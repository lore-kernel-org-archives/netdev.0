From: Nicolas Kaiser <nikai@nikai.net>
Subject: [PATCH] drivers/net: remove duplicated defines
Date: Thu, 8 Nov 2007 14:36:25 +0100
Message-ID: <20071108143625.17ae9c13@lucky.kitzblitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ensim03.bon.m2soft.com ([195.38.20.12]:55902 "EHLO
	ensim03.bon.m2soft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754198AbXKHNwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 08:52:15 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove duplicated defines.

Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
---

 drivers/net/cxgb3/regs.h                  |   37 ------------------------------
 drivers/net/e1000e/defines.h              |   23 +-----------------
 drivers/net/ehea/ehea_phyp.c              |    7 -----
 drivers/net/hp100.c                       |    6 ----
 drivers/net/niu.h                         |    1 
 drivers/net/tokenring/smctr.h             |    6 ----
 drivers/net/tulip/de4x5.c                 |    6 ----
 drivers/net/usb/rtl8150.c                 |   26 ---------------------
 drivers/net/wan/dscc4.c                   |    1 
 drivers/net/wireless/atmel.c              |    1 
 drivers/net/wireless/iwlwifi/iwl-eeprom.h |    3 --
 drivers/net/wireless/libertas/host.h      |    1 
 12 files changed, 3 insertions(+), 115 deletions(-)

diff -ur a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
--- a/drivers/net/cxgb3/regs.h	2007-11-07 11:26:12.000000000 +0100
+++ b/drivers/net/cxgb3/regs.h	2007-11-07 21:55:15.000000000 +0100
@@ -555,10 +555,6 @@
 #define V_BUSY(x) ((x) << S_BUSY)
 #define F_BUSY    V_BUSY(1U)
 
-#define S_BUSY    31
-#define V_BUSY(x) ((x) << S_BUSY)
-#define F_BUSY    V_BUSY(1U)
-
 #define A_MC7_EXT_MODE1 0x108
 
 #define A_MC7_EXT_MODE2 0x10c
@@ -619,14 +615,6 @@
 
 #define A_MC7_CAL 0x128
 
-#define S_BUSY    31
-#define V_BUSY(x) ((x) << S_BUSY)
-#define F_BUSY    V_BUSY(1U)
-
-#define S_BUSY    31
-#define V_BUSY(x) ((x) << S_BUSY)
-#define F_BUSY    V_BUSY(1U)
-
 #define S_CAL_FAULT    30
 #define V_CAL_FAULT(x) ((x) << S_CAL_FAULT)
 #define F_CAL_FAULT    V_CAL_FAULT(1U)
@@ -685,7 +673,6 @@
 #define V_OP(x) ((x) << S_OP)
 #define F_OP    V_OP(1U)
 
-#define F_OP    V_OP(1U)
 #define A_SF_OP 0x6dc
 
 #define A_MC7_BIST_ADDR_BEG 0x168
@@ -700,8 +687,6 @@
 #define V_CONT(x) ((x) << S_CONT)
 #define F_CONT    V_CONT(1U)
 
-#define F_CONT    V_CONT(1U)
-
 #define A_MC7_INT_ENABLE 0x178
 
 #define S_AE    17
@@ -805,8 +790,6 @@
 #define V_NICMODE(x) ((x) << S_NICMODE)
 #define F_NICMODE    V_NICMODE(1U)
 
-#define F_NICMODE    V_NICMODE(1U)
-
 #define S_IPV6ENABLE    15
 #define V_IPV6ENABLE(x) ((x) << S_IPV6ENABLE)
 #define F_IPV6ENABLE    V_IPV6ENABLE(1U)
@@ -1268,27 +1251,15 @@
 #define A_ULPRX_STAG_ULIMIT 0x530
 
 #define A_ULPRX_RQ_LLIMIT 0x534
-#define A_ULPRX_RQ_LLIMIT 0x534
 
 #define A_ULPRX_RQ_ULIMIT 0x538
-#define A_ULPRX_RQ_ULIMIT 0x538
 
 #define A_ULPRX_PBL_LLIMIT 0x53c
 
 #define A_ULPRX_PBL_ULIMIT 0x540
-#define A_ULPRX_PBL_ULIMIT 0x540
 
 #define A_ULPRX_TDDP_TAGMASK 0x524
 
-#define A_ULPRX_RQ_LLIMIT 0x534
-#define A_ULPRX_RQ_LLIMIT 0x534
-
-#define A_ULPRX_RQ_ULIMIT 0x538
-#define A_ULPRX_RQ_ULIMIT 0x538
-
-#define A_ULPRX_PBL_ULIMIT 0x540
-#define A_ULPRX_PBL_ULIMIT 0x540
-
 #define A_ULPTX_CONFIG 0x580
 
 #define S_CFG_RR_ARB    0
@@ -1615,8 +1586,6 @@
 
 #define A_SF_DATA 0x6d8
 
-#define A_SF_OP 0x6dc
-
 #define S_BYTECNT    1
 #define M_BYTECNT    0x3
 #define V_BYTECNT(x) ((x) << S_BYTECNT)
@@ -1747,8 +1716,6 @@
 #define V_TMMODE(x) ((x) << S_TMMODE)
 #define F_TMMODE    V_TMMODE(1U)
 
-#define F_TMMODE    V_TMMODE(1U)
-
 #define A_MC5_DB_ROUTING_TABLE_INDEX 0x70c
 
 #define A_MC5_DB_FILTER_TABLE 0x710
@@ -2110,8 +2077,6 @@
 #define V_TXACTENABLE(x) ((x) << S_TXACTENABLE)
 #define F_TXACTENABLE    V_TXACTENABLE(1U)
 
-#define A_XGM_SERDES_CTRL0 0x8e0
-
 #define S_RESET3    23
 #define V_RESET3(x) ((x) << S_RESET3)
 #define F_RESET3    V_RESET3(1U)
@@ -2240,8 +2205,6 @@
 #define V_CMULOCK(x) ((x) << S_CMULOCK)
 #define F_CMULOCK    V_CMULOCK(1U)
 
-#define A_XGM_RX_MAX_PKT_SIZE_ERR_CNT 0x9a4
-
 #define A_XGM_TX_SPI4_SOP_EOP_CNT 0x9a8
 
 #define S_TXSPI4SOPCNT    16
diff -ur a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
--- a/drivers/net/e1000e/defines.h	2007-11-07 11:26:13.000000000 +0100
+++ b/drivers/net/e1000e/defines.h	2007-11-07 22:16:15.000000000 +0100
@@ -29,6 +29,8 @@
 #ifndef _E1000_DEFINES_H_
 #define _E1000_DEFINES_H_
 
+/* Transmit Descriptor bit definitions */
+#define E1000_TXD_DTYP_D     0x00100000 /* Data Descriptor */
 #define E1000_TXD_POPTS_IXSM 0x01       /* Insert IP checksum */
 #define E1000_TXD_POPTS_TXSM 0x02       /* Insert TCP/UDP checksum */
 #define E1000_TXD_CMD_EOP    0x01000000 /* End of Packet */
@@ -256,27 +258,6 @@
 #define E1000_LEDCTL_MODE_LED_ON        0xE
 #define E1000_LEDCTL_MODE_LED_OFF       0xF
 
-/* Transmit Descriptor bit definitions */
-#define E1000_TXD_DTYP_D     0x00100000 /* Data Descriptor */
-#define E1000_TXD_POPTS_IXSM 0x01       /* Insert IP checksum */
-#define E1000_TXD_POPTS_TXSM 0x02       /* Insert TCP/UDP checksum */
-#define E1000_TXD_CMD_EOP    0x01000000 /* End of Packet */
-#define E1000_TXD_CMD_IFCS   0x02000000 /* Insert FCS (Ethernet CRC) */
-#define E1000_TXD_CMD_IC     0x04000000 /* Insert Checksum */
-#define E1000_TXD_CMD_RS     0x08000000 /* Report Status */
-#define E1000_TXD_CMD_RPS    0x10000000 /* Report Packet Sent */
-#define E1000_TXD_CMD_DEXT   0x20000000 /* Descriptor extension (0 = legacy) */
-#define E1000_TXD_CMD_VLE    0x40000000 /* Add VLAN tag */
-#define E1000_TXD_CMD_IDE    0x80000000 /* Enable Tidv register */
-#define E1000_TXD_STAT_DD    0x00000001 /* Descriptor Done */
-#define E1000_TXD_STAT_EC    0x00000002 /* Excess Collisions */
-#define E1000_TXD_STAT_LC    0x00000004 /* Late Collisions */
-#define E1000_TXD_STAT_TU    0x00000008 /* Transmit underrun */
-#define E1000_TXD_CMD_TCP    0x01000000 /* TCP packet */
-#define E1000_TXD_CMD_IP     0x02000000 /* IP packet */
-#define E1000_TXD_CMD_TSE    0x04000000 /* TCP Seg enable */
-#define E1000_TXD_STAT_TC    0x00000004 /* Tx Underrun */
-
 /* Transmit Control */
 #define E1000_TCTL_EN     0x00000002    /* enable tx */
 #define E1000_TCTL_PSP    0x00000008    /* pad short packets */
diff -ur a/drivers/net/ehea/ehea_phyp.c b/drivers/net/ehea/ehea_phyp.c
--- a/drivers/net/ehea/ehea_phyp.c	2007-10-09 22:31:38.000000000 +0200
+++ b/drivers/net/ehea/ehea_phyp.c	2007-11-07 22:25:28.000000000 +0100
@@ -333,13 +333,6 @@
 	return hret;
 }
 
