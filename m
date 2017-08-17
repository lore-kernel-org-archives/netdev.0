From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 14/15] net/mlx5e: Use kernel types instead of uint*_t in ethtool callbacks
Date: Thu, 17 Aug 2017 16:30:02 +0300
Message-ID: <20170817133003.16900-15-saeedm@mellanox.com>
References: <20170817133003.16900-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47142 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752614AbdHQNaS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 09:30:18 -0400
In-Reply-To: <20170817133003.16900-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Fix checkpatch errors:
CHECK:PREFER_KERNEL_TYPES: Prefer kernel type 'u32' over 'uint32_t'

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c    | 8 +++-----
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c | 3 +--
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index ed161312a773..03b130408359 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -206,7 +206,7 @@ static int mlx5e_get_sset_count(struct net_device *dev, int sset)
 	return mlx5e_ethtool_get_sset_count(priv, sset);
 }
 
-static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, uint8_t *data)
+static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, u8 *data)
 {
 	int i, j, tc, prio, idx = 0;
 	unsigned long pfc_combined;
@@ -308,8 +308,7 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, uint8_t *data)
 					priv->channel_tc2txq[i][tc]);
 }
 
-void mlx5e_ethtool_get_strings(struct mlx5e_priv *priv,
-			       uint32_t stringset, uint8_t *data)
+void mlx5e_ethtool_get_strings(struct mlx5e_priv *priv, u32 stringset, u8 *data)
 {
 	int i;
 
@@ -331,8 +330,7 @@ void mlx5e_ethtool_get_strings(struct mlx5e_priv *priv,
 	}
 }
 
-static void mlx5e_get_strings(struct net_device *dev,
-			      uint32_t stringset, uint8_t *data)
+static void mlx5e_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
index dd49a59854e5..43c126c63955 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
@@ -43,8 +43,7 @@ static void mlx5i_get_drvinfo(struct net_device *dev,
 		sizeof(drvinfo->driver));
 }
 
-static void mlx5i_get_strings(struct net_device *dev,
-			      uint32_t stringset, uint8_t *data)
+static void mlx5i_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 {
 	struct mlx5e_priv *priv  = mlx5i_epriv(dev);
 
-- 
2.13.0
