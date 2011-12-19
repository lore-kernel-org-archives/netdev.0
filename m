From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 0/5] mlx4: link sensing changes and Fixes.
Date: Mon, 19 Dec 2011 16:00:17 +0200
Message-ID: <4EEF4371.6010605@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:39262 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750910Ab1LSQMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 11:12:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

This series presents link sensing logic changes (mostly for ConnectX3 devices)
and some fixes to the driver in addition to the SRIOV code we submitted lately.

Thanks,
Yevgeny

 drivers/net/ethernet/mellanox/mlx4/cmd.c              |   88 +++++++++++-------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |    2
 drivers/net/ethernet/mellanox/mlx4/fw.c               |    2
 drivers/net/ethernet/mellanox/mlx4/fw.h               |    2
 drivers/net/ethernet/mellanox/mlx4/main.c             |   60 ++++++++----
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |    4
 include/linux/mlx4/device.h                           |    5 -
 7 files changed, 110 insertions(+), 53 deletions(-)
 
