From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: [PATCH 2.6.33 2/4] net: Kconfig change for KSZ884X driver
Date: Thu, 4 Feb 2010 15:24:36 -0800
Message-ID: <14385191E87B904DBD836449AA30269D021A53@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@micrel.com>

Add Micrel KSZ8841/KSZ8842 PCI Ethernet chip support.

Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>
---
This is a resubmission of the Micrel KSZ8841/2 PCI Ethernet driver.

--- linux-2.6.33-rc5.old/drivers/net/Kconfig	2010-01-21 15:31:35.000000000 -0800
+++ linux-2.6.33-rc5.new/drivers/net/Kconfig	2010-02-04 12:12:58.000000000 -0800
@@ -1368,6 +1368,17 @@ config AC3200
 	  To compile this driver as a module, choose M here. The module
 	  will be called ac3200.
 
+config KSZ884X_PCI
+	tristate "Micrel KSZ8841/2 PCI"
+	depends on NET_PCI && PCI
+	select MII
+	select CRC32
+	help
+	  This PCI driver is for Micrel KSZ8841/KSZ8842 PCI Ethernet chip.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ksz884x.
+
 config APRICOT
 	tristate "Apricot Xen-II on board Ethernet"
 	depends on NET_PCI && ISA
