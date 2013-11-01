From: Ben Boeckel <mathstuf@gmail.com>
Subject: [PATCHv3 net-next 4/7] smsc911x: replace printk with netdev_ calls
Date: Fri,  1 Nov 2013 08:53:33 -0400
Message-ID: <1383310416-27177-5-git-send-email-mathstuf@gmail.com>
References: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
 <1383310416-27177-1-git-send-email-mathstuf@gmail.com>
Cc: Ben Boeckel <mathstuf@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:48102 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027Ab3KAMx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 08:53:57 -0400
Received: by mail-qa0-f46.google.com with SMTP id j15so583860qaq.12
        for <netdev@vger.kernel.org>; Fri, 01 Nov 2013 05:53:55 -0700 (PDT)
In-Reply-To: <1383310416-27177-1-git-send-email-mathstuf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Boeckel <mathstuf@gmail.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 01f8459..8564f23 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2167,7 +2167,7 @@ static int smsc911x_init(struct net_device *dev)
 		udelay(1000);
 
 	if (to == 0) {
-		pr_err("Device not READY in 100ms aborting\n");
+		netdev_err(dev, "Device not READY in 100ms aborting\n");
 		return -ENODEV;
 	}
 
-- 
1.8.4.2
