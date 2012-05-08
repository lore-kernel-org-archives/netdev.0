From: pablo@netfilter.org
Subject: [PATCH 22/25] net: export sysctl_[r|w]mem_max symbols needed by ip_vs_sync
Date: Tue,  8 May 2012 20:38:20 +0200
Message-ID: <1336502303-1722-23-git-send-email-pablo@netfilter.org>
References: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, openbsc@lists.osmocom.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39881 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756670Ab2EHSkx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 14:40:53 -0400
In-Reply-To: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

To build ip_vs as a module sysctl_rmem_max and sysctl_wmem_max
needs to be exported.

The dependency was added by "ipvs: wakeup master thread" patch.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/core/sock.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/sock.c b/net/core/sock.c
index b8c818e..26ed27f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -259,7 +259,9 @@ static struct lock_class_key af_callback_keys[AF_MAX];
 
 /* Run time adjustable parameters. */
 __u32 sysctl_wmem_max __read_mostly = SK_WMEM_MAX;
+EXPORT_SYMBOL(sysctl_wmem_max);
 __u32 sysctl_rmem_max __read_mostly = SK_RMEM_MAX;
+EXPORT_SYMBOL(sysctl_rmem_max);
 __u32 sysctl_wmem_default __read_mostly = SK_WMEM_MAX;
 __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
 
-- 
1.7.9.5
