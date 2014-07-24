From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1] net/mlx4_en: mlx4_en_[gs]et_priv_flags() can be static
Date: Thu, 24 Jul 2014 09:11:46 +0300
Message-ID: <1406182306-27436-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Fengguang Wu <fengguang.wu@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38406 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751248AbaGXGL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 02:11:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fengguang Wu <fengguang.wu@intel.com>

Fixes sparse warning intrduced by commit 0fef9d0 ("net/mlx4_en: Disable
blueflame using ethtool private flags")

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 50e85cc..e22f24f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1221,7 +1221,7 @@ static int mlx4_en_get_ts_info(struct net_device *dev,
 	return ret;
 }
 
-int mlx4_en_set_priv_flags(struct net_device *dev, u32 flags)
+static int mlx4_en_set_priv_flags(struct net_device *dev, u32 flags)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	bool bf_enabled_new = !!(flags & MLX4_EN_PRIV_FLAGS_BLUEFLAME);
@@ -1256,7 +1256,7 @@ int mlx4_en_set_priv_flags(struct net_device *dev, u32 flags)
 	return 0;
 }
 
-u32 mlx4_en_get_priv_flags(struct net_device *dev)
+static u32 mlx4_en_get_priv_flags(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
-- 
1.8.3.4
