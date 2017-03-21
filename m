From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 6/8] net/mlx5: Increase number of max QPs in default profile
Date: Tue, 21 Mar 2017 15:59:17 +0200
Message-ID: <20170321135919.25018-7-saeedm@mellanox.com>
References: <20170321135919.25018-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Maor Gottlieb <maorg@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38165 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757521AbdCUN7y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 09:59:54 -0400
In-Reply-To: <20170321135919.25018-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

With ConnectX-4 sharing SRQs from the same space as QPs, we hit a
limit preventing some applications to allocate needed QPs amount.
Double the size to 256K.

Fixes: e126ba97dba9e ('mlx5: Add driver for Mellanox Connect-IB adapters')
Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index e2bd600d19de..60154a175bd3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -87,7 +87,7 @@ static struct mlx5_profile profile[] = {
 	[2] = {
 		.mask		= MLX5_PROF_MASK_QP_SIZE |
 				  MLX5_PROF_MASK_MR_CACHE,
-		.log_max_qp	= 17,
+		.log_max_qp	= 18,
 		.mr_cache[0]	= {
 			.size	= 500,
 			.limit	= 250
-- 
2.11.0
