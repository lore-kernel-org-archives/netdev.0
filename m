From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 08/30] rtlwifi: rtl8723ae: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:16:16 +0200
Message-ID: <1405865801-18806-9-git-send-email-fabf@skynet.be>
References: <1405865801-18806-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay009.isp.belgacom.be ([195.238.6.176]:38311 "EHLO
	mailrelay009.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751704AbaGTOVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 10:21:35 -0400
In-Reply-To: <1405865801-18806-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
index 87f6916..27cb76f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
@@ -1103,7 +1103,6 @@ static int _rtl8723ae_set_media_status(struct ieee80211_hw *hw,
 			 "Network type %d not supported!\n",
 			 type);
 		return 1;
-		break;
 
 	}
 
-- 
1.9.1
