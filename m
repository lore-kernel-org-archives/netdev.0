From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 1/6] net/mlx5e: s390 system compilation fix
Date: Wed, 22 Feb 2017 17:20:11 +0200
Message-ID: <20170222152016.31263-2-saeedm@mellanox.com>
References: <20170222152016.31263-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57751 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933016AbdBVPVr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 10:21:47 -0500
In-Reply-To: <20170222152016.31263-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Add necessary headers include for s390 arch compilation.

Fixes: e586b3b0baee ("net/mlx5: Ethernet Datapath files")
Fixes: d605d6686dc7 ("net/mlx5e: Add support for ethtool self..")
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c       | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index b039b87742a6..9fad22768aab 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -30,6 +30,7 @@
  * SOFTWARE.
  */
 
+#include <linux/prefetch.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/tcp.h>
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
index 65442c36a6e1..31e3cb7ee5fe 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
@@ -30,6 +30,7 @@
  * SOFTWARE.
  */
 
+#include <linux/prefetch.h>
 #include <linux/ip.h>
 #include <linux/udp.h>
 #include <net/udp.h>
-- 
2.11.0
