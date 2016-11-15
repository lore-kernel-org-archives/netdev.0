From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/5] net: ethernet: marvell: pxa168_eth: Implement ethtool::nway_reset
Date: Tue, 15 Nov 2016 11:19:49 -0800
Message-ID: <20161115191949.15361-6-f.fainelli@gmail.com>
References: <20161115191949.15361-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Peter Chen <peter.chen@nxp.com>,
        Jarod Wilson <jarod@redhat.com>,
        Florian Westphal <fw@strlen.de>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115191949.15361-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement ethtool::nway_reset using phy_ethtool_nway_reset. We are
already using dev->phydev all over the place so this comes for free.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index b78a838f306c..3af2814ada23 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1393,6 +1393,7 @@ static void pxa168_get_drvinfo(struct net_device *dev,
 
 static const struct ethtool_ops pxa168_ethtool_ops = {
 	.get_drvinfo	= pxa168_get_drvinfo,
+	.nway_reset	= phy_ethtool_nway_reset,
 	.get_link	= ethtool_op_get_link,
 	.get_ts_info	= ethtool_op_get_ts_info,
 	.get_link_ksettings = pxa168_get_link_ksettings,
-- 
2.9.3
