From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 12/13] net: Include appropriate header file in
 netfilter/nft_lookup.c
Date: Sun, 9 Feb 2014 01:39:20 +0530
Message-ID: <401aceca1fc3f95097624fe8433635491b39248d.1391888654.git.rashika.kheria@gmail.com>
References: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Include appropriate header file net/netfilter/nf_tables_core.h in
net/netfilter/nft_lookup.c because it has prototype declaration of
functions defined in net/netfilter/nft_lookup.c.

This eliminates the following warning in net/netfilter/nft_lookup.c:
net/netfilter/nft_lookup.c:133:12: warning: no previous prototype for =E2=
=80=98nft_lookup_module_init=E2=80=99 [-Wmissing-prototypes]
net/netfilter/nft_lookup.c:138:6: warning: no previous prototype for =E2=
=80=98nft_lookup_module_exit=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
---
 net/netfilter/nft_lookup.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index 8a6116b..bb4ef4c 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -16,6 +16,7 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_core.h>
=20
 struct nft_lookup {
 	struct nft_set			*set;
--=20
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
