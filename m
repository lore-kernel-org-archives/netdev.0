From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 2/7] drivers/s390/net: Kconfig brush up
Date: Fri, 01 Feb 2008 15:51:30 +0100
Message-ID: <20080201145257.329130000@linux.vnet.ibm.com>
References: <20080201145128.462823000@linux.vnet.ibm.com>
Cc: Peter Tiedemann <ptiedem@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:21652 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754870AbYBAOw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 09:52:59 -0500
Content-Disposition: inline; filename=kconfig.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Tiedemann <ptiedem@de.ibm.com>
From: Ursula Braun <braunu@de.ibm.com>

adapt drivers/s390/net/Kconfig to current IBM wording
and further cosmetics

Signed-off-by: Peter Tiedemann <ptiedem@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>

---
 drivers/s390/net/Kconfig |   43 ++++++++++++++++++++++---------------------
 1 file changed, 22 insertions(+), 21 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/Kconfig
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/Kconfig
+++ linux-2.6-uschi/drivers/s390/net/Kconfig
@@ -5,22 +5,23 @@ config LCS
 	tristate "Lan Channel Station Interface"
 	depends on CCW && NETDEVICES && (NET_ETHERNET || TR || FDDI)
 	help
-	   Select this option if you want to use LCS networking  on IBM S/390
-  	   or zSeries. This device driver supports Token Ring (IEEE 802.5),
-  	   FDDI (IEEE 802.7) and Ethernet. 
-	   This option is also available as a module which will be
-	   called lcs.ko. If you do not know what it is, it's safe to say "Y".
+	   Select this option if you want to use LCS networking on IBM System z.
+	   This device driver supports Token Ring (IEEE 802.5),
+	   FDDI (IEEE 802.7) and Ethernet.
+	   To compile as a module, choose M. The module name is lcs.ko.
+	   If you do not know what it is, it's safe to choose Y.
 
 config CTC
 	tristate "CTC device support"
 	depends on CCW && NETDEVICES
 	help
-	  Select this option if you want to use channel-to-channel networking
-	  on IBM S/390 or zSeries. This device driver supports real CTC
-	  coupling using ESCON. It also supports virtual CTCs when running
-	  under VM. It will use the channel device configuration if this is
-	  available.  This option is also available as a module which will be
-	  called ctc.ko.  If you do not know what it is, it's safe to say "Y".
+	  Select this option if you want to use channel-to-channel
+	  point-to-point networking on IBM System z.
+	  This device driver supports real CTC coupling using ESCON.
+	  It also supports virtual CTCs when running under VM.
+	  To compile as a module, choose M. The module name is ctc.ko.
+	  To compile into the kernel, choose Y.
+	  If you do not need any channel-to-channel connection, choose N.
 
 config NETIUCV
 	tristate "IUCV network device support (VM only)"
@@ -29,9 +30,9 @@ config NETIUCV
 	  Select this option if you want to use inter-user communication
 	  vehicle networking under VM or VIF. It enables a fast communication
 	  link between VM guests. Using ifconfig a point-to-point connection
-	  can be established to the Linux for zSeries and S7390 system
-	  running on the other VM guest. This option is also available
-	  as a module which will be called netiucv.ko. If unsure, say "Y".
+	  can be established to the Linux on IBM System z
+	  running on the other VM guest. To compile as a module, choose M.
+	  The module name is netiucv.ko. If unsure, choose Y.
 
 config SMSGIUCV
 	tristate "IUCV special message support (VM only)"
@@ -47,22 +48,22 @@ config CLAW
 	  This driver supports channel attached CLAW devices.
 	  CLAW is Common Link Access for Workstation.  Common devices
           that use CLAW are RS/6000s, Cisco Routers (CIP) and 3172 devices.
-	  To compile as a module choose M here:  The module will be called
-	  claw.ko to compile into the kernel choose Y
+	  To compile as a module, choose M. The module name is claw.ko.
+	  To compile into the kernel, choose Y.
 
 config QETH
 	tristate "Gigabit Ethernet device support"
 	depends on CCW && NETDEVICES && IP_MULTICAST && QDIO
 	help
-	  This driver supports the IBM S/390 and zSeries OSA Express adapters
+	  This driver supports the IBM System z OSA Express adapters
 	  in QDIO mode (all media types), HiperSockets interfaces and VM GuestLAN
 	  interfaces in QDIO and HIPER mode.
 	
-	  For details please refer to the documentation provided by IBM at   
-	  <http://www10.software.ibm.com/developerworks/opensource/linux390>
+	  For details please refer to the documentation provided by IBM at
+	  <http://www.ibm.com/developerworks/linux/linux390>
 
-	  To compile this driver as a module, choose M here: the
-	  module will be called qeth.ko.
+	  To compile this driver as a module, choose M.
+	  The module name is qeth.ko.
 
 
 comment "Gigabit Ethernet default settings"

-- 
