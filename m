From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net 00/11] Mellanox, mlx5 fixes 2017-09-28
Date: Thu, 28 Sep 2017 07:41:21 +0300
Message-ID: <20170928044132.30940-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54344 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750891AbdI1EmE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 00:42:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series provides misc fixes for mlx5 dirver.

Please pull and let me know if there's any problem.

for -stable:
  net/mlx5e: IPoIB, Fix access to invalid memory address (Kernels >= 4.12)

Thanks,
Saeed.

-- 

The following changes since commit c2cc187e53011c1c4931055984657da9085c763b:

  sctp: Fix a big endian bug in sctp_diag_dump() (2017-09-26 21:16:29 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-fixes-2017-09-28

for you to fetch changes up to 353f59f4d41e9c5798a15c5c52958f25b579a3d5:

  net/mlx5: Fix wrong indentation in enable SRIOV code (2017-09-28 07:23:10 +0300)

----------------------------------------------------------------
mlx5-fixes-2017-09-28

Misc. fixes for mlx5 drivers.

----------------------------------------------------------------
Gal Pressman (3):
      net/mlx5e: Print netdev features correctly in error message
      net/mlx5e: Don't add/remove 802.1ad rules when changing 802.1Q VLAN filter
      net/mlx5e: Fix calculated checksum offloads counters

Inbar Karmy (1):
      net/mlx5: Fix FPGA capability location

Matan Barak (1):
      net/mlx5: Fix static checker warning on steering tracepoints code

Or Gerlitz (2):
      net/mlx5e: Disallow TC offloading of unsupported match/action combinations
      net/mlx5: Fix wrong indentation in enable SRIOV code

Paul Blakey (1):
      net/mlx5e: Fix erroneous freeing of encap header buffer

Raed Salem (1):
      net/mlx5: Check device capability for maximum flow counters

Roi Dayan (1):
      net/mlx5e: IPoIB, Fix access to invalid memory address

Vlad Buslov (1):
      net/mlx5e: Check encap entry state when offloading tunneled flows

 .../mellanox/mlx5/core/diag/fs_tracepoint.h        |  4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 13 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  3 +
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |  6 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 91 ++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c |  4 +-
 drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.h |  2 +-
 .../net/ethernet/mellanox/mlx5/core/fpga/core.c    |  3 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  8 ++
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  | 11 +++
 .../net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c  |  3 +-
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c    |  2 +-
 include/linux/mlx5/device.h                        |  5 +-
 include/linux/mlx5/driver.h                        |  1 +
 include/linux/mlx5/mlx5_ifc.h                      |  3 +-
 17 files changed, 133 insertions(+), 31 deletions(-)
