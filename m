From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] net/mlx5: use rb_entry()
Date: Tue, 20 Dec 2016 22:02:14 +0800
Message-ID: <8443fa3fa03d82c2b829375d8020762e5236dc6d.1482203930.git.geliangtang@gmail.com>
References: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To make the code clearer, use rb_entry() instead of container_of() to
deal with rbtree.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
index 3b026c1..7431f63 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
@@ -75,7 +75,7 @@ static void mlx5_fc_stats_insert(struct rb_root *root, struct mlx5_fc *counter)
 	struct rb_node *parent = NULL;
 
 	while (*new) {
-		struct mlx5_fc *this = container_of(*new, struct mlx5_fc, node);
+		struct mlx5_fc *this = rb_entry(*new, struct mlx5_fc, node);
 		int result = counter->id - this->id;
 
 		parent = *new;
-- 
2.9.3
