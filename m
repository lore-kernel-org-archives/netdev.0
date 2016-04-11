From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 0/2] mlx5_core: mlx5_ifc updates
Date: Mon, 11 Apr 2016 23:10:20 +0300
Message-ID: <1460405422-8654-1-git-send-email-saeedm@mellanox.com>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave and Doug

This series include mlx5_core updates for both net-next and rdma
trees for 4.7 kernel cycle. This is the only shared code planned
for 4.7 between rdma and net trees. Hopefully, this will prevent 
future conflicts when merging between ib-next and net-next once
4.7 cycle is over and merge window is opened.

Both Mellanox rdma and net submissions will proceed once this series
is applied into both trees.

Future shared code will be sent to both maintainers as pull requests
from Mellanox's kernel.org tree.

We have included all the maintainers of respective drivers.
Kindly review the change and let us know in case of any review comments.

Saeed Mahameed (1):
  net/mlx5: Update mlx5_ifc hardware features

Tariq Toukan (1):
  net/mlx5: Fix mlx5 ifc cmd_hca_cap bad offsets

 include/linux/mlx5/mlx5_ifc.h |  253 +++++++++++++++++++++++++++++------------
 1 files changed, 179 insertions(+), 74 deletions(-)

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
