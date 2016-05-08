From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 0/2] net/mlx5e: Kconfig fixes for VxLAN
Date: Sun,  8 May 2016 14:55:23 +0300
Message-ID: <1462708525-23545-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38981 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750735AbcEHL4W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2016 07:56:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reposting to net the build errors fixes posted by Arnd last week.

Originally Arnd posted those fixes to net-next, while the issue
is also seen in net.  For net-next a different approach is required 
for fixing the issue as VXLAN and Device Drivers are no longer
dependent, but there is no harm for those fixes to get into net-next.

Optionally, once net is merged into net-next we can 
Revert "net/mlx5e: make VXLAN support conditional" as the 
CONFIG_MLX5_CORE_EN_VXLAN will no longer be required.

Applied on top: 288928658583 ('mlxsw: spectrum: Add missing rollback in flood configuration')

Thanks,
Saeed.

Arnd Bergmann (2):
  Revert "net/mlx5: Kconfig: Fix MLX5_EN/VXLAN build issue"
  net/mlx5e: make VXLAN support conditional

 drivers/net/ethernet/mellanox/mlx5/core/Kconfig   |  8 +++++++-
 drivers/net/ethernet/mellanox/mlx5/core/Makefile  |  3 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  4 ++++
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.h   | 11 +++++++++--
 5 files changed, 24 insertions(+), 4 deletions(-)

-- 
2.8.0
