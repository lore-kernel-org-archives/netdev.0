From: Jeffrin Jose <ahiliation@yahoo.co.in>
Subject: [PATCH 1/1] net:ipv6:fixed space issues relating to operators.
Date: Sat, 19 May 2012 17:29:04 +0530
Message-ID: <1337428744-2935-1-git-send-email-ahiliation@yahoo.co.in>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ahiliation@yahoo.co.in
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed space issues relating to operators found by
checkpatch.pl tool in net/ipv6/udp.c

Signed-off-by: Jeffrin Jose <ahiliation@yahoo.co.in>
---
 net/ipv6/udp.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 847253c..f05099f 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -349,7 +349,7 @@ int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 	bool slow;
 
 	if (addr_len)
-		*addr_len=sizeof(struct sockaddr_in6);
+		*addr_len = sizeof(struct sockaddr_in6);
 
 	if (flags & MSG_ERRQUEUE)
 		return ipv6_recv_error(sk, msg, len);
@@ -1379,7 +1379,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 	 * do checksum of UDP packets sent as multiple IP fragments.
 	 */
 	offset = skb_checksum_start_offset(skb);
-	csum = skb_checksum(skb, offset, skb->len- offset, 0);
+	csum = skb_checksum(skb, offset, skb->len - offset, 0);
 	offset += skb->csum_offset;
 	*(__sum16 *)(skb->data + offset) = csum_fold(csum);
 	skb->ip_summed = CHECKSUM_NONE;
-- 
1.7.10
