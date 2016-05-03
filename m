From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/2] cxgb4: mbox enhancements for cxgb4
Date: Tue,  3 May 2016 18:58:00 +0530
Message-ID: <1462282082-6894-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com,
	swise@opengridcomputing.com, nirranjan@chelsio.com,
	santosh@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:10839 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755608AbcECNXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 09:23:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This patch series checks for firmware errors when we are waiting for
mbox response in a loop and breaks out. When negative timeout is passed
to mailbox code, don't sleep. Negative timeout is passed only from
interrupt context.

This patch series has been created against net-next tree and includes
patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (2):
  cxgb4: Don't sleep when mbox cmd is issued from interrupt context
  cxgb4: Check for firmware errors in the mailbox command loop

 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

-- 
2.3.4
