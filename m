From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH] net: ethernet: fs_enet: Remove useless includes
Date: Thu, 16 Mar 2017 10:18:04 +0100 (CET)
Message-ID: <20170316091804.DCA4168481@localhost.localdomain>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org
To: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
        Vitaly Bordug <vbordug@ru.mvista.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from pegase1.c-s.fr ([93.17.236.30]:24084 "EHLO pegase1.c-s.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751146AbdCPJSI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Mar 2017 05:18:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_8xx is being deprecated. Since the includes dependent on
CONFIG_8xx are useless, just drop them.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 drivers/net/ethernet/freescale/fs_enet/mac-fec.c | 6 ------
 drivers/net/ethernet/freescale/fs_enet/mac-scc.c | 6 ------
 2 files changed, 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-fec.c b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
index db9c0bcf54cd..1fc27c97e3b2 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
@@ -38,12 +38,6 @@
 #include <asm/irq.h>
 #include <linux/uaccess.h>
 
-#ifdef CONFIG_8xx
-#include <asm/8xx_immap.h>
-#include <asm/pgtable.h>
-#include <asm/cpm1.h>
-#endif
-
 #include "fs_enet.h"
 #include "fec.h"
 
diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-scc.c b/drivers/net/ethernet/freescale/fs_enet/mac-scc.c
index 96d44cf44fe0..64300ac13e02 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-scc.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-scc.c
@@ -37,12 +37,6 @@
 #include <asm/irq.h>
 #include <linux/uaccess.h>
 
-#ifdef CONFIG_8xx
-#include <asm/8xx_immap.h>
-#include <asm/pgtable.h>
-#include <asm/cpm1.h>
-#endif
-
 #include "fs_enet.h"
 
 /*************************************************/
-- 
2.12.0
