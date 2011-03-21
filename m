From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] fix incorrect spelling in drop monitor protocol
Date: Mon, 21 Mar 2011 16:30:15 -0400
Message-ID: <1300739415-26656-1-git-send-email-nhorman@tuxdriver.com>
Cc: davem@davemloft.net, Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52739 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754075Ab1CUUaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 16:30:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was pointed out to me recently that my spelling could be better :)

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 net/core/drop_monitor.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 36e603c..706502f 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -350,7 +350,7 @@ static int __init init_net_drop_monitor(void)
 	struct per_cpu_dm_data *data;
 	int cpu, rc;
 
-	printk(KERN_INFO "Initalizing network drop monitor service\n");
+	printk(KERN_INFO "Initializing network drop monitor service\n");
 
 	if (sizeof(void *) > 8) {
 		printk(KERN_ERR "Unable to store program counters on this arch, Drop monitor failed\n");
-- 
1.7.4

