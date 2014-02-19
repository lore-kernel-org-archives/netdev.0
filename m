From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net] net,IB/mlx: Bump all Mellanox driver versions
Date: Wed, 19 Feb 2014 17:47:31 +0200
Message-ID: <1392824851-8667-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Eli Cohen <eli@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:42103 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753595AbaBSPri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 10:47:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bump all Mellanox driver versions.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
Hi,

We're changing the version scheme of our drivers.
I would be happy if it goes to net. Also, added here drivers from rdma tree,
because I would like it to be unified accorss all Mellanox's drivers.

Thanks,
Amir

 drivers/infiniband/hw/mlx4/main.c              | 4 ++--
 drivers/infiniband/hw/mlx5/main.c              | 4 ++--
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      | 4 ++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   | 4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 4 ++--
 5 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index e81c554..f9c12e9 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -53,8 +53,8 @@
 #include "user.h"
 
 #define DRV_NAME	MLX4_IB_DRV_NAME
-#define DRV_VERSION	"1.0"
-#define DRV_RELDATE	"April 4, 2008"
+#define DRV_VERSION	"2.2-1"
+#define DRV_RELDATE	"Feb 2014"
 
 #define MLX4_IB_FLOW_MAX_PRIO 0xFFF
 #define MLX4_IB_FLOW_QPN_MASK 0xFFFFFF
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index aa03e73..bf90057 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -46,8 +46,8 @@
 #include "mlx5_ib.h"
 
 #define DRIVER_NAME "mlx5_ib"
-#define DRIVER_VERSION "1.0"
-#define DRIVER_RELDATE	"June 2013"
+#define DRIVER_VERSION "2.2-1"
+#define DRIVER_RELDATE	"Feb 2014"
 
 MODULE_AUTHOR("Eli Cohen <eli@mellanox.com>");
 MODULE_DESCRIPTION("Mellanox Connect-IB HCA IB driver");
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 6b65f77..7aec6c8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -51,8 +51,8 @@
 
 #define DRV_NAME	"mlx4_core"
 #define PFX		DRV_NAME ": "
-#define DRV_VERSION	"1.1"
-#define DRV_RELDATE	"Dec, 2011"
+#define DRV_VERSION	"2.2-1"
+#define DRV_RELDATE	"Feb, 2014"
 
 #define MLX4_FS_UDP_UC_EN		(1 << 1)
 #define MLX4_FS_TCP_UC_EN		(1 << 2)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 9ca223b..b57e8c8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -57,8 +57,8 @@
 #include "en_port.h"
 
 #define DRV_NAME	"mlx4_en"
-#define DRV_VERSION	"2.0"
-#define DRV_RELDATE	"Dec 2011"
+#define DRV_VERSION	"2.2-1"
+#define DRV_RELDATE	"Feb 2014"
 
 #define MLX4_EN_MSG_LEVEL	(NETIF_MSG_LINK | NETIF_MSG_IFDOWN)
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index a064f06..23b7e2d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -46,8 +46,8 @@
 #include "mlx5_core.h"
 
 #define DRIVER_NAME "mlx5_core"
-#define DRIVER_VERSION "1.0"
-#define DRIVER_RELDATE	"June 2013"
+#define DRIVER_VERSION "2.2-1"
+#define DRIVER_RELDATE	"Feb 2014"
 
 MODULE_AUTHOR("Eli Cohen <eli@mellanox.com>");
 MODULE_DESCRIPTION("Mellanox ConnectX-IB HCA core library");
-- 
1.8.3.4
