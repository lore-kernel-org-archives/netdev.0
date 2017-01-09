From: William Breathitt Gray <vilhelm.gray@gmail.com>
Subject: [PATCH] netfilter: Fix typo in NF_CONNTRACK Kconfig option
 description
Date: Mon, 9 Jan 2017 17:24:18 -0500
Message-ID: <20170109222417.GA18253@sophia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The NF_CONNTRACK Kconfig option description makes an incorrect reference
to the "meta" expression where the "ct" expression would be correct.This
patch fixes the respective typographical error.

Fixes: d497c6352736 ("netfilter: add help information to new nf_tables Kconfig options")
Signed-off-by: William Breathitt Gray <vilhelm.gray@gmail.com>
---
 net/netfilter/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 63729b489c2c..bbc45f8a7b2d 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -494,7 +494,7 @@ config NFT_CT
 	depends on NF_CONNTRACK
 	tristate "Netfilter nf_tables conntrack module"
 	help
-	  This option adds the "meta" expression that you can use to match
+	  This option adds the "ct" expression that you can use to match
 	  connection tracking information such as the flow state.
 
 config NFT_SET_RBTREE
-- 
2.11.0
