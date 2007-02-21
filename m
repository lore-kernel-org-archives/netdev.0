From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/4] bridge: get rid of miscdevice include
Date: Wed, 21 Feb 2007 14:41:08 -0800
Message-ID: <20070221224255.581096490@linux-foundation.org>
References: <20070221224107.741532037@linux-foundation.org>
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:53655 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423234AbXBUWrR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 17:47:17 -0500
Content-Disposition: inline; filename=bridge-get-rid-miscdevice
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bridge hasn't used miscdevice for a long long time.

Signed-off-by: StephenHemminger <shemminger@linux-foundtion.org>

---
 net/bridge/br_private.h |    1 -
 1 file changed, 1 deletion(-)

--- bridge.orig/net/bridge/br_private.h	2007-02-21 10:57:26.000000000 -0800
+++ bridge/net/bridge/br_private.h	2007-02-21 10:57:30.000000000 -0800
@@ -16,7 +16,6 @@
 #define _BR_PRIVATE_H
 
 #include <linux/netdevice.h>
-#include <linux/miscdevice.h>
 #include <linux/if_bridge.h>
 
 #define BR_HASH_BITS 8

--
Stephen Hemminger <shemminger@linux-foundation.org>

