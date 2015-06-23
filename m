From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 05/11] net/mlx5e: Remove re-assignment of wq type in mlx5e_enable_rq()
Date: Tue, 23 Jun 2015 17:14:16 +0300
Message-ID: <1435068862-26488-6-git-send-email-ogerlitz@mellanox.com>
References: <1435068862-26488-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41227 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S934071AbbFWOPE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2015 10:15:04 -0400
In-Reply-To: <1435068862-26488-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

It is already assigned at mlx5e_build_rq_param()

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index f5f5eb9..45dc8c2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -345,7 +345,6 @@ static int mlx5e_enable_rq(struct mlx5e_rq *rq, struct mlx5e_rq_param *param)
 	MLX5_SET(rqc,  rqc, cqn,		c->rq.cq.mcq.cqn);
 	MLX5_SET(rqc,  rqc, state,		MLX5_RQC_STATE_RST);
 	MLX5_SET(rqc,  rqc, flush_in_error_en,	1);
-	MLX5_SET(wq,   wq,  wq_type,		MLX5_WQ_TYPE_LINKED_LIST);
 	MLX5_SET(wq,   wq,  log_wq_pg_sz,	rq->wq_ctrl.buf.page_shift -
 						PAGE_SHIFT);
 	MLX5_SET64(wq, wq,  dbr_addr,		rq->wq_ctrl.db.dma);
-- 
2.3.7
