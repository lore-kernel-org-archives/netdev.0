From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] staging: rtl8188eu: Add missing include
Date: Wed, 30 Sep 2015 10:20:47 -0500
Message-ID: <1443626447-3227-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Jakub Sitnicki <jsitnicki@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:33607 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754255AbbI3PUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 11:20:54 -0400
Received: by oixx17 with SMTP id x17so24111355oix.0
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 08:20:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 0a0796eb16f3, there is no include to mon.h, a newly created
header file. This omission leads to the following Sparse warnings:

  CHECK   drivers/staging/rtl8188eu/os_dep/mon.c
drivers/staging/rtl8188eu/os_dep/mon.c:81:6: warning: symbol 'rtl88eu_mon_recv_hook' was not declared. Should it be static?
drivers/staging/rtl8188eu/os_dep/mon.c:113:6: warning: symbol 'rtl88eu_mon_xmit_hook' was not declared. Should it be static?
drivers/staging/rtl8188eu/os_dep/mon.c:167:19: warning: symbol 'rtl88eu_mon_init' was not declared. Should it be static?
drivers/staging/rtl8188eu/os_dep/mon.c:188:6: warning: symbol 'rtl88eu_mon_deinit' was not declared. Should it be static?

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Jakub Sitnicki <jsitnicki@gmail.com>
---
 drivers/staging/rtl8188eu/os_dep/mon.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/rtl8188eu/os_dep/mon.c b/drivers/staging/rtl8188eu/os_dep/mon.c
index 3dd3dc0..63bb875 100644
--- a/drivers/staging/rtl8188eu/os_dep/mon.c
+++ b/drivers/staging/rtl8188eu/os_dep/mon.c
@@ -20,6 +20,7 @@
 #include <drv_types.h>
 #include <rtw_recv.h>
 #include <rtw_xmit.h>
+#include <mon.h>
 
 /**
  * unprotect_frame() - unset Protected flag and strip off IV and ICV/MIC
-- 
2.1.4
