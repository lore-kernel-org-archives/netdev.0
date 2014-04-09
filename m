From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH 1/2] baycom_epp.c:#include <linux/uaccess.h>
Date: Thu, 10 Apr 2014 00:25:20 +0100
Message-ID: <1397085921-13803-1-git-send-email-paulmcquad@gmail.com>
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: t.sailer@alumni.ethz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:49149 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933869AbaDIXZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 19:25:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WARNING: Use #include <linux/uaccess.h> instead of <asm/uaccess.h>

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 drivers/net/hamradio/baycom_epp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 484f77e..3daafec 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -55,7 +55,7 @@
 #include <linux/jiffies.h>
 #include <linux/random.h>
 #include <net/ax25.h> 
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 
 /* --------------------------------------------------------------------- */
 
-- 
1.8.3.2
