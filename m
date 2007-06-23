From: Patrick McHardy <kaber@trash.net>
Subject: [SKBUFF]: Fix incorrect config #ifdef around skb_copy_secmark
Date: Sat, 23 Jun 2007 12:53:35 +0200
Message-ID: <467CFBAF.9080709@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050208090103020008090502"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51053 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753481AbXFWKxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 06:53:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050208090103020008090502
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------050208090103020008090502
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[SKBUFF]: Fix incorrect config #ifdef around skb_copy_secmark

secmark doesn't depend on CONFIG_NET_SCHED.

Signed-off-by: Patrick McHardy <kaber@trash.net>
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7c6a34e..8d43ae6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -434,8 +434,8 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 	n->tc_verd = CLR_TC_MUNGED(n->tc_verd);
 	C(iif);
 #endif
-	skb_copy_secmark(n, skb);
 #endif
+	skb_copy_secmark(n, skb);
 	C(truesize);
 	atomic_set(&n->users, 1);
 	C(head);

--------------050208090103020008090502--
