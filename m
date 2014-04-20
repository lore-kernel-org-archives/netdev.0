From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] hisax/icc: add missing semicolon after label
Date: Sun, 20 Apr 2014 11:48:33 +0200
Message-ID: <1397987313-27579-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:53879
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754793AbaDTJtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2014 05:49:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>

A label just before a brace needs a following semicolon (empty statement).

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/isdn/hisax/icc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hisax/icc.c b/drivers/isdn/hisax/icc.c
index 51dae91..96d1df0 100644
--- a/drivers/isdn/hisax/icc.c
+++ b/drivers/isdn/hisax/icc.c
@@ -425,7 +425,7 @@ afterXPR:
 				if (cs->debug & L1_DEB_MONITOR)
 					debugl1(cs, "ICC %02x -> MOX1", cs->dc.icc.mon_tx[cs->dc.icc.mon_txp - 1]);
 			}
-		AfterMOX1:
+		AfterMOX1: ;
 #endif
 		}
 	}
