From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 0/7] Mellanox 100G mlx5 fixes#2 for 4.7-rc
Date: Mon, 27 Jun 2016 12:08:31 +0300
Message-ID: <1467018518-11630-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53195 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751673AbcF0JQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 05:16:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The following series provides one-liners fixes for mlx5 driver plus one
medium patch to reorganize ethtool counters reporting.

Highlights:
	- Added MODIFY_FLOW_TABLE to command strings table
	- Add ConnectX-5 PCIe 4.0 to list of supported devices
	- Rename ASYNC_EVENTS enum
	- Enable BlueFlame only when supported by device
	- Avoid adding same vxlan port twice
	- Report the correct number of PFC counters
	- Reorganize ethtool reported counters and remove duplications

Thanks,
Saeed.

Eli Cohen (2):
  net/mlx5: Update command strings
  net/mlx5e: Change enum to better reflect usage

Gal Pressman (3):
  net/mlx5e: Check for BlueFlame capability before allocating SQ uar
  net/mlx5e: Fix number of PFC counters reported to ethtool
  net/mlx5e: Reorganize ethtool statistics

Majd Dibbiny (1):
  net/mlx5: Add ConnectX-5 PCIe 4.0 to list of supported devices

Matthew Finlay (1):
  net/mlx5e: Prevent adding the same vxlan port

 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   2 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  34 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  35 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 228 +++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.c    |   3 +
 9 files changed, 144 insertions(+), 170 deletions(-)

-- 
2.8.0
