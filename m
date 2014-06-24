From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] trivial: net: filter: Fix typo in comment
Date: Tue, 24 Jun 2014 15:33:20 +0200
Message-ID: <1403616802-25743-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:57136 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751984AbaFXNdj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 09:33:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/core/filter.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 735fad8..243fb5d 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1382,7 +1382,7 @@ static struct sk_filter *__sk_migrate_realloc(struct sk_filter *fp,
 	fp_new = sock_kmalloc(sk, len, GFP_KERNEL);
 	if (fp_new) {
 		*fp_new = *fp;
-		/* As we're kepping orig_prog in fp_new along,
+		/* As we're keeping orig_prog in fp_new along,
 		 * we need to make sure we're not evicting it
 		 * from the old fp.
 		 */
-- 
1.7.9.5
