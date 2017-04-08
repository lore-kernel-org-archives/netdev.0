From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 04/22] staging: rtl8723bs: Fix indenting warning in os_dep/os_intfs.c
Date: Sat,  8 Apr 2017 11:07:27 -0500
Message-ID: <20170408160745.14328-5-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33294 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752539AbdDHQIG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:06 -0400
Received: by mail-oi0-f65.google.com with SMTP id t63so1022597oih.0
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:05 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch logs the following warning:

  CHECK   drivers/staging/rtl8723bs/os_dep/os_intfs.c
drivers/staging/rtl8723bs/os_dep/os_intfs.c:1082 ips_netdrv_open() warn: inconsistent indenting

A simple change in the white space handles this warning.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/os_dep/os_intfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/rtl8723bs/os_dep/os_intfs.c b/drivers/staging/rtl8723bs/os_dep/os_intfs.c
index 2ed3067b4af0..843be2cc6c10 100644
--- a/drivers/staging/rtl8723bs/os_dep/os_intfs.c
+++ b/drivers/staging/rtl8723bs/os_dep/os_intfs.c
@@ -1079,7 +1079,7 @@ static int  ips_netdrv_open(struct adapter *padapter)
 
 	_set_timer(&padapter->mlmepriv.dynamic_chk_timer, 2000);
 
-	 return _SUCCESS;
+	return _SUCCESS;
 
 netdev_open_error:
 	/* padapter->bup = false; */
-- 
2.12.0
