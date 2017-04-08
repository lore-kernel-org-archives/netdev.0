From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 08/22] staging: rtl8723bs: Fix indenting problems in hal/HalHWImg8723B_BB.c
Date: Sat,  8 Apr 2017 11:07:31 -0500
Message-ID: <20170408160745.14328-9-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34835 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752406AbdDHQIJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:09 -0400
Received: by mail-oi0-f66.google.com with SMTP id g204so6268783oib.2
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:09 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch lists the following:

  CHECK   drivers/staging/rtl8723bs/hal/HalHWImg8723B_BB.c
drivers/staging/rtl8723bs/hal/HalHWImg8723B_BB.c:314 ODM_ReadAndConfig_MP_8723B_AGC_TAB() warn: for statement not indented
drivers/staging/rtl8723bs/hal/HalHWImg8723B_BB.c:583 ODM_ReadAndConfig_MP_8723B_PHY_REG() warn: for statement not indented
drivers/staging/rtl8723bs/hal/HalHWImg8723B_BB.c:586 ODM_ReadAndConfig_MP_8723B_PHY_REG() warn: inconsistent indenting

These were all fixed with white-space changes.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/hal/HalHWImg8723B_BB.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/rtl8723bs/hal/HalHWImg8723B_BB.c b/drivers/staging/rtl8723bs/hal/HalHWImg8723B_BB.c
index b42f06076f93..51d4219177d3 100644
--- a/drivers/staging/rtl8723bs/hal/HalHWImg8723B_BB.c
+++ b/drivers/staging/rtl8723bs/hal/HalHWImg8723B_BB.c
@@ -312,7 +312,7 @@ void ODM_ReadAndConfig_MP_8723B_AGC_TAB(PDM_ODM_T pDM_Odm)
 				*   Discard the following (offset, data) pairs.
 				*/
 				while (v1 < 0x40000000 && i < ArrayLen-2)
-				READ_NEXT_PAIR(v1, v2, i);
+					READ_NEXT_PAIR(v1, v2, i);
 
 				i -= 2; /*  prevent from for-loop += 2 */
 			} else {
@@ -581,9 +581,9 @@ void ODM_ReadAndConfig_MP_8723B_PHY_REG(PDM_ODM_T pDM_Odm)
 				*   Discard the following (offset, data) pairs.
 				*/
 				while (v1 < 0x40000000 && i < ArrayLen-2)
-				READ_NEXT_PAIR(v1, v2, i);
+					READ_NEXT_PAIR(v1, v2, i);
 
-					i -= 2; /*  prevent from for-loop += 2 */
+				i -= 2; /*  prevent from for-loop += 2 */
 			} else { /*  Configure matched pairs and skip to end of if-else. */
 				while (v1 < 0x40000000 && i < ArrayLen-2) {
 					odm_ConfigBB_PHY_8723B(pDM_Odm, v1, bMaskDWord, v2);
-- 
2.12.0
