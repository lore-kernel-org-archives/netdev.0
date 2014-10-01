From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] inet: frags: add __init to ip4_frags_ctl_register
Date: Wed,  1 Oct 2014 19:18:57 +0200
Message-ID: <1412183937-16055-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ip4_frags_ctl_register is only called by __init ipfrag_init

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv4/ip_fragment.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 15f0e2b..2811cc1 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -790,7 +790,7 @@ static void __net_exit ip4_frags_ns_ctl_unregister(struct net *net)
 	kfree(table);
 }
 
-static void ip4_frags_ctl_register(void)
+static void __init ip4_frags_ctl_register(void)
 {
 	register_net_sysctl(&init_net, "net/ipv4", ip4_frags_ctl_table);
 }
@@ -804,7 +804,7 @@ static inline void ip4_frags_ns_ctl_unregister(struct net *net)
 {
 }
 
-static inline void ip4_frags_ctl_register(void)
+static inline void __init ip4_frags_ctl_register(void)
 {
 }
 #endif
-- 
1.9.3
