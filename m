From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Mark non 64bit clean network drivers
Date: Tue, 7 Oct 2003 19:53:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007175338.GA1692@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This marks some net drivers which are clearly not 64bit (judging from
the warnings) as !64BIT.

-Andi
 
diff -u linux-2.5-cleanup/drivers/net/Kconfig-o linux-2.5-cleanup/drivers/net/Kconfig
--- linux-2.5-cleanup/drivers/net/Kconfig-o	2003-10-02 18:12:03.000000000 +0200
+++ linux-2.5-cleanup/drivers/net/Kconfig	2003-12-02 17:20:58.742717656 +0100
@@ -1616,7 +1616,7 @@
 
 config TLAN
 	tristate "TI ThunderLAN support"
-	depends on NET_PCI && (PCI || EISA)
+	depends on NET_PCI && (PCI || EISA) && !64BIT
 	---help---
 	  If you have a PCI Ethernet network card based on the ThunderLAN chip
 	  which is supported by this driver, say Y and read the
@@ -2412,7 +2412,7 @@
 
 config RCPCI
 	tristate "Red Creek Hardware VPN (EXPERIMENTAL)"
-	depends on NETDEVICES && EXPERIMENTAL && PCI
+	depends on NETDEVICES && EXPERIMENTAL && PCI && !64BIT
 	help
 	  This is a driver for hardware which provides a Virtual Private
 	  Network (VPN). Say Y if you have it.
 	
