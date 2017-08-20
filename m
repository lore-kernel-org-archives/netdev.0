From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [V2 net-next 09/15] net/mlx5: Avoid blank lines after/before open/close brace
Date: Sun, 20 Aug 2017 16:49:10 +0300
Message-ID: <20170820134916.10222-10-saeedm@mellanox.com>
References: <20170820134916.10222-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44781 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752937AbdHTNtX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 09:49:23 -0400
In-Reply-To: <20170820134916.10222-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

To fix these checkpatch complaints:

CHECK: Blank lines aren't necessary after an open brace '{'
CHECK: Blank lines aren't necessary before a close brace '}'

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 1 -
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c      | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index d453a11f41fe..a75ac4d11c5b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -176,7 +176,6 @@ static bool mlx5e_query_global_pause_combined(struct mlx5e_priv *priv)
 
 int mlx5e_ethtool_get_sset_count(struct mlx5e_priv *priv, int sset)
 {
-
 	switch (sset) {
 	case ETH_SS_STATS:
 		return NUM_SW_COUNTERS +
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
index 5e7ffc9fad78..55b07c5ecd12 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
@@ -71,7 +71,6 @@ static int mlx5_device_enable_sriov(struct mlx5_core_dev *dev, int num_vfs)
 		sriov->vfs_ctx[vf].enabled = 1;
 		sriov->enabled_vfs++;
 		mlx5_core_dbg(dev, "successfully enabled VF* %d\n", vf);
-
 	}
 
 	return 0;
-- 
2.13.0
