From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 0/6] Mellanox 100G mlx5 fixes 2016-12-04
Date: Sun,  4 Dec 2016 12:56:10 +0200
Message-ID: <1480848976-6797-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39409 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751126AbcLDK5F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 05:57:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Some bug fixes for mlx5 core and mlx5e driver.

Thanks,
Saeed.

Kamal Heib (3):
  net/mlx5: Verify module parameters
  net/mlx5: Remove duplicate pci dev name print
  net/mlx5: Fix query ISSI flow

Mohamad Haj Yahia (1):
  net/mlx5e: Change the SQ/RQ operational state to positive logic

Saeed Mahameed (2):
  net/mlx5e: Don't notify HW when filling the edge of ICO SQ
  net/mlx5e: Don't flush SQ on error

 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |  5 ---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  4 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 15 ++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  8 ++---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |  4 +--
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 42 +++++++++++++---------
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    | 15 +++++---
 8 files changed, 53 insertions(+), 42 deletions(-)

-- 
2.7.4
