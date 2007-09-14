From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH] NET_SB1250_MAC: Update Kconfig entry
Date: Fri, 14 Sep 2007 11:57:33 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0709141148540.1926@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.ds.pg.gda.pl ([153.19.208.18]:38825 "EHLO
	cerber.ds.pg.gda.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206AbXINK5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 06:57:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 The SB1250 network interfaces are Gigabit Ethernet ones.  Move the 
Kconfig entry to the appropriate section and add some help text.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 It should be obvious; I hope the help text will be useful to somebody and 
will prevent from misclassifying the interface again in the future.

 Please apply,

  Maciej

patch-netdev-2.6.23-rc6-20070913-sb1250-mac-kconfig-0
diff -up --recursive --new-file linux-netdev-2.6.23-rc6-20070913.macro/drivers/net/Kconfig linux-netdev-2.6.23-rc6-20070913/drivers/net/Kconfig
--- linux-netdev-2.6.23-rc6-20070913.macro/drivers/net/Kconfig	2007-09-13 17:27:52.000000000 +0000
+++ linux-netdev-2.6.23-rc6-20070913/drivers/net/Kconfig	2007-09-14 00:02:05.000000000 +0000
@@ -466,10 +466,6 @@ config MIPS_AU1X00_ENET
 	  If you have an Alchemy Semi AU1X00 based system
 	  say Y.  Otherwise, say N.
 
-config NET_SB1250_MAC
-	tristate "SB1250 Ethernet support"
-	depends on SIBYTE_SB1xxx_SOC
-
 config SGI_IOC3_ETH
 	bool "SGI IOC3 Ethernet"
 	depends on PCI && SGI_IP27
@@ -2157,6 +2153,18 @@ config R8169_VLAN
 	  
 	  If in doubt, say Y.
 
+config NET_SB1250_MAC
+	tristate "SB1250 Gigabit Ethernet support"
+	depends on SIBYTE_SB1xxx_SOC
+	---help---
+	  This driver supports Gigabit Ethernet interfaces based on the
+	  Broadcom SiByte family of System-On-a-Chip parts.  They include
+	  the BCM1120, BCM1125, BCM1125H, BCM1250, BCM1255, BCM1280, BCM1455
+	  and BCM1480 chips.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sb1250-mac.
+
 config SIS190
 	tristate "SiS190/SiS191 gigabit ethernet support"
 	depends on PCI
