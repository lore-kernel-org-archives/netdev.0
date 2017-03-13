From: Erez Shitrit <erezsh@mellanox.com>
Subject: [RFC v1 for accelerated IPoIB 06/25] hw/mlx5: Add New bit to check over QP creation
Date: Mon, 13 Mar 2017 20:31:17 +0200
Message-ID: <1489429896-10781-7-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        valex@mellanox.com, leonro@mellanox.com, saedm@mellanox.com,
        erezsh@dev.mellanox.co.il, Erez Shitrit <erezsh@mellanox.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49705 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752891AbdCMScB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 14:32:01 -0400
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add check for bit IB_QP_CREATE_NETIF_QP while creating QP.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
---
 drivers/infiniband/hw/mlx5/qp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index dc0ea63900c1..41e14d57fec9 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -897,6 +897,7 @@ static int create_kernel_qp(struct mlx5_ib_dev *dev,
 	if (init_attr->create_flags & ~(IB_QP_CREATE_SIGNATURE_EN |
 					IB_QP_CREATE_BLOCK_MULTICAST_LOOPBACK |
 					IB_QP_CREATE_IPOIB_UD_LSO |
+					IB_QP_CREATE_NETIF_QP |
 					mlx5_ib_create_qp_sqpn_qp1()))
 		return -EINVAL;
 
-- 
1.8.3.1
