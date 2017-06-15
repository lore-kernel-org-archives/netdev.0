From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 04/15] net/mlx5: Avoid blank lines before/after closing/opening braces
Date: Fri, 16 Jun 2017 00:42:41 +0300
Message-ID: <20170615214252.30140-5-saeedm@mellanox.com>
References: <20170615214252.30140-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32947 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752316AbdFOVnG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:43:06 -0400
In-Reply-To: <20170615214252.30140-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Fixed checkpatch complaints on that:

 CHECK: Blank lines aren't necessary before a close brace '}'
 CHECK: Blank lines aren't necessary after an open brace '{'

and one on missing blank line..

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 1 -
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  | 1 -
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 1 -
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 2 +-
 4 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 5afec0f4a658..c803a533ec3c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3067,7 +3067,6 @@ mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	 */
 	stats->multicast =
 		VPORT_COUNTER_GET(vstats, received_eth_multicast.packets);
-
 }
 
 static void mlx5e_set_rx_mode(struct net_device *dev)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 70c2b8d020bd..01798e1ab667 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -1019,7 +1019,6 @@ mlx5e_vport_rep_load(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
 	mlx5e_destroy_netdev(netdev_priv(netdev));
 	kfree(rpriv);
 	return err;
-
 }
 
 static void
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 37927156f258..89bfda419efe 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1217,7 +1217,6 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 			       "vport[%d] configure ingress rules failed, illegal mac with spoofchk\n",
 			       vport->vport);
 		return -EPERM;
-
 	}
 
 	esw_vport_cleanup_ingress_rules(esw, vport);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 6380c2db355a..e8690fe46bf2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -104,6 +104,7 @@ struct node_caps {
 	size_t	arr_sz;
 	long	*caps;
 };
+
 static struct init_tree_node {
 	enum fs_node_type	type;
 	struct init_tree_node *children;
@@ -1858,7 +1859,6 @@ static int create_anchor_flow_table(struct mlx5_flow_steering *steering)
 
 static int init_root_ns(struct mlx5_flow_steering *steering)
 {
-
 	steering->root_ns = create_root_ns(steering, FS_FT_NIC_RX);
 	if (!steering->root_ns)
 		goto cleanup;
-- 
2.11.0
