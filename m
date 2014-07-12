From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 8/9] rtlwifi: remove unnecessary break after goto
Date: Sat, 12 Jul 2014 20:09:47 +0200
Message-ID: <1405188597-2815-9-git-send-email-fabf@skynet.be>
References: <1405188597-2815-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay009.isp.belgacom.be ([195.238.6.176]:30174 "EHLO
	mailrelay009.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753140AbaGLSLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jul 2014 14:11:46 -0400
In-Reply-To: <1405188597-2815-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/wireless/rtlwifi/rtl8192se/fw.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/fw.c b/drivers/net/wireless/rtlwifi/rtl8192se/fw.c
index 380e7d4..73fa4a1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/fw.c
@@ -438,7 +438,6 @@ int rtl92s_download_fw(struct ieee80211_hw *hw)
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 				 "Unexpected Download step!!\n");
 			goto fail;
-			break;
 		}
 
 		/* <2> Download image file */
-- 
1.9.1
