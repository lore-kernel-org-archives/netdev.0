From: Patrick McHardy <kaber@trash.net>
Subject: [XFRM]: Fix protocol field value for outgoing IPv6 GSO packets
Date: Tue, 25 Jul 2006 02:09:26 +0200
Message-ID: <44C56136.50600@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010804050402050802020300"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:30875 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932342AbWGYALD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 20:11:03 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010804050402050802020300
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

This appears to be a mistake, but I didn't follow the GSO stuff
very closely, so there could be some non-obvious reason.



--------------010804050402050802020300
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[XFRM]: Fix protocol field value for outgoing IPv6 GSO packets

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8035f60a607630459e4440dbbc5a20f3cfbf97ac
tree f1a7061cfd1f923b3991ee8f449cffce86870a3e
parent 440848a8e33fc1927bab45bd73f6c8e042ea7abd
author Patrick McHardy <kaber@trash.net> Tue, 25 Jul 2006 02:02:00 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 25 Jul 2006 02:02:00 +0200

 net/ipv6/xfrm6_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 0eea60e..c8c8b44 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -125,7 +125,7 @@ static int xfrm6_output_finish(struct sk
 	if (!skb_is_gso(skb))
 		return xfrm6_output_finish2(skb);
 
-	skb->protocol = htons(ETH_P_IP);
+	skb->protocol = htons(ETH_P_IPV6);
 	segs = skb_gso_segment(skb, 0);
 	kfree_skb(skb);
 	if (unlikely(IS_ERR(segs)))

--------------010804050402050802020300--
