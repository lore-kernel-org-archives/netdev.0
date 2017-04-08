From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 09/22] staging: rtl8723bs: Fix indening problem in hal/hal_com_phycfg.c
Date: Sat,  8 Apr 2017 11:07:32 -0500
Message-ID: <20170408160745.14328-10-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34838 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752622AbdDHQIP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:15 -0400
Received: by mail-oi0-f65.google.com with SMTP id g204so6268831oib.2
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:09 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch reports the following:

  CHECK   drivers/staging/rtl8723bs/hal/hal_com_phycfg.c
drivers/staging/rtl8723bs/hal/hal_com_phycfg.c:2090 Hal_ChannelPlanToRegulation() warn: inconsistent indenting

This warning is fixed with a white-space change.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/hal/hal_com_phycfg.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/rtl8723bs/hal/hal_com_phycfg.c b/drivers/staging/rtl8723bs/hal/hal_com_phycfg.c
index 95fff20e9c4b..566b6f0997da 100644
--- a/drivers/staging/rtl8723bs/hal/hal_com_phycfg.c
+++ b/drivers/staging/rtl8723bs/hal/hal_com_phycfg.c
@@ -2087,7 +2087,7 @@ void Hal_ChannelPlanToRegulation(struct adapter *Adapter, u16 ChannelPlan)
 	case RT_CHANNEL_DOMAIN_WORLD_FCC2:
 		pHalData->Regulation2_4G = TXPWR_LMT_FCC;
 		pHalData->Regulation5G = TXPWR_LMT_FCC;
-				break;
+		break;
 	case RT_CHANNEL_DOMAIN_WORLD_FCC3:
 		pHalData->Regulation2_4G = TXPWR_LMT_FCC;
 		pHalData->Regulation5G = TXPWR_LMT_FCC;
-- 
2.12.0
