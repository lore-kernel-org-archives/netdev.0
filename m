From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 34/36] bnx2x: Removing unused definitions
Date: Wed, 12 Aug 2009 21:24:25 +0300
Message-ID: <1250101465.27379.186.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Vladislav Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3470 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753391AbZHLSZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:25:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_reg.h |  811 -----------------------------------------------
 1 files changed, 0 insertions(+), 811 deletions(-)

diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 1e6f5aa..95ebf3f 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -190,12 +190,6 @@
    _(0..15) stands for the connection type (one of 16). */
 #define CCM_REG_N_SM_CTX_LD_0					 0xd004c
 #define CCM_REG_N_SM_CTX_LD_1					 0xd0050
-#define CCM_REG_N_SM_CTX_LD_10					 0xd0074
-#define CCM_REG_N_SM_CTX_LD_11					 0xd0078
-#define CCM_REG_N_SM_CTX_LD_12					 0xd007c
-#define CCM_REG_N_SM_CTX_LD_13					 0xd0080
-#define CCM_REG_N_SM_CTX_LD_14					 0xd0084
-#define CCM_REG_N_SM_CTX_LD_15					 0xd0088
 #define CCM_REG_N_SM_CTX_LD_2					 0xd0054
 #define CCM_REG_N_SM_CTX_LD_3					 0xd0058
 #define CCM_REG_N_SM_CTX_LD_4					 0xd005c
@@ -622,24 +616,6 @@
 #define DMAE_REG_GO_C1						 0x102084
 /* [RW 1] Command 10 go. */
 #define DMAE_REG_GO_C10 					 0x102088
-#define DMAE_REG_GO_C10_SIZE					 1
-/* [RW 1] Command 11 go. */
-#define DMAE_REG_GO_C11 					 0x10208c
-#define DMAE_REG_GO_C11_SIZE					 1
-/* [RW 1] Command 12 go. */
-#define DMAE_REG_GO_C12 					 0x102090
-#define DMAE_REG_GO_C12_SIZE					 1
-/* [RW 1] Command 13 go. */
-#define DMAE_REG_GO_C13 					 0x102094
-#define DMAE_REG_GO_C13_SIZE					 1
-/* [RW 1] Command 14 go. */
-#define DMAE_REG_GO_C14 					 0x102098
-#define DMAE_REG_GO_C14_SIZE					 1
-/* [RW 1] Command 15 go. */
-#define DMAE_REG_GO_C15 					 0x10209c
-#define DMAE_REG_GO_C15_SIZE					 1
-/* [RW 1] Command 10 go. */
-#define DMAE_REG_GO_C10 					 0x102088
 /* [RW 1] Command 11 go. */
 #define DMAE_REG_GO_C11 					 0x10208c
 /* [RW 1] Command 12 go. */
@@ -789,7 +765,6 @@
 #define MCP_REG_MCPR_NVM_READ					 0x86410
 #define MCP_REG_MCPR_NVM_SW_ARB 				 0x86420
 #define MCP_REG_MCPR_NVM_WRITE					 0x86408
-#define MCP_REG_MCPR_NVM_WRITE1 				 0x86428
 #define MCP_REG_MCPR_SCRATCH					 0xa0000
 /* [R 32] read first 32 bit after inversion of function 0. mapped as
    follows: [0] NIG attention for function0; [1] NIG attention for
@@ -1175,19 +1150,7 @@
 #define MISC_REG_AEU_GENERAL_ATTN_10				 0xa028
 #define MISC_REG_AEU_GENERAL_ATTN_11				 0xa02c
 #define MISC_REG_AEU_GENERAL_ATTN_12				 0xa030
-#define MISC_REG_AEU_GENERAL_ATTN_13				 0xa034
-#define MISC_REG_AEU_GENERAL_ATTN_14				 0xa038
-#define MISC_REG_AEU_GENERAL_ATTN_15				 0xa03c
-#define MISC_REG_AEU_GENERAL_ATTN_16				 0xa040
-#define MISC_REG_AEU_GENERAL_ATTN_17				 0xa044
-#define MISC_REG_AEU_GENERAL_ATTN_18				 0xa048
-#define MISC_REG_AEU_GENERAL_ATTN_19				 0xa04c
-#define MISC_REG_AEU_GENERAL_ATTN_10				 0xa028
-#define MISC_REG_AEU_GENERAL_ATTN_11				 0xa02c
-#define MISC_REG_AEU_GENERAL_ATTN_12				 0xa030
 #define MISC_REG_AEU_GENERAL_ATTN_2				 0xa008
-#define MISC_REG_AEU_GENERAL_ATTN_20				 0xa050
-#define MISC_REG_AEU_GENERAL_ATTN_21				 0xa054
 #define MISC_REG_AEU_GENERAL_ATTN_3				 0xa00c
 #define MISC_REG_AEU_GENERAL_ATTN_4				 0xa010
 #define MISC_REG_AEU_GENERAL_ATTN_5				 0xa014
@@ -1279,133 +1242,7 @@
    set. if the appropriate bit is clear (the driver request to free a client
    it doesn't controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW interrupt will
    be asserted). */
-#define MISC_REG_DRIVER_CONTROL_10				 0xa3e0
-#define MISC_REG_DRIVER_CONTROL_10_SIZE 			 2
-/* [RW 32] The following driver registers(1...16) represent 16 drivers and
-   32 clients. Each client can be controlled by one driver only. One in each
-   bit represent that this driver control the appropriate client (Ex: bit 5
-   is set means this driver control client number 5). addr1 = set; addr0 =
-   clear; read from both addresses will give the same result = status. write
-   to address 1 will set a request to control all the clients that their
-   appropriate bit (in the write command) is set. if the client is free (the
-   appropriate bit in all the other drivers is clear) one will be written to
-   that driver register; if the client isn't free the bit will remain zero.
-   if the appropriate bit is set (the driver request to gain control on a
-   client it already controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW
-   interrupt will be asserted). write to address 0 will set a request to
-   free all the clients that their appropriate bit (in the write command) is
-   set. if the appropriate bit is clear (the driver request to free a client
-   it doesn't controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW interrupt will
-   be asserted). */
-#define MISC_REG_DRIVER_CONTROL_11				 0xa3e8
-#define MISC_REG_DRIVER_CONTROL_11_SIZE 			 2
-/* [RW 32] The following driver registers(1...16) represent 16 drivers and
-   32 clients. Each client can be controlled by one driver only. One in each
-   bit represent that this driver control the appropriate client (Ex: bit 5
-   is set means this driver control client number 5). addr1 = set; addr0 =
-   clear; read from both addresses will give the same result = status. write
-   to address 1 will set a request to control all the clients that their
-   appropriate bit (in the write command) is set. if the client is free (the
-   appropriate bit in all the other drivers is clear) one will be written to
-   that driver register; if the client isn't free the bit will remain zero.
-   if the appropriate bit is set (the driver request to gain control on a
-   client it already controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW
-   interrupt will be asserted). write to address 0 will set a request to
-   free all the clients that their appropriate bit (in the write command) is
-   set. if the appropriate bit is clear (the driver request to free a client
-   it doesn't controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW interrupt will
-   be asserted). */
-#define MISC_REG_DRIVER_CONTROL_12				 0xa3f0
-#define MISC_REG_DRIVER_CONTROL_12_SIZE 			 2
-/* [RW 32] The following driver registers(1...16) represent 16 drivers and
-   32 clients. Each client can be controlled by one driver only. One in each
-   bit represent that this driver control the appropriate client (Ex: bit 5
-   is set means this driver control client number 5). addr1 = set; addr0 =
-   clear; read from both addresses will give the same result = status. write
-   to address 1 will set a request to control all the clients that their
-   appropriate bit (in the write command) is set. if the client is free (the
-   appropriate bit in all the other drivers is clear) one will be written to
-   that driver register; if the client isn't free the bit will remain zero.
-   if the appropriate bit is set (the driver request to gain control on a
-   client it already controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW
-   interrupt will be asserted). write to address 0 will set a request to
-   free all the clients that their appropriate bit (in the write command) is
-   set. if the appropriate bit is clear (the driver request to free a client
-   it doesn't controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW interrupt will
-   be asserted). */
-#define MISC_REG_DRIVER_CONTROL_13				 0xa3f8
-#define MISC_REG_DRIVER_CONTROL_13_SIZE 			 2
-/* [RW 32] The following driver registers(1...16) represent 16 drivers and
-   32 clients. Each client can be controlled by one driver only. One in each
-   bit represent that this driver control the appropriate client (Ex: bit 5
-   is set means this driver control client number 5). addr1 = set; addr0 =
-   clear; read from both addresses will give the same result = status. write
-   to address 1 will set a request to control all the clients that their
-   appropriate bit (in the write command) is set. if the client is free (the
-   appropriate bit in all the other drivers is clear) one will be written to
-   that driver register; if the client isn't free the bit will remain zero.
-   if the appropriate bit is set (the driver request to gain control on a
-   client it already controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW
-   interrupt will be asserted). write to address 0 will set a request to
-   free all the clients that their appropriate bit (in the write command) is
-   set. if the appropriate bit is clear (the driver request to free a client
-   it doesn't controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW interrupt will
-   be asserted). */
 #define MISC_REG_DRIVER_CONTROL_1				 0xa510
