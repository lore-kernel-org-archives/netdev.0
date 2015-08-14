From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next] ipv6: remove unnecessary include
Date: Fri, 14 Aug 2015 23:13:19 +0100
Message-ID: <1439590399-21374-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:39178 "EHLO
	cedar.ipmorris.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751967AbbHNWNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 18:13:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

printk.h does not need to be explicitly included as we include kernel.h
which already called it.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/ip6_offload.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 08b6204..1cb2dc7 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -12,7 +12,6 @@
 #include <linux/socket.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
-#include <linux/printk.h>
 
 #include <net/protocol.h>
 #include <net/ipv6.h>
-- 
1.9.1
