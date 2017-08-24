From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 3/8] net/mlx5e: Fix wrong code indentation in conditional statement
Date: Thu, 24 Aug 2017 16:21:47 +0300
Message-ID: <20170824132152.29538-4-saeedm@mellanox.com>
References: <20170824132152.29538-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34093 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753045AbdHXNV6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 09:21:58 -0400
In-Reply-To: <20170824132152.29538-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Fix the following checkpatch warning in en_ethtool.c:
WARNING: suspect code indent for conditional statements (8, 9)
+	for (i = 0; i < NUM_PCIE_PERF_STALL_COUNTERS(priv); i++)
+	 strcpy(data + (idx++) * ETH_GSTRING_LEN,

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index c30cf6b4736f..0dd7e9caf150 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -254,8 +254,8 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, u8 *data)
 		       pcie_perf_stats_desc64[i].format);
 
 	for (i = 0; i < NUM_PCIE_PERF_STALL_COUNTERS(priv); i++)
-	 strcpy(data + (idx++) * ETH_GSTRING_LEN,
-		pcie_perf_stall_stats_desc[i].format);
+		strcpy(data + (idx++) * ETH_GSTRING_LEN,
+		       pcie_perf_stall_stats_desc[i].format);
 
 	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
 		for (i = 0; i < NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS; i++)
-- 
2.13.0
