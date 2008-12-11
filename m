From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc911x: make smsc911x_poll_controller static
Date: Thu, 11 Dec 2008 10:55:36 +0000
Message-ID: <1228992936-16674-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:60034 "EHLO
	drevil2.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754925AbYLKKzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 05:55:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 4b8ff84..ae32716 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1526,7 +1526,7 @@ static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id)
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-void smsc911x_poll_controller(struct net_device *dev)
+static void smsc911x_poll_controller(struct net_device *dev)
 {
 	disable_irq(dev->irq);
 	smsc911x_irqhandler(0, dev);
-- 
1.5.6.5

