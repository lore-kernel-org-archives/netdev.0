From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 26/43] netfitler: Remove spurios included of netfilter.h
Date: Wed, 17 Jun 2015 10:28:35 -0500
Message-ID: <1434554932-4552-26-git-send-email-ebiederm@xmission.com>
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

While testing my netfilter changes I noticed several files where
recompiling unncessarily because they unncessarily included
netfilter.h.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/hamradio/bpqether.c | 1 -
 drivers/net/ppp/pptp.c          | 2 --
 drivers/net/wan/lapbether.c     | 1 -
 net/ax25/af_ax25.c              | 1 -
 net/ax25/ax25_in.c              | 1 -
 net/ax25/ax25_ip.c              | 1 -
 net/ax25/ax25_out.c             | 1 -
 net/ax25/ax25_uid.c             | 1 -
 net/netrom/nr_route.c           | 1 -
 net/rose/rose_link.c            | 1 -
 net/rose/rose_route.c           | 1 -
 security/selinux/xfrm.c         | 3 ---
 12 files changed, 15 deletions(-)

diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 63ff08a26da8..7856b6ccf5c5 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -76,7 +76,6 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/stat.h>
-#include <linux/netfilter.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/rtnetlink.h>
diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 14839bc0aaf5..686f37daa262 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -28,8 +28,6 @@
 #include <linux/file.h>
 #include <linux/in.h>
 #include <linux/ip.h>
-#include <linux/netfilter.h>
-#include <linux/netfilter_ipv4.h>
 #include <linux/rcupdate.h>
 #include <linux/spinlock.h>
 
diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
index 2f5eda8a7227..6676607164d6 100644
--- a/drivers/net/wan/lapbether.c
+++ b/drivers/net/wan/lapbether.c
@@ -40,7 +40,6 @@
 #include <linux/interrupt.h>
 #include <linux/notifier.h>
 #include <linux/stat.h>
-#include <linux/netfilter.h>
 #include <linux/module.h>
 #include <linux/lapb.h>
 #include <linux/init.h>
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 4273533d22b1..9c891d0412a2 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -40,7 +40,6 @@
 #include <linux/notifier.h>
 #include <linux/proc_fs.h>
 #include <linux/stat.h>
-#include <linux/netfilter.h>
 #include <linux/sysctl.h>
 #include <linux/init.h>
 #include <linux/spinlock.h>
diff --git a/net/ax25/ax25_in.c b/net/ax25/ax25_in.c
index 7ed8ab724819..29a3687237aa 100644
--- a/net/ax25/ax25_in.c
+++ b/net/ax25/ax25_in.c
@@ -23,7 +23,6 @@
 #include <linux/inet.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
-#include <linux/netfilter.h>
 #include <net/sock.h>
 #include <net/tcp_states.h>
 #include <asm/uaccess.h>
diff --git a/net/ax25/ax25_ip.c b/net/ax25/ax25_ip.c
index 7c646bb2c6f7..b563a3f5f2a8 100644
--- a/net/ax25/ax25_ip.c
+++ b/net/ax25/ax25_ip.c
@@ -31,7 +31,6 @@
 #include <linux/notifier.h>
 #include <linux/proc_fs.h>
 #include <linux/stat.h>
-#include <linux/netfilter.h>
 #include <linux/sysctl.h>
 #include <net/ip.h>
 #include <net/arp.h>
diff --git a/net/ax25/ax25_out.c b/net/ax25/ax25_out.c
index be2acab9be9d..8ddd41baa81c 100644
--- a/net/ax25/ax25_out.c
+++ b/net/ax25/ax25_out.c
@@ -24,7 +24,6 @@
 #include <linux/inet.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
-#include <linux/netfilter.h>
 #include <net/sock.h>
 #include <asm/uaccess.h>
 #include <linux/fcntl.h>
diff --git a/net/ax25/ax25_uid.c b/net/ax25/ax25_uid.c
index 71c4badbc807..4ad2fb7bcd35 100644
--- a/net/ax25/ax25_uid.c
+++ b/net/ax25/ax25_uid.c
@@ -34,7 +34,6 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/stat.h>
-#include <linux/netfilter.h>
 #include <linux/sysctl.h>
 #include <linux/export.h>
 #include <net/ip.h>
diff --git a/net/netrom/nr_route.c b/net/netrom/nr_route.c
index 96b64d2f6dbf..d72a4f1558f2 100644
--- a/net/netrom/nr_route.c
+++ b/net/netrom/nr_route.c
@@ -31,7 +31,6 @@
 #include <linux/mm.h>
 #include <linux/interrupt.h>
 #include <linux/notifier.h>
-#include <linux/netfilter.h>
 #include <linux/init.h>
 #include <linux/spinlock.h>
 #include <net/netrom.h>
diff --git a/net/rose/rose_link.c b/net/rose/rose_link.c
index e873d7d9f857..c76638cc2cd5 100644
--- a/net/rose/rose_link.c
+++ b/net/rose/rose_link.c
@@ -25,7 +25,6 @@
 #include <linux/fcntl.h>
 #include <linux/mm.h>
 #include <linux/interrupt.h>
-#include <linux/netfilter.h>
 #include <net/rose.h>
 
 static void rose_ftimer_expiry(unsigned long);
diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index 40148932c8a4..0fc76d845103 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -31,7 +31,6 @@
 #include <linux/mm.h>
 #include <linux/interrupt.h>
 #include <linux/notifier.h>
-#include <linux/netfilter.h>
 #include <linux/init.h>
 #include <net/rose.h>
 #include <linux/seq_file.h>
diff --git a/security/selinux/xfrm.c b/security/selinux/xfrm.c
index 98b042630a9e..56e354fcdfc6 100644
--- a/security/selinux/xfrm.c
+++ b/security/selinux/xfrm.c
@@ -35,9 +35,6 @@
 #include <linux/init.h>
 #include <linux/security.h>
 #include <linux/types.h>
-#include <linux/netfilter.h>
-#include <linux/netfilter_ipv4.h>
-#include <linux/netfilter_ipv6.h>
 #include <linux/slab.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
-- 
2.2.1

