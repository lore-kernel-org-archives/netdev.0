From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/5] cxgb4: Misc. fixes for sge
Date: Wed, 15 Apr 2015 02:02:29 +0530
Message-ID: <1429043554-8744-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:32230 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755508AbbDNPUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 11:20:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Increases value of MAX_IMM_TX_PKT_LEN to improve latency, fill freelist
starving threshold based on adapter type, add comments for tx flits and sge
length code and don't call t4_slow_intr_handler when we are not master PF.

This patch series has been created against net-next tree and includes patches on
cxgb4 driver

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (5):
  cxgb4: Increased the value of MAX_IMM_TX_PKT_LEN from 128 to 256 bytes
  cxgb4: Freelist starving threshold varies from adapter to adapter
  cxgb4: Use device node in page allocation
  cxgb4: Add comment for calculate tx flits and sge length code
  cxgb4: Don't call t4_slow_intr_handler when we're not the Master PF

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  3 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c        | 76 +++++++++++++++++++------
 2 files changed, 62 insertions(+), 17 deletions(-)

-- 
2.3.4
