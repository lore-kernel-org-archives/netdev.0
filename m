From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH 2/2] net:wireless:treewide: Fix typo in drivers/net/wireless
Date: Mon, 27 Apr 2015 23:14:58 +0900
Message-ID: <1430144098-4933-2-git-send-email-standby24x7@gmail.com>
References: <1430144098-4933-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, Larry.Finger@lwfinger.net,
	rdunlap@infradead.org, trivial@kernel.org,
	chaoming_li@realsil.com.cn, linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430144098-4933-1-git-send-email-standby24x7@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix some spelling typo in drivers/net/wirless

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 drivers/net/wireless/mwifiex/tdls.c         | 2 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/fw.c | 2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/fw.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/tdls.c b/drivers/net/wireless/mwifiex/tdls.c
index 087d847..275a476 100644
--- a/drivers/net/wireless/mwifiex/tdls.c
+++ b/drivers/net/wireless/mwifiex/tdls.c
@@ -255,7 +255,7 @@ static int mwifiex_tdls_add_vht_oper(struct mwifiex_private *priv,
 		if (sta_ptr->tdls_cap.extcap.ext_capab[7] &
 		   WLAN_EXT_CAPA8_TDLS_WIDE_BW_ENABLED) {
 			dev_dbg(adapter->dev,
-				"TDLS peer doesn't support wider bandwitdh\n");
+				"TDLS peer doesn't support wider bandwidth\n");
 			return 0;
 		}
 	} else {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/fw.c b/drivers/net/wireless/rtlwifi/rtl8192ee/fw.c
index c5d4b80..232865c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/fw.c
@@ -875,7 +875,7 @@ static void _rtl92ee_c2h_content_parsing(struct ieee80211_hw *hw, u8 c2h_cmd_id,
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
-			 "[C2H], Unkown packet!! CmdId(%#X)!\n", c2h_cmd_id);
+			 "[C2H], Unknown packet!! CmdId(%#X)!\n", c2h_cmd_id);
 		break;
 	}
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/fw.c b/drivers/net/wireless/rtlwifi/rtl8723be/fw.c
index 69d4f0f..d5da0f3 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/fw.c
@@ -613,7 +613,7 @@ static void _rtl8723be_c2h_content_parsing(struct ieee80211_hw *hw,
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
-			 "[C2H], Unkown packet!! CmdId(%#X)!\n", c2h_cmd_id);
+			 "[C2H], Unknown packet!! CmdId(%#X)!\n", c2h_cmd_id);
 		break;
 	}
 }
-- 
2.4.0.rc3.3.g6eb1401
