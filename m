From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] inetpeer: kmem_cache_create() failure
Date: Mon, 23 Feb 2004 13:36:35 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223133635.68099d7f.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Please apply to 2.6.3-current.


From: <WHarms@bfs.de>(Walter Harms)


 linux-263-kj1-rddunlap/net/ipv4/inetpeer.c |    3 +++
 1 files changed, 3 insertions(+)

diff -puN net/ipv4/inetpeer.c~ipv4_inetpeer_kmemcc net/ipv4/inetpeer.c
--- linux-263-kj1/net/ipv4/inetpeer.c~ipv4_inetpeer_kmemcc	2004-02-18 14:41:08.000000000 -0800
+++ linux-263-kj1-rddunlap/net/ipv4/inetpeer.c	2004-02-18 14:41:08.000000000 -0800
@@ -129,6 +129,9 @@ void __init inet_initpeers(void)
 			0, SLAB_HWCACHE_ALIGN,
 			NULL, NULL);
 
+	if (!peer_cachep)
+		panic("cannot create inet_peer_cache");
+
 	/* All the timers, started at system startup tend
 	   to synchronize. Perturb it a bit.
 	 */

_


--
~Randy
