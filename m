From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Include module.h in ip_tunnel_core.c
Date: Thu, 23 Jul 2015 01:26:25 -0700 (PDT)
Message-ID: <20150723.012625.1155727478780199014.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55101 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038AbbGWINd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 04:13:33 -0400
Received: from localhost (unknown [172.56.7.242])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 7CABC581A5F
	for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 01:13:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_tunnel_core.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 630e6d5..7305728 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -33,6 +33,7 @@
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
 #include <linux/static_key.h>
+#include <linux/module.h>
 
 #include <net/ip.h>
 #include <net/icmp.h>
-- 
1.7.10.4
