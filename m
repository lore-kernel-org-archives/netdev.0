From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/05: Kconfig: TProxy doesn't depend on NF_CONNTRACK
Date: Fri, 24 Apr 2009 17:44:05 +0200 (MEST)
Message-ID: <20090424154359.28952.25425.sendpatchset@x2.localnet>
References: <20090424154355.28952.21443.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47988 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbZDXPoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 11:44:06 -0400
In-Reply-To: <20090424154355.28952.21443.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 4b0706624930dc75c3b0d0df463d89759ef7de29
Author: Laszlo Attila Toth <panther@balabit.hu>
Date:   Fri Apr 24 16:55:25 2009 +0200

    netfilter: Kconfig: TProxy doesn't depend on NF_CONNTRACK
    
    Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 2329c5f..881203c 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -275,6 +275,8 @@ config NF_CT_NETLINK
 	help
 	  This option enables support for a netlink-based userspace interface
 
+endif # NF_CONNTRACK
+
 # transparent proxy support
 config NETFILTER_TPROXY
 	tristate "Transparent proxying support (EXPERIMENTAL)"
@@ -290,8 +292,6 @@ config NETFILTER_TPROXY
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
-endif # NF_CONNTRACK
-
 config NETFILTER_XTABLES
 	tristate "Netfilter Xtables support (required for ip_tables)"
 	default m if NETFILTER_ADVANCED=n
