From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/4] Cleanup, T6 changes and register range update
Date: Tue,  7 Jul 2015 21:49:17 +0530
Message-ID: <1436285961-8674-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5324 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754520AbbGGLF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 07:05:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds the following:
Don't use entire L2T table, update register ranges for T6 adapter,
read stats for only available channels for T6 and enable cim_la dump for
T6 adapter also.

This patch series has been created against net-next tree and includes
patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (4):
  cxgb4: Don't use entire L2T table, use only its slice
  cxgb4: Update register ranges for T6 adapter
  cxgb4: Read stats for only available channels
  cxgb4: Enable cim_la dump to support T6

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 54 ++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c           | 94 +++++++++++++---------
 drivers/net/ethernet/chelsio/cxgb4/l2t.h           | 18 ++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 89 ++++++++------------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |  1 -
 6 files changed, 157 insertions(+), 101 deletions(-)

-- 
2.3.4
