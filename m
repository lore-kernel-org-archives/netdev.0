From: Jeffrin Jose <ahiliation@yahoo.co.in>
Subject: [PATCH 4/4]net:ipv6:fixed space issues relating to >= and !=
Date: Tue, 22 May 2012 00:35:01 +0530
Message-ID: <1337627101-3386-1-git-send-email-ahiliation@yahoo.co.in>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ahiliation@yahoo.co.in
To: davem@davemloft.net, edumazet@google.com, loke.chetan@gmail.com,
	herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed space issues related to >= and != operators
in net/ipv6/mcast.c found by cheackpatch.pl tool

Signed-off-by: Jeffrin Jose <ahiliation@yahoo.co.in>
---
 net/ipv6/mcast.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 541893d..9de31b3 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -427,7 +427,7 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 	}
 	if (rv == 0)		/* address already there is an error */
 		goto done;
-	for (j = psl->sl_count-1; j>=i; j--)
+	for (j = psl->sl_count-1; j >= i; j--)
 		psl->sl_addr[j+1] = psl->sl_addr[j];
 	psl->sl_addr[i] = *source;
 	psl->sl_count++;
@@ -987,7 +987,7 @@ int ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 						psf->sf_count[MCAST_EXCLUDE] !=
 						mc->mca_sfcount[MCAST_EXCLUDE];
 				else
-					rv = mc->mca_sfcount[MCAST_EXCLUDE] !=0;
+					rv = mc->mca_sfcount[MCAST_EXCLUDE] != 0;
 				spin_unlock_bh(&mc->mca_lock);
 			} else
 				rv = 1; /* don't filter unspecified source */
-- 
1.7.10
