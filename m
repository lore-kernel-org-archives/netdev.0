From: akpm@linux-foundation.org
Subject: [patch 05/28] Clean up duplicate includes in net/ipv4/
Date: Fri, 10 Aug 2007 14:11:52 -0700
Message-ID: <200708102111.l7ALBqgG009383@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jesper.juhl@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36100 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S942359AbXHJVMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>

This patch cleans up duplicate includes in
	net/ipv4/

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/ipv4/ip_output.c               |    1 -
 net/ipv4/ipvs/ip_vs_ctl.c          |    1 -
 net/ipv4/netfilter/ipt_CLUSTERIP.c |    1 -
 3 files changed, 3 deletions(-)

diff -puN net/ipv4/ip_output.c~clean-up-duplicate-includes-in-net-ipv4 net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c~clean-up-duplicate-includes-in-net-ipv4
+++ a/net/ipv4/ip_output.c
@@ -75,7 +75,6 @@
 #include <net/icmp.h>
 #include <net/checksum.h>
 #include <net/inetpeer.h>
-#include <net/checksum.h>
 #include <linux/igmp.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_bridge.h>
diff -puN net/ipv4/ipvs/ip_vs_ctl.c~clean-up-duplicate-includes-in-net-ipv4 net/ipv4/ipvs/ip_vs_ctl.c
--- a/net/ipv4/ipvs/ip_vs_ctl.c~clean-up-duplicate-includes-in-net-ipv4
+++ a/net/ipv4/ipvs/ip_vs_ctl.c
@@ -29,7 +29,6 @@
 #include <linux/proc_fs.h>
 #include <linux/workqueue.h>
 #include <linux/swap.h>
-#include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 
 #include <linux/netfilter.h>
diff -puN net/ipv4/netfilter/ipt_CLUSTERIP.c~clean-up-duplicate-includes-in-net-ipv4 net/ipv4/netfilter/ipt_CLUSTERIP.c
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c~clean-up-duplicate-includes-in-net-ipv4
+++ a/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -19,7 +19,6 @@
 #include <linux/udp.h>
 #include <linux/icmp.h>
 #include <linux/if_arp.h>
-#include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/netfilter_arp.h>
 #include <linux/netfilter/x_tables.h>
_
