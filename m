From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 5/5] mlx5: fix warning about missing prototype
Date: Sat, 22 Apr 2017 21:45:07 +0300
Message-ID: <20170422184507.26569-6-saeedm@mellanox.com>
References: <20170422184507.26569-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48069 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1426162AbdDVSpo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 14:45:44 -0400
In-Reply-To: <20170422184507.26569-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>

Fix sparse warning about missing prototypes. The rx/tx code path
defines functions with prototypes in ipoib.h.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
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
