From: akpm@linux-foundation.org
Subject: [patch 06/10] Net: ibm_newemac, remove SPIN_LOCK_UNLOCKED
Date: Thu, 13 Dec 2007 16:02:57 -0800
Message-ID: <200712140002.lBE02vqD025526@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jirislaby@gmail.com, jgarzik@pobox.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57320 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755947AbXLNAJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 19:09:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jirislaby@gmail.com>

SPIN_LOCK_UNLOCKED is deprecated, use DEFINE_SPINLOCK instead

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ibm_newemac/debug.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/ibm_newemac/debug.c~net-ibm_newemac-remove-spin_lock_unlocked drivers/net/ibm_newemac/debug.c
--- a/drivers/net/ibm_newemac/debug.c~net-ibm_newemac-remove-spin_lock_unlocked
+++ a/drivers/net/ibm_newemac/debug.c
@@ -21,7 +21,7 @@
 
 #include "core.h"
 
-static spinlock_t emac_dbg_lock = SPIN_LOCK_UNLOCKED;
+static DEFINE_SPINLOCK(emac_dbg_lock);
 
 static void emac_desc_dump(struct emac_instance *p)
 {
_
