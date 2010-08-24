From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 03/14] mlx4_en: Settign dev->perm_addr field
Date: Tue, 24 Aug 2010 16:45:30 +0300
Message-ID: <4C73CCFA.90905@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:50040 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755151Ab0HXNpe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 09:45:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index a0d8a26..c4ab0fc 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -1023,9 +1023,10 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 
 	/* Set defualt MAC */
 	dev->addr_len = ETH_ALEN;
-	for (i = 0; i < ETH_ALEN; i++)
-		dev->dev_addr[ETH_ALEN - 1 - i] =
-		(u8) (priv->mac >> (8 * i));
+	for (i = 0; i < ETH_ALEN; i++) {
+		dev->dev_addr[ETH_ALEN - 1 - i] = (u8) (priv->mac >> (8 * i));
+		dev->perm_addr[ETH_ALEN - 1 - i] = (u8) (priv->mac >> (8 * i));
+	}
 
 	/*
 	 * Set driver features
-- 
1.6.1.3


