From: akpm@osdl.org
Subject: [patch 27/41] s2io build fix
Date: Mon, 14 Aug 2006 23:00:14 -0700
Message-ID: <200608150600.k7F60ECd012681@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, Ananda.Raju@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:2195 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965156AbWHOGB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:01:56 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

sparc32:

drivers/net/s2io.c:2636: warning: implicit declaration of function 'disable_irq'
drivers/net/s2io.c:2656: warning: implicit declaration of function 'enable_irq'

Cc: Ananda Raju <Ananda.Raju@neterion.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/s2io.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN drivers/net/s2io.c~s2io-build-fix drivers/net/s2io.c
--- a/drivers/net/s2io.c~s2io-build-fix
+++ a/drivers/net/s2io.c
@@ -71,6 +71,7 @@
 #include <asm/uaccess.h>
 #include <asm/io.h>
 #include <asm/div64.h>
+#include <asm/irq.h>
 
 /* local include */
 #include "s2io.h"
_
