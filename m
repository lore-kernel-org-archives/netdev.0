From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 0/6] Mellanox Ethernet driver updates 2013-01-16
Date: Thu, 17 Jan 2013 13:47:15 +0200
Message-ID: <1358423241-2452-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:60812 "HELO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752064Ab3AQMdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 07:33:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

These are all small bug fixes to the Mellanox mlx4 driver, patches done against
net-next commit d59577b "sk-filter: Add ability to lock a socket filter program"

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
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |    9 +++-
 drivers/net/ethernet/mellanox/mlx4/main.c      |    7 ++-
 3 files changed, 50 insertions(+), 21 deletions(-)

-- 
1.7.8.2
