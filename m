From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net-next 2/9] bnx2x: Remove unused iov code
Date: Mon, 10 Feb 2014 17:16:55 +0200
Message-ID: <1392045422-5437-3-git-send-email-yuvalmin@broadcom.com>
References: <1392045422-5437-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariele@broadcom.com>, Yuval Mintz <yuvalmin@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:23733 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491AbaBJPRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 10:17:08 -0500
In-Reply-To: <1392045422-5437-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 04805b6..c98edb0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -3075,16 +3075,6 @@ static inline void bnx2x_vf_get_sbdf(struct bnx2x *bp,
 	*sbdf = vf->devfn | (vf->bus << 8);
 }
 
-static inline void bnx2x_vf_get_bars(struct bnx2x *bp, struct bnx2x_virtf *vf,
-		       struct bnx2x_vf_bar_info *bar_info)
-{
-	int n;
-
-	bar_info->nr_bars = bp->vfdb->sriov.nres;
-	for (n = 0; n < bar_info->nr_bars; n++)
-		bar_info->bars[n] = vf->bars[n];
-}
-
 void bnx2x_lock_vf_pf_channel(struct bnx2x *bp, struct bnx2x_virtf *vf,
 			      enum channel_tlvs tlv)
 {
-- 
1.8.1.227.g44fe835
