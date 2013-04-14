From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/3] freescale: Update logging style
Date: Sat, 13 Apr 2013 22:03:16 -0700
Message-ID: <cover.1365915548.git.joe@perches.com>
Cc: Fabio Estevam <festevam@gmail.com>, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert various printk logging styles to current styles.

Uncompiled, untested.

Joe Perches (3):
  fec: Convert printks to netdev_<level>
  gianfar: Use netdev_<level> when possible
  ucc_geth: Convert ugeth_<level> to pr_<level>

 drivers/net/ethernet/freescale/fec_main.c         |  26 +-
 drivers/net/ethernet/freescale/fec_mpc52xx.c      |  16 +-
 drivers/net/ethernet/freescale/fec_ptp.c          |   2 +
 drivers/net/ethernet/freescale/gianfar_ethtool.c  |  24 +-
 drivers/net/ethernet/freescale/gianfar_ptp.c      |   3 +
 drivers/net/ethernet/freescale/gianfar_sysfs.c    |   2 +-
 drivers/net/ethernet/freescale/ucc_geth.c         | 881 ++++++++++------------
 drivers/net/ethernet/freescale/ucc_geth_ethtool.c |  24 +-
 8 files changed, 441 insertions(+), 537 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty
