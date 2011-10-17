From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 0/7] mlx4_en: Data path optimizations and bug fix.
Date: Mon, 17 Oct 2011 22:16:16 +0200
Message-ID: <4E9C8D10.9020509@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:50182 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754371Ab1JQWXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 18:23:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

This series of patches presents a bug fix (VLAN table overflow),
some alignment optimizations for better HW performance, RXHASH support.
Updated driver version.

Patches are generated against net-next tree.


 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 -
 drivers/net/ethernet/mellanox/mlx4/en_port.c   |    6 ++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |   32 +++++++++++++++----------
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |    2 -
 drivers/net/ethernet/mellanox/mlx4/fw.c        |    1
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    9 ++++---
 drivers/net/ethernet/mellanox/mlx4/port.c      |   15 ++++++-----
 include/linux/mlx4/device.h                    |    1
 8 files changed, 44 insertions(+), 24 deletions(-)


Thanks,
Yevgeny
