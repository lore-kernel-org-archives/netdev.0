From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net V1 0/4] mlx4 driver fixes for 4.0-rc
Date: Wed, 18 Mar 2015 16:51:34 +0200
Message-ID: <1426690298-10567-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49346 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752088AbbCROvl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2015 10:51:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

Just few small fixes for the 4.0 rc cycle.

The fix from Moni addresses an issue from 4.0-rc1 so we
just need it for net.

Eran's fix for off-by-one should go to 3.19.y too.

Or.

changes from V0:
  - addressed feedback from Sergei removed redundant defines 
    from the PMA patch

Eran Ben Elisha (2):
  net/mlx4_en: Fix off-by-one in ethtool statistics display
  net/mlx4_en: Set statistics bitmap at port init

Majd Dibbiny (1):
  IB/mlx4: Saturate RoCE port PMA counters in case of overflow

Moni Shoua (1):
  IB/mlx4: Verify net device validity on port change event

 drivers/infiniband/hw/mlx4/mad.c               |   20 ++++++++++++++++----
 drivers/infiniband/hw/mlx4/main.c              |    6 +++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    4 ++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    2 +-
 4 files changed, 24 insertions(+), 8 deletions(-)
