From: David Miller <davem@davemloft.net>
Subject: [PATCH 07/26] xfrm: Const'ify address argument to xfrm_addr_any()
Date: Wed, 23 Feb 2011 23:13:14 -0800 (PST)
Message-ID: <20110223.231314.59683122.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37466
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932371Ab1BXHMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:12:38 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D4C2D24C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:13:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 1c82b94..b60f956 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -954,7 +954,7 @@ secpath_reset(struct sk_buff *skb)
 }
 
 static inline int
-xfrm_addr_any(xfrm_address_t *addr, unsigned short family)
+xfrm_addr_any(const xfrm_address_t *addr, unsigned short family)
 {
 	switch (family) {
 	case AF_INET:
-- 
1.7.4.1

