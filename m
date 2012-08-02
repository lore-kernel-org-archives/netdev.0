From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 0/4] net/mlx4: Fixes to mlx4 driver
Date: Thu,  2 Aug 2012 18:30:52 +0300
Message-ID: <1343921456-19180-1-git-send-email-yevgenyp@mellanox.co.il>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:60828 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752435Ab2HBPbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 11:31:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

This is a patchset of 3 fixes and additional change that removes
a port Link layer type restriction that is no longer relevant.

Thanks,
Yevgeny
---
Yevgeny Petrilin (3):
  net/mlx4_en: Setting the NETIF_F_GRO flag back to dev->hw_features
  net/mlx4_en: Fixing TX queue stop/wake flow
  net/mlx4_core: Remove port type restrictions

Amir Vadai (1):
  net/mlx4_en: loopbacked packets are dropped when SMAC=DMAC

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    3 ++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |    4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |   17 +++++++----------
 drivers/net/ethernet/mellanox/mlx4/main.c      |    3 ---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    1 -
 drivers/net/ethernet/mellanox/mlx4/sense.c     |   14 --------------
 6 files changed, 11 insertions(+), 31 deletions(-)
