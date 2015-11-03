From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 5/7] net/mlx5e: Return error in case mlx5e_set_features() fails
Date: Tue,  3 Nov 2015 08:07:22 +0200
Message-ID: <1446530844-14077-6-git-send-email-ogerlitz@mellanox.com>
References: <1446530844-14077-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38584 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754594AbbKCGIQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 01:08:16 -0500
In-Reply-To: <1446530844-14077-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

In case mlx5e_set_features() fails, return the failure status rather
than 0.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index febf711..28eaed5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1843,7 +1843,7 @@ static int mlx5e_set_features(struct net_device *netdev,
 			mlx5e_disable_vlan_filter(priv);
 	}
 
-	return 0;
+	return err;
 }
 
 static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
-- 
2.3.7
