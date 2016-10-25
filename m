From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next 01/14] net/mlx5: Report multi packet WQE capabilities
Date: Tue, 25 Oct 2016 18:00:04 +0300
Message-ID: <1477407617-20745-2-git-send-email-saeedm@mellanox.com>
References: <1477407617-20745-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Bodong Wang <bodong@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37436 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754379AbcJYPFn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:05:43 -0400
In-Reply-To: <1477407617-20745-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Multi packet WQE enables sending multiple fix sized packets
using a single WQE. The exposed field reports such HW support.

Signed-off-by: Bodong Wang <bodong@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/mlx5_ifc.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 6045d4d..2def5b9 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -556,7 +556,7 @@ struct mlx5_ifc_per_protocol_networking_offload_caps_bits {
 	u8         self_lb_en_modifiable[0x1];
 	u8         reserved_at_9[0x2];
 	u8         max_lso_cap[0x5];
-	u8         reserved_at_10[0x2];
+	u8         multi_pkt_send_wqe[0x2];
 	u8	   wqe_inline_mode[0x2];
 	u8         rss_ind_tbl_cap[0x4];
 	u8         reg_umr_sq[0x1];
-- 
2.7.4
