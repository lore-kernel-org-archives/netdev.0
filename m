From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: rds: remove duplication type definitions
Date: Mon, 23 Aug 2010 10:41:59 +0800
Message-ID: <1282531319-13083-1-git-send-email-xiaosuo@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:34444 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749Ab0HWCmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 22:42:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__be* are defined in linux/types.h now, and in fact, rds.h isn't exported
to user space even.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/linux/rds.h |    9 ---------
 1 file changed, 9 deletions(-)
diff --git a/include/linux/rds.h b/include/linux/rds.h
index 24bce3d..7f3971d 100644
--- a/include/linux/rds.h
+++ b/include/linux/rds.h
@@ -36,15 +36,6 @@
 
 #include <linux/types.h>
 
-/* These sparse annotated types shouldn't be in any user
- * visible header file. We should clean this up rather
- * than kludging around them. */
-#ifndef __KERNEL__
-#define __be16	u_int16_t
-#define __be32	u_int32_t
-#define __be64	u_int64_t
-#endif
-
 #define RDS_IB_ABI_VERSION		0x301
 
 /*
