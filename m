From: "Andrew F. Davis" <afd@ti.com>
Subject: [PATCH v2 4/5] net: phy: dp83848: Add support for TI TLK10x Ethernet PHYs
Date: Sun, 7 Feb 2016 11:47:20 -0600
Message-ID: <1454867241-20928-5-git-send-email-afd@ti.com>
References: <1454867241-20928-1-git-send-email-afd@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"Andrew F. Davis" <afd@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454867241-20928-1-git-send-email-afd@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TI TLK10x Ethernet PHYs are similar in the interrupt relevant
registers and so are compatible with the DP83848x devices already
supported.

Signed-off-by: Andrew F. Davis <afd@ti.com>
---
 drivers/net/phy/dp83848.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
index 20d3b9d..f897989 100644
--- a/drivers/net/phy/dp83848.c
+++ b/drivers/net/phy/dp83848.c
@@ -18,6 +18,7 @@
 
 #define TI_DP83848C_PHY_ID		0x20005ca0
 #define NS_DP83848C_PHY_ID		0x20005c90
+#define TLK10X_PHY_ID			0x2000a210
 
 /* Registers */
 #define DP83848_MICR			0x11
@@ -75,6 +76,7 @@ static int dp83848_config_intr(struct phy_device *phydev)
 static struct mdio_device_id __maybe_unused dp83848_tbl[] = {
 	{ TI_DP83848C_PHY_ID, 0xfffffff0 },
 	{ NS_DP83848C_PHY_ID, 0xfffffff0 },
+	{ TLK10X_PHY_ID, 0xfffffff0 },
 	{ }
 };
 MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
@@ -102,6 +104,7 @@ MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
 static struct phy_driver dp83848_driver[] = {
 	DP83848_PHY_DRIVER(TI_DP83848C_PHY_ID, "TI DP83848C 10/100 Mbps PHY"),
 	DP83848_PHY_DRIVER(NS_DP83848C_PHY_ID, "TI DP83848C 10/100 Mbps PHY"),
+	DP83848_PHY_DRIVER(TLK10X_PHY_ID, "TI TLK10X 10/100 Mbps PHY"),
 };
 module_phy_driver(dp83848_driver);
 
-- 
2.7.0
