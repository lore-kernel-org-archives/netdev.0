From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next] net/mlx4_en: mlx4_en_[gs]et_priv_flags() can be static
Date: Wed, 23 Jul 2014 09:36:26 +0300
Message-ID: <1406097386-11034-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Fengguang Wu <fengguang.wu@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37431 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752707AbaGWGgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2014 02:36:47 -0400
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
index 881f5c59..16051cc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1221,7 +1221,7 @@ static int mlx4_en_get_ts_info(struct net_device *dev,
 	return ret;
 }
 
-int mlx4_en_set_priv_flags(struct net_device *dev, u32 flags)
+static int mlx4_en_set_priv_flags(struct net_device *dev, u32 flags)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
@@ -1246,7 +1246,7 @@ int mlx4_en_set_priv_flags(struct net_device *dev, u32 flags)
 	return 0;
 }
 
-u32 mlx4_en_get_priv_flags(struct net_device *dev)
+static u32 mlx4_en_get_priv_flags(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
-- 
1.8.3.4
