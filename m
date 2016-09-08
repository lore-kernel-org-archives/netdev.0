From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 0/9] mlx4 fixes
Date: Thu,  8 Sep 2016 11:51:52 +0300
Message-ID: <1473324721-5206-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55566 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932219AbcIHIw7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 04:52:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains several bug fixes from the team to the
mlx4 Eth and core drivers.

Series generated against net commit:
9dd4aaef194e "MAINTAINERS: Update CPMAC email address"

Please push the following patch to -stable  >= 4.6 as well:
"net/mlx4_core: Fix to clean devlink resources"

Thanks,
Tariq.

Jack Morgenstein (1):
  net/mlx4_core: Fix deadlock when switching between polling and event
    fw commands

Kamal Heib (4):
  net/mlx4_en: Fix wrong indentation
  net/mlx4_en: Fix the return value of mlx4_en_dcbnl_set_all()
  net/mlx4_en: Fix the return value of mlx4_en_dcbnl_set_state()
  net/mlx4_core: Fix to clean devlink resources

Leon Romanovsky (1):
  net/mlx4_core: Use RCU to perform radix tree lookup for SRQ

Moshe Shemesh (1):
  net/mlx4_en: Fix panic on xmit while port is down

Tariq Toukan (2):
  net/mlx4_en: Add branch prediction hints in RX data-path
  net/mlx4_en: Fixes for DCBX

 drivers/net/ethernet/mellanox/mlx4/cmd.c       | 23 ++++++++---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c | 57 ++++++++++++++------------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 21 ++++------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 28 +++++++------
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 12 +++---
 drivers/net/ethernet/mellanox/mlx4/main.c      |  3 ++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |  2 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   | 15 ++-----
 drivers/net/ethernet/mellanox/mlx4/port.c      |  4 +-
 drivers/net/ethernet/mellanox/mlx4/srq.c       | 14 +++----
 10 files changed, 92 insertions(+), 87 deletions(-)

-- 
1.8.3.1
