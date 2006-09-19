From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 21/23] ixgb: combine more rx descriptors to improve performance
Date: Tue, 19 Sep 2006 10:29:20 -0700
Message-ID: <20060919172920.4605.24456.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:31757 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030358AbWISRUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:20:25 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We experimented with more descriptor buffer writebacks and found that
values larger than 8 give HW problems, but 8 is safe and gives us some
improved performance.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index a1a7f3b..50ffe90 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -111,7 +111,7 @@ struct ixgb_adapter;
 #define IXGB_RXBUFFER_16384 16384
 
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
-#define IXGB_RX_BUFFER_WRITE	4	/* Must be power of 2 */
+#define IXGB_RX_BUFFER_WRITE	8	/* Must be power of 2 */
 
 /* only works for sizes that are powers of 2 */
 #define IXGB_ROUNDUP(i, size) ((i) = (((i) + (size) - 1) & ~((size) - 1)))



---
Auke Kok <auke-jan.h.kok@intel.com>
