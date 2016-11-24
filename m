From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] net/mlx5: drop duplicate header delay.h
Date: Thu, 24 Nov 2016 21:58:33 +0800
Message-ID: <03d5a2a0f03458cdb4f2b139cfabc11b5c334f95.1479990943.git.geliangtang@gmail.com>
References: <15299de49216a2360976ca37ff774cae9d27d88b.1479991297.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <15299de49216a2360976ca37ff774cae9d27d88b.1479991297.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drop duplicate header delay.h from mlx5/core/main.c.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index f28df33..d7a55eb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -46,7 +46,6 @@
 #include <linux/mlx5/srq.h>
 #include <linux/debugfs.h>
 #include <linux/kmod.h>
-#include <linux/delay.h>
 #include <linux/mlx5/mlx5_ifc.h>
 #ifdef CONFIG_RFS_ACCEL
 #include <linux/cpu_rmap.h>
-- 
2.9.3
