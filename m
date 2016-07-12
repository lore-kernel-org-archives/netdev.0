From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 0/2] mlx5 tx timeout watchdog fixes
Date: Wed, 13 Jul 2016 00:06:58 +0300
Message-ID: <1468357620-27831-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40534 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750926AbcGLVHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 17:07:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch set provides two trivial fixes for the tx timeout series lately 
applied into net 4.7.

>From Daniel, detect stuck queues due to BQL
>From Mohamad, fix tx timeout watchdog false alarm

Hopefully those two fixes will make it to -stable, assuming 
3947ca185999 ('net/mlx5e: Implement ndo_tx_timeout callback') was also backported to -stable.

Thanks,
Saeed.

Daniel Jurgens (1):
  net/mlx5e: Fix TX Timeout to detect queues stuck on BQL

Mohamad Haj Yahia (1):
  net/mlx5e: start/stop all tx queues upon open/close netdev

 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

-- 
2.8.0
