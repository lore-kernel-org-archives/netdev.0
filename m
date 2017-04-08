From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 14/22] staging: rtl8723bs: Fix indenting mistakes in core/rtw_ieee80211.c
Date: Sat,  8 Apr 2017 11:07:37 -0500
Message-ID: <20170408160745.14328-15-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33328 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752618AbdDHQIP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:15 -0400
Received: by mail-oi0-f65.google.com with SMTP id t63so1022875oih.0
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:14 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch reports the following:

  CHECK   drivers/staging/rtl8723bs/core/rtw_ieee80211.c
drivers/staging/rtl8723bs/core/rtw_ieee80211.c:83 rtw_is_cckrates_included() warn: if statement not indented
drivers/staging/rtl8723bs/core/rtw_ieee80211.c:98 rtw_is_cckratesonly_included() warn: if statement not indented

These warnings are fixed with white-space changes.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/core/rtw_ieee80211.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/rtl8723bs/core/rtw_ieee80211.c b/drivers/staging/rtl8723bs/core/rtw_ieee80211.c
index af44a8cd26f8..4670e72368e5 100644
--- a/drivers/staging/rtl8723bs/core/rtw_ieee80211.c
+++ b/drivers/staging/rtl8723bs/core/rtw_ieee80211.c
@@ -81,8 +81,8 @@ uint	rtw_is_cckrates_included(u8 *rate)
 
 		while (rate[i] !=  0) {
 			if  ((((rate[i]) & 0x7f) == 2)	|| (((rate[i]) & 0x7f) == 4) ||
-			(((rate[i]) & 0x7f) == 11)  || (((rate[i]) & 0x7f) == 22))
-			return true;
+			     (((rate[i]) & 0x7f) == 11)  || (((rate[i]) & 0x7f) == 22))
+				return true;
 			i++;
 		}
 
@@ -95,16 +95,13 @@ uint	rtw_is_cckratesonly_included(u8 *rate)
 
 
 	while (rate[i] != 0) {
-			if  ((((rate[i]) & 0x7f) != 2) && (((rate[i]) & 0x7f) != 4) &&
-				(((rate[i]) & 0x7f) != 11)  && (((rate[i]) & 0x7f) != 22))
-
+		if  ((((rate[i]) & 0x7f) != 2) && (((rate[i]) & 0x7f) != 4) &&
+		     (((rate[i]) & 0x7f) != 11)  && (((rate[i]) & 0x7f) != 22))
 			return false;
-
-			i++;
+		i++;
 	}
 
 	return true;
-
 }
 
 int rtw_check_network_type(unsigned char *rate, int ratelen, int channel)
-- 
2.12.0
