From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] e1000e: cleanup hw.h
Date: Mon, 28 Jan 2013 01:04:25 -0800
Message-ID: <1359363869-32391-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32473 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754469Ab3A1JEk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 04:04:40 -0500
In-Reply-To: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Remove unnecessary #include, forward prototype of struct e1000_adapter and
an empty comment; fix a comment which mentions "static data for the MAC"
which is not applicable to the following struct; and cleanup some
whitespace issues.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/hw.h | 25 ++++++++++---------------
 1 file changed, 10 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/hw.h b/drivers/net/ethernet/intel/e1000e/hw.h
index a10de4d..f32b19a 100644
--- a/drivers/net/ethernet/intel/e1000e/hw.h
+++ b/drivers/net/ethernet/intel/e1000e/hw.h
@@ -29,12 +29,9 @@
 #ifndef _E1000_HW_H_
 #define _E1000_HW_H_
 
-#include <linux/types.h>
+#include "defines.h"
 
 struct e1000_hw;
-struct e1000_adapter;
-
-#include "defines.h"
 
 enum e1e_registers {
 	E1000_CTRL     = 0x00000, /* Device Control - RW */
@@ -391,13 +388,11 @@ enum e1e_registers {
 #define E1000_DEV_ID_82573L			0x109A
 #define E1000_DEV_ID_82574L			0x10D3
 #define E1000_DEV_ID_82574LA			0x10F6
-#define E1000_DEV_ID_82583V                     0x150C
-
+#define E1000_DEV_ID_82583V			0x150C
 #define E1000_DEV_ID_80003ES2LAN_COPPER_DPT	0x1096
 #define E1000_DEV_ID_80003ES2LAN_SERDES_DPT	0x1098
 #define E1000_DEV_ID_80003ES2LAN_COPPER_SPT	0x10BA
 #define E1000_DEV_ID_80003ES2LAN_SERDES_SPT	0x10BB
-
 #define E1000_DEV_ID_ICH8_82567V_3		0x1501
 #define E1000_DEV_ID_ICH8_IGP_M_AMT		0x1049
 #define E1000_DEV_ID_ICH8_IGP_AMT		0x104A
@@ -432,12 +427,12 @@ enum e1e_registers {
 #define E1000_DEV_ID_PCH_LPTLP_I218_LM		0x155A
 #define E1000_DEV_ID_PCH_LPTLP_I218_V		0x1559
 
-#define E1000_REVISION_4 4
+#define E1000_REVISION_4	4
 
-#define E1000_FUNC_1 1
+#define E1000_FUNC_1		1
 
-#define E1000_ALT_MAC_ADDRESS_OFFSET_LAN0   0
-#define E1000_ALT_MAC_ADDRESS_OFFSET_LAN1   3
+#define E1000_ALT_MAC_ADDRESS_OFFSET_LAN0	0
+#define E1000_ALT_MAC_ADDRESS_OFFSET_LAN1	3
 
 enum e1000_mac_type {
 	e1000_82571,
@@ -664,7 +659,7 @@ struct e1000_data_desc {
 		struct {
 			u8 status;     /* Descriptor status */
 			u8 popts;      /* Packet Options */
-			__le16 special;   /* */
+			__le16 special;
 		} fields;
 	} upper;
 };
@@ -760,7 +755,7 @@ struct e1000_host_command_header {
 	u8 checksum;
 };
 
-#define E1000_HI_MAX_DATA_LENGTH     252
+#define E1000_HI_MAX_DATA_LENGTH	252
 struct e1000_host_command_info {
 	struct e1000_host_command_header command_header;
 	u8 command_data[E1000_HI_MAX_DATA_LENGTH];
@@ -775,13 +770,13 @@ struct e1000_host_mng_command_header {
 	u16 command_length;
 };
 
-#define E1000_HI_MAX_MNG_DATA_LENGTH 0x6F8
+#define E1000_HI_MAX_MNG_DATA_LENGTH	0x6F8
 struct e1000_host_mng_command_info {
 	struct e1000_host_mng_command_header command_header;
 	u8 command_data[E1000_HI_MAX_MNG_DATA_LENGTH];
 };
 
-/* Function pointers and static data for the MAC. */
+/* Function pointers for the MAC. */
 struct e1000_mac_operations {
 	s32  (*id_led_init)(struct e1000_hw *);
 	s32  (*blink_led)(struct e1000_hw *);
-- 
1.7.11.7
