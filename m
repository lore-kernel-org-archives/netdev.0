From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/53] netfilter: ftp: Remove the useless code
Date: Mon, 26 Sep 2016 01:06:16 +0200
Message-ID: <1474844823-2026-7-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54530 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941163AbcIYXH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:26 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6EBF2C0B39
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:24 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5C877DA7E9
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:24 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 57498DA7FA
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:22 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

There are some debug code which are commented out in find_pattern by #if 0.
Now remove them.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_ftp.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index d49a2d410813..e3ed20060878 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -309,19 +309,8 @@ static int find_pattern(const char *data, size_t dlen,
 		else return 0;
 	}
 
-	if (strncasecmp(data, pattern, plen) != 0) {
-#if 0
-		size_t i;
-
-		pr_debug("ftp: string mismatch\n");
-		for (i = 0; i < plen; i++) {
-			pr_debug("ftp:char %u `%c'(%u) vs `%c'(%u)\n",
-				 i, data[i], data[i],
-				 pattern[i], pattern[i]);
-		}
-#endif
+	if (strncasecmp(data, pattern, plen) != 0)
 		return 0;
-	}
 
 	pr_debug("Pattern matches!\n");
 	/* Now we've found the constant string, try to skip
-- 
2.1.4
