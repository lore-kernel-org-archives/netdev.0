From: simran singhal <singhalsimran0@gmail.com>
Subject: [PATCH 2/2] netfilter: ipvs: Compress return logic
Date: Tue, 21 Mar 2017 18:53:19 +0530
Message-ID: <1490102599-27579-3-git-send-email-singhalsimran0@gmail.com>
References: <1490102599-27579-1-git-send-email-singhalsimran0@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        gregkh@linuxfoundation.org, outreachy-kernel@googlegroups.com,
        wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36427 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932663AbdCUNXp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 09:23:45 -0400
In-Reply-To: <1490102599-27579-1-git-send-email-singhalsimran0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify function returns by merging assignment and return into
one command line.

Signed-off-by: simran singhal <singhalsimran0@gmail.com>
---

 --This is my contribution to the netfilter project of
   Outreachy Round 14.

 net/netfilter/ipvs/ip_vs_ftp.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index d30c327..c93c937 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -482,11 +482,8 @@ static struct pernet_operations ip_vs_ftp_ops = {
 
 static int __init ip_vs_ftp_init(void)
 {
-	int rv;
-
-	rv = register_pernet_subsys(&ip_vs_ftp_ops);
 	/* rcu_barrier() is called by netns on error */
-	return rv;
+	return register_pernet_subsys(&ip_vs_ftp_ops);
 }
 
 /*
-- 
2.7.4
