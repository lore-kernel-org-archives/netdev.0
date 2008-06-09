From: akpm@linux-foundation.org
Subject: [patch 1/4] drivers/atm/eni.h: remove unused macro KERNEL_OFFSET
Date: Mon, 09 Jun 2008 16:31:59 -0700
Message-ID: <200806092331.m59NVxYc014553@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	rautelap@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57138 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755827AbYFIXcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 19:32:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pradeep Singh Rautela <rautelap@gmail.com>

KERNEL_OFFSET macro in eni.h is not required as it is not used anywhere. 
Remove the unused macro from eni.h header file.

Signed-off-by: Pradeep Singh <rautelap@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/atm/eni.h |    1 -
 1 file changed, 1 deletion(-)

diff -puN drivers/atm/eni.h~drivers-atm-enih-remove-unused-macro-kernel_offset drivers/atm/eni.h
--- a/drivers/atm/eni.h~drivers-atm-enih-remove-unused-macro-kernel_offset
+++ a/drivers/atm/eni.h
@@ -18,7 +18,6 @@
 #include "midway.h"
 
 
-#define KERNEL_OFFSET	0xC0000000	/* kernel 0x0 is at phys 0xC0000000 */
 #define DEV_LABEL	"eni"
 
 #define UBR_BUFFER	(128*1024)	/* UBR buffer size */
_
