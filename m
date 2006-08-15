From: akpm@osdl.org
Subject: [patch 23/41] sundance section fix
Date: Mon, 14 Aug 2006 23:00:10 -0700
Message-ID: <200608150600.k7F60AIO012669@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:62610 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965153AbWHOGBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:01:49 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

drivers/net/sundance.c:110: error: version causes a section type conflict

I don't understand this error.  It's referred to from both __init and
__devinit code.  With CONFIG_HOTPLUG=n, version[] is placed in .init.data and
is referred to from .init.text.

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/sundance.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/sundance.c~sundance-section-fix drivers/net/sundance.c
--- a/drivers/net/sundance.c~sundance-section-fix
+++ a/drivers/net/sundance.c
@@ -109,7 +109,7 @@ static char *media[MAX_UNITS];
 #endif
 
 /* These identify the driver base version and may not be removed. */
-static char version[] __devinitdata =
+static char version[] =
 KERN_INFO DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE "  Written by Donald Becker\n"
 KERN_INFO "  http://www.scyld.com/network/sundance.html\n";
 
_
