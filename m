From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 30/36] bnx2x: Adding explicit casting
Date: Wed, 12 Aug 2009 21:24:05 +0300
Message-ID: <1250101445.27379.182.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4902 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754594AbZHLSZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:25:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index bdf7228..a409767 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2926,7 +2926,7 @@ static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 		REG_WR(bp, reg_offset, val);
 
 		BNX2X_ERR("FATAL HW block attention set0 0x%x\n",
-			  (attn & HW_INTERRUT_ASSERT_SET_0));
+			  (u32)(attn & HW_INTERRUT_ASSERT_SET_0));
 		bnx2x_panic();
 	}
 }
@@ -2957,7 +2957,7 @@ static inline void bnx2x_attn_int_deasserted1(struct bnx2x *bp, u32 attn)
 		REG_WR(bp, reg_offset, val);
 
 		BNX2X_ERR("FATAL HW block attention set1 0x%x\n",
-			  (attn & HW_INTERRUT_ASSERT_SET_1));
+			  (u32)(attn & HW_INTERRUT_ASSERT_SET_1));
 		bnx2x_panic();
 	}
 }
@@ -2997,7 +2997,7 @@ static inline void bnx2x_attn_int_deasserted2(struct bnx2x *bp, u32 attn)
 		REG_WR(bp, reg_offset, val);
 
 		BNX2X_ERR("FATAL HW block attention set2 0x%x\n",
-			  (attn & HW_INTERRUT_ASSERT_SET_2));
+			  (u32)(attn & HW_INTERRUT_ASSERT_SET_2));
 		bnx2x_panic();
 	}
 }
-- 
1.5.4.3




