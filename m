From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 0/4] cxgb4: Trivial fixes for cxgb4
Date: Wed, 30 Sep 2015 20:33:27 +0530
Message-ID: <1443625411-12096-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:18672 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751279AbbI3PCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 11:02:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Fixes the following issues
Don't read non existent T4/T5/T6 adapter registers for ethtool dump.
For T4, dont read mailbox control registers. Adds new devlog faility and
report correct link speed for unsupported ones.

This patch series has been created against net-next tree and includes
patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

V2: Fix coding style for Patch2/4 ("cxgb4: For T4, don't read the Firmware
 Mailbox Control register") based on review comment by Sergei Shtylyov

Hariprasad Shenai (4):
  cxgb4 : Update T4/T5/T6 register ranges
  cxgb4: For T4, don't read the Firmware Mailbox Control register
  cxgb4: Adds a new Device Log Facility FW_DEVLOG_FACILITY_CF
  cxgb4: Report correct link speed for unsupported ones

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   19 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    6 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 1464 +++++++++++++++-----
 3 files changed, 1153 insertions(+), 336 deletions(-)

-- 
2.3.4
