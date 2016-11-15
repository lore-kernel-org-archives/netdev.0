From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/5] net: stmmac: Implement ethtool::nway_reset
Date: Tue, 15 Nov 2016 11:19:45 -0800
Message-ID: <20161115191949.15361-2-f.fainelli@gmail.com>
References: <20161115191949.15361-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115191949.15361-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Utilize the generic phy_ethtool_nway_reset() helper function to
implement an autonegotiation restart.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 3fe9340b748f..0290d52330da 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -870,6 +870,7 @@ static const struct ethtool_ops stmmac_ethtool_ops = {
 	.get_regs = stmmac_ethtool_gregs,
 	.get_regs_len = stmmac_ethtool_get_regs_len,
 	.get_link = ethtool_op_get_link,
+	.nway_reset = phy_ethtool_nway_reset,
 	.get_pauseparam = stmmac_get_pauseparam,
 	.set_pauseparam = stmmac_set_pauseparam,
 	.get_ethtool_stats = stmmac_get_ethtool_stats,
-- 
2.9.3
