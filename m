From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 2/3] smsc911x: replace print_mac with %pM
Date: Thu, 19 Mar 2009 10:24:45 +0000
Message-ID: <1237458286-23421-2-git-send-email-steve.glendinning@smsc.com>
References: <1237458286-23421-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:56041 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752246AbZCSKYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 06:24:51 -0400
In-Reply-To: <1237458286-23421-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index f52bb8a..82157cd 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1914,7 +1914,6 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	unsigned int intcfg = 0;
 	int res_size, irq_flags;
 	int retval;
-	DECLARE_MAC_BUF(mac);
 
 	pr_info("%s: Driver version %s.\n", SMSC_CHIPNAME, SMSC_DRV_VERSION);
 
@@ -2049,8 +2048,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 	spin_unlock_irq(&pdata->mac_lock);
 
-	dev_info(&dev->dev, "MAC Address: %s\n",
-		 print_mac(mac, dev->dev_addr));
+	dev_info(&dev->dev, "MAC Address: %pM\n", dev->dev_addr);
 
 	return 0;
 
-- 
1.6.0.6

