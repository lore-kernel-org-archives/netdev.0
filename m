From: <Bryan.Whitehead@microchip.com>
Subject: [PATCH net-next 2/3] Add LAN743X to Kconfig and Makefile
Date: Fri, 11 Aug 2017 19:48:00 +0000
Message-ID: <90A7E81AE28BAE4CBDDB3B35F187D264406F6049@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa6.microchip.iphmx.com ([216.71.154.253]:18454 "EHLO
        esa6.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753647AbdHKTsR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 15:48:17 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bryan Whitehead <Bryan.Whitehead@microchip.com>

Add LAN743X Driver to Kconfig and Makefile

Removed "depends on SPI" from NET_VENDOR_MICROCHIP group
Because all existing drivers already specify SPI dependency, and
New driver does not have SPI dependency.

Signed-off-by: Bryan Whitehead <Bryan.Whitehead@microchip.com>
---
 drivers/net/ethernet/microchip/Kconfig  | 10 +++++++++-
 drivers/net/ethernet/microchip/Makefile |  1 +
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/microchip/Kconfig b/drivers/net/ethernet/microchip/Kconfig
index 36a09d9..5796718 100644
--- a/drivers/net/ethernet/microchip/Kconfig
+++ b/drivers/net/ethernet/microchip/Kconfig
@@ -5,7 +5,6 @@
 config NET_VENDOR_MICROCHIP
 	bool "Microchip devices"
 	default y
-	depends on SPI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
 
@@ -42,4 +41,13 @@ config ENCX24J600
       To compile this driver as a module, choose M here. The module will be
       called encx24j600.
 
+config LAN743X
+	tristate "LAN7430 support"
+	depends on PCI
+	---help---
+	  Support for the Microchip LAN7430 PCI Express Gigabit Ethernet chip
+
+	  To compile this driver as a module, choose M here. The module will be
+	  called lan743x.
+
 endif # NET_VENDOR_MICROCHIP
diff --git a/drivers/net/ethernet/microchip/Makefile b/drivers/net/ethernet/microchip/Makefile
index ff78f62..f7215dd 100644
--- a/drivers/net/ethernet/microchip/Makefile
+++ b/drivers/net/ethernet/microchip/Makefile
@@ -4,3 +4,4 @@
 
 obj-$(CONFIG_ENC28J60) += enc28j60.o
 obj-$(CONFIG_ENCX24J600) += encx24j600.o encx24j600-regmap.o
+obj-$(CONFIG_LAN743X) += lan743x.o
-- 
2.7.4
