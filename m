From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] rtlwifi: Use is_zero_ether_addr, remove line continuation
Date: Sat, 17 Mar 2012 12:13:30 -0700
Message-ID: <1d738d4a4dd61978f969ed4a43f2dd3717f51a19.1332011552.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:49249 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753180Ab2CQTNf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 15:13:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the normal kernel facilities and use %pM
to print the all zero mac address.

Remove unnecessary line continuation.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtlwifi/cam.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/cam.c b/drivers/net/wireless/rtlwifi/cam.c
index 5c7d579..3d8cc4a 100644
--- a/drivers/net/wireless/rtlwifi/cam.c
+++ b/drivers/net/wireless/rtlwifi/cam.c
@@ -328,10 +328,9 @@ void rtl_cam_del_entry(struct ieee80211_hw *hw, u8 *sta_addr)
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG, "sta_addr is NULL\n");
 	}
 
-	if ((sta_addr[0]|sta_addr[1]|sta_addr[2]|sta_addr[3]|\
-				sta_addr[4]|sta_addr[5]) == 0) {
+	if (is_zero_ether_addr(sta_addr)) {
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG,
-			 "sta_addr is 00:00:00:00:00:00\n");
+			 "sta_addr is %pM\n", sta_addr);
 		return;
 	}
 	/* Does STA already exist? */
-- 
1.7.8.111.gad25c.dirty
