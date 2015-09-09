From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 0/4] net: a few kzalloc/memset cleanups
Date: Wed,  9 Sep 2015 10:38:01 +0200
Message-ID: <1441787886-7214-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These are just a few k[czm]alloc/memset related cleanups.

Rasmus Villemoes (4):
  net: cavium: liquidio: use kzalloc in setup_glist()
  net: jme: use kzalloc() instead of kmalloc+memset
  net: mv643xx_eth: use kzalloc
  net: qlcnic: delete redundant memsets

 drivers/net/ethernet/cavium/liquidio/lio_main.c          | 3 +--
 drivers/net/ethernet/jme.c                               | 8 ++------
 drivers/net/ethernet/marvell/mv643xx_eth.c               | 5 +----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c      | 2 --
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c          | 2 --
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c | 2 --
 6 files changed, 4 insertions(+), 18 deletions(-)

-- 
2.1.3
