From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/7] mlx5 Ethernet driver update - Jun 11 2015
Date: Thu, 11 Jun 2015 14:47:26 +0300
Message-ID: <1434023253-24362-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47260 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752535AbbFKLr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 07:47:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series from Saeed, Achiad and Gal contains few fixes
to the recently introduced mlx5 Ethernet functionality.

Or.

Achiad Shochat (2):
  net/mlx5_core: Add transport domain alloc/dealloc support
  net/mlx5e: Add transport domain to the ethernet TIRs/TISs

Gal Pressman (1):
  net/mlx5e: Enforce max flow-tables level >= 3

Saeed Mahameed (4):
  net/mlx5e: Fix HW MTU settings
  net/mlx5e: Add HW cacheline start padding
  net/mlx5e: Disable client vlan TX acceleration
  net/mlx5e: Support NETIF_F_SG

 drivers/infiniband/hw/mlx5/main.c                  |    8 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |    5 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  112 ++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   10 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   58 ++++++----
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |   36 +++----
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c |   35 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/transobj.h |    2 +
 include/linux/mlx5/device.h                        |    4 +
 include/linux/mlx5/driver.h                        |   10 +-
 10 files changed, 166 insertions(+), 114 deletions(-)
