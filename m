From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 03/15] net/mlx5: Avoid using multiple blank lines
Date: Fri, 16 Jun 2017 00:42:40 +0300
Message-ID: <20170615214252.30140-4-saeedm@mellanox.com>
References: <20170615214252.30140-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32914 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752143AbdFOVnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:43:05 -0400
In-Reply-To: <20170615214252.30140-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Fixed bunch of this checkpatch complaint:

 CHECK: Please don't use multiple blank lines

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c     | 1 -
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c       | 2 --
 drivers/net/ethernet/mellanox/mlx5/core/debugfs.c   | 3 ---
 drivers/net/ethernet/mellanox/mlx5/core/en_common.c | 1 -
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c     | 1 -
 drivers/net/ethernet/mellanox/mlx5/core/eq.c        | 2 --
 drivers/net/ethernet/mellanox/mlx5/core/lag.c       | 2 --
 drivers/net/ethernet/mellanox/mlx5/core/main.c      | 1 -
 drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c | 1 -
 drivers/net/ethernet/mellanox/mlx5/core/qp.c        | 1 -
 10 files changed, 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
index 66bd213f35ce..3c95f7f53802 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
@@ -274,7 +274,6 @@ void mlx5_db_free(struct mlx5_core_dev *dev, struct mlx5_db *db)
 }
 EXPORT_SYMBOL_GPL(mlx5_db_free);
 
-
 void mlx5_fill_page_array(struct mlx5_buf *buf, __be64 *pas)
 {
 	u64 addr;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 46efaab9da46..e283095b69c3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -217,7 +217,6 @@ static void free_cmd(struct mlx5_cmd_work_ent *ent)
 	kfree(ent);
 }
 
-
 static int verify_signature(struct mlx5_cmd_work_ent *ent)
 {
 	struct mlx5_cmd_mailbox *next = ent->out->next;
@@ -1001,7 +1000,6 @@ static ssize_t dbg_write(struct file *filp, const char __user *buf,
 	return err ? err : count;
 }
 
-
 static const struct file_operations fops = {
 	.owner	= THIS_MODULE,
 	.open	= simple_open,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c b/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
index de40b6cfee95..7ecadb501743 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
@@ -168,7 +168,6 @@ static ssize_t average_read(struct file *filp, char __user *buf, size_t count,
 	return ret;
 }
 
-
 static ssize_t average_write(struct file *filp, const char __user *buf,
 			     size_t count, loff_t *pos)
 {
@@ -466,7 +465,6 @@ static ssize_t dbg_read(struct file *filp, char __user *buf, size_t count,
 		return -EINVAL;
 	}
 
-
 	if (is_str)
 		ret = snprintf(tbuf, sizeof(tbuf), "%s\n", (const char *)(unsigned long)field);
 	else
@@ -562,7 +560,6 @@ void mlx5_debug_qp_remove(struct mlx5_core_dev *dev, struct mlx5_core_qp *qp)
 		rem_res_tree(qp->dbg);
 }
 
-
 int mlx5_debug_eq_add(struct mlx5_core_dev *dev, struct mlx5_eq *eq)
 {
 	int err;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
index 46e56ec4c26f..ece3fb147e3e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
@@ -145,7 +145,6 @@ int mlx5e_refresh_tirs(struct mlx5e_priv *priv, bool enable_uc_lb)
 	int inlen;
 	void *in;
 
-
 	inlen = MLX5_ST_SZ_BYTES(modify_tir_in);
 	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index 7acc4fba7ece..dfccb5305e9c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -170,7 +170,6 @@ static int __mlx5e_add_vlan_rule(struct mlx5e_priv *priv,
 
 	spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
 
-
 	switch (rule_type) {
 	case MLX5E_VLAN_RULE_TYPE_UNTAGGED:
 		rule_p = &priv->fs.vlan.untagged_rule;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index 23048247d827..43b279b01e07 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -677,7 +677,6 @@ int mlx5_eq_init(struct mlx5_core_dev *dev)
 	return err;
 }
 
-
 void mlx5_eq_cleanup(struct mlx5_core_dev *dev)
 {
 	mlx5_eq_debugfs_cleanup(dev);
@@ -689,7 +688,6 @@ int mlx5_start_eqs(struct mlx5_core_dev *dev)
 	u64 async_event_mask = MLX5_ASYNC_EVENT_MASK;
 	int err;
 
-
 	if (MLX5_CAP_GEN(dev, port_type) == MLX5_CAP_PORT_TYPE_ETH &&
 	    MLX5_CAP_GEN(dev, vport_group_manager) &&
 	    mlx5_core_is_pf(dev))
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/lag.c b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
index b5d5519542e8..b6993c4e4823 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/lag.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
@@ -467,7 +467,6 @@ static void mlx5_lag_dev_remove_pf(struct mlx5_lag *ldev,
 	mutex_unlock(&lag_mutex);
 }
 
-
 /* Must be called with intf_mutex held */
 void mlx5_lag_add(struct mlx5_core_dev *dev, struct net_device *netdev)
 {
@@ -586,4 +585,3 @@ bool mlx5_lag_intf_add(struct mlx5_interface *intf, struct mlx5_priv *priv)
 	/* If bonded, we do not add an IB device for PF1. */
 	return false;
 }
-
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 3319968ed789..39e7e523a0dd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -361,7 +361,6 @@ struct mlx5_reg_host_endianness {
 	u8      rsvd[15];
 };
 
-
 #define CAP_MASK(pos, size) ((u64)((1 << (size)) - 1) << (pos))
 
 enum {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
index efcded7ca27a..e36d3e3675f9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -403,7 +403,6 @@ static int reclaim_pages(struct mlx5_core_dev *dev, u32 func_id, int npages,
 	for (i = 0; i < num_claimed; i++)
 		free_4k(dev, MLX5_GET64(manage_pages_out, out, pas[i]));
 
-
 	if (nclaimed)
 		*nclaimed = num_claimed;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/qp.c b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
index 573a6b27fed8..da0f18f93616 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
@@ -30,7 +30,6 @@
  * SOFTWARE.
  */
 
-
 #include <linux/gfp.h>
 #include <linux/export.h>
 #include <linux/mlx5/cmd.h>
-- 
2.11.0
