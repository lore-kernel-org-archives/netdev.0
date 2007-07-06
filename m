From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: macmace: use "unsigned long flags;"
Date: Fri, 6 Jul 2007 18:57:13 +0400
Message-ID: <20070706145713.GC11067@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fthain@telegraphics.com.au
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:35781 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754168AbXGFO57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 10:57:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Code will do local_irq_save() on it.

Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
---

 drivers/net/macmace.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/macmace.c
+++ b/drivers/net/macmace.c
@@ -577,7 +577,7 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
 	struct mace_data *mp = netdev_priv(dev);
 	volatile struct mace *mb = mp->mace;
 	int intr, fs;
-	unsigned int flags;
+	unsigned long flags;
 
 	/* don't want the dma interrupt handler to fire */
 	local_irq_save(flags);


