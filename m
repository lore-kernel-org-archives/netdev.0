From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 07/10] net/mlx4_en: Remove an unnecessary test
Date: Tue, 25 Jun 2013 12:09:35 +0300
Message-ID: <1372151378-21468-8-git-send-email-ogerlitz@mellanox.com>
References: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Dotan Barak <dotanb@dev.mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40738 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751923Ab3FYJKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 05:10:25 -0400
In-Reply-To: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dotan Barak <dotanb@dev.mellanox.com>

Since this variable is now part of a structure and not allocated dynamically,
this test is irrelevant now.

Signed-off-by: Dotan Barak <dotanb@dev.mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

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
1.7.1
