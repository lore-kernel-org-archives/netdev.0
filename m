From: akpm@linux-foundation.org
Subject: [patch 5/7] via-velocity section fix
Date: Fri, 08 Feb 2008 03:11:16 -0800
Message-ID: <200802081120.m18BK8ac021635@imap1.linux-foundation.org>
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	sam@ravnborg.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50522 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964889AbYBHLVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 06:21:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

gcc-3.4.4 on powerpc:

drivers/net/via-velocity.c:443: error: chip_info_table causes a section type conflict

on this one I had to remove the __devinitdata too.  Don't know why.

Cc: Jeff Garzik <jeff@garzik.org>
Cc: Sam Ravnborg <sam@ravnborg.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/via-velocity.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/via-velocity.c~via-velocity-section-fix drivers/net/via-velocity.c
--- a/drivers/net/via-velocity.c~via-velocity-section-fix
+++ a/drivers/net/via-velocity.c
@@ -440,7 +440,7 @@ static void velocity_unregister_notifier
  *	Internal board variants. At the moment we have only one
  */
 
-static const struct velocity_info_tbl chip_info_table[] __devinitdata = {
+static struct velocity_info_tbl chip_info_table[] = {
 	{CHIP_TYPE_VT6110, "VIA Networking Velocity Family Gigabit Ethernet Adapter", 1, 0x00FFFFFFUL},
 	{ }
 };
_
