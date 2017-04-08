From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 17/22] staging: rtl8723bs: Fix indenting problem in core/rtw_sta_mgt.c
Date: Sat,  8 Apr 2017 11:07:40 -0500
Message-ID: <20170408160745.14328-18-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33336 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752722AbdDHQIW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:22 -0400
Received: by mail-oi0-f68.google.com with SMTP id t63so1022943oih.0
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:21 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse reports the following:

  CHECK   drivers/staging/rtl8723bs/core/rtw_sta_mgt.c
drivers/staging/rtl8723bs/core/rtw_sta_mgt.c:25 _rtw_init_stainfo() warn: inconsistent indenting

This problem is fixed with a white-spcae change.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/core/rtw_sta_mgt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/rtl8723bs/core/rtw_sta_mgt.c b/drivers/staging/rtl8723bs/core/rtw_sta_mgt.c
index d7eee6dd7e3b..cb43ec90a648 100644
--- a/drivers/staging/rtl8723bs/core/rtw_sta_mgt.c
+++ b/drivers/staging/rtl8723bs/core/rtw_sta_mgt.c
@@ -22,7 +22,7 @@ void _rtw_init_stainfo(struct sta_info *psta)
 {
 	memset((u8 *)psta, 0, sizeof(struct sta_info));
 
-	 spin_lock_init(&psta->lock);
+	spin_lock_init(&psta->lock);
 	INIT_LIST_HEAD(&psta->list);
 	INIT_LIST_HEAD(&psta->hash_list);
 	/* INIT_LIST_HEAD(&psta->asoc_list); */
-- 
2.12.0
