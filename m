From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking for 2.6.28
Date: Sat, 11 Oct 2008 09:46:09 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0810110945420.3402@nehalem.linux-foundation.org>
References: <20081010.144921.115563930.davem@davemloft.net> <alpine.LFD.2.00.0810110941330.3402@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48920 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753183AbYJKQqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 12:46:43 -0400
In-Reply-To: <alpine.LFD.2.00.0810110941330.3402@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 11 Oct 2008, Linus Torvalds wrote:
> 
> Please fix ASAP.

Ahh. I think this fixes it.

		Linus

---
 include/net/netfilter/nf_conntrack_ecache.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index 11480e6..1285ff2 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -63,7 +63,7 @@ extern void nf_conntrack_ecache_fini(struct net *net);
 #else /* CONFIG_NF_CONNTRACK_EVENTS */
 
 static inline void nf_conntrack_event_cache(enum ip_conntrack_events event,
-					    const struct sk_buff *skb) {}
+					    struct nf_conn *ct) {}
 static inline void nf_conntrack_event(enum ip_conntrack_events event,
 				      struct nf_conn *ct) {}
 static inline void nf_ct_deliver_cached_events(const struct nf_conn *ct) {}
