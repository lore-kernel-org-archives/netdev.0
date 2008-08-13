From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 14/25] bnx2x: Wrong structure size
Date: Wed, 13 Aug 2008 17:15:13 +0300
Message-ID: <1218636913.547.90.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yitchak Gertner" <gertner@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2057 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753265AbYHMOP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:15:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrong structure size
The wrong structure was used in the sizeof to clear (luckily both
structures have the same size in this version...)

Signed-off-by: Yitchak Gertner <gertner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 0321870..6fe1972 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -3985,10 +3985,10 @@ static void bnx2x_zero_sb(struct bnx2x *bp, int sb_id)
 
 	bnx2x_init_fill(bp, BAR_USTRORM_INTMEM +
 			USTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, sb_id), 0,
-			sizeof(struct ustorm_def_status_block)/4);
+			sizeof(struct ustorm_status_block)/4);
 	bnx2x_init_fill(bp, BAR_CSTRORM_INTMEM +
 			CSTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, sb_id), 0,
-			sizeof(struct cstorm_def_status_block)/4);
+			sizeof(struct cstorm_status_block)/4);
 }
 
 static void bnx2x_init_sb(struct bnx2x *bp, struct host_status_block *sb,
-- 
1.5.3.2




