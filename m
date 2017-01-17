From: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
Subject: [PATCH] net: phy: dp83848: add DP83620 PHY support
Date: Tue, 17 Jan 2017 09:08:16 +0100
Message-ID: <20170117080816.356-1-alvaro.gamez@hazent.com>
Cc: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32917 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750893AbdAQIRP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 03:17:15 -0500
Received: by mail-wm0-f66.google.com with SMTP id r144so36587756wme.0
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 00:17:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This PHY with fiber support is register compatible with DP83848,
so add support for it.

Signed-off-by: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
---
 drivers/net/phy/dp83848.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
index 800b39f06279..a10d0e7fc5f7 100644
--- a/drivers/net/phy/dp83848.c
+++ b/drivers/net/phy/dp83848.c
@@ -17,6 +17,7 @@
 #include <linux/phy.h>
 
 #define TI_DP83848C_PHY_ID		0x20005ca0
+#define TI_DP83620_PHY_ID		0x20005ce0
 #define NS_DP83848C_PHY_ID		0x20005c90
 #define TLK10X_PHY_ID			0x2000a210
 #define TI_DP83822_PHY_ID		0x2000a240
@@ -77,6 +78,7 @@ static int dp83848_config_intr(struct phy_device *phydev)
 static struct mdio_device_id __maybe_unused dp83848_tbl[] = {
 	{ TI_DP83848C_PHY_ID, 0xfffffff0 },
 	{ NS_DP83848C_PHY_ID, 0xfffffff0 },
+	{ TI_DP83620_PHY_ID, 0xfffffff0 },
 	{ TLK10X_PHY_ID, 0xfffffff0 },
 	{ TI_DP83822_PHY_ID, 0xfffffff0 },
 	{ }
@@ -106,6 +108,7 @@ MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
 static struct phy_driver dp83848_driver[] = {
 	DP83848_PHY_DRIVER(TI_DP83848C_PHY_ID, "TI DP83848C 10/100 Mbps PHY"),
 	DP83848_PHY_DRIVER(NS_DP83848C_PHY_ID, "NS DP83848C 10/100 Mbps PHY"),
+	DP83848_PHY_DRIVER(TI_DP83620_PHY_ID, "TI DP83620 10/100 Mbps PHY"),
 	DP83848_PHY_DRIVER(TLK10X_PHY_ID, "TI TLK10X 10/100 Mbps PHY"),
 	DP83848_PHY_DRIVER(TI_DP83822_PHY_ID, "TI DP83822 10/100 Mbps PHY"),
 };
-- 
2.11.0
