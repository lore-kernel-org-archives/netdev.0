From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] e1000: allow option to limit number of
	descriptors down to 48 per ring
Date: Mon, 19 Jul 2010 16:43:47 -0700
Message-ID: <20100719234219.13875.90302.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:43570
	"EHLO qmta13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757358Ab0GSXoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 19:44:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it possible to limit the number of descriptors down to 48
per ring.  The reason for this change is to address a variation on hardware
errata 10 for 82546GB in which descriptors will be lost if more than 32
descriptors are fetched and the PCI-X MRBC is 512.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 40b62b4..65298a6 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -86,12 +86,12 @@ struct e1000_adapter;
 /* TX/RX descriptor defines */
 #define E1000_DEFAULT_TXD                  256
 #define E1000_MAX_TXD                      256
-#define E1000_MIN_TXD                       80
+#define E1000_MIN_TXD                       48
 #define E1000_MAX_82544_TXD               4096
 
 #define E1000_DEFAULT_RXD                  256
 #define E1000_MAX_RXD                      256
-#define E1000_MIN_RXD                       80
+#define E1000_MIN_RXD                       48
 #define E1000_MAX_82544_RXD               4096
 
 #define E1000_MIN_ITR_USECS		10 /* 100000 irq/sec */

