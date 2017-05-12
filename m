From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net 0/6] Mellanox, mlx5 fixes 2017-05-12
Date: Fri, 12 May 2017 14:56:44 +0300
Message-ID: <20170512115650.11635-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51201 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755662AbdELMCD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 08:02:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains some mlx5 fixes for net.
Please pull and let me know if there's any problem.

For -stable:
("net/mlx5e: Fix ethtool pause support and advertise reporting") kernels >= 4.8
("net/mlx5e: Use the correct pause values for ethtool advertising") kernels >= 4.8

Thanks,
Saeed.

---

The following changes since commit df0c8d911abf6ba97b2c2fc3c5a12769e0b081a3:

  net: phy: Call bus->reset() after releasing PHYs from reset (2017-05-11 23:06:18 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-fixes-2017-05-12

for you to fetch changes up to 5405a3d4687a3e2fad41a59c3cecbd33b7200fa1:

  net/mlx5: Use underlay QPN from the root name space (2017-05-12 14:18:41 +0300)

----------------------------------------------------------------
mlx5-fixes-2017-05-12

Misc mlx5 fixes

----------------------------------------------------------------
Gal Pressman (3):
      net/mlx5e: Use a spinlock to synchronize statistics
      net/mlx5e: Use the correct pause values for ethtool advertising
      net/mlx5e: Fix ethtool pause support and advertise reporting

Saeed Mahameed (2):
      net/mlx5e: Fix setup TC ndo
      net/mlx5e: IPoIB, Only support regular RQ for now

Yishai Hadas (1):
      net/mlx5: Use underlay QPN from the root name space

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  3 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 21 +++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  5 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 47 ++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  9 ++---
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   |  3 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 25 ++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c    | 11 ++++-
 include/linux/mlx5/fs.h                            |  4 +-
 10 files changed, 93 insertions(+), 37 deletions(-)
