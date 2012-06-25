From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next (v2) 10/14] bnx2x: set maximal number of default
 RSS queues
Date: Mon, 25 Jun 2012 14:45:41 +0300
Message-ID: <1340624745-8650-11-git-send-email-yuvalmin@broadcom.com>
References: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4374 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756114Ab2FYLry (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 07:47:54 -0400
In-Reply-To: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index daa894b..53659f3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -822,7 +822,8 @@ static inline int bnx2x_calc_num_queues(struct bnx2x *bp)
 {
 	return  num_queues ?
 		 min_t(int, num_queues, BNX2X_MAX_QUEUES(bp)) :
-		 min_t(int, num_online_cpus(), BNX2X_MAX_QUEUES(bp));
+		 min_t(int, netif_get_num_default_rss_queues(),
+		       BNX2X_MAX_QUEUES(bp));
 }
 
 static inline void bnx2x_clear_sge_mask_next_elems(struct bnx2x_fastpath *fp)
-- 
1.7.9.rc2
