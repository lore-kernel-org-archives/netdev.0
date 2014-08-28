From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 3/4] include/linux/phonedev.h: Remove unused header
Date: Thu, 28 Aug 2014 13:44:33 +0200
Message-ID: <1409226274-3202-4-git-send-email-linux@rasmusvillemoes.dk>
References: <1409226274-3202-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:61300 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbaH1LpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 07:45:01 -0400
Received: by mail-lb0-f177.google.com with SMTP id z11so737567lbi.36
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2014 04:45:00 -0700 (PDT)
In-Reply-To: <1409226274-3202-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The header file include/linux/phonedev.h does not seem to be used
anywhere. It was orphaned by 7326446c "Staging: remove telephony
drivers". Remove it.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 include/linux/phonedev.h | 25 -------------------------
 1 file changed, 25 deletions(-)
 delete mode 100644 include/linux/phonedev.h

diff --git a/include/linux/phonedev.h b/include/linux/phonedev.h
deleted file mode 100644
index 4269de9..0000000
--- a/include/linux/phonedev.h
+++ /dev/null
@@ -1,25 +0,0 @@
-#ifndef __LINUX_PHONEDEV_H
-#define __LINUX_PHONEDEV_H
-
-#include <linux/types.h>
-
-#ifdef __KERNEL__
-
-#include <linux/poll.h>
-
-struct phone_device {
-	struct phone_device *next;
-	const struct file_operations *f_op;
-	int (*open) (struct phone_device *, struct file *);
-	int board;		/* Device private index */
-	int minor;
-};
-
-extern int phonedev_init(void);
-#define PHONE_MAJOR	100
-extern int phone_register_device(struct phone_device *, int unit);
-#define PHONE_UNIT_ANY	-1
-extern void phone_unregister_device(struct phone_device *);
-
-#endif
-#endif
-- 
2.0.4
