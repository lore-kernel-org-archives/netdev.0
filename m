From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/4] cxgb4/cxgb4vf: T5 BAR2 and ethtool related fixes
Date: Wed,  3 Dec 2014 19:32:50 +0530
Message-ID: <1417615374-12961-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:57232
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750855AbaLCN5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 08:57:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series adds new interface to calculate BAR2 SGE queue register address for
cxgb4 and cxgb4vf driver and some more sge related fixes for T5. Also adds a
patch which updates the FW version displayed by ethtool after firmware flash. 

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 and cxgb4vf driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (4):
  cxgb4vf: Add and initialize some sge params for VF driver
  cxgb4/cxgb4vf: Add code to calculate T5 BAR2 Offsets for SGE Queue
    Registers
  cxgb4/cxgb4vf: Use new interfaces to calculate BAR2 SGE Queue
    Register addresses
  cxgb4: Update firmware version after flashing it via ethtool

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   25 +++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   60 +++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |    7 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  148 ++++++++--------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  122 +++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   22 ++-
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |    7 +
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   39 +++--
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |  185 +++++++++++++++++---
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |   19 ++-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |  173 ++++++++++++++++++
 11 files changed, 656 insertions(+), 151 deletions(-)
