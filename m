From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 22/26] ixgb: Cache-align all TX components of the adapter struct.
Date: Tue, 29 Aug 2006 09:45:03 -0700
Message-ID: <20060829164503.6872.93015.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:57354 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965093AbWH2Qgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:50 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index a4bee8c..e157247 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -170,7 +170,7 @@ struct ixgb_adapter {
 	unsigned long led_status;
 
 	/* TX */
-	struct ixgb_desc_ring tx_ring;
+	struct ixgb_desc_ring tx_ring ____cacheline_aligned;
 	unsigned long timeo_start;
 	uint32_t tx_cmd_type;
 	uint64_t hw_csum_tx_good;



---
Auke Kok <auke-jan.h.kok@intel.com>
