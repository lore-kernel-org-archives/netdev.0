From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/8] Mellanox driver update, Nov 1 2015
Date: Sun,  1 Nov 2015 19:35:14 +0200
Message-ID: <1446399322-14046-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:56258 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752698AbbKARfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Nov 2015 12:35:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains bunch of small fixes to the mlx5e driver from Achiad.

Applies on net-next commit e7b63ff "Merge branch 'master' of 
git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next"

Or.

Achiad Shochat (8):
  net/mlx5e: Avoid NULL pointer access in case of configuration failure
  net/mlx5e: Wait for RX buffers initialization in a more proper manner
  net/mlx5_core: Use the the real irqn in eq->irqn
  net/mlx5e: Consider IRQ affinity changes in NAPI poll
  net/mlx5e: Don't allow more than max supported channels
  net/mlx5e: Return error in case mlx5e_set_features() fails
  net/mlx5e: Re-eanble client vlan TX acceleration
  net/mlx5e: Fix LSO vlan insertion

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  9 ++++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  5 ++---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 17 +++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    | 26 +++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  | 12 +++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  8 +++----
 6 files changed, 61 insertions(+), 16 deletions(-)

-- 
2.3.7
