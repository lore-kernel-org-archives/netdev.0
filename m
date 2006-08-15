From: akpm@osdl.org
Subject: [patch 21/41] winbond-840 section fix
Date: Mon, 14 Aug 2006 23:00:08 -0700
Message-ID: <200608150600.k7F6084V012663@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, val_henson@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:64914 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965158AbWHOGBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:01:52 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

With CONFIG_HOTPLUG=n it won't compile:

drivers/net/tulip/winbond-840.c:141: error: version causes a section type conflict

(For some reason it gets the same error if marked __initdata.  Give up.)

Cc: Valerie Henson <val_henson@linux.intel.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/tulip/winbond-840.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/tulip/winbond-840.c~winbond-840-section-fix drivers/net/tulip/winbond-840.c
--- a/drivers/net/tulip/winbond-840.c~winbond-840-section-fix
+++ a/drivers/net/tulip/winbond-840.c
@@ -138,7 +138,7 @@ static int full_duplex[MAX_UNITS] = {-1,
 #include <asm/irq.h>
 
 /* These identify the driver base version and may not be removed. */
-static char version[] __devinitdata =
+static char version[] =
 KERN_INFO DRV_NAME ".c:v" DRV_VERSION " (2.4 port) " DRV_RELDATE "  Donald Becker <becker@scyld.com>\n"
 KERN_INFO "  http://www.scyld.com/network/drivers.html\n";
 
_
