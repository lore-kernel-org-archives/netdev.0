From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 08/10] net/mlx5e: Add missing 50G baseSR2 link mode
Date: Thu, 23 Jun 2016 17:02:44 +0300
Message-ID: <1466690566-14700-9-git-send-email-saeedm@mellanox.com>
References: <1466690566-14700-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ben Hutchings <bwh@kernel.org>,
	David Decotigny <decot@googlers.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35377 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751933AbcFWPrI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2016 11:47:08 -0400
In-Reply-To: <1466690566-14700-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Add MLX5E_50GBASE_SR2 as ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Cc: Ben Hutchings <bwh@kernel.org>
Cc: David Decotigny <decot@googlers.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h | 1 +
 1 file changed, 1 insertion(+)

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
-- 
2.8.0
