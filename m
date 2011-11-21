From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 0/8] net/mlx4 features and fixes
Date: Mon, 21 Nov 2011 10:43:18 +0200
Message-ID: <4ECA0F26.7000009@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<ogerlitz@mellanox.com>, <oren@mellanox.co.il>,
	<amirv@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:56915 "HELO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755522Ab1KULTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 06:19:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

This is a series of patches for mlx4_en driver.
synchronized the different commits into a single series.

Thanks,
Yevgeny

Or Gerlitz (3):
      net/mlx4: move RSS related definitions to be global
      net/mlx4: fix UDP RSS related settings
      net/mlx4_en: fix sparse warning on a cast which truncates bits from constant value

Yevgeny Petrilin (1):
      net/mlx4_en: using non collapsed CQ on TX

Oren Duer (1):
      net/mlx4_en: fix WOL handlers were always looking at port2, capability bit

Amir Vadai (3):
      net/mlx4_en: allow setting number of rx rings for, RSS/TCP
      net/mlx4_en: adding loopback support
      net/mlx4_en: bug fix for the case of vlan id 0 and UP 0

 drivers/net/ethernet/mellanox/mlx4/en_cq.c        |    7 --
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c   |   20 +++++
 drivers/net/ethernet/mellanox/mlx4/en_main.c      |    7 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |    1
 drivers/net/ethernet/mellanox/mlx4/en_resources.c |    2
 drivers/net/ethernet/mellanox/mlx4/en_rx.c        |   25 +++++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |   74 +++++++++++-----------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |   12 ---
 include/linux/mlx4/device.h                       |    3
 include/linux/mlx4/qp.h                           |   28 ++++++++
 10 files changed, 115 insertions(+), 64 deletions(-)
