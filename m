From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/8] igb: fix comments
Date: Fri, 01 Aug 2008 16:11:06 -0700
Message-ID: <20080801231106.393.46174.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:4861 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367AbYHAXLM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 19:11:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The internal name was used in comments, replaced with silicon part number.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |    2 +-
 drivers/net/igb/igb_main.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index e098f23..f3d7be0 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1243,7 +1243,7 @@ out:
 u32 igb_translate_register_82576(u32 reg)
 {
 	/*
-	 * Some of the Kawela registers are located at different
+	 * Some of the 82576 registers are located at different
 	 * offsets than they are in older adapters.
 	 * Despite the difference in location, the registers
 	 * function in the same manner.
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index b602c4d..f23a048 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -311,7 +311,7 @@ static void igb_assign_vector(struct igb_adapter *adapter, int rx_queue,
 		array_wr32(E1000_MSIXBM(0), msix_vector, msixbm);
 		break;
 	case e1000_82576:
-		/* Kawela uses a table-based method for assigning vectors.
+		/* The 82576 uses a table-based method for assigning vectors.
 		   Each queue has a single entry in the table to which we write
 		   a vector number along with a "valid" bit.  Sadly, the layout
 		   of the table is somewhat counterintuitive. */

