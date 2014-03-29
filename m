From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 4/6 NEXT] staging: r8723au: Add source files for new driver - part 4
Date: Fri, 28 Mar 2014 21:37:41 -0500
Message-ID: <1396060663-3589-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1396060663-3589-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Jes Sorensen <Jes.Sorensen@redhat.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:35149 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbaC2Cil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 22:38:41 -0400
Received: by mail-oa0-f47.google.com with SMTP id i11so6967178oag.34
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 19:38:31 -0700 (PDT)
In-Reply-To: <1396060663-3589-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Realtek USB device RTL8723AU is found in Lenovo Yoga 13 tablets.
A driver for it has been available in a GitHub repo for several months.
This commit contains the fourth part of source files. The source
is arbitrarily split to avoid E-mail files that are too large.

Jes Sorensen at RedHat has made many improvements to the vendor code,
and he has been doing the testing. I do not have access to this device.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Jes Sorensen <Jes.Sorensen@redhat.com>
---
 drivers/staging/rtl8723au/include/Hal8723APhyCfg.h |  234 +++
 drivers/staging/rtl8723au/include/Hal8723APhyReg.h | 1078 ++++++++++
 drivers/staging/rtl8723au/include/Hal8723PwrSeq.h  |  150 ++
 .../staging/rtl8723au/include/Hal8723UHWImg_CE.h   |   29 +
 .../staging/rtl8723au/include/HalDMOutSrc8723A.h   |   64 +
 .../staging/rtl8723au/include/HalHWImg8723A_BB.h   |   44 +
 .../staging/rtl8723au/include/HalHWImg8723A_FW.h   |   28 +
 .../staging/rtl8723au/include/HalHWImg8723A_MAC.h  |   26 +
 .../staging/rtl8723au/include/HalHWImg8723A_RF.h   |   25 +
 drivers/staging/rtl8723au/include/HalPwrSeqCmd.h   |  130 ++
 drivers/staging/rtl8723au/include/HalVerDef.h      |  136 ++
 drivers/staging/rtl8723au/include/cmd_osdep.h      |   26 +
 drivers/staging/rtl8723au/include/drv_types.h      |  364 ++++
 drivers/staging/rtl8723au/include/ethernet.h       |   22 +
 drivers/staging/rtl8723au/include/hal_com.h        |  211 ++
 drivers/staging/rtl8723au/include/hal_intf.h       |  392 ++++
 drivers/staging/rtl8723au/include/ieee80211.h      |  603 ++++++
 drivers/staging/rtl8723au/include/ioctl_cfg80211.h |  119 ++
 drivers/staging/rtl8723au/include/mlme_osdep.h     |   28 +
 drivers/staging/rtl8723au/include/mp_custom_oid.h  |  342 ++++
 drivers/staging/rtl8723au/include/odm.h            | 1210 +++++++++++
 drivers/staging/rtl8723au/include/odm_HWConfig.h   |  174 ++
 .../staging/rtl8723au/include/odm_RegConfig8723A.h |   34 +
 .../staging/rtl8723au/include/odm_RegDefine11AC.h  |   49 +
 .../staging/rtl8723au/include/odm_RegDefine11N.h   |  165 ++
 drivers/staging/rtl8723au/include/odm_debug.h      |  139 ++
 drivers/staging/rtl8723au/include/odm_interface.h  |  131 ++
 drivers/staging/rtl8723au/include/odm_precomp.h    |   54 +
 drivers/staging/rtl8723au/include/odm_reg.h        |  114 ++
 drivers/staging/rtl8723au/include/odm_types.h      |   36 +
 drivers/staging/rtl8723au/include/osdep_intf.h     |   46 +
 drivers/staging/rtl8723au/include/osdep_service.h  |  340 +++
 drivers/staging/rtl8723au/include/recv_osdep.h     |   45 +
 .../rtl8723au/include/rtl8723a_bt-coexist.h        | 1672 ++++++++++++=
+++
 drivers/staging/rtl8723au/include/rtl8723a_cmd.h   |  160 ++
 drivers/staging/rtl8723au/include/rtl8723a_dm.h    |  144 ++
 drivers/staging/rtl8723au/include/rtl8723a_hal.h   |  575 ++++++
 drivers/staging/rtl8723au/include/rtl8723a_led.h   |   30 +
 drivers/staging/rtl8723au/include/rtl8723a_pg.h    |  107 +
 drivers/staging/rtl8723au/include/rtl8723a_recv.h  |   70 +
 drivers/staging/rtl8723au/include/rtl8723a_rf.h    |   58 +
 drivers/staging/rtl8723au/include/rtl8723a_spec.h  | 2158 ++++++++++++=
++++++++
 .../staging/rtl8723au/include/rtl8723a_sreset.h    |   25 +
 drivers/staging/rtl8723au/include/rtl8723a_xmit.h  |  229 +++
 drivers/staging/rtl8723au/include/rtw_ap.h         |   55 +
 drivers/staging/rtl8723au/include/rtw_cmd.h        |  835 ++++++++
 drivers/staging/rtl8723au/include/rtw_debug.h      |  192 ++
 drivers/staging/rtl8723au/include/rtw_eeprom.h     |  135 ++
 drivers/staging/rtl8723au/include/rtw_efuse.h      |  109 +
 drivers/staging/rtl8723au/include/rtw_event.h      |  114 ++
 drivers/staging/rtl8723au/include/rtw_ht.h         |   43 +
 drivers/staging/rtl8723au/include/rtw_io.h         |  416 ++++
 drivers/staging/rtl8723au/include/rtw_ioctl.h      |   26 +
 drivers/staging/rtl8723au/include/rtw_ioctl_set.h  |   39 +
 drivers/staging/rtl8723au/include/rtw_led.h        |  181 ++
 drivers/staging/rtl8723au/include/rtw_mlme.h       |  632 ++++++
 drivers/staging/rtl8723au/include/rtw_mlme_ext.h   |  782 +++++++
 drivers/staging/rtl8723au/include/rtw_p2p.h        |  158 ++
 drivers/staging/rtl8723au/include/rtw_pwrctrl.h    |  265 +++
 drivers/staging/rtl8723au/include/rtw_qos.h        |   26 +
 drivers/staging/rtl8723au/include/rtw_recv.h       |  319 +++
 drivers/staging/rtl8723au/include/rtw_rf.h         |  113 +
 drivers/staging/rtl8723au/include/rtw_security.h   |  357 ++++
 drivers/staging/rtl8723au/include/rtw_sreset.h     |   56 +
 drivers/staging/rtl8723au/include/rtw_version.h    |    1 +
 drivers/staging/rtl8723au/include/rtw_xmit.h       |  407 ++++
 drivers/staging/rtl8723au/include/sta_info.h       |  396 ++++
 drivers/staging/rtl8723au/include/usb_hal.h        |   20 +
 drivers/staging/rtl8723au/include/usb_ops.h        |   97 +
 drivers/staging/rtl8723au/include/usb_ops_linux.h  |   46 +
 drivers/staging/rtl8723au/include/usb_osintf.h     |   24 +
 drivers/staging/rtl8723au/include/usb_vendor_req.h |   31 +
 drivers/staging/rtl8723au/include/wifi.h           |  707 +++++++
 drivers/staging/rtl8723au/include/wlan_bssdef.h    |  215 ++
 drivers/staging/rtl8723au/include/xmit_osdep.h     |   57 +
 75 files changed, 18670 insertions(+)
 create mode 100644 drivers/staging/rtl8723au/include/Hal8723APhyCfg.h
 create mode 100644 drivers/staging/rtl8723au/include/Hal8723APhyReg.h
 create mode 100644 drivers/staging/rtl8723au/include/Hal8723PwrSeq.h
 create mode 100644 drivers/staging/rtl8723au/include/Hal8723UHWImg_CE.=
h
 create mode 100644 drivers/staging/rtl8723au/include/HalDMOutSrc8723A.=
h
 create mode 100644 drivers/staging/rtl8723au/include/HalHWImg8723A_BB.=
h
 create mode 100644 drivers/staging/rtl8723au/include/HalHWImg8723A_FW.=
h
 create mode 100644 drivers/staging/rtl8723au/include/HalHWImg8723A_MAC=
=2Eh
 create mode 100644 drivers/staging/rtl8723au/include/HalHWImg8723A_RF.=
h
 create mode 100644 drivers/staging/rtl8723au/include/HalPwrSeqCmd.h
 create mode 100644 drivers/staging/rtl8723au/include/HalVerDef.h
 create mode 100644 drivers/staging/rtl8723au/include/cmd_osdep.h
 create mode 100644 drivers/staging/rtl8723au/include/drv_types.h
 create mode 100644 drivers/staging/rtl8723au/include/ethernet.h
 create mode 100644 drivers/staging/rtl8723au/include/hal_com.h
 create mode 100644 drivers/staging/rtl8723au/include/hal_intf.h
 create mode 100644 drivers/staging/rtl8723au/include/ieee80211.h
 create mode 100644 drivers/staging/rtl8723au/include/ioctl_cfg80211.h
 create mode 100644 drivers/staging/rtl8723au/include/mlme_osdep.h
 create mode 100644 drivers/staging/rtl8723au/include/mp_custom_oid.h
 create mode 100644 drivers/staging/rtl8723au/include/odm.h
 create mode 100644 drivers/staging/rtl8723au/include/odm_HWConfig.h
 create mode 100644 drivers/staging/rtl8723au/include/odm_RegConfig8723=
A.h
 create mode 100644 drivers/staging/rtl8723au/include/odm_RegDefine11AC=
=2Eh
 create mode 100644 drivers/staging/rtl8723au/include/odm_RegDefine11N.=
h
 create mode 100644 drivers/staging/rtl8723au/include/odm_debug.h
 create mode 100644 drivers/staging/rtl8723au/include/odm_interface.h
 create mode 100644 drivers/staging/rtl8723au/include/odm_precomp.h
 create mode 100644 drivers/staging/rtl8723au/include/odm_reg.h
 create mode 100644 drivers/staging/rtl8723au/include/odm_types.h
 create mode 100644 drivers/staging/rtl8723au/include/osdep_intf.h
 create mode 100644 drivers/staging/rtl8723au/include/osdep_service.h
 create mode 100644 drivers/staging/rtl8723au/include/recv_osdep.h
 create mode 100644 drivers/staging/rtl8723au/include/rtl8723a_bt-coexi=
st.h
 create mode 100644 drivers/staging/rtl8723au/include/rtl8723a_cmd.h
 create mode 100644 drivers/staging/rtl8723au/include/rtl8723a_dm.h
 create mode 100644 drivers/staging/rtl8723au/include/rtl8723a_hal.h
 create mode 100644 drivers/staging/rtl8723au/include/rtl8723a_led.h
 create mode 100644 drivers/staging/rtl8723au/include/rtl8723a_pg.h
 create mode 100644 drivers/staging/rtl8723au/include/rtl8723a_recv.h
 create mode 100644 drivers/staging/rtl8723au/include/rtl8723a_rf.h
 create mode 100644 drivers/staging/rtl8723au/include/rtl8723a_spec.h
 create mode 100644 drivers/staging/rtl8723au/include/rtl8723a_sreset.h
 create mode 100644 drivers/staging/rtl8723au/include/rtl8723a_xmit.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_ap.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_cmd.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_debug.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_eeprom.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_efuse.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_event.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_ht.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_io.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_ioctl.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_ioctl_set.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_led.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_mlme.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_mlme_ext.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_p2p.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_pwrctrl.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_qos.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_recv.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_rf.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_security.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_sreset.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_version.h
 create mode 100644 drivers/staging/rtl8723au/include/rtw_xmit.h
 create mode 100644 drivers/staging/rtl8723au/include/sta_info.h
 create mode 100644 drivers/staging/rtl8723au/include/usb_hal.h
 create mode 100644 drivers/staging/rtl8723au/include/usb_ops.h
 create mode 100644 drivers/staging/rtl8723au/include/usb_ops_linux.h
 create mode 100644 drivers/staging/rtl8723au/include/usb_osintf.h
 create mode 100644 drivers/staging/rtl8723au/include/usb_vendor_req.h
 create mode 100644 drivers/staging/rtl8723au/include/wifi.h
 create mode 100644 drivers/staging/rtl8723au/include/wlan_bssdef.h
 create mode 100644 drivers/staging/rtl8723au/include/xmit_osdep.h

diff --git a/drivers/staging/rtl8723au/include/Hal8723APhyCfg.h b/drive=
rs/staging/rtl8723au/include/Hal8723APhyCfg.h
new file mode 100644
index 0000000..4aa8cdb
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/Hal8723APhyCfg.h
@@ -0,0 +1,234 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *
+ *********************************************************************=
*********/
+#ifndef __INC_HAL8723PHYCFG_H__
+#define __INC_HAL8723PHYCFG_H__
+
+/*--------------------------Define Parameters-------------------------=
------*/
+#define LOOP_LIMIT				5
+#define MAX_STALL_TIME		50		/* us */
+#define AntennaDiversityValue	0x80
+#define MAX_TXPWR_IDX_NMODE_92S	63
+#define Reset_Cnt_Limit		3
+
+
+#define MAX_AGGR_NUM	0x0909
+
+/*--------------------------Define Parameters-------------------------=
------*/
+
+
+/*------------------------------Define structure----------------------=
------*/
+enum swchnlcmdid {
+	CmdID_End,
+	CmdID_SetTxPowerLevel,
+	CmdID_BBRegWrite10,
+	CmdID_WritePortUlong,
+	CmdID_WritePortUshort,
+	CmdID_WritePortUchar,
+	CmdID_RF_WriteReg,
+};
+
+
+/* 1. Switch channel related */
+struct swchnlcmd {
+	enum swchnlcmdid	CmdID;
+	u32			Para1;
+	u32			Para2;
+	u32			msDelay;
+};
+
+enum HW90_BLOCK {
+	HW90_BLOCK_MAC =3D 0,
+	HW90_BLOCK_PHY0 =3D 1,
+	HW90_BLOCK_PHY1 =3D 2,
+	HW90_BLOCK_RF =3D 3,
+	HW90_BLOCK_MAXIMUM =3D 4, /*  Never use this */
+};
+
+enum RF_RADIO_PATH {
+	RF_PATH_A =3D 0,			/* Radio Path A */
+	RF_PATH_B =3D 1,			/* Radio Path B */
+	RF_PATH_C =3D 2,			/* Radio Path C */
+	RF_PATH_D =3D 3,			/* Radio Path D */
+	RF_PATH_MAX			/* Max RF number 90 support */
+};
+
+#define	RF_PATH_MAX			3
+
+#define CHANNEL_MAX_NUMBER		14	/*  14 is the max channel number */
+#define CHANNEL_GROUP_MAX		3	/*  ch1~3, ch4~9, ch10~14 total three gro=
ups */
+
+enum WIRELESS_MODE {
+	WIRELESS_MODE_UNKNOWN	=3D 0x00,
+	WIRELESS_MODE_A		=3D BIT2,
+	WIRELESS_MODE_B		=3D BIT0,
+	WIRELESS_MODE_G		=3D BIT1,
+	WIRELESS_MODE_AUTO	=3D BIT5,
+	WIRELESS_MODE_N_24G	=3D BIT3,
+	WIRELESS_MODE_N_5G	=3D BIT4,
+	WIRELESS_MODE_AC	=3D BIT6
+};
+
+enum baseband_config_type {
+	BaseBand_Config_PHY_REG =3D 0,			/* Radio Path A */
+	BaseBand_Config_AGC_TAB =3D 1,			/* Radio Path B */
+};
+
+enum ra_offset_area {
+	RA_OFFSET_LEGACY_OFDM1,
+	RA_OFFSET_LEGACY_OFDM2,
+	RA_OFFSET_HT_OFDM1,
+	RA_OFFSET_HT_OFDM2,
+	RA_OFFSET_HT_OFDM3,
+	RA_OFFSET_HT_OFDM4,
+	RA_OFFSET_HT_CCK,
+};
+
+
+/* BB/RF related */
+enum rf_type_8190p {
+	RF_TYPE_MIN,		/*  0 */
+	RF_8225 =3D 1,		/*  1 11b/g RF for verification only */
+	RF_8256 =3D 2,		/*  2 11b/g/n */
+	RF_8258 =3D 3,		/*  3 11a/b/g/n RF */
+	RF_6052 =3D 4,		/*  4 11b/g/n RF */
+	RF_PSEUDO_11N =3D 5,	/*  5, It is a temporality RF. */
+};
+
+struct bb_reg_define {
+	u32 rfintfs;		/*  set software control: */
+				/*		0x870~0x877[8 bytes] */
+	u32 rfintfi;		/*  readback data: */
+				/*		0x8e0~0x8e7[8 bytes] */
+	u32 rfintfo;		/*  output data: */
+				/*		0x860~0x86f [16 bytes] */
+	u32 rfintfe;		/*  output enable: */
+				/*		0x860~0x86f [16 bytes] */
+	u32 rf3wireOffset;	/*  LSSI data: */
+				/*		0x840~0x84f [16 bytes] */
+	u32 rfLSSI_Select;	/*  BB Band Select: */
+				/*		0x878~0x87f [8 bytes] */
+	u32 rfTxGainStage;	/*  Tx gain stage: */
+				/*		0x80c~0x80f [4 bytes] */
+	u32 rfHSSIPara1;	/*  wire parameter control1 : */
+				/*		0x820~0x823, 0x828~0x82b, 0x830~0x833, 0x838~0x83b [16 bytes] =
*/
+	u32 rfHSSIPara2;	/*  wire parameter control2 : */
+				/*		0x824~0x827, 0x82c~0x82f, 0x834~0x837, 0x83c~0x83f [16 bytes] =
*/
+	u32 rfSwitchControl; /* Tx Rx antenna control : */
+				/*		0x858~0x85f [16 bytes] */
+	u32 rfAGCControl1;	/* AGC parameter control1 : */
+				/*	0xc50~0xc53, 0xc58~0xc5b, 0xc60~0xc63, 0xc68~0xc6b [16 bytes] *=
/
+	u32 rfAGCControl2;	/* AGC parameter control2 : */
+				/*		0xc54~0xc57, 0xc5c~0xc5f, 0xc64~0xc67, 0xc6c~0xc6f [16 bytes] =
*/
+	u32 rfRxIQImbalance; /* OFDM Rx IQ imbalance matrix : */
+				/*		0xc14~0xc17, 0xc1c~0xc1f, 0xc24~0xc27, 0xc2c~0xc2f [16 bytes] =
*/
+	u32 rfRxAFE;		/* Rx IQ DC ofset and Rx digital filter, Rx DC notch fi=
lter : */
+				/*	0xc10~0xc13, 0xc18~0xc1b, 0xc20~0xc23, 0xc28~0xc2b [16 bytes] *=
/
+	u32 rfTxIQImbalance; /* OFDM Tx IQ imbalance matrix */
+				/*	0xc80~0xc83, 0xc88~0xc8b, 0xc90~0xc93, 0xc98~0xc9b [16 bytes] *=
/
+	u32 rfTxAFE;		/* Tx IQ DC Offset and Tx DFIR type */
+				/*	0xc84~0xc87, 0xc8c~0xc8f, 0xc94~0xc97, 0xc9c~0xc9f [16 bytes] *=
/
+	u32 rfLSSIReadBack;	/* LSSI RF readback data SI mode */
+				/*	0x8a0~0x8af [16 bytes] */
+	u32 rfLSSIReadBackPi;	/* LSSI RF readback data PI mode 0x8b8-8bc for =
Path A and B */
+};
+
+struct r_antenna_sel_ofdm {
+	u32			r_tx_antenna:4;
+	u32			r_ant_l:4;
+	u32			r_ant_non_ht:4;
+	u32			r_ant_ht1:4;
+	u32			r_ant_ht2:4;
+	u32			r_ant_ht_s1:4;
+	u32			r_ant_non_ht_s1:4;
+	u32			OFDM_TXSC:2;
+	u32			Reserved:2;
+};
+
+struct r_antenna_sel_cck {
+	u8			r_cckrx_enable_2:2;
+	u8			r_cckrx_enable:2;
+	u8			r_ccktx_enable:4;
+};
+
+/*------------------------------Define structure----------------------=
------*/
+
+
+/*------------------------Export global variable----------------------=
------*/
+/*------------------------Export global variable----------------------=
------*/
+
+
+/*------------------------Export Macro Definition---------------------=
------*/
+/*------------------------Export Macro Definition---------------------=
------*/
+
+
+/*--------------------------Exported Function prototype---------------=
------*/
+/*  */
+/*  BB and RF register read/write */
+/*  */
+u32	PHY_QueryBBReg(struct rtw_adapter *Adapter, u32 RegAddr,
+		       u32 BitMask);
+void	PHY_SetBBReg(struct rtw_adapter *Adapter, u32 RegAddr,
+		     u32 BitMask, u32 Data);
+u32	PHY_QueryRFReg(struct rtw_adapter *Adapter,
+		       enum RF_RADIO_PATH	eRFPath, u32 RegAddr,
+		       u32 BitMask);
+void	PHY_SetRFReg(struct rtw_adapter *Adapter,
+		     enum RF_RADIO_PATH eRFPath, u32 RegAddr,
+		     u32 BitMask,  u32	Data);
+
+/*  */
+/*  BB TX Power R/W */
+/*  */
+void PHY_SetTxPowerLevel8723A(struct rtw_adapter *Adapter, u8 channel)=
;
+
+/*  */
+/*  Switch bandwidth for 8723A */
+/*  */
+void	PHY_SetBWMode23a8723A(struct rtw_adapter *pAdapter,
+			   enum ht_channel_width ChnlWidth,
+			   unsigned char Offset);
+
+/*  */
+/*  channel switch related funciton */
+/*  */
+void	PHY_SwChnl8723A(struct rtw_adapter *pAdapter, u8 channel);
+				/*  Call after initialization */
+void ChkFwCmdIoDone(struct rtw_adapter *Adapter);
+
+/*  */
+/*  Modify the value of the hw register when beacon interval be change=
d. */
+/*  */
+void
+rtl8192c_PHY_SetBeaconHwReg(struct rtw_adapter *Adapter, u16 BeaconInt=
erval);
+
+
+void PHY_SwitchEphyParameter(struct rtw_adapter *Adapter);
+
+void PHY_EnableHostClkReq(struct rtw_adapter *Adapter);
+
+bool
+SetAntennaConfig92C(struct rtw_adapter *Adapter, u8 DefaultAnt);
+
+/*--------------------------Exported Function prototype---------------=
------*/
+
+#define PHY_SetMacReg	PHY_SetBBReg
+
+/* MAC/BB/RF HAL config */
+int PHY_BBConfig8723A(struct rtw_adapter *Adapter);
+int PHY_RFConfig8723A(struct rtw_adapter *Adapter);
+s32 PHY_MACConfig8723A(struct rtw_adapter *padapter);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/Hal8723APhyReg.h b/drive=
rs/staging/rtl8723au/include/Hal8723APhyReg.h
new file mode 100644
index 0000000..759928f
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/Hal8723APhyReg.h
@@ -0,0 +1,1078 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *
+ *********************************************************************=
*********/
+#ifndef __INC_HAL8723APHYREG_H__
+#define __INC_HAL8723APHYREG_H__
+
+/*  1. PMAC duplicate register due to connection: RF_Mode, TRxRN, NumO=
f L-STF */
+/*  1. Page1(0x100) */
+#define rPMAC_Reset				0x100
+#define rPMAC_TxStart				0x104
+#define rPMAC_TxLegacySIG			0x108
+#define rPMAC_TxHTSIG1				0x10c
+#define rPMAC_TxHTSIG2				0x110
+#define rPMAC_PHYDebug				0x114
+#define rPMAC_TxPacketNum			0x118
+#define rPMAC_TxIdle				0x11c
+#define rPMAC_TxMACHeader0			0x120
+#define rPMAC_TxMACHeader1			0x124
+#define rPMAC_TxMACHeader2			0x128
+#define rPMAC_TxMACHeader3			0x12c
+#define rPMAC_TxMACHeader4			0x130
+#define rPMAC_TxMACHeader5			0x134
+#define rPMAC_TxDataType			0x138
+#define rPMAC_TxRandomSeed			0x13c
+#define rPMAC_CCKPLCPPreamble			0x140
+#define rPMAC_CCKPLCPHeader			0x144
+#define rPMAC_CCKCRC16				0x148
+#define rPMAC_OFDMRxCRC32OK			0x170
+#define rPMAC_OFDMRxCRC32Er			0x174
+#define rPMAC_OFDMRxParityEr			0x178
+#define rPMAC_OFDMRxCRC8Er			0x17c
+#define rPMAC_CCKCRxRC16Er			0x180
+#define rPMAC_CCKCRxRC32Er			0x184
+#define rPMAC_CCKCRxRC32OK			0x188
+#define rPMAC_TxStatus				0x18c
+
+/*  2. Page2(0x200) */
+/*  The following two definition are only used for USB interface. */
+#define RF_BB_CMD_ADDR		0x02c0	/*  RF/BB read/write command address. *=
/
+#define RF_BB_CMD_DATA		0x02c4	/*  RF/BB read/write command data. */
+
+/*  3. Page8(0x800) */
+#define rFPGA0_RFMOD		0x800	/* RF mode & CCK TxSC  RF BW Setting?? */
+
+#define rFPGA0_TxInfo		0x804	/*  Status report?? */
+#define rFPGA0_PSDFunction	0x808
+
+#define rFPGA0_TxGainStage	0x80c	/*  Set TX PWR init gain? */
+
+#define rFPGA0_RFTiming1	0x810	/*  Useless now */
+#define rFPGA0_RFTiming2	0x814
+
+#define rFPGA0_XA_HSSIParameter1	0x820	/*  RF 3 wire register */
+#define rFPGA0_XA_HSSIParameter2	0x824
+#define rFPGA0_XB_HSSIParameter1	0x828
+#define rFPGA0_XB_HSSIParameter2	0x82c
+#define rTxAGC_B_Rate18_06		0x830
+#define rTxAGC_B_Rate54_24		0x834
+#define rTxAGC_B_CCK1_55_Mcs32		0x838
+#define rTxAGC_B_Mcs03_Mcs00		0x83c
+
+#define rTxAGC_B_Mcs07_Mcs04		0x848
+#define rTxAGC_B_Mcs11_Mcs08		0x84c
+
+#define rFPGA0_XA_LSSIParameter		0x840
+#define rFPGA0_XB_LSSIParameter		0x844
+
+#define rFPGA0_RFWakeUpParameter	0x850	/*  Useless now */
+#define rFPGA0_RFSleepUpParameter	0x854
+
+#define rFPGA0_XAB_SwitchControl	0x858	/*  RF Channel switch */
+#define rFPGA0_XCD_SwitchControl	0x85c
+
+#define rFPGA0_XA_RFInterfaceOE		0x860	/*  RF Channel switch */
+#define rFPGA0_XB_RFInterfaceOE		0x864
+
+#define rTxAGC_B_Mcs15_Mcs12		0x868
+#define rTxAGC_B_CCK11_A_CCK2_11	0x86c
+
+#define rFPGA0_XAB_RFInterfaceSW	0x870	/*  RF Interface Software Contr=
ol */
+#define rFPGA0_XCD_RFInterfaceSW	0x874
+
+#define rFPGA0_XAB_RFParameter		0x878	/*  RF Parameter */
+#define rFPGA0_XCD_RFParameter		0x87c
+
+#define rFPGA0_AnalogParameter1		0x880	/*  Crystal cap setting RF-R/W =
protection for parameter4?? */
+#define rFPGA0_AnalogParameter2		0x884
+#define rFPGA0_AnalogParameter3		0x888	/*  Useless now */
+#define rFPGA0_AnalogParameter4		0x88c
+
+#define rFPGA0_XA_LSSIReadBack		0x8a0	/*  Tranceiver LSSI Readback */
+#define rFPGA0_XB_LSSIReadBack		0x8a4
+#define rFPGA0_XC_LSSIReadBack		0x8a8
+#define rFPGA0_XD_LSSIReadBack		0x8ac
+
+#define rFPGA0_PSDReport		0x8b4	/*  Useless now */
+#define TransceiverA_HSPI_Readback	0x8b8	/*  Transceiver A HSPI Readba=
ck */
+#define TransceiverB_HSPI_Readback	0x8bc	/*  Transceiver B HSPI Readba=
ck */
+#define rFPGA0_XAB_RFInterfaceRB	0x8e0	/*  Useless now RF Interface Re=
adback Value */
+#define rFPGA0_XCD_RFInterfaceRB	0x8e4	/*  Useless now */
+
+/*  4. Page9(0x900) */
+#define rFPGA1_RFMOD			0x900	/* RF mode & OFDM TxSC RF BW Setting?? */
+
+#define rFPGA1_TxBlock			0x904	/*  Useless now */
+#define rFPGA1_DebugSelect		0x908	/*  Useless now */
+#define rFPGA1_TxInfo			0x90c	/*  Useless now Status report?? */
+
+/*  5. PageA(0xA00) */
+/*  Set Control channel to upper or lower. These settings are required=
 only for 40MHz */
+#define rCCK0_System			0xa00
+
+#define rCCK0_AFESetting		0xa04	/*  Disable init gain now Select RX pa=
th by RSSI */
+#define rCCK0_CCA			0xa08	/*  Disable init gain now Init gain */
+
+#define rCCK0_RxAGC1			0xa0c	/* AGC default value, saturation level An=
tenna Diversity, RX AGC, LNA Threshold, RX LNA Threshold useless now. N=
ot the same as 90 series */
+#define rCCK0_RxAGC2			0xa10	/* AGC & DAGC */
+
+#define rCCK0_RxHP			0xa14
+
+#define rCCK0_DSPParameter1		0xa18	/* Timing recovery & Channel estima=
tion threshold */
+#define rCCK0_DSPParameter2		0xa1c	/* SQ threshold */
+
+#define rCCK0_TxFilter1			0xa20
+#define rCCK0_TxFilter2			0xa24
+#define rCCK0_DebugPort			0xa28	/* debug port and Tx filter3 */
+#define rCCK0_FalseAlarmReport		0xa2c	/* 0xa2d	useless now 0xa30-a4f c=
hannel report */
+#define rCCK0_TRSSIReport		0xa50
+#define rCCK0_RxReport			0xa54  /* 0xa57 */
+#define rCCK0_FACounterLower		0xa5c  /* 0xa5b */
+#define rCCK0_FACounterUpper		0xa58  /* 0xa5c */
+/*  PageB(0xB00) */
+#define rPdp_AntA			0xb00
+#define rPdp_AntA_4			0xb04
+#define rConfig_Pmpd_AntA		0xb28
+#define rConfig_AntA			0xb68
+#define rConfig_AntB			0xb6c
+#define rPdp_AntB			0xb70
+#define rPdp_AntB_4			0xb74
+#define rConfig_Pmpd_AntB		0xb98
+#define rAPK				0xbd8
+
+/*  6. PageC(0xC00) */
+#define rOFDM0_LSTF			0xc00
+
+#define rOFDM0_TRxPathEnable		0xc04
+#define rOFDM0_TRMuxPar			0xc08
+#define rOFDM0_TRSWIsolation		0xc0c
+
+#define rOFDM0_XARxAFE			0xc10  /* RxIQ DC offset, Rx digital filter, =
DC notch filter */
+#define rOFDM0_XARxIQImbalance		0xc14  /* RxIQ imblance matrix */
+#define rOFDM0_XBRxAFE			0xc18
+#define rOFDM0_XBRxIQImbalance		0xc1c
+#define rOFDM0_XCRxAFE			0xc20
+#define rOFDM0_XCRxIQImbalance		0xc24
+#define rOFDM0_XDRxAFE			0xc28
+#define rOFDM0_XDRxIQImbalance		0xc2c
+
+#define rOFDM0_RxDetector1		0xc30  /* PD,BW & SBD	DM tune init gain */
+#define rOFDM0_RxDetector2		0xc34  /* SBD & Fame Sync. */
+#define rOFDM0_RxDetector3		0xc38  /* Frame Sync. */
+#define rOFDM0_RxDetector4		0xc3c  /* PD, SBD, Frame Sync & Short-GI *=
/
+
+#define rOFDM0_RxDSP			0xc40  /* Rx Sync Path */
+#define rOFDM0_CFOandDAGC		0xc44  /* CFO & DAGC */
+#define rOFDM0_CCADropThreshold	0xc48 /* CCA Drop threshold */
+#define rOFDM0_ECCAThreshold		0xc4c /*  energy CCA */
+
+#define rOFDM0_XAAGCCore1		0xc50	/*  DIG */
+#define rOFDM0_XAAGCCore2		0xc54
+#define rOFDM0_XBAGCCore1		0xc58
+#define rOFDM0_XBAGCCore2		0xc5c
+#define rOFDM0_XCAGCCore1		0xc60
+#define rOFDM0_XCAGCCore2		0xc64
+#define rOFDM0_XDAGCCore1		0xc68
+#define rOFDM0_XDAGCCore2		0xc6c
+
+#define rOFDM0_AGCParameter1		0xc70
+#define rOFDM0_AGCParameter2		0xc74
+#define rOFDM0_AGCRSSITable		0xc78
+#define rOFDM0_HTSTFAGC			0xc7c
+
+#define rOFDM0_XATxIQImbalance		0xc80	/*  TX PWR TRACK and DIG */
+#define rOFDM0_XATxAFE			0xc84
+#define rOFDM0_XBTxIQImbalance		0xc88
+#define rOFDM0_XBTxAFE			0xc8c
+#define rOFDM0_XCTxIQImbalance		0xc90
+#define rOFDM0_XCTxAFE			0xc94
+#define rOFDM0_XDTxIQImbalance		0xc98
+#define rOFDM0_XDTxAFE			0xc9c
+
+#define rOFDM0_RxIQExtAnta		0xca0
+#define rOFDM0_TxCoeff1			0xca4
+#define rOFDM0_TxCoeff2			0xca8
+#define rOFDM0_TxCoeff3			0xcac
+#define rOFDM0_TxCoeff4			0xcb0
+#define rOFDM0_TxCoeff5			0xcb4
+#define rOFDM0_TxCoeff6			0xcb8
+#define rOFDM0_RxHPParameter		0xce0
+#define rOFDM0_TxPseudoNoiseWgt		0xce4
+#define rOFDM0_FrameSync		0xcf0
+#define rOFDM0_DFSReport		0xcf4
+
+/*  7. PageD(0xD00) */
+#define rOFDM1_LSTF			0xd00
+#define rOFDM1_TRxPathEnable		0xd04
+
+#define rOFDM1_CFO			0xd08	/*  No setting now */
+#define rOFDM1_CSI1			0xd10
+#define rOFDM1_SBD			0xd14
+#define rOFDM1_CSI2			0xd18
+#define rOFDM1_CFOTracking		0xd2c
+#define rOFDM1_TRxMesaure1		0xd34
+#define rOFDM1_IntfDet			0xd3c
+#define rOFDM1_PseudoNoiseStateAB	0xd50
+#define rOFDM1_PseudoNoiseStateCD	0xd54
+#define rOFDM1_RxPseudoNoiseWgt		0xd58
+
+#define rOFDM_PHYCounter1		0xda0  /* cca, parity fail */
+#define rOFDM_PHYCounter2		0xda4  /* rate illegal, crc8 fail */
+#define rOFDM_PHYCounter3		0xda8  /* MCS not support */
+
+#define rOFDM_ShortCFOAB		0xdac	/*  No setting now */
+#define rOFDM_ShortCFOCD		0xdb0
+#define rOFDM_LongCFOAB			0xdb4
+#define rOFDM_LongCFOCD			0xdb8
+#define rOFDM_TailCFOAB			0xdbc
+#define rOFDM_TailCFOCD			0xdc0
+#define rOFDM_PWMeasure1		0xdc4
+#define rOFDM_PWMeasure2		0xdc8
+#define rOFDM_BWReport			0xdcc
+#define rOFDM_AGCReport			0xdd0
+#define rOFDM_RxSNR			0xdd4
+#define rOFDM_RxEVMCSI			0xdd8
+#define rOFDM_SIGReport			0xddc
+
+
+/*  8. PageE(0xE00) */
+#define rTxAGC_A_Rate18_06		0xe00
+#define rTxAGC_A_Rate54_24		0xe04
+#define rTxAGC_A_CCK1_Mcs32		0xe08
+#define rTxAGC_A_Mcs03_Mcs00		0xe10
+#define rTxAGC_A_Mcs07_Mcs04		0xe14
+#define rTxAGC_A_Mcs11_Mcs08		0xe18
+#define rTxAGC_A_Mcs15_Mcs12		0xe1c
+
+#define rFPGA0_IQK			0xe28
+#define rTx_IQK_Tone_A			0xe30
+#define rRx_IQK_Tone_A			0xe34
+#define rTx_IQK_PI_A			0xe38
+#define rRx_IQK_PI_A			0xe3c
+
+#define rTx_IQK				0xe40
+#define rRx_IQK				0xe44
+#define rIQK_AGC_Pts			0xe48
+#define rIQK_AGC_Rsp			0xe4c
+#define rTx_IQK_Tone_B			0xe50
+#define rRx_IQK_Tone_B			0xe54
+#define rTx_IQK_PI_B			0xe58
+#define rRx_IQK_PI_B			0xe5c
+#define rIQK_AGC_Cont			0xe60
+
+#define rBlue_Tooth			0xe6c
+#define rRx_Wait_CCA			0xe70
+#define rTx_CCK_RFON			0xe74
+#define rTx_CCK_BBON			0xe78
+#define rTx_OFDM_RFON			0xe7c
+#define rTx_OFDM_BBON			0xe80
+#define rTx_To_Rx			0xe84
+#define rTx_To_Tx			0xe88
+#define rRx_CCK				0xe8c
+
+#define rTx_Power_Before_IQK_A		0xe94
+#define rTx_Power_After_IQK_A		0xe9c
+
+#define rRx_Power_Before_IQK_A		0xea0
+#define rRx_Power_Before_IQK_A_2	0xea4
+#define rRx_Power_After_IQK_A		0xea8
+#define rRx_Power_After_IQK_A_2		0xeac
+
+#define rTx_Power_Before_IQK_B		0xeb4
+#define rTx_Power_After_IQK_B		0xebc
+
+#define rRx_Power_Before_IQK_B		0xec0
+#define rRx_Power_Before_IQK_B_2	0xec4
+#define rRx_Power_After_IQK_B		0xec8
+#define rRx_Power_After_IQK_B_2		0xecc
+
+#define rRx_OFDM			0xed0
+#define rRx_Wait_RIFS			0xed4
+#define rRx_TO_Rx			0xed8
+#define rStandby			0xedc
+#define rSleep				0xee0
+#define rPMPD_ANAEN			0xeec
+
+/*  7. RF Register 0x00-0x2E (RF 8256) */
+/*     RF-0222D 0x00-3F */
+/* Zebra1 */
+#define rZebra1_HSSIEnable		0x0	/*  Useless now */
+#define rZebra1_TRxEnable1		0x1
+#define rZebra1_TRxEnable2		0x2
+#define rZebra1_AGC			0x4
+#define rZebra1_ChargePump		0x5
+#define rZebra1_Channel			0x7	/*  RF channel switch */
+
+#define rZebra1_TxGain			0x8	/*  Useless now */
+#define rZebra1_TxLPF			0x9
+#define rZebra1_RxLPF			0xb
+#define rZebra1_RxHPFCorner		0xc
+
+/* Zebra4 */
+#define rGlobalCtrl			0	/*  Useless now */
+#define rRTL8256_TxLPF			19
+#define rRTL8256_RxLPF			11
+
+/* RTL8258 */
+#define rRTL8258_TxLPF			0x11	/*  Useless now */
+#define rRTL8258_RxLPF			0x13
+#define rRTL8258_RSSILPF		0xa
+
+/*  RL6052 Register definition */
+#define RF_AC				0x00
+#define RF_IQADJ_G1			0x01
+#define RF_IQADJ_G2			0x02
+#define RF_BS_PA_APSET_G1_G4		0x03
+#define RF_BS_PA_APSET_G5_G8		0x04
+#define RF_POW_TRSW			0x05
+#define RF_GAIN_RX			0x06
+#define RF_GAIN_TX			0x07
+#define RF_TXM_IDAC			0x08
+#define RF_IPA_G			0x09
+#define RF_TXBIAS_G			0x0A
+#define RF_TXPA_AG			0x0B
+#define RF_IPA_A			0x0C
+#define RF_TXBIAS_A			0x0D
+#define RF_BS_PA_APSET_G9_G11		0x0E
+#define RF_BS_IQGEN			0x0F
+#define RF_MODE1			0x10
+#define RF_MODE2			0x11
+#define RF_RX_AGC_HP			0x12
+#define RF_TX_AGC			0x13
+#define RF_BIAS				0x14
+#define RF_IPA				0x15
+#define RF_TXBIAS			0x16
+#define RF_POW_ABILITY			0x17
+#define RF_MODE_AG			0x18
+#define rRfChannel			0x18	/*  RF channel and BW switch */
+#define RF_CHNLBW			0x18	/*  RF channel and BW switch */
+#define RF_TOP				0x19
+#define RF_RX_G1			0x1A
+#define RF_RX_G2			0x1B
+#define RF_RX_BB2			0x1C
+#define RF_RX_BB1			0x1D
+#define RF_RCK1				0x1E
+#define RF_RCK2				0x1F
+#define RF_TX_G1			0x20
+#define RF_TX_G2			0x21
+#define RF_TX_G3			0x22
+#define RF_TX_BB1			0x23
+#define RF_T_METER			0x24
+#define RF_SYN_G1			0x25	/*  RF TX Power control */
+#define RF_SYN_G2			0x26	/*  RF TX Power control */
+#define RF_SYN_G3			0x27	/*  RF TX Power control */
+#define RF_SYN_G4			0x28	/*  RF TX Power control */
+#define RF_SYN_G5			0x29	/*  RF TX Power control */
+#define RF_SYN_G6			0x2A	/*  RF TX Power control */
+#define RF_SYN_G7			0x2B	/*  RF TX Power control */
+#define RF_SYN_G8			0x2C	/*  RF TX Power control */
+
+#define RF_RCK_OS			0x30	/*  RF TX PA control */
+
+#define RF_TXPA_G1			0x31	/*  RF TX PA control */
+#define RF_TXPA_G2			0x32	/*  RF TX PA control */
+#define RF_TXPA_G3			0x33	/*  RF TX PA control */
+
+/* Bit Mask */
+/*  1. Page1(0x100) */
+#define bBBResetB			0x100	/*  Useless now? */
+#define bGlobalResetB			0x200
+#define bOFDMTxStart			0x4
+#define bCCKTxStart			0x8
+#define bCRC32Debug			0x100
+#define bPMACLoopback			0x10
+#define bTxLSIG				0xffffff
+#define bOFDMTxRate			0xf
+#define bOFDMTxReserved			0x10
+#define bOFDMTxLength			0x1ffe0
+#define bOFDMTxParity			0x20000
+#define bTxHTSIG1			0xffffff
+#define bTxHTMCSRate			0x7f
+#define bTxHTBW				0x80
+#define bTxHTLength			0xffff00
+#define bTxHTSIG2			0xffffff
+#define bTxHTSmoothing			0x1
+#define bTxHTSounding			0x2
+#define bTxHTReserved			0x4
+#define bTxHTAggreation			0x8
+#define bTxHTSTBC			0x30
+#define bTxHTAdvanceCoding		0x40
+#define bTxHTShortGI			0x80
+#define bTxHTNumberHT_LTF		0x300
+#define bTxHTCRC8			0x3fc00
+#define bCounterReset			0x10000
+#define bNumOfOFDMTx			0xffff
+#define bNumOfCCKTx			0xffff0000
+#define bTxIdleInterval			0xffff
+#define bOFDMService			0xffff0000
+#define bTxMACHeader			0xffffffff
+#define bTxDataInit			0xff
+#define bTxHTMode			0x100
+#define bTxDataType			0x30000
+#define bTxRandomSeed			0xffffffff
+#define bCCKTxPreamble			0x1
+#define bCCKTxSFD			0xffff0000
+#define bCCKTxSIG			0xff
+#define bCCKTxService			0xff00
+#define bCCKLengthExt			0x8000
+#define bCCKTxLength			0xffff0000
+#define bCCKTxCRC16			0xffff
+#define bCCKTxStatus			0x1
+#define bOFDMTxStatus			0x2
+
+#define IS_BB_REG_OFFSET_92S(_Offset)			\
+	((_Offset >=3D 0x800) && (_Offset <=3D 0xfff))
+
+/*  2. Page8(0x800) */
+#define bRFMOD				0x1	/*  Reg 0x800 rFPGA0_RFMOD */
+#define bJapanMode			0x2
+#define bCCKTxSC			0x30
+#define bCCKEn				0x1000000
+#define bOFDMEn				0x2000000
+
+#define bOFDMRxADCPhase			0x10000	/*  Useless now */
+#define bOFDMTxDACPhase			0x40000
+#define bXATxAGC			0x3f
+
+#define bAntennaSelect			0x0300
+
+#define bXBTxAGC			0xf00	/*  Reg 80c rFPGA0_TxGainStage */
+#define bXCTxAGC			0xf000
+#define bXDTxAGC			0xf0000
+
+#define bPAStart			0xf0000000	/*  Useless now */
+#define bTRStart			0x00f00000
+#define bRFStart			0x0000f000
+#define bBBStart			0x000000f0
+#define bBBCCKStart			0x0000000f
+#define bPAEnd				0xf          /* Reg0x814 */
+#define bTREnd				0x0f000000
+#define bRFEnd				0x000f0000
+#define bCCAMask			0x000000f0   /* T2R */
+#define bR2RCCAMask			0x00000f00
+#define bHSSI_R2TDelay			0xf8000000
+#define bHSSI_T2RDelay			0xf80000
+#define bContTxHSSI			0x400     /* chane gain at continue Tx */
+#define bIGFromCCK			0x200
+#define bAGCAddress			0x3f
+#define bRxHPTx				0x7000
+#define bRxHPT2R			0x38000
+#define bRxHPCCKIni			0xc0000
+#define bAGCTxCode			0xc00000
+#define bAGCRxCode			0x300000
+
+#define b3WireDataLength		0x800	/*  Reg 0x820~84f rFPGA0_XA_HSSIParame=
ter1 */
+#define b3WireAddressLength		0x400
+
+#define b3WireRFPowerDown		0x1	/*  Useless now */
+/* define bHWSISelect			0x8 */
+#define b5GPAPEPolarity			0x40000000
+#define b2GPAPEPolarity			0x80000000
+#define bRFSW_TxDefaultAnt		0x3
+#define bRFSW_TxOptionAnt		0x30
+#define bRFSW_RxDefaultAnt		0x300
+#define bRFSW_RxOptionAnt		0x3000
+#define bRFSI_3WireData			0x1
+#define bRFSI_3WireClock		0x2
+#define bRFSI_3WireLoad			0x4
+#define bRFSI_3WireRW			0x8
+#define bRFSI_3Wire			0xf
+
+#define bRFSI_RFENV			0x10	/*  Reg 0x870 rFPGA0_XAB_RFInterfaceSW */
+
+#define bRFSI_TRSW			0x20	/*  Useless now */
+#define bRFSI_TRSWB			0x40
+#define bRFSI_ANTSW			0x100
+#define bRFSI_ANTSWB			0x200
+#define bRFSI_PAPE			0x400
+#define bRFSI_PAPE5G			0x800
+#define bBandSelect			0x1
+#define bHTSIG2_GI			0x80
+#define bHTSIG2_Smoothing		0x01
+#define bHTSIG2_Sounding		0x02
+#define bHTSIG2_Aggreaton		0x08
+#define bHTSIG2_STBC			0x30
+#define bHTSIG2_AdvCoding		0x40
+#define bHTSIG2_NumOfHTLTF		0x300
+#define bHTSIG2_CRC8			0x3fc
+#define bHTSIG1_MCS			0x7f
+#define bHTSIG1_BandWidth		0x80
+#define bHTSIG1_HTLength		0xffff
+#define bLSIG_Rate			0xf
+#define bLSIG_Reserved			0x10
+#define bLSIG_Length			0x1fffe
+#define bLSIG_Parity			0x20
+#define bCCKRxPhase			0x4
+
+#define bLSSIReadAddress		0x7f800000   /*  T65 RF */
+
+#define bLSSIReadEdge			0x80000000   /* LSSI "Read" edge signal */
+
+#define bLSSIReadBackData		0xfffff		/*  T65 RF */
+
+#define bLSSIReadOKFlag			0x1000	/*  Useless now */
+#define bCCKSampleRate			0x8       /* 0: 44MHz, 1:88MHz */
+#define bRegulator0Standby		0x1
+#define bRegulatorPLLStandby		0x2
+#define bRegulator1Standby		0x4
+#define bPLLPowerUp			0x8
+#define bDPLLPowerUp			0x10
+#define bDA10PowerUp			0x20
+#define bAD7PowerUp			0x200
+#define bDA6PowerUp			0x2000
+#define bXtalPowerUp			0x4000
+#define b40MDClkPowerUP			0x8000
+#define bDA6DebugMode			0x20000
+#define bDA6Swing			0x380000
+
+#define bADClkPhase			0x4000000	/*  Reg 0x880 rFPGA0_AnalogParameter1 =
20/40 CCK support switch 40/80 BB MHZ */
+
+#define b80MClkDelay			0x18000000	/*  Useless */
+#define bAFEWatchDogEnable		0x20000000
+
+#define bXtalCap01			0xc0000000	/*  Reg 0x884 rFPGA0_AnalogParameter2 =
Crystal cap */
+#define bXtalCap23			0x3
+#define bXtalCap92x			0x0f000000
+#define		bXtalCap		0x0f000000
+
+#define bIntDifClkEnable		0x400	/*  Useless */
+#define bExtSigClkEnable		0x800
+#define bBandgapMbiasPowerUp		0x10000
+#define bAD11SHGain			0xc0000
+#define bAD11InputRange			0x700000
+#define bAD11OPCurrent			0x3800000
+#define bIPathLoopback			0x4000000
+#define bQPathLoopback			0x8000000
+#define bAFELoopback			0x10000000
+#define bDA10Swing			0x7e0
+#define bDA10Reverse			0x800
+#define bDAClkSource			0x1000
+#define bAD7InputRange			0x6000
+#define bAD7Gain			0x38000
+#define bAD7OutputCMMode		0x40000
+#define bAD7InputCMMode			0x380000
+#define bAD7Current			0xc00000
+#define bRegulatorAdjust		0x7000000
+#define bAD11PowerUpAtTx		0x1
+#define bDA10PSAtTx			0x10
+#define bAD11PowerUpAtRx		0x100
+#define bDA10PSAtRx			0x1000
+#define bCCKRxAGCFormat			0x200
+#define bPSDFFTSamplepPoint		0xc000
+#define bPSDAverageNum			0x3000
+#define bIQPathControl			0xc00
+#define bPSDFreq			0x3ff
+#define bPSDAntennaPath			0x30
+#define bPSDIQSwitch			0x40
+#define bPSDRxTrigger			0x400000
+#define bPSDTxTrigger			0x80000000
+#define bPSDSineToneScale		0x7f000000
+#define bPSDReport			0xffff
+
+/*  3. Page9(0x900) */
+#define bOFDMTxSC			0x30000000	/*  Useless */
+#define bCCKTxOn			0x1
+#define bOFDMTxOn			0x2
+#define bDebugPage			0xfff  /* reset debug page and also HWord, LWord =
*/
+#define bDebugItem			0xff   /* reset debug page and LWord */
+#define bAntL				0x10
+#define bAntNonHT			0x100
+#define bAntHT1				0x1000
+#define bAntHT2				0x10000
+#define bAntHT1S1			0x100000
+#define bAntNonHTS1			0x1000000
+
+/*  4. PageA(0xA00) */
+#define bCCKBBMode			0x3	/*  Useless */
+#define bCCKTxPowerSaving		0x80
+#define bCCKRxPowerSaving		0x40
+
+#define bCCKSideBand			0x10	/*  Reg 0xa00 rCCK0_System 20/40 switch */
+
+#define bCCKScramble			0x8	/*  Useless */
+#define bCCKAntDiversity		0x8000
+#define bCCKCarrierRecovery		0x4000
+#define bCCKTxRate			0x3000
+#define bCCKDCCancel			0x0800
+#define bCCKISICancel			0x0400
+#define bCCKMatchFilter			0x0200
+#define bCCKEqualizer			0x0100
+#define bCCKPreambleDetect		0x800000
+#define bCCKFastFalseCCA		0x400000
+#define bCCKChEstStart			0x300000
+#define bCCKCCACount			0x080000
+#define bCCKcs_lim			0x070000
+#define bCCKBistMode			0x80000000
+#define bCCKCCAMask			0x40000000
+#define bCCKTxDACPhase			0x4
+#define bCCKRxADCPhase			0x20000000   /* r_rx_clk */
+#define bCCKr_cp_mode0			0x0100
+#define bCCKTxDCOffset			0xf0
+#define bCCKRxDCOffset			0xf
+#define bCCKCCAMode			0xc000
+#define bCCKFalseCS_lim			0x3f00
+#define bCCKCS_ratio			0xc00000
+#define bCCKCorgBit_sel			0x300000
+#define bCCKPD_lim			0x0f0000
+#define bCCKNewCCA			0x80000000
+#define bCCKRxHPofIG			0x8000
+#define bCCKRxIG			0x7f00
+#define bCCKLNAPolarity			0x800000
+#define bCCKRx1stGain			0x7f0000
+#define bCCKRFExtend			0x20000000 /* CCK Rx Iinital gain polarity */
+#define bCCKRxAGCSatLevel		0x1f000000
+#define bCCKRxAGCSatCount		0xe0
+#define bCCKRxRFSettle			0x1f       /* AGCsamp_dly */
+#define bCCKFixedRxAGC			0x8000
+/* define bCCKRxAGCFormat		0x4000   remove to HSSI register 0x824 */
+#define bCCKAntennaPolarity		0x2000
+#define bCCKTxFilterType		0x0c00
+#define bCCKRxAGCReportType		0x0300
+#define bCCKRxDAGCEn			0x80000000
+#define bCCKRxDAGCPeriod		0x20000000
+#define bCCKRxDAGCSatLevel		0x1f000000
+#define bCCKTimingRecovery		0x800000
+#define bCCKTxC0			0x3f0000
+#define bCCKTxC1			0x3f000000
+#define bCCKTxC2			0x3f
+#define bCCKTxC3			0x3f00
+#define bCCKTxC4			0x3f0000
+#define bCCKTxC5			0x3f000000
+#define bCCKTxC6			0x3f
+#define bCCKTxC7			0x3f00
+#define bCCKDebugPort			0xff0000
+#define bCCKDACDebug			0x0f000000
+#define bCCKFalseAlarmEnable		0x8000
+#define bCCKFalseAlarmRead		0x4000
+#define bCCKTRSSI			0x7f
+#define bCCKRxAGCReport			0xfe
+#define bCCKRxReport_AntSel		0x80000000
+#define bCCKRxReport_MFOff		0x40000000
+#define bCCKRxRxReport_SQLoss		0x20000000
+#define bCCKRxReport_Pktloss		0x10000000
+#define bCCKRxReport_Lockedbit		0x08000000
+#define bCCKRxReport_RateError		0x04000000
+#define bCCKRxReport_RxRate		0x03000000
+#define bCCKRxFACounterLower		0xff
+#define bCCKRxFACounterUpper		0xff000000
+#define bCCKRxHPAGCStart		0xe000
+#define bCCKRxHPAGCFinal		0x1c00
+#define bCCKRxFalseAlarmEnable		0x8000
+#define bCCKFACounterFreeze		0x4000
+#define bCCKTxPathSel			0x10000000
+#define bCCKDefaultRxPath		0xc000000
+#define bCCKOptionRxPath		0x3000000
+
+/*  5. PageC(0xC00) */
+#define bNumOfSTF			0x3	/*  Useless */
+#define bShift_L			0xc0
+#define bGI_TH				0xc
+#define bRxPathA			0x1
+#define bRxPathB			0x2
+#define bRxPathC			0x4
+#define bRxPathD			0x8
+#define bTxPathA			0x1
+#define bTxPathB			0x2
+#define bTxPathC			0x4
+#define bTxPathD			0x8
+#define bTRSSIFreq			0x200
+#define bADCBackoff			0x3000
+#define bDFIRBackoff			0xc000
+#define bTRSSILatchPhase		0x10000
+#define bRxIDCOffset			0xff
+#define bRxQDCOffset			0xff00
+#define bRxDFIRMode			0x1800000
+#define bRxDCNFType			0xe000000
+#define bRXIQImb_A			0x3ff
+#define bRXIQImb_B			0xfc00
+#define bRXIQImb_C			0x3f0000
+#define bRXIQImb_D			0xffc00000
+#define bDC_dc_Notch			0x60000
+#define bRxNBINotch			0x1f000000
+#define bPD_TH				0xf
+#define bPD_TH_Opt2			0xc000
+#define bPWED_TH			0x700
+#define bIfMF_Win_L			0x800
+#define bPD_Option			0x1000
+#define bMF_Win_L			0xe000
+#define bBW_Search_L			0x30000
+#define bwin_enh_L			0xc0000
+#define bBW_TH				0x700000
+#define bED_TH2				0x3800000
+#define bBW_option			0x4000000
+#define bRatio_TH			0x18000000
+#define bWindow_L			0xe0000000
+#define bSBD_Option			0x1
+#define bFrame_TH			0x1c
+#define bFS_Option			0x60
+#define bDC_Slope_check			0x80
+#define bFGuard_Counter_DC_L		0xe00
+#define bFrame_Weight_Short		0x7000
+#define bSub_Tune			0xe00000
+#define bFrame_DC_Length		0xe000000
+#define bSBD_start_offset		0x30000000
+#define bFrame_TH_2			0x7
+#define bFrame_GI2_TH			0x38
+#define bGI2_Sync_en			0x40
+#define bSarch_Short_Early		0x300
+#define bSarch_Short_Late		0xc00
+#define bSarch_GI2_Late			0x70000
+#define bCFOAntSum			0x1
+#define bCFOAcc				0x2
+#define bCFOStartOffset			0xc
+#define bCFOLookBack			0x70
+#define bCFOSumWeight			0x80
+#define bDAGCEnable			0x10000
+#define bTXIQImb_A			0x3ff
+#define bTXIQImb_B			0xfc00
+#define bTXIQImb_C			0x3f0000
+#define bTXIQImb_D			0xffc00000
+#define bTxIDCOffset			0xff
+#define bTxQDCOffset			0xff00
+#define bTxDFIRMode			0x10000
+#define bTxPesudoNoiseOn		0x4000000
+#define bTxPesudoNoise_A		0xff
+#define bTxPesudoNoise_B		0xff00
+#define bTxPesudoNoise_C		0xff0000
+#define bTxPesudoNoise_D		0xff000000
+#define bCCADropOption			0x20000
+#define bCCADropThres			0xfff00000
+#define bEDCCA_H			0xf
+#define bEDCCA_L			0xf0
+#define bLambda_ED			0x300
+#define bRxInitialGain			0x7f
+#define bRxAntDivEn			0x80
+#define bRxAGCAddressForLNA		0x7f00
+#define bRxHighPowerFlow		0x8000
+#define bRxAGCFreezeThres		0xc0000
+#define bRxFreezeStep_AGC1		0x300000
+#define bRxFreezeStep_AGC2		0xc00000
+#define bRxFreezeStep_AGC3		0x3000000
+#define bRxFreezeStep_AGC0		0xc000000
+#define bRxRssi_Cmp_En			0x10000000
+#define bRxQuickAGCEn			0x20000000
+#define bRxAGCFreezeThresMode		0x40000000
+#define bRxOverFlowCheckType		0x80000000
+#define bRxAGCShift			0x7f
+#define bTRSW_Tri_Only			0x80
+#define bPowerThres			0x300
+#define bRxAGCEn			0x1
+#define bRxAGCTogetherEn		0x2
+#define bRxAGCMin			0x4
+#define bRxHP_Ini			0x7
+#define bRxHP_TRLNA			0x70
+#define bRxHP_RSSI			0x700
+#define bRxHP_BBP1			0x7000
+#define bRxHP_BBP2			0x70000
+#define bRxHP_BBP3			0x700000
+#define bRSSI_H				0x7f0000     /* the threshold for high power */
+#define bRSSI_Gen			0x7f000000   /* the threshold for ant diversity */
+#define bRxSettle_TRSW			0x7
+#define bRxSettle_LNA			0x38
+#define bRxSettle_RSSI			0x1c0
+#define bRxSettle_BBP			0xe00
+#define bRxSettle_RxHP			0x7000
+#define bRxSettle_AntSW_RSSI		0x38000
+#define bRxSettle_AntSW			0xc0000
+#define bRxProcessTime_DAGC		0x300000
+#define bRxSettle_HSSI			0x400000
+#define bRxProcessTime_BBPPW		0x800000
+#define bRxAntennaPowerShift		0x3000000
+#define bRSSITableSelect		0xc000000
+#define bRxHP_Final			0x7000000
+#define bRxHTSettle_BBP			0x7
+#define bRxHTSettle_HSSI		0x8
+#define bRxHTSettle_RxHP		0x70
+#define bRxHTSettle_BBPPW		0x80
+#define bRxHTSettle_Idle		0x300
+#define bRxHTSettle_Reserved		0x1c00
+#define bRxHTRxHPEn			0x8000
+#define bRxHTAGCFreezeThres		0x30000
+#define bRxHTAGCTogetherEn		0x40000
+#define bRxHTAGCMin			0x80000
+#define bRxHTAGCEn			0x100000
+#define bRxHTDAGCEn			0x200000
+#define bRxHTRxHP_BBP			0x1c00000
+#define bRxHTRxHP_Final			0xe0000000
+#define bRxPWRatioTH			0x3
+#define bRxPWRatioEn			0x4
+#define bRxMFHold			0x3800
+#define bRxPD_Delay_TH1			0x38
+#define bRxPD_Delay_TH2			0x1c0
+#define bRxPD_DC_COUNT_MAX		0x600
+/* define bRxMF_Hold           	    0x3800 */
+#define bRxPD_Delay_TH			0x8000
+#define bRxProcess_Delay		0xf0000
+#define bRxSearchrange_GI2_Early	0x700000
+#define bRxFrame_Guard_Counter_L	0x3800000
+#define bRxSGI_Guard_L			0xc000000
+#define bRxSGI_Search_L			0x30000000
+#define bRxSGI_TH			0xc0000000
+#define bDFSCnt0			0xff
+#define bDFSCnt1			0xff00
+#define bDFSFlag			0xf0000
+#define bMFWeightSum			0x300000
+#define bMinIdxTH			0x7f000000
+#define bDAFormat			0x40000
+#define bTxChEmuEnable			0x01000000
+#define bTRSWIsolation_A		0x7f
+#define bTRSWIsolation_B		0x7f00
+#define bTRSWIsolation_C		0x7f0000
+#define bTRSWIsolation_D		0x7f000000
+#define bExtLNAGain			0x7c00
+
+/*  6. PageE(0xE00) */
+#define bSTBCEn				0x4	/*  Useless */
+#define bAntennaMapping			0x10
+#define bNss				0x20
+#define bCFOAntSumD			0x200
+#define bPHYCounterReset		0x8000000
+#define bCFOReportGet			0x4000000
+#define bOFDMContinueTx			0x10000000
+#define bOFDMSingleCarrier		0x20000000
+#define bOFDMSingleTone			0x40000000
+/* define bRxPath1                 0x01 */
+/* define bRxPath2                 0x02 */
+/* define bRxPath3                 0x04 */
+/* define bRxPath4                 0x08 */
+/* define bTxPath1                 0x10 */
+/* define bTxPath2                 0x20 */
+#define bHTDetect			0x100
+#define bCFOEn				0x10000
+#define bCFOValue			0xfff00000
+#define bSigTone_Re			0x3f
+#define bSigTone_Im			0x7f00
+#define bCounter_CCA			0xffff
+#define bCounter_ParityFail		0xffff0000
+#define bCounter_RateIllegal		0xffff
+#define bCounter_CRC8Fail		0xffff0000
+#define bCounter_MCSNoSupport		0xffff
+#define bCounter_FastSync		0xffff
+#define bShortCFO			0xfff
+#define bShortCFOTLength		12   /* total */
+#define bShortCFOFLength		11   /* fraction */
+#define bLongCFO			0x7ff
+#define bLongCFOTLength			11
+#define bLongCFOFLength			11
+#define bTailCFO			0x1fff
+#define bTailCFOTLength			13
+#define bTailCFOFLength			12
+#define bmax_en_pwdB			0xffff
+#define bCC_power_dB			0xffff0000
+#define bnoise_pwdB			0xffff
+#define bPowerMeasTLength		10
+#define bPowerMeasFLength		3
+#define bRx_HT_BW			0x1
+#define bRxSC				0x6
+#define bRx_HT				0x8
+#define bNB_intf_det_on			0x1
+#define bIntf_win_len_cfg		0x30
+#define bNB_Intf_TH_cfg			0x1c0
+#define bRFGain				0x3f
+#define bTableSel			0x40
+#define bTRSW				0x80
+#define bRxSNR_A			0xff
+#define bRxSNR_B			0xff00
+#define bRxSNR_C			0xff0000
+#define bRxSNR_D			0xff000000
+#define bSNREVMTLength			8
+#define bSNREVMFLength			1
+#define bCSI1st				0xff
+#define bCSI2nd				0xff00
+#define bRxEVM1st			0xff0000
+#define bRxEVM2nd			0xff000000
+#define bSIGEVM				0xff
+#define bPWDB				0xff00
+#define bSGIEN				0x10000
+
+#define bSFactorQAM1			0xf	/*  Useless */
+#define bSFactorQAM2			0xf0
+#define bSFactorQAM3			0xf00
+#define bSFactorQAM4			0xf000
+#define bSFactorQAM5			0xf0000
+#define bSFactorQAM6			0xf0000
+#define bSFactorQAM7			0xf00000
+#define bSFactorQAM8			0xf000000
+#define bSFactorQAM9			0xf0000000
+#define bCSIScheme			0x100000
+
+#define bNoiseLvlTopSet			0x3	/*  Useless */
+#define bChSmooth			0x4
+#define bChSmoothCfg1			0x38
+#define bChSmoothCfg2			0x1c0
+#define bChSmoothCfg3			0xe00
+#define bChSmoothCfg4			0x7000
+#define bMRCMode			0x800000
+#define bTHEVMCfg			0x7000000
+
+#define bLoopFitType			0x1	/*  Useless */
+#define bUpdCFO				0x40
+#define bUpdCFOOffData			0x80
+#define bAdvUpdCFO			0x100
+#define bAdvTimeCtrl			0x800
+#define bUpdClko			0x1000
+#define bFC				0x6000
+#define bTrackingMode			0x8000
+#define bPhCmpEnable			0x10000
+#define bUpdClkoLTF			0x20000
+#define bComChCFO			0x40000
+#define bCSIEstiMode			0x80000
+#define bAdvUpdEqz			0x100000
+#define bUChCfg				0x7000000
+#define bUpdEqz				0x8000000
+
+/* Rx Pseduo noise */
+#define bRxPesudoNoiseOn		0x20000000	/*  Useless */
+#define bRxPesudoNoise_A		0xff
+#define bRxPesudoNoise_B		0xff00
+#define bRxPesudoNoise_C		0xff0000
+#define bRxPesudoNoise_D		0xff000000
+#define bPesudoNoiseState_A		0xffff
+#define bPesudoNoiseState_B		0xffff0000
+#define bPesudoNoiseState_C		0xffff
+#define bPesudoNoiseState_D		0xffff0000
+
+/* 7. RF Register */
+/* Zebra1 */
+#define bZebra1_HSSIEnable		0x8		/*  Useless */
+#define bZebra1_TRxControl		0xc00
+#define bZebra1_TRxGainSetting		0x07f
+#define bZebra1_RxCorner		0xc00
+#define bZebra1_TxChargePump		0x38
+#define bZebra1_RxChargePump		0x7
+#define bZebra1_ChannelNum		0xf80
+#define bZebra1_TxLPFBW			0x400
+#define bZebra1_RxLPFBW			0x600
+
+/* Zebra4 */
+#define bRTL8256RegModeCtrl1		0x100	/*  Useless */
+#define bRTL8256RegModeCtrl0		0x40
+#define bRTL8256_TxLPFBW		0x18
+#define bRTL8256_RxLPFBW		0x600
+
+/* RTL8258 */
+#define bRTL8258_TxLPFBW		0xc	/*  Useless */
+#define bRTL8258_RxLPFBW		0xc00
+#define bRTL8258_RSSILPFBW		0xc0
+
+
+/*  Other Definition */
+
+/* byte endable for sb_write */
+#define bByte0				0x1	/*  Useless */
+#define bByte1				0x2
+#define bByte2				0x4
+#define bByte3				0x8
+#define bWord0				0x3
+#define bWord1				0xc
+#define bDWord				0xf
+
+/* for PutRegsetting & GetRegSetting BitMask */
+#define bMaskByte0			0xff	/*  Reg 0xc50 rOFDM0_XAAGCCore~0xC6f */
+#define bMaskByte1			0xff00
+#define bMaskByte2			0xff0000
+#define bMaskByte3			0xff000000
+#define bMaskHWord			0xffff0000
+#define bMaskLWord			0x0000ffff
+#define bMaskDWord			0xffffffff
+#define bMask12Bits			0xfff
+#define bMaskH4Bits			0xf0000000
+#define bMaskOFDM_D			0xffc00000
+#define bMaskCCK			0x3f3f3f3f
+
+/* for PutRFRegsetting & GetRFRegSetting BitMask */
+#define		bRFRegOffsetMask	0xfffff
+
+#define bDisable			0x0
+
+#define LeftAntenna			0x0	/*  Useless */
+#define RightAntenna			0x1
+
+#define tCheckTxStatus			500   /* 500ms Useless */
+#define tUpdateRxCounter		100   /* 100ms */
+
+#define rateCCK				0	/*  Useless */
+#define rateOFDM			1
+#define rateHT				2
+
+/* define Register-End */
+#define bPMAC_End			0x1ff	/*  Useless */
+#define bFPGAPHY0_End			0x8ff
+#define bFPGAPHY1_End			0x9ff
+#define bCCKPHY0_End			0xaff
+#define bOFDMPHY0_End			0xcff
+#define bOFDMPHY1_End			0xdff
+
+/* define max debug item in each debug page */
+/* define bMaxItem_FPGA_PHY0        0x9 */
+/* define bMaxItem_FPGA_PHY1        0x3 */
+/* define bMaxItem_PHY_11B          0x16 */
+/* define bMaxItem_OFDM_PHY0        0x29 */
+/* define bMaxItem_OFDM_PHY1        0x0 */
+
+#define bPMACControl			0x0	/*  Useless */
+#define bWMACControl			0x1
+#define bWNICControl			0x2
+
+#define PathA				0x0	/*  Useless */
+#define PathB				0x1
+#define PathC				0x2
+#define PathD				0x3
+
+/*  PageB(0xB00) */
+#define rPdp_AntA			0xb00
+#define rPdp_AntA_4			0xb04
+#define rPdp_AntA_8			0xb08
+#define rPdp_AntA_C			0xb0c
+#define rPdp_AntA_18			0xb18
+#define rPdp_AntA_1C			0xb1c
+#define rPdp_AntA_20			0xb20
+#define rPdp_AntA_24			0xb24
+
+#define rConfig_Pmpd_AntA		0xb28
+#define rConfig_ram64x16		0xb2c
+
+#define rBndA				0xb30
+#define rHssiPar			0xb34
+
+#define rConfig_AntA			0xb68
+#define rConfig_AntB			0xb6c
+
+#define rPdp_AntB			0xb70
+#define rPdp_AntB_4			0xb74
+#define rPdp_AntB_8			0xb78
+#define rPdp_AntB_C			0xb7c
+#define rPdp_AntB_10			0xb80
+#define rPdp_AntB_14			0xb84
+#define rPdp_AntB_18			0xb88
+#define rPdp_AntB_1C			0xb8c
+#define rPdp_AntB_20			0xb90
+#define rPdp_AntB_24			0xb94
+
+#define rConfig_Pmpd_AntB		0xb98
+
+#define rBndB				0xba0
+
+#define rAPK				0xbd8
+#define rPm_Rx0_AntA			0xbdc
+#define rPm_Rx1_AntA			0xbe0
+#define rPm_Rx2_AntA			0xbe4
+#define rPm_Rx3_AntA			0xbe8
+#define rPm_Rx0_AntB			0xbec
+#define rPm_Rx1_AntB			0xbf0
+#define rPm_Rx2_AntB			0xbf4
+#define rPm_Rx3_AntB			0xbf8
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/Hal8723PwrSeq.h b/driver=
s/staging/rtl8723au/include/Hal8723PwrSeq.h
new file mode 100644
index 0000000..7f3bdea
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/Hal8723PwrSeq.h
@@ -0,0 +1,150 @@
+#ifndef __HAL8723PWRSEQ_H__
+#define __HAL8723PWRSEQ_H__
+/*
+	Check document WM-20110607-Paul-RTL8723A_Power_Architecture-R02.vsd
+	There are 6 HW Power States:
+	0: POFF--Power Off
+	1: PDN--Power Down
+	2: CARDEMU--Card Emulation
+	3: ACT--Active Mode
+	4: LPS--Low Power State
+	5: SUS--Suspend
+
+	The transision from different states are defined below
+	TRANS_CARDEMU_TO_ACT
+	TRANS_ACT_TO_CARDEMU
+	TRANS_CARDEMU_TO_SUS
+	TRANS_SUS_TO_CARDEMU
+	TRANS_CARDEMU_TO_PDN
+	TRANS_ACT_TO_LPS
+	TRANS_LPS_TO_ACT
+
+	TRANS_END
+*/
+#include "HalPwrSeqCmd.h"
+#include "rtl8723a_spec.h"
+
+#define	RTL8723A_TRANS_CARDEMU_TO_ACT_STEPS	15
+#define	RTL8723A_TRANS_ACT_TO_CARDEMU_STEPS	15
+#define	RTL8723A_TRANS_CARDEMU_TO_SUS_STEPS	15
+#define	RTL8723A_TRANS_SUS_TO_CARDEMU_STEPS	15
+#define	RTL8723A_TRANS_CARDEMU_TO_PDN_STEPS	15
+#define	RTL8723A_TRANS_PDN_TO_CARDEMU_STEPS	15
+#define	RTL8723A_TRANS_ACT_TO_LPS_STEPS	15
+#define	RTL8723A_TRANS_LPS_TO_ACT_STEPS	15
+#define	RTL8723A_TRANS_END_STEPS	1
+
+
+/* format
+ * { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },  =
comments here
+ */
+#define RTL8723A_TRANS_CARDEMU_TO_ACT														\
+	{0x0020, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK|PWR_INTF_=
SDIO_MSK, PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0, BIT0}, /*0x20[0] =3D 1=
b'1 enable LDOA12 MACRO block for all interface*/   \
+	{0x0067, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK|PWR_INTF_=
SDIO_MSK, PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT4, 0}, /*0x67[0] =3D 0 to=
 disable BT_GPS_SEL pins*/	\
+	{0x0001, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK|PWR_INTF_=
SDIO_MSK, PWR_BASEADDR_MAC, PWR_CMD_DELAY, 1, PWRSEQ_DELAY_MS},/*Delay =
1ms*/   \
+	{0x0000, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK|PWR_INTF_=
SDIO_MSK, PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT5, 0}, /*0x00[5] =3D 1b'0=
 release analog Ips to digital , 1:isolation*/   \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT2, 0},/* disable SW LPS 0x04[10]=3D 0*/	\
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_POLLING, BIT1, BIT1},/* wait till 0x04[17] =3D 1    p=
ower ready*/	\
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT0, BIT0},/* release WLON reset  0x04[16]=3D=
 1*/	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT7, 0},/* disable HWPDN 0x04[15]=3D 0*/	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, (BIT4|BIT3), 0},/* disable WL suspend*/	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT0, BIT0},/* polling until return 0*/	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_POLLING, BIT0, 0},/**/	\
+	{0x004E, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT7, 1},/*0x4C[23] =3D 0x4E[7] =3D 1, switch =
DPDT_SEL_P output from WL BB */\
+
+#define RTL8723A_TRANS_ACT_TO_CARDEMU													\
+	{0x001F, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, 0xFF, 0},/*0x1F[7:0] =3D 0 turn off RF*/	\
+	{0x004E, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT7, 0},/*0x4C[23] =3D 0x4E[7] =3D 0, switch =
DPDT_SEL_P output from register 0x65[2] */\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT1, BIT1}, /*0x04[9] =3D 1 turn off MAC by H=
W state machine*/	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_POLLING, BIT1, 0}, /*wait till 0x04[9] =3D 0 polling =
until return 0 to disable*/	\
+	{0x0000, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK|PWR_INTF_=
SDIO_MSK, PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT5, BIT5}, /*0x00[5] =3D 1=
b'1 analog Ips to digital , 1:isolation*/   \
+	{0x0020, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK|PWR_INTF_=
SDIO_MSK, PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0, 0}, /*0x20[0] =3D 1b'0=
 disable LDOA12 MACRO block*/   \
+
+
+#define RTL8723A_TRANS_CARDEMU_TO_SUS													\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT4|BIT3, (BIT4|BIT3)}, /*0x04[12:11] =3D 2b'=
11 enable WL suspend for PCIe*/	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK|PWR_INTF_=
SDIO_MSK, PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT3|BIT4, BIT3}, /*0x04[12:=
11] =3D 2b'01 enable WL suspend*/	\
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK, PWR_BAS=
EADDR_MAC, PWR_CMD_WRITE, BIT4, BIT4}, /*0x23[4] =3D 1b'1 12H LDO enter=
 sleep mode*/   \
+	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK, PWR_BAS=
EADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x20}, /*0x07[7:0] =3D 0x20 SDIO SOP op=
tion to disable BG/MB/ACK/SWR*/   \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT3|BIT4, BIT3|BIT4}, /*0x04[12:11] =3D 2b'11=
 enable WL suspend for PCIe*/	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK, PWR_BAS=
EADDR_SDIO, PWR_CMD_WRITE, BIT0, BIT0}, /*Set SDIO suspend local regist=
er*/	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK, PWR_BAS=
EADDR_SDIO, PWR_CMD_POLLING, BIT1, 0}, /*wait power state to suspend*/
+
+#define RTL8723A_TRANS_SUS_TO_CARDEMU													\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT3 | BIT7, 0}, /*clear suspend enable and po=
wer down enable*/	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK, PWR_BAS=
EADDR_SDIO, PWR_CMD_WRITE, BIT0, 0}, /*Set SDIO suspend local register*=
/	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK, PWR_BAS=
EADDR_SDIO, PWR_CMD_POLLING, BIT1, BIT1}, /*wait power state to suspend=
*/\
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK, PWR_BAS=
EADDR_MAC, PWR_CMD_WRITE, BIT4, 0}, /*0x23[4] =3D 1b'0 12H LDO enter no=
rmal mode*/   \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT3|BIT4, 0}, /*0x04[12:11] =3D 2b'01enable W=
L suspend*/
+
+#define RTL8723A_TRANS_CARDEMU_TO_CARDDIS													\
+	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK, PWR_BAS=
EADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x20}, /*0x07 =3D 0x20 , SOP option to =
disable BG/MB*/	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK|PWR_INTF_=
SDIO_MSK, PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT3|BIT4, BIT3}, /*0x04[12:=
11] =3D 2b'01 enable WL suspend*/	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT2, BIT2}, /*0x04[10] =3D 1, enable SW LPS*/=
	\
+	{0x004A, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT0, 1}, /*0x48[16] =3D 1 to enable GPIO9 as =
EXT WAKEUP*/   \
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK, PWR_BAS=
EADDR_MAC, PWR_CMD_WRITE, BIT4, BIT4}, /*0x23[4] =3D 1b'1 12H LDO enter=
 sleep mode*/   \
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK, PWR_BAS=
EADDR_SDIO, PWR_CMD_WRITE, BIT0, BIT0}, /*Set SDIO suspend local regist=
er*/	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK, PWR_BAS=
EADDR_SDIO, PWR_CMD_POLLING, BIT1, 0}, /*wait power state to suspend*/
+
+#define RTL8723A_TRANS_CARDDIS_TO_CARDEMU													\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT3 | BIT7, 0}, /*clear suspend enable and po=
wer down enable*/	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK, PWR_BAS=
EADDR_SDIO, PWR_CMD_WRITE, BIT0, 0}, /*Set SDIO suspend local register*=
/	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK, PWR_BAS=
EADDR_SDIO, PWR_CMD_POLLING, BIT1, BIT1}, /*wait power state to suspend=
*/\
+	{0x004A, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT0, 0}, /*0x48[16] =3D 0 to disable GPIO9 as=
 EXT WAKEUP*/   \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT3|BIT4, 0}, /*0x04[12:11] =3D 2b'01enable W=
L suspend*/\
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK, PWR_BAS=
EADDR_MAC, PWR_CMD_WRITE, BIT4, 0}, /*0x23[4] =3D 1b'0 12H LDO enter no=
rmal mode*/   \
+	{0x0301, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, 0xFF, 0},/*PCIe DMA start*/
+
+
+#define RTL8723A_TRANS_CARDEMU_TO_PDN												\
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK, PWR_BAS=
EADDR_MAC, PWR_CMD_WRITE, BIT4, BIT4}, /*0x23[4] =3D 1b'1 12H LDO enter=
 sleep mode*/   \
+	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK|PWR_INTF=
_USB_MSK, PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x20}, /*0x07[7:0] =3D=
 0x20 SOP option to disable BG/MB/ACK/SWR*/   \
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT0, 0},/* 0x04[16] =3D 0*/\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT7, BIT7},/* 0x04[15] =3D 1*/
+
+#define RTL8723A_TRANS_PDN_TO_CARDEMU												\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT7, 0},/* 0x04[15] =3D 0*/
+
+#define RTL8723A_TRANS_ACT_TO_LPS														\
+	{0x0301, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF},/*PCIe DMA stop*/	\
+	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF},/*Tx Pause*/	\
+	{0x05F8, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},/*Should be zero if no packet is tr=
ansmitting*/	\
+	{0x05F9, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},/*Should be zero if no packet is tr=
ansmitting*/	\
+	{0x05FA, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},/*Should be zero if no packet is tr=
ansmitting*/	\
+	{0x05FB, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},/*Should be zero if no packet is tr=
ansmitting*/	\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT0, 0},/*CCK and OFDM are disabled, and cloc=
k are gated*/	\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_US},/*Delay 1us*/	\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT1, 0},/*Whole BB is reset*/	\
+	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x03},/*Reset MAC TRX*/	\
+	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT1, 0},/*check if removed later*/	\
+	{0x0093, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK, PWR_BAS=
EADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x00},/*When driver enter Sus/ Disable,=
 enable LOP for BT*/	\
+	{0x0553, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT5, BIT5},/*Respond TxOK to scheduler*/
+
+#define RTL8723A_TRANS_LPS_TO_ACT															\
+	{0x0080, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK, PWR_BAS=
EADDR_SDIO, PWR_CMD_WRITE, 0xFF, 0x84}, /*SDIO RPWM*/\
+	{0xFE58, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84}, /*USB RPWM*/\
+	{0x0361, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84}, /*PCIe RPWM*/\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_MS}, /*Delay*/\
+	{0x0008, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT4, 0}, /*.	0x08[4] =3D 0		 switch TSF to 40=
M*/\
+	{0x0109, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_POLLING, BIT7, 0}, /*Polling 0x109[7]=3D 0  TSF in 40=
M*/\
+	{0x0029, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT6|BIT7, 0}, /*.	0x29[7:6] =3D 2b'00	 enable=
 BB clock*/\
+	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT1, BIT1}, /*.	0x101[1] =3D 1*/\
+	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF}, /*.	0x100[7:0] =3D 0xFF	 enable W=
MAC TRX*/\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, BIT1|BIT0, BIT1|BIT0}, /*.	0x02[1:0] =3D 2b'11=
	 enable BB macro*/\
+	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, PWR_BASE=
ADDR_MAC, PWR_CMD_WRITE, 0xFF, 0}, /*.	0x522 =3D 0*/
+
+#define RTL8723A_TRANS_END															\
+	{0xFFFF, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, 0, PWR_C=
MD_END, 0, 0},
+
+
+extern struct wlan_pwr_cfg rtl8723AU_power_on_flow[RTL8723A_TRANS_CARD=
EMU_TO_ACT_STEPS+RTL8723A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723AU_radio_off_flow[RTL8723A_TRANS_ACT=
_TO_CARDEMU_STEPS+RTL8723A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723AU_card_disable_flow[RTL8723A_TRANS_=
ACT_TO_CARDEMU_STEPS+RTL8723A_TRANS_CARDEMU_TO_PDN_STEPS+RTL8723A_TRANS=
_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723AU_card_enable_flow[RTL8723A_TRANS_A=
CT_TO_CARDEMU_STEPS+RTL8723A_TRANS_CARDEMU_TO_PDN_STEPS+RTL8723A_TRANS_=
END_STEPS];
+extern struct wlan_pwr_cfg rtl8723AU_suspend_flow[RTL8723A_TRANS_ACT_T=
O_CARDEMU_STEPS+RTL8723A_TRANS_CARDEMU_TO_SUS_STEPS+RTL8723A_TRANS_END_=
STEPS];
+extern struct wlan_pwr_cfg rtl8723AU_resume_flow[RTL8723A_TRANS_ACT_TO=
_CARDEMU_STEPS+RTL8723A_TRANS_CARDEMU_TO_SUS_STEPS+RTL8723A_TRANS_END_S=
TEPS];
+extern struct wlan_pwr_cfg rtl8723AU_hwpdn_flow[RTL8723A_TRANS_ACT_TO_=
CARDEMU_STEPS+RTL8723A_TRANS_CARDEMU_TO_PDN_STEPS+RTL8723A_TRANS_END_ST=
EPS];
+extern struct wlan_pwr_cfg rtl8723AU_enter_lps_flow[RTL8723A_TRANS_ACT=
_TO_LPS_STEPS+RTL8723A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723AU_leave_lps_flow[RTL8723A_TRANS_LPS=
_TO_ACT_STEPS+RTL8723A_TRANS_END_STEPS];
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/Hal8723UHWImg_CE.h b/dri=
vers/staging/rtl8723au/include/Hal8723UHWImg_CE.h
new file mode 100644
index 0000000..bbeaab4
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/Hal8723UHWImg_CE.h
@@ -0,0 +1,29 @@
+#ifndef __INC_HAL8723U_FW_IMG_H
+#define __INC_HAL8723U_FW_IMG_H
+
+/*Created on  2013/01/14, 15:51*/
+
+/* FW v16 enable usb interrupt */
+#define Rtl8723UImgArrayLength 22172
+extern u8 Rtl8723UFwImgArray[Rtl8723UImgArrayLength];
+#define Rtl8723UBTImgArrayLength 1
+extern u8 Rtl8723UFwBTImgArray[Rtl8723UBTImgArrayLength];
+
+#define Rtl8723UUMCBCutImgArrayWithBTLength 24118
+#define Rtl8723UUMCBCutImgArrayWithoutBTLength 19200
+
+extern u8 Rtl8723UFwUMCBCutImgArrayWithBT[Rtl8723UUMCBCutImgArrayWithB=
TLength];
+extern u8 Rtl8723UFwUMCBCutImgArrayWithoutBT[Rtl8723UUMCBCutImgArrayWi=
thoutBTLength];
+
+#define Rtl8723SUMCBCutMPImgArrayLength 24174
+extern const u8 Rtl8723SFwUMCBCutMPImgArray[Rtl8723SUMCBCutMPImgArrayL=
ength];
+
+#define Rtl8723EBTImgArrayLength 15276
+extern u8 Rtl8723EFwBTImgArray[Rtl8723EBTImgArrayLength] ;
+
+#define Rtl8723UPHY_REG_Array_PGLength 336
+extern u32 Rtl8723UPHY_REG_Array_PG[Rtl8723UPHY_REG_Array_PGLength];
+#define Rtl8723UMACPHY_Array_PGLength 1
+extern u32 Rtl8723UMACPHY_Array_PG[Rtl8723UMACPHY_Array_PGLength];
+
+#endif /* ifndef __INC_HAL8723U_FW_IMG_H */
diff --git a/drivers/staging/rtl8723au/include/HalDMOutSrc8723A.h b/dri=
vers/staging/rtl8723au/include/HalDMOutSrc8723A.h
new file mode 100644
index 0000000..d7651f7
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/HalDMOutSrc8723A.h
@@ -0,0 +1,64 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *
+ *********************************************************************=
*********/
+#ifndef	__RTL8723A_ODM_H__
+#define __RTL8723A_ODM_H__
+/*  */
+
+#define	RSSI_CCK	0
+#define	RSSI_OFDM	1
+#define	RSSI_DEFAULT	2
+
+#define IQK_MAC_REG_NUM		4
+#define IQK_ADDA_REG_NUM		16
+#define IQK_BB_REG_NUM			9
+#define HP_THERMAL_NUM		8
+
+
+/*  */
+/*  structure and define */
+/*  */
+
+
+
+
+/*------------------------Export global variable----------------------=
------*/
+/*------------------------Export global variable----------------------=
------*/
+/*------------------------Export Marco Definition---------------------=
------*/
+/* define DM_MultiSTA_InitGainChangeNotify(Event) {DM_DigTable.CurMult=
iSTAConnectState =3D Event;} */
+
+
+/*  */
+/*  function prototype */
+/*  */
+
+/*  */
+/*  IQ calibrate */
+/*  */
+void rtl8723a_phy_iq_calibrate(struct rtw_adapter *pAdapter, bool bReC=
overy);
+
+/*  */
+/*  LC calibrate */
+/*  */
+void rtl8723a_phy_lc_calibrate(struct rtw_adapter *pAdapter);
+
+/*  */
+/*  AP calibrate */
+/*  */
+void rtl8723a_phy_ap_calibrate(struct rtw_adapter *pAdapter, char delt=
a);
+
+void rtl8723a_odm_check_tx_power_tracking(struct rtw_adapter *Adapter)=
;
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/HalHWImg8723A_BB.h b/dri=
vers/staging/rtl8723au/include/HalHWImg8723A_BB.h
new file mode 100644
index 0000000..e99833c
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/HalHWImg8723A_BB.h
@@ -0,0 +1,44 @@
+/*********************************************************************=
*********
+*
+* Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+*
+* This program is free software; you can redistribute it and/or modify=
 it
+* under the terms of version 2 of the GNU General Public License as
+* published by the Free Software Foundation.
+*
+* This program is distributed in the hope that it will be useful, but =
WITHOUT
+* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY o=
r
+* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License=
 for
+* more details.
+*
+*
+**********************************************************************=
********/
+
+#ifndef __INC_BB_8723A_HW_IMG_H
+#define __INC_BB_8723A_HW_IMG_H
+
+/*********************************************************************=
*********
+*                           AGC_TAB_1T.TXT
+**********************************************************************=
********/
+
+void ODM_ReadAndConfig_AGC_TAB_1T_8723A(struct dm_odm_t *pDM_Odm);
+
+/*********************************************************************=
*********
+*                           PHY_REG_1T.TXT
+**********************************************************************=
********/
+
+void ODM_ReadAndConfig_PHY_REG_1T_8723A(struct dm_odm_t *pDM_Odm);
+
+/*********************************************************************=
*********
+*                           PHY_REG_MP.TXT
+**********************************************************************=
********/
+
+void ODM_ReadAndConfig_PHY_REG_MP_8723A(struct dm_odm_t *pDM_Odm);
+
+/*********************************************************************=
*********
+*                           PHY_REG_PG.TXT
+**********************************************************************=
********/
+
+void ODM_ReadAndConfig_PHY_REG_PG_8723A(struct dm_odm_t *pDM_Odm);
+
+#endif /*  end of HWIMG_SUPPORT */
diff --git a/drivers/staging/rtl8723au/include/HalHWImg8723A_FW.h b/dri=
vers/staging/rtl8723au/include/HalHWImg8723A_FW.h
new file mode 100644
index 0000000..7ee363b
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/HalHWImg8723A_FW.h
@@ -0,0 +1,28 @@
+/*********************************************************************=
*********
+*
+* Copyright(c) 2007 - 2012 Realtek Corporation. All rights reserved.
+*
+* This program is free software; you can redistribute it and/or modify=
 it
+* under the terms of version 2 of the GNU General Public License as
+* published by the Free Software Foundation.
+*
+* This program is distributed in the hope that it will be useful, but =
WITHOUT
+* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY o=
r
+* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License=
 for
+* more details.
+*
+*
+**********************************************************************=
********/
+
+#ifndef __INC_FW_8723A_HW_IMG_H
+#define __INC_FW_8723A_HW_IMG_H
+
+
+/*********************************************************************=
*********
+*                           rtl8723fw_B.TXT
+**********************************************************************=
********/
+
+void ODM_ReadFirmware_8723A_rtl8723fw_B(struct dm_odm_t *pDM_Odm,
+					u8 *pFirmware, u32 *pFirmwareSize);
+
+#endif /*  end of HWIMG_SUPPORT */
diff --git a/drivers/staging/rtl8723au/include/HalHWImg8723A_MAC.h b/dr=
ivers/staging/rtl8723au/include/HalHWImg8723A_MAC.h
new file mode 100644
index 0000000..201be1f
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/HalHWImg8723A_MAC.h
@@ -0,0 +1,26 @@
+/*********************************************************************=
*********
+*
+* Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+*
+* This program is free software; you can redistribute it and/or modify=
 it
+* under the terms of version 2 of the GNU General Public License as
+* published by the Free Software Foundation.
+*
+* This program is distributed in the hope that it will be useful, but =
WITHOUT
+* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY o=
r
+* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License=
 for
+* more details.
+*
+*
+**********************************************************************=
********/
+
+#ifndef __INC_MAC_8723A_HW_IMG_H
+#define __INC_MAC_8723A_HW_IMG_H
+
+/*********************************************************************=
*********
+*                           MAC_REG.TXT
+**********************************************************************=
********/
+
+void ODM_ReadAndConfig_MAC_REG_8723A(struct dm_odm_t *pDM_Odm);
+
+#endif /*  end of HWIMG_SUPPORT */
diff --git a/drivers/staging/rtl8723au/include/HalHWImg8723A_RF.h b/dri=
vers/staging/rtl8723au/include/HalHWImg8723A_RF.h
new file mode 100644
index 0000000..c9af1c3
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/HalHWImg8723A_RF.h
@@ -0,0 +1,25 @@
+/*********************************************************************=
*********
+*
+* Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+*
+* This program is free software; you can redistribute it and/or modify=
 it
+* under the terms of version 2 of the GNU General Public License as
+* published by the Free Software Foundation.
+*
+* This program is distributed in the hope that it will be useful, but =
WITHOUT
+* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY o=
r
+* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License=
 for
+* more details.
+*
+**********************************************************************=
********/
+
+#ifndef __INC_RF_8723A_HW_IMG_H
+#define __INC_RF_8723A_HW_IMG_H
+
+/*********************************************************************=
*********
+*                           RadioA_1T.TXT
+**********************************************************************=
********/
+
+void ODM_ReadAndConfig_RadioA_1T_8723A(struct dm_odm_t *pDM_Odm);
+
+#endif /*  end of HWIMG_SUPPORT */
diff --git a/drivers/staging/rtl8723au/include/HalPwrSeqCmd.h b/drivers=
/staging/rtl8723au/include/HalPwrSeqCmd.h
new file mode 100644
index 0000000..12e03a3
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/HalPwrSeqCmd.h
@@ -0,0 +1,130 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *
+ *********************************************************************=
*********/
+#ifndef __HALPWRSEQCMD_H__
+#define __HALPWRSEQCMD_H__
+
+#include <drv_types.h>
+
+/*---------------------------------------------*/
+/*---------------------------------------------*/
+#define PWR_CMD_READ			0x00
+     /*  offset: the read register offset */
+     /*  msk: the mask of the read value */
+     /*  value: N/A, left by 0 */
+     /*  note: dirver shall implement this function by read & msk */
+
+#define PWR_CMD_WRITE			0x01
+     /*  offset: the read register offset */
+     /*  msk: the mask of the write bits */
+     /*  value: write value */
+     /*  note: driver shall implement this cmd by read & msk after wri=
te */
+
+#define PWR_CMD_POLLING			0x02
+     /*  offset: the read register offset */
+     /*  msk: the mask of the polled value */
+     /*  value: the value to be polled, masked by the msd field. */
+     /*  note: driver shall implement this cmd by */
+     /*  do{ */
+     /*  if( (Read(offset) & msk) =3D=3D (value & msk) ) */
+     /*  break; */
+     /*  } while(not timeout); */
+
+#define PWR_CMD_DELAY			0x03
+     /*  offset: the value to delay */
+     /*  msk: N/A */
+     /*  value: the unit of delay, 0: us, 1: ms */
+
+#define PWR_CMD_END				0x04
+     /*  offset: N/A */
+     /*  msk: N/A */
+     /*  value: N/A */
+
+/*---------------------------------------------*/
+/* 3 The value of base: 4 bits */
+/*---------------------------------------------*/
+   /*  define the base address of each block */
+#define PWR_BASEADDR_MAC		0x00
+#define PWR_BASEADDR_USB		0x01
+#define PWR_BASEADDR_PCIE		0x02
+#define PWR_BASEADDR_SDIO		0x03
+
+/*---------------------------------------------*/
+/* 3 The value of interface_msk: 4 bits */
+/*---------------------------------------------*/
+#define	PWR_INTF_SDIO_MSK		BIT(0)
+#define	PWR_INTF_USB_MSK		BIT(1)
+#define	PWR_INTF_PCI_MSK		BIT(2)
+#define	PWR_INTF_ALL_MSK		(BIT(0)|BIT(1)|BIT(2)|BIT(3))
+
+/*---------------------------------------------*/
+/* 3 The value of fab_msk: 4 bits */
+/*---------------------------------------------*/
+#define	PWR_FAB_TSMC_MSK		BIT(0)
+#define	PWR_FAB_UMC_MSK			BIT(1)
+#define	PWR_FAB_ALL_MSK			(BIT(0)|BIT(1)|BIT(2)|BIT(3))
+
+/*---------------------------------------------*/
+/* 3 The value of cut_msk: 8 bits */
+/*---------------------------------------------*/
+#define	PWR_CUT_TESTCHIP_MSK	BIT(0)
+#define	PWR_CUT_A_MSK			BIT(1)
+#define	PWR_CUT_B_MSK			BIT(2)
+#define	PWR_CUT_C_MSK			BIT(3)
+#define	PWR_CUT_D_MSK			BIT(4)
+#define	PWR_CUT_E_MSK			BIT(5)
+#define	PWR_CUT_F_MSK			BIT(6)
+#define	PWR_CUT_G_MSK			BIT(7)
+#define	PWR_CUT_ALL_MSK			0xFF
+
+
+enum pwrseq_delay_unit {
+	PWRSEQ_DELAY_US,
+	PWRSEQ_DELAY_MS,
+};
+
+struct wlan_pwr_cfg {
+	u16 offset;
+	u8 cut_msk;
+	u8 fab_msk:4;
+	u8 interface_msk:4;
+	u8 base:4;
+	u8 cmd:4;
+	u8 msk;
+	u8 value;
+};
+
+
+#define GET_PWR_CFG_OFFSET(__PWR_CMD)		__PWR_CMD.offset
+#define GET_PWR_CFG_CUT_MASK(__PWR_CMD)		__PWR_CMD.cut_msk
+#define GET_PWR_CFG_FAB_MASK(__PWR_CMD)		__PWR_CMD.fab_msk
+#define GET_PWR_CFG_INTF_MASK(__PWR_CMD)	__PWR_CMD.interface_msk
+#define GET_PWR_CFG_BASE(__PWR_CMD)			__PWR_CMD.base
+#define GET_PWR_CFG_CMD(__PWR_CMD)			__PWR_CMD.cmd
+#define GET_PWR_CFG_MASK(__PWR_CMD)			__PWR_CMD.msk
+#define GET_PWR_CFG_VALUE(__PWR_CMD)		__PWR_CMD.value
+
+
+/*  */
+/*	Prototype of protected function. */
+/*  */
+u8 HalPwrSeqCmdParsing23a(
+	struct rtw_adapter		*padapter,
+	u8				CutVersion,
+	u8				FabVersion,
+	u8				InterfaceType,
+	struct wlan_pwr_cfg	PwrCfgCmd[]);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/HalVerDef.h b/drivers/st=
aging/rtl8723au/include/HalVerDef.h
new file mode 100644
index 0000000..607b71f
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/HalVerDef.h
@@ -0,0 +1,136 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __HAL_VERSION_DEF_H__
+#define __HAL_VERSION_DEF_H__
+
+enum hal_ic_type {
+	CHIP_8192S		=3D	0,
+	CHIP_8188C	=3D	1,
+	CHIP_8192C	=3D	2,
+	CHIP_8192D	=3D	3,
+	CHIP_8723A	=3D	4,
+	CHIP_8188E	=3D	5,
+	CHIP_8881A	=3D	6,
+	CHIP_8812A	=3D	7,
+	CHIP_8821A	=3D	8,
+	CHIP_8723B	=3D	9,
+	CHIP_8192E		=3D	10,
+};
+
+enum hal_chip_type {
+	TEST_CHIP		=3D	0,
+	NORMAL_CHIP		=3D	1,
+	FPGA			=3D	2,
+};
+
+enum hal_cut_version {
+	A_CUT_VERSION		=3D	0,
+	B_CUT_VERSION		=3D	1,
+	C_CUT_VERSION		=3D	2,
+	D_CUT_VERSION		=3D	3,
+	E_CUT_VERSION		=3D	4,
+	F_CUT_VERSION		=3D	5,
+	G_CUT_VERSION		=3D	6,
+};
+
+/*  HAL_Manufacturer */
+enum hal_vendor {
+	CHIP_VENDOR_TSMC	=3D	0,
+	CHIP_VENDOR_UMC		=3D	1,
+};
+
+enum hal_rf_type {
+	RF_TYPE_1T1R	=3D	0,
+	RF_TYPE_1T2R	=3D	1,
+	RF_TYPE_2T2R	=3D	2,
+	RF_TYPE_2T3R	=3D	3,
+	RF_TYPE_2T4R	=3D	4,
+	RF_TYPE_3T3R	=3D	5,
+	RF_TYPE_3T4R	=3D	6,
+	RF_TYPE_4T4R	=3D	7,
+};
+
+struct hal_version {
+	enum hal_ic_type	ICType;
+	enum hal_chip_type	ChipType;
+	enum hal_cut_version	CUTVersion;
+	enum hal_vendor		VendorType;
+	enum hal_rf_type	RFType;
+	u8			ROMVer;
+};
+
+/*  Get element */
+#define GET_CVID_IC_TYPE(version)	((version).ICType)
+#define GET_CVID_CHIP_TYPE(version)	((version).ChipType)
+#define GET_CVID_RF_TYPE(version)	((version).RFType)
+#define GET_CVID_MANUFACTUER(version)	((version).VendorType)
+#define GET_CVID_CUT_VERSION(version)	((version).CUTVersion)
+#define GET_CVID_ROM_VERSION(version)	(((version).ROMVer) & ROM_VERSIO=
N_MASK)
+
+/* Common Macro. -- */
+
+#define IS_81XXC(version)			\
+	(((GET_CVID_IC_TYPE(version) =3D=3D CHIP_8192C) ||	\
+	 (GET_CVID_IC_TYPE(version) =3D=3D CHIP_8188C)) ? true : false)
+#define IS_8723_SERIES(version)			\
+	((GET_CVID_IC_TYPE(version) =3D=3D CHIP_8723A) ? true : false)
+
+#define IS_TEST_CHIP(version)			\
+	((GET_CVID_CHIP_TYPE(version) =3D=3D TEST_CHIP) ? true : false)
+#define IS_NORMAL_CHIP(version)			\
+	((GET_CVID_CHIP_TYPE(version) =3D=3D NORMAL_CHIP) ? true : false)
+
+#define IS_A_CUT(version)			\
+	((GET_CVID_CUT_VERSION(version) =3D=3D A_CUT_VERSION) ? true : false)
+#define IS_B_CUT(version)			\
+	((GET_CVID_CUT_VERSION(version) =3D=3D B_CUT_VERSION) ? true : false)
+#define IS_C_CUT(version)			\
+	((GET_CVID_CUT_VERSION(version) =3D=3D C_CUT_VERSION) ? true : false)
+#define IS_D_CUT(version)			\
+	((GET_CVID_CUT_VERSION(version) =3D=3D D_CUT_VERSION) ? true : false)
+#define IS_E_CUT(version)			\
+	((GET_CVID_CUT_VERSION(version) =3D=3D E_CUT_VERSION) ? true : false)
+
+#define IS_CHIP_VENDOR_TSMC(version)		\
+	((GET_CVID_MANUFACTUER(version) =3D=3D CHIP_VENDOR_TSMC) ? true : fal=
se)
+#define IS_CHIP_VENDOR_UMC(version)		\
+	((GET_CVID_MANUFACTUER(version) =3D=3D CHIP_VENDOR_UMC) ? true : fals=
e)
+
+#define IS_1T1R(version)			\
+	((GET_CVID_RF_TYPE(version) =3D=3D RF_TYPE_1T1R) ? true : false)
+#define IS_1T2R(version)			\
+	((GET_CVID_RF_TYPE(version) =3D=3D RF_TYPE_1T2R) ? true : false)
+#define IS_2T2R(version)			\
+	((GET_CVID_RF_TYPE(version) =3D=3D RF_TYPE_2T2R) ? true : false)
+
+/* Chip version Macro. -- */
+
+#define IS_92C_SERIAL(version)					\
+	((IS_81XXC(version) && IS_2T2R(version)) ? true : false)
+#define IS_81xxC_VENDOR_UMC_A_CUT(version)			\
+	(IS_81XXC(version)?(IS_CHIP_VENDOR_UMC(version) ?	\
+	(IS_A_CUT(version) ? true : false) : false) : false)
+#define IS_81xxC_VENDOR_UMC_B_CUT(version)			\
+	(IS_81XXC(version) ? (IS_CHIP_VENDOR_UMC(version) ?	\
+	 (IS_B_CUT(version) ? true : false) : false): false)
+#define IS_81xxC_VENDOR_UMC_C_CUT(version)			\
+	(IS_81XXC(version)?(IS_CHIP_VENDOR_UMC(version) ?	\
+	(IS_C_CUT(version) ? true : false) : false) : false)
+#define IS_8723A_A_CUT(version)				\
+	((IS_8723_SERIES(version)) ? (IS_A_CUT(version) ? true : false) : fal=
se)
+#define IS_8723A_B_CUT(version)					\
+	((IS_8723_SERIES(version)) ? (IS_B_CUT(version) ? true : false) : fal=
se)
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/cmd_osdep.h b/drivers/st=
aging/rtl8723au/include/cmd_osdep.h
new file mode 100644
index 0000000..4866bee
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/cmd_osdep.h
@@ -0,0 +1,26 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __CMD_OSDEP_H_
+#define __CMD_OSDEP_H_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+int _rtw_init_evt_priv23a(struct evt_priv *pevtpriv);
+void _rtw_free_evt_priv23a(struct	evt_priv *pevtpriv);
+void _rtw_free_cmd_priv23a(struct	cmd_priv *pcmdpriv);
+int _rtw_enqueue_cmd23a(struct rtw_queue *queue, struct cmd_obj *obj);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/drv_types.h b/drivers/st=
aging/rtl8723au/include/drv_types.h
new file mode 100644
index 0000000..5847988
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/drv_types.h
@@ -0,0 +1,364 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2012 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+/*--------------------------------------------------------------------=
---------
+
+	For type defines and data structure defines
+
+----------------------------------------------------------------------=
--------*/
+
+
+#ifndef __DRV_TYPES_H__
+#define __DRV_TYPES_H__
+
+#include <osdep_service.h>
+#include <wlan_bssdef.h>
+
+
+enum _NIC_VERSION {
+	RTL8711_NIC,
+	RTL8712_NIC,
+	RTL8713_NIC,
+	RTL8716_NIC
+
+};
+
+
+#include <rtw_ht.h>
+
+#include <rtw_cmd.h>
+#include <wlan_bssdef.h>
+#include <rtw_xmit.h>
+#include <rtw_recv.h>
+#include <hal_intf.h>
+#include <hal_com.h>
+#include <rtw_qos.h>
+#include <rtw_security.h>
+#include <rtw_pwrctrl.h>
+#include <rtw_io.h>
+#include <rtw_eeprom.h>
+#include <sta_info.h>
+#include <rtw_mlme.h>
+#include <rtw_debug.h>
+#include <rtw_rf.h>
+#include <rtw_event.h>
+#include <rtw_led.h>
+#include <rtw_mlme_ext.h>
+#include <rtw_p2p.h>
+#include <rtw_ap.h>
+
+#include "ioctl_cfg80211.h"
+
+#define SPEC_DEV_ID_NONE BIT(0)
+#define SPEC_DEV_ID_DISABLE_HT BIT(1)
+#define SPEC_DEV_ID_ENABLE_PS BIT(2)
+#define SPEC_DEV_ID_RF_CONFIG_1T1R BIT(3)
+#define SPEC_DEV_ID_RF_CONFIG_2T2R BIT(4)
+#define SPEC_DEV_ID_ASSIGN_IFNAME BIT(5)
+
+struct specific_device_id {
+	u32		flags;
+
+	u16		idVendor;
+	u16		idProduct;
+
+};
+
+struct registry_priv {
+	u8	chip_version;
+	u8	rfintfs;
+	struct	cfg80211_ssid ssid;
+	u8	channel;/* ad-hoc support requirement */
+	u8	wireless_mode;/* A, B, G, auto */
+	u8	scan_mode;/* active, passive */
+	u8	preamble;/* long, short, auto */
+	u8	vrtl_carrier_sense;/* Enable, Disable, Auto */
+	u8	vcs_type;/* RTS/CTS, CTS-to-self */
+	u16	rts_thresh;
+	u16  frag_thresh;
+	u8	adhoc_tx_pwr;
+	u8	soft_ap;
+	u8	power_mgnt;
+	u8	ips_mode;
+	u8	smart_ps;
+	u8	long_retry_lmt;
+	u8	short_retry_lmt;
+	u16	busy_thresh;
+	u8	ack_policy;
+	u8	software_encrypt;
+	u8	software_decrypt;
+	u8	acm_method;
+	  /* UAPSD */
+	u8	wmm_enable;
+	u8	uapsd_enable;
+
+	struct wlan_bssid_ex    dev_network;
+
+	u8	ht_enable;
+	u8	cbw40_enable;
+	u8	ampdu_enable;/* for tx */
+	u8	rx_stbc;
+	u8	ampdu_amsdu;/* A-MPDU Supports A-MSDU is permitted */
+	u8	lowrate_two_xmit;
+
+	u8	rf_config;
+	u8	low_power;
+
+	u8	wifi_spec;/*  !turbo_mode */
+
+	u8	channel_plan;
+#ifdef CONFIG_8723AU_BT_COEXIST
+	u8	btcoex;
+	u8	bt_iso;
+	u8	bt_sco;
+	u8	bt_ampdu;
+#endif
+	bool	bAcceptAddbaReq;
+
+	u8	antdiv_cfg;
+	u8	antdiv_type;
+
+	u8	usbss_enable;/* 0:disable,1:enable */
+	u8	hwpdn_mode;/* 0:disable,1:enable,2:decide by EFUSE config */
+	u8	hwpwrp_detect;/* 0:disable,1:enable */
+
+	u8	hw_wps_pbc;/* 0:disable,1:enable */
+
+	u8	max_roaming_times; /* max number driver will try to roaming */
+
+	u8 enable80211d;
+
+	u8 ifname[16];
+	u8 if2name[16];
+
+	u8 notch_filter;
+
+	u8 regulatory_tid;
+};
+
+
+#define MAX_CONTINUAL_URB_ERR 4
+
+#define GET_PRIMARY_ADAPTER(padapter)					\
+	(((struct rtw_adapter *)padapter)->dvobj->if1)
+
+enum _IFACE_ID {
+	IFACE_ID0, /* maping to PRIMARY_ADAPTER */
+	IFACE_ID1, /* maping to SECONDARY_ADAPTER */
+	IFACE_ID2,
+	IFACE_ID3,
+	IFACE_ID_MAX,
+};
+
+struct dvobj_priv {
+	struct rtw_adapter *if1; /* PRIMARY_ADAPTER */
+	struct rtw_adapter *if2; /* SECONDARY_ADAPTER */
+
+	/* for local/global synchronization */
+	struct mutex hw_init_mutex;
+	struct mutex h2c_fwcmd_mutex;
+	struct mutex setch_mutex;
+	struct mutex setbw_mutex;
+
+	unsigned char	oper_channel; /* saved chan info when set chan bw */
+	unsigned char	oper_bwmode;
+	unsigned char	oper_ch_offset;/* PRIME_CHNL_OFFSET */
+
+	struct rtw_adapter *padapters[IFACE_ID_MAX];
+	u8 iface_nums; /*  total number of ifaces used runtime */
+
+	/* For 92D, DMDP have 2 interface. */
+	u8	InterfaceNumber;
+	u8	NumInterfaces;
+
+	/* In /Out Pipe information */
+	int	RtInPipe[2];
+	int	RtOutPipe[3];
+	u8	Queue2Pipe[HW_QUEUE_ENTRY];/* for out pipe mapping */
+
+	u8	irq_alloc;
+
+/*-------- below is for USB INTERFACE --------*/
+
+	u8	nr_endpoint;
+	u8	ishighspeed;
+	u8	RtNumInPipes;
+	u8	RtNumOutPipes;
+	int	ep_num[5]; /* endpoint number */
+
+	int	RegUsbSS;
+
+	struct semaphore usb_suspend_sema;
+
+	struct mutex  usb_vendor_req_mutex;
+
+	u8 *usb_alloc_vendor_req_buf;
+	u8 *usb_vendor_req_buf;
+
+	struct usb_interface *pusbintf;
+	struct usb_device *pusbdev;
+	atomic_t continual_urb_error;
+
+/*-------- below is for PCIE INTERFACE --------*/
+
+};
+
+static inline struct device *dvobj_to_dev(struct dvobj_priv *dvobj)
+{
+	/* todo: get interface type from dvobj and the return the dev accordi=
ngly */
+	return &dvobj->pusbintf->dev;
+}
+
+enum _IFACE_TYPE {
+	IFACE_PORT0, /* mapping to port0 for C/D series chips */
+	IFACE_PORT1, /* mapping to port1 for C/D series chip */
+	MAX_IFACE_PORT,
+};
+
+enum _ADAPTER_TYPE {
+	PRIMARY_ADAPTER,
+	SECONDARY_ADAPTER,
+	MAX_ADAPTER,
+};
+
+struct rtw_adapter {
+	int	pid[3];/* process id from UI, 0:wps, 1:hostapd, 2:dhcpcd */
+	int	bDongle;/* build-in module or external dongle */
+	u16	chip_type;
+	u16	HardwareType;
+
+	struct dvobj_priv *dvobj;
+	struct	mlme_priv mlmepriv;
+	struct	mlme_ext_priv mlmeextpriv;
+	struct	cmd_priv	cmdpriv;
+	struct	evt_priv	evtpriv;
+	/* struct	io_queue	*pio_queue; */
+	struct	io_priv	iopriv;
+	struct	xmit_priv	xmitpriv;
+	struct	recv_priv	recvpriv;
+	struct	sta_priv	stapriv;
+	struct	security_priv	securitypriv;
+	struct	registry_priv	registrypriv;
+	struct	pwrctrl_priv	pwrctrlpriv;
+	struct	eeprom_priv eeprompriv;
+	struct	led_priv	ledpriv;
+
+#ifdef CONFIG_8723AU_AP_MODE
+	struct	hostapd_priv	*phostapdpriv;
+#endif
+
+#ifdef CONFIG_8723AU_P2P
+	struct cfg80211_wifidirect_info	cfg80211_wdinfo;
+#endif /* CONFIG_8723AU_P2P */
+	u32	setband;
+#ifdef CONFIG_8723AU_P2P
+	struct wifidirect_info	wdinfo;
+#endif /* CONFIG_8723AU_P2P */
+
+#ifdef CONFIG_8723AU_P2P
+	struct wifi_display_info wfd_info;
+#endif /* CONFIG_8723AU_P2P */
+
+	void *HalData;
+	u32 hal_data_sz;
+	struct hal_ops	HalFunc;
+
+	s32	bDriverStopped;
+	s32	bSurpriseRemoved;
+	s32  bCardDisableWOHSM;
+
+	u32	IsrContent;
+	u32	ImrContent;
+
+	u8	EepromAddressSize;
+	u8	hw_init_completed;
+	u8	bDriverIsGoingToUnload;
+	u8	init_adpt_in_progress;
+	u8	bHaltInProgress;
+
+	void *cmdThread;
+	void *evtThread;
+	void *xmitThread;
+	void *recvThread;
+
+	void (*intf_start)(struct rtw_adapter *adapter);
+	void (*intf_stop)(struct rtw_adapter *adapter);
+
+	struct net_device *pnetdev;
+
+	/*  used by rtw_rereg_nd_name related function */
+	struct rereg_nd_name_data {
+		struct net_device *old_pnetdev;
+		char old_ifname[IFNAMSIZ];
+		u8 old_ips_mode;
+		u8 old_bRegUseLed;
+	} rereg_nd_name_priv;
+
+	int bup;
+	struct net_device_stats stats;
+	struct iw_statistics iwstats;
+	struct proc_dir_entry *dir_dev;/*  for proc directory */
+
+	struct wireless_dev *rtw_wdev;
+	int net_closed;
+
+	u8 bFWReady;
+	u8 bBTFWReady;
+	u8 bReadPortCancel;
+	u8 bWritePortCancel;
+	u8 bRxRSSIDisplay;
+	/* The driver will show the desired chan nor when this flag is 1. */
+	u8 bNotifyChannelChange;
+#ifdef CONFIG_8723AU_P2P
+	/* driver will show current P2P status when the  application reads it=
*/
+	u8 bShowGetP2PState;
+#endif
+	struct rtw_adapter *pbuddy_adapter;
+
+	/* extend to support multi interface */
+	/* IFACE_ID0 is equals to PRIMARY_ADAPTER */
+	/* IFACE_ID1 is equals to SECONDARY_ADAPTER */
+	u8 iface_id;
+
+#ifdef CONFIG_BR_EXT
+	_lock					br_ext_lock;
+	/* unsigned int			macclone_completed; */
+	struct nat25_network_db_entry	*nethash[NAT25_HASH_SIZE];
+	int				pppoe_connection_in_progress;
+	unsigned char			pppoe_addr[MACADDRLEN];
+	unsigned char			scdb_mac[MACADDRLEN];
+	unsigned char			scdb_ip[4];
+	struct nat25_network_db_entry	*scdb_entry;
+	unsigned char			br_mac[MACADDRLEN];
+	unsigned char			br_ip[4];
+
+	struct br_ext_info		ethBrExtInfo;
+#endif	/*  CONFIG_BR_EXT */
+
+	u8    fix_rate;
+
+	unsigned char     in_cta_test;
+
+};
+
+#define adapter_to_dvobj(adapter) (adapter->dvobj)
+
+int rtw_handle_dualmac23a(struct rtw_adapter *adapter, bool init);
+
+static inline u8 *myid(struct eeprom_priv *peepriv)
+{
+	return peepriv->mac_addr;
+}
+
+#endif /* __DRV_TYPES_H__ */
diff --git a/drivers/staging/rtl8723au/include/ethernet.h b/drivers/sta=
ging/rtl8723au/include/ethernet.h
new file mode 100644
index 0000000..39fc6df
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/ethernet.h
@@ -0,0 +1,22 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *
+ *********************************************************************=
*********/
+/*! \file */
+#ifndef __INC_ETHERNET_H
+#define __INC_ETHERNET_H
+
+#define LLC_HEADER_SIZE			6	/*  LLC Header Length */
+
+#endif /*  #ifndef __INC_ETHERNET_H */
diff --git a/drivers/staging/rtl8723au/include/hal_com.h b/drivers/stag=
ing/rtl8723au/include/hal_com.h
new file mode 100644
index 0000000..20f983c
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/hal_com.h
@@ -0,0 +1,211 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __HAL_COMMON_H__
+#define __HAL_COMMON_H__
+
+/*  */
+/*        Rate Definition */
+/*  */
+/* CCK */
+#define	RATR_1M					0x00000001
+#define	RATR_2M					0x00000002
+#define	RATR_55M				0x00000004
+#define	RATR_11M				0x00000008
+/* OFDM */
+#define	RATR_6M					0x00000010
+#define	RATR_9M					0x00000020
+#define	RATR_12M				0x00000040
+#define	RATR_18M				0x00000080
+#define	RATR_24M				0x00000100
+#define	RATR_36M				0x00000200
+#define	RATR_48M				0x00000400
+#define	RATR_54M				0x00000800
+/* MCS 1 Spatial Stream */
+#define	RATR_MCS0				0x00001000
+#define	RATR_MCS1				0x00002000
+#define	RATR_MCS2				0x00004000
+#define	RATR_MCS3				0x00008000
+#define	RATR_MCS4				0x00010000
+#define	RATR_MCS5				0x00020000
+#define	RATR_MCS6				0x00040000
+#define	RATR_MCS7				0x00080000
+/* MCS 2 Spatial Stream */
+#define	RATR_MCS8				0x00100000
+#define	RATR_MCS9				0x00200000
+#define	RATR_MCS10				0x00400000
+#define	RATR_MCS11				0x00800000
+#define	RATR_MCS12				0x01000000
+#define	RATR_MCS13				0x02000000
+#define	RATR_MCS14				0x04000000
+#define	RATR_MCS15				0x08000000
+
+/* CCK */
+#define RATE_1M					BIT(0)
+#define RATE_2M					BIT(1)
+#define RATE_5_5M				BIT(2)
+#define RATE_11M				BIT(3)
+/* OFDM */
+#define RATE_6M					BIT(4)
+#define RATE_9M					BIT(5)
+#define RATE_12M				BIT(6)
+#define RATE_18M				BIT(7)
+#define RATE_24M				BIT(8)
+#define RATE_36M				BIT(9)
+#define RATE_48M				BIT(10)
+#define RATE_54M				BIT(11)
+/* MCS 1 Spatial Stream */
+#define RATE_MCS0				BIT(12)
+#define RATE_MCS1				BIT(13)
+#define RATE_MCS2				BIT(14)
+#define RATE_MCS3				BIT(15)
+#define RATE_MCS4				BIT(16)
+#define RATE_MCS5				BIT(17)
+#define RATE_MCS6				BIT(18)
+#define RATE_MCS7				BIT(19)
+/* MCS 2 Spatial Stream */
+#define RATE_MCS8				BIT(20)
+#define RATE_MCS9				BIT(21)
+#define RATE_MCS10				BIT(22)
+#define RATE_MCS11				BIT(23)
+#define RATE_MCS12				BIT(24)
+#define RATE_MCS13				BIT(25)
+#define RATE_MCS14				BIT(26)
+#define RATE_MCS15				BIT(27)
+
+/*  ALL CCK Rate */
+#define	RATE_ALL_CCK	(RATR_1M | RATR_2M | RATR_55M | RATR_11M)
+#define	RATE_ALL_OFDM_AG				\
+	(RATR_6M | RATR_9M | RATR_12M | RATR_18M | RATR_24M| \
+	 RATR_36M|RATR_48M|RATR_54M)
+#define	RATE_ALL_OFDM_1SS				\
+	(RATR_MCS0 | RATR_MCS1 | RATR_MCS2 | RATR_MCS3 |	\
+	 RATR_MCS4 | RATR_MCS5 | RATR_MCS6 | RATR_MCS7)
+#define	RATE_ALL_OFDM_2SS				\
+	(RATR_MCS8 | RATR_MCS9 | RATR_MCS10 | RATR_MCS11|	\
+	 RATR_MCS12 | RATR_MCS13 | RATR_MCS14 | RATR_MCS15)
+
+/*------------------------------ Tx Desc definition Macro ------------=
------------*/
+/* pragma mark -- Tx Desc related definition. -- */
+/*  */
+/*  */
+/*	Rate */
+/*  */
+/*  CCK Rates, TxHT =3D 0 */
+#define DESC_RATE1M				0x00
+#define DESC_RATE2M				0x01
+#define DESC_RATE5_5M				0x02
+#define DESC_RATE11M				0x03
+
+/*  OFDM Rates, TxHT =3D 0 */
+#define DESC_RATE6M				0x04
+#define DESC_RATE9M				0x05
+#define DESC_RATE12M				0x06
+#define DESC_RATE18M				0x07
+#define DESC_RATE24M				0x08
+#define DESC_RATE36M				0x09
+#define DESC_RATE48M				0x0a
+#define DESC_RATE54M				0x0b
+
+/*  MCS Rates, TxHT =3D 1 */
+#define DESC_RATEMCS0				0x0c
+#define DESC_RATEMCS1				0x0d
+#define DESC_RATEMCS2				0x0e
+#define DESC_RATEMCS3				0x0f
+#define DESC_RATEMCS4				0x10
+#define DESC_RATEMCS5				0x11
+#define DESC_RATEMCS6				0x12
+#define DESC_RATEMCS7				0x13
+#define DESC_RATEMCS8				0x14
+#define DESC_RATEMCS9				0x15
+#define DESC_RATEMCS10				0x16
+#define DESC_RATEMCS11				0x17
+#define DESC_RATEMCS12				0x18
+#define DESC_RATEMCS13				0x19
+#define DESC_RATEMCS14				0x1a
+#define DESC_RATEMCS15				0x1b
+#define DESC_RATEMCS15_SG			0x1c
+#define DESC_RATEMCS32				0x20
+
+#define REG_P2P_CTWIN					0x0572 /*  1 Byte long (in unit of TU) */
+#define REG_NOA_DESC_SEL				0x05CF
+#define REG_NOA_DESC_DURATION		0x05E0
+#define REG_NOA_DESC_INTERVAL			0x05E4
+#define REG_NOA_DESC_START			0x05E8
+#define REG_NOA_DESC_COUNT			0x05EC
+
+#include "HalVerDef.h"
+void dump_chip_info23a(struct hal_version	ChipVersion);
+
+
+u8	/* return the final channel plan decision */
+hal_com_get_channel_plan23a(
+	struct rtw_adapter	*padapter,
+	u8			hw_channel_plan,	/* channel plan from HW (efuse/eeprom) */
+	u8			sw_channel_plan,	/* channel plan from SW (registry/module param)=
 */
+	u8			def_channel_plan,	/* channel plan used when the former two is in=
valid */
+	bool		AutoLoadFail
+	);
+
+u8	MRateToHwRate23a(u8 rate);
+
+void HalSetBrateCfg23a(struct rtw_adapter *padapter, u8 *mBratesOS);
+
+bool
+Hal_MappingOutPipe23a(struct rtw_adapter *pAdapter, u8 NumOutPipe);
+
+void hal_init_macaddr23a(struct rtw_adapter *adapter);
+
+void c2h_evt_clear23a(struct rtw_adapter *adapter);
+s32 c2h_evt_read23a(struct rtw_adapter *adapter, u8 *buf);
+
+void rtl8723a_set_ampdu_min_space(struct rtw_adapter *padapter, u8 Min=
SpacingToSet);
+void rtl8723a_set_ampdu_factor(struct rtw_adapter *padapter, u8 Factor=
ToSet);
+void rtl8723a_set_acm_ctrl(struct rtw_adapter *padapter, u8 ctrl);
+void rtl8723a_set_media_status(struct rtw_adapter *padapter, u8 status=
);
+void rtl8723a_set_media_status1(struct rtw_adapter *padapter, u8 statu=
s);
+void rtl8723a_set_bcn_func(struct rtw_adapter *padapter, u8 val);
+void rtl8723a_check_bssid(struct rtw_adapter *padapter, u8 val);
+void rtl8723a_mlme_sitesurvey(struct rtw_adapter *padapter, u8 flag);
+void rtl8723a_on_rcr_am(struct rtw_adapter *padapter);
+void rtl8723a_off_rcr_am(struct rtw_adapter *padapter);
+void rtl8723a_set_slot_time(struct rtw_adapter *padapter, u8 slottime)=
;
+void rtl8723a_ack_preamble(struct rtw_adapter *padapter, u8 bShortPrea=
mble);
+void rtl8723a_set_sec_cfg(struct rtw_adapter *padapter, u8 sec);
+void rtl8723a_cam_empty_entry(struct rtw_adapter *padapter, u8 ucIndex=
);
+void rtl8723a_cam_invalid_all(struct rtw_adapter *padapter);
+void rtl8723a_cam_write(struct rtw_adapter *padapter, u32 val1, u32 va=
l2);
+void rtl8723a_fifo_cleanup(struct rtw_adapter *padapter);
+void rtl8723a_set_apfm_on_mac(struct rtw_adapter *padapter, u8 val);
+void rtl8723a_bcn_valid(struct rtw_adapter *padapter);
+void rtl8723a_set_tx_pause(struct rtw_adapter *padapter, u8 pause);
+void rtl8723a_set_beacon_interval(struct rtw_adapter *padapter, u16 in=
terval);
+void rtl8723a_set_resp_sifs(struct rtw_adapter *padapter,
+			    u8 r2t1, u8 r2t2, u8 t2t1, u8 t2t2);
+void rtl8723a_set_ac_param_vo(struct rtw_adapter *padapter, u32 vo);
+void rtl8723a_set_ac_param_vi(struct rtw_adapter *padapter, u32 vi);
+void rtl8723a_set_ac_param_be(struct rtw_adapter *padapter, u32 be);
+void rtl8723a_set_ac_param_bk(struct rtw_adapter *padapter, u32 bk);
+void rtl8723a_set_rxdma_agg_pg_th(struct rtw_adapter *padapter, u8 val=
);
+void rtl8723a_set_nav_upper(struct rtw_adapter *padapter, u32 usNavUpp=
er);
+void rtl8723a_set_initial_gain(struct rtw_adapter *padapter, u32 rx_ga=
in);
+
+void rtl8723a_odm_support_ability_write(struct rtw_adapter *padapter, =
u32 val);
+void rtl8723a_odm_support_ability_backup(struct rtw_adapter *padapter,=
 u8 val);
+void rtl8723a_odm_support_ability_set(struct rtw_adapter *padapter, u3=
2 val);
+void rtl8723a_odm_support_ability_clr(struct rtw_adapter *padapter, u3=
2 val);
+
+void rtl8723a_set_rpwm(struct rtw_adapter *padapter, u8 val);
+
+#endif /* __HAL_COMMON_H__ */
diff --git a/drivers/staging/rtl8723au/include/hal_intf.h b/drivers/sta=
ging/rtl8723au/include/hal_intf.h
new file mode 100644
index 0000000..d183f4b
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/hal_intf.h
@@ -0,0 +1,392 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2012 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __HAL_INTF_H__
+#define __HAL_INTF_H__
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+enum RTL871X_HCI_TYPE {
+	RTW_PCIE	=3D BIT0,
+	RTW_USB		=3D BIT1,
+	RTW_SDIO	=3D BIT2,
+	RTW_GSPI	=3D BIT3,
+};
+
+enum _CHIP_TYPE {
+	NULL_CHIP_TYPE,
+	RTL8712_8188S_8191S_8192S,
+	RTL8188C_8192C,
+	RTL8192D,
+	RTL8723A,
+	RTL8188E,
+	MAX_CHIP_TYPE
+};
+
+enum HW_VARIABLES {
+	HW_VAR_MEDIA_STATUS,
+	HW_VAR_MEDIA_STATUS1,
+	HW_VAR_SET_OPMODE,
+	HW_VAR_MAC_ADDR,
+	HW_VAR_BSSID,
+	HW_VAR_INIT_RTS_RATE,
+	HW_VAR_BASIC_RATE,
+	HW_VAR_TXPAUSE,
+	HW_VAR_BCN_FUNC,
+	HW_VAR_CORRECT_TSF,
+	HW_VAR_CHECK_BSSID,
+	HW_VAR_MLME_DISCONNECT,
+	HW_VAR_MLME_SITESURVEY,
+	HW_VAR_MLME_JOIN,
+	HW_VAR_ON_RCR_AM,
+	HW_VAR_OFF_RCR_AM,
+	HW_VAR_BEACON_INTERVAL,
+	HW_VAR_SLOT_TIME,
+	HW_VAR_RESP_SIFS,
+	HW_VAR_ACK_PREAMBLE,
+	HW_VAR_SEC_CFG,
+	HW_VAR_BCN_VALID,
+	HW_VAR_RF_TYPE,
+	HW_VAR_DM_FLAG,
+	HW_VAR_DM_FUNC_OP,
+	HW_VAR_DM_FUNC_SET,
+	HW_VAR_DM_FUNC_CLR,
+	HW_VAR_CAM_EMPTY_ENTRY,
+	HW_VAR_CAM_INVALID_ALL,
+	HW_VAR_CAM_WRITE,
+	HW_VAR_CAM_READ,
+	HW_VAR_AC_PARAM_VO,
+	HW_VAR_AC_PARAM_VI,
+	HW_VAR_AC_PARAM_BE,
+	HW_VAR_AC_PARAM_BK,
+	HW_VAR_ACM_CTRL,
+	HW_VAR_AMPDU_MIN_SPACE,
+	HW_VAR_AMPDU_FACTOR,
+	HW_VAR_RXDMA_AGG_PG_TH,
+	HW_VAR_SET_RPWM,
+	HW_VAR_H2C_FW_PWRMODE,
+	HW_VAR_H2C_FW_JOINBSSRPT,
+	HW_VAR_FWLPS_RF_ON,
+	HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
+	HW_VAR_TDLS_WRCR,
+	HW_VAR_TDLS_INIT_CH_SEN,
+	HW_VAR_TDLS_RS_RCR,
+	HW_VAR_TDLS_DONE_CH_SEN,
+	HW_VAR_INITIAL_GAIN,
+	HW_VAR_TRIGGER_GPIO_0,
+	HW_VAR_BT_SET_COEXIST,
+	HW_VAR_BT_ISSUE_DELBA,
+	HW_VAR_CURRENT_ANTENNA,
+	HW_VAR_ANTENNA_DIVERSITY_LINK,
+	HW_VAR_ANTENNA_DIVERSITY_SELECT,
+	HW_VAR_SWITCH_EPHY_WoWLAN,
+	HW_VAR_EFUSE_BYTES,
+	HW_VAR_EFUSE_BT_BYTES,
+	HW_VAR_FIFO_CLEARN_UP,
+	HW_VAR_CHECK_TXBUF,
+	HW_VAR_APFM_ON_MAC, /* Auto FSM to Turn On, include clock, isolation,=
 power control for MAC only */
+	/*  The valid upper nav range for the HW updating, if the true value =
is larger than the upper range, the HW won't update it. */
+	/*  Unit in microsecond. 0 means disable this function. */
+	HW_VAR_NAV_UPPER,
+	HW_VAR_RPT_TIMER_SETTING,
+	HW_VAR_TX_RPT_MAX_MACID,
+	HW_VAR_H2C_MEDIA_STATUS_RPT,
+	HW_VAR_CHK_HI_QUEUE_EMPTY,
+	HW_VAR_READ_LLT_TAB,
+};
+
+enum hal_def_variable {
+	HAL_DEF_UNDERCORATEDSMOOTHEDPWDB,
+	HAL_DEF_IS_SUPPORT_ANT_DIV,
+	HAL_DEF_CURRENT_ANTENNA,
+	HAL_DEF_DRVINFO_SZ,
+	HAL_DEF_MAX_RECVBUF_SZ,
+	HAL_DEF_RX_PACKET_OFFSET,
+	HAL_DEF_DBG_DUMP_RXPKT,/* for dbg */
+	HAL_DEF_DBG_DM_FUNC,/* for dbg */
+	HAL_DEF_RA_DECISION_RATE,
+	HAL_DEF_RA_SGI,
+	HAL_DEF_PT_PWR_STATUS,
+	HW_VAR_MAX_RX_AMPDU_FACTOR,
+	HW_DEF_RA_INFO_DUMP,
+	HAL_DEF_DBG_DUMP_TXPKT,
+	HW_DEF_FA_CNT_DUMP,
+	HW_DEF_ODM_DBG_FLAG,
+};
+
+enum hal_odm_variable {
+	HAL_ODM_STA_INFO,
+	HAL_ODM_P2P_STATE,
+	HAL_ODM_WIFI_DISPLAY_STATE,
+};
+
+enum hal_intf_ps_func {
+	HAL_USB_SELECT_SUSPEND,
+	HAL_MAX_ID,
+};
+
+struct hal_ops {
+	u32 (*hal_power_on)(struct rtw_adapter *padapter);
+	u32 (*hal_init)(struct rtw_adapter *padapter);
+	u32 (*hal_deinit)(struct rtw_adapter *padapter);
+
+	void (*free_hal_data)(struct rtw_adapter *padapter);
+
+	u32 (*inirp_init)(struct rtw_adapter *padapter);
+	u32 (*inirp_deinit)(struct rtw_adapter *padapter);
+
+	s32 (*init_xmit_priv)(struct rtw_adapter *padapter);
+	void (*free_xmit_priv)(struct rtw_adapter *padapter);
+
+	s32 (*init_recv_priv)(struct rtw_adapter *padapter);
+	void (*free_recv_priv)(struct rtw_adapter *padapter);
+
+	void (*InitSwLeds)(struct rtw_adapter *padapter);
+	void (*DeInitSwLeds)(struct rtw_adapter *padapter);
+
+	void (*dm_init)(struct rtw_adapter *padapter);
+	void (*dm_deinit)(struct rtw_adapter *padapter);
+	void (*read_chip_version)(struct rtw_adapter *padapter);
+
+	void (*init_default_value)(struct rtw_adapter *padapter);
+
+	void (*intf_chip_configure)(struct rtw_adapter *padapter);
+
+	void (*read_adapter_info)(struct rtw_adapter *padapter);
+
+	void (*enable_interrupt)(struct rtw_adapter *padapter);
+	void (*disable_interrupt)(struct rtw_adapter *padapter);
+	s32 (*interrupt_handler)(struct rtw_adapter *padapter);
+	void (*set_bwmode_handler)(struct rtw_adapter *padapter,
+				   enum ht_channel_width Bandwidth, u8 Offset);
+	void (*set_channel_handler)(struct rtw_adapter *padapter, u8 channel)=
;
+
+	void (*hal_dm_watchdog)(struct rtw_adapter *padapter);
+
+	void (*SetHwRegHandler)(struct rtw_adapter *padapter,
+				u8 variable, u8 *val);
+	void (*GetHwRegHandler)(struct rtw_adapter *padapter,
+				u8 variable, u8 *val);
+
+	u8 (*GetHalDefVarHandler)(struct rtw_adapter *padapter,
+				  enum hal_def_variable eVariable,
+				  void *pValue);
+	u8 (*SetHalDefVarHandler)(struct rtw_adapter *padapter,
+				  enum hal_def_variable eVariable,
+				  void *pValue);
+
+	void (*GetHalODMVarHandler)(struct rtw_adapter *padapter,
+				    enum hal_odm_variable eVariable,
+				    void *pValue1, bool bSet);
+	void (*SetHalODMVarHandler)(struct rtw_adapter *padapter,
+				    enum hal_odm_variable eVariable,
+				    void *pValue1, bool bSet);
+
+	void (*UpdateRAMaskHandler)(struct rtw_adapter *padapter,
+				    u32 mac_id, u8 rssi_level);
+	void (*SetBeaconRelatedRegistersHandler)(struct rtw_adapter *padapter=
);
+
+	void (*Add_RateATid)(struct rtw_adapter *padapter, u32 bitmap,
+			     u8 arg, u8 rssi_level);
+	void (*run_thread)(struct rtw_adapter *padapter);
+	void (*cancel_thread)(struct rtw_adapter *padapter);
+
+	u8 (*interface_ps_func)(struct rtw_adapter *padapter,
+				enum hal_intf_ps_func efunc_id, u8 *val);
+
+	s32 (*hal_xmit)(struct rtw_adapter *padapter,
+			struct xmit_frame *pxmitframe);
+	s32 (*mgnt_xmit)(struct rtw_adapter *padapter,
+			 struct xmit_frame *pmgntframe);
+	s32 (*hal_xmitframe_enqueue)(struct rtw_adapter *padapter,
+				     struct xmit_frame *pxmitframe);
+
+	u32 (*read_bbreg)(struct rtw_adapter *padapter, u32 RegAddr,
+			  u32 BitMask);
+	void (*write_bbreg)(struct rtw_adapter *padapter, u32 RegAddr,
+			    u32 BitMask, u32 Data);
+	u32 (*read_rfreg)(struct rtw_adapter *padapter, u32 eRFPath,
+			  u32 RegAddr, u32 BitMask);
+	void (*write_rfreg)(struct rtw_adapter *padapter, u32 eRFPath,
+			    u32 RegAddr, u32 BitMask, u32 Data);
+
+	void (*EfusePowerSwitch)(struct rtw_adapter *padapter, u8 bWrite,
+				 u8 PwrState);
+	void (*ReadEFuse)(struct rtw_adapter *padapter, u8 efuseType,
+			  u16 _offset, u16 _size_byte, u8 *pbuf);
+	void (*EFUSEGetEfuseDefinition)(struct rtw_adapter *padapter,
+					u8 efuseType, u8 type, void *pOut);
+	u16 (*EfuseGetCurrentSize)(struct rtw_adapter *padapter, u8 efuseType=
);
+	int (*Efuse_PgPacketRead23a)(struct rtw_adapter *padapter,
+				     u8 offset, u8 *data);
+	int (*Efuse_PgPacketWrite23a)(struct rtw_adapter *padapter,
+				      u8 offset, u8 word_en, u8 *data);
+	u8 (*Efuse_WordEnableDataWrite23a)(struct rtw_adapter *padapter,
+					   u16 efuse_addr, u8 word_en,
+					   u8 *data);
+	bool (*Efuse_PgPacketWrite23a_BT)(struct rtw_adapter *padapter,
+					  u8 offset, u8 word_en, u8 *data);
+
+	void (*sreset_init_value23a)(struct rtw_adapter *padapter);
+	void (*sreset_reset_value23a)(struct rtw_adapter *padapter);
+	void (*silentreset)(struct rtw_adapter *padapter);
+	void (*sreset_xmit_status_check)(struct rtw_adapter *padapter);
+	void (*sreset_linked_status_check) (struct rtw_adapter *padapter);
+	u8 (*sreset_get_wifi_status23a)(struct rtw_adapter *padapter);
+	bool (*sreset_inprogress)(struct rtw_adapter *padapter);
+
+	void (*hal_notch_filter)(struct rtw_adapter *adapter, bool enable);
+	void (*hal_reset_security_engine)(struct rtw_adapter *adapter);
+	s32 (*c2h_handler)(struct rtw_adapter *padapter, struct c2h_evt_hdr *=
c2h_evt);
+	c2h_id_filter c2h_id_filter_ccx;
+};
+
+enum rt_eeprom_type {
+	EEPROM_93C46,
+	EEPROM_93C56,
+	EEPROM_BOOT_EFUSE,
+};
+
+
+
+#define RF_CHANGE_BY_INIT	0
+#define RF_CHANGE_BY_IPS	BIT28
+#define RF_CHANGE_BY_PS		BIT29
+#define RF_CHANGE_BY_HW		BIT30
+#define RF_CHANGE_BY_SW		BIT31
+
+enum hardware_type {
+	HARDWARE_TYPE_RTL8180,
+	HARDWARE_TYPE_RTL8185,
+	HARDWARE_TYPE_RTL8187,
+	HARDWARE_TYPE_RTL8188,
+	HARDWARE_TYPE_RTL8190P,
+	HARDWARE_TYPE_RTL8192E,
+	HARDWARE_TYPE_RTL819xU,
+	HARDWARE_TYPE_RTL8192SE,
+	HARDWARE_TYPE_RTL8192SU,
+	HARDWARE_TYPE_RTL8192CE,
+	HARDWARE_TYPE_RTL8192CU,
+	HARDWARE_TYPE_RTL8192DE,
+	HARDWARE_TYPE_RTL8192DU,
+	HARDWARE_TYPE_RTL8723AE,
+	HARDWARE_TYPE_RTL8723AU,
+	HARDWARE_TYPE_RTL8723AS,
+	HARDWARE_TYPE_RTL8188EE,
+	HARDWARE_TYPE_RTL8188EU,
+	HARDWARE_TYPE_RTL8188ES,
+	HARDWARE_TYPE_MAX,
+};
+
+#define GET_EEPROM_EFUSE_PRIV(adapter) (&adapter->eeprompriv)
+#define is_boot_from_eeprom(adapter) (adapter->eeprompriv.EepromOrEfus=
e)
+
+extern int rtw_ht_enable23A;
+extern int rtw_cbw40_enable23A;
+extern int rtw_ampdu_enable23A;/* for enable tx_ampdu */
+
+void rtw_hal_def_value_init23a(struct rtw_adapter *padapter);
+int pm_netdev_open23a(struct net_device *pnetdev, u8 bnormal);
+int rtw_resume_process23a(struct rtw_adapter *padapter);
+
+void	rtw_hal_free_data23a(struct rtw_adapter *padapter);
+
+void rtw_hal_dm_init23a(struct rtw_adapter *padapter);
+void rtw_hal_dm_deinit23a(struct rtw_adapter *padapter);
+void rtw_hal_sw_led_init23a(struct rtw_adapter *padapter);
+void rtw_hal_sw_led_deinit23a(struct rtw_adapter *padapter);
+
+u32 rtw_hal_power_on23a(struct rtw_adapter *padapter);
+uint rtw_hal_init23a(struct rtw_adapter *padapter);
+uint rtw_hal_deinit23a(struct rtw_adapter *padapter);
+void rtw_hal_stop(struct rtw_adapter *padapter);
+void rtw_hal_set_hwreg23a(struct rtw_adapter *padapter, u8 variable, u=
8 *val);
+void rtw23a_hal_get_hwreg(struct rtw_adapter *padapter, u8 variable, u=
8 *val);
+
+void rtw_hal_chip_configure23a(struct rtw_adapter *padapter);
+void rtw_hal_read_chip_info23a(struct rtw_adapter *padapter);
+void rtw_hal_read_chip_version23a(struct rtw_adapter *padapter);
+
+u8 rtw_hal_set_def_var23a(struct rtw_adapter *padapter,
+			  enum hal_def_variable eVariable,
+			  void *pValue);
+u8 rtw_hal_get_def_var23a(struct rtw_adapter *padapter,
+			  enum hal_def_variable eVariable,
+			  void *pValue);
+
+void rtw_hal_set_odm_var23a(struct rtw_adapter *padapter,
+			    enum hal_odm_variable eVariable,
+			    void *pValue1, bool bSet);
+void rtw_hal_get_odm_var23a(struct rtw_adapter *padapter,
+			    enum hal_odm_variable eVariable,
+			    void *pValue1, bool bSet);
+
+void rtw_hal_enable_interrupt23a(struct rtw_adapter *padapter);
+void rtw_hal_disable_interrupt23a(struct rtw_adapter *padapter);
+
+u32 rtw_hal_inirp_init23a(struct rtw_adapter *padapter);
+u32 rtw_hal_inirp_deinit23a(struct rtw_adapter *padapter);
+
+u8 rtw_hal_intf_ps_func23a(struct rtw_adapter *padapter,
+			   enum hal_intf_ps_func efunc_id, u8 *val);
+
+s32 rtw_hal_xmit23aframe_enqueue(struct rtw_adapter *padapter,
+				 struct xmit_frame *pxmitframe);
+s32 rtw_hal_xmit23a(struct rtw_adapter *padapter,
+		    struct xmit_frame *pxmitframe);
+s32 rtw_hal_mgnt_xmit23a(struct rtw_adapter *padapter,
+			 struct xmit_frame *pmgntframe);
+
+s32	rtw_hal_init23a_xmit_priv(struct rtw_adapter *padapter);
+void	rtw_hal_free_xmit_priv23a(struct rtw_adapter *padapter);
+
+s32	rtw_hal_init23a_recv_priv(struct rtw_adapter *padapter);
+void	rtw_hal_free_recv_priv23a(struct rtw_adapter *padapter);
+
+void rtw_hal_update_ra_mask23a(struct sta_info *psta, u8 rssi_level);
+void	rtw_hal_add_ra_tid23a(struct rtw_adapter *padapter, u32 bitmap, u=
8 arg, u8 rssi_level);
+void	rtw_hal_clone_data(struct rtw_adapter *dst_padapter, struct rtw_a=
dapter *src_padapter);
+void	rtw_hal_start_thread23a(struct rtw_adapter *padapter);
+void	rtw_hal_stop_thread23a(struct rtw_adapter *padapter);
+
+void rtw_hal_bcn_related_reg_setting23a(struct rtw_adapter *padapter);
+
+u32	rtw_hal_read_bbreg23a(struct rtw_adapter *padapter, u32 RegAddr, u=
32 BitMask);
+void	rtw_hal_write_bbreg23a(struct rtw_adapter *padapter, u32 RegAddr,=
 u32 BitMask, u32 Data);
+u32	rtw_hal_read_rfreg23a(struct rtw_adapter *padapter, u32 eRFPath, u=
32 RegAddr, u32 BitMask);
+void	rtw_hal_write_rfreg23a(struct rtw_adapter *padapter, u32 eRFPath,=
 u32 RegAddr, u32 BitMask, u32 Data);
+
+s32	rtw_hal_interrupt_handler23a(struct rtw_adapter *padapter);
+
+void	rtw_hal_set_bwmode23a(struct rtw_adapter *padapter,
+			   enum ht_channel_width Bandwidth, u8 Offset);
+void	rtw_hal_set_chan23a(struct rtw_adapter *padapter, u8 channel);
+void	rtw_hal_dm_watchdog23a(struct rtw_adapter *padapter);
+
+void rtw_hal_sreset_init23a(struct rtw_adapter *padapter);
+void rtw_hal_sreset_reset23a(struct rtw_adapter *padapter);
+void rtw_hal_sreset_reset23a_value23a(struct rtw_adapter *padapter);
+void rtw_hal_sreset_xmit_status_check23a(struct rtw_adapter *padapter)=
;
+void rtw_hal_sreset_linked_status_check23a (struct rtw_adapter *padapt=
er);
+u8   rtw_hal_sreset_get_wifi_status23a(struct rtw_adapter *padapter);
+bool rtw_hal_sreset_inprogress(struct rtw_adapter *padapter);
+
+void rtw_hal_notch_filter23a(struct rtw_adapter *adapter, bool enable)=
;
+void rtw_hal_reset_security_engine23a(struct rtw_adapter *adapter);
+
+s32 rtw_hal_c2h_handler23a(struct rtw_adapter *adapter, struct c2h_evt=
_hdr *c2h_evt);
+c2h_id_filter rtw_hal_c2h_id_filter_ccx23a(struct rtw_adapter *adapter=
);
+
+#endif /* __HAL_INTF_H__ */
diff --git a/drivers/staging/rtl8723au/include/ieee80211.h b/drivers/st=
aging/rtl8723au/include/ieee80211.h
new file mode 100644
index 0000000..28e4ab2
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/ieee80211.h
@@ -0,0 +1,603 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __IEEE80211_H
+#define __IEEE80211_H
+
+#include <osdep_service.h>
+#include <drv_types.h>
+#include "linux/ieee80211.h"
+#include "wifi.h"
+
+#include <linux/wireless.h>
+
+#if (WIRELESS_EXT < 22)
+#error "Obsolete pre 2007 wireless extensions are not supported"
+#endif
+
+
+#define MGMT_QUEUE_NUM 5
+
+#ifdef CONFIG_8723AU_AP_MODE
+
+/* STA flags */
+#define WLAN_STA_AUTH BIT(0)
+#define WLAN_STA_ASSOC BIT(1)
+#define WLAN_STA_PS BIT(2)
+#define WLAN_STA_TIM BIT(3)
+#define WLAN_STA_PERM BIT(4)
+#define WLAN_STA_AUTHORIZED BIT(5)
+#define WLAN_STA_PENDING_POLL BIT(6) /* pending activity poll not ACKe=
d */
+#define WLAN_STA_SHORT_PREAMBLE BIT(7)
+#define WLAN_STA_PREAUTH BIT(8)
+#define WLAN_STA_WME BIT(9)
+#define WLAN_STA_MFP BIT(10)
+#define WLAN_STA_HT BIT(11)
+#define WLAN_STA_WPS BIT(12)
+#define WLAN_STA_MAYBE_WPS BIT(13)
+#define WLAN_STA_NONERP BIT(31)
+
+#endif
+
+#define IEEE_CMD_SET_WPA_PARAM			1
+#define IEEE_CMD_SET_WPA_IE				2
+#define IEEE_CMD_SET_ENCRYPTION			3
+
+#define	IEEE_CRYPT_ALG_NAME_LEN			16
+
+#define WPA_CIPHER_NONE		BIT(0)
+#define WPA_CIPHER_WEP40	BIT(1)
+#define WPA_CIPHER_WEP104 BIT(2)
+#define WPA_CIPHER_TKIP		BIT(3)
+#define WPA_CIPHER_CCMP		BIT(4)
+
+
+
+#define WPA_SELECTOR_LEN 4
+extern u8 RTW_WPA_OUI23A_TYPE[] ;
+extern u16 RTW_WPA_VERSION23A ;
+extern u8 WPA_AUTH_KEY_MGMT_NONE23A[];
+extern u8 WPA_AUTH_KEY_MGMT_UNSPEC_802_1X23A[];
+extern u8 WPA_AUTH_KEY_MGMT_PSK_OVER_802_1X23A[];
+extern u8 WPA_CIPHER_SUITE_NONE23A[];
+extern u8 WPA_CIPHER_SUITE_WEP4023A[];
+extern u8 WPA_CIPHER_SUITE_TKIP23A[];
+extern u8 WPA_CIPHER_SUITE_WRAP23A[];
+extern u8 WPA_CIPHER_SUITE_CCMP23A[];
+extern u8 WPA_CIPHER_SUITE_WEP10423A[];
+
+
+#define RSN_HEADER_LEN 4
+#define RSN_SELECTOR_LEN 4
+
+extern u16 RSN_VERSION_BSD23A;
+extern u8 RSN_AUTH_KEY_MGMT_UNSPEC_802_1X23A[];
+extern u8 RSN_AUTH_KEY_MGMT_PSK_OVER_802_1X23A[];
+extern u8 RSN_CIPHER_SUITE_NONE23A[];
+extern u8 RSN_CIPHER_SUITE_WEP4023A[];
+extern u8 RSN_CIPHER_SUITE_TKIP23A[];
+extern u8 RSN_CIPHER_SUITE_WRAP23A[];
+extern u8 RSN_CIPHER_SUITE_CCMP23A[];
+extern u8 RSN_CIPHER_SUITE_WEP10423A[];
+
+enum ratr_table_mode {
+	RATR_INX_WIRELESS_NGB =3D 0,	/*  BGN 40 Mhz 2SS 1SS */
+	RATR_INX_WIRELESS_NG =3D 1,	/*  GN or N */
+	RATR_INX_WIRELESS_NB =3D 2,	/*  BGN 20 Mhz 2SS 1SS  or BN */
+	RATR_INX_WIRELESS_N =3D 3,
+	RATR_INX_WIRELESS_GB =3D 4,
+	RATR_INX_WIRELESS_G =3D 5,
+	RATR_INX_WIRELESS_B =3D 6,
+	RATR_INX_WIRELESS_MC =3D 7,
+	RATR_INX_WIRELESS_AC_N =3D 8,
+};
+
+enum NETWORK_TYPE
+{
+    WIRELESS_INVALID =3D 0,
+    /* Sub-Element */
+    WIRELESS_11B =3D BIT(0), /*  tx: cck only , rx: cck only, hw: cck =
*/
+    WIRELESS_11G =3D BIT(1), /*  tx: ofdm only, rx: ofdm & cck, hw: cc=
k & ofdm */
+    WIRELESS_11A =3D BIT(2), /*  tx: ofdm only, rx: ofdm only, hw: ofd=
m only */
+    WIRELESS_11_24N =3D BIT(3), /*  tx: MCS only, rx: MCS & cck, hw: M=
CS & cck */
+    WIRELESS_11_5N =3D BIT(4), /*  tx: MCS only, rx: MCS & ofdm, hw: o=
fdm only */
+	/* WIRELESS_AUTO		=3D BIT(5), */
+	WIRELESS_AC		=3D BIT(6),
+
+    /* Combination */
+    WIRELESS_11BG =3D (WIRELESS_11B|WIRELESS_11G), /*  tx: cck & ofdm,=
 rx: cck & ofdm & MCS, hw: cck & ofdm */
+    WIRELESS_11G_24N =3D (WIRELESS_11G|WIRELESS_11_24N), /*  tx: ofdm =
& MCS, rx: ofdm & cck & MCS, hw: cck & ofdm */
+    WIRELESS_11A_5N =3D (WIRELESS_11A|WIRELESS_11_5N), /*  tx: ofdm & =
MCS, rx: ofdm & MCS, hw: ofdm only */
+    WIRELESS_11BG_24N =3D (WIRELESS_11B|WIRELESS_11G|WIRELESS_11_24N),=
 /*  tx: ofdm & cck & MCS, rx: ofdm & cck & MCS, hw: ofdm & cck */
+    WIRELESS_11AGN =3D (WIRELESS_11A|WIRELESS_11G|WIRELESS_11_24N|WIRE=
LESS_11_5N), /*  tx: ofdm & MCS, rx: ofdm & MCS, hw: ofdm only */
+    WIRELESS_11ABGN =3D (WIRELESS_11A|WIRELESS_11B|WIRELESS_11G|WIRELE=
SS_11_24N|WIRELESS_11_5N),
+};
+
+#define SUPPORTED_24G_NETTYPE_MSK (WIRELESS_11B | WIRELESS_11G | WIREL=
ESS_11_24N)
+#define SUPPORTED_5G_NETTYPE_MSK (WIRELESS_11A | WIRELESS_11_5N)
+
+#define IsSupported24G(NetType) ((NetType) & SUPPORTED_24G_NETTYPE_MSK=
 ? true : false)
+#define IsSupported5G(NetType) ((NetType) & SUPPORTED_5G_NETTYPE_MSK ?=
 true : false)
+
+#define IsEnableHWCCK(NetType) IsSupported24G(NetType)
+#define IsEnableHWOFDM(NetType) ((NetType) & (WIRELESS_11G|WIRELESS_11=
_24N|SUPPORTED_5G_NETTYPE_MSK) ? true : false)
+
+#define IsSupportedRxCCK(NetType) IsEnableHWCCK(NetType)
+#define IsSupportedRxOFDM(NetType) IsEnableHWOFDM(NetType)
+#define IsSupportedRxMCS(NetType) IsEnableHWOFDM(NetType)
+
+#define IsSupportedTxCCK(NetType) ((NetType) & (WIRELESS_11B) ? true :=
 false)
+#define IsSupportedTxOFDM(NetType) ((NetType) & (WIRELESS_11G|WIRELESS=
_11A) ? true : false)
+#define IsSupportedTxMCS(NetType) ((NetType) & (WIRELESS_11_24N|WIRELE=
SS_11_5N) ? true : false)
+
+
+struct ieee_param {
+	u32 cmd;
+	u8 sta_addr[ETH_ALEN];
+	union {
+		struct {
+			u8 name;
+			u32 value;
+		} wpa_param;
+		struct {
+			u32 len;
+			u8 reserved[32];
+			u8 data[0];
+		} wpa_ie;
+	        struct{
+			int command;
+			int reason_code;
+		} mlme;
+		struct {
+			u8 alg[IEEE_CRYPT_ALG_NAME_LEN];
+			u8 set_tx;
+			u32 err;
+			u8 idx;
+			u8 seq[8]; /* sequence counter (set: RX, get: TX) */
+			u16 key_len;
+			u8 key[0];
+		} crypt;
+#ifdef CONFIG_8723AU_AP_MODE
+		struct {
+			u16 aid;
+			u16 capability;
+			int flags;
+			u8 tx_supp_rates[16];
+			struct ieee80211_ht_cap ht_cap;
+		} add_sta;
+		struct {
+			u8	reserved[2];/* for set max_num_sta */
+			u8	buf[0];
+		} bcn_ie;
+#endif
+
+	} u;
+};
+
+
+#define MIN_FRAG_THRESHOLD     256U
+#define	MAX_FRAG_THRESHOLD     2346U
+
+/* QoS,QOS */
+#define NORMAL_ACK			0
+#define NO_ACK				1
+#define NON_EXPLICIT_ACK	2
+#define BLOCK_ACK			3
+
+/* IEEE 802.11 defines */
+
+#define P80211_OUI_LEN 3
+
+struct ieee80211_snap_hdr {
+
+        u8    dsap;   /* always 0xAA */
+        u8    ssap;   /* always 0xAA */
+        u8    ctrl;   /* always 0x03 */
+        u8    oui[P80211_OUI_LEN];    /* organizational universal id *=
/
+
+} __attribute__ ((packed));
+
+
+#define SNAP_SIZE sizeof(struct ieee80211_snap_hdr)
+
+#define WLAN_FC_GET_TYPE(fc) ((fc) & IEEE80211_FCTL_FTYPE)
+#define WLAN_FC_GET_STYPE(fc) ((fc) & IEEE80211_FCTL_STYPE)
+
+#define WLAN_QC_GET_TID(qc) ((qc) & 0x0f)
+
+#define WLAN_GET_SEQ_FRAG(seq) ((seq) & RTW_IEEE80211_SCTL_FRAG)
+#define WLAN_GET_SEQ_SEQ(seq)  ((seq) & RTW_IEEE80211_SCTL_SEQ)
+
+
+#define WLAN_REASON_JOIN_WRONG_CHANNEL       65534
+#define WLAN_REASON_EXPIRATION_CHK 65535
+
+
+
+#define IEEE80211_STATMASK_SIGNAL (1<<0)
+#define IEEE80211_STATMASK_RSSI (1<<1)
+#define IEEE80211_STATMASK_NOISE (1<<2)
+#define IEEE80211_STATMASK_RATE (1<<3)
+#define IEEE80211_STATMASK_WEMASK 0x7
+
+
+#define IEEE80211_CCK_MODULATION    (1<<0)
+#define IEEE80211_OFDM_MODULATION   (1<<1)
+
+#define IEEE80211_24GHZ_BAND     (1<<0)
+#define IEEE80211_52GHZ_BAND     (1<<1)
+
+#define IEEE80211_CCK_RATE_LEN			4
+#define IEEE80211_NUM_OFDM_RATESLEN	8
+
+
+#define IEEE80211_CCK_RATE_1MB		        0x02
+#define IEEE80211_CCK_RATE_2MB		        0x04
+#define IEEE80211_CCK_RATE_5MB		        0x0B
+#define IEEE80211_CCK_RATE_11MB		        0x16
+#define IEEE80211_OFDM_RATE_LEN			8
+#define IEEE80211_OFDM_RATE_6MB		        0x0C
+#define IEEE80211_OFDM_RATE_9MB		        0x12
+#define IEEE80211_OFDM_RATE_12MB		0x18
+#define IEEE80211_OFDM_RATE_18MB		0x24
+#define IEEE80211_OFDM_RATE_24MB		0x30
+#define IEEE80211_OFDM_RATE_36MB		0x48
+#define IEEE80211_OFDM_RATE_48MB		0x60
+#define IEEE80211_OFDM_RATE_54MB		0x6C
+#define IEEE80211_BASIC_RATE_MASK		0x80
+
+#define IEEE80211_CCK_RATE_1MB_MASK		(1<<0)
+#define IEEE80211_CCK_RATE_2MB_MASK		(1<<1)
+#define IEEE80211_CCK_RATE_5MB_MASK		(1<<2)
+#define IEEE80211_CCK_RATE_11MB_MASK		(1<<3)
+#define IEEE80211_OFDM_RATE_6MB_MASK		(1<<4)
+#define IEEE80211_OFDM_RATE_9MB_MASK		(1<<5)
+#define IEEE80211_OFDM_RATE_12MB_MASK		(1<<6)
+#define IEEE80211_OFDM_RATE_18MB_MASK		(1<<7)
+#define IEEE80211_OFDM_RATE_24MB_MASK		(1<<8)
+#define IEEE80211_OFDM_RATE_36MB_MASK		(1<<9)
+#define IEEE80211_OFDM_RATE_48MB_MASK		(1<<10)
+#define IEEE80211_OFDM_RATE_54MB_MASK		(1<<11)
+
+#define IEEE80211_CCK_RATES_MASK	        0x0000000F
+#define IEEE80211_CCK_BASIC_RATES_MASK	(IEEE80211_CCK_RATE_1MB_MASK | =
\
+	IEEE80211_CCK_RATE_2MB_MASK)
+#define IEEE80211_CCK_DEFAULT_RATES_MASK	(IEEE80211_CCK_BASIC_RATES_MA=
SK | \
+        IEEE80211_CCK_RATE_5MB_MASK | \
+        IEEE80211_CCK_RATE_11MB_MASK)
+
+#define IEEE80211_OFDM_RATES_MASK		0x00000FF0
+#define IEEE80211_OFDM_BASIC_RATES_MASK	(IEEE80211_OFDM_RATE_6MB_MASK =
| \
+	IEEE80211_OFDM_RATE_12MB_MASK | \
+	IEEE80211_OFDM_RATE_24MB_MASK)
+#define IEEE80211_OFDM_DEFAULT_RATES_MASK	(IEEE80211_OFDM_BASIC_RATES_=
MASK | \
+	IEEE80211_OFDM_RATE_9MB_MASK  | \
+	IEEE80211_OFDM_RATE_18MB_MASK | \
+	IEEE80211_OFDM_RATE_36MB_MASK | \
+	IEEE80211_OFDM_RATE_48MB_MASK | \
+	IEEE80211_OFDM_RATE_54MB_MASK)
+#define IEEE80211_DEFAULT_RATES_MASK (IEEE80211_OFDM_DEFAULT_RATES_MAS=
K | \
+                                IEEE80211_CCK_DEFAULT_RATES_MASK)
+
+#define IEEE80211_NUM_OFDM_RATES	    8
+#define IEEE80211_NUM_CCK_RATES	            4
+#define IEEE80211_OFDM_SHIFT_MASK_A         4
+
+#define WEP_KEYS 4
+#define WEP_KEY_LEN 13
+
+
+
+/*
+
+ 802.11 data frame from AP
+
+      ,---------------------------------------------------------------=
----.
+Bytes |  2   |  2   |    6    |    6    |    6    |  2   | 0..2312 |  =
 4  |
+      |------|------|---------|---------|---------|------|---------|--=
----|
+Desc. | ctrl | dura |  DA/RA  |   TA    |    SA   | Sequ |  frame  |  =
fcs |
+      |      | tion | (BSSID) |         |         | ence |  data   |  =
    |
+      `---------------------------------------------------------------=
----'
+
+Total: 28-2340 bytes
+
+*/
+
+struct ieee80211_header_data {
+	u16 frame_ctl;
+	u16 duration_id;
+	u8 addr1[6];
+	u8 addr2[6];
+	u8 addr3[6];
+	u16 seq_ctrl;
+};
+
+struct ieee80211_info_element_hdr {
+	u8 id;
+	u8 len;
+} __attribute__ ((packed));
+
+struct ieee80211_info_element {
+	u8 id;
+	u8 len;
+	u8 data[0];
+} __attribute__ ((packed));
+
+
+struct ieee80211_txb {
+	u8 nr_frags;
+	u8 encrypted;
+	u16 reserved;
+	u16 frag_size;
+	u16 payload_size;
+	struct sk_buff *fragments[0];
+};
+
+
+/* MAX_RATES_LENGTH needs to be 12.  The spec says 8, and many APs
+ * only use 8, and then use extended rates for the remaining supported
+ * rates.  Other APs, however, stick all of their supported rates on t=
he
+ * main rates information element... */
+#define MAX_RATES_LENGTH                  ((u8)12)
+#define MAX_RATES_EX_LENGTH               ((u8)16)
+#define MAX_CHANNEL_NUMBER                 161
+
+#define MAX_WPA_IE_LEN (256)
+#define MAX_WPS_IE_LEN (512)
+#define MAX_P2P_IE_LEN (256)
+#define MAX_WFD_IE_LEN (128)
+
+#define IW_ESSID_MAX_SIZE 32
+
+/*
+join_res:
+-1: authentication fail
+-2: association fail
+> 0: TID
+*/
+
+#define DEFAULT_MAX_SCAN_AGE (15 * HZ)
+#define DEFAULT_FTS 2346
+#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
+#define MAC_ARG(x) ((u8*)(x))[0],((u8*)(x))[1],((u8*)(x))[2],((u8*)(x)=
)[3],((u8*)(x))[4],((u8*)(x))[5]
+
+#define CFG_IEEE80211_RESERVE_FCS (1<<0)
+#define CFG_IEEE80211_COMPUTE_FCS (1<<1)
+
+#define MAXTID	16
+
+#define IEEE_A            (1<<0)
+#define IEEE_B            (1<<1)
+#define IEEE_G            (1<<2)
+#define IEEE_MODE_MASK    (IEEE_A|IEEE_B|IEEE_G)
+
+/* Baron move to ieee80211.c */
+int ieee80211_is_empty_essid23a(const char *essid, int essid_len);
+
+enum _PUBLIC_ACTION{
+	ACT_PUBLIC_BSSCOEXIST =3D 0, /*  20/40 BSS Coexistence */
+	ACT_PUBLIC_DSE_ENABLE =3D 1,
+	ACT_PUBLIC_DSE_DEENABLE =3D 2,
+	ACT_PUBLIC_DSE_REG_LOCATION =3D 3,
+	ACT_PUBLIC_EXT_CHL_SWITCH =3D 4,
+	ACT_PUBLIC_DSE_MSR_REQ =3D 5,
+	ACT_PUBLIC_DSE_MSR_RPRT =3D 6,
+	ACT_PUBLIC_MP =3D 7, /*  Measurement Pilot */
+	ACT_PUBLIC_DSE_PWR_CONSTRAINT =3D 8,
+	ACT_PUBLIC_VENDOR =3D 9, /*  for WIFI_DIRECT */
+	ACT_PUBLIC_GAS_INITIAL_REQ =3D 10,
+	ACT_PUBLIC_GAS_INITIAL_RSP =3D 11,
+	ACT_PUBLIC_GAS_COMEBACK_REQ =3D 12,
+	ACT_PUBLIC_GAS_COMEBACK_RSP =3D 13,
+	ACT_PUBLIC_TDLS_DISCOVERY_RSP =3D 14,
+	ACT_PUBLIC_LOCATION_TRACK =3D 15,
+	ACT_PUBLIC_MAX
+};
+
+#define WME_OUI_TYPE 2
+#define WME_OUI_SUBTYPE_INFORMATION_ELEMENT 0
+#define WME_OUI_SUBTYPE_PARAMETER_ELEMENT 1
+#define WME_OUI_SUBTYPE_TSPEC_ELEMENT 2
+#define WME_VERSION 1
+
+
+#define OUI_BROADCOM 0x00904c /* Broadcom (Epigram) */
+
+#define VENDOR_HT_CAPAB_OUI_TYPE 0x33 /* 00-90-4c:0x33 */
+
+/* Represent channel details, subset of ieee80211_channel */
+struct rtw_ieee80211_channel {
+	/* enum ieee80211_band band; */
+	/* u16 center_freq; */
+	u16 hw_value;
+	u32 flags;
+	/* int max_antenna_gain; */
+	/* int max_power; */
+	/* int max_reg_power; */
+	/* bool beacon_found; */
+	/* u32 orig_flags; */
+	/* int orig_mag; */
+	/* int orig_mpwr; */
+};
+
+#define CHAN_FMT \
+	/*"band:%d, "*/ \
+	/*"center_freq:%u, "*/ \
+	"hw_value:%u, " \
+	"flags:0x%08x" \
+	/*"max_antenna_gain:%d\n"*/ \
+	/*"max_power:%d\n"*/ \
+	/*"max_reg_power:%d\n"*/ \
+	/*"beacon_found:%u\n"*/ \
+	/*"orig_flags:0x%08x\n"*/ \
+	/*"orig_mag:%d\n"*/ \
+	/*"orig_mpwr:%d\n"*/
+
+#define CHAN_ARG(channel) \
+	/*(channel)->band*/ \
+	/*, (channel)->center_freq*/ \
+	(channel)->hw_value \
+	, (channel)->flags \
+	/*, (channel)->max_antenna_gain*/ \
+	/*, (channel)->max_power*/ \
+	/*, (channel)->max_reg_power*/ \
+	/*, (channel)->beacon_found*/ \
+	/*, (channel)->orig_flags*/ \
+	/*, (channel)->orig_mag*/ \
+	/*, (channel)->orig_mpwr*/ \
+
+/* Parsed Information Elements */
+struct rtw_ieee802_11_elems {
+	u8 *ssid;
+	u8 ssid_len;
+	u8 *supp_rates;
+	u8 supp_rates_len;
+	u8 *fh_params;
+	u8 fh_params_len;
+	u8 *ds_params;
+	u8 ds_params_len;
+	u8 *cf_params;
+	u8 cf_params_len;
+	u8 *tim;
+	u8 tim_len;
+	u8 *ibss_params;
+	u8 ibss_params_len;
+	u8 *challenge;
+	u8 challenge_len;
+	u8 *erp_info;
+	u8 erp_info_len;
+	u8 *ext_supp_rates;
+	u8 ext_supp_rates_len;
+	u8 *wpa_ie;
+	u8 wpa_ie_len;
+	u8 *rsn_ie;
+	u8 rsn_ie_len;
+	u8 *wme;
+	u8 wme_len;
+	u8 *wme_tspec;
+	u8 wme_tspec_len;
+	u8 *wps_ie;
+	u8 wps_ie_len;
+	u8 *power_cap;
+	u8 power_cap_len;
+	u8 *supp_channels;
+	u8 supp_channels_len;
+	u8 *mdie;
+	u8 mdie_len;
+	u8 *ftie;
+	u8 ftie_len;
+	u8 *timeout_int;
+	u8 timeout_int_len;
+	u8 *ht_capabilities;
+	u8 ht_capabilities_len;
+	u8 *ht_operation;
+	u8 ht_operation_len;
+	u8 *vendor_ht_cap;
+	u8 vendor_ht_cap_len;
+};
+
+enum parse_res {
+	ParseOK =3D 0,
+	ParseUnknown =3D 1,
+	ParseFailed =3D -1
+};
+
+enum parse_res rtw_ieee802_11_parse_elems23a(u8 *start, uint len,
+				struct rtw_ieee802_11_elems *elems,
+				int show_errors);
+
+u8 *rtw_set_fixed_ie23a(unsigned char *pbuf, unsigned int len, unsigne=
d char *source, unsigned int *frlen);
+u8 *rtw_set_ie23a(u8 *pbuf, int index, uint len, u8 *source, uint *frl=
en);
+
+enum secondary_ch_offset {
+	SCN =3D 0, /* no secondary channel */
+	SCA =3D 1, /* secondary channel above */
+	SCB =3D 3,  /* secondary channel below */
+};
+u8 secondary_ch_offset_to_hal_ch_offset23a(u8 ch_offset);
+u8 hal_ch_offset_to_secondary_ch_offset23a(u8 ch_offset);
+u8 *rtw_set_ie23a_ch_switch(u8 *buf, u32 *buf_len, u8 ch_switch_mode, =
u8 new_ch, u8 ch_switch_cnt);
+u8 *rtw_set_ie23a_secondary_ch_offset(u8 *buf, u32 *buf_len, u8 second=
ary_ch_offset);
+u8 *rtw_set_ie23a_mesh_ch_switch_parm(u8 *buf, u32 *buf_len, u8 ttl, u=
8 flags, u16 reason, u16 precedence);
+
+u8 *rtw_get_ie23a(u8*pbuf, int index, int *len, int limit);
+u8 *rtw_get_ie23a_ex(u8 *in_ie, uint in_len, u8 eid, u8 *oui, u8 oui_l=
en, u8 *ie, uint *ielen);
+int rtw_ies_remove_ie23a(u8 *ies, uint *ies_len, uint offset, u8 eid, =
u8 *oui, u8 oui_len);
+
+void rtw_set_supported_rate23a(u8* SupportedRates, uint mode) ;
+
+unsigned char *rtw_get_wpa_ie23a(unsigned char *pie, int *wpa_ie_len, =
int limit);
+unsigned char *rtw_get_wpa2_ie23a(unsigned char *pie, int *rsn_ie_len,=
 int limit);
+int rtw_get_wpa_cipher_suite23a(u8 *s);
+int rtw_get_wpa2_cipher_suite23a(u8 *s);
+int rtw_parse_wpa_ie23a(u8* wpa_ie, int wpa_ie_len, int *group_cipher,=
 int *pairwise_cipher, int *is_8021x);
+int rtw_parse_wpa2_ie23a(u8* wpa_ie, int wpa_ie_len, int *group_cipher=
, int *pairwise_cipher, int *is_8021x);
+
+int rtw_get_sec_ie23a(u8 *in_ie,uint in_len,u8 *rsn_ie,u16 *rsn_len,u8=
 *wpa_ie,u16 *wpa_len);
+
+u8 rtw_is_wps_ie23a(u8 *ie_ptr, uint *wps_ielen);
+u8 *rtw_get_wps_ie23a(u8 *in_ie, uint in_len, u8 *wps_ie, uint *wps_ie=
len);
+u8 *rtw_get_wps_attr23a(u8 *wps_ie, uint wps_ielen, u16 target_attr_id=
 ,u8 *buf_attr, u32 *len_attr);
+u8 *rtw_get_wps_attr_content23a(u8 *wps_ie, uint wps_ielen, u16 target=
_attr_id ,u8 *buf_content, uint *len_content);
+
+/**
+ * for_each_ie - iterate over continuous IEs
+ * @ie:
+ * @buf:
+ * @buf_len:
+ */
+#define for_each_ie(ie, buf, buf_len) \
+	for (ie =3D (void*)buf; (((u8*)ie) - ((u8*)buf) + 1) < buf_len; ie =3D=
 (void*)(((u8*)ie) + *(((u8*)ie)+1) + 2))
+
+void dump_ies23a(u8 *buf, u32 buf_len);
+void dump_wps_ie23a(u8 *ie, u32 ie_len);
+
+#ifdef CONFIG_8723AU_P2P
+void dump_p2p_ie23a(u8 *ie, u32 ie_len);
+u8 *rtw_get_p2p_ie23a(u8 *in_ie, int in_len, u8 *p2p_ie, uint *p2p_iel=
en);
+u8 *rtw_get_p2p_attr23a(u8 *p2p_ie, uint p2p_ielen, u8 target_attr_id =
,u8 *buf_attr, u32 *len_attr);
+u8 *rtw_get_p2p_attr23a_content(u8 *p2p_ie, uint p2p_ielen, u8 target_=
attr_id ,u8 *buf_content, uint *len_content);
+u32 rtw_set_p2p_attr_content23a(u8 *pbuf, u8 attr_id, u16 attr_len, u8=
 *pdata_attr);
+void rtw_wlan_bssid_ex_remove_p2p_attr23a(struct wlan_bssid_ex *bss_ex=
, u8 attr_id);
+#endif
+
+#ifdef CONFIG_8723AU_P2P
+int rtw_get_wfd_ie(u8 *in_ie, int in_len, u8 *wfd_ie, uint *wfd_ielen)=
;
+int rtw_get_wfd_attr_content(u8 *wfd_ie, uint wfd_ielen, u8 target_att=
r_id ,u8 *attr_content, uint *attr_contentlen);
+#endif /*  CONFIG_8723AU_P2P */
+
+uint	rtw_get_rateset_len23a(u8	*rateset);
+
+struct registry_priv;
+int rtw_generate_ie23a(struct registry_priv *pregistrypriv);
+
+
+int rtw_get_bit_value_from_ieee_value23a(u8 val);
+
+uint rtw_is_cckrates_included23a(u8 *rate);
+
+uint rtw_is_cckratesonly_included23a(u8 *rate);
+
+int rtw_check_network_type23a(unsigned char *rate, int ratelen, int ch=
annel);
+
+void rtw_get_bcn_info23a(struct wlan_network *pnetwork);
+
+void rtw_macaddr_cfg23a(u8 *mac_addr);
+
+u16 rtw_mcs_rate23a(u8 rf_type, u8 bw_40MHz, u8 short_GI_20, u8 short_=
GI_40, unsigned char * MCS_rate);
+
+int rtw_action_frame_parse23a(const u8 *frame, u32 frame_len, u8* cate=
gory, u8 *action);
+const char *action_public_str23a(u8 action);
+
+#endif /* IEEE80211_H */
diff --git a/drivers/staging/rtl8723au/include/ioctl_cfg80211.h b/drive=
rs/staging/rtl8723au/include/ioctl_cfg80211.h
new file mode 100644
index 0000000..0eb9036
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/ioctl_cfg80211.h
@@ -0,0 +1,119 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __IOCTL_CFG80211_H__
+#define __IOCTL_CFG80211_H__
+
+struct rtw_wdev_invit_info {
+	u8 token;
+	u8 flags;
+	u8 status;
+	u8 req_op_ch;
+	u8 rsp_op_ch;
+};
+
+#define rtw_wdev_invit_info_init(invit_info) \
+	do { \
+		(invit_info)->token =3D 0; \
+		(invit_info)->flags =3D 0x00; \
+		(invit_info)->status =3D 0xff; \
+		(invit_info)->req_op_ch =3D 0; \
+		(invit_info)->rsp_op_ch =3D 0; \
+	} while (0)
+
+struct rtw_wdev_priv {
+	struct wireless_dev *rtw_wdev;
+
+	struct rtw_adapter *padapter;
+
+	struct cfg80211_scan_request *scan_request;
+	spinlock_t scan_req_lock;
+
+	struct net_device *pmon_ndev;/* for monitor interface */
+	char ifname_mon[IFNAMSIZ + 1]; /* name for monitor interface */
+
+	u8 p2p_enabled;
+
+	u8 provdisc_req_issued;
+
+	struct rtw_wdev_invit_info invit_info;
+
+	bool block;
+	bool power_mgmt;
+};
+
+#define wdev_to_priv(w) ((struct rtw_wdev_priv *)(wdev_priv(w)))
+
+#define wiphy_to_adapter(x)					\
+	(struct rtw_adapter *)(((struct rtw_wdev_priv *)	\
+	wiphy_priv(x))->padapter)
+
+#define wiphy_to_wdev(x)					\
+	(struct wireless_dev *)(((struct rtw_wdev_priv *)	\
+	wiphy_priv(x))->rtw_wdev)
+
+int rtw_wdev_alloc(struct rtw_adapter *padapter, struct device *dev);
+void rtw_wdev_free(struct wireless_dev *wdev);
+void rtw_wdev_unregister(struct wireless_dev *wdev);
+
+void rtw_cfg80211_init_wiphy(struct rtw_adapter *padapter);
+
+void rtw_cfg80211_surveydone_event_callback(struct rtw_adapter *padapt=
er);
+
+void rtw_cfg80211_indicate_connect(struct rtw_adapter *padapter);
+void rtw_cfg80211_indicate_disconnect(struct rtw_adapter *padapter);
+void rtw_cfg80211_indicate_scan_done(struct rtw_wdev_priv *pwdev_priv,
+				     bool aborted);
+
+#ifdef CONFIG_8723AU_AP_MODE
+void rtw_cfg80211_indicate_sta_assoc(struct rtw_adapter *padapter,
+				     u8 *pmgmt_frame, uint frame_len);
+void rtw_cfg80211_indicate_sta_disassoc(struct rtw_adapter *padapter,
+					unsigned char *da, unsigned short reason);
+#endif /* CONFIG_8723AU_AP_MODE */
+
+void rtw_cfg80211_issue_p2p_provision_request23a(struct rtw_adapter *p=
adapter,
+					      const u8 *buf, size_t len);
+void rtw_cfg80211_rx_p2p_action_public(struct rtw_adapter *padapter,
+				       u8 *pmgmt_frame, uint frame_len);
+void rtw_cfg80211_rx_action_p2p(struct rtw_adapter *padapter,
+				u8 *pmgmt_frame, uint frame_len);
+void rtw_cfg80211_rx_action(struct rtw_adapter *adapter, u8 *frame,
+			    uint frame_len, const char*msg);
+
+int rtw_cfg80211_set_mgnt_wpsp2pie(struct net_device *net, char *buf, =
int len,
+				   int type);
+
+bool rtw_cfg80211_pwr_mgmt(struct rtw_adapter *adapter);
+
+#define rtw_cfg80211_rx_mgmt(adapter, freq, sig_dbm, buf, len, gfp)	\
+	cfg80211_rx_mgmt((adapter)->rtw_wdev, freq, sig_dbm, buf, len, 0, gfp=
)
+
+#define rtw_cfg80211_send_rx_assoc(adapter, bss, buf, len)		\
+	cfg80211_send_rx_assoc((adapter)->pnetdev, bss, buf, len)
+
+#define rtw_cfg80211_mgmt_tx_status(adapter, cookie, buf, len, ack, gf=
p) \
+	cfg80211_mgmt_tx_status((adapter)->rtw_wdev, cookie, buf,	\
+				len, ack, gfp)
+
+#define rtw_cfg80211_ready_on_channel(adapter, cookie, chan,		\
+				      channel_type, duration, gfp)	\
+	cfg80211_ready_on_channel((adapter)->rtw_wdev, cookie, chan,	\
+				  duration, gfp)
+#define rtw_cfg80211_remain_on_channel_expired(adapter, cookie, chan,	=
\
+					       chan_type, gfp)		\
+	cfg80211_remain_on_channel_expired((adapter)->rtw_wdev,		\
+					   cookie, chan, gfp)
+
+#endif /* __IOCTL_CFG80211_H__ */
diff --git a/drivers/staging/rtl8723au/include/mlme_osdep.h b/drivers/s=
taging/rtl8723au/include/mlme_osdep.h
new file mode 100644
index 0000000..b7132a9
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/mlme_osdep.h
@@ -0,0 +1,28 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef	__MLME_OSDEP_H_
+#define __MLME_OSDEP_H_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+void rtw_os_indicate_disconnect23a(struct rtw_adapter *adapter);
+void rtw_os_indicate_connect23a(struct rtw_adapter *adapter);
+void rtw_os_indicate_scan_done23a(struct rtw_adapter *padapter, bool a=
borted);
+void rtw_report_sec_ie23a(struct rtw_adapter *adapter, u8 authmode, u8=
 *sec_ie);
+
+void rtw_reset_securitypriv23a(struct rtw_adapter *adapter);
+
+#endif	/* _MLME_OSDEP_H_ */
diff --git a/drivers/staging/rtl8723au/include/mp_custom_oid.h b/driver=
s/staging/rtl8723au/include/mp_custom_oid.h
new file mode 100644
index 0000000..da197cf
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/mp_custom_oid.h
@@ -0,0 +1,342 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef	__CUSTOM_OID_H
+#define __CUSTOM_OID_H
+
+/*  0xFF818000 - 0xFF81802F		RTL8180 Mass Production Kit */
+/*  0xFF818500 - 0xFF81850F		RTL8185 Setup Utility */
+/*  0xFF818580 - 0xFF81858F		RTL8185 Phy Status Utility */
+
+/*  For Production Kit with Agilent Equipments */
+/*  in order to make our custom oids hopefully somewhat unique */
+/*  we will use 0xFF (indicating implementation specific OID) */
+/*                81(first byte of non zero Realtek unique identifier)=
 */
+/*                80 (second byte of non zero Realtek unique identifie=
r) */
+/*                XX (the custom OID number - providing 255 possible c=
ustom oids) */
+
+#define OID_RT_PRO_RESET_DUT		0xFF818000
+#define OID_RT_PRO_SET_DATA_RATE		0xFF818001
+#define OID_RT_PRO_START_TEST		0xFF818002
+#define OID_RT_PRO_STOP_TEST		0xFF818003
+#define OID_RT_PRO_SET_PREAMBLE		0xFF818004
+#define OID_RT_PRO_SET_SCRAMBLER		0xFF818005
+#define OID_RT_PRO_SET_FILTER_BB		0xFF818006
+#define OID_RT_PRO_SET_MANUAL_DIVERSITY_BB		0xFF818007
+#define OID_RT_PRO_SET_CHANNEL_DIRECT_CALL		0xFF818008
+#define OID_RT_PRO_SET_SLEEP_MODE_DIRECT_CALL		0xFF818009
+#define OID_RT_PRO_SET_WAKE_MODE_DIRECT_CALL		0xFF81800A
+
+#define OID_RT_PRO_SET_TX_ANTENNA_BB		0xFF81800D
+#define OID_RT_PRO_SET_ANTENNA_BB		0xFF81800E
+#define OID_RT_PRO_SET_CR_SCRAMBLER		0xFF81800F
+#define OID_RT_PRO_SET_CR_NEW_FILTER		0xFF818010
+#define OID_RT_PRO_SET_TX_POWER_CONTROL		0xFF818011
+#define OID_RT_PRO_SET_CR_TX_CONFIG		0xFF818012
+#define OID_RT_PRO_GET_TX_POWER_CONTROL		0xFF818013
+#define OID_RT_PRO_GET_CR_SIGNAL_QUALITY		0xFF818014
+#define OID_RT_PRO_SET_CR_SETPOINT		0xFF818015
+#define OID_RT_PRO_SET_INTEGRATOR		0xFF818016
+#define OID_RT_PRO_SET_SIGNAL_QUALITY		0xFF818017
+#define OID_RT_PRO_GET_INTEGRATOR		0xFF818018
+#define OID_RT_PRO_GET_SIGNAL_QUALITY		0xFF818019
+#define OID_RT_PRO_QUERY_EEPROM_TYPE		0xFF81801A
+#define OID_RT_PRO_WRITE_MAC_ADDRESS		0xFF81801B
+#define OID_RT_PRO_READ_MAC_ADDRESS		0xFF81801C
+#define OID_RT_PRO_WRITE_CIS_DATA		0xFF81801D
+#define OID_RT_PRO_READ_CIS_DATA		0xFF81801E
+#define OID_RT_PRO_WRITE_POWER_CONTROL		0xFF81801F
+#define OID_RT_PRO_READ_POWER_CONTROL		0xFF818020
+#define OID_RT_PRO_WRITE_EEPROM		0xFF818021
+#define OID_RT_PRO_READ_EEPROM		0xFF818022
+#define OID_RT_PRO_RESET_TX_PACKET_SENT		0xFF818023
+#define OID_RT_PRO_QUERY_TX_PACKET_SENT		0xFF818024
+#define OID_RT_PRO_RESET_RX_PACKET_RECEIVED		0xFF818025
+#define OID_RT_PRO_QUERY_RX_PACKET_RECEIVED		0xFF818026
+#define OID_RT_PRO_QUERY_RX_PACKET_CRC32_ERROR		0xFF818027
+#define OID_RT_PRO_QUERY_CURRENT_ADDRESS		0xFF818028
+#define OID_RT_PRO_QUERY_PERMANENT_ADDRESS		0xFF818029
+#define OID_RT_PRO_SET_PHILIPS_RF_PARAMETERS		0xFF81802A
+#define OID_RT_PRO_RECEIVE_PACKET		0xFF81802C
+/*  added by Owen on 04/08/03 for Cameo's request */
+#define OID_RT_PRO_WRITE_EEPROM_BYTE		0xFF81802D
+#define OID_RT_PRO_READ_EEPROM_BYTE		0xFF81802E
+#define OID_RT_PRO_SET_MODULATION		0xFF81802F
+/*  */
+
+#define OID_RT_DRIVER_OPTION		0xFF818080
+#define OID_RT_RF_OFF		0xFF818081
+#define OID_RT_AUTH_STATUS		0xFF818082
+
+/*  */
+#define OID_RT_PRO_SET_CONTINUOUS_TX		0xFF81800B
+#define OID_RT_PRO_SET_SINGLE_CARRIER_TX		0xFF81800C
+#define OID_RT_PRO_SET_CARRIER_SUPPRESSION_TX		0xFF81802B
+#define OID_RT_PRO_SET_SINGLE_TONE_TX		0xFF818043
+/*  */
+
+
+/*  by Owen for RTL8185 Phy Status Report Utility */
+#define OID_RT_UTILITYfalse_ALARM_COUNTERS		0xFF818580
+#define OID_RT_UTILITY_SELECT_DEBUG_MODE		0xFF818581
+#define OID_RT_UTILITY_SELECT_SUBCARRIER_NUMBER		0xFF818582
+#define OID_RT_UTILITY_GET_RSSI_STATUS		0xFF818583
+#define OID_RT_UTILITY_GET_FRAME_DETECTION_STATUS		0xFF818584
+#define OID_RT_UTILITY_GET_AGC_AND_FREQUENCY_OFFSET_ESTIMATION_STATUS	=
0xFF818585
+#define OID_RT_UTILITY_GET_CHANNEL_ESTIMATION_STATUS		0xFF818586
+
+/*  by Owen on 03/09/19-03/09/22 for RTL8185 */
+#define OID_RT_WIRELESS_MODE		0xFF818500
+#define OID_RT_SUPPORTED_RATES		0xFF818501
+#define OID_RT_DESIRED_RATES		0xFF818502
+#define OID_RT_WIRELESS_MODE_STARTING_ADHOC		0xFF818503
+/*  */
+
+#define OID_RT_GET_CONNECT_STATE		0xFF030001
+#define OID_RT_RESCAN		0xFF030002
+#define OID_RT_SET_KEY_LENGTH		0xFF030003
+#define OID_RT_SET_DEFAULT_KEY_ID		0xFF030004
+
+#define OID_RT_SET_CHANNEL		0xFF010182
+#define OID_RT_SET_SNIFFER_MODE		0xFF010183
+#define OID_RT_GET_SIGNAL_QUALITY		0xFF010184
+#define OID_RT_GET_SMALL_PACKET_CRC		0xFF010185
+#define OID_RT_GET_MIDDLE_PACKET_CRC		0xFF010186
+#define OID_RT_GET_LARGE_PACKET_CRC		0xFF010187
+#define OID_RT_GET_TX_RETRY		0xFF010188
+#define OID_RT_GET_RX_RETRY		0xFF010189
+#define OID_RT_PRO_SET_FW_DIG_STATE		0xFF01018A/* S */
+#define OID_RT_PRO_SET_FW_RA_STATE		0xFF01018B/* S */
+
+#define OID_RT_GET_RX_TOTAL_PACKET		0xFF010190
+#define OID_RT_GET_TX_BEACON_OK		0xFF010191
+#define OID_RT_GET_TX_BEACON_ERR		0xFF010192
+#define OID_RT_GET_RX_ICV_ERR		0xFF010193
+#define OID_RT_SET_ENCRYPTION_ALGORITHM		0xFF010194
+#define OID_RT_SET_NO_AUTO_RESCAN		0xFF010195
+#define OID_RT_GET_PREAMBLE_MODE		0xFF010196
+#define OID_RT_GET_DRIVER_UP_DELTA_TIME		0xFF010197
+#define OID_RT_GET_AP_IP		0xFF010198
+#define OID_RT_GET_CHANNELPLAN		0xFF010199
+#define OID_RT_SET_PREAMBLE_MODE		0xFF01019A
+#define OID_RT_SET_BCN_INTVL		0xFF01019B
+#define OID_RT_GET_RF_VENDER		0xFF01019C
+#define OID_RT_DEDICATE_PROBE		0xFF01019D
+#define OID_RT_PRO_RX_FILTER_PATTERN		0xFF01019E
+
+#define OID_RT_GET_DCST_CURRENT_THRESHOLD		0xFF01019F
+
+#define OID_RT_GET_CCA_ERR		0xFF0101A0
+#define OID_RT_GET_CCA_UPGRADE_THRESHOLD		0xFF0101A1
+#define OID_RT_GET_CCA_FALLBACK_THRESHOLD		0xFF0101A2
+
+#define OID_RT_GET_CCA_UPGRADE_EVALUATE_TIMES		0xFF0101A3
+#define OID_RT_GET_CCA_FALLBACK_EVALUATE_TIMES		0xFF0101A4
+
+/*  by Owen on 03/31/03 for Cameo's request */
+#define OID_RT_SET_RATE_ADAPTIVE		0xFF0101A5
+/*  */
+#define OID_RT_GET_DCST_EVALUATE_PERIOD		0xFF0101A5
+#define OID_RT_GET_DCST_TIME_UNIT_INDEX		0xFF0101A6
+#define OID_RT_GET_TOTAL_TX_BYTES		0xFF0101A7
+#define OID_RT_GET_TOTAL_RX_BYTES		0xFF0101A8
+#define OID_RT_CURRENT_TX_POWER_LEVEL		0xFF0101A9
+#define OID_RT_GET_ENC_KEY_MISMATCH_COUNT		0xFF0101AA
+#define OID_RT_GET_ENC_KEY_MATCH_COUNT		0xFF0101AB
+#define OID_RT_GET_CHANNEL		0xFF0101AC
+
+#define OID_RT_SET_CHANNELPLAN		0xFF0101AD
+#define OID_RT_GET_HARDWARE_RADIO_OFF		0xFF0101AE
+#define OID_RT_CHANNELPLAN_BY_COUNTRY		0xFF0101AF
+#define OID_RT_SCAN_AVAILABLE_BSSID		0xFF0101B0
+#define OID_RT_GET_HARDWARE_VERSION		0xFF0101B1
+#define OID_RT_GET_IS_ROAMING		0xFF0101B2
+#define OID_RT_GET_IS_PRIVACY		0xFF0101B3
+#define OID_RT_GET_KEY_MISMATCH		0xFF0101B4
+#define OID_RT_SET_RSSI_ROAM_TRAFFIC_TH		0xFF0101B5
+#define OID_RT_SET_RSSI_ROAM_SIGNAL_TH		0xFF0101B6
+#define OID_RT_RESET_LOG		0xFF0101B7
+#define OID_RT_GET_LOG		0xFF0101B8
+#define OID_RT_SET_INDICATE_HIDDEN_AP		0xFF0101B9
+#define OID_RT_GET_HEADER_FAIL		0xFF0101BA
+#define OID_RT_SUPPORTED_WIRELESS_MODE		0xFF0101BB
+#define OID_RT_GET_CHANNEL_LIST		0xFF0101BC
+#define OID_RT_GET_SCAN_IN_PROGRESS		0xFF0101BD
+#define OID_RT_GET_TX_INFO		0xFF0101BE
+#define OID_RT_RF_READ_WRITE_OFFSET		0xFF0101BF
+#define OID_RT_RF_READ_WRITE		0xFF0101C0
+
+/*  For Netgear request. 2005.01.13, by rcnjko. */
+#define OID_RT_FORCED_DATA_RATE		0xFF0101C1
+#define OID_RT_WIRELESS_MODE_FOR_SCAN_LIST	0xFF0101C2
+/*  For Netgear request. 2005.02.17, by rcnjko. */
+#define OID_RT_GET_BSS_WIRELESS_MODE		0xFF0101C3
+/*  For AZ project. 2005.06.27, by rcnjko. */
+#define OID_RT_SCAN_WITH_MAGIC_PACKET		0xFF0101C4
+
+/*  Vincent 8185MP */
+#define OID_RT_PRO_RX_FILTER		0xFF0111C0
+
+/* Andy TEST */
+/* define OID_RT_PRO_WRITE_REGISTRY		0xFF0111C1 */
+/* define OID_RT_PRO_READ_REGISTRY		0xFF0111C2 */
+#define OID_CE_USB_WRITE_REGISTRY		0xFF0111C1
+#define OID_CE_USB_READ_REGISTRY		0xFF0111C2
+
+
+#define OID_RT_PRO_SET_INITIAL_GAIN		0xFF0111C3
+#define OID_RT_PRO_SET_BB_RF_STANDBY_MODE		0xFF0111C4
+#define OID_RT_PRO_SET_BB_RF_SHUTDOWN_MODE		0xFF0111C5
+#define OID_RT_PRO_SET_TX_CHARGE_PUMP		0xFF0111C6
+#define OID_RT_PRO_SET_RX_CHARGE_PUMP		0xFF0111C7
+#define OID_RT_PRO_RF_WRITE_REGISTRY		0xFF0111C8
+#define OID_RT_PRO_RF_READ_REGISTRY		0xFF0111C9
+#define OID_RT_PRO_QUERY_RF_TYPE		0xFF0111CA
+
+/*  AP OID */
+#define OID_RT_AP_GET_ASSOCIATED_STATION_LIST		0xFF010300
+#define OID_RT_AP_GET_CURRENT_TIME_STAMP		0xFF010301
+#define OID_RT_AP_SWITCH_INTO_AP_MODE		0xFF010302
+#define OID_RT_AP_SET_DTIM_PERIOD		0xFF010303
+#define OID_RT_AP_SUPPORTED		0xFF010304	/*  Determine if driver suppor=
ts AP mode. 2004.08.27, by rcnjko. */
+#define OID_RT_AP_SET_PASSPHRASE		0xFF010305	/*  Set WPA-PSK passphras=
e into authenticator. 2005.07.08, byrcnjko. */
+
+/*  8187MP. 2004.09.06, by rcnjko. */
+#define OID_RT_PRO8187_WI_POLL		0xFF818780
+#define OID_RT_PRO_WRITE_BB_REG		0xFF818781
+#define OID_RT_PRO_READ_BB_REG		0xFF818782
+#define OID_RT_PRO_WRITE_RF_REG		0xFF818783
+#define OID_RT_PRO_READ_RF_REG		0xFF818784
+
+/*  Meeting House. added by Annie, 2005-07-20. */
+#define OID_RT_MH_VENDER_ID		0xFFEDC100
+
+/* 8711 MP OID added 20051230. */
+#define OID_RT_PRO8711_JOIN_BSS		0xFF871100/* S */
+
+#define OID_RT_PRO_READ_REGISTER		0xFF871101 /* Q */
+#define OID_RT_PRO_WRITE_REGISTER		0xFF871102 /* S */
+
+#define OID_RT_PRO_BURST_READ_REGISTER		0xFF871103 /* Q */
+#define OID_RT_PRO_BURST_WRITE_REGISTER		0xFF871104 /* S */
+
+#define OID_RT_PRO_WRITE_TXCMD		0xFF871105 /* S */
+
+#define OID_RT_PRO_READ16_EEPROM		0xFF871106 /* Q */
+#define OID_RT_PRO_WRITE16_EEPROM		0xFF871107 /* S */
+
+#define OID_RT_PRO_H2C_SET_COMMAND		0xFF871108 /* S */
+#define OID_RT_PRO_H2C_QUERY_RESULT		0xFF871109 /* Q */
+
+#define OID_RT_PRO8711_WI_POLL		0xFF87110A /* Q */
+#define OID_RT_PRO8711_PKT_LOSS		0xFF87110B /* Q */
+#define OID_RT_RD_ATTRIB_MEM		0xFF87110C/* Q */
+#define OID_RT_WR_ATTRIB_MEM		0xFF87110D/* S */
+
+
+/* Method 2 for H2C/C2H */
+#define OID_RT_PRO_H2C_CMD_MODE		0xFF871110 /* S */
+#define OID_RT_PRO_H2C_CMD_RSP_MODE		0xFF871111 /* Q */
+#define OID_RT_PRO_H2C_CMD_EVENT_MODE		0xFF871112 /* S */
+#define OID_RT_PRO_WAIT_C2H_EVENT		0xFF871113 /* Q */
+#define OID_RT_PRO_RW_ACCESS_PROTOCOL_TEST		0xFF871114/* Q */
+
+#define OID_RT_PRO_SCSI_ACCESS_TEST		0xFF871115 /* Q, S */
+
+#define OID_RT_PRO_SCSI_TCPIPOFFLOAD_OUT		0xFF871116 /* S */
+#define OID_RT_PRO_SCSI_TCPIPOFFLOAD_IN		0xFF871117 /* Q,S */
+#define OID_RT_RRO_RX_PKT_VIA_IOCTRL		0xFF871118 /* Q */
+#define OID_RT_RRO_RX_PKTARRAY_VIA_IOCTRL		0xFF871119 /* Q */
+
+#define OID_RT_RPO_SET_PWRMGT_TEST		0xFF87111A /* S */
+#define OID_RT_PRO_QRY_PWRMGT_TEST		0XFF87111B /* Q */
+#define OID_RT_RPO_ASYNC_RWIO_TEST		0xFF87111C /* S */
+#define OID_RT_RPO_ASYNC_RWIO_POLL		0xFF87111D /* Q */
+#define OID_RT_PRO_SET_RF_INTFS		0xFF87111E /* S */
+#define OID_RT_POLL_RX_STATUS		0xFF87111F /* Q */
+
+#define OID_RT_PRO_CFG_DEBUG_MESSAGE		0xFF871120 /* Q,S */
+#define OID_RT_PRO_SET_DATA_RATE_EX		0xFF871121/* S */
+#define OID_RT_PRO_SET_BASIC_RATE		0xFF871122/* S */
+#define OID_RT_PRO_READ_TSSI		0xFF871123/* S */
+#define OID_RT_PRO_SET_POWER_TRACKING		0xFF871124/* S */
+
+
+#define OID_RT_PRO_QRY_PWRSTATE		0xFF871150 /* Q */
+#define OID_RT_PRO_SET_PWRSTATE		0xFF871151 /* S */
+
+/* Method 2 , using workitem */
+#define OID_RT_SET_READ_REG		0xFF871181 /* S */
+#define OID_RT_SET_WRITE_REG		0xFF871182 /* S */
+#define OID_RT_SET_BURST_READ_REG		0xFF871183 /* S */
+#define OID_RT_SET_BURST_WRITE_REG		0xFF871184 /* S */
+#define OID_RT_SET_WRITE_TXCMD		0xFF871185 /* S */
+#define OID_RT_SET_READ16_EEPROM		0xFF871186 /* S */
+#define OID_RT_SET_WRITE16_EEPROM		0xFF871187 /* S */
+#define OID_RT_QRY_POLL_WKITEM		0xFF871188 /* Q */
+
+/* For SDIO INTERFACE only */
+#define OID_RT_PRO_SYNCPAGERW_SRAM		0xFF8711A0 /* Q, S */
+#define OID_RT_PRO_871X_DRV_EXT		0xFF8711A1
+
+/* For USB INTERFACE only */
+#define OID_RT_PRO_USB_VENDOR_REQ		0xFF8711B0 /* Q, S */
+#define OID_RT_PRO_SCSI_AUTO_TEST		0xFF8711B1 /* S */
+#define OID_RT_PRO_USB_MAC_AC_FIFO_WRITE		0xFF8711B2 /* S */
+#define OID_RT_PRO_USB_MAC_RX_FIFO_READ		0xFF8711B3 /* Q */
+#define OID_RT_PRO_USB_MAC_RX_FIFO_POLLING		0xFF8711B4 /* Q */
+
+#define OID_RT_PRO_H2C_SET_RATE_TABLE		0xFF8711FB /* S */
+#define OID_RT_PRO_H2C_GET_RATE_TABLE		0xFF8711FC /* S */
+#define OID_RT_PRO_H2C_C2H_LBK_TEST		0xFF8711FE
+
+#define OID_RT_PRO_ENCRYPTION_CTRL		0xFF871200 /* Q, S */
+#define OID_RT_PRO_ADD_STA_INFO		0xFF871201 /* S */
+#define OID_RT_PRO_DELE_STA_INFO		0xFF871202 /* S */
+#define OID_RT_PRO_QUERY_DR_VARIABLE		0xFF871203 /* Q */
+
+#define OID_RT_PRO_RX_PACKET_TYPE		0xFF871204 /* Q, S */
+
+#define OID_RT_PRO_READ_EFUSE		0xFF871205 /* Q */
+#define OID_RT_PRO_WRITE_EFUSE		0xFF871206 /* S */
+#define OID_RT_PRO_RW_EFUSE_PGPKT		0xFF871207 /* Q, S */
+#define OID_RT_GET_EFUSE_CURRENT_SIZE		0xFF871208 /* Q */
+
+#define OID_RT_SET_BANDWIDTH		0xFF871209 /* S */
+#define OID_RT_SET_CRYSTAL_CAP		0xFF87120A /* S */
+
+#define OID_RT_SET_RX_PACKET_TYPE		0xFF87120B /* S */
+
+#define OID_RT_GET_EFUSE_MAX_SIZE		0xFF87120C /* Q */
+
+#define OID_RT_PRO_SET_TX_AGC_OFFSET		0xFF87120D /* S */
+
+#define OID_RT_PRO_SET_PKT_TEST_MODE		0xFF87120E /* S */
+
+#define OID_RT_PRO_FOR_EVM_TEST_SETTING		0xFF87120F /* S */
+
+#define OID_RT_PRO_GET_THERMAL_METER		0xFF871210 /* Q */
+
+#define OID_RT_RESET_PHY_RX_PACKET_COUNT	0xFF871211 /* S */
+#define OID_RT_GET_PHY_RX_PACKET_RECEIVED	0xFF871212 /* Q */
+#define OID_RT_GET_PHY_RX_PACKET_CRC32_ERROR	0xFF871213 /* Q */
+
+#define OID_RT_SET_POWER_DOWN		0xFF871214 /* S */
+
+#define OID_RT_GET_POWER_MODE		0xFF871215 /* Q */
+
+#define OID_RT_PRO_EFUSE		0xFF871216 /* Q, S */
+#define OID_RT_PRO_EFUSE_MAP		0xFF871217 /* Q, S */
+
+#endif /* ifndef	__CUSTOM_OID_H */
diff --git a/drivers/staging/rtl8723au/include/odm.h b/drivers/staging/=
rtl8723au/include/odm.h
new file mode 100644
index 0000000..ac42732
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/odm.h
@@ -0,0 +1,1210 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+
+
+#ifndef	__HALDMOUTSRC_H__
+#define __HALDMOUTSRC_H__
+
+/*  */
+/*  Definition */
+/*  */
+/*  */
+/*  2011/09/22 MH Define all team supprt ability. */
+/*  */
+
+/*  */
+/*  2011/09/22 MH Define for all teams. Please Define the constan in y=
our precomp header. */
+/*  */
+/* define		DM_ODM_SUPPORT_AP			0 */
+/* define		DM_ODM_SUPPORT_ADSL			0 */
+/* define		DM_ODM_SUPPORT_CE			0 */
+/* define		DM_ODM_SUPPORT_MP			1 */
+
+#define	TP_MODE		0
+#define	RSSI_MODE		1
+#define	TRAFFIC_LOW	0
+#define	TRAFFIC_HIGH	1
+
+
+/*  */
+/* 3 Tx Power Tracking */
+/* 3=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+#define		DPK_DELTA_MAPPING_NUM	13
+#define		index_mapping_HP_NUM	15
+
+
+/*  */
+/* 3 PSD Handler */
+/* 3=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+
+#define	AFH_PSD		1	/* 0:normal PSD scan, 1: only do 20 pts PSD */
+#define	MODE_40M		0	/* 0:20M, 1:40M */
+#define	PSD_TH2		3
+#define	PSD_CHMIN		20   /*  Minimum channel number for BT AFH */
+#define	SIR_STEP_SIZE	3
+#define   Smooth_Size_1		5
+#define	Smooth_TH_1	3
+#define   Smooth_Size_2		10
+#define	Smooth_TH_2	4
+#define   Smooth_Size_3		20
+#define	Smooth_TH_3	4
+#define   Smooth_Step_Size 5
+#define	Adaptive_SIR	1
+#define	PSD_RESCAN		4
+#define	PSD_SCAN_INTERVAL	700 /* ms */
+
+/* 8723A High Power IGI Setting */
+#define DM_DIG_HIGH_PWR_IGI_LOWER_BOUND	0x22
+#define DM_DIG_Gmode_HIGH_PWR_IGI_LOWER_BOUND 0x28
+#define DM_DIG_HIGH_PWR_THRESHOLD	0x3a
+
+/*  LPS define */
+#define DM_DIG_FA_TH0_LPS				4 /*  4 in lps */
+#define DM_DIG_FA_TH1_LPS				15 /*  15 lps */
+#define DM_DIG_FA_TH2_LPS				30 /*  30 lps */
+#define RSSI_OFFSET_DIG					0x05;
+
+/* ANT Test */
+#define			ANTTESTALL		0x00		/* Ant A or B will be Testing */
+#define		ANTTESTA		0x01		/* Ant A will be Testing */
+#define		ANTTESTB		0x02		/* Ant B will be testing */
+
+
+/*  */
+/*  structure and define */
+/*  */
+
+/*  */
+/*  2011/09/20 MH Add for AP/ADSLpseudo DM structuer requirement. */
+/*  We need to remove to other position??? */
+/*  */
+struct rtl8723a_priv {
+	u8		temp;
+};
+
+
+struct  dig_t {
+	u8		Dig_Enable_Flag;
+	u8		Dig_Ext_Port_Stage;
+
+	int		RssiLowThresh;
+	int		RssiHighThresh;
+
+	u32		FALowThresh;
+	u32		FAHighThresh;
+
+	u8		CurSTAConnectState;
+	u8		PreSTAConnectState;
+	u8		CurMultiSTAConnectState;
+
+	u8		PreIGValue;
+	u8		CurIGValue;
+	u8		BackupIGValue;
+
+	s8		BackoffVal;
+	s8		BackoffVal_range_max;
+	s8		BackoffVal_range_min;
+	u8		rx_gain_range_max;
+	u8		rx_gain_range_min;
+	u8		Rssi_val_min;
+
+	u8		PreCCK_CCAThres;
+	u8		CurCCK_CCAThres;
+	u8		PreCCKPDState;
+	u8		CurCCKPDState;
+
+	u8		LargeFAHit;
+	u8		ForbiddenIGI;
+	u32		Recover_cnt;
+
+	u8		DIG_Dynamic_MIN_0;
+	u8		DIG_Dynamic_MIN_1;
+	bool		bMediaConnect_0;
+	bool		bMediaConnect_1;
+
+	u32		AntDiv_RSSI_max;
+	u32		RSSI_max;
+};
+
+struct dynamic_pwr_sav {
+	u8		PreCCAState;
+	u8		CurCCAState;
+
+	u8		PreRFState;
+	u8		CurRFState;
+
+	int		    Rssi_val_min;
+
+	u8		initialize;
+	u32		Reg874,RegC70,Reg85C,RegA74;
+};
+
+struct false_alarm_stats {
+	u32	Cnt_Parity_Fail;
+	u32	Cnt_Rate_Illegal;
+	u32	Cnt_Crc8_fail;
+	u32	Cnt_Mcs_fail;
+	u32	Cnt_Ofdm_fail;
+	u32	Cnt_Cck_fail;
+	u32	Cnt_all;
+	u32	Cnt_Fast_Fsync;
+	u32	Cnt_SB_Search_fail;
+	u32	Cnt_OFDM_CCA;
+	u32	Cnt_CCK_CCA;
+	u32	Cnt_CCA_all;
+	u32	Cnt_BW_USC;	/* Gary */
+	u32	Cnt_BW_LSC;	/* Gary */
+};
+
+struct pri_cca {
+	u8		PriCCA_flag;
+	u8		intf_flag;
+	u8		intf_type;
+	u8		DupRTS_flag;
+	u8		Monitor_flag;
+};
+
+struct rx_hp {
+	u8		RXHP_flag;
+	u8		PSD_func_trigger;
+	u8		PSD_bitmap_RXHP[80];
+	u8		Pre_IGI;
+	u8		Cur_IGI;
+	u8		Pre_pw_th;
+	u8		Cur_pw_th;
+	bool		First_time_enter;
+	bool		RXHP_enable;
+	u8		TP_Mode;
+	struct timer_list PSDTimer;
+};
+
+#define ASSOCIATE_ENTRY_NUM					32 /*  Max size of AsocEntry[]. */
+#define	ODM_ASSOCIATE_ENTRY_NUM				ASSOCIATE_ENTRY_NUM
+
+/*  This indicates two different the steps. */
+/*  In SWAW_STEP_PEAK, driver needs to switch antenna and listen to th=
e signal on the air. */
+/*  In SWAW_STEP_DETERMINE, driver just compares the signal captured i=
n SWAW_STEP_PEAK */
+/*  with original RSSI to determine if it is necessary to switch anten=
na. */
+#define SWAW_STEP_PEAK		0
+#define SWAW_STEP_DETERMINE	1
+
+#define	TP_MODE		0
+#define	RSSI_MODE		1
+#define	TRAFFIC_LOW	0
+#define	TRAFFIC_HIGH	1
+
+struct sw_ant_sw {
+	u8		try_flag;
+	s32		PreRSSI;
+	u8		CurAntenna;
+	u8		PreAntenna;
+	u8		RSSI_Trying;
+	u8		TestMode;
+	u8		bTriggerAntennaSwitch;
+	u8		SelectAntennaMap;
+	u8		RSSI_target;
+
+	/*  Before link Antenna Switch check */
+	u8		SWAS_NoLink_State;
+	u32		SWAS_NoLink_BK_Reg860;
+	bool		ANTA_ON;	/* To indicate Ant A is or not */
+	bool		ANTB_ON;	/* To indicate Ant B is on or not */
+
+	s32		RSSI_sum_A;
+	s32		RSSI_sum_B;
+	s32		RSSI_cnt_A;
+	s32		RSSI_cnt_B;
+
+	u64		lastTxOkCnt;
+	u64		lastRxOkCnt;
+	u64		TXByteCnt_A;
+	u64		TXByteCnt_B;
+	u64		RXByteCnt_A;
+	u64		RXByteCnt_B;
+	u8		TrafficLoad;
+	struct timer_list SwAntennaSwitchTimer;
+};
+
+struct edca_turbo {
+	bool bCurrentTurboEDCA;
+	bool bIsCurRDLState;
+	u32	prv_traffic_idx; /*  edca turbo */
+
+};
+
+struct odm_rate_adapt {
+	u8	Type;		/*  DM_Type_ByFW/DM_Type_ByDriver */
+	u8	HighRSSIThresh;	/*  if RSSI > HighRSSIThresh	=3D> RATRState is DM_=
RATR_STA_HIGH */
+	u8	LowRSSIThresh;	/*  if RSSI <=3D LowRSSIThresh	=3D> RATRState is DM=
_RATR_STA_LOW */
+	u8	RATRState;	/*  Current RSSI level, DM_RATR_STA_HIGH/DM_RATR_STA_MI=
DDLE/DM_RATR_STA_LOW */
+	u32	LastRATR;	/*  RATR Register Content */
+};
+
+#define IQK_MAC_REG_NUM		4
+#define IQK_ADDA_REG_NUM		16
+#define IQK_BB_REG_NUM_MAX	10
+#define IQK_BB_REG_NUM		9
+#define HP_THERMAL_NUM		8
+
+#define AVG_THERMAL_NUM		8
+#define IQK_Matrix_REG_NUM	8
+#define IQK_Matrix_Settings_NUM	1+24+21
+
+#define		DM_Type_ByFW			0
+#define		DM_Type_ByDriver		1
+
+/*  */
+/*  Declare for common info */
+/*  */
+/*  Declare for common info */
+/*  */
+#define MAX_PATH_NUM_92CS		2
+
+struct odm_phy_info {
+	u8		RxPWDBAll;
+	u8		SignalQuality;	 /*  in 0-100 index. */
+	u8		RxMIMOSignalQuality[MAX_PATH_NUM_92CS]; /* EVM */
+	u8		RxMIMOSignalStrength[MAX_PATH_NUM_92CS];/*  in 0~100 index */
+	s8		RxPower; /*  in dBm Translate from PWdB */
+	s8		RecvSignalPower;/*  Real power in dBm for this packet, no beautif=
ication and aggregation. Keep this raw info to be used for the other pr=
ocedures. */
+	u8		BTRxRSSIPercentage;
+	u8		SignalStrength; /*  in 0-100 index. */
+	u8		RxPwr[MAX_PATH_NUM_92CS];/* per-path's pwdb */
+	u8		RxSNR[MAX_PATH_NUM_92CS];/* per-path's SNR */
+};
+
+
+struct odm_phy_dbg_info {
+	/* ODM Write,debug info */
+	s8		RxSNRdB[MAX_PATH_NUM_92CS];
+	u64		NumQryPhyStatus;
+	u64		NumQryPhyStatusCCK;
+	u64		NumQryPhyStatusOFDM;
+	/* Others */
+	s32		RxEVM[MAX_PATH_NUM_92CS];
+
+};
+
+struct odm_packet_info {
+	u8		Rate;
+	u8		StationID;
+	bool		bPacketMatchBSSID;
+	bool		bPacketToSelf;
+	bool		bPacketBeacon;
+};
+
+struct odm_mac_info {
+	u8	test;
+
+};
+
+
+enum {
+	/*  BB Team */
+	ODM_DIG			=3D 0x00000001,
+	ODM_HIGH_POWER		=3D 0x00000002,
+	ODM_CCK_CCA_TH		=3D 0x00000004,
+	ODM_FA_STATISTICS	=3D 0x00000008,
+	ODM_RAMASK		=3D 0x00000010,
+	ODM_RSSI_MONITOR	=3D 0x00000020,
+	ODM_SW_ANTDIV		=3D 0x00000040,
+	ODM_HW_ANTDIV		=3D 0x00000080,
+	ODM_BB_PWRSV		=3D 0x00000100,
+	ODM_2TPATHDIV		=3D 0x00000200,
+	ODM_1TPATHDIV		=3D 0x00000400,
+	ODM_PSD2AFH		=3D 0x00000800
+};
+
+/*  */
+/*  2011/20/20 MH For MP driver RT_WLAN_STA =3D  struct sta_info */
+/*  Please declare below ODM relative info in your STA info structure.=
 */
+/*  */
+struct odm_sta_info {
+	/*  Driver Write */
+	bool		bUsed;				/*  record the sta status link or not? */
+	u8		IOTPeer;			/*  Enum value.	HT_IOT_PEER_E */
+
+	/*  ODM Write */
+	/* 1 PHY_STATUS_INFO */
+	u8		RSSI_Path[4];		/*  */
+	u8		RSSI_Ave;
+	u8		RXEVM[4];
+	u8		RXSNR[4];
+
+	/*  ODM Write */
+	/* 1 TX_INFO (may changed by IC) */
+
+	/*  */
+	/*	Please use compile flag to disable the structure for other IC exce=
pt 88E. */
+	/*	Move To lower layer. */
+	/*  */
+	/*  ODM Write Wilson will handle this part(said by Luke.Lee) */
+};
+
+/*  */
+/*  2011/10/20 MH Define Common info enum for all team. */
+/*  */
+
+enum odm_cmninfo {
+	/*  Fixed value: */
+	/*  */
+
+	ODM_CMNINFO_PLATFORM =3D 0,
+	ODM_CMNINFO_ABILITY,					/*  enum odm_ability */
+	ODM_CMNINFO_INTERFACE,				/*  enum odm_interface_def */
+	ODM_CMNINFO_MP_TEST_CHIP,
+	ODM_CMNINFO_IC_TYPE,					/*  enum odm_ic_type_def */
+	ODM_CMNINFO_CUT_VER,					/*  enum odm_cut_version */
+	ODM_CMNINFO_FAB_VER,					/*  enum odm_fab_version */
+	ODM_CMNINFO_RF_TYPE,					/*  enum rf_path_def or enum odm_rf_type? */
+	ODM_CMNINFO_BOARD_TYPE,				/*  enum odm_board_type */
+	ODM_CMNINFO_EXT_LNA,					/*  true */
+	ODM_CMNINFO_EXT_PA,
+	ODM_CMNINFO_EXT_TRSW,
+	ODM_CMNINFO_PATCH_ID,				/* CUSTOMER ID */
+	ODM_CMNINFO_BINHCT_TEST,
+	ODM_CMNINFO_BWIFI_TEST,
+	ODM_CMNINFO_SMART_CONCURRENT,
+
+
+	/*  */
+	/*  Dynamic value: */
+	/*  */
+	ODM_CMNINFO_MAC_PHY_MODE,			/*  enum odm_mac_phy_mode */
+	ODM_CMNINFO_TX_UNI,
+	ODM_CMNINFO_RX_UNI,
+	ODM_CMNINFO_WM_MODE,				/*  enum odm_wireless_mode */
+	ODM_CMNINFO_BAND,					/*  enum odm_band_type */
+	ODM_CMNINFO_SEC_CHNL_OFFSET,		/*  enum odm_sec_chnl_offset */
+	ODM_CMNINFO_SEC_MODE,				/*  enum odm_security */
+	ODM_CMNINFO_BW,						/*  enum odm_band_width */
+	ODM_CMNINFO_CHNL,
+
+	ODM_CMNINFO_DMSP_GET_VALUE,
+	ODM_CMNINFO_BUDDY_ADAPTOR,
+	ODM_CMNINFO_DMSP_IS_MASTER,
+	ODM_CMNINFO_SCAN,
+	ODM_CMNINFO_POWER_SAVING,
+	ODM_CMNINFO_ONE_PATH_CCA,			/*  enum odm_cca_path */
+	ODM_CMNINFO_DRV_STOP,
+	ODM_CMNINFO_PNP_IN,
+	ODM_CMNINFO_INIT_ON,
+	ODM_CMNINFO_ANT_TEST,
+	ODM_CMNINFO_NET_CLOSED,
+	ODM_CMNINFO_MP_MODE,
+
+	ODM_CMNINFO_WIFI_DIRECT,
+	ODM_CMNINFO_WIFI_DISPLAY,
+	ODM_CMNINFO_LINK,
+	ODM_CMNINFO_RSSI_MIN,
+	ODM_CMNINFO_DBG_COMP,				/*  u64 */
+	ODM_CMNINFO_DBG_LEVEL,				/*  u32 */
+	ODM_CMNINFO_RA_THRESHOLD_HIGH,		/*  u8 */
+	ODM_CMNINFO_RA_THRESHOLD_LOW,		/*  u8 */
+	ODM_CMNINFO_RF_ANTENNA_TYPE,		/*  u8 */
+	ODM_CMNINFO_BT_DISABLED,
+	ODM_CMNINFO_BT_OPERATION,
+	ODM_CMNINFO_BT_DIG,
+	ODM_CMNINFO_BT_BUSY,					/* Check Bt is using or not */
+	ODM_CMNINFO_BT_DISABLE_EDCA,
+
+	/*  */
+	/*  Dynamic ptr array hook itms. */
+	/*  */
+	ODM_CMNINFO_STA_STATUS,
+	ODM_CMNINFO_PHY_STATUS,
+	ODM_CMNINFO_MAC_STATUS,
+
+	ODM_CMNINFO_MAX,
+};
+
+/*  Define ODM support ability.  ODM_CMNINFO_ABILITY */
+enum {
+	/*  BB ODM section BIT 0-15 */
+	ODM_BB_DIG				=3D BIT0,
+	ODM_BB_RA_MASK				=3D BIT1,
+	ODM_BB_DYNAMIC_TXPWR			=3D BIT2,
+	ODM_BB_FA_CNT				=3D BIT3,
+	ODM_BB_RSSI_MONITOR			=3D BIT4,
+	ODM_BB_CCK_PD				=3D BIT5,
+	ODM_BB_ANT_DIV				=3D BIT6,
+	ODM_BB_PWR_SAVE				=3D BIT7,
+	ODM_BB_PWR_TRAIN			=3D BIT8,
+	ODM_BB_RATE_ADAPTIVE			=3D BIT9,
+	ODM_BB_PATH_DIV				=3D BIT10,
+	ODM_BB_PSD				=3D BIT11,
+	ODM_BB_RXHP				=3D BIT12,
+
+	/*  MAC DM section BIT 16-23 */
+	ODM_MAC_EDCA_TURBO			=3D BIT16,
+	ODM_MAC_EARLY_MODE			=3D BIT17,
+
+	/*  RF ODM section BIT 24-31 */
+	ODM_RF_TX_PWR_TRACK			=3D BIT24,
+	ODM_RF_RX_GAIN_TRACK			=3D BIT25,
+	ODM_RF_CALIBRATION			=3D BIT26,
+
+};
+
+/*	ODM_CMNINFO_INTERFACE */
+enum odm_interface_def {
+	ODM_ITRF_PCIE	=3D	0x1,
+	ODM_ITRF_USB	=3D	0x2,
+	ODM_ITRF_SDIO	=3D	0x4,
+	ODM_ITRF_ALL	=3D	0x7,
+};
+
+/*  ODM_CMNINFO_IC_TYPE */
+enum odm_ic_type_def {
+	ODM_RTL8192S	=3D	BIT0,
+	ODM_RTL8192C	=3D	BIT1,
+	ODM_RTL8192D	=3D	BIT2,
+	ODM_RTL8723A	=3D	BIT3,
+	ODM_RTL8188E	=3D	BIT4,
+	ODM_RTL8812	=3D	BIT5,
+	ODM_RTL8821	=3D	BIT6,
+};
+
+#define ODM_IC_11N_SERIES			\
+	(ODM_RTL8192S|ODM_RTL8192C|ODM_RTL8192D|ODM_RTL8723A|ODM_RTL8188E)
+#define ODM_IC_11AC_SERIES		(ODM_RTL8812)
+
+/* ODM_CMNINFO_CUT_VER */
+enum odm_cut_version {
+	ODM_CUT_A		=3D	1,
+	ODM_CUT_B		=3D	2,
+	ODM_CUT_C		=3D	3,
+	ODM_CUT_D		=3D	4,
+	ODM_CUT_E		=3D	5,
+	ODM_CUT_F		=3D	6,
+	ODM_CUT_TEST		=3D	7,
+};
+
+/*  ODM_CMNINFO_FAB_VER */
+enum odm_fab_version {
+	ODM_TSMC	=3D	0,
+	ODM_UMC		=3D	1,
+};
+
+/*  ODM_CMNINFO_RF_TYPE */
+/*  For example 1T2R (A+AB =3D BIT0|BIT4|BIT5) */
+enum rf_path_def {
+	ODM_RF_TX_A	=3D	BIT0,
+	ODM_RF_TX_B	=3D	BIT1,
+	ODM_RF_TX_C	=3D	BIT2,
+	ODM_RF_TX_D	=3D	BIT3,
+	ODM_RF_RX_A	=3D	BIT4,
+	ODM_RF_RX_B	=3D	BIT5,
+	ODM_RF_RX_C	=3D	BIT6,
+	ODM_RF_RX_D	=3D	BIT7,
+};
+
+
+enum odm_rf_type {
+	ODM_1T1R	=3D	0,
+	ODM_1T2R	=3D	1,
+	ODM_2T2R	=3D	2,
+	ODM_2T3R	=3D	3,
+	ODM_2T4R	=3D	4,
+	ODM_3T3R	=3D	5,
+	ODM_3T4R	=3D	6,
+	ODM_4T4R	=3D	7,
+};
+
+/*  ODM Dynamic common info value definition */
+
+enum odm_mac_phy_mode {
+	ODM_SMSP	=3D 0,
+	ODM_DMSP	=3D 1,
+	ODM_DMDP	=3D 2,
+};
+
+
+enum odm_bt_coexist {
+	ODM_BT_BUSY		=3D 1,
+	ODM_BT_ON		=3D 2,
+	ODM_BT_OFF		=3D 3,
+	ODM_BT_NONE		=3D 4,
+};
+
+/*  ODM_CMNINFO_OP_MODE */
+enum odm_operation_mode {
+	ODM_NO_LINK		=3D BIT0,
+	ODM_LINK		=3D BIT1,
+	ODM_SCAN		=3D BIT2,
+	ODM_POWERSAVE		=3D BIT3,
+	ODM_AP_MODE		=3D BIT4,
+	ODM_CLIENT_MODE		=3D BIT5,
+	ODM_AD_HOC		=3D BIT6,
+	ODM_WIFI_DIRECT		=3D BIT7,
+	ODM_WIFI_DISPLAY	=3D BIT8,
+};
+
+/*  ODM_CMNINFO_WM_MODE */
+enum odm_wireless_mode {
+	ODM_WM_UNKNOW		=3D 0x0,
+	ODM_WM_B		=3D BIT0,
+	ODM_WM_G		=3D BIT1,
+	ODM_WM_A		=3D BIT2,
+	ODM_WM_N24G		=3D BIT3,
+	ODM_WM_N5G		=3D BIT4,
+	ODM_WM_AUTO		=3D BIT5,
+	ODM_WM_AC		=3D BIT6,
+};
+
+/*  ODM_CMNINFO_BAND */
+enum odm_band_type {
+	ODM_BAND_2_4G		=3D BIT0,
+	ODM_BAND_5G		=3D BIT1,
+
+};
+
+/*  ODM_CMNINFO_SEC_CHNL_OFFSET */
+enum odm_sec_chnl_offset {
+	ODM_DONT_CARE		=3D 0,
+	ODM_BELOW		=3D 1,
+	ODM_ABOVE		=3D 2
+};
+
+/*  ODM_CMNINFO_SEC_MODE */
+enum odm_security {
+	ODM_SEC_OPEN		=3D 0,
+	ODM_SEC_WEP40		=3D 1,
+	ODM_SEC_TKIP		=3D 2,
+	ODM_SEC_RESERVE		=3D 3,
+	ODM_SEC_AESCCMP		=3D 4,
+	ODM_SEC_WEP104		=3D 5,
+	ODM_WEP_WPA_MIXED	=3D 6, /*  WEP + WPA */
+	ODM_SEC_SMS4		=3D 7,
+};
+
+/*  ODM_CMNINFO_BW */
+enum odm_band_width {
+	ODM_BW20M		=3D 0,
+	ODM_BW40M		=3D 1,
+	ODM_BW80M		=3D 2,
+	ODM_BW160M		=3D 3,
+	ODM_BW10M		=3D 4,
+};
+
+/*  ODM_CMNINFO_CHNL */
+
+/*  ODM_CMNINFO_BOARD_TYPE */
+enum odm_board_type {
+	ODM_BOARD_NORMAL	=3D 0,
+	ODM_BOARD_HIGHPWR	=3D 1,
+	ODM_BOARD_MINICARD	=3D 2,
+	ODM_BOARD_SLIM		=3D 3,
+	ODM_BOARD_COMBO		=3D 4,
+
+};
+
+/*  ODM_CMNINFO_ONE_PATH_CCA */
+enum odm_cca_path {
+	ODM_CCA_2R			=3D 0,
+	ODM_CCA_1R_A			=3D 1,
+	ODM_CCA_1R_B			=3D 2,
+};
+
+struct odm_ra_info {
+	u8 RateID;
+	u32 RateMask;
+	u32 RAUseRate;
+	u8 RateSGI;
+	u8 RssiStaRA;
+	u8 PreRssiStaRA;
+	u8 SGIEnable;
+	u8 DecisionRate;
+	u8 PreRate;
+	u8 HighestRate;
+	u8 LowestRate;
+	u32 NscUp;
+	u32 NscDown;
+	u16 RTY[5];
+	u32 TOTAL;
+	u16 DROP;
+	u8 Active;
+	u16 RptTime;
+	u8 RAWaitingCounter;
+	u8 RAPendingCounter;
+	u8 PTActive;  /*  on or off */
+	u8 PTTryState;  /*  0 trying state, 1 for decision state */
+	u8 PTStage;  /*  0~6 */
+	u8 PTStopCount; /* Stop PT counter */
+	u8 PTPreRate;  /*  if rate change do PT */
+	u8 PTPreRssi; /*  if RSSI change 5% do PT */
+	u8 PTModeSS;  /*  decide whitch rate should do PT */
+	u8 RAstage;  /*  StageRA, decide how many times RA will be done betwe=
en PT */
+	u8 PTSmoothFactor;
+};
+
+struct iqk_matrix_regs_set {
+	bool	bIQKDone;
+	s32	Value[1][IQK_Matrix_REG_NUM];
+};
+
+struct odm_rf_cal_t {
+	/* for tx power tracking */
+
+	u32	RegA24; /*  for TempCCK */
+	s32	RegE94;
+	s32	RegE9C;
+	s32	RegEB4;
+	s32	RegEBC;
+
+	/* u8 bTXPowerTracking; */
+	u8		TXPowercount;
+	bool bTXPowerTrackingInit;
+	bool bTXPowerTracking;
+	u8		TxPowerTrackControl; /* for mp mode, turn off txpwrtracking as de=
fault */
+	u8		TM_Trigger;
+	u8		InternalPA5G[2];	/* pathA / pathB */
+
+	u8		ThermalMeter[2];    /*  ThermalMeter, index 0 for RFIC0, and 1 fo=
r RFIC1 */
+	u8		ThermalValue;
+	u8		ThermalValue_LCK;
+	u8		ThermalValue_IQK;
+	u8	ThermalValue_DPK;
+	u8	ThermalValue_AVG[AVG_THERMAL_NUM];
+	u8	ThermalValue_AVG_index;
+	u8	ThermalValue_RxGain;
+	u8	ThermalValue_Crystal;
+	u8	ThermalValue_DPKstore;
+	u8	ThermalValue_DPKtrack;
+	bool	TxPowerTrackingInProgress;
+	bool	bDPKenable;
+
+	bool	bReloadtxpowerindex;
+	u8	bRfPiEnable;
+	u32	TXPowerTrackingCallbackCnt; /* cosa add for debug */
+
+	u8	bCCKinCH14;
+	u8	CCK_index;
+	u8	OFDM_index[2];
+	bool bDoneTxpower;
+
+	u8	ThermalValue_HP[HP_THERMAL_NUM];
+	u8	ThermalValue_HP_index;
+	struct iqk_matrix_regs_set IQKMatrixRegSetting[IQK_Matrix_Settings_NU=
M];
+
+	u8	Delta_IQK;
+	u8	Delta_LCK;
+
+	/* for IQK */
+	u32	RegC04;
+	u32	Reg874;
+	u32	RegC08;
+	u32	RegB68;
+	u32	RegB6C;
+	u32	Reg870;
+	u32	Reg860;
+	u32	Reg864;
+
+	bool	bIQKInitialized;
+	bool bLCKInProgress;
+	bool	bAntennaDetected;
+	u32	ADDA_backup[IQK_ADDA_REG_NUM];
+	u32	IQK_MAC_backup[IQK_MAC_REG_NUM];
+	u32	IQK_BB_backup_recover[9];
+	u32	IQK_BB_backup[IQK_BB_REG_NUM];
+
+	/* for APK */
+	u32	APKoutput[2][2]; /* path A/B; output1_1a/output1_2a */
+	u8	bAPKdone;
+	u8	bAPKThermalMeterIgnore;
+	u8	bDPdone;
+	u8	bDPPathAOK;
+	u8	bDPPathBOK;
+};
+
+/*  ODM Dynamic common info value definition */
+struct odm_fat_t {
+	u8	Bssid[6];
+	u8	antsel_rx_keep_0;
+	u8	antsel_rx_keep_1;
+	u8	antsel_rx_keep_2;
+	u32	antSumRSSI[7];
+	u32	antRSSIcnt[7];
+	u32	antAveRSSI[7];
+	u8	FAT_State;
+	u32	TrainIdx;
+	u8	antsel_a[ODM_ASSOCIATE_ENTRY_NUM];
+	u8	antsel_b[ODM_ASSOCIATE_ENTRY_NUM];
+	u8	antsel_c[ODM_ASSOCIATE_ENTRY_NUM];
+	u32	MainAnt_Sum[ODM_ASSOCIATE_ENTRY_NUM];
+	u32	AuxAnt_Sum[ODM_ASSOCIATE_ENTRY_NUM];
+	u32	MainAnt_Cnt[ODM_ASSOCIATE_ENTRY_NUM];
+	u32	AuxAnt_Cnt[ODM_ASSOCIATE_ENTRY_NUM];
+	u8	RxIdleAnt;
+	bool	bBecomeLinked;
+};
+
+enum fat_state {
+	FAT_NORMAL_STATE		=3D 0,
+	FAT_TRAINING_STATE		=3D 1,
+};
+
+enum ant_dif_type {
+	NO_ANTDIV			=3D 0xFF,
+	CG_TRX_HW_ANTDIV		=3D 0x01,
+	CGCS_RX_HW_ANTDIV		=3D 0x02,
+	FIXED_HW_ANTDIV			=3D 0x03,
+	CG_TRX_SMART_ANTDIV		=3D 0x04,
+	CGCS_RX_SW_ANTDIV		=3D 0x05,
+};
+
+/*  2011/09/22 MH Copy from SD4 defined structure. We use to support P=
HY DM integration. */
+struct dm_odm_t {
+	/* struct timer_list FastAntTrainingTimer; */
+	/*  */
+	/*	Add for different team use temporarily */
+	/*  */
+	struct rtw_adapter	*Adapter;		/*  For CE/NIC team */
+	struct rtl8723a_priv	*priv;			/*  For AP/ADSL team */
+	/*  WHen you use Adapter or priv pointer, you must make sure the poin=
ter is ready. */
+	bool			odm_ready;
+
+	struct rtl8723a_priv fake_priv;
+
+	u64			DebugComponents;
+	u32			DebugLevel;
+
+/*  ODM HANDLE, DRIVER NEEDS NOT TO HOOK------ */
+	bool			bCckHighPower;
+	u8			RFPathRxEnable;		/*  ODM_CMNINFO_RFPATH_ENABLE */
+	u8			ControlChannel;
+/*  ODM HANDLE, DRIVER NEEDS NOT TO HOOK------ */
+
+/* 1  COMMON INFORMATION */
+
+	/*  Init Value */
+/* HOOK BEFORE REG INIT----------- */
+	/*  ODM Support Ability DIG/RATR/TX_PWR_TRACK/ =A1K=A1K =3D 1/2/3/=A1=
K */
+	u32			SupportAbility;
+	/*  ODM PCIE/USB/SDIO/GSPI =3D 0/1/2/3 */
+	u8			SupportInterface;
+	/*  ODM composite or independent. Bit oriented/ 92C+92D+ .... or any =
other type =3D 1/2/3/... */
+	u32			SupportICType;
+	/*  Cut Version TestChip/A-cut/B-cut... =3D 0/1/2/3/... */
+	u8			CutVersion;
+	/*  Fab Version TSMC/UMC =3D 0/1 */
+	u8			FabVersion;
+	/*  RF Type 4T4R/3T3R/2T2R/1T2R/1T1R/... */
+	u8			RFType;
+	/*  Board Type Normal/HighPower/MiniCard/SLIM/Combo/... =3D 0/1/2/3/4=
/... */
+	u8			BoardType;
+	/*  with external LNA  NO/Yes =3D 0/1 */
+	u8			ExtLNA;
+	/*  with external PA  NO/Yes =3D 0/1 */
+	u8			ExtPA;
+	/*  with external TRSW  NO/Yes =3D 0/1 */
+	u8			ExtTRSW;
+	u8			PatchID; /* Customer ID */
+	bool			bInHctTest;
+	bool			bWIFITest;
+
+	bool			bDualMacSmartConcurrent;
+	u32			BK_SupportAbility;
+	u8			AntDivType;
+/* HOOK BEFORE REG INIT----------- */
+
+	/*  */
+	/*  Dynamic Value */
+	/*  */
+/*  POINTER REFERENCE----------- */
+
+	u8			u8_temp;
+	bool			bool_temp;
+	struct rtw_adapter	*PADAPTER_temp;
+
+	/*  MAC PHY Mode SMSP/DMSP/DMDP =3D 0/1/2 */
+	u8			*pMacPhyMode;
+	/* TX Unicast byte count */
+	u64			*pNumTxBytesUnicast;
+	/* RX Unicast byte count */
+	u64			*pNumRxBytesUnicast;
+	/*  Wireless mode B/G/A/N =3D BIT0/BIT1/BIT2/BIT3 */
+	u8			*pWirelessMode; /* enum odm_wireless_mode */
+	/*  Frequence band 2.4G/5G =3D 0/1 */
+	u8			*pBandType;
+	/*  Secondary channel offset don't_care/below/above =3D 0/1/2 */
+	u8			*pSecChOffset;
+	/*  Security mode Open/WEP/AES/TKIP =3D 0/1/2/3 */
+	u8			*pSecurity;
+	/*  BW info 20M/40M/80M =3D 0/1/2 */
+	u8			*pBandWidth;
+	/*  Central channel location Ch1/Ch2/.... */
+	u8			*pChannel;	/* central channel number */
+	/*  Common info for 92D DMSP */
+
+	bool			*pbGetValueFromOtherMac;
+	struct rtw_adapter	**pBuddyAdapter;
+	bool			*pbMasterOfDMSP; /* MAC0: master, MAC1: slave */
+	/*  Common info for Status */
+	bool			*pbScanInProcess;
+	bool			*pbPowerSaving;
+	/*  CCA Path 2-path/path-A/path-B =3D 0/1/2; using enum odm_cca_path.=
 */
+	u8			*pOnePathCCA;
+	/* pMgntInfo->AntennaTest */
+	u8			*pAntennaTest;
+	bool			*pbNet_closed;
+/*  POINTER REFERENCE----------- */
+	/*  */
+/* CALL BY VALUE------------- */
+	bool			bWIFI_Direct;
+	bool			bWIFI_Display;
+	bool			bLinked;
+	u8			RSSI_Min;
+	u8			InterfaceIndex; /*  Add for 92D  dual MAC: 0--Mac0 1--Mac1 */
+	bool		bIsMPChip;
+	bool			bOneEntryOnly;
+	/*  Common info for BTDM */
+	bool			bBtDisabled;			/*  BT is disabled */
+	bool			bBtHsOperation;		/*  BT HS mode is under progress */
+	u8			btHsDigVal;			/*  use BT rssi to decide the DIG value */
+	bool			bBtDisableEdcaTurbo;	/*  Under some condition, don't enable th=
e EDCA Turbo */
+	bool			bBtBusy;			/*  BT is busy. */
+/* CALL BY VALUE------------- */
+
+	/* 2 Define STA info. */
+	/*  _ODM_STA_INFO */
+	/*  2012/01/12 MH For MP, we need to reduce one array pointer for def=
ault port.?? */
+	struct sta_info *		pODM_StaInfo[ODM_ASSOCIATE_ENTRY_NUM];
+
+	/*  */
+	/*  2012/02/14 MH Add to share 88E ra with other SW team. */
+	/*  We need to colelct all support abilit to a proper area. */
+	/*  */
+	bool				RaSupport88E;
+
+	/*  Define ........... */
+
+	/*  Latest packet phy info (ODM write) */
+	struct odm_phy_dbg_info	 PhyDbgInfo;
+	/* PHY_INFO_88E		PhyInfo; */
+
+	/*  Latest packet phy info (ODM write) */
+	struct odm_mac_info		*pMacInfo;
+	/* MAC_INFO_88E		MacInfo; */
+
+	/*  Different Team independt structure?? */
+
+	/*  */
+	/* TX_RTP_CMN		TX_retrpo; */
+	/* TX_RTP_88E		TX_retrpo; */
+	/* TX_RTP_8195		TX_retrpo; */
+
+	/*  */
+	/* ODM Structure */
+	/*  */
+	struct odm_fat_t		DM_FatTable;
+	struct dig_t	DM_DigTable;
+	struct dynamic_pwr_sav		DM_PSTable;
+	struct pri_cca	DM_PriCCA;
+	struct rx_hp		DM_RXHP_Table;
+	struct false_alarm_stats	FalseAlmCnt;
+	struct false_alarm_stats	FlaseAlmCntBuddyAdapter;
+	struct sw_ant_sw		DM_SWAT_Table;
+	bool		RSSI_test;
+
+	struct edca_turbo		DM_EDCA_Table;
+	u32		WMMEDCA_BE;
+	/*  Copy from SD4 structure */
+	/*  */
+	/*  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D */
+	/*  */
+
+	/* common */
+	bool			*pbDriverStopped;
+	bool			*pbDriverIsGoingToPnpSetPowerSleep;
+	bool			*pinit_adpt_in_progress;
+
+	/* PSD */
+	bool			bUserAssignLevel;
+	struct timer_list	PSDTimer;
+	u8			RSSI_BT;			/* come from BT */
+	bool			bPSDinProcess;
+	bool			bDMInitialGainEnable;
+
+	/* for rate adaptive, in fact,  88c/92c fw will handle this */
+	u8			bUseRAMask;
+
+	struct odm_rate_adapt	RateAdaptive;
+
+
+	struct odm_rf_cal_t	RFCalibrateInfo;
+
+	/*  */
+	/*  TX power tracking */
+	/*  */
+	u8			BbSwingIdxOfdm;
+	u8			BbSwingIdxOfdmCurrent;
+	u8			BbSwingIdxOfdmBase;
+	bool			BbSwingFlagOfdm;
+	u8			BbSwingIdxCck;
+	u8			BbSwingIdxCckCurrent;
+	u8			BbSwingIdxCckBase;
+	bool			BbSwingFlagCck;
+	/*  */
+	/*  ODM system resource. */
+	/*  */
+
+	/*  ODM relative time. */
+	struct timer_list PathDivSwitchTimer;
+	/* 2011.09.27 add for Path Diversity */
+	struct timer_list CCKPathDiversityTimer;
+	struct timer_list FastAntTrainingTimer;
+
+	/*  ODM relative workitem. */
+};	/*  DM_Dynamic_Mechanism_Structure */
+
+enum odm_rf_content {
+	odm_radioa_txt =3D 0x1000,
+	odm_radiob_txt =3D 0x1001,
+	odm_radioc_txt =3D 0x1002,
+	odm_radiod_txt =3D 0x1003
+};
+
+enum odm_bb_config_type {
+    CONFIG_BB_PHY_REG,
+    CONFIG_BB_AGC_TAB,
+    CONFIG_BB_AGC_TAB_2G,
+    CONFIG_BB_AGC_TAB_5G,
+    CONFIG_BB_PHY_REG_PG,
+};
+
+/*  Status code */
+enum rt_status {
+	RT_STATUS_SUCCESS,
+	RT_STATUS_FAILURE,
+	RT_STATUS_PENDING,
+	RT_STATUS_RESOURCE,
+	RT_STATUS_INVALID_CONTEXT,
+	RT_STATUS_INVALID_PARAMETER,
+	RT_STATUS_NOT_SUPPORT,
+	RT_STATUS_OS_API_FAILED,
+};
+
+/* include "odm_function.h" */
+
+/* 3=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 DIG */
+/* 3=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+
+enum dm_dig_op {
+	DIG_TYPE_THRESH_HIGH	=3D 0,
+	DIG_TYPE_THRESH_LOW	=3D 1,
+	DIG_TYPE_BACKOFF		=3D 2,
+	DIG_TYPE_RX_GAIN_MIN	=3D 3,
+	DIG_TYPE_RX_GAIN_MAX	=3D 4,
+	DIG_TYPE_ENABLE			=3D 5,
+	DIG_TYPE_DISABLE		=3D 6,
+	DIG_OP_TYPE_MAX
+};
+
+#define		DM_DIG_THRESH_HIGH			40
+#define		DM_DIG_THRESH_LOW			35
+
+#define		DM_SCAN_RSSI_TH				0x14 /* scan return issue for LC */
+
+
+#define		DM_FALSEALARM_THRESH_LOW	400
+#define		DM_FALSEALARM_THRESH_HIGH	1000
+
+#define		DM_DIG_MAX_NIC				0x4e
+#define		DM_DIG_MIN_NIC				0x1e
+
+#define		DM_DIG_MAX_AP				0x32
+#define		DM_DIG_MIN_AP				0x20
+
+#define		DM_DIG_MAX_NIC_HP			0x46
+#define		DM_DIG_MIN_NIC_HP			0x2e
+
+#define		DM_DIG_MAX_AP_HP				0x42
+#define		DM_DIG_MIN_AP_HP				0x30
+
+/* vivi 92c&92d has different definition, 20110504 */
+/* this is for 92c */
+#define		DM_DIG_FA_TH0				0x200
+#define		DM_DIG_FA_TH1				0x300
+#define		DM_DIG_FA_TH2				0x400
+/* this is for 92d */
+#define		DM_DIG_FA_TH0_92D			0x100
+#define		DM_DIG_FA_TH1_92D			0x400
+#define		DM_DIG_FA_TH2_92D			0x600
+
+#define		DM_DIG_BACKOFF_MAX			12
+#define		DM_DIG_BACKOFF_MIN			-4
+#define		DM_DIG_BACKOFF_DEFAULT		10
+
+/* 3=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 AGC RX High Power Mode */
+/* 3=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+#define          LNA_Low_Gain_1                      0x64
+#define          LNA_Low_Gain_2                      0x5A
+#define          LNA_Low_Gain_3                      0x58
+
+#define          FA_RXHP_TH1                           5000
+#define          FA_RXHP_TH2                           1500
+#define          FA_RXHP_TH3                             800
+#define          FA_RXHP_TH4                             600
+#define          FA_RXHP_TH5                             500
+
+/* 3=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 EDCA */
+/* 3=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+
+/* 3=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 Dynamic Tx Power */
+/* 3=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* Dynamic Tx Power Control Threshold */
+#define		TX_POWER_NEAR_FIELD_THRESH_LVL2	74
+#define		TX_POWER_NEAR_FIELD_THRESH_LVL1	67
+#define		TX_POWER_NEAR_FIELD_THRESH_AP		0x3F
+
+#define		TxHighPwrLevel_Normal		0
+#define		TxHighPwrLevel_Level1		1
+#define		TxHighPwrLevel_Level2		2
+#define		TxHighPwrLevel_BT1			3
+#define		TxHighPwrLevel_BT2			4
+#define		TxHighPwrLevel_15			5
+#define		TxHighPwrLevel_35			6
+#define		TxHighPwrLevel_50			7
+#define		TxHighPwrLevel_70			8
+#define		TxHighPwrLevel_100			9
+
+/* 3=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 Rate Adaptive */
+/* 3=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+#define		DM_RATR_STA_INIT			0
+#define		DM_RATR_STA_HIGH			1
+#define			DM_RATR_STA_MIDDLE		2
+#define			DM_RATR_STA_LOW			3
+
+/* 3=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 BB Power Save */
+/* 3=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+
+
+enum dm_1r_cca {
+	CCA_1R =3D0,
+	CCA_2R =3D 1,
+	CCA_MAX =3D 2,
+};
+
+enum dm_rf_def {
+	RF_Save =3D0,
+	RF_Normal =3D 1,
+	RF_MAX =3D 2,
+};
+
+/* 3=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 Antenna Diversity */
+/* 3=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+enum dm_swas {
+	Antenna_A =3D 1,
+	Antenna_B =3D 2,
+	Antenna_MAX =3D 3,
+};
+
+/*  Maximal number of antenna detection mechanism needs to perform, ad=
ded by Roger, 2011.12.28. */
+#define	MAX_ANTENNA_DETECTION_CNT	10
+
+/*  */
+/*  Extern Global Variables. */
+/*  */
+#define	OFDM_TABLE_SIZE_92C	37
+#define	OFDM_TABLE_SIZE_92D	43
+#define	CCK_TABLE_SIZE		33
+
+extern	u32 OFDMSwingTable23A[OFDM_TABLE_SIZE_92D];
+extern	u8 CCKSwingTable_Ch1_Ch1323A[CCK_TABLE_SIZE][8];
+extern	u8 CCKSwingTable_Ch1423A [CCK_TABLE_SIZE][8];
+
+
+
+/*  */
+/*  check Sta pointer valid or not */
+/*  */
+#define IS_STA_VALID(pSta)		(pSta)
+/*  20100514 Joseph: Add definition for antenna switching test after l=
ink. */
+/*  This indicates two different the steps. */
+/*  In SWAW_STEP_PEAK, driver needs to switch antenna and listen to th=
e signal on the air. */
+/*  In SWAW_STEP_DETERMINE, driver just compares the signal captured i=
n SWAW_STEP_PEAK */
+/*  with original RSSI to determine if it is necessary to switch anten=
na. */
+#define SWAW_STEP_PEAK		0
+#define SWAW_STEP_DETERMINE	1
+
+void ODM_Write_DIG23a(struct dm_odm_t *pDM_Odm,	u8	CurrentIGI);
+void ODM_Write_CCK_CCA_Thres23a(struct dm_odm_t *pDM_Odm, u8	CurCCK_CC=
AThres);
+
+void ODM_SetAntenna(struct dm_odm_t *pDM_Odm, u8 Antenna);
+
+
+#define dm_RF_Saving	ODM_RF_Saving23a
+void ODM_RF_Saving23a(struct dm_odm_t *pDM_Odm, u8 bForceInNormal);
+
+#define SwAntDivRestAfterLink	ODM_SwAntDivRestAfterLink
+void ODM_SwAntDivRestAfterLink(struct dm_odm_t *pDM_Odm);
+
+#define dm_CheckTXPowerTracking		ODM_TXPowerTrackingCheck23a
+void ODM_TXPowerTrackingCheck23a(struct dm_odm_t *pDM_Odm);
+
+bool ODM_RAStateCheck23a(struct dm_odm_t *pDM_Odm, s32 RSSI, bool bFor=
ceUpdate,
+		      u8 *pRATRState);
+
+
+#define dm_SWAW_RSSI_Check	ODM_SwAntDivChkPerPktRssi
+void ODM_SwAntDivChkPerPktRssi(struct dm_odm_t *pDM_Odm, u8 StationID,
+			       struct odm_phy_info *pPhyInfo);
+
+u32 ConvertTo_dB23a(u32 Value);
+
+u32 GetPSDData(struct dm_odm_t *pDM_Odm, unsigned int point, u8 initia=
l_gain_psd);
+
+void odm_DIG23abyRSSI_LPS(struct dm_odm_t *pDM_Odm);
+
+u32 ODM_Get_Rate_Bitmap23a(struct dm_odm_t *pDM_Odm, u32 macid, u32 ra=
_mask, u8 rssi_level);
+
+
+void ODM23a_DMInit(struct dm_odm_t *pDM_Odm);
+
+void ODM_DMWatchdog23a(struct dm_odm_t *pDM_Odm); /*  For common use i=
n the future */
+
+void ODM_CmnInfoInit23a(struct dm_odm_t *pDM_Odm, enum odm_cmninfo	Cmn=
Info, u32 Value);
+
+void ODM23a_CmnInfoHook(struct dm_odm_t *pDM_Odm, enum odm_cmninfo	Cmn=
Info, void *pValue);
+
+void ODM_CmnInfoPtrArrayHook23a(struct dm_odm_t *pDM_Odm, enum odm_cmn=
info	CmnInfo, u16 Index, void *pValue);
+
+void ODM_CmnInfoUpdate23a(struct dm_odm_t *pDM_Odm, u32 CmnInfo, u64 V=
alue);
+
+void ODM_InitAllTimers(struct dm_odm_t *pDM_Odm);
+
+void ODM_CancelAllTimers(struct dm_odm_t *pDM_Odm);
+
+void ODM_ReleaseAllTimers(struct dm_odm_t *pDM_Odm);
+
+void ODM_ResetIQKResult(struct dm_odm_t *pDM_Odm);
+
+void ODM_AntselStatistics_88C(struct dm_odm_t *pDM_Odm, u8 MacId, u32 =
PWDBAll, bool isCCKrate);
+
+void ODM_SingleDualAntennaDefaultSetting(struct dm_odm_t *pDM_Odm);
+
+bool ODM_SingleDualAntennaDetection(struct dm_odm_t *pDM_Odm, u8 mode)=
;
+
+void odm_dtc(struct dm_odm_t *pDM_Odm);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/odm_HWConfig.h b/drivers=
/staging/rtl8723au/include/odm_HWConfig.h
new file mode 100644
index 0000000..057fdb0
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/odm_HWConfig.h
@@ -0,0 +1,174 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+
+
+#ifndef	__HALHWOUTSRC_H__
+#define __HALHWOUTSRC_H__
+
+#include <Hal8723APhyCfg.h>
+
+/*  */
+/*  Definition */
+/*  */
+/*  */
+/*  */
+/*  CCK Rates, TxHT =3D 0 */
+#define DESC92C_RATE1M					0x00
+#define DESC92C_RATE2M					0x01
+#define DESC92C_RATE5_5M				0x02
+#define DESC92C_RATE11M				0x03
+
+/*  OFDM Rates, TxHT =3D 0 */
+#define DESC92C_RATE6M					0x04
+#define DESC92C_RATE9M					0x05
+#define DESC92C_RATE12M				0x06
+#define DESC92C_RATE18M				0x07
+#define DESC92C_RATE24M				0x08
+#define DESC92C_RATE36M				0x09
+#define DESC92C_RATE48M				0x0a
+#define DESC92C_RATE54M				0x0b
+
+/*  MCS Rates, TxHT =3D 1 */
+#define DESC92C_RATEMCS0				0x0c
+#define DESC92C_RATEMCS1				0x0d
+#define DESC92C_RATEMCS2				0x0e
+#define DESC92C_RATEMCS3				0x0f
+#define DESC92C_RATEMCS4				0x10
+#define DESC92C_RATEMCS5				0x11
+#define DESC92C_RATEMCS6				0x12
+#define DESC92C_RATEMCS7				0x13
+#define DESC92C_RATEMCS8				0x14
+#define DESC92C_RATEMCS9				0x15
+#define DESC92C_RATEMCS10				0x16
+#define DESC92C_RATEMCS11				0x17
+#define DESC92C_RATEMCS12				0x18
+#define DESC92C_RATEMCS13				0x19
+#define DESC92C_RATEMCS14				0x1a
+#define DESC92C_RATEMCS15				0x1b
+#define DESC92C_RATEMCS15_SG			0x1c
+#define DESC92C_RATEMCS32				0x20
+
+
+/*  */
+/*  structure and define */
+/*  */
+
+struct phy_rx_agc_info {
+	#ifdef __LITTLE_ENDIAN
+		u8	gain:7,trsw:1;
+	#else
+		u8	trsw:1,gain:7;
+	#endif
+};
+
+struct phy_status_rpt {
+	struct phy_rx_agc_info path_agc[2];
+	u8	ch_corr[2];
+	u8	cck_sig_qual_ofdm_pwdb_all;
+	u8	cck_agc_rpt_ofdm_cfosho_a;
+	u8	cck_rpt_b_ofdm_cfosho_b;
+	u8	rsvd_1;/* ch_corr_msb; */
+	u8	noise_power_db_msb;
+	u8	path_cfotail[2];
+	u8	pcts_mask[2];
+	s8	stream_rxevm[2];
+	u8	path_rxsnr[2];
+	u8	noise_power_db_lsb;
+	u8	rsvd_2[3];
+	u8	stream_csi[2];
+	u8	stream_target_csi[2];
+	s8	sig_evm;
+	u8	rsvd_3;
+
+#ifdef __LITTLE_ENDIAN
+	u8	antsel_rx_keep_2:1;	/* ex_intf_flg:1; */
+	u8	sgi_en:1;
+	u8	rxsc:2;
+	u8	idle_long:1;
+	u8	r_ant_train_en:1;
+	u8	ant_sel_b:1;
+	u8	ant_sel:1;
+#else	/*  _BIG_ENDIAN_ */
+	u8	ant_sel:1;
+	u8	ant_sel_b:1;
+	u8	r_ant_train_en:1;
+	u8	idle_long:1;
+	u8	rxsc:2;
+	u8	sgi_en:1;
+	u8	antsel_rx_keep_2:1;	/* ex_intf_flg:1; */
+#endif
+};
+
+
+struct phy_status_rpt_8195 {
+	struct phy_rx_agc_info path_agc[2];
+	u8	ch_num[2];
+	u8	cck_sig_qual_ofdm_pwdb_all;
+	u8	cck_agc_rpt_ofdm_cfosho_a;
+	u8	cck_bb_pwr_ofdm_cfosho_b;
+	u8    cck_rx_path;	/* CCK_RX_PATH [3:0] (with regA07[3:0] definition)=
 */
+	u8	rsvd_1;
+	u8	path_cfotail[2];
+	u8	pcts_mask[2];
+	s8	stream_rxevm[2];
+	u8	path_rxsnr[2];
+	u8	rsvd_2[2];
+	u8	stream_snr[2];
+	u8	stream_csi[2];
+	u8	rsvd_3[2];
+	s8	sig_evm;
+	u8	rsvd_4;
+#ifdef __LITTLE_ENDIAN
+	u8	antidx_anta:3;
+	u8	antidx_antb:3;
+	u8	rsvd_5:2;
+#else	/*  _BIG_ENDIAN_ */
+	u8	rsvd_5:2;
+	u8	antidx_antb:3;
+	u8	antidx_anta:3;
+#endif
+};
+
+
+void odm_Init_RSSIForDM23a(struct dm_odm_t *pDM_Odm);
+
+void
+ODM_PhyStatusQuery23a(
+	struct dm_odm_t *pDM_Odm,
+	struct odm_phy_info *pPhyInfo,
+	u8 *						pPhyStatus,
+	struct odm_packet_info *pPktinfo
+	);
+
+void ODM_MacStatusQuery23a(struct dm_odm_t *pDM_Odm,
+	u8 *pMacStatus,
+	u8 MacID,
+	bool bPacketMatchBSSID,
+	bool bPacketToSelf,
+	bool bPacketBeacon
+);
+
+enum hal_status ODM_ConfigRFWithHeaderFile23a(struct dm_odm_t *pDM_Odm=
,
+	enum RF_RADIO_PATH	Content,
+	enum RF_RADIO_PATH	eRFPath
+);
+
+enum hal_status ODM_ConfigBBWithHeaderFile23a(struct dm_odm_t *pDM_Odm=
,
+	enum odm_bb_config_type		ConfigType
+);
+
+enum hal_status ODM_ConfigMACWithHeaderFile23a(struct dm_odm_t *pDM_Od=
m);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/odm_RegConfig8723A.h b/d=
rivers/staging/rtl8723au/include/odm_RegConfig8723A.h
new file mode 100644
index 0000000..4ea579b
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/odm_RegConfig8723A.h
@@ -0,0 +1,34 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __INC_ODM_REGCONFIG_H_8723A
+#define __INC_ODM_REGCONFIG_H_8723A
+
+void odm_ConfigRFReg_8723A(struct dm_odm_t *pDM_Odm, u32 Addr, u32 Dat=
a,
+			   enum RF_RADIO_PATH RF_PATH, u32 RegAddr);
+
+void odm_ConfigRF_RadioA_8723A(struct dm_odm_t *pDM_Odm, u32 Addr, u32=
 Data);
+
+void odm_ConfigRF_RadioB_8723A(struct dm_odm_t *pDM_Odm, u32 Addr, u32=
 Data);
+
+void odm_ConfigMAC_8723A(struct dm_odm_t *pDM_Odm, u32 Addr, u8 Data);
+
+void odm_ConfigBB_AGC_8723A(struct dm_odm_t *pDM_Odm, u32 Addr,
+			    u32 Bitmask, u32 Data);
+
+void odm_ConfigBB_PHY_REG_PG_8723A(struct dm_odm_t *pDM_Odm, u32 Addr,=
 u32 Bitmask, u32 Data);
+
+void odm_ConfigBB_PHY_8723A(struct dm_odm_t *pDM_Odm, u32 Addr, u32 Bi=
tmask, u32 Data);
+
+#endif /*  end of SUPPORT */
diff --git a/drivers/staging/rtl8723au/include/odm_RegDefine11AC.h b/dr=
ivers/staging/rtl8723au/include/odm_RegDefine11AC.h
new file mode 100644
index 0000000..77b7ace
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/odm_RegDefine11AC.h
@@ -0,0 +1,49 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+
+#ifndef	__ODM_REGDEFINE11AC_H__
+#define __ODM_REGDEFINE11AC_H__
+
+/* 2 RF REG LIST */
+
+
+
+/* 2 BB REG LIST */
+/* PAGE 8 */
+/* PAGE 9 */
+#define	ODM_REG_OFDM_FA_RST_11AC		0x9A4
+/* PAGE A */
+#define	ODM_REG_CCK_CCA_11AC				0xA0A
+#define	ODM_REG_CCK_FA_RST_11AC			0xA2C
+#define	ODM_REG_CCK_FA_11AC				0xA5C
+/* PAGE C */
+#define	ODM_REG_IGI_A_11AC				0xC50
+/* PAGE E */
+#define	ODM_REG_IGI_B_11AC				0xE50
+/* PAGE F */
+#define	ODM_REG_OFDM_FA_11AC			0xF48
+
+
+/* 2 MAC REG LIST */
+
+
+
+
+/* DIG Related */
+#define	ODM_BIT_IGI_11AC				0xFFFFFFFF
+
+
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/odm_RegDefine11N.h b/dri=
vers/staging/rtl8723au/include/odm_RegDefine11N.h
new file mode 100644
index 0000000..2778215
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/odm_RegDefine11N.h
@@ -0,0 +1,165 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+
+#ifndef	__ODM_REGDEFINE11N_H__
+#define __ODM_REGDEFINE11N_H__
+
+
+/* 2 RF REG LIST */
+#define	ODM_REG_RF_MODE_11N			0x00
+#define	ODM_REG_RF_0B_11N			0x0B
+#define	ODM_REG_CHNBW_11N			0x18
+#define	ODM_REG_T_METER_11N			0x24
+#define	ODM_REG_RF_25_11N			0x25
+#define	ODM_REG_RF_26_11N			0x26
+#define	ODM_REG_RF_27_11N			0x27
+#define	ODM_REG_RF_2B_11N			0x2B
+#define	ODM_REG_RF_2C_11N			0x2C
+#define	ODM_REG_RXRF_A3_11N			0x3C
+#define	ODM_REG_T_METER_92D_11N			0x42
+#define	ODM_REG_T_METER_88E_11N			0x42
+
+
+
+/* 2 BB REG LIST */
+/* PAGE 8 */
+#define	ODM_REG_BB_CTRL_11N			0x800
+#define	ODM_REG_RF_PIN_11N			0x804
+#define	ODM_REG_PSD_CTRL_11N			0x808
+#define	ODM_REG_TX_ANT_CTRL_11N			0x80C
+#define	ODM_REG_BB_PWR_SAV5_11N			0x818
+#define	ODM_REG_CCK_RPT_FORMAT_11N		0x824
+#define	ODM_REG_RX_DEFUALT_A_11N		0x858
+#define	ODM_REG_RX_DEFUALT_B_11N		0x85A
+#define	ODM_REG_BB_PWR_SAV3_11N			0x85C
+#define	ODM_REG_ANTSEL_CTRL_11N			0x860
+#define	ODM_REG_RX_ANT_CTRL_11N			0x864
+#define	ODM_REG_PIN_CTRL_11N			0x870
+#define	ODM_REG_BB_PWR_SAV1_11N			0x874
+#define	ODM_REG_ANTSEL_PATH_11N			0x878
+#define	ODM_REG_BB_3WIRE_11N			0x88C
+#define	ODM_REG_SC_CNT_11N			0x8C4
+#define	ODM_REG_PSD_DATA_11N			0x8B4
+/* PAGE 9 */
+#define	ODM_REG_ANT_MAPPING1_11N		0x914
+#define	ODM_REG_ANT_MAPPING2_11N		0x918
+/* PAGE A */
+#define	ODM_REG_CCK_ANTDIV_PARA1_11N		0xA00
+#define	ODM_REG_CCK_CCA_11N			0xA0A
+#define	ODM_REG_CCK_ANTDIV_PARA2_11N		0xA0C
+#define	ODM_REG_CCK_ANTDIV_PARA3_11N		0xA10
+#define	ODM_REG_CCK_ANTDIV_PARA4_11N		0xA14
+#define	ODM_REG_CCK_FILTER_PARA1_11N		0xA22
+#define	ODM_REG_CCK_FILTER_PARA2_11N		0xA23
+#define	ODM_REG_CCK_FILTER_PARA3_11N		0xA24
+#define	ODM_REG_CCK_FILTER_PARA4_11N		0xA25
+#define	ODM_REG_CCK_FILTER_PARA5_11N		0xA26
+#define	ODM_REG_CCK_FILTER_PARA6_11N		0xA27
+#define	ODM_REG_CCK_FILTER_PARA7_11N		0xA28
+#define	ODM_REG_CCK_FILTER_PARA8_11N		0xA29
+#define	ODM_REG_CCK_FA_RST_11N			0xA2C
+#define	ODM_REG_CCK_FA_MSB_11N			0xA58
+#define	ODM_REG_CCK_FA_LSB_11N			0xA5C
+#define	ODM_REG_CCK_CCA_CNT_11N			0xA60
+#define	ODM_REG_BB_PWR_SAV4_11N			0xA74
+/* PAGE B */
+#define	ODM_REG_LNA_SWITCH_11N			0xB2C
+#define	ODM_REG_PATH_SWITCH_11N			0xB30
+#define	ODM_REG_RSSI_CTRL_11N			0xB38
+#define	ODM_REG_CONFIG_ANTA_11N			0xB68
+#define	ODM_REG_RSSI_BT_11N			0xB9C
+/* PAGE C */
+#define	ODM_REG_OFDM_FA_HOLDC_11N		0xC00
+#define	ODM_REG_RX_PATH_11N			0xC04
+#define	ODM_REG_TRMUX_11N			0xC08
+#define	ODM_REG_OFDM_FA_RSTC_11N		0xC0C
+#define	ODM_REG_RXIQI_MATRIX_11N		0xC14
+#define	ODM_REG_TXIQK_MATRIX_LSB1_11N		0xC4C
+#define	ODM_REG_IGI_A_11N			0xC50
+#define	ODM_REG_ANTDIV_PARA2_11N		0xC54
+#define	ODM_REG_IGI_B_11N			0xC58
+#define	ODM_REG_ANTDIV_PARA3_11N		0xC5C
+#define	ODM_REG_BB_PWR_SAV2_11N			0xC70
+#define	ODM_REG_RX_OFF_11N			0xC7C
+#define	ODM_REG_TXIQK_MATRIXA_11N		0xC80
+#define	ODM_REG_TXIQK_MATRIXB_11N		0xC88
+#define	ODM_REG_TXIQK_MATRIXA_LSB2_11N		0xC94
+#define	ODM_REG_TXIQK_MATRIXB_LSB2_11N		0xC9C
+#define	ODM_REG_RXIQK_MATRIX_LSB_11N		0xCA0
+#define	ODM_REG_ANTDIV_PARA1_11N		0xCA4
+#define	ODM_REG_OFDM_FA_TYPE1_11N		0xCF0
+/* PAGE D */
+#define	ODM_REG_OFDM_FA_RSTD_11N		0xD00
+#define	ODM_REG_OFDM_FA_TYPE2_11N		0xDA0
+#define	ODM_REG_OFDM_FA_TYPE3_11N		0xDA4
+#define	ODM_REG_OFDM_FA_TYPE4_11N		0xDA8
+/* PAGE E */
+#define	ODM_REG_TXAGC_A_6_18_11N		0xE00
+#define	ODM_REG_TXAGC_A_24_54_11N		0xE04
+#define	ODM_REG_TXAGC_A_1_MCS32_11N		0xE08
+#define	ODM_REG_TXAGC_A_MCS0_3_11N		0xE10
+#define	ODM_REG_TXAGC_A_MCS4_7_11N		0xE14
+#define	ODM_REG_TXAGC_A_MCS8_11_11N		0xE18
+#define	ODM_REG_TXAGC_A_MCS12_15_11N		0xE1C
+#define	ODM_REG_FPGA0_IQK_11N			0xE28
+#define	ODM_REG_TXIQK_TONE_A_11N		0xE30
+#define	ODM_REG_RXIQK_TONE_A_11N		0xE34
+#define	ODM_REG_TXIQK_PI_A_11N			0xE38
+#define	ODM_REG_RXIQK_PI_A_11N			0xE3C
+#define	ODM_REG_TXIQK_11N			0xE40
+#define	ODM_REG_RXIQK_11N			0xE44
+#define	ODM_REG_IQK_AGC_PTS_11N			0xE48
+#define	ODM_REG_IQK_AGC_RSP_11N			0xE4C
+#define	ODM_REG_BLUETOOTH_11N			0xE6C
+#define	ODM_REG_RX_WAIT_CCA_11N			0xE70
+#define	ODM_REG_TX_CCK_RFON_11N			0xE74
+#define	ODM_REG_TX_CCK_BBON_11N			0xE78
+#define	ODM_REG_OFDM_RFON_11N			0xE7C
+#define	ODM_REG_OFDM_BBON_11N			0xE80
+#define ODM_REG_TX2RX_11N			0xE84
+#define	ODM_REG_TX2TX_11N			0xE88
+#define	ODM_REG_RX_CCK_11N			0xE8C
+#define	ODM_REG_RX_OFDM_11N			0xED0
+#define	ODM_REG_RX_WAIT_RIFS_11N		0xED4
+#define	ODM_REG_RX2RX_11N			0xED8
+#define	ODM_REG_STANDBY_11N			0xEDC
+#define	ODM_REG_SLEEP_11N			0xEE0
+#define	ODM_REG_PMPD_ANAEN_11N			0xEEC
+
+
+
+
+
+
+
+/* 2 MAC REG LIST */
+#define	ODM_REG_BB_RST_11N			0x02
+#define	ODM_REG_ANTSEL_PIN_11N			0x4C
+#define	ODM_REG_EARLY_MODE_11N			0x4D0
+#define	ODM_REG_RSSI_MONITOR_11N		0x4FE
+#define	ODM_REG_EDCA_VO_11N			0x500
+#define	ODM_REG_EDCA_VI_11N			0x504
+#define	ODM_REG_EDCA_BE_11N			0x508
+#define	ODM_REG_EDCA_BK_11N			0x50C
+#define	ODM_REG_TXPAUSE_11N			0x522
+#define	ODM_REG_RESP_TX_11N			0x6D8
+#define	ODM_REG_ANT_TRAIN_PARA1_11N		0x7b0
+#define	ODM_REG_ANT_TRAIN_PARA2_11N		0x7b4
+
+
+/* DIG Related */
+#define	ODM_BIT_IGI_11N				0x0000007F
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/odm_debug.h b/drivers/st=
aging/rtl8723au/include/odm_debug.h
new file mode 100644
index 0000000..5bc51d0
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/odm_debug.h
@@ -0,0 +1,139 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+
+
+#ifndef	__ODM_DBG_H__
+#define __ODM_DBG_H__
+
+
+/*  */
+/*	Define the debug levels */
+/*  */
+/*	1.	DBG_TRACE and DBG_LOUD are used for normal cases. */
+/*	So that, they can help SW engineer to develope or trace states chan=
ged */
+/*	and also help HW enginner to trace every operation to and from HW, =
*/
+/*	e.g IO, Tx, Rx. */
+/*  */
+/*	2.	DBG_WARNNING and DBG_SERIOUS are used for unusual or error cases=
, */
+/*	which help us to debug SW or HW. */
+/*  */
+/*  */
+/*  */
+/*	Never used in a call to ODM_RT_TRACE()! */
+/*  */
+#define ODM_DBG_OFF					1
+
+/*  */
+/*	Fatal bug. */
+/*	For example, Tx/Rx/IO locked up, OS hangs, memory access violation,=
 */
+/*	resource allocation failed, unexpected HW behavior, HW BUG and so o=
n. */
+/*  */
+#define ODM_DBG_SERIOUS				2
+
+/*  */
+/*	Abnormal, rare, or unexpeted cases. */
+/*	For example, IRP/Packet/OID canceled, device suprisely unremoved an=
d so on. */
+/*  */
+#define ODM_DBG_WARNING				3
+
+/*  */
+/*	Normal case with useful information about current SW or HW state. *=
/
+/*	For example, Tx/Rx descriptor to fill, Tx/Rx descriptor completed s=
tatus, */
+/*	SW protocol state change, dynamic mechanism state change and so on.=
 */
+/*  */
+#define ODM_DBG_LOUD					4
+
+/*  */
+/*	Normal case with detail execution flow or information. */
+/*  */
+#define ODM_DBG_TRACE					5
+
+/*  */
+/*  Define the tracing components */
+/*  */
+/*  */
+/* BB Functions */
+#define ODM_COMP_DIG				BIT0
+#define ODM_COMP_RA_MASK			BIT1
+#define ODM_COMP_DYNAMIC_TXPWR			BIT2
+#define ODM_COMP_FA_CNT				BIT3
+#define ODM_COMP_RSSI_MONITOR			BIT4
+#define ODM_COMP_CCK_PD				BIT5
+#define ODM_COMP_ANT_DIV			BIT6
+#define ODM_COMP_PWR_SAVE			BIT7
+#define ODM_COMP_PWR_TRAIN			BIT8
+#define ODM_COMP_RATE_ADAPTIVE			BIT9
+#define ODM_COMP_PATH_DIV			BIT10
+#define ODM_COMP_PSD				BIT11
+#define ODM_COMP_DYNAMIC_PRICCA			BIT12
+#define ODM_COMP_RXHP				BIT13
+/* MAC Functions */
+#define ODM_COMP_EDCA_TURBO			BIT16
+#define ODM_COMP_EARLY_MODE			BIT17
+/* RF Functions */
+#define ODM_COMP_TX_PWR_TRACK			BIT24
+#define ODM_COMP_RX_GAIN_TRACK			BIT25
+#define ODM_COMP_CALIBRATION			BIT26
+/* Common Functions */
+#define ODM_COMP_COMMON				BIT30
+#define ODM_COMP_INIT				BIT31
+
+/*------------------------Export Macro Definition---------------------=
------*/
+	#define DbgPrint	printk
+	#define RT_PRINTK(fmt, args...)	DbgPrint("%s(): " fmt, __func__, ## a=
rgs);
+
+#ifndef ASSERT
+	#define ASSERT(expr)
+#endif
+
+#define ODM_RT_TRACE(pDM_Odm, comp, level, fmt)							\
+		if(((comp) & pDM_Odm->DebugComponents) && (level <=3D pDM_Odm->Debug=
Level))	\
+		{										\
+			DbgPrint("[ODM-8723A] ");						\
+			RT_PRINTK fmt;								\
+		}
+
+#define ODM_RT_TRACE_F(pDM_Odm, comp, level, fmt)						\
+		if(((comp) & pDM_Odm->DebugComponents) && (level <=3D pDM_Odm->Debug=
Level))	\
+		{										\
+			RT_PRINTK fmt;								\
+		}
+
+#define ODM_RT_ASSERT(pDM_Odm, expr, fmt)							\
+		if(!(expr)) {									\
+			DbgPrint("Assertion failed! %s at ......\n", #expr);			\
+			DbgPrint("      ......%s,%s,line=3D%d\n", __FILE__, __func__, __LIN=
E__);\
+			RT_PRINTK fmt;								\
+			ASSERT(false);								\
+		}
+#define ODM_dbg_enter() { DbgPrint("=3D=3D> %s\n", __func__); }
+#define ODM_dbg_exit() { DbgPrint("<=3D=3D %s\n", __func__); }
+#define ODM_dbg_trace(str) { DbgPrint("%s:%s\n", __func__, str); }
+
+#define ODM_PRINT_ADDR(pDM_Odm, comp, level, title_str, ptr)						\
+			if(((comp) & pDM_Odm->DebugComponents) && (level <=3D pDM_Odm->Debu=
gLevel){	\
+				int __i;			\
+				u8 *	__ptr =3D (u8 *)ptr;	\
+				DbgPrint("[ODM] ");		\
+				DbgPrint(title_str);		\
+				DbgPrint(" ");			\
+				for (__i=3D0; __i < 6; __i++)	\
+					DbgPrint("%02X%s", __ptr[__i], (__i =3D=3D 5) ? "" : "-");		\
+				DbgPrint("\n");			\
+			}
+
+void ODM_InitDebugSetting23a(struct dm_odm_t *pDM_Odm);
+
+#endif	/*  __ODM_DBG_H__ */
diff --git a/drivers/staging/rtl8723au/include/odm_interface.h b/driver=
s/staging/rtl8723au/include/odm_interface.h
new file mode 100644
index 0000000..f216b58
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/odm_interface.h
@@ -0,0 +1,131 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+
+
+#ifndef	__ODM_INTERFACE_H__
+#define __ODM_INTERFACE_H__
+
+
+
+/*  */
+/*  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D Constant/Structure/Enum/... Defi=
ne */
+/*  */
+
+
+
+/*  */
+/*  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D Macro Define */
+/*  */
+
+#define _reg_all(_name)			ODM_##_name
+#define _reg_ic(_name, _ic)		ODM_##_name##_ic
+#define _bit_all(_name)			BIT_##_name
+#define _bit_ic(_name, _ic)		BIT_##_name##_ic
+
+/*  _cat: implemented by Token-Pasting Operator. */
+
+/*=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+
+#define ODM_REG_DIG_11N		0xC50
+#define ODM_REG_DIG_11AC	0xDDD
+
+ODM_REG(DIG,_pDM_Odm)
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D*/
+
+#define _reg_11N(_name)			ODM_REG_##_name##_11N
+#define _reg_11AC(_name)		ODM_REG_##_name##_11AC
+#define _bit_11N(_name)			ODM_BIT_##_name##_11N
+#define _bit_11AC(_name)		ODM_BIT_##_name##_11AC
+
+#define _cat(_name, _ic_type, _func)									\
+	(															\
+		((_ic_type) & ODM_IC_11N_SERIES)? _func##_11N(_name):		\
+		_func##_11AC(_name)									\
+	)
+
+/*  _name: name of register or bit. */
+/*  Example: "ODM_REG(R_A_AGC_CORE1, pDM_Odm)" */
+/*         gets "ODM_R_A_AGC_CORE1" or "ODM_R_A_AGC_CORE1_8192C", depe=
nds on SupportICType. */
+#define ODM_REG(_name, _pDM_Odm)	_cat(_name, _pDM_Odm->SupportICType, =
_reg)
+#define ODM_BIT(_name, _pDM_Odm)	_cat(_name, _pDM_Odm->SupportICType, =
_bit)
+
+/*  */
+/*  2012/02/17 MH For non-MP compile pass only. Linux does not support=
 workitem. */
+/*  Suggest HW team to use thread instead of workitem. Windows also su=
pport the feature. */
+/*  */
+typedef void (*RT_WORKITEM_CALL_BACK)(struct work_struct *pContext);
+
+/*  */
+/*  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D Extern Variable ??? It should be=
 forbidden. */
+/*  */
+
+
+/*  */
+/*  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D EXtern Function Prototype */
+/*  */
+
+
+u8 ODM_Read1Byte(struct dm_odm_t *pDM_Odm, u32 RegAddr);
+
+u16 ODM_Read2Byte(struct dm_odm_t *pDM_Odm, u32 RegAddr);
+
+u32 ODM_Read4Byte(struct dm_odm_t *pDM_Odm, u32 RegAddr);
+
+void ODM_Write1Byte(struct dm_odm_t *pDM_Odm, u32 RegAddr, u8 Data);
+
+void ODM_Write2Byte(struct dm_odm_t *pDM_Odm, u32 RegAddr, u16 Data);
+
+void ODM_Write4Byte(struct dm_odm_t *pDM_Odm, u32 RegAddr, u32 Data);
+
+void ODM_SetMACReg(struct dm_odm_t *pDM_Odm, u32 RegAddr, u32 BitMask,=
 u32 Data);
+
+u32 ODM_GetMACReg(struct dm_odm_t *pDM_Odm, u32 RegAddr, u32 BitMask);
+
+void ODM_SetBBReg(struct dm_odm_t *pDM_Odm, u32 RegAddr, u32 BitMask, =
u32 Data);
+
+u32 ODM_GetBBReg(struct dm_odm_t *pDM_Odm, u32 RegAddr, u32 BitMask);
+
+void ODM_SetRFReg(struct dm_odm_t *pDM_Odm, enum RF_RADIO_PATH eRFPath=
,
+		  u32 RegAddr, u32 BitMask, u32 Data);
+
+u32 ODM_GetRFReg(struct dm_odm_t *pDM_Odm, enum RF_RADIO_PATH eRFPath,
+		 u32 RegAddr, u32 BitMask);
+
+/*  Memory Relative Function. */
+void ODM_AllocateMemory(struct dm_odm_t *pDM_Odm, void **pPtr, u32 len=
gth);
+void ODM_FreeMemory(struct dm_odm_t *pDM_Odm, void *pPtr, u32 length);
+
+s32 ODM_CompareMemory(struct dm_odm_t *pDM_Odm, void *pBuf1, void *pBu=
f2, u32 length);
+
+/*  ODM MISC-spin lock relative API. */
+void ODM_AcquireSpinLock(struct dm_odm_t *pDM_Odm, enum rt_spinlock_ty=
pe type);
+
+void ODM_ReleaseSpinLock(struct dm_odm_t *pDM_Odm, enum rt_spinlock_ty=
pe type);
+
+/*  ODM MISC-workitem relative API. */
+void ODM_InitializeWorkItem(struct dm_odm_t *pDM_Odm, void *pRtWorkIte=
m,
+			    RT_WORKITEM_CALL_BACK RtWorkItemCallback, void *pContext, const=
 char *szID);
+
+/*  ODM Timer relative API. */
+void ODM_SetTimer(struct dm_odm_t *pDM_Odm, struct timer_list *pTimer,=
 u32 msDelay);
+
+void ODM_ReleaseTimer(struct dm_odm_t *pDM_Odm, struct timer_list *pTi=
mer);
+
+/*  ODM FW relative API. */
+u32 ODM_FillH2CCmd(u8 *pH2CBuffer, u32 H2CBufferLen, u32 CmdNum,
+		   u32 *pElementID, u32 *pCmdLen, u8 **pCmbBuffer,
+		   u8 *CmdStartSeq);
+
+#endif	/*  __ODM_INTERFACE_H__ */
diff --git a/drivers/staging/rtl8723au/include/odm_precomp.h b/drivers/=
staging/rtl8723au/include/odm_precomp.h
new file mode 100644
index 0000000..f3fc2fa
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/odm_precomp.h
@@ -0,0 +1,54 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+
+#ifndef	__ODM_PRECOMP_H__
+#define __ODM_PRECOMP_H__
+
+#include "odm_types.h"
+
+#define		TEST_FALG___		1
+
+/* 2 Config Flags and Structs - defined by each ODM Type */
+
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <hal_intf.h>
+
+
+/* 2 Hardware Parameter Files */
+#include "Hal8723UHWImg_CE.h"
+
+
+/* 2 OutSrc Header Files */
+
+#include "odm.h"
+#include "odm_HWConfig.h"
+#include "odm_debug.h"
+#include "odm_RegDefine11AC.h"
+#include "odm_RegDefine11N.h"
+
+#include "HalDMOutSrc8723A.h" /* for IQK,LCK,Power-tracking */
+#include "rtl8723a_hal.h"
+
+#include "odm_interface.h"
+#include "odm_reg.h"
+
+#include "HalHWImg8723A_MAC.h"
+#include "HalHWImg8723A_RF.h"
+#include "HalHWImg8723A_BB.h"
+#include "HalHWImg8723A_FW.h"
+#include "odm_RegConfig8723A.h"
+
+#endif	/*  __ODM_PRECOMP_H__ */
diff --git a/drivers/staging/rtl8723au/include/odm_reg.h b/drivers/stag=
ing/rtl8723au/include/odm_reg.h
new file mode 100644
index 0000000..56191e9
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/odm_reg.h
@@ -0,0 +1,114 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+/*  */
+/*  File Name: odm_reg.h */
+/*  */
+/*  Description: */
+/*  */
+/*  This file is for general register definition. */
+/*  */
+/*  */
+/*  */
+#ifndef	__HAL_ODM_REG_H__
+#define __HAL_ODM_REG_H__
+
+/*  */
+/*  Register Definition */
+/*  */
+
+/* MAC REG */
+#define	ODM_BB_RESET					0x002
+#define	ODM_DUMMY						0x4fe
+#define	ODM_EDCA_VO_PARAM			0x500
+#define	ODM_EDCA_VI_PARAM			0x504
+#define	ODM_EDCA_BE_PARAM			0x508
+#define	ODM_EDCA_BK_PARAM			0x50C
+#define	ODM_TXPAUSE					0x522
+
+/* BB REG */
+#define	ODM_FPGA_PHY0_PAGE8			0x800
+#define	ODM_PSD_SETTING				0x808
+#define	ODM_AFE_SETTING				0x818
+#define	ODM_TXAGC_B_6_18				0x830
+#define	ODM_TXAGC_B_24_54			0x834
+#define	ODM_TXAGC_B_MCS32_5			0x838
+#define	ODM_TXAGC_B_MCS0_MCS3		0x83c
+#define	ODM_TXAGC_B_MCS4_MCS7		0x848
+#define	ODM_TXAGC_B_MCS8_MCS11		0x84c
+#define	ODM_ANALOG_REGISTER			0x85c
+#define	ODM_RF_INTERFACE_OUTPUT		0x860
+#define	ODM_TXAGC_B_MCS12_MCS15	0x868
+#define	ODM_TXAGC_B_11_A_2_11		0x86c
+#define	ODM_AD_DA_LSB_MASK			0x874
+#define	ODM_ENABLE_3_WIRE			0x88c
+#define	ODM_PSD_REPORT				0x8b4
+#define	ODM_R_ANT_SELECT				0x90c
+#define	ODM_CCK_ANT_SELECT			0xa07
+#define	ODM_CCK_PD_THRESH			0xa0a
+#define	ODM_CCK_RF_REG1				0xa11
+#define	ODM_CCK_MATCH_FILTER			0xa20
+#define	ODM_CCK_RAKE_MAC				0xa2e
+#define	ODM_CCK_CNT_RESET			0xa2d
+#define	ODM_CCK_TX_DIVERSITY			0xa2f
+#define	ODM_CCK_FA_CNT_MSB			0xa5b
+#define	ODM_CCK_FA_CNT_LSB			0xa5c
+#define	ODM_CCK_NEW_FUNCTION		0xa75
+#define	ODM_OFDM_PHY0_PAGE_C		0xc00
+#define	ODM_OFDM_RX_ANT				0xc04
+#define	ODM_R_A_RXIQI					0xc14
+#define	ODM_R_A_AGC_CORE1			0xc50
+#define	ODM_R_A_AGC_CORE2			0xc54
+#define	ODM_R_B_AGC_CORE1			0xc58
+#define	ODM_R_AGC_PAR					0xc70
+#define	ODM_R_HTSTF_AGC_PAR			0xc7c
+#define	ODM_TX_PWR_TRAINING_A		0xc90
+#define	ODM_TX_PWR_TRAINING_B		0xc98
+#define	ODM_OFDM_FA_CNT1				0xcf0
+#define	ODM_OFDM_PHY0_PAGE_D		0xd00
+#define	ODM_OFDM_FA_CNT2				0xda0
+#define	ODM_OFDM_FA_CNT3				0xda4
+#define	ODM_OFDM_FA_CNT4				0xda8
+#define	ODM_TXAGC_A_6_18				0xe00
+#define	ODM_TXAGC_A_24_54			0xe04
+#define	ODM_TXAGC_A_1_MCS32			0xe08
+#define	ODM_TXAGC_A_MCS0_MCS3		0xe10
+#define	ODM_TXAGC_A_MCS4_MCS7		0xe14
+#define	ODM_TXAGC_A_MCS8_MCS11		0xe18
+#define	ODM_TXAGC_A_MCS12_MCS15		0xe1c
+
+/* RF REG */
+#define	ODM_GAIN_SETTING				0x00
+#define	ODM_CHANNEL					0x18
+
+/* Ant Detect Reg */
+#define	ODM_DPDT						0x300
+
+/* PSD Init */
+#define	ODM_PSDREG					0x808
+
+/* 92D Path Div */
+#define	PATHDIV_REG					0xB30
+#define	PATHDIV_TRI					0xBA0
+
+
+/*  */
+/*  Bitmap Definition */
+/*  */
+
+#define	BIT_FA_RESET					BIT0
+
+
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/odm_types.h b/drivers/st=
aging/rtl8723au/include/odm_types.h
new file mode 100644
index 0000000..a866769
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/odm_types.h
@@ -0,0 +1,36 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __ODM_TYPES_H__
+#define __ODM_TYPES_H__
+
+/*  Define Different SW team support */
+
+enum hal_status {
+	HAL_STATUS_SUCCESS,
+	HAL_STATUS_FAILURE,
+};
+
+enum rt_spinlock_type {
+	RT_TEMP =3D1,
+};
+
+#define SET_TX_DESC_ANTSEL_A_88E(__pTxDesc, __Value)		\
+	SET_BITS_TO_LE_4BYTE(__pTxDesc+8, 24, 1, __Value)
+#define SET_TX_DESC_ANTSEL_B_88E(__pTxDesc, __Value)		\
+	SET_BITS_TO_LE_4BYTE(__pTxDesc+8, 25, 1, __Value)
+#define SET_TX_DESC_ANTSEL_C_88E(__pTxDesc, __Value)		\
+	SET_BITS_TO_LE_4BYTE(__pTxDesc+28, 29, 1, __Value)
+
+#endif /*  __ODM_TYPES_H__ */
diff --git a/drivers/staging/rtl8723au/include/osdep_intf.h b/drivers/s=
taging/rtl8723au/include/osdep_intf.h
new file mode 100644
index 0000000..b603cf5
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/osdep_intf.h
@@ -0,0 +1,46 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+
+#ifndef __OSDEP_INTF_H_
+#define __OSDEP_INTF_H_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+int rtw_hw_suspend23a(struct rtw_adapter *padapter);
+int rtw_hw_resume23a(struct rtw_adapter *padapter);
+
+u8 rtw_init_drv_sw23a(struct rtw_adapter *padapter);
+u8 rtw_free_drv_sw23a(struct rtw_adapter *padapter);
+u8 rtw_reset_drv_sw23a(struct rtw_adapter *padapter);
+
+u32 rtw_start_drv_threads23a(struct rtw_adapter *padapter);
+void rtw_stop_drv_threads23a (struct rtw_adapter *padapter);
+void rtw_cancel_all_timer23a(struct rtw_adapter *padapter);
+
+int rtw_init_netdev23a_name23a(struct net_device *pnetdev, const char =
*ifname);
+struct net_device *rtw_init_netdev23a(struct rtw_adapter *padapter);
+
+u16 rtw_recv_select_queue23a(struct sk_buff *skb);
+
+void rtw_ips_dev_unload23a(struct rtw_adapter *padapter);
+
+int rtw_ips_pwr_up23a(struct rtw_adapter *padapter);
+void rtw_ips_pwr_down23a(struct rtw_adapter *padapter);
+
+int rtw_drv_register_netdev(struct rtw_adapter *padapter);
+void rtw_ndev_destructor(struct net_device *ndev);
+
+#endif	/* _OSDEP_INTF_H_ */
diff --git a/drivers/staging/rtl8723au/include/osdep_service.h b/driver=
s/staging/rtl8723au/include/osdep_service.h
new file mode 100644
index 0000000..cb7b5cd
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/osdep_service.h
@@ -0,0 +1,340 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __OSDEP_SERVICE_H_
+#define __OSDEP_SERVICE_H_
+
+#define _FAIL		0
+#define _SUCCESS	1
+#define RTW_RX_HANDLED 2
+
+#include <linux/version.h>
+#include <linux/spinlock.h>
+#include <linux/compiler.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <linux/kref.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/circ_buf.h>
+#include <asm/uaccess.h>
+#include <asm/byteorder.h>
+#include <asm/atomic.h>
+#include <asm/io.h>
+#include <linux/semaphore.h>
+#include <linux/sem.h>
+#include <linux/sched.h>
+#include <linux/etherdevice.h>
+#include <linux/wireless.h>
+#include <net/iw_handler.h>
+#include <linux/if_arp.h>
+#include <linux/rtnetlink.h>
+#include <linux/delay.h>
+#include <linux/proc_fs.h>	/*  Necessary because we use the proc fs */
+#include <linux/interrupt.h>	/*  for struct tasklet_struct */
+#include <linux/ip.h>
+#include <linux/kthread.h>
+
+
+/*	#include <linux/ieee80211.h> */
+#include <net/ieee80211_radiotap.h>
+#include <net/cfg80211.h>
+#include <linux/usb.h>
+#include <linux/usb/ch9.h>
+
+struct rtw_adapter;
+struct c2h_evt_hdr;
+
+typedef s32 (*c2h_id_filter)(u8 id);
+
+struct rtw_queue {
+	struct	list_head	queue;
+	spinlock_t		lock;
+};
+
+static inline struct list_head *get_list_head(struct rtw_queue *queue)
+{
+	return (&queue->queue);
+}
+
+static inline int rtw_netif_queue_stopped(struct net_device *pnetdev)
+{
+	return (netif_tx_queue_stopped(netdev_get_tx_queue(pnetdev, 0)) &&
+		netif_tx_queue_stopped(netdev_get_tx_queue(pnetdev, 1)) &&
+		netif_tx_queue_stopped(netdev_get_tx_queue(pnetdev, 2)) &&
+		netif_tx_queue_stopped(netdev_get_tx_queue(pnetdev, 3)) );
+}
+
+#ifndef BIT
+#define BIT(x)	( 1 << (x))
+#endif
+static inline u32 CHKBIT(u32 x)
+{
+	WARN_ON(x >=3D 32);
+	if (x >=3D 32)
+		return 0;
+	return BIT(x);
+}
+
+#define BIT0	0x00000001
+#define BIT1	0x00000002
+#define BIT2	0x00000004
+#define BIT3	0x00000008
+#define BIT4	0x00000010
+#define BIT5	0x00000020
+#define BIT6	0x00000040
+#define BIT7	0x00000080
+#define BIT8	0x00000100
+#define BIT9	0x00000200
+#define BIT10	0x00000400
+#define BIT11	0x00000800
+#define BIT12	0x00001000
+#define BIT13	0x00002000
+#define BIT14	0x00004000
+#define BIT15	0x00008000
+#define BIT16	0x00010000
+#define BIT17	0x00020000
+#define BIT18	0x00040000
+#define BIT19	0x00080000
+#define BIT20	0x00100000
+#define BIT21	0x00200000
+#define BIT22	0x00400000
+#define BIT23	0x00800000
+#define BIT24	0x01000000
+#define BIT25	0x02000000
+#define BIT26	0x04000000
+#define BIT27	0x08000000
+#define BIT28	0x10000000
+#define BIT29	0x20000000
+#define BIT30	0x40000000
+#define BIT31	0x80000000
+#define BIT32	0x0100000000
+#define BIT33	0x0200000000
+#define BIT34	0x0400000000
+#define BIT35	0x0800000000
+#define BIT36	0x1000000000
+
+int RTW_STATUS_CODE23a(int error_code);
+
+u8*	_rtw_vmalloc(u32 sz);
+u8*	_rtw_zvmalloc(u32 sz);
+void	_rtw_vmfree(u8 *pbuf, u32 sz);
+#define rtw_vmalloc(sz)			_rtw_vmalloc((sz))
+#define rtw_zvmalloc(sz)			_rtw_zvmalloc((sz))
+#define rtw_vmfree(pbuf, sz)		_rtw_vmfree((pbuf), (sz))
+
+extern unsigned char REALTEK_96B_IE23A[];
+extern unsigned char MCS_rate_2R23A[16];
+extern unsigned char RTW_WPA_OUI23A[];
+extern unsigned char WPA_TKIP_CIPHER23A[4];
+extern unsigned char RSN_TKIP_CIPHER23A[4];
+
+extern unsigned char	MCS_rate_2R23A[16];
+extern unsigned char	MCS_rate_1R23A[16];
+
+void	_rtw_init_queue23a(struct rtw_queue *pqueue);
+u32	_rtw_queue_empty23a(struct rtw_queue *pqueue);
+
+u32	rtw_get_current_time(void);
+u32	rtw_systime_to_ms23a(u32 systime);
+u32	rtw_ms_to_systime23a(u32 ms);
+s32	rtw_get_passing_time_ms23a(u32 start);
+s32	rtw_get_time_interval_ms23a(u32 start, u32 end);
+
+#define _RND(sz, r) ((((sz)+((r)-1))/(r))*(r))
+#define RND4(x)	(((x >> 2) + (((x & 3) =3D=3D 0) ?  0: 1)) << 2)
+
+static inline u32 _RND4(u32 sz)
+{
+
+	u32	val;
+
+	val =3D ((sz >> 2) + ((sz & 3) ? 1: 0)) << 2;
+
+	return val;
+
+}
+
+static inline u32 _RND8(u32 sz)
+{
+
+	u32	val;
+
+	val =3D ((sz >> 3) + ((sz & 7) ? 1: 0)) << 3;
+
+	return val;
+
+}
+
+static inline u32 _RND128(u32 sz)
+{
+
+	u32	val;
+
+	val =3D ((sz >> 7) + ((sz & 127) ? 1: 0)) << 7;
+
+	return val;
+
+}
+
+static inline u32 _RND256(u32 sz)
+{
+
+	u32	val;
+
+	val =3D ((sz >> 8) + ((sz & 255) ? 1: 0)) << 8;
+
+	return val;
+
+}
+
+static inline u32 _RND512(u32 sz)
+{
+
+	u32	val;
+
+	val =3D ((sz >> 9) + ((sz & 511) ? 1: 0)) << 9;
+
+	return val;
+
+}
+
+static inline u32 bitshift(u32 bitmask)
+{
+	u32 i;
+
+	for (i =3D 0; i <=3D 31; i++)
+		if (((bitmask>>i) &  0x1) =3D=3D 1) break;
+
+	return i;
+}
+
+#define STRUCT_PACKED __attribute__ ((packed))
+
+/*  limitation of path length */
+#define PATH_LENGTH_MAX PATH_MAX
+
+void rtw_suspend_lock_init(void);
+void rtw_suspend_lock_uninit(void);
+void rtw_lock_suspend(void);
+void rtw_unlock_suspend(void);
+
+/* File operation APIs, just for linux now */
+int rtw_is_file_readable(char *path);
+int rtw_retrive_from_file(char *path, u8* buf, u32 sz);
+int rtw_store_to_file(char *path, u8* buf, u32 sz);
+
+#define NDEV_FMT "%s"
+#define NDEV_ARG(ndev) ndev->name
+#define ADPT_FMT "%s"
+#define ADPT_ARG(adapter) adapter->pnetdev->name
+#define FUNC_NDEV_FMT "%s(%s)"
+#define FUNC_NDEV_ARG(ndev) __func__, ndev->name
+#define FUNC_ADPT_FMT "%s(%s)"
+#define FUNC_ADPT_ARG(adapter) __func__, adapter->pnetdev->name
+
+#define rtw_signal_process(pid, sig) kill_pid(find_vpid((pid)),(sig), =
1)
+
+u64 rtw_modular6423a(u64 x, u64 y);
+u64 rtw_division6423a(u64 x, u64 y);
+
+
+/* Macros for handling unaligned memory accesses */
+
+#define RTW_GET_BE16(a) ((u16) (((a)[0] << 8) | (a)[1]))
+#define RTW_PUT_BE16(a, val)			\
+	do {					\
+		(a)[0] =3D ((u16) (val)) >> 8;	\
+		(a)[1] =3D ((u16) (val)) & 0xff;	\
+	} while (0)
+
+#define RTW_GET_LE16(a) ((u16) (((a)[1] << 8) | (a)[0]))
+#define RTW_PUT_LE16(a, val)			\
+	do {					\
+		(a)[1] =3D ((u16) (val)) >> 8;	\
+		(a)[0] =3D ((u16) (val)) & 0xff;	\
+	} while (0)
+
+#define RTW_GET_BE24(a) ((((u32) (a)[0]) << 16) | (((u32) (a)[1]) << 8=
) | \
+			 ((u32) (a)[2]))
+#define RTW_PUT_BE24(a, val)					\
+	do {							\
+		(a)[0] =3D (u8) ((((u32) (val)) >> 16) & 0xff);	\
+		(a)[1] =3D (u8) ((((u32) (val)) >> 8) & 0xff);	\
+		(a)[2] =3D (u8) (((u32) (val)) & 0xff);		\
+	} while (0)
+
+#define RTW_GET_BE32(a) ((((u32) (a)[0]) << 24) | (((u32) (a)[1]) << 1=
6) | \
+			 (((u32) (a)[2]) << 8) | ((u32) (a)[3]))
+#define RTW_PUT_BE32(a, val)					\
+	do {							\
+		(a)[0] =3D (u8) ((((u32) (val)) >> 24) & 0xff);	\
+		(a)[1] =3D (u8) ((((u32) (val)) >> 16) & 0xff);	\
+		(a)[2] =3D (u8) ((((u32) (val)) >> 8) & 0xff);	\
+		(a)[3] =3D (u8) (((u32) (val)) & 0xff);		\
+	} while (0)
+
+#define RTW_GET_LE32(a) ((((u32) (a)[3]) << 24) | (((u32) (a)[2]) << 1=
6) | \
+			 (((u32) (a)[1]) << 8) | ((u32) (a)[0]))
+#define RTW_PUT_LE32(a, val)					\
+	do {							\
+		(a)[3] =3D (u8) ((((u32) (val)) >> 24) & 0xff);	\
+		(a)[2] =3D (u8) ((((u32) (val)) >> 16) & 0xff);	\
+		(a)[1] =3D (u8) ((((u32) (val)) >> 8) & 0xff);	\
+		(a)[0] =3D (u8) (((u32) (val)) & 0xff);		\
+	} while (0)
+
+#define RTW_GET_BE64(a) ((((u64) (a)[0]) << 56) | (((u64) (a)[1]) << 4=
8) | \
+			 (((u64) (a)[2]) << 40) | (((u64) (a)[3]) << 32) | \
+			 (((u64) (a)[4]) << 24) | (((u64) (a)[5]) << 16) | \
+			 (((u64) (a)[6]) << 8) | ((u64) (a)[7]))
+#define RTW_PUT_BE64(a, val)				\
+	do {						\
+		(a)[0] =3D (u8) (((u64) (val)) >> 56);	\
+		(a)[1] =3D (u8) (((u64) (val)) >> 48);	\
+		(a)[2] =3D (u8) (((u64) (val)) >> 40);	\
+		(a)[3] =3D (u8) (((u64) (val)) >> 32);	\
+		(a)[4] =3D (u8) (((u64) (val)) >> 24);	\
+		(a)[5] =3D (u8) (((u64) (val)) >> 16);	\
+		(a)[6] =3D (u8) (((u64) (val)) >> 8);	\
+		(a)[7] =3D (u8) (((u64) (val)) & 0xff);	\
+	} while (0)
+
+#define RTW_GET_LE64(a) ((((u64) (a)[7]) << 56) | (((u64) (a)[6]) << 4=
8) | \
+			 (((u64) (a)[5]) << 40) | (((u64) (a)[4]) << 32) | \
+			 (((u64) (a)[3]) << 24) | (((u64) (a)[2]) << 16) | \
+			 (((u64) (a)[1]) << 8) | ((u64) (a)[0]))
+
+struct rtw_cbuf {
+	u32 write;
+	u32 read;
+	u32 size;
+	void *bufs[0];
+};
+
+bool rtw_cbuf_full23a(struct rtw_cbuf *cbuf);
+bool rtw_cbuf_empty23a(struct rtw_cbuf *cbuf);
+bool rtw_cbuf_push23a(struct rtw_cbuf *cbuf, void *buf);
+void *rtw_cbuf_pop23a(struct rtw_cbuf *cbuf);
+struct rtw_cbuf *rtw_cbuf_alloc23a(u32 size);
+void rtw_cbuf_free(struct rtw_cbuf *cbuf);
+int rtw_change_ifname(struct rtw_adapter *padapter, const char *ifname=
);
+s32 c2h_evt_hdl(struct rtw_adapter *adapter, struct c2h_evt_hdr *c2h_e=
vt, c2h_id_filter filter);
+void indicate_wx_scan_complete_event(struct rtw_adapter *padapter);
+u8 rtw_do_join23a(struct rtw_adapter *padapter);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/recv_osdep.h b/drivers/s=
taging/rtl8723au/include/recv_osdep.h
new file mode 100644
index 0000000..15c94b6
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/recv_osdep.h
@@ -0,0 +1,45 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RECV_OSDEP_H_
+#define __RECV_OSDEP_H_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+int _rtw_init_recv_priv23a(struct recv_priv *precvpriv, struct rtw_ada=
pter *padapter);
+void _rtw_free_recv_priv23a (struct recv_priv *precvpriv);
+
+int rtw_recv_entry23a(struct recv_frame *precv_frame);
+int rtw_recv_indicatepkt23a(struct rtw_adapter *adapter, struct recv_f=
rame *precv_frame);
+void rtw_recv_returnpacket(struct net_device *cnxt, struct sk_buff *pr=
eturnedpkt);
+
+void rtw_hostapd_mlme_rx23a(struct rtw_adapter *padapter, struct recv_=
frame *precv_frame);
+void rtw_handle_tkip_mic_err23a(struct rtw_adapter *padapter, u8 bgrou=
p);
+
+int	rtw_init_recv_priv(struct recv_priv *precvpriv, struct rtw_adapter=
 *padapter);
+void rtw_free_recv_priv (struct recv_priv *precvpriv);
+
+int rtw_os_recv_resource_init(struct recv_priv *precvpriv, struct rtw_=
adapter *padapter);
+int rtw_os_recv_resource_alloc23a(struct rtw_adapter *padapter, struct=
 recv_frame *precvframe);
+void rtw_os_recv_resource_free(struct recv_priv *precvpriv);
+
+int rtw_os_recvbuf_resource_alloc23a(struct rtw_adapter *padapter, str=
uct recv_buf *precvbuf);
+int rtw_os_recvbuf_resource_free23a(struct rtw_adapter *padapter, stru=
ct recv_buf *precvbuf);
+
+void rtw_os_read_port23a(struct rtw_adapter *padapter, struct recv_buf=
 *precvbuf);
+
+void rtw_init_recv_timer23a(struct recv_reorder_ctrl *preorder_ctrl);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtl8723a_bt-coexist.h b/=
drivers/staging/rtl8723au/include/rtl8723a_bt-coexist.h
new file mode 100644
index 0000000..5777eda
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtl8723a_bt-coexist.h
@@ -0,0 +1,1672 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2012 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTL8723A_BT_COEXIST_H__
+#define __RTL8723A_BT_COEXIST_H__
+
+#include <drv_types.h>
+#include "odm_precomp.h"
+
+
+#define __BT_C__ 1
+#define __BT_HANDLEPACKET_C__ 1
+#define __BT_HCI_C__ 1
+#define __HALBTC87231ANT_C__ 1
+#define __HALBTC87232ANT_C__ 1
+#define __HALBTC8723_C__ 1
+#define __HALBTCCSR1ANT_C__ 1
+#define __HALBTCCSR2ANT_C__ 1
+#define __HALBTCOEXIST_C__ 1
+#define __HALBT_C__ 1
+
+#ifdef __BT_C__ /*  COMMON/BT.h */
+
+/*  HEADER/PlatformDef.h */
+enum rt_media_status {
+	RT_MEDIA_DISCONNECT	=3D 0,
+	RT_MEDIA_CONNECT	=3D 1
+};
+
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver COMMON/BT.=
h =3D=3D=3D=3D=3D */
+
+#define	BT_TMP_BUF_SIZE		100
+
+void BT_SignalCompensation(struct rtw_adapter *padapter,
+			   u8 *rssi_wifi, u8 *rssi_bt);
+void BT_WifiScanNotify(struct rtw_adapter *padapter, u8 scanType);
+void BT_WifiAssociateNotify(struct rtw_adapter *padapter, u8 action);
+void BT_WifiMediaStatusNotify(struct rtw_adapter *padapter,
+			      enum rt_media_status mstatus);
+void BT_SpecialPacketNotify(struct rtw_adapter * padapter);
+void BT_HaltProcess(struct rtw_adapter * padapter);
+void BT_LpsLeave(struct rtw_adapter * padapter);
+
+
+#define	BT_HsConnectionEstablished(Adapter)		false
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver COMMON/BT.h =3D=3D=3D=3D=
=3D */
+#endif /*  __BT_C__ */
+
+#ifdef __BT_HCI_C__ /*  COMMON/bt_hci.h */
+
+/*  HEADER/SecurityType.h */
+#define TKIP_ENC_KEY_POS		32		/* KEK_LEN+KEK_LEN) */
+#define MAXRSNIELEN				256
+
+/*  COMMON/Protocol802_11.h */
+/*  */
+/*       802.11 Management frame Status Code field */
+/*  */
+struct octet_string {
+	u8		*Octet;
+	u16		Length;
+};
+
+
+/*  AES_CCMP specific */
+enum {
+	AESCCMP_BLK_SIZE		=3D   16,     /*  # octets in an AES block */
+	AESCCMP_MAX_PACKET		=3D   4*512,  /*  largest packet size */
+	AESCCMP_N_RESERVED		=3D   0,      /*  reserved nonce octet value */
+	AESCCMP_A_DATA			=3D   0x40,   /*  the Adata bit in the flags */
+	AESCCMP_M_SHIFT			=3D   3,      /*  how much to shift the 3-bit M fie=
ld */
+	AESCCMP_L_SHIFT			=3D   0,      /*  how much to shift the 3-bit L fie=
ld */
+	AESCCMP_L_SIZE			=3D   2,       /*  size of the l(m) length field (in=
 octets) */
+	AESCCMP_OFFSET_SC		=3D	22,
+	AESCCMP_OFFSET_DURATION	=3D	4,
+	AESCCMP_OFFSET_A2		=3D	10,
+	AESCCMP_OFFSET_A4		=3D	24,
+	AESCCMP_QC_TID_MASK		=3D	0x0f,
+	AESCCMP_BLK_SIZE_TOTAL	=3D   16*16,     /*  Added by Annie for CKIP A=
ES MIC BSOD, 2006-08-17. */
+											/*  16*8 < 4*60  Resove to 16*16 */
+};
+
+/*  Key Length */
+#define PMK_LEN				32
+#define PTK_LEN_TKIP			64
+#define GTK_LEN				32
+#define KEY_NONCE_LEN			32
+
+
+/*  COMMON/Dot11d.h */
+struct chnl_txpower_triple {
+	u8 FirstChnl;
+	u8 NumChnls;
+	s8 MaxTxPowerInDbm;
+};
+
+
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver COMMON/bt_=
hci.h =3D=3D=3D=3D=3D */
+/*  The following is for BT 3.0 + HS HCI COMMAND ERRORS CODES */
+
+#define Max80211PALPDUSize			1492
+#define Max80211AMPASSOCLen			672
+#define MinGUserPrio					4
+#define MaxGUserPrio					7
+#define BEUserPrio0						0
+#define BEUserPrio1						3
+#define Max80211BeaconPeriod		2000
+#define ShortRangeModePowerMax		4
+
+#define BT_Default_Chnl					10
+#define ACLDataHeaderLen				4
+
+#define BTTotalDataBlockNum			0x100
+#define BTLocalBufNum					0x200
+#define BTMaxDataBlockLen				0x800
+#define BTTOTALBANDWIDTH				0x7530
+#define BTMAXBANDGUBANDWIDTH		0x4e20
+#define TmpLocalBufSize					0x100
+#define BTSynDataPacketLength			0xff
+/*  */
+
+#define BTMaxAuthCount					5
+#define BTMaxAsocCount					5
+
+#define MAX_LOGICAL_LINK_NUM			2	/* temporarily define */
+#define MAX_BT_ASOC_ENTRY_NUM		2	/* temporarily define */
+
+#define INVALID_PL_HANDLE				0xff
+#define INVALID_ENTRY_NUM				0xff
+/*  */
+
+#define CAM_BT_START_INDEX		(HALF_CAM_ENTRY - 4)   /*  MAX_BT_ASOC_ENT=
RY_NUM : 4 !!! */
+#define BT_HWCAM_STAR			CAM_BT_START_INDEX  /*  We used  HALF_CAM_ENTR=
Y ~ HALF_CAM_ENTRY -MAX_BT_ASOC_ENTRY_NUM */
+
+enum hci_status {
+	HCI_STATUS_SUCCESS			=3D 0x00, /* Success */
+	HCI_STATUS_UNKNOW_HCI_CMD		=3D 0x01, /* Unknown HCI Command */
+	HCI_STATUS_UNKNOW_CONNECT_ID		=3D 0X02, /* Unknown Connection Identif=
ier */
+	HCI_STATUS_HW_FAIL			=3D 0X03, /* Hardware Failure */
+	HCI_STATUS_PAGE_TIMEOUT			=3D 0X04, /* Page Timeout */
+	HCI_STATUS_AUTH_FAIL			=3D 0X05, /* Authentication Failure */
+	HCI_STATUS_PIN_OR_KEY_MISSING		=3D 0X06, /* PIN or Key Missing */
+	HCI_STATUS_MEM_CAP_EXCEED		=3D 0X07, /* Memory Capacity Exceeded */
+	HCI_STATUS_CONNECT_TIMEOUT		=3D 0X08, /* Connection Timeout */
+	HCI_STATUS_CONNECT_LIMIT		=3D 0X09, /* Connection Limit Exceeded */
+	HCI_STATUS_SYN_CONNECT_LIMIT		=3D 0X0a, /* Synchronous Connection Lim=
it To A Device Exceeded */
+	HCI_STATUS_ACL_CONNECT_EXISTS		=3D 0X0b, /* ACL Connection Already Ex=
ists */
+	HCI_STATUS_CMD_DISALLOW			=3D 0X0c, /* Command Disallowed */
+	HCI_STATUS_CONNECT_RJT_LIMIT_RESOURCE	=3D 0X0d, /* Connection Rejecte=
d due to Limited Resources */
+	HCI_STATUS_CONNECT_RJT_SEC_REASON	=3D 0X0e, /* Connection Rejected Du=
e To Security Reasons */
+	HCI_STATUS_CONNECT_RJT_UNACCEPT_BD_ADDR	=3D 0X0f, /* Connection Rejec=
ted due to Unacceptable BD_ADDR */
+	HCI_STATUS_CONNECT_ACCEPT_TIMEOUT	=3D 0X10, /* Connection Accept Time=
out Exceeded */
+	HCI_STATUS_UNSUPPORT_FEATURE_PARA_VALUE	=3D 0X11, /* Unsupported Feat=
ure or Parameter Value */
+	HCI_STATUS_INVALID_HCI_CMD_PARA_VALUE	=3D 0X12, /* Invalid HCI Comman=
d Parameters */
+	HCI_STATUS_REMOTE_USER_TERMINATE_CONNECT =3D 0X13, /* Remote User Ter=
minated Connection */
+	HCI_STATUS_REMOTE_DEV_TERMINATE_LOW_RESOURCE =3D 0X14, /* Remote Devi=
ce Terminated Connection due to Low Resources */
+	HCI_STATUS_REMOTE_DEV_TERMINATE_CONNECT_POWER_OFF =3D 0X15, /* Remote=
 Device Terminated Connection due to Power Off */
+	HCI_STATUS_CONNECT_TERMINATE_LOCAL_HOST	=3D 0X16, /* Connection Termi=
nated By Local Host */
+	HCI_STATUS_REPEATE_ATTEMPT		=3D 0X17, /* Repeated Attempts */
+	HCI_STATUS_PAIR_NOT_ALLOW		=3D 0X18, /* Pairing Not Allowed */
+	HCI_STATUS_UNKNOW_LMP_PDU		=3D 0X19, /* Unknown LMP PDU */
+	HCI_STATUS_UNSUPPORT_REMOTE_LMP_FEATURE	=3D 0X1a, /* Unsupported Remo=
te Feature / Unsupported LMP Feature */
+	HCI_STATUS_SOC_OFFSET_REJECT		=3D 0X1b, /* SCO Offset Rejected */
+	HCI_STATUS_SOC_INTERVAL_REJECT		=3D 0X1c, /* SCO Interval Rejected */
+	HCI_STATUS_SOC_AIR_MODE_REJECT		=3D 0X1d,/* SCO Air Mode Rejected */
+	HCI_STATUS_INVALID_LMP_PARA		=3D 0X1e, /* Invalid LMP Parameters */
+	HCI_STATUS_UNSPECIFIC_ERROR		=3D 0X1f, /* Unspecified Error */
+	HCI_STATUS_UNSUPPORT_LMP_PARA_VALUE	=3D 0X20, /* Unsupported LMP Para=
meter Value */
+	HCI_STATUS_ROLE_CHANGE_NOT_ALLOW	=3D 0X21, /* Role Change Not Allowed=
 */
+	HCI_STATUS_LMP_RESPONSE_TIMEOUT		=3D 0X22, /* LMP Response Timeout */
+	HCI_STATUS_LMP_ERROR_TRANSACTION_COLLISION =3D 0X23, /* LMP Error Tra=
nsaction Collision */
+	HCI_STATUS_LMP_PDU_NOT_ALLOW		=3D 0X24, /* LMP PDU Not Allowed */
+	HCI_STATUS_ENCRYPTION_MODE_NOT_ALLOW	=3D 0X25, /* Encryption Mode Not=
 Acceptable */
+	HCI_STATUS_LINK_KEY_CAN_NOT_CHANGE	=3D 0X26, /* Link Key Can Not be C=
hanged */
+	HCI_STATUS_REQUEST_QOS_NOT_SUPPORT	=3D 0X27, /* Requested QoS Not Sup=
ported */
+	HCI_STATUS_INSTANT_PASSED		=3D 0X28, /* Instant Passed */
+	HCI_STATUS_PAIRING_UNIT_KEY_NOT_SUPPORT =3D 0X29, /* Pairing With Uni=
t Key Not Supported */
+	HCI_STATUS_DIFFERENT_TRANSACTION_COLLISION =3D 0X2a, /* Different Tra=
nsaction Collision */
+	HCI_STATUS_RESERVE_1			=3D 0X2b, /* Reserved */
+	HCI_STATUS_QOS_UNACCEPT_PARA		=3D 0X2c, /* QoS Unacceptable Parameter=
 */
+	HCI_STATUS_QOS_REJECT			=3D 0X2d, /* QoS Rejected */
+	HCI_STATUS_CHNL_CLASSIFICATION_NOT_SUPPORT =3D 0X2e, /* Channel Class=
ification Not Supported */
+	HCI_STATUS_INSUFFICIENT_SECURITY	=3D 0X2f, /* Insufficient Security *=
/
+	HCI_STATUS_PARA_OUT_OF_RANGE		=3D 0x30, /* Parameter Out Of Mandatory=
 Range */
+	HCI_STATUS_RESERVE_2			=3D 0X31, /* Reserved */
+	HCI_STATUS_ROLE_SWITCH_PENDING		=3D 0X32, /* Role Switch Pending */
+	HCI_STATUS_RESERVE_3			=3D 0X33, /* Reserved */
+	HCI_STATUS_RESERVE_SOLT_VIOLATION	=3D 0X34, /* Reserved Slot Violatio=
n */
+	HCI_STATUS_ROLE_SWITCH_FAIL		=3D 0X35, /* Role Switch Failed */
+	HCI_STATUS_EXTEND_INQUIRY_RSP_TOO_LARGE	=3D 0X36, /* Extended Inquiry=
 Response Too Large */
+	HCI_STATUS_SEC_SIMPLE_PAIRING_NOT_SUPPORT =3D 0X37, /* Secure Simple =
Pairing Not Supported By Host. */
+	HCI_STATUS_HOST_BUSY_PAIRING		=3D 0X38, /* Host Busy - Pairing */
+	HCI_STATUS_CONNECT_REJ_NOT_SUIT_CHNL_FOUND =3D 0X39, /* Connection Re=
jected due to No Suitable Channel Found */
+	HCI_STATUS_CONTROLLER_BUSY		=3D 0X3a  /* CONTROLLER BUSY */
+};
+
+/*  */
+/*  The following is for BT 3.0 + HS HCI COMMAND */
+/*  */
+
+/* bit 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 */
+/*	 |	OCF			             |	   OGF       | */
+/*  */
+
+/* OGF 0x01 */
+#define LINK_CONTROL_COMMANDS			0x01
+enum link_control_commands {
+	HCI_INQUIRY					=3D 0x0001,
+	HCI_INQUIRY_CANCEL				=3D 0x0002,
+	HCI_PERIODIC_INQUIRY_MODE			=3D 0x0003,
+	HCI_EXIT_PERIODIC_INQUIRY_MODE			=3D 0x0004,
+	HCI_CREATE_CONNECTION				=3D 0x0005,
+	HCI_DISCONNECT					=3D 0x0006,
+	HCI_CREATE_CONNECTION_CANCEL			=3D 0x0008,
+	HCI_ACCEPT_CONNECTIONREQUEST			=3D 0x0009,
+	HCI_REJECT_CONNECTION_REQUEST			=3D 0x000a,
+	HCI_LINK_KEY_REQUEST_REPLY			=3D 0x000b,
+	HCI_LINK_KEY_REQUEST_NEGATIVE_REPLY		=3D 0x000c,
+	HCI_PIN_CODE_REQUEST_REPLY			=3D 0x000d,
+	HCI_PIN_CODE_REQUEST_NEGATIVE_REPLY		=3D 0x000e,
+	HCI_CHANGE_CONNECTION_PACKET_TYPE		=3D 0x000f,
+	HCI_AUTHENTICATION_REQUESTED			=3D 0x0011,
+	HCI_SET_CONNECTION_ENCRYPTION			=3D 0x0013,
+	HCI_CHANGE_CONNECTION_LINK_KEY			=3D 0x0015,
+	HCI_MASTER_LINK_KEY				=3D 0x0017,
+	HCI_REMOTE_NAME_REQUEST				=3D 0x0019,
+	HCI_REMOTE_NAME_REQUEST_CANCEL			=3D 0x001a,
+	HCI_READ_REMOTE_SUPPORTED_FEATURES		=3D 0x001b,
+	HCI_READ_REMOTE_EXTENDED_FEATURES		=3D 0x001c,
+	HCI_READ_REMOTE_VERSION_INFORMATION		=3D 0x001d,
+	HCI_READ_CLOCK_OFFSET				=3D 0x001f,
+	HCI_READ_LMP_HANDLE				=3D 0x0020,
+	HCI_SETUP_SYNCHRONOUS_CONNECTION		=3D 0x0028,
+	HCI_ACCEPT_SYNCHRONOUS_CONNECTION_REQUEST	=3D 0x0029,
+	HCI_REJECT_SYNCHRONOUS_CONNECTION_REQUEST	=3D 0x002a,
+	HCI_IO_CAPABILITY_REQUEST_REPLY			=3D 0x002b,
+	HCI_USER_CONFIRMATION_REQUEST_REPLY		=3D 0x002c,
+	HCI_USER_CONFIRMATION_REQUEST_NEGATIVE_REPLY	=3D 0x002d,
+	HCI_USER_PASSKEY_REQUEST_REPLY			=3D 0x002e,
+	HCI_USER_PASSKEY_REQUESTNEGATIVE_REPLY		=3D 0x002f,
+	HCI_REMOTE_OOB_DATA_REQUEST_REPLY		=3D 0x0030,
+	HCI_REMOTE_OOB_DATA_REQUEST_NEGATIVE_REPLY	=3D 0x0033,
+	HCI_IO_CAPABILITY_REQUEST_NEGATIVE_REPLY	=3D 0x0034,
+	HCI_CREATE_PHYSICAL_LINK			=3D 0x0035,
+	HCI_ACCEPT_PHYSICAL_LINK			=3D 0x0036,
+	HCI_DISCONNECT_PHYSICAL_LINK			=3D 0x0037,
+	HCI_CREATE_LOGICAL_LINK				=3D 0x0038,
+	HCI_ACCEPT_LOGICAL_LINK				=3D 0x0039,
+	HCI_DISCONNECT_LOGICAL_LINK			=3D 0x003a,
+	HCI_LOGICAL_LINK_CANCEL				=3D 0x003b,
+	HCI_FLOW_SPEC_MODIFY				=3D 0x003c
+};
+
+/* OGF 0x02 */
+#define HOLD_MODE_COMMAND				0x02
+enum hold_mode_command {
+	HCI_HOLD_MODE					=3D 0x0001,
+	HCI_SNIFF_MODE					=3D 0x0002,
+	HCI_EXIT_SNIFF_MODE				=3D 0x0003,
+	HCI_PARK_STATE					=3D 0x0005,
+	HCI_EXIT_PARK_STATE				=3D 0x0006,
+	HCI_QOS_SETUP					=3D 0x0007,
+	HCI_ROLE_DISCOVERY				=3D 0x0009,
+	HCI_SWITCH_ROLE					=3D 0x000b,
+	HCI_READ_LINK_POLICY_SETTINGS			=3D 0x000c,
+	HCI_WRITE_LINK_POLICY_SETTINGS			=3D 0x000d,
+	HCI_READ_DEFAULT_LINK_POLICY_SETTINGS		=3D 0x000e,
+	HCI_WRITE_DEFAULT_LINK_POLICY_SETTINGS		=3D 0x000f,
+	HCI_FLOW_SPECIFICATION				=3D 0x0010,
+	HCI_SNIFF_SUBRATING				=3D 0x0011
+};
+
+/* OGF 0x03 */
+#define OGF_SET_EVENT_MASK_COMMAND			0x03
+enum set_event_mask_command {
+	HCI_SET_EVENT_MASK				=3D 0x0001,
+	HCI_RESET					=3D 0x0003,
+	HCI_SET_EVENT_FILTER				=3D 0x0005,
+	HCI_FLUSH					=3D 0x0008,
+	HCI_READ_PIN_TYPE				=3D 0x0009,
+	HCI_WRITE_PIN_TYPE				=3D 0x000a,
+	HCI_CREATE_NEW_UNIT_KEY				=3D 0x000b,
+	HCI_READ_STORED_LINK_KEY			=3D 0x000d,
+	HCI_WRITE_STORED_LINK_KEY			=3D 0x0011,
+	HCI_DELETE_STORED_LINK_KEY			=3D 0x0012,
+	HCI_WRITE_LOCAL_NAME				=3D 0x0013,
+	HCI_READ_LOCAL_NAME				=3D 0x0014,
+	HCI_READ_CONNECTION_ACCEPT_TIMEOUT		=3D 0x0015,
+	HCI_WRITE_CONNECTION_ACCEPT_TIMEOUT		=3D 0x0016,
+	HCI_READ_PAGE_TIMEOUT				=3D 0x0017,
+	HCI_WRITE_PAGE_TIMEOUT				=3D 0x0018,
+	HCI_READ_SCAN_ENABLE				=3D 0x0019,
+	HCI_WRITE_SCAN_ENABLE				=3D 0x001a,
+	HCI_READ_PAGE_SCAN_ACTIVITY			=3D 0x001b,
+	HCI_WRITE_PAGE_SCAN_ACTIVITY			=3D 0x001c,
+	HCI_READ_INQUIRY_SCAN_ACTIVITY			=3D 0x001d,
+	HCI_WRITE_INQUIRY_SCAN_ACTIVITY			=3D 0x001e,
+	HCI_READ_AUTHENTICATION_ENABLE			=3D 0x001f,
+	HCI_WRITE_AUTHENTICATION_ENABLE			=3D 0x0020,
+	HCI_READ_CLASS_OF_DEVICE			=3D 0x0023,
+	HCI_WRITE_CLASS_OF_DEVICE			=3D 0x0024,
+	HCI_READ_VOICE_SETTING				=3D 0x0025,
+	HCI_WRITE_VOICE_SETTING				=3D 0x0026,
+	HCI_READ_AUTOMATIC_FLUSH_TIMEOUT		=3D 0x0027,
+	HCI_WRITE_AUTOMATIC_FLUSH_TIMEOUT		=3D 0x0028,
+	HCI_READ_NUM_BROADCAST_RETRANSMISSIONS		=3D 0x0029,
+	HCI_WRITE_NUM_BROADCAST_RETRANSMISSIONS		=3D 0x002a,
+	HCI_READ_HOLD_MODE_ACTIVITY			=3D 0x002b,
+	HCI_WRITE_HOLD_MODE_ACTIVITY			=3D 0x002c,
+	HCI_READ_SYNCHRONOUS_FLOW_CONTROL_ENABLE	=3D 0x002e,
+	HCI_WRITE_SYNCHRONOUS_FLOW_CONTROL_ENABLE	=3D 0x002f,
+	HCI_SET_CONTROLLER_TO_HOST_FLOW_CONTROL		=3D 0x0031,
+	HCI_HOST_BUFFER_SIZE				=3D 0x0033,
+	HCI_HOST_NUMBER_OF_COMPLETED_PACKETS		=3D 0x0035,
+	HCI_READ_LINK_SUPERVISION_TIMEOUT		=3D 0x0036,
+	HCI_WRITE_LINK_SUPERVISION_TIMEOUT		=3D 0x0037,
+	HCI_READ_NUMBER_OF_SUPPORTED_IAC		=3D 0x0038,
+	HCI_READ_CURRENT_IAC_LAP			=3D 0x0039,
+	HCI_WRITE_CURRENT_IAC_LAP			=3D 0x003a,
+	HCI_READ_PAGE_SCAN_MODE				=3D 0x003d,
+	HCI_WRITE_PAGE_SCAN_MODE			=3D 0x003e,
+	HCI_SET_AFH_HOST_CHANNEL_CLASSIFICATION		=3D 0x003f,
+	HCI_READ_INQUIRY_SCAN_TYPE			=3D 0x0042,
+	HCI_WRITE_INQUIRY_SCAN_TYPE			=3D 0x0043,
+	HCI_READ_INQUIRY_MODE				=3D 0x0044,
+	HCI_WRITE_INQUIRY_MODE				=3D 0x0045,
+	HCI_READ_PAGE_SCAN_TYPE				=3D 0x0046,
+	HCI_WRITE_PAGE_SCAN_TYPE			=3D 0x0047,
+	HCI_READ_AFH_CHANNEL_ASSESSMENT_MODE		=3D 0x0048,
+	HCI_WRITE_AFH_CHANNEL_ASSESSMENT_MODE		=3D 0x0049,
+	HCI_READ_EXTENDED_INQUIRY_RESPONSE		=3D 0x0051,
+	HCI_WRITE_EXTENDED_INQUIRY_RESPONSE		=3D 0x0052,
+	HCI_REFRESH_ENCRYPTION_KEY			=3D 0x0053,
+	HCI_READ_SIMPLE_PAIRING_MODE			=3D 0x0055,
+	HCI_WRITE_SIMPLE_PAIRING_MODE			=3D 0x0056,
+	HCI_READ_LOCAL_OOB_DATA				=3D 0x0057,
+	HCI_READ_INQUIRY_RESPONSE_TRANSMIT_POWER_LEVEL	=3D 0x0058,
+	HCI_WRITE_INQUIRY_TRANSMIT_POWER_LEVEL		=3D 0x0059,
+	HCI_READ_DEFAULT_ERRONEOUS_DATA_REPORTING	=3D 0x005a,
+	HCI_WRITE_DEFAULT_ERRONEOUS_DATA_REPORTING	=3D 0x005b,
+	HCI_ENHANCED_FLUSH				=3D 0x005f,
+	HCI_SEND_KEYPRESS_NOTIFICATION			=3D 0x0060,
+	HCI_READ_LOGICAL_LINK_ACCEPT_TIMEOUT		=3D 0x0061,
+	HCI_WRITE_LOGICAL_LINK_ACCEPT_TIMEOUT		=3D 0x0062,
+	HCI_SET_EVENT_MASK_PAGE_2			=3D 0x0063,
+	HCI_READ_LOCATION_DATA				=3D 0x0064,
+	HCI_WRITE_LOCATION_DATA				=3D 0x0065,
+	HCI_READ_FLOW_CONTROL_MODE			=3D 0x0066,
+	HCI_WRITE_FLOW_CONTROL_MODE			=3D 0x0067,
+	HCI_READ_ENHANCE_TRANSMIT_POWER_LEVEL		=3D 0x0068,
+	HCI_READ_BEST_EFFORT_FLUSH_TIMEOUT		=3D 0x0069,
+	HCI_WRITE_BEST_EFFORT_FLUSH_TIMEOUT		=3D 0x006a,
+	HCI_SHORT_RANGE_MODE				=3D 0x006b
+};
+
+/* OGF 0x04 */
+#define OGF_INFORMATIONAL_PARAMETERS			0x04
+enum informational_params {
+	HCI_READ_LOCAL_VERSION_INFORMATION		=3D 0x0001,
+	HCI_READ_LOCAL_SUPPORTED_COMMANDS		=3D 0x0002,
+	HCI_READ_LOCAL_SUPPORTED_FEATURES		=3D 0x0003,
+	HCI_READ_LOCAL_EXTENDED_FEATURES		=3D 0x0004,
+	HCI_READ_BUFFER_SIZE				=3D 0x0005,
+	HCI_READ_BD_ADDR				=3D 0x0009,
+	HCI_READ_DATA_BLOCK_SIZE			=3D 0x000a
+};
+
+/* OGF 0x05 */
+#define OGF_STATUS_PARAMETERS				0x05
+enum status_params {
+	HCI_READ_FAILED_CONTACT_COUNTER			=3D 0x0001,
+	HCI_RESET_FAILED_CONTACT_COUNTER		=3D 0x0002,
+	HCI_READ_LINK_QUALITY				=3D 0x0003,
+	HCI_READ_RSSI					=3D 0x0005,
+	HCI_READ_AFH_CHANNEL_MAP			=3D 0x0006,
+	HCI_READ_CLOCK					=3D 0x0007,
+	HCI_READ_ENCRYPTION_KEY_SIZE			=3D 0x0008,
+	HCI_READ_LOCAL_AMP_INFO				=3D 0x0009,
+	HCI_READ_LOCAL_AMP_ASSOC			=3D 0x000a,
+	HCI_WRITE_REMOTE_AMP_ASSOC			=3D 0x000b
+};
+
+/* OGF 0x06 */
+#define OGF_TESTING_COMMANDS				0x06
+enum testing_commands {
+	HCI_READ_LOOPBACK_MODE				=3D 0x0001,
+	HCI_WRITE_LOOPBACK_MODE				=3D 0x0002,
+	HCI_ENABLE_DEVICE_UNDER_TEST_MODE		=3D 0x0003,
+	HCI_WRITE_SIMPLE_PAIRING_DEBUG_MODE		=3D 0x0004,
+	HCI_ENABLE_AMP_RECEIVER_REPORTS			=3D 0x0007,
+	HCI_AMP_TEST_END				=3D 0x0008,
+	HCI_AMP_TEST_COMMAND				=3D 0x0009
+};
+
+/* OGF 0x3f */
+#define OGF_EXTENSION					0X3f
+enum hci_extension_commands {
+	HCI_SET_ACL_LINK_DATA_FLOW_MODE			=3D 0x0010,
+	HCI_SET_ACL_LINK_STATUS				=3D 0x0020,
+	HCI_SET_SCO_LINK_STATUS				=3D 0x0030,
+	HCI_SET_RSSI_VALUE				=3D 0x0040,
+	HCI_SET_CURRENT_BLUETOOTH_STATUS		=3D 0x0041,
+
+	/* The following is for RTK8723 */
+	HCI_EXTENSION_VERSION_NOTIFY			=3D 0x0100,
+	HCI_LINK_STATUS_NOTIFY				=3D 0x0101,
+	HCI_BT_OPERATION_NOTIFY				=3D 0x0102,
+	HCI_ENABLE_WIFI_SCAN_NOTIFY			=3D 0x0103,
+
+
+	/* The following is for IVT */
+	HCI_WIFI_CURRENT_CHANNEL			=3D 0x0300,
+	HCI_WIFI_CURRENT_BANDWIDTH			=3D 0x0301,
+	HCI_WIFI_CONNECTION_STATUS			=3D 0x0302,
+};
+
+enum bt_spec {
+	BT_SPEC_1_0_b					=3D 0x00,
+	BT_SPEC_1_1					=3D 0x01,
+	BT_SPEC_1_2					=3D 0x02,
+	BT_SPEC_2_0_EDR					=3D 0x03,
+	BT_SPEC_2_1_EDR					=3D 0x04,
+	BT_SPEC_3_0_HS					=3D 0x05,
+	BT_SPEC_4_0					=3D 0x06
+};
+
+/*  The following is for BT 3.0 + HS EVENTS */
+enum hci_event {
+	HCI_EVENT_INQUIRY_COMPLETE			=3D 0x01,
+	HCI_EVENT_INQUIRY_RESULT			=3D 0x02,
+	HCI_EVENT_CONNECTION_COMPLETE			=3D 0x03,
+	HCI_EVENT_CONNECTION_REQUEST			=3D 0x04,
+	HCI_EVENT_DISCONNECTION_COMPLETE		=3D 0x05,
+	HCI_EVENT_AUTHENTICATION_COMPLETE		=3D 0x06,
+	HCI_EVENT_REMOTE_NAME_REQUEST_COMPLETE		=3D 0x07,
+	HCI_EVENT_ENCRYPTION_CHANGE			=3D 0x08,
+	HCI_EVENT_CHANGE_LINK_KEY_COMPLETE		=3D 0x09,
+	HCI_EVENT_MASTER_LINK_KEY_COMPLETE		=3D 0x0a,
+	HCI_EVENT_READ_REMOTE_SUPPORT_FEATURES_COMPLETE	=3D 0x0b,
+	HCI_EVENT_READ_REMOTE_VER_INFO_COMPLETE		=3D 0x0c,
+	HCI_EVENT_QOS_SETUP_COMPLETE			=3D 0x0d,
+	HCI_EVENT_COMMAND_COMPLETE			=3D 0x0e,
+	HCI_EVENT_COMMAND_STATUS			=3D 0x0f,
+	HCI_EVENT_HARDWARE_ERROR			=3D 0x10,
+	HCI_EVENT_FLUSH_OCCRUED				=3D 0x11,
+	HCI_EVENT_ROLE_CHANGE				=3D 0x12,
+	HCI_EVENT_NUMBER_OF_COMPLETE_PACKETS		=3D 0x13,
+	HCI_EVENT_MODE_CHANGE				=3D 0x14,
+	HCI_EVENT_RETURN_LINK_KEYS			=3D 0x15,
+	HCI_EVENT_PIN_CODE_REQUEST			=3D 0x16,
+	HCI_EVENT_LINK_KEY_REQUEST			=3D 0x17,
+	HCI_EVENT_LINK_KEY_NOTIFICATION			=3D 0x18,
+	HCI_EVENT_LOOPBACK_COMMAND			=3D 0x19,
+	HCI_EVENT_DATA_BUFFER_OVERFLOW			=3D 0x1a,
+	HCI_EVENT_MAX_SLOTS_CHANGE			=3D 0x1b,
+	HCI_EVENT_READ_CLOCK_OFFSET_COMPLETE		=3D 0x1c,
+	HCI_EVENT_CONNECT_PACKET_TYPE_CHANGE		=3D 0x1d,
+	HCI_EVENT_QOS_VIOLATION				=3D 0x1e,
+	HCI_EVENT_PAGE_SCAN_REPETITION_MODE_CHANGE	=3D 0x20,
+	HCI_EVENT_FLOW_SEPC_COMPLETE			=3D 0x21,
+	HCI_EVENT_INQUIRY_RESULT_WITH_RSSI		=3D 0x22,
+	HCI_EVENT_READ_REMOTE_EXT_FEATURES_COMPLETE	=3D 0x23,
+	HCI_EVENT_SYNC_CONNECT_COMPLETE			=3D 0x2c,
+	HCI_EVENT_SYNC_CONNECT_CHANGE			=3D 0x2d,
+	HCI_EVENT_SNIFFER_SUBRATING			=3D 0x2e,
+	HCI_EVENT_EXTENTED_INQUIRY_RESULT		=3D 0x2f,
+	HCI_EVENT_ENCRYPTION_KEY_REFLASH_COMPLETE	=3D 0x30,
+	HCI_EVENT_IO_CAPIBILITY_COMPLETE		=3D 0x31,
+	HCI_EVENT_IO_CAPIBILITY_RESPONSE		=3D 0x32,
+	HCI_EVENT_USER_CONFIRMTION_REQUEST		=3D 0x33,
+	HCI_EVENT_USER_PASSKEY_REQUEST			=3D 0x34,
+	HCI_EVENT_REMOTE_OOB_DATA_REQUEST		=3D 0x35,
+	HCI_EVENT_SIMPLE_PAIRING_COMPLETE		=3D 0x36,
+	HCI_EVENT_LINK_SUPERVISION_TIMEOUT_CHANGE	=3D 0x38,
+	HCI_EVENT_ENHANCED_FLUSH_COMPLETE		=3D 0x39,
+	HCI_EVENT_USER_PASSKEY_NOTIFICATION		=3D 0x3b,
+	HCI_EVENT_KEYPRESS_NOTIFICATION			=3D 0x3c,
+	HCI_EVENT_REMOTE_HOST_SUPPORT_FEATURES_NOTIFICATION	=3D 0x3d,
+	HCI_EVENT_PHY_LINK_COMPLETE			=3D 0x40,
+	HCI_EVENT_CHANNEL_SELECT			=3D 0x41,
+	HCI_EVENT_DISCONNECT_PHY_LINK_COMPLETE		=3D 0x42,
+	HCI_EVENT_PHY_LINK_LOSS_EARLY_WARNING		=3D 0x43,
+	HCI_EVENT_PHY_LINK_RECOVER			=3D 0x44,
+	HCI_EVENT_LOGICAL_LINK_COMPLETE			=3D 0x45,
+	HCI_EVENT_DISCONNECT_LOGICAL_LINK_COMPLETE	=3D 0x46,
+	HCI_EVENT_FLOW_SPEC_MODIFY_COMPLETE		=3D 0x47,
+	HCI_EVENT_NUM_OF_COMPLETE_DATA_BLOCKS		=3D 0x48,
+	HCI_EVENT_AMP_START_TEST			=3D 0x49,
+	HCI_EVENT_AMP_TEST_END				=3D 0x4a,
+	HCI_EVENT_AMP_RECEIVER_REPORT			=3D 0x4b,
+	HCI_EVENT_SHORT_RANGE_MODE_CHANGE_COMPLETE	=3D 0x4c,
+	HCI_EVENT_AMP_STATUS_CHANGE			=3D 0x4d,
+	HCI_EVENT_EXTENSION_RTK				=3D 0xfe,
+	HCI_EVENT_EXTENSION_MOTO			=3D 0xff,
+};
+
+enum hci_extension_event_moto {
+	HCI_EVENT_GET_BT_RSSI				=3D 0x01,
+};
+
+enum hci_extension_event {
+	HCI_EVENT_EXT_WIFI_SCAN_NOTIFY			=3D 0x01,
+};
+
+enum hci_event_mask_page_2 {
+	EMP2_HCI_EVENT_PHY_LINK_COMPLETE		=3D 0x0000000000000001,
+	EMP2_HCI_EVENT_CHANNEL_SELECT			=3D 0x0000000000000002,
+	EMP2_HCI_EVENT_DISCONNECT_PHY_LINK_COMPLETE	=3D 0x0000000000000004,
+	EMP2_HCI_EVENT_PHY_LINK_LOSS_EARLY_WARNING	=3D 0x0000000000000008,
+	EMP2_HCI_EVENT_PHY_LINK_RECOVER			=3D 0x0000000000000010,
+	EMP2_HCI_EVENT_LOGICAL_LINK_COMPLETE		=3D 0x0000000000000020,
+	EMP2_HCI_EVENT_DISCONNECT_LOGICAL_LINK_COMPLETE	=3D 0x000000000000004=
0,
+	EMP2_HCI_EVENT_FLOW_SPEC_MODIFY_COMPLETE	=3D 0x0000000000000080,
+	EMP2_HCI_EVENT_NUM_OF_COMPLETE_DATA_BLOCKS	=3D 0x0000000000000100,
+	EMP2_HCI_EVENT_AMP_START_TEST			=3D 0x0000000000000200,
+	EMP2_HCI_EVENT_AMP_TEST_END			=3D 0x0000000000000400,
+	EMP2_HCI_EVENT_AMP_RECEIVER_REPORT		=3D 0x0000000000000800,
+	EMP2_HCI_EVENT_SHORT_RANGE_MODE_CHANGE_COMPLETE	=3D 0x000000000000100=
0,
+	EMP2_HCI_EVENT_AMP_STATUS_CHANGE		=3D 0x0000000000002000,
+};
+
+enum hci_state_machine {
+	HCI_STATE_STARTING			=3D 0x01,
+	HCI_STATE_CONNECTING			=3D 0x02,
+	HCI_STATE_AUTHENTICATING		=3D 0x04,
+	HCI_STATE_CONNECTED			=3D 0x08,
+	HCI_STATE_DISCONNECTING			=3D 0x10,
+	HCI_STATE_DISCONNECTED			=3D 0x20
+};
+
+enum amp_assoc_structure_type {
+	AMP_MAC_ADDR				=3D 0x01,
+	AMP_PREFERRED_CHANNEL_LIST		=3D 0x02,
+	AMP_CONNECTED_CHANNEL			=3D 0x03,
+	AMP_80211_PAL_CAP_LIST			=3D 0x04,
+	AMP_80211_PAL_VISION			=3D 0x05,
+	AMP_RESERVED_FOR_TESTING		=3D 0x33
+};
+
+enum amp_btap_type {
+	AMP_BTAP_NONE,
+	AMP_BTAP_CREATOR,
+	AMP_BTAP_JOINER
+};
+
+enum hci_state_with_cmd {
+	STATE_CMD_CREATE_PHY_LINK,
+	STATE_CMD_ACCEPT_PHY_LINK,
+	STATE_CMD_DISCONNECT_PHY_LINK,
+	STATE_CMD_CONNECT_ACCEPT_TIMEOUT,
+	STATE_CMD_MAC_START_COMPLETE,
+	STATE_CMD_MAC_START_FAILED,
+	STATE_CMD_MAC_CONNECT_COMPLETE,
+	STATE_CMD_MAC_CONNECT_FAILED,
+	STATE_CMD_MAC_DISCONNECT_INDICATE,
+	STATE_CMD_MAC_CONNECT_CANCEL_INDICATE,
+	STATE_CMD_4WAY_FAILED,
+	STATE_CMD_4WAY_SUCCESSED,
+	STATE_CMD_ENTER_STATE,
+	STATE_CMD_NO_SUCH_CMD,
+};
+
+enum hci_service_type {
+	SERVICE_NO_TRAFFIC,
+	SERVICE_BEST_EFFORT,
+	SERVICE_GUARANTEE
+};
+
+enum hci_traffic_mode {
+	TRAFFIC_MODE_BEST_EFFORT			=3D 0x00,
+	TRAFFIC_MODE_GUARANTEED_LATENCY			=3D 0x01,
+	TRAFFIC_MODE_GUARANTEED_BANDWIDTH		=3D 0x02,
+	TRAFFIC_MODE_GUARANTEED_LATENCY_AND_BANDWIDTH	=3D 0x03
+};
+
+#define HCIOPCODE(_OCF, _OGF)		(_OGF<<10|_OCF)
+#define HCIOPCODELOW(_OCF, _OGF)	(u8)(HCIOPCODE(_OCF, _OGF)&0x00ff)
+#define HCIOPCODEHIGHT(_OCF, _OGF)	(u8)(HCIOPCODE(_OCF, _OGF)>>8)
+
+#define TWOBYTE_HIGHTBYTE(_DATA)	(u8)(_DATA>>8)
+#define TWOBYTE_LOWBYTE(_DATA)		(u8)(_DATA)
+
+enum amp_status {
+	AMP_STATUS_AVA_PHY_PWR_DWN		=3D 0x0,
+	AMP_STATUS_BT_USE_ONLY			=3D 0x1,
+	AMP_STATUS_NO_CAPACITY_FOR_BT		=3D 0x2,
+	AMP_STATUS_LOW_CAPACITY_FOR_BT		=3D 0x3,
+	AMP_STATUS_MEDIUM_CAPACITY_FOR_BT	=3D 0x4,
+	AMP_STATUS_HIGH_CAPACITY_FOR_BT		=3D 0x5,
+	AMP_STATUS_FULL_CAPACITY_FOR_BT		=3D 0x6
+};
+
+enum bt_wpa_msg_type {
+	Type_BT_4way1st	=3D 0,
+	Type_BT_4way2nd	=3D 1,
+	Type_BT_4way3rd	=3D 2,
+	Type_BT_4way4th	=3D 3,
+	Type_BT_unknow	=3D 4
+};
+
+enum bt_connect_type {
+	BT_CONNECT_AUTH_REQ			=3D 0x00,
+	BT_CONNECT_AUTH_RSP			=3D 0x01,
+	BT_CONNECT_ASOC_REQ			=3D 0x02,
+	BT_CONNECT_ASOC_RSP			=3D 0x03,
+	BT_DISCONNECT				=3D 0x04
+};
+
+enum bt_ll_service_type {
+	BT_LL_BE =3D 0x01,
+	BT_LL_GU =3D 0x02
+};
+
+enum bt_ll_flowspec {
+	BT_TX_BE_FS,			/* TX best effort flowspec */
+	BT_RX_BE_FS,			/* RX best effort flowspec */
+	BT_TX_GU_FS,			/* TX guaranteed latency flowspec */
+	BT_RX_GU_FS,			/* RX guaranteed latency flowspec */
+	BT_TX_BE_AGG_FS,		/* TX aggregated best effort flowspec */
+	BT_RX_BE_AGG_FS,		/* RX aggregated best effort flowspec */
+	BT_TX_GU_BW_FS,			/* TX guaranteed bandwidth flowspec */
+	BT_RX_GU_BW_FS,			/* RX guaranteed bandwidth flowspec */
+	BT_TX_GU_LARGE_FS,		/* TX guaranteed latency flowspec, for testing on=
ly */
+	BT_RX_GU_LARGE_FS,		/* RX guaranteed latency flowspec, for testing on=
ly */
+};
+
+enum bt_traffic_mode {
+	BT_MOTOR_EXT_BE		=3D 0x00, /* Best Effort. Default. for HCRP, PAN, SD=
P, RFCOMM-based profiles like FTP, OPP, SPP, DUN, etc. */
+	BT_MOTOR_EXT_GUL	=3D 0x01, /* Guaranteed Latency. This type of traffi=
c is used e.g. for HID and AVRCP. */
+	BT_MOTOR_EXT_GUB	=3D 0X02, /* Guaranteed Bandwidth. */
+	BT_MOTOR_EXT_GULB	=3D 0X03  /* Guaranteed Latency and Bandwidth. for =
A2DP and VDP. */
+};
+
+enum bt_traffic_mode_profile {
+	BT_PROFILE_NONE,
+	BT_PROFILE_A2DP,
+	BT_PROFILE_PAN,
+	BT_PROFILE_HID,
+	BT_PROFILE_SCO
+};
+
+enum bt_link_role {
+	BT_LINK_MASTER	=3D 0,
+	BT_LINK_SLAVE	=3D 1
+};
+
+enum bt_state_wpa_auth {
+	STATE_WPA_AUTH_UNINITIALIZED,
+	STATE_WPA_AUTH_WAIT_PACKET_1, /*  Join */
+	STATE_WPA_AUTH_WAIT_PACKET_2, /*  Creat */
+	STATE_WPA_AUTH_WAIT_PACKET_3,
+	STATE_WPA_AUTH_WAIT_PACKET_4,
+	STATE_WPA_AUTH_SUCCESSED
+};
+
+#define BT_WPA_AUTH_TIMEOUT_PERIOD		1000
+#define BTMaxWPAAuthReTransmitCoun		5
+
+#define MAX_AMP_ASSOC_FRAG_LEN			248
+#define TOTAL_ALLOCIATE_ASSOC_LEN			1000
+
+struct hci_flow_spec {
+	u8				Identifier;
+	u8				ServiceType;
+	u16				MaximumSDUSize;
+	u32				SDUInterArrivalTime;
+	u32				AccessLatency;
+	u32				FlushTimeout;
+};
+
+struct hci_log_link_cmd_data {
+	u8				BtPhyLinkhandle;
+	u16				BtLogLinkhandle;
+	u8				BtTxFlowSpecID;
+	struct hci_flow_spec		Tx_Flow_Spec;
+	struct hci_flow_spec		Rx_Flow_Spec;
+	u32				TxPacketCount;
+	u32				BestEffortFlushTimeout;
+
+	u8				bLLCompleteEventIsSet;
+
+	u8				bLLCancelCMDIsSetandComplete;
+};
+
+struct hci_phy_link_cmd_data {
+	/* Physical_Link_Handle */
+	u8				BtPhyLinkhandle;
+
+	u16				LinkSuperversionTimeout;
+
+	/* u16				SuperTimeOutCnt; */
+
+	/* Dedicated_AMP_Key_Length */
+	u8				BtAMPKeyLen;
+	/* Dedicated_AMP_Key_Type */
+	u8				BtAMPKeyType;
+	/* Dedicated_AMP_Key */
+	u8				BtAMPKey[PMK_LEN];
+};
+
+struct amp_assoc_structure {
+	/* TYPE ID */
+	u8				TypeID;
+	/* Length */
+	u16				Length;
+	/* Value */
+	u8				Data[1];
+};
+
+struct amp_pref_chnl_regulatory {
+	u8				reXId;
+	u8				regulatoryClass;
+	u8				coverageClass;
+};
+
+struct amp_assoc_cmd_data {
+	/* Physical_Link_Handle */
+	u8				BtPhyLinkhandle;
+	/* Length_So_Far */
+	u16				LenSoFar;
+
+	u16				MaxRemoteASSOCLen;
+	/* AMP_ASSOC_Remaining_Length */
+	u16				AMPAssocRemLen;
+	/* AMP_ASSOC_fragment */
+	void				*AMPAssocfragment;
+};
+
+struct hci_link_info {
+	u16				ConnectHandle;
+	u8				IncomingTrafficMode;
+	u8				OutgoingTrafficMode;
+	u8				BTProfile;
+	u8				BTCoreSpec;
+	s8				BT_RSSI;
+	u8				TrafficProfile;
+	u8				linkRole;
+};
+
+struct hci_ext_config {
+	struct hci_link_info		linkInfo[MAX_BT_ASOC_ENTRY_NUM];
+	u8				btOperationCode;
+	u16				CurrentConnectHandle;
+	u8				CurrentIncomingTrafficMode;
+	u8				CurrentOutgoingTrafficMode;
+	s8				MIN_BT_RSSI;
+	u8				NumberOfHandle;
+	u8				NumberOfSCO;
+	u8				CurrentBTStatus;
+	u16				HCIExtensionVer;
+
+	/* Bt coexist related */
+	u8				btProfileCase;
+	u8				btProfileAction;
+	u8				bManualControl;
+	u8				bBTBusy;
+	u8				bBTA2DPBusy;
+	u8				bEnableWifiScanNotify;
+
+	u8				bHoldForBtOperation;
+	u32				bHoldPeriodCnt;
+};
+
+struct hci_acl_packet_data {
+	u16				ACLDataPacketLen;
+	u8				SyncDataPacketLen;
+	u16				TotalNumACLDataPackets;
+	u16				TotalSyncNumDataPackets;
+};
+
+struct hci_phy_link_bss_info {
+	u16				bdCap;	/*  capability information */
+};
+
+struct packet_irp_hcicmd_data {
+	u16		OCF:10;
+	u16		OGF:6;
+	u8		Length;
+	u8		Data[20];
+};
+
+struct bt_asoc_entry {
+	u8						bUsed;
+	u8						mAssoc;
+	u8						b4waySuccess;
+	u8						Bssid[6];
+	struct hci_phy_link_cmd_data		PhyLinkCmdData;
+
+	struct hci_log_link_cmd_data		LogLinkCmdData[MAX_LOGICAL_LINK_NUM];
+
+	struct hci_acl_packet_data			ACLPacketsData;
+
+	struct amp_assoc_cmd_data		AmpAsocCmdData;
+	struct octet_string				BTSsid;
+	u8						BTSsidBuf[33];
+
+	enum hci_status						PhyLinkDisconnectReason;
+
+	u8						bSendSupervisionPacket;
+	/* u8						CurrentSuervisionPacketSendNum; */
+	/* u8						LastSuervisionPacketSendNum; */
+	u32						NoRxPktCnt;
+	/* Is Creator or Joiner */
+	enum amp_btap_type				AMPRole;
+
+	/* BT current state */
+	u8						BtCurrentState;
+	/* BT next state */
+	u8						BtNextState;
+
+	u8						bNeedPhysLinkCompleteEvent;
+
+	enum hci_status					PhysLinkCompleteStatus;
+
+	u8						BTRemoteMACAddr[6];
+
+	u32						BTCapability;
+
+	u8						SyncDataPacketLen;
+
+	u16						TotalSyncNumDataPackets;
+	u16						TotalNumACLDataPackets;
+
+	u8						ShortRangeMode;
+
+	u8						PTK[PTK_LEN_TKIP];
+	u8						GTK[GTK_LEN];
+	u8						ANonce[KEY_NONCE_LEN];
+	u8						SNonce[KEY_NONCE_LEN];
+	u64						KeyReplayCounter;
+	u8						WPAAuthReplayCount;
+	u8						AESKeyBuf[AESCCMP_BLK_SIZE_TOTAL];
+	u8						PMK[PMK_LEN];
+	enum bt_state_wpa_auth			BTWPAAuthState;
+	s32						UndecoratedSmoothedPWDB;
+
+	/*  Add for HW security !! */
+	u8						HwCAMIndex;  /*  Cam index */
+	u8						bPeerQosSta;
+
+	u32						rxSuvpPktCnt;
+};
+
+struct bt_traffic_statistics {
+	u8				bTxBusyTraffic;
+	u8				bRxBusyTraffic;
+	u8				bIdle;
+	u32				TxPktCntInPeriod;
+	u32				RxPktCntInPeriod;
+	u64				TxPktLenInPeriod;
+	u64				RxPktLenInPeriod;
+};
+
+struct bt_mgnt {
+	u8				bBTConnectInProgress;
+	u8				bLogLinkInProgress;
+	u8				bPhyLinkInProgress;
+	u8				bPhyLinkInProgressStartLL;
+	u8				BtCurrentPhyLinkhandle;
+	u16				BtCurrentLogLinkhandle;
+	u8				CurrentConnectEntryNum;
+	u8				DisconnectEntryNum;
+	u8				CurrentBTConnectionCnt;
+	enum bt_connect_type		BTCurrentConnectType;
+	enum bt_connect_type		BTReceiveConnectPkt;
+	u8				BTAuthCount;
+	u8				BTAsocCount;
+	u8				bStartSendSupervisionPkt;
+	u8				BtOperationOn;
+	u8				BTNeedAMPStatusChg;
+	u8				JoinerNeedSendAuth;
+	struct hci_phy_link_bss_info	bssDesc;
+	struct hci_ext_config		ExtConfig;
+	u8				bNeedNotifyAMPNoCap;
+	u8				bCreateSpportQos;
+	u8				bSupportProfile;
+	u8				BTChannel;
+	u8				CheckChnlIsSuit;
+	u8				bBtScan;
+	u8				btLogoTest;
+};
+
+struct bt_hci_dgb_info {
+	u32				hciCmdCnt;
+	u32				hciCmdCntUnknown;
+	u32				hciCmdCntCreatePhyLink;
+	u32				hciCmdCntAcceptPhyLink;
+	u32				hciCmdCntDisconnectPhyLink;
+	u32				hciCmdPhyLinkStatus;
+	u32				hciCmdCntCreateLogLink;
+	u32				hciCmdCntAcceptLogLink;
+	u32				hciCmdCntDisconnectLogLink;
+	u32				hciCmdCntReadLocalAmpAssoc;
+	u32				hciCmdCntWriteRemoteAmpAssoc;
+	u32				hciCmdCntSetAclLinkStatus;
+	u32				hciCmdCntSetScoLinkStatus;
+	u32				hciCmdCntExtensionVersionNotify;
+	u32				hciCmdCntLinkStatusNotify;
+};
+
+struct bt_irp_dgb_info {
+	u32				irpMJCreate;
+	/*  Io Control */
+	u32				irpIoControl;
+	u32				irpIoCtrlHciCmd;
+	u32				irpIoCtrlHciEvent;
+	u32				irpIoCtrlHciTxData;
+	u32				irpIoCtrlHciRxData;
+	u32				irpIoCtrlUnknown;
+
+	u32				irpIoCtrlHciTxData1s;
+};
+
+struct bt_packet_dgb_info {
+	u32				btPktTxProbReq;
+	u32				btPktRxProbReq;
+	u32				btPktRxProbReqFail;
+	u32				btPktTxProbRsp;
+	u32				btPktRxProbRsp;
+	u32				btPktTxAuth;
+	u32				btPktRxAuth;
+	u32				btPktRxAuthButDrop;
+	u32				btPktTxAssocReq;
+	u32				btPktRxAssocReq;
+	u32				btPktRxAssocReqButDrop;
+	u32				btPktTxAssocRsp;
+	u32				btPktRxAssocRsp;
+	u32				btPktTxDisassoc;
+	u32				btPktRxDisassoc;
+	u32				btPktRxDeauth;
+	u32				btPktTx4way1st;
+	u32				btPktRx4way1st;
+	u32				btPktTx4way2nd;
+	u32				btPktRx4way2nd;
+	u32				btPktTx4way3rd;
+	u32				btPktRx4way3rd;
+	u32				btPktTx4way4th;
+	u32				btPktRx4way4th;
+	u32				btPktTxLinkSuperReq;
+	u32				btPktRxLinkSuperReq;
+	u32				btPktTxLinkSuperRsp;
+	u32				btPktRxLinkSuperRsp;
+	u32				btPktTxData;
+	u32				btPktRxData;
+};
+
+struct bt_dgb {
+	u8				dbgCtrl;
+	u32				dbgProfile;
+	struct bt_hci_dgb_info		dbgHciInfo;
+	struct bt_irp_dgb_info		dbgIrpInfo;
+	struct bt_packet_dgb_info	dbgBtPkt;
+};
+
+struct bt_hci_info {
+	/* 802.11 Pal version specifier */
+	u8				BTPalVersion;
+	u16				BTPalCompanyID;
+	u16				BTPalsubversion;
+
+	/* Connected channel list */
+	u16				BTConnectChnlListLen;
+	u8				BTConnectChnllist[64];
+
+	/* Fail contact counter */
+	u16				FailContactCount;
+
+	/* Event mask */
+	u64				BTEventMask;
+	u64				BTEventMaskPage2;
+
+	/* timeout var */
+	u16				ConnAcceptTimeout;
+	u16				LogicalAcceptTimeout;
+	u16				PageTimeout;
+
+	u8				LocationDomainAware;
+	u16				LocationDomain;
+	u8				LocationDomainOptions;
+	u8				LocationOptions;
+
+	u8				FlowControlMode;
+
+	/* Preferred channel list */
+	u16				BtPreChnlListLen;
+	u8				BTPreChnllist[64];
+
+	u16				enFlush_LLH;	/* enhanced flush handle */
+	u16				FLTO_LLH;		/* enhanced flush handle */
+
+	/*  */
+	/* Test command only. */
+	u8				bInTestMode;
+	u8				bTestIsEnd;
+	u8				bTestNeedReport;
+	u8				TestScenario;
+	u8				TestReportInterval;
+	u8				TestCtrType;
+	u32				TestEventType;
+	u16				TestNumOfFrame;
+	u16				TestNumOfErrFrame;
+	u16				TestNumOfBits;
+	u16				TestNumOfErrBits;
+	/*  */
+};
+
+struct bt_traffic {
+	/*  Add for check replay data */
+	u8					LastRxUniFragNum;
+	u16					LastRxUniSeqNum;
+
+	/* s32					EntryMaxUndecoratedSmoothedPWDB; */
+	/* s32					EntryMinUndecoratedSmoothedPWDB; */
+
+	struct bt_traffic_statistics		Bt30TrafficStatistics;
+};
+
+#define RT_WORK_ITEM struct work_struct
+
+struct bt_security {
+	/*  WPA auth state
+	 *  May need to remove to BTSecInfo ...=20
+	 * enum bt_state_wpa_auth BTWPAAuthState;
+	 */
+	struct octet_string	RSNIE;
+	u8			RSNIEBuf[MAXRSNIELEN];
+	u8			bRegNoEncrypt;
+	u8			bUsedHwEncrypt;
+};
+
+struct bt_30info {
+	struct rtw_adapter	*padapter;
+	struct bt_asoc_entry		BtAsocEntry[MAX_BT_ASOC_ENTRY_NUM];
+	struct bt_mgnt				BtMgnt;
+	struct bt_dgb				BtDbg;
+	struct bt_hci_info			BtHciInfo;
+	struct bt_traffic			BtTraffic;
+	struct bt_security			BtSec;
+	RT_WORK_ITEM		HCICmdWorkItem;
+	struct timer_list BTHCICmdTimer;
+	RT_WORK_ITEM		BTPsDisableWorkItem;
+	RT_WORK_ITEM		BTConnectWorkItem;
+	struct timer_list BTHCIDiscardAclDataTimer;
+	struct timer_list BTHCIJoinTimeoutTimer;
+	struct timer_list BTTestSendPacketTimer;
+	struct timer_list BTDisconnectPhyLinkTimer;
+	struct timer_list BTBeaconTimer;
+	u8				BTBeaconTmrOn;
+
+	struct timer_list BTPsDisableTimer;
+
+	void *				pBtChnlList;
+};
+
+struct packet_irp_acl_data {
+	u16		Handle:12;
+	u16		PB_Flag:2;
+	u16		BC_Flag:2;
+	u16		Length;
+	u8		Data[1];
+};
+
+struct packet_irp_hcievent_data {
+	u8		EventCode;
+	u8		Length;
+	u8		Data[5];
+};
+
+struct common_triple {
+	u8 byte_1st;
+	u8 byte_2nd;
+	u8 byte_3rd;
+};
+
+#define COUNTRY_STR_LEN		3	/*  country string len =3D 3 */
+
+#define LOCAL_PMK	0
+
+enum hci_wifi_connect_status {
+	HCI_WIFI_NOT_CONNECTED			=3D 0x0,
+	HCI_WIFI_CONNECTED			=3D 0x1,
+	HCI_WIFI_CONNECT_IN_PROGRESS		=3D 0x2,
+};
+
+enum hci_ext_bp_operation {
+	HCI_BT_OP_NONE				=3D 0x0,
+	HCI_BT_OP_INQUIRY_START			=3D 0x1,
+	HCI_BT_OP_INQUIRY_FINISH		=3D 0x2,
+	HCI_BT_OP_PAGING_START			=3D 0x3,
+	HCI_BT_OP_PAGING_SUCCESS		=3D 0x4,
+	HCI_BT_OP_PAGING_UNSUCCESS		=3D 0x5,
+	HCI_BT_OP_PAIRING_START			=3D 0x6,
+	HCI_BT_OP_PAIRING_FINISH		=3D 0x7,
+	HCI_BT_OP_BT_DEV_ENABLE			=3D 0x8,
+	HCI_BT_OP_BT_DEV_DISABLE		=3D 0x9,
+	HCI_BT_OP_MAX
+};
+
+/*	Function proto type */
+struct btdata_entry {
+	struct list_head	List;
+	void			*pDataBlock;
+};
+
+#define BTHCI_SM_WITH_INFO(_Adapter, _StateToEnter, _StateCmd, _EntryN=
um)	\
+{										\
+	RTPRINT(FIOCTL, IOCTL_STATE, ("[BT state change] caused by ""%s"", li=
ne =3D%d\n", __FUNCTION__, __LINE__));							\
+	BTHCI_StateMachine(_Adapter, _StateToEnter, _StateCmd, _EntryNum);\
+}
+
+void BTHCI_EventParse(struct rtw_adapter * padapter, void *pEvntData, =
u32 dataLen);
+#define BT_EventParse BTHCI_EventParse
+u8 BTHCI_HsConnectionEstablished(struct rtw_adapter * padapter);
+void BTHCI_UpdateBTProfileRTKToMoto(struct rtw_adapter * padapter);
+void BTHCI_WifiScanNotify(struct rtw_adapter * padapter, u8 scanType);
+void BTHCI_StateMachine(struct rtw_adapter * padapter, u8 StateToEnter=
, enum hci_state_with_cmd StateCmd, u8 EntryNum);
+void BTHCI_DisconnectPeer(struct rtw_adapter * padapter, u8 EntryNum);
+void BTHCI_EventNumOfCompletedDataBlocks(struct rtw_adapter * padapter=
);
+void BTHCI_EventAMPStatusChange(struct rtw_adapter * padapter, u8 AMP_=
Status);
+void BTHCI_DisconnectAll(struct rtw_adapter * padapter);
+enum hci_status BTHCI_HandleHCICMD(struct rtw_adapter * padapter, stru=
ct packet_irp_hcicmd_data *pHciCmd);
+
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver COMMON/bt_hci.h =3D=3D=
=3D=3D=3D */
+#endif /*  __BT_HCI_C__ */
+
+#ifdef __HALBTC87231ANT_C__ /*  HAL/BTCoexist/HalBtc87231Ant.h */
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver HAL/BTCoex=
ist/HalBtc87231Ant.h =3D=3D=3D=3D=3D */
+#define GET_BT_INFO(padapter)	(&GET_HAL_DATA(padapter)->BtInfo)
+
+#define	BTC_FOR_SCAN_START				1
+#define	BTC_FOR_SCAN_FINISH				0
+
+#define	BT_TXRX_CNT_THRES_1				1200
+#define	BT_TXRX_CNT_THRES_2				1400
+#define	BT_TXRX_CNT_THRES_3				3000
+#define	BT_TXRX_CNT_LEVEL_0				0	/*  < 1200 */
+#define	BT_TXRX_CNT_LEVEL_1				1	/*  >=3D 1200 && < 1400 */
+#define	BT_TXRX_CNT_LEVEL_2				2	/*  >=3D 1400 */
+#define	BT_TXRX_CNT_LEVEL_3				3	/*  >=3D 3000 */
+
+enum bt_state_1ant {
+	BT_INFO_STATE_DISABLED			=3D 0,
+	BT_INFO_STATE_NO_CONNECTION		=3D 1,
+	BT_INFO_STATE_CONNECT_IDLE		=3D 2,
+	BT_INFO_STATE_INQ_OR_PAG		=3D 3,
+	BT_INFO_STATE_ACL_ONLY_BUSY		=3D 4,
+	BT_INFO_STATE_SCO_ONLY_BUSY		=3D 5,
+	BT_INFO_STATE_ACL_SCO_BUSY		=3D 6,
+	BT_INFO_STATE_ACL_INQ_OR_PAG		=3D 7,
+	BT_INFO_STATE_MAX			=3D 8
+};
+
+struct btdm_8723a_1ant {
+	u8		prePsTdma;
+	u8		curPsTdma;
+	u8		psTdmaDuAdjType;
+	u8		bPrePsTdmaOn;
+	u8		bCurPsTdmaOn;
+	u8		preWifiPara;
+	u8		curWifiPara;
+	u8		preCoexWifiCon;
+	u8		curCoexWifiCon;
+	u8		wifiRssiThresh;
+
+	u32		psTdmaMonitorCnt;
+	u32		psTdmaGlobalCnt;
+
+	/* DurationAdjust For SCO */
+	u32		psTdmaMonitorCntForSCO;
+	u8		psTdmaDuAdjTypeForSCO;
+	u8		RSSI_WiFi_Last;
+	u8		RSSI_BT_Last;
+
+	u8		bWiFiHalt;
+	u8		bRAChanged;
+};
+
+void BTDM_1AntSignalCompensation(struct rtw_adapter * padapter, u8 *rs=
si_wifi, u8 *rssi_bt);
+void BTDM_1AntForDhcp(struct rtw_adapter * padapter);
+void BTDM_1AntBtCoexist8723A(struct rtw_adapter * padapter);
+
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver HAL/BTCoexist/HalBtc87=
231Ant.h =3D=3D=3D=3D=3D */
+#endif /*  __HALBTC87231ANT_C__ */
+
+#ifdef __HALBTC87232ANT_C__ /*  HAL/BTCoexist/HalBtc87232Ant.h */
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver HAL/BTCoex=
ist/HalBtc87232Ant.h =3D=3D=3D=3D=3D */
+enum bt_2ant_bt_status {
+	BT_2ANT_BT_STATUS_IDLE			=3D 0x0,
+	BT_2ANT_BT_STATUS_CONNECTED_IDLE	=3D 0x1,
+	BT_2ANT_BT_STATUS_NON_IDLE		=3D 0x2,
+	BT_2ANT_BT_STATUS_MAX
+};
+
+enum bt_2ant_coex_algo {
+	BT_2ANT_COEX_ALGO_UNDEFINED			=3D 0x0,
+	BT_2ANT_COEX_ALGO_SCO				=3D 0x1,
+	BT_2ANT_COEX_ALGO_HID				=3D 0x2,
+	BT_2ANT_COEX_ALGO_A2DP				=3D 0x3,
+	BT_2ANT_COEX_ALGO_PANEDR			=3D 0x4,
+	BT_2ANT_COEX_ALGO_PANHS				=3D 0x5,
+	BT_2ANT_COEX_ALGO_PANEDR_A2DP		=3D 0x6,
+	BT_2ANT_COEX_ALGO_PANEDR_HID		=3D 0x7,
+	BT_2ANT_COEX_ALGO_HID_A2DP_PANEDR	=3D 0x8,
+	BT_2ANT_COEX_ALGO_HID_A2DP			=3D 0x9,
+	BT_2ANT_COEX_ALGO_HID_A2DP_PANHS	=3D 0xA,
+	BT_2ANT_COEX_ALGO_MAX				=3D 0xB,
+};
+
+struct btdm_8723a_2ant {
+	u8	bPreDecBtPwr;
+	u8	bCurDecBtPwr;
+
+	u8	preWlanActHi;
+	u8	curWlanActHi;
+	u8	preWlanActLo;
+	u8	curWlanActLo;
+
+	u8	preFwDacSwingLvl;
+	u8	curFwDacSwingLvl;
+
+	u8	bPreRfRxLpfShrink;
+	u8	bCurRfRxLpfShrink;
+
+	u8	bPreLowPenaltyRa;
+	u8	bCurLowPenaltyRa;
+
+	u8	preBtRetryIndex;
+	u8	curBtRetryIndex;
+
+	u8	bPreDacSwingOn;
+	u32	preDacSwingLvl;
+	u8	bCurDacSwingOn;
+	u32	curDacSwingLvl;
+
+	u8	bPreAdcBackOff;
+	u8	bCurAdcBackOff;
+
+	u8	bPreAgcTableEn;
+	u8	bCurAgcTableEn;
+
+	u32	preVal0x6c0;
+	u32	curVal0x6c0;
+	u32	preVal0x6c8;
+	u32	curVal0x6c8;
+	u8	preVal0x6cc;
+	u8	curVal0x6cc;
+
+	u8	bCurIgnoreWlanAct;
+	u8	bPreIgnoreWlanAct;
+
+	u8	prePsTdma;
+	u8	curPsTdma;
+	u8	psTdmaDuAdjType;
+	u8	bPrePsTdmaOn;
+	u8	bCurPsTdmaOn;
+
+	u8	preAlgorithm;
+	u8	curAlgorithm;
+	u8	bResetTdmaAdjust;
+
+	u8	btStatus;
+};
+
+void BTDM_2AntBtCoexist8723A(struct rtw_adapter * padapter);
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver HAL/BTCoexist/HalBtc87=
232Ant.h =3D=3D=3D=3D=3D */
+#endif /*  __HALBTC87232ANT_C__ */
+
+#ifdef __HALBTC8723_C__ /*  HAL/BTCoexist/HalBtc8723.h */
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver HAL/BTCoex=
ist/HalBtc8723.h =3D=3D=3D=3D=3D */
+
+#define	BT_Q_PKT_OFF		0
+#define	BT_Q_PKT_ON		1
+
+#define	BT_TX_PWR_OFF		0
+#define	BT_TX_PWR_ON		1
+
+/*  TDMA mode definition */
+#define	TDMA_2ANT			0
+#define	TDMA_1ANT			1
+#define	TDMA_NAV_OFF		0
+#define	TDMA_NAV_ON		1
+#define	TDMA_DAC_SWING_OFF	0
+#define	TDMA_DAC_SWING_ON	1
+
+#define	BT_RSSI_LEVEL_H	0
+#define	BT_RSSI_LEVEL_M	1
+#define	BT_RSSI_LEVEL_L	2
+
+/*  PTA mode related definition */
+#define	BT_PTA_MODE_OFF		0
+#define	BT_PTA_MODE_ON		1
+
+/*  Penalty Tx Rate Adaptive */
+#define	BT_TX_RATE_ADAPTIVE_NORMAL			0
+#define	BT_TX_RATE_ADAPTIVE_LOW_PENALTY	1
+
+/*  RF Corner */
+#define	BT_RF_RX_LPF_CORNER_RESUME			0
+#define	BT_RF_RX_LPF_CORNER_SHRINK			1
+
+#define BT_INFO_ACL			BIT(0)
+#define BT_INFO_SCO			BIT(1)
+#define BT_INFO_INQ_PAG		BIT(2)
+#define BT_INFO_ACL_BUSY	BIT(3)
+#define BT_INFO_SCO_BUSY	BIT(4)
+#define BT_INFO_HID			BIT(5)
+#define BT_INFO_A2DP		BIT(6)
+#define BT_INFO_FTP			BIT(7)
+
+
+
+struct bt_coexist_8723a {
+	u32					highPriorityTx;
+	u32					highPriorityRx;
+	u32					lowPriorityTx;
+	u32					lowPriorityRx;
+	u8					btRssi;
+	u8					TotalAntNum;
+	u8					bC2hBtInfoSupport;
+	u8					c2hBtInfo;
+	u8					c2hBtInfoOriginal;
+	u8					prec2hBtInfo; /*  for 1Ant */
+	u8					bC2hBtInquiryPage;
+	u64					btInqPageStartTime; /*  for 2Ant */
+	u8					c2hBtProfile; /*  for 1Ant */
+	u8					btRetryCnt;
+	u8					btInfoExt;
+	u8					bC2hBtInfoReqSent;
+	u8					bForceFwBtInfo;
+	u8					bForceA2dpSink;
+	struct btdm_8723a_2ant			btdm2Ant;
+	struct btdm_8723a_1ant			btdm1Ant;
+};
+
+void BTDM_SetFwChnlInfo(struct rtw_adapter * padapter, enum rt_media_s=
tatus mstatus);
+u8 BTDM_IsWifiConnectionExist(struct rtw_adapter * padapter);
+void BTDM_SetFw3a(struct rtw_adapter * padapter, u8 byte1, u8 byte2, u=
8 byte3, u8 byte4, u8 byte5);
+void BTDM_QueryBtInformation(struct rtw_adapter * padapter);
+void BTDM_SetSwRfRxLpfCorner(struct rtw_adapter * padapter, u8 type);
+void BTDM_SetSwPenaltyTxRateAdaptive(struct rtw_adapter * padapter, u8=
 raType);
+void BTDM_SetFwDecBtPwr(struct rtw_adapter * padapter, u8 bDecBtPwr);
+u8 BTDM_BtProfileSupport(struct rtw_adapter * padapter);
+void BTDM_LpsLeave(struct rtw_adapter * padapter);
+u8 BTDM_1Ant8723A(struct rtw_adapter * padapter);
+#define BT_1Ant BTDM_1Ant8723A
+
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver HAL/BTCoexist/HalBtc87=
23.h =3D=3D=3D=3D=3D */
+#endif /*  __HALBTC8723_C__ */
+
+#ifdef __HALBTCCSR1ANT_C__ /*  HAL/BTCoexist/HalBtcCsr1Ant.h */
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver HAL/BTCoex=
ist/HalBtcCsr1Ant.h =3D=3D=3D=3D=3D */
+
+enum BT_A2DP_INDEX{
+	BT_A2DP_INDEX0		=3D 0,			/*  32, 12; the most critical for BT */
+	BT_A2DP_INDEX1,					/*  12, 24 */
+	BT_A2DP_INDEX2,					/*  0, 0 */
+	BT_A2DP_INDEX_MAX
+};
+
+#define BT_A2DP_STATE_NOT_ENTERED		0
+#define BT_A2DP_STATE_DETECTING		1
+#define BT_A2DP_STATE_DETECTED			2
+
+#define BTDM_ANT_BT_IDLE				0
+#define BTDM_ANT_WIFI					1
+#define BTDM_ANT_BT						2
+
+
+void BTDM_SingleAnt(struct rtw_adapter * padapter, u8 bSingleAntOn, u8=
 bInterruptOn, u8 bMultiNAVOn);
+void BTDM_CheckBTIdleChange1Ant(struct rtw_adapter * padapter);
+
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver HAL/BTCoexist/HalBtcCs=
r1Ant.h =3D=3D=3D=3D=3D */
+#endif /*  __HALBTCCSR1ANT_C__ */
+
+#ifdef __HALBTCCSR2ANT_C__ /*  HAL/BTCoexist/HalBtcCsr2Ant.h */
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver HAL/BTCoex=
ist/HalBtcCsr2Ant.h =3D=3D=3D=3D=3D */
+
+/*  */
+/*  For old core stack before v251 */
+/*  */
+#define BT_RSSI_STATE_NORMAL_POWER	BIT0
+#define BT_RSSI_STATE_AMDPU_OFF		BIT1
+#define BT_RSSI_STATE_SPECIAL_LOW	BIT2
+#define BT_RSSI_STATE_BG_EDCA_LOW	BIT3
+#define BT_RSSI_STATE_TXPOWER_LOW	BIT4
+
+#define	BT_DACSWING_OFF				0
+#define	BT_DACSWING_M4				1
+#define	BT_DACSWING_M7				2
+#define	BT_DACSWING_M10				3
+
+void BTDM_DiminishWiFi(struct rtw_adapter * Adapter, u8 bDACOn, u8 bIn=
terruptOn, u8 DACSwingLevel, u8 bNAVOn);
+
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver HAL/BTCoexist/HalBtcCs=
r2Ant.h =3D=3D=3D=3D=3D */
+#endif /*  __HALBTCCSR2ANT_C__ */
+
+#ifdef __HALBTCOEXIST_C__ /*  HAL/BTCoexist/HalBtCoexist.h */
+
+/*  HEADER/TypeDef.h */
+#define MAX_FW_SUPPORT_MACID_NUM			64
+
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver HAL/BTCoex=
ist/HalBtCoexist.h =3D=3D=3D=3D=3D */
+
+#define	FW_VER_BT_REG			62
+#define	FW_VER_BT_REG1		74
+#define	REG_BT_ACTIVE			0x444
+#define	REG_BT_STATE			0x448
+#define	REG_BT_POLLING1		0x44c
+#define	REG_BT_POLLING			0x700
+
+#define	REG_BT_ACTIVE_OLD		0x488
+#define	REG_BT_STATE_OLD		0x48c
+#define	REG_BT_POLLING_OLD	0x490
+
+/*  The reg define is for 8723 */
+#define	REG_HIGH_PRIORITY_TXRX			0x770
+#define	REG_LOW_PRIORITY_TXRX			0x774
+
+#define BT_FW_COEX_THRESH_TOL			6
+#define BT_FW_COEX_THRESH_20				20
+#define BT_FW_COEX_THRESH_23				23
+#define BT_FW_COEX_THRESH_25				25
+#define BT_FW_COEX_THRESH_30				30
+#define BT_FW_COEX_THRESH_35				35
+#define BT_FW_COEX_THRESH_40				40
+#define BT_FW_COEX_THRESH_45				45
+#define BT_FW_COEX_THRESH_47				47
+#define BT_FW_COEX_THRESH_50				50
+#define BT_FW_COEX_THRESH_55				55
+#define BT_FW_COEX_THRESH_65				65
+
+#define BT_COEX_STATE_BT30					BIT(0)
+#define BT_COEX_STATE_WIFI_HT20			BIT(1)
+#define BT_COEX_STATE_WIFI_HT40			BIT(2)
+#define BT_COEX_STATE_WIFI_LEGACY			BIT(3)
+
+#define BT_COEX_STATE_WIFI_RSSI_LOW		BIT(4)
+#define BT_COEX_STATE_WIFI_RSSI_MEDIUM	BIT(5)
+#define BT_COEX_STATE_WIFI_RSSI_HIGH		BIT(6)
+#define BT_COEX_STATE_DEC_BT_POWER		BIT(7)
+
+#define BT_COEX_STATE_WIFI_IDLE			BIT(8)
+#define BT_COEX_STATE_WIFI_UPLINK			BIT(9)
+#define BT_COEX_STATE_WIFI_DOWNLINK		BIT(10)
+
+#define BT_COEX_STATE_BT_INQ_PAGE	BIT(11)
+#define BT_COEX_STATE_BT_IDLE				BIT(12)
+#define BT_COEX_STATE_BT_UPLINK			BIT(13)
+#define BT_COEX_STATE_BT_DOWNLINK		BIT(14)
+/*  */
+/*  Todo: Remove these definitions */
+#define BT_COEX_STATE_BT_PAN_IDLE			BIT(15)
+#define BT_COEX_STATE_BT_PAN_UPLINK		BIT(16)
+#define BT_COEX_STATE_BT_PAN_DOWNLINK	BIT(17)
+#define BT_COEX_STATE_BT_A2DP_IDLE		BIT(18)
+/*  */
+#define BT_COEX_STATE_BT_RSSI_LOW			BIT(19)
+
+#define BT_COEX_STATE_PROFILE_HID			BIT(20)
+#define BT_COEX_STATE_PROFILE_A2DP		BIT(21)
+#define BT_COEX_STATE_PROFILE_PAN			BIT(22)
+#define BT_COEX_STATE_PROFILE_SCO			BIT(23)
+
+#define BT_COEX_STATE_WIFI_RSSI_1_LOW		BIT(24)
+#define BT_COEX_STATE_WIFI_RSSI_1_MEDIUM	BIT(25)
+#define BT_COEX_STATE_WIFI_RSSI_1_HIGH		BIT(26)
+
+#define BT_COEX_STATE_WIFI_RSSI_BEACON_LOW		BIT(27)
+#define BT_COEX_STATE_WIFI_RSSI_BEACON_MEDIUM		BIT(28)
+#define BT_COEX_STATE_WIFI_RSSI_BEACON_HIGH		BIT(29)
+
+
+#define BT_COEX_STATE_BTINFO_COMMON				BIT30
+#define BT_COEX_STATE_BTINFO_B_HID_SCOESCO		BIT31
+#define BT_COEX_STATE_BTINFO_B_FTP_A2DP			BIT32
+
+#define BT_COEX_STATE_BT_CNT_LEVEL_0				BIT33
+#define BT_COEX_STATE_BT_CNT_LEVEL_1				BIT34
+#define BT_COEX_STATE_BT_CNT_LEVEL_2				BIT35
+#define BT_COEX_STATE_BT_CNT_LEVEL_3				BIT36
+
+#define BT_RSSI_STATE_HIGH					0
+#define BT_RSSI_STATE_MEDIUM				1
+#define BT_RSSI_STATE_LOW					2
+#define BT_RSSI_STATE_STAY_HIGH			3
+#define BT_RSSI_STATE_STAY_MEDIUM			4
+#define BT_RSSI_STATE_STAY_LOW			5
+
+#define	BT_AGCTABLE_OFF				0
+#define	BT_AGCTABLE_ON				1
+
+#define	BT_BB_BACKOFF_OFF			0
+#define	BT_BB_BACKOFF_ON			1
+
+#define	BT_FW_NAV_OFF				0
+#define	BT_FW_NAV_ON				1
+
+#define	BT_COEX_MECH_NONE			0
+#define	BT_COEX_MECH_SCO			1
+#define	BT_COEX_MECH_HID			2
+#define	BT_COEX_MECH_A2DP			3
+#define	BT_COEX_MECH_PAN			4
+#define	BT_COEX_MECH_HID_A2DP			5
+#define	BT_COEX_MECH_HID_PAN			6
+#define	BT_COEX_MECH_PAN_A2DP			7
+#define	BT_COEX_MECH_HID_SCO_ESCO		8
+#define	BT_COEX_MECH_FTP_A2DP			9
+#define	BT_COEX_MECH_COMMON			10
+#define	BT_COEX_MECH_MAX			11
+/*	BT Dbg Ctrl */
+#define	BT_DBG_PROFILE_NONE			0
+#define	BT_DBG_PROFILE_SCO			1
+#define	BT_DBG_PROFILE_HID			2
+#define	BT_DBG_PROFILE_A2DP			3
+#define	BT_DBG_PROFILE_PAN			4
+#define	BT_DBG_PROFILE_HID_A2DP			5
+#define	BT_DBG_PROFILE_HID_PAN			6
+#define	BT_DBG_PROFILE_PAN_A2DP			7
+#define	BT_DBG_PROFILE_MAX			9
+
+struct bt_coexist_str {
+	u8			BluetoothCoexist;
+	u8			BT_Ant_Num;
+	u8			BT_CoexistType;
+	u8			BT_Ant_isolation;	/* 0:good, 1:bad */
+	u8			bt_radiosharedtype;
+	u32			Ratio_Tx;
+	u32			Ratio_PRI;
+	u8			bInitlized;
+	u32			BtRfRegOrigin1E;
+	u32			BtRfRegOrigin1F;
+	u8			bBTBusyTraffic;
+	u8			bBTTrafficModeSet;
+	u8			bBTNonTrafficModeSet;
+	struct bt_traffic_statistics		BT21TrafficStatistics;
+	u64			CurrentState;
+	u64			PreviousState;
+	u8			preRssiState;
+	u8			preRssiState1;
+	u8			preRssiStateBeacon;
+	u8			bFWCoexistAllOff;
+	u8			bSWCoexistAllOff;
+	u8			bHWCoexistAllOff;
+	u8			bBalanceOn;
+	u8			bSingleAntOn;
+	u8			bInterruptOn;
+	u8			bMultiNAVOn;
+	u8			PreWLANActH;
+	u8			PreWLANActL;
+	u8			WLANActH;
+	u8			WLANActL;
+	u8			A2DPState;
+	u8			AntennaState;
+	u32			lastBtEdca;
+	u16			last_aggr_num;
+	u8			bEDCAInitialized;
+	u8			exec_cnt;
+	u8			b8723aAgcTableOn;
+	u8			b92DAgcTableOn;
+	struct bt_coexist_8723a	halCoex8723;
+	u8			btActiveZeroCnt;
+	u8			bCurBtDisabled;
+	u8			bPreBtDisabled;
+	u8			bNeedToRoamForBtDisableEnable;
+	u8			fw3aVal[5];
+};
+
+void BTDM_CheckAntSelMode(struct rtw_adapter * padapter);
+void BTDM_FwC2hBtRssi(struct rtw_adapter * padapter, u8 *tmpBuf);
+#define BT_FwC2hBtRssi BTDM_FwC2hBtRssi
+void BTDM_FwC2hBtInfo(struct rtw_adapter * padapter, u8 *tmpBuf, u8 le=
ngth);
+#define BT_FwC2hBtInfo BTDM_FwC2hBtInfo
+void BTDM_DisplayBtCoexInfo(struct rtw_adapter * padapter);
+#define BT_DisplayBtCoexInfo BTDM_DisplayBtCoexInfo
+void BTDM_RejectAPAggregatedPacket(struct rtw_adapter * padapter, u8 b=
Reject);
+u8 BTDM_IsHT40(struct rtw_adapter * padapter);
+u8 BTDM_Legacy(struct rtw_adapter * padapter);
+void BTDM_CheckWiFiState(struct rtw_adapter * padapter);
+s32 BTDM_GetRxSS(struct rtw_adapter * padapter);
+u8 BTDM_CheckCoexBcnRssiState(struct rtw_adapter * padapter, u8 levelN=
um, u8 RssiThresh, u8 RssiThresh1);
+u8 BTDM_CheckCoexRSSIState1(struct rtw_adapter * padapter, u8 levelNum=
, u8 RssiThresh, u8 RssiThresh1);
+u8 BTDM_CheckCoexRSSIState(struct rtw_adapter * padapter, u8 levelNum,=
 u8 RssiThresh, u8 RssiThresh1);
+u8 BTDM_DisableEDCATurbo(struct rtw_adapter * padapter);
+#define BT_DisableEDCATurbo BTDM_DisableEDCATurbo
+void BTDM_Balance(struct rtw_adapter * padapter, u8 bBalanceOn, u8 ms0=
, u8 ms1);
+void BTDM_AGCTable(struct rtw_adapter * padapter, u8 type);
+void BTDM_BBBackOffLevel(struct rtw_adapter * padapter, u8 type);
+void BTDM_FWCoexAllOff(struct rtw_adapter * padapter);
+void BTDM_SWCoexAllOff(struct rtw_adapter * padapter);
+void BTDM_HWCoexAllOff(struct rtw_adapter * padapter);
+void BTDM_CoexAllOff(struct rtw_adapter * padapter);
+void BTDM_TurnOffBtCoexistBeforeEnterIPS(struct rtw_adapter * padapter=
);
+void BTDM_SignalCompensation(struct rtw_adapter * padapter, u8 *rssi_w=
ifi, u8 *rssi_bt);
+void BTDM_Coexist(struct rtw_adapter * padapter);
+#define BT_CoexistMechanism BTDM_Coexist
+void BTDM_UpdateCoexState(struct rtw_adapter * padapter);
+u8 BTDM_IsSameCoexistState(struct rtw_adapter * padapter);
+void BTDM_PWDBMonitor(struct rtw_adapter * padapter);
+u8 BTDM_IsBTBusy(struct rtw_adapter * padapter);
+#define BT_IsBtBusy BTDM_IsBTBusy
+u8 BTDM_IsWifiBusy(struct rtw_adapter * padapter);
+u8 BTDM_IsCoexistStateChanged(struct rtw_adapter * padapter);
+u8 BTDM_IsWifiUplink(struct rtw_adapter * padapter);
+u8 BTDM_IsWifiDownlink(struct rtw_adapter * padapter);
+u8 BTDM_IsBTHSMode(struct rtw_adapter * padapter);
+u8 BTDM_IsBTUplink(struct rtw_adapter * padapter);
+u8 BTDM_IsBTDownlink(struct rtw_adapter * padapter);
+void BTDM_AdjustForBtOperation(struct rtw_adapter * padapter);
+void BTDM_ForHalt(struct rtw_adapter * padapter);
+void BTDM_WifiScanNotify(struct rtw_adapter * padapter, u8 scanType);
+void BTDM_WifiAssociateNotify(struct rtw_adapter * padapter, u8 action=
);
+void BTDM_MediaStatusNotify(struct rtw_adapter * padapter, enum rt_med=
ia_status mstatus);
+void BTDM_ForDhcp(struct rtw_adapter * padapter);
+void BTDM_ResetActionProfileState(struct rtw_adapter * padapter);
+void BTDM_SetBtCoexCurrAntNum(struct rtw_adapter * padapter, u8 antNum=
);
+#define BT_SetBtCoexCurrAntNum BTDM_SetBtCoexCurrAntNum
+u8 BTDM_IsActionSCO(struct rtw_adapter * padapter);
+u8 BTDM_IsActionHID(struct rtw_adapter * padapter);
+u8 BTDM_IsActionA2DP(struct rtw_adapter * padapter);
+u8 BTDM_IsActionPAN(struct rtw_adapter * padapter);
+u8 BTDM_IsActionHIDA2DP(struct rtw_adapter * padapter);
+u8 BTDM_IsActionHIDPAN(struct rtw_adapter * padapter);
+u8 BTDM_IsActionPANA2DP(struct rtw_adapter * padapter);
+u8 BTDM_IsBtDisabled(struct rtw_adapter * padapter);
+#define BT_IsBtDisabled BTDM_IsBtDisabled
+u32 BTDM_BtTxRxCounterH(struct rtw_adapter * padapter);
+u32 BTDM_BtTxRxCounterL(struct rtw_adapter * padapter);
+
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver HAL/BTCoexist/HalBtCoe=
xist.h =3D=3D=3D=3D=3D */
+#endif /*  __HALBTCOEXIST_C__ */
+
+#ifdef __HALBT_C__ /*  HAL/HalBT.h */
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver HAL/HalBT.=
h =3D=3D=3D=3D=3D */
+
+#define RTS_CTS_NO_LEN_LIMIT	0
+
+u8 HALBT_GetPGAntNum(struct rtw_adapter * padapter);
+#define BT_GetPGAntNum HALBT_GetPGAntNum
+void HALBT_SetKey(struct rtw_adapter * padapter, u8 EntryNum);
+void HALBT_RemoveKey(struct rtw_adapter * padapter, u8 EntryNum);
+void HALBT_InitBTVars8723A(struct rtw_adapter * padapter);
+#define HALBT_InitHalVars HALBT_InitBTVars8723A
+#define BT_InitHalVars HALBT_InitHalVars
+u8 HALBT_IsBTExist(struct rtw_adapter * padapter);
+#define BT_IsBtExist HALBT_IsBTExist
+u8 HALBT_BTChipType(struct rtw_adapter * padapter);
+void HALBT_InitHwConfig(struct rtw_adapter * padapter);
+#define BT_InitHwConfig HALBT_InitHwConfig
+void HALBT_SetRtsCtsNoLenLimit(struct rtw_adapter * padapter);
+
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver HAL/HalBT.c =3D=3D=3D=3D=
=3D */
+#endif /*  __HALBT_C__ */
+
+#define _bt_dbg_off_		0
+#define _bt_dbg_on_		1
+
+extern u32 BTCoexDbgLevel;
+
+
+
+#endif /*  __RTL8723A_BT_COEXIST_H__ */
diff --git a/drivers/staging/rtl8723au/include/rtl8723a_cmd.h b/drivers=
/staging/rtl8723au/include/rtl8723a_cmd.h
new file mode 100644
index 0000000..8fccbfc
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtl8723a_cmd.h
@@ -0,0 +1,160 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2012 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTL8723A_CMD_H__
+#define __RTL8723A_CMD_H__
+
+
+#define H2C_BT_FW_PATCH_LEN		3
+#define H2C_BT_PWR_FORCE_LEN		3
+
+enum cmd_msg_element_id
+{
+	NONE_CMDMSG_EID,
+	AP_OFFLOAD_EID =3D 0,
+	SET_PWRMODE_EID =3D 1,
+	JOINBSS_RPT_EID =3D 2,
+	RSVD_PAGE_EID =3D 3,
+	RSSI_4_EID =3D 4,
+	RSSI_SETTING_EID =3D 5,
+	MACID_CONFIG_EID =3D 6,
+	MACID_PS_MODE_EID =3D 7,
+	P2P_PS_OFFLOAD_EID =3D 8,
+	SELECTIVE_SUSPEND_ROF_CMD =3D 9,
+	BT_QUEUE_PKT_EID =3D 17,
+	BT_ANT_TDMA_EID =3D 20,
+	BT_2ANT_HID_EID =3D 21,
+	P2P_PS_CTW_CMD_EID =3D 32,
+	FORCE_BT_TX_PWR_EID =3D 33,
+	SET_TDMA_WLAN_ACT_TIME_EID =3D 34,
+	SET_BT_TX_RETRY_INDEX_EID =3D 35,
+	HID_PROFILE_ENABLE_EID =3D 36,
+	BT_IGNORE_WLAN_ACT_EID =3D 37,
+	BT_PTA_MANAGER_UPDATE_ENABLE_EID =3D 38,
+	DAC_SWING_VALUE_EID =3D 41,
+	TRADITIONAL_TDMA_EN_EID =3D 51,
+	H2C_BT_FW_PATCH =3D 54,
+	B_TYPE_TDMA_EID =3D 58,
+	SCAN_EN_EID =3D 59,
+	LOWPWR_LPS_EID =3D 71,
+	H2C_RESET_TSF =3D 75,
+	MAX_CMDMSG_EID
+};
+
+struct cmd_msg_parm {
+	u8 eid; /* element id */
+	u8 sz; /*  sz */
+	u8 buf[6];
+};
+
+struct setpwrmode_parm {
+	u8 Mode;
+	u8 SmartPS;
+	u8 AwakeInterval;	/*  unit: beacon interval */
+	u8 bAllQueueUAPSD;
+
+#define SETPM_LOWRXBCN			BIT(0)
+#define SETPM_AUTOANTSWITCH		BIT(1)
+#define SETPM_PSALLOWBTHIGHPRI	BIT(2)
+	u8 BcnAntMode;
+} __packed;
+
+struct H2C_SS_RFOFF_PARAM{
+	u8 ROFOn; /*  1: on, 0:off */
+	u16 gpio_period; /*  unit: 1024 us */
+}__attribute__ ((packed));
+
+
+struct joinbssrpt_parm {
+	u8 OpMode;	/*  enum rt_media_status */
+};
+
+struct rsvdpage_loc {
+	u8 LocProbeRsp;
+	u8 LocPsPoll;
+	u8 LocNullData;
+	u8 LocQosNull;
+	u8 LocBTQosNull;
+};
+
+struct P2P_PS_Offload_t {
+	u8 Offload_En:1;
+	u8 role:1; /*  1: Owner, 0: Client */
+	u8 CTWindow_En:1;
+	u8 NoA0_En:1;
+	u8 NoA1_En:1;
+	u8 AllStaSleep:1; /*  Only valid in Owner */
+	u8 discovery:1;
+	u8 rsvd:1;
+};
+
+struct P2P_PS_CTWPeriod_t {
+	u8 CTWPeriod;	/* TU */
+};
+
+#define B_TDMA_EN			BIT(0)
+#define B_TDMA_FIXANTINBT		BIT(1)
+#define B_TDMA_TXPSPOLL			BIT(2)
+#define B_TDMA_VAL870			BIT(3)
+#define B_TDMA_AUTOWAKEUP		BIT(4)
+#define B_TDMA_NOPS			BIT(5)
+#define B_TDMA_WLANHIGHPRI		BIT(6)
+
+struct b_type_tdma_parm {
+	u8 option;
+
+	u8 TBTTOnPeriod;
+	u8 MedPeriod;
+	u8 rsvd30;
+} __packed;
+
+struct scan_en_parm {
+	u8 En;
+} __packed;
+
+/*  BT_PWR */
+#define SET_H2CCMD_BT_PWR_IDX(__pH2CCmd, __Value)							SET_BITS_TO_LE=
_1BYTE_8BIT(__pH2CCmd, 0, 8, __Value)
+
+/*  BT_FW_PATCH */
+#define SET_H2CCMD_BT_FW_PATCH_ENABLE(__pH2CCmd, __Value)					SET_BITS=
_TO_LE_4BYTE(__pH2CCmd, 0, 8, __Value) /*	SET_BITS_TO_LE_1BYTE(__pH2CCm=
d, 0, 8, __Value) */
+#define SET_H2CCMD_BT_FW_PATCH_SIZE(__pH2CCmd, __Value)						SET_BITS_=
TO_LE_4BYTE(__pH2CCmd, 8, 16, __Value) /*	SET_BITS_TO_LE_2BYTE((__pH2CC=
md)+1, 0, 16, __Value) */
+
+struct lowpwr_lps_parm{
+	u8 bcn_count:4;
+	u8 tb_bcn_threshold:3;
+	u8 enable:1;
+	u8 bcn_interval;
+	u8 drop_threshold;
+	u8 max_early_period;
+	u8 max_bcn_timeout_period;
+} __packed;
+
+
+/*  host message to firmware cmd */
+void rtl8723a_set_FwPwrMode_cmd(struct rtw_adapter * padapter, u8 Mode=
);
+void rtl8723a_set_FwJoinBssReport_cmd(struct rtw_adapter * padapter, u=
8 mstatus);
+#ifdef CONFIG_8723AU_BT_COEXIST
+void rtl8723a_set_BTCoex_AP_mode_FwRsvdPkt_cmd(struct rtw_adapter * pa=
dapter);
+#endif
+u8 rtl8723a_set_rssi_cmd(struct rtw_adapter * padapter, u8 *param);
+u8 rtl8723a_set_raid_cmd(struct rtw_adapter * padapter, u32 mask, u8 a=
rg);
+void rtl8723a_add_rateatid(struct rtw_adapter * padapter, u32 bitmap, =
u8 arg, u8 rssi_level);
+
+#ifdef CONFIG_8723AU_P2P
+void rtl8723a_set_p2p_ps_offload_cmd(struct rtw_adapter * padapter, u8=
 p2p_ps_state);
+#endif /* CONFIG_8723AU_P2P */
+
+void CheckFwRsvdPageContent23a(struct rtw_adapter *padapter);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtl8723a_dm.h b/drivers/=
staging/rtl8723au/include/rtl8723a_dm.h
new file mode 100644
index 0000000..47e887f
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtl8723a_dm.h
@@ -0,0 +1,144 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTL8723A_DM_H__
+#define __RTL8723A_DM_H__
+/*  */
+/*  Description: */
+/*  */
+/*  This file is for 8723A dynamic mechanism only */
+/*  */
+/*  */
+/*  */
+#define DYNAMIC_FUNC_BT BIT(0)
+
+enum{
+	UP_LINK,
+	DOWN_LINK,
+};
+/*  */
+/*  structure and define */
+/*  */
+
+/*  duplicate code,will move to ODM ######### */
+#define IQK_MAC_REG_NUM		4
+#define IQK_ADDA_REG_NUM		16
+#define IQK_BB_REG_NUM			9
+#define HP_THERMAL_NUM		8
+/*  duplicate code,will move to ODM ######### */
+struct dm_priv
+{
+	u8	DM_Type;
+	u8	DMFlag;
+	u8	InitDMFlag;
+	u32	InitODMFlag;
+
+	/*  Upper and Lower Signal threshold for Rate Adaptive*/
+	int	UndecoratedSmoothedPWDB;
+	int	UndecoratedSmoothedCCK;
+	int	EntryMinUndecoratedSmoothedPWDB;
+	int	EntryMaxUndecoratedSmoothedPWDB;
+	int	MinUndecoratedPWDBForDM;
+	int	LastMinUndecoratedPWDBForDM;
+
+	s32	UndecoratedSmoothedBeacon;
+	#ifdef CONFIG_8723AU_BT_COEXIST
+	s32 BT_EntryMinUndecoratedSmoothedPWDB;
+	s32 BT_EntryMaxUndecoratedSmoothedPWDB;
+	#endif
+
+	/* for High Power */
+	u8 bDynamicTxPowerEnable;
+	u8 LastDTPLvl;
+	u8 DynamicTxHighPowerLvl;/* Add by Jacken Tx Power Control for Near/F=
ar Range 2008/03/06 */
+
+	/* for tx power tracking */
+	u8	bTXPowerTracking;
+	u8	TXPowercount;
+	u8	bTXPowerTrackingInit;
+	u8	TxPowerTrackControl;	/* for mp mode, turn off txpwrtracking as def=
ault */
+	u8	TM_Trigger;
+
+	u8	ThermalMeter[2];				/*  ThermalMeter, index 0 for RFIC0, and 1 for=
 RFIC1 */
+	u8	ThermalValue;
+	u8	ThermalValue_LCK;
+	u8	ThermalValue_IQK;
+	u8	ThermalValue_DPK;
+
+	u8	bRfPiEnable;
+
+	/* for APK */
+	u32	APKoutput[2][2];	/* path A/B; output1_1a/output1_2a */
+	u8	bAPKdone;
+	u8	bAPKThermalMeterIgnore;
+	u8	bDPdone;
+	u8	bDPPathAOK;
+	u8	bDPPathBOK;
+
+	/* for IQK */
+	u32	RegC04;
+	u32	Reg874;
+	u32	RegC08;
+	u32	RegB68;
+	u32	RegB6C;
+	u32	Reg870;
+	u32	Reg860;
+	u32	Reg864;
+	u32	ADDA_backup[IQK_ADDA_REG_NUM];
+	u32	IQK_MAC_backup[IQK_MAC_REG_NUM];
+	u32	IQK_BB_backup_recover[9];
+	u32	IQK_BB_backup[IQK_BB_REG_NUM];
+	u8	PowerIndex_backup[6];
+
+	u8	bCCKinCH14;
+
+	u8	CCK_index;
+	u8	OFDM_index[2];
+
+	u8	bDoneTxpower;
+	u8	CCK_index_HP;
+	u8	OFDM_index_HP[2];
+	u8	ThermalValue_HP[HP_THERMAL_NUM];
+	u8	ThermalValue_HP_index;
+
+	/* for TxPwrTracking */
+	s32	RegE94;
+	s32     RegE9C;
+	s32	RegEB4;
+	s32	RegEBC;
+
+	u32	TXPowerTrackingCallbackCnt;	/* cosa add for debug */
+
+	u32	prv_traffic_idx; /*  edca turbo */
+
+	s32	OFDM_Pkt_Cnt;
+	u8	RSSI_Select;
+/*	u8	DIG_Dynamic_MIN ; */
+/*  duplicate code,will move to ODM ######### */
+	/*  Add for Reading Initial Data Rate SEL Register 0x484 during watch=
dog. Using for fill tx desc. 2011.3.21 by Thomas */
+	u8	INIDATA_RATE[32];
+};
+
+
+/*  */
+/*  function prototype */
+/*  */
+
+void rtl8723a_init_dm_priv(struct rtw_adapter *padapter);
+void rtl8723a_deinit_dm_priv(struct rtw_adapter *padapter);
+
+void rtl8723a_InitHalDm(struct rtw_adapter *padapter);
+void rtl8723a_HalDmWatchDog(struct rtw_adapter *padapter);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtl8723a_hal.h b/drivers=
/staging/rtl8723au/include/rtl8723a_hal.h
new file mode 100644
index 0000000..c20248b
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtl8723a_hal.h
@@ -0,0 +1,575 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTL8723A_HAL_H__
+#define __RTL8723A_HAL_H__
+
+#include "rtl8723a_spec.h"
+#include "rtl8723a_pg.h"
+#include "Hal8723APhyReg.h"
+#include "Hal8723APhyCfg.h"
+#include "rtl8723a_rf.h"
+#ifdef CONFIG_8723AU_BT_COEXIST
+#include "rtl8723a_bt-coexist.h"
+#endif
+#include "rtl8723a_dm.h"
+#include "rtl8723a_recv.h"
+#include "rtl8723a_xmit.h"
+#include "rtl8723a_cmd.h"
+#include "rtl8723a_sreset.h"
+#include "rtw_efuse.h"
+
+#include "odm_precomp.h"
+
+
+/* 2TODO: We should define 8192S firmware related macro settings here!=
! */
+#define RTL819X_DEFAULT_RF_TYPE			RF_1T2R
+#define RTL819X_TOTAL_RF_PATH				2
+
+/* TODO:  The following need to check!! */
+#define RTL8723_FW_UMC_IMG				"rtl8192CU\\rtl8723fw.bin"
+#define RTL8723_FW_UMC_B_IMG			"rtl8192CU\\rtl8723fw_B.bin"
+#define RTL8723_PHY_REG					"rtl8723S\\PHY_REG_1T.txt"
+#define RTL8723_PHY_RADIO_A				"rtl8723S\\radio_a_1T.txt"
+#define RTL8723_PHY_RADIO_B				"rtl8723S\\radio_b_1T.txt"
+#define RTL8723_AGC_TAB					"rtl8723S\\AGC_TAB_1T.txt"
+#define RTL8723_PHY_MACREG				"rtl8723S\\MAC_REG.txt"
+#define RTL8723_PHY_REG_PG				"rtl8723S\\PHY_REG_PG.txt"
+#define RTL8723_PHY_REG_MP				"rtl8723S\\PHY_REG_MP.txt"
+
+/*  */
+/*		RTL8723S From header */
+/*  */
+
+/*  Fw Array */
+#define Rtl8723_FwImageArray				Rtl8723UFwImgArray
+#define Rtl8723_FwUMCBCutImageArrayWithBT		Rtl8723UFwUMCBCutImgArrayWi=
thBT
+#define Rtl8723_FwUMCBCutImageArrayWithoutBT	Rtl8723UFwUMCBCutImgArray=
WithoutBT
+
+#define Rtl8723_ImgArrayLength				Rtl8723UImgArrayLength
+#define Rtl8723_UMCBCutImgArrayWithBTLength		Rtl8723UUMCBCutImgArrayWi=
thBTLength
+#define Rtl8723_UMCBCutImgArrayWithoutBTLength	Rtl8723UUMCBCutImgArray=
WithoutBTLength
+
+#define Rtl8723_PHY_REG_Array_PG			Rtl8723UPHY_REG_Array_PG
+#define Rtl8723_PHY_REG_Array_PGLength		Rtl8723UPHY_REG_Array_PGLength
+
+#define Rtl8723_FwUMCBCutMPImageArray		Rtl8723SFwUMCBCutMPImgAr
+#define Rtl8723_UMCBCutMPImgArrayLength		Rtl8723SUMCBCutMPImgArrayLeng=
th
+
+#define DRVINFO_SZ				4 /*  unit is 8bytes */
+#define PageNum_128(_Len)		(u32)(((_Len)>>7) + ((_Len)&0x7F ? 1:0))
+
+#define FW_8723A_SIZE			0x8000
+#define FW_8723A_START_ADDRESS	0x1000
+#define FW_8723A_END_ADDRESS		0x1FFF /* 0x5FFF */
+
+#define MAX_PAGE_SIZE			4096	/*  @ page : 4k bytes */
+
+#define IS_FW_HEADER_EXIST(_pFwHdr)	((le16_to_cpu(_pFwHdr->Signature)&=
0xFFF0) =3D=3D 0x92C0 ||\
+									(le16_to_cpu(_pFwHdr->Signature)&0xFFF0) =3D=3D 0x88C0 ||\
+									(le16_to_cpu(_pFwHdr->Signature)&0xFFF0) =3D=3D 0x2300)
+
+/*  */
+/*  This structure must be cared byte-ordering */
+/*  */
+/*  Added by tynli. 2009.12.04. */
+struct rt_8723a_firmware_hdr {
+	/*  8-byte alinment required */
+
+	/*  LONG WORD 0 ---- */
+	u16		Signature;	/*  92C0: test chip; 92C, 88C0: test chip; 88C1: MP A=
-cut; 92C1: MP A-cut */
+	u8		Category;	/*  AP/NIC and USB/PCI */
+	u8		Function;	/*  Reserved for different FW function indcation, for f=
urther use when driver needs to download different FW in different cond=
itions */
+	u16		Version;		/*  FW Version */
+	u8		Subversion;	/*  FW Subversion, default 0x00 */
+	u16		Rsvd1;
+
+
+	/*  LONG WORD 1 ---- */
+	u8		Month;	/*  Release time Month field */
+	u8		Date;	/*  Release time Date field */
+	u8		Hour;	/*  Release time Hour field */
+	u8		Minute;	/*  Release time Minute field */
+	u16		RamCodeSize;	/*  The size of RAM code */
+	u16		Rsvd2;
+
+	/*  LONG WORD 2 ---- */
+	u32		SvnIdx;	/*  The SVN entry index */
+	u32		Rsvd3;
+
+	/*  LONG WORD 3 ---- */
+	u32		Rsvd4;
+	u32		Rsvd5;
+};
+
+#define DRIVER_EARLY_INT_TIME		0x05
+#define BCN_DMA_ATIME_INT_TIME		0x02
+
+
+/*  BK, BE, VI, VO, HCCA, MANAGEMENT, COMMAND, HIGH, BEACON. */
+#define MAX_TX_QUEUE		9
+
+#define TX_SELE_HQ			BIT(0)		/*  High Queue */
+#define TX_SELE_LQ			BIT(1)		/*  Low Queue */
+#define TX_SELE_NQ			BIT(2)		/*  Normal Queue */
+
+/*  Note: We will divide number of page equally for each queue other t=
han public queue! */
+#define TX_TOTAL_PAGE_NUMBER	0xF8
+#define TX_PAGE_BOUNDARY		(TX_TOTAL_PAGE_NUMBER + 1)
+
+/*  For Normal Chip Setting */
+/*  (HPQ + LPQ + NPQ + PUBQ) shall be TX_TOTAL_PAGE_NUMBER */
+#define NORMAL_PAGE_NUM_PUBQ	0xE7
+#define NORMAL_PAGE_NUM_HPQ		0x0C
+#define NORMAL_PAGE_NUM_LPQ		0x02
+#define NORMAL_PAGE_NUM_NPQ		0x02
+
+/*  For Test Chip Setting */
+/*  (HPQ + LPQ + PUBQ) shall be TX_TOTAL_PAGE_NUMBER */
+#define TEST_PAGE_NUM_PUBQ		0x7E
+
+/*  For Test Chip Setting */
+#define WMM_TEST_TX_TOTAL_PAGE_NUMBER	0xF5
+#define WMM_TEST_TX_PAGE_BOUNDARY		(WMM_TEST_TX_TOTAL_PAGE_NUMBER + 1)=
 /* F6 */
+
+#define WMM_TEST_PAGE_NUM_PUBQ		0xA3
+#define WMM_TEST_PAGE_NUM_HPQ		0x29
+#define WMM_TEST_PAGE_NUM_LPQ		0x29
+
+/*  Note: For Normal Chip Setting, modify later */
+#define WMM_NORMAL_TX_TOTAL_PAGE_NUMBER	0xF5
+#define WMM_NORMAL_TX_PAGE_BOUNDARY		(WMM_TEST_TX_TOTAL_PAGE_NUMBER + =
1) /* F6 */
+
+#define WMM_NORMAL_PAGE_NUM_PUBQ	0xB0
+#define WMM_NORMAL_PAGE_NUM_HPQ		0x29
+#define WMM_NORMAL_PAGE_NUM_LPQ		0x1C
+#define WMM_NORMAL_PAGE_NUM_NPQ		0x1C
+
+
+/*  */
+/*	Chip specific */
+/*  */
+#define CHIP_BONDING_IDENTIFIER(_value)	(((_value)>>22)&0x3)
+#define CHIP_BONDING_92C_1T2R			0x1
+#define CHIP_BONDING_88C_USB_MCARD		0x2
+#define CHIP_BONDING_88C_USB_HP			0x1
+
+#include "HalVerDef.h"
+#include "hal_com.h"
+
+/*  */
+/*	Channel Plan */
+/*  */
+enum ChannelPlan
+{
+	CHPL_FCC	=3D 0,
+	CHPL_IC		=3D 1,
+	CHPL_ETSI	=3D 2,
+	CHPL_SPAIN	=3D 3,
+	CHPL_FRANCE	=3D 4,
+	CHPL_MKK	=3D 5,
+	CHPL_MKK1	=3D 6,
+	CHPL_ISRAEL	=3D 7,
+	CHPL_TELEC	=3D 8,
+	CHPL_GLOBAL	=3D 9,
+	CHPL_WORLD	=3D 10,
+};
+
+#define EFUSE_REAL_CONTENT_LEN		512
+#define EFUSE_MAP_LEN				128
+#define EFUSE_MAX_SECTION			16
+#define EFUSE_IC_ID_OFFSET			506	/* For some inferiority IC purpose. a=
dded by Roger, 2009.09.02. */
+#define AVAILABLE_EFUSE_ADDR(addr)	(addr < EFUSE_REAL_CONTENT_LEN)
+/*  */
+/*  <Roger_Notes> */
+/*  To prevent out of boundary programming case, */
+/*  leave 1byte and program full section */
+/*  9bytes + 1byt + 5bytes and pre 1byte. */
+/*  For worst case: */
+/*  | 1byte|----8bytes----|1byte|--5bytes--| */
+/*  |         |            Reserved(14bytes)	      | */
+/*  */
+
+/*  PG data exclude header, dummy 6 bytes frome CP test and reserved 1=
byte. */
+#define EFUSE_OOB_PROTECT_BYTES			15
+
+#define EFUSE_REAL_CONTENT_LEN_8723A	512
+#define EFUSE_MAP_LEN_8723A				256
+#define EFUSE_MAX_SECTION_8723A			32
+
+/*  */
+/*			EFUSE for BT definition */
+/*  */
+#define EFUSE_BT_REAL_BANK_CONTENT_LEN	512
+#define EFUSE_BT_REAL_CONTENT_LEN		1536	/*  512*3 */
+#define EFUSE_BT_MAP_LEN				1024	/*  1k bytes */
+#define EFUSE_BT_MAX_SECTION			128		/*  1024/8 */
+
+#define EFUSE_PROTECT_BYTES_BANK		16
+
+/*  */
+/*  <Roger_Notes> For RTL8723 WiFi/BT/GPS multi-function configuration=
=2E 2010.10.06. */
+/*  */
+enum RT_MULTI_FUNC {
+	RT_MULTI_FUNC_NONE =3D 0x00,
+	RT_MULTI_FUNC_WIFI =3D 0x01,
+	RT_MULTI_FUNC_BT =3D 0x02,
+	RT_MULTI_FUNC_GPS =3D 0x04,
+};
+
+/*  */
+/*  <Roger_Notes> For RTL8723 WiFi PDn/GPIO polarity control configura=
tion. 2010.10.08. */
+/*  */
+enum RT_POLARITY_CTL {
+	RT_POLARITY_LOW_ACT =3D 0,
+	RT_POLARITY_HIGH_ACT =3D 1,
+};
+
+/*  For RTL8723 regulator mode. by tynli. 2011.01.14. */
+enum RT_REGULATOR_MODE {
+	RT_SWITCHING_REGULATOR =3D 0,
+	RT_LDO_REGULATOR =3D 1,
+};
+
+/*  Description: Determine the types of C2H events that are the same i=
n driver and Fw. */
+/*  Fisrt constructed by tynli. 2009.10.09. */
+enum {
+	C2H_DBG =3D 0,
+	C2H_TSF =3D 1,
+	C2H_AP_RPT_RSP =3D 2,
+	C2H_CCX_TX_RPT =3D 3,	/*  The FW notify the report of the specific tx=
 packet. */
+	C2H_BT_RSSI =3D 4,
+	C2H_BT_OP_MODE =3D 5,
+	C2H_EXT_RA_RPT =3D 6,
+	C2H_HW_INFO_EXCH =3D 10,
+	C2H_C2H_H2C_TEST =3D 11,
+	C2H_BT_INFO =3D 12,
+	C2H_BT_MP_INFO =3D 15,
+	MAX_C2HEVENT
+};
+
+struct hal_data_8723a {
+	struct hal_version		VersionID;
+	enum rt_customer_id CustomerID;
+
+	u16	FirmwareVersion;
+	u16	FirmwareVersionRev;
+	u16	FirmwareSubVersion;
+	u16	FirmwareSignature;
+
+	/* current WIFI_PHY values */
+	u32	ReceiveConfig;
+	enum WIRELESS_MODE		CurrentWirelessMode;
+	enum ht_channel_width	CurrentChannelBW;
+	u8	CurrentChannel;
+	u8	nCur40MhzPrimeSC;/*  Control channel sub-carrier */
+
+	u16	BasicRateSet;
+
+	/* rf_ctrl */
+	u8	rf_chip;
+	u8	rf_type;
+	u8	NumTotalRFPath;
+
+	u8	BoardType;
+	u8	CrystalCap;
+	/*  */
+	/*  EEPROM setting. */
+	/*  */
+	u8	EEPROMVersion;
+	u16	EEPROMVID;
+	u16	EEPROMPID;
+	u16	EEPROMSVID;
+	u16	EEPROMSDID;
+	u8	EEPROMCustomerID;
+	u8	EEPROMSubCustomerID;
+	u8	EEPROMRegulatory;
+	u8	EEPROMThermalMeter;
+	u8	EEPROMBluetoothCoexist;
+	u8	EEPROMBluetoothType;
+	u8	EEPROMBluetoothAntNum;
+	u8	EEPROMBluetoothAntIsolation;
+	u8	EEPROMBluetoothRadioShared;
+
+	u8	bTXPowerDataReadFromEEPORM;
+	u8	bAPKThermalMeterIgnore;
+
+	u8	bIQKInitialized;
+	u8	bAntennaDetected;
+
+	u8	TxPwrLevelCck[RF_PATH_MAX][CHANNEL_MAX_NUMBER];
+	u8	TxPwrLevelHT40_1S[RF_PATH_MAX][CHANNEL_MAX_NUMBER];	/*  For HT 40M=
HZ pwr */
+	u8	TxPwrLevelHT40_2S[RF_PATH_MAX][CHANNEL_MAX_NUMBER];	/*  For HT 40M=
HZ pwr */
+	u8	TxPwrHt20Diff[RF_PATH_MAX][CHANNEL_MAX_NUMBER];/*  HT 20<->40 Pwr =
diff */
+	u8	TxPwrLegacyHtDiff[RF_PATH_MAX][CHANNEL_MAX_NUMBER];/*  For HT<->le=
gacy pwr diff */
+	/*  For power group */
+	u8	PwrGroupHT20[RF_PATH_MAX][CHANNEL_MAX_NUMBER];
+	u8	PwrGroupHT40[RF_PATH_MAX][CHANNEL_MAX_NUMBER];
+
+	u8	LegacyHTTxPowerDiff;/*  Legacy to HT rate power diff */
+
+	/*  Read/write are allow for following hardware information variables=
 */
+	u8	framesync;
+	u32	framesyncC34;
+	u8	framesyncMonitor;
+	u8	DefaultInitialGain[4];
+	u8	pwrGroupCnt;
+	u32	MCSTxPowerLevelOriginalOffset[7][16];
+	u32	CCKTxPowerLevelOriginalOffset;
+
+	u32	AntennaTxPath;					/*  Antenna path Tx */
+	u32	AntennaRxPath;					/*  Antenna path Rx */
+	u8	ExternalPA;
+
+	u8	bLedOpenDrain; /*  Support Open-drain arrangement for controlling =
the LED. Added by Roger, 2009.10.16. */
+
+	u8	b1x1RecvCombine;	/*  for 1T1R receive combining */
+
+	/*  For EDCA Turbo mode */
+
+	u32	AcParam_BE; /* Original parameter for BE, use for EDCA turbo. */
+
+	/* vivi, for tx power tracking, 20080407 */
+	/* u16	TSSI_13dBm; */
+	/* u32	Pwr_Track; */
+	/*  The current Tx Power Level */
+	u8	CurrentCckTxPwrIdx;
+	u8	CurrentOfdm24GTxPwrIdx;
+
+	struct bb_reg_define	PHYRegDef[4];	/* Radio A/B/C/D */
+
+	bool		bRFPathRxEnable[4];	/*  We support 4 RF path now. */
+
+	u32	RfRegChnlVal[2];
+
+	u8	bCckHighPower;
+
+	/* RDG enable */
+	bool	 bRDGEnable;
+
+	/* for host message to fw */
+	u8	LastHMEBoxNum;
+
+	u8	fw_ractrl;
+	u8	RegTxPause;
+	/*  Beacon function related global variable. */
+	u32	RegBcnCtrlVal;
+	u8	RegFwHwTxQCtrl;
+	u8	RegReg542;
+
+	struct dm_priv	dmpriv;
+	struct dm_odm_t		odmpriv;
+	struct sreset_priv srestpriv;
+
+#ifdef CONFIG_8723AU_BT_COEXIST
+	u8				bBTMode;
+	/*  BT only. */
+	struct bt_30info		BtInfo;
+	/*  For bluetooth co-existance */
+	struct bt_coexist_str	bt_coexist;
+#endif
+
+	u8	bDumpRxPkt;/* for debug */
+	u8	FwRsvdPageStartOffset; /* 2010.06.23. Added by tynli. Reserve page=
 start offset except beacon in TxQ. */
+
+	/*  2010/08/09 MH Add CU power down mode. */
+	u8	pwrdown;
+
+	/*  Add for dual MAC  0--Mac0 1--Mac1 */
+	u32	interfaceIndex;
+
+	u8	OutEpQueueSel;
+	u8	OutEpNumber;
+
+	/*  2010/12/10 MH Add for USB aggreation mode dynamic shceme. */
+	bool		UsbRxHighSpeedMode;
+
+	/*  2010/11/22 MH Add for slim combo debug mode selective. */
+	/*  This is used for fix the drawback of CU TSMC-A/UMC-A cut. HW auto=
 suspend ability. Close BT clock. */
+	bool		SlimComboDbg;
+
+	/*  */
+	/*  Add For EEPROM Efuse switch and  Efuse Shadow map Setting */
+	/*  */
+	u8			EepromOrEfuse;
+	u16			EfuseUsedBytes;
+	u16			BTEfuseUsedBytes;
+
+	/*  Interrupt relatd register information. */
+	u32			SysIntrStatus;
+	u32			SysIntrMask;
+
+	/*  */
+	/*  2011/02/23 MH Add for 8723 mylti function definition. The define =
should be moved to an */
+	/*  independent file in the future. */
+	/*  */
+	/* 8723-----------------------------------------*/
+	enum RT_MULTI_FUNC	MultiFunc; /*  For multi-function consideration. *=
/
+	enum RT_POLARITY_CTL	PolarityCtl; /*  For Wifi PDn Polarity control. =
*/
+	enum RT_REGULATOR_MODE	RegulatorMode; /*  switching regulator or LDO =
*/
+	/* 8723-----------------------------------------
+	 *  2011/02/23 MH Add for 8723 mylti function definition. The define =
should be moved to an */
+	/*  independent file in the future. */
+
+	bool				bMACFuncEnable;
+
+#ifdef CONFIG_8723AU_P2P
+	struct P2P_PS_Offload_t	p2p_ps_offload;
+#endif
+
+
+	/*  */
+	/*  For USB Interface HAL related */
+	/*  */
+	u32	UsbBulkOutSize;
+
+	/*  Interrupt related register information. */
+	u32	IntArray[2];
+	u32	IntrMask[2];
+
+	/*  */
+	/*  For SDIO Interface HAL related */
+	/*  */
+
+	/*  Auto FSM to Turn On, include clock, isolation, power control for =
MAC only */
+	u8			bMacPwrCtrlOn;
+
+};
+
+#define GET_HAL_DATA(__pAdapter)	((struct hal_data_8723a *)((__pAdapte=
r)->HalData))
+#define GET_RF_TYPE(priv)			(GET_HAL_DATA(priv)->rf_type)
+
+#define INCLUDE_MULTI_FUNC_BT(_Adapter)		(GET_HAL_DATA(_Adapter)->Mult=
iFunc & RT_MULTI_FUNC_BT)
+#define INCLUDE_MULTI_FUNC_GPS(_Adapter)	(GET_HAL_DATA(_Adapter)->Mult=
iFunc & RT_MULTI_FUNC_GPS)
+
+struct rxreport_8723a {
+	u32 pktlen:14;
+	u32 crc32:1;
+	u32 icverr:1;
+	u32 drvinfosize:4;
+	u32 security:3;
+	u32 qos:1;
+	u32 shift:2;
+	u32 physt:1;
+	u32 swdec:1;
+	u32 ls:1;
+	u32 fs:1;
+	u32 eor:1;
+	u32 own:1;
+
+	u32 macid:5;
+	u32 tid:4;
+	u32 hwrsvd:4;
+	u32 amsdu:1;
+	u32 paggr:1;
+	u32 faggr:1;
+	u32 a1fit:4;
+	u32 a2fit:4;
+	u32 pam:1;
+	u32 pwr:1;
+	u32 md:1;
+	u32 mf:1;
+	u32 type:2;
+	u32 mc:1;
+	u32 bc:1;
+
+	u32 seq:12;
+	u32 frag:4;
+	u32 nextpktlen:14;
+	u32 nextind:1;
+	u32 rsvd0831:1;
+
+	u32 rxmcs:6;
+	u32 rxht:1;
+	u32 gf:1;
+	u32 splcp:1;
+	u32 bw:1;
+	u32 htc:1;
+	u32 eosp:1;
+	u32 bssidfit:2;
+	u32 rsvd1214:16;
+	u32 unicastwake:1;
+	u32 magicwake:1;
+
+	u32 pattern0match:1;
+	u32 pattern1match:1;
+	u32 pattern2match:1;
+	u32 pattern3match:1;
+	u32 pattern4match:1;
+	u32 pattern5match:1;
+	u32 pattern6match:1;
+	u32 pattern7match:1;
+	u32 pattern8match:1;
+	u32 pattern9match:1;
+	u32 patternamatch:1;
+	u32 patternbmatch:1;
+	u32 patterncmatch:1;
+	u32 rsvd1613:19;
+
+	u32 tsfl;
+
+	u32 bassn:12;
+	u32 bavld:1;
+	u32 rsvd2413:19;
+};
+
+/*  rtl8723a_hal_init.c */
+s32 rtl8723a_FirmwareDownload(struct rtw_adapter *padapter);
+void rtl8723a_FirmwareSelfReset(struct rtw_adapter *padapter);
+void rtl8723a_InitializeFirmwareVars(struct rtw_adapter *padapter);
+
+void rtl8723a_InitAntenna_Selection(struct rtw_adapter *padapter);
+void rtl8723a_DeinitAntenna_Selection(struct rtw_adapter *padapter);
+void rtl8723a_CheckAntenna_Selection(struct rtw_adapter *padapter);
+void rtl8723a_init_default_value(struct rtw_adapter *padapter);
+
+s32 InitLLTTable23a(struct rtw_adapter *padapter, u32 boundary);
+
+s32 CardDisableHWSM(struct rtw_adapter *padapter, u8 resetMCU);
+s32 CardDisableWithoutHWSM(struct rtw_adapter *padapter);
+
+/*  EFuse */
+u8 GetEEPROMSize8723A(struct rtw_adapter *padapter);
+void Hal_InitPGData(struct rtw_adapter *padapter, u8 *PROMContent);
+void Hal_EfuseParseIDCode(struct rtw_adapter *padapter, u8 *hwinfo);
+void Hal_EfuseParsetxpowerinfo_8723A(struct rtw_adapter *padapter, u8 =
*PROMContent, bool AutoLoadFail);
+void Hal_EfuseParseBTCoexistInfo_8723A(struct rtw_adapter *padapter, u=
8 *hwinfo, bool AutoLoadFail);
+void Hal_EfuseParseEEPROMVer(struct rtw_adapter *padapter, u8 *hwinfo,=
 bool AutoLoadFail);
+void rtl8723a_EfuseParseChnlPlan(struct rtw_adapter *padapter, u8 *hwi=
nfo, bool AutoLoadFail);
+void Hal_EfuseParseCustomerID(struct rtw_adapter *padapter, u8 *hwinfo=
, bool AutoLoadFail);
+void Hal_EfuseParseAntennaDiversity(struct rtw_adapter *padapter, u8 *=
hwinfo, bool AutoLoadFail);
+void Hal_EfuseParseRateIndicationOption(struct rtw_adapter *padapter, =
u8 *hwinfo, bool AutoLoadFail);
+void Hal_EfuseParseXtal_8723A(struct rtw_adapter *pAdapter, u8 *hwinfo=
, u8 AutoLoadFail);
+void Hal_EfuseParseThermalMeter_8723A(struct rtw_adapter *padapter, u8=
 *hwinfo, u8 AutoLoadFail);
+
+void Hal_InitChannelPlan23a(struct rtw_adapter *padapter);
+
+void rtl8723a_set_hal_ops(struct hal_ops *pHalFunc);
+void SetHwReg8723A(struct rtw_adapter *padapter, u8 variable, u8 *val)=
;
+void GetHwReg8723A(struct rtw_adapter *padapter, u8 variable, u8 *val)=
;
+#ifdef CONFIG_8723AU_BT_COEXIST
+void rtl8723a_SingleDualAntennaDetection(struct rtw_adapter *padapter)=
;
+#endif
+
+/*  register */
+void SetBcnCtrlReg23a(struct rtw_adapter *padapter, u8 SetBits, u8 Cle=
arBits);
+void rtl8723a_InitBeaconParameters(struct rtw_adapter *padapter);
+
+void rtl8723a_clone_haldata(struct rtw_adapter *dst_adapter, struct rt=
w_adapter *src_adapter);
+void rtl8723a_start_thread(struct rtw_adapter *padapter);
+void rtl8723a_stop_thread(struct rtw_adapter *padapter);
+
+s32 c2h_id_filter_ccx_8723a(u8 id);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtl8723a_led.h b/drivers=
/staging/rtl8723au/include/rtl8723a_led.h
new file mode 100644
index 0000000..1623d18
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtl8723a_led.h
@@ -0,0 +1,30 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTL8723A_LED_H__
+#define __RTL8723A_LED_H__
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+
+/*  */
+/*  Interface to manipulate LED objects. */
+/*  */
+void rtl8723au_InitSwLeds(struct rtw_adapter *padapter);
+void rtl8723au_DeInitSwLeds(struct rtw_adapter *padapter);
+void SwLedOn23a(struct rtw_adapter *padapter, struct led_8723a * pLed)=
;
+void SwLedOff23a(struct rtw_adapter *padapter, struct led_8723a * pLed=
);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtl8723a_pg.h b/drivers/=
staging/rtl8723au/include/rtl8723a_pg.h
new file mode 100644
index 0000000..12f7a13
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtl8723a_pg.h
@@ -0,0 +1,107 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTL8723A_PG_H__
+#define __RTL8723A_PG_H__
+
+/*  */
+/*			EEPROM/Efuse PG Offset for 8723E/8723U/8723S */
+/*  */
+#define EEPROM_CCK_TX_PWR_INX_8723A			0x10
+#define EEPROM_HT40_1S_TX_PWR_INX_8723A		0x16
+#define EEPROM_HT20_TX_PWR_INX_DIFF_8723A	0x1C
+#define EEPROM_OFDM_TX_PWR_INX_DIFF_8723A	0x1F
+#define EEPROM_HT40_MAX_PWR_OFFSET_8723A	0x22
+#define EEPROM_HT20_MAX_PWR_OFFSET_8723A	0x25
+
+#define EEPROM_ChannelPlan_8723A			0x28
+#define EEPROM_TSSI_A_8723A					0x29
+#define EEPROM_THERMAL_METER_8723A			0x2A
+#define RF_OPTION1_8723A					0x2B
+#define RF_OPTION2_8723A					0x2C
+#define RF_OPTION3_8723A					0x2D
+#define RF_OPTION4_8723A					0x2E
+#define EEPROM_VERSION_8723A				0x30
+#define EEPROM_CustomID_8723A				0x31
+#define EEPROM_SubCustomID_8723A			0x32
+#define EEPROM_XTAL_K_8723A					0x33
+#define EEPROM_Chipset_8723A				0x34
+
+/*  RTL8723AE */
+#define EEPROM_VID_8723AE					0x49
+#define EEPROM_DID_8723AE					0x4B
+#define EEPROM_SVID_8723AE					0x4D
+#define EEPROM_SMID_8723AE					0x4F
+#define EEPROM_MAC_ADDR_8723AE				0x67
+
+/*  RTL8723AU */
+#define EEPROM_MAC_ADDR_8723AU				0xC6
+#define EEPROM_VID_8723AU					0xB7
+#define EEPROM_PID_8723AU					0xB9
+
+/*  RTL8723AS */
+#define EEPROM_MAC_ADDR_8723AS				0xAA
+
+/*  */
+/*			EEPROM/Efuse Value Type */
+/*  */
+#define EETYPE_TX_PWR						0x0
+
+/*  */
+/*			EEPROM/Efuse Default Value */
+/*  */
+#define EEPROM_Default_CrystalCap_8723A		0x20
+
+
+/*  */
+/*        EEPROM/EFUSE data structure definition. */
+/*  */
+#define	MAX_RF_PATH_NUM	2
+#define	MAX_CHNL_GROUP		3+9
+
+struct txpowerinfo {
+	u8 CCKIndex[MAX_RF_PATH_NUM][MAX_CHNL_GROUP];
+	u8 HT40_1SIndex[MAX_RF_PATH_NUM][MAX_CHNL_GROUP];
+	u8 HT40_2SIndexDiff[MAX_RF_PATH_NUM][MAX_CHNL_GROUP];
+	u8 HT20IndexDiff[MAX_RF_PATH_NUM][MAX_CHNL_GROUP];
+	u8 OFDMIndexDiff[MAX_RF_PATH_NUM][MAX_CHNL_GROUP];
+	u8 HT40MaxOffset[MAX_RF_PATH_NUM][MAX_CHNL_GROUP];
+	u8 HT20MaxOffset[MAX_RF_PATH_NUM][MAX_CHNL_GROUP];
+	u8 TSSI_A[3];
+	u8 TSSI_B[3];
+	u8 TSSI_A_5G[3];		/* 5GL/5GM/5GH */
+	u8 TSSI_B_5G[3];
+};
+
+enum bt_ant_num {
+	Ant_x2	=3D 0,
+	Ant_x1	=3D 1
+};
+
+enum bt_cotype {
+	BT_2Wire		=3D 0,
+	BT_ISSC_3Wire		=3D 1,
+	BT_Accel		=3D 2,
+	BT_CSR_BC4		=3D 3,
+	BT_CSR_BC8		=3D 4,
+	BT_RTL8756		=3D 5,
+	BT_RTL8723A		=3D 6
+};
+
+enum bt_radioshared {
+	BT_Radio_Shared		=3D 0,
+	BT_Radio_Individual	=3D 1,
+};
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtl8723a_recv.h b/driver=
s/staging/rtl8723au/include/rtl8723a_recv.h
new file mode 100644
index 0000000..6bf6904
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtl8723a_recv.h
@@ -0,0 +1,70 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTL8723A_RECV_H__
+#define __RTL8723A_RECV_H__
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+#define NR_RECVBUFF (4)
+
+#define NR_PREALLOC_RECV_SKB (8)
+
+#define RECV_BLK_SZ 512
+#define RECV_BLK_CNT 16
+#define RECV_BLK_TH RECV_BLK_CNT
+
+#define MAX_RECVBUF_SZ (15360) /*  15k < 16k */
+
+#define RECV_BULK_IN_ADDR		0x80
+#define RECV_INT_IN_ADDR		0x81
+
+#define PHY_RSSI_SLID_WIN_MAX				100
+#define PHY_LINKQUALITY_SLID_WIN_MAX		20
+
+
+struct phy_stat
+{
+	unsigned int phydw0;
+	unsigned int phydw1;
+	unsigned int phydw2;
+	unsigned int phydw3;
+	unsigned int phydw4;
+	unsigned int phydw5;
+	unsigned int phydw6;
+	unsigned int phydw7;
+};
+
+/*  Rx smooth factor */
+#define	Rx_Smooth_Factor (20)
+
+struct interrupt_msg_format {
+	unsigned int C2H_MSG0;
+	unsigned int C2H_MSG1;
+	unsigned int C2H_MSG2;
+	unsigned int C2H_MSG3;
+	unsigned int HISR; /*  from HISR Reg0x124, read to clear */
+	unsigned int HISRE;/*  from HISRE Reg0x12c, read to clear */
+	unsigned int  MSG_EX;
+};
+
+void rtl8723au_init_recvbuf(struct rtw_adapter *padapter, struct recv_=
buf *precvbuf);
+int	rtl8723au_init_recv_priv(struct rtw_adapter * padapter);
+void rtl8723au_free_recv_priv(struct rtw_adapter * padapter);
+void rtl8723a_process_phy_info(struct rtw_adapter *padapter, void *prf=
rame);
+void update_recvframe_attrib(struct recv_frame *precvframe, struct rec=
v_stat *prxstat);
+void update_recvframe_phyinfo(struct recv_frame *precvframe, struct ph=
y_stat *pphy_info);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtl8723a_rf.h b/drivers/=
staging/rtl8723au/include/rtl8723a_rf.h
new file mode 100644
index 0000000..166a45f
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtl8723a_rf.h
@@ -0,0 +1,58 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTL8723A_RF_H__
+#define __RTL8723A_RF_H__
+
+/*--------------------------Define Parameters-------------------------=
------*/
+
+/*  */
+/*  For RF 6052 Series */
+/*  */
+#define		RF6052_MAX_TX_PWR			0x3F
+#define		RF6052_MAX_REG				0x3F
+#define		RF6052_MAX_PATH				2
+/*--------------------------Define Parameters-------------------------=
------*/
+
+
+/*------------------------------Define structure----------------------=
------*/
+
+/*------------------------------Define structure----------------------=
------*/
+
+
+/*------------------------Export global variable----------------------=
------*/
+/*------------------------Export global variable----------------------=
------*/
+
+/*------------------------Export Marco Definition---------------------=
------*/
+
+/*------------------------Export Marco Definition---------------------=
------*/
+
+
+/*--------------------------Exported Function prototype---------------=
------*/
+
+/*  */
+/*  RF RL6052 Series API */
+/*  */
+void rtl8723a_phy_rf6052set_bw(struct rtw_adapter *Adapter,
+			       enum ht_channel_width Bandwidth);
+void rtl823a_phy_rf6052setccktxpower(struct rtw_adapter *Adapter,
+				      u8* pPowerlevel);
+void rtl8723a_PHY_RF6052SetOFDMTxPower(struct rtw_adapter *Adapter,
+				       u8* pPowerLevel, u8 Channel);
+
+/*--------------------------Exported Function prototype---------------=
------*/
+
+int	PHY_RF6052_Config8723A(struct rtw_adapter *Adapter);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtl8723a_spec.h b/driver=
s/staging/rtl8723au/include/rtl8723a_spec.h
new file mode 100644
index 0000000..3595c27
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtl8723a_spec.h
@@ -0,0 +1,2158 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
**********/
+#ifndef __RTL8723A_SPEC_H__
+#define __RTL8723A_SPEC_H__
+
+/*  */
+/*  */
+/*	0x0000h ~ 0x00FFh	System Configuration */
+/*  */
+/*  */
+#define REG_SYS_ISO_CTRL		0x0000
+#define REG_SYS_FUNC_EN			0x0002
+#define REG_APS_FSMCO			0x0004
+#define REG_SYS_CLKR			0x0008
+#define REG_9346CR			0x000A
+#define REG_EE_VPD			0x000C
+#define REG_AFE_MISC			0x0010
+#define REG_SPS0_CTRL			0x0011
+#define REG_SPS_OCP_CFG			0x0018
+#define REG_RSV_CTRL			0x001C
+#define REG_RF_CTRL			0x001F
+#define REG_LDOA15_CTRL			0x0020
+#define REG_LDOV12D_CTRL		0x0021
+#define REG_LDOHCI12_CTRL		0x0022
+#define REG_LPLDO_CTRL			0x0023
+#define REG_AFE_XTAL_CTRL		0x0024
+#define REG_AFE_PLL_CTRL		0x0028
+#define REG_MAC_PHY_CTRL		0x002c
+#define REG_EFUSE_CTRL			0x0030
+#define REG_EFUSE_TEST			0x0034
+#define REG_PWR_DATA			0x0038
+#define REG_CAL_TIMER			0x003C
+#define REG_ACLK_MON			0x003E
+#define REG_GPIO_MUXCFG			0x0040
+#define REG_GPIO_IO_SEL			0x0042
+#define REG_MAC_PINMUX_CFG		0x0043
+#define REG_GPIO_PIN_CTRL		0x0044
+#define REG_GPIO_INTM			0x0048
+#define REG_LEDCFG0			0x004C
+#define REG_LEDCFG1			0x004D
+#define REG_LEDCFG2			0x004E
+#define REG_LEDCFG3			0x004F
+#define REG_LEDCFG			REG_LEDCFG2
+#define REG_FSIMR			0x0050
+#define REG_FSISR			0x0054
+#define REG_HSIMR			0x0058
+#define REG_HSISR			0x005c
+ /*  RTL8723 WIFI/BT/GPS Multi-Function GPIO Pin Control. */
+#define REG_GPIO_PIN_CTRL_2		0x0060
+ /*  RTL8723 WIFI/BT/GPS Multi-Function GPIO Select. */
+#define REG_GPIO_IO_SEL_2		0x0062
+ /*  RTL8723 WIFI/BT/GPS Multi-Function control source. */
+#define REG_MULTI_FUNC_CTRL		0x0068
+#define REG_MCUFWDL			0x0080
+#define REG_HMEBOX_EXT_0		0x0088
+#define REG_HMEBOX_EXT_1		0x008A
+#define REG_HMEBOX_EXT_2		0x008C
+#define REG_HMEBOX_EXT_3		0x008E
+	/*  Host suspend counter on FPGA platform */
+#define REG_HOST_SUSP_CNT		0x00BC
+	/*  Efuse access protection for RTL8723 */
+#define REG_EFUSE_ACCESS		0x00CF
+#define REG_BIST_SCAN			0x00D0
+#define REG_BIST_RPT			0x00D4
+#define REG_BIST_ROM_RPT		0x00D8
+#define REG_USB_SIE_INTF		0x00E0
+#define REG_PCIE_MIO_INTF		0x00E4
+#define REG_PCIE_MIO_INTD		0x00E8
+#define REG_HPON_FSM			0x00EC
+#define REG_SYS_CFG			0x00F0
+#define REG_GPIO_OUTSTS			0x00F4	/*  For RTL8723 only. */
+
+/*  */
+/*  */
+/*	0x0100h ~ 0x01FFh	MACTOP General Configuration */
+/*  */
+/*  */
+#define REG_CR				0x0100
+#define REG_PBP				0x0104
+#define REG_TRXDMA_CTRL			0x010C
+#define REG_TRXFF_BNDY			0x0114
+#define REG_TRXFF_STATUS		0x0118
+#define REG_RXFF_PTR			0x011C
+#define REG_HIMR			0x0120
+#define REG_HISR			0x0124
+#define REG_HIMRE			0x0128
+#define REG_HISRE			0x012C
+#define REG_CPWM			0x012F
+#define REG_FWIMR			0x0130
+#define REG_FWISR			0x0134
+#define REG_PKTBUF_DBG_CTRL		0x0140
+#define REG_PKTBUF_DBG_DATA_L		0x0144
+#define REG_PKTBUF_DBG_DATA_H		0x0148
+
+#define REG_TC0_CTRL			0x0150
+#define REG_TC1_CTRL			0x0154
+#define REG_TC2_CTRL			0x0158
+#define REG_TC3_CTRL			0x015C
+#define REG_TC4_CTRL			0x0160
+#define REG_TCUNIT_BASE			0x0164
+#define REG_MBIST_START			0x0174
+#define REG_MBIST_DONE			0x0178
+#define REG_MBIST_FAIL			0x017C
+#define REG_C2HEVT_MSG_NORMAL		0x01A0
+#define REG_C2HEVT_CLEAR		0x01AF
+#define REG_C2HEVT_MSG_TEST		0x01B8
+#define REG_MCUTST_1			0x01c0
+#define REG_FMETHR			0x01C8
+#define REG_HMETFR			0x01CC
+#define REG_HMEBOX_0			0x01D0
+#define REG_HMEBOX_1			0x01D4
+#define REG_HMEBOX_2			0x01D8
+#define REG_HMEBOX_3			0x01DC
+
+#define REG_LLT_INIT			0x01E0
+#define REG_BB_ACCEESS_CTRL		0x01E8
+#define REG_BB_ACCESS_DATA		0x01EC
+
+
+/*  */
+/*  */
+/*	0x0200h ~ 0x027Fh	TXDMA Configuration */
+/*  */
+/*  */
+#define REG_RQPN			0x0200
+#define REG_FIFOPAGE			0x0204
+#define REG_TDECTRL			0x0208
+#define REG_TXDMA_OFFSET_CHK		0x020C
+#define REG_TXDMA_STATUS		0x0210
+#define REG_RQPN_NPQ			0x0214
+
+/*  */
+/*  */
+/*	0x0280h ~ 0x02FFh	RXDMA Configuration */
+/*  */
+/*  */
+#define REG_RXDMA_AGG_PG_TH		0x0280
+#define REG_RXPKT_NUM			0x0284
+#define REG_RXDMA_STATUS		0x0288
+
+
+/*  */
+/*  */
+/*	0x0300h ~ 0x03FFh	PCIe */
+/*  */
+/*  */
+#define	REG_PCIE_CTRL_REG		0x0300
+#define	REG_INT_MIG			0x0304	/*  Interrupt Migration */
+	/*  TX Beacon Descriptor Address */
+#define	REG_BCNQ_DESA			0x0308
+	/*  TX High Queue Descriptor Address */
+#define	REG_HQ_DESA			0x0310
+	/*  TX Manage Queue Descriptor Address */
+#define	REG_MGQ_DESA			0x0318
+	/*  TX VO Queue Descriptor Address */
+#define	REG_VOQ_DESA			0x0320
+	/*  TX VI Queue Descriptor Address */
+#define	REG_VIQ_DESA			0x0328
+	/*  TX BE Queue Descriptor Address */
+#define	REG_BEQ_DESA			0x0330
+	/*  TX BK Queue Descriptor Address */
+#define	REG_BKQ_DESA			0x0338
+	/*  RX Queue	Descriptor Address */
+#define	REG_RX_DESA			0x0340
+	/*  Backdoor REG for Access Configuration */
+#define	REG_DBI				0x0348
+	/*  MDIO for Access PCIE PHY */
+#define	REG_MDIO			0x0354
+	/*  Debug Selection Register */
+#define	REG_DBG_SEL			0x0360
+	/* PCIe RPWM */
+#define	REG_PCIE_HRPWM			0x0361
+	/* PCIe CPWM */
+#define	REG_PCIE_HCPWM			0x0363
+	/*  UART	Control */
+#define	REG_UART_CTRL			0x0364
+	/*  UART TX Descriptor Address */
+#define	REG_UART_TX_DESA		0x0370
+	/*  UART Rx Descriptor Address */
+#define	REG_UART_RX_DESA		0x0378
+
+
+/*  spec version 11 */
+/*  */
+/*  */
+/*	0x0400h ~ 0x047Fh	Protocol Configuration */
+/*  */
+/*  */
+#define REG_VOQ_INFORMATION		0x0400
+#define REG_VIQ_INFORMATION		0x0404
+#define REG_BEQ_INFORMATION		0x0408
+#define REG_BKQ_INFORMATION		0x040C
+#define REG_MGQ_INFORMATION		0x0410
+#define REG_HGQ_INFORMATION		0x0414
+#define REG_BCNQ_INFORMATION		0x0418
+
+
+#define REG_CPU_MGQ_INFORMATION		0x041C
+#define REG_FWHW_TXQ_CTRL		0x0420
+#define REG_HWSEQ_CTRL			0x0423
+#define REG_TXPKTBUF_BCNQ_BDNY		0x0424
+#define REG_TXPKTBUF_MGQ_BDNY		0x0425
+#define REG_LIFETIME_EN			0x0426
+#define REG_MULTI_BCNQ_OFFSET		0x0427
+#define REG_SPEC_SIFS			0x0428
+#define REG_RL				0x042A
+#define REG_DARFRC			0x0430
+#define REG_RARFRC			0x0438
+#define REG_RRSR			0x0440
+#define REG_ARFR0			0x0444
+#define REG_ARFR1			0x0448
+#define REG_ARFR2			0x044C
+#define REG_ARFR3			0x0450
+#define REG_AGGLEN_LMT			0x0458
+#define REG_AMPDU_MIN_SPACE		0x045C
+#define REG_TXPKTBUF_WMAC_LBK_BF_HD	0x045D
+#define REG_FAST_EDCA_CTRL		0x0460
+#define REG_RD_RESP_PKT_TH		0x0463
+#define REG_INIRTS_RATE_SEL		0x0480
+#define REG_INIDATA_RATE_SEL		0x0484
+
+
+#define REG_POWER_STATUS		0x04A4
+#define REG_POWER_STAGE1		0x04B4
+#define REG_POWER_STAGE2		0x04B8
+#define REG_PKT_VO_VI_LIFE_TIME		0x04C0
+#define REG_PKT_BE_BK_LIFE_TIME		0x04C2
+#define REG_STBC_SETTING		0x04C4
+#define REG_PROT_MODE_CTRL		0x04C8
+#define REG_MAX_AGGR_NUM		0x04CA
+#define REG_RTS_MAX_AGGR_NUM		0x04CB
+#define REG_BAR_MODE_CTRL		0x04CC
+#define REG_RA_TRY_RATE_AGG_LMT		0x04CF
+#define REG_NQOS_SEQ			0x04DC
+#define REG_QOS_SEQ			0x04DE
+#define REG_NEED_CPU_HANDLE		0x04E0
+#define REG_PKT_LOSE_RPT		0x04E1
+#define REG_PTCL_ERR_STATUS		0x04E2
+#define REG_DUMMY			0x04FC
+
+
+
+/*  */
+/*  */
+/*	0x0500h ~ 0x05FFh	EDCA Configuration */
+/*  */
+/*  */
+#define REG_EDCA_VO_PARAM		0x0500
+#define REG_EDCA_VI_PARAM		0x0504
+#define REG_EDCA_BE_PARAM		0x0508
+#define REG_EDCA_BK_PARAM		0x050C
+#define REG_BCNTCFG			0x0510
+#define REG_PIFS			0x0512
+#define REG_RDG_PIFS			0x0513
+#define REG_SIFS_CCK			0x0514
+#define REG_SIFS_OFDM			0x0516
+#define REG_SIFS_CTX			0x0514
+#define REG_SIFS_TRX			0x0516
+#define REG_TSFTR_SYN_OFFSET		0x0518
+#define REG_AGGR_BREAK_TIME		0x051A
+#define REG_SLOT			0x051B
+#define REG_TX_PTCL_CTRL		0x0520
+#define REG_TXPAUSE			0x0522
+#define REG_DIS_TXREQ_CLR		0x0523
+#define REG_RD_CTRL			0x0524
+#define REG_TBTT_PROHIBIT		0x0540
+#define REG_RD_NAV_NXT			0x0544
+#define REG_NAV_PROT_LEN		0x0546
+#define REG_BCN_CTRL			0x0550
+#define REG_BCN_CTRL_1			0x0551
+#define REG_MBID_NUM			0x0552
+#define REG_DUAL_TSF_RST		0x0553
+	/*  The same as REG_MBSSID_BCN_SPACE */
+#define REG_BCN_INTERVAL		0x0554
+#define REG_MBSSID_BCN_SPACE		0x0554
+#define REG_DRVERLYINT			0x0558
+#define REG_BCNDMATIM			0x0559
+#define REG_ATIMWND			0x055A
+#define REG_BCN_MAX_ERR			0x055D
+#define REG_RXTSF_OFFSET_CCK		0x055E
+#define REG_RXTSF_OFFSET_OFDM		0x055F
+#define REG_TSFTR			0x0560
+#define REG_TSFTR1			0x0568
+#define REG_INIT_TSFTR			0x0564
+#define REG_ATIMWND_1			0x0570
+#define REG_PSTIMER			0x0580
+#define REG_TIMER0			0x0584
+#define REG_TIMER1			0x0588
+#define REG_ACMHWCTRL			0x05C0
+#define REG_ACMRSTCTRL			0x05C1
+#define REG_ACMAVG			0x05C2
+#define REG_VO_ADMTIME			0x05C4
+#define REG_VI_ADMTIME			0x05C6
+#define REG_BE_ADMTIME			0x05C8
+#define REG_EDCA_RANDOM_GEN		0x05CC
+#define REG_SCH_TXCMD			0x05D0
+
+/* define REG_FW_TSF_SYNC_CNT		0x04A0 */
+#define REG_FW_RESET_TSF_CNT_1		0x05FC
+#define REG_FW_RESET_TSF_CNT_0		0x05FD
+#define REG_FW_BCN_DIS_CNT		0x05FE
+
+/*  */
+/*  */
+/*	0x0600h ~ 0x07FFh	WMAC Configuration */
+/*  */
+/*  */
+#define REG_APSD_CTRL			0x0600
+#define REG_BWOPMODE			0x0603
+#define REG_TCR				0x0604
+#define REG_RCR				0x0608
+#define REG_RX_PKT_LIMIT		0x060C
+#define REG_RX_DLK_TIME			0x060D
+#define REG_RX_DRVINFO_SZ		0x060F
+
+#define REG_MACID			0x0610
+#define REG_BSSID			0x0618
+#define REG_MAR				0x0620
+#define REG_MBIDCAMCFG			0x0628
+
+#define REG_USTIME_EDCA			0x0638
+#define REG_MAC_SPEC_SIFS		0x063A
+
+/*  20100719 Joseph: Hardware register definition change. (HW datashee=
t v54) */
+	/*  [15:8]SIFS_R2T_OFDM, [7:0]SIFS_R2T_CCK */
+#define REG_R2T_SIFS			0x063C
+	/*  [15:8]SIFS_T2T_OFDM, [7:0]SIFS_T2T_CCK */
+#define REG_T2T_SIFS			0x063E
+#define REG_ACKTO			0x0640
+#define REG_CTS2TO			0x0641
+#define REG_EIFS			0x0642
+
+/* WMA, BA, CCX */
+#define REG_NAV_CTRL			0x0650
+#define REG_BACAMCMD			0x0654
+#define REG_BACAMCONTENT		0x0658
+#define REG_LBDLY			0x0660
+#define REG_FWDLY			0x0661
+#define REG_RXERR_RPT			0x0664
+#define REG_WMAC_TRXPTCL_CTL		0x0668
+
+
+/*  Security */
+#define REG_CAMCMD			0x0670
+#define REG_CAMWRITE			0x0674
+#define REG_CAMREAD			0x0678
+#define REG_CAMDBG			0x067C
+#define REG_SECCFG			0x0680
+
+/*  Power */
+#define REG_WOW_CTRL			0x0690
+#define REG_PSSTATUS			0x0691
+#define REG_PS_RX_INFO			0x0692
+#define REG_LPNAV_CTRL			0x0694
+#define REG_WKFMCAM_CMD			0x0698
+#define REG_WKFMCAM_RWD			0x069C
+#define REG_RXFLTMAP0			0x06A0
+#define REG_RXFLTMAP1			0x06A2
+#define REG_RXFLTMAP2			0x06A4
+#define REG_BCN_PSR_RPT			0x06A8
+#define REG_CALB32K_CTRL		0x06AC
+#define REG_PKT_MON_CTRL		0x06B4
+#define REG_BT_COEX_TABLE		0x06C0
+#define REG_WMAC_RESP_TXINFO		0x06D8
+
+#define REG_MACID1			0x0700
+#define REG_BSSID1			0x0708
+
+
+/*  */
+/*  */
+/*	0xFE00h ~ 0xFE55h	USB Configuration */
+/*  */
+/*  */
+#define REG_USB_INFO			0xFE17
+#define REG_USB_SPECIAL_OPTION		0xFE55
+#define REG_USB_DMA_AGG_TO		0xFE5B
+#define REG_USB_AGG_TO			0xFE5C
+#define REG_USB_AGG_TH			0xFE5D
+
+/*  For test chip */
+#define REG_TEST_USB_TXQS		0xFE48
+#define REG_TEST_SIE_VID		0xFE60		/*  0xFE60~0xFE61 */
+#define REG_TEST_SIE_PID		0xFE62		/*  0xFE62~0xFE63 */
+#define REG_TEST_SIE_OPTIONAL		0xFE64
+#define REG_TEST_SIE_CHIRP_K		0xFE65
+#define REG_TEST_SIE_PHY		0xFE66		/*  0xFE66~0xFE6B */
+#define REG_TEST_SIE_MAC_ADDR		0xFE70		/*  0xFE70~0xFE75 */
+#define REG_TEST_SIE_STRING		0xFE80		/*  0xFE80~0xFEB9 */
+
+
+/*  For normal chip */
+#define REG_NORMAL_SIE_VID		0xFE60		/*  0xFE60~0xFE61 */
+#define REG_NORMAL_SIE_PID		0xFE62		/*  0xFE62~0xFE63 */
+#define REG_NORMAL_SIE_OPTIONAL		0xFE64
+#define REG_NORMAL_SIE_EP		0xFE65		/*  0xFE65~0xFE67 */
+#define REG_NORMAL_SIE_PHY		0xFE68		/*  0xFE68~0xFE6B */
+#define REG_NORMAL_SIE_OPTIONAL2	0xFE6C
+#define REG_NORMAL_SIE_GPS_EP		0xFE6D		/*  RTL8723 only */
+#define REG_NORMAL_SIE_MAC_ADDR		0xFE70		/*  0xFE70~0xFE75 */
+#define REG_NORMAL_SIE_STRING		0xFE80		/*  0xFE80~0xFEDF */
+
+
+/*  */
+/*  */
+/*	Redifine 8192C register definition for compatibility */
+/*  */
+/*  */
+
+/*  TODO: use these definition when using REG_xxx naming rule. */
+/*  NOTE: DO NOT Remove these definition. Use later. */
+
+	/*  System Isolation Interface Control. */
+#define	SYS_ISO_CTRL			REG_SYS_ISO_CTRL
+	/*  System Function Enable. */
+#define	SYS_FUNC_EN			REG_SYS_FUNC_EN
+#define	SYS_CLK				REG_SYS_CLKR
+	/*  93C46/93C56 Command Register. */
+#define	CR9346				REG_9346CR
+	/*  E-Fuse Control. */
+#define	EFUSE_CTRL			REG_EFUSE_CTRL
+	/*  E-Fuse Test. */
+#define	EFUSE_TEST			REG_EFUSE_TEST
+	/*  Media Status register */
+#define	MSR				(REG_CR + 2)
+#define	ISR				REG_HISR
+	/*  Timing Sync Function Timer Register. */
+#define	TSFR				REG_TSFTR
+
+	/*  MAC ID Register, Offset 0x0050-0x0053 */
+#define	MACIDR0				REG_MACID
+	/*  MAC ID Register, Offset 0x0054-0x0055 */
+#define	MACIDR4				(REG_MACID + 4)
+
+#define	PBP				REG_PBP
+
+	/*  Redifine MACID register, to compatible prior ICs. */
+#define	IDR0				MACIDR0
+#define	IDR4				MACIDR4
+
+
+/*  */
+/*  9. Security Control Registers	(Offset: ) */
+/*  */
+	/* IN 8190 Data Sheet is called CAMcmd */
+#define	RWCAM				REG_CAMCMD
+	/*  Software write CAM input content */
+#define	WCAMI				REG_CAMWRITE
+	/*  Software read/write CAM config */
+#define	RCAMO				REG_CAMREAD
+#define	CAMDBG				REG_CAMDBG
+	/* Security Configuration Register */
+#define	SECR				REG_SECCFG
+
+/*  Unused register */
+#define	UnusedRegister			0x1BF
+#define	DCAM				UnusedRegister
+#define	PSR				UnusedRegister
+#define	BBAddr				UnusedRegister
+#define	PhyDataR			UnusedRegister
+
+#define	InvalidBBRFValue		0x12345678
+
+/*  Min Spacing related settings. */
+#define	MAX_MSS_DENSITY_2T		0x13
+#define	MAX_MSS_DENSITY_1T		0x0A
+
+/*  */
+/* 8192C Cmd9346CR bits			(Offset 0xA, 16bit) */
+/*  */
+	 /*  EEPROM enable when set 1 */
+#define	CmdEEPROM_En			BIT5
+	/*  System EEPROM select, 0: boot from E-FUSE,
+	    1: The EEPROM used is 9346 */
+#define	CmdEERPOMSEL			BIT4
+#define	Cmd9346CR_9356SEL		BIT4
+#define	AutoLoadEEPROM			(CmdEEPROM_En|CmdEERPOMSEL)
+#define	AutoLoadEFUSE			CmdEEPROM_En
+
+/*  */
+/* 8192C GPIO MUX Configuration Register (offset 0x40, 4 byte) */
+/*  */
+#define	GPIOSEL_GPIO			0
+#define	GPIOSEL_ENBT			BIT5
+
+/*  */
+/*        8192C GPIO PIN Control Register (offset 0x44, 4 byte) */
+/*  */
+	/*  GPIO pins input value */
+#define	GPIO_IN				REG_GPIO_PIN_CTRL
+	/*  GPIO pins output value */
+#define	GPIO_OUT			(REG_GPIO_PIN_CTRL+1)
+	/*  GPIO pins output enable when a bit is set to "1";
+	    otherwise, input is configured. */
+#define	GPIO_IO_SEL			(REG_GPIO_PIN_CTRL+2)
+#define	GPIO_MOD			(REG_GPIO_PIN_CTRL+3)
+
+/*  */
+/* 8192C (MSR) Media Status Register	(Offset 0x4C, 8 bits) */
+/*  */
+/*
+Network Type
+00: No link
+01: Link in ad hoc network
+10: Link in infrastructure network
+11: AP mode
+Default: 00b.
+*/
+#define	MSR_NOLINK			0x00
+#define	MSR_ADHOC			0x01
+#define	MSR_INFRA			0x02
+#define	MSR_AP				0x03
+
+/*  */
+/*  6. Adaptive Control Registers  (Offset: 0x0160 - 0x01CF) */
+/*  */
+/*  */
+/* 8192C Response Rate Set Register	(offset 0x181, 24bits) */
+/*  */
+#define	RRSR_RSC_OFFSET			21
+#define	RRSR_SHORT_OFFSET		23
+#define	RRSR_RSC_BW_40M			0x600000
+#define	RRSR_RSC_UPSUBCHNL		0x400000
+#define	RRSR_RSC_LOWSUBCHNL		0x200000
+#define	RRSR_SHORT			0x800000
+#define	RRSR_1M				BIT0
+#define	RRSR_2M				BIT1
+#define	RRSR_5_5M			BIT2
+#define	RRSR_11M			BIT3
+#define	RRSR_6M				BIT4
+#define	RRSR_9M				BIT5
+#define	RRSR_12M			BIT6
+#define	RRSR_18M			BIT7
+#define	RRSR_24M			BIT8
+#define	RRSR_36M			BIT9
+#define	RRSR_48M			BIT10
+#define	RRSR_54M			BIT11
+#define	RRSR_MCS0			BIT12
+#define	RRSR_MCS1			BIT13
+#define	RRSR_MCS2			BIT14
+#define	RRSR_MCS3			BIT15
+#define	RRSR_MCS4			BIT16
+#define	RRSR_MCS5			BIT17
+#define	RRSR_MCS6			BIT18
+#define	RRSR_MCS7			BIT19
+#define	BRSR_AckShortPmb		BIT23
+/*  CCK ACK: use Short Preamble or not */
+
+/*  */
+/* 8192C BW_OPMODE bits			(Offset 0x203, 8bit) */
+/*  */
+#define	BW_OPMODE_20MHZ			BIT2
+#define	BW_OPMODE_5G			BIT1
+#define	BW_OPMODE_11J			BIT0
+
+
+/*  */
+/* 8192C CAM Config Setting (offset 0x250, 1 byte) */
+/*  */
+#define	CAM_VALID			BIT15
+#define	CAM_NOTVALID			0x0000
+#define	CAM_USEDK			BIT5
+
+#define	CAM_CONTENT_COUNT		8
+
+#define	CAM_NONE			0x0
+#define	CAM_WEP40			0x01
+#define	CAM_TKIP			0x02
+#define	CAM_AES				0x04
+#define	CAM_WEP104			0x05
+
+#define	TOTAL_CAM_ENTRY			32
+#define	HALF_CAM_ENTRY			16
+
+#define	CAM_CONFIG_USEDK		true
+#define	CAM_CONFIG_NO_USEDK		false
+
+#define	CAM_WRITE			BIT16
+#define	CAM_READ			0x00000000
+#define	CAM_POLLINIG			BIT31
+
+#define	SCR_UseDK			0x01
+#define	SCR_TxSecEnable			0x02
+#define	SCR_RxSecEnable			0x04
+
+
+/*  */
+/*  12. Host Interrupt Status Registers	 (Offset: 0x0300 - 0x030F) */
+/*  */
+/*  */
+/* 8190 IMR/ISR bits			(offset 0xfd,  8bits) */
+/*  */
+#define	IMR8190_DISABLED		0x0
+/*  IMR DW0 Bit 0-31 */
+
+#define	IMR_BCNDMAINT6			BIT31	/*  Beacon DMA Interrupt 6 */
+#define	IMR_BCNDMAINT5			BIT30	/*  Beacon DMA Interrupt 5 */
+#define	IMR_BCNDMAINT4			BIT29	/*  Beacon DMA Interrupt 4 */
+#define	IMR_BCNDMAINT3			BIT28	/*  Beacon DMA Interrupt 3 */
+#define	IMR_BCNDMAINT2			BIT27	/*  Beacon DMA Interrupt 2 */
+#define	IMR_BCNDMAINT1			BIT26	/*  Beacon DMA Interrupt 1 */
+#define	IMR_BCNDOK8			BIT25	/*  Beacon Queue DMA OK
+						    Interrupt 8 */
+#define	IMR_BCNDOK7			BIT24	/*  Beacon Queue DMA OK
+						    Interrupt 7 */
+#define	IMR_BCNDOK6			BIT23	/*  Beacon Queue DMA OK
+						    Interrupt 6 */
+#define	IMR_BCNDOK5			BIT22	/*  Beacon Queue DMA OK
+						    Interrupt 5 */
+#define	IMR_BCNDOK4			BIT21	/*  Beacon Queue DMA OK
+						    Interrupt 4 */
+#define	IMR_BCNDOK3			BIT20	/*  Beacon Queue DMA OK
+						    Interrupt 3 */
+#define	IMR_BCNDOK2			BIT19	/*  Beacon Queue DMA OK
+						    Interrupt 2 */
+#define	IMR_BCNDOK1			BIT18	/*  Beacon Queue DMA OK
+						    Interrupt 1 */
+#define	IMR_TIMEOUT2			BIT17	/*  Timeout interrupt 2 */
+#define	IMR_TIMEOUT1			BIT16	/*  Timeout interrupt 1 */
+#define	IMR_TXFOVW			BIT15	/*  Transmit FIFO Overflow */
+#define	IMR_PSTIMEOUT			BIT14	/*  Power save time out
+						    interrupt */
+#define	IMR_BcnInt			BIT13	/*  Beacon DMA Interrupt 0 */
+#define	IMR_RXFOVW			BIT12	/*  Receive FIFO Overflow */
+#define	IMR_RDU				BIT11	/*  Receive Descriptor
+						    Unavailable */
+#define	IMR_ATIMEND			BIT10	/*  For 92C,ATIM Window
+						    End Interrupt */
+#define	IMR_BDOK			BIT9	/*  Beacon Queue DMA OK
+						    Interrup */
+#define	IMR_HIGHDOK			BIT8	/*  High Queue DMA OK
+						    Interrupt */
+#define	IMR_TBDOK			BIT7	/*  Transmit Beacon OK
+						    interrup */
+#define	IMR_MGNTDOK			BIT6	/*  Management Queue DMA OK
+						    Interrupt */
+#define	IMR_TBDER			BIT5	/*  For 92C,Transmit Beacon
+						    Error Interrupt */
+#define	IMR_BKDOK			BIT4	/*  AC_BK DMA OK Interrupt */
+#define	IMR_BEDOK			BIT3	/*  AC_BE DMA OK Interrupt */
+#define	IMR_VIDOK			BIT2	/*  AC_VI DMA OK Interrupt */
+#define	IMR_VODOK			BIT1	/*  AC_VO DMA Interrupt */
+#define	IMR_ROK				BIT0	/*  Receive DMA OK Interrupt */
+
+#define	IMR_RX_MASK			(IMR_ROK|IMR_RDU|IMR_RXFOVW)
+#define	IMR_TX_MASK			(IMR_VODOK|IMR_VIDOK|IMR_BEDOK| \
+					 IMR_BKDOK|IMR_MGNTDOK|IMR_HIGHDOK| \
+					 IMR_BDOK)
+
+/*  13. Host Interrupt Status Extension Register (Offset: 0x012C-012Eh=
) */
+#define	IMR_BcnInt_E			BIT12
+#define	IMR_TXERR			BIT11
+#define	IMR_RXERR			BIT10
+#define	IMR_C2HCMD			BIT9
+#define	IMR_CPWM			BIT8
+/* RSVD [2-7] */
+#define	IMR_OCPINT			BIT1
+#define	IMR_WLANOFF			BIT0
+
+
+/*        8192C EEPROM/EFUSE share register definition. */
+
+/*  Default Value for EEPROM or EFUSE!!! */
+#define EEPROM_Default_TSSI			0x0
+#define EEPROM_Default_TxPowerDiff		0x0
+#define EEPROM_Default_CrystalCap		0x5
+ /*  Default: 2X2, RTL8192CE(QFPN68) */
+#define EEPROM_Default_BoardType		0x02
+#define EEPROM_Default_TxPower			0x1010
+#define EEPROM_Default_HT2T_TxPwr		0x10
+
+#define EEPROM_Default_LegacyHTTxPowerDiff	0x3
+#define EEPROM_Default_ThermalMeter		0x12
+
+#define EEPROM_Default_AntTxPowerDiff		0x0
+#define EEPROM_Default_TxPwDiff_CrystalCap	0x5
+#define EEPROM_Default_TxPowerLevel		0x22
+#define EEPROM_Default_HT40_2SDiff		0x0
+	/*  HT20<->40 default Tx Power Index Difference */
+#define EEPROM_Default_HT20_Diff		2
+#define EEPROM_Default_LegacyHTTxPowerDiff	0x3
+#define EEPROM_Default_HT40_PwrMaxOffset	0
+#define EEPROM_Default_HT20_PwrMaxOffset	0
+
+/*  For debug */
+#define EEPROM_Default_PID			0x1234
+#define EEPROM_Default_VID			0x5678
+#define EEPROM_Default_CustomerID		0xAB
+#define EEPROM_Default_SubCustomerID		0xCD
+#define EEPROM_Default_Version			0
+
+#define EEPROM_CHANNEL_PLAN_FCC			0x0
+#define EEPROM_CHANNEL_PLAN_IC			0x1
+#define EEPROM_CHANNEL_PLAN_ETSI		0x2
+#define EEPROM_CHANNEL_PLAN_SPAIN		0x3
+#define EEPROM_CHANNEL_PLAN_FRANCE		0x4
+#define EEPROM_CHANNEL_PLAN_MKK			0x5
+#define EEPROM_CHANNEL_PLAN_MKK1		0x6
+#define EEPROM_CHANNEL_PLAN_ISRAEL		0x7
+#define EEPROM_CHANNEL_PLAN_TELEC		0x8
+#define EEPROM_CHANNEL_PLAN_GLOBAL_DOMAIN	0x9
+#define EEPROM_CHANNEL_PLAN_WORLD_WIDE_13	0xA
+#define EEPROM_CHANNEL_PLAN_NCC			0xB
+#define EEPROM_USB_OPTIONAL1			0xE
+#define EEPROM_CHANNEL_PLAN_BY_HW_MASK		0x80
+
+
+#define EEPROM_CID_DEFAULT			0x0
+#define EEPROM_CID_TOSHIBA			0x4
+ /*  CCX test. By Bruce, 2009-02-25. */
+#define EEPROM_CID_CCX				0x10
+#define EEPROM_CID_QMI				0x0D
+ /*  added by chiyoko for dtm, 20090108 */
+#define EEPROM_CID_WHQL				0xFE
+
+
+#define	RTL_EEPROM_ID				0x8129
+
+#define	SUPPORT_HW_RADIO_DETECT(pHalData)		\
+	(pHalData->BoardType =3D=3D BOARD_MINICARD ||	\
+	pHalData->BoardType =3D=3D BOARD_USB_SOLO ||	\
+	pHalData->BoardType =3D=3D BOARD_USB_COMBO)
+
+/*  */
+/*  EEPROM address for Test chip */
+/*  */
+#define EEPROM_TEST_USB_OPT		0x0E
+#define EEPROM_TEST_CHIRP_K		0x0F
+#define EEPROM_TEST_EP_SETTING		0x0E
+#define EEPROM_TEST_USB_PHY		0x10
+
+
+/*  */
+/*  EEPROM address for Normal chip */
+/*  */
+#define EEPROM_NORMAL_USB_OPT		0x0E
+#define EEPROM_NORMAL_CHIRP_K		0x0E	/*  Changed */
+#define EEPROM_NORMAL_EP_SETTING	0x0F	/*  Changed */
+#define EEPROM_NORMAL_USB_PHY		0x12	/*  Changed */
+
+enum {
+	BOARD_USB_DONGLE =3D 0,	/*  USB dongle */
+	BOARD_USB_High_PA =3D 1,	/*  USB dongle with high power PA */
+	BOARD_MINICARD =3D 2,	/*  Minicard */
+	BOARD_USB_SOLO =3D 3,	/*  USB solo-Slim module */
+	BOARD_USB_COMBO =3D 4,	/*  USB Combo-Slim module */
+};
+
+/*  Test chip and normal chip common define */
+/*  */
+/*  EEPROM address for both */
+/*  */
+#define EEPROM_ID0			0x00
+#define EEPROM_ID1			0x01
+#define EEPROM_RTK_RSV1			0x02
+#define EEPROM_RTK_RSV2			0x03
+#define EEPROM_RTK_RSV3			0x04
+#define EEPROM_RTK_RSV4			0x05
+#define EEPROM_RTK_RSV5			0x06
+#define EEPROM_DBG_SEL			0x07
+#define EEPROM_RTK_RSV6			0x08
+#define EEPROM_VID			0x0A
+#define EEPROM_PID			0x0C
+
+#define EEPROM_MAC_ADDR			0x16
+#define EEPROM_STRING			0x1C
+#define EEPROM_SUBCUSTOMER_ID		0x59
+#define EEPROM_CCK_TX_PWR_INX		0x5A
+#define EEPROM_HT40_1S_TX_PWR_INX	0x60
+#define EEPROM_HT40_2S_TX_PWR_INX_DIFF	0x66
+#define EEPROM_HT20_TX_PWR_INX_DIFF	0x69
+#define EEPROM_OFDM_TX_PWR_INX_DIFF	0x6C
+#define EEPROM_HT40_MAX_PWR_OFFSET	0x6F
+#define EEPROM_HT20_MAX_PWR_OFFSET	0x72
+
+#define EEPROM_CHANNEL_PLAN		0x75
+#define EEPROM_TSSI_A			0x76
+#define EEPROM_TSSI_B			0x77
+#define EEPROM_THERMAL_METER		0x78
+#define EEPROM_RF_OPT1			0x79
+#define EEPROM_RF_OPT2			0x7A
+#define EEPROM_RF_OPT3			0x7B
+#define EEPROM_RF_OPT4			0x7C
+#define EEPROM_VERSION			0x7E
+#define EEPROM_CUSTOMER_ID		0x7F
+
+	 /* 0x0: RTL8188SU, 0x1: RTL8191SU, 0x2: RTL8192SU, 0x3: RTL8191GU */
+#define EEPROM_BoardType		0x54
+	/* 0x5C-0x76, Tx Power index. */
+#define EEPROM_TxPwIndex		0x5C
+	/*  Difference of gain index between legacy and high throughput OFDM.=
 */
+#define EEPROM_PwDiff			0x67
+	/*  CCK Tx Power */
+#define EEPROM_TxPowerCCK		0x5A
+
+/*  2009/02/09 Cosa Add for SD3 requirement */
+	/*  HT20 Tx Power Index Difference */
+#define EEPROM_TX_PWR_HT20_DIFF		0x6e
+	/*  HT20<->40 default Tx Power Index Difference */
+#define DEFAULT_HT20_TXPWR_DIFF		2
+	/*  OFDM Tx Power Index Difference */
+#define EEPROM_TX_PWR_OFDM_DIFF		0x71
+
+	/*  Power diff for channel group */
+#define EEPROM_TxPWRGroup		0x73
+	/*  Check if power safety is need */
+#define EEPROM_Regulatory		0x79
+
+	/*  92cu, 0x7E[4] */
+#define EEPROM_BLUETOOTH_COEXIST	0x7E
+#define EEPROM_NORMAL_BoardType		EEPROM_RF_OPT1	/* 7:5] */
+#define BOARD_TYPE_NORMAL_MASK		0xE0
+#define BOARD_TYPE_TEST_MASK		0x0F
+	/* BIT0 1 for build-in module, 0 for external dongle */
+#define EEPROM_EASY_REPLACEMENT		0x50
+/*  */
+/* EPROM content definitions */
+/*  */
+#define OS_LINK_SPEED			BIT(5)
+
+#define BOARD_TYPE_MASK			0xF
+
+#define BT_COEXISTENCE			BIT(4)
+#define BT_CO_SHIFT			4
+
+#define EP_NUMBER_MASK			0x30	/* bit 4:5 0Eh */
+#define EP_NUMBER_SHIFT			4
+
+
+#define USB_PHY_PARA_SIZE		5
+
+
+/*  */
+/*	=14EEPROM default value definitions */
+/*  */
+/*  Use 0xABCD instead of 0x8192 for debug */
+#define EEPROM_DEF_ID_0			0xCD	/*  Byte 0x00 */
+#define EEPROM_DEF_ID_1			0xAB	/*  Byte 0x01 */
+
+#define EEPROM_DEF_RTK_RSV_A3		0x74	/*  Byte 0x03 */
+#define EEPROM_DEF_RTK_RSV_A4		0x6D	/*  Byte 0x04 */
+#define EEPROM_DEF_RTK_RSV_A8		0xFF	/*  Byte 0x08 */
+
+#define EEPROM_DEF_VID_0		0x0A	/*  Byte 0x0A */
+#define EEPROM_DEF_VID_1		0x0B
+
+#define EEPROM_DEF_PID_0		0x92	/*  Byte 0x0C */
+#define EEPROM_DEF_PID_1		0x81
+
+
+#define EEPROM_TEST_DEF_USB_OPT		0x80	/*  Byte 0x0E */
+#define EEPROM_NORMAL_DEF_USB_OPT	0x00	/*  Byte 0x0E */
+
+#define EEPROM_DEF_CHIRPK		0x15	/*  Byte 0x0F */
+
+#define EEPROM_DEF_USB_PHY_0		0x85	/*  Byte 0x10 */
+#define EEPROM_DEF_USB_PHY_1		0x62	/*  Byte 0x11 */
+#define EEPROM_DEF_USB_PHY_2		0x9E	/*  Byte 0x12 */
+#define EEPROM_DEF_USB_PHY_3		0x06	/*  Byte 0x13 */
+
+#define EEPROM_DEF_TSSI_A		0x09	/*  Byte 0x78 */
+#define EEPROM_DEF_TSSI_B		0x09	/*  Byte 0x79 */
+
+
+#define EEPROM_DEF_THERMAL_METER	0x12	/*  Byte 0x7A */
+
+	/*  Check if power safety spec is need */
+#define RF_OPTION1			0x79
+#define RF_OPTION2			0x7A
+#define RF_OPTION3			0x7B
+#define RF_OPTION4			0x7C
+
+
+#define	EEPROM_USB_SN			BIT(0)
+#define	EEPROM_USB_REMOTE_WAKEUP	BIT(1)
+#define	EEPROM_USB_DEVICE_PWR		BIT(2)
+#define	EEPROM_EP_NUMBER		(BIT(3)|BIT(4))
+
+/*=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+Here the register defines are for 92C. When the define is as same with=
 92C,
+we will use the 92C's define for the consistency
+So the following defines for 92C is not entire!!!!!!
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D*/
+/*
+Based on Datasheet V33---090401
+Register Summary
+Current IOREG MAP
+0x0000h ~ 0x00FFh   System Configuration (256 Bytes)
+0x0100h ~ 0x01FFh   MACTOP General Configuration (256 Bytes)
+0x0200h ~ 0x027Fh   TXDMA Configuration (128 Bytes)
+0x0280h ~ 0x02FFh   RXDMA Configuration (128 Bytes)
+0x0300h ~ 0x03FFh   PCIE EMAC Reserved Region (256 Bytes)
+0x0400h ~ 0x04FFh   Protocol Configuration (256 Bytes)
+0x0500h ~ 0x05FFh   EDCA Configuration (256 Bytes)
+0x0600h ~ 0x07FFh   WMAC Configuration (512 Bytes)
+0x2000h ~ 0x3FFFh   8051 FW Download Region (8196 Bytes)
+*/
+
+/*  */
+/* 8192C (RCR) Receive Configuration Register	(Offset 0x608, 32 bits) =
*/
+/*  */
+#define	RCR_APPFCS			BIT31 /* WMAC append FCS after payload*/
+#define	RCR_APP_MIC			BIT30
+#define	RCR_APP_PHYSTS			BIT28
+#define	RCR_APP_ICV			BIT29
+#define	RCR_APP_PHYST_RXFF		BIT28
+#define	RCR_APP_BA_SSN			BIT27 /* Accept BA SSN */
+#define	RCR_ENMBID			BIT24 /* Enable Multiple BssId. */
+#define	RCR_LSIGEN			BIT23
+#define	RCR_MFBEN			BIT22
+#define	RCR_HTC_LOC_CTRL		BIT14 /* MFC<--HTC=3D1 MFC-->HTC=3D0 */
+#define	RCR_AMF				BIT13 /* Accept management type frame */
+#define	RCR_ACF				BIT12 /* Accept control type frame */
+#define	RCR_ADF				BIT11 /* Accept data type frame */
+#define	RCR_AICV			BIT9  /* Accept ICV error packet */
+#define	RCR_ACRC32			BIT8  /* Accept CRC32 error packet */
+#define	RCR_CBSSID_BCN			BIT7  /* Accept BSSID match packet
+						 (Rx beacon, probe rsp) */
+#define	RCR_CBSSID_DATA			BIT6  /* Accept BSSID match packet
+						 (Data) */
+#define	RCR_CBSSID			RCR_CBSSID_DATA	/* Accept BSSID match
+							   packet */
+#define	RCR_APWRMGT			BIT5  /* Accept power management
+						 packet */
+#define	RCR_ADD3			BIT4  /* Accept address 3 match
+						 packet */
+#define	RCR_AB				BIT3  /* Accept broadcast packet */
+#define	RCR_AM				BIT2  /* Accept multicast packet */
+#define	RCR_APM				BIT1  /* Accept physical match packet */
+#define	RCR_AAP				BIT0  /* Accept all unicast packet */
+#define	RCR_MXDMA_OFFSET		8
+#define	RCR_FIFO_OFFSET			13
+
+
+
+/*  */
+/* 8192c USB specific Regsiter Offset and Content definition, */
+/* 2009.08.18, added by vivi. for merge 92c and 92C into one driver */
+/*  */
+/* define APS_FSMCO			0x0004  same with 92Ce */
+#define RSV_CTRL			0x001C
+#define RD_CTRL				0x0524
+
+/*  */
+/*  */
+/*	0xFE00h ~ 0xFE55h	USB Configuration */
+/*  */
+/*  */
+#define REG_USB_INFO			0xFE17
+#define REG_USB_SPECIAL_OPTION		0xFE55
+#define REG_USB_DMA_AGG_TO		0xFE5B
+#define REG_USB_AGG_TO			0xFE5C
+#define REG_USB_AGG_TH			0xFE5D
+
+#define REG_USB_VID			0xFE60
+#define REG_USB_PID			0xFE62
+#define REG_USB_OPTIONAL		0xFE64
+#define REG_USB_CHIRP_K			0xFE65
+#define REG_USB_PHY			0xFE66
+#define REG_USB_MAC_ADDR		0xFE70
+
+#define REG_USB_HRPWM			0xFE58
+#define REG_USB_HCPWM			0xFE57
+
+#define	InvalidBBRFValue		0x12345678
+
+/*  */
+/*        8192C Regsiter Bit and Content definition */
+/*  */
+/*  */
+/*  */
+/*	0x0000h ~ 0x00FFh	System Configuration */
+/*  */
+/*  */
+
+/* 2 SPS0_CTRL */
+#define SW18_FPWM			BIT(3)
+
+
+/* 2 SYS_ISO_CTRL */
+#define ISO_MD2PP			BIT(0)
+#define ISO_UA2USB			BIT(1)
+#define ISO_UD2CORE			BIT(2)
+#define ISO_PA2PCIE			BIT(3)
+#define ISO_PD2CORE			BIT(4)
+#define ISO_IP2MAC			BIT(5)
+#define ISO_DIOP			BIT(6)
+#define ISO_DIOE			BIT(7)
+#define ISO_EB2CORE			BIT(8)
+#define ISO_DIOR			BIT(9)
+
+#define PWC_EV25V			BIT(14)
+#define PWC_EV12V			BIT(15)
+
+
+/* 2 SYS_FUNC_EN */
+#define FEN_BBRSTB			BIT(0)
+#define FEN_BB_GLB_RSTn			BIT(1)
+#define FEN_USBA			BIT(2)
+#define FEN_UPLL			BIT(3)
+#define FEN_USBD			BIT(4)
+#define FEN_DIO_PCIE			BIT(5)
+#define FEN_PCIEA			BIT(6)
+#define FEN_PPLL			BIT(7)
+#define FEN_PCIED			BIT(8)
+#define FEN_DIOE			BIT(9)
+#define FEN_CPUEN			BIT(10)
+#define FEN_DCORE			BIT(11)
+#define FEN_ELDR			BIT(12)
+#define FEN_DIO_RF			BIT(13)
+#define FEN_HWPDN			BIT(14)
+#define FEN_MREGEN			BIT(15)
+
+/* 2 APS_FSMCO */
+#define PFM_LDALL			BIT(0)
+#define PFM_ALDN			BIT(1)
+#define PFM_LDKP			BIT(2)
+#define PFM_WOWL			BIT(3)
+#define EnPDN				BIT(4)
+#define PDN_PL				BIT(5)
+#define APFM_ONMAC			BIT(8)
+#define APFM_OFF			BIT(9)
+#define APFM_RSM			BIT(10)
+#define AFSM_HSUS			BIT(11)
+#define AFSM_PCIE			BIT(12)
+#define APDM_MAC			BIT(13)
+#define APDM_HOST			BIT(14)
+#define APDM_HPDN			BIT(15)
+#define RDY_MACON			BIT(16)
+#define SUS_HOST			BIT(17)
+#define ROP_ALD				BIT(20)
+#define ROP_PWR				BIT(21)
+#define ROP_SPS				BIT(22)
+#define SOP_MRST			BIT(25)
+#define SOP_FUSE			BIT(26)
+#define SOP_ABG				BIT(27)
+#define SOP_AMB				BIT(28)
+#define SOP_RCK				BIT(29)
+#define SOP_A8M				BIT(30)
+#define XOP_BTCK			BIT(31)
+
+/* 2 SYS_CLKR */
+#define ANAD16V_EN			BIT(0)
+#define ANA8M				BIT(1)
+#define MACSLP				BIT(4)
+#define LOADER_CLK_EN			BIT(5)
+#define _80M_SSC_DIS			BIT(7)
+#define _80M_SSC_EN_HO			BIT(8)
+#define PHY_SSC_RSTB			BIT(9)
+#define SEC_CLK_EN			BIT(10)
+#define MAC_CLK_EN			BIT(11)
+#define SYS_CLK_EN			BIT(12)
+#define RING_CLK_EN			BIT(13)
+
+
+/* 2 9346CR */
+
+
+#define		EEDO			BIT(0)
+#define		EEDI			BIT(1)
+#define		EESK			BIT(2)
+#define		EECS			BIT(3)
+/* define	EERPROMSEL		BIT(4) */
+/* define	EEPROM_EN		BIT(5) */
+#define		BOOT_FROM_EEPROM	BIT(4)
+#define		EEPROM_EN		BIT(5)
+#define		EEM0			BIT(6)
+#define		EEM1			BIT(7)
+
+
+/* 2 AFE_MISC */
+#define AFE_BGEN			BIT(0)
+#define AFE_MBEN			BIT(1)
+#define MAC_ID_EN			BIT(7)
+
+
+/* 2 SPS0_CTRL */
+
+
+/* 2 SPS_OCP_CFG */
+
+
+/* 2 RSV_CTRL */
+#define WLOCK_ALL			BIT(0)
+#define WLOCK_00			BIT(1)
+#define WLOCK_04			BIT(2)
+#define WLOCK_08			BIT(3)
+#define WLOCK_40			BIT(4)
+#define R_DIS_PRST_0			BIT(5)
+#define R_DIS_PRST_1			BIT(6)
+#define LOCK_ALL_EN			BIT(7)
+
+/* 2 RF_CTRL */
+#define RF_EN				BIT(0)
+#define RF_RSTB				BIT(1)
+#define RF_SDMRSTB			BIT(2)
+
+
+
+/* 2 LDOA15_CTRL */
+#define LDA15_EN			BIT(0)
+#define LDA15_STBY			BIT(1)
+#define LDA15_OBUF			BIT(2)
+#define LDA15_REG_VOS			BIT(3)
+#define _LDA15_VOADJ(x)			(((x) & 0x7) << 4)
+
+
+
+/* 2 LDOV12D_CTRL */
+#define LDV12_EN			BIT(0)
+#define LDV12_SDBY			BIT(1)
+#define LPLDO_HSM			BIT(2)
+#define LPLDO_LSM_DIS			BIT(3)
+#define _LDV12_VADJ(x)			(((x) & 0xF) << 4)
+
+
+/* 2 AFE_XTAL_CTRL */
+#define XTAL_EN				BIT(0)
+#define XTAL_BSEL			BIT(1)
+#define _XTAL_BOSC(x)			(((x) & 0x3) << 2)
+#define _XTAL_CADJ(x)			(((x) & 0xF) << 4)
+#define XTAL_GATE_USB			BIT(8)
+#define _XTAL_USB_DRV(x)		(((x) & 0x3) << 9)
+#define XTAL_GATE_AFE			BIT(11)
+#define _XTAL_AFE_DRV(x)		(((x) & 0x3) << 12)
+#define XTAL_RF_GATE			BIT(14)
+#define _XTAL_RF_DRV(x)			(((x) & 0x3) << 15)
+#define XTAL_GATE_DIG			BIT(17)
+#define _XTAL_DIG_DRV(x)		(((x) & 0x3) << 18)
+#define XTAL_BT_GATE			BIT(20)
+#define _XTAL_BT_DRV(x)			(((x) & 0x3) << 21)
+#define _XTAL_GPIO(x)			(((x) & 0x7) << 23)
+
+
+#define CKDLY_AFE			BIT(26)
+#define CKDLY_USB			BIT(27)
+#define CKDLY_DIG			BIT(28)
+#define CKDLY_BT			BIT(29)
+
+
+/* 2 AFE_PLL_CTRL */
+#define APLL_EN				BIT(0)
+#define APLL_320_EN			BIT(1)
+#define APLL_FREF_SEL			BIT(2)
+#define APLL_EDGE_SEL			BIT(3)
+#define APLL_WDOGB			BIT(4)
+#define APLL_LPFEN			BIT(5)
+
+#define APLL_REF_CLK_13MHZ		0x1
+#define APLL_REF_CLK_19_2MHZ		0x2
+#define APLL_REF_CLK_20MHZ		0x3
+#define APLL_REF_CLK_25MHZ		0x4
+#define APLL_REF_CLK_26MHZ		0x5
+#define APLL_REF_CLK_38_4MHZ		0x6
+#define APLL_REF_CLK_40MHZ		0x7
+
+#define APLL_320EN			BIT(14)
+#define APLL_80EN			BIT(15)
+#define APLL_1MEN			BIT(24)
+
+
+/* 2 EFUSE_CTRL */
+#define ALD_EN				BIT(18)
+#define EF_PD				BIT(19)
+#define EF_FLAG				BIT(31)
+
+/* 2 EFUSE_TEST (For RTL8723 partially) */
+#define EF_TRPT				BIT(7)
+	/*  00: Wifi Efuse, 01: BT Efuse0, 10: BT Efuse1, 11: BT Efuse2 */
+#define EF_CELL_SEL			(BIT(8)|BIT(9))
+#define LDOE25_EN			BIT(31)
+#define EFUSE_SEL(x)			(((x) & 0x3) << 8)
+#define EFUSE_SEL_MASK			0x300
+#define EFUSE_WIFI_SEL_0		0x0
+#define EFUSE_BT_SEL_0			0x1
+#define EFUSE_BT_SEL_1			0x2
+#define EFUSE_BT_SEL_2			0x3
+
+#define EFUSE_ACCESS_ON			0x69	/*  For RTL8723 only. */
+#define EFUSE_ACCESS_OFF		0x00	/*  For RTL8723 only. */
+
+/* 2 PWR_DATA */
+
+/* 2 CAL_TIMER */
+
+/* 2 ACLK_MON */
+#define RSM_EN				BIT(0)
+#define Timer_EN			BIT(4)
+
+
+/* 2 GPIO_MUXCFG */
+#define TRSW0EN				BIT(2)
+#define TRSW1EN				BIT(3)
+#define EROM_EN				BIT(4)
+#define EnBT				BIT(5)
+#define EnUart				BIT(8)
+#define Uart_910			BIT(9)
+#define EnPMAC				BIT(10)
+#define SIC_SWRST			BIT(11)
+#define EnSIC				BIT(12)
+#define SIC_23				BIT(13)
+#define EnHDP				BIT(14)
+#define SIC_LBK				BIT(15)
+
+/* 2 GPIO_PIN_CTRL */
+
+/*  GPIO BIT */
+#define HAL_8192C_HW_GPIO_WPS_BIT	BIT(2)
+
+/* 2 GPIO_INTM */
+
+/* 2 LEDCFG */
+#define LED0PL				BIT(4)
+#define LED0DIS				BIT(7)
+#define LED1DIS				BIT(15)
+#define LED1PL				BIT(12)
+
+#define  SECCAM_CLR			BIT(30)
+
+
+/* 2 FSIMR */
+
+/* 2 FSISR */
+
+
+/* 2 8051FWDL */
+/* 2 MCUFWDL */
+#define MCUFWDL_EN			BIT(0)
+#define MCUFWDL_RDY			BIT(1)
+#define FWDL_ChkSum_rpt			BIT(2)
+#define MACINI_RDY			BIT(3)
+#define BBINI_RDY			BIT(4)
+#define RFINI_RDY			BIT(5)
+#define WINTINI_RDY			BIT(6)
+#define CPRST				BIT(23)
+
+/* 2REG_HPON_FSM */
+#define BOND92CE_1T2R_CFG		BIT(22)
+
+
+/* 2 REG_SYS_CFG */
+#define XCLK_VLD			BIT(0)
+#define ACLK_VLD			BIT(1)
+#define UCLK_VLD			BIT(2)
+#define PCLK_VLD			BIT(3)
+#define PCIRSTB				BIT(4)
+#define V15_VLD				BIT(5)
+#define TRP_B15V_EN			BIT(7)
+#define SIC_IDLE			BIT(8)
+#define BD_MAC2				BIT(9)
+#define BD_MAC1				BIT(10)
+#define IC_MACPHY_MODE			BIT(11)
+#define CHIP_VER			(BIT(12)|BIT(13)|BIT(14)|BIT(15))
+#define BT_FUNC				BIT(16)
+#define VENDOR_ID			BIT(19)
+#define PAD_HWPD_IDN			BIT(22)
+#define TRP_VAUX_EN			BIT(23)
+#define TRP_BT_EN			BIT(24)
+#define BD_PKG_SEL			BIT(25)
+#define BD_HCI_SEL			BIT(26)
+#define TYPE_ID				BIT(27)
+
+#define CHIP_VER_RTL_MASK		0xF000	/* Bit 12 ~ 15 */
+#define CHIP_VER_RTL_SHIFT		12
+
+/* 2REG_GPIO_OUTSTS (For RTL8723 only) */
+#define	EFS_HCI_SEL			(BIT(0)|BIT(1))
+#define	PAD_HCI_SEL			(BIT(2)|BIT(3))
+#define	HCI_SEL				(BIT(4)|BIT(5))
+#define	PKG_SEL_HCI			BIT(6)
+#define	FEN_GPS				BIT(7)
+#define	FEN_BT				BIT(8)
+#define	FEN_WL				BIT(9)
+#define	FEN_PCI				BIT(10)
+#define	FEN_USB				BIT(11)
+#define	BTRF_HWPDN_N			BIT(12)
+#define	WLRF_HWPDN_N			BIT(13)
+#define	PDN_BT_N			BIT(14)
+#define	PDN_GPS_N			BIT(15)
+#define	BT_CTL_HWPDN			BIT(16)
+#define	GPS_CTL_HWPDN			BIT(17)
+#define	PPHY_SUSB			BIT(20)
+#define	UPHY_SUSB			BIT(21)
+#define	PCI_SUSEN			BIT(22)
+#define	USB_SUSEN			BIT(23)
+#define	RF_RL_ID			(BIT(31)|BIT(30)|BIT(29)|BIT(28))
+
+/*  */
+/*  */
+/*	0x0100h ~ 0x01FFh	MACTOP General Configuration */
+/*  */
+/*  */
+
+
+/* 2 Function Enable Registers */
+/* 2 CR */
+
+#define REG_LBMODE			(REG_CR + 3)
+
+
+#define HCI_TXDMA_EN			BIT(0)
+#define HCI_RXDMA_EN			BIT(1)
+#define TXDMA_EN			BIT(2)
+#define RXDMA_EN			BIT(3)
+#define PROTOCOL_EN			BIT(4)
+#define SCHEDULE_EN			BIT(5)
+#define MACTXEN				BIT(6)
+#define MACRXEN				BIT(7)
+#define ENSWBCN				BIT(8)
+#define ENSEC				BIT(9)
+
+/*  Network type */
+#define _NETTYPE(x)			(((x) & 0x3) << 16)
+#define MASK_NETTYPE			0x30000
+#define NT_NO_LINK			0x0
+#define NT_LINK_AD_HOC			0x1
+#define NT_LINK_AP			0x2
+#define NT_AS_AP			0x3
+
+#define _LBMODE(x)			(((x) & 0xF) << 24)
+#define MASK_LBMODE			0xF000000
+#define LOOPBACK_NORMAL			0x0
+#define LOOPBACK_IMMEDIATELY		0xB
+#define LOOPBACK_MAC_DELAY		0x3
+#define LOOPBACK_PHY			0x1
+#define LOOPBACK_DMA			0x7
+
+
+/* 2 PBP - Page Size Register */
+#define GET_RX_PAGE_SIZE(value)		((value) & 0xF)
+#define GET_TX_PAGE_SIZE(value)		(((value) & 0xF0) >> 4)
+#define _PSRX_MASK			0xF
+#define _PSTX_MASK			0xF0
+#define _PSRX(x)			(x)
+#define _PSTX(x)			((x) << 4)
+
+#define PBP_64				0x0
+#define PBP_128				0x1
+#define PBP_256				0x2
+#define PBP_512				0x3
+#define PBP_1024			0x4
+
+
+/* 2 TX/RXDMA */
+#define RXDMA_ARBBW_EN			BIT(0)
+#define RXSHFT_EN			BIT(1)
+#define RXDMA_AGG_EN			BIT(2)
+#define QS_VO_QUEUE			BIT(8)
+#define QS_VI_QUEUE			BIT(9)
+#define QS_BE_QUEUE			BIT(10)
+#define QS_BK_QUEUE			BIT(11)
+#define QS_MANAGER_QUEUE		BIT(12)
+#define QS_HIGH_QUEUE			BIT(13)
+
+#define HQSEL_VOQ			BIT(0)
+#define HQSEL_VIQ			BIT(1)
+#define HQSEL_BEQ			BIT(2)
+#define HQSEL_BKQ			BIT(3)
+#define HQSEL_MGTQ			BIT(4)
+#define HQSEL_HIQ			BIT(5)
+
+/*  For normal driver, 0x10C */
+#define _TXDMA_HIQ_MAP(x)		(((x)&0x3) << 14)
+#define _TXDMA_MGQ_MAP(x)		(((x)&0x3) << 12)
+#define _TXDMA_BKQ_MAP(x)		(((x)&0x3) << 10)
+#define _TXDMA_BEQ_MAP(x)		(((x)&0x3) << 8 )
+#define _TXDMA_VIQ_MAP(x)		(((x)&0x3) << 6 )
+#define _TXDMA_VOQ_MAP(x)		(((x)&0x3) << 4 )
+
+#define QUEUE_LOW			1
+#define QUEUE_NORMAL			2
+#define QUEUE_HIGH			3
+
+
+
+/* 2 TRXFF_BNDY */
+
+
+/* 2 LLT_INIT */
+#define _LLT_NO_ACTIVE			0x0
+#define _LLT_WRITE_ACCESS		0x1
+#define _LLT_READ_ACCESS		0x2
+
+#define _LLT_INIT_DATA(x)		((x) & 0xFF)
+#define _LLT_INIT_ADDR(x)		(((x) & 0xFF) << 8)
+#define _LLT_OP(x)			(((x) & 0x3) << 30)
+#define _LLT_OP_VALUE(x)		(((x) >> 30) & 0x3)
+
+
+/* 2 BB_ACCESS_CTRL */
+#define BB_WRITE_READ_MASK		(BIT(31) | BIT(30))
+#define BB_WRITE_EN			BIT(30)
+#define BB_READ_EN			BIT(31)
+/* define BB_ADDR_MASK			0xFFF */
+/* define _BB_ADDR(x)			((x) & BB_ADDR_MASK) */
+
+/*  */
+/*  */
+/*	0x0200h ~ 0x027Fh	TXDMA Configuration */
+/*  */
+/*  */
+/* 2 RQPN */
+#define _HPQ(x)				((x) & 0xFF)
+#define _LPQ(x)				(((x) & 0xFF) << 8)
+#define _PUBQ(x)			(((x) & 0xFF) << 16)
+	/*  NOTE: in RQPN_NPQ register */
+#define _NPQ(x)				((x) & 0xFF)
+
+
+#define HPQ_PUBLIC_DIS			BIT(24)
+#define LPQ_PUBLIC_DIS			BIT(25)
+#define LD_RQPN				BIT(31)
+
+
+/* 2 TDECTRL */
+#define BCN_VALID			BIT(16)
+#define BCN_HEAD(x)			(((x) & 0xFF) << 8)
+#define	BCN_HEAD_MASK			0xFF00
+
+/* 2 TDECTL */
+#define BLK_DESC_NUM_SHIFT		4
+#define BLK_DESC_NUM_MASK		0xF
+
+
+/* 2 TXDMA_OFFSET_CHK */
+#define DROP_DATA_EN			BIT(9)
+
+/*  */
+/*  */
+/*	0x0400h ~ 0x047Fh	Protocol Configuration */
+/*  */
+/*  */
+/* 2 FWHW_TXQ_CTRL */
+#define EN_AMPDU_RTY_NEW		BIT(7)
+
+/* 2 INIRTSMCS_SEL */
+#define _INIRTSMCS_SEL(x)		((x) & 0x3F)
+
+
+/* 2 SPEC SIFS */
+#define _SPEC_SIFS_CCK(x)		((x) & 0xFF)
+#define _SPEC_SIFS_OFDM(x)		(((x) & 0xFF) << 8)
+
+
+/* 2 RRSR */
+
+#define RATE_REG_BITMAP_ALL		0xFFFFF
+
+#define _RRSC_BITMAP(x)			((x) & 0xFFFFF)
+
+#define _RRSR_RSC(x)			(((x) & 0x3) << 21)
+#define RRSR_RSC_RESERVED		0x0
+#define RRSR_RSC_UPPER_SUBCHANNEL	0x1
+#define RRSR_RSC_LOWER_SUBCHANNEL	0x2
+#define RRSR_RSC_DUPLICATE_MODE		0x3
+
+
+/* 2 ARFR */
+#define USE_SHORT_G1			BIT(20)
+
+/* 2 AGGLEN_LMT_L */
+#define _AGGLMT_MCS0(x)			((x) & 0xF)
+#define _AGGLMT_MCS1(x)			(((x) & 0xF) << 4)
+#define _AGGLMT_MCS2(x)			(((x) & 0xF) << 8)
+#define _AGGLMT_MCS3(x)			(((x) & 0xF) << 12)
+#define _AGGLMT_MCS4(x)			(((x) & 0xF) << 16)
+#define _AGGLMT_MCS5(x)			(((x) & 0xF) << 20)
+#define _AGGLMT_MCS6(x)			(((x) & 0xF) << 24)
+#define _AGGLMT_MCS7(x)			(((x) & 0xF) << 28)
+
+
+/* 2 RL */
+#define	RETRY_LIMIT_SHORT_SHIFT		8
+#define	RETRY_LIMIT_LONG_SHIFT		0
+
+
+/* 2 DARFRC */
+#define _DARF_RC1(x)			((x) & 0x1F)
+#define _DARF_RC2(x)			(((x) & 0x1F) << 8)
+#define _DARF_RC3(x)			(((x) & 0x1F) << 16)
+#define _DARF_RC4(x)			(((x) & 0x1F) << 24)
+/*  NOTE: shift starting from address (DARFRC + 4) */
+#define _DARF_RC5(x)			((x) & 0x1F)
+#define _DARF_RC6(x)			(((x) & 0x1F) << 8)
+#define _DARF_RC7(x)			(((x) & 0x1F) << 16)
+#define _DARF_RC8(x)			(((x) & 0x1F) << 24)
+
+
+/* 2 RARFRC */
+#define _RARF_RC1(x)			((x) & 0x1F)
+#define _RARF_RC2(x)			(((x) & 0x1F) << 8)
+#define _RARF_RC3(x)			(((x) & 0x1F) << 16)
+#define _RARF_RC4(x)			(((x) & 0x1F) << 24)
+/*  NOTE: shift starting from address (RARFRC + 4) */
+#define _RARF_RC5(x)			((x) & 0x1F)
+#define _RARF_RC6(x)			(((x) & 0x1F) << 8)
+#define _RARF_RC7(x)			(((x) & 0x1F) << 16)
+#define _RARF_RC8(x)			(((x) & 0x1F) << 24)
+
+
+/*  */
+/*  */
+/*	0x0500h ~ 0x05FFh	EDCA Configuration */
+/*  */
+/*  */
+
+
+
+/* 2 EDCA setting */
+#define AC_PARAM_TXOP_LIMIT_OFFSET	16
+#define AC_PARAM_ECW_MAX_OFFSET		12
+#define AC_PARAM_ECW_MIN_OFFSET		8
+#define AC_PARAM_AIFS_OFFSET		0
+
+
+/* 2 EDCA_VO_PARAM */
+#define _AIFS(x)			(x)
+#define _ECW_MAX_MIN(x)			((x) << 8)
+#define _TXOP_LIMIT(x)			((x) << 16)
+
+
+#define _BCNIFS(x)			((x) & 0xFF)
+#define _BCNECW(x)			(((x) & 0xF))<< 8)
+
+
+#define _LRL(x)				((x) & 0x3F)
+#define _SRL(x)				(((x) & 0x3F) << 8)
+
+
+/* 2 SIFS_CCK */
+#define _SIFS_CCK_CTX(x)		((x) & 0xFF)
+#define _SIFS_CCK_TRX(x)		(((x) & 0xFF) << 8);
+
+
+/* 2 SIFS_OFDM */
+#define _SIFS_OFDM_CTX(x)		((x) & 0xFF)
+#define _SIFS_OFDM_TRX(x)		(((x) & 0xFF) << 8);
+
+
+/* 2 TBTT PROHIBIT */
+#define _TBTT_PROHIBIT_HOLD(x)		(((x) & 0xFF) << 8)
+
+
+/* 2 REG_RD_CTRL */
+#define DIS_EDCA_CNT_DWN		BIT(11)
+
+
+/* 2 BCN_CTRL */
+#define EN_MBSSID			BIT(1)
+#define EN_TXBCN_RPT			BIT(2)
+#define	EN_BCN_FUNCTION			BIT(3)
+#define DIS_TSF_UPDATE			BIT(3)
+
+/*  The same function but different bit field. */
+#define	DIS_TSF_UDT0_NORMAL_CHIP	BIT(4)
+#define	DIS_TSF_UDT0_TEST_CHIP		BIT(5)
+
+/* 2 ACMHWCTRL */
+#define	AcmHw_HwEn			BIT(0)
+#define	AcmHw_BeqEn			BIT(1)
+#define	AcmHw_ViqEn			BIT(2)
+#define	AcmHw_VoqEn			BIT(3)
+#define	AcmHw_BeqStatus			BIT(4)
+#define	AcmHw_ViqStatus			BIT(5)
+#define	AcmHw_VoqStatus			BIT(6)
+
+
+
+/*  */
+/*  */
+/*	0x0600h ~ 0x07FFh	WMAC Configuration */
+/*  */
+/*  */
+
+/* 2 APSD_CTRL */
+#define APSDOFF				BIT(6)
+#define APSDOFF_STATUS			BIT(7)
+
+
+/* 2 BWOPMODE */
+#define BW_20MHZ			BIT(2)
+
+
+#define RATE_BITMAP_ALL			0xFFFFF
+
+/*  Only use CCK 1M rate for ACK */
+#define RATE_RRSR_CCK_ONLY_1M		0xFFFF1
+
+/* 2 TCR */
+#define TSFRST				BIT(0)
+#define DIS_GCLK			BIT(1)
+#define PAD_SEL				BIT(2)
+#define PWR_ST				BIT(6)
+#define PWRBIT_OW_EN			BIT(7)
+#define ACRC				BIT(8)
+#define CFENDFORM			BIT(9)
+#define ICV				BIT(10)
+
+
+
+/* 2 RCR */
+#define AAP				BIT(0)
+#define APM				BIT(1)
+#define AM				BIT(2)
+#define AB				BIT(3)
+#define ADD3				BIT(4)
+#define APWRMGT				BIT(5)
+#define CBSSID				BIT(6)
+#define CBSSID_BCN			BIT(7)
+#define ACRC32				BIT(8)
+#define AICV				BIT(9)
+#define ADF				BIT(11)
+#define ACF				BIT(12)
+#define AMF				BIT(13)
+#define HTC_LOC_CTRL			BIT(14)
+#define UC_DATA_EN			BIT(16)
+#define BM_DATA_EN			BIT(17)
+#define MFBEN				BIT(22)
+#define LSIGEN				BIT(23)
+#define EnMBID				BIT(24)
+#define APP_BASSN			BIT(27)
+#define APP_PHYSTS			BIT(28)
+#define APP_ICV				BIT(29)
+#define APP_MIC				BIT(30)
+#define APP_FCS				BIT(31)
+
+/* 2 RX_PKT_LIMIT */
+
+/* 2 RX_DLK_TIME */
+
+/* 2 MBIDCAMCFG */
+
+
+
+/* 2 AMPDU_MIN_SPACE */
+#define _MIN_SPACE(x)			((x) & 0x7)
+#define _SHORT_GI_PADDING(x)		(((x) & 0x1F) << 3)
+
+
+/* 2 RXERR_RPT */
+#define RXERR_TYPE_OFDM_PPDU		0
+#define RXERR_TYPE_OFDMfalse_ALARM	1
+#define	RXERR_TYPE_OFDM_MPDU_OK		2
+#define RXERR_TYPE_OFDM_MPDU_FAIL	3
+#define RXERR_TYPE_CCK_PPDU		4
+#define RXERR_TYPE_CCKfalse_ALARM	5
+#define RXERR_TYPE_CCK_MPDU_OK		6
+#define RXERR_TYPE_CCK_MPDU_FAIL	7
+#define RXERR_TYPE_HT_PPDU		8
+#define RXERR_TYPE_HTfalse_ALARM	9
+#define RXERR_TYPE_HT_MPDU_TOTAL	10
+#define RXERR_TYPE_HT_MPDU_OK		11
+#define RXERR_TYPE_HT_MPDU_FAIL		12
+#define RXERR_TYPE_RX_FULL_DROP		15
+
+#define RXERR_COUNTER_MASK		0xFFFFF
+#define RXERR_RPT_RST			BIT(27)
+#define _RXERR_RPT_SEL(type)		((type) << 28)
+
+
+/* 2 SECCFG */
+#define	SCR_TxUseDK			BIT(0)	/* Force Tx Use Default Key */
+#define	SCR_RxUseDK			BIT(1)	/* Force Rx Use Default Key */
+#define	SCR_TxEncEnable			BIT(2)	/* Enable Tx Encryption */
+#define	SCR_RxDecEnable			BIT(3)	/* Enable Rx Decryption */
+#define	SCR_SKByA2			BIT(4)	/* Search kEY BY A2 */
+#define	SCR_NoSKMC			BIT(5)	/* No Key Search Multicast */
+
+
+
+/*  */
+/*  */
+/*	0xFE00h ~ 0xFE55h	USB Configuration */
+/*  */
+/*  */
+
+/* 2 USB Information (0xFE17) */
+#define USB_IS_HIGH_SPEED		0
+#define USB_IS_FULL_SPEED		1
+#define USB_SPEED_MASK			BIT(5)
+
+#define USB_NORMAL_SIE_EP_MASK		0xF
+#define USB_NORMAL_SIE_EP_SHIFT		4
+
+#define USB_TEST_EP_MASK		0x30
+#define USB_TEST_EP_SHIFT		4
+
+/* 2 Special Option */
+#define USB_AGG_EN			BIT(3)
+
+
+/* 2REG_C2HEVT_CLEAR */
+	/*  Set by driver and notify FW that the driver has read the
+	    C2H command message */
+#define C2H_EVT_HOST_CLOSE		0x00
+	/*  Set by FW indicating that FW had set the C2H command message
+	    and it's not yet read by driver. */
+#define C2H_EVT_FW_CLOSE		0xFF
+
+
+/* 2REG_MULTI_FUNC_CTRL(For RTL8723 Only) */
+	/*  Enable GPIO[9] as WiFi HW PDn source */
+#define	WL_HWPDN_EN			BIT0
+	/*  WiFi HW PDn polarity control */
+#define	WL_HWPDN_SL			BIT1
+	/*  WiFi function enable */
+#define	WL_FUNC_EN			BIT2
+	/*  Enable GPIO[9] as WiFi RF HW PDn source */
+#define	WL_HWROF_EN			BIT3
+	/*  Enable GPIO[11] as BT HW PDn source */
+#define	BT_HWPDN_EN			BIT16
+	/*  BT HW PDn polarity control */
+#define	BT_HWPDN_SL			BIT17
+	/*  BT function enable */
+#define	BT_FUNC_EN			BIT18
+	/*  Enable GPIO[11] as BT/GPS RF HW PDn source */
+#define	BT_HWROF_EN			BIT19
+	/*  Enable GPIO[10] as GPS HW PDn source */
+#define	GPS_HWPDN_EN			BIT20
+	/*  GPS HW PDn polarity control */
+#define	GPS_HWPDN_SL			BIT21
+	/*  GPS function enable */
+#define	GPS_FUNC_EN			BIT22
+
+/* 3 REG_LIFECTRL_CTRL */
+#define	HAL92C_EN_PKT_LIFE_TIME_BK	BIT3
+#define	HAL92C_EN_PKT_LIFE_TIME_BE	BIT2
+#define	HAL92C_EN_PKT_LIFE_TIME_VI	BIT1
+#define	HAL92C_EN_PKT_LIFE_TIME_VO	BIT0
+
+#define	HAL92C_MSDU_LIFE_TIME_UNIT	128	/*  in us, said by Tim. */
+
+/*  */
+/*  General definitions */
+/*  */
+
+#define LAST_ENTRY_OF_TX_PKT_BUFFER	255
+
+#define POLLING_LLT_THRESHOLD		20
+#define POLLING_READY_TIMEOUT_COUNT	1000
+
+/*  Min Spacing related settings. */
+#define	MAX_MSS_DENSITY_2T		0x13
+#define	MAX_MSS_DENSITY_1T		0x0A
+
+/*  */
+/*	8723A Regsiter offset definition */
+/*  */
+#define HAL_8723A_NAV_UPPER_UNIT	128		/*  micro-second */
+
+/*  */
+/*  */
+/*	0x0000h ~ 0x00FFh	System Configuration */
+/*  */
+/*  */
+#define REG_SYSON_REG_LOCK		0x001C
+
+
+/*  */
+/*  */
+/*	0x0100h ~ 0x01FFh	MACTOP General Configuration */
+/*  */
+/*  */
+#define REG_FTIMR			0x0138
+
+
+/*  */
+/*  */
+/*	0x0200h ~ 0x027Fh	TXDMA Configuration */
+/*  */
+/*  */
+
+
+/*  */
+/*  */
+/*	0x0280h ~ 0x02FFh	RXDMA Configuration */
+/*  */
+/*  */
+
+
+/*  */
+/*  */
+/*	0x0300h ~ 0x03FFh	PCIe */
+/*  */
+/*  */
+
+
+/*  */
+/*  */
+/*	0x0400h ~ 0x047Fh	Protocol Configuration */
+/*  */
+/*  */
+#define REG_EARLY_MODE_CONTROL		0x4D0
+
+
+/*  */
+/*  */
+/*	0x0500h ~ 0x05FFh	EDCA Configuration */
+/*  */
+/*  */
+
+/* 2 BCN_CTRL */
+#define DIS_ATIM			BIT(0)
+#define DIS_BCNQ_SUB			BIT(1)
+#define DIS_TSF_UDT			BIT(4)
+
+
+/*  */
+/*  */
+/*	0x0600h ~ 0x07FFh	WMAC Configuration */
+/*  */
+/*  */
+/*  */
+/*  Note: */
+/*	The NAV upper value is very important to WiFi 11n 5.2.3 NAV test.
+ *	The default value is always too small, but the WiFi TestPlan test
+ *	by 25,000 microseconds of NAV through sending CTS in the air. We
+ *	must update this value greater than 25,000 microseconds to pass the
+ *	item.
+*	The offset of NAV_UPPER in 8192C Spec is incorrect, and the offset
+*	should be 0x0652. Commented by SD1 Scott. */
+/*  By Bruce, 2011-07-18. */
+/*  */
+#define	REG_NAV_UPPER			0x0652	/*  unit of 128 */
+
+
+/*  */
+/*	8723 Regsiter Bit and Content definition */
+/*  */
+
+/*  */
+/*  */
+/*	0x0000h ~ 0x00FFh	System Configuration */
+/*  */
+/*  */
+
+/* 2 SPS0_CTRL */
+
+/* 2 SYS_ISO_CTRL */
+
+/* 2 SYS_FUNC_EN */
+
+/* 2 APS_FSMCO */
+#define EN_WLON				BIT(16)
+
+/* 2 SYS_CLKR */
+
+/* 2 9346CR */
+
+/* 2 AFE_MISC */
+
+/* 2 SPS0_CTRL */
+
+/* 2 SPS_OCP_CFG */
+
+/* 2 SYSON_REG_LOCK */
+#define WLOCK_ALL			BIT(0)
+#define WLOCK_00			BIT(1)
+#define WLOCK_04			BIT(2)
+#define WLOCK_08			BIT(3)
+#define WLOCK_40			BIT(4)
+#define WLOCK_1C_B6			BIT(5)
+#define R_DIS_PRST_1			BIT(6)
+#define LOCK_ALL_EN			BIT(7)
+
+/* 2 RF_CTRL */
+
+/* 2 LDOA15_CTRL */
+
+/* 2 LDOV12D_CTRL */
+
+/* 2 AFE_XTAL_CTRL */
+
+/* 2 AFE_PLL_CTRL */
+
+/* 2 EFUSE_CTRL */
+
+/* 2 EFUSE_TEST (For RTL8723 partially) */
+
+/* 2 PWR_DATA */
+
+/* 2 CAL_TIMER */
+
+/* 2 ACLK_MON */
+
+/* 2 GPIO_MUXCFG */
+
+/* 2 GPIO_PIN_CTRL */
+
+/* 2 GPIO_INTM */
+
+/* 2 LEDCFG */
+
+/* 2 FSIMR */
+
+/* 2 FSISR */
+
+/* 2 HSIMR */
+/*  8723 Host System Interrupt Mask Register (offset 0x58, 32 byte) */
+#define HSIMR_GPIO12_0_INT_EN		BIT(0)
+#define HSIMR_SPS_OCP_INT_EN		BIT(5)
+#define HSIMR_RON_INT_EN		BIT(6)
+#define HSIMR_PDNINT_EN			BIT(7)
+#define HSIMR_GPIO9_INT_EN		BIT(25)
+
+/* 2 HSISR */
+/*  8723 Host System Interrupt Status Register (offset 0x5C, 32 byte) =
*/
+#define HSISR_GPIO12_0_INT		BIT(0)
+#define HSISR_SPS_OCP_INT		BIT(5)
+#define HSISR_RON_INT			BIT(6)
+#define HSISR_PDNINT			BIT(7)
+#define	HSISR_GPIO9_INT			BIT(25)
+
+/*  interrupt mask which needs to clear */
+#define MASK_HSISR_CLEAR		(HSISR_GPIO12_0_INT | \
+					 HSISR_SPS_OCP_INT | \
+					 HSISR_RON_INT | \
+					 HSISR_PDNINT |	\
+					 HSISR_GPIO9_INT)
+
+/* 2 MCUFWDL */
+#define RAM_DL_SEL			BIT7	/*  1:RAM, 0:ROM */
+
+/* 2 HPON_FSM */
+
+/* 2 SYS_CFG */
+#define RTL_ID				BIT(23)	/*  TestChip ID,
+						    1:Test(RLE); 0:MP(RL) */
+#define SPS_SEL				BIT(24) /*  1:LDO regulator mode;
+						    0:Switching regulator mode*/
+
+
+/*  */
+/*  */
+/*	0x0100h ~ 0x01FFh	MACTOP General Configuration */
+/*  */
+/*  */
+
+/* 2 Function Enable Registers */
+
+/* 2 CR */
+#define CALTMR_EN			BIT(10)
+
+/* 2 PBP - Page Size Register */
+
+/* 2 TX/RXDMA */
+
+/* 2 TRXFF_BNDY */
+
+/* 2 LLT_INIT */
+
+/* 2 BB_ACCESS_CTRL */
+
+
+/*  */
+/*  */
+/*	0x0200h ~ 0x027Fh	TXDMA Configuration */
+/*  */
+/*  */
+
+/* 2 RQPN */
+
+/* 2 TDECTRL */
+
+/* 2 TDECTL */
+
+/* 2 TXDMA_OFFSET_CHK */
+
+
+/*  */
+/*  */
+/*	0x0400h ~ 0x047Fh	Protocol Configuration */
+/*  */
+/*  */
+
+/* 2 FWHW_TXQ_CTRL */
+
+/* 2 INIRTSMCS_SEL */
+
+/* 2 SPEC SIFS */
+
+/* 2 RRSR */
+
+/* 2 ARFR */
+
+/* 2 AGGLEN_LMT_L */
+
+/* 2 RL */
+
+/* 2 DARFRC */
+
+/* 2 RARFRC */
+
+
+/*  */
+/*  */
+/*	0x0500h ~ 0x05FFh	EDCA Configuration */
+/*  */
+/*  */
+
+/* 2 EDCA setting */
+
+/* 2 EDCA_VO_PARAM */
+
+/* 2 SIFS_CCK */
+
+/* 2 SIFS_OFDM */
+
+/* 2 TBTT PROHIBIT */
+
+/* 2 REG_RD_CTRL */
+
+/* 2 BCN_CTRL */
+
+/* 2 ACMHWCTRL */
+
+
+/*  */
+/*  */
+/*	0x0600h ~ 0x07FFh	WMAC Configuration */
+/*  */
+/*  */
+
+/* 2 APSD_CTRL */
+
+/* 2 BWOPMODE */
+
+/* 2 TCR */
+
+/* 2 RCR */
+
+/* 2 RX_PKT_LIMIT */
+
+/* 2 RX_DLK_TIME */
+
+/* 2 MBIDCAMCFG */
+
+/* 2 AMPDU_MIN_SPACE */
+
+/* 2 RXERR_RPT */
+
+/* 2 SECCFG */
+
+
+/*  */
+/*  */
+/*	0xFE00h ~ 0xFE55h	RTL8723 SDIO Configuration */
+/*  */
+/*  */
+
+/*  I/O bus domain address mapping */
+#define WLAN_IOREG_BASE			0x10260000
+#define FIRMWARE_FIFO_BASE		0x10270000
+#define TX_HIQ_BASE			0x10310000
+#define TX_MIQ_BASE			0x10320000
+#define TX_LOQ_BASE			0x10330000
+#define RX_RX0FF_BASE			0x10340000
+
+/*  SDIO host local register space mapping. */
+#define WLAN_IOREG_MSK			0x7FFF
+#define WLAN_FIFO_MSK			0x1FFF	/*  Aggregation Length[12:0] */
+#define WLAN_RX0FF_MSK			0x0003
+
+#define WLAN_RX0FF_DEVICE_ID		7	/*  0b[16], 111b[15:13] */
+#define WLAN_IOREG_DEVICE_ID		8	/*  1b[16] */
+
+/*  8723 EFUSE */
+#define HWSET_MAX_SIZE			256
+
+
+/* USB interrupt */
+#define	UHIMR_TIMEOUT2			BIT31
+#define	UHIMR_TIMEOUT1			BIT30
+#define	UHIMR_PSTIMEOUT			BIT29
+#define	UHIMR_GTINT4			BIT28
+#define	UHIMR_GTINT3			BIT27
+#define	UHIMR_TXBCNERR			BIT26
+#define	UHIMR_TXBCNOK			BIT25
+#define	UHIMR_TSF_BIT32_TOGGLE		BIT24
+#define	UHIMR_BCNDMAINT3		BIT23
+#define	UHIMR_BCNDMAINT2		BIT22
+#define	UHIMR_BCNDMAINT1		BIT21
+#define	UHIMR_BCNDMAINT0		BIT20
+#define	UHIMR_BCNDOK3			BIT19
+#define	UHIMR_BCNDOK2			BIT18
+#define	UHIMR_BCNDOK1			BIT17
+#define	UHIMR_BCNDOK0			BIT16
+#define	UHIMR_HSISR_IND			BIT15
+#define	UHIMR_BCNDMAINT_E		BIT14
+/* RSVD	BIT13 */
+#define	UHIMR_CTW_END			BIT12
+/* RSVD	BIT11 */
+#define	UHIMR_C2HCMD			BIT10
+#define	UHIMR_CPWM2			BIT9
+#define	UHIMR_CPWM			BIT8
+#define	UHIMR_HIGHDOK			BIT7	/*  High Queue DMA OK
+						    Interrupt */
+#define	UHIMR_MGNTDOK			BIT6	/*  Management Queue DMA OK
+						    Interrupt */
+#define	UHIMR_BKDOK			BIT5	/*  AC_BK DMA OK Interrupt */
+#define	UHIMR_BEDOK			BIT4	/*  AC_BE DMA OK Interrupt */
+#define	UHIMR_VIDOK			BIT3	/*  AC_VI DMA OK Interrupt */
+#define	UHIMR_VODOK			BIT2	/*  AC_VO DMA Interrupt */
+#define	UHIMR_RDU			BIT1	/*  Receive Descriptor
+						    Unavailable */
+#define	UHIMR_ROK			BIT0	/*  Receive DMA OK Interrupt */
+
+/*  USB Host Interrupt Status Extension bit */
+#define	UHIMR_BCNDMAINT7		BIT23
+#define	UHIMR_BCNDMAINT6		BIT22
+#define	UHIMR_BCNDMAINT5		BIT21
+#define	UHIMR_BCNDMAINT4		BIT20
+#define	UHIMR_BCNDOK7			BIT19
+#define	UHIMR_BCNDOK6			BIT18
+#define	UHIMR_BCNDOK5			BIT17
+#define	UHIMR_BCNDOK4			BIT16
+/*  bit14-15: RSVD */
+#define	UHIMR_ATIMEND_E			BIT13
+#define	UHIMR_ATIMEND			BIT12
+#define	UHIMR_TXERR			BIT11
+#define	UHIMR_RXERR			BIT10
+#define	UHIMR_TXFOVW			BIT9
+#define	UHIMR_RXFOVW			BIT8
+/*  bit2-7: RSVD */
+#define	UHIMR_OCPINT			BIT1
+/*  bit0: RSVD */
+
+#define	REG_USB_HIMR			0xFE38
+#define	REG_USB_HIMRE			0xFE3C
+#define	REG_USB_HISR			0xFE78
+#define	REG_USB_HISRE			0xFE7C
+
+#define	USB_INTR_CPWM_OFFSET		16
+#define	USB_INTR_CONTENT_HISR_OFFSET	48
+#define	USB_INTR_CONTENT_HISRE_OFFSET	52
+#define	USB_INTR_CONTENT_LENGTH		56
+#define	USB_C2H_CMDID_OFFSET		0
+#define	USB_C2H_SEQ_OFFSET		1
+#define	USB_C2H_EVENT_OFFSET		2
+/*  */
+/*	General definitions */
+/*  */
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtl8723a_sreset.h b/driv=
ers/staging/rtl8723au/include/rtl8723a_sreset.h
new file mode 100644
index 0000000..82af6a2
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtl8723a_sreset.h
@@ -0,0 +1,25 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef _RTL8723A_SRESET_H_
+#define _RTL8723A_SRESET_H_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <rtw_sreset.h>
+
+void rtl8723a_sreset_xmit_status_check(struct rtw_adapter *padapter);
+void rtl8723a_sreset_linked_status_check(struct rtw_adapter *padapter)=
;
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtl8723a_xmit.h b/driver=
s/staging/rtl8723au/include/rtl8723a_xmit.h
new file mode 100644
index 0000000..3b6fdc3
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtl8723a_xmit.h
@@ -0,0 +1,229 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTL8723A_XMIT_H__
+#define __RTL8723A_XMIT_H__
+
+/*  */
+/*  Queue Select Value in TxDesc */
+/*  */
+#define QSLT_BK							0x2/* 0x01 */
+#define QSLT_BE							0x0
+#define QSLT_VI							0x5/* 0x4 */
+#define QSLT_VO							0x7/* 0x6 */
+#define QSLT_BEACON						0x10
+#define QSLT_HIGH						0x11
+#define QSLT_MGNT						0x12
+#define QSLT_CMD						0x13
+
+/*  */
+/* defined for TX DESC Operation */
+/*  */
+
+#define MAX_TID (15)
+
+/* OFFSET 0 */
+#define OFFSET_SZ	0
+#define OFFSET_SHT	16
+#define BMC		BIT(24)
+#define LSG		BIT(26)
+#define FSG		BIT(27)
+#define OWN		BIT(31)
+
+
+/* OFFSET 4 */
+#define PKT_OFFSET_SZ	0
+#define BK		BIT(6)
+#define QSEL_SHT	8
+#define Rate_ID_SHT	16
+#define NAVUSEHDR	BIT(20)
+#define PKT_OFFSET_SHT	26
+#define HWPC		BIT(31)
+
+/* OFFSET 8 */
+#define AGG_EN		BIT(29)
+
+/* OFFSET 12 */
+#define SEQ_SHT		16
+
+/* OFFSET 16 */
+#define QoS		BIT(6)
+#define HW_SEQ_EN	BIT(7)
+#define USERATE		BIT(8)
+#define DISDATAFB	BIT(10)
+#define DATA_SHORT	BIT(24)
+#define DATA_BW		BIT(25)
+
+/* OFFSET 20 */
+#define SGI		BIT(6)
+
+struct txdesc_8723a {
+	u32 pktlen:16;
+	u32 offset:8;
+	u32 bmc:1;
+	u32 htc:1;
+	u32 ls:1;
+	u32 fs:1;
+	u32 linip:1;
+	u32 noacm:1;
+	u32 gf:1;
+	u32 own:1;
+
+	u32 macid:5;
+	u32 agg_en:1;
+	u32 bk:1;
+	u32 rd_en:1;
+	u32 qsel:5;
+	u32 rd_nav_ext:1;
+	u32 lsig_txop_en:1;
+	u32 pifs:1;
+	u32 rate_id:4;
+	u32 navusehdr:1;
+	u32 en_desc_id:1;
+	u32 sectype:2;
+	u32 rsvd0424:2;
+	u32 pkt_offset:5;	/*  unit: 8 bytes */
+	u32 rsvd0431:1;
+
+	u32 rts_rc:6;
+	u32 data_rc:6;
+	u32 rsvd0812:2;
+	u32 bar_rty_th:2;
+	u32 rsvd0816:1;
+	u32 morefrag:1;
+	u32 raw:1;
+	u32 ccx:1;
+	u32 ampdu_density:3;
+	u32 bt_null:1;
+	u32 ant_sel_a:1;
+	u32 ant_sel_b:1;
+	u32 tx_ant_cck:2;
+	u32 tx_antl:2;
+	u32 tx_ant_ht:2;
+
+	u32 nextheadpage:8;
+	u32 tailpage:8;
+	u32 seq:12;
+	u32 cpu_handle:1;
+	u32 tag1:1;
+	u32 trigger_int:1;
+	u32 hwseq_en:1;
+
+	u32 rtsrate:5;
+	u32 ap_dcfe:1;
+	u32 hwseq_sel:2;
+	u32 userate:1;
+	u32 disrtsfb:1;
+	u32 disdatafb:1;
+	u32 cts2self:1;
+	u32 rtsen:1;
+	u32 hw_rts_en:1;
+	u32 port_id:1;
+	u32 rsvd1615:3;
+	u32 wait_dcts:1;
+	u32 cts2ap_en:1;
+	u32 data_sc:2;
+	u32 data_stbc:2;
+	u32 data_short:1;
+	u32 data_bw:1;
+	u32 rts_short:1;
+	u32 rts_bw:1;
+	u32 rts_sc:2;
+	u32 vcs_stbc:2;
+
+	u32 datarate:6;
+	u32 sgi:1;
+	u32 try_rate:1;
+	u32 data_ratefb_lmt:5;
+	u32 rts_ratefb_lmt:4;
+	u32 rty_lmt_en:1;
+	u32 data_rt_lmt:6;
+	u32 usb_txagg_num:8;
+
+	u32 txagg_a:5;
+	u32 txagg_b:5;
+	u32 use_max_len:1;
+	u32 max_agg_num:5;
+	u32 mcsg1_max_len:4;
+	u32 mcsg2_max_len:4;
+	u32 mcsg3_max_len:4;
+	u32 mcs7_sgi_max_len:4;
+
+	u32 checksum:16;	/*  TxBuffSize(PCIe)/CheckSum(USB) */
+	u32 mcsg4_max_len:4;
+	u32 mcsg5_max_len:4;
+	u32 mcsg6_max_len:4;
+	u32 mcs15_sgi_max_len:4;
+};
+
+#define txdesc_set_ccx_sw_8723a(txdesc, value) \
+	do { \
+		((struct txdesc_8723a *)(txdesc))->mcsg4_max_len =3D (((value)>>8) &=
 0x0f); \
+		((struct txdesc_8723a *)(txdesc))->mcs15_sgi_max_len=3D (((value)>>4=
) & 0x0f); \
+		((struct txdesc_8723a *)(txdesc))->mcsg6_max_len =3D ((value) & 0x0f=
); \
+	} while (0)
+
+struct txrpt_ccx_8723a {
+	/* offset 0 */
+	u8 tag1:1;
+	u8 rsvd:4;
+	u8 int_bt:1;
+	u8 int_tri:1;
+	u8 int_ccx:1;
+
+	/* offset 1 */
+	u8 mac_id:5;
+	u8 pkt_drop:1;
+	u8 pkt_ok:1;
+	u8 bmc:1;
+
+	/* offset 2 */
+	u8 retry_cnt:6;
+	u8 lifetime_over:1;
+	u8 retry_over:1;
+
+	/* offset 3 */
+	u8 ccx_qtime0;
+	u8 ccx_qtime1;
+
+	/* offset 5 */
+	u8 final_data_rate;
+
+	/* offset 6 */
+	u8 sw1:4;
+	u8 qsel:4;
+
+	/* offset 7 */
+	u8 sw0;
+};
+
+#define txrpt_ccx_sw_8723a(txrpt_ccx) ((txrpt_ccx)->sw0 + ((txrpt_ccx)=
->sw1<<8))
+#define txrpt_ccx_qtime_8723a(txrpt_ccx) ((txrpt_ccx)->ccx_qtime0+((tx=
rpt_ccx)->ccx_qtime1<<8))
+
+void dump_txrpt_ccx_8723a(void *buf);
+void handle_txrpt_ccx_8723a(struct rtw_adapter *adapter, void *buf);
+void rtl8723a_update_txdesc(struct xmit_frame *pxmitframe, u8 *pmem);
+void rtl8723a_fill_fake_txdesc(struct rtw_adapter *padapter, u8 *pDesc=
, u32 BufferLen, u8 IsPsPoll, u8 IsBTQosNull);
+
+s32	rtl8723au_hal_xmitframe_enqueue(struct rtw_adapter *padapter, stru=
ct xmit_frame *pxmitframe);
+s32 rtl8723au_xmit_buf_handler(struct rtw_adapter *padapter);
+#define hal_xmit_handler rtl8723au_xmit_buf_handler
+s32	rtl8723au_init_xmit_priv(struct rtw_adapter * padapter);
+void	rtl8723au_free_xmit_priv(struct rtw_adapter * padapter);
+s32 rtl8723au_hal_xmit(struct rtw_adapter *padapter, struct xmit_frame=
 *pxmitframe);
+s32 rtl8723au_mgnt_xmit(struct rtw_adapter *padapter, struct xmit_fram=
e *pmgntframe);
+s32 rtl8723au_xmitframe_complete(struct rtw_adapter *padapter, struct =
xmit_priv *pxmitpriv, struct xmit_buf *pxmitbuf);
+
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtw_ap.h b/drivers/stagi=
ng/rtl8723au/include/rtw_ap.h
new file mode 100644
index 0000000..76f82d6
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_ap.h
@@ -0,0 +1,55 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2012 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTW_AP_H_
+#define __RTW_AP_H_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+
+#ifdef CONFIG_8723AU_AP_MODE
+
+/* external function */
+void rtw_indicate_sta_assoc_event23a(struct rtw_adapter *padapter, str=
uct sta_info *psta);
+void rtw_indicate_sta_disassoc_event23a(struct rtw_adapter *padapter, =
struct sta_info *psta);
+
+void init_mlme_ap_info23a(struct rtw_adapter *padapter);
+void free_mlme_ap_info23a(struct rtw_adapter *padapter);
+/* void update_BCNTIM(struct rtw_adapter *padapter); */
+void rtw_add_bcn_ie(struct rtw_adapter *padapter, struct wlan_bssid_ex=
 *pnetwork, u8 index, u8 *data, u8 len);
+void rtw_remove_bcn_ie(struct rtw_adapter *padapter, struct wlan_bssid=
_ex *pnetwork, u8 index);
+void update_beacon23a(struct rtw_adapter *padapter, u8 ie_id, u8 *oui,=
 u8 tx);
+void add_RATid23a(struct rtw_adapter *padapter, struct sta_info *psta,=
 u8 rssi_level);
+void expire_timeout_chk23a(struct rtw_adapter *padapter);
+void update_sta_info23a_apmode23a(struct rtw_adapter *padapter, struct=
 sta_info *psta);
+int rtw_check_beacon_data23a(struct rtw_adapter *padapter, u8 *pbuf,  =
int len);
+void rtw_ap_restore_network(struct rtw_adapter *padapter);
+void rtw_set_macaddr_acl23a(struct rtw_adapter *padapter, int mode);
+int rtw_acl_add_sta23a(struct rtw_adapter *padapter, u8 *addr);
+int rtw_acl_remove_sta23a(struct rtw_adapter *padapter, u8 *addr);
+
+void associated_clients_update23a(struct rtw_adapter *padapter, u8 upd=
ated);
+void bss_cap_update_on_sta_join23a(struct rtw_adapter *padapter, struc=
t sta_info *psta);
+u8 bss_cap_update_on_sta_leave23a(struct rtw_adapter *padapter, struct=
 sta_info *psta);
+void sta_info_update23a(struct rtw_adapter *padapter, struct sta_info =
*psta);
+void ap_sta_info_defer_update23a(struct rtw_adapter *padapter, struct =
sta_info *psta);
+u8 ap_free_sta23a(struct rtw_adapter *padapter, struct sta_info *psta,=
 bool active, u16 reason);
+int rtw_sta_flush23a(struct rtw_adapter *padapter);
+int rtw_ap_inform_ch_switch23a(struct rtw_adapter *padapter, u8 new_ch=
, u8 ch_offset);
+void start_ap_mode23a(struct rtw_adapter *padapter);
+void stop_ap_mode23a(struct rtw_adapter *padapter);
+#endif /* end of CONFIG_8723AU_AP_MODE */
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtw_cmd.h b/drivers/stag=
ing/rtl8723au/include/rtw_cmd.h
new file mode 100644
index 0000000..f9caa3e
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_cmd.h
@@ -0,0 +1,835 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTW_CMD_H_
+#define __RTW_CMD_H_
+
+#include <wlan_bssdef.h>
+#include <rtw_rf.h>
+#include <rtw_led.h>
+
+#define C2H_MEM_SZ (16*1024)
+
+#include <osdep_service.h>
+#include <ieee80211.h> /*  <ieee80211/ieee80211.h> */
+
+
+#define FREE_CMDOBJ_SZ	128
+
+#define MAX_CMDSZ	1024
+#define MAX_RSPSZ	512
+#define MAX_EVTSZ	1024
+
+#define CMDBUFF_ALIGN_SZ 512
+
+struct cmd_obj {
+	struct rtw_adapter *padapter;
+	u16	cmdcode;
+	u8	res;
+	u8	*parmbuf;
+	u32	cmdsz;
+	u8	*rsp;
+	u32	rspsz;
+	/* struct semaphore		cmd_sem; */
+	struct list_head	list;
+};
+
+struct cmd_priv {
+	struct semaphore	cmd_queue_sema;
+	/* struct semaphore	cmd_done_sema; */
+	struct semaphore	terminate_cmdthread_sema;
+	struct rtw_queue	cmd_queue;
+	u8	cmd_seq;
+	u8	*cmd_buf;	/* shall be non-paged, and 4 bytes aligned */
+	u8	*cmd_allocated_buf;
+	u8	*rsp_buf;	/* shall be non-paged, and 4 bytes aligned */
+	u8	*rsp_allocated_buf;
+	u32	cmd_issued_cnt;
+	u32	cmd_done_cnt;
+	u32	rsp_cnt;
+	u8 cmdthd_running;
+	struct rtw_adapter *padapter;
+};
+
+#define C2H_QUEUE_MAX_LEN 10
+
+struct	evt_priv {
+	struct work_struct c2h_wk;
+	bool c2h_wk_alive;
+	struct rtw_cbuf *c2h_queue;
+
+	atomic_t event_seq;
+	u8	*evt_buf;	/* shall be non-paged, and 4 bytes aligned */
+	u8	*evt_allocated_buf;
+	u32	evt_done_cnt;
+};
+
+#define init_h2fwcmd_w_parm_no_rsp(pcmd, pparm, code) \
+do {\
+	INIT_LIST_HEAD(&pcmd->list);\
+	pcmd->cmdcode =3D code;\
+	pcmd->parmbuf =3D (u8 *)(pparm);\
+	pcmd->cmdsz =3D sizeof (*pparm);\
+	pcmd->rsp =3D NULL;\
+	pcmd->rspsz =3D 0;\
+} while(0)
+
+struct c2h_evt_hdr {
+	u8 id:4;
+	u8 plen:4;
+	u8 seq;
+	u8 payload[0];
+};
+
+#define c2h_evt_exist(c2h_evt) ((c2h_evt)->id || (c2h_evt)->plen)
+
+u32 rtw_enqueue_cmd23a(struct cmd_priv *pcmdpriv, struct cmd_obj *obj)=
;
+void rtw_free_cmd_obj23a(struct cmd_obj *pcmd);
+
+int rtw_cmd_thread23a(void *context);
+
+int rtw_init_cmd_priv23a(struct cmd_priv *pcmdpriv);
+void rtw_free_cmd_priv23a (struct cmd_priv *pcmdpriv);
+
+u32 rtw_init_evt_priv23a (struct evt_priv *pevtpriv);
+void rtw_free_evt_priv23a (struct evt_priv *pevtpriv);
+void rtw_cmd_clr_isr23a(struct cmd_priv *pcmdpriv);
+void rtw_evt_notify_isr(struct evt_priv *pevtpriv);
+#ifdef CONFIG_8723AU_P2P
+u8 p2p_protocol_wk_cmd23a(struct rtw_adapter*padapter, int intCmdType =
);
+#endif /* CONFIG_8723AU_P2P */
+
+enum rtw_drvextra_cmd_id
+{
+	NONE_WK_CID,
+	DYNAMIC_CHK_WK_CID,
+	DM_CTRL_WK_CID,
+	PBC_POLLING_WK_CID,
+	POWER_SAVING_CTRL_WK_CID,/* IPS,AUTOSuspend */
+	LPS_CTRL_WK_CID,
+	ANT_SELECT_WK_CID,
+	P2P_PS_WK_CID,
+	P2P_PROTO_WK_CID,
+	CHECK_HIQ_WK_CID,/* for softap mode, check hi queue if empty */
+	C2H_WK_CID,
+	RTP_TIMER_CFG_WK_CID,
+	MAX_WK_CID
+};
+
+enum LPS_CTRL_TYPE
+{
+	LPS_CTRL_SCAN=3D0,
+	LPS_CTRL_JOINBSS=3D1,
+	LPS_CTRL_CONNECT=3D2,
+	LPS_CTRL_DISCONNECT=3D3,
+	LPS_CTRL_SPECIAL_PACKET=3D4,
+	LPS_CTRL_LEAVE=3D5,
+};
+
+enum RFINTFS {
+	SWSI,
+	HWSI,
+	HWPI,
+};
+
+/*
+Caller Mode: Infra, Ad-HoC(C)
+
+Notes: To enter USB suspend mode
+
+Command Mode
+
+*/
+struct usb_suspend_parm {
+	u32 action;/*  1: sleep, 0:resume */
+};
+
+/*
+Caller Mode: Infra, Ad-HoC
+
+Notes: To join a known BSS.
+
+Command-Event Mode
+
+*/
+
+/*
+Caller Mode: Infra, Ad-HoC(C)
+
+Notes: To disconnect the current associated BSS
+
+Command Mode
+
+*/
+struct disconnect_parm {
+	u32 deauth_timeout_ms;
+};
+
+struct	setopmode_parm {
+	u8	mode;
+	u8	rsvd[3];
+};
+
+/*
+Caller Mode: AP, Ad-HoC, Infra
+
+Notes: To ask RTL8711 performing site-survey
+
+Command-Event Mode
+
+*/
+
+#define RTW_SSID_SCAN_AMOUNT 9 /*  for WEXT_CSCAN_AMOUNT 9 */
+#define RTW_CHANNEL_SCAN_AMOUNT (14+37)
+struct sitesurvey_parm {
+	int scan_mode;	/* active: 1, passive: 0 */
+	u8 ssid_num;
+	u8 ch_num;
+	struct cfg80211_ssid ssid[RTW_SSID_SCAN_AMOUNT];
+	struct rtw_ieee80211_channel ch[RTW_CHANNEL_SCAN_AMOUNT];
+};
+
+/*
+Caller Mode: Any
+
+Notes: To set the auth type of RTL8711. open/shared/802.1x
+
+Command Mode
+
+*/
+struct setauth_parm {
+	u8 mode;  /* 0: legacy open, 1: legacy shared 2: 802.1x */
+	u8 _1x;   /* 0: PSK, 1: TLS */
+	u8 rsvd[2];
+};
+
+/*
+Caller Mode: Infra
+
+a. algorithm: wep40, wep104, tkip & aes
+b. keytype: grp key/unicast key
+c. key contents
+
+when shared key =3D=3D> keyid is the camid
+when 802.1x =3D=3D> keyid [0:1] =3D=3D> grp key
+when 802.1x =3D=3D> keyid > 2 =3D=3D> unicast key
+
+*/
+struct setkey_parm {
+	u8	algorithm;	/*  encryption algorithm, could be none, wep40, TKIP, C=
CMP, wep104 */
+	u8	keyid;
+	u8	grpkey;		/*  1: this is the grpkey for 802.1x. 0: this is the unic=
ast key for 802.1x */
+	u8	set_tx;		/*  1: main tx key for wep. 0: other key. */
+	u8	key[16];	/*  this could be 40 or 104 */
+};
+
+/*
+When in AP or Ad-Hoc mode, this is used to
+allocate an sw/hw entry for a newly associated sta.
+
+Command
+
+when shared key =3D=3D> algorithm/keyid
+
+*/
+struct set_stakey_parm {
+	u8	addr[ETH_ALEN];
+	u8	algorithm;
+	u8	id;/*  currently for erasing cam entry if algorithm =3D=3D _NO_PRI=
VACY_ */
+	u8	key[16];
+};
+
+struct set_stakey_rsp {
+	u8	addr[ETH_ALEN];
+	u8	keyid;
+	u8	rsvd;
+};
+
+/*
+Caller Ad-Hoc/AP
+
+Command -Rsp(AID =3D=3D CAMID) mode
+
+This is to force fw to add an sta_data entry per driver's request.
+
+FW will write an cam entry associated with it.
+
+*/
+struct set_assocsta_parm {
+	u8	addr[ETH_ALEN];
+};
+
+struct set_assocsta_rsp {
+	u8	cam_id;
+	u8	rsvd[3];
+};
+
+/*
+	Caller Ad-Hoc/AP
+
+	Command mode
+
+	This is to force fw to del an sta_data entry per driver's request
+
+	FW will invalidate the cam entry associated with it.
+
+*/
+struct del_assocsta_parm {
+	u8	addr[ETH_ALEN];
+};
+
+/*
+Caller Mode: AP/Ad-HoC(M)
+
+Notes: To notify fw that given staid has changed its power state
+
+Command Mode
+
+*/
+struct setstapwrstate_parm {
+	u8	staid;
+	u8	status;
+	u8	hwaddr[6];
+};
+
+/*
+Caller Mode: Any
+
+Notes: To setup the basic rate of RTL8711
+
+Command Mode
+
+*/
+struct	setbasicrate_parm {
+	u8	basicrates[NumRates];
+};
+
+/*
+Caller Mode: Any
+
+Notes: To read the current basic rate
+
+Command-Rsp Mode
+
+*/
+struct getbasicrate_parm {
+	u32 rsvd;
+};
+
+struct getbasicrate_rsp {
+	u8 basicrates[NumRates];
+};
+
+/*
+Caller Mode: Any
+
+Notes: To setup the data rate of RTL8711
+
+Command Mode
+
+*/
+struct setdatarate_parm {
+	u8	mac_id;
+	u8	datarates[NumRates];
+};
+
+/*
+Caller Mode: Any
+
+Notes: To read the current data rate
+
+Command-Rsp Mode
+
+*/
+struct getdatarate_parm {
+	u32 rsvd;
+};
+
+struct getdatarate_rsp {
+	u8 datarates[NumRates];
+};
+
+
+/*
+Caller Mode: Any
+AP: AP can use the info for the contents of beacon frame
+Infra: STA can use the info when sitesurveying
+Ad-HoC(M): Like AP
+Ad-HoC(C): Like STA
+
+
+Notes: To set the phy capability of the NIC
+
+Command Mode
+
+*/
+
+struct	setphyinfo_parm {
+	struct regulatory_class class_sets[NUM_REGULATORYS];
+	u8	status;
+};
+
+struct	getphyinfo_parm {
+	u32 rsvd;
+};
+
+struct	getphyinfo_rsp {
+	struct regulatory_class class_sets[NUM_REGULATORYS];
+	u8	status;
+};
+
+/*
+Caller Mode: Any
+
+Notes: To set the channel/modem/band
+This command will be used when channel/modem/band is changed.
+
+Command Mode
+
+*/
+struct	setphy_parm {
+	u8	rfchannel;
+	u8	modem;
+};
+
+/*
+Caller Mode: Any
+
+Notes: To get the current setting of channel/modem/band
+
+Command-Rsp Mode
+
+*/
+struct	getphy_parm {
+	u32 rsvd;
+};
+
+struct	getphy_rsp {
+	u8	rfchannel;
+	u8	modem;
+};
+
+struct readBB_parm {
+	u8	offset;
+};
+
+struct readBB_rsp {
+	u8	value;
+};
+
+struct readTSSI_parm {
+	u8	offset;
+};
+
+struct readTSSI_rsp {
+	u8	value;
+};
+
+struct writeBB_parm {
+	u8	offset;
+	u8	value;
+};
+
+struct readRF_parm {
+	u8	offset;
+};
+
+struct readRF_rsp {
+	u32	value;
+};
+
+struct writeRF_parm {
+	u32	offset;
+	u32	value;
+};
+
+struct getrfintfs_parm {
+	u8	rfintfs;
+};
+
+struct Tx_Beacon_param
+{
+	struct wlan_bssid_ex network;
+};
+
+/*  CMD param Formart for driver extra cmd handler */
+struct drvextra_cmd_parm {
+	int ec_id; /* extra cmd id */
+	int type_size; /*  Can use this field as the type id or command size =
*/
+	unsigned char *pbuf;
+};
+
+/*------------------- Below are used for RF/BB tunning ---------------=
------*/
+
+struct	setantenna_parm {
+	u8	tx_antset;
+	u8	rx_antset;
+	u8	tx_antenna;
+	u8	rx_antenna;
+};
+
+struct	enrateadaptive_parm {
+	u32	en;
+};
+
+struct settxagctbl_parm {
+	u32	txagc[MAX_RATES_LENGTH];
+};
+
+struct gettxagctbl_parm {
+	u32 rsvd;
+};
+
+struct gettxagctbl_rsp {
+	u32	txagc[MAX_RATES_LENGTH];
+};
+
+struct setagcctrl_parm {
+	u32	agcctrl;		/*  0: pure hw, 1: fw */
+};
+
+struct setssup_parm	{
+	u32	ss_ForceUp[MAX_RATES_LENGTH];
+};
+
+struct getssup_parm	{
+	u32 rsvd;
+};
+
+struct getssup_rsp	{
+	u8	ss_ForceUp[MAX_RATES_LENGTH];
+};
+
+struct setssdlevel_parm	{
+	u8	ss_DLevel[MAX_RATES_LENGTH];
+};
+
+struct getssdlevel_parm	{
+	u32 rsvd;
+};
+
+struct getssdlevel_rsp	{
+	u8	ss_DLevel[MAX_RATES_LENGTH];
+};
+
+struct setssulevel_parm	{
+	u8	ss_ULevel[MAX_RATES_LENGTH];
+};
+
+struct getssulevel_parm	{
+	u32 rsvd;
+};
+
+struct getssulevel_rsp	{
+	u8	ss_ULevel[MAX_RATES_LENGTH];
+};
+
+struct	setcountjudge_parm {
+	u8	count_judge[MAX_RATES_LENGTH];
+};
+
+struct	getcountjudge_parm {
+	u32 rsvd;
+};
+
+struct	getcountjudge_rsp {
+	u8	count_judge[MAX_RATES_LENGTH];
+};
+
+struct setratable_parm {
+	u8 ss_ForceUp[NumRates];
+	u8 ss_ULevel[NumRates];
+	u8 ss_DLevel[NumRates];
+	u8 count_judge[NumRates];
+};
+
+struct getratable_parm {
+                uint rsvd;
+};
+
+struct getratable_rsp {
+        u8 ss_ForceUp[NumRates];
+        u8 ss_ULevel[NumRates];
+        u8 ss_DLevel[NumRates];
+        u8 count_judge[NumRates];
+};
+
+/* to get TX,RX retry count */
+struct gettxretrycnt_parm{
+	unsigned int rsvd;
+};
+struct gettxretrycnt_rsp{
+	unsigned long tx_retrycnt;
+};
+
+struct getrxretrycnt_parm{
+	unsigned int rsvd;
+};
+struct getrxretrycnt_rsp{
+	unsigned long rx_retrycnt;
+};
+
+/* to get BCNOK,BCNERR count */
+struct getbcnokcnt_parm{
+	unsigned int rsvd;
+};
+struct getbcnokcnt_rsp{
+	unsigned long  bcnokcnt;
+};
+
+struct getbcnerrcnt_parm{
+	unsigned int rsvd;
+};
+struct getbcnerrcnt_rsp{
+	unsigned long bcnerrcnt;
+};
+
+/*  to get current TX power level */
+struct getcurtxpwrlevel_parm{
+	unsigned int rsvd;
+};
+
+struct getcurtxpwrlevel_rsp{
+	unsigned short tx_power;
+};
+
+struct setprobereqextraie_parm {
+	unsigned char e_id;
+	unsigned char ie_len;
+	unsigned char ie[0];
+};
+
+struct setassocreqextraie_parm {
+	unsigned char e_id;
+	unsigned char ie_len;
+	unsigned char ie[0];
+};
+
+struct setproberspextraie_parm {
+	unsigned char e_id;
+	unsigned char ie_len;
+	unsigned char ie[0];
+};
+
+struct setassocrspextraie_parm {
+	unsigned char e_id;
+	unsigned char ie_len;
+	unsigned char ie[0];
+};
+
+struct addBaReq_parm {
+	unsigned int tid;
+	u8	addr[ETH_ALEN];
+};
+
+/*H2C Handler index: 46 */
+struct set_ch_parm {
+	u8 ch;
+	u8 bw;
+	u8 ch_offset;
+};
+
+/*H2C Handler index: 59 */
+struct SetChannelPlan_param {
+	u8 channel_plan;
+};
+
+/*H2C Handler index: 60 */
+struct LedBlink_param {
+	struct led_8723a *pLed;
+};
+
+/*H2C Handler index: 61 */
+struct SetChannelSwitch_param {
+	u8 new_ch_no;
+};
+
+/*H2C Handler index: 62 */
+struct TDLSoption_param {
+	u8 addr[ETH_ALEN];
+	u8 option;
+};
+
+#define GEN_CMD_CODE(cmd)	cmd ## _CMD_
+
+
+/*
+
+Result:
+0x00: success
+0x01: sucess, and check Response.
+0x02: cmd ignored due to duplicated sequcne number
+0x03: cmd dropped due to invalid cmd code
+0x04: reserved.
+
+*/
+
+#define H2C_RSP_OFFSET			512
+
+#define H2C_SUCCESS			0x00
+#define H2C_SUCCESS_RSP			0x01
+#define H2C_DUPLICATED			0x02
+#define H2C_DROPPED			0x03
+#define H2C_PARAMETERS_ERROR		0x04
+#define H2C_REJECTED			0x05
+#define H2C_CMD_OVERFLOW		0x06
+#define H2C_RESERVED			0x07
+
+u8 rtw_setassocsta_cmd(struct rtw_adapter  *padapter, u8 *mac_addr);
+u8 rtw_setstandby_cmd(struct rtw_adapter *padapter, uint action);
+u8 rtw_sitesurvey_cmd23a(struct rtw_adapter  *padapter, struct cfg8021=
1_ssid *ssid, int ssid_num, struct rtw_ieee80211_channel *ch, int ch_nu=
m);
+u8 rtw_createbss_cmd23a(struct rtw_adapter  *padapter);
+u8 rtw_createbss_cmd23a_ex(struct rtw_adapter  *padapter, unsigned cha=
r *pbss, unsigned int sz);
+u8 rtw_setphy_cmd(struct rtw_adapter  *padapter, u8 modem, u8 ch);
+u8 rtw_setstakey_cmd23a(struct rtw_adapter  *padapter, u8 *psta, u8 un=
icast_key);
+u8 rtw_clearstakey_cmd23a(struct rtw_adapter *padapter, u8 *psta, u8 e=
ntry, u8 enqueue);
+u8 rtw_joinbss_cmd23a(struct rtw_adapter  *padapter, struct wlan_netwo=
rk* pnetwork);
+u8 rtw_disassoc_cmd23a(struct rtw_adapter *padapter, u32 deauth_timeou=
t_ms, bool enqueue);
+u8 rtw_setopmode_cmd23a(struct rtw_adapter  *padapter, enum ndis_802_1=
1_net_infra networktype);
+u8 rtw_setdatarate_cmd(struct rtw_adapter  *padapter, u8 *rateset);
+u8 rtw_setbasicrate_cmd(struct rtw_adapter  *padapter, u8 *rateset);
+u8 rtw_setbbreg_cmd(struct rtw_adapter * padapter, u8 offset, u8 val);
+u8 rtw_setrfreg_cmd(struct rtw_adapter * padapter, u8 offset, u32 val)=
;
+u8 rtw_getbbreg_cmd(struct rtw_adapter * padapter, u8 offset, u8 * pva=
l);
+u8 rtw_getrfreg_cmd(struct rtw_adapter * padapter, u8 offset, u8 * pva=
l);
+u8 rtw_setrfintfs_cmd(struct rtw_adapter  *padapter, u8 mode);
+u8 rtw_setrttbl_cmd(struct rtw_adapter  *padapter, struct setratable_p=
arm *prate_table);
+u8 rtw_getrttbl_cmd(struct rtw_adapter  *padapter, struct getratable_r=
sp *pval);
+
+u8 rtw_gettssi_cmd(struct rtw_adapter  *padapter, u8 offset,u8 *pval);
+u8 rtw_setfwdig_cmd(struct rtw_adapter*padapter, u8 type);
+u8 rtw_setfwra_cmd(struct rtw_adapter*padapter, u8 type);
+
+u8 rtw_addbareq_cmd23a(struct rtw_adapter*padapter, u8 tid, u8 *addr);
+
+u8 rtw_dynamic_chk_wk_cmd23a(struct rtw_adapter *adapter);
+
+u8 rtw_lps_ctrl_wk_cmd23a(struct rtw_adapter*padapter, u8 lps_ctrl_typ=
e, u8 enqueue);
+
+u8 rtw_ps_cmd23a(struct rtw_adapter*padapter);
+
+#ifdef CONFIG_8723AU_AP_MODE
+u8 rtw_chk_hi_queue_cmd23a(struct rtw_adapter*padapter);
+#endif
+
+u8 rtw_set_ch_cmd23a(struct rtw_adapter*padapter, u8 ch, u8 bw, u8 ch_=
offset, u8 enqueue);
+u8 rtw_set_chplan_cmd(struct rtw_adapter*padapter, u8 chplan, u8 enque=
ue);
+u8 rtw_led_blink_cmd(struct rtw_adapter*padapter, struct led_8723a *pL=
ed);
+u8 rtw_set_csa_cmd(struct rtw_adapter*padapter, u8 new_ch_no);
+u8 rtw_tdls_cmd(struct rtw_adapter*padapter, u8 *addr, u8 option);
+
+u8 rtw_c2h_wk_cmd23a(struct rtw_adapter *padapter, u8 *c2h_evt);
+
+u8 rtw_drvextra_cmd_hdl23a(struct rtw_adapter *padapter, unsigned char=
 *pbuf);
+
+void rtw_survey_cmd_callback23a(struct rtw_adapter  *padapter, struct =
cmd_obj *pcmd);
+void rtw_disassoc_cmd23a_callback(struct rtw_adapter  *padapter, struc=
t cmd_obj *pcmd);
+void rtw_joinbss_cmd23a_callback(struct rtw_adapter  *padapter, struct=
 cmd_obj *pcmd);
+void rtw_createbss_cmd23a_callback(struct rtw_adapter  *padapter, stru=
ct cmd_obj *pcmd);
+void rtw_getbbrfreg_cmdrsp_callback23a(struct rtw_adapter  *padapter, =
struct cmd_obj *pcmd);
+void rtw_readtssi_cmdrsp_callback(struct rtw_adapter*	padapter,  struc=
t cmd_obj *pcmd);
+
+void rtw_setstaKey_cmdrsp_callback23a(struct rtw_adapter  *padapter,  =
struct cmd_obj *pcmd);
+void rtw_setassocsta_cmdrsp_callback23a(struct rtw_adapter  *padapter,=
  struct cmd_obj *pcmd);
+void rtw_getrttbl_cmdrsp_callback(struct rtw_adapter  *padapter,  stru=
ct cmd_obj *pcmd);
+
+struct _cmd_callback {
+	u32	cmd_code;
+	void (*callback)(struct rtw_adapter  *padapter, struct cmd_obj *cmd);
+};
+
+enum rtw_h2c_cmd {
+	GEN_CMD_CODE(_Read_MACREG) ,	/*0*/
+	GEN_CMD_CODE(_Write_MACREG) ,
+	GEN_CMD_CODE(_Read_BBREG) ,
+	GEN_CMD_CODE(_Write_BBREG) ,
+	GEN_CMD_CODE(_Read_RFREG) ,
+	GEN_CMD_CODE(_Write_RFREG) , /*5*/
+	GEN_CMD_CODE(_Read_EEPROM) ,
+	GEN_CMD_CODE(_Write_EEPROM) ,
+	GEN_CMD_CODE(_Read_EFUSE) ,
+	GEN_CMD_CODE(_Write_EFUSE) ,
+
+	GEN_CMD_CODE(_Read_CAM) ,	/*10*/
+	GEN_CMD_CODE(_Write_CAM) ,
+	GEN_CMD_CODE(_setBCNITV),
+	GEN_CMD_CODE(_setMBIDCFG),
+	GEN_CMD_CODE(_JoinBss),   /*14*/
+	GEN_CMD_CODE(_DisConnect) , /*15*/
+	GEN_CMD_CODE(_CreateBss) ,
+	GEN_CMD_CODE(_SetOpMode) ,
+	GEN_CMD_CODE(_SiteSurvey),  /*18*/
+	GEN_CMD_CODE(_SetAuth) ,
+
+	GEN_CMD_CODE(_SetKey) ,	/*20*/
+	GEN_CMD_CODE(_SetStaKey) ,
+	GEN_CMD_CODE(_SetAssocSta) ,
+	GEN_CMD_CODE(_DelAssocSta) ,
+	GEN_CMD_CODE(_SetStaPwrState) ,
+	GEN_CMD_CODE(_SetBasicRate) , /*25*/
+	GEN_CMD_CODE(_GetBasicRate) ,
+	GEN_CMD_CODE(_SetDataRate) ,
+	GEN_CMD_CODE(_GetDataRate) ,
+	GEN_CMD_CODE(_SetPhyInfo) ,
+
+	GEN_CMD_CODE(_GetPhyInfo) ,	/*30*/
+	GEN_CMD_CODE(_SetPhy) ,
+	GEN_CMD_CODE(_GetPhy) ,
+	GEN_CMD_CODE(_readRssi) ,
+	GEN_CMD_CODE(_readGain) ,
+	GEN_CMD_CODE(_SetAtim) , /*35*/
+	GEN_CMD_CODE(_SetPwrMode) ,
+	GEN_CMD_CODE(_JoinbssRpt),
+	GEN_CMD_CODE(_SetRaTable) ,
+	GEN_CMD_CODE(_GetRaTable) ,
+
+	GEN_CMD_CODE(_GetCCXReport), /*40*/
+	GEN_CMD_CODE(_GetDTMReport),
+	GEN_CMD_CODE(_GetTXRateStatistics),
+	GEN_CMD_CODE(_SetUsbSuspend),
+	GEN_CMD_CODE(_SetH2cLbk),
+	GEN_CMD_CODE(_AddBAReq) , /*45*/
+	GEN_CMD_CODE(_SetChannel), /*46*/
+	GEN_CMD_CODE(_SetTxPower),
+	GEN_CMD_CODE(_SwitchAntenna),
+	GEN_CMD_CODE(_SetCrystalCap),
+	GEN_CMD_CODE(_SetSingleCarrierTx), /*50*/
+
+	GEN_CMD_CODE(_SetSingleToneTx),/*51*/
+	GEN_CMD_CODE(_SetCarrierSuppressionTx),
+	GEN_CMD_CODE(_SetContinuousTx),
+	GEN_CMD_CODE(_SwitchBandwidth), /*54*/
+	GEN_CMD_CODE(_TX_Beacon), /*55*/
+
+	GEN_CMD_CODE(_Set_MLME_EVT), /*56*/
+	GEN_CMD_CODE(_Set_Drv_Extra), /*57*/
+	GEN_CMD_CODE(_Set_H2C_MSG), /*58*/
+
+	GEN_CMD_CODE(_SetChannelPlan), /*59*/
+	GEN_CMD_CODE(_LedBlink), /*60*/
+
+	GEN_CMD_CODE(_SetChannelSwitch), /*61*/
+	GEN_CMD_CODE(_TDLS), /*62*/
+
+	MAX_H2CCMD
+};
+
+#define _GetBBReg_CMD_		_Read_BBREG_CMD_
+#define _SetBBReg_CMD_		_Write_BBREG_CMD_
+#define _GetRFReg_CMD_		_Read_RFREG_CMD_
+#define _SetRFReg_CMD_		_Write_RFREG_CMD_
+
+extern struct _cmd_callback	rtw_cmd_callback[];
+
+#endif /*  _CMD_H_ */
diff --git a/drivers/staging/rtl8723au/include/rtw_debug.h b/drivers/st=
aging/rtl8723au/include/rtw_debug.h
new file mode 100644
index 0000000..a69d6e2
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_debug.h
@@ -0,0 +1,192 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *
+ *********************************************************************=
*********/
+#ifndef __RTW_DEBUG_H__
+#define __RTW_DEBUG_H__
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+#define _drv_always_			1
+#define _drv_emerg_			2
+#define _drv_alert_			3
+#define _drv_err_			4
+#define	_drv_warning_			5
+#define _drv_notice_			6
+#define _drv_info_			7
+#define	_drv_debug_			8
+
+#define _module_rtl871x_xmit_c_		BIT(0)
+#define _module_xmit_osdep_c_		BIT(1)
+#define _module_rtl871x_recv_c_		BIT(2)
+#define _module_recv_osdep_c_		BIT(3)
+#define _module_rtl871x_mlme_c_		BIT(4)
+#define _module_mlme_osdep_c_		BIT(5)
+#define _module_rtl871x_sta_mgt_c_	BIT(6)
+#define _module_rtl871x_cmd_c_		BIT(7)
+#define _module_cmd_osdep_c_		BIT(8)
+#define _module_rtl871x_io_c_		BIT(9)
+#define _module_io_osdep_c_		BIT(10)
+#define _module_os_intfs_c_		BIT(11)
+#define _module_rtl871x_security_c_	BIT(12)
+#define _module_rtl871x_eeprom_c_	BIT(13)
+#define _module_hal_init_c_		BIT(14)
+#define _module_hci_hal_init_c_		BIT(15)
+#define _module_rtl871x_ioctl_c_	BIT(16)
+#define _module_rtl871x_ioctl_set_c_	BIT(17)
+#define _module_rtl871x_ioctl_query_c_	BIT(18)
+#define _module_rtl871x_pwrctrl_c_	BIT(19)
+#define _module_hci_intfs_c_		BIT(20)
+#define _module_hci_ops_c_		BIT(21)
+#define _module_osdep_service_c_	BIT(22)
+#define _module_mp_			BIT(23)
+#define _module_hci_ops_os_c_		BIT(24)
+#define _module_rtl871x_ioctl_os_c	BIT(25)
+#define _module_rtl8712_cmd_c_		BIT(26)
+#define	_module_rtl8192c_xmit_c_	BIT(28)
+#define _module_hal_xmit_c_		BIT(28) /* duplication intentional */
+#define _module_efuse_			BIT(29)
+#define _module_rtl8712_recv_c_		BIT(30)
+#define _module_rtl8712_led_c_		BIT(31)
+
+#undef _MODULE_DEFINE_
+
+#if defined _RTW_XMIT_C_
+	#define _MODULE_DEFINE_	_module_rtl871x_xmit_c_
+#elif defined _XMIT_OSDEP_C_
+	#define _MODULE_DEFINE_	_module_xmit_osdep_c_
+#elif defined _RTW_RECV_C_
+	#define _MODULE_DEFINE_	_module_rtl871x_recv_c_
+#elif defined _RECV_OSDEP_C_
+	#define _MODULE_DEFINE_	_module_recv_osdep_c_
+#elif defined _RTW_MLME_C_
+	#define _MODULE_DEFINE_	_module_rtl871x_mlme_c_
+#elif defined _MLME_OSDEP_C_
+	#define _MODULE_DEFINE_	_module_mlme_osdep_c_
+#elif defined _RTW_MLME_EXT_C_
+	#define _MODULE_DEFINE_ 1
+#elif defined _RTW_STA_MGT_C_
+	#define _MODULE_DEFINE_	_module_rtl871x_sta_mgt_c_
+#elif defined _RTW_CMD_C_
+	#define _MODULE_DEFINE_	_module_rtl871x_cmd_c_
+#elif defined _CMD_OSDEP_C_
+	#define _MODULE_DEFINE_	_module_cmd_osdep_c_
+#elif defined _RTW_IO_C_
+	#define _MODULE_DEFINE_	_module_rtl871x_io_c_
+#elif defined _IO_OSDEP_C_
+	#define _MODULE_DEFINE_	_module_io_osdep_c_
+#elif defined _OS_INTFS_C_
+	#define	_MODULE_DEFINE_	_module_os_intfs_c_
+#elif defined _RTW_SECURITY_C_
+	#define	_MODULE_DEFINE_	_module_rtl871x_security_c_
+#elif defined _RTW_EEPROM_C_
+	#define	_MODULE_DEFINE_	_module_rtl871x_eeprom_c_
+#elif defined _HAL_INTF_C_
+	#define	_MODULE_DEFINE_	_module_hal_init_c_
+#elif (defined _HCI_HAL_INIT_C_) || (defined _SDIO_HALINIT_C_)
+	#define	_MODULE_DEFINE_	_module_hci_hal_init_c_
+#elif defined _RTL871X_IOCTL_C_
+	#define	_MODULE_DEFINE_	_module_rtl871x_ioctl_c_
+#elif defined _RTL871X_IOCTL_SET_C_
+	#define	_MODULE_DEFINE_	_module_rtl871x_ioctl_set_c_
+#elif defined _RTL871X_IOCTL_QUERY_C_
+	#define	_MODULE_DEFINE_	_module_rtl871x_ioctl_query_c_
+#elif defined _RTL871X_PWRCTRL_C_
+	#define	_MODULE_DEFINE_	_module_rtl871x_pwrctrl_c_
+#elif defined _RTW_PWRCTRL_C_
+	#define	_MODULE_DEFINE_	1
+#elif defined _HCI_INTF_C_
+	#define	_MODULE_DEFINE_	_module_hci_intfs_c_
+#elif defined _HCI_OPS_C_
+	#define	_MODULE_DEFINE_	_module_hci_ops_c_
+#elif defined _SDIO_OPS_C_
+	#define	_MODULE_DEFINE_ 1
+#elif defined _OSDEP_HCI_INTF_C_
+	#define	_MODULE_DEFINE_	_module_hci_intfs_c_
+#elif defined _OSDEP_SERVICE_C_
+	#define	_MODULE_DEFINE_	_module_osdep_service_c_
+#elif defined _HCI_OPS_OS_C_
+	#define	_MODULE_DEFINE_	_module_hci_ops_os_c_
+#elif defined _RTL871X_IOCTL_LINUX_C_
+	#define	_MODULE_DEFINE_	_module_rtl871x_ioctl_os_c
+#elif defined _RTL8712_CMD_C_
+	#define	_MODULE_DEFINE_	_module_rtl8712_cmd_c_
+#elif defined _RTL8192C_XMIT_C_
+	#define	_MODULE_DEFINE_	1
+#elif defined _RTL8723AS_XMIT_C_
+	#define	_MODULE_DEFINE_	1
+#elif defined _RTL8712_RECV_C_
+	#define	_MODULE_DEFINE_	_module_rtl8712_recv_c_
+#elif defined _RTL8192CU_RECV_C_
+	#define	_MODULE_DEFINE_	_module_rtl8712_recv_c_
+#elif defined _RTL871X_MLME_EXT_C_
+	#define _MODULE_DEFINE_	_module_mlme_osdep_c_
+#elif defined _RTW_MP_C_
+	#define	_MODULE_DEFINE_	_module_mp_
+#elif defined _RTW_MP_IOCTL_C_
+	#define	_MODULE_DEFINE_	_module_mp_
+#elif defined _RTW_EFUSE_C_
+	#define	_MODULE_DEFINE_	_module_efuse_
+#endif
+
+#define DRIVER_PREFIX	"RTL8723AU: "
+#define DEBUG_LEVEL	(_drv_err_)
+#define DBG_8723A_LEVEL(_level, fmt, arg...)				\
+	do {								\
+		if (_level <=3D GlobalDebugLevel23A)				\
+			pr_info(DRIVER_PREFIX"ERROR " fmt, ##arg);\
+	} while (0)
+
+#define DBG_8723A(...)							\
+	do {								\
+		if (_drv_err_ <=3D GlobalDebugLevel23A)			\
+			pr_info(DRIVER_PREFIX __VA_ARGS__);		\
+	} while (0)
+
+#define MSG_8723A(...)							\
+	do {								\
+		if (_drv_err_ <=3D GlobalDebugLevel23A)			\
+			pr_info(DRIVER_PREFIX __VA_ARGS__);		\
+	} while (0)
+
+extern u32 GlobalDebugLevel23A;
+
+
+#define RT_TRACE(_Comp, _Level, Fmt)					\
+do {									\
+	if (_Level <=3D GlobalDebugLevel23A) {				\
+		pr_info("%s [0x%08x,%d]", DRIVER_PREFIX,		\
+			 (unsigned int)_Comp, _Level);			\
+		pr_info Fmt;						\
+	}								\
+} while (0)
+
+#define RT_PRINT_DATA(_Comp, _Level, _TitleString, _HexData,		\
+		      _HexDataLen)					\
+	if (_Level <=3D GlobalDebugLevel23A) {				\
+		int __i;						\
+		u8	*ptr =3D (u8 *)_HexData;				\
+		pr_info("%s", DRIVER_PREFIX);				\
+		pr_info(_TitleString);					\
+		for (__i =3D 0; __i < (int)_HexDataLen; __i++) {		\
+			printk("%02X%s", ptr[__i],			\
+			       (((__i + 1) % 4) =3D=3D 0) ? "  " : " ");	\
+			if (((__i + 1) % 16) =3D=3D 0)			\
+				printk("\n");				\
+		}							\
+		printk("\n");						\
+	}
+
+#endif	/* __RTW_DEBUG_H__ */
diff --git a/drivers/staging/rtl8723au/include/rtw_eeprom.h b/drivers/s=
taging/rtl8723au/include/rtw_eeprom.h
new file mode 100644
index 0000000..d008f03
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_eeprom.h
@@ -0,0 +1,135 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTW_EEPROM_H__
+#define __RTW_EEPROM_H__
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+#define	RTL8712_EEPROM_ID			0x8712
+/* define	EEPROM_MAX_SIZE			256 */
+
+#define	HWSET_MAX_SIZE_512		512
+#define	EEPROM_MAX_SIZE			HWSET_MAX_SIZE_512
+
+#define	CLOCK_RATE					50			/* 100us */
+
+/*  EEPROM opcodes */
+#define EEPROM_READ_OPCODE		06
+#define EEPROM_WRITE_OPCODE		05
+#define EEPROM_ERASE_OPCODE		07
+#define EEPROM_EWEN_OPCODE		19      /*  Erase/write enable */
+#define EEPROM_EWDS_OPCODE		16      /*  Erase/write disable */
+
+/* Country codes */
+#define USA							0x555320
+#define EUROPE						0x1 /* temp, should be provided later */
+#define JAPAN						0x2 /* temp, should be provided later */
+
+#define	EEPROM_CID_DEFAULT			0x0
+#define	EEPROM_CID_ALPHA				0x1
+#define	EEPROM_CID_Senao				0x3
+#define	EEPROM_CID_NetCore				0x5
+#define	EEPROM_CID_CAMEO				0X8
+#define	EEPROM_CID_SITECOM				0x9
+#define	EEPROM_CID_COREGA				0xB
+#define	EEPROM_CID_EDIMAX_BELKIN		0xC
+#define	EEPROM_CID_SERCOMM_BELKIN		0xE
+#define	EEPROM_CID_CAMEO1				0xF
+#define	EEPROM_CID_WNC_COREGA		0x12
+#define	EEPROM_CID_CLEVO				0x13
+#define	EEPROM_CID_WHQL				0xFE /*  added by chiyoko for dtm, 20090108=
 */
+
+/*  */
+/*  Customer ID, note that: */
+/*  This variable is initiailzed through EEPROM or registry, */
+/*  however, its definition may be different with that in EEPROM for *=
/
+/*  EEPROM size consideration. So, we have to perform proper translati=
on between them. */
+/*  Besides, CustomerID of registry has precedence of that of EEPROM. =
*/
+/*  defined below. 060703, by rcnjko. */
+/*  */
+enum rt_customer_id
+{
+	RT_CID_DEFAULT =3D 0,
+	RT_CID_8187_ALPHA0 =3D 1,
+	RT_CID_8187_SERCOMM_PS =3D 2,
+	RT_CID_8187_HW_LED =3D 3,
+	RT_CID_8187_NETGEAR =3D 4,
+	RT_CID_WHQL =3D 5,
+	RT_CID_819x_CAMEO  =3D 6,
+	RT_CID_819x_RUNTOP =3D 7,
+	RT_CID_819x_Senao =3D 8,
+	RT_CID_TOSHIBA =3D 9,	/*  Merge by Jacken, 2008/01/31. */
+	RT_CID_819x_Netcore =3D 10,
+	RT_CID_Nettronix =3D 11,
+	RT_CID_DLINK =3D 12,
+	RT_CID_PRONET =3D 13,
+	RT_CID_COREGA =3D 14,
+	RT_CID_CHINA_MOBILE =3D 15,
+	RT_CID_819x_ALPHA =3D 16,
+	RT_CID_819x_Sitecom =3D 17,
+	RT_CID_CCX =3D 18, /*  It's set under CCX logo test and isn't demande=
d for CCX functions, but for test behavior like retry limit and tx repo=
rt. By Bruce, 2009-02-17. */
+	RT_CID_819x_Lenovo =3D 19,
+	RT_CID_819x_QMI =3D 20,
+	RT_CID_819x_Edimax_Belkin =3D 21,
+	RT_CID_819x_Sercomm_Belkin =3D 22,
+	RT_CID_819x_CAMEO1 =3D 23,
+	RT_CID_819x_MSI =3D 24,
+	RT_CID_819x_Acer =3D 25,
+	RT_CID_819x_AzWave_ASUS =3D 26,
+	RT_CID_819x_AzWave =3D 27, /*  For AzWave in PCIe, The ID is AzWave u=
se and not only Asus */
+	RT_CID_819x_HP =3D 28,
+	RT_CID_819x_WNC_COREGA =3D 29,
+	RT_CID_819x_Arcadyan_Belkin =3D 30,
+	RT_CID_819x_SAMSUNG =3D 31,
+	RT_CID_819x_CLEVO =3D 32,
+	RT_CID_819x_DELL =3D 33,
+	RT_CID_819x_PRONETS =3D 34,
+	RT_CID_819x_Edimax_ASUS =3D 35,
+	RT_CID_819x_CAMEO_NETGEAR =3D 36,
+	RT_CID_PLANEX =3D 37,
+	RT_CID_CC_C =3D 38,
+	RT_CID_819x_Xavi =3D 39,
+	RT_CID_819x_FUNAI_TV =3D 40,
+	RT_CID_819x_ALPHA_WD=3D41,
+};
+
+struct eeprom_priv {
+	u8		bautoload_fail_flag;
+	u8		bloadfile_fail_flag;
+	u8		bloadmac_fail_flag;
+	/* u8		bempty; */
+	/* u8		sys_config; */
+	u8		mac_addr[6];	/* PermanentAddress */
+	/* u8		config0; */
+	u16		channel_plan;
+	/* u8		country_string[3]; */
+	/* u8		tx_power_b[15]; */
+	/* u8		tx_power_g[15]; */
+	/* u8		tx_power_a[201]; */
+
+	u8		EepromOrEfuse;
+
+	u8		efuse_eeprom_data[HWSET_MAX_SIZE_512]; /* 92C:256bytes, 88E:512by=
tes, we use union set (512bytes) */
+};
+
+void eeprom_write16(struct rtw_adapter *padapter, u16 reg, u16 data);
+u16 eeprom_read16(struct rtw_adapter *padapter, u16 reg);
+void read_eeprom_content(struct rtw_adapter *padapter);
+void eeprom_read_sz(struct rtw_adapter * padapter, u16 reg,u8* data, u=
32 sz);
+
+void read_eeprom_content_by_attrib(struct rtw_adapter *padapter);
+
+#endif  /* __RTL871X_EEPROM_H__ */
diff --git a/drivers/staging/rtl8723au/include/rtw_efuse.h b/drivers/st=
aging/rtl8723au/include/rtw_efuse.h
new file mode 100644
index 0000000..a775505
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_efuse.h
@@ -0,0 +1,109 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *
+ *********************************************************************=
*********/
+#ifndef __RTW_EFUSE_H__
+#define __RTW_EFUSE_H__
+
+#include <osdep_service.h>
+
+#define	EFUSE_ERROE_HANDLE		1
+
+#define	PG_STATE_HEADER			0x01
+#define	PG_STATE_WORD_0		0x02
+#define	PG_STATE_WORD_1		0x04
+#define	PG_STATE_WORD_2		0x08
+#define	PG_STATE_WORD_3		0x10
+#define	PG_STATE_DATA			0x20
+
+#define	PG_SWBYTE_H			0x01
+#define	PG_SWBYTE_L			0x02
+
+#define	PGPKT_DATA_SIZE		8
+
+#define	EFUSE_WIFI				0
+#define	EFUSE_BT				1
+
+enum _EFUSE_DEF_TYPE {
+	TYPE_EFUSE_MAX_SECTION				=3D 0,
+	TYPE_EFUSE_REAL_CONTENT_LEN			=3D 1,
+	TYPE_AVAILABLE_EFUSE_BYTES_BANK		=3D 2,
+	TYPE_AVAILABLE_EFUSE_BYTES_TOTAL	=3D 3,
+	TYPE_EFUSE_MAP_LEN					=3D 4,
+	TYPE_EFUSE_PROTECT_BYTES_BANK		=3D 5,
+	TYPE_EFUSE_CONTENT_LEN_BANK			=3D 6,
+};
+
+/* E-Fuse */
+#define EFUSE_MAP_SIZE      256
+
+#define EFUSE_MAX_SIZE      512
+/* end of E-Fuse */
+
+#define		EFUSE_MAX_MAP_LEN		256
+#define		EFUSE_MAX_HW_SIZE		512
+#define		EFUSE_MAX_SECTION_BASE	16
+
+#define EXT_HEADER(header) ((header & 0x1F ) =3D=3D 0x0F)
+#define ALL_WORDS_DISABLED(wde)	((wde & 0x0F) =3D=3D 0x0F)
+#define GET_HDR_OFFSET_2_0(header) ( (header & 0xE0) >> 5)
+
+#define		EFUSE_REPEAT_THRESHOLD_			3
+
+/*  */
+/*	The following is for BT Efuse definition */
+/*  */
+#define		EFUSE_BT_MAX_MAP_LEN		1024
+#define		EFUSE_MAX_BANK			4
+#define		EFUSE_MAX_BT_BANK		(EFUSE_MAX_BANK-1)
+/*  */
+/*--------------------------Define Parameters-------------------------=
------*/
+#define		EFUSE_MAX_WORD_UNIT			4
+
+/*------------------------------Define structure----------------------=
------*/
+struct pg_pkt_struct {
+	u8 offset;
+	u8 word_en;
+	u8 data[8];
+	u8 word_cnts;
+};
+
+/*------------------------Export global variable----------------------=
------*/
+
+u8	efuse_GetCurrentSize23a(struct rtw_adapter *padapter, u16 *size);
+u16	efuse_GetMaxSize23a(struct rtw_adapter *padapter);
+u8	rtw_efuse_access23a(struct rtw_adapter *padapter, u8 bRead, u16 sta=
rt_addr, u16 cnts, u8 *data);
+u8	rtw_efuse_map_read23a(struct rtw_adapter *padapter, u16 addr, u16 c=
nts, u8 *data);
+u8	rtw_efuse_map_write(struct rtw_adapter *padapter, u16 addr, u16 cnt=
s, u8 *data);
+u8	rtw_BT_efuse_map_read23a(struct rtw_adapter *padapter, u16 addr, u1=
6 cnts, u8 *data);
+u8	rtw_BT_efuse_map_write(struct rtw_adapter *padapter, u16 addr, u16 =
cnts, u8 *data);
+
+u16	Efuse_GetCurrentSize23a(struct rtw_adapter *pAdapter, u8 efuseType=
);
+u8	Efuse_CalculateWordCnts23a(u8 word_en);
+void	ReadEFuseByte23a(struct rtw_adapter *Adapter, u16 _offset, u8 *pb=
uf);
+void	EFUSE_GetEfuseDefinition23a(struct rtw_adapter *pAdapter, u8 efus=
eType, u8 type, void *pOut);
+u8	efuse_OneByteRead23a(struct rtw_adapter *pAdapter, u16 addr, u8 *da=
ta);
+u8	efuse_OneByteWrite23a(struct rtw_adapter *pAdapter, u16 addr, u8 da=
ta);
+
+void	Efuse_PowerSwitch23a(struct rtw_adapter *pAdapter,u8	bWrite,u8	 P=
wrState);
+int	Efuse_PgPacketRead23a(struct rtw_adapter *pAdapter, u8 offset, u8 =
*data);
+int	Efuse_PgPacketWrite23a(struct rtw_adapter *pAdapter, u8 offset, u8=
 word_en, u8 *data);
+void	efuse_WordEnableDataRead23a(u8 word_en, u8 *sourdata, u8 *targetd=
ata);
+u8	Efuse_WordEnableDataWrite23a(struct rtw_adapter *pAdapter, u16 efus=
e_addr, u8 word_en, u8 *data);
+
+u8	EFUSE_Read1Byte23a(struct rtw_adapter *pAdapter, u16 Address);
+void	EFUSE_ShadowMapUpdate23a(struct rtw_adapter *pAdapter, u8 efuseTy=
pe);
+void	EFUSE_ShadowRead23a(struct rtw_adapter *pAdapter, u8 Type, u16 Of=
fset, u32 *Value);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtw_event.h b/drivers/st=
aging/rtl8723au/include/rtw_event.h
new file mode 100644
index 0000000..bb20640
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_event.h
@@ -0,0 +1,114 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef _RTW_EVENT_H_
+#define _RTW_EVENT_H_
+
+#include <osdep_service.h>
+
+#include <wlan_bssdef.h>
+
+/*
+Used to report a bss has been scanned
+
+*/
+struct survey_event	{
+	struct wlan_bssid_ex bss;
+};
+
+/*
+Used to report that the requested site survey has been done.
+
+bss_cnt indicates the number of bss that has been reported.
+
+
+*/
+struct surveydone_event {
+	unsigned int	bss_cnt;
+
+};
+
+/*
+Used to report the link result of joinning the given bss
+
+
+join_res:
+-1: authentication fail
+-2: association fail
+> 0: TID
+
+*/
+struct joinbss_event {
+	struct	wlan_network	network;
+};
+
+/*
+Used to report a given STA has joinned the created BSS.
+It is used in AP/Ad-HoC(M) mode.
+
+
+*/
+struct stassoc_event {
+	unsigned char macaddr[6];
+	unsigned char rsvd[2];
+	int    cam_id;
+
+};
+
+struct stadel_event {
+ unsigned char macaddr[6];
+ unsigned char rsvd[2]; /* for reason */
+ int mac_id;
+};
+
+struct addba_event
+{
+	unsigned int tid;
+};
+
+#define GEN_EVT_CODE(event)	event ## _EVT_
+
+struct fwevent {
+	u32	parmsize;
+	void (*event_callback)(struct rtw_adapter *dev, u8 *pbuf);
+};
+
+
+#define C2HEVENT_SZ			32
+
+struct event_node{
+	unsigned char *node;
+	unsigned char evt_code;
+	unsigned short evt_sz;
+	volatile int	*caller_ff_tail;
+	int	caller_ff_sz;
+};
+
+struct c2hevent_queue {
+	volatile int	head;
+	volatile int	tail;
+	struct	event_node	nodes[C2HEVENT_SZ];
+	unsigned char	seq;
+};
+
+#define NETWORK_QUEUE_SZ	4
+
+struct network_queue {
+	volatile int	head;
+	volatile int	tail;
+	struct wlan_bssid_ex networks[NETWORK_QUEUE_SZ];
+};
+
+
+#endif /*  _WLANEVENT_H_ */
diff --git a/drivers/staging/rtl8723au/include/rtw_ht.h b/drivers/stagi=
ng/rtl8723au/include/rtw_ht.h
new file mode 100644
index 0000000..7fe0aa4
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_ht.h
@@ -0,0 +1,43 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef _RTW_HT_H_
+#define _RTW_HT_H_
+
+#include <osdep_service.h>
+#include "linux/ieee80211.h"
+#include "wifi.h"
+
+struct ht_priv
+{
+	u32	ht_option;
+	u32	ampdu_enable;/* for enable Tx A-MPDU */
+	/* u8	baddbareq_issued[16]; */
+	u32	tx_amsdu_enable;/* for enable Tx A-MSDU */
+	u32	tx_amdsu_maxlen; /*  1: 8k, 0:4k ; default:8k, for tx */
+	u32	rx_ampdu_maxlen; /* for rx reordering ctrl win_sz, updated when j=
oin_callback. */
+
+	u8	bwmode;/*  */
+	u8	ch_offset;/* PRIME_CHNL_OFFSET */
+	u8	sgi;/* short GI */
+
+	/* for processing Tx A-MPDU */
+	u8	agg_enable_bitmap;
+	/* u8	ADDBA_retry_count; */
+	u8	candidate_tid_bitmap;
+
+	struct ieee80211_ht_cap ht_cap;
+};
+
+#endif	/* _RTL871X_HT_H_ */
diff --git a/drivers/staging/rtl8723au/include/rtw_io.h b/drivers/stagi=
ng/rtl8723au/include/rtw_io.h
new file mode 100644
index 0000000..8d39d800
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_io.h
@@ -0,0 +1,416 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+
+#ifndef _RTW_IO_H_
+#define _RTW_IO_H_
+
+#include <osdep_service.h>
+#include <osdep_intf.h>
+
+#include <asm/byteorder.h>
+#include <linux/semaphore.h>
+#include <linux/list.h>
+/* include <linux/smp_lock.h> */
+#include <linux/spinlock.h>
+#include <asm/atomic.h>
+
+#include <linux/usb.h>
+#include <linux/usb/ch9.h>
+
+#define rtw_usb_buffer_alloc(dev, size, dma) usb_alloc_coherent((dev),=
 (size), (in_interrupt() ? GFP_ATOMIC : GFP_KERNEL), (dma))
+#define rtw_usb_buffer_free(dev, size, addr, dma) usb_free_coherent((d=
ev), (size), (addr), (dma))
+
+#define NUM_IOREQ		8
+
+#define MAX_PROT_SZ	(64-16)
+
+#define _IOREADY			0
+#define _IO_WAIT_COMPLETE   1
+#define _IO_WAIT_RSP        2
+
+/*  IO COMMAND TYPE */
+#define _IOSZ_MASK_		(0x7F)
+#define _IO_WRITE_		BIT(7)
+#define _IO_FIXED_		BIT(8)
+#define _IO_BURST_		BIT(9)
+#define _IO_BYTE_		BIT(10)
+#define _IO_HW_			BIT(11)
+#define _IO_WORD_		BIT(12)
+#define _IO_SYNC_		BIT(13)
+#define _IO_CMDMASK_	(0x1F80)
+
+
+/*
+	For prompt mode accessing, caller shall free io_req
+	Otherwise, io_handler will free io_req
+*/
+
+
+
+/*  IO STATUS TYPE */
+#define _IO_ERR_		BIT(2)
+#define _IO_SUCCESS_	BIT(1)
+#define _IO_DONE_		BIT(0)
+
+
+#define IO_RD32			(_IO_SYNC_ | _IO_WORD_)
+#define IO_RD16			(_IO_SYNC_ | _IO_HW_)
+#define IO_RD8			(_IO_SYNC_ | _IO_BYTE_)
+
+#define IO_RD32_ASYNC	(_IO_WORD_)
+#define IO_RD16_ASYNC	(_IO_HW_)
+#define IO_RD8_ASYNC	(_IO_BYTE_)
+
+#define IO_WR32			(_IO_WRITE_ | _IO_SYNC_ | _IO_WORD_)
+#define IO_WR16			(_IO_WRITE_ | _IO_SYNC_ | _IO_HW_)
+#define IO_WR8			(_IO_WRITE_ | _IO_SYNC_ | _IO_BYTE_)
+
+#define IO_WR32_ASYNC	(_IO_WRITE_ | _IO_WORD_)
+#define IO_WR16_ASYNC	(_IO_WRITE_ | _IO_HW_)
+#define IO_WR8_ASYNC	(_IO_WRITE_ | _IO_BYTE_)
+
+/*
+
+	Only Sync. burst accessing is provided.
+
+*/
+
+#define IO_WR_BURST(x)		(_IO_WRITE_ | _IO_SYNC_ | _IO_BURST_ | ( (x) &=
 _IOSZ_MASK_))
+#define IO_RD_BURST(x)		(_IO_SYNC_ | _IO_BURST_ | ( (x) & _IOSZ_MASK_)=
)
+
+
+
+/* below is for the intf_option bit defition... */
+
+#define _INTF_ASYNC_	BIT(0)	/* support async io */
+
+struct intf_priv;
+struct intf_hdl;
+struct io_queue;
+
+struct _io_ops
+{
+		u8 (*_read8)(struct intf_hdl *pintfhdl, u32 addr);
+		u16 (*_read16)(struct intf_hdl *pintfhdl, u32 addr);
+		u32 (*_read32)(struct intf_hdl *pintfhdl, u32 addr);
+
+		int (*_write8)(struct intf_hdl *pintfhdl, u32 addr, u8 val);
+		int (*_write16)(struct intf_hdl *pintfhdl, u32 addr, u16 val);
+		int (*_write32)(struct intf_hdl *pintfhdl, u32 addr, u32 val);
+		int (*_writeN)(struct intf_hdl *pintfhdl, u32 addr, u32 length, u8 *=
pdata);
+
+		int (*_write8_async)(struct intf_hdl *pintfhdl, u32 addr, u8 val);
+		int (*_write16_async)(struct intf_hdl *pintfhdl, u32 addr, u16 val);
+		int (*_write32_async)(struct intf_hdl *pintfhdl, u32 addr, u32 val);
+
+		void (*_read_mem)(struct intf_hdl *pintfhdl, u32 addr, u32 cnt, u8 *=
pmem);
+		void (*_write_mem)(struct intf_hdl *pintfhdl, u32 addr, u32 cnt, u8 =
*pmem);
+
+		void (*_sync_irp_protocol_rw)(struct io_queue *pio_q);
+
+		u32 (*_read_interrupt)(struct intf_hdl *pintfhdl, u32 addr);
+
+		u32 (*_read_port)(struct intf_hdl *pintfhdl, u32 addr, u32 cnt, stru=
ct recv_buf *rbuf);
+		u32 (*_write_port)(struct intf_hdl *pintfhdl, u32 addr, u32 cnt, str=
uct xmit_buf *pmem);
+
+		u32 (*_write_scsi)(struct intf_hdl *pintfhdl,u32 cnt, u8 *pmem);
+
+		void (*_read_port_cancel)(struct intf_hdl *pintfhdl);
+		void (*_write_port_cancel)(struct intf_hdl *pintfhdl);
+
+};
+
+struct io_req {
+	struct list_head	list;
+	u32	addr;
+	volatile u32	val;
+	u32	command;
+	u32	status;
+	u8	*pbuf;
+	struct semaphore	sema;
+
+	void (*_async_io_callback)(struct rtw_adapter *padater, struct io_req=
 *pio_req, u8 *cnxt);
+	u8 *cnxt;
+};
+
+struct	intf_hdl {
+	struct rtw_adapter *padapter;
+	struct dvobj_priv *pintf_dev;/* 	pointer to &(padapter->dvobjpriv); *=
/
+
+	struct _io_ops	io_ops;
+
+};
+
+struct reg_protocol_rd {
+
+#ifdef __LITTLE_ENDIAN
+
+	/* DW1 */
+	u32		NumOfTrans:4;
+	u32		Reserved1:4;
+	u32		Reserved2:24;
+	/* DW2 */
+	u32		ByteCount:7;
+	u32		WriteEnable:1;		/* 0:read, 1:write */
+	u32		FixOrContinuous:1;	/* 0:continuous, 1: Fix */
+	u32		BurstMode:1;
+	u32		Byte1Access:1;
+	u32		Byte2Access:1;
+	u32		Byte4Access:1;
+	u32		Reserved3:3;
+	u32		Reserved4:16;
+	/* DW3 */
+	u32		BusAddress;
+	/* DW4 */
+	/* u32		Value; */
+#else
+
+
+/* DW1 */
+	u32 Reserved1  :4;
+	u32 NumOfTrans :4;
+
+	u32 Reserved2  :24;
+
+	/* DW2 */
+	u32 WriteEnable : 1;
+	u32 ByteCount :7;
+
+
+	u32 Reserved3 : 3;
+	u32 Byte4Access : 1;
+
+	u32 Byte2Access : 1;
+	u32 Byte1Access : 1;
+	u32 BurstMode :1 ;
+	u32 FixOrContinuous : 1;
+
+	u32 Reserved4 : 16;
+
+	/* DW3 */
+	u32		BusAddress;
+
+	/* DW4 */
+	/* u32		Value; */
+
+#endif
+
+};
+
+
+struct reg_protocol_wt {
+
+
+#ifdef __LITTLE_ENDIAN
+
+	/* DW1 */
+	u32		NumOfTrans:4;
+	u32		Reserved1:4;
+	u32		Reserved2:24;
+	/* DW2 */
+	u32		ByteCount:7;
+	u32		WriteEnable:1;		/* 0:read, 1:write */
+	u32		FixOrContinuous:1;	/* 0:continuous, 1: Fix */
+	u32		BurstMode:1;
+	u32		Byte1Access:1;
+	u32		Byte2Access:1;
+	u32		Byte4Access:1;
+	u32		Reserved3:3;
+	u32		Reserved4:16;
+	/* DW3 */
+	u32		BusAddress;
+	/* DW4 */
+	u32		Value;
+
+#else
+	/* DW1 */
+	u32 Reserved1  :4;
+	u32 NumOfTrans :4;
+
+	u32 Reserved2  :24;
+
+	/* DW2 */
+	u32 WriteEnable : 1;
+	u32 ByteCount :7;
+
+	u32 Reserved3 : 3;
+	u32 Byte4Access : 1;
+
+	u32 Byte2Access : 1;
+	u32 Byte1Access : 1;
+	u32 BurstMode :1 ;
+	u32 FixOrContinuous : 1;
+
+	u32 Reserved4 : 16;
+
+	/* DW3 */
+	u32		BusAddress;
+
+	/* DW4 */
+	u32		Value;
+
+#endif
+
+};
+
+
+
+/*
+Below is the data structure used by _io_handler
+
+*/
+
+struct io_queue {
+	spinlock_t	lock;
+	struct list_head free_ioreqs;
+	struct list_head pending;		/* The io_req list that will be served in =
the single protocol read/write. */
+	struct list_head processing;
+	u8	*free_ioreqs_buf; /*  4-byte aligned */
+	u8	*pallocated_free_ioreqs_buf;
+	struct	intf_hdl	intf;
+};
+
+struct io_priv{
+
+	struct rtw_adapter *padapter;
+
+	struct intf_hdl intf;
+
+};
+
+uint ioreq_flush(struct rtw_adapter *adapter, struct io_queue *ioqueue=
);
+void sync_ioreq_enqueue(struct io_req *preq,struct io_queue *ioqueue);
+uint sync_ioreq_flush(struct rtw_adapter *adapter, struct io_queue *io=
queue);
+
+uint free_ioreq(struct io_req *preq, struct io_queue *pio_queue);
+struct io_req *alloc_ioreq(struct io_queue *pio_q);
+
+uint register_intf_hdl(u8 *dev, struct intf_hdl *pintfhdl);
+void unregister_intf_hdl(struct intf_hdl *pintfhdl);
+
+void _rtw_attrib_read(struct rtw_adapter *adapter, u32 addr, u32 cnt, =
u8 *pmem);
+void _rtw_attrib_write(struct rtw_adapter *adapter, u32 addr, u32 cnt,=
 u8 *pmem);
+
+u8 _rtw_read823a(struct rtw_adapter *adapter, u32 addr);
+u16 _rtw_read1623a(struct rtw_adapter *adapter, u32 addr);
+u32 _rtw_read3223a(struct rtw_adapter *adapter, u32 addr);
+void _rtw_read_mem23a(struct rtw_adapter *adapter, u32 addr, u32 cnt, =
u8 *pmem);
+void _rtw_read_port23a(struct rtw_adapter *adapter, u32 addr, u32 cnt,=
 struct recv_buf *rbuf);
+void _rtw_read_port23a_cancel(struct rtw_adapter *adapter);
+
+int _rtw_write823a(struct rtw_adapter *adapter, u32 addr, u8 val);
+int _rtw_write1623a(struct rtw_adapter *adapter, u32 addr, u16 val);
+int _rtw_write3223a(struct rtw_adapter *adapter, u32 addr, u32 val);
+int _rtw_writeN23a(struct rtw_adapter *adapter, u32 addr, u32 length, =
u8 *pdata);
+
+int _rtw_write823a_async23a(struct rtw_adapter *adapter, u32 addr, u8 =
val);
+int _rtw_write1623a_async(struct rtw_adapter *adapter, u32 addr, u16 v=
al);
+int _rtw_write3223a_async23a(struct rtw_adapter *adapter, u32 addr, u3=
2 val);
+
+void _rtw_write_mem23a(struct rtw_adapter *adapter, u32 addr, u32 cnt,=
 u8 *pmem);
+u32 _rtw_write_port23a(struct rtw_adapter *adapter, u32 addr, u32 cnt,=
 struct xmit_buf *pmem);
+u32 _rtw_write_port23a_and_wait23a(struct rtw_adapter *adapter, u32 ad=
dr, u32 cnt, struct xmit_buf *pmem, int timeout_ms);
+void _rtw_write_port23a_cancel(struct rtw_adapter *adapter);
+
+#ifdef DBG_IO
+bool match_read_sniff_ranges(u16 addr, u16 len);
+bool match_write_sniff_ranges(u16 addr, u16 len);
+
+u8 dbg_rtw_read823a(struct rtw_adapter *adapter, u32 addr, const char =
*caller, const int line);
+u16 dbg_rtw_read1623a(struct rtw_adapter *adapter, u32 addr, const cha=
r *caller, const int line);
+u32 dbg_rtw_read3223a(struct rtw_adapter *adapter, u32 addr, const cha=
r *caller, const int line);
+
+int dbg_rtw_write823a(struct rtw_adapter *adapter, u32 addr, u8 val, c=
onst char *caller, const int line);
+int dbg_rtw_write1623a(struct rtw_adapter *adapter, u32 addr, u16 val,=
 const char *caller, const int line);
+int dbg_rtw_write3223a(struct rtw_adapter *adapter, u32 addr, u32 val,=
 const char *caller, const int line);
+int dbg_rtw_writeN23a(struct rtw_adapter *adapter, u32 addr ,u32 lengt=
h , u8 *data, const char *caller, const int line);
+
+#define rtw_read8(adapter, addr) dbg_rtw_read823a((adapter), (addr), _=
_FUNCTION__, __LINE__)
+#define rtw_read16(adapter, addr) dbg_rtw_read1623a((adapter), (addr),=
 __FUNCTION__, __LINE__)
+#define rtw_read32(adapter, addr) dbg_rtw_read3223a((adapter), (addr),=
 __FUNCTION__, __LINE__)
+#define rtw_read_mem(adapter, addr, cnt, mem) _rtw_read_mem23a((adapte=
r), (addr), (cnt), (mem))
+#define rtw_read_port(adapter, addr, cnt, mem) _rtw_read_port23a((adap=
ter), (addr), (cnt), (mem))
+#define rtw_read_port_cancel(adapter) _rtw_read_port23a_cancel((adapte=
r))
+
+#define  rtw_write8(adapter, addr, val) dbg_rtw_write823a((adapter), (=
addr), (val), __FUNCTION__, __LINE__)
+#define  rtw_write16(adapter, addr, val) dbg_rtw_write1623a((adapter),=
 (addr), (val), __FUNCTION__, __LINE__)
+#define  rtw_write32(adapter, addr, val) dbg_rtw_write3223a((adapter),=
 (addr), (val), __FUNCTION__, __LINE__)
+#define  rtw_writeN(adapter, addr, length, data) dbg_rtw_writeN23a((ad=
apter), (addr), (length), (data), __FUNCTION__, __LINE__)
+
+#define rtw_write8_async(adapter, addr, val) _rtw_write823a_async23a((=
adapter), (addr), (val))
+#define rtw_write16_async(adapter, addr, val) _rtw_write1623a_async((a=
dapter), (addr), (val))
+#define rtw_write32_async(adapter, addr, val) _rtw_write3223a_async23a=
((adapter), (addr), (val))
+
+#define rtw_write_mem(adapter, addr, cnt, mem) _rtw_write_mem23a((adap=
ter), addr, cnt, mem)
+#define rtw_write_port(adapter, addr, cnt, mem) _rtw_write_port23a(ada=
pter, addr, cnt, mem)
+#define rtw_write_port_and_wait(adapter, addr, cnt, mem, timeout_ms) _=
rtw_write_port23a_and_wait23a((adapter), (addr), (cnt), (mem), (timeout=
_ms))
+#define rtw_write_port_cancel(adapter) _rtw_write_port23a_cancel(adapt=
er)
+#else /* DBG_IO */
+#define rtw_read8(adapter, addr) _rtw_read823a((adapter), (addr))
+#define rtw_read16(adapter, addr) _rtw_read1623a((adapter), (addr))
+#define rtw_read32(adapter, addr) _rtw_read3223a((adapter), (addr))
+#define rtw_read_mem(adapter, addr, cnt, mem) _rtw_read_mem23a((adapte=
r), (addr), (cnt), (mem))
+#define rtw_read_port(adapter, addr, cnt, mem) _rtw_read_port23a((adap=
ter), (addr), (cnt), (mem))
+#define rtw_read_port_cancel(adapter) _rtw_read_port23a_cancel((adapte=
r))
+
+#define  rtw_write8(adapter, addr, val) _rtw_write823a((adapter), (add=
r), (val))
+#define  rtw_write16(adapter, addr, val) _rtw_write1623a((adapter), (a=
ddr), (val))
+#define  rtw_write32(adapter, addr, val) _rtw_write3223a((adapter), (a=
ddr), (val))
+#define  rtw_writeN(adapter, addr, length, data) _rtw_writeN23a((adapt=
er), (addr), (length), (data))
+
+#define rtw_write8_async(adapter, addr, val) _rtw_write823a_async23a((=
adapter), (addr), (val))
+#define rtw_write16_async(adapter, addr, val) _rtw_write1623a_async((a=
dapter), (addr), (val))
+#define rtw_write32_async(adapter, addr, val) _rtw_write3223a_async23a=
((adapter), (addr), (val))
+
+#define rtw_write_mem(adapter, addr, cnt, mem) _rtw_write_mem23a((adap=
ter), (addr), (cnt), (mem))
+#define rtw_write_port(adapter, addr, cnt, mem) _rtw_write_port23a((ad=
apter), (addr), (cnt), (mem))
+#define rtw_write_port_and_wait(adapter, addr, cnt, mem, timeout_ms) _=
rtw_write_port23a_and_wait23a((adapter), (addr), (cnt), (mem), (timeout=
_ms))
+#define rtw_write_port_cancel(adapter) _rtw_write_port23a_cancel((adap=
ter))
+#endif /* DBG_IO */
+
+void rtw_write_scsi(struct rtw_adapter *adapter, u32 cnt, u8 *pmem);
+
+/* ioreq */
+void ioreq_read8(struct rtw_adapter *adapter, u32 addr, u8 *pval);
+void ioreq_read16(struct rtw_adapter *adapter, u32 addr, u16 *pval);
+void ioreq_read32(struct rtw_adapter *adapter, u32 addr, u32 *pval);
+void ioreq_write8(struct rtw_adapter *adapter, u32 addr, u8 val);
+void ioreq_write16(struct rtw_adapter *adapter, u32 addr, u16 val);
+void ioreq_write32(struct rtw_adapter *adapter, u32 addr, u32 val);
+
+int rtw_init_io_priv23a(struct rtw_adapter *padapter, void (*set_intf_=
ops)(struct _io_ops *pops));
+
+uint alloc_io_queue(struct rtw_adapter *adapter);
+void free_io_queue(struct rtw_adapter *adapter);
+void async_bus_io(struct io_queue *pio_q);
+void bus_sync_io(struct io_queue *pio_q);
+u32 _ioreq2rwmem(struct io_queue *pio_q);
+void dev_power_down(struct rtw_adapter * Adapter, u8 bpwrup);
+
+#define PlatformEFIOWrite1Byte(_a,_b,_c)		\
+	rtw_write8(_a,_b,_c)
+#define PlatformEFIOWrite2Byte(_a,_b,_c)		\
+	rtw_write16(_a,_b,_c)
+#define PlatformEFIOWrite4Byte(_a,_b,_c)		\
+	rtw_write32(_a,_b,_c)
+
+#define PlatformEFIORead1Byte(_a,_b)		\
+		rtw_read8(_a,_b)
+#define PlatformEFIORead2Byte(_a,_b)		\
+		rtw_read16(_a,_b)
+#define PlatformEFIORead4Byte(_a,_b)		\
+		rtw_read32(_a,_b)
+
+#endif	/* _RTL8711_IO_H_ */
diff --git a/drivers/staging/rtl8723au/include/rtw_ioctl.h b/drivers/st=
aging/rtl8723au/include/rtw_ioctl.h
new file mode 100644
index 0000000..629eec8
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_ioctl.h
@@ -0,0 +1,26 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef _RTW_IOCTL_H_
+#define _RTW_IOCTL_H_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+
+#if defined(CONFIG_WIRELESS_EXT)
+extern struct iw_handler_def  rtw_handlers_def;
+#endif
+
+#endif /*  #ifndef __INC_CEINFO_ */
diff --git a/drivers/staging/rtl8723au/include/rtw_ioctl_set.h b/driver=
s/staging/rtl8723au/include/rtw_ioctl_set.h
new file mode 100644
index 0000000..18ad2a8
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_ioctl_set.h
@@ -0,0 +1,39 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTW_IOCTL_SET_H_
+#define __RTW_IOCTL_SET_H_
+
+#include <drv_types.h>
+
+
+struct bssid_info {
+	unsigned char  BSSID[6];
+	u8  PMKID[16];
+};
+
+u8 rtw_set_802_11_authentication_mode23a(struct rtw_adapter *pdapter,
+				      enum ndis_802_11_auth_mode authmode);
+u8 rtw_set_802_11_add_wep23a(struct rtw_adapter * padapter,
+			  struct ndis_802_11_wep *wep);
+u8 rtw_set_802_11_bssid23a_list_scan(struct rtw_adapter *padapter,
+				  struct cfg80211_ssid *pssid, int ssid_max_num);
+u8 rtw_set_802_11_infrastructure_mode23a(struct rtw_adapter *padapter,
+				      enum ndis_802_11_net_infra networktype);
+u8 rtw_set_802_11_ssid23a(struct rtw_adapter * padapter, struct cfg802=
11_ssid * ssid);
+
+u16 rtw_get_cur_max_rate23a(struct rtw_adapter *adapter);
+s32 FillH2CCmd(struct rtw_adapter *padapter, u8 ElementID, u32 CmdLen,=
 u8 *pCmdBuffer);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtw_led.h b/drivers/stag=
ing/rtl8723au/include/rtw_led.h
new file mode 100644
index 0000000..c071da5
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_led.h
@@ -0,0 +1,181 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTW_LED_H_
+#define __RTW_LED_H_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+#define MSECS(t)        (HZ * ((t) / 1000) + (HZ * ((t) % 1000)) / 100=
0)
+
+#define LED_BLINK_NORMAL_INTERVAL	100
+#define LED_BLINK_SLOWLY_INTERVAL	200
+#define LED_BLINK_LONG_INTERVAL	400
+
+#define LED_BLINK_NO_LINK_INTERVAL_ALPHA		1000
+#define LED_BLINK_LINK_INTERVAL_ALPHA			500		/* 500 */
+#define LED_BLINK_SCAN_INTERVAL_ALPHA		180	/* 150 */
+#define LED_BLINK_FASTER_INTERVAL_ALPHA		50
+#define LED_BLINK_WPS_SUCESS_INTERVAL_ALPHA	5000
+
+#define LED_BLINK_NORMAL_INTERVAL_NETTRONIX  100
+#define LED_BLINK_SLOWLY_INTERVAL_NETTRONIX  2000
+
+#define LED_BLINK_SLOWLY_INTERVAL_PORNET 1000
+#define LED_BLINK_NORMAL_INTERVAL_PORNET 100
+
+#define LED_BLINK_FAST_INTERVAL_BITLAND 30
+
+/*  060403, rcnjko: Customized for AzWave. */
+#define LED_CM2_BLINK_ON_INTERVAL			250
+#define LED_CM2_BLINK_OFF_INTERVAL		4750
+
+#define LED_CM8_BLINK_INTERVAL			500		/* for QMI */
+#define LED_CM8_BLINK_OFF_INTERVAL	3750	/* for QMI */
+
+/*  080124, lanhsin: Customized for RunTop */
+#define LED_RunTop_BLINK_INTERVAL			300
+
+/*  060421, rcnjko: Customized for Sercomm Printer Server case. */
+#define LED_CM3_BLINK_INTERVAL				1500
+
+enum led_ctl_mode {
+	LED_CTL_POWER_ON =3D 1,
+	LED_CTL_LINK =3D 2,
+	LED_CTL_NO_LINK =3D 3,
+	LED_CTL_TX =3D 4,
+	LED_CTL_RX =3D 5,
+	LED_CTL_SITE_SURVEY =3D 6,
+	LED_CTL_POWER_OFF =3D 7,
+	LED_CTL_START_TO_LINK =3D 8,
+	LED_CTL_START_WPS =3D 9,
+	LED_CTL_STOP_WPS =3D 10,
+	LED_CTL_START_WPS_BOTTON =3D 11, /* added for runtop */
+	LED_CTL_STOP_WPS_FAIL =3D 12, /* added for ALPHA */
+	LED_CTL_STOP_WPS_FAIL_OVERLAP =3D 13, /* added for BELKIN */
+	LED_CTL_CONNECTION_NO_TRANSFER =3D 14,
+};
+
+enum led_state_872x {
+	LED_UNKNOWN =3D 0,
+	RTW_LED_ON =3D 1,
+	RTW_LED_OFF =3D 2,
+	LED_BLINK_NORMAL =3D 3,
+	LED_BLINK_SLOWLY =3D 4,
+	LED_BLINK_POWER_ON =3D 5,
+	LED_BLINK_SCAN =3D 6, /*  LED is blinking during scanning period, the=
 # of times to blink is depend on time for scanning. */
+	LED_BLINK_NO_LINK =3D 7, /*  LED is blinking during no link state. */
+	LED_BLINK_StartToBlink =3D 8,/*  Customzied for Sercomm Printer Serve=
r case */
+	LED_BLINK_TXRX =3D 9,
+	LED_BLINK_WPS =3D 10,	/*  LED is blinkg during WPS communication */
+	LED_BLINK_WPS_STOP =3D 11,	/* for ALPHA */
+	LED_BLINK_WPS_STOP_OVERLAP =3D 12,	/* for BELKIN */
+	LED_BLINK_RUNTOP =3D 13, /*  Customized for RunTop */
+	LED_BLINK_CAMEO =3D 14,
+	LED_BLINK_XAVI =3D 15,
+	LED_BLINK_ALWAYS_ON =3D 16,
+};
+
+enum led_pin_8723a {
+	LED_PIN_NULL =3D 0,
+	LED_PIN_LED0 =3D 1,
+	LED_PIN_LED1 =3D 2,
+	LED_PIN_LED2 =3D 3,
+	LED_PIN_GPIO0 =3D 4,
+};
+
+struct led_8723a {
+	struct rtw_adapter				*padapter;
+
+	enum led_pin_8723a		LedPin;	/*  Identify how to implement this SW led=
=2E */
+	enum led_state_872x		CurrLedState; /*  Current LED state. */
+	enum led_state_872x		BlinkingLedState; /*  Next state for blinking, e=
ither RTW_LED_ON or RTW_LED_OFF are. */
+
+	u8					bLedOn; /*  true if LED is ON, false if LED is OFF. */
+
+	u8					bLedBlinkInProgress; /*  true if it is blinking, false o.w.. *=
/
+
+	u8					bLedWPSBlinkInProgress;
+
+	u32					BlinkTimes; /*  Number of times to toggle led state for blink=
ing. */
+
+	struct timer_list			BlinkTimer; /*  Timer object for led blinking. */
+
+	u8					bSWLedCtrl;
+
+	/*  ALPHA, added by chiyoko, 20090106 */
+	u8					bLedNoLinkBlinkInProgress;
+	u8					bLedLinkBlinkInProgress;
+	u8					bLedStartToLinkBlinkInProgress;
+	u8					bLedScanBlinkInProgress;
+
+	struct work_struct			BlinkWorkItem; /*  Workitem used by BlinkTimer t=
o manipulate H/W to blink LED. */
+};
+
+#define IS_LED_WPS_BLINKING(_LED_871x)	(((struct led_8723a *)_LED_871x=
)->CurrLedState=3D=3DLED_BLINK_WPS \
+					|| ((struct led_8723a *)_LED_871x)->CurrLedState=3D=3DLED_BLINK_W=
PS_STOP \
+					|| ((struct led_8723a *)_LED_871x)->bLedWPSBlinkInProgress)
+
+#define IS_LED_BLINKING(_LED_871x)	(((struct led_8723a *)_LED_871x)->b=
LedWPSBlinkInProgress \
+					||((struct led_8723a *)_LED_871x)->bLedScanBlinkInProgress)
+
+/*  */
+/*  LED customization. */
+/*  */
+
+enum led_strategy_8723a {
+	SW_LED_MODE0 =3D 0, /*  SW control 1 LED via GPIO0. It is default opt=
ion. */
+	SW_LED_MODE1=3D 1, /*  2 LEDs, through LED0 and LED1. For ALPHA. */
+	SW_LED_MODE2 =3D 2, /*  SW control 1 LED via GPIO0, customized for Az=
Wave 8187 minicard. */
+	SW_LED_MODE3 =3D 3, /*  SW control 1 LED via GPIO0, customized for Se=
rcomm Printer Server case. */
+	SW_LED_MODE4 =3D 4, /* for Edimax / Belkin */
+	SW_LED_MODE5 =3D 5, /* for Sercomm / Belkin */
+	SW_LED_MODE6 =3D 6, /* for 88CU minicard, porting from ce SW_LED_MODE=
7 */
+	HW_LED =3D 50, /*  HW control 2 LEDs, LED0 and LED1 (there are 4 diff=
erent control modes, see MAC.CONFIG1 for details.) */
+	LED_ST_NONE =3D 99,
+};
+
+void LedControl871x23a(struct rtw_adapter *padapter, enum led_ctl_mode=
 LedAction);
+
+struct led_priv{
+	/* add for led controll */
+	struct led_8723a			SwLed0;
+	struct led_8723a			SwLed1;
+	enum led_strategy_8723a	LedStrategy;
+	u8					bRegUseLed;
+	void (*LedControlHandler)(struct rtw_adapter *padapter, enum led_ctl_=
mode LedAction);
+	/* add for led controll */
+};
+
+#define rtw_led_control(adapter, LedAction)
+
+void BlinkWorkItemCallback23a(struct work_struct *work);
+
+void ResetLedStatus23a(struct led_8723a *pLed);
+
+void
+InitLed871x23a(
+	struct rtw_adapter *padapter,
+	struct led_8723a *pLed,
+	enum led_pin_8723a	LedPin
+);
+
+void
+DeInitLed871x23a(struct led_8723a *pLed);
+
+/* hal... */
+void BlinkHandler23a(struct led_8723a *pLed);
+
+#endif /* __RTW_LED_H_ */
diff --git a/drivers/staging/rtl8723au/include/rtw_mlme.h b/drivers/sta=
ging/rtl8723au/include/rtw_mlme.h
new file mode 100644
index 0000000..adbea44
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_mlme.h
@@ -0,0 +1,632 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *
+ *********************************************************************=
*********/
+#ifndef __RTW_MLME_H_
+#define __RTW_MLME_H_
+
+#include <osdep_service.h>
+#include <mlme_osdep.h>
+#include <drv_types.h>
+#include <wlan_bssdef.h>
+
+#define	MAX_BSS_CNT	128
+#define   MAX_JOIN_TIMEOUT	6500
+
+/* Increase the scanning timeout because of increasing the SURVEY_TO v=
alue. */
+
+#define	SCANNING_TIMEOUT	8000
+
+#define	SCAN_INTERVAL	(30) /*  unit:2sec, 30*2 =3D 60sec */
+
+#define	SCANQUEUE_LIFETIME 20 /*  unit:sec */
+
+#define	WIFI_NULL_STATE		0x00000000
+
+#define	WIFI_ASOC_STATE		0x00000001 /*  Under Linked state.*/
+#define	WIFI_REASOC_STATE	0x00000002
+#define	WIFI_SLEEP_STATE	0x00000004
+#define	WIFI_STATION_STATE	0x00000008
+
+#define	WIFI_AP_STATE		0x00000010
+#define	WIFI_ADHOC_STATE	0x00000020
+#define   WIFI_ADHOC_MASTER_STATE	0x00000040
+#define   WIFI_UNDER_LINKING	0x00000080
+
+#define	WIFI_UNDER_WPS		0x00000100
+#define	WIFI_STA_ALIVE_CHK_STATE	0x00000400
+/* to indicate the station is under site surveying */
+#define	WIFI_SITE_MONITOR	0x00000800
+
+#define	WIFI_MP_STATE		0x00010000
+#define	WIFI_MP_CTX_BACKGROUND	0x00020000	/*  in continous tx backgrou=
nd */
+#define	WIFI_MP_CTX_ST		0x00040000	/*  in continous tx with single-ton=
e */
+#define	WIFI_MP_CTX_BACKGROUND_PENDING	0x00080000	/*  pending in conti=
nous tx background due to out of skb */
+#define	WIFI_MP_CTX_CCK_HW	0x00100000	/*  in continous tx */
+#define	WIFI_MP_CTX_CCK_CS	0x00200000	/*  in continous tx with carrier=
 suppression */
+#define   WIFI_MP_LPBK_STATE	0x00400000
+
+#define _FW_UNDER_LINKING	WIFI_UNDER_LINKING
+#define _FW_LINKED		WIFI_ASOC_STATE
+#define _FW_UNDER_SURVEY	WIFI_SITE_MONITOR
+
+
+enum dot11AuthAlgrthmNum {
+	dot11AuthAlgrthm_Open =3D 0,
+	dot11AuthAlgrthm_Shared,
+	dot11AuthAlgrthm_8021X,
+	dot11AuthAlgrthm_Auto,
+	dot11AuthAlgrthm_MaxNum
+};
+
+/*  Scan type including active and passive scan. */
+enum rt_scan_type {
+	SCAN_PASSIVE,
+	SCAN_ACTIVE,
+	SCAN_MIX,
+};
+
+enum {
+	GHZ24_50 =3D 0,
+	GHZ_50,
+	GHZ_24,
+};
+
+enum SCAN_RESULT_TYPE {
+	SCAN_RESULT_P2P_ONLY =3D 0,	/*	Will return all the P2P devices. */
+	SCAN_RESULT_ALL =3D 1,		/*	Will return all the scanned device, includ=
e AP. */
+	SCAN_RESULT_WFD_TYPE =3D 2	/*	Will just return the correct WFD device=
=2E */
+					/*	If this device is Miracast sink device, it will just return al=
l the Miracast source devices. */
+};
+
+/*
+
+there are several "locks" in mlme_priv,
+since mlme_priv is a shared resource between many threads,
+like ISR/Call-Back functions, the OID handlers, and even timer functio=
ns.
+
+
+Each _queue has its own locks, already.
+Other items are protected by mlme_priv.lock.
+
+To avoid possible dead lock, any thread trying to modifiying mlme_priv
+SHALL not lock up more than one locks at a time!
+*/
+
+#define traffic_threshold	10
+#define	traffic_scan_period	500
+
+struct sitesurvey_ctrl {
+	u64	last_tx_pkts;
+	uint	last_rx_pkts;
+	int	traffic_busy;
+	struct timer_list	sitesurvey_ctrl_timer;
+};
+
+struct rt_link_detect {
+	u32	NumTxOkInPeriod;
+	u32	NumRxOkInPeriod;
+	u32	NumRxUnicastOkInPeriod;
+	bool	bBusyTraffic;
+	bool	bTxBusyTraffic;
+	bool	bRxBusyTraffic;
+	bool	bHigherBusyTraffic; /*  For interrupt migration purpose. */
+	bool	bHigherBusyRxTraffic; /*  We may disable Tx interrupt according =
as Rx traffic. */
+	bool	bHigherBusyTxTraffic; /*  We may disable Tx interrupt according =
as Tx traffic. */
+};
+
+struct profile_info {
+	u8	ssidlen;
+	u8	ssid[IEEE80211_MAX_SSID_LEN];
+	u8	peermac[ETH_ALEN];
+};
+
+struct tx_invite_req_info {
+	u8	token;
+	u8	benable;
+	u8	go_ssid[IEEE80211_MAX_SSID_LEN];
+	u8	ssidlen;
+	u8	go_bssid[ETH_ALEN];
+	u8	peer_macaddr[ETH_ALEN];
+	u8	operating_ch;	/* This information will be set by using the p2p_set=
 op_ch =3D x */
+	u8	peer_ch;	/* The listen channel for peer P2P device */
+
+};
+
+struct tx_invite_resp_info {
+	u8	token;	/*	Used to record the dialog token of p2p invitation reques=
t frame. */
+};
+
+#ifdef CONFIG_8723AU_P2P
+
+struct wifi_display_info {
+	u16	wfd_enable;		/* Enable/Disable the WFD function. */
+	u16	rtsp_ctrlport;		/* TCP port number at which the this WFD device l=
istens for RTSP messages */
+	u16	peer_rtsp_ctrlport;	/* TCP port number at which the peer WFD devi=
ce listens for RTSP messages */
+					/* This filed should be filled when receiving the gropu negotiati=
on request */
+
+	u8	peer_session_avail;	/* WFD session is available or not for the pee=
r wfd device. */
+					/* This variable will be set when sending the provisioning discov=
ery request to peer WFD device. */
+					/* And this variable will be reset when it is read by using the i=
wpriv p2p_get wfd_sa command. */
+	u8	ip_address[4];
+	u8	peer_ip_address[4];
+	u8	wfd_pc;		/* WFD preferred connection */
+				/* 0 -> Prefer to use the P2P for WFD connection on peer side. */
+				/* 1 -> Prefer to use the TDLS for WFD connection on peer side. */
+
+	u8	wfd_device_type;/* WFD Device Type */
+				/* 0 -> WFD Source Device */
+				/* 1 -> WFD Primary Sink Device */
+	enum	SCAN_RESULT_TYPE scan_result_type;	/* Used when P2P is enable. T=
his parameter will impact the scan result. */
+};
+#endif /* CONFIG_8723AU_P2P */
+
+struct tx_provdisc_req_info {
+	u16	wps_config_method_request;	/* Used when sending the provisioning =
request frame */
+	u16	peer_channel_num[2];		/* The channel number which the receiver st=
ands. */
+	struct	cfg80211_ssid ssid;
+	u8	peerDevAddr[ETH_ALEN];	/* Peer device address */
+	u8	peerIFAddr[ETH_ALEN];		/* Peer interface address */
+	u8	benable;			/* This provision discovery request frame is trigger to=
 send or not */
+};
+
+struct rx_provdisc_req_info {	/* When peer device issue prov_disc_req =
first, we should store the following informations */
+	u8	peerDevAddr[ETH_ALEN];		/*	Peer device address */
+	u8	strconfig_method_desc_of_prov_disc_req[4];	/*	description for the =
config method located in the provisioning discovery request frame. */
+																	/*	The UI must know this information to know which co=
nfig method the remote p2p device is requiring. */
+};
+
+struct tx_nego_req_info {
+	u16	peer_channel_num[2];	/* The channel number which the receiver sta=
nds. */
+	u8	peerDevAddr[ETH_ALEN];/* Peer device address */
+	u8	benable;		/* This negoitation request frame is trigger to send or =
not */
+};
+
+struct group_id_info {
+	u8 go_device_addr[ETH_ALEN]; /*The GO's device address of P2P group *=
/
+	u8 ssid[IEEE80211_MAX_SSID_LEN]; /* The SSID of this P2P group */
+};
+
+struct scan_limit_info {
+	u8	scan_op_ch_only;	/* When this flag is set, the driver should just =
scan the operation channel */
+	u8	operation_ch[2];	/* Store the operation channel of invitation requ=
est frame */
+};
+
+struct cfg80211_wifidirect_info {
+	struct timer_list		remain_on_ch_timer;
+	u8		restore_channel;
+	struct ieee80211_channel	remain_on_ch_channel;
+	enum nl80211_channel_type	remain_on_ch_type;
+	u64	remain_on_ch_cookie;
+	bool is_ro_ch;
+};
+
+struct wifidirect_info {
+	struct rtw_adapter	*padapter;
+	struct timer_list	find_phase_timer;
+	struct timer_list	restore_p2p_state_timer;
+
+	/*	Used to do the scanning. After confirming the peer is availalble, =
the driver transmits the P2P frame to peer. */
+	struct timer_list	pre_tx_scan_timer;
+	struct timer_list	reset_ch_sitesurvey;
+	struct timer_list	reset_ch_sitesurvey2;	/*	Just for resetting the sca=
n limit function by using p2p nego */
+	struct tx_provdisc_req_info	tx_prov_disc_info;
+	struct rx_provdisc_req_info rx_prov_disc_info;
+	struct tx_invite_req_info	invitereq_info;
+	struct profile_info	profileinfo[P2P_MAX_PERSISTENT_GROUP_NUM];	/*	Sto=
re the profile information of persistent group */
+	struct tx_invite_resp_info	inviteresp_info;
+	struct tx_nego_req_info	nego_req_info;
+	struct group_id_info	groupid_info;	/*	Store the group id information =
when doing the group negotiation handshake. */
+	struct scan_limit_info	rx_invitereq_info;	/*	Used for get the limit s=
can channel from the Invitation procedure */
+	struct scan_limit_info	p2p_info;		/*	Used for get the limit scan chan=
nel from the P2P negotiation handshake */
+#ifdef CONFIG_8723AU_P2P
+	struct wifi_display_info	*wfd_info;
+#endif
+	enum P2P_ROLE	role;
+	enum P2P_STATE	pre_p2p_state;
+	enum P2P_STATE	p2p_state;
+	u8	device_addr[ETH_ALEN];	/*	The device address should be the mac add=
ress of this device. */
+	u8	interface_addr[ETH_ALEN];
+	u8	social_chan[4];
+	u8	listen_channel;
+	u8	operating_channel;
+	u8	listen_dwell;		/*	This value should be between 1 and 3 */
+	u8	support_rate[8];
+	u8	p2p_wildcard_ssid[P2P_WILDCARD_SSID_LEN];
+	u8	intent;		/*	should only include the intent value. */
+	u8	p2p_peer_interface_addr[ETH_ALEN];
+	u8	p2p_peer_device_addr[ETH_ALEN];
+	u8	peer_intent;	/*	Included the intent value and tie breaker value. *=
/
+	u8	device_name[WPS_MAX_DEVICE_NAME_LEN];	/*	Device name for displayin=
g on searching device screen */
+	u8	device_name_len;
+	u8	profileindex;	/*	Used to point to the index of profileinfo array *=
/
+	u8	peer_operating_ch;
+	u8	find_phase_state_exchange_cnt;
+	u16	device_password_id_for_nego;	/*	The device password ID for group =
negotation */
+	u8	negotiation_dialog_token;
+	/*	SSID information for group negotitation */
+	u8 nego_ssid[IEEE80211_MAX_SSID_LEN];
+	u8 nego_ssidlen;
+	u8 p2p_group_ssid[IEEE80211_MAX_SSID_LEN];
+	u8 p2p_group_ssid_len;
+	u8	persistent_supported;	/*	Flag to know the persistent function shou=
ld be supported or not. */
+					/*	In the Sigma test, the Sigma will provide this enable from the=
 sta_set_p2p CAPI. */
+					/*	0: disable */
+					/*	1: enable */
+	u8	session_available;	/*	Flag to set the WFD session available to ena=
ble or disable "by Sigma" */
+					/*	In the Sigma test, the Sigma will disable the session availabl=
e by using the sta_preset CAPI. */
+					/*	0: disable */
+					/*	1: enable */
+
+	u8	wfd_tdls_enable;	/*	Flag to enable or disable the TDLS by WFD Sigm=
a */
+					/*	0: disable */
+					/*	1: enable */
+	u8	wfd_tdls_weaksec;	/*	Flag to enable or disable the weak security f=
unction for TDLS by WFD Sigma */
+				/*	0: disable */
+				/*	In this case, the driver can't issue the tdsl setup request fra=
me. */
+				/*	1: enable */
+				/*	In this case, the driver can issue the tdls setup request frame=
 */
+				/*	even the current security is weak security. */
+
+	enum	P2P_WPSINFO		ui_got_wps_info;			/*	This field will store the WPS=
 value (PIN value or PBC) that UI had got from the user. */
+	u16	supported_wps_cm;			/*	This field describes the WPS config method=
 which this driver supported. */
+														/*	The value should be the combination of config method =
defined in page104 of WPS v2.0 spec. */
+	uint	channel_list_attr_len;		/*	This field will contain the length of=
 body of P2P Channel List attribute of group negotitation response fram=
e. */
+	u8	channel_list_attr[100];		/*	This field will contain the body of P2=
P Channel List attribute of group negotitation response frame. */
+														/*	We will use the channel_cnt and channel_list fields w=
hen constructing the group negotitation confirm frame. */
+#ifdef CONFIG_8723AU_P2P
+	enum P2P_PS_MODE	p2p_ps_mode; /*  indicate p2p ps mode */
+	enum P2P_PS_STATE	p2p_ps_state; /*  indicate p2p ps state */
+	u8	noa_index; /*  Identifies and instance of Notice of Absence timing=
=2E */
+	u8	ctwindow; /*  Client traffic window. A period of time in TU after =
TBTT. */
+	u8	opp_ps; /*  opportunistic power save. */
+	u8	noa_num; /*  number of NoA descriptor in P2P IE. */
+	u8	noa_count[P2P_MAX_NOA_NUM]; /*  Count for owner, Type of client. *=
/
+	u32	noa_duration[P2P_MAX_NOA_NUM]; /*  Max duration for owner, prefer=
red or min acceptable duration for client. */
+	u32	noa_interval[P2P_MAX_NOA_NUM]; /*  Length of interval for owner, =
preferred or max acceptable interval of client. */
+	u32	noa_start_time[P2P_MAX_NOA_NUM]; /*  schedule expressed in terms =
of the lower 4 bytes of the TSF timer. */
+#endif /*  CONFIG_8723AU_P2P */
+};
+
+struct tdls_ss_record {	/* signal strength record */
+	u8	macaddr[ETH_ALEN];
+	u8	RxPWDBAll;
+	u8	is_tdls_sta;	/*  true: direct link sta, false: else */
+};
+
+struct tdls_info {
+	u8	ap_prohibited;
+	uint	setup_state;
+	u8	sta_cnt;
+	/* 1:tdls sta =3D=3D (NUM_STA-1), reach max direct link no; 0: else; =
*/
+	u8	sta_maximum;
+	struct tdls_ss_record	ss_record;
+	u8	macid_index;	/* macid entry that is ready to write */
+	/* cam entry that is trying to clear, using it in direct link teardow=
n*/
+	u8	clear_cam;
+	u8	ch_sensing;
+	u8	cur_channel;
+	u8	candidate_ch;
+	u8	collect_pkt_num[MAX_CHANNEL_NUM];
+	spinlock_t	cmd_lock;
+	spinlock_t	hdl_lock;
+	u8	watchdog_count;
+	u8	dev_discovered;		/* WFD_TDLS: for sigma test */
+	u8	enable;
+#ifdef CONFIG_8723AU_P2P
+	struct wifi_display_info		*wfd_info;
+#endif
+};
+
+struct mlme_priv {
+	spinlock_t	lock;
+	int	fw_state;
+	u8 bScanInProcess;
+	u8	to_join; /* flag */
+	u8 to_roaming; /*  roaming trying times */
+
+	struct rtw_adapter *nic_hdl;
+
+	u8	not_indic_disco;
+	struct rtw_queue	scanned_queue;
+
+	struct cfg80211_ssid assoc_ssid;
+	u8	assoc_bssid[6];
+
+	struct wlan_network	cur_network;
+
+	/* uint wireless_mode; no used, remove it */
+
+	u32	scan_interval;
+
+	struct timer_list assoc_timer;
+
+	uint assoc_by_bssid;
+	uint assoc_by_rssi;
+
+	struct timer_list scan_to_timer;
+
+	struct timer_list set_scan_deny_timer;
+	atomic_t set_scan_deny; /* 0: allowed, 1: deny */
+
+	struct qos_priv qospriv;
+
+	/* Number of non-HT AP/stations */
+	int num_sta_no_ht;
+
+	int num_FortyMHzIntolerant;
+
+	struct ht_priv	htpriv;
+
+	struct rt_link_detect LinkDetectInfo;
+	struct timer_list dynamic_chk_timer; /* dynamic/periodic check timer =
*/
+
+	u8	key_mask; /* use for ips to set wep key after ips_leave23a */
+	u8	acm_mask; /*  for wmm acm mask */
+	u8	ChannelPlan;
+	enum rt_scan_type scan_mode; /*  active: 1, passive: 0 */
+
+	u8 *wps_probe_req_ie;
+	u32 wps_probe_req_ie_len;
+
+#ifdef CONFIG_8723AU_AP_MODE
+	/* Number of associated Non-ERP stations (i.e., stations using 802.11=
b
+	 * in 802.11g BSS) */
+	int num_sta_non_erp;
+
+	/* Number of associated stations that do not support Short Slot Time =
*/
+	int num_sta_no_short_slot_time;
+
+	/* Number of associated stations that do not support Short Preamble *=
/
+	int num_sta_no_short_preamble;
+
+	int olbc; /* Overlapping Legacy BSS Condition */
+
+	/* Number of HT associated stations that do not support greenfield */
+	int num_sta_ht_no_gf;
+
+	/* Number of associated non-HT stations */
+	/* int num_sta_no_ht; */
+
+	/* Number of HT associated stations 20 MHz */
+	int num_sta_ht_20mhz;
+
+	/* Overlapping BSS information */
+	int olbc_ht;
+
+	u16 ht_op_mode;
+
+	u8 *assoc_req;
+	u32 assoc_req_len;
+	u8 *assoc_rsp;
+	u32 assoc_rsp_len;
+
+	u8 *wps_beacon_ie;
+	/* u8 *wps_probe_req_ie; */
+	u8 *wps_probe_resp_ie;
+	u8 *wps_assoc_resp_ie;
+
+	u32 wps_beacon_ie_len;
+	/* u32 wps_probe_req_ie_len; */
+	u32 wps_probe_resp_ie_len;
+	u32 wps_assoc_resp_ie_len;
+
+	u8 *p2p_beacon_ie;
+	u8 *p2p_probe_req_ie;
+	u8 *p2p_probe_resp_ie;
+	u8 *p2p_go_probe_resp_ie; /* for GO */
+	u8 *p2p_assoc_req_ie;
+
+	u32 p2p_beacon_ie_len;
+	u32 p2p_probe_req_ie_len;
+	u32 p2p_probe_resp_ie_len;
+	u32 p2p_go_probe_resp_ie_len; /* for GO */
+	u32 p2p_assoc_req_ie_len;
+	spinlock_t	bcn_update_lock;
+	u8		update_bcn;
+
+#endif /* ifdef CONFIG_8723AU_AP_MODE */
+
+#if defined(CONFIG_8723AU_P2P)
+	u8 *wfd_beacon_ie;
+	u8 *wfd_probe_req_ie;
+	u8 *wfd_probe_resp_ie;
+	u8 *wfd_go_probe_resp_ie; /* for GO */
+	u8 *wfd_assoc_req_ie;
+
+	u32 wfd_beacon_ie_len;
+	u32 wfd_probe_req_ie_len;
+	u32 wfd_probe_resp_ie_len;
+	u32 wfd_go_probe_resp_ie_len; /* for GO */
+	u32 wfd_assoc_req_ie_len;
+#endif
+};
+
+#ifdef CONFIG_8723AU_AP_MODE
+
+struct hostapd_priv {
+	struct rtw_adapter *padapter;
+};
+
+int hostapd_mode_init(struct rtw_adapter *padapter);
+void hostapd_mode_unload(struct rtw_adapter *padapter);
+#endif
+
+void rtw_joinbss_event_prehandle23a(struct rtw_adapter *adapter, u8 *p=
buf);
+void rtw_survey_event_cb23a(struct rtw_adapter *adapter, u8 *pbuf);
+void rtw_surveydone_event_callback23a(struct rtw_adapter *adapter, u8 =
*pbuf);
+void rtw23a_joinbss_event_cb(struct rtw_adapter *adapter, u8 *pbuf);
+void rtw_stassoc_event_callback23a(struct rtw_adapter *adapter, u8 *pb=
uf);
+void rtw_stadel_event_callback23a(struct rtw_adapter *adapter, u8 *pbu=
f);
+void rtw_atimdone_event_callback23a(struct rtw_adapter *adapter, u8 *p=
buf);
+void rtw_cpwm_event_callback23a(struct rtw_adapter *adapter, u8 *pbuf)=
;
+
+
+int event_thread(void *context);
+void rtw23a_join_to_handler(unsigned long);
+
+void rtw_free_network_queue23a(struct rtw_adapter *adapter, u8 isfreea=
ll);
+int rtw_init_mlme_priv23a(struct rtw_adapter *adapter);
+
+void rtw_free_mlme_priv23a(struct mlme_priv *pmlmepriv);
+
+int rtw_select_and_join_from_scanned_queue23a(struct mlme_priv *pmlmep=
riv);
+int rtw_set_key23a(struct rtw_adapter *adapter,
+		struct security_priv *psecuritypriv, int keyid, u8 set_tx);
+int rtw_set_auth23a(struct rtw_adapter *adapter,
+		 struct security_priv *psecuritypriv);
+
+static inline u8 *get_bssid(struct mlme_priv *pmlmepriv)
+{	/* if sta_mode:pmlmepriv->cur_network.network.MacAddress =3D> bssid =
*/
+	/*  if adhoc_mode:pmlmepriv->cur_network.network.MacAddress =3D> ibss=
 mac address */
+	return pmlmepriv->cur_network.network.MacAddress;
+}
+
+static inline int check_fwstate(struct mlme_priv *pmlmepriv, int state=
)
+{
+	if (pmlmepriv->fw_state & state)
+		return true;
+
+	return false;
+}
+
+static inline int get_fwstate(struct mlme_priv *pmlmepriv)
+{
+	return pmlmepriv->fw_state;
+}
+
+/*
+ * No Limit on the calling context,
+ * therefore set it to be the critical section...
+ *
+ * ### NOTE:#### (!!!!)
+ * MUST TAKE CARE THAT BEFORE CALLING THIS FUNC, YOU SHOULD HAVE LOCKE=
D pmlmepriv->lock
+ */
+static inline void set_fwstate(struct mlme_priv *pmlmepriv, int state)
+{
+	pmlmepriv->fw_state |=3D state;
+	/* FOR HW integration */
+	if (_FW_UNDER_SURVEY =3D=3D state)
+		pmlmepriv->bScanInProcess =3D true;
+}
+
+static inline void _clr_fwstate_(struct mlme_priv *pmlmepriv, int stat=
e)
+{
+	pmlmepriv->fw_state &=3D ~state;
+	/* FOR HW integration */
+	if (_FW_UNDER_SURVEY =3D=3D state)
+		pmlmepriv->bScanInProcess =3D false;
+}
+
+/*
+ * No Limit on the calling context,
+ * therefore set it to be the critical section...
+ */
+static inline void clr_fwstate(struct mlme_priv *pmlmepriv, int state)
+{
+	spin_lock_bh(&pmlmepriv->lock);
+	if (check_fwstate(pmlmepriv, state) =3D=3D true)
+		pmlmepriv->fw_state ^=3D state;
+	spin_unlock_bh(&pmlmepriv->lock);
+}
+
+static inline void clr_fwstate_ex(struct mlme_priv *pmlmepriv, int sta=
te)
+{
+	spin_lock_bh(&pmlmepriv->lock);
+	_clr_fwstate_(pmlmepriv, state);
+	spin_unlock_bh(&pmlmepriv->lock);
+}
+
+u16 rtw_get_capability23a(struct wlan_bssid_ex *bss);
+void rtw_update_scanned_network23a(struct rtw_adapter *adapter,
+				struct wlan_bssid_ex *target);
+void rtw_disconnect_hdl23a_under_linked(struct rtw_adapter *adapter,
+				     struct sta_info *psta, u8 free_assoc);
+void rtw_generate_random_ibss23a(u8 *pibss);
+struct wlan_network *rtw_find_network23a(struct rtw_queue *scanned_que=
ue, u8 *addr);
+struct wlan_network *rtw_get_oldest_wlan_network23a(struct rtw_queue *=
scanned_queue);
+
+void rtw_free_assoc_resources23a(struct rtw_adapter *adapter,
+			      int lock_scanned_queue);
+void rtw_indicate_disconnect23a(struct rtw_adapter *adapter);
+void rtw_indicate_connect23a(struct rtw_adapter *adapter);
+void rtw_indicate_scan_done23a(struct rtw_adapter *padapter, bool abor=
ted);
+void rtw_scan_abort23a(struct rtw_adapter *adapter);
+
+int rtw_restruct_sec_ie23a(struct rtw_adapter *adapter, u8 *in_ie, u8 =
*out_ie,
+			uint in_len);
+int rtw_restruct_wmm_ie23a(struct rtw_adapter *adapter, u8 *in_ie, u8 =
*out_ie,
+			uint in_len, uint initial_out_len);
+void rtw_init_registrypriv_dev_network23a(struct rtw_adapter *adapter)=
;
+
+void rtw_update_registrypriv_dev_network23a(struct rtw_adapter *adapte=
r);
+
+void rtw_get_encrypt_decrypt_from_registrypriv23a(struct rtw_adapter *=
adapter);
+
+void rtw_scan_timeout_handler23a(unsigned long data);
+
+void rtw_dynamic_check_timer_handler(unsigned long data);
+bool rtw_is_scan_deny(struct rtw_adapter *adapter);
+void rtw_clear_scan_deny(struct rtw_adapter *adapter);
+void rtw_set_scan_deny_timer_hdl(unsigned long data);
+void rtw_set_scan_deny(struct rtw_adapter *adapter, u32 ms);
+
+int _rtw_init_mlme_priv23a(struct rtw_adapter *padapter);
+
+void rtw23a_free_mlme_priv_ie_data(struct mlme_priv *pmlmepriv);
+
+void _rtw_free_mlme_priv23a(struct mlme_priv *pmlmepriv);
+
+struct wlan_network *rtw_alloc_network(struct mlme_priv *pmlmepriv);
+
+void _rtw_free_network23a(struct mlme_priv *pmlmepriv,
+		       struct wlan_network *pnetwork, u8 isfreeall);
+void _rtw_free_network23a_nolock23a(struct mlme_priv *pmlmepriv,
+			      struct wlan_network *pnetwork);
+
+struct wlan_network *_rtw_find_network23a(struct rtw_queue *scanned_qu=
eue, u8 *addr);
+
+void _rtw_free_network23a_queue23a(struct rtw_adapter *padapter, u8 is=
freeall);
+
+int rtw_if_up23a(struct rtw_adapter *padapter);
+
+int rtw_linked_check(struct rtw_adapter *padapter);
+
+u8 *rtw_get_capability23a_from_ie(u8 *ie);
+u8 *rtw_get_timestampe_from_ie23a(u8 *ie);
+u8 *rtw_get_beacon_interval23a_from_ie(u8 *ie);
+
+
+void rtw_joinbss_reset23a(struct rtw_adapter *padapter);
+
+unsigned int rtw_restructure_ht_ie23a(struct rtw_adapter *padapter, u8=
 *in_ie,
+				   u8 *out_ie, uint in_len, uint *pout_len);
+void rtw_update_ht_cap23a(struct rtw_adapter *padapter,
+		       u8 *pie, uint ie_len);
+void rtw_issue_addbareq_cmd23a(struct rtw_adapter *padapter,
+			    struct xmit_frame *pxmitframe);
+
+int rtw_is_same_ibss23a(struct rtw_adapter *adapter,
+		     struct wlan_network *pnetwork);
+int is_same_network23a(struct wlan_bssid_ex *src, struct wlan_bssid_ex=
 *dst);
+
+void _rtw23a_roaming(struct rtw_adapter *adapter,
+		  struct wlan_network *tgt_network);
+void rtw23a_roaming(struct rtw_adapter *adapter,
+		 struct wlan_network *tgt_network);
+void rtw_set_roaming(struct rtw_adapter *adapter, u8 to_roaming);
+u8 rtw_to_roaming(struct rtw_adapter *adapter);
+void rtw_stassoc_hw_rpt23a(struct rtw_adapter *adapter, struct sta_inf=
o *psta);
+
+#endif /* __RTL871X_MLME_H_ */
diff --git a/drivers/staging/rtl8723au/include/rtw_mlme_ext.h b/drivers=
/staging/rtl8723au/include/rtw_mlme_ext.h
new file mode 100644
index 0000000..d1c2d71
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_mlme_ext.h
@@ -0,0 +1,782 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTW_MLME_EXT_H_
+#define __RTW_MLME_EXT_H_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <wlan_bssdef.h>
+
+
+/*	Commented by Albert 20101105 */
+/*	Increase the SURVEY_TO value from 100 to 150  ( 100ms to 150ms ) */
+/*	The Realtek 8188CE SoftAP will spend around 100ms to send the probe=
 response after receiving the probe request. */
+/*	So, this driver tried to extend the dwell time for each scanning ch=
annel. */
+/*	This will increase the chance to receive the probe response from So=
ftAP. */
+
+#define SURVEY_TO		(100)
+#define REAUTH_TO		(300) /* 50) */
+#define REASSOC_TO		(300) /* 50) */
+/* define DISCONNECT_TO	(3000) */
+#define ADDBA_TO			(2000)
+
+#define LINKED_TO (1) /* unit:2 sec, 1x2=3D2 sec */
+
+#define REAUTH_LIMIT	(4)
+#define REASSOC_LIMIT	(4)
+#define READDBA_LIMIT	(2)
+
+#define ROAMING_LIMIT	8
+
+#define	DYNAMIC_FUNC_DISABLE			(0x0)
+
+/*  =3D=3D=3D=3D=3D=3D enum odm_ability =3D=3D=3D=3D=3D=3D=3D=3D */
+/*  BB ODM section BIT 0-15 */
+#define	DYNAMIC_BB_DIG				BIT(0)
+#define	DYNAMIC_BB_RA_MASK			BIT(1)
+#define	DYNAMIC_BB_DYNAMIC_TXPWR	BIT(2)
+#define	DYNAMIC_BB_BB_FA_CNT			BIT(3)
+
+#define		DYNAMIC_BB_RSSI_MONITOR		BIT(4)
+#define		DYNAMIC_BB_CCK_PD			BIT(5)
+#define		DYNAMIC_BB_ANT_DIV			BIT(6)
+#define		DYNAMIC_BB_PWR_SAVE			BIT(7)
+#define		DYNAMIC_BB_PWR_TRAIN			BIT(8)
+#define		DYNAMIC_BB_RATE_ADAPTIVE		BIT(9)
+#define		DYNAMIC_BB_PATH_DIV			BIT(10)
+#define		DYNAMIC_BB_PSD				BIT(11)
+
+/*  MAC DM section BIT 16-23 */
+#define		DYNAMIC_MAC_struct edca_turboURBO		BIT(16)
+#define		DYNAMIC_MAC_EARLY_MODE		BIT(17)
+
+/*  RF ODM section BIT 24-31 */
+#define		DYNAMIC_RF_TX_PWR_TRACK		BIT(24)
+#define		DYNAMIC_RF_RX_GAIN_TRACK		BIT(25)
+#define		DYNAMIC_RF_CALIBRATION		BIT(26)
+
+#define		DYNAMIC_ALL_FUNC_ENABLE		0xFFFFFFF
+
+#define _HW_STATE_NOLINK_		0x00
+#define _HW_STATE_ADHOC_		0x01
+#define _HW_STATE_STATION_	0x02
+#define _HW_STATE_AP_			0x03
+
+
+#define		_1M_RATE_	0
+#define		_2M_RATE_	1
+#define		_5M_RATE_	2
+#define		_11M_RATE_	3
+#define		_6M_RATE_	4
+#define		_9M_RATE_	5
+#define		_12M_RATE_	6
+#define		_18M_RATE_	7
+#define		_24M_RATE_	8
+#define		_36M_RATE_	9
+#define		_48M_RATE_	10
+#define		_54M_RATE_	11
+
+
+extern unsigned char RTW_WPA_OUI23A[];
+extern unsigned char WMM_OUI23A[];
+extern unsigned char WPS_OUI23A[];
+extern unsigned char WFD_OUI23A[];
+extern unsigned char P2P_OUI23A[];
+
+extern unsigned char WMM_INFO_OUI23A[];
+extern unsigned char WMM_PARA_OUI23A[];
+
+
+/*  */
+/*  Channel Plan Type. */
+/*  Note: */
+/*	We just add new channel plan when the new channel plan is different=
 from any of the following */
+/*	channel plan. */
+/*	If you just wnat to customize the acitions(scan period or join acti=
ons) about one of the channel plan, */
+/*	customize them in struct rt_channel_info in the RT_CHANNEL_LIST. */
+/*  */
+enum  { /* _RT_CHANNEL_DOMAIN */
+	/*  old channel plan mapping =3D=3D=3D=3D=3D */
+	RT_CHANNEL_DOMAIN_FCC =3D 0x00,
+	RT_CHANNEL_DOMAIN_IC =3D 0x01,
+	RT_CHANNEL_DOMAIN_ETSI =3D 0x02,
+	RT_CHANNEL_DOMAIN_SPAIN =3D 0x03,
+	RT_CHANNEL_DOMAIN_FRANCE =3D 0x04,
+	RT_CHANNEL_DOMAIN_MKK =3D 0x05,
+	RT_CHANNEL_DOMAIN_MKK1 =3D 0x06,
+	RT_CHANNEL_DOMAIN_ISRAEL =3D 0x07,
+	RT_CHANNEL_DOMAIN_TELEC =3D 0x08,
+	RT_CHANNEL_DOMAIN_GLOBAL_DOAMIN =3D 0x09,
+	RT_CHANNEL_DOMAIN_WORLD_WIDE_13 =3D 0x0A,
+	RT_CHANNEL_DOMAIN_TAIWAN =3D 0x0B,
+	RT_CHANNEL_DOMAIN_CHINA =3D 0x0C,
+	RT_CHANNEL_DOMAIN_SINGAPORE_INDIA_MEXICO =3D 0x0D,
+	RT_CHANNEL_DOMAIN_KOREA =3D 0x0E,
+	RT_CHANNEL_DOMAIN_TURKEY =3D 0x0F,
+	RT_CHANNEL_DOMAIN_JAPAN =3D 0x10,
+	RT_CHANNEL_DOMAIN_FCC_NO_DFS =3D 0x11,
+	RT_CHANNEL_DOMAIN_JAPAN_NO_DFS =3D 0x12,
+	RT_CHANNEL_DOMAIN_WORLD_WIDE_5G =3D 0x13,
+	RT_CHANNEL_DOMAIN_TAIWAN_NO_DFS =3D 0x14,
+
+	/*  new channel plan mapping, (2GDOMAIN_5GDOMAIN) =3D=3D=3D=3D=3D */
+	RT_CHANNEL_DOMAIN_WORLD_NULL =3D 0x20,
+	RT_CHANNEL_DOMAIN_ETSI1_NULL =3D 0x21,
+	RT_CHANNEL_DOMAIN_FCC1_NULL =3D 0x22,
+	RT_CHANNEL_DOMAIN_MKK1_NULL =3D 0x23,
+	RT_CHANNEL_DOMAIN_ETSI2_NULL =3D 0x24,
+	RT_CHANNEL_DOMAIN_FCC1_FCC1 =3D 0x25,
+	RT_CHANNEL_DOMAIN_WORLD_ETSI1 =3D 0x26,
+	RT_CHANNEL_DOMAIN_MKK1_MKK1 =3D 0x27,
+	RT_CHANNEL_DOMAIN_WORLD_KCC1 =3D 0x28,
+	RT_CHANNEL_DOMAIN_WORLD_FCC2 =3D 0x29,
+	RT_CHANNEL_DOMAIN_WORLD_FCC3 =3D 0x30,
+	RT_CHANNEL_DOMAIN_WORLD_FCC4 =3D 0x31,
+	RT_CHANNEL_DOMAIN_WORLD_FCC5 =3D 0x32,
+	RT_CHANNEL_DOMAIN_WORLD_FCC6 =3D 0x33,
+	RT_CHANNEL_DOMAIN_FCC1_FCC7 =3D 0x34,
+	RT_CHANNEL_DOMAIN_WORLD_ETSI2 =3D 0x35,
+	RT_CHANNEL_DOMAIN_WORLD_ETSI3 =3D 0x36,
+	RT_CHANNEL_DOMAIN_MKK1_MKK2 =3D 0x37,
+	RT_CHANNEL_DOMAIN_MKK1_MKK3 =3D 0x38,
+	RT_CHANNEL_DOMAIN_FCC1_NCC1 =3D 0x39,
+	RT_CHANNEL_DOMAIN_FCC1_NCC2 =3D 0x40,
+	RT_CHANNEL_DOMAIN_GLOBAL_DOAMIN_2G =3D 0x41,
+	/*  Add new channel plan above this line=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D */
+	RT_CHANNEL_DOMAIN_MAX,
+	RT_CHANNEL_DOMAIN_REALTEK_DEFINE =3D 0x7F,
+};
+
+enum { /* _RT_CHANNEL_DOMAIN_2G */
+	RT_CHANNEL_DOMAIN_2G_WORLD =3D 0x00,		/* Worldwird 13 */
+	RT_CHANNEL_DOMAIN_2G_ETSI1 =3D 0x01,		/* Europe */
+	RT_CHANNEL_DOMAIN_2G_FCC1 =3D 0x02,		/* US */
+	RT_CHANNEL_DOMAIN_2G_MKK1 =3D 0x03,		/* Japan */
+	RT_CHANNEL_DOMAIN_2G_ETSI2 =3D 0x04,		/* France */
+	RT_CHANNEL_DOMAIN_2G_NULL =3D 0x05,
+	/*  Add new channel plan above this line=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D */
+	RT_CHANNEL_DOMAIN_2G_MAX,
+};
+
+enum { /* _RT_CHANNEL_DOMAIN_5G */
+	RT_CHANNEL_DOMAIN_5G_NULL =3D 0x00,
+	RT_CHANNEL_DOMAIN_5G_ETSI1 =3D 0x01,		/* Europe */
+	RT_CHANNEL_DOMAIN_5G_ETSI2 =3D 0x02,		/* Australia, New Zealand */
+	RT_CHANNEL_DOMAIN_5G_ETSI3 =3D 0x03,		/* Russia */
+	RT_CHANNEL_DOMAIN_5G_FCC1 =3D 0x04,		/* US */
+	RT_CHANNEL_DOMAIN_5G_FCC2 =3D 0x05,		/* FCC o/w DFS Channels */
+	RT_CHANNEL_DOMAIN_5G_FCC3 =3D 0x06,		/* India, Mexico */
+	RT_CHANNEL_DOMAIN_5G_FCC4 =3D 0x07,		/* Venezuela */
+	RT_CHANNEL_DOMAIN_5G_FCC5 =3D 0x08,		/* China */
+	RT_CHANNEL_DOMAIN_5G_FCC6 =3D 0x09,		/* Israel */
+	RT_CHANNEL_DOMAIN_5G_FCC7_IC1 =3D 0x0A,	/* US, Canada */
+	RT_CHANNEL_DOMAIN_5G_KCC1 =3D 0x0B,		/* Korea */
+	RT_CHANNEL_DOMAIN_5G_MKK1 =3D 0x0C,		/* Japan */
+	RT_CHANNEL_DOMAIN_5G_MKK2 =3D 0x0D,		/* Japan (W52, W53) */
+	RT_CHANNEL_DOMAIN_5G_MKK3 =3D 0x0E,		/* Japan (W56) */
+	RT_CHANNEL_DOMAIN_5G_NCC1 =3D 0x0F,		/* Taiwan */
+	RT_CHANNEL_DOMAIN_5G_NCC2 =3D 0x10,		/* Taiwan o/w DFS */
+	/*  Add new channel plan above this line=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D */
+	/*  Driver Self Defined =3D=3D=3D=3D=3D */
+	RT_CHANNEL_DOMAIN_5G_FCC =3D 0x11,
+	RT_CHANNEL_DOMAIN_5G_JAPAN_NO_DFS =3D 0x12,
+	RT_CHANNEL_DOMAIN_5G_FCC4_NO_DFS =3D 0x13,
+	RT_CHANNEL_DOMAIN_5G_MAX,
+};
+
+#define rtw_is_channel_plan_valid(chplan) (chplan<RT_CHANNEL_DOMAIN_MA=
X || chplan =3D=3D RT_CHANNEL_DOMAIN_REALTEK_DEFINE)
+
+struct rt_channel_plan {
+	unsigned char	Channel[MAX_CHANNEL_NUM];
+	unsigned char	Len;
+};
+
+struct rt_channel_plan_2g {
+	unsigned char	Channel[MAX_CHANNEL_NUM_2G];
+	unsigned char	Len;
+};
+
+struct rt_channel_plan_5g {
+	unsigned char	Channel[MAX_CHANNEL_NUM_5G];
+	unsigned char	Len;
+};
+
+struct rt_channel_plan_map {
+	unsigned char	Index2G;
+	unsigned char	Index5G;
+};
+
+enum Associated_AP {
+	atherosAP	=3D 0,
+	broadcomAP	=3D 1,
+	ciscoAP		=3D 2,
+	marvellAP	=3D 3,
+	ralinkAP	=3D 4,
+	realtekAP	=3D 5,
+	airgocapAP	=3D 6,
+	unknownAP	=3D 7,
+	maxAP,
+};
+
+enum { /* HT_IOT_PEER_E */
+	HT_IOT_PEER_UNKNOWN		=3D 0,
+	HT_IOT_PEER_REALTEK		=3D 1,
+	HT_IOT_PEER_REALTEK_92SE	=3D 2,
+	HT_IOT_PEER_BROADCOM		=3D 3,
+	HT_IOT_PEER_RALINK		=3D 4,
+	HT_IOT_PEER_ATHEROS		=3D 5,
+	HT_IOT_PEER_CISCO		=3D 6,
+	HT_IOT_PEER_MERU		=3D 7,
+	HT_IOT_PEER_MARVELL		=3D 8,
+	HT_IOT_PEER_REALTEK_SOFTAP	=3D 9,/*  peer is RealTek SOFT_AP, by Bohn=
, 2009.12.17 */
+	HT_IOT_PEER_SELF_SOFTAP		=3D 10, /*  Self is SoftAP */
+	HT_IOT_PEER_AIRGO		=3D 11,
+	HT_IOT_PEER_INTEL		=3D 12,
+	HT_IOT_PEER_RTK_APCLIENT	=3D 13,
+	HT_IOT_PEER_REALTEK_81XX	=3D 14,
+	HT_IOT_PEER_REALTEK_WOW		=3D 15,
+	HT_IOT_PEER_TENDA		=3D 16,
+	HT_IOT_PEER_MAX			=3D 17
+};
+
+enum SCAN_STATE {
+	SCAN_DISABLE =3D 0,
+	SCAN_START =3D 1,
+	SCAN_TXNULL =3D 2,
+	SCAN_PROCESS =3D 3,
+	SCAN_COMPLETE =3D 4,
+	SCAN_STATE_MAX,
+};
+
+struct mlme_handler {
+	char *str;
+	unsigned int (*func)(struct rtw_adapter *padapter, struct recv_frame =
*precv_frame);
+};
+
+struct action_handler {
+	unsigned int   num;
+	char* str;
+	unsigned int (*func)(struct rtw_adapter *padapter, struct recv_frame =
*precv_frame);
+};
+
+struct	ss_res
+{
+	int	state;
+	int	bss_cnt;
+	int	channel_idx;
+	int	scan_mode;
+	u8 ssid_num;
+	u8 ch_num;
+	struct cfg80211_ssid ssid[RTW_SSID_SCAN_AMOUNT];
+	struct rtw_ieee80211_channel ch[RTW_CHANNEL_SCAN_AMOUNT];
+};
+
+/* define AP_MODE				0x0C */
+/* define STATION_MODE	0x08 */
+/* define AD_HOC_MODE		0x04 */
+/* define NO_LINK_MODE	0x00 */
+
+#define		WIFI_FW_NULL_STATE			_HW_STATE_NOLINK_
+#define	WIFI_FW_STATION_STATE		_HW_STATE_STATION_
+#define	WIFI_FW_AP_STATE				_HW_STATE_AP_
+#define	WIFI_FW_ADHOC_STATE			_HW_STATE_ADHOC_
+
+#define	WIFI_FW_AUTH_NULL			0x00000100
+#define	WIFI_FW_AUTH_STATE			0x00000200
+#define	WIFI_FW_AUTH_SUCCESS			0x00000400
+
+#define	WIFI_FW_ASSOC_STATE			0x00002000
+#define	WIFI_FW_ASSOC_SUCCESS		0x00004000
+
+#define	WIFI_FW_LINKING_STATE		(WIFI_FW_AUTH_NULL | WIFI_FW_AUTH_STATE=
 | WIFI_FW_AUTH_SUCCESS |WIFI_FW_ASSOC_STATE)
+
+struct FW_Sta_Info {
+	struct sta_info	*psta;
+	u32	status;
+	u32	rx_pkt;
+	u32	retry;
+	unsigned char SupportedRates[NDIS_802_11_LENGTH_RATES_EX];
+};
+
+/*
+ * Usage:
+ * When one iface acted as AP mode and the other iface is STA mode and=
 scanning,
+ * it should switch back to AP's operating channel periodically.
+ * Parameters info:
+ * When the driver scanned RTW_SCAN_NUM_OF_CH channels, it would switc=
h back to AP's operating channel for
+ * RTW_STAY_AP_CH_MILLISECOND * SURVEY_TO milliseconds.
+ * Example:
+ * For chip supports 2.4G + 5GHz and AP mode is operating in channel 1=
,
+ * RTW_SCAN_NUM_OF_CH is 8, RTW_STAY_AP_CH_MILLISECOND is 3 and SURVEY=
_TO is 100.
+ * When it's STA mode gets set_scan command,
+ * it would
+ * 1. Doing the scan on channel 1.2.3.4.5.6.7.8
+ * 2. Back to channel 1 for 300 milliseconds
+ * 3. Go through doing site survey on channel 9.10.11.36.40.44.48.52
+ * 4. Back to channel 1 for 300 milliseconds
+ * 5. ... and so on, till survey done.
+ */
+
+struct mlme_ext_info
+{
+	u32	state;
+	u32	reauth_count;
+	u32	reassoc_count;
+	u32	link_count;
+	u32	auth_seq;
+	u32	auth_algo;	/*  802.11 auth, could be open, shared, auto */
+	u32	authModeToggle;
+	u32	enc_algo;/* encrypt algorithm; */
+	u32	key_index;	/*  this is only valid for legendary wep, 0~3 for key =
id. */
+	u32	iv;
+	u8	chg_txt[128];
+	u16	aid;
+	u16	bcn_interval;
+	u16	capability;
+	u8	assoc_AP_vendor;
+	u8	slotTime;
+	u8	preamble_mode;
+	u8	WMM_enable;
+	u8	ERP_enable;
+	u8	ERP_IE;
+	u8	HT_enable;
+	u8	HT_caps_enable;
+	u8	HT_info_enable;
+	u8	HT_protection;
+	u8	turboMode_cts2self;
+	u8	turboMode_rtsen;
+	u8	SM_PS;
+	u8	agg_enable_bitmap;
+	u8	ADDBA_retry_count;
+	u8	candidate_tid_bitmap;
+	u8	dialogToken;
+	/*  Accept ADDBA Request */
+	bool bAcceptAddbaReq;
+	u8	bwmode_updated;
+	u8	hidden_ssid_mode;
+
+	struct ADDBA_request		ADDBA_req;
+	struct WMM_para_element	WMM_param;
+	struct HT_caps_element	HT_caps;
+	struct HT_info_element		HT_info;
+	struct wlan_bssid_ex			network;/* join network or bss_network, if in =
ap mode, it is the same to cur_network.network */
+	struct FW_Sta_Info		FW_sta_info[NUM_STA];
+};
+
+/*  The channel information about this channel including joining, scan=
ning, and power constraints. */
+struct rt_channel_info {
+	u8		ChannelNum;		/*  The channel number. */
+	enum rt_scan_type ScanType;		/*  Scan type such as passive or active =
scan. */
+};
+
+int rtw_ch_set_search_ch23a(struct rt_channel_info *ch_set, const u32 =
ch);
+
+/*  P2P_MAX_REG_CLASSES - Maximum number of regulatory classes */
+#define P2P_MAX_REG_CLASSES 10
+
+/*  P2P_MAX_REG_CLASS_CHANNELS - Maximum number of channels per regula=
tory class */
+#define P2P_MAX_REG_CLASS_CHANNELS 20
+
+/*   struct p2p_channels - List of supported channels */
+struct p2p_channels {
+	/*  struct p2p_reg_class - Supported regulatory class */
+	struct p2p_reg_class {
+		/*  reg_class - Regulatory class (IEEE 802.11-2007, Annex J) */
+		u8 reg_class;
+
+		/*  channel - Supported channels */
+		u8 channel[P2P_MAX_REG_CLASS_CHANNELS];
+
+		/*  channels - Number of channel entries in use */
+		size_t channels;
+	} reg_class[P2P_MAX_REG_CLASSES];
+
+	/*  reg_classes - Number of reg_class entries in use */
+	size_t reg_classes;
+};
+
+struct p2p_oper_class_map {
+	enum hw_mode {IEEE80211G,IEEE80211A} mode;
+	u8 op_class;
+	u8 min_chan;
+	u8 max_chan;
+	u8 inc;
+	enum {
+		BW20, BW40PLUS, BW40MINUS
+	} bw;
+};
+
+struct mlme_ext_priv {
+	struct rtw_adapter	*padapter;
+	u8	mlmeext_init;
+	atomic_t		event_seq;
+	u16	mgnt_seq;
+
+	/* struct fw_priv	fwpriv; */
+
+	unsigned char	cur_channel;
+	unsigned char	cur_bwmode;
+	unsigned char	cur_ch_offset;/* PRIME_CHNL_OFFSET */
+	unsigned char	cur_wireless_mode;	/*  NETWORK_TYPE */
+
+	unsigned char	max_chan_nums;
+	struct rt_channel_info		channel_set[MAX_CHANNEL_NUM];
+	struct p2p_channels channel_list;
+	unsigned char	basicrate[NumRates];
+	unsigned char	datarate[NumRates];
+
+	struct ss_res		sitesurvey_res;
+	struct mlme_ext_info	mlmext_info;/* for sta/adhoc mode, including cur=
rent scanning/connecting/connected related info. */
+                                                     /* for ap mode, n=
etwork includes ap's cap_info */
+	struct timer_list		survey_timer;
+	struct timer_list		link_timer;
+	u16			chan_scan_time;
+
+	u8	scan_abort;
+	u8	tx_rate; /*  TXRATE when USERATE is set. */
+
+	u32	retry; /* retry for issue probereq */
+
+	u64 TSFValue;
+
+#ifdef CONFIG_8723AU_AP_MODE
+	unsigned char bstart_bss;
+#endif
+	u8 update_channel_plan_by_ap_done;
+	/* recv_decache check for Action_public frame */
+	u8 action_public_dialog_token;
+	u16	 action_public_rxseq;
+	u8 active_keep_alive_check;
+};
+
+int init_mlme_ext_priv23a(struct rtw_adapter* padapter);
+int init_hw_mlme_ext23a(struct rtw_adapter *padapter);
+void free_mlme_ext_priv23a (struct mlme_ext_priv *pmlmeext);
+void init_mlme_ext_timer23a(struct rtw_adapter *padapter);
+void init_addba_retry_timer23a(struct sta_info *psta);
+struct xmit_frame *alloc_mgtxmitframe23a(struct xmit_priv *pxmitpriv);
+
+unsigned char networktype_to_raid23a(unsigned char network_type);
+u8 judge_network_type23a(struct rtw_adapter *padapter, unsigned char *=
rate,
+		      int ratelen);
+void get_rate_set23a(struct rtw_adapter *padapter, unsigned char *pbss=
rate,
+		  int *bssrate_len);
+void UpdateBrateTbl23a(struct rtw_adapter *padapter,u8 *mBratesOS);
+void Update23aTblForSoftAP(u8 *bssrateset, u32 bssratelen);
+
+void Save_DM_Func_Flag23a(struct rtw_adapter *padapter);
+void Restore_DM_Func_Flag23a(struct rtw_adapter *padapter);
+void Switch_DM_Func23a(struct rtw_adapter *padapter, unsigned long mod=
e, u8 enable);
+
+void Set_MSR23a(struct rtw_adapter *padapter, u8 type);
+
+u8 rtw_get_oper_ch23a(struct rtw_adapter *adapter);
+void rtw_set_oper_ch23a(struct rtw_adapter *adapter, u8 ch);
+u8 rtw_get_oper_bw23a(struct rtw_adapter *adapter);
+void rtw_set_oper_bw23a(struct rtw_adapter *adapter, u8 bw);
+u8 rtw_get_oper_ch23aoffset(struct rtw_adapter *adapter);
+void rtw_set_oper_ch23aoffset23a(struct rtw_adapter *adapter, u8 offse=
t);
+
+void set_channel_bwmode23a(struct rtw_adapter *padapter, unsigned char=
 channel,
+			unsigned char channel_offset, unsigned short bwmode);
+void SelectChannel23a(struct rtw_adapter *padapter, unsigned char chan=
nel);
+void SetBWMode23a(struct rtw_adapter *padapter, unsigned short bwmode,
+	       unsigned char channel_offset);
+
+unsigned int decide_wait_for_beacon_timeout23a(unsigned int bcn_interv=
al);
+
+void write_cam23a(struct rtw_adapter *padapter, u8 entry, u16 ctrl,
+	       u8 *mac, u8 *key);
+void clear_cam_entry23a(struct rtw_adapter *padapter, u8 entry);
+
+void invalidate_cam_all23a(struct rtw_adapter *padapter);
+void CAM_empty_entry23a(struct rtw_adapter *Adapter, u8 ucIndex);
+
+int allocate_fw_sta_entry23a(struct rtw_adapter *padapter);
+void flush_all_cam_entry23a(struct rtw_adapter *padapter);
+
+bool IsLegal5GChannel(struct rtw_adapter *Adapter, u8 channel);
+
+void site_survey23a(struct rtw_adapter *padapter);
+u8 collect_bss_info23a(struct rtw_adapter *padapter,
+		    struct recv_frame *precv_frame,
+		    struct wlan_bssid_ex *bssid);
+void update_network23a(struct wlan_bssid_ex *dst, struct wlan_bssid_ex=
 *src,
+		    struct rtw_adapter *padapter, bool update_ie);
+
+int get_bsstype23a(unsigned short capability);
+u8 *get_my_bssid23a(struct wlan_bssid_ex *pnetwork);
+u16 get_beacon_interval23a(struct wlan_bssid_ex *bss);
+
+int is_client_associated_to_ap23a(struct rtw_adapter *padapter);
+int is_client_associated_to_ibss23a(struct rtw_adapter *padapter);
+int is_IBSS_empty23a(struct rtw_adapter *padapter);
+
+unsigned char check_assoc_AP23a(u8 *pframe, uint len);
+
+int WMM_param_handler23a(struct rtw_adapter *padapter,
+		      struct ndis_802_11_var_ies *pIE);
+#ifdef CONFIG_8723AU_P2P
+int WFD_info_handler(struct rtw_adapter *padapter,
+		     struct ndis_802_11_var_ies *pIE);
+#endif
+void WMMOnAssocRsp23a(struct rtw_adapter *padapter);
+
+void HT_caps_handler23a(struct rtw_adapter *padapter,
+		     struct ndis_802_11_var_ies *pIE);
+void HT_info_handler23a(struct rtw_adapter *padapter,
+		     struct ndis_802_11_var_ies *pIE);
+void HTOnAssocRsp23a(struct rtw_adapter *padapter);
+
+void ERP_IE_handler23a(struct rtw_adapter *padapter,
+		    struct ndis_802_11_var_ies *pIE);
+void VCS_update23a(struct rtw_adapter *padapter, struct sta_info *psta=
);
+
+void update_beacon23a_info(struct rtw_adapter *padapter, u8 *pframe, u=
int len,
+			struct sta_info *psta);
+int rtw_check_bcn_info23a(struct rtw_adapter *Adapter, u8 *pframe, u32=
 packet_len);
+void update_IOT_info23a(struct rtw_adapter *padapter);
+void update_capinfo23a(struct rtw_adapter *Adapter, u16 updateCap);
+void update_wireless_mode23a(struct rtw_adapter * padapter);
+void update_tx_basic_rate23a(struct rtw_adapter *padapter, u8 modulati=
on);
+void update_bmc_sta_support_rate23a(struct rtw_adapter *padapter, u32 =
mac_id);
+int update_sta_support_rate23a(struct rtw_adapter *padapter, u8* pvar_=
ie,
+			    uint var_ie_len, int cam_idx);
+
+/* for sta/adhoc mode */
+void update_sta_info23a(struct rtw_adapter *padapter, struct sta_info =
*psta);
+unsigned int update_basic_rate23a(unsigned char *ptn, unsigned int ptn=
_sz);
+unsigned int update_supported_rate23a(unsigned char *ptn, unsigned int=
 ptn_sz);
+unsigned int update_MSC_rate23a(struct HT_caps_element *pHT_caps);
+void Update_RA_Entry23a(struct rtw_adapter *padapter, struct sta_info =
*psta);
+void set_sta_rate23a(struct rtw_adapter *padapter, struct sta_info *ps=
ta);
+
+unsigned int receive_disconnect23a(struct rtw_adapter *padapter,
+				unsigned char *MacAddr, unsigned short reason);
+
+unsigned char get_highest_rate_idx23a(u32 mask);
+int support_short_GI23a(struct rtw_adapter *padapter,
+		     struct HT_caps_element *pHT_caps);
+unsigned int is_ap_in_tkip23a(struct rtw_adapter *padapter);
+unsigned int is_ap_in_wep23a(struct rtw_adapter *padapter);
+unsigned int should_forbid_n_rate23a(struct rtw_adapter *padapter);
+
+void report_join_res23a(struct rtw_adapter *padapter, int res);
+void report_survey_event23a(struct rtw_adapter *padapter,
+			 struct recv_frame *precv_frame);
+void report_surveydone_event23a(struct rtw_adapter *padapter);
+void report_del_sta_event23a(struct rtw_adapter *padapter,
+			  unsigned char *MacAddr, unsigned short reason);
+void report_add_sta_event23a(struct rtw_adapter *padapter,
+			  unsigned char *MacAddr, int cam_idx);
+
+void beacon_timing_control23a(struct rtw_adapter *padapter);
+u8 set_tx_beacon_cmd23a(struct rtw_adapter*padapter);
+unsigned int setup_beacon_frame(struct rtw_adapter *padapter,
+				unsigned char *beacon_frame);
+void update_mgnt_tx_rate23a(struct rtw_adapter *padapter, u8 rate);
+void update_mgntframe_attrib23a(struct rtw_adapter *padapter,
+			     struct pkt_attrib *pattrib);
+void dump_mgntframe23a(struct rtw_adapter *padapter,
+		    struct xmit_frame *pmgntframe);
+s32 dump_mgntframe23a_and_wait(struct rtw_adapter *padapter,
+			    struct xmit_frame *pmgntframe, int timeout_ms);
+s32 dump_mgntframe23a_and_wait_ack23a(struct rtw_adapter *padapter,
+				struct xmit_frame *pmgntframe);
+
+#ifdef CONFIG_8723AU_P2P
+void issue_probersp23a_p2p23a(struct rtw_adapter *padapter, unsigned c=
har *da);
+void issue_p2p_provision_request23a(struct rtw_adapter *padapter, u8 *=
pssid,
+				 u8 ussidlen, u8* pdev_raddr);
+void issue_p2p_GO_request23a(struct rtw_adapter *padapter, u8* raddr);
+void issue23a_probereq_p2p(struct rtw_adapter *padapter, u8 *da);
+int issue23a_probereq_p2p_ex(struct rtw_adapter *adapter, u8 *da, int =
try_cnt,
+			  int wait_ms);
+void issue_p2p_invitation_response23a(struct rtw_adapter *padapter, u8=
* raddr,
+				   u8 dialogToken, u8 success);
+void issue_p2p_invitation_request23a(struct rtw_adapter *padapter, u8*=
 raddr);
+#endif /* CONFIG_8723AU_P2P */
+void issue_beacon23a(struct rtw_adapter *padapter, int timeout_ms);
+void issue_probersp23a(struct rtw_adapter *padapter, unsigned char *da=
,
+		    u8 is_valid_p2p_probereq);
+void issue_assocreq23a(struct rtw_adapter *padapter);
+void issue_asocrsp23a(struct rtw_adapter *padapter, unsigned short sta=
tus,
+		   struct sta_info *pstat, int pkt_type);
+void issue_auth23a(struct rtw_adapter *padapter, struct sta_info *psta=
,
+		unsigned short status);
+void issue_probereq23a(struct rtw_adapter *padapter, struct cfg80211_s=
sid *pssid,
+		    u8 *da);
+s32 issue_probereq23a_ex23a(struct rtw_adapter *padapter, struct cfg80=
211_ssid *pssid,
+		      u8 *da, int try_cnt, int wait_ms);
+int issue_nulldata23a(struct rtw_adapter *padapter, unsigned char *da,
+		   unsigned int power_mode, int try_cnt, int wait_ms);
+int issue_qos_nulldata23a(struct rtw_adapter *padapter, unsigned char =
*da, u16 tid,
+		       int try_cnt, int wait_ms);
+int issue_deauth23a(struct rtw_adapter *padapter, unsigned char *da,
+		 unsigned short reason);
+int issue_deauth23a_ex23a(struct rtw_adapter *padapter, u8 *da, unsign=
ed short reason,
+		    int try_cnt, int wait_ms);
+void issue_action_spct_ch_switch23a(struct rtw_adapter *padapter, u8 *=
ra,
+				 u8 new_ch, u8 ch_offset);
+void issue_action_BA23a(struct rtw_adapter *padapter, unsigned char *r=
addr,
+		     unsigned char action, unsigned short status);
+unsigned int send_delba23a(struct rtw_adapter *padapter, u8 initiator,=
 u8 *addr);
+unsigned int send_beacon23a(struct rtw_adapter *padapter);
+
+void start_clnt_assoc23a(struct rtw_adapter *padapter);
+void start_clnt_auth23a(struct rtw_adapter *padapter);
+void start_clnt_join23a(struct rtw_adapter *padapter);
+void start_create_ibss23a(struct rtw_adapter *padapter);
+
+unsigned int OnAssocReq23a(struct rtw_adapter *padapter, struct recv_f=
rame *precv_frame);
+unsigned int OnAssocRsp23a(struct rtw_adapter *padapter, struct recv_f=
rame *precv_frame);
+unsigned int OnProbeReq23a(struct rtw_adapter *padapter, struct recv_f=
rame *precv_frame);
+unsigned int OnProbeRsp23a(struct rtw_adapter *padapter, struct recv_f=
rame *precv_frame);
+unsigned int DoReserved23a(struct rtw_adapter *padapter, struct recv_f=
rame *precv_frame);
+unsigned int OnBeacon23a(struct rtw_adapter *padapter, struct recv_fra=
me *precv_frame);
+unsigned int OnAtim23a(struct rtw_adapter *padapter, struct recv_frame=
 *precv_frame);
+unsigned int OnDisassoc23a(struct rtw_adapter *padapter, struct recv_f=
rame *precv_frame);
+unsigned int OnAuth23a(struct rtw_adapter *padapter, struct recv_frame=
 *precv_frame);
+unsigned int OnAuth23aClient23a(struct rtw_adapter *padapter, struct r=
ecv_frame *precv_frame);
+unsigned int OnDeAuth23a(struct rtw_adapter *padapter, struct recv_fra=
me *precv_frame);
+unsigned int OnAction23a(struct rtw_adapter *padapter, struct recv_fra=
me *precv_frame);
+
+unsigned int on_action_spct23a(struct rtw_adapter *padapter, struct re=
cv_frame *precv_frame);
+unsigned int OnAction23a_qos(struct rtw_adapter *padapter, struct recv=
_frame *precv_frame);
+unsigned int OnAction23a_dls(struct rtw_adapter *padapter, struct recv=
_frame *precv_frame);
+unsigned int OnAction23a_back23a(struct rtw_adapter *padapter, struct =
recv_frame *precv_frame);
+unsigned int on_action_public23a(struct rtw_adapter *padapter, struct =
recv_frame *precv_frame);
+unsigned int OnAction23a_ht(struct rtw_adapter *padapter, struct recv_=
frame *precv_frame);
+unsigned int OnAction23a_wmm(struct rtw_adapter *padapter, struct recv=
_frame *precv_frame);
+unsigned int OnAction23a_p2p(struct rtw_adapter *padapter, struct recv=
_frame *precv_frame);
+
+
+void mlmeext_joinbss_event_callback23a(struct rtw_adapter *padapter, i=
nt join_res);
+void mlmeext_sta_del_event_callback23a(struct rtw_adapter *padapter);
+void mlmeext_sta_add_event_callback23a(struct rtw_adapter *padapter, s=
truct sta_info *psta);
+
+void linked_status_chk23a(struct rtw_adapter *padapter);
+
+#define set_survey_timer(mlmeext, ms) \
+	/*DBG_8723A("%s set_survey_timer(%p, %d)\n", __FUNCTION__, (mlmeext),=
 (ms));*/ \
+	mod_timer(&mlmeext->survey_timer, jiffies + msecs_to_jiffies(ms));
+
+#define set_link_timer(mlmeext, ms) \
+	/*DBG_8723A("%s set_link_timer(%p, %d)\n", __FUNCTION__, (mlmeext), (=
ms));*/ \
+	mod_timer(&mlmeext->link_timer, jiffies + msecs_to_jiffies(ms));
+
+int cckrates_included23a(unsigned char *rate, int ratelen);
+int cckratesonly_included23a(unsigned char *rate, int ratelen);
+
+void process_addba_req23a(struct rtw_adapter *padapter, u8 *paddba_req=
, u8 *addr);
+
+void update_TSF23a(struct mlme_ext_priv *pmlmeext, u8 *pframe, uint le=
n);
+void correct_TSF23a(struct rtw_adapter *padapter, struct mlme_ext_priv=
 *pmlmeext);
+
+struct cmd_hdl {
+	uint	parmsize;
+	u8 (*h2cfuns)(struct rtw_adapter *padapter, u8 *pbuf);
+};
+
+
+u8 read_macreg_hdl(struct rtw_adapter *padapter, u8 *pbuf);
+u8 write_macreg_hdl(struct rtw_adapter *padapter, u8 *pbuf);
+u8 read_bbreg_hdl(struct rtw_adapter *padapter, u8 *pbuf);
+u8 write_bbreg_hdl(struct rtw_adapter *padapter, u8 *pbuf);
+u8 read_rfreg_hdl(struct rtw_adapter *padapter, u8 *pbuf);
+u8 write_rfreg_hdl(struct rtw_adapter *padapter, u8 *pbuf);
+
+
+u8 NULL_hdl23a(struct rtw_adapter *padapter, u8 *pbuf);
+u8 join_cmd_hdl23a(struct rtw_adapter *padapter, u8 *pbuf);
+u8 disconnect_hdl23a(struct rtw_adapter *padapter, u8 *pbuf);
+u8 createbss_hdl23a(struct rtw_adapter *padapter, u8 *pbuf);
+u8 setopmode_hdl23a(struct rtw_adapter *padapter, u8 *pbuf);
+u8 sitesurvey_cmd_hdl23a(struct rtw_adapter *padapter, u8 *pbuf);
+u8 setauth_hdl23a(struct rtw_adapter *padapter, u8 *pbuf);
+u8 setkey_hdl23a(struct rtw_adapter *padapter, u8 *pbuf);
+u8 set_stakey_hdl23a(struct rtw_adapter *padapter, u8 *pbuf);
+u8 set_assocsta_hdl(struct rtw_adapter *padapter, u8 *pbuf);
+u8 del_assocsta_hdl(struct rtw_adapter *padapter, u8 *pbuf);
+u8 add_ba_hdl23a(struct rtw_adapter *padapter, unsigned char *pbuf);
+
+u8 mlme_evt_hdl23a(struct rtw_adapter *padapter, unsigned char *pbuf);
+u8 h2c_msg_hdl23a(struct rtw_adapter *padapter, unsigned char *pbuf);
+u8 tx_beacon_hdl23a(struct rtw_adapter *padapter, unsigned char *pbuf)=
;
+u8 set_ch_hdl23a(struct rtw_adapter *padapter, u8 *pbuf);
+u8 set_chplan_hdl23a(struct rtw_adapter *padapter, unsigned char *pbuf=
);
+u8 led_blink_hdl23a(struct rtw_adapter *padapter, unsigned char *pbuf)=
;
+u8 set_csa_hdl23a(struct rtw_adapter *padapter, unsigned char *pbuf);	=
/* Kurt: Handling DFS channel switch announcement ie. */
+u8 tdls_hdl23a(struct rtw_adapter *padapter, unsigned char *pbuf);
+
+#define GEN_DRV_CMD_HANDLER(size, cmd)	{size, &cmd ## _hdl23a},
+#define GEN_MLME_EXT_HANDLER(size, cmd)	{size, cmd},
+
+struct C2HEvent_Header {
+#ifdef __LITTLE_ENDIAN
+
+	unsigned int len:16;
+	unsigned int ID:8;
+	unsigned int seq:8;
+
+#elif defined(__BIG_ENDIAN)
+
+	unsigned int seq:8;
+	unsigned int ID:8;
+	unsigned int len:16;
+
+#else
+
+#  error "Must be LITTLE or BIG Endian"
+
+#endif
+
+	unsigned int rsvd;
+};
+
+void rtw_dummy_event_callback23a(struct rtw_adapter *adapter , u8 *pbu=
f);
+void rtw23a_fwdbg_event_callback(struct rtw_adapter *adapter , u8 *pbu=
f);
+
+enum rtw_c2h_event {
+	GEN_EVT_CODE(_Read_MACREG) =3D 0, /*0*/
+	GEN_EVT_CODE(_Read_BBREG),
+	GEN_EVT_CODE(_Read_RFREG),
+	GEN_EVT_CODE(_Read_EEPROM),
+	GEN_EVT_CODE(_Read_EFUSE),
+	GEN_EVT_CODE(_Read_CAM),			/*5*/
+	GEN_EVT_CODE(_Get_BasicRate),
+	GEN_EVT_CODE(_Get_DataRate),
+	GEN_EVT_CODE(_Survey),	 /*8*/
+	GEN_EVT_CODE(_SurveyDone),	 /*9*/
+
+	GEN_EVT_CODE(_JoinBss) , /*10*/
+	GEN_EVT_CODE(_AddSTA),
+	GEN_EVT_CODE(_DelSTA),
+	GEN_EVT_CODE(_AtimDone) ,
+	GEN_EVT_CODE(_TX_Report),
+	GEN_EVT_CODE(_CCX_Report),			/*15*/
+	GEN_EVT_CODE(_DTM_Report),
+	GEN_EVT_CODE(_TX_Rate_Statistics),
+	GEN_EVT_CODE(_C2HLBK),
+	GEN_EVT_CODE(_FWDBG),
+	GEN_EVT_CODE(_C2HFEEDBACK),               /*20*/
+	GEN_EVT_CODE(_ADDBA),
+	GEN_EVT_CODE(_C2HBCN),
+	GEN_EVT_CODE(_ReportPwrState),		/* filen: only for PCIE, USB */
+	GEN_EVT_CODE(_CloseRF),				/* filen: only for PCIE, work around ASPM =
*/
+	MAX_C2HEVT
+};
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtw_p2p.h b/drivers/stag=
ing/rtl8723au/include/rtw_p2p.h
new file mode 100644
index 0000000..93fdc65
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_p2p.h
@@ -0,0 +1,158 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTW_P2P_H_
+#define __RTW_P2P_H_
+
+#include <drv_types.h>
+
+u32 build_beacon_p2p_ie23a(struct wifidirect_info *pwdinfo, u8 *pbuf);
+u32 build_probe_resp_p2p_ie23a(struct wifidirect_info *pwdinfo, u8 *pb=
uf);
+u32 build_prov_disc_request_p2p_ie23a(struct wifidirect_info *pwdinfo,=
 u8 *pbuf,
+				   u8 *pssid, u8 ussidlen, u8 *pdev_raddr);
+u32 build_assoc_resp_p2p_ie23a(struct wifidirect_info *pwdinfo, u8 *pb=
uf,
+			    u8 status_code);
+u32 build_deauth_p2p_ie23a(struct wifidirect_info *pwdinfo, u8 *pbuf);
+#ifdef CONFIG_8723AU_P2P
+u32 build_probe_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf);
+u32 build_probe_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf,
+			    u8 tunneled);
+u32 build_beacon_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf);
+u32 build_nego_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf);
+u32 build_nego_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf);
+u32 build_nego_confirm_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbu=
f);
+u32 build_invitation_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *p=
buf);
+u32 build_invitation_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *=
pbuf);
+u32 build_assoc_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf);
+u32 build_assoc_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbuf)=
;
+u32 build_provdisc_req_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pbu=
f);
+u32 build_provdisc_resp_wfd_ie(struct wifidirect_info *pwdinfo, u8 *pb=
uf);
+#endif /* CONFIG_8723AU_P2P */
+
+u32 process_probe_req_p2p_ie23a(struct wifidirect_info *pwdinfo, u8 *p=
frame,
+			     uint len);
+u32 process_assoc_req_p2p_ie23a(struct wifidirect_info *pwdinfo, u8 *p=
frame,
+			     uint len, struct sta_info *psta);
+u32 process_p2p_devdisc_req23a(struct wifidirect_info *pwdinfo, u8 *pf=
rame,
+			    uint len);
+u32 process_p2p_devdisc_resp23a(struct wifidirect_info *pwdinfo, u8 *p=
frame,
+			     uint len);
+u8 process_p2p_provdisc_req23a(struct wifidirect_info *pwdinfo, u8 *pf=
rame,
+			    uint len);
+u8 process_p2p_provdisc_resp23a(struct wifidirect_info *pwdinfo, u8 *p=
frame);
+u8 process_p2p_group_negotation_req23a(struct wifidirect_info *pwdinfo=
,
+				    u8 *pframe, uint len);
+u8 process_p2p_group_negotation_resp23a(struct wifidirect_info *pwdinf=
o,
+				     u8 *pframe, uint len);
+u8 process_p2p_group_negotation_confirm23a(struct wifidirect_info *pwd=
info,
+					u8 *pframe, uint len);
+u8 process_p2p_presence_req23a(struct wifidirect_info *pwdinfo,
+			    u8 *pframe, uint len);
+
+void p2p_protocol_wk_hdl23a(struct rtw_adapter *padapter, int cmdtype)=
;
+
+#ifdef CONFIG_8723AU_P2P
+void	process_p2p_ps_ie23a(struct rtw_adapter *padapter, u8 *IEs, u32 I=
ELength);
+void	p2p_ps_wk_hdl23a(struct rtw_adapter *padapter, u8 p2p_ps_state);
+u8 p2p_ps_wk_cmd23a(struct rtw_adapter *padapter, u8 p2p_ps_state, u8 =
enqueue);
+#endif /*  CONFIG_8723AU_P2P */
+
+void rtw_init_cfg80211_wifidirect_info(struct rtw_adapter *padapter);
+int rtw_p2p_check_frames(struct rtw_adapter *padapter, const u8 *buf,
+			 u32 len, u8 tx);
+void rtw_append_wfd_ie(struct rtw_adapter *padapter, u8 *buf, u32 *len=
);
+
+void reset_global_wifidirect_info23a(struct rtw_adapter *padapter);
+int rtw_init_wifi_display_info(struct rtw_adapter *padapter);
+void rtw_init_wifidirect_timers23a(struct rtw_adapter *padapter);
+void rtw_init_wifidirect_addrs23a(struct rtw_adapter *padapter, u8 *de=
v_addr,
+			       u8 *iface_addr);
+void init_wifidirect_info23a(struct rtw_adapter *padapter, enum P2P_RO=
LE role);
+int rtw_p2p_enable23a(struct rtw_adapter *padapter, enum P2P_ROLE role=
);
+
+static inline void _rtw_p2p_set_state(struct wifidirect_info *wdinfo,
+				      enum P2P_STATE state)
+{
+	if (wdinfo->p2p_state !=3D state) {
+		/* wdinfo->pre_p2p_state =3D wdinfo->p2p_state; */
+		wdinfo->p2p_state =3D state;
+	}
+}
+
+static inline void _rtw_p2p_set_pre_state(struct wifidirect_info *wdin=
fo,
+					  enum P2P_STATE state)
+{
+	if (wdinfo->pre_p2p_state !=3D state)
+		wdinfo->pre_p2p_state =3D state;
+}
+
+static inline void _rtw_p2p_set_role(struct wifidirect_info *wdinfo,
+				     enum P2P_ROLE role)
+{
+	if (wdinfo->role !=3D role)
+		wdinfo->role =3D role;
+}
+
+static inline int _rtw_p2p_state(struct wifidirect_info *wdinfo)
+{
+	return wdinfo->p2p_state;
+}
+
+static inline int _rtw_p2p_pre_state(struct wifidirect_info *wdinfo)
+{
+	return wdinfo->pre_p2p_state;
+}
+
+static inline int _rtw_p2p_role(struct wifidirect_info *wdinfo)
+{
+	return wdinfo->role;
+}
+
+static inline bool _rtw_p2p_chk_state(struct wifidirect_info *wdinfo,
+				      enum P2P_STATE state)
+{
+	return wdinfo->p2p_state =3D=3D state;
+}
+
+static inline bool _rtw_p2p_chk_role(struct wifidirect_info *wdinfo,
+				     enum P2P_ROLE role)
+{
+	return wdinfo->role =3D=3D role;
+}
+
+#define rtw_p2p_set_state(wdinfo, state) _rtw_p2p_set_state(wdinfo, st=
ate)
+#define rtw_p2p_set_pre_state(wdinfo, state)			\
+	_rtw_p2p_set_pre_state(wdinfo, state)
+#define rtw_p2p_set_role(wdinfo, role) _rtw_p2p_set_role(wdinfo, role)
+
+#define rtw_p2p_state(wdinfo) _rtw_p2p_state(wdinfo)
+#define rtw_p2p_pre_state(wdinfo) _rtw_p2p_pre_state(wdinfo)
+#define rtw_p2p_role(wdinfo) _rtw_p2p_role(wdinfo)
+#define rtw_p2p_chk_state(wdinfo, state) _rtw_p2p_chk_state(wdinfo, st=
ate)
+#define rtw_p2p_chk_role(wdinfo, role) _rtw_p2p_chk_role(wdinfo, role)
+
+#define rtw_p2p_findphase_ex_set(wdinfo, value) \
+	((wdinfo)->find_phase_state_exchange_cnt =3D (value))
+
+/* is this find phase exchange for social channel scan? */
+#define rtw_p2p_findphase_ex_is_social(wdinfo)			\
+	((wdinfo)->find_phase_state_exchange_cnt >=3D		\
+	 P2P_FINDPHASE_EX_SOCIAL_FIRST)
+
+/* should we need find phase exchange anymore? */
+#define rtw_p2p_findphase_ex_is_needed(wdinfo) \
+	((wdinfo)->find_phase_state_exchange_cnt < P2P_FINDPHASE_EX_MAX && \
+	(wdinfo)->find_phase_state_exchange_cnt !=3D P2P_FINDPHASE_EX_NONE)
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtw_pwrctrl.h b/drivers/=
staging/rtl8723au/include/rtw_pwrctrl.h
new file mode 100644
index 0000000..b42e141
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_pwrctrl.h
@@ -0,0 +1,265 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2012 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTW_PWRCTRL_H_
+#define __RTW_PWRCTRL_H_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+#define FW_PWR0		0
+#define FW_PWR1		1
+#define FW_PWR2		2
+#define FW_PWR3		3
+
+
+#define HW_PWR0		7
+#define HW_PWR1		6
+#define HW_PWR2		2
+#define HW_PWR3		0
+#define HW_PWR4		8
+
+#define FW_PWRMSK	0x7
+
+
+#define XMIT_ALIVE	BIT(0)
+#define RECV_ALIVE	BIT(1)
+#define CMD_ALIVE	BIT(2)
+#define EVT_ALIVE	BIT(3)
+
+enum Power_Mgnt {
+	PS_MODE_ACTIVE	=3D 0,
+	PS_MODE_MIN,
+	PS_MODE_MAX,
+	PS_MODE_DTIM,
+	PS_MODE_VOIP,
+	PS_MODE_UAPSD_WMM,
+	PS_MODE_UAPSD,
+	PS_MODE_IBSS,
+	PS_MODE_WWLAN,
+	PM_Radio_Off,
+	PM_Card_Disable,
+	PS_MODE_NUM
+};
+
+
+/* BIT[2:0] =3D HW state
+ * BIT[3] =3D Protocol PS state,  0: active, 1: sleep state
+ * BIT[4] =3D sub-state
+ */
+
+#define PS_DPS			BIT(0)
+#define PS_LCLK			(PS_DPS)
+#define PS_RF_OFF		BIT(1)
+#define PS_ALL_ON		BIT(2)
+#define PS_ST_ACTIVE		BIT(3)
+
+#define PS_ISR_ENABLE		BIT(4)
+#define PS_IMR_ENABLE		BIT(5)
+#define PS_ACK			BIT(6)
+#define PS_TOGGLE		BIT(7)
+
+#define PS_STATE_MASK		(0x0F)
+#define PS_STATE_HW_MASK	(0x07)
+#define PS_SEQ_MASK		(0xc0)
+
+#define PS_STATE(x)		(PS_STATE_MASK & (x))
+#define PS_STATE_HW(x)	(PS_STATE_HW_MASK & (x))
+#define PS_SEQ(x)		(PS_SEQ_MASK & (x))
+
+#define PS_STATE_S0		(PS_DPS)
+#define PS_STATE_S1		(PS_LCLK)
+#define PS_STATE_S2		(PS_RF_OFF)
+#define PS_STATE_S3		(PS_ALL_ON)
+#define PS_STATE_S4		((PS_ST_ACTIVE) | (PS_ALL_ON))
+
+
+#define PS_IS_RF_ON(x)	((x) & (PS_ALL_ON))
+#define PS_IS_ACTIVE(x)	((x) & (PS_ST_ACTIVE))
+#define CLR_PS_STATE(x)	((x) =3D ((x) & (0xF0)))
+
+
+struct reportpwrstate_parm {
+	unsigned char mode;
+	unsigned char state; /* the CPWM value */
+	unsigned short rsvd;
+};
+
+#define LPS_DELAY_TIME	(1*HZ) /*  1 sec */
+
+#define EXE_PWR_NONE		0x01
+#define EXE_PWR_IPS		0x02
+#define EXE_PWR_LPS		0x04
+
+/*  RF state. */
+enum rt_rf_power_state {
+	rf_on,		/*  RF is on after RFSleep or RFOff */
+	rf_sleep,	/*  802.11 Power Save mode */
+	rf_off,		/*  HW/SW Radio OFF or Inactive Power Save */
+	/* Add the new RF state above this line=3D=3D=3D=3D=3D */
+	rf_max
+};
+
+/*  RF Off Level for IPS or HW/SW radio off */
+#define	RT_RF_OFF_LEVL_ASPM		BIT(0)	/*  PCI ASPM */
+#define	RT_RF_OFF_LEVL_CLK_REQ		BIT(1)	/*  PCI clock request */
+#define	RT_RF_OFF_LEVL_PCI_D3		BIT(2)	/*  PCI D3 mode */
+/* NIC halt, re-init hw params */
+#define	RT_RF_OFF_LEVL_HALT_NIC		BIT(3)
+/*  FW free, re-download the FW */
+#define	RT_RF_OFF_LEVL_FREE_FW		BIT(4)
+#define	RT_RF_OFF_LEVL_FW_32K		BIT(5)	/*  FW in 32k */
+/*  Always enable ASPM and Clock Req in initialization. */
+#define	RT_RF_PS_LEVEL_ALWAYS_ASPM	BIT(6)
+/*  When LPS is on, disable 2R if no packet is received or transmittd.=
 */
+#define	RT_RF_LPS_DISALBE_2R		BIT(30)
+#define	RT_RF_LPS_LEVEL_ASPM		BIT(31)	/*  LPS with ASPM */
+
+#define	RT_IN_PS_LEVEL(ppsc, _PS_FLAG)				\
+	((ppsc->cur_ps_level & _PS_FLAG) ? true : false)
+#define	RT_CLEAR_PS_LEVEL(ppsc, _PS_FLAG)			\
+	(ppsc->cur_ps_level &=3D (~(_PS_FLAG)))
+#define	RT_SET_PS_LEVEL(ppsc, _PS_FLAG)				\
+	(ppsc->cur_ps_level |=3D _PS_FLAG)
+
+
+enum {
+	PSBBREG_RF0 =3D 0,
+	PSBBREG_RF1,
+	PSBBREG_RF2,
+	PSBBREG_AFE0,
+	PSBBREG_TOTALCNT
+};
+
+enum { /*  for ips_mode */
+	IPS_NONE =3D 0,
+	IPS_NORMAL,
+	IPS_LEVEL_2,
+};
+
+struct pwrctrl_priv {
+	struct semaphore lock;
+	volatile u8 rpwm; /* requested power state for fw */
+	volatile u8 cpwm; /* fw current power state. updated when 1.
+			   * read from HCPWM 2. driver lowers power level
+			   */
+	volatile u8 tog; /*  toggling */
+	volatile u8 cpwm_tog; /*  toggling */
+
+	u8	pwr_mode;
+	u8	smart_ps;
+	u8	bcn_ant_mode;
+
+	u32	alives;
+	struct work_struct cpwm_event;
+	u8	bpower_saving;
+
+	u8	b_hw_radio_off;
+	u8	reg_rfoff;
+	u8	reg_pdnmode; /* powerdown mode */
+	u32	rfoff_reason;
+
+	/* RF OFF Level */
+	u32	cur_ps_level;
+	u32	reg_rfps_level;
+
+	uint	ips_enter23a_cnts;
+	uint	ips_leave23a_cnts;
+
+	u8	ips_mode;
+	u8	ips_mode_req; /*  used to accept the mode setting request */
+	uint bips_processing;
+	u32 ips_deny_time; /* will deny IPS when system time is smaller */
+	u8 ps_processing; /* used to mark whether in rtw_ps_processor23a */
+
+	u8	bLeisurePs;
+	u8	LpsIdleCount;
+	u8	power_mgnt;
+	u8	bFwCurrentInPSMode;
+	unsigned long	DelayLPSLastTimeStamp;
+	u8	btcoex_rfon;
+	s32		pnp_current_pwr_state;
+	u8		pnp_bstop_trx;
+
+	u8		bInternalAutoSuspend;
+	u8		bInSuspend;
+#ifdef	CONFIG_8723AU_BT_COEXIST
+	u8		bAutoResume;
+	u8		autopm_cnt;
+#endif
+	u8		bSupportRemoteWakeup;
+	struct timer_list	pwr_state_check_timer;
+	int		pwr_state_check_interval;
+	u8		pwr_state_check_cnts;
+
+	int		ps_flag;
+
+	enum rt_rf_power_state	rf_pwrstate;/* cur power state */
+	enum rt_rf_power_state	change_rfpwrstate;
+
+	u8	wepkeymask;
+	u8	bHWPowerdown;/* if support hw power down */
+	u8	bHWPwrPindetect;
+	u8	bkeepfwalive;
+	u8	brfoffbyhw;
+	unsigned long PS_BBRegBackup[PSBBREG_TOTALCNT];
+};
+
+#define rtw_get_ips_mode_req(pwrctrlpriv) \
+	((pwrctrlpriv)->ips_mode_req)
+
+#define rtw_ips_mode_req(pwrctrlpriv, ips_mode) \
+	((pwrctrlpriv)->ips_mode_req =3D (ips_mode))
+
+#define RTW_PWR_STATE_CHK_INTERVAL 2000
+
+#define _rtw_set_pwr_state_check_timer(pwrctrlpriv, ms) \
+	(mod_timer(&pwrctrlpriv->pwr_state_check_timer, jiffies +	\
+		  msecs_to_jiffies(ms)))
+
+#define rtw_set_pwr_state_check_timer(pwrctrlpriv)	\
+	(_rtw_set_pwr_state_check_timer((pwrctrlpriv),	\
+			 (pwrctrlpriv)->pwr_state_check_interval))
+
+void rtw_init_pwrctrl_priv23a(struct rtw_adapter *adapter);
+void rtw_free_pwrctrl_priv(struct rtw_adapter *adapter);
+
+void rtw_set_ps_mode23a(struct rtw_adapter *padapter, u8 ps_mode,
+		     u8 smart_ps, u8 bcn_ant_mode);
+void rtw_set_rpwm23a(struct rtw_adapter *padapter, u8 val8);
+void LeaveAllPowerSaveMode23a(struct rtw_adapter *adapter);
+void ips_enter23a(struct rtw_adapter *padapter);
+int ips_leave23a(struct rtw_adapter *padapter);
+
+void rtw_ps_processor23a(struct rtw_adapter *padapter);
+
+enum rt_rf_power_state RfOnOffDetect23a(struct rtw_adapter *adapter);
+
+s32 LPS_RF_ON_check23a(struct rtw_adapter *padapter, u32 delay_ms);
+void LPS_Enter23a(struct rtw_adapter *padapter);
+void LPS_Leave23a(struct rtw_adapter *padapter);
+
+u8 rtw_interface_ps_func23a(struct rtw_adapter *padapter,
+			 enum hal_intf_ps_func efunc_id, u8 *val);
+void rtw_set_ips_deny23a(struct rtw_adapter *padapter, u32 ms);
+int _rtw_pwr_wakeup23a(struct rtw_adapter *padapter, u32 ips_deffer_ms=
,
+		    const char *caller);
+#define rtw_pwr_wakeup(adapter) _rtw_pwr_wakeup23a(adapter,		\
+	 RTW_PWR_STATE_CHK_INTERVAL, __func__)
+#define rtw_pwr_wakeup_ex(adapter, ips_deffer_ms)			\
+	 _rtw_pwr_wakeup23a(adapter, ips_deffer_ms, __func__)
+int rtw_pm_set_ips23a(struct rtw_adapter *padapter, u8 mode);
+int rtw_pm_set_lps23a(struct rtw_adapter *padapter, u8 mode);
+
+#endif  /* __RTL871X_PWRCTRL_H_ */
diff --git a/drivers/staging/rtl8723au/include/rtw_qos.h b/drivers/stag=
ing/rtl8723au/include/rtw_qos.h
new file mode 100644
index 0000000..68fc5ba
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_qos.h
@@ -0,0 +1,26 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+
+#ifndef _RTW_QOS_H_
+#define _RTW_QOS_H_
+
+#include <osdep_service.h>
+
+struct	qos_priv	{
+	/* bit mask option: u-apsd, s-apsd, ts, block ack... */
+	unsigned int	  qos_option;
+};
+
+#endif	/* _RTL871X_QOS_H_ */
diff --git a/drivers/staging/rtl8723au/include/rtw_recv.h b/drivers/sta=
ging/rtl8723au/include/rtw_recv.h
new file mode 100644
index 0000000..e2462e0
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_recv.h
@@ -0,0 +1,319 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2012 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef _RTW_RECV_H_
+#define _RTW_RECV_H_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+#define NR_RECVFRAME		256
+
+#define MAX_RXFRAME_CNT		512
+#define MAX_RX_NUMBLKS		(32)
+#define RECVFRAME_HDR_ALIGN	128
+
+#define SNAP_SIZE sizeof(struct ieee80211_snap_hdr)
+
+#define MAX_SUBFRAME_COUNT	64
+
+/* for Rx reordering buffer control */
+struct recv_reorder_ctrl {
+	struct rtw_adapter	*padapter;
+	u8 enable;
+	u16 indicate_seq;/* wstart_b, init_value=3D0xffff */
+	u16 wend_b;
+	u8 wsize_b;
+	struct rtw_queue pending_recvframe_queue;
+	struct timer_list reordering_ctrl_timer;
+};
+
+struct	stainfo_rxcache	{
+	u16	tid_rxseq[16];
+/*
+	unsigned short	tid0_rxseq;
+	unsigned short	tid1_rxseq;
+	unsigned short	tid2_rxseq;
+	unsigned short	tid3_rxseq;
+	unsigned short	tid4_rxseq;
+	unsigned short	tid5_rxseq;
+	unsigned short	tid6_rxseq;
+	unsigned short	tid7_rxseq;
+	unsigned short	tid8_rxseq;
+	unsigned short	tid9_rxseq;
+	unsigned short	tid10_rxseq;
+	unsigned short	tid11_rxseq;
+	unsigned short	tid12_rxseq;
+	unsigned short	tid13_rxseq;
+	unsigned short	tid14_rxseq;
+	unsigned short	tid15_rxseq;
+*/
+};
+
+struct smooth_rssi_data {
+	u32	elements[100];	/* array to store values */
+	u32	index;			/* index to current array to store */
+	u32	total_num;		/* num of valid elements */
+	u32	total_val;		/* sum of valid elements */
+};
+
+struct signal_stat {
+	u8	update_req;		/* used to indicate */
+	u8	avg_val;		/* avg of valid elements */
+	u32	total_num;		/* num of valid elements */
+	u32	total_val;		/* sum of valid elements */
+};
+
+#define MAX_PATH_NUM_92CS		2
+
+struct phy_info {
+	u8		RxPWDBAll;
+	u8		SignalQuality;	 /*  in 0-100 index. */
+	u8		RxMIMOSignalQuality[MAX_PATH_NUM_92CS]; /* EVM */
+	u8		RxMIMOSignalStrength[MAX_PATH_NUM_92CS];/* 0~100 */
+	s8		RxPower; /*  in dBm Translate from PWdB */
+	/* Real power in dBm for this packet, no beautification and aggregati=
on.
+	 * Keep this raw info to be used for the other procedures.
+	 */
+	s8		RecvSignalPower;
+	u8		BTRxRSSIPercentage;
+	u8		SignalStrength; /*  in 0-100 index. */
+	u8		RxPwr[MAX_PATH_NUM_92CS];/* per-path's pwdb */
+	u8		RxSNR[MAX_PATH_NUM_92CS];/* per-path's SNR */
+};
+
+
+struct rx_pkt_attrib	{
+	u16	pkt_len;
+	u8	physt;
+	u8	drvinfo_sz;
+	u8	shift_sz;
+	u8	hdrlen; /* the WLAN Header Len */
+	u8	to_fr_ds;
+	u8	amsdu;
+	u8	qos;
+	u8	priority;
+	u8	pw_save;
+	u8	mdata;
+	u16	seq_num;
+	u8	frag_num;
+	u8	mfrag;
+	u8	order;
+	u8	privacy; /* in frame_ctrl field */
+	u8	bdecrypted;
+	/* when 0 indicate no encrypt. when non-zero, indicate the algorith *=
/
+	u8	encrypt;
+	u8	iv_len;
+	u8	icv_len;
+	u8	crc_err;
+	u8	icv_err;
+
+	u16 eth_type;
+
+	u8	dst[ETH_ALEN];
+	u8	src[ETH_ALEN];
+	u8	ta[ETH_ALEN];
+	u8	ra[ETH_ALEN];
+	u8	bssid[ETH_ALEN];
+
+	u8 ack_policy;
+
+	u8	tcpchk_valid; /*  0: invalid, 1: valid */
+	u8	ip_chkrpt; /* 0: incorrect, 1: correct */
+	u8	tcp_chkrpt; /* 0: incorrect, 1: correct */
+	u8	key_index;
+
+	u8	mcs_rate;
+	u8	rxht;
+	u8	sgi;
+	u8	pkt_rpt_type;
+	u32	MacIDValidEntry[2];	/*  64 bits present 64 entry. */
+	struct phy_info phy_info;
+};
+
+/* These definition is used for Rx packet reordering. */
+#define SN_LESS(a, b)		(((a-b) & 0x800) !=3D 0)
+#define SN_EQUAL(a, b)		(a =3D=3D b)
+#define REORDER_WAIT_TIME	(50) /*  (ms) */
+
+#define RECVBUFF_ALIGN_SZ 8
+
+#define RXDESC_SIZE	24
+#define RXDESC_OFFSET RXDESC_SIZE
+
+struct recv_stat {
+	unsigned int rxdw0;
+	unsigned int rxdw1;
+	unsigned int rxdw2;
+	unsigned int rxdw3;
+	unsigned int rxdw4;
+	unsigned int rxdw5;
+};
+
+/* accesser of recv_priv: rtw_recv_entry23a(dispatch / passive level);=
	\
+ * recv_thread(passive) ; returnpkt(dispatch) ; halt(passive) ;
+ *
+ * using enter_critical section to protect
+ */
+struct recv_priv {
+	spinlock_t	lock;
+
+	struct rtw_queue	free_recv_queue;
+	struct rtw_queue	recv_pending_queue;
+	struct rtw_queue	uc_swdec_pending_queue;
+
+	void *pallocated_frame_buf;
+
+	uint free_recvframe_cnt;
+
+	struct rtw_adapter	*adapter;
+
+	u32	bIsAnyNonBEPkts;
+	u64	rx_bytes;
+	u64	rx_pkts;
+	u64	rx_drop;
+	u64	last_rx_bytes;
+
+	uint  rx_icv_err;
+	uint  rx_largepacket_crcerr;
+	uint  rx_smallpacket_crcerr;
+	uint  rx_middlepacket_crcerr;
+
+	/* u8 *pallocated_urb_buf; */
+	struct semaphore allrxreturnevt;
+	uint	ff_hwaddr;
+	u8	rx_pending_cnt;
+
+	struct urb *int_in_urb;
+
+	u8	*int_in_buf;
+
+	struct tasklet_struct irq_prepare_beacon_tasklet;
+	struct tasklet_struct recv_tasklet;
+	struct sk_buff_head free_recv_skb_queue;
+	struct sk_buff_head rx_skb_queue;
+	u8 *precv_buf;
+	struct rtw_queue	free_recv_buf_queue;
+	u32	free_recv_buf_queue_cnt;
+
+	/* For display the phy informatiom */
+	u8 is_signal_dbg;	/*  for debug */
+	u8 signal_strength_dbg;	/*  for debug */
+	s8 rssi;
+	s8 rxpwdb;
+	u8 signal_strength;
+	u8 signal_qual;
+	u8 noise;
+	int RxSNRdB[2];
+	s8 RxRssi[2];
+	int FalseAlmCnt_all;
+
+	struct timer_list signal_stat_timer;
+	u32 signal_stat_sampling_interval;
+	/* u32 signal_stat_converging_constant; */
+	struct signal_stat signal_qual_data;
+	struct signal_stat signal_strength_data;
+};
+
+#define rtw_set_signal_stat_timer(recvpriv)			\
+	 mod_timer(&(recvpriv)->signal_stat_timer, jiffies +	\
+		   msecs_to_jiffies((recvpriv)->signal_stat_sampling_interval))
+
+struct sta_recv_priv {
+	spinlock_t	lock;
+	int	option;
+
+	/* struct rtw_queue	blk_strms[MAX_RX_NUMBLKS]; */
+	struct rtw_queue defrag_q;	 /* keeping the fragment frame until defra=
g */
+
+	struct	stainfo_rxcache rxcache;
+
+	/* uint	sta_rx_bytes; */
+	/* uint	sta_rx_pkts; */
+	/* uint	sta_rx_fail; */
+
+};
+
+
+struct recv_buf {
+	struct list_head list;
+
+	struct rtw_adapter *adapter;
+
+	struct urb *purb;
+	struct sk_buff *pskb;
+};
+
+/*	head  ----->
+ *
+ *		data  ----->
+ *
+ *			payload
+ *
+ *		tail  ----->
+ *
+ *	end   ----->
+ *
+ *	len =3D (unsigned int )(tail - data);
+ *
+ */
+struct recv_frame {
+	struct list_head	list;
+	struct sk_buff *pkt;
+
+	struct rtw_adapter  *adapter;
+
+	struct rx_pkt_attrib attrib;
+
+	struct sta_info *psta;
+
+	/* for A-MPDU Rx reordering buffer control */
+	struct recv_reorder_ctrl *preorder_ctrl;
+};
+
+/* get a free recv_frame from pfree_recv_queue */
+struct recv_frame *rtw_alloc_recvframe23a(struct rtw_queue *pfree_recv=
_queue);
+int rtw_free_recvframe23a(struct recv_frame *precvframe, struct rtw_qu=
eue *pfree_recv_queue);
+
+int rtw_enqueue_recvframe23a(struct recv_frame *precvframe, struct rtw=
_queue *queue);
+
+void rtw_free_recvframe23a_queue(struct rtw_queue *pframequeue, struct=
 rtw_queue *pfree_recv_queue);
+u32 rtw_free_uc_swdec_pending_queue23a(struct rtw_adapter *adapter);
+
+int rtw_enqueue_recvbuf23a_to_head(struct recv_buf *precvbuf, struct r=
tw_queue *queue);
+int rtw_enqueue_recvbuf23a(struct recv_buf *precvbuf, struct rtw_queue=
 *queue);
+struct recv_buf *rtw_dequeue_recvbuf23a(struct rtw_queue *queue);
+
+void rtw_reordering_ctrl_timeout_handler23a(unsigned long pcontext);
+
+static inline s32 translate_percentage_to_dbm(u32 SignalStrengthIndex)
+{
+	s32	SignalPower; /*  in dBm. */
+
+	/*  Translate to dBm (x=3D0.5y-95). */
+	SignalPower =3D (s32)((SignalStrengthIndex + 1) >> 1);
+	SignalPower -=3D 95;
+
+	return SignalPower;
+}
+
+
+struct sta_info;
+
+void _rtw_init_sta_recv_priv23a(struct sta_recv_priv *psta_recvpriv);
+
+void mgt_dispatcher23a(struct rtw_adapter *padapter,
+		    struct recv_frame *precv_frame);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtw_rf.h b/drivers/stagi=
ng/rtl8723au/include/rtw_rf.h
new file mode 100644
index 0000000..91a0a22
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_rf.h
@@ -0,0 +1,113 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef	__RTW_RF_H_
+#define __RTW_RF_H_
+
+#include <rtw_cmd.h>
+
+#define OFDM_PHY		1
+#define MIXED_PHY		2
+#define CCK_PHY			3
+
+#define NumRates		(13)
+
+/*  slot time for 11g */
+#define SHORT_SLOT_TIME			9
+#define NON_SHORT_SLOT_TIME		20
+
+/*  We now define the max channels in each channel plan. */
+#define	MAX_CHANNEL_NUM_2G	14
+#define	MAX_CHANNEL_NUM_5G	24
+#define	MAX_CHANNEL_NUM		38/* 14+24 */
+
+/* define NUM_REGULATORYS	21 */
+#define NUM_REGULATORYS	1
+
+/* Country codes */
+#define USA		0x555320
+#define EUROPE		0x1 /* temp, should be provided later */
+#define JAPAN		0x2 /* temp, should be provided later */
+
+struct	regulatory_class {
+	u32	starting_freq;					/* MHz, */
+	u8	channel_set[MAX_CHANNEL_NUM];
+	u8	channel_cck_power[MAX_CHANNEL_NUM];/* dbm */
+	u8	channel_ofdm_power[MAX_CHANNEL_NUM];/* dbm */
+	u8	txpower_limit;					/* dbm */
+	u8	channel_spacing;				/* MHz */
+	u8	modem;
+};
+
+enum {
+	cESS		=3D 0x0001,
+	cIBSS		=3D 0x0002,
+	cPollable	=3D 0x0004,
+	cPollReq	=3D 0x0008,
+	cPrivacy	=3D 0x0010,
+	cShortPreamble	=3D 0x0020,
+	cPBCC		=3D 0x0040,
+	cChannelAgility	=3D 0x0080,
+	cSpectrumMgnt	=3D 0x0100,
+	cQos		=3D 0x0200,	/*  For HCCA, use with CF-Pollable and CF-PollReq *=
/
+	cShortSlotTime	=3D 0x0400,
+	cAPSD		=3D 0x0800,
+	cRM		=3D 0x1000,	/*  RRM (Radio Request Measurement) */
+	cDSSS_OFDM	=3D 0x2000,
+	cDelayedBA	=3D 0x4000,
+	cImmediateBA	=3D 0x8000,
+};
+
+enum {
+	PREAMBLE_LONG	=3D 1,
+	PREAMBLE_AUTO	=3D 2,
+	PREAMBLE_SHORT	=3D 3,
+};
+
+/*  Bandwidth Offset */
+#define HAL_PRIME_CHNL_OFFSET_DONT_CARE	0
+#define HAL_PRIME_CHNL_OFFSET_LOWER	1
+#define HAL_PRIME_CHNL_OFFSET_UPPER	2
+
+/*  Represent Channel Width in HT Capabilities */
+enum ht_channel_width {
+	HT_CHANNEL_WIDTH_20 =3D 0,
+	HT_CHANNEL_WIDTH_40 =3D 1,
+	HT_CHANNEL_WIDTH_80 =3D 2,
+	HT_CHANNEL_WIDTH_160 =3D 3,
+	HT_CHANNEL_WIDTH_10 =3D 4,
+};
+
+/*  */
+/*  Represent Extention Channel Offset in HT Capabilities */
+/*  This is available only in 40Mhz mode. */
+/*  */
+enum {
+	HT_EXTCHNL_OFFSET_NO_EXT =3D 0,
+	HT_EXTCHNL_OFFSET_UPPER =3D 1,
+	HT_EXTCHNL_OFFSET_NO_DEF =3D 2,
+	HT_EXTCHNL_OFFSET_LOWER =3D 3,
+};
+
+/* 2007/11/15 MH Define different RF type. */
+enum {
+	RF_1T2R =3D 0,
+	RF_2T4R =3D 1,
+	RF_2T2R =3D 2,
+	RF_1T1R =3D 3,
+	RF_2T2R_GREEN =3D 4,
+	RF_819X_MAX_TYPE =3D 5,
+};
+
+#endif /* _RTL8711_RF_H_ */
diff --git a/drivers/staging/rtl8723au/include/rtw_security.h b/drivers=
/staging/rtl8723au/include/rtw_security.h
new file mode 100644
index 0000000..75bbb93
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_security.h
@@ -0,0 +1,357 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __RTW_SECURITY_H_
+#define __RTW_SECURITY_H_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+
+#define _NO_PRIVACY_		0x0
+#define _WEP40_			0x1
+#define _TKIP_			0x2
+#define _TKIP_WTMIC_		0x3
+#define _AES_			0x4
+#define _WEP104_		0x5
+#define _WEP_WPA_MIXED_	0x07  /*  WEP + WPA */
+#define _SMS4_			0x06
+
+#define is_wep_enc(alg) (((alg) =3D=3D _WEP40_) || ((alg) =3D=3D _WEP1=
04_))
+
+#define _WPA_IE_ID_	0xdd
+#define _WPA2_IE_ID_	0x30
+
+#define SHA256_MAC_LEN 32
+#define AES_BLOCK_SIZE 16
+#define AES_PRIV_SIZE (4 * 44)
+
+enum ENCRYP_PROTOCOL {
+	ENCRYP_PROTOCOL_OPENSYS,   /* open system */
+	ENCRYP_PROTOCOL_WEP,       /* WEP */
+	ENCRYP_PROTOCOL_WPA,       /* WPA */
+	ENCRYP_PROTOCOL_WPA2,      /* WPA2 */
+	ENCRYP_PROTOCOL_MAX
+};
+
+#ifndef Ndis802_11AuthModeWPA2
+#define Ndis802_11AuthModeWPA2 (Ndis802_11AuthModeWPANone + 1)
+#endif
+
+#ifndef Ndis802_11AuthModeWPA2PSK
+#define Ndis802_11AuthModeWPA2PSK (Ndis802_11AuthModeWPANone + 2)
+#endif
+
+union pn48 {
+	u64	val;
+
+#ifdef __LITTLE_ENDIAN
+
+struct {
+	u8 TSC0;
+	u8 TSC1;
+	u8 TSC2;
+	u8 TSC3;
+	u8 TSC4;
+	u8 TSC5;
+	u8 TSC6;
+	u8 TSC7;
+} _byte_;
+
+#elif defined(__BIG_ENDIAN)
+
+struct {
+	u8 TSC7;
+	u8 TSC6;
+	u8 TSC5;
+	u8 TSC4;
+	u8 TSC3;
+	u8 TSC2;
+	u8 TSC1;
+	u8 TSC0;
+} _byte_;
+#else
+#error Need BIG or LITTLE endian
+
+#endif
+
+};
+
+union Keytype {
+	u8   skey[16];
+	u32    lkey[4];
+};
+
+
+struct rt_pmkid_list {
+	u8	bUsed;
+	u8	Bssid[6];
+	u8	PMKID[16];
+	u8	SsidBuf[33];
+	u8	*ssid_octet;
+	u16	ssid_length;
+};
+
+struct security_priv {
+	u32	  dot11AuthAlgrthm;	/*  802.11 auth, could be open, shared,
+					 * 8021x and authswitch */
+	u32	  dot11PrivacyAlgrthm;	/* This specifies the privacy for
+					 * shared auth. algorithm.
+					 */
+	/* WEP */
+	u32	  dot11PrivacyKeyIndex;	/*  this is only valid for legendary
+					 * wep, 0~3 for key id. (tx key index)
+					 */
+	union Keytype dot11DefKey[4];	/*  this is only valid for def. key */
+	u32	dot11DefKeylen[4];
+
+	u32 dot118021XGrpPrivacy;	/* specify the privacy algthm.
+					 * used for Grp key
+					 */
+	u32	dot118021XGrpKeyid;	/*  key id used for Grp Key
+					 * (tx key index)
+					 */
+	union Keytype	dot118021XGrpKey[4];/* 802.1x Grp Key, inx0 and inx1 */
+	union Keytype	dot118021XGrptxmickey[4];
+	union Keytype	dot118021XGrprxmickey[4];
+	union pn48	dot11Grptxpn;		/* PN48 used for Grp Key xmit.*/
+	union pn48	dot11Grprxpn;		/* PN48 used for Grp Key recv.*/
+
+#ifdef CONFIG_8723AU_AP_MODE
+	/* extend security capabilities for AP_MODE */
+	unsigned int dot8021xalg;/* 0:disable, 1:psk, 2:802.1x */
+	unsigned int wpa_psk;/* 0:disable, bit(0): WPA, bit(1):WPA2 */
+	unsigned int wpa_group_cipher;
+	unsigned int wpa2_group_cipher;
+	unsigned int wpa_pairwise_cipher;
+	unsigned int wpa2_pairwise_cipher;
+#endif
+
+	u8 wps_ie[MAX_WPS_IE_LEN];/* added in assoc req */
+	int wps_ie_len;
+	u8	binstallGrpkey;
+	u8	busetkipkey;
+	u8	bcheck_grpkey;
+	u8	bgrpkey_handshake;
+	s32	hw_decrypted;
+	u32 ndisauthtype;	/*  enum ndis_802_11_auth_mode */
+	u32 ndisencryptstatus;	/*  NDIS_802_11_ENCRYPTION_STATUS */
+	struct wlan_bssid_ex sec_bss;  /* for joinbss (h2c buffer) usage */
+	struct ndis_802_11_wep ndiswep;
+	u8 assoc_info[600];
+	u8 szofcapability[256]; /* for wpa2 usage */
+	u8 oidassociation[512]; /* for wpa/wpa2 usage */
+	u8 authenticator_ie[256];  /* store ap security information element *=
/
+	u8 supplicant_ie[256];  /* store sta security information element */
+
+	/* for tkip countermeasure */
+	unsigned long last_mic_err_time;
+	u8	btkip_countermeasure;
+	u8	btkip_wait_report;
+	unsigned long btkip_countermeasure_time;
+
+	/*  For WPA2 Pre-Authentication. */
+	struct rt_pmkid_list PMKIDList[NUM_PMKID_CACHE];
+	u8 PMKIDIndex;
+	u8 bWepDefaultKeyIdxSet;
+};
+
+struct sha256_state {
+	u64 length;
+	u32 state[8], curlen;
+	u8 buf[64];
+};
+
+#define GET_ENCRY_ALGO(psecuritypriv, psta, encry_algo, bmcst)\
+do {\
+	switch (psecuritypriv->dot11AuthAlgrthm) {\
+	case dot11AuthAlgrthm_Open:\
+	case dot11AuthAlgrthm_Shared:\
+	case dot11AuthAlgrthm_Auto:\
+		encry_algo =3D (u8)psecuritypriv->dot11PrivacyAlgrthm;\
+		break;\
+	case dot11AuthAlgrthm_8021X:\
+		if (bmcst)\
+			encry_algo =3D (u8)psecuritypriv->dot118021XGrpPrivacy;\
+		else\
+			encry_algo =3D (u8)psta->dot118021XPrivacy;\
+		break;\
+	}	\
+} while (0)
+
+#define GET_TKIP_PN(iv, dot11txpn)\
+do {\
+	dot11txpn._byte_.TSC0 =3D iv[2];\
+	dot11txpn._byte_.TSC1 =3D iv[0];\
+	dot11txpn._byte_.TSC2 =3D iv[4];\
+	dot11txpn._byte_.TSC3 =3D iv[5];\
+	dot11txpn._byte_.TSC4 =3D iv[6];\
+	dot11txpn._byte_.TSC5 =3D iv[7];\
+} while (0)
+
+#define ROL32(A, n)  (((A) << (n)) | (((A)>>(32-(n)))  & ((1UL << (n))=
 - 1)))
+#define ROR32(A, n)  ROL32((A), 32-(n))
+
+struct mic_data {
+	u32  K0, K1;         /*  Key */
+	u32  L, R;           /*  Current state */
+	u32  M;              /*  Message accumulator (single word) */
+	u32     nBytesInM;      /*  # bytes in M */
+};
+
+extern const u32 Te0[256];
+extern const u32 Te1[256];
+extern const u32 Te2[256];
+extern const u32 Te3[256];
+extern const u32 Te4[256];
+extern const u32 Td0[256];
+extern const u32 Td1[256];
+extern const u32 Td2[256];
+extern const u32 Td3[256];
+extern const u32 Td4[256];
+extern const u32 rcon[10];
+extern const u8 Td4s[256];
+extern const u8 rcons[10];
+
+#define RCON(i) (rcons[(i)] << 24)
+
+static inline u32 rotr(u32 val, int bits)
+{
+	return (val >> bits) | (val << (32 - bits));
+}
+
+#define TE0(i) Te0[((i) >> 24) & 0xff]
+#define TE1(i) rotr(Te0[((i) >> 16) & 0xff], 8)
+#define TE2(i) rotr(Te0[((i) >> 8) & 0xff], 16)
+#define TE3(i) rotr(Te0[(i) & 0xff], 24)
+#define TE41(i) ((Te0[((i) >> 24) & 0xff] << 8) & 0xff000000)
+#define TE42(i) (Te0[((i) >> 16) & 0xff] & 0x00ff0000)
+#define TE43(i) (Te0[((i) >> 8) & 0xff] & 0x0000ff00)
+#define TE44(i) ((Te0[(i) & 0xff] >> 8) & 0x000000ff)
+#define TE421(i) ((Te0[((i) >> 16) & 0xff] << 8) & 0xff000000)
+#define TE432(i) (Te0[((i) >> 8) & 0xff] & 0x00ff0000)
+#define TE443(i) (Te0[(i) & 0xff] & 0x0000ff00)
+#define TE414(i) ((Te0[((i) >> 24) & 0xff] >> 8) & 0x000000ff)
+#define TE4(i) ((Te0[(i)] >> 8) & 0x000000ff)
+
+#define TD0(i) Td0[((i) >> 24) & 0xff]
+#define TD1(i) rotr(Td0[((i) >> 16) & 0xff], 8)
+#define TD2(i) rotr(Td0[((i) >> 8) & 0xff], 16)
+#define TD3(i) rotr(Td0[(i) & 0xff], 24)
+#define TD41(i) (Td4s[((i) >> 24) & 0xff] << 24)
+#define TD42(i) (Td4s[((i) >> 16) & 0xff] << 16)
+#define TD43(i) (Td4s[((i) >> 8) & 0xff] << 8)
+#define TD44(i) (Td4s[(i) & 0xff])
+#define TD0_(i) Td0[(i) & 0xff]
+#define TD1_(i) rotr(Td0[(i) & 0xff], 8)
+#define TD2_(i) rotr(Td0[(i) & 0xff], 16)
+#define TD3_(i) rotr(Td0[(i) & 0xff], 24)
+
+#define GETU32(pt) (((u32)(pt)[0] << 24) ^ ((u32)(pt)[1] << 16) ^ \
+			((u32)(pt)[2] <<  8) ^ ((u32)(pt)[3]))
+
+#define PUTU32(ct, st) { \
+(ct)[0] =3D (u8)((st) >> 24); (ct)[1] =3D (u8)((st) >> 16); \
+(ct)[2] =3D (u8)((st) >>  8); (ct)[3] =3D (u8)(st); }
+
+#define WPA_GET_BE32(a) ((((u32) (a)[0]) << 24) | (((u32) (a)[1]) << 1=
6) | \
+			 (((u32) (a)[2]) << 8) | ((u32) (a)[3]))
+
+#define WPA_PUT_LE16(a, val)			\
+	do {					\
+		(a)[1] =3D ((u16) (val)) >> 8;	\
+		(a)[0] =3D ((u16) (val)) & 0xff;	\
+	} while (0)
+
+#define WPA_PUT_BE32(a, val)					\
+	do {							\
+		(a)[0] =3D (u8) ((((u32) (val)) >> 24) & 0xff);	\
+		(a)[1] =3D (u8) ((((u32) (val)) >> 16) & 0xff);	\
+		(a)[2] =3D (u8) ((((u32) (val)) >> 8) & 0xff);	\
+		(a)[3] =3D (u8) (((u32) (val)) & 0xff);		\
+	} while (0)
+
+#define WPA_PUT_BE64(a, val)				\
+	do {						\
+		(a)[0] =3D (u8) (((u64) (val)) >> 56);	\
+		(a)[1] =3D (u8) (((u64) (val)) >> 48);	\
+		(a)[2] =3D (u8) (((u64) (val)) >> 40);	\
+		(a)[3] =3D (u8) (((u64) (val)) >> 32);	\
+		(a)[4] =3D (u8) (((u64) (val)) >> 24);	\
+		(a)[5] =3D (u8) (((u64) (val)) >> 16);	\
+		(a)[6] =3D (u8) (((u64) (val)) >> 8);	\
+		(a)[7] =3D (u8) (((u64) (val)) & 0xff);	\
+	} while (0)
+
+/* =3D=3D=3D=3D=3D start - public domain SHA256 implementation =3D=3D=3D=
=3D=3D */
+
+/* This is based on SHA256 implementation in LibTomCrypt that was rele=
ased into
+ * public domain by Tom St Denis. */
+
+/* the K array */
+static const unsigned long K[64] =3D {
+	0x428a2f98UL, 0x71374491UL, 0xb5c0fbcfUL, 0xe9b5dba5UL, 0x3956c25bUL,
+	0x59f111f1UL, 0x923f82a4UL, 0xab1c5ed5UL, 0xd807aa98UL, 0x12835b01UL,
+	0x243185beUL, 0x550c7dc3UL, 0x72be5d74UL, 0x80deb1feUL, 0x9bdc06a7UL,
+	0xc19bf174UL, 0xe49b69c1UL, 0xefbe4786UL, 0x0fc19dc6UL, 0x240ca1ccUL,
+	0x2de92c6fUL, 0x4a7484aaUL, 0x5cb0a9dcUL, 0x76f988daUL, 0x983e5152UL,
+	0xa831c66dUL, 0xb00327c8UL, 0xbf597fc7UL, 0xc6e00bf3UL, 0xd5a79147UL,
+	0x06ca6351UL, 0x14292967UL, 0x27b70a85UL, 0x2e1b2138UL, 0x4d2c6dfcUL,
+	0x53380d13UL, 0x650a7354UL, 0x766a0abbUL, 0x81c2c92eUL, 0x92722c85UL,
+	0xa2bfe8a1UL, 0xa81a664bUL, 0xc24b8b70UL, 0xc76c51a3UL, 0xd192e819UL,
+	0xd6990624UL, 0xf40e3585UL, 0x106aa070UL, 0x19a4c116UL, 0x1e376c08UL,
+	0x2748774cUL, 0x34b0bcb5UL, 0x391c0cb3UL, 0x4ed8aa4aUL, 0x5b9cca4fUL,
+	0x682e6ff3UL, 0x748f82eeUL, 0x78a5636fUL, 0x84c87814UL, 0x8cc70208UL,
+	0x90befffaUL, 0xa4506cebUL, 0xbef9a3f7UL, 0xc67178f2UL
+};
+
+/* Various logical functions */
+#define RORc(x, y) \
+(((((unsigned long)(x) & 0xFFFFFFFFUL) >> (unsigned long) ((y) & 31)) =
| \
+((unsigned long)(x) << (unsigned long) (32 - ((y) & 31)))) & 0xFFFFFFF=
=46UL)
+#define Ch(x, y, z)     (z ^ (x & (y ^ z)))
+#define Maj(x, y, z)    (((x | y) & z) | (x & y))
+#define S(x, n)         RORc((x), (n))
+#define R(x, n)         (((x)&0xFFFFFFFFUL)>>(n))
+#define Sigma0(x)       (S(x, 2) ^ S(x, 13) ^ S(x, 22))
+#define Sigma1(x)       (S(x, 6) ^ S(x, 11) ^ S(x, 25))
+#define Gamma0(x)       (S(x, 7) ^ S(x, 18) ^ R(x, 3))
+#define Gamma1(x)       (S(x, 17) ^ S(x, 19) ^ R(x, 10))
+#ifndef MIN
+#define MIN(x, y) (((x) < (y)) ? (x) : (y))
+#endif
+
+void rtw_secmicsetkey23a(struct mic_data *pmicdata, u8 *key);
+void rtw_secmicappend23abyte23a(struct mic_data *pmicdata, u8 b);
+void rtw_secmicappend23a(struct mic_data *pmicdata, u8 *src, u32 nbByt=
es);
+void rtw_secgetmic23a(struct mic_data *pmicdata, u8 *dst);
+
+void rtw_seccalctkipmic23a(u8 *key, u8 *header, u8 *data, u32 data_len=
,
+			u8 *Miccode, u8 priorityi);
+
+u32 rtw_aes_encrypt23a(struct rtw_adapter *padapter,
+		    struct xmit_frame *pxmitframe);
+u32 rtw_tkip_encrypt23a(struct rtw_adapter *padapter,
+		     struct xmit_frame *pxmitframe);
+void rtw_wep_encrypt23a(struct rtw_adapter *padapter,
+		     struct xmit_frame *pxmitframe);
+u32 rtw_aes_decrypt23a(struct rtw_adapter *padapter,
+		    struct recv_frame *precvframe);
+u32 rtw_tkip_decrypt23a(struct rtw_adapter *padapter,
+		     struct recv_frame *precvframe);
+void rtw_wep_decrypt23a(struct rtw_adapter *padapter, struct recv_fram=
e *precvframe);
+
+void rtw_use_tkipkey_handler23a(void *FunctionContext);
+
+#endif	/* __RTL871X_SECURITY_H_ */
diff --git a/drivers/staging/rtl8723au/include/rtw_sreset.h b/drivers/s=
taging/rtl8723au/include/rtw_sreset.h
new file mode 100644
index 0000000..4c52372
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_sreset.h
@@ -0,0 +1,56 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2012 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef _RTW_SRESET_C_
+#define _RTW_SRESET_C_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+enum {
+	SRESET_TGP_NULL =3D 0,
+	SRESET_TGP_XMIT_STATUS =3D 1,
+	SRESET_TGP_LINK_STATUS =3D 2,
+};
+
+struct sreset_priv {
+	struct mutex	silentreset_mutex;
+	u8	silent_reset_inprogress;
+	u8	Wifi_Error_Status;
+	unsigned long last_tx_time;
+	unsigned long last_tx_complete_time;
+
+	s32 dbg_trigger_point;
+};
+
+#include <rtl8723a_hal.h>
+
+#define	WIFI_STATUS_SUCCESS		0
+#define	USB_VEN_REQ_CMD_FAIL	BIT0
+#define	USB_READ_PORT_FAIL		BIT1
+#define	USB_WRITE_PORT_FAIL		BIT2
+#define	WIFI_MAC_TXDMA_ERROR	BIT3
+#define   WIFI_TX_HANG				BIT4
+#define	WIFI_RX_HANG				BIT5
+#define		WIFI_IF_NOT_EXIST			BIT6
+
+void sreset_init_value23a(struct rtw_adapter *padapter);
+void sreset_reset_value23a(struct rtw_adapter *padapter);
+u8 sreset_get_wifi_status23a(struct rtw_adapter *padapter);
+void sreset_set_wifi_error_status23a(struct rtw_adapter *padapter, u32=
 status);
+void sreset_set_trigger_point(struct rtw_adapter *padapter, s32 tgp);
+bool sreset_inprogress(struct rtw_adapter *padapter);
+void sreset_reset(struct rtw_adapter *padapter);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/rtw_version.h b/drivers/=
staging/rtl8723au/include/rtw_version.h
new file mode 100644
index 0000000..c947733
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_version.h
@@ -0,0 +1 @@
+#define DRIVERVERSION	"v4.1.6_7336.20130426"
diff --git a/drivers/staging/rtl8723au/include/rtw_xmit.h b/drivers/sta=
ging/rtl8723au/include/rtw_xmit.h
new file mode 100644
index 0000000..65a33a0
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/rtw_xmit.h
@@ -0,0 +1,407 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef _RTW_XMIT_H_
+#define _RTW_XMIT_H_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+#define MAX_XMITBUF_SZ		2048
+#define NR_XMITBUFF		4
+
+#define XMITBUF_ALIGN_SZ	512
+
+/*  xmit extension buff defination */
+#define MAX_XMIT_EXTBUF_SZ	1536
+#define NR_XMIT_EXTBUFF		32
+
+#define MAX_NUMBLKS		1
+
+#define XMIT_VO_QUEUE		0
+#define XMIT_VI_QUEUE		1
+#define XMIT_BE_QUEUE		2
+#define XMIT_BK_QUEUE		3
+
+#define VO_QUEUE_INX		0
+#define VI_QUEUE_INX		1
+#define BE_QUEUE_INX		2
+#define BK_QUEUE_INX		3
+#define BCN_QUEUE_INX		4
+#define MGT_QUEUE_INX		5
+#define HIGH_QUEUE_INX		6
+#define TXCMD_QUEUE_INX		7
+
+#define HW_QUEUE_ENTRY		8
+
+#define WEP_IV(pattrib_iv, dot11txpn, keyidx)				\
+do {									\
+	pattrib_iv[0] =3D dot11txpn._byte_.TSC0;				\
+	pattrib_iv[1] =3D dot11txpn._byte_.TSC1;				\
+	pattrib_iv[2] =3D dot11txpn._byte_.TSC2;				\
+	pattrib_iv[3] =3D ((keyidx & 0x3) << 6);				\
+	dot11txpn.val =3D (dot11txpn.val =3D=3D 0xffffff) ? 0 :		\
+			 (dot11txpn.val+1);				\
+} while (0)
+
+#define TKIP_IV(pattrib_iv, dot11txpn, keyidx)				\
+do {									\
+	pattrib_iv[0] =3D dot11txpn._byte_.TSC1;				\
+	pattrib_iv[1] =3D (dot11txpn._byte_.TSC1 | 0x20) & 0x7f;		\
+	pattrib_iv[2] =3D dot11txpn._byte_.TSC0;				\
+	pattrib_iv[3] =3D BIT(5) | ((keyidx & 0x3)<<6);			\
+	pattrib_iv[4] =3D dot11txpn._byte_.TSC2;				\
+	pattrib_iv[5] =3D dot11txpn._byte_.TSC3;				\
+	pattrib_iv[6] =3D dot11txpn._byte_.TSC4;				\
+	pattrib_iv[7] =3D dot11txpn._byte_.TSC5;				\
+	dot11txpn.val =3D dot11txpn.val =3D=3D 0xffffffffffffULL ? 0 :	\
+					 (dot11txpn.val+1);		\
+} while (0)
+
+#define AES_IV(pattrib_iv, dot11txpn, keyidx)\
+do {									\
+	pattrib_iv[0] =3D dot11txpn._byte_.TSC0;				\
+	pattrib_iv[1] =3D dot11txpn._byte_.TSC1;				\
+	pattrib_iv[2] =3D 0;						\
+	pattrib_iv[3] =3D BIT(5) | ((keyidx & 0x3) << 6);			\
+	pattrib_iv[4] =3D dot11txpn._byte_.TSC2;				\
+	pattrib_iv[5] =3D dot11txpn._byte_.TSC3;				\
+	pattrib_iv[6] =3D dot11txpn._byte_.TSC4;				\
+	pattrib_iv[7] =3D dot11txpn._byte_.TSC5;				\
+	dot11txpn.val =3D dot11txpn.val =3D=3D 0xffffffffffffULL ? 0 :	\
+					 (dot11txpn.val+1);		\
+} while (0)
+
+#define HWXMIT_ENTRY	4
+
+#define TXDESC_SIZE 32
+
+#define PACKET_OFFSET_SZ 8
+#define TXDESC_OFFSET (TXDESC_SIZE + PACKET_OFFSET_SZ)
+
+struct tx_desc {
+	/* DWORD 0 */
+	unsigned int txdw0;
+	unsigned int txdw1;
+	unsigned int txdw2;
+	unsigned int txdw3;
+	unsigned int txdw4;
+	unsigned int txdw5;
+	unsigned int txdw6;
+	unsigned int txdw7;
+};
+
+union txdesc {
+	struct tx_desc txdesc;
+	unsigned int value[TXDESC_SIZE>>2];
+};
+
+struct	hw_xmit	{
+	struct rtw_queue *sta_queue;
+	int	accnt;
+};
+
+/* reduce size */
+struct pkt_attrib {
+	u8	type;
+	u8	subtype;
+	u8	bswenc;
+	u8	dhcp_pkt;
+	u16	ether_type;
+	u16	seqnum;
+	u16	pkt_hdrlen;	/* the original 802.3 pkt header len */
+	u16	hdrlen;		/* the WLAN Header Len */
+	u32	pktlen;		/* the original 802.3 pkt raw_data len */
+	u32	last_txcmdsz;
+	u8	nr_frags;
+	u8	encrypt;	/* when 0 indicate no encrypt. */
+	u8	iv_len;
+	u8	icv_len;
+	u8	iv[18];
+	u8	icv[16];
+	u8	priority;
+	u8	ack_policy;
+	u8	mac_id;
+	u8	vcs_mode;	/* virtual carrier sense method */
+	u8	dst[ETH_ALEN];
+	u8	src[ETH_ALEN];
+	u8	ta[ETH_ALEN];
+	u8	ra[ETH_ALEN];
+	u8	key_idx;
+	u8	qos_en;
+	u8	ht_en;
+	u8	raid;/* rate adpative id */
+	u8	bwmode;
+	u8	ch_offset;/* PRIME_CHNL_OFFSET */
+	u8	sgi;/* short GI */
+	u8	ampdu_en;/* tx ampdu enable */
+	u8	mdata;/* more data bit */
+	u8	pctrl;/* per packet txdesc control enable */
+	u8	triggered;/* for ap mode handling Power Saving sta */
+	u8	qsel;
+	u8	eosp;
+	u8	rate;
+	u8	retry_ctrl;
+	struct sta_info *psta;
+};
+
+#define WLANHDR_OFFSET		64
+
+#define NULL_FRAMETAG		0x0
+#define DATA_FRAMETAG		0x01
+#define L2_FRAMETAG		0x02
+#define MGNT_FRAMETAG		0x03
+#define AMSDU_FRAMETAG		0x04
+
+#define EII_FRAMETAG		0x05
+#define IEEE8023_FRAMETAG 	0x06
+
+#define MP_FRAMETAG		0x07
+
+#define TXAGG_FRAMETAG		0x08
+
+struct  submit_ctx {
+	u32 timeout_ms; /* <0: not synchronous, 0: wait forever,
+			 * >0: up to ms waiting
+			 */
+	int status; /* status for operation */
+	struct completion done;
+};
+
+enum {
+	RTW_SCTX_SUBMITTED =3D -1,
+	RTW_SCTX_DONE_SUCCESS =3D 0,
+	RTW_SCTX_DONE_UNKNOWN,
+	RTW_SCTX_DONE_TIMEOUT,
+	RTW_SCTX_DONE_BUF_ALLOC,
+	RTW_SCTX_DONE_BUF_FREE,
+	RTW_SCTX_DONE_WRITE_PORT_ERR,
+	RTW_SCTX_DONE_TX_DESC_NA,
+	RTW_SCTX_DONE_TX_DENY,
+	RTW_SCTX_DONE_CCX_PKT_FAIL,
+	RTW_SCTX_DONE_DRV_STOP,
+	RTW_SCTX_DONE_DEV_REMOVE,
+};
+
+void rtw_sctx_init23a(struct submit_ctx *sctx, int timeout_ms);
+int rtw_sctx_wait23a(struct submit_ctx *sctx);
+void rtw23a_sctx_done_err(struct submit_ctx **sctx, int status);
+void rtw_sctx_done23a(struct submit_ctx **sctx);
+
+struct xmit_buf {
+	struct list_head list, list2;
+	struct rtw_adapter *padapter;
+
+	u8 *pallocated_buf;
+	u8 *pbuf;
+	void *priv_data;
+
+	u16 ext_tag; /*  0: Normal xmitbuf, 1: extension xmitbuf. */
+	u16 flags;
+	u32 alloc_sz;
+	u32  len;
+	struct submit_ctx *sctx;
+	u32	ff_hwaddr;
+	struct urb *pxmit_urb[8];
+	u8 bpending[8];
+	int last[8];
+#if defined(DBG_XMIT_BUF) || defined(DBG_XMIT_BUF_EXT)
+	u8 no;
+#endif
+};
+
+struct xmit_frame {
+	struct list_head	list;
+	struct pkt_attrib attrib;
+	struct sk_buff *pkt;
+	int	frame_tag;
+	struct rtw_adapter *padapter;
+	u8	*buf_addr;
+	struct xmit_buf *pxmitbuf;
+
+	s8	pkt_offset;
+
+	u8 ack_report;
+
+	u8 ext_tag; /* 0:data, 1:mgmt */
+};
+
+struct tx_servq {
+	struct list_head	tx_pending;
+	struct rtw_queue	sta_pending;
+	int qcnt;
+};
+
+struct sta_xmit_priv {
+	spinlock_t	lock;
+	int	option;
+	int	apsd_setting;	/* When bit mask is on, the associated edca
+				 * queue supports APSD.
+				 */
+	struct tx_servq	be_q;			/* priority =3D=3D 0,3 */
+	struct tx_servq	bk_q;			/* priority =3D=3D 1,2 */
+	struct tx_servq	vi_q;			/* priority =3D=3D 4,5 */
+	struct tx_servq	vo_q;			/* priority =3D=3D 6,7 */
+	struct list_head legacy_dz;
+	struct list_head apsd;
+	u16 txseq_tid[16];
+};
+
+struct	hw_txqueue {
+	volatile int head;
+	volatile int tail;
+	volatile int free_sz;	/* in units of 64 bytes */
+	volatile int free_cmdsz;
+	volatile int txsz[8];
+	uint	ff_hwaddr;
+	uint	cmd_hwaddr;
+	int	ac_tag;
+};
+
+struct agg_pkt_info {
+	u16 offset;
+	u16 pkt_len;
+};
+
+struct	xmit_priv {
+	spinlock_t	lock;
+
+	struct semaphore	xmit_sema;
+	struct semaphore	terminate_xmitthread_sema;
+
+	struct rtw_queue	be_pending;
+	struct rtw_queue	bk_pending;
+	struct rtw_queue	vi_pending;
+	struct rtw_queue	vo_pending;
+	struct rtw_queue	bm_pending;
+
+	u8 *pallocated_frame_buf;
+	u8 *pxmit_frame_buf;
+	uint free_xmitframe_cnt;
+	struct rtw_queue	free_xmit_queue;
+
+	u8 *xframe_ext_alloc_addr;
+	u8 *xframe_ext;
+	uint free_xframe_ext_cnt;
+	struct rtw_queue free_xframe_ext_queue;
+
+	uint	frag_len;
+
+	struct rtw_adapter	*adapter;
+
+	u8   vcs_setting;
+	u8	vcs;
+	u8	vcs_type;
+
+	u64	tx_bytes;
+	u64	tx_pkts;
+	u64	tx_drop;
+	u64	last_tx_bytes;
+	u64	last_tx_pkts;
+
+	struct hw_xmit *hwxmits;
+	u8	hwxmit_entry;
+
+	u8	wmm_para_seq[4];/* sequence for wmm ac parameter strength from
+				 * large to small. it's value is 0->vo, 1->vi,
+				 * 2->be, 3->bk.
+				 */
+
+	struct semaphore	tx_retevt;/* all tx return event; */
+	u8		txirp_cnt;/*  */
+
+	struct tasklet_struct xmit_tasklet;
+	/* per AC pending irp */
+	int beq_cnt;
+	int bkq_cnt;
+	int viq_cnt;
+	int voq_cnt;
+
+	struct rtw_queue free_xmitbuf_queue;
+	struct list_head xmitbuf_list;		/* track buffers for cleanup */
+	struct rtw_queue pending_xmitbuf_queue;
+	uint free_xmitbuf_cnt;
+
+	struct rtw_queue free_xmit_extbuf_queue;
+	struct list_head xmitextbuf_list;	/* track buffers for cleanup */
+	uint free_xmit_extbuf_cnt;
+
+	u16	nqos_ssn;
+	int	ack_tx;
+	struct mutex ack_tx_mutex;
+	struct submit_ctx ack_tx_ops;
+	spinlock_t lock_sctx;
+};
+
+struct xmit_buf *rtw_alloc_xmitbuf23a_ext(struct xmit_priv *pxmitpriv)=
;
+s32 rtw_free_xmitbuf_ext23a(struct xmit_priv *pxmitpriv,
+			 struct xmit_buf *pxmitbuf);
+
+struct xmit_buf *rtw_alloc_xmitbuf23a(struct xmit_priv *pxmitpriv);
+s32 rtw_free_xmitbuf23a(struct xmit_priv *pxmitpriv, struct xmit_buf *=
pxmitbuf);
+
+void rtw_count_tx_stats23a(struct rtw_adapter *padapter,
+			struct xmit_frame *pxmitframe, int sz);
+void rtw_update_protection23a(struct rtw_adapter *padapter, u8 *ie, ui=
nt ie_len);
+s32 rtw_make_wlanhdr23a(struct rtw_adapter *padapter, u8 *hdr,
+		     struct pkt_attrib *pattrib);
+s32 rtw_put_snap23a(u8 *data, u16 h_proto);
+struct xmit_frame *rtw_alloc_xmitframe23a(struct xmit_priv *pxmitpriv)=
;
+struct xmit_frame *rtw_alloc_xmitframe23a_ext(struct xmit_priv *pxmitp=
riv);
+struct xmit_frame *rtw_alloc_xmitframe23a_once(struct xmit_priv *pxmit=
priv);
+s32 rtw_free_xmitframe23a(struct xmit_priv *pxmitpriv,
+		       struct xmit_frame *pxmitframe);
+void rtw_free_xmitframe_queue23a(struct xmit_priv *pxmitpriv, struct r=
tw_queue *pframequeue);
+struct tx_servq *rtw_get_sta_pending23a(struct rtw_adapter *padapter,
+				     struct sta_info *psta, int up, u8 *ac);
+s32 rtw_xmitframe_enqueue23a(struct rtw_adapter *padapter,
+			     struct xmit_frame *pxmitframe);
+struct xmit_frame *rtw_dequeue_xframe23a(struct xmit_priv *pxmitpriv,
+				      struct hw_xmit *phwxmit_i, int entry);
+s32 rtw_xmit23a_classifier(struct rtw_adapter *padapter,
+			struct xmit_frame *pxmitframe);
+u32 rtw_calculate_wlan_pkt_size_by_attribue23a(struct pkt_attrib *patt=
rib);
+#define rtw_wlan_pkt_size(f) rtw_calculate_wlan_pkt_size_by_attribue23=
a(&f->attrib)
+s32 rtw_xmitframe_coalesce23a(struct rtw_adapter *padapter, struct sk_=
buff *pkt,
+			      struct xmit_frame *pxmitframe);
+s32 _rtw_init_hw_txqueue(struct hw_txqueue *phw_txqueue, u8 ac_tag);
+void _rtw_init_sta_xmit_priv23a(struct sta_xmit_priv *psta_xmitpriv);
+
+s32 rtw_txframes_pending23a(struct rtw_adapter *padapter);
+s32 rtw_txframes_sta_ac_pending23a(struct rtw_adapter *padapter,
+				struct pkt_attrib *pattrib);
+void rtw_init_hwxmits23a(struct hw_xmit *phwxmit, int entry);
+s32 _rtw_init_xmit_priv23a(struct xmit_priv *pxmitpriv,
+			struct rtw_adapter *padapter);
+void _rtw_free_xmit_priv23a(struct xmit_priv *pxmitpriv);
+void rtw_alloc_hwxmits23a(struct rtw_adapter *padapter);
+void rtw_free_hwxmits23a(struct rtw_adapter *padapter);
+int rtw_xmit23a(struct rtw_adapter *padapter, struct sk_buff *pkt);
+#if defined(CONFIG_8723AU_AP_MODE)
+int xmitframe_enqueue_for_sleeping_sta23a(struct rtw_adapter *padapter=
,
+				       struct xmit_frame *pxmitframe);
+void stop_sta_xmit23a(struct rtw_adapter *padapter, struct sta_info *p=
sta);
+void wakeup_sta_to_xmit23a(struct rtw_adapter *padapter, struct sta_in=
fo *psta);
+void xmit_delivery_enabled_frames23a(struct rtw_adapter *padapter,
+				  struct sta_info *psta);
+#endif
+u8	qos_acm23a(u8 acm_mask, u8 priority);
+u32	rtw_get_ff_hwaddr23a(struct xmit_frame	*pxmitframe);
+int rtw_ack_tx_wait23a(struct xmit_priv *pxmitpriv, u32 timeout_ms);
+void rtw_ack_tx_done23a(struct xmit_priv *pxmitpriv, int status);
+
+/* include after declaring struct xmit_buf, in order to avoid warning =
*/
+#include <xmit_osdep.h>
+
+#endif	/* _RTL871X_XMIT_H_ */
diff --git a/drivers/staging/rtl8723au/include/sta_info.h b/drivers/sta=
ging/rtl8723au/include/sta_info.h
new file mode 100644
index 0000000..8af98ee
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/sta_info.h
@@ -0,0 +1,396 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __STA_INFO_H_
+#define __STA_INFO_H_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <wifi.h>
+
+#define IBSS_START_MAC_ID	2
+#define NUM_STA 32
+#define NUM_ACL 16
+
+
+/* if mode =3D=3D0, then the sta is allowed once the addr is hit. */
+/* if mode =3D=3D1, then the sta is rejected once the addr is non-hit.=
 */
+struct rtw_wlan_acl_node {
+	struct list_head	list;
+	u8       addr[ETH_ALEN];
+	u8       valid;
+};
+
+/* mode=3D0, disable */
+/* mode=3D1, accept unless in deny list */
+/* mode=3D2, deny unless in accept list */
+struct wlan_acl_pool {
+	int mode;
+	int num;
+	struct rtw_wlan_acl_node aclnode[NUM_ACL];
+	struct rtw_queue	acl_node_q;
+};
+
+struct rssi_sta  {
+	s32	UndecoratedSmoothedPWDB;
+	s32	UndecoratedSmoothedCCK;
+	s32	UndecoratedSmoothedOFDM;
+	u64	PacketMap;
+	u8	ValidBit;
+};
+
+struct	stainfo_stats	{
+	u64 rx_mgnt_pkts;
+		u64 rx_beacon_pkts;
+		u64 rx_probereq_pkts;
+		u64 rx_probersp_pkts;
+		u64 rx_probersp_bm_pkts;
+		u64 rx_probersp_uo_pkts;
+	u64 rx_ctrl_pkts;
+	u64 rx_data_pkts;
+
+	u64	last_rx_mgnt_pkts;
+		u64 last_rx_beacon_pkts;
+		u64 last_rx_probereq_pkts;
+		u64 last_rx_probersp_pkts;
+		u64 last_rx_probersp_bm_pkts;
+		u64 last_rx_probersp_uo_pkts;
+	u64	last_rx_ctrl_pkts;
+	u64	last_rx_data_pkts;
+
+	u64	rx_bytes;
+	u64	rx_drops;
+
+	u64	tx_pkts;
+	u64	tx_bytes;
+	u64  tx_drops;
+
+};
+
+struct sta_info {
+	spinlock_t	lock;
+	struct list_head	list; /* free_sta_queue */
+	struct list_head	hash_list; /* sta_hash */
+	struct rtw_adapter *padapter;
+
+	struct sta_xmit_priv sta_xmitpriv;
+	struct sta_recv_priv sta_recvpriv;
+
+	struct rtw_queue sleep_q;
+	unsigned int sleepq_len;
+
+	uint state;
+	uint aid;
+	uint mac_id;
+	uint qos_option;
+	u8	hwaddr[ETH_ALEN];
+
+	uint	ieee8021x_blocked;	/* 0: allowed, 1:blocked */
+	uint	dot118021XPrivacy; /* aes, tkip... */
+	union Keytype	dot11tkiptxmickey;
+	union Keytype	dot11tkiprxmickey;
+	union Keytype	dot118021x_UncstKey;
+	union pn48		dot11txpn;			/*  PN48 used for Unicast xmit. */
+	union pn48		dot11rxpn;			/*  PN48 used for Unicast recv. */
+
+
+	u8	bssrateset[16];
+	u32	bssratelen;
+	s32  rssi;
+	s32	signal_quality;
+
+	u8	cts2self;
+	u8	rtsen;
+
+	u8	raid;
+	u8	init_rate;
+	u32	ra_mask;
+	u8	wireless_mode;	/*  NETWORK_TYPE */
+	struct stainfo_stats sta_stats;
+
+	/* for A-MPDU TX, ADDBA timeout check */
+	struct timer_list addba_retry_timer;
+
+	/* for A-MPDU Rx reordering buffer control */
+	struct recv_reorder_ctrl recvreorder_ctrl[16];
+
+	/* for A-MPDU Tx */
+	/* unsigned char		ampdu_txen_bitmap; */
+	u16	BA_starting_seqctrl[16];
+
+	struct ht_priv	htpriv;
+
+	/* Notes: */
+	/* STA_Mode: */
+	/* curr_network(mlme_priv/security_priv/qos/ht) + sta_info: (STA & AP=
) CAP/INFO */
+	/* scan_q: AP CAP/INFO */
+
+	/* AP_Mode: */
+	/* curr_network(mlme_priv/security_priv/qos/ht) : AP CAP/INFO */
+	/* sta_info: (AP & STA) CAP/INFO */
+
+#ifdef CONFIG_8723AU_AP_MODE
+
+	struct list_head asoc_list;
+	struct list_head auth_list;
+
+	unsigned int expire_to;
+	unsigned int auth_seq;
+	unsigned int authalg;
+	unsigned char chg_txt[128];
+
+	u16 capability;
+	int flags;
+
+	int dot8021xalg;/* 0:disable, 1:psk, 2:802.1x */
+	int wpa_psk;/* 0:disable, bit(0): WPA, bit(1):WPA2 */
+	int wpa_group_cipher;
+	int wpa2_group_cipher;
+	int wpa_pairwise_cipher;
+	int wpa2_pairwise_cipher;
+
+	u8 bpairwise_key_installed;
+
+	u8 wpa_ie[32];
+
+	u8 nonerp_set;
+	u8 no_short_slot_time_set;
+	u8 no_short_preamble_set;
+	u8 no_ht_gf_set;
+	u8 no_ht_set;
+	u8 ht_20mhz_set;
+
+	unsigned int tx_ra_bitmap;
+	u8 qos_info;
+
+	u8 max_sp_len;
+	u8 uapsd_bk;/* BIT(0): Delivery enabled, BIT(1): Trigger enabled */
+	u8 uapsd_be;
+	u8 uapsd_vi;
+	u8 uapsd_vo;
+
+	u8 has_legacy_ac;
+	unsigned int sleepq_ac_len;
+
+#ifdef CONFIG_8723AU_P2P
+	/* p2p priv data */
+	u8 is_p2p_device;
+	u8 p2p_status_code;
+
+	/* p2p client info */
+	u8 dev_addr[ETH_ALEN];
+	u8 dev_cap;
+	u16 config_methods;
+	u8 primary_dev_type[8];
+	u8 num_of_secdev_type;
+	u8 secdev_types_list[32];/*  32/8 =3D=3D 4; */
+	u16 dev_name_len;
+	u8 dev_name[32];
+#endif /* CONFIG_8723AU_P2P */
+
+	u8 keep_alive_trycnt;
+
+#endif	/*  CONFIG_8723AU_AP_MODE */
+
+	u8 *passoc_req;
+	u32 assoc_req_len;
+
+	/* for DM */
+	struct rssi_sta	 rssi_stat;
+
+	/*  */
+	/*  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DODM Relative Info=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D *=
/
+	/*  Please be care, dont declare too much structure here. It will cos=
t memory * STA support num. */
+	/*  */
+	/*  */
+	/*  2011/10/20 MH Add for ODM STA info. */
+	/*  */
+	/*  Driver Write */
+	u8		bValid;				/*  record the sta status link or not? */
+	u8		IOTPeer;			/*  Enum value.	HT_IOT_PEER_E */
+	u8		rssi_level;			/* for Refresh RA mask */
+	/*  ODM Write */
+	/* 1 PHY_STATUS_INFO */
+	u8		RSSI_Path[4];		/*  */
+	u8		RSSI_Ave;
+	u8		RXEVM[4];
+	u8		RXSNR[4];
+
+	/*  ODM Write */
+	/* 1 TX_INFO (may changed by IC) */
+	/*  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DODM Relative Info=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D *=
/
+	/*  */
+
+	/* To store the sequence number of received management frame */
+	u16 RxMgmtFrameSeqNum;
+};
+
+#define sta_rx_pkts(sta) \
+	(sta->sta_stats.rx_mgnt_pkts \
+	+ sta->sta_stats.rx_ctrl_pkts \
+	+ sta->sta_stats.rx_data_pkts)
+
+#define sta_last_rx_pkts(sta) \
+	(sta->sta_stats.last_rx_mgnt_pkts \
+	+ sta->sta_stats.last_rx_ctrl_pkts \
+	+ sta->sta_stats.last_rx_data_pkts)
+
+#define sta_rx_data_pkts(sta) \
+	(sta->sta_stats.rx_data_pkts)
+
+#define sta_last_rx_data_pkts(sta) \
+	(sta->sta_stats.last_rx_data_pkts)
+
+#define sta_rx_mgnt_pkts(sta) \
+	(sta->sta_stats.rx_mgnt_pkts)
+
+#define sta_last_rx_mgnt_pkts(sta) \
+	(sta->sta_stats.last_rx_mgnt_pkts)
+
+#define sta_rx_beacon_pkts(sta) \
+	(sta->sta_stats.rx_beacon_pkts)
+
+#define sta_last_rx_beacon_pkts(sta) \
+	(sta->sta_stats.last_rx_beacon_pkts)
+
+#define sta_rx_probereq_pkts(sta) \
+	(sta->sta_stats.rx_probereq_pkts)
+
+#define sta_last_rx_probereq_pkts(sta) \
+	(sta->sta_stats.last_rx_probereq_pkts)
+
+#define sta_rx_probersp_pkts(sta) \
+	(sta->sta_stats.rx_probersp_pkts)
+
+#define sta_last_rx_probersp_pkts(sta) \
+	(sta->sta_stats.last_rx_probersp_pkts)
+
+#define sta_rx_probersp_bm_pkts(sta) \
+	(sta->sta_stats.rx_probersp_bm_pkts)
+
+#define sta_last_rx_probersp_bm_pkts(sta) \
+	(sta->sta_stats.last_rx_probersp_bm_pkts)
+
+#define sta_rx_probersp_uo_pkts(sta) \
+	(sta->sta_stats.rx_probersp_uo_pkts)
+
+#define sta_last_rx_probersp_uo_pkts(sta) \
+	(sta->sta_stats.last_rx_probersp_uo_pkts)
+
+#define sta_update_last_rx_pkts(sta) \
+	do { \
+		sta->sta_stats.last_rx_mgnt_pkts =3D sta->sta_stats.rx_mgnt_pkts; \
+		sta->sta_stats.last_rx_beacon_pkts =3D sta->sta_stats.rx_beacon_pkts=
; \
+		sta->sta_stats.last_rx_probereq_pkts =3D sta->sta_stats.rx_probereq_=
pkts; \
+		sta->sta_stats.last_rx_probersp_pkts =3D sta->sta_stats.rx_probersp_=
pkts; \
+		sta->sta_stats.last_rx_probersp_bm_pkts =3D sta->sta_stats.rx_prober=
sp_bm_pkts; \
+		sta->sta_stats.last_rx_probersp_uo_pkts =3D sta->sta_stats.rx_prober=
sp_uo_pkts; \
+		sta->sta_stats.last_rx_ctrl_pkts =3D sta->sta_stats.rx_ctrl_pkts; \
+		sta->sta_stats.last_rx_data_pkts =3D sta->sta_stats.rx_data_pkts; \
+	} while (0)
+
+#define STA_RX_PKTS_ARG(sta) \
+	sta->sta_stats.rx_mgnt_pkts \
+	, sta->sta_stats.rx_ctrl_pkts \
+	, sta->sta_stats.rx_data_pkts
+
+#define STA_LAST_RX_PKTS_ARG(sta) \
+	sta->sta_stats.last_rx_mgnt_pkts, \
+	sta->sta_stats.last_rx_ctrl_pkts, \
+	sta->sta_stats.last_rx_data_pkts
+
+#define STA_RX_PKTS_DIFF_ARG(sta) \
+	sta->sta_stats.rx_mgnt_pkts - sta->sta_stats.last_rx_mgnt_pkts, \
+	sta->sta_stats.rx_ctrl_pkts - sta->sta_stats.last_rx_ctrl_pkts, \
+	sta->sta_stats.rx_data_pkts - sta->sta_stats.last_rx_data_pkts
+
+#define STA_PKTS_FMT "(m:%llu, c:%llu, d:%llu)"
+
+struct	sta_priv {
+	u8 *pallocated_stainfo_buf;
+	u8 *pstainfo_buf;
+	struct rtw_queue	free_sta_queue;
+
+	spinlock_t sta_hash_lock;
+	struct list_head   sta_hash[NUM_STA];
+	int asoc_sta_count;
+	struct rtw_queue sleep_q;
+	struct rtw_queue wakeup_q;
+
+	struct rtw_adapter *padapter;
+
+
+#ifdef CONFIG_8723AU_AP_MODE
+	struct list_head asoc_list;
+	struct list_head auth_list;
+	spinlock_t asoc_list_lock;
+	spinlock_t auth_list_lock;
+	u8 asoc_list_cnt;
+	u8 auth_list_cnt;
+
+	unsigned int auth_to;  /* sec, time to expire in authenticating. */
+	unsigned int assoc_to; /* sec, time to expire before associating. */
+	unsigned int expire_to; /* sec , time to expire after associated. */
+
+	/* pointers to STA info; based on allocated AID or NULL if AID free
+	 * AID is in the range 1-2007, so sta_aid[0] corresponders to AID 1
+	 * and so on
+	 */
+	struct sta_info *sta_aid[NUM_STA];
+
+	u16 sta_dz_bitmap;/* only support 15 stations, staion aid bitmap
+			   * for sleeping sta. */
+	u16 tim_bitmap;/* only support 15 stations,
+			* aid=3D0~15 mapping bit0~bit15 */
+
+	u16 max_num_sta;
+
+	struct wlan_acl_pool acl_list;
+#endif
+};
+
+static inline u32 wifi_mac_hash(u8 *mac)
+{
+	u32 x;
+
+	x =3D mac[0];
+	x =3D (x << 2) ^ mac[1];
+	x =3D (x << 2) ^ mac[2];
+	x =3D (x << 2) ^ mac[3];
+	x =3D (x << 2) ^ mac[4];
+	x =3D (x << 2) ^ mac[5];
+
+	x ^=3D x >> 8;
+	x  =3D x & (NUM_STA - 1);
+
+	return x;
+}
+
+u32	_rtw_init_sta_priv23a(struct sta_priv *pstapriv);
+u32	_rtw_free_sta_priv23a(struct sta_priv *pstapriv);
+
+#define stainfo_offset_valid(offset) (offset < NUM_STA && offset >=3D =
0)
+int rtw_stainfo_offset23a(struct sta_priv *stapriv, struct sta_info *s=
ta);
+struct sta_info *rtw_get_stainfo23a_by_offset23a(struct sta_priv *stap=
riv,
+					   int offset);
+
+struct sta_info *rtw_alloc_stainfo23a(struct sta_priv *pstapriv, u8 *h=
waddr);
+u32 rtw_free_stainfo23a(struct rtw_adapter *padapter, struct sta_info =
*psta);
+void rtw_free_all_stainfo23a(struct rtw_adapter *padapter);
+struct sta_info *rtw_get_stainfo23a(struct sta_priv *pstapriv, u8 *hwa=
ddr);
+u32 rtw_init_bcmc_stainfo23a(struct rtw_adapter *padapter);
+struct sta_info *rtw_get_bcmc_stainfo23a(struct rtw_adapter *padapter)=
;
+u8 rtw_access_ctrl23a(struct rtw_adapter *padapter, u8 *mac_addr);
+
+#endif /* _STA_INFO_H_ */
diff --git a/drivers/staging/rtl8723au/include/usb_hal.h b/drivers/stag=
ing/rtl8723au/include/usb_hal.h
new file mode 100644
index 0000000..4edec3b
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/usb_hal.h
@@ -0,0 +1,20 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __USB_HAL_H__
+#define __USB_HAL_H__
+
+int rtl8723au_set_hal_ops(struct rtw_adapter *padapter);
+
+#endif /* __USB_HAL_H__ */
diff --git a/drivers/staging/rtl8723au/include/usb_ops.h b/drivers/stag=
ing/rtl8723au/include/usb_ops.h
new file mode 100644
index 0000000..55d1380
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/usb_ops.h
@@ -0,0 +1,97 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __USB_OPS_H_
+#define __USB_OPS_H_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <osdep_intf.h>
+#include <usb_ops_linux.h>
+
+#define REALTEK_USB_VENQT_READ		0xC0
+#define REALTEK_USB_VENQT_WRITE		0x40
+#define REALTEK_USB_VENQT_CMD_REQ	0x05
+#define REALTEK_USB_VENQT_CMD_IDX	0x00
+
+enum {
+	VENDOR_WRITE =3D 0x00,
+	VENDOR_READ =3D 0x01,
+};
+
+#define ALIGNMENT_UNIT				16
+#define MAX_VENDOR_REQ_CMD_SIZE	254		/* 8188cu SIE Support */
+#define MAX_USB_IO_CTL_SIZE	(MAX_VENDOR_REQ_CMD_SIZE +ALIGNMENT_UNIT)
+
+#define rtw_usb_control_msg(dev, pipe, request, requesttype, value,	\
+			    index, data, size, timeout_ms)		\
+	usb_control_msg((dev), (pipe), (request), (requesttype),	\
+			(value), (index), (data), (size), (timeout_ms))
+#define rtw_usb_bulk_msg(usb_dev, pipe, data, len, actual_length, time=
out_ms) \
+	usb_bulk_msg((usb_dev), (pipe), (data), (len), (actual_length),	\
+		     (timeout_ms))
+
+void rtl8723au_set_hw_type(struct rtw_adapter *padapter);
+#define hal_set_hw_type rtl8723au_set_hw_type
+
+void rtl8723au_set_intf_ops(struct _io_ops *pops);
+#define usb_set_intf_ops rtl8723au_set_intf_ops
+
+void rtl8723au_recv_tasklet(void *priv);
+
+void rtl8723au_xmit_tasklet(void *priv);
+
+/* Increase and check if the continual_urb_error of this @param dvobjp=
rive is
+ * larger than MAX_CONTINUAL_URB_ERR. Return result
+ */
+static inline int rtw_inc_and_chk_continual_urb_error(struct dvobj_pri=
v *dvobj)
+{
+	int ret =3D false;
+	int value;
+
+	value =3D atomic_inc_return(&dvobj->continual_urb_error);
+	if (value > MAX_CONTINUAL_URB_ERR) {
+		DBG_8723A("[dvobj:%p][ERROR] continual_urb_error:%d > %d\n",
+			  dvobj, value, MAX_CONTINUAL_URB_ERR);
+		ret =3D true;
+	}
+	return ret;
+}
+
+/* Set the continual_urb_error of this @param dvobjprive to 0 */
+static inline void rtw_reset_continual_urb_error(struct dvobj_priv *dv=
obj)
+{
+	atomic_set(&dvobj->continual_urb_error, 0);
+}
+
+#define USB_HIGH_SPEED_BULK_SIZE	512
+#define USB_FULL_SPEED_BULK_SIZE	64
+
+static inline u8 rtw_usb_bulk_size_boundary(struct rtw_adapter *padapt=
er,
+					    int buf_len)
+{
+	u8 rst =3D true;
+	struct dvobj_priv *pdvobjpriv =3D adapter_to_dvobj(padapter);
+
+	if (pdvobjpriv->ishighspeed)
+		rst =3D (0 =3D=3D (buf_len) % USB_HIGH_SPEED_BULK_SIZE) ?
+		      true : false;
+	else
+		rst =3D (0 =3D=3D (buf_len) % USB_FULL_SPEED_BULK_SIZE) ?
+		      true : false;
+	return rst;
+}
+
+
+#endif /* __USB_OPS_H_ */
diff --git a/drivers/staging/rtl8723au/include/usb_ops_linux.h b/driver=
s/staging/rtl8723au/include/usb_ops_linux.h
new file mode 100644
index 0000000..8f5c59e
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/usb_ops_linux.h
@@ -0,0 +1,46 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __USB_OPS_LINUX_H__
+#define __USB_OPS_LINUX_H__
+
+#define VENDOR_CMD_MAX_DATA_LEN	254
+
+#define RTW_USB_CONTROL_MSG_TIMEOUT_TEST	10/* ms */
+#define RTW_USB_CONTROL_MSG_TIMEOUT	500/* ms */
+
+#define MAX_USBCTRL_VENDORREQ_TIMES	10
+
+#define RTW_USB_BULKOUT_TIMEOUT	5000/* ms */
+
+#define _usbctrl_vendorreq_async_callback(urb, regs)		\
+	_usbctrl_vendorreq_async_callback(urb)
+#define usb_write_mem23a_complete(purb, regs)	usb_write_mem23a_complet=
e(purb)
+#define usb_write_port23a_complete(purb, regs)	usb_write_port23a_compl=
ete(purb)
+#define usb_read_port_complete(purb, regs)	usb_read_port_complete(purb=
)
+#define usb_read_interrupt_complete(purb, regs)			\
+	usb_read_interrupt_complete(purb)
+
+unsigned int ffaddr2pipehdl23a(struct dvobj_priv *pdvobj, u32 addr);
+
+void usb_read_mem23a(struct intf_hdl *pintfhdl, u32 addr, u32 cnt, u8 =
*rmem);
+void usb_write_mem23a(struct intf_hdl *pintfhdl, u32 addr, u32 cnt, u8=
 *wmem);
+
+void usb_read_port_cancel23a(struct intf_hdl *pintfhdl);
+
+u32 usb_write_port23a(struct intf_hdl *pintfhdl, u32 addr, u32 cnt,
+		   struct xmit_buf *wmem);
+void usb_write_port23a_cancel(struct intf_hdl *pintfhdl);
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/usb_osintf.h b/drivers/s=
taging/rtl8723au/include/usb_osintf.h
new file mode 100644
index 0000000..4608766
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/usb_osintf.h
@@ -0,0 +1,24 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __USB_OSINTF_H
+#define __USB_OSINTF_H
+
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <usb_vendor_req.h>
+
+#define USBD_HALTED(_status) ((u32)(_status) >> 30 =3D=3D 3)
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/usb_vendor_req.h b/drive=
rs/staging/rtl8723au/include/usb_vendor_req.h
new file mode 100644
index 0000000..eb4508e
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/usb_vendor_req.h
@@ -0,0 +1,31 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef _USB_VENDOR_REQUEST_H_
+#define _USB_VENDOR_REQUEST_H_
+
+/* 4	Set/Get Register related wIndex/Data */
+#define	RT_USB_RESET_MASK_OFF		0
+#define	RT_USB_RESET_MASK_ON		1
+#define	RT_USB_SLEEP_MASK_OFF		0
+#define	RT_USB_SLEEP_MASK_ON		1
+#define	RT_USB_LDO_ON			1
+#define	RT_USB_LDO_OFF			0
+
+/* 4	Set/Get SYSCLK related	wValue or Data */
+#define	RT_USB_SYSCLK_32KHZ		0
+#define	RT_USB_SYSCLK_40MHZ		1
+#define	RT_USB_SYSCLK_60MHZ		2
+
+#endif
diff --git a/drivers/staging/rtl8723au/include/wifi.h b/drivers/staging=
/rtl8723au/include/wifi.h
new file mode 100644
index 0000000..b5034c6
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/wifi.h
@@ -0,0 +1,707 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2012 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef _WIFI_H_
+#define _WIFI_H_
+
+#define P80211CAPTURE_VERSION	0x80211001
+
+/*  This value is tested by WiFi 11n Test Plan 5.2.3.
+ *  This test verifies the WLAN NIC can update the NAV through sending
+ *  the CTS with large duration.
+ */
+#define	WiFiNavUpperUs		30000	/*  30 ms */
+
+enum WIFI_FRAME_TYPE {
+	WIFI_MGT_TYPE  =3D	(0),
+	WIFI_CTRL_TYPE =3D	(BIT(2)),
+	WIFI_DATA_TYPE =3D	(BIT(3)),
+	WIFI_QOS_DATA_TYPE	=3D (BIT(7)|BIT(3)),	/*  QoS Data */
+};
+
+enum WIFI_FRAME_SUBTYPE {
+	/*  below is for mgt frame */
+	WIFI_ASSOCREQ =3D (0 | WIFI_MGT_TYPE),
+	WIFI_ASSOCRSP =3D (BIT(4) | WIFI_MGT_TYPE),
+	WIFI_REASSOCREQ =3D (BIT(5) | WIFI_MGT_TYPE),
+	WIFI_REASSOCRSP =3D (BIT(5) | BIT(4) | WIFI_MGT_TYPE),
+	WIFI_PROBEREQ =3D (BIT(6) | WIFI_MGT_TYPE),
+	WIFI_PROBERSP =3D (BIT(6) | BIT(4) | WIFI_MGT_TYPE),
+	WIFI_BEACON =3D (BIT(7) | WIFI_MGT_TYPE),
+	WIFI_ATIM =3D (BIT(7) | BIT(4) | WIFI_MGT_TYPE),
+	WIFI_DISASSOC =3D (BIT(7) | BIT(5) | WIFI_MGT_TYPE),
+	WIFI_AUTH =3D (BIT(7) | BIT(5) | BIT(4) | WIFI_MGT_TYPE),
+	WIFI_DEAUTH =3D (BIT(7) | BIT(6) | WIFI_MGT_TYPE),
+	WIFI_ACTION =3D (BIT(7) | BIT(6) | BIT(4) | WIFI_MGT_TYPE),
+
+	/*  below is for control frame */
+	WIFI_PSPOLL =3D (BIT(7) | BIT(5) | WIFI_CTRL_TYPE),
+	WIFI_RTS =3D (BIT(7) | BIT(5) | BIT(4) | WIFI_CTRL_TYPE),
+	WIFI_CTS =3D (BIT(7) | BIT(6) | WIFI_CTRL_TYPE),
+	WIFI_ACK =3D (BIT(7) | BIT(6) | BIT(4) | WIFI_CTRL_TYPE),
+	WIFI_CFEND =3D (BIT(7) | BIT(6) | BIT(5) | WIFI_CTRL_TYPE),
+	WIFI_CFEND_CFACK =3D (BIT(7) | BIT(6) | BIT(5) | BIT(4) | WIFI_CTRL_T=
YPE),
+
+	/*  below is for data frame */
+	WIFI_DATA =3D (0 | WIFI_DATA_TYPE),
+	WIFI_DATA_CFACK =3D (BIT(4) | WIFI_DATA_TYPE),
+	WIFI_DATA_CFPOLL =3D (BIT(5) | WIFI_DATA_TYPE),
+	WIFI_DATA_CFACKPOLL =3D (BIT(5) | BIT(4) | WIFI_DATA_TYPE),
+	WIFI_DATA_NULL =3D (BIT(6) | WIFI_DATA_TYPE),
+	WIFI_CF_ACK =3D (BIT(6) | BIT(4) | WIFI_DATA_TYPE),
+	WIFI_CF_POLL =3D (BIT(6) | BIT(5) | WIFI_DATA_TYPE),
+	WIFI_CF_ACKPOLL =3D (BIT(6) | BIT(5) | BIT(4) | WIFI_DATA_TYPE),
+	WIFI_QOS_DATA_NULL =3D (BIT(6) | WIFI_QOS_DATA_TYPE),
+};
+
+
+enum WIFI_REG_DOMAIN {
+	DOMAIN_FCC		=3D 1,
+	DOMAIN_IC		=3D 2,
+	DOMAIN_ETSI		=3D 3,
+	DOMAIN_SPAIN		=3D 4,
+	DOMAIN_FRANCE		=3D 5,
+	DOMAIN_MKK		=3D 6,
+	DOMAIN_ISRAEL		=3D 7,
+	DOMAIN_MKK1		=3D 8,
+	DOMAIN_MKK2		=3D 9,
+	DOMAIN_MKK3		=3D 10,
+	DOMAIN_MAX
+};
+
+
+#define SetToDs(pbuf)	\
+	(*(unsigned short *)(pbuf) |=3D cpu_to_le16(IEEE80211_FCTL_TODS))
+
+#define SetFrDs(pbuf)	\
+	(*(unsigned short *)(pbuf) |=3D cpu_to_le16(IEEE80211_FCTL_FROMDS))
+
+#define get_tofr_ds(pframe)	((ieee80211_has_tods(pframe) << 1) | \
+				 ieee80211_has_fromds(pframe))
+
+#define SetMFrag(pbuf)	\
+	(*(unsigned short *)(pbuf) |=3D cpu_to_le16(IEEE80211_FCTL_MOREFRAGS)=
)
+
+#define ClearMFrag(pbuf)	\
+	(*(unsigned short *)(pbuf) &=3D (~cpu_to_le16(IEEE80211_FCTL_MOREFRAG=
S)))
+
+#define SetRetry(pbuf)	\
+	(*(unsigned short *)(pbuf) |=3D cpu_to_le16(IEEE80211_FCTL_RETRY))
+
+#define SetPwrMgt(pbuf)	\
+	(*(unsigned short *)(pbuf) |=3D cpu_to_le16(IEEE80211_FCTL_PM))
+
+#define SetMData(pbuf)	\
+	(*(unsigned short *)(pbuf) |=3D cpu_to_le16(IEEE80211_FCTL_MOREDATA))
+
+#define SetPrivacy(pbuf)	\
+	(*(unsigned short *)(pbuf) |=3D cpu_to_le16(IEEE80211_FCTL_PROTECTED)=
)
+
+#define SetFrameType(pbuf, type)	\
+	do {	\
+		*(unsigned short *)(pbuf) &=3D __constant_cpu_to_le16(~(BIT(3) | BIT=
(2))); \
+		*(unsigned short *)(pbuf) |=3D __constant_cpu_to_le16(type); \
+	} while (0)
+
+#define SetFrameSubType(pbuf, type) \
+	do {    \
+		*(unsigned short *)(pbuf) &=3D cpu_to_le16(~(BIT(7) | BIT(6) | BIT(5=
) | BIT(4) | BIT(3) | BIT(2))); \
+		*(unsigned short *)(pbuf) |=3D cpu_to_le16(type); \
+	} while (0)
+
+#define GetTupleCache(pbuf)	(cpu_to_le16(*(unsigned short *)((unsigned=
 long)(pbuf) + 22)))
+
+#define SetFragNum(pbuf, num) \
+	do {    \
+		*(unsigned short *)((unsigned long)(pbuf) + 22) =3D \
+			((*(unsigned short *)((unsigned long)(pbuf) + 22)) & le16_to_cpu(~(=
0x000f))) | \
+			cpu_to_le16(0x0f & (num));     \
+	} while (0)
+
+#define SetSeqNum(pbuf, num) \
+	do {    \
+		*(unsigned short *)((unsigned long)(pbuf) + 22) =3D \
+			((*(unsigned short *)((unsigned long)(pbuf) + 22)) & le16_to_cpu((u=
nsigned short)0x000f)) | \
+			le16_to_cpu((unsigned short)(0xfff0 & (num << 4))); \
+	} while (0)
+
+#define SetDuration(pbuf, dur) \
+	(*(unsigned short *)((unsigned long)(pbuf) + 2) =3D		\
+	 cpu_to_le16(0xffff & (dur)))
+
+#define SetPriority(pbuf, tid)	\
+	(*(unsigned short *)(pbuf) |=3D cpu_to_le16(tid & 0xf))
+
+#define SetEOSP(pbuf, eosp)	\
+	(*(unsigned short *)(pbuf) |=3D cpu_to_le16((eosp & 1) << 4))
+
+#define SetAckpolicy(pbuf, ack)	\
+	(*(unsigned short *)(pbuf) |=3D cpu_to_le16((ack & 3) << 5))
+
+#define SetAMsdu(pbuf, amsdu)	\
+	(*(unsigned short *)(pbuf) |=3D cpu_to_le16((amsdu & 1) << 7))
+
+#define GetAid(pbuf)							\
+	(cpu_to_le16(*(unsigned short *)((unsigned long)(pbuf) + 2)) &	\
+	 0x3fff)
+
+#define GetTid(pbuf)							\
+	(cpu_to_le16(*(unsigned short *)((unsigned long)(pbuf) +	\
+	 (((ieee80211_has_tods(pbuf)<<1) |				\
+	 ieee80211_has_fromds(pbuf)) =3D=3D 3 ? 30 : 24))) & 0x000f)
+
+static inline unsigned char *get_hdr_bssid(unsigned char *pframe)
+{
+	unsigned char	*sa;
+	unsigned int	to_fr_ds;
+	struct ieee80211_hdr *hdr =3D (struct ieee80211_hdr *) pframe;
+
+	to_fr_ds =3D (ieee80211_has_tods(hdr->frame_control) << 1) |
+		    ieee80211_has_fromds(hdr->frame_control);
+
+	switch (to_fr_ds) {
+	case 0x00:	/*  ToDs=3D0, FromDs=3D0 */
+		sa =3D hdr->addr3;
+		break;
+	case 0x01:	/*  ToDs=3D0, FromDs=3D1 */
+		sa =3D hdr->addr2;
+		break;
+	case 0x02:	/*  ToDs=3D1, FromDs=3D0 */
+		sa =3D hdr->addr1;
+		break;
+	case 0x03:	/*  ToDs=3D1, FromDs=3D1 */
+		sa =3D hdr->addr1;
+		break;
+	default:
+		sa =3D NULL; /*  */
+		break;
+	}
+	return sa;
+}
+
+/*--------------------------------------------------------------------=
---------
+			Below is for the security related definition
+----------------------------------------------------------------------=
--------*/
+#define _RESERVED_FRAME_TYPE_		0
+#define _SKB_FRAME_TYPE_		2
+#define _PRE_ALLOCMEM_			1
+#define _PRE_ALLOCHDR_			3
+#define _PRE_ALLOCLLCHDR_		4
+#define _PRE_ALLOCICVHDR_		5
+#define _PRE_ALLOCMICHDR_		6
+
+#define _SIFSTIME_					\
+	((priv->pmib->dot11BssType.net_work_type & WIRELESS_11A) ? 16 : 10)
+#define _ACKCTSLNG_			14	/* 14 bytes long, including crclng */
+#define _CRCLNG_			4
+
+#define _ASOCREQ_IE_OFFSET_		4	/*  excluding wlan_hdr */
+#define	_ASOCRSP_IE_OFFSET_		6
+#define _REASOCREQ_IE_OFFSET_		10
+#define _REASOCRSP_IE_OFFSET_		6
+#define _PROBEREQ_IE_OFFSET_		0
+#define	_PROBERSP_IE_OFFSET_		12
+#define _AUTH_IE_OFFSET_		6
+#define _DEAUTH_IE_OFFSET_		0
+#define _BEACON_IE_OFFSET_		12
+#define _PUBLIC_ACTION_IE_OFFSET_	8
+
+#define _FIXED_IE_LENGTH_		_BEACON_IE_OFFSET_
+
+#define _SSID_IE_			0
+#define _SUPPORTEDRATES_IE_		1
+#define _DSSET_IE_			3
+#define _TIM_IE_			5
+#define _IBSS_PARA_IE_			6
+#define _COUNTRY_IE_			7
+#define _CHLGETXT_IE_			16
+#define _SUPPORTED_CH_IE_		36
+#define _CH_SWTICH_ANNOUNCE_	37	/* Secondary Channel Offset */
+#define _RSN_IE_2_			48
+#define _SSN_IE_1_			221
+#define _ERPINFO_IE_			42
+#define _EXT_SUPPORTEDRATES_IE_		50
+
+#define _HT_CAPABILITY_IE_		45
+#define _FTIE_				55
+#define _TIMEOUT_ITVL_IE_		56
+#define _SRC_IE_			59
+#define _HT_EXTRA_INFO_IE_		61
+#define _HT_ADD_INFO_IE_		61 /* _HT_EXTRA_INFO_IE_ */
+
+
+#define	EID_BSSCoexistence		72 /*  20/40 BSS Coexistence */
+#define	EID_BSSIntolerantChlReport	73
+#define _RIC_Descriptor_IE_		75
+
+#define _LINK_ID_IE_		101
+#define _CH_SWITCH_TIMING_	104
+#define _PTI_BUFFER_STATUS_	106
+#define _EXT_CAP_IE_		127
+#define _VENDOR_SPECIFIC_IE_	221
+
+#define	_RESERVED47_		47
+
+/* -------------------------------------------------------------------=
--------
+					Below is the fixed elements...
+----------------------------------------------------------------------=
-------*/
+#define _AUTH_ALGM_NUM_		2
+#define _AUTH_SEQ_NUM_		2
+#define _BEACON_ITERVAL_	2
+#define _CAPABILITY_		2
+#define _CURRENT_APADDR_	6
+#define _LISTEN_INTERVAL_	2
+#define _ASOC_ID_		2
+#define _STATUS_CODE_		2
+#define _TIMESTAMP_		8
+
+#define AUTH_ODD_TO		0
+#define AUTH_EVEN_TO		1
+
+#define WLAN_ETHCONV_ENCAP	1
+#define WLAN_ETHCONV_RFC1042	2
+#define WLAN_ETHCONV_8021h	3
+
+#define cap_ESS		BIT(0)
+#define cap_IBSS	BIT(1)
+#define cap_CFPollable	BIT(2)
+#define cap_CFRequest	BIT(3)
+#define cap_Privacy	BIT(4)
+#define cap_ShortPremble BIT(5)
+#define cap_PBCC	BIT(6)
+#define cap_ChAgility	BIT(7)
+#define cap_SpecMgmt	BIT(8)
+#define cap_QoS		BIT(9)
+#define cap_ShortSlot	BIT(10)
+
+/*--------------------------------------------------------------------=
---------
+				Below is the definition for 802.11i / 802.1x
+----------------------------------------------------------------------=
--------*/
+#define _IEEE8021X_MGT_			1	/*  WPA */
+#define _IEEE8021X_PSK_			2	/*  WPA with pre-shared key */
+
+/*
+#define _NO_PRIVACY_			0
+#define _WEP_40_PRIVACY_		1
+#define _TKIP_PRIVACY_			2
+#define _WRAP_PRIVACY_			3
+#define _CCMP_PRIVACY_			4
+#define _WEP_104_PRIVACY_		5
+#define _WEP_WPA_MIXED_PRIVACY_ 6	WEP + WPA
+*/
+
+/*--------------------------------------------------------------------=
---------
+				Below is the definition for WMM
+----------------------------------------------------------------------=
--------*/
+#define _WMM_IE_Length_				7  /*  for WMM STA */
+#define _WMM_Para_Element_Length_		24
+
+
+/*--------------------------------------------------------------------=
---------
+				Below is the definition for 802.11n
+----------------------------------------------------------------------=
--------*/
+
+#define SetOrderBit(pbuf)						\
+	(*(unsigned short *)(pbuf) |=3D cpu_to_le16(_ORDER_))
+
+#define GetOrderBit(pbuf)		\
+	(((*(unsigned short *)(pbuf)) & le16_to_cpu(_ORDER_)) !=3D 0)
+
+
+/* struct rtw_ieee80211_ht_cap - HT additional information
+ *
+ * This structure refers to "HT information element" as
+ * described in 802.11n draft section 7.3.2.53
+ */
+struct ieee80211_ht_addt_info {
+	unsigned char	control_chan;
+	unsigned char	ht_param;
+	unsigned short	operation_mode;
+	unsigned short	stbc_param;
+	unsigned char	basic_set[16];
+} __packed;
+
+struct HT_caps_element {
+	union {
+		struct {
+			unsigned short	HT_caps_info;
+			unsigned char	AMPDU_para;
+			unsigned char	MCS_rate[16];
+			unsigned short	HT_ext_caps;
+			unsigned int	Beamforming_caps;
+			unsigned char	ASEL_caps;
+		} HT_cap_element;
+		unsigned char HT_cap[26];
+	} u;
+} __packed;
+
+struct HT_info_element {
+	unsigned char	primary_channel;
+	unsigned char	infos[5];
+	unsigned char	MCS_rate[16];
+}  __packed;
+
+struct AC_param {
+	unsigned char		ACI_AIFSN;
+	unsigned char		CW;
+	unsigned short	TXOP_limit;
+}  __packed;
+
+struct WMM_para_element {
+	unsigned char		QoS_info;
+	unsigned char		reserved;
+	struct AC_param	ac_param[4];
+}  __packed;
+
+struct ADDBA_request {
+	unsigned char		dialog_token;
+	unsigned short	BA_para_set;
+	unsigned short	BA_timeout_value;
+	unsigned short	BA_starting_seqctrl;
+}  __packed;
+
+
+#define OP_MODE_PURE                    0
+#define OP_MODE_MAY_BE_LEGACY_STAS      1
+#define OP_MODE_20MHZ_HT_STA_ASSOCED    2
+#define OP_MODE_MIXED                   3
+
+#define HT_INFO_HT_PARAM_SECONDARY_CHNL_OFF_MASK	((u8) BIT(0) | BIT(1)=
)
+#define HT_INFO_HT_PARAM_SECONDARY_CHNL_ABOVE		((u8) BIT(0))
+#define HT_INFO_HT_PARAM_SECONDARY_CHNL_BELOW		((u8) BIT(0) | BIT(1))
+#define HT_INFO_HT_PARAM_REC_TRANS_CHNL_WIDTH		((u8) BIT(2))
+#define HT_INFO_HT_PARAM_RIFS_MODE			((u8) BIT(3))
+#define HT_INFO_HT_PARAM_CTRL_ACCESS_ONLY		((u8) BIT(4))
+#define HT_INFO_HT_PARAM_SRV_INTERVAL_GRANULARITY	((u8) BIT(5))
+
+#define HT_INFO_OPERATION_MODE_OP_MODE_MASK	\
+		((u16) (0x0001 | 0x0002))
+#define HT_INFO_OPERATION_MODE_OP_MODE_OFFSET		0
+#define HT_INFO_OPERATION_MODE_NON_GF_DEVS_PRESENT	((u8) BIT(2))
+#define HT_INFO_OPERATION_MODE_TRANSMIT_BURST_LIMIT	((u8) BIT(3))
+#define HT_INFO_OPERATION_MODE_NON_HT_STA_PRESENT	((u8) BIT(4))
+
+#define HT_INFO_STBC_PARAM_DUAL_BEACON		((u16) BIT(6))
+#define HT_INFO_STBC_PARAM_DUAL_STBC_PROTECT	((u16) BIT(7))
+#define HT_INFO_STBC_PARAM_SECONDARY_BCN	((u16) BIT(8))
+#define HT_INFO_STBC_PARAM_LSIG_TXOP_PROTECT_ALLOWED	((u16) BIT(9))
+#define HT_INFO_STBC_PARAM_PCO_ACTIVE		((u16) BIT(10))
+#define HT_INFO_STBC_PARAM_PCO_PHASE		((u16) BIT(11))
+
+
+
+/*	=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DWPS Section=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/*	For WPSv1.0 */
+#define WPSOUI					0x0050f204
+/*	WPS attribute ID */
+#define WPS_ATTR_VER1				0x104A
+#define WPS_ATTR_SIMPLE_CONF_STATE		0x1044
+#define WPS_ATTR_RESP_TYPE			0x103B
+#define WPS_ATTR_UUID_E				0x1047
+#define WPS_ATTR_MANUFACTURER			0x1021
+#define WPS_ATTR_MODEL_NAME			0x1023
+#define WPS_ATTR_MODEL_NUMBER			0x1024
+#define WPS_ATTR_SERIAL_NUMBER			0x1042
+#define WPS_ATTR_PRIMARY_DEV_TYPE		0x1054
+#define WPS_ATTR_SEC_DEV_TYPE_LIST		0x1055
+#define WPS_ATTR_DEVICE_NAME			0x1011
+#define WPS_ATTR_CONF_METHOD			0x1008
+#define WPS_ATTR_RF_BANDS			0x103C
+#define WPS_ATTR_DEVICE_PWID			0x1012
+#define WPS_ATTR_REQUEST_TYPE			0x103A
+#define WPS_ATTR_ASSOCIATION_STATE		0x1002
+#define WPS_ATTR_CONFIG_ERROR			0x1009
+#define WPS_ATTR_VENDOR_EXT			0x1049
+#define WPS_ATTR_SELECTED_REGISTRAR		0x1041
+
+/*	Value of WPS attribute "WPS_ATTR_DEVICE_NAME */
+#define WPS_MAX_DEVICE_NAME_LEN			32
+
+/*	Value of WPS Request Type Attribute */
+#define WPS_REQ_TYPE_ENROLLEE_INFO_ONLY		0x00
+#define WPS_REQ_TYPE_ENROLLEE_OPEN_8021X	0x01
+#define WPS_REQ_TYPE_REGISTRAR			0x02
+#define WPS_REQ_TYPE_WLAN_MANAGER_REGISTRAR	0x03
+
+/*	Value of WPS Response Type Attribute */
+#define WPS_RESPONSE_TYPE_INFO_ONLY		0x00
+#define WPS_RESPONSE_TYPE_8021X			0x01
+#define WPS_RESPONSE_TYPE_REGISTRAR		0x02
+#define WPS_RESPONSE_TYPE_AP			0x03
+
+/*	Value of WPS WiFi Simple Configuration State Attribute */
+#define WPS_WSC_STATE_NOT_CONFIG		0x01
+#define WPS_WSC_STATE_CONFIG			0x02
+
+/*	Value of WPS Version Attribute */
+#define WPS_VERSION_1				0x10
+
+/*	Value of WPS Configuration Method Attribute */
+#define WPS_CONFIG_METHOD_FLASH			0x0001
+#define WPS_CONFIG_METHOD_ETHERNET		0x0002
+#define WPS_CONFIG_METHOD_LABEL			0x0004
+#define WPS_CONFIG_METHOD_DISPLAY		0x0008
+#define WPS_CONFIG_METHOD_E_NFC			0x0010
+#define WPS_CONFIG_METHOD_I_NFC			0x0020
+#define WPS_CONFIG_METHOD_NFC			0x0040
+#define WPS_CONFIG_METHOD_PBC			0x0080
+#define WPS_CONFIG_METHOD_KEYPAD		0x0100
+#define WPS_CONFIG_METHOD_VPBC			0x0280
+#define WPS_CONFIG_METHOD_PPBC			0x0480
+#define WPS_CONFIG_METHOD_VDISPLAY		0x2008
+#define WPS_CONFIG_METHOD_PDISPLAY		0x4008
+
+/*	Value of Category ID of WPS Primary Device Type Attribute */
+#define WPS_PDT_CID_DISPLAYS			0x0007
+#define WPS_PDT_CID_MULIT_MEDIA			0x0008
+#define WPS_PDT_CID_RTK_WIDI			WPS_PDT_CID_MULIT_MEDIA
+
+/*	Value of Sub Category ID of WPS Primary Device Type Attribute */
+#define WPS_PDT_SCID_MEDIA_SERVER		0x0005
+#define WPS_PDT_SCID_RTK_DMP			WPS_PDT_SCID_MEDIA_SERVER
+
+/*	Value of Device Password ID */
+#define WPS_DPID_PIN				0x0000
+#define WPS_DPID_USER_SPEC			0x0001
+#define WPS_DPID_MACHINE_SPEC			0x0002
+#define WPS_DPID_REKEY				0x0003
+#define WPS_DPID_PBC				0x0004
+#define WPS_DPID_REGISTRAR_SPEC			0x0005
+
+/*	Value of WPS RF Bands Attribute */
+#define WPS_RF_BANDS_2_4_GHZ			0x01
+#define WPS_RF_BANDS_5_GHZ			0x02
+
+/*	Value of WPS Association State Attribute */
+#define WPS_ASSOC_STATE_NOT_ASSOCIATED		0x00
+#define WPS_ASSOC_STATE_CONNECTION_SUCCESS	0x01
+#define WPS_ASSOC_STATE_CONFIGURATION_FAILURE	0x02
+#define WPS_ASSOC_STATE_ASSOCIATION_FAILURE	0x03
+#define WPS_ASSOC_STATE_IP_FAILURE		0x04
+
+/*	=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DP2P =
Section=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =
*/
+/*	For P2P */
+#define	P2POUI					0x506F9A09
+
+/*	P2P Attribute ID */
+#define	P2P_ATTR_STATUS				0x00
+#define	P2P_ATTR_MINOR_REASON_CODE		0x01
+#define	P2P_ATTR_CAPABILITY			0x02
+#define	P2P_ATTR_DEVICE_ID			0x03
+#define	P2P_ATTR_GO_INTENT			0x04
+#define	P2P_ATTR_CONF_TIMEOUT			0x05
+#define	P2P_ATTR_LISTEN_CH			0x06
+#define	P2P_ATTR_GROUP_BSSID			0x07
+#define	P2P_ATTR_EX_LISTEN_TIMING		0x08
+#define	P2P_ATTR_INTENTED_IF_ADDR		0x09
+#define	P2P_ATTR_MANAGEABILITY			0x0A
+#define	P2P_ATTR_CH_LIST			0x0B
+#define	P2P_ATTR_NOA				0x0C
+#define	P2P_ATTR_DEVICE_INFO			0x0D
+#define	P2P_ATTR_GROUP_INFO			0x0E
+#define	P2P_ATTR_GROUP_ID			0x0F
+#define	P2P_ATTR_INTERFACE			0x10
+#define	P2P_ATTR_OPERATING_CH			0x11
+#define	P2P_ATTR_INVITATION_FLAGS		0x12
+
+/*	Value of Status Attribute */
+#define	P2P_STATUS_SUCCESS			0x00
+#define	P2P_STATUS_FAIL_INFO_UNAVAILABLE	0x01
+#define	P2P_STATUS_FAIL_INCOMPATIBLE_PARAM	0x02
+#define	P2P_STATUS_FAIL_LIMIT_REACHED		0x03
+#define	P2P_STATUS_FAIL_INVALID_PARAM		0x04
+#define	P2P_STATUS_FAIL_REQUEST_UNABLE		0x05
+#define	P2P_STATUS_FAIL_PREVOUS_PROTO_ERR	0x06
+#define	P2P_STATUS_FAIL_NO_COMMON_CH		0x07
+#define	P2P_STATUS_FAIL_UNKNOWN_P2PGROUP	0x08
+#define	P2P_STATUS_FAIL_BOTH_GOINTENT_15	0x09
+#define	P2P_STATUS_FAIL_INCOMPATIBLE_PROVSION	0x0A
+#define	P2P_STATUS_FAIL_USER_REJECT		0x0B
+
+/*	Value of Inviation Flags Attribute */
+#define	P2P_INVITATION_FLAGS_PERSISTENT		BIT(0)
+
+#define	DMP_P2P_DEVCAP_SUPPORT	(P2P_DEVCAP_SERVICE_DISCOVERY | \
+				 P2P_DEVCAP_CLIENT_DISCOVERABILITY | \
+				 P2P_DEVCAP_CONCURRENT_OPERATION | \
+				 P2P_DEVCAP_INVITATION_PROC)
+
+#define	DMP_P2P_GRPCAP_SUPPORT	(P2P_GRPCAP_INTRABSS)
+
+/*	Value of Device Capability Bitmap */
+#define	P2P_DEVCAP_SERVICE_DISCOVERY		BIT(0)
+#define	P2P_DEVCAP_CLIENT_DISCOVERABILITY	BIT(1)
+#define	P2P_DEVCAP_CONCURRENT_OPERATION		BIT(2)
+#define	P2P_DEVCAP_INFRA_MANAGED		BIT(3)
+#define	P2P_DEVCAP_DEVICE_LIMIT			BIT(4)
+#define	P2P_DEVCAP_INVITATION_PROC		BIT(5)
+
+/*	Value of Group Capability Bitmap */
+#define	P2P_GRPCAP_GO				BIT(0)
+#define	P2P_GRPCAP_PERSISTENT_GROUP		BIT(1)
+#define	P2P_GRPCAP_GROUP_LIMIT			BIT(2)
+#define	P2P_GRPCAP_INTRABSS			BIT(3)
+#define	P2P_GRPCAP_CROSS_CONN			BIT(4)
+#define	P2P_GRPCAP_PERSISTENT_RECONN		BIT(5)
+#define	P2P_GRPCAP_GROUP_FORMATION		BIT(6)
+
+/*	P2P Public Action Frame ( Management Frame ) */
+#define	P2P_PUB_ACTION_ACTION			0x09
+
+/*	P2P Public Action Frame Type */
+#define	P2P_GO_NEGO_REQ				0
+#define	P2P_GO_NEGO_RESP			1
+#define	P2P_GO_NEGO_CONF			2
+#define	P2P_INVIT_REQ				3
+#define	P2P_INVIT_RESP				4
+#define	P2P_DEVDISC_REQ				5
+#define	P2P_DEVDISC_RESP			6
+#define	P2P_PROVISION_DISC_REQ			7
+#define	P2P_PROVISION_DISC_RESP			8
+
+/*	P2P Action Frame Type */
+#define	P2P_NOTICE_OF_ABSENCE			0
+#define	P2P_PRESENCE_REQUEST			1
+#define	P2P_PRESENCE_RESPONSE			2
+#define	P2P_GO_DISC_REQUEST			3
+
+
+#define	P2P_MAX_PERSISTENT_GROUP_NUM		10
+
+#define	P2P_PROVISIONING_SCAN_CNT		3
+
+#define	P2P_WILDCARD_SSID_LEN			7
+
+#define	P2P_FINDPHASE_EX_NONE			0	/*  default value, used when: (1)p2p=
 disabed or (2)p2p enabled but only do 1 scan phase */
+#define	P2P_FINDPHASE_EX_FULL			1	/*  used when p2p enabled and want t=
o do 1 scan phase and P2P_FINDPHASE_EX_MAX-1 find phase */
+#define	P2P_FINDPHASE_EX_SOCIAL_FIRST		(P2P_FINDPHASE_EX_FULL+1)
+#define	P2P_FINDPHASE_EX_MAX					4
+#define	P2P_FINDPHASE_EX_SOCIAL_LAST		P2P_FINDPHASE_EX_MAX
+
+#define	P2P_PROVISION_TIMEOUT			5000	/*5 sec timeout for sending the p=
rovision discovery request */
+#define	P2P_CONCURRENT_PROVISION_TIMEOUT	3000	/*3 sec timeout for send=
ing the provision discovery request under concurrent mode */
+#define	P2P_GO_NEGO_TIMEOUT			5000	/*5 sec timeout for receiving the g=
roup negotation response */
+#define	P2P_CONCURRENT_GO_NEGO_TIMEOUT		3000	/*3 sec timeout for sendi=
ng the negotiation request under concurrent mode */
+#define	P2P_TX_PRESCAN_TIMEOUT			100	/*100ms */
+#define	P2P_INVITE_TIMEOUT			5000	/*5 sec timeout for sending the invi=
tation request */
+#define	P2P_CONCURRENT_INVITE_TIMEOUT		3000	/*3 sec timeout for sendin=
g the invitation request under concurrent mode */
+#define	P2P_RESET_SCAN_CH			25000	/*25 sec t/o to reset the scan chann=
el ( based on channel plan ) */
+#define	P2P_MAX_INTENT				15
+
+#define	P2P_MAX_NOA_NUM				2
+
+/*	WPS Configuration Method */
+#define	WPS_CM_NONE					0x0000
+#define	WPS_CM_LABEL					0x0004
+#define	WPS_CM_DISPLYA					0x0008
+#define	WPS_CM_EXTERNAL_NFC_TOKEN			0x0010
+#define	WPS_CM_INTEGRATED_NFC_TOKEN			0x0020
+#define	WPS_CM_NFC_INTERFACE				0x0040
+#define	WPS_CM_PUSH_BUTTON				0x0080
+#define	WPS_CM_KEYPAD					0x0100
+#define	WPS_CM_SW_PUHS_BUTTON				0x0280
+#define	WPS_CM_HW_PUHS_BUTTON				0x0480
+#define	WPS_CM_SW_DISPLAY_PIN				0x2008
+#define	WPS_CM_LCD_DISPLAY_PIN				0x4008
+
+enum P2P_ROLE {
+	P2P_ROLE_DISABLE =3D 0,
+	P2P_ROLE_DEVICE =3D 1,
+	P2P_ROLE_CLIENT =3D 2,
+	P2P_ROLE_GO =3D 3
+};
+
+enum P2P_STATE {
+	P2P_STATE_NONE =3D 0,			/*P2P disable */
+	P2P_STATE_IDLE =3D 1,			/*P2P had enabled and do nothing */
+	P2P_STATE_LISTEN =3D 2,			/*In pure listen state */
+	P2P_STATE_SCAN =3D 3,			/*In scan phase */
+	P2P_STATE_FIND_PHASE_LISTEN =3D 4,	/*In the listen state of find phas=
e */
+	P2P_STATE_FIND_PHASE_SEARCH =3D 5,	/*In the search state of find phas=
e */
+	P2P_STATE_TX_PROVISION_DIS_REQ =3D 6,	/*In P2P provisioning discovery=
 */
+	P2P_STATE_RX_PROVISION_DIS_RSP =3D 7,
+	P2P_STATE_RX_PROVISION_DIS_REQ =3D 8,
+	P2P_STATE_GONEGO_ING =3D 9,		/*Doing the group owner negoitation hand=
shake */
+	P2P_STATE_GONEGO_OK =3D 10,		/*finish the group negoitation handshake=
 with success */
+	P2P_STATE_GONEGO_FAIL =3D 11,		/*finish the group negoitation handsha=
ke with failure */
+	P2P_STATE_RECV_INVITE_REQ_MATCH =3D 12,	/*receiving the P2P Inviation=
 request and match with the profile. */
+	P2P_STATE_PROVISIONING_ING =3D 13,	/*Doing the P2P WPS */
+	P2P_STATE_PROVISIONING_DONE =3D 14,	/*Finish the P2P WPS */
+	P2P_STATE_TX_INVITE_REQ =3D 15,		/*Transmit the P2P Invitation reques=
t */
+	P2P_STATE_RX_INVITE_RESP_OK =3D 16,	/*Receiving the P2P Invitation re=
sponse */
+	P2P_STATE_RECV_INVITE_REQ_DISMATCH =3D 17,/*receiving the P2P Inviati=
on request and dismatch with the profile. */
+	P2P_STATE_RECV_INVITE_REQ_GO =3D 18,	/*receiving the P2P Inviation re=
quest and this wifi is GO. */
+	P2P_STATE_RECV_INVITE_REQ_JOIN =3D 19,	/*receiving the P2P Inviation =
request to join an existing P2P Group. */
+	P2P_STATE_RX_INVITE_RESP_FAIL =3D 20,	/*receiving the P2P Inviation r=
esponse with failure */
+	P2P_STATE_RX_INFOR_NOREADY =3D 21,	/*receiving p2p negotiation respon=
se with information is not available */
+	P2P_STATE_TX_INFOR_NOREADY =3D 22,	/*sending p2p negotiation response=
 with information is not available */
+};
+
+enum P2P_WPSINFO {
+	P2P_NO_WPSINFO				=3D 0,
+	P2P_GOT_WPSINFO_PEER_DISPLAY_PIN	=3D 1,
+	P2P_GOT_WPSINFO_SELF_DISPLAY_PIN	=3D 2,
+	P2P_GOT_WPSINFO_PBC			=3D 3,
+};
+
+#define	P2P_PRIVATE_IOCTL_SET_LEN		64
+
+enum P2P_PROTO_WK_ID {
+	P2P_FIND_PHASE_WK =3D 0,
+	P2P_RESTORE_STATE_WK =3D 1,
+	P2P_PRE_TX_PROVDISC_PROCESS_WK =3D 2,
+	P2P_PRE_TX_NEGOREQ_PROCESS_WK =3D 3,
+	P2P_PRE_TX_INVITEREQ_PROCESS_WK =3D 4,
+	P2P_AP_P2P_CH_SWITCH_PROCESS_WK =3D 5,
+	P2P_RO_CH_WK =3D 6,
+};
+
+#ifdef CONFIG_8723AU_P2P
+enum P2P_PS_STATE {
+	P2P_PS_DISABLE =3D 0,
+	P2P_PS_ENABLE =3D 1,
+	P2P_PS_SCAN =3D 2,
+	P2P_PS_SCAN_DONE =3D 3,
+	P2P_PS_ALLSTASLEEP =3D 4, /*  for P2P GO */
+};
+
+enum P2P_PS_MODE {
+	P2P_PS_NONE =3D 0,
+	P2P_PS_CTWINDOW =3D 1,
+	P2P_PS_NOA	 =3D 2,
+	P2P_PS_MIX =3D 3, /*  CTWindow and NoA */
+};
+#endif /*  CONFIG_8723AU_P2P */
+
+/*	=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DWFD =
Section=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =
*/
+/*	For Wi-Fi Display */
+#define	WFD_ATTR_DEVICE_INFO			0x00
+#define	WFD_ATTR_ASSOC_BSSID			0x01
+#define	WFD_ATTR_COUPLED_SINK_INFO	0x06
+#define	WFD_ATTR_LOCAL_IP_ADDR		0x08
+#define	WFD_ATTR_SESSION_INFO		0x09
+#define	WFD_ATTR_ALTER_MAC			0x0a
+
+/*	For WFD Device Information Attribute */
+#define	WFD_DEVINFO_SOURCE					0x0000
+#define	WFD_DEVINFO_PSINK					0x0001
+#define	WFD_DEVINFO_SSINK					0x0002
+#define	WFD_DEVINFO_DUAL					0x0003
+
+#define	WFD_DEVINFO_SESSION_AVAIL			0x0010
+#define	WFD_DEVINFO_WSD						0x0040
+#define	WFD_DEVINFO_PC_TDLS					0x0080
+#define	WFD_DEVINFO_HDCP_SUPPORT			0x0100
+
+#endif /*  _WIFI_H_ */
diff --git a/drivers/staging/rtl8723au/include/wlan_bssdef.h b/drivers/=
staging/rtl8723au/include/wlan_bssdef.h
new file mode 100644
index 0000000..92287eb
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/wlan_bssdef.h
@@ -0,0 +1,215 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __WLAN_BSSDEF_H__
+#define __WLAN_BSSDEF_H__
+
+
+#define MAX_IE_SZ	768
+
+
+#define NDIS_802_11_LENGTH_RATES        8
+#define NDIS_802_11_LENGTH_RATES_EX     16
+
+enum ndis_802_11_net_type {
+	Ndis802_11FH,
+	Ndis802_11DS,
+	Ndis802_11OFDM5,
+	Ndis802_11OFDM24,
+	Ndis802_11NetworkTypeMax    /*  just an upper bound */
+};
+
+struct ndis_802_11_configuration_fh {
+	u32           Length;             /*  Length of structure */
+	u32           HopPattern;         /*  As defined by 802.11, MSB set *=
/
+	u32           HopSet;             /*  to one if non-802.11 */
+	u32           DwellTime;          /*  units are Kusec */
+};
+
+
+/*
+	FW will only save the channel number in DSConfig.
+	ODI Handler will convert the channel number to freq. number.
+*/
+struct ndis_802_11_config {
+	u32           Length;             /*  Length of structure */
+	u32           BeaconPeriod;       /*  units are Kusec */
+	u32           ATIMWindow;         /*  units are Kusec */
+	u32           DSConfig;           /*  Frequency, units are kHz */
+	struct ndis_802_11_configuration_fh    FHConfig;
+};
+
+enum ndis_802_11_net_infra {
+	Ndis802_11IBSS,
+	Ndis802_11Infrastructure,
+	Ndis802_11AutoUnknown,
+	Ndis802_11InfrastructureMax,     /*  Not a real value, defined as upp=
er bound */
+	Ndis802_11APMode
+};
+
+struct ndis_802_11_fixed_ies {
+	u8  Timestamp[8];
+	u16  BeaconInterval;
+	u16  Capabilities;
+};
+
+struct ndis_802_11_var_ies {
+	u8  ElementID;
+	u8  Length;
+	u8  data[1];
+};
+
+/* Length is the 4 bytes multiples of the sum of
+ * sizeof(6 * sizeof(unsigned char)) + 2 + sizeof(struct ndis_802_11_s=
sid) +
+ * sizeof(u32) + sizeof(long) + sizeof(enum ndis_802_11_net_type) +
+ * sizeof(struct ndis_802_11_config) + sizeof(sizeof(unsigned char) *
+ * NDIS_802_11_LENGTH_RATES_EX) + IELength
+ *
+ * Except the IELength, all other fields are fixed length. Therefore,
+ * we can define a macro to present the partial sum.
+ */
+
+enum ndis_802_11_auth_mode {
+	Ndis802_11AuthModeOpen,
+	Ndis802_11AuthModeShared,
+	Ndis802_11AuthModeAutoSwitch,
+	Ndis802_11AuthModeWPA,
+	Ndis802_11AuthModeWPAPSK,
+	Ndis802_11AuthModeWPANone,
+	dis802_11AuthModeMax       /*  upper bound */
+};
+
+enum  {
+	Ndis802_11WEPEnabled,
+	Ndis802_11Encryption1Enabled =3D Ndis802_11WEPEnabled,
+	Ndis802_11WEPDisabled,
+	Ndis802_11EncryptionDisabled =3D Ndis802_11WEPDisabled,
+	Ndis802_11WEPKeyAbsent,
+	Ndis802_11Encryption1KeyAbsent =3D Ndis802_11WEPKeyAbsent,
+	Ndis802_11WEPNotSupported,
+	Ndis802_11EncryptionNotSupported =3D Ndis802_11WEPNotSupported,
+	Ndis802_11Encryption2Enabled,
+	Ndis802_11Encryption2KeyAbsent,
+	Ndis802_11Encryption3Enabled,
+	Ndis802_11Encryption3KeyAbsent,
+};
+
+/*  Key mapping keys require a BSSID */
+struct ndis_802_11_key {
+	u32 Length;             /*  Length of this structure */
+	u32 KeyIndex;
+	u32 KeyLength;          /*  length of key in bytes */
+	unsigned char BSSID[6];
+	unsigned long long KeyRSC;
+	u8 KeyMaterial[32]; /*  variable length depending on above field */
+};
+
+struct ndis_802_11_wep {
+	u32     Length;        /*  Length of this structure */
+	u32     KeyIndex;      /*  0 is the per-client key, 1-N are global */
+	u32     KeyLength;     /*  length of key in bytes */
+	u8     KeyMaterial[16];/*  variable length depending on above field *=
/
+};
+
+enum NDIS_802_11_STATUS_TYPE {
+	Ndis802_11StatusType_Authentication,
+	Ndis802_11StatusType_MediaStreamMode,
+	Ndis802_11StatusType_PMKID_CandidateList,
+	Ndis802_11StatusTypeMax    /*  not a real type, just an upper bound *=
/
+};
+
+/*  mask for authentication/integrity fields */
+#define NDIS_802_11_AUTH_REQUEST_AUTH_FIELDS        0x0f
+#define NDIS_802_11_AUTH_REQUEST_REAUTH			0x01
+#define NDIS_802_11_AUTH_REQUEST_KEYUPDATE		0x02
+#define NDIS_802_11_AUTH_REQUEST_PAIRWISE_ERROR		0x06
+#define NDIS_802_11_AUTH_REQUEST_GROUP_ERROR		0x0E
+
+/*  MIC check time, 60 seconds. */
+#define MIC_CHECK_TIME	60000000
+
+#ifndef Ndis802_11APMode
+#define Ndis802_11APMode (Ndis802_11InfrastructureMax+1)
+#endif
+
+struct wlan_phy_info {
+	u8	SignalStrength;/* in percentage) */
+	u8	SignalQuality;/* in percentage) */
+	u8	Optimum_antenna;  /* for Antenna diversity */
+	u8	Reserved_0;
+};
+
+struct wlan_bcn_info {
+	/* these infor get from rtw_get_encrypt_info when
+	 *	 * translate scan to UI */
+	u8 encryp_protocol;/* ENCRYP_PROTOCOL_E: OPEN/WEP/WPA/WPA2 */
+	int group_cipher; /* WPA/WPA2 group cipher */
+	int pairwise_cipher;/* WPA/WPA2/WEP pairwise cipher */
+	int is_8021x;
+
+	/* bwmode 20/40 and ch_offset UP/LOW */
+	unsigned short	ht_cap_info;
+	unsigned char	ht_info_infos_0;
+};
+
+struct wlan_bssid_ex {
+	u32  Length;
+	u8 MacAddress[ETH_ALEN];
+	u16 reserved;
+	struct cfg80211_ssid Ssid;
+	u32  Privacy;
+	long  Rssi;/* in dBM, raw data , get from PHY) */
+	enum ndis_802_11_net_type  NetworkTypeInUse;
+	struct ndis_802_11_config  Configuration;
+	enum ndis_802_11_net_infra  InfrastructureMode;
+	unsigned char SupportedRates[NDIS_802_11_LENGTH_RATES_EX];
+	struct wlan_phy_info	PhyInfo;
+	u32  IELength;
+	u8  IEs[MAX_IE_SZ]; /* timestamp, beacon interval, and capability inf=
o*/
+} __packed;
+
+static inline uint get_wlan_bssid_ex_sz(struct wlan_bssid_ex *bss)
+{
+	return sizeof(struct wlan_bssid_ex) - MAX_IE_SZ + bss->IELength;
+}
+
+struct	wlan_network {
+	struct list_head	list;
+	int	network_type;	/* refer to ieee80211.h for 11A/B/G */
+	/*  set to fixed when not to be removed as site-surveying */
+	int	fixed;
+	unsigned long	last_scanned; /* timestamp for the network */
+	int	aid;		/* will only be valid when a BSS is joined. */
+	int	join_res;
+	struct wlan_bssid_ex	network; /* must be the last item */
+	struct wlan_bcn_info	BcnInfo;
+};
+
+enum VRTL_CARRIER_SENSE {
+	DISABLE_VCS,
+	ENABLE_VCS,
+	AUTO_VCS
+};
+
+enum VCS_TYPE {
+	NONE_VCS,
+	RTS_CTS,
+	CTS_TO_SELF
+};
+
+/* john */
+#define NUM_PRE_AUTH_KEY 16
+#define NUM_PMKID_CACHE NUM_PRE_AUTH_KEY
+
+#endif /* ifndef WLAN_BSSDEF_H_ */
diff --git a/drivers/staging/rtl8723au/include/xmit_osdep.h b/drivers/s=
taging/rtl8723au/include/xmit_osdep.h
new file mode 100644
index 0000000..0eca53e
--- /dev/null
+++ b/drivers/staging/rtl8723au/include/xmit_osdep.h
@@ -0,0 +1,57 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licens=
e for
+ * more details.
+ *
+ *********************************************************************=
*********/
+#ifndef __XMIT_OSDEP_H_
+#define __XMIT_OSDEP_H_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+struct pkt_file {
+	struct sk_buff *pkt;
+	__kernel_size_t pkt_len; /* the remainder length of the open_file */
+	unsigned char *cur_buffer;
+	u8 *buf_start;
+	u8 *cur_addr;
+	__kernel_size_t buf_len;
+};
+
+
+#define NR_XMITFRAME	256
+
+struct xmit_priv;
+struct pkt_attrib;
+struct sta_xmit_priv;
+struct xmit_frame;
+struct xmit_buf;
+
+int rtw_xmit23a_entry23a(struct sk_buff *pkt, struct net_device *pnetd=
ev);
+
+void rtw_os_xmit_schedule23a(struct rtw_adapter *padapter);
+
+int rtw_os_xmit_resource_alloc23a(struct rtw_adapter *padapter,
+			       struct xmit_buf *pxmitbuf, u32 alloc_sz);
+void rtw_os_xmit_resource_free23a(struct rtw_adapter *padapter,
+			       struct xmit_buf *pxmitbuf);
+uint rtw_remainder_len23a(struct pkt_file *pfile);
+void _rtw_open_pktfile23a(struct sk_buff *pkt, struct pkt_file *pfile)=
;
+uint _rtw_pktfile_read23a(struct pkt_file *pfile, u8 *rmem, uint rlen)=
;
+int rtw_endofpktfile23a(struct pkt_file *pfile);
+
+void rtw_os_pkt_complete23a(struct rtw_adapter *padapter, struct sk_bu=
ff *pkt);
+void rtw_os_xmit_complete23a(struct rtw_adapter *padapter,
+			  struct xmit_frame *pxframe);
+int netdev_open23a(struct net_device *pnetdev);
+
+#endif /* __XMIT_OSDEP_H_ */
--=20
1.8.4.5
