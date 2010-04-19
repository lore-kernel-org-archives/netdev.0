From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] rps: static functions
Date: Mon, 19 Apr 2010 23:26:35 +0200
Message-ID: <1271712395.3845.98.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:45503 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258Ab0DSVcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 17:32:47 -0400
Received: by bwz19 with SMTP id 19so435bwz.21
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 14:32:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

store_rps_map() & store_rps_dev_flow_table_cnt() are static.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 143052a..c57c4b2 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -550,7 +550,7 @@ static void rps_map_release(struct rcu_head *rcu)
 	kfree(map);
 }
 
-ssize_t store_rps_map(struct netdev_rx_queue *queue,
+static ssize_t store_rps_map(struct netdev_rx_queue *queue,
 		      struct rx_queue_attribute *attribute,
 		      const char *buf, size_t len)
 {
@@ -635,7 +635,7 @@ static void rps_dev_flow_table_release(struct rcu_head *rcu)
 	schedule_work(&table->free_work);
 }
 
-ssize_t store_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
+static ssize_t store_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
 				     struct rx_queue_attribute *attr,
 				     const char *buf, size_t len)
 {


