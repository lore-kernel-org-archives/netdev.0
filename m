From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 060/199] Documentation/isdn/README.sc: Checkpatch cleanup
Date: Sun, 23 May 2010 21:50:24 +0200
Message-ID: <1274644226-23612-10-git-send-email-andrea.gelmini@gelma.net>
References: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
To: andrea.gelmini@gelma.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:9896 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754492Ab0EWTu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 15:50:56 -0400
In-Reply-To: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Documentation/isdn/README.sc:3: ERROR: trailing whitespace
Documentation/isdn/README.sc:30: ERROR: trailing whitespace
Documentation/isdn/README.sc:106: ERROR: trailing whitespace
Documentation/isdn/README.sc:120: ERROR: trailing whitespace
Documentation/isdn/README.sc:123: ERROR: trailing whitespace
Documentation/isdn/README.sc:143: ERROR: trailing whitespace
Documentation/isdn/README.sc:162: ERROR: trailing whitespace
Documentation/isdn/README.sc:165: ERROR: trailing whitespace
Documentation/isdn/README.sc:166: ERROR: trailing whitespace
Documentation/isdn/README.sc:168: ERROR: trailing whitespace
Documentation/isdn/README.sc:187: ERROR: trailing whitespace
Documentation/isdn/README.sc:188: ERROR: trailing whitespace
Documentation/isdn/README.sc:189: ERROR: trailing whitespace
Documentation/isdn/README.sc:192: ERROR: trailing whitespace
Documentation/isdn/README.sc:196: ERROR: trailing whitespace
Documentation/isdn/README.sc:201: ERROR: trailing whitespace
Documentation/isdn/README.sc:202: ERROR: trailing whitespace
Documentation/isdn/README.sc:207: ERROR: trailing whitespace
Documentation/isdn/README.sc:212: ERROR: trailing whitespace
Documentation/isdn/README.sc:213: ERROR: trailing whitespace
Documentation/isdn/README.sc:214: ERROR: trailing whitespace
Documentation/isdn/README.sc:215: ERROR: trailing whitespace
Documentation/isdn/README.sc:217: ERROR: trailing whitespace
Documentation/isdn/README.sc:218: ERROR: trailing whitespace
Documentation/isdn/README.sc:219: ERROR: trailing whitespace
Documentation/isdn/README.sc:220: ERROR: trailing whitespace
Documentation/isdn/README.sc:224: ERROR: trailing whitespace
Documentation/isdn/README.sc:230: ERROR: trailing whitespace
Documentation/isdn/README.sc:237: ERROR: trailing whitespace
Documentation/isdn/README.sc:238: ERROR: trailing whitespace
Documentation/isdn/README.sc:239: ERROR: trailing whitespace
Documentation/isdn/README.sc:240: ERROR: trailing whitespace
Documentation/isdn/README.sc:241: ERROR: trailing whitespace
Documentation/isdn/README.sc:244: ERROR: trailing whitespace
Documentation/isdn/README.sc:247: ERROR: trailing whitespace
Documentation/isdn/README.sc:252: ERROR: trailing whitespace
Documentation/isdn/README.sc:255: ERROR: trailing whitespace
Documentation/isdn/README.sc:264: ERROR: trailing whitespace
Documentation/isdn/README.sc:265: ERROR: trailing whitespace
Documentation/isdn/README.sc:268: ERROR: trailing whitespace

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 Documentation/isdn/README.sc |   80 +++++++++++++++++++++---------------------
 1 files changed, 40 insertions(+), 40 deletions(-)

diff --git a/Documentation/isdn/README.sc b/Documentation/isdn/README.sc
index 1153cd9..f9641b8 100644
--- a/Documentation/isdn/README.sc
+++ b/Documentation/isdn/README.sc
@@ -1,6 +1,6 @@
 Welcome to Beta Release 2 of the combination ISDN driver for SpellCaster's
 ISA ISDN adapters. Please note this release 2 includes support for the
-DataCommute/BRI and TeleCommute/BRI adapters only and any other use is 
+DataCommute/BRI and TeleCommute/BRI adapters only and any other use is
 guaranteed to fail. If you have a DataCommute/PRI installed in the test
 computer, we recommend removing it as it will be detected but will not
 be usable.  To see what we have done to Beta Release 2, see section 3.
