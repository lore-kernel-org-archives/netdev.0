From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [XFRM] BEET: Remove extra semicolon after if
Date: Sat, 2 Feb 2008 23:53:29 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0802022351510.2526@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1682660206-1201989209=:2526"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40142 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864AbYBBVxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 16:53:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1682660206-1201989209=:2526
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Once again, one of this kind tries to creep in.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/xfrm4_mode_beet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index e093a7b..b47030b 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -102,7 +102,7 @@ static int xfrm4_beet_input(struct xfrm_state *x, struct sk_buff *skb)
 
 		XFRM_MODE_SKB_CB(skb)->protocol = ph->nexthdr;
 
-		if (!pskb_may_pull(skb, phlen));
+		if (!pskb_may_pull(skb, phlen))
 			goto out;
 		__skb_pull(skb, phlen);
 	}
-- 
1.5.2.2

---696243703-1682660206-1201989209=:2526--
