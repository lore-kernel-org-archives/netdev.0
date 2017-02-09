From: Saber Rezvani <irsaber@gmail.com>
Subject: [PATCH 1/1] net: ethernet: intel: e1000: add space after close brace
Date: Fri, 10 Feb 2017 01:36:40 +0330
Message-ID: <1486678000-11468-1-git-send-email-irsaber@gmail.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Saber Rezvani <irsaber@gmail.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-pp-092.zoho.com ([135.84.80.237]:25372 "EHLO
        sender-pp-092.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751682AbdBIWXx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 17:23:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes checkpatch.pl error:
ERROR: space required after that close brace '}'

Signed-off-by: Saber Rezvani <irsaber@gmail.com>
---
 drivers/net/ethernet/intel/e1000/e1000_param.c | 28 +++++++++++++-------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_param.c b/drivers/net/ethernet/intel/e1000/e1000_param.c
index c9cde35..4a8a38a 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_param.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_param.c
@@ -291,7 +291,7 @@ void e1000_check_options(struct e1000_adapter *adapter)
 			.arg  = { .r = {
 				.min = E1000_MIN_TXD,
 				.max = mac_type < e1000_82544 ? E1000_MAX_TXD : E1000_MAX_82544_TXD
-				}}
+				} }
 		};
 
 		if (num_TxDescriptors > bd) {
@@ -320,7 +320,7 @@ void e1000_check_options(struct e1000_adapter *adapter)
 				.min = E1000_MIN_RXD,
 				.max = mac_type < e1000_82544 ? E1000_MAX_RXD :
 				       E1000_MAX_82544_RXD
-			}}
+			} }
 		};
 
 		if (num_RxDescriptors > bd) {
@@ -366,7 +366,7 @@ void e1000_check_options(struct e1000_adapter *adapter)
 			.err  = "reading default settings from EEPROM",
 			.def  = E1000_FC_DEFAULT,
 			.arg  = { .l = { .nr = ARRAY_SIZE(fc_list),
-					 .p = fc_list }}
+					 .p = fc_list } }
 		};
 
 		if (num_FlowControl > bd) {
@@ -384,7 +384,7 @@ void e1000_check_options(struct e1000_adapter *adapter)
 			.err  = "using default of " __MODULE_STRING(DEFAULT_TIDV),
 			.def  = DEFAULT_TIDV,
 			.arg  = { .r = { .min = MIN_TXDELAY,
-					 .max = MAX_TXDELAY }}
+					 .max = MAX_TXDELAY } }
 		};
 
 		if (num_TxIntDelay > bd) {
@@ -402,7 +402,7 @@ void e1000_check_options(struct e1000_adapter *adapter)
 			.err  = "using default of " __MODULE_STRING(DEFAULT_TADV),
 			.def  = DEFAULT_TADV,
 			.arg  = { .r = { .min = MIN_TXABSDELAY,
-					 .max = MAX_TXABSDELAY }}
+					 .max = MAX_TXABSDELAY } }
 		};
 
 		if (num_TxAbsIntDelay > bd) {
@@ -420,7 +420,7 @@ void e1000_check_options(struct e1000_adapter *adapter)
 			.err  = "using default of " __MODULE_STRING(DEFAULT_RDTR),
 			.def  = DEFAULT_RDTR,
 			.arg  = { .r = { .min = MIN_RXDELAY,
-					 .max = MAX_RXDELAY }}
+					 .max = MAX_RXDELAY } }
 		};
 
 		if (num_RxIntDelay > bd) {
@@ -438,7 +438,7 @@ void e1000_check_options(struct e1000_adapter *adapter)
 			.err  = "using default of " __MODULE_STRING(DEFAULT_RADV),
 			.def  = DEFAULT_RADV,
 			.arg  = { .r = { .min = MIN_RXABSDELAY,
-					 .max = MAX_RXABSDELAY }}
+					 .max = MAX_RXABSDELAY } }
 		};
 
 		if (num_RxAbsIntDelay > bd) {
@@ -456,7 +456,7 @@ void e1000_check_options(struct e1000_adapter *adapter)
 			.err  = "using default of " __MODULE_STRING(DEFAULT_ITR),
 			.def  = DEFAULT_ITR,
 			.arg  = { .r = { .min = MIN_ITR,
-					 .max = MAX_ITR }}
+					 .max = MAX_ITR } }
 		};
 
 		if (num_InterruptThrottleRate > bd) {
@@ -570,7 +570,7 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter)
 			{          0, "" },
 			{   SPEED_10, "" },
 			{  SPEED_100, "" },
-			{ SPEED_1000, "" }};
+			{ SPEED_1000, "" } };
 
 		opt = (struct e1000_option) {
 			.type = list_option,
@@ -578,7 +578,7 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter)
 			.err  = "parameter ignored",
 			.def  = 0,
 			.arg  = { .l = { .nr = ARRAY_SIZE(speed_list),
-					 .p = speed_list }}
+					 .p = speed_list } }
 		};
 
 		if (num_Speed > bd) {
@@ -592,7 +592,7 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter)
 		static const struct e1000_opt_list dplx_list[] = {
 			{           0, "" },
 			{ HALF_DUPLEX, "" },
-			{ FULL_DUPLEX, "" }};
+			{ FULL_DUPLEX, "" } };
 
 		opt = (struct e1000_option) {
 			.type = list_option,
@@ -600,7 +600,7 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter)
 			.err  = "parameter ignored",
 			.def  = 0,
 			.arg  = { .l = { .nr = ARRAY_SIZE(dplx_list),
-					 .p = dplx_list }}
+					 .p = dplx_list } }
 		};
 
 		if (num_Duplex > bd) {
@@ -648,7 +648,7 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter)
 			 { 0x2c, AA "1000/FD, 100/FD, 100/HD" },
 			 { 0x2d, AA "1000/FD, 100/FD, 100/HD, 10/HD" },
 			 { 0x2e, AA "1000/FD, 100/FD, 100/HD, 10/FD" },
-			 { 0x2f, AA "1000/FD, 100/FD, 100/HD, 10/FD, 10/HD" }};
+			 { 0x2f, AA "1000/FD, 100/FD, 100/HD, 10/FD, 10/HD" } };
 
 		opt = (struct e1000_option) {
 			.type = list_option,
@@ -656,7 +656,7 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter)
 			.err  = "parameter ignored",
 			.def  = AUTONEG_ADV_DEFAULT,
 			.arg  = { .l = { .nr = ARRAY_SIZE(an_list),
-					 .p = an_list }}
+					 .p = an_list } }
 		};
 
 		if (num_AutoNeg > bd) {
-- 
2.7.4
