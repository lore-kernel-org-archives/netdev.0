From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 01/21] e1000: fix loopback ethtool test
Date: Wed, 21 Jun 2006 22:20:07 -0700
Message-ID: <20060622052007.25497.41396.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:41224 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751565AbWFVFOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:09 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ethtool was reporting that loopback failed randomly on esb2
systems. Upon study it was found that the phy manual was changed
with respect to the loopback mode bits. The new value fixes it.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 6ed7f59..845d293 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1246,7 +1246,7 @@ e1000_integrated_phy_loopback(struct e10
 	} else if (adapter->hw.phy_type == e1000_phy_gg82563) {
 		e1000_write_phy_reg(&adapter->hw,
 		                    GG82563_PHY_KMRN_MODE_CTRL,
-		                    0x1CE);
+		                    0x1CC);
 	}
 	/* force 1000, set loopback */
 	e1000_write_phy_reg(&adapter->hw, PHY_CTRL, 0x4140);



--
Auke Kok <auke-jan.h.kok@intel.com>
