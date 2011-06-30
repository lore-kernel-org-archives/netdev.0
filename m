From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 1/5] fakehard: stop setting platform_data as it's unused anymore
Date: Thu, 30 Jun 2011 16:37:44 +0400
Message-ID: <1309437468-31021-2-git-send-email-dbaryshkov@gmail.com>
References: <1309437468-31021-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37174 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470Ab1F3MiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 08:38:05 -0400
Received: by mail-wy0-f174.google.com with SMTP id 8so1510445wyg.19
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2011 05:38:04 -0700 (PDT)
In-Reply-To: <1309437468-31021-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously dev.platform_data was used to store a pointer to net device.
Now this code was gone. Drop it.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 drivers/ieee802154/fakehard.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehard.c
index a5a49a1..eb0e2cc 100644
--- a/drivers/ieee802154/fakehard.c
+++ b/drivers/ieee802154/fakehard.c
@@ -370,8 +370,6 @@ static int __devinit ieee802154fake_probe(struct platform_device *pdev)
 		return -ENOMEM;
 	}
 
-	phy->dev.platform_data = dev;
-
 	memcpy(dev->dev_addr, "\xba\xbe\xca\xfe\xde\xad\xbe\xef",
 			dev->addr_len);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
-- 
1.7.5.4

