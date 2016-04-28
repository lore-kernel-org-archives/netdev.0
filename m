From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/2] cxgb4/cxgb4vf: add support for mbox cmd logging
Date: Thu, 28 Apr 2016 13:23:17 +0530
Message-ID: <1461829999-20270-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com,
	swise@opengridcomputing.com, nirranjan@chelsio.com,
	santosh@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:57479 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752352AbcD1HtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 03:49:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This patch series adds support for logging mailbox commands and replies
for debugging purpose for both PF and VF driver.

This patch series has been created against net-next tree and includes
patches on cxgb4  and cxgb4vf driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (2):
  cxgb4: Add support to enable logging of firmware mailbox commands
  cxgb4vf: Add support to enable logging of firmware mailbox commands
    for VF

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  32 ++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  99 ++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  12 +++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  69 +++++++++----
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |   4 +
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    | 112 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |  29 ++++++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |  72 ++++++++-----
 8 files changed, 384 insertions(+), 45 deletions(-)

-- 
2.3.4
