From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 5/5] stmmac: update the driver version and doc (V2)
Date: Wed, 12 Oct 2011 15:38:08 +0200
Message-ID: <1318426688-9419-6-git-send-email-peppe.cavallaro@st.com>
References: <1318426688-9419-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:41295 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753327Ab1JLNim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 09:38:42 -0400
In-Reply-To: <1318426688-9419-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 Documentation/networking/stmmac.txt          |   11 ++++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h |    2 +-
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index 40ec92c..8d67980 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -76,7 +76,16 @@ core.
 
 4.5) DMA descriptors
 Driver handles both normal and enhanced descriptors. The latter has been only
-tested on DWC Ether MAC 10/100/1000 Universal version 3.41a.
+tested on DWC Ether MAC 10/100/1000 Universal version 3.41a and later.
+
+STMMAC supports DMA descriptor to operate both in dual buffer (RING)
+and linked-list(CHAINED) mode. In RING each descriptor points to two
+data buffer pointers whereas in CHAINED mode they point to only one data
+buffer pointer. RING mode is the default.
+
+In CHAINED mode each descriptor will have pointer to next descriptor in
+the list, hence creating the explicit chaining in the descriptor itself,
+whereas such explicit chaining is not possible in RING mode.
 
 4.6) Ethtool support
 Ethtool is supported. Driver statistics and internal errors can be taken using:
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 50e95d8..49a4af3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -20,7 +20,7 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
-#define DRV_MODULE_VERSION	"Aug_2011"
+#define DRV_MODULE_VERSION	"Oct_2011"
 #include <linux/stmmac.h>
 
 #include "common.h"
-- 
1.7.4.4
