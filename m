From: Petr Holasek <pholasek@redhat.com>
Subject: [PATCH] ipv6: ipv6_create_tempaddr cleanup
Date: Fri, 30 Aug 2013 17:02:38 +0200
Message-ID: <1377874958-2426-1-git-send-email-pholasek@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Petr Holasek <pholasek@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This two-liner removes max_addresses variable which is now unecessary related
to patch [ipv6: remove max_addresses check from ipv6_create_tempaddr].

Signed-off-by: Petr Holasek <pholasek@redhat.com>
---
 net/ipv6/addrconf.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 498ea99..05c83dd 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1054,7 +1054,6 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *i
 	unsigned long regen_advance;
 	int tmp_plen;
 	int ret = 0;
-	int max_addresses;
 	u32 addr_flags;
 	unsigned long now = jiffies;
 
@@ -1100,7 +1099,6 @@ retry:
 				 idev->cnf.temp_prefered_lft + age -
 				 idev->cnf.max_desync_factor);
 	tmp_plen = ifp->prefix_len;
-	max_addresses = idev->cnf.max_addresses;
 	tmp_tstamp = ifp->tstamp;
 	spin_unlock_bh(&ifp->lock);
 
-- 
1.8.1.4
