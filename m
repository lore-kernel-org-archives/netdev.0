From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net 0/2] Mellanox driver fixes
Date: Mon,  2 Mar 2015 17:27:04 +0200
Message-ID: <1425310026-22993-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:33621 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755428AbbCBP1K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 10:27:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

Two small fixes, please apply to net.

Both patches should go to 3.19.y too.

thanks, 

Or.

changes from V1:
  - applied feedback from Sergei

Ido Shamay (1):
  net/mlx4_en: Disbale GRO for incoming loopback/selftest packets

Or Gerlitz (1):
  net/mlx4_core: Fix wrong mask and error flow for the update-qp
    command

 drivers/net/ethernet/mellanox/mlx4/en_selftest.c   |    8 +++++++-
 drivers/net/ethernet/mellanox/mlx4/qp.c            |    1 -
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    9 ++++++---
 include/linux/mlx4/qp.h                            |    2 +-
 4 files changed, 14 insertions(+), 6 deletions(-)
