From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/4] mlx4 driver fixes, June 24, 2015
Date: Wed, 24 Jun 2015 18:21:59 +0300
Message-ID: <1435159323-10028-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:56551 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752536AbbFXPW2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2015 11:22:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Some fixes that we made recently, all need to go into stable.

patch #1 "net/mlx4_en: Release TX QP when destroying TX ring" and patch #3 
"Fix wrong csum complete report when rxvlan offload is disabled" to >= 3.19

patch #2 "Wake TX queues only when there's enough room" addressing a bug 
which is there from day one... should go to whatever kernels it's still applicable

patch #4 "mlx4: Disable HA for SRIOV PF RoCE devices" to >= 4.0

The patches are marked with net but are made against net-next,
as the net tree still doesn't contain all the net-next bits.

thanks,

Or.

Eran Ben Elisha (1):
  net/mlx4_en: Release TX QP when destroying TX ring

Ido Shamay (2):
  net/mlx4_en: Wake TX queues only when there's enough room
  net/mlx4_en: Fix wrong csum complete report when rxvlan offload is disabled

Or Gerlitz (1):
  mlx4: Disable HA for SRIOV PF RoCE devices

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  4 ----
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 17 ++++++-----------
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 20 ++++++++++++--------
 drivers/net/ethernet/mellanox/mlx4/intf.c      |  8 +++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  2 +-
 5 files changed, 26 insertions(+), 25 deletions(-)

-- 
2.3.7
