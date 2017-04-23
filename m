From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net 0/7] Mellanox, mlx5 fixes 2017-04-22
Date: Sun, 23 Apr 2017 13:07:55 +0300
Message-ID: <20170423100802.27630-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48679 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1044744AbdDWKIM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 06:08:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains some mlx5 fixes for net.

For your convenience, the series doesn't introduce any conflict with
the ongoing net-next pull request.

Please pull and let me know if there's any problem.

For -stable:
("net/mlx5: E-Switch, Correctly deal with inline mode on ConnectX-5") kernels >= 4.10
("net/mlx5e: Fix ETHTOOL_GRXCLSRLALL handling") kernels >= 4.8
("net/mlx5e: Fix small packet threshold")       kernels >= 4.7
("net/mlx5: Fix driver load bad flow when having fw initializing timeout") kernels >= 4.4

Thanks,
Saeed.

The following changes since commit 94836ecf1e7378b64d37624fbb81fe48fbd4c772:

  Merge tag 'nfsd-4.11-2' of git://linux-nfs.org/~bfields/linux (2017-04-21 16:37:48 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-fixes-2017-04-22

for you to fetch changes up to 5e82c9e4ed60beba83f46a1a5a8307b99a23e982:

  net/mlx5e: Fix ETHTOOL_GRXCLSRLALL handling (2017-04-22 21:52:37 +0300)

----------------------------------------------------------------
mlx5-fixes-2017-04-22

----------------------------------------------------------------
Eugenia Emantayev (1):
      net/mlx5e: Fix small packet threshold

Ilan Tayari (1):
      net/mlx5e: Fix ETHTOOL_GRXCLSRLALL handling

Maor Gottlieb (1):
      net/mlx5: Fix UAR memory leak

Mohamad Haj Yahia (1):
      net/mlx5: Fix driver load bad flow when having fw initializing timeout

Or Gerlitz (3):
      net/mlx5: E-Switch, Correctly deal with inline mode on ConnectX-5
      net/mlx5e: Make sure the FW max encap size is enough for ipv4 tunnels
      net/mlx5e: Make sure the FW max encap size is enough for ipv6 tunnels

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  2 +-
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 87 ++++++++++++----------
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 36 ++++++---
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/uar.c      |  1 +
 6 files changed, 76 insertions(+), 53 deletions(-)
