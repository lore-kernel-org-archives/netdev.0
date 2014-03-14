From: clsoto-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Subject: [PATCH v2 0/2] IB/mlx5: Add PCI error handler support for mlx5
Date: Fri, 14 Mar 2014 12:14:56 -0500
Message-ID: <20140314171456.181059236@linux.vnet.ibm.com>
Cc: brking-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, clsoto-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The following series add PCI error handler support for mlx5 driver and
improvements in the mlx5 remove_one function to make sure that it can execute
all the functions to tear down the resources.

IB/mlx5: Implementation of PCI error handler
IB/mlx5: Free resources during PCI error

 drivers/infiniband/hw/mlx5/main.c              |   32 ++++++++++++++++++++++++-
 drivers/infiniband/hw/mlx5/mr.c                |    9 ++++---
 drivers/infiniband/hw/mlx5/qp.c                |    6 +++-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c  |    7 +++++
 drivers/net/ethernet/mellanox/mlx5/core/eq.c   |    8 ++----
 drivers/net/ethernet/mellanox/mlx5/core/main.c |    1
 include/linux/mlx5/driver.h                    |    2 -
 7 files changed, 53 insertions(+), 12 deletions(-)

Carol Soto
-- 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
