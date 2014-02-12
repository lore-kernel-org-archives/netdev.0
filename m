From: <andreas.bofjall@ericsson.com>
Subject: [PATCH net-next] tipc: explicitly include core.h in addr.h
Date: Wed, 12 Feb 2014 09:34:18 +0100
Message-ID: <1392194058-16271-1-git-send-email-andreas.bofjall@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <tipc-discussion@lists.sourceforge.net>, <maloy@donjonn.com>,
	=?UTF-8?q?Andreas=20Bofj=C3=A4ll?= <andreas.bofjall@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg20.ericsson.net ([193.180.251.56]:62938 "EHLO
	sesbmg20.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551AbaBLIej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 03:34:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Andreas Bofj=C3=A4ll <andreas.bofjall@ericsson.com>

The inline functions in addr.h uses tipc_own_addr which is exported by
core.h, but addr.h never actually includes it. It works because it is
explicitly included where this is used, but it looks a bit strange.

Include core.h in addr.h explicitly to make the dependency clearer.

Signed-off-by: Andreas Bofj=C3=A4ll <andreas.bofjall@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/addr.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/tipc/addr.h b/net/tipc/addr.h
index 60b00ab..a74acf9 100644
--- a/net/tipc/addr.h
+++ b/net/tipc/addr.h
@@ -37,6 +37,8 @@
 #ifndef _TIPC_ADDR_H
 #define _TIPC_ADDR_H
=20
+#include "core.h"
+
 #define TIPC_ZONE_MASK		0xff000000u
 #define TIPC_CLUSTER_MASK	0xfffff000u
=20
--=20
1.8.5.2
