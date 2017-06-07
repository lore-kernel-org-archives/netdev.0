From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 2/3] net/mlx4_en: Bump driver version
Date: Wed,  7 Jun 2017 16:26:14 +0300
Message-ID: <1496841975-7728-3-git-send-email-tariqt@mellanox.com>
References: <1496841975-7728-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54947 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751522AbdFGN0y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 09:26:54 -0400
In-Reply-To: <1496841975-7728-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove date and bump version for mlx4_en driver.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 2 +-
 drivers/net/ethernet/mellanox/mlx4/en_main.c    | 4 ++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    | 3 +--
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index ffbcb27c05e5..e97fbf327594 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -89,7 +89,7 @@ static int mlx4_en_moderation_update(struct mlx4_en_priv *priv)
 	struct mlx4_en_dev *mdev = priv->mdev;
 
 	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
-	strlcpy(drvinfo->version, DRV_VERSION " (" DRV_RELDATE ")",
+	strlcpy(drvinfo->version, DRV_VERSION,
 		sizeof(drvinfo->version));
 	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
 		"%d.%d.%d",
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index 36a7a54bbb82..d94f981eafc4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -46,11 +46,11 @@
 MODULE_AUTHOR("Liran Liss, Yevgeny Petrilin");
 MODULE_DESCRIPTION("Mellanox ConnectX HCA Ethernet driver");
 MODULE_LICENSE("Dual BSD/GPL");
-MODULE_VERSION(DRV_VERSION " ("DRV_RELDATE")");
+MODULE_VERSION(DRV_VERSION);
 
 static const char mlx4_en_version[] =
 	DRV_NAME ": Mellanox ConnectX HCA Ethernet driver v"
-	DRV_VERSION " (" DRV_RELDATE ")\n";
+	DRV_VERSION "\n";
 
 #define MLX4_EN_PARM_INT(X, def_val, desc) \
 	static unsigned int X = def_val;\
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 39f401aa3047..8c4f63946b14 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -58,8 +58,7 @@
 #include "mlx4_stats.h"
 
 #define DRV_NAME	"mlx4_en"
-#define DRV_VERSION	"2.2-1"
-#define DRV_RELDATE	"Feb 2014"
+#define DRV_VERSION	"4.0-0"
 
 #define MLX4_EN_MSG_LEVEL	(NETIF_MSG_LINK | NETIF_MSG_IFDOWN)
 
-- 
1.8.3.1