-/* Defines for H_CALL H_ALLOC_RESOURCE */
-#define H_ALL_RES_TYPE_QP        1
-#define H_ALL_RES_TYPE_CQ        2
-#define H_ALL_RES_TYPE_EQ        3
-#define H_ALL_RES_TYPE_MR        5
-#define H_ALL_RES_TYPE_MW        6
-
 /*  input param R5 */
 #define H_ALL_RES_EQ_NEQ             EHEA_BMASK_IBM(0, 0)
 #define H_ALL_RES_EQ_NON_NEQ_ISN     EHEA_BMASK_IBM(6, 7)
diff -ur a/drivers/net/hp100.c b/drivers/net/hp100.c
--- a/drivers/net/hp100.c	2007-11-07 11:26:13.000000000 +0100
+++ b/drivers/net/hp100.c	2007-11-08 11:57:21.000000000 +0100
@@ -83,6 +83,7 @@
 **
 */
 
+/* default - don't enable transmit outgoing packets as priority */
 #define HP100_DEFAULT_PRIORITY_TX 0
 
 #undef HP100_DEBUG
@@ -139,11 +140,6 @@
 #define HP100_DEFAULT_RX_RATIO	75
 #endif
 
-#ifndef HP100_DEFAULT_PRIORITY_TX
-/* default - don't enable transmit outgoing packets as priority */
-#define HP100_DEFAULT_PRIORITY_TX 0
-#endif
-
 /*
  *  structures
  */
