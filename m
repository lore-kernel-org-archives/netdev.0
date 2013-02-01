From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 4/6] rtlwifi: rtl8192cu: Fix W=1 build warning
Date: Fri,  1 Feb 2013 10:40:25 -0600
Message-ID: <1359736827-30977-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1359736827-30977-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:38730 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757085Ab3BAQks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 11:40:48 -0500
In-Reply-To: <1359736827-30977-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When this driver is built with "make W=3D1", the following warning is o=
utput:

drivers/net/wireless/rtlwifi/rtl8192cu/sw.c:56:6: warning: variable =E2=
=80=98err=E2=80=99 set but not used [-Wunused-but-set-variable]

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/=
wireless/rtlwifi/rtl8192cu/sw.c
index b7e6607..d9e659f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -76,7 +76,7 @@ static int rtl92cu_init_sw_vars(struct ieee80211_hw *=
hw)
 				      GFP_KERNEL, hw, rtl_fw_cb);
=20
=20
-	return 0;
+	return err;
 }
=20
 static void rtl92cu_deinit_sw_vars(struct ieee80211_hw *hw)
--=20
1.8.1
