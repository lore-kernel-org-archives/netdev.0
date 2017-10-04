From: Dan Murphy <dmurphy@ti.com>
Subject: [PATCH 1/3 v2] net: phy: Remove TI DP83822 from DP83848 driver
Date: Wed, 4 Oct 2017 13:20:29 -0500
Message-ID: <20171004182031.13794-1-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <afd@ti.com>, Dan Murphy <dmurphy@ti.com>
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:59369 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbdJDSUl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 14:20:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing the DP83822 device from the DP83848 to
support the TI DP83822 dedicated driver that will
initially support WoL settings.

Signed-off-by: Dan Murphy <dmurphy@ti.com>
---

v2 - There was no v1 on this patch this is new.

 drivers/net/phy/dp83848.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
index 3de4fe4dda77..3966d43c5146 100644
--- a/drivers/net/phy/dp83848.c
+++ b/drivers/net/phy/dp83848.c
@@ -20,7 +20,6 @@
 #define TI_DP83620_PHY_ID		0x20005ce0
 #define NS_DP83848C_PHY_ID		0x20005c90
 #define TLK10X_PHY_ID			0x2000a210
-#define TI_DP83822_PHY_ID		0x2000a240
 
 /* Registers */
 #define DP83848_MICR			0x11 /* MII Interrupt Control Register */
@@ -80,7 +79,6 @@ static struct mdio_device_id __maybe_unused dp83848_tbl[] = {
 	{ NS_DP83848C_PHY_ID, 0xfffffff0 },
 	{ TI_DP83620_PHY_ID, 0xfffffff0 },
 	{ TLK10X_PHY_ID, 0xfffffff0 },
-	{ TI_DP83822_PHY_ID, 0xfffffff0 },
 	{ }
 };
 MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
@@ -110,7 +108,6 @@ static struct phy_driver dp83848_driver[] = {
 	DP83848_PHY_DRIVER(NS_DP83848C_PHY_ID, "NS DP83848C 10/100 Mbps PHY"),
 	DP83848_PHY_DRIVER(TI_DP83620_PHY_ID, "TI DP83620 10/100 Mbps PHY"),
 	DP83848_PHY_DRIVER(TLK10X_PHY_ID, "TI TLK10X 10/100 Mbps PHY"),
-	DP83848_PHY_DRIVER(TI_DP83822_PHY_ID, "TI DP83822 10/100 Mbps PHY"),
 };
 module_phy_driver(dp83848_driver);
 
-- 
2.14.0
