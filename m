From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/2] mlx4 driver RC fixes
Date: Tue, 24 Mar 2015 15:18:37 +0200
Message-ID: <1427203119-27149-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49665 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752648AbbCXNSq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2015 09:18:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Ido's patch should go to -stable of >= 3.14 too, the issue is older but it
hits us with VXLAN for which driver support dates there.

As for Jack's fix, for the time being, picking it to 4.0 is OK.

Or.

Ido Shamay (1):
  net/mlx4_en: Call register_netdevice in the proper location

Jack Morgenstein (1):
  net/mlx4_core: Fix GEN_EQE accessing uninitialixed mutex

 drivers/net/ethernet/mellanox/mlx4/cmd.c           |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   15 ++++++++-------
 drivers/net/ethernet/mellanox/mlx4/eq.c            |   18 +++++++-----------
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    6 ++++++
 4 files changed, 22 insertions(+), 19 deletions(-)