-#define MISC_REG_DRIVER_CONTROL_14				 0xa5e0
-#define MISC_REG_DRIVER_CONTROL_14_SIZE 			 2
-/* [RW 32] The following driver registers(1...16) represent 16 drivers and
-   32 clients. Each client can be controlled by one driver only. One in each
-   bit represent that this driver control the appropriate client (Ex: bit 5
-   is set means this driver control client number 5). addr1 = set; addr0 =
-   clear; read from both addresses will give the same result = status. write
-   to address 1 will set a request to control all the clients that their
-   appropriate bit (in the write command) is set. if the client is free (the
-   appropriate bit in all the other drivers is clear) one will be written to
-   that driver register; if the client isn't free the bit will remain zero.
-   if the appropriate bit is set (the driver request to gain control on a
-   client it already controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW
-   interrupt will be asserted). write to address 0 will set a request to
-   free all the clients that their appropriate bit (in the write command) is
-   set. if the appropriate bit is clear (the driver request to free a client
-   it doesn't controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW interrupt will
-   be asserted). */
-#define MISC_REG_DRIVER_CONTROL_15				 0xa5e8
-#define MISC_REG_DRIVER_CONTROL_15_SIZE 			 2
-/* [RW 32] The following driver registers(1...16) represent 16 drivers and
-   32 clients. Each client can be controlled by one driver only. One in each
-   bit represent that this driver control the appropriate client (Ex: bit 5
-   is set means this driver control client number 5). addr1 = set; addr0 =
-   clear; read from both addresses will give the same result = status. write
-   to address 1 will set a request to control all the clients that their
-   appropriate bit (in the write command) is set. if the client is free (the
-   appropriate bit in all the other drivers is clear) one will be written to
-   that driver register; if the client isn't free the bit will remain zero.
-   if the appropriate bit is set (the driver request to gain control on a
-   client it already controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW
-   interrupt will be asserted). write to address 0 will set a request to
-   free all the clients that their appropriate bit (in the write command) is
-   set. if the appropriate bit is clear (the driver request to free a client
-   it doesn't controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW interrupt will
-   be asserted). */
-#define MISC_REG_DRIVER_CONTROL_16				 0xa5f0
-#define MISC_REG_DRIVER_CONTROL_16_SIZE 			 2
-/* [RW 32] The following driver registers(1...16) represent 16 drivers and
-   32 clients. Each client can be controlled by one driver only. One in each
-   bit represent that this driver control the appropriate client (Ex: bit 5
-   is set means this driver control client number 5). addr1 = set; addr0 =
-   clear; read from both addresses will give the same result = status. write
-   to address 1 will set a request to control all the clients that their
-   appropriate bit (in the write command) is set. if the client is free (the
-   appropriate bit in all the other drivers is clear) one will be written to
-   that driver register; if the client isn't free the bit will remain zero.
-   if the appropriate bit is set (the driver request to gain control on a
-   client it already controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW
-   interrupt will be asserted). write to address 0 will set a request to
-   free all the clients that their appropriate bit (in the write command) is
-   set. if the appropriate bit is clear (the driver request to free a client
-   it doesn't controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW interrupt will
-   be asserted). */
 #define MISC_REG_DRIVER_CONTROL_7				 0xa3c8
 /* [RW 1] e1hmf for WOL. If clr WOL signal o the PXP will be send on bit 0
    only. */
@@ -1650,8 +1487,6 @@
 /* [RW 1] MAC configuration for packets of port0. If 1 - all packet outputs
    to emac for port0; other way to bmac for port0 */
 #define NIG_REG_EGRESS_EMAC0_PORT				 0x10058
-/* [RW 32] TX_MNG_FIFO in NIG_TX_PORT0; data[31:0] written in FIFO order. */
-#define NIG_REG_EGRESS_MNG0_FIFO				 0x1045c
 /* [RW 1] Input enable for TX PBF user packet port0 IF */
 #define NIG_REG_EGRESS_PBF0_IN_EN				 0x100cc
 /* [RW 1] Input enable for TX PBF user packet port1 IF */
@@ -2161,11 +1996,8 @@
 #define PXP2_REG_PSWRQ_BW_ADD1					 0x1201c0
 #define PXP2_REG_PSWRQ_BW_ADD10 				 0x1201e4
 #define PXP2_REG_PSWRQ_BW_ADD11 				 0x1201e8
-#define PXP2_REG_PSWRQ_BW_ADD10 				 0x1201e4
-#define PXP2_REG_PSWRQ_BW_ADD11 				 0x1201e8
 #define PXP2_REG_PSWRQ_BW_ADD2					 0x1201c4
 #define PXP2_REG_PSWRQ_BW_ADD28 				 0x120228
-#define PXP2_REG_PSWRQ_BW_ADD28 				 0x120228
 #define PXP2_REG_PSWRQ_BW_ADD3					 0x1201c8
 #define PXP2_REG_PSWRQ_BW_ADD6					 0x1201d4
 #define PXP2_REG_PSWRQ_BW_ADD7					 0x1201d8
@@ -2175,11 +2007,8 @@
 #define PXP2_REG_PSWRQ_BW_L1					 0x1202b0
 #define PXP2_REG_PSWRQ_BW_L10					 0x1202d4
 #define PXP2_REG_PSWRQ_BW_L11					 0x1202d8
-#define PXP2_REG_PSWRQ_BW_L10					 0x1202d4
-#define PXP2_REG_PSWRQ_BW_L11					 0x1202d8
 #define PXP2_REG_PSWRQ_BW_L2					 0x1202b4
 #define PXP2_REG_PSWRQ_BW_L28					 0x120318
-#define PXP2_REG_PSWRQ_BW_L28					 0x120318
 #define PXP2_REG_PSWRQ_BW_L3					 0x1202b8
 #define PXP2_REG_PSWRQ_BW_L6					 0x1202c4
 #define PXP2_REG_PSWRQ_BW_L7					 0x1202c8
