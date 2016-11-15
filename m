From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 0/8] Mellanox 100G mlx5 update 2016-11-15
Date: Tue, 15 Nov 2016 23:29:59 +0200
Message-ID: <1479245407-6884-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54814 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752875AbcKOVae (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 16:30:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains four humble mlx5 features.

from Gal, 
 - Add the support for PCIe statistics and expose them in ethtool

from Huy,
 - Add the support for port module events reporting and statistics
 - Add the support for driver version setting into FW (for display purposes only)

>From Mohamad,
 - Extended the command interface cache flexibility

This series was generated against commit
c915fe13cbaa ("udplite: fix NULL pointer dereference")

Thanks,
Saeed.

Gal Pressman (2):
  net/mlx5: Add MPCNT register infrastructure
  net/mlx5e: Expose PCIe statistics to ethtool

Huy Nguyen (4):
  net/mlx5: Port module event hardware structures
  net/mlx5: Add handling for port module event
  net/mlx5e: Add port module event counters to ethtool stats
  net/mlx5: Set driver version into firmware

Mohamad Haj Yahia (1):
  net/mlx5: Make the command interface cache more flexible

Saeed Mahameed (1):
  net/mlx5: Set driver version infrastructure

 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      | 145 ++++++++++-----------
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  40 +++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  24 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |  49 ++++++-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  12 ++
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  37 ++++++
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  57 ++++++++
 include/linux/mlx5/device.h                        |  16 +++
 include/linux/mlx5/driver.h                        |  42 +++++-
 include/linux/mlx5/mlx5_ifc.h                      | 118 ++++++++++++++++-
 include/linux/mlx5/port.h                          |   3 +
 12 files changed, 457 insertions(+), 87 deletions(-)

-- 
2.7.4
