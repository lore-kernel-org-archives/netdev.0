From: David Miller <davem@davemloft.net>
Subject: [PATCH]: niu: Bump driver version and release date.
Date: Fri, 14 Nov 2008 14:48:17 -0800 (PST)
Message-ID: <20081114.144817.154642509.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51101
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751416AbYKNWsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 17:48:18 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id EC391C8C196
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2008 14:48:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've just added the following patch to net-2.6

niu: Bump driver version and release date.

This driver is pretty mature, and the worst of the known
problems has been fixed (the 32-bit failures due to readq
implementation).

So let's finally give it a version of 1.0

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index be6b4d7..1b6f548 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -33,8 +33,8 @@
 
 #define DRV_MODULE_NAME		"niu"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"0.9"
-#define DRV_MODULE_RELDATE	"May 4, 2008"
+#define DRV_MODULE_VERSION	"1.0"
+#define DRV_MODULE_RELDATE	"Nov 14, 2008"
 
 static char version[] __devinitdata =
 	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
-- 
1.5.6.5

