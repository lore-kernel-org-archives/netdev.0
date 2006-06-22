From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 16/21] e1000: disable ERT
Date: Wed, 21 Jun 2006 22:20:41 -0700
Message-ID: <20060622052041.25497.44792.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:60168 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932798AbWFVFOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:43 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hardware is reported to have problems with ERT. We disable it for
all hardware to make sure we are not seeing unexplainable user
problems.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7787299..f5689fa 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1814,9 +1814,6 @@ e1000_configure_rx(struct e1000_adapter 
 		E1000_WRITE_REG(hw, RXCSUM, rxcsum);
 	}
 
-	if (hw->mac_type == e1000_82573)
-		E1000_WRITE_REG(hw, ERT, 0x0100);
-
 	/* Enable Receives */
 	E1000_WRITE_REG(hw, RCTL, rctl);
 }



--
Auke Kok <auke-jan.h.kok@intel.com>
