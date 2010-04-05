From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 01/12] tg3: Fix MII_TG3_DSP_EXP8 offset
Date: Mon, 5 Apr 2010 13:19:19 -0700
Message-ID: <1270498770-23765-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2379 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756447Ab0DEUTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 16:19:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The offset to the MII_TG3_DSP_EXP8 register is incorrect.  Fix it.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 574a1cc..4836f56 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2082,7 +2082,7 @@
 #define MII_TG3_DSP_AADJ1CH0		0x001f
 #define MII_TG3_DSP_AADJ1CH3		0x601f
 #define  MII_TG3_DSP_AADJ1CH3_ADCCKADJ	0x0002
-#define MII_TG3_DSP_EXP8		0x0708
+#define MII_TG3_DSP_EXP8		0x0f08
 #define  MII_TG3_DSP_EXP8_REJ2MHz	0x0001
 #define  MII_TG3_DSP_EXP8_AEDW		0x0200
 #define MII_TG3_DSP_EXP75		0x0f75
-- 
1.6.4.4