diff -ur a/drivers/net/niu.h b/drivers/net/niu.h
--- a/drivers/net/niu.h	2007-11-07 11:26:13.000000000 +0100
+++ b/drivers/net/niu.h	2007-11-07 22:35:18.000000000 +0100
@@ -546,7 +546,6 @@
 #define  BRXMAC_ALIGN_ERR_CNT_COUNT	0x000000000000ffffULL
 
 #define BRXMAC_CRC_ERR_CNT		0x00388
-#define  BRXMAC_ALIGN_ERR_CNT_COUNT	0x000000000000ffffULL
 
 #define BRXMAC_CODE_VIOL_ERR_CNT	0x00390
 #define  BRXMAC_CODE_VIOL_ERR_CNT_COUNT	0x000000000000ffffULL
diff -ur a/drivers/net/tokenring/smctr.h b/drivers/net/tokenring/smctr.h
--- a/drivers/net/tokenring/smctr.h	2007-10-09 22:31:38.000000000 +0200
+++ b/drivers/net/tokenring/smctr.h	2007-11-08 12:28:25.000000000 +0100
@@ -745,15 +745,11 @@
 #define MSR_MEMB                0x40
 #define MSR_0WS                 0x20
 
-#define FORCED_16BIT_MODE       0x0002
-
 #define INTERFRAME_SPACING_16           0x0003  /* 6 bytes */
 #define INTERFRAME_SPACING_4            0x0001  /* 2 bytes */
 #define MULTICAST_ADDRESS_BIT           0x0010
 #define NON_SRC_ROUTING_BIT             0x0020
 
-#define LOOPING_MODE_MASK       0x0007
-
 /*
  * Decode firmware defines.
  */
@@ -873,8 +869,6 @@
                 __u8                    filler[12];             /* 32 */
 } ACBlock;
 
