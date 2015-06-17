From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 41/43] netfilter: Remove the network namespace Kconfig conflict
Date: Wed, 17 Jun 2015 10:28:50 -0500
Message-ID: <1434554932-4552-41-git-send-email-ebiederm@xmission.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:45889 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757500AbbFQPib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:38:31 -0400
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the nf_register_hook conversion is complete netfilter
should work just fine with network namespaces remove the temporary
Kconfig conflict.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 init/Kconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/init/Kconfig b/init/Kconfig
index 166cfbfdc2df..dc24dec60232 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1207,7 +1207,6 @@ config PID_NS
 config NET_NS
 	bool "Network namespace"
 	depends on NET
-	depends on !NETFILTER
 	default y
 	help
 	  Allow user space to create what appear to be multiple instances
-- 
2.2.1
