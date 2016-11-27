From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 09/10] net/mlx4: Change number of max MSIXs from 64 to 1024
Date: Sun, 27 Nov 2016 17:51:16 +0200
Message-ID: <1480261877-19720-10-git-send-email-tariqt@mellanox.com>
References: <1480261877-19720-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Moshe Shemesh <moshe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50469 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753083AbcK0Pvf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 10:51:35 -0500
In-Reply-To: <1480261877-19720-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Increase the number of max MSIXs in order to achieve
better performance on machines with high number of CPUs.

Fixes: 0b7ca5a928e2 ("mlx4: Changing interrupt scheme")
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 include/linux/mlx4/device.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 1dcd6ac3b1f3..44863e3c0981 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -47,7 +47,7 @@
 #define DEFAULT_UAR_PAGE_SHIFT  12
 
 #define MAX_MSIX_P_PORT		17
-#define MAX_MSIX		64
+#define MAX_MSIX		1024
 #define MIN_MSIX_P_PORT		5
 #define MLX4_IS_LEGACY_EQ_MODE(dev_cap) ((dev_cap).num_comp_vectors < \
 					 (dev_cap).num_ports * MIN_MSIX_P_PORT)
-- 
1.8.3.1
