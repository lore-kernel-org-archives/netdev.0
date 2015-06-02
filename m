From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/3] cxgb4/cxgb4vf: Adds support for Chelsio T6 adapter
Date: Tue,  2 Jun 2015 06:32:02 +0530
Message-ID: <1433206925-5997-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:30791 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752245AbbFATtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 15:49:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds the following:
Adds NIC driver support for T6 adapter
Adds vNIC driver support for T6 adapter

This patch series has been created against net-next tree and includes
patches on cxgb4 and cxgb4vf driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (3):
  cxgb4: Add is_t6 macro and T6 register ranges
  cxgb4: Adds support for T6 adapter
  cxgb4vf: Adds SRIOV driver changes for T6 adapter

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  21 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 180 +++++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  47 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  49 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 562 +++++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        |   3 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       | 105 ++++
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h     |   1 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |  56 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h  |   5 +
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |  45 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |   8 +
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |  24 +-
 13 files changed, 933 insertions(+), 173 deletions(-)

-- 
2.3.4
