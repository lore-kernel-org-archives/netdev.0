From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 1/2] 6lowpan: add missing include of net/ipv6.h
Date: Wed,  5 Mar 2014 14:29:04 +0100
Message-ID: <1394026145-18981-2-git-send-email-alex.aring@gmail.com>
References: <1394026145-18981-1-git-send-email-alex.aring@gmail.com>
Cc: gustavo@padovan.org, johan.hedberg@gmail.com, davem@davemloft.net,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:55999 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbaCEN3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 08:29:24 -0500
In-Reply-To: <1394026145-18981-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 6lowpan.h file contains some static inline function which use
internal ipv6 api structs. Add a include of ipv6.h to be sure that it's
known before.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 net/ieee802154/6lowpan.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
index 0dccf62..f7d372b 100644
--- a/net/ieee802154/6lowpan.h
+++ b/net/ieee802154/6lowpan.h
@@ -53,6 +53,8 @@
 #ifndef __6LOWPAN_H__
 #define __6LOWPAN_H__
 
+#include <net/ipv6.h>
+
 #define UIP_802154_SHORTADDR_LEN	2  /* compressed ipv6 address length */
 #define UIP_IPH_LEN			40 /* ipv6 fixed header size */
 #define UIP_PROTO_UDP			17 /* ipv6 next header value for UDP */
-- 
1.9.0
