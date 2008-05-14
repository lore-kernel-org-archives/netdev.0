From: akpm@linux-foundation.org
Subject: [patch 08/11] drivers/net/tokenring/3c359.c: squish a warning
Date: Wed, 14 May 2008 16:20:15 -0700
Message-ID: <200805142320.m4ENKF7C026632@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, greg@kroah.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59806 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755324AbYENX0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:26:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

When dev_name() is changed to return `const char *':

drivers/net/tokenring/3c359.c: In function 'xl_probe':
drivers/net/tokenring/3c359.c:318: warning: assignment discards qualifiers from pointer target type

Cc: Jeff Garzik <jeff@garzik.org>
Cc: Greg KH <greg@kroah.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tokenring/3c359.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/tokenring/3c359.h~drivers-net-tokenring-3c359c-squish-a-warning drivers/net/tokenring/3c359.h
--- a/drivers/net/tokenring/3c359.h~drivers-net-tokenring-3c359c-squish-a-warning
+++ a/drivers/net/tokenring/3c359.h
@@ -264,7 +264,7 @@ struct xl_private {
 	u16 asb;
 
 	u8 __iomem *xl_mmio;
-	char *xl_card_name;
+	const char *xl_card_name;
 	struct pci_dev *pdev ; 
 	
 	spinlock_t xl_lock ; 
_
