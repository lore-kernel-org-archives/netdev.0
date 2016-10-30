From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next V2 02/15] net/mlx5: Update struct mlx5_ifc_xrqc_bits
Date: Sun, 30 Oct 2016 23:21:55 +0200
Message-ID: <1477862528-4328-3-git-send-email-saeedm@mellanox.com>
References: <1477862528-4328-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Artemy Kovalyov <artemyko@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60251 "EHLO
        mellanox.co.il" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756356AbcJ3VXn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 17:23:43 -0400
In-Reply-To: <1477862528-4328-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Artemy Kovalyov <artemyko@mellanox.com>

Update struct mlx5_ifc_xrqc_bits according to last specification

Signed-off-by: Artemy Kovalyov <artemyko@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/mlx5_ifc.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 6045d4d..12f72e4 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -2844,7 +2844,7 @@ struct mlx5_ifc_xrqc_bits {
 
 	struct mlx5_ifc_tag_matching_topology_context_bits tag_matching_topology_context;
 
-	u8         reserved_at_180[0x200];
+	u8         reserved_at_180[0x880];
 
 	struct mlx5_ifc_wq_bits wq;
 };
-- 
2.7.4
