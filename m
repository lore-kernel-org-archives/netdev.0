From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 04/16] sfc: Comment corrections
Date: Thu, 26 Nov 2009 02:09:04 +0000
Message-ID: <1259201344.2806.11.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:31146 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbZKZCJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 21:09:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c        |    5 +----
 drivers/net/sfc/falcon.h        |    2 +-
 drivers/net/sfc/falcon_boards.c |    2 +-
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index f97ef3e..140087f 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -27,10 +27,7 @@
 #include "phy.h"
 #include "workarounds.h"
 
-/* Falcon hardware control.
- * Falcon is the internal codename for the SFC4000 controller that is
- * present in SFE400X evaluation boards
- */
+/* Hardware control for SFC4000 (aka Falcon). */
 
 /**************************************************************************
  *
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 0da5ea7..ea6ac06 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -61,7 +61,7 @@ struct falcon_board {
 
 /**
  * struct falcon_nic_data - Falcon NIC state
- * @pci_dev2: The secondary PCI device if present
+ * @pci_dev2: Secondary function of Falcon A
  * @board: Board state and functions
  */
 struct falcon_nic_data {
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index 333ccc1..f05c9d3 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -144,7 +144,7 @@ static inline int efx_check_lm87(struct efx_nic *efx, unsigned mask)
  */
 
 /**************************************************************************
- * Support for I2C IO Expander device on SFE40001
+ * Support for I2C IO Expander device on SFE4001
  */
 #define	PCA9539 0x74
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

