From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 5/5] skge/sky2: change config references to Marvell
Date: Thu, 07 Jul 2011 08:51:01 -0700
Message-ID: <20110707155212.350112276@vyatta.com>
References: <20110707155056.939223264@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:56591 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752732Ab1GGQnn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2011 12:43:43 -0400
Content-Disposition: inline; filename=marvell.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change references to SysKonnect in Kconfig to Marvell since
SysKonnect was acquired by Marvell back in 2002.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/Kconfig	2011-07-07 08:39:18.456011945 -0700
+++ b/drivers/net/Kconfig	2011-07-07 08:43:41.372026416 -0700
@@ -2272,7 +2272,7 @@ config SIS190
 	  will be called sis190.  This is recommended.
 
 config SKGE
-	tristate "SysKonnect GigaEthernet support"
+	tristate "Marvell Yukon Gigabit Ethernet support"
 	depends on PCI
 	select CRC32
 	---help---
@@ -2288,7 +2288,7 @@ config SKGE
 	  Linksys EG1032/EG1064, 3Com 3C940/3C940B, SysKonnect SK-9871/9872.
 
 	  It does not support the newer Yukon2 chipset: a separate driver,
-	  sky2, is provided for Yukon2-based adapters.
+	  sky2, is provided for these adapters.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called skge.  This is recommended.
@@ -2313,7 +2313,7 @@ config SKGE_GENESIS
 	 by making code smaller. If unsure say Y.
 
 config SKY2
-	tristate "SysKonnect Yukon2 support"
+	tristate "Marvell Yukon 2 support"
 	depends on PCI
 	select CRC32
 	---help---
@@ -2323,7 +2323,7 @@ config SKY2
 	  88E8053/88E8055/88E8061/88E8062, SysKonnect SK-9E21D/SK-9S21
 
 	  There is companion driver for the older Marvell Yukon and
-	  Genesis based adapters: skge.
+	  SysKonnect Genesis based adapters: skge.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called sky2.  This is recommended.


