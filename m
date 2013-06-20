From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 08/11] net/mlx4_en: Remove an unnecessary test
Date: Thu, 20 Jun 2013 22:40:19 +0300
Message-ID: <1371757222-21412-9-git-send-email-amirv@mellanox.com>
References: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Dotan Barak <dotanb@dev.mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:48208 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030262Ab3FTTkl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 15:40:41 -0400
In-Reply-To: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dotan Barak <dotanb@dev.mellanox.com>

Since this variable is now part of a structure and not allocated dynamically,
this test is irrelevant now.

Signed-off-by: Dotan Barak <dotanb@dev.mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index 0f91222..9d4a1ea 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -207,9 +207,6 @@ static int mlx4_en_dcbnl_ieee_getmaxrate(struct net_device *dev,
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	int i;
 
-	if (!priv->maxrate)
-		return -EINVAL;
-
 	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
 		maxrate->tc_maxrate[i] =
 			priv->maxrate[i] * MLX4_RATELIMIT_UNITS_IN_KB;
-- 
1.8.3.251.g1462b67
