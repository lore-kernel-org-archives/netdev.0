From: Jeffrin Jose <ahiliation@yahoo.co.in>
Subject: [PATCH 1/1] net:ipv6:fixed a trailing white space issue.
Date: Sat, 19 May 2012 17:15:21 +0530
Message-ID: <1337427921-2848-1-git-send-email-ahiliation@yahoo.co.in>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ahiliation@yahoo.co.in
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed a trailing white space issue found by
checkpatch.pl tool in net/ipv6/udp.c

Signed-off-by: Jeffrin Jose <ahiliation@yahoo.co.in>
---
 net/ipv6/udp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index c1d91a7..847253c 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -103,7 +103,7 @@ int udp_v6_get_port(struct sock *sk, unsigned short snum)
 {
 	unsigned int hash2_nulladdr =
 		udp6_portaddr_hash(sock_net(sk), &in6addr_any, snum);
-	unsigned int hash2_partial = 
+	unsigned int hash2_partial =
 		udp6_portaddr_hash(sock_net(sk), &inet6_sk(sk)->rcv_saddr, 0);
 
 	/* precompute partial secondary hash */
-- 
1.7.10
