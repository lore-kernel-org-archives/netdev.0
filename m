From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/7] mlx4: Extend statistics gathering and display
Date: Mon, 30 Mar 2015 17:45:19 +0300
Message-ID: <1427726726-27516-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Hadar Har-Zion <hadarh@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50859 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753727AbbC3OqY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 10:46:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series from Eran and Matan extends the statistics collected and later 
reported to the user via ethtool for native mode and SRIOV PF.

More Packet statistics, PFC statistics and global pause statistics 
are now displayed via ethtool.

Or.

Eran Ben Elisha (6):
  net/mlx4_en: Fix port counters statistics bitmask
  net/mlx4_en: Create new header file for all statistics info
  net/mlx4_en: Move statistics bitmap setting to the Ethernet driver
  net/mlx4_en: Support general selective view of ethtool statistics
  net/mlx4_en: Protect access to the statistics bitmap
  net/mlx4_en: Moderate ethtool callback to show more statistics

Matan Barak (1):
  net/mlx4_en: Add Flow control statistics display via ethtool

 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c  |    4 +
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  225 +++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |   88 +++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_port.c    |  182 +++++++++++++++----
 drivers/net/ethernet/mellanox/mlx4/fw.c         |   10 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |   55 ++----
 drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h |  107 +++++++++++
 drivers/net/ethernet/mellanox/mlx4/port.c       |   22 +--
 include/linux/mlx4/device.h                     |    4 +-
 9 files changed, 546 insertions(+), 151 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
