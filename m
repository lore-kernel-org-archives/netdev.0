From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 05/21] e1000: small performance tweak by removing double code
Date: Wed, 21 Jun 2006 22:20:16 -0700
Message-ID: <20060622052016.25497.19919.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:46088 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932799AbWFVFOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:18 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


buffer_info is already filled at the end of this while() loop.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7cf5e5d..76e36a4 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3717,7 +3717,6 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
 	buffer_info = &rx_ring->buffer_info[i];
 
 	while (staterr & E1000_RXD_STAT_DD) {
-		buffer_info = &rx_ring->buffer_info[i];
 		ps_page = &rx_ring->ps_page[i];
 		ps_page_dma = &rx_ring->ps_page_dma[i];
 #ifdef CONFIG_E1000_NAPI



--
Auke Kok <auke-jan.h.kok@intel.com>
