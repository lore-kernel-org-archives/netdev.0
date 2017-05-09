From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 1/3] net/mlx4_en: Change the error print to debug print
Date: Tue,  9 May 2017 14:45:22 +0300
Message-ID: <1494330324-11752-2-git-send-email-tariqt@mellanox.com>
References: <1494330324-11752-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Kamal Heib <kamalh@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49008 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752826AbdEILpu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 07:45:50 -0400
In-Reply-To: <1494330324-11752-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

The error print within mlx4_en_calc_rx_buf() should be a debug print.

Fixes: 51151a16a60f ('mlx4: allow order-0 memory allocations in RX path')
Signed-off-by: Kamal Heib <kamalh@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index aa074e57ce06..77abd1813047 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -997,7 +997,8 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 	en_dbg(DRV, priv, "Rx buffer scatter-list (effective-mtu:%d num_frags:%d):\n",
 	       eff_mtu, priv->num_frags);
 	for (i = 0; i < priv->num_frags; i++) {
-		en_err(priv,
+		en_dbg(DRV,
+		       priv,
 		       "  frag:%d - size:%d stride:%d\n",
 		       i,
 		       priv->frag_info[i].frag_size,
-- 
1.8.3.1
