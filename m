From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/11] drivers/net/smc911x.c: Use print_mac
Date: Fri, 14 Dec 2007 14:34:08 -0800
Message-ID: <1197671652-32492-7-git-send-email-joe@perches.com>
References: <1197671652-32492-1-git-send-email-joe@perches.com>
 <1197671652-32492-2-git-send-email-joe@perches.com>
 <1197671652-32492-3-git-send-email-joe@perches.com>
 <1197671652-32492-4-git-send-email-joe@perches.com>
 <1197671652-32492-5-git-send-email-joe@perches.com>
 <1197671652-32492-6-git-send-email-joe@perches.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4989 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755713AbXLNWeT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 17:34:19 -0500
In-Reply-To: <1197671652-32492-6-git-send-email-joe@perches.com>
Message-Id: <d1a31f8685a70676de100f9521e9f5b6f4255fe5.1197671367.git.joe@perches.com>
In-Reply-To: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
References: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/smc911x.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 76cc1d3..f503b73 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -2086,10 +2086,9 @@ static int __init smc911x_probe(struct net_device *dev, unsigned long ioaddr)
 					"set using ifconfig\n", dev->name);
 		} else {
 			/* Print the Ethernet address */
-			printk("%s: Ethernet addr: ", dev->name);
-			for (i = 0; i < 5; i++)
-				printk("%2.2x:", dev->dev_addr[i]);
-			printk("%2.2x\n", dev->dev_addr[5]);
+			DECLARE_MAC_BUF(mac);
+			printk("%s: Ethernet addr: %s\n",
+			       dev->name, print_mac(mac, dev->dev_addr));
 		}
 
 		if (lp->phy_type == 0) {
-- 
1.5.3.7.949.g2221a6

