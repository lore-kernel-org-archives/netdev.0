From: Mark Brown <broonie@kernel.org>
Subject: [PATCH] nfp: Explicitly include linux/bug.h
Date: Fri, 13 Oct 2017 03:50:35 +0100
Message-ID: <20171013025035.4450-1-broonie@kernel.org>
Cc: oss-drivers@netronome.com, netdev@vger.kernel.org,
        Mark Brown <broonie@kernel.org>
To: davem@davemloft.net, Jakub Kicinski <jakub.kicinski@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from heliosphere.sirena.org.uk ([172.104.155.198]:53506 "EHLO
        heliosphere.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753291AbdJMCuq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 22:50:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today's -next build encountered an error due to a missing definition of
WARN_ON(), caused by some header reorganization removing an implicit
inclusion of linux/bug.h.  Fix this with an explicit inclusion.

Signed-off-by: Mark Brown <broonie@kernel.org>
---
 drivers/net/ethernet/netronome/nfp/nfp_app.c | 1 +
 drivers/net/ethernet/netronome/nfp/nfp_asm.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.c b/drivers/net/ethernet/netronome/nfp/nfp_app.c
index 82c290763529..5d9e2eba5b49 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.c
@@ -31,6 +31,7 @@
  * SOFTWARE.
  */
 
+#include <linux/bug.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_asm.h b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
index c4c18dd5630a..aa397bf308e4 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_asm.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
@@ -35,6 +35,7 @@
 #define __NFP_ASM_H__ 1
 
 #include <linux/bitfield.h>
+#include <linux/bug.h>
 #include <linux/types.h>
 
 #define REG_NONE	0
-- 
2.14.1
