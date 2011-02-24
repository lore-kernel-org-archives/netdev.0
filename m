From: David Miller <davem@davemloft.net>
Subject: [PATCH 06/26] xfrm: Const'ify address arguments to xfrm_addr_cmp()
Date: Wed, 23 Feb 2011 23:13:12 -0800 (PST)
Message-ID: <20110223.231312.39184712.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37463
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932371Ab1BXHMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:12:35 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B802224C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:13:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 18f115a..1c82b94 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1520,7 +1520,8 @@ struct scatterlist;
 typedef int (icv_update_fn_t)(struct hash_desc *, struct scatterlist *,
 			      unsigned int);
 
-static inline int xfrm_addr_cmp(xfrm_address_t *a, xfrm_address_t *b,
+static inline int xfrm_addr_cmp(const xfrm_address_t *a,
+				const xfrm_address_t *b,
 				int family)
 {
 	switch (family) {
-- 
1.7.4.1

