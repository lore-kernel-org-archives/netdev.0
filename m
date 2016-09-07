From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 0/5] Mellanox 100G mlx5 fixes 2016-09-07
Date: Wed,  7 Sep 2016 19:07:56 +0300
Message-ID: <1473264481-20392-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:58434 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756132AbcIGQIg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 12:08:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The following series contains bug fixes for the mlx5e driver.

from Gal,
	- Static code checker cleanup (casting overflow)
	- Fix global PFC counter statistics reading
	- Fix HW LRO when vlan stripping is off

>From Bodong,
	- Deprecate old autoneg capability bit and use new one.

>From Tariq,
	- Fix xmit more counter race condition


For -stable:
('net/mlx5e: Fix parsing of vlan packets when updating lro header')

No conflicts are introduced with the mlx5 ongoing net-next submission.

Thanks,
Saeed.

Bodong Wang (1):
  net/mlx5e: Move an_disable_cap bit to a new position

Gal Pressman (3):
  net/mlx5e: Prevent casting overflow
  net/mlx5e: Fix global PFC counters replication
  net/mlx5e: Fix parsing of vlan packets when updating lro header

Tariq Toukan (1):
  net/mlx5e: Fix xmit_more counter race issue

 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  8 +++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 22 +++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |  2 +-
 include/linux/mlx5/mlx5_ifc.h                      |  5 +++--
 4 files changed, 24 insertions(+), 13 deletions(-)

-- 
2.7.4
