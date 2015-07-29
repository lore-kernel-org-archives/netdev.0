From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 4/8] net/mlx5e: Remove redundant assignment of sq->user_index
Date: Wed, 29 Jul 2015 15:05:42 +0300
Message-ID: <1438171546-17021-5-git-send-email-amirv@mellanox.com>
References: <1438171546-17021-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53836 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752300AbbG2MGn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 08:06:43 -0400
In-Reply-To: <1438171546-17021-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

It is not needed by the mlx5 Eth driver since it has a CQ per RQ/SQ.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 48dbed9..ef1480b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -577,7 +577,6 @@ static int mlx5e_enable_sq(struct mlx5e_sq *sq, struct mlx5e_sq_param *param)
 
 	memcpy(sqc, param->sqc, sizeof(param->sqc));
 
-	MLX5_SET(sqc,  sqc, user_index,		sq->tc);
 	MLX5_SET(sqc,  sqc, tis_num_0,		priv->tisn[sq->tc]);
 	MLX5_SET(sqc,  sqc, cqn,		c->sq[sq->tc].cq.mcq.cqn);
 	MLX5_SET(sqc,  sqc, state,		MLX5_SQC_STATE_RST);
-- 
2.4.3.413.ga5fe668
