From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 04/12 NEXT] rtlwifi: Set the link state
Date: Mon, 18 Nov 2013 11:11:28 -0600
Message-ID: <1384794696-20314-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1384794696-20314-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1384794696-20314-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The present code fails to set the linked state when an interface is
added.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---
 drivers/net/wireless/rtlwifi/core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index 0f12cd3..3550e8a 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -194,6 +194,7 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 					rtlpriv->cfg->maps
 					[RTL_IBSS_INT_MASKS]);
 		}
+		mac->link_state = MAC80211_LINKED;
 		break;
 	case NL80211_IFTYPE_ADHOC:
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-- 
1.8.4
