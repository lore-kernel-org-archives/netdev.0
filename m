From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] [sparse] af_inet6 -- 0 vs NULL
Date: Tue, 13 Jul 2004 11:23:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040713112340.58712804@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
        "David S.
 Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sparse complains about 0 vs NULL here.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c	2004-07-13 10:07:04 -07:00
+++ b/net/ipv6/af_inet6.c	2004-07-13 10:07:04 -07:00
@@ -719,13 +719,13 @@
 	/* allocate our sock slab caches */
         tcp6_sk_cachep = kmem_cache_create("tcp6_sock",
 					   sizeof(struct tcp6_sock), 0,
-                                           SLAB_HWCACHE_ALIGN, 0, 0);
+                                           SLAB_HWCACHE_ALIGN, NULL, NULL);
         udp6_sk_cachep = kmem_cache_create("udp6_sock",
 					   sizeof(struct udp6_sock), 0,
-                                           SLAB_HWCACHE_ALIGN, 0, 0);
+                                           SLAB_HWCACHE_ALIGN, NULL, NULL);
         raw6_sk_cachep = kmem_cache_create("raw6_sock",
 					   sizeof(struct raw6_sock), 0,
-                                           SLAB_HWCACHE_ALIGN, 0, 0);
+                                           SLAB_HWCACHE_ALIGN, NULL, NULL);
         if (!tcp6_sk_cachep || !udp6_sk_cachep || !raw6_sk_cachep)
                 printk(KERN_CRIT "%s: Can't create protocol sock SLAB "
 		       "caches!\n", __FUNCTION__);