@@ -27,7 +27,7 @@ TABLE OF CONTENTS
 	 1.2 What is different between this driver and previous drivers?
 	 1.3 How do I setup my system with the correct software to use
 	     this driver release?
-	
+
 	2. Basic Operations
 	 2.1 Unpacking and installing the driver
 	 2.2 Read the man pages!!!
@@ -103,7 +103,7 @@ must ensure that the following software is installed, configured and running:
 	- The latest modules package (modules-2.0.0.tar.gz) from
 	  ftp://sunsite.unc.edu/pub/Linux/kernel/modules-2.0.0.tar.gz
 
-	- The ISDN4Linux tools available from 
+	- The ISDN4Linux tools available from
 	  ftp://ftp.franken.de/pub/isdn4linux/v2.0/isdn4k-utils-2.0.tar.gz
 	  This package may fail to compile for you so you can alternatively
 	  get a pre-compiled version from
@@ -117,10 +117,10 @@ must ensure that the following software is installed, configured and running:
 
 	1. As root, create a directory in a convenient place. We suggest
 	   /usr/src/spellcaster.
-	
+
 	2. Unpack the archive with :
 		tar xzf sc-n.nn.tar.gz -C /usr/src/spellcaster
-	
+
 	3. Change directory to /usr/src/spellcaster
 
 	4. Read the README and RELNOTES files.
@@ -140,7 +140,7 @@ you can specify but you shouldn't need to use any unless this doesn't work.
 Make sure the driver loaded and detected all of the adapters by typing
 'dmesg'.
 
-The driver can be configured so that it is loaded upon startup.  To do this, 
+The driver can be configured so that it is loaded upon startup.  To do this,
 edit the file "/etc/modules/'uname -f'/'uname -v'" and insert the driver name
 "sc" into this file.
 
@@ -159,13 +159,13 @@ If you get a message that says 'initialization of sc failed', then the
 driver failed to detect an adapter or failed to find resources needed such
 as a free IRQ line or shared memory segment. If you are sure there are free
 resources available, use the insmod options detailed in sc(4) to override
-the probing function.  
+the probing function.
 
 Upon testing, the following problem was noted, the driver would load without
-problems, but the board would not respond beyond that point.  When a check was 
-done with 'cat /proc/interrupts' the interrupt count for sc was 0.  In the event 
+problems, but the board would not respond beyond that point.  When a check was
+done with 'cat /proc/interrupts' the interrupt count for sc was 0.  In the event
 of this problem, change the BIOS settings so that the interrupts in question are
-reserved for ISA use only.   
+reserved for ISA use only.
 
 
 2.6 How to setup ISDN4Linux with the driver
@@ -184,75 +184,75 @@ A) 10 steps to the establishment of a basic HDLC connection
 -----------------------------------------------------------
 
 - please open the isdn-hdlc file in the examples directory and follow along...
-	
-	This file is a script used to configure a BRI ISDN TA to establish a 
-	basic HDLC connection between its two channels.  Two network 
+
+	This file is a script used to configure a BRI ISDN TA to establish a
+	basic HDLC connection between its two channels.  Two network
 	interfaces are created and two routes added between the channels.
 
-	i)   using the isdnctrl utility, add an interface with "addif" and 
+	i)   using the isdnctrl utility, add an interface with "addif" and
 	     name it "isdn0"
 	ii)  add the outgoing and inbound telephone numbers
 	iii) set the Layer 2 protocol to hdlc
-	iv)  set the eaz of the interface to be the phone number of that 
+	iv)  set the eaz of the interface to be the phone number of that
 	     specific channel
 	v)   to turn the callback features off, set the callback to "off" and
 	     the callback delay (cbdelay) to 0.
 	vi)  the hangup timeout can be set to a specified number of seconds
-	vii) the hangup upon incoming call can be set on or off 
-	viii) use the ifconfig command to bring up the network interface with 
+	vii) the hangup upon incoming call can be set on or off
+	viii) use the ifconfig command to bring up the network interface with
 	      a specific IP address and point to point address
 	ix)  add a route to the IP address through the isdn0 interface
 	x)   a ping should result in the establishment of the connection
 
