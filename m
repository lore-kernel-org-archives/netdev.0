From: Nithin Nayak Sujir <nsujir@broadcom.com>
Subject: [PATCH net-next 3/5] tg3: Fix bit definition for the nvram Auto Power Down setting
Date: Fri, 6 Dec 2013 09:53:18 -0800
Message-ID: <1386352400-9623-4-git-send-email-nsujir@broadcom.com>
References: <1386352400-9623-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:45030 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758179Ab3LFRxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:53:32 -0500
In-Reply-To: <1386352400-9623-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The APD bit is 14 and not bit 10.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index e128f37..e4da9d7 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2204,7 +2204,7 @@
 
 #define NIC_SRAM_DATA_CFG_2		0x00000d38
 
-#define  NIC_SRAM_DATA_CFG_2_APD_EN	 0x00000400
+#define  NIC_SRAM_DATA_CFG_2_APD_EN	 0x00004000
 #define  SHASTA_EXT_LED_MODE_MASK	 0x00018000
 #define  SHASTA_EXT_LED_LEGACY		 0x00000000
 #define  SHASTA_EXT_LED_SHARED		 0x00008000
-- 
1.8.1.4
