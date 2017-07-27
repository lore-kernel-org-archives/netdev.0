From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net V2 07/14] net/mlx5: Fix mlx5_ifc_mtpps_reg_bits structure size
Date: Thu, 27 Jul 2017 16:56:10 +0300
Message-ID: <20170727135617.18559-8-saeedm@mellanox.com>
References: <20170727135617.18559-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40171 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751742AbdG0N5Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 09:57:16 -0400
In-Reply-To: <20170727135617.18559-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Fix miscalculation in reserved_at_1a0 field.

Fixes: ee7f12205abc ('net/mlx5e: Implement 1PPS support')
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/mlx5_ifc.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 87869c04849a..fd98aef4545c 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -8175,7 +8175,7 @@ struct mlx5_ifc_mtpps_reg_bits {
 	u8         out_pulse_duration[0x10];
 	u8         out_periodic_adjustment[0x10];
 
-	u8         reserved_at_1a0[0x60];
+	u8         reserved_at_1a0[0x40];
 };
 
 struct mlx5_ifc_mtppse_reg_bits {
-- 
2.13.0
