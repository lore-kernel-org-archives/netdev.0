From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] hso reset_resume patch
Date: Tue, 16 Sep 2008 16:52:38 +0200
Message-ID: <48CFC836.9030102@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Made usb_drivers reset_resume function point to hso_resume this 
fixes problems a usb reset is done when the network interface
is left idle for a few minutes. Possibly reset_resume should
initialise hardware more but this works in the common case.
Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---
Index: linux-2.6.27-rc6/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.27-rc6.orig/drivers/net/usb/hso.c	2008-09-16 16:21:34.000000000 +0200
+++ linux-2.6.27-rc6/drivers/net/usb/hso.c	2008-09-16 16:22:56.000000000 +0200
@@ -2751,6 +2751,7 @@
 	.id_table = hso_ids,
 	.suspend = hso_suspend,
 	.resume = hso_resume,
+	.reset_resume = hso_resume,
 	.supports_autosuspend = 1,
 };
-- 
best regards,
D.J. Barrow
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
