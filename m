From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 6/6] net/macb: convert to kernel doc
Date: Fri, 24 Jul 2015 21:24:04 +0300
Message-ID: <1437762244-2678-7-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1437762244-2678-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45091 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754370AbbGXSYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jul 2015 14:24:09 -0400
In-Reply-To: <1437762244-2678-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch coverts struct description to the kernel doc format. There is no
functional change.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 include/linux/platform_data/macb.h | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/include/linux/platform_data/macb.h b/include/linux/platform_data/macb.h
index 044a124..21b15f6 100644
--- a/include/linux/platform_data/macb.h
+++ b/include/linux/platform_data/macb.h
@@ -8,11 +8,19 @@
 #ifndef __MACB_PDATA_H__
 #define __MACB_PDATA_H__
 
+/**
+ * struct macb_platform_data - platform data for MACB Ethernet
+ * @phy_mask:		phy mask passed when register the MDIO bus
+ *			within the driver
+ * @phy_irq_pin:	PHY IRQ
+ * @is_rmii:		using RMII interface?
+ * @rev_eth_addr:	reverse Ethernet address byte order
+ */
 struct macb_platform_data {
 	u32		phy_mask;
-	int		phy_irq_pin;	/* PHY IRQ */
-	u8		is_rmii;	/* using RMII interface? */
-	u8		rev_eth_addr;	/* reverse Ethernet address byte order */
+	int		phy_irq_pin;
+	u8		is_rmii;
+	u8		rev_eth_addr;
 };
 
 #endif /* __MACB_PDATA_H__ */
-- 
2.4.6
