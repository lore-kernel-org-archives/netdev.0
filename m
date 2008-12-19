From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 1/2] netns: igmp: allow IPPROTO_IGMP sockets in netns
Date: Fri, 19 Dec 2008 15:25:06 +0100
Message-ID: <20081219142508.351224256@theryb.frec.bull.fr>
References: <20081219142505.469589973@theryb.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:33689 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352AbYLSO1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 09:27:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like everything is already ready.

Required for ebtables(8) for one thing.

Also, required for ipmr per-netns (coming soon). (Benjamin)

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Acked-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv4/af_inet.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 664ff0e..743f554 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1402,6 +1402,7 @@ EXPORT_SYMBOL_GPL(snmp_mib_free);
 #ifdef CONFIG_IP_MULTICAST
 static struct net_protocol igmp_protocol = {
 	.handler =	igmp_rcv,
+	.netns_ok =	1,
 };
 #endif
 

