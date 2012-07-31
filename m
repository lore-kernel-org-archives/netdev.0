From: Bernard Pidoux <bernard.pidoux@free.fr>
Subject: CPU: 0 Not tainted  (3.1.9+ #1) when ifconfig rose0 down
Date: Tue, 31 Jul 2012 16:11:18 +0200
Message-ID: <5017E786.5000102@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-hams <linux-hams@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I observe systematically a kernel panic when I try to shutdown rose0 
device using ifconfig rose0 down

This is happening on two very different ROSE implementation, one is on a 
machine with x86-64 kernel 4.6.3 on an Intel core 2 duo CPU
the other is on a RaspBerry Pi with Raspbian and 3.1.9+ wheezy kernel
recompiled with AX.25 modules (ax25, rose, netrom, 6pack, kiss) enabled.

Here is an image of the screen dump :

http://f6bvp.org/photos/rose_device_event.JPG

It can be noticed that PC is at rose_device_event and
LR is at sock_def_wakeup

One thing to be noticed is that when I close before all ROSE and AX.25 
applications, there are still a few populated sockets, probably for one 
of the program did not close the sockets properly.

I that case, does rose module should accept to shutdown rose0 device ?
However, I guess that it should not create a kernel panic due to a 
kernel NULL pointer.

I don't know what to do in order to debug that issue.

Bernard

