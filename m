From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [V2 net-next 15/15] net/mlx5e: Use size_t to store byte offset in statistics descriptors
Date: Sun, 20 Aug 2017 16:49:16 +0300
Message-ID: <20170820134916.10222-16-saeedm@mellanox.com>
References: <20170820134916.10222-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44798 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752928AbdHTNtX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 09:49:23 -0400
In-Reply-To: <20170820134916.10222-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

The byte offset of counter descriptors should be stored in size_t variable
instead of an integer.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 40b5c73e5e26..6761796e803c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -47,7 +47,7 @@
 
 struct counter_desc {
 	char		format[ETH_GSTRING_LEN];
-	int		offset; /* Byte offset */
+	size_t		offset; /* Byte offset */
 };
 
 struct mlx5e_sw_stats {
-- 
2.13.0
