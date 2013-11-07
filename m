From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/6] net/mlx4: Mellanox driver update 07-11-2013
Date: Thu,  7 Nov 2013 12:19:48 +0200
Message-ID: <1383819594-24070-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:44663 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750859Ab3KGKUO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 05:20:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains some enhancements and bug fixes for the mlx4_* drivers.
Patchset was applied and tested against commit: "9bb8ca8 virtio-net: switch to
use XPS to choose txq"

Thanks,
Amir

Eugenia Emantayev (3):
  net/mlx4_en: Datapath resources allocated dynamically
  net/mlx4_core: ICM pages are allocated on device NUMA node
  net/mlx4_en: Datapath structures are allocated per NUMA node

Eyal Perry (1):
  net/mlx4_en: Add RFS support in UDP

Jack Morgenstein (1):
  net/mlx4_core: Initialize all mailbox buffers to zero before use

Rony Efraim (1):
  net/mlx4_core: Add immediate activate for VGT->VST->VGT

 drivers/infiniband/hw/mlx4/main.c                  |   6 -
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |  36 +++---
 drivers/net/ethernet/mellanox/mlx4/cq.c            |   6 -
 drivers/net/ethernet/mellanox/mlx4/en_cq.c         |  45 +++++--
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    |  36 +++---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     | 144 +++++++++++++--------
 drivers/net/ethernet/mellanox/mlx4/en_port.c       |  17 +--
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |  68 +++++++---
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c   |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |  54 ++++++--
 drivers/net/ethernet/mellanox/mlx4/eq.c            |   1 -
 drivers/net/ethernet/mellanox/mlx4/fw.c            |   7 -
 drivers/net/ethernet/mellanox/mlx4/icm.c           |  42 ++++--
 drivers/net/ethernet/mellanox/mlx4/main.c          |   1 +
 drivers/net/ethernet/mellanox/mlx4/mcg.c           |   2 -
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |  33 ++---
 drivers/net/ethernet/mellanox/mlx4/mr.c            |   5 -
 drivers/net/ethernet/mellanox/mlx4/pd.c            |  11 +-
 drivers/net/ethernet/mellanox/mlx4/port.c          |  11 --
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  79 +++++++++--
 drivers/net/ethernet/mellanox/mlx4/srq.c           |   2 -
 include/linux/mlx4/device.h                        |   3 +-
 22 files changed, 383 insertions(+), 228 deletions(-)

-- 
1.8.3.4
