From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 0/9] net/mlx4: Mellanox driver update 27-02-2014
Date: Sun,  2 Mar 2014 10:24:56 +0200
Message-ID: <1393748705-1685-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52983 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751661AbaCBIZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Mar 2014 03:25:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset contains some fixes for small trivial bugs, and
compilation/syntactic parsers warnings

Patchset was applied and tested over commit 750f679 "Merge branch '6lowpan'"

Changes from V1:
-patch 5/9:  Replace mlx4_en_mac_to_u64() with mlx4_mac_to_u64()
  - Remove unnecessary define of ETH_ALEN

Changes from V0:
-patch 3/9:  net/mlx4_en: Pad ethernet packets smaller than 17 bytes
  - Make condition more efficient
  - Didn't use canonical function to pad buffer since using bounce buffer

Thanks,
Amir

Amir Vadai (3):
  net/mlx4_en: Fix UP limit in ieee_ets->prio_tc
  net/mlx4_en: Fix selftest failing on non 10G link speed
  net/mlx4_en: Use union for BlueFlame WQE

Eugenia Emantayev (4):
  net/mlx4_en: Verify mlx4_en module parameters
  net/mlx4_en: Pad ethernet packets smaller than 17 bytes
  net/mlx4_en: Move queue stopped/waked counters to be per ring
  net/mlx4: Replace mlx4_en_mac_to_u64() with mlx4_mac_to_u64()

Eyal Perry (2):
  net/mlx4_core: Fix sparse warning
  net/mlx4_en: Change Connect-X description in kconfig

 drivers/net/ethernet/mellanox/mlx4/Kconfig       |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c   |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_main.c     | 30 +++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   | 32 +++++++-------------
 drivers/net/ethernet/mellanox/mlx4/en_port.c     |  6 ++++
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c |  6 ++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c       | 38 +++++++++++-------------
 drivers/net/ethernet/mellanox/mlx4/fw.c          |  3 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h     | 12 +++++++-
 include/linux/mlx4/driver.h                      | 12 ++++++++
 include/linux/mlx4/qp.h                          | 11 +++++--
 11 files changed, 102 insertions(+), 52 deletions(-)

-- 
1.8.3.4
