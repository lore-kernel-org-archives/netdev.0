From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 6/7] rtlwifi: Remove duplicate __func__
Date: Wed,  4 Jan 2012 19:40:44 -0800
Message-ID: <423eb9a5e773ff865997dbef580c3b741dc45a8a.1325734203.git.joe@perches.com>
References: <cover.1325734202.git.joe@perches.com>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1325734202.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The RT_TRACE macro already prepends it.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
index aca0fd5..7d5f799 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
@@ -620,7 +620,7 @@ void rtl92cu_tx_fill_desc(struct ieee80211_hw *hw,
 		SET_TX_DESC_BMC(txdesc, 1);
 	_rtl_fill_usb_tx_desc(txdesc);
 	_rtl_tx_desc_checksum(txdesc);
-	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, " %s ==>\n", __func__);
+	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, "==>\n");
 }
 
 void rtl92cu_fill_fake_txdesc(struct ieee80211_hw *hw, u8 * pDesc,
-- 
1.7.8.111.gad25c.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
