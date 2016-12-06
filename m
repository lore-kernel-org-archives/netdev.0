From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V2 0/6] Mellanox 100G mlx5 fixes 2016-12-04
Date: Tue,  6 Dec 2016 17:32:42 +0200
Message-ID: <1481038368-29677-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55467 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752900AbcLFPdk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 10:33:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Some bug fixes for mlx5 core and mlx5e driver.

v1->v2:
 - replace "uint" with "unsigned int"

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
