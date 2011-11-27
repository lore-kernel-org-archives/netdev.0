From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH V2 0/7] net/mlx4 features and fixes
Date: Sun, 27 Nov 2011 07:54:51 +0200
Message-ID: <4ED1D0AB.5010804@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<ogerlitz@mellanox.com>, <oren@mellanox.co.il>,
	<amirv@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:56020 "HELO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752076Ab1K0ITp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 03:19:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

This is V2 ofa series of patches for mlx4_en driver.
synchronized the different commits into a single series.

The changes from initial commit:
1. loobback support patch: control flags are not set on data path.
2. Setting number of RSS rings patch was removed for rework following the review.

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

Amir Vadai (2):
      net/mlx4_en: adding loopback support
      net/mlx4_en: bug fix for the case of vlan id 0 and UP 0

 drivers/net/ethernet/mellanox/mlx4/en_cq.c        |    7 --
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c   |   20 +++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |   19 +++++
 drivers/net/ethernet/mellanox/mlx4/en_resources.c |    2
 drivers/net/ethernet/mellanox/mlx4/en_rx.c        |   16 ++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |   74 +++++++++++-----------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |   13 ---
 include/linux/mlx4/device.h                       |    3
 include/linux/mlx4/qp.h                           |   28 ++++++++
 9 files changed, 120 insertions(+), 62 deletions(-)
