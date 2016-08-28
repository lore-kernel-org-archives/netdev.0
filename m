From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 9/9] net/mlx5: Increase number of ethtool steering priorities
Date: Mon, 29 Aug 2016 01:13:50 +0300
Message-ID: <1472422430-21583-10-git-send-email-saeedm@mellanox.com>
References: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Maor Gottlieb <maorg@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53056 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756159AbcH1WOe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 18:14:34 -0400
In-Reply-To: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Ethtool has 11 flow tables, each flow table has its own priority.
Increase the number of priorities to be aligned with the number of flow
tables.

Fixes: 1174fce8d141 ('net/mlx5e: Support l3/l4 flow type specs in ethtool flow steering')
Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 75bb8c8..3d6c1f6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -80,7 +80,7 @@
 			   LEFTOVERS_NUM_PRIOS)
 
 #define ETHTOOL_PRIO_NUM_LEVELS 1
-#define ETHTOOL_NUM_PRIOS 10
+#define ETHTOOL_NUM_PRIOS 11
 #define ETHTOOL_MIN_LEVEL (KERNEL_MIN_LEVEL + ETHTOOL_NUM_PRIOS)
 /* Vlan, mac, ttc, aRFS */
 #define KERNEL_NIC_PRIO_NUM_LEVELS 4
-- 
2.7.4
