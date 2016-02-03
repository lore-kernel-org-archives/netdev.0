From: Byeoungwook Kim <quddnr145@gmail.com>
Subject: [PATCH v2 1/2] rtlwifi: Fix improve function 'rtl_addr_delay()' in
 core.c
Date: Wed, 3 Feb 2016 11:15:10 +0900
Message-ID: <20160203021510.GA13725@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvalo@codeaurora.org, chaoming_li@realsil.com.cn,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry.Finger@lwfinger.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33471 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754270AbcBCCPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 21:15:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Conditional codes in rtl_addr_delay() were improved in readability and
performance by using switch codes.

Signed-off-by: Byeoungwook Kim <quddnr145@gmail.com>
Reviewed-by: Julian Calaby <julian.calaby@gmail.com>
---
V2 split in separate patchs.
 drivers/net/wireless/realtek/rtlwifi/core.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/core.c b/drivers/net/wireless/realtek/rtlwifi/core.c
index 4ae421e..05f432c 100644
--- a/drivers/net/wireless/realtek/rtlwifi/core.c
+++ b/drivers/net/wireless/realtek/rtlwifi/core.c
@@ -37,18 +37,26 @@
 
 void rtl_addr_delay(u32 addr)
 {
-	if (addr == 0xfe)
+	switch (addr) {
+	case 0xfe:
 		mdelay(50);
-	else if (addr == 0xfd)
+		break;
+	case 0xfd:
 		mdelay(5);
-	else if (addr == 0xfc)
+		break;
+	case 0xfc:
 		mdelay(1);
-	else if (addr == 0xfb)
+		break;
+	case 0xfb:
 		udelay(50);
-	else if (addr == 0xfa)
+		break;
+	case 0xfa:
 		udelay(5);
-	else if (addr == 0xf9)
+		break;
+	case 0xf9:
 		udelay(1);
+		break;
+	};
 }
 EXPORT_SYMBOL(rtl_addr_delay);
 
-- 
2.5.0
