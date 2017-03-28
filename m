From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 2/3] bnxt_en: Correct the order of arguments to netdev_err() in bnxt_set_tpa()
Date: Tue, 28 Mar 2017 19:47:30 -0400
Message-ID: <1490744851-19985-3-git-send-email-michael.chan@broadcom.com>
References: <1490744851-19985-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:35358 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932088AbdC1XsU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:48:20 -0400
Received: by mail-wr0-f174.google.com with SMTP id u1so49761wra.2
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 16:48:05 -0700 (PDT)
In-Reply-To: <1490744851-19985-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sankar Patchineelam <sankar.patchineelam@broadcom.com>

Signed-off-by: Sankar Patchineelam <sankar.patchineelam@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 7ee7724..6c856878 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4744,7 +4744,7 @@ static int bnxt_set_tpa(struct bnxt *bp, bool set_tpa)
 		rc = bnxt_hwrm_vnic_set_tpa(bp, i, tpa_flags);
 		if (rc) {
 			netdev_err(bp->dev, "hwrm vnic set tpa failure rc for vnic %d: %x\n",
-				   rc, i);
+				   i, rc);
 			return rc;
 		}
 	}
-- 
1.8.3.1
