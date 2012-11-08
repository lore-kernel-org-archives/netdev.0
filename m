From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH 2/2] irda: sh-irda: Remove SH7377 support
Date: Thu,  8 Nov 2012 16:44:27 +0900
Message-ID: <1352360667-9341-2-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
References: <1352360667-9341-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: samuel@sortiz.org,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:33163 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500Ab2KHHok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 02:44:40 -0500
Received: by mail-da0-f46.google.com with SMTP id n41so1072021dak.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 23:44:40 -0800 (PST)
In-Reply-To: <1352360667-9341-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The shmobile SH7377 already was removed from source tree.
This remove SH7377 support for sh-irda.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 drivers/net/irda/sh_irda.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/irda/sh_irda.c b/drivers/net/irda/sh_irda.c
index ca49bbf..945360a 100644
--- a/drivers/net/irda/sh_irda.c
+++ b/drivers/net/irda/sh_irda.c
@@ -33,11 +33,7 @@
 
 #define DRIVER_NAME "sh_irda"
 
-#if defined(CONFIG_ARCH_SH7377)
-#define __IRDARAM_LEN	0x13FF
-#else
 #define __IRDARAM_LEN	0x1039
-#endif
 
 #define IRTMR		0x1F00 /* Transfer mode */
 #define IRCFR		0x1F02 /* Configuration */
-- 
1.7.10.4
