From: akpm@linux-foundation.org
Subject: [patch 3/3] drivers/net/82596.c: fix warning
Date: Tue, 20 Jul 2010 15:25:18 -0700
Message-ID: <201007202225.o6KMPIQd021449@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	segooon@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48170 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932070Ab0GTWZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 18:25:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

drivers/net/82596.c: In function 'i596_open':
drivers/net/82596.c:1044: warning: label 'err_irq_dev' defined but not used

Caused by "82596: free resources on error"

Cc: Kulikov Vasiliy <segooon@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/82596.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/82596.c~drivers-net-82596c-fix-warning drivers/net/82596.c
--- a/drivers/net/82596.c~drivers-net-82596c-fix-warning
+++ a/drivers/net/82596.c
@@ -1040,8 +1040,8 @@ err_queue:
 err_irq_56:
 #ifdef ENABLE_MVME16x_NET
 	free_irq(0x56, dev);
-#endif
 err_irq_dev:
+#endif
 	free_irq(dev->irq, dev);
 
 	return res;
_
