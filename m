From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/2] mlx4 driver fixes for 3.19-rc1
Date: Sun, 14 Dec 2014 16:18:03 +0200
Message-ID: <1418566685-9855-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60962 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750782AbaLNOSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Dec 2014 09:18:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

Just fixes for two small issues introduced in the 3.19 merge window

Or.

Matan Barak (1):
  net/mlx4_core: Fixed memory leak and incorrect refcount in mlx4_load_one

Or Gerlitz (1):
  net/mlx4_core: Avoid double dumping of the PF device capabilities

 drivers/net/ethernet/mellanox/mlx4/fw.c   |   26 +++++++-----
 drivers/net/ethernet/mellanox/mlx4/fw.h   |    1 +
 drivers/net/ethernet/mellanox/mlx4/main.c |   62 ++++++++++++++++-------------
 3 files changed, 50 insertions(+), 39 deletions(-)
