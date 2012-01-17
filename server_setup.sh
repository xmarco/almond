#!/usr/bin/env bash

echo "Using apt-get to install OS packages so let's update it first ..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "Installing OS packages. You will be prompted for your password ..."
sudo apt-get install build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev -y

echo "Creating new account with username 'deployer'..."
sudo useradd -m -g staff -s /bin/bash deployer

echo "Granting sudo privilege to members of the staff group"
sudo sh -c "echo '' >> /etc/sudoers"
sudo sh -c "echo '# Members of the staff group may gain root privileges' >> /etc/sudoers"
sudo sh -c "echo '%staff ALL=(ALL) ALL' >> /etc/sudoers"

echo "Installing PostgreSQL ..."
sudo apt-get install libpq5 libpq-dev postgresql -y

echo "Installing ack, a good way to search through files ..."
sudo apt-get install ack-grep -y

echo "Installing ImageMagick, good for cropping and re-sizing images ..."
sudo apt-get install imagemagick --fix-missing -y

echo "Installing nginx"
sudo apt-get install nginx -y
sudo cp /etc/nginx/nginx.conf /etc/nginx/default_nginx.conf
sudo sh -c "sed -i '/sites-enabled\/\*;/ a include /home/deployer/www/*/conf/nginx.conf;' /etc/nginx/nginx.conf"
sudo sh -c "sed -i '/www-data/ c user deployer staff;' /etc/nginx/nginx.conf"
sudo /etc/init.d/nginx start

echo "Installing Webmin"
sudo sh -c "echo '' >> /etc/apt/sources.list"
sudo sh -c "echo '# Source for Webmin' >> /etc/apt/sources.list"
sudo sh -c "echo 'deb http://download.webmin.com/download/repository sarge contrib' >> /etc/apt/sources.list"
sudo sh -c "echo 'deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib' >> /etc/apt/sources.list"
sudo curl http://www.webmin.com/jcameron-key.asc -o /root/jcameron-key.asc
sudo apt-key add /root/jcameron-key.asc
sudo apt-get update -y
sudo apt-get install webmin -y

echo "Installing RVM (Ruby Version Manager) ..."
sudo bash < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)
sudo usermod -G rvm deployer

echo "Adding auto-trust for project .rvmrc files ..."
sudo sh -c "echo '' >> /etc/rvmrc"
sudo sh -c "echo 'rvm_trust_rvmrcs_flag=1' >> /etc/rvmrc"

echo "Installing Ruby 1.9.2 stable and making it the default Ruby ..."
su deployer -c "rvm install 1.9.2 && rvm use 1.9.2 --default && gem update --system"

echo "Omitting RI and RDOC ..."
sudo sh -c "touch /home/deployer/.gemrc"
sudo sh -c "echo 'gem: --no-ri --no-rdoc' >> /home/deployer/.gemrc"

echo "Setting the golbal environment to production for rails ..."
sudo sh -c "echo '' >> /etc/environment"
sudo sh -c "echo '# Run all rails apps in production mode' >> /etc/environment"
sudo sh -c "echo 'RAILS_ENV=production' >> /etc/environment"

echo "Please set password for 'deployer' ..."
sudo passwd deployer

echo "Now formally switch to 'deployer' ..."
su deployer
