From: Stefan Roese <sr@denx.de>
Subject: [PATCH] stmmac: Fix compilation error in mmc_core.c
Date: Tue, 10 Jan 2012 12:47:40 +0100
Message-ID: <1326196060-10283-1-git-send-email-sr@denx.de>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.181]:21608 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755792Ab2AJL6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 06:58:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this error:

  CC      drivers/net/ethernet/stmicro/stmmac/mmc_core.o
drivers/net/ethernet/stmicro/stmmac/mmc_core.c: In function 'dwmac_mmc_ctrl':
drivers/net/ethernet/stmicro/stmmac/mmc_core.c:143:2: error: implicit
  declaration of function 'pr_debug' [-Werror=implicit-function-declaration]

Signed-off-by: Stefan Roese <sr@denx.de>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/mmc_core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
index 41e6b33..c07cfe9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
@@ -22,6 +22,7 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
+#include <linux/kernel.h>
 #include <linux/io.h>
 #include "mmc.h"
 
-- 
1.7.8.3
