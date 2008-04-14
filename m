From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 5/5] e1000e: lower ring minimum size to 64
Date: Mon, 14 Apr 2008 10:06:19 -0700
Message-ID: <20080414170619.23286.25518.stgit@localhost.localdomain>
References: <20080414170557.23286.71580.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61921 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762461AbYDNRGn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 13:06:43 -0400
In-Reply-To: <20080414170557.23286.71580.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lower limit of 80 descriptors in the ring is only valid for
one older 8254x chipset. All e1000e devices can use as low as
64 descriptors.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/e1000.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index f6835c3..38bfd0d 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -64,11 +64,11 @@ struct e1000_info;
 /* Tx/Rx descriptor defines */
 #define E1000_DEFAULT_TXD		256
 #define E1000_MAX_TXD			4096
-#define E1000_MIN_TXD			80
+#define E1000_MIN_TXD			64
 
 #define E1000_DEFAULT_RXD		256
 #define E1000_MAX_RXD			4096
-#define E1000_MIN_RXD			80
+#define E1000_MIN_RXD			64
 
 #define E1000_MIN_ITR_USECS		10 /* 100000 irq/sec */
 #define E1000_MAX_ITR_USECS		10000 /* 100    irq/sec */

