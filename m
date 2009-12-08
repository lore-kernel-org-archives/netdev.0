From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/3] e1000e: minor correction to name of bit in CTRL_EXT
	register
Date: Tue, 08 Dec 2009 09:27:41 -0800
Message-ID: <20091208172725.19741.25809.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:45054
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936840AbZLHR1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 12:27:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Bit 7 in the CTRL_REG register is actually the Software Definable Pin 3,
not the Software Definable Pin 7.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/defines.h |    2 +-
 drivers/net/e1000e/netdev.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 86d2809..e02e382 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -74,7 +74,7 @@
 #define E1000_WUS_BC           E1000_WUFC_BC
 
 /* Extended Device Control */
-#define E1000_CTRL_EXT_SDP7_DATA 0x00000080 /* Value of SW Definable Pin 7 */
+#define E1000_CTRL_EXT_SDP3_DATA 0x00000080 /* Value of SW Definable Pin 3 */
 #define E1000_CTRL_EXT_EE_RST    0x00002000 /* Reinitialize from EEPROM */
 #define E1000_CTRL_EXT_SPD_BYPS  0x00008000 /* Speed Select Bypass */
 #define E1000_CTRL_EXT_RO_DIS    0x00020000 /* Relaxed Ordering disable */
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index c3105c5..762b697 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4541,7 +4541,7 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 		    e1000_media_type_internal_serdes) {
 			/* keep the laser running in D3 */
 			ctrl_ext = er32(CTRL_EXT);
-			ctrl_ext |= E1000_CTRL_EXT_SDP7_DATA;
+			ctrl_ext |= E1000_CTRL_EXT_SDP3_DATA;
 			ew32(CTRL_EXT, ctrl_ext);
 		}
 

