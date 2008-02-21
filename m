From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/7] e1000e: fix flow control when using ethtool overrides
Date: Thu, 21 Feb 2008 15:10:57 -0800
Message-ID: <20080221231057.5595.87736.stgit@localhost.localdomain>
References: <20080221231041.5595.4933.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42144 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753651AbYBUXMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2008 18:12:37 -0500
In-Reply-To: <20080221231041.5595.4933.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/lib.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 16f35fa..0860b5f 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -589,9 +589,6 @@ static s32 e1000_set_default_fc_generic(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 nvm_data;
 
-	if (mac->fc != e1000_fc_default)
-		return 0;
-
 	/* Read and store word 0x0F of the EEPROM. This word contains bits
 	 * that determine the hardware's default PAUSE (flow control) mode,
 	 * a bit that determines whether the HW defaults to enabling or

