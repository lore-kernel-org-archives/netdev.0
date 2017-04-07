From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 4/7] net/mlx5e: Change FW sub_minor display to 4 zeros padding
Date: Fri,  7 Apr 2017 21:26:53 +0300
Message-ID: <20170407182656.6734-5-saeedm@mellanox.com>
References: <20170407182656.6734-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47255 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756082AbdDGS1T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 14:27:19 -0400
In-Reply-To: <20170407182656.6734-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

FW version should be reported as X.Y.ZZZZ, add leading zeroes to sub
minor in order to fix it.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index af039b6c0799..167a8379156e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -42,7 +42,7 @@ static void mlx5e_get_drvinfo(struct net_device *dev,
 	strlcpy(drvinfo->version, DRIVER_VERSION " (" DRIVER_RELDATE ")",
 		sizeof(drvinfo->version));
 	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
-		 "%d.%d.%d",
+		 "%d.%d.%04d",
 		 fw_rev_maj(mdev), fw_rev_min(mdev), fw_rev_sub(mdev));
 	strlcpy(drvinfo->bus_info, pci_name(mdev->pdev),
 		sizeof(drvinfo->bus_info));
-- 
2.11.0
