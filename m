From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] net/mlx5e: make mlx5e_profile const
Date: Wed, 23 Aug 2017 18:22:01 +0530
Message-ID: <1503492721-3187-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, saeedm@mellanox.com, matanb@mellanox.com,
        leonro@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make this const as it is only passed as an argument to the function
mlx5e_create_netdev and the corresponding argument is of type const.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 45c088c..45e03c4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -924,7 +924,7 @@ static int mlx5e_get_rep_max_num_channels(struct mlx5_core_dev *mdev)
 	return MLX5E_PORT_REPRESENTOR_NCH;
 }
 
-static struct mlx5e_profile mlx5e_rep_profile = {
+static const struct mlx5e_profile mlx5e_rep_profile = {
 	.init			= mlx5e_init_rep,
 	.init_rx		= mlx5e_init_rep_rx,
 	.cleanup_rx		= mlx5e_cleanup_rep_rx,
-- 
1.9.1
