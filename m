From: David Miller <davem@davemloft.net>
Subject: [PATCH 12/20] net: Mark flowi arg to flow_cache_uli_match() const.
Date: Tue, 22 Feb 2011 19:54:44 -0800 (PST)
Message-ID: <20110222.195444.246513383.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32848
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753629Ab1BWDyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:54:08 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id F027124C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/flow.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 1ae901f..f4270d4 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -112,7 +112,8 @@ extern struct flow_cache_object *flow_cache_lookup(
 extern void flow_cache_flush(void);
 extern atomic_t flow_cache_genid;
 
-static inline int flow_cache_uli_match(struct flowi *fl1, struct flowi *fl2)
+static inline int flow_cache_uli_match(const struct flowi *fl1,
+				       const struct flowi *fl2)
 {
 	return (fl1->proto == fl2->proto &&
 		!memcmp(&fl1->uli_u, &fl2->uli_u, sizeof(fl1->uli_u)));
-- 
1.7.4.1

