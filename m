From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 06/12 NEXT] rtlwifi: Increase the RX queue length for USB drivers
Date: Mon, 18 Nov 2013 11:11:30 -0600
Message-ID: <1384794696-20314-7-git-send-email-Larry.Finger@lwfinger.net>
References: <1384794696-20314-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1384794696-20314-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current number of RX buffers queued is 32, which is too small under
heavy load. That number is doubled.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---
 drivers/net/wireless/rtlwifi/usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
index 6e2b5c5..75481d2 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -553,7 +553,7 @@ static void _rtl_rx_pre_process(struct ieee80211_hw *hw, struct sk_buff *skb)
 	}
 }
 
-#define __RX_SKB_MAX_QUEUED	32
+#define __RX_SKB_MAX_QUEUED	64
 
 static void _rtl_rx_work(unsigned long param)
 {
-- 
1.8.4
