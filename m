From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net V2 0/5] Mellanox, mlx5 fixes 2017-05-12
Date: Sun, 14 May 2017 13:43:06 +0300
Message-ID: <20170514104311.2081-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48609 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750969AbdENKnZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 06:43:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains some mlx5 fixes for net.
Please pull and let me know if there's any problem.

For -stable:
("net/mlx5e: Fix ethtool pause support and advertise reporting") kernels >= 4.8
("net/mlx5e: Use the correct pause values for ethtool advertising") kernels >= 4.8

v1->v2:
 Dropped statistics spinlock patch, it needs some extra work.

Thanks,
Saeed.

The following changes since commit 1c4d5f51a812a82de97beee24f48ed05c65ebda5:

  vmxnet3: ensure that adapter is in proper state during force_close (2017-05-12 12:23:52 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-fixes-2017-05-12-V2

for you to fetch changes up to 508541146af18e43072e41a31aa62fac2b01aac1:

  net/mlx5: Use underlay QPN from the root name space (2017-05-14 13:33:45 +0300)

----------------------------------------------------------------
mlx5-fixes-2017-05-12

Misc fixes for mlx5 driver

----------------------------------------------------------------
Gal Pressman (2):
      net/mlx5e: Use the correct pause values for ethtool advertising
      net/mlx5e: Fix ethtool pause support and advertise reporting

Saeed Mahameed (2):
      net/mlx5e: Fix setup TC ndo
      net/mlx5e: IPoIB, Only support regular RQ for now

Yishai Hadas (1):
      net/mlx5: Use underlay QPN from the root name space

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  2 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  9 +++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  5 ++---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  9 +++-----
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   |  3 ++-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 25 ++++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c    | 11 ++++++++--
 include/linux/mlx5/fs.h                            |  4 +++-
 10 files changed, 49 insertions(+), 23 deletions(-)
