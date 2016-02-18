From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 09/12] net/mlx5e: Protect en header file from redefinitions
Date: Thu, 18 Feb 2016 12:32:50 +0200
Message-ID: <1455791573-5270-10-git-send-email-saeedm@mellanox.com>
References: <1455791573-5270-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34227 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1425528AbcBRKm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 05:42:26 -0500
In-Reply-To: <1455791573-5270-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Finlay <matt@mellanox.com>

add ifndef to en.h. needed for upcoming vxlan patchset.

Signed-off-by: Matt Finlay <matt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index dfbc4e5..786a247 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2015, Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2015-2016, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
@@ -29,6 +29,8 @@
  * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  * SOFTWARE.
  */
+#ifndef __MLX5_EN_H__
+#define __MLX5_EN_H__
 
 #include <linux/if_vlan.h>
 #include <linux/etherdevice.h>
@@ -678,3 +680,5 @@ int mlx5e_dcbnl_ieee_setets_core(struct mlx5e_priv *priv, struct ieee_ets *ets);
 #endif
 
 u16 mlx5e_get_max_inline_cap(struct mlx5_core_dev *mdev);
+
+#endif /* __MLX5_EN_H__ */
-- 
1.7.1
