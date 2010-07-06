From: George Kadianakis <desnacked@gmail.com>
Subject: [PATCH] net/ipv4/ip_output.c: Removal of unused variable in ip_fragment()
Date: Wed, 07 Jul 2010 00:44:12 +0300
Message-ID: <874ogctheb.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: George Kadianakis <desnacked@gmail.com>

Removal of unused integer variable in ip_fragment().

Signed-off-by: George Kadianakis <desnacked@gmail.com>
---
 net/ipv4/ip_output.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 041d41d..a83b876 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -442,7 +442,6 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 {
 	struct iphdr *iph;
-	int raw = 0;
 	int ptr;
 	struct net_device *dev;
 	struct sk_buff *skb2;
@@ -580,7 +579,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 
 slow_path:
 	left = skb->len - hlen;		/* Space per frame */
-	ptr = raw + hlen;		/* Where to start from */
+	ptr = hlen;		/* Where to start from */
 
 	/* for bridged IP traffic encapsulated inside f.e. a vlan header,
 	 * we need to make room for the encapsulating header
