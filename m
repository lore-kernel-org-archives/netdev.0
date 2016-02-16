From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/6] Mellanox 10/40G mlx4 driver fixes for 4.5-rc
Date: Tue, 16 Feb 2016 17:01:45 +0200
Message-ID: <1455634911-31206-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:59309 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932229AbcBPPCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 10:02:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Bunch of fixes from the team to the mlx4 Eth and core drivers.

Series generated against net commit db92ea5 "dscc4: Undefined signed int shift"

Or.

Amir Vadai (1):
  net/mlx4_en: Do not count dropped packets twice

Daniel Jurgens (1):
  net/mlx4_core: Do not BUG_ON during reset when PCI is offline

Eran Ben Elisha (1):
  net/mlx4_core: Fix potential corruption in counters database

Eugenia Emantayev (2):
  net/mlx4_en: Choose time-stamping shift value according to HW frequency
  net/mlx4_en: Avoid changing dev->features directly in run-time

Huy Nguyen (1):
  net/mlx4_core: Set UAR page size to 4KB regardless of system page size

 drivers/infiniband/hw/mlx4/qp.c                    |  7 ++-
 drivers/net/ethernet/mellanox/mlx4/catas.c         | 11 ++++-
 drivers/net/ethernet/mellanox/mlx4/cq.c            |  4 +-
 drivers/net/ethernet/mellanox/mlx4/en_clock.c      | 25 +++++++---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  9 ++--
 drivers/net/ethernet/mellanox/mlx4/en_port.c       |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_resources.c  |  3 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |  4 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c            |  7 +--
 drivers/net/ethernet/mellanox/mlx4/main.c          | 56 +++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/pd.c            | 12 +++--
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 10 ++--
 include/linux/mlx4/device.h                        | 13 +++++
 13 files changed, 124 insertions(+), 39 deletions(-)

-- 
2.3.7
