From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 0/5] mlx4 misc fixes
Date: Thu, 29 Dec 2016 18:37:08 +0200
Message-ID: <1483029433-3624-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51879 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752881AbcL2Qh6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 11:37:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains several bug fixes from the team to the
mlx4 Eth and Core drivers.

Series generated against net commit:
60133867f1f1 'net: wan: slic_ds26522: fix spelling mistake: "configurated" -> "configured"'

Thanks,
Tariq.

Eugenia Emantayev (1):
  net/mlx4_en: Fix bad WQE issue

Jack Morgenstein (2):
  net/mlx4_core: Use-after-free causes a resource leak in flow-steering
    detach
  net/mlx4_core: Fix raw qp flow steering rules under SRIOV

Leon Romanovsky (1):
  net/mlx4: Remove BUG_ON from ICM allocation routine

Slava Shwartsman (1):
  net/mlx4_en: Fix type mismatch for 32-bit systems

 drivers/infiniband/hw/mlx4/main.c                  | 14 +++++++++--
 drivers/net/ethernet/mellanox/mlx4/en_clock.c      |  8 ++-----
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |  8 ++++++-
 drivers/net/ethernet/mellanox/mlx4/icm.c           |  7 +++++-
 drivers/net/ethernet/mellanox/mlx4/main.c          | 18 ++++++++++++++
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 28 ++++------------------
 include/linux/mlx4/device.h                        |  2 ++
 7 files changed, 52 insertions(+), 33 deletions(-)

-- 
1.8.3.1
