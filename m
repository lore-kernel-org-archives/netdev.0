From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next 0/1] [pull request] Mellanox ConnectX-4 Shared Code
Date: Tue, 14 Jun 2016 13:34:59 +0300
Message-ID: <1465900500-1578-1-git-send-email-leonro@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Doug and Dave,

This is Mellanox mlx5_core shared code for both net-next and RDMA
trees for 4.8 kernel cycle.

This mlx5_ifc update introduces following ConnectX-4 features.

* netdev part:
 - MLX5_CQ_PERIOD_NUM_MODES for adaptive moderation support
 - QoS rate limiting
 - SQ context rate limiting
 - Auto negotiation fields in PTYS register
 - Source SQN field in flow table entry match structure
 - DCBX parameters

* RDMA part:
 - New XRQ opcodes, commands and capabilities layout
 - Extend Q counters definition to support IB.

Thank you,
  Saeed and Leon.

The following changes since commit af8c34ce6ae32addda3788d54a7e340cad22516b:

  Linux 4.7-rc2 (2016-06-05 14:31:26 -0700)

are available in the git repository at:

  git-OoYKEaZ2EDaWaY/ihj7yzEB+6BGkLq7r@public.gmane.org:pub/scm/linux/kernel/git/leon/linux-rdma tags/shared

for you to fetch changes up to 7486216b3a0bd26375b17b2cc168a311106cea70:

  {net,IB}/mlx5: mlx5_ifc updates (2016-06-10 13:29:14 +0300)

Saeed Mahameed (1):
  {net,IB}/mlx5: mlx5_ifc updates

 Makefile                      |   2 +-
 include/linux/mlx5/mlx5_ifc.h | 275 ++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 264 insertions(+), 13 deletions(-)

-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
