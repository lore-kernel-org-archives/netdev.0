From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/18] ixgbe: Delete some unused register definitions
Date: Thu,  7 Apr 2016 20:20:56 -0700
Message-ID: <1460085673-87056-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63152 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752046AbcDHDVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 23:21:17 -0400
In-Reply-To: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

I noticed the SRAMREL registers are not referenced for any device,
so delete the definitions.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index bc012ab..d02a0a3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -143,13 +143,6 @@
 #define IXGBE_GRC_X550EM_a	0x15F64
 #define IXGBE_GRC(_hw)		IXGBE_BY_MAC((_hw), GRC)
 
-#define IXGBE_SRAMREL_8259X	0x10210
-#define IXGBE_SRAMREL_X540	IXGBE_SRAMREL_8259X
-#define IXGBE_SRAMREL_X550	IXGBE_SRAMREL_8259X
-#define IXGBE_SRAMREL_X550EM_x	IXGBE_SRAMREL_8259X
-#define IXGBE_SRAMREL_X550EM_a	0x15F6C
-#define IXGBE_SRAMREL(_hw)	IXGBE_BY_MAC((_hw), SRAMREL)
-
 /* General Receive Control */
 #define IXGBE_GRC_MNG  0x00000001 /* Manageability Enable */
 #define IXGBE_GRC_APME 0x00000002 /* APM enabled in EEPROM */
@@ -2948,7 +2941,6 @@ union ixgbe_atr_hash_dword {
 	IXGBE_CAT(EEC, m),		\
 	IXGBE_CAT(FLA, m),		\
 	IXGBE_CAT(GRC, m),		\
-	IXGBE_CAT(SRAMREL, m),		\
 	IXGBE_CAT(FACTPS, m),		\
 	IXGBE_CAT(SWSM, m),		\
 	IXGBE_CAT(SWFW_SYNC, m),	\
-- 
2.5.5
