From: pablo@netfilter.org
Subject: [PATCH 7/7] netfilter: remove unused "config IP_NF_QUEUE"
Date: Wed, 20 Mar 2013 11:49:34 +0100
Message-ID: <1363776574-4766-8-git-send-email-pablo@netfilter.org>
References: <1363776574-4766-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51317 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756226Ab3CTKty (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 06:49:54 -0400
In-Reply-To: <1363776574-4766-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Bolle <pebolle@tiscali.nl>

Kconfig symbol IP_NF_QUEUE is unused since commit
d16cf20e2f2f13411eece7f7fb72c17d141c4a84 ("netfilter: remove ip_queue
support"). Let's remove it too.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/Kconfig |   13 -------------
 1 file changed, 13 deletions(-)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index ce2d43e..0d755c5 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -36,19 +36,6 @@ config NF_CONNTRACK_PROC_COMPAT
 
 	  If unsure, say Y.
 
-config IP_NF_QUEUE
-	tristate "IP Userspace queueing via NETLINK (OBSOLETE)"
-	depends on NETFILTER_ADVANCED
-	help
-	  Netfilter has the ability to queue packets to user space: the
-	  netlink device can be used to access them using this driver.
-
-	  This option enables the old IPv4-only "ip_queue" implementation
-	  which has been obsoleted by the new "nfnetlink_queue" code (see
-	  CONFIG_NETFILTER_NETLINK_QUEUE).
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP_NF_IPTABLES
 	tristate "IP tables support (required for filtering/masq/NAT)"
 	default m if NETFILTER_ADVANCED=n
-- 
1.7.10.4