@@ -2189,11 +2018,8 @@
 #define PXP2_REG_PSWRQ_BW_UB1					 0x120238
 #define PXP2_REG_PSWRQ_BW_UB10					 0x12025c
 #define PXP2_REG_PSWRQ_BW_UB11					 0x120260
-#define PXP2_REG_PSWRQ_BW_UB10					 0x12025c
-#define PXP2_REG_PSWRQ_BW_UB11					 0x120260
 #define PXP2_REG_PSWRQ_BW_UB2					 0x12023c
 #define PXP2_REG_PSWRQ_BW_UB28					 0x1202a0
-#define PXP2_REG_PSWRQ_BW_UB28					 0x1202a0
 #define PXP2_REG_PSWRQ_BW_UB3					 0x120240
 #define PXP2_REG_PSWRQ_BW_UB6					 0x12024c
 #define PXP2_REG_PSWRQ_BW_UB7					 0x120250
@@ -2784,16 +2610,6 @@
 #define QM_REG_QVOQIDX_107					 0x16e4b8
 #define QM_REG_QVOQIDX_108					 0x16e4bc
 #define QM_REG_QVOQIDX_109					 0x16e4c0
-#define QM_REG_QVOQIDX_100					 0x16e49c
-#define QM_REG_QVOQIDX_101					 0x16e4a0
-#define QM_REG_QVOQIDX_102					 0x16e4a4
-#define QM_REG_QVOQIDX_103					 0x16e4a8
-#define QM_REG_QVOQIDX_104					 0x16e4ac
-#define QM_REG_QVOQIDX_105					 0x16e4b0
-#define QM_REG_QVOQIDX_106					 0x16e4b4
-#define QM_REG_QVOQIDX_107					 0x16e4b8
-#define QM_REG_QVOQIDX_108					 0x16e4bc
-#define QM_REG_QVOQIDX_109					 0x16e4c0
 #define QM_REG_QVOQIDX_11					 0x168120
 #define QM_REG_QVOQIDX_110					 0x16e4c4
 #define QM_REG_QVOQIDX_111					 0x16e4c8
@@ -2805,16 +2621,6 @@
 #define QM_REG_QVOQIDX_117					 0x16e4e0
 #define QM_REG_QVOQIDX_118					 0x16e4e4
 #define QM_REG_QVOQIDX_119					 0x16e4e8
-#define QM_REG_QVOQIDX_110					 0x16e4c4
-#define QM_REG_QVOQIDX_111					 0x16e4c8
-#define QM_REG_QVOQIDX_112					 0x16e4cc
-#define QM_REG_QVOQIDX_113					 0x16e4d0
-#define QM_REG_QVOQIDX_114					 0x16e4d4
-#define QM_REG_QVOQIDX_115					 0x16e4d8
-#define QM_REG_QVOQIDX_116					 0x16e4dc
-#define QM_REG_QVOQIDX_117					 0x16e4e0
-#define QM_REG_QVOQIDX_118					 0x16e4e4
-#define QM_REG_QVOQIDX_119					 0x16e4e8
 #define QM_REG_QVOQIDX_12					 0x168124
 #define QM_REG_QVOQIDX_120					 0x16e4ec
 #define QM_REG_QVOQIDX_121					 0x16e4f0
@@ -2824,14 +2630,6 @@
 #define QM_REG_QVOQIDX_125					 0x16e500
 #define QM_REG_QVOQIDX_126					 0x16e504
 #define QM_REG_QVOQIDX_127					 0x16e508
-#define QM_REG_QVOQIDX_120					 0x16e4ec
-#define QM_REG_QVOQIDX_121					 0x16e4f0
-#define QM_REG_QVOQIDX_122					 0x16e4f4
-#define QM_REG_QVOQIDX_123					 0x16e4f8
-#define QM_REG_QVOQIDX_124					 0x16e4fc
-#define QM_REG_QVOQIDX_125					 0x16e500
-#define QM_REG_QVOQIDX_126					 0x16e504
-#define QM_REG_QVOQIDX_127					 0x16e508
 #define QM_REG_QVOQIDX_13					 0x168128
 #define QM_REG_QVOQIDX_14					 0x16812c
 #define QM_REG_QVOQIDX_15					 0x168130
@@ -2877,16 +2675,6 @@
 #define QM_REG_QVOQIDX_57					 0x1681d8
 #define QM_REG_QVOQIDX_58					 0x1681dc
 #define QM_REG_QVOQIDX_59					 0x1681e0
-#define QM_REG_QVOQIDX_50					 0x1681bc
-#define QM_REG_QVOQIDX_51					 0x1681c0
-#define QM_REG_QVOQIDX_52					 0x1681c4
-#define QM_REG_QVOQIDX_53					 0x1681c8
-#define QM_REG_QVOQIDX_54					 0x1681cc
-#define QM_REG_QVOQIDX_55					 0x1681d0
-#define QM_REG_QVOQIDX_56					 0x1681d4
-#define QM_REG_QVOQIDX_57					 0x1681d8
-#define QM_REG_QVOQIDX_58					 0x1681dc
-#define QM_REG_QVOQIDX_59					 0x1681e0
 #define QM_REG_QVOQIDX_6					 0x16810c
 #define QM_REG_QVOQIDX_60					 0x1681e4
 #define QM_REG_QVOQIDX_61					 0x1681e8
@@ -2894,16 +2682,6 @@
 #define QM_REG_QVOQIDX_63					 0x1681f0
 #define QM_REG_QVOQIDX_64					 0x16e40c
 #define QM_REG_QVOQIDX_65					 0x16e410
-#define QM_REG_QVOQIDX_66					 0x16e414
-#define QM_REG_QVOQIDX_67					 0x16e418
-#define QM_REG_QVOQIDX_68					 0x16e41c
-#define QM_REG_QVOQIDX_69					 0x16e420
-#define QM_REG_QVOQIDX_60					 0x1681e4
-#define QM_REG_QVOQIDX_61					 0x1681e8
-#define QM_REG_QVOQIDX_62					 0x1681ec
-#define QM_REG_QVOQIDX_63					 0x1681f0
-#define QM_REG_QVOQIDX_64					 0x16e40c
-#define QM_REG_QVOQIDX_65					 0x16e410
 #define QM_REG_QVOQIDX_69					 0x16e420
 #define QM_REG_QVOQIDX_7					 0x168110
 #define QM_REG_QVOQIDX_70					 0x16e424
@@ -2916,29 +2694,9 @@
 #define QM_REG_QVOQIDX_77					 0x16e440
 #define QM_REG_QVOQIDX_78					 0x16e444
 #define QM_REG_QVOQIDX_79					 0x16e448
-#define QM_REG_QVOQIDX_70					 0x16e424
-#define QM_REG_QVOQIDX_71					 0x16e428
-#define QM_REG_QVOQIDX_72					 0x16e42c
-#define QM_REG_QVOQIDX_73					 0x16e430
-#define QM_REG_QVOQIDX_74					 0x16e434
-#define QM_REG_QVOQIDX_75					 0x16e438
-#define QM_REG_QVOQIDX_76					 0x16e43c
-#define QM_REG_QVOQIDX_77					 0x16e440
-#define QM_REG_QVOQIDX_78					 0x16e444
-#define QM_REG_QVOQIDX_79					 0x16e448
 #define QM_REG_QVOQIDX_8					 0x168114
 #define QM_REG_QVOQIDX_80					 0x16e44c
 #define QM_REG_QVOQIDX_81					 0x16e450
