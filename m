From: Joe Perches <joe@perches.com>
Subject: [Trivial PATCH 28/33] ipv6: Convert use of typedef ctl_table to struct ctl_table
Date: Thu, 13 Jun 2013 19:37:53 -0700
Message-ID: <43ebfe570d433155e880191f889d8b0a912257e5.1371177118.git.joe@perches.com>
References: <cover.1371177118.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1371177118.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This typedef is unnecessary and should just be removed.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/ipv6.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index ab47582..5fe5649 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -859,8 +859,8 @@ static inline int snmp6_unregister_dev(struct inet6_dev *idev) { return 0; }
 #endif
 
 #ifdef CONFIG_SYSCTL
-extern ctl_table ipv6_route_table_template[];
-extern ctl_table ipv6_icmp_table_template[];
+extern struct ctl_table ipv6_route_table_template[];
+extern struct ctl_table ipv6_icmp_table_template[];
 
 extern struct ctl_table *ipv6_icmp_sysctl_init(struct net *net);
 extern struct ctl_table *ipv6_route_sysctl_init(struct net *net);
-- 
1.8.1.2.459.gbcd45b4.dirty
