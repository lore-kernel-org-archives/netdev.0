From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] e1000e: mark shifted values as unsigned
Date: Fri, 13 May 2016 16:43:53 -0700
Message-ID: <1463183035-31888-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:31691 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932231AbcEMXoB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 19:44:01 -0400
In-Reply-To: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The E1000_ICH_NVM_SIG_MASK value is shifted, out to the 31st bit, which
is the signed bit for signed constants. Mark these values as unsigned to
prevent compiler warnings and issues on platforms which a different
signed bit implementation.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.h b/drivers/net/ethernet/intel/e1000e/ich8lan.h
index 2311f60..67163ca 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.h
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.h
@@ -73,10 +73,10 @@
 				 (ID_LED_OFF1_ON2  <<  4) | \
 				 (ID_LED_DEF1_DEF2))
 
-#define E1000_ICH_NVM_SIG_WORD		0x13
-#define E1000_ICH_NVM_SIG_MASK		0xC000
-#define E1000_ICH_NVM_VALID_SIG_MASK	0xC0
-#define E1000_ICH_NVM_SIG_VALUE		0x80
+#define E1000_ICH_NVM_SIG_WORD		0x13u
+#define E1000_ICH_NVM_SIG_MASK		0xC000u
+#define E1000_ICH_NVM_VALID_SIG_MASK	0xC0u
+#define E1000_ICH_NVM_SIG_VALUE		0x80u
 
 #define E1000_ICH8_LAN_INIT_TIMEOUT	1500
 
-- 
2.5.5
