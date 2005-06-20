From: Pavel Machek <pavel@ucw.cz>
Subject: [patch] ipw2100: remove commented-out code
Date: Mon, 20 Jun 2005 13:33:07 +0200
Message-ID: <20050620113307.GA14918@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev list <netdev@oss.sgi.com>, Andrew Morton <akpm@zip.com.au>,
        Jeff Garzik <jgarzik@pobox.com>,
        "James P. Ketrenos" <ipw2100-admin@linux.intel.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This removes up various code/defines that was just commented out
instead of being deleted.

--- clean-mm/drivers/net/wireless/ipw2100.c	2005-06-20 12:34:33.000000000 +0200
+++ linux-mm/drivers/net/wireless/ipw2100.c	2005-06-20 12:55:03.000000000 +0200
@@ -915,12 +907,10 @@
 	if (i == 10000)
 		return -EIO;	/* TODO: better error value */
 
-//#if CONFIG_IPW2100_D0ENABLED
 	/* set D0 standby bit */
 	read_register(priv->net_dev, IPW_REG_GP_CNTRL, &r);
 	write_register(priv->net_dev, IPW_REG_GP_CNTRL,
 		       r | IPW_AUX_HOST_GP_CNTRL_BIT_HOST_ALLOWS_STANDBY);
-//#endif
 
 	return 0;
 }
--- clean-mm/drivers/net/wireless/ipw2100.h	2005-06-20 12:34:33.000000000 +0200
+++ linux-mm/drivers/net/wireless/ipw2100.h	2005-06-20 12:55:10.000000000 +0200
@@ -320,7 +318,7 @@
 	u16 fragment_size;
 } __attribute__ ((packed));
 
-// Host command data structure
+/* Host command data structure */
 struct host_command {
 	u32 host_command;		// COMMAND ID
 	u32 host_command1;		// COMMAND ID
@@ -663,7 +656,7 @@
 #define MSDU_TX_RATES          62
 
 
-// Rogue AP Detection
+/* Rogue AP Detection */
 #define SET_STATION_STAT_BITS      64
 #define CLEAR_STATIONS_STAT_BITS   65
 #define LEAP_ROGUE_MODE            66	//TODO tbw replaced by CFG_LEAP_ROGUE_AP
@@ -673,25 +666,16 @@
 
 
 
-// system configuration bit mask:
-//#define IPW_CFG_ANTENNA_SETTING           0x03
-//#define IPW_CFG_ANTENNA_A                 0x01
-//#define IPW_CFG_ANTENNA_B                 0x02
+/* system configuration bit mask: */
 #define IPW_CFG_MONITOR               0x00004
-//#define IPW_CFG_TX_STATUS_ENABLE    0x00008
 #define IPW_CFG_PREAMBLE_AUTO        0x00010
 #define IPW_CFG_IBSS_AUTO_START     0x00020
-//#define IPW_CFG_KERBEROS_ENABLE     0x00040
 #define IPW_CFG_LOOPBACK            0x00100
-//#define IPW_CFG_WNMP_PING_PASS      0x00200
-//#define IPW_CFG_DEBUG_ENABLE        0x00400
 #define IPW_CFG_ANSWER_BCSSID_PROBE 0x00800
-//#define IPW_CFG_BT_PRIORITY         0x01000
 #define IPW_CFG_BT_SIDEBAND_SIGNAL	0x02000
 #define IPW_CFG_802_1x_ENABLE       0x04000
 #define IPW_CFG_BSS_MASK		0x08000
 #define IPW_CFG_IBSS_MASK		0x10000
-//#define IPW_CFG_DYNAMIC_CW          0x10000
 
 #define IPW_SCAN_NOASSOCIATE (1<<0)
 #define IPW_SCAN_MIXED_CELL (1<<1)
@@ -840,7 +824,7 @@
 	} rx_data;
 } __attribute__ ((packed));
 
-// Bit 0-7 are for 802.11b tx rates - .  Bit 5-7 are reserved
+/* Bit 0-7 are for 802.11b tx rates - .  Bit 5-7 are reserved */
 #define TX_RATE_1_MBIT              0x0001
 #define TX_RATE_2_MBIT              0x0002
 #define TX_RATE_5_5_MBIT            0x0004
@@ -1120,7 +1104,6 @@
 	IPW_ORD_UCODE_VERSION,	// Ucode Version
 	IPW_ORD_HW_RF_SWITCH_STATE = 214,	// HW RF Kill Switch State
 } ORDINALTABLE1;
-//ENDOF TABLE1
 
 // ordinal table 2
 // Variable length data:

-- 
teflon -- maybe it is a trademark, but it should not be.
