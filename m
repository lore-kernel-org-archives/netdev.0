From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net 0/8] Mellanox mlx5 fixes 2017-01-27
Date: Fri, 27 Jan 2017 22:38:35 +0200
Message-ID: <20170127203843.3206-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:33325 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751338AbdA0VLL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 16:11:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This pull request includes some mlx5 fixes for net, please see details
below.

Please pull and let me know if there's any problem.

For -stable:
      net/mlx5e: Modify TIRs hash only when it's needed
      net/mlx5e: Fix update of hash function/key via ethtool

Thanks,
Saeed.

---

The following changes since commit 214767faa2f31285f92754393c036f13b55474a6:

  Merge tag 'batadv-net-for-davem-20170125' of git://git.open-mesh.org/linux-merge (2017-01-25 23:11:13 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-fixes-2017-01-27

for you to fetch changes up to 4f24229d2f73be75c2d362113588e30a1695dcb1:

  net/mlx5e: Check ets capability before ets query FW command (2017-01-27 00:05:47 +0200)

----------------------------------------------------------------
mlx5-fixes-2017-01-27

A couple of mlx5 core and ethernet driver fixes.

>From Or, a couple of error return values and error handling fixes.
>From Hadar, Support TC encapsulation offloads even when the mlx5e uplink
device is stacked  under an upper device.
>From Gal, two patches to fix RSS hash modifications via ethtool.
>From Moshe, Added a needed ets capability check.

----------------------------------------------------------------
Gal Pressman (2):
      net/mlx5e: Modify TIRs hash only when it's needed
      net/mlx5e: Fix update of hash function/key via ethtool

Hadar Hen Zion (1):
      net/mlx5e: Support TC encapsulation offloads with upper devices

Moshe Shemesh (1):
      net/mlx5e: Check ets capability before ets query FW command

Or Gerlitz (4):
      net/mlx5: Change ENOTSUPP to EOPNOTSUPP
      net/mlx5: Return EOPNOTSUPP when failing to get steering name-space
      net/mlx5: E-Switch, Err when retrieving steering name-space fails
      net/mlx5: E-Switch, Re-enable RoCE on mode change only after FDB destroy

 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   7 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c |  11 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  41 +++--
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |   2 +-
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 202 ++++++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  13 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  10 +-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  36 ++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/vport.c    |   2 +-
 15 files changed, 181 insertions(+), 157 deletions(-)
