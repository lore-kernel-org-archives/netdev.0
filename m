From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V1 2/8] net/mlx5e: Fix MLX5E_100BASE_T define
Date: Fri, 22 Apr 2016 00:33:01 +0300
Message-ID: <1461274387-10653-3-git-send-email-saeedm@mellanox.com>
References: <1461274387-10653-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:60176 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752315AbcDUVeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 17:34:03 -0400
In-Reply-To: <1461274387-10653-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rana Shahout <ranas@mellanox.com>

Bit 25 of eth_proto_capability in PTYS register is
1000Base-TT and not 100Base-T.

Fixes: f62b8bb8f2d3 ('net/mlx5: Extend mlx5_core to
support ConnectX-4 Ethernet functionality')
Signed-off-by: Rana Shahout <ranas@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |    2 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 879e627..e80ce94 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -609,7 +609,7 @@ enum mlx5e_link_mode {
 	MLX5E_100GBASE_KR4	 = 22,
 	MLX5E_100GBASE_LR4	 = 23,
 	MLX5E_100BASE_TX	 = 24,
-	MLX5E_100BASE_T		 = 25,
+	MLX5E_1000BASE_T	 = 25,
 	MLX5E_10GBASE_T		 = 26,
 	MLX5E_25GBASE_CR	 = 27,
 	MLX5E_25GBASE_KR	 = 28,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 68834b7..3476ab8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -138,10 +138,10 @@ static const struct {
 	[MLX5E_100BASE_TX]   = {
 		.speed      = 100,
 	},
-	[MLX5E_100BASE_T]    = {
-		.supported  = SUPPORTED_100baseT_Full,
-		.advertised = ADVERTISED_100baseT_Full,
-		.speed      = 100,
+	[MLX5E_1000BASE_T]    = {
+		.supported  = SUPPORTED_1000baseT_Full,
+		.advertised = ADVERTISED_1000baseT_Full,
+		.speed      = 1000,
 	},
 	[MLX5E_10GBASE_T]    = {
 		.supported  = SUPPORTED_10000baseT_Full,
-- 
1.7.1
