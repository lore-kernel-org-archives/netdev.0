From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/7] Mellanox Ethernet driver updates 2013-01-16
Date: Wed, 16 Jan 2013 17:42:08 +0200
Message-ID: <1358350935-3281-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:58639 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755885Ab3APPm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 10:42:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

These are all small bug fixes to the Mellanox mlx4 driver, patches done against
net-next commit 757b8b1 "net_sched: fix qdisc_pkt_len_init()"

Thanks,
Amir

Amir Vadai (2):
  net/mlx4_en: Fix a race when closing TX queue
  net/mlx4_en: Initialize RFS filters lock and list in init_netdev

Aviad Yehezkel (1):
  net/mlx4_en: Fix traffic loss under promiscuous mode

Eugenia Emantayev (3):
  net/mlx4_en: Issue the dump eth statistics command under lock
  net/mlx4_en: Use the correct netif lock on ndo_set_rx_mode
  net/mlx4_en: Set carrier to off when a port is stopped

Jack Morgenstein (1):
  net/mlx4_core: Return proper error code when __mlx4_add_one fails

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   56 ++++++++++++++++--------
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |    9 +++-
 drivers/net/ethernet/mellanox/mlx4/main.c      |    7 ++-
 3 files changed, 51 insertions(+), 21 deletions(-)

-- 
1.7.8.2
