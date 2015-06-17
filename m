From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 16/43] net: include missing headers in net/net_namespace.h
Date: Wed, 17 Jun 2015 10:28:25 -0500
Message-ID: <1434554932-4552-16-git-send-email-ebiederm@xmission.com>
References: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Include linux/idr.h and linux/skbuff.h since they are required by objects that
are declared in the net structure.

 struct net {
	...
	struct idr		netns_ids;
	...
	struct sk_buff_head	wext_nlevents;
	...

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/net_namespace.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 72eb23723294..e951453e0a23 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -28,6 +28,8 @@
 #include <net/netns/xfrm.h>
 #include <net/netns/mpls.h>
 #include <linux/ns_common.h>
+#include <linux/idr.h>
+#include <linux/skbuff.h>
 
 struct user_namespace;
 struct proc_dir_entry;
-- 
2.2.1

