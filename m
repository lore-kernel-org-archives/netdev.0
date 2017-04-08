From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 02/22] staging: rtl8723bs: Fix indenting warning in os_dep/rtw_proc.c
Date: Sat,  8 Apr 2017 11:07:25 -0500
Message-ID: <20170408160745.14328-3-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35835 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752491AbdDHQIE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:04 -0400
Received: by mail-oi0-f68.google.com with SMTP id g204so6268579oib.2
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:03 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch lists the following warning:

  CHECK   drivers/staging/rtl8723bs/os_dep/rtw_proc.c
drivers/staging/rtl8723bs/os_dep/rtw_proc.c:102 rtw_drv_proc_open() warn: inconsistent indenting

This warning is fixed with a simple change in the white space.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/os_dep/rtw_proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/rtl8723bs/os_dep/rtw_proc.c b/drivers/staging/rtl8723bs/os_dep/rtw_proc.c
index 4088381dff35..a2011e06d719 100644
--- a/drivers/staging/rtl8723bs/os_dep/rtw_proc.c
+++ b/drivers/staging/rtl8723bs/os_dep/rtw_proc.c
@@ -99,7 +99,8 @@ static int rtw_drv_proc_open(struct inode *inode, struct file *file)
 	/* struct net_device *dev = proc_get_parent_data(inode); */
 	ssize_t index = (ssize_t)PDE_DATA(inode);
 	const struct rtw_proc_hdl *hdl = drv_proc_hdls+index;
-       return single_open(file, hdl->show, NULL);
+
+	return single_open(file, hdl->show, NULL);
 }
 
 static ssize_t rtw_drv_proc_write(struct file *file, const char __user *buffer, size_t count, loff_t *pos)
-- 
2.12.0
