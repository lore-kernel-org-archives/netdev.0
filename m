From: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 1/3] net/mlx4_core: Bump driver version
Date: Wed,  7 Jun 2017 16:26:13 +0300
Message-ID: <1496841975-7728-2-git-send-email-tariqt@mellanox.com>
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

Remove date and bump version for mlx4_core driver.

Signed-off-by: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 83aab1e4c8c8..ccae3c6593c4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -119,7 +119,7 @@
 
 static char mlx4_version[] =
 	DRV_NAME ": Mellanox ConnectX core driver v"
-	DRV_VERSION " (" DRV_RELDATE ")\n";
+	DRV_VERSION "\n";
 
 static struct mlx4_profile default_profile = {
 	.num_qp		= 1 << 18,
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index b4f1bc56cc68..6ea2b7a0c34d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -56,8 +56,7 @@
 
 #define DRV_NAME	"mlx4_core"
 #define PFX		DRV_NAME ": "
-#define DRV_VERSION	"2.2-1"
-#define DRV_RELDATE	"Feb, 2014"
+#define DRV_VERSION	"4.0-0"
 
 #define MLX4_FS_UDP_UC_EN		(1 << 1)
 #define MLX4_FS_TCP_UC_EN		(1 << 2)
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
