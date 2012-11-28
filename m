From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net] net/mlx4_en: Can set maxrate only for TC0
Date: Wed, 28 Nov 2012 13:43:15 +0200
Message-ID: <1354102995-27305-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:37100 "HELO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754338Ab2K1Ln1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 06:43:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Had a typo in memcpy.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index 5d367958..b799ab12 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -237,7 +237,7 @@ static int mlx4_en_dcbnl_ieee_setmaxrate(struct net_device *dev,
 	if (err)
 		return err;
 
-	memcpy(priv->maxrate, tmp, sizeof(*priv->maxrate));
+	memcpy(priv->maxrate, tmp, sizeof(priv->maxrate));
 
 	return 0;
 }
-- 
1.7.8.2
