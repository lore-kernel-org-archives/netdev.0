From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/8] net/mlx5e: Driver update 29-Jul-2015
Date: Wed, 29 Jul 2015 15:05:38 +0300
Message-ID: <1438171546-17021-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53782 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751000AbbG2MGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 08:06:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contain bug fixes and code cleaning patches to the ConnectX-4
Ethernet driver.

Patchset was applied and tested over commit 8c1a91f ("Merge branch
'mlx4-802.1ad-accel'")

Thanks,
Amir

Achiad Shochat (7):
  net/mlx5e: Use hard-coded 4K page size for RQ/SQ/CQ
  net/mlx5e: Remove redundant field mlx5e_priv->num_tc
  net/mlx5e: Remove redundant assignment of sq->user_index
  net/mlx5e: Avoid redundant de-reference
  net/mlx5e: Do not use netdev_err() before the netdev is registered
  net/mlx5e: Introduce create/destroy RSS indir table access functions
  net/mlx5e: Remove the mlx5e_update_priv_params() function

Haggai Abramonvsky (1):
  net/mlx5_core: Check the return value of mlx5_command_exec()

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   3 -
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  63 +++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 119 ++++++++-------------
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   7 +-
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c |  29 +++++
 drivers/net/ethernet/mellanox/mlx5/core/transobj.h |   4 +
 6 files changed, 124 insertions(+), 101 deletions(-)

-- 
2.4.3.413.ga5fe668
