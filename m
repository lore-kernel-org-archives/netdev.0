From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/4] Add some more debug info
Date: Wed, 12 Aug 2015 16:55:03 +0530
Message-ID: <1439378707-14462-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24451 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750974AbbHLLZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 07:25:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds the following.
Add more info for sge_qinfo dump
Differentiate tid and stids between different regions, and add a debugfs
entry to dump all the tid info

This patch series has been created against net-next tree and includes
patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (4):
  cxgb4: Add some more details to sge qinfo
  cxgb4: Differentiates between TIDs being used in TCAM and HASH
  cxgb4: Differentiate between stids between server and filter region
  cxgb4: Add debugfs support to dump tid info

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 129 +++++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  47 ++++++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |  10 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |   9 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   5 +
 5 files changed, 176 insertions(+), 24 deletions(-)

-- 
2.3.4
