From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next 0/5] Mellanox, mlx5 updates 2017-04-22
Date: Sat, 22 Apr 2017 21:45:02 +0300
Message-ID: <20170422184507.26569-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48048 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755395AbdDVSpo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 14:45:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains some updates to mlx5 driver.

Sparse and compiler warnings fixes from Stephen Hemminger.

>From Roi Dayan and Or Gerlitz, Add devlink and mlx5 support for controlling
E-Switch encapsulation mode, this knob will enable HW support for applying
encapsulation/decapsulation to VF traffic as part of SRIOV e-switch offloading.

Please pull and let me know if there's any problem.

Thanks,
Saeed.

---

The following changes since commit fb796707d7a6c9b24fdf80b9b4f24fa5ffcf0ec5:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-04-21 20:23:53 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-updates-2017-04-22

for you to fetch changes up to 8bf3198a5e394ed6815aeb8fedaf49722986bbd3:

  mlx5: fix warning about missing prototype (2017-04-22 20:26:42 +0300)

Or Gerlitz (1):
      net/mlx5: E-Switch, Refactor fast path FDB table creation in switchdev mode

Roi Dayan (2):
      net/devlink: Add E-Switch encapsulation control
      net/mlx5: E-Switch, Add control for encapsulation

Stephen Hemminger (2):
      mlx5: hide unused functions
      mlx5: fix warning about missing prototype

 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |   5 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |   3 +
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 132 +++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c    |  24 ++--
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   2 +
 include/net/devlink.h                              |   2 +
 include/uapi/linux/devlink.h                       |   7 ++
 net/core/devlink.c                                 |  26 +++-
 10 files changed, 167 insertions(+), 36 deletions(-)
