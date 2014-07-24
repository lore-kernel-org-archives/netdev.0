From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] igmp: remove exceptional & on function name
Date: Fri, 25 Jul 2014 01:48:44 +0530
Message-ID: <20140724201844.GA16240@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In this file, function names are otherwise used as pointers without &.

A simplified version of the Coccinelle semantic patch that makes this
change is as follows: 

// <smpl>
@r@
identifier f;
@@

f(...) { ... }

@@
identifier r.f;
@@

- &f
+ f
// </smpl>

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
 net/ipv4/igmp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index db710b0..f10eab4 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1321,7 +1321,7 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 	atomic_set(&im->refcnt, 1);
 	spin_lock_init(&im->lock);
 #ifdef CONFIG_IP_MULTICAST
-	setup_timer(&im->timer, &igmp_timer_expire, (unsigned long)im);
+	setup_timer(&im->timer, igmp_timer_expire, (unsigned long)im);
 	im->unsolicit_count = IGMP_Unsolicited_Report_Count;
 #endif
 
-- 
1.9.1
