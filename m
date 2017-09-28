From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 07/11] net/mlx5e: Print netdev features correctly in error message
Date: Thu, 28 Sep 2017 07:41:28 +0300
Message-ID: <20170928044132.30940-8-saeedm@mellanox.com>
References: <20170928044132.30940-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54396 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751587AbdI1EmG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 00:42:06 -0400
In-Reply-To: <20170928044132.30940-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Use the correct formatting for netdev features.

Fixes: 0e405443e803 ("net/mlx5e: Improve set features ndo resiliency")
Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index dfc29720ab77..84b013dc62e9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3333,8 +3333,8 @@ static int mlx5e_handle_feature(struct net_device *netdev,
 
 	err = feature_handler(netdev, enable);
 	if (err) {
-		netdev_err(netdev, "%s feature 0x%llx failed err %d\n",
-			   enable ? "Enable" : "Disable", feature, err);
+		netdev_err(netdev, "%s feature %pNF failed, err %d\n",
+			   enable ? "Enable" : "Disable", &feature, err);
 		return err;
 	}
 
-- 
2.13.0
