From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 063/199] Documentation/isdn/syncPPP.FAQ: Checkpatch cleanup
Date: Sun, 23 May 2010 21:50:26 +0200
Message-ID: <1274644226-23612-12-git-send-email-andrea.gelmini@gelma.net>
References: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
To: andrea.gelmini@gelma.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:9896 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753535Ab0EWTvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 15:51:05 -0400
In-Reply-To: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Documentation/isdn/syncPPP.FAQ:1: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:8: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:13: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:15: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:29: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:38: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:41: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:42: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:51: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:58: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:63: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:64: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:67: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:72: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:77: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:82: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:109: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:130: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:139: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:141: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:152: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:162: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:181: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:184: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:207: ERROR: trailing whitespace
Documentation/isdn/syncPPP.FAQ:217: ERROR: trailing whitespace

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 Documentation/isdn/syncPPP.FAQ |   52 ++++++++++++++++++++--------------------
 1 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/Documentation/isdn/syncPPP.FAQ b/Documentation/isdn/syncPPP.FAQ
index 3257a4b..bf4d912 100644
--- a/Documentation/isdn/syncPPP.FAQ
+++ b/Documentation/isdn/syncPPP.FAQ
@@ -1,18 +1,18 @@
-simple isdn4linux PPP FAQ .. to be continued .. not 'debugged' 
+simple isdn4linux PPP FAQ .. to be continued .. not 'debugged'
 -------------------------------------------------------------------
 
 Q01: what's pppd, ipppd, syncPPP, asyncPPP ??
 Q02: error message "this system lacks PPP support"
 Q03: strange information using 'ifconfig'
 Q04: MPPP?? What's that and how can I use it ...
-Q05: I tried MPPP but it doesn't work 
+Q05: I tried MPPP but it doesn't work
 Q06: can I use asynchronous PPP encapsulation with network devices
 Q07: A SunISDN machine can't connect to my i4l system
 Q08: I wanna talk to several machines, which need different configs
 Q09: Starting the ipppd, I get only error messages from i4l
-Q10: I wanna use dynamic IP address assignment 
+Q10: I wanna use dynamic IP address assignment
 Q11: I can't connect. How can I check where the problem is.
-Q12: How can I reduce login delay? 
+Q12: How can I reduce login delay?
 
 -------------------------------------------------------------------
 
@@ -26,7 +26,7 @@ A: The pppd is for asynchronous PPP .. asynchronous means
    frames (bit based protocol) ... The PPP driver
    in isdn4linux pushes all IP packets direct
    to the network layer and all PPP protocol
-   frames to the /dev/ippp* device. 
+   frames to the /dev/ippp* device.
    So, the ipppd is a simple external network
    protocol handler.
 
@@ -35,11 +35,11 @@ A: The pppd is for asynchronous PPP .. asynchronous means
    remote terminal server -> use the 'old' pppd
 
    If your remote side immediately starts to send
-   frames ... you probably connect to a 
+   frames ... you probably connect to a
    syncPPP machine .. use the network device part
    of isdn4linux with the 'syncppp' encapsulation
-   and make sure, that the ipppd is running and 
-   connected to at least one /dev/ippp*. Check the 
+   and make sure, that the ipppd is running and
+   connected to at least one /dev/ippp*. Check the
    isdn4linux manual on how to configure a network device.
 
 --
@@ -48,38 +48,38 @@ Q02: when I start the ipppd .. I only get the
    error message "this system lacks PPP support"
 A: check that at least the device 'ippp0' exists.
    (you can check this e.g with the program 'ifconfig')
-   The ipppd NEEDS this device under THIS name .. 
+   The ipppd NEEDS this device under THIS name ..
    If this device doesn't exists, use:
 	isdnctrl addif ippp0
 	isdnctrl encap ippp0 syncppp
 	... (see isdn4linux doc for more) ...
 A: Maybe you have compiled the ipppd with another
    kernel source tree than the kernel you currently
-   run ... 
+   run ...
 
 --
 
 Q03: when I list the netdevices with ifconfig I see, that
