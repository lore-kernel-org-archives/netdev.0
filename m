From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 1/7] net/mlx5: Add missing include in lib/gid.c
Date: Sun,  9 Jul 2017 15:49:11 +0300
Message-ID: <20170709124917.12852-2-saeedm@mellanox.com>
References: <20170709124917.12852-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Ilan Tayari <ilant@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36243 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752158AbdGIMuH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2017 08:50:07 -0400
In-Reply-To: <20170709124917.12852-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Fix warnings when building with -Wall:
drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c:38:6: warning: symbol 'mlx5_init_reserved_gids' was not declared. Should it be static?
drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c:47:6: warning: symbol 'mlx5_cleanup_reserved_gids' was not declared. Should it be static?
drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c:55:5: warning: symbol 'mlx5_core_reserve_gids' was not declared. Should it be static?
drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c:79:6: warning: symbol 'mlx5_core_unreserve_gids' was not declared. Should it be static?
drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c:92:5: warning: symbol 'mlx5_core_reserved_gid_alloc' was not declared. Should it be static?
drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c:109:6: warning: symbol 'mlx5_core_reserved_gid_free' was not declared. Should it be static?

Fixes: 52ec462eca9b ("net/mlx5: Add reserved-gids support")
Reported-by: Or Gerlitz <gerlitz.or@gmail.com>
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c b/drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c
index de2aed44ab85..573f59f46d41 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c
@@ -34,6 +34,7 @@
 #include <linux/etherdevice.h>
 #include <linux/idr.h>
 #include "mlx5_core.h"
+#include "lib/mlx5.h"
 
 void mlx5_init_reserved_gids(struct mlx5_core_dev *dev)
 {
-- 
2.11.0
