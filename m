From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 07/11] net/mlx4_core: Remove duplicate code line from procedure mlx4_bf_alloc
Date: Tue, 27 Jan 2015 15:58:05 +0200
Message-ID: <1422367089-13419-8-git-send-email-amirv@mellanox.com>
References: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46370 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758059AbbA0N7S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 08:59:18 -0500
In-Reply-To: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

mlx4_bf_alloc had an unnecessary/duplicate code line. Did no harm,
but not good practice.

Reported by the Mellanox Beijing team.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/pd.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/pd.c b/drivers/net/ethernet/mellanox/mlx4/pd.c
index a42b4c0..609c59d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/pd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/pd.c
@@ -214,7 +214,6 @@ int mlx4_bf_alloc(struct mlx4_dev *dev, struct mlx4_bf *bf, int node)
 		list_add(&uar->bf_list, &priv->bf_list);
 	}
 
-	bf->uar = uar;
 	idx = ffz(uar->free_bf_bmap);
 	uar->free_bf_bmap |= 1 << idx;
 	bf->uar = uar;
-- 
1.9.3
