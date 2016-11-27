From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 00/10] mlx4 misc improvements
Date: Sun, 27 Nov 2016 17:51:07 +0200
Message-ID: <1480261877-19720-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50415 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753021AbcK0Pv3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 10:51:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains several improvements, cleanups, and bug fixes
from the team to the mlx4 Eth and core drivers.

Series generated against net-next commit:
e5f12b3f5ebb Merge branch 'mlxsw-trap-groups-and-policers'

Thanks,
Tariq.

Alaa Hleihel (1):
  net/mlx4_core: Get num_tc using netdev_get_num_tc

Daniel Jurgens (1):
  net/mlx4_core: Set EQ affinity hint to local NUMA CPUs

Eran Ben Elisha (1):
  net/mlx4_core: Dynamically allocate structs at mlx4_slave_cap

Erez Shitrit (2):
  net/mlx4_core: Make each VF manage its own mac table
  net/mlx4_en: Add new FDB entry only if there is space in the mac table

Jack Morgenstein (1):
  net/mlx4_core: Fix racy CQ (Completion Queue) free

Matan Barak (2):
  net/mlx4_core: Add resource alloc/dealloc debugging
  net/mlx4: Change number of max MSIXs from 64 to 1024

Tariq Toukan (1):
  net/mlx4: Replace ENOSYS with better fitting error codes

Yishai Hadas (1):
  net/mlx4_core: Device revision support

 drivers/net/ethernet/mellanox/mlx4/cq.c            |  38 ++--
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    |   4 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   6 +
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |   2 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |  17 +-
 drivers/net/ethernet/mellanox/mlx4/main.c          | 253 ++++++++++++---------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   1 +
 drivers/net/ethernet/mellanox/mlx4/port.c          |  98 +++++++-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  57 ++++-
 include/linux/mlx4/device.h                        |   4 +-
 10 files changed, 342 insertions(+), 138 deletions(-)

-- 
1.8.3.1
