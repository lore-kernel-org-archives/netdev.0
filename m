From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH] net: phy: dp83848: add dp83822 PHY support
Date: Fri, 28 Oct 2016 12:40:20 +0300
Message-ID: <1477647620-7315-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <afd@ti.com>, <dmurphy@ti.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Roger Quadros <rogerq@ti.com>
To: <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This PHY has a compatible register set with DP83848x so
add support for it.

Acked-by: Andrew F. Davis <afd@ti.com>
Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 drivers/net/phy/dp83848.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
index 03d54c4..800b39f 100644
--- a/drivers/net/phy/dp83848.c
+++ b/drivers/net/phy/dp83848.c
@@ -19,6 +19,7 @@
 #define TI_DP83848C_PHY_ID		0x20005ca0
 #define NS_DP83848C_PHY_ID		0x20005c90
 #define TLK10X_PHY_ID			0x2000a210
+#define TI_DP83822_PHY_ID		0x2000a240
 
 /* Registers */
 #define DP83848_MICR			0x11 /* MII Interrupt Control Register */
@@ -77,6 +78,7 @@ static struct mdio_device_id __maybe_unused dp83848_tbl[] = {
 	{ TI_DP83848C_PHY_ID, 0xfffffff0 },
 	{ NS_DP83848C_PHY_ID, 0xfffffff0 },
 	{ TLK10X_PHY_ID, 0xfffffff0 },
+	{ TI_DP83822_PHY_ID, 0xfffffff0 },
 	{ }
 };
 MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
@@ -105,6 +107,7 @@ static struct phy_driver dp83848_driver[] = {
 	DP83848_PHY_DRIVER(TI_DP83848C_PHY_ID, "TI DP83848C 10/100 Mbps PHY"),
 	DP83848_PHY_DRIVER(NS_DP83848C_PHY_ID, "NS DP83848C 10/100 Mbps PHY"),
 	DP83848_PHY_DRIVER(TLK10X_PHY_ID, "TI TLK10X 10/100 Mbps PHY"),
+	DP83848_PHY_DRIVER(TI_DP83822_PHY_ID, "TI DP83822 10/100 Mbps PHY"),
 };
 module_phy_driver(dp83848_driver);
 
-- 
2.7.4
