From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/8] net/mlx5_core: Fix struct type in the DESTROY_TIR/TIS device commands
Date: Fri, 25 Sep 2015 10:49:10 +0300
Message-ID: <1443167356-32095-3-git-send-email-ogerlitz@mellanox.com>
References: <1443167356-32095-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, eli@labmailer.mlnx,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39366 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755376AbbIYHuR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 03:50:17 -0400
In-Reply-To: <1443167356-32095-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Used the output mailbox format for input mailbox.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
index b4c87c7..d7068f5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
@@ -177,7 +177,7 @@ int mlx5_core_modify_tir(struct mlx5_core_dev *dev, u32 tirn, u32 *in,
 
 void mlx5_core_destroy_tir(struct mlx5_core_dev *dev, u32 tirn)
 {
-	u32 in[MLX5_ST_SZ_DW(destroy_tir_out)];
+	u32 in[MLX5_ST_SZ_DW(destroy_tir_in)];
 	u32 out[MLX5_ST_SZ_DW(destroy_tir_out)];
 
 	memset(in, 0, sizeof(in));
@@ -206,7 +206,7 @@ int mlx5_core_create_tis(struct mlx5_core_dev *dev, u32 *in, int inlen,
 
 void mlx5_core_destroy_tis(struct mlx5_core_dev *dev, u32 tisn)
 {
-	u32 in[MLX5_ST_SZ_DW(destroy_tis_out)];
+	u32 in[MLX5_ST_SZ_DW(destroy_tis_in)];
 	u32 out[MLX5_ST_SZ_DW(destroy_tis_out)];
 
 	memset(in, 0, sizeof(in));
-- 
2.3.7
