From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: Remove redundant code in t4_uld_clean_up()
Date: Thu, 16 Feb 2017 12:27:15 +0530
Message-ID: <1487228235-29489-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:21679 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753163AbdBPG5i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 01:57:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove variable rxq_info and also remove redundant assignment
to it.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
index 36105b6..d0868c2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
@@ -591,7 +591,6 @@ void t4_uld_mem_free(struct adapter *adap)
 
 void t4_uld_clean_up(struct adapter *adap)
 {
-	struct sge_uld_rxq_info *rxq_info;
 	unsigned int i;
 
 	if (!adap->uld)
@@ -599,7 +598,6 @@ void t4_uld_clean_up(struct adapter *adap)
 	for (i = 0; i < CXGB4_ULD_MAX; i++) {
 		if (!adap->uld[i].handle)
 			continue;
-		rxq_info = adap->sge.uld_rxq_info[i];
 		if (adap->flags & FULL_INIT_DONE)
 			quiesce_rx_uld(adap, i);
 		if (adap->flags & USING_MSIX)
-- 
2.1.0
