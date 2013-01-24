From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 0/6] Mellanox Ethernet driver updates 2013-01-16
Date: Thu, 24 Jan 2013 13:54:13 +0200
Message-ID: <1359028459-30961-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:56463 "HELO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752956Ab3AXLyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 06:54:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

These are all small bug fixes to the Mellanox mlx4 driver, patches done against
net-next commit d59577b "sk-filter: Add ability to lock a socket filter program"

Changes from V1:
- added memory barrier to "Fix a race when closing TX queue"
- Fixed indentation

Changes from V0:
- Removed patch "Set carrier to off when a port is stopped"
  Need some time to make sure using netif_device_detach instead of
  netif_carrier_off, as suggested by Ben, won't break anything.

Thanks,
Amir

Amir Vadai (2):
  net/mlx4_en: Fix a race when closing TX queue
  net/mlx4_en: Initialize RFS filters lock and list in init_netdev

Aviad Yehezkel (1):
  net/mlx4_en: Fix traffic loss under promiscuous mode

Eugenia Emantayev (2):
  net/mlx4_en: Issue the dump eth statistics command under lock
  net/mlx4_en: Use the correct netif lock on ndo_set_rx_mode

Jack Morgenstein (1):
  net/mlx4_core: Return proper error code when __mlx4_add_one fails

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   55 ++++++++++++++++--------
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |   16 ++++++-
 drivers/net/ethernet/mellanox/mlx4/main.c      |    7 ++-
 3 files changed, 57 insertions(+), 21 deletions(-)

-- 
1.7.8.2
