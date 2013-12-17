From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH] bnx2x: downgrade "valid ME register value" message level
Date: Tue, 17 Dec 2013 18:51:25 +0100
Message-ID: <1387302685-32314-1-git-send-email-mschmidt@redhat.com>
Cc: Ariel Elior <ariele@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46422 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753361Ab3LQRv2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 12:51:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"valid ME register value" is not an error. It should be logged for
debugging only.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index efa8a15..3dc2537 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -208,7 +208,7 @@ static int bnx2x_get_vf_id(struct bnx2x *bp, u32 *vf_id)
 		return -EINVAL;
 	}
 
-	BNX2X_ERR("valid ME register value: 0x%08x\n", me_reg);
+	DP(BNX2X_MSG_IOV, "valid ME register value: 0x%08x\n", me_reg);
 
 	*vf_id = (me_reg & ME_REG_VF_NUM_MASK) >> ME_REG_VF_NUM_SHIFT;
 
-- 
1.8.4.2
