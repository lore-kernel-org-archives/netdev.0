From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 1/2] mlx4_en: Removed redundant stride variable
Date: Sun, 24 May 2009 16:16:51 +0300
Message-ID: <4A1948C3.9050000@mellanox.co.il>
References: <49EC859C.700@mellanox.co.il> <4A0AB34A.10100@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:56852 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750756AbZEXNP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 May 2009 09:15:59 -0400
In-Reply-To: <4A0AB34A.10100@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 7bcc49d..be487fa 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -559,7 +559,6 @@ int mlx4_en_start_port(struct net_device *dev)
 	struct mlx4_en_rx_ring *rx_ring;
 	int rx_index = 0;
 	int tx_index = 0;
-	u16 stride;
 	int err = 0;
 	int i;
 	int j;
@@ -573,8 +572,6 @@ int mlx4_en_start_port(struct net_device *dev)
 	dev->mtu = min(dev->mtu, priv->max_mtu);
 	mlx4_en_calc_rx_buf(dev);
 	mlx4_dbg(DRV, priv, "Rx buf size:%d\n", priv->rx_skb_size);
-	stride = roundup_pow_of_two(sizeof(struct mlx4_en_rx_desc) +
-				    DS_SIZE * priv->num_frags);
 	/* Configure rx cq's and rings */
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		cq = &priv->rx_cq[i];
-- 
1.6.0


