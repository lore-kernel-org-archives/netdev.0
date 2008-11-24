From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: respin of hso patches for linux-2.6.28-rc6 hso_reset_resume.patch
 [patch 6/6]
Date: Mon, 24 Nov 2008 15:53:46 +0100
Message-ID: <492ABFFA.7070805@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030605080304050102080506"
To: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030605080304050102080506
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Made usb_drivers reset_resume function point to hso_resume this 
fixes problems a usb reset is done when the network interface
is left idle for a few minutes. Possibly reset_resume should
initialise hardware more but this works in the common case.
Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---
Index: linux-2.6.28-rc6.patches/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.28-rc6.patches.orig/drivers/net/usb/hso.c	2008-11-24 15:07:47.000000000 +0100
+++ linux-2.6.28-rc6.patches/drivers/net/usb/hso.c	2008-11-24 15:12:35.000000000 +0100
@@ -3277,6 +3277,7 @@
 	.id_table = hso_ids,
 	.suspend = hso_suspend,
 	.resume = hso_resume,
+	.reset_resume = hso_resume,
 	.supports_autosuspend = 1,
 };
 

-- 
best regards,
D.J. Barrow

--------------030605080304050102080506
Content-Type: text/x-diff;
 name="hso_reset_resume.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_reset_resume.patch"

Made usb_drivers reset_resume function point to hso_resume this 
fixes problems a usb reset is done when the network interface
is left idle for a few minutes. Possibly reset_resume should
initialise hardware more but this works in the common case.
Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---
Index: linux-2.6.28-rc6.patches/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.28-rc6.patches.orig/drivers/net/usb/hso.c	2008-11-24 15:07:47.000000000 +0100
+++ linux-2.6.28-rc6.patches/drivers/net/usb/hso.c	2008-11-24 15:12:35.000000000 +0100
@@ -3277,6 +3277,7 @@
 	.id_table = hso_ids,
 	.suspend = hso_suspend,
 	.resume = hso_resume,
+	.reset_resume = hso_resume,
 	.supports_autosuspend = 1,
 };
 

--------------030605080304050102080506--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