-#define QM_REG_QVOQIDX_82					 0x16e454
-#define QM_REG_QVOQIDX_83					 0x16e458
-#define QM_REG_QVOQIDX_84					 0x16e45c
-#define QM_REG_QVOQIDX_85					 0x16e460
-#define QM_REG_QVOQIDX_86					 0x16e464
-#define QM_REG_QVOQIDX_87					 0x16e468
-#define QM_REG_QVOQIDX_88					 0x16e46c
-#define QM_REG_QVOQIDX_89					 0x16e470
-#define QM_REG_QVOQIDX_80					 0x16e44c
-#define QM_REG_QVOQIDX_81					 0x16e450
 #define QM_REG_QVOQIDX_85					 0x16e460
 #define QM_REG_QVOQIDX_86					 0x16e464
 #define QM_REG_QVOQIDX_87					 0x16e468
@@ -2955,23 +2713,11 @@
 #define QM_REG_QVOQIDX_97					 0x16e490
 #define QM_REG_QVOQIDX_98					 0x16e494
 #define QM_REG_QVOQIDX_99					 0x16e498
-#define QM_REG_QVOQIDX_90					 0x16e474
-#define QM_REG_QVOQIDX_91					 0x16e478
-#define QM_REG_QVOQIDX_92					 0x16e47c
-#define QM_REG_QVOQIDX_93					 0x16e480
-#define QM_REG_QVOQIDX_94					 0x16e484
-#define QM_REG_QVOQIDX_95					 0x16e488
-#define QM_REG_QVOQIDX_96					 0x16e48c
-#define QM_REG_QVOQIDX_97					 0x16e490
-#define QM_REG_QVOQIDX_98					 0x16e494
-#define QM_REG_QVOQIDX_99					 0x16e498
 /* [RW 1] Initialization bit command */
 #define QM_REG_SOFT_RESET					 0x168428
 /* [RW 8] The credit cost per every task in the QM. A value per each VOQ */
 #define QM_REG_TASKCRDCOST_0					 0x16809c
 #define QM_REG_TASKCRDCOST_1					 0x1680a0
-#define QM_REG_TASKCRDCOST_10					 0x1680c4
-#define QM_REG_TASKCRDCOST_11					 0x1680c8
 #define QM_REG_TASKCRDCOST_2					 0x1680a4
 #define QM_REG_TASKCRDCOST_4					 0x1680ac
 #define QM_REG_TASKCRDCOST_5					 0x1680b0
@@ -2984,24 +2730,18 @@
 /* [R 16] The credit value for each VOQ */
 #define QM_REG_VOQCREDIT_0					 0x1682d0
 #define QM_REG_VOQCREDIT_1					 0x1682d4
-#define QM_REG_VOQCREDIT_10					 0x1682f8
-#define QM_REG_VOQCREDIT_11					 0x1682fc
 #define QM_REG_VOQCREDIT_4					 0x1682e0
 /* [RW 16] The credit value that if above the QM is considered almost full */
 #define QM_REG_VOQCREDITAFULLTHR				 0x168090
 /* [RW 16] The init and maximum credit for each VoQ */
 #define QM_REG_VOQINITCREDIT_0					 0x168060
 #define QM_REG_VOQINITCREDIT_1					 0x168064
-#define QM_REG_VOQINITCREDIT_10 				 0x168088
-#define QM_REG_VOQINITCREDIT_11 				 0x16808c
 #define QM_REG_VOQINITCREDIT_2					 0x168068
 #define QM_REG_VOQINITCREDIT_4					 0x168070
 #define QM_REG_VOQINITCREDIT_5					 0x168074
 /* [RW 1] The port of which VOQ belongs */
 #define QM_REG_VOQPORT_0					 0x1682a0
 #define QM_REG_VOQPORT_1					 0x1682a4
-#define QM_REG_VOQPORT_10					 0x1682c8
-#define QM_REG_VOQPORT_11					 0x1682cc
 #define QM_REG_VOQPORT_2					 0x1682a8
 /* [RW 32] The physical queue number associated with each VOQ; queues 31-0 */
 #define QM_REG_VOQQMASK_0_LSB					 0x168240
@@ -3099,36 +2839,6 @@
 #define QM_REG_WRRWEIGHTS_0					 0x16880c
 #define QM_REG_WRRWEIGHTS_1					 0x168810
 #define QM_REG_WRRWEIGHTS_10					 0x168814
-#define QM_REG_WRRWEIGHTS_10_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_11					 0x168818
-#define QM_REG_WRRWEIGHTS_11_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_12					 0x16881c
-#define QM_REG_WRRWEIGHTS_12_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_13					 0x168820
-#define QM_REG_WRRWEIGHTS_13_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_14					 0x168824
-#define QM_REG_WRRWEIGHTS_14_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_15					 0x168828
-#define QM_REG_WRRWEIGHTS_15_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_16					 0x16e000
-#define QM_REG_WRRWEIGHTS_16_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_17					 0x16e004
-#define QM_REG_WRRWEIGHTS_17_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_18					 0x16e008
-#define QM_REG_WRRWEIGHTS_18_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_19					 0x16e00c
-#define QM_REG_WRRWEIGHTS_19_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_10					 0x168814
 #define QM_REG_WRRWEIGHTS_11					 0x168818
 #define QM_REG_WRRWEIGHTS_12					 0x16881c
 #define QM_REG_WRRWEIGHTS_13					 0x168820
@@ -3140,36 +2850,6 @@
 #define QM_REG_WRRWEIGHTS_19					 0x16e00c
 #define QM_REG_WRRWEIGHTS_2					 0x16882c
 #define QM_REG_WRRWEIGHTS_20					 0x16e010
-#define QM_REG_WRRWEIGHTS_20_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_21					 0x16e014
-#define QM_REG_WRRWEIGHTS_21_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_22					 0x16e018
-#define QM_REG_WRRWEIGHTS_22_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_23					 0x16e01c
-#define QM_REG_WRRWEIGHTS_23_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_24					 0x16e020
-#define QM_REG_WRRWEIGHTS_24_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_25					 0x16e024
-#define QM_REG_WRRWEIGHTS_25_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_26					 0x16e028
-#define QM_REG_WRRWEIGHTS_26_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_27					 0x16e02c
-#define QM_REG_WRRWEIGHTS_27_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_28					 0x16e030
-#define QM_REG_WRRWEIGHTS_28_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_29					 0x16e034
-#define QM_REG_WRRWEIGHTS_29_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_20					 0x16e010
 #define QM_REG_WRRWEIGHTS_21					 0x16e014
 #define QM_REG_WRRWEIGHTS_22					 0x16e018
 #define QM_REG_WRRWEIGHTS_23					 0x16e01c
@@ -3181,12 +2861,6 @@
 #define QM_REG_WRRWEIGHTS_29					 0x16e034
 #define QM_REG_WRRWEIGHTS_3					 0x168830
 #define QM_REG_WRRWEIGHTS_30					 0x16e038
-#define QM_REG_WRRWEIGHTS_30_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_31					 0x16e03c
-#define QM_REG_WRRWEIGHTS_31_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_30					 0x16e038
 #define QM_REG_WRRWEIGHTS_31					 0x16e03c
 #define QM_REG_WRRWEIGHTS_4					 0x168834
 #define QM_REG_WRRWEIGHTS_5					 0x168838
@@ -3196,362 +2870,6 @@
 #define QM_REG_WRRWEIGHTS_9					 0x168848
 /* [R 6] Keep the fill level of the fifo from write client 1 */
 #define QM_REG_XQM_WRC_FIFOLVL					 0x168000
