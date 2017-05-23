From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next 5/6] net/mlx5: Bump driver version
Date: Tue, 23 May 2017 14:44:03 +0300
Message-ID: <20170523114404.20387-6-saeedm@mellanox.com>
References: <20170523114404.20387-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Ilan Tayari <ilant@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51033 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1761588AbdEWLoK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 07:44:10 -0400
In-Reply-To: <20170523114404.20387-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Remove date and bump version for mlx5_core driver.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h  | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index e0dd1048c966..afa89dcf30a5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -39,7 +39,7 @@ static void mlx5e_get_drvinfo(struct net_device *dev,
 	struct mlx5_core_dev *mdev = priv->mdev;
 
 	strlcpy(drvinfo->driver, DRIVER_NAME, sizeof(drvinfo->driver));
-	strlcpy(drvinfo->version, DRIVER_VERSION " (" DRIVER_RELDATE ")",
+	strlcpy(drvinfo->version, DRIVER_VERSION,
 		sizeof(drvinfo->version));
 	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
 		 "%d.%d.%04d (%.16s)",
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index fbc6e9e9e305..cf69b42278df 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -39,8 +39,7 @@
 #include <linux/if_link.h>
 
 #define DRIVER_NAME "mlx5_core"
-#define DRIVER_VERSION "3.0-1"
-#define DRIVER_RELDATE  "January 2015"
+#define DRIVER_VERSION "5.0-0"
 
 #define MLX5_TOTAL_VPORTS(mdev) (1 + pci_sriov_get_totalvfs(mdev->pdev))
 
-- 
2.11.0
