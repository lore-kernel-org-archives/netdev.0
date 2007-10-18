From: Joe Perches <joe@perches.com>
Subject: [PATCH] trivial - QUICC UCC driver - remove buggy and unused vdbg
	macro
Date: Thu, 18 Oct 2007 12:24:53 -0700
Message-ID: <1192735493.23980.42.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3153 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764467AbXJRTZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 15:25:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

remove buggy and unused vdbg macro

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index df884f0..a4b481c 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -46,13 +46,6 @@
 #include "ucc_geth_mii.h"
 #include "ucc_geth.h"
 
-#define DEBUG
-#ifdef DEBUG
-#define vdbg(format, arg...) printk(KERN_DEBUG , format "\n" , ## arg)
-#else
-#define vdbg(format, arg...) do {} while(0)
-#endif
-
 #define MII_DRV_DESC "QE UCC Ethernet Controller MII Bus"
 #define MII_DRV_NAME "fsl-uec_mdio"
 


