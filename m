From: carl@bookmanassociates.com
Subject: Linux kernel hanging with certain networking configuration - uncertain of relevant maintainer
Date: Fri, 13 Jun 2003 16:00:32 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EE9F520.13447.9611F8@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-description: Mail message body
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

Sorry to bother you if you're the wrong person to contact, I got your name from the 
MAINTAINERS list in /usr/src/linux on my distribution (kernel 2.4.4).  If you are the 
wrong person could you tell me where I should go please?

We have successfully used a linux server in our small office for a year now and it has 
been almost entirely stable.  Recently I configured a VPN to connect to one of our 
client sites.  I installed a linux server at that site also, because they are behind a 
firewall over which I have no control (being on a medical school's network) I used the 
method described in the Firewall Piercing mini-howto.  Namely I configured pppd to 
run ssh to connect from that machine to ours here and run pppd on this end, once the 
tunnel is set up both ends add routes through it to each other's subnets in the ip-up 
scripts on either end (neither end is using PPP for any other connections, both are 
connected to the "outside world" via ethernet NICs).

This tunnel is largely stable and satisfactory but if intensive load is placed on it (the 
reliable, reproducible load I use is a remote control software package called PC Duo) 
then the server machine at our end hangs and has to be rebooted using the reset 
button on the front or a power off/on cycle.  The machine becomes completely 
unresponsive to pinging from other machines on our LAN, the keyboard becomes 
unresponsive and the screen freezes.

I understand that this is called a "kernel panic" but, unlike other reports I have seen 
on the internet, there is no "oops" dump thing that comes up on the screen - the 
screen simply freezes.

To add to the mystery I have found this problem with both the OpenSSH package 
and the non-commercial SSH package (v3.2.3) from ftp.ssh.com PLUS I have also 
seen something similar where I ran an SSH client on a Windows PC here that 
connected to the SSH daemon on their firewall with the relevant port for PCDuo 
control forwarded and then ran an ssh client on that firewall machine through to an 
SSH daemon on the linux box I support in our client's office, again forwarding the 
port.  This configuration doesn't use ppp at any point yet when I ran PCDuo control 
over that connection it worked briefly then hung their server, which again had to be 
rebooted!

Can you help at all?  Is there some way of getting this "oops" output from linux if that 
would help?

Yours with regards,
Carl Peto
