From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2.6.26] myri10ge: update driver version
Date: Wed, 28 May 2008 09:10:01 +0200
Message-ID: <483D0549.1010208@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1987 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750943AbYE1HKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 03:10:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update myri10ge version to 1.3.99-1.347.

Signed-off-by: Brice Goglin <brice@myri.com>
---
Hello Jeff,

Please apply this patch for 2.6.26 to reflect the driver status
(contains all our 1.4 bugfixes without multislice support).

You should also drop the correponding last patch from your upstream-myri
branch (commit id d1d0b191365b2606cf09631805f07b81ab005d7e) before pushing
to davem' net-next-2.6. I'll send a new one during the 2.6.27 cycle.

thanks,
Brice

 drivers/net/myri10ge/myri10ge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.git.orig/drivers/net/myri10ge/myri10ge.c	2008-05-28 09:01:47.000000000 +0200
+++ linux-2.6.git/drivers/net/myri10ge/myri10ge.c	2008-05-28 09:03:22.000000000 +0200
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.3.2-1.287"
+#define MYRI10GE_VERSION_STR "1.3.99-1.347"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");


