From: Christian Hemp <c.hemp@phytec.de>
Subject: [RFC][PATCH] net: ipv4: ipconfig: decrease CONF_CARRIER_TIMEOUT
Date: Wed, 2 May 2012 17:24:19 +0200
Message-ID: <1335972259-20975-1-git-send-email-c.hemp@phytec.de>
Cc: Christian Hemp <c.hemp@phytec.de>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.phytec.co.uk ([217.6.246.34]:60905 "EHLO root.phytec.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754753Ab2EBPYp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 11:24:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A timeout of two minutes is pretty anoying if _no_ ethernet cable
is attached by purpose.  This patch decreases the timeout of
CONF_CARRIER_TIMEOUT to an accaptable value of 10 secounds.

Signed-off-by: Christian Hemp <c.hemp@phytec.de>
---
 net/ipv4/ipconfig.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 99ec116..2aa80ac 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -89,7 +89,7 @@
 
 /* Define the friendly delay before and after opening net devices */
 #define CONF_POST_OPEN		10	/* After opening: 10 msecs */
-#define CONF_CARRIER_TIMEOUT	120000	/* Wait for carrier timeout */
+#define CONF_CARRIER_TIMEOUT	1000	/* Wait for carrier timeout */
 
 /* Define the timeout for waiting for a DHCP/BOOTP/RARP reply */
 #define CONF_OPEN_RETRIES 	2	/* (Re)open devices twice */
-- 
1.7.0.4
