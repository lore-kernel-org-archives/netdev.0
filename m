From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 2/2] netxen: include ipv6.h (fixes build failure)
Date: Fri, 16 Jan 2009 10:28:04 -0800
Message-ID: <1232130484-25188-3-git-send-email-dhananjay@netxen.com>
References: <1232130484-25188-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:54445 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757007AbZAPS2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2009 13:28:06 -0500
In-Reply-To: <1232130484-25188-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes a build error in absence of CONFIG_IPV6:

drivers/net/netxen/netxen_nic_main.c:1189: error: implicit declaration of function 'ipv6_hdr'
drivers/net/netxen/netxen_nic_main.c:1189: error: invalid type argument of '->'

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index f8e2629..d854f07 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -41,6 +41,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/if_vlan.h>
 #include <net/ip.h>
+#include <linux/ipv6.h>
 
 MODULE_DESCRIPTION("NetXen Multi port (1/10) Gigabit Network Driver");
 MODULE_LICENSE("GPL");
-- 
1.6.0.2

