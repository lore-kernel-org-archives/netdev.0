From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 21/22] staging: rtl8723bs: Fix indenting problems in core/rtw_odm.c
Date: Sat,  8 Apr 2017 11:07:44 -0500
Message-ID: <20170408160745.14328-22-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34893 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752539AbdDHQIU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:20 -0400
Received: by mail-oi0-f66.google.com with SMTP id g204so6269246oib.2
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:20 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch reports the following:

  CHECK   drivers/staging/rtl8723bs/core/rtw_odm.c
drivers/staging/rtl8723bs/core/rtw_odm.c:109 rtw_odm_dbg_comp_msg() warn: if statement not indented
drivers/staging/rtl8723bs/core/rtw_odm.c:146 rtw_odm_ability_msg() warn: if statement not indented

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/core/rtw_odm.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/rtl8723bs/core/rtw_odm.c b/drivers/staging/rtl8723bs/core/rtw_odm.c
index 5bc573386ad1..3144e8ec2fa2 100644
--- a/drivers/staging/rtl8723bs/core/rtw_odm.c
+++ b/drivers/staging/rtl8723bs/core/rtw_odm.c
@@ -107,8 +107,9 @@ void rtw_odm_dbg_comp_msg(void *sel, struct adapter *adapter)
 	DBG_871X_SEL_NL(sel, "odm.DebugComponents = 0x%016llx\n", dbg_comp);
 	for (i = 0; i < RTW_ODM_COMP_MAX; i++) {
 		if (odm_comp_str[i])
-		DBG_871X_SEL_NL(sel, "%cBIT%-2d %s\n",
-			(BIT0 << i) & dbg_comp ? '+' : ' ', i, odm_comp_str[i]);
+			DBG_871X_SEL_NL(sel, "%cBIT%-2d %s\n",
+					(BIT0 << i) & dbg_comp ? '+' : ' ',
+					i, odm_comp_str[i]);
 	}
 }
 
@@ -144,8 +145,9 @@ void rtw_odm_ability_msg(void *sel, struct adapter *adapter)
 	DBG_871X_SEL_NL(sel, "odm.SupportAbility = 0x%08x\n", ability);
 	for (i = 0; i < RTW_ODM_ABILITY_MAX; i++) {
 		if (odm_ability_str[i])
-		DBG_871X_SEL_NL(sel, "%cBIT%-2d %s\n",
-			(BIT0 << i) & ability ? '+' : ' ', i, odm_ability_str[i]);
+			DBG_871X_SEL_NL(sel, "%cBIT%-2d %s\n",
+					(BIT0 << i) & ability ? '+' : ' ', i,
+					odm_ability_str[i]);
 	}
 }
 
-- 
2.12.0
