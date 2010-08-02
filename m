From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: cleanup inclusion
Date: Tue,  3 Aug 2010 06:11:41 +0800
Message-ID: <1280787101-5589-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:53083 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755184Ab0HCFn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 01:43:59 -0400
Received: by pwi5 with SMTP id 5so1543500pwi.19
        for <netdev@vger.kernel.org>; Mon, 02 Aug 2010 22:43:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit ab95bfe01f9872459c8678572ccadbf646badad0 replaces bridge and macvlan
hooks in __netif_receive_skb(), so dev.c doesn't need to include their headers.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/core/dev.c |    2 --
 1 file changed, 2 deletions(-)
diff --git a/net/core/dev.c b/net/core/dev.c
index 5d1282d..8c663db 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -101,8 +101,6 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/stat.h>
-#include <linux/if_bridge.h>
-#include <linux/if_macvlan.h>
 #include <net/dst.h>
 #include <net/pkt_sched.h>
 #include <net/checksum.h>
