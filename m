From: "=?iso-8859-1?Q?xavier.droubay@laposte.net?=" <xavier.droubay@laposte.net>
Subject: =?iso-8859-1?Q?3C900-COMBO_lan_minor_problem?=
Date: Fri, 10 Sep 2004 13:23:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <I3TOZ2$AFEE6488A486CE1253583AF122FFF53B@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "=?iso-8859-1?Q?netdev?=" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello, and sorry to bother you concerning my 
problems, but I am quite new in linux and don't 
know much about bug reportings. I got your address 
in vortext.txt file from kernel 2.6.8. 

I use the 3c59x driver for my 3COM 900 Combo 
Ethernet Card on
a box B1. I use this card on a lan, which is a set 
of 2 boxes
connected with a crossover cable. When I disconnect 
the cable
for a while (about 30 seconds), or boot my box B2 
after box
B1, I always have to restart network '/etc/init.
d/network
restart' or do a 'ifconfig eth1 down ; ifconfig 
eth1 up' on
box B1. I have double boot with windows on both 
boxes, and I
tested with windows on box1: I had no problem to 
ping both boxes. 

I can try to generate a bug report as mentionned in 
file
vortext.txt, but you may know this problem, that 
seems to
have been already reproduced see page 
http://lists.debian.
org/debian-user/2001/08/msg01564.html
It is a closely related or same problem. 

I found on libranet site an update of the 3c59x 
driver for
kernel greater than 2.4.23. They mentionned an 
eventual
improvement of the driver for the problem, at page: 
http://libranet.com/support/2.8/0305
I tried this update, upgrading to kernel 2.4.27 on 
box B1,
with no improvement for the problem. 

I cannot get the latest source driver, and don't 
know if
improvements have been done after 2.4.23. Do you 
know if an
improvement of this driver has been released for 
the problem ?
Or should I set options I did not find for this 
module ? Even 
though I guess it is not directly related to my 
problem, tried 
the option "enable_wol=1" in my modules.conf file, 
with no effect. 
This is a minor problem, but I would like to know 
if it can be solved.


I have seen that you still did a lot of work for 
kernel v2.6.x versions, so are
there improvements for 2.6.x kerenels ?


Thank you, Xavier.
