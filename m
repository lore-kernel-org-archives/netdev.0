From: Ubuntu <dineshraju2007@gmail.com>
Subject: [--signoff] Changes made for Lance.c
Date: Sat, 21 Sep 2013 20:17:59 +0000
Message-ID: <1379794679-4304-1-git-send-email-ubuntu@ip-10-164-104-115.ec2.internal>
Cc: dinesh <dineshraju2007@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f48.google.com ([209.85.216.48]:60350 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993Ab3IUUSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 16:18:04 -0400
Received: by mail-qa0-f48.google.com with SMTP id hu16so562986qab.0
        for <netdev@vger.kernel.org>; Sat, 21 Sep 2013 13:18:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: dinesh <dineshraju2007@gmail.com>

---
 drivers/net/ethernet/amd/lance.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/ethernet/amd/lance.c
index 5c72843..256f590 100644
--- a/drivers/net/ethernet/amd/lance.c
+++ b/drivers/net/ethernet/amd/lance.c
@@ -754,7 +754,7 @@ lance_open(struct net_device *dev)
 	int i;
 
 	if (dev->irq == 0 ||
-		request_irq(dev->irq, lance_interrupt, 0, lp->name, dev)) {
+		request_irq(dev->irq, lance_interrupt, 0, dev->name, dev)) {
 		return -EAGAIN;
 	}
 
-- 
1.8.1.2
