From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net 0/6] Mellanox mlx5 fixes 2017-06-11
Date: Sun, 11 Jun 2017 17:00:22 +0300
Message-ID: <20170611140028.12467-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35955 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751936AbdFKOAu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 10:00:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains some fixes for the mlx5 core and netdev driver.

Please pull and let me know if there's any problem.

For -stable:
("net/mlx5e: Added BW check for DIM decision mechanism")              kernels >= 4.9
("net/mlx5e: Fix wrong indications in DIM due to counter wraparound") kernels >= 4.9
("net/mlx5: Remove several module events out of ethtool stats")       kernels >= 4.10
("net/mlx5: Enable 4K UAR only when page size is bigger than 4K")     kernels >= 4.11

*all patches apply with no issue on their -stable.

BTW I never asked you if this way of marking patches to -stable is good for you ?
if you prefer another format please let me know.

Thanks,
Saeed.
---

The following changes since commit b87fa0fafef4b16495740432f4eb8262efa500d0:

  Merge branch 'mvpp2-fixes' (2017-06-10 18:22:56 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-fixes-2017-06-11

for you to fetch changes up to 91828bd89940e8145f91751a015bc11bc486aad0:

  net/mlx5: Enable 4K UAR only when page size is bigger than 4K (2017-06-11 13:10:36 +0300)

----------------------------------------------------------------
mlx5-fixes-2017-06-11

----------------------------------------------------------------
Huy Nguyen (1):
      net/mlx5: Remove several module events out of ethtool stats

Majd Dibbiny (1):
      net/mlx5: Enable 4K UAR only when page size is bigger than 4K

Mohamad Haj Yahia (2):
      net/mlx5: Fix create vport flow table flow
      net/mlx5: Continue health polling until it is explicitly stopped

Tal Gilboa (2):
      net/mlx5e: Added BW check for DIM decision mechanism
      net/mlx5e: Fix wrong indications in DIM due to counter wraparound

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  8 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c | 45 +++++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 11 +-----
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/health.c   | 11 +++---
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  6 ++-
 6 files changed, 43 insertions(+), 40 deletions(-)
