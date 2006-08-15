From: akpm@osdl.org
Subject: [patch 22/41] fealnx section fix
Date: Mon, 14 Aug 2006 23:00:09 -0700
Message-ID: <200608150600.k7F6093k012666@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:28562 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965128AbWHOGAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:00:20 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

With CONFIG_HOTPLUG=n it won't compile:

distcc[25607] ERROR: compile drivers/net/fealnx.c on g5/64 failed

version[] is referred to from both __init code and from __devinit code, so
move it out of __init altogether.

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/fealnx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/fealnx.c~fealnx-section-fix drivers/net/fealnx.c
--- a/drivers/net/fealnx.c~fealnx-section-fix
+++ a/drivers/net/fealnx.c
@@ -92,7 +92,7 @@ static int full_duplex[MAX_UNITS] = { -1
 #include <asm/uaccess.h>
 
 /* These identify the driver base version and may not be removed. */
-static char version[] __devinitdata =
+static char version[] =
 KERN_INFO DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE "\n";
 
 
_
