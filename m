From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 0/8] Mellanox mlx5 fixes 2017-03-21
Date: Tue, 21 Mar 2017 15:59:11 +0200
Message-ID: <20170321135919.25018-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38150 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757547AbdCUN7y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 09:59:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains some mlx5 core and ethernet driver fixes.

For -stable:
net/mlx5e: Count LRO packets correctly (for kernel >= 4.2)
net/mlx5e: Count GSO packets correctly (for kernel >= 4.2)
net/mlx5: Increase number of max QPs in default profile (for kernel >= 4.0)
net/mlx5e: Avoid supporting udp tunnel port ndo for VF reps (for kernel >= 4.10)
net/mlx5e: Use the proper UAPI values when offloading TC vlan actions (for kernel >= v4.9)
net/mlx5: E-Switch, Don't allow changing inline mode when flows are configured (for kernel >= 4.10)
net/mlx5e: Change the TC offload rule add/del code path to be per NIC or E-Switch (for kernel >= 4.10)
net/mlx5: Add missing entries for set/query rate limit commands (for kernel >= 4.8)

Thanks,
Saeed.

Gal Pressman (2):
  net/mlx5e: Count GSO packets correctly
  net/mlx5e: Count LRO packets correctly

Maor Gottlieb (1):
  net/mlx5: Increase number of max QPs in default profile

Or Gerlitz (3):
  net/mlx5: Add missing entries for set/query rate limit commands
  net/mlx5e: Change the TC offload rule add/del code path to be per NIC
    or E-Switch
  net/mlx5e: Use the proper UAPI values when offloading TC vlan actions

Paul Blakey (1):
  net/mlx5e: Avoid supporting udp tunnel port ndo for VF reps

Roi Dayan (1):
  net/mlx5: E-Switch, Don't allow changing inline mode when flows are
    configured

 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |  4 ++
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  4 --
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  8 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |  2 -
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  4 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 74 +++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |  5 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  6 ++
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 22 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  2 +-
 10 files changed, 94 insertions(+), 37 deletions(-)

-- 
2.11.0
