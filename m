From: akpm@linux-foundation.org
Subject: [patch 3/7] bnx2x section fix
Date: Fri, 08 Feb 2008 03:11:15 -0800
Message-ID: <200802081120.m18BK73F021629@imap1.linux-foundation.org>
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	sam@ravnborg.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35843 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964897AbYBHLVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 06:21:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

gcc-3.4.4 on powerpc:

drivers/net/bnx2x.c:73: error: version causes a section type conflict

Cc: Jeff Garzik <jeff@garzik.org>
Cc: Sam Ravnborg <sam@ravnborg.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/bnx2x.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/bnx2x.c~bnx2x-section-fix drivers/net/bnx2x.c
--- a/drivers/net/bnx2x.c~bnx2x-section-fix
+++ a/drivers/net/bnx2x.c
@@ -70,7 +70,7 @@
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT      	(5*HZ)
 
-static const char version[] __devinitdata =
+static char version[] __devinitdata =
 	"Broadcom NetXtreme II 577xx 10Gigabit Ethernet Driver "
 	DRV_MODULE_NAME " " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
@@ -107,7 +107,7 @@ enum bnx2x_board_type {
 };
 
 /* indexed by board_t, above */
-static const struct {
+static struct {
 	char *name;
 } board_info[] __devinitdata = {
 	{ "Broadcom NetXtreme II BCM57710 XGb" }
_
