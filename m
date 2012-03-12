From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 2/8] bnx2x: removed unused function
 bnx2x_queue_set_cos_cid
Date: Mon, 12 Mar 2012 14:53:08 -0400
Message-ID: <1331578394-1153-3-git-send-email-yuvalmin@broadcom.com>
References: <1331578394-1153-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1168 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754660Ab2CLL71 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 07:59:27 -0400
In-Reply-To: <1331578394-1153-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index f7896c2..2b18ccd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -5181,13 +5181,6 @@ void bnx2x_init_queue_obj(struct bnx2x *bp,
 	obj->set_pending = bnx2x_queue_set_pending;
 }
 
-void bnx2x_queue_set_cos_cid(struct bnx2x *bp,
-			     struct bnx2x_queue_sp_obj *obj,
-			     u32 cid, u8 index)
-{
-	obj->cids[index] = cid;
-}
-
 /********************** Function state object *********************************/
 enum bnx2x_func_state bnx2x_func_get_state(struct bnx2x *bp,
 					   struct bnx2x_func_sp_obj *o)
-- 
1.7.9.rc2
