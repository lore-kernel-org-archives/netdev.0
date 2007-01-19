From: dlezcano@fr.ibm.com
Subject: [patch 01/12] net namespace : initialize init process to level 2
Date: Fri, 19 Jan 2007 16:47:15 +0100
Message-ID: <20070119155342.556325554@localhost.localdomain>
References: <20070119154714.439706567@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from AToulouse-252-1-85-33.w86-201.abo.wanadoo.fr ([86.201.99.33]:56627
	"EHLO localhost.localdomain" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932503AbXASQkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jan 2007 11:40:40 -0500
To: containers@lists.osdl.org
Content-Disposition: inline; filename=net-namespace-l3-fix-level-init.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Lezcano <dlezcano@fr.ibm.com>

Initialize the init's network namespace to level 2

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

---
 net/core/net_namespace.c |    1 +
 1 file changed, 1 insertion(+)

Index: 2.6.20-rc4-mm1/net/core/net_namespace.c
===================================================================
--- 2.6.20-rc4-mm1.orig/net/core/net_namespace.c
+++ 2.6.20-rc4-mm1/net/core/net_namespace.c
@@ -21,6 +21,7 @@
 	.dev_tail_p	= &init_net_ns.dev_base_p,
 	.loopback_dev_p	= NULL,
 	.pcpu_lstats_p	= NULL,
+	.level          = NET_NS_LEVEL2,
 };
 
 #ifdef CONFIG_NET_NS

-- 
