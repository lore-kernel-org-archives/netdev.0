From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 09/13] e1000: Disable aggressive clocking on esb2 with SERDES port
Date: Wed, 16 Aug 2006 14:56:35 -0700
Message-ID: <20060816215635.27080.14955.stgit@gitlost.site>
References: <20060816215336.27080.56147.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:63753 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932257AbWHPVsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 17:48:47 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060816215336.27080.56147.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Disable aggressive clocking on esb2 with SERDES port as it causes
hardware problems.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index b2caaa2..978e3b7 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1498,8 +1498,6 @@ e1000_configure_tx(struct e1000_adapter 
 	} else if (hw->mac_type == e1000_80003es2lan) {
 		tarc = E1000_READ_REG(hw, TARC0);
 		tarc |= 1;
-		if (hw->media_type == e1000_media_type_internal_serdes)
-			tarc |= (1 << 20);
 		E1000_WRITE_REG(hw, TARC0, tarc);
 		tarc = E1000_READ_REG(hw, TARC1);
 		tarc |= 1;



--
Auke Kok <auke-jan.h.kok@intel.com>
