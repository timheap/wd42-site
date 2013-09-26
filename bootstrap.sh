#!/bin/bash
# Funky user function procured from:
# http://www.cyberciti.biz/tips/howto-write-shell-script-to-add-user.html
function user {
  if [ $(id -u) -eq 0 ]; then
    echo "Creating user : $1"
    read -s -p "Enter password : " password
    egrep "^$1" /etc/passwd >/dev/null
    if [ $? -eq 0 ]; then
      echo "user $1 exists!"
      exit 1
    else
      pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
      useradd -m -p $pass $1
      [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
    fi
  else
    echo "Only root may add a user to the system"
    exit 2
  fi
}

echo "The required packages are about to be installed:"
sleep 1
apt-get update && apt-get upgrade -y
apt-get install -y software-properties-common python-software-properties
add-apt-repository ppa:chris-lea/node.js
apt-get update && apt-get install -y python g++ make git nginx nodejs=0.10.18-1chl1~precise1

echo "Setting up services:"
sleep 1
# Acquiring node upsart script
curl https://raw.github.com/wd42/wd42-site/deplyment/upstart/wd42-site.conf -o /etc/init/wd42-site.conf
service wd42-site start
curl https://raw.github.com/wd42/wd42-site/deplyment/nginx/wd42-site -o /etc/nginx/sites-available/wd42-site
ln -s /etc/nginx/sites-available/wd42-site /etc/nginx/sites-enabled/wd42-site
# Ensures no conficts for node app
rm /etc/nginx/sites-enabled/default
service nginx start
# To be sure nginx is set to come up after a reboot
update-rc.d nginx defaults

echo "Cloning application:"
mkdir -p /srv/www/wd42-site
cd /srv/www/wd42-site
git clone https://github.com/wd42/wd42-site .
npm install
node app.js

