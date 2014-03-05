From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/5] samsung: xgmac:
Date: Wed,  5 Mar 2014 11:20:14 -0800
Message-ID: <cover.1394046997.git.joe@perches.com>
Cc: linux-samsung-soc@vger.kernel.org, davem@davemloft.net,
	siva.kallam@samsung.com, vipul.pandya@samsung.com,
	ks.giri@samsung.com, ilho215.lee@samsung.com,
	netdev@vger.kernel.org
To: Byungho An <bh74.an@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0238.hostedemail.com ([216.40.44.238]:44796 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756338AbaCETUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 14:20:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mostly neatening and logging cleanups on top of the initial submittal.

Joe Perches (5):
  samsung: xgmac: Neatening
  samsung: xgmac: Fix pr_<level> uses
  samsung: xgmac: Use more current logging style
  samsung: xgmac: Neaten comments
  samsung: xgmac: Mostly whitespace neatening

 drivers/net/ethernet/samsung/xgmac_common.h   |  56 ++--
 drivers/net/ethernet/samsung/xgmac_core.c     |  28 +-
 drivers/net/ethernet/samsung/xgmac_desc.c     |  39 ++-
 drivers/net/ethernet/samsung/xgmac_desc.h     |  16 +-
 drivers/net/ethernet/samsung/xgmac_dma.c      |  49 ++--
 drivers/net/ethernet/samsung/xgmac_dma.h      |  12 +-
 drivers/net/ethernet/samsung/xgmac_ethtool.c  |  95 ++++---
 drivers/net/ethernet/samsung/xgmac_main.c     | 389 +++++++++++++-------------
 drivers/net/ethernet/samsung/xgmac_mdio.c     |  58 ++--
 drivers/net/ethernet/samsung/xgmac_mtl.c      |  15 +-
 drivers/net/ethernet/samsung/xgmac_mtl.h      |  14 +-
 drivers/net/ethernet/samsung/xgmac_platform.c |  45 +--
 drivers/net/ethernet/samsung/xgmac_reg.h      | 190 ++++++-------
 13 files changed, 502 insertions(+), 504 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty
