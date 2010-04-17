From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] rps: rps_sock_flow_table is mostly read
Date: Sat, 17 Apr 2010 09:52:13 +0200
Message-ID: <1271490733.16881.4588.camel@edumazet-laptop>
References: <20100415.233334.242114544.davem@davemloft.net>
	 <1271401007.16881.3762.camel@edumazet-laptop>
	 <1271402283.16881.3791.camel@edumazet-laptop>
	 <20100416.002632.83844236.davem@davemloft.net>
	 <1271404097.16881.3827.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:34045 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753990Ab0DQHwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Apr 2010 03:52:19 -0400
Received: by bwz25 with SMTP id 25so3859291bwz.28
        for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 00:52:17 -0700 (PDT)
In-Reply-To: <1271404097.16881.3827.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index d7107ac..7abf959 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2205,7 +2205,7 @@ DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
 #ifdef CONFIG_RPS
 
 /* One global table that all flow-based protocols share. */
-struct rps_sock_flow_table *rps_sock_flow_table;
+struct rps_sock_flow_table *rps_sock_flow_table __read_mostly;
 EXPORT_SYMBOL(rps_sock_flow_table);
 
 /*


