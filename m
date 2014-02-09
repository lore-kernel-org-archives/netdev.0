From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/6] staging: r8188eu: Remove dead file
Date: Sun,  9 Feb 2014 15:15:55 -0600
Message-ID: <1391980559-24288-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1391980559-24288-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:42689 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbaBIVQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 16:16:09 -0500
Received: by mail-oa0-f53.google.com with SMTP id m1so6703190oag.12
        for <netdev@vger.kernel.org>; Sun, 09 Feb 2014 13:16:09 -0800 (PST)
In-Reply-To: <1391980559-24288-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the previous cleanups, file hal/odm_interface.c is now empty. It
is hereby deleted, and removed from Makefile.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/Makefile            | 1 -
 drivers/staging/rtl8188eu/hal/odm_interface.c | 1 -
 2 files changed, 2 deletions(-)
 delete mode 100644 drivers/staging/rtl8188eu/hal/odm_interface.c

diff --git a/drivers/staging/rtl8188eu/Makefile b/drivers/staging/rtl8188eu/Makefile
index 0a617b4..6a138ff 100644
--- a/drivers/staging/rtl8188eu/Makefile
+++ b/drivers/staging/rtl8188eu/Makefile
@@ -34,7 +34,6 @@ r8188eu-y :=				\
 		hal/hal_com.o		\
 		hal/odm.o		\
 		hal/odm_debug.o		\
-		hal/odm_interface.o	\
 		hal/odm_HWConfig.o	\
 		hal/odm_RegConfig8188E.o\
 		hal/odm_RTL8188E.o	\
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
deleted file mode 100644
index 8b13789..0000000
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ /dev/null
@@ -1 +0,0 @@
-
-- 
1.8.4.5
