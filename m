From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netfilter: nf_conntrack: remove one synchronize_net()
Date: Fri, 27 May 2011 17:15:13 +0200
Message-ID: <1306509313.3445.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No point to wait a rcu grace period before the unregisters.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 5a03c02..b09bfeb 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -435,7 +435,6 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 
 static void __exit nf_conntrack_l3proto_ipv4_fini(void)
 {
-	synchronize_net();
 #if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
 	nf_conntrack_ipv4_compat_fini();
 #endif


