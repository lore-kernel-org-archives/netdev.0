From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] xfrm: remove useless forward declarations
Date: Tue, 25 Nov 2008 06:36:04 +0300
Message-ID: <20081125033604.GB2617@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:33639 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753494AbYKYDcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 22:32:22 -0500
Received: by ug-out-1314.google.com with SMTP id 39so951051ugf.37
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 19:32:21 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/xfrm4_state.c |    2 --
 net/ipv6/xfrm6_state.c |    2 --
 2 files changed, 4 deletions(-)

--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -13,8 +13,6 @@
 #include <linux/ipsec.h>
 #include <linux/netfilter_ipv4.h>
 
-static struct xfrm_state_afinfo xfrm4_state_afinfo;
-
 static int xfrm4_init_flags(struct xfrm_state *x)
 {
 	if (ipv4_config.no_pmtu_disc)
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -19,8 +19,6 @@
 #include <net/ipv6.h>
 #include <net/addrconf.h>
 
-static struct xfrm_state_afinfo xfrm6_state_afinfo;
-
 static void
 __xfrm6_init_tempsel(struct xfrm_state *x, struct flowi *fl,
 		     struct xfrm_tmpl *tmpl,
