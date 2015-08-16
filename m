From: Achiad Shochat <achiad@mellanox.com>
Subject: [PATCH net-next 0/8] Driver updates 16-Aug-2015
Date: Sun, 16 Aug 2015 16:04:44 +0300
Message-ID: <1439730292-29617-1-git-send-email-achiad@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38364 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751237AbbHPNHA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Aug 2015 09:07:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains bug fixes, new RSS and pause parameters ethtool
options, and support for RX CHECKSUM_COMPLETE.

Patchset was applied and tested over commit adc6310 ("Merge branch
'mv88e6xxx-switchdev-fdb'").

Thanks,
Achiad

Achiad Shochat (8):
  net/mlx5e: Have a single RSS Toeplitz hash key
  net/mlx5e: Make RSS indirection table size a constant
  net/mlx5e: Add ethtool RSS configuration options
  net/mlx5e: Support smaller RX/TX ring sizes
  net/mlx5e: HW LRO changes/fixes
  net/mlx5e: Ethtool link speed setting fixes
  net/mlx5e: Support ethtool get/set_pauseparam
  net/mlx5e: Support RX CHECKSUM_COMPLETE

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  25 ++--
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 134 +++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  80 ++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  46 +++++--
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  56 ++++++++-
 include/linux/mlx5/driver.h                        |  16 ++-
 6 files changed, 266 insertions(+), 91 deletions(-)

-- 
1.8.3.1
