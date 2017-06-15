From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 05/15] net/mlx5: Align to match opening parenthesis
Date: Fri, 16 Jun 2017 00:42:42 +0300
Message-ID: <20170615214252.30140-6-saeedm@mellanox.com>
References: <20170615214252.30140-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32915 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752099AbdFOVnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:43:05 -0400
In-Reply-To: <20170615214252.30140-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Fixed checkpatch complaints of the form:

 CHECK: Alignment should match open parenthesis

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c              | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c          | 5 +++--
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c            | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c | 2 +-
 4 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index e283095b69c3..c1d8b0bcde75 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -1151,7 +1151,7 @@ static struct mlx5_cmd_msg *mlx5_alloc_cmd_msg(struct mlx5_core_dev *dev,
 }
 
 static void mlx5_free_cmd_msg(struct mlx5_core_dev *dev,
-				  struct mlx5_cmd_msg *msg)
+			      struct mlx5_cmd_msg *msg)
 {
 	struct mlx5_cmd_mailbox *head = msg->next;
 	struct mlx5_cmd_mailbox *next;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index c803a533ec3c..9dad80f32314 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -124,7 +124,8 @@ static void mlx5e_update_carrier(struct mlx5e_priv *priv)
 	u8 port_state;
 
 	port_state = mlx5_query_vport_state(mdev,
-		MLX5_QUERY_VPORT_STATE_IN_OP_MOD_VNIC_VPORT, 0);
+					    MLX5_QUERY_VPORT_STATE_IN_OP_MOD_VNIC_VPORT,
+					    0);
 
 	if (port_state == VPORT_STATE_UP) {
 		netdev_info(priv->netdev, "Link up\n");
@@ -3850,7 +3851,7 @@ void mlx5e_build_nic_params(struct mlx5_core_dev *mdev,
 	/* set CQE compression */
 	params->rx_cqe_compress_def = false;
 	if (MLX5_CAP_GEN(mdev, cqe_compression) &&
-	     MLX5_CAP_GEN(mdev, vport_group_manager))
+	    MLX5_CAP_GEN(mdev, vport_group_manager))
 		params->rx_cqe_compress_def = cqe_compress_heuristic(link_speed, pci_bw);
 
 	MLX5E_SET_PFLAG(params, MLX5E_PFLAG_RX_CQE_COMPRESS, params->rx_cqe_compress_def);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index ab3bb026ff9e..ef3e1918d8cc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -245,7 +245,7 @@ mlx5e_txwqe_build_dsegs(struct mlx5e_txqsq *sq, struct sk_buff *skb,
 		int fsz = skb_frag_size(frag);
 
 		dma_addr = skb_frag_dma_map(sq->pdev, frag, 0, fsz,
-				     DMA_TO_DEVICE);
+					    DMA_TO_DEVICE);
 		if (unlikely(dma_mapping_error(sq->pdev, dma_addr)))
 			return -ENOMEM;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 3795943ef2d1..877395f34e89 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -691,7 +691,7 @@ mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn)
 
 	flow_act.action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
 	flow_rule = mlx5_add_flow_rules(esw->offloads.ft_offloads, spec,
-				       &flow_act, &dest, 1);
+					&flow_act, &dest, 1);
 	if (IS_ERR(flow_rule)) {
 		esw_warn(esw->dev, "fs offloads: Failed to add vport rx rule err %ld\n", PTR_ERR(flow_rule));
 		goto out;
-- 
2.11.0
