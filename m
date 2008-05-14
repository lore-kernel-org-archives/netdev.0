From: akpm@linux-foundation.org
Subject: [patch 09/11] drivers/net/tokenring/olympic.c: fix warning
Date: Wed, 14 May 2008 16:20:15 -0700
Message-ID: <200805142320.m4ENKGSF026635@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, greg@kroah.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40188 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754516AbYENXUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:20:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

When dev_name() is changed to return `const char *':

drivers/net/tokenring/olympic.c: In function 'olympic_probe':
drivers/net/tokenring/olympic.c:234: warning: assignment discards qualifiers from pointer target type

Cc: Jeff Garzik <jeff@garzik.org>
Cc: Greg KH <greg@kroah.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tokenring/olympic.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/tokenring/olympic.h~drivers-net-tokenring-olympicc-fix-warning drivers/net/tokenring/olympic.h
--- a/drivers/net/tokenring/olympic.h~drivers-net-tokenring-olympicc-fix-warning
+++ a/drivers/net/tokenring/olympic.h
@@ -254,7 +254,7 @@ struct olympic_private {
 	u8 __iomem *olympic_mmio;
 	u8 __iomem *olympic_lap;
 	struct pci_dev *pdev ; 
-	char *olympic_card_name ; 
+	const char *olympic_card_name;
 
 	spinlock_t olympic_lock ; 
 
_
