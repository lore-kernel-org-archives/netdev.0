From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH 1/2] irda: sh-irda: Remove SH7367 support
Date: Thu,  8 Nov 2012 16:44:26 +0900
Message-ID: <1352360667-9341-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: samuel@sortiz.org,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:65514 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500Ab2KHHoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 02:44:37 -0500
Received: by mail-pb0-f46.google.com with SMTP id rr4so1846952pbb.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 23:44:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The shmobile SH7367 already was removed from source tree.
This remove SH7367 support for sh-irda.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 drivers/net/irda/sh_irda.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/irda/sh_irda.c b/drivers/net/irda/sh_irda.c
index 4b746d9..ca49bbf 100644
--- a/drivers/net/irda/sh_irda.c
+++ b/drivers/net/irda/sh_irda.c
@@ -33,7 +33,7 @@
 
 #define DRIVER_NAME "sh_irda"
 
-#if defined(CONFIG_ARCH_SH7367) || defined(CONFIG_ARCH_SH7377)
+#if defined(CONFIG_ARCH_SH7377)
 #define __IRDARAM_LEN	0x13FF
 #else
 #define __IRDARAM_LEN	0x1039
-- 
1.7.10.4
