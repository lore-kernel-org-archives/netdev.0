From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 13/15] net/mlx5e: Place constants on the right side of comparisons
Date: Thu, 17 Aug 2017 16:30:01 +0300
Message-ID: <20170817133003.16900-14-saeedm@mellanox.com>
References: <20170817133003.16900-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47154 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752642AbdHQNaS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 09:30:18 -0400
In-Reply-To: <20170817133003.16900-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

To fix these checkpatch complaints:

WARNING: Comparisons should place the constant on the right side of the test

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 8e224bcbc6a6..55a6786d3c4c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -509,8 +509,8 @@ static void mlx5e_lro_update_hdr(struct sk_buff *skb, struct mlx5_cqe64 *cqe,
 	u16 tot_len;
 
 	u8 l4_hdr_type = get_cqe_l4_hdr_type(cqe);
-	int tcp_ack = ((CQE_L4_HDR_TYPE_TCP_ACK_NO_DATA  == l4_hdr_type) ||
-		       (CQE_L4_HDR_TYPE_TCP_ACK_AND_DATA == l4_hdr_type));
+	int tcp_ack = ((l4_hdr_type == CQE_L4_HDR_TYPE_TCP_ACK_NO_DATA) ||
+		       (l4_hdr_type == CQE_L4_HDR_TYPE_TCP_ACK_AND_DATA));
 
 	skb->mac_len = ETH_HLEN;
 	proto = __vlan_get_protocol(skb, eth->h_proto, &network_depth);
-- 
2.13.0
