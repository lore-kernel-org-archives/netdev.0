From: Achiad Shochat <achiad@mellanox.com>
Subject: [PATCH net-next 3/4] net/mlx5_core: Fix struct type in the DESTROY_TIR/TIS device commands
Date: Tue, 25 Aug 2015 15:29:59 +0300
Message-ID: <1440505800-5934-4-git-send-email-achiad@mellanox.com>
References: <1440505800-5934-1-git-send-email-achiad@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54956 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754892AbbHYMcO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 08:32:14 -0400
In-Reply-To: <1440505800-5934-1-git-send-email-achiad@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Used the output mailbox format for input mailbox.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
index 4039c69..b0ae7f7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
@@ -188,7 +188,7 @@ EXPORT_SYMBOL(mlx5_core_modify_tir);
 
 void mlx5_core_destroy_tir(struct mlx5_core_dev *dev, u32 tirn)
 {
-	u32 in[MLX5_ST_SZ_DW(destroy_tir_out)];
+	u32 in[MLX5_ST_SZ_DW(destroy_tir_in)];
 	u32 out[MLX5_ST_SZ_DW(destroy_tir_out)];
 
 	memset(in, 0, sizeof(in));
@@ -219,7 +219,7 @@ EXPORT_SYMBOL(mlx5_core_create_tis);
 
 void mlx5_core_destroy_tis(struct mlx5_core_dev *dev, u32 tisn)
 {
-	u32 in[MLX5_ST_SZ_DW(destroy_tis_out)];
+	u32 in[MLX5_ST_SZ_DW(destroy_tis_in)];
 	u32 out[MLX5_ST_SZ_DW(destroy_tis_out)];
 
 	memset(in, 0, sizeof(in));
-- 
1.8.3.1
