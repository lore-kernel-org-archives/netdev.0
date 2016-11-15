From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/5] net: ethoc: Implement ethtool::nway_reset
Date: Tue, 15 Nov 2016 11:19:46 -0800
Message-ID: <20161115191949.15361-3-f.fainelli@gmail.com>
References: <20161115191949.15361-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Tobias Klauser <tklauser@distanz.ch>,
        Colin Ian King <colin.king@canonical.com>,
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
 drivers/net/ethernet/ethoc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index c044667a0a25..6456c180114b 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -966,6 +966,7 @@ static int ethoc_set_ringparam(struct net_device *dev,
 const struct ethtool_ops ethoc_ethtool_ops = {
 	.get_regs_len = ethoc_get_regs_len,
 	.get_regs = ethoc_get_regs,
+	.nway_reset = phy_ethtool_nway_reset,
 	.get_link = ethtool_op_get_link,
 	.get_ringparam = ethoc_get_ringparam,
 	.set_ringparam = ethoc_set_ringparam,
-- 
2.9.3
