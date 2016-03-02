From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 7/7] bnx2x: fix indentation in bnx2x_sp_task()
Date: Wed,  2 Mar 2016 13:47:11 +0100
Message-ID: <1456922831-15071-8-git-send-email-mschmidt@redhat.com>
References: <1456922831-15071-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54159 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873AbcCBMo2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 07:44:28 -0500
In-Reply-To: <1456922831-15071-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a case of misleading code indentation.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 9f5716a..2bf9c87 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -5682,7 +5682,7 @@ static void bnx2x_sp_task(struct work_struct *work)
 		if (status & BNX2X_DEF_SB_IDX) {
 			struct bnx2x_fastpath *fp = bnx2x_fcoe_fp(bp);
 
-		if (FCOE_INIT(bp) &&
+			if (FCOE_INIT(bp) &&
 			    (bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
 				/* Prevent local bottom-halves from running as
 				 * we are going to change the local NAPI list.
-- 
2.5.0
