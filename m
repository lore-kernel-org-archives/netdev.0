From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next 7/8] net/mlx5: Fix counter list hardware structure
Date: Mon,  7 Aug 2017 13:18:07 +0300
Message-ID: <20170807101808.22924-8-saeedm@mellanox.com>
References: <20170807101808.22924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Rabie Loulou <rabiel@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53273 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752964AbdHGKSe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 06:18:34 -0400
In-Reply-To: <20170807101808.22924-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rabie Loulou <rabiel@mellanox.com>

The counter list hardware structure doesn't contain a clear and
num_of_counters fields, remove them.

These wrong fields were never used by the driver hence no other driver
changes.

Fixes: a351a1b03bf1 ("net/mlx5: Introduce bulk reading of flow counters")
Signed-off-by: Rabie Loulou <rabiel@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/mlx5_ifc.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 3030121b4746..f847a3a57913 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -1071,8 +1071,7 @@ struct mlx5_ifc_dest_format_struct_bits {
 };
 
 struct mlx5_ifc_flow_counter_list_bits {
-	u8         clear[0x1];
-	u8         num_of_counters[0xf];
+	u8         reserved_at_0[0x10];
 	u8         flow_counter_id[0x10];
 
 	u8         reserved_at_20[0x20];
-- 
2.13.0
