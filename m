From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 0/2] net/mlx4: Mellanox driver update 01-01-2014
Date: Fri, 21 Feb 2014 12:39:16 +0200
Message-ID: <1392979158-18093-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:58698 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752725AbaBUKjd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Feb 2014 05:39:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This small patchset has a fix to a bogus usage of
netif_get_num_default_rss_queues() in mlx4_en driver.

Changes from V1:
- Removed affinity_hint patch, to make it a generic instead of mlx specific

Changes from V0:
- Instead of reverting the netif_get_num_default_rss_queues() in mlx4_en,
  fixing it to limit the actual number of receive queues instead of limiting
  the number of IRQ's.

Patchset was applied and tested against commit: cb6e926 "ipv6:fix checkpatch
errors with assignment in if condition"

Thanks,
Amir

Ido Shamay (2):
  net/mlx4: Set number of RX rings in a utility function
  net/mlx4: Fix limiting number of IRQ's instead of RSS queues

 drivers/net/ethernet/mellanox/mlx4/en_main.c | 15 ++-------------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 25 +++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/main.c    |  3 +--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  2 +-
 4 files changed, 29 insertions(+), 16 deletions(-)

-- 
1.8.3.4
