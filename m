From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 10/22] staging: rtl8723bs: Fix indenting problem for hal/hal_com.c
Date: Sat,  8 Apr 2017 11:07:33 -0500
Message-ID: <20170408160745.14328-11-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36135 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752576AbdDHQIL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:11 -0400
Received: by mail-oi0-f66.google.com with SMTP id b187so16472599oif.3
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:11 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch lists the following:

  CHECK   drivers/staging/rtl8723bs/hal/hal_com_phycfg.c
drivers/staging/rtl8723bs/hal/hal_com_phycfg.c:2090 Hal_ChannelPlanToRegulation() warn: inconsistent indenting

Fixed by changing the white space.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/hal/hal_com.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/rtl8723bs/hal/hal_com.c b/drivers/staging/rtl8723bs/hal/hal_com.c
index 093978d8f2a4..1880d4140bee 100644
--- a/drivers/staging/rtl8723bs/hal/hal_com.c
+++ b/drivers/staging/rtl8723bs/hal/hal_com.c
@@ -1731,11 +1731,11 @@ void rtw_bb_rf_gain_offset(struct adapter *padapter)
 			for (i = 0; i < ArrayLen; i += 2) {
 				v1 = Array[i];
 				v2 = Array[i+1];
-				 if (v1 == padapter->eeprompriv.EEPROMRFGainVal) {
-						DBG_871X("Offset RF Gain. got v1 = 0x%x , v2 = 0x%x\n", v1, v2);
-						target = v2;
-						break;
-				 }
+				if (v1 == padapter->eeprompriv.EEPROMRFGainVal) {
+					DBG_871X("Offset RF Gain. got v1 = 0x%x , v2 = 0x%x\n", v1, v2);
+					target = v2;
+					break;
+				}
 			}
 			DBG_871X("padapter->eeprompriv.EEPROMRFGainVal = 0x%x , Gain offset Target Value = 0x%x\n", padapter->eeprompriv.EEPROMRFGainVal, target);
 			PHY_SetRFReg(padapter, RF_PATH_A, REG_RF_BB_GAIN_OFFSET, BIT18|BIT17|BIT16|BIT15, target);
-- 
2.12.0
