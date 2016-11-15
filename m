From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 07/15] net: ethernet: ll_temac: Utilize phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 10:06:36 -0800
Message-ID: <20161115180644.3941-8-f.fainelli@gmail.com>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Michal Simek <michal.simek@xilinx.com>,
        =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
        Florian Westphal <fw@strlen.de>,
        Felipe Balbi <felipe.balbi@linux.intel.com>,
        linux-arm-kernel@lists.infradead.org (moderated list:ARM/ZYNQ
        ARCHITECTURE), linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115180644.3941-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index a9bd665fd122..bcd7b76dde9f 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -967,13 +967,8 @@ static const struct attribute_group temac_attr_group = {
 };
 
 /* ethtool support */
-static int temac_nway_reset(struct net_device *ndev)
-{
-	return phy_start_aneg(ndev->phydev);
-}
-
 static const struct ethtool_ops temac_ethtool_ops = {
-	.nway_reset = temac_nway_reset,
+	.nway_reset = phy_ethtool_nway_reset,
 	.get_link = ethtool_op_get_link,
 	.get_ts_info = ethtool_op_get_ts_info,
 	.get_link_ksettings = phy_ethtool_get_link_ksettings,
-- 
2.9.3
