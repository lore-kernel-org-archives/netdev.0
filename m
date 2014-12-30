From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/2] mlx4 driver fixes for 3.19-rc2
Date: Tue, 30 Dec 2014 11:59:48 +0200
Message-ID: <1419933590-9718-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	talal@labmailer.mlnx, Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36428 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751756AbaL3KAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Dec 2014 05:00:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

Please push Maor's patch to -stable >= 3.17

Jack's fixes error-flow issues introduced in 3.19-rc1, no need for -stable.

thanks and EOY happy-holidays,

Or.

Jack Morgenstein (1):
  net/mlx4_core: Fix error flow in mlx4_init_hca()

Maor Gottlieb (1):
  net/mlx4_core: Correcly update the mtt's offset in the MR re-reg flow

 drivers/net/ethernet/mellanox/mlx4/main.c |   13 ++++---------
 drivers/net/ethernet/mellanox/mlx4/mr.c   |    9 +++++----
 2 files changed, 9 insertions(+), 13 deletions(-)
