From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 09/15] net/mlx5e: Fix typo in warning if CQ moderation is not supported
Date: Fri, 16 Jun 2017 00:42:46 +0300
Message-ID: <20170615214252.30140-10-saeedm@mellanox.com>
References: <20170615214252.30140-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Itay Aveksis <itayav@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32926 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752204AbdFOVnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:43:05 -0400
In-Reply-To: <20170615214252.30140-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Itay Aveksis <itayav@mellanox.com>

Signed-off-by: Itay Aveksis <itayav@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 9dad80f32314..51f686d737cb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3718,7 +3718,7 @@ static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
 	if (!MLX5_CAP_ETH(mdev, self_lb_en_modifiable))
 		mlx5_core_warn(mdev, "Self loop back prevention is not supported\n");
 	if (!MLX5_CAP_GEN(mdev, cq_moderation))
-		mlx5_core_warn(mdev, "CQ modiration is not supported\n");
+		mlx5_core_warn(mdev, "CQ moderation is not supported\n");
 
 	return 0;
 }
-- 
2.11.0
