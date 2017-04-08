From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 22/22] staging: rtl8723bs: Fix indenting error in core/rtw_pwrctrl.c
Date: Sat,  8 Apr 2017 11:07:45 -0500
Message-ID: <20170408160745.14328-23-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36183 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752576AbdDHQI0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:26 -0400
Received: by mail-oi0-f68.google.com with SMTP id b187so16473002oif.3
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:21 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch reports the following:

  CHECK   drivers/staging/rtl8723bs/core/rtw_pwrctrl.c
drivers/staging/rtl8723bs/core/rtw_pwrctrl.c:641 LeaveAllPowerSaveModeDirect() warn: inconsistent indenting

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/core/rtw_pwrctrl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/rtl8723bs/core/rtw_pwrctrl.c b/drivers/staging/rtl8723bs/core/rtw_pwrctrl.c
index c5dd794dac4b..f708dbf5bfd4 100644
--- a/drivers/staging/rtl8723bs/core/rtw_pwrctrl.c
+++ b/drivers/staging/rtl8723bs/core/rtw_pwrctrl.c
@@ -638,7 +638,7 @@ void LeaveAllPowerSaveModeDirect(struct adapter *Adapter)
 
 		rtw_set_rpwm(Adapter, PS_STATE_S4);
 
-	up(&pwrpriv->lock);
+		up(&pwrpriv->lock);
 
 		rtw_lps_ctrl_wk_cmd(pri_padapter, LPS_CTRL_LEAVE, 0);
 	} else{
-- 
2.12.0
