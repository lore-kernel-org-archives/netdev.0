From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH 1/3] igb: fix typo in igb_validate_nvm_checksum_82580
Date: Tue, 29 Mar 2011 15:09:44 +0200
Message-ID: <1301404186-20872-2-git-send-email-sassmann@kpanic.de>
References: <1301404186-20872-1-git-send-email-sassmann@kpanic.de>
Cc: e1000-devel@lists.sourceforge.net, jeffrey.t.kirsher@intel.com,
	alexander.h.duyck@intel.com, sassmann@kpanic.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20984 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753183Ab1C2NJ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2011 09:09:58 -0400
In-Reply-To: <1301404186-20872-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Comment spelling fix.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/igb/e1000_82575.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 6b256c2..0cd41c4 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1877,7 +1877,7 @@ static s32 igb_validate_nvm_checksum_82580(struct e1000_hw *hw)
 	}
 
 	if (nvm_data & NVM_COMPATIBILITY_BIT_MASK) {
-		/* if chekcsums compatibility bit is set validate checksums
+		/* if checksums compatibility bit is set validate checksums
 		 * for all 4 ports. */
 		eeprom_regions_count = 4;
 	}
@@ -1988,6 +1988,7 @@ static s32 igb_update_nvm_checksum_i350(struct e1000_hw *hw)
 out:
 	return ret_val;
 }
+
 /**
  *  igb_set_eee_i350 - Enable/disable EEE support
  *  @hw: pointer to the HW structure
-- 
1.7.4

