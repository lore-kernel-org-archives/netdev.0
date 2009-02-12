From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 25/41]bnx2x: Returning EBUSY in debug mode as well
Date: Thu, 12 Feb 2009 20:37:21 +0200
Message-ID: <1234463841.1863.157.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3738 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758542AbZBLShr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:37:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 25/41]bnx2x: Returning EBUSY in debug mode as well

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 2e4d64d..6c04539 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -7059,9 +7059,8 @@ static int bnx2x_stop_leading(struct bnx2x *bp)
 			   *bp->dsb_sp_prod, dsb_sp_prod_idx);
 #ifdef BNX2X_STOP_ON_ERROR
 			bnx2x_panic();
-#else
-			rc = -EBUSY;
 #endif
+			rc = -EBUSY;
 			break;
 		}
 		cnt--;
-- 
1.5.4.3




