From: Joe Perches <joe@perches.com>
Subject: [PATCH 05/11] drivers/net/niu.c: Use print_mac
Date: Fri, 14 Dec 2007 14:34:06 -0800
Message-ID: <1197671652-32492-5-git-send-email-joe@perches.com>
References: <1197671652-32492-1-git-send-email-joe@perches.com>
 <1197671652-32492-2-git-send-email-joe@perches.com>
 <1197671652-32492-3-git-send-email-joe@perches.com>
 <1197671652-32492-4-git-send-email-joe@perches.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4985 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757701AbXLNWeS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 17:34:18 -0500
In-Reply-To: <1197671652-32492-4-git-send-email-joe@perches.com>
Message-Id: <5766808cd4c25c37bc7b27864be04ca777b59528.1197671367.git.joe@perches.com>
In-Reply-To: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
References: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/niu.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index abfc61c..8a0f8f8 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -7392,12 +7392,10 @@ static void __devinit niu_assign_netdev_ops(struct net_device *dev)
 static void __devinit niu_device_announce(struct niu *np)
 {
 	struct net_device *dev = np->dev;
-	int i;
+	DECLARE_MAC_BUF(mac);
 
-	pr_info("%s: NIU Ethernet ", dev->name);
-	for (i = 0; i < 6; i++)
-		printk("%2.2x%c", dev->dev_addr[i],
-		       i == 5 ? '\n' : ':');
+	pr_info("%s: NIU Ethernet %s\n",
+		dev->name, print_mac(mac, dev->dev_addr));
 
 	pr_info("%s: Port type[%s] mode[%s:%s] XCVR[%s] phy[%s]\n",
 		dev->name,
-- 
1.5.3.7.949.g2221a6

