From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [V2 net-next 11/15] net/mlx5e: Properly indent within conditional statements
Date: Sun, 20 Aug 2017 16:49:12 +0300
Message-ID: <20170820134916.10222-12-saeedm@mellanox.com>
References: <20170820134916.10222-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44807 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752944AbdHTNtX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 09:49:23 -0400
In-Reply-To: <20170820134916.10222-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

To fix these checkpatch complaints:

WARNING: suspect code indent for conditional statements (8, 24)
+       if (eth_proto & (MLX5E_PROT_MASK(MLX5E_10GBASE_SR)
[...]
+                       return PORT_FIBRE;

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 31 ++++++++++++----------
 1 file changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index a75ac4d11c5b..1f3d87e28618 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -987,24 +987,27 @@ static u8 get_connector_port(u32 eth_proto, u8 connector_type)
 	if (connector_type && connector_type < MLX5E_CONNECTOR_TYPE_NUMBER)
 		return ptys2connector_type[connector_type];
 
-	if (eth_proto & (MLX5E_PROT_MASK(MLX5E_10GBASE_SR)
-			 | MLX5E_PROT_MASK(MLX5E_40GBASE_SR4)
-			 | MLX5E_PROT_MASK(MLX5E_100GBASE_SR4)
-			 | MLX5E_PROT_MASK(MLX5E_1000BASE_CX_SGMII))) {
-			return PORT_FIBRE;
+	if (eth_proto &
+	    (MLX5E_PROT_MASK(MLX5E_10GBASE_SR)   |
+	     MLX5E_PROT_MASK(MLX5E_40GBASE_SR4)  |
+	     MLX5E_PROT_MASK(MLX5E_100GBASE_SR4) |
+	     MLX5E_PROT_MASK(MLX5E_1000BASE_CX_SGMII))) {
+		return PORT_FIBRE;
 	}
 
-	if (eth_proto & (MLX5E_PROT_MASK(MLX5E_40GBASE_CR4)
-			 | MLX5E_PROT_MASK(MLX5E_10GBASE_CR)
-			 | MLX5E_PROT_MASK(MLX5E_100GBASE_CR4))) {
-			return PORT_DA;
+	if (eth_proto &
+	    (MLX5E_PROT_MASK(MLX5E_40GBASE_CR4) |
+	     MLX5E_PROT_MASK(MLX5E_10GBASE_CR)  |
+	     MLX5E_PROT_MASK(MLX5E_100GBASE_CR4))) {
+		return PORT_DA;
 	}
 
-	if (eth_proto & (MLX5E_PROT_MASK(MLX5E_10GBASE_KX4)
-			 | MLX5E_PROT_MASK(MLX5E_10GBASE_KR)
-			 | MLX5E_PROT_MASK(MLX5E_40GBASE_KR4)
-			 | MLX5E_PROT_MASK(MLX5E_100GBASE_KR4))) {
-			return PORT_NONE;
+	if (eth_proto &
+	    (MLX5E_PROT_MASK(MLX5E_10GBASE_KX4) |
+	     MLX5E_PROT_MASK(MLX5E_10GBASE_KR)  |
+	     MLX5E_PROT_MASK(MLX5E_40GBASE_KR4) |
+	     MLX5E_PROT_MASK(MLX5E_100GBASE_KR4))) {
+		return PORT_NONE;
 	}
 
 	return PORT_OTHER;
-- 
2.13.0
