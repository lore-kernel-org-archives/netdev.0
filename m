From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 7/9] net/mlx5e: Add 50G missing link mode to ethtool and mlx5 driver
Date: Wed, 22 Jun 2016 19:33:15 +0300
Message-ID: <1466613197-28726-8-git-send-email-saeedm@mellanox.com>
References: <1466613197-28726-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Ben Hutchings <bwh@kernel.org>,
	David Decotigny <decot@googlers.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39106 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752182AbcFVQeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 12:34:04 -0400
In-Reply-To: <1466613197-28726-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Add ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT and MLX5E_50GBASE_SR2
bits.

Signed-off-by: Gal Pressman <galp@mellanox.com>
CC: Ben Hutchings <bwh@kernel.org>
CC: David Decotigny <decot@googlers.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h | 1 +
 include/uapi/linux/ethtool.h                 | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index aa36a3a..b8732e6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -616,6 +616,7 @@ enum mlx5e_link_mode {
 	MLX5E_10GBASE_ER	 = 14,
 	MLX5E_40GBASE_SR4	 = 15,
 	MLX5E_40GBASE_LR4	 = 16,
+	MLX5E_50GBASE_SR2	 = 18,
 	MLX5E_100GBASE_CR4	 = 20,
 	MLX5E_100GBASE_SR4	 = 21,
 	MLX5E_100GBASE_KR4	 = 22,
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 5f030b4..b8f38e8 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1362,6 +1362,7 @@ enum ethtool_link_mode_bit_indices {
 	ETHTOOL_LINK_MODE_100000baseSR4_Full_BIT	= 37,
 	ETHTOOL_LINK_MODE_100000baseCR4_Full_BIT	= 38,
 	ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT	= 39,
+	ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT         = 40,
 
 	/* Last allowed bit for __ETHTOOL_LINK_MODE_LEGACY_MASK is bit
 	 * 31. Please do NOT define any SUPPORTED_* or ADVERTISED_*
@@ -1370,7 +1371,7 @@ enum ethtool_link_mode_bit_indices {
 	 */
 
 	__ETHTOOL_LINK_MODE_LAST
-	  = ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT,
+	  = ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT,
 };
 
 #define __ETHTOOL_LINK_MODE_LEGACY_MASK(base_name)	\
-- 
2.8.0
