From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next 0/8] Mellanox, mlx5updates 2017-08-24
Date: Thu, 24 Aug 2017 16:21:44 +0300
Message-ID: <20170824132152.29538-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34083 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753041AbdHXNV6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 09:21:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,


Tthe following changes provide updates to mlx5 core driver.

For more details please see tag log message below.
Please pull and let me know if there's any problem.

Thanks,
Saeed.

---

The following changes since commit a5e2da6e9787187ff104c34aa048419703c1f9cb:

  bpf: netdev is never null in __dev_map_flush (2017-08-23 22:43:40 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-updates-2017-08-24

for you to fetch changes up to 4c03e69ab1ef31877cef63575a1869b130f9c5ce:

  net/mlx5: Add tracepoints (2017-08-24 16:02:58 +0300)

----------------------------------------------------------------
mlx5-updates-2017-08-24

This series includes updates to mlx5 core driver.

>From Gal and Saeed, three cleanup patches.
>From Matan, Low level flow steering improvements and optimizations,
 - Use more efficient data structures for flow steering objects handling.
 - Add tracepoints to flow steering operations.
 - Overall these patches improve flow steering rule insertion rate by a
   factor of seven in large scales (~50K rules or more).

-Saeed.

----------------------------------------------------------------
Gal Pressman (2):
      net/mlx5: Remove a leftover unused variable
      net/mlx5e: Fix wrong code indentation in conditional statement

Matan Barak (5):
      net/mlx5: Convert linear search for free index to ida
      net/mlx5: Don't store reserved part in FTEs and FGs
      net/mlx5: Add hash table to search FTEs in a flow-group
      net/mlx5: Add hash table for flow groups in flow table
      net/mlx5: Add tracepoints

Saeed Mahameed (1):
      net/mlx5: Add a blank line after declarations V2

 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   5 +-
 .../net/ethernet/mellanox/mlx5/core/diag/Makefile  |   1 +
 .../mellanox/mlx5/core/diag/fs_tracepoint.c        | 261 ++++++++++++
 .../mellanox/mlx5/core/diag/fs_tracepoint.h        | 282 ++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 472 ++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |  23 +-
 include/linux/mlx5/device.h                        |   2 +-
 include/linux/mlx5/driver.h                        |   2 -
 11 files changed, 900 insertions(+), 156 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/diag/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/diag/fs_tracepoint.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/diag/fs_tracepoint.h
