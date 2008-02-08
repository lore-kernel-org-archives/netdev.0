From: akpm@linux-foundation.org
Subject: [patch 4/7] bnx2.c section fix
Date: Fri, 08 Feb 2008 03:11:15 -0800
Message-ID: <200802081120.m18BK8HR021632@imap1.linux-foundation.org>
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	sam@ravnborg.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60012 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964890AbYBHLVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 06:21:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

gcc-3.4.4 on powerpc:

drivers/net/bnx2.c:67: error: version causes a section type conflict

Cc: Jeff Garzik <jeff@garzik.org>
Cc: Sam Ravnborg <sam@ravnborg.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/bnx2.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/bnx2.c~bnx2c-section-fix drivers/net/bnx2.c
--- a/drivers/net/bnx2.c~bnx2c-section-fix
+++ a/drivers/net/bnx2.c
@@ -64,7 +64,7 @@
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT  (5*HZ)
 
-static const char version[] __devinitdata =
+static char version[] __devinitdata =
 	"Broadcom NetXtreme II Gigabit Ethernet Driver " DRV_MODULE_NAME " v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("Michael Chan <mchan@broadcom.com>");
@@ -90,7 +90,7 @@ typedef enum {
 } board_t;
 
 /* indexed by board_t, above */
-static const struct {
+static struct {
 	char *name;
 } board_info[] __devinitdata = {
 	{ "Broadcom NetXtreme II BCM5706 1000Base-T" },
_