-#define BRB1_BRB1_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
-#define BRB1_BRB1_INT_STS_REG_ADDRESS_ERROR_SIZE		 0
-#define BRB1_BRB1_INT_STS_CLR_REG_ADDRESS_ERROR 		 (0x1<<0)
-#define BRB1_BRB1_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define BRB1_BRB1_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define BRB1_BRB1_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
-#define BRB1_BRB1_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define BRB1_BRB1_INT_MASK_REG_ADDRESS_ERROR_SIZE		 0
-#define CCM_CCM_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
-#define CCM_CCM_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
-#define CCM_CCM_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define CCM_CCM_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define CCM_CCM_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define CCM_CCM_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
-#define CCM_CCM_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define CCM_CCM_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
-#define CDU_CDU_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
-#define CDU_CDU_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
-#define CDU_CDU_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define CDU_CDU_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define CDU_CDU_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define CDU_CDU_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
-#define CDU_CDU_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define CDU_CDU_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
-#define CFC_CFC_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
-#define CFC_CFC_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
-#define CFC_CFC_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define CFC_CFC_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define CFC_CFC_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define CFC_CFC_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
-#define CFC_CFC_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define CFC_CFC_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
-#define CSDM_CSDM_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define CSDM_CSDM_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
-#define CSDM_CSDM_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define CSDM_CSDM_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define CSDM_CSDM_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define CSDM_CSDM_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define CSDM_CSDM_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define CSDM_CSDM_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
-#define CSEM_CSEM_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define CSEM_CSEM_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
-#define CSEM_CSEM_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define CSEM_CSEM_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define CSEM_CSEM_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define CSEM_CSEM_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define CSEM_CSEM_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define CSEM_CSEM_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
-#define DBG_DBG_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
-#define DBG_DBG_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
-#define DBG_DBG_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define DBG_DBG_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define DBG_DBG_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define DBG_DBG_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
-#define DBG_DBG_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define DBG_DBG_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
-#define DMAE_DMAE_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
-#define DMAE_DMAE_INT_STS_REG_ADDRESS_ERROR_SIZE		 0
-#define DMAE_DMAE_INT_STS_CLR_REG_ADDRESS_ERROR 		 (0x1<<0)
-#define DMAE_DMAE_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define DMAE_DMAE_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define DMAE_DMAE_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
-#define DMAE_DMAE_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define DMAE_DMAE_INT_MASK_REG_ADDRESS_ERROR_SIZE		 0
-#define DORQ_DORQ_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
-#define DORQ_DORQ_INT_STS_REG_ADDRESS_ERROR_SIZE		 0
-#define DORQ_DORQ_INT_STS_CLR_REG_ADDRESS_ERROR 		 (0x1<<0)
-#define DORQ_DORQ_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define DORQ_DORQ_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define DORQ_DORQ_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
-#define DORQ_DORQ_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define DORQ_DORQ_INT_MASK_REG_ADDRESS_ERROR_SIZE		 0
-#define HC_HC_INT_STS_REG_ADDRESS_ERROR 			 (0x1<<0)
-#define HC_HC_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
-#define HC_HC_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define HC_HC_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define HC_HC_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define HC_HC_INT_STS_WR_REG_ADDRESS_ERROR_SIZE 		 0
-#define HC_HC_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define HC_HC_INT_MASK_REG_ADDRESS_ERROR_SIZE			 0
-#define MISC_MISC_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
-#define MISC_MISC_INT_STS_REG_ADDRESS_ERROR_SIZE		 0
-#define MISC_MISC_INT_STS_CLR_REG_ADDRESS_ERROR 		 (0x1<<0)
-#define MISC_MISC_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define MISC_MISC_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define MISC_MISC_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
-#define MISC_MISC_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define MISC_MISC_INT_MASK_REG_ADDRESS_ERROR_SIZE		 0
-#define NIG_NIG_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define NIG_NIG_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
-#define NIG_NIG_INT_STS_CLR_0_REG_ADDRESS_ERROR 		 (0x1<<0)
-#define NIG_NIG_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define NIG_NIG_INT_STS_WR_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define NIG_NIG_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define NIG_NIG_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define NIG_NIG_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
-#define PBF_PBF_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
-#define PBF_PBF_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
-#define PBF_PBF_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define PBF_PBF_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define PBF_PBF_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define PBF_PBF_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
-#define PBF_PBF_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define PBF_PBF_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
-#define PB_PB_INT_STS_REG_ADDRESS_ERROR 			 (0x1<<0)
-#define PB_PB_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
-#define PB_PB_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define PB_PB_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define PB_PB_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define PB_PB_INT_STS_WR_REG_ADDRESS_ERROR_SIZE 		 0
-#define PB_PB_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define PB_PB_INT_MASK_REG_ADDRESS_ERROR_SIZE			 0
-#define PRS_PRS_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
-#define PRS_PRS_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
-#define PRS_PRS_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define PRS_PRS_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define PRS_PRS_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define PRS_PRS_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
-#define PRS_PRS_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define PRS_PRS_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
-#define PXP2_PXP2_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define PXP2_PXP2_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
-#define PXP2_PXP2_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define PXP2_PXP2_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define PXP2_PXP2_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define PXP2_PXP2_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define PXP2_PXP2_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define PXP2_PXP2_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
-#define PXP_PXP_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define PXP_PXP_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
-#define PXP_PXP_INT_STS_CLR_0_REG_ADDRESS_ERROR 		 (0x1<<0)
-#define PXP_PXP_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define PXP_PXP_INT_STS_WR_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define PXP_PXP_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define PXP_PXP_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define PXP_PXP_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
-#define QM_QM_INT_STS_REG_ADDRESS_ERROR 			 (0x1<<0)
-#define QM_QM_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
-#define QM_QM_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define QM_QM_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define QM_QM_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define QM_QM_INT_STS_WR_REG_ADDRESS_ERROR_SIZE 		 0
-#define QM_QM_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define QM_QM_INT_MASK_REG_ADDRESS_ERROR_SIZE			 0
-#define SEM_FAST_SEM_FAST_INT_STS_REG_ADDRESS_ERROR		 (0x1<<0)
-#define SEM_FAST_SEM_FAST_INT_STS_REG_ADDRESS_ERROR_SIZE	 0
-#define SEM_FAST_SEM_FAST_INT_STS_CLR_REG_ADDRESS_ERROR 	 (0x1<<0)
-#define SEM_FAST_SEM_FAST_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE	 0
-#define SEM_FAST_SEM_FAST_INT_STS_WR_REG_ADDRESS_ERROR		 (0x1<<0)
-#define SEM_FAST_SEM_FAST_INT_STS_WR_REG_ADDRESS_ERROR_SIZE	 0
-#define SEM_FAST_SEM_FAST_INT_MASK_REG_ADDRESS_ERROR		 (0x1<<0)
-#define SEM_FAST_SEM_FAST_INT_MASK_REG_ADDRESS_ERROR_SIZE	 0
-#define SRC_SRC_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
-#define SRC_SRC_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
-#define SRC_SRC_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define SRC_SRC_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define SRC_SRC_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define SRC_SRC_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
-#define SRC_SRC_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define SRC_SRC_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
-#define TCM_TCM_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
-#define TCM_TCM_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
-#define TCM_TCM_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define TCM_TCM_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define TCM_TCM_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define TCM_TCM_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
-#define TCM_TCM_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define TCM_TCM_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
-#define TM_TM_INT_STS_REG_ADDRESS_ERROR 			 (0x1<<0)
-#define TM_TM_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
-#define TM_TM_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define TM_TM_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define TM_TM_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define TM_TM_INT_STS_WR_REG_ADDRESS_ERROR_SIZE 		 0
-#define TM_TM_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define TM_TM_INT_MASK_REG_ADDRESS_ERROR_SIZE			 0
-#define TSDM_TSDM_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define TSDM_TSDM_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
-#define TSDM_TSDM_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define TSDM_TSDM_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define TSDM_TSDM_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define TSDM_TSDM_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define TSDM_TSDM_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define TSDM_TSDM_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
-#define TSEM_TSEM_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define TSEM_TSEM_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
-#define TSEM_TSEM_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define TSEM_TSEM_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define TSEM_TSEM_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define TSEM_TSEM_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define TSEM_TSEM_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define TSEM_TSEM_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
-#define UCM_UCM_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
-#define UCM_UCM_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
-#define UCM_UCM_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define UCM_UCM_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define UCM_UCM_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define UCM_UCM_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
-#define UCM_UCM_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define UCM_UCM_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
-#define USDM_USDM_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define USDM_USDM_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
-#define USDM_USDM_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define USDM_USDM_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define USDM_USDM_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define USDM_USDM_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define USDM_USDM_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define USDM_USDM_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
-#define USEM_USEM_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define USEM_USEM_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
-#define USEM_USEM_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define USEM_USEM_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define USEM_USEM_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define USEM_USEM_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define USEM_USEM_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define USEM_USEM_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
-#define XCM_XCM_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
-#define XCM_XCM_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
-#define XCM_XCM_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define XCM_XCM_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
-#define XCM_XCM_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
-#define XCM_XCM_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
-#define XCM_XCM_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
-#define XCM_XCM_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
-#define XSDM_XSDM_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define XSDM_XSDM_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
-#define XSDM_XSDM_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define XSDM_XSDM_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define XSDM_XSDM_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define XSDM_XSDM_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define XSDM_XSDM_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define XSDM_XSDM_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
-#define XSEM_XSEM_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define XSEM_XSEM_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
-#define XSEM_XSEM_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define XSEM_XSEM_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define XSEM_XSEM_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
-#define XSEM_XSEM_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
-#define XSEM_XSEM_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
-#define XSEM_XSEM_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
-#define CFC_DEBUG1_REG_WRITE_AC 				 (0x1<<4)
-#define CFC_DEBUG1_REG_WRITE_AC_SIZE				 4
-/* [R 1] debug only: This bit indicates whether indicates that external
-   buffer was wrapped (oldest data was thrown); Relevant only when
-   ~dbg_registers_debug_target=2 (PCI) & ~dbg_registers_full_mode=1 (wrap); */
-#define DBG_REG_WRAP_ON_EXT_BUFFER				 0xc124
-#define DBG_REG_WRAP_ON_EXT_BUFFER_SIZE 			 1
-/* [R 1] debug only: This bit indicates whether the internal buffer was
-   wrapped (oldest data was thrown) Relevant only when
-   ~dbg_registers_debug_target=0 (internal buffer) */
-#define DBG_REG_WRAP_ON_INT_BUFFER				 0xc128
-#define DBG_REG_WRAP_ON_INT_BUFFER_SIZE 			 1
-#define QM_QM_PRTY_STS_REG_WRBUFF				 (0x1<<8)
-#define QM_QM_PRTY_STS_REG_WRBUFF_SIZE				 8
-#define QM_QM_PRTY_STS_CLR_REG_WRBUFF				 (0x1<<8)
-#define QM_QM_PRTY_STS_CLR_REG_WRBUFF_SIZE			 8
-#define QM_QM_PRTY_STS_WR_REG_WRBUFF				 (0x1<<8)
-#define QM_QM_PRTY_STS_WR_REG_WRBUFF_SIZE			 8
-#define QM_QM_PRTY_MASK_REG_WRBUFF				 (0x1<<8)
-#define QM_QM_PRTY_MASK_REG_WRBUFF_SIZE 			 8
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_0					 0x16880c
-#define QM_REG_WRRWEIGHTS_0_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_1					 0x168810
-#define QM_REG_WRRWEIGHTS_1_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_10					 0x168814
-#define QM_REG_WRRWEIGHTS_10_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_11					 0x168818
-#define QM_REG_WRRWEIGHTS_11_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_12					 0x16881c
-#define QM_REG_WRRWEIGHTS_12_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_13					 0x168820
-#define QM_REG_WRRWEIGHTS_13_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_14					 0x168824
-#define QM_REG_WRRWEIGHTS_14_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_15					 0x168828
-#define QM_REG_WRRWEIGHTS_15_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_2					 0x16882c
-#define QM_REG_WRRWEIGHTS_2_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_3					 0x168830
-#define QM_REG_WRRWEIGHTS_3_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_4					 0x168834
-#define QM_REG_WRRWEIGHTS_4_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_5					 0x168838
-#define QM_REG_WRRWEIGHTS_5_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_6					 0x16883c
-#define QM_REG_WRRWEIGHTS_6_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_7					 0x168840
-#define QM_REG_WRRWEIGHTS_7_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_8					 0x168844
-#define QM_REG_WRRWEIGHTS_8_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_9					 0x168848
-#define QM_REG_WRRWEIGHTS_9_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_16					 0x16e000
-#define QM_REG_WRRWEIGHTS_16_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_17					 0x16e004
-#define QM_REG_WRRWEIGHTS_17_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_18					 0x16e008
-#define QM_REG_WRRWEIGHTS_18_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_19					 0x16e00c
-#define QM_REG_WRRWEIGHTS_19_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_20					 0x16e010
-#define QM_REG_WRRWEIGHTS_20_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_21					 0x16e014
-#define QM_REG_WRRWEIGHTS_21_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_22					 0x16e018
-#define QM_REG_WRRWEIGHTS_22_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_23					 0x16e01c
-#define QM_REG_WRRWEIGHTS_23_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_24					 0x16e020
-#define QM_REG_WRRWEIGHTS_24_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_25					 0x16e024
-#define QM_REG_WRRWEIGHTS_25_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_26					 0x16e028
-#define QM_REG_WRRWEIGHTS_26_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_27					 0x16e02c
-#define QM_REG_WRRWEIGHTS_27_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_28					 0x16e030
-#define QM_REG_WRRWEIGHTS_28_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_29					 0x16e034
-#define QM_REG_WRRWEIGHTS_29_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_30					 0x16e038
-#define QM_REG_WRRWEIGHTS_30_SIZE				 1
-/* [RW 32] Wrr weights */
-#define QM_REG_WRRWEIGHTS_31					 0x16e03c
-#define QM_REG_WRRWEIGHTS_31_SIZE				 1
 #define SRC_REG_COUNTFREE0					 0x40500
 /* [RW 1] If clr the searcher is compatible to E1 A0 - support only two
    ports. If set the searcher support 8 functions. */
