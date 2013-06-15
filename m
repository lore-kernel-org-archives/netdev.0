From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next] inet: frag , remove an empty ifdef.
Date: Sat, 15 Jun 2013 23:04:56 +0300
Message-ID: <1371326696-32561-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:52297 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754414Ab3FOUFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jun 2013 16:05:23 -0400
Received: by mail-ee0-f41.google.com with SMTP id d17so991493eek.0
        for <netdev@vger.kernel.org>; Sat, 15 Jun 2013 13:05:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes an empty ifdef from inet_frag_intern()
in net/ipv4/inet_fragment.c.

commit b67bfe0d42cac56c512dd5da4b1b347a23f4b70a
(hlist: drop the node parameter from iterators) removed hlist from
net/ipv4/inet_fragment.c, but did not remove the enclosing ifdef command,
which is now empty.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 net/ipv4/inet_fragment.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 7e06641..4b86443 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -247,8 +247,6 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 {
 	struct inet_frag_bucket *hb;
 	struct inet_frag_queue *qp;
-#ifdef CONFIG_SMP
-#endif
 	unsigned int hash;
 
 	read_lock(&f->lock); /* Protects against hash rebuild */
-- 
1.8.1.4
