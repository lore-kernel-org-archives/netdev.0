From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 0/7] Update Kconfig and some fixes for cxgb4
Date: Tue,  8 Dec 2015 10:09:10 +0530
Message-ID: <1449549557-16023-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:5690 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756118AbbLHEiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 23:38:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This series update Kconfig to add description for Chelsio's next
generation T6 family of adapters, also fixes ethtool stats alignment
and prevents simultaneous execution of service_ofldq thread, deals with
queue wrap around and adds some fl counters for debugging purpose and
device ID for new T5 adapters.

This patch series has been created against net-next tree and includes
patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

V2: Declare 'service_ofldq_running' as bool in Patch 4/7 ("cxgb4: prevent
    simultaneous execution of service_ofldq()") based on review comment
    by David Miller

Hariprasad Shenai (7):
  cxgb4: Align rest of the ethtool get stats
  cxgb4/cxgb4vf: update Kconfig file to include T6 adapter
  cxgb4: Use ACCES_ONCE macro to read queue's consumer index
  cxgb4: prevent simultaneous execution of service_ofldq()
  cxgb4: Deal with wrap-around of queue for Work request
  cxgb4: Add FL DMA mapping error and low counter
  cxgb4: Adds PCI device id for new T5 adapters

 drivers/net/ethernet/chelsio/Kconfig               |  17 +--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   3 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   6 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 146 ++++++++++-----------
 drivers/net/ethernet/chelsio/cxgb4/sge.c           | 120 +++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h |   3 +
 6 files changed, 202 insertions(+), 93 deletions(-)

-- 
2.3.4
