From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next 06/14] net/mlx5: Fix length of async_event_mask
Date: Tue, 25 Oct 2016 18:00:09 +0300
Message-ID: <1477407617-20745-7-git-send-email-saeedm@mellanox.com>
References: <1477407617-20745-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37472 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754569AbcJYPFn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:05:43 -0400
In-Reply-To: <1477407617-20745-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

According to PRM async_event_mask have to be 64 bits long.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index aaca090..e74a73b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -469,7 +469,7 @@ void mlx5_eq_cleanup(struct mlx5_core_dev *dev)
 int mlx5_start_eqs(struct mlx5_core_dev *dev)
 {
 	struct mlx5_eq_table *table = &dev->priv.eq_table;
-	u32 async_event_mask = MLX5_ASYNC_EVENT_MASK;
+	u64 async_event_mask = MLX5_ASYNC_EVENT_MASK;
 	int err;
 
 	if (MLX5_CAP_GEN(dev, pg))
-- 
2.7.4
