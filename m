From: David Miller <davem@davemloft.net>
Subject: [PATCH 38/42] netfilter: nf_conntrack_standalone: Fix
 set-but-unused variables.
Date: Sun, 17 Apr 2011 17:34:20 -0700 (PDT)
Message-ID: <20110417.173420.91343222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51099
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753961Ab1DRAez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:55 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 21B3324C089
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:34:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'ret' is set but unused in ct_seq_show().

This was obviously meant to be used to propagate error codes
to the caller, so make it so.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nf_conntrack_standalone.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 0ae1428..05e9feb 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -245,7 +245,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 	ret = 0;
 release:
 	nf_ct_put(ct);
-	return 0;
+	return ret;
 }
 
 static const struct seq_operations ct_seq_ops = {
-- 
1.7.4.3

