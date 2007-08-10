From: akpm@linux-foundation.org
Subject: [patch 03/28] Clean up duplicate includes in drivers/atm/
Date: Fri, 10 Aug 2007 14:11:50 -0700
Message-ID: <200708102111.l7ALBobp009373@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jesper.juhl@gmail.com, chas@cmf.nrl.navy.mil
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57014 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S942371AbXHJVMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>

This patch cleans up duplicate includes in
	drivers/atm/

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/atm/lanai.c |    1 -
 1 files changed, 1 deletion(-)

diff -puN drivers/atm/lanai.c~clean-up-duplicate-includes-in-drivers-atm drivers/atm/lanai.c
--- a/drivers/atm/lanai.c~clean-up-duplicate-includes-in-drivers-atm
+++ a/drivers/atm/lanai.c
@@ -65,7 +65,6 @@
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/interrupt.h>
-#include <linux/dma-mapping.h>
 
 /* -------------------- TUNABLE PARAMATERS: */
 
_
