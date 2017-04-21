From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/3] mlx5: fix warning about missing prototype
Date: Fri, 21 Apr 2017 11:15:57 -0700
Message-ID: <20170421181558.5414-3-sthemmin@microsoft.com>
References: <20170421181558.5414-1-sthemmin@microsoft.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net, saeedm@mellanox.com, matanb@mellanox.com,
        leonro@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f181.google.com ([209.85.213.181]:35625 "EHLO
        mail-yb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162349AbdDUSYT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:24:19 -0400
Received: by mail-yb0-f181.google.com with SMTP id 6so47033211ybq.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:24:19 -0700 (PDT)
In-Reply-To: <20170421181558.5414-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix sparse warning about missing prototypes. The rx/tx code path
defines functions with prototypes in ipoib.h.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 43308243f519..ae66fad98244 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -39,6 +39,7 @@
 #include "en.h"
 #include "en_tc.h"
 #include "eswitch.h"
+#include "ipoib.h"
 
 static inline bool mlx5e_rx_hw_stamp(struct mlx5e_tstamp *tstamp)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index dda7db503043..ab3bb026ff9e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -33,6 +33,7 @@
 #include <linux/tcp.h>
 #include <linux/if_vlan.h>
 #include "en.h"
+#include "ipoib.h"
 
 #define MLX5E_SQ_NOPS_ROOM  MLX5_SEND_WQE_MAX_WQEBBS
 #define MLX5E_SQ_STOP_ROOM (MLX5_SEND_WQE_MAX_WQEBBS +\
-- 
2.11.0
