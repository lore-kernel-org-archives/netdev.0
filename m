From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 4/4] cxgb4: Use napi_complete_done() api in napi handler
Date: Wed, 23 Dec 2015 11:29:56 +0530
Message-ID: <1450850396-24141-5-git-send-email-hariprasad@chelsio.com>
References: <1450850396-24141-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:45153 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753499AbbLWF6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 00:58:37 -0500
In-Reply-To: <1450850396-24141-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 138be46..5e3ffa7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2288,7 +2288,7 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
 	if (likely(work_done < budget)) {
 		int timer_index;
 
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		timer_index = QINTR_TIMER_IDX_G(q->next_intr_params);
 
 		if (q->adaptive_rx) {
-- 
2.3.4