@@ -3651,12 +2969,6 @@
    type (one of 16). */
 #define TCM_REG_N_SM_CTX_LD_0					 0x50050
 #define TCM_REG_N_SM_CTX_LD_1					 0x50054
-#define TCM_REG_N_SM_CTX_LD_10					 0x50078
-#define TCM_REG_N_SM_CTX_LD_11					 0x5007c
-#define TCM_REG_N_SM_CTX_LD_12					 0x50080
-#define TCM_REG_N_SM_CTX_LD_13					 0x50084
-#define TCM_REG_N_SM_CTX_LD_14					 0x50088
-#define TCM_REG_N_SM_CTX_LD_15					 0x5008c
 #define TCM_REG_N_SM_CTX_LD_2					 0x50058
 #define TCM_REG_N_SM_CTX_LD_3					 0x5005c
 #define TCM_REG_N_SM_CTX_LD_4					 0x50060
@@ -3863,8 +3175,6 @@
 #define TM_REG_LIN_SETCLR_FIFO_ALFULL_THR			 0x164070
 /* [RW 2] Load value for pci arbiter credit cnt. */
 #define TM_REG_PCIARB_CRDCNT_VAL				 0x164260
-/* [RW 1] Timer software reset - active high. */
-#define TM_REG_TIMER_SOFT_RST					 0x164004
 /* [RW 20] The amount of hardware cycles for each timer tick. */
 #define TM_REG_TIMER_TICK_SIZE					 0x16401c
 /* [RW 8] Timers Context region. */
