From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH][30/37] Clean up duplicate includes in net/netfilter/
Date: Sat, 21 Jul 2007 17:03:47 +0200
Message-ID: <200707211703.47827.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jesper Juhl <jesper.juhl@gmail.com>, netdev@vger.kernel.org,
	David S Miller <davem@davemloft.net>,
	Harald Welte <laforge@netfilter.org>,
	netfilter-devel@lists.netfilter.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	James Morris <jmorris@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	Netfilter Core Team <coreteam@netfilter.org>,
	Bart De Schuymer <bdschuym@pandora.be>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:36163 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S939493AbXGUPEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 11:04:46 -0400
Received: by nf-out-0910.google.com with SMTP id g13so79771nfb
        for <netdev@vger.kernel.org>; Sat, 21 Jul 2007 08:04:44 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch cleans up duplicate includes in
	net/netfilter/


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 87ad3cc..eb3fe74 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -8,7 +8,6 @@
 
 #include <linux/types.h>
 #include <linux/timer.h>
-#include <linux/netfilter.h>
 #include <linux/module.h>
 #include <linux/in.h>
 #include <linux/tcp.h>
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 13d94a0..2a2fd1a 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -9,7 +9,6 @@
 #include <linux/types.h>
 #include <linux/timer.h>
 #include <linux/module.h>
-#include <linux/netfilter.h>
 #include <linux/udp.h>
 #include <linux/seq_file.h>
 #include <linux/skbuff.h>
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 93e747b..b906b41 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -10,7 +10,6 @@
 #include <linux/types.h>
 #include <linux/timer.h>
 #include <linux/module.h>
-#include <linux/netfilter.h>
 #include <linux/udp.h>
 #include <linux/seq_file.h>
 #include <linux/skbuff.h>
diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index f47cab7..a4bab04 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -13,7 +13,6 @@
 #include <linux/netfilter_bridge.h>
 #include <linux/netfilter/xt_physdev.h>
 #include <linux/netfilter/x_tables.h>
-#include <linux/netfilter_bridge.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Bart De Schuymer <bdschuym@pandora.be>");
