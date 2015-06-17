From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 09/12] net/mlx5e: Remove extra spaces
Date: Wed, 17 Jun 2015 18:26:26 +0300
Message-ID: <1434554789-13758-10-git-send-email-ogerlitz@mellanox.com>
References: <1434554789-13758-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53967 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756634AbbFQP1E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 11:27:04 -0400
In-Reply-To: <1434554789-13758-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Coding Style fix, remove extra spaces.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index a45d751..67493ab 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -153,7 +153,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 		sq->stats.tso_packets++;
 		sq->stats.tso_bytes += payload_len;
 	} else {
-		ihs             = mlx5e_get_inline_hdr_size(sq, skb);
+		ihs = mlx5e_get_inline_hdr_size(sq, skb);
 		MLX5E_TX_SKB_CB(skb)->num_bytes = max_t(unsigned int, skb->len,
 							ETH_ZLEN);
 	}
@@ -161,7 +161,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	skb_copy_from_linear_data(skb, eseg->inline_hdr_start, ihs);
 	skb_pull_inline(skb, ihs);
 
-	eseg->inline_hdr_sz	= cpu_to_be16(ihs);
+	eseg->inline_hdr_sz = cpu_to_be16(ihs);
 
 	ds_cnt  = sizeof(*wqe) / MLX5_SEND_WQE_DS;
 	ds_cnt += DIV_ROUND_UP(ihs - sizeof(eseg->inline_hdr_start),
@@ -208,8 +208,8 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 
 	ds_cnt += MLX5E_TX_SKB_CB(skb)->num_dma;
 
-	cseg->opmod_idx_opcode	= cpu_to_be32((sq->pc << 8) | opcode);
-	cseg->qpn_ds		= cpu_to_be32((sq->sqn << 8) | ds_cnt);
+	cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | opcode);
+	cseg->qpn_ds           = cpu_to_be32((sq->sqn << 8) | ds_cnt);
 
 	sq->skb[pi] = skb;
 
-- 
2.3.7
