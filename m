From: akpm@linux-foundation.org
Subject: [patch 6/7] starfire secton fix
Date: Fri, 08 Feb 2008 03:11:16 -0800
Message-ID: <200802081120.m18BK8cw021639@imap1.linux-foundation.org>
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	sam@ravnborg.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50612 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964891AbYBHLVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 06:21:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

gcc-3.4.4 on powerpc:

drivers/net/starfire.c:219: error: version causes a section type conflict

Cc: Jeff Garzik <jeff@garzik.org>
Cc: Sam Ravnborg <sam@ravnborg.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/starfire.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/starfire.c~starfire-secton-fix drivers/net/starfire.c
--- a/drivers/net/starfire.c~starfire-secton-fix
+++ a/drivers/net/starfire.c
@@ -216,7 +216,7 @@ do { \
 
 
 /* These identify the driver base version and may not be removed. */
-static const char version[] __devinitdata =
+static char version[] =
 KERN_INFO "starfire.c:v1.03 7/26/2000  Written by Donald Becker <becker@scyld.com>\n"
 KERN_INFO " (unofficial 2.2/2.4 kernel port, version " DRV_VERSION ", " DRV_RELDATE ")\n";
 
_
