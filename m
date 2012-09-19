From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH v2 4/9] net/macb: remove macb_get_drvinfo()
Date: Wed, 19 Sep 2012 13:55:17 +0200
Message-ID: <3fbd9b0eb1e255eccd14ad43044e146776baa963.1348055112.git.nicolas.ferre@atmel.com>
References: <cover.1348055112.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bhutchings@solarflare.com>,
	<linux-arm-kernel@lists.infradead.org>, <plagnioj@jcrosoft.com>,
	<patrice.vilchez@atmel.com>, <linux-kernel@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<havard@skinnemoen.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1348055112.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This function has little meaning so remove it altogether and
let ethtool core fill in the fields automatically.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 2948553..31f945c 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1217,20 +1217,9 @@ static int macb_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	return phy_ethtool_sset(phydev, cmd);
 }
 
-static void macb_get_drvinfo(struct net_device *dev,
-			     struct ethtool_drvinfo *info)
-{
-	struct macb *bp = netdev_priv(dev);
-
-	strcpy(info->driver, bp->pdev->dev.driver->name);
-	strcpy(info->version, "$Revision: 1.14 $");
-	strcpy(info->bus_info, dev_name(&bp->pdev->dev));
-}
-
 static const struct ethtool_ops macb_ethtool_ops = {
 	.get_settings		= macb_get_settings,
 	.set_settings		= macb_set_settings,
-	.get_drvinfo		= macb_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 };
 
-- 
1.7.11.3
