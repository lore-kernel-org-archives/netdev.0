From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 02/24] igb: fix typo in igb_validate_nvm_checksum_82580
Date: Wed, 13 Apr 2011 18:01:58 -0700
Message-ID: <1302742940-22141-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stefan Assmann <sassmann@kpanic.de>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30345 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757658Ab1DNBC1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:27 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@kpanic.de>

Comment spelling fix.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
Tested-by:  Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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
1.7.4.2

