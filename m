From: Ferenc Wagner <wferi@niif.hu>
Subject: [PATCH 2/2] netconsole: clarify stopping message
Date: Thu,  6 Jan 2011 16:11:20 +0100
Message-ID: <99af52dbb92137be928c164d9e87cc797db05513.1294326001.git.wferi@niif.hu>
References: <cover.1294326001.git.wferi@niif.hu>
Cc: Ferenc Wagner <wferi@niif.hu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs22.lvs.iif.hu ([193.225.14.172]:51320 "EHLO rs22.lvs.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753505Ab1AFPsB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 10:48:01 -0500
In-Reply-To: <cover.1294326001.git.wferi@niif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ferenc Wagner <wferi@niif.hu>
---
 drivers/net/netconsole.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index b2ad998..dfb67eb 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -699,8 +699,8 @@ static int netconsole_netdev_event(struct notifier_block *this,
 	}
 	spin_unlock_irqrestore(&target_list_lock, flags);
 	if (stopped && (event == NETDEV_UNREGISTER || event == NETDEV_BONDING_DESLAVE))
-		printk(KERN_INFO "netconsole: network logging stopped, "
-			"interface %s %s\n",  dev->name,
+		printk(KERN_INFO "netconsole: network logging stopped on "
+			"interface %s as it %s\n",  dev->name,
 			event == NETDEV_UNREGISTER ? "unregistered" : "released slaves");
 
 done:
-- 
1.6.5

