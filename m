From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 00/12] Mellanox 100G mlx5 fixes 28-12-2016
Date: Wed, 28 Dec 2016 14:58:30 +0200
Message-ID: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32807 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751693AbcL1M7B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 07:59:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Some fixes for mlx5 core and ethernet driver.

for -stable:
    net/mlx5: Check FW limitations on log_max_qp before setting it
    net/mlx5: Cancel recovery work in remove flow
    net/mlx5: Avoid shadowing numa_node
    net/mlx5: Mask destination mac value in ethtool steering rules
    net/mlx5: Prevent setting multicast macs for VFs
    net/mlx5e: Don't sync netdev state when not registered
    net/mlx5e: Disable netdev after close

Thanks,
Saeed.

Daniel Jurgens (1):
  net/mlx5: Cancel recovery work in remove flow

Eli Cohen (1):
  net/mlx5: Avoid shadowing numa_node

Gal Pressman (2):
  Revert "net/mlx5e: Expose PCIe statistics to ethtool"
  Revert "net/mlx5: Add MPCNT register infrastructure"

Huy Nguyen (1):
  net/mlx5e: Check ets capability before initializing ets settings

Maor Gottlieb (2):
  net/mlx5: Mask destination mac value in ethtool steering rules
  net/mlx5: Release FTE lock in error flow

Mohamad Haj Yahia (1):
  net/mlx5: Prevent setting multicast macs for VFs

Noa Osherovich (1):
  net/mlx5: Check FW limitations on log_max_qp before setting it

Or Gerlitz (1):
  net/mlx5: Disable RoCE on the e-switch management port under switchdev
    mode

Saeed Mahameed (2):
  net/mlx5e: Don't sync netdev state when not registered
  net/mlx5e: Disable netdev after close

 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c |  3 +
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 17 ----
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 51 ++++--------
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 32 +-------
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  2 +-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 11 +++
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 15 +++-
 include/linux/mlx5/device.h                        |  5 --
 include/linux/mlx5/driver.h                        |  1 -
 include/linux/mlx5/mlx5_ifc.h                      | 93 ----------------------
 12 files changed, 45 insertions(+), 187 deletions(-)

-- 
2.7.4
