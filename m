From: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 3/3] IB/mlx4: Bump driver version
Date: Wed,  7 Jun 2017 16:26:15 +0300
Message-ID: <1496841975-7728-4-git-send-email-tariqt@mellanox.com>
References: <1496841975-7728-1-git-send-email-tariqt@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Eran Ben Elisha <eranbe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1496841975-7728-1-git-send-email-tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Remove date and bump version for mlx4_ib driver.

Signed-off-by: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/mlx4/main.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 521d0def2d9e..75b2f7d4cd95 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -61,8 +61,7 @@
 #include <rdma/mlx4-abi.h>
 
 #define DRV_NAME	MLX4_IB_DRV_NAME
-#define DRV_VERSION	"2.2-1"
-#define DRV_RELDATE	"Feb 2014"
+#define DRV_VERSION	"4.0-0"
 
 #define MLX4_IB_FLOW_MAX_PRIO 0xFFF
 #define MLX4_IB_FLOW_QPN_MASK 0xFFFFFF
@@ -79,7 +78,7 @@
 
 static const char mlx4_ib_version[] =
 	DRV_NAME ": Mellanox ConnectX InfiniBand driver v"
-	DRV_VERSION " (" DRV_RELDATE ")\n";
+	DRV_VERSION "\n";
 
 static void do_slave_init(struct mlx4_ib_dev *ibdev, int slave, int do_init);
 
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
