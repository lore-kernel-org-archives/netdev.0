From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] net/core/utils: fix sparse warning
Date: Mon, 06 Aug 2007 18:37:26 +0200
Message-ID: <1186418247.28655.82.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38599 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757733AbXHGJoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 05:44:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net_msg_warn is not defined because it is in net/sock.h which isn't
included.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
 net/core/utils.c |    1 +
 1 file changed, 1 insertion(+)

--- wireless-dev.orig/net/core/utils.c	2007-08-06 18:35:29.197838489 +0200
+++ wireless-dev/net/core/utils.c	2007-08-06 18:35:52.227838489 +0200
@@ -25,6 +25,7 @@
 #include <linux/random.h>
 #include <linux/percpu.h>
 #include <linux/init.h>
+#include <net/sock.h>
 
 #include <asm/byteorder.h>
 #include <asm/system.h>


