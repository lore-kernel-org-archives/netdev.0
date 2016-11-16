From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 3/3] net: marvell: Allow drivers to be built with COMPILE_TEST
Date: Tue, 15 Nov 2016 16:40:37 -0800
Message-ID: <20161116004037.20941-6-f.fainelli@gmail.com>
References: <20161116004037.20941-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, mw@semihalf.com, arnd@arndb.de,
        gregory.clement@free-electrons.com, Shaohui.Xie@freescale.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34679 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752213AbcKPAkv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 19:40:51 -0500
Received: by mail-pf0-f194.google.com with SMTP id y68so8730222pfb.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 16:40:51 -0800 (PST)
In-Reply-To: <20161116004037.20941-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All Marvell Ethernet drivers actually build fine with COMPILE_TEST with
a few warnings.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/Kconfig | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index 2664827ddecd..1fbe0bfbeead 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_MARVELL
 	bool "Marvell devices"
 	default y
-	depends on PCI || CPU_PXA168 || MV64X60 || PPC32 || PLAT_ORION || INET
+	depends on PCI || CPU_PXA168 || MV64X60 || PPC32 || PLAT_ORION || INET || COMPILE_TEST
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
 
@@ -18,7 +18,7 @@ if NET_VENDOR_MARVELL
 
 config MV643XX_ETH
 	tristate "Marvell Discovery (643XX) and Orion ethernet support"
-	depends on (MV64X60 || PPC32 || PLAT_ORION) && INET
+	depends on (MV64X60 || PPC32 || PLAT_ORION || COMPILE_TEST) && INET
 	select PHYLIB
 	select MVMDIO
 	---help---
@@ -55,7 +55,7 @@ config MVNETA_BM_ENABLE
 
 config MVNETA
 	tristate "Marvell Armada 370/38x/XP network interface support"
-	depends on PLAT_ORION
+	depends on PLAT_ORION || COMPILE_TEST
 	select MVMDIO
 	select FIXED_PHY
 	---help---
@@ -77,7 +77,7 @@ config MVNETA_BM
 
 config MVPP2
 	tristate "Marvell Armada 375 network interface support"
-	depends on MACH_ARMADA_375
+	depends on MACH_ARMADA_375 || COMPILE_TEST
 	select MVMDIO
 	---help---
 	  This driver supports the network interface units in the
-- 
2.9.3
