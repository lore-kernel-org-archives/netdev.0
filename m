From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 4/6] rtlwifi: use to_delayed_work
Date: Fri,  1 Jan 2016 23:48:55 +0800
Message-ID: <9453f5a6fe422f47b095d1b0a9fb5eb5a4935c4d.1451661580.git.geliangtang@163.com>
References: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-133.163.com ([123.125.50.133]:44020 "EHLO m50-133.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752057AbcAAPt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jan 2016 10:49:56 -0500
In-Reply-To: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
In-Reply-To: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
References: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use to_delayed_work() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 drivers/net/wireless/realtek/rtlwifi/wifi.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/wifi.h b/drivers/net/wireless/realtek/rtlwifi/wifi.h
index 4544752..d37ce16 100644
--- a/drivers/net/wireless/realtek/rtlwifi/wifi.h
+++ b/drivers/net/wireless/realtek/rtlwifi/wifi.h
@@ -2873,7 +2873,7 @@ value to host byte ordering.*/
 	(ppsc->cur_ps_level |= _ps_flg)
 
 #define container_of_dwork_rtl(x, y, z) \
-	container_of(container_of(x, struct delayed_work, work), y, z)
+	container_of(to_delayed_work(x), y, z)
 
 #define FILL_OCTET_STRING(_os, _octet, _len)	\
 		(_os).octet = (u8 *)(_octet);		\
-- 
2.5.0
