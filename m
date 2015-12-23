From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/9] Update support for T6 adapters
Date: Wed, 23 Dec 2015 22:47:10 +0530
Message-ID: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:1138 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751728AbbLWRP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 12:15:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This patch changes updates the various code changes related to
register, stats and hardware related changes for T6 family of
adapters.

This patch series has been created against net-next tree and includes
patches on cxgb4 and cxgb4vf driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (9):
  cxgb4: Pass correct argument to t4_link_l1cfg()
  cxgb4: Update pm_stats for T6 adapter family
  cxgb4/cxgb4vf: Update Ingress padding boundary values for T6 adapter
  cxgb4: Update register range and SGE registers for T6 adapter
  cxgb4: Update Congestion Channel map for T6 adapter
  cxgb4: Update correct encoding of SGE Ingress DMA States for T6
    adapter
  cxgb4: Update mps_tcam output to include T6 fields
  cxgb4: Update SGE context congestion map change for T6 adapter
  cxgb4vf: Update to 128 byte mailbox size for T6 adapter

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   3 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 130 ++++++++++++++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   5 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  55 +++----
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 162 +++++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |   1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  27 ++++
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h     |   3 +
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |  11 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_defs.h   |   1 +
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |  11 +-
 12 files changed, 338 insertions(+), 73 deletions(-)

-- 
2.3.4
