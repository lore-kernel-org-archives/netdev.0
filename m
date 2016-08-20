From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 17/30] net/mlx5: Update struct mlx5_ifc_xrqc_bits
Date: Sat, 20 Aug 2016 23:12:00 +0300
Message-ID: <1471723933-5894-18-git-send-email-saeedm@mellanox.com>
References: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Artemy Kovalyov <artemyko@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34224 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752193AbcHTUMs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 16:12:48 -0400
In-Reply-To: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Artemy Kovalyov <artemyko@mellanox.com>

Update struct mlx5_ifc_xrqc_bits according to last specification

Signed-off-by: Artemy Kovalyov <artemyko@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 include/linux/mlx5/mlx5_ifc.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index e1f8e34..5f150c8 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -2829,7 +2829,7 @@ struct mlx5_ifc_xrqc_bits {
 
 	struct mlx5_ifc_tag_matching_topology_context_bits tag_matching_topology_context;
 
-	u8         reserved_at_180[0x180];
+	u8         reserved_at_180[0x200];
 
 	struct mlx5_ifc_wq_bits wq;
 };
-- 
2.7.4
