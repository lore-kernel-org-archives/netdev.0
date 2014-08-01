From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 4/6] inet: frags: fix function declaration alignments in inet_fragment
Date: Fri,  1 Aug 2014 12:29:46 +0200
Message-ID: <1406888988-20742-5-git-send-email-nikolay@redhat.com>
References: <1406888988-20742-1-git-send-email-nikolay@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexander Aring <alex.aring@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7620 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754155AbaHAKax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 06:30:53 -0400
In-Reply-To: <1406888988-20742-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a couple of functions' declaration alignments.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v2: new patch, broken off the old patch 02 and re-adjusted

 net/ipv4/inet_fragment.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index e3ebc6608e5d..fa49916c23a0 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -334,8 +334,9 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f)
 EXPORT_SYMBOL(inet_frag_destroy);
 
 static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
-		struct inet_frag_queue *qp_in, struct inet_frags *f,
-		void *arg)
+						struct inet_frag_queue *qp_in,
+						struct inet_frags *f,
+						void *arg)
 {
 	struct inet_frag_bucket *hb = get_frag_bucket_locked(qp_in, f);
 	struct inet_frag_queue *qp;
@@ -368,7 +369,8 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 }
 
 static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
-		struct inet_frags *f, void *arg)
+					       struct inet_frags *f,
+					       void *arg)
 {
 	struct inet_frag_queue *q;
 
@@ -393,7 +395,8 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 }
 
 static struct inet_frag_queue *inet_frag_create(struct netns_frags *nf,
-		struct inet_frags *f, void *arg)
+						struct inet_frags *f,
+						void *arg)
 {
 	struct inet_frag_queue *q;
 
@@ -405,7 +408,8 @@ static struct inet_frag_queue *inet_frag_create(struct netns_frags *nf,
 }
 
 struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
-		struct inet_frags *f, void *key, unsigned int hash)
+				       struct inet_frags *f, void *key,
+				       unsigned int hash)
 {
 	struct inet_frag_bucket *hb;
 	struct inet_frag_queue *q;
-- 
1.9.3
