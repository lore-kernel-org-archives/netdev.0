From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 01/15] net/mlx5: Update eqe_type_str() event names
Date: Fri, 16 Jun 2017 00:42:38 +0300
Message-ID: <20170615214252.30140-2-saeedm@mellanox.com>
References: <20170615214252.30140-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32908 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752136AbdFOVnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:43:05 -0400
In-Reply-To: <20170615214252.30140-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Add missing NIC_VPORT_CHANGE event.

Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index 0ed8e90ba54f..23048247d827 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -157,6 +157,8 @@ static const char *eqe_type_str(u8 type)
 		return "MLX5_EVENT_TYPE_PAGE_FAULT";
 	case MLX5_EVENT_TYPE_PPS_EVENT:
 		return "MLX5_EVENT_TYPE_PPS_EVENT";
+	case MLX5_EVENT_TYPE_NIC_VPORT_CHANGE:
+		return "MLX5_EVENT_TYPE_NIC_VPORT_CHANGE";
 	case MLX5_EVENT_TYPE_FPGA_ERROR:
 		return "MLX5_EVENT_TYPE_FPGA_ERROR";
 	default:
-- 
2.11.0
