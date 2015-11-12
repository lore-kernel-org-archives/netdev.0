From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/6] Mellanox NIC driver update, Nov 12, 2015
Date: Thu, 12 Nov 2015 19:35:24 +0200
Message-ID: <1447349730-19832-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:46721 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752883AbbKLRfz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2015 12:35:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Few small mlx5 and mlx4 fixes from the team... done over
net commit c5a3788 "Merge branch 'akpm' (patches from Andrew)"

Eran's patch needs to go to 4.2 and 4.3 stable kernels.

Tariq's patch need to go to 4.3 stable too.

Or.

Achiad Shochat (1):
  net/mlx5e: Use the right DMA free function on TX path

Doron Tsur (1):
  net/mlx5e: Max mtu comparison fix

Eran Ben Elisha (1):
  net/mlx4_core: Fix sleeping while holding spinlock at rem_slave_counters

Noa Osherovich (1):
  net/mlx4_core: Avoid returning success in case of an error flow

Saeed Mahameed (1):
  net/mlx5e: Fix inline header size calculation

Tariq Toukan (1):
  net/mlx5e: Added self loopback prevention

 drivers/net/ethernet/mellanox/mlx4/main.c          |  8 ++-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 39 +++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en.h       | 10 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 50 ++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    | 76 +++++++++++++---------
 include/linux/mlx5/mlx5_ifc.h                      | 24 ++++---
 6 files changed, 148 insertions(+), 59 deletions(-)

-- 
2.3.7
