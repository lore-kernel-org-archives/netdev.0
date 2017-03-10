From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 0/5] Mellanox mlx5 fixes 2017-03-09
Date: Fri, 10 Mar 2017 14:33:00 +0200
Message-ID: <20170310123305.2185-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38672 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S937027AbdCJMdX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 07:33:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains some mlx5 core and ethernet driver fixes.

For -stable:
net/mlx5e: remove IEEE/CEE mode check when setting DCBX mode (for kernel >= 4.10)
net/mlx5e: Avoid wrong identification of rules on deletion (for kernel >= 4.9)
net/mlx5: Don't save PCI state when PCI error is detected (for kernel >= 4.9)
net/mlx5: Fix create autogroup prev initializer (for kernel >=4.9)

Thanks,
Saeed.

Daniel Jurgens (1):
  net/mlx5: Don't save PCI state when PCI error is detected

Eugenia Emantayev (1):
  net/mlx5e: Fix loopback selftest

Huy Nguyen (1):
  net/mlx5e: remove IEEE/CEE mode check when setting DCBX mode

Or Gerlitz (1):
  net/mlx5e: Avoid wrong identification of rules on deletion

Paul Blakey (1):
  net/mlx5: Fix create autogroup prev initializer

 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 10 +++----
 .../net/ethernet/mellanox/mlx5/core/en_selftest.c  |  5 +---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 33 ++++++++++++----------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  5 ++--
 5 files changed, 28 insertions(+), 27 deletions(-)

-- 
2.11.0
