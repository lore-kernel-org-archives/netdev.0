From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 01/10] net/mlx5e: IPoIB, Move to a separate directory
Date: Tue, 20 Jun 2017 17:13:05 +0300
Message-ID: <20170620141314.25620-2-saeedm@mellanox.com>
References: <20170620141314.25620-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42036 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751174AbdFTONd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 10:13:33 -0400
In-Reply-To: <20170620141314.25620-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPoIB netdevice driver was only introduced in previous kernel release
and it is growing in terms of features and LOC, move it to a separate
directory.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile            | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c             | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c             | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/{ => ipoib}/ipoib.c | 0
 drivers/net/ethernet/mellanox/mlx5/core/{ => ipoib}/ipoib.h | 0
 5 files changed, 3 insertions(+), 3 deletions(-)
 rename drivers/net/ethernet/mellanox/mlx5/core/{ => ipoib}/ipoib.c (100%)
 rename drivers/net/ethernet/mellanox/mlx5/core/{ => ipoib}/ipoib.h (100%)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 12556c03eec4..59b87b30e438 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -15,4 +15,4 @@ mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o eswitch_offloads.o \
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
 
-mlx5_core-$(CONFIG_MLX5_CORE_IPOIB) += ipoib.o
+mlx5_core-$(CONFIG_MLX5_CORE_IPOIB) += ipoib/ipoib.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 66b5fec15313..806139d62139 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -40,7 +40,7 @@
 #include "en_tc.h"
 #include "eswitch.h"
 #include "en_rep.h"
-#include "ipoib.h"
+#include "ipoib/ipoib.h"
 
 static inline bool mlx5e_rx_hw_stamp(struct mlx5e_tstamp *tstamp)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index ef3e1918d8cc..354f474322ce 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -33,7 +33,7 @@
 #include <linux/tcp.h>
 #include <linux/if_vlan.h>
 #include "en.h"
-#include "ipoib.h"
+#include "ipoib/ipoib.h"
 
 #define MLX5E_SQ_NOPS_ROOM  MLX5_SEND_WQE_MAX_WQEBBS
 #define MLX5E_SQ_STOP_ROOM (MLX5_SEND_WQE_MAX_WQEBBS +\
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
similarity index 100%
rename from drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
rename to drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.h b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
similarity index 100%
rename from drivers/net/ethernet/mellanox/mlx5/core/ipoib.h
rename to drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
-- 
2.11.0
