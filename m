From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 15/15] net/mlx5: Fix offset of hca cap reserved field
Date: Fri, 23 Jun 2017 17:26:22 +0300
Message-ID: <20170623142622.16565-16-saeedm@mellanox.com>
References: <20170623142622.16565-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54091 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753397AbdFWO1p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 10:27:45 -0400
In-Reply-To: <20170623142622.16565-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

The offending commit pushed fwd the field by two bits but
didn't increment the offset, fix that. Currently, no damage
was done b/c this is just a field name, but lets have it right.

Fixes: f32f5bd2eb7e ('net/mlx5: Configure cache line size for start and end padding')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/mlx5_ifc.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 8f197b070cea..d6b99d5d0f24 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -824,7 +824,7 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         cc_modify_allowed[0x1];
 	u8         start_pad[0x1];
 	u8         cache_line_128byte[0x1];
-	u8         reserved_at_163[0xb];
+	u8         reserved_at_165[0xb];
 	u8         gid_table_size[0x10];
 
 	u8         out_of_seq_cnt[0x1];
-- 
2.11.0
