From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/5] Trivial enhancements for cxgb4
Date: Mon, 21 Dec 2015 12:46:05 +0530
Message-ID: <1450682170-7106-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:33459 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750863AbbLUHOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 02:14:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This series adds a debug message if adapter isn't inserted in right PCI
slot, adds a debug entry to dump dcb information. Changes naming
conventions for iSCSI rx queues, use node info while allocating rx queue
and use napi_complete_done() api in napi handler. 

This patch series has been created against net-next tree and includes
patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks


Hariprasad Shenai (5):
  cxgb4: Warn if device doesn't have enough PCI bandwidth
  cxgb4: get naming correct for iscsi queues
  cxgb4: add dcb info node in debugfs
  cxgb4: Use the node info to alloc_ring() for RX queues
  cxgb4: Use napi_complete_done() api in napi handler

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  13 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c     |  11 --
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h     |  11 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 199 ++++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 133 +++++++++++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |   1 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  10 +-
 7 files changed, 324 insertions(+), 54 deletions(-)

-- 
2.3.4
