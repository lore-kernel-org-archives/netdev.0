From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 16/16] hw/mlx5: Add New bit to check over QP creation
Date: Thu, 13 Apr 2017 06:37:06 +0300
Message-ID: <20170413033706.19016-17-saeedm@mellanox.com>
References: <20170413033706.19016-1-saeedm@mellanox.com>
Cc: linux-rdma@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Erez Shitrit <erezsh@mellanox.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Vishwanathapura Niranjana <niranjana.vishwanathapura@intel.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41794 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756066AbdDMDhq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 23:37:46 -0400
In-Reply-To: <20170413033706.19016-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.com>

Add check for bit IB_QP_CREATE_NETIF_QP while creating QP.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/qp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index ad8a2638e339..ed6320186f89 100644
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
2.11.0