-	
+
 B) Establishment of a PPP connection
 ------------------------------------
 
 - please open the isdn-ppp file in the examples directory and follow along...
-	
-	This file is a script used to configure a BRI ISDN TA to establish a 
-	PPP connection 	between the two channels.  The file is almost 
-	identical to the HDLC connection example except that the packet 
+
+	This file is a script used to configure a BRI ISDN TA to establish a
+	PPP connection 	between the two channels.  The file is almost
+	identical to the HDLC connection example except that the packet
 	encapsulation type has to be set.
-	
-	use the same procedure as in the HDLC connection from steps i) to 
-	iii) then, after the Layer 2 protocol is set, set the encapsulation 
-	"encap" to syncppp. With this done, the rest of the steps, iv) to x) 
+
+	use the same procedure as in the HDLC connection from steps i) to
+	iii) then, after the Layer 2 protocol is set, set the encapsulation
+	"encap" to syncppp. With this done, the rest of the steps, iv) to x)
 	can be followed from above.
 
 	Then, the ipppd (ippp daemon) must be setup:
-	
+
 	xi)   use the ipppd function found in /sbin/ipppd to set the following:
 	xii)  take out (minus) VJ compression and bsd compression
 	xiii) set the mru size to 2000
 	xiv)  link the two /dev interfaces to the daemon
 
-NOTE:  A "*" in the inbound telephone number specifies that a call can be 
+NOTE:  A "*" in the inbound telephone number specifies that a call can be
 accepted on any number.
 
 C) Establishment of a MLPPP connection
 --------------------------------------
 
 - please open the isdn-mppp file in the examples directory and follow along...
-	
-	This file is a script used to configure a BRI ISDN TA to accept a 
-	Multi Link PPP connection. 
-	
-	i)   using the isdnctrl utility, add an interface with "addif" and 
+
+	This file is a script used to configure a BRI ISDN TA to accept a
+	Multi Link PPP connection.
+
+	i)   using the isdnctrl utility, add an interface with "addif" and
 	     name it "ippp0"
 	ii)  add the inbound telephone number
-	iii) set the Layer 2 protocol to hdlc and the Layer 3 protocol to 
+	iii) set the Layer 2 protocol to hdlc and the Layer 3 protocol to
 	     trans (transparent)
 	iv)  set the packet encapsulation to syncppp
-	v)   set the eaz of the interface to be the phone number of that 
+	v)   set the eaz of the interface to be the phone number of that
 	     specific channel
 	vi)  to turn the callback features off, set the callback to "off" and
 	     the callback delay (cbdelay) to 0.
 	vi)  the hangup timeout can be set to a specified number of seconds
-	vii) the hangup upon incoming call can be set on or off 
+	vii) the hangup upon incoming call can be set on or off
 	viii) add a slave interface and name it "ippp32" for example
 	ix)  set the similar parameters for the ippp32 interface
-	x)   use the ifconfig command to bring-up the ippp0 interface with a 
+	x)   use the ifconfig command to bring-up the ippp0 interface with a
 	     specific IP address and point to point address
 	xi)  add a route to the IP address through the ippp0 interface
 	xii) use the ipppd function found in /sbin/ipppd to set the following:
@@ -261,11 +261,11 @@ C) Establishment of a MLPPP connection
 	xv)  add (+) the multi-link function "+mp"
 	xvi)  link the two /dev interfaces to the daemon
 
-NOTE:  To use the MLPPP connection to dial OUT to a MLPPP connection, change 
-the inbound telephone numbers to the outgoing telephone numbers of the MLPPP 
+NOTE:  To use the MLPPP connection to dial OUT to a MLPPP connection, change
+the inbound telephone numbers to the outgoing telephone numbers of the MLPPP
 host.
 
-	
+
 3. Beta Change Summaries and Miscellaneous Notes
 ------------------------------------------------
 When using the "scctrl" utility to upload firmware revisions on the board,
-- 
1.7.1.251.gf80a2

