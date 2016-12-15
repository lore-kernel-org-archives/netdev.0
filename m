From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 2/5] irda: irnet: Move linux/miscdevice.h include
Date: Thu, 15 Dec 2016 11:42:47 +0100
Message-ID: <20161215104250.16813-2-clabbe.montjoie@gmail.com>
References: <20161215104250.16813-1-clabbe.montjoie@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: arnd@arndb.de, gregkh@linuxfoundation.org, samuel@sortiz.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:33466 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753745AbcLOLxN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 06:53:13 -0500
In-Reply-To: <20161215104250.16813-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only use of miscdevice is irda_ppp so no need to include
linux/miscdevice.h for all irda files.
This patch move the linux/miscdevice.h include to irnet_ppp.h

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 net/irda/irnet/irnet.h     | 1 -
 net/irda/irnet/irnet_ppp.h | 1 +
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/irda/irnet/irnet.h b/net/irda/irnet/irnet.h
index 8d65bb9..c69f0f3 100644
--- a/net/irda/irnet/irnet.h
+++ b/net/irda/irnet/irnet.h
@@ -245,7 +245,6 @@
 #include <linux/tty.h>
 #include <linux/proc_fs.h>
 #include <linux/netdevice.h>
-#include <linux/miscdevice.h>
 #include <linux/poll.h>
 #include <linux/capability.h>
 #include <linux/ctype.h>	/* isspace() */
diff --git a/net/irda/irnet/irnet_ppp.h b/net/irda/irnet/irnet_ppp.h
index 9402258..693ebc0 100644
--- a/net/irda/irnet/irnet_ppp.h
+++ b/net/irda/irnet/irnet_ppp.h
@@ -15,6 +15,7 @@
 /***************************** INCLUDES *****************************/
 
 #include "irnet.h"		/* Module global include */
+#include <linux/miscdevice.h>
 
 /************************ CONSTANTS & MACROS ************************/
 
-- 
2.10.2