-   my ISDN interface has a HWaddr and IRQ=0 and Base 
-   address = 0 
+   my ISDN interface has a HWaddr and IRQ=0 and Base
+   address = 0
 A: The device is a fake ethernet device .. ignore IRQ and baseaddr
    You need the HWaddr only for ethernet encapsulation.
-   
+
 --
 
 Q04: MPPP?? What's that and how can I use it ...
 
-A: MPPP or MP or MPP (Warning: MP is also an 
+A: MPPP or MP or MPP (Warning: MP is also an
    acronym for 'Multi Processor') stands for
    Multi Point to Point and means bundling
    of several channels to one logical stream.
    To enable MPPP negotiation you must call the
-   ipppd with the '+mp' option. 
+   ipppd with the '+mp' option.
    You must also configure a slave device for
    every additional channel. (see the i4l manual
    for more)
    To use channel bundling you must first activate
-   the 'master' or initial call. Now you can add 
+   the 'master' or initial call. Now you can add
    the slave channels with the command:
        isdnctrl addlink <device>
    e.g:
@@ -106,7 +106,7 @@ Q06: can I use asynchronous PPP encapsulation
 A: No .. that's not possible .. Use the standard
    PPP package over the /dev/ttyI* devices. You
    must not use the ipppd for this.
-   
+
 --
 
 Q07: A SunISDN machine tries to connect my i4l system,
@@ -127,7 +127,7 @@ Q08: I wanna talk to remote machines, which need
    a different configuration. The only way
    I found to do this is to kill the ipppd and
    start a new one with another config to connect
-   to the second machine. 
+   to the second machine.
 
 A: you must bind a network interface explicitly to
    an ippp device, where you can connect a (for this
@@ -136,9 +136,9 @@ A: you must bind a network interface explicitly to
 --
 
 Q09: When I start the ipppd I only get error messages
-   from the i4l driver .. 
+   from the i4l driver ..
 
-A: When starting, the ipppd calls functions which may 
+A: When starting, the ipppd calls functions which may
    trigger a network packet. (e.g gethostbyname()).
    Without the ipppd (at this moment, it is not
    fully started) we can't handle this network request.
@@ -149,7 +149,7 @@ A: When starting, the ipppd calls functions which may
 
 --
 
-Q10: I wanna use dynamic IP address assignment ... How 
+Q10: I wanna use dynamic IP address assignment ... How
    must I configure the network device.
 
 A: At least you must have a route which forwards
@@ -159,7 +159,7 @@ A: At least you must have a route which forwards
    Now you must choose a dummy IP address for your
    interface.
    If for some reason you can't set the default
-   route to the ippp interface, you may take any 
+   route to the ippp interface, you may take any
    address of the subnet from which you expect your
    dynamic IP number and set a 'network route' for
    this subnet to the ippp interface.
@@ -178,10 +178,10 @@ A: You must know, how the ipppd gets the addresses it wanna
    If your side doesn't know the IP address after negotiation, it
    closes the connection!
    You must allow overriding of address with the 'ipcp-accept-*'
-   options, if you have set your own or the remote address 
+   options, if you have set your own or the remote address
    explicitly.
 
-A: Maybe you try these options .. e.g:   
+A: Maybe you try these options .. e.g:
 
     /sbin/ipppd :$REMOTE noipdefault /dev/ippp0
 
@@ -204,7 +204,7 @@ A: A good help log is the debug output from the ipppd...
         you can see, whether there is activity on the card/line.
    - there are at least a few RECV messages in the log:
      -> fine: your card is dialing and your remote machine
-        tries to talk with you. Maybe only a missing 
+        tries to talk with you. Maybe only a missing
         authentication. Check your ipppd configuration again.
    - the ipppd exits for some reason:
      -> not good ... check /var/adm/syslog and /var/adm/daemon.
@@ -214,7 +214,7 @@ A: A good help log is the debug output from the ipppd...
 
 Q12: How can I reduce login delay?
 
-A: Log a login session ('debug' log) and check which options 
+A: Log a login session ('debug' log) and check which options
   your remote side rejects. Next time configure your ipppd
   to not negotiate these options. Another 'side effect' is, that
   this increases redundancy. (e.g your remote side is buggy and
-- 
1.7.1.251.gf80a2

