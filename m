From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 01/17] mlx4_en: going out of range of TX rings when reporting
 stats
Date: Mon, 7 Mar 2011 12:16:57 +0200
Message-ID: <4D74B099.8070207@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:42124 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751929Ab1CGOaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 09:30:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_port.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/mlx4/en_port.c
index 7f5a322..a2b0bc4 100644
--- a/drivers/net/mlx4/en_port.c
+++ b/drivers/net/mlx4/en_port.c
@@ -206,7 +206,7 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	}
 	stats->tx_packets = 0;
 	stats->tx_bytes = 0;
-	for (i = 0; i <= priv->tx_ring_num; i++) {
+	for (i = 0; i < priv->tx_ring_num; i++) {
 		stats->tx_packets += priv->tx_ring[i].packets;
 		stats->tx_bytes += priv->tx_ring[i].bytes;
 	}
-- 
1.6.0.2



