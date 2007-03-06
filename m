From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] ixgb: Use ARRAY_SIZE macro when appropriate.
Date: Tue, 06 Mar 2007 11:08:28 -0800
Message-ID: <20070306190828.1882.9647.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, john.ronciak@intel.com,
	jesse.brandeburg@intel.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:35370 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932770AbXCFTIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 14:08:30 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ahmed S. Darwish <darwish.07@gmail.com>

Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb_param.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
index b27442a..c38ce73 100644
--- a/drivers/net/ixgb/ixgb_param.c
+++ b/drivers/net/ixgb/ixgb_param.c
@@ -245,8 +245,6 @@ ixgb_validate_option(int *value, struct ixgb_option *opt)
 	return -1;
 }
 
-#define LIST_LEN(l) (sizeof(l) / sizeof(l[0]))
-
 /**
  * ixgb_check_options - Range Checking for Command Line Parameters
  * @adapter: board private structure
@@ -335,7 +333,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 			.name = "Flow Control",
 			.err  = "reading default settings from EEPROM",
 			.def  = ixgb_fc_tx_pause,
-			.arg  = { .l = { .nr = LIST_LEN(fc_list),
+			.arg  = { .l = { .nr = ARRAY_SIZE(fc_list),
 					 .p = fc_list }}
 		};
 
