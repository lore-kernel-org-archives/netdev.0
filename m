From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/5] net: ethernet: mvpp2: Implement ethtool::nway_reset
Date: Tue, 15 Nov 2016 11:19:48 -0800
Message-ID: <20161115191949.15361-5-f.fainelli@gmail.com>
References: <20161115191949.15361-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Jarod Wilson <jarod@redhat.com>,
        Peter Chen <peter.chen@nxp.com>,
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
 drivers/net/ethernet/marvell/mvpp2.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index c8bf155cad94..ee857868bea5 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5923,6 +5923,7 @@ static const struct net_device_ops mvpp2_netdev_ops = {
 };
 
 static const struct ethtool_ops mvpp2_eth_tool_ops = {
+	.nway_reset	= phy_ethtool_nway_reset,
 	.get_link	= ethtool_op_get_link,
 	.set_coalesce	= mvpp2_ethtool_set_coalesce,
 	.get_coalesce	= mvpp2_ethtool_get_coalesce,
-- 
2.9.3
