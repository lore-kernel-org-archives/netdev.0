From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 10/11] bnx2x: set maximal number of default RSS
 queues
Date: Sun, 1 Jul 2012 16:18:59 +0300
Message-ID: <1341148740-7375-11-git-send-email-yuvalmin@broadcom.com>
References: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3380 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932370Ab2GANUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2012 09:20:51 -0400
In-Reply-To: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
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
