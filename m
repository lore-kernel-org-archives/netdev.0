From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/3] rtlwifi: rtl8192ce: Handle unused switch case
Date: Wed,  5 Mar 2014 17:25:59 -0600
Message-ID: <1394061961-11682-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1394061961-11682-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:50256 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757235AbaCEX0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 18:26:16 -0500
In-Reply-To: <1394061961-11682-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prevents log spamming by adding a case for a previously
unhandled case.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index c6a3820..4ae51d5 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -542,9 +542,11 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 						(u8 *)(&fw_current_inps));
 			}
 		break; }
+	case HW_VAR_KEEP_ALIVE:
+		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case %d not processed\n", variable);
 		break;
 	}
 }
-- 
1.8.4.5