@@ -3876,44 +3186,12 @@
 /* [RW 8] The event id for aggregated interrupt 0 */
 #define TSDM_REG_AGG_INT_EVENT_0				 0x42038
 #define TSDM_REG_AGG_INT_EVENT_1				 0x4203c
-#define TSDM_REG_AGG_INT_EVENT_10				 0x42060
-#define TSDM_REG_AGG_INT_EVENT_11				 0x42064
-#define TSDM_REG_AGG_INT_EVENT_12				 0x42068
-#define TSDM_REG_AGG_INT_EVENT_13				 0x4206c
-#define TSDM_REG_AGG_INT_EVENT_14				 0x42070
-#define TSDM_REG_AGG_INT_EVENT_15				 0x42074
-#define TSDM_REG_AGG_INT_EVENT_16				 0x42078
-#define TSDM_REG_AGG_INT_EVENT_17				 0x4207c
-#define TSDM_REG_AGG_INT_EVENT_18				 0x42080
-#define TSDM_REG_AGG_INT_EVENT_19				 0x42084
 #define TSDM_REG_AGG_INT_EVENT_2				 0x42040
-#define TSDM_REG_AGG_INT_EVENT_20				 0x42088
-#define TSDM_REG_AGG_INT_EVENT_21				 0x4208c
-#define TSDM_REG_AGG_INT_EVENT_22				 0x42090
-#define TSDM_REG_AGG_INT_EVENT_23				 0x42094
-#define TSDM_REG_AGG_INT_EVENT_24				 0x42098
-#define TSDM_REG_AGG_INT_EVENT_25				 0x4209c
-#define TSDM_REG_AGG_INT_EVENT_26				 0x420a0
-#define TSDM_REG_AGG_INT_EVENT_27				 0x420a4
-#define TSDM_REG_AGG_INT_EVENT_28				 0x420a8
-#define TSDM_REG_AGG_INT_EVENT_29				 0x420ac
 #define TSDM_REG_AGG_INT_EVENT_3				 0x42044
-#define TSDM_REG_AGG_INT_EVENT_30				 0x420b0
-#define TSDM_REG_AGG_INT_EVENT_31				 0x420b4
 #define TSDM_REG_AGG_INT_EVENT_4				 0x42048
 /* [RW 1] The T bit for aggregated interrupt 0 */
 #define TSDM_REG_AGG_INT_T_0					 0x420b8
 #define TSDM_REG_AGG_INT_T_1					 0x420bc
-#define TSDM_REG_AGG_INT_T_10					 0x420e0
-#define TSDM_REG_AGG_INT_T_11					 0x420e4
-#define TSDM_REG_AGG_INT_T_12					 0x420e8
-#define TSDM_REG_AGG_INT_T_13					 0x420ec
-#define TSDM_REG_AGG_INT_T_14					 0x420f0
-#define TSDM_REG_AGG_INT_T_15					 0x420f4
-#define TSDM_REG_AGG_INT_T_16					 0x420f8
-#define TSDM_REG_AGG_INT_T_17					 0x420fc
-#define TSDM_REG_AGG_INT_T_18					 0x42100
-#define TSDM_REG_AGG_INT_T_19					 0x42104
 /* [RW 13] The start address in the internal RAM for the cfc_rsp lcid */
 #define TSDM_REG_CFC_RSP_START_ADDR				 0x42008
 /* [RW 16] The maximum value of the competion counter #0 */
@@ -4198,12 +3476,6 @@
    connection type (one of 16). */
 #define UCM_REG_N_SM_CTX_LD_0					 0xe0054
 #define UCM_REG_N_SM_CTX_LD_1					 0xe0058
-#define UCM_REG_N_SM_CTX_LD_10					 0xe007c
-#define UCM_REG_N_SM_CTX_LD_11					 0xe0080
-#define UCM_REG_N_SM_CTX_LD_12					 0xe0084
-#define UCM_REG_N_SM_CTX_LD_13					 0xe0088
-#define UCM_REG_N_SM_CTX_LD_14					 0xe008c
-#define UCM_REG_N_SM_CTX_LD_15					 0xe0090
 #define UCM_REG_N_SM_CTX_LD_2					 0xe005c
 #define UCM_REG_N_SM_CTX_LD_3					 0xe0060
 #define UCM_REG_N_SM_CTX_LD_4					 0xe0064
@@ -4353,30 +3625,7 @@
 /* [RW 8] The event id for aggregated interrupt 0 */
 #define USDM_REG_AGG_INT_EVENT_0				 0xc4038
 #define USDM_REG_AGG_INT_EVENT_1				 0xc403c
-#define USDM_REG_AGG_INT_EVENT_10				 0xc4060
-#define USDM_REG_AGG_INT_EVENT_11				 0xc4064
-#define USDM_REG_AGG_INT_EVENT_12				 0xc4068
-#define USDM_REG_AGG_INT_EVENT_13				 0xc406c
-#define USDM_REG_AGG_INT_EVENT_14				 0xc4070
-#define USDM_REG_AGG_INT_EVENT_15				 0xc4074
-#define USDM_REG_AGG_INT_EVENT_16				 0xc4078
-#define USDM_REG_AGG_INT_EVENT_17				 0xc407c
-#define USDM_REG_AGG_INT_EVENT_18				 0xc4080
-#define USDM_REG_AGG_INT_EVENT_19				 0xc4084
 #define USDM_REG_AGG_INT_EVENT_2				 0xc4040
-#define USDM_REG_AGG_INT_EVENT_20				 0xc4088
-#define USDM_REG_AGG_INT_EVENT_21				 0xc408c
-#define USDM_REG_AGG_INT_EVENT_22				 0xc4090
-#define USDM_REG_AGG_INT_EVENT_23				 0xc4094
-#define USDM_REG_AGG_INT_EVENT_24				 0xc4098
-#define USDM_REG_AGG_INT_EVENT_25				 0xc409c
-#define USDM_REG_AGG_INT_EVENT_26				 0xc40a0
-#define USDM_REG_AGG_INT_EVENT_27				 0xc40a4
-#define USDM_REG_AGG_INT_EVENT_28				 0xc40a8
-#define USDM_REG_AGG_INT_EVENT_29				 0xc40ac
-#define USDM_REG_AGG_INT_EVENT_3				 0xc4044
-#define USDM_REG_AGG_INT_EVENT_30				 0xc40b0
-#define USDM_REG_AGG_INT_EVENT_31				 0xc40b4
 #define USDM_REG_AGG_INT_EVENT_4				 0xc4048
 #define USDM_REG_AGG_INT_EVENT_5				 0xc404c
 #define USDM_REG_AGG_INT_EVENT_6				 0xc4050
@@ -4384,16 +3633,6 @@
    or auto-mask-mode (1) */
 #define USDM_REG_AGG_INT_MODE_0 				 0xc41b8
 #define USDM_REG_AGG_INT_MODE_1 				 0xc41bc
