From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 21/43] netfilter: Add a network namespace Kconfig conflict
Date: Wed, 17 Jun 2015 10:28:30 -0500
Message-ID: <1434554932-4552-21-git-send-email-ebiederm@xmission.com>
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

From: Eric W Biederman <ebiederm@xmission.com>

Don't allow network namespaces and netfilter to both be
enabled.  This allows the netfilter code to be bisected
through while per network namespace netfilter hooks are
being implemented.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 init/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/init/Kconfig b/init/Kconfig
index dc24dec60232..166cfbfdc2df 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1207,6 +1207,7 @@ config PID_NS
 config NET_NS
 	bool "Network namespace"
 	depends on NET
+	depends on !NETFILTER
 	default y
 	help
 	  Allow user space to create what appear to be multiple instances
-- 
2.2.1

