From: akpm@osdl.org
Subject: [patch 06/13] xt_physdev build fix
Date: Mon, 14 Aug 2006 23:03:40 -0700
Message-ID: <200608150603.k7F63eVv012939@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, bdschuym@pandora.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:46739 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965167AbWHOGDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:03:49 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

It needs netfilter_bridge.h for brnf_deferred_hooks

Cc: Bart De Schuymer <bdschuym@pandora.be>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/netfilter/xt_physdev.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN net/netfilter/xt_physdev.c~xt_physdev-build-fix net/netfilter/xt_physdev.c
--- a/net/netfilter/xt_physdev.c~xt_physdev-build-fix
+++ a/net/netfilter/xt_physdev.c
@@ -10,6 +10,7 @@
 
 #include <linux/module.h>
 #include <linux/skbuff.h>
+#include <linux/netfilter_bridge.h>
 #include <linux/netfilter/xt_physdev.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_bridge.h>
_