-#define NUM_OF_INTERRUPTS               0x20
-
 #pragma pack(1)
 typedef struct {
                 Interrupt_Status_Word   IStatus[NUM_OF_INTERRUPTS];
diff -ur a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
--- a/drivers/net/tulip/de4x5.c	2007-11-07 11:26:14.000000000 +0100
+++ b/drivers/net/tulip/de4x5.c	2007-11-08 12:31:49.000000000 +0100
@@ -606,12 +606,6 @@
 #define DE4X5_NDA 0xffe0            /* No Device (I/O) Address */
 
 /*
-** Ethernet PROM defines
-*/
-#define PROBE_LENGTH    32
-#define ETH_PROM_SIG    0xAA5500FFUL
-
-/*
 ** Ethernet Info
 */
 #define PKT_BUF_SZ	1536            /* Buffer size for each Tx/Rx buffer */
diff -ur a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
--- a/drivers/net/usb/rtl8150.c	2007-11-07 11:26:14.000000000 +0100
+++ b/drivers/net/usb/rtl8150.c	2007-11-08 12:37:40.000000000 +0100
@@ -85,32 +85,6 @@
 #define INT_CRERR_CNT		0x06
 #define INT_COL_CNT		0x07
 
-/* Transmit status register errors */
-#define TSR_ECOL		(1<<5)
-#define TSR_LCOL		(1<<4)
-#define TSR_LOSS_CRS		(1<<3)
-#define TSR_JBR			(1<<2)
-#define TSR_ERRORS		(TSR_ECOL | TSR_LCOL | TSR_LOSS_CRS | TSR_JBR)
-/* Receive status register errors */
-#define RSR_CRC			(1<<2)
-#define RSR_FAE			(1<<1)
-#define RSR_ERRORS		(RSR_CRC | RSR_FAE)
-
-/* Media status register definitions */
-#define MSR_DUPLEX		(1<<4)
-#define MSR_SPEED		(1<<3)
-#define MSR_LINK		(1<<2)
-
-/* Interrupt pipe data */
-#define INT_TSR			0x00
-#define INT_RSR			0x01
-#define INT_MSR			0x02
-#define INT_WAKSR		0x03
-#define INT_TXOK_CNT		0x04
-#define INT_RXLOST_CNT		0x05
-#define INT_CRERR_CNT		0x06
-#define INT_COL_CNT		0x07
-
 
 #define	RTL8150_MTU		1540
 #define	RTL8150_TX_TIMEOUT	(HZ)
diff -ur a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
--- a/drivers/net/wan/dscc4.c	2007-11-07 11:26:14.000000000 +0100
+++ b/drivers/net/wan/dscc4.c	2007-11-08 12:39:07.000000000 +0100
@@ -297,7 +297,6 @@
 #define IsrMask		0x000fffff
 #define BrrExpMask	0x00000f00
 #define BrrMultMask	0x0000003f
-#define EncodingMask	0x00700000
 #define Hold		0x40000000
 #define SccBusy		0x10000000
 #define PowerUp		0x80000000
diff -ur a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
--- a/drivers/net/wireless/atmel.c	2007-11-07 11:26:14.000000000 +0100
+++ b/drivers/net/wireless/atmel.c	2007-11-08 12:40:56.000000000 +0100
@@ -253,7 +253,6 @@
 #define MAC_MGMT_MIB_BEACON_PER_POS           0
 #define MAC_MGMT_MIB_STATION_ID_POS           6
 #define MAC_MGMT_MIB_CUR_PRIVACY_POS          11
-#define MAC_MGMT_MIB_CUR_BSSID_POS            14
 #define MAC_MGMT_MIB_PS_MODE_POS              53
 #define MAC_MGMT_MIB_LISTEN_INTERVAL_POS      54
 #define MAC_MGMT_MIB_MULTI_DOMAIN_IMPLEMENTED 56
diff -ur a/drivers/net/wireless/iwlwifi/iwl-eeprom.h b/drivers/net/wireless/iwlwifi/iwl-eeprom.h
--- a/drivers/net/wireless/iwlwifi/iwl-eeprom.h	2007-11-07 11:26:14.000000000 +0100
+++ b/drivers/net/wireless/iwlwifi/iwl-eeprom.h	2007-11-08 12:45:59.000000000 +0100
@@ -88,9 +88,6 @@
 
 /* EEPROM field lengths */
 #define EEPROM_BOARD_PBA_NUMBER_LENGTH                  11
-
-/* EEPROM field lengths */
-#define EEPROM_BOARD_PBA_NUMBER_LENGTH                  11
 #define EEPROM_REGULATORY_SKU_ID_LENGTH                 4
 #define EEPROM_REGULATORY_BAND1_CHANNELS_LENGTH         14
 #define EEPROM_REGULATORY_BAND2_CHANNELS_LENGTH         13
diff -ur a/drivers/net/wireless/libertas/host.h b/drivers/net/wireless/libertas/host.h
--- a/drivers/net/wireless/libertas/host.h	2007-11-07 11:26:14.000000000 +0100
+++ b/drivers/net/wireless/libertas/host.h	2007-11-08 12:49:20.000000000 +0100
@@ -83,7 +83,6 @@
 #define CMD_802_11_BEACON_STOP        0x0049
 
 #define CMD_802_11_MAC_ADDRESS        0x004D
-#define CMD_802_11_EEPROM_ACCESS      0x0059
 
 #define CMD_802_11_BAND_CONFIG        0x0058
 
