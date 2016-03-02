From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/3] Mellanox 10/40G mlx4 driver fixes for 4.5-rc6
Date: Wed,  2 Mar 2016 17:47:43 +0200
Message-ID: <1456933666-28949-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:48322 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754997AbcCBPsU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 10:48:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains two fixes for the SRIOV HW LAG that was 
introduced in 4.5-rc1 and one fix that allows to revoke the 
administrative MAC that was assigned to VF through the PF.

The VF mac fix needs to go for stable too.

Or.


Jack Morgenstein (2):
  net/mlx4_core: Fix lockdep warning in handling of mac/vlan tables
  net/mlx4_core: Allow resetting VF admin mac to zero

Moni Shoua (1):
  net/mlx4_core: Check the correct limitation on VFs for HA mode

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c      | 14 +++++++++++---
 drivers/net/ethernet/mellanox/mlx4/port.c      | 20 ++++++++++----------
 3 files changed, 22 insertions(+), 14 deletions(-)

-- 
2.3.7
