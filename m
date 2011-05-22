From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6 3/4] bnx2x: fix DMAE timeout according to hw
 specifications
Date: Sun, 22 May 2011 23:09:19 +0300
Message-ID: <1306094959.9376.5.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2562 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754390Ab1EVUQO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2011 16:16:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 8b27c75..09586e2 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -571,7 +571,7 @@ static int bnx2x_issue_dmae_with_comp(struct bnx2x *bp,
 				      struct dmae_command *dmae)
 {
 	u32 *wb_comp = bnx2x_sp(bp, wb_comp);
-	int cnt = CHIP_REV_IS_SLOW(bp) ? (400000) : 40;
+	int cnt = CHIP_REV_IS_SLOW(bp) ? (400000) : 4000;
 	int rc = 0;
 
 	DP(BNX2X_MSG_OFF, "data before [0x%08x 0x%08x 0x%08x 0x%08x]\n",
-- 
1.7.2.2