-#define USDM_REG_AGG_INT_MODE_10				 0xc41e0
-#define USDM_REG_AGG_INT_MODE_11				 0xc41e4
-#define USDM_REG_AGG_INT_MODE_12				 0xc41e8
-#define USDM_REG_AGG_INT_MODE_13				 0xc41ec
-#define USDM_REG_AGG_INT_MODE_14				 0xc41f0
-#define USDM_REG_AGG_INT_MODE_15				 0xc41f4
-#define USDM_REG_AGG_INT_MODE_16				 0xc41f8
-#define USDM_REG_AGG_INT_MODE_17				 0xc41fc
-#define USDM_REG_AGG_INT_MODE_18				 0xc4200
-#define USDM_REG_AGG_INT_MODE_19				 0xc4204
 #define USDM_REG_AGG_INT_MODE_4 				 0xc41c8
 #define USDM_REG_AGG_INT_MODE_5 				 0xc41cc
 #define USDM_REG_AGG_INT_MODE_6 				 0xc41d0
@@ -4703,10 +3942,6 @@
 /* [RC 1] Set at message length mismatch (relative to last indication) at
    the nig1 interface. */
 #define XCM_REG_NIG1_LENGTH_MIS 				 0x2023c
-/* [RW 3] The weight of the input nig1 in the WRR mechanism. 0 stands for
-   weight 8 (the most prioritised); 1 stands for weight 1(least
-   prioritised); 2 stands for weight 2; tc. */
-#define XCM_REG_NIG1_WEIGHT					 0x200d8
 /* [RW 5] The number of double REG-pairs; loaded from the STORM context and
    sent to STORM; for a specific connection type. The double REG-pairs are
    used in order to align to STORM context row size of 128 bits. The offset
@@ -4714,12 +3949,6 @@
    connection type (one of 16). */
 #define XCM_REG_N_SM_CTX_LD_0					 0x20060
 #define XCM_REG_N_SM_CTX_LD_1					 0x20064
-#define XCM_REG_N_SM_CTX_LD_10					 0x20088
-#define XCM_REG_N_SM_CTX_LD_11					 0x2008c
-#define XCM_REG_N_SM_CTX_LD_12					 0x20090
-#define XCM_REG_N_SM_CTX_LD_13					 0x20094
-#define XCM_REG_N_SM_CTX_LD_14					 0x20098
-#define XCM_REG_N_SM_CTX_LD_15					 0x2009c
 #define XCM_REG_N_SM_CTX_LD_2					 0x20068
 #define XCM_REG_N_SM_CTX_LD_3					 0x2006c
 #define XCM_REG_N_SM_CTX_LD_4					 0x20070
@@ -4896,30 +4125,8 @@
 #define XSDM_REG_AGG_INT_EVENT_12				 0x166068
 #define XSDM_REG_AGG_INT_EVENT_13				 0x16606c
 #define XSDM_REG_AGG_INT_EVENT_14				 0x166070
-#define XSDM_REG_AGG_INT_EVENT_15				 0x166074
-#define XSDM_REG_AGG_INT_EVENT_16				 0x166078
-#define XSDM_REG_AGG_INT_EVENT_17				 0x16607c
-#define XSDM_REG_AGG_INT_EVENT_18				 0x166080
-#define XSDM_REG_AGG_INT_EVENT_19				 0x166084
-#define XSDM_REG_AGG_INT_EVENT_10				 0x166060
-#define XSDM_REG_AGG_INT_EVENT_11				 0x166064
-#define XSDM_REG_AGG_INT_EVENT_12				 0x166068
-#define XSDM_REG_AGG_INT_EVENT_13				 0x16606c
-#define XSDM_REG_AGG_INT_EVENT_14				 0x166070
 #define XSDM_REG_AGG_INT_EVENT_2				 0x166040
-#define XSDM_REG_AGG_INT_EVENT_20				 0x166088
-#define XSDM_REG_AGG_INT_EVENT_21				 0x16608c
-#define XSDM_REG_AGG_INT_EVENT_22				 0x166090
-#define XSDM_REG_AGG_INT_EVENT_23				 0x166094
-#define XSDM_REG_AGG_INT_EVENT_24				 0x166098
-#define XSDM_REG_AGG_INT_EVENT_25				 0x16609c
-#define XSDM_REG_AGG_INT_EVENT_26				 0x1660a0
-#define XSDM_REG_AGG_INT_EVENT_27				 0x1660a4
-#define XSDM_REG_AGG_INT_EVENT_28				 0x1660a8
-#define XSDM_REG_AGG_INT_EVENT_29				 0x1660ac
 #define XSDM_REG_AGG_INT_EVENT_3				 0x166044
-#define XSDM_REG_AGG_INT_EVENT_30				 0x1660b0
-#define XSDM_REG_AGG_INT_EVENT_31				 0x1660b4
 #define XSDM_REG_AGG_INT_EVENT_4				 0x166048
 #define XSDM_REG_AGG_INT_EVENT_5				 0x16604c
 #define XSDM_REG_AGG_INT_EVENT_6				 0x166050
@@ -4930,16 +4137,6 @@
    or auto-mask-mode (1) */
 #define XSDM_REG_AGG_INT_MODE_0 				 0x1661b8
 #define XSDM_REG_AGG_INT_MODE_1 				 0x1661bc
-#define XSDM_REG_AGG_INT_MODE_10				 0x1661e0
-#define XSDM_REG_AGG_INT_MODE_11				 0x1661e4
-#define XSDM_REG_AGG_INT_MODE_12				 0x1661e8
-#define XSDM_REG_AGG_INT_MODE_13				 0x1661ec
-#define XSDM_REG_AGG_INT_MODE_14				 0x1661f0
-#define XSDM_REG_AGG_INT_MODE_15				 0x1661f4
-#define XSDM_REG_AGG_INT_MODE_16				 0x1661f8
-#define XSDM_REG_AGG_INT_MODE_17				 0x1661fc
-#define XSDM_REG_AGG_INT_MODE_18				 0x166200
-#define XSDM_REG_AGG_INT_MODE_19				 0x166204
 /* [RW 13] The start address in the internal RAM for the cfc_rsp lcid */
 #define XSDM_REG_CFC_RSP_START_ADDR				 0x166008
 /* [RW 16] The maximum value of the competion counter #0 */
@@ -5147,10 +4344,6 @@
 #define MCPR_NVM_COMMAND_FIRST					 (1L<<7)
 #define MCPR_NVM_COMMAND_LAST					 (1L<<8)
 #define MCPR_NVM_COMMAND_WR					 (1L<<5)
-#define MCPR_NVM_COMMAND_WREN					 (1L<<16)
-#define MCPR_NVM_COMMAND_WREN_BITSHIFT				 16
-#define MCPR_NVM_COMMAND_WRDI					 (1L<<17)
-#define MCPR_NVM_COMMAND_WRDI_BITSHIFT				 17
 #define MCPR_NVM_SW_ARB_ARB_ARB1				 (1L<<9)
 #define MCPR_NVM_SW_ARB_ARB_REQ_CLR1				 (1L<<5)
 #define MCPR_NVM_SW_ARB_ARB_REQ_SET1				 (1L<<1)
@@ -5251,10 +4444,6 @@
 #define MISC_REGISTERS_SPIO_7					 7
 #define MISC_REGISTERS_SPIO_CLR_POS				 16
 #define MISC_REGISTERS_SPIO_FLOAT				 (0xffL<<24)
-#define GRC_MISC_REGISTERS_SPIO_FLOAT7				 0x80000000
-#define GRC_MISC_REGISTERS_SPIO_FLOAT6				 0x40000000
-#define GRC_MISC_REGISTERS_SPIO_FLOAT5				 0x20000000
-#define GRC_MISC_REGISTERS_SPIO_FLOAT4				 0x10000000
 #define MISC_REGISTERS_SPIO_FLOAT_POS				 24
 #define MISC_REGISTERS_SPIO_INPUT_HI_Z				 2
 #define MISC_REGISTERS_SPIO_INT_OLD_SET_POS			 16
-- 
1.5.4.3




