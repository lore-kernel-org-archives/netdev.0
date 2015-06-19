From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/12] netfilter: Remove spurios included of netfilter.h
Date: Fri, 19 Jun 2015 19:17:48 +0200
Message-ID: <1434734269-4545-12-git-send-email-pablo@netfilter.org>
References: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55558 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754831AbbFSRMk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2015 13:12:40 -0400
In-Reply-To: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W Biederman <ebiederm@xmission.com>

While testing my netfilter changes I noticed several files where
recompiling unncessarily because they unncessarily included
netfilter.h.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 drivers/net/hamradio/bpqether.c |    1 -
 drivers/net/ppp/pptp.c          |    2 --
 drivers/net/wan/lapbether.c     |    1 -
 net/ax25/af_ax25.c              |    1 -
 net/ax25/ax25_in.c              |    1 -
 net/ax25/ax25_ip.c              |    1 -
 net/ax25/ax25_out.c             |    1 -
 net/ax25/ax25_uid.c             |    1 -
 net/netrom/nr_route.c           |    1 -
 net/rose/rose_link.c            |    1 -
 net/rose/rose_route.c           |    1 -
 security/selinux/xfrm.c         |    3 ---
 12 files changed, 15 deletions(-)

diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 63ff08a..7856b6c 100644
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
index 14839bc..686f37d 100644
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
index 2f5eda8..6676607 100644
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
index 4273533..9c891d0 100644
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
index 7ed8ab7..29a3687 100644
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
index 7c646bb..b563a3f 100644
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
index be2acab..8ddd41b 100644
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
index 71c4bad..4ad2fb7 100644
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
index 96b64d2..d72a4f1 100644
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
index e873d7d..c76638c 100644
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
index 40148932..0fc76d8 100644
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
index 98b0426..56e354f 100644
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
1.7.10.4
