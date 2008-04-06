From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH 2.6.25] BNX2X: Correct bringing chip out of reset
Date: Sun, 06 Apr 2008 12:44:42 +0300
Message-ID: <1207475082.13326.17.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "davem@davemloft.net" <davem@davemloft.net>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2966 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641AbYDFJw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Apr 2008 05:52:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BNX2X: Correct bringing chip out of reset

Fixed bug: Wrong register was written to when bringing the chip out of reset.

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/bnx2x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index de32b3f..ff15454 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -6153,7 +6153,7 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 		   func, mode);
 		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET,
 		       0xffffffff);
-		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET,
+		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET,
 		       0xfffc);
 		bnx2x_init_block(bp, MISC_COMMON_START, MISC_COMMON_END);
 
-- 
1.5.3.2




