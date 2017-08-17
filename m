From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 10/15] net/mlx5: Add a blank line after declarations
Date: Thu, 17 Aug 2017 16:29:58 +0300
Message-ID: <20170817133003.16900-11-saeedm@mellanox.com>
References: <20170817133003.16900-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47155 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752644AbdHQNaS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 09:30:18 -0400
In-Reply-To: <20170817133003.16900-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

To fix these checkpatch complaints:

WARNING: Missing a blank line after declarations

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/eq.c    | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
index 3c95f7f53802..47239bf7bf43 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
@@ -258,6 +258,7 @@ EXPORT_SYMBOL_GPL(mlx5_db_alloc);
 void mlx5_db_free(struct mlx5_core_dev *dev, struct mlx5_db *db)
 {
 	u32 db_per_page = PAGE_SIZE / cache_line_size();
+
 	mutex_lock(&dev->priv.pgdir_mutex);
 
 	__set_bit(db->index, db->u.pgdir->bitmap);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index de704ff5619a..a08027b8f3ce 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -188,6 +188,7 @@ static enum mlx5_dev_event port_subtype_event(u8 subtype)
 static void eq_update_ci(struct mlx5_eq *eq, int arm)
 {
 	__be32 __iomem *addr = eq->doorbell + (arm ? 0 : 2);
+
 	u32 val = (eq->cons_index & 0xffffff) | (eq->eqn << 24);
 	__raw_writel((__force u32)cpu_to_be32(val), addr);
 	/* We still want ordering, just not swabbing, so add a barrier */
-- 
2.13.0
