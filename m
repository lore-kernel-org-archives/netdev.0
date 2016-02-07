From: "Andrew F. Davis" <afd@ti.com>
Subject: [PATCH v2 2/5] net: phy: dp83848: Add PHY ID for TI version of DP83848C
Date: Sun, 7 Feb 2016 11:47:18 -0600
Message-ID: <1454867241-20928-3-git-send-email-afd@ti.com>
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

After acquiring National Semiconductor, TI appears to have
changed the Vendor Model Number for the DP83848C PHYs,
add this new ID to supported IDs.

Signed-off-by: Andrew F. Davis <afd@ti.com>
---
 drivers/net/phy/dp83848.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
index 4e78f54..d4686d5f 100644
--- a/drivers/net/phy/dp83848.c
+++ b/drivers/net/phy/dp83848.c
@@ -16,7 +16,8 @@
 #include <linux/module.h>
 #include <linux/phy.h>
 
-#define DP83848_PHY_ID			0x20005c90
+#define TI_DP83848C_PHY_ID		0x20005ca0
+#define NS_DP83848C_PHY_ID		0x20005c90
 
 /* Registers */
 #define DP83848_MICR			0x11
@@ -65,7 +66,8 @@ static int dp83848_config_intr(struct phy_device *phydev)
 }
 
 static struct mdio_device_id __maybe_unused dp83848_tbl[] = {
-	{ DP83848_PHY_ID, 0xfffffff0 },
+	{ TI_DP83848C_PHY_ID, 0xfffffff0 },
+	{ NS_DP83848C_PHY_ID, 0xfffffff0 },
 	{ }
 };
 MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
@@ -91,7 +93,8 @@ MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
 	}
 
 static struct phy_driver dp83848_driver[] = {
-	DP83848_PHY_DRIVER(DP83848_PHY_ID, "TI DP83848 10/100 Mbps PHY"),
+	DP83848_PHY_DRIVER(TI_DP83848C_PHY_ID, "TI DP83848C 10/100 Mbps PHY"),
+	DP83848_PHY_DRIVER(NS_DP83848C_PHY_ID, "TI DP83848C 10/100 Mbps PHY"),
 };
 module_phy_driver(dp83848_driver);
 
-- 
2.7.0
