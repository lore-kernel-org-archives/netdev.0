From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 5/5] irda: irnet: add member name to the miscdevice declaration
Date: Thu, 15 Dec 2016 11:42:50 +0100
Message-ID: <20161215104250.16813-5-clabbe.montjoie@gmail.com>
References: <20161215104250.16813-1-clabbe.montjoie@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: arnd@arndb.de, gregkh@linuxfoundation.org, samuel@sortiz.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36050 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932591AbcLOLC5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 06:02:57 -0500
In-Reply-To: <20161215104250.16813-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the struct miscdevice have many members, it is dangerous to init
it without members name relying only on member order.

This patch add member name to the init declaration.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 net/irda/irnet/irnet_ppp.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/irda/irnet/irnet_ppp.h b/net/irda/irnet/irnet_ppp.h
index ec092c9..1ed17f9 100644
--- a/net/irda/irnet/irnet_ppp.h
+++ b/net/irda/irnet/irnet_ppp.h
@@ -108,9 +108,9 @@ static const struct file_operations irnet_device_fops =
 /* Structure so that the misc major (drivers/char/misc.c) take care of us... */
 static struct miscdevice irnet_misc_device =
 {
-	IRNET_MINOR,
-	"irnet",
-	&irnet_device_fops
+	.minor = IRNET_MINOR,
+	.name = "irnet",
+	.file_operations = &irnet_device_fops
 };
 
 #endif /* IRNET_PPP_H */
-- 
2.10.2
