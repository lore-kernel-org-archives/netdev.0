From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 0/4] Trivial enhancements for cxgb4
Date: Wed, 23 Dec 2015 11:29:52 +0530
Message-ID: <1450850396-24141-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:10243 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753519AbbLWF6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 00:58:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This series adds a debug message if adapter isn't inserted in right PCI
slot. Changes naming conventions for iSCSI rx queues, use node info while
allocating rx queue and use napi_complete_done() api in napi handler.

This patch series has been created against net-next tree and includes
patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

V2: Dropped 'dcb_info' debug entry patch, since the same can be achieved
    using lldp tool.
    Based on review comments by Or Gerlitz <gerlitz.or@gmail.com> and
    David Miller.

Hariprasad Shenai (4):
  cxgb4: Warn if device doesn't have enough PCI bandwidth
  cxgb4: get naming correct for iscsi queues
  cxgb4: Use the node info to alloc_ring() for RX queues
  cxgb4: Use napi_complete_done() api in napi handler

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  13 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   8 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 133 ++++++++++++++++-----
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  10 +-
 4 files changed, 121 insertions(+), 43 deletions(-)

-- 
2.3.4
