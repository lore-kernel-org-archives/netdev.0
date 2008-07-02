From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: WAN: wanmain.c doesn't need syncppp.h
Date: Wed, 02 Jul 2008 21:13:58 +0200
Message-ID: <m3prpw3xqh.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:48621 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752044AbYGBTX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 15:23:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For review only, the actual patch will be made available in git.

wanmain.c doesn't need syncppp.h

diff --git a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
index 6c20205..34177f2 100644
--- a/net/wanrouter/wanmain.c
+++ b/net/wanrouter/wanmain.c
@@ -57,7 +57,6 @@
 #include <linux/vmalloc.h>	/* vmalloc, vfree */
 #include <asm/uaccess.h>        /* copy_to/from_user */
 #include <linux/init.h>         /* __initfunc et al. */
-#include <net/syncppp.h>
 
 #define KMEM_SAFETYZONE 8
 


-- 
Krzysztof Halasa
