From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/4]  Use new BAR2 GTS for T5, adds adaptive rx and few Device ID's
Date: Fri, 26 Sep 2014 00:23:51 +0530
Message-ID: <1411671235-6527-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, santosh@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:50757
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750889AbaIYSsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 14:48:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds support to use new BAR2 GTS for T5 adapter.
Adds support for adaptive rx. Remove redundant variable from a macro of
cxgb4vf driver. Adds Device ID for new adapters.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 and cxgb4vf driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks 

Hariprasad Shenai (4):
  cxgb4: Use BAR2 Going To Sleep (GTS) for T5 and later.
  cxgb4vf: Remove superfluous "idx" parameter of CH_DEVICE() macro.
  cxgb4/cxgb4vf: Add Devicde ID for two more adapter
  cxgb4: Add support for adaptive rx

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    5 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   28 +++
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  210 ++++++++++++++++----
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   20 ++
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  106 +++++-----
 6 files changed, 274 insertions(+), 96 deletions(-)
