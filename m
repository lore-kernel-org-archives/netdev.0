From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH 3/3] net:hamradio:6pack.c:#include <linux/uaccess.h>
Date: Wed,  9 Apr 2014 23:11:08 +0100
Message-ID: <1397081468-10301-1-git-send-email-paulmcquad@gmail.com>
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ajk@comnets.uni-bremen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38948 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934430AbaDIWLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 18:11:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WARNING: Use #include <linux/uaccess.h> instead of <asm/uaccess.h>

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 drivers/net/hamradio/6pack.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 66e2b19..4cd3acd 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -13,7 +13,7 @@
  */
 
 #include <linux/module.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/bitops.h>
 #include <linux/string.h>
 #include <linux/mm.h>
-- 
1.8.3.2
