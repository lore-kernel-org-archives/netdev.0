From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH] net: mvneta: make mvneta_eth_tool_ops static
Date: Thu, 16 Feb 2017 17:07:39 +0800
Message-ID: <20170216090739.2632-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Jisheng Zhang <jszhang@marvell.com>
To: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mvneta_eth_tool_ops is only used internally in mvneta driver, so
make it static.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index fdf71720e707..61dd4462411c 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3959,7 +3959,7 @@ static const struct net_device_ops mvneta_netdev_ops = {
 	.ndo_do_ioctl        = mvneta_ioctl,
 };
 
-const struct ethtool_ops mvneta_eth_tool_ops = {
+static const struct ethtool_ops mvneta_eth_tool_ops = {
 	.nway_reset	= phy_ethtool_nway_reset,
 	.get_link       = ethtool_op_get_link,
 	.set_coalesce   = mvneta_ethtool_set_coalesce,
-- 
2.11.0
