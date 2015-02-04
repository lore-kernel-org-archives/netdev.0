From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH] net: ethernet: ti/cpsw-common.c: fix sparse warning
Date: Wed,  4 Feb 2015 12:31:28 +0000
Message-ID: <1423053088-6589-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: linux-kernel@vger.kernel.org, Tony Lindgren <tony@atomide.com>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:48575 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932316AbbBDMbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 07:31:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

this patch fixes following sparse warning:

cpsw-common.c:23:5: warning: symbol 'cpsw_am33xx_cm_get_macid' was not declared. Should it be static?

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 drivers/net/ethernet/ti/cpsw-common.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw-common.c b/drivers/net/ethernet/ti/cpsw-common.c
index 763ada1..f595094 100644
--- a/drivers/net/ethernet/ti/cpsw-common.c
+++ b/drivers/net/ethernet/ti/cpsw-common.c
@@ -17,6 +17,8 @@
 #include <linux/regmap.h>
 #include <linux/mfd/syscon.h>
 
+#include "cpsw.h"
+
 #define AM33XX_CTRL_MAC_LO_REG(offset, id) ((offset) + 0x8 * (id))
 #define AM33XX_CTRL_MAC_HI_REG(offset, id) ((offset) + 0x8 * (id) + 0x4)
 
-- 
1.9.1
