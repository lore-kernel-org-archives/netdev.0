From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Print functions in /proc/net/ptype without the offset.
Date: Mon, 25 Mar 2013 14:13:14 -0400 (EDT)
Message-ID: <20130325.141314.736565121605941076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932530Ab3CYSNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 14:13:16 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 2DD9B5840C1
	for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 11:13:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It's always zero.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/net-procfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/net-procfs.c b/net/core/net-procfs.c
index 3174f19..569d355 100644
--- a/net/core/net-procfs.c
+++ b/net/core/net-procfs.c
@@ -271,7 +271,7 @@ static int ptype_seq_show(struct seq_file *seq, void *v)
 		else
 			seq_printf(seq, "%04x", ntohs(pt->type));
 
-		seq_printf(seq, " %-8s %pF\n",
+		seq_printf(seq, " %-8s %pf\n",
 			   pt->dev ? pt->dev->name : "", pt->func);
 	}
 
-- 
1.7.11.7
