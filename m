From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: [PATCH net-next 0/9] mlx5 driver updates
Date: Tue,  2 Dec 2014 12:26:10 +0200
Message-ID: <1417515979-22418-1-git-send-email-eli@mellanox.com>
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

The following series contains some fixes to mlx5 as well as update to the list
of supported devices.

Thanks,
Eli

Eli Cohen (8):
  net/mlx5_core: Request the mlx5 IB module on driver load
  net/mlx5_core: Fix min vectors value in mlx5_enable_msix
  net/mlx5_core: Fix command queue size enforcement
  net/mlx5_core: Remove unused dev cap enum fields
  net/mlx5_core: Print resource number on QP/SRQ async events
  net/mlx5_core: Add more supported devices
  mlx5: Fix sparse warnings
  mlx5: Fix error flow in add_keys

Majd Dibbiny (1):
  net/mlx5_core: Clear outbox of dealloc uar

 drivers/infiniband/hw/mlx5/mr.c                |  3 +++
 drivers/infiniband/hw/mlx5/qp.c                | 16 +++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c  |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c   |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 15 +++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/uar.c  |  1 +
 include/linux/mlx5/device.h                    |  8 --------
 7 files changed, 35 insertions(+), 14 deletions(-)

-- 
2.1.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
