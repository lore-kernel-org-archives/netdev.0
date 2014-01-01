From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/2] net/mlx4: Mellanox driver update 01-01-2014
Date: Wed,  1 Jan 2014 15:05:35 +0200
Message-ID: <1388581537-4810-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38247 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753769AbaAANGJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jan 2014 08:06:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Happy new year,

This driver update contains some fixes to enhance the OOB user experience of
Mellanox driver.
Yuval added support in set_irq_affinity_hint().
Jenny reverted commit 90b1ebe "mlx4: set maximal number of default RSS queues "
that limited the number of rx rings to the hard coded number 8.

Patchset was applied and tested against commit: 21eb218 "net, sch: fix the typo
in register_qdisc()"

Thanks,
Amir

Eugenia Emantayev (1):
  net/mlx4: Revert "mlx4: set maximal number of default RSS queues"

Yuval Atias (1):
  net/mlx4_en: Use affinity hint

 drivers/infiniband/hw/mlx4/main.c              |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_cq.c     |  4 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 60 +++++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/eq.c        | 12 +++++-
 drivers/net/ethernet/mellanox/mlx4/main.c      |  5 +--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  1 +
 include/linux/mlx4/device.h                    |  2 +-
 7 files changed, 78 insertions(+), 8 deletions(-)

-- 
1.8.3.4
