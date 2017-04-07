From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 3/7] net/mlx5e: Make mlx5e_modify_rqs_vsd a static function
Date: Fri,  7 Apr 2017 21:26:52 +0300
Message-ID: <20170407182656.6734-4-saeedm@mellanox.com>
References: <20170407182656.6734-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Guy Ergas <guye@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47249 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756077AbdDGS1T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 14:27:19 -0400
In-Reply-To: <20170407182656.6734-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guy Ergas <guye@mellanox.com>

Make mlx5e_modify_rqs_vsd a static function and remove from en.h in
order to reduce redundant exposure of functions.

Signed-off-by: Guy Ergas <guye@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 2 --
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 2 +-
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index a58031da7fad..b7feecfbb5a5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -843,8 +843,6 @@ int mlx5e_vlan_rx_kill_vid(struct net_device *dev, __always_unused __be16 proto,
 void mlx5e_enable_vlan_filter(struct mlx5e_priv *priv);
 void mlx5e_disable_vlan_filter(struct mlx5e_priv *priv);
 
-int mlx5e_modify_channels_vsd(struct mlx5e_channels *chs, bool vsd);
-
 struct mlx5e_redirect_rqt_param {
 	bool is_rss;
 	union {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 83796ce17fc3..b57a6e72cc86 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2950,7 +2950,7 @@ static int mlx5e_modify_channels_scatter_fcs(struct mlx5e_channels *chs, bool en
 	return 0;
 }
 
-int mlx5e_modify_channels_vsd(struct mlx5e_channels *chs, bool vsd)
+static int mlx5e_modify_channels_vsd(struct mlx5e_channels *chs, bool vsd)
 {
 	int err = 0;
 	int i;
-- 
2.11.0
