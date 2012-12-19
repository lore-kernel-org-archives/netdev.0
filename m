From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 2/4] solos-pci: remove superfluous debug output
Date: Wed, 19 Dec 2012 21:01:19 +0000
Message-ID: <1355950881-31550-2-git-send-email-dwmw2@infradead.org>
References: <1355950881-31550-1-git-send-email-dwmw2@infradead.org>
Cc: Nathan Williams <nathan@traverse.com.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:53381 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017Ab2LSVBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 16:01:35 -0500
In-Reply-To: <1355950881-31550-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Williams <nathan@traverse.com.au>

Signed-off-by: Nathan Williams <nathan@traverse.com.au>
Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 473d808..50e5c56 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -452,7 +452,6 @@ static ssize_t console_show(struct device *dev, struct device_attribute *attr,
 
 	len = skb->len;
 	memcpy(buf, skb->data, len);
-	dev_dbg(&card->dev->dev, "len: %d\n", len);
 
 	kfree_skb(skb);
 	return len;
-- 
1.8.0.1
