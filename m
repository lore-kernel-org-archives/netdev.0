From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next v1 0/3] mlx4_en: set number of rx/tx channels using ethtool
Date: Thu, 29 Nov 2012 21:21:40 +0200
Message-ID: <1354216903-830-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Oren Duer <oren@mellanox.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:52350 "HELO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752133Ab2K2TWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 14:22:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Added a record in the MAINTAINERS file for the mlx4_en driver
2. Fix set_ringparam not to forget tx moderation info + remove code duplication
3. Add support to changing number of rx/tx channels using ethtool

---

Changes from V0:
- Added file pattern to MAINAINERS file

Amir Vadai (3):
  MAINTAINERS: Add Mellanox ethernet driver - mlx4_en
  net/mlx4_en: Fix TX moderation info loss after set_ringparam is
    called
  net/mlx4_en: Set number of rx/tx channels using ethtool

 MAINTAINERS                                     |    8 ++
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  128 +++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/en_main.c    |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |   26 +++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      |    2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    8 ++-
 6 files changed, 131 insertions(+), 43 deletions(-)

-- 
1.7.8.2
