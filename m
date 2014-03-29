From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/6 NEXT] staging: r8723au: Add source files for new driver - part 2
Date: Fri, 28 Mar 2014 21:37:39 -0500
Message-ID: <1396060663-3589-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1396060663-3589-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Jes Sorensen <Jes.Sorensen@redhat.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:34164 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbaC2CiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 22:38:21 -0400
Received: by mail-ob0-f172.google.com with SMTP id wm4so6864766obc.3
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 19:38:20 -0700 (PDT)
In-Reply-To: <1396060663-3589-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Realtek USB device RTL8723AU is found in Lenovo Yoga 13 tablets.
A driver for it has been available in a GitHub repo for several months.
This commit contains the second part of the source files. The source
is arbitrarily split to avoid E-mail files that are too large.

Jes Sorensen at RedHat has made many improvements to the vendor code,
and he has been doing the testing. I do not have access to this device.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Jes Sorensen <Jes.Sorensen@redhat.com>
---
 drivers/staging/rtl8723au/hal/Hal8723PwrSeq.c      |    80 +
 drivers/staging/rtl8723au/hal/Hal8723UHWImg_CE.c   |   136 +
 .../staging/rtl8723au/hal/HalDMOutSrc8723A_CE.c    |  1063 ++
 drivers/staging/rtl8723au/hal/HalHWImg8723A_BB.c   |   726 ++
 drivers/staging/rtl8723au/hal/HalHWImg8723A_MAC.c  |   188 +
 drivers/staging/rtl8723au/hal/HalHWImg8723A_RF.c   |   259 +
 drivers/staging/rtl8723au/hal/HalPwrSeqCmd.c       |   163 +
 drivers/staging/rtl8723au/hal/hal_com.c            |   881 ++
 drivers/staging/rtl8723au/hal/hal_intf.c           |   418 +
 drivers/staging/rtl8723au/hal/odm.c                |  2090 ++++
 drivers/staging/rtl8723au/hal/odm_HWConfig.c       |   481 +
 drivers/staging/rtl8723au/hal/odm_RegConfig8723A.c |   162 +
 drivers/staging/rtl8723au/hal/odm_debug.c          |    24 +
 drivers/staging/rtl8723au/hal/odm_interface.c      |   236 +
 .../staging/rtl8723au/hal/rtl8723a_bt-coexist.c    | 11304 +++++++++++=
++++++++
 drivers/staging/rtl8723au/hal/rtl8723a_cmd.c       |   845 ++
 drivers/staging/rtl8723au/hal/rtl8723a_dm.c        |   273 +
 drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c  |  3452 ++++++
 drivers/staging/rtl8723au/hal/rtl8723a_phycfg.c    |  1197 ++
 drivers/staging/rtl8723au/hal/rtl8723a_rf6052.c    |   515 +
 drivers/staging/rtl8723au/hal/rtl8723a_rxdesc.c    |    69 +
 drivers/staging/rtl8723au/hal/rtl8723a_sreset.c    |    73 +
 drivers/staging/rtl8723au/hal/rtl8723a_xmit.c      |    52 +
 drivers/staging/rtl8723au/hal/rtl8723au_led.c      |   113 +
 drivers/staging/rtl8723au/hal/rtl8723au_recv.c     |   247 +
 drivers/staging/rtl8723au/hal/rtl8723au_xmit.c     |   548 +
 drivers/staging/rtl8723au/hal/usb_halinit.c        |  1834 +++
 drivers/staging/rtl8723au/hal/usb_ops_linux.c      |   848 ++
 28 files changed, 28277 insertions(+)
 create mode 100644 drivers/staging/rtl8723au/hal/Hal8723PwrSeq.c
 create mode 100644 drivers/staging/rtl8723au/hal/Hal8723UHWImg_CE.c
 create mode 100644 drivers/staging/rtl8723au/hal/HalDMOutSrc8723A_CE.c
 create mode 100644 drivers/staging/rtl8723au/hal/HalHWImg8723A_BB.c
 create mode 100644 drivers/staging/rtl8723au/hal/HalHWImg8723A_MAC.c
 create mode 100644 drivers/staging/rtl8723au/hal/HalHWImg8723A_RF.c
 create mode 100644 drivers/staging/rtl8723au/hal/HalPwrSeqCmd.c
 create mode 100644 drivers/staging/rtl8723au/hal/hal_com.c
 create mode 100644 drivers/staging/rtl8723au/hal/hal_intf.c
 create mode 100644 drivers/staging/rtl8723au/hal/odm.c
 create mode 100644 drivers/staging/rtl8723au/hal/odm_HWConfig.c
 create mode 100644 drivers/staging/rtl8723au/hal/odm_RegConfig8723A.c
 create mode 100644 drivers/staging/rtl8723au/hal/odm_debug.c
 create mode 100644 drivers/staging/rtl8723au/hal/odm_interface.c
 create mode 100644 drivers/staging/rtl8723au/hal/rtl8723a_bt-coexist.c
 create mode 100644 drivers/staging/rtl8723au/hal/rtl8723a_cmd.c
 create mode 100644 drivers/staging/rtl8723au/hal/rtl8723a_dm.c
 create mode 100644 drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c
 create mode 100644 drivers/staging/rtl8723au/hal/rtl8723a_phycfg.c
 create mode 100644 drivers/staging/rtl8723au/hal/rtl8723a_rf6052.c
 create mode 100644 drivers/staging/rtl8723au/hal/rtl8723a_rxdesc.c
 create mode 100644 drivers/staging/rtl8723au/hal/rtl8723a_sreset.c
 create mode 100644 drivers/staging/rtl8723au/hal/rtl8723a_xmit.c
 create mode 100644 drivers/staging/rtl8723au/hal/rtl8723au_led.c
 create mode 100644 drivers/staging/rtl8723au/hal/rtl8723au_recv.c
 create mode 100644 drivers/staging/rtl8723au/hal/rtl8723au_xmit.c
 create mode 100644 drivers/staging/rtl8723au/hal/usb_halinit.c
 create mode 100644 drivers/staging/rtl8723au/hal/usb_ops_linux.c

diff --git a/drivers/staging/rtl8723au/hal/Hal8723PwrSeq.c b/drivers/st=
aging/rtl8723au/hal/Hal8723PwrSeq.c
new file mode 100644
index 0000000..747f86c
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/Hal8723PwrSeq.c
@@ -0,0 +1,80 @@
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
+
+#include "Hal8723PwrSeq.h"
+
+/*
+    drivers should parse below arrays and do the corresponding actions
+*/
+/* 3 Power on  Array */
+struct wlan_pwr_cfg rtl8723AU_power_on_flow[RTL8723A_TRANS_CARDEMU_TO_=
ACT_STEPS+RTL8723A_TRANS_END_STEPS] =3D {
+	RTL8723A_TRANS_CARDEMU_TO_ACT
+	RTL8723A_TRANS_END
+};
+
+/* 3 Radio off GPIO Array */
+struct wlan_pwr_cfg rtl8723AU_radio_off_flow[RTL8723A_TRANS_ACT_TO_CAR=
DEMU_STEPS+RTL8723A_TRANS_END_STEPS] =3D {
+	RTL8723A_TRANS_ACT_TO_CARDEMU
+	RTL8723A_TRANS_END
+};
+
+/* 3 Card Disable Array */
+struct wlan_pwr_cfg rtl8723AU_card_disable_flow[RTL8723A_TRANS_ACT_TO_=
CARDEMU_STEPS+RTL8723A_TRANS_CARDEMU_TO_PDN_STEPS+RTL8723A_TRANS_END_ST=
EPS] =3D {
+	RTL8723A_TRANS_ACT_TO_CARDEMU
+	RTL8723A_TRANS_CARDEMU_TO_CARDDIS
+	RTL8723A_TRANS_END
+};
+
+/* 3 Card Enable Array */
+struct wlan_pwr_cfg rtl8723AU_card_enable_flow[RTL8723A_TRANS_ACT_TO_C=
ARDEMU_STEPS+RTL8723A_TRANS_CARDEMU_TO_PDN_STEPS+RTL8723A_TRANS_END_STE=
PS] =3D {
+	RTL8723A_TRANS_CARDDIS_TO_CARDEMU
+	RTL8723A_TRANS_CARDEMU_TO_ACT
+	RTL8723A_TRANS_END
+};
+
+/* 3 Suspend Array */
+struct wlan_pwr_cfg rtl8723AU_suspend_flow[RTL8723A_TRANS_ACT_TO_CARDE=
MU_STEPS+RTL8723A_TRANS_CARDEMU_TO_SUS_STEPS+RTL8723A_TRANS_END_STEPS] =
=3D {
+	RTL8723A_TRANS_ACT_TO_CARDEMU
+	RTL8723A_TRANS_CARDEMU_TO_SUS
+	RTL8723A_TRANS_END
+};
+
+/* 3 Resume Array */
+struct wlan_pwr_cfg rtl8723AU_resume_flow[RTL8723A_TRANS_ACT_TO_CARDEM=
U_STEPS+RTL8723A_TRANS_CARDEMU_TO_SUS_STEPS+RTL8723A_TRANS_END_STEPS] =3D=
 {
+	RTL8723A_TRANS_SUS_TO_CARDEMU
+	RTL8723A_TRANS_CARDEMU_TO_ACT
+	RTL8723A_TRANS_END
+};
+
+/* 3 HWPDN Array */
+struct wlan_pwr_cfg rtl8723AU_hwpdn_flow[RTL8723A_TRANS_ACT_TO_CARDEMU=
_STEPS+RTL8723A_TRANS_CARDEMU_TO_PDN_STEPS+RTL8723A_TRANS_END_STEPS] =3D=
 {
+	RTL8723A_TRANS_ACT_TO_CARDEMU
+	RTL8723A_TRANS_CARDEMU_TO_PDN
+	RTL8723A_TRANS_END
+};
+
+/* 3 Enter LPS */
+struct wlan_pwr_cfg rtl8723AU_enter_lps_flow[RTL8723A_TRANS_ACT_TO_LPS=
_STEPS+RTL8723A_TRANS_END_STEPS] =3D {
+	/* FW behavior */
+	RTL8723A_TRANS_ACT_TO_LPS
+	RTL8723A_TRANS_END
+};
+
+/* 3 Leave LPS */
+struct wlan_pwr_cfg rtl8723AU_leave_lps_flow[RTL8723A_TRANS_LPS_TO_ACT=
_STEPS+RTL8723A_TRANS_END_STEPS] =3D {
+	/* FW behavior */
+	RTL8723A_TRANS_LPS_TO_ACT
+	RTL8723A_TRANS_END
+};
diff --git a/drivers/staging/rtl8723au/hal/Hal8723UHWImg_CE.c b/drivers=
/staging/rtl8723au/hal/Hal8723UHWImg_CE.c
new file mode 100644
index 0000000..56833da
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/Hal8723UHWImg_CE.c
@@ -0,0 +1,136 @@
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
+
+/*Created on  2013/01/14, 15:51*/
+#include "odm_precomp.h"
+
+u32 Rtl8723UPHY_REG_Array_PG[Rtl8723UPHY_REG_Array_PGLength] =3D {
+	0xe00, 0xffffffff, 0x0a0c0c0c,
+	0xe04, 0xffffffff, 0x02040608,
+	0xe08, 0x0000ff00, 0x00000000,
+	0x86c, 0xffffff00, 0x00000000,
+	0xe10, 0xffffffff, 0x0a0c0d0e,
+	0xe14, 0xffffffff, 0x02040608,
+	0xe18, 0xffffffff, 0x0a0c0d0e,
+	0xe1c, 0xffffffff, 0x02040608,
+	0x830, 0xffffffff, 0x0a0c0c0c,
+	0x834, 0xffffffff, 0x02040608,
+	0x838, 0xffffff00, 0x00000000,
+	0x86c, 0x000000ff, 0x00000000,
+	0x83c, 0xffffffff, 0x0a0c0d0e,
+	0x848, 0xffffffff, 0x02040608,
+	0x84c, 0xffffffff, 0x0a0c0d0e,
+	0x868, 0xffffffff, 0x02040608,
+	0xe00, 0xffffffff, 0x00000000,
+	0xe04, 0xffffffff, 0x00000000,
+	0xe08, 0x0000ff00, 0x00000000,
+	0x86c, 0xffffff00, 0x00000000,
+	0xe10, 0xffffffff, 0x00000000,
+	0xe14, 0xffffffff, 0x00000000,
+	0xe18, 0xffffffff, 0x00000000,
+	0xe1c, 0xffffffff, 0x00000000,
+	0x830, 0xffffffff, 0x00000000,
+	0x834, 0xffffffff, 0x00000000,
+	0x838, 0xffffff00, 0x00000000,
+	0x86c, 0x000000ff, 0x00000000,
+	0x83c, 0xffffffff, 0x00000000,
+	0x848, 0xffffffff, 0x00000000,
+	0x84c, 0xffffffff, 0x00000000,
+	0x868, 0xffffffff, 0x00000000,
+	0xe00, 0xffffffff, 0x04040404,
+	0xe04, 0xffffffff, 0x00020204,
+	0xe08, 0x0000ff00, 0x00000000,
+	0x86c, 0xffffff00, 0x00000000,
+	0xe10, 0xffffffff, 0x06060606,
+	0xe14, 0xffffffff, 0x00020406,
+	0xe18, 0xffffffff, 0x00000000,
+	0xe1c, 0xffffffff, 0x00000000,
+	0x830, 0xffffffff, 0x04040404,
+	0x834, 0xffffffff, 0x00020204,
+	0x838, 0xffffff00, 0x00000000,
+	0x86c, 0x000000ff, 0x00000000,
+	0x83c, 0xffffffff, 0x06060606,
+	0x848, 0xffffffff, 0x00020406,
+	0x84c, 0xffffffff, 0x00000000,
+	0x868, 0xffffffff, 0x00000000,
+	0xe00, 0xffffffff, 0x00000000,
+	0xe04, 0xffffffff, 0x00000000,
+	0xe08, 0x0000ff00, 0x00000000,
+	0x86c, 0xffffff00, 0x00000000,
+	0xe10, 0xffffffff, 0x00000000,
+	0xe14, 0xffffffff, 0x00000000,
+	0xe18, 0xffffffff, 0x00000000,
+	0xe1c, 0xffffffff, 0x00000000,
+	0x830, 0xffffffff, 0x00000000,
+	0x834, 0xffffffff, 0x00000000,
+	0x838, 0xffffff00, 0x00000000,
+	0x86c, 0x000000ff, 0x00000000,
+	0x83c, 0xffffffff, 0x00000000,
+	0x848, 0xffffffff, 0x00000000,
+	0x84c, 0xffffffff, 0x00000000,
+	0x868, 0xffffffff, 0x00000000,
+	0xe00, 0xffffffff, 0x00000000,
+	0xe04, 0xffffffff, 0x00000000,
+	0xe08, 0x0000ff00, 0x00000000,
+	0x86c, 0xffffff00, 0x00000000,
+	0xe10, 0xffffffff, 0x00000000,
+	0xe14, 0xffffffff, 0x00000000,
+	0xe18, 0xffffffff, 0x00000000,
+	0xe1c, 0xffffffff, 0x00000000,
+	0x830, 0xffffffff, 0x00000000,
+	0x834, 0xffffffff, 0x00000000,
+	0x838, 0xffffff00, 0x00000000,
+	0x86c, 0x000000ff, 0x00000000,
+	0x83c, 0xffffffff, 0x00000000,
+	0x848, 0xffffffff, 0x00000000,
+	0x84c, 0xffffffff, 0x00000000,
+	0x868, 0xffffffff, 0x00000000,
+	0xe00, 0xffffffff, 0x04040404,
+	0xe04, 0xffffffff, 0x00020204,
+	0xe08, 0x0000ff00, 0x00000000,
+	0x86c, 0xffffff00, 0x00000000,
+	0xe10, 0xffffffff, 0x00000000,
+	0xe14, 0xffffffff, 0x00000000,
+	0xe18, 0xffffffff, 0x00000000,
+	0xe1c, 0xffffffff, 0x00000000,
+	0x830, 0xffffffff, 0x04040404,
+	0x834, 0xffffffff, 0x00020204,
+	0x838, 0xffffff00, 0x00000000,
+	0x86c, 0x000000ff, 0x00000000,
+	0x83c, 0xffffffff, 0x00000000,
+	0x848, 0xffffffff, 0x00000000,
+	0x84c, 0xffffffff, 0x00000000,
+	0x868, 0xffffffff, 0x00000000,
+	0xe00, 0xffffffff, 0x00000000,
+	0xe04, 0xffffffff, 0x00000000,
+	0xe08, 0x0000ff00, 0x00000000,
+	0x86c, 0xffffff00, 0x00000000,
+	0xe10, 0xffffffff, 0x00000000,
+	0xe14, 0xffffffff, 0x00000000,
+	0xe18, 0xffffffff, 0x00000000,
+	0xe1c, 0xffffffff, 0x00000000,
+	0x830, 0xffffffff, 0x00000000,
+	0x834, 0xffffffff, 0x00000000,
+	0x838, 0xffffff00, 0x00000000,
+	0x86c, 0x000000ff, 0x00000000,
+	0x83c, 0xffffffff, 0x00000000,
+	0x848, 0xffffffff, 0x00000000,
+	0x84c, 0xffffffff, 0x00000000,
+	0x868, 0xffffffff, 0x00000000,
+	};
+
+u32 Rtl8723UMACPHY_Array_PG[Rtl8723UMACPHY_Array_PGLength] =3D {
+	0x0,
+};
diff --git a/drivers/staging/rtl8723au/hal/HalDMOutSrc8723A_CE.c b/driv=
ers/staging/rtl8723au/hal/HalDMOutSrc8723A_CE.c
new file mode 100644
index 0000000..9796f2e
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/HalDMOutSrc8723A_CE.c
@@ -0,0 +1,1063 @@
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
+/*  Description: */
+/*  This file is for 92CE/92CU dynamic mechanism only */
+
+/*  include files */
+
+#include "odm_precomp.h"
+
+#define		DPK_DELTA_MAPPING_NUM	13
+#define		index_mapping_HP_NUM	15
+/* 091212 chiyokolin */
+static	void
+odm_TXPowerTrackingCallback_ThermalMeter_92C(
+	struct rtw_adapter *Adapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct dm_priv *pdmpriv =3D &pHalData->dmpriv;
+	u8 ThermalValue =3D 0, delta, delta_LCK, delta_IQK, delta_HP;
+	int ele_A, ele_D, TempCCk, X, value32;
+	int Y, ele_C;
+	s8 OFDM_index[2], CCK_index =3D 0, OFDM_index_old[2] =3D {0};
+	s8 CCK_index_old =3D 0;
+	int i =3D 0;
+	bool is2T =3D IS_92C_SERIAL(pHalData->VersionID);
+	u8 OFDM_min_index =3D 6, rf; /* OFDM BB Swing should be less than +3.=
0dB*/
+	u8 ThermalValue_HP_count =3D 0;
+	u32 ThermalValue_HP =3D 0;
+	s32 index_mapping_HP[index_mapping_HP_NUM] =3D {
+		0, 1, 3, 4, 6,
+		7, 9, 10, 12, 13,
+		15, 16, 18, 19, 21
+	};
+	s8 index_HP;
+
+	pdmpriv->TXPowerTrackingCallbackCnt++;	/* cosa add for debug */
+	pdmpriv->bTXPowerTrackingInit =3D true;
+
+	if (pHalData->CurrentChannel =3D=3D 14 && !pdmpriv->bCCKinCH14)
+		pdmpriv->bCCKinCH14 =3D true;
+	else if (pHalData->CurrentChannel !=3D 14 && pdmpriv->bCCKinCH14)
+		pdmpriv->bCCKinCH14 =3D false;
+
+	ThermalValue =3D (u8)PHY_QueryRFReg(Adapter, RF_PATH_A, RF_T_METER,
+					  0x1f);/*  0x24: RF Reg[4:0]	 */
+
+	rtl8723a_phy_ap_calibrate(Adapter, (ThermalValue -
+				  pHalData->EEPROMThermalMeter));
+
+	if (is2T)
+		rf =3D 2;
+	else
+		rf =3D 1;
+
+	if (ThermalValue) {
+		/* Query OFDM path A default setting	 */
+		ele_D =3D PHY_QueryBBReg(Adapter, rOFDM0_XATxIQImbalance,
+				       bMaskDWord)&bMaskOFDM_D;
+		for (i =3D 0; i < OFDM_TABLE_SIZE_92C; i++) {
+			/* find the index */
+			if (ele_D =3D=3D (OFDMSwingTable23A[i]&bMaskOFDM_D)) {
+				OFDM_index_old[0] =3D (u8)i;
+				break;
+			}
+		}
+
+		/* Query OFDM path B default setting  */
+		if (is2T) {
+			ele_D =3D PHY_QueryBBReg(Adapter, rOFDM0_XBTxIQImbalance,
+					       bMaskDWord)&bMaskOFDM_D;
+			for (i =3D 0; i < OFDM_TABLE_SIZE_92C; i++) {	/* find the index  */
+				if (ele_D =3D=3D (OFDMSwingTable23A[i]&bMaskOFDM_D)) {
+					OFDM_index_old[1] =3D (u8)i;
+					break;
+				}
+			}
+		}
+
+		/* Query CCK default setting From 0xa24 */
+		TempCCk =3D PHY_QueryBBReg(Adapter, rCCK0_TxFilter2,
+					 bMaskDWord)&bMaskCCK;
+		for (i =3D 0 ; i < CCK_TABLE_SIZE ; i++) {
+			if (pdmpriv->bCCKinCH14) {
+				if (!memcmp(&TempCCk,
+					    &CCKSwingTable_Ch1423A[i][2], 4)) {
+					CCK_index_old =3D (u8)i;
+					break;
+				}
+			} else {
+				if (!memcmp(&TempCCk,
+					    &CCKSwingTable_Ch1_Ch1323A[i][2], 4)) {
+					CCK_index_old =3D (u8)i;
+					break;
+				}
+			}
+		}
+
+		if (!pdmpriv->ThermalValue) {
+			pdmpriv->ThermalValue =3D pHalData->EEPROMThermalMeter;
+			pdmpriv->ThermalValue_LCK =3D ThermalValue;
+			pdmpriv->ThermalValue_IQK =3D ThermalValue;
+			pdmpriv->ThermalValue_DPK =3D pHalData->EEPROMThermalMeter;
+
+			for (i =3D 0; i < rf; i++) {
+				pdmpriv->OFDM_index_HP[i] =3D OFDM_index_old[i];
+				pdmpriv->OFDM_index[i] =3D OFDM_index_old[i];
+			}
+			pdmpriv->CCK_index_HP =3D CCK_index_old;
+			pdmpriv->CCK_index =3D CCK_index_old;
+		}
+
+		if (pHalData->BoardType =3D=3D BOARD_USB_High_PA) {
+			pdmpriv->ThermalValue_HP[pdmpriv->ThermalValue_HP_index] =3D Therma=
lValue;
+			pdmpriv->ThermalValue_HP_index++;
+			if (pdmpriv->ThermalValue_HP_index =3D=3D HP_THERMAL_NUM)
+				pdmpriv->ThermalValue_HP_index =3D 0;
+
+			for (i =3D 0; i < HP_THERMAL_NUM; i++) {
+				if (pdmpriv->ThermalValue_HP[i]) {
+					ThermalValue_HP +=3D pdmpriv->ThermalValue_HP[i];
+					ThermalValue_HP_count++;
+				}
+			}
+
+			if (ThermalValue_HP_count)
+				ThermalValue =3D (u8)(ThermalValue_HP / ThermalValue_HP_count);
+		}
+
+		delta =3D (ThermalValue > pdmpriv->ThermalValue) ?
+			(ThermalValue - pdmpriv->ThermalValue) :
+			(pdmpriv->ThermalValue - ThermalValue);
+		if (pHalData->BoardType =3D=3D BOARD_USB_High_PA) {
+			if (pdmpriv->bDoneTxpower)
+				delta_HP =3D (ThermalValue > pdmpriv->ThermalValue) ?
+					   (ThermalValue - pdmpriv->ThermalValue) :
+					   (pdmpriv->ThermalValue - ThermalValue);
+			else
+				delta_HP =3D ThermalValue > pHalData->EEPROMThermalMeter ?
+					   (ThermalValue - pHalData->EEPROMThermalMeter) :
+					   (pHalData->EEPROMThermalMeter - ThermalValue);
+		} else {
+			delta_HP =3D 0;
+		}
+		delta_LCK =3D (ThermalValue > pdmpriv->ThermalValue_LCK) ?
+			    (ThermalValue - pdmpriv->ThermalValue_LCK) :
+			    (pdmpriv->ThermalValue_LCK - ThermalValue);
+		delta_IQK =3D (ThermalValue > pdmpriv->ThermalValue_IQK) ?
+			    (ThermalValue - pdmpriv->ThermalValue_IQK) :
+			    (pdmpriv->ThermalValue_IQK - ThermalValue);
+
+		if (delta_LCK > 1) {
+			pdmpriv->ThermalValue_LCK =3D ThermalValue;
+			rtl8723a_phy_lc_calibrate(Adapter);
+		}
+
+		if ((delta > 0 || delta_HP > 0) && pdmpriv->TxPowerTrackControl) {
+			if (pHalData->BoardType =3D=3D BOARD_USB_High_PA) {
+				pdmpriv->bDoneTxpower =3D true;
+				delta_HP =3D ThermalValue > pHalData->EEPROMThermalMeter ?
+					   (ThermalValue - pHalData->EEPROMThermalMeter) :
+					   (pHalData->EEPROMThermalMeter - ThermalValue);
+
+				if (delta_HP > index_mapping_HP_NUM-1)
+					index_HP =3D index_mapping_HP[index_mapping_HP_NUM-1];
+				else
+					index_HP =3D index_mapping_HP[delta_HP];
+
+				if (ThermalValue > pHalData->EEPROMThermalMeter) {
+					/* set larger Tx power */
+					for (i =3D 0; i < rf; i++)
+						OFDM_index[i] =3D pdmpriv->OFDM_index_HP[i] - index_HP;
+					CCK_index =3D pdmpriv->CCK_index_HP - index_HP;
+				} else {
+					for (i =3D 0; i < rf; i++)
+						OFDM_index[i] =3D pdmpriv->OFDM_index_HP[i] + index_HP;
+					CCK_index =3D pdmpriv->CCK_index_HP + index_HP;
+				}
+
+				delta_HP =3D (ThermalValue > pdmpriv->ThermalValue) ?
+					   (ThermalValue - pdmpriv->ThermalValue) :
+					   (pdmpriv->ThermalValue - ThermalValue);
+			} else {
+				if (ThermalValue > pdmpriv->ThermalValue) {
+					for (i =3D 0; i < rf; i++)
+						pdmpriv->OFDM_index[i] -=3D delta;
+					pdmpriv->CCK_index -=3D delta;
+				} else {
+					for (i =3D 0; i < rf; i++)
+						pdmpriv->OFDM_index[i] +=3D delta;
+					pdmpriv->CCK_index +=3D delta;
+				}
+			}
+
+			/* no adjust */
+			if (pHalData->BoardType !=3D BOARD_USB_High_PA) {
+				if (ThermalValue > pHalData->EEPROMThermalMeter) {
+					for (i =3D 0; i < rf; i++)
+						OFDM_index[i] =3D pdmpriv->OFDM_index[i]+1;
+					CCK_index =3D pdmpriv->CCK_index+1;
+				} else {
+					for (i =3D 0; i < rf; i++)
+						OFDM_index[i] =3D pdmpriv->OFDM_index[i];
+					CCK_index =3D pdmpriv->CCK_index;
+				}
+			}
+			for (i =3D 0; i < rf; i++) {
+				if (OFDM_index[i] > (OFDM_TABLE_SIZE_92C-1))
+					OFDM_index[i] =3D (OFDM_TABLE_SIZE_92C-1);
+				else if (OFDM_index[i] < OFDM_min_index)
+					OFDM_index[i] =3D OFDM_min_index;
+			}
+
+			if (CCK_index > (CCK_TABLE_SIZE-1))
+				CCK_index =3D (CCK_TABLE_SIZE-1);
+			else if (CCK_index < 0)
+				CCK_index =3D 0;
+		}
+
+		if (pdmpriv->TxPowerTrackControl && (delta !=3D 0 || delta_HP !=3D 0=
)) {
+			/* Adujst OFDM Ant_A according to IQK result */
+			ele_D =3D (OFDMSwingTable23A[OFDM_index[0]] & 0xFFC00000)>>22;
+			X =3D pdmpriv->RegE94;
+			Y =3D pdmpriv->RegE9C;
+
+			if (X !=3D 0) {
+				if ((X & 0x00000200) !=3D 0)
+					X =3D X | 0xFFFFFC00;
+				ele_A =3D ((X * ele_D)>>8)&0x000003FF;
+
+				/* new element C =3D element D x Y */
+				if ((Y & 0x00000200) !=3D 0)
+					Y =3D Y | 0xFFFFFC00;
+				ele_C =3D ((Y * ele_D)>>8)&0x000003FF;
+
+				/* write new elements A, C, D to regC80 and regC94, element B is a=
lways 0 */
+				value32 =3D (ele_D<<22)|((ele_C&0x3F)<<16)|ele_A;
+				PHY_SetBBReg(Adapter, rOFDM0_XATxIQImbalance, bMaskDWord, value32)=
;
+
+				value32 =3D (ele_C&0x000003C0)>>6;
+				PHY_SetBBReg(Adapter, rOFDM0_XCTxAFE, bMaskH4Bits, value32);
+
+				value32 =3D ((X * ele_D)>>7)&0x01;
+				PHY_SetBBReg(Adapter, rOFDM0_ECCAThreshold, BIT31, value32);
+
+				value32 =3D ((Y * ele_D)>>7)&0x01;
+				PHY_SetBBReg(Adapter, rOFDM0_ECCAThreshold, BIT29, value32);
+			} else {
+				PHY_SetBBReg(Adapter, rOFDM0_XATxIQImbalance, bMaskDWord, OFDMSwin=
gTable23A[OFDM_index[0]]);
+				PHY_SetBBReg(Adapter, rOFDM0_XCTxAFE, bMaskH4Bits, 0x00);
+				PHY_SetBBReg(Adapter, rOFDM0_ECCAThreshold, BIT31|BIT29, 0x00);
+			}
+
+			/* Adjust CCK according to IQK result */
+			if (!pdmpriv->bCCKinCH14) {
+				rtw_write8(Adapter, 0xa22, CCKSwingTable_Ch1_Ch1323A[CCK_index][0]=
);
+				rtw_write8(Adapter, 0xa23, CCKSwingTable_Ch1_Ch1323A[CCK_index][1]=
);
+				rtw_write8(Adapter, 0xa24, CCKSwingTable_Ch1_Ch1323A[CCK_index][2]=
);
+				rtw_write8(Adapter, 0xa25, CCKSwingTable_Ch1_Ch1323A[CCK_index][3]=
);
+				rtw_write8(Adapter, 0xa26, CCKSwingTable_Ch1_Ch1323A[CCK_index][4]=
);
+				rtw_write8(Adapter, 0xa27, CCKSwingTable_Ch1_Ch1323A[CCK_index][5]=
);
+				rtw_write8(Adapter, 0xa28, CCKSwingTable_Ch1_Ch1323A[CCK_index][6]=
);
+				rtw_write8(Adapter, 0xa29, CCKSwingTable_Ch1_Ch1323A[CCK_index][7]=
);
+			} else {
+				rtw_write8(Adapter, 0xa22, CCKSwingTable_Ch1423A[CCK_index][0]);
+				rtw_write8(Adapter, 0xa23, CCKSwingTable_Ch1423A[CCK_index][1]);
+				rtw_write8(Adapter, 0xa24, CCKSwingTable_Ch1423A[CCK_index][2]);
+				rtw_write8(Adapter, 0xa25, CCKSwingTable_Ch1423A[CCK_index][3]);
+				rtw_write8(Adapter, 0xa26, CCKSwingTable_Ch1423A[CCK_index][4]);
+				rtw_write8(Adapter, 0xa27, CCKSwingTable_Ch1423A[CCK_index][5]);
+				rtw_write8(Adapter, 0xa28, CCKSwingTable_Ch1423A[CCK_index][6]);
+				rtw_write8(Adapter, 0xa29, CCKSwingTable_Ch1423A[CCK_index][7]);
+			}
+
+			if (is2T) {
+				ele_D =3D (OFDMSwingTable23A[(u8)OFDM_index[1]] & 0xFFC00000)>>22;
+
+				/* new element A =3D element D x X */
+				X =3D pdmpriv->RegEB4;
+				Y =3D pdmpriv->RegEBC;
+
+				if (X !=3D 0) {
+					if ((X & 0x00000200) !=3D 0)	/* consider minus */
+						X =3D X | 0xFFFFFC00;
+					ele_A =3D ((X * ele_D)>>8)&0x000003FF;
+
+					/* new element C =3D element D x Y */
+					if ((Y & 0x00000200) !=3D 0)
+						Y =3D Y | 0xFFFFFC00;
+					ele_C =3D ((Y * ele_D)>>8)&0x00003FF;
+
+					/* write new elements A, C, D to regC88 and regC9C, element B is =
always 0 */
+					value32 =3D (ele_D<<22)|((ele_C&0x3F)<<16) | ele_A;
+					PHY_SetBBReg(Adapter, rOFDM0_XBTxIQImbalance, bMaskDWord, value32=
);
+
+					value32 =3D (ele_C&0x000003C0)>>6;
+					PHY_SetBBReg(Adapter, rOFDM0_XDTxAFE, bMaskH4Bits, value32);
+
+					value32 =3D ((X * ele_D)>>7)&0x01;
+					PHY_SetBBReg(Adapter, rOFDM0_ECCAThreshold, BIT27, value32);
+
+					value32 =3D ((Y * ele_D)>>7)&0x01;
+					PHY_SetBBReg(Adapter, rOFDM0_ECCAThreshold, BIT25, value32);
+				} else {
+					PHY_SetBBReg(Adapter, rOFDM0_XBTxIQImbalance, bMaskDWord, OFDMSwi=
ngTable23A[OFDM_index[1]]);
+					PHY_SetBBReg(Adapter, rOFDM0_XDTxAFE, bMaskH4Bits, 0x00);
+					PHY_SetBBReg(Adapter, rOFDM0_ECCAThreshold, BIT27|BIT25, 0x00);
+				}
+			}
+
+		}
+		if (delta_IQK > 3) {
+			pdmpriv->ThermalValue_IQK =3D ThermalValue;
+			rtl8723a_phy_iq_calibrate(Adapter, false);
+		}
+
+		/* update thermal meter value */
+		if (pdmpriv->TxPowerTrackControl)
+			pdmpriv->ThermalValue =3D ThermalValue;
+	}
+	pdmpriv->TXPowercount =3D 0;
+}
+
+/*	Description: */
+/*		- Dispatch TxPower Tracking direct call ONLY for 92s. */
+/*		- We shall NOT schedule Workitem within PASSIVE LEVEL, which will =
cause system resource */
+/*		   leakage under some platform. */
+/*	Assumption: */
+/*		PASSIVE_LEVEL when this routine is called. */
+static void ODM_TXPowerTracking92CDirectCall(struct rtw_adapter *Adapt=
er)
+{
+	odm_TXPowerTrackingCallback_ThermalMeter_92C(Adapter);
+}
+
+static void odm_CheckTXPowerTracking_ThermalMeter(struct rtw_adapter *=
Adapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct dm_priv *pdmpriv =3D &pHalData->dmpriv;
+	struct dm_odm_t *podmpriv =3D &pHalData->odmpriv;
+
+	if (!(podmpriv->SupportAbility & ODM_RF_TX_PWR_TRACK))
+		return;
+
+	if (!pdmpriv->TM_Trigger) {		/* at least delay 1 sec */
+		PHY_SetRFReg(Adapter, RF_PATH_A, RF_T_METER, bRFRegOffsetMask, 0x60)=
;
+
+		pdmpriv->TM_Trigger =3D 1;
+		return;
+	} else {
+		ODM_TXPowerTracking92CDirectCall(Adapter);
+		pdmpriv->TM_Trigger =3D 0;
+	}
+}
+
+void rtl8723a_odm_check_tx_power_tracking(struct rtw_adapter *Adapter)
+{
+	odm_CheckTXPowerTracking_ThermalMeter(Adapter);
+}
+
+/*	IQK */
+#define MAX_TOLERANCE		5
+#define IQK_DELAY_TIME		1	/* ms */
+
+static u8 _PHY_PathA_IQK(struct rtw_adapter *pAdapter, bool configPath=
B)
+{
+	u32 regEAC, regE94, regE9C, regEA4;
+	u8 result =3D 0x00;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(pAdapter);
+
+	/* path-A IQK setting */
+	PHY_SetBBReg(pAdapter, rTx_IQK_Tone_A, bMaskDWord, 0x10008c1f);
+	PHY_SetBBReg(pAdapter, rRx_IQK_Tone_A, bMaskDWord, 0x10008c1f);
+	PHY_SetBBReg(pAdapter, rTx_IQK_PI_A, bMaskDWord, 0x82140102);
+
+	PHY_SetBBReg(pAdapter, rRx_IQK_PI_A, bMaskDWord, configPathB ? 0x2816=
0202 :
+		IS_81xxC_VENDOR_UMC_B_CUT(pHalData->VersionID)?0x28160202:0x28160502=
);
+
+	/* path-B IQK setting */
+	if (configPathB) {
+		PHY_SetBBReg(pAdapter, rTx_IQK_Tone_B, bMaskDWord, 0x10008c22);
+		PHY_SetBBReg(pAdapter, rRx_IQK_Tone_B, bMaskDWord, 0x10008c22);
+		PHY_SetBBReg(pAdapter, rTx_IQK_PI_B, bMaskDWord, 0x82140102);
+		PHY_SetBBReg(pAdapter, rRx_IQK_PI_B, bMaskDWord, 0x28160202);
+	}
+
+	/* LO calibration setting */
+	PHY_SetBBReg(pAdapter, rIQK_AGC_Rsp, bMaskDWord, 0x001028d1);
+
+	/* One shot, path A LOK & IQK */
+	PHY_SetBBReg(pAdapter, rIQK_AGC_Pts, bMaskDWord, 0xf9000000);
+	PHY_SetBBReg(pAdapter, rIQK_AGC_Pts, bMaskDWord, 0xf8000000);
+
+	/*  delay x ms */
+	udelay(IQK_DELAY_TIME*1000);/* PlatformStallExecution(IQK_DELAY_TIME*=
1000); */
+
+	/*  Check failed */
+	regEAC =3D PHY_QueryBBReg(pAdapter, rRx_Power_After_IQK_A_2, bMaskDWo=
rd);
+	regE94 =3D PHY_QueryBBReg(pAdapter, rTx_Power_Before_IQK_A, bMaskDWor=
d);
+	regE9C =3D PHY_QueryBBReg(pAdapter, rTx_Power_After_IQK_A, bMaskDWord=
);
+	regEA4 =3D PHY_QueryBBReg(pAdapter, rRx_Power_Before_IQK_A_2, bMaskDW=
ord);
+
+	if (!(regEAC & BIT28) &&
+	    (((regE94 & 0x03FF0000)>>16) !=3D 0x142) &&
+	    (((regE9C & 0x03FF0000)>>16) !=3D 0x42))
+		result |=3D 0x01;
+	else			/* if Tx not OK, ignore Rx */
+		return result;
+
+	if (!(regEAC & BIT27) &&		/* if Tx is OK, check whether Rx is OK */
+	    (((regEA4 & 0x03FF0000)>>16) !=3D 0x132) &&
+	    (((regEAC & 0x03FF0000)>>16) !=3D 0x36))
+		result |=3D 0x02;
+	else
+		DBG_8723A("Path A Rx IQK fail!!\n");
+	return result;
+}
+
+static u8 _PHY_PathB_IQK(struct rtw_adapter *pAdapter)
+{
+	u32 regEAC, regEB4, regEBC, regEC4, regECC;
+	u8 result =3D 0x00;
+
+	/* One shot, path B LOK & IQK */
+	PHY_SetBBReg(pAdapter, rIQK_AGC_Cont, bMaskDWord, 0x00000002);
+	PHY_SetBBReg(pAdapter, rIQK_AGC_Cont, bMaskDWord, 0x00000000);
+
+	/*  delay x ms */
+	udelay(IQK_DELAY_TIME*1000);
+
+	/*  Check failed */
+	regEAC =3D PHY_QueryBBReg(pAdapter, rRx_Power_After_IQK_A_2, bMaskDWo=
rd);
+	regEB4 =3D PHY_QueryBBReg(pAdapter, rTx_Power_Before_IQK_B, bMaskDWor=
d);
+	regEBC =3D PHY_QueryBBReg(pAdapter, rTx_Power_After_IQK_B, bMaskDWord=
);
+	regEC4 =3D PHY_QueryBBReg(pAdapter, rRx_Power_Before_IQK_B_2, bMaskDW=
ord);
+	regECC =3D PHY_QueryBBReg(pAdapter, rRx_Power_After_IQK_B_2, bMaskDWo=
rd);
+
+	if (!(regEAC & BIT31) &&
+	    (((regEB4 & 0x03FF0000)>>16) !=3D 0x142) &&
+	    (((regEBC & 0x03FF0000)>>16) !=3D 0x42))
+		result |=3D 0x01;
+	else
+		return result;
+
+	if (!(regEAC & BIT30) &&
+	    (((regEC4 & 0x03FF0000)>>16) !=3D 0x132) &&
+	    (((regECC & 0x03FF0000)>>16) !=3D 0x36))
+		result |=3D 0x02;
+	else
+		DBG_8723A("Path B Rx IQK fail!!\n");
+	return result;
+}
+
+static void _PHY_PathAFillIQKMatrix(struct rtw_adapter *pAdapter,
+	bool bIQKOK,
+	int result[][8],
+	u8 final_candidate,
+	bool bTxOnly
+	)
+{
+	u32 Oldval_0, X, TX0_A, reg;
+	s32 Y, TX0_C;
+
+	DBG_8723A("Path A IQ Calibration %s !\n", (bIQKOK)?"Success":"Failed"=
);
+
+	if (final_candidate =3D=3D 0xFF) {
+		return;
+	} else if (bIQKOK) {
+		Oldval_0 =3D (PHY_QueryBBReg(pAdapter, rOFDM0_XATxIQImbalance, bMask=
DWord) >> 22) & 0x3FF;
+
+		X =3D result[final_candidate][0];
+		if ((X & 0x00000200) !=3D 0)
+			X =3D X | 0xFFFFFC00;
+		TX0_A =3D (X * Oldval_0) >> 8;
+		PHY_SetBBReg(pAdapter, rOFDM0_XATxIQImbalance, 0x3FF, TX0_A);
+		PHY_SetBBReg(pAdapter, rOFDM0_ECCAThreshold, BIT(31), ((X * Oldval_0=
>>7) & 0x1));
+
+		Y =3D result[final_candidate][1];
+		if ((Y & 0x00000200) !=3D 0)
+			Y =3D Y | 0xFFFFFC00;
+		TX0_C =3D (Y * Oldval_0) >> 8;
+		PHY_SetBBReg(pAdapter, rOFDM0_XCTxAFE, 0xF0000000, ((TX0_C&0x3C0)>>6=
));
+		PHY_SetBBReg(pAdapter, rOFDM0_XATxIQImbalance, 0x003F0000, (TX0_C&0x=
3F));
+		PHY_SetBBReg(pAdapter, rOFDM0_ECCAThreshold, BIT(29), ((Y * Oldval_0=
>>7) & 0x1));
+
+		if (bTxOnly) {
+			DBG_8723A("_PHY_PathAFillIQKMatrix only Tx OK\n");
+			return;
+		}
+
+		reg =3D result[final_candidate][2];
+		PHY_SetBBReg(pAdapter, rOFDM0_XARxIQImbalance, 0x3FF, reg);
+
+		reg =3D result[final_candidate][3] & 0x3F;
+		PHY_SetBBReg(pAdapter, rOFDM0_XARxIQImbalance, 0xFC00, reg);
+
+		reg =3D (result[final_candidate][3] >> 6) & 0xF;
+		PHY_SetBBReg(pAdapter, rOFDM0_RxIQExtAnta, 0xF0000000, reg);
+	}
+}
+
+static void _PHY_PathBFillIQKMatrix(struct rtw_adapter *pAdapter, bool=
 bIQKOK, int result[][8], u8 final_candidate, bool bTxOnly)
+{
+	u32 Oldval_1, X, TX1_A, reg;
+	s32 Y, TX1_C;
+
+	DBG_8723A("Path B IQ Calibration %s !\n", (bIQKOK)?"Success":"Failed"=
);
+
+	if (final_candidate =3D=3D 0xFF) {
+		return;
+	} else if (bIQKOK) {
+		Oldval_1 =3D (PHY_QueryBBReg(pAdapter, rOFDM0_XBTxIQImbalance, bMask=
DWord) >> 22) & 0x3FF;
+
+		X =3D result[final_candidate][4];
+		if ((X & 0x00000200) !=3D 0)
+			X =3D X | 0xFFFFFC00;
+		TX1_A =3D (X * Oldval_1) >> 8;
+		PHY_SetBBReg(pAdapter, rOFDM0_XBTxIQImbalance, 0x3FF, TX1_A);
+		PHY_SetBBReg(pAdapter, rOFDM0_ECCAThreshold, BIT(27), ((X * Oldval_1=
>>7) & 0x1));
+
+		Y =3D result[final_candidate][5];
+		if ((Y & 0x00000200) !=3D 0)
+			Y =3D Y | 0xFFFFFC00;
+		TX1_C =3D (Y * Oldval_1) >> 8;
+		PHY_SetBBReg(pAdapter, rOFDM0_XDTxAFE, 0xF0000000, ((TX1_C&0x3C0)>>6=
));
+		PHY_SetBBReg(pAdapter, rOFDM0_XBTxIQImbalance, 0x003F0000, (TX1_C&0x=
3F));
+		PHY_SetBBReg(pAdapter, rOFDM0_ECCAThreshold, BIT(25), ((Y * Oldval_1=
>>7) & 0x1));
+
+		if (bTxOnly)
+			return;
+
+		reg =3D result[final_candidate][6];
+		PHY_SetBBReg(pAdapter, rOFDM0_XBRxIQImbalance, 0x3FF, reg);
+
+		reg =3D result[final_candidate][7] & 0x3F;
+		PHY_SetBBReg(pAdapter, rOFDM0_XBRxIQImbalance, 0xFC00, reg);
+
+		reg =3D (result[final_candidate][7] >> 6) & 0xF;
+		PHY_SetBBReg(pAdapter, rOFDM0_AGCRSSITable, 0x0000F000, reg);
+	}
+}
+
+static void _PHY_SaveADDARegisters(struct rtw_adapter *pAdapter, u32 *=
ADDAReg, u32 *ADDABackup, u32 RegisterNum)
+{
+	u32 i;
+
+	for (i =3D 0 ; i < RegisterNum ; i++) {
+		ADDABackup[i] =3D PHY_QueryBBReg(pAdapter, ADDAReg[i], bMaskDWord);
+	}
+}
+
+static void _PHY_SaveMACRegisters(struct rtw_adapter *pAdapter, u32 *M=
ACReg, u32 *MACBackup)
+{
+	u32 i;
+
+	for (i =3D 0 ; i < (IQK_MAC_REG_NUM - 1); i++) {
+		MACBackup[i] =3D rtw_read8(pAdapter, MACReg[i]);
+	}
+	MACBackup[i] =3D rtw_read32(pAdapter, MACReg[i]);
+}
+
+static void _PHY_ReloadADDARegisters(struct rtw_adapter *pAdapter, u32=
 *ADDAReg, u32 *ADDABackup, u32 RegiesterNum)
+{
+	u32 i;
+
+	for (i =3D 0 ; i < RegiesterNum ; i++) {
+		PHY_SetBBReg(pAdapter, ADDAReg[i], bMaskDWord, ADDABackup[i]);
+	}
+}
+
+static void _PHY_ReloadMACRegisters(struct rtw_adapter *pAdapter, u32 =
*MACReg, u32 *MACBackup)
+{
+	u32 i;
+
+	for (i =3D 0 ; i < (IQK_MAC_REG_NUM - 1); i++) {
+		rtw_write8(pAdapter, MACReg[i], (u8)MACBackup[i]);
+	}
+	rtw_write32(pAdapter, MACReg[i], MACBackup[i]);
+}
+
+static void _PHY_PathADDAOn(struct rtw_adapter *pAdapter, u32 *ADDAReg=
, bool isPathAOn, bool is2T)
+{
+	u32 pathOn;
+	u32 i;
+
+	pathOn =3D isPathAOn ? 0x04db25a4 : 0x0b1b25a4;
+	if (false =3D=3D is2T) {
+		pathOn =3D 0x0bdb25a0;
+		PHY_SetBBReg(pAdapter, ADDAReg[0], bMaskDWord, 0x0b1b25a0);
+	} else {
+		PHY_SetBBReg(pAdapter, ADDAReg[0], bMaskDWord, pathOn);
+	}
+
+	for (i =3D 1 ; i < IQK_ADDA_REG_NUM ; i++)
+		PHY_SetBBReg(pAdapter, ADDAReg[i], bMaskDWord, pathOn);
+}
+
+static void _PHY_MACSettingCalibration(struct rtw_adapter *pAdapter, u=
32 *MACReg, u32 *MACBackup)
+{
+	u32 i =3D 0;
+
+	rtw_write8(pAdapter, MACReg[i], 0x3F);
+
+	for (i =3D 1 ; i < (IQK_MAC_REG_NUM - 1); i++) {
+		rtw_write8(pAdapter, MACReg[i], (u8)(MACBackup[i]&(~BIT3)));
+	}
+	rtw_write8(pAdapter, MACReg[i], (u8)(MACBackup[i]&(~BIT5)));
+}
+
+static void _PHY_PathAStandBy(struct rtw_adapter *pAdapter)
+{
+	PHY_SetBBReg(pAdapter, rFPGA0_IQK, bMaskDWord, 0x0);
+	PHY_SetBBReg(pAdapter, 0x840, bMaskDWord, 0x00010000);
+	PHY_SetBBReg(pAdapter, rFPGA0_IQK, bMaskDWord, 0x80800000);
+}
+
+static void _PHY_PIModeSwitch(struct rtw_adapter *pAdapter, bool PIMod=
e)
+{
+	u32 mode;
+
+	mode =3D PIMode ? 0x01000100 : 0x01000000;
+	PHY_SetBBReg(pAdapter, 0x820, bMaskDWord, mode);
+	PHY_SetBBReg(pAdapter, 0x828, bMaskDWord, mode);
+}
+
+/*
+return false =3D> do IQK again
+*/
+static bool _PHY_SimularityCompare(struct rtw_adapter *pAdapter, int r=
esult[][8], u8 c1, u8 c2)
+{
+	u32 i, j, diff, SimularityBitMap, bound =3D 0;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(pAdapter);
+	u8 final_candidate[2] =3D {0xFF, 0xFF};	/* for path A and path B */
+	bool bResult =3D true, is2T =3D IS_92C_SERIAL(pHalData->VersionID);
+
+	if (is2T)
+		bound =3D 8;
+	else
+		bound =3D 4;
+
+	SimularityBitMap =3D 0;
+
+	for (i =3D 0; i < bound; i++) {
+		diff =3D (result[c1][i] > result[c2][i]) ? (result[c1][i] - result[c=
2][i]) : (result[c2][i] - result[c1][i]);
+		if (diff > MAX_TOLERANCE) {
+			if ((i =3D=3D 2 || i =3D=3D 6) && !SimularityBitMap) {
+				if (result[c1][i]+result[c1][i+1] =3D=3D 0)
+					final_candidate[(i/4)] =3D c2;
+				else if (result[c2][i]+result[c2][i+1] =3D=3D 0)
+					final_candidate[(i/4)] =3D c1;
+				else
+					SimularityBitMap =3D SimularityBitMap|(1<<i);
+			} else {
+				SimularityBitMap =3D SimularityBitMap|(1<<i);
+			}
+		}
+	}
+
+	if (SimularityBitMap =3D=3D 0) {
+		for (i =3D 0; i < (bound/4); i++) {
+			if (final_candidate[i] !=3D 0xFF) {
+				for (j =3D i*4; j < (i+1)*4-2; j++)
+					result[3][j] =3D result[final_candidate[i]][j];
+				bResult =3D false;
+			}
+		}
+		return bResult;
+	} else if (!(SimularityBitMap & 0x0F)) {
+		/* path A OK */
+		for (i =3D 0; i < 4; i++)
+			result[3][i] =3D result[c1][i];
+		return false;
+	} else if (!(SimularityBitMap & 0xF0) && is2T) {
+		/* path B OK */
+		for (i =3D 4; i < 8; i++)
+			result[3][i] =3D result[c1][i];
+		return false;
+	} else {
+		return false;
+	}
+}
+
+static void _PHY_IQCalibrate(struct rtw_adapter *pAdapter, int result[=
][8], u8 t, bool is2T)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(pAdapter);
+	struct dm_priv *pdmpriv =3D &pHalData->dmpriv;
+	u32 i;
+	u8 PathAOK, PathBOK;
+	u32 ADDA_REG[IQK_ADDA_REG_NUM] =3D {
+		rFPGA0_XCD_SwitchControl, rBlue_Tooth,
+		rRx_Wait_CCA, rTx_CCK_RFON,
+		rTx_CCK_BBON, rTx_OFDM_RFON,
+		rTx_OFDM_BBON, rTx_To_Rx,
+		rTx_To_Tx, rRx_CCK,
+		rRx_OFDM, rRx_Wait_RIFS,
+		rRx_TO_Rx, rStandby,
+		rSleep, rPMPD_ANAEN
+	};
+
+	u32 IQK_MAC_REG[IQK_MAC_REG_NUM] =3D {
+		REG_TXPAUSE, REG_BCN_CTRL,
+		REG_BCN_CTRL_1, REG_GPIO_MUXCFG
+	};
+
+	u32 IQK_BB_REG_92C[IQK_BB_REG_NUM] =3D {
+		rOFDM0_TRxPathEnable, rOFDM0_TRMuxPar,
+		rFPGA0_XCD_RFInterfaceSW, rConfig_AntA, rConfig_AntB,
+		rFPGA0_XAB_RFInterfaceSW, rFPGA0_XA_RFInterfaceOE,
+		rFPGA0_XB_RFInterfaceOE, rFPGA0_RFMOD
+	};
+
+	const u32 retryCount =3D 2;
+
+	/*  Note: IQ calibration must be performed after loading  */
+	/*		PHY_REG.txt , and radio_a, radio_b.txt	 */
+
+	u32 bbvalue;
+
+	if (t =3D=3D 0) {
+		bbvalue =3D PHY_QueryBBReg(pAdapter, rFPGA0_RFMOD, bMaskDWord);
+
+		/*  Save ADDA parameters, turn Path A ADDA on */
+		_PHY_SaveADDARegisters(pAdapter, ADDA_REG, pdmpriv->ADDA_backup, IQK=
_ADDA_REG_NUM);
+		_PHY_SaveMACRegisters(pAdapter, IQK_MAC_REG, pdmpriv->IQK_MAC_backup=
);
+		_PHY_SaveADDARegisters(pAdapter, IQK_BB_REG_92C, pdmpriv->IQK_BB_bac=
kup, IQK_BB_REG_NUM);
+	}
+	_PHY_PathADDAOn(pAdapter, ADDA_REG, true, is2T);
+
+	if (t =3D=3D 0)
+		pdmpriv->bRfPiEnable =3D (u8)PHY_QueryBBReg(pAdapter, rFPGA0_XA_HSSI=
Parameter1, BIT(8));
+
+	if (!pdmpriv->bRfPiEnable) {
+		/*  Switch BB to PI mode to do IQ Calibration. */
+		_PHY_PIModeSwitch(pAdapter, true);
+	}
+
+	PHY_SetBBReg(pAdapter, rFPGA0_RFMOD, BIT24, 0x00);
+	PHY_SetBBReg(pAdapter, rOFDM0_TRxPathEnable, bMaskDWord, 0x03a05600);
+	PHY_SetBBReg(pAdapter, rOFDM0_TRMuxPar, bMaskDWord, 0x000800e4);
+	PHY_SetBBReg(pAdapter, rFPGA0_XCD_RFInterfaceSW, bMaskDWord, 0x222040=
00);
+	PHY_SetBBReg(pAdapter, rFPGA0_XAB_RFInterfaceSW, BIT10, 0x01);
+	PHY_SetBBReg(pAdapter, rFPGA0_XAB_RFInterfaceSW, BIT26, 0x01);
+	PHY_SetBBReg(pAdapter, rFPGA0_XA_RFInterfaceOE, BIT10, 0x00);
+	PHY_SetBBReg(pAdapter, rFPGA0_XB_RFInterfaceOE, BIT10, 0x00);
+
+	if (is2T) {
+		PHY_SetBBReg(pAdapter, rFPGA0_XA_LSSIParameter, bMaskDWord, 0x000100=
00);
+		PHY_SetBBReg(pAdapter, rFPGA0_XB_LSSIParameter, bMaskDWord, 0x000100=
00);
+	}
+
+	/* MAC settings */
+	_PHY_MACSettingCalibration(pAdapter, IQK_MAC_REG, pdmpriv->IQK_MAC_ba=
ckup);
+
+	/* Page B init */
+	PHY_SetBBReg(pAdapter, rConfig_AntA, bMaskDWord, 0x00080000);
+
+	if (is2T)
+		PHY_SetBBReg(pAdapter, rConfig_AntB, bMaskDWord, 0x00080000);
+
+	/*  IQ calibration setting */
+	PHY_SetBBReg(pAdapter, rFPGA0_IQK, bMaskDWord, 0x80800000);
+	PHY_SetBBReg(pAdapter, rTx_IQK, bMaskDWord, 0x01007c00);
+	PHY_SetBBReg(pAdapter, rRx_IQK, bMaskDWord, 0x01004800);
+
+	for (i =3D 0 ; i < retryCount ; i++) {
+		PathAOK =3D _PHY_PathA_IQK(pAdapter, is2T);
+		if (PathAOK =3D=3D 0x03) {
+				DBG_8723A("Path A IQK Success!!\n");
+				result[t][0] =3D (PHY_QueryBBReg(pAdapter, rTx_Power_Before_IQK_A,=
 bMaskDWord)&0x3FF0000)>>16;
+				result[t][1] =3D (PHY_QueryBBReg(pAdapter, rTx_Power_After_IQK_A, =
bMaskDWord)&0x3FF0000)>>16;
+				result[t][2] =3D (PHY_QueryBBReg(pAdapter, rRx_Power_Before_IQK_A_=
2, bMaskDWord)&0x3FF0000)>>16;
+				result[t][3] =3D (PHY_QueryBBReg(pAdapter, rRx_Power_After_IQK_A_2=
, bMaskDWord)&0x3FF0000)>>16;
+			break;
+		} else if (i =3D=3D (retryCount-1) && PathAOK =3D=3D 0x01) {
+			/* Tx IQK OK */
+			DBG_8723A("Path A IQK Only  Tx Success!!\n");
+
+			result[t][0] =3D (PHY_QueryBBReg(pAdapter, rTx_Power_Before_IQK_A, =
bMaskDWord)&0x3FF0000)>>16;
+			result[t][1] =3D (PHY_QueryBBReg(pAdapter, rTx_Power_After_IQK_A, b=
MaskDWord)&0x3FF0000)>>16;
+		}
+	}
+
+	if (0x00 =3D=3D PathAOK) {
+		DBG_8723A("Path A IQK failed!!\n");
+	}
+
+	if (is2T) {
+		_PHY_PathAStandBy(pAdapter);
+
+		/*  Turn Path B ADDA on */
+		_PHY_PathADDAOn(pAdapter, ADDA_REG, false, is2T);
+
+		for (i =3D 0 ; i < retryCount ; i++) {
+			PathBOK =3D _PHY_PathB_IQK(pAdapter);
+			if (PathBOK =3D=3D 0x03) {
+				DBG_8723A("Path B IQK Success!!\n");
+				result[t][4] =3D (PHY_QueryBBReg(pAdapter, rTx_Power_Before_IQK_B,=
 bMaskDWord)&0x3FF0000)>>16;
+				result[t][5] =3D (PHY_QueryBBReg(pAdapter, rTx_Power_After_IQK_B, =
bMaskDWord)&0x3FF0000)>>16;
+				result[t][6] =3D (PHY_QueryBBReg(pAdapter, rRx_Power_Before_IQK_B_=
2, bMaskDWord)&0x3FF0000)>>16;
+				result[t][7] =3D (PHY_QueryBBReg(pAdapter, rRx_Power_After_IQK_B_2=
, bMaskDWord)&0x3FF0000)>>16;
+				break;
+			} else if (i =3D=3D (retryCount - 1) && PathBOK =3D=3D 0x01) {
+				/* Tx IQK OK */
+				DBG_8723A("Path B Only Tx IQK Success!!\n");
+				result[t][4] =3D (PHY_QueryBBReg(pAdapter, rTx_Power_Before_IQK_B,=
 bMaskDWord)&0x3FF0000)>>16;
+				result[t][5] =3D (PHY_QueryBBReg(pAdapter, rTx_Power_After_IQK_B, =
bMaskDWord)&0x3FF0000)>>16;
+			}
+		}
+
+		if (0x00 =3D=3D PathBOK) {
+			DBG_8723A("Path B IQK failed!!\n");
+		}
+	}
+
+	/* Back to BB mode, load original value */
+	PHY_SetBBReg(pAdapter, rFPGA0_IQK, bMaskDWord, 0);
+
+	if (t !=3D 0) {
+		if (!pdmpriv->bRfPiEnable) {
+			/*  Switch back BB to SI mode after finish IQ Calibration. */
+			_PHY_PIModeSwitch(pAdapter, false);
+		}
+
+		/*  Reload ADDA power saving parameters */
+		_PHY_ReloadADDARegisters(pAdapter, ADDA_REG, pdmpriv->ADDA_backup, I=
QK_ADDA_REG_NUM);
+
+		/*  Reload MAC parameters */
+		_PHY_ReloadMACRegisters(pAdapter, IQK_MAC_REG, pdmpriv->IQK_MAC_back=
up);
+
+		/*  Reload BB parameters */
+		_PHY_ReloadADDARegisters(pAdapter, IQK_BB_REG_92C, pdmpriv->IQK_BB_b=
ackup, IQK_BB_REG_NUM);
+
+		/*  Restore RX initial gain */
+		PHY_SetBBReg(pAdapter, rFPGA0_XA_LSSIParameter, bMaskDWord, 0x00032e=
d3);
+		if (is2T) {
+			PHY_SetBBReg(pAdapter, rFPGA0_XB_LSSIParameter, bMaskDWord, 0x00032=
ed3);
+		}
+
+		/* load 0xe30 IQC default value */
+		PHY_SetBBReg(pAdapter, rTx_IQK_Tone_A, bMaskDWord, 0x01008c00);
+		PHY_SetBBReg(pAdapter, rRx_IQK_Tone_A, bMaskDWord, 0x01008c00);
+
+	}
+}
+
+static void _PHY_LCCalibrate(struct rtw_adapter *pAdapter, bool is2T)
+{
+	u8 tmpReg;
+	u32 RF_Amode =3D 0, RF_Bmode =3D 0, LC_Cal;
+
+	/* Check continuous TX and Packet TX */
+	tmpReg =3D rtw_read8(pAdapter, 0xd03);
+
+	if ((tmpReg&0x70) !=3D 0)			/* Deal with contisuous TX case */
+		rtw_write8(pAdapter, 0xd03, tmpReg&0x8F);	/* disable all continuous =
TX */
+	else							/*  Deal with Packet TX case */
+		rtw_write8(pAdapter, REG_TXPAUSE, 0xFF);			/*  block all queues */
+
+	if ((tmpReg&0x70) !=3D 0) {
+		/* 1. Read original RF mode */
+		/* Path-A */
+		RF_Amode =3D PHY_QueryRFReg(pAdapter, RF_PATH_A, RF_AC, bMask12Bits)=
;
+
+		/* Path-B */
+		if (is2T)
+			RF_Bmode =3D PHY_QueryRFReg(pAdapter, RF_PATH_B, RF_AC, bMask12Bits=
);
+
+		/* 2. Set RF mode =3D standby mode */
+		/* Path-A */
+		PHY_SetRFReg(pAdapter, RF_PATH_A, RF_AC, bMask12Bits, (RF_Amode&0x8F=
=46FF)|0x10000);
+
+		/* Path-B */
+		if (is2T)
+			PHY_SetRFReg(pAdapter, RF_PATH_B, RF_AC, bMask12Bits, (RF_Bmode&0x8=
=46FFF)|0x10000);
+	}
+
+	/* 3. Read RF reg18 */
+	LC_Cal =3D PHY_QueryRFReg(pAdapter, RF_PATH_A, RF_CHNLBW, bMask12Bits=
);
+
+	/* 4. Set LC calibration begin */
+	PHY_SetRFReg(pAdapter, RF_PATH_A, RF_CHNLBW, bMask12Bits, LC_Cal|0x08=
000);
+
+	msleep(100);
+
+	/* Restore original situation */
+	if ((tmpReg&0x70) !=3D 0) {	/* Deal with contuous TX case  */
+		/* Path-A */
+		rtw_write8(pAdapter, 0xd03, tmpReg);
+		PHY_SetRFReg(pAdapter, RF_PATH_A, RF_AC, bMask12Bits, RF_Amode);
+
+		/* Path-B */
+		if (is2T)
+			PHY_SetRFReg(pAdapter, RF_PATH_B, RF_AC, bMask12Bits, RF_Bmode);
+	} else { /*  Deal with Packet TX case */
+		rtw_write8(pAdapter, REG_TXPAUSE, 0x00);
+	}
+}
+
+/* Analog Pre-distortion calibration */
+#define		APK_BB_REG_NUM	8
+#define		APK_CURVE_REG_NUM 4
+#define		PATH_NUM		2
+
+void rtl8723a_phy_iq_calibrate(struct rtw_adapter *pAdapter, bool bReC=
overy)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(pAdapter);
+	struct dm_priv *pdmpriv =3D &pHalData->dmpriv;
+	s32 result[4][8];	/* last is final result */
+	u8 i, final_candidate;
+	bool bPathAOK, bPathBOK;
+	s32 RegE94, RegE9C, RegEA4, RegEAC, RegEB4, RegEBC, RegEC4;
+	s32 RegECC, RegTmp =3D 0;
+	bool is12simular, is13simular, is23simular;
+	bool bStartContTx =3D false, bSingleTone =3D false;
+	bool bCarrierSuppression =3D false;
+	u32 IQK_BB_REG_92C[IQK_BB_REG_NUM] =3D {
+		rOFDM0_XARxIQImbalance, rOFDM0_XBRxIQImbalance,
+		rOFDM0_ECCAThreshold, rOFDM0_AGCRSSITable,
+		rOFDM0_XATxIQImbalance, rOFDM0_XBTxIQImbalance,
+		rOFDM0_XCTxAFE, rOFDM0_XDTxAFE,
+		rOFDM0_RxIQExtAnta
+	};
+
+	/* ignore IQK when continuous Tx */
+	if (bStartContTx || bSingleTone || bCarrierSuppression)
+		return;
+
+	if (bReCovery) {
+		_PHY_ReloadADDARegisters(pAdapter, IQK_BB_REG_92C, pdmpriv->IQK_BB_b=
ackup_recover, 9);
+		return;
+	}
+	DBG_8723A("IQK:Start!!!\n");
+
+	for (i =3D 0; i < 8; i++) {
+		result[0][i] =3D 0;
+		result[1][i] =3D 0;
+		result[2][i] =3D 0;
+		result[3][i] =3D 0;
+	}
+	final_candidate =3D 0xff;
+	bPathAOK =3D false;
+	bPathBOK =3D false;
+	is12simular =3D false;
+	is23simular =3D false;
+	is13simular =3D false;
+
+	for (i =3D 0; i < 3; i++) {
+		if (IS_92C_SERIAL(pHalData->VersionID)) {
+			 _PHY_IQCalibrate(pAdapter, result, i, true);
+		} else {
+			/*  For 88C 1T1R */
+			_PHY_IQCalibrate(pAdapter, result, i, false);
+		}
+
+		if (i =3D=3D 1) {
+			is12simular =3D _PHY_SimularityCompare(pAdapter, result, 0, 1);
+			if (is12simular) {
+				final_candidate =3D 0;
+				break;
+			}
+		}
+
+		if (i =3D=3D 2) {
+			is13simular =3D _PHY_SimularityCompare(pAdapter, result, 0, 2);
+			if (is13simular) {
+				final_candidate =3D 0;
+				break;
+			}
+
+			is23simular =3D _PHY_SimularityCompare(pAdapter, result, 1, 2);
+			if (is23simular) {
+				final_candidate =3D 1;
+			} else {
+				for (i =3D 0; i < 8; i++)
+					RegTmp +=3D result[3][i];
+
+				if (RegTmp !=3D 0)
+					final_candidate =3D 3;
+				else
+					final_candidate =3D 0xFF;
+			}
+		}
+	}
+
+	for (i =3D 0; i < 4; i++) {
+		RegE94 =3D result[i][0];
+		RegE9C =3D result[i][1];
+		RegEA4 =3D result[i][2];
+		RegEAC =3D result[i][3];
+		RegEB4 =3D result[i][4];
+		RegEBC =3D result[i][5];
+		RegEC4 =3D result[i][6];
+		RegECC =3D result[i][7];
+	}
+
+	if (final_candidate !=3D 0xff) {
+		RegE94 =3D result[final_candidate][0];
+		pdmpriv->RegE94 =3D  RegE94;
+		RegE9C =3D result[final_candidate][1];
+		pdmpriv->RegE9C =3D RegE9C;
+		RegEA4 =3D result[final_candidate][2];
+		RegEAC =3D result[final_candidate][3];
+		RegEB4 =3D result[final_candidate][4];
+		pdmpriv->RegEB4 =3D RegEB4;
+		RegEBC =3D result[final_candidate][5];
+		pdmpriv->RegEBC =3D RegEBC;
+		RegEC4 =3D result[final_candidate][6];
+		RegECC =3D result[final_candidate][7];
+		DBG_8723A("IQK: final_candidate is %x\n", final_candidate);
+		DBG_8723A("IQK: RegE94 =3D%x RegE9C =3D%x RegEA4 =3D%x RegEAC =3D%x =
RegEB4 =3D%x RegEBC =3D%x RegEC4 =3D%x RegECC =3D%x\n ",
+			  RegE94, RegE9C, RegEA4, RegEAC, RegEB4, RegEBC, RegEC4, RegECC);
+		bPathAOK =3D bPathBOK =3D true;
+	} else {
+		RegE94 =3D RegEB4 =3D pdmpriv->RegE94 =3D pdmpriv->RegEB4 =3D 0x100;=
	/* X default value */
+		RegE9C =3D RegEBC =3D pdmpriv->RegE9C =3D pdmpriv->RegEBC =3D 0x0;		=
/* Y default value */
+	}
+
+	if ((RegE94 !=3D 0)/*&&(RegEA4 !=3D 0)*/)
+		_PHY_PathAFillIQKMatrix(pAdapter, bPathAOK, result, final_candidate,=
 (RegEA4 =3D=3D 0));
+
+	if (IS_92C_SERIAL(pHalData->VersionID)) {
+		if ((RegEB4 !=3D 0)/*&&(RegEC4 !=3D 0)*/)
+		_PHY_PathBFillIQKMatrix(pAdapter, bPathBOK, result, final_candidate,=
 (RegEC4 =3D=3D 0));
+	}
+
+	_PHY_SaveADDARegisters(pAdapter, IQK_BB_REG_92C, pdmpriv->IQK_BB_back=
up_recover, 9);
+}
+
+void rtl8723a_phy_lc_calibrate(struct rtw_adapter *pAdapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(pAdapter);
+	struct mlme_ext_priv *pmlmeext =3D &pAdapter->mlmeextpriv;
+	bool bStartContTx =3D false, bSingleTone =3D false, bCarrierSuppressi=
on =3D false;
+
+	/* ignore IQK when continuous Tx */
+	if (bStartContTx || bSingleTone || bCarrierSuppression)
+		return;
+
+	if (pmlmeext->sitesurvey_res.state =3D=3D SCAN_PROCESS)
+		return;
+
+	if (IS_92C_SERIAL(pHalData->VersionID)) {
+		_PHY_LCCalibrate(pAdapter, true);
+	} else {
+		/*  For 88C 1T1R */
+		_PHY_LCCalibrate(pAdapter, false);
+	}
+}
+
+void
+rtl8723a_phy_ap_calibrate(struct rtw_adapter *pAdapter, char delta)
+{
+}
diff --git a/drivers/staging/rtl8723au/hal/HalHWImg8723A_BB.c b/drivers=
/staging/rtl8723au/hal/HalHWImg8723A_BB.c
new file mode 100644
index 0000000..294e6a6
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/HalHWImg8723A_BB.c
@@ -0,0 +1,726 @@
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
+#include "odm_precomp.h"
+
+static bool CheckCondition(const u32  Condition, const u32  Hex)
+{
+	u32 _board     =3D (Hex & 0x000000FF);
+	u32 _interface =3D (Hex & 0x0000FF00) >> 8;
+	u32 _platform  =3D (Hex & 0x00FF0000) >> 16;
+	u32 cond =3D Condition;
+
+	if (Condition =3D=3D 0xCDCDCDCD)
+		return true;
+
+	cond =3D Condition & 0x000000FF;
+	if ((_board =3D=3D cond) && cond !=3D 0x00)
+		return false;
+
+	cond =3D Condition & 0x0000FF00;
+	cond =3D cond >> 8;
+	if ((_interface & cond) =3D=3D 0 && cond !=3D 0x07)
+		return false;
+
+	cond =3D Condition & 0x00FF0000;
+	cond =3D cond >> 16;
+	if ((_platform & cond) =3D=3D 0 && cond !=3D 0x0F)
+		return false;
+	return true;
+}
+
+/*********************************************************************=
*********
+*                           AGC_TAB_1T.TXT
+**********************************************************************=
********/
+
+static u32 Array_AGC_TAB_1T_8723A[] =3D {
+	0xC78, 0x7B000001,
+	0xC78, 0x7B010001,
+	0xC78, 0x7B020001,
+	0xC78, 0x7B030001,
+	0xC78, 0x7B040001,
+	0xC78, 0x7B050001,
+	0xC78, 0x7A060001,
+	0xC78, 0x79070001,
+	0xC78, 0x78080001,
+	0xC78, 0x77090001,
+	0xC78, 0x760A0001,
+	0xC78, 0x750B0001,
+	0xC78, 0x740C0001,
+	0xC78, 0x730D0001,
+	0xC78, 0x720E0001,
+	0xC78, 0x710F0001,
+	0xC78, 0x70100001,
+	0xC78, 0x6F110001,
+	0xC78, 0x6E120001,
+	0xC78, 0x6D130001,
+	0xC78, 0x6C140001,
+	0xC78, 0x6B150001,
+	0xC78, 0x6A160001,
+	0xC78, 0x69170001,
+	0xC78, 0x68180001,
+	0xC78, 0x67190001,
+	0xC78, 0x661A0001,
+	0xC78, 0x651B0001,
+	0xC78, 0x641C0001,
+	0xC78, 0x631D0001,
+	0xC78, 0x621E0001,
+	0xC78, 0x611F0001,
+	0xC78, 0x60200001,
+	0xC78, 0x49210001,
+	0xC78, 0x48220001,
+	0xC78, 0x47230001,
+	0xC78, 0x46240001,
+	0xC78, 0x45250001,
+	0xC78, 0x44260001,
+	0xC78, 0x43270001,
+	0xC78, 0x42280001,
+	0xC78, 0x41290001,
+	0xC78, 0x402A0001,
+	0xC78, 0x262B0001,
+	0xC78, 0x252C0001,
+	0xC78, 0x242D0001,
+	0xC78, 0x232E0001,
+	0xC78, 0x222F0001,
+	0xC78, 0x21300001,
+	0xC78, 0x20310001,
+	0xC78, 0x06320001,
+	0xC78, 0x05330001,
+	0xC78, 0x04340001,
+	0xC78, 0x03350001,
+	0xC78, 0x02360001,
+	0xC78, 0x01370001,
+	0xC78, 0x00380001,
+	0xC78, 0x00390001,
+	0xC78, 0x003A0001,
+	0xC78, 0x003B0001,
+	0xC78, 0x003C0001,
+	0xC78, 0x003D0001,
+	0xC78, 0x003E0001,
+	0xC78, 0x003F0001,
+	0xC78, 0x7B400001,
+	0xC78, 0x7B410001,
+	0xC78, 0x7B420001,
+	0xC78, 0x7B430001,
+	0xC78, 0x7B440001,
+	0xC78, 0x7B450001,
+	0xC78, 0x7A460001,
+	0xC78, 0x79470001,
+	0xC78, 0x78480001,
+	0xC78, 0x77490001,
+	0xC78, 0x764A0001,
+	0xC78, 0x754B0001,
+	0xC78, 0x744C0001,
+	0xC78, 0x734D0001,
+	0xC78, 0x724E0001,
+	0xC78, 0x714F0001,
+	0xC78, 0x70500001,
+	0xC78, 0x6F510001,
+	0xC78, 0x6E520001,
+	0xC78, 0x6D530001,
+	0xC78, 0x6C540001,
+	0xC78, 0x6B550001,
+	0xC78, 0x6A560001,
+	0xC78, 0x69570001,
+	0xC78, 0x68580001,
+	0xC78, 0x67590001,
+	0xC78, 0x665A0001,
+	0xC78, 0x655B0001,
+	0xC78, 0x645C0001,
+	0xC78, 0x635D0001,
+	0xC78, 0x625E0001,
+	0xC78, 0x615F0001,
+	0xC78, 0x60600001,
+	0xC78, 0x49610001,
+	0xC78, 0x48620001,
+	0xC78, 0x47630001,
+	0xC78, 0x46640001,
+	0xC78, 0x45650001,
+	0xC78, 0x44660001,
+	0xC78, 0x43670001,
+	0xC78, 0x42680001,
+	0xC78, 0x41690001,
+	0xC78, 0x406A0001,
+	0xC78, 0x266B0001,
+	0xC78, 0x256C0001,
+	0xC78, 0x246D0001,
+	0xC78, 0x236E0001,
+	0xC78, 0x226F0001,
+	0xC78, 0x21700001,
+	0xC78, 0x20710001,
+	0xC78, 0x06720001,
+	0xC78, 0x05730001,
+	0xC78, 0x04740001,
+	0xC78, 0x03750001,
+	0xC78, 0x02760001,
+	0xC78, 0x01770001,
+	0xC78, 0x00780001,
+	0xC78, 0x00790001,
+	0xC78, 0x007A0001,
+	0xC78, 0x007B0001,
+	0xC78, 0x007C0001,
+	0xC78, 0x007D0001,
+	0xC78, 0x007E0001,
+	0xC78, 0x007F0001,
+	0xC78, 0x3800001E,
+	0xC78, 0x3801001E,
+	0xC78, 0x3802001E,
+	0xC78, 0x3803001E,
+	0xC78, 0x3804001E,
+	0xC78, 0x3805001E,
+	0xC78, 0x3806001E,
+	0xC78, 0x3807001E,
+	0xC78, 0x3808001E,
+	0xC78, 0x3C09001E,
+	0xC78, 0x3E0A001E,
+	0xC78, 0x400B001E,
+	0xC78, 0x440C001E,
+	0xC78, 0x480D001E,
+	0xC78, 0x4C0E001E,
+	0xC78, 0x500F001E,
+	0xC78, 0x5210001E,
+	0xC78, 0x5611001E,
+	0xC78, 0x5A12001E,
+	0xC78, 0x5E13001E,
+	0xC78, 0x6014001E,
+	0xC78, 0x6015001E,
+	0xC78, 0x6016001E,
+	0xC78, 0x6217001E,
+	0xC78, 0x6218001E,
+	0xC78, 0x6219001E,
+	0xC78, 0x621A001E,
+	0xC78, 0x621B001E,
+	0xC78, 0x621C001E,
+	0xC78, 0x621D001E,
+	0xC78, 0x621E001E,
+	0xC78, 0x621F001E,
+};
+
+#define READ_NEXT_PAIR(v1, v2, i)			\
+	do {						\
+		i +=3D 2; v1 =3D Array[i]; v2 =3D Array[i+1];	\
+	} while (0)
+
+void ODM_ReadAndConfig_AGC_TAB_1T_8723A(struct dm_odm_t *pDM_Odm)
+{
+
+	u32 hex;
+	u32 i;
+	u8 platform =3D 0x04;
+	u8 interfaceValue   =3D pDM_Odm->SupportInterface;
+	u8 board =3D pDM_Odm->BoardType;
+	u32 ArrayLen =3D sizeof(Array_AGC_TAB_1T_8723A)/sizeof(u32);
+	u32 *Array =3D Array_AGC_TAB_1T_8723A;
+
+	hex =3D board;
+	hex +=3D interfaceValue << 8;
+	hex +=3D platform << 16;
+	hex +=3D 0xFF000000;
+	for (i =3D 0; i < ArrayLen; i +=3D 2) {
+		u32 v1 =3D Array[i];
+		u32 v2 =3D Array[i+1];
+
+		/*  This (offset, data) pair meets the condition. */
+		if (v1 < 0xCDCDCDCD) {
+			odm_ConfigBB_AGC_8723A(pDM_Odm, v1, bMaskDWord, v2);
+			continue;
+		} else {
+			if (!CheckCondition(Array[i], hex)) {
+				/*  Discard the following (offset, data) pairs. */
+				READ_NEXT_PAIR(v1, v2, i);
+				while (v2 !=3D 0xDEAD &&
+				       v2 !=3D 0xCDEF &&
+				       v2 !=3D 0xCDCD && i < ArrayLen - 2)
+					READ_NEXT_PAIR(v1, v2, i);
+				i -=3D 2; /*  prevent from for-loop +=3D 2 */
+			} else {
+				/*  Configure matched pairs and skip to end of if-else. */
+				READ_NEXT_PAIR(v1, v2, i);
+				while (v2 !=3D 0xDEAD &&
+				       v2 !=3D 0xCDEF &&
+				       v2 !=3D 0xCDCD && i < ArrayLen - 2) {
+					odm_ConfigBB_AGC_8723A(pDM_Odm, v1, bMaskDWord, v2);
+					READ_NEXT_PAIR(v1, v2, i);
+				}
+				while (v2 !=3D 0xDEAD && i < ArrayLen - 2)
+					READ_NEXT_PAIR(v1, v2, i);
+			}
+		}
+	}
+}
+
+/*********************************************************************=
*********
+*                           PHY_REG_1T.TXT
+**********************************************************************=
********/
+
+static u32 Array_PHY_REG_1T_8723A[] =3D {
+	0x800, 0x80040000,
+	0x804, 0x00000003,
+	0x808, 0x0000FC00,
+	0x80C, 0x0000000A,
+	0x810, 0x10001331,
+	0x814, 0x020C3D10,
+	0x818, 0x02200385,
+	0x81C, 0x00000000,
+	0x820, 0x01000100,
+	0x824, 0x00390004,
+	0x828, 0x00000000,
+	0x82C, 0x00000000,
+	0x830, 0x00000000,
+	0x834, 0x00000000,
+	0x838, 0x00000000,
+	0x83C, 0x00000000,
+	0x840, 0x00010000,
+	0x844, 0x00000000,
+	0x848, 0x00000000,
+	0x84C, 0x00000000,
+	0x850, 0x00000000,
+	0x854, 0x00000000,
+	0x858, 0x569A569A,
+	0x85C, 0x001B25A4,
+	0x860, 0x66F60110,
+	0x864, 0x061F0130,
+	0x868, 0x00000000,
+	0x86C, 0x32323200,
+	0x870, 0x07000760,
+	0x874, 0x22004000,
+	0x878, 0x00000808,
+	0x87C, 0x00000000,
+	0x880, 0xC0083070,
+	0x884, 0x000004D5,
+	0x888, 0x00000000,
+	0x88C, 0xCCC000C0,
+	0x890, 0x00000800,
+	0x894, 0xFFFFFFFE,
+	0x898, 0x40302010,
+	0x89C, 0x00706050,
+	0x900, 0x00000000,
+	0x904, 0x00000023,
+	0x908, 0x00000000,
+	0x90C, 0x81121111,
+	0xA00, 0x00D047C8,
+	0xA04, 0x80FF000C,
+	0xA08, 0x8C838300,
+	0xA0C, 0x2E68120F,
+	0xA10, 0x9500BB78,
+	0xA14, 0x11144028,
+	0xA18, 0x00881117,
+	0xA1C, 0x89140F00,
+	0xA20, 0x1A1B0000,
+	0xA24, 0x090E1317,
+	0xA28, 0x00000204,
+	0xA2C, 0x00D30000,
+	0xA70, 0x101FBF00,
+	0xA74, 0x00000007,
+	0xA78, 0x00000900,
+	0xC00, 0x48071D40,
+	0xC04, 0x03A05611,
+	0xC08, 0x000000E4,
+	0xC0C, 0x6C6C6C6C,
+	0xC10, 0x08800000,
+	0xC14, 0x40000100,
+	0xC18, 0x08800000,
+	0xC1C, 0x40000100,
+	0xC20, 0x00000000,
+	0xC24, 0x00000000,
+	0xC28, 0x00000000,
+	0xC2C, 0x00000000,
+	0xC30, 0x69E9AC44,
+	0xFF0F011F, 0xABCD,
+	0xC34, 0x469652CF,
+	0xCDCDCDCD, 0xCDCD,
+	0xC34, 0x469652AF,
+	0xFF0F011F, 0xDEAD,
+	0xC38, 0x49795994,
+	0xC3C, 0x0A97971C,
+	0xC40, 0x1F7C403F,
+	0xC44, 0x000100B7,
+	0xC48, 0xEC020107,
+	0xC4C, 0x007F037F,
+	0xC50, 0x69543420,
+	0xC54, 0x43BC0094,
+	0xC58, 0x69543420,
+	0xC5C, 0x433C0094,
+	0xC60, 0x00000000,
+	0xFF0F011F, 0xABCD,
+	0xC64, 0x7116848B,
+	0xCDCDCDCD, 0xCDCD,
+	0xC64, 0x7112848B,
+	0xFF0F011F, 0xDEAD,
+	0xC68, 0x47C00BFF,
+	0xC6C, 0x00000036,
+	0xC70, 0x2C7F000D,
+	0xC74, 0x018610DB,
+	0xC78, 0x0000001F,
+	0xC7C, 0x00B91612,
+	0xC80, 0x40000100,
+	0xC84, 0x20F60000,
+	0xC88, 0x40000100,
+	0xC8C, 0x20200000,
+	0xC90, 0x00121820,
+	0xC94, 0x00000000,
+	0xC98, 0x00121820,
+	0xC9C, 0x00007F7F,
+	0xCA0, 0x00000000,
+	0xCA4, 0x00000080,
+	0xCA8, 0x00000000,
+	0xCAC, 0x00000000,
+	0xCB0, 0x00000000,
+	0xCB4, 0x00000000,
+	0xCB8, 0x00000000,
+	0xCBC, 0x28000000,
+	0xCC0, 0x00000000,
+	0xCC4, 0x00000000,
+	0xCC8, 0x00000000,
+	0xCCC, 0x00000000,
+	0xCD0, 0x00000000,
+	0xCD4, 0x00000000,
+	0xCD8, 0x64B22427,
+	0xCDC, 0x00766932,
+	0xCE0, 0x00222222,
+	0xCE4, 0x00000000,
+	0xCE8, 0x37644302,
+	0xCEC, 0x2F97D40C,
+	0xD00, 0x00080740,
+	0xD04, 0x00020401,
+	0xD08, 0x0000907F,
+	0xD0C, 0x20010201,
+	0xD10, 0xA0633333,
+	0xD14, 0x3333BC43,
+	0xD18, 0x7A8F5B6B,
+	0xD2C, 0xCC979975,
+	0xD30, 0x00000000,
+	0xD34, 0x80608000,
+	0xD38, 0x00000000,
+	0xD3C, 0x00027293,
+	0xD40, 0x00000000,
+	0xD44, 0x00000000,
+	0xD48, 0x00000000,
+	0xD4C, 0x00000000,
+	0xD50, 0x6437140A,
+	0xD54, 0x00000000,
+	0xD58, 0x00000000,
+	0xD5C, 0x30032064,
+	0xD60, 0x4653DE68,
+	0xD64, 0x04518A3C,
+	0xD68, 0x00002101,
+	0xD6C, 0x2A201C16,
+	0xD70, 0x1812362E,
+	0xD74, 0x322C2220,
+	0xD78, 0x000E3C24,
+	0xE00, 0x2A2A2A2A,
+	0xE04, 0x2A2A2A2A,
+	0xE08, 0x03902A2A,
+	0xE10, 0x2A2A2A2A,
+	0xE14, 0x2A2A2A2A,
+	0xE18, 0x2A2A2A2A,
+	0xE1C, 0x2A2A2A2A,
+	0xE28, 0x00000000,
+	0xE30, 0x1000DC1F,
+	0xE34, 0x10008C1F,
+	0xE38, 0x02140102,
+	0xE3C, 0x681604C2,
+	0xE40, 0x01007C00,
+	0xE44, 0x01004800,
+	0xE48, 0xFB000000,
+	0xE4C, 0x000028D1,
+	0xE50, 0x1000DC1F,
+	0xE54, 0x10008C1F,
+	0xE58, 0x02140102,
+	0xE5C, 0x28160D05,
+	0xE60, 0x00000008,
+	0xE68, 0x001B25A4,
+	0xE6C, 0x631B25A0,
+	0xE70, 0x631B25A0,
+	0xE74, 0x081B25A0,
+	0xE78, 0x081B25A0,
+	0xE7C, 0x081B25A0,
+	0xE80, 0x081B25A0,
+	0xE84, 0x631B25A0,
+	0xE88, 0x081B25A0,
+	0xE8C, 0x631B25A0,
+	0xED0, 0x631B25A0,
+	0xED4, 0x631B25A0,
+	0xED8, 0x631B25A0,
+	0xEDC, 0x001B25A0,
+	0xEE0, 0x001B25A0,
+	0xEEC, 0x6B1B25A0,
+	0xF14, 0x00000003,
+	0xF4C, 0x00000000,
+	0xF00, 0x00000300,
+};
+
+void ODM_ReadAndConfig_PHY_REG_1T_8723A(struct dm_odm_t *pDM_Odm)
+{
+	u32 hex =3D 0;
+	u32 i =3D 0;
+	u8  platform =3D 0x04;
+	u8  interfaceValue =3D pDM_Odm->SupportInterface;
+	u8  board =3D pDM_Odm->BoardType;
+	u32 ArrayLen =3D sizeof(Array_PHY_REG_1T_8723A)/sizeof(u32);
+	u32 *Array =3D Array_PHY_REG_1T_8723A;
+
+	hex +=3D board;
+	hex +=3D interfaceValue << 8;
+	hex +=3D platform << 16;
+	hex +=3D 0xFF000000;
+	for (i =3D 0; i < ArrayLen; i +=3D 2) {
+		u32 v1 =3D Array[i];
+		u32 v2 =3D Array[i+1];
+
+		/*  This (offset, data) pair meets the condition. */
+		if (v1 < 0xCDCDCDCD) {
+			odm_ConfigBB_PHY_8723A(pDM_Odm, v1, bMaskDWord, v2);
+			continue;
+		} else {
+			if (!CheckCondition(Array[i], hex)) {
+				/*  Discard the following (offset, data) pairs. */
+				READ_NEXT_PAIR(v1, v2, i);
+				while (v2 !=3D 0xDEAD &&
+				       v2 !=3D 0xCDEF &&
+				       v2 !=3D 0xCDCD && i < ArrayLen - 2)
+					READ_NEXT_PAIR(v1, v2, i);
+				i -=3D 2; /*  prevent from for-loop +=3D 2 */
+			} else {
+				/*  Configure matched pairs and skip to end of if-else. */
+				READ_NEXT_PAIR(v1, v2, i);
+				while (v2 !=3D 0xDEAD &&
+				       v2 !=3D 0xCDEF &&
+				       v2 !=3D 0xCDCD && i < ArrayLen - 2) {
+					odm_ConfigBB_PHY_8723A(pDM_Odm, v1, bMaskDWord, v2);
+					READ_NEXT_PAIR(v1, v2, i);
+				}
+				while (v2 !=3D 0xDEAD && i < ArrayLen - 2)
+					READ_NEXT_PAIR(v1, v2, i);
+			}
+		}
+	}
+}
+
+/*********************************************************************=
*********
+*                           PHY_REG_MP.TXT
+**********************************************************************=
********/
+
+static u32 Array_PHY_REG_MP_8723A[] =3D {
+	0xC30, 0x69E9AC4A,
+	0xC3C, 0x0A979718,
+};
+
+void ODM_ReadAndConfig_PHY_REG_MP_8723A(struct dm_odm_t *pDM_Odm)
+{
+	u32     hex         =3D 0;
+	u32     i           =3D 0;
+	u8     platform    =3D 0x04;
+	u8     interfaceValue   =3D pDM_Odm->SupportInterface;
+	u8     board       =3D pDM_Odm->BoardType;
+	u32     ArrayLen    =3D sizeof(Array_PHY_REG_MP_8723A)/sizeof(u32);
+	u32 *Array       =3D Array_PHY_REG_MP_8723A;
+
+	hex +=3D board;
+	hex +=3D interfaceValue << 8;
+	hex +=3D platform << 16;
+	hex +=3D 0xFF000000;
+	for (i =3D 0; i < ArrayLen; i +=3D 2) {
+		u32 v1 =3D Array[i];
+		u32 v2 =3D Array[i+1];
+
+		/*  This (offset, data) pair meets the condition. */
+		if (v1 < 0xCDCDCDCD) {
+			odm_ConfigBB_PHY_8723A(pDM_Odm, v1, bMaskDWord, v2);
+			continue;
+		} else {
+			if (!CheckCondition(Array[i], hex)) {
+				/* Discard the following (offset, data) pairs. */
+				READ_NEXT_PAIR(v1, v2, i);
+				while (v2 !=3D 0xDEAD &&
+				       v2 !=3D 0xCDEF &&
+				       v2 !=3D 0xCDCD && i < ArrayLen - 2)
+					READ_NEXT_PAIR(v1, v2, i);
+				i -=3D 2; /*  prevent from for-loop +=3D 2 */
+			} else {
+				/* Configure matched pairs and skip to end of if-else. */
+				READ_NEXT_PAIR(v1, v2, i);
+				while (v2 !=3D 0xDEAD &&
+				       v2 !=3D 0xCDEF &&
+				       v2 !=3D 0xCDCD && i < ArrayLen - 2) {
+					odm_ConfigBB_PHY_8723A(pDM_Odm, v1, bMaskDWord, v2);
+					READ_NEXT_PAIR(v1, v2, i);
+				}
+				while (v2 !=3D 0xDEAD && i < ArrayLen - 2)
+					READ_NEXT_PAIR(v1, v2, i);
+			}
+		}
+	}
+}
+
+/*********************************************************************=
*********
+*                           PHY_REG_PG.TXT
+**********************************************************************=
********/
+
+static u32 Array_PHY_REG_PG_8723A[] =3D {
+	0xE00, 0xFFFFFFFF, 0x0A0C0C0C,
+	0xE04, 0xFFFFFFFF, 0x02040608,
+	0xE08, 0x0000FF00, 0x00000000,
+	0x86C, 0xFFFFFF00, 0x00000000,
+	0xE10, 0xFFFFFFFF, 0x0A0C0D0E,
+	0xE14, 0xFFFFFFFF, 0x02040608,
+	0xE18, 0xFFFFFFFF, 0x0A0C0D0E,
+	0xE1C, 0xFFFFFFFF, 0x02040608,
+	0x830, 0xFFFFFFFF, 0x0A0C0C0C,
+	0x834, 0xFFFFFFFF, 0x02040608,
+	0x838, 0xFFFFFF00, 0x00000000,
+	0x86C, 0x000000FF, 0x00000000,
+	0x83C, 0xFFFFFFFF, 0x0A0C0D0E,
+	0x848, 0xFFFFFFFF, 0x02040608,
+	0x84C, 0xFFFFFFFF, 0x0A0C0D0E,
+	0x868, 0xFFFFFFFF, 0x02040608,
+	0xE00, 0xFFFFFFFF, 0x00000000,
+	0xE04, 0xFFFFFFFF, 0x00000000,
+	0xE08, 0x0000FF00, 0x00000000,
+	0x86C, 0xFFFFFF00, 0x00000000,
+	0xE10, 0xFFFFFFFF, 0x00000000,
+	0xE14, 0xFFFFFFFF, 0x00000000,
+	0xE18, 0xFFFFFFFF, 0x00000000,
+	0xE1C, 0xFFFFFFFF, 0x00000000,
+	0x830, 0xFFFFFFFF, 0x00000000,
+	0x834, 0xFFFFFFFF, 0x00000000,
+	0x838, 0xFFFFFF00, 0x00000000,
+	0x86C, 0x000000FF, 0x00000000,
+	0x83C, 0xFFFFFFFF, 0x00000000,
+	0x848, 0xFFFFFFFF, 0x00000000,
+	0x84C, 0xFFFFFFFF, 0x00000000,
+	0x868, 0xFFFFFFFF, 0x00000000,
+	0xE00, 0xFFFFFFFF, 0x04040404,
+	0xE04, 0xFFFFFFFF, 0x00020204,
+	0xE08, 0x0000FF00, 0x00000000,
+	0x86C, 0xFFFFFF00, 0x00000000,
+	0xE10, 0xFFFFFFFF, 0x06060606,
+	0xE14, 0xFFFFFFFF, 0x00020406,
+	0xE18, 0xFFFFFFFF, 0x00000000,
+	0xE1C, 0xFFFFFFFF, 0x00000000,
+	0x830, 0xFFFFFFFF, 0x04040404,
+	0x834, 0xFFFFFFFF, 0x00020204,
+	0x838, 0xFFFFFF00, 0x00000000,
+	0x86C, 0x000000FF, 0x00000000,
+	0x83C, 0xFFFFFFFF, 0x06060606,
+	0x848, 0xFFFFFFFF, 0x00020406,
+	0x84C, 0xFFFFFFFF, 0x00000000,
+	0x868, 0xFFFFFFFF, 0x00000000,
+	0xE00, 0xFFFFFFFF, 0x00000000,
+	0xE04, 0xFFFFFFFF, 0x00000000,
+	0xE08, 0x0000FF00, 0x00000000,
+	0x86C, 0xFFFFFF00, 0x00000000,
+	0xE10, 0xFFFFFFFF, 0x00000000,
+	0xE14, 0xFFFFFFFF, 0x00000000,
+	0xE18, 0xFFFFFFFF, 0x00000000,
+	0xE1C, 0xFFFFFFFF, 0x00000000,
+	0x830, 0xFFFFFFFF, 0x00000000,
+	0x834, 0xFFFFFFFF, 0x00000000,
+	0x838, 0xFFFFFF00, 0x00000000,
+	0x86C, 0x000000FF, 0x00000000,
+	0x83C, 0xFFFFFFFF, 0x00000000,
+	0x848, 0xFFFFFFFF, 0x00000000,
+	0x84C, 0xFFFFFFFF, 0x00000000,
+	0x868, 0xFFFFFFFF, 0x00000000,
+	0xE00, 0xFFFFFFFF, 0x00000000,
+	0xE04, 0xFFFFFFFF, 0x00000000,
+	0xE08, 0x0000FF00, 0x00000000,
+	0x86C, 0xFFFFFF00, 0x00000000,
+	0xE10, 0xFFFFFFFF, 0x00000000,
+	0xE14, 0xFFFFFFFF, 0x00000000,
+	0xE18, 0xFFFFFFFF, 0x00000000,
+	0xE1C, 0xFFFFFFFF, 0x00000000,
+	0x830, 0xFFFFFFFF, 0x00000000,
+	0x834, 0xFFFFFFFF, 0x00000000,
+	0x838, 0xFFFFFF00, 0x00000000,
+	0x86C, 0x000000FF, 0x00000000,
+	0x83C, 0xFFFFFFFF, 0x00000000,
+	0x848, 0xFFFFFFFF, 0x00000000,
+	0x84C, 0xFFFFFFFF, 0x00000000,
+	0x868, 0xFFFFFFFF, 0x00000000,
+	0xE00, 0xFFFFFFFF, 0x04040404,
+	0xE04, 0xFFFFFFFF, 0x00020204,
+	0xE08, 0x0000FF00, 0x00000000,
+	0x86C, 0xFFFFFF00, 0x00000000,
+	0xE10, 0xFFFFFFFF, 0x00000000,
+	0xE14, 0xFFFFFFFF, 0x00000000,
+	0xE18, 0xFFFFFFFF, 0x00000000,
+	0xE1C, 0xFFFFFFFF, 0x00000000,
+	0x830, 0xFFFFFFFF, 0x04040404,
+	0x834, 0xFFFFFFFF, 0x00020204,
+	0x838, 0xFFFFFF00, 0x00000000,
+	0x86C, 0x000000FF, 0x00000000,
+	0x83C, 0xFFFFFFFF, 0x00000000,
+	0x848, 0xFFFFFFFF, 0x00000000,
+	0x84C, 0xFFFFFFFF, 0x00000000,
+	0x868, 0xFFFFFFFF, 0x00000000,
+	0xE00, 0xFFFFFFFF, 0x00000000,
+	0xE04, 0xFFFFFFFF, 0x00000000,
+	0xE08, 0x0000FF00, 0x00000000,
+	0x86C, 0xFFFFFF00, 0x00000000,
+	0xE10, 0xFFFFFFFF, 0x00000000,
+	0xE14, 0xFFFFFFFF, 0x00000000,
+	0xE18, 0xFFFFFFFF, 0x00000000,
+	0xE1C, 0xFFFFFFFF, 0x00000000,
+	0x830, 0xFFFFFFFF, 0x00000000,
+	0x834, 0xFFFFFFFF, 0x00000000,
+	0x838, 0xFFFFFF00, 0x00000000,
+	0x86C, 0x000000FF, 0x00000000,
+	0x83C, 0xFFFFFFFF, 0x00000000,
+	0x848, 0xFFFFFFFF, 0x00000000,
+	0x84C, 0xFFFFFFFF, 0x00000000,
+	0x868, 0xFFFFFFFF, 0x00000000,
+};
+
+void ODM_ReadAndConfig_PHY_REG_PG_8723A(struct dm_odm_t *pDM_Odm)
+{
+	u32     hex =3D 0;
+	u32     i           =3D 0;
+	u8     platform    =3D 0x04;
+	u8     interfaceValue   =3D pDM_Odm->SupportInterface;
+	u8     board       =3D pDM_Odm->BoardType;
+	u32     ArrayLen    =3D sizeof(Array_PHY_REG_PG_8723A)/sizeof(u32);
+	u32 *Array       =3D Array_PHY_REG_PG_8723A;
+
+	hex +=3D board;
+	hex +=3D interfaceValue << 8;
+	hex +=3D platform << 16;
+	hex +=3D 0xFF000000;
+	for (i =3D 0; i < ArrayLen; i +=3D 3) {
+		u32 v1 =3D Array[i];
+		u32 v2 =3D Array[i+1];
+		u32 v3 =3D Array[i+2];
+
+		/*  this line is a line of pure_body */
+		if (v1 < 0xCDCDCDCD) {
+			 odm_ConfigBB_PHY_REG_PG_8723A(pDM_Odm, v1, v2, v3);
+			 continue;
+		} else { /*  this line is the start of branch */
+			if (!CheckCondition(Array[i], hex)) {
+				/*  don't need the hw_body */
+				i +=3D 2; /*  skip the pair of expression */
+				v1 =3D Array[i];
+				v2 =3D Array[i+1];
+				v3 =3D Array[i+2];
+				while (v2 !=3D 0xDEAD) {
+					i +=3D 3;
+					v1 =3D Array[i];
+					v2 =3D Array[i+1];
+					v3 =3D Array[i+1];
+				}
+			}
+		}
+	}
+}
diff --git a/drivers/staging/rtl8723au/hal/HalHWImg8723A_MAC.c b/driver=
s/staging/rtl8723au/hal/HalHWImg8723A_MAC.c
new file mode 100644
index 0000000..1207145
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/HalHWImg8723A_MAC.c
@@ -0,0 +1,188 @@
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
+#include "odm_precomp.h"
+
+static bool CheckCondition(const u32  Condition, const u32  Hex)
+{
+	u32 _board     =3D (Hex & 0x000000FF);
+	u32 _interface =3D (Hex & 0x0000FF00) >> 8;
+	u32 _platform  =3D (Hex & 0x00FF0000) >> 16;
+	u32 cond =3D Condition;
+
+	if (Condition =3D=3D 0xCDCDCDCD)
+		return true;
+
+	cond =3D Condition & 0x000000FF;
+	if ((_board =3D=3D cond) && cond !=3D 0x00)
+		return false;
+
+	cond =3D Condition & 0x0000FF00;
+	cond =3D cond >> 8;
+	if ((_interface & cond) =3D=3D 0 && cond !=3D 0x07)
+		return false;
+
+	cond =3D Condition & 0x00FF0000;
+	cond =3D cond >> 16;
+	if ((_platform & cond) =3D=3D 0 && cond !=3D 0x0F)
+		return false;
+	return true;
+}
+
+/*********************************************************************=
*********
+*                           MAC_REG.TXT
+**********************************************************************=
********/
+
+static u32 Array_MAC_REG_8723A[] =3D {
+		0x420, 0x00000080,
+		0x423, 0x00000000,
+		0x430, 0x00000000,
+		0x431, 0x00000000,
+		0x432, 0x00000000,
+		0x433, 0x00000001,
+		0x434, 0x00000004,
+		0x435, 0x00000005,
+		0x436, 0x00000006,
+		0x437, 0x00000007,
+		0x438, 0x00000000,
+		0x439, 0x00000000,
+		0x43A, 0x00000000,
+		0x43B, 0x00000001,
+		0x43C, 0x00000004,
+		0x43D, 0x00000005,
+		0x43E, 0x00000006,
+		0x43F, 0x00000007,
+		0x440, 0x0000005D,
+		0x441, 0x00000001,
+		0x442, 0x00000000,
+		0x444, 0x00000015,
+		0x445, 0x000000F0,
+		0x446, 0x0000000F,
+		0x447, 0x00000000,
+		0x458, 0x00000041,
+		0x459, 0x000000A8,
+		0x45A, 0x00000072,
+		0x45B, 0x000000B9,
+		0x460, 0x00000066,
+		0x461, 0x00000066,
+		0x462, 0x00000008,
+		0x463, 0x00000003,
+		0x4C8, 0x000000FF,
+		0x4C9, 0x00000008,
+		0x4CC, 0x000000FF,
+		0x4CD, 0x000000FF,
+		0x4CE, 0x00000001,
+		0x500, 0x00000026,
+		0x501, 0x000000A2,
+		0x502, 0x0000002F,
+		0x503, 0x00000000,
+		0x504, 0x00000028,
+		0x505, 0x000000A3,
+		0x506, 0x0000005E,
+		0x507, 0x00000000,
+		0x508, 0x0000002B,
+		0x509, 0x000000A4,
+		0x50A, 0x0000005E,
+		0x50B, 0x00000000,
+		0x50C, 0x0000004F,
+		0x50D, 0x000000A4,
+		0x50E, 0x00000000,
+		0x50F, 0x00000000,
+		0x512, 0x0000001C,
+		0x514, 0x0000000A,
+		0x515, 0x00000010,
+		0x516, 0x0000000A,
+		0x517, 0x00000010,
+		0x51A, 0x00000016,
+		0x524, 0x0000000F,
+		0x525, 0x0000004F,
+		0x546, 0x00000040,
+		0x547, 0x00000000,
+		0x550, 0x00000010,
+		0x551, 0x00000010,
+		0x559, 0x00000002,
+		0x55A, 0x00000002,
+		0x55D, 0x000000FF,
+		0x605, 0x00000030,
+		0x608, 0x0000000E,
+		0x609, 0x0000002A,
+		0x652, 0x00000020,
+		0x63C, 0x0000000A,
+		0x63D, 0x0000000A,
+		0x63E, 0x0000000E,
+		0x63F, 0x0000000E,
+		0x66E, 0x00000005,
+		0x700, 0x00000021,
+		0x701, 0x00000043,
+		0x702, 0x00000065,
+		0x703, 0x00000087,
+		0x708, 0x00000021,
+		0x709, 0x00000043,
+		0x70A, 0x00000065,
+		0x70B, 0x00000087,
+};
+
+void ODM_ReadAndConfig_MAC_REG_8723A(struct dm_odm_t *pDM_Odm)
+{
+	#define READ_NEXT_PAIR(v1, v2, i)			\
+		 do {						\
+			i +=3D 2; v1 =3D Array[i]; v2 =3D Array[i+1];	\
+		 } while (0)
+
+	u32     hex         =3D 0;
+	u32     i           =3D 0;
+	u8     platform    =3D 0x04;
+	u8     interfaceValue   =3D pDM_Odm->SupportInterface;
+	u8     board       =3D pDM_Odm->BoardType;
+	u32     ArrayLen    =3D sizeof(Array_MAC_REG_8723A)/sizeof(u32);
+	u32 *Array       =3D Array_MAC_REG_8723A;
+
+	hex +=3D board;
+	hex +=3D interfaceValue << 8;
+	hex +=3D platform << 16;
+	hex +=3D 0xFF000000;
+	for (i =3D 0; i < ArrayLen; i +=3D 2) {
+		u32 v1 =3D Array[i];
+		u32 v2 =3D Array[i+1];
+
+		/*  This (offset, data) pair meets the condition. */
+		if (v1 < 0xCDCDCDCD) {
+			odm_ConfigMAC_8723A(pDM_Odm, v1, (u8)v2);
+			continue;
+		} else {
+			if (!CheckCondition(Array[i], hex)) {
+				/* Discard the following (offset, data) pairs. */
+				READ_NEXT_PAIR(v1, v2, i);
+				while (v2 !=3D 0xDEAD &&
+				       v2 !=3D 0xCDEF &&
+				       v2 !=3D 0xCDCD && i < ArrayLen - 2)
+					READ_NEXT_PAIR(v1, v2, i);
+				i -=3D 2; /*  prevent from for-loop +=3D 2 */
+			} else {
+				/*  Configure matched pairs and skip to end of if-else. */
+				READ_NEXT_PAIR(v1, v2, i);
+				while (v2 !=3D 0xDEAD &&
+				       v2 !=3D 0xCDEF &&
+				       v2 !=3D 0xCDCD && i < ArrayLen - 2) {
+					odm_ConfigMAC_8723A(pDM_Odm, v1, (u8)v2);
+					READ_NEXT_PAIR(v1, v2, i);
+				}
+
+				while (v2 !=3D 0xDEAD && i < ArrayLen - 2)
+					READ_NEXT_PAIR(v1, v2, i);
+			}
+		}
+	}
+}
diff --git a/drivers/staging/rtl8723au/hal/HalHWImg8723A_RF.c b/drivers=
/staging/rtl8723au/hal/HalHWImg8723A_RF.c
new file mode 100644
index 0000000..0f2ae05
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/HalHWImg8723A_RF.c
@@ -0,0 +1,259 @@
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
+#include "odm_precomp.h"
+
+static bool CheckCondition(const u32  Condition, const u32  Hex)
+{
+	u32 _board     =3D (Hex & 0x000000FF);
+	u32 _interface =3D (Hex & 0x0000FF00) >> 8;
+	u32 _platform  =3D (Hex & 0x00FF0000) >> 16;
+	u32 cond =3D Condition;
+
+	if (Condition =3D=3D 0xCDCDCDCD)
+		return true;
+
+	cond =3D Condition & 0x000000FF;
+	if ((_board =3D=3D cond) && cond !=3D 0x00)
+		return false;
+
+	cond =3D Condition & 0x0000FF00;
+	cond =3D cond >> 8;
+	if ((_interface & cond) =3D=3D 0 && cond !=3D 0x07)
+		return false;
+
+	cond =3D Condition & 0x00FF0000;
+	cond =3D cond >> 16;
+	if ((_platform & cond) =3D=3D 0 && cond !=3D 0x0F)
+		return false;
+	return true;
+}
+
+/*********************************************************************=
*********
+*                           RadioA_1T.TXT
+**********************************************************************=
********/
+
+static u32 Array_RadioA_1T_8723A[] =3D {
+	0x000, 0x00030159,
+	0x001, 0x00031284,
+	0x002, 0x00098000,
+	0xFF0F011F, 0xABCD,
+	0x003, 0x00018C63,
+	0xCDCDCDCD, 0xCDCD,
+	0x003, 0x00039C63,
+	0xFF0F011F, 0xDEAD,
+	0x004, 0x000210E7,
+	0x009, 0x0002044F,
+	0x00A, 0x0001A3F1,
+	0x00B, 0x00014787,
+	0x00C, 0x000896FE,
+	0x00D, 0x0000E02C,
+	0x00E, 0x00039CE7,
+	0x00F, 0x00000451,
+	0x019, 0x00000000,
+	0x01A, 0x00030355,
+	0x01B, 0x00060A00,
+	0x01C, 0x000FC378,
+	0x01D, 0x000A1250,
+	0x01E, 0x0000024F,
+	0x01F, 0x00000000,
+	0x020, 0x0000B614,
+	0x021, 0x0006C000,
+	0x022, 0x00000000,
+	0x023, 0x00001558,
+	0x024, 0x00000060,
+	0x025, 0x00000483,
+	0x026, 0x0004F000,
+	0x027, 0x000EC7D9,
+	0x028, 0x00057730,
+	0x029, 0x00004783,
+	0x02A, 0x00000001,
+	0x02B, 0x00021334,
+	0x02A, 0x00000000,
+	0x02B, 0x00000054,
+	0x02A, 0x00000001,
+	0x02B, 0x00000808,
+	0x02B, 0x00053333,
+	0x02C, 0x0000000C,
+	0x02A, 0x00000002,
+	0x02B, 0x00000808,
+	0x02B, 0x0005B333,
+	0x02C, 0x0000000D,
+	0x02A, 0x00000003,
+	0x02B, 0x00000808,
+	0x02B, 0x00063333,
+	0x02C, 0x0000000D,
+	0x02A, 0x00000004,
+	0x02B, 0x00000808,
+	0x02B, 0x0006B333,
+	0x02C, 0x0000000D,
+	0x02A, 0x00000005,
+	0x02B, 0x00000808,
+	0x02B, 0x00073333,
+	0x02C, 0x0000000D,
+	0x02A, 0x00000006,
+	0x02B, 0x00000709,
+	0x02B, 0x0005B333,
+	0x02C, 0x0000000D,
+	0x02A, 0x00000007,
+	0x02B, 0x00000709,
+	0x02B, 0x00063333,
+	0x02C, 0x0000000D,
+	0x02A, 0x00000008,
+	0x02B, 0x0000060A,
+	0x02B, 0x0004B333,
+	0x02C, 0x0000000D,
+	0x02A, 0x00000009,
+	0x02B, 0x0000060A,
+	0x02B, 0x00053333,
+	0x02C, 0x0000000D,
+	0x02A, 0x0000000A,
+	0x02B, 0x0000060A,
+	0x02B, 0x0005B333,
+	0x02C, 0x0000000D,
+	0x02A, 0x0000000B,
+	0x02B, 0x0000060A,
+	0x02B, 0x00063333,
+	0x02C, 0x0000000D,
+	0x02A, 0x0000000C,
+	0x02B, 0x0000060A,
+	0x02B, 0x0006B333,
+	0x02C, 0x0000000D,
+	0x02A, 0x0000000D,
+	0x02B, 0x0000060A,
+	0x02B, 0x00073333,
+	0x02C, 0x0000000D,
+	0x02A, 0x0000000E,
+	0x02B, 0x0000050B,
+	0x02B, 0x00066666,
+	0x02C, 0x0000001A,
+	0x02A, 0x000E0000,
+	0x010, 0x0004000F,
+	0x011, 0x000E31FC,
+	0x010, 0x0006000F,
+	0x011, 0x000FF9F8,
+	0x010, 0x0002000F,
+	0x011, 0x000203F9,
+	0x010, 0x0003000F,
+	0x011, 0x000FF500,
+	0x010, 0x00000000,
+	0x011, 0x00000000,
+	0x010, 0x0008000F,
+	0x011, 0x0003F100,
+	0x010, 0x0009000F,
+	0x011, 0x00023100,
+	0x012, 0x00032000,
+	0x012, 0x00071000,
+	0x012, 0x000B0000,
+	0x012, 0x000FC000,
+	0x013, 0x000287B3,
+	0x013, 0x000244B7,
+	0x013, 0x000204AB,
+	0x013, 0x0001C49F,
+	0x013, 0x00018493,
+	0x013, 0x0001429B,
+	0x013, 0x00010299,
+	0x013, 0x0000C29C,
+	0x013, 0x000081A0,
+	0x013, 0x000040AC,
+	0x013, 0x00000020,
+	0x014, 0x0001944C,
+	0x014, 0x00059444,
+	0x014, 0x0009944C,
+	0x014, 0x000D9444,
+	0xFF0F011F, 0xABCD,
+	0x015, 0x0000F424,
+	0x015, 0x0004F424,
+	0x015, 0x0008F424,
+	0x015, 0x000CF424,
+	0xCDCDCDCD, 0xCDCD,
+	0x015, 0x0000F474,
+	0x015, 0x0004F477,
+	0x015, 0x0008F455,
+	0x015, 0x000CF455,
+	0xFF0F011F, 0xDEAD,
+	0x016, 0x00000339,
+	0x016, 0x00040339,
+	0x016, 0x00080339,
+	0xFF0F011F, 0xABCD,
+	0x016, 0x000C0356,
+	0xCDCDCDCD, 0xCDCD,
+	0x016, 0x000C0366,
+	0xFF0F011F, 0xDEAD,
+	0x000, 0x00010159,
+	0x018, 0x0000F401,
+	0x0FE, 0x00000000,
+	0x0FE, 0x00000000,
+	0x01F, 0x00000003,
+	0x0FE, 0x00000000,
+	0x0FE, 0x00000000,
+	0x01E, 0x00000247,
+	0x01F, 0x00000000,
+	0x000, 0x00030159,
+};
+
+void ODM_ReadAndConfig_RadioA_1T_8723A(struct dm_odm_t *pDM_Odm)
+{
+	#define READ_NEXT_PAIR(v1, v2, i)			\
+		 do {						\
+			 i +=3D 2; v1 =3D Array[i]; v2 =3D Array[i+1];\
+		 } while (0)
+
+	u32     hex         =3D 0;
+	u32     i           =3D 0;
+	u8     platform    =3D 0x04;
+	u8     interfaceValue   =3D pDM_Odm->SupportInterface;
+	u8     board       =3D pDM_Odm->BoardType;
+	u32     ArrayLen    =3D sizeof(Array_RadioA_1T_8723A)/sizeof(u32);
+	u32 *Array =3D Array_RadioA_1T_8723A;
+
+	hex +=3D board;
+	hex +=3D interfaceValue << 8;
+	hex +=3D platform << 16;
+	hex +=3D 0xFF000000;
+
+	for (i =3D 0; i < ArrayLen; i +=3D 2) {
+		u32 v1 =3D Array[i];
+		u32 v2 =3D Array[i+1];
+
+		/*  This (offset, data) pair meets the condition. */
+		if (v1 < 0xCDCDCDCD) {
+			odm_ConfigRF_RadioA_8723A(pDM_Odm, v1, v2);
+			continue;
+		} else {
+			if (!CheckCondition(Array[i], hex)) {
+				/*  Discard the following (offset, data) pairs. */
+				READ_NEXT_PAIR(v1, v2, i);
+				while (v2 !=3D 0xDEAD &&
+				       v2 !=3D 0xCDEF &&
+				       v2 !=3D 0xCDCD && i < ArrayLen - 2)
+					READ_NEXT_PAIR(v1, v2, i);
+				i -=3D 2; /*  prevent from for-loop +=3D 2 */
+			} else {
+				/*  Configure matched pairs and skip to end of if-else. */
+				READ_NEXT_PAIR(v1, v2, i);
+				while (v2 !=3D 0xDEAD &&
+				       v2 !=3D 0xCDEF &&
+				       v2 !=3D 0xCDCD && i < ArrayLen - 2) {
+					odm_ConfigRF_RadioA_8723A(pDM_Odm, v1, v2);
+					READ_NEXT_PAIR(v1, v2, i);
+				}
+
+				while (v2 !=3D 0xDEAD && i < ArrayLen - 2)
+					READ_NEXT_PAIR(v1, v2, i);
+			}
+		}
+	}
+}
diff --git a/drivers/staging/rtl8723au/hal/HalPwrSeqCmd.c b/drivers/sta=
ging/rtl8723au/hal/HalPwrSeqCmd.c
new file mode 100644
index 0000000..4f6b4b7
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/HalPwrSeqCmd.c
@@ -0,0 +1,163 @@
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
+/*++
+Copyright (c) Realtek Semiconductor Corp. All rights reserved.
+
+Module Name:
+	HalPwrSeqCmd.c
+
+Abstract:
+	Implement HW Power sequence configuration CMD handling routine for
+	Realtek devices.
+
+Major Change History:
+	When       Who               What
+	---------- ---------------   -------------------------------
+	2011-10-26 Lucas            Modify to be compatible with SD4-CE drive=
r.
+	2011-07-07 Roger            Create.
+
+--*/
+#include <HalPwrSeqCmd.h>
+
+/*  */
+/*	Description: */
+/*		This routine deal with the Power Configuration CMDs parsing
+		for RTL8723/RTL8188E Series IC. */
+/*  */
+/*	Assumption: */
+/*		We should follow specific format which was released from
+		HW SD. */
+/*  */
+/*	2011.07.07, added by Roger. */
+/*  */
+u8 HalPwrSeqCmdParsing23a(struct rtw_adapter *padapter, u8 CutVersion,
+		       u8 FabVersion, u8 InterfaceType,
+		       struct wlan_pwr_cfg PwrSeqCmd[])
+{
+	struct wlan_pwr_cfg PwrCfgCmd =3D { 0 };
+	u8 bPollingBit =3D false;
+	u32 AryIdx =3D 0;
+	u8 value =3D 0;
+	u32 offset =3D 0;
+	u32 pollingCount =3D 0;	/*  polling autoload done. */
+	u32 maxPollingCnt =3D 5000;
+
+	do {
+		PwrCfgCmd =3D PwrSeqCmd[AryIdx];
+
+		RT_TRACE(_module_hal_init_c_, _drv_info_,
+			 ("HalPwrSeqCmdParsing23a: offset(%#x) cut_msk(%#x) "
+			  "fab_msk(%#x) interface_msk(%#x) base(%#x) cmd(%#x) "
+			  "msk(%#x) value(%#x)\n",
+			  GET_PWR_CFG_OFFSET(PwrCfgCmd),
+			  GET_PWR_CFG_CUT_MASK(PwrCfgCmd),
+			  GET_PWR_CFG_FAB_MASK(PwrCfgCmd),
+			  GET_PWR_CFG_INTF_MASK(PwrCfgCmd),
+			  GET_PWR_CFG_BASE(PwrCfgCmd),
+			  GET_PWR_CFG_CMD(PwrCfgCmd),
+			  GET_PWR_CFG_MASK(PwrCfgCmd),
+			  GET_PWR_CFG_VALUE(PwrCfgCmd)));
+
+		/* 2 Only Handle the command whose FAB, CUT, and Interface are
+		   matched */
+		if ((GET_PWR_CFG_FAB_MASK(PwrCfgCmd) & FabVersion) &&
+		    (GET_PWR_CFG_CUT_MASK(PwrCfgCmd) & CutVersion) &&
+		    (GET_PWR_CFG_INTF_MASK(PwrCfgCmd) & InterfaceType)) {
+			switch (GET_PWR_CFG_CMD(PwrCfgCmd)) {
+			case PWR_CMD_READ:
+				RT_TRACE(_module_hal_init_c_, _drv_info_,
+					 ("HalPwrSeqCmdParsing23a: "
+					  "PWR_CMD_READ\n"));
+				break;
+
+			case PWR_CMD_WRITE:
+				RT_TRACE(_module_hal_init_c_, _drv_info_,
+					 ("HalPwrSeqCmdParsing23a: "
+					  "PWR_CMD_WRITE\n"));
+				offset =3D GET_PWR_CFG_OFFSET(PwrCfgCmd);
+
+				/*  Read the value from system register */
+				value =3D rtw_read8(padapter, offset);
+
+				value &=3D ~(GET_PWR_CFG_MASK(PwrCfgCmd));
+				value |=3D (GET_PWR_CFG_VALUE(PwrCfgCmd) &
+					  GET_PWR_CFG_MASK(PwrCfgCmd));
+
+				/*  Write the value back to sytem register */
+				rtw_write8(padapter, offset, value);
+				break;
+
+			case PWR_CMD_POLLING:
+				RT_TRACE(_module_hal_init_c_, _drv_info_,
+					 ("HalPwrSeqCmdParsing23a: "
+					  "PWR_CMD_POLLING\n"));
+
+				bPollingBit =3D false;
+				offset =3D GET_PWR_CFG_OFFSET(PwrCfgCmd);
+				do {
+					value =3D rtw_read8(padapter, offset);
+
+					value &=3D GET_PWR_CFG_MASK(PwrCfgCmd);
+					if (value =3D=3D
+					    (GET_PWR_CFG_VALUE(PwrCfgCmd) &
+					     GET_PWR_CFG_MASK(PwrCfgCmd)))
+						bPollingBit =3D true;
+					else
+						udelay(10);
+
+					if (pollingCount++ > maxPollingCnt) {
+						DBG_8723A("Fail to polling "
+							  "Offset[%#x]\n",
+							  offset);
+						return false;
+					}
+				} while (!bPollingBit);
+
+				break;
+
+			case PWR_CMD_DELAY:
+				RT_TRACE(_module_hal_init_c_, _drv_info_,
+					 ("HalPwrSeqCmdParsing23a: "
+					  "PWR_CMD_DELAY\n"));
+				if (GET_PWR_CFG_VALUE(PwrCfgCmd) =3D=3D
+				    PWRSEQ_DELAY_US)
+					udelay(GET_PWR_CFG_OFFSET(PwrCfgCmd));
+				else
+					udelay(GET_PWR_CFG_OFFSET(PwrCfgCmd) *
+					       1000);
+				break;
+
+			case PWR_CMD_END:
+				/*  When this command is parsed, end
+				    the process */
+				RT_TRACE(_module_hal_init_c_, _drv_info_,
+					 ("HalPwrSeqCmdParsing23a: "
+					  "PWR_CMD_END\n"));
+				return true;
+				break;
+
+			default:
+				RT_TRACE(_module_hal_init_c_, _drv_err_,
+					 ("HalPwrSeqCmdParsing23a: "
+					  "Unknown CMD!!\n"));
+				break;
+			}
+		}
+
+		AryIdx++;	/* Add Array Index */
+	} while (1);
+
+	return true;
+}
diff --git a/drivers/staging/rtl8723au/hal/hal_com.c b/drivers/staging/=
rtl8723au/hal/hal_com.c
new file mode 100644
index 0000000..0640f35
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/hal_com.c
@@ -0,0 +1,881 @@
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
+#include <osdep_service.h>
+#include <drv_types.h>
+
+#include <hal_intf.h>
+#include <hal_com.h>
+#include <rtl8723a_hal.h>
+
+#define _HAL_INIT_C_
+
+void dump_chip_info23a(struct hal_version ChipVersion)
+{
+	int cnt =3D 0;
+	u8 buf[128];
+
+	cnt +=3D sprintf((buf + cnt), "Chip Version Info: CHIP_8723A_");
+
+	cnt +=3D sprintf((buf + cnt), "%s_", IS_NORMAL_CHIP(ChipVersion) ?
+		       "Normal_Chip" : "Test_Chip");
+	cnt +=3D sprintf((buf + cnt), "%s_",
+		       IS_CHIP_VENDOR_TSMC(ChipVersion) ? "TSMC" : "UMC");
+	if (IS_A_CUT(ChipVersion))
+		cnt +=3D sprintf((buf + cnt), "A_CUT_");
+	else if (IS_B_CUT(ChipVersion))
+		cnt +=3D sprintf((buf + cnt), "B_CUT_");
+	else if (IS_C_CUT(ChipVersion))
+		cnt +=3D sprintf((buf + cnt), "C_CUT_");
+	else if (IS_D_CUT(ChipVersion))
+		cnt +=3D sprintf((buf + cnt), "D_CUT_");
+	else if (IS_E_CUT(ChipVersion))
+		cnt +=3D sprintf((buf + cnt), "E_CUT_");
+	else
+		cnt +=3D sprintf((buf + cnt), "UNKNOWN_CUT(%d)_",
+			       ChipVersion.CUTVersion);
+
+	if (IS_1T1R(ChipVersion))
+		cnt +=3D sprintf((buf + cnt), "1T1R_");
+	else if (IS_1T2R(ChipVersion))
+		cnt +=3D sprintf((buf + cnt), "1T2R_");
+	else if (IS_2T2R(ChipVersion))
+		cnt +=3D sprintf((buf + cnt), "2T2R_");
+	else
+		cnt +=3D sprintf((buf + cnt), "UNKNOWN_RFTYPE(%d)_",
+			       ChipVersion.RFType);
+
+	cnt +=3D sprintf((buf + cnt), "RomVer(%d)\n", ChipVersion.ROMVer);
+
+	DBG_8723A("%s", buf);
+}
+
+#define	EEPROM_CHANNEL_PLAN_BY_HW_MASK	0x80
+
+/* return the final channel plan decision */
+/* hw_channel_plan:  channel plan from HW (efuse/eeprom) */
+/* sw_channel_plan:  channel plan from SW (registry/module param) */
+/* def_channel_plan: channel plan used when the former two is invalid =
*/
+u8 hal_com_get_channel_plan23a(struct rtw_adapter *padapter, u8 hw_cha=
nnel_plan,
+			    u8 sw_channel_plan, u8 def_channel_plan,
+			    bool AutoLoadFail)
+{
+	u8 swConfig;
+	u8 chnlPlan;
+
+	swConfig =3D true;
+	if (!AutoLoadFail) {
+		if (!rtw_is_channel_plan_valid(sw_channel_plan))
+			swConfig =3D false;
+		if (hw_channel_plan & EEPROM_CHANNEL_PLAN_BY_HW_MASK)
+			swConfig =3D false;
+	}
+
+	if (swConfig =3D=3D true)
+		chnlPlan =3D sw_channel_plan;
+	else
+		chnlPlan =3D hw_channel_plan & (~EEPROM_CHANNEL_PLAN_BY_HW_MASK);
+
+	if (!rtw_is_channel_plan_valid(chnlPlan))
+		chnlPlan =3D def_channel_plan;
+
+	return chnlPlan;
+}
+
+u8 MRateToHwRate23a(u8 rate)
+{
+	u8 ret =3D DESC_RATE1M;
+
+	switch (rate) {
+		/*  CCK and OFDM non-HT rates */
+	case IEEE80211_CCK_RATE_1MB:
+		ret =3D DESC_RATE1M;
+		break;
+	case IEEE80211_CCK_RATE_2MB:
+		ret =3D DESC_RATE2M;
+		break;
+	case IEEE80211_CCK_RATE_5MB:
+		ret =3D DESC_RATE5_5M;
+		break;
+	case IEEE80211_CCK_RATE_11MB:
+		ret =3D DESC_RATE11M;
+		break;
+	case IEEE80211_OFDM_RATE_6MB:
+		ret =3D DESC_RATE6M;
+		break;
+	case IEEE80211_OFDM_RATE_9MB:
+		ret =3D DESC_RATE9M;
+		break;
+	case IEEE80211_OFDM_RATE_12MB:
+		ret =3D DESC_RATE12M;
+		break;
+	case IEEE80211_OFDM_RATE_18MB:
+		ret =3D DESC_RATE18M;
+		break;
+	case IEEE80211_OFDM_RATE_24MB:
+		ret =3D DESC_RATE24M;
+		break;
+	case IEEE80211_OFDM_RATE_36MB:
+		ret =3D DESC_RATE36M;
+		break;
+	case IEEE80211_OFDM_RATE_48MB:
+		ret =3D DESC_RATE48M;
+		break;
+	case IEEE80211_OFDM_RATE_54MB:
+		ret =3D DESC_RATE54M;
+		break;
+
+		/*  HT rates since here */
+		/* case MGN_MCS0:	ret =3D DESC_RATEMCS0;    break; */
+		/* case MGN_MCS1:	ret =3D DESC_RATEMCS1;    break; */
+		/* case MGN_MCS2:	ret =3D DESC_RATEMCS2;    break; */
+		/* case MGN_MCS3:	ret =3D DESC_RATEMCS3;    break; */
+		/* case MGN_MCS4:	ret =3D DESC_RATEMCS4;    break; */
+		/* case MGN_MCS5:	ret =3D DESC_RATEMCS5;    break; */
+		/* case MGN_MCS6:	ret =3D DESC_RATEMCS6;    break; */
+		/* case MGN_MCS7:	ret =3D DESC_RATEMCS7;    break; */
+
+	default:
+		break;
+	}
+	return ret;
+}
+
+void HalSetBrateCfg23a(struct rtw_adapter *padapter, u8 *mBratesOS)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u8 i, is_brate, brate;
+	u16 brate_cfg =3D 0;
+	u8 rate_index;
+
+	for (i =3D 0; i < NDIS_802_11_LENGTH_RATES_EX; i++) {
+		is_brate =3D mBratesOS[i] & IEEE80211_BASIC_RATE_MASK;
+		brate =3D mBratesOS[i] & 0x7f;
+
+		if (is_brate) {
+			switch (brate) {
+			case IEEE80211_CCK_RATE_1MB:
+				brate_cfg |=3D RATE_1M;
+				break;
+			case IEEE80211_CCK_RATE_2MB:
+				brate_cfg |=3D RATE_2M;
+				break;
+			case IEEE80211_CCK_RATE_5MB:
+				brate_cfg |=3D RATE_5_5M;
+				break;
+			case IEEE80211_CCK_RATE_11MB:
+				brate_cfg |=3D RATE_11M;
+				break;
+			case IEEE80211_OFDM_RATE_6MB:
+				brate_cfg |=3D RATE_6M;
+				break;
+			case IEEE80211_OFDM_RATE_9MB:
+				brate_cfg |=3D RATE_9M;
+				break;
+			case IEEE80211_OFDM_RATE_12MB:
+				brate_cfg |=3D RATE_12M;
+				break;
+			case IEEE80211_OFDM_RATE_18MB:
+				brate_cfg |=3D RATE_18M;
+				break;
+			case IEEE80211_OFDM_RATE_24MB:
+				brate_cfg |=3D RATE_24M;
+				break;
+			case IEEE80211_OFDM_RATE_36MB:
+				brate_cfg |=3D RATE_36M;
+				break;
+			case IEEE80211_OFDM_RATE_48MB:
+				brate_cfg |=3D RATE_48M;
+				break;
+			case IEEE80211_OFDM_RATE_54MB:
+				brate_cfg |=3D RATE_54M;
+				break;
+			}
+		}
+	}
+
+	/*  2007.01.16, by Emily */
+	/*  Select RRSR (in Legacy-OFDM and CCK) */
+	/*  For 8190, we select only 24M, 12M, 6M, 11M, 5.5M, 2M,
+	    and 1M from the Basic rate. */
+	/*  We do not use other rates. */
+	/* 2011.03.30 add by Luke Lee */
+	/* CCK 2M ACK should be disabled for some BCM and Atheros AP IOT */
+	/* because CCK 2M has poor TXEVM */
+	/* CCK 5.5M & 11M ACK should be enabled for better
+	   performance */
+
+	brate_cfg =3D (brate_cfg | 0xd) & 0x15d;
+	pHalData->BasicRateSet =3D brate_cfg;
+	brate_cfg |=3D 0x01;	/*  default enable 1M ACK rate */
+	DBG_8723A("HW_VAR_BASIC_RATE: BrateCfg(%#x)\n", brate_cfg);
+
+	/*  Set RRSR rate table. */
+	rtw_write8(padapter, REG_RRSR, brate_cfg & 0xff);
+	rtw_write8(padapter, REG_RRSR + 1, (brate_cfg >> 8) & 0xff);
+	rtw_write8(padapter, REG_RRSR + 2,
+		   rtw_read8(padapter, REG_RRSR + 2) & 0xf0);
+
+	rate_index =3D 0;
+	/*  Set RTS initial rate */
+	while (brate_cfg > 0x1) {
+		brate_cfg =3D (brate_cfg >> 1);
+		rate_index++;
+	}
+		/*  Ziv - Check */
+	rtw_write8(padapter, REG_INIRTS_RATE_SEL, rate_index);
+
+	return;
+}
+
+static void _OneOutPipeMapping(struct rtw_adapter *pAdapter)
+{
+	struct dvobj_priv *pdvobjpriv =3D adapter_to_dvobj(pAdapter);
+
+	pdvobjpriv->Queue2Pipe[0] =3D pdvobjpriv->RtOutPipe[0];	/* VO */
+	pdvobjpriv->Queue2Pipe[1] =3D pdvobjpriv->RtOutPipe[0];	/* VI */
+	pdvobjpriv->Queue2Pipe[2] =3D pdvobjpriv->RtOutPipe[0];	/* BE */
+	pdvobjpriv->Queue2Pipe[3] =3D pdvobjpriv->RtOutPipe[0];	/* BK */
+
+	pdvobjpriv->Queue2Pipe[4] =3D pdvobjpriv->RtOutPipe[0];	/* BCN */
+	pdvobjpriv->Queue2Pipe[5] =3D pdvobjpriv->RtOutPipe[0];	/* MGT */
+	pdvobjpriv->Queue2Pipe[6] =3D pdvobjpriv->RtOutPipe[0];	/* HIGH */
+	pdvobjpriv->Queue2Pipe[7] =3D pdvobjpriv->RtOutPipe[0];	/* TXCMD */
+}
+
+static void _TwoOutPipeMapping(struct rtw_adapter *pAdapter, bool bWIF=
ICfg)
+{
+	struct dvobj_priv *pdvobjpriv =3D adapter_to_dvobj(pAdapter);
+
+	if (bWIFICfg) {		/* WMM */
+		/*    BK,   BE,   VI,   VO,   BCN,  CMD,  MGT, HIGH, HCCA */
+		/*     0,    1,    0,    1,     0,    0,    0,    0,    0 }; */
+		/* 0:H, 1:L */
+		pdvobjpriv->Queue2Pipe[0] =3D pdvobjpriv->RtOutPipe[1]; /* VO */
+		pdvobjpriv->Queue2Pipe[1] =3D pdvobjpriv->RtOutPipe[0]; /* VI */
+		pdvobjpriv->Queue2Pipe[2] =3D pdvobjpriv->RtOutPipe[1]; /* BE */
+		pdvobjpriv->Queue2Pipe[3] =3D pdvobjpriv->RtOutPipe[0]; /* BK */
+
+		pdvobjpriv->Queue2Pipe[4] =3D pdvobjpriv->RtOutPipe[0]; /* BCN */
+		pdvobjpriv->Queue2Pipe[5] =3D pdvobjpriv->RtOutPipe[0]; /* MGT */
+		pdvobjpriv->Queue2Pipe[6] =3D pdvobjpriv->RtOutPipe[0]; /* HIGH */
+		pdvobjpriv->Queue2Pipe[7] =3D pdvobjpriv->RtOutPipe[0]; /* TXCMD*/
+	} else {		/* typical setting */
+		/*    BK,   BE,   VI,   VO,   BCN,  CMD,  MGT, HIGH, HCCA */
+		/*     1,    1,    0,    0,     0,    0,    0,    0,    0 }; */
+		/* 0:H, 1:L */
+		pdvobjpriv->Queue2Pipe[0] =3D pdvobjpriv->RtOutPipe[0]; /* VO */
+		pdvobjpriv->Queue2Pipe[1] =3D pdvobjpriv->RtOutPipe[0]; /* VI */
+		pdvobjpriv->Queue2Pipe[2] =3D pdvobjpriv->RtOutPipe[1]; /* BE */
+		pdvobjpriv->Queue2Pipe[3] =3D pdvobjpriv->RtOutPipe[1]; /* BK */
+
+		pdvobjpriv->Queue2Pipe[4] =3D pdvobjpriv->RtOutPipe[0]; /* BCN */
+		pdvobjpriv->Queue2Pipe[5] =3D pdvobjpriv->RtOutPipe[0]; /* MGT */
+		pdvobjpriv->Queue2Pipe[6] =3D pdvobjpriv->RtOutPipe[0]; /* HIGH */
+		pdvobjpriv->Queue2Pipe[7] =3D pdvobjpriv->RtOutPipe[0]; /* TXCMD*/
+	}
+}
+
+static void _ThreeOutPipeMapping(struct rtw_adapter *pAdapter, bool bW=
IFICfg)
+{
+	struct dvobj_priv *pdvobjpriv =3D adapter_to_dvobj(pAdapter);
+
+	if (bWIFICfg) {		/* for WMM */
+		/*    BK,   BE,   VI,   VO,   BCN,  CMD,  MGT, HIGH, HCCA */
+		/*     1,    2,    1,    0,     0,    0,    0,    0,    0 }; */
+		/* 0:H, 1:N, 2:L */
+		pdvobjpriv->Queue2Pipe[0] =3D pdvobjpriv->RtOutPipe[0]; /* VO */
+		pdvobjpriv->Queue2Pipe[1] =3D pdvobjpriv->RtOutPipe[1]; /* VI */
+		pdvobjpriv->Queue2Pipe[2] =3D pdvobjpriv->RtOutPipe[2]; /* BE */
+		pdvobjpriv->Queue2Pipe[3] =3D pdvobjpriv->RtOutPipe[1]; /* BK */
+
+		pdvobjpriv->Queue2Pipe[4] =3D pdvobjpriv->RtOutPipe[0]; /* BCN */
+		pdvobjpriv->Queue2Pipe[5] =3D pdvobjpriv->RtOutPipe[0]; /* MGT */
+		pdvobjpriv->Queue2Pipe[6] =3D pdvobjpriv->RtOutPipe[0]; /* HIGH */
+		pdvobjpriv->Queue2Pipe[7] =3D pdvobjpriv->RtOutPipe[0]; /* TXCMD*/
+	} else {		/* typical setting */
+		/*    BK,   BE,   VI,   VO,   BCN,  CMD,  MGT, HIGH, HCCA */
+		/*     2,    2,    1,    0,     0,    0,    0,    0,    0 }; */
+		/* 0:H, 1:N, 2:L */
+		pdvobjpriv->Queue2Pipe[0] =3D pdvobjpriv->RtOutPipe[0]; /* VO */
+		pdvobjpriv->Queue2Pipe[1] =3D pdvobjpriv->RtOutPipe[1]; /* VI */
+		pdvobjpriv->Queue2Pipe[2] =3D pdvobjpriv->RtOutPipe[2]; /* BE */
+		pdvobjpriv->Queue2Pipe[3] =3D pdvobjpriv->RtOutPipe[2]; /* BK */
+
+		pdvobjpriv->Queue2Pipe[4] =3D pdvobjpriv->RtOutPipe[0]; /* BCN */
+		pdvobjpriv->Queue2Pipe[5] =3D pdvobjpriv->RtOutPipe[0]; /* MGT */
+		pdvobjpriv->Queue2Pipe[6] =3D pdvobjpriv->RtOutPipe[0]; /* HIGH */
+		pdvobjpriv->Queue2Pipe[7] =3D pdvobjpriv->RtOutPipe[0]; /* TXCMD*/
+	}
+}
+
+bool Hal_MappingOutPipe23a(struct rtw_adapter *pAdapter, u8 NumOutPipe=
)
+{
+	struct registry_priv *pregistrypriv =3D &pAdapter->registrypriv;
+	bool bWIFICfg =3D (pregistrypriv->wifi_spec) ? true : false;
+	bool result =3D true;
+
+	switch (NumOutPipe) {
+	case 2:
+		_TwoOutPipeMapping(pAdapter, bWIFICfg);
+		break;
+	case 3:
+		_ThreeOutPipeMapping(pAdapter, bWIFICfg);
+		break;
+	case 1:
+		_OneOutPipeMapping(pAdapter);
+		break;
+	default:
+		result =3D false;
+		break;
+	}
+
+	return result;
+}
+
+void hal_init_macaddr23a(struct rtw_adapter *adapter)
+{
+	rtw_hal_set_hwreg23a(adapter, HW_VAR_MAC_ADDR,
+			  adapter->eeprompriv.mac_addr);
+}
+
+/*
+* C2H event format:
+* Field	 TRIGGER		CONTENT	   CMD_SEQ	CMD_LEN		 CMD_ID
+* BITS	 [127:120]	[119:16]      [15:8]		  [7:4]		   [3:0]
+*/
+
+void c2h_evt_clear23a(struct rtw_adapter *adapter)
+{
+	rtw_write8(adapter, REG_C2HEVT_CLEAR, C2H_EVT_HOST_CLOSE);
+}
+
+s32 c2h_evt_read23a(struct rtw_adapter *adapter, u8 *buf)
+{
+	s32 ret =3D _FAIL;
+	struct c2h_evt_hdr *c2h_evt;
+	int i;
+	u8 trigger;
+
+	if (buf =3D=3D NULL)
+		goto exit;
+
+	trigger =3D rtw_read8(adapter, REG_C2HEVT_CLEAR);
+
+	if (trigger =3D=3D C2H_EVT_HOST_CLOSE)
+		goto exit;	/* Not ready */
+	else if (trigger !=3D C2H_EVT_FW_CLOSE)
+		goto clear_evt;	/* Not a valid value */
+
+	c2h_evt =3D (struct c2h_evt_hdr *)buf;
+
+	memset(c2h_evt, 0, 16);
+
+	*buf =3D rtw_read8(adapter, REG_C2HEVT_MSG_NORMAL);
+	*(buf + 1) =3D rtw_read8(adapter, REG_C2HEVT_MSG_NORMAL + 1);
+
+	RT_PRINT_DATA(_module_hal_init_c_, _drv_info_, "c2h_evt_read23a(): ",
+		      &c2h_evt, sizeof(c2h_evt));
+
+	if (0) {
+		DBG_8723A("%s id:%u, len:%u, seq:%u, trigger:0x%02x\n",
+			  __func__, c2h_evt->id, c2h_evt->plen, c2h_evt->seq,
+			  trigger);
+	}
+
+	/* Read the content */
+	for (i =3D 0; i < c2h_evt->plen; i++)
+		c2h_evt->payload[i] =3D rtw_read8(adapter,
+						REG_C2HEVT_MSG_NORMAL +
+						sizeof(*c2h_evt) + i);
+
+	RT_PRINT_DATA(_module_hal_init_c_, _drv_info_,
+		      "c2h_evt_read23a(): Command Content:\n", c2h_evt->payload,
+		      c2h_evt->plen);
+
+	ret =3D _SUCCESS;
+
+clear_evt:
+	/*
+	 * Clear event to notify FW we have read the command.
+	 * If this field isn't clear, the FW won't update the
+	 * next command message.
+	 */
+	c2h_evt_clear23a(adapter);
+exit:
+	return ret;
+}
+
+void
+rtl8723a_set_ampdu_min_space(struct rtw_adapter *padapter, u8 MinSpaci=
ngToSet)
+{
+	u8 SecMinSpace;
+
+	if (MinSpacingToSet <=3D 7) {
+		switch (padapter->securitypriv.dot11PrivacyAlgrthm) {
+		case _NO_PRIVACY_:
+		case _AES_:
+			SecMinSpace =3D 0;
+			break;
+
+		case _WEP40_:
+		case _WEP104_:
+		case _TKIP_:
+		case _TKIP_WTMIC_:
+			SecMinSpace =3D 6;
+			break;
+		default:
+			SecMinSpace =3D 7;
+			break;
+		}
+
+		if (MinSpacingToSet < SecMinSpace)
+			MinSpacingToSet =3D SecMinSpace;
+
+		/* RT_TRACE(COMP_MLME, DBG_LOUD,
+		   ("Set HW_VAR_AMPDU_MIN_SPACE: %#x\n",
+		   padapter->MgntInfo.MinSpaceCfg)); */
+		MinSpacingToSet |=3D
+			rtw_read8(padapter, REG_AMPDU_MIN_SPACE) & 0xf8;
+		rtw_write8(padapter, REG_AMPDU_MIN_SPACE,
+			   MinSpacingToSet);
+	}
+}
+
+void rtl8723a_set_ampdu_factor(struct rtw_adapter *padapter, u8 Factor=
ToSet)
+{
+	u8 RegToSet_Normal[4] =3D { 0x41, 0xa8, 0x72, 0xb9 };
+	u8 MaxAggNum;
+	u8 *pRegToSet;
+	u8 index =3D 0;
+
+	pRegToSet =3D RegToSet_Normal;	/*  0xb972a841; */
+#ifdef CONFIG_8723AU_BT_COEXIST
+	if ((BT_IsBtDisabled(padapter) =3D=3D false) &&
+	    (BT_1Ant(padapter) =3D=3D true)) {
+		MaxAggNum =3D 0x8;
+	} else
+#endif /*  CONFIG_8723AU_BT_COEXIST */
+	{
+		MaxAggNum =3D 0xF;
+	}
+
+	if (FactorToSet <=3D 3) {
+		FactorToSet =3D (1 << (FactorToSet + 2));
+		if (FactorToSet > MaxAggNum)
+			FactorToSet =3D MaxAggNum;
+
+		for (index =3D 0; index < 4; index++) {
+			if ((pRegToSet[index] & 0xf0) > (FactorToSet << 4))
+				pRegToSet[index] =3D (pRegToSet[index] & 0x0f) |
+					(FactorToSet << 4);
+
+			if ((pRegToSet[index] & 0x0f) > FactorToSet)
+				pRegToSet[index] =3D (pRegToSet[index] & 0xf0) |
+					FactorToSet;
+
+			rtw_write8(padapter, REG_AGGLEN_LMT + index,
+				   pRegToSet[index]);
+		}
+
+		/* RT_TRACE(COMP_MLME, DBG_LOUD,
+		   ("Set HW_VAR_AMPDU_FACTOR: %#x\n", FactorToSet)); */
+	}
+}
+
+void rtl8723a_set_acm_ctrl(struct rtw_adapter *padapter, u8 ctrl)
+{
+	u8 hwctrl =3D 0;
+
+	if (ctrl !=3D 0) {
+		hwctrl |=3D AcmHw_HwEn;
+
+		if (ctrl & BIT(1))	/*  BE */
+			hwctrl |=3D AcmHw_BeqEn;
+
+		if (ctrl & BIT(2))	/*  VI */
+			hwctrl |=3D AcmHw_ViqEn;
+
+		if (ctrl & BIT(3))	/*  VO */
+			hwctrl |=3D AcmHw_VoqEn;
+	}
+
+	DBG_8723A("[HW_VAR_ACM_CTRL] Write 0x%02X\n", hwctrl);
+	rtw_write8(padapter, REG_ACMHWCTRL, hwctrl);
+}
+
+void rtl8723a_set_media_status(struct rtw_adapter *padapter, u8 status=
)
+{
+	u8 val8;
+
+	val8 =3D rtw_read8(padapter, MSR) & 0x0c;
+	val8 |=3D status;
+	rtw_write8(padapter, MSR, val8);
+}
+
+void rtl8723a_set_media_status1(struct rtw_adapter *padapter, u8 statu=
s)
+{
+	u8 val8;
+
+	val8 =3D rtw_read8(padapter, MSR) & 0x03;
+	val8 |=3D status << 2;
+	rtw_write8(padapter, MSR, val8);
+}
+
+void rtl8723a_set_bcn_func(struct rtw_adapter *padapter, u8 val)
+{
+	if (val)
+		SetBcnCtrlReg23a(padapter, EN_BCN_FUNCTION | EN_TXBCN_RPT, 0);
+	else
+		SetBcnCtrlReg23a(padapter, 0, EN_BCN_FUNCTION | EN_TXBCN_RPT);
+}
+
+void rtl8723a_check_bssid(struct rtw_adapter *padapter, u8 val)
+{
+	u32 val32;
+	val32 =3D rtw_read32(padapter, REG_RCR);
+	if (val)
+		val32 |=3D RCR_CBSSID_DATA | RCR_CBSSID_BCN;
+	else
+		val32 &=3D ~(RCR_CBSSID_DATA | RCR_CBSSID_BCN);
+	rtw_write32(padapter, REG_RCR, val32);
+}
+
+void rtl8723a_mlme_sitesurvey(struct rtw_adapter *padapter, u8 flag)
+{
+	if (flag) {	/* under sitesurvey */
+		u32 v32;
+
+		/*  config RCR to receive different BSSID & not
+		    to receive data frame */
+		v32 =3D rtw_read32(padapter, REG_RCR);
+		v32 &=3D ~(RCR_CBSSID_BCN);
+		rtw_write32(padapter, REG_RCR, v32);
+		/*  reject all data frame */
+		rtw_write16(padapter, REG_RXFLTMAP2, 0);
+
+		/*  disable update TSF */
+		SetBcnCtrlReg23a(padapter, DIS_TSF_UDT, 0);
+	} else {	/* sitesurvey done */
+
+		struct mlme_ext_priv *pmlmeext =3D &padapter->mlmeextpriv;
+		struct mlme_ext_info *pmlmeinfo;
+		u32 v32;
+
+		pmlmeinfo =3D &pmlmeext->mlmext_info;
+
+		if ((is_client_associated_to_ap23a(padapter) =3D=3D true) ||
+		    ((pmlmeinfo->state & 0x03) =3D=3D WIFI_FW_ADHOC_STATE) ||
+		    ((pmlmeinfo->state & 0x03) =3D=3D WIFI_FW_AP_STATE)) {
+			/*  enable to rx data frame */
+			rtw_write16(padapter, REG_RXFLTMAP2, 0xFFFF);
+
+			/*  enable update TSF */
+			SetBcnCtrlReg23a(padapter, 0, DIS_TSF_UDT);
+		}
+
+		v32 =3D rtw_read32(padapter, REG_RCR);
+		v32 |=3D RCR_CBSSID_BCN;
+		rtw_write32(padapter, REG_RCR, v32);
+	}
+
+#ifdef CONFIG_8723AU_BT_COEXIST
+	BT_WifiScanNotify(padapter, flag ? true : false);
+#endif
+}
+
+void rtl8723a_on_rcr_am(struct rtw_adapter *padapter)
+{
+	rtw_write32(padapter, REG_RCR, rtw_read32(padapter, REG_RCR) | RCR_AM=
);
+	DBG_8723A("%s, %d, RCR =3D %x \n", __FUNCTION__, __LINE__,
+		  rtw_read32(padapter, REG_RCR));
+}
+
+void rtl8723a_off_rcr_am(struct rtw_adapter *padapter)
+{
+	rtw_write32(padapter, REG_RCR,
+		    rtw_read32(padapter, REG_RCR) & (~RCR_AM));
+	DBG_8723A("%s, %d, RCR =3D %x \n", __FUNCTION__, __LINE__,
+		  rtw_read32(padapter, REG_RCR));
+}
+
+void rtl8723a_set_slot_time(struct rtw_adapter *padapter, u8 slottime)
+{
+	u8 u1bAIFS, aSifsTime;
+	struct mlme_ext_priv *pmlmeext =3D &padapter->mlmeextpriv;
+	struct mlme_ext_info *pmlmeinfo =3D &pmlmeext->mlmext_info;
+
+	rtw_write8(padapter, REG_SLOT, slottime);
+
+	if (pmlmeinfo->WMM_enable =3D=3D 0) {
+		if (pmlmeext->cur_wireless_mode =3D=3D WIRELESS_11B)
+			aSifsTime =3D 10;
+		else
+			aSifsTime =3D 16;
+
+		u1bAIFS =3D aSifsTime + (2 * pmlmeinfo->slotTime);
+
+		/*  <Roger_EXP> Temporary removed, 2008.06.20. */
+		rtw_write8(padapter, REG_EDCA_VO_PARAM, u1bAIFS);
+		rtw_write8(padapter, REG_EDCA_VI_PARAM, u1bAIFS);
+		rtw_write8(padapter, REG_EDCA_BE_PARAM, u1bAIFS);
+		rtw_write8(padapter, REG_EDCA_BK_PARAM, u1bAIFS);
+	}
+}
+
+void rtl8723a_ack_preamble(struct rtw_adapter *padapter, u8 bShortPrea=
mble)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u8 regTmp;
+
+	/*  Joseph marked out for Netgear 3500 TKIP
+	    channel 7 issue.(Temporarily) */
+	regTmp =3D (pHalData->nCur40MhzPrimeSC) << 5;
+	/* regTmp =3D 0; */
+	if (bShortPreamble)
+		regTmp |=3D 0x80;
+	rtw_write8(padapter, REG_RRSR + 2, regTmp);
+}
+
+void rtl8723a_set_sec_cfg(struct rtw_adapter *padapter, u8 sec)
+{
+	rtw_write8(padapter, REG_SECCFG, sec);
+}
+
+void rtl8723a_cam_empty_entry(struct rtw_adapter *padapter, u8 ucIndex=
)
+{
+	u8 i;
+	u32 ulCommand =3D 0;
+	u32 ulContent =3D 0;
+	u32 ulEncAlgo =3D CAM_AES;
+
+	for (i =3D 0; i < CAM_CONTENT_COUNT; i++) {
+		/*  filled id in CAM config 2 byte */
+		if (i =3D=3D 0) {
+			ulContent |=3D (ucIndex & 0x03) |
+				((u16) (ulEncAlgo) << 2);
+			/* ulContent |=3D CAM_VALID; */
+		} else {
+			ulContent =3D 0;
+		}
+		/*  polling bit, and No Write enable, and address */
+		ulCommand =3D CAM_CONTENT_COUNT * ucIndex + i;
+		ulCommand =3D ulCommand | CAM_POLLINIG | CAM_WRITE;
+		/*  write content 0 is equall to mark invalid */
+		/* delay_ms(40); */
+		rtw_write32(padapter, WCAMI, ulContent);
+		/* RT_TRACE(COMP_SEC, DBG_LOUD,
+		   ("CAM_empty_entry23a(): WRITE A4: %lx \n", ulContent));*/
+		/* delay_ms(40); */
+		rtw_write32(padapter, RWCAM, ulCommand);
+		/* RT_TRACE(COMP_SEC, DBG_LOUD,
+		   ("CAM_empty_entry23a(): WRITE A0: %lx \n", ulCommand));*/
+	}
+}
+
+void rtl8723a_cam_invalid_all(struct rtw_adapter *padapter)
+{
+	rtw_write32(padapter, RWCAM, BIT(31) | BIT(30));
+}
+
+void rtl8723a_cam_write(struct rtw_adapter *padapter, u32 val1, u32 va=
l2)
+{
+	u32 cmd;
+
+	rtw_write32(padapter, WCAMI, val1);
+
+	cmd =3D CAM_POLLINIG | CAM_WRITE | val2;
+	rtw_write32(padapter, RWCAM, cmd);
+}
+
+void rtl8723a_fifo_cleanup(struct rtw_adapter *padapter)
+{
+#define RW_RELEASE_EN		BIT(18)
+#define RXDMA_IDLE		BIT(17)
+
+	struct pwrctrl_priv *pwrpriv =3D &padapter->pwrctrlpriv;
+	u8 trycnt =3D 100;
+
+	/*  pause tx */
+	rtw_write8(padapter, REG_TXPAUSE, 0xff);
+
+	/*  keep sn */
+	padapter->xmitpriv.nqos_ssn =3D rtw_read16(padapter, REG_NQOS_SEQ);
+
+	if (pwrpriv->bkeepfwalive !=3D true) {
+		u32 v32;
+
+		/*  RX DMA stop */
+		v32 =3D rtw_read32(padapter, REG_RXPKT_NUM);
+		v32 |=3D RW_RELEASE_EN;
+		rtw_write32(padapter, REG_RXPKT_NUM, v32);
+		do {
+			v32 =3D rtw_read32(padapter, REG_RXPKT_NUM) & RXDMA_IDLE;
+			if (!v32)
+				break;
+		} while (trycnt--);
+		if (trycnt =3D=3D 0) {
+			DBG_8723A("Stop RX DMA failed......\n");
+		}
+
+		/*  RQPN Load 0 */
+		rtw_write16(padapter, REG_RQPN_NPQ, 0);
+		rtw_write32(padapter, REG_RQPN, 0x80000000);
+		mdelay(10);
+	}
+}
+
+void rtl8723a_set_apfm_on_mac(struct rtw_adapter *padapter, u8 val)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	pHalData->bMacPwrCtrlOn =3D val;
+	DBG_8723A("%s: bMacPwrCtrlOn =3D%d\n", __func__, pHalData->bMacPwrCtr=
lOn);
+}
+
+void rtl8723a_bcn_valid(struct rtw_adapter *padapter)
+{
+	/* BCN_VALID, BIT16 of REG_TDECTRL =3D BIT0 of REG_TDECTRL+2,
+	   write 1 to clear, Clear by sw */
+	rtw_write8(padapter, REG_TDECTRL + 2,
+		   rtw_read8(padapter, REG_TDECTRL + 2) | BIT0);
+}
+
+void rtl8723a_set_tx_pause(struct rtw_adapter *padapter, u8 pause)
+{
+	rtw_write8(padapter, REG_TXPAUSE, pause);
+}
+
+void rtl8723a_set_beacon_interval(struct rtw_adapter *padapter, u16 in=
terval)
+{
+	rtw_write16(padapter, REG_BCN_INTERVAL, interval);
+}
+
+void rtl8723a_set_resp_sifs(struct rtw_adapter *padapter,
+			    u8 r2t1, u8 r2t2, u8 t2t1, u8 t2t2)
+{
+	/* SIFS_Timer =3D 0x0a0a0808; */
+	/* RESP_SIFS for CCK */
+	/*  SIFS_T2T_CCK (0x08) */
+	rtw_write8(padapter, REG_R2T_SIFS, r2t1);
+	/* SIFS_R2T_CCK(0x08) */
+	rtw_write8(padapter, REG_R2T_SIFS + 1, r2t2);
+	/* RESP_SIFS for OFDM */
+	/* SIFS_T2T_OFDM (0x0a) */
+	rtw_write8(padapter, REG_T2T_SIFS, t2t1);
+	/* SIFS_R2T_OFDM(0x0a) */
+	rtw_write8(padapter, REG_T2T_SIFS + 1, t2t2);
+}
+
+void rtl8723a_set_ac_param_vo(struct rtw_adapter *padapter, u32 vo)
+{
+	rtw_write32(padapter, REG_EDCA_VO_PARAM, vo);
+}
+
+void rtl8723a_set_ac_param_vi(struct rtw_adapter *padapter, u32 vi)
+{
+	rtw_write32(padapter, REG_EDCA_VI_PARAM, vi);
+}
+
+void rtl8723a_set_ac_param_be(struct rtw_adapter *padapter, u32 be)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	pHalData->AcParam_BE =3D be;
+	rtw_write32(padapter, REG_EDCA_BE_PARAM, be);
+}
+
+void rtl8723a_set_ac_param_bk(struct rtw_adapter *padapter, u32 bk)
+{
+	rtw_write32(padapter, REG_EDCA_BK_PARAM, bk);
+}
+
+void rtl8723a_set_rxdma_agg_pg_th(struct rtw_adapter *padapter, u8 val=
)
+{
+	rtw_write8(padapter, REG_RXDMA_AGG_PG_TH, val);
+}
+
+void rtl8723a_set_nav_upper(struct rtw_adapter *padapter, u32 usNavUpp=
er)
+{
+	if (usNavUpper > HAL_8723A_NAV_UPPER_UNIT * 0xFF) {
+		RT_TRACE(_module_hal_init_c_, _drv_notice_,
+			 ("The setting value (0x%08X us) of NAV_UPPER "
+			  "is larger than (%d * 0xFF)!!!\n",
+			  usNavUpper, HAL_8723A_NAV_UPPER_UNIT));
+		return;
+	}
+
+	/*  The value of ((usNavUpper + HAL_8723A_NAV_UPPER_UNIT - 1) /
+	    HAL_8723A_NAV_UPPER_UNIT) */
+	/*  is getting the upper integer. */
+	usNavUpper =3D (usNavUpper + HAL_8723A_NAV_UPPER_UNIT - 1) /
+		HAL_8723A_NAV_UPPER_UNIT;
+	rtw_write8(padapter, REG_NAV_UPPER, (u8) usNavUpper);
+}
+
+void rtl8723a_set_initial_gain(struct rtw_adapter *padapter, u32 rx_ga=
in)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct dig_t *pDigTable =3D &pHalData->odmpriv.DM_DigTable;
+
+	if (rx_gain =3D=3D 0xff)	/* restore rx gain */
+		ODM_Write_DIG23a(&pHalData->odmpriv, pDigTable->BackupIGValue);
+	else {
+		pDigTable->BackupIGValue =3D pDigTable->CurIGValue;
+		ODM_Write_DIG23a(&pHalData->odmpriv, rx_gain);
+	}
+}
+
+void rtl8723a_odm_support_ability_write(struct rtw_adapter *padapter, =
u32 val)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	pHalData->odmpriv.SupportAbility =3D val;
+}
+
+void rtl8723a_odm_support_ability_backup(struct rtw_adapter *padapter,=
 u8 val)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (val)	/*  save dm flag */
+		pHalData->odmpriv.BK_SupportAbility =3D
+			pHalData->odmpriv.SupportAbility;
+	else		/*  restore dm flag */
+		pHalData->odmpriv.SupportAbility =3D
+			pHalData->odmpriv.BK_SupportAbility;
+}
+
+void rtl8723a_odm_support_ability_set(struct rtw_adapter *padapter, u3=
2 val)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (val =3D=3D DYNAMIC_ALL_FUNC_ENABLE) {
+		pHalData->dmpriv.DMFlag =3D pHalData->dmpriv.InitDMFlag;
+		pHalData->odmpriv.SupportAbility =3D pHalData->dmpriv.InitODMFlag;
+	} else {
+		pHalData->odmpriv.SupportAbility |=3D val;
+	}
+}
+
+void rtl8723a_odm_support_ability_clr(struct rtw_adapter *padapter, u3=
2 val)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	pHalData->odmpriv.SupportAbility &=3D val;
+}
+
+void rtl8723a_set_rpwm(struct rtw_adapter *padapter, u8 val)
+{
+	rtw_write8(padapter, REG_USB_HRPWM, val);
+}
diff --git a/drivers/staging/rtl8723au/hal/hal_intf.c b/drivers/staging=
/rtl8723au/hal/hal_intf.c
new file mode 100644
index 0000000..c1a5b73
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/hal_intf.c
@@ -0,0 +1,418 @@
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
+
+#define _HAL_INTF_C_
+#include <osdep_service.h>
+#include <drv_types.h>
+
+#include <hal_intf.h>
+
+#include <usb_hal.h>
+
+void rtw_hal_chip_configure23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.intf_chip_configure)
+		padapter->HalFunc.intf_chip_configure(padapter);
+}
+
+void rtw_hal_read_chip_info23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.read_adapter_info)
+		padapter->HalFunc.read_adapter_info(padapter);
+}
+
+void rtw_hal_read_chip_version23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.read_chip_version)
+		padapter->HalFunc.read_chip_version(padapter);
+}
+
+void rtw_hal_def_value_init23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.init_default_value)
+		padapter->HalFunc.init_default_value(padapter);
+}
+void	rtw_hal_free_data23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.free_hal_data)
+		padapter->HalFunc.free_hal_data(padapter);
+}
+void	rtw_hal_dm_init23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.dm_init)
+		padapter->HalFunc.dm_init(padapter);
+}
+void rtw_hal_dm_deinit23a(struct rtw_adapter *padapter)
+{
+	/*  cancel dm  timer */
+	if (padapter->HalFunc.dm_deinit)
+		padapter->HalFunc.dm_deinit(padapter);
+}
+void	rtw_hal_sw_led_init23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.InitSwLeds)
+		padapter->HalFunc.InitSwLeds(padapter);
+}
+
+void rtw_hal_sw_led_deinit23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.DeInitSwLeds)
+		padapter->HalFunc.DeInitSwLeds(padapter);
+}
+
+u32 rtw_hal_power_on23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.hal_power_on)
+		return padapter->HalFunc.hal_power_on(padapter);
+	return _FAIL;
+}
+
+uint	 rtw_hal_init23a(struct rtw_adapter *padapter)
+{
+	uint	status =3D _SUCCESS;
+
+	padapter->hw_init_completed =3D false;
+
+	status =3D padapter->HalFunc.hal_init(padapter);
+
+	if (status =3D=3D _SUCCESS) {
+		padapter->hw_init_completed =3D true;
+
+		if (padapter->registrypriv.notch_filter =3D=3D 1)
+			rtw_hal_notch_filter23a(padapter, 1);
+
+		rtw_hal_reset_security_engine23a(padapter);
+	} else {
+		padapter->hw_init_completed =3D false;
+		DBG_8723A("rtw_hal_init23a: hal__init fail\n");
+	}
+
+	RT_TRACE(_module_hal_init_c_, _drv_err_, ("-rtl871x_hal_init:status =3D=
 0x%x\n", status));
+
+	return status;
+}
+
+uint rtw_hal_deinit23a(struct rtw_adapter *padapter)
+{
+	uint	status =3D _SUCCESS;
+
+	status =3D padapter->HalFunc.hal_deinit(padapter);
+
+	if (status =3D=3D _SUCCESS)
+		padapter->hw_init_completed =3D false;
+	else
+		DBG_8723A("\n rtw_hal_deinit23a: hal_init fail\n");
+	return status;
+}
+
+void rtw_hal_set_hwreg23a(struct rtw_adapter *padapter, u8 variable, u=
8 *val)
+{
+	if (padapter->HalFunc.SetHwRegHandler)
+		padapter->HalFunc.SetHwRegHandler(padapter, variable, val);
+}
+
+void rtw23a_hal_get_hwreg(struct rtw_adapter *padapter, u8 variable, u=
8 *val)
+{
+	if (padapter->HalFunc.GetHwRegHandler)
+		padapter->HalFunc.GetHwRegHandler(padapter, variable, val);
+}
+
+u8 rtw_hal_set_def_var23a(struct rtw_adapter *padapter, enum hal_def_v=
ariable eVariable, void *pValue)
+{
+	if (padapter->HalFunc.SetHalDefVarHandler)
+		return padapter->HalFunc.SetHalDefVarHandler(padapter, eVariable, pV=
alue);
+	return _FAIL;
+}
+u8 rtw_hal_get_def_var23a(struct rtw_adapter *padapter, enum hal_def_v=
ariable eVariable, void *pValue)
+{
+	if (padapter->HalFunc.GetHalDefVarHandler)
+		return padapter->HalFunc.GetHalDefVarHandler(padapter, eVariable, pV=
alue);
+	return _FAIL;
+}
+
+void rtw_hal_set_odm_var23a(struct rtw_adapter *padapter, enum hal_odm=
_variable eVariable, void *pValue1, bool bSet)
+{
+	if (padapter->HalFunc.SetHalODMVarHandler)
+		padapter->HalFunc.SetHalODMVarHandler(padapter, eVariable, pValue1, =
bSet);
+}
+void	rtw_hal_get_odm_var23a(struct rtw_adapter *padapter, enum hal_odm=
_variable eVariable, void *pValue1, bool bSet)
+{
+	if (padapter->HalFunc.GetHalODMVarHandler)
+		padapter->HalFunc.GetHalODMVarHandler(padapter, eVariable, pValue1, =
bSet);
+}
+
+void rtw_hal_enable_interrupt23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.enable_interrupt)
+		padapter->HalFunc.enable_interrupt(padapter);
+	else
+		DBG_8723A("%s: HalFunc.enable_interrupt is NULL!\n", __FUNCTION__);
+
+}
+void rtw_hal_disable_interrupt23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.disable_interrupt)
+		padapter->HalFunc.disable_interrupt(padapter);
+	else
+		DBG_8723A("%s: HalFunc.disable_interrupt is NULL!\n", __FUNCTION__);
+
+}
+
+u32	rtw_hal_inirp_init23a(struct rtw_adapter *padapter)
+{
+	u32 rst =3D _FAIL;
+	if (padapter->HalFunc.inirp_init)
+		rst =3D padapter->HalFunc.inirp_init(padapter);
+	else
+		DBG_8723A(" %s HalFunc.inirp_init is NULL!!!\n", __FUNCTION__);
+	return rst;
+}
+
+u32	rtw_hal_inirp_deinit23a(struct rtw_adapter *padapter)
+{
+
+	if (padapter->HalFunc.inirp_deinit)
+		return padapter->HalFunc.inirp_deinit(padapter);
+
+	return _FAIL;
+
+}
+
+u8	rtw_hal_intf_ps_func23a(struct rtw_adapter *padapter, enum hal_intf=
_ps_func efunc_id, u8 *val)
+{
+	if (padapter->HalFunc.interface_ps_func)
+		return padapter->HalFunc.interface_ps_func(padapter, efunc_id, val);
+	return _FAIL;
+}
+
+s32	rtw_hal_xmit23aframe_enqueue(struct rtw_adapter *padapter, struct =
xmit_frame *pxmitframe)
+{
+	if (padapter->HalFunc.hal_xmitframe_enqueue)
+		return padapter->HalFunc.hal_xmitframe_enqueue(padapter, pxmitframe)=
;
+
+	return false;
+}
+
+s32	rtw_hal_xmit23a(struct rtw_adapter *padapter, struct xmit_frame *p=
xmitframe)
+{
+	if (padapter->HalFunc.hal_xmit)
+		return padapter->HalFunc.hal_xmit(padapter, pxmitframe);
+
+	return false;
+}
+
+s32	rtw_hal_mgnt_xmit23a(struct rtw_adapter *padapter, struct xmit_fra=
me *pmgntframe)
+{
+	s32 ret =3D _FAIL;
+	if (padapter->HalFunc.mgnt_xmit)
+		ret =3D padapter->HalFunc.mgnt_xmit(padapter, pmgntframe);
+	return ret;
+}
+
+s32	rtw_hal_init23a_xmit_priv(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.init_xmit_priv !=3D NULL)
+		return padapter->HalFunc.init_xmit_priv(padapter);
+	return _FAIL;
+}
+void	rtw_hal_free_xmit_priv23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.free_xmit_priv !=3D NULL)
+		padapter->HalFunc.free_xmit_priv(padapter);
+}
+
+s32	rtw_hal_init23a_recv_priv(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.init_recv_priv)
+		return padapter->HalFunc.init_recv_priv(padapter);
+
+	return _FAIL;
+}
+void	rtw_hal_free_recv_priv23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.free_recv_priv)
+		padapter->HalFunc.free_recv_priv(padapter);
+}
+
+void rtw_hal_update_ra_mask23a(struct sta_info *psta, u8 rssi_level)
+{
+	struct rtw_adapter *padapter;
+	struct mlme_priv *pmlmepriv;
+
+	if (!psta)
+		return;
+
+	padapter =3D psta->padapter;
+
+	pmlmepriv =3D &padapter->mlmepriv;
+
+	if (check_fwstate(pmlmepriv, WIFI_AP_STATE)) {
+		add_RATid23a(padapter, psta, rssi_level);
+	} else {
+		if (padapter->HalFunc.UpdateRAMaskHandler)
+			padapter->HalFunc.UpdateRAMaskHandler(padapter, psta->mac_id, rssi_=
level);
+	}
+}
+
+void	rtw_hal_add_ra_tid23a(struct rtw_adapter *padapter, u32 bitmap, u=
8 arg, u8 rssi_level)
+{
+	if (padapter->HalFunc.Add_RateATid)
+		padapter->HalFunc.Add_RateATid(padapter, bitmap, arg, rssi_level);
+}
+
+/*	Start specifical interface thread		*/
+void	rtw_hal_start_thread23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.run_thread)
+		padapter->HalFunc.run_thread(padapter);
+}
+/*	Start specifical interface thread		*/
+void	rtw_hal_stop_thread23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.cancel_thread)
+		padapter->HalFunc.cancel_thread(padapter);
+}
+
+u32	rtw_hal_read_bbreg23a(struct rtw_adapter *padapter, u32 RegAddr, u=
32 BitMask)
+{
+	u32 data =3D 0;
+	if (padapter->HalFunc.read_bbreg)
+		 data =3D padapter->HalFunc.read_bbreg(padapter, RegAddr, BitMask);
+	return data;
+}
+void	rtw_hal_write_bbreg23a(struct rtw_adapter *padapter, u32 RegAddr,=
 u32 BitMask, u32 Data)
+{
+	if (padapter->HalFunc.write_bbreg)
+		padapter->HalFunc.write_bbreg(padapter, RegAddr, BitMask, Data);
+}
+
+u32	rtw_hal_read_rfreg23a(struct rtw_adapter *padapter, u32 eRFPath, u=
32 RegAddr, u32 BitMask)
+{
+	u32 data =3D 0;
+	if (padapter->HalFunc.read_rfreg)
+		data =3D padapter->HalFunc.read_rfreg(padapter, eRFPath, RegAddr, Bi=
tMask);
+	return data;
+}
+void	rtw_hal_write_rfreg23a(struct rtw_adapter *padapter, u32 eRFPath,=
 u32 RegAddr, u32 BitMask, u32 Data)
+{
+	if (padapter->HalFunc.write_rfreg)
+		padapter->HalFunc.write_rfreg(padapter, eRFPath, RegAddr, BitMask, D=
ata);
+}
+
+s32	rtw_hal_interrupt_handler23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.interrupt_handler)
+		return padapter->HalFunc.interrupt_handler(padapter);
+	return _FAIL;
+}
+
+void	rtw_hal_set_bwmode23a(struct rtw_adapter *padapter,
+			   enum ht_channel_width Bandwidth, u8 offset)
+{
+	if (padapter->HalFunc.set_bwmode_handler)
+		padapter->HalFunc.set_bwmode_handler(padapter, Bandwidth,
+						     offset);
+}
+
+void	rtw_hal_set_chan23a(struct rtw_adapter *padapter, u8 channel)
+{
+	if (padapter->HalFunc.set_channel_handler)
+		padapter->HalFunc.set_channel_handler(padapter, channel);
+}
+
+void	rtw_hal_dm_watchdog23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.hal_dm_watchdog)
+		padapter->HalFunc.hal_dm_watchdog(padapter);
+}
+
+void rtw_hal_bcn_related_reg_setting23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.SetBeaconRelatedRegistersHandler)
+		padapter->HalFunc.SetBeaconRelatedRegistersHandler(padapter);
+}
+
+void	rtw_hal_sreset_init23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.sreset_init_value23a)
+		padapter->HalFunc.sreset_init_value23a(padapter);
+}
+void rtw_hal_sreset_reset23a(struct rtw_adapter *padapter)
+{
+	padapter =3D GET_PRIMARY_ADAPTER(padapter);
+
+	if (padapter->HalFunc.silentreset)
+		padapter->HalFunc.silentreset(padapter);
+}
+
+void rtw_hal_sreset_reset23a_value23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.sreset_reset_value23a)
+		padapter->HalFunc.sreset_reset_value23a(padapter);
+}
+
+void rtw_hal_sreset_xmit_status_check23a(struct rtw_adapter *padapter)
+{
+	if (padapter->HalFunc.sreset_xmit_status_check)
+		padapter->HalFunc.sreset_xmit_status_check(padapter);
+}
+void rtw_hal_sreset_linked_status_check23a(struct rtw_adapter *padapte=
r)
+{
+	if (padapter->HalFunc.sreset_linked_status_check)
+		padapter->HalFunc.sreset_linked_status_check(padapter);
+}
+u8   rtw_hal_sreset_get_wifi_status23a(struct rtw_adapter *padapter)
+{
+	u8 status =3D 0;
+	if (padapter->HalFunc.sreset_get_wifi_status23a)
+		status =3D padapter->HalFunc.sreset_get_wifi_status23a(padapter);
+	return status;
+}
+
+bool rtw_hal_sreset_inprogress(struct rtw_adapter *padapter)
+{
+	bool inprogress =3D false;
+
+	padapter =3D GET_PRIMARY_ADAPTER(padapter);
+
+	if (padapter->HalFunc.sreset_inprogress)
+		inprogress =3D padapter->HalFunc.sreset_inprogress(padapter);
+	return inprogress;
+}
+
+void rtw_hal_notch_filter23a(struct rtw_adapter *adapter, bool enable)
+{
+	if (adapter->HalFunc.hal_notch_filter)
+		adapter->HalFunc.hal_notch_filter(adapter, enable);
+}
+
+void rtw_hal_reset_security_engine23a(struct rtw_adapter *adapter)
+{
+	if (adapter->HalFunc.hal_reset_security_engine)
+		adapter->HalFunc.hal_reset_security_engine(adapter);
+}
+
+s32 rtw_hal_c2h_handler23a(struct rtw_adapter *adapter, struct c2h_evt=
_hdr *c2h_evt)
+{
+	s32 ret =3D _FAIL;
+	if (adapter->HalFunc.c2h_handler)
+		ret =3D adapter->HalFunc.c2h_handler(adapter, c2h_evt);
+	return ret;
+}
+
+c2h_id_filter rtw_hal_c2h_id_filter_ccx23a(struct rtw_adapter *adapter=
)
+{
+	return adapter->HalFunc.c2h_id_filter_ccx;
+}
diff --git a/drivers/staging/rtl8723au/hal/odm.c b/drivers/staging/rtl8=
723au/hal/odm.c
new file mode 100644
index 0000000..584a74e
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/odm.c
@@ -0,0 +1,2090 @@
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
+#include "odm_precomp.h"
+
+static const u16 dB_Invert_Table[8][12] =3D {
+	{1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4},
+	{4, 5, 6, 6, 7, 8, 9, 10, 11, 13, 14, 16},
+	{18, 20, 22, 25, 28, 32, 35, 40, 45, 50, 56, 63},
+	{71, 79, 89, 100, 112, 126, 141, 158, 178, 200, 224, 251},
+	{282, 316, 355, 398, 447, 501, 562, 631, 708, 794, 891, 1000},
+	{1122, 1259, 1413, 1585, 1778, 1995, 2239, 2512, 2818, 3162, 3548, 39=
81},
+	{4467, 5012, 5623, 6310, 7079, 7943, 8913, 10000, 11220, 12589, 14125=
, 15849},
+	{17783, 19953, 22387, 25119, 28184, 31623, 35481, 39811, 44668, 50119=
, 56234, 65535}
+};
+
+static u32 EDCAParam[HT_IOT_PEER_MAX][3] =3D {          /*  UL			DL */
+	{0x5ea42b, 0x5ea42b, 0x5ea42b}, /* 0:unknown AP */
+	{0xa44f, 0x5ea44f, 0x5e431c}, /*  1:realtek AP */
+	{0x5ea42b, 0x5ea42b, 0x5ea42b}, /*  2:unknown AP =3D> realtek_92SE */
+	{0x5ea32b, 0x5ea42b, 0x5e4322}, /*  3:broadcom AP */
+	{0x5ea422, 0x00a44f, 0x00a44f}, /*  4:ralink AP */
+	{0x5ea322, 0x00a630, 0x00a44f}, /*  5:atheros AP */
+	{0x5e4322, 0x5e4322, 0x5e4322},/*  6:cisco AP */
+	{0x5ea44f, 0x00a44f, 0x5ea42b}, /*  8:marvell AP */
+	{0x5ea42b, 0x5ea42b, 0x5ea42b}, /*  10:unknown AP =3D> 92U AP */
+	{0x5ea42b, 0xa630, 0x5e431c}, /*  11:airgocap AP */
+};
+
+/*  EDCA Paramter for AP/ADSL   by Mingzhi 2011-11-22 */
+
+/*  Global var */
+u32 OFDMSwingTable23A[OFDM_TABLE_SIZE_92D] =3D {
+	0x7f8001fe, /*  0, +6.0dB */
+	0x788001e2, /*  1, +5.5dB */
+	0x71c001c7, /*  2, +5.0dB */
+	0x6b8001ae, /*  3, +4.5dB */
+	0x65400195, /*  4, +4.0dB */
+	0x5fc0017f, /*  5, +3.5dB */
+	0x5a400169, /*  6, +3.0dB */
+	0x55400155, /*  7, +2.5dB */
+	0x50800142, /*  8, +2.0dB */
+	0x4c000130, /*  9, +1.5dB */
+	0x47c0011f, /*  10, +1.0dB */
+	0x43c0010f, /*  11, +0.5dB */
+	0x40000100, /*  12, +0dB */
+	0x3c8000f2, /*  13, -0.5dB */
+	0x390000e4, /*  14, -1.0dB */
+	0x35c000d7, /*  15, -1.5dB */
+	0x32c000cb, /*  16, -2.0dB */
+	0x300000c0, /*  17, -2.5dB */
+	0x2d4000b5, /*  18, -3.0dB */
+	0x2ac000ab, /*  19, -3.5dB */
+	0x288000a2, /*  20, -4.0dB */
+	0x26000098, /*  21, -4.5dB */
+	0x24000090, /*  22, -5.0dB */
+	0x22000088, /*  23, -5.5dB */
+	0x20000080, /*  24, -6.0dB */
+	0x1e400079, /*  25, -6.5dB */
+	0x1c800072, /*  26, -7.0dB */
+	0x1b00006c, /*  27. -7.5dB */
+	0x19800066, /*  28, -8.0dB */
+	0x18000060, /*  29, -8.5dB */
+	0x16c0005b, /*  30, -9.0dB */
+	0x15800056, /*  31, -9.5dB */
+	0x14400051, /*  32, -10.0dB */
+	0x1300004c, /*  33, -10.5dB */
+	0x12000048, /*  34, -11.0dB */
+	0x11000044, /*  35, -11.5dB */
+	0x10000040, /*  36, -12.0dB */
+	0x0f00003c,/*  37, -12.5dB */
+	0x0e400039,/*  38, -13.0dB */
+	0x0d800036,/*  39, -13.5dB */
+	0x0cc00033,/*  40, -14.0dB */
+	0x0c000030,/*  41, -14.5dB */
+	0x0b40002d,/*  42, -15.0dB */
+};
+
+u8 CCKSwingTable_Ch1_Ch1323A[CCK_TABLE_SIZE][8] =3D {
+	{0x36, 0x35, 0x2e, 0x25, 0x1c, 0x12, 0x09, 0x04}, /*  0, +0dB */
+	{0x33, 0x32, 0x2b, 0x23, 0x1a, 0x11, 0x08, 0x04}, /*  1, -0.5dB */
+	{0x30, 0x2f, 0x29, 0x21, 0x19, 0x10, 0x08, 0x03}, /*  2, -1.0dB */
+	{0x2d, 0x2d, 0x27, 0x1f, 0x18, 0x0f, 0x08, 0x03}, /*  3, -1.5dB */
+	{0x2b, 0x2a, 0x25, 0x1e, 0x16, 0x0e, 0x07, 0x03}, /*  4, -2.0dB */
+	{0x28, 0x28, 0x22, 0x1c, 0x15, 0x0d, 0x07, 0x03}, /*  5, -2.5dB */
+	{0x26, 0x25, 0x21, 0x1b, 0x14, 0x0d, 0x06, 0x03}, /*  6, -3.0dB */
+	{0x24, 0x23, 0x1f, 0x19, 0x13, 0x0c, 0x06, 0x03}, /*  7, -3.5dB */
+	{0x22, 0x21, 0x1d, 0x18, 0x11, 0x0b, 0x06, 0x02}, /*  8, -4.0dB */
+	{0x20, 0x20, 0x1b, 0x16, 0x11, 0x08, 0x05, 0x02}, /*  9, -4.5dB */
+	{0x1f, 0x1e, 0x1a, 0x15, 0x10, 0x0a, 0x05, 0x02}, /*  10, -5.0dB */
+	{0x1d, 0x1c, 0x18, 0x14, 0x0f, 0x0a, 0x05, 0x02}, /*  11, -5.5dB */
+	{0x1b, 0x1a, 0x17, 0x13, 0x0e, 0x09, 0x04, 0x02}, /*  12, -6.0dB */
+	{0x1a, 0x19, 0x16, 0x12, 0x0d, 0x09, 0x04, 0x02}, /*  13, -6.5dB */
+	{0x18, 0x17, 0x15, 0x11, 0x0c, 0x08, 0x04, 0x02}, /*  14, -7.0dB */
+	{0x17, 0x16, 0x13, 0x10, 0x0c, 0x08, 0x04, 0x02}, /*  15, -7.5dB */
+	{0x16, 0x15, 0x12, 0x0f, 0x0b, 0x07, 0x04, 0x01}, /*  16, -8.0dB */
+	{0x14, 0x14, 0x11, 0x0e, 0x0b, 0x07, 0x03, 0x02}, /*  17, -8.5dB */
+	{0x13, 0x13, 0x10, 0x0d, 0x0a, 0x06, 0x03, 0x01}, /*  18, -9.0dB */
+	{0x12, 0x12, 0x0f, 0x0c, 0x09, 0x06, 0x03, 0x01}, /*  19, -9.5dB */
+	{0x11, 0x11, 0x0f, 0x0c, 0x09, 0x06, 0x03, 0x01}, /*  20, -10.0dB */
+	{0x10, 0x10, 0x0e, 0x0b, 0x08, 0x05, 0x03, 0x01}, /*  21, -10.5dB */
+	{0x0f, 0x0f, 0x0d, 0x0b, 0x08, 0x05, 0x03, 0x01}, /*  22, -11.0dB */
+	{0x0e, 0x0e, 0x0c, 0x0a, 0x08, 0x05, 0x02, 0x01}, /*  23, -11.5dB */
+	{0x0d, 0x0d, 0x0c, 0x0a, 0x07, 0x05, 0x02, 0x01}, /*  24, -12.0dB */
+	{0x0d, 0x0c, 0x0b, 0x09, 0x07, 0x04, 0x02, 0x01}, /*  25, -12.5dB */
+	{0x0c, 0x0c, 0x0a, 0x09, 0x06, 0x04, 0x02, 0x01}, /*  26, -13.0dB */
+	{0x0b, 0x0b, 0x0a, 0x08, 0x06, 0x04, 0x02, 0x01}, /*  27, -13.5dB */
+	{0x0b, 0x0a, 0x09, 0x08, 0x06, 0x04, 0x02, 0x01}, /*  28, -14.0dB */
+	{0x0a, 0x0a, 0x09, 0x07, 0x05, 0x03, 0x02, 0x01}, /*  29, -14.5dB */
+	{0x0a, 0x09, 0x08, 0x07, 0x05, 0x03, 0x02, 0x01}, /*  30, -15.0dB */
+	{0x09, 0x09, 0x08, 0x06, 0x05, 0x03, 0x01, 0x01}, /*  31, -15.5dB */
+	{0x09, 0x08, 0x07, 0x06, 0x04, 0x03, 0x01, 0x01}	/*  32, -16.0dB */
+};
+
+u8 CCKSwingTable_Ch1423A[CCK_TABLE_SIZE][8] =3D {
+	{0x36, 0x35, 0x2e, 0x1b, 0x00, 0x00, 0x00, 0x00}, /*  0, +0dB */
+	{0x33, 0x32, 0x2b, 0x19, 0x00, 0x00, 0x00, 0x00}, /*  1, -0.5dB */
+	{0x30, 0x2f, 0x29, 0x18, 0x00, 0x00, 0x00, 0x00}, /*  2, -1.0dB */
+	{0x2d, 0x2d, 0x17, 0x17, 0x00, 0x00, 0x00, 0x00}, /*  3, -1.5dB */
+	{0x2b, 0x2a, 0x25, 0x15, 0x00, 0x00, 0x00, 0x00}, /*  4, -2.0dB */
+	{0x28, 0x28, 0x24, 0x14, 0x00, 0x00, 0x00, 0x00}, /*  5, -2.5dB */
+	{0x26, 0x25, 0x21, 0x13, 0x00, 0x00, 0x00, 0x00}, /*  6, -3.0dB */
+	{0x24, 0x23, 0x1f, 0x12, 0x00, 0x00, 0x00, 0x00}, /*  7, -3.5dB */
+	{0x22, 0x21, 0x1d, 0x11, 0x00, 0x00, 0x00, 0x00}, /*  8, -4.0dB */
+	{0x20, 0x20, 0x1b, 0x10, 0x00, 0x00, 0x00, 0x00}, /*  9, -4.5dB */
+	{0x1f, 0x1e, 0x1a, 0x0f, 0x00, 0x00, 0x00, 0x00}, /*  10, -5.0dB */
+	{0x1d, 0x1c, 0x18, 0x0e, 0x00, 0x00, 0x00, 0x00}, /*  11, -5.5dB */
+	{0x1b, 0x1a, 0x17, 0x0e, 0x00, 0x00, 0x00, 0x00}, /*  12, -6.0dB */
+	{0x1a, 0x19, 0x16, 0x0d, 0x00, 0x00, 0x00, 0x00}, /*  13, -6.5dB */
+	{0x18, 0x17, 0x15, 0x0c, 0x00, 0x00, 0x00, 0x00}, /*  14, -7.0dB */
+	{0x17, 0x16, 0x13, 0x0b, 0x00, 0x00, 0x00, 0x00}, /*  15, -7.5dB */
+	{0x16, 0x15, 0x12, 0x0b, 0x00, 0x00, 0x00, 0x00}, /*  16, -8.0dB */
+	{0x14, 0x14, 0x11, 0x0a, 0x00, 0x00, 0x00, 0x00}, /*  17, -8.5dB */
+	{0x13, 0x13, 0x10, 0x0a, 0x00, 0x00, 0x00, 0x00}, /*  18, -9.0dB */
+	{0x12, 0x12, 0x0f, 0x09, 0x00, 0x00, 0x00, 0x00}, /*  19, -9.5dB */
+	{0x11, 0x11, 0x0f, 0x09, 0x00, 0x00, 0x00, 0x00}, /*  20, -10.0dB */
+	{0x10, 0x10, 0x0e, 0x08, 0x00, 0x00, 0x00, 0x00}, /*  21, -10.5dB */
+	{0x0f, 0x0f, 0x0d, 0x08, 0x00, 0x00, 0x00, 0x00}, /*  22, -11.0dB */
+	{0x0e, 0x0e, 0x0c, 0x07, 0x00, 0x00, 0x00, 0x00}, /*  23, -11.5dB */
+	{0x0d, 0x0d, 0x0c, 0x07, 0x00, 0x00, 0x00, 0x00}, /*  24, -12.0dB */
+	{0x0d, 0x0c, 0x0b, 0x06, 0x00, 0x00, 0x00, 0x00}, /*  25, -12.5dB */
+	{0x0c, 0x0c, 0x0a, 0x06, 0x00, 0x00, 0x00, 0x00}, /*  26, -13.0dB */
+	{0x0b, 0x0b, 0x0a, 0x06, 0x00, 0x00, 0x00, 0x00}, /*  27, -13.5dB */
+	{0x0b, 0x0a, 0x09, 0x05, 0x00, 0x00, 0x00, 0x00}, /*  28, -14.0dB */
+	{0x0a, 0x0a, 0x09, 0x05, 0x00, 0x00, 0x00, 0x00}, /*  29, -14.5dB */
+	{0x0a, 0x09, 0x08, 0x05, 0x00, 0x00, 0x00, 0x00}, /*  30, -15.0dB */
+	{0x09, 0x09, 0x08, 0x05, 0x00, 0x00, 0x00, 0x00}, /*  31, -15.5dB */
+	{0x09, 0x08, 0x07, 0x04, 0x00, 0x00, 0x00, 0x00}	/*  32, -16.0dB */
+};
+
+/*  Local Function predefine. */
+
+/* START------------COMMON INFO RELATED--------------- */
+void odm_CommonInfoSelfInit23a(struct dm_odm_t *pDM_Odm);
+
+void odm_CommonInfoSelfUpdate23a(struct dm_odm_t *pDM_Odm);
+
+void odm_CmnInfoInit_Debug23a(struct dm_odm_t *pDM_Odm);
+
+void odm_CmnInfoHook_Debug23a(struct dm_odm_t *pDM_Odm);
+
+void odm_CmnInfoUpdate_Debug23a(struct dm_odm_t *pDM_Odm);
+
+/* START---------------DIG--------------------------- */
+void odm_FalseAlarmCounterStatistics23a(struct dm_odm_t *pDM_Odm);
+
+void odm_DIG23aInit(struct dm_odm_t *pDM_Odm);
+
+void odm_DIG23a(struct dm_odm_t *pDM_Odm);
+
+void odm_CCKPacketDetectionThresh23a(struct dm_odm_t *pDM_Odm);
+/* END---------------DIG--------------------------- */
+
+/* START-------BB POWER SAVE----------------------- */
+void odm23a_DynBBPSInit(struct dm_odm_t *pDM_Odm);
+
+void odm_DynamicBBPowerSaving23a(struct dm_odm_t *pDM_Odm);
+
+void odm_1R_CCA23a(struct dm_odm_t *pDM_Odm);
+/* END---------BB POWER SAVE----------------------- */
+
+void odm_RefreshRateAdaptiveMask23aMP23a(struct dm_odm_t *pDM_Odm);
+
+void odm_RefreshRateAdaptiveMask23aCE23a(struct dm_odm_t *pDM_Odm);
+
+void odm_RefreshRateAdaptiveMask23aAPADSL23a(struct dm_odm_t *pDM_Odm)=
;
+
+void odm_DynamicTxPower23aInit(struct dm_odm_t *pDM_Odm);
+
+void odm_DynamicTxPower23aRestorePowerIndex(struct dm_odm_t *pDM_Odm);
+
+void odm_DynamicTxPower23aSavePowerIndex(struct dm_odm_t *pDM_Odm);
+
+void odm_DynamicTxPower23aWritePowerIndex(struct dm_odm_t *pDM_Odm,
+	u8 Value);
+
+void odm_DynamicTxPower23a_92C(struct dm_odm_t *pDM_Odm);
+
+void odm_DynamicTxPower23a_92D(struct dm_odm_t *pDM_Odm);
+
+void odm_RSSIMonitorInit(struct dm_odm_t *pDM_Odm);
+
+void odm_RSSIMonitorCheck23aMP(struct dm_odm_t *pDM_Odm);
+
+void odm_RSSIMonitorCheck23aCE(struct dm_odm_t *pDM_Odm);
+void odm_RSSIMonitorCheck23aAP(struct dm_odm_t *pDM_Odm);
+
+void odm_RSSIMonitorCheck23a(struct dm_odm_t *pDM_Odm);
+void odm_DynamicTxPower23a(struct dm_odm_t *pDM_Odm);
+
+void odm_SwAntDivInit(struct dm_odm_t *pDM_Odm);
+
+void odm_SwAntDivInit_NIC(struct dm_odm_t *pDM_Odm);
+
+void odm_SwAntDivChkAntSwitch(struct dm_odm_t *pDM_Odm, u8 Step);
+
+void odm_SwAntDivChkAntSwitchNIC(struct dm_odm_t *pDM_Odm,
+		u8 Step
+	);
+
+void odm_SwAntDivChkAntSwitchCallback23a(unsigned long data);
+
+void odm_GlobalAdapterCheck(void);
+
+void odm_RefreshRateAdaptiveMask23a(struct dm_odm_t *pDM_Odm);
+
+void ODM_TXPowerTrackingCheck23a(struct dm_odm_t *pDM_Odm);
+
+void odm_TXPowerTrackingCheckAP(struct dm_odm_t *pDM_Odm);
+
+void odm_RateAdaptiveMaskInit23a(struct dm_odm_t *pDM_Odm);
+
+void odm_TXPowerTrackingThermalMeterInit23a(struct dm_odm_t *pDM_Odm);
+
+void odm_TXPowerTrackingInit23a(struct dm_odm_t *pDM_Odm);
+
+void odm_TXPowerTrackingCheckMP(struct dm_odm_t *pDM_Odm);
+
+void odm_TXPowerTrackingCheckCE23a(struct dm_odm_t *pDM_Odm);
+
+void odm_EdcaTurboCheck23a(struct dm_odm_t *pDM_Odm);
+void ODM_EdcaTurboInit23a(struct dm_odm_t *pDM_Odm);
+
+void odm_EdcaTurboCheck23aCE23a(struct dm_odm_t *pDM_Odm);
+
+#define		RxDefaultAnt1		0x65a9
+#define	RxDefaultAnt2		0x569a
+
+void odm_InitHybridAntDiv23a(struct dm_odm_t *pDM_Odm);
+
+bool odm_StaDefAntSel(struct dm_odm_t *pDM_Odm,
+ u32 OFDM_Ant1_Cnt,
+ u32 OFDM_Ant2_Cnt,
+ u32 CCK_Ant1_Cnt,
+ u32 CCK_Ant2_Cnt,
+ u8 *pDefAnt
+	);
+
+void odm_SetRxIdleAnt(struct dm_odm_t *pDM_Odm,
+	u8 Ant,
+   bool   bDualPath
+);
+
+void odm_HwAntDiv23a(struct dm_odm_t *pDM_Odm);
+
+/* 3 Export Interface */
+
+/*  2011/09/21 MH Add to describe different team necessary resource al=
locate?? */
+void ODM23a_DMInit(struct dm_odm_t *pDM_Odm)
+{
+	/* For all IC series */
+	odm_CommonInfoSelfInit23a(pDM_Odm);
+	odm_CmnInfoInit_Debug23a(pDM_Odm);
+	odm_DIG23aInit(pDM_Odm);
+	odm_RateAdaptiveMaskInit23a(pDM_Odm);
+
+	if (pDM_Odm->SupportICType & ODM_IC_11N_SERIES) {
+		odm23a_DynBBPSInit(pDM_Odm);
+		odm_DynamicTxPower23aInit(pDM_Odm);
+		odm_TXPowerTrackingInit23a(pDM_Odm);
+		ODM_EdcaTurboInit23a(pDM_Odm);
+		if ((pDM_Odm->AntDivType =3D=3D CG_TRX_HW_ANTDIV)	||
+		    (pDM_Odm->AntDivType =3D=3D CGCS_RX_HW_ANTDIV)	||
+		    (pDM_Odm->AntDivType =3D=3D CG_TRX_SMART_ANTDIV))
+			odm_InitHybridAntDiv23a(pDM_Odm);
+		else if (pDM_Odm->AntDivType =3D=3D CGCS_RX_SW_ANTDIV)
+			odm_SwAntDivInit(pDM_Odm);
+	}
+}
+
+/*  2011/09/20 MH This is the entry pointer for all team to execute HW=
 out source DM. */
+/*  You can not add any dummy function here, be care, you can only use=
 DM structure */
+/*  to perform any new ODM_DM. */
+void ODM_DMWatchdog23a(struct dm_odm_t *pDM_Odm)
+{
+	/* 2012.05.03 Luke: For all IC series */
+	odm_GlobalAdapterCheck();
+	odm_CmnInfoHook_Debug23a(pDM_Odm);
+	odm_CmnInfoUpdate_Debug23a(pDM_Odm);
+	odm_CommonInfoSelfUpdate23a(pDM_Odm);
+	odm_FalseAlarmCounterStatistics23a(pDM_Odm);
+	odm_RSSIMonitorCheck23a(pDM_Odm);
+
+	/* 8723A or 8189ES platform */
+	/* NeilChen--2012--08--24-- */
+	/* Fix Leave LPS issue */
+	if ((pDM_Odm->Adapter->pwrctrlpriv.pwr_mode !=3D PS_MODE_ACTIVE) &&/*=
  in LPS mode */
+	    (pDM_Odm->SupportICType & (ODM_RTL8723A))) {
+			ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("----Step1: odm_=
DIG23a is in LPS mode\n"));
+			ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("---Step2: 8723A=
S is in LPS mode\n"));
+			odm_DIG23abyRSSI_LPS(pDM_Odm);
+	} else {
+		odm_DIG23a(pDM_Odm);
+	}
+
+	odm_CCKPacketDetectionThresh23a(pDM_Odm);
+
+	if (*(pDM_Odm->pbPowerSaving))
+		return;
+
+	odm_RefreshRateAdaptiveMask23a(pDM_Odm);
+
+	odm_DynamicBBPowerSaving23a(pDM_Odm);
+	if ((pDM_Odm->AntDivType =3D=3D  CG_TRX_HW_ANTDIV)	||
+	    (pDM_Odm->AntDivType =3D=3D CGCS_RX_HW_ANTDIV)	||
+	    (pDM_Odm->AntDivType =3D=3D CG_TRX_SMART_ANTDIV))
+		odm_HwAntDiv23a(pDM_Odm);
+	else if (pDM_Odm->AntDivType =3D=3D CGCS_RX_SW_ANTDIV)
+		odm_SwAntDivChkAntSwitch(pDM_Odm, SWAW_STEP_PEAK);
+
+	if (pDM_Odm->SupportICType & ODM_IC_11N_SERIES) {
+		ODM_TXPowerTrackingCheck23a(pDM_Odm);
+	      odm_EdcaTurboCheck23a(pDM_Odm);
+		odm_DynamicTxPower23a(pDM_Odm);
+	}
+
+	odm_dtc(pDM_Odm);
+}
+
+/*  */
+/*  Init /.. Fixed HW value. Only init time. */
+/*  */
+void ODM_CmnInfoInit23a(struct dm_odm_t *pDM_Odm,
+		enum odm_cmninfo CmnInfo,
+		u32 Value
+	)
+{
+	/* ODM_RT_TRACE(pDM_Odm,); */
+
+	/*  */
+	/*  This section is used for init value */
+	/*  */
+	switch	(CmnInfo) {
+	/*  Fixed ODM value. */
+	case	ODM_CMNINFO_ABILITY:
+		pDM_Odm->SupportAbility =3D (u32)Value;
+		break;
+	case	ODM_CMNINFO_PLATFORM:
+		break;
+	case	ODM_CMNINFO_INTERFACE:
+		pDM_Odm->SupportInterface =3D (u8)Value;
+		break;
+	case	ODM_CMNINFO_MP_TEST_CHIP:
+		pDM_Odm->bIsMPChip =3D (u8)Value;
+		break;
+	case	ODM_CMNINFO_IC_TYPE:
+		pDM_Odm->SupportICType =3D Value;
+		break;
+	case	ODM_CMNINFO_CUT_VER:
+		pDM_Odm->CutVersion =3D (u8)Value;
+		break;
+	case	ODM_CMNINFO_FAB_VER:
+		pDM_Odm->FabVersion =3D (u8)Value;
+		break;
+	case	ODM_CMNINFO_RF_TYPE:
+		pDM_Odm->RFType =3D (u8)Value;
+		break;
+	case    ODM_CMNINFO_RF_ANTENNA_TYPE:
+		pDM_Odm->AntDivType =3D (u8)Value;
+		break;
+	case	ODM_CMNINFO_BOARD_TYPE:
+		pDM_Odm->BoardType =3D (u8)Value;
+		break;
+	case	ODM_CMNINFO_EXT_LNA:
+		pDM_Odm->ExtLNA =3D (u8)Value;
+		break;
+	case	ODM_CMNINFO_EXT_PA:
+		pDM_Odm->ExtPA =3D (u8)Value;
+		break;
+	case	ODM_CMNINFO_EXT_TRSW:
+		pDM_Odm->ExtTRSW =3D (u8)Value;
+		break;
+	case	ODM_CMNINFO_PATCH_ID:
+		pDM_Odm->PatchID =3D (u8)Value;
+		break;
+	case	ODM_CMNINFO_BINHCT_TEST:
+		pDM_Odm->bInHctTest =3D (bool)Value;
+		break;
+	case	ODM_CMNINFO_BWIFI_TEST:
+		pDM_Odm->bWIFITest =3D (bool)Value;
+		break;
+	case	ODM_CMNINFO_SMART_CONCURRENT:
+		pDM_Odm->bDualMacSmartConcurrent =3D (bool)Value;
+		break;
+	/* To remove the compiler warning, must add an empty default statemen=
t to handle the other values. */
+	default:
+		/* do nothing */
+		break;
+	}
+
+	/*  */
+	/*  Tx power tracking BB swing table. */
+	/*  The base index =3D 12. +((12-n)/2)dB 13~?? =3D decrease tx pwr by=
 -((n-12)/2)dB */
+	/*  */
+	pDM_Odm->BbSwingIdxOfdm			=3D 12; /*  Set defalut value as index 12. =
*/
+	pDM_Odm->BbSwingIdxOfdmCurrent	=3D 12;
+	pDM_Odm->BbSwingFlagOfdm		=3D false;
+
+}
+
+void ODM23a_CmnInfoHook(struct dm_odm_t *pDM_Odm,
+		enum odm_cmninfo CmnInfo,
+		void *pValue
+	)
+{
+	/*  Hook call by reference pointer. */
+	switch	(CmnInfo) {
+	/*  Dynamic call by reference pointer. */
+	case	ODM_CMNINFO_MAC_PHY_MODE:
+		pDM_Odm->pMacPhyMode =3D (u8 *)pValue;
+		break;
+	case	ODM_CMNINFO_TX_UNI:
+		pDM_Odm->pNumTxBytesUnicast =3D (u64 *)pValue;
+		break;
+	case	ODM_CMNINFO_RX_UNI:
+		pDM_Odm->pNumRxBytesUnicast =3D (u64 *)pValue;
+		break;
+	case	ODM_CMNINFO_WM_MODE:
+		pDM_Odm->pWirelessMode =3D (u8 *)pValue;
+		break;
+	case	ODM_CMNINFO_BAND:
+		pDM_Odm->pBandType =3D (u8 *)pValue;
+		break;
+	case	ODM_CMNINFO_SEC_CHNL_OFFSET:
+		pDM_Odm->pSecChOffset =3D (u8 *)pValue;
+		break;
+	case	ODM_CMNINFO_SEC_MODE:
+		pDM_Odm->pSecurity =3D (u8 *)pValue;
+		break;
+	case	ODM_CMNINFO_BW:
+		pDM_Odm->pBandWidth =3D (u8 *)pValue;
+		break;
+	case	ODM_CMNINFO_CHNL:
+		pDM_Odm->pChannel =3D (u8 *)pValue;
+		break;
+	case	ODM_CMNINFO_DMSP_GET_VALUE:
+		pDM_Odm->pbGetValueFromOtherMac =3D (bool *)pValue;
+		break;
+	case	ODM_CMNINFO_BUDDY_ADAPTOR:
+		pDM_Odm->pBuddyAdapter =3D (struct rtw_adapter **)pValue;
+		break;
+	case	ODM_CMNINFO_DMSP_IS_MASTER:
+		pDM_Odm->pbMasterOfDMSP =3D (bool *)pValue;
+		break;
+	case	ODM_CMNINFO_SCAN:
+		pDM_Odm->pbScanInProcess =3D (bool *)pValue;
+		break;
+	case	ODM_CMNINFO_POWER_SAVING:
+		pDM_Odm->pbPowerSaving =3D (bool *)pValue;
+		break;
+	case	ODM_CMNINFO_ONE_PATH_CCA:
+		pDM_Odm->pOnePathCCA =3D (u8 *)pValue;
+		break;
+	case	ODM_CMNINFO_DRV_STOP:
+		pDM_Odm->pbDriverStopped =3D  (bool *)pValue;
+		break;
+	case	ODM_CMNINFO_PNP_IN:
+		pDM_Odm->pbDriverIsGoingToPnpSetPowerSleep =3D  (bool *)pValue;
+		break;
+	case	ODM_CMNINFO_INIT_ON:
+		pDM_Odm->pinit_adpt_in_progress =3D  (bool *)pValue;
+		break;
+	case	ODM_CMNINFO_ANT_TEST:
+		pDM_Odm->pAntennaTest =3D  (u8 *)pValue;
+		break;
+	case	ODM_CMNINFO_NET_CLOSED:
+		pDM_Odm->pbNet_closed =3D (bool *)pValue;
+		break;
+	/* To remove the compiler warning, must add an empty default statemen=
t to handle the other values. */
+	default:
+		/* do nothing */
+		break;
+	}
+}
+
+void ODM_CmnInfoPtrArrayHook23a(struct dm_odm_t *pDM_Odm, enum odm_cmn=
info CmnInfo,
+				u16 Index, void *pValue)
+{
+	/*  Hook call by reference pointer. */
+	switch	(CmnInfo) {
+	/*  Dynamic call by reference pointer. */
+	case	ODM_CMNINFO_STA_STATUS:
+		pDM_Odm->pODM_StaInfo[Index] =3D (struct sta_info *)pValue;
+		break;
+	/* To remove the compiler warning, must add an empty default statemen=
t to handle the other values. */
+	default:
+		/* do nothing */
+		break;
+	}
+}
+
+/*  Update Band/CHannel/.. The values are dynamic but non-per-packet. =
*/
+void ODM_CmnInfoUpdate23a(struct dm_odm_t *pDM_Odm, u32 CmnInfo, u64 V=
alue)
+{
+	/*  This init variable may be changed in run time. */
+	switch	(CmnInfo) {
+	case	ODM_CMNINFO_ABILITY:
+		pDM_Odm->SupportAbility =3D (u32)Value;
+		break;
+	case	ODM_CMNINFO_RF_TYPE:
+		pDM_Odm->RFType =3D (u8)Value;
+		break;
+	case	ODM_CMNINFO_WIFI_DIRECT:
+		pDM_Odm->bWIFI_Direct =3D (bool)Value;
+		break;
+	case	ODM_CMNINFO_WIFI_DISPLAY:
+		pDM_Odm->bWIFI_Display =3D (bool)Value;
+		break;
+	case	ODM_CMNINFO_LINK:
+		pDM_Odm->bLinked =3D (bool)Value;
+		break;
+	case	ODM_CMNINFO_RSSI_MIN:
+		pDM_Odm->RSSI_Min =3D (u8)Value;
+		break;
+	case	ODM_CMNINFO_DBG_COMP:
+		pDM_Odm->DebugComponents =3D Value;
+		break;
+	case	ODM_CMNINFO_DBG_LEVEL:
+		pDM_Odm->DebugLevel =3D (u32)Value;
+		break;
+	case	ODM_CMNINFO_RA_THRESHOLD_HIGH:
+		pDM_Odm->RateAdaptive.HighRSSIThresh =3D (u8)Value;
+		break;
+	case	ODM_CMNINFO_RA_THRESHOLD_LOW:
+		pDM_Odm->RateAdaptive.LowRSSIThresh =3D (u8)Value;
+		break;
+	}
+
+}
+
+void odm_CommonInfoSelfInit23a(struct dm_odm_t *pDM_Odm
+	)
+{
+	pDM_Odm->bCckHighPower =3D (bool) ODM_GetBBReg(pDM_Odm, 0x824, BIT9);
+	pDM_Odm->RFPathRxEnable =3D (u8) ODM_GetBBReg(pDM_Odm, 0xc04, 0x0F);
+	if (pDM_Odm->SupportICType & (ODM_RTL8723A))
+		pDM_Odm->AntDivType =3D CGCS_RX_SW_ANTDIV;
+
+	ODM_InitDebugSetting23a(pDM_Odm);
+}
+
+void odm_CommonInfoSelfUpdate23a(struct dm_odm_t *pDM_Odm)
+{
+	u8 EntryCnt =3D 0;
+	u8 i;
+	struct sta_info *pEntry;
+
+	if (*(pDM_Odm->pBandWidth) =3D=3D ODM_BW40M) {
+		if (*(pDM_Odm->pSecChOffset) =3D=3D 1)
+			pDM_Odm->ControlChannel =3D *(pDM_Odm->pChannel) - 2;
+		else if (*(pDM_Odm->pSecChOffset) =3D=3D 2)
+			pDM_Odm->ControlChannel =3D *(pDM_Odm->pChannel) + 2;
+	} else {
+		pDM_Odm->ControlChannel =3D *(pDM_Odm->pChannel);
+	}
+
+	for (i =3D 0; i < ODM_ASSOCIATE_ENTRY_NUM; i++) {
+		pEntry =3D pDM_Odm->pODM_StaInfo[i];
+		if (IS_STA_VALID(pEntry))
+			EntryCnt++;
+	}
+	if (EntryCnt =3D=3D 1)
+		pDM_Odm->bOneEntryOnly =3D true;
+	else
+		pDM_Odm->bOneEntryOnly =3D false;
+}
+
+void odm_CmnInfoInit_Debug23a(struct dm_odm_t *pDM_Odm)
+{
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("odm_CmnInfoIni=
t_Debug23a =3D=3D>\n"));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("SupportAbility=
 =3D 0x%x\n", pDM_Odm->SupportAbility));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("SupportInterfa=
ce =3D%d\n", pDM_Odm->SupportInterface));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("SupportICType =
=3D 0x%x\n", pDM_Odm->SupportICType));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("CutVersion =3D=
%d\n", pDM_Odm->CutVersion));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("FabVersion =3D=
%d\n", pDM_Odm->FabVersion));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("RFType =3D%d\n=
", pDM_Odm->RFType));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("BoardType =3D%=
d\n", pDM_Odm->BoardType));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("ExtLNA =3D%d\n=
", pDM_Odm->ExtLNA));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("ExtPA =3D%d\n"=
, pDM_Odm->ExtPA));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("ExtTRSW =3D%d\=
n", pDM_Odm->ExtTRSW));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("PatchID =3D%d\=
n", pDM_Odm->PatchID));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("bInHctTest =3D=
%d\n", pDM_Odm->bInHctTest));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("bWIFITest =3D%=
d\n", pDM_Odm->bWIFITest));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("bDualMacSmartC=
oncurrent =3D%d\n", pDM_Odm->bDualMacSmartConcurrent));
+
+}
+
+void odm_CmnInfoHook_Debug23a(struct dm_odm_t *pDM_Odm)
+{
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("odm_CmnInfoHoo=
k_Debug23a =3D=3D>\n"));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("pNumTxBytesUni=
cast =3D%llu\n", *(pDM_Odm->pNumTxBytesUnicast)));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("pNumRxBytesUni=
cast =3D%llu\n", *(pDM_Odm->pNumRxBytesUnicast)));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("pWirelessMode =
=3D 0x%x\n", *(pDM_Odm->pWirelessMode)));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("pSecChOffset =3D=
%d\n", *(pDM_Odm->pSecChOffset)));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("pSecurity =3D%=
d\n", *(pDM_Odm->pSecurity)));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("pBandWidth =3D=
%d\n", *(pDM_Odm->pBandWidth)));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("pChannel =3D%d=
\n", *(pDM_Odm->pChannel)));
+
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("pbScanInProces=
s =3D%d\n", *(pDM_Odm->pbScanInProcess)));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("pbPowerSaving =
=3D%d\n", *(pDM_Odm->pbPowerSaving)));
+}
+
+void odm_CmnInfoUpdate_Debug23a(struct dm_odm_t *pDM_Odm)
+{
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("odm_CmnInfoUpd=
ate_Debug23a =3D=3D>\n"));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("bWIFI_Direct =3D=
%d\n", pDM_Odm->bWIFI_Direct));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("bWIFI_Display =
=3D%d\n", pDM_Odm->bWIFI_Display));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("bLinked =3D%d\=
n", pDM_Odm->bLinked));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("RSSI_Min =3D%d=
\n", pDM_Odm->RSSI_Min));
+}
+
+void ODM_Write_DIG23a(struct dm_odm_t *pDM_Odm,
+	u8 CurrentIGI
+	)
+{
+	struct dig_t *pDM_DigTable =3D &pDM_Odm->DM_DigTable;
+
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("ODM_REG(IGI_A, pD=
M_Odm) =3D 0x%x, ODM_BIT(IGI, pDM_Odm) =3D 0x%x \n",
+		ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm)));
+
+	if (pDM_DigTable->CurIGValue !=3D CurrentIGI) {
+		ODM_SetBBReg(pDM_Odm, ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm)=
, CurrentIGI);
+		ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("CurrentIGI(0x%02=
x). \n", CurrentIGI));
+		pDM_DigTable->CurIGValue =3D CurrentIGI;
+	}
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD,
+		     ("ODM_Write_DIG23a():CurrentIGI =3D 0x%x \n", CurrentIGI));
+}
+
+/* Need LPS mode for CE platform --2012--08--24--- */
+/* 8723AS/8189ES */
+void odm_DIG23abyRSSI_LPS(struct dm_odm_t *pDM_Odm)
+{
+	struct rtw_adapter *pAdapter =3D pDM_Odm->Adapter;
+	struct false_alarm_stats *pFalseAlmCnt =3D &pDM_Odm->FalseAlmCnt;
+	u8 RSSI_Lower =3D DM_DIG_MIN_NIC;   /* 0x1E or 0x1C */
+	u8 bFwCurrentInPSMode =3D false;
+	u8 CurrentIGI =3D pDM_Odm->RSSI_Min;
+
+	if (!(pDM_Odm->SupportICType & (ODM_RTL8723A)))
+		return;
+
+	CurrentIGI =3D CurrentIGI+RSSI_OFFSET_DIG;
+	bFwCurrentInPSMode =3D pAdapter->pwrctrlpriv.bFwCurrentInPSMode;
+
+	/* ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG_LPS, ODM_DBG_LOUD, ("odm_DIG23a=
() =3D=3D>\n")); */
+
+	/*  Using FW PS mode to make IGI */
+	if (bFwCurrentInPSMode) {
+		ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("---Neil---odm_DI=
G23a is in LPS mode\n"));
+		/* Adjust by  FA in LPS MODE */
+		if (pFalseAlmCnt->Cnt_all > DM_DIG_FA_TH2_LPS)
+			CurrentIGI =3D CurrentIGI+2;
+		else if (pFalseAlmCnt->Cnt_all > DM_DIG_FA_TH1_LPS)
+			CurrentIGI =3D CurrentIGI+1;
+		else if (pFalseAlmCnt->Cnt_all < DM_DIG_FA_TH0_LPS)
+			CurrentIGI =3D CurrentIGI-1;
+	} else {
+		CurrentIGI =3D RSSI_Lower;
+	}
+
+	/* Lower bound checking */
+
+	/* RSSI Lower bound check */
+	if ((pDM_Odm->RSSI_Min-10) > DM_DIG_MIN_NIC)
+		RSSI_Lower =3D (pDM_Odm->RSSI_Min-10);
+	else
+		RSSI_Lower =3D DM_DIG_MIN_NIC;
+
+	/* Upper and Lower Bound checking */
+	 if (CurrentIGI > DM_DIG_MAX_NIC)
+		CurrentIGI =3D DM_DIG_MAX_NIC;
+	 else if (CurrentIGI < RSSI_Lower)
+		CurrentIGI =3D RSSI_Lower;
+
+	ODM_Write_DIG23a(pDM_Odm, CurrentIGI);/* ODM_Write_DIG23a(pDM_Odm, pD=
M_DigTable->CurIGValue); */
+
+}
+
+void odm_DIG23aInit(struct dm_odm_t *pDM_Odm)
+{
+	struct dig_t *pDM_DigTable =3D &pDM_Odm->DM_DigTable;
+
+	pDM_DigTable->CurIGValue =3D (u8) ODM_GetBBReg(pDM_Odm, ODM_REG(IGI_A=
, pDM_Odm), ODM_BIT(IGI, pDM_Odm));
+	pDM_DigTable->RssiLowThresh	=3D DM_DIG_THRESH_LOW;
+	pDM_DigTable->RssiHighThresh	=3D DM_DIG_THRESH_HIGH;
+	pDM_DigTable->FALowThresh	=3D DM_FALSEALARM_THRESH_LOW;
+	pDM_DigTable->FAHighThresh	=3D DM_FALSEALARM_THRESH_HIGH;
+	if (pDM_Odm->BoardType =3D=3D ODM_BOARD_HIGHPWR) {
+		pDM_DigTable->rx_gain_range_max =3D DM_DIG_MAX_NIC;
+		pDM_DigTable->rx_gain_range_min =3D DM_DIG_MIN_NIC;
+	} else {
+		pDM_DigTable->rx_gain_range_max =3D DM_DIG_MAX_NIC;
+		pDM_DigTable->rx_gain_range_min =3D DM_DIG_MIN_NIC;
+	}
+	pDM_DigTable->BackoffVal =3D DM_DIG_BACKOFF_DEFAULT;
+	pDM_DigTable->BackoffVal_range_max =3D DM_DIG_BACKOFF_MAX;
+	pDM_DigTable->BackoffVal_range_min =3D DM_DIG_BACKOFF_MIN;
+	pDM_DigTable->PreCCK_CCAThres =3D 0xFF;
+	pDM_DigTable->CurCCK_CCAThres =3D 0x83;
+	pDM_DigTable->ForbiddenIGI =3D DM_DIG_MIN_NIC;
+	pDM_DigTable->LargeFAHit =3D 0;
+	pDM_DigTable->Recover_cnt =3D 0;
+	pDM_DigTable->DIG_Dynamic_MIN_0 =3D DM_DIG_MIN_NIC;
+	pDM_DigTable->DIG_Dynamic_MIN_1 =3D DM_DIG_MIN_NIC;
+	pDM_DigTable->bMediaConnect_0 =3D false;
+	pDM_DigTable->bMediaConnect_1 =3D false;
+
+	/* To Initialize pDM_Odm->bDMInitialGainEnable =3D=3D false to avoid =
DIG error */
+	pDM_Odm->bDMInitialGainEnable =3D true;
+
+}
+
+void odm_DIG23a(struct dm_odm_t *pDM_Odm)
+{
+
+	struct dig_t *pDM_DigTable =3D &pDM_Odm->DM_DigTable;
+	struct false_alarm_stats *pFalseAlmCnt =3D &pDM_Odm->FalseAlmCnt;
+	u8 DIG_Dynamic_MIN;
+	u8 DIG_MaxOfMin;
+	bool FirstConnect, FirstDisConnect;
+	u8 dm_dig_max, dm_dig_min;
+	u8 CurrentIGI =3D pDM_DigTable->CurIGValue;
+
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("odm_DIG23a() =3D=3D=
>\n"));
+	/* if (!(pDM_Odm->SupportAbility & (ODM_BB_DIG|ODM_BB_FA_CNT))) */
+	if ((!(pDM_Odm->SupportAbility&ODM_BB_DIG)) || (!(pDM_Odm->SupportAbi=
lity&ODM_BB_FA_CNT))) {
+		ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD,
+			     ("odm_DIG23a() Return: SupportAbility ODM_BB_DIG or ODM_BB_FA_=
CNT is disabled\n"));
+		return;
+	}
+
+	if (*(pDM_Odm->pbScanInProcess)) {
+		ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("odm_DIG23a() Ret=
urn: In Scan Progress \n"));
+		return;
+	}
+
+	/* add by Neil Chen to avoid PSD is processing */
+	if (!pDM_Odm->bDMInitialGainEnable) {
+		ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("odm_DIG23a() Ret=
urn: PSD is Processing \n"));
+		return;
+	}
+
+	DIG_Dynamic_MIN =3D pDM_DigTable->DIG_Dynamic_MIN_0;
+	FirstConnect =3D (pDM_Odm->bLinked) && (!pDM_DigTable->bMediaConnect_=
0);
+	FirstDisConnect =3D (!pDM_Odm->bLinked) && (pDM_DigTable->bMediaConne=
ct_0);
+
+	/* 1 Boundary Decision */
+	if ((pDM_Odm->SupportICType & (ODM_RTL8723A)) &&
+	    ((pDM_Odm->BoardType =3D=3D ODM_BOARD_HIGHPWR) || pDM_Odm->ExtLNA=
)) {
+		dm_dig_max =3D DM_DIG_MAX_NIC_HP;
+		dm_dig_min =3D DM_DIG_MIN_NIC_HP;
+		DIG_MaxOfMin =3D DM_DIG_MAX_AP_HP;
+	} else {
+		dm_dig_max =3D DM_DIG_MAX_NIC;
+		dm_dig_min =3D DM_DIG_MIN_NIC;
+		DIG_MaxOfMin =3D DM_DIG_MAX_AP;
+	}
+
+	if (pDM_Odm->bLinked) {
+	      /* 2 8723A Series, offset need to be 10 */
+		if (pDM_Odm->SupportICType =3D=3D (ODM_RTL8723A)) {
+			/* 2 Upper Bound */
+			if ((pDM_Odm->RSSI_Min + 10) > DM_DIG_MAX_NIC)
+				pDM_DigTable->rx_gain_range_max =3D DM_DIG_MAX_NIC;
+			else if ((pDM_Odm->RSSI_Min + 10) < DM_DIG_MIN_NIC)
+				pDM_DigTable->rx_gain_range_max =3D DM_DIG_MIN_NIC;
+			else
+				pDM_DigTable->rx_gain_range_max =3D pDM_Odm->RSSI_Min + 10;
+
+			/* 2 If BT is Concurrent, need to set Lower Bound */
+			DIG_Dynamic_MIN =3D DM_DIG_MIN_NIC;
+		} else {
+			/* 2 Modify DIG upper bound */
+			if ((pDM_Odm->RSSI_Min + 20) > dm_dig_max)
+				pDM_DigTable->rx_gain_range_max =3D dm_dig_max;
+			else if ((pDM_Odm->RSSI_Min + 20) < dm_dig_min)
+				pDM_DigTable->rx_gain_range_max =3D dm_dig_min;
+			else
+				pDM_DigTable->rx_gain_range_max =3D pDM_Odm->RSSI_Min + 20;
+
+			/* 2 Modify DIG lower bound */
+			if (pDM_Odm->bOneEntryOnly) {
+				if (pDM_Odm->RSSI_Min < dm_dig_min)
+					DIG_Dynamic_MIN =3D dm_dig_min;
+				else if (pDM_Odm->RSSI_Min > DIG_MaxOfMin)
+					DIG_Dynamic_MIN =3D DIG_MaxOfMin;
+				else
+					DIG_Dynamic_MIN =3D pDM_Odm->RSSI_Min;
+				ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD,
+					     ("odm_DIG23a() : bOneEntryOnly =3D true,  DIG_Dynamic_MIN =3D=
 0x%x\n",
+					     DIG_Dynamic_MIN));
+				ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD,
+					     ("odm_DIG23a() : pDM_Odm->RSSI_Min =3D%d\n",
+					     pDM_Odm->RSSI_Min));
+			} else {
+				DIG_Dynamic_MIN =3D dm_dig_min;
+			}
+		}
+	} else {
+		pDM_DigTable->rx_gain_range_max =3D dm_dig_max;
+		DIG_Dynamic_MIN =3D dm_dig_min;
+		ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("odm_DIG23a() : N=
o Link\n"));
+	}
+
+	/* 1 Modify DIG lower bound, deal with abnormally large false alarm *=
/
+	if (pFalseAlmCnt->Cnt_all > 10000) {
+		ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD,
+			     ("dm_DIG(): Abnornally false alarm case. \n"));
+
+		if (pDM_DigTable->LargeFAHit !=3D 3)
+			pDM_DigTable->LargeFAHit++;
+		if (pDM_DigTable->ForbiddenIGI < CurrentIGI) {
+			pDM_DigTable->ForbiddenIGI =3D CurrentIGI;
+			pDM_DigTable->LargeFAHit =3D 1;
+		}
+
+		if (pDM_DigTable->LargeFAHit >=3D 3) {
+			if ((pDM_DigTable->ForbiddenIGI+1) > pDM_DigTable->rx_gain_range_ma=
x)
+				pDM_DigTable->rx_gain_range_min =3D pDM_DigTable->rx_gain_range_ma=
x;
+			else
+				pDM_DigTable->rx_gain_range_min =3D (pDM_DigTable->ForbiddenIGI + =
1);
+			pDM_DigTable->Recover_cnt =3D 3600; /* 3600 =3D 2hr */
+		}
+	} else {
+		/* Recovery mechanism for IGI lower bound */
+		if (pDM_DigTable->Recover_cnt !=3D 0) {
+			pDM_DigTable->Recover_cnt--;
+		} else {
+			if (pDM_DigTable->LargeFAHit < 3) {
+				if ((pDM_DigTable->ForbiddenIGI - 1) < DIG_Dynamic_MIN) {
+					pDM_DigTable->ForbiddenIGI =3D DIG_Dynamic_MIN; /* DM_DIG_MIN; */
+					pDM_DigTable->rx_gain_range_min =3D DIG_Dynamic_MIN; /* DM_DIG_MI=
N; */
+					ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD,
+						     ("odm_DIG23a(): Normal Case: At Lower Bound\n"));
+				} else {
+					pDM_DigTable->ForbiddenIGI--;
+					pDM_DigTable->rx_gain_range_min =3D (pDM_DigTable->ForbiddenIGI +=
 1);
+					ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD,
+						     ("odm_DIG23a(): Normal Case: Approach Lower Bound\n"));
+				}
+			} else {
+				pDM_DigTable->LargeFAHit =3D 0;
+			}
+		}
+	}
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("odm_DIG23a(): pDM=
_DigTable->LargeFAHit =3D%d\n", pDM_DigTable->LargeFAHit));
+
+	/* 1 Adjust initial gain by false alarm */
+	if (pDM_Odm->bLinked) {
+		ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("odm_DIG23a(): DI=
G AfterLink\n"));
+		if (FirstConnect) {
+			CurrentIGI =3D pDM_Odm->RSSI_Min;
+			ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("DIG: First Conn=
ect\n"));
+		} else {
+			if (pFalseAlmCnt->Cnt_all > DM_DIG_FA_TH2)
+				CurrentIGI =3D CurrentIGI + 4;/* pDM_DigTable->CurIGValue =3D pDM_=
DigTable->PreIGValue+2; */
+			else if (pFalseAlmCnt->Cnt_all > DM_DIG_FA_TH1)
+				CurrentIGI =3D CurrentIGI + 2;/* pDM_DigTable->CurIGValue =3D pDM_=
DigTable->PreIGValue+1; */
+			else if (pFalseAlmCnt->Cnt_all < DM_DIG_FA_TH0)
+				CurrentIGI =3D CurrentIGI - 2;/* pDM_DigTable->CurIGValue =3D pDM_=
DigTable->PreIGValue-1; */
+		}
+	} else {
+		ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("odm_DIG23a(): DI=
G BeforeLink\n"));
+		if (FirstDisConnect) {
+			CurrentIGI =3D pDM_DigTable->rx_gain_range_min;
+			ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("odm_DIG23a(): F=
irst DisConnect \n"));
+		} else {
+			/* 2012.03.30 LukeLee: enable DIG before link but with very high th=
resholds */
+			if (pFalseAlmCnt->Cnt_all > 10000)
+				CurrentIGI =3D CurrentIGI + 2;/* pDM_DigTable->CurIGValue =3D pDM_=
DigTable->PreIGValue+2; */
+			else if (pFalseAlmCnt->Cnt_all > 8000)
+				CurrentIGI =3D CurrentIGI + 1;/* pDM_DigTable->CurIGValue =3D pDM_=
DigTable->PreIGValue+1; */
+			else if (pFalseAlmCnt->Cnt_all < 500)
+				CurrentIGI =3D CurrentIGI - 1;/* pDM_DigTable->CurIGValue =3D pDM_=
DigTable->PreIGValue-1; */
+			ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("odm_DIG23a(): E=
ngland DIG \n"));
+		}
+	}
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("odm_DIG23a(): DIG=
 End Adjust IGI\n"));
+	/* 1 Check initial gain by upper/lower bound */
+	if (CurrentIGI > pDM_DigTable->rx_gain_range_max)
+		CurrentIGI =3D pDM_DigTable->rx_gain_range_max;
+	if (CurrentIGI < pDM_DigTable->rx_gain_range_min)
+		CurrentIGI =3D pDM_DigTable->rx_gain_range_min;
+
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("odm_DIG23a(): rx_=
gain_range_max =3D 0x%x, rx_gain_range_min =3D 0x%x\n",
+		pDM_DigTable->rx_gain_range_max, pDM_DigTable->rx_gain_range_min));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("odm_DIG23a(): Tot=
alFA =3D%d\n", pFalseAlmCnt->Cnt_all));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("odm_DIG23a(): Cur=
IGValue =3D 0x%x\n", CurrentIGI));
+
+	/* 2 High power RSSI threshold */
+
+	ODM_Write_DIG23a(pDM_Odm, CurrentIGI);/* ODM_Write_DIG23a(pDM_Odm, pD=
M_DigTable->CurIGValue); */
+	pDM_DigTable->bMediaConnect_0 =3D pDM_Odm->bLinked;
+	pDM_DigTable->DIG_Dynamic_MIN_0 =3D DIG_Dynamic_MIN;
+}
+
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 FASLE ALARM CHECK */
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+
+void odm_FalseAlarmCounterStatistics23a(struct dm_odm_t *pDM_Odm)
+{
+	u32 ret_value;
+	struct false_alarm_stats *FalseAlmCnt =3D &pDM_Odm->FalseAlmCnt;
+
+	if (!(pDM_Odm->SupportAbility & ODM_BB_FA_CNT))
+		return;
+
+	if (pDM_Odm->SupportICType & ODM_IC_11N_SERIES) {
+		/* hold ofdm counter */
+		ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_HOLDC_11N, BIT31, 1); /* hold =
page C counter */
+		ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_RSTD_11N, BIT31, 1); /* hold p=
age D counter */
+
+		ret_value =3D ODM_GetBBReg(pDM_Odm, ODM_REG_OFDM_FA_TYPE1_11N, bMask=
DWord);
+		FalseAlmCnt->Cnt_Fast_Fsync =3D (ret_value&0xffff);
+		FalseAlmCnt->Cnt_SB_Search_fail =3D ((ret_value&0xffff0000)>>16);
+		ret_value =3D ODM_GetBBReg(pDM_Odm, ODM_REG_OFDM_FA_TYPE2_11N, bMask=
DWord);
+		FalseAlmCnt->Cnt_OFDM_CCA =3D (ret_value&0xffff);
+		FalseAlmCnt->Cnt_Parity_Fail =3D ((ret_value&0xffff0000)>>16);
+		ret_value =3D ODM_GetBBReg(pDM_Odm, ODM_REG_OFDM_FA_TYPE3_11N, bMask=
DWord);
+		FalseAlmCnt->Cnt_Rate_Illegal =3D (ret_value&0xffff);
+		FalseAlmCnt->Cnt_Crc8_fail =3D ((ret_value&0xffff0000)>>16);
+		ret_value =3D ODM_GetBBReg(pDM_Odm, ODM_REG_OFDM_FA_TYPE4_11N, bMask=
DWord);
+		FalseAlmCnt->Cnt_Mcs_fail =3D (ret_value&0xffff);
+
+		FalseAlmCnt->Cnt_Ofdm_fail =3D FalseAlmCnt->Cnt_Parity_Fail +
+					     FalseAlmCnt->Cnt_Rate_Illegal +
+					     FalseAlmCnt->Cnt_Crc8_fail +
+					     FalseAlmCnt->Cnt_Mcs_fail +
+					     FalseAlmCnt->Cnt_Fast_Fsync +
+					     FalseAlmCnt->Cnt_SB_Search_fail;
+	/* hold cck counter */
+	ODM_SetBBReg(pDM_Odm, ODM_REG_CCK_FA_RST_11N, BIT12, 1);
+	ODM_SetBBReg(pDM_Odm, ODM_REG_CCK_FA_RST_11N, BIT14, 1);
+
+	ret_value =3D ODM_GetBBReg(pDM_Odm, ODM_REG_CCK_FA_LSB_11N, bMaskByte=
0);
+	FalseAlmCnt->Cnt_Cck_fail =3D ret_value;
+	ret_value =3D ODM_GetBBReg(pDM_Odm, ODM_REG_CCK_FA_MSB_11N, bMaskByte=
3);
+	FalseAlmCnt->Cnt_Cck_fail +=3D  (ret_value & 0xff) << 8;
+
+	ret_value =3D ODM_GetBBReg(pDM_Odm, ODM_REG_CCK_CCA_CNT_11N, bMaskDWo=
rd);
+	FalseAlmCnt->Cnt_CCK_CCA =3D ((ret_value&0xFF)<<8) | ((ret_value&0xFF=
00)>>8);
+
+	FalseAlmCnt->Cnt_all =3D (FalseAlmCnt->Cnt_Fast_Fsync +
+				FalseAlmCnt->Cnt_SB_Search_fail +
+				FalseAlmCnt->Cnt_Parity_Fail +
+				FalseAlmCnt->Cnt_Rate_Illegal +
+				FalseAlmCnt->Cnt_Crc8_fail +
+				FalseAlmCnt->Cnt_Mcs_fail +
+				FalseAlmCnt->Cnt_Cck_fail);
+
+	FalseAlmCnt->Cnt_CCA_all =3D FalseAlmCnt->Cnt_OFDM_CCA + FalseAlmCnt-=
>Cnt_CCK_CCA;
+
+	if (pDM_Odm->SupportICType >=3D ODM_RTL8723A) {
+		/* reset false alarm counter registers */
+		ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_RSTC_11N, BIT31, 1);
+		ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_RSTC_11N, BIT31, 0);
+		ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_RSTD_11N, BIT27, 1);
+		ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_RSTD_11N, BIT27, 0);
+		/* update ofdm counter */
+		ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_HOLDC_11N, BIT31, 0); /* updat=
e page C counter */
+		ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_RSTD_11N, BIT31, 0); /* update=
 page D counter */
+
+		/* reset CCK CCA counter */
+		ODM_SetBBReg(pDM_Odm, ODM_REG_CCK_FA_RST_11N, BIT13|BIT12, 0);
+		ODM_SetBBReg(pDM_Odm, ODM_REG_CCK_FA_RST_11N, BIT13|BIT12, 2);
+		/* reset CCK FA counter */
+		ODM_SetBBReg(pDM_Odm, ODM_REG_CCK_FA_RST_11N, BIT15|BIT14, 0);
+		ODM_SetBBReg(pDM_Odm, ODM_REG_CCK_FA_RST_11N, BIT15|BIT14, 2);
+	}
+
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD, ("Enter odm_Fals=
eAlarmCounterStatistics23a\n"));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD, ("Cnt_Fast_Fsync=
 =3D%d, Cnt_SB_Search_fail =3D%d\n",
+		FalseAlmCnt->Cnt_Fast_Fsync, FalseAlmCnt->Cnt_SB_Search_fail));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD, ("Cnt_Parity_Fai=
l =3D%d, Cnt_Rate_Illegal =3D%d\n",
+		FalseAlmCnt->Cnt_Parity_Fail, FalseAlmCnt->Cnt_Rate_Illegal));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD, ("Cnt_Crc8_fail =
=3D%d, Cnt_Mcs_fail =3D%d\n",
+		FalseAlmCnt->Cnt_Crc8_fail, FalseAlmCnt->Cnt_Mcs_fail));
+	} else { /* FOR ODM_IC_11AC_SERIES */
+		/* read OFDM FA counter */
+		FalseAlmCnt->Cnt_Ofdm_fail =3D ODM_GetBBReg(pDM_Odm, ODM_REG_OFDM_FA=
_11AC, bMaskLWord);
+		FalseAlmCnt->Cnt_Cck_fail =3D ODM_GetBBReg(pDM_Odm, ODM_REG_CCK_FA_1=
1AC, bMaskLWord);
+		FalseAlmCnt->Cnt_all =3D FalseAlmCnt->Cnt_Ofdm_fail + FalseAlmCnt->C=
nt_Cck_fail;
+
+		/*  reset OFDM FA coutner */
+		ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_RST_11AC, BIT17, 1);
+		ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_RST_11AC, BIT17, 0);
+		/*  reset CCK FA counter */
+		ODM_SetBBReg(pDM_Odm, ODM_REG_CCK_FA_RST_11AC, BIT15, 0);
+		ODM_SetBBReg(pDM_Odm, ODM_REG_CCK_FA_RST_11AC, BIT15, 1);
+	}
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD, ("Cnt_Cck_fail =3D=
%d\n", FalseAlmCnt->Cnt_Cck_fail));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD, ("Cnt_Ofdm_fail =
=3D%d\n", FalseAlmCnt->Cnt_Ofdm_fail));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD, ("Total False Al=
arm =3D%d\n", FalseAlmCnt->Cnt_all));
+}
+
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 CCK Packet Detect Threshold */
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+
+void odm_CCKPacketDetectionThresh23a(struct dm_odm_t *pDM_Odm)
+{
+	struct false_alarm_stats *FalseAlmCnt =3D &pDM_Odm->FalseAlmCnt;
+	u8 CurCCK_CCAThres;
+
+	if (!(pDM_Odm->SupportAbility & (ODM_BB_CCK_PD|ODM_BB_FA_CNT)))
+		return;
+
+	if (pDM_Odm->ExtLNA)
+		return;
+
+	if (pDM_Odm->bLinked) {
+		if (pDM_Odm->RSSI_Min > 25) {
+			CurCCK_CCAThres =3D 0xcd;
+		} else if ((pDM_Odm->RSSI_Min <=3D 25) && (pDM_Odm->RSSI_Min > 10)) =
{
+			CurCCK_CCAThres =3D 0x83;
+		} else {
+			if (FalseAlmCnt->Cnt_Cck_fail > 1000)
+				CurCCK_CCAThres =3D 0x83;
+			else
+				CurCCK_CCAThres =3D 0x40;
+		}
+	} else {
+		if (FalseAlmCnt->Cnt_Cck_fail > 1000)
+			CurCCK_CCAThres =3D 0x83;
+		else
+			CurCCK_CCAThres =3D 0x40;
+	}
+
+	ODM_Write_CCK_CCA_Thres23a(pDM_Odm, CurCCK_CCAThres);
+}
+
+void ODM_Write_CCK_CCA_Thres23a(struct dm_odm_t *pDM_Odm, u8 CurCCK_CC=
AThres)
+{
+	struct dig_t *pDM_DigTable =3D &pDM_Odm->DM_DigTable;
+
+	if (pDM_DigTable->CurCCK_CCAThres !=3D CurCCK_CCAThres)
+		ODM_Write1Byte(pDM_Odm, ODM_REG(CCK_CCA, pDM_Odm), CurCCK_CCAThres);
+	pDM_DigTable->PreCCK_CCAThres =3D pDM_DigTable->CurCCK_CCAThres;
+	pDM_DigTable->CurCCK_CCAThres =3D CurCCK_CCAThres;
+
+}
+
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 BB Power Save */
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+void odm23a_DynBBPSInit(struct dm_odm_t *pDM_Odm)
+{
+	struct dynamic_pwr_sav *pDM_PSTable =3D &pDM_Odm->DM_PSTable;
+
+	pDM_PSTable->PreCCAState =3D CCA_MAX;
+	pDM_PSTable->CurCCAState =3D CCA_MAX;
+	pDM_PSTable->PreRFState =3D RF_MAX;
+	pDM_PSTable->CurRFState =3D RF_MAX;
+	pDM_PSTable->Rssi_val_min =3D 0;
+	pDM_PSTable->initialize =3D 0;
+}
+
+void odm_DynamicBBPowerSaving23a(struct dm_odm_t *pDM_Odm)
+{
+	return;
+}
+
+void odm_1R_CCA23a(struct dm_odm_t *pDM_Odm)
+{
+	struct dynamic_pwr_sav *pDM_PSTable =3D &pDM_Odm->DM_PSTable;
+
+	if (pDM_Odm->RSSI_Min !=3D 0xFF) {
+		if (pDM_PSTable->PreCCAState =3D=3D CCA_2R) {
+			if (pDM_Odm->RSSI_Min >=3D 35)
+				pDM_PSTable->CurCCAState =3D CCA_1R;
+			else
+				pDM_PSTable->CurCCAState =3D CCA_2R;
+		} else {
+			if (pDM_Odm->RSSI_Min <=3D 30)
+				pDM_PSTable->CurCCAState =3D CCA_2R;
+			else
+				pDM_PSTable->CurCCAState =3D CCA_1R;
+		}
+	} else {
+		pDM_PSTable->CurCCAState =3D CCA_MAX;
+	}
+
+	if (pDM_PSTable->PreCCAState !=3D pDM_PSTable->CurCCAState) {
+		if (pDM_PSTable->CurCCAState =3D=3D CCA_1R) {
+			if (pDM_Odm->RFType =3D=3D ODM_2T2R)
+				ODM_SetBBReg(pDM_Odm, 0xc04, bMaskByte0, 0x13);
+			else
+				ODM_SetBBReg(pDM_Odm, 0xc04, bMaskByte0, 0x23);
+		} else {
+			ODM_SetBBReg(pDM_Odm, 0xc04, bMaskByte0, 0x33);
+			/* PHY_SetBBReg(pAdapter, 0xe70, bMaskByte3, 0x63); */
+		}
+		pDM_PSTable->PreCCAState =3D pDM_PSTable->CurCCAState;
+	}
+}
+
+void ODM_RF_Saving23a(struct dm_odm_t *pDM_Odm, u8 bForceInNormal)
+{
+	struct dynamic_pwr_sav *pDM_PSTable =3D &pDM_Odm->DM_PSTable;
+	u8 Rssi_Up_bound =3D 30 ;
+	u8 Rssi_Low_bound =3D 25;
+	if (pDM_Odm->PatchID =3D=3D 40) { /* RT_CID_819x_FUNAI_TV */
+		Rssi_Up_bound =3D 50 ;
+		Rssi_Low_bound =3D 45;
+	}
+	if (pDM_PSTable->initialize =3D=3D 0) {
+
+		pDM_PSTable->Reg874 =3D (ODM_GetBBReg(pDM_Odm, 0x874, bMaskDWord)&0x=
1CC000)>>14;
+		pDM_PSTable->RegC70 =3D (ODM_GetBBReg(pDM_Odm, 0xc70, bMaskDWord)&BI=
T3)>>3;
+		pDM_PSTable->Reg85C =3D (ODM_GetBBReg(pDM_Odm, 0x85c, bMaskDWord)&0x=
=46F000000)>>24;
+		pDM_PSTable->RegA74 =3D (ODM_GetBBReg(pDM_Odm, 0xa74, bMaskDWord)&0x=
=46000)>>12;
+		/* Reg818 =3D PHY_QueryBBReg(pAdapter, 0x818, bMaskDWord); */
+		pDM_PSTable->initialize =3D 1;
+	}
+
+	if (!bForceInNormal) {
+		if (pDM_Odm->RSSI_Min !=3D 0xFF) {
+			if (pDM_PSTable->PreRFState =3D=3D RF_Normal) {
+				if (pDM_Odm->RSSI_Min >=3D Rssi_Up_bound)
+					pDM_PSTable->CurRFState =3D RF_Save;
+				else
+					pDM_PSTable->CurRFState =3D RF_Normal;
+			} else {
+				if (pDM_Odm->RSSI_Min <=3D Rssi_Low_bound)
+					pDM_PSTable->CurRFState =3D RF_Normal;
+				else
+					pDM_PSTable->CurRFState =3D RF_Save;
+			}
+		} else {
+			pDM_PSTable->CurRFState =3D RF_MAX;
+		}
+	} else {
+		pDM_PSTable->CurRFState =3D RF_Normal;
+	}
+
+	if (pDM_PSTable->PreRFState !=3D pDM_PSTable->CurRFState) {
+		if (pDM_PSTable->CurRFState =3D=3D RF_Save) {
+			/*  <tynli_note> 8723 RSSI report will be wrong. Set 0x874[5]=3D 1 =
when enter BB power saving mode. */
+			/*  Suggested by SD3 Yu-Nan. 2011.01.20. */
+			if (pDM_Odm->SupportICType =3D=3D ODM_RTL8723A)
+				ODM_SetBBReg(pDM_Odm, 0x874, BIT5, 0x1); /* Reg874[5]=3D 1b'1 */
+			ODM_SetBBReg(pDM_Odm, 0x874, 0x1C0000, 0x2); /* Reg874[20:18]=3D 3'=
b010 */
+			ODM_SetBBReg(pDM_Odm, 0xc70, BIT3, 0); /* RegC70[3]=3D 1'b0 */
+			ODM_SetBBReg(pDM_Odm, 0x85c, 0xFF000000, 0x63); /* Reg85C[31:24]=3D=
 0x63 */
+			ODM_SetBBReg(pDM_Odm, 0x874, 0xC000, 0x2); /* Reg874[15:14]=3D 2'b1=
0 */
+			ODM_SetBBReg(pDM_Odm, 0xa74, 0xF000, 0x3); /* RegA75[7:4]=3D 0x3 */
+			ODM_SetBBReg(pDM_Odm, 0x818, BIT28, 0x0); /* Reg818[28]=3D 1'b0 */
+			ODM_SetBBReg(pDM_Odm, 0x818, BIT28, 0x1); /* Reg818[28]=3D 1'b1 */
+		} else {
+			ODM_SetBBReg(pDM_Odm, 0x874, 0x1CC000, pDM_PSTable->Reg874);
+			ODM_SetBBReg(pDM_Odm, 0xc70, BIT3, pDM_PSTable->RegC70);
+			ODM_SetBBReg(pDM_Odm, 0x85c, 0xFF000000, pDM_PSTable->Reg85C);
+			ODM_SetBBReg(pDM_Odm, 0xa74, 0xF000, pDM_PSTable->RegA74);
+			ODM_SetBBReg(pDM_Odm, 0x818, BIT28, 0x0);
+
+			if (pDM_Odm->SupportICType =3D=3D ODM_RTL8723A)
+				ODM_SetBBReg(pDM_Odm, 0x874, BIT5, 0x0); /* Reg874[5]=3D 1b'0 */
+		}
+		pDM_PSTable->PreRFState =3D pDM_PSTable->CurRFState;
+	}
+}
+
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 RATR MASK */
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 Rate Adaptive */
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+
+void odm_RateAdaptiveMaskInit23a(struct dm_odm_t *pDM_Odm)
+{
+	struct odm_rate_adapt *pOdmRA =3D &pDM_Odm->RateAdaptive;
+
+	pOdmRA->Type =3D DM_Type_ByDriver;
+	if (pOdmRA->Type =3D=3D DM_Type_ByDriver)
+		pDM_Odm->bUseRAMask =3D true;
+	else
+		pDM_Odm->bUseRAMask =3D false;
+
+	pOdmRA->RATRState =3D DM_RATR_STA_INIT;
+	pOdmRA->HighRSSIThresh =3D 50;
+	pOdmRA->LowRSSIThresh =3D 20;
+}
+
+u32 ODM_Get_Rate_Bitmap23a(struct dm_odm_t *pDM_Odm,
+	u32 macid,
+	u32 ra_mask,
+	u8 rssi_level)
+{
+	struct sta_info *pEntry;
+	u32 rate_bitmap =3D 0x0fffffff;
+	u8 WirelessMode;
+	/* u8 WirelessMode =3D*(pDM_Odm->pWirelessMode); */
+
+	pEntry =3D pDM_Odm->pODM_StaInfo[macid];
+	if (!IS_STA_VALID(pEntry))
+		return ra_mask;
+
+	WirelessMode =3D pEntry->wireless_mode;
+
+	switch (WirelessMode) {
+	case ODM_WM_B:
+		if (ra_mask & 0x0000000c)		/* 11M or 5.5M enable */
+			rate_bitmap =3D 0x0000000d;
+		else
+			rate_bitmap =3D 0x0000000f;
+		break;
+	case (ODM_WM_A|ODM_WM_G):
+		if (rssi_level =3D=3D DM_RATR_STA_HIGH)
+			rate_bitmap =3D 0x00000f00;
+		else
+			rate_bitmap =3D 0x00000ff0;
+		break;
+	case (ODM_WM_B|ODM_WM_G):
+		if (rssi_level =3D=3D DM_RATR_STA_HIGH)
+			rate_bitmap =3D 0x00000f00;
+		else if (rssi_level =3D=3D DM_RATR_STA_MIDDLE)
+			rate_bitmap =3D 0x00000ff0;
+		else
+			rate_bitmap =3D 0x00000ff5;
+		break;
+	case (ODM_WM_B|ODM_WM_G|ODM_WM_N24G):
+	case (ODM_WM_A|ODM_WM_B|ODM_WM_G|ODM_WM_N24G):
+		if (pDM_Odm->RFType =3D=3D ODM_1T2R || pDM_Odm->RFType =3D=3D ODM_1T=
1R) {
+			if (rssi_level =3D=3D DM_RATR_STA_HIGH) {
+				rate_bitmap =3D 0x000f0000;
+			} else if (rssi_level =3D=3D DM_RATR_STA_MIDDLE) {
+				rate_bitmap =3D 0x000ff000;
+			} else {
+				if (*(pDM_Odm->pBandWidth) =3D=3D ODM_BW40M)
+					rate_bitmap =3D 0x000ff015;
+				else
+					rate_bitmap =3D 0x000ff005;
+			}
+		} else {
+			if (rssi_level =3D=3D DM_RATR_STA_HIGH) {
+				rate_bitmap =3D 0x0f8f0000;
+			} else if (rssi_level =3D=3D DM_RATR_STA_MIDDLE) {
+				rate_bitmap =3D 0x0f8ff000;
+			} else {
+				if (*(pDM_Odm->pBandWidth) =3D=3D ODM_BW40M)
+					rate_bitmap =3D 0x0f8ff015;
+				else
+					rate_bitmap =3D 0x0f8ff005;
+			}
+		}
+		break;
+	default:
+		/* case WIRELESS_11_24N: */
+		/* case WIRELESS_11_5N: */
+		if (pDM_Odm->RFType =3D=3D RF_1T2R)
+			rate_bitmap =3D 0x000fffff;
+		else
+			rate_bitmap =3D 0x0fffffff;
+		break;
+	}
+
+	/* printk("%s =3D=3D> rssi_level:0x%02x, WirelessMode:0x%02x, rate_bi=
tmap:0x%08x \n", __FUNCTION__, rssi_level, WirelessMode, rate_bitmap); =
*/
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_RA_MASK, ODM_DBG_LOUD, (" =3D=3D> rssi=
_level:0x%02x, WirelessMode:0x%02x, rate_bitmap:0x%08x \n", rssi_level,=
 WirelessMode, rate_bitmap));
+
+	return rate_bitmap;
+
+}
+
+/*--------------------------------------------------------------------=
---------
+ * Function:	odm_RefreshRateAdaptiveMask23a()
+ *
+ * Overview:	Update rate table mask according to rssi
+ *
+ * Input:		NONE
+ *
+ * Output:		NONE
+ *
+ * Return:		NONE
+ *
+ * Revised History:
+ *When		Who		Remark
+ *05/27/2009	hpfan	Create Version 0.
+ *
+ *--------------------------------------------------------------------=
-------*/
+void odm_RefreshRateAdaptiveMask23a(struct dm_odm_t *pDM_Odm)
+{
+	if (!(pDM_Odm->SupportAbility & ODM_BB_RA_MASK))
+		return;
+	/*  */
+	/*  2011/09/29 MH In HW integration first stage, we provide 4 differe=
nt handle to operate */
+	/*  at the same time. In the stage2/3, we need to prive universal int=
erface and merge all */
+	/*  HW dynamic mechanism. */
+	/*  */
+	odm_RefreshRateAdaptiveMask23aCE23a(pDM_Odm);
+}
+
+void odm_RefreshRateAdaptiveMask23aMP23a(struct dm_odm_t *pDM_Odm)
+{
+}
+
+void odm_RefreshRateAdaptiveMask23aCE23a(struct dm_odm_t *pDM_Odm)
+{
+	u8 i;
+	struct rtw_adapter *pAdapter	 =3D  pDM_Odm->Adapter;
+
+	if (pAdapter->bDriverStopped) {
+		ODM_RT_TRACE(pDM_Odm, ODM_COMP_RA_MASK, ODM_DBG_TRACE,
+			     ("<---- odm_RefreshRateAdaptiveMask23a(): driver is going to u=
nload\n"));
+		return;
+	}
+
+	if (!pDM_Odm->bUseRAMask) {
+		ODM_RT_TRACE(pDM_Odm, ODM_COMP_RA_MASK, ODM_DBG_LOUD,
+			     ("<---- odm_RefreshRateAdaptiveMask23a(): driver does not cont=
rol rate adaptive mask\n"));
+		return;
+	}
+
+	/* printk("=3D=3D> %s \n", __FUNCTION__); */
+
+	for (i =3D 0; i < ODM_ASSOCIATE_ENTRY_NUM; i++) {
+		struct sta_info *pstat =3D pDM_Odm->pODM_StaInfo[i];
+		if (IS_STA_VALID(pstat)) {
+			if (ODM_RAStateCheck23a(pDM_Odm, pstat->rssi_stat.UndecoratedSmooth=
edPWDB, false, &pstat->rssi_level)) {
+				ODM_RT_TRACE(pDM_Odm, ODM_COMP_RA_MASK, ODM_DBG_LOUD,
+					     ("RSSI:%d, RSSI_LEVEL:%d\n",
+					     pstat->rssi_stat.UndecoratedSmoothedPWDB,
+					     pstat->rssi_level));
+				rtw_hal_update_ra_mask23a(pstat, pstat->rssi_level);
+			}
+
+		}
+	}
+
+}
+
+void odm_RefreshRateAdaptiveMask23aAPADSL23a(struct dm_odm_t *pDM_Odm)
+{
+}
+
+/*  Return Value: bool */
+/*  - true: RATRState is changed. */
+bool ODM_RAStateCheck23a(struct dm_odm_t *pDM_Odm, s32 RSSI, bool bFor=
ceUpdate,
+			 u8 *pRATRState)
+{
+	struct odm_rate_adapt *pRA =3D &pDM_Odm->RateAdaptive;
+	const u8 GoUpGap =3D 5;
+	u8 HighRSSIThreshForRA =3D pRA->HighRSSIThresh;
+	u8 LowRSSIThreshForRA =3D pRA->LowRSSIThresh;
+	u8 RATRState;
+
+	/*  Threshold Adjustment: */
+	/*  when RSSI state trends to go up one or two levels, make sure RSSI=
 is high enough. */
+	/*  Here GoUpGap is added to solve the boundary's level alternation i=
ssue. */
+	switch (*pRATRState) {
+	case DM_RATR_STA_INIT:
+	case DM_RATR_STA_HIGH:
+		break;
+	case DM_RATR_STA_MIDDLE:
+		HighRSSIThreshForRA +=3D GoUpGap;
+		break;
+	case DM_RATR_STA_LOW:
+		HighRSSIThreshForRA +=3D GoUpGap;
+		LowRSSIThreshForRA +=3D GoUpGap;
+		break;
+	default:
+		ODM_RT_ASSERT(pDM_Odm, false, ("wrong rssi level setting %d !", *pRA=
TRState));
+		break;
+	}
+
+	/*  Decide RATRState by RSSI. */
+	if (RSSI > HighRSSIThreshForRA)
+		RATRState =3D DM_RATR_STA_HIGH;
+	else if (RSSI > LowRSSIThreshForRA)
+		RATRState =3D DM_RATR_STA_MIDDLE;
+	else
+		RATRState =3D DM_RATR_STA_LOW;
+
+	if (*pRATRState !=3D RATRState || bForceUpdate) {
+		ODM_RT_TRACE(pDM_Odm, ODM_COMP_RA_MASK, ODM_DBG_LOUD,
+			     ("RSSI Level %d -> %d\n", *pRATRState, RATRState));
+		*pRATRState =3D RATRState;
+		return true;
+	}
+	return false;
+}
+
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 Dynamic Tx Power */
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+
+void odm_DynamicTxPower23aInit(struct dm_odm_t *pDM_Odm)
+{
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct dm_priv *pdmpriv =3D &pHalData->dmpriv;
+
+	pdmpriv->bDynamicTxPowerEnable =3D false;
+
+	pdmpriv->LastDTPLvl =3D TxHighPwrLevel_Normal;
+	pdmpriv->DynamicTxHighPowerLvl =3D TxHighPwrLevel_Normal;
+}
+
+void odm_DynamicTxPower23aSavePowerIndex(struct dm_odm_t *pDM_Odm)
+{
+	u8 index;
+	u32 Power_Index_REG[6] =3D {0xc90, 0xc91, 0xc92, 0xc98, 0xc99, 0xc9a}=
;
+
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct dm_priv *pdmpriv =3D &pHalData->dmpriv;
+	for (index =3D 0; index < 6; index++)
+		pdmpriv->PowerIndex_backup[index] =3D rtw_read8(Adapter, Power_Index=
_REG[index]);
+}
+
+void odm_DynamicTxPower23aRestorePowerIndex(struct dm_odm_t *pDM_Odm)
+{
+	u8 index;
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	u32 Power_Index_REG[6] =3D {0xc90, 0xc91, 0xc92, 0xc98, 0xc99, 0xc9a}=
;
+	struct dm_priv *pdmpriv =3D &pHalData->dmpriv;
+	for (index =3D 0; index < 6; index++)
+		rtw_write8(Adapter, Power_Index_REG[index], pdmpriv->PowerIndex_back=
up[index]);
+}
+
+void odm_DynamicTxPower23aWritePowerIndex(struct dm_odm_t *pDM_Odm,
+	u8 Value)
+{
+
+	u8 index;
+	u32 Power_Index_REG[6] =3D {0xc90, 0xc91, 0xc92, 0xc98, 0xc99, 0xc9a}=
;
+
+	for (index =3D 0; index < 6; index++)
+		ODM_Write1Byte(pDM_Odm, Power_Index_REG[index], Value);
+
+}
+
+void odm_DynamicTxPower23a(struct dm_odm_t *pDM_Odm)
+{
+}
+
+void odm_DynamicTxPower23a_92C(struct dm_odm_t *pDM_Odm)
+{
+}
+
+void odm_DynamicTxPower23a_92D(struct dm_odm_t *pDM_Odm)
+{
+}
+
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 RSSI Monitor */
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+
+void odm_RSSIMonitorInit(struct dm_odm_t *pDM_Odm)
+{
+}
+
+void odm_RSSIMonitorCheck23a(struct dm_odm_t *pDM_Odm)
+{
+	/*  For AP/ADSL use struct rtl8723a_priv * */
+	/*  For CE/NIC use struct rtw_adapter * */
+
+	if (!(pDM_Odm->SupportAbility & ODM_BB_RSSI_MONITOR))
+		return;
+
+	/*  2011/09/29 MH In HW integration first stage, we provide 4 differe=
nt handle to operate */
+	/*  at the same time. In the stage2/3, we need to prive universal int=
erface and merge all */
+	/*  HW dynamic mechanism. */
+	odm_RSSIMonitorCheck23aCE(pDM_Odm);
+}	/*  odm_RSSIMonitorCheck23a */
+
+void odm_RSSIMonitorCheck23aMP(struct dm_odm_t *pDM_Odm)
+{
+}
+
+static void
+FindMinimumRSSI(
+	struct rtw_adapter *pAdapter
+	)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(pAdapter);
+	struct dm_priv *pdmpriv =3D &pHalData->dmpriv;
+	struct dm_odm_t *pDM_Odm =3D &pHalData->odmpriv;
+
+	/* 1 1.Determine the minimum RSSI */
+
+	if ((!pDM_Odm->bLinked) &&
+	    (pdmpriv->EntryMinUndecoratedSmoothedPWDB =3D=3D 0))
+		pdmpriv->MinUndecoratedPWDBForDM =3D 0;
+	else
+		pdmpriv->MinUndecoratedPWDBForDM =3D pdmpriv->EntryMinUndecoratedSmo=
othedPWDB;
+}
+
+void odm_RSSIMonitorCheck23aCE(struct dm_odm_t *pDM_Odm)
+{
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct dm_priv *pdmpriv =3D &pHalData->dmpriv;
+	int	i;
+	int	tmpEntryMaxPWDB =3D 0, tmpEntryMinPWDB =3D 0xff;
+	u8 sta_cnt =3D 0;
+	u32 PWDB_rssi[NUM_STA] =3D {0};/* 0~15]:MACID, [16~31]:PWDB_rssi */
+	struct sta_info *psta;
+
+	if (!pDM_Odm->bLinked)
+		return;
+
+	for (i =3D 0; i < ODM_ASSOCIATE_ENTRY_NUM; i++) {
+		psta =3D pDM_Odm->pODM_StaInfo[i];
+		if (IS_STA_VALID(psta)) {
+			if (psta->rssi_stat.UndecoratedSmoothedPWDB < tmpEntryMinPWDB)
+				tmpEntryMinPWDB =3D psta->rssi_stat.UndecoratedSmoothedPWDB;
+
+			if (psta->rssi_stat.UndecoratedSmoothedPWDB > tmpEntryMaxPWDB)
+				tmpEntryMaxPWDB =3D psta->rssi_stat.UndecoratedSmoothedPWDB;
+
+			if (psta->rssi_stat.UndecoratedSmoothedPWDB !=3D (-1))
+				PWDB_rssi[sta_cnt++] =3D (psta->mac_id | (psta->rssi_stat.Undecora=
tedSmoothedPWDB<<16));
+		}
+	}
+
+	for (i =3D 0; i < sta_cnt; i++) {
+		if (PWDB_rssi[i] !=3D (0)) {
+			if (pHalData->fw_ractrl) /*  Report every sta's RSSI to FW */
+				rtl8723a_set_rssi_cmd(Adapter, (u8 *)&PWDB_rssi[i]);
+		}
+	}
+
+	if (tmpEntryMaxPWDB !=3D 0)	/*  If associated entry is found */
+		pdmpriv->EntryMaxUndecoratedSmoothedPWDB =3D tmpEntryMaxPWDB;
+	else
+		pdmpriv->EntryMaxUndecoratedSmoothedPWDB =3D 0;
+
+	if (tmpEntryMinPWDB !=3D 0xff) /*  If associated entry is found */
+		pdmpriv->EntryMinUndecoratedSmoothedPWDB =3D tmpEntryMinPWDB;
+	else
+		pdmpriv->EntryMinUndecoratedSmoothedPWDB =3D 0;
+
+	FindMinimumRSSI(Adapter);/* get pdmpriv->MinUndecoratedPWDBForDM */
+
+	ODM_CmnInfoUpdate23a(&pHalData->odmpriv, ODM_CMNINFO_RSSI_MIN, pdmpri=
v->MinUndecoratedPWDBForDM);
+}
+
+void odm_RSSIMonitorCheck23aAP(struct dm_odm_t *pDM_Odm)
+{
+}
+
+void ODM_InitAllTimers(struct dm_odm_t *pDM_Odm)
+{
+	setup_timer(&pDM_Odm->DM_SWAT_Table.SwAntennaSwitchTimer,
+		    odm_SwAntDivChkAntSwitchCallback23a, (unsigned long)pDM_Odm);
+}
+
+void ODM_CancelAllTimers(struct dm_odm_t *pDM_Odm)
+{
+	del_timer_sync(&pDM_Odm->DM_SWAT_Table.SwAntennaSwitchTimer);
+}
+
+void ODM_ReleaseAllTimers(struct dm_odm_t *pDM_Odm)
+{
+	ODM_ReleaseTimer(pDM_Odm, &pDM_Odm->DM_SWAT_Table.SwAntennaSwitchTime=
r);
+}
+
+/* endif */
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 Tx Power Tracking */
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+
+void odm_TXPowerTrackingInit23a(struct dm_odm_t *pDM_Odm)
+{
+	odm_TXPowerTrackingThermalMeterInit23a(pDM_Odm);
+}
+
+void odm_TXPowerTrackingThermalMeterInit23a(struct dm_odm_t *pDM_Odm)
+{
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct dm_priv *pdmpriv =3D &pHalData->dmpriv;
+
+	pdmpriv->bTXPowerTracking =3D true;
+	pdmpriv->TXPowercount =3D 0;
+	pdmpriv->bTXPowerTrackingInit =3D false;
+	pdmpriv->TxPowerTrackControl =3D true;
+	MSG_8723A("pdmpriv->TxPowerTrackControl =3D %d\n", pdmpriv->TxPowerTr=
ackControl);
+
+	pDM_Odm->RFCalibrateInfo.TxPowerTrackControl =3D true;
+}
+
+void ODM_TXPowerTrackingCheck23a(struct dm_odm_t *pDM_Odm)
+{
+	/*  For AP/ADSL use struct rtl8723a_priv * */
+	/*  For CE/NIC use struct rtw_adapter * */
+
+	/*  2011/09/29 MH In HW integration first stage, we provide 4 differe=
nt handle to operate */
+	/*  at the same time. In the stage2/3, we need to prive universal int=
erface and merge all */
+	/*  HW dynamic mechanism. */
+	odm_TXPowerTrackingCheckCE23a(pDM_Odm);
+}
+
+void odm_TXPowerTrackingCheckCE23a(struct dm_odm_t *pDM_Odm)
+{
+}
+
+void odm_TXPowerTrackingCheckMP(struct dm_odm_t *pDM_Odm)
+{
+}
+
+void odm_TXPowerTrackingCheckAP(struct dm_odm_t *pDM_Odm)
+{
+}
+
+/* antenna mapping info */
+/*  1: right-side antenna */
+/*  2/0: left-side antenna */
+/* PpDM_SWAT_Table->CCK_Ant1_Cnt /OFDM_Ant1_Cnt:  for right-side anten=
na:   Ant:1    RxDefaultAnt1 */
+/* PpDM_SWAT_Table->CCK_Ant2_Cnt /OFDM_Ant2_Cnt:  for left-side antenn=
a:     Ant:0    RxDefaultAnt2 */
+/*  We select left antenna as default antenna in initial process, modi=
fy it as needed */
+/*  */
+
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 SW Antenna Diversity */
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+void odm_SwAntDivInit(struct dm_odm_t *pDM_Odm)
+{
+}
+
+void ODM_SwAntDivChkPerPktRssi(struct dm_odm_t *pDM_Odm, u8 StationID,=
 struct odm_phy_info *pPhyInfo)
+{
+}
+
+void odm_SwAntDivChkAntSwitch(struct dm_odm_t *pDM_Odm, u8 Step)
+{
+}
+
+void ODM_SwAntDivRestAfterLink(struct dm_odm_t *pDM_Odm)
+{
+}
+
+void odm_SwAntDivChkAntSwitchCallback23a(unsigned long data)
+{
+}
+
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+/* 3 SW Antenna Diversity */
+/* 3 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+
+void odm_InitHybridAntDiv23a(struct dm_odm_t *pDM_Odm)
+{
+}
+
+void odm_HwAntDiv23a(struct dm_odm_t *pDM_Odm)
+{
+}
+
+/* EDCA Turbo */
+void ODM_EdcaTurboInit23a(struct dm_odm_t *pDM_Odm)
+{
+
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+	pDM_Odm->DM_EDCA_Table.bCurrentTurboEDCA =3D false;
+	pDM_Odm->DM_EDCA_Table.bIsCurRDLState =3D false;
+	Adapter->recvpriv.bIsAnyNonBEPkts =3D false;
+
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_EDCA_TURBO, ODM_DBG_LOUD, ("Orginial V=
O PARAM: 0x%x\n", ODM_Read4Byte(pDM_Odm, ODM_EDCA_VO_PARAM)));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_EDCA_TURBO, ODM_DBG_LOUD, ("Orginial V=
I PARAM: 0x%x\n", ODM_Read4Byte(pDM_Odm, ODM_EDCA_VI_PARAM)));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_EDCA_TURBO, ODM_DBG_LOUD, ("Orginial B=
E PARAM: 0x%x\n", ODM_Read4Byte(pDM_Odm, ODM_EDCA_BE_PARAM)));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_EDCA_TURBO, ODM_DBG_LOUD, ("Orginial B=
K PARAM: 0x%x\n", ODM_Read4Byte(pDM_Odm, ODM_EDCA_BK_PARAM)));
+
+}	/*  ODM_InitEdcaTurbo */
+
+void odm_EdcaTurboCheck23a(struct dm_odm_t *pDM_Odm)
+{
+	/*  For AP/ADSL use struct rtl8723a_priv * */
+	/*  For CE/NIC use struct rtw_adapter * */
+
+	/*  2011/09/29 MH In HW integration first stage, we provide 4 differe=
nt handle to operate */
+	/*  at the same time. In the stage2/3, we need to prive universal int=
erface and merge all */
+	/*  HW dynamic mechanism. */
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_EDCA_TURBO, ODM_DBG_LOUD, ("odm_EdcaTu=
rboCheck23a =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D>\n"));
+
+	if (!(pDM_Odm->SupportAbility & ODM_MAC_EDCA_TURBO))
+		return;
+
+	odm_EdcaTurboCheck23aCE23a(pDM_Odm);
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_EDCA_TURBO, ODM_DBG_LOUD, ("<=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D odm_Edc=
aTurboCheck23a\n"));
+
+}	/*  odm_CheckEdcaTurbo */
+
+void odm_EdcaTurboCheck23aCE23a(struct dm_odm_t *pDM_Odm)
+{
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+
+	u32 trafficIndex;
+	u32 edca_param;
+	u64 cur_tx_bytes =3D 0;
+	u64 cur_rx_bytes =3D 0;
+	u8 bbtchange =3D false;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct xmit_priv *pxmitpriv =3D &Adapter->xmitpriv;
+	struct recv_priv *precvpriv =3D &Adapter->recvpriv;
+	struct registry_priv *pregpriv =3D &Adapter->registrypriv;
+	struct mlme_ext_priv *pmlmeext =3D &Adapter->mlmeextpriv;
+	struct mlme_ext_info *pmlmeinfo =3D &pmlmeext->mlmext_info;
+
+	if ((pregpriv->wifi_spec =3D=3D 1))/*  (pmlmeinfo->HT_enable =3D=3D 0=
)) */
+		goto dm_CheckEdcaTurbo_EXIT;
+
+	if (pmlmeinfo->assoc_AP_vendor >=3D  HT_IOT_PEER_MAX)
+		goto dm_CheckEdcaTurbo_EXIT;
+
+#ifdef CONFIG_8723AU_BT_COEXIST
+	if (BT_DisableEDCATurbo(Adapter))
+		goto dm_CheckEdcaTurbo_EXIT;
+#endif
+
+	/*  Check if the status needs to be changed. */
+	if ((bbtchange) || (!precvpriv->bIsAnyNonBEPkts)) {
+		cur_tx_bytes =3D pxmitpriv->tx_bytes - pxmitpriv->last_tx_bytes;
+		cur_rx_bytes =3D precvpriv->rx_bytes - precvpriv->last_rx_bytes;
+
+		/* traffic, TX or RX */
+		if ((pmlmeinfo->assoc_AP_vendor =3D=3D HT_IOT_PEER_RALINK) ||
+		    (pmlmeinfo->assoc_AP_vendor =3D=3D HT_IOT_PEER_ATHEROS)) {
+			if (cur_tx_bytes > (cur_rx_bytes << 2)) {
+				/*  Uplink TP is present. */
+				trafficIndex =3D UP_LINK;
+			} else { /*  Balance TP is present. */
+				trafficIndex =3D DOWN_LINK;
+			}
+		} else {
+			if (cur_rx_bytes > (cur_tx_bytes << 2)) {
+				/*  Downlink TP is present. */
+				trafficIndex =3D DOWN_LINK;
+			} else { /*  Balance TP is present. */
+				trafficIndex =3D UP_LINK;
+			}
+		}
+
+		if ((pDM_Odm->DM_EDCA_Table.prv_traffic_idx !=3D trafficIndex) ||
+		    (!pDM_Odm->DM_EDCA_Table.bCurrentTurboEDCA)) {
+			if ((pmlmeinfo->assoc_AP_vendor =3D=3D HT_IOT_PEER_CISCO) &&
+			    (pmlmeext->cur_wireless_mode & WIRELESS_11_24N))
+				edca_param =3D EDCAParam[pmlmeinfo->assoc_AP_vendor][trafficIndex]=
;
+			else
+				edca_param =3D EDCAParam[HT_IOT_PEER_UNKNOWN][trafficIndex];
+			rtw_write32(Adapter, REG_EDCA_BE_PARAM, edca_param);
+
+			pDM_Odm->DM_EDCA_Table.prv_traffic_idx =3D trafficIndex;
+		}
+
+		pDM_Odm->DM_EDCA_Table.bCurrentTurboEDCA =3D true;
+	} else {
+		/*  Turn Off EDCA turbo here. */
+		/*  Restore original EDCA according to the declaration of AP. */
+		if (pDM_Odm->DM_EDCA_Table.bCurrentTurboEDCA) {
+			rtw_write32(Adapter, REG_EDCA_BE_PARAM, pHalData->AcParam_BE);
+			pDM_Odm->DM_EDCA_Table.bCurrentTurboEDCA =3D false;
+		}
+	}
+
+dm_CheckEdcaTurbo_EXIT:
+	/*  Set variables for next time. */
+	precvpriv->bIsAnyNonBEPkts =3D false;
+	pxmitpriv->last_tx_bytes =3D pxmitpriv->tx_bytes;
+	precvpriv->last_rx_bytes =3D precvpriv->rx_bytes;
+}
+
+u32 GetPSDData(struct dm_odm_t *pDM_Odm, unsigned int point, u8 initia=
l_gain_psd)
+{
+	u32 psd_report;
+
+	/* Set DCO frequency index, offset =3D (40MHz/SamplePts)*point */
+	ODM_SetBBReg(pDM_Odm, 0x808, 0x3FF, point);
+
+	/* Start PSD calculation, Reg808[22]=3D 0->1 */
+	ODM_SetBBReg(pDM_Odm, 0x808, BIT22, 1);
+	/* Need to wait for HW PSD report */
+	udelay(30);
+	ODM_SetBBReg(pDM_Odm, 0x808, BIT22, 0);
+	/* Read PSD report, Reg8B4[15:0] */
+	psd_report =3D ODM_GetBBReg(pDM_Odm, 0x8B4, bMaskDWord) & 0x0000FFFF;
+
+	psd_report =3D (u32)(ConvertTo_dB23a(psd_report))+(u32)(initial_gain_=
psd-0x1c);
+
+	return psd_report;
+}
+
+u32
+ConvertTo_dB23a(
+	u32 Value)
+{
+	u8 i;
+	u8 j;
+	u32 dB;
+
+	Value =3D Value & 0xFFFF;
+
+	for (i =3D 0; i < 8; i++) {
+		if (Value <=3D dB_Invert_Table[i][11])
+			break;
+	}
+
+	if (i >=3D 8)
+		return 96;	/*  maximum 96 dB */
+
+	for (j =3D 0; j < 12; j++) {
+		if (Value <=3D dB_Invert_Table[i][j])
+			break;
+	}
+
+	dB =3D i*12 + j + 1;
+
+	return dB;
+}
+
+/*  */
+/*  2011/09/22 MH Add for 92D global spin lock utilization. */
+/*  */
+void
+odm_GlobalAdapterCheck(
+		void
+	)
+{
+}	/*  odm_GlobalAdapterCheck */
+
+/*  */
+/*  Description: */
+/*Set Single/Dual Antenna default setting for products that do not do =
detection in advance. */
+/*  */
+/*  Added by Joseph, 2012.03.22 */
+/*  */
+void ODM_SingleDualAntennaDefaultSetting(struct dm_odm_t *pDM_Odm)
+{
+	struct sw_ant_sw *pDM_SWAT_Table =3D &pDM_Odm->DM_SWAT_Table;
+	pDM_SWAT_Table->ANTA_ON =3D true;
+	pDM_SWAT_Table->ANTB_ON =3D true;
+}
+
+/* 2 8723A ANT DETECT */
+
+static void odm_PHY_SaveAFERegisters(
+	struct dm_odm_t *pDM_Odm,
+	u32 *AFEReg,
+	u32 *AFEBackup,
+	u32 RegisterNum
+	)
+{
+	u32 i;
+
+	/* RTPRINT(FINIT, INIT_IQK, ("Save ADDA parameters.\n")); */
+	for (i =3D 0 ; i < RegisterNum ; i++)
+		AFEBackup[i] =3D ODM_GetBBReg(pDM_Odm, AFEReg[i], bMaskDWord);
+}
+
+static void odm_PHY_ReloadAFERegisters(struct dm_odm_t *pDM_Odm, u32 *=
AFEReg,
+				       u32 *AFEBackup, u32 RegiesterNum)
+{
+	u32 i;
+
+	for (i =3D 0 ; i < RegiesterNum; i++)
+		ODM_SetBBReg(pDM_Odm, AFEReg[i], bMaskDWord, AFEBackup[i]);
+}
+
+/* 2 8723A ANT DETECT */
+/*  Description: */
+/* Implement IQK single tone for RF DPK loopback and BB PSD scanning. =
*/
+/* This function is cooperated with BB team Neil. */
+bool ODM_SingleDualAntennaDetection(struct dm_odm_t *pDM_Odm, u8 mode)
+{
+	struct sw_ant_sw *pDM_SWAT_Table =3D &pDM_Odm->DM_SWAT_Table;
+	u32 CurrentChannel, RfLoopReg;
+	u8 n;
+	u32 Reg88c, Regc08, Reg874, Regc50;
+	u8 initial_gain =3D 0x5a;
+	u32 PSD_report_tmp;
+	u32 AntA_report =3D 0x0, AntB_report =3D 0x0, AntO_report =3D 0x0;
+	bool bResult =3D true;
+	u32 AFE_Backup[16];
+	u32 AFE_REG_8723A[16] =3D {
+		rRx_Wait_CCA, rTx_CCK_RFON,
+		rTx_CCK_BBON, rTx_OFDM_RFON,
+		rTx_OFDM_BBON, rTx_To_Rx,
+		rTx_To_Tx, rRx_CCK,
+		rRx_OFDM, rRx_Wait_RIFS,
+		rRx_TO_Rx, rStandby,
+		rSleep, rPMPD_ANAEN,
+		rFPGA0_XCD_SwitchControl, rBlue_Tooth};
+
+	if (!(pDM_Odm->SupportICType & (ODM_RTL8723A)))
+		return bResult;
+
+	if (!(pDM_Odm->SupportAbility&ODM_BB_ANT_DIV))
+		return bResult;
+	/* 1 Backup Current RF/BB Settings */
+
+	CurrentChannel =3D ODM_GetRFReg(pDM_Odm, RF_PATH_A, ODM_CHANNEL, bRFR=
egOffsetMask);
+	RfLoopReg =3D ODM_GetRFReg(pDM_Odm, RF_PATH_A, 0x00, bRFRegOffsetMask=
);
+	ODM_SetBBReg(pDM_Odm, rFPGA0_XA_RFInterfaceOE, ODM_DPDT, Antenna_A); =
 /*  change to Antenna A */
+	/*  Step 1: USE IQK to transmitter single tone */
+
+	udelay(10);
+
+	/* Store A Path Register 88c, c08, 874, c50 */
+	Reg88c =3D ODM_GetBBReg(pDM_Odm, rFPGA0_AnalogParameter4, bMaskDWord)=
;
+	Regc08 =3D ODM_GetBBReg(pDM_Odm, rOFDM0_TRMuxPar, bMaskDWord);
+	Reg874 =3D ODM_GetBBReg(pDM_Odm, rFPGA0_XCD_RFInterfaceSW, bMaskDWord=
);
+	Regc50 =3D ODM_GetBBReg(pDM_Odm, rOFDM0_XAAGCCore1, bMaskDWord);
+
+	/*  Store AFE Registers */
+	odm_PHY_SaveAFERegisters(pDM_Odm, AFE_REG_8723A, AFE_Backup, 16);
+
+	/* Set PSD 128 pts */
+	ODM_SetBBReg(pDM_Odm, rFPGA0_PSDFunction, BIT14|BIT15, 0x0);  /* 128 =
pts */
+
+	/*  To SET CH1 to do */
+	ODM_SetRFReg(pDM_Odm, RF_PATH_A, ODM_CHANNEL, bRFRegOffsetMask, 0x01)=
;     /* Channel 1 */
+
+	/*  AFE all on step */
+	ODM_SetBBReg(pDM_Odm, rRx_Wait_CCA, bMaskDWord, 0x6FDB25A4);
+	ODM_SetBBReg(pDM_Odm, rTx_CCK_RFON, bMaskDWord, 0x6FDB25A4);
+	ODM_SetBBReg(pDM_Odm, rTx_CCK_BBON, bMaskDWord, 0x6FDB25A4);
+	ODM_SetBBReg(pDM_Odm, rTx_OFDM_RFON, bMaskDWord, 0x6FDB25A4);
+	ODM_SetBBReg(pDM_Odm, rTx_OFDM_BBON, bMaskDWord, 0x6FDB25A4);
+	ODM_SetBBReg(pDM_Odm, rTx_To_Rx, bMaskDWord, 0x6FDB25A4);
+	ODM_SetBBReg(pDM_Odm, rTx_To_Tx, bMaskDWord, 0x6FDB25A4);
+	ODM_SetBBReg(pDM_Odm, rRx_CCK, bMaskDWord, 0x6FDB25A4);
+	ODM_SetBBReg(pDM_Odm, rRx_OFDM, bMaskDWord, 0x6FDB25A4);
+	ODM_SetBBReg(pDM_Odm, rRx_Wait_RIFS, bMaskDWord, 0x6FDB25A4);
+	ODM_SetBBReg(pDM_Odm, rRx_TO_Rx, bMaskDWord, 0x6FDB25A4);
+	ODM_SetBBReg(pDM_Odm, rStandby, bMaskDWord, 0x6FDB25A4);
+	ODM_SetBBReg(pDM_Odm, rSleep, bMaskDWord, 0x6FDB25A4);
+	ODM_SetBBReg(pDM_Odm, rPMPD_ANAEN, bMaskDWord, 0x6FDB25A4);
+	ODM_SetBBReg(pDM_Odm, rFPGA0_XCD_SwitchControl, bMaskDWord, 0x6FDB25A=
4);
+	ODM_SetBBReg(pDM_Odm, rBlue_Tooth, bMaskDWord, 0x6FDB25A4);
+
+	/*  3 wire Disable */
+	ODM_SetBBReg(pDM_Odm, rFPGA0_AnalogParameter4, bMaskDWord, 0xCCF000C0=
);
+
+	/* BB IQK Setting */
+	ODM_SetBBReg(pDM_Odm, rOFDM0_TRMuxPar, bMaskDWord, 0x000800E4);
+	ODM_SetBBReg(pDM_Odm, rFPGA0_XCD_RFInterfaceSW, bMaskDWord, 0x2220800=
0);
+
+	/* IQK setting tone@ 4.34Mhz */
+	ODM_SetBBReg(pDM_Odm, rTx_IQK_Tone_A, bMaskDWord, 0x10008C1C);
+	ODM_SetBBReg(pDM_Odm, rTx_IQK, bMaskDWord, 0x01007c00);
+
+	/* Page B init */
+	ODM_SetBBReg(pDM_Odm, rConfig_AntA, bMaskDWord, 0x00080000);
+	ODM_SetBBReg(pDM_Odm, rConfig_AntA, bMaskDWord, 0x0f600000);
+	ODM_SetBBReg(pDM_Odm, rRx_IQK, bMaskDWord, 0x01004800);
+	ODM_SetBBReg(pDM_Odm, rRx_IQK_Tone_A, bMaskDWord, 0x10008c1f);
+	ODM_SetBBReg(pDM_Odm, rTx_IQK_PI_A, bMaskDWord, 0x82150008);
+	ODM_SetBBReg(pDM_Odm, rRx_IQK_PI_A, bMaskDWord, 0x28150008);
+	ODM_SetBBReg(pDM_Odm, rIQK_AGC_Rsp, bMaskDWord, 0x001028d0);
+
+	/* RF loop Setting */
+	ODM_SetRFReg(pDM_Odm, RF_PATH_A, 0x0, 0xFFFFF, 0x50008);
+
+	/* IQK Single tone start */
+	ODM_SetBBReg(pDM_Odm, rFPGA0_IQK, bMaskDWord, 0x80800000);
+	ODM_SetBBReg(pDM_Odm, rIQK_AGC_Pts, bMaskDWord, 0xf8000000);
+	udelay(1000);
+	PSD_report_tmp =3D 0x0;
+
+	for (n =3D 0; n < 2; n++) {
+		PSD_report_tmp =3D  GetPSDData(pDM_Odm, 14, initial_gain);
+		if (PSD_report_tmp > AntA_report)
+			AntA_report =3D PSD_report_tmp;
+	}
+
+	PSD_report_tmp =3D 0x0;
+
+	ODM_SetBBReg(pDM_Odm, rFPGA0_XA_RFInterfaceOE, 0x300, Antenna_B);  /*=
  change to Antenna B */
+	udelay(10);
+
+	for (n =3D 0; n < 2; n++) {
+		PSD_report_tmp =3D  GetPSDData(pDM_Odm, 14, initial_gain);
+		if (PSD_report_tmp > AntB_report)
+			AntB_report =3D PSD_report_tmp;
+	}
+
+	/*  change to open case */
+	ODM_SetBBReg(pDM_Odm, rFPGA0_XA_RFInterfaceOE, 0x300, 0);  /*  change=
 to Ant A and B all open case */
+	udelay(10);
+
+	for (n =3D 0; n < 2; n++) {
+		PSD_report_tmp =3D  GetPSDData(pDM_Odm, 14, initial_gain);
+		if (PSD_report_tmp > AntO_report)
+			AntO_report =3D PSD_report_tmp;
+	}
+
+	/* Close IQK Single Tone function */
+	ODM_SetBBReg(pDM_Odm, rFPGA0_IQK, bMaskDWord, 0x00000000);
+	PSD_report_tmp =3D 0x0;
+
+	/* 1 Return to antanna A */
+	ODM_SetBBReg(pDM_Odm, rFPGA0_XA_RFInterfaceOE, 0x300, Antenna_A);
+	ODM_SetBBReg(pDM_Odm, rFPGA0_AnalogParameter4, bMaskDWord, Reg88c);
+	ODM_SetBBReg(pDM_Odm, rOFDM0_TRMuxPar, bMaskDWord, Regc08);
+	ODM_SetBBReg(pDM_Odm, rFPGA0_XCD_RFInterfaceSW, bMaskDWord, Reg874);
+	ODM_SetBBReg(pDM_Odm, rOFDM0_XAAGCCore1, 0x7F, 0x40);
+	ODM_SetBBReg(pDM_Odm, rOFDM0_XAAGCCore1, bMaskDWord, Regc50);
+	ODM_SetRFReg(pDM_Odm, RF_PATH_A, RF_CHNLBW, bRFRegOffsetMask, Current=
Channel);
+	ODM_SetRFReg(pDM_Odm, RF_PATH_A, 0x00, bRFRegOffsetMask, RfLoopReg);
+
+	/* Reload AFE Registers */
+	odm_PHY_ReloadAFERegisters(pDM_Odm, AFE_REG_8723A, AFE_Backup, 16);
+
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("psd_report_A[=
%d]=3D %d \n", 2416, AntA_report));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("psd_report_B[=
%d]=3D %d \n", 2416, AntB_report));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("psd_report_O[=
%d]=3D %d \n", 2416, AntO_report));
+
+	/* 2 Test Ant B based on Ant A is ON */
+	if (mode =3D=3D ANTTESTB) {
+		if (AntA_report >=3D 100) {
+			if (AntB_report > (AntA_report+1)) {
+				pDM_SWAT_Table->ANTB_ON =3D false;
+				ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("ODM_Single=
DualAntennaDetection(): Single Antenna A\n"));
+			} else {
+				pDM_SWAT_Table->ANTB_ON =3D true;
+				ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("ODM_Single=
DualAntennaDetection(): Dual Antenna is A and B\n"));
+			}
+		} else {
+			ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("ODM_SingleD=
ualAntennaDetection(): Need to check again\n"));
+			pDM_SWAT_Table->ANTB_ON =3D false; /*  Set Antenna B off as default=
 */
+			bResult =3D false;
+		}
+	} else if (mode =3D=3D ANTTESTALL) {
+		/* 2 Test Ant A and B based on DPDT Open */
+		if ((AntO_report >=3D 100) & (AntO_report < 118)) {
+			if (AntA_report > (AntO_report+1)) {
+				pDM_SWAT_Table->ANTA_ON =3D false;
+				ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("Ant A is O=
=46F"));
+			} else {
+				pDM_SWAT_Table->ANTA_ON =3D true;
+				ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("Ant A is O=
N"));
+			}
+
+			if (AntB_report > (AntO_report+2)) {
+				pDM_SWAT_Table->ANTB_ON =3D false;
+				ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("Ant B is O=
=46F"));
+			} else {
+				pDM_SWAT_Table->ANTB_ON =3D true;
+				ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("Ant B is O=
N"));
+			}
+		}
+	} else {
+		ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("ODM_SingleDu=
alAntennaDetection(): Need to check again\n"));
+		pDM_SWAT_Table->ANTA_ON =3D true; /*  Set Antenna A on as default */
+		pDM_SWAT_Table->ANTB_ON =3D false; /*  Set Antenna B off as default =
*/
+		bResult =3D false;
+	}
+	return bResult;
+}
+
+/* Justin: According to the current RRSI to adjust Response Frame TX p=
ower, 2012/11/05 */
+void odm_dtc(struct dm_odm_t *pDM_Odm)
+{
+}
diff --git a/drivers/staging/rtl8723au/hal/odm_HWConfig.c b/drivers/sta=
ging/rtl8723au/hal/odm_HWConfig.c
new file mode 100644
index 0000000..7244170
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/odm_HWConfig.c
@@ -0,0 +1,481 @@
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
+/*  */
+/*  include files */
+/*  */
+
+#include "odm_precomp.h"
+
+#define READ_AND_CONFIG     READ_AND_CONFIG_MP
+
+#define READ_AND_CONFIG_MP(ic, txt) (ODM_ReadAndConfig##txt##ic(pDM_Od=
m))
+#define READ_AND_CONFIG_TC(ic, txt) (ODM_ReadAndConfig_TC##txt##ic(pDM=
_Odm))
+
+static u8 odm_QueryRxPwrPercentage(s8 AntPower)
+{
+	if ((AntPower <=3D -100) || (AntPower >=3D 20))
+		return	0;
+	else if (AntPower >=3D 0)
+		return	100;
+	else
+		return	100 + AntPower;
+}
+
+static s32 odm_SignalScaleMapping_92CSeries(struct dm_odm_t *pDM_Odm, =
s32 CurrSig)
+{
+	s32 RetSig =3D 0;
+
+	if ((pDM_Odm->SupportInterface  =3D=3D ODM_ITRF_USB) || (pDM_Odm->Sup=
portInterface  =3D=3D ODM_ITRF_SDIO)) {
+		if (CurrSig >=3D 51 && CurrSig <=3D 100)
+			RetSig =3D 100;
+		else if (CurrSig >=3D 41 && CurrSig <=3D 50)
+			RetSig =3D 80 + ((CurrSig - 40)*2);
+		else if (CurrSig >=3D 31 && CurrSig <=3D 40)
+			RetSig =3D 66 + (CurrSig - 30);
+		else if (CurrSig >=3D 21 && CurrSig <=3D 30)
+			RetSig =3D 54 + (CurrSig - 20);
+		else if (CurrSig >=3D 10 && CurrSig <=3D 20)
+			RetSig =3D 42 + (((CurrSig - 10) * 2) / 3);
+		else if (CurrSig >=3D 5 && CurrSig <=3D 9)
+			RetSig =3D 22 + (((CurrSig - 5) * 3) / 2);
+		else if (CurrSig >=3D 1 && CurrSig <=3D 4)
+			RetSig =3D 6 + (((CurrSig - 1) * 3) / 2);
+		else
+			RetSig =3D CurrSig;
+	}
+	return RetSig;
+}
+
+static s32 odm_SignalScaleMapping(struct dm_odm_t *pDM_Odm, s32 CurrSi=
g)
+{
+	return odm_SignalScaleMapping_92CSeries(pDM_Odm, CurrSig);
+}
+
+static u8
+odm_EVMdbToPercentage(
+	s8 Value
+  )
+{
+	/*  */
+	/*  -33dB~0dB to 0%~99% */
+	/*  */
+	s8 ret_val;
+
+	ret_val =3D Value;
+
+	if (ret_val >=3D 0)
+		ret_val =3D 0;
+	if (ret_val <=3D -33)
+		ret_val =3D -33;
+
+	ret_val =3D 0 - ret_val;
+	ret_val *=3D 3;
+
+	if (ret_val =3D=3D 99)
+		ret_val =3D 100;
+
+	return ret_val;
+}
+
+static void odm_RxPhyStatus92CSeries_Parsing(struct dm_odm_t *pDM_Odm,
+					     struct odm_phy_info *pPhyInfo,
+					     u8 *pPhyStatus,
+					     struct odm_packet_info *pPktinfo)
+{
+	struct phy_status_rpt *pPhyStaRpt =3D (struct phy_status_rpt *)pPhySt=
atus;
+	u8 i, Max_spatial_stream;
+	s8 rx_pwr[4], rx_pwr_all =3D 0;
+	u8 EVM, PWDB_ALL =3D 0, PWDB_ALL_BT;
+	u8 RSSI, total_rssi =3D 0;
+	u8 isCCKrate =3D 0;
+	u8 rf_rx_num =3D 0;
+	u8 cck_highpwr =3D 0;
+
+	isCCKrate =3D (pPktinfo->Rate <=3D DESC92C_RATE11M) ? true : false;
+	pPhyInfo->RxMIMOSignalQuality[RF_PATH_A] =3D -1;
+	pPhyInfo->RxMIMOSignalQuality[RF_PATH_B] =3D -1;
+
+	if (isCCKrate) {
+		u8 report;
+		u8 cck_agc_rpt;
+
+		pDM_Odm->PhyDbgInfo.NumQryPhyStatusCCK++;
+		/*  (1)Hardware does not provide RSSI for CCK */
+		/*  (2)PWDB, Average PWDB cacluated by hardware (for rate adaptive) =
*/
+
+		cck_highpwr =3D pDM_Odm->bCckHighPower;
+
+		cck_agc_rpt =3D  pPhyStaRpt->cck_agc_rpt_ofdm_cfosho_a ;
+
+		/* The RSSI formula should be modified according to the gain table *=
/
+		if (!cck_highpwr) {
+			report =3D (cck_agc_rpt & 0xc0)>>6;
+			switch (report) {
+			/*  Modify the RF RNA gain value to -40, -20, -2, 14 by Jenyu's sug=
gestion */
+			/*  Note: different RF with the different RNA gain. */
+			case 0x3:
+				rx_pwr_all =3D -46 - (cck_agc_rpt & 0x3e);
+				break;
+			case 0x2:
+				rx_pwr_all =3D -26 - (cck_agc_rpt & 0x3e);
+				break;
+			case 0x1:
+				rx_pwr_all =3D -12 - (cck_agc_rpt & 0x3e);
+				break;
+			case 0x0:
+				rx_pwr_all =3D 16 - (cck_agc_rpt & 0x3e);
+				break;
+			}
+		} else {
+			report =3D (cck_agc_rpt & 0x60)>>5;
+			switch (report) {
+			case 0x3:
+				rx_pwr_all =3D -46 - ((cck_agc_rpt & 0x1f)<<1) ;
+				break;
+			case 0x2:
+				rx_pwr_all =3D -26 - ((cck_agc_rpt & 0x1f)<<1);
+				break;
+			case 0x1:
+				rx_pwr_all =3D -12 - ((cck_agc_rpt & 0x1f)<<1) ;
+				break;
+			case 0x0:
+				rx_pwr_all =3D 16 - ((cck_agc_rpt & 0x1f)<<1) ;
+				break;
+			}
+		}
+
+		PWDB_ALL =3D odm_QueryRxPwrPercentage(rx_pwr_all);
+
+		/* Modification for ext-LNA board */
+		if (pDM_Odm->BoardType =3D=3D ODM_BOARD_HIGHPWR) {
+			if ((cck_agc_rpt>>7) =3D=3D 0) {
+				PWDB_ALL =3D (PWDB_ALL > 94) ? 100 : (PWDB_ALL+6);
+			} else {
+				if (PWDB_ALL > 38)
+					PWDB_ALL -=3D 16;
+				else
+					PWDB_ALL =3D (PWDB_ALL <=3D 16) ? (PWDB_ALL>>2) : (PWDB_ALL-12);
+			}
+
+			/* CCK modification */
+			if (PWDB_ALL > 25 && PWDB_ALL <=3D 60)
+				PWDB_ALL +=3D 6;
+		} else { /* Modification for int-LNA board */
+			if (PWDB_ALL > 99)
+				PWDB_ALL -=3D 8;
+			else if (PWDB_ALL > 50 && PWDB_ALL <=3D 68)
+				PWDB_ALL +=3D 4;
+		}
+		pPhyInfo->RxPWDBAll =3D PWDB_ALL;
+		pPhyInfo->BTRxRSSIPercentage =3D PWDB_ALL;
+		pPhyInfo->RecvSignalPower =3D rx_pwr_all;
+		/*  (3) Get Signal Quality (EVM) */
+		if (pPktinfo->bPacketMatchBSSID) {
+			u8	SQ, SQ_rpt;
+
+			SQ_rpt =3D pPhyStaRpt->cck_sig_qual_ofdm_pwdb_all;
+
+			if (SQ_rpt > 64)
+				SQ =3D 0;
+			else if (SQ_rpt < 20)
+				SQ =3D 100;
+			else
+				SQ =3D ((64-SQ_rpt) * 100) / 44;
+
+			pPhyInfo->SignalQuality =3D SQ;
+			pPhyInfo->RxMIMOSignalQuality[RF_PATH_A] =3D SQ;
+			pPhyInfo->RxMIMOSignalQuality[RF_PATH_B] =3D -1;
+		}
+	} else { /* is OFDM rate */
+		pDM_Odm->PhyDbgInfo.NumQryPhyStatusOFDM++;
+
+		/*  (1)Get RSSI for HT rate */
+
+		for (i =3D RF_PATH_A; i < RF_PATH_MAX; i++) {
+			/*  2008/01/30 MH we will judge RF RX path now. */
+			if (pDM_Odm->RFPathRxEnable & BIT(i))
+				rf_rx_num++;
+
+			rx_pwr[i] =3D ((pPhyStaRpt->path_agc[i].gain & 0x3F)*2) - 110;
+
+			pPhyInfo->RxPwr[i] =3D rx_pwr[i];
+
+			/* Translate DBM to percentage. */
+			RSSI =3D odm_QueryRxPwrPercentage(rx_pwr[i]);
+			total_rssi +=3D RSSI;
+
+			/* Modification for ext-LNA board */
+			if (pDM_Odm->BoardType =3D=3D ODM_BOARD_HIGHPWR) {
+				if ((pPhyStaRpt->path_agc[i].trsw) =3D=3D 1)
+					RSSI =3D (RSSI > 94) ? 100 : (RSSI+6);
+				else
+					RSSI =3D (RSSI <=3D 16) ? (RSSI>>3) : (RSSI-16);
+
+				if ((RSSI <=3D 34) && (RSSI >=3D 4))
+					RSSI -=3D 4;
+			}
+
+			pPhyInfo->RxMIMOSignalStrength[i] =3D (u8) RSSI;
+
+			/* Get Rx snr value in DB */
+			pPhyInfo->RxSNR[i] =3D pDM_Odm->PhyDbgInfo.RxSNRdB[i] =3D (s32)(pPh=
yStaRpt->path_rxsnr[i]/2);
+		}
+
+		/*  (2)PWDB, Average PWDB cacluated by hardware (for rate adaptive) =
*/
+		rx_pwr_all =3D (((pPhyStaRpt->cck_sig_qual_ofdm_pwdb_all) >> 1) & 0x=
7f)-110;
+
+		PWDB_ALL =3D odm_QueryRxPwrPercentage(rx_pwr_all);
+		PWDB_ALL_BT =3D PWDB_ALL;
+
+		pPhyInfo->RxPWDBAll =3D PWDB_ALL;
+		pPhyInfo->BTRxRSSIPercentage =3D PWDB_ALL_BT;
+		pPhyInfo->RxPower =3D rx_pwr_all;
+		pPhyInfo->RecvSignalPower =3D rx_pwr_all;
+
+		/*  (3)EVM of HT rate */
+		if (pPktinfo->Rate >=3D DESC92C_RATEMCS8 && pPktinfo->Rate <=3D DESC=
92C_RATEMCS15)
+			Max_spatial_stream =3D 2; /* both spatial stream make sense */
+		else
+			Max_spatial_stream =3D 1; /* only spatial stream 1 makes sense */
+
+		for (i =3D 0; i < Max_spatial_stream; i++) {
+			/*  Do not use shift operation like "rx_evmX >>=3D 1" because the c=
ompilor of free build environment */
+			/*  fill most significant bit to "zero" when doing shifting operati=
on which may change a negative */
+			/*  value to positive one, then the dbm value (which is supposed to=
 be negative)  is not correct anymore. */
+			EVM =3D odm_EVMdbToPercentage((pPhyStaRpt->stream_rxevm[i]));	/* db=
m */
+
+			if (pPktinfo->bPacketMatchBSSID) {
+				if (i =3D=3D RF_PATH_A) {
+					/*  Fill value in RFD, Get the first spatial stream only */
+					pPhyInfo->SignalQuality =3D (u8)(EVM & 0xff);
+				}
+				pPhyInfo->RxMIMOSignalQuality[i] =3D (u8)(EVM & 0xff);
+			}
+		}
+	}
+	/* UI BSS List signal strength(in percentage), make it good looking, =
from 0~100. */
+	/* It is assigned to the BSS List in GetValueFromBeaconOrProbeRsp(). =
*/
+	if (isCCKrate) {
+		pPhyInfo->SignalStrength =3D (u8)(odm_SignalScaleMapping(pDM_Odm, PW=
DB_ALL));/* PWDB_ALL; */
+	} else {
+		if (rf_rx_num !=3D 0)
+			pPhyInfo->SignalStrength =3D (u8)(odm_SignalScaleMapping(pDM_Odm, t=
otal_rssi /=3D rf_rx_num));
+	}
+}
+
+void odm_Init_RSSIForDM23a(struct dm_odm_t *pDM_Odm)
+{
+}
+
+static void odm_Process_RSSIForDM(struct dm_odm_t *pDM_Odm,
+				  struct odm_phy_info *pPhyInfo,
+				  struct odm_packet_info *pPktinfo)
+{
+	s32 UndecoratedSmoothedPWDB, UndecoratedSmoothedCCK;
+	s32 UndecoratedSmoothedOFDM, RSSI_Ave;
+	u8 isCCKrate =3D 0;
+	u8 RSSI_max, RSSI_min, i;
+	u32 OFDM_pkt =3D 0;
+	u32 Weighting =3D 0;
+	struct sta_info *pEntry;
+
+	if (pPktinfo->StationID =3D=3D 0xFF)
+		return;
+
+	pEntry =3D pDM_Odm->pODM_StaInfo[pPktinfo->StationID];
+	if (!IS_STA_VALID(pEntry))
+		return;
+	if ((!pPktinfo->bPacketMatchBSSID))
+		return;
+
+	isCCKrate =3D (pPktinfo->Rate <=3D DESC92C_RATE11M) ? true : false;
+
+	/* Smart Antenna Debug Message------------------*/
+
+	UndecoratedSmoothedCCK =3D  pEntry->rssi_stat.UndecoratedSmoothedCCK;
+	UndecoratedSmoothedOFDM =3D pEntry->rssi_stat.UndecoratedSmoothedOFDM=
;
+	UndecoratedSmoothedPWDB =3D pEntry->rssi_stat.UndecoratedSmoothedPWDB=
;
+
+	if (pPktinfo->bPacketToSelf || pPktinfo->bPacketBeacon) {
+		if (!isCCKrate) { /* ofdm rate */
+			if (pPhyInfo->RxMIMOSignalStrength[RF_PATH_B] =3D=3D 0) {
+				RSSI_Ave =3D pPhyInfo->RxMIMOSignalStrength[RF_PATH_A];
+			} else {
+				if (pPhyInfo->RxMIMOSignalStrength[RF_PATH_A] > pPhyInfo->RxMIMOSi=
gnalStrength[RF_PATH_B]) {
+					RSSI_max =3D pPhyInfo->RxMIMOSignalStrength[RF_PATH_A];
+					RSSI_min =3D pPhyInfo->RxMIMOSignalStrength[RF_PATH_B];
+				} else {
+					RSSI_max =3D pPhyInfo->RxMIMOSignalStrength[RF_PATH_B];
+					RSSI_min =3D pPhyInfo->RxMIMOSignalStrength[RF_PATH_A];
+				}
+				if ((RSSI_max - RSSI_min) < 3)
+					RSSI_Ave =3D RSSI_max;
+				else if ((RSSI_max - RSSI_min) < 6)
+					RSSI_Ave =3D RSSI_max - 1;
+				else if ((RSSI_max - RSSI_min) < 10)
+					RSSI_Ave =3D RSSI_max - 2;
+				else
+					RSSI_Ave =3D RSSI_max - 3;
+			}
+
+			/* 1 Process OFDM RSSI */
+			if (UndecoratedSmoothedOFDM <=3D 0) {
+				/*  initialize */
+				UndecoratedSmoothedOFDM =3D pPhyInfo->RxPWDBAll;
+			} else {
+				if (pPhyInfo->RxPWDBAll > (u32)UndecoratedSmoothedOFDM) {
+					UndecoratedSmoothedOFDM =3D
+							(((UndecoratedSmoothedOFDM)*(Rx_Smooth_Factor-1)) +
+							(RSSI_Ave)) / (Rx_Smooth_Factor);
+					UndecoratedSmoothedOFDM =3D UndecoratedSmoothedOFDM + 1;
+				} else {
+					UndecoratedSmoothedOFDM =3D
+							(((UndecoratedSmoothedOFDM)*(Rx_Smooth_Factor-1)) +
+							(RSSI_Ave)) / (Rx_Smooth_Factor);
+				}
+			}
+			pEntry->rssi_stat.PacketMap =3D (pEntry->rssi_stat.PacketMap<<1) | =
BIT0;
+		} else {
+			RSSI_Ave =3D pPhyInfo->RxPWDBAll;
+
+			/* 1 Process CCK RSSI */
+			if (UndecoratedSmoothedCCK <=3D 0) {
+				/*  initialize */
+				UndecoratedSmoothedCCK =3D pPhyInfo->RxPWDBAll;
+			} else {
+				if (pPhyInfo->RxPWDBAll > (u32)UndecoratedSmoothedCCK) {
+					UndecoratedSmoothedCCK =3D
+							(((UndecoratedSmoothedCCK)*(Rx_Smooth_Factor-1)) +
+							(pPhyInfo->RxPWDBAll)) / (Rx_Smooth_Factor);
+					UndecoratedSmoothedCCK =3D UndecoratedSmoothedCCK + 1;
+				} else {
+					UndecoratedSmoothedCCK =3D
+							(((UndecoratedSmoothedCCK)*(Rx_Smooth_Factor-1)) +
+							(pPhyInfo->RxPWDBAll)) / (Rx_Smooth_Factor);
+				}
+			}
+			pEntry->rssi_stat.PacketMap =3D pEntry->rssi_stat.PacketMap<<1;
+		}
+
+		/* 2011.07.28 LukeLee: modified to prevent unstable CCK RSSI */
+		if (pEntry->rssi_stat.ValidBit >=3D 64)
+			pEntry->rssi_stat.ValidBit =3D 64;
+		else
+			pEntry->rssi_stat.ValidBit++;
+
+		for (i =3D 0; i < pEntry->rssi_stat.ValidBit; i++)
+			OFDM_pkt +=3D (u8)(pEntry->rssi_stat.PacketMap>>i)&BIT0;
+
+		if (pEntry->rssi_stat.ValidBit =3D=3D 64) {
+			Weighting =3D ((OFDM_pkt<<4) > 64)?64:(OFDM_pkt<<4);
+			UndecoratedSmoothedPWDB =3D (Weighting*UndecoratedSmoothedOFDM+(64-=
Weighting)*UndecoratedSmoothedCCK)>>6;
+		} else {
+			if (pEntry->rssi_stat.ValidBit !=3D 0)
+				UndecoratedSmoothedPWDB =3D (OFDM_pkt*UndecoratedSmoothedOFDM+(pEn=
try->rssi_stat.ValidBit-OFDM_pkt)*UndecoratedSmoothedCCK)/pEntry->rssi_=
stat.ValidBit;
+			else
+				UndecoratedSmoothedPWDB =3D 0;
+		}
+		pEntry->rssi_stat.UndecoratedSmoothedCCK =3D UndecoratedSmoothedCCK;
+		pEntry->rssi_stat.UndecoratedSmoothedOFDM =3D UndecoratedSmoothedOFD=
M;
+		pEntry->rssi_stat.UndecoratedSmoothedPWDB =3D UndecoratedSmoothedPWD=
B;
+	}
+}
+
+/*  Endianness before calling this API */
+static void ODM_PhyStatusQuery23a_92CSeries(struct dm_odm_t *pDM_Odm,
+					 struct odm_phy_info *pPhyInfo,
+					 u8 *pPhyStatus,
+					 struct odm_packet_info *pPktinfo)
+{
+	odm_RxPhyStatus92CSeries_Parsing(pDM_Odm, pPhyInfo,
+					 pPhyStatus, pPktinfo);
+	if (pDM_Odm->RSSI_test) {
+		/*  Select the packets to do RSSI checking for antenna switching. */
+		if (pPktinfo->bPacketToSelf || pPktinfo->bPacketBeacon)
+			ODM_SwAntDivChkPerPktRssi(pDM_Odm, pPktinfo->StationID, pPhyInfo);
+	} else {
+		odm_Process_RSSIForDM(pDM_Odm, pPhyInfo, pPktinfo);
+	}
+}
+
+void ODM_PhyStatusQuery23a(struct dm_odm_t *pDM_Odm, struct odm_phy_in=
fo *pPhyInfo,
+			   u8 *pPhyStatus, struct odm_packet_info *pPktinfo)
+{
+	ODM_PhyStatusQuery23a_92CSeries(pDM_Odm, pPhyInfo, pPhyStatus, pPktin=
fo);
+}
+
+/*  For future use. */
+void ODM_MacStatusQuery23a(struct dm_odm_t *pDM_Odm, u8 *pMacStatus, u=
8 MacID,
+			bool bPacketMatchBSSID, bool bPacketToSelf,
+			bool bPacketBeacon)
+{
+	/*  2011/10/19 Driver team will handle in the future. */
+
+}
+
+enum hal_status
+ODM_ConfigRFWithHeaderFile23a(
+	struct dm_odm_t *pDM_Odm,
+	enum RF_RADIO_PATH	Content,
+	enum RF_RADIO_PATH	eRFPath
+  )
+{
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_LOUD,
+		     ("=3D=3D=3D>ODM_ConfigRFWithHeaderFile23a\n"));
+	if (pDM_Odm->SupportICType =3D=3D ODM_RTL8723A) {
+		if (eRFPath =3D=3D RF_PATH_A)
+			READ_AND_CONFIG_MP(8723A, _RadioA_1T_);
+
+		ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_LOUD,
+			     (" =3D=3D=3D> ODM_ConfigRFWithHeaderFile23a() Radio_A:Rtl8723R=
adioA_1TArray\n"));
+		ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_LOUD,
+			     (" =3D=3D=3D> ODM_ConfigRFWithHeaderFile23a() Radio_B:Rtl8723R=
adioB_1TArray\n"));
+	}
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_TRACE,
+		     ("ODM_ConfigRFWithHeaderFile23a: Radio No %x\n", eRFPath));
+	return HAL_STATUS_SUCCESS;
+}
+
+enum hal_status
+ODM_ConfigBBWithHeaderFile23a(
+	struct dm_odm_t *pDM_Odm,
+	enum odm_bb_config_type		ConfigType
+	)
+{
+	if (pDM_Odm->SupportICType =3D=3D ODM_RTL8723A) {
+		if (ConfigType =3D=3D CONFIG_BB_PHY_REG)
+			READ_AND_CONFIG_MP(8723A, _PHY_REG_1T_);
+		else if (ConfigType =3D=3D CONFIG_BB_AGC_TAB)
+			READ_AND_CONFIG_MP(8723A, _AGC_TAB_1T_);
+		ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_LOUD,
+			     (" =3D=3D=3D> phy_ConfigBBWithHeaderFile() phy:Rtl8723AGCTAB_1=
TArray\n"));
+		ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_LOUD,
+			     (" =3D=3D=3D> phy_ConfigBBWithHeaderFile() agc:Rtl8723PHY_REG_=
1TArray\n"));
+	}
+	return HAL_STATUS_SUCCESS;
+}
+
+enum hal_status
+ODM_ConfigMACWithHeaderFile23a(
+	struct dm_odm_t *pDM_Odm
+	)
+{
+	u8 result =3D HAL_STATUS_SUCCESS;
+
+	if (pDM_Odm->SupportICType =3D=3D ODM_RTL8723A)
+		READ_AND_CONFIG_MP(8723A, _MAC_REG_);
+	return result;
+}
diff --git a/drivers/staging/rtl8723au/hal/odm_RegConfig8723A.c b/drive=
rs/staging/rtl8723au/hal/odm_RegConfig8723A.c
new file mode 100644
index 0000000..d076e14
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/odm_RegConfig8723A.c
@@ -0,0 +1,162 @@
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
+#include "odm_precomp.h"
+
+void
+odm_ConfigRFReg_8723A(
+	struct dm_odm_t *pDM_Odm,
+	u32					Addr,
+	u32					Data,
+  enum RF_RADIO_PATH     RF_PATH,
+	u32				    RegAddr
+	)
+{
+	if (Addr =3D=3D 0xfe) {
+		msleep(50);
+	} else if (Addr =3D=3D 0xfd) {
+		mdelay(5);
+	} else if (Addr =3D=3D 0xfc) {
+		mdelay(1);
+	} else if (Addr =3D=3D 0xfb) {
+		udelay(50);
+	} else if (Addr =3D=3D 0xfa) {
+		udelay(5);
+	} else if (Addr =3D=3D 0xf9) {
+		udelay(1);
+	} else {
+		ODM_SetRFReg(pDM_Odm, RF_PATH, RegAddr, bRFRegOffsetMask, Data);
+		/*  Add 1us delay between BB/RF register setting. */
+		udelay(1);
+	}
+}
+
+void odm_ConfigRF_RadioA_8723A(struct dm_odm_t *pDM_Odm,
+	u32					Addr,
+	u32					Data
+	)
+{
+	u32  content =3D 0x1000; /*  RF_Content: radioa_txt */
+	u32	maskforPhySet =3D (u32)(content&0xE000);
+
+	odm_ConfigRFReg_8723A(pDM_Odm, Addr, Data, RF_PATH_A,
+			      Addr|maskforPhySet);
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_LOUD,
+		     ("=3D=3D=3D> ODM_ConfigRFWithHeaderFile23a: [RadioA] %08X %08X\=
n",
+		     Addr, Data));
+}
+
+void odm_ConfigRF_RadioB_8723A(struct dm_odm_t *pDM_Odm,
+	u32					Addr,
+	u32					Data
+	)
+{
+	u32  content =3D 0x1001; /*  RF_Content: radiob_txt */
+	u32	maskforPhySet =3D (u32)(content&0xE000);
+
+	odm_ConfigRFReg_8723A(pDM_Odm, Addr, Data, RF_PATH_B,
+			      Addr|maskforPhySet);
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_LOUD,
+		     ("=3D=3D=3D> ODM_ConfigRFWithHeaderFile23a: [RadioB] %08X %08X\=
n",
+		     Addr, Data));
+}
+
+void odm_ConfigMAC_8723A(struct dm_odm_t *pDM_Odm,
+	u32		Addr,
+	u8		Data
+	)
+{
+	ODM_Write1Byte(pDM_Odm, Addr, Data);
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_LOUD,
+		     ("=3D=3D=3D> ODM_ConfigMACWithHeaderFile23a: [MAC_REG] %08X %08=
X\n",
+		     Addr, Data));
+}
+
+void
+odm_ConfigBB_AGC_8723A(
+	struct dm_odm_t *pDM_Odm,
+	u32		Addr,
+	u32		Bitmask,
+	u32		Data
+  )
+{
+	ODM_SetBBReg(pDM_Odm, Addr, Bitmask, Data);
+	/*  Add 1us delay between BB/RF register setting. */
+	udelay(1);
+
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_LOUD,
+		     ("=3D=3D=3D> ODM_ConfigBBWithHeaderFile23a: [AGC_TAB] %08X %08X=
\n",
+		     Addr, Data));
+}
+
+void
+odm_ConfigBB_PHY_REG_PG_8723A(
+	struct dm_odm_t *pDM_Odm,
+	u32		Addr,
+	u32		Bitmask,
+	u32		Data
+  )
+{
+	if (Addr =3D=3D 0xfe)
+		msleep(50);
+	else if (Addr =3D=3D 0xfd)
+		mdelay(5);
+	else if (Addr =3D=3D 0xfc)
+		mdelay(1);
+	else if (Addr =3D=3D 0xfb)
+		udelay(50);
+	else if (Addr =3D=3D 0xfa)
+		udelay(5);
+	else if (Addr =3D=3D 0xf9)
+		udelay(1);
+    /*  TODO: ODM_StorePwrIndexDiffRateOffset(...) */
+	/*  storePwrIndexDiffRateOffset(Adapter, Addr, Bitmask, Data); */
+
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_LOUD,
+		     ("=3D=3D=3D> ODM_ConfigBBWithHeaderFile23a: [PHY_REG] %08X %08X=
 %08X\n",
+		     Addr, Bitmask, Data));
+}
+
+void
+odm_ConfigBB_PHY_8723A(
+	struct dm_odm_t *pDM_Odm,
+	u32		Addr,
+	u32		Bitmask,
+	u32		Data
+  )
+{
+	if (Addr =3D=3D 0xfe)
+		msleep(50);
+	else if (Addr =3D=3D 0xfd)
+		mdelay(5);
+	else if (Addr =3D=3D 0xfc)
+		mdelay(1);
+	else if (Addr =3D=3D 0xfb)
+		udelay(50);
+	else if (Addr =3D=3D 0xfa)
+		udelay(5);
+	else if (Addr =3D=3D 0xf9)
+		udelay(1);
+	else if (Addr =3D=3D 0xa24)
+		pDM_Odm->RFCalibrateInfo.RegA24 =3D Data;
+	ODM_SetBBReg(pDM_Odm, Addr, Bitmask, Data);
+
+	/*  Add 1us delay between BB/RF register setting. */
+	udelay(1);
+
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_LOUD,
+		     ("=3D=3D=3D> ODM_ConfigBBWithHeaderFile23a: [PHY_REG] %08X %08X=
\n",
+		     Addr, Data));
+}
diff --git a/drivers/staging/rtl8723au/hal/odm_debug.c b/drivers/stagin=
g/rtl8723au/hal/odm_debug.c
new file mode 100644
index 0000000..c912ab8
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/odm_debug.c
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
+
+#include "odm_precomp.h"
+
+void ODM_InitDebugSetting23a(struct dm_odm_t *pDM_Odm)
+{
+	pDM_Odm->DebugLevel =3D ODM_DBG_TRACE;
+	pDM_Odm->DebugComponents =3D 0;
+}
+
+u32 GlobalDebugLevel23A;
diff --git a/drivers/staging/rtl8723au/hal/odm_interface.c b/drivers/st=
aging/rtl8723au/hal/odm_interface.c
new file mode 100644
index 0000000..bef1269
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/odm_interface.c
@@ -0,0 +1,236 @@
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
+/*  */
+/*  include files */
+/*  */
+
+#include "odm_precomp.h"
+/*  */
+/*  ODM IO Relative API. */
+/*  */
+
+u8 ODM_Read1Byte(struct dm_odm_t *pDM_Odm,
+	u32			RegAddr
+	)
+{
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+
+	return rtw_read8(Adapter, RegAddr);
+}
+
+u16 ODM_Read2Byte(struct dm_odm_t *pDM_Odm,
+	u32			RegAddr
+	)
+{
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+
+	return rtw_read16(Adapter, RegAddr);
+}
+
+u32 ODM_Read4Byte(struct dm_odm_t *pDM_Odm,
+	u32			RegAddr
+	)
+{
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+
+	return rtw_read32(Adapter, RegAddr);
+}
+
+void ODM_Write1Byte(
+	struct dm_odm_t *pDM_Odm,
+	u32			RegAddr,
+	u8			Data
+	)
+{
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+
+	rtw_write8(Adapter, RegAddr, Data);
+}
+
+void ODM_Write2Byte(
+	struct dm_odm_t *pDM_Odm,
+	u32			RegAddr,
+	u16			Data
+	)
+{
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+
+	rtw_write16(Adapter, RegAddr, Data);
+}
+
+void ODM_Write4Byte(
+	struct dm_odm_t *pDM_Odm,
+	u32			RegAddr,
+	u32			Data
+	)
+{
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+
+	rtw_write32(Adapter, RegAddr, Data);
+
+}
+
+void ODM_SetMACReg(
+	struct dm_odm_t *pDM_Odm,
+	u32		RegAddr,
+	u32		BitMask,
+	u32		Data
+	)
+{
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+
+	PHY_SetBBReg(Adapter, RegAddr, BitMask, Data);
+}
+
+u32 ODM_GetMACReg(
+	struct dm_odm_t *pDM_Odm,
+	u32		RegAddr,
+	u32		BitMask
+	)
+{
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+
+	return PHY_QueryBBReg(Adapter, RegAddr, BitMask);
+}
+
+void ODM_SetBBReg(
+	struct dm_odm_t *pDM_Odm,
+	u32		RegAddr,
+	u32		BitMask,
+	u32		Data
+	)
+{
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+
+	PHY_SetBBReg(Adapter, RegAddr, BitMask, Data);
+}
+
+u32 ODM_GetBBReg(
+	struct dm_odm_t *pDM_Odm,
+	u32		RegAddr,
+	u32		BitMask
+	)
+{
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+
+	return PHY_QueryBBReg(Adapter, RegAddr, BitMask);
+}
+
+void ODM_SetRFReg(
+	struct dm_odm_t *pDM_Odm,
+	enum RF_RADIO_PATH	eRFPath,
+	u32				RegAddr,
+	u32				BitMask,
+	u32				Data
+	)
+{
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+
+	PHY_SetRFReg(Adapter, eRFPath, RegAddr, BitMask, Data);
+}
+
+u32 ODM_GetRFReg(
+	struct dm_odm_t *pDM_Odm,
+	enum RF_RADIO_PATH	eRFPath,
+	u32				RegAddr,
+	u32				BitMask
+	)
+{
+	struct rtw_adapter *Adapter =3D pDM_Odm->Adapter;
+
+	return PHY_QueryRFReg(Adapter, eRFPath, RegAddr, BitMask);
+}
+
+/*  */
+/*  ODM Memory relative API. */
+/*  */
+void ODM_AllocateMemory(
+	struct dm_odm_t *pDM_Odm,
+	void **pPtr,
+	u32		length
+	)
+{
+	*pPtr =3D rtw_zvmalloc(length);
+}
+
+/*  length could be ignored, used to detect memory leakage. */
+void ODM_FreeMemory(
+	struct dm_odm_t *pDM_Odm,
+	void *pPtr,
+	u32		length
+	)
+{
+	rtw_vmfree(pPtr, length);
+}
+
+/*  */
+/*  ODM MISC relative API. */
+/*  */
+void
+ODM_AcquireSpinLock(
+	struct dm_odm_t *pDM_Odm,
+	enum rt_spinlock_type	type
+	)
+{
+}
+
+void ODM_ReleaseSpinLock(
+	struct dm_odm_t *pDM_Odm,
+	enum rt_spinlock_type	type
+	)
+{
+}
+
+/*  */
+/*  Work item relative API. FOr MP driver only~! */
+/*  */
+void ODM_InitializeWorkItem(
+	struct dm_odm_t *pDM_Odm,
+	void *pRtWorkItem,
+	RT_WORKITEM_CALL_BACK		RtWorkItemCallback,
+	void *pContext,
+	const char *szID
+	)
+{
+}
+
+/*  */
+/*  ODM Timer relative API. */
+/*  */
+void ODM_SetTimer(struct dm_odm_t *pDM_Odm, struct timer_list *pTimer,=
 u32 msDelay)
+{
+	mod_timer(pTimer, jiffies + msecs_to_jiffies(msDelay)); /* ms */
+}
+
+void ODM_ReleaseTimer(struct dm_odm_t *pDM_Odm, struct timer_list *pTi=
mer)
+{
+}
+
+/*  */
+/*  ODM FW relative API. */
+/*  */
+u32 ODM_FillH2CCmd(
+	u8 *pH2CBuffer,
+	u32		H2CBufferLen,
+	u32		CmdNum,
+	u32 *pElementID,
+	u32 *pCmdLen,
+	u8 **pCmbBuffer,
+	u8 *CmdStartSeq
+	)
+{
+	return	true;
+}
diff --git a/drivers/staging/rtl8723au/hal/rtl8723a_bt-coexist.c b/driv=
ers/staging/rtl8723au/hal/rtl8723a_bt-coexist.c
new file mode 100644
index 0000000..2d4135f
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/rtl8723a_bt-coexist.c
@@ -0,0 +1,11304 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2007 - 2012 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ *published by the Free Software Foundation.
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
+#include <drv_types.h>
+#include <rtl8723a_hal.h>
+#include <rtw_ioctl_set.h>
+
+#define DIS_PS_RX_BCN
+
+#ifdef CONFIG_8723AU_BT_COEXIST
+
+u32 BTCoexDbgLevel =3D _bt_dbg_off_;
+
+#define RTPRINT(_Comp, _Level, Fmt)\
+do {\
+	if ((BTCoexDbgLevel =3D=3D _bt_dbg_on_)) {\
+		printk Fmt;\
+	}					\
+} while (0)
+
+#define RTPRINT_ADDR(dbgtype, dbgflag, printstr, _Ptr)\
+if ((BTCoexDbgLevel =3D=3D _bt_dbg_on_)) {\
+	u32 __i;						\
+	u8 *ptr =3D (u8 *)_Ptr;	\
+	printk printstr;				\
+	printk(" ");					\
+	for (__i =3D 0; __i < 6; __i++)		\
+		printk("%02X%s", ptr[__i], (__i =3D=3D 5)?"":"-");		\
+	printk("\n");							\
+}
+#define RTPRINT_DATA(dbgtype, dbgflag, _TitleString, _HexData, _HexDat=
aLen)\
+if ((BTCoexDbgLevel =3D=3D _bt_dbg_on_)) {\
+	u32 __i;						\
+	u8 *ptr =3D (u8 *)_HexData;				\
+	printk(_TitleString);					\
+	for (__i =3D 0; __i < (u32)_HexDataLen; __i++) {		\
+		printk("%02X%s", ptr[__i], (((__i + 1) % 4) =3D=3D 0)?"  ":" ");\
+		if (((__i + 1) % 16) =3D=3D 0)			\
+			printk("\n");				\
+	}								\
+	printk("\n");							\
+}
+/*  Added by Annie, 2005-11-22. */
+#define MAX_STR_LEN	64
+/*  I want to see ASCII 33 to 126 only. Otherwise, I print '?'. */
+#define PRINTABLE(_ch)	(_ch >=3D ' ' && _ch <=3D '~')
+#define RT_PRINT_STR(_Comp, _Level, _TitleString, _Ptr, _Len)		\
+	{								\
+		u32 __i;						\
+		u8 buffer[MAX_STR_LEN];					\
+		u32 length =3D (_Len < MAX_STR_LEN) ? _Len : (MAX_STR_LEN-1);\
+		memset(buffer, 0, MAX_STR_LEN);				\
+		memcpy(buffer, (u8 *)_Ptr, length);			\
+		for (__i =3D 0; __i < length; __i++) {			\
+			if (!PRINTABLE(buffer[__i]))			\
+				buffer[__i] =3D '?';			\
+		}							\
+		buffer[length] =3D '\0';					\
+		printk(_TitleString);					\
+		printk(": %d, <%s>\n", _Len, buffer);			\
+	}
+#endif
+
+#define DCMD_Printf(...)
+#define RT_ASSERT(...)
+
+#define rsprintf snprintf
+
+#define GetDefaultAdapter(padapter)	padapter
+
+#define PlatformZeroMemory(ptr, sz)	memset(ptr, 0, sz)
+
+#define PlatformProcessHCICommands(...)
+#define PlatformTxBTQueuedPackets(...)
+#define PlatformIndicateBTACLData(...)	(RT_STATUS_SUCCESS)
+#define PlatformAcquireSpinLock(padapter, type)
+#define PlatformReleaseSpinLock(padapter, type)
+
+#define GET_UNDECORATED_AVERAGE_RSSI(padapter)	\
+			(GET_HAL_DATA(padapter)->dmpriv.EntryMinUndecoratedSmoothedPWDB)
+#define RT_RF_CHANGE_SOURCE u32
+
+enum {
+	RT_JOIN_INFRA   =3D 1,
+	RT_JOIN_IBSS  =3D 2,
+	RT_START_IBSS =3D 3,
+	RT_NO_ACTION  =3D 4,
+};
+
+/*  power saving */
+
+#ifdef __BT_C__ /*  COMMOM/BT.c */
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver COMMOM/BT.=
c =3D=3D=3D=3D=3D */
+
+static u8 BT_Operation(struct rtw_adapter *padapter)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	if (pBtMgnt->BtOperationOn)
+		return true;
+	else
+		return false;
+}
+
+static u8 BT_IsLegalChannel(struct rtw_adapter *padapter, u8 channel)
+{
+	struct rt_channel_info *pChanneList =3D NULL;
+	u8 channelLen, i;
+
+	pChanneList =3D padapter->mlmeextpriv.channel_set;
+	channelLen =3D padapter->mlmeextpriv.max_chan_nums;
+
+	for (i =3D 0; i < channelLen; i++) {
+		RTPRINT(FIOCTL, IOCTL_STATE,
+			("Check if chnl(%d) in channel plan contains bt target chnl(%d) for=
 BT connection\n",
+			 pChanneList[i].ChannelNum, channel));
+		if ((channel =3D=3D pChanneList[i].ChannelNum) ||
+		    (channel =3D=3D pChanneList[i].ChannelNum + 2))
+			return channel;
+	}
+	return 0;
+}
+
+void BT_SignalCompensation(struct rtw_adapter *padapter, u8 *rssi_wifi=
, u8 *rssi_bt)
+{
+	BTDM_SignalCompensation(padapter, rssi_wifi, rssi_bt);
+}
+
+void BT_WifiScanNotify(struct rtw_adapter *padapter, u8 scanType)
+{
+	BTHCI_WifiScanNotify(padapter, scanType);
+	BTDM_CheckAntSelMode(padapter);
+	BTDM_WifiScanNotify(padapter, scanType);
+}
+
+void BT_WifiAssociateNotify(struct rtw_adapter *padapter, u8 action)
+{
+	/*  action : */
+	/*  true =3D associate start */
+	/*  false =3D associate finished */
+	if (action)
+		BTDM_CheckAntSelMode(padapter);
+
+	BTDM_WifiAssociateNotify(padapter, action);
+}
+
+void BT_WifiMediaStatusNotify(struct rtw_adapter *padapter, enum rt_me=
dia_status mstatus)
+{
+	BTDM_MediaStatusNotify(padapter, mstatus);
+}
+
+void BT_SpecialPacketNotify(struct rtw_adapter *padapter)
+{
+	BTDM_ForDhcp(padapter);
+}
+
+void BT_HaltProcess(struct rtw_adapter *padapter)
+{
+	BTDM_ForHalt(padapter);
+}
+
+void BT_LpsLeave(struct rtw_adapter *padapter)
+{
+	BTDM_LpsLeave(padapter);
+}
+
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver COMMOM/BT.c =3D=3D=3D=3D=
=3D */
+#endif
+
+#ifdef __BT_HANDLEPACKET_C__ /*  COMMOM/bt_handlepacket.c */
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver COMMOM/bt_=
handlepacket.c =3D=3D=3D=3D=3D */
+
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver COMMOM/bt_handlepacket=
=2Ec =3D=3D=3D=3D=3D */
+#endif
+
+#ifdef __BT_HCI_C__ /*  COMMOM/bt_hci.c */
+
+#define i64fmt		"ll"
+#define UINT64_C(v)  (v)
+
+#define FillOctetString(_os, _octet, _len)		\
+	(_os).Octet =3D (u8 *)(_octet);			\
+	(_os).Length =3D (_len);
+
+static enum rt_status PlatformIndicateBTEvent(
+	struct rtw_adapter *padapter,
+	void						*pEvntData,
+	u32						dataLen
+	)
+{
+	enum rt_status	rt_status =3D RT_STATUS_FAILURE;
+
+	RTPRINT(FIOCTL, IOCTL_BT_EVENT_DETAIL, ("BT event start, %d bytes dat=
a to Transferred!!\n", dataLen));
+	RTPRINT_DATA(FIOCTL, IOCTL_BT_EVENT_DETAIL, "To transfer Hex Data :\n=
",
+		pEvntData, dataLen);
+
+	BT_EventParse(padapter, pEvntData, dataLen);
+
+	printk(KERN_WARNING "%s: Linux has no way to report BT event!!\n", __=
func__);
+
+	RTPRINT(FIOCTL, IOCTL_BT_EVENT_DETAIL, ("BT event end, %s\n",
+		(rt_status =3D=3D RT_STATUS_SUCCESS) ? "SUCCESS" : "FAIL"));
+
+	return rt_status;
+}
+
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver COMMOM/bt_=
hci.c =3D=3D=3D=3D=3D */
+
+static u8 bthci_GetLocalChannel(struct rtw_adapter *padapter)
+{
+	return padapter->mlmeextpriv.cur_channel;
+}
+
+static u8 bthci_GetCurrentEntryNum(struct rtw_adapter *padapter, u8 Ph=
yHandle)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	u8 i;
+
+	for (i =3D 0; i < MAX_BT_ASOC_ENTRY_NUM; i++) {
+		if ((pBTInfo->BtAsocEntry[i].bUsed) &&
+		    (pBTInfo->BtAsocEntry[i].PhyLinkCmdData.BtPhyLinkhandle =3D=3D P=
hyHandle))
+			return i;
+	}
+
+	return 0xFF;
+}
+
+static void bthci_DecideBTChannel(struct rtw_adapter *padapter, u8 Ent=
ryNum)
+{
+/*PMGNT_INFO pMgntInfo =3D &padapter->MgntInfo; */
+	struct mlme_priv *pmlmepriv;
+	struct bt_30info *pBTInfo;
+	struct bt_mgnt *pBtMgnt;
+	struct bt_hci_info *pBtHciInfo;
+	struct chnl_txpower_triple *pTriple_subband =3D NULL;
+	struct common_triple *pTriple;
+	u8 i, j, localchnl, firstRemoteLegalChnlInTriplet =3D 0;
+	u8 regulatory_skipLen =3D 0;
+	u8 subbandTripletCnt =3D 0;
+
+	pmlmepriv =3D &padapter->mlmepriv;
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtMgnt =3D &pBTInfo->BtMgnt;
+	pBtHciInfo =3D &pBTInfo->BtHciInfo;
+
+	pBtMgnt->CheckChnlIsSuit =3D true;
+	localchnl =3D bthci_GetLocalChannel(padapter);
+
+	pTriple =3D (struct common_triple *)
+		&pBtHciInfo->BTPreChnllist[COUNTRY_STR_LEN];
+
+	/*  contains country string, len is 3 */
+	for (i =3D 0; i < (pBtHciInfo->BtPreChnlListLen-COUNTRY_STR_LEN); i +=
=3D 3, pTriple++) {
+		/*  */
+		/*  check every triplet, an triplet may be */
+		/*  regulatory extension identifier or sub-band triplet */
+		/*  */
+		if (pTriple->byte_1st =3D=3D 0xc9) {
+			/*  Regulatory Extension Identifier, skip it */
+			RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO),
+				("Find Regulatory ID, regulatory class =3D %d\n", pTriple->byte_2n=
d));
+			regulatory_skipLen +=3D 3;
+			pTriple_subband =3D NULL;
+			continue;
+		} else {	/*  Sub-band triplet */
+			RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("Find Sub-band tr=
iplet \n"));
+			subbandTripletCnt++;
+			pTriple_subband =3D (struct chnl_txpower_triple *)pTriple;
+			/*  if remote first legal channel not found, then find first remote=
 channel */
+			/*  and it's legal for our channel plan. */
+
+			/*  search the sub-band triplet and find if remote channel is legal=
 to our channel plan. */
+			for (j =3D pTriple_subband->FirstChnl; j < (pTriple_subband->FirstC=
hnl+pTriple_subband->NumChnls); j++) {
+				RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), (" Check if chnl(=
%d) is legal\n", j));
+				if (BT_IsLegalChannel(padapter, j)) {
+					/*  remote channel is legal for our channel plan. */
+					firstRemoteLegalChnlInTriplet =3D j;
+					RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO),
+						("Find first remote legal channel : %d\n",
+						firstRemoteLegalChnlInTriplet));
+
+					/*  If we find a remote legal channel in the sub-band triplet */
+					/*  and only BT connection is established(local not connect to an=
y AP or IBSS), */
+					/*  then we just switch channel to remote channel. */
+					if (!(check_fwstate(pmlmepriv, WIFI_ASOC_STATE|WIFI_ADHOC_STATE|W=
IFI_AP_STATE) ||
+					    BTHCI_HsConnectionEstablished(padapter))) {
+						pBtMgnt->BTChannel =3D firstRemoteLegalChnlInTriplet;
+						RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("Remote legal =
channel (%d) is selected, Local not connect to any!!\n", pBtMgnt->BTCha=
nnel));
+						return;
+					} else {
+						if ((localchnl >=3D firstRemoteLegalChnlInTriplet) &&
+						    (localchnl < (pTriple_subband->FirstChnl+pTriple_subband->Nu=
mChnls))) {
+							pBtMgnt->BTChannel =3D localchnl;
+							RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("Local channe=
l (%d) is selected, wifi or BT connection exists\n", pBtMgnt->BTChannel=
));
+							return;
+						}
+					}
+					break;
+				}
+			}
+		}
+	}
+
+	if (subbandTripletCnt) {
+		/* if any preferred channel triplet exists */
+		RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("There are %d sub =
band triplet exists, ", subbandTripletCnt));
+		if (firstRemoteLegalChnlInTriplet =3D=3D 0) {
+			/* no legal channel is found, reject the connection. */
+			RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("no legal channel=
 is found!!\n"));
+		} else {
+			/*  Remote Legal channel is found but not match to local */
+			/* wifi connection exists), so reject the connection. */
+			RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO),
+				("Remote Legal channel is found but not match to local(wifi connec=
tion exists)!!\n"));
+		}
+		pBtMgnt->CheckChnlIsSuit =3D false;
+	} else {
+		/*  There are not any preferred channel triplet exists */
+		/*  Use current legal channel as the bt channel. */
+		RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("No sub band tripl=
et exists!!\n"));
+	}
+	pBtMgnt->BTChannel =3D localchnl;
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("Local channel (%d)=
 is selected!!\n", pBtMgnt->BTChannel));
+}
+
+/* Success:return true */
+/* Fail:return false */
+static u8 bthci_GetAssocInfo(struct rtw_adapter *padapter, u8 EntryNum=
)
+{
+	struct bt_30info *pBTInfo;
+	struct bt_hci_info *pBtHciInfo;
+	u8 tempBuf[256];
+	u8 i =3D 0;
+	u8 BaseMemoryShift =3D 0;
+	u16	TotalLen =3D 0;
+	struct amp_assoc_structure *pAmpAsoc;
+
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("GetAssocInfo start\n"));
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtHciInfo =3D &pBTInfo->BtHciInfo;
+
+	if (pBTInfo->BtAsocEntry[EntryNum].AmpAsocCmdData.LenSoFar =3D=3D 0) =
{
+		if (pBTInfo->BtAsocEntry[EntryNum].AmpAsocCmdData.AMPAssocRemLen < (=
MAX_AMP_ASSOC_FRAG_LEN))
+			TotalLen =3D pBTInfo->BtAsocEntry[EntryNum].AmpAsocCmdData.AMPAssoc=
RemLen;
+		else if (pBTInfo->BtAsocEntry[EntryNum].AmpAsocCmdData.AMPAssocRemLe=
n =3D=3D (MAX_AMP_ASSOC_FRAG_LEN))
+			TotalLen =3D MAX_AMP_ASSOC_FRAG_LEN;
+	} else if (pBTInfo->BtAsocEntry[EntryNum].AmpAsocCmdData.LenSoFar > 0=
)
+		TotalLen =3D pBTInfo->BtAsocEntry[EntryNum].AmpAsocCmdData.LenSoFar;
+
+	while ((pBTInfo->BtAsocEntry[EntryNum].AmpAsocCmdData.LenSoFar >=3D B=
aseMemoryShift) || TotalLen > BaseMemoryShift) {
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_DETAIL, ("GetAssocInfo, TotalLen =3D=
%d, BaseMemoryShift =3D%d\n", TotalLen, BaseMemoryShift));
+		memcpy(tempBuf,
+			(u8 *)pBTInfo->BtAsocEntry[EntryNum].AmpAsocCmdData.AMPAssocfragmen=
t+BaseMemoryShift,
+			TotalLen-BaseMemoryShift);
+		RTPRINT_DATA(FIOCTL, IOCTL_BT_HCICMD_DETAIL, "GetAssocInfo :\n",
+			tempBuf, TotalLen-BaseMemoryShift);
+
+		pAmpAsoc =3D (struct amp_assoc_structure *)tempBuf;
+		pAmpAsoc->Length =3D le16_to_cpu(pAmpAsoc->Length);
+		BaseMemoryShift +=3D 3 + pAmpAsoc->Length;
+
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("TypeID =3D 0x%x, ", pAmpAsoc->Typ=
eID));
+		RTPRINT_DATA(FIOCTL, IOCTL_BT_HCICMD, "Hex Data: \n", pAmpAsoc->Data=
, pAmpAsoc->Length);
+		switch (pAmpAsoc->TypeID) {
+		case AMP_MAC_ADDR:
+			RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("=3D=3D> AMP_MAC_ADDR\n"));
+			if (pAmpAsoc->Length > 6)
+				return false;
+			memcpy(pBTInfo->BtAsocEntry[EntryNum].BTRemoteMACAddr, pAmpAsoc->Da=
ta, 6);
+			RTPRINT_ADDR(FIOCTL, IOCTL_BT_HCICMD, ("Remote Mac address \n"), pB=
TInfo->BtAsocEntry[EntryNum].BTRemoteMACAddr);
+			break;
+		case AMP_PREFERRED_CHANNEL_LIST:
+			RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("=3D=3D> AMP_PREFERRED_CHANNEL_LI=
ST\n"));
+			pBtHciInfo->BtPreChnlListLen =3D pAmpAsoc->Length;
+			memcpy(pBtHciInfo->BTPreChnllist,
+				pAmpAsoc->Data,
+				pBtHciInfo->BtPreChnlListLen);
+			RTPRINT_DATA(FIOCTL, IOCTL_BT_HCICMD, "Preferred channel list : \n"=
, pBtHciInfo->BTPreChnllist, pBtHciInfo->BtPreChnlListLen);
+			bthci_DecideBTChannel(padapter, EntryNum);
+			break;
+		case AMP_CONNECTED_CHANNEL:
+			RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("=3D=3D> AMP_CONNECTED_CHANNEL\n"=
));
+			pBtHciInfo->BTConnectChnlListLen =3D pAmpAsoc->Length;
+			memcpy(pBtHciInfo->BTConnectChnllist,
+				pAmpAsoc->Data,
+				pBtHciInfo->BTConnectChnlListLen);
+			break;
+		case AMP_80211_PAL_CAP_LIST:
+			RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("=3D=3D> AMP_80211_PAL_CAP_LIST\n=
"));
+			pBTInfo->BtAsocEntry[EntryNum].BTCapability =3D *(u32 *)(pAmpAsoc->=
Data);
+			if (pBTInfo->BtAsocEntry[EntryNum].BTCapability & 0x00000001) {
+				/*  TODO: */
+
+				/* Signifies PAL capable of utilizing received activity reports. *=
/
+			}
+			if (pBTInfo->BtAsocEntry[EntryNum].BTCapability & 0x00000002) {
+				/*  TODO: */
+				/* Signifies PAL is capable of utilizing scheduling information re=
ceived in an activity reports. */
+			}
+			break;
+		case AMP_80211_PAL_VISION:
+			pBtHciInfo->BTPalVersion =3D *(u8 *)(pAmpAsoc->Data);
+			pBtHciInfo->BTPalCompanyID =3D *(u16 *)(((u8 *)(pAmpAsoc->Data))+1)=
;
+			pBtHciInfo->BTPalsubversion =3D *(u16 *)(((u8 *)(pAmpAsoc->Data))+3=
);
+			RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("=3D=3D> AMP_8021=
1_PAL_VISION PalVersion  0x%x, PalCompanyID  0x%x, Palsubversion 0x%x\n=
",
+				pBtHciInfo->BTPalVersion,
+				pBtHciInfo->BTPalCompanyID,
+				pBtHciInfo->BTPalsubversion));
+			break;
+		default:
+			RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("=3D=3D> Unsupport TypeID !!\n"))=
;
+			break;
+		}
+		i++;
+	}
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("GetAssocInfo end\n"));
+
+	return true;
+}
+
+static u8 bthci_AddEntry(struct rtw_adapter *padapter)
+{
+	struct bt_30info *pBTInfo;
+	struct bt_mgnt *pBtMgnt;
+	u8 i;
+
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	for (i =3D 0; i < MAX_BT_ASOC_ENTRY_NUM; i++) {
+		if (pBTInfo->BtAsocEntry[i].bUsed =3D=3D false) {
+			pBTInfo->BtAsocEntry[i].bUsed =3D true;
+			pBtMgnt->CurrentConnectEntryNum =3D i;
+			break;
+		}
+	}
+
+	if (i =3D=3D MAX_BT_ASOC_ENTRY_NUM) {
+		RTPRINT(FIOCTL, IOCTL_STATE, ("bthci_AddEntry(), Add entry fail!!\n"=
));
+		return false;
+	}
+	return true;
+}
+
+static u8 bthci_DiscardTxPackets(struct rtw_adapter *padapter, u16 LLH=
)
+{
+	return false;
+}
+
+static u8
+bthci_CheckLogLinkBehavior(
+	struct rtw_adapter *padapter,
+	struct hci_flow_spec			TxFlowSpec
+	)
+{
+	u8 ID =3D TxFlowSpec.Identifier;
+	u8 ServiceType =3D TxFlowSpec.ServiceType;
+	u16	MaxSDUSize =3D TxFlowSpec.MaximumSDUSize;
+	u32	SDUInterArrivatime =3D TxFlowSpec.SDUInterArrivalTime;
+	u8 match =3D false;
+
+	switch (ID) {
+	case 1:
+		if (ServiceType =3D=3D BT_LL_BE) {
+			match =3D true;
+			RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("Logical Link Type=
 =3D  TX best effort flowspec\n"));
+		} else if ((ServiceType =3D=3D BT_LL_GU) && (MaxSDUSize =3D=3D 0xfff=
f)) {
+			match =3D true;
+			RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("Logical Link Type=
 =3D  RX guaranteed latency flowspec\n"));
+		} else if ((ServiceType =3D=3D BT_LL_GU) && (MaxSDUSize =3D=3D 2500)=
) {
+			RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("Logical Link Type=
 =3D  RX guaranteed Large latency flowspec\n"));
+		}
+		break;
+	case 2:
+		if (ServiceType =3D=3D BT_LL_BE) {
+			match =3D true;
+			RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("Logical Link Type=
 =3D  RX best effort flowspec\n"));
+
+		}
+		break;
+	case 3:
+		if ((ServiceType =3D=3D BT_LL_GU) && (MaxSDUSize =3D=3D 1492)) {
+			match =3D true;
+			RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("Logical Link Type=
 =3D  TX guaranteed latency flowspec\n"));
+		} else if ((ServiceType =3D=3D BT_LL_GU) && (MaxSDUSize =3D=3D 2500)=
) {
+			RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("Logical Link Type=
 =3D  TX guaranteed Large latency flowspec\n"));
+		}
+		break;
+	case 4:
+		if (ServiceType =3D=3D BT_LL_BE) {
+			if ((SDUInterArrivatime =3D=3D 0xffffffff) && (ServiceType =3D=3D B=
T_LL_BE) && (MaxSDUSize =3D=3D 1492)) {
+				match =3D true;
+				RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("Logical Link Typ=
e =3D  TX/RX aggregated best effort flowspec\n"));
+			}
+		} else if (ServiceType =3D=3D BT_LL_GU) {
+			if (SDUInterArrivatime =3D=3D 100) {
+				match =3D true;
+				RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("Logical Link Typ=
e =3D  TX/RX guaranteed bandwidth flowspec\n"));
+			}
+		}
+		break;
+	default:
+		RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("Logical Link Type =
=3D  Unknow Type !!!!!!!!\n"));
+		break;
+	}
+
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO),
+		("ID =3D 0x%x, ServiceType =3D 0x%x, MaximumSDUSize =3D 0x%x, SDUInt=
erArrivalTime =3D 0x%x, AccessLatency =3D 0x%x, FlushTimeout =3D 0x%x\n=
",
+		TxFlowSpec.Identifier, TxFlowSpec.ServiceType, MaxSDUSize,
+		SDUInterArrivatime, TxFlowSpec.AccessLatency, TxFlowSpec.FlushTimeou=
t));
+	return match;
+}
+
+static u16 bthci_AssocMACAddr(struct rtw_adapter *padapter, void	*pbuf=
)
+{
+	struct amp_assoc_structure *pAssoStrc =3D (struct amp_assoc_structure=
 *)pbuf;
+	pAssoStrc->TypeID =3D AMP_MAC_ADDR;
+	pAssoStrc->Length =3D 0x06;
+	memcpy(&pAssoStrc->Data[0], padapter->eeprompriv.mac_addr, 6);
+	RTPRINT_DATA(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_HCICMD_DETAIL|IOCTL_BT=
_LOGO),
+		     ("AssocMACAddr : \n"), pAssoStrc, pAssoStrc->Length+3);
+
+	return pAssoStrc->Length + 3;
+}
+
+static u16
+bthci_PALCapabilities(
+	struct rtw_adapter *padapter,
+	void	*pbuf
+	)
+{
+	struct amp_assoc_structure *pAssoStrc =3D (struct amp_assoc_structure=
 *)pbuf;
+
+	pAssoStrc->TypeID =3D AMP_80211_PAL_CAP_LIST;
+	pAssoStrc->Length =3D 0x04;
+
+	pAssoStrc->Data[0] =3D 0x00;
+	pAssoStrc->Data[1] =3D 0x00;
+
+	RTPRINT_DATA(FIOCTL, IOCTL_BT_HCICMD_DETAIL, ("PALCapabilities:\n"), =
pAssoStrc, pAssoStrc->Length+3);
+	RTPRINT(FIOCTL, IOCTL_BT_LOGO, ("PALCapabilities \n"));
+
+	RTPRINT(FIOCTL, IOCTL_BT_LOGO, (" TypeID =3D 0x%x,\n Length =3D 0x%x,=
\n Content =3D 0x0000\n",
+		pAssoStrc->TypeID,
+		pAssoStrc->Length));
+
+	return pAssoStrc->Length + 3;
+}
+
+static u16 bthci_AssocPreferredChannelList(struct rtw_adapter *padapte=
r,
+					   void *pbuf, u8 EntryNum)
+{
+	struct bt_30info *pBTInfo;
+	struct amp_assoc_structure *pAssoStrc;
+	struct amp_pref_chnl_regulatory *pReg;
+	struct chnl_txpower_triple *pTriple;
+	char ctrString[3] =3D {'X', 'X', 'X'};
+	u32 len =3D 0;
+	u8 preferredChnl;
+
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pAssoStrc =3D (struct amp_assoc_structure *)pbuf;
+	pReg =3D (struct amp_pref_chnl_regulatory *)&pAssoStrc->Data[3];
+
+	preferredChnl =3D bthci_GetLocalChannel(padapter);
+	pAssoStrc->TypeID =3D AMP_PREFERRED_CHANNEL_LIST;
+
+	/*  locale unknown */
+	memcpy(&pAssoStrc->Data[0], &ctrString[0], 3);
+	pReg->reXId =3D 201;
+	pReg->regulatoryClass =3D 254;
+	pReg->coverageClass =3D 0;
+	len +=3D 6;
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD | IOCTL_BT_LOGO), ("PREFERRED_CHNL_L=
IST\n"));
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD | IOCTL_BT_LOGO), ("XXX, 201, 254, 0=
\n"));
+	/*  at the following, chnl 1~11 should be contained */
+	pTriple =3D (struct chnl_txpower_triple *)&pAssoStrc->Data[len];
+
+	/*  (1) if any wifi or bt HS connection exists */
+	if ((pBTInfo->BtAsocEntry[EntryNum].AMPRole =3D=3D AMP_BTAP_CREATOR) =
||
+	    (check_fwstate(&padapter->mlmepriv, WIFI_ASOC_STATE |
+			   WIFI_ADHOC_STATE | WIFI_ADHOC_MASTER_STATE |
+			   WIFI_AP_STATE)) ||
+	    BTHCI_HsConnectionEstablished(padapter)) {
+		pTriple->FirstChnl =3D preferredChnl;
+		pTriple->NumChnls =3D 1;
+		pTriple->MaxTxPowerInDbm =3D 20;
+		len +=3D 3;
+		RTPRINT(FIOCTL, (IOCTL_BT_HCICMD | IOCTL_BT_LOGO), ("First Channel =3D=
 %d, Channel Num =3D %d, MaxDbm =3D %d\n",
+			pTriple->FirstChnl,
+			pTriple->NumChnls,
+			pTriple->MaxTxPowerInDbm));
+	}
+
+	pAssoStrc->Length =3D (u16)len;
+	RTPRINT_DATA(FIOCTL, IOCTL_BT_HCICMD, ("AssocPreferredChannelList : \=
n"), pAssoStrc, pAssoStrc->Length+3);
+
+	return pAssoStrc->Length + 3;
+}
+
+static u16 bthci_AssocPALVer(struct rtw_adapter *padapter, void *pbuf)
+{
+	struct amp_assoc_structure *pAssoStrc =3D (struct amp_assoc_structure=
 *)pbuf;
+	u8 *pu1Tmp;
+	u16	*pu2Tmp;
+
+	pAssoStrc->TypeID =3D AMP_80211_PAL_VISION;
+	pAssoStrc->Length =3D 0x5;
+	pu1Tmp =3D &pAssoStrc->Data[0];
+	*pu1Tmp =3D 0x1;	/*  PAL Version */
+	pu2Tmp =3D (u16 *)&pAssoStrc->Data[1];
+	*pu2Tmp =3D 0x5D;	/*  SIG Company identifier of 802.11 PAL vendor */
+	pu2Tmp =3D (u16 *)&pAssoStrc->Data[3];
+	*pu2Tmp =3D 0x1;	/*  PAL Sub-version specifier */
+
+	RTPRINT_DATA(FIOCTL, IOCTL_BT_HCICMD_DETAIL, ("AssocPALVer : \n"), pA=
ssoStrc, pAssoStrc->Length+3);
+	RTPRINT(FIOCTL, IOCTL_BT_LOGO, ("AssocPALVer \n"));
+
+	RTPRINT(FIOCTL, IOCTL_BT_LOGO, (" TypeID =3D 0x%x,\n Length =3D 0x%x,=
\n PAL Version =3D 0x01,\n PAL vendor =3D 0x01,\n PAL Sub-version speci=
fier =3D 0x01\n",
+		pAssoStrc->TypeID,
+		pAssoStrc->Length));
+	return pAssoStrc->Length + 3;
+}
+
+static u8 bthci_CheckRfStateBeforeConnect(struct rtw_adapter *padapter=
)
+{
+	struct bt_30info *pBTInfo;
+	enum rt_rf_power_state		RfState;
+
+	pBTInfo =3D GET_BT_INFO(padapter);
+
+	RfState =3D padapter->pwrctrlpriv.rf_pwrstate;
+
+	if (RfState !=3D rf_on) {
+		mod_timer(&pBTInfo->BTPsDisableTimer,
+			  jiffies + msecs_to_jiffies(50));
+		return false;
+	}
+	return true;
+}
+
+static void bthci_ResponderStartToScan(struct rtw_adapter *padapter)
+{
+}
+
+static u8 bthci_PhyLinkConnectionInProgress(struct rtw_adapter *padapt=
er, u8 PhyLinkHandle)
+{
+	struct bt_30info *pBTInfo;
+	struct bt_mgnt *pBtMgnt;
+
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	if (pBtMgnt->bPhyLinkInProgress &&
+		(pBtMgnt->BtCurrentPhyLinkhandle =3D=3D PhyLinkHandle))
+		return true;
+	return false;
+}
+
+static void bthci_ResetFlowSpec(struct rtw_adapter *padapter, u8 Entry=
Num, u8 index)
+{
+	struct bt_30info *pBTinfo;
+
+	pBTinfo =3D GET_BT_INFO(padapter);
+
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].BtLogLinkhandle =
=3D 0;
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].BtPhyLinkhandle =
=3D 0;
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].bLLCompleteEvent=
IsSet =3D false;
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].bLLCancelCMDIsSe=
tandComplete =3D false;
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].BtTxFlowSpecID =3D=
 0;
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].TxPacketCount =3D=
 0;
+
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].Tx_Flow_Spec.Ide=
ntifier =3D 0x01;
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].Tx_Flow_Spec.Ser=
viceType =3D SERVICE_BEST_EFFORT;
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].Tx_Flow_Spec.Max=
imumSDUSize =3D 0xffff;
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].Tx_Flow_Spec.SDU=
InterArrivalTime =3D 0xffffffff;
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].Tx_Flow_Spec.Acc=
essLatency =3D 0xffffffff;
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].Tx_Flow_Spec.Flu=
shTimeout =3D 0xffffffff;
+
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].Rx_Flow_Spec.Ide=
ntifier =3D 0x01;
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].Rx_Flow_Spec.Ser=
viceType =3D SERVICE_BEST_EFFORT;
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].Rx_Flow_Spec.Max=
imumSDUSize =3D 0xffff;
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].Rx_Flow_Spec.SDU=
InterArrivalTime =3D 0xffffffff;
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].Rx_Flow_Spec.Acc=
essLatency =3D 0xffffffff;
+	pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[index].Rx_Flow_Spec.Flu=
shTimeout =3D 0xffffffff;
+}
+
+static void bthci_ResetEntry(struct rtw_adapter *padapter, u8 EntryNum=
)
+{
+	struct bt_30info *pBTinfo;
+	struct bt_mgnt *pBtMgnt;
+	u8 j;
+
+	pBTinfo =3D GET_BT_INFO(padapter);
+	pBtMgnt =3D &pBTinfo->BtMgnt;
+
+	pBTinfo->BtAsocEntry[EntryNum].bUsed =3D false;
+	pBTinfo->BtAsocEntry[EntryNum].BtCurrentState =3D HCI_STATE_DISCONNEC=
TED;
+	pBTinfo->BtAsocEntry[EntryNum].BtNextState =3D HCI_STATE_DISCONNECTED=
;
+
+	pBTinfo->BtAsocEntry[EntryNum].AmpAsocCmdData.AMPAssocRemLen =3D 0;
+	pBTinfo->BtAsocEntry[EntryNum].AmpAsocCmdData.BtPhyLinkhandle =3D 0;
+	if (pBTinfo->BtAsocEntry[EntryNum].AmpAsocCmdData.AMPAssocfragment !=3D=
 NULL)
+		memset(pBTinfo->BtAsocEntry[EntryNum].AmpAsocCmdData.AMPAssocfragmen=
t, 0, TOTAL_ALLOCIATE_ASSOC_LEN);
+	pBTinfo->BtAsocEntry[EntryNum].AmpAsocCmdData.LenSoFar =3D 0;
+
+	pBTinfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtAMPKeyType =3D 0;
+	pBTinfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtPhyLinkhandle =3D 0;
+	memset(pBTinfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtAMPKey, 0,
+	       pBTinfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtAMPKeyLen);
+	pBTinfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtAMPKeyLen =3D 0;
+
+	/* 0x640; 0.625ms*1600 =3D 1000ms, 0.625ms*16000 =3D 10000ms */
+	pBTinfo->BtAsocEntry[EntryNum].PhyLinkCmdData.LinkSuperversionTimeout=
 =3D 0x3e80;
+
+	pBTinfo->BtAsocEntry[EntryNum].AMPRole =3D AMP_BTAP_NONE;
+
+	pBTinfo->BtAsocEntry[EntryNum].mAssoc =3D false;
+	pBTinfo->BtAsocEntry[EntryNum].b4waySuccess =3D false;
+
+	/*  Reset BT WPA */
+	pBTinfo->BtAsocEntry[EntryNum].KeyReplayCounter =3D 0;
+	pBTinfo->BtAsocEntry[EntryNum].BTWPAAuthState =3D STATE_WPA_AUTH_UNIN=
ITIALIZED;
+
+	pBTinfo->BtAsocEntry[EntryNum].bSendSupervisionPacket =3D false;
+	pBTinfo->BtAsocEntry[EntryNum].NoRxPktCnt =3D 0;
+	pBTinfo->BtAsocEntry[EntryNum].ShortRangeMode =3D 0;
+	pBTinfo->BtAsocEntry[EntryNum].rxSuvpPktCnt =3D 0;
+
+	for (j =3D 0; j < MAX_LOGICAL_LINK_NUM; j++)
+		bthci_ResetFlowSpec(padapter, EntryNum, j);
+
+	pBtMgnt->BTAuthCount =3D 0;
+	pBtMgnt->BTAsocCount =3D 0;
+	pBtMgnt->BTCurrentConnectType =3D BT_DISCONNECT;
+	pBtMgnt->BTReceiveConnectPkt =3D BT_DISCONNECT;
+
+	HALBT_RemoveKey(padapter, EntryNum);
+}
+
+static void bthci_RemoveEntryByEntryNum(struct rtw_adapter *padapter, =
u8 EntryNum)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	bthci_ResetEntry(padapter, EntryNum);
+
+	if (pBtMgnt->CurrentBTConnectionCnt > 0)
+		pBtMgnt->CurrentBTConnectionCnt--;
+
+	RTPRINT(FIOCTL, IOCTL_STATE, ("[BT Flag], CurrentBTConnectionCnt =3D =
%d!!\n",
+		pBtMgnt->CurrentBTConnectionCnt));
+
+	if (pBtMgnt->CurrentBTConnectionCnt > 0) {
+		pBtMgnt->BtOperationOn =3D true;
+	} else {
+		pBtMgnt->BtOperationOn =3D false;
+		RTPRINT(FIOCTL, IOCTL_STATE, ("[BT Flag], Bt Operation OFF!!\n"));
+	}
+
+	if (!pBtMgnt->BtOperationOn) {
+		del_timer_sync(&pBTInfo->BTHCIDiscardAclDataTimer);
+		del_timer_sync(&pBTInfo->BTBeaconTimer);
+		pBtMgnt->bStartSendSupervisionPkt =3D false;
+	}
+}
+
+static u8
+bthci_CommandCompleteHeader(
+	u8 *pbuf,
+	u16		OGF,
+	u16		OCF,
+	enum hci_status	status
+	)
+{
+	struct packet_irp_hcievent_data *PPacketIrpEvent =3D (struct packet_i=
rp_hcievent_data *)pbuf;
+	u8 NumHCI_Comm =3D 0x1;
+
+	PPacketIrpEvent->EventCode =3D HCI_EVENT_COMMAND_COMPLETE;
+	PPacketIrpEvent->Data[0] =3D NumHCI_Comm;	/* packet # */
+	PPacketIrpEvent->Data[1] =3D HCIOPCODELOW(OCF, OGF);
+	PPacketIrpEvent->Data[2] =3D HCIOPCODEHIGHT(OCF, OGF);
+
+	if (OGF =3D=3D OGF_EXTENSION) {
+		if (OCF =3D=3D HCI_SET_RSSI_VALUE) {
+			RTPRINT(FIOCTL, (IOCTL_BT_EVENT_PERIODICAL),
+				("[BT event], CommandComplete, Num_HCI_Comm =3D 0x%x, Opcode =3D 0=
x%02x%02x, status =3D 0x%x, OGF =3D 0x%x, OCF =3D 0x%x\n",
+				NumHCI_Comm, (HCIOPCODEHIGHT(OCF, OGF)), (HCIOPCODELOW(OCF, OGF)),=
 status, OGF, OCF));
+		} else {
+			RTPRINT(FIOCTL, (IOCTL_BT_HCICMD_EXT),
+				("[BT event], CommandComplete, Num_HCI_Comm =3D 0x%x, Opcode =3D 0=
x%02x%02x, status =3D 0x%x, OGF =3D 0x%x, OCF =3D 0x%x\n",
+				NumHCI_Comm, (HCIOPCODEHIGHT(OCF, OGF)), (HCIOPCODELOW(OCF, OGF)),=
 status, OGF, OCF));
+		}
+	} else {
+		RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO),
+			("[BT event], CommandComplete, Num_HCI_Comm =3D 0x%x, Opcode =3D 0x=
%02x%02x, status =3D 0x%x, OGF =3D 0x%x, OCF =3D 0x%x\n",
+			NumHCI_Comm, (HCIOPCODEHIGHT(OCF, OGF)), (HCIOPCODELOW(OCF, OGF)), =
status, OGF, OCF));
+	}
+	return 3;
+}
+
+static u8 bthci_ExtensionEventHeaderRtk(u8 *pbuf, u8 extensionEvent)
+{
+	struct packet_irp_hcievent_data *PPacketIrpEvent =3D (struct packet_i=
rp_hcievent_data *)pbuf;
+	PPacketIrpEvent->EventCode =3D HCI_EVENT_EXTENSION_RTK;
+	PPacketIrpEvent->Data[0] =3D extensionEvent;	/* extension event code =
*/
+
+	return 1;
+}
+
+static enum rt_status
+bthci_IndicateEvent(
+	struct rtw_adapter *padapter,
+	void		*pEvntData,
+	u32		dataLen
+	)
+{
+	enum rt_status	rt_status;
+
+	rt_status =3D PlatformIndicateBTEvent(padapter, pEvntData, dataLen);
+
+	return rt_status;
+}
+
+static void
+bthci_EventWriteRemoteAmpAssoc(
+	struct rtw_adapter *padapter,
+	enum hci_status	status,
+	u8 PLHandle
+	)
+{
+	u8 localBuf[TmpLocalBufSize] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	PlatformZeroMemory(&localBuf[0], TmpLocalBufSize);
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_STATUS_PARAMETERS,
+		HCI_WRITE_REMOTE_AMP_ASSOC,
+		status);
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("PhyLinkHandle =3D =
0x%x, status =3D %d\n", PLHandle, status));
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;		/* status */
+	pRetPar[1] =3D PLHandle;
+	len +=3D 2;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+}
+
+static void
+bthci_EventEnhancedFlushComplete(
+	struct rtw_adapter *padapter,
+	u16					LLH
+	)
+{
+	u8 localBuf[4] =3D "";
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	RTPRINT(FIOCTL, IOCTL_BT_EVENT, ("EventEnhancedFlushComplete, LLH =3D=
 0x%x\n", LLH));
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+	PPacketIrpEvent->EventCode =3D HCI_EVENT_ENHANCED_FLUSH_COMPLETE;
+	PPacketIrpEvent->Length =3D 2;
+	/* Logical link handle */
+	PPacketIrpEvent->Data[0] =3D TWOBYTE_LOWBYTE(LLH);
+	PPacketIrpEvent->Data[1] =3D TWOBYTE_HIGHTBYTE(LLH);
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, 4);
+}
+
+static void
+bthci_EventShortRangeModeChangeComplete(
+	struct rtw_adapter *padapter,
+	enum hci_status				HciStatus,
+	u8 		ShortRangeState,
+	u8 		EntryNum
+	)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u8 localBuf[5] =3D "";
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	if (!(pBtHciInfo->BTEventMaskPage2 & EMP2_HCI_EVENT_SHORT_RANGE_MODE_=
CHANGE_COMPLETE)) {
+		RTPRINT(FIOCTL, IOCTL_BT_EVENT,
+			("[BT event], Short Range Mode Change Complete, Ignore to send this=
 event due to event mask page 2\n"));
+		return;
+	}
+	RTPRINT(FIOCTL, IOCTL_BT_EVENT, ("[BT event], Short Range Mode Change=
 Complete, Status =3D %d\n , PLH =3D 0x%x\n, Short_Range_Mode_State =3D=
 0x%x\n",
+		HciStatus, pBTInfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtPhyLinkha=
ndle, ShortRangeState));
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+	PPacketIrpEvent->EventCode =3D HCI_EVENT_SHORT_RANGE_MODE_CHANGE_COMP=
LETE;
+	PPacketIrpEvent->Length =3D 3;
+	PPacketIrpEvent->Data[0] =3D HciStatus;
+	PPacketIrpEvent->Data[1] =3D pBTInfo->BtAsocEntry[EntryNum].PhyLinkCm=
dData.BtPhyLinkhandle;
+	PPacketIrpEvent->Data[2] =3D ShortRangeState;
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, 5);
+}
+
+static void bthci_EventSendFlowSpecModifyComplete(struct rtw_adapter *=
padapter,
+						  enum hci_status HciStatus,
+						  u16 logicHandle)
+{
+	u8 localBuf[5] =3D "";
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+
+	if (!(pBtHciInfo->BTEventMaskPage2 & EMP2_HCI_EVENT_FLOW_SPEC_MODIFY_=
COMPLETE)) {
+		RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO),
+			("[BT event], Flow Spec Modify Complete, Ignore to send this event =
due to event mask page 2\n"));
+		return;
+	}
+	RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO),
+		("[BT event], Flow Spec Modify Complete, status =3D 0x%x, LLH =3D 0x=
%x\n", HciStatus, logicHandle));
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+	PPacketIrpEvent->EventCode =3D HCI_EVENT_FLOW_SPEC_MODIFY_COMPLETE;
+	PPacketIrpEvent->Length =3D 3;
+
+	PPacketIrpEvent->Data[0] =3D HciStatus;
+	/* Logical link handle */
+	PPacketIrpEvent->Data[1] =3D TWOBYTE_LOWBYTE(logicHandle);
+	PPacketIrpEvent->Data[2] =3D TWOBYTE_HIGHTBYTE(logicHandle);
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, 5);
+}
+
+static void
+bthci_EventExtWifiScanNotify(
+	struct rtw_adapter *padapter,
+	u8 			scanType
+	)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	u8 len =3D 0;
+	u8 localBuf[7] =3D "";
+	u8 *pRetPar;
+	u8 *pu1Temp;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	if (!pBtMgnt->BtOperationOn)
+		return;
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_ExtensionEventHeaderRtk(&localBuf[0], HCI_EVENT_EXT_WI=
=46I_SCAN_NOTIFY);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pu1Temp =3D (u8 *)&pRetPar[0];
+	*pu1Temp =3D scanType;
+	len +=3D 1;
+
+	PPacketIrpEvent->Length =3D len;
+
+	if (bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2) =3D=3D RT_S=
TATUS_SUCCESS) {
+		RTPRINT(FIOCTL, IOCTL_BT_EVENT, ("[BT event], Wifi scan notify, scan=
 type =3D %d\n",
+			scanType));
+	}
+}
+
+static void
+bthci_EventAMPReceiverReport(
+	struct rtw_adapter *padapter,
+	u8 Reason
+	)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+
+	if (pBtHciInfo->bTestNeedReport) {
+		u8 localBuf[20] =3D "";
+		u32	*pu4Temp;
+		u16	*pu2Temp;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), (" HCI_EVENT_AMP_REC=
EIVER_REPORT\n"));
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+		PPacketIrpEvent->EventCode =3D HCI_EVENT_AMP_RECEIVER_REPORT;
+		PPacketIrpEvent->Length =3D 2;
+
+		PPacketIrpEvent->Data[0] =3D pBtHciInfo->TestCtrType;
+
+		PPacketIrpEvent->Data[1] =3D Reason;
+
+		pu4Temp =3D (u32 *)&PPacketIrpEvent->Data[2];
+		*pu4Temp =3D pBtHciInfo->TestEventType;
+
+		pu2Temp =3D (u16 *)&PPacketIrpEvent->Data[6];
+		*pu2Temp =3D pBtHciInfo->TestNumOfFrame;
+
+		pu2Temp =3D (u16 *)&PPacketIrpEvent->Data[8];
+		*pu2Temp =3D pBtHciInfo->TestNumOfErrFrame;
+
+		pu4Temp =3D (u32 *)&PPacketIrpEvent->Data[10];
+		*pu4Temp =3D pBtHciInfo->TestNumOfBits;
+
+		pu4Temp =3D (u32 *)&PPacketIrpEvent->Data[14];
+		*pu4Temp =3D pBtHciInfo->TestNumOfErrBits;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, 20);
+
+		/* Return to Idel state with RX and TX off. */
+
+	}
+
+	pBtHciInfo->TestNumOfFrame =3D 0x00;
+}
+
+static void
+bthci_EventChannelSelected(
+	struct rtw_adapter *padapter,
+	u8 	EntryNum
+	)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u8 localBuf[3] =3D "";
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	if (!(pBtHciInfo->BTEventMaskPage2 & EMP2_HCI_EVENT_CHANNEL_SELECT)) =
{
+		RTPRINT(FIOCTL, IOCTL_BT_EVENT,
+			("[BT event], Channel Selected, Ignore to send this event due to ev=
ent mask page 2\n"));
+		return;
+	}
+
+	RTPRINT(FIOCTL, IOCTL_BT_EVENT|IOCTL_STATE,
+		("[BT event], Channel Selected, PhyLinkHandle %d\n",
+		pBTInfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtPhyLinkhandle));
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+	PPacketIrpEvent->EventCode =3D HCI_EVENT_CHANNEL_SELECT;
+	PPacketIrpEvent->Length =3D 1;
+	PPacketIrpEvent->Data[0] =3D pBTInfo->BtAsocEntry[EntryNum].PhyLinkCm=
dData.BtPhyLinkhandle;
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, 3);
+}
+
+static void
+bthci_EventDisconnectPhyLinkComplete(
+	struct rtw_adapter *padapter,
+	enum hci_status				HciStatus,
+	enum hci_status				Reason,
+	u8 		EntryNum
+	)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u8 localBuf[5] =3D "";
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	if (!(pBtHciInfo->BTEventMaskPage2 & EMP2_HCI_EVENT_DISCONNECT_PHY_LI=
NK_COMPLETE)) {
+		RTPRINT(FIOCTL, IOCTL_BT_EVENT,
+			("[BT event], Disconnect Physical Link Complete, Ignore to send thi=
s event due to event mask page 2\n"));
+		return;
+	}
+	RTPRINT(FIOCTL, IOCTL_BT_EVENT,
+		("[BT event], Disconnect Physical Link Complete, Status =3D 0x%x, PL=
H =3D 0x%x Reason =3D 0x%x\n",
+		HciStatus, pBTInfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtPhyLinkha=
ndle, Reason));
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+	PPacketIrpEvent->EventCode =3D HCI_EVENT_DISCONNECT_PHY_LINK_COMPLETE=
;
+	PPacketIrpEvent->Length =3D 3;
+	PPacketIrpEvent->Data[0] =3D HciStatus;
+	PPacketIrpEvent->Data[1] =3D pBTInfo->BtAsocEntry[EntryNum].PhyLinkCm=
dData.BtPhyLinkhandle;
+	PPacketIrpEvent->Data[2] =3D Reason;
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, 5);
+}
+
+static void
+bthci_EventPhysicalLinkComplete(
+	struct rtw_adapter *padapter,
+	enum hci_status				HciStatus,
+	u8 		EntryNum,
+	u8 		PLHandle
+	)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	struct bt_dgb *pBtDbg =3D &pBTInfo->BtDbg;
+	u8 localBuf[4] =3D "";
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+	u8 PL_handle;
+
+	pBtMgnt->bPhyLinkInProgress =3D false;
+	pBtDbg->dbgHciInfo.hciCmdPhyLinkStatus =3D HciStatus;
+	if (!(pBtHciInfo->BTEventMaskPage2 & EMP2_HCI_EVENT_PHY_LINK_COMPLETE=
)) {
+		RTPRINT(FIOCTL, IOCTL_BT_EVENT,
+			("[BT event], Physical Link Complete, Ignore to send this event due=
 to event mask page 2\n"));
+		return;
+	}
+
+	if (EntryNum =3D=3D 0xff) {
+		/*  connection not started yet, just use the input physical link han=
dle to response. */
+		PL_handle =3D PLHandle;
+	} else {
+		/*  connection is under progress, use the phy link handle we recorde=
d. */
+		PL_handle  =3D pBTInfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtPhyLi=
nkhandle;
+		pBTInfo->BtAsocEntry[EntryNum].bNeedPhysLinkCompleteEvent =3D false;
+	}
+
+	RTPRINT(FIOCTL, IOCTL_BT_EVENT, ("[BT event], Physical Link Complete,=
 Status =3D 0x%x PhyLinkHandle =3D 0x%x\n", HciStatus,
+		PL_handle));
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+	PPacketIrpEvent->EventCode =3D HCI_EVENT_PHY_LINK_COMPLETE;
+	PPacketIrpEvent->Length =3D 2;
+
+	PPacketIrpEvent->Data[0] =3D HciStatus;
+	PPacketIrpEvent->Data[1] =3D PL_handle;
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, 4);
+
+}
+
+static void
+bthci_EventCommandStatus(
+	struct rtw_adapter *padapter,
+	u8 		OGF,
+	u16					OCF,
+	enum hci_status				HciStatus
+	)
+{
+
+	u8 localBuf[6] =3D "";
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+	u8 Num_Hci_Comm =3D 0x1;
+	RTPRINT(FIOCTL, IOCTL_BT_EVENT,
+		("[BT event], CommandStatus, Opcode =3D 0x%02x%02x, OGF =3D 0x%x,  O=
CF =3D 0x%x, Status =3D 0x%x, Num_HCI_COMM =3D 0x%x\n",
+		(HCIOPCODEHIGHT(OCF, OGF)), (HCIOPCODELOW(OCF, OGF)), OGF, OCF, HciS=
tatus, Num_Hci_Comm));
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+	PPacketIrpEvent->EventCode =3D HCI_EVENT_COMMAND_STATUS;
+	PPacketIrpEvent->Length =3D 4;
+	PPacketIrpEvent->Data[0] =3D HciStatus;	/* current pending */
+	PPacketIrpEvent->Data[1] =3D Num_Hci_Comm;	/* packet # */
+	PPacketIrpEvent->Data[2] =3D HCIOPCODELOW(OCF, OGF);
+	PPacketIrpEvent->Data[3] =3D HCIOPCODEHIGHT(OCF, OGF);
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, 6);
+
+}
+
+static void
+bthci_EventLogicalLinkComplete(
+	struct rtw_adapter *padapter,
+	enum hci_status				HciStatus,
+	u8 		PhyLinkHandle,
+	u16					LogLinkHandle,
+	u8 		LogLinkIndex,
+	u8 		EntryNum
+	)
+{
+/*PMGNT_INFO pMgntInfo =3D &padapter->MgntInfo; */
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u8 localBuf[7] =3D "";
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	if (!(pBtHciInfo->BTEventMaskPage2 & EMP2_HCI_EVENT_LOGICAL_LINK_COMP=
LETE)) {
+		RTPRINT(FIOCTL, IOCTL_BT_EVENT,
+			("[BT event], Logical Link Complete, Ignore to send this event due =
to event mask page 2\n"));
+		return;
+	}
+	RTPRINT(FIOCTL, IOCTL_BT_EVENT, ("[BT event], Logical Link Complete, =
PhyLinkHandle =3D 0x%x,  LogLinkHandle =3D 0x%x, Status =3D 0x%x\n",
+		PhyLinkHandle, LogLinkHandle, HciStatus));
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+	PPacketIrpEvent->EventCode =3D HCI_EVENT_LOGICAL_LINK_COMPLETE;
+	PPacketIrpEvent->Length =3D 5;
+
+	PPacketIrpEvent->Data[0] =3D HciStatus;/* status code */
+	/* Logical link handle */
+	PPacketIrpEvent->Data[1] =3D TWOBYTE_LOWBYTE(LogLinkHandle);
+	PPacketIrpEvent->Data[2] =3D TWOBYTE_HIGHTBYTE(LogLinkHandle);
+	/* Physical link handle */
+	PPacketIrpEvent->Data[3] =3D TWOBYTE_LOWBYTE(PhyLinkHandle);
+	/* corresponding Tx flow spec ID */
+	if (HciStatus =3D=3D HCI_STATUS_SUCCESS) {
+		PPacketIrpEvent->Data[4] =3D
+			pBTInfo->BtAsocEntry[EntryNum].LogLinkCmdData[LogLinkIndex].Tx_Flow=
_Spec.Identifier;
+	} else {
+		PPacketIrpEvent->Data[4] =3D 0x0;
+	}
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, 7);
+}
+
+static void
+bthci_EventDisconnectLogicalLinkComplete(
+	struct rtw_adapter *padapter,
+	enum hci_status				HciStatus,
+	u16					LogLinkHandle,
+	enum hci_status				Reason
+	)
+{
+	u8 localBuf[6] =3D "";
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	if (!(pBtHciInfo->BTEventMaskPage2 & EMP2_HCI_EVENT_DISCONNECT_LOGICA=
L_LINK_COMPLETE)) {
+		RTPRINT(FIOCTL, IOCTL_BT_EVENT, ("[BT event], Disconnect Logical Lin=
k Complete, Ignore to send this event due to event mask page 2\n"));
+		return;
+	}
+	RTPRINT(FIOCTL, IOCTL_BT_EVENT, ("[BT event], Disconnect Logical Link=
 Complete, Status =3D 0x%x, LLH =3D 0x%x Reason =3D 0x%x\n", HciStatus,=
 LogLinkHandle, Reason));
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+	PPacketIrpEvent->EventCode =3D HCI_EVENT_DISCONNECT_LOGICAL_LINK_COMP=
LETE;
+	PPacketIrpEvent->Length =3D 4;
+
+	PPacketIrpEvent->Data[0] =3D HciStatus;
+	/* Logical link handle */
+	PPacketIrpEvent->Data[1] =3D TWOBYTE_LOWBYTE(LogLinkHandle);
+	PPacketIrpEvent->Data[2] =3D TWOBYTE_HIGHTBYTE(LogLinkHandle);
+	/* Disconnect reason */
+	PPacketIrpEvent->Data[3] =3D Reason;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, 6);
+}
+
+static void
+bthci_EventFlushOccurred(
+	struct rtw_adapter *padapter,
+	u16					LogLinkHandle
+	)
+{
+	u8 localBuf[4] =3D "";
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+	RTPRINT(FIOCTL, IOCTL_BT_EVENT, ("bthci_EventFlushOccurred(), LLH =3D=
 0x%x\n", LogLinkHandle));
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+	PPacketIrpEvent->EventCode =3D HCI_EVENT_FLUSH_OCCRUED;
+	PPacketIrpEvent->Length =3D 2;
+	/* Logical link handle */
+	PPacketIrpEvent->Data[0] =3D TWOBYTE_LOWBYTE(LogLinkHandle);
+	PPacketIrpEvent->Data[1] =3D TWOBYTE_HIGHTBYTE(LogLinkHandle);
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, 4);
+}
+
+static enum hci_status
+bthci_BuildPhysicalLink(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd,
+	u16	OCF
+)
+{
+	enum hci_status		status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	u8 EntryNum, PLH;
+
+	/* Send HCI Command status event to AMP. */
+	bthci_EventCommandStatus(padapter,
+			LINK_CONTROL_COMMANDS,
+			OCF,
+			HCI_STATUS_SUCCESS);
+
+	PLH =3D *((u8 *)pHciCmd->Data);
+
+	/*  Check if resource or bt connection is under progress, if yes, rej=
ect the link creation. */
+	if (!bthci_AddEntry(padapter)) {
+		status =3D HCI_STATUS_CONNECT_RJT_LIMIT_RESOURCE;
+		bthci_EventPhysicalLinkComplete(padapter, status, INVALID_ENTRY_NUM,=
 PLH);
+		return status;
+	}
+
+	EntryNum =3D pBtMgnt->CurrentConnectEntryNum;
+	pBTInfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtPhyLinkhandle =3D PLH=
;
+	pBtMgnt->BtCurrentPhyLinkhandle =3D PLH;
+
+	if (pBTInfo->BtAsocEntry[EntryNum].AmpAsocCmdData.AMPAssocfragment =3D=
=3D NULL) {
+		RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("Create/Accept Phy=
sicalLink, AMP controller is busy\n"));
+		status =3D HCI_STATUS_CONTROLLER_BUSY;
+		bthci_EventPhysicalLinkComplete(padapter, status, INVALID_ENTRY_NUM,=
 PLH);
+		return status;
+	}
+
+	/*  Record Key and the info */
+	pBTInfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtAMPKeyLen =3D (*((u8 =
*)pHciCmd->Data+1));
+	pBTInfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtAMPKeyType =3D (*((u8=
 *)pHciCmd->Data+2));
+	memcpy(pBTInfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtAMPKey,
+		(((u8 *)pHciCmd->Data+3)), pBTInfo->BtAsocEntry[EntryNum].PhyLinkCmd=
Data.BtAMPKeyLen);
+	memcpy(pBTInfo->BtAsocEntry[EntryNum].PMK, pBTInfo->BtAsocEntry[Entry=
Num].PhyLinkCmdData.BtAMPKey, PMK_LEN);
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("BuildPhysicalLink, EntryNum =3D %d=
, PLH =3D 0x%x  KeyLen =3D 0x%x, KeyType =3D 0x%x\n",
+		EntryNum, pBTInfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtPhyLinkhan=
dle,
+		pBTInfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtAMPKeyLen,
+		pBTInfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtAMPKeyType));
+	RTPRINT_DATA(FIOCTL, (IOCTL_BT_LOGO|IOCTL_BT_HCICMD), ("BtAMPKey\n"),=
 pBTInfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtAMPKey,
+		pBTInfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtAMPKeyLen);
+	RTPRINT_DATA(FIOCTL, (IOCTL_BT_LOGO|IOCTL_BT_HCICMD), ("PMK\n"), pBTI=
nfo->BtAsocEntry[EntryNum].PMK,
+		PMK_LEN);
+
+	if (OCF =3D=3D HCI_CREATE_PHYSICAL_LINK) {
+		/* These macros require braces */
+		BTHCI_SM_WITH_INFO(padapter, HCI_STATE_DISCONNECTED, STATE_CMD_CREAT=
E_PHY_LINK, EntryNum);
+	} else if (OCF =3D=3D HCI_ACCEPT_PHYSICAL_LINK) {
+		BTHCI_SM_WITH_INFO(padapter, HCI_STATE_DISCONNECTED, STATE_CMD_ACCEP=
T_PHY_LINK, EntryNum);
+	}
+
+	return status;
+}
+
+static void
+bthci_BuildLogicalLink(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd,
+	u16 OCF
+	)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTinfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTinfo->BtMgnt;
+	u8 PhyLinkHandle, EntryNum;
+	static u16 AssignLogHandle =3D 1;
+
+	struct hci_flow_spec	TxFlowSpec;
+	struct hci_flow_spec	RxFlowSpec;
+	u32	MaxSDUSize, ArriveTime, Bandwidth;
+
+	PhyLinkHandle =3D *((u8 *)pHciCmd->Data);
+
+	EntryNum =3D bthci_GetCurrentEntryNum(padapter, PhyLinkHandle);
+
+	memcpy(&TxFlowSpec,
+		&pHciCmd->Data[1], sizeof(struct hci_flow_spec));
+	memcpy(&RxFlowSpec,
+		&pHciCmd->Data[17], sizeof(struct hci_flow_spec));
+
+	MaxSDUSize =3D TxFlowSpec.MaximumSDUSize;
+	ArriveTime =3D TxFlowSpec.SDUInterArrivalTime;
+
+	if (bthci_CheckLogLinkBehavior(padapter, TxFlowSpec) && bthci_CheckLo=
gLinkBehavior(padapter, RxFlowSpec))
+		Bandwidth =3D BTTOTALBANDWIDTH;
+	else if (MaxSDUSize =3D=3D 0xffff && ArriveTime =3D=3D 0xffffffff)
+		Bandwidth =3D BTTOTALBANDWIDTH;
+	else
+		Bandwidth =3D MaxSDUSize*8*1000/(ArriveTime+244);
+
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD,
+		("BuildLogicalLink, PhyLinkHandle =3D 0x%x, MaximumSDUSize =3D 0x%x,=
 SDUInterArrivalTime =3D 0x%x, Bandwidth =3D 0x%x\n",
+		PhyLinkHandle, MaxSDUSize, ArriveTime, Bandwidth));
+
+	if (EntryNum =3D=3D 0xff) {
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("Invalid Physical Link handle =3D =
0x%x, status =3D HCI_STATUS_UNKNOW_CONNECT_ID, return\n", PhyLinkHandle=
));
+		status =3D HCI_STATUS_UNKNOW_CONNECT_ID;
+
+		/* When we receive Create/Accept logical link command, we should sen=
d command status event first. */
+		bthci_EventCommandStatus(padapter,
+			LINK_CONTROL_COMMANDS,
+			OCF,
+			status);
+		return;
+	}
+
+	if (!pBtMgnt->bLogLinkInProgress) {
+		if (bthci_PhyLinkConnectionInProgress(padapter, PhyLinkHandle)) {
+			RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("Physical link connection in prog=
ress, status =3D HCI_STATUS_CMD_DISALLOW, return\n"));
+			status =3D HCI_STATUS_CMD_DISALLOW;
+
+			pBtMgnt->bPhyLinkInProgressStartLL =3D true;
+			/* When we receive Create/Accept logical link command, we should se=
nd command status event first. */
+			bthci_EventCommandStatus(padapter,
+				LINK_CONTROL_COMMANDS,
+				OCF,
+				status);
+
+			return;
+		}
+
+		if (Bandwidth > BTTOTALBANDWIDTH) {
+			RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("status =3D HCI_STATUS_QOS_REJECT=
, Bandwidth =3D 0x%x, return\n", Bandwidth));
+			status =3D HCI_STATUS_QOS_REJECT;
+
+			/* When we receive Create/Accept logical link command, we should se=
nd command status event first. */
+			bthci_EventCommandStatus(padapter,
+				LINK_CONTROL_COMMANDS,
+				OCF,
+				status);
+		} else {
+			RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("status =3D HCI_STATUS_SUCCESS\n"=
));
+			status =3D HCI_STATUS_SUCCESS;
+
+			/* When we receive Create/Accept logical link command, we should se=
nd command status event first. */
+			bthci_EventCommandStatus(padapter,
+				LINK_CONTROL_COMMANDS,
+				OCF,
+				status);
+
+		}
+
+		if (pBTinfo->BtAsocEntry[EntryNum].BtCurrentState !=3D HCI_STATE_CON=
NECTED) {
+			bthci_EventLogicalLinkComplete(padapter,
+				HCI_STATUS_CMD_DISALLOW, 0, 0, 0, EntryNum);
+		} else {
+			u8 i, find =3D 0;
+
+			pBtMgnt->bLogLinkInProgress =3D true;
+
+			/*  find an unused logical link index and copy the data */
+			for (i =3D 0; i < MAX_LOGICAL_LINK_NUM; i++) {
+				if (pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[i].BtLogLinkhand=
le =3D=3D 0) {
+					enum hci_status LogCompEventstatus =3D HCI_STATUS_SUCCESS;
+
+					pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[i].BtPhyLinkhandle =
=3D *((u8 *)pHciCmd->Data);
+					pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[i].BtLogLinkhandle =
=3D AssignLogHandle;
+					RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("BuildLogicalLink, EntryNum =3D=
 %d, physical link handle =3D 0x%x, logical link handle =3D 0x%x\n",
+						EntryNum, pBTinfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtPhyLin=
khandle,
+								  pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[i].BtLogLinkha=
ndle));
+					memcpy(&pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[i].Tx_Flow_=
Spec,
+						&TxFlowSpec, sizeof(struct hci_flow_spec));
+					memcpy(&pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[i].Rx_Flow_=
Spec,
+						&RxFlowSpec, sizeof(struct hci_flow_spec));
+
+					pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[i].bLLCompleteEvent=
IsSet =3D false;
+
+					if (pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[i].bLLCancelCMD=
IsSetandComplete)
+						LogCompEventstatus =3D HCI_STATUS_UNKNOW_CONNECT_ID;
+					bthci_EventLogicalLinkComplete(padapter,
+						LogCompEventstatus,
+						pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[i].BtPhyLinkhandle=
,
+						pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[i].BtLogLinkhandle=
, i, EntryNum);
+
+					pBTinfo->BtAsocEntry[EntryNum].LogLinkCmdData[i].bLLCompleteEvent=
IsSet =3D true;
+
+					find =3D 1;
+					pBtMgnt->BtCurrentLogLinkhandle =3D AssignLogHandle;
+					AssignLogHandle++;
+					break;
+				}
+			}
+
+			if (!find) {
+				bthci_EventLogicalLinkComplete(padapter,
+					HCI_STATUS_CONNECT_RJT_LIMIT_RESOURCE, 0, 0, 0, EntryNum);
+			}
+			pBtMgnt->bLogLinkInProgress =3D false;
+		}
+	} else {
+		bthci_EventLogicalLinkComplete(padapter,
+			HCI_STATUS_CONTROLLER_BUSY, 0, 0, 0, EntryNum);
+	}
+
+}
+
+static void
+bthci_StartBeaconAndConnect(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd,
+	u8 CurrentAssocNum
+	)
+{
+/*PMGNT_INFO pMgntInfo =3D &padapter->MgntInfo; */
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("StartBeaconAndConnect, CurrentAsso=
cNum =3D%d, AMPRole =3D%d\n",
+		CurrentAssocNum,
+		pBTInfo->BtAsocEntry[CurrentAssocNum].AMPRole));
+
+	if (!pBtMgnt->CheckChnlIsSuit) {
+		bthci_EventPhysicalLinkComplete(padapter, HCI_STATUS_CONNECT_REJ_NOT=
_SUIT_CHNL_FOUND, CurrentAssocNum, INVALID_PL_HANDLE);
+		bthci_RemoveEntryByEntryNum(padapter, CurrentAssocNum);
+		return;
+	}
+
+	if (pBTInfo->BtAsocEntry[CurrentAssocNum].AMPRole =3D=3D AMP_BTAP_CRE=
ATOR) {
+		rsprintf((char *)pBTInfo->BtAsocEntry[CurrentAssocNum].BTSsidBuf, 32=
, "AMP-%02x-%02x-%02x-%02x-%02x-%02x",
+		padapter->eeprompriv.mac_addr[0],
+		padapter->eeprompriv.mac_addr[1],
+		padapter->eeprompriv.mac_addr[2],
+		padapter->eeprompriv.mac_addr[3],
+		padapter->eeprompriv.mac_addr[4],
+		padapter->eeprompriv.mac_addr[5]);
+	} else if (pBTInfo->BtAsocEntry[CurrentAssocNum].AMPRole =3D=3D AMP_B=
TAP_JOINER) {
+		rsprintf((char *)pBTInfo->BtAsocEntry[CurrentAssocNum].BTSsidBuf, 32=
, "AMP-%02x-%02x-%02x-%02x-%02x-%02x",
+		pBTInfo->BtAsocEntry[CurrentAssocNum].BTRemoteMACAddr[0],
+		pBTInfo->BtAsocEntry[CurrentAssocNum].BTRemoteMACAddr[1],
+		pBTInfo->BtAsocEntry[CurrentAssocNum].BTRemoteMACAddr[2],
+		pBTInfo->BtAsocEntry[CurrentAssocNum].BTRemoteMACAddr[3],
+		pBTInfo->BtAsocEntry[CurrentAssocNum].BTRemoteMACAddr[4],
+		pBTInfo->BtAsocEntry[CurrentAssocNum].BTRemoteMACAddr[5]);
+	}
+
+	FillOctetString(pBTInfo->BtAsocEntry[CurrentAssocNum].BTSsid, pBTInfo=
->BtAsocEntry[CurrentAssocNum].BTSsidBuf, 21);
+	pBTInfo->BtAsocEntry[CurrentAssocNum].BTSsid.Length =3D 21;
+
+	/* To avoid set the start ap or connect twice, or the original connec=
tion will be disconnected. */
+	if (!pBtMgnt->bBTConnectInProgress) {
+		pBtMgnt->bBTConnectInProgress =3D true;
+		RTPRINT(FIOCTL, IOCTL_STATE, ("[BT Flag], BT Connect in progress ON!=
!\n"));
+		BTHCI_SM_WITH_INFO(padapter, HCI_STATE_STARTING, STATE_CMD_MAC_START=
_COMPLETE, CurrentAssocNum);
+
+		/*  20100325 Joseph: Check RF ON/OFF. */
+		/*  If RF OFF, it reschedule connecting operation after 50ms. */
+		if (!bthci_CheckRfStateBeforeConnect(padapter))
+			return;
+
+		if (pBTInfo->BtAsocEntry[CurrentAssocNum].AMPRole =3D=3D AMP_BTAP_CR=
EATOR) {
+			/* These macros need braces */
+			BTHCI_SM_WITH_INFO(padapter, HCI_STATE_CONNECTING, STATE_CMD_MAC_CO=
NNECT_COMPLETE, CurrentAssocNum);
+		} else if (pBTInfo->BtAsocEntry[CurrentAssocNum].AMPRole =3D=3D AMP_=
BTAP_JOINER) {
+			bthci_ResponderStartToScan(padapter);
+		}
+	}
+	RT_PRINT_STR(_module_rtl871x_mlme_c_, _drv_notice_,
+		     "StartBeaconAndConnect, SSID:\n",
+		     pBTInfo->BtAsocEntry[pBtMgnt->CurrentConnectEntryNum].BTSsid.Oc=
tet,
+		     pBTInfo->BtAsocEntry[pBtMgnt->CurrentConnectEntryNum].BTSsid.Le=
ngth);
+}
+
+static void bthci_ResetBtMgnt(struct bt_mgnt *pBtMgnt)
+{
+	pBtMgnt->BtOperationOn =3D false;
+	pBtMgnt->bBTConnectInProgress =3D false;
+	pBtMgnt->bLogLinkInProgress =3D false;
+	pBtMgnt->bPhyLinkInProgress =3D false;
+	pBtMgnt->bPhyLinkInProgressStartLL =3D false;
+	pBtMgnt->DisconnectEntryNum =3D 0xff;
+	pBtMgnt->bStartSendSupervisionPkt =3D false;
+	pBtMgnt->JoinerNeedSendAuth =3D false;
+	pBtMgnt->CurrentBTConnectionCnt =3D 0;
+	pBtMgnt->BTCurrentConnectType =3D BT_DISCONNECT;
+	pBtMgnt->BTReceiveConnectPkt =3D BT_DISCONNECT;
+	pBtMgnt->BTAuthCount =3D 0;
+	pBtMgnt->btLogoTest =3D 0;
+}
+
+static void bthci_ResetBtHciInfo(struct bt_hci_info *pBtHciInfo)
+{
+	pBtHciInfo->BTEventMask =3D 0;
+	pBtHciInfo->BTEventMaskPage2 =3D 0;
+	pBtHciInfo->ConnAcceptTimeout =3D  10000;
+	pBtHciInfo->PageTimeout  =3D  0x30;
+	pBtHciInfo->LocationDomainAware =3D 0x0;
+	pBtHciInfo->LocationDomain =3D 0x5858;
+	pBtHciInfo->LocationDomainOptions =3D 0x58;
+	pBtHciInfo->LocationOptions =3D 0x0;
+	pBtHciInfo->FlowControlMode =3D 0x1;	/*  0:Packet based data flow con=
trol mode(BR/EDR), 1: Data block based data flow control mode(AMP). */
+
+	pBtHciInfo->enFlush_LLH =3D 0;
+	pBtHciInfo->FLTO_LLH =3D 0;
+
+	/* Test command only */
+	pBtHciInfo->bTestIsEnd =3D true;
+	pBtHciInfo->bInTestMode =3D false;
+	pBtHciInfo->bTestNeedReport =3D false;
+	pBtHciInfo->TestScenario =3D 0xff;
+	pBtHciInfo->TestReportInterval =3D 0x01;
+	pBtHciInfo->TestCtrType =3D 0x5d;
+	pBtHciInfo->TestEventType =3D 0x00;
+	pBtHciInfo->TestNumOfFrame =3D 0;
+	pBtHciInfo->TestNumOfErrFrame =3D 0;
+	pBtHciInfo->TestNumOfBits =3D 0;
+	pBtHciInfo->TestNumOfErrBits =3D 0;
+}
+
+static void bthci_ResetBtSec(struct rtw_adapter *padapter, struct bt_s=
ecurity *pBtSec)
+{
+/*PMGNT_INFO	pMgntInfo =3D &padapter->MgntInfo; */
+
+	/*  Set BT used HW or SW encrypt !! */
+	if (GET_HAL_DATA(padapter)->bBTMode)
+		pBtSec->bUsedHwEncrypt =3D true;
+	else
+		pBtSec->bUsedHwEncrypt =3D false;
+	RT_TRACE(_module_rtl871x_security_c_, _drv_info_, ("%s: bUsedHwEncryp=
t =3D%d\n", __func__, pBtSec->bUsedHwEncrypt));
+
+	pBtSec->RSNIE.Octet =3D pBtSec->RSNIEBuf;
+}
+
+static void bthci_ResetBtExtInfo(struct bt_mgnt *pBtMgnt)
+{
+	u8 i;
+
+	for (i =3D 0; i < MAX_BT_ASOC_ENTRY_NUM; i++) {
+		pBtMgnt->ExtConfig.linkInfo[i].ConnectHandle =3D 0;
+		pBtMgnt->ExtConfig.linkInfo[i].IncomingTrafficMode =3D 0;
+		pBtMgnt->ExtConfig.linkInfo[i].OutgoingTrafficMode =3D 0;
+		pBtMgnt->ExtConfig.linkInfo[i].BTProfile =3D BT_PROFILE_NONE;
+		pBtMgnt->ExtConfig.linkInfo[i].BTCoreSpec =3D BT_SPEC_2_1_EDR;
+		pBtMgnt->ExtConfig.linkInfo[i].BT_RSSI =3D 0;
+		pBtMgnt->ExtConfig.linkInfo[i].TrafficProfile =3D BT_PROFILE_NONE;
+		pBtMgnt->ExtConfig.linkInfo[i].linkRole =3D BT_LINK_MASTER;
+	}
+
+	pBtMgnt->ExtConfig.CurrentConnectHandle =3D 0;
+	pBtMgnt->ExtConfig.CurrentIncomingTrafficMode =3D 0;
+	pBtMgnt->ExtConfig.CurrentOutgoingTrafficMode =3D 0;
+	pBtMgnt->ExtConfig.MIN_BT_RSSI =3D 0;
+	pBtMgnt->ExtConfig.NumberOfHandle =3D 0;
+	pBtMgnt->ExtConfig.NumberOfSCO =3D 0;
+	pBtMgnt->ExtConfig.CurrentBTStatus =3D 0;
+	pBtMgnt->ExtConfig.HCIExtensionVer =3D 0;
+
+	pBtMgnt->ExtConfig.bManualControl =3D false;
+	pBtMgnt->ExtConfig.bBTBusy =3D false;
+	pBtMgnt->ExtConfig.bBTA2DPBusy =3D false;
+}
+
+static enum hci_status bthci_CmdReset(struct rtw_adapter *_padapter, u=
8 bNeedSendEvent)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct rtw_adapter *padapter;
+/*PMGNT_INFO pMgntInfo =3D &padapter->MgntInfo; */
+	struct bt_30info *pBTInfo;
+	struct bt_mgnt *pBtMgnt;
+	struct bt_hci_info *pBtHciInfo;
+	struct bt_security *pBtSec;
+	struct bt_dgb *pBtDbg;
+	u8 i;
+
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("bthci_CmdReset()\n"));
+
+	padapter =3D GetDefaultAdapter(_padapter);
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtMgnt =3D &pBTInfo->BtMgnt;
+	pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	pBtSec =3D &pBTInfo->BtSec;
+	pBtDbg =3D &pBTInfo->BtDbg;
+
+	pBTInfo->padapter =3D padapter;
+
+	for (i =3D 0; i < MAX_BT_ASOC_ENTRY_NUM; i++)
+		bthci_ResetEntry(padapter, i);
+
+	bthci_ResetBtMgnt(pBtMgnt);
+	bthci_ResetBtHciInfo(pBtHciInfo);
+	bthci_ResetBtSec(padapter, pBtSec);
+
+	pBtMgnt->BTChannel =3D BT_Default_Chnl;
+	pBtMgnt->CheckChnlIsSuit =3D true;
+
+	pBTInfo->BTBeaconTmrOn =3D false;
+
+	pBtMgnt->bCreateSpportQos =3D true;
+
+	del_timer_sync(&pBTInfo->BTHCIDiscardAclDataTimer);
+	del_timer_sync(&pBTInfo->BTBeaconTimer);
+
+	HALBT_SetRtsCtsNoLenLimit(padapter);
+	/*  */
+	/*  Maybe we need to take care Group !=3D AES case !! */
+	/*  now we Pairwise and Group all used AES !! */
+
+	bthci_ResetBtExtInfo(pBtMgnt);
+
+	/* send command complete event here when all data are received. */
+	if (bNeedSendEvent) {
+		u8 localBuf[6] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_SET_EVENT_MASK_COMMAND,
+			HCI_RESET,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;		/* status */
+		len +=3D 1;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdWriteRemoteAMPAssoc(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_dgb *pBtDbg =3D &pBTInfo->BtDbg;
+	u8 CurrentAssocNum;
+	u8 PhyLinkHandle;
+
+	pBtDbg->dbgHciInfo.hciCmdCntWriteRemoteAmpAssoc++;
+	PhyLinkHandle =3D *((u8 *)pHciCmd->Data);
+	CurrentAssocNum =3D bthci_GetCurrentEntryNum(padapter, PhyLinkHandle)=
;
+
+	if (CurrentAssocNum =3D=3D 0xff) {
+		RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("WriteRemoteAMPAss=
oc, No such Handle in the Entry\n"));
+		status =3D HCI_STATUS_UNKNOW_CONNECT_ID;
+		bthci_EventWriteRemoteAmpAssoc(padapter, status, PhyLinkHandle);
+		return status;
+	}
+
+	if (pBTInfo->BtAsocEntry[CurrentAssocNum].AmpAsocCmdData.AMPAssocfrag=
ment =3D=3D NULL) {
+		RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("WriteRemoteAMPAss=
oc, AMP controller is busy\n"));
+		status =3D HCI_STATUS_CONTROLLER_BUSY;
+		bthci_EventWriteRemoteAmpAssoc(padapter, status, PhyLinkHandle);
+		return status;
+	}
+
+	pBTInfo->BtAsocEntry[CurrentAssocNum].AmpAsocCmdData.BtPhyLinkhandle =
=3D PhyLinkHandle;/* u8 *)pHciCmd->Data); */
+	pBTInfo->BtAsocEntry[CurrentAssocNum].AmpAsocCmdData.LenSoFar =3D *((=
u16 *)((u8 *)pHciCmd->Data+1));
+	pBTInfo->BtAsocEntry[CurrentAssocNum].AmpAsocCmdData.AMPAssocRemLen =3D=
 *((u16 *)((u8 *)pHciCmd->Data+3));
+
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD_DETAIL|IOCTL_BT_LOGO), ("WriteRemote=
AMPAssoc, LenSoFar =3D 0x%x, AssocRemLen =3D 0x%x\n",
+		pBTInfo->BtAsocEntry[CurrentAssocNum].AmpAsocCmdData.LenSoFar,
+		pBTInfo->BtAsocEntry[CurrentAssocNum].AmpAsocCmdData.AMPAssocRemLen)=
);
+
+	RTPRINT_DATA(FIOCTL, (IOCTL_BT_HCICMD_DETAIL|IOCTL_BT_LOGO),
+		     ("WriteRemoteAMPAssoc fragment \n"),
+		     pHciCmd->Data,
+		     pBTInfo->BtAsocEntry[CurrentAssocNum].AmpAsocCmdData.AMPAssocRe=
mLen+5);
+	if ((pBTInfo->BtAsocEntry[CurrentAssocNum].AmpAsocCmdData.AMPAssocRem=
Len) > MAX_AMP_ASSOC_FRAG_LEN) {
+		memcpy(((u8 *)pBTInfo->BtAsocEntry[CurrentAssocNum].AmpAsocCmdData.A=
MPAssocfragment+(pBTInfo->BtAsocEntry[CurrentAssocNum].AmpAsocCmdData.L=
enSoFar*(sizeof(u8)))),
+			(u8 *)pHciCmd->Data+5,
+			MAX_AMP_ASSOC_FRAG_LEN);
+	} else {
+		memcpy((u8 *)(pBTInfo->BtAsocEntry[CurrentAssocNum].AmpAsocCmdData.A=
MPAssocfragment)+(pBTInfo->BtAsocEntry[CurrentAssocNum].AmpAsocCmdData.=
LenSoFar*(sizeof(u8))),
+			((u8 *)pHciCmd->Data+5),
+			(pBTInfo->BtAsocEntry[CurrentAssocNum].AmpAsocCmdData.AMPAssocRemLe=
n));
+
+		RTPRINT_DATA(FIOCTL, (IOCTL_BT_HCICMD_DETAIL|IOCTL_BT_LOGO), "WriteR=
emoteAMPAssoc :\n",
+			pHciCmd->Data+5, pBTInfo->BtAsocEntry[CurrentAssocNum].AmpAsocCmdDa=
ta.AMPAssocRemLen);
+
+		if (!bthci_GetAssocInfo(padapter, CurrentAssocNum))
+			status =3D HCI_STATUS_INVALID_HCI_CMD_PARA_VALUE;
+
+		bthci_EventWriteRemoteAmpAssoc(padapter, status, PhyLinkHandle);
+
+		bthci_StartBeaconAndConnect(padapter, pHciCmd, CurrentAssocNum);
+	}
+
+	return status;
+}
+
+/* 7.3.13 */
+static enum hci_status bthci_CmdReadConnectionAcceptTimeout(struct rtw=
_adapter *padapter)
+{
+	enum hci_status		status =3D HCI_STATUS_SUCCESS;
+/*PMGNT_INFO		pMgntInfo =3D &padapter->MgntInfo; */
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u8 localBuf[8] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+	u16 *pu2Temp;
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_SET_EVENT_MASK_COMMAND,
+		HCI_READ_CONNECTION_ACCEPT_TIMEOUT,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;		/* status */
+	pu2Temp =3D (u16 *)&pRetPar[1];		/*  Conn_Accept_Timeout */
+	*pu2Temp =3D pBtHciInfo->ConnAcceptTimeout;
+	len +=3D 3;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+
+	return status;
+}
+
+/* 7.3.3 */
+static enum hci_status
+bthci_CmdSetEventFilter(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+
+	return status;
+}
+
+/* 7.3.14 */
+static enum hci_status
+bthci_CmdWriteConnectionAcceptTimeout(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status		status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u16	*pu2Temp;
+	u8 localBuf[6] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	pu2Temp =3D (u16 *)&pHciCmd->Data[0];
+	pBtHciInfo->ConnAcceptTimeout =3D *pu2Temp;
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD_DETAIL, ("ConnAcceptTimeout =3D 0x%x"=
,
+		pBtHciInfo->ConnAcceptTimeout));
+
+	/* send command complete event here when all data are received. */
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_SET_EVENT_MASK_COMMAND,
+		HCI_WRITE_CONNECTION_ACCEPT_TIMEOUT,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;		/* status */
+	len +=3D 1;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdReadPageTimeout(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status		status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u8 localBuf[8] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+	u16 *pu2Temp;
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_SET_EVENT_MASK_COMMAND,
+		HCI_READ_PAGE_TIMEOUT,
+		status);
+
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("Read PageTimeout =3D 0x%x\n", pBtH=
ciInfo->PageTimeout));
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;		/* status */
+	pu2Temp =3D (u16 *)&pRetPar[1];		/*  Page_Timeout */
+	*pu2Temp =3D pBtHciInfo->PageTimeout;
+	len +=3D 3;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdWritePageTimeout(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status		status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u16	*pu2Temp;
+
+	pu2Temp =3D (u16 *)&pHciCmd->Data[0];
+	pBtHciInfo->PageTimeout =3D *pu2Temp;
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("Write PageTimeout =3D 0x%x\n",
+		pBtHciInfo->PageTimeout));
+
+	/* send command complete event here when all data are received. */
+	{
+		u8 localBuf[6] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_SET_EVENT_MASK_COMMAND,
+			HCI_WRITE_PAGE_TIMEOUT,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;		/* status */
+		len +=3D 1;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdReadLinkSupervisionTimeout(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status	status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTinfo =3D GET_BT_INFO(padapter);
+	u8 physicalLinkHandle, EntryNum;
+
+	physicalLinkHandle =3D *((u8 *)pHciCmd->Data);
+
+	EntryNum =3D bthci_GetCurrentEntryNum(padapter, physicalLinkHandle);
+
+	if (EntryNum =3D=3D 0xff) {
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("ReadLinkSupervisionTimeout, No su=
ch Handle in the Entry\n"));
+		status =3D HCI_STATUS_UNKNOW_CONNECT_ID;
+		return status;
+	}
+
+	if (pBTinfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtPhyLinkhandle !=3D=
 physicalLinkHandle)
+		status =3D HCI_STATUS_UNKNOW_CONNECT_ID;
+
+	{
+		u8 localBuf[10] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+		u16 *pu2Temp;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_SET_EVENT_MASK_COMMAND,
+			HCI_READ_LINK_SUPERVISION_TIMEOUT,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;
+		pRetPar[1] =3D pBTinfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtPhyLi=
nkhandle;
+		pRetPar[2] =3D 0;
+		pu2Temp =3D (u16 *)&pRetPar[3];		/*  Conn_Accept_Timeout */
+		*pu2Temp =3D pBTinfo->BtAsocEntry[EntryNum].PhyLinkCmdData.LinkSuper=
versionTimeout;
+		len +=3D 5;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdWriteLinkSupervisionTimeout(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status	status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTinfo =3D GET_BT_INFO(padapter);
+	u8 physicalLinkHandle, EntryNum;
+
+	physicalLinkHandle =3D *((u8 *)pHciCmd->Data);
+
+	EntryNum =3D bthci_GetCurrentEntryNum(padapter, physicalLinkHandle);
+
+	if (EntryNum =3D=3D 0xff) {
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("WriteLinkSupervisionTimeout, No s=
uch Handle in the Entry\n"));
+		status =3D HCI_STATUS_UNKNOW_CONNECT_ID;
+	} else {
+		if (pBTinfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtPhyLinkhandle !=3D=
 physicalLinkHandle) {
+			status =3D HCI_STATUS_UNKNOW_CONNECT_ID;
+		} else {
+			pBTinfo->BtAsocEntry[EntryNum].PhyLinkCmdData.LinkSuperversionTimeo=
ut =3D *((u16 *)(((u8 *)pHciCmd->Data)+2));
+			RTPRINT(FIOCTL, IOCTL_STATE, ("BT Write LinkSuperversionTimeout[%d]=
 =3D 0x%x\n",
+				EntryNum, pBTinfo->BtAsocEntry[EntryNum].PhyLinkCmdData.LinkSuperv=
ersionTimeout));
+		}
+	}
+
+	{
+		u8 localBuf[8] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_SET_EVENT_MASK_COMMAND,
+			HCI_WRITE_LINK_SUPERVISION_TIMEOUT,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;
+		pRetPar[1] =3D pBTinfo->BtAsocEntry[EntryNum].PhyLinkCmdData.BtPhyLi=
nkhandle;
+		pRetPar[2] =3D 0;
+		len +=3D 3;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdEnhancedFlush(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status		status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTinfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTinfo->BtHciInfo;
+	u16		logicHandle;
+	u8 Packet_Type;
+
+	logicHandle =3D *((u16 *)&pHciCmd->Data[0]);
+	Packet_Type =3D pHciCmd->Data[2];
+
+	if (Packet_Type !=3D 0)
+		status =3D HCI_STATUS_INVALID_HCI_CMD_PARA_VALUE;
+	else
+		pBtHciInfo->enFlush_LLH =3D logicHandle;
+
+	if (bthci_DiscardTxPackets(padapter, pBtHciInfo->enFlush_LLH))
+		bthci_EventFlushOccurred(padapter, pBtHciInfo->enFlush_LLH);
+
+	/*  should send command status event */
+	bthci_EventCommandStatus(padapter,
+			OGF_SET_EVENT_MASK_COMMAND,
+			HCI_ENHANCED_FLUSH,
+			status);
+
+	if (pBtHciInfo->enFlush_LLH) {
+		bthci_EventEnhancedFlushComplete(padapter, pBtHciInfo->enFlush_LLH);
+		pBtHciInfo->enFlush_LLH =3D 0;
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdReadLogicalLinkAcceptTimeout(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status		status =3D HCI_STATUS_SUCCESS;
+/*PMGNT_INFO		pMgntInfo =3D &padapter->MgntInfo; */
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u8 localBuf[8] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+	u16 *pu2Temp;
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_SET_EVENT_MASK_COMMAND,
+		HCI_READ_LOGICAL_LINK_ACCEPT_TIMEOUT,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;
+
+	pu2Temp =3D (u16 *)&pRetPar[1];		/*  Conn_Accept_Timeout */
+	*pu2Temp =3D pBtHciInfo->LogicalAcceptTimeout;
+	len +=3D 3;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdWriteLogicalLinkAcceptTimeout(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status		status =3D HCI_STATUS_SUCCESS;
+/*PMGNT_INFO		pMgntInfo =3D &padapter->MgntInfo; */
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u8 localBuf[6] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	pBtHciInfo->LogicalAcceptTimeout =3D *((u16 *)pHciCmd->Data);
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_SET_EVENT_MASK_COMMAND,
+		HCI_WRITE_LOGICAL_LINK_ACCEPT_TIMEOUT,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;
+
+	len +=3D 1;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	return status;
+}
+
+static enum hci_status
+bthci_CmdSetEventMask(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status		status =3D HCI_STATUS_SUCCESS;
+/*PMGNT_INFO		pMgntInfo =3D &padapter->MgntInfo; */
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u8 *pu8Temp;
+	u8 localBuf[6] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	pu8Temp =3D (u8 *)&pHciCmd->Data[0];
+	pBtHciInfo->BTEventMask =3D *pu8Temp;
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD_DETAIL, ("BTEventMask =3D 0x%"i64fmt"=
x\n",
+		pBtHciInfo->BTEventMask));
+
+	/* send command complete event here when all data are received. */
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_SET_EVENT_MASK_COMMAND,
+		HCI_SET_EVENT_MASK,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;		/* status */
+	len +=3D 1;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+
+	return status;
+}
+
+/*  7.3.69 */
+static enum hci_status
+bthci_CmdSetEventMaskPage2(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status		status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u8 *pu8Temp;
+	u8 localBuf[6] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	pu8Temp =3D (u8 *)&pHciCmd->Data[0];
+	pBtHciInfo->BTEventMaskPage2 =3D *pu8Temp;
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD_DETAIL|IOCTL_BT_LOGO), ("BTEventMask=
Page2 =3D 0x%"i64fmt"x\n",
+		pBtHciInfo->BTEventMaskPage2));
+
+	/* send command complete event here when all data are received. */
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_SET_EVENT_MASK_COMMAND,
+		HCI_SET_EVENT_MASK_PAGE_2,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;		/* status */
+	len +=3D 1;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdReadLocationData(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status		status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u8 localBuf[12] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+	u16 *pu2Temp;
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_SET_EVENT_MASK_COMMAND,
+		HCI_READ_LOCATION_DATA,
+		status);
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("DomainAware =3D 0x%x\n", pBtHciInf=
o->LocationDomainAware));
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("Domain =3D 0x%x\n", pBtHciInfo->Lo=
cationDomain));
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("DomainOptions =3D 0x%x\n", pBtHciI=
nfo->LocationDomainOptions));
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("Options =3D 0x%x\n", pBtHciInfo->L=
ocationOptions));
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;
+
+	pRetPar[1] =3D pBtHciInfo->LocationDomainAware;	/* 0x0;	 Location_Dom=
ain_Aware */
+	pu2Temp =3D (u16 *)&pRetPar[2];					/*  Location_Domain */
+	*pu2Temp =3D pBtHciInfo->LocationDomain;		/* 0x5858; */
+	pRetPar[4] =3D pBtHciInfo->LocationDomainOptions;	/* 0x58;	Location_D=
omain_Options */
+	pRetPar[5] =3D pBtHciInfo->LocationOptions;		/* 0x0;	Location_Options=
 */
+	len +=3D 6;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	return status;
+}
+
+static enum hci_status
+bthci_CmdWriteLocationData(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u16	*pu2Temp;
+	u8 localBuf[6] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	pBtHciInfo->LocationDomainAware =3D pHciCmd->Data[0];
+	pu2Temp =3D (u16 *)&pHciCmd->Data[1];
+	pBtHciInfo->LocationDomain =3D *pu2Temp;
+	pBtHciInfo->LocationDomainOptions =3D pHciCmd->Data[3];
+	pBtHciInfo->LocationOptions =3D pHciCmd->Data[4];
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("DomainAware =3D 0x%x\n", pBtHciInf=
o->LocationDomainAware));
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("Domain =3D 0x%x\n", pBtHciInfo->Lo=
cationDomain));
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("DomainOptions =3D 0x%x\n", pBtHciI=
nfo->LocationDomainOptions));
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("Options =3D 0x%x\n", pBtHciInfo->L=
ocationOptions));
+
+	/* send command complete event here when all data are received. */
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_SET_EVENT_MASK_COMMAND,
+		HCI_WRITE_LOCATION_DATA,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;		/* status */
+	len +=3D 1;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdReadFlowControlMode(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u8 localBuf[7] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_SET_EVENT_MASK_COMMAND,
+		HCI_READ_FLOW_CONTROL_MODE,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;
+	pRetPar[1] =3D pBtHciInfo->FlowControlMode;	/*  Flow Control Mode */
+	len +=3D 2;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	return status;
+}
+
+static enum hci_status
+bthci_CmdWriteFlowControlMode(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u8 localBuf[6] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	pBtHciInfo->FlowControlMode =3D pHciCmd->Data[0];
+
+	/* send command complete event here when all data are received. */
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_SET_EVENT_MASK_COMMAND,
+		HCI_WRITE_FLOW_CONTROL_MODE,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;		/* status */
+	len +=3D 1;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdReadBestEffortFlushTimeout(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTinfo =3D GET_BT_INFO(padapter);
+	u16 i, j, logicHandle;
+	u32 BestEffortFlushTimeout =3D 0xffffffff;
+	u8 find =3D 0;
+
+	logicHandle =3D *((u16 *)pHciCmd->Data);
+	/*  find an matched logical link index and copy the data */
+	for (j =3D 0; j < MAX_BT_ASOC_ENTRY_NUM; j++) {
+		for (i =3D 0; i < MAX_LOGICAL_LINK_NUM; i++) {
+			if (pBTinfo->BtAsocEntry[j].LogLinkCmdData[i].BtLogLinkhandle =3D=3D=
 logicHandle) {
+				BestEffortFlushTimeout =3D pBTinfo->BtAsocEntry[j].LogLinkCmdData[=
i].BestEffortFlushTimeout;
+				find =3D 1;
+				break;
+			}
+		}
+	}
+
+	if (!find)
+		status =3D HCI_STATUS_UNKNOW_CONNECT_ID;
+
+	{
+		u8 localBuf[10] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+		u32 *pu4Temp;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_SET_EVENT_MASK_COMMAND,
+			HCI_READ_BEST_EFFORT_FLUSH_TIMEOUT,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;
+		pu4Temp =3D (u32 *)&pRetPar[1];	/*  Best_Effort_Flush_Timeout */
+		*pu4Temp =3D BestEffortFlushTimeout;
+		len +=3D 5;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+	return status;
+}
+
+static enum hci_status
+bthci_CmdWriteBestEffortFlushTimeout(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTinfo =3D GET_BT_INFO(padapter);
+	u16 i, j, logicHandle;
+	u32 BestEffortFlushTimeout =3D 0xffffffff;
+	u8 find =3D 0;
+
+	logicHandle =3D *((u16 *)pHciCmd->Data);
+	BestEffortFlushTimeout =3D *((u32 *)(pHciCmd->Data+1));
+
+	/*  find an matched logical link index and copy the data */
+	for (j =3D 0; j < MAX_BT_ASOC_ENTRY_NUM; j++) {
+		for (i =3D 0; i < MAX_LOGICAL_LINK_NUM; i++) {
+			if (pBTinfo->BtAsocEntry[j].LogLinkCmdData[i].BtLogLinkhandle =3D=3D=
 logicHandle) {
+				pBTinfo->BtAsocEntry[j].LogLinkCmdData[i].BestEffortFlushTimeout =3D=
 BestEffortFlushTimeout;
+				find =3D 1;
+				break;
+			}
+		}
+	}
+
+	if (!find)
+		status =3D HCI_STATUS_UNKNOW_CONNECT_ID;
+
+	{
+		u8 localBuf[6] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_SET_EVENT_MASK_COMMAND,
+			HCI_WRITE_BEST_EFFORT_FLUSH_TIMEOUT,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;
+		len +=3D 1;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+	return status;
+}
+
+static enum hci_status
+bthci_CmdShortRangeMode(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	u8 PhyLinkHandle, EntryNum, ShortRangeMode;
+
+	PhyLinkHandle =3D pHciCmd->Data[0];
+	ShortRangeMode =3D pHciCmd->Data[1];
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("PLH =3D 0x%x, Short_Range_Mode =3D=
 0x%x\n", PhyLinkHandle, ShortRangeMode));
+
+	EntryNum =3D bthci_GetCurrentEntryNum(padapter, PhyLinkHandle);
+	if (EntryNum !=3D 0xff) {
+		pBTInfo->BtAsocEntry[EntryNum].ShortRangeMode =3D ShortRangeMode;
+	} else {
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("No such PLH(0x%x)\n", PhyLinkHand=
le));
+		status =3D HCI_STATUS_UNKNOW_CONNECT_ID;
+	}
+
+	bthci_EventCommandStatus(padapter,
+			OGF_SET_EVENT_MASK_COMMAND,
+			HCI_SHORT_RANGE_MODE,
+			status);
+
+	bthci_EventShortRangeModeChangeComplete(padapter, status, ShortRangeM=
ode, EntryNum);
+
+	return status;
+}
+
+static enum hci_status bthci_CmdReadLocalSupportedCommands(struct rtw_=
adapter *padapter)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	u8 localBuf[TmpLocalBufSize] =3D "";
+	u8 *pRetPar, *pSupportedCmds;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	/*  send command complete event here when all data are received. */
+	PlatformZeroMemory(&localBuf[0], TmpLocalBufSize);
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_INFORMATIONAL_PARAMETERS,
+		HCI_READ_LOCAL_SUPPORTED_COMMANDS,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;		/* status */
+	len +=3D 1;
+	pSupportedCmds =3D &pRetPar[1];
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("Octet[5]=3D 0xc0\n=
Bit [6]=3D Set Event Mask, [7]=3D Reset\n"));
+	pSupportedCmds[5] =3D 0xc0;
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("Octet[6]=3D 0x01\n=
Bit [0]=3D Set Event Filter\n"));
+	pSupportedCmds[6] =3D 0x01;
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("Octet[7]=3D 0x0c\n=
Bit [2]=3D Read Connection Accept Timeout, [3]=3D Write Connection Acce=
pt Timeout\n"));
+	pSupportedCmds[7] =3D 0x0c;
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("Octet[10]=3D 0x80\=
nBit [7]=3D Host Number Of Completed Packets\n"));
+	pSupportedCmds[10] =3D 0x80;
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("Octet[11]=3D 0x03\=
nBit [0]=3D Read Link Supervision Timeout, [1]=3D Write Link Supervisio=
n Timeout\n"));
+	pSupportedCmds[11] =3D 0x03;
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("Octet[14]=3D 0xa8\=
nBit [3]=3D Read Local Version Information, [5]=3D Read Local Supported=
 Features, [7]=3D Read Buffer Size\n"));
+	pSupportedCmds[14] =3D 0xa8;
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("Octet[15]=3D 0x1c\=
nBit [2]=3D Read Failed Contact Count, [3]=3D Reset Failed Contact Coun=
t, [4]=3D Get Link Quality\n"));
+	pSupportedCmds[15] =3D 0x1c;
+	/* pSupportedCmds[16] =3D 0x04; */
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("Octet[19]=3D 0x40\=
nBit [6]=3D Enhanced Flush\n"));
+	pSupportedCmds[19] =3D 0x40;
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("Octet[21]=3D 0xff\=
nBit [0]=3D Create Physical Link, [1]=3D Accept Physical Link, [2]=3D D=
isconnect Physical Link, [3]=3D Create Logical Link\n"));
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("	[4]=3D Accept Log=
ical Link, [5]=3D Disconnect Logical Link, [6]=3D Logical Link Cancel, =
[7]=3D Flow Spec Modify\n"));
+	pSupportedCmds[21] =3D 0xff;
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("Octet[22]=3D 0xff\=
nBit [0]=3D Read Logical Link Accept Timeout, [1]=3D Write Logical Link=
 Accept Timeout, [2]=3D Set Event Mask Page 2, [3]=3D Read Location Dat=
a\n"));
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("	[4]=3D Write Loca=
tion Data, [5]=3D Read Local AMP Info, [6]=3D Read Local AMP_ASSOC, [7]=
=3D Write Remote AMP_ASSOC\n"));
+	pSupportedCmds[22] =3D 0xff;
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("Octet[23]=3D 0x07\=
nBit [0]=3D Read Flow Control Mode, [1]=3D Write Flow Control Mode, [2]=
=3D Read Data Block Size\n"));
+	pSupportedCmds[23] =3D 0x07;
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD|IOCTL_BT_LOGO), ("Octet[24]=3D 0x1c\=
nBit [2]=3D Read Best Effort Flush Timeout, [3]=3D Write Best Effort Fl=
ush Timeout, [4]=3D Short Range Mode\n"));
+	pSupportedCmds[24] =3D 0x1c;
+	len +=3D 64;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+
+	return status;
+}
+
+static enum hci_status bthci_CmdReadLocalSupportedFeatures(struct rtw_=
adapter *padapter)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	u8 localBuf[TmpLocalBufSize] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	/* send command complete event here when all data are received. */
+	PlatformZeroMemory(&localBuf[0], TmpLocalBufSize);
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_INFORMATIONAL_PARAMETERS,
+		HCI_READ_LOCAL_SUPPORTED_FEATURES,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;		/* status */
+	len +=3D 9;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	return status;
+}
+
+static enum hci_status bthci_CmdReadLocalAMPAssoc(struct rtw_adapter *=
padapter,
+	struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	struct bt_dgb *pBtDbg =3D &pBTInfo->BtDbg;
+	u8 PhyLinkHandle, EntryNum;
+
+	pBtDbg->dbgHciInfo.hciCmdCntReadLocalAmpAssoc++;
+	PhyLinkHandle =3D *((u8 *)pHciCmd->Data);
+	EntryNum =3D bthci_GetCurrentEntryNum(padapter, PhyLinkHandle);
+
+	if ((EntryNum =3D=3D 0xff) && PhyLinkHandle !=3D 0) {
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("ReadLocalAMPAssoc, EntryNum =3D %=
d  !!!!!, physical link handle =3D 0x%x\n",
+		EntryNum, PhyLinkHandle));
+		status =3D HCI_STATUS_UNKNOW_CONNECT_ID;
+	} else if (pBtMgnt->bPhyLinkInProgressStartLL) {
+		status =3D HCI_STATUS_UNKNOW_CONNECT_ID;
+		pBtMgnt->bPhyLinkInProgressStartLL =3D false;
+	} else {
+		pBTInfo->BtAsocEntry[EntryNum].AmpAsocCmdData.BtPhyLinkhandle =3D *(=
(u8 *)pHciCmd->Data);
+		pBTInfo->BtAsocEntry[EntryNum].AmpAsocCmdData.LenSoFar =3D *((u16 *)=
((u8 *)pHciCmd->Data+1));
+		pBTInfo->BtAsocEntry[EntryNum].AmpAsocCmdData.MaxRemoteASSOCLen =3D =
*((u16 *)((u8 *)pHciCmd->Data+3));
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_DETAIL, ("ReadLocalAMPAssoc, LenSoFa=
r =3D%d, MaxRemoteASSOCLen =3D%d\n",
+			pBTInfo->BtAsocEntry[EntryNum].AmpAsocCmdData.LenSoFar,
+			pBTInfo->BtAsocEntry[EntryNum].AmpAsocCmdData.MaxRemoteASSOCLen));
+	}
+
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("ReadLocalAMPAssoc, EntryNum =3D %d=
  !!!!!, physical link handle =3D 0x%x, LengthSoFar =3D %x  \n",
+		EntryNum, PhyLinkHandle, pBTInfo->BtAsocEntry[EntryNum].AmpAsocCmdDa=
ta.LenSoFar));
+
+	/* send command complete event here when all data are received. */
+	{
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		/* PVOID buffer =3D padapter->IrpHCILocalbuf.Ptr; */
+		u8 localBuf[TmpLocalBufSize] =3D "";
+		u16	*pRemainLen;
+		u32	totalLen =3D 0;
+		u16	typeLen =3D 0, remainLen =3D 0, ret_index =3D 0;
+		u8 *pRetPar;
+
+		PlatformZeroMemory(&localBuf[0], TmpLocalBufSize);
+		/* PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(buffer); =
*/
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		totalLen +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_STATUS_PARAMETERS,
+			HCI_READ_LOCAL_AMP_ASSOC,
+			status);
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("ReadLocalAMPAssoc, Remaining_Len =
=3D%d  \n", remainLen));
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[totalLen];
+		pRetPar[0] =3D status;		/* status */
+		pRetPar[1] =3D *((u8 *)pHciCmd->Data);
+		pRemainLen =3D (u16 *)&pRetPar[2];	/* AMP_ASSOC_Remaining_Length */
+		totalLen +=3D 4;	/* 0]~[3] */
+		ret_index =3D 4;
+
+		typeLen =3D bthci_AssocMACAddr(padapter, &pRetPar[ret_index]);
+		totalLen +=3D typeLen;
+		remainLen +=3D typeLen;
+		ret_index +=3D typeLen;
+		typeLen =3D bthci_AssocPreferredChannelList(padapter, &pRetPar[ret_i=
ndex], EntryNum);
+		totalLen +=3D typeLen;
+		remainLen +=3D typeLen;
+		ret_index +=3D typeLen;
+		typeLen =3D bthci_PALCapabilities(padapter, &pRetPar[ret_index]);
+		totalLen +=3D typeLen;
+		remainLen +=3D typeLen;
+		ret_index +=3D typeLen;
+		typeLen =3D bthci_AssocPALVer(padapter, &pRetPar[ret_index]);
+		totalLen +=3D typeLen;
+		remainLen +=3D typeLen;
+		PPacketIrpEvent->Length =3D (u8)totalLen;
+		*pRemainLen =3D remainLen;	/*  AMP_ASSOC_Remaining_Length */
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("ReadLocalAMPAssoc, Remaining_Len =
=3D%d  \n", remainLen));
+		RTPRINT_DATA(FIOCTL, (IOCTL_BT_HCICMD_DETAIL|IOCTL_BT_LOGO), ("AMP_A=
SSOC_fragment : \n"), PPacketIrpEvent->Data, totalLen);
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, totalLen+2);
+	}
+
+	return status;
+}
+
+static enum hci_status bthci_CmdReadFailedContactCounter(struct rtw_ad=
apter *padapter,
+		       struct packet_irp_hcicmd_data *pHciCmd)
+{
+
+	enum hci_status		status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u8 localBuf[TmpLocalBufSize] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+	u16 handle;
+
+	handle =3D *((u16 *)pHciCmd->Data);
+	/* send command complete event here when all data are received. */
+	PlatformZeroMemory(&localBuf[0], TmpLocalBufSize);
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_STATUS_PARAMETERS,
+		HCI_READ_FAILED_CONTACT_COUNTER,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;		/* status */
+	pRetPar[1] =3D TWOBYTE_LOWBYTE(handle);
+	pRetPar[2] =3D TWOBYTE_HIGHTBYTE(handle);
+	pRetPar[3] =3D TWOBYTE_LOWBYTE(pBtHciInfo->FailContactCount);
+	pRetPar[4] =3D TWOBYTE_HIGHTBYTE(pBtHciInfo->FailContactCount);
+	len +=3D 5;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdResetFailedContactCounter(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status		status =3D HCI_STATUS_SUCCESS;
+/*PMGNT_INFO		pMgntInfo =3D &padapter->MgntInfo; */
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u16		handle;
+	u8 localBuf[TmpLocalBufSize] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+	handle =3D *((u16 *)pHciCmd->Data);
+	pBtHciInfo->FailContactCount =3D 0;
+
+	/* send command complete event here when all data are received. */
+	PlatformZeroMemory(&localBuf[0], TmpLocalBufSize);
+	/* PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(buffer); *=
/
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_STATUS_PARAMETERS,
+		HCI_RESET_FAILED_CONTACT_COUNTER,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;		/* status */
+	pRetPar[1] =3D TWOBYTE_LOWBYTE(handle);
+	pRetPar[2] =3D TWOBYTE_HIGHTBYTE(handle);
+	len +=3D 3;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	return status;
+}
+
+/*  */
+/*  BT 3.0+HS [Vol 2] 7.4.1 */
+/*  */
+static enum hci_status
+bthci_CmdReadLocalVersionInformation(
+	struct rtw_adapter *padapter
+	)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	/* send command complete event here when all data are received. */
+	u8 localBuf[TmpLocalBufSize] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+	u16 *pu2Temp;
+
+	PlatformZeroMemory(&localBuf[0], TmpLocalBufSize);
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_INFORMATIONAL_PARAMETERS,
+		HCI_READ_LOCAL_VERSION_INFORMATION,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;		/* status */
+	pRetPar[1] =3D 0x05;			/*  HCI_Version */
+	pu2Temp =3D (u16 *)&pRetPar[2];		/*  HCI_Revision */
+	*pu2Temp =3D 0x0001;
+	pRetPar[4] =3D 0x05;			/*  LMP/PAL_Version */
+	pu2Temp =3D (u16 *)&pRetPar[5];		/*  Manufacturer_Name */
+	*pu2Temp =3D 0x005d;
+	pu2Temp =3D (u16 *)&pRetPar[7];		/*  LMP/PAL_Subversion */
+	*pu2Temp =3D 0x0001;
+	len +=3D 9;
+	PPacketIrpEvent->Length =3D len;
+
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD_DETAIL|IOCTL_BT_LOGO), ("LOCAL_VERSI=
ON_INFORMATION\n"));
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD_DETAIL|IOCTL_BT_LOGO), ("Status  %x\=
n", status));
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD_DETAIL|IOCTL_BT_LOGO), ("HCI_Version=
 =3D 0x05\n"));
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD_DETAIL|IOCTL_BT_LOGO), ("HCI_Revisio=
n =3D 0x0001\n"));
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD_DETAIL|IOCTL_BT_LOGO), ("LMP/PAL_Ver=
sion =3D 0x05\n"));
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD_DETAIL|IOCTL_BT_LOGO), ("Manufacture=
r_Name =3D 0x0001\n"));
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD_DETAIL|IOCTL_BT_LOGO), ("LMP/PAL_Sub=
version =3D 0x0001\n"));
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+
+	return status;
+}
+
+/* 7.4.7 */
+static enum hci_status bthci_CmdReadDataBlockSize(struct rtw_adapter *=
padapter)
+{
+	enum hci_status			status =3D HCI_STATUS_SUCCESS;
+	u8 localBuf[TmpLocalBufSize] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+	u16 *pu2Temp;
+
+	PlatformZeroMemory(&localBuf[0], TmpLocalBufSize);
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_INFORMATIONAL_PARAMETERS,
+		HCI_READ_DATA_BLOCK_SIZE,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D HCI_STATUS_SUCCESS;	/* status */
+	pu2Temp =3D (u16 *)&pRetPar[1];		/*  Max_ACL_Data_Packet_Length */
+	*pu2Temp =3D Max80211PALPDUSize;
+
+	pu2Temp =3D (u16 *)&pRetPar[3];		/*  Data_Block_Length */
+	*pu2Temp =3D Max80211PALPDUSize;
+	pu2Temp =3D (u16 *)&pRetPar[5];		/*  Total_Num_Data_Blocks */
+	*pu2Temp =3D BTTotalDataBlockNum;
+	len +=3D 7;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+
+	return status;
+}
+
+/*  7.4.5 */
+static enum hci_status bthci_CmdReadBufferSize(struct rtw_adapter *pad=
apter)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	u8 localBuf[TmpLocalBufSize] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+	u16 *pu2Temp;
+
+	PlatformZeroMemory(&localBuf[0], TmpLocalBufSize);
+	/* PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(buffer); *=
/
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_INFORMATIONAL_PARAMETERS,
+		HCI_READ_BUFFER_SIZE,
+		status);
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("Synchronous_Data_Packet_Length =3D=
 0x%x\n", BTSynDataPacketLength));
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("Total_Num_ACL_Data_Packets =3D 0x%=
x\n", BTTotalDataBlockNum));
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("Total_Num_Synchronous_Data_Packets=
 =3D 0x%x\n", BTTotalDataBlockNum));
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;		/* status */
+	pu2Temp =3D (u16 *)&pRetPar[1];		/*  HC_ACL_Data_Packet_Length */
+	*pu2Temp =3D Max80211PALPDUSize;
+
+	pRetPar[3] =3D BTSynDataPacketLength;	/*  HC_Synchronous_Data_Packet_=
Length */
+	pu2Temp =3D (u16 *)&pRetPar[4];		/*  HC_Total_Num_ACL_Data_Packets */
+	*pu2Temp =3D BTTotalDataBlockNum;
+	pu2Temp =3D (u16 *)&pRetPar[6];		/*  HC_Total_Num_Synchronous_Data_Pa=
ckets */
+	*pu2Temp =3D BTTotalDataBlockNum;
+	len +=3D 8;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+
+	return status;
+}
+
+static enum hci_status bthci_CmdReadLocalAMPInfo(struct rtw_adapter *p=
adapter)
+{
+	enum hci_status	status =3D HCI_STATUS_SUCCESS;
+	struct pwrctrl_priv *ppwrctrl =3D &padapter->pwrctrlpriv;
+	u8 localBuf[TmpLocalBufSize] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+	u16 *pu2Temp;
+	u32 *pu4Temp;
+	u32	TotalBandwidth =3D BTTOTALBANDWIDTH, MaxBandGUBandwidth =3D BTMAX=
BANDGUBANDWIDTH;
+	u8 ControlType =3D 0x01, AmpStatus =3D 0x01;
+	u32	MaxFlushTimeout =3D 10000, BestEffortFlushTimeout =3D 5000;
+	u16 MaxPDUSize =3D Max80211PALPDUSize, PalCap =3D 0x1, AmpAssocLen =3D=
 Max80211AMPASSOCLen, MinLatency =3D 20;
+
+	if ((ppwrctrl->rfoff_reason & RF_CHANGE_BY_HW) ||
+	    (ppwrctrl->rfoff_reason & RF_CHANGE_BY_SW)) {
+		AmpStatus =3D AMP_STATUS_NO_CAPACITY_FOR_BT;
+	}
+
+	PlatformZeroMemory(&localBuf[0], TmpLocalBufSize);
+	/* PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(buffer); *=
/
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_STATUS_PARAMETERS,
+		HCI_READ_LOCAL_AMP_INFO,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;			/* status */
+	pRetPar[1] =3D AmpStatus;			/*  AMP_Status */
+	pu4Temp =3D (u32 *)&pRetPar[2];		/*  Total_Bandwidth */
+	*pu4Temp =3D TotalBandwidth;		/* 0x19bfcc00;0x7530; */
+	pu4Temp =3D (u32 *)&pRetPar[6];		/*  Max_Guaranteed_Bandwidth */
+	*pu4Temp =3D MaxBandGUBandwidth;		/* 0x19bfcc00;0x4e20; */
+	pu4Temp =3D (u32 *)&pRetPar[10];		/*  Min_Latency */
+	*pu4Temp =3D MinLatency;			/* 150; */
+	pu4Temp =3D (u32 *)&pRetPar[14];		/*  Max_PDU_Size */
+	*pu4Temp =3D MaxPDUSize;
+	pRetPar[18] =3D ControlType;		/*  Controller_Type */
+	pu2Temp =3D (u16 *)&pRetPar[19];		/*  PAL_Capabilities */
+	*pu2Temp =3D PalCap;
+	pu2Temp =3D (u16 *)&pRetPar[21];		/*  AMP_ASSOC_Length */
+	*pu2Temp =3D AmpAssocLen;
+	pu4Temp =3D (u32 *)&pRetPar[23];		/*  Max_Flush_Timeout */
+	*pu4Temp =3D MaxFlushTimeout;
+	pu4Temp =3D (u32 *)&pRetPar[27];		/*  Best_Effort_Flush_Timeout */
+	*pu4Temp =3D BestEffortFlushTimeout;
+	len +=3D 31;
+	PPacketIrpEvent->Length =3D len;
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("AmpStatus =3D 0x%x\n",
+		AmpStatus));
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("TotalBandwidth =3D 0x%x, MaxBandGU=
Bandwidth =3D 0x%x, MinLatency =3D 0x%x, \n MaxPDUSize =3D 0x%x, Contro=
lType =3D 0x%x\n",
+		TotalBandwidth, MaxBandGUBandwidth, MinLatency, MaxPDUSize, ControlT=
ype));
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("PalCap =3D 0x%x, AmpAssocLen =3D 0=
x%x, MaxFlushTimeout =3D 0x%x, BestEffortFlushTimeout =3D 0x%x\n",
+		PalCap, AmpAssocLen, MaxFlushTimeout, BestEffortFlushTimeout));
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	return status;
+}
+
+static enum hci_status
+bthci_CmdCreatePhysicalLink(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status	status;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_dgb *pBtDbg =3D &pBTInfo->BtDbg;
+
+	pBtDbg->dbgHciInfo.hciCmdCntCreatePhyLink++;
+
+	status =3D bthci_BuildPhysicalLink(padapter,
+		pHciCmd, HCI_CREATE_PHYSICAL_LINK);
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdReadLinkQuality(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status			status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	u16				PLH;
+	u8 	EntryNum, LinkQuality =3D 0x55;
+
+	PLH =3D *((u16 *)&pHciCmd->Data[0]);
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("PLH =3D 0x%x\n", PLH));
+
+	EntryNum =3D bthci_GetCurrentEntryNum(padapter, (u8)PLH);
+	if (EntryNum =3D=3D 0xff) {
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("No such PLH(0x%x)\n", PLH));
+		status =3D HCI_STATUS_UNKNOW_CONNECT_ID;
+	}
+
+	{
+		u8 localBuf[11] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_STATUS_PARAMETERS,
+			HCI_READ_LINK_QUALITY,
+			status);
+
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, (" PLH =3D 0x%x\n Link Quality =3D =
0x%x\n", PLH, LinkQuality));
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;			/* status */
+		*((u16 *)&pRetPar[1]) =3D pBTInfo->BtAsocEntry[EntryNum].PhyLinkCmdD=
ata.BtPhyLinkhandle;	/*  Handle */
+		pRetPar[3] =3D 0x55;	/* Link Quailty */
+		len +=3D 4;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status bthci_CmdReadRSSI(struct rtw_adapter *padapter)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	return status;
+}
+
+static enum hci_status
+bthci_CmdCreateLogicalLink(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_dgb *pBtDbg =3D &pBTInfo->BtDbg;
+
+	pBtDbg->dbgHciInfo.hciCmdCntCreateLogLink++;
+
+	bthci_BuildLogicalLink(padapter, pHciCmd,
+		HCI_CREATE_LOGICAL_LINK);
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdAcceptLogicalLink(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_dgb *pBtDbg =3D &pBTInfo->BtDbg;
+
+	pBtDbg->dbgHciInfo.hciCmdCntAcceptLogLink++;
+
+	bthci_BuildLogicalLink(padapter, pHciCmd,
+		HCI_ACCEPT_LOGICAL_LINK);
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdDisconnectLogicalLink(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+/*PMGNT_INFO pMgntInfo =3D &padapter->MgntInfo; */
+	struct bt_30info *pBTinfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTinfo->BtMgnt;
+	struct bt_dgb *pBtDbg =3D &pBTinfo->BtDbg;
+	u16	logicHandle;
+	u8 i, j, find =3D 0, LogLinkCount =3D 0;
+
+	pBtDbg->dbgHciInfo.hciCmdCntDisconnectLogLink++;
+
+	logicHandle =3D *((u16 *)pHciCmd->Data);
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("DisconnectLogicalLink, logicHandle=
 =3D 0x%x\n", logicHandle));
+
+	/*  find an created logical link index and clear the data */
+	for (j =3D 0; j < MAX_BT_ASOC_ENTRY_NUM; j++) {
+		for (i =3D 0; i < MAX_LOGICAL_LINK_NUM; i++) {
+			if (pBTinfo->BtAsocEntry[j].LogLinkCmdData[i].BtLogLinkhandle =3D=3D=
 logicHandle) {
+				RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("DisconnectLogicalLink, logicHan=
dle is matched  0x%x\n", logicHandle));
+				bthci_ResetFlowSpec(padapter, j, i);
+				find =3D 1;
+				pBtMgnt->DisconnectEntryNum =3D j;
+				break;
+			}
+		}
+	}
+
+	if (!find)
+		status =3D HCI_STATUS_UNKNOW_CONNECT_ID;
+
+	/*  To check each */
+	for (i =3D 0; i < MAX_LOGICAL_LINK_NUM; i++) {
+		if (pBTinfo->BtAsocEntry[pBtMgnt->DisconnectEntryNum].LogLinkCmdData=
[i].BtLogLinkhandle !=3D 0)
+			LogLinkCount++;
+	}
+
+	/* When we receive Create logical link command, we should send comman=
d status event first. */
+	bthci_EventCommandStatus(padapter,
+			LINK_CONTROL_COMMANDS,
+			HCI_DISCONNECT_LOGICAL_LINK,
+			status);
+	/*  */
+	/* When we determines the logical link is established, we should send=
 command complete event. */
+	/*  */
+	if (status =3D=3D HCI_STATUS_SUCCESS) {
+		bthci_EventDisconnectLogicalLinkComplete(padapter, status,
+			logicHandle, HCI_STATUS_CONNECT_TERMINATE_LOCAL_HOST);
+	}
+
+	if (LogLinkCount =3D=3D 0)
+		mod_timer(&pBTinfo->BTDisconnectPhyLinkTimer,
+			  jiffies + msecs_to_jiffies(100));
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdLogicalLinkCancel(struct rtw_adapter *padapter,
+			   struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTinfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTinfo->BtMgnt;
+	u8 CurrentEntryNum, CurrentLogEntryNum;
+
+	u8 physicalLinkHandle, TxFlowSpecID, i;
+	u16	CurrentLogicalHandle;
+
+	physicalLinkHandle =3D *((u8 *)pHciCmd->Data);
+	TxFlowSpecID =3D *(((u8 *)pHciCmd->Data)+1);
+
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("LogicalLinkCancel, physicalLinkHan=
dle =3D 0x%x, TxFlowSpecID =3D 0x%x\n",
+		physicalLinkHandle, TxFlowSpecID));
+
+	CurrentEntryNum =3D pBtMgnt->CurrentConnectEntryNum;
+	CurrentLogicalHandle =3D pBtMgnt->BtCurrentLogLinkhandle;
+
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("CurrentEntryNum =3D 0x%x, CurrentL=
ogicalHandle =3D 0x%x\n",
+		CurrentEntryNum, CurrentLogicalHandle));
+
+	CurrentLogEntryNum =3D 0xff;
+	for (i =3D 0; i < MAX_LOGICAL_LINK_NUM; i++) {
+		if ((CurrentLogicalHandle =3D=3D pBTinfo->BtAsocEntry[CurrentEntryNu=
m].LogLinkCmdData[i].BtLogLinkhandle) &&
+			(physicalLinkHandle =3D=3D pBTinfo->BtAsocEntry[CurrentEntryNum].Lo=
gLinkCmdData[i].BtPhyLinkhandle)) {
+			CurrentLogEntryNum =3D i;
+			break;
+		}
+	}
+
+	if (CurrentLogEntryNum =3D=3D 0xff) {
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("LogicalLinkCancel, CurrentLogEntr=
yNum =3D=3D 0xff !!!!\n"));
+		status =3D HCI_STATUS_UNKNOW_CONNECT_ID;
+		return status;
+	} else {
+		if (pBTinfo->BtAsocEntry[CurrentEntryNum].LogLinkCmdData[CurrentLogE=
ntryNum].bLLCompleteEventIsSet) {
+			RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("LogicalLinkCancel, LLCompleteEve=
ntIsSet!!!!\n"));
+			status =3D HCI_STATUS_ACL_CONNECT_EXISTS;
+		}
+	}
+
+	{
+		u8 localBuf[8] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			LINK_CONTROL_COMMANDS,
+			HCI_LOGICAL_LINK_CANCEL,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;		/* status */
+		pRetPar[1] =3D pBTinfo->BtAsocEntry[CurrentEntryNum].LogLinkCmdData[=
CurrentLogEntryNum].BtPhyLinkhandle;
+		pRetPar[2] =3D pBTinfo->BtAsocEntry[CurrentEntryNum].LogLinkCmdData[=
CurrentLogEntryNum].BtTxFlowSpecID;
+		len +=3D 3;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	pBTinfo->BtAsocEntry[CurrentEntryNum].LogLinkCmdData[CurrentLogEntryN=
um].bLLCancelCMDIsSetandComplete =3D true;
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdFlowSpecModify(struct rtw_adapter *padapter,
+			struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+/*PMGNT_INFO pMgntInfo =3D &padapter->MgntInfo; */
+	struct bt_30info *pBTinfo =3D GET_BT_INFO(padapter);
+	u8 i, j, find =3D 0;
+	u16 logicHandle;
+
+	logicHandle =3D *((u16 *)pHciCmd->Data);
+	/*  find an matched logical link index and copy the data */
+	for (j =3D 0; j < MAX_BT_ASOC_ENTRY_NUM; j++) {
+		for (i =3D 0; i < MAX_LOGICAL_LINK_NUM; i++) {
+			if (pBTinfo->BtAsocEntry[j].LogLinkCmdData[i].BtLogLinkhandle =3D=3D=
 logicHandle) {
+				memcpy(&pBTinfo->BtAsocEntry[j].LogLinkCmdData[i].Tx_Flow_Spec,
+					&pHciCmd->Data[2], sizeof(struct hci_flow_spec));
+				memcpy(&pBTinfo->BtAsocEntry[j].LogLinkCmdData[i].Rx_Flow_Spec,
+					&pHciCmd->Data[18], sizeof(struct hci_flow_spec));
+
+				bthci_CheckLogLinkBehavior(padapter, pBTinfo->BtAsocEntry[j].LogLi=
nkCmdData[i].Tx_Flow_Spec);
+				find =3D 1;
+				break;
+			}
+		}
+	}
+	RTPRINT(FIOCTL, IOCTL_BT_LOGO, ("FlowSpecModify, LLH =3D 0x%x, \n", l=
ogicHandle));
+
+	/* When we receive Flow Spec Modify command, we should send command s=
tatus event first. */
+	bthci_EventCommandStatus(padapter,
+		LINK_CONTROL_COMMANDS,
+		HCI_FLOW_SPEC_MODIFY,
+		HCI_STATUS_SUCCESS);
+
+	if (!find)
+		status =3D HCI_STATUS_UNKNOW_CONNECT_ID;
+
+	bthci_EventSendFlowSpecModifyComplete(padapter, status, logicHandle);
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdAcceptPhysicalLink(struct rtw_adapter *padapter,
+			    struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status	status;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_dgb *pBtDbg =3D &pBTInfo->BtDbg;
+
+	pBtDbg->dbgHciInfo.hciCmdCntAcceptPhyLink++;
+
+	status =3D bthci_BuildPhysicalLink(padapter,
+		pHciCmd, HCI_ACCEPT_PHYSICAL_LINK);
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdDisconnectPhysicalLink(struct rtw_adapter *padapter,
+				struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status	status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_dgb *pBtDbg =3D &pBTInfo->BtDbg;
+	u8 PLH, CurrentEntryNum, PhysLinkDisconnectReason;
+
+	pBtDbg->dbgHciInfo.hciCmdCntDisconnectPhyLink++;
+
+	PLH =3D *((u8 *)pHciCmd->Data);
+	PhysLinkDisconnectReason =3D (*((u8 *)pHciCmd->Data+1));
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_DISCONNECT_PHYSICAL_LINK  PhyH=
andle =3D 0x%x, Reason =3D 0x%x\n",
+		PLH, PhysLinkDisconnectReason));
+
+	CurrentEntryNum =3D bthci_GetCurrentEntryNum(padapter, PLH);
+
+	if (CurrentEntryNum =3D=3D 0xff) {
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD,
+			("DisconnectPhysicalLink, No such Handle in the Entry\n"));
+		status =3D HCI_STATUS_UNKNOW_CONNECT_ID;
+	} else {
+		pBTInfo->BtAsocEntry[CurrentEntryNum].PhyLinkDisconnectReason =3D
+			(enum hci_status)PhysLinkDisconnectReason;
+	}
+	/* Send HCI Command status event to AMP. */
+	bthci_EventCommandStatus(padapter, LINK_CONTROL_COMMANDS,
+				 HCI_DISCONNECT_PHYSICAL_LINK, status);
+
+	if (status !=3D HCI_STATUS_SUCCESS)
+		return status;
+
+	/* The macros below require { and } in the if statement */
+	if (pBTInfo->BtAsocEntry[CurrentEntryNum].BtCurrentState =3D=3D HCI_S=
TATE_DISCONNECTED) {
+		BTHCI_SM_WITH_INFO(padapter, HCI_STATE_DISCONNECTED, STATE_CMD_DISCO=
NNECT_PHY_LINK, CurrentEntryNum);
+	} else {
+		BTHCI_SM_WITH_INFO(padapter, HCI_STATE_DISCONNECTING, STATE_CMD_DISC=
ONNECT_PHY_LINK, CurrentEntryNum);
+	}
+	return status;
+}
+
+static enum hci_status
+bthci_CmdSetACLLinkDataFlowMode(struct rtw_adapter *padapter,
+				struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	u8 localBuf[8] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+	u16 *pu2Temp;
+
+	pBtMgnt->ExtConfig.CurrentConnectHandle =3D *((u16 *)pHciCmd->Data);
+	pBtMgnt->ExtConfig.CurrentIncomingTrafficMode =3D *((u8 *)pHciCmd->Da=
ta)+2;
+	pBtMgnt->ExtConfig.CurrentOutgoingTrafficMode =3D *((u8 *)pHciCmd->Da=
ta)+3;
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("Connection Handle =3D 0x%x, In=
coming Traffic mode =3D 0x%x, Outgoing Traffic mode =3D 0x%x",
+		pBtMgnt->ExtConfig.CurrentConnectHandle,
+		pBtMgnt->ExtConfig.CurrentIncomingTrafficMode,
+		pBtMgnt->ExtConfig.CurrentOutgoingTrafficMode));
+
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_EXTENSION,
+		HCI_SET_ACL_LINK_DATA_FLOW_MODE,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;		/* status */
+
+	pu2Temp =3D (u16 *)&pRetPar[1];
+	*pu2Temp =3D pBtMgnt->ExtConfig.CurrentConnectHandle;
+	len +=3D 3;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	return status;
+}
+
+static enum hci_status
+bthci_CmdSetACLLinkStatus(struct rtw_adapter *padapter,
+			  struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	struct bt_dgb *pBtDbg =3D &pBTInfo->BtDbg;
+	u8 i;
+	u8 *pTriple;
+
+	pBtDbg->dbgHciInfo.hciCmdCntSetAclLinkStatus++;
+	RTPRINT_DATA(FIOCTL, IOCTL_BT_HCICMD_EXT, "SetACLLinkStatus, Hex Data=
 :\n",
+			&pHciCmd->Data[0], pHciCmd->Length);
+
+	/*  Only Core Stack v251 and later version support this command. */
+	pBtMgnt->bSupportProfile =3D true;
+
+	pBtMgnt->ExtConfig.NumberOfHandle =3D *((u8 *)pHciCmd->Data);
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("NumberOfHandle =3D 0x%x\n", pB=
tMgnt->ExtConfig.NumberOfHandle));
+
+	pTriple =3D &pHciCmd->Data[1];
+	for (i =3D 0; i < pBtMgnt->ExtConfig.NumberOfHandle; i++) {
+		pBtMgnt->ExtConfig.linkInfo[i].ConnectHandle =3D *((u16 *)&pTriple[0=
]);
+		pBtMgnt->ExtConfig.linkInfo[i].IncomingTrafficMode =3D pTriple[2];
+		pBtMgnt->ExtConfig.linkInfo[i].OutgoingTrafficMode =3D pTriple[3];
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT,
+			("Connection_Handle =3D 0x%x, Incoming Traffic mode =3D 0x%x, Outgo=
ing Traffic Mode =3D 0x%x\n",
+			pBtMgnt->ExtConfig.linkInfo[i].ConnectHandle,
+			pBtMgnt->ExtConfig.linkInfo[i].IncomingTrafficMode,
+			pBtMgnt->ExtConfig.linkInfo[i].OutgoingTrafficMode));
+		pTriple +=3D 4;
+	}
+
+	{
+		u8 localBuf[6] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_EXTENSION,
+			HCI_SET_ACL_LINK_STATUS,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;		/* status */
+
+		len +=3D 1;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdSetSCOLinkStatus(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	struct bt_dgb *pBtDbg =3D &pBTInfo->BtDbg;
+
+	pBtDbg->dbgHciInfo.hciCmdCntSetScoLinkStatus++;
+	pBtMgnt->ExtConfig.NumberOfSCO =3D *((u8 *)pHciCmd->Data);
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("NumberOfSCO =3D 0x%x\n",
+		pBtMgnt->ExtConfig.NumberOfSCO));
+
+	{
+		u8 localBuf[6] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_EXTENSION,
+			HCI_SET_SCO_LINK_STATUS,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;		/* status */
+
+		len +=3D 1;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdSetRSSIValue(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	s8		min_bt_rssi =3D 0;
+	u8 i;
+	for (i =3D 0; i < pBtMgnt->ExtConfig.NumberOfHandle; i++) {
+		if (pBtMgnt->ExtConfig.linkInfo[i].ConnectHandle =3D=3D *((u16 *)&pH=
ciCmd->Data[0])) {
+			pBtMgnt->ExtConfig.linkInfo[i].BT_RSSI =3D (s8)(pHciCmd->Data[2]);
+			RTPRINT(FIOCTL, IOCTL_BT_EVENT_PERIODICAL,
+			("Connection_Handle =3D 0x%x, RSSI =3D %d \n",
+			pBtMgnt->ExtConfig.linkInfo[i].ConnectHandle,
+			pBtMgnt->ExtConfig.linkInfo[i].BT_RSSI));
+		}
+		/*  get the minimum bt rssi value */
+		if (pBtMgnt->ExtConfig.linkInfo[i].BT_RSSI <=3D min_bt_rssi)
+			min_bt_rssi =3D pBtMgnt->ExtConfig.linkInfo[i].BT_RSSI;
+	}
+
+	pBtMgnt->ExtConfig.MIN_BT_RSSI =3D min_bt_rssi;
+	RTPRINT(FBT, BT_TRACE, ("[bt rssi], the min rssi is %d\n", min_bt_rss=
i));
+
+	{
+		u8 localBuf[6] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_EXTENSION,
+			HCI_SET_RSSI_VALUE,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;		/* status */
+
+		len +=3D 1;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdSetCurrentBluetoothStatus(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status	status =3D HCI_STATUS_SUCCESS;
+/*PMGNT_INFO	pMgntInfo =3D &padapter->MgntInfo; */
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	pBtMgnt->ExtConfig.CurrentBTStatus =3D *((u8 *)&pHciCmd->Data[0]);
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("SetCurrentBluetoothStatus, Cur=
rentBTStatus =3D 0x%x\n",
+		pBtMgnt->ExtConfig.CurrentBTStatus));
+
+	{
+		u8 localBuf[6] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_EXTENSION,
+			HCI_SET_CURRENT_BLUETOOTH_STATUS,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;		/* status */
+		len +=3D 1;
+
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdExtensionVersionNotify(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status	status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	struct bt_dgb *pBtDbg =3D &pBTInfo->BtDbg;
+
+	pBtDbg->dbgHciInfo.hciCmdCntExtensionVersionNotify++;
+	RTPRINT_DATA(FIOCTL, IOCTL_BT_HCICMD_EXT, "ExtensionVersionNotify, He=
x Data :\n",
+			&pHciCmd->Data[0], pHciCmd->Length);
+
+	pBtMgnt->ExtConfig.HCIExtensionVer =3D *((u16 *)&pHciCmd->Data[0]);
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("HCIExtensionVer =3D 0x%x\n", p=
BtMgnt->ExtConfig.HCIExtensionVer));
+
+	{
+		u8 localBuf[6] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_EXTENSION,
+			HCI_EXTENSION_VERSION_NOTIFY,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;		/* status */
+
+		len +=3D 1;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdLinkStatusNotify(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status	status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	struct bt_dgb *pBtDbg =3D &pBTInfo->BtDbg;
+	u8 i;
+	u8 *pTriple;
+
+	pBtDbg->dbgHciInfo.hciCmdCntLinkStatusNotify++;
+	RTPRINT_DATA(FIOCTL, IOCTL_BT_HCICMD_EXT, "LinkStatusNotify, Hex Data=
 :\n",
+			&pHciCmd->Data[0], pHciCmd->Length);
+
+	/*  Current only RTL8723 support this command. */
+	pBtMgnt->bSupportProfile =3D true;
+
+	pBtMgnt->ExtConfig.NumberOfHandle =3D *((u8 *)pHciCmd->Data);
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("NumberOfHandle =3D 0x%x\n", pB=
tMgnt->ExtConfig.NumberOfHandle));
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("HCIExtensionVer =3D %d\n", pBt=
Mgnt->ExtConfig.HCIExtensionVer));
+
+	pTriple =3D &pHciCmd->Data[1];
+	for (i =3D 0; i < pBtMgnt->ExtConfig.NumberOfHandle; i++) {
+		if (pBtMgnt->ExtConfig.HCIExtensionVer < 1) {
+			pBtMgnt->ExtConfig.linkInfo[i].ConnectHandle =3D *((u16 *)&pTriple[=
0]);
+			pBtMgnt->ExtConfig.linkInfo[i].BTProfile =3D pTriple[2];
+			pBtMgnt->ExtConfig.linkInfo[i].BTCoreSpec =3D pTriple[3];
+			RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT,
+				("Connection_Handle =3D 0x%x, BTProfile =3D%d, BTSpec =3D%d\n",
+				pBtMgnt->ExtConfig.linkInfo[i].ConnectHandle,
+				pBtMgnt->ExtConfig.linkInfo[i].BTProfile,
+				pBtMgnt->ExtConfig.linkInfo[i].BTCoreSpec));
+			pTriple +=3D 4;
+		} else if (pBtMgnt->ExtConfig.HCIExtensionVer >=3D 1) {
+			pBtMgnt->ExtConfig.linkInfo[i].ConnectHandle =3D *((u16 *)&pTriple[=
0]);
+			pBtMgnt->ExtConfig.linkInfo[i].BTProfile =3D pTriple[2];
+			pBtMgnt->ExtConfig.linkInfo[i].BTCoreSpec =3D pTriple[3];
+			pBtMgnt->ExtConfig.linkInfo[i].linkRole =3D pTriple[4];
+			RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT,
+				("Connection_Handle =3D 0x%x, BTProfile =3D%d, BTSpec =3D%d, LinkR=
ole =3D%d\n",
+				pBtMgnt->ExtConfig.linkInfo[i].ConnectHandle,
+				pBtMgnt->ExtConfig.linkInfo[i].BTProfile,
+				pBtMgnt->ExtConfig.linkInfo[i].BTCoreSpec,
+				pBtMgnt->ExtConfig.linkInfo[i].linkRole));
+			pTriple +=3D 5;
+		}
+
+	}
+	BTHCI_UpdateBTProfileRTKToMoto(padapter);
+	{
+		u8 localBuf[6] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_EXTENSION,
+			HCI_LINK_STATUS_NOTIFY,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;		/* status */
+
+		len +=3D 1;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdBtOperationNotify(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status	status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	RTPRINT_DATA(FIOCTL, IOCTL_BT_HCICMD_EXT, "Bt Operation notify, Hex D=
ata :\n",
+			&pHciCmd->Data[0], pHciCmd->Length);
+
+	pBtMgnt->ExtConfig.btOperationCode =3D *((u8 *)pHciCmd->Data);
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("btOperationCode =3D 0x%x\n", p=
BtMgnt->ExtConfig.btOperationCode));
+	switch (pBtMgnt->ExtConfig.btOperationCode) {
+	case HCI_BT_OP_NONE:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("[bt operation] : Operation No=
ne!!\n"));
+		break;
+	case HCI_BT_OP_INQUIRY_START:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("[bt operation] : Inquire star=
t!!\n"));
+		break;
+	case HCI_BT_OP_INQUIRY_FINISH:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("[bt operation] : Inquire fini=
shed!!\n"));
+		break;
+	case HCI_BT_OP_PAGING_START:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("[bt operation] : Paging is st=
arted!!\n"));
+		break;
+	case HCI_BT_OP_PAGING_SUCCESS:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("[bt operation] : Paging compl=
ete successfully!!\n"));
+		break;
+	case HCI_BT_OP_PAGING_UNSUCCESS:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("[bt operation] : Paging compl=
ete unsuccessfully!!\n"));
+		break;
+	case HCI_BT_OP_PAIRING_START:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("[bt operation] : Pairing star=
t!!\n"));
+		break;
+	case HCI_BT_OP_PAIRING_FINISH:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("[bt operation] : Pairing fini=
shed!!\n"));
+		break;
+	case HCI_BT_OP_BT_DEV_ENABLE:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("[bt operation] : BT Device is=
 enabled!!\n"));
+		break;
+	case HCI_BT_OP_BT_DEV_DISABLE:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("[bt operation] : BT Device is=
 disabled!!\n"));
+		break;
+	default:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("[bt operation] : Unknown, err=
or!!\n"));
+		break;
+	}
+	BTDM_AdjustForBtOperation(padapter);
+	{
+		u8 localBuf[6] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_EXTENSION,
+			HCI_BT_OPERATION_NOTIFY,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;		/* status */
+
+		len +=3D 1;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdEnableWifiScanNotify(struct rtw_adapter *padapter,
+			      struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status	status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	RTPRINT_DATA(FIOCTL, IOCTL_BT_HCICMD_EXT, "Enable Wifi scan notify, H=
ex Data :\n",
+			&pHciCmd->Data[0], pHciCmd->Length);
+
+	pBtMgnt->ExtConfig.bEnableWifiScanNotify =3D *((u8 *)pHciCmd->Data);
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("bEnableWifiScanNotify =3D %d\n=
", pBtMgnt->ExtConfig.bEnableWifiScanNotify));
+
+	{
+		u8 localBuf[6] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_EXTENSION,
+			HCI_ENABLE_WIFI_SCAN_NOTIFY,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;		/* status */
+
+		len +=3D 1;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdWIFICurrentChannel(struct rtw_adapter *padapter,
+			    struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct mlme_ext_priv *pmlmeext =3D &padapter->mlmeextpriv;
+	u8 chnl =3D pmlmeext->cur_channel;
+
+	if (pmlmeext->cur_bwmode =3D=3D HT_CHANNEL_WIDTH_40) {
+		if (pmlmeext->cur_ch_offset =3D=3D HAL_PRIME_CHNL_OFFSET_UPPER)
+			chnl +=3D 2;
+		else if (pmlmeext->cur_ch_offset =3D=3D HAL_PRIME_CHNL_OFFSET_LOWER)
+			chnl -=3D 2;
+	}
+
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("Current Channel  =3D 0x%x\n", =
chnl));
+
+	{
+		u8 localBuf[8] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_EXTENSION,
+			HCI_WIFI_CURRENT_CHANNEL,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;		/* status */
+		pRetPar[1] =3D chnl;			/* current channel */
+		len +=3D 2;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdWIFICurrentBandwidth(struct rtw_adapter *padapter,
+			      struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	enum ht_channel_width bw;
+	u8 CurrentBW =3D 0;
+
+	bw =3D padapter->mlmeextpriv.cur_bwmode;
+
+	if (bw =3D=3D HT_CHANNEL_WIDTH_20)
+		CurrentBW =3D 0;
+	else if (bw =3D=3D HT_CHANNEL_WIDTH_40)
+		CurrentBW =3D 1;
+
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("Current BW =3D 0x%x\n",
+		CurrentBW));
+
+	{
+		u8 localBuf[8] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_EXTENSION,
+			HCI_WIFI_CURRENT_BANDWIDTH,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;		/* status */
+		pRetPar[1] =3D CurrentBW;		/* current BW */
+		len +=3D 2;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdWIFIConnectionStatus(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	u8 connectStatus =3D HCI_WIFI_NOT_CONNECTED;
+
+	if (check_fwstate(&padapter->mlmepriv, WIFI_AP_STATE)) {
+		if (padapter->stapriv.asoc_sta_count >=3D 3)
+			connectStatus =3D HCI_WIFI_CONNECTED;
+		else
+			connectStatus =3D HCI_WIFI_NOT_CONNECTED;
+	} else if (check_fwstate(&padapter->mlmepriv, WIFI_ADHOC_STATE|WIFI_A=
DHOC_MASTER_STATE|WIFI_ASOC_STATE)) {
+		connectStatus =3D HCI_WIFI_CONNECTED;
+	} else if (check_fwstate(&padapter->mlmepriv, WIFI_UNDER_LINKING)) {
+		connectStatus =3D HCI_WIFI_CONNECT_IN_PROGRESS;
+	} else {
+		connectStatus =3D HCI_WIFI_NOT_CONNECTED;
+	}
+
+	{
+		u8 localBuf[8] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_EXTENSION,
+			HCI_WIFI_CONNECTION_STATUS,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;			/* status */
+		pRetPar[1] =3D connectStatus;	/* connect status */
+		len +=3D 2;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdEnableDeviceUnderTestMode(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+
+	pBtHciInfo->bInTestMode =3D true;
+	pBtHciInfo->bTestIsEnd =3D false;
+
+	/* send command complete event here when all data are received. */
+	{
+		u8 localBuf[6] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_TESTING_COMMANDS,
+			HCI_ENABLE_DEVICE_UNDER_TEST_MODE,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;		/* status */
+		len +=3D 1;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdAMPTestEnd(struct rtw_adapter *padapter,
+		    struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u8 bFilterOutNonAssociatedBSSID =3D true;
+
+	if (!pBtHciInfo->bInTestMode) {
+		RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("Not in Test mode, =
return status =3D HCI_STATUS_CMD_DISALLOW\n"));
+		status =3D HCI_STATUS_CMD_DISALLOW;
+		return status;
+	}
+
+	pBtHciInfo->bTestIsEnd =3D true;
+
+	del_timer_sync(&pBTInfo->BTTestSendPacketTimer);
+
+	rtw_hal_set_hwreg23a(padapter, HW_VAR_CHECK_BSSID, (u8 *)(&bFilterOut=
NonAssociatedBSSID));
+
+	/* send command complete event here when all data are received. */
+	{
+		u8 localBuf[4] =3D "";
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("AMP Test End Event=
 \n"));
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+		PPacketIrpEvent->EventCode =3D HCI_EVENT_AMP_TEST_END;
+		PPacketIrpEvent->Length =3D 2;
+
+		PPacketIrpEvent->Data[0] =3D status;
+		PPacketIrpEvent->Data[1] =3D pBtHciInfo->TestScenario;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, 4);
+	}
+
+	bthci_EventAMPReceiverReport(padapter, 0x01);
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdAMPTestCommand(struct rtw_adapter *padapter,
+			struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+
+	if (!pBtHciInfo->bInTestMode) {
+		RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("Not in Test mode, =
return status =3D HCI_STATUS_CMD_DISALLOW\n"));
+		status =3D HCI_STATUS_CMD_DISALLOW;
+		return status;
+	}
+
+	pBtHciInfo->TestScenario =3D *((u8 *)pHciCmd->Data);
+
+	if (pBtHciInfo->TestScenario =3D=3D 0x01)
+		RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("TX Single Test \n"=
));
+	else if (pBtHciInfo->TestScenario =3D=3D 0x02)
+		RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("Receive Frame Test=
 \n"));
+	else
+		RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("No Such Test !!!!!=
!!!!!!!!!!!!! \n"));
+
+	if (pBtHciInfo->bTestIsEnd) {
+		u8 localBuf[5] =3D "";
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("AMP Test End Event=
 \n"));
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+		PPacketIrpEvent->EventCode =3D HCI_EVENT_AMP_TEST_END;
+		PPacketIrpEvent->Length =3D 2;
+
+		PPacketIrpEvent->Data[0] =3D status;
+		PPacketIrpEvent->Data[1] =3D pBtHciInfo->TestScenario ;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, 4);
+
+		/* Return to Idel state with RX and TX off. */
+
+		return status;
+	}
+
+	/*  should send command status event */
+	bthci_EventCommandStatus(padapter,
+			OGF_TESTING_COMMANDS,
+			HCI_AMP_TEST_COMMAND,
+			status);
+
+	/* The HCI_AMP_Start Test Event shall be generated when the */
+	/* HCI_AMP_Test_Command has completed and the first data is ready to =
be sent */
+	/* or received. */
+
+	{
+		u8 localBuf[5] =3D "";
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), (" HCI_AMP_Start Tes=
t Event \n"));
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+		PPacketIrpEvent->EventCode =3D HCI_EVENT_AMP_START_TEST;
+		PPacketIrpEvent->Length =3D 2;
+
+		PPacketIrpEvent->Data[0] =3D status;
+		PPacketIrpEvent->Data[1] =3D pBtHciInfo->TestScenario ;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, 4);
+
+		/* Return to Idel state with RX and TX off. */
+	}
+
+	if (pBtHciInfo->TestScenario =3D=3D 0x01) {
+		/*
+			When in a transmitter test scenario and the frames/bursts count hav=
e been
+			transmitted the HCI_AMP_Test_End event shall be sent.
+		*/
+		mod_timer(&pBTInfo->BTTestSendPacketTimer,
+			  jiffies + msecs_to_jiffies(50));
+		RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("TX Single Test \n"=
));
+	} else if (pBtHciInfo->TestScenario =3D=3D 0x02) {
+		u8 bFilterOutNonAssociatedBSSID =3D false;
+		rtw_hal_set_hwreg23a(padapter, HW_VAR_CHECK_BSSID, (u8 *)(&bFilterOu=
tNonAssociatedBSSID));
+		RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_BT_LOGO), ("Receive Frame Test=
 \n"));
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdEnableAMPReceiverReports(struct rtw_adapter *padapter,
+				  struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+
+	if (!pBtHciInfo->bInTestMode) {
+		status =3D HCI_STATUS_CMD_DISALLOW;
+		/* send command complete event here when all data are received. */
+		{
+			u8 localBuf[6] =3D "";
+			u8 *pRetPar;
+			u8 len =3D 0;
+			struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+			PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0=
]);
+
+			len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+				OGF_TESTING_COMMANDS,
+				HCI_ENABLE_AMP_RECEIVER_REPORTS,
+				status);
+
+			/*  Return parameters starts from here */
+			pRetPar =3D &PPacketIrpEvent->Data[len];
+			pRetPar[0] =3D status;		/* status */
+			len +=3D 1;
+			PPacketIrpEvent->Length =3D len;
+
+			bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+		}
+		return status;
+	}
+
+	pBtHciInfo->bTestNeedReport =3D *((u8 *)pHciCmd->Data);
+	pBtHciInfo->TestReportInterval =3D (*((u8 *)pHciCmd->Data+2));
+
+	bthci_EventAMPReceiverReport(padapter, 0x00);
+
+	/* send command complete event here when all data are received. */
+	{
+		u8 localBuf[6] =3D "";
+		u8 *pRetPar;
+		u8 len =3D 0;
+		struct packet_irp_hcievent_data *PPacketIrpEvent;
+
+		PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0]=
);
+
+		len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+			OGF_TESTING_COMMANDS,
+			HCI_ENABLE_AMP_RECEIVER_REPORTS,
+			status);
+
+		/*  Return parameters starts from here */
+		pRetPar =3D &PPacketIrpEvent->Data[len];
+		pRetPar[0] =3D status;		/* status */
+		len +=3D 1;
+		PPacketIrpEvent->Length =3D len;
+
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+	}
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdHostBufferSize(struct rtw_adapter *padapter,
+			struct packet_irp_hcicmd_data *pHciCmd)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	u8 localBuf[6] =3D "";
+	u8 *pRetPar;
+	u8 len =3D 0;
+
+	pBTInfo->BtAsocEntry[pBtMgnt->CurrentConnectEntryNum].ACLPacketsData.=
ACLDataPacketLen =3D *((u16 *)pHciCmd->Data);
+	pBTInfo->BtAsocEntry[pBtMgnt->CurrentConnectEntryNum].SyncDataPacketL=
en =3D *((u8 *)(pHciCmd->Data+2));
+	pBTInfo->BtAsocEntry[pBtMgnt->CurrentConnectEntryNum].TotalNumACLData=
Packets =3D *((u16 *)(pHciCmd->Data+3));
+	pBTInfo->BtAsocEntry[pBtMgnt->CurrentConnectEntryNum].TotalSyncNumDat=
aPackets =3D *((u16 *)(pHciCmd->Data+5));
+
+	/* send command complete event here when all data are received. */
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	len +=3D bthci_CommandCompleteHeader(&localBuf[0],
+		OGF_SET_EVENT_MASK_COMMAND,
+		HCI_HOST_BUFFER_SIZE,
+		status);
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[len];
+	pRetPar[0] =3D status;		/* status */
+	len +=3D 1;
+	PPacketIrpEvent->Length =3D len;
+
+	bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+
+	return status;
+}
+
+static enum hci_status
+bthci_CmdHostNumberOfCompletedPackets(struct rtw_adapter *padapter,
+				      struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+
+	return status;
+}
+
+static enum hci_status
+bthci_UnknownCMD(struct rtw_adapter *padapter, struct packet_irp_hcicm=
d_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_UNKNOW_HCI_CMD;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_dgb *pBtDbg =3D &pBTInfo->BtDbg;
+
+	pBtDbg->dbgHciInfo.hciCmdCntUnknown++;
+	bthci_EventCommandStatus(padapter,
+			(u8)pHciCmd->OGF,
+			pHciCmd->OCF,
+			status);
+
+	return status;
+}
+
+static enum hci_status
+bthci_HandleOGFInformationalParameters(struct rtw_adapter *padapter,
+				       struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+
+	switch (pHciCmd->OCF) {
+	case HCI_READ_LOCAL_VERSION_INFORMATION:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_READ_LOCAL_VERSION_INFORMATIO=
N\n"));
+		status =3D bthci_CmdReadLocalVersionInformation(padapter);
+		break;
+	case HCI_READ_LOCAL_SUPPORTED_COMMANDS:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_READ_LOCAL_SUPPORTED_COMMANDS=
\n"));
+		status =3D bthci_CmdReadLocalSupportedCommands(padapter);
+		break;
+	case HCI_READ_LOCAL_SUPPORTED_FEATURES:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_READ_LOCAL_SUPPORTED_FEATURES=
\n"));
+		status =3D bthci_CmdReadLocalSupportedFeatures(padapter);
+		break;
+	case HCI_READ_BUFFER_SIZE:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_READ_BUFFER_SIZE\n"));
+		status =3D bthci_CmdReadBufferSize(padapter);
+		break;
+	case HCI_READ_DATA_BLOCK_SIZE:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_READ_DATA_BLOCK_SIZE\n"));
+		status =3D bthci_CmdReadDataBlockSize(padapter);
+		break;
+	default:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("bthci_HandleOGFInformationalParam=
eters(), Unknown case =3D 0x%x\n", pHciCmd->OCF));
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_UNKNOWN_COMMAND\n"));
+		status =3D bthci_UnknownCMD(padapter, pHciCmd);
+		break;
+	}
+	return status;
+}
+
+static enum hci_status
+bthci_HandleOGFSetEventMaskCMD(struct rtw_adapter *padapter,
+			       struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+
+	switch (pHciCmd->OCF) {
+	case HCI_SET_EVENT_MASK:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_SET_EVENT_MASK\n"));
+		status =3D bthci_CmdSetEventMask(padapter, pHciCmd);
+		break;
+	case HCI_RESET:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_RESET\n"));
+		status =3D bthci_CmdReset(padapter, true);
+		break;
+	case HCI_READ_CONNECTION_ACCEPT_TIMEOUT:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_READ_CONNECTION_ACCEPT_TIMEOU=
T\n"));
+		status =3D bthci_CmdReadConnectionAcceptTimeout(padapter);
+		break;
+	case HCI_SET_EVENT_FILTER:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_SET_EVENT_FILTER\n"));
+		status =3D bthci_CmdSetEventFilter(padapter, pHciCmd);
+		break;
+	case HCI_WRITE_CONNECTION_ACCEPT_TIMEOUT:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_WRITE_CONNECTION_ACCEPT_TIMEO=
UT\n"));
+		status =3D bthci_CmdWriteConnectionAcceptTimeout(padapter, pHciCmd);
+		break;
+	case HCI_READ_PAGE_TIMEOUT:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_READ_PAGE_TIMEOUT\n"));
+		status =3D bthci_CmdReadPageTimeout(padapter, pHciCmd);
+		break;
+	case HCI_WRITE_PAGE_TIMEOUT:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_WRITE_PAGE_TIMEOUT\n"));
+		status =3D bthci_CmdWritePageTimeout(padapter, pHciCmd);
+		break;
+	case HCI_HOST_NUMBER_OF_COMPLETED_PACKETS:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_HOST_NUMBER_OF_COMPLETED_PACK=
ETS\n"));
+		status =3D bthci_CmdHostNumberOfCompletedPackets(padapter, pHciCmd);
+		break;
+	case HCI_READ_LINK_SUPERVISION_TIMEOUT:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_READ_LINK_SUPERVISION_TIMEOUT=
\n"));
+		status =3D bthci_CmdReadLinkSupervisionTimeout(padapter, pHciCmd);
+		break;
+	case HCI_WRITE_LINK_SUPERVISION_TIMEOUT:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_WRITE_LINK_SUPERVISION_TIMEOU=
T\n"));
+		status =3D bthci_CmdWriteLinkSupervisionTimeout(padapter, pHciCmd);
+		break;
+	case HCI_ENHANCED_FLUSH:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_ENHANCED_FLUSH\n"));
+		status =3D bthci_CmdEnhancedFlush(padapter, pHciCmd);
+		break;
+	case HCI_READ_LOGICAL_LINK_ACCEPT_TIMEOUT:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_READ_LOGICAL_LINK_ACCEPT_TIME=
OUT\n"));
+		status =3D bthci_CmdReadLogicalLinkAcceptTimeout(padapter, pHciCmd);
+		break;
+	case HCI_WRITE_LOGICAL_LINK_ACCEPT_TIMEOUT:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_WRITE_LOGICAL_LINK_ACCEPT_TIM=
EOUT\n"));
+		status =3D bthci_CmdWriteLogicalLinkAcceptTimeout(padapter, pHciCmd)=
;
+		break;
+	case HCI_SET_EVENT_MASK_PAGE_2:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_SET_EVENT_MASK_PAGE_2\n"));
+		status =3D bthci_CmdSetEventMaskPage2(padapter, pHciCmd);
+		break;
+	case HCI_READ_LOCATION_DATA:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_READ_LOCATION_DATA\n"));
+		status =3D bthci_CmdReadLocationData(padapter, pHciCmd);
+		break;
+	case HCI_WRITE_LOCATION_DATA:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_WRITE_LOCATION_DATA\n"));
+		status =3D bthci_CmdWriteLocationData(padapter, pHciCmd);
+		break;
+	case HCI_READ_FLOW_CONTROL_MODE:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_READ_FLOW_CONTROL_MODE\n"));
+		status =3D bthci_CmdReadFlowControlMode(padapter, pHciCmd);
+		break;
+	case HCI_WRITE_FLOW_CONTROL_MODE:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_WRITE_FLOW_CONTROL_MODE\n"));
+		status =3D bthci_CmdWriteFlowControlMode(padapter, pHciCmd);
+		break;
+	case HCI_READ_BEST_EFFORT_FLUSH_TIMEOUT:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_READ_BEST_EFFORT_FLUSH_TIMEOU=
T\n"));
+		status =3D bthci_CmdReadBestEffortFlushTimeout(padapter, pHciCmd);
+		break;
+	case HCI_WRITE_BEST_EFFORT_FLUSH_TIMEOUT:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_WRITE_BEST_EFFORT_FLUSH_TIMEO=
UT\n"));
+		status =3D bthci_CmdWriteBestEffortFlushTimeout(padapter, pHciCmd);
+		break;
+	case HCI_SHORT_RANGE_MODE:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_SHORT_RANGE_MODE\n"));
+		status =3D bthci_CmdShortRangeMode(padapter, pHciCmd);
+		break;
+	case HCI_HOST_BUFFER_SIZE:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_HOST_BUFFER_SIZE\n"));
+		status =3D bthci_CmdHostBufferSize(padapter, pHciCmd);
+		break;
+	default:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("bthci_HandleOGFSetEventMaskCMD(),=
 Unknown case =3D 0x%x\n", pHciCmd->OCF));
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_UNKNOWN_COMMAND\n"));
+		status =3D bthci_UnknownCMD(padapter, pHciCmd);
+		break;
+	}
+	return status;
+}
+
+static enum hci_status
+bthci_HandleOGFStatusParameters(struct rtw_adapter *padapter,
+				struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+
+	switch (pHciCmd->OCF) {
+	case HCI_READ_FAILED_CONTACT_COUNTER:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_READ_FAILED_CONTACT_COUNTER\n=
"));
+		status =3D bthci_CmdReadFailedContactCounter(padapter, pHciCmd);
+		break;
+	case HCI_RESET_FAILED_CONTACT_COUNTER:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_RESET_FAILED_CONTACT_COUNTER\=
n"));
+		status =3D bthci_CmdResetFailedContactCounter(padapter, pHciCmd);
+		break;
+	case HCI_READ_LINK_QUALITY:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_READ_LINK_QUALITY\n"));
+		status =3D bthci_CmdReadLinkQuality(padapter, pHciCmd);
+		break;
+	case HCI_READ_RSSI:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_READ_RSSI\n"));
+		status =3D bthci_CmdReadRSSI(padapter);
+		break;
+	case HCI_READ_LOCAL_AMP_INFO:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_READ_LOCAL_AMP_INFO\n"));
+		status =3D bthci_CmdReadLocalAMPInfo(padapter);
+		break;
+	case HCI_READ_LOCAL_AMP_ASSOC:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_READ_LOCAL_AMP_ASSOC\n"));
+		status =3D bthci_CmdReadLocalAMPAssoc(padapter, pHciCmd);
+		break;
+	case HCI_WRITE_REMOTE_AMP_ASSOC:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_WRITE_REMOTE_AMP_ASSOC\n"));
+		status =3D bthci_CmdWriteRemoteAMPAssoc(padapter, pHciCmd);
+		break;
+	default:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("bthci_HandleOGFStatusParameters()=
, Unknown case =3D 0x%x\n", pHciCmd->OCF));
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_UNKNOWN_COMMAND\n"));
+		status =3D bthci_UnknownCMD(padapter, pHciCmd);
+		break;
+	}
+	return status;
+}
+
+static enum hci_status
+bthci_HandleOGFLinkControlCMD(struct rtw_adapter *padapter,
+			      struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+
+	switch (pHciCmd->OCF) {
+	case HCI_CREATE_PHYSICAL_LINK:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_CREATE_PHYSICAL_LINK\n"));
+		status =3D bthci_CmdCreatePhysicalLink(padapter, pHciCmd);
+		break;
+	case HCI_ACCEPT_PHYSICAL_LINK:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_ACCEPT_PHYSICAL_LINK\n"));
+		status =3D bthci_CmdAcceptPhysicalLink(padapter, pHciCmd);
+		break;
+	case HCI_DISCONNECT_PHYSICAL_LINK:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_DISCONNECT_PHYSICAL_LINK\n"))=
;
+		status =3D bthci_CmdDisconnectPhysicalLink(padapter, pHciCmd);
+		break;
+	case HCI_CREATE_LOGICAL_LINK:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_CREATE_LOGICAL_LINK\n"));
+		status =3D bthci_CmdCreateLogicalLink(padapter, pHciCmd);
+		break;
+	case HCI_ACCEPT_LOGICAL_LINK:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_ACCEPT_LOGICAL_LINK\n"));
+		status =3D bthci_CmdAcceptLogicalLink(padapter, pHciCmd);
+		break;
+	case HCI_DISCONNECT_LOGICAL_LINK:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_DISCONNECT_LOGICAL_LINK\n"));
+		status =3D bthci_CmdDisconnectLogicalLink(padapter, pHciCmd);
+		break;
+	case HCI_LOGICAL_LINK_CANCEL:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_LOGICAL_LINK_CANCEL\n"));
+		status =3D bthci_CmdLogicalLinkCancel(padapter, pHciCmd);
+		break;
+	case HCI_FLOW_SPEC_MODIFY:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_FLOW_SPEC_MODIFY\n"));
+		status =3D bthci_CmdFlowSpecModify(padapter, pHciCmd);
+		break;
+	default:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("bthci_HandleOGFLinkControlCMD(), =
Unknown case =3D 0x%x\n", pHciCmd->OCF));
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_UNKNOWN_COMMAND\n"));
+		status =3D bthci_UnknownCMD(padapter, pHciCmd);
+		break;
+	}
+	return status;
+}
+
+static enum hci_status
+bthci_HandleOGFTestingCMD(struct rtw_adapter *padapter,
+			  struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	switch (pHciCmd->OCF) {
+	case HCI_ENABLE_DEVICE_UNDER_TEST_MODE:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_ENABLE_DEVICE_UNDER_TEST_MODE=
\n"));
+		bthci_CmdEnableDeviceUnderTestMode(padapter, pHciCmd);
+		break;
+	case HCI_AMP_TEST_END:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_AMP_TEST_END\n"));
+		bthci_CmdAMPTestEnd(padapter, pHciCmd);
+		break;
+	case HCI_AMP_TEST_COMMAND:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_AMP_TEST_COMMAND\n"));
+		bthci_CmdAMPTestCommand(padapter, pHciCmd);
+		break;
+	case HCI_ENABLE_AMP_RECEIVER_REPORTS:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_ENABLE_AMP_RECEIVER_REPORTS\n=
"));
+		bthci_CmdEnableAMPReceiverReports(padapter, pHciCmd);
+		break;
+	default:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_UNKNOWN_COMMAND\n"));
+		status =3D bthci_UnknownCMD(padapter, pHciCmd);
+		break;
+	}
+	return status;
+}
+
+static enum hci_status
+bthci_HandleOGFExtension(struct rtw_adapter *padapter,
+			 struct packet_irp_hcicmd_data *pHciCmd)
+{
+	enum hci_status status =3D HCI_STATUS_SUCCESS;
+	switch (pHciCmd->OCF) {
+	case HCI_SET_ACL_LINK_DATA_FLOW_MODE:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("HCI_SET_ACL_LINK_DATA_FLOW_MO=
DE\n"));
+		status =3D bthci_CmdSetACLLinkDataFlowMode(padapter, pHciCmd);
+		break;
+	case HCI_SET_ACL_LINK_STATUS:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("HCI_SET_ACL_LINK_STATUS\n"));
+		status =3D bthci_CmdSetACLLinkStatus(padapter, pHciCmd);
+		break;
+	case HCI_SET_SCO_LINK_STATUS:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("HCI_SET_SCO_LINK_STATUS\n"));
+		status =3D bthci_CmdSetSCOLinkStatus(padapter, pHciCmd);
+		break;
+	case HCI_SET_RSSI_VALUE:
+		RTPRINT(FIOCTL, IOCTL_BT_EVENT_PERIODICAL, ("HCI_SET_RSSI_VALUE\n"))=
;
+		status =3D bthci_CmdSetRSSIValue(padapter, pHciCmd);
+		break;
+	case HCI_SET_CURRENT_BLUETOOTH_STATUS:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("HCI_SET_CURRENT_BLUETOOTH_STA=
TUS\n"));
+		status =3D bthci_CmdSetCurrentBluetoothStatus(padapter, pHciCmd);
+		break;
+	/* The following is for RTK8723 */
+
+	case HCI_EXTENSION_VERSION_NOTIFY:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("HCI_EXTENSION_VERSION_NOTIFY\=
n"));
+		status =3D bthci_CmdExtensionVersionNotify(padapter, pHciCmd);
+		break;
+	case HCI_LINK_STATUS_NOTIFY:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("HCI_LINK_STATUS_NOTIFY\n"));
+		status =3D bthci_CmdLinkStatusNotify(padapter, pHciCmd);
+		break;
+	case HCI_BT_OPERATION_NOTIFY:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("HCI_BT_OPERATION_NOTIFY\n"));
+		status =3D bthci_CmdBtOperationNotify(padapter, pHciCmd);
+		break;
+	case HCI_ENABLE_WIFI_SCAN_NOTIFY:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("HCI_ENABLE_WIFI_SCAN_NOTIFY\n=
"));
+		status =3D bthci_CmdEnableWifiScanNotify(padapter, pHciCmd);
+		break;
+
+	/* The following is for IVT */
+	case HCI_WIFI_CURRENT_CHANNEL:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("HCI_WIFI_CURRENT_CHANNEL\n"))=
;
+		status =3D bthci_CmdWIFICurrentChannel(padapter, pHciCmd);
+		break;
+	case HCI_WIFI_CURRENT_BANDWIDTH:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("HCI_WIFI_CURRENT_BANDWIDTH\n"=
));
+		status =3D bthci_CmdWIFICurrentBandwidth(padapter, pHciCmd);
+		break;
+	case HCI_WIFI_CONNECTION_STATUS:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("HCI_WIFI_CONNECTION_STATUS\n"=
));
+		status =3D bthci_CmdWIFIConnectionStatus(padapter, pHciCmd);
+		break;
+
+	default:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("HCI_UNKNOWN_COMMAND\n"));
+		status =3D bthci_UnknownCMD(padapter, pHciCmd);
+		break;
+	}
+	return status;
+}
+
+static void
+bthci_StateStarting(struct rtw_adapter *padapter,
+		    enum hci_state_with_cmd StateCmd, u8 EntryNum)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	RTPRINT(FIOCTL, IOCTL_STATE, ("[BT state], [Starting], "));
+	switch (StateCmd) {
+	case STATE_CMD_CONNECT_ACCEPT_TIMEOUT:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_CONNECT_ACCEPT_TIMEOUT\n"))=
;
+		pBTInfo->BtAsocEntry[EntryNum].PhysLinkCompleteStatus =3D HCI_STATUS=
_CONNECT_ACCEPT_TIMEOUT;
+		pBtMgnt->bNeedNotifyAMPNoCap =3D true;
+		BTHCI_DisconnectPeer(padapter, EntryNum);
+		break;
+	case STATE_CMD_DISCONNECT_PHY_LINK:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_DISCONNECT_PHY_LINK\n"));
+
+		bthci_EventDisconnectPhyLinkComplete(padapter,
+		HCI_STATUS_SUCCESS,
+		pBTInfo->BtAsocEntry[EntryNum].PhyLinkDisconnectReason,
+		EntryNum);
+
+		del_timer_sync(&pBTInfo->BTHCIJoinTimeoutTimer);
+
+		pBTInfo->BtAsocEntry[EntryNum].PhysLinkCompleteStatus =3D HCI_STATUS=
_UNKNOW_CONNECT_ID;
+
+		BTHCI_DisconnectPeer(padapter, EntryNum);
+		break;
+	case STATE_CMD_MAC_START_COMPLETE:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_MAC_START_COMPLETE\n"));
+		if (pBTInfo->BtAsocEntry[EntryNum].AMPRole =3D=3D AMP_BTAP_CREATOR)
+			bthci_EventChannelSelected(padapter, EntryNum);
+		break;
+	default:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("State command(%d) is Wrong !!!\n", St=
ateCmd));
+		break;
+	}
+}
+
+static void
+bthci_StateConnecting(struct rtw_adapter *padapter,
+		      enum hci_state_with_cmd StateCmd, u8 EntryNum)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	RTPRINT(FIOCTL, IOCTL_STATE, ("[BT state], [Connecting], "));
+	switch (StateCmd) {
+	case STATE_CMD_CONNECT_ACCEPT_TIMEOUT:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_CONNECT_ACCEPT_TIMEOUT\n"))=
;
+		pBTInfo->BtAsocEntry[EntryNum].PhysLinkCompleteStatus =3D HCI_STATUS=
_CONNECT_ACCEPT_TIMEOUT;
+		pBtMgnt->bNeedNotifyAMPNoCap =3D true;
+		BTHCI_DisconnectPeer(padapter, EntryNum);
+		break;
+	case STATE_CMD_MAC_CONNECT_COMPLETE:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_MAC_CONNECT_COMPLETE\n"));
+
+		if (pBTInfo->BtAsocEntry[EntryNum].AMPRole =3D=3D AMP_BTAP_JOINER) {
+			RT_TRACE(_module_rtl871x_security_c_,
+				 _drv_info_, ("StateConnecting \n"));
+		}
+		break;
+	case STATE_CMD_DISCONNECT_PHY_LINK:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_DISCONNECT_PHY_LINK\n"));
+
+		bthci_EventDisconnectPhyLinkComplete(padapter,
+		HCI_STATUS_SUCCESS,
+		pBTInfo->BtAsocEntry[EntryNum].PhyLinkDisconnectReason,
+		EntryNum);
+
+		pBTInfo->BtAsocEntry[EntryNum].PhysLinkCompleteStatus =3D HCI_STATUS=
_UNKNOW_CONNECT_ID;
+
+		del_timer_sync(&pBTInfo->BTHCIJoinTimeoutTimer);
+
+		BTHCI_DisconnectPeer(padapter, EntryNum);
+
+		break;
+	case STATE_CMD_MAC_CONNECT_CANCEL_INDICATE:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_MAC_CONNECT_CANCEL_INDICATE=
\n"));
+		pBTInfo->BtAsocEntry[EntryNum].PhysLinkCompleteStatus =3D HCI_STATUS=
_CONTROLLER_BUSY;
+		/*  Because this state cmd is caused by the BTHCI_EventAMPStatusChan=
ge(), */
+		/*  we don't need to send event in the following BTHCI_DisconnectPee=
r() again. */
+		pBtMgnt->bNeedNotifyAMPNoCap =3D false;
+		BTHCI_DisconnectPeer(padapter, EntryNum);
+		break;
+	default:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("State command(%d) is Wrong !!!\n", St=
ateCmd));
+		break;
+	}
+}
+
+static void
+bthci_StateConnected(struct rtw_adapter *padapter,
+		     enum hci_state_with_cmd StateCmd, u8 EntryNum)
+{
+/*PMGNT_INFO pMgntInfo =3D &padapter->MgntInfo; */
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	RTPRINT(FIOCTL, IOCTL_STATE, ("[BT state], [Connected], "));
+	switch (StateCmd) {
+	u8 i;
+	u16 logicHandle =3D 0;
+	case STATE_CMD_DISCONNECT_PHY_LINK:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_DISCONNECT_PHY_LINK\n"));
+
+		/* When we are trying to disconnect the phy link, we should disconne=
ct log link first, */
+		for (i =3D 0; i < MAX_LOGICAL_LINK_NUM; i++) {
+			if (pBTInfo->BtAsocEntry[EntryNum].LogLinkCmdData->BtLogLinkhandle =
!=3D 0) {
+				logicHandle =3D pBTInfo->BtAsocEntry[EntryNum].LogLinkCmdData->BtL=
ogLinkhandle;
+
+				bthci_EventDisconnectLogicalLinkComplete(padapter, HCI_STATUS_SUCC=
ESS,
+					logicHandle, pBTInfo->BtAsocEntry[EntryNum].PhyLinkDisconnectReas=
on);
+
+				pBTInfo->BtAsocEntry[EntryNum].LogLinkCmdData->BtLogLinkhandle =3D=
 0;
+			}
+		}
+
+		bthci_EventDisconnectPhyLinkComplete(padapter,
+		HCI_STATUS_SUCCESS,
+		pBTInfo->BtAsocEntry[EntryNum].PhyLinkDisconnectReason,
+		EntryNum);
+
+		del_timer_sync(&pBTInfo->BTHCIJoinTimeoutTimer);
+
+		BTHCI_DisconnectPeer(padapter, EntryNum);
+		break;
+
+	case STATE_CMD_MAC_DISCONNECT_INDICATE:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_MAC_DISCONNECT_INDICATE\n")=
);
+
+		bthci_EventDisconnectPhyLinkComplete(padapter,
+		HCI_STATUS_SUCCESS,
+		/*  TODO: Remote Host not local host */
+		HCI_STATUS_CONNECT_TERMINATE_LOCAL_HOST,
+		EntryNum);
+		BTHCI_DisconnectPeer(padapter, EntryNum);
+
+		break;
+	case STATE_CMD_ENTER_STATE:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_ENTER_STATE\n"));
+
+		if (pBtMgnt->bBTConnectInProgress) {
+			pBtMgnt->bBTConnectInProgress =3D false;
+			RTPRINT(FIOCTL, IOCTL_STATE, ("[BT Flag], BT Connect in progress OF=
=46!!\n"));
+		}
+		pBTInfo->BtAsocEntry[EntryNum].BtCurrentState =3D HCI_STATE_CONNECTE=
D;
+		pBTInfo->BtAsocEntry[EntryNum].b4waySuccess =3D true;
+		pBtMgnt->bStartSendSupervisionPkt =3D true;
+
+		/*  for rate adaptive */
+
+		if (padapter->HalFunc.UpdateRAMaskHandler)
+			padapter->HalFunc.UpdateRAMaskHandler(padapter, MAX_FW_SUPPORT_MACI=
D_NUM-1-EntryNum, 0);
+
+		rtw_hal_set_hwreg23a(padapter, HW_VAR_BASIC_RATE, padapter->mlmepriv=
=2Ecur_network.network.SupportedRates);
+		BTDM_SetFwChnlInfo(padapter, RT_MEDIA_CONNECT);
+		break;
+	default:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("State command(%d) is Wrong !!!\n", St=
ateCmd));
+		break;
+	}
+}
+
+static void
+bthci_StateAuth(struct rtw_adapter *padapter, enum hci_state_with_cmd =
StateCmd,
+		u8 EntryNum)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	RTPRINT(FIOCTL, IOCTL_STATE, ("[BT state], [Authenticating], "));
+	switch (StateCmd) {
+	case STATE_CMD_CONNECT_ACCEPT_TIMEOUT:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_CONNECT_ACCEPT_TIMEOUT\n"))=
;
+		pBTInfo->BtAsocEntry[EntryNum].PhysLinkCompleteStatus =3D HCI_STATUS=
_CONNECT_ACCEPT_TIMEOUT;
+		pBtMgnt->bNeedNotifyAMPNoCap =3D true;
+		BTHCI_DisconnectPeer(padapter, EntryNum);
+		break;
+	case STATE_CMD_DISCONNECT_PHY_LINK:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_DISCONNECT_PHY_LINK\n"));
+		bthci_EventDisconnectPhyLinkComplete(padapter,
+		HCI_STATUS_SUCCESS,
+		pBTInfo->BtAsocEntry[EntryNum].PhyLinkDisconnectReason,
+		EntryNum);
+
+		pBTInfo->BtAsocEntry[EntryNum].PhysLinkCompleteStatus =3D HCI_STATUS=
_UNKNOW_CONNECT_ID;
+
+		del_timer_sync(&pBTInfo->BTHCIJoinTimeoutTimer);
+
+		BTHCI_DisconnectPeer(padapter, EntryNum);
+		break;
+	case STATE_CMD_4WAY_FAILED:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_4WAY_FAILED\n"));
+
+		pBTInfo->BtAsocEntry[EntryNum].PhysLinkCompleteStatus =3D HCI_STATUS=
_AUTH_FAIL;
+		pBtMgnt->bNeedNotifyAMPNoCap =3D true;
+
+		BTHCI_DisconnectPeer(padapter, EntryNum);
+
+		del_timer_sync(&pBTInfo->BTHCIJoinTimeoutTimer);
+		break;
+	case STATE_CMD_4WAY_SUCCESSED:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_4WAY_SUCCESSED\n"));
+
+		bthci_EventPhysicalLinkComplete(padapter, HCI_STATUS_SUCCESS, EntryN=
um, INVALID_PL_HANDLE);
+
+		del_timer_sync(&pBTInfo->BTHCIJoinTimeoutTimer);
+
+		BTHCI_SM_WITH_INFO(padapter, HCI_STATE_CONNECTED, STATE_CMD_ENTER_ST=
ATE, EntryNum);
+		break;
+	default:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("State command(%d) is Wrong !!!\n", St=
ateCmd));
+		break;
+	}
+}
+
+static void
+bthci_StateDisconnecting(struct rtw_adapter *padapter,
+			 enum hci_state_with_cmd StateCmd, u8 EntryNum)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	RTPRINT(FIOCTL, IOCTL_STATE, ("[BT state], [Disconnecting], "));
+	switch (StateCmd) {
+	case STATE_CMD_MAC_CONNECT_CANCEL_INDICATE:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_MAC_CONNECT_CANCEL_INDICATE=
\n"));
+		if (pBTInfo->BtAsocEntry[EntryNum].bNeedPhysLinkCompleteEvent) {
+			bthci_EventPhysicalLinkComplete(padapter,
+				pBTInfo->BtAsocEntry[EntryNum].PhysLinkCompleteStatus,
+				EntryNum, INVALID_PL_HANDLE);
+		}
+
+		if (pBtMgnt->bBTConnectInProgress) {
+			pBtMgnt->bBTConnectInProgress =3D false;
+			RTPRINT(FIOCTL, IOCTL_STATE, ("[BT Flag], BT Connect in progress OF=
=46!!\n"));
+		}
+
+		BTHCI_SM_WITH_INFO(padapter, HCI_STATE_DISCONNECTED, STATE_CMD_ENTER=
_STATE, EntryNum);
+		break;
+	case STATE_CMD_DISCONNECT_PHY_LINK:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_DISCONNECT_PHY_LINK\n"));
+
+		bthci_EventDisconnectPhyLinkComplete(padapter,
+		HCI_STATUS_SUCCESS,
+		pBTInfo->BtAsocEntry[EntryNum].PhyLinkDisconnectReason,
+		EntryNum);
+
+		del_timer_sync(&pBTInfo->BTHCIJoinTimeoutTimer);
+
+		BTHCI_DisconnectPeer(padapter, EntryNum);
+		break;
+	default:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("State command(%d) is Wrong !!!\n", St=
ateCmd));
+		break;
+	}
+}
+
+static void
+bthci_StateDisconnected(struct rtw_adapter *padapter,
+			enum hci_state_with_cmd StateCmd, u8 EntryNum)
+{
+/*PMGNT_INFO pMgntInfo =3D &padapter->MgntInfo; */
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	RTPRINT(FIOCTL, IOCTL_STATE, ("[BT state], [Disconnected], "));
+	switch (StateCmd) {
+	case STATE_CMD_CREATE_PHY_LINK:
+	case STATE_CMD_ACCEPT_PHY_LINK:
+		if (StateCmd =3D=3D STATE_CMD_CREATE_PHY_LINK)
+			RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_CREATE_PHY_LINK\n"));
+		else
+			RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_ACCEPT_PHY_LINK\n"));
+
+		RTPRINT(FIOCTL, IOCTL_STATE, ("[BT PS], Disable IPS and LPS\n"));
+		ips_leave23a(padapter);
+		LPS_Leave23a(padapter);
+
+		pBtMgnt->bPhyLinkInProgress =3D true;
+		pBtMgnt->BTCurrentConnectType =3D BT_DISCONNECT;
+		pBtMgnt->CurrentBTConnectionCnt++;
+		RTPRINT(FIOCTL, IOCTL_STATE, ("[BT Flag], CurrentBTConnectionCnt =3D=
 %d\n",
+			pBtMgnt->CurrentBTConnectionCnt));
+		pBtMgnt->BtOperationOn =3D true;
+		RTPRINT(FIOCTL, IOCTL_STATE, ("[BT Flag], Bt Operation ON!! CurrentC=
onnectEntryNum =3D %d\n",
+			pBtMgnt->CurrentConnectEntryNum));
+
+		if (pBtMgnt->bBTConnectInProgress) {
+			bthci_EventPhysicalLinkComplete(padapter, HCI_STATUS_CONTROLLER_BUS=
Y, INVALID_ENTRY_NUM, pBtMgnt->BtCurrentPhyLinkhandle);
+			bthci_RemoveEntryByEntryNum(padapter, EntryNum);
+			return;
+		}
+
+		if (StateCmd =3D=3D STATE_CMD_CREATE_PHY_LINK)
+			pBTInfo->BtAsocEntry[EntryNum].AMPRole =3D AMP_BTAP_CREATOR;
+		else
+			pBTInfo->BtAsocEntry[EntryNum].AMPRole =3D AMP_BTAP_JOINER;
+
+		/*  1. MAC not yet in selected channel */
+		while (check_fwstate(&padapter->mlmepriv, WIFI_ASOC_STATE|WIFI_SITE_=
MONITOR)) {
+			RTPRINT(FIOCTL, IOCTL_STATE, ("Scan/Roaming/Wifi Link is in Progres=
s, wait 200 ms\n"));
+			mdelay(200);
+		}
+		/*  2. MAC already in selected channel */
+		RTPRINT(FIOCTL, IOCTL_STATE, ("Channel is Ready\n"));
+		mod_timer(&pBTInfo->BTHCIJoinTimeoutTimer,
+			  jiffies + msecs_to_jiffies(pBtHciInfo->ConnAcceptTimeout));
+
+		pBTInfo->BtAsocEntry[EntryNum].bNeedPhysLinkCompleteEvent =3D true;
+		break;
+	case STATE_CMD_DISCONNECT_PHY_LINK:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_DISCONNECT_PHY_LINK\n"));
+
+		del_timer_sync(&pBTInfo->BTHCIJoinTimeoutTimer);
+
+		bthci_EventDisconnectPhyLinkComplete(padapter,
+		HCI_STATUS_SUCCESS,
+		pBTInfo->BtAsocEntry[EntryNum].PhyLinkDisconnectReason,
+		EntryNum);
+
+		if (pBTInfo->BtAsocEntry[EntryNum].bNeedPhysLinkCompleteEvent) {
+			bthci_EventPhysicalLinkComplete(padapter,
+				HCI_STATUS_UNKNOW_CONNECT_ID,
+				EntryNum, INVALID_PL_HANDLE);
+		}
+
+		if (pBtMgnt->bBTConnectInProgress) {
+			pBtMgnt->bBTConnectInProgress =3D false;
+			RTPRINT(FIOCTL, IOCTL_STATE, ("[BT Flag], BT Connect in progress OF=
=46!!\n"));
+		}
+		BTHCI_SM_WITH_INFO(padapter, HCI_STATE_DISCONNECTED, STATE_CMD_ENTER=
_STATE, EntryNum);
+		bthci_RemoveEntryByEntryNum(padapter, EntryNum);
+		break;
+	case STATE_CMD_ENTER_STATE:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("STATE_CMD_ENTER_STATE\n"));
+		break;
+	default:
+		RTPRINT(FIOCTL, IOCTL_STATE, ("State command(%d) is Wrong !!!\n", St=
ateCmd));
+		break;
+	}
+}
+
+void BTHCI_EventParse(struct rtw_adapter *padapter, void *pEvntData, u=
32 dataLen)
+{
+}
+
+u8 BTHCI_HsConnectionEstablished(struct rtw_adapter *padapter)
+{
+	u8 bBtConnectionExist =3D false;
+	struct bt_30info *pBtinfo =3D GET_BT_INFO(padapter);
+	u8 i;
+
+	for (i =3D 0; i < MAX_BT_ASOC_ENTRY_NUM; i++) {
+		if (pBtinfo->BtAsocEntry[i].b4waySuccess) {
+			bBtConnectionExist =3D true;
+			break;
+		}
+	}
+
+/*RTPRINT(FIOCTL, IOCTL_STATE, (" BTHCI_HsConnectionEstablished(), con=
nection exist =3D %d\n", bBtConnectionExist)); */
+
+	return bBtConnectionExist;
+}
+
+static u8
+BTHCI_CheckProfileExist(struct rtw_adapter *padapter,
+			enum bt_traffic_mode_profile Profile)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	u8 IsPRofile =3D false;
+	u8 i =3D 0;
+
+	for (i =3D 0; i < pBtMgnt->ExtConfig.NumberOfHandle; i++) {
+		if (pBtMgnt->ExtConfig.linkInfo[i].TrafficProfile =3D=3D Profile) {
+			IsPRofile =3D true;
+			break;
+		}
+	}
+
+	return IsPRofile;
+}
+
+void BTHCI_UpdateBTProfileRTKToMoto(struct rtw_adapter *padapter)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	u8 i =3D 0;
+
+	pBtMgnt->ExtConfig.NumberOfSCO =3D 0;
+
+	for (i =3D 0; i < pBtMgnt->ExtConfig.NumberOfHandle; i++) {
+		pBtMgnt->ExtConfig.linkInfo[i].TrafficProfile =3D BT_PROFILE_NONE;
+
+		if (pBtMgnt->ExtConfig.linkInfo[i].BTProfile =3D=3D BT_PROFILE_SCO)
+			pBtMgnt->ExtConfig.NumberOfSCO++;
+
+		pBtMgnt->ExtConfig.linkInfo[i].TrafficProfile =3D pBtMgnt->ExtConfig=
=2ElinkInfo[i].BTProfile;
+		switch (pBtMgnt->ExtConfig.linkInfo[i].TrafficProfile) {
+		case BT_PROFILE_SCO:
+			break;
+		case BT_PROFILE_PAN:
+			pBtMgnt->ExtConfig.linkInfo[i].IncomingTrafficMode =3D BT_MOTOR_EXT=
_BE;
+			pBtMgnt->ExtConfig.linkInfo[i].OutgoingTrafficMode =3D BT_MOTOR_EXT=
_BE;
+			break;
+		case BT_PROFILE_A2DP:
+			pBtMgnt->ExtConfig.linkInfo[i].IncomingTrafficMode =3D BT_MOTOR_EXT=
_GULB;
+			pBtMgnt->ExtConfig.linkInfo[i].OutgoingTrafficMode =3D BT_MOTOR_EXT=
_GULB;
+			break;
+		case BT_PROFILE_HID:
+			pBtMgnt->ExtConfig.linkInfo[i].IncomingTrafficMode =3D BT_MOTOR_EXT=
_GUL;
+			pBtMgnt->ExtConfig.linkInfo[i].OutgoingTrafficMode =3D BT_MOTOR_EXT=
_BE;
+			break;
+		default:
+			break;
+		}
+	}
+
+	RTPRINT(FBT, BT_TRACE, ("[DM][BT], RTK, NumberOfHandle =3D %d, Number=
OfSCO =3D %d\n",
+		pBtMgnt->ExtConfig.NumberOfHandle, pBtMgnt->ExtConfig.NumberOfSCO));
+}
+
+void BTHCI_WifiScanNotify(struct rtw_adapter *padapter, u8 scanType)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	if (pBtMgnt->ExtConfig.bEnableWifiScanNotify)
+		bthci_EventExtWifiScanNotify(padapter, scanType);
+}
+
+void
+BTHCI_StateMachine(
+	struct rtw_adapter *padapter,
+	u8 		StateToEnter,
+	enum hci_state_with_cmd		StateCmd,
+	u8 		EntryNum
+	)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	if (EntryNum =3D=3D 0xff) {
+		RTPRINT(FIOCTL, IOCTL_STATE, (" StateMachine, error EntryNum =3D 0x%=
x \n", EntryNum));
+		return;
+	}
+	RTPRINT(FIOCTL, IOCTL_STATE, (" StateMachine, EntryNum =3D 0x%x, Curr=
entState =3D 0x%x, BtNextState =3D 0x%x,  StateCmd =3D 0x%x , StateToEn=
ter =3D 0x%x\n",
+		EntryNum, pBTInfo->BtAsocEntry[EntryNum].BtCurrentState, pBTInfo->Bt=
AsocEntry[EntryNum].BtNextState, StateCmd, StateToEnter));
+
+	if (pBTInfo->BtAsocEntry[EntryNum].BtNextState & StateToEnter) {
+		pBTInfo->BtAsocEntry[EntryNum].BtCurrentState =3D StateToEnter;
+
+		switch (StateToEnter) {
+		case HCI_STATE_STARTING:
+			pBTInfo->BtAsocEntry[EntryNum].BtNextState =3D HCI_STATE_DISCONNECT=
ING | HCI_STATE_CONNECTING;
+			bthci_StateStarting(padapter, StateCmd, EntryNum);
+			break;
+		case HCI_STATE_CONNECTING:
+			pBTInfo->BtAsocEntry[EntryNum].BtNextState =3D HCI_STATE_CONNECTING=
 | HCI_STATE_DISCONNECTING | HCI_STATE_AUTHENTICATING;
+			bthci_StateConnecting(padapter, StateCmd, EntryNum);
+			break;
+		case HCI_STATE_AUTHENTICATING:
+			pBTInfo->BtAsocEntry[EntryNum].BtNextState =3D HCI_STATE_DISCONNECT=
ING | HCI_STATE_CONNECTED;
+			bthci_StateAuth(padapter, StateCmd, EntryNum);
+			break;
+		case HCI_STATE_CONNECTED:
+			pBTInfo->BtAsocEntry[EntryNum].BtNextState =3D HCI_STATE_CONNECTED =
| HCI_STATE_DISCONNECTING;
+			bthci_StateConnected(padapter, StateCmd, EntryNum);
+			break;
+		case HCI_STATE_DISCONNECTING:
+			pBTInfo->BtAsocEntry[EntryNum].BtNextState =3D HCI_STATE_DISCONNECT=
ED | HCI_STATE_DISCONNECTING;
+			bthci_StateDisconnecting(padapter, StateCmd, EntryNum);
+			break;
+		case HCI_STATE_DISCONNECTED:
+			pBTInfo->BtAsocEntry[EntryNum].BtNextState =3D HCI_STATE_DISCONNECT=
ED | HCI_STATE_STARTING | HCI_STATE_CONNECTING;
+			bthci_StateDisconnected(padapter, StateCmd, EntryNum);
+			break;
+		default:
+			RTPRINT(FIOCTL, IOCTL_STATE, (" StateMachine, Unknown state to ente=
r!!!\n"));
+			break;
+		}
+	} else {
+		RTPRINT(FIOCTL, IOCTL_STATE, (" StateMachine, Wrong state to enter\n=
"));
+	}
+
+	/*  20100325 Joseph: Disable/Enable IPS/LPS according to BT status. *=
/
+	if (!pBtMgnt->bBTConnectInProgress && !pBtMgnt->BtOperationOn) {
+		RTPRINT(FIOCTL, IOCTL_STATE, ("[BT PS], ips_enter23a()\n"));
+		ips_enter23a(padapter);
+	}
+}
+
+void BTHCI_DisconnectPeer(struct rtw_adapter *padapter, u8 EntryNum)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, (" BTHCI_DisconnectPeer()\n"));
+
+	BTHCI_SM_WITH_INFO(padapter, HCI_STATE_DISCONNECTING, STATE_CMD_MAC_C=
ONNECT_CANCEL_INDICATE, EntryNum);
+
+	if (pBTInfo->BtAsocEntry[EntryNum].bUsed) {
+/*BTPKT_SendDeauthentication(padapter, pBTInfo->BtAsocEntry[EntryNum].=
BTRemoteMACAddr, unspec_reason); not porting yet */
+	}
+
+	if (pBtMgnt->bBTConnectInProgress) {
+		pBtMgnt->bBTConnectInProgress =3D false;
+		RTPRINT(FIOCTL, IOCTL_STATE, ("[BT Flag], BT Connect in progress OFF=
!!\n"));
+	}
+
+	bthci_RemoveEntryByEntryNum(padapter, EntryNum);
+
+	if (pBtMgnt->bNeedNotifyAMPNoCap) {
+		RTPRINT(FIOCTL, IOCTL_STATE, ("[BT AMPStatus], set to invalid in BTH=
CI_DisconnectPeer()\n"));
+		BTHCI_EventAMPStatusChange(padapter, AMP_STATUS_NO_CAPACITY_FOR_BT);
+	}
+}
+
+void BTHCI_EventNumOfCompletedDataBlocks(struct rtw_adapter *padapter)
+{
+/*PMGNT_INFO pMgntInfo =3D &padapter->MgntInfo; */
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_hci_info *pBtHciInfo =3D &pBTInfo->BtHciInfo;
+	u8 localBuf[TmpLocalBufSize] =3D "";
+	u8 *pRetPar, *pTriple;
+	u8 len =3D 0, i, j, handleNum =3D 0;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+	u16 *pu2Temp, *pPackets, *pHandle, *pDblocks;
+	u8 sent =3D 0;
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+
+	if (!(pBtHciInfo->BTEventMaskPage2 & EMP2_HCI_EVENT_NUM_OF_COMPLETE_D=
ATA_BLOCKS)) {
+		RTPRINT(FIOCTL, IOCTL_BT_EVENT, ("[BT event], Num Of Completed DataB=
locks, Ignore to send NumOfCompletedDataBlocksEvent due to event mask p=
age 2\n"));
+		return;
+	}
+
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[0];
+	pTriple =3D &pRetPar[3];
+	for (j =3D 0; j < MAX_BT_ASOC_ENTRY_NUM; j++) {
+
+		for (i =3D 0; i < MAX_LOGICAL_LINK_NUM; i++) {
+			if (pBTInfo->BtAsocEntry[j].LogLinkCmdData[i].BtLogLinkhandle) {
+				handleNum++;
+				pHandle =3D (u16 *)&pTriple[0];	/*  Handle[i] */
+				pPackets =3D (u16 *)&pTriple[2];	/*  Num_Of_Completed_Packets[i] *=
/
+				pDblocks =3D (u16 *)&pTriple[4];	/*  Num_Of_Completed_Blocks[i] */
+				*pHandle =3D pBTInfo->BtAsocEntry[j].LogLinkCmdData[i].BtLogLinkha=
ndle;
+				*pPackets =3D (u16)pBTInfo->BtAsocEntry[j].LogLinkCmdData[i].TxPac=
ketCount;
+				*pDblocks =3D (u16)pBTInfo->BtAsocEntry[j].LogLinkCmdData[i].TxPac=
ketCount;
+				if (pBTInfo->BtAsocEntry[j].LogLinkCmdData[i].TxPacketCount) {
+					sent =3D 1;
+					RTPRINT(FIOCTL, IOCTL_BT_EVENT_DETAIL,
+						("[BT event], Num Of Completed DataBlocks, Handle =3D 0x%x, Num_=
Of_Completed_Packets =3D 0x%x, Num_Of_Completed_Blocks =3D 0x%x\n",
+					*pHandle, *pPackets, *pDblocks));
+				}
+				pBTInfo->BtAsocEntry[j].LogLinkCmdData[i].TxPacketCount =3D 0;
+				len +=3D 6;
+				pTriple +=3D len;
+			}
+		}
+	}
+
+	pRetPar[2] =3D handleNum;				/*  Number_of_Handles */
+	len +=3D 1;
+	pu2Temp =3D (u16 *)&pRetPar[0];
+	*pu2Temp =3D BTTotalDataBlockNum;
+	len +=3D 2;
+
+	PPacketIrpEvent->EventCode =3D HCI_EVENT_NUM_OF_COMPLETE_DATA_BLOCKS;
+	PPacketIrpEvent->Length =3D len;
+	if (handleNum && sent)
+		bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2);
+}
+
+void BTHCI_EventAMPStatusChange(struct rtw_adapter *padapter, u8 AMP_S=
tatus)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	struct packet_irp_hcievent_data *PPacketIrpEvent;
+	u8 len =3D 0;
+	u8 localBuf[7] =3D "";
+	u8 *pRetPar;
+
+	if (AMP_Status =3D=3D AMP_STATUS_NO_CAPACITY_FOR_BT) {
+		pBtMgnt->BTNeedAMPStatusChg =3D true;
+		pBtMgnt->bNeedNotifyAMPNoCap =3D false;
+
+		BTHCI_DisconnectAll(padapter);
+	} else if (AMP_Status =3D=3D AMP_STATUS_FULL_CAPACITY_FOR_BT) {
+		pBtMgnt->BTNeedAMPStatusChg =3D false;
+	}
+
+	PPacketIrpEvent =3D (struct packet_irp_hcievent_data *)(&localBuf[0])=
;
+	/*  Return parameters starts from here */
+	pRetPar =3D &PPacketIrpEvent->Data[0];
+
+	pRetPar[0] =3D 0;	/*  Status */
+	len +=3D 1;
+	pRetPar[1] =3D AMP_Status;	/*  AMP_Status */
+	len +=3D 1;
+
+	PPacketIrpEvent->EventCode =3D HCI_EVENT_AMP_STATUS_CHANGE;
+	PPacketIrpEvent->Length =3D len;
+	if (bthci_IndicateEvent(padapter, PPacketIrpEvent, len+2) =3D=3D RT_S=
TATUS_SUCCESS)
+		RTPRINT(FIOCTL, (IOCTL_BT_EVENT|IOCTL_STATE), ("[BT event], AMP Stat=
us Change, AMP_Status =3D %d\n", AMP_Status));
+}
+
+void BTHCI_DisconnectAll(struct rtw_adapter *padapter)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	u8 i;
+
+	RTPRINT(FIOCTL, IOCTL_STATE, (" DisconnectALL()\n"));
+
+	for (i =3D 0; i < MAX_BT_ASOC_ENTRY_NUM; i++) {
+		if (pBTInfo->BtAsocEntry[i].b4waySuccess) {
+			BTHCI_SM_WITH_INFO(padapter, HCI_STATE_CONNECTED, STATE_CMD_DISCONN=
ECT_PHY_LINK, i);
+		} else if (pBTInfo->BtAsocEntry[i].bUsed) {
+			if (pBTInfo->BtAsocEntry[i].BtCurrentState =3D=3D HCI_STATE_CONNECT=
ING) {
+				BTHCI_SM_WITH_INFO(padapter, HCI_STATE_CONNECTING, STATE_CMD_MAC_C=
ONNECT_CANCEL_INDICATE, i);
+			} else if (pBTInfo->BtAsocEntry[i].BtCurrentState =3D=3D HCI_STATE_=
DISCONNECTING) {
+				BTHCI_SM_WITH_INFO(padapter, HCI_STATE_DISCONNECTING, STATE_CMD_MA=
C_CONNECT_CANCEL_INDICATE, i);
+			}
+		}
+	}
+}
+
+enum hci_status
+BTHCI_HandleHCICMD(
+	struct rtw_adapter *padapter,
+	struct packet_irp_hcicmd_data *pHciCmd
+	)
+{
+	enum hci_status	status =3D HCI_STATUS_SUCCESS;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_dgb *pBtDbg =3D &pBTInfo->BtDbg;
+
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("\n"));
+	RTPRINT(FIOCTL, (IOCTL_BT_HCICMD_DETAIL|IOCTL_BT_LOGO), ("HCI Command=
 start, OGF =3D 0x%x, OCF =3D 0x%x, Length =3D 0x%x\n",
+		pHciCmd->OGF, pHciCmd->OCF, pHciCmd->Length));
+	if (pHciCmd->Length) {
+		RTPRINT_DATA(FIOCTL, (IOCTL_BT_HCICMD_DETAIL|IOCTL_BT_LOGO), "HCI Co=
mmand, Hex Data :\n",
+			&pHciCmd->Data[0], pHciCmd->Length);
+	}
+	if (pHciCmd->OGF =3D=3D OGF_EXTENSION) {
+		if (pHciCmd->OCF =3D=3D HCI_SET_RSSI_VALUE)
+			RTPRINT(FIOCTL, IOCTL_BT_EVENT_PERIODICAL, ("[BT cmd], "));
+		else
+			RTPRINT(FIOCTL, IOCTL_BT_HCICMD_EXT, ("[BT cmd], "));
+	} else {
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("[BT cmd], "));
+	}
+
+	pBtDbg->dbgHciInfo.hciCmdCnt++;
+
+	switch (pHciCmd->OGF) {
+	case LINK_CONTROL_COMMANDS:
+		status =3D bthci_HandleOGFLinkControlCMD(padapter, pHciCmd);
+		break;
+	case HOLD_MODE_COMMAND:
+		break;
+	case OGF_SET_EVENT_MASK_COMMAND:
+		status =3D bthci_HandleOGFSetEventMaskCMD(padapter, pHciCmd);
+		break;
+	case OGF_INFORMATIONAL_PARAMETERS:
+		status =3D bthci_HandleOGFInformationalParameters(padapter, pHciCmd)=
;
+		break;
+	case OGF_STATUS_PARAMETERS:
+		status =3D bthci_HandleOGFStatusParameters(padapter, pHciCmd);
+		break;
+	case OGF_TESTING_COMMANDS:
+		status =3D bthci_HandleOGFTestingCMD(padapter, pHciCmd);
+		break;
+	case OGF_EXTENSION:
+		status =3D bthci_HandleOGFExtension(padapter, pHciCmd);
+		break;
+	default:
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI Command(), Unknown OGF =3D 0x=
%x\n", pHciCmd->OGF));
+		RTPRINT(FIOCTL, IOCTL_BT_HCICMD, ("HCI_UNKNOWN_COMMAND\n"));
+		status =3D bthci_UnknownCMD(padapter, pHciCmd);
+		break;
+	}
+	RTPRINT(FIOCTL, IOCTL_BT_HCICMD_DETAIL, ("HCI Command execution end!!=
\n"));
+
+	return status;
+}
+
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver COMMOM/bt_hci.c =3D=3D=
=3D=3D=3D */
+#endif
+
+#ifdef __HALBTC87231ANT_C__ /*  HAL/BTCoexist/HalBtc87231Ant.c */
+
+static const char *const BtStateString[] =3D {
+	"BT_DISABLED",
+	"BT_NO_CONNECTION",
+	"BT_CONNECT_IDLE",
+	"BT_INQ_OR_PAG",
+	"BT_ACL_ONLY_BUSY",
+	"BT_SCO_ONLY_BUSY",
+	"BT_ACL_SCO_BUSY",
+	"BT_ACL_INQ_OR_PAG",
+	"BT_STATE_NOT_DEFINED"
+};
+
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver HAL/BTCoex=
ist/HalBtc87231Ant.c =3D=3D=3D=3D=3D */
+
+static void btdm_SetFwIgnoreWlanAct(struct rtw_adapter *padapter, u8 b=
Enable)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u8 H2C_Parameter[1] =3D {0};
+
+	if (bEnable) {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT Ignore Wlan_Act !!\n"));
+		H2C_Parameter[0] |=3D BIT(0);		/*  function enable */
+		pHalData->bt_coexist.bFWCoexistAllOff =3D false;
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT don't ignore Wlan_Act !!\n"));
+	}
+
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], set FW for BT Ignore Wlan_Act, wri=
te 0x25 =3D 0x%02x\n",
+		H2C_Parameter[0]));
+
+	FillH2CCmd(padapter, BT_IGNORE_WLAN_ACT_EID, 1, H2C_Parameter);
+}
+
+static void btdm_NotifyFwScan(struct rtw_adapter *padapter, u8 scanTyp=
e)
+{
+	u8 H2C_Parameter[1] =3D {0};
+
+	if (scanType =3D=3D true)
+		H2C_Parameter[0] =3D 0x1;
+
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], Notify FW for wifi scan, write 0x3=
b =3D 0x%02x\n",
+		H2C_Parameter[0]));
+
+	FillH2CCmd(padapter, 0x3b, 1, H2C_Parameter);
+}
+
+static void btdm_1AntSetPSMode(struct rtw_adapter *padapter,
+			       u8 enable, u8 smartps, u8 mode)
+{
+	struct pwrctrl_priv *pwrctrl;
+
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], Current LPS(%s, %d), smartps =3D%d=
\n", enable =3D=3D true?"ON":"OFF", mode, smartps));
+
+	pwrctrl =3D &padapter->pwrctrlpriv;
+
+	if (enable =3D=3D true) {
+		rtw_set_ps_mode23a(padapter, PS_MODE_MIN, smartps, mode);
+	} else {
+		rtw_set_ps_mode23a(padapter, PS_MODE_ACTIVE, 0, 0);
+		LPS_RF_ON_check23a(padapter, 100);
+	}
+}
+
+static void btdm_1AntTSFSwitch(struct rtw_adapter *padapter, u8 enable=
)
+{
+	u8 oldVal, newVal;
+
+	oldVal =3D rtw_read8(padapter, 0x550);
+
+	if (enable)
+		newVal =3D oldVal | EN_BCN_FUNCTION;
+	else
+		newVal =3D oldVal & ~EN_BCN_FUNCTION;
+
+	if (oldVal !=3D newVal)
+		rtw_write8(padapter, 0x550, newVal);
+}
+
+static u8 btdm_Is1AntPsTdmaStateChange(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_1ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm1Ant;
+
+	if ((pBtdm8723->bPrePsTdmaOn !=3D pBtdm8723->bCurPsTdmaOn) ||
+		(pBtdm8723->prePsTdma !=3D pBtdm8723->curPsTdma))
+		return true;
+	else
+		return false;
+}
+
+/*  Before enter TDMA, make sure Power Saving is enable! */
+static void
+btdm_1AntPsTdma(
+	struct rtw_adapter *padapter,
+	u8 bTurnOn,
+	u8 type
+	)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_1ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm1Ant;
+
+	pBtdm8723->bCurPsTdmaOn =3D bTurnOn;
+	pBtdm8723->curPsTdma =3D type;
+	if (bTurnOn) {
+		switch (type) {
+		case 1:	/*  A2DP Level-1 or FTP/OPP */
+		default:
+			if (btdm_Is1AntPsTdmaStateChange(padapter)) {
+				/*  wide duration for WiFi */
+				BTDM_SetFw3a(padapter, 0xd3, 0x1a, 0x1a, 0x0, 0x58);
+			}
+			break;
+		case 2:	/*  A2DP Level-2 */
+			if (btdm_Is1AntPsTdmaStateChange(padapter)) {
+				/*  normal duration for WiFi */
+				BTDM_SetFw3a(padapter, 0xd3, 0x12, 0x12, 0x0, 0x58);
+			}
+			break;
+		case 3:	/*  BT FTP/OPP */
+			if (btdm_Is1AntPsTdmaStateChange(padapter)) {
+				/*  normal duration for WiFi */
+				BTDM_SetFw3a(padapter, 0xd3, 0x30, 0x03, 0x10, 0x58);
+
+			}
+			break;
+		case 4:	/*  for wifi scan & BT is connected */
+			if (btdm_Is1AntPsTdmaStateChange(padapter)) {
+				/*  protect 3 beacons in 3-beacon period & no Tx pause at BT slot =
*/
+				BTDM_SetFw3a(padapter, 0x93, 0x15, 0x03, 0x14, 0x0);
+			}
+			break;
+		case 5:	/*  for WiFi connected-busy & BT is Non-Connected-Idle */
+			if (btdm_Is1AntPsTdmaStateChange(padapter)) {
+				/*  SCO mode, Ant fixed at WiFi, WLAN_Act toggle */
+				BTDM_SetFw3a(padapter, 0x61, 0x15, 0x03, 0x31, 0x00);
+			}
+			break;
+		case 9:	/*  ACL high-retry type - 2 */
+			if (btdm_Is1AntPsTdmaStateChange(padapter)) {
+				/*  narrow duration for WiFi */
+				BTDM_SetFw3a(padapter, 0xd3, 0xa, 0xa, 0x0, 0x58); /* narrow durat=
ion for WiFi */
+			}
+			break;
+		case 10: /*  for WiFi connect idle & BT ACL busy or WiFi Connected-B=
usy & BT is Inquiry */
+			if (btdm_Is1AntPsTdmaStateChange(padapter))
+				BTDM_SetFw3a(padapter, 0x13, 0xa, 0xa, 0x0, 0x40);
+			break;
+		case 11: /*  ACL high-retry type - 3 */
+			if (btdm_Is1AntPsTdmaStateChange(padapter)) {
+				/*  narrow duration for WiFi */
+				BTDM_SetFw3a(padapter, 0xd3, 0x05, 0x05, 0x00, 0x58);
+			}
+			break;
+		case 12: /*  for WiFi Connected-Busy & BT is Connected-Idle */
+			if (btdm_Is1AntPsTdmaStateChange(padapter)) {
+				/*  Allow High-Pri BT */
+				BTDM_SetFw3a(padapter, 0xeb, 0x0a, 0x03, 0x31, 0x18);
+			}
+			break;
+		case 20: /*  WiFi only busy , TDMA mode for power saving */
+			if (btdm_Is1AntPsTdmaStateChange(padapter))
+				BTDM_SetFw3a(padapter, 0x13, 0x25, 0x25, 0x00, 0x00);
+			break;
+		case 27: /*  WiFi DHCP/Site Survey & BT SCO busy */
+			if (btdm_Is1AntPsTdmaStateChange(padapter))
+				BTDM_SetFw3a(padapter, 0xa3, 0x25, 0x03, 0x31, 0x98);
+			break;
+		case 28: /*  WiFi DHCP/Site Survey & BT idle */
+			if (btdm_Is1AntPsTdmaStateChange(padapter))
+				BTDM_SetFw3a(padapter, 0x69, 0x25, 0x03, 0x31, 0x00);
+			break;
+		case 29: /*  WiFi DHCP/Site Survey & BT ACL busy */
+			if (btdm_Is1AntPsTdmaStateChange(padapter)) {
+				BTDM_SetFw3a(padapter, 0xeb, 0x1a, 0x1a, 0x01, 0x18);
+				rtw_write32(padapter, 0x6c0, 0x5afa5afa);
+				rtw_write32(padapter, 0x6c4, 0x5afa5afa);
+			}
+			break;
+		case 30: /*  WiFi idle & BT Inquiry */
+			if (btdm_Is1AntPsTdmaStateChange(padapter))
+				BTDM_SetFw3a(padapter, 0x93, 0x15, 0x03, 0x14, 0x00);
+			break;
+		case 31:  /*  BT HID */
+			if (btdm_Is1AntPsTdmaStateChange(padapter))
+				BTDM_SetFw3a(padapter, 0xd3, 0x1a, 0x1a, 0x00, 0x58);
+			break;
+		case 32:  /*  BT SCO & Inquiry */
+			if (btdm_Is1AntPsTdmaStateChange(padapter))
+				BTDM_SetFw3a(padapter, 0xab, 0x0a, 0x03, 0x11, 0x98);
+			break;
+		case 33:  /*  BT SCO & WiFi site survey */
+			if (btdm_Is1AntPsTdmaStateChange(padapter))
+				BTDM_SetFw3a(padapter, 0xa3, 0x25, 0x03, 0x30, 0x98);
+			break;
+		case 34:  /*  BT HID & WiFi site survey */
+			if (btdm_Is1AntPsTdmaStateChange(padapter))
+				BTDM_SetFw3a(padapter, 0xd3, 0x1a, 0x1a, 0x00, 0x18);
+			break;
+		case 35:  /*  BT HID & WiFi Connecting */
+			if (btdm_Is1AntPsTdmaStateChange(padapter))
+				BTDM_SetFw3a(padapter, 0xe3, 0x1a, 0x1a, 0x00, 0x18);
+			break;
+		}
+	} else {
+		/*  disable PS-TDMA */
+		switch (type) {
+		case 8:
+			if (btdm_Is1AntPsTdmaStateChange(padapter)) {
+				/*  Antenna control by PTA, 0x870 =3D 0x310 */
+				BTDM_SetFw3a(padapter, 0x8, 0x0, 0x0, 0x0, 0x0);
+			}
+			break;
+		case 0:
+		default:
+			if (btdm_Is1AntPsTdmaStateChange(padapter)) {
+				/*  Antenna control by PTA, 0x870 =3D 0x310 */
+				BTDM_SetFw3a(padapter, 0x0, 0x0, 0x0, 0x8, 0x0);
+			}
+			rtw_write16(padapter, 0x860, 0x210); /*  Switch Antenna to BT */
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], 0x860 =3D 0x210, Switch Antenna =
to BT\n"));
+			break;
+		case 9:
+			if (btdm_Is1AntPsTdmaStateChange(padapter)) {
+				/*  Antenna control by PTA, 0x870 =3D 0x310 */
+				BTDM_SetFw3a(padapter, 0x0, 0x0, 0x0, 0x8, 0x0);
+			}
+			rtw_write16(padapter, 0x860, 0x110); /*  Switch Antenna to WiFi */
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], 0x860 =3D 0x110, Switch Antenna =
to WiFi\n"));
+			break;
+		}
+	}
+
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], Current TDMA(%s, %d)\n",
+		pBtdm8723->bCurPsTdmaOn?"ON":"OFF", pBtdm8723->curPsTdma));
+
+	/*  update pre state */
+	pBtdm8723->bPrePsTdmaOn =3D pBtdm8723->bCurPsTdmaOn;
+	pBtdm8723->prePsTdma =3D pBtdm8723->curPsTdma;
+}
+
+static void
+_btdm_1AntSetPSTDMA(struct rtw_adapter *padapter, u8 bPSEn, u8 smartps=
,
+		    u8 psOption, u8 bTDMAOn, u8 tdmaType)
+{
+	struct pwrctrl_priv *pwrctrl;
+	struct hal_data_8723a *pHalData;
+	struct btdm_8723a_1ant *pBtdm8723;
+	u8 psMode;
+	u8 bSwitchPS;
+
+	if (!check_fwstate(&padapter->mlmepriv, WIFI_STATION_STATE) &&
+	    (get_fwstate(&padapter->mlmepriv) !=3D WIFI_NULL_STATE)) {
+		btdm_1AntPsTdma(padapter, bTDMAOn, tdmaType);
+		return;
+	}
+	psOption &=3D ~BIT(0);
+
+	RTPRINT(FBT, BT_TRACE,
+		("[BTCoex], Set LPS(%s, %d) TDMA(%s, %d)\n",
+		bPSEn =3D=3D true?"ON":"OFF", psOption,
+		bTDMAOn =3D=3D true?"ON":"OFF", tdmaType));
+
+	pwrctrl =3D &padapter->pwrctrlpriv;
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBtdm8723 =3D &pHalData->bt_coexist.halCoex8723.btdm1Ant;
+
+	if (bPSEn) {
+		if (pBtdm8723->bWiFiHalt) {
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], Enable PS Fail, WiFi in Halt!!\n=
"));
+			return;
+		}
+
+		if (pwrctrl->bInSuspend) {
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], Enable PS Fail, WiFi in Suspend!=
!\n"));
+			return;
+		}
+
+		if (padapter->bDriverStopped) {
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], Enable PS Fail, WiFi driver stop=
ped!!\n"));
+			return;
+		}
+
+		if (padapter->bSurpriseRemoved) {
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], Enable PS Fail, WiFi Surprise Re=
moved!!\n"));
+			return;
+		}
+
+		psMode =3D PS_MODE_MIN;
+	} else {
+		psMode =3D PS_MODE_ACTIVE;
+		psOption =3D 0;
+	}
+
+	if (psMode !=3D pwrctrl->pwr_mode) {
+		bSwitchPS =3D true;
+	} else if (psMode !=3D PS_MODE_ACTIVE) {
+		if (psOption !=3D pwrctrl->bcn_ant_mode)
+			bSwitchPS =3D true;
+		else if (smartps !=3D pwrctrl->smart_ps)
+			bSwitchPS =3D true;
+		else
+			bSwitchPS =3D false;
+	} else {
+		bSwitchPS =3D false;
+	}
+
+	if (bSwitchPS) {
+		/*  disable TDMA */
+		if (pBtdm8723->bCurPsTdmaOn) {
+			if (!bTDMAOn) {
+				btdm_1AntPsTdma(padapter, false, tdmaType);
+			} else {
+				if ((BT_IsBtDisabled(padapter)) ||
+				    (pHalData->bt_coexist.halCoex8723.c2hBtInfo =3D=3D BT_INFO_STA=
TE_NO_CONNECTION) ||
+				    (pHalData->bt_coexist.halCoex8723.c2hBtInfo =3D=3D BT_INFO_STA=
TE_CONNECT_IDLE) ||
+				    (tdmaType =3D=3D 29))
+					btdm_1AntPsTdma(padapter, false, 9);
+				else
+					btdm_1AntPsTdma(padapter, false, 0);
+			}
+		}
+
+		/*  change Power Save State */
+		btdm_1AntSetPSMode(padapter, bPSEn, smartps, psOption);
+	}
+
+	btdm_1AntPsTdma(padapter, bTDMAOn, tdmaType);
+}
+
+static void
+btdm_1AntSetPSTDMA(struct rtw_adapter *padapter, u8 bPSEn,
+		   u8 psOption, u8 bTDMAOn, u8 tdmaType)
+{
+	_btdm_1AntSetPSTDMA(padapter, bPSEn, 0, psOption, bTDMAOn, tdmaType);
+}
+
+static void btdm_1AntWifiParaAdjust(struct rtw_adapter *padapter, u8 b=
Enable)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_1ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm1Ant;
+
+	if (bEnable) {
+		pBtdm8723->curWifiPara =3D 1;
+		if (pBtdm8723->preWifiPara !=3D pBtdm8723->curWifiPara)
+			BTDM_SetSwPenaltyTxRateAdaptive(padapter, BT_TX_RATE_ADAPTIVE_LOW_P=
ENALTY);
+	} else {
+		pBtdm8723->curWifiPara =3D 2;
+		if (pBtdm8723->preWifiPara !=3D pBtdm8723->curWifiPara)
+			BTDM_SetSwPenaltyTxRateAdaptive(padapter, BT_TX_RATE_ADAPTIVE_NORMA=
L);
+	}
+
+}
+
+static void btdm_1AntPtaParaReload(struct rtw_adapter *padapter)
+{
+	/*  PTA parameter */
+	rtw_write8(padapter, 0x6cc, 0x0);			/*  1-Ant coex */
+	rtw_write32(padapter, 0x6c8, 0xffff);		/*  wifi break table */
+	rtw_write32(padapter, 0x6c4, 0x55555555);	/*  coex table */
+
+	/*  Antenna switch control parameter */
+	rtw_write32(padapter, 0x858, 0xaaaaaaaa);
+	if (IS_8723A_A_CUT(GET_HAL_DATA(padapter)->VersionID)) {
+		rtw_write32(padapter, 0x870, 0x0);	/*  SPDT(connected with TRSW) con=
trol by hardware PTA */
+		rtw_write8(padapter, 0x40, 0x24);
+	} else {
+		rtw_write8(padapter, 0x40, 0x20);
+		rtw_write16(padapter, 0x860, 0x210);	/*  set antenna at bt side if A=
NTSW is software control */
+		rtw_write32(padapter, 0x870, 0x300);	/*  SPDT(connected with TRSW) c=
ontrol by hardware PTA */
+		rtw_write32(padapter, 0x874, 0x22804000);	/*  ANTSW keep by GNT_BT *=
/
+	}
+
+	/*  coexistence parameters */
+	rtw_write8(padapter, 0x778, 0x1);	/*  enable RTK mode PTA */
+
+	/*  BT don't ignore WLAN_Act */
+	btdm_SetFwIgnoreWlanAct(padapter, false);
+}
+
+/*
+ * Return
+ *1: upgrade (add WiFi duration time)
+ *0: keep
+ *-1: downgrade (add BT duration time)
+ */
+static s8 btdm_1AntTdmaJudgement(struct rtw_adapter *padapter, u8 retr=
y)
+{
+	struct hal_data_8723a *pHalData;
+	struct btdm_8723a_1ant *pBtdm8723;
+	static s8 up, dn, m =3D 1, n =3D 3, WaitCount;
+	s8 ret;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBtdm8723 =3D &pHalData->bt_coexist.halCoex8723.btdm1Ant;
+	ret =3D 0;
+
+	if (pBtdm8723->psTdmaMonitorCnt =3D=3D 0) {
+		up =3D 0;
+		dn =3D 0;
+		m =3D 1;
+		n =3D 3;
+		WaitCount =3D 0;
+	} else {
+		WaitCount++;
+	}
+
+	if (retry =3D=3D 0) {
+	/*  no retry in the last 2-second duration */
+		up++;
+		dn--;
+		if (dn < 0)
+			dn =3D 0;
+		if (up >=3D 3*m) {
+			/*  retry =3D 0 in consecutive 3m*(2s), add WiFi duration */
+			ret =3D 1;
+
+			n =3D 3;
+			up =3D 0;
+			dn =3D 0;
+			WaitCount =3D 0;
+		}
+	} else if (retry <=3D 3) {
+		/*  retry<=3D 3 in the last 2-second duration */
+		up--;
+		dn++;
+		if (up < 0)
+			up =3D 0;
+
+		if (dn =3D=3D 2) {
+			/*  retry<=3D 3 in consecutive 2*(2s), minus WiFi duration (add BT =
duration) */
+			ret =3D -1;
+
+			/*  record how many time downgrad WiFi duration */
+			if (WaitCount <=3D 2)
+				m++;
+			else
+				m =3D 1;
+			/*  the max number of m is 20 */
+			/*  the longest time of upgrade WiFi duration is 20*3*2s =3D 120s *=
/
+			if (m >=3D 20)
+				m =3D 20;
+			up =3D 0;
+			dn =3D 0;
+			WaitCount =3D 0;
+		}
+	} else {
+		/*  retry count > 3 */
+		/*  retry>3, minus WiFi duration (add BT duration) */
+		ret =3D -1;
+
+		/*  record how many time downgrad WiFi duration */
+		if (WaitCount =3D=3D 1)
+			m++;
+		else
+			m =3D 1;
+		if (m >=3D 20)
+			m =3D 20;
+
+		up =3D 0;
+		dn =3D 0;
+		WaitCount =3D 0;
+	}
+	return ret;
+}
+
+static void btdm_1AntTdmaDurationAdjustForACL(struct rtw_adapter *pada=
pter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_1ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm1Ant;
+
+	if (pBtdm8723->psTdmaGlobalCnt !=3D pBtdm8723->psTdmaMonitorCnt) {
+		pBtdm8723->psTdmaMonitorCnt =3D 0;
+		pBtdm8723->psTdmaGlobalCnt =3D 0;
+	}
+	if (pBtdm8723->psTdmaMonitorCnt =3D=3D 0) {
+		btdm_1AntSetPSTDMA(padapter, true, 0, true, 2);
+		pBtdm8723->psTdmaDuAdjType =3D 2;
+	} else {
+		/*  Now we only have 4 level Ps Tdma, */
+		/*  if that's not the following 4 level(will changed by wifi scan, d=
hcp...), */
+		/*  then we have to adjust it back to the previous record one. */
+		if ((pBtdm8723->curPsTdma !=3D 1) &&
+		    (pBtdm8723->curPsTdma !=3D 2) &&
+		    (pBtdm8723->curPsTdma !=3D 9) &&
+		    (pBtdm8723->curPsTdma !=3D 11)) {
+			btdm_1AntSetPSTDMA(padapter, true, 0, true, pBtdm8723->psTdmaDuAdjT=
ype);
+		} else {
+			s32 judge =3D 0;
+
+			judge =3D btdm_1AntTdmaJudgement(padapter, pHalData->bt_coexist.hal=
Coex8723.btRetryCnt);
+			if (judge =3D=3D -1) {
+				if (pBtdm8723->curPsTdma =3D=3D 1) {
+					/*  Decrease WiFi duration for high BT retry */
+					if (pHalData->bt_coexist.halCoex8723.btInfoExt)
+						pBtdm8723->psTdmaDuAdjType =3D 9;
+					else
+						pBtdm8723->psTdmaDuAdjType =3D 2;
+					btdm_1AntSetPSTDMA(padapter, true, 0, true, pBtdm8723->psTdmaDuAd=
jType);
+				} else if (pBtdm8723->curPsTdma =3D=3D 2) {
+					btdm_1AntSetPSTDMA(padapter, true, 0, true, 9);
+					pBtdm8723->psTdmaDuAdjType =3D 9;
+				} else if (pBtdm8723->curPsTdma =3D=3D 9) {
+					btdm_1AntSetPSTDMA(padapter, true, 0, true, 11);
+					pBtdm8723->psTdmaDuAdjType =3D 11;
+				}
+			} else if (judge =3D=3D 1) {
+				if (pBtdm8723->curPsTdma =3D=3D 11) {
+					btdm_1AntSetPSTDMA(padapter, true, 0, true, 9);
+					pBtdm8723->psTdmaDuAdjType =3D 9;
+				} else if (pBtdm8723->curPsTdma =3D=3D 9) {
+					if (pHalData->bt_coexist.halCoex8723.btInfoExt)
+						pBtdm8723->psTdmaDuAdjType =3D 9;
+					else
+						pBtdm8723->psTdmaDuAdjType =3D 2;
+					btdm_1AntSetPSTDMA(padapter, true, 0, true, pBtdm8723->psTdmaDuAd=
jType);
+				} else if (pBtdm8723->curPsTdma =3D=3D 2) {
+					if (pHalData->bt_coexist.halCoex8723.btInfoExt)
+						pBtdm8723->psTdmaDuAdjType =3D 9;
+					else
+						pBtdm8723->psTdmaDuAdjType =3D 1;
+					btdm_1AntSetPSTDMA(padapter, true, 0, true, pBtdm8723->psTdmaDuAd=
jType);
+				}
+			}
+		}
+		RTPRINT(FBT, BT_TRACE,
+			("[BTCoex], ACL current TDMA(%s, %d)\n",
+			(pBtdm8723->bCurPsTdmaOn ? "ON" : "OFF"), pBtdm8723->curPsTdma));
+	}
+	pBtdm8723->psTdmaMonitorCnt++;
+}
+
+static void btdm_1AntCoexProcessForWifiConnect(struct rtw_adapter *pad=
apter)
+{
+	struct mlme_priv *pmlmepriv;
+	struct hal_data_8723a *pHalData;
+	struct bt_coexist_8723a *pBtCoex;
+	struct btdm_8723a_1ant *pBtdm8723;
+	u8 BtState;
+
+	pmlmepriv =3D &padapter->mlmepriv;
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBtCoex =3D &pHalData->bt_coexist.halCoex8723;
+	pBtdm8723 =3D &pBtCoex->btdm1Ant;
+	BtState =3D pBtCoex->c2hBtInfo;
+
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], WiFi is %s\n", BTDM_IsWifiBusy(pad=
apter)?"Busy":"IDLE"));
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT is %s\n", BtStateString[BtState=
]));
+
+	padapter->pwrctrlpriv.btcoex_rfon =3D false;
+
+	if ((!BTDM_IsWifiBusy(padapter)) && (!check_fwstate(&padapter->mlmepr=
iv, WIFI_AP_STATE)) &&
+	    ((BtState =3D=3D BT_INFO_STATE_NO_CONNECTION) || (BtState =3D=3D =
BT_INFO_STATE_CONNECT_IDLE))) {
+		switch (BtState) {
+		case BT_INFO_STATE_NO_CONNECTION:
+			_btdm_1AntSetPSTDMA(padapter, true, 2, 0x26, false, 9);
+			break;
+		case BT_INFO_STATE_CONNECT_IDLE:
+			_btdm_1AntSetPSTDMA(padapter, true, 2, 0x26, false, 0);
+			break;
+		}
+	} else {
+		switch (BtState) {
+		case BT_INFO_STATE_NO_CONNECTION:
+		case BT_INFO_STATE_CONNECT_IDLE:
+			/*  WiFi is Busy */
+			btdm_1AntSetPSTDMA(padapter, false, 0, true, 5);
+			rtw_write32(padapter, 0x6c0, 0x5a5a5a5a);
+			rtw_write32(padapter, 0x6c4, 0x5a5a5a5a);
+			break;
+		case BT_INFO_STATE_ACL_INQ_OR_PAG:
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT PROFILE is BT_INFO_STATE_ACL_=
INQ_OR_PAG\n"));
+		case BT_INFO_STATE_INQ_OR_PAG:
+			padapter->pwrctrlpriv.btcoex_rfon =3D true;
+			btdm_1AntSetPSTDMA(padapter, true, 0, true, 30);
+			break;
+		case BT_INFO_STATE_SCO_ONLY_BUSY:
+		case BT_INFO_STATE_ACL_SCO_BUSY:
+			if (true =3D=3D pBtCoex->bC2hBtInquiryPage) {
+				btdm_1AntSetPSTDMA(padapter, false, 0, true, 32);
+			} else {
+#ifdef BTCOEX_CMCC_TEST
+				btdm_1AntSetPSTDMA(padapter, false, 0, true, 23);
+#else /*  !BTCOEX_CMCC_TEST */
+				btdm_1AntSetPSTDMA(padapter, false, 0, false, 8);
+				rtw_write32(padapter, 0x6c0, 0x5a5a5a5a);
+				rtw_write32(padapter, 0x6c4, 0x5a5a5a5a);
+#endif /*  !BTCOEX_CMCC_TEST */
+			}
+			break;
+		case BT_INFO_STATE_ACL_ONLY_BUSY:
+			padapter->pwrctrlpriv.btcoex_rfon =3D true;
+			if (pBtCoex->c2hBtProfile =3D=3D BT_INFO_HID) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT PROFILE is HID\n"));
+				btdm_1AntSetPSTDMA(padapter, true, 0, true, 31);
+			} else if (pBtCoex->c2hBtProfile =3D=3D BT_INFO_FTP) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT PROFILE is FTP/OPP\n"));
+				btdm_1AntSetPSTDMA(padapter, true, 0, true, 3);
+			} else if (pBtCoex->c2hBtProfile =3D=3D (BT_INFO_A2DP|BT_INFO_FTP))=
 {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT PROFILE is A2DP_FTP\n"));
+				btdm_1AntSetPSTDMA(padapter, true, 0, true, 11);
+			} else {
+				if (pBtCoex->c2hBtProfile =3D=3D BT_INFO_A2DP)
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT PROFILE is A2DP\n"));
+				else
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT PROFILE is UNKNOWN(0x%02X)!=
 Use A2DP Profile\n", pBtCoex->c2hBtProfile));
+				btdm_1AntTdmaDurationAdjustForACL(padapter);
+			}
+			break;
+		}
+	}
+
+	pBtdm8723->psTdmaGlobalCnt++;
+}
+
+static void btdm_1AntUpdateHalRAMask(struct rtw_adapter *padapter, u32=
 mac_id, u32 filter)
+{
+	u8 init_rate =3D 0;
+	u8 raid;
+	u32 mask;
+	u8 shortGIrate =3D false;
+	int	supportRateNum =3D 0;
+	struct sta_info	*psta;
+	struct hal_data_8723a *pHalData;
+	struct dm_priv *pdmpriv;
+	struct mlme_ext_priv *pmlmeext;
+	struct mlme_ext_info *pmlmeinfo;
+	struct wlan_bssid_ex *cur_network;
+
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], %s, MACID =3D%d, filter =3D 0x%08x=
!!\n", __func__, mac_id, filter));
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pdmpriv =3D &pHalData->dmpriv;
+	pmlmeext =3D &padapter->mlmeextpriv;
+	pmlmeinfo =3D &pmlmeext->mlmext_info;
+	cur_network =3D &pmlmeinfo->network;
+
+	if (mac_id >=3D NUM_STA) { /* CAM_SIZE */
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], %s, MACID =3D%d illegal!!\n", __f=
unc__, mac_id));
+		return;
+	}
+
+	psta =3D pmlmeinfo->FW_sta_info[mac_id].psta;
+	if (psta =3D=3D NULL) {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], %s, Can't find station!!\n", __fu=
nc__));
+		return;
+	}
+
+	raid =3D psta->raid;
+
+	switch (mac_id) {
+	case 0:/*  for infra mode */
+		supportRateNum =3D rtw_get_rateset_len23a(cur_network->SupportedRate=
s);
+		mask =3D update_supported_rate23a(cur_network->SupportedRates, suppo=
rtRateNum);
+		mask |=3D (pmlmeinfo->HT_enable) ? update_MSC_rate23a(&pmlmeinfo->HT=
_caps):0;
+		if (support_short_GI23a(padapter, &pmlmeinfo->HT_caps))
+			shortGIrate =3D true;
+		break;
+	case 1:/* for broadcast/multicast */
+		supportRateNum =3D rtw_get_rateset_len23a(pmlmeinfo->FW_sta_info[mac=
_id].SupportedRates);
+		mask =3D update_basic_rate23a(cur_network->SupportedRates, supportRa=
teNum);
+		break;
+	default: /* for each sta in IBSS */
+		supportRateNum =3D rtw_get_rateset_len23a(pmlmeinfo->FW_sta_info[mac=
_id].SupportedRates);
+		mask =3D update_supported_rate23a(cur_network->SupportedRates, suppo=
rtRateNum);
+		break;
+	}
+	mask |=3D ((raid<<28)&0xf0000000);
+	mask &=3D 0xffffffff;
+	mask &=3D ~filter;
+	init_rate =3D get_highest_rate_idx23a(mask)&0x3f;
+
+	if (pHalData->fw_ractrl) {
+		u8 arg =3D 0;
+
+		arg =3D mac_id&0x1f;/* MACID */
+		arg |=3D BIT(7);
+		if (true =3D=3D shortGIrate)
+			arg |=3D BIT(5);
+
+		RTPRINT(FBT, BT_TRACE,
+			("[BTCoex], Update FW RAID entry, MASK =3D 0x%08x, arg =3D 0x%02x\n=
",
+			mask, arg));
+
+		rtl8723a_set_raid_cmd(padapter, mask, arg);
+	} else {
+		if (shortGIrate)
+			init_rate |=3D BIT(6);
+
+		rtw_write8(padapter, (REG_INIDATA_RATE_SEL+mac_id), init_rate);
+	}
+
+	psta->init_rate =3D init_rate;
+	pdmpriv->INIDATA_RATE[mac_id] =3D init_rate;
+}
+
+static void btdm_1AntUpdateHalRAMaskForSCO(struct rtw_adapter *padapte=
r, u8 forceUpdate)
+{
+	struct btdm_8723a_1ant *pBtdm8723;
+	struct sta_priv *pstapriv;
+	struct wlan_bssid_ex *cur_network;
+	struct sta_info *psta;
+	u32 macid;
+	u32 filter =3D 0;
+
+	pBtdm8723 =3D &GET_HAL_DATA(padapter)->bt_coexist.halCoex8723.btdm1An=
t;
+
+	if ((pBtdm8723->bRAChanged =3D=3D true) && (forceUpdate =3D=3D false)=
)
+		return;
+
+	pstapriv =3D &padapter->stapriv;
+	cur_network =3D &padapter->mlmeextpriv.mlmext_info.network;
+	psta =3D rtw_get_stainfo23a(pstapriv, cur_network->MacAddress);
+	macid =3D psta->mac_id;
+
+	filter |=3D BIT(_1M_RATE_);
+	filter |=3D BIT(_2M_RATE_);
+	filter |=3D BIT(_5M_RATE_);
+	filter |=3D BIT(_11M_RATE_);
+	filter |=3D BIT(_6M_RATE_);
+	filter |=3D BIT(_9M_RATE_);
+
+	btdm_1AntUpdateHalRAMask(padapter, macid, filter);
+
+	pBtdm8723->bRAChanged =3D true;
+}
+
+static void btdm_1AntRecoverHalRAMask(struct rtw_adapter *padapter)
+{
+	struct btdm_8723a_1ant *pBtdm8723;
+	struct sta_priv *pstapriv;
+	struct wlan_bssid_ex *cur_network;
+	struct sta_info *psta;
+
+	pBtdm8723 =3D &GET_HAL_DATA(padapter)->bt_coexist.halCoex8723.btdm1An=
t;
+
+	if (pBtdm8723->bRAChanged =3D=3D false)
+		return;
+
+	pstapriv =3D &padapter->stapriv;
+	cur_network =3D &padapter->mlmeextpriv.mlmext_info.network;
+	psta =3D rtw_get_stainfo23a(pstapriv, cur_network->MacAddress);
+
+	Update_RA_Entry23a(padapter, psta);
+
+	pBtdm8723->bRAChanged =3D false;
+}
+
+static void
+btdm_1AntBTStateChangeHandler(struct rtw_adapter *padapter,
+			      enum bt_state_1ant oldState, enum bt_state_1ant newState)
+{
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT state change, %s =3D> %s\n", Bt=
StateString[oldState], BtStateString[newState]));
+
+	/*  BT default ignore wlan active, */
+	/*  WiFi MUST disable this when BT is enable */
+	if (newState > BT_INFO_STATE_DISABLED)
+		btdm_SetFwIgnoreWlanAct(padapter, false);
+
+	if ((check_fwstate(&padapter->mlmepriv, WIFI_STATION_STATE)) &&
+	    (BTDM_IsWifiConnectionExist(padapter))) {
+		if ((newState =3D=3D BT_INFO_STATE_SCO_ONLY_BUSY) ||
+		    (newState =3D=3D BT_INFO_STATE_ACL_SCO_BUSY)) {
+			btdm_1AntUpdateHalRAMaskForSCO(padapter, false);
+		} else {
+			/*  Recover original RA setting */
+			btdm_1AntRecoverHalRAMask(padapter);
+		}
+	} else {
+		GET_HAL_DATA(padapter)->bt_coexist.halCoex8723.btdm1Ant.bRAChanged =3D=
 false;
+	}
+
+	if (oldState =3D=3D newState)
+		return;
+
+	if (oldState =3D=3D BT_INFO_STATE_ACL_ONLY_BUSY) {
+		struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+		pHalData->bt_coexist.halCoex8723.btdm1Ant.psTdmaMonitorCnt =3D 0;
+		pHalData->bt_coexist.halCoex8723.btdm1Ant.psTdmaMonitorCntForSCO =3D=
 0;
+	}
+
+	if ((oldState =3D=3D BT_INFO_STATE_SCO_ONLY_BUSY) ||
+	    (oldState =3D=3D BT_INFO_STATE_ACL_SCO_BUSY)) {
+		struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+		pHalData->bt_coexist.halCoex8723.btdm1Ant.psTdmaMonitorCntForSCO =3D=
 0;
+	}
+
+	/*  Active 2Ant mechanism when BT Connected */
+	if ((oldState =3D=3D BT_INFO_STATE_DISABLED) ||
+	    (oldState =3D=3D BT_INFO_STATE_NO_CONNECTION)) {
+		if ((newState !=3D BT_INFO_STATE_DISABLED) &&
+		    (newState !=3D BT_INFO_STATE_NO_CONNECTION)) {
+			BTDM_SetSwRfRxLpfCorner(padapter, BT_RF_RX_LPF_CORNER_SHRINK);
+			BTDM_AGCTable(padapter, BT_AGCTABLE_ON);
+			BTDM_BBBackOffLevel(padapter, BT_BB_BACKOFF_ON);
+		}
+	} else {
+		if ((newState =3D=3D BT_INFO_STATE_DISABLED) ||
+		    (newState =3D=3D BT_INFO_STATE_NO_CONNECTION)) {
+			BTDM_SetSwRfRxLpfCorner(padapter, BT_RF_RX_LPF_CORNER_RESUME);
+			BTDM_AGCTable(padapter, BT_AGCTABLE_OFF);
+			BTDM_BBBackOffLevel(padapter, BT_BB_BACKOFF_OFF);
+		}
+	}
+}
+
+static void btdm_1AntBtCoexistHandler(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	struct bt_coexist_8723a *pBtCoex8723;
+	struct btdm_8723a_1ant *pBtdm8723;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBtCoex8723 =3D &pHalData->bt_coexist.halCoex8723;
+	pBtdm8723 =3D &pBtCoex8723->btdm1Ant;
+	padapter->pwrctrlpriv.btcoex_rfon =3D false;
+	if (BT_IsBtDisabled(padapter)) {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT is disabled\n"));
+
+		if (BTDM_IsWifiConnectionExist(padapter)) {
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], wifi is connected\n"));
+
+			if (BTDM_IsWifiBusy(padapter)) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], Wifi is busy\n"));
+				btdm_1AntSetPSTDMA(padapter, false, 0, false, 9);
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], Wifi is idle\n"));
+				_btdm_1AntSetPSTDMA(padapter, true, 2, 1, false, 9);
+			}
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], wifi is disconnected\n"));
+
+			btdm_1AntSetPSTDMA(padapter, false, 0, false, 9);
+		}
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT is enabled\n"));
+
+		if (BTDM_IsWifiConnectionExist(padapter)) {
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], wifi is connected\n"));
+
+			btdm_1AntWifiParaAdjust(padapter, true);
+			btdm_1AntCoexProcessForWifiConnect(padapter);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], wifi is disconnected\n"));
+
+			/*  Antenna switch at BT side(0x870 =3D 0x300, 0x860 =3D 0x210) aft=
er PSTDMA off */
+			btdm_1AntWifiParaAdjust(padapter, false);
+			btdm_1AntSetPSTDMA(padapter, false, 0, false, 0);
+		}
+	}
+
+	btdm_1AntBTStateChangeHandler(padapter, pBtCoex8723->prec2hBtInfo, pB=
tCoex8723->c2hBtInfo);
+	pBtCoex8723->prec2hBtInfo =3D pBtCoex8723->c2hBtInfo;
+}
+
+void BTDM_1AntSignalCompensation(struct rtw_adapter *padapter, u8 *rss=
i_wifi, u8 *rssi_bt)
+{
+	struct hal_data_8723a *pHalData;
+	struct btdm_8723a_1ant *pBtdm8723;
+	u8 RSSI_WiFi_Cmpnstn, RSSI_BT_Cmpnstn;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBtdm8723 =3D &pHalData->bt_coexist.halCoex8723.btdm1Ant;
+	RSSI_WiFi_Cmpnstn =3D 0;
+	RSSI_BT_Cmpnstn =3D 0;
+
+	switch (pBtdm8723->curPsTdma) {
+	case 1: /*  WiFi 52ms */
+		RSSI_WiFi_Cmpnstn =3D 11; /*  22*0.48 */
+		break;
+	case 2: /*  WiFi 36ms */
+		RSSI_WiFi_Cmpnstn =3D 14; /*  22*0.64 */
+		break;
+	case 9: /*  WiFi 20ms */
+		RSSI_WiFi_Cmpnstn =3D 18; /*  22*0.80 */
+		break;
+	case 11: /*  WiFi 10ms */
+		RSSI_WiFi_Cmpnstn =3D 20; /*  22*0.90 */
+		break;
+	case 4: /*  WiFi 21ms */
+		RSSI_WiFi_Cmpnstn =3D 17; /*  22*0.79 */
+		break;
+	case 16: /*  WiFi 24ms */
+		RSSI_WiFi_Cmpnstn =3D 18; /*  22*0.76 */
+		break;
+	case 18: /*  WiFi 37ms */
+		RSSI_WiFi_Cmpnstn =3D 14; /*  22*0.64 */
+		break;
+	case 23: /* Level-1, Antenna switch to BT at all time */
+	case 24: /* Level-2, Antenna switch to BT at all time */
+	case 25: /* Level-3a, Antenna switch to BT at all time */
+	case 26: /* Level-3b, Antenna switch to BT at all time */
+	case 27: /* Level-3b, Antenna switch to BT at all time */
+	case 33: /* BT SCO & WiFi site survey */
+		RSSI_WiFi_Cmpnstn =3D 22;
+		break;
+	default:
+		break;
+	}
+
+	if (rssi_wifi && RSSI_WiFi_Cmpnstn) {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], 1AntSgnlCmpnstn, case %d, WiFiCmp=
nstn =3D%d(%d =3D> %d)\n",
+				pBtdm8723->curPsTdma, RSSI_WiFi_Cmpnstn, *rssi_wifi, *rssi_wifi+RS=
SI_WiFi_Cmpnstn));
+		*rssi_wifi +=3D RSSI_WiFi_Cmpnstn;
+	}
+
+	if (rssi_bt && RSSI_BT_Cmpnstn) {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], 1AntSgnlCmpnstn, case %d, BTCmpns=
tn =3D%d(%d =3D> %d)\n",
+				pBtdm8723->curPsTdma, RSSI_BT_Cmpnstn, *rssi_bt, *rssi_bt+RSSI_BT_=
Cmpnstn));
+		*rssi_bt +=3D RSSI_BT_Cmpnstn;
+	}
+}
+
+static void BTDM_1AntParaInit(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	struct bt_coexist_8723a *pBtCoex;
+	struct btdm_8723a_1ant *pBtdm8723;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBtCoex =3D &pHalData->bt_coexist.halCoex8723;
+	pBtdm8723 =3D &pBtCoex->btdm1Ant;
+
+	/*  Enable counter statistics */
+	rtw_write8(padapter, 0x76e, 0x4);
+	btdm_1AntPtaParaReload(padapter);
+
+	pBtdm8723->wifiRssiThresh =3D 48;
+
+	pBtdm8723->bWiFiHalt =3D false;
+	pBtdm8723->bRAChanged =3D false;
+
+	if ((pBtCoex->c2hBtInfo !=3D BT_INFO_STATE_DISABLED) &&
+	    (pBtCoex->c2hBtInfo !=3D BT_INFO_STATE_NO_CONNECTION)) {
+		BTDM_SetSwRfRxLpfCorner(padapter, BT_RF_RX_LPF_CORNER_SHRINK);
+		BTDM_AGCTable(padapter, BT_AGCTABLE_ON);
+		BTDM_BBBackOffLevel(padapter, BT_BB_BACKOFF_ON);
+	}
+}
+
+static void BTDM_1AntForHalt(struct rtw_adapter *padapter)
+{
+	RTPRINT(FBT, BT_TRACE, ("\n[BTCoex], 1Ant for halt\n"));
+
+	GET_HAL_DATA(padapter)->bt_coexist.halCoex8723.btdm1Ant.bWiFiHalt =3D=
 true;
+
+	btdm_1AntWifiParaAdjust(padapter, false);
+
+	/*  don't use btdm_1AntSetPSTDMA() here */
+	/*  it will call rtw_set_ps_mode23a() and request pwrpriv->lock. */
+	/*  This will lead to deadlock, if this function is called in IPS */
+	/*  Lucas@20130205 */
+	btdm_1AntPsTdma(padapter, false, 0);
+
+	btdm_SetFwIgnoreWlanAct(padapter, true);
+}
+
+static void BTDM_1AntLpsLeave(struct rtw_adapter *padapter)
+{
+	RTPRINT(FBT, BT_TRACE, ("\n[BTCoex], 1Ant for LPS Leave\n"));
+
+	/*  Prevent from entering LPS again */
+	GET_HAL_DATA(padapter)->bt_coexist.halCoex8723.btdm1Ant.bWiFiHalt =3D=
 true;
+
+	btdm_1AntSetPSTDMA(padapter, false, 0, false, 8);
+/*btdm_1AntPsTdma(padapter, false, 8); */
+}
+
+static void BTDM_1AntWifiAssociateNotify(struct rtw_adapter *padapter,=
 u8 type)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	RTPRINT(FBT, BT_TRACE, ("\n[BTCoex], 1Ant for associate, type =3D%d\n=
", type));
+
+	if (type) {
+		rtl8723a_CheckAntenna_Selection(padapter);
+		if (BT_IsBtDisabled(padapter)) {
+			btdm_1AntSetPSTDMA(padapter, false, 0, false, 9);
+		} else {
+			struct bt_coexist_8723a *pBtCoex;
+			u8 BtState;
+
+			pBtCoex =3D &pHalData->bt_coexist.halCoex8723;
+			BtState =3D pBtCoex->c2hBtInfo;
+
+			btdm_1AntTSFSwitch(padapter, true);
+
+			if ((BtState =3D=3D BT_INFO_STATE_NO_CONNECTION) ||
+			    (BtState =3D=3D BT_INFO_STATE_CONNECT_IDLE)) {
+				btdm_1AntSetPSTDMA(padapter, false, 0, true, 28);
+			} else if ((BtState =3D=3D BT_INFO_STATE_SCO_ONLY_BUSY) ||
+				   (BtState =3D=3D BT_INFO_STATE_ACL_SCO_BUSY)) {
+				btdm_1AntSetPSTDMA(padapter, false, 0, false, 8);
+				rtw_write32(padapter, 0x6c0, 0x5a5a5a5a);
+				rtw_write32(padapter, 0x6c4, 0x5a5a5a5a);
+			} else if ((BtState =3D=3D BT_INFO_STATE_ACL_ONLY_BUSY) ||
+				   (BtState =3D=3D BT_INFO_STATE_ACL_INQ_OR_PAG)) {
+				if (pBtCoex->c2hBtProfile =3D=3D BT_INFO_HID)
+					btdm_1AntSetPSTDMA(padapter, false, 0, true, 35);
+				else
+					btdm_1AntSetPSTDMA(padapter, false, 0, true, 29);
+			}
+		}
+	} else {
+		if (BT_IsBtDisabled(padapter)) {
+			if (!BTDM_IsWifiConnectionExist(padapter)) {
+				btdm_1AntPsTdma(padapter, false, 0);
+				btdm_1AntTSFSwitch(padapter, false);
+			}
+		}
+
+		btdm_1AntBtCoexistHandler(padapter);
+	}
+}
+
+static void
+BTDM_1AntMediaStatusNotify(struct rtw_adapter *padapter,
+			   enum rt_media_status mstatus)
+{
+	struct bt_coexist_8723a *pBtCoex;
+
+	pBtCoex =3D &GET_HAL_DATA(padapter)->bt_coexist.halCoex8723;
+
+	RTPRINT(FBT, BT_TRACE, ("\n\n[BTCoex]******************************\n=
"));
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], MediaStatus, WiFi %s !!\n",
+			mstatus =3D=3D RT_MEDIA_CONNECT?"CONNECT":"DISCONNECT"));
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex]******************************\n"));
+
+	if (RT_MEDIA_CONNECT =3D=3D mstatus) {
+		if (check_fwstate(&padapter->mlmepriv, WIFI_STATION_STATE)) {
+			if ((pBtCoex->c2hBtInfo =3D=3D BT_INFO_STATE_SCO_ONLY_BUSY) ||
+			    (pBtCoex->c2hBtInfo =3D=3D BT_INFO_STATE_ACL_SCO_BUSY))
+				btdm_1AntUpdateHalRAMaskForSCO(padapter, true);
+		}
+
+		padapter->pwrctrlpriv.DelayLPSLastTimeStamp =3D jiffies;
+		BTDM_1AntForDhcp(padapter);
+	} else {
+		/* DBG_8723A("%s rtl8723a_DeinitAntenna_Selection\n", __func__); */
+		rtl8723a_DeinitAntenna_Selection(padapter);
+		btdm_1AntBtCoexistHandler(padapter);
+		pBtCoex->btdm1Ant.bRAChanged =3D false;
+	}
+}
+
+void BTDM_1AntForDhcp(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	u8 BtState;
+	struct bt_coexist_8723a *pBtCoex;
+	struct btdm_8723a_1ant *pBtdm8723;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBtCoex =3D &pHalData->bt_coexist.halCoex8723;
+	BtState =3D pBtCoex->c2hBtInfo;
+	pBtdm8723 =3D &pBtCoex->btdm1Ant;
+
+	RTPRINT(FBT, BT_TRACE, ("\n[BTCoex], 1Ant for DHCP\n"));
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], 1Ant for DHCP, WiFi is %s\n", BTDM=
_IsWifiBusy(padapter)?"Busy":"IDLE"));
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], 1Ant for DHCP, %s\n", BtStateStrin=
g[BtState]));
+
+	BTDM_1AntWifiAssociateNotify(padapter, true);
+}
+
+static void BTDM_1AntWifiScanNotify(struct rtw_adapter *padapter, u8 s=
canType)
+{
+	struct hal_data_8723a *pHalData;
+	u8 BtState;
+	struct bt_coexist_8723a *pBtCoex;
+	struct btdm_8723a_1ant *pBtdm8723;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	BtState =3D pHalData->bt_coexist.halCoex8723.c2hBtInfo;
+	pBtCoex =3D &pHalData->bt_coexist.halCoex8723;
+	pBtdm8723 =3D &pBtCoex->btdm1Ant;
+
+	RTPRINT(FBT, BT_TRACE, ("\n[BTCoex], 1Ant for wifi scan =3D%d!!\n", s=
canType));
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], 1Ant for wifi scan, WiFi is %s\n",=
 BTDM_IsWifiBusy(padapter)?"Busy":"IDLE"));
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], 1Ant for wifi scan, %s\n", BtState=
String[BtState]));
+
+	if (scanType) {
+		rtl8723a_CheckAntenna_Selection(padapter);
+		if (BT_IsBtDisabled(padapter)) {
+			btdm_1AntSetPSTDMA(padapter, false, 0, false, 9);
+		} else if (BTDM_IsWifiConnectionExist(padapter) =3D=3D false) {
+			BTDM_1AntWifiAssociateNotify(padapter, true);
+		} else {
+			if ((BtState =3D=3D BT_INFO_STATE_SCO_ONLY_BUSY) ||
+			    (BtState =3D=3D BT_INFO_STATE_ACL_SCO_BUSY)) {
+				if (pBtCoex->bC2hBtInquiryPage) {
+					btdm_1AntSetPSTDMA(padapter, false, 0, true, 32);
+				} else {
+					padapter->pwrctrlpriv.btcoex_rfon =3D true;
+					btdm_1AntSetPSTDMA(padapter, true, 0, true, 33);
+				}
+			} else if (true =3D=3D pBtCoex->bC2hBtInquiryPage) {
+				padapter->pwrctrlpriv.btcoex_rfon =3D true;
+				btdm_1AntSetPSTDMA(padapter, true, 0, true, 30);
+			} else if (BtState =3D=3D BT_INFO_STATE_ACL_ONLY_BUSY) {
+				padapter->pwrctrlpriv.btcoex_rfon =3D true;
+				if (pBtCoex->c2hBtProfile =3D=3D BT_INFO_HID)
+					btdm_1AntSetPSTDMA(padapter, true, 0, true, 34);
+				else
+					btdm_1AntSetPSTDMA(padapter, true, 0, true, 4);
+			} else {
+				padapter->pwrctrlpriv.btcoex_rfon =3D true;
+				btdm_1AntSetPSTDMA(padapter, true, 0, true, 5);
+			}
+		}
+
+		btdm_NotifyFwScan(padapter, 1);
+	} else {
+		/*  WiFi_Finish_Scan */
+		btdm_NotifyFwScan(padapter, 0);
+		btdm_1AntBtCoexistHandler(padapter);
+	}
+}
+
+static void BTDM_1AntFwC2hBtInfo8723A(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	struct bt_30info *pBTInfo;
+	struct bt_mgnt *pBtMgnt;
+	struct bt_coexist_8723a *pBtCoex;
+	u8 u1tmp, btState;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtMgnt =3D &pBTInfo->BtMgnt;
+	pBtCoex =3D &pHalData->bt_coexist.halCoex8723;
+
+	u1tmp =3D pBtCoex->c2hBtInfoOriginal;
+	/*  sco BUSY bit is not used on voice over PCM platform */
+	btState =3D u1tmp & 0xF;
+	pBtCoex->c2hBtProfile =3D u1tmp & 0xE0;
+
+	/*  default set bt to idle state. */
+	pBtMgnt->ExtConfig.bBTBusy =3D false;
+	pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_BT_IDLE;
+
+	/*  check BIT2 first =3D=3D> check if bt is under inquiry or page sca=
n */
+	if (btState & BIT(2))
+		pBtCoex->bC2hBtInquiryPage =3D true;
+	else
+		pBtCoex->bC2hBtInquiryPage =3D false;
+	btState &=3D ~BIT(2);
+
+	if (!(btState & BIT(0))) {
+		pBtCoex->c2hBtInfo =3D BT_INFO_STATE_NO_CONNECTION;
+	} else {
+		if (btState =3D=3D 0x1) {
+			pBtCoex->c2hBtInfo =3D BT_INFO_STATE_CONNECT_IDLE;
+		} else if (btState =3D=3D 0x9) {
+			if (pBtCoex->bC2hBtInquiryPage =3D=3D true)
+				pBtCoex->c2hBtInfo =3D BT_INFO_STATE_ACL_INQ_OR_PAG;
+			else
+				pBtCoex->c2hBtInfo =3D BT_INFO_STATE_ACL_ONLY_BUSY;
+			pBtMgnt->ExtConfig.bBTBusy =3D true;
+		} else if (btState =3D=3D 0x3) {
+			pBtCoex->c2hBtInfo =3D BT_INFO_STATE_SCO_ONLY_BUSY;
+			pBtMgnt->ExtConfig.bBTBusy =3D true;
+		} else if (btState =3D=3D 0xb) {
+			pBtCoex->c2hBtInfo =3D BT_INFO_STATE_ACL_SCO_BUSY;
+			pBtMgnt->ExtConfig.bBTBusy =3D true;
+		} else {
+			pBtCoex->c2hBtInfo =3D BT_INFO_STATE_MAX;
+		}
+		if (pBtMgnt->ExtConfig.bBTBusy)
+			pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_BT_IDLE;
+	}
+
+	if ((BT_INFO_STATE_NO_CONNECTION =3D=3D pBtCoex->c2hBtInfo) ||
+	    (BT_INFO_STATE_CONNECT_IDLE =3D=3D pBtCoex->c2hBtInfo)) {
+		if (pBtCoex->bC2hBtInquiryPage)
+			pBtCoex->c2hBtInfo =3D BT_INFO_STATE_INQ_OR_PAG;
+	}
+
+	RTPRINT(FBT, BT_TRACE, ("[BTC2H], %s(%d)\n",
+			BtStateString[pBtCoex->c2hBtInfo], pBtCoex->c2hBtInfo));
+
+	if (pBtCoex->c2hBtProfile !=3D BT_INFO_HID)
+		pBtCoex->c2hBtProfile &=3D ~BT_INFO_HID;
+}
+
+void BTDM_1AntBtCoexist8723A(struct rtw_adapter *padapter)
+{
+	struct mlme_priv *pmlmepriv;
+	struct hal_data_8723a *pHalData;
+	unsigned long delta_time;
+
+	pmlmepriv =3D &padapter->mlmepriv;
+	pHalData =3D GET_HAL_DATA(padapter);
+
+	if (check_fwstate(pmlmepriv, WIFI_SITE_MONITOR)) {
+		/*  already done in BTDM_1AntForScan() */
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], wifi is under scan progress!!\n")=
);
+		return;
+	}
+
+	if (check_fwstate(pmlmepriv, WIFI_UNDER_LINKING)) {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], wifi is under link progress!!\n")=
);
+		return;
+	}
+
+	/*  under DHCP(Special packet) */
+	delta_time =3D jiffies - padapter->pwrctrlpriv.DelayLPSLastTimeStamp;
+	delta_time =3D jiffies_to_msecs(delta_time);
+	if (delta_time < 500) {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], wifi is under DHCP "
+					"progress(%li ms)!!\n", delta_time));
+		return;
+	}
+
+	BTDM_CheckWiFiState(padapter);
+
+	btdm_1AntBtCoexistHandler(padapter);
+}
+
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver HAL/BTCoexist/HalBtc87=
231Ant.c =3D=3D=3D=3D=3D */
+#endif
+
+#ifdef __HALBTC87232ANT_C__ /*  HAL/BTCoexist/HalBtc87232Ant.c */
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver HAL/BTCoex=
ist/HalBtc87232Ant.c =3D=3D=3D=3D=3D */
+
+/*  local function start with btdm_ */
+static u8 btdm_ActionAlgorithm(struct rtw_adapter *padapter)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_2ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm2Ant;
+	u8 bScoExist =3D false, bBtLinkExist =3D false, bBtHsModeExist =3D fa=
lse;
+	u8 algorithm =3D BT_2ANT_COEX_ALGO_UNDEFINED;
+
+	if (pBtMgnt->ExtConfig.NumberOfHandle)
+		bBtLinkExist =3D true;
+	if (pBtMgnt->ExtConfig.NumberOfSCO)
+		bScoExist =3D true;
+	if (BT_HsConnectionEstablished(padapter))
+		bBtHsModeExist =3D true;
+
+	/*  here we get BT status first */
+	/*  1) initialize */
+	pBtdm8723->btStatus =3D BT_2ANT_BT_STATUS_IDLE;
+
+	if ((bScoExist) || (bBtHsModeExist) ||
+	    (BTHCI_CheckProfileExist(padapter, BT_PROFILE_HID))) {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], SCO or HID or HS exists, set BT n=
on-idle !!!\n"));
+		pBtdm8723->btStatus =3D BT_2ANT_BT_STATUS_NON_IDLE;
+	} else {
+		/*  A2dp profile */
+		if ((pBtMgnt->ExtConfig.NumberOfHandle =3D=3D 1) &&
+		    (BTHCI_CheckProfileExist(padapter, BT_PROFILE_A2DP))) {
+			if (BTDM_BtTxRxCounterL(padapter) < 100) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], A2DP, low priority tx+rx < 100,=
 set BT connected-idle!!!\n"));
+				pBtdm8723->btStatus =3D BT_2ANT_BT_STATUS_CONNECTED_IDLE;
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], A2DP, low priority tx+rx >=3D 1=
00, set BT non-idle!!!\n"));
+				pBtdm8723->btStatus =3D BT_2ANT_BT_STATUS_NON_IDLE;
+			}
+		}
+		/*  Pan profile */
+		if ((pBtMgnt->ExtConfig.NumberOfHandle =3D=3D 1) &&
+		    (BTHCI_CheckProfileExist(padapter, BT_PROFILE_PAN))) {
+			if (BTDM_BtTxRxCounterL(padapter) < 600) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], PAN, low priority tx+rx < 600, =
set BT connected-idle!!!\n"));
+				pBtdm8723->btStatus =3D BT_2ANT_BT_STATUS_CONNECTED_IDLE;
+			} else {
+				if (pHalData->bt_coexist.halCoex8723.lowPriorityTx) {
+					if ((pHalData->bt_coexist.halCoex8723.lowPriorityRx /
+					    pHalData->bt_coexist.halCoex8723.lowPriorityTx) > 9) {
+						RTPRINT(FBT, BT_TRACE, ("[BTCoex], PAN, low priority rx/tx > 9, =
set BT connected-idle!!!\n"));
+						pBtdm8723->btStatus =3D BT_2ANT_BT_STATUS_CONNECTED_IDLE;
+					}
+				}
+			}
+			if (BT_2ANT_BT_STATUS_CONNECTED_IDLE !=3D pBtdm8723->btStatus) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], PAN, set BT non-idle!!!\n"));
+				pBtdm8723->btStatus =3D BT_2ANT_BT_STATUS_NON_IDLE;
+			}
+		}
+		/*  Pan+A2dp profile */
+		if ((pBtMgnt->ExtConfig.NumberOfHandle =3D=3D 2) &&
+		    (BTHCI_CheckProfileExist(padapter, BT_PROFILE_A2DP)) &&
+		    (BTHCI_CheckProfileExist(padapter, BT_PROFILE_PAN))) {
+			if (BTDM_BtTxRxCounterL(padapter) < 600) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], PAN+A2DP, low priority tx+rx < =
600, set BT connected-idle!!!\n"));
+				pBtdm8723->btStatus =3D BT_2ANT_BT_STATUS_CONNECTED_IDLE;
+			} else {
+				if (pHalData->bt_coexist.halCoex8723.lowPriorityTx) {
+					if ((pHalData->bt_coexist.halCoex8723.lowPriorityRx /
+					    pHalData->bt_coexist.halCoex8723.lowPriorityTx) > 9) {
+						RTPRINT(FBT, BT_TRACE, ("[BTCoex], PAN+A2DP, low priority rx/tx =
> 9, set BT connected-idle!!!\n"));
+						pBtdm8723->btStatus =3D BT_2ANT_BT_STATUS_CONNECTED_IDLE;
+					}
+				}
+			}
+			if (BT_2ANT_BT_STATUS_CONNECTED_IDLE !=3D pBtdm8723->btStatus) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], PAN+A2DP, set BT non-idle!!!\n"=
));
+				pBtdm8723->btStatus =3D BT_2ANT_BT_STATUS_NON_IDLE;
+			}
+		}
+	}
+	if (BT_2ANT_BT_STATUS_IDLE !=3D pBtdm8723->btStatus)
+		pBtMgnt->ExtConfig.bBTBusy =3D true;
+	else
+		pBtMgnt->ExtConfig.bBTBusy =3D false;
+
+	if (!bBtLinkExist) {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], No profile exists!!!\n"));
+		return algorithm;
+	}
+
+	if (pBtMgnt->ExtConfig.NumberOfHandle =3D=3D 1) {
+		if (bScoExist) {
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], SCO only\n"));
+			algorithm =3D BT_2ANT_COEX_ALGO_SCO;
+		} else {
+			if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_HID)) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], HID only\n"));
+				algorithm =3D BT_2ANT_COEX_ALGO_HID;
+			} else if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_A2DP)) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], A2DP only\n"));
+				algorithm =3D BT_2ANT_COEX_ALGO_A2DP;
+			} else if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_PAN)) {
+				if (bBtHsModeExist) {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], PAN(HS) only\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_PANHS;
+				} else {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], PAN(EDR) only\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_PANEDR;
+				}
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], Error!!! NO matched profile for=
 NumberOfHandle =3D%d \n",
+				pBtMgnt->ExtConfig.NumberOfHandle));
+			}
+		}
+	} else if (pBtMgnt->ExtConfig.NumberOfHandle =3D=3D 2) {
+		if (bScoExist) {
+			if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_HID)) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], SCO + HID\n"));
+				algorithm =3D BT_2ANT_COEX_ALGO_HID;
+			} else if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_A2DP)) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], Error!!! SCO + A2DP\n"));
+			} else if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_PAN)) {
+				if (bBtHsModeExist) {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], SCO + PAN(HS)\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_SCO;
+				} else {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], SCO + PAN(EDR)\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_PANEDR_HID;
+				}
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], Error!!! SCO exists but why NO =
matched ACL profile for NumberOfHandle =3D%d\n",
+				pBtMgnt->ExtConfig.NumberOfHandle));
+			}
+		} else {
+			if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_HID) &&
+			    BTHCI_CheckProfileExist(padapter, BT_PROFILE_A2DP)) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], HID + A2DP\n"));
+				algorithm =3D BT_2ANT_COEX_ALGO_HID_A2DP;
+		} else if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_HID) &&
+			   BTHCI_CheckProfileExist(padapter, BT_PROFILE_PAN)) {
+				if (bBtHsModeExist) {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], HID + PAN(HS)\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_HID_A2DP;
+				} else {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], HID + PAN(EDR)\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_PANEDR_HID;
+				}
+			} else if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_PAN) &&
+				   BTHCI_CheckProfileExist(padapter, BT_PROFILE_A2DP)) {
+				if (bBtHsModeExist) {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], A2DP + PAN(HS)\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_A2DP;
+				} else {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], A2DP + PAN(EDR)\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_PANEDR_A2DP;
+				}
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], Error!!! NO matched profile for=
 NumberOfHandle =3D%d\n",
+					pBtMgnt->ExtConfig.NumberOfHandle));
+			}
+		}
+	} else if (pBtMgnt->ExtConfig.NumberOfHandle =3D=3D 3) {
+		if (bScoExist) {
+			if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_HID) &&
+			    BTHCI_CheckProfileExist(padapter, BT_PROFILE_A2DP)) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], Error!!! SCO + HID + A2DP\n"));
+			} else if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_HID) &&
+				   BTHCI_CheckProfileExist(padapter, BT_PROFILE_PAN)) {
+				if (bBtHsModeExist) {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], SCO + HID + PAN(HS)\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_HID_A2DP;
+				} else {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], SCO + HID + PAN(EDR)\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_PANEDR_HID;
+				}
+			} else if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_PAN) &&
+				   BTHCI_CheckProfileExist(padapter, BT_PROFILE_A2DP)) {
+				if (bBtHsModeExist) {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], Error!!! SCO + A2DP + PAN(HS)\=
n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_SCO;
+				} else {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], Error!!! SCO + A2DP + PAN(EDR)=
\n"));
+				}
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], Error!!! SCO exists but why NO =
matched profile for NumberOfHandle =3D%d\n",
+					pBtMgnt->ExtConfig.NumberOfHandle));
+			}
+		} else {
+			if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_HID) &&
+			    BTHCI_CheckProfileExist(padapter, BT_PROFILE_PAN) &&
+			    BTHCI_CheckProfileExist(padapter, BT_PROFILE_A2DP)) {
+				if (bBtHsModeExist) {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], HID + A2DP + PAN(HS)\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_HID_A2DP_PANHS;
+				} else {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], HID + A2DP + PAN(EDR)\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_HID_A2DP_PANEDR;
+				}
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], Error!!! NO matched profile for=
 NumberOfHandle =3D%d\n",
+					pBtMgnt->ExtConfig.NumberOfHandle));
+			}
+		}
+	} else if (pBtMgnt->ExtConfig.NumberOfHandle >=3D 3) {
+		if (bScoExist) {
+			if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_HID) &&
+			    BTHCI_CheckProfileExist(padapter, BT_PROFILE_PAN) &&
+			    BTHCI_CheckProfileExist(padapter, BT_PROFILE_A2DP)) {
+				if (bBtHsModeExist)
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], Error!!! SCO + HID + A2DP + PA=
N(HS)\n"));
+				else
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], Error!!! SCO + HID + A2DP + PA=
N(EDR)\n"));
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], Error!!! SCO exists but why NO =
matched profile for NumberOfHandle =3D%d\n",
+					pBtMgnt->ExtConfig.NumberOfHandle));
+			}
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], Error!!! NO matched profile for =
NumberOfHandle =3D%d\n",
+				pBtMgnt->ExtConfig.NumberOfHandle));
+		}
+	}
+	return algorithm;
+}
+
+static u8 btdm_NeedToDecBtPwr(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u8 bRet =3D false;
+
+	if (BT_Operation(padapter)) {
+		if (pHalData->dmpriv.EntryMinUndecoratedSmoothedPWDB > 47) {
+			RTPRINT(FBT, BT_TRACE, ("Need to decrease bt power for HS mode!!\n"=
));
+			bRet =3D true;
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("NO Need to decrease bt power for HS mode!!=
\n"));
+		}
+	} else {
+		if (BTDM_IsWifiConnectionExist(padapter)) {
+			RTPRINT(FBT, BT_TRACE, ("Need to decrease bt power for Wifi is conn=
ected!!\n"));
+			bRet =3D true;
+		}
+	}
+	return bRet;
+}
+
+static void
+btdm_SetCoexTable(struct rtw_adapter *padapter, u32 val0x6c0,
+		  u32 val0x6c8, u8 val0x6cc)
+{
+	RTPRINT(FBT, BT_TRACE, ("set coex table, set 0x6c0 =3D 0x%x\n", val0x=
6c0));
+	rtw_write32(padapter, 0x6c0, val0x6c0);
+
+	RTPRINT(FBT, BT_TRACE, ("set coex table, set 0x6c8 =3D 0x%x\n", val0x=
6c8));
+	rtw_write32(padapter, 0x6c8, val0x6c8);
+
+	RTPRINT(FBT, BT_TRACE, ("set coex table, set 0x6cc =3D 0x%x\n", val0x=
6cc));
+	rtw_write8(padapter, 0x6cc, val0x6cc);
+}
+
+static void
+btdm_SetSwFullTimeDacSwing(struct rtw_adapter *padapter, u8 bSwDacSwin=
gOn,
+			   u32 swDacSwingLvl)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (bSwDacSwingOn) {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], SwDacSwing =3D 0x%x\n", swDacSwin=
gLvl));
+		PHY_SetBBReg(padapter, 0x880, 0xff000000, swDacSwingLvl);
+		pHalData->bt_coexist.bSWCoexistAllOff =3D false;
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], SwDacSwing Off!\n"));
+		PHY_SetBBReg(padapter, 0x880, 0xff000000, 0xc0);
+	}
+}
+
+static void
+btdm_SetFwDacSwingLevel(struct rtw_adapter *padapter, u8 dacSwingLvl)
+{
+	u8 H2C_Parameter[1] =3D {0};
+
+	H2C_Parameter[0] =3D dacSwingLvl;
+
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], Set Dac Swing Level =3D 0x%x\n", d=
acSwingLvl));
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], write 0x29 =3D 0x%x\n", H2C_Parame=
ter[0]));
+
+	FillH2CCmd(padapter, 0x29, 1, H2C_Parameter);
+}
+
+static void btdm_2AntDecBtPwr(struct rtw_adapter *padapter, u8 bDecBtP=
wr)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_2ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm2Ant;
+
+	RTPRINT(FBT, BT_TRACE,
+		("[BTCoex], Dec BT power =3D %s\n",
+		((bDecBtPwr) ? "ON" : "OFF")));
+	pBtdm8723->bCurDecBtPwr =3D bDecBtPwr;
+
+	if (pBtdm8723->bPreDecBtPwr =3D=3D pBtdm8723->bCurDecBtPwr)
+		return;
+
+	BTDM_SetFwDecBtPwr(padapter, pBtdm8723->bCurDecBtPwr);
+
+	pBtdm8723->bPreDecBtPwr =3D pBtdm8723->bCurDecBtPwr;
+}
+
+static void
+btdm_2AntFwDacSwingLvl(struct rtw_adapter *padapter, u8 fwDacSwingLvl)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_2ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm2Ant;
+
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], set FW Dac Swing level =3D %d\n", =
 fwDacSwingLvl));
+	pBtdm8723->curFwDacSwingLvl =3D fwDacSwingLvl;
+
+	/* RTPRINT(FBT, BT_TRACE, ("[BTCoex], preFwDacSwingLvl =3D%d, curFwDa=
cSwingLvl =3D%d\n", */
+	/*pBtdm8723->preFwDacSwingLvl, pBtdm8723->curFwDacSwingLvl)); */
+
+	if (pBtdm8723->preFwDacSwingLvl =3D=3D pBtdm8723->curFwDacSwingLvl)
+		return;
+
+	btdm_SetFwDacSwingLevel(padapter, pBtdm8723->curFwDacSwingLvl);
+
+	pBtdm8723->preFwDacSwingLvl =3D pBtdm8723->curFwDacSwingLvl;
+}
+
+static void
+btdm_2AntRfShrink(struct rtw_adapter *padapter, u8 bRxRfShrinkOn)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_2ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm2Ant;
+
+	RTPRINT(FBT, BT_TRACE,
+		("[BTCoex], turn Rx RF Shrink =3D %s\n",
+		((bRxRfShrinkOn) ? "ON" : "OFF")));
+	pBtdm8723->bCurRfRxLpfShrink =3D bRxRfShrinkOn;
+
+	/* RTPRINT(FBT, BT_TRACE, ("[BTCoex], bPreRfRxLpfShrink =3D%d, bCurRf=
RxLpfShrink =3D%d\n", */
+	/*pBtdm8723->bPreRfRxLpfShrink, pBtdm8723->bCurRfRxLpfShrink)); */
+
+	if (pBtdm8723->bPreRfRxLpfShrink =3D=3D pBtdm8723->bCurRfRxLpfShrink)
+		return;
+
+	BTDM_SetSwRfRxLpfCorner(padapter, (u8)pBtdm8723->bCurRfRxLpfShrink);
+
+	pBtdm8723->bPreRfRxLpfShrink =3D pBtdm8723->bCurRfRxLpfShrink;
+}
+
+static void
+btdm_2AntLowPenaltyRa(struct rtw_adapter *padapter, u8 bLowPenaltyRa)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_2ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm2Ant;
+
+	RTPRINT(FBT, BT_TRACE,
+		("[BTCoex], turn LowPenaltyRA =3D %s\n",
+		((bLowPenaltyRa) ? "ON" : "OFF")));
+	pBtdm8723->bCurLowPenaltyRa =3D bLowPenaltyRa;
+
+	/* RTPRINT(FBT, BT_TRACE, ("[BTCoex], bPreLowPenaltyRa =3D%d, bCurLow=
PenaltyRa =3D%d\n", */
+	/*pBtdm8723->bPreLowPenaltyRa, pBtdm8723->bCurLowPenaltyRa)); */
+
+	if (pBtdm8723->bPreLowPenaltyRa =3D=3D pBtdm8723->bCurLowPenaltyRa)
+		return;
+
+	BTDM_SetSwPenaltyTxRateAdaptive(padapter, (u8)pBtdm8723->bCurLowPenal=
tyRa);
+
+	pBtdm8723->bPreLowPenaltyRa =3D pBtdm8723->bCurLowPenaltyRa;
+}
+
+static void
+btdm_2AntDacSwing(struct rtw_adapter *padapter,
+		  u8 bDacSwingOn, u32 dacSwingLvl)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_2ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm2Ant;
+
+	RTPRINT(FBT, BT_TRACE,
+		("[BTCoex], turn DacSwing =3D%s, dacSwingLvl =3D 0x%x\n",
+		(bDacSwingOn ? "ON" : "OFF"), dacSwingLvl));
+	pBtdm8723->bCurDacSwingOn =3D bDacSwingOn;
+	pBtdm8723->curDacSwingLvl =3D dacSwingLvl;
+
+	if ((pBtdm8723->bPreDacSwingOn =3D=3D pBtdm8723->bCurDacSwingOn) &&
+	    (pBtdm8723->preDacSwingLvl =3D=3D pBtdm8723->curDacSwingLvl))
+		return;
+
+	mdelay(30);
+	btdm_SetSwFullTimeDacSwing(padapter, bDacSwingOn, dacSwingLvl);
+
+	pBtdm8723->bPreDacSwingOn =3D pBtdm8723->bCurDacSwingOn;
+	pBtdm8723->preDacSwingLvl =3D pBtdm8723->curDacSwingLvl;
+}
+
+static void btdm_2AntAdcBackOff(struct rtw_adapter *padapter, u8 bAdcB=
ackOff)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_2ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm2Ant;
+
+	RTPRINT(FBT, BT_TRACE,
+		("[BTCoex], turn AdcBackOff =3D %s\n",
+		((bAdcBackOff) ? "ON" : "OFF")));
+	pBtdm8723->bCurAdcBackOff =3D bAdcBackOff;
+
+	if (pBtdm8723->bPreAdcBackOff =3D=3D pBtdm8723->bCurAdcBackOff)
+		return;
+
+	BTDM_BBBackOffLevel(padapter, (u8)pBtdm8723->bCurAdcBackOff);
+
+	pBtdm8723->bPreAdcBackOff =3D pBtdm8723->bCurAdcBackOff;
+}
+
+static void btdm_2AntAgcTable(struct rtw_adapter *padapter, u8 bAgcTab=
leEn)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_2ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm2Ant;
+
+	RTPRINT(FBT, BT_TRACE,
+		("[BTCoex], %s Agc Table\n", ((bAgcTableEn) ? "Enable" : "Disable"))=
);
+	pBtdm8723->bCurAgcTableEn =3D bAgcTableEn;
+
+	/* RTPRINT(FBT, BT_TRACE, ("[BTCoex], bPreAgcTableEn =3D%d, bCurAgcTa=
bleEn =3D%d\n", */
+	/*pBtdm8723->bPreAgcTableEn, pBtdm8723->bCurAgcTableEn)); */
+
+	if (pBtdm8723->bPreAgcTableEn =3D=3D pBtdm8723->bCurAgcTableEn)
+		return;
+
+	BTDM_AGCTable(padapter, (u8)bAgcTableEn);
+
+	pBtdm8723->bPreAgcTableEn =3D pBtdm8723->bCurAgcTableEn;
+}
+
+static void
+btdm_2AntCoexTable(struct rtw_adapter *padapter,
+		   u32 val0x6c0, u32 val0x6c8, u8 val0x6cc)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_2ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm2Ant;
+
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], write Coex Table 0x6c0 =3D 0x%x, 0=
x6c8 =3D 0x%x, 0x6cc =3D 0x%x\n",
+		val0x6c0, val0x6c8, val0x6cc));
+	pBtdm8723->curVal0x6c0 =3D val0x6c0;
+	pBtdm8723->curVal0x6c8 =3D val0x6c8;
+	pBtdm8723->curVal0x6cc =3D val0x6cc;
+
+	/* RTPRINT(FBT, BT_TRACE, ("[BTCoex], preVal0x6c0 =3D 0x%x, preVal0x6=
c8 =3D 0x%x, preVal0x6cc =3D 0x%x !!\n", */
+	/*pBtdm8723->preVal0x6c0, pBtdm8723->preVal0x6c8, pBtdm8723->preVal0x=
6cc)); */
+	/* RTPRINT(FBT, BT_TRACE, ("[BTCoex], curVal0x6c0 =3D 0x%x, curVal0x6=
c8 =3D 0x%x, curVal0x6cc =3D 0x%x !!\n", */
+	/*pBtdm8723->curVal0x6c0, pBtdm8723->curVal0x6c8, pBtdm8723->curVal0x=
6cc)); */
+
+	if ((pBtdm8723->preVal0x6c0 =3D=3D pBtdm8723->curVal0x6c0) &&
+	    (pBtdm8723->preVal0x6c8 =3D=3D pBtdm8723->curVal0x6c8) &&
+	    (pBtdm8723->preVal0x6cc =3D=3D pBtdm8723->curVal0x6cc))
+		return;
+
+	btdm_SetCoexTable(padapter, val0x6c0, val0x6c8, val0x6cc);
+
+	pBtdm8723->preVal0x6c0 =3D pBtdm8723->curVal0x6c0;
+	pBtdm8723->preVal0x6c8 =3D pBtdm8723->curVal0x6c8;
+	pBtdm8723->preVal0x6cc =3D pBtdm8723->curVal0x6cc;
+}
+
+static void btdm_2AntIgnoreWlanAct(struct rtw_adapter *padapter, u8 bE=
nable)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_2ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm2Ant;
+
+	RTPRINT(FBT, BT_TRACE,
+		("[BTCoex], turn Ignore WlanAct %s\n", (bEnable ? "ON" : "OFF")));
+	pBtdm8723->bCurIgnoreWlanAct =3D bEnable;
+
+
+	if (pBtdm8723->bPreIgnoreWlanAct =3D=3D pBtdm8723->bCurIgnoreWlanAct)
+		return;
+
+	btdm_SetFwIgnoreWlanAct(padapter, bEnable);
+	pBtdm8723->bPreIgnoreWlanAct =3D pBtdm8723->bCurIgnoreWlanAct;
+}
+
+static void
+btdm_2AntSetFw3a(struct rtw_adapter *padapter, u8 byte1, u8 byte2,
+		 u8 byte3, u8 byte4, u8 byte5)
+{
+	u8 H2C_Parameter[5] =3D {0};
+
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	/*  byte1[1:0] !=3D 0 means enable pstdma */
+	/*  for 2Ant bt coexist, if byte1 !=3D 0 means enable pstdma */
+	if (byte1)
+		pHalData->bt_coexist.bFWCoexistAllOff =3D false;
+	H2C_Parameter[0] =3D byte1;
+	H2C_Parameter[1] =3D byte2;
+	H2C_Parameter[2] =3D byte3;
+	H2C_Parameter[3] =3D byte4;
+	H2C_Parameter[4] =3D byte5;
+
+	pHalData->bt_coexist.fw3aVal[0] =3D byte1;
+	pHalData->bt_coexist.fw3aVal[1] =3D byte2;
+	pHalData->bt_coexist.fw3aVal[2] =3D byte3;
+	pHalData->bt_coexist.fw3aVal[3] =3D byte4;
+	pHalData->bt_coexist.fw3aVal[4] =3D byte5;
+
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], FW write 0x3a(5bytes) =3D 0x%x%08x=
\n",
+		H2C_Parameter[0],
+		H2C_Parameter[1]<<24|H2C_Parameter[2]<<16|H2C_Parameter[3]<<8|H2C_Pa=
rameter[4]));
+
+	FillH2CCmd(padapter, 0x3a, 5, H2C_Parameter);
+	}
+
+static void btdm_2AntPsTdma(struct rtw_adapter *padapter, u8 bTurnOn, =
u8 type)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_2ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm2Ant;
+	u32			btTxRxCnt =3D 0;
+	u8 bTurnOnByCnt =3D false;
+	u8 psTdmaTypeByCnt =3D 0;
+
+	btTxRxCnt =3D BTDM_BtTxRxCounterH(padapter)+BTDM_BtTxRxCounterL(padap=
ter);
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT TxRx Counters =3D %d\n", btTxRx=
Cnt));
+	if (btTxRxCnt > 3000) {
+		bTurnOnByCnt =3D true;
+		psTdmaTypeByCnt =3D 8;
+
+		RTPRINT(FBT, BT_TRACE,
+			("[BTCoex], For BTTxRxCounters, turn %s PS TDMA, type =3D%d\n",
+			(bTurnOnByCnt ? "ON" : "OFF"), psTdmaTypeByCnt));
+		pBtdm8723->bCurPsTdmaOn =3D bTurnOnByCnt;
+		pBtdm8723->curPsTdma =3D psTdmaTypeByCnt;
+	} else {
+		RTPRINT(FBT, BT_TRACE,
+			("[BTCoex], turn %s PS TDMA, type =3D%d\n",
+			(bTurnOn ? "ON" : "OFF"), type));
+		pBtdm8723->bCurPsTdmaOn =3D bTurnOn;
+		pBtdm8723->curPsTdma =3D type;
+	}
+
+	if ((pBtdm8723->bPrePsTdmaOn =3D=3D pBtdm8723->bCurPsTdmaOn) &&
+	    (pBtdm8723->prePsTdma =3D=3D pBtdm8723->curPsTdma))
+		return;
+
+	if (bTurnOn) {
+		switch (type) {
+		case 1:
+		default:
+			btdm_2AntSetFw3a(padapter, 0xe3, 0x1a, 0x1a, 0xa1, 0x98);
+			break;
+		case 2:
+			btdm_2AntSetFw3a(padapter, 0xe3, 0x12, 0x12, 0xa1, 0x98);
+			break;
+		case 3:
+			btdm_2AntSetFw3a(padapter, 0xe3, 0xa, 0xa, 0xa1, 0x98);
+			break;
+		case 4:
+			btdm_2AntSetFw3a(padapter, 0xa3, 0x5, 0x5, 0xa1, 0x80);
+			break;
+		case 5:
+			btdm_2AntSetFw3a(padapter, 0xe3, 0x1a, 0x1a, 0x20, 0x98);
+			break;
+		case 6:
+			btdm_2AntSetFw3a(padapter, 0xe3, 0x12, 0x12, 0x20, 0x98);
+			break;
+		case 7:
+			btdm_2AntSetFw3a(padapter, 0xe3, 0xa, 0xa, 0x20, 0x98);
+			break;
+		case 8:
+			btdm_2AntSetFw3a(padapter, 0xa3, 0x5, 0x5, 0x20, 0x80);
+			break;
+		case 9:
+			btdm_2AntSetFw3a(padapter, 0xe3, 0x1a, 0x1a, 0xa1, 0x98);
+			break;
+		case 10:
+			btdm_2AntSetFw3a(padapter, 0xe3, 0x12, 0x12, 0xa1, 0x98);
+			break;
+		case 11:
+			btdm_2AntSetFw3a(padapter, 0xe3, 0xa, 0xa, 0xa1, 0x98);
+			break;
+		case 12:
+			btdm_2AntSetFw3a(padapter, 0xe3, 0x5, 0x5, 0xa1, 0x98);
+			break;
+		case 13:
+			btdm_2AntSetFw3a(padapter, 0xe3, 0x1a, 0x1a, 0x20, 0x98);
+			break;
+		case 14:
+			btdm_2AntSetFw3a(padapter, 0xe3, 0x12, 0x12, 0x20, 0x98);
+			break;
+		case 15:
+			btdm_2AntSetFw3a(padapter, 0xe3, 0xa, 0xa, 0x20, 0x98);
+			break;
+		case 16:
+			btdm_2AntSetFw3a(padapter, 0xe3, 0x5, 0x5, 0x20, 0x98);
+			break;
+		case 17:
+			btdm_2AntSetFw3a(padapter, 0xa3, 0x2f, 0x2f, 0x20, 0x80);
+			break;
+		case 18:
+			btdm_2AntSetFw3a(padapter, 0xe3, 0x5, 0x5, 0xa1, 0x98);
+			break;
+		case 19:
+			btdm_2AntSetFw3a(padapter, 0xe3, 0x25, 0x25, 0xa1, 0x98);
+			break;
+		case 20:
+			btdm_2AntSetFw3a(padapter, 0xe3, 0x25, 0x25, 0x20, 0x98);
+			break;
+		}
+	} else {
+		/*  disable PS tdma */
+		switch (type) {
+		case 0:
+			btdm_2AntSetFw3a(padapter, 0x0, 0x0, 0x0, 0x8, 0x0);
+			break;
+		case 1:
+			btdm_2AntSetFw3a(padapter, 0x0, 0x0, 0x0, 0x0, 0x0);
+			break;
+		default:
+			btdm_2AntSetFw3a(padapter, 0x0, 0x0, 0x0, 0x8, 0x0);
+			break;
+		}
+	}
+
+	/*  update pre state */
+	pBtdm8723->bPrePsTdmaOn =3D  pBtdm8723->bCurPsTdmaOn;
+	pBtdm8723->prePsTdma =3D pBtdm8723->curPsTdma;
+}
+
+static void btdm_2AntBtInquiryPage(struct rtw_adapter *padapter)
+{
+	btdm_2AntCoexTable(padapter, 0x55555555, 0xffff, 0x3);
+	btdm_2AntIgnoreWlanAct(padapter, false);
+	btdm_2AntPsTdma(padapter, true, 8);
+}
+
+static u8 btdm_HoldForBtInqPage(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u32 curTime =3D rtw_get_current_time();
+
+	if (pHalData->bt_coexist.halCoex8723.bC2hBtInquiryPage) {
+		/*  bt inquiry or page is started. */
+		if (pHalData->bt_coexist.halCoex8723.btInqPageStartTime =3D=3D 0) {
+			pHalData->bt_coexist.halCoex8723.btInqPageStartTime =3D curTime;
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT Inquiry/page is started at ti=
me : 0x%"i64fmt"x \n",
+			pHalData->bt_coexist.halCoex8723.btInqPageStartTime));
+		}
+	}
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT Inquiry/page started time : 0x%=
"i64fmt"x, curTime : 0x%x \n",
+		pHalData->bt_coexist.halCoex8723.btInqPageStartTime, curTime));
+
+	if (pHalData->bt_coexist.halCoex8723.btInqPageStartTime) {
+		if (((curTime - pHalData->bt_coexist.halCoex8723.btInqPageStartTime)=
/1000000) >=3D 10) {
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], BT Inquiry/page >=3D 10sec!!!"))=
;
+			pHalData->bt_coexist.halCoex8723.btInqPageStartTime =3D 0;
+		}
+	}
+
+	if (pHalData->bt_coexist.halCoex8723.btInqPageStartTime) {
+		btdm_2AntCoexTable(padapter, 0x55555555, 0xffff, 0x3);
+		btdm_2AntIgnoreWlanAct(padapter, false);
+		btdm_2AntPsTdma(padapter, true, 8);
+		return true;
+	} else {
+		return false;
+	}
+}
+
+static u8 btdm_Is2Ant8723ACommonAction(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_2ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm2Ant;
+	u8 bCommon =3D false;
+
+	RTPRINT(FBT, BT_TRACE, ("%s :BTDM_IsWifiConnectionExist =3D%x check_f=
wstate =3D%x pmlmepriv->fw_state =3D 0x%x\n", __func__, BTDM_IsWifiConn=
ectionExist(padapter), check_fwstate(&padapter->mlmepriv, (_FW_UNDER_SU=
RVEY|_FW_UNDER_LINKING)), padapter->mlmepriv.fw_state));
+
+	if ((!BTDM_IsWifiConnectionExist(padapter)) &&
+	    (!check_fwstate(&padapter->mlmepriv, (_FW_UNDER_SURVEY|_FW_UNDER_=
LINKING))) &&
+	    (BT_2ANT_BT_STATUS_IDLE =3D=3D pBtdm8723->btStatus)) {
+		RTPRINT(FBT, BT_TRACE, ("Wifi idle + Bt idle!!\n"));
+
+		btdm_2AntLowPenaltyRa(padapter, false);
+		btdm_2AntRfShrink(padapter, false);
+		btdm_2AntCoexTable(padapter, 0x55555555, 0xffff, 0x3);
+
+		btdm_2AntIgnoreWlanAct(padapter, false);
+		btdm_2AntPsTdma(padapter, false, 0);
+		btdm_2AntFwDacSwingLvl(padapter, 0x20);
+		btdm_2AntDecBtPwr(padapter, false);
+
+		btdm_2AntAgcTable(padapter, false);
+		btdm_2AntAdcBackOff(padapter, false);
+		btdm_2AntDacSwing(padapter, false, 0xc0);
+
+		bCommon =3D true;
+	} else if (((BTDM_IsWifiConnectionExist(padapter)) ||
+		   (check_fwstate(&padapter->mlmepriv, (_FW_UNDER_SURVEY|_FW_UNDER_L=
INKING)))) &&
+		   (BT_2ANT_BT_STATUS_IDLE =3D=3D pBtdm8723->btStatus)) {
+		RTPRINT(FBT, BT_TRACE, ("Wifi non-idle + BT idle!!\n"));
+
+		btdm_2AntLowPenaltyRa(padapter, true);
+		btdm_2AntRfShrink(padapter, false);
+		btdm_2AntCoexTable(padapter, 0x55555555, 0xffff, 0x3);
+
+		btdm_2AntIgnoreWlanAct(padapter, false);
+		btdm_2AntPsTdma(padapter, false, 0);
+		btdm_2AntFwDacSwingLvl(padapter, 0x20);
+		btdm_2AntDecBtPwr(padapter, true);
+
+		btdm_2AntAgcTable(padapter, false);
+		btdm_2AntAdcBackOff(padapter, false);
+		btdm_2AntDacSwing(padapter, false, 0xc0);
+
+		bCommon =3D true;
+	} else if ((!BTDM_IsWifiConnectionExist(padapter)) &&
+		   (!check_fwstate(&padapter->mlmepriv, (_FW_UNDER_SURVEY|_FW_UNDER_=
LINKING))) &&
+		   (BT_2ANT_BT_STATUS_CONNECTED_IDLE =3D=3D pBtdm8723->btStatus)) {
+		RTPRINT(FBT, BT_TRACE, ("Wifi idle + Bt connected idle!!\n"));
+
+		btdm_2AntLowPenaltyRa(padapter, true);
+		btdm_2AntRfShrink(padapter, true);
+		btdm_2AntCoexTable(padapter, 0x55555555, 0xffff, 0x3);
+
+		btdm_2AntIgnoreWlanAct(padapter, false);
+		btdm_2AntPsTdma(padapter, false, 0);
+		btdm_2AntFwDacSwingLvl(padapter, 0x20);
+		btdm_2AntDecBtPwr(padapter, false);
+
+		btdm_2AntAgcTable(padapter, false);
+		btdm_2AntAdcBackOff(padapter, false);
+		btdm_2AntDacSwing(padapter, false, 0xc0);
+
+		bCommon =3D true;
+	} else if (((BTDM_IsWifiConnectionExist(padapter)) ||
+		   (check_fwstate(&padapter->mlmepriv, (_FW_UNDER_SURVEY|_FW_UNDER_L=
INKING)))) &&
+		   (BT_2ANT_BT_STATUS_CONNECTED_IDLE =3D=3D pBtdm8723->btStatus)) {
+		RTPRINT(FBT, BT_TRACE, ("Wifi non-idle + Bt connected idle!!\n"));
+
+		btdm_2AntLowPenaltyRa(padapter, true);
+		btdm_2AntRfShrink(padapter, true);
+		btdm_2AntCoexTable(padapter, 0x55555555, 0xffff, 0x3);
+
+		btdm_2AntIgnoreWlanAct(padapter, false);
+		btdm_2AntPsTdma(padapter, false, 0);
+		btdm_2AntFwDacSwingLvl(padapter, 0x20);
+		btdm_2AntDecBtPwr(padapter, true);
+
+		btdm_2AntAgcTable(padapter, false);
+		btdm_2AntAdcBackOff(padapter, false);
+		btdm_2AntDacSwing(padapter, false, 0xc0);
+
+		bCommon =3D true;
+	} else if ((!BTDM_IsWifiConnectionExist(padapter)) &&
+		   (!check_fwstate(&padapter->mlmepriv, (_FW_UNDER_SURVEY|_FW_UNDER_=
LINKING))) &&
+		   (BT_2ANT_BT_STATUS_NON_IDLE =3D=3D pBtdm8723->btStatus)) {
+		RTPRINT(FBT, BT_TRACE, ("Wifi idle + BT non-idle!!\n"));
+
+		btdm_2AntLowPenaltyRa(padapter, true);
+		btdm_2AntRfShrink(padapter, true);
+		btdm_2AntCoexTable(padapter, 0x55555555, 0xffff, 0x3);
+
+		btdm_2AntIgnoreWlanAct(padapter, false);
+		btdm_2AntPsTdma(padapter, false, 0);
+		btdm_2AntFwDacSwingLvl(padapter, 0x20);
+		btdm_2AntDecBtPwr(padapter, false);
+
+		btdm_2AntAgcTable(padapter, false);
+		btdm_2AntAdcBackOff(padapter, false);
+		btdm_2AntDacSwing(padapter, false, 0xc0);
+
+		bCommon =3D true;
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("Wifi non-idle + BT non-idle!!\n"));
+		btdm_2AntLowPenaltyRa(padapter, true);
+		btdm_2AntRfShrink(padapter, true);
+		btdm_2AntCoexTable(padapter, 0x55555555, 0xffff, 0x3);
+		btdm_2AntIgnoreWlanAct(padapter, false);
+		btdm_2AntFwDacSwingLvl(padapter, 0x20);
+
+		bCommon =3D false;
+	}
+	return bCommon;
+}
+
+static void
+btdm_2AntTdmaDurationAdjust(struct rtw_adapter *padapter, u8 bScoHid,
+			    u8 bTxPause, u8 maxInterval)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_2ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm2Ant;
+	static s32		up, dn, m, n, WaitCount;
+	s32			result;   /* 0: no change, +1: increase WiFi duration, -1: decr=
ease WiFi duration */
+	u8 retryCount =3D 0;
+
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], TdmaDurationAdjust()\n"));
+
+	if (pBtdm8723->bResetTdmaAdjust) {
+		pBtdm8723->bResetTdmaAdjust =3D false;
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], first run TdmaDurationAdjust()!!\=
n"));
+		if (bScoHid) {
+			if (bTxPause) {
+				if (maxInterval =3D=3D 1) {
+					btdm_2AntPsTdma(padapter, true, 15);
+					pBtdm8723->psTdmaDuAdjType =3D 15;
+				} else if (maxInterval =3D=3D 2) {
+					btdm_2AntPsTdma(padapter, true, 15);
+					pBtdm8723->psTdmaDuAdjType =3D 15;
+				} else if (maxInterval =3D=3D 3) {
+					btdm_2AntPsTdma(padapter, true, 15);
+					pBtdm8723->psTdmaDuAdjType =3D 15;
+				} else {
+					btdm_2AntPsTdma(padapter, true, 15);
+					pBtdm8723->psTdmaDuAdjType =3D 15;
+				}
+			} else {
+				if (maxInterval =3D=3D 1) {
+					btdm_2AntPsTdma(padapter, true, 11);
+					pBtdm8723->psTdmaDuAdjType =3D 11;
+				} else if (maxInterval =3D=3D 2) {
+					btdm_2AntPsTdma(padapter, true, 11);
+					pBtdm8723->psTdmaDuAdjType =3D 11;
+				} else if (maxInterval =3D=3D 3) {
+					btdm_2AntPsTdma(padapter, true, 11);
+					pBtdm8723->psTdmaDuAdjType =3D 11;
+				} else {
+					btdm_2AntPsTdma(padapter, true, 11);
+					pBtdm8723->psTdmaDuAdjType =3D 11;
+				}
+			}
+		} else {
+			if (bTxPause) {
+				if (maxInterval =3D=3D 1) {
+					btdm_2AntPsTdma(padapter, true, 7);
+					pBtdm8723->psTdmaDuAdjType =3D 7;
+				} else if (maxInterval =3D=3D 2) {
+					btdm_2AntPsTdma(padapter, true, 7);
+					pBtdm8723->psTdmaDuAdjType =3D 7;
+				} else if (maxInterval =3D=3D 3) {
+					btdm_2AntPsTdma(padapter, true, 7);
+					pBtdm8723->psTdmaDuAdjType =3D 7;
+				} else {
+					btdm_2AntPsTdma(padapter, true, 7);
+					pBtdm8723->psTdmaDuAdjType =3D 7;
+				}
+			} else {
+				if (maxInterval =3D=3D 1) {
+					btdm_2AntPsTdma(padapter, true, 3);
+					pBtdm8723->psTdmaDuAdjType =3D 3;
+				} else if (maxInterval =3D=3D 2) {
+					btdm_2AntPsTdma(padapter, true, 3);
+					pBtdm8723->psTdmaDuAdjType =3D 3;
+				} else if (maxInterval =3D=3D 3) {
+					btdm_2AntPsTdma(padapter, true, 3);
+					pBtdm8723->psTdmaDuAdjType =3D 3;
+				} else {
+					btdm_2AntPsTdma(padapter, true, 3);
+					pBtdm8723->psTdmaDuAdjType =3D 3;
+				}
+			}
+		}
+		up =3D 0;
+		dn =3D 0;
+		m =3D 1;
+		n =3D 3;
+		result =3D 0;
+		WaitCount =3D 0;
+	} else {
+		/* accquire the BT TRx retry count from BT_Info byte2 */
+		retryCount =3D pHalData->bt_coexist.halCoex8723.btRetryCnt;
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], retryCount =3D %d\n", retryCount)=
);
+		result =3D 0;
+		WaitCount++;
+
+		if (retryCount =3D=3D 0) {  /*  no retry in the last 2-second durati=
on */
+			up++;
+			dn--;
+
+			if (dn <=3D 0)
+				dn =3D 0;
+
+			if (up >=3D n) {	/*  if =B3s=C4=F2 n =AD=D32=AC=ED retry count=AC=B0=
0, =ABh=BD=D5=BCeWiFi duration */
+				WaitCount =3D 0;
+				n =3D 3;
+				up =3D 0;
+				dn =3D 0;
+				result =3D 1;
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], Increase wifi duration!!\n"));
+			}
+		} else if (retryCount <=3D 3) {	/*  <=3D 3 retry in the last 2-secon=
d duration */
+			up--;
+			dn++;
+
+			if (up <=3D 0)
+				up =3D 0;
+
+			if (dn =3D=3D 2) {	/*  if =B3s=C4=F2 2 =AD=D32=AC=ED retry count< 3=
, =ABh=BD=D5=AF=B6WiFi duration */
+				if (WaitCount <=3D 2)
+					m++; /*  =C1=D7=A7K=A4@=AA=BD=A6b=A8=E2=AD=D3level=A4=A4=A8=D3=A6=
^ */
+				else
+					m =3D 1;
+
+				if (m >=3D 20) /* m =B3=CC=A4j=AD=C8 =3D 20 ' =B3=CC=A4j120=AC=ED =
recheck=ACO=A7_=BD=D5=BE=E3 WiFi duration. */
+					m =3D 20;
+
+				n =3D 3*m;
+				up =3D 0;
+				dn =3D 0;
+				WaitCount =3D 0;
+				result =3D -1;
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], Decrease wifi duration for retr=
yCounter<3!!\n"));
+			}
+		} else {  /* retry count > 3, =A5u=ADn1=A6=B8 retry count > 3, =ABh=BD=
=D5=AF=B6WiFi duration */
+			if (WaitCount =3D=3D 1)
+				m++; /*  =C1=D7=A7K=A4@=AA=BD=A6b=A8=E2=AD=D3level=A4=A4=A8=D3=A6^=
 */
+			else
+				m =3D 1;
+
+			if (m >=3D 20) /* m =B3=CC=A4j=AD=C8 =3D 20 ' =B3=CC=A4j120=AC=ED r=
echeck=ACO=A7_=BD=D5=BE=E3 WiFi duration. */
+				m =3D 20;
+			n =3D 3*m;
+			up =3D 0;
+			dn =3D 0;
+			WaitCount =3D 0;
+			result =3D -1;
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], Decrease wifi duration for retry=
Counter>3!!\n"));
+		}
+
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], max Interval =3D %d\n", maxInterv=
al));
+		if (maxInterval =3D=3D 1) {
+			if (bTxPause) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], TxPause =3D 1\n"));
+				if (pBtdm8723->curPsTdma =3D=3D 1) {
+					btdm_2AntPsTdma(padapter, true, 5);
+					pBtdm8723->psTdmaDuAdjType =3D 5;
+				} else if (pBtdm8723->curPsTdma =3D=3D 2) {
+					btdm_2AntPsTdma(padapter, true, 6);
+					pBtdm8723->psTdmaDuAdjType =3D 6;
+				} else if (pBtdm8723->curPsTdma =3D=3D 3) {
+					btdm_2AntPsTdma(padapter, true, 7);
+					pBtdm8723->psTdmaDuAdjType =3D 7;
+				} else if (pBtdm8723->curPsTdma =3D=3D 4) {
+					btdm_2AntPsTdma(padapter, true, 8);
+					pBtdm8723->psTdmaDuAdjType =3D 8;
+				}
+				if (pBtdm8723->curPsTdma =3D=3D 9) {
+					btdm_2AntPsTdma(padapter, true, 13);
+					pBtdm8723->psTdmaDuAdjType =3D 13;
+				} else if (pBtdm8723->curPsTdma =3D=3D 10) {
+					btdm_2AntPsTdma(padapter, true, 14);
+					pBtdm8723->psTdmaDuAdjType =3D 14;
+				} else if (pBtdm8723->curPsTdma =3D=3D 11) {
+					btdm_2AntPsTdma(padapter, true, 15);
+					pBtdm8723->psTdmaDuAdjType =3D 15;
+				} else if (pBtdm8723->curPsTdma =3D=3D 12) {
+					btdm_2AntPsTdma(padapter, true, 16);
+					pBtdm8723->psTdmaDuAdjType =3D 16;
+				}
+
+				if (result =3D=3D -1) {
+					if (pBtdm8723->curPsTdma =3D=3D 5) {
+						btdm_2AntPsTdma(padapter, true, 6);
+						pBtdm8723->psTdmaDuAdjType =3D 6;
+					} else if (pBtdm8723->curPsTdma =3D=3D 6) {
+						btdm_2AntPsTdma(padapter, true, 7);
+						pBtdm8723->psTdmaDuAdjType =3D 7;
+					} else if (pBtdm8723->curPsTdma =3D=3D 7) {
+						btdm_2AntPsTdma(padapter, true, 8);
+						pBtdm8723->psTdmaDuAdjType =3D 8;
+					} else if (pBtdm8723->curPsTdma =3D=3D 13) {
+						btdm_2AntPsTdma(padapter, true, 14);
+						pBtdm8723->psTdmaDuAdjType =3D 14;
+					} else if (pBtdm8723->curPsTdma =3D=3D 14) {
+						btdm_2AntPsTdma(padapter, true, 15);
+						pBtdm8723->psTdmaDuAdjType =3D 15;
+					} else if (pBtdm8723->curPsTdma =3D=3D 15) {
+						btdm_2AntPsTdma(padapter, true, 16);
+						pBtdm8723->psTdmaDuAdjType =3D 16;
+					}
+				} else if (result =3D=3D 1) {
+					if (pBtdm8723->curPsTdma =3D=3D 8) {
+						btdm_2AntPsTdma(padapter, true, 7);
+						pBtdm8723->psTdmaDuAdjType =3D 7;
+					} else if (pBtdm8723->curPsTdma =3D=3D 7) {
+						btdm_2AntPsTdma(padapter, true, 6);
+						pBtdm8723->psTdmaDuAdjType =3D 6;
+					} else if (pBtdm8723->curPsTdma =3D=3D 6) {
+						btdm_2AntPsTdma(padapter, true, 5);
+						pBtdm8723->psTdmaDuAdjType =3D 5;
+					} else if (pBtdm8723->curPsTdma =3D=3D 16) {
+						btdm_2AntPsTdma(padapter, true, 15);
+						pBtdm8723->psTdmaDuAdjType =3D 15;
+					} else if (pBtdm8723->curPsTdma =3D=3D 15) {
+						btdm_2AntPsTdma(padapter, true, 14);
+						pBtdm8723->psTdmaDuAdjType =3D 14;
+					} else if (pBtdm8723->curPsTdma =3D=3D 14) {
+						btdm_2AntPsTdma(padapter, true, 13);
+						pBtdm8723->psTdmaDuAdjType =3D 13;
+					}
+				}
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], TxPause =3D 0\n"));
+				if (pBtdm8723->curPsTdma =3D=3D 5) {
+					btdm_2AntPsTdma(padapter, true, 1);
+					pBtdm8723->psTdmaDuAdjType =3D 1;
+				} else if (pBtdm8723->curPsTdma =3D=3D 6) {
+					btdm_2AntPsTdma(padapter, true, 2);
+					pBtdm8723->psTdmaDuAdjType =3D 2;
+				} else if (pBtdm8723->curPsTdma =3D=3D 7) {
+					btdm_2AntPsTdma(padapter, true, 3);
+					pBtdm8723->psTdmaDuAdjType =3D 3;
+				} else if (pBtdm8723->curPsTdma =3D=3D 8) {
+					btdm_2AntPsTdma(padapter, true, 4);
+					pBtdm8723->psTdmaDuAdjType =3D 4;
+				}
+				if (pBtdm8723->curPsTdma =3D=3D 13) {
+					btdm_2AntPsTdma(padapter, true, 9);
+					pBtdm8723->psTdmaDuAdjType =3D 9;
+				} else if (pBtdm8723->curPsTdma =3D=3D 14) {
+					btdm_2AntPsTdma(padapter, true, 10);
+					pBtdm8723->psTdmaDuAdjType =3D 10;
+				} else if (pBtdm8723->curPsTdma =3D=3D 15) {
+					btdm_2AntPsTdma(padapter, true, 11);
+					pBtdm8723->psTdmaDuAdjType =3D 11;
+				} else if (pBtdm8723->curPsTdma =3D=3D 16) {
+					btdm_2AntPsTdma(padapter, true, 12);
+					pBtdm8723->psTdmaDuAdjType =3D 12;
+				}
+
+				if (result =3D=3D -1) {
+					if (pBtdm8723->curPsTdma =3D=3D 1) {
+						btdm_2AntPsTdma(padapter, true, 2);
+						pBtdm8723->psTdmaDuAdjType =3D 2;
+					} else if (pBtdm8723->curPsTdma =3D=3D 2) {
+						btdm_2AntPsTdma(padapter, true, 3);
+						pBtdm8723->psTdmaDuAdjType =3D 3;
+					} else if (pBtdm8723->curPsTdma =3D=3D 3) {
+						btdm_2AntPsTdma(padapter, true, 4);
+						pBtdm8723->psTdmaDuAdjType =3D 4;
+					} else if (pBtdm8723->curPsTdma =3D=3D 9) {
+						btdm_2AntPsTdma(padapter, true, 10);
+						pBtdm8723->psTdmaDuAdjType =3D 10;
+					} else if (pBtdm8723->curPsTdma =3D=3D 10) {
+						btdm_2AntPsTdma(padapter, true, 11);
+						pBtdm8723->psTdmaDuAdjType =3D 11;
+					} else if (pBtdm8723->curPsTdma =3D=3D 11) {
+						btdm_2AntPsTdma(padapter, true, 12);
+						pBtdm8723->psTdmaDuAdjType =3D 12;
+					}
+				} else if (result =3D=3D 1) {
+					if (pBtdm8723->curPsTdma =3D=3D 4) {
+						btdm_2AntPsTdma(padapter, true, 3);
+						pBtdm8723->psTdmaDuAdjType =3D 3;
+					} else if (pBtdm8723->curPsTdma =3D=3D 3) {
+						btdm_2AntPsTdma(padapter, true, 2);
+						pBtdm8723->psTdmaDuAdjType =3D 2;
+					} else if (pBtdm8723->curPsTdma =3D=3D 2) {
+						btdm_2AntPsTdma(padapter, true, 1);
+						pBtdm8723->psTdmaDuAdjType =3D 1;
+					} else if (pBtdm8723->curPsTdma =3D=3D 12) {
+						btdm_2AntPsTdma(padapter, true, 11);
+						pBtdm8723->psTdmaDuAdjType =3D 11;
+					} else if (pBtdm8723->curPsTdma =3D=3D 11) {
+						btdm_2AntPsTdma(padapter, true, 10);
+						pBtdm8723->psTdmaDuAdjType =3D 10;
+					} else if (pBtdm8723->curPsTdma =3D=3D 10) {
+						btdm_2AntPsTdma(padapter, true, 9);
+						pBtdm8723->psTdmaDuAdjType =3D 9;
+					}
+				}
+			}
+		} else if (maxInterval =3D=3D 2) {
+			if (bTxPause) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], TxPause =3D 1\n"));
+				if (pBtdm8723->curPsTdma =3D=3D 1) {
+					btdm_2AntPsTdma(padapter, true, 6);
+					pBtdm8723->psTdmaDuAdjType =3D 6;
+				} else if (pBtdm8723->curPsTdma =3D=3D 2) {
+					btdm_2AntPsTdma(padapter, true, 6);
+					pBtdm8723->psTdmaDuAdjType =3D 6;
+				} else if (pBtdm8723->curPsTdma =3D=3D 3) {
+					btdm_2AntPsTdma(padapter, true, 7);
+					pBtdm8723->psTdmaDuAdjType =3D 7;
+				} else if (pBtdm8723->curPsTdma =3D=3D 4) {
+					btdm_2AntPsTdma(padapter, true, 8);
+					pBtdm8723->psTdmaDuAdjType =3D 8;
+				}
+				if (pBtdm8723->curPsTdma =3D=3D 9) {
+					btdm_2AntPsTdma(padapter, true, 14);
+					pBtdm8723->psTdmaDuAdjType =3D 14;
+				} else if (pBtdm8723->curPsTdma =3D=3D 10) {
+					btdm_2AntPsTdma(padapter, true, 14);
+					pBtdm8723->psTdmaDuAdjType =3D 14;
+				} else if (pBtdm8723->curPsTdma =3D=3D 11) {
+					btdm_2AntPsTdma(padapter, true, 15);
+					pBtdm8723->psTdmaDuAdjType =3D 15;
+				} else if (pBtdm8723->curPsTdma =3D=3D 12) {
+					btdm_2AntPsTdma(padapter, true, 16);
+					pBtdm8723->psTdmaDuAdjType =3D 16;
+				}
+				if (result =3D=3D -1) {
+					if (pBtdm8723->curPsTdma =3D=3D 5) {
+						btdm_2AntPsTdma(padapter, true, 6);
+						pBtdm8723->psTdmaDuAdjType =3D 6;
+					} else if (pBtdm8723->curPsTdma =3D=3D 6) {
+						btdm_2AntPsTdma(padapter, true, 7);
+						pBtdm8723->psTdmaDuAdjType =3D 7;
+					} else if (pBtdm8723->curPsTdma =3D=3D 7) {
+						btdm_2AntPsTdma(padapter, true, 8);
+						pBtdm8723->psTdmaDuAdjType =3D 8;
+					} else if (pBtdm8723->curPsTdma =3D=3D 13) {
+						btdm_2AntPsTdma(padapter, true, 14);
+						pBtdm8723->psTdmaDuAdjType =3D 14;
+					} else if (pBtdm8723->curPsTdma =3D=3D 14) {
+						btdm_2AntPsTdma(padapter, true, 15);
+						pBtdm8723->psTdmaDuAdjType =3D 15;
+					} else if (pBtdm8723->curPsTdma =3D=3D 15) {
+						btdm_2AntPsTdma(padapter, true, 16);
+						pBtdm8723->psTdmaDuAdjType =3D 16;
+					}
+				} else if (result =3D=3D 1) {
+					if (pBtdm8723->curPsTdma =3D=3D 8) {
+						btdm_2AntPsTdma(padapter, true, 7);
+						pBtdm8723->psTdmaDuAdjType =3D 7;
+					} else if (pBtdm8723->curPsTdma =3D=3D 7) {
+						btdm_2AntPsTdma(padapter, true, 6);
+						pBtdm8723->psTdmaDuAdjType =3D 6;
+					} else if (pBtdm8723->curPsTdma =3D=3D 6) {
+						btdm_2AntPsTdma(padapter, true, 6);
+						pBtdm8723->psTdmaDuAdjType =3D 6;
+					} else if (pBtdm8723->curPsTdma =3D=3D 16) {
+						btdm_2AntPsTdma(padapter, true, 15);
+						pBtdm8723->psTdmaDuAdjType =3D 15;
+					} else if (pBtdm8723->curPsTdma =3D=3D 15) {
+						btdm_2AntPsTdma(padapter, true, 14);
+						pBtdm8723->psTdmaDuAdjType =3D 14;
+					} else if (pBtdm8723->curPsTdma =3D=3D 14) {
+						btdm_2AntPsTdma(padapter, true, 14);
+						pBtdm8723->psTdmaDuAdjType =3D 14;
+					}
+				}
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], TxPause =3D 0\n"));
+				if (pBtdm8723->curPsTdma =3D=3D 5) {
+					btdm_2AntPsTdma(padapter, true, 2);
+					pBtdm8723->psTdmaDuAdjType =3D 2;
+				} else if (pBtdm8723->curPsTdma =3D=3D 6) {
+					btdm_2AntPsTdma(padapter, true, 2);
+					pBtdm8723->psTdmaDuAdjType =3D 2;
+				} else if (pBtdm8723->curPsTdma =3D=3D 7) {
+					btdm_2AntPsTdma(padapter, true, 3);
+					pBtdm8723->psTdmaDuAdjType =3D 3;
+				} else if (pBtdm8723->curPsTdma =3D=3D 8) {
+					btdm_2AntPsTdma(padapter, true, 4);
+					pBtdm8723->psTdmaDuAdjType =3D 4;
+				}
+				if (pBtdm8723->curPsTdma =3D=3D 13) {
+					btdm_2AntPsTdma(padapter, true, 10);
+					pBtdm8723->psTdmaDuAdjType =3D 10;
+				} else if (pBtdm8723->curPsTdma =3D=3D 14) {
+					btdm_2AntPsTdma(padapter, true, 10);
+					pBtdm8723->psTdmaDuAdjType =3D 10;
+				} else if (pBtdm8723->curPsTdma =3D=3D 15) {
+					btdm_2AntPsTdma(padapter, true, 11);
+					pBtdm8723->psTdmaDuAdjType =3D 11;
+				} else if (pBtdm8723->curPsTdma =3D=3D 16) {
+					btdm_2AntPsTdma(padapter, true, 12);
+					pBtdm8723->psTdmaDuAdjType =3D 12;
+				}
+				if (result =3D=3D -1) {
+					if (pBtdm8723->curPsTdma =3D=3D 1) {
+						btdm_2AntPsTdma(padapter, true, 2);
+						pBtdm8723->psTdmaDuAdjType =3D 2;
+					} else if (pBtdm8723->curPsTdma =3D=3D 2) {
+						btdm_2AntPsTdma(padapter, true, 3);
+						pBtdm8723->psTdmaDuAdjType =3D 3;
+					} else if (pBtdm8723->curPsTdma =3D=3D 3) {
+						btdm_2AntPsTdma(padapter, true, 4);
+						pBtdm8723->psTdmaDuAdjType =3D 4;
+					} else if (pBtdm8723->curPsTdma =3D=3D 9) {
+						btdm_2AntPsTdma(padapter, true, 10);
+						pBtdm8723->psTdmaDuAdjType =3D 10;
+					} else if (pBtdm8723->curPsTdma =3D=3D 10) {
+						btdm_2AntPsTdma(padapter, true, 11);
+						pBtdm8723->psTdmaDuAdjType =3D 11;
+					} else if (pBtdm8723->curPsTdma =3D=3D 11) {
+						btdm_2AntPsTdma(padapter, true, 12);
+						pBtdm8723->psTdmaDuAdjType =3D 12;
+					}
+				} else if (result =3D=3D 1) {
+					if (pBtdm8723->curPsTdma =3D=3D 4) {
+						btdm_2AntPsTdma(padapter, true, 3);
+						pBtdm8723->psTdmaDuAdjType =3D 3;
+					} else if (pBtdm8723->curPsTdma =3D=3D 3) {
+						btdm_2AntPsTdma(padapter, true, 2);
+						pBtdm8723->psTdmaDuAdjType =3D 2;
+					} else if (pBtdm8723->curPsTdma =3D=3D 2) {
+						btdm_2AntPsTdma(padapter, true, 2);
+						pBtdm8723->psTdmaDuAdjType =3D 2;
+					} else if (pBtdm8723->curPsTdma =3D=3D 12) {
+						btdm_2AntPsTdma(padapter, true, 11);
+						pBtdm8723->psTdmaDuAdjType =3D 11;
+					} else if (pBtdm8723->curPsTdma =3D=3D 11) {
+						btdm_2AntPsTdma(padapter, true, 10);
+						pBtdm8723->psTdmaDuAdjType =3D 10;
+					} else if (pBtdm8723->curPsTdma =3D=3D 10) {
+						btdm_2AntPsTdma(padapter, true, 10);
+						pBtdm8723->psTdmaDuAdjType =3D 10;
+					}
+				}
+			}
+		} else if (maxInterval =3D=3D 3) {
+			if (bTxPause) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], TxPause =3D 1\n"));
+				if (pBtdm8723->curPsTdma =3D=3D 1) {
+					btdm_2AntPsTdma(padapter, true, 7);
+					pBtdm8723->psTdmaDuAdjType =3D 7;
+				} else if (pBtdm8723->curPsTdma =3D=3D 2) {
+					btdm_2AntPsTdma(padapter, true, 7);
+					pBtdm8723->psTdmaDuAdjType =3D 7;
+				} else if (pBtdm8723->curPsTdma =3D=3D 3) {
+					btdm_2AntPsTdma(padapter, true, 7);
+					pBtdm8723->psTdmaDuAdjType =3D 7;
+				} else if (pBtdm8723->curPsTdma =3D=3D 4) {
+					btdm_2AntPsTdma(padapter, true, 8);
+					pBtdm8723->psTdmaDuAdjType =3D 8;
+				}
+				if (pBtdm8723->curPsTdma =3D=3D 9) {
+					btdm_2AntPsTdma(padapter, true, 15);
+					pBtdm8723->psTdmaDuAdjType =3D 15;
+				} else if (pBtdm8723->curPsTdma =3D=3D 10) {
+					btdm_2AntPsTdma(padapter, true, 15);
+					pBtdm8723->psTdmaDuAdjType =3D 15;
+				} else if (pBtdm8723->curPsTdma =3D=3D 11) {
+					btdm_2AntPsTdma(padapter, true, 15);
+					pBtdm8723->psTdmaDuAdjType =3D 15;
+				} else if (pBtdm8723->curPsTdma =3D=3D 12) {
+					btdm_2AntPsTdma(padapter, true, 16);
+					pBtdm8723->psTdmaDuAdjType =3D 16;
+				}
+				if (result =3D=3D -1) {
+					if (pBtdm8723->curPsTdma =3D=3D 5) {
+						btdm_2AntPsTdma(padapter, true, 7);
+						pBtdm8723->psTdmaDuAdjType =3D 7;
+					} else if (pBtdm8723->curPsTdma =3D=3D 6) {
+						btdm_2AntPsTdma(padapter, true, 7);
+						pBtdm8723->psTdmaDuAdjType =3D 7;
+					} else if (pBtdm8723->curPsTdma =3D=3D 7) {
+						btdm_2AntPsTdma(padapter, true, 8);
+						pBtdm8723->psTdmaDuAdjType =3D 8;
+					} else if (pBtdm8723->curPsTdma =3D=3D 13) {
+						btdm_2AntPsTdma(padapter, true, 15);
+						pBtdm8723->psTdmaDuAdjType =3D 15;
+					} else if (pBtdm8723->curPsTdma =3D=3D 14) {
+						btdm_2AntPsTdma(padapter, true, 15);
+						pBtdm8723->psTdmaDuAdjType =3D 15;
+					} else if (pBtdm8723->curPsTdma =3D=3D 15) {
+						btdm_2AntPsTdma(padapter, true, 16);
+						pBtdm8723->psTdmaDuAdjType =3D 16;
+					}
+				} else if (result =3D=3D 1) {
+					if (pBtdm8723->curPsTdma =3D=3D 8) {
+						btdm_2AntPsTdma(padapter, true, 7);
+						pBtdm8723->psTdmaDuAdjType =3D 7;
+					} else if (pBtdm8723->curPsTdma =3D=3D 7) {
+						btdm_2AntPsTdma(padapter, true, 7);
+						pBtdm8723->psTdmaDuAdjType =3D 7;
+					} else if (pBtdm8723->curPsTdma =3D=3D 6) {
+						btdm_2AntPsTdma(padapter, true, 7);
+						pBtdm8723->psTdmaDuAdjType =3D 7;
+					} else if (pBtdm8723->curPsTdma =3D=3D 16) {
+						btdm_2AntPsTdma(padapter, true, 15);
+						pBtdm8723->psTdmaDuAdjType =3D 15;
+					} else if (pBtdm8723->curPsTdma =3D=3D 15) {
+						btdm_2AntPsTdma(padapter, true, 15);
+						pBtdm8723->psTdmaDuAdjType =3D 15;
+					} else if (pBtdm8723->curPsTdma =3D=3D 14) {
+						btdm_2AntPsTdma(padapter, true, 15);
+						pBtdm8723->psTdmaDuAdjType =3D 15;
+					}
+				}
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], TxPause =3D 0\n"));
+				if (pBtdm8723->curPsTdma =3D=3D 5) {
+					btdm_2AntPsTdma(padapter, true, 3);
+					pBtdm8723->psTdmaDuAdjType =3D 3;
+				} else if (pBtdm8723->curPsTdma =3D=3D 6) {
+					btdm_2AntPsTdma(padapter, true, 3);
+					pBtdm8723->psTdmaDuAdjType =3D 3;
+				} else if (pBtdm8723->curPsTdma =3D=3D 7) {
+					btdm_2AntPsTdma(padapter, true, 3);
+					pBtdm8723->psTdmaDuAdjType =3D 3;
+				} else if (pBtdm8723->curPsTdma =3D=3D 8) {
+					btdm_2AntPsTdma(padapter, true, 4);
+					pBtdm8723->psTdmaDuAdjType =3D 4;
+				}
+				if (pBtdm8723->curPsTdma =3D=3D 13) {
+					btdm_2AntPsTdma(padapter, true, 11);
+					pBtdm8723->psTdmaDuAdjType =3D 11;
+				} else if (pBtdm8723->curPsTdma =3D=3D 14) {
+					btdm_2AntPsTdma(padapter, true, 11);
+					pBtdm8723->psTdmaDuAdjType =3D 11;
+				} else if (pBtdm8723->curPsTdma =3D=3D 15) {
+					btdm_2AntPsTdma(padapter, true, 11);
+					pBtdm8723->psTdmaDuAdjType =3D 11;
+				} else if (pBtdm8723->curPsTdma =3D=3D 16) {
+					btdm_2AntPsTdma(padapter, true, 12);
+					pBtdm8723->psTdmaDuAdjType =3D 12;
+				}
+				if (result =3D=3D -1) {
+					if (pBtdm8723->curPsTdma =3D=3D 1) {
+						btdm_2AntPsTdma(padapter, true, 3);
+						pBtdm8723->psTdmaDuAdjType =3D 3;
+					} else if (pBtdm8723->curPsTdma =3D=3D 2) {
+						btdm_2AntPsTdma(padapter, true, 3);
+						pBtdm8723->psTdmaDuAdjType =3D 3;
+					} else if (pBtdm8723->curPsTdma =3D=3D 3) {
+						btdm_2AntPsTdma(padapter, true, 4);
+						pBtdm8723->psTdmaDuAdjType =3D 4;
+					} else if (pBtdm8723->curPsTdma =3D=3D 9) {
+						btdm_2AntPsTdma(padapter, true, 11);
+						pBtdm8723->psTdmaDuAdjType =3D 11;
+					} else if (pBtdm8723->curPsTdma =3D=3D 10) {
+						btdm_2AntPsTdma(padapter, true, 11);
+						pBtdm8723->psTdmaDuAdjType =3D 11;
+					} else if (pBtdm8723->curPsTdma =3D=3D 11) {
+						btdm_2AntPsTdma(padapter, true, 12);
+						pBtdm8723->psTdmaDuAdjType =3D 12;
+					}
+				} else if (result =3D=3D 1) {
+					if (pBtdm8723->curPsTdma =3D=3D 4) {
+						btdm_2AntPsTdma(padapter, true, 3);
+						pBtdm8723->psTdmaDuAdjType =3D 3;
+					} else if (pBtdm8723->curPsTdma =3D=3D 3) {
+						btdm_2AntPsTdma(padapter, true, 3);
+						pBtdm8723->psTdmaDuAdjType =3D 3;
+					} else if (pBtdm8723->curPsTdma =3D=3D 2) {
+						btdm_2AntPsTdma(padapter, true, 3);
+						pBtdm8723->psTdmaDuAdjType =3D 3;
+					} else if (pBtdm8723->curPsTdma =3D=3D 12) {
+						btdm_2AntPsTdma(padapter, true, 11);
+						pBtdm8723->psTdmaDuAdjType =3D 11;
+					} else if (pBtdm8723->curPsTdma =3D=3D 11) {
+						btdm_2AntPsTdma(padapter, true, 11);
+						pBtdm8723->psTdmaDuAdjType =3D 11;
+					} else if (pBtdm8723->curPsTdma =3D=3D 10) {
+						btdm_2AntPsTdma(padapter, true, 11);
+						pBtdm8723->psTdmaDuAdjType =3D 11;
+					}
+				}
+			}
+		}
+	}
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], PsTdma type : recordPsTdma =3D%d\n=
", pBtdm8723->psTdmaDuAdjType));
+	/*  if current PsTdma not match with the recorded one (when scan, dhc=
p...), */
+	/*  then we have to adjust it back to the previous record one. */
+	if (pBtdm8723->curPsTdma !=3D pBtdm8723->psTdmaDuAdjType) {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], PsTdma type dismatch!!!, curPsTdm=
a =3D%d, recordPsTdma =3D%d\n",
+			pBtdm8723->curPsTdma, pBtdm8723->psTdmaDuAdjType));
+
+		if (!check_fwstate(&padapter->mlmepriv, _FW_UNDER_SURVEY|_FW_UNDER_L=
INKING))
+			btdm_2AntPsTdma(padapter, true, pBtdm8723->psTdmaDuAdjType);
+		else
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], roaming/link/scan is under progr=
ess, will adjust next time!!!\n"));
+	}
+}
+
+/*  default Action */
+/*  SCO only or SCO+PAN(HS) */
+static void btdm_2Ant8723ASCOAction(struct rtw_adapter *padapter)
+{
+	u8 btRssiState, btRssiState1;
+
+	if (btdm_NeedToDecBtPwr(padapter))
+		btdm_2AntDecBtPwr(padapter, true);
+	else
+		btdm_2AntDecBtPwr(padapter, false);
+
+	if (BTDM_IsHT40(padapter)) {
+		RTPRINT(FBT, BT_TRACE, ("HT40\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 37, 0);
+		/*  fw mechanism */
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 high \n"));
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+			btdm_2AntPsTdma(padapter, true, 11);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 low \n"));
+			btdm_2AntPsTdma(padapter, true, 15);
+		}
+
+		/*  sw mechanism */
+		btdm_2AntAgcTable(padapter, false);
+		btdm_2AntAdcBackOff(padapter, true);
+		btdm_2AntDacSwing(padapter, false, 0xc0);
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("HT20 or Legacy\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 37, 0);
+		btRssiState1 =3D BTDM_CheckCoexRSSIState1(padapter, 2, 27, 0);
+
+		/*  fw mechanism */
+		if ((btRssiState1 =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState1 =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 high \n"));
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+			btdm_2AntPsTdma(padapter, true, 11);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 low \n"));
+			btdm_2AntPsTdma(padapter, true, 15);
+		}
+
+		/*  sw mechanism */
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi high \n"));
+			btdm_2AntAgcTable(padapter, true);
+			btdm_2AntAdcBackOff(padapter, true);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi low \n"));
+			btdm_2AntAgcTable(padapter, false);
+			btdm_2AntAdcBackOff(padapter, false);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		}
+	}
+}
+
+static void btdm_2Ant8723AHIDAction(struct rtw_adapter *padapter)
+{
+	u8 btRssiState, btRssiState1;
+
+	if (btdm_NeedToDecBtPwr(padapter))
+		btdm_2AntDecBtPwr(padapter, true);
+	else
+		btdm_2AntDecBtPwr(padapter, false);
+
+	if (BTDM_IsHT40(padapter)) {
+		RTPRINT(FBT, BT_TRACE, ("HT40\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 37, 0);
+			/*  fw mechanism */
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 high \n"));
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+			btdm_2AntPsTdma(padapter, true, 9);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 low \n"));
+			btdm_2AntPsTdma(padapter, true, 13);
+		}
+
+		/*  sw mechanism */
+		btdm_2AntAgcTable(padapter, false);
+		btdm_2AntAdcBackOff(padapter, false);
+		btdm_2AntDacSwing(padapter, false, 0xc0);
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("HT20 or Legacy\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 37, 0);
+		btRssiState1 =3D BTDM_CheckCoexRSSIState1(padapter, 2, 27, 0);
+
+		/*  fw mechanism */
+		if ((btRssiState1 =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState1 =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 high \n"));
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+			btdm_2AntPsTdma(padapter, true, 9);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 low \n"));
+			btdm_2AntPsTdma(padapter, true, 13);
+		}
+
+		/*  sw mechanism */
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi high \n"));
+			btdm_2AntAgcTable(padapter, true);
+			btdm_2AntAdcBackOff(padapter, true);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi low \n"));
+			btdm_2AntAgcTable(padapter, false);
+			btdm_2AntAdcBackOff(padapter, false);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		}
+	}
+}
+
+/* A2DP only / PAN(EDR) only/ A2DP+PAN(HS) */
+static void btdm_2Ant8723AA2DPAction(struct rtw_adapter *padapter)
+{
+	u8 btRssiState, btRssiState1;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u8 btInfoExt =3D pHalData->bt_coexist.halCoex8723.btInfoExt;
+
+	if (btdm_NeedToDecBtPwr(padapter))
+		btdm_2AntDecBtPwr(padapter, true);
+	else
+		btdm_2AntDecBtPwr(padapter, false);
+
+	if (BTDM_IsHT40(padapter)) {
+		RTPRINT(FBT, BT_TRACE, ("HT40\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 37, 0);
+
+		/*  fw mechanism */
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi high \n"));
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+
+			if (btInfoExt&BIT(0)) {	/* a2dp rate, 1:basic /0:edr */
+				RTPRINT(FBT, BT_TRACE, ("a2dp basic rate \n"));
+				btdm_2AntTdmaDurationAdjust(padapter, false, false, 3);
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("a2dp edr rate \n"));
+				btdm_2AntTdmaDurationAdjust(padapter, false, false, 1);
+			}
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi low \n"));
+			if (btInfoExt&BIT(0)) {	/* a2dp rate, 1:basic /0:edr */
+				RTPRINT(FBT, BT_TRACE, ("a2dp basic rate \n"));
+				btdm_2AntTdmaDurationAdjust(padapter, false, true, 3);
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("a2dp edr rate \n"));
+			btdm_2AntTdmaDurationAdjust(padapter, false, true, 1);
+			}
+		}
+
+		/*  sw mechanism */
+		btdm_2AntAgcTable(padapter, false);
+		btdm_2AntAdcBackOff(padapter, true);
+		btdm_2AntDacSwing(padapter, false, 0xc0);
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("HT20 or Legacy\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 37, 0);
+		btRssiState1 =3D BTDM_CheckCoexRSSIState1(padapter, 2, 27, 0);
+
+		/*  fw mechanism */
+		if ((btRssiState1 =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState1 =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 high \n"));
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+			if (btInfoExt&BIT(0)) {	/* a2dp rate, 1:basic /0:edr */
+				RTPRINT(FBT, BT_TRACE, ("a2dp basic rate \n"));
+				btdm_2AntTdmaDurationAdjust(padapter, false, false, 3);
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("a2dp edr rate \n"));
+				btdm_2AntTdmaDurationAdjust(padapter, false, false, 1);
+			}
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 low \n"));
+			if (btInfoExt&BIT(0)) {	/* a2dp rate, 1:basic /0:edr */
+				RTPRINT(FBT, BT_TRACE, ("a2dp basic rate \n"));
+				btdm_2AntTdmaDurationAdjust(padapter, false, true, 3);
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("a2dp edr rate \n"));
+				btdm_2AntTdmaDurationAdjust(padapter, false, true, 1);
+			}
+		}
+
+		/*  sw mechanism */
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi high \n"));
+			btdm_2AntAgcTable(padapter, true);
+			btdm_2AntAdcBackOff(padapter, true);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi low \n"));
+			btdm_2AntAgcTable(padapter, false);
+			btdm_2AntAdcBackOff(padapter, false);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		}
+	}
+}
+
+static void btdm_2Ant8723APANEDRAction(struct rtw_adapter *padapter)
+{
+	u8 btRssiState, btRssiState1;
+
+	if (btdm_NeedToDecBtPwr(padapter))
+		btdm_2AntDecBtPwr(padapter, true);
+	else
+		btdm_2AntDecBtPwr(padapter, false);
+
+	if (BTDM_IsHT40(padapter)) {
+		RTPRINT(FBT, BT_TRACE, ("HT40\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 37, 0);
+
+		/*  fw mechanism */
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi high \n"));
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+			btdm_2AntPsTdma(padapter, true, 2);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi low \n"));
+			btdm_2AntPsTdma(padapter, true, 6);
+		}
+
+		/*  sw mechanism */
+		btdm_2AntAgcTable(padapter, false);
+		btdm_2AntAdcBackOff(padapter, true);
+		btdm_2AntDacSwing(padapter, false, 0xc0);
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("HT20 or Legacy\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 37, 0);
+		btRssiState1 =3D BTDM_CheckCoexRSSIState1(padapter, 2, 27, 0);
+
+		/*  fw mechanism */
+		if ((btRssiState1 =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState1 =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 high \n"));
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+			btdm_2AntPsTdma(padapter, true, 2);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 low \n"));
+			btdm_2AntPsTdma(padapter, true, 6);
+		}
+
+		/*  sw mechanism */
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi high \n"));
+			btdm_2AntAgcTable(padapter, true);
+			btdm_2AntAdcBackOff(padapter, true);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi low \n"));
+			btdm_2AntAgcTable(padapter, false);
+			btdm_2AntAdcBackOff(padapter, false);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		}
+	}
+}
+
+/* PAN(HS) only */
+static void btdm_2Ant8723APANHSAction(struct rtw_adapter *padapter)
+{
+	u8 btRssiState;
+
+	if (BTDM_IsHT40(padapter)) {
+		RTPRINT(FBT, BT_TRACE, ("HT40\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 47, 0);
+		/*  fw mechanism */
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi high \n"));
+			btdm_2AntDecBtPwr(padapter, true);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi low \n"));
+			btdm_2AntDecBtPwr(padapter, false);
+		}
+		btdm_2AntPsTdma(padapter, false, 0);
+
+		/*  sw mechanism */
+		btdm_2AntAgcTable(padapter, false);
+		btdm_2AntAdcBackOff(padapter, true);
+		btdm_2AntDacSwing(padapter, false, 0xc0);
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("HT20 or Legacy\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 47, 0);
+
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi high\n"));
+			/*  fw mechanism */
+			btdm_2AntDecBtPwr(padapter, true);
+			btdm_2AntPsTdma(padapter, false, 0);
+
+			/*  sw mechanism */
+			btdm_2AntAgcTable(padapter, true);
+			btdm_2AntAdcBackOff(padapter, true);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi low\n"));
+			/*  fw mechanism */
+			btdm_2AntDecBtPwr(padapter, false);
+			btdm_2AntPsTdma(padapter, false, 0);
+
+			/*  sw mechanism */
+			btdm_2AntAgcTable(padapter, false);
+			btdm_2AntAdcBackOff(padapter, false);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		}
+	}
+}
+
+/* PAN(EDR)+A2DP */
+static void btdm_2Ant8723APANEDRA2DPAction(struct rtw_adapter *padapte=
r)
+{
+	u8 btRssiState, btRssiState1, btInfoExt;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	btInfoExt =3D pHalData->bt_coexist.halCoex8723.btInfoExt;
+
+	if (btdm_NeedToDecBtPwr(padapter))
+		btdm_2AntDecBtPwr(padapter, true);
+	else
+		btdm_2AntDecBtPwr(padapter, false);
+
+	if (BTDM_IsHT40(padapter)) {
+		RTPRINT(FBT, BT_TRACE, ("HT40\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 37, 0);
+
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi high \n"));
+			/*  fw mechanism */
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+
+			if (btInfoExt&BIT(0)) {	/* a2dp rate, 1:basic /0:edr */
+				RTPRINT(FBT, BT_TRACE, ("a2dp basic rate \n"));
+				btdm_2AntPsTdma(padapter, true, 4);
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("a2dp edr rate \n"));
+				btdm_2AntPsTdma(padapter, true, 2);
+			}
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi low \n"));
+			/*  fw mechanism */
+			if (btInfoExt&BIT(0)) {	/* a2dp rate, 1:basic /0:edr */
+				RTPRINT(FBT, BT_TRACE, ("a2dp basic rate \n"));
+				btdm_2AntPsTdma(padapter, true, 8);
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("a2dp edr rate \n"));
+				btdm_2AntPsTdma(padapter, true, 6);
+			}
+		}
+
+		/*  sw mechanism */
+		btdm_2AntAgcTable(padapter, false);
+		btdm_2AntAdcBackOff(padapter, true);
+		btdm_2AntDacSwing(padapter, false, 0xc0);
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("HT20 or Legacy\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 37, 0);
+		btRssiState1 =3D BTDM_CheckCoexRSSIState1(padapter, 2, 27, 0);
+
+		if ((btRssiState1 =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState1 =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 high \n"));
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+			/*  fw mechanism */
+			if (btInfoExt&BIT(0)) {	/* a2dp rate, 1:basic /0:edr */
+				RTPRINT(FBT, BT_TRACE, ("a2dp basic rate \n"));
+				btdm_2AntPsTdma(padapter, true, 4);
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("a2dp edr rate \n"));
+				btdm_2AntPsTdma(padapter, true, 2);
+			}
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 low \n"));
+			/*  fw mechanism */
+			if (btInfoExt&BIT(0)) {	/* a2dp rate, 1:basic /0:edr */
+				RTPRINT(FBT, BT_TRACE, ("a2dp basic rate \n"));
+				btdm_2AntPsTdma(padapter, true, 8);
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("a2dp edr rate \n"));
+				btdm_2AntPsTdma(padapter, true, 6);
+			}
+		}
+
+		/*  sw mechanism */
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi high \n"));
+			btdm_2AntAgcTable(padapter, true);
+			btdm_2AntAdcBackOff(padapter, true);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi low \n"));
+			btdm_2AntAgcTable(padapter, false);
+			btdm_2AntAdcBackOff(padapter, false);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		}
+	}
+}
+
+static void btdm_2Ant8723APANEDRHIDAction(struct rtw_adapter *padapter=
)
+{
+	u8 btRssiState, btRssiState1;
+
+	if (btdm_NeedToDecBtPwr(padapter))
+		btdm_2AntDecBtPwr(padapter, true);
+	else
+		btdm_2AntDecBtPwr(padapter, false);
+
+	if (BTDM_IsHT40(padapter)) {
+		RTPRINT(FBT, BT_TRACE, ("HT40\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 37, 0);
+		/*  fw mechanism */
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi high \n"));
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+			btdm_2AntPsTdma(padapter, true, 10);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi low \n"));
+			btdm_2AntPsTdma(padapter, true, 14);
+		}
+
+		/*  sw mechanism */
+		btdm_2AntAgcTable(padapter, false);
+		btdm_2AntAdcBackOff(padapter, true);
+		btdm_2AntDacSwing(padapter, false, 0xc0);
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("HT20 or Legacy\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 37, 0);
+		btRssiState1 =3D BTDM_CheckCoexRSSIState1(padapter, 2, 27, 0);
+
+		/*  fw mechanism */
+		if ((btRssiState1 =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState1 =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 high \n"));
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+			btdm_2AntPsTdma(padapter, true, 10);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 low \n"));
+			btdm_2AntPsTdma(padapter, true, 14);
+		}
+
+		/*  sw mechanism */
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi high \n"));
+			btdm_2AntAgcTable(padapter, true);
+			btdm_2AntAdcBackOff(padapter, true);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi low \n"));
+			btdm_2AntAgcTable(padapter, false);
+			btdm_2AntAdcBackOff(padapter, false);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		}
+	}
+}
+
+/*  HID+A2DP+PAN(EDR) */
+static void btdm_2Ant8723AHIDA2DPPANEDRAction(struct rtw_adapter *pada=
pter)
+{
+	u8 btRssiState, btRssiState1, btInfoExt;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	btInfoExt =3D pHalData->bt_coexist.halCoex8723.btInfoExt;
+
+	if (btdm_NeedToDecBtPwr(padapter))
+		btdm_2AntDecBtPwr(padapter, true);
+	else
+		btdm_2AntDecBtPwr(padapter, false);
+
+	if (BTDM_IsHT40(padapter)) {
+		RTPRINT(FBT, BT_TRACE, ("HT40\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 37, 0);
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi high \n"));
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+
+			if (btInfoExt&BIT(0)) {	/* a2dp rate, 1:basic /0:edr */
+				RTPRINT(FBT, BT_TRACE, ("a2dp basic rate \n"));
+				btdm_2AntPsTdma(padapter, true, 12);
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("a2dp edr rate \n"));
+				btdm_2AntPsTdma(padapter, true, 10);
+			}
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi low \n"));
+			if (btInfoExt&BIT(0)) {	/* a2dp rate, 1:basic /0:edr */
+				RTPRINT(FBT, BT_TRACE, ("a2dp basic rate \n"));
+				btdm_2AntPsTdma(padapter, true, 16);
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("a2dp edr rate \n"));
+				btdm_2AntPsTdma(padapter, true, 14);
+			}
+		}
+
+		/*  sw mechanism */
+		btdm_2AntAgcTable(padapter, false);
+		btdm_2AntAdcBackOff(padapter, true);
+		btdm_2AntDacSwing(padapter, false, 0xc0);
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("HT20 or Legacy\n"));
+		btRssiState1 =3D BTDM_CheckCoexRSSIState1(padapter, 2, 37, 0);
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 27, 0);
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi high \n"));
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+
+			if (btInfoExt&BIT(0)) {	/* a2dp rate, 1:basic /0:edr */
+				RTPRINT(FBT, BT_TRACE, ("a2dp basic rate \n"));
+				btdm_2AntPsTdma(padapter, true, 12);
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("a2dp edr rate \n"));
+				btdm_2AntPsTdma(padapter, true, 10);
+			}
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi low \n"));
+			if (btInfoExt&BIT(0)) {	/* a2dp rate, 1:basic /0:edr */
+				RTPRINT(FBT, BT_TRACE, ("a2dp basic rate \n"));
+				btdm_2AntPsTdma(padapter, true, 16);
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("a2dp edr rate \n"));
+				btdm_2AntPsTdma(padapter, true, 14);
+			}
+		}
+
+		/*  sw mechanism */
+		if ((btRssiState1 =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState1 =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 high \n"));
+			btdm_2AntAgcTable(padapter, true);
+			btdm_2AntAdcBackOff(padapter, true);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 high \n"));
+			btdm_2AntAgcTable(padapter, false);
+			btdm_2AntAdcBackOff(padapter, false);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		}
+	}
+}
+
+static void btdm_2Ant8723AHIDA2DPAction(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u8 btRssiState, btRssiState1, btInfoExt;
+
+	btInfoExt =3D pHalData->bt_coexist.halCoex8723.btInfoExt;
+
+	if (btdm_NeedToDecBtPwr(padapter))
+		btdm_2AntDecBtPwr(padapter, true);
+	else
+		btdm_2AntDecBtPwr(padapter, false);
+
+	if (BTDM_IsHT40(padapter)) {
+		RTPRINT(FBT, BT_TRACE, ("HT40\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 37, 0);
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi high \n"));
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+
+			if (btInfoExt&BIT(0)) {	/* a2dp rate, 1:basic /0:edr */
+				RTPRINT(FBT, BT_TRACE, ("a2dp basic rate \n"));
+				btdm_2AntTdmaDurationAdjust(padapter, true, false, 3);
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("a2dp edr rate \n"));
+				btdm_2AntTdmaDurationAdjust(padapter, true, false, 1);
+			}
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi low \n"));
+			if (btInfoExt&BIT(0)) {	/* a2dp rate, 1:basic /0:edr */
+				RTPRINT(FBT, BT_TRACE, ("a2dp basic rate \n"));
+				btdm_2AntTdmaDurationAdjust(padapter, true, true, 3);
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("a2dp edr rate \n"));
+				btdm_2AntTdmaDurationAdjust(padapter, true, true, 1);
+			}
+		}
+		/*  sw mechanism */
+		btdm_2AntAgcTable(padapter, false);
+		btdm_2AntAdcBackOff(padapter, true);
+		btdm_2AntDacSwing(padapter, false, 0xc0);
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("HT20 or Legacy\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 37, 0);
+		btRssiState1 =3D BTDM_CheckCoexRSSIState(padapter, 2, 27, 0);
+
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi high \n"));
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+
+			if (btInfoExt&BIT(0)) {	/* a2dp rate, 1:basic /0:edr */
+				RTPRINT(FBT, BT_TRACE, ("a2dp basic rate \n"));
+				btdm_2AntTdmaDurationAdjust(padapter, true, false, 3);
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("a2dp edr rate \n"));
+				btdm_2AntTdmaDurationAdjust(padapter, true, false, 1);
+			}
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi low \n"));
+			if (btInfoExt&BIT(0)) {	/* a2dp rate, 1:basic /0:edr */
+				RTPRINT(FBT, BT_TRACE, ("a2dp basic rate \n"));
+				btdm_2AntTdmaDurationAdjust(padapter, true, true, 3);
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("a2dp edr rate \n"));
+				btdm_2AntTdmaDurationAdjust(padapter, true, true, 1);
+			}
+		}
+		if ((btRssiState1 =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState1 =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 high \n"));
+			/*  sw mechanism */
+			btdm_2AntAgcTable(padapter, true);
+			btdm_2AntAdcBackOff(padapter, true);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 low \n"));
+			/*  sw mechanism */
+			btdm_2AntAgcTable(padapter, false);
+			btdm_2AntAdcBackOff(padapter, false);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		}
+	}
+}
+
+static void btdm_2Ant8723AA2dp(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u8 btRssiState, btRssiState1, btInfoExt;
+
+	btInfoExt =3D pHalData->bt_coexist.halCoex8723.btInfoExt;
+
+	if (btdm_NeedToDecBtPwr(padapter))
+		btdm_2AntDecBtPwr(padapter, true);
+	else
+		btdm_2AntDecBtPwr(padapter, false);
+	/*  coex table */
+	btdm_2AntCoexTable(padapter, 0x55555555, 0xffff, 0x3);
+	btdm_2AntIgnoreWlanAct(padapter, false);
+
+	if (BTDM_IsHT40(padapter)) {
+		RTPRINT(FBT, BT_TRACE, ("HT40\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 37, 0);
+		/*  fw mechanism */
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 high \n"));
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+			btdm_2AntTdmaDurationAdjust(padapter, false, false, 1);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 low \n"));
+			btdm_2AntTdmaDurationAdjust(padapter, false, true, 1);
+		}
+
+		/*  sw mechanism */
+		btdm_2AntAgcTable(padapter, false);
+		btdm_2AntAdcBackOff(padapter, true);
+		btdm_2AntDacSwing(padapter, false, 0xc0);
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("HT20 or Legacy\n"));
+		btRssiState =3D BTDM_CheckCoexRSSIState(padapter, 2, 47, 0);
+		btRssiState1 =3D BTDM_CheckCoexRSSIState1(padapter, 2, 27, 0);
+
+		/*  fw mechanism */
+		if ((btRssiState1 =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState1 =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 high \n"));
+			PlatformEFIOWrite1Byte(padapter, 0x883, 0x40);
+			btdm_2AntTdmaDurationAdjust(padapter, false, false, 1);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi-1 low \n"));
+			btdm_2AntTdmaDurationAdjust(padapter, false, true, 1);
+		}
+
+		/*  sw mechanism */
+		if ((btRssiState =3D=3D BT_RSSI_STATE_HIGH) ||
+		    (btRssiState =3D=3D BT_RSSI_STATE_STAY_HIGH)) {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi high \n"));
+			btdm_2AntAgcTable(padapter, true);
+			btdm_2AntAdcBackOff(padapter, true);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("Wifi rssi low \n"));
+			btdm_2AntAgcTable(padapter, false);
+			btdm_2AntAdcBackOff(padapter, false);
+			btdm_2AntDacSwing(padapter, false, 0xc0);
+		}
+	}
+}
+
+/*  extern function start with BTDM_ */
+static void BTDM_2AntParaInit(struct rtw_adapter *padapter)
+{
+
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_2ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm2Ant;
+
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], 2Ant Parameter Init!!\n"));
+
+	/*  Enable counter statistics */
+	rtw_write8(padapter, 0x76e, 0x4);
+	rtw_write8(padapter, 0x778, 0x3);
+	rtw_write8(padapter, 0x40, 0x20);
+
+	/*  force to reset coex mechanism */
+	pBtdm8723->preVal0x6c0 =3D 0x0;
+	btdm_2AntCoexTable(padapter, 0x55555555, 0xffff, 0x3);
+
+	pBtdm8723->bPrePsTdmaOn =3D true;
+	btdm_2AntPsTdma(padapter, false, 0);
+
+	pBtdm8723->preFwDacSwingLvl =3D 0x10;
+	btdm_2AntFwDacSwingLvl(padapter, 0x20);
+
+	pBtdm8723->bPreDecBtPwr =3D true;
+	btdm_2AntDecBtPwr(padapter, false);
+
+	pBtdm8723->bPreAgcTableEn =3D true;
+	btdm_2AntAgcTable(padapter, false);
+
+	pBtdm8723->bPreAdcBackOff =3D true;
+	btdm_2AntAdcBackOff(padapter, false);
+
+	pBtdm8723->bPreLowPenaltyRa =3D true;
+	btdm_2AntLowPenaltyRa(padapter, false);
+
+	pBtdm8723->bPreRfRxLpfShrink =3D true;
+	btdm_2AntRfShrink(padapter, false);
+
+	pBtdm8723->bPreDacSwingOn =3D true;
+	btdm_2AntDacSwing(padapter, false, 0xc0);
+
+	pBtdm8723->bPreIgnoreWlanAct =3D true;
+	btdm_2AntIgnoreWlanAct(padapter, false);
+}
+
+static void BTDM_2AntHwCoexAllOff8723A(struct rtw_adapter *padapter)
+{
+	btdm_2AntCoexTable(padapter, 0x55555555, 0xffff, 0x3);
+}
+
+static void BTDM_2AntFwCoexAllOff8723A(struct rtw_adapter *padapter)
+{
+	btdm_2AntIgnoreWlanAct(padapter, false);
+	btdm_2AntPsTdma(padapter, false, 0);
+	btdm_2AntFwDacSwingLvl(padapter, 0x20);
+	btdm_2AntDecBtPwr(padapter, false);
+}
+
+static void BTDM_2AntSwCoexAllOff8723A(struct rtw_adapter *padapter)
+{
+	btdm_2AntAgcTable(padapter, false);
+	btdm_2AntAdcBackOff(padapter, false);
+	btdm_2AntLowPenaltyRa(padapter, false);
+	btdm_2AntRfShrink(padapter, false);
+	btdm_2AntDacSwing(padapter, false, 0xc0);
+}
+
+static void BTDM_2AntFwC2hBtInfo8723A(struct rtw_adapter *padapter)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_2ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm2Ant;
+	u8 btInfo =3D 0;
+	u8 algorithm =3D BT_2ANT_COEX_ALGO_UNDEFINED;
+	u8 bBtLinkExist =3D false, bBtHsModeExist =3D false;
+
+	btInfo =3D pHalData->bt_coexist.halCoex8723.c2hBtInfoOriginal;
+	pBtdm8723->btStatus =3D BT_2ANT_BT_STATUS_IDLE;
+
+	/*  check BIT2 first =3D=3D> check if bt is under inquiry or page sca=
n */
+	if (btInfo & BIT(2)) {
+		if (!pHalData->bt_coexist.halCoex8723.bC2hBtInquiryPage) {
+			pBtMgnt->ExtConfig.bHoldForBtOperation =3D true;
+			pBtMgnt->ExtConfig.bHoldPeriodCnt =3D 1;
+			btdm_2AntBtInquiryPage(padapter);
+		} else {
+			pBtMgnt->ExtConfig.bHoldPeriodCnt++;
+			btdm_HoldForBtInqPage(padapter);
+		}
+		pHalData->bt_coexist.halCoex8723.bC2hBtInquiryPage =3D true;
+
+	} else {
+		pHalData->bt_coexist.halCoex8723.bC2hBtInquiryPage =3D false;
+		pBtMgnt->ExtConfig.bHoldForBtOperation =3D false;
+		pBtMgnt->ExtConfig.bHoldPeriodCnt =3D 0;
+
+	}
+	RTPRINT(FBT, BT_TRACE,
+		("[BTC2H], pHalData->bt_coexist.halCoex8723.bC2hBtInquiryPage =3D%x =
pBtMgnt->ExtConfig.bHoldPeriodCnt =3D%x pBtMgnt->ExtConfig.bHoldForBtOp=
eration =3D%x\n",
+		pHalData->bt_coexist.halCoex8723.bC2hBtInquiryPage,
+		pBtMgnt->ExtConfig.bHoldPeriodCnt,
+		pBtMgnt->ExtConfig.bHoldForBtOperation));
+
+	RTPRINT(FBT, BT_TRACE,
+		("[BTC2H],   btInfo =3D%x   pHalData->bt_coexist.halCoex8723.c2hBtIn=
foOriginal =3D%x\n",
+		btInfo, pHalData->bt_coexist.halCoex8723.c2hBtInfoOriginal));
+	if (btInfo&BT_INFO_ACL) {
+		RTPRINT(FBT, BT_TRACE, ("[BTC2H], BTInfo: bConnect =3D true   btInfo=
 =3D%x\n", btInfo));
+		bBtLinkExist =3D true;
+		if (((btInfo&(BT_INFO_FTP|BT_INFO_A2DP|BT_INFO_HID|BT_INFO_SCO_BUSY)=
) !=3D 0) ||
+		    pHalData->bt_coexist.halCoex8723.btRetryCnt > 0) {
+			pBtdm8723->btStatus =3D BT_2ANT_BT_STATUS_NON_IDLE;
+		} else {
+			pBtdm8723->btStatus =3D BT_2ANT_BT_STATUS_CONNECTED_IDLE;
+		}
+
+		if (btInfo&BT_INFO_SCO || btInfo&BT_INFO_SCO_BUSY) {
+			if (btInfo&BT_INFO_FTP || btInfo&BT_INFO_A2DP || btInfo&BT_INFO_HID=
) {
+				switch (btInfo&0xe0) {
+				case BT_INFO_HID:
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], SCO + HID\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_HID;
+					break;
+				case BT_INFO_A2DP:
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], Error!!! SCO + A2DP\n"));
+					break;
+				case BT_INFO_FTP:
+					if (bBtHsModeExist) {
+						RTPRINT(FBT, BT_TRACE, ("[BTCoex], SCO + PAN(HS)\n"));
+						algorithm =3D BT_2ANT_COEX_ALGO_SCO;
+					} else {
+						RTPRINT(FBT, BT_TRACE, ("[BTCoex], SCO + PAN(EDR)\n"));
+						algorithm =3D BT_2ANT_COEX_ALGO_PANEDR_HID;
+					}
+					break;
+				case (BT_INFO_HID | BT_INFO_A2DP):
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], HID + A2DP\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_HID_A2DP;
+					break;
+				case (BT_INFO_HID | BT_INFO_FTP):
+					if (bBtHsModeExist) {
+						RTPRINT(FBT, BT_TRACE, ("[BTCoex], HID + PAN(HS)\n"));
+						algorithm =3D BT_2ANT_COEX_ALGO_HID_A2DP;
+					} else {
+						RTPRINT(FBT, BT_TRACE, ("[BTCoex], HID + PAN(EDR)\n"));
+						algorithm =3D BT_2ANT_COEX_ALGO_PANEDR_HID;
+					}
+					break;
+				case (BT_INFO_A2DP | BT_INFO_FTP):
+					if (bBtHsModeExist) {
+						RTPRINT(FBT, BT_TRACE, ("[BTCoex], A2DP + PAN(HS)\n"));
+						algorithm =3D BT_2ANT_COEX_ALGO_A2DP;
+					} else {
+						RTPRINT(FBT, BT_TRACE, ("[BTCoex], A2DP + PAN(EDR)\n"));
+						algorithm =3D BT_2ANT_COEX_ALGO_PANEDR_A2DP;
+					}
+					break;
+				case (BT_INFO_HID | BT_INFO_A2DP | BT_INFO_FTP):
+					if (bBtHsModeExist) {
+						RTPRINT(FBT, BT_TRACE, ("[BTCoex], HID + A2DP + PAN(HS)\n"));
+						algorithm =3D BT_2ANT_COEX_ALGO_HID_A2DP;
+					} else {
+						RTPRINT(FBT, BT_TRACE, ("[BTCoex], HID + A2DP + PAN(EDR)\n"));
+						algorithm =3D BT_2ANT_COEX_ALGO_HID_A2DP_PANEDR;
+					}
+					break;
+				}
+			} else {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], SCO only\n"));
+				algorithm =3D BT_2ANT_COEX_ALGO_SCO;
+			}
+		} else {
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex], non SCO\n"));
+			switch (btInfo&0xe0) {
+			case BT_INFO_HID:
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], HID\n"));
+				algorithm =3D BT_2ANT_COEX_ALGO_HID;
+				break;
+			case BT_INFO_A2DP:
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex],  A2DP\n"));
+				algorithm =3D BT_2ANT_COEX_ALGO_A2DP;
+				break;
+			case BT_INFO_FTP:
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], PAN(EDR)\n"));
+				algorithm =3D BT_2ANT_COEX_ALGO_PANEDR_HID;
+				break;
+			case (BT_INFO_HID | BT_INFO_A2DP):
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], HID + A2DP\n"));
+				algorithm =3D BT_2ANT_COEX_ALGO_HID_A2DP;
+				break;
+			case (BT_INFO_HID|BT_INFO_FTP):
+				if (bBtHsModeExist) {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], HID + PAN(HS)\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_HID_A2DP;
+				} else {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], HID + PAN(EDR)\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_PANEDR_HID;
+				}
+				break;
+			case (BT_INFO_A2DP|BT_INFO_FTP):
+				if (bBtHsModeExist) {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], A2DP + PAN(HS)\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_A2DP;
+				} else {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], A2DP + PAN(EDR)\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_PANEDR_A2DP;
+				}
+				break;
+			case (BT_INFO_HID|BT_INFO_A2DP|BT_INFO_FTP):
+				if (bBtHsModeExist) {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], HID + A2DP + PAN(HS)\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_HID_A2DP;
+				} else {
+					RTPRINT(FBT, BT_TRACE, ("[BTCoex], HID + A2DP + PAN(EDR)\n"));
+					algorithm =3D BT_2ANT_COEX_ALGO_HID_A2DP_PANEDR;
+				}
+				break;
+			}
+
+		}
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("[BTC2H], BTInfo: bConnect =3D false\n"));
+		pBtdm8723->btStatus =3D BT_2ANT_BT_STATUS_IDLE;
+	}
+
+	pBtdm8723->curAlgorithm =3D algorithm;
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], Algorithm =3D %d \n", pBtdm8723->c=
urAlgorithm));
+
+/* From */
+	BTDM_CheckWiFiState(padapter);
+	if (pBtMgnt->ExtConfig.bManualControl) {
+		RTPRINT(FBT, BT_TRACE, ("Action Manual control, won't execute bt coe=
xist mechanism!!\n"));
+		return;
+	}
+}
+
+void BTDM_2AntBtCoexist8723A(struct rtw_adapter *padapter)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	struct bt_dgb *pBtDbg =3D &pBTInfo->BtDbg;
+	u8 btInfoOriginal =3D 0;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct btdm_8723a_2ant *pBtdm8723 =3D &pHalData->bt_coexist.halCoex87=
23.btdm2Ant;
+
+	if (BTDM_BtProfileSupport(padapter)) {
+		if (pBtMgnt->ExtConfig.bHoldForBtOperation) {
+			RTPRINT(FBT, BT_TRACE, ("Action for BT Operation adjust!!\n"));
+			return;
+		}
+		if (pBtMgnt->ExtConfig.bHoldPeriodCnt) {
+			RTPRINT(FBT, BT_TRACE, ("Hold BT inquiry/page scan setting (cnt =3D=
 %d)!!\n",
+				pBtMgnt->ExtConfig.bHoldPeriodCnt));
+			if (pBtMgnt->ExtConfig.bHoldPeriodCnt >=3D 11) {
+				pBtMgnt->ExtConfig.bHoldPeriodCnt =3D 0;
+				/*  next time the coexist parameters should be reset again. */
+			} else {
+				pBtMgnt->ExtConfig.bHoldPeriodCnt++;
+			}
+			return;
+		}
+
+		if (pBtDbg->dbgCtrl)
+			RTPRINT(FBT, BT_TRACE, ("[Dbg control], "));
+
+		pBtdm8723->curAlgorithm =3D btdm_ActionAlgorithm(padapter);
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], Algorithm =3D %d \n", pBtdm8723->=
curAlgorithm));
+
+		if (btdm_Is2Ant8723ACommonAction(padapter)) {
+			RTPRINT(FBT, BT_TRACE, ("Action 2-Ant common.\n"));
+			pBtdm8723->bResetTdmaAdjust =3D true;
+		} else {
+			if (pBtdm8723->curAlgorithm !=3D pBtdm8723->preAlgorithm) {
+				RTPRINT(FBT, BT_TRACE, ("[BTCoex], preAlgorithm =3D%d, curAlgorith=
m =3D%d\n",
+				pBtdm8723->preAlgorithm, pBtdm8723->curAlgorithm));
+				pBtdm8723->bResetTdmaAdjust =3D true;
+			}
+			switch (pBtdm8723->curAlgorithm) {
+			case BT_2ANT_COEX_ALGO_SCO:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D SCO.\n"));
+				btdm_2Ant8723ASCOAction(padapter);
+				break;
+			case BT_2ANT_COEX_ALGO_HID:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D HID.\n"));
+				btdm_2Ant8723AHIDAction(padapter);
+				break;
+			case BT_2ANT_COEX_ALGO_A2DP:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D A2DP.\n"));
+				btdm_2Ant8723AA2DPAction(padapter);
+				break;
+			case BT_2ANT_COEX_ALGO_PANEDR:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D PAN(EDR).\n")=
);
+				btdm_2Ant8723APANEDRAction(padapter);
+				break;
+			case BT_2ANT_COEX_ALGO_PANHS:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D HS mode.\n"))=
;
+				btdm_2Ant8723APANHSAction(padapter);
+				break;
+			case BT_2ANT_COEX_ALGO_PANEDR_A2DP:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D PAN+A2DP.\n")=
);
+				btdm_2Ant8723APANEDRA2DPAction(padapter);
+				break;
+			case BT_2ANT_COEX_ALGO_PANEDR_HID:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D PAN(EDR)+HID.=
\n"));
+				btdm_2Ant8723APANEDRHIDAction(padapter);
+				break;
+			case BT_2ANT_COEX_ALGO_HID_A2DP_PANEDR:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D HID+A2DP+PAN.=
\n"));
+				btdm_2Ant8723AHIDA2DPPANEDRAction(padapter);
+				break;
+			case BT_2ANT_COEX_ALGO_HID_A2DP:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D HID+A2DP.\n")=
);
+				btdm_2Ant8723AHIDA2DPAction(padapter);
+				break;
+			default:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D 0.\n"));
+				btdm_2Ant8723AA2DPAction(padapter);
+				break;
+			}
+			pBtdm8723->preAlgorithm =3D pBtdm8723->curAlgorithm;
+		}
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex] Get bt info by fw!!\n"));
+		/* msg shows c2h rsp for bt_info is received or not. */
+		if (pHalData->bt_coexist.halCoex8723.bC2hBtInfoReqSent)
+			RTPRINT(FBT, BT_TRACE, ("[BTCoex] c2h for btInfo not rcvd yet!!\n")=
);
+
+		btInfoOriginal =3D pHalData->bt_coexist.halCoex8723.c2hBtInfoOrigina=
l;
+
+		if (pBtMgnt->ExtConfig.bHoldForBtOperation) {
+			RTPRINT(FBT, BT_TRACE, ("Action for BT Operation adjust!!\n"));
+			return;
+		}
+		if (pBtMgnt->ExtConfig.bHoldPeriodCnt) {
+			RTPRINT(FBT, BT_TRACE,
+				("Hold BT inquiry/page scan setting (cnt =3D %d)!!\n",
+				pBtMgnt->ExtConfig.bHoldPeriodCnt));
+			if (pBtMgnt->ExtConfig.bHoldPeriodCnt >=3D 11) {
+				pBtMgnt->ExtConfig.bHoldPeriodCnt =3D 0;
+				/*  next time the coexist parameters should be reset again. */
+			} else {
+				 pBtMgnt->ExtConfig.bHoldPeriodCnt++;
+			}
+			return;
+		}
+
+		if (pBtDbg->dbgCtrl)
+			RTPRINT(FBT, BT_TRACE, ("[Dbg control], "));
+		if (btdm_Is2Ant8723ACommonAction(padapter)) {
+			RTPRINT(FBT, BT_TRACE, ("Action 2-Ant common.\n"));
+			pBtdm8723->bResetTdmaAdjust =3D true;
+		} else {
+			if (pBtdm8723->curAlgorithm !=3D pBtdm8723->preAlgorithm) {
+				RTPRINT(FBT, BT_TRACE,
+					("[BTCoex], preAlgorithm =3D%d, curAlgorithm =3D%d\n",
+					pBtdm8723->preAlgorithm,
+					pBtdm8723->curAlgorithm));
+				pBtdm8723->bResetTdmaAdjust =3D true;
+			}
+			switch (pBtdm8723->curAlgorithm) {
+			case BT_2ANT_COEX_ALGO_SCO:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D SCO.\n"));
+				btdm_2Ant8723ASCOAction(padapter);
+				break;
+			case BT_2ANT_COEX_ALGO_HID:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D HID.\n"));
+				btdm_2Ant8723AHIDAction(padapter);
+				break;
+			case BT_2ANT_COEX_ALGO_A2DP:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D A2DP.\n"));
+				btdm_2Ant8723AA2dp(padapter);
+				break;
+			case BT_2ANT_COEX_ALGO_PANEDR:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D PAN(EDR).\n")=
);
+				btdm_2Ant8723APANEDRAction(padapter);
+				break;
+			case BT_2ANT_COEX_ALGO_PANHS:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D HS mode.\n"))=
;
+				btdm_2Ant8723APANHSAction(padapter);
+				break;
+			case BT_2ANT_COEX_ALGO_PANEDR_A2DP:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D PAN+A2DP.\n")=
);
+				btdm_2Ant8723APANEDRA2DPAction(padapter);
+				break;
+			case BT_2ANT_COEX_ALGO_PANEDR_HID:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D PAN(EDR)+HID.=
\n"));
+				btdm_2Ant8723APANEDRHIDAction(padapter);
+				break;
+			case BT_2ANT_COEX_ALGO_HID_A2DP_PANEDR:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D HID+A2DP+PAN.=
\n"));
+				btdm_2Ant8723AHIDA2DPPANEDRAction(padapter);
+				break;
+			case BT_2ANT_COEX_ALGO_HID_A2DP:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D HID+A2DP.\n")=
);
+				btdm_2Ant8723AHIDA2DPAction(padapter);
+				break;
+			default:
+				RTPRINT(FBT, BT_TRACE, ("Action 2-Ant, algorithm =3D 0.\n"));
+				btdm_2Ant8723AA2DPAction(padapter);
+				break;
+			}
+			pBtdm8723->preAlgorithm =3D pBtdm8723->curAlgorithm;
+		}
+	}
+}
+
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver HAL/BTCoexist/HalBtc87=
232Ant.c =3D=3D=3D=3D=3D */
+#endif
+
+#ifdef __HALBTC8723_C__ /*  HAL/BTCoexist/HalBtc8723.c */
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver HAL/BTCoex=
ist/HalBtc8723.c =3D=3D=3D=3D=3D */
+
+static u8 btCoexDbgBuf[BT_TMP_BUF_SIZE];
+
+static const char *const BtProfileString[] =3D {
+	"NONE",
+	"A2DP",
+	"PAN",
+	"HID",
+	"SCO",
+};
+
+static const char *const BtSpecString[] =3D {
+	"1.0b",
+	"1.1",
+	"1.2",
+	"2.0+EDR",
+	"2.1+EDR",
+	"3.0+HS",
+	"4.0",
+};
+
+static const char *const BtLinkRoleString[] =3D {
+	"Master",
+	"Slave",
+};
+
+static u8 btdm_BtWifiAntNum(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct bt_coexist_8723a *pBtCoex =3D &pHalData->bt_coexist.halCoex872=
3;
+
+	if (Ant_x2 =3D=3D pHalData->bt_coexist.BT_Ant_Num) {
+		if (Ant_x2 =3D=3D pBtCoex->TotalAntNum)
+			return Ant_x2;
+		else
+			return Ant_x1;
+	} else {
+		return Ant_x1;
+	}
+	return Ant_x2;
+}
+
+static void btdm_BtHwCountersMonitor(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u32	regHPTxRx, regLPTxRx, u4Tmp;
+	u32	regHPTx =3D 0, regHPRx =3D 0, regLPTx =3D 0, regLPRx =3D 0;
+
+	regHPTxRx =3D REG_HIGH_PRIORITY_TXRX;
+	regLPTxRx =3D REG_LOW_PRIORITY_TXRX;
+
+	u4Tmp =3D rtw_read32(padapter, regHPTxRx);
+	regHPTx =3D u4Tmp & bMaskLWord;
+	regHPRx =3D (u4Tmp & bMaskHWord)>>16;
+
+	u4Tmp =3D rtw_read32(padapter, regLPTxRx);
+	regLPTx =3D u4Tmp & bMaskLWord;
+	regLPRx =3D (u4Tmp & bMaskHWord)>>16;
+
+	pHalData->bt_coexist.halCoex8723.highPriorityTx =3D regHPTx;
+	pHalData->bt_coexist.halCoex8723.highPriorityRx =3D regHPRx;
+	pHalData->bt_coexist.halCoex8723.lowPriorityTx =3D regLPTx;
+	pHalData->bt_coexist.halCoex8723.lowPriorityRx =3D regLPRx;
+
+	RTPRINT(FBT, BT_TRACE, ("High Priority Tx/Rx =3D %d / %d\n", regHPTx,=
 regHPRx));
+	RTPRINT(FBT, BT_TRACE, ("Low Priority Tx/Rx =3D %d / %d\n", regLPTx, =
regLPRx));
+
+	/*  reset counter */
+	rtw_write8(padapter, 0x76e, 0xc);
+}
+
+/*  This function check if 8723 bt is disabled */
+static void btdm_BtEnableDisableCheck8723A(struct rtw_adapter *padapte=
r)
+{
+	u8 btAlife =3D true;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+#ifdef CHECK_BT_EXIST_FROM_REG
+	u8 val8;
+
+	/*  ox68[28]=3D 1 =3D> BT enable; otherwise disable */
+	val8 =3D rtw_read8(padapter, 0x6B);
+	if (!(val8 & BIT(4)))
+		btAlife =3D false;
+
+	if (btAlife)
+		pHalData->bt_coexist.bCurBtDisabled =3D false;
+	else
+		pHalData->bt_coexist.bCurBtDisabled =3D true;
+#else
+	if (pHalData->bt_coexist.halCoex8723.highPriorityTx =3D=3D 0 &&
+	    pHalData->bt_coexist.halCoex8723.highPriorityRx =3D=3D 0 &&
+	    pHalData->bt_coexist.halCoex8723.lowPriorityTx =3D=3D 0 &&
+	    pHalData->bt_coexist.halCoex8723.lowPriorityRx =3D=3D 0)
+		btAlife =3D false;
+	if (pHalData->bt_coexist.halCoex8723.highPriorityTx =3D=3D 0xeaea &&
+	    pHalData->bt_coexist.halCoex8723.highPriorityRx =3D=3D 0xeaea &&
+	    pHalData->bt_coexist.halCoex8723.lowPriorityTx =3D=3D 0xeaea &&
+	    pHalData->bt_coexist.halCoex8723.lowPriorityRx =3D=3D 0xeaea)
+		btAlife =3D false;
+	if (pHalData->bt_coexist.halCoex8723.highPriorityTx =3D=3D 0xffff &&
+	    pHalData->bt_coexist.halCoex8723.highPriorityRx =3D=3D 0xffff &&
+	    pHalData->bt_coexist.halCoex8723.lowPriorityTx =3D=3D 0xffff &&
+	    pHalData->bt_coexist.halCoex8723.lowPriorityRx =3D=3D 0xffff)
+		btAlife =3D false;
+	if (btAlife) {
+		pHalData->bt_coexist.btActiveZeroCnt =3D 0;
+		pHalData->bt_coexist.bCurBtDisabled =3D false;
+		RTPRINT(FBT, BT_TRACE, ("8723A BT is enabled !!\n"));
+	} else {
+		pHalData->bt_coexist.btActiveZeroCnt++;
+		RTPRINT(FBT, BT_TRACE, ("8723A bt all counters =3D 0, %d times!!\n",
+				pHalData->bt_coexist.btActiveZeroCnt));
+		if (pHalData->bt_coexist.btActiveZeroCnt >=3D 2) {
+			pHalData->bt_coexist.bCurBtDisabled =3D true;
+			RTPRINT(FBT, BT_TRACE, ("8723A BT is disabled !!\n"));
+		}
+	}
+#endif
+
+	if (!pHalData->bt_coexist.bCurBtDisabled) {
+		if (BTDM_IsWifiConnectionExist(padapter))
+			BTDM_SetFwChnlInfo(padapter, RT_MEDIA_CONNECT);
+		else
+			BTDM_SetFwChnlInfo(padapter, RT_MEDIA_DISCONNECT);
+	}
+
+	if (pHalData->bt_coexist.bPreBtDisabled !=3D
+	    pHalData->bt_coexist.bCurBtDisabled) {
+		RTPRINT(FBT, BT_TRACE, ("8723A BT is from %s to %s!!\n",
+			(pHalData->bt_coexist.bPreBtDisabled ? "disabled":"enabled"),
+			(pHalData->bt_coexist.bCurBtDisabled ? "disabled":"enabled")));
+		pHalData->bt_coexist.bPreBtDisabled =3D pHalData->bt_coexist.bCurBtD=
isabled;
+	}
+}
+
+static void btdm_BTCoexist8723AHandler(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+
+	if (btdm_BtWifiAntNum(padapter) =3D=3D Ant_x2) {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], 2 Ant mechanism\n"));
+		BTDM_2AntBtCoexist8723A(padapter);
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], 1 Ant mechanism\n"));
+		BTDM_1AntBtCoexist8723A(padapter);
+	}
+
+	if (!BTDM_IsSameCoexistState(padapter)) {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], Coexist State[bitMap] change from=
 0x%"i64fmt"x to 0x%"i64fmt"x\n",
+			pHalData->bt_coexist.PreviousState,
+			pHalData->bt_coexist.CurrentState));
+		pHalData->bt_coexist.PreviousState =3D pHalData->bt_coexist.CurrentS=
tate;
+
+		RTPRINT(FBT, BT_TRACE, ("["));
+		if (pHalData->bt_coexist.CurrentState & BT_COEX_STATE_BT30)
+			RTPRINT(FBT, BT_TRACE, ("BT 3.0, "));
+		if (pHalData->bt_coexist.CurrentState & BT_COEX_STATE_WIFI_HT20)
+			RTPRINT(FBT, BT_TRACE, ("HT20, "));
+		if (pHalData->bt_coexist.CurrentState & BT_COEX_STATE_WIFI_HT40)
+			RTPRINT(FBT, BT_TRACE, ("HT40, "));
+		if (pHalData->bt_coexist.CurrentState & BT_COEX_STATE_WIFI_LEGACY)
+			RTPRINT(FBT, BT_TRACE, ("Legacy, "));
+		if (pHalData->bt_coexist.CurrentState & BT_COEX_STATE_WIFI_RSSI_LOW)
+			RTPRINT(FBT, BT_TRACE, ("Rssi_Low, "));
+		if (pHalData->bt_coexist.CurrentState & BT_COEX_STATE_WIFI_RSSI_MEDI=
UM)
+			RTPRINT(FBT, BT_TRACE, ("Rssi_Mid, "));
+		if (pHalData->bt_coexist.CurrentState & BT_COEX_STATE_WIFI_RSSI_HIGH=
)
+			RTPRINT(FBT, BT_TRACE, ("Rssi_High, "));
+		if (pHalData->bt_coexist.CurrentState & BT_COEX_STATE_WIFI_IDLE)
+			RTPRINT(FBT, BT_TRACE, ("Wifi_Idle, "));
+		if (pHalData->bt_coexist.CurrentState & BT_COEX_STATE_WIFI_UPLINK)
+			RTPRINT(FBT, BT_TRACE, ("Wifi_Uplink, "));
+		if (pHalData->bt_coexist.CurrentState & BT_COEX_STATE_WIFI_DOWNLINK)
+			RTPRINT(FBT, BT_TRACE, ("Wifi_Downlink, "));
+		if (pHalData->bt_coexist.CurrentState & BT_COEX_STATE_BT_IDLE)
+			RTPRINT(FBT, BT_TRACE, ("BT_idle, "));
+		if (pHalData->bt_coexist.CurrentState & BT_COEX_STATE_PROFILE_HID)
+			RTPRINT(FBT, BT_TRACE, ("PRO_HID, "));
+		if (pHalData->bt_coexist.CurrentState & BT_COEX_STATE_PROFILE_A2DP)
+			RTPRINT(FBT, BT_TRACE, ("PRO_A2DP, "));
+		if (pHalData->bt_coexist.CurrentState & BT_COEX_STATE_PROFILE_PAN)
+			RTPRINT(FBT, BT_TRACE, ("PRO_PAN, "));
+		if (pHalData->bt_coexist.CurrentState & BT_COEX_STATE_PROFILE_SCO)
+			RTPRINT(FBT, BT_TRACE, ("PRO_SCO, "));
+		RTPRINT(FBT, BT_TRACE, ("]\n"));
+	}
+}
+
+/*  extern function start with BTDM_ */
+u32 BTDM_BtTxRxCounterH(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u32	counters =3D 0;
+
+	counters =3D pHalData->bt_coexist.halCoex8723.highPriorityTx+
+		pHalData->bt_coexist.halCoex8723.highPriorityRx;
+	return counters;
+}
+
+u32 BTDM_BtTxRxCounterL(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u32	counters =3D 0;
+
+	counters =3D pHalData->bt_coexist.halCoex8723.lowPriorityTx+
+		pHalData->bt_coexist.halCoex8723.lowPriorityRx ;
+	return counters;
+}
+
+void BTDM_SetFwChnlInfo(struct rtw_adapter *padapter, enum rt_media_st=
atus mstatus)
+{
+	struct mlme_ext_priv *pmlmeext =3D &padapter->mlmeextpriv;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	u8 H2C_Parameter[3] =3D {0};
+	u8 chnl;
+
+	/*  opMode */
+	if (RT_MEDIA_CONNECT =3D=3D mstatus)
+		H2C_Parameter[0] =3D 0x1;	/*  0: disconnected, 1:connected */
+
+	if (check_fwstate(&padapter->mlmepriv, WIFI_ASOC_STATE)) {
+		/*  channel */
+		chnl =3D pmlmeext->cur_channel;
+		if (BTDM_IsHT40(padapter)) {
+			if (pmlmeext->cur_ch_offset =3D=3D HAL_PRIME_CHNL_OFFSET_UPPER)
+				chnl -=3D 2;
+			else if (pmlmeext->cur_ch_offset =3D=3D HAL_PRIME_CHNL_OFFSET_LOWER=
)
+				chnl +=3D 2;
+		}
+		H2C_Parameter[1] =3D chnl;
+	} else {	/*  check if HS link is exists */
+		/*  channel */
+		if (BT_Operation(padapter))
+			H2C_Parameter[1] =3D pBtMgnt->BTChannel;
+		else
+			H2C_Parameter[1] =3D pmlmeext->cur_channel;
+	}
+
+	if (BTDM_IsHT40(padapter))
+		H2C_Parameter[2] =3D 0x30;
+	else
+		H2C_Parameter[2] =3D 0x20;
+
+	FillH2CCmd(padapter, 0x19, 3, H2C_Parameter);
+}
+
+u8 BTDM_IsWifiConnectionExist(struct rtw_adapter *padapter)
+{
+	u8 bRet =3D false;
+
+	if (BTHCI_HsConnectionEstablished(padapter))
+		bRet =3D true;
+
+	if (check_fwstate(&padapter->mlmepriv, WIFI_ASOC_STATE) =3D=3D true)
+		bRet =3D true;
+
+	return bRet;
+}
+
+void BTDM_SetFw3a(
+	struct rtw_adapter *padapter,
+	u8 byte1,
+	u8 byte2,
+	u8 byte3,
+	u8 byte4,
+	u8 byte5
+	)
+{
+	u8 H2C_Parameter[5] =3D {0};
+
+	if (BTDM_1Ant8723A(padapter)) {
+		if ((!check_fwstate(&padapter->mlmepriv, WIFI_STATION_STATE)) &&
+		    (get_fwstate(&padapter->mlmepriv) !=3D WIFI_NULL_STATE)) {
+			/*  for softap mode */
+			struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+			struct bt_coexist_8723a *pBtCoex =3D &pHalData->bt_coexist.halCoex8=
723;
+			u8 BtState =3D pBtCoex->c2hBtInfo;
+
+			if ((BtState !=3D BT_INFO_STATE_NO_CONNECTION) &&
+			    (BtState !=3D BT_INFO_STATE_CONNECT_IDLE)) {
+				if (byte1 & BIT(4)) {
+					byte1 &=3D ~BIT(4);
+					byte1 |=3D BIT(5);
+				}
+
+				byte5 |=3D BIT(5);
+				if (byte5 & BIT(6))
+					byte5 &=3D ~BIT(6);
+			}
+		}
+	}
+
+	H2C_Parameter[0] =3D byte1;
+	H2C_Parameter[1] =3D byte2;
+	H2C_Parameter[2] =3D byte3;
+	H2C_Parameter[3] =3D byte4;
+	H2C_Parameter[4] =3D byte5;
+
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], FW write 0x3a(5bytes) =3D 0x%02x%0=
8x\n",
+		H2C_Parameter[0],
+		H2C_Parameter[1]<<24|H2C_Parameter[2]<<16|H2C_Parameter[3]<<8|H2C_Pa=
rameter[4]));
+
+	FillH2CCmd(padapter, 0x3a, 5, H2C_Parameter);
+}
+
+void BTDM_QueryBtInformation(struct rtw_adapter *padapter)
+{
+	u8 H2C_Parameter[1] =3D {0};
+	struct hal_data_8723a *pHalData;
+	struct bt_coexist_8723a *pBtCoex;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBtCoex =3D &pHalData->bt_coexist.halCoex8723;
+
+	if (BT_IsBtDisabled(padapter)) {
+		pBtCoex->c2hBtInfo =3D BT_INFO_STATE_DISABLED;
+		pBtCoex->bC2hBtInfoReqSent =3D false;
+		return;
+	}
+
+	if (pBtCoex->c2hBtInfo =3D=3D BT_INFO_STATE_DISABLED)
+		pBtCoex->c2hBtInfo =3D BT_INFO_STATE_NO_CONNECTION;
+
+	if (pBtCoex->bC2hBtInfoReqSent =3D=3D true)
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], didn't recv previous BtInfo repor=
t!\n"));
+	else
+		pBtCoex->bC2hBtInfoReqSent =3D true;
+
+	H2C_Parameter[0] |=3D BIT(0);	/*  trigger */
+
+/*RTPRINT(FBT, BT_TRACE, ("[BTCoex], Query Bt information, write 0x38 =
=3D 0x%x\n", */
+/*H2C_Parameter[0])); */
+
+	FillH2CCmd(padapter, 0x38, 1, H2C_Parameter);
+}
+
+void BTDM_SetSwRfRxLpfCorner(struct rtw_adapter *padapter, u8 type)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (BT_RF_RX_LPF_CORNER_SHRINK =3D=3D type) {
+		/* Shrink RF Rx LPF corner */
+		RTPRINT(FBT, BT_TRACE, ("Shrink RF Rx LPF corner!!\n"));
+		PHY_SetRFReg(padapter, PathA, 0x1e, bRFRegOffsetMask, 0xf0ff7);
+		pHalData->bt_coexist.bSWCoexistAllOff =3D false;
+	} else if (BT_RF_RX_LPF_CORNER_RESUME =3D=3D type) {
+		/* Resume RF Rx LPF corner */
+		RTPRINT(FBT, BT_TRACE, ("Resume RF Rx LPF corner!!\n"));
+		PHY_SetRFReg(padapter, PathA, 0x1e, bRFRegOffsetMask, pHalData->bt_c=
oexist.BtRfRegOrigin1E);
+	}
+}
+
+void
+BTDM_SetSwPenaltyTxRateAdaptive(
+	struct rtw_adapter *padapter,
+	u8 raType
+	)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u8 tmpU1;
+
+	tmpU1 =3D rtw_read8(padapter, 0x4fd);
+	tmpU1 |=3D BIT(0);
+	if (BT_TX_RATE_ADAPTIVE_LOW_PENALTY =3D=3D raType) {
+		tmpU1 &=3D ~BIT(2);
+		pHalData->bt_coexist.bSWCoexistAllOff =3D false;
+	} else if (BT_TX_RATE_ADAPTIVE_NORMAL =3D=3D raType) {
+		tmpU1 |=3D BIT(2);
+	}
+
+	rtw_write8(padapter, 0x4fd, tmpU1);
+}
+
+void BTDM_SetFwDecBtPwr(struct rtw_adapter *padapter, u8 bDecBtPwr)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u8 H2C_Parameter[1] =3D {0};
+
+	H2C_Parameter[0] =3D 0;
+
+	if (bDecBtPwr) {
+		H2C_Parameter[0] |=3D BIT(1);
+		pHalData->bt_coexist.bFWCoexistAllOff =3D false;
+	}
+
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], decrease Bt Power : %s, write 0x21=
 =3D 0x%x\n",
+		(bDecBtPwr ? "Yes!!" : "No!!"), H2C_Parameter[0]));
+
+	FillH2CCmd(padapter, 0x21, 1, H2C_Parameter);
+}
+
+u8 BTDM_BtProfileSupport(struct rtw_adapter *padapter)
+{
+	u8 bRet =3D false;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (pBtMgnt->bSupportProfile &&
+	    !pHalData->bt_coexist.halCoex8723.bForceFwBtInfo)
+		bRet =3D true;
+
+	return bRet;
+}
+
+static void BTDM_AdjustForBtOperation8723A(struct rtw_adapter *padapte=
r)
+{
+	/* BTDM_2AntAdjustForBtOperation8723(padapter); */
+}
+
+static void BTDM_FwC2hBtRssi8723A(struct rtw_adapter *padapter, u8 *tm=
pBuf)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u8 percent =3D 0, u1tmp =3D 0;
+
+	u1tmp =3D tmpBuf[0];
+	percent =3D u1tmp*2+10;
+
+	pHalData->bt_coexist.halCoex8723.btRssi =3D percent;
+/*RTPRINT(FBT, BT_TRACE, ("[BTC2H], BT RSSI =3D%d\n", percent)); */
+}
+
+static void
+BTDM_FwC2hBtInfo8723A(struct rtw_adapter *padapter, u8 *tmpBuf, u8 len=
gth)
+{
+	struct hal_data_8723a *pHalData;
+	struct bt_30info *pBTInfo;
+	struct bt_mgnt *pBtMgnt;
+	struct bt_coexist_8723a *pBtCoex;
+	u8 i;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtMgnt =3D &pBTInfo->BtMgnt;
+	pBtCoex =3D &pHalData->bt_coexist.halCoex8723;
+
+	pBtCoex->bC2hBtInfoReqSent =3D false;
+
+	RTPRINT(FBT, BT_TRACE, ("[BTC2H], BT info[%d]=3D[", length));
+
+	pBtCoex->btRetryCnt =3D 0;
+	for (i =3D 0; i < length; i++) {
+		switch (i) {
+		case 0:
+			pBtCoex->c2hBtInfoOriginal =3D tmpBuf[i];
+			break;
+		case 1:
+			pBtCoex->btRetryCnt =3D tmpBuf[i];
+			break;
+		case 2:
+			BTDM_FwC2hBtRssi8723A(padapter, &tmpBuf[i]);
+			break;
+		case 3:
+			pBtCoex->btInfoExt =3D tmpBuf[i]&BIT(0);
+			break;
+		}
+
+		if (i =3D=3D length-1)
+			RTPRINT(FBT, BT_TRACE, ("0x%02x]\n", tmpBuf[i]));
+		else
+			RTPRINT(FBT, BT_TRACE, ("0x%02x, ", tmpBuf[i]));
+	}
+	RTPRINT(FBT, BT_TRACE, ("[BTC2H], BT RSSI =3D%d\n", pBtCoex->btRssi))=
;
+	if (pBtCoex->btInfoExt)
+		RTPRINT(FBT, BT_TRACE, ("[BTC2H], pBtCoex->btInfoExt =3D%x\n", pBtCo=
ex->btInfoExt));
+
+	if (btdm_BtWifiAntNum(padapter) =3D=3D Ant_x1)
+		BTDM_1AntFwC2hBtInfo8723A(padapter);
+	else
+		BTDM_2AntFwC2hBtInfo8723A(padapter);
+
+	if (pBtMgnt->ExtConfig.bManualControl) {
+		RTPRINT(FBT, BT_TRACE, ("%s: Action Manual control!!\n", __func__));
+		return;
+	}
+
+	btdm_BTCoexist8723AHandler(padapter);
+}
+
+static void BTDM_Display8723ABtCoexInfo(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct bt_coexist_8723a *pBtCoex =3D &pHalData->bt_coexist.halCoex872=
3;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	u8 u1Tmp, u1Tmp1, u1Tmp2, i, btInfoExt, psTdmaCase =3D 0;
+	u32 u4Tmp[4];
+	u8 antNum =3D Ant_x2;
+
+	rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n =3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D[BT Coexist info]=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D");
+	DCMD_Printf(btCoexDbgBuf);
+
+	if (!pHalData->bt_coexist.BluetoothCoexist) {
+		rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n BT not exists !!!");
+		DCMD_Printf(btCoexDbgBuf);
+		return;
+	}
+
+	antNum =3D btdm_BtWifiAntNum(padapter);
+	rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D %d/%d ", "Ant=
 mechanism PG/Now run :", \
+		((pHalData->bt_coexist.BT_Ant_Num =3D=3D Ant_x2) ? 2 : 1), ((antNum =
=3D=3D Ant_x2) ? 2 : 1));
+	DCMD_Printf(btCoexDbgBuf);
+
+	if (pBtMgnt->ExtConfig.bManualControl) {
+		rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s", "[Action Manua=
l control]!!");
+		DCMD_Printf(btCoexDbgBuf);
+	} else {
+		rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D %s / %d", "B=
T stack/ hci ext ver", \
+			((pBtMgnt->bSupportProfile) ? "Yes" : "No"), pBtMgnt->ExtConfig.HCI=
ExtensionVer);
+		DCMD_Printf(btCoexDbgBuf);
+	}
+
+	rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\n %-35s =3D / %d", "Dot11 c=
hannel / BT channel", \
+		pBtMgnt->BTChannel);
+		DCMD_Printf(btCoexDbgBuf);
+
+	rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\n %-35s =3D %d / %d / %d", =
"Wifi/BT/HS rssi", \
+		BTDM_GetRxSS(padapter),
+		pHalData->bt_coexist.halCoex8723.btRssi,
+		pHalData->dmpriv.EntryMinUndecoratedSmoothedPWDB);
+			DCMD_Printf(btCoexDbgBuf);
+
+	if (!pBtMgnt->ExtConfig.bManualControl) {
+		rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\n %-35s =3D %s / %s ", "WI=
fi status",
+			((BTDM_Legacy(padapter)) ? "Legacy" : (((BTDM_IsHT40(padapter)) ? "=
HT40" : "HT20"))),
+			((!BTDM_IsWifiBusy(padapter)) ? "idle" : ((BTDM_IsWifiUplink(padapt=
er)) ? "uplink" : "downlink")));
+		DCMD_Printf(btCoexDbgBuf);
+
+		if (pBtMgnt->bSupportProfile) {
+			rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D %d / %d / %=
d / %d", "SCO/HID/PAN/A2DP",
+				((BTHCI_CheckProfileExist(padapter, BT_PROFILE_SCO)) ? 1 : 0),
+				((BTHCI_CheckProfileExist(padapter, BT_PROFILE_HID)) ? 1 : 0),
+				((BTHCI_CheckProfileExist(padapter, BT_PROFILE_PAN)) ? 1 : 0),
+				((BTHCI_CheckProfileExist(padapter, BT_PROFILE_A2DP)) ? 1 : 0));
+		DCMD_Printf(btCoexDbgBuf);
+
+			for (i =3D 0; i < pBtMgnt->ExtConfig.NumberOfHandle; i++) {
+				if (pBtMgnt->ExtConfig.HCIExtensionVer >=3D 1) {
+					rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D %s/ %s/ %=
s", "Bt link type/spec/role",
+						BtProfileString[pBtMgnt->ExtConfig.linkInfo[i].BTProfile],
+						BtSpecString[pBtMgnt->ExtConfig.linkInfo[i].BTCoreSpec],
+						BtLinkRoleString[pBtMgnt->ExtConfig.linkInfo[i].linkRole]);
+					DCMD_Printf(btCoexDbgBuf);
+
+					btInfoExt =3D pHalData->bt_coexist.halCoex8723.btInfoExt;
+					rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D %s", "A2D=
P rate", \
+						(btInfoExt&BIT0) ? "Basic rate" : "EDR rate");
+					DCMD_Printf(btCoexDbgBuf);
+				} else {
+					rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D %s/ %s", =
"Bt link type/spec", \
+						BtProfileString[pBtMgnt->ExtConfig.linkInfo[i].BTProfile],
+						BtSpecString[pBtMgnt->ExtConfig.linkInfo[i].BTCoreSpec]);
+					DCMD_Printf(btCoexDbgBuf);
+				}
+			}
+		}
+	}
+
+	/*  Sw mechanism */
+	if (!pBtMgnt->ExtConfig.bManualControl) {
+		rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s", "=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D[Sw BT Coex mechanism]=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D");
+		DCMD_Printf(btCoexDbgBuf);
+		rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D %d ", "AGC T=
able", \
+			pBtCoex->btdm2Ant.bCurAgcTableEn);
+		DCMD_Printf(btCoexDbgBuf);
+		rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D %d ", "ADC B=
ackoff", \
+			pBtCoex->btdm2Ant.bCurAdcBackOff);
+		DCMD_Printf(btCoexDbgBuf);
+		rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D %d ", "Low p=
enalty RA", \
+			pBtCoex->btdm2Ant.bCurLowPenaltyRa);
+		DCMD_Printf(btCoexDbgBuf);
+		rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D %d ", "RF Rx=
 LPF Shrink", \
+			pBtCoex->btdm2Ant.bCurRfRxLpfShrink);
+		DCMD_Printf(btCoexDbgBuf);
+	}
+	u4Tmp[0] =3D PHY_QueryRFReg(padapter, PathA, 0x1e, 0xff0);
+	rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D 0x%x/ 0x%x", =
"RF-A, 0x1e[11:4]/original val", \
+		u4Tmp[0], pHalData->bt_coexist.BtRfRegOrigin1E);
+	DCMD_Printf(btCoexDbgBuf);
+
+	/*  Fw mechanism */
+	if (!pBtMgnt->ExtConfig.bManualControl) {
+		rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s", "=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D[Fw BT Coex mechanism]=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D");
+		DCMD_Printf(btCoexDbgBuf);
+	}
+	if (!pBtMgnt->ExtConfig.bManualControl) {
+		if (btdm_BtWifiAntNum(padapter) =3D=3D Ant_x1)
+			psTdmaCase =3D pHalData->bt_coexist.halCoex8723.btdm1Ant.curPsTdma;
+		else
+			psTdmaCase =3D pHalData->bt_coexist.halCoex8723.btdm2Ant.curPsTdma;
+		rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D %02x %02x %0=
2x %02x %02x case-%d", "PS TDMA(0x3a)", \
+			pHalData->bt_coexist.fw3aVal[0], pHalData->bt_coexist.fw3aVal[1],
+			pHalData->bt_coexist.fw3aVal[2], pHalData->bt_coexist.fw3aVal[3],
+			pHalData->bt_coexist.fw3aVal[4], psTdmaCase);
+		DCMD_Printf(btCoexDbgBuf);
+
+		rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D %d ", "Decre=
ase Bt Power", \
+			pBtCoex->btdm2Ant.bCurDecBtPwr);
+		DCMD_Printf(btCoexDbgBuf);
+	}
+	u1Tmp =3D rtw_read8(padapter, 0x778);
+	u1Tmp1 =3D rtw_read8(padapter, 0x783);
+	u1Tmp2 =3D rtw_read8(padapter, 0x796);
+	rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D 0x%x/ 0x%x/ 0=
x%x", "0x778/ 0x783/ 0x796", \
+		u1Tmp, u1Tmp1, u1Tmp2);
+	DCMD_Printf(btCoexDbgBuf);
+
+	if (!pBtMgnt->ExtConfig.bManualControl) {
+		rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D 0x%x / 0x%x"=
, "Sw DacSwing Ctrl/Val", \
+			pBtCoex->btdm2Ant.bCurDacSwingOn, pBtCoex->btdm2Ant.curDacSwingLvl)=
;
+		DCMD_Printf(btCoexDbgBuf);
+	}
+	u4Tmp[0] =3D  rtw_read32(padapter, 0x880);
+	rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D 0x%x", "0x880=
", \
+		u4Tmp[0]);
+	DCMD_Printf(btCoexDbgBuf);
+
+	/*  Hw mechanism */
+	if (!pBtMgnt->ExtConfig.bManualControl) {
+		rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s", "=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D[Hw BT Coex mechanism]=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D");
+		DCMD_Printf(btCoexDbgBuf);
+	}
+
+	u1Tmp =3D rtw_read8(padapter, 0x40);
+	rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D 0x%x", "0x40"=
, \
+		u1Tmp);
+	DCMD_Printf(btCoexDbgBuf);
+
+	u4Tmp[0] =3D rtw_read32(padapter, 0x550);
+	u1Tmp =3D rtw_read8(padapter, 0x522);
+	rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D 0x%x/0x%x", "=
0x550(bcn contrl)/0x522", \
+		u4Tmp[0], u1Tmp);
+	DCMD_Printf(btCoexDbgBuf);
+
+	u4Tmp[0] =3D rtw_read32(padapter, 0x484);
+	rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D 0x%x", "0x484=
(rate adaptive)", \
+		u4Tmp[0]);
+	DCMD_Printf(btCoexDbgBuf);
+
+	u4Tmp[0] =3D rtw_read32(padapter, 0x50);
+	rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D 0x%x", "0xc50=
(dig)", \
+		u4Tmp[0]);
+	DCMD_Printf(btCoexDbgBuf);
+
+	u4Tmp[0] =3D rtw_read32(padapter, 0xda0);
+	u4Tmp[1] =3D rtw_read32(padapter, 0xda4);
+	u4Tmp[2] =3D rtw_read32(padapter, 0xda8);
+	u4Tmp[3] =3D rtw_read32(padapter, 0xdac);
+	rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D 0x%x/ 0x%x/ 0=
x%x/ 0x%x", "0xda0/0xda4/0xda8/0xdac(FA cnt)", \
+		u4Tmp[0], u4Tmp[1], u4Tmp[2], u4Tmp[3]);
+	DCMD_Printf(btCoexDbgBuf);
+
+	u4Tmp[0] =3D rtw_read32(padapter, 0x6c0);
+	u4Tmp[1] =3D rtw_read32(padapter, 0x6c4);
+	u4Tmp[2] =3D rtw_read32(padapter, 0x6c8);
+	u1Tmp =3D rtw_read8(padapter, 0x6cc);
+	rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D 0x%x/ 0x%x/ 0=
x%x/ 0x%x", "0x6c0/0x6c4/0x6c8/0x6cc(coexTable)", \
+		u4Tmp[0], u4Tmp[1], u4Tmp[2], u1Tmp);
+	DCMD_Printf(btCoexDbgBuf);
+
+	/* u4Tmp =3D rtw_read32(padapter, 0x770); */
+	rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D %d / %d", "0x=
770(Hi pri Rx[31:16]/Tx[15:0])", \
+		pHalData->bt_coexist.halCoex8723.highPriorityRx,
+		pHalData->bt_coexist.halCoex8723.highPriorityTx);
+	DCMD_Printf(btCoexDbgBuf);
+	/* u4Tmp =3D rtw_read32(padapter, 0x774); */
+	rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D %d / %d", "0x=
774(Lo pri Rx[31:16]/Tx[15:0])", \
+		pHalData->bt_coexist.halCoex8723.lowPriorityRx,
+		pHalData->bt_coexist.halCoex8723.lowPriorityTx);
+	DCMD_Printf(btCoexDbgBuf);
+
+	/*  Tx mgnt queue hang or not, 0x41b should =3D 0xf, ex: 0xd =3D=3D>h=
ang */
+	u1Tmp =3D rtw_read8(padapter, 0x41b);
+	rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D 0x%x", "0x41b=
 (hang chk =3D=3D 0xf)", \
+		u1Tmp);
+	DCMD_Printf(btCoexDbgBuf);
+	rsprintf(btCoexDbgBuf, BT_TMP_BUF_SIZE, "\r\n %-35s =3D 0x%x", "lastH=
MEBoxNum", \
+		pHalData->LastHMEBoxNum);
+	DCMD_Printf(btCoexDbgBuf);
+}
+
+static void
+BTDM_8723ASignalCompensation(struct rtw_adapter *padapter,
+			     u8 *rssi_wifi, u8 *rssi_bt)
+{
+	if (btdm_BtWifiAntNum(padapter) =3D=3D Ant_x1)
+		BTDM_1AntSignalCompensation(padapter, rssi_wifi, rssi_bt);
+}
+
+static void BTDM_8723AInit(struct rtw_adapter *padapter)
+{
+	if (btdm_BtWifiAntNum(padapter) =3D=3D Ant_x2)
+		BTDM_2AntParaInit(padapter);
+	else
+		BTDM_1AntParaInit(padapter);
+}
+
+static void BTDM_HWCoexAllOff8723A(struct rtw_adapter *padapter)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	if (pBtMgnt->ExtConfig.bManualControl)
+		return;
+
+	if (btdm_BtWifiAntNum(padapter) =3D=3D Ant_x2)
+		BTDM_2AntHwCoexAllOff8723A(padapter);
+}
+
+static void BTDM_FWCoexAllOff8723A(struct rtw_adapter *padapter)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	if (pBtMgnt->ExtConfig.bManualControl)
+		return;
+
+	if (btdm_BtWifiAntNum(padapter) =3D=3D Ant_x2)
+		BTDM_2AntFwCoexAllOff8723A(padapter);
+}
+
+static void BTDM_SWCoexAllOff8723A(struct rtw_adapter *padapter)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	if (pBtMgnt->ExtConfig.bManualControl)
+		return;
+
+	if (btdm_BtWifiAntNum(padapter) =3D=3D Ant_x2)
+		BTDM_2AntSwCoexAllOff8723A(padapter);
+}
+
+static void
+BTDM_Set8723ABtCoexCurrAntNum(struct rtw_adapter *padapter, u8 antNum)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct bt_coexist_8723a *pBtCoex =3D &pHalData->bt_coexist.halCoex872=
3;
+
+	if (antNum =3D=3D 1)
+		pBtCoex->TotalAntNum =3D Ant_x1;
+	else if (antNum =3D=3D 2)
+		pBtCoex->TotalAntNum =3D Ant_x2;
+}
+
+void BTDM_LpsLeave(struct rtw_adapter *padapter)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	if (pBtMgnt->ExtConfig.bManualControl)
+		return;
+
+	if (btdm_BtWifiAntNum(padapter) =3D=3D Ant_x1)
+		BTDM_1AntLpsLeave(padapter);
+}
+
+static void BTDM_ForHalt8723A(struct rtw_adapter *padapter)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	if (pBtMgnt->ExtConfig.bManualControl)
+		return;
+
+	if (btdm_BtWifiAntNum(padapter) =3D=3D Ant_x1)
+		BTDM_1AntForHalt(padapter);
+}
+
+static void BTDM_WifiScanNotify8723A(struct rtw_adapter *padapter, u8 =
scanType)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	if (pBtMgnt->ExtConfig.bManualControl)
+		return;
+
+	if (btdm_BtWifiAntNum(padapter) =3D=3D Ant_x1)
+		BTDM_1AntWifiScanNotify(padapter, scanType);
+}
+
+static void
+BTDM_WifiAssociateNotify8723A(struct rtw_adapter *padapter, u8 action)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	if (pBtMgnt->ExtConfig.bManualControl)
+		return;
+
+	if (btdm_BtWifiAntNum(padapter) =3D=3D Ant_x1)
+		BTDM_1AntWifiAssociateNotify(padapter, action);
+}
+
+static void
+BTDM_MediaStatusNotify8723A(struct rtw_adapter *padapter,
+			    enum rt_media_status mstatus)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], MediaStatusNotify, %s\n",
+		mstatus?"connect":"disconnect"));
+
+	BTDM_SetFwChnlInfo(padapter, mstatus);
+
+	if (pBtMgnt->ExtConfig.bManualControl)
+		return;
+
+	if (btdm_BtWifiAntNum(padapter) =3D=3D Ant_x1)
+		BTDM_1AntMediaStatusNotify(padapter, mstatus);
+}
+
+static void BTDM_ForDhcp8723A(struct rtw_adapter *padapter)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	if (pBtMgnt->ExtConfig.bManualControl)
+		return;
+
+	if (btdm_BtWifiAntNum(padapter) =3D=3D Ant_x1)
+		BTDM_1AntForDhcp(padapter);
+}
+
+u8 BTDM_1Ant8723A(struct rtw_adapter *padapter)
+{
+	if (btdm_BtWifiAntNum(padapter) =3D=3D Ant_x1)
+		return true;
+	else
+		return false;
+}
+
+static void BTDM_BTCoexist8723A(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	struct bt_30info *pBTInfo;
+	struct bt_mgnt *pBtMgnt;
+	struct bt_coexist_8723a *pBtCoex;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtMgnt =3D &pBTInfo->BtMgnt;
+	pBtCoex =3D &pHalData->bt_coexist.halCoex8723;
+
+	RTPRINT(FBT, BT_TRACE, ("[BTCoex], beacon RSSI =3D 0x%x(%d)\n",
+		pHalData->dmpriv.EntryMinUndecoratedSmoothedPWDB,
+		pHalData->dmpriv.EntryMinUndecoratedSmoothedPWDB));
+
+	btdm_BtHwCountersMonitor(padapter);
+	btdm_BtEnableDisableCheck8723A(padapter);
+
+	if (pBtMgnt->ExtConfig.bManualControl) {
+		RTPRINT(FBT, BT_TRACE, ("%s: Action Manual control!!\n", __func__));
+		return;
+	}
+
+	if (pBtCoex->bC2hBtInfoReqSent) {
+		if (BT_IsBtDisabled(padapter)) {
+			pBtCoex->c2hBtInfo =3D BT_INFO_STATE_DISABLED;
+		} else {
+			if (pBtCoex->c2hBtInfo =3D=3D BT_INFO_STATE_DISABLED)
+				pBtCoex->c2hBtInfo =3D BT_INFO_STATE_NO_CONNECTION;
+		}
+
+		btdm_BTCoexist8723AHandler(padapter);
+	} else if (BT_IsBtDisabled(padapter) =3D=3D true) {
+		pBtCoex->c2hBtInfo =3D BT_INFO_STATE_DISABLED;
+		btdm_BTCoexist8723AHandler(padapter);
+	}
+
+	BTDM_QueryBtInformation(padapter);
+}
+
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver HAL/BTCoexist/HalBtc87=
23.c =3D=3D=3D=3D=3D */
+#endif
+
+#ifdef __HALBTCCSR1ANT_C__ /*  HAL/BTCoexist/HalBtcCsr1Ant.c */
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver HAL/BTCoex=
ist/HalBtcCsr1Ant.c =3D=3D=3D=3D=3D */
+
+/*  local function start with btdm_ */
+/*  extern function start with BTDM_ */
+
+static void BTDM_SetAntenna(struct rtw_adapter *padapter, u8 who)
+{
+}
+
+void
+BTDM_SingleAnt(
+	struct rtw_adapter *padapter,
+	u8 bSingleAntOn,
+	u8 bInterruptOn,
+	u8 bMultiNAVOn
+	)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u8 H2C_Parameter[3] =3D {0};
+
+	if (pHalData->bt_coexist.BT_Ant_Num !=3D Ant_x1)
+		return;
+
+	H2C_Parameter[2] =3D 0;
+	H2C_Parameter[1] =3D 0;
+	H2C_Parameter[0] =3D 0;
+
+	if (bInterruptOn) {
+		H2C_Parameter[2] |=3D 0x02;	/* BIT1 */
+		pHalData->bt_coexist.bFWCoexistAllOff =3D false;
+	}
+	pHalData->bt_coexist.bInterruptOn =3D bInterruptOn;
+
+	if (bSingleAntOn) {
+		H2C_Parameter[2] |=3D 0x10;	/* BIT4 */
+		pHalData->bt_coexist.bFWCoexistAllOff =3D false;
+	}
+	pHalData->bt_coexist.bSingleAntOn =3D bSingleAntOn;
+
+	if (bMultiNAVOn) {
+		H2C_Parameter[2] |=3D 0x20;	/* BIT5 */
+		pHalData->bt_coexist.bFWCoexistAllOff =3D false;
+	}
+	pHalData->bt_coexist.bMultiNAVOn =3D bMultiNAVOn;
+
+	RTPRINT(FBT, BT_TRACE, ("[DM][BT], SingleAntenna =3D[%s:%s:%s], write=
 0xe =3D 0x%x\n",
+		bSingleAntOn?"ON":"OFF", bInterruptOn?"ON":"OFF", bMultiNAVOn?"ON":"=
OFF",
+		H2C_Parameter[0]<<16|H2C_Parameter[1]<<8|H2C_Parameter[2]));
+}
+
+void BTDM_CheckBTIdleChange1Ant(struct rtw_adapter *padapter)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+/*PMGNT_INFO		pMgntInfo =3D &padapter->MgntInfo; */
+	u8 	stateChange =3D false;
+	u32			BT_Polling, Ratio_Act, Ratio_STA;
+	u32				BT_Active, BT_State;
+	u32				regBTActive =3D 0, regBTState =3D 0, regBTPolling =3D 0;
+
+	if (!pHalData->bt_coexist.BluetoothCoexist)
+		return;
+	if (pBtMgnt->ExtConfig.bManualControl)
+		return;
+	if (pHalData->bt_coexist.BT_CoexistType !=3D BT_CSR_BC8)
+		return;
+	if (pHalData->bt_coexist.BT_Ant_Num !=3D Ant_x1)
+		return;
+
+	/*  The following we only consider CSR BC8 and fw version should be >=
=3D 62 */
+	RTPRINT(FBT, BT_TRACE, ("[DM][BT], FirmwareVersion =3D 0x%x(%d)\n",
+	pHalData->FirmwareVersion, pHalData->FirmwareVersion));
+	regBTActive =3D REG_BT_ACTIVE;
+	regBTState =3D REG_BT_STATE;
+	if (pHalData->FirmwareVersion >=3D FW_VER_BT_REG1)
+		regBTPolling =3D REG_BT_POLLING1;
+	else
+		regBTPolling =3D REG_BT_POLLING;
+
+	BT_Active =3D rtw_read32(padapter, regBTActive);
+	RTPRINT(FBT, BT_TRACE, ("[DM][BT], BT_Active(0x%x) =3D%x\n", regBTAct=
ive, BT_Active));
+	BT_Active =3D BT_Active & 0x00ffffff;
+
+	BT_State =3D rtw_read32(padapter, regBTState);
+	RTPRINT(FBT, BT_TRACE, ("[DM][BT], BT_State(0x%x) =3D%x\n", regBTStat=
e, BT_State));
+	BT_State =3D BT_State & 0x00ffffff;
+
+	BT_Polling =3D rtw_read32(padapter, regBTPolling);
+	RTPRINT(FBT, BT_TRACE, ("[DM][BT], BT_Polling(0x%x) =3D%x\n", regBTPo=
lling, BT_Polling));
+
+	if (BT_Active =3D=3D 0xffffffff && BT_State =3D=3D 0xffffffff && BT_P=
olling =3D=3D 0xffffffff)
+		return;
+	if (BT_Polling =3D=3D 0)
+		return;
+
+	Ratio_Act =3D BT_Active*1000/BT_Polling;
+	Ratio_STA =3D BT_State*1000/BT_Polling;
+
+	pHalData->bt_coexist.Ratio_Tx =3D Ratio_Act;
+	pHalData->bt_coexist.Ratio_PRI =3D Ratio_STA;
+
+	RTPRINT(FBT, BT_TRACE, ("[DM][BT], Ratio_Act =3D%d\n", Ratio_Act));
+	RTPRINT(FBT, BT_TRACE, ("[DM][BT], Ratio_STA =3D%d\n", Ratio_STA));
+
+	if (Ratio_STA < 60 && Ratio_Act < 500) {	/*  BT PAN idle */
+		pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_BT_PAN_IDLE;
+		pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_BT_PAN_DOWNLIN=
K;
+		pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_BT_PAN_UPLINK;
+	} else {
+		pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_BT_PAN_IDLE;
+
+		if (Ratio_STA) {
+			/*  Check if BT PAN (under BT 2.1) is uplink or downlink */
+			if ((Ratio_Act/Ratio_STA) < 2) {
+				/*  BT PAN Uplink */
+				pHalData->bt_coexist.BT21TrafficStatistics.bTxBusyTraffic =3D true=
;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_BT_PAN_UPLINK=
;
+				pHalData->bt_coexist.BT21TrafficStatistics.bRxBusyTraffic =3D fals=
e;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_BT_PAN_DOWNL=
INK;
+			} else {
+				/*  BT PAN downlink */
+				pHalData->bt_coexist.BT21TrafficStatistics.bTxBusyTraffic =3D fals=
e;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_BT_PAN_UPLIN=
K;
+				pHalData->bt_coexist.BT21TrafficStatistics.bRxBusyTraffic =3D true=
;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_BT_PAN_DOWNLI=
NK;
+			}
+		} else {
+			/*  BT PAN downlink */
+			pHalData->bt_coexist.BT21TrafficStatistics.bTxBusyTraffic =3D false=
;
+			pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_BT_PAN_UPLINK=
;
+			pHalData->bt_coexist.BT21TrafficStatistics.bRxBusyTraffic =3D true;
+			pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_BT_PAN_DOWNLIN=
K;
+		}
+	}
+
+	/*  Check BT is idle or not */
+	if (pBtMgnt->ExtConfig.NumberOfHandle =3D=3D 0 &&
+	    pBtMgnt->ExtConfig.NumberOfSCO =3D=3D 0) {
+		pBtMgnt->ExtConfig.bBTBusy =3D false;
+		pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_BT_IDLE;
+	} else {
+		if (Ratio_STA < 60) {
+			pBtMgnt->ExtConfig.bBTBusy =3D false;
+			pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_BT_IDLE;
+		} else {
+			pBtMgnt->ExtConfig.bBTBusy =3D true;
+			pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_BT_IDLE;
+		}
+	}
+
+	if (pBtMgnt->ExtConfig.NumberOfHandle =3D=3D 0 &&
+	    pBtMgnt->ExtConfig.NumberOfSCO =3D=3D 0) {
+		pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_BT_RSSI_LOW;
+		pBtMgnt->ExtConfig.MIN_BT_RSSI =3D 0;
+		BTDM_SetAntenna(padapter, BTDM_ANT_BT_IDLE);
+	} else {
+		if (pBtMgnt->ExtConfig.MIN_BT_RSSI <=3D -5) {
+			pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_BT_RSSI_LOW;
+			RTPRINT(FBT, BT_TRACE, ("[DM][BT], core stack notify bt rssi Low\n"=
));
+		} else {
+			pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_BT_RSSI_LOW;
+			RTPRINT(FBT, BT_TRACE, ("[DM][BT], core stack notify bt rssi Normal=
\n"));
+		}
+	}
+
+	if (pHalData->bt_coexist.bBTBusyTraffic !=3D pBtMgnt->ExtConfig.bBTBu=
sy) {
+		/*  BT idle or BT non-idle */
+		pHalData->bt_coexist.bBTBusyTraffic =3D pBtMgnt->ExtConfig.bBTBusy;
+		stateChange =3D true;
+	}
+
+	if (stateChange) {
+		if (!pBtMgnt->ExtConfig.bBTBusy)
+			RTPRINT(FBT, BT_TRACE, ("[DM][BT], BT is idle or disable\n"));
+		else
+			RTPRINT(FBT, BT_TRACE, ("[DM][BT], BT is non-idle\n"));
+	}
+	if (!pBtMgnt->ExtConfig.bBTBusy) {
+		RTPRINT(FBT, BT_TRACE, ("[DM][BT], BT is idle or disable\n"));
+		if (check_fwstate(&padapter->mlmepriv, WIFI_UNDER_LINKING|WIFI_SITE_=
MONITOR) =3D=3D true)
+			BTDM_SetAntenna(padapter, BTDM_ANT_WIFI);
+	}
+}
+
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver HAL/BTCoexist/HalBtcCs=
r1Ant.c =3D=3D=3D=3D=3D */
+#endif
+
+#ifdef __HALBTCCSR2ANT_C__ /*  HAL/BTCoexist/HalBtcCsr2Ant.c */
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver HAL/BTCoex=
ist/HalBtcCsr2Ant.c =3D=3D=3D=3D=3D */
+
+/*  local function start with btdm_ */
+
+/*  Note: */
+/*  In the following, FW should be done before SW mechanism. */
+/*  BTDM_Balance(), BTDM_DiminishWiFi(), BT_NAV() should be done */
+/*  before BTDM_AGCTable(), BTDM_BBBackOffLevel(), btdm_DacSwing(). */
+
+/*  extern function start with BTDM_ */
+
+void
+BTDM_DiminishWiFi(
+	struct rtw_adapter *padapter,
+	u8 bDACOn,
+	u8 bInterruptOn,
+	u8 DACSwingLevel,
+	u8 bNAVOn
+	)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u8 H2C_Parameter[3] =3D {0};
+
+	if (pHalData->bt_coexist.BT_Ant_Num !=3D Ant_x2)
+		return;
+
+	if ((pHalData->bt_coexist.CurrentState & BT_COEX_STATE_BT_RSSI_LOW) &=
&
+	    (DACSwingLevel =3D=3D 0x20)) {
+		RTPRINT(FBT, BT_TRACE, ("[BT]DiminishWiFi 0x20 original, but set 0x1=
8 for Low RSSI!\n"));
+		DACSwingLevel =3D 0x18;
+	}
+
+	H2C_Parameter[2] =3D 0;
+	H2C_Parameter[1] =3D DACSwingLevel;
+	H2C_Parameter[0] =3D 0;
+	if (bDACOn) {
+		H2C_Parameter[2] |=3D 0x01;	/* BIT0 */
+		if (bInterruptOn)
+			H2C_Parameter[2] |=3D 0x02;	/* BIT1 */
+		pHalData->bt_coexist.bFWCoexistAllOff =3D false;
+	}
+	if (bNAVOn) {
+		H2C_Parameter[2] |=3D 0x08;	/* BIT3 */
+		pHalData->bt_coexist.bFWCoexistAllOff =3D false;
+	}
+
+	RTPRINT(FBT, BT_TRACE, ("[DM][BT], bDACOn =3D %s, bInterruptOn =3D %s=
, write 0xe =3D 0x%x\n",
+		bDACOn?"ON":"OFF", bInterruptOn?"ON":"OFF",
+		H2C_Parameter[0]<<16|H2C_Parameter[1]<<8|H2C_Parameter[2]));
+	RTPRINT(FBT, BT_TRACE, ("[DM][BT], bNAVOn =3D %s\n",
+		bNAVOn?"ON":"OFF"));
+}
+
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver HAL/BTCoexist/HalBtcCs=
r2Ant.c =3D=3D=3D=3D=3D */
+#endif
+
+#ifdef __HALBTCOEXIST_C__ /*  HAL/BTCoexist/HalBtCoexist.c */
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver HAL/BTCoex=
ist/HalBtCoexist.c =3D=3D=3D=3D=3D */
+
+/*  local function */
+static void btdm_ResetFWCoexState(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	pHalData->bt_coexist.CurrentState =3D 0;
+	pHalData->bt_coexist.PreviousState =3D 0;
+}
+
+static void btdm_InitBtCoexistDM(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	/*  20100415 Joseph: Restore RF register 0x1E and 0x1F value for furt=
her usage. */
+	pHalData->bt_coexist.BtRfRegOrigin1E =3D PHY_QueryRFReg(padapter, Pat=
hA, RF_RCK1, bRFRegOffsetMask);
+	pHalData->bt_coexist.BtRfRegOrigin1F =3D PHY_QueryRFReg(padapter, Pat=
hA, RF_RCK2, 0xf0);
+
+	pHalData->bt_coexist.CurrentState =3D 0;
+	pHalData->bt_coexist.PreviousState =3D 0;
+
+	BTDM_8723AInit(padapter);
+	pHalData->bt_coexist.bInitlized =3D true;
+}
+
+/*  */
+/*  extern function */
+/*  */
+void BTDM_CheckAntSelMode(struct rtw_adapter *padapter)
+{
+}
+
+void BTDM_FwC2hBtRssi(struct rtw_adapter *padapter, u8 *tmpBuf)
+{
+	BTDM_FwC2hBtRssi8723A(padapter, tmpBuf);
+}
+
+void BTDM_FwC2hBtInfo(struct rtw_adapter *padapter, u8 *tmpBuf, u8 len=
gth)
+{
+	BTDM_FwC2hBtInfo8723A(padapter, tmpBuf, length);
+}
+
+void BTDM_DisplayBtCoexInfo(struct rtw_adapter *padapter)
+{
+	BTDM_Display8723ABtCoexInfo(padapter);
+}
+
+void BTDM_RejectAPAggregatedPacket(struct rtw_adapter *padapter, u8 bR=
eject)
+{
+}
+
+u8 BTDM_IsHT40(struct rtw_adapter *padapter)
+{
+	u8 isht40 =3D true;
+	enum ht_channel_width bw;
+
+	bw =3D padapter->mlmeextpriv.cur_bwmode;
+
+	if (bw =3D=3D HT_CHANNEL_WIDTH_20)
+		isht40 =3D false;
+	else if (bw =3D=3D HT_CHANNEL_WIDTH_40)
+		isht40 =3D true;
+
+	return isht40;
+}
+
+u8 BTDM_Legacy(struct rtw_adapter *padapter)
+{
+	struct mlme_ext_priv *pmlmeext;
+	u8 isLegacy =3D false;
+
+	pmlmeext =3D &padapter->mlmeextpriv;
+	if ((pmlmeext->cur_wireless_mode =3D=3D WIRELESS_11B) ||
+		(pmlmeext->cur_wireless_mode =3D=3D WIRELESS_11G) ||
+		(pmlmeext->cur_wireless_mode =3D=3D WIRELESS_11BG))
+		isLegacy =3D true;
+
+	return isLegacy;
+}
+
+void BTDM_CheckWiFiState(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	struct mlme_priv *pmlmepriv;
+	struct bt_30info *pBTInfo;
+	struct bt_mgnt *pBtMgnt;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pmlmepriv =3D &padapter->mlmepriv;
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	if (pmlmepriv->LinkDetectInfo.bBusyTraffic) {
+		pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_IDLE;
+
+		if (pmlmepriv->LinkDetectInfo.bTxBusyTraffic)
+			pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_UPLINK;
+		else
+			pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_UPLINK;
+
+		if (pmlmepriv->LinkDetectInfo.bRxBusyTraffic)
+			pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_DOWNLINK;
+		else
+			pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_DOWNLINK=
;
+	} else {
+		pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_IDLE;
+		pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_UPLINK;
+		pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_DOWNLINK;
+	}
+
+	if (BTDM_Legacy(padapter)) {
+		pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_LEGACY;
+		pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_HT20;
+		pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_HT40;
+	} else {
+		pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_LEGACY;
+		if (BTDM_IsHT40(padapter)) {
+			pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_HT40;
+			pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_HT20;
+		} else {
+			pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_HT20;
+			pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_HT40;
+		}
+	}
+
+	if (pBtMgnt->BtOperationOn)
+		pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_BT30;
+	else
+		pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_BT30;
+}
+
+s32 BTDM_GetRxSS(struct rtw_adapter *padapter)
+{
+/*PMGNT_INFO		pMgntInfo =3D &padapter->MgntInfo; */
+	struct mlme_priv *pmlmepriv;
+	struct hal_data_8723a *pHalData;
+	s32			UndecoratedSmoothedPWDB =3D 0;
+
+	pmlmepriv =3D &padapter->mlmepriv;
+	pHalData =3D GET_HAL_DATA(padapter);
+
+	if (check_fwstate(pmlmepriv, _FW_LINKED)) {
+		UndecoratedSmoothedPWDB =3D GET_UNDECORATED_AVERAGE_RSSI(padapter);
+	} else { /*  associated entry pwdb */
+		UndecoratedSmoothedPWDB =3D pHalData->dmpriv.EntryMinUndecoratedSmoo=
thedPWDB;
+		/* pHalData->BT_EntryMinUndecoratedSmoothedPWDB */
+	}
+	RTPRINT(FBT, BT_TRACE, ("BTDM_GetRxSS() =3D %d\n", UndecoratedSmoothe=
dPWDB));
+	return UndecoratedSmoothedPWDB;
+}
+
+static s32 BTDM_GetRxBeaconSS(struct rtw_adapter *padapter)
+{
+/*PMGNT_INFO		pMgntInfo =3D &padapter->MgntInfo; */
+	struct mlme_priv *pmlmepriv;
+	struct hal_data_8723a *pHalData;
+	s32			pwdbBeacon =3D 0;
+
+	pmlmepriv =3D &padapter->mlmepriv;
+	pHalData =3D GET_HAL_DATA(padapter);
+
+	if (check_fwstate(pmlmepriv, _FW_LINKED)) {
+		/* pwdbBeacon =3D pHalData->dmpriv.UndecoratedSmoothedBeacon; */
+		pwdbBeacon =3D pHalData->dmpriv.EntryMinUndecoratedSmoothedPWDB;
+	}
+	RTPRINT(FBT, BT_TRACE, ("BTDM_GetRxBeaconSS() =3D %d\n", pwdbBeacon))=
;
+	return pwdbBeacon;
+}
+
+/*  Get beacon rssi state */
+u8 BTDM_CheckCoexBcnRssiState(struct rtw_adapter *padapter, u8 levelNu=
m,
+			      u8 RssiThresh, u8 RssiThresh1)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	s32 pwdbBeacon =3D 0;
+	u8 bcnRssiState =3D 0;
+
+	pwdbBeacon =3D BTDM_GetRxBeaconSS(padapter);
+
+	if (levelNum =3D=3D 2) {
+		pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_BEAC=
ON_MEDIUM;
+
+		if ((pHalData->bt_coexist.preRssiStateBeacon =3D=3D BT_RSSI_STATE_LO=
W) ||
+		    (pHalData->bt_coexist.preRssiStateBeacon =3D=3D BT_RSSI_STATE_ST=
AY_LOW)) {
+			if (pwdbBeacon >=3D (RssiThresh+BT_FW_COEX_THRESH_TOL)) {
+				bcnRssiState =3D BT_RSSI_STATE_HIGH;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_BEA=
CON_HIGH;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_BE=
ACON_LOW;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_BEACON state switch to Hig=
h\n"));
+			} else {
+				bcnRssiState =3D BT_RSSI_STATE_STAY_LOW;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_BEACON state stay at Low\n=
"));
+			}
+		} else {
+			if (pwdbBeacon < RssiThresh) {
+				bcnRssiState =3D BT_RSSI_STATE_LOW;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_BEA=
CON_LOW;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_BE=
ACON_HIGH;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_BEACON state switch to Low=
\n"));
+			} else {
+				bcnRssiState =3D BT_RSSI_STATE_STAY_HIGH;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_BEACON state stay at High\=
n"));
+			}
+		}
+	} else if (levelNum =3D=3D 3) {
+		if (RssiThresh > RssiThresh1) {
+			RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_BEACON thresh error!!\n"));
+			return pHalData->bt_coexist.preRssiStateBeacon;
+		}
+
+		if ((pHalData->bt_coexist.preRssiStateBeacon =3D=3D BT_RSSI_STATE_LO=
W) ||
+		    (pHalData->bt_coexist.preRssiStateBeacon =3D=3D BT_RSSI_STATE_ST=
AY_LOW)) {
+			if (pwdbBeacon >=3D (RssiThresh+BT_FW_COEX_THRESH_TOL)) {
+				bcnRssiState =3D BT_RSSI_STATE_MEDIUM;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_BEA=
CON_MEDIUM;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_BE=
ACON_LOW;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_BE=
ACON_HIGH;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_BEACON state switch to Med=
ium\n"));
+			} else {
+				bcnRssiState =3D BT_RSSI_STATE_STAY_LOW;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_BEACON state stay at Low\n=
"));
+			}
+		} else if ((pHalData->bt_coexist.preRssiStateBeacon =3D=3D BT_RSSI_S=
TATE_MEDIUM) ||
+			   (pHalData->bt_coexist.preRssiStateBeacon =3D=3D BT_RSSI_STATE_ST=
AY_MEDIUM)) {
+			if (pwdbBeacon >=3D (RssiThresh1+BT_FW_COEX_THRESH_TOL)) {
+				bcnRssiState =3D BT_RSSI_STATE_HIGH;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_BEA=
CON_HIGH;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_BE=
ACON_LOW;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_BE=
ACON_MEDIUM;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_BEACON state switch to Hig=
h\n"));
+			} else if (pwdbBeacon < RssiThresh) {
+				bcnRssiState =3D BT_RSSI_STATE_LOW;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_BEA=
CON_LOW;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_BE=
ACON_HIGH;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_BE=
ACON_MEDIUM;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_BEACON state switch to Low=
\n"));
+			} else {
+				bcnRssiState =3D BT_RSSI_STATE_STAY_MEDIUM;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_BEACON state stay at Mediu=
m\n"));
+			}
+		} else {
+			if (pwdbBeacon < RssiThresh1) {
+				bcnRssiState =3D BT_RSSI_STATE_MEDIUM;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_BEA=
CON_MEDIUM;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_BE=
ACON_HIGH;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_BE=
ACON_LOW;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_BEACON state switch to Med=
ium\n"));
+			} else {
+				bcnRssiState =3D BT_RSSI_STATE_STAY_HIGH;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_BEACON state stay at High\=
n"));
+			}
+		}
+	}
+
+	pHalData->bt_coexist.preRssiStateBeacon =3D bcnRssiState;
+
+	return bcnRssiState;
+}
+
+u8 BTDM_CheckCoexRSSIState1(struct rtw_adapter *padapter, u8 levelNum,
+			    u8 RssiThresh, u8 RssiThresh1)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	s32 UndecoratedSmoothedPWDB =3D 0;
+	u8 btRssiState =3D 0;
+
+	UndecoratedSmoothedPWDB =3D BTDM_GetRxSS(padapter);
+
+	if (levelNum =3D=3D 2) {
+		pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_1_ME=
DIUM;
+
+		if ((pHalData->bt_coexist.preRssiState1 =3D=3D BT_RSSI_STATE_LOW) ||
+		    (pHalData->bt_coexist.preRssiState1 =3D=3D BT_RSSI_STATE_STAY_LO=
W)) {
+			if (UndecoratedSmoothedPWDB >=3D (RssiThresh+BT_FW_COEX_THRESH_TOL)=
) {
+				btRssiState =3D BT_RSSI_STATE_HIGH;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_1_H=
IGH;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_1_=
LOW;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_1 state switch to High\n")=
);
+			} else {
+				btRssiState =3D BT_RSSI_STATE_STAY_LOW;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_1 state stay at Low\n"));
+			}
+		} else {
+			if (UndecoratedSmoothedPWDB < RssiThresh) {
+				btRssiState =3D BT_RSSI_STATE_LOW;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_1_L=
OW;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_1_=
HIGH;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_1 state switch to Low\n"))=
;
+			} else {
+				btRssiState =3D BT_RSSI_STATE_STAY_HIGH;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_1 state stay at High\n"));
+			}
+		}
+	} else if (levelNum =3D=3D 3) {
+		if (RssiThresh > RssiThresh1) {
+			RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_1 thresh error!!\n"));
+			return pHalData->bt_coexist.preRssiState1;
+		}
+
+		if ((pHalData->bt_coexist.preRssiState1 =3D=3D BT_RSSI_STATE_LOW) ||
+		    (pHalData->bt_coexist.preRssiState1 =3D=3D BT_RSSI_STATE_STAY_LO=
W)) {
+			if (UndecoratedSmoothedPWDB >=3D (RssiThresh+BT_FW_COEX_THRESH_TOL)=
) {
+				btRssiState =3D BT_RSSI_STATE_MEDIUM;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_1_M=
EDIUM;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_1_=
LOW;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_1_=
HIGH;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_1 state switch to Medium\n=
"));
+			} else {
+				btRssiState =3D BT_RSSI_STATE_STAY_LOW;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_1 state stay at Low\n"));
+			}
+		} else if ((pHalData->bt_coexist.preRssiState1 =3D=3D BT_RSSI_STATE_=
MEDIUM) ||
+			   (pHalData->bt_coexist.preRssiState1 =3D=3D BT_RSSI_STATE_STAY_ME=
DIUM)) {
+			if (UndecoratedSmoothedPWDB >=3D (RssiThresh1+BT_FW_COEX_THRESH_TOL=
)) {
+				btRssiState =3D BT_RSSI_STATE_HIGH;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_1_H=
IGH;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_1_=
LOW;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_1_=
MEDIUM;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_1 state switch to High\n")=
);
+			} else if (UndecoratedSmoothedPWDB < RssiThresh) {
+				btRssiState =3D BT_RSSI_STATE_LOW;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_1_L=
OW;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_1_=
HIGH;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_1_=
MEDIUM;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_1 state switch to Low\n"))=
;
+			} else {
+				btRssiState =3D BT_RSSI_STATE_STAY_MEDIUM;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_1 state stay at Medium\n")=
);
+			}
+		} else {
+			if (UndecoratedSmoothedPWDB < RssiThresh1) {
+				btRssiState =3D BT_RSSI_STATE_MEDIUM;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_1_M=
EDIUM;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_1_=
HIGH;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_1_=
LOW;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_1 state switch to Medium\n=
"));
+			} else {
+				btRssiState =3D BT_RSSI_STATE_STAY_HIGH;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI_1 state stay at High\n"));
+			}
+		}
+	}
+
+	pHalData->bt_coexist.preRssiState1 =3D btRssiState;
+
+	return btRssiState;
+}
+
+u8 BTDM_CheckCoexRSSIState(struct rtw_adapter *padapter, u8 levelNum,
+			   u8 RssiThresh, u8 RssiThresh1)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	s32 UndecoratedSmoothedPWDB =3D 0;
+	u8 btRssiState =3D 0;
+
+	UndecoratedSmoothedPWDB =3D BTDM_GetRxSS(padapter);
+
+	if (levelNum =3D=3D 2) {
+		pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_MEDI=
UM;
+
+		if ((pHalData->bt_coexist.preRssiState =3D=3D BT_RSSI_STATE_LOW) ||
+		    (pHalData->bt_coexist.preRssiState =3D=3D BT_RSSI_STATE_STAY_LOW=
)) {
+			if (UndecoratedSmoothedPWDB >=3D (RssiThresh+BT_FW_COEX_THRESH_TOL)=
) {
+				btRssiState =3D BT_RSSI_STATE_HIGH;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_HIG=
H;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_LO=
W;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI state switch to High\n"));
+			} else {
+				btRssiState =3D BT_RSSI_STATE_STAY_LOW;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI state stay at Low\n"));
+			}
+		} else {
+			if (UndecoratedSmoothedPWDB < RssiThresh) {
+				btRssiState =3D BT_RSSI_STATE_LOW;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_LOW=
;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_HI=
GH;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI state switch to Low\n"));
+			} else {
+				btRssiState =3D BT_RSSI_STATE_STAY_HIGH;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI state stay at High\n"));
+			}
+		}
+	} else if (levelNum =3D=3D 3) {
+		if (RssiThresh > RssiThresh1) {
+			RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI thresh error!!\n"));
+			return pHalData->bt_coexist.preRssiState;
+		}
+
+		if ((pHalData->bt_coexist.preRssiState =3D=3D BT_RSSI_STATE_LOW) ||
+		    (pHalData->bt_coexist.preRssiState =3D=3D BT_RSSI_STATE_STAY_LOW=
)) {
+			if (UndecoratedSmoothedPWDB >=3D (RssiThresh+BT_FW_COEX_THRESH_TOL)=
) {
+				btRssiState =3D BT_RSSI_STATE_MEDIUM;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_MED=
IUM;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_LO=
W;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_HI=
GH;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI state switch to Medium\n")=
);
+			} else {
+				btRssiState =3D BT_RSSI_STATE_STAY_LOW;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI state stay at Low\n"));
+			}
+		} else if ((pHalData->bt_coexist.preRssiState =3D=3D BT_RSSI_STATE_M=
EDIUM) ||
+			   (pHalData->bt_coexist.preRssiState =3D=3D BT_RSSI_STATE_STAY_MED=
IUM)) {
+			if (UndecoratedSmoothedPWDB >=3D (RssiThresh1+BT_FW_COEX_THRESH_TOL=
)) {
+				btRssiState =3D BT_RSSI_STATE_HIGH;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_HIG=
H;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_LO=
W;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_ME=
DIUM;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI state switch to High\n"));
+			} else if (UndecoratedSmoothedPWDB < RssiThresh) {
+				btRssiState =3D BT_RSSI_STATE_LOW;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_LOW=
;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_HI=
GH;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_ME=
DIUM;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI state switch to Low\n"));
+			} else {
+				btRssiState =3D BT_RSSI_STATE_STAY_MEDIUM;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI state stay at Medium\n"));
+			}
+		} else {
+			if (UndecoratedSmoothedPWDB < RssiThresh1) {
+				btRssiState =3D BT_RSSI_STATE_MEDIUM;
+				pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_WIFI_RSSI_MED=
IUM;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_HI=
GH;
+				pHalData->bt_coexist.CurrentState &=3D ~BT_COEX_STATE_WIFI_RSSI_LO=
W;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI state switch to Medium\n")=
);
+			} else {
+				btRssiState =3D BT_RSSI_STATE_STAY_HIGH;
+				RTPRINT(FBT, BT_TRACE, ("[DM][BT], RSSI state stay at High\n"));
+			}
+		}
+	}
+
+	pHalData->bt_coexist.preRssiState =3D btRssiState;
+
+	return btRssiState;
+}
+
+u8 BTDM_DisableEDCATurbo(struct rtw_adapter *padapter)
+{
+	struct bt_mgnt *pBtMgnt;
+	struct hal_data_8723a *pHalData;
+	u8 bBtChangeEDCA =3D false;
+	u32 EDCA_BT_BE =3D 0x5ea42b, cur_EDCA_reg;
+	u8 bRet =3D false;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBtMgnt =3D &pHalData->BtInfo.BtMgnt;
+
+	if (!pHalData->bt_coexist.BluetoothCoexist) {
+		bRet =3D false;
+		pHalData->bt_coexist.lastBtEdca =3D 0;
+		return bRet;
+	}
+	if (!((pBtMgnt->bSupportProfile) ||
+	    (pHalData->bt_coexist.BT_CoexistType =3D=3D BT_CSR_BC8))) {
+		bRet =3D false;
+		pHalData->bt_coexist.lastBtEdca =3D 0;
+		return bRet;
+	}
+
+	if (BT_1Ant(padapter)) {
+		bRet =3D false;
+		pHalData->bt_coexist.lastBtEdca =3D 0;
+		return bRet;
+	}
+
+	if (pHalData->bt_coexist.exec_cnt < 3)
+		pHalData->bt_coexist.exec_cnt++;
+	else
+		pHalData->bt_coexist.bEDCAInitialized =3D true;
+
+	/*  When BT is non idle */
+	if (!(pHalData->bt_coexist.CurrentState & BT_COEX_STATE_BT_IDLE)) {
+		RTPRINT(FBT, BT_TRACE, ("BT state non idle, set bt EDCA\n"));
+
+		/* aggr_num =3D 0x0909; */
+		if (pHalData->odmpriv.DM_EDCA_Table.bCurrentTurboEDCA) {
+			bBtChangeEDCA =3D true;
+			pHalData->odmpriv.DM_EDCA_Table.bCurrentTurboEDCA =3D false;
+			pHalData->dmpriv.prv_traffic_idx =3D 3;
+		}
+		cur_EDCA_reg =3D rtw_read32(padapter, REG_EDCA_BE_PARAM);
+
+		if (cur_EDCA_reg !=3D EDCA_BT_BE)
+			bBtChangeEDCA =3D true;
+		if (bBtChangeEDCA || !pHalData->bt_coexist.bEDCAInitialized) {
+			rtw_write32(padapter, REG_EDCA_BE_PARAM, EDCA_BT_BE);
+			pHalData->bt_coexist.lastBtEdca =3D EDCA_BT_BE;
+		}
+		bRet =3D true;
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("BT state idle, set original EDCA\n"));
+		pHalData->bt_coexist.lastBtEdca =3D 0;
+		bRet =3D false;
+	}
+	return bRet;
+}
+
+void
+BTDM_Balance(
+	struct rtw_adapter *padapter,
+	u8 bBalanceOn,
+	u8 ms0,
+	u8 ms1
+	)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u8 H2C_Parameter[3] =3D {0};
+
+	if (bBalanceOn) {
+		H2C_Parameter[2] =3D 1;
+		H2C_Parameter[1] =3D ms1;
+		H2C_Parameter[0] =3D ms0;
+		pHalData->bt_coexist.bFWCoexistAllOff =3D false;
+	} else {
+		H2C_Parameter[2] =3D 0;
+		H2C_Parameter[1] =3D 0;
+		H2C_Parameter[0] =3D 0;
+	}
+	pHalData->bt_coexist.bBalanceOn =3D bBalanceOn;
+
+	RTPRINT(FBT, BT_TRACE, ("[DM][BT], Balance =3D[%s:%dms:%dms], write 0=
xc =3D 0x%x\n",
+		bBalanceOn?"ON":"OFF", ms0, ms1,
+		H2C_Parameter[0]<<16|H2C_Parameter[1]<<8|H2C_Parameter[2]));
+
+	FillH2CCmd(padapter, 0xc, 3, H2C_Parameter);
+}
+
+void BTDM_AGCTable(struct rtw_adapter *padapter, u8 type)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	if (type =3D=3D BT_AGCTABLE_OFF) {
+		RTPRINT(FBT, BT_TRACE, ("[BT]AGCTable Off!\n"));
+		rtw_write32(padapter, 0xc78, 0x641c0001);
+		rtw_write32(padapter, 0xc78, 0x631d0001);
+		rtw_write32(padapter, 0xc78, 0x621e0001);
+		rtw_write32(padapter, 0xc78, 0x611f0001);
+		rtw_write32(padapter, 0xc78, 0x60200001);
+
+		PHY_SetRFReg(padapter, PathA, RF_RX_AGC_HP, bRFRegOffsetMask, 0x3200=
0);
+		PHY_SetRFReg(padapter, PathA, RF_RX_AGC_HP, bRFRegOffsetMask, 0x7100=
0);
+		PHY_SetRFReg(padapter, PathA, RF_RX_AGC_HP, bRFRegOffsetMask, 0xb000=
0);
+		PHY_SetRFReg(padapter, PathA, RF_RX_AGC_HP, bRFRegOffsetMask, 0xfc00=
0);
+		PHY_SetRFReg(padapter, PathA, RF_RX_G1, bRFRegOffsetMask, 0x30355);
+
+		pHalData->bt_coexist.b8723aAgcTableOn =3D false;
+	} else if (type =3D=3D BT_AGCTABLE_ON) {
+		RTPRINT(FBT, BT_TRACE, ("[BT]AGCTable On!\n"));
+		rtw_write32(padapter, 0xc78, 0x4e1c0001);
+		rtw_write32(padapter, 0xc78, 0x4d1d0001);
+		rtw_write32(padapter, 0xc78, 0x4c1e0001);
+		rtw_write32(padapter, 0xc78, 0x4b1f0001);
+		rtw_write32(padapter, 0xc78, 0x4a200001);
+
+		PHY_SetRFReg(padapter, PathA, RF_RX_AGC_HP, bRFRegOffsetMask, 0xdc00=
0);
+		PHY_SetRFReg(padapter, PathA, RF_RX_AGC_HP, bRFRegOffsetMask, 0x9000=
0);
+		PHY_SetRFReg(padapter, PathA, RF_RX_AGC_HP, bRFRegOffsetMask, 0x5100=
0);
+		PHY_SetRFReg(padapter, PathA, RF_RX_AGC_HP, bRFRegOffsetMask, 0x1200=
0);
+		PHY_SetRFReg(padapter, PathA, RF_RX_G1, bRFRegOffsetMask, 0x00355);
+
+		pHalData->bt_coexist.b8723aAgcTableOn =3D true;
+
+		pHalData->bt_coexist.bSWCoexistAllOff =3D false;
+	}
+}
+
+void BTDM_BBBackOffLevel(struct rtw_adapter *padapter, u8 type)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (type =3D=3D BT_BB_BACKOFF_OFF) {
+		RTPRINT(FBT, BT_TRACE, ("[BT]BBBackOffLevel Off!\n"));
+		rtw_write32(padapter, 0xc04, 0x3a05611);
+	} else if (type =3D=3D BT_BB_BACKOFF_ON) {
+		RTPRINT(FBT, BT_TRACE, ("[BT]BBBackOffLevel On!\n"));
+		rtw_write32(padapter, 0xc04, 0x3a07611);
+		pHalData->bt_coexist.bSWCoexistAllOff =3D false;
+	}
+}
+
+void BTDM_FWCoexAllOff(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);;
+
+	RTPRINT(FBT, BT_TRACE, ("BTDM_FWCoexAllOff()\n"));
+	if (pHalData->bt_coexist.bFWCoexistAllOff)
+		return;
+	RTPRINT(FBT, BT_TRACE, ("BTDM_FWCoexAllOff(), real Do\n"));
+
+	BTDM_FWCoexAllOff8723A(padapter);
+
+	pHalData->bt_coexist.bFWCoexistAllOff =3D true;
+}
+
+void BTDM_SWCoexAllOff(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);;
+
+	RTPRINT(FBT, BT_TRACE, ("BTDM_SWCoexAllOff()\n"));
+	if (pHalData->bt_coexist.bSWCoexistAllOff)
+		return;
+	RTPRINT(FBT, BT_TRACE, ("BTDM_SWCoexAllOff(), real Do\n"));
+	BTDM_SWCoexAllOff8723A(padapter);
+
+	pHalData->bt_coexist.bSWCoexistAllOff =3D true;
+}
+
+void BTDM_HWCoexAllOff(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);;
+
+	RTPRINT(FBT, BT_TRACE, ("BTDM_HWCoexAllOff()\n"));
+	if (pHalData->bt_coexist.bHWCoexistAllOff)
+		return;
+	RTPRINT(FBT, BT_TRACE, ("BTDM_HWCoexAllOff(), real Do\n"));
+
+	BTDM_HWCoexAllOff8723A(padapter);
+
+	pHalData->bt_coexist.bHWCoexistAllOff =3D true;
+}
+
+void BTDM_CoexAllOff(struct rtw_adapter *padapter)
+{
+	BTDM_FWCoexAllOff(padapter);
+	BTDM_SWCoexAllOff(padapter);
+	BTDM_HWCoexAllOff(padapter);
+}
+
+void BTDM_TurnOffBtCoexistBeforeEnterIPS(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct pwrctrl_priv *ppwrctrl =3D &padapter->pwrctrlpriv;
+
+	if (!pHalData->bt_coexist.BluetoothCoexist)
+		return;
+
+	/*  8723 1Ant doesn't need to turn off bt coexist mechanism. */
+	if (BTDM_1Ant8723A(padapter))
+		return;
+
+	/*  Before enter IPS, turn off FW BT Co-exist mechanism */
+	if (ppwrctrl->reg_rfoff =3D=3D rf_on) {
+		RTPRINT(FBT, BT_TRACE, ("[BT][DM], Before enter IPS, turn off all Co=
exist DM\n"));
+		btdm_ResetFWCoexState(padapter);
+		BTDM_CoexAllOff(padapter);
+		BTDM_SetAntenna(padapter, BTDM_ANT_BT);
+	}
+}
+
+void BTDM_SignalCompensation(struct rtw_adapter *padapter, u8 *rssi_wi=
fi, u8 *rssi_bt)
+{
+	BTDM_8723ASignalCompensation(padapter, rssi_wifi, rssi_bt);
+}
+
+void BTDM_Coexist(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (!pHalData->bt_coexist.BluetoothCoexist) {
+		RTPRINT(FBT, BT_TRACE, ("[DM][BT], BT not exists!!\n"));
+		return;
+	}
+
+	if (!pHalData->bt_coexist.bInitlized) {
+		RTPRINT(FBT, BT_TRACE, ("[DM][BT], btdm_InitBtCoexistDM()\n"));
+		btdm_InitBtCoexistDM(padapter);
+	}
+
+	RTPRINT(FBT, BT_TRACE, ("\n\n[DM][BT], BTDM start!!\n"));
+
+	BTDM_PWDBMonitor(padapter);
+
+	RTPRINT(FBT, BT_TRACE, ("[DM][BT], HW type is 8723\n"));
+	BTDM_BTCoexist8723A(padapter);
+	RTPRINT(FBT, BT_TRACE, ("[DM][BT], BTDM end!!\n\n"));
+}
+
+void BTDM_UpdateCoexState(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (!BTDM_IsSameCoexistState(padapter)) {
+		RTPRINT(FBT, BT_TRACE, ("[BTCoex], Coexist State[bitMap] change from=
 0x%"i64fmt"x to 0x%"i64fmt"x,  changeBits =3D 0x%"i64fmt"x\n",
+			pHalData->bt_coexist.PreviousState,
+			pHalData->bt_coexist.CurrentState,
+			(pHalData->bt_coexist.PreviousState^pHalData->bt_coexist.CurrentSta=
te)));
+		pHalData->bt_coexist.PreviousState =3D pHalData->bt_coexist.CurrentS=
tate;
+	}
+}
+
+u8 BTDM_IsSameCoexistState(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (pHalData->bt_coexist.PreviousState =3D=3D pHalData->bt_coexist.Cu=
rrentState) {
+		return true;
+	} else {
+		RTPRINT(FBT, BT_TRACE, ("[DM][BT], Coexist state changed!!\n"));
+		return false;
+	}
+}
+
+void BTDM_PWDBMonitor(struct rtw_adapter *padapter)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(GetDefaultAdapter(padapter)=
);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u8 H2C_Parameter[3] =3D {0};
+	s32 tmpBTEntryMaxPWDB =3D 0, tmpBTEntryMinPWDB =3D 0xff;
+	u8 i;
+
+	if (pBtMgnt->BtOperationOn) {
+		for (i =3D 0; i < MAX_BT_ASOC_ENTRY_NUM; i++) {
+			if (pBTInfo->BtAsocEntry[i].bUsed) {
+				if (pBTInfo->BtAsocEntry[i].UndecoratedSmoothedPWDB < tmpBTEntryMi=
nPWDB)
+					tmpBTEntryMinPWDB =3D pBTInfo->BtAsocEntry[i].UndecoratedSmoothed=
PWDB;
+				if (pBTInfo->BtAsocEntry[i].UndecoratedSmoothedPWDB > tmpBTEntryMa=
xPWDB)
+					tmpBTEntryMaxPWDB =3D pBTInfo->BtAsocEntry[i].UndecoratedSmoothed=
PWDB;
+				/*  Report every BT connection (HS mode) RSSI to FW */
+				H2C_Parameter[2] =3D (u8)(pBTInfo->BtAsocEntry[i].UndecoratedSmoot=
hedPWDB & 0xFF);
+				H2C_Parameter[0] =3D (MAX_FW_SUPPORT_MACID_NUM-1-i);
+				RTPRINT(FDM, DM_BT30, ("RSSI report for BT[%d], H2C_Par =3D 0x%x\n=
", i, H2C_Parameter[0]));
+				FillH2CCmd(padapter, RSSI_SETTING_EID, 3, H2C_Parameter);
+				RTPRINT_ADDR(FDM, (DM_PWDB|DM_BT30), ("BT_Entry Mac :"),
+					     pBTInfo->BtAsocEntry[i].BTRemoteMACAddr)
+				RTPRINT(FDM, (DM_PWDB|DM_BT30),
+					("BT rx pwdb[%d] =3D 0x%x(%d)\n", i,
+					pBTInfo->BtAsocEntry[i].UndecoratedSmoothedPWDB,
+					pBTInfo->BtAsocEntry[i].UndecoratedSmoothedPWDB));
+			}
+		}
+		if (tmpBTEntryMaxPWDB !=3D 0) {	/*  If associated entry is found */
+			pHalData->dmpriv.BT_EntryMaxUndecoratedSmoothedPWDB =3D tmpBTEntryM=
axPWDB;
+			RTPRINT(FDM, (DM_PWDB|DM_BT30), ("BT_EntryMaxPWDB =3D 0x%x(%d)\n",
+				tmpBTEntryMaxPWDB, tmpBTEntryMaxPWDB));
+		} else {
+			pHalData->dmpriv.BT_EntryMaxUndecoratedSmoothedPWDB =3D 0;
+		}
+		if (tmpBTEntryMinPWDB !=3D 0xff) { /*  If associated entry is found =
*/
+			pHalData->dmpriv.BT_EntryMinUndecoratedSmoothedPWDB =3D tmpBTEntryM=
inPWDB;
+			RTPRINT(FDM, (DM_PWDB|DM_BT30), ("BT_EntryMinPWDB =3D 0x%x(%d)\n",
+				tmpBTEntryMinPWDB, tmpBTEntryMinPWDB));
+		} else {
+			pHalData->dmpriv.BT_EntryMinUndecoratedSmoothedPWDB =3D 0;
+		}
+	}
+}
+
+u8 BTDM_IsBTBusy(struct rtw_adapter *padapter)
+{
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_mgnt *pBtMgnt =3D &pBTInfo->BtMgnt;
+
+	if (pBtMgnt->ExtConfig.bBTBusy)
+		return true;
+	else
+		return false;
+}
+
+u8 BTDM_IsWifiBusy(struct rtw_adapter *padapter)
+{
+/*PMGNT_INFO		pMgntInfo =3D &GetDefaultAdapter(padapter)->MgntInfo; */
+	struct mlme_priv *pmlmepriv =3D &GetDefaultAdapter(padapter)->mlmepri=
v;
+	struct bt_30info *pBTInfo =3D GET_BT_INFO(padapter);
+	struct bt_traffic *pBtTraffic =3D &pBTInfo->BtTraffic;
+
+	if (pmlmepriv->LinkDetectInfo.bBusyTraffic ||
+		pBtTraffic->Bt30TrafficStatistics.bTxBusyTraffic ||
+		pBtTraffic->Bt30TrafficStatistics.bRxBusyTraffic)
+		return true;
+	else
+		return false;
+}
+
+u8 BTDM_IsCoexistStateChanged(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (pHalData->bt_coexist.PreviousState =3D=3D pHalData->bt_coexist.Cu=
rrentState)
+		return false;
+	else
+		return true;
+}
+
+u8 BTDM_IsWifiUplink(struct rtw_adapter *padapter)
+{
+/*PMGNT_INFO		pMgntInfo =3D &GetDefaultAdapter(padapter)->MgntInfo; */
+	struct mlme_priv *pmlmepriv;
+	struct bt_30info *pBTInfo;
+	struct bt_traffic *pBtTraffic;
+
+	pmlmepriv =3D &padapter->mlmepriv;
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtTraffic =3D &pBTInfo->BtTraffic;
+
+	if ((pmlmepriv->LinkDetectInfo.bTxBusyTraffic) ||
+		(pBtTraffic->Bt30TrafficStatistics.bTxBusyTraffic))
+		return true;
+	else
+		return false;
+}
+
+u8 BTDM_IsWifiDownlink(struct rtw_adapter *padapter)
+{
+/*PMGNT_INFO		pMgntInfo =3D &GetDefaultAdapter(padapter)->MgntInfo; */
+	struct mlme_priv *pmlmepriv;
+	struct bt_30info *pBTInfo;
+	struct bt_traffic *pBtTraffic;
+
+	pmlmepriv =3D &padapter->mlmepriv;
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtTraffic =3D &pBTInfo->BtTraffic;
+
+	if ((pmlmepriv->LinkDetectInfo.bRxBusyTraffic) ||
+		(pBtTraffic->Bt30TrafficStatistics.bRxBusyTraffic))
+		return true;
+	else
+		return false;
+}
+
+u8 BTDM_IsBTHSMode(struct rtw_adapter *padapter)
+{
+/*PMGNT_INFO		pMgntInfo =3D &GetDefaultAdapter(padapter)->MgntInfo; */
+	struct hal_data_8723a *pHalData;
+	struct bt_mgnt *pBtMgnt;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBtMgnt =3D &pHalData->BtInfo.BtMgnt;
+
+	if (pBtMgnt->BtOperationOn)
+		return true;
+	else
+		return false;
+}
+
+u8 BTDM_IsBTUplink(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (pHalData->bt_coexist.BT21TrafficStatistics.bTxBusyTraffic)
+		return true;
+	else
+		return false;
+}
+
+u8 BTDM_IsBTDownlink(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (pHalData->bt_coexist.BT21TrafficStatistics.bRxBusyTraffic)
+		return true;
+	else
+		return false;
+}
+
+void BTDM_AdjustForBtOperation(struct rtw_adapter *padapter)
+{
+	RTPRINT(FBT, BT_TRACE, ("[BT][DM], BTDM_AdjustForBtOperation()\n"));
+	BTDM_AdjustForBtOperation8723A(padapter);
+}
+
+void BTDM_SetBtCoexCurrAntNum(struct rtw_adapter *padapter, u8 antNum)
+{
+	BTDM_Set8723ABtCoexCurrAntNum(padapter, antNum);
+}
+
+void BTDM_ForHalt(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (!pHalData->bt_coexist.BluetoothCoexist)
+		return;
+
+	BTDM_ForHalt8723A(padapter);
+	GET_HAL_DATA(padapter)->bt_coexist.bInitlized =3D false;
+}
+
+void BTDM_WifiScanNotify(struct rtw_adapter *padapter, u8 scanType)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (!pHalData->bt_coexist.BluetoothCoexist)
+		return;
+
+	BTDM_WifiScanNotify8723A(padapter, scanType);
+}
+
+void BTDM_WifiAssociateNotify(struct rtw_adapter *padapter, u8 action)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (!pHalData->bt_coexist.BluetoothCoexist)
+		return;
+
+	BTDM_WifiAssociateNotify8723A(padapter, action);
+}
+
+void BTDM_MediaStatusNotify(struct rtw_adapter *padapter, enum rt_medi=
a_status mstatus)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (!pHalData->bt_coexist.BluetoothCoexist)
+		return;
+
+	BTDM_MediaStatusNotify8723A(padapter, mstatus);
+}
+
+void BTDM_ForDhcp(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (!pHalData->bt_coexist.BluetoothCoexist)
+		return;
+
+	BTDM_ForDhcp8723A(padapter);
+}
+
+void BTDM_ResetActionProfileState(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	pHalData->bt_coexist.CurrentState &=3D ~\
+		(BT_COEX_STATE_PROFILE_HID|BT_COEX_STATE_PROFILE_A2DP|
+		BT_COEX_STATE_PROFILE_PAN|BT_COEX_STATE_PROFILE_SCO);
+}
+
+u8 BTDM_IsActionSCO(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	struct bt_30info *pBTInfo;
+	struct bt_mgnt *pBtMgnt;
+	struct bt_dgb *pBtDbg;
+	u8 bRet;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtMgnt =3D &pBTInfo->BtMgnt;
+	pBtDbg =3D &pBTInfo->BtDbg;
+	bRet =3D false;
+
+	if (pBtDbg->dbgCtrl) {
+		if (pBtDbg->dbgProfile =3D=3D BT_DBG_PROFILE_SCO) {
+			pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_PROFILE_SCO;
+			bRet =3D true;
+		}
+	} else {
+		if (pBtMgnt->ExtConfig.NumberOfSCO > 0) {
+			pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_PROFILE_SCO;
+			bRet =3D true;
+		}
+	}
+	return bRet;
+}
+
+u8 BTDM_IsActionHID(struct rtw_adapter *padapter)
+{
+	struct bt_30info *pBTInfo;
+	struct hal_data_8723a *pHalData;
+	struct bt_mgnt *pBtMgnt;
+	struct bt_dgb *pBtDbg;
+	u8 bRet;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtMgnt =3D &pBTInfo->BtMgnt;
+	pBtDbg =3D &pBTInfo->BtDbg;
+	bRet =3D false;
+
+	if (pBtDbg->dbgCtrl) {
+		if (pBtDbg->dbgProfile =3D=3D BT_DBG_PROFILE_HID) {
+			pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_PROFILE_HID;
+			bRet =3D true;
+		}
+	} else {
+		if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_HID) &&
+		    pBtMgnt->ExtConfig.NumberOfHandle =3D=3D 1) {
+			pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_PROFILE_HID;
+			bRet =3D true;
+		}
+	}
+	return bRet;
+}
+
+u8 BTDM_IsActionA2DP(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	struct bt_30info *pBTInfo;
+	struct bt_mgnt *pBtMgnt;
+	struct bt_dgb *pBtDbg;
+	u8 bRet;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtMgnt =3D &pBTInfo->BtMgnt;
+	pBtDbg =3D &pBTInfo->BtDbg;
+	bRet =3D false;
+
+	if (pBtDbg->dbgCtrl) {
+		if (pBtDbg->dbgProfile =3D=3D BT_DBG_PROFILE_A2DP) {
+			pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_PROFILE_A2DP;
+			bRet =3D true;
+		}
+	} else {
+		if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_A2DP) &&
+		    pBtMgnt->ExtConfig.NumberOfHandle =3D=3D 1) {
+			pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_PROFILE_A2DP;
+			bRet =3D true;
+		}
+	}
+	return bRet;
+}
+
+u8 BTDM_IsActionPAN(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	struct bt_30info *pBTInfo;
+	struct bt_mgnt *pBtMgnt;
+	struct bt_dgb *pBtDbg;
+	u8 bRet;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtMgnt =3D &pBTInfo->BtMgnt;
+	pBtDbg =3D &pBTInfo->BtDbg;
+	bRet =3D false;
+
+	if (pBtDbg->dbgCtrl) {
+		if (pBtDbg->dbgProfile =3D=3D BT_DBG_PROFILE_PAN) {
+			pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_PROFILE_PAN;
+			bRet =3D true;
+		}
+	} else {
+		if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_PAN) &&
+		    pBtMgnt->ExtConfig.NumberOfHandle =3D=3D 1) {
+			pHalData->bt_coexist.CurrentState |=3D BT_COEX_STATE_PROFILE_PAN;
+			bRet =3D true;
+		}
+	}
+	return bRet;
+}
+
+u8 BTDM_IsActionHIDA2DP(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	struct bt_30info *pBTInfo;
+	struct bt_mgnt *pBtMgnt;
+	struct bt_dgb *pBtDbg;
+	u8 bRet;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtMgnt =3D &pBTInfo->BtMgnt;
+	pBtDbg =3D &pBTInfo->BtDbg;
+	bRet =3D false;
+
+	if (pBtDbg->dbgCtrl) {
+		if (pBtDbg->dbgProfile =3D=3D BT_DBG_PROFILE_HID_A2DP) {
+			pHalData->bt_coexist.CurrentState |=3D (BT_COEX_STATE_PROFILE_HID|B=
T_COEX_STATE_PROFILE_A2DP);
+			bRet =3D true;
+		}
+	} else {
+		if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_HID) &&
+		    BTHCI_CheckProfileExist(padapter, BT_PROFILE_A2DP)) {
+			pHalData->bt_coexist.CurrentState |=3D (BT_COEX_STATE_PROFILE_HID|B=
T_COEX_STATE_PROFILE_A2DP);
+			bRet =3D true;
+		}
+	}
+	return bRet;
+}
+
+u8 BTDM_IsActionHIDPAN(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	struct bt_30info *pBTInfo;
+	struct bt_dgb *pBtDbg;
+	u8 bRet;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtDbg =3D &pBTInfo->BtDbg;
+	bRet =3D false;
+
+	if (pBtDbg->dbgCtrl) {
+		if (pBtDbg->dbgProfile =3D=3D BT_DBG_PROFILE_HID_PAN) {
+			pHalData->bt_coexist.CurrentState |=3D (BT_COEX_STATE_PROFILE_HID|B=
T_COEX_STATE_PROFILE_PAN);
+			bRet =3D true;
+		}
+	} else {
+		if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_HID) &&
+		    BTHCI_CheckProfileExist(padapter, BT_PROFILE_PAN)) {
+			pHalData->bt_coexist.CurrentState |=3D (BT_COEX_STATE_PROFILE_HID|B=
T_COEX_STATE_PROFILE_PAN);
+			bRet =3D true;
+		}
+	}
+	return bRet;
+}
+
+u8 BTDM_IsActionPANA2DP(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	struct bt_30info *pBTInfo;
+	struct bt_dgb *pBtDbg;
+	u8 bRet;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pBTInfo =3D GET_BT_INFO(padapter);
+	pBtDbg =3D &pBTInfo->BtDbg;
+	bRet =3D false;
+
+	if (pBtDbg->dbgCtrl) {
+		if (pBtDbg->dbgProfile =3D=3D BT_DBG_PROFILE_PAN_A2DP) {
+			pHalData->bt_coexist.CurrentState |=3D (BT_COEX_STATE_PROFILE_PAN|B=
T_COEX_STATE_PROFILE_A2DP);
+			bRet =3D true;
+		}
+	} else {
+		if (BTHCI_CheckProfileExist(padapter, BT_PROFILE_PAN) && BTHCI_Check=
ProfileExist(padapter, BT_PROFILE_A2DP)) {
+			pHalData->bt_coexist.CurrentState |=3D (BT_COEX_STATE_PROFILE_PAN|B=
T_COEX_STATE_PROFILE_A2DP);
+			bRet =3D true;
+		}
+	}
+	return bRet;
+}
+
+u8 BTDM_IsBtDisabled(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (pHalData->bt_coexist.bCurBtDisabled)
+		return true;
+	else
+		return false;
+}
+
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver HAL/BTCoexist/HalBtCoe=
xist.c =3D=3D=3D=3D=3D */
+#endif
+
+#ifdef __HALBT_C__ /*  HAL/HalBT.c */
+/*  =3D=3D=3D=3D=3D Below this line is sync from SD7 driver HAL/HalBT.=
c =3D=3D=3D=3D=3D */
+
+/*  */
+/*local function */
+/*  */
+
+static void halbt_InitHwConfig8723A(struct rtw_adapter *padapter)
+{
+}
+
+/*  */
+/*extern function */
+/*  */
+u8 HALBT_GetPGAntNum(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	return pHalData->bt_coexist.BT_Ant_Num;
+}
+
+void HALBT_SetKey(struct rtw_adapter *padapter, u8 EntryNum)
+{
+	struct bt_30info *pBTinfo;
+	struct bt_asoc_entry *pBtAssocEntry;
+	u16				usConfig =3D 0;
+
+	pBTinfo =3D GET_BT_INFO(padapter);
+	pBtAssocEntry =3D &pBTinfo->BtAsocEntry[EntryNum];
+
+	pBtAssocEntry->HwCAMIndex =3D BT_HWCAM_STAR + EntryNum;
+
+	usConfig =3D CAM_VALID | (CAM_AES << 2);
+	write_cam23a(padapter, pBtAssocEntry->HwCAMIndex, usConfig, pBtAssocE=
ntry->BTRemoteMACAddr, pBtAssocEntry->PTK + TKIP_ENC_KEY_POS);
+}
+
+void HALBT_RemoveKey(struct rtw_adapter *padapter, u8 EntryNum)
+{
+	struct bt_30info *pBTinfo;
+	struct bt_asoc_entry *pBtAssocEntry;
+
+	pBTinfo =3D GET_BT_INFO(padapter);
+	pBtAssocEntry =3D &pBTinfo->BtAsocEntry[EntryNum];
+
+	if (pBTinfo->BtAsocEntry[EntryNum].HwCAMIndex !=3D 0) {
+		/*  ToDo : add New HALBT_RemoveKey function !! */
+		if (pBtAssocEntry->HwCAMIndex >=3D BT_HWCAM_STAR && pBtAssocEntry->H=
wCAMIndex < HALF_CAM_ENTRY)
+			CAM_empty_entry23a(padapter, pBtAssocEntry->HwCAMIndex);
+		pBTinfo->BtAsocEntry[EntryNum].HwCAMIndex =3D 0;
+	}
+}
+
+void HALBT_InitBTVars8723A(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+
+	pHalData->bt_coexist.BluetoothCoexist =3D pHalData->EEPROMBluetoothCo=
exist;
+	pHalData->bt_coexist.BT_Ant_Num =3D pHalData->EEPROMBluetoothAntNum;
+	pHalData->bt_coexist.BT_CoexistType =3D pHalData->EEPROMBluetoothType=
;
+	pHalData->bt_coexist.BT_Ant_isolation =3D pHalData->EEPROMBluetoothAn=
tIsolation;
+	pHalData->bt_coexist.bt_radiosharedtype =3D pHalData->EEPROMBluetooth=
RadioShared;
+
+	RT_TRACE(_module_hal_init_c_, _drv_info_, ("BT Coexistance =3D 0x%x\n=
", pHalData->bt_coexist.BluetoothCoexist));
+	if (pHalData->bt_coexist.BluetoothCoexist) {
+		if (pHalData->bt_coexist.BT_Ant_Num =3D=3D Ant_x2) {
+			BTDM_SetBtCoexCurrAntNum(padapter, 2);
+			RT_TRACE(_module_hal_init_c_, _drv_info_, ("BlueTooth BT_Ant_Num =3D=
 Antx2\n"));
+		} else if (pHalData->bt_coexist.BT_Ant_Num =3D=3D Ant_x1) {
+			BTDM_SetBtCoexCurrAntNum(padapter, 1);
+			RT_TRACE(_module_hal_init_c_, _drv_info_, ("BlueTooth BT_Ant_Num =3D=
 Antx1\n"));
+		}
+		pHalData->bt_coexist.bBTBusyTraffic =3D false;
+		pHalData->bt_coexist.bBTTrafficModeSet =3D false;
+		pHalData->bt_coexist.bBTNonTrafficModeSet =3D false;
+		pHalData->bt_coexist.CurrentState =3D 0;
+		pHalData->bt_coexist.PreviousState =3D 0;
+
+		RT_TRACE(_module_hal_init_c_, _drv_info_,
+			 ("bt_radiosharedType =3D 0x%x\n",
+			 pHalData->bt_coexist.bt_radiosharedtype));
+	}
+}
+
+u8 HALBT_IsBTExist(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (pHalData->bt_coexist.BluetoothCoexist)
+		return true;
+	else
+		return false;
+}
+
+u8 HALBT_BTChipType(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	return pHalData->bt_coexist.BT_CoexistType;
+}
+
+void HALBT_InitHwConfig(struct rtw_adapter *padapter)
+{
+	halbt_InitHwConfig8723A(padapter);
+	BTDM_Coexist(padapter);
+}
+
+void HALBT_SetRtsCtsNoLenLimit(struct rtw_adapter *padapter)
+{
+}
+
+/*  =3D=3D=3D=3D=3D End of sync from SD7 driver HAL/HalBT.c =3D=3D=3D=3D=
=3D */
+#endif
diff --git a/drivers/staging/rtl8723au/hal/rtl8723a_cmd.c b/drivers/sta=
ging/rtl8723au/hal/rtl8723a_cmd.c
new file mode 100644
index 0000000..0b205e1
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/rtl8723a_cmd.c
@@ -0,0 +1,845 @@
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
+#define _RTL8723A_CMD_C_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <recv_osdep.h>
+#include <cmd_osdep.h>
+#include <mlme_osdep.h>
+#include <rtw_ioctl_set.h>
+#include <rtl8723a_hal.h>
+
+#define RTL92C_MAX_H2C_BOX_NUMS		4
+#define RTL92C_MAX_CMD_LEN		5
+#define MESSAGE_BOX_SIZE		4
+#define EX_MESSAGE_BOX_SIZE		2
+
+static u8 _is_fw_read_cmd_down(struct rtw_adapter *padapter, u8 msgbox=
_num)
+{
+	u8 read_down =3D false;
+	int	retry_cnts =3D 100;
+	u8 valid;
+
+	do {
+		valid =3D rtw_read8(padapter, REG_HMETFR) & BIT(msgbox_num);
+		if (0 =3D=3D valid)
+			read_down =3D true;
+	} while ((!read_down) && (retry_cnts--));
+
+	return read_down;
+}
+
+/*****************************************
+* H2C Msg format :
+*| 31 - 8		|7		| 6 - 0	|
+*| h2c_msg	|Ext_bit	|CMD_ID	|
+*
+******************************************/
+s32 FillH2CCmd(struct rtw_adapter *padapter, u8 ElementID, u32 CmdLen,=
 u8 *pCmdBuffer)
+{
+	u8 bcmd_down =3D false;
+	s32 retry_cnts =3D 100;
+	u8 h2c_box_num;
+	u32 msgbox_addr;
+	u32 msgbox_ex_addr;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u32 h2c_cmd =3D 0;
+	u16 h2c_cmd_ex =3D 0;
+	s32 ret =3D _FAIL;
+
+	padapter =3D GET_PRIMARY_ADAPTER(padapter);
+	pHalData =3D GET_HAL_DATA(padapter);
+
+	mutex_lock(&adapter_to_dvobj(padapter)->h2c_fwcmd_mutex);
+
+	if (!pCmdBuffer)
+		goto exit;
+	if (CmdLen > RTL92C_MAX_CMD_LEN)
+		goto exit;
+	if (padapter->bSurpriseRemoved =3D=3D true)
+		goto exit;
+
+	/* pay attention to if  race condition happened in  H2C cmd setting. =
*/
+	do {
+		h2c_box_num =3D pHalData->LastHMEBoxNum;
+
+		if (!_is_fw_read_cmd_down(padapter, h2c_box_num)) {
+			DBG_8723A(" fw read cmd failed...\n");
+			goto exit;
+		}
+
+		if (CmdLen <=3D 3) {
+			memcpy((u8 *)(&h2c_cmd)+1, pCmdBuffer, CmdLen);
+		} else {
+			memcpy((u8 *)(&h2c_cmd_ex), pCmdBuffer, EX_MESSAGE_BOX_SIZE);
+			memcpy((u8 *)(&h2c_cmd)+1, pCmdBuffer+2, (CmdLen-EX_MESSAGE_BOX_SIZ=
E));
+			*(u8 *)(&h2c_cmd) |=3D BIT(7);
+		}
+
+		*(u8 *)(&h2c_cmd) |=3D ElementID;
+
+		if (h2c_cmd & BIT(7)) {
+			msgbox_ex_addr =3D REG_HMEBOX_EXT_0 + (h2c_box_num * EX_MESSAGE_BOX=
_SIZE);
+			h2c_cmd_ex =3D le16_to_cpu(h2c_cmd_ex);
+			rtw_write16(padapter, msgbox_ex_addr, h2c_cmd_ex);
+		}
+		msgbox_addr =3D REG_HMEBOX_0 + (h2c_box_num * MESSAGE_BOX_SIZE);
+		h2c_cmd =3D le32_to_cpu(h2c_cmd);
+		rtw_write32(padapter, msgbox_addr, h2c_cmd);
+
+		bcmd_down =3D true;
+
+		pHalData->LastHMEBoxNum =3D (h2c_box_num+1) % RTL92C_MAX_H2C_BOX_NUM=
S;
+
+	} while ((!bcmd_down) && (retry_cnts--));
+
+	ret =3D _SUCCESS;
+
+exit:
+	mutex_unlock(&adapter_to_dvobj(padapter)->h2c_fwcmd_mutex);
+	return ret;
+}
+
+u8 rtl8723a_set_rssi_cmd(struct rtw_adapter *padapter, u8 *param)
+{
+	u8 res =3D _SUCCESS;
+
+	*((u32 *)param) =3D cpu_to_le32(*((u32 *)param));
+
+	FillH2CCmd(padapter, RSSI_SETTING_EID, 3, param);
+
+	return res;
+}
+
+u8 rtl8723a_set_raid_cmd(struct rtw_adapter *padapter, u32 mask, u8 ar=
g)
+{
+	u8 buf[5];
+	u8 res =3D _SUCCESS;
+
+	memset(buf, 0, 5);
+	mask =3D cpu_to_le32(mask);
+	memcpy(buf, &mask, 4);
+	buf[4]  =3D arg;
+
+	FillH2CCmd(padapter, MACID_CONFIG_EID, 5, buf);
+
+	return res;
+
+}
+
+/* bitmap[0:27] =3D tx_rate_bitmap */
+/* bitmap[28:31]=3D Rate Adaptive id */
+/* arg[0:4] =3D macid */
+/* arg[5] =3D Short GI */
+void rtl8723a_add_rateatid(struct rtw_adapter *pAdapter, u32 bitmap, u=
8 arg, u8 rssi_level)
+{
+	struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(pAdapter);
+	u8 macid =3D arg&0x1f;
+	u8 raid =3D (bitmap>>28) & 0x0f;
+
+	bitmap &=3D 0x0fffffff;
+	if (rssi_level !=3D DM_RATR_STA_INIT)
+		bitmap =3D ODM_Get_Rate_Bitmap23a(&pHalData->odmpriv, macid, bitmap,=
 rssi_level);
+
+	bitmap |=3D ((raid<<28)&0xf0000000);
+
+	if (pHalData->fw_ractrl =3D=3D true) {
+		rtl8723a_set_raid_cmd(pAdapter, bitmap, arg);
+	} else {
+		u8 init_rate, shortGIrate =3D false;
+
+		init_rate =3D get_highest_rate_idx23a(bitmap&0x0fffffff)&0x3f;
+
+		shortGIrate =3D (arg&BIT(5)) ? true:false;
+
+		if (shortGIrate =3D=3D true)
+			init_rate |=3D BIT(6);
+
+		rtw_write8(pAdapter, (REG_INIDATA_RATE_SEL+macid), (u8)init_rate);
+	}
+}
+
+void rtl8723a_set_FwPwrMode_cmd(struct rtw_adapter *padapter, u8 Mode)
+{
+	struct setpwrmode_parm H2CSetPwrMode;
+	struct pwrctrl_priv *pwrpriv =3D &padapter->pwrctrlpriv;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	DBG_8723A("%s: Mode =3D%d SmartPS =3D%d UAPSD =3D%d BcnMode =3D 0x%02=
x\n", __FUNCTION__,
+			Mode, pwrpriv->smart_ps, padapter->registrypriv.uapsd_enable, pwrpr=
iv->bcn_ant_mode);
+
+	/*  Forece leave RF low power mode for 1T1R to
+	    prevent conficting setting in Fw power */
+	/*  saving sequence. 2010.06.07. Added by tynli.
+	    Suggested by SD3 yschang. */
+	if ((Mode !=3D PS_MODE_ACTIVE) &&
+	    (!IS_92C_SERIAL(pHalData->VersionID))) {
+		ODM_RF_Saving23a(&pHalData->odmpriv, true);
+	}
+
+	H2CSetPwrMode.Mode =3D Mode;
+	H2CSetPwrMode.SmartPS =3D pwrpriv->smart_ps;
+	H2CSetPwrMode.AwakeInterval =3D 1;
+	H2CSetPwrMode.bAllQueueUAPSD =3D padapter->registrypriv.uapsd_enable;
+	H2CSetPwrMode.BcnAntMode =3D pwrpriv->bcn_ant_mode;
+
+	FillH2CCmd(padapter, SET_PWRMODE_EID, sizeof(H2CSetPwrMode), (u8 *)&H=
2CSetPwrMode);
+
+}
+
+static void ConstructBeacon(struct rtw_adapter *padapter, u8 *pframe, =
u32 *pLength)
+{
+	struct ieee80211_hdr *pwlanhdr;
+	u16 *fctrl;
+	u32 rate_len, pktlen;
+	struct mlme_ext_priv *pmlmeext =3D &padapter->mlmeextpriv;
+	struct mlme_ext_info *pmlmeinfo =3D &pmlmeext->mlmext_info;
+	struct wlan_bssid_ex *cur_network =3D &pmlmeinfo->network;
+	u8 bc_addr[] =3D {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
+
+	/* DBG_8723A("%s\n", __FUNCTION__); */
+
+	pwlanhdr =3D (struct ieee80211_hdr *)pframe;
+
+	fctrl =3D &pwlanhdr->frame_control;
+	*(fctrl) =3D 0;
+
+	memcpy(pwlanhdr->addr1, bc_addr, ETH_ALEN);
+	memcpy(pwlanhdr->addr2, myid(&padapter->eeprompriv), ETH_ALEN);
+	memcpy(pwlanhdr->addr3, get_my_bssid23a(cur_network), ETH_ALEN);
+
+	SetSeqNum(pwlanhdr, 0/*pmlmeext->mgnt_seq*/);
+	/* pmlmeext->mgnt_seq++; */
+	SetFrameSubType(pframe, WIFI_BEACON);
+
+	pframe +=3D sizeof(struct ieee80211_hdr_3addr);
+	pktlen =3D sizeof (struct ieee80211_hdr_3addr);
+
+	/* timestamp will be inserted by hardware */
+	pframe +=3D 8;
+	pktlen +=3D 8;
+
+	/*  beacon interval: 2 bytes */
+	memcpy(pframe, (unsigned char *)(rtw_get_beacon_interval23a_from_ie(c=
ur_network->IEs)), 2);
+
+	pframe +=3D 2;
+	pktlen +=3D 2;
+
+	/*  capability info: 2 bytes */
+	memcpy(pframe, (unsigned char *)(rtw_get_capability23a_from_ie(cur_ne=
twork->IEs)), 2);
+
+	pframe +=3D 2;
+	pktlen +=3D 2;
+
+	if ((pmlmeinfo->state&0x03) =3D=3D WIFI_FW_AP_STATE) {
+		/* DBG_8723A("ie len =3D%d\n", cur_network->IELength); */
+		pktlen +=3D cur_network->IELength - sizeof(struct ndis_802_11_fixed_=
ies);
+		memcpy(pframe, cur_network->IEs+sizeof(struct ndis_802_11_fixed_ies)=
, pktlen);
+
+		goto _ConstructBeacon;
+	}
+
+	/* below for ad-hoc mode */
+
+	/*  SSID */
+	pframe =3D rtw_set_ie23a(pframe, _SSID_IE_, cur_network->Ssid.ssid_le=
n,
+			    cur_network->Ssid.ssid, &pktlen);
+
+	/*  supported rates... */
+	rate_len =3D rtw_get_rateset_len23a(cur_network->SupportedRates);
+	pframe =3D rtw_set_ie23a(pframe, _SUPPORTEDRATES_IE_, ((rate_len > 8)=
 ?
+			       8 : rate_len), cur_network->SupportedRates, &pktlen);
+
+	/*  DS parameter set */
+	pframe =3D rtw_set_ie23a(pframe, _DSSET_IE_, 1, (unsigned char *)&cur=
_network->Configuration.DSConfig, &pktlen);
+
+	if ((pmlmeinfo->state&0x03) =3D=3D WIFI_FW_ADHOC_STATE) {
+		u32 ATIMWindow;
+		/*  IBSS Parameter Set... */
+		/* ATIMWindow =3D cur->Configuration.ATIMWindow; */
+		ATIMWindow =3D 0;
+		pframe =3D rtw_set_ie23a(pframe, _IBSS_PARA_IE_, 2, (unsigned char *=
)(&ATIMWindow), &pktlen);
+	}
+
+	/* todo: ERP IE */
+
+	/*  EXTERNDED SUPPORTED RATE */
+	if (rate_len > 8)
+		pframe =3D rtw_set_ie23a(pframe, _EXT_SUPPORTEDRATES_IE_, (rate_len =
- 8), (cur_network->SupportedRates + 8), &pktlen);
+
+	/* todo:HT for adhoc */
+
+_ConstructBeacon:
+
+	if ((pktlen + TXDESC_SIZE) > 512) {
+		DBG_8723A("beacon frame too large\n");
+		return;
+	}
+
+	*pLength =3D pktlen;
+
+	/* DBG_8723A("%s bcn_sz =3D%d\n", __FUNCTION__, pktlen); */
+
+}
+
+static void ConstructPSPoll(struct rtw_adapter *padapter, u8 *pframe, =
u32 *pLength)
+{
+	struct ieee80211_hdr *pwlanhdr;
+	u16 *fctrl;
+	struct mlme_ext_priv *pmlmeext =3D &padapter->mlmeextpriv;
+	struct mlme_ext_info *pmlmeinfo =3D &pmlmeext->mlmext_info;
+
+	pwlanhdr =3D (struct ieee80211_hdr *)pframe;
+
+	/*  Frame control. */
+	fctrl =3D &pwlanhdr->frame_control;
+	*(fctrl) =3D 0;
+	SetPwrMgt(fctrl);
+	SetFrameSubType(pframe, WIFI_PSPOLL);
+
+	/*  AID. */
+	SetDuration(pframe, (pmlmeinfo->aid | 0xc000));
+
+	/*  BSSID. */
+	memcpy(pwlanhdr->addr1, get_my_bssid23a(&pmlmeinfo->network), ETH_ALE=
N);
+
+	/*  TA. */
+	memcpy(pwlanhdr->addr2, myid(&padapter->eeprompriv), ETH_ALEN);
+
+	*pLength =3D 16;
+}
+
+static void ConstructNullFunctionData(
+	struct rtw_adapter *padapter,
+	u8 *pframe,
+	u32 *pLength,
+	u8 *StaAddr,
+	u8 bQoS,
+	u8 AC,
+	u8 bEosp,
+	u8 bForcePowerSave)
+{
+	struct ieee80211_hdr *pwlanhdr;
+	u16 *fctrl;
+	u32 pktlen;
+	struct mlme_priv *pmlmepriv =3D &padapter->mlmepriv;
+	struct wlan_network		*cur_network =3D &pmlmepriv->cur_network;
+	struct mlme_ext_priv *pmlmeext =3D &padapter->mlmeextpriv;
+	struct mlme_ext_info *pmlmeinfo =3D &pmlmeext->mlmext_info;
+
+	pwlanhdr =3D (struct ieee80211_hdr *)pframe;
+
+	fctrl =3D &pwlanhdr->frame_control;
+	*(fctrl) =3D 0;
+	if (bForcePowerSave)
+		SetPwrMgt(fctrl);
+
+	switch (cur_network->network.InfrastructureMode) {
+	case Ndis802_11Infrastructure:
+		SetToDs(fctrl);
+		memcpy(pwlanhdr->addr1,
+		       get_my_bssid23a(&pmlmeinfo->network), ETH_ALEN);
+		memcpy(pwlanhdr->addr2, myid(&padapter->eeprompriv),
+		       ETH_ALEN);
+		memcpy(pwlanhdr->addr3, StaAddr, ETH_ALEN);
+		break;
+	case Ndis802_11APMode:
+		SetFrDs(fctrl);
+		memcpy(pwlanhdr->addr1, StaAddr, ETH_ALEN);
+		memcpy(pwlanhdr->addr2,
+		       get_my_bssid23a(&pmlmeinfo->network), ETH_ALEN);
+		memcpy(pwlanhdr->addr3, myid(&padapter->eeprompriv),
+		       ETH_ALEN);
+		break;
+	case Ndis802_11IBSS:
+	default:
+		memcpy(pwlanhdr->addr1, StaAddr, ETH_ALEN);
+		memcpy(pwlanhdr->addr2, myid(&padapter->eeprompriv), ETH_ALEN);
+		memcpy(pwlanhdr->addr3,
+		       get_my_bssid23a(&pmlmeinfo->network), ETH_ALEN);
+		break;
+	}
+
+	SetSeqNum(pwlanhdr, 0);
+
+	if (bQoS =3D=3D true) {
+		struct ieee80211_qos_hdr *pwlanqoshdr;
+
+		SetFrameSubType(pframe, WIFI_QOS_DATA_NULL);
+
+		pwlanqoshdr =3D (struct ieee80211_qos_hdr *)pframe;
+		SetPriority(&pwlanqoshdr->qos_ctrl, AC);
+		SetEOSP(&pwlanqoshdr->qos_ctrl, bEosp);
+
+		pktlen =3D sizeof(struct ieee80211_qos_hdr);
+	} else {
+		SetFrameSubType(pframe, WIFI_DATA_NULL);
+
+		pktlen =3D sizeof(struct ieee80211_hdr_3addr);
+	}
+
+	*pLength =3D pktlen;
+}
+
+static void ConstructProbeRsp(struct rtw_adapter *padapter, u8 *pframe=
, u32 *pLength, u8 *StaAddr, bool bHideSSID)
+{
+	struct ieee80211_hdr *pwlanhdr;
+	u16 *fctrl;
+	u8 *mac, *bssid;
+	u32 pktlen;
+	struct mlme_ext_priv *pmlmeext =3D &padapter->mlmeextpriv;
+	struct mlme_ext_info *pmlmeinfo =3D &pmlmeext->mlmext_info;
+	struct wlan_bssid_ex *cur_network =3D &pmlmeinfo->network;
+
+	/* DBG_8723A("%s\n", __FUNCTION__); */
+
+	pwlanhdr =3D (struct ieee80211_hdr *)pframe;
+
+	mac =3D myid(&padapter->eeprompriv);
+	bssid =3D cur_network->MacAddress;
+
+	fctrl =3D &pwlanhdr->frame_control;
+	*(fctrl) =3D 0;
+	memcpy(pwlanhdr->addr1, StaAddr, ETH_ALEN);
+	memcpy(pwlanhdr->addr2, mac, ETH_ALEN);
+	memcpy(pwlanhdr->addr3, bssid, ETH_ALEN);
+
+	SetSeqNum(pwlanhdr, 0);
+	SetFrameSubType(fctrl, WIFI_PROBERSP);
+
+	pktlen =3D sizeof(struct ieee80211_hdr_3addr);
+	pframe +=3D pktlen;
+
+	if (cur_network->IELength > MAX_IE_SZ)
+		return;
+
+	memcpy(pframe, cur_network->IEs, cur_network->IELength);
+	pframe +=3D cur_network->IELength;
+	pktlen +=3D cur_network->IELength;
+
+	*pLength =3D pktlen;
+}
+
+/*  To check if reserved page content is destroyed by beacon beacuse b=
eacon is too large. */
+void CheckFwRsvdPageContent23a(struct rtw_adapter *Adapter)
+{
+}
+
+/*  */
+/*  Description: Fill the reserved packets that FW will use to RSVD pa=
ge. */
+/*			Now we just send 4 types packet to rsvd page. */
+/*			(1)Beacon, (2)Ps-poll, (3)Null data, (4)ProbeRsp. */
+/*	Input: */
+/*	    bDLFinished - false: At the first time we will send all the pac=
kets as a large packet to Hw, */
+/*						so we need to set the packet length to total lengh. */
+/*			      true: At the second time, we should send the first packet (=
default:beacon) */
+/*						to Hw again and set the lengh in descriptor to the real beacon=
 lengh. */
+/*  2009.10.15 by tynli. */
+static void SetFwRsvdPagePkt(struct rtw_adapter *padapter, bool bDLFin=
ished)
+{
+	struct hal_data_8723a *pHalData;
+	struct xmit_frame *pmgntframe;
+	struct pkt_attrib *pattrib;
+	struct xmit_priv *pxmitpriv;
+	struct mlme_ext_priv *pmlmeext;
+	struct mlme_ext_info *pmlmeinfo;
+	u32 BeaconLength =3D 0, ProbeRspLength =3D 0, PSPollLength;
+	u32 NullDataLength, QosNullLength, BTQosNullLength;
+	u8 *ReservedPagePacket;
+	u8 PageNum, PageNeed, TxDescLen;
+	u16 BufIndex;
+	u32 TotalPacketLen;
+	struct rsvdpage_loc	RsvdPageLoc;
+
+	DBG_8723A("%s\n", __FUNCTION__);
+
+	ReservedPagePacket =3D kzalloc(1000, GFP_KERNEL);
+	if (ReservedPagePacket =3D=3D NULL) {
+		DBG_8723A("%s: alloc ReservedPagePacket fail!\n", __FUNCTION__);
+		return;
+	}
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pxmitpriv =3D &padapter->xmitpriv;
+	pmlmeext =3D &padapter->mlmeextpriv;
+	pmlmeinfo =3D &pmlmeext->mlmext_info;
+
+	TxDescLen =3D TXDESC_SIZE;
+	PageNum =3D 0;
+
+	/* 3 (1) beacon */
+	BufIndex =3D TXDESC_OFFSET;
+	ConstructBeacon(padapter, &ReservedPagePacket[BufIndex], &BeaconLengt=
h);
+
+	/*  When we count the first page size, we need to reserve description=
 size for the RSVD */
+	/*  packet, it will be filled in front of the packet in TXPKTBUF. */
+	PageNeed =3D (u8)PageNum_128(TxDescLen + BeaconLength);
+	/*  To reserved 2 pages for beacon buffer. 2010.06.24. */
+	if (PageNeed =3D=3D 1)
+		PageNeed +=3D 1;
+	PageNum +=3D PageNeed;
+	pHalData->FwRsvdPageStartOffset =3D PageNum;
+
+	BufIndex +=3D PageNeed*128;
+
+	/* 3 (2) ps-poll */
+	RsvdPageLoc.LocPsPoll =3D PageNum;
+	ConstructPSPoll(padapter, &ReservedPagePacket[BufIndex], &PSPollLengt=
h);
+	rtl8723a_fill_fake_txdesc(padapter, &ReservedPagePacket[BufIndex-TxDe=
scLen], PSPollLength, true, false);
+
+	PageNeed =3D (u8)PageNum_128(TxDescLen + PSPollLength);
+	PageNum +=3D PageNeed;
+
+	BufIndex +=3D PageNeed*128;
+
+	/* 3 (3) null data */
+	RsvdPageLoc.LocNullData =3D PageNum;
+	ConstructNullFunctionData(
+		padapter,
+		&ReservedPagePacket[BufIndex],
+		&NullDataLength,
+		get_my_bssid23a(&pmlmeinfo->network),
+		false, 0, 0, false);
+	rtl8723a_fill_fake_txdesc(padapter, &ReservedPagePacket[BufIndex-TxDe=
scLen], NullDataLength, false, false);
+
+	PageNeed =3D (u8)PageNum_128(TxDescLen + NullDataLength);
+	PageNum +=3D PageNeed;
+
+	BufIndex +=3D PageNeed*128;
+
+	/* 3 (4) probe response */
+	RsvdPageLoc.LocProbeRsp =3D PageNum;
+	ConstructProbeRsp(
+		padapter,
+		&ReservedPagePacket[BufIndex],
+		&ProbeRspLength,
+		get_my_bssid23a(&pmlmeinfo->network),
+		false);
+	rtl8723a_fill_fake_txdesc(padapter, &ReservedPagePacket[BufIndex-TxDe=
scLen], ProbeRspLength, false, false);
+
+	PageNeed =3D (u8)PageNum_128(TxDescLen + ProbeRspLength);
+	PageNum +=3D PageNeed;
+
+	BufIndex +=3D PageNeed*128;
+
+	/* 3 (5) Qos null data */
+	RsvdPageLoc.LocQosNull =3D PageNum;
+	ConstructNullFunctionData(
+		padapter,
+		&ReservedPagePacket[BufIndex],
+		&QosNullLength,
+		get_my_bssid23a(&pmlmeinfo->network),
+		true, 0, 0, false);
+	rtl8723a_fill_fake_txdesc(padapter, &ReservedPagePacket[BufIndex-TxDe=
scLen], QosNullLength, false, false);
+
+	PageNeed =3D (u8)PageNum_128(TxDescLen + QosNullLength);
+	PageNum +=3D PageNeed;
+
+	BufIndex +=3D PageNeed*128;
+
+	/* 3 (6) BT Qos null data */
+	RsvdPageLoc.LocBTQosNull =3D PageNum;
+	ConstructNullFunctionData(
+		padapter,
+		&ReservedPagePacket[BufIndex],
+		&BTQosNullLength,
+		get_my_bssid23a(&pmlmeinfo->network),
+		true, 0, 0, false);
+	rtl8723a_fill_fake_txdesc(padapter, &ReservedPagePacket[BufIndex-TxDe=
scLen], BTQosNullLength, false, true);
+
+	TotalPacketLen =3D BufIndex + BTQosNullLength;
+
+	pmgntframe =3D alloc_mgtxmitframe23a(pxmitpriv);
+	if (pmgntframe =3D=3D NULL)
+		goto exit;
+
+	/*  update attribute */
+	pattrib =3D &pmgntframe->attrib;
+	update_mgntframe_attrib23a(padapter, pattrib);
+	pattrib->qsel =3D 0x10;
+	pattrib->pktlen =3D pattrib->last_txcmdsz =3D TotalPacketLen - TXDESC=
_OFFSET;
+	memcpy(pmgntframe->buf_addr, ReservedPagePacket, TotalPacketLen);
+
+	rtw_hal_mgnt_xmit23a(padapter, pmgntframe);
+
+	DBG_8723A("%s: Set RSVD page location to Fw\n", __FUNCTION__);
+	FillH2CCmd(padapter, RSVD_PAGE_EID, sizeof(RsvdPageLoc), (u8 *)&RsvdP=
ageLoc);
+
+exit:
+	kfree(ReservedPagePacket);
+}
+
+void rtl8723a_set_FwJoinBssReport_cmd(struct rtw_adapter *padapter, u8=
 mstatus)
+{
+	struct joinbssrpt_parm	JoinBssRptParm;
+	struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(padapter);
+	struct mlme_ext_priv *pmlmeext =3D &padapter->mlmeextpriv;
+	struct mlme_ext_info *pmlmeinfo =3D &pmlmeext->mlmext_info;
+
+	DBG_8723A("%s mstatus(%x)\n", __FUNCTION__, mstatus);
+
+	if (mstatus =3D=3D 1) {
+		bool bRecover =3D false;
+		u8 v8;
+
+		/*  We should set AID, correct TSF, HW seq enable before set JoinBss=
Report to Fw in 88/92C. */
+		/*  Suggested by filen. Added by tynli. */
+		rtw_write16(padapter, REG_BCN_PSR_RPT, (0xC000|pmlmeinfo->aid));
+		/*  Do not set TSF again here or vWiFi beacon DMA INT will not work.=
 */
+		/* correct_TSF23a(padapter, pmlmeext); */
+		/*  Hw sequende enable by dedault. 2010.06.23. by tynli. */
+		/* rtw_write16(padapter, REG_NQOS_SEQ, ((pmlmeext->mgnt_seq+100)&0xF=
=46F)); */
+		/* rtw_write8(padapter, REG_HWSEQ_CTRL, 0xFF); */
+
+		/*  set REG_CR bit 8 */
+		v8 =3D rtw_read8(padapter, REG_CR+1);
+		v8 |=3D BIT(0); /*  ENSWBCN */
+		rtw_write8(padapter,  REG_CR+1, v8);
+
+		/*  Disable Hw protection for a time which revserd for Hw sending be=
acon. */
+		/*  Fix download reserved page packet fail that access collision wit=
h the protection time. */
+		/*  2010.05.11. Added by tynli. */
+/*			SetBcnCtrlReg23a(padapter, 0, BIT(3)); */
+/*			SetBcnCtrlReg23a(padapter, BIT(4), 0); */
+		SetBcnCtrlReg23a(padapter, BIT(4), BIT(3));
+
+		/*  Set FWHW_TXQ_CTRL 0x422[6]=3D 0 to tell Hw the packet is not a r=
eal beacon frame. */
+		if (pHalData->RegFwHwTxQCtrl & BIT(6))
+			bRecover =3D true;
+
+		/*  To tell Hw the packet is not a real beacon frame. */
+		/* U1bTmp =3D rtw_read8(padapter, REG_FWHW_TXQ_CTRL+2); */
+		rtw_write8(padapter, REG_FWHW_TXQ_CTRL+2, pHalData->RegFwHwTxQCtrl &=
 ~BIT(6));
+		pHalData->RegFwHwTxQCtrl &=3D ~BIT(6);
+		SetFwRsvdPagePkt(padapter, 0);
+
+		/*  2010.05.11. Added by tynli. */
+		SetBcnCtrlReg23a(padapter, BIT(3), BIT(4));
+
+		/*  To make sure that if there exists an adapter which would like to=
 send beacon. */
+		/*  If exists, the origianl value of 0x422[6] will be 1, we should c=
heck this to */
+		/*  prevent from setting 0x422[6] to 0 after download reserved page,=
 or it will cause */
+		/*  the beacon cannot be sent by HW. */
+		/*  2010.06.23. Added by tynli. */
+		if (bRecover) {
+			rtw_write8(padapter, REG_FWHW_TXQ_CTRL+2, pHalData->RegFwHwTxQCtrl =
| BIT(6));
+			pHalData->RegFwHwTxQCtrl |=3D BIT(6);
+		}
+
+		/*  Clear CR[8] or beacon packet will not be send to TxBuf anymore. =
*/
+		v8 =3D rtw_read8(padapter, REG_CR+1);
+		v8 &=3D ~BIT(0); /*  ~ENSWBCN */
+		rtw_write8(padapter, REG_CR+1, v8);
+	}
+
+	JoinBssRptParm.OpMode =3D mstatus;
+
+	FillH2CCmd(padapter, JOINBSS_RPT_EID, sizeof(JoinBssRptParm), (u8 *)&=
JoinBssRptParm);
+
+}
+
+#ifdef CONFIG_8723AU_BT_COEXIST
+static void SetFwRsvdPagePkt_BTCoex(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	struct xmit_frame *pmgntframe;
+	struct pkt_attrib *pattrib;
+	struct xmit_priv *pxmitpriv;
+	struct mlme_ext_priv *pmlmeext;
+	struct mlme_ext_info *pmlmeinfo;
+	u8 fakemac[6] =3D {0x00, 0xe0, 0x4c, 0x00, 0x00, 0x00};
+	u32 NullDataLength, BTQosNullLength;
+	u8 *ReservedPagePacket;
+	u8 PageNum, PageNeed, TxDescLen;
+	u16 BufIndex;
+	u32 TotalPacketLen;
+	struct rsvdpage_loc	RsvdPageLoc;
+
+	DBG_8723A("+%s\n", __FUNCTION__);
+
+	ReservedPagePacket =3D kzalloc(1024, GFP_KERNEL);
+	if (ReservedPagePacket =3D=3D NULL) {
+		DBG_8723A("%s: alloc ReservedPagePacket fail!\n", __FUNCTION__);
+		return;
+	}
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pxmitpriv =3D &padapter->xmitpriv;
+	pmlmeext =3D &padapter->mlmeextpriv;
+	pmlmeinfo =3D &pmlmeext->mlmext_info;
+
+	TxDescLen =3D TXDESC_SIZE;
+	PageNum =3D 0;
+
+	/* 3 (1) beacon */
+	BufIndex =3D TXDESC_OFFSET;
+	/*  skip Beacon Packet */
+	PageNeed =3D 3;
+
+	PageNum +=3D PageNeed;
+	pHalData->FwRsvdPageStartOffset =3D PageNum;
+
+	BufIndex +=3D PageNeed*128;
+
+	/* 3 (3) null data */
+	RsvdPageLoc.LocNullData =3D PageNum;
+	ConstructNullFunctionData(
+		padapter,
+		&ReservedPagePacket[BufIndex],
+		&NullDataLength,
+		fakemac,
+		false, 0, 0, false);
+	rtl8723a_fill_fake_txdesc(padapter, &ReservedPagePacket[BufIndex-TxDe=
scLen], NullDataLength, false, false);
+
+	PageNeed =3D (u8)PageNum_128(TxDescLen + NullDataLength);
+	PageNum +=3D PageNeed;
+
+	BufIndex +=3D PageNeed*128;
+
+	/* 3 (6) BT Qos null data */
+	RsvdPageLoc.LocBTQosNull =3D PageNum;
+	ConstructNullFunctionData(
+		padapter,
+		&ReservedPagePacket[BufIndex],
+		&BTQosNullLength,
+		fakemac,
+		true, 0, 0, false);
+	rtl8723a_fill_fake_txdesc(padapter, &ReservedPagePacket[BufIndex-TxDe=
scLen], BTQosNullLength, false, true);
+
+	TotalPacketLen =3D BufIndex + BTQosNullLength;
+
+	pmgntframe =3D alloc_mgtxmitframe23a(pxmitpriv);
+	if (pmgntframe =3D=3D NULL)
+		goto exit;
+
+	/*  update attribute */
+	pattrib =3D &pmgntframe->attrib;
+	update_mgntframe_attrib23a(padapter, pattrib);
+	pattrib->qsel =3D 0x10;
+	pattrib->pktlen =3D pattrib->last_txcmdsz =3D TotalPacketLen - TXDESC=
_OFFSET;
+	memcpy(pmgntframe->buf_addr, ReservedPagePacket, TotalPacketLen);
+
+	rtw_hal_mgnt_xmit23a(padapter, pmgntframe);
+
+	DBG_8723A("%s: Set RSVD page location to Fw\n", __FUNCTION__);
+	FillH2CCmd(padapter, RSVD_PAGE_EID, sizeof(RsvdPageLoc), (u8 *)&RsvdP=
ageLoc);
+
+exit:
+	kfree(ReservedPagePacket);
+}
+
+void rtl8723a_set_BTCoex_AP_mode_FwRsvdPkt_cmd(struct rtw_adapter *pad=
apter)
+{
+	struct hal_data_8723a *pHalData;
+	u8 bRecover =3D false;
+
+	DBG_8723A("+%s\n", __FUNCTION__);
+
+	pHalData =3D GET_HAL_DATA(padapter);
+
+	/*  Set FWHW_TXQ_CTRL 0x422[6]=3D 0 to tell Hw the packet is not a re=
al beacon frame. */
+	if (pHalData->RegFwHwTxQCtrl & BIT(6))
+		bRecover =3D true;
+
+	/*  To tell Hw the packet is not a real beacon frame. */
+	pHalData->RegFwHwTxQCtrl &=3D ~BIT(6);
+	rtw_write8(padapter, REG_FWHW_TXQ_CTRL+2, pHalData->RegFwHwTxQCtrl);
+	SetFwRsvdPagePkt_BTCoex(padapter);
+
+	/*  To make sure that if there exists an adapter which would like to =
send beacon. */
+	/*  If exists, the origianl value of 0x422[6] will be 1, we should ch=
eck this to */
+	/*  prevent from setting 0x422[6] to 0 after download reserved page, =
or it will cause */
+	/*  the beacon cannot be sent by HW. */
+	/*  2010.06.23. Added by tynli. */
+	if (bRecover) {
+		pHalData->RegFwHwTxQCtrl |=3D BIT(6);
+		rtw_write8(padapter, REG_FWHW_TXQ_CTRL+2, pHalData->RegFwHwTxQCtrl);
+	}
+}
+#endif
+
+#ifdef CONFIG_8723AU_P2P
+void rtl8723a_set_p2p_ps_offload_cmd(struct rtw_adapter *padapter, u8 =
p2p_ps_state)
+{
+	struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(padapter);
+	struct wifidirect_info *pwdinfo =3D &padapter->wdinfo;
+	struct P2P_PS_Offload_t	*p2p_ps_offload =3D &pHalData->p2p_ps_offload=
;
+	u8 i;
+
+	switch (p2p_ps_state) {
+	case P2P_PS_DISABLE:
+		DBG_8723A("P2P_PS_DISABLE \n");
+		memset(p2p_ps_offload, 0, 1);
+		break;
+	case P2P_PS_ENABLE:
+		DBG_8723A("P2P_PS_ENABLE \n");
+		/*  update CTWindow value. */
+		if (pwdinfo->ctwindow > 0) {
+			p2p_ps_offload->CTWindow_En =3D 1;
+			rtw_write8(padapter, REG_P2P_CTWIN, pwdinfo->ctwindow);
+		}
+
+		/*  hw only support 2 set of NoA */
+		for (i =3D 0; i < pwdinfo->noa_num; i++) {
+			/*  To control the register setting for which NOA */
+			rtw_write8(padapter, REG_NOA_DESC_SEL, (i << 4));
+			if (i =3D=3D 0)
+				p2p_ps_offload->NoA0_En =3D 1;
+			else
+				p2p_ps_offload->NoA1_En =3D 1;
+
+			/*  config P2P NoA Descriptor Register */
+			rtw_write32(padapter, REG_NOA_DESC_DURATION, pwdinfo->noa_duration[=
i]);
+
+			rtw_write32(padapter, REG_NOA_DESC_INTERVAL, pwdinfo->noa_interval[=
i]);
+
+			rtw_write32(padapter, REG_NOA_DESC_START, pwdinfo->noa_start_time[i=
]);
+
+			rtw_write8(padapter, REG_NOA_DESC_COUNT, pwdinfo->noa_count[i]);
+		}
+
+		if ((pwdinfo->opp_ps =3D=3D 1) || (pwdinfo->noa_num > 0)) {
+			/*  rst p2p circuit */
+			rtw_write8(padapter, REG_DUAL_TSF_RST, BIT(4));
+
+			p2p_ps_offload->Offload_En =3D 1;
+
+			if (rtw_p2p_chk_role(pwdinfo, P2P_ROLE_GO)) {
+				p2p_ps_offload->role =3D 1;
+				p2p_ps_offload->AllStaSleep =3D 0;
+			} else {
+				p2p_ps_offload->role =3D 0;
+			}
+
+			p2p_ps_offload->discovery =3D 0;
+		}
+		break;
+	case P2P_PS_SCAN:
+		DBG_8723A("P2P_PS_SCAN \n");
+		p2p_ps_offload->discovery =3D 1;
+		break;
+	case P2P_PS_SCAN_DONE:
+		DBG_8723A("P2P_PS_SCAN_DONE \n");
+		p2p_ps_offload->discovery =3D 0;
+		pwdinfo->p2p_ps_state =3D P2P_PS_ENABLE;
+		break;
+	default:
+		break;
+	}
+
+	FillH2CCmd(padapter, P2P_PS_OFFLOAD_EID, 1, (u8 *)p2p_ps_offload);
+}
+#endif /* CONFIG_8723AU_P2P */
diff --git a/drivers/staging/rtl8723au/hal/rtl8723a_dm.c b/drivers/stag=
ing/rtl8723au/hal/rtl8723a_dm.c
new file mode 100644
index 0000000..f204ab1
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/rtl8723a_dm.c
@@ -0,0 +1,273 @@
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
+/*  */
+/*  Description: */
+/*  */
+/*  This file is for 92CE/92CU dynamic mechanism only */
+/*  */
+/*  */
+/*  */
+#define _RTL8723A_DM_C_
+
+/*  */
+/*  include files */
+/*  */
+#include <osdep_service.h>
+#include <drv_types.h>
+
+#include <rtl8723a_hal.h>
+
+/*  */
+/*  Global var */
+/*  */
+
+static void dm_CheckStatistics(struct rtw_adapter *Adapter)
+{
+}
+
+static void dm_CheckPbcGPIO(struct rtw_adapter *padapter)
+{
+	u8	tmp1byte;
+	u8	bPbcPressed =3D false;
+
+	if (!padapter->registrypriv.hw_wps_pbc)
+		return;
+
+	tmp1byte =3D rtw_read8(padapter, GPIO_IO_SEL);
+	tmp1byte |=3D (HAL_8192C_HW_GPIO_WPS_BIT);
+	rtw_write8(padapter, GPIO_IO_SEL, tmp1byte);	/* enable GPIO[2] as out=
put mode */
+
+	tmp1byte &=3D ~(HAL_8192C_HW_GPIO_WPS_BIT);
+	rtw_write8(padapter,  GPIO_IN, tmp1byte);		/* reset the floating volt=
age level */
+
+	tmp1byte =3D rtw_read8(padapter, GPIO_IO_SEL);
+	tmp1byte &=3D ~(HAL_8192C_HW_GPIO_WPS_BIT);
+	rtw_write8(padapter, GPIO_IO_SEL, tmp1byte);	/* enable GPIO[2] as inp=
ut mode */
+
+	tmp1byte =3D rtw_read8(padapter, GPIO_IN);
+
+	if (tmp1byte =3D=3D 0xff)
+		return;
+
+	if (tmp1byte&HAL_8192C_HW_GPIO_WPS_BIT)
+		bPbcPressed =3D true;
+
+	if (bPbcPressed) {
+		/*  Here we only set bPbcPressed to true */
+		/*  After trigger PBC, the variable will be set to false */
+		DBG_8723A("CheckPbcGPIO - PBC is pressed\n");
+
+		if (padapter->pid[0] =3D=3D 0) {
+			/* 0 is the default value and it means the application
+			 * monitors the HW PBC doesn't privde its pid to driver.
+			 */
+			return;
+		}
+
+		rtw_signal_process(padapter->pid[0], SIGUSR1);
+	}
+}
+
+/*  Initialize GPIO setting registers */
+/*  functions */
+static void Init_ODM_ComInfo_8723a(struct rtw_adapter *Adapter)
+{
+
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct dm_odm_t *pDM_Odm =3D &pHalData->odmpriv;
+	u8	cut_ver, fab_ver;
+
+	/*  */
+	/*  Init Value */
+	/*  */
+	memset(pDM_Odm, 0, sizeof(*pDM_Odm));
+
+	pDM_Odm->Adapter =3D Adapter;
+	ODM_CmnInfoInit23a(pDM_Odm, ODM_CMNINFO_PLATFORM, 0x04);
+	ODM_CmnInfoInit23a(pDM_Odm, ODM_CMNINFO_INTERFACE, RTW_USB);/* RTL871=
X_HCI_TYPE */
+
+	ODM_CmnInfoInit23a(pDM_Odm, ODM_CMNINFO_IC_TYPE, ODM_RTL8723A);
+
+	if (IS_8723A_A_CUT(pHalData->VersionID)) {
+		fab_ver =3D ODM_UMC;
+		cut_ver =3D ODM_CUT_A;
+	} else if (IS_8723A_B_CUT(pHalData->VersionID)) {
+		fab_ver =3D ODM_UMC;
+		cut_ver =3D ODM_CUT_B;
+	} else {
+		fab_ver =3D ODM_TSMC;
+		cut_ver =3D ODM_CUT_A;
+	}
+	ODM_CmnInfoInit23a(pDM_Odm, ODM_CMNINFO_FAB_VER, fab_ver);
+	ODM_CmnInfoInit23a(pDM_Odm, ODM_CMNINFO_CUT_VER, cut_ver);
+	ODM_CmnInfoInit23a(pDM_Odm, ODM_CMNINFO_MP_TEST_CHIP, IS_NORMAL_CHIP(=
pHalData->VersionID));
+
+	ODM_CmnInfoInit23a(pDM_Odm, ODM_CMNINFO_BOARD_TYPE, pHalData->BoardTy=
pe);
+
+	if (pHalData->BoardType =3D=3D BOARD_USB_High_PA) {
+		ODM_CmnInfoInit23a(pDM_Odm, ODM_CMNINFO_EXT_LNA, true);
+		ODM_CmnInfoInit23a(pDM_Odm, ODM_CMNINFO_EXT_PA, true);
+	}
+	ODM_CmnInfoInit23a(pDM_Odm, ODM_CMNINFO_PATCH_ID, pHalData->CustomerI=
D);
+	ODM_CmnInfoInit23a(pDM_Odm, ODM_CMNINFO_BWIFI_TEST, Adapter->registry=
priv.wifi_spec);
+
+	if (pHalData->rf_type =3D=3D RF_1T1R)
+		ODM_CmnInfoUpdate23a(pDM_Odm, ODM_CMNINFO_RF_TYPE, ODM_1T1R);
+	else if (pHalData->rf_type =3D=3D RF_2T2R)
+		ODM_CmnInfoUpdate23a(pDM_Odm, ODM_CMNINFO_RF_TYPE, ODM_2T2R);
+	else if (pHalData->rf_type =3D=3D RF_1T2R)
+		ODM_CmnInfoUpdate23a(pDM_Odm, ODM_CMNINFO_RF_TYPE, ODM_1T2R);
+}
+
+static void Update_ODM_ComInfo_8723a(struct rtw_adapter *Adapter)
+{
+	struct mlme_ext_priv	*pmlmeext =3D &Adapter->mlmeextpriv;
+	struct mlme_priv		*pmlmepriv =3D &Adapter->mlmepriv;
+	struct pwrctrl_priv *pwrctrlpriv =3D &Adapter->pwrctrlpriv;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct dm_odm_t *pDM_Odm =3D &pHalData->odmpriv;
+	struct dm_priv	*pdmpriv =3D &pHalData->dmpriv;
+	int i;
+	pdmpriv->InitODMFlag =3D	ODM_BB_DIG		|
+				ODM_BB_RA_MASK		|
+				ODM_BB_DYNAMIC_TXPWR	|
+				ODM_BB_FA_CNT		|
+				ODM_BB_RSSI_MONITOR	|
+				ODM_BB_CCK_PD		|
+				ODM_BB_PWR_SAVE		|
+				ODM_MAC_EDCA_TURBO	|
+				ODM_RF_TX_PWR_TRACK	|
+				ODM_RF_CALIBRATION;
+	/*  Pointer reference */
+
+	ODM_CmnInfoUpdate23a(pDM_Odm, ODM_CMNINFO_ABILITY, pdmpriv->InitODMFl=
ag);
+
+	ODM23a_CmnInfoHook(pDM_Odm, ODM_CMNINFO_TX_UNI,
+			   &Adapter->xmitpriv.tx_bytes);
+	ODM23a_CmnInfoHook(pDM_Odm, ODM_CMNINFO_RX_UNI,
+			   &Adapter->recvpriv.rx_bytes);
+	ODM23a_CmnInfoHook(pDM_Odm, ODM_CMNINFO_WM_MODE,
+			   &pmlmeext->cur_wireless_mode);
+	ODM23a_CmnInfoHook(pDM_Odm, ODM_CMNINFO_SEC_CHNL_OFFSET,
+			   &pHalData->nCur40MhzPrimeSC);
+	ODM23a_CmnInfoHook(pDM_Odm, ODM_CMNINFO_SEC_MODE,
+			   &Adapter->securitypriv.dot11PrivacyAlgrthm);
+	ODM23a_CmnInfoHook(pDM_Odm, ODM_CMNINFO_BW,
+			   &pHalData->CurrentChannelBW);
+	ODM23a_CmnInfoHook(pDM_Odm, ODM_CMNINFO_CHNL,
+			   &pHalData->CurrentChannel);
+	ODM23a_CmnInfoHook(pDM_Odm, ODM_CMNINFO_NET_CLOSED, &Adapter->net_clo=
sed);
+
+	ODM23a_CmnInfoHook(pDM_Odm, ODM_CMNINFO_SCAN, &pmlmepriv->bScanInProc=
ess);
+	ODM23a_CmnInfoHook(pDM_Odm, ODM_CMNINFO_POWER_SAVING,
+			   &pwrctrlpriv->bpower_saving);
+
+	for (i =3D 0; i < NUM_STA; i++)
+		ODM_CmnInfoPtrArrayHook23a(pDM_Odm, ODM_CMNINFO_STA_STATUS, i, NULL)=
;
+}
+
+void rtl8723a_InitHalDm(struct rtw_adapter *Adapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct dm_priv	*pdmpriv =3D &pHalData->dmpriv;
+	struct dm_odm_t *pDM_Odm =3D &pHalData->odmpriv;
+	u8	i;
+
+	pdmpriv->DM_Type =3D DM_Type_ByDriver;
+	pdmpriv->DMFlag =3D DYNAMIC_FUNC_DISABLE;
+
+#ifdef CONFIG_8723AU_BT_COEXIST
+	pdmpriv->DMFlag |=3D DYNAMIC_FUNC_BT;
+#endif
+	pdmpriv->InitDMFlag =3D pdmpriv->DMFlag;
+
+	Update_ODM_ComInfo_8723a(Adapter);
+	ODM23a_DMInit(pDM_Odm);
+	/*  Save REG_INIDATA_RATE_SEL value for TXDESC. */
+	for (i =3D 0; i < 32; i++)
+		pdmpriv->INIDATA_RATE[i] =3D rtw_read8(Adapter, REG_INIDATA_RATE_SEL=
+i) & 0x3f;
+}
+
+void
+rtl8723a_HalDmWatchDog(
+	struct rtw_adapter *Adapter
+	)
+{
+	bool		bFwCurrentInPSMode =3D false;
+	bool		bFwPSAwake =3D true;
+	u8 hw_init_completed =3D false;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct dm_priv	*pdmpriv =3D &pHalData->dmpriv;
+
+	hw_init_completed =3D Adapter->hw_init_completed;
+
+	if (hw_init_completed =3D=3D false)
+		goto skip_dm;
+
+	bFwCurrentInPSMode =3D Adapter->pwrctrlpriv.bFwCurrentInPSMode;
+	rtw23a_hal_get_hwreg(Adapter, HW_VAR_FWLPS_RF_ON, (u8 *)(&bFwPSAwake)=
);
+
+#ifdef CONFIG_8723AU_P2P
+	/*  Fw is under p2p powersaving mode, driver should stop dynamic mech=
anism. */
+	/*  modifed by thomas. 2011.06.11. */
+	if (Adapter->wdinfo.p2p_ps_mode)
+		bFwPSAwake =3D false;
+#endif /* CONFIG_8723AU_P2P */
+
+	if ((hw_init_completed) && ((!bFwCurrentInPSMode) && bFwPSAwake)) {
+		/*  Calculate Tx/Rx statistics. */
+		dm_CheckStatistics(Adapter);
+
+		/*  Read REG_INIDATA_RATE_SEL value for TXDESC. */
+		if (check_fwstate(&Adapter->mlmepriv, WIFI_STATION_STATE)) {
+			pdmpriv->INIDATA_RATE[0] =3D rtw_read8(Adapter, REG_INIDATA_RATE_SE=
L) & 0x3f;
+		} else {
+			u8	i;
+			for (i =3D 1 ; i < (Adapter->stapriv.asoc_sta_count + 1); i++)
+				pdmpriv->INIDATA_RATE[i] =3D rtw_read8(Adapter, (REG_INIDATA_RATE_=
SEL+i)) & 0x3f;
+		}
+	}
+
+	/* ODM */
+	if (hw_init_completed =3D=3D true) {
+		u8	bLinked =3D false;
+
+		if (rtw_linked_check(Adapter))
+			bLinked =3D true;
+
+		ODM_CmnInfoUpdate23a(&pHalData->odmpriv, ODM_CMNINFO_LINK,
+				     bLinked);
+		ODM_DMWatchdog23a(&pHalData->odmpriv);
+	}
+
+skip_dm:
+
+	/*  Check GPIO to determine current RF on/off and Pbc status. */
+	/*  Check Hardware Radio ON/OFF or not */
+	dm_CheckPbcGPIO(Adapter);
+}
+
+void rtl8723a_init_dm_priv(struct rtw_adapter *Adapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct dm_priv	*pdmpriv =3D &pHalData->dmpriv;
+
+	memset(pdmpriv, 0, sizeof(struct dm_priv));
+	Init_ODM_ComInfo_8723a(Adapter);
+}
+
+void rtl8723a_deinit_dm_priv(struct rtw_adapter *Adapter)
+{
+}
diff --git a/drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c b/driver=
s/staging/rtl8723au/hal/rtl8723a_hal_init.c
new file mode 100644
index 0000000..fd00ddb
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c
@@ -0,0 +1,3452 @@
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
+#define _HAL_INIT_C_
+
+#include <linux/firmware.h>
+#include <drv_types.h>
+#include <rtw_efuse.h>
+
+#include <rtl8723a_hal.h>
+
+static void _FWDownloadEnable(struct rtw_adapter *padapter, bool enabl=
e)
+{
+	u8 tmp;
+
+	if (enable) {
+		/*  8051 enable */
+		tmp =3D rtw_read8(padapter, REG_SYS_FUNC_EN + 1);
+		rtw_write8(padapter, REG_SYS_FUNC_EN + 1, tmp | 0x04);
+
+		/*  MCU firmware download enable. */
+		tmp =3D rtw_read8(padapter, REG_MCUFWDL);
+		rtw_write8(padapter, REG_MCUFWDL, tmp | 0x01);
+
+		/*  8051 reset */
+		tmp =3D rtw_read8(padapter, REG_MCUFWDL + 2);
+		rtw_write8(padapter, REG_MCUFWDL + 2, tmp & 0xf7);
+	} else {
+		/*  MCU firmware download disable. */
+		tmp =3D rtw_read8(padapter, REG_MCUFWDL);
+		rtw_write8(padapter, REG_MCUFWDL, tmp & 0xfe);
+
+		/*  Reserved for fw extension. */
+		rtw_write8(padapter, REG_MCUFWDL + 1, 0x00);
+	}
+}
+
+static int _BlockWrite(struct rtw_adapter *padapter, void *buffer, u32=
 buffSize)
+{
+	int ret =3D _SUCCESS;
+	/*  (Default) Phase #1 : PCI muse use 4-byte write to download FW */
+	u32 blockSize_p1 =3D 4;
+	/*  Phase #2 : Use 8-byte, if Phase#1 use big size to write FW. */
+	u32 blockSize_p2 =3D 8;
+	/*  Phase #3 : Use 1-byte, the remnant of FW image. */
+	u32 blockSize_p3 =3D 1;
+	u32 blockCount_p1 =3D 0, blockCount_p2 =3D 0, blockCount_p3 =3D 0;
+	u32 remainSize_p1 =3D 0, remainSize_p2 =3D 0;
+	u8 *bufferPtr =3D (u8 *) buffer;
+	u32 i =3D 0, offset =3D 0;
+
+	blockSize_p1 =3D 254;
+
+	/* 3 Phase #1 */
+	blockCount_p1 =3D buffSize / blockSize_p1;
+	remainSize_p1 =3D buffSize % blockSize_p1;
+
+	if (blockCount_p1) {
+		RT_TRACE(_module_hal_init_c_, _drv_notice_,
+			 ("_BlockWrite: [P1] buffSize(%d) blockSize_p1(%d) "
+			  "blockCount_p1(%d) remainSize_p1(%d)\n",
+			  buffSize, blockSize_p1, blockCount_p1,
+			  remainSize_p1));
+	}
+
+	for (i =3D 0; i < blockCount_p1; i++) {
+		ret =3D rtw_writeN(padapter,
+				 (FW_8723A_START_ADDRESS + i * blockSize_p1),
+				 blockSize_p1, (bufferPtr + i * blockSize_p1));
+		if (ret =3D=3D _FAIL)
+			goto exit;
+	}
+
+	/* 3 Phase #2 */
+	if (remainSize_p1) {
+		offset =3D blockCount_p1 * blockSize_p1;
+
+		blockCount_p2 =3D remainSize_p1 / blockSize_p2;
+		remainSize_p2 =3D remainSize_p1 % blockSize_p2;
+
+		if (blockCount_p2) {
+			RT_TRACE(_module_hal_init_c_, _drv_notice_,
+				 ("_BlockWrite: [P2] buffSize_p2(%d) "
+				  "blockSize_p2(%d) blockCount_p2(%d) "
+				  "remainSize_p2(%d)\n",
+				  (buffSize - offset), blockSize_p2,
+				  blockCount_p2, remainSize_p2));
+		}
+
+		for (i =3D 0; i < blockCount_p2; i++) {
+			ret =3D rtw_writeN(padapter,
+					 (FW_8723A_START_ADDRESS + offset +
+					  i * blockSize_p2), blockSize_p2,
+					 (bufferPtr + offset +
+					  i * blockSize_p2));
+
+			if (ret =3D=3D _FAIL)
+				goto exit;
+		}
+	}
+
+	/* 3 Phase #3 */
+	if (remainSize_p2) {
+		offset =3D (blockCount_p1 * blockSize_p1) +
+			(blockCount_p2 * blockSize_p2);
+
+		blockCount_p3 =3D remainSize_p2 / blockSize_p3;
+
+		RT_TRACE(_module_hal_init_c_, _drv_notice_,
+			 ("_BlockWrite: [P3] buffSize_p3(%d) blockSize_p3(%d) "
+			  "blockCount_p3(%d)\n",
+			  (buffSize - offset), blockSize_p3, blockCount_p3));
+
+		for (i =3D 0; i < blockCount_p3; i++) {
+			ret =3D rtw_write8(padapter,
+					 (FW_8723A_START_ADDRESS + offset + i),
+					 *(bufferPtr + offset + i));
+
+			if (ret =3D=3D _FAIL)
+				goto exit;
+		}
+	}
+
+exit:
+	return ret;
+}
+
+static int
+_PageWrite(struct rtw_adapter *padapter, u32 page, void *buffer, u32 s=
ize)
+{
+	u8 value8;
+	u8 u8Page =3D (u8) (page & 0x07);
+
+	value8 =3D (rtw_read8(padapter, REG_MCUFWDL + 2) & 0xF8) | u8Page;
+	rtw_write8(padapter, REG_MCUFWDL + 2, value8);
+
+	return _BlockWrite(padapter, buffer, size);
+}
+
+static int _WriteFW(struct rtw_adapter *padapter, void *buffer, u32 si=
ze)
+{
+	/*  Since we need dynamic decide method of dwonload fw, so we
+	    call this function to get chip version. */
+	/*  We can remove _ReadChipVersion from ReadpadapterInfo8192C later. =
*/
+	int ret =3D _SUCCESS;
+	u32 pageNums, remainSize;
+	u32 page, offset;
+	u8 *bufferPtr =3D (u8 *) buffer;
+
+	pageNums =3D size / MAX_PAGE_SIZE;
+	/* RT_ASSERT((pageNums <=3D 4),
+	   ("Page numbers should not greater then 4 \n")); */
+	remainSize =3D size % MAX_PAGE_SIZE;
+
+	for (page =3D 0; page < pageNums; page++) {
+		offset =3D page * MAX_PAGE_SIZE;
+		ret =3D _PageWrite(padapter, page, bufferPtr + offset,
+				 MAX_PAGE_SIZE);
+
+		if (ret =3D=3D _FAIL)
+			goto exit;
+	}
+	if (remainSize) {
+		offset =3D pageNums * MAX_PAGE_SIZE;
+		page =3D pageNums;
+		ret =3D _PageWrite(padapter, page, bufferPtr + offset,
+				 remainSize);
+
+		if (ret =3D=3D _FAIL)
+			goto exit;
+	}
+	RT_TRACE(_module_hal_init_c_, _drv_info_,
+		 ("_WriteFW Done- for Normal chip.\n"));
+
+exit:
+	return ret;
+}
+
+static s32 _FWFreeToGo(struct rtw_adapter *padapter)
+{
+	u32 counter =3D 0;
+	u32 value32;
+
+	/*  polling CheckSum report */
+	do {
+		value32 =3D rtw_read32(padapter, REG_MCUFWDL);
+		if (value32 & FWDL_ChkSum_rpt)
+			break;
+	} while (counter++ < POLLING_READY_TIMEOUT_COUNT);
+
+	if (counter >=3D POLLING_READY_TIMEOUT_COUNT) {
+		RT_TRACE(_module_hal_init_c_, _drv_err_,
+			 ("%s: chksum report fail! REG_MCUFWDL:0x%08x\n",
+			  __func__, value32));
+		return _FAIL;
+	}
+	RT_TRACE(_module_hal_init_c_, _drv_info_,
+		 ("%s: Checksum report OK! REG_MCUFWDL:0x%08x\n", __func__,
+		  value32));
+
+	value32 =3D rtw_read32(padapter, REG_MCUFWDL);
+	value32 |=3D MCUFWDL_RDY;
+	value32 &=3D ~WINTINI_RDY;
+	rtw_write32(padapter, REG_MCUFWDL, value32);
+
+	/*  polling for FW ready */
+	counter =3D 0;
+	do {
+		value32 =3D rtw_read32(padapter, REG_MCUFWDL);
+		if (value32 & WINTINI_RDY) {
+			RT_TRACE(_module_hal_init_c_, _drv_info_,
+				 ("%s: Polling FW ready success!! "
+				  "REG_MCUFWDL:0x%08x\n",
+				  __func__, value32));
+			return _SUCCESS;
+		}
+		udelay(5);
+	} while (counter++ < POLLING_READY_TIMEOUT_COUNT);
+
+	RT_TRACE(_module_hal_init_c_, _drv_err_,
+		 ("%s: Polling FW ready fail!! REG_MCUFWDL:0x%08x\n",
+		  __func__, value32));
+	return _FAIL;
+}
+
+#define IS_FW_81xxC(padapter)	(((GET_HAL_DATA(padapter))->FirmwareSign=
ature & 0xFFF0) =3D=3D 0x88C0)
+
+void rtl8723a_FirmwareSelfReset(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u8 u1bTmp;
+	u8 Delay =3D 100;
+
+	if (!(IS_FW_81xxC(padapter) &&
+	      ((pHalData->FirmwareVersion < 0x21) ||
+	       (pHalData->FirmwareVersion =3D=3D 0x21 &&
+		pHalData->FirmwareSubVersion < 0x01)))) {
+		/*  after 88C Fw v33.1 */
+		/* 0x1cf =3D 0x20. Inform 8051 to reset. 2009.12.25. tynli_test */
+		rtw_write8(padapter, REG_HMETFR + 3, 0x20);
+
+		u1bTmp =3D rtw_read8(padapter, REG_SYS_FUNC_EN + 1);
+		while (u1bTmp & BIT2) {
+			Delay--;
+			if (Delay =3D=3D 0)
+				break;
+			udelay(50);
+			u1bTmp =3D rtw_read8(padapter, REG_SYS_FUNC_EN + 1);
+		}
+		RT_TRACE(_module_hal_init_c_, _drv_info_,
+			 ("-%s: 8051 reset success (%d)\n", __func__,
+			  Delay));
+
+		if ((Delay =3D=3D 0)) {
+			/* force firmware reset */
+			u1bTmp =3D rtw_read8(padapter, REG_SYS_FUNC_EN + 1);
+			rtw_write8(padapter, REG_SYS_FUNC_EN + 1,
+				   u1bTmp & (~BIT2));
+		}
+	}
+}
+
+/*  */
+/*	Description: */
+/*		Download 8192C firmware code. */
+/*  */
+/*  */
+s32 rtl8723a_FirmwareDownload(struct rtw_adapter *padapter)
+{
+	s32 rtStatus =3D _SUCCESS;
+	u8 writeFW_retry =3D 0;
+	unsigned long fwdl_start_time;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct dvobj_priv *dvobj =3D adapter_to_dvobj(padapter);
+	struct device *device =3D dvobj_to_dev(dvobj);
+	struct rt_8723a_firmware_hdr *pFwHdr =3D NULL;
+	const struct firmware *fw;
+	char *fw_name;
+	u8 *firmware_buf =3D NULL;
+	u8 *buf;
+	int fw_size;
+	static int log_version;
+
+	RT_TRACE(_module_hal_init_c_, _drv_info_, ("+%s\n", __func__));
+
+	if (IS_8723A_A_CUT(pHalData->VersionID)) {
+		fw_name =3D "rtlwifi/rtl8723aufw.bin";
+		RT_TRACE(_module_hal_init_c_, _drv_info_,
+			 ("rtl8723a_FirmwareDownload: R8723FwImageArray_UMC "
+			  "for RTL8723A A CUT\n"));
+	} else if (IS_8723A_B_CUT(pHalData->VersionID)) {
+		/*  WLAN Fw. */
+		if (padapter->registrypriv.wifi_spec =3D=3D 1) {
+			fw_name =3D "rtlwifi/rtl8723aufw_B_NoBT.bin";
+			DBG_8723A(" Rtl8723_FwUMCBCutImageArrayWithoutBT for "
+				  "RTL8723A B CUT\n");
+		} else {
+#ifdef CONFIG_8723AU_BT_COEXIST
+			fw_name =3D "rtlwifi/rtl8723aufw_B.bin";
+			DBG_8723A(" Rtl8723_FwUMCBCutImageArrayWithBT for "
+				  "RTL8723A B CUT\n");
+#else
+			fw_name =3D "rtlwifi/rtl8723aufw_B_NoBT.bin";
+			DBG_8723A(" Rtl8723_FwUMCBCutImageArrayWithoutBT for "
+				  "RTL8723A B CUT\n");
+#endif
+		}
+	} else {
+		/*  <Roger_TODO> We should download proper RAM Code here
+		    to match the ROM code. */
+		RT_TRACE(_module_hal_init_c_, _drv_err_,
+			 ("%s: unknow version!\n", __func__));
+		rtStatus =3D _FAIL;
+		goto Exit;
+	}
+
+	pr_info("rtl8723au: Loading firmware %s\n", fw_name);
+	if (request_firmware(&fw, fw_name, device)) {
+		pr_err("rtl8723au: request_firmware load failed\n");
+		rtStatus =3D _FAIL;
+		goto Exit;
+	}
+	if (!fw) {
+		pr_err("rtl8723au: Firmware %s not available\n", fw_name);
+		rtStatus =3D _FAIL;
+		goto Exit;
+	}
+	firmware_buf =3D kzalloc(fw->size, GFP_KERNEL);
+	if (!firmware_buf) {
+		rtStatus =3D _FAIL;
+		goto Exit;
+	}
+	memcpy(firmware_buf, fw->data, fw->size);
+	buf =3D firmware_buf;
+	fw_size =3D fw->size;
+	release_firmware(fw);
+
+	/*  To Check Fw header. Added by tynli. 2009.12.04. */
+	pFwHdr =3D (struct rt_8723a_firmware_hdr *)firmware_buf;
+
+	pHalData->FirmwareVersion =3D le16_to_cpu(pFwHdr->Version);
+	pHalData->FirmwareSubVersion =3D pFwHdr->Subversion;
+	pHalData->FirmwareSignature =3D le16_to_cpu(pFwHdr->Signature);
+
+	DBG_8723A("%s: fw_ver =3D%d fw_subver =3D%d sig =3D 0x%x\n",
+		  __func__, pHalData->FirmwareVersion,
+		  pHalData->FirmwareSubVersion, pHalData->FirmwareSignature);
+
+	if (!log_version++)
+		pr_info("%sFirmware Version %d, SubVersion %d, Signature "
+			"0x%x\n", DRIVER_PREFIX, pHalData->FirmwareVersion,
+			pHalData->FirmwareSubVersion,
+			pHalData->FirmwareSignature);
+
+	if (IS_FW_HEADER_EXIST(pFwHdr)) {
+		/*  Shift 32 bytes for FW header */
+		buf =3D buf + 32;
+		fw_size =3D fw_size - 32;
+	}
+
+	/*  Suggested by Filen. If 8051 is running in RAM code, driver should
+	    inform Fw to reset by itself, */
+	/*  or it will cause download Fw fail. 2010.02.01. by tynli. */
+	if (rtw_read8(padapter, REG_MCUFWDL) & RAM_DL_SEL) {
+		/* 8051 RAM code */
+		rtl8723a_FirmwareSelfReset(padapter);
+		rtw_write8(padapter, REG_MCUFWDL, 0x00);
+	}
+
+	_FWDownloadEnable(padapter, true);
+	fwdl_start_time =3D jiffies;
+	while (1) {
+		/* reset the FWDL chksum */
+		rtw_write8(padapter, REG_MCUFWDL,
+			   rtw_read8(padapter, REG_MCUFWDL) | FWDL_ChkSum_rpt);
+
+		rtStatus =3D _WriteFW(padapter, buf, fw_size);
+
+		if (rtStatus =3D=3D _SUCCESS ||
+		    (rtw_get_passing_time_ms23a(fwdl_start_time) > 500 &&
+		     writeFW_retry++ >=3D 3))
+			break;
+
+		DBG_8723A("%s writeFW_retry:%u, time after fwdl_start_time:"
+			  "%ums\n", __func__, writeFW_retry,
+			  jiffies_to_msecs(jiffies - fwdl_start_time));
+	}
+	_FWDownloadEnable(padapter, false);
+	if (_SUCCESS !=3D rtStatus) {
+		DBG_8723A("DL Firmware failed!\n");
+		goto Exit;
+	}
+
+	rtStatus =3D _FWFreeToGo(padapter);
+	if (_SUCCESS !=3D rtStatus) {
+		RT_TRACE(_module_hal_init_c_, _drv_err_,
+			 ("DL Firmware failed!\n"));
+		goto Exit;
+	}
+	RT_TRACE(_module_hal_init_c_, _drv_info_,
+		 ("Firmware is ready to run!\n"));
+
+Exit:
+	kfree(firmware_buf);
+	return rtStatus;
+}
+
+void rtl8723a_InitializeFirmwareVars(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	/*  Init Fw LPS related. */
+	padapter->pwrctrlpriv.bFwCurrentInPSMode =3D false;
+
+	/*  Init H2C counter. by tynli. 2009.12.09. */
+	pHalData->LastHMEBoxNum =3D 0;
+}
+
+static void rtl8723a_free_hal_data(struct rtw_adapter *padapter)
+{
+
+	kfree(padapter->HalData);
+	padapter->HalData =3D NULL;
+
+}
+
+/*  */
+/*				Efuse related code */
+/*  */
+static u8
+hal_EfuseSwitchToBank(struct rtw_adapter *padapter, u8 bank)
+{
+	u8 bRet =3D false;
+	u32 value32 =3D 0;
+
+	DBG_8723A("%s: Efuse switch bank to %d\n", __func__, bank);
+	value32 =3D rtw_read32(padapter, EFUSE_TEST);
+	bRet =3D true;
+	switch (bank) {
+	case 0:
+		value32 =3D (value32 & ~EFUSE_SEL_MASK) |
+			EFUSE_SEL(EFUSE_WIFI_SEL_0);
+		break;
+	case 1:
+		value32 =3D (value32 & ~EFUSE_SEL_MASK) |
+			EFUSE_SEL(EFUSE_BT_SEL_0);
+		break;
+	case 2:
+		value32 =3D (value32 & ~EFUSE_SEL_MASK) |
+			EFUSE_SEL(EFUSE_BT_SEL_1);
+		break;
+	case 3:
+		value32 =3D (value32 & ~EFUSE_SEL_MASK) |
+			EFUSE_SEL(EFUSE_BT_SEL_2);
+		break;
+	default:
+		value32 =3D (value32 & ~EFUSE_SEL_MASK) |
+			EFUSE_SEL(EFUSE_WIFI_SEL_0);
+		bRet =3D false;
+		break;
+	}
+	rtw_write32(padapter, EFUSE_TEST, value32);
+
+	return bRet;
+}
+
+static void
+Hal_GetEfuseDefinition(struct rtw_adapter *padapter,
+		       u8 efuseType, u8 type, void *pOut)
+{
+	u8 *pu1Tmp;
+	u16 *pu2Tmp;
+	u8 *pMax_section;
+
+	switch (type) {
+	case TYPE_EFUSE_MAX_SECTION:
+		pMax_section =3D (u8 *) pOut;
+
+		if (efuseType =3D=3D EFUSE_WIFI)
+			*pMax_section =3D EFUSE_MAX_SECTION_8723A;
+		else
+			*pMax_section =3D EFUSE_BT_MAX_SECTION;
+		break;
+
+	case TYPE_EFUSE_REAL_CONTENT_LEN:
+		pu2Tmp =3D (u16 *) pOut;
+
+		if (efuseType =3D=3D EFUSE_WIFI)
+			*pu2Tmp =3D EFUSE_REAL_CONTENT_LEN_8723A;
+		else
+			*pu2Tmp =3D EFUSE_BT_REAL_CONTENT_LEN;
+		break;
+
+	case TYPE_AVAILABLE_EFUSE_BYTES_BANK:
+		pu2Tmp =3D (u16 *) pOut;
+
+		if (efuseType =3D=3D EFUSE_WIFI)
+			*pu2Tmp =3D (EFUSE_REAL_CONTENT_LEN_8723A -
+				   EFUSE_OOB_PROTECT_BYTES);
+		else
+			*pu2Tmp =3D (EFUSE_BT_REAL_BANK_CONTENT_LEN -
+				   EFUSE_PROTECT_BYTES_BANK);
+		break;
+
+	case TYPE_AVAILABLE_EFUSE_BYTES_TOTAL:
+		pu2Tmp =3D (u16 *) pOut;
+
+		if (efuseType =3D=3D EFUSE_WIFI)
+			*pu2Tmp =3D (EFUSE_REAL_CONTENT_LEN_8723A -
+				   EFUSE_OOB_PROTECT_BYTES);
+		else
+			*pu2Tmp =3D (EFUSE_BT_REAL_CONTENT_LEN -
+				   (EFUSE_PROTECT_BYTES_BANK * 3));
+		break;
+
+	case TYPE_EFUSE_MAP_LEN:
+		pu2Tmp =3D (u16 *) pOut;
+
+		if (efuseType =3D=3D EFUSE_WIFI)
+			*pu2Tmp =3D EFUSE_MAP_LEN_8723A;
+		else
+			*pu2Tmp =3D EFUSE_BT_MAP_LEN;
+		break;
+
+	case TYPE_EFUSE_PROTECT_BYTES_BANK:
+		pu1Tmp =3D (u8 *) pOut;
+
+		if (efuseType =3D=3D EFUSE_WIFI)
+			*pu1Tmp =3D EFUSE_OOB_PROTECT_BYTES;
+		else
+			*pu1Tmp =3D EFUSE_PROTECT_BYTES_BANK;
+		break;
+
+	case TYPE_EFUSE_CONTENT_LEN_BANK:
+		pu2Tmp =3D (u16 *) pOut;
+
+		if (efuseType =3D=3D EFUSE_WIFI)
+			*pu2Tmp =3D EFUSE_REAL_CONTENT_LEN_8723A;
+		else
+			*pu2Tmp =3D EFUSE_BT_REAL_BANK_CONTENT_LEN;
+		break;
+
+	default:
+		pu1Tmp =3D (u8 *) pOut;
+		*pu1Tmp =3D 0;
+		break;
+	}
+}
+
+#define VOLTAGE_V25		0x03
+#define LDOE25_SHIFT	28
+
+static void
+Hal_EfusePowerSwitch(struct rtw_adapter *padapter, u8 bWrite, u8 PwrSt=
ate)
+{
+	u8 tempval;
+	u16 tmpV16;
+
+	if (PwrState =3D=3D true) {
+		rtw_write8(padapter, REG_EFUSE_ACCESS, EFUSE_ACCESS_ON);
+
+		/*  1.2V Power: From VDDON with Power
+		    Cut(0x0000h[15]), defualt valid */
+		tmpV16 =3D rtw_read16(padapter, REG_SYS_ISO_CTRL);
+		if (!(tmpV16 & PWC_EV12V)) {
+			tmpV16 |=3D PWC_EV12V;
+			rtw_write16(padapter, REG_SYS_ISO_CTRL, tmpV16);
+		}
+		/*  Reset: 0x0000h[28], default valid */
+		tmpV16 =3D rtw_read16(padapter, REG_SYS_FUNC_EN);
+		if (!(tmpV16 & FEN_ELDR)) {
+			tmpV16 |=3D FEN_ELDR;
+			rtw_write16(padapter, REG_SYS_FUNC_EN, tmpV16);
+		}
+
+		/*  Clock: Gated(0x0008h[5]) 8M(0x0008h[1]) clock
+		    from ANA, default valid */
+		tmpV16 =3D rtw_read16(padapter, REG_SYS_CLKR);
+		if ((!(tmpV16 & LOADER_CLK_EN)) || (!(tmpV16 & ANA8M))) {
+			tmpV16 |=3D (LOADER_CLK_EN | ANA8M);
+			rtw_write16(padapter, REG_SYS_CLKR, tmpV16);
+		}
+
+		if (bWrite =3D=3D true) {
+			/*  Enable LDO 2.5V before read/write action */
+			tempval =3D rtw_read8(padapter, EFUSE_TEST + 3);
+			tempval &=3D 0x0F;
+			tempval |=3D (VOLTAGE_V25 << 4);
+			rtw_write8(padapter, EFUSE_TEST + 3, (tempval | 0x80));
+		}
+	} else {
+		rtw_write8(padapter, REG_EFUSE_ACCESS, EFUSE_ACCESS_OFF);
+
+		if (bWrite =3D=3D true) {
+			/*  Disable LDO 2.5V after read/write action */
+			tempval =3D rtw_read8(padapter, EFUSE_TEST + 3);
+			rtw_write8(padapter, EFUSE_TEST + 3, (tempval & 0x7F));
+		}
+	}
+}
+
+static void
+hal_ReadEFuse_WiFi(struct rtw_adapter *padapter,
+		   u16 _offset, u16 _size_byte, u8 *pbuf)
+{
+	u8 *efuseTbl =3D NULL;
+	u16 eFuse_Addr =3D 0;
+	u8 offset, wden;
+	u8 efuseHeader, efuseExtHdr, efuseData;
+	u16 i, total, used;
+
+	/*  Do NOT excess total size of EFuse table.
+	    Added by Roger, 2008.11.10. */
+	if ((_offset + _size_byte) > EFUSE_MAP_LEN_8723A) {
+		DBG_8723A("%s: Invalid offset(%#x) with read bytes(%#x)!!\n",
+			  __func__, _offset, _size_byte);
+		return;
+	}
+
+	efuseTbl =3D (u8 *) kmalloc(EFUSE_MAP_LEN_8723A, GFP_KERNEL);
+	if (efuseTbl =3D=3D NULL) {
+		DBG_8723A("%s: alloc efuseTbl fail!\n", __func__);
+		return;
+	}
+	/*  0xff will be efuse default value instead of 0x00. */
+	memset(efuseTbl, 0xFF, EFUSE_MAP_LEN_8723A);
+
+	/*  switch bank back to bank 0 for later BT and wifi use. */
+	hal_EfuseSwitchToBank(padapter, 0);
+
+	while (AVAILABLE_EFUSE_ADDR(eFuse_Addr)) {
+		ReadEFuseByte23a(padapter, eFuse_Addr++, &efuseHeader);
+		if (efuseHeader =3D=3D 0xFF) {
+			DBG_8723A("%s: data end at address =3D%#x\n", __func__,
+				  eFuse_Addr);
+			break;
+		}
+
+		/*  Check PG header for section num. */
+		if (EXT_HEADER(efuseHeader)) {	/* extended header */
+			offset =3D GET_HDR_OFFSET_2_0(efuseHeader);
+
+			ReadEFuseByte23a(padapter, eFuse_Addr++, &efuseExtHdr);
+			if (ALL_WORDS_DISABLED(efuseExtHdr)) {
+				continue;
+			}
+
+			offset |=3D ((efuseExtHdr & 0xF0) >> 1);
+			wden =3D (efuseExtHdr & 0x0F);
+		} else {
+			offset =3D ((efuseHeader >> 4) & 0x0f);
+			wden =3D (efuseHeader & 0x0f);
+		}
+
+		if (offset < EFUSE_MAX_SECTION_8723A) {
+			u16 addr;
+			/*  Get word enable value from PG header */
+
+			addr =3D offset * PGPKT_DATA_SIZE;
+			for (i =3D 0; i < EFUSE_MAX_WORD_UNIT; i++) {
+				/* Check word enable condition in the section */
+				if (!(wden & (0x01 << i))) {
+					ReadEFuseByte23a(padapter, eFuse_Addr++,
+						      &efuseData);
+					efuseTbl[addr] =3D efuseData;
+
+					ReadEFuseByte23a(padapter, eFuse_Addr++,
+						      &efuseData);
+					efuseTbl[addr + 1] =3D efuseData;
+				}
+				addr +=3D 2;
+			}
+		} else {
+			DBG_8723A(KERN_ERR "%s: offset(%d) is illegal!!\n",
+				  __func__, offset);
+			eFuse_Addr +=3D Efuse_CalculateWordCnts23a(wden) * 2;
+		}
+	}
+
+	/*  Copy from Efuse map to output pointer memory!!! */
+	for (i =3D 0; i < _size_byte; i++)
+		pbuf[i] =3D efuseTbl[_offset + i];
+
+	/*  Calculate Efuse utilization */
+	EFUSE_GetEfuseDefinition23a(padapter, EFUSE_WIFI,
+				 TYPE_AVAILABLE_EFUSE_BYTES_TOTAL, &total);
+	used =3D eFuse_Addr - 1;
+	rtw_hal_set_hwreg23a(padapter, HW_VAR_EFUSE_BYTES, (u8 *)&used);
+
+	kfree(efuseTbl);
+}
+
+static void
+hal_ReadEFuse_BT(struct rtw_adapter *padapter,
+		 u16 _offset, u16 _size_byte, u8 *pbuf)
+{
+	u8 *efuseTbl;
+	u8 bank;
+	u16 eFuse_Addr;
+	u8 efuseHeader, efuseExtHdr, efuseData;
+	u8 offset, wden;
+	u16 i, total, used;
+
+	/*  Do NOT excess total size of EFuse table.
+	    Added by Roger, 2008.11.10. */
+	if ((_offset + _size_byte) > EFUSE_BT_MAP_LEN) {
+		DBG_8723A("%s: Invalid offset(%#x) with read bytes(%#x)!!\n",
+			  __func__, _offset, _size_byte);
+		return;
+	}
+
+	efuseTbl =3D kmalloc(EFUSE_BT_MAP_LEN, GFP_KERNEL);
+	if (efuseTbl =3D=3D NULL) {
+		DBG_8723A("%s: efuseTbl malloc fail!\n", __func__);
+		return;
+	}
+	/*  0xff will be efuse default value instead of 0x00. */
+	memset(efuseTbl, 0xFF, EFUSE_BT_MAP_LEN);
+
+	EFUSE_GetEfuseDefinition23a(padapter, EFUSE_BT,
+				 TYPE_AVAILABLE_EFUSE_BYTES_BANK, &total);
+
+	for (bank =3D 1; bank < EFUSE_MAX_BANK; bank++) {
+		if (hal_EfuseSwitchToBank(padapter, bank) =3D=3D false) {
+			DBG_8723A("%s: hal_EfuseSwitchToBank Fail!!\n",
+				  __func__);
+			goto exit;
+		}
+
+		eFuse_Addr =3D 0;
+
+		while (AVAILABLE_EFUSE_ADDR(eFuse_Addr)) {
+			ReadEFuseByte23a(padapter, eFuse_Addr++, &efuseHeader);
+			if (efuseHeader =3D=3D 0xFF)
+				break;
+
+			/*  Check PG header for section num. */
+			if (EXT_HEADER(efuseHeader)) {	/* extended header */
+				offset =3D GET_HDR_OFFSET_2_0(efuseHeader);
+
+				ReadEFuseByte23a(padapter, eFuse_Addr++,
+					      &efuseExtHdr);
+				if (ALL_WORDS_DISABLED(efuseExtHdr)) {
+					continue;
+				}
+
+				offset |=3D ((efuseExtHdr & 0xF0) >> 1);
+				wden =3D (efuseExtHdr & 0x0F);
+			} else {
+				offset =3D ((efuseHeader >> 4) & 0x0f);
+				wden =3D (efuseHeader & 0x0f);
+			}
+
+			if (offset < EFUSE_BT_MAX_SECTION) {
+				u16 addr;
+
+				/*  Get word enable value from PG header */
+
+				addr =3D offset * PGPKT_DATA_SIZE;
+				for (i =3D 0; i < EFUSE_MAX_WORD_UNIT; i++) {
+					/*  Check word enable condition in
+					    the section */
+					if (!(wden & (0x01 << i))) {
+						ReadEFuseByte23a(padapter,
+							      eFuse_Addr++,
+							      &efuseData);
+						efuseTbl[addr] =3D efuseData;
+
+						ReadEFuseByte23a(padapter,
+							      eFuse_Addr++,
+							      &efuseData);
+						efuseTbl[addr + 1] =3D efuseData;
+					}
+					addr +=3D 2;
+				}
+			} else {
+				DBG_8723A(KERN_ERR
+					  "%s: offset(%d) is illegal!!\n",
+					  __func__, offset);
+				eFuse_Addr +=3D Efuse_CalculateWordCnts23a(wden) * 2;
+			}
+		}
+
+		if ((eFuse_Addr - 1) < total) {
+			DBG_8723A("%s: bank(%d) data end at %#x\n",
+				  __func__, bank, eFuse_Addr - 1);
+			break;
+		}
+	}
+
+	/*  switch bank back to bank 0 for later BT and wifi use. */
+	hal_EfuseSwitchToBank(padapter, 0);
+
+	/*  Copy from Efuse map to output pointer memory!!! */
+	for (i =3D 0; i < _size_byte; i++)
+		pbuf[i] =3D efuseTbl[_offset + i];
+
+	/*  */
+	/*  Calculate Efuse utilization. */
+	/*  */
+	EFUSE_GetEfuseDefinition23a(padapter, EFUSE_BT,
+				 TYPE_AVAILABLE_EFUSE_BYTES_TOTAL, &total);
+	used =3D (EFUSE_BT_REAL_BANK_CONTENT_LEN * (bank - 1)) + eFuse_Addr -=
 1;
+	rtw_hal_set_hwreg23a(padapter, HW_VAR_EFUSE_BT_BYTES, (u8 *) &used);
+
+exit:
+	kfree(efuseTbl);
+}
+
+static void
+Hal_ReadEFuse(struct rtw_adapter *padapter,
+	      u8 efuseType, u16 _offset, u16 _size_byte, u8 *pbuf)
+{
+	if (efuseType =3D=3D EFUSE_WIFI)
+		hal_ReadEFuse_WiFi(padapter, _offset, _size_byte, pbuf);
+	else
+		hal_ReadEFuse_BT(padapter, _offset, _size_byte, pbuf);
+}
+
+static u16
+hal_EfuseGetCurrentSize_WiFi(struct rtw_adapter *padapter)
+{
+	u16 efuse_addr =3D 0;
+	u8 hoffset =3D 0, hworden =3D 0;
+	u8 efuse_data, word_cnts =3D 0;
+
+	rtw23a_hal_get_hwreg(padapter, HW_VAR_EFUSE_BYTES, (u8 *) &efuse_addr=
);
+
+	DBG_8723A("%s: start_efuse_addr =3D 0x%X\n", __func__, efuse_addr);
+
+	/*  switch bank back to bank 0 for later BT and wifi use. */
+	hal_EfuseSwitchToBank(padapter, 0);
+
+	while (AVAILABLE_EFUSE_ADDR(efuse_addr)) {
+		if (efuse_OneByteRead23a(padapter, efuse_addr, &efuse_data) =3D=3D
+		    false) {
+			DBG_8723A(KERN_ERR "%s: efuse_OneByteRead23a Fail! "
+				  "addr =3D 0x%X !!\n", __func__, efuse_addr);
+			break;
+		}
+
+		if (efuse_data =3D=3D 0xFF)
+			break;
+
+		if (EXT_HEADER(efuse_data)) {
+			hoffset =3D GET_HDR_OFFSET_2_0(efuse_data);
+			efuse_addr++;
+			efuse_OneByteRead23a(padapter, efuse_addr, &efuse_data);
+			if (ALL_WORDS_DISABLED(efuse_data)) {
+				continue;
+			}
+
+			hoffset |=3D ((efuse_data & 0xF0) >> 1);
+			hworden =3D efuse_data & 0x0F;
+		} else {
+			hoffset =3D (efuse_data >> 4) & 0x0F;
+			hworden =3D efuse_data & 0x0F;
+		}
+
+		word_cnts =3D Efuse_CalculateWordCnts23a(hworden);
+		efuse_addr +=3D (word_cnts * 2) + 1;
+	}
+
+	rtw_hal_set_hwreg23a(padapter, HW_VAR_EFUSE_BYTES, (u8 *) &efuse_addr=
);
+
+	DBG_8723A("%s: CurrentSize =3D%d\n", __func__, efuse_addr);
+
+	return efuse_addr;
+}
+
+static u16
+hal_EfuseGetCurrentSize_BT(struct rtw_adapter *padapter)
+{
+	u16 btusedbytes;
+	u16 efuse_addr;
+	u8 bank, startBank;
+	u8 hoffset =3D 0, hworden =3D 0;
+	u8 efuse_data, word_cnts =3D 0;
+	u16 retU2 =3D 0;
+
+	rtw23a_hal_get_hwreg(padapter, HW_VAR_EFUSE_BT_BYTES, (u8 *) &btusedb=
ytes);
+
+	efuse_addr =3D (u16) ((btusedbytes % EFUSE_BT_REAL_BANK_CONTENT_LEN))=
;
+	startBank =3D (u8) (1 + (btusedbytes / EFUSE_BT_REAL_BANK_CONTENT_LEN=
));
+
+	DBG_8723A("%s: start from bank =3D%d addr =3D 0x%X\n", __func__, star=
tBank,
+		  efuse_addr);
+
+	EFUSE_GetEfuseDefinition23a(padapter, EFUSE_BT,
+				 TYPE_AVAILABLE_EFUSE_BYTES_BANK, &retU2);
+
+	for (bank =3D startBank; bank < EFUSE_MAX_BANK; bank++) {
+		if (hal_EfuseSwitchToBank(padapter, bank) =3D=3D false) {
+			DBG_8723A(KERN_ERR "%s: switch bank(%d) Fail!!\n",
+				  __func__, bank);
+			bank =3D EFUSE_MAX_BANK;
+			break;
+		}
+
+		/*  only when bank is switched we have to reset
+		    the efuse_addr. */
+		if (bank !=3D startBank)
+			efuse_addr =3D 0;
+
+		while (AVAILABLE_EFUSE_ADDR(efuse_addr)) {
+			if (efuse_OneByteRead23a(padapter, efuse_addr,
+					      &efuse_data) =3D=3D false) {
+				DBG_8723A(KERN_ERR "%s: efuse_OneByteRead23a Fail!"
+					  " addr =3D 0x%X !!\n",
+					  __func__, efuse_addr);
+				bank =3D EFUSE_MAX_BANK;
+				break;
+			}
+
+			if (efuse_data =3D=3D 0xFF)
+				break;
+
+			if (EXT_HEADER(efuse_data)) {
+				hoffset =3D GET_HDR_OFFSET_2_0(efuse_data);
+				efuse_addr++;
+				efuse_OneByteRead23a(padapter, efuse_addr,
+						  &efuse_data);
+				if (ALL_WORDS_DISABLED(efuse_data)) {
+					efuse_addr++;
+					continue;
+				}
+
+				hoffset |=3D ((efuse_data & 0xF0) >> 1);
+				hworden =3D efuse_data & 0x0F;
+			} else {
+				hoffset =3D (efuse_data >> 4) & 0x0F;
+				hworden =3D efuse_data & 0x0F;
+			}
+			word_cnts =3D Efuse_CalculateWordCnts23a(hworden);
+			/* read next header */
+			efuse_addr +=3D (word_cnts * 2) + 1;
+		}
+
+		/*  Check if we need to check next bank efuse */
+		if (efuse_addr < retU2) {
+			break;	/*  don't need to check next bank. */
+		}
+	}
+
+	retU2 =3D ((bank - 1) * EFUSE_BT_REAL_BANK_CONTENT_LEN) + efuse_addr;
+	rtw_hal_set_hwreg23a(padapter, HW_VAR_EFUSE_BT_BYTES, (u8 *)&retU2);
+
+	DBG_8723A("%s: CurrentSize =3D%d\n", __func__, retU2);
+	return retU2;
+}
+
+static u16
+Hal_EfuseGetCurrentSize(struct rtw_adapter *pAdapter, u8 efuseType)
+{
+	u16 ret =3D 0;
+
+	if (efuseType =3D=3D EFUSE_WIFI)
+		ret =3D hal_EfuseGetCurrentSize_WiFi(pAdapter);
+	else
+		ret =3D hal_EfuseGetCurrentSize_BT(pAdapter);
+
+	return ret;
+}
+
+static u8
+Hal_EfuseWordEnableDataWrite(struct rtw_adapter *padapter,
+			     u16 efuse_addr, u8 word_en, u8 *data)
+{
+	u16 tmpaddr =3D 0;
+	u16 start_addr =3D efuse_addr;
+	u8 badworden =3D 0x0F;
+	u8 tmpdata[PGPKT_DATA_SIZE];
+
+	memset(tmpdata, 0xFF, PGPKT_DATA_SIZE);
+
+	if (!(word_en & BIT(0))) {
+		tmpaddr =3D start_addr;
+		efuse_OneByteWrite23a(padapter, start_addr++, data[0]);
+		efuse_OneByteWrite23a(padapter, start_addr++, data[1]);
+
+		efuse_OneByteRead23a(padapter, tmpaddr, &tmpdata[0]);
+		efuse_OneByteRead23a(padapter, tmpaddr + 1, &tmpdata[1]);
+		if ((data[0] !=3D tmpdata[0]) || (data[1] !=3D tmpdata[1])) {
+			badworden &=3D (~BIT(0));
+		}
+	}
+	if (!(word_en & BIT(1))) {
+		tmpaddr =3D start_addr;
+		efuse_OneByteWrite23a(padapter, start_addr++, data[2]);
+		efuse_OneByteWrite23a(padapter, start_addr++, data[3]);
+
+		efuse_OneByteRead23a(padapter, tmpaddr, &tmpdata[2]);
+		efuse_OneByteRead23a(padapter, tmpaddr + 1, &tmpdata[3]);
+		if ((data[2] !=3D tmpdata[2]) || (data[3] !=3D tmpdata[3])) {
+			badworden &=3D (~BIT(1));
+		}
+	}
+	if (!(word_en & BIT(2))) {
+		tmpaddr =3D start_addr;
+		efuse_OneByteWrite23a(padapter, start_addr++, data[4]);
+		efuse_OneByteWrite23a(padapter, start_addr++, data[5]);
+
+		efuse_OneByteRead23a(padapter, tmpaddr, &tmpdata[4]);
+		efuse_OneByteRead23a(padapter, tmpaddr + 1, &tmpdata[5]);
+		if ((data[4] !=3D tmpdata[4]) || (data[5] !=3D tmpdata[5])) {
+			badworden &=3D (~BIT(2));
+		}
+	}
+	if (!(word_en & BIT(3))) {
+		tmpaddr =3D start_addr;
+		efuse_OneByteWrite23a(padapter, start_addr++, data[6]);
+		efuse_OneByteWrite23a(padapter, start_addr++, data[7]);
+
+		efuse_OneByteRead23a(padapter, tmpaddr, &tmpdata[6]);
+		efuse_OneByteRead23a(padapter, tmpaddr + 1, &tmpdata[7]);
+		if ((data[6] !=3D tmpdata[6]) || (data[7] !=3D tmpdata[7])) {
+			badworden &=3D (~BIT(3));
+		}
+	}
+
+	return badworden;
+}
+
+static s32
+Hal_EfusePgPacketRead(struct rtw_adapter *padapter, u8 offset, u8 *dat=
a)
+{
+	u8 efuse_data, word_cnts =3D 0;
+	u16 efuse_addr =3D 0;
+	u8 hoffset =3D 0, hworden =3D 0;
+	u8 i;
+	u8 max_section =3D 0;
+	s32 ret;
+
+	if (data =3D=3D NULL)
+		return false;
+
+	EFUSE_GetEfuseDefinition23a(padapter, EFUSE_WIFI, TYPE_EFUSE_MAX_SECT=
ION,
+				 &max_section);
+	if (offset > max_section) {
+		DBG_8723A("%s: Packet offset(%d) is illegal(>%d)!\n",
+			  __func__, offset, max_section);
+		return false;
+	}
+
+	memset(data, 0xFF, PGPKT_DATA_SIZE);
+	ret =3D true;
+
+	/*  */
+	/*  <Roger_TODO> Efuse has been pre-programmed dummy 5Bytes at the
+	    end of Efuse by CP. */
+	/*  Skip dummy parts to prevent unexpected data read from Efuse. */
+	/*  By pass right now. 2009.02.19. */
+	/*  */
+	while (AVAILABLE_EFUSE_ADDR(efuse_addr)) {
+		if (efuse_OneByteRead23a(padapter, efuse_addr++, &efuse_data) =3D=3D
+		    false) {
+			ret =3D false;
+			break;
+		}
+
+		if (efuse_data =3D=3D 0xFF)
+			break;
+
+		if (EXT_HEADER(efuse_data)) {
+			hoffset =3D GET_HDR_OFFSET_2_0(efuse_data);
+			efuse_OneByteRead23a(padapter, efuse_addr++, &efuse_data);
+			if (ALL_WORDS_DISABLED(efuse_data)) {
+				DBG_8723A("%s: Error!! All words disabled!\n",
+					  __func__);
+				continue;
+			}
+
+			hoffset |=3D ((efuse_data & 0xF0) >> 1);
+			hworden =3D efuse_data & 0x0F;
+		} else {
+			hoffset =3D (efuse_data >> 4) & 0x0F;
+			hworden =3D efuse_data & 0x0F;
+		}
+
+		if (hoffset =3D=3D offset) {
+			for (i =3D 0; i < EFUSE_MAX_WORD_UNIT; i++) {
+				/* Check word enable condition in the section */
+				if (!(hworden & (0x01 << i))) {
+					ReadEFuseByte23a(padapter, efuse_addr++,
+						      &efuse_data);
+					data[i * 2] =3D efuse_data;
+
+					ReadEFuseByte23a(padapter, efuse_addr++,
+						      &efuse_data);
+					data[(i * 2) + 1] =3D efuse_data;
+				}
+			}
+		} else {
+			word_cnts =3D Efuse_CalculateWordCnts23a(hworden);
+			efuse_addr +=3D word_cnts * 2;
+		}
+	}
+
+	return ret;
+}
+
+static u8
+hal_EfusePgCheckAvailableAddr(struct rtw_adapter *pAdapter, u8 efuseTy=
pe)
+{
+	u16 max_available =3D 0;
+	u16 current_size;
+
+	EFUSE_GetEfuseDefinition23a(pAdapter, efuseType,
+				 TYPE_AVAILABLE_EFUSE_BYTES_TOTAL,
+				 &max_available);
+
+	current_size =3D Efuse_GetCurrentSize23a(pAdapter, efuseType);
+	if (current_size >=3D max_available) {
+		DBG_8723A("%s: Error!! current_size(%d)>max_available(%d)\n",
+			  __func__, current_size, max_available);
+		return false;
+	}
+	return true;
+}
+
+static void
+hal_EfuseConstructPGPkt(u8 offset, u8 word_en, u8 *pData,
+			struct pg_pkt_struct *pTargetPkt)
+{
+	memset(pTargetPkt->data, 0xFF, PGPKT_DATA_SIZE);
+	pTargetPkt->offset =3D offset;
+	pTargetPkt->word_en =3D word_en;
+	efuse_WordEnableDataRead23a(word_en, pData, pTargetPkt->data);
+	pTargetPkt->word_cnts =3D Efuse_CalculateWordCnts23a(pTargetPkt->word=
_en);
+}
+
+static u8
+hal_EfusePartialWriteCheck(struct rtw_adapter *padapter, u8 efuseType,
+			   u16 *pAddr, struct pg_pkt_struct *pTargetPkt)
+{
+	u8 bRet =3D false;
+	u16 startAddr =3D 0, efuse_max_available_len =3D 0, efuse_max =3D 0;
+	u8 efuse_data =3D 0;
+
+	EFUSE_GetEfuseDefinition23a(padapter, efuseType,
+				 TYPE_AVAILABLE_EFUSE_BYTES_TOTAL,
+				 &efuse_max_available_len);
+	EFUSE_GetEfuseDefinition23a(padapter, efuseType,
+				 TYPE_EFUSE_CONTENT_LEN_BANK, &efuse_max);
+
+	if (efuseType =3D=3D EFUSE_WIFI) {
+		rtw23a_hal_get_hwreg(padapter, HW_VAR_EFUSE_BYTES,
+				  (u8 *) &startAddr);
+	} else {
+		rtw23a_hal_get_hwreg(padapter, HW_VAR_EFUSE_BT_BYTES,
+				  (u8 *) &startAddr);
+	}
+	startAddr %=3D efuse_max;
+
+	while (1) {
+		if (startAddr >=3D efuse_max_available_len) {
+			bRet =3D false;
+			DBG_8723A("%s: startAddr(%d) >=3D efuse_max_available_"
+				  "len(%d)\n", __func__, startAddr,
+				  efuse_max_available_len);
+			break;
+		}
+
+		if (efuse_OneByteRead23a(padapter, startAddr, &efuse_data) &&
+		    (efuse_data !=3D 0xFF)) {
+			bRet =3D false;
+			DBG_8723A("%s: Something Wrong! last bytes(%#X =3D 0x%02X) "
+				  "is not 0xFF\n", __func__,
+				  startAddr, efuse_data);
+			break;
+		} else {
+			/*  not used header, 0xff */
+			*pAddr =3D startAddr;
+			bRet =3D true;
+			break;
+		}
+	}
+
+	return bRet;
+}
+
+static u8
+hal_EfusePgPacketWrite1ByteHeader(struct rtw_adapter *pAdapter, u8 efu=
seType,
+				  u16 *pAddr, struct pg_pkt_struct *pTargetPkt)
+{
+	u8 pg_header =3D 0, tmp_header =3D 0;
+	u16 efuse_addr =3D *pAddr;
+	u8 repeatcnt =3D 0;
+
+	pg_header =3D ((pTargetPkt->offset << 4) & 0xf0) | pTargetPkt->word_e=
n;
+
+	do {
+		efuse_OneByteWrite23a(pAdapter, efuse_addr, pg_header);
+		efuse_OneByteRead23a(pAdapter, efuse_addr, &tmp_header);
+		if (tmp_header !=3D 0xFF)
+			break;
+		if (repeatcnt++ > EFUSE_REPEAT_THRESHOLD_) {
+			DBG_8723A("%s: Repeat over limit for pg_header!!\n",
+				  __func__);
+			return false;
+		}
+	} while (1);
+
+	if (tmp_header !=3D pg_header) {
+		DBG_8723A(KERN_ERR "%s: PG Header Fail!!(pg =3D 0x%02X "
+			  "read =3D 0x%02X)\n", __func__,
+			  pg_header, tmp_header);
+		return false;
+	}
+
+	*pAddr =3D efuse_addr;
+
+	return true;
+}
+
+static u8
+hal_EfusePgPacketWrite2ByteHeader(struct rtw_adapter *padapter, u8 efu=
seType,
+				  u16 *pAddr, struct pg_pkt_struct *pTargetPkt)
+{
+	u16 efuse_addr, efuse_max_available_len =3D 0;
+	u8 pg_header =3D 0, tmp_header =3D 0;
+	u8 repeatcnt =3D 0;
+
+	EFUSE_GetEfuseDefinition23a(padapter, efuseType,
+				 TYPE_AVAILABLE_EFUSE_BYTES_BANK,
+				 &efuse_max_available_len);
+
+	efuse_addr =3D *pAddr;
+	if (efuse_addr >=3D efuse_max_available_len) {
+		DBG_8723A("%s: addr(%d) over avaliable(%d)!!\n", __func__,
+			  efuse_addr, efuse_max_available_len);
+		return false;
+	}
+
+	pg_header =3D ((pTargetPkt->offset & 0x07) << 5) | 0x0F;
+
+	do {
+		efuse_OneByteWrite23a(padapter, efuse_addr, pg_header);
+		efuse_OneByteRead23a(padapter, efuse_addr, &tmp_header);
+		if (tmp_header !=3D 0xFF)
+			break;
+		if (repeatcnt++ > EFUSE_REPEAT_THRESHOLD_) {
+			DBG_8723A("%s: Repeat over limit for pg_header!!\n",
+				  __func__);
+			return false;
+		}
+	} while (1);
+
+	if (tmp_header !=3D pg_header) {
+		DBG_8723A(KERN_ERR
+			  "%s: PG Header Fail!!(pg =3D 0x%02X read =3D 0x%02X)\n",
+			  __func__, pg_header, tmp_header);
+		return false;
+	}
+
+	/*  to write ext_header */
+	efuse_addr++;
+	pg_header =3D ((pTargetPkt->offset & 0x78) << 1) | pTargetPkt->word_e=
n;
+
+	do {
+		efuse_OneByteWrite23a(padapter, efuse_addr, pg_header);
+		efuse_OneByteRead23a(padapter, efuse_addr, &tmp_header);
+		if (tmp_header !=3D 0xFF)
+			break;
+		if (repeatcnt++ > EFUSE_REPEAT_THRESHOLD_) {
+			DBG_8723A("%s: Repeat over limit for ext_header!!\n",
+				  __func__);
+			return false;
+		}
+	} while (1);
+
+	if (tmp_header !=3D pg_header) {	/* offset PG fail */
+		DBG_8723A(KERN_ERR
+			  "%s: PG EXT Header Fail!!(pg =3D 0x%02X read =3D 0x%02X)\n",
+			  __func__, pg_header, tmp_header);
+		return false;
+	}
+
+	*pAddr =3D efuse_addr;
+
+	return true;
+}
+
+static u8
+hal_EfusePgPacketWriteHeader(struct rtw_adapter *padapter, u8 efuseTyp=
e,
+			     u16 *pAddr, struct pg_pkt_struct *pTargetPkt)
+{
+	u8 bRet =3D false;
+
+	if (pTargetPkt->offset >=3D EFUSE_MAX_SECTION_BASE) {
+		bRet =3D hal_EfusePgPacketWrite2ByteHeader(padapter, efuseType,
+							 pAddr, pTargetPkt);
+	} else {
+		bRet =3D hal_EfusePgPacketWrite1ByteHeader(padapter, efuseType,
+							 pAddr, pTargetPkt);
+	}
+
+	return bRet;
+}
+
+static u8
+hal_EfusePgPacketWriteData(struct rtw_adapter *pAdapter, u8 efuseType,
+			   u16 *pAddr, struct pg_pkt_struct *pTargetPkt)
+{
+	u16 efuse_addr;
+	u8 badworden;
+
+	efuse_addr =3D *pAddr;
+	badworden =3D
+	    Efuse_WordEnableDataWrite23a(pAdapter, efuse_addr + 1,
+				      pTargetPkt->word_en, pTargetPkt->data);
+	if (badworden !=3D 0x0F) {
+		DBG_8723A("%s: Fail!!\n", __func__);
+		return false;
+	}
+
+	return true;
+}
+
+static s32
+Hal_EfusePgPacketWrite(struct rtw_adapter *padapter,
+		       u8 offset, u8 word_en, u8 *pData)
+{
+	struct pg_pkt_struct targetPkt;
+	u16 startAddr =3D 0;
+	u8 efuseType =3D EFUSE_WIFI;
+
+	if (!hal_EfusePgCheckAvailableAddr(padapter, efuseType))
+		return false;
+
+	hal_EfuseConstructPGPkt(offset, word_en, pData, &targetPkt);
+
+	if (!hal_EfusePartialWriteCheck(padapter, efuseType,
+					&startAddr, &targetPkt))
+		return false;
+
+	if (!hal_EfusePgPacketWriteHeader(padapter, efuseType,
+					  &startAddr, &targetPkt))
+		return false;
+
+	if (!hal_EfusePgPacketWriteData(padapter, efuseType,
+					&startAddr, &targetPkt))
+		return false;
+
+	return true;
+}
+
+static bool
+Hal_EfusePgPacketWrite_BT(struct rtw_adapter *pAdapter,
+			  u8 offset, u8 word_en, u8 *pData)
+{
+	struct pg_pkt_struct targetPkt;
+	u16 startAddr =3D 0;
+	u8 efuseType =3D EFUSE_BT;
+
+	if (!hal_EfusePgCheckAvailableAddr(pAdapter, efuseType))
+		return false;
+
+	hal_EfuseConstructPGPkt(offset, word_en, pData, &targetPkt);
+
+	if (!hal_EfusePartialWriteCheck(pAdapter, efuseType,
+					&startAddr, &targetPkt))
+		return false;
+
+	if (!hal_EfusePgPacketWriteHeader(pAdapter, efuseType,
+					  &startAddr, &targetPkt))
+		return false;
+
+	if (!hal_EfusePgPacketWriteData(pAdapter, efuseType,
+					&startAddr, &targetPkt))
+		return false;
+
+	return true;
+}
+
+static struct hal_version ReadChipVersion8723A(struct rtw_adapter *pad=
apter)
+{
+	u32 value32;
+	struct hal_version ChipVersion;
+	struct hal_data_8723a *pHalData;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+
+	value32 =3D rtw_read32(padapter, REG_SYS_CFG);
+	ChipVersion.ICType =3D CHIP_8723A;
+	ChipVersion.ChipType =3D ((value32 & RTL_ID) ? TEST_CHIP : NORMAL_CHI=
P);
+	ChipVersion.RFType =3D RF_TYPE_1T1R;
+	ChipVersion.VendorType =3D
+		((value32 & VENDOR_ID) ? CHIP_VENDOR_UMC : CHIP_VENDOR_TSMC);
+	ChipVersion.CUTVersion =3D (value32 & CHIP_VER_RTL_MASK) >> CHIP_VER_=
RTL_SHIFT;	/*  IC version (CUT) */
+
+	/*  For regulator mode. by tynli. 2011.01.14 */
+	pHalData->RegulatorMode =3D ((value32 & SPS_SEL) ?
+				   RT_LDO_REGULATOR : RT_SWITCHING_REGULATOR);
+
+	value32 =3D rtw_read32(padapter, REG_GPIO_OUTSTS);
+	/*  ROM code version. */
+	ChipVersion.ROMVer =3D ((value32 & RF_RL_ID) >> 20);
+
+	/*  For multi-function consideration. Added by Roger, 2010.10.06. */
+	pHalData->MultiFunc =3D RT_MULTI_FUNC_NONE;
+	value32 =3D rtw_read32(padapter, REG_MULTI_FUNC_CTRL);
+	pHalData->MultiFunc |=3D
+		((value32 & WL_FUNC_EN) ? RT_MULTI_FUNC_WIFI : 0);
+	pHalData->MultiFunc |=3D ((value32 & BT_FUNC_EN) ? RT_MULTI_FUNC_BT :=
 0);
+	pHalData->MultiFunc |=3D
+		((value32 & GPS_FUNC_EN) ? RT_MULTI_FUNC_GPS : 0);
+	pHalData->PolarityCtl =3D
+		((value32 & WL_HWPDN_SL) ? RT_POLARITY_HIGH_ACT :
+		 RT_POLARITY_LOW_ACT);
+	dump_chip_info23a(ChipVersion);
+	pHalData->VersionID =3D ChipVersion;
+
+	if (IS_1T2R(ChipVersion))
+		pHalData->rf_type =3D RF_1T2R;
+	else if (IS_2T2R(ChipVersion))
+		pHalData->rf_type =3D RF_2T2R;
+	else
+		pHalData->rf_type =3D RF_1T1R;
+
+	MSG_8723A("RF_Type is %x!!\n", pHalData->rf_type);
+
+	return ChipVersion;
+}
+
+static void rtl8723a_read_chip_version(struct rtw_adapter *padapter)
+{
+	ReadChipVersion8723A(padapter);
+}
+
+/*  */
+/*  */
+/*  20100209 Joseph: */
+/*  This function is used only for 92C to set REG_BCN_CTRL(0x550) regi=
ster. */
+/*  We just reserve the value of the register in variable
+    pHalData->RegBcnCtrlVal and then operate */
+/*  the value of the register via atomic operation. */
+/*  This prevents from race condition when setting this register. */
+/*  The value of pHalData->RegBcnCtrlVal is initialized in
+    HwConfigureRTL8192CE() function. */
+/*  */
+void SetBcnCtrlReg23a(struct rtw_adapter *padapter, u8 SetBits, u8 Cle=
arBits)
+{
+	struct hal_data_8723a *pHalData;
+	u32 addr;
+	u8 *pRegBcnCtrlVal;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pRegBcnCtrlVal =3D (u8 *)&pHalData->RegBcnCtrlVal;
+
+	addr =3D REG_BCN_CTRL;
+
+	*pRegBcnCtrlVal =3D rtw_read8(padapter, addr);
+	*pRegBcnCtrlVal |=3D SetBits;
+	*pRegBcnCtrlVal &=3D ~ClearBits;
+
+	rtw_write8(padapter, addr, *pRegBcnCtrlVal);
+}
+
+void rtl8723a_InitBeaconParameters(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	rtw_write16(padapter, REG_BCN_CTRL, 0x1010);
+	pHalData->RegBcnCtrlVal =3D 0x1010;
+
+	/*  TODO: Remove these magic number */
+	rtw_write16(padapter, REG_TBTT_PROHIBIT, 0x6404);	/*  ms */
+	/*  Firmware will control REG_DRVERLYINT when power saving is enable,=
 */
+	/*  so don't set this register on STA mode. */
+	if (check_fwstate(&padapter->mlmepriv, WIFI_STATION_STATE) =3D=3D fal=
se)
+		rtw_write8(padapter, REG_DRVERLYINT, DRIVER_EARLY_INT_TIME);
+	/*  2ms */
+	rtw_write8(padapter, REG_BCNDMATIM, BCN_DMA_ATIME_INT_TIME);
+
+	/*  Suggested by designer timchen. Change beacon AIFS to the
+	    largest number beacause test chip does not contension before
+	    sending beacon. by tynli. 2009.11.03 */
+	rtw_write16(padapter, REG_BCNTCFG, 0x660F);
+}
+
+static void ResumeTxBeacon(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	/*  2010.03.01. Marked by tynli. No need to call workitem beacause
+	    we record the value */
+	/*  which should be read from register to a global variable. */
+
+	RT_TRACE(_module_hci_hal_init_c_, _drv_info_, ("+ResumeTxBeacon\n"));
+
+	pHalData->RegFwHwTxQCtrl |=3D BIT(6);
+	rtw_write8(padapter, REG_FWHW_TXQ_CTRL + 2, pHalData->RegFwHwTxQCtrl)=
;
+	rtw_write8(padapter, REG_TBTT_PROHIBIT + 1, 0xff);
+	pHalData->RegReg542 |=3D BIT(0);
+	rtw_write8(padapter, REG_TBTT_PROHIBIT + 2, pHalData->RegReg542);
+}
+
+static void StopTxBeacon(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	/*  2010.03.01. Marked by tynli. No need to call workitem beacause
+	    we record the value */
+	/*  which should be read from register to a global variable. */
+
+	RT_TRACE(_module_hci_hal_init_c_, _drv_info_, ("+StopTxBeacon\n"));
+
+	pHalData->RegFwHwTxQCtrl &=3D ~BIT(6);
+	rtw_write8(padapter, REG_FWHW_TXQ_CTRL + 2, pHalData->RegFwHwTxQCtrl)=
;
+	rtw_write8(padapter, REG_TBTT_PROHIBIT + 1, 0x64);
+	pHalData->RegReg542 &=3D ~BIT(0);
+	rtw_write8(padapter, REG_TBTT_PROHIBIT + 2, pHalData->RegReg542);
+
+	CheckFwRsvdPageContent23a(padapter); /*  2010.06.23. Added by tynli. =
*/
+}
+
+static void _BeaconFunctionEnable(struct rtw_adapter *padapter, u8 Ena=
ble,
+				  u8 Linked)
+{
+	SetBcnCtrlReg23a(padapter, DIS_TSF_UDT | EN_BCN_FUNCTION | DIS_BCNQ_S=
UB,
+		      0);
+	rtw_write8(padapter, REG_RD_CTRL + 1, 0x6F);
+}
+
+static void rtl8723a_SetBeaconRelatedRegisters(struct rtw_adapter *pad=
apter)
+{
+	u32 value32;
+	struct mlme_ext_priv *pmlmeext =3D &padapter->mlmeextpriv;
+	struct mlme_ext_info *pmlmeinfo =3D &pmlmeext->mlmext_info;
+
+	/* reset TSF, enable update TSF, correcting TSF On Beacon */
+
+	/* REG_BCN_INTERVAL */
+	/* REG_BCNDMATIM */
+	/* REG_ATIMWND */
+	/* REG_TBTT_PROHIBIT */
+	/* REG_DRVERLYINT */
+	/* REG_BCN_MAX_ERR */
+	/* REG_BCNTCFG (0x510) */
+	/* REG_DUAL_TSF_RST */
+	/* REG_BCN_CTRL (0x550) */
+
+	/*  */
+	/*  ATIM window */
+	/*  */
+	rtw_write16(padapter, REG_ATIMWND, 2);
+
+	/*  */
+	/*  Beacon interval (in unit of TU). */
+	/*  */
+	rtw_write16(padapter, REG_BCN_INTERVAL, pmlmeinfo->bcn_interval);
+
+	rtl8723a_InitBeaconParameters(padapter);
+
+	rtw_write8(padapter, REG_SLOT, 0x09);
+
+	/*  */
+	/*  Reset TSF Timer to zero, added by Roger. 2008.06.24 */
+	/*  */
+	value32 =3D rtw_read32(padapter, REG_TCR);
+	value32 &=3D ~TSFRST;
+	rtw_write32(padapter, REG_TCR, value32);
+
+	value32 |=3D TSFRST;
+	rtw_write32(padapter, REG_TCR, value32);
+
+	/*  NOTE: Fix test chip's bug (about contention windows's randomness)=
 */
+	if (check_fwstate(&padapter->mlmepriv, WIFI_ADHOC_STATE |
+			  WIFI_ADHOC_MASTER_STATE | WIFI_AP_STATE) =3D=3D true) {
+		rtw_write8(padapter, REG_RXTSF_OFFSET_CCK, 0x50);
+		rtw_write8(padapter, REG_RXTSF_OFFSET_OFDM, 0x50);
+	}
+
+	_BeaconFunctionEnable(padapter, true, true);
+
+	ResumeTxBeacon(padapter);
+	SetBcnCtrlReg23a(padapter, DIS_BCNQ_SUB, 0);
+}
+
+static void rtl8723a_GetHalODMVar(struct rtw_adapter *Adapter,
+				  enum hal_odm_variable eVariable,
+				  void *pValue1, bool bSet)
+{
+	switch (eVariable) {
+	case HAL_ODM_STA_INFO:
+		break;
+	default:
+		break;
+	}
+}
+
+static void rtl8723a_SetHalODMVar(struct rtw_adapter *Adapter,
+				  enum hal_odm_variable eVariable,
+				  void *pValue1, bool bSet)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct dm_odm_t *podmpriv =3D &pHalData->odmpriv;
+	switch (eVariable) {
+	case HAL_ODM_STA_INFO:
+	{
+		struct sta_info *psta =3D (struct sta_info *)pValue1;
+
+		if (bSet) {
+			DBG_8723A("Set STA_(%d) info\n", psta->mac_id);
+			ODM_CmnInfoPtrArrayHook23a(podmpriv,
+						ODM_CMNINFO_STA_STATUS,
+						psta->mac_id, psta);
+		} else {
+			DBG_8723A("Clean STA_(%d) info\n", psta->mac_id);
+				ODM_CmnInfoPtrArrayHook23a(podmpriv,
+							ODM_CMNINFO_STA_STATUS,
+							psta->mac_id, NULL);
+		}
+	}
+		break;
+	case HAL_ODM_P2P_STATE:
+		ODM_CmnInfoUpdate23a(podmpriv, ODM_CMNINFO_WIFI_DIRECT, bSet);
+		break;
+	case HAL_ODM_WIFI_DISPLAY_STATE:
+		ODM_CmnInfoUpdate23a(podmpriv, ODM_CMNINFO_WIFI_DISPLAY, bSet);
+		break;
+	default:
+		break;
+	}
+}
+
+static void hal_notch_filter_8723a(struct rtw_adapter *adapter, bool e=
nable)
+{
+	if (enable) {
+		DBG_8723A("Enable notch filter\n");
+		rtw_write8(adapter, rOFDM0_RxDSP + 1,
+			   rtw_read8(adapter, rOFDM0_RxDSP + 1) | BIT1);
+	} else {
+		DBG_8723A("Disable notch filter\n");
+		rtw_write8(adapter, rOFDM0_RxDSP + 1,
+			   rtw_read8(adapter, rOFDM0_RxDSP + 1) & ~BIT1);
+	}
+}
+
+s32 c2h_id_filter_ccx_8723a(u8 id)
+{
+	s32 ret =3D false;
+	if (id =3D=3D C2H_CCX_TX_RPT)
+		ret =3D true;
+
+	return ret;
+}
+
+static s32 c2h_handler_8723a(struct rtw_adapter *padapter,
+			     struct c2h_evt_hdr *c2h_evt)
+{
+	s32 ret =3D _SUCCESS;
+	u8 i =3D 0;
+
+	if (c2h_evt =3D=3D NULL) {
+		DBG_8723A("%s c2h_evt is NULL\n", __func__);
+		ret =3D _FAIL;
+		goto exit;
+	}
+
+	switch (c2h_evt->id) {
+	case C2H_DBG:
+		RT_TRACE(_module_hal_init_c_, _drv_info_,
+			 ("C2HCommandHandler: %s\n", c2h_evt->payload));
+		break;
+
+	case C2H_CCX_TX_RPT:
+		handle_txrpt_ccx_8723a(padapter, c2h_evt->payload);
+		break;
+	case C2H_EXT_RA_RPT:
+		break;
+	case C2H_HW_INFO_EXCH:
+		RT_TRACE(_module_hal_init_c_, _drv_info_,
+			 ("[BT], C2H_HW_INFO_EXCH\n"));
+		for (i =3D 0; i < c2h_evt->plen; i++) {
+			RT_TRACE(_module_hal_init_c_, _drv_info_,
+				 ("[BT], tmpBuf[%d]=3D 0x%x\n", i,
+				  c2h_evt->payload[i]));
+		}
+		break;
+
+	case C2H_C2H_H2C_TEST:
+		RT_TRACE(_module_hal_init_c_, _drv_info_,
+			 ("[BT], C2H_H2C_TEST\n"));
+		RT_TRACE(_module_hal_init_c_, _drv_info_,
+			 ("[BT], tmpBuf[0]/[1]/[2]/[3]/[4]=3D 0x%x/ 0x%x/ "
+			  "0x%x/ 0x%x/ 0x%x\n", c2h_evt->payload[0],
+			  c2h_evt->payload[1], c2h_evt->payload[2],
+			  c2h_evt->payload[3], c2h_evt->payload[4]));
+		break;
+
+#ifdef CONFIG_8723AU_BT_COEXIST
+	case C2H_BT_INFO:
+		DBG_8723A("%s ,  Got  C2H_BT_INFO \n", __func__);
+		BT_FwC2hBtInfo(padapter, c2h_evt->payload, c2h_evt->plen);
+		break;
+#endif
+
+	default:
+		ret =3D _FAIL;
+		break;
+	}
+
+exit:
+	return ret;
+}
+
+void rtl8723a_set_hal_ops(struct hal_ops *pHalFunc)
+{
+	pHalFunc->free_hal_data =3D &rtl8723a_free_hal_data;
+
+	pHalFunc->dm_init =3D &rtl8723a_init_dm_priv;
+	pHalFunc->dm_deinit =3D &rtl8723a_deinit_dm_priv;
+
+	pHalFunc->read_chip_version =3D &rtl8723a_read_chip_version;
+
+	pHalFunc->set_bwmode_handler =3D &PHY_SetBWMode23a8723A;
+	pHalFunc->set_channel_handler =3D &PHY_SwChnl8723A;
+
+	pHalFunc->hal_dm_watchdog =3D &rtl8723a_HalDmWatchDog;
+
+	pHalFunc->SetBeaconRelatedRegistersHandler =3D
+		&rtl8723a_SetBeaconRelatedRegisters;
+
+	pHalFunc->Add_RateATid =3D &rtl8723a_add_rateatid;
+	pHalFunc->run_thread =3D &rtl8723a_start_thread;
+	pHalFunc->cancel_thread =3D &rtl8723a_stop_thread;
+
+	pHalFunc->read_bbreg =3D &PHY_QueryBBReg;
+	pHalFunc->write_bbreg =3D &PHY_SetBBReg;
+	pHalFunc->read_rfreg =3D &PHY_QueryRFReg;
+	pHalFunc->write_rfreg =3D &PHY_SetRFReg;
+
+	/*  Efuse related function */
+	pHalFunc->EfusePowerSwitch =3D &Hal_EfusePowerSwitch;
+	pHalFunc->ReadEFuse =3D &Hal_ReadEFuse;
+	pHalFunc->EFUSEGetEfuseDefinition =3D &Hal_GetEfuseDefinition;
+	pHalFunc->EfuseGetCurrentSize =3D &Hal_EfuseGetCurrentSize;
+	pHalFunc->Efuse_PgPacketRead23a =3D &Hal_EfusePgPacketRead;
+	pHalFunc->Efuse_PgPacketWrite23a =3D &Hal_EfusePgPacketWrite;
+	pHalFunc->Efuse_WordEnableDataWrite23a =3D &Hal_EfuseWordEnableDataWr=
ite;
+	pHalFunc->Efuse_PgPacketWrite23a_BT =3D &Hal_EfusePgPacketWrite_BT;
+
+	pHalFunc->sreset_init_value23a =3D &sreset_init_value23a;
+	pHalFunc->sreset_reset_value23a =3D &sreset_reset_value23a;
+	pHalFunc->silentreset =3D &sreset_reset;
+	pHalFunc->sreset_xmit_status_check =3D &rtl8723a_sreset_xmit_status_c=
heck;
+	pHalFunc->sreset_linked_status_check =3D
+		&rtl8723a_sreset_linked_status_check;
+	pHalFunc->sreset_get_wifi_status23a =3D &sreset_get_wifi_status23a;
+	pHalFunc->sreset_inprogress =3D &sreset_inprogress;
+	pHalFunc->GetHalODMVarHandler =3D &rtl8723a_GetHalODMVar;
+	pHalFunc->SetHalODMVarHandler =3D &rtl8723a_SetHalODMVar;
+
+	pHalFunc->hal_notch_filter =3D &hal_notch_filter_8723a;
+
+	pHalFunc->c2h_handler =3D c2h_handler_8723a;
+	pHalFunc->c2h_id_filter_ccx =3D c2h_id_filter_ccx_8723a;
+}
+
+void rtl8723a_InitAntenna_Selection(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	u8 val;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+
+	val =3D rtw_read8(padapter, REG_LEDCFG2);
+	/*  Let 8051 take control antenna settting */
+	val |=3D BIT(7);		/*  DPDT_SEL_EN, 0x4C[23] */
+	rtw_write8(padapter, REG_LEDCFG2, val);
+}
+
+void rtl8723a_CheckAntenna_Selection(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	u8 val;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+
+	val =3D rtw_read8(padapter, REG_LEDCFG2);
+	/*  Let 8051 take control antenna settting */
+	if (!(val & BIT(7))) {
+		val |=3D BIT(7);	/*  DPDT_SEL_EN, 0x4C[23] */
+		rtw_write8(padapter, REG_LEDCFG2, val);
+	}
+}
+
+void rtl8723a_DeinitAntenna_Selection(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	u8 val;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	val =3D rtw_read8(padapter, REG_LEDCFG2);
+	/*  Let 8051 take control antenna settting */
+	val &=3D ~BIT(7);		/*  DPDT_SEL_EN, clear 0x4C[23] */
+	rtw_write8(padapter, REG_LEDCFG2, val);
+}
+
+void rtl8723a_init_default_value(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	struct dm_priv *pdmpriv;
+	u8 i;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pdmpriv =3D &pHalData->dmpriv;
+
+	/*  init default value */
+	pHalData->fw_ractrl =3D false;
+	pHalData->bIQKInitialized =3D false;
+	if (!padapter->pwrctrlpriv.bkeepfwalive)
+		pHalData->LastHMEBoxNum =3D 0;
+
+	pHalData->bIQKInitialized =3D false;
+
+	/*  init dm default value */
+	pdmpriv->TM_Trigger =3D 0;	/* for IQK */
+/*	pdmpriv->binitialized =3D false; */
+/*	pdmpriv->prv_traffic_idx =3D 3; */
+/*	pdmpriv->initialize =3D 0; */
+
+	pdmpriv->ThermalValue_HP_index =3D 0;
+	for (i =3D 0; i < HP_THERMAL_NUM; i++)
+		pdmpriv->ThermalValue_HP[i] =3D 0;
+
+	/*  init Efuse variables */
+	pHalData->EfuseUsedBytes =3D 0;
+	pHalData->BTEfuseUsedBytes =3D 0;
+}
+
+u8 GetEEPROMSize8723A(struct rtw_adapter *padapter)
+{
+	u8 size =3D 0;
+	u32 cr;
+
+	cr =3D rtw_read16(padapter, REG_9346CR);
+	/*  6: EEPROM used is 93C46, 4: boot from E-Fuse. */
+	size =3D (cr & BOOT_FROM_EEPROM) ? 6 : 4;
+
+	MSG_8723A("EEPROM type is %s\n", size =3D=3D 4 ? "E-FUSE" : "93C46");
+
+	return size;
+}
+
+/*  */
+/*  */
+/*  LLT R/W/Init function */
+/*  */
+/*  */
+static s32 _LLTWrite(struct rtw_adapter *padapter, u32 address, u32 da=
ta)
+{
+	s32 status =3D _SUCCESS;
+	s32 count =3D 0;
+	u32 value =3D _LLT_INIT_ADDR(address) | _LLT_INIT_DATA(data) |
+		    _LLT_OP(_LLT_WRITE_ACCESS);
+	u16 LLTReg =3D REG_LLT_INIT;
+
+	rtw_write32(padapter, LLTReg, value);
+
+	/* polling */
+	do {
+		value =3D rtw_read32(padapter, LLTReg);
+		if (_LLT_NO_ACTIVE =3D=3D _LLT_OP_VALUE(value)) {
+			break;
+		}
+
+		if (count > POLLING_LLT_THRESHOLD) {
+			RT_TRACE(_module_hal_init_c_, _drv_err_,
+				 ("Failed to polling write LLT done at "
+				  "address %d!\n", address));
+			status =3D _FAIL;
+			break;
+		}
+	} while (count++);
+
+	return status;
+}
+
+s32 InitLLTTable23a(struct rtw_adapter *padapter, u32 boundary)
+{
+	s32 status =3D _SUCCESS;
+	u32 i;
+	u32 txpktbuf_bndy =3D boundary;
+	u32 Last_Entry_Of_TxPktBuf =3D LAST_ENTRY_OF_TX_PKT_BUFFER;
+
+	for (i =3D 0; i < (txpktbuf_bndy - 1); i++) {
+		status =3D _LLTWrite(padapter, i, i + 1);
+		if (_SUCCESS !=3D status) {
+			return status;
+		}
+	}
+
+	/*  end of list */
+	status =3D _LLTWrite(padapter, (txpktbuf_bndy - 1), 0xFF);
+	if (_SUCCESS !=3D status) {
+		return status;
+	}
+
+	/*  Make the other pages as ring buffer */
+	/*  This ring buffer is used as beacon buffer if we config this
+	    MAC as two MAC transfer. */
+	/*  Otherwise used as local loopback buffer. */
+	for (i =3D txpktbuf_bndy; i < Last_Entry_Of_TxPktBuf; i++) {
+		status =3D _LLTWrite(padapter, i, (i + 1));
+		if (_SUCCESS !=3D status) {
+			return status;
+		}
+	}
+
+	/*  Let last entry point to the start entry of ring buffer */
+	status =3D _LLTWrite(padapter, Last_Entry_Of_TxPktBuf, txpktbuf_bndy)=
;
+	if (_SUCCESS !=3D status) {
+		return status;
+	}
+
+	return status;
+}
+
+static void _DisableGPIO(struct rtw_adapter *padapter)
+{
+/***************************************
+j. GPIO_PIN_CTRL 0x44[31:0]=3D 0x000
+k.Value =3D GPIO_PIN_CTRL[7:0]
+l. GPIO_PIN_CTRL 0x44[31:0] =3D 0x00FF0000 | (value <<8); write extern=
al PIN level
+m. GPIO_MUXCFG 0x42 [15:0] =3D 0x0780
+n. LEDCFG 0x4C[15:0] =3D 0x8080
+***************************************/
+	u32 value32;
+	u32 u4bTmp;
+
+	/* 1. Disable GPIO[7:0] */
+	rtw_write16(padapter, REG_GPIO_PIN_CTRL + 2, 0x0000);
+	value32 =3D rtw_read32(padapter, REG_GPIO_PIN_CTRL) & 0xFFFF00FF;
+	u4bTmp =3D value32 & 0x000000FF;
+	value32 |=3D ((u4bTmp << 8) | 0x00FF0000);
+	rtw_write32(padapter, REG_GPIO_PIN_CTRL, value32);
+
+	/*  */
+	/*  <Roger_Notes> For RTL8723u multi-function configuration which
+	    was autoload from Efuse offset 0x0a and 0x0b, */
+	/*  WLAN HW GPIO[9], GPS HW GPIO[10] and BT HW GPIO[11]. */
+	/*  Added by Roger, 2010.10.07. */
+	/*  */
+	/* 2. Disable GPIO[8] and GPIO[12] */
+
+	/*  Configure all pins as input mode. */
+	rtw_write16(padapter, REG_GPIO_IO_SEL_2, 0x0000);
+	value32 =3D rtw_read32(padapter, REG_GPIO_PIN_CTRL_2) & 0xFFFF001F;
+	u4bTmp =3D value32 & 0x0000001F;
+	/*  Set pin 8, 10, 11 and pin 12 to output mode. */
+	value32 |=3D ((u4bTmp << 8) | 0x001D0000);
+	rtw_write32(padapter, REG_GPIO_PIN_CTRL_2, value32);
+
+	/* 3. Disable LED0 & 1 */
+	rtw_write16(padapter, REG_LEDCFG0, 0x8080);
+}				/* end of _DisableGPIO() */
+
+static void _DisableRFAFEAndResetBB8192C(struct rtw_adapter *padapter)
+{
+/**************************************
+a.	TXPAUSE 0x522[7:0] =3D 0xFF		Pause MAC TX queue
+b.	RF path 0 offset 0x00 =3D 0x00		disable RF
+c.	APSD_CTRL 0x600[7:0] =3D 0x40
+d.	SYS_FUNC_EN 0x02[7:0] =3D 0x16		reset BB state machine
+e.	SYS_FUNC_EN 0x02[7:0] =3D 0x14		reset BB state machine
+***************************************/
+	u8 eRFPath =3D 0, value8 =3D 0;
+
+	rtw_write8(padapter, REG_TXPAUSE, 0xFF);
+
+	PHY_SetRFReg(padapter, (enum RF_RADIO_PATH) eRFPath, 0x0, bMaskByte0,=
 0x0);
+
+	value8 |=3D APSDOFF;
+	rtw_write8(padapter, REG_APSD_CTRL, value8);	/* 0x40 */
+
+	/*  Set BB reset at first */
+	value8 =3D 0;
+	value8 |=3D (FEN_USBD | FEN_USBA | FEN_BB_GLB_RSTn);
+	rtw_write8(padapter, REG_SYS_FUNC_EN, value8);	/* 0x16 */
+
+	/*  Set global reset. */
+	value8 &=3D ~FEN_BB_GLB_RSTn;
+	rtw_write8(padapter, REG_SYS_FUNC_EN, value8);	/* 0x14 */
+
+	/*  2010/08/12 MH We need to set BB/GLBAL reset to save power
+	    for SS mode. */
+
+/*	RT_TRACE(COMP_INIT, DBG_LOUD, ("=3D=3D=3D=3D=3D=3D> RF off and rese=
t BB.\n")); */
+}
+
+static void _DisableRFAFEAndResetBB(struct rtw_adapter *padapter)
+{
+	_DisableRFAFEAndResetBB8192C(padapter);
+}
+
+static void _ResetDigitalProcedure1_92C(struct rtw_adapter *padapter,
+					bool bWithoutHWSM)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (IS_FW_81xxC(padapter) && (pHalData->FirmwareVersion <=3D 0x20)) {
+	/*****************************
+	f.	MCUFWDL 0x80[7:0]=3D 0		reset MCU ready status
+	g.	SYS_FUNC_EN 0x02[10]=3D 0		reset MCU register, (8051 reset)
+	h.	SYS_FUNC_EN 0x02[15-12]=3D 5	reset MAC register, DCORE
+	i.     SYS_FUNC_EN 0x02[10]=3D 1		enable MCU register,
+						(8051 enable)
+	******************************/
+		u16 valu16 =3D 0;
+		rtw_write8(padapter, REG_MCUFWDL, 0);
+
+		valu16 =3D rtw_read16(padapter, REG_SYS_FUNC_EN);
+		/* reset MCU , 8051 */
+		rtw_write16(padapter, REG_SYS_FUNC_EN, (valu16 & (~FEN_CPUEN)));
+
+		valu16 =3D rtw_read16(padapter, REG_SYS_FUNC_EN) & 0x0FFF;
+		rtw_write16(padapter, REG_SYS_FUNC_EN,
+			    (valu16 | (FEN_HWPDN | FEN_ELDR)));	/* reset MAC */
+
+		valu16 =3D rtw_read16(padapter, REG_SYS_FUNC_EN);
+		/* enable MCU , 8051 */
+		rtw_write16(padapter, REG_SYS_FUNC_EN, (valu16 | FEN_CPUEN));
+	} else {
+		u8 retry_cnts =3D 0;
+
+		/*  2010/08/12 MH For USB SS, we can not stop 8051 when we
+		    are trying to enter IPS/HW&SW radio off. For
+		    S3/S4/S5/Disable, we can stop 8051 because */
+		/*  we will init FW when power on again. */
+		/* if (!pDevice->RegUsbSS) */
+		/*  If we want to SS mode, we can not reset 8051. */
+		if (rtw_read8(padapter, REG_MCUFWDL) & BIT1) {
+			/* IF fw in RAM code, do reset */
+			if (padapter->bFWReady) {
+				/*  2010/08/25 MH Accordign to RD alfred's
+				    suggestion, we need to disable other */
+				/*  HRCV INT to influence 8051 reset. */
+				rtw_write8(padapter, REG_FWIMR, 0x20);
+				/*  2011/02/15 MH According to Alex's
+				    suggestion, close mask to prevent
+				    incorrect FW write operation. */
+				rtw_write8(padapter, REG_FTIMR, 0x00);
+				rtw_write8(padapter, REG_FSIMR, 0x00);
+
+				/* 8051 reset by self */
+				rtw_write8(padapter, REG_HMETFR + 3, 0x20);
+
+				while ((retry_cnts++ < 100) &&
+				       (FEN_CPUEN &
+					rtw_read16(padapter, REG_SYS_FUNC_EN))) {
+					udelay(50);	/* us */
+				}
+
+				if (retry_cnts >=3D 100) {
+					/* Reset MAC and Enable 8051 */
+					rtw_write8(padapter,
+						   REG_SYS_FUNC_EN + 1, 0x50);
+					mdelay(10);
+				}
+			}
+		}
+		/* Reset MAC and Enable 8051 */
+		rtw_write8(padapter, REG_SYS_FUNC_EN + 1, 0x54);
+		rtw_write8(padapter, REG_MCUFWDL, 0);
+	}
+
+	if (bWithoutHWSM) {
+	/*****************************
+		Without HW auto state machine
+	g.	SYS_CLKR 0x08[15:0] =3D 0x30A3		disable MAC clock
+	h.	AFE_PLL_CTRL 0x28[7:0] =3D 0x80		disable AFE PLL
+	i.	AFE_XTAL_CTRL 0x24[15:0] =3D 0x880F	gated AFE DIG_CLOCK
+	j.	SYS_ISO_CTRL 0x00[7:0] =3D 0xF9		isolated digital to PON
+	******************************/
+		/* modify to 0x70A3 by Scott. */
+		rtw_write16(padapter, REG_SYS_CLKR, 0x70A3);
+		rtw_write8(padapter, REG_AFE_PLL_CTRL, 0x80);
+		rtw_write16(padapter, REG_AFE_XTAL_CTRL, 0x880F);
+		rtw_write8(padapter, REG_SYS_ISO_CTRL, 0xF9);
+	} else {
+		/*  Disable all RF/BB power */
+		rtw_write8(padapter, REG_RF_CTRL, 0x00);
+	}
+}
+
+static void _ResetDigitalProcedure1(struct rtw_adapter *padapter,
+				    bool bWithoutHWSM)
+{
+	_ResetDigitalProcedure1_92C(padapter, bWithoutHWSM);
+}
+
+static void _ResetDigitalProcedure2(struct rtw_adapter *padapter)
+{
+/*****************************
+k.	SYS_FUNC_EN 0x03[7:0] =3D 0x44		disable ELDR runction
+l.	SYS_CLKR 0x08[15:0] =3D 0x3083		disable ELDR clock
+m.	SYS_ISO_CTRL 0x01[7:0] =3D 0x83		isolated ELDR to PON
+******************************/
+	/* modify to 0x70a3 by Scott. */
+	rtw_write16(padapter, REG_SYS_CLKR, 0x70a3);
+	/* modify to 0x82 by Scott. */
+	rtw_write8(padapter, REG_SYS_ISO_CTRL + 1, 0x82);
+}
+
+static void _DisableAnalog(struct rtw_adapter *padapter, bool bWithout=
HWSM)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u16 value16 =3D 0;
+	u8 value8 =3D 0;
+
+	if (bWithoutHWSM) {
+	/*****************************
+	n.	LDOA15_CTRL 0x20[7:0] =3D 0x04	disable A15 power
+	o.	LDOV12D_CTRL 0x21[7:0] =3D 0x54	disable digital core power
+	r.	When driver call disable, the ASIC will turn off remaining
+		clock automatically
+	******************************/
+
+		rtw_write8(padapter, REG_LDOA15_CTRL, 0x04);
+		/* rtw_write8(padapter, REG_LDOV12D_CTRL, 0x54); */
+
+		value8 =3D rtw_read8(padapter, REG_LDOV12D_CTRL);
+		value8 &=3D (~LDV12_EN);
+		rtw_write8(padapter, REG_LDOV12D_CTRL, value8);
+/*		RT_TRACE(COMP_INIT, DBG_LOUD,
+		(" REG_LDOV12D_CTRL Reg0x21:0x%02x.\n", value8)); */
+	}
+
+	/*****************************
+	h.	SPS0_CTRL 0x11[7:0] =3D 0x23		enter PFM mode
+	i.	APS_FSMCO 0x04[15:0] =3D 0x4802		set USB suspend
+	******************************/
+	value8 =3D 0x23;
+	if (IS_81xxC_VENDOR_UMC_B_CUT(pHalData->VersionID))
+		value8 |=3D BIT3;
+
+	rtw_write8(padapter, REG_SPS0_CTRL, value8);
+
+	if (bWithoutHWSM) {
+		/* value16 |=3D (APDM_HOST | FSM_HSUS |/PFM_ALDN); */
+		/*  2010/08/31 According to Filen description, we need to
+		    use HW to shut down 8051 automatically. */
+		/*  Becasue suspend operatione need the asistance of 8051
+		    to wait for 3ms. */
+		value16 |=3D (APDM_HOST | AFSM_HSUS | PFM_ALDN);
+	} else {
+		value16 |=3D (APDM_HOST | AFSM_HSUS | PFM_ALDN);
+	}
+
+	rtw_write16(padapter, REG_APS_FSMCO, value16);	/* 0x4802 */
+
+	rtw_write8(padapter, REG_RSV_CTRL, 0x0e);
+}
+
+/*  HW Auto state machine */
+s32 CardDisableHWSM(struct rtw_adapter *padapter, u8 resetMCU)
+{
+	int rtStatus =3D _SUCCESS;
+
+	if (padapter->bSurpriseRemoved) {
+		return rtStatus;
+	}
+	/*  RF Off Sequence =3D=3D=3D=3D */
+	_DisableRFAFEAndResetBB(padapter);
+
+	/*   =3D=3D=3D=3D Reset digital sequence   =3D=3D=3D=3D=3D=3D */
+	_ResetDigitalProcedure1(padapter, false);
+
+	/*   =3D=3D=3D=3D Pull GPIO PIN to balance level and LED control =3D=3D=
=3D=3D=3D=3D */
+	_DisableGPIO(padapter);
+
+	/*   =3D=3D=3D=3D Disable analog sequence =3D=3D=3D */
+	_DisableAnalog(padapter, false);
+
+	RT_TRACE(_module_hci_hal_init_c_, _drv_info_,
+		 ("=3D=3D=3D=3D=3D=3D> Card disable finished.\n"));
+
+	return rtStatus;
+}
+
+/*  without HW Auto state machine */
+s32 CardDisableWithoutHWSM(struct rtw_adapter *padapter)
+{
+	s32 rtStatus =3D _SUCCESS;
+
+	/* RT_TRACE(COMP_INIT, DBG_LOUD,
+	   ("=3D=3D=3D=3D=3D=3D> Card Disable Without HWSM .\n")); */
+	if (padapter->bSurpriseRemoved) {
+		return rtStatus;
+	}
+
+	/*  RF Off Sequence =3D=3D=3D=3D */
+	_DisableRFAFEAndResetBB(padapter);
+
+	/*   =3D=3D=3D=3D Reset digital sequence   =3D=3D=3D=3D=3D=3D */
+	_ResetDigitalProcedure1(padapter, true);
+
+	/*   =3D=3D=3D=3D Pull GPIO PIN to balance level and LED control =3D=3D=
=3D=3D=3D=3D */
+	_DisableGPIO(padapter);
+
+	/*   =3D=3D=3D=3D Reset digital sequence   =3D=3D=3D=3D=3D=3D */
+	_ResetDigitalProcedure2(padapter);
+
+	/*   =3D=3D=3D=3D Disable analog sequence =3D=3D=3D */
+	_DisableAnalog(padapter, true);
+
+	/* RT_TRACE(COMP_INIT, DBG_LOUD,
+	   ("<=3D=3D=3D=3D=3D=3D Card Disable Without HWSM .\n")); */
+	return rtStatus;
+}
+
+void Hal_InitPGData(struct rtw_adapter *padapter, u8 *PROMContent)
+{
+	struct eeprom_priv *pEEPROM =3D GET_EEPROM_EFUSE_PRIV(padapter);
+
+	if (false =3D=3D pEEPROM->bautoload_fail_flag) {	/*  autoload OK. */
+		if (!pEEPROM->EepromOrEfuse) {
+			/*  Read EFUSE real map to shadow. */
+			EFUSE_ShadowMapUpdate23a(padapter, EFUSE_WIFI);
+			memcpy((void *)PROMContent,
+			       (void *)pEEPROM->efuse_eeprom_data,
+			       HWSET_MAX_SIZE);
+		}
+	} else {		/* autoload fail */
+		RT_TRACE(_module_hci_hal_init_c_, _drv_notice_,
+			 ("AutoLoad Fail reported from CR9346!!\n"));
+/*		pHalData->AutoloadFailFlag =3D true; */
+		/* update to default value 0xFF */
+		if (false =3D=3D pEEPROM->EepromOrEfuse)
+			EFUSE_ShadowMapUpdate23a(padapter, EFUSE_WIFI);
+		memcpy((void *)PROMContent, (void *)pEEPROM->efuse_eeprom_data,
+		       HWSET_MAX_SIZE);
+	}
+}
+
+void Hal_EfuseParseIDCode(struct rtw_adapter *padapter, u8 *hwinfo)
+{
+	struct eeprom_priv *pEEPROM =3D GET_EEPROM_EFUSE_PRIV(padapter);
+/*	struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(padapter); */
+	u16 EEPROMId;
+
+	/*  Checl 0x8129 again for making sure autoload status!! */
+	EEPROMId =3D le16_to_cpu(*((u16 *) hwinfo));
+	if (EEPROMId !=3D RTL_EEPROM_ID) {
+		DBG_8723A("EEPROM ID(%#x) is invalid!!\n", EEPROMId);
+		pEEPROM->bautoload_fail_flag =3D true;
+	} else {
+		pEEPROM->bautoload_fail_flag =3D false;
+	}
+
+	RT_TRACE(_module_hal_init_c_, _drv_info_,
+		 ("EEPROM ID =3D 0x%04x\n", EEPROMId));
+}
+
+static void Hal_EEValueCheck(u8 EEType, void *pInValue, void *pOutValu=
e)
+{
+	switch (EEType) {
+	case EETYPE_TX_PWR:
+	{
+		u8 *pIn, *pOut;
+		pIn =3D (u8 *) pInValue;
+		pOut =3D (u8 *) pOutValue;
+		if (*pIn >=3D 0 && *pIn <=3D 63) {
+			*pOut =3D *pIn;
+		} else {
+			RT_TRACE(_module_hci_hal_init_c_, _drv_err_,
+				 ("EETYPE_TX_PWR, value =3D%d is invalid, set "
+				  "to default =3D 0x%x\n",
+				  *pIn, EEPROM_Default_TxPowerLevel));
+			*pOut =3D EEPROM_Default_TxPowerLevel;
+		}
+	}
+		break;
+	default:
+		break;
+	}
+}
+
+static void
+Hal_ReadPowerValueFromPROM_8723A(struct txpowerinfo *pwrInfo,
+				 u8 *PROMContent, bool AutoLoadFail)
+{
+	u32 rfPath, eeAddr, group, rfPathMax =3D 1;
+
+	memset(pwrInfo, 0, sizeof(*pwrInfo));
+
+	if (AutoLoadFail) {
+		for (group =3D 0; group < MAX_CHNL_GROUP; group++) {
+			for (rfPath =3D 0; rfPath < rfPathMax; rfPath++) {
+				pwrInfo->CCKIndex[rfPath][group] =3D
+					EEPROM_Default_TxPowerLevel;
+				pwrInfo->HT40_1SIndex[rfPath][group] =3D
+					EEPROM_Default_TxPowerLevel;
+				pwrInfo->HT40_2SIndexDiff[rfPath][group] =3D
+					EEPROM_Default_HT40_2SDiff;
+				pwrInfo->HT20IndexDiff[rfPath][group] =3D
+					EEPROM_Default_HT20_Diff;
+				pwrInfo->OFDMIndexDiff[rfPath][group] =3D
+					EEPROM_Default_LegacyHTTxPowerDiff;
+				pwrInfo->HT40MaxOffset[rfPath][group] =3D
+					EEPROM_Default_HT40_PwrMaxOffset;
+				pwrInfo->HT20MaxOffset[rfPath][group] =3D
+					EEPROM_Default_HT20_PwrMaxOffset;
+			}
+		}
+		pwrInfo->TSSI_A[0] =3D EEPROM_Default_TSSI;
+		return;
+	}
+
+	for (rfPath =3D 0; rfPath < rfPathMax; rfPath++) {
+		for (group =3D 0; group < MAX_CHNL_GROUP; group++) {
+			eeAddr =3D
+			    EEPROM_CCK_TX_PWR_INX_8723A + (rfPath * 3) + group;
+			/* pwrInfo->CCKIndex[rfPath][group] =3D
+			   PROMContent[eeAddr]; */
+			Hal_EEValueCheck(EETYPE_TX_PWR, &PROMContent[eeAddr],
+					 &pwrInfo->CCKIndex[rfPath][group]);
+			eeAddr =3D EEPROM_HT40_1S_TX_PWR_INX_8723A +
+				(rfPath * 3) + group;
+			/* pwrInfo->HT40_1SIndex[rfPath][group] =3D
+			   PROMContent[eeAddr]; */
+			Hal_EEValueCheck(EETYPE_TX_PWR, &PROMContent[eeAddr],
+					 &pwrInfo->HT40_1SIndex[rfPath][group]);
+		}
+	}
+
+	for (group =3D 0; group < MAX_CHNL_GROUP; group++) {
+		for (rfPath =3D 0; rfPath < rfPathMax; rfPath++) {
+			pwrInfo->HT40_2SIndexDiff[rfPath][group] =3D 0;
+			pwrInfo->HT20IndexDiff[rfPath][group] =3D
+				(PROMContent
+				 [EEPROM_HT20_TX_PWR_INX_DIFF_8723A +
+				  group] >> (rfPath * 4)) & 0xF;
+			/* 4bit sign number to 8 bit sign number */
+			if (pwrInfo->HT20IndexDiff[rfPath][group] & BIT3)
+				pwrInfo->HT20IndexDiff[rfPath][group] |=3D 0xF0;
+
+			pwrInfo->OFDMIndexDiff[rfPath][group] =3D
+				(PROMContent[EEPROM_OFDM_TX_PWR_INX_DIFF_8723A +
+					     group] >> (rfPath * 4)) & 0xF;
+
+			pwrInfo->HT40MaxOffset[rfPath][group] =3D
+				(PROMContent[EEPROM_HT40_MAX_PWR_OFFSET_8723A +
+					     group] >> (rfPath * 4)) & 0xF;
+
+			pwrInfo->HT20MaxOffset[rfPath][group] =3D
+				(PROMContent[EEPROM_HT20_MAX_PWR_OFFSET_8723A +
+					     group] >> (rfPath * 4)) & 0xF;
+		}
+	}
+
+	pwrInfo->TSSI_A[0] =3D PROMContent[EEPROM_TSSI_A_8723A];
+}
+
+static u8 Hal_GetChnlGroup(u8 chnl)
+{
+	u8 group =3D 0;
+
+	if (chnl < 3)		/*  Cjanel 1-3 */
+		group =3D 0;
+	else if (chnl < 9)	/*  Channel 4-9 */
+		group =3D 1;
+	else			/*  Channel 10-14 */
+		group =3D 2;
+
+	return group;
+}
+
+void
+Hal_EfuseParsetxpowerinfo_8723A(struct rtw_adapter *padapter,
+				u8 *PROMContent, bool AutoLoadFail)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct txpowerinfo pwrInfo;
+	u8 rfPath, ch, group, rfPathMax =3D 1;
+	u8 pwr, diff;
+
+	Hal_ReadPowerValueFromPROM_8723A(&pwrInfo, PROMContent, AutoLoadFail)=
;
+	for (rfPath =3D 0; rfPath < rfPathMax; rfPath++) {
+		for (ch =3D 0; ch < CHANNEL_MAX_NUMBER; ch++) {
+			group =3D Hal_GetChnlGroup(ch);
+
+			pHalData->TxPwrLevelCck[rfPath][ch] =3D
+				pwrInfo.CCKIndex[rfPath][group];
+			pHalData->TxPwrLevelHT40_1S[rfPath][ch] =3D
+				pwrInfo.HT40_1SIndex[rfPath][group];
+
+			pHalData->TxPwrHt20Diff[rfPath][ch] =3D
+				pwrInfo.HT20IndexDiff[rfPath][group];
+			pHalData->TxPwrLegacyHtDiff[rfPath][ch] =3D
+				pwrInfo.OFDMIndexDiff[rfPath][group];
+			pHalData->PwrGroupHT20[rfPath][ch] =3D
+				pwrInfo.HT20MaxOffset[rfPath][group];
+			pHalData->PwrGroupHT40[rfPath][ch] =3D
+				pwrInfo.HT40MaxOffset[rfPath][group];
+
+			pwr =3D pwrInfo.HT40_1SIndex[rfPath][group];
+			diff =3D pwrInfo.HT40_2SIndexDiff[rfPath][group];
+
+			pHalData->TxPwrLevelHT40_2S[rfPath][ch] =3D
+			    (pwr > diff) ? (pwr - diff) : 0;
+		}
+	}
+	for (rfPath =3D 0; rfPath < RF_PATH_MAX; rfPath++) {
+		for (ch =3D 0; ch < CHANNEL_MAX_NUMBER; ch++) {
+			RT_TRACE(_module_hci_hal_init_c_, _drv_info_,
+				 ("RF(%u)-Ch(%u) [CCK / HT40_1S / HT40_2S] =3D "
+				  "[0x%x / 0x%x / 0x%x]\n",
+				  rfPath, ch,
+				  pHalData->TxPwrLevelCck[rfPath][ch],
+				  pHalData->TxPwrLevelHT40_1S[rfPath][ch],
+				  pHalData->TxPwrLevelHT40_2S[rfPath][ch]));
+
+		}
+	}
+	for (ch =3D 0; ch < CHANNEL_MAX_NUMBER; ch++) {
+		RT_TRACE(_module_hci_hal_init_c_, _drv_info_,
+			 ("RF-A Ht20 to HT40 Diff[%u] =3D 0x%x(%d)\n", ch,
+			  pHalData->TxPwrHt20Diff[RF_PATH_A][ch],
+			  pHalData->TxPwrHt20Diff[RF_PATH_A][ch]));
+	}
+	for (ch =3D 0; ch < CHANNEL_MAX_NUMBER; ch++)
+		RT_TRACE(_module_hci_hal_init_c_, _drv_info_,
+			 ("RF-A Legacy to Ht40 Diff[%u] =3D 0x%x\n", ch,
+			  pHalData->TxPwrLegacyHtDiff[RF_PATH_A][ch]));
+	for (ch =3D 0; ch < CHANNEL_MAX_NUMBER; ch++) {
+		RT_TRACE(_module_hci_hal_init_c_, _drv_info_,
+			 ("RF-B Ht20 to HT40 Diff[%u] =3D 0x%x(%d)\n", ch,
+			  pHalData->TxPwrHt20Diff[RF_PATH_B][ch],
+			  pHalData->TxPwrHt20Diff[RF_PATH_B][ch]));
+	}
+	for (ch =3D 0; ch < CHANNEL_MAX_NUMBER; ch++)
+		RT_TRACE(_module_hci_hal_init_c_, _drv_info_,
+			 ("RF-B Legacy to HT40 Diff[%u] =3D 0x%x\n", ch,
+			  pHalData->TxPwrLegacyHtDiff[RF_PATH_B][ch]));
+	if (!AutoLoadFail) {
+		struct registry_priv *registry_par =3D &padapter->registrypriv;
+		if (registry_par->regulatory_tid =3D=3D 0xff) {
+			if (PROMContent[RF_OPTION1_8723A] =3D=3D 0xff)
+				pHalData->EEPROMRegulatory =3D 0;
+			else
+				pHalData->EEPROMRegulatory =3D
+					PROMContent[RF_OPTION1_8723A] & 0x7;
+		} else {
+			pHalData->EEPROMRegulatory =3D
+			    registry_par->regulatory_tid;
+		}
+	} else {
+		pHalData->EEPROMRegulatory =3D 0;
+	}
+	RT_TRACE(_module_hci_hal_init_c_, _drv_info_,
+		 ("EEPROMRegulatory =3D 0x%x\n", pHalData->EEPROMRegulatory));
+
+	if (!AutoLoadFail)
+		pHalData->bTXPowerDataReadFromEEPORM =3D true;
+}
+
+void
+Hal_EfuseParseBTCoexistInfo_8723A(struct rtw_adapter *padapter,
+				  u8 *hwinfo, bool AutoLoadFail)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u8 tempval;
+	u32 tmpu4;
+
+	if (!AutoLoadFail) {
+		tmpu4 =3D rtw_read32(padapter, REG_MULTI_FUNC_CTRL);
+		if (tmpu4 & BT_FUNC_EN)
+			pHalData->EEPROMBluetoothCoexist =3D 1;
+		else
+			pHalData->EEPROMBluetoothCoexist =3D 0;
+		pHalData->EEPROMBluetoothType =3D BT_RTL8723A;
+
+		/*  The following need to be checked with newer version of */
+		/*  eeprom spec */
+		tempval =3D hwinfo[RF_OPTION4_8723A];
+		pHalData->EEPROMBluetoothAntNum =3D (tempval & 0x1);
+		pHalData->EEPROMBluetoothAntIsolation =3D ((tempval & 0x10) >> 4);
+		pHalData->EEPROMBluetoothRadioShared =3D ((tempval & 0x20) >> 5);
+	} else {
+		pHalData->EEPROMBluetoothCoexist =3D 0;
+		pHalData->EEPROMBluetoothType =3D BT_RTL8723A;
+		pHalData->EEPROMBluetoothAntNum =3D Ant_x2;
+		pHalData->EEPROMBluetoothAntIsolation =3D 0;
+		pHalData->EEPROMBluetoothRadioShared =3D BT_Radio_Shared;
+	}
+#ifdef CONFIG_8723AU_BT_COEXIST
+	BT_InitHalVars(padapter);
+#endif
+}
+
+void
+Hal_EfuseParseEEPROMVer(struct rtw_adapter *padapter,
+			u8 *hwinfo, bool AutoLoadFail)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (!AutoLoadFail)
+		pHalData->EEPROMVersion =3D hwinfo[EEPROM_VERSION_8723A];
+	else
+		pHalData->EEPROMVersion =3D 1;
+	RT_TRACE(_module_hci_hal_init_c_, _drv_info_,
+		 ("Hal_EfuseParseEEPROMVer(), EEVer =3D %d\n",
+		  pHalData->EEPROMVersion));
+}
+
+void
+rtl8723a_EfuseParseChnlPlan(struct rtw_adapter *padapter,
+			    u8 *hwinfo, bool AutoLoadFail)
+{
+	padapter->mlmepriv.ChannelPlan =3D
+		hal_com_get_channel_plan23a(padapter, hwinfo ?
+					 hwinfo[EEPROM_ChannelPlan_8723A]:0xFF,
+					 padapter->registrypriv.channel_plan,
+					 RT_CHANNEL_DOMAIN_WORLD_WIDE_13,
+					 AutoLoadFail);
+
+	DBG_8723A("mlmepriv.ChannelPlan =3D 0x%02x\n",
+		  padapter->mlmepriv.ChannelPlan);
+}
+
+void
+Hal_EfuseParseCustomerID(struct rtw_adapter *padapter,
+			 u8 *hwinfo, bool AutoLoadFail)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	if (!AutoLoadFail) {
+		pHalData->EEPROMCustomerID =3D hwinfo[EEPROM_CustomID_8723A];
+		pHalData->EEPROMSubCustomerID =3D
+		    hwinfo[EEPROM_SubCustomID_8723A];
+	} else {
+		pHalData->EEPROMCustomerID =3D 0;
+		pHalData->EEPROMSubCustomerID =3D 0;
+	}
+	RT_TRACE(_module_hci_hal_init_c_, _drv_info_,
+		 ("EEPROM Customer ID: 0x%2x\n", pHalData->EEPROMCustomerID));
+	RT_TRACE(_module_hci_hal_init_c_, _drv_info_,
+		 ("EEPROM SubCustomer ID: 0x%02x\n",
+		  pHalData->EEPROMSubCustomerID));
+}
+
+void
+Hal_EfuseParseAntennaDiversity(struct rtw_adapter *padapter,
+			       u8 *hwinfo, bool AutoLoadFail)
+{
+}
+
+void
+Hal_EfuseParseRateIndicationOption(struct rtw_adapter *padapter,
+				   u8 *hwinfo, bool AutoLoadFail)
+{
+}
+
+void
+Hal_EfuseParseXtal_8723A(struct rtw_adapter *pAdapter,
+			 u8 *hwinfo, u8 AutoLoadFail)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(pAdapter);
+
+	if (!AutoLoadFail) {
+		pHalData->CrystalCap =3D hwinfo[EEPROM_XTAL_K_8723A];
+		if (pHalData->CrystalCap =3D=3D 0xFF)
+			pHalData->CrystalCap =3D EEPROM_Default_CrystalCap_8723A;
+	} else {
+		pHalData->CrystalCap =3D EEPROM_Default_CrystalCap_8723A;
+	}
+	RT_TRACE(_module_hci_hal_init_c_, _drv_info_,
+		 ("%s: CrystalCap =3D 0x%2x\n", __func__,
+		  pHalData->CrystalCap));
+}
+
+void
+Hal_EfuseParseThermalMeter_8723A(struct rtw_adapter *padapter,
+				 u8 *PROMContent, u8 AutoloadFail)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	/*  */
+	/*  ThermalMeter from EEPROM */
+	/*  */
+	if (false =3D=3D AutoloadFail)
+		pHalData->EEPROMThermalMeter =3D
+		    PROMContent[EEPROM_THERMAL_METER_8723A];
+	else
+		pHalData->EEPROMThermalMeter =3D EEPROM_Default_ThermalMeter;
+
+	if ((pHalData->EEPROMThermalMeter =3D=3D 0xff) || (true =3D=3D Autolo=
adFail)) {
+		pHalData->bAPKThermalMeterIgnore =3D true;
+		pHalData->EEPROMThermalMeter =3D EEPROM_Default_ThermalMeter;
+	}
+
+	DBG_8723A("%s: ThermalMeter =3D 0x%x\n", __func__,
+		  pHalData->EEPROMThermalMeter);
+}
+
+void Hal_InitChannelPlan23a(struct rtw_adapter *padapter)
+{
+}
+
+static void rtl8723a_cal_txdesc_chksum(struct tx_desc *ptxdesc)
+{
+	u16 *usPtr =3D (u16 *) ptxdesc;
+	u32 count =3D 16;		/*  (32 bytes / 2 bytes per XOR) =3D> 16 times */
+	u32 index;
+	u16 checksum =3D 0;
+
+	/*  Clear first */
+	ptxdesc->txdw7 &=3D cpu_to_le32(0xffff0000);
+
+	for (index =3D 0; index < count; index++) {
+		checksum ^=3D le16_to_cpu(*(usPtr + index));
+	}
+
+	ptxdesc->txdw7 |=3D cpu_to_le32(checksum & 0x0000ffff);
+}
+
+static void fill_txdesc_sectype(struct pkt_attrib *pattrib,
+				struct txdesc_8723a *ptxdesc)
+{
+	if ((pattrib->encrypt > 0) && !pattrib->bswenc) {
+		switch (pattrib->encrypt) {
+			/*  SEC_TYPE */
+		case _WEP40_:
+		case _WEP104_:
+		case _TKIP_:
+		case _TKIP_WTMIC_:
+			ptxdesc->sectype =3D 1;
+			break;
+
+		case _AES_:
+			ptxdesc->sectype =3D 3;
+			break;
+
+		case _NO_PRIVACY_:
+		default:
+			break;
+		}
+	}
+}
+
+static void fill_txdesc_vcs(struct pkt_attrib *pattrib,
+			    struct txdesc_8723a *ptxdesc)
+{
+	/* DBG_8723A("cvs_mode =3D%d\n", pattrib->vcs_mode); */
+
+	switch (pattrib->vcs_mode) {
+	case RTS_CTS:
+		ptxdesc->rtsen =3D 1;
+		break;
+
+	case CTS_TO_SELF:
+		ptxdesc->cts2self =3D 1;
+		break;
+
+	case NONE_VCS:
+	default:
+		break;
+	}
+
+	if (pattrib->vcs_mode) {
+		ptxdesc->hw_rts_en =3D 1;	/*  ENABLE HW RTS */
+
+		/*  Set RTS BW */
+		if (pattrib->ht_en) {
+			if (pattrib->bwmode & HT_CHANNEL_WIDTH_40)
+				ptxdesc->rts_bw =3D 1;
+
+			switch (pattrib->ch_offset) {
+			case HAL_PRIME_CHNL_OFFSET_DONT_CARE:
+				ptxdesc->rts_sc =3D 0;
+				break;
+
+			case HAL_PRIME_CHNL_OFFSET_LOWER:
+				ptxdesc->rts_sc =3D 1;
+				break;
+
+			case HAL_PRIME_CHNL_OFFSET_UPPER:
+				ptxdesc->rts_sc =3D 2;
+				break;
+
+			default:
+				ptxdesc->rts_sc =3D 3;	/*  Duplicate */
+				break;
+			}
+		}
+	}
+}
+
+static void fill_txdesc_phy(struct pkt_attrib *pattrib,
+			    struct txdesc_8723a *ptxdesc)
+{
+	if (pattrib->ht_en) {
+		if (pattrib->bwmode & HT_CHANNEL_WIDTH_40)
+			ptxdesc->data_bw =3D 1;
+
+		switch (pattrib->ch_offset) {
+		case HAL_PRIME_CHNL_OFFSET_DONT_CARE:
+			ptxdesc->data_sc =3D 0;
+			break;
+
+		case HAL_PRIME_CHNL_OFFSET_LOWER:
+			ptxdesc->data_sc =3D 1;
+			break;
+
+		case HAL_PRIME_CHNL_OFFSET_UPPER:
+			ptxdesc->data_sc =3D 2;
+			break;
+
+		default:
+			ptxdesc->data_sc =3D 3;	/*  Duplicate */
+			break;
+		}
+	}
+}
+
+static void rtl8723a_fill_default_txdesc(struct xmit_frame *pxmitframe=
,
+					 u8 *pbuf)
+{
+	struct rtw_adapter *padapter;
+	struct hal_data_8723a *pHalData;
+	struct dm_priv *pdmpriv;
+	struct mlme_ext_priv *pmlmeext;
+	struct mlme_ext_info *pmlmeinfo;
+	struct pkt_attrib *pattrib;
+	struct txdesc_8723a *ptxdesc;
+	s32 bmcst;
+
+	padapter =3D pxmitframe->padapter;
+	pHalData =3D GET_HAL_DATA(padapter);
+	pdmpriv =3D &pHalData->dmpriv;
+	pmlmeext =3D &padapter->mlmeextpriv;
+	pmlmeinfo =3D &pmlmeext->mlmext_info;
+
+	pattrib =3D &pxmitframe->attrib;
+	bmcst =3D is_multicast_ether_addr(pattrib->ra);
+
+	ptxdesc =3D (struct txdesc_8723a *)pbuf;
+
+	if (pxmitframe->frame_tag =3D=3D DATA_FRAMETAG) {
+		ptxdesc->macid =3D pattrib->mac_id;	/*  CAM_ID(MAC_ID) */
+
+		if (pattrib->ampdu_en =3D=3D true)
+			ptxdesc->agg_en =3D 1;	/*  AGG EN */
+		else
+			ptxdesc->bk =3D 1;	/*  AGG BK */
+
+		ptxdesc->qsel =3D pattrib->qsel;
+		ptxdesc->rate_id =3D pattrib->raid;
+
+		fill_txdesc_sectype(pattrib, ptxdesc);
+
+		ptxdesc->seq =3D pattrib->seqnum;
+
+		if ((pattrib->ether_type !=3D 0x888e) &&
+		    (pattrib->ether_type !=3D 0x0806) &&
+		    (pattrib->dhcp_pkt !=3D 1)) {
+			/*  Non EAP & ARP & DHCP type data packet */
+
+			fill_txdesc_vcs(pattrib, ptxdesc);
+			fill_txdesc_phy(pattrib, ptxdesc);
+
+			ptxdesc->rtsrate =3D 8;	/*  RTS Rate =3D 24M */
+			ptxdesc->data_ratefb_lmt =3D 0x1F;
+			ptxdesc->rts_ratefb_lmt =3D 0xF;
+
+			/*  use REG_INIDATA_RATE_SEL value */
+			ptxdesc->datarate =3D
+				pdmpriv->INIDATA_RATE[pattrib->mac_id];
+
+		} else {
+			/*  EAP data packet and ARP packet. */
+			/*  Use the 1M data rate to send the EAP/ARP packet. */
+			/*  This will maybe make the handshake smooth. */
+
+			ptxdesc->bk =3D 1;	/*  AGG BK */
+			ptxdesc->userate =3D 1;	/*  driver uses rate */
+			if (pmlmeinfo->preamble_mode =3D=3D PREAMBLE_SHORT)
+				ptxdesc->data_short =3D 1;
+			ptxdesc->datarate =3D MRateToHwRate23a(pmlmeext->tx_rate);
+		}
+	} else if (pxmitframe->frame_tag =3D=3D MGNT_FRAMETAG) {
+/*		RT_TRACE(_module_hal_xmit_c_, _drv_notice_,
+		("%s: MGNT_FRAMETAG\n", __func__)); */
+
+		ptxdesc->macid =3D pattrib->mac_id;	/*  CAM_ID(MAC_ID) */
+		ptxdesc->qsel =3D pattrib->qsel;
+		ptxdesc->rate_id =3D pattrib->raid;	/*  Rate ID */
+		ptxdesc->seq =3D pattrib->seqnum;
+		ptxdesc->userate =3D 1;	/*  driver uses rate, 1M */
+		ptxdesc->rty_lmt_en =3D 1;	/*  retry limit enable */
+		ptxdesc->data_rt_lmt =3D 6;	/*  retry limit =3D 6 */
+
+		/* CCX-TXRPT ack for xmit mgmt frames. */
+		if (pxmitframe->ack_report)
+			ptxdesc->ccx =3D 1;
+
+		ptxdesc->datarate =3D MRateToHwRate23a(pmlmeext->tx_rate);
+	} else if (pxmitframe->frame_tag =3D=3D TXAGG_FRAMETAG) {
+		RT_TRACE(_module_hal_xmit_c_, _drv_warning_,
+			 ("%s: TXAGG_FRAMETAG\n", __func__));
+	} else {
+		RT_TRACE(_module_hal_xmit_c_, _drv_warning_,
+			 ("%s: frame_tag =3D 0x%x\n", __func__,
+			  pxmitframe->frame_tag));
+
+		ptxdesc->macid =3D 4;	/*  CAM_ID(MAC_ID) */
+		ptxdesc->rate_id =3D 6;	/*  Rate ID */
+		ptxdesc->seq =3D pattrib->seqnum;
+		ptxdesc->userate =3D 1;	/*  driver uses rate */
+		ptxdesc->datarate =3D MRateToHwRate23a(pmlmeext->tx_rate);
+	}
+
+	ptxdesc->pktlen =3D pattrib->last_txcmdsz;
+	ptxdesc->offset =3D TXDESC_SIZE + OFFSET_SZ;
+	if (bmcst)
+		ptxdesc->bmc =3D 1;
+	ptxdesc->ls =3D 1;
+	ptxdesc->fs =3D 1;
+	ptxdesc->own =3D 1;
+
+	/*  2009.11.05. tynli_test. Suggested by SD4 Filen for FW LPS. */
+	/*  (1) The sequence number of each non-Qos frame / broadcast /
+	 *   multicast / mgnt frame should be controled by Hw because Fw
+	 * will also send null data which we cannot control when Fw LPS enabl=
e.
+	 *  --> default enable non-Qos data sequense number.
+	 2010.06.23. by tynli. */
+	/*  (2) Enable HW SEQ control for beacon packet,
+	 * because we use Hw beacon. */
+	/*  (3) Use HW Qos SEQ to control the seq num of Ext port
+	 * non-Qos packets. */
+	/*  2010.06.23. Added by tynli. */
+	if (!pattrib->qos_en) {
+		/*  Hw set sequence number */
+		ptxdesc->hwseq_en =3D 1;	/*  HWSEQ_EN */
+		ptxdesc->hwseq_sel =3D 0;	/*  HWSEQ_SEL */
+	}
+}
+
+/*
+ *	Description:
+ *
+ *	Parameters:
+ *		pxmitframe	xmitframe
+ *		pbuf		where to fill tx desc
+ */
+void rtl8723a_update_txdesc(struct xmit_frame *pxmitframe, u8 *pbuf)
+{
+	struct tx_desc *pdesc;
+
+	pdesc =3D (struct tx_desc *)pbuf;
+	memset(pdesc, 0, sizeof(struct tx_desc));
+
+	rtl8723a_fill_default_txdesc(pxmitframe, pbuf);
+
+	pdesc->txdw0 =3D cpu_to_le32(pdesc->txdw0);
+	pdesc->txdw1 =3D cpu_to_le32(pdesc->txdw1);
+	pdesc->txdw2 =3D cpu_to_le32(pdesc->txdw2);
+	pdesc->txdw3 =3D cpu_to_le32(pdesc->txdw3);
+	pdesc->txdw4 =3D cpu_to_le32(pdesc->txdw4);
+	pdesc->txdw5 =3D cpu_to_le32(pdesc->txdw5);
+	pdesc->txdw6 =3D cpu_to_le32(pdesc->txdw6);
+	pdesc->txdw7 =3D cpu_to_le32(pdesc->txdw7);
+	rtl8723a_cal_txdesc_chksum(pdesc);
+}
+
+/*
+ *  Description: In normal chip, we should send some packet to Hw whic=
h
+ *  will be used by Fw in FW LPS mode. The function is to fill the Tx
+ * descriptor of this packets, then
+ */
+/*			Fw can tell Hw to send these packet derectly. */
+/*  Added by tynli. 2009.10.15. */
+/*  */
+void rtl8723a_fill_fake_txdesc(struct rtw_adapter *padapter, u8 *pDesc=
,
+			       u32 BufferLen, u8 IsPsPoll, u8 IsBTQosNull)
+{
+	struct tx_desc *ptxdesc;
+
+	/*  Clear all status */
+	ptxdesc =3D (struct tx_desc *)pDesc;
+	memset(pDesc, 0, TXDESC_SIZE);
+
+	/* offset 0 */
+	/* own, bFirstSeg, bLastSeg; */
+	ptxdesc->txdw0 |=3D cpu_to_le32(OWN | FSG | LSG);
+
+	/* 32 bytes for TX Desc */
+	ptxdesc->txdw0 |=3D cpu_to_le32(((TXDESC_SIZE + OFFSET_SZ) <<
+				       OFFSET_SHT) & 0x00ff0000);
+
+	/*  Buffer size + command header */
+	ptxdesc->txdw0 |=3D cpu_to_le32(BufferLen & 0x0000ffff);
+
+	/* offset 4 */
+	/*  Fixed queue of Mgnt queue */
+	ptxdesc->txdw1 |=3D cpu_to_le32((QSLT_MGNT << QSEL_SHT) & 0x00001f00)=
;
+
+	/* Set NAVUSEHDR to prevent Ps-poll AId filed to be changed
+	   to error vlaue by Hw. */
+	if (IsPsPoll) {
+		ptxdesc->txdw1 |=3D cpu_to_le32(NAVUSEHDR);
+	} else {
+		/*  Hw set sequence number */
+		ptxdesc->txdw4 |=3D cpu_to_le32(BIT(7));
+		/* set bit3 to 1. Suugested by TimChen. 2009.12.29. */
+		ptxdesc->txdw3 |=3D cpu_to_le32((8 << 28));
+	}
+
+	if (true =3D=3D IsBTQosNull) {
+		ptxdesc->txdw2 |=3D cpu_to_le32(BIT(23));	/*  BT NULL */
+	}
+
+	/* offset 16 */
+	ptxdesc->txdw4 |=3D cpu_to_le32(BIT(8));	/* driver uses rate */
+
+	/*  USB interface drop packet if the checksum of descriptor isn't
+	    correct. */
+	/*  Using this checksum can let hardware recovery from packet bulk
+	    out error (e.g. Cancel URC, Bulk out error.). */
+	rtl8723a_cal_txdesc_chksum(ptxdesc);
+}
+
+static void hw_var_set_opmode(struct rtw_adapter *padapter, u8 mode)
+{
+	u8 val8;
+
+	if ((mode =3D=3D _HW_STATE_STATION_) || (mode =3D=3D _HW_STATE_NOLINK=
_)) {
+		StopTxBeacon(padapter);
+
+		/*  disable atim wnd */
+		val8 =3D DIS_TSF_UDT | EN_BCN_FUNCTION | DIS_ATIM;
+		SetBcnCtrlReg23a(padapter, val8, ~val8);
+	} else if ((mode =3D=3D _HW_STATE_ADHOC_) /*|| (mode =3D=3D _HW_STATE=
_AP_) */) {
+		ResumeTxBeacon(padapter);
+
+		val8 =3D DIS_TSF_UDT | EN_BCN_FUNCTION | DIS_BCNQ_SUB;
+		SetBcnCtrlReg23a(padapter, val8, ~val8);
+	} else if (mode =3D=3D _HW_STATE_AP_) {
+#ifdef CONFIG_8723AU_BT_COEXIST
+		/*  add NULL Data and BT NULL Data Packets to FW RSVD Page */
+		rtl8723a_set_BTCoex_AP_mode_FwRsvdPkt_cmd(padapter);
+#endif
+
+		ResumeTxBeacon(padapter);
+
+		val8 =3D DIS_TSF_UDT | DIS_BCNQ_SUB;
+		SetBcnCtrlReg23a(padapter, val8, ~val8);
+
+		/*  Set RCR */
+		/* rtw_write32(padapter, REG_RCR, 0x70002a8e);
+		   CBSSID_DATA must set to 0 */
+		/* CBSSID_DATA must set to 0 */
+		rtw_write32(padapter, REG_RCR, 0x7000228e);
+		/*  enable to rx data frame */
+		rtw_write16(padapter, REG_RXFLTMAP2, 0xFFFF);
+		/*  enable to rx ps-poll */
+		rtw_write16(padapter, REG_RXFLTMAP1, 0x0400);
+
+		/*  Beacon Control related register for first time */
+		rtw_write8(padapter, REG_BCNDMATIM, 0x02);	/*  2ms */
+		rtw_write8(padapter, REG_DRVERLYINT, 0x05);	/*  5ms */
+		rtw_write8(padapter, REG_ATIMWND, 0x0a); /*  10ms for port0 */
+		rtw_write16(padapter, REG_BCNTCFG, 0x00);
+		rtw_write16(padapter, REG_TBTT_PROHIBIT, 0xff04);
+		/*  +32767 (~32ms) */
+		rtw_write16(padapter, REG_TSFTR_SYN_OFFSET, 0x7fff);
+
+		/*  reset TSF */
+		rtw_write8(padapter, REG_DUAL_TSF_RST, BIT(0));
+
+		/*  enable BCN Function */
+		/*  don't enable update TSF (due to TSF update when
+		    beacon/probe rsp are received) */
+		val8 =3D DIS_TSF_UDT | EN_BCN_FUNCTION |
+		       EN_TXBCN_RPT | DIS_BCNQ_SUB;
+		SetBcnCtrlReg23a(padapter, val8, ~val8);
+	}
+
+	val8 =3D rtw_read8(padapter, MSR);
+	val8 =3D (val8 & 0xC) | mode;
+	rtw_write8(padapter, MSR, val8);
+}
+
+static void hw_var_set_macaddr(struct rtw_adapter *padapter, u8 *val)
+{
+	u8 idx =3D 0;
+	u32 reg_macid;
+
+	reg_macid =3D REG_MACID;
+
+	for (idx =3D 0; idx < 6; idx++)
+		rtw_write8(padapter, (reg_macid + idx), val[idx]);
+}
+
+static void hw_var_set_bssid(struct rtw_adapter *padapter, u8 *val)
+{
+	u8 idx =3D 0;
+	u32 reg_bssid;
+
+	reg_bssid =3D REG_BSSID;
+
+	for (idx =3D 0; idx < 6; idx++)
+		rtw_write8(padapter, (reg_bssid + idx), val[idx]);
+}
+
+static void hw_var_set_correct_tsf(struct rtw_adapter *padapter)
+{
+	u64 tsf;
+	u32 reg_tsftr;
+	struct mlme_ext_priv *pmlmeext =3D &padapter->mlmeextpriv;
+	struct mlme_ext_info *pmlmeinfo =3D &pmlmeext->mlmext_info;
+
+	/* tsf =3D pmlmeext->TSFValue - ((u32)pmlmeext->TSFValue %
+	   (pmlmeinfo->bcn_interval*1024)) - 1024; us */
+	tsf =3D pmlmeext->TSFValue -
+		rtw_modular6423a(pmlmeext->TSFValue,
+			      (pmlmeinfo->bcn_interval * 1024)) - 1024;	/* us */
+
+	if (((pmlmeinfo->state & 0x03) =3D=3D WIFI_FW_ADHOC_STATE) ||
+	    ((pmlmeinfo->state & 0x03) =3D=3D WIFI_FW_AP_STATE)) {
+		/* pHalData->RegTxPause |=3D STOP_BCNQ;BIT(6) */
+		/* rtw_write8(padapter, REG_TXPAUSE,
+		   (rtw_read8(Adapter, REG_TXPAUSE)|BIT(6))); */
+		StopTxBeacon(padapter);
+	}
+
+	reg_tsftr =3D REG_TSFTR;
+
+	/*  disable related TSF function */
+	SetBcnCtrlReg23a(padapter, 0, EN_BCN_FUNCTION);
+
+	rtw_write32(padapter, reg_tsftr, tsf);
+	rtw_write32(padapter, reg_tsftr + 4, tsf >> 32);
+
+	/* enable related TSF function */
+	SetBcnCtrlReg23a(padapter, EN_BCN_FUNCTION, 0);
+
+	if (((pmlmeinfo->state & 0x03) =3D=3D WIFI_FW_ADHOC_STATE) ||
+	    ((pmlmeinfo->state & 0x03) =3D=3D WIFI_FW_AP_STATE))
+		ResumeTxBeacon(padapter);
+}
+
+static void hw_var_set_mlme_disconnect(struct rtw_adapter *padapter)
+{
+	/*  reject all data frames */
+	rtw_write16(padapter, REG_RXFLTMAP2, 0);
+
+	/*  reset TSF */
+	rtw_write8(padapter, REG_DUAL_TSF_RST, BIT(0));
+
+	/*  disable update TSF */
+	SetBcnCtrlReg23a(padapter, DIS_TSF_UDT, 0);
+}
+
+static void hw_var_set_mlme_join(struct rtw_adapter *padapter, u8 type=
)
+{
+	u8 RetryLimit =3D 0x30;
+
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct mlme_priv *pmlmepriv =3D &padapter->mlmepriv;
+
+	if (type =3D=3D 0) {	/*  prepare to join */
+		u32 v32;
+
+		/*  enable to rx data frame.Accept all data frame */
+		/* rtw_write32(padapter, REG_RCR,
+		   rtw_read32(padapter, REG_RCR)|RCR_ADF); */
+		rtw_write16(padapter, REG_RXFLTMAP2, 0xFFFF);
+
+		v32 =3D rtw_read32(padapter, REG_RCR);
+		v32 |=3D RCR_CBSSID_DATA | RCR_CBSSID_BCN;
+		rtw_write32(padapter, REG_RCR, v32);
+
+		if (check_fwstate(pmlmepriv, WIFI_STATION_STATE) =3D=3D true)
+			RetryLimit =3D
+			    (pHalData->CustomerID =3D=3D RT_CID_CCX) ? 7 : 48;
+		else		/*  Ad-hoc Mode */
+			RetryLimit =3D 0x7;
+	} else if (type =3D=3D 1) {	/*  joinbss_event callback when join res =
< 0 */
+		/*  config RCR to receive different BSSID & not to
+		    receive data frame during linking */
+		rtw_write16(padapter, REG_RXFLTMAP2, 0);
+	} else if (type =3D=3D 2) {	/*  sta add event callback */
+		/*  enable update TSF */
+		SetBcnCtrlReg23a(padapter, 0, DIS_TSF_UDT);
+
+		if (check_fwstate(pmlmepriv,
+				  WIFI_ADHOC_STATE | WIFI_ADHOC_MASTER_STATE)) {
+			/*  fixed beacon issue for 8191su........... */
+			rtw_write8(padapter, 0x542, 0x02);
+			RetryLimit =3D 0x7;
+		}
+	}
+
+	rtw_write16(padapter, REG_RL,
+		    RetryLimit << RETRY_LIMIT_SHORT_SHIFT | RetryLimit <<
+		    RETRY_LIMIT_LONG_SHIFT);
+
+#ifdef CONFIG_8723AU_BT_COEXIST
+	switch (type) {
+	case 0:
+		/*  prepare to join */
+		BT_WifiAssociateNotify(padapter, true);
+		break;
+	case 1:
+		/*  joinbss_event callback when join res < 0 */
+		BT_WifiAssociateNotify(padapter, false);
+		break;
+	case 2:
+		/*  sta add event callback */
+/*		BT_WifiMediaStatusNotify(padapter, RT_MEDIA_CONNECT); */
+		break;
+	}
+#endif
+}
+
+void SetHwReg8723A(struct rtw_adapter *padapter, u8 variable, u8 *val)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	u32 *val32 =3D (u32 *)val;
+
+	switch (variable) {
+	case HW_VAR_MEDIA_STATUS:
+		rtl8723a_set_media_status(padapter, *val);
+		break;
+
+	case HW_VAR_MEDIA_STATUS1:
+		rtl8723a_set_media_status1(padapter, *val);
+		break;
+
+	case HW_VAR_SET_OPMODE:
+		hw_var_set_opmode(padapter, *val);
+		break;
+
+	case HW_VAR_MAC_ADDR:
+		hw_var_set_macaddr(padapter, val);
+		break;
+
+	case HW_VAR_BSSID:
+		hw_var_set_bssid(padapter, val);
+		break;
+
+	case HW_VAR_BASIC_RATE:
+		HalSetBrateCfg23a(padapter, val);
+		break;
+
+	case HW_VAR_TXPAUSE:
+		rtl8723a_set_tx_pause(padapter, *val);
+		break;
+
+	case HW_VAR_BCN_FUNC:
+		rtl8723a_set_bcn_func(padapter, *val);
+		break;
+
+	case HW_VAR_CORRECT_TSF:
+		hw_var_set_correct_tsf(padapter);
+		break;
+
+	case HW_VAR_CHECK_BSSID:
+		rtl8723a_check_bssid(padapter, *val);
+		break;
+
+	case HW_VAR_MLME_DISCONNECT:
+		hw_var_set_mlme_disconnect(padapter);
+		break;
+
+	case HW_VAR_MLME_SITESURVEY:
+		rtl8723a_mlme_sitesurvey(padapter, *val);
+		break;
+
+	case HW_VAR_MLME_JOIN:
+		hw_var_set_mlme_join(padapter, *val);
+		break;
+
+	case HW_VAR_ON_RCR_AM:
+		rtl8723a_on_rcr_am(padapter);
+		break;
+
+	case HW_VAR_OFF_RCR_AM:
+		rtl8723a_off_rcr_am(padapter);
+		break;
+
+	case HW_VAR_BEACON_INTERVAL:
+		rtl8723a_set_beacon_interval(padapter, *((u16 *) val));
+		break;
+
+	case HW_VAR_SLOT_TIME:
+		rtl8723a_set_slot_time(padapter, *val);
+		break;
+
+	case HW_VAR_RESP_SIFS:
+		rtl8723a_set_resp_sifs(padapter, val[0], val[1],
+				       val[2], val[3]);
+		break;
+
+	case HW_VAR_ACK_PREAMBLE:
+		rtl8723a_ack_preamble(padapter, *val);
+		break;
+
+	case HW_VAR_SEC_CFG:
+		rtl8723a_set_sec_cfg(padapter, *val);
+		break;
+
+	case HW_VAR_DM_FLAG:
+		rtl8723a_odm_support_ability_write(padapter, *val32);
+		break;
+	case HW_VAR_DM_FUNC_OP:
+		rtl8723a_odm_support_ability_backup(padapter, *val);
+		break;
+	case HW_VAR_DM_FUNC_SET:
+		rtl8723a_odm_support_ability_set(padapter, *val32);
+		break;
+
+	case HW_VAR_DM_FUNC_CLR:
+		rtl8723a_odm_support_ability_clr(padapter, *val32);
+		break;
+
+	case HW_VAR_CAM_EMPTY_ENTRY:
+		rtl8723a_cam_empty_entry(padapter, *val);
+		break;
+
+	case HW_VAR_CAM_INVALID_ALL:
+		rtl8723a_cam_invalid_all(padapter);
+		break;
+
+	case HW_VAR_CAM_WRITE:
+		rtl8723a_cam_write(padapter, val32[0], val32[1]);
+		break;
+
+	case HW_VAR_AC_PARAM_VO:
+		rtl8723a_set_ac_param_vo(padapter, *val32);
+		break;
+
+	case HW_VAR_AC_PARAM_VI:
+		rtl8723a_set_ac_param_vi(padapter, *val32);
+		break;
+
+	case HW_VAR_AC_PARAM_BE:
+		rtl8723a_set_ac_param_be(padapter, *val32);
+		break;
+
+	case HW_VAR_AC_PARAM_BK:
+		rtl8723a_set_ac_param_bk(padapter, *val32);
+		break;
+
+	case HW_VAR_ACM_CTRL:
+		rtl8723a_set_acm_ctrl(padapter, *val);
+		break;
+
+	case HW_VAR_AMPDU_MIN_SPACE:
+		rtl8723a_set_ampdu_min_space(padapter, *val);
+		break;
+
+	case HW_VAR_AMPDU_FACTOR:
+		rtl8723a_set_ampdu_factor(padapter, *val);
+		break;
+
+	case HW_VAR_RXDMA_AGG_PG_TH:
+		rtl8723a_set_rxdma_agg_pg_th(padapter, *val);
+		break;
+
+	case HW_VAR_H2C_FW_PWRMODE:
+		rtl8723a_set_FwPwrMode_cmd(padapter, *val);
+		break;
+
+	case HW_VAR_H2C_FW_JOINBSSRPT:
+		rtl8723a_set_FwJoinBssReport_cmd(padapter, *val);
+		break;
+
+#ifdef CONFIG_8723AU_P2P
+	case HW_VAR_H2C_FW_P2P_PS_OFFLOAD:
+		rtl8723a_set_p2p_ps_offload_cmd(padapter, *val);
+		break;
+#endif /* CONFIG_8723AU_P2P */
+
+	case HW_VAR_INITIAL_GAIN:
+		rtl8723a_set_initial_gain(padapter, *val32);
+		break;
+	case HW_VAR_EFUSE_BYTES:
+		pHalData->EfuseUsedBytes =3D *((u16 *) val);
+		break;
+	case HW_VAR_EFUSE_BT_BYTES:
+		pHalData->BTEfuseUsedBytes =3D *((u16 *) val);
+		break;
+	case HW_VAR_FIFO_CLEARN_UP:
+		rtl8723a_fifo_cleanup(padapter);
+		break;
+	case HW_VAR_CHECK_TXBUF:
+		break;
+	case HW_VAR_APFM_ON_MAC:
+		rtl8723a_set_apfm_on_mac(padapter, *val);
+		break;
+
+	case HW_VAR_NAV_UPPER:
+		rtl8723a_set_nav_upper(padapter, *val32);
+		break;
+	case HW_VAR_BCN_VALID:
+		rtl8723a_bcn_valid(padapter);
+		break;
+	default:
+		break;
+	}
+
+}
+
+void GetHwReg8723A(struct rtw_adapter *padapter, u8 variable, u8 *val)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+
+	switch (variable) {
+	case HW_VAR_BASIC_RATE:
+		*((u16 *) val) =3D pHalData->BasicRateSet;
+		break;
+
+	case HW_VAR_TXPAUSE:
+		*val =3D rtw_read8(padapter, REG_TXPAUSE);
+		break;
+
+	case HW_VAR_BCN_VALID:
+		/* BCN_VALID, BIT16 of REG_TDECTRL =3D BIT0 of REG_TDECTRL+2 */
+		val[0] =3D (BIT0 & rtw_read8(padapter, REG_TDECTRL + 2)) ? true :
+			false;
+		break;
+
+	case HW_VAR_RF_TYPE:
+		*val =3D pHalData->rf_type;
+		break;
+
+	case HW_VAR_DM_FLAG:
+	{
+		struct dm_odm_t *podmpriv =3D &pHalData->odmpriv;
+		*((u32 *) val) =3D podmpriv->SupportAbility;
+	}
+		break;
+
+	case HW_VAR_FWLPS_RF_ON:
+	{
+		/*  When we halt NIC, we should check if FW LPS is leave. */
+		u32 valRCR;
+
+		if ((padapter->bSurpriseRemoved =3D=3D true) ||
+		    (padapter->pwrctrlpriv.rf_pwrstate =3D=3D rf_off)) {
+			/*  If it is in HW/SW Radio OFF or IPS state, we do
+			    not check Fw LPS Leave, because Fw is unload. */
+			*val =3D true;
+		} else {
+			valRCR =3D rtw_read32(padapter, REG_RCR);
+			valRCR &=3D 0x00070000;
+			if (valRCR)
+				*val =3D false;
+			else
+				*val =3D true;
+		}
+	}
+		break;
+	case HW_VAR_EFUSE_BYTES:
+		*((u16 *) val) =3D pHalData->EfuseUsedBytes;
+		break;
+
+	case HW_VAR_EFUSE_BT_BYTES:
+		*((u16 *) val) =3D pHalData->BTEfuseUsedBytes;
+		break;
+
+	case HW_VAR_APFM_ON_MAC:
+		*val =3D pHalData->bMacPwrCtrlOn;
+		break;
+	case HW_VAR_CHK_HI_QUEUE_EMPTY:
+		*val =3D
+		    ((rtw_read32(padapter, REG_HGQ_INFORMATION) & 0x0000ff00) =3D=3D
+		     0) ? true : false;
+		break;
+	}
+}
+
+#ifdef CONFIG_8723AU_BT_COEXIST
+
+void rtl8723a_SingleDualAntennaDetection(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a *pHalData;
+	struct dm_odm_t *pDM_Odm;
+	struct sw_ant_sw *pDM_SWAT_Table;
+	u8 i;
+
+	pHalData =3D GET_HAL_DATA(padapter);
+	pDM_Odm =3D &pHalData->odmpriv;
+	pDM_SWAT_Table =3D &pDM_Odm->DM_SWAT_Table;
+
+	/*  */
+	/*  <Roger_Notes> RTL8723A Single and Dual antenna dynamic detection
+	    mechanism when RF power state is on. */
+	/*  We should take power tracking, IQK, LCK, RCK RF read/write
+	    operation into consideration. */
+	/*  2011.12.15. */
+	/*  */
+	if (!pHalData->bAntennaDetected) {
+		u8 btAntNum =3D BT_GetPGAntNum(padapter);
+
+		/*  Set default antenna B status */
+		if (btAntNum =3D=3D Ant_x2)
+			pDM_SWAT_Table->ANTB_ON =3D true;
+		else if (btAntNum =3D=3D Ant_x1)
+			pDM_SWAT_Table->ANTB_ON =3D false;
+		else
+			pDM_SWAT_Table->ANTB_ON =3D true;
+
+		if (pHalData->CustomerID !=3D RT_CID_TOSHIBA) {
+			for (i =3D 0; i < MAX_ANTENNA_DETECTION_CNT; i++) {
+				if (ODM_SingleDualAntennaDetection
+				    (&pHalData->odmpriv, ANTTESTALL) =3D=3D true)
+					break;
+			}
+
+			/*  Set default antenna number for BT coexistence */
+			if (btAntNum =3D=3D Ant_x2)
+				BT_SetBtCoexCurrAntNum(padapter,
+						       pDM_SWAT_Table->
+						       ANTB_ON ? 2 : 1);
+		}
+		pHalData->bAntennaDetected =3D true;
+	}
+}
+#endif /*  CONFIG_8723AU_BT_COEXIST */
+
+void rtl8723a_clone_haldata(struct rtw_adapter *dst_adapter,
+			    struct rtw_adapter *src_adapter)
+{
+	memcpy(dst_adapter->HalData, src_adapter->HalData,
+	       dst_adapter->hal_data_sz);
+}
+
+void rtl8723a_start_thread(struct rtw_adapter *padapter)
+{
+}
+
+void rtl8723a_stop_thread(struct rtw_adapter *padapter)
+{
+}
diff --git a/drivers/staging/rtl8723au/hal/rtl8723a_phycfg.c b/drivers/=
staging/rtl8723au/hal/rtl8723a_phycfg.c
new file mode 100644
index 0000000..bac3f3b
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/rtl8723a_phycfg.c
@@ -0,0 +1,1197 @@
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
+#define _RTL8723A_PHYCFG_C_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+#include <rtl8723a_hal.h>
+
+/*---------------------------Define Local Constant--------------------=
-------*/
+/* Channel switch:The size of command tables for switch channel*/
+#define MAX_PRECMD_CNT 16
+#define MAX_RFDEPENDCMD_CNT 16
+#define MAX_POSTCMD_CNT 16
+
+#define MAX_DOZE_WAITING_TIMES_9x 64
+
+/*---------------------------Define Local Constant--------------------=
-------*/
+
+/*------------------------Define global variable----------------------=
-------*/
+
+/*------------------------Define local variable-----------------------=
-------*/
+
+/*--------------------Define export function prototype----------------=
-------*/
+/*  Please refer to header file */
+/*--------------------Define export function prototype----------------=
-------*/
+
+/*----------------------------Function Body---------------------------=
-------*/
+/*  */
+/*  1. BB register R/W API */
+/*  */
+
+/**
+* Function:	phy_CalculateBitShift
+*
+* OverView:	Get shifted position of the BitMask
+*
+* Input:
+*			u32		BitMask,
+*
+* Output:	none
+* Return:		u32		Return the shift bit bit position of the mask
+*/
+static	u32 phy_CalculateBitShift(u32 BitMask)
+{
+	u32 i;
+
+	for (i =3D 0; i <=3D 31; i++) {
+		if (((BitMask>>i) & 0x1) =3D=3D 1)
+			break;
+	}
+
+	return i;
+}
+
+/**
+* Function:	PHY_QueryBBReg
+*
+* OverView:	Read "sepcific bits" from BB register
+*
+* Input:
+*	struct rtw_adapter *	Adapter,
+*	u32			RegAddr,	Target address to be readback
+*	u32			BitMask		Target bit position in the
+*						target address to be readback
+* Output:
+*	None
+* Return:
+*	u32			Data		The readback register value
+* Note:
+*	This function is equal to "GetRegSetting" in PHY programming guide
+*/
+u32
+PHY_QueryBBReg(struct rtw_adapter *Adapter, u32 RegAddr, u32 BitMask)
+{
+	u32	ReturnValue =3D 0, OriginalValue, BitShift;
+
+	OriginalValue =3D rtw_read32(Adapter, RegAddr);
+	BitShift =3D phy_CalculateBitShift(BitMask);
+	ReturnValue =3D (OriginalValue & BitMask) >> BitShift;
+	return ReturnValue;
+}
+
+/**
+* Function:	PHY_SetBBReg
+*
+* OverView:	Write "Specific bits" to BB register (page 8~)
+*
+* Input:
+*	struct rtw_adapter *	Adapter,
+*	u32			RegAddr,	Target address to be modified
+*	u32			BitMask		Target bit position in the
+*						target address to be modified
+*	u32			Data		The new register value in the
+*						target bit position of the
+*						 target address
+*
+* Output:
+*	None
+* Return:
+*	None
+* Note:
+*	This function is equal to "PutRegSetting" in PHY programming guide
+*/
+
+void
+PHY_SetBBReg(struct rtw_adapter *Adapter, u32 RegAddr, u32 BitMask, u3=
2	Data)
+{
+	u32 OriginalValue, BitShift;
+
+	/* RT_TRACE(COMP_RF, DBG_TRACE, ("--->PHY_SetBBReg(): RegAddr(%#lx), =
BitMask(%#lx), Data(%#lx)\n", RegAddr, BitMask, Data)); */
+
+	if (BitMask !=3D bMaskDWord) {/* if not "double word" write */
+		OriginalValue =3D rtw_read32(Adapter, RegAddr);
+		BitShift =3D phy_CalculateBitShift(BitMask);
+		Data =3D ((OriginalValue & (~BitMask)) | (Data << BitShift));
+	}
+
+	rtw_write32(Adapter, RegAddr, Data);
+
+	/* RTPRINT(FPHY, PHY_BBW, ("BBW MASK =3D 0x%lx Addr[0x%lx]=3D 0x%lx\n=
", BitMask, RegAddr, Data)); */
+	/* RT_TRACE(COMP_RF, DBG_TRACE, ("<---PHY_SetBBReg(): RegAddr(%#lx), =
BitMask(%#lx), Data(%#lx)\n", RegAddr, BitMask, Data)); */
+}
+
+/*  */
+/*  2. RF register R/W API */
+/*  */
+
+/**
+* Function:	phy_RFSerialRead
+*
+* OverView:	Read regster from RF chips
+*
+* Input:
+*		struct rtw_adapter *		Adapter,
+*		enum RF_RADIO_PATH	eRFPath,	Radio path of A/B/C/D
+*		u32 Offset,			The target address to be read
+*
+* Output:	None
+* Return:	u32			reback value
+* Note:		Threre are three types of serial operations:
+*		1. Software serial write
+*		2. Hardware LSSI-Low Speed Serial Interface
+*		3. Hardware HSSI-High speed
+*		serial write. Driver need to implement (1) and (2).
+*		This function is equal to the combination of RF_ReadReg() and
+*		RFLSSIRead()
+*/
+static u32
+phy_RFSerialRead(struct rtw_adapter *Adapter, enum RF_RADIO_PATH eRFPa=
th,
+		 u32 Offset)
+{
+	u32 retValue =3D 0;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct bb_reg_define *pPhyReg =3D &pHalData->PHYRegDef[eRFPath];
+	u32 NewOffset;
+	u32 tmplong, tmplong2;
+	u8 RfPiEnable =3D 0;
+	/*  */
+	/*  Make sure RF register offset is correct */
+	/*  */
+	Offset &=3D 0x3f;
+
+	/*  */
+	/*  Switch page for 8256 RF IC */
+	/*  */
+	NewOffset =3D Offset;
+
+	/*  2009/06/17 MH We can not execute IO for power save or
+	    other accident mode. */
+	/* if (RT_CANNOT_IO(Adapter)) */
+	/*  */
+	/*	RTPRINT(FPHY, PHY_RFR, ("phy_RFSerialRead return all one\n")); */
+	/*	return	0xFFFFFFFF; */
+	/*  */
+
+	/*  For 92S LSSI Read RFLSSIRead */
+	/*  For RF A/B write 0x824/82c(does not work in the future) */
+	/*  We must use 0x824 for RF A and B to execute read trigger */
+	tmplong =3D PHY_QueryBBReg(Adapter, rFPGA0_XA_HSSIParameter2, bMaskDW=
ord);
+	if (eRFPath =3D=3D RF_PATH_A)
+		tmplong2 =3D tmplong;
+	else
+		tmplong2 =3D PHY_QueryBBReg(Adapter, pPhyReg->rfHSSIPara2,
+					  bMaskDWord);
+
+	tmplong2 =3D (tmplong2 & ~bLSSIReadAddress) |
+		(NewOffset << 23) | bLSSIReadEdge;	/* T65 RF */
+
+	PHY_SetBBReg(Adapter, rFPGA0_XA_HSSIParameter2,
+		     bMaskDWord, tmplong & (~bLSSIReadEdge));
+	udelay(10);/*  PlatformStallExecution(10); */
+
+	PHY_SetBBReg(Adapter, pPhyReg->rfHSSIPara2, bMaskDWord, tmplong2);
+	udelay(100);/* PlatformStallExecution(100); */
+
+	PHY_SetBBReg(Adapter, rFPGA0_XA_HSSIParameter2, bMaskDWord,
+		     tmplong | bLSSIReadEdge);
+	udelay(10);/* PlatformStallExecution(10); */
+
+	if (eRFPath =3D=3D RF_PATH_A)
+		RfPiEnable =3D (u8)PHY_QueryBBReg(Adapter,
+						rFPGA0_XA_HSSIParameter1, BIT8);
+	else if (eRFPath =3D=3D RF_PATH_B)
+		RfPiEnable =3D (u8)PHY_QueryBBReg(Adapter,
+						rFPGA0_XB_HSSIParameter1, BIT8);
+
+	if (RfPiEnable)	{
+		/* Read from BBreg8b8, 12 bits for 8190, 20bits for T65 RF */
+		retValue =3D PHY_QueryBBReg(Adapter, pPhyReg->rfLSSIReadBackPi,
+					  bLSSIReadBackData);
+		/* DBG_8723A("Readback from RF-PI : 0x%x\n", retValue); */
+	} else {
+		/* Read from BBreg8a0, 12 bits for 8190, 20 bits for T65 RF */
+		retValue =3D PHY_QueryBBReg(Adapter, pPhyReg->rfLSSIReadBack,
+					  bLSSIReadBackData);
+		/* DBG_8723A("Readback from RF-SI : 0x%x\n", retValue); */
+	}
+	/* DBG_8723A("RFR-%d Addr[0x%x]=3D 0x%x\n", eRFPath, pPhyReg->rfLSSIR=
eadBack, retValue); */
+
+	return retValue;
+}
+
+/**
+* Function:	phy_RFSerialWrite
+*
+* OverView:	Write data to RF register (page 8~)
+*
+* Input:
+*	struct rtw_adapter *		Adapter,
+*	enum RF_RADIO_PATH	eRFPath,	Radio path of A/B/C/D
+*	u32 Offset,			The target address to be read
+*	u32 Data			The new register Data in the target
+*					bit position of the target to be read
+*
+* Output:
+*	None
+* Return:
+*	None
+* Note:
+*	Threre are three types of serial operations:
+*		1. Software serial write
+*		2. Hardware LSSI-Low Speed Serial Interface
+*		3. Hardware HSSI-High speed
+*		serial write. Driver need to implement (1) and (2).
+*		This function is equal to the combination of RF_ReadReg() and
+*		RFLSSIRead()
+*
+* Note:	  For RF8256 only
+* The total count of RTL8256(Zebra4) register is around 36 bit it only=
 employs
+* 4-bit RF address. RTL8256 uses "register mode control bit"
+* (Reg00[12], Reg00[10]) to access register address bigger than 0xf.
+* See "Appendix-4 in PHY Configuration programming guide" for more det=
ails.
+* Thus, we define a sub-finction for RTL8526 register address conversi=
on
+* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+* Register Mode:	RegCTL[1]	RegCTL[0]	Note
+*			(Reg00[12])	(Reg00[10])
+* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+* Reg_Mode0		0		x		Reg 0 ~15(0x0 ~ 0xf)
+* ------------------------------------------------------------------
+* Reg_Mode1		1		0		Reg 16 ~30(0x1 ~ 0xf)
+* ------------------------------------------------------------------
+* Reg_Mode2		1		1		Reg 31 ~ 45(0x1 ~ 0xf)
+* ------------------------------------------------------------------
+*
+*	2008/09/02	MH	Add 92S RF definition
+*/
+static	void
+phy_RFSerialWrite(struct rtw_adapter *Adapter, enum RF_RADIO_PATH eRFP=
ath,
+		  u32 Offset, u32 Data)
+{
+	u32 DataAndAddr =3D 0;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct bb_reg_define *pPhyReg =3D &pHalData->PHYRegDef[eRFPath];
+	u32 NewOffset;
+
+	/*  2009/06/17 MH We can not execute IO for power save or
+	    other accident mode. */
+	/* if (RT_CANNOT_IO(Adapter)) */
+	/*  */
+	/*	RTPRINT(FPHY, PHY_RFW, ("phy_RFSerialWrite stop\n")); */
+	/*	return; */
+	/*  */
+
+	Offset &=3D 0x3f;
+
+	/*  */
+	/*  Shadow Update */
+	/*  */
+	/* PHY_RFShadowWrite(Adapter, eRFPath, Offset, Data); */
+
+	/*  */
+	/*  Switch page for 8256 RF IC */
+	/*  */
+	NewOffset =3D Offset;
+
+	/*  */
+	/*  Put write addr in [5:0]  and write data in [31:16] */
+	/*  */
+	/* DataAndAddr =3D (Data<<16) | (NewOffset&0x3f); */
+	/*  T65 RF */
+	DataAndAddr =3D ((NewOffset<<20) | (Data&0x000fffff)) & 0x0fffffff;
+
+	/*  */
+	/*  Write Operation */
+	/*  */
+	PHY_SetBBReg(Adapter, pPhyReg->rf3wireOffset, bMaskDWord, DataAndAddr=
);
+	/* RTPRINT(FPHY, PHY_RFW, ("RFW-%d Addr[0x%lx]=3D 0x%lx\n", eRFPath, =
pPhyReg->rf3wireOffset, DataAndAddr)); */
+
+}
+
+/**
+* Function:	PHY_QueryRFReg
+*
+* OverView:	Query "Specific bits" to RF register (page 8~)
+*
+* Input:
+*	struct rtw_adapter *		Adapter,
+*	enum RF_RADIO_PATH	eRFPath,	Radio path of A/B/C/D
+*	u32 RegAddr,			The target address to be read
+*	u32BitMask			The target bit position in the target
+*					address	to be read
+*
+* Output:
+*	None
+* Return:
+*	u32				Readback value
+* Note:
+*	This function is equal to "GetRFRegSetting" in PHY programming guide
+*/
+u32
+PHY_QueryRFReg(struct rtw_adapter *Adapter, enum RF_RADIO_PATH eRFPath=
,
+	       u32 RegAddr, u32 BitMask)
+{
+	u32 Original_Value, Readback_Value, BitShift;
+	/* struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(Adapter); */
+	/* u8	RFWaitCounter =3D 0; */
+	/* _irqL	irqL; */
+
+	Original_Value =3D phy_RFSerialRead(Adapter, eRFPath, RegAddr);
+
+	BitShift =3D  phy_CalculateBitShift(BitMask);
+	Readback_Value =3D (Original_Value & BitMask) >> BitShift;
+
+	return Readback_Value;
+}
+
+/**
+* Function:	PHY_SetRFReg
+*
+* OverView:	Write "Specific bits" to RF register (page 8~)
+*
+* Input:
+*	struct rtw_adapter *		Adapter,
+*	enum RF_RADIO_PATH	eRFPath,	Radio path of A/B/C/D
+*	u32 RegAddr,			The target address to be modified
+*	u32 BitMask			The target bit position in the target
+*					address to be modified
+*	u32 Data			The new register Data in the target
+*					bit position of the target address
+*
+* Output:
+*	None
+* Return:
+*	None
+* Note:	This function is equal to "PutRFRegSetting" in PHY programming=
 guide
+*/
+void
+PHY_SetRFReg(struct rtw_adapter *Adapter, enum RF_RADIO_PATH eRFPath,
+	     u32 RegAddr, u32 BitMask, u32 Data)
+{
+	/* struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter); */
+	/* u8 RFWaitCounter	=3D 0; */
+	u32 Original_Value, BitShift;
+
+	/*  RF data is 12 bits only */
+	if (BitMask !=3D bRFRegOffsetMask) {
+		Original_Value =3D phy_RFSerialRead(Adapter, eRFPath, RegAddr);
+		BitShift =3D  phy_CalculateBitShift(BitMask);
+		Data =3D ((Original_Value & (~BitMask)) | (Data << BitShift));
+	}
+
+	phy_RFSerialWrite(Adapter, eRFPath, RegAddr, Data);
+}
+
+/*  3. Initial MAC/BB/RF config by reading MAC/BB/RF txt. */
+
+/*--------------------------------------------------------------------=
---------
+ * Function:    PHY_MACConfig8723A
+ *
+ * Overview:	Condig MAC by header file or parameter file.
+ *
+ * Input:       NONE
+ *
+ * Output:      NONE
+ *
+ * Return:      NONE
+ *
+ * Revised History:
+ *  When		Who		Remark
+ *  08/12/2008	MHC		Create Version 0.
+ *
+ *--------------------------------------------------------------------=
-------*/
+s32 PHY_MACConfig8723A(struct rtw_adapter *Adapter)
+{
+	int rtStatus =3D _SUCCESS;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	s8 *pszMACRegFile;
+	s8 sz8723MACRegFile[] =3D RTL8723_PHY_MACREG;
+	bool is92C =3D IS_92C_SERIAL(pHalData->VersionID);
+
+	pszMACRegFile =3D sz8723MACRegFile;
+
+	/*  */
+	/*  Config MAC */
+	/*  */
+	if (HAL_STATUS_FAILURE =3D=3D
+	    ODM_ConfigMACWithHeaderFile23a(&pHalData->odmpriv))
+		rtStatus =3D _FAIL;
+
+	/*  2010.07.13 AMPDU aggregation number 9 */
+	/* rtw_write16(Adapter, REG_MAX_AGGR_NUM, MAX_AGGR_NUM); */
+	rtw_write8(Adapter, REG_MAX_AGGR_NUM, 0x0A); /* By tynli. 2010.11.18.=
 */
+	if (is92C && (BOARD_USB_DONGLE =3D=3D pHalData->BoardType))
+		rtw_write8(Adapter, 0x40, 0x04);
+
+	return rtStatus;
+}
+
+/**
+* Function:	phy_InitBBRFRegisterDefinition
+*
+* OverView:	Initialize Register definition offset for Radio Path A/B/C=
/D
+*
+* Input:
+*			struct rtw_adapter *		Adapter,
+*
+* Output:	None
+* Return:		None
+* Note:
+*	The initialization value is constant and it should never be changes
+*/
+static	void
+phy_InitBBRFRegisterDefinition(struct rtw_adapter *Adapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+
+	/*  RF Interface Sowrtware Control */
+	 /*  16 LSBs if read 32-bit from 0x870 */
+	pHalData->PHYRegDef[RF_PATH_A].rfintfs =3D rFPGA0_XAB_RFInterfaceSW;
+	 /*  16 MSBs if read 32-bit from 0x870 (16-bit for 0x872) */
+	pHalData->PHYRegDef[RF_PATH_B].rfintfs =3D rFPGA0_XAB_RFInterfaceSW;
+	/*  16 LSBs if read 32-bit from 0x874 */
+	pHalData->PHYRegDef[RF_PATH_C].rfintfs =3D rFPGA0_XCD_RFInterfaceSW;
+	/*  16 MSBs if read 32-bit from 0x874 (16-bit for 0x876) */
+	pHalData->PHYRegDef[RF_PATH_D].rfintfs =3D rFPGA0_XCD_RFInterfaceSW;
+
+	/*  RF Interface Readback Value */
+	/*  16 LSBs if read 32-bit from 0x8E0 */
+	pHalData->PHYRegDef[RF_PATH_A].rfintfi =3D rFPGA0_XAB_RFInterfaceRB;
+	/*  16 MSBs if read 32-bit from 0x8E0 (16-bit for 0x8E2) */
+	pHalData->PHYRegDef[RF_PATH_B].rfintfi =3D rFPGA0_XAB_RFInterfaceRB;
+	/*  16 LSBs if read 32-bit from 0x8E4 */
+	pHalData->PHYRegDef[RF_PATH_C].rfintfi =3D rFPGA0_XCD_RFInterfaceRB;
+	/*  16 MSBs if read 32-bit from 0x8E4 (16-bit for 0x8E6) */
+	pHalData->PHYRegDef[RF_PATH_D].rfintfi =3D rFPGA0_XCD_RFInterfaceRB;
+
+	/*  RF Interface Output (and Enable) */
+	/*  16 LSBs if read 32-bit from 0x860 */
+	pHalData->PHYRegDef[RF_PATH_A].rfintfo =3D rFPGA0_XA_RFInterfaceOE;
+	 /*  16 LSBs if read 32-bit from 0x864 */
+	pHalData->PHYRegDef[RF_PATH_B].rfintfo =3D rFPGA0_XB_RFInterfaceOE;
+
+	/*  RF Interface (Output and)  Enable */
+	 /*  16 MSBs if read 32-bit from 0x860 (16-bit for 0x862) */
+	pHalData->PHYRegDef[RF_PATH_A].rfintfe =3D rFPGA0_XA_RFInterfaceOE;
+	/*  16 MSBs if read 32-bit from 0x864 (16-bit for 0x866) */
+	pHalData->PHYRegDef[RF_PATH_B].rfintfe =3D rFPGA0_XB_RFInterfaceOE;
+
+	/* Addr of LSSI. Wirte RF register by driver */
+	pHalData->PHYRegDef[RF_PATH_A].rf3wireOffset =3D rFPGA0_XA_LSSIParame=
ter;
+	pHalData->PHYRegDef[RF_PATH_B].rf3wireOffset =3D rFPGA0_XB_LSSIParame=
ter;
+
+	/*  RF parameter */
+	/* BB Band Select */
+	pHalData->PHYRegDef[RF_PATH_A].rfLSSI_Select =3D rFPGA0_XAB_RFParamet=
er;
+	pHalData->PHYRegDef[RF_PATH_B].rfLSSI_Select =3D rFPGA0_XAB_RFParamet=
er;
+	pHalData->PHYRegDef[RF_PATH_C].rfLSSI_Select =3D rFPGA0_XCD_RFParamet=
er;
+	pHalData->PHYRegDef[RF_PATH_D].rfLSSI_Select =3D rFPGA0_XCD_RFParamet=
er;
+
+	/*  Tx AGC Gain Stage (same for all path. Should we remove this?) */
+	pHalData->PHYRegDef[RF_PATH_A].rfTxGainStage =3D rFPGA0_TxGainStage;
+	pHalData->PHYRegDef[RF_PATH_B].rfTxGainStage =3D rFPGA0_TxGainStage;
+	pHalData->PHYRegDef[RF_PATH_C].rfTxGainStage =3D rFPGA0_TxGainStage;
+	pHalData->PHYRegDef[RF_PATH_D].rfTxGainStage =3D rFPGA0_TxGainStage;
+
+	/*  Tranceiver A~D HSSI Parameter-1 */
+	/* wire control parameter1 */
+	pHalData->PHYRegDef[RF_PATH_A].rfHSSIPara1 =3D rFPGA0_XA_HSSIParamete=
r1;
+	/* wire control parameter1 */
+	pHalData->PHYRegDef[RF_PATH_B].rfHSSIPara1 =3D rFPGA0_XB_HSSIParamete=
r1;
+
+	/*  Tranceiver A~D HSSI Parameter-2 */
+	/* wire control parameter2 */
+	pHalData->PHYRegDef[RF_PATH_A].rfHSSIPara2 =3D rFPGA0_XA_HSSIParamete=
r2;
+	/* wire control parameter2 */
+	pHalData->PHYRegDef[RF_PATH_B].rfHSSIPara2 =3D rFPGA0_XB_HSSIParamete=
r2;
+
+	/*  RF switch Control */
+	pHalData->PHYRegDef[RF_PATH_A].rfSwitchControl =3D
+		rFPGA0_XAB_SwitchControl; /* TR/Ant switch control */
+	pHalData->PHYRegDef[RF_PATH_B].rfSwitchControl =3D
+		rFPGA0_XAB_SwitchControl;
+	pHalData->PHYRegDef[RF_PATH_C].rfSwitchControl =3D
+		rFPGA0_XCD_SwitchControl;
+	pHalData->PHYRegDef[RF_PATH_D].rfSwitchControl =3D
+		rFPGA0_XCD_SwitchControl;
+
+	/*  AGC control 1 */
+	pHalData->PHYRegDef[RF_PATH_A].rfAGCControl1 =3D rOFDM0_XAAGCCore1;
+	pHalData->PHYRegDef[RF_PATH_B].rfAGCControl1 =3D rOFDM0_XBAGCCore1;
+	pHalData->PHYRegDef[RF_PATH_C].rfAGCControl1 =3D rOFDM0_XCAGCCore1;
+	pHalData->PHYRegDef[RF_PATH_D].rfAGCControl1 =3D rOFDM0_XDAGCCore1;
+
+	/*  AGC control 2 */
+	pHalData->PHYRegDef[RF_PATH_A].rfAGCControl2 =3D rOFDM0_XAAGCCore2;
+	pHalData->PHYRegDef[RF_PATH_B].rfAGCControl2 =3D rOFDM0_XBAGCCore2;
+	pHalData->PHYRegDef[RF_PATH_C].rfAGCControl2 =3D rOFDM0_XCAGCCore2;
+	pHalData->PHYRegDef[RF_PATH_D].rfAGCControl2 =3D rOFDM0_XDAGCCore2;
+
+	/*  RX AFE control 1 */
+	pHalData->PHYRegDef[RF_PATH_A].rfRxIQImbalance =3D rOFDM0_XARxIQImbal=
ance;
+	pHalData->PHYRegDef[RF_PATH_B].rfRxIQImbalance =3D rOFDM0_XBRxIQImbal=
ance;
+	pHalData->PHYRegDef[RF_PATH_C].rfRxIQImbalance =3D rOFDM0_XCRxIQImbal=
ance;
+	pHalData->PHYRegDef[RF_PATH_D].rfRxIQImbalance =3D rOFDM0_XDRxIQImbal=
ance;
+
+	/*  RX AFE control 1 */
+	pHalData->PHYRegDef[RF_PATH_A].rfRxAFE =3D rOFDM0_XARxAFE;
+	pHalData->PHYRegDef[RF_PATH_B].rfRxAFE =3D rOFDM0_XBRxAFE;
+	pHalData->PHYRegDef[RF_PATH_C].rfRxAFE =3D rOFDM0_XCRxAFE;
+	pHalData->PHYRegDef[RF_PATH_D].rfRxAFE =3D rOFDM0_XDRxAFE;
+
+	/*  Tx AFE control 1 */
+	pHalData->PHYRegDef[RF_PATH_A].rfTxIQImbalance =3D rOFDM0_XATxIQImbal=
ance;
+	pHalData->PHYRegDef[RF_PATH_B].rfTxIQImbalance =3D rOFDM0_XBTxIQImbal=
ance;
+	pHalData->PHYRegDef[RF_PATH_C].rfTxIQImbalance =3D rOFDM0_XCTxIQImbal=
ance;
+	pHalData->PHYRegDef[RF_PATH_D].rfTxIQImbalance =3D rOFDM0_XDTxIQImbal=
ance;
+
+	/*  Tx AFE control 2 */
+	pHalData->PHYRegDef[RF_PATH_A].rfTxAFE =3D rOFDM0_XATxAFE;
+	pHalData->PHYRegDef[RF_PATH_B].rfTxAFE =3D rOFDM0_XBTxAFE;
+	pHalData->PHYRegDef[RF_PATH_C].rfTxAFE =3D rOFDM0_XCTxAFE;
+	pHalData->PHYRegDef[RF_PATH_D].rfTxAFE =3D rOFDM0_XDTxAFE;
+
+	/*  Tranceiver LSSI Readback SI mode */
+	pHalData->PHYRegDef[RF_PATH_A].rfLSSIReadBack =3D rFPGA0_XA_LSSIReadB=
ack;
+	pHalData->PHYRegDef[RF_PATH_B].rfLSSIReadBack =3D rFPGA0_XB_LSSIReadB=
ack;
+	pHalData->PHYRegDef[RF_PATH_C].rfLSSIReadBack =3D rFPGA0_XC_LSSIReadB=
ack;
+	pHalData->PHYRegDef[RF_PATH_D].rfLSSIReadBack =3D rFPGA0_XD_LSSIReadB=
ack;
+
+	/*  Tranceiver LSSI Readback PI mode */
+	pHalData->PHYRegDef[RF_PATH_A].rfLSSIReadBackPi =3D
+		TransceiverA_HSPI_Readback;
+	pHalData->PHYRegDef[RF_PATH_B].rfLSSIReadBackPi =3D
+		TransceiverB_HSPI_Readback;
+	/* pHalData->PHYRegDef[RF_PATH_C].rfLSSIReadBackPi =3D
+	   rFPGA0_XC_LSSIReadBack; */
+	/* pHalData->PHYRegDef[RF_PATH_D].rfLSSIReadBackPi =3D
+	   rFPGA0_XD_LSSIReadBack; */
+
+}
+
+/*  The following is for High Power PA */
+static void
+storePwrIndexDiffRateOffset(struct rtw_adapter *Adapter, u32 RegAddr,
+			    u32 BitMask, u32 Data)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+
+	if (RegAddr =3D=3D rTxAGC_A_Rate18_06) {
+		pHalData->MCSTxPowerLevelOriginalOffset[pHalData->pwrGroupCnt][0] =3D=
 Data;
+		/* RT_TRACE(COMP_INIT, DBG_TRACE,
+		   ("MCSTxPowerLevelOriginalOffset[%d][0] =3D 0x%lx\n",
+		   pHalData->pwrGroupCnt, */
+		/*	pHalData->MCSTxPowerLevelOriginalOffset[
+			pHalData->pwrGroupCnt][0])); */
+	}
+	if (RegAddr =3D=3D rTxAGC_A_Rate54_24) {
+		pHalData->MCSTxPowerLevelOriginalOffset[pHalData->pwrGroupCnt][1] =3D=
 Data;
+		/* RT_TRACE(COMP_INIT, DBG_TRACE,
+		   ("MCSTxPowerLevelOriginalOffset[%d][1] =3D 0x%lx\n",
+		   pHalData->pwrGroupCnt, */
+		/*	pHalData->MCSTxPowerLevelOriginalOffset[
+			pHalData->pwrGroupCnt][1])); */
+	}
+	if (RegAddr =3D=3D rTxAGC_A_CCK1_Mcs32) {
+		pHalData->MCSTxPowerLevelOriginalOffset[pHalData->pwrGroupCnt][6] =3D=
 Data;
+		/* RT_TRACE(COMP_INIT, DBG_TRACE,
+		   ("MCSTxPowerLevelOriginalOffset[%d][6] =3D 0x%lx\n",
+		   pHalData->pwrGroupCnt, */
+		/*	pHalData->MCSTxPowerLevelOriginalOffset[
+			pHalData->pwrGroupCnt][6])); */
+	}
+	if (RegAddr =3D=3D rTxAGC_B_CCK11_A_CCK2_11 && BitMask =3D=3D 0xfffff=
f00) {
+		pHalData->MCSTxPowerLevelOriginalOffset[pHalData->pwrGroupCnt][7] =3D=
 Data;
+		/* RT_TRACE(COMP_INIT, DBG_TRACE,
+		   ("MCSTxPowerLevelOriginalOffset[%d][7] =3D 0x%lx\n",
+		   pHalData->pwrGroupCnt, */
+		/*	pHalData->MCSTxPowerLevelOriginalOffset[
+			pHalData->pwrGroupCnt][7])); */
+	}
+	if (RegAddr =3D=3D rTxAGC_A_Mcs03_Mcs00) {
+		pHalData->MCSTxPowerLevelOriginalOffset[pHalData->pwrGroupCnt][2] =3D=
 Data;
+		/* RT_TRACE(COMP_INIT, DBG_TRACE,
+		   ("MCSTxPowerLevelOriginalOffset[%d][2] =3D 0x%lx\n",
+		   pHalData->pwrGroupCnt, */
+		/*	pHalData->MCSTxPowerLevelOriginalOffset[
+			pHalData->pwrGroupCnt][2])); */
+	}
+	if (RegAddr =3D=3D rTxAGC_A_Mcs07_Mcs04) {
+		pHalData->MCSTxPowerLevelOriginalOffset[pHalData->pwrGroupCnt][3] =3D=
 Data;
+		/* RT_TRACE(COMP_INIT, DBG_TRACE,
+		   ("MCSTxPowerLevelOriginalOffset[%d][3] =3D 0x%lx\n",
+		   pHalData->pwrGroupCnt, */
+		/*	pHalData->MCSTxPowerLevelOriginalOffset[
+			pHalData->pwrGroupCnt][3])); */
+	}
+	if (RegAddr =3D=3D rTxAGC_A_Mcs11_Mcs08) {
+		pHalData->MCSTxPowerLevelOriginalOffset[pHalData->pwrGroupCnt][4] =3D=
 Data;
+		/* RT_TRACE(COMP_INIT, DBG_TRACE,
+		   ("MCSTxPowerLevelOriginalOffset[%d][4] =3D 0x%lx\n",
+		   pHalData->pwrGroupCnt, */
+		/*	pHalData->MCSTxPowerLevelOriginalOffset[
+			pHalData->pwrGroupCnt][4])); */
+	}
+	if (RegAddr =3D=3D rTxAGC_A_Mcs15_Mcs12) {
+		pHalData->MCSTxPowerLevelOriginalOffset[pHalData->pwrGroupCnt][5] =3D=
 Data;
+		/* RT_TRACE(COMP_INIT, DBG_TRACE,
+		   ("MCSTxPowerLevelOriginalOffset[%d][5] =3D 0x%lx\n",
+		   pHalData->pwrGroupCnt, */
+		/*	pHalData->MCSTxPowerLevelOriginalOffset[
+			pHalData->pwrGroupCnt][5])); */
+	}
+	if (RegAddr =3D=3D rTxAGC_B_Rate18_06) {
+		pHalData->MCSTxPowerLevelOriginalOffset[pHalData->pwrGroupCnt][8] =3D=
 Data;
+		/* RT_TRACE(COMP_INIT, DBG_TRACE,
+		   ("MCSTxPowerLevelOriginalOffset[%d][8] =3D 0x%lx\n",
+		   pHalData->pwrGroupCnt, */
+		/*	pHalData->MCSTxPowerLevelOriginalOffset[
+			pHalData->pwrGroupCnt][8])); */
+	}
+	if (RegAddr =3D=3D rTxAGC_B_Rate54_24) {
+		pHalData->MCSTxPowerLevelOriginalOffset[pHalData->pwrGroupCnt][9] =3D=
 Data;
+		/* RT_TRACE(COMP_INIT, DBG_TRACE,
+		   ("MCSTxPowerLevelOriginalOffset[%d][9] =3D 0x%lx\n",
+		   pHalData->pwrGroupCnt, */
+		/*	pHalData->MCSTxPowerLevelOriginalOffset[
+			pHalData->pwrGroupCnt][9])); */
+	}
+	if (RegAddr =3D=3D rTxAGC_B_CCK1_55_Mcs32) {
+		pHalData->MCSTxPowerLevelOriginalOffset[pHalData->pwrGroupCnt][14] =3D=
 Data;
+		/* RT_TRACE(COMP_INIT, DBG_TRACE,
+		   ("MCSTxPowerLevelOriginalOffset[%d][14] =3D 0x%lx\n",
+		   pHalData->pwrGroupCnt, */
+		/*	pHalData->MCSTxPowerLevelOriginalOffset[
+			pHalData->pwrGroupCnt][14])); */
+	}
+	if (RegAddr =3D=3D rTxAGC_B_CCK11_A_CCK2_11 && BitMask =3D=3D 0x00000=
0ff) {
+		pHalData->MCSTxPowerLevelOriginalOffset[pHalData->pwrGroupCnt][15] =3D=
 Data;
+		/* RT_TRACE(COMP_INIT, DBG_TRACE,
+		   ("MCSTxPowerLevelOriginalOffset[%d][15] =3D 0x%lx\n",
+		   pHalData->pwrGroupCnt, */
+		/*	pHalData->MCSTxPowerLevelOriginalOffset[
+			pHalData->pwrGroupCnt][15])); */
+	}
+	if (RegAddr =3D=3D rTxAGC_B_Mcs03_Mcs00) {
+		pHalData->MCSTxPowerLevelOriginalOffset[pHalData->pwrGroupCnt][10] =3D=
 Data;
+		/* RT_TRACE(COMP_INIT, DBG_TRACE,
+		   ("MCSTxPowerLevelOriginalOffset[%d][10] =3D 0x%lx\n",
+		   pHalData->pwrGroupCnt, */
+		/*	pHalData->MCSTxPowerLevelOriginalOffset[
+			pHalData->pwrGroupCnt][10])); */
+	}
+	if (RegAddr =3D=3D rTxAGC_B_Mcs07_Mcs04) {
+		pHalData->MCSTxPowerLevelOriginalOffset[pHalData->pwrGroupCnt][11] =3D=
 Data;
+		/* RT_TRACE(COMP_INIT, DBG_TRACE,
+		   ("MCSTxPowerLevelOriginalOffset[%d][11] =3D 0x%lx\n",
+		   pHalData->pwrGroupCnt, */
+		/*	pHalData->MCSTxPowerLevelOriginalOffset[
+			pHalData->pwrGroupCnt][11])); */
+	}
+	if (RegAddr =3D=3D rTxAGC_B_Mcs11_Mcs08) {
+		pHalData->MCSTxPowerLevelOriginalOffset[pHalData->pwrGroupCnt][12] =3D=
 Data;
+		/* RT_TRACE(COMP_INIT, DBG_TRACE,
+		   ("MCSTxPowerLevelOriginalOffset[%d][12] =3D 0x%lx\n",
+		   pHalData->pwrGroupCnt, */
+		/*	pHalData->MCSTxPowerLevelOriginalOffset[
+			pHalData->pwrGroupCnt][12])); */
+	}
+	if (RegAddr =3D=3D rTxAGC_B_Mcs15_Mcs12) {
+		pHalData->MCSTxPowerLevelOriginalOffset[pHalData->pwrGroupCnt][13] =3D=
 Data;
+		/* RT_TRACE(COMP_INIT, DBG_TRACE,
+		   ("MCSTxPowerLevelOriginalOffset[%d][13] =3D 0x%lx\n",
+		   pHalData->pwrGroupCnt, */
+		/*	pHalData->MCSTxPowerLevelOriginalOffset[
+			pHalData->pwrGroupCnt][13])); */
+		pHalData->pwrGroupCnt++;
+	}
+}
+
+/*--------------------------------------------------------------------=
---------
+ * Function:	phy_ConfigBBWithPgHeaderFile
+ *
+ * Overview:	Config PHY_REG_PG array
+ *
+ * Input:       NONE
+ *
+ * Output:      NONE
+ *
+ * Return:      NONE
+ *
+ * Revised History:
+ * When		Who	Remark
+ * 11/06/2008	MHC	Add later!!!!!!.. Please modify for new files!!!!
+ * 11/10/2008	tynli	Modify to mew files.
+ *--------------------------------------------------------------------=
-------*/
+static	int
+phy_ConfigBBWithPgHeaderFile(struct rtw_adapter *Adapter, u8 ConfigTyp=
e)
+{
+	int i;
+	u32 *Rtl819XPHY_REGArray_Table_PG;
+	u16 PHY_REGArrayPGLen;
+
+	PHY_REGArrayPGLen =3D Rtl8723_PHY_REG_Array_PGLength;
+	Rtl819XPHY_REGArray_Table_PG =3D (u32 *)Rtl8723_PHY_REG_Array_PG;
+
+	if (ConfigType =3D=3D BaseBand_Config_PHY_REG) {
+		for (i =3D 0; i < PHY_REGArrayPGLen; i =3D i + 3) {
+			storePwrIndexDiffRateOffset(Adapter,
+				Rtl819XPHY_REGArray_Table_PG[i],
+				Rtl819XPHY_REGArray_Table_PG[i+1],
+				Rtl819XPHY_REGArray_Table_PG[i+2]);
+		}
+	}
+
+	return _SUCCESS;
+}	/* phy_ConfigBBWithPgHeaderFile */
+
+static void
+phy_BB8192C_Config_1T(struct rtw_adapter *Adapter)
+{
+	/* for path - B */
+	PHY_SetBBReg(Adapter, rFPGA0_TxInfo, 0x3, 0x2);
+	PHY_SetBBReg(Adapter, rFPGA1_TxInfo, 0x300033, 0x200022);
+
+	/*  20100519 Joseph: Add for 1T2R config. Suggested by Kevin,
+	    Jenyu and Yunan. */
+	PHY_SetBBReg(Adapter, rCCK0_AFESetting, bMaskByte3, 0x45);
+	PHY_SetBBReg(Adapter, rOFDM0_TRxPathEnable, bMaskByte0, 0x23);
+	/*  B path first AGC */
+	PHY_SetBBReg(Adapter, rOFDM0_AGCParameter1, 0x30, 0x1);
+
+	PHY_SetBBReg(Adapter, 0xe74, 0x0c000000, 0x2);
+	PHY_SetBBReg(Adapter, 0xe78, 0x0c000000, 0x2);
+	PHY_SetBBReg(Adapter, 0xe7c, 0x0c000000, 0x2);
+	PHY_SetBBReg(Adapter, 0xe80, 0x0c000000, 0x2);
+	PHY_SetBBReg(Adapter, 0xe88, 0x0c000000, 0x2);
+}
+
+static int
+phy_BB8723a_Config_ParaFile(struct rtw_adapter *Adapter)
+{
+	struct eeprom_priv *pEEPROM =3D GET_EEPROM_EFUSE_PRIV(Adapter);
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	int rtStatus =3D _SUCCESS;
+
+	u8 sz8723BBRegFile[] =3D RTL8723_PHY_REG;
+	u8 sz8723AGCTableFile[] =3D RTL8723_AGC_TAB;
+	u8 sz8723BBRegPgFile[] =3D RTL8723_PHY_REG_PG;
+	u8 sz8723BBRegMpFile[] =3D RTL8723_PHY_REG_MP;
+
+	u8 *pszBBRegFile =3D NULL, *pszAGCTableFile =3D NULL;
+	u8 *pszBBRegPgFile =3D NULL, *pszBBRegMpFile =3D NULL;
+
+	/* RT_TRACE(COMP_INIT, DBG_TRACE, ("=3D=3D>phy_BB8192S_Config_ParaFil=
e\n")); */
+
+	pszBBRegFile =3D sz8723BBRegFile ;
+	pszAGCTableFile =3D sz8723AGCTableFile;
+	pszBBRegPgFile =3D sz8723BBRegPgFile;
+	pszBBRegMpFile =3D sz8723BBRegMpFile;
+
+	/*  */
+	/*  1. Read PHY_REG.TXT BB INIT!! */
+	/*  We will seperate as 88C / 92C according to chip version */
+	/*  */
+	if (HAL_STATUS_FAILURE =3D=3D ODM_ConfigBBWithHeaderFile23a(&pHalData=
->odmpriv,
+							     CONFIG_BB_PHY_REG))
+		rtStatus =3D _FAIL;
+	if (rtStatus !=3D _SUCCESS)
+		goto phy_BB8190_Config_ParaFile_Fail;
+
+	/*  */
+	/*  20100318 Joseph: Config 2T2R to 1T2R if necessary. */
+	/*  */
+	if (pHalData->rf_type =3D=3D RF_1T2R) {
+		phy_BB8192C_Config_1T(Adapter);
+		DBG_8723A("phy_BB8723a_Config_ParaFile():Config to 1T!!\n");
+	}
+
+	/*  */
+	/*  2. If EEPROM or EFUSE autoload OK, We must config by
+	    PHY_REG_PG.txt */
+	/*  */
+	if (pEEPROM->bautoload_fail_flag =3D=3D false) {
+		pHalData->pwrGroupCnt =3D 0;
+
+		rtStatus =3D phy_ConfigBBWithPgHeaderFile(Adapter,
+							BaseBand_Config_PHY_REG);
+	}
+
+	if (rtStatus !=3D _SUCCESS)
+		goto phy_BB8190_Config_ParaFile_Fail;
+
+	/*  */
+	/*  3. BB AGC table Initialization */
+	/*  */
+	if (HAL_STATUS_FAILURE =3D=3D ODM_ConfigBBWithHeaderFile23a(&pHalData=
->odmpriv,
+							     CONFIG_BB_AGC_TAB))
+		rtStatus =3D _FAIL;
+
+phy_BB8190_Config_ParaFile_Fail:
+
+	return rtStatus;
+}
+
+int
+PHY_BBConfig8723A(struct rtw_adapter *Adapter)
+{
+	int rtStatus =3D _SUCCESS;
+	struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(Adapter);
+	u8 TmpU1B =3D 0;
+	u8 CrystalCap;
+
+	phy_InitBBRFRegisterDefinition(Adapter);
+
+	/*  Suggested by Scott. tynli_test. 2010.12.30. */
+	/* 1. 0x28[1] =3D 1 */
+	TmpU1B =3D rtw_read8(Adapter, REG_AFE_PLL_CTRL);
+	udelay(2);
+	rtw_write8(Adapter, REG_AFE_PLL_CTRL, (TmpU1B|BIT1));
+	udelay(2);
+
+	/* 2. 0x29[7:0] =3D 0xFF */
+	rtw_write8(Adapter, REG_AFE_PLL_CTRL+1, 0xff);
+	udelay(2);
+
+	/* 3. 0x02[1:0] =3D 2b'11 */
+	TmpU1B =3D rtw_read8(Adapter, REG_SYS_FUNC_EN);
+	rtw_write8(Adapter, REG_SYS_FUNC_EN,
+		   (TmpU1B | FEN_BB_GLB_RSTn | FEN_BBRSTB));
+
+	/* 4. 0x25[6] =3D 0 */
+	TmpU1B =3D rtw_read8(Adapter, REG_AFE_XTAL_CTRL + 1);
+	rtw_write8(Adapter, REG_AFE_XTAL_CTRL+1, (TmpU1B & (~BIT6)));
+
+	/* 5. 0x24[20] =3D 0	Advised by SD3 Alex Wang. 2011.02.09. */
+	TmpU1B =3D rtw_read8(Adapter, REG_AFE_XTAL_CTRL+2);
+	rtw_write8(Adapter, REG_AFE_XTAL_CTRL+2, (TmpU1B & (~BIT4)));
+
+	/* 6. 0x1f[7:0] =3D 0x07 */
+	rtw_write8(Adapter, REG_RF_CTRL, 0x07);
+
+	/*  */
+	/*  Config BB and AGC */
+	/*  */
+	rtStatus =3D phy_BB8723a_Config_ParaFile(Adapter);
+
+/* only for B-cut */
+	if (pHalData->EEPROMVersion >=3D 0x01) {
+		CrystalCap =3D pHalData->CrystalCap & 0x3F;
+		PHY_SetBBReg(Adapter, REG_MAC_PHY_CTRL, 0xFFF000,
+			     (CrystalCap | (CrystalCap << 6)));
+	}
+
+	PHY_SetBBReg(Adapter, REG_LDOA15_CTRL, bMaskDWord, 0x01572505);
+	return rtStatus;
+}
+
+int
+PHY_RFConfig8723A(struct rtw_adapter *Adapter)
+{
+	int rtStatus =3D _SUCCESS;
+
+	/*  */
+	/*  RF config */
+	/*  */
+	rtStatus =3D PHY_RF6052_Config8723A(Adapter);
+	return rtStatus;
+}
+
+static void getTxPowerIndex(struct rtw_adapter *Adapter,
+			    u8 channel,	u8 *cckPowerLevel,  u8 *ofdmPowerLevel)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	u8 index =3D (channel - 1);
+	/*  1. CCK */
+	cckPowerLevel[RF_PATH_A] =3D pHalData->TxPwrLevelCck[RF_PATH_A][index=
];
+	cckPowerLevel[RF_PATH_B] =3D pHalData->TxPwrLevelCck[RF_PATH_B][index=
];
+
+	/*  2. OFDM for 1S or 2S */
+	if (GET_RF_TYPE(Adapter) =3D=3D RF_1T2R || GET_RF_TYPE(Adapter) =3D=3D=
 RF_1T1R) {
+		/*  Read HT 40 OFDM TX power */
+		ofdmPowerLevel[RF_PATH_A] =3D
+			pHalData->TxPwrLevelHT40_1S[RF_PATH_A][index];
+		ofdmPowerLevel[RF_PATH_B] =3D
+			pHalData->TxPwrLevelHT40_1S[RF_PATH_B][index];
+	} else if (GET_RF_TYPE(Adapter) =3D=3D RF_2T2R) {
+		/*  Read HT 40 OFDM TX power */
+		ofdmPowerLevel[RF_PATH_A] =3D
+			pHalData->TxPwrLevelHT40_2S[RF_PATH_A][index];
+		ofdmPowerLevel[RF_PATH_B] =3D
+			pHalData->TxPwrLevelHT40_2S[RF_PATH_B][index];
+	}
+}
+
+static void ccxPowerIndexCheck(struct rtw_adapter *Adapter, u8 channel=
,
+			       u8 *cckPowerLevel, u8 *ofdmPowerLevel)
+{
+}
+
+/*--------------------------------------------------------------------=
---------
+ * Function:    SetTxPowerLevel8723A()
+ *
+ * Overview:    This function is export to "HalCommon" moudule
+ *			We must consider RF path later!!!!!!!
+ *
+ * Input:       struct rtw_adapter *		Adapter
+ *			u8		channel
+ *
+ * Output:      NONE
+ *
+ * Return:      NONE
+ *
+ *--------------------------------------------------------------------=
-------*/
+void PHY_SetTxPowerLevel8723A(struct rtw_adapter *Adapter, u8 channel)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	u8 cckPowerLevel[2], ofdmPowerLevel[2];	/*  [0]:RF-A, [1]:RF-B */
+
+	if (pHalData->bTXPowerDataReadFromEEPORM =3D=3D false)
+		return;
+
+	getTxPowerIndex(Adapter, channel, &cckPowerLevel[0],
+			&ofdmPowerLevel[0]);
+
+	ccxPowerIndexCheck(Adapter, channel, &cckPowerLevel[0],
+			   &ofdmPowerLevel[0]);
+
+	rtl823a_phy_rf6052setccktxpower(Adapter, &cckPowerLevel[0]);
+	rtl8723a_PHY_RF6052SetOFDMTxPower(Adapter, &ofdmPowerLevel[0], channe=
l);
+}
+
+/*--------------------------------------------------------------------=
---------
+ * Function:    PHY_SetBWMode23aCallback8192C()
+ *
+ * Overview:    Timer callback function for SetSetBWMode23a
+ *
+ * Input:		PRT_TIMER		pTimer
+ *
+ * Output:      NONE
+ *
+ * Return:      NONE
+ *
+ * Note:
+ *	(1) We do not take j mode into consideration now
+ *	(2) Will two workitem of "switch channel" and
+ *	    "switch channel bandwidth" run concurrently?
+ *--------------------------------------------------------------------=
-------*/
+static void
+_PHY_SetBWMode23a92C(struct rtw_adapter *Adapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	u8 regBwOpMode;
+	u8 regRRSR_RSC;
+
+	if (pHalData->rf_chip =3D=3D RF_PSEUDO_11N)
+		return;
+
+	/*  There is no 40MHz mode in RF_8225. */
+	if (pHalData->rf_chip =3D=3D RF_8225)
+		return;
+
+	if (Adapter->bDriverStopped)
+		return;
+
+	/* 3 */
+	/* 3<1>Set MAC register */
+	/* 3 */
+
+	regBwOpMode =3D rtw_read8(Adapter, REG_BWOPMODE);
+	regRRSR_RSC =3D rtw_read8(Adapter, REG_RRSR+2);
+
+	switch (pHalData->CurrentChannelBW) {
+	case HT_CHANNEL_WIDTH_20:
+		regBwOpMode |=3D BW_OPMODE_20MHZ;
+		rtw_write8(Adapter, REG_BWOPMODE, regBwOpMode);
+		break;
+	case HT_CHANNEL_WIDTH_40:
+		regBwOpMode &=3D ~BW_OPMODE_20MHZ;
+		rtw_write8(Adapter, REG_BWOPMODE, regBwOpMode);
+		regRRSR_RSC =3D (regRRSR_RSC & 0x90) |
+			(pHalData->nCur40MhzPrimeSC << 5);
+		rtw_write8(Adapter, REG_RRSR+2, regRRSR_RSC);
+		break;
+
+	default:
+		break;
+	}
+
+	/* 3 */
+	/* 3<2>Set PHY related register */
+	/* 3 */
+	switch (pHalData->CurrentChannelBW) {
+		/* 20 MHz channel*/
+	case HT_CHANNEL_WIDTH_20:
+		PHY_SetBBReg(Adapter, rFPGA0_RFMOD, bRFMOD, 0x0);
+		PHY_SetBBReg(Adapter, rFPGA1_RFMOD, bRFMOD, 0x0);
+		PHY_SetBBReg(Adapter, rFPGA0_AnalogParameter2, BIT10, 1);
+
+		break;
+
+		/* 40 MHz channel*/
+	case HT_CHANNEL_WIDTH_40:
+		PHY_SetBBReg(Adapter, rFPGA0_RFMOD, bRFMOD, 0x1);
+		PHY_SetBBReg(Adapter, rFPGA1_RFMOD, bRFMOD, 0x1);
+
+		/*  Set Control channel to upper or lower. These settings
+		    are required only for 40MHz */
+		PHY_SetBBReg(Adapter, rCCK0_System, bCCKSideBand,
+			     (pHalData->nCur40MhzPrimeSC >> 1));
+		PHY_SetBBReg(Adapter, rOFDM1_LSTF, 0xC00,
+			     pHalData->nCur40MhzPrimeSC);
+		PHY_SetBBReg(Adapter, rFPGA0_AnalogParameter2, BIT10, 0);
+
+		PHY_SetBBReg(Adapter, 0x818, (BIT26 | BIT27),
+			     (pHalData->nCur40MhzPrimeSC =3D=3D
+			      HAL_PRIME_CHNL_OFFSET_LOWER) ? 2:1);
+		break;
+
+	default:
+		/*RT_TRACE(COMP_DBG, DBG_LOUD,
+		  ("PHY_SetBWMode23aCallback8192C(): unknown Bandwidth: %#X\n" \
+		  , pHalData->CurrentChannelBW));*/
+			break;
+	}
+	/* Skip over setting of J-mode in BB register here. Default value
+	   is "None J mode". Emily 20070315 */
+
+	/*  Added it for 20/40 mhz switch time evaluation by guangan 070531 *=
/
+	/* NowL =3D PlatformEFIORead4Byte(Adapter, TSFR); */
+	/* NowH =3D PlatformEFIORead4Byte(Adapter, TSFR+4); */
+	/* EndTime =3D ((u64)NowH << 32) + NowL; */
+	/* RT_TRACE(COMP_SCAN, DBG_LOUD, ("SetBWMode23aCallback8190Pci: time
+	   of SetBWMode23a =3D %I64d us!\n", (EndTime - BeginTime))); */
+
+	/* 3<3>Set RF related register */
+	switch (pHalData->rf_chip) {
+	case RF_8225:
+		/* PHY_SetRF8225Bandwidth(Adapter,
+		   pHalData->CurrentChannelBW); */
+		break;
+
+	case RF_8256:
+		/*  Please implement this function in Hal8190PciPhy8256.c */
+		/* PHY_SetRF8256Bandwidth(Adapter,
+		   pHalData->CurrentChannelBW); */
+		break;
+
+	case RF_8258:
+		/*  Please implement this function in Hal8190PciPhy8258.c */
+		/*  PHY_SetRF8258Bandwidth(); */
+		break;
+
+	case RF_PSEUDO_11N:
+		/*  Do Nothing */
+		break;
+
+	case RF_6052:
+		rtl8723a_phy_rf6052set_bw(Adapter, pHalData->CurrentChannelBW);
+		break;
+
+	default:
+		/* RT_ASSERT(false, ("Unknown RFChipID: %d\n",
+		   pHalData->RFChipID)); */
+		break;
+	}
+
+	/* pHalData->SetBWMode23aInProgress =3D false; */
+
+	/* RT_TRACE(COMP_SCAN, DBG_LOUD,
+	   ("<=3D=3D PHY_SetBWMode23aCallback8192C() \n")); */
+}
+
+ /*-------------------------------------------------------------------=
----------
+ * Function:   SetBWMode23a8190Pci()
+ *
+ * Overview:  This function is export to "HalCommon" moudule
+ *
+ * Input:		struct rtw_adapter *			Adapter
+ *			enum ht_channel_width	Bandwidth	20M or 40M
+ *
+ * Output:      NONE
+ *
+ * Return:      NONE
+ *
+ * Note:		We do not take j mode into consideration now
+ *--------------------------------------------------------------------=
-------*/
+void
+PHY_SetBWMode23a8723A(struct rtw_adapter *Adapter,
+		   enum ht_channel_width Bandwidth, unsigned char Offset)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	enum ht_channel_width tmpBW =3D pHalData->CurrentChannelBW;
+
+	pHalData->CurrentChannelBW =3D Bandwidth;
+
+	pHalData->nCur40MhzPrimeSC =3D Offset;
+
+	if ((!Adapter->bDriverStopped) && (!Adapter->bSurpriseRemoved))
+		_PHY_SetBWMode23a92C(Adapter);
+	else
+		pHalData->CurrentChannelBW =3D tmpBW;
+}
+
+static void _PHY_SwChnl8723A(struct rtw_adapter *Adapter, u8 channel)
+{
+	u8 eRFPath;
+	u32 param1, param2;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+
+	if (Adapter->bNotifyChannelChange)
+		DBG_8723A("[%s] ch =3D %d\n", __FUNCTION__, channel);
+
+	/* s1. pre common command - CmdID_SetTxPowerLevel */
+	PHY_SetTxPowerLevel8723A(Adapter, channel);
+
+	/* s2. RF dependent command - CmdID_RF_WriteReg,
+	   param1 =3D RF_CHNLBW, param2 =3D channel */
+	param1 =3D RF_CHNLBW;
+	param2 =3D channel;
+	for (eRFPath =3D 0; eRFPath < pHalData->NumTotalRFPath; eRFPath++) {
+		pHalData->RfRegChnlVal[eRFPath] =3D
+			(pHalData->RfRegChnlVal[eRFPath] & 0xfffffc00) | param2;
+		PHY_SetRFReg(Adapter, (enum RF_RADIO_PATH)eRFPath, param1,
+			     bRFRegOffsetMask, pHalData->RfRegChnlVal[eRFPath]);
+	}
+
+	/* s3. post common command - CmdID_End, None */
+}
+
+void PHY_SwChnl8723A(struct rtw_adapter *Adapter, u8 channel)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	u8 tmpchannel =3D pHalData->CurrentChannel;
+	bool  result =3D true;
+
+	if (pHalData->rf_chip =3D=3D RF_PSEUDO_11N) {
+		/* return immediately if it is peudo-phy */
+		return;
+	}
+
+	if (channel =3D=3D 0)
+		channel =3D 1;
+
+	pHalData->CurrentChannel =3D channel;
+
+	if ((!Adapter->bDriverStopped) && (!Adapter->bSurpriseRemoved)) {
+		_PHY_SwChnl8723A(Adapter, channel);
+
+		if (!result)
+			pHalData->CurrentChannel =3D tmpchannel;
+	} else {
+		pHalData->CurrentChannel =3D tmpchannel;
+	}
+}
diff --git a/drivers/staging/rtl8723au/hal/rtl8723a_rf6052.c b/drivers/=
staging/rtl8723au/hal/rtl8723a_rf6052.c
new file mode 100644
index 0000000..2a7238b
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/rtl8723a_rf6052.c
@@ -0,0 +1,515 @@
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
+/*********************************************************************=
*********
+ *
+ *
+ * Module:	rtl8192c_rf6052.c	(Source C File)
+ *
+ * Note:	Provide RF 6052 series relative API.
+ *
+ * Function:
+ *
+ * Export:
+ *
+ * Abbrev:
+ *
+ * History:
+ * Data			Who		Remark
+ *
+ * 09/25/2008	MHC		Create initial version.
+ * 11/05/2008	MHC		Add API for tw power setting.
+ *
+ *
+**********************************************************************=
********/
+
+#define _RTL8723A_RF6052_C_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+
+#include <rtl8723a_hal.h>
+
+/*---------------------------Define Local Constant--------------------=
-------*/
+/*  Define local structure for debug!!!!! */
+struct rf_shadow_compare_map {
+	/*  Shadow register value */
+	u32		Value;
+	/*  Compare or not flag */
+	u8		Compare;
+	/*  Record If it had ever modified unpredicted */
+	u8		ErrorOrNot;
+	/*  Recorver Flag */
+	u8		Recorver;
+	/*  */
+	u8		Driver_Write;
+};
+
+/*--------------------------------------------------------------------=
---------
+ * Function:    PHY_RF6052SetBandwidth()
+ *
+ * Overview:    This function is called by SetBWMode23aCallback8190Pci=
() only
+ *
+ * Input:       struct rtw_adapter *				Adapter
+ *			WIRELESS_BANDWIDTH_E	Bandwidth	20M or 40M
+ *
+ * Output:      NONE
+ *
+ * Return:      NONE
+ *
+ * Note:		For RF type 0222D
+ *--------------------------------------------------------------------=
-------*/
+void rtl8723a_phy_rf6052set_bw(
+	struct rtw_adapter *Adapter,
+	enum ht_channel_width Bandwidth)	/* 20M or 40M */
+{
+	struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(Adapter);
+
+	switch (Bandwidth) {
+	case HT_CHANNEL_WIDTH_20:
+		pHalData->RfRegChnlVal[0] =3D ((pHalData->RfRegChnlVal[0] & 0xfffff3=
ff) | 0x0400);
+		PHY_SetRFReg(Adapter, RF_PATH_A, RF_CHNLBW, bRFRegOffsetMask, pHalDa=
ta->RfRegChnlVal[0]);
+		break;
+	case HT_CHANNEL_WIDTH_40:
+		pHalData->RfRegChnlVal[0] =3D ((pHalData->RfRegChnlVal[0] & 0xfffff3=
ff));
+		PHY_SetRFReg(Adapter, RF_PATH_A, RF_CHNLBW, bRFRegOffsetMask, pHalDa=
ta->RfRegChnlVal[0]);
+		break;
+	default:
+		break;
+	}
+}
+
+/*--------------------------------------------------------------------=
---------
+ * Function:	PHY_RF6052SetCckTxPower
+ *
+ * Overview:
+ *
+ * Input:       NONE
+ *
+ * Output:      NONE
+ *
+ * Return:      NONE
+ *
+ * Revised History:
+ * When			Who		Remark
+ * 11/05/2008	MHC		Simulate 8192series..
+ *
+ *--------------------------------------------------------------------=
-------*/
+
+void rtl823a_phy_rf6052setccktxpower(struct rtw_adapter *Adapter, u8 *=
pPowerlevel)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct dm_priv *pdmpriv =3D &pHalData->dmpriv;
+	struct mlme_ext_priv *pmlmeext =3D &Adapter->mlmeextpriv;
+	u32 TxAGC[2] =3D {0, 0}, tmpval =3D 0;
+	bool TurboScanOff =3D false;
+	u8 idx1, idx2;
+	u8 *ptr;
+
+	/*  According to SD3 eechou's suggestion, we need to disable turbo sc=
an for RU. */
+	/*  Otherwise, external PA will be broken if power index > 0x20. */
+	if (pHalData->EEPROMRegulatory !=3D 0 || pHalData->ExternalPA)
+		TurboScanOff =3D true;
+
+	if (pmlmeext->sitesurvey_res.state =3D=3D SCAN_PROCESS) {
+		TxAGC[RF_PATH_A] =3D 0x3f3f3f3f;
+		TxAGC[RF_PATH_B] =3D 0x3f3f3f3f;
+
+		TurboScanOff =3D true;/* disable turbo scan */
+
+		if (TurboScanOff) {
+			for (idx1 =3D RF_PATH_A; idx1 <=3D RF_PATH_B; idx1++) {
+				TxAGC[idx1] =3D
+					pPowerlevel[idx1] | (pPowerlevel[idx1]<<8) |
+					(pPowerlevel[idx1]<<16) | (pPowerlevel[idx1]<<24);
+				/*  2010/10/18 MH For external PA module. We need to limit power i=
ndex to be less than 0x20. */
+				if (TxAGC[idx1] > 0x20 && pHalData->ExternalPA)
+					TxAGC[idx1] =3D 0x20;
+			}
+		}
+	} else {
+/*  20100427 Joseph: Driver dynamic Tx power shall not affect Tx power=
=2E It shall be determined by power training mechanism. */
+/*  Currently, we cannot fully disable driver dynamic tx power mechani=
sm because it is referenced by BT coexist mechanism. */
+/*  In the future, two mechanism shall be separated from each other an=
d maintained independantly. Thanks for Lanhsin's reminder. */
+		if (pdmpriv->DynamicTxHighPowerLvl =3D=3D TxHighPwrLevel_Level1) {
+			TxAGC[RF_PATH_A] =3D 0x10101010;
+			TxAGC[RF_PATH_B] =3D 0x10101010;
+		} else if (pdmpriv->DynamicTxHighPowerLvl =3D=3D TxHighPwrLevel_Leve=
l2) {
+			TxAGC[RF_PATH_A] =3D 0x00000000;
+			TxAGC[RF_PATH_B] =3D 0x00000000;
+		} else {
+			for (idx1 =3D RF_PATH_A; idx1 <=3D RF_PATH_B; idx1++) {
+				TxAGC[idx1] =3D
+					pPowerlevel[idx1] | (pPowerlevel[idx1]<<8) |
+					(pPowerlevel[idx1]<<16) | (pPowerlevel[idx1]<<24);
+			}
+
+			if (pHalData->EEPROMRegulatory =3D=3D 0) {
+				tmpval =3D (pHalData->MCSTxPowerLevelOriginalOffset[0][6]) +
+						(pHalData->MCSTxPowerLevelOriginalOffset[0][7]<<8);
+				TxAGC[RF_PATH_A] +=3D tmpval;
+
+				tmpval =3D (pHalData->MCSTxPowerLevelOriginalOffset[0][14]) +
+						(pHalData->MCSTxPowerLevelOriginalOffset[0][15]<<24);
+				TxAGC[RF_PATH_B] +=3D tmpval;
+			}
+		}
+	}
+
+	for (idx1 =3D RF_PATH_A; idx1 <=3D RF_PATH_B; idx1++) {
+		ptr =3D (u8 *)(&TxAGC[idx1]);
+		for (idx2 =3D 0; idx2 < 4; idx2++) {
+			if (*ptr > RF6052_MAX_TX_PWR)
+				*ptr =3D RF6052_MAX_TX_PWR;
+			ptr++;
+		}
+	}
+
+	/*  rf-A cck tx power */
+	tmpval =3D TxAGC[RF_PATH_A]&0xff;
+	PHY_SetBBReg(Adapter, rTxAGC_A_CCK1_Mcs32, bMaskByte1, tmpval);
+	tmpval =3D TxAGC[RF_PATH_A]>>8;
+	PHY_SetBBReg(Adapter, rTxAGC_B_CCK11_A_CCK2_11, 0xffffff00, tmpval);
+
+	/*  rf-B cck tx power */
+	tmpval =3D TxAGC[RF_PATH_B]>>24;
+	PHY_SetBBReg(Adapter, rTxAGC_B_CCK11_A_CCK2_11, bMaskByte0, tmpval);
+	tmpval =3D TxAGC[RF_PATH_B]&0x00ffffff;
+	PHY_SetBBReg(Adapter, rTxAGC_B_CCK1_55_Mcs32, 0xffffff00, tmpval);
+}	/* PHY_RF6052SetCckTxPower */
+
+/*  powerbase0 for OFDM rates */
+/*  powerbase1 for HT MCS rates */
+static void getPowerBase(
+	struct rtw_adapter *Adapter,
+	u8 *pPowerLevel,
+	u8 Channel,
+	u32 *OfdmBase,
+	u32 *MCSBase
+	)
+{
+	struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(Adapter);
+	u32 powerBase0, powerBase1;
+	u8 Legacy_pwrdiff =3D 0;
+	s8 HT20_pwrdiff =3D 0;
+	u8 i, powerlevel[2];
+
+	for (i =3D 0; i < 2; i++) {
+		powerlevel[i] =3D pPowerLevel[i];
+		Legacy_pwrdiff =3D pHalData->TxPwrLegacyHtDiff[i][Channel-1];
+		powerBase0 =3D powerlevel[i] + Legacy_pwrdiff;
+
+		powerBase0 =3D (powerBase0<<24) | (powerBase0<<16) | (powerBase0<<8)=
 | powerBase0;
+		*(OfdmBase+i) =3D powerBase0;
+	}
+
+	for (i =3D 0; i < 2; i++) {
+		/* Check HT20 to HT40 diff */
+		if (pHalData->CurrentChannelBW =3D=3D HT_CHANNEL_WIDTH_20) {
+			HT20_pwrdiff =3D pHalData->TxPwrHt20Diff[i][Channel-1];
+			powerlevel[i] +=3D HT20_pwrdiff;
+		}
+		powerBase1 =3D powerlevel[i];
+		powerBase1 =3D (powerBase1<<24) | (powerBase1<<16) | (powerBase1<<8)=
 | powerBase1;
+		*(MCSBase+i) =3D powerBase1;
+	}
+}
+
+static void getTxPowerWriteValByRegulatory(
+		struct rtw_adapter *Adapter,
+		u8 Channel,
+		u8 index,
+		u32 *powerBase0,
+		u32 *powerBase1,
+		u32 *pOutWriteVal
+	)
+{
+	struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(Adapter);
+	struct dm_priv	*pdmpriv =3D &pHalData->dmpriv;
+	u8	i, chnlGroup =3D 0, pwr_diff_limit[4];
+	u32	writeVal, customer_limit, rf;
+
+	/*  Index 0 & 1 =3D legacy OFDM, 2-5 =3D HT_MCS rate */
+	for (rf =3D 0; rf < 2; rf++) {
+		switch (pHalData->EEPROMRegulatory) {
+		case 0:	/*  Realtek better performance */
+			/*  increase power diff defined by Realtek for large power */
+			chnlGroup =3D 0;
+			writeVal =3D pHalData->MCSTxPowerLevelOriginalOffset[chnlGroup][ind=
ex+(rf?8:0)] +
+				((index < 2) ? powerBase0[rf] : powerBase1[rf]);
+			break;
+		case 1:	/*  Realtek regulatory */
+			/*  increase power diff defined by Realtek for regulatory */
+			if (pHalData->pwrGroupCnt =3D=3D 1)
+				chnlGroup =3D 0;
+			if (pHalData->pwrGroupCnt >=3D 3) {
+				if (Channel <=3D 3)
+					chnlGroup =3D 0;
+				else if (Channel >=3D 4 && Channel <=3D 9)
+					chnlGroup =3D 1;
+				else if (Channel > 9)
+					chnlGroup =3D 2;
+
+				if (pHalData->CurrentChannelBW =3D=3D HT_CHANNEL_WIDTH_20)
+					chnlGroup++;
+				else
+					chnlGroup +=3D 4;
+			}
+			writeVal =3D pHalData->MCSTxPowerLevelOriginalOffset[chnlGroup][ind=
ex+(rf?8:0)] +
+				   ((index < 2) ? powerBase0[rf] : powerBase1[rf]);
+			break;
+		case 2:	/*  Better regulatory */
+				/*  don't increase any power diff */
+			writeVal =3D ((index < 2) ? powerBase0[rf] : powerBase1[rf]);
+			break;
+		case 3:	/*  Customer defined power diff. */
+			chnlGroup =3D 0;
+
+			for (i =3D 0; i < 4; i++) {
+				pwr_diff_limit[i] =3D (u8)((pHalData->MCSTxPowerLevelOriginalOffse=
t[chnlGroup][index +
+						    (rf ? 8 : 0)]&(0x7f << (i*8))) >> (i*8));
+				if (pHalData->CurrentChannelBW =3D=3D HT_CHANNEL_WIDTH_40) {
+					if (pwr_diff_limit[i] > pHalData->PwrGroupHT40[rf][Channel-1])
+						pwr_diff_limit[i] =3D pHalData->PwrGroupHT40[rf][Channel-1];
+				} else {
+					if (pwr_diff_limit[i] > pHalData->PwrGroupHT20[rf][Channel-1])
+						pwr_diff_limit[i] =3D pHalData->PwrGroupHT20[rf][Channel-1];
+				}
+			}
+			customer_limit =3D (pwr_diff_limit[3]<<24) | (pwr_diff_limit[2]<<16=
) |
+							(pwr_diff_limit[1]<<8) | (pwr_diff_limit[0]);
+			writeVal =3D customer_limit + ((index<2)?powerBase0[rf]:powerBase1[=
rf]);
+			break;
+		default:
+			chnlGroup =3D 0;
+			writeVal =3D pHalData->MCSTxPowerLevelOriginalOffset[chnlGroup][ind=
ex+(rf?8:0)] +
+					((index < 2) ? powerBase0[rf] : powerBase1[rf]);
+			break;
+		}
+
+/*  20100427 Joseph: Driver dynamic Tx power shall not affect Tx power=
=2E It shall be determined by power training mechanism. */
+/*  Currently, we cannot fully disable driver dynamic tx power mechani=
sm because it is referenced by BT coexist mechanism. */
+/*  In the future, two mechanism shall be separated from each other an=
d maintained independantly. Thanks for Lanhsin's reminder. */
+
+		if (pdmpriv->DynamicTxHighPowerLvl =3D=3D TxHighPwrLevel_Level1)
+			writeVal =3D 0x14141414;
+		else if (pdmpriv->DynamicTxHighPowerLvl =3D=3D TxHighPwrLevel_Level2=
)
+			writeVal =3D 0x00000000;
+
+		/*  20100628 Joseph: High power mode for BT-Coexist mechanism. */
+		/*  This mechanism is only applied when Driver-Highpower-Mechanism i=
s OFF. */
+		if (pdmpriv->DynamicTxHighPowerLvl =3D=3D TxHighPwrLevel_BT1)
+			writeVal =3D writeVal - 0x06060606;
+		else if (pdmpriv->DynamicTxHighPowerLvl =3D=3D TxHighPwrLevel_BT2)
+			writeVal =3D writeVal;
+		*(pOutWriteVal+rf) =3D writeVal;
+	}
+}
+
+static void writeOFDMPowerReg(struct rtw_adapter *Adapter, u8 index, u=
32 *pValue)
+{
+	struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(Adapter);
+	u16 RegOffset_A[6] =3D {
+		rTxAGC_A_Rate18_06, rTxAGC_A_Rate54_24,
+		rTxAGC_A_Mcs03_Mcs00, rTxAGC_A_Mcs07_Mcs04,
+		rTxAGC_A_Mcs11_Mcs08, rTxAGC_A_Mcs15_Mcs12
+	};
+	u16 RegOffset_B[6] =3D {
+		rTxAGC_B_Rate18_06, rTxAGC_B_Rate54_24,
+		rTxAGC_B_Mcs03_Mcs00, rTxAGC_B_Mcs07_Mcs04,
+		rTxAGC_B_Mcs11_Mcs08, rTxAGC_B_Mcs15_Mcs12
+	};
+	u8 i, rf, pwr_val[4];
+	u32 writeVal;
+	u16 RegOffset;
+
+	for (rf =3D 0; rf < 2; rf++) {
+		writeVal =3D pValue[rf];
+		for (i =3D 0; i < 4; i++) {
+			pwr_val[i] =3D (u8)((writeVal & (0x7f<<(i*8)))>>(i*8));
+			if (pwr_val[i]  > RF6052_MAX_TX_PWR)
+				pwr_val[i]  =3D RF6052_MAX_TX_PWR;
+		}
+		writeVal =3D (pwr_val[3]<<24) | (pwr_val[2]<<16) |
+			   (pwr_val[1]<<8) | pwr_val[0];
+
+		if (rf =3D=3D 0)
+			RegOffset =3D RegOffset_A[index];
+		else
+			RegOffset =3D RegOffset_B[index];
+
+		PHY_SetBBReg(Adapter, RegOffset, bMaskDWord, writeVal);
+
+		/*  201005115 Joseph: Set Tx Power diff for Tx power training mechan=
ism. */
+		if (((pHalData->rf_type =3D=3D RF_2T2R) &&
+		    (RegOffset =3D=3D rTxAGC_A_Mcs15_Mcs12 ||
+		     RegOffset =3D=3D rTxAGC_B_Mcs15_Mcs12)) ||
+		    ((pHalData->rf_type !=3D RF_2T2R) &&
+		     (RegOffset =3D=3D rTxAGC_A_Mcs07_Mcs04 ||
+		      RegOffset =3D=3D rTxAGC_B_Mcs07_Mcs04))) {
+			writeVal =3D pwr_val[3];
+			if (RegOffset =3D=3D rTxAGC_A_Mcs15_Mcs12 || RegOffset =3D=3D rTxAG=
C_A_Mcs07_Mcs04)
+				RegOffset =3D 0xc90;
+			if (RegOffset =3D=3D rTxAGC_B_Mcs15_Mcs12 || RegOffset =3D=3D rTxAG=
C_B_Mcs07_Mcs04)
+				RegOffset =3D 0xc98;
+			for (i =3D 0; i < 3; i++) {
+				if (i !=3D 2)
+					writeVal =3D (writeVal > 8) ? (writeVal-8) : 0;
+				else
+					writeVal =3D (writeVal > 6) ? (writeVal-6) : 0;
+				rtw_write8(Adapter, (u32)(RegOffset+i), (u8)writeVal);
+			}
+		}
+	}
+}
+/*--------------------------------------------------------------------=
---------
+ * Function:	PHY_RF6052SetOFDMTxPower
+ *
+ * Overview:	For legacy and HY OFDM, we must read EEPROM TX power inde=
x for
+ *			different channel and read original value in TX power register ar=
ea from
+ *			0xe00. We increase offset and original value to be correct tx pwr=
=2E
+ *
+ * Input:       NONE
+ *
+ * Output:      NONE
+ *
+ * Return:      NONE
+ *
+ * Revised History:
+ * When			Who		Remark
+ * 11/05/2008	MHC		Simulate 8192 series method.
+ * 01/06/2009	MHC		1. Prevent Path B tx power overflow or underflow du=
re to
+ *						A/B pwr difference or legacy/HT pwr diff.
+ *						2. We concern with path B legacy/HT OFDM difference.
+ * 01/22/2009	MHC		Support new EPRO format from SD3.
+ *
+ *--------------------------------------------------------------------=
-------*/
+void rtl8723a_PHY_RF6052SetOFDMTxPower(struct rtw_adapter *Adapter, u8=
 *pPowerLevel, u8 Channel)
+{
+	u32 writeVal[2], powerBase0[2], powerBase1[2];
+	u8 index =3D 0;
+
+	getPowerBase(Adapter, pPowerLevel, Channel, &powerBase0[0], &powerBas=
e1[0]);
+
+	for (index =3D 0; index < 6; index++) {
+		getTxPowerWriteValByRegulatory(Adapter, Channel, index,
+			&powerBase0[0], &powerBase1[0], &writeVal[0]);
+
+		writeOFDMPowerReg(Adapter, index, &writeVal[0]);
+	}
+}
+
+static int phy_RF6052_Config_ParaFile(struct rtw_adapter *Adapter)
+{
+	u32 u4RegValue =3D 0;
+	u8 eRFPath;
+	struct bb_reg_define	*pPhyReg;
+	int rtStatus =3D _SUCCESS;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	static char sz8723RadioAFile[] =3D RTL8723_PHY_RADIO_A;
+	static char sz8723RadioBFile[] =3D RTL8723_PHY_RADIO_B;
+	char *pszRadioAFile, *pszRadioBFile;
+
+	pszRadioAFile =3D sz8723RadioAFile;
+	pszRadioBFile =3D sz8723RadioBFile;
+
+	/* 3-----------------------------------------------------------------=
 */
+	/* 3 <2> Initialize RF */
+	/* 3-----------------------------------------------------------------=
 */
+	for (eRFPath =3D 0; eRFPath < pHalData->NumTotalRFPath; eRFPath++) {
+
+		pPhyReg =3D &pHalData->PHYRegDef[eRFPath];
+
+		/*----Store original RFENV control type----*/
+		switch (eRFPath) {
+		case RF_PATH_A:
+		case RF_PATH_C:
+			u4RegValue =3D PHY_QueryBBReg(Adapter, pPhyReg->rfintfs, bRFSI_RFEN=
V);
+			break;
+		case RF_PATH_B:
+		case RF_PATH_D:
+			u4RegValue =3D PHY_QueryBBReg(Adapter, pPhyReg->rfintfs, bRFSI_RFEN=
V<<16);
+			break;
+		}
+
+		/*----Set RF_ENV enable----*/
+		PHY_SetBBReg(Adapter, pPhyReg->rfintfe, bRFSI_RFENV<<16, 0x1);
+		udelay(1);/* PlatformStallExecution(1); */
+
+		/*----Set RF_ENV output high----*/
+		PHY_SetBBReg(Adapter, pPhyReg->rfintfo, bRFSI_RFENV, 0x1);
+		udelay(1);/* PlatformStallExecution(1); */
+
+		/* Set bit number of Address and Data for RF register */
+		PHY_SetBBReg(Adapter, pPhyReg->rfHSSIPara2, b3WireAddressLength, 0x0=
);	/*  Set 1 to 4 bits for 8255 */
+		udelay(1);/* PlatformStallExecution(1); */
+
+		PHY_SetBBReg(Adapter, pPhyReg->rfHSSIPara2, b3WireDataLength, 0x0);	=
/*  Set 0 to 12  bits for 8255 */
+		udelay(1);/* PlatformStallExecution(1); */
+
+		/*----Initialize RF fom connfiguration file----*/
+		switch (eRFPath) {
+		case RF_PATH_A:
+			if (HAL_STATUS_FAILURE =3D=3D ODM_ConfigRFWithHeaderFile23a(&pHalDa=
ta->odmpriv, (enum RF_RADIO_PATH)eRFPath, (enum RF_RADIO_PATH)eRFPath))
+				rtStatus =3D _FAIL;
+			break;
+		case RF_PATH_B:
+			if (HAL_STATUS_FAILURE =3D=3D ODM_ConfigRFWithHeaderFile23a(&pHalDa=
ta->odmpriv, (enum RF_RADIO_PATH)eRFPath, (enum RF_RADIO_PATH)eRFPath))
+				rtStatus =3D _FAIL;
+			break;
+		case RF_PATH_C:
+			break;
+		case RF_PATH_D:
+			break;
+		}
+
+		/*----Restore RFENV control type----*/;
+		switch (eRFPath) {
+		case RF_PATH_A:
+		case RF_PATH_C:
+			PHY_SetBBReg(Adapter, pPhyReg->rfintfs, bRFSI_RFENV, u4RegValue);
+			break;
+		case RF_PATH_B:
+		case RF_PATH_D:
+			PHY_SetBBReg(Adapter, pPhyReg->rfintfs, bRFSI_RFENV<<16, u4RegValue=
);
+			break;
+		}
+
+		if (rtStatus !=3D _SUCCESS) {
+			/* RT_TRACE(COMP_FPGA, DBG_LOUD, ("phy_RF6052_Config_ParaFile():Rad=
io[%d] Fail!!", eRFPath)); */
+			goto phy_RF6052_Config_ParaFile_Fail;
+		}
+	}
+phy_RF6052_Config_ParaFile_Fail:
+	return rtStatus;
+}
+
+int PHY_RF6052_Config8723A(struct rtw_adapter *Adapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	int rtStatus =3D _SUCCESS;
+
+	/*  Initialize general global value */
+	/*  TODO: Extend RF_PATH_C and RF_PATH_D in the future */
+	if (pHalData->rf_type =3D=3D RF_1T1R)
+		pHalData->NumTotalRFPath =3D 1;
+	else
+		pHalData->NumTotalRFPath =3D 2;
+
+	/*  Config BB and RF */
+	rtStatus =3D phy_RF6052_Config_ParaFile(Adapter);
+	return rtStatus;
+}
+
+/* End of HalRf6052.c */
diff --git a/drivers/staging/rtl8723au/hal/rtl8723a_rxdesc.c b/drivers/=
staging/rtl8723au/hal/rtl8723a_rxdesc.c
new file mode 100644
index 0000000..81b5efe
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/rtl8723a_rxdesc.c
@@ -0,0 +1,69 @@
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
+#define _RTL8723A_REDESC_C_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <rtl8723a_hal.h>
+
+static void process_rssi(struct rtw_adapter *padapter,
+			 struct recv_frame *prframe)
+{
+	struct rx_pkt_attrib *pattrib =3D &prframe->attrib;
+	struct signal_stat *signal_stat =3D &padapter->recvpriv.signal_streng=
th_data;
+
+	if (signal_stat->update_req) {
+		signal_stat->total_num =3D 0;
+		signal_stat->total_val =3D 0;
+		signal_stat->update_req =3D 0;
+	}
+
+	signal_stat->total_num++;
+	signal_stat->total_val  +=3D pattrib->phy_info.SignalStrength;
+	signal_stat->avg_val =3D signal_stat->total_val / signal_stat->total_=
num;
+}
+
+static void process_link_qual(struct rtw_adapter *padapter,
+			      struct recv_frame *prframe)
+{
+	struct rx_pkt_attrib *pattrib;
+	struct signal_stat *signal_stat;
+
+	if (prframe =3D=3D NULL || padapter =3D=3D NULL)
+		return;
+
+	pattrib =3D &prframe->attrib;
+	signal_stat =3D &padapter->recvpriv.signal_qual_data;
+
+	if (signal_stat->update_req) {
+		signal_stat->total_num =3D 0;
+		signal_stat->total_val =3D 0;
+		signal_stat->update_req =3D 0;
+	}
+
+	signal_stat->total_num++;
+	signal_stat->total_val  +=3D pattrib->phy_info.SignalQuality;
+	signal_stat->avg_val =3D signal_stat->total_val / signal_stat->total_=
num;
+}
+
+/* void rtl8723a_process_phy_info(struct rtw_adapter *padapter, union =
recv_frame *prframe) */
+void rtl8723a_process_phy_info(struct rtw_adapter *padapter, void *prf=
rame)
+{
+	struct recv_frame *precvframe =3D prframe;
+	/*  Check RSSI */
+	process_rssi(padapter, precvframe);
+	/*  Check EVM */
+	process_link_qual(padapter,  precvframe);
+}
diff --git a/drivers/staging/rtl8723au/hal/rtl8723a_sreset.c b/drivers/=
staging/rtl8723au/hal/rtl8723a_sreset.c
new file mode 100644
index 0000000..c0218e7
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/rtl8723a_sreset.c
@@ -0,0 +1,73 @@
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
+#define _RTL8723A_SRESET_C_
+
+#include <rtl8723a_sreset.h>
+#include <rtl8723a_hal.h>
+
+void rtl8723a_sreset_xmit_status_check(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(padapter);
+	struct sreset_priv *psrtpriv =3D &pHalData->srestpriv;
+
+	unsigned long current_time;
+	struct xmit_priv	*pxmitpriv =3D &padapter->xmitpriv;
+	unsigned int diff_time;
+	u32 txdma_status;
+
+	txdma_status =3D rtw_read32(padapter, REG_TXDMA_STATUS);
+	if (txdma_status !=3D 0) {
+		DBG_8723A("%s REG_TXDMA_STATUS:0x%08x\n", __func__, txdma_status);
+		rtw_hal_sreset_reset23a(padapter);
+	}
+
+	current_time =3D jiffies;
+
+	if (0 =3D=3D pxmitpriv->free_xmitbuf_cnt || 0 =3D=3D pxmitpriv->free_=
xmit_extbuf_cnt) {
+
+		diff_time =3D jiffies_to_msecs(jiffies - psrtpriv->last_tx_time);
+
+		if (diff_time > 2000) {
+			if (psrtpriv->last_tx_complete_time =3D=3D 0) {
+				psrtpriv->last_tx_complete_time =3D current_time;
+			} else {
+				diff_time =3D jiffies_to_msecs(jiffies - psrtpriv->last_tx_complet=
e_time);
+				if (diff_time > 4000) {
+					/* padapter->Wifi_Error_Status =3D WIFI_TX_HANG; */
+					DBG_8723A("%s tx hang\n", __func__);
+					rtw_hal_sreset_reset23a(padapter);
+				}
+			}
+		}
+	}
+
+	if (psrtpriv->dbg_trigger_point =3D=3D SRESET_TGP_XMIT_STATUS) {
+		psrtpriv->dbg_trigger_point =3D SRESET_TGP_NULL;
+		rtw_hal_sreset_reset23a(padapter);
+		return;
+	}
+}
+
+void rtl8723a_sreset_linked_status_check(struct rtw_adapter *padapter)
+{
+	struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(padapter);
+	struct sreset_priv *psrtpriv =3D &pHalData->srestpriv;
+
+	if (psrtpriv->dbg_trigger_point =3D=3D SRESET_TGP_LINK_STATUS) {
+		psrtpriv->dbg_trigger_point =3D SRESET_TGP_NULL;
+		rtw_hal_sreset_reset23a(padapter);
+		return;
+	}
+}
diff --git a/drivers/staging/rtl8723au/hal/rtl8723a_xmit.c b/drivers/st=
aging/rtl8723au/hal/rtl8723a_xmit.c
new file mode 100644
index 0000000..d7612cc
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/rtl8723a_xmit.c
@@ -0,0 +1,52 @@
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
+#define _RTL8723A_XMIT_C_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <rtl8723a_hal.h>
+
+void dump_txrpt_ccx_8723a(void *buf)
+{
+	struct txrpt_ccx_8723a *txrpt_ccx =3D buf;
+
+	DBG_8723A("%s:\n"
+		"tag1:%u, rsvd:%u, int_bt:%u, int_tri:%u, int_ccx:%u\n"
+		"mac_id:%u, pkt_drop:%u, pkt_ok:%u, bmc:%u\n"
+		"retry_cnt:%u, lifetime_over:%u, retry_over:%u\n"
+		"ccx_qtime:%u\n"
+		"final_data_rate:0x%02x\n"
+		"qsel:%u, sw:0x%03x\n"
+		, __func__
+		, txrpt_ccx->tag1, txrpt_ccx->rsvd, txrpt_ccx->int_bt, txrpt_ccx->in=
t_tri, txrpt_ccx->int_ccx
+		, txrpt_ccx->mac_id, txrpt_ccx->pkt_drop, txrpt_ccx->pkt_ok, txrpt_c=
cx->bmc
+		, txrpt_ccx->retry_cnt, txrpt_ccx->lifetime_over, txrpt_ccx->retry_o=
ver
+		, txrpt_ccx_qtime_8723a(txrpt_ccx)
+		, txrpt_ccx->final_data_rate
+		, txrpt_ccx->qsel, txrpt_ccx_sw_8723a(txrpt_ccx)
+	);
+}
+
+void handle_txrpt_ccx_8723a(struct rtw_adapter *adapter, void *buf)
+{
+	struct txrpt_ccx_8723a *txrpt_ccx =3D buf;
+
+	if (txrpt_ccx->int_ccx) {
+		if (txrpt_ccx->pkt_ok)
+			rtw_ack_tx_done23a(&adapter->xmitpriv, RTW_SCTX_DONE_SUCCESS);
+		else
+			rtw_ack_tx_done23a(&adapter->xmitpriv, RTW_SCTX_DONE_CCX_PKT_FAIL);
+	}
+}
diff --git a/drivers/staging/rtl8723au/hal/rtl8723au_led.c b/drivers/st=
aging/rtl8723au/hal/rtl8723au_led.c
new file mode 100644
index 0000000..4d5c909
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/rtl8723au_led.c
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
+
+#include "drv_types.h"
+#include "rtl8723a_hal.h"
+#include "rtl8723a_led.h"
+
+/*  */
+/*  LED object. */
+/*  */
+
+/*  */
+/*	Prototype of protected function. */
+/*  */
+
+/*  */
+/*  LED_819xUsb routines. */
+/*  */
+
+/*	Description: */
+/*		Turn on LED according to LedPin specified. */
+void SwLedOn23a(struct rtw_adapter *padapter, struct led_8723a *pLed)
+{
+	u8	LedCfg =3D 0;
+
+	if ((padapter->bSurpriseRemoved =3D=3D true) || (padapter->bDriverSto=
pped =3D=3D true))
+		return;
+	switch (pLed->LedPin) {
+	case LED_PIN_GPIO0:
+		break;
+	case LED_PIN_LED0:
+		rtw_write8(padapter, REG_LEDCFG0, (LedCfg&0xf0)|BIT5|BIT6); /*  SW c=
ontrol led0 on. */
+		break;
+	case LED_PIN_LED1:
+		rtw_write8(padapter, REG_LEDCFG1, (LedCfg&0x00)|BIT6); /*  SW contro=
l led1 on. */
+		break;
+	case LED_PIN_LED2:
+		LedCfg =3D rtw_read8(padapter, REG_LEDCFG2);
+		rtw_write8(padapter, REG_LEDCFG2, (LedCfg&0x80)|BIT5); /*  SW contro=
l led1 on. */
+		break;
+	default:
+		break;
+	}
+	pLed->bLedOn =3D true;
+}
+
+/*	Description: */
+/*		Turn off LED according to LedPin specified. */
+void SwLedOff23a(struct rtw_adapter *padapter, struct led_8723a *pLed)
+{
+	u8	LedCfg =3D 0;
+	/* struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(padapter); */
+
+	if ((padapter->bSurpriseRemoved) || (padapter->bDriverStopped))
+		goto exit;
+
+	switch (pLed->LedPin) {
+	case LED_PIN_GPIO0:
+		break;
+	case LED_PIN_LED0:
+		rtw_write8(padapter, REG_LEDCFG0, (LedCfg&0xf0)|BIT5|BIT6); /*  SW c=
ontrol led0 on. */
+		break;
+	case LED_PIN_LED1:
+		rtw_write8(padapter, REG_LEDCFG1, (LedCfg&0x00)|BIT5|BIT6); /*  SW c=
ontrol led1 on. */
+		break;
+	case LED_PIN_LED2:
+		LedCfg =3D rtw_read8(padapter, REG_LEDCFG2);
+		rtw_write8(padapter, REG_LEDCFG2, (LedCfg&0x80)|BIT3|BIT5); /*  SW c=
ontrol led1 on. */
+		break;
+	default:
+		break;
+	}
+exit:
+	pLed->bLedOn =3D false;
+}
+
+/*  Interface to manipulate LED objects. */
+
+/*	Description: */
+/*		Initialize all LED_871x objects. */
+void
+rtl8723au_InitSwLeds(struct rtw_adapter	*padapter)
+{
+	struct led_priv *pledpriv =3D &padapter->ledpriv;
+
+	pledpriv->LedControlHandler =3D LedControl871x23a;
+	/* 8723as-vau wifi used led2 */
+	InitLed871x23a(padapter, &pledpriv->SwLed0, LED_PIN_LED2);
+
+/*	InitLed871x23a(padapter,&pledpriv->SwLed1, LED_PIN_LED2); */
+}
+
+/*	Description: */
+/*		DeInitialize all LED_819xUsb objects. */
+void
+rtl8723au_DeInitSwLeds(struct rtw_adapter *padapter)
+{
+	struct led_priv	*ledpriv =3D &padapter->ledpriv;
+
+	DeInitLed871x23a(&ledpriv->SwLed0);
+}
diff --git a/drivers/staging/rtl8723au/hal/rtl8723au_recv.c b/drivers/s=
taging/rtl8723au/hal/rtl8723au_recv.c
new file mode 100644
index 0000000..213d193
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/rtl8723au_recv.c
@@ -0,0 +1,247 @@
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
+#define _RTL8192CU_RECV_C_
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <recv_osdep.h>
+#include <mlme_osdep.h>
+#include <linux/ip.h>
+#include <linux/if_ether.h>
+#include <ethernet.h>
+#include <usb_ops.h>
+#include <wifi.h>
+#include <rtl8723a_hal.h>
+
+void rtl8723au_init_recvbuf(struct rtw_adapter *padapter,
+			    struct recv_buf *precvbuf)
+{
+}
+
+int rtl8723au_init_recv_priv(struct rtw_adapter *padapter)
+{
+	struct recv_priv *precvpriv =3D &padapter->recvpriv;
+	int i, size, res =3D _SUCCESS;
+	struct recv_buf *precvbuf;
+	unsigned long tmpaddr;
+	unsigned long alignment;
+	struct sk_buff *pskb;
+
+	tasklet_init(&precvpriv->recv_tasklet,
+		     (void(*)(unsigned long))rtl8723au_recv_tasklet,
+		     (unsigned long)padapter);
+
+	precvpriv->int_in_urb =3D usb_alloc_urb(0, GFP_KERNEL);
+	if (!precvpriv->int_in_urb)
+		DBG_8723A("alloc_urb for interrupt in endpoint fail !!!!\n");
+	precvpriv->int_in_buf =3D kzalloc(USB_INTR_CONTENT_LENGTH, GFP_KERNEL=
);
+	if (!precvpriv->int_in_buf)
+		DBG_8723A("alloc_mem for interrupt in endpoint fail !!!!\n");
+
+	/* init recv_buf */
+	_rtw_init_queue23a(&precvpriv->free_recv_buf_queue);
+
+	size =3D NR_RECVBUFF * sizeof(struct recv_buf);
+	precvpriv->precv_buf =3D kzalloc(size, GFP_KERNEL);
+	if (!precvpriv->precv_buf) {
+		res =3D _FAIL;
+		RT_TRACE(_module_rtl871x_recv_c_, _drv_err_,
+			 ("alloc recv_buf fail!\n"));
+		goto exit;
+	}
+
+	precvbuf =3D (struct recv_buf *)precvpriv->precv_buf;
+
+	for (i =3D 0; i < NR_RECVBUFF; i++) {
+		INIT_LIST_HEAD(&precvbuf->list);
+
+		res =3D rtw_os_recvbuf_resource_alloc23a(padapter, precvbuf);
+		if (res =3D=3D _FAIL)
+			break;
+
+		precvbuf->adapter =3D padapter;
+
+		precvbuf++;
+	}
+
+	precvpriv->free_recv_buf_queue_cnt =3D NR_RECVBUFF;
+
+	skb_queue_head_init(&precvpriv->rx_skb_queue);
+	skb_queue_head_init(&precvpriv->free_recv_skb_queue);
+
+	for (i =3D 0; i < NR_PREALLOC_RECV_SKB; i++) {
+		size =3D MAX_RECVBUF_SZ + RECVBUFF_ALIGN_SZ;
+		pskb =3D __netdev_alloc_skb(padapter->pnetdev, size, GFP_KERNEL);
+
+		if (pskb) {
+			pskb->dev =3D padapter->pnetdev;
+
+			tmpaddr =3D (unsigned long)pskb->data;
+			alignment =3D tmpaddr & (RECVBUFF_ALIGN_SZ-1);
+			skb_reserve(pskb, (RECVBUFF_ALIGN_SZ - alignment));
+
+			skb_queue_tail(&precvpriv->free_recv_skb_queue, pskb);
+		}
+
+		pskb =3D NULL;
+	}
+
+exit:
+	return res;
+}
+
+void rtl8723au_free_recv_priv(struct rtw_adapter *padapter)
+{
+	int	i;
+	struct recv_buf	*precvbuf;
+	struct recv_priv *precvpriv =3D &padapter->recvpriv;
+
+	precvbuf =3D (struct recv_buf *)precvpriv->precv_buf;
+
+	for (i =3D 0; i < NR_RECVBUFF; i++) {
+		rtw_os_recvbuf_resource_free23a(padapter, precvbuf);
+		precvbuf++;
+	}
+
+	kfree(precvpriv->precv_buf);
+
+	usb_free_urb(precvpriv->int_in_urb);
+	kfree(precvpriv->int_in_buf);
+
+	if (skb_queue_len(&precvpriv->rx_skb_queue))
+		DBG_8723A(KERN_WARNING "rx_skb_queue not empty\n");
+
+	skb_queue_purge(&precvpriv->rx_skb_queue);
+
+	if (skb_queue_len(&precvpriv->free_recv_skb_queue)) {
+		DBG_8723A(KERN_WARNING "free_recv_skb_queue not empty, %d\n",
+			  skb_queue_len(&precvpriv->free_recv_skb_queue));
+	}
+
+	skb_queue_purge(&precvpriv->free_recv_skb_queue);
+}
+
+void update_recvframe_attrib(struct recv_frame *precvframe,
+			     struct recv_stat *prxstat)
+{
+	struct rx_pkt_attrib *pattrib;
+	struct recv_stat report;
+	struct rxreport_8723a *prxreport;
+
+	report.rxdw0 =3D le32_to_cpu(prxstat->rxdw0);
+	report.rxdw1 =3D le32_to_cpu(prxstat->rxdw1);
+	report.rxdw2 =3D le32_to_cpu(prxstat->rxdw2);
+	report.rxdw3 =3D le32_to_cpu(prxstat->rxdw3);
+	report.rxdw4 =3D le32_to_cpu(prxstat->rxdw4);
+	report.rxdw5 =3D le32_to_cpu(prxstat->rxdw5);
+
+	prxreport =3D (struct rxreport_8723a *)&report;
+
+	pattrib =3D &precvframe->attrib;
+	memset(pattrib, 0, sizeof(struct rx_pkt_attrib));
+
+	/*  update rx report to recv_frame attribute */
+	pattrib->pkt_len =3D (u16)prxreport->pktlen;
+	pattrib->drvinfo_sz =3D (u8)(prxreport->drvinfosize << 3);
+	pattrib->physt =3D (u8)prxreport->physt;
+
+	pattrib->crc_err =3D (u8)prxreport->crc32;
+	pattrib->icv_err =3D (u8)prxreport->icverr;
+
+	pattrib->bdecrypted =3D (u8)(prxreport->swdec ? 0 : 1);
+	pattrib->encrypt =3D (u8)prxreport->security;
+
+	pattrib->qos =3D (u8)prxreport->qos;
+	pattrib->priority =3D (u8)prxreport->tid;
+
+	pattrib->amsdu =3D (u8)prxreport->amsdu;
+
+	pattrib->seq_num =3D (u16)prxreport->seq;
+	pattrib->frag_num =3D (u8)prxreport->frag;
+	pattrib->mfrag =3D (u8)prxreport->mf;
+	pattrib->mdata =3D (u8)prxreport->md;
+
+	pattrib->mcs_rate =3D (u8)prxreport->rxmcs;
+	pattrib->rxht =3D (u8)prxreport->rxht;
+}
+
+void update_recvframe_phyinfo(struct recv_frame *precvframe,
+			      struct phy_stat *pphy_status)
+{
+	struct rtw_adapter *padapter =3D precvframe->adapter;
+	struct rx_pkt_attrib *pattrib =3D &precvframe->attrib;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct odm_phy_info *pPHYInfo =3D (struct odm_phy_info *)(&pattrib->p=
hy_info);
+	struct odm_packet_info pkt_info;
+	u8 *sa =3D NULL, *da;
+	struct sta_priv *pstapriv;
+	struct sta_info *psta;
+	struct sk_buff *skb =3D precvframe->pkt;
+	struct ieee80211_hdr *hdr =3D (struct ieee80211_hdr *) skb->data;
+	u8 *wlanhdr =3D skb->data;
+
+	pkt_info.bPacketMatchBSSID =3D false;
+	pkt_info.bPacketToSelf =3D false;
+	pkt_info.bPacketBeacon =3D false;
+
+	pkt_info.bPacketMatchBSSID =3D
+		(!ieee80211_is_ctl(hdr->frame_control) &&
+		 !pattrib->icv_err &&
+		 !pattrib->crc_err &&
+		 !memcmp(get_hdr_bssid(wlanhdr),
+			 get_bssid(&padapter->mlmepriv), ETH_ALEN));
+
+	da =3D ieee80211_get_DA(hdr);
+	pkt_info.bPacketToSelf =3D pkt_info.bPacketMatchBSSID &&
+		(!memcmp(da, myid(&padapter->eeprompriv), ETH_ALEN));
+
+	pkt_info.bPacketBeacon =3D pkt_info.bPacketMatchBSSID &&
+		ieee80211_is_beacon(hdr->frame_control);
+
+	pkt_info.StationID =3D 0xFF;
+	if (pkt_info.bPacketBeacon) {
+		if (check_fwstate(&padapter->mlmepriv, WIFI_STATION_STATE) =3D=3D tr=
ue)
+			sa =3D padapter->mlmepriv.cur_network.network.MacAddress;
+		/* to do Ad-hoc */
+	} else {
+		sa =3D ieee80211_get_SA(hdr);
+	}
+
+	pstapriv =3D &padapter->stapriv;
+	psta =3D rtw_get_stainfo23a(pstapriv, sa);
+	if (psta) {
+		pkt_info.StationID =3D psta->mac_id;
+		/* printk("%s =3D=3D> StationID(%d)\n", __FUNCTION__, pkt_info.Stati=
onID); */
+	}
+	pkt_info.Rate =3D pattrib->mcs_rate;
+
+	ODM_PhyStatusQuery23a(&pHalData->odmpriv, pPHYInfo,
+			   (u8 *)pphy_status, &pkt_info);
+	precvframe->psta =3D NULL;
+	if (pkt_info.bPacketMatchBSSID &&
+	    (check_fwstate(&padapter->mlmepriv, WIFI_AP_STATE) =3D=3D true)) =
{
+		if (psta) {
+			precvframe->psta =3D psta;
+			rtl8723a_process_phy_info(padapter, precvframe);
+		}
+	} else if (pkt_info.bPacketToSelf || pkt_info.bPacketBeacon) {
+		if (check_fwstate(&padapter->mlmepriv,
+				  WIFI_ADHOC_STATE|WIFI_ADHOC_MASTER_STATE) =3D=3D
+		    true) {
+			if (psta)
+				precvframe->psta =3D psta;
+		}
+		rtl8723a_process_phy_info(padapter, precvframe);
+	}
+}
diff --git a/drivers/staging/rtl8723au/hal/rtl8723au_xmit.c b/drivers/s=
taging/rtl8723au/hal/rtl8723au_xmit.c
new file mode 100644
index 0000000..3165ff5
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/rtl8723au_xmit.c
@@ -0,0 +1,548 @@
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
+#define _RTL8192C_XMIT_C_
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <wifi.h>
+#include <osdep_intf.h>
+#include <usb_ops.h>
+/* include <rtl8192c_hal.h> */
+#include <rtl8723a_hal.h>
+
+s32	rtl8723au_init_xmit_priv(struct rtw_adapter *padapter)
+{
+	struct xmit_priv	*pxmitpriv =3D &padapter->xmitpriv;
+
+	tasklet_init(&pxmitpriv->xmit_tasklet,
+	     (void(*)(unsigned long))rtl8723au_xmit_tasklet,
+	     (unsigned long)padapter);
+	return _SUCCESS;
+}
+
+void	rtl8723au_free_xmit_priv(struct rtw_adapter *padapter)
+{
+}
+
+static void do_queue_select(struct rtw_adapter	*padapter, struct pkt_a=
ttrib *pattrib)
+{
+	u8 qsel;
+
+	qsel =3D pattrib->priority;
+	RT_TRACE(_module_rtl871x_xmit_c_, _drv_info_,
+		 ("### do_queue_select priority =3D%d , qsel =3D %d\n",
+		  pattrib->priority, qsel));
+
+	pattrib->qsel =3D qsel;
+}
+
+static int urb_zero_packet_chk(struct rtw_adapter *padapter, int sz)
+{
+	int blnSetTxDescOffset;
+	struct dvobj_priv	*pdvobj =3D adapter_to_dvobj(padapter);
+
+	if (pdvobj->ishighspeed) {
+		if (((sz + TXDESC_SIZE) % 512) =3D=3D 0)
+			blnSetTxDescOffset =3D 1;
+		else
+			blnSetTxDescOffset =3D 0;
+	} else {
+		if (((sz + TXDESC_SIZE) % 64) =3D=3D 0)
+			blnSetTxDescOffset =3D 1;
+		else
+			blnSetTxDescOffset =3D 0;
+	}
+	return blnSetTxDescOffset;
+}
+
+static void rtl8192cu_cal_txdesc_chksum(struct tx_desc	*ptxdesc)
+{
+		u16	*usPtr =3D (u16 *)ptxdesc;
+		u32 count =3D 16;		/*  (32 bytes / 2 bytes per XOR) =3D> 16 times */
+		u32 index;
+		u16 checksum =3D 0;
+
+		/* Clear first */
+		ptxdesc->txdw7 &=3D cpu_to_le32(0xffff0000);
+
+		for (index =3D 0 ; index < count ; index++)
+			checksum =3D checksum ^ le16_to_cpu(*(usPtr + index));
+
+		ptxdesc->txdw7 |=3D cpu_to_le32(0x0000ffff&checksum);
+}
+
+static void fill_txdesc_sectype(struct pkt_attrib *pattrib, struct tx_=
desc *ptxdesc)
+{
+	if ((pattrib->encrypt > 0) && !pattrib->bswenc) {
+		switch (pattrib->encrypt) {
+		/* SEC_TYPE */
+		case _WEP40_:
+		case _WEP104_:
+			ptxdesc->txdw1 |=3D cpu_to_le32((0x01<<22)&0x00c00000);
+			break;
+		case _TKIP_:
+		case _TKIP_WTMIC_:
+			/* ptxdesc->txdw1 |=3D cpu_to_le32((0x02<<22)&0x00c00000); */
+			ptxdesc->txdw1 |=3D cpu_to_le32((0x01<<22)&0x00c00000);
+			break;
+		case _AES_:
+			ptxdesc->txdw1 |=3D cpu_to_le32((0x03<<22)&0x00c00000);
+			break;
+		case _NO_PRIVACY_:
+		default:
+			break;
+		}
+	}
+}
+
+static void fill_txdesc_vcs(struct pkt_attrib *pattrib, u32 *pdw)
+{
+	/* DBG_8723A("cvs_mode =3D%d\n", pattrib->vcs_mode); */
+
+	switch (pattrib->vcs_mode) {
+	case RTS_CTS:
+		*pdw |=3D cpu_to_le32(BIT(12));
+		break;
+	case CTS_TO_SELF:
+		*pdw |=3D cpu_to_le32(BIT(11));
+		break;
+	case NONE_VCS:
+	default:
+		break;
+	}
+
+	if (pattrib->vcs_mode) {
+		*pdw |=3D cpu_to_le32(BIT(13));
+
+		/*  Set RTS BW */
+		if (pattrib->ht_en) {
+			*pdw |=3D (pattrib->bwmode&HT_CHANNEL_WIDTH_40) ?	cpu_to_le32(BIT(2=
7)) : 0;
+
+			if (pattrib->ch_offset =3D=3D HAL_PRIME_CHNL_OFFSET_LOWER)
+				*pdw |=3D cpu_to_le32((0x01<<28)&0x30000000);
+			else if (pattrib->ch_offset =3D=3D HAL_PRIME_CHNL_OFFSET_UPPER)
+				*pdw |=3D cpu_to_le32((0x02<<28)&0x30000000);
+			else if (pattrib->ch_offset =3D=3D HAL_PRIME_CHNL_OFFSET_DONT_CARE)
+				*pdw |=3D 0;
+			else
+				*pdw |=3D cpu_to_le32((0x03<<28)&0x30000000);
+		}
+	}
+}
+
+static void fill_txdesc_phy(struct pkt_attrib *pattrib, u32 *pdw)
+{
+	if (pattrib->ht_en) {
+		*pdw |=3D (pattrib->bwmode&HT_CHANNEL_WIDTH_40) ? cpu_to_le32(BIT(25=
)) : 0;
+
+		if (pattrib->ch_offset =3D=3D HAL_PRIME_CHNL_OFFSET_LOWER)
+			*pdw |=3D cpu_to_le32((0x01<<20)&0x003f0000);
+		else if (pattrib->ch_offset =3D=3D HAL_PRIME_CHNL_OFFSET_UPPER)
+			*pdw |=3D cpu_to_le32((0x02<<20)&0x003f0000);
+		else if (pattrib->ch_offset =3D=3D HAL_PRIME_CHNL_OFFSET_DONT_CARE)
+			*pdw |=3D 0;
+		else
+			*pdw |=3D cpu_to_le32((0x03<<20)&0x003f0000);
+	}
+}
+
+static s32 update_txdesc(struct xmit_frame *pxmitframe, u8 *pmem, s32 =
sz, u8 bagg_pkt)
+{
+	int	pull =3D 0;
+	uint	qsel;
+	struct rtw_adapter	*padapter =3D pxmitframe->padapter;
+	struct pkt_attrib	*pattrib =3D &pxmitframe->attrib;
+	struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(padapter);
+	struct dm_priv	*pdmpriv =3D &pHalData->dmpriv;
+	struct tx_desc	*ptxdesc =3D (struct tx_desc *)pmem;
+	struct mlme_ext_priv	*pmlmeext =3D &padapter->mlmeextpriv;
+	struct mlme_ext_info	*pmlmeinfo =3D &pmlmeext->mlmext_info;
+	int	bmcst =3D is_multicast_ether_addr(pattrib->ra);
+
+	if ((!bagg_pkt) && (urb_zero_packet_chk(padapter, sz) =3D=3D 0)) {
+		ptxdesc =3D (struct tx_desc *)(pmem+PACKET_OFFSET_SZ);
+		pull =3D 1;
+		pxmitframe->pkt_offset--;
+	}
+
+	memset(ptxdesc, 0, sizeof(struct tx_desc));
+
+	if ((pxmitframe->frame_tag&0x0f) =3D=3D DATA_FRAMETAG) {
+		/* offset 4 */
+		ptxdesc->txdw1 |=3D cpu_to_le32(pattrib->mac_id&0x1f);
+
+		qsel =3D (uint)(pattrib->qsel & 0x0000001f);
+		ptxdesc->txdw1 |=3D cpu_to_le32((qsel << QSEL_SHT) & 0x00001f00);
+
+		ptxdesc->txdw1 |=3D cpu_to_le32((pattrib->raid<<16) & 0x000f0000);
+
+		fill_txdesc_sectype(pattrib, ptxdesc);
+
+		if (pattrib->ampdu_en)
+			ptxdesc->txdw1 |=3D cpu_to_le32(BIT(5));/* AGG EN */
+		else
+			ptxdesc->txdw1 |=3D cpu_to_le32(BIT(6));/* AGG BK */
+
+		/* offset 8 */
+
+		/* offset 12 */
+		ptxdesc->txdw3 |=3D cpu_to_le32((pattrib->seqnum<<16)&0xffff0000);
+
+		/* offset 16 , offset 20 */
+		if (pattrib->qos_en)
+			ptxdesc->txdw4 |=3D cpu_to_le32(BIT(6));/* QoS */
+
+		if ((pattrib->ether_type !=3D 0x888e) &&
+		    (pattrib->ether_type !=3D 0x0806) &&
+		    (pattrib->dhcp_pkt !=3D 1)) {
+			/* Non EAP & ARP & DHCP type data packet */
+
+			fill_txdesc_vcs(pattrib, &ptxdesc->txdw4);
+			fill_txdesc_phy(pattrib, &ptxdesc->txdw4);
+
+			ptxdesc->txdw4 |=3D cpu_to_le32(0x00000008);/* RTS Rate =3D 24M */
+			ptxdesc->txdw5 |=3D cpu_to_le32(0x0001ff00);/*  */
+
+			/* use REG_INIDATA_RATE_SEL value */
+			ptxdesc->txdw5 |=3D cpu_to_le32(pdmpriv->INIDATA_RATE[pattrib->mac_=
id]);
+		} else {
+			/*  EAP data packet and ARP packet. */
+			/*  Use the 1M data rate to send the EAP/ARP packet. */
+			/*  This will maybe make the handshake smooth. */
+
+			ptxdesc->txdw1 |=3D cpu_to_le32(BIT(6));/* AGG BK */
+
+			ptxdesc->txdw4 |=3D cpu_to_le32(BIT(8));/* driver uses rate */
+
+			if (pmlmeinfo->preamble_mode =3D=3D PREAMBLE_SHORT)
+				ptxdesc->txdw4 |=3D cpu_to_le32(BIT(24));/*  DATA_SHORT */
+
+			ptxdesc->txdw5 |=3D cpu_to_le32(MRateToHwRate23a(pmlmeext->tx_rate)=
);
+		}
+	} else if ((pxmitframe->frame_tag&0x0f) =3D=3D MGNT_FRAMETAG) {
+		/* offset 4 */
+		ptxdesc->txdw1 |=3D cpu_to_le32(pattrib->mac_id&0x1f);
+
+		qsel =3D (uint)(pattrib->qsel&0x0000001f);
+		ptxdesc->txdw1 |=3D cpu_to_le32((qsel<<QSEL_SHT)&0x00001f00);
+
+		ptxdesc->txdw1 |=3D cpu_to_le32((pattrib->raid<<16) & 0x000f0000);
+
+		/* offset 8 */
+		/* CCX-TXRPT ack for xmit mgmt frames. */
+		if (pxmitframe->ack_report)
+			ptxdesc->txdw2 |=3D cpu_to_le32(BIT(19));
+
+		/* offset 12 */
+		ptxdesc->txdw3 |=3D cpu_to_le32((pattrib->seqnum<<16)&0xffff0000);
+
+		/* offset 16 */
+		ptxdesc->txdw4 |=3D cpu_to_le32(BIT(8));/* driver uses rate */
+
+		/* offset 20 */
+		ptxdesc->txdw5 |=3D cpu_to_le32(BIT(17));/* retry limit enable */
+		ptxdesc->txdw5 |=3D cpu_to_le32(0x00180000);/* retry limit =3D 6 */
+
+		ptxdesc->txdw5 |=3D cpu_to_le32(MRateToHwRate23a(pmlmeext->tx_rate))=
;
+	} else if ((pxmitframe->frame_tag&0x0f) =3D=3D TXAGG_FRAMETAG) {
+		DBG_8723A("pxmitframe->frame_tag =3D=3D TXAGG_FRAMETAG\n");
+	} else {
+		DBG_8723A("pxmitframe->frame_tag =3D %d\n", pxmitframe->frame_tag);
+
+		/* offset 4 */
+		ptxdesc->txdw1 |=3D cpu_to_le32((4)&0x1f);/* CAM_ID(MAC_ID) */
+
+		ptxdesc->txdw1 |=3D cpu_to_le32((6<<16) & 0x000f0000);/* raid */
+
+		/* offset 8 */
+
+		/* offset 12 */
+		ptxdesc->txdw3 |=3D cpu_to_le32((pattrib->seqnum<<16)&0xffff0000);
+
+		/* offset 16 */
+		ptxdesc->txdw4 |=3D cpu_to_le32(BIT(8));/* driver uses rate */
+
+		/* offset 20 */
+		ptxdesc->txdw5 |=3D cpu_to_le32(MRateToHwRate23a(pmlmeext->tx_rate))=
;
+	}
+
+	/*  (1) The sequence number of each non-Qos frame / broadcast / multi=
cast / */
+	/*  mgnt frame should be controled by Hw because Fw will also send nu=
ll data */
+	/*  which we cannot control when Fw LPS enable. */
+	/*  --> default enable non-Qos data sequense number. 2010.06.23. by t=
ynli. */
+	/*  (2) Enable HW SEQ control for beacon packet, because we use Hw be=
acon. */
+	/*  (3) Use HW Qos SEQ to control the seq num of Ext port non-Qos pac=
kets. */
+	if (!pattrib->qos_en) {
+		/*  Hw set sequence number */
+		ptxdesc->txdw4 |=3D cpu_to_le32(BIT(7));
+		/* set bit3 to 1. */
+		ptxdesc->txdw3 |=3D cpu_to_le32((8 << 28));
+	}
+
+	/* offset 0 */
+	ptxdesc->txdw0 |=3D cpu_to_le32(sz&0x0000ffff);
+	ptxdesc->txdw0 |=3D cpu_to_le32(OWN | FSG | LSG);
+	ptxdesc->txdw0 |=3D cpu_to_le32(((TXDESC_SIZE+OFFSET_SZ)<<OFFSET_SHT)=
&0x00ff0000);/* 32 bytes for TX Desc */
+
+	if (bmcst)
+		ptxdesc->txdw0 |=3D cpu_to_le32(BIT(24));
+
+	RT_TRACE(_module_rtl871x_xmit_c_, _drv_info_, ("offset0-txdesc =3D 0x=
%x\n", ptxdesc->txdw0));
+
+	/* offset 4 */
+	/*  pkt_offset, unit:8 bytes padding */
+	if (pxmitframe->pkt_offset > 0)
+		ptxdesc->txdw1 |=3D cpu_to_le32((pxmitframe->pkt_offset << 26) & 0x7=
c000000);
+
+	rtl8192cu_cal_txdesc_chksum(ptxdesc);
+	return pull;
+}
+
+static s32 rtw_dump_xframe(struct rtw_adapter *padapter, struct xmit_f=
rame *pxmitframe)
+{
+	s32 ret =3D _SUCCESS;
+	s32 inner_ret =3D _SUCCESS;
+	int t, sz, w_sz, pull =3D 0;
+	u8 *mem_addr;
+	u32 ff_hwaddr;
+	struct xmit_buf *pxmitbuf =3D pxmitframe->pxmitbuf;
+	struct pkt_attrib *pattrib =3D &pxmitframe->attrib;
+	struct xmit_priv *pxmitpriv =3D &padapter->xmitpriv;
+
+	if ((pxmitframe->frame_tag =3D=3D DATA_FRAMETAG) &&
+	    (pxmitframe->attrib.ether_type !=3D 0x0806) &&
+	    (pxmitframe->attrib.ether_type !=3D 0x888e) &&
+	    (pxmitframe->attrib.dhcp_pkt !=3D 1))
+		rtw_issue_addbareq_cmd23a(padapter, pxmitframe);
+
+	mem_addr =3D pxmitframe->buf_addr;
+
+	RT_TRACE(_module_rtl871x_xmit_c_, _drv_info_, ("rtw_dump_xframe()\n")=
);
+
+	for (t =3D 0; t < pattrib->nr_frags; t++) {
+		if (inner_ret !=3D _SUCCESS && ret =3D=3D _SUCCESS)
+			ret =3D _FAIL;
+
+		if (t !=3D (pattrib->nr_frags - 1)) {
+			RT_TRACE(_module_rtl871x_xmit_c_, _drv_err_,
+				 ("pattrib->nr_frags =3D%d\n", pattrib->nr_frags));
+
+			sz =3D pxmitpriv->frag_len;
+			sz =3D sz - 4 - pattrib->icv_len;
+		} else {
+			/* no frag */
+			sz =3D pattrib->last_txcmdsz;
+		}
+
+		pull =3D update_txdesc(pxmitframe, mem_addr, sz, false);
+
+		if (pull) {
+			mem_addr +=3D PACKET_OFFSET_SZ; /* pull txdesc head */
+
+			pxmitframe->buf_addr =3D mem_addr;
+
+			w_sz =3D sz + TXDESC_SIZE;
+		} else {
+			w_sz =3D sz + TXDESC_SIZE + PACKET_OFFSET_SZ;
+		}
+
+		ff_hwaddr =3D rtw_get_ff_hwaddr23a(pxmitframe);
+		inner_ret =3D rtw_write_port(padapter, ff_hwaddr, w_sz, pxmitbuf);
+		rtw_count_tx_stats23a(padapter, pxmitframe, sz);
+
+		RT_TRACE(_module_rtl871x_xmit_c_, _drv_info_,
+			 ("rtw_write_port, w_sz =3D%d\n", w_sz));
+
+		mem_addr +=3D w_sz;
+
+		mem_addr =3D (u8 *)RND4(((unsigned long)(mem_addr)));
+	}
+
+	rtw_free_xmitframe23a(pxmitpriv, pxmitframe);
+
+	if  (ret !=3D _SUCCESS)
+		rtw23a_sctx_done_err(&pxmitbuf->sctx, RTW_SCTX_DONE_UNKNOWN);
+
+	return ret;
+}
+
+s32 rtl8723au_xmitframe_complete(struct rtw_adapter *padapter,
+				 struct xmit_priv *pxmitpriv, struct xmit_buf *pxmitbuf)
+{
+	struct hw_xmit *phwxmits;
+	struct xmit_frame *pxmitframe;
+	int hwentry;
+	int res =3D _SUCCESS, xcnt =3D 0;
+
+	phwxmits =3D pxmitpriv->hwxmits;
+	hwentry =3D pxmitpriv->hwxmit_entry;
+
+	RT_TRACE(_module_rtl871x_xmit_c_, _drv_info_, ("xmitframe_complete()\=
n"));
+
+	if (pxmitbuf =3D=3D NULL) {
+		pxmitbuf =3D rtw_alloc_xmitbuf23a(pxmitpriv);
+		if (!pxmitbuf)
+			return false;
+	}
+	pxmitframe =3D  rtw_dequeue_xframe23a(pxmitpriv, phwxmits, hwentry);
+
+	if (pxmitframe) {
+		pxmitframe->pxmitbuf =3D pxmitbuf;
+
+		pxmitframe->buf_addr =3D pxmitbuf->pbuf;
+
+		pxmitbuf->priv_data =3D pxmitframe;
+
+		if ((pxmitframe->frame_tag&0x0f) =3D=3D DATA_FRAMETAG) {
+			if (pxmitframe->attrib.priority <=3D 15)/* TID0~15 */
+				res =3D rtw_xmitframe_coalesce23a(padapter, pxmitframe->pkt, pxmit=
frame);
+
+			rtw_os_xmit_complete23a(padapter, pxmitframe);/* always return ndis=
_packet after rtw_xmitframe_coalesce23a */
+		}
+
+		RT_TRACE(_module_rtl871x_xmit_c_, _drv_info_, ("xmitframe_complete()=
: rtw_dump_xframe\n"));
+
+		if (res =3D=3D _SUCCESS) {
+			rtw_dump_xframe(padapter, pxmitframe);
+		} else {
+			rtw_free_xmitbuf23a(pxmitpriv, pxmitbuf);
+			rtw_free_xmitframe23a(pxmitpriv, pxmitframe);
+		}
+		xcnt++;
+	} else {
+		rtw_free_xmitbuf23a(pxmitpriv, pxmitbuf);
+		return false;
+	}
+	return true;
+}
+
+static s32 xmitframe_direct(struct rtw_adapter *padapter, struct xmit_=
frame *pxmitframe)
+{
+	s32 res =3D _SUCCESS;
+
+	res =3D rtw_xmitframe_coalesce23a(padapter, pxmitframe->pkt, pxmitfra=
me);
+	if (res =3D=3D _SUCCESS)
+		rtw_dump_xframe(padapter, pxmitframe);
+	return res;
+}
+
+/*
+ * Return
+ *	true	dump packet directly
+ *	false	enqueue packet
+ */
+static s32 pre_xmitframe(struct rtw_adapter *padapter, struct xmit_fra=
me *pxmitframe)
+{
+	s32 res;
+	struct xmit_buf *pxmitbuf =3D NULL;
+	struct xmit_priv *pxmitpriv =3D &padapter->xmitpriv;
+	struct pkt_attrib *pattrib =3D &pxmitframe->attrib;
+	struct mlme_priv *pmlmepriv =3D &padapter->mlmepriv;
+
+	do_queue_select(padapter, pattrib);
+	spin_lock_bh(&pxmitpriv->lock);
+
+#ifdef CONFIG_8723AU_AP_MODE
+	if (xmitframe_enqueue_for_sleeping_sta23a(padapter, pxmitframe)) {
+		struct sta_info *psta;
+		struct sta_priv *pstapriv =3D &padapter->stapriv;
+
+		spin_unlock_bh(&pxmitpriv->lock);
+
+		if (pattrib->psta)
+			psta =3D pattrib->psta;
+		else
+			psta =3D rtw_get_stainfo23a(pstapriv, pattrib->ra);
+
+		if (psta) {
+			if (psta->sleepq_len > (NR_XMITFRAME>>3))
+				wakeup_sta_to_xmit23a(padapter, psta);
+		}
+
+		return false;
+	}
+#endif
+
+	if (rtw_txframes_sta_ac_pending23a(padapter, pattrib) > 0)
+		goto enqueue;
+
+	if (check_fwstate(pmlmepriv, _FW_UNDER_SURVEY|_FW_UNDER_LINKING) =3D=3D=
 true)
+		goto enqueue;
+
+	pxmitbuf =3D rtw_alloc_xmitbuf23a(pxmitpriv);
+	if (pxmitbuf =3D=3D NULL)
+		goto enqueue;
+
+	spin_unlock_bh(&pxmitpriv->lock);
+
+	pxmitframe->pxmitbuf =3D pxmitbuf;
+	pxmitframe->buf_addr =3D pxmitbuf->pbuf;
+	pxmitbuf->priv_data =3D pxmitframe;
+
+	if (xmitframe_direct(padapter, pxmitframe) !=3D _SUCCESS) {
+		rtw_free_xmitbuf23a(pxmitpriv, pxmitbuf);
+		rtw_free_xmitframe23a(pxmitpriv, pxmitframe);
+	}
+	return true;
+
+enqueue:
+	res =3D rtw_xmitframe_enqueue23a(padapter, pxmitframe);
+	spin_unlock_bh(&pxmitpriv->lock);
+
+	if (res !=3D _SUCCESS) {
+		RT_TRACE(_module_xmit_osdep_c_, _drv_err_,
+			 ("pre_xmitframe: enqueue xmitframe fail\n"));
+		rtw_free_xmitframe23a(pxmitpriv, pxmitframe);
+
+		/*  Trick, make the statistics correct */
+		pxmitpriv->tx_pkts--;
+		pxmitpriv->tx_drop++;
+		return true;
+	}
+	return false;
+}
+
+s32 rtl8723au_mgnt_xmit(struct rtw_adapter *padapter, struct xmit_fram=
e *pmgntframe)
+{
+	return rtw_dump_xframe(padapter, pmgntframe);
+}
+
+/*
+ * Return
+ *	true	dump packet directly ok
+ *	false	temporary can't transmit packets to hardware
+ */
+s32 rtl8723au_hal_xmit(struct rtw_adapter *padapter, struct xmit_frame=
 *pxmitframe)
+{
+	return pre_xmitframe(padapter, pxmitframe);
+}
+
+s32	rtl8723au_hal_xmitframe_enqueue(struct rtw_adapter *padapter,
+					struct xmit_frame *pxmitframe)
+{
+	struct xmit_priv *pxmitpriv =3D &padapter->xmitpriv;
+	s32 err;
+
+	err =3D rtw_xmitframe_enqueue23a(padapter, pxmitframe);
+	if (err !=3D _SUCCESS) {
+		rtw_free_xmitframe23a(pxmitpriv, pxmitframe);
+
+		/*  Trick, make the statistics correct */
+		pxmitpriv->tx_pkts--;
+		pxmitpriv->tx_drop++;
+	} else {
+		tasklet_hi_schedule(&pxmitpriv->xmit_tasklet);
+	}
+	return err;
+}
diff --git a/drivers/staging/rtl8723au/hal/usb_halinit.c b/drivers/stag=
ing/rtl8723au/hal/usb_halinit.c
new file mode 100644
index 0000000..e206829
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/usb_halinit.c
@@ -0,0 +1,1834 @@
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
+#define _HCI_HAL_INIT_C_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <rtw_efuse.h>
+
+#include <HalPwrSeqCmd.h>
+#include <Hal8723PwrSeq.h>
+#include <rtl8723a_hal.h>
+#include <rtl8723a_led.h>
+#include <linux/ieee80211.h>
+
+#include <usb_ops.h>
+#include <usb_hal.h>
+#include <usb_osintf.h>
+
+static void
+_ConfigChipOutEP(struct rtw_adapter *pAdapter, u8 NumOutPipe)
+{
+	u8 value8;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(pAdapter);
+
+	pHalData->OutEpQueueSel =3D 0;
+	pHalData->OutEpNumber =3D 0;
+
+	/*  Normal and High queue */
+	value8 =3D rtw_read8(pAdapter, (REG_NORMAL_SIE_EP + 1));
+
+	if (value8 & USB_NORMAL_SIE_EP_MASK) {
+		pHalData->OutEpQueueSel |=3D TX_SELE_HQ;
+		pHalData->OutEpNumber++;
+	}
+
+	if ((value8 >> USB_NORMAL_SIE_EP_SHIFT) & USB_NORMAL_SIE_EP_MASK) {
+		pHalData->OutEpQueueSel |=3D TX_SELE_NQ;
+		pHalData->OutEpNumber++;
+	}
+
+	/*  Low queue */
+	value8 =3D rtw_read8(pAdapter, (REG_NORMAL_SIE_EP + 2));
+	if (value8 & USB_NORMAL_SIE_EP_MASK) {
+		pHalData->OutEpQueueSel |=3D TX_SELE_LQ;
+		pHalData->OutEpNumber++;
+	}
+
+	/*  TODO: Error recovery for this case */
+	/* RT_ASSERT((NumOutPipe =3D=3D pHalData->OutEpNumber),
+	   ("Out EP number isn't match! %d(Descriptor) !=3D %d (SIE reg)\n",
+	   (u32)NumOutPipe, (u32)pHalData->OutEpNumber)); */
+}
+
+static bool rtl8723au_set_queue_pipe_mapping(struct rtw_adapter *pAdap=
ter,
+					     u8 NumInPipe, u8 NumOutPipe)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(pAdapter);
+	bool result =3D false;
+
+	_ConfigChipOutEP(pAdapter, NumOutPipe);
+
+	/*  Normal chip with one IN and one OUT doesn't have interrupt IN EP.=
 */
+	if (pHalData->OutEpNumber =3D=3D 1) {
+		if (NumInPipe !=3D 1)
+			return result;
+	}
+
+	result =3D Hal_MappingOutPipe23a(pAdapter, NumOutPipe);
+
+	return result;
+}
+
+static void rtl8723au_interface_configure(struct rtw_adapter *padapter=
)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(padapter);
+	struct dvobj_priv *pdvobjpriv =3D adapter_to_dvobj(padapter);
+
+	if (pdvobjpriv->ishighspeed =3D=3D true) {
+		/* 512 bytes */
+		pHalData->UsbBulkOutSize =3D USB_HIGH_SPEED_BULK_SIZE;
+	} else {
+		/* 64 bytes */
+		pHalData->UsbBulkOutSize =3D USB_FULL_SPEED_BULK_SIZE;
+	}
+
+	pHalData->interfaceIndex =3D pdvobjpriv->InterfaceNumber;
+
+	rtl8723au_set_queue_pipe_mapping(padapter,
+					 pdvobjpriv->RtNumInPipes,
+					 pdvobjpriv->RtNumOutPipes);
+}
+
+static u8 _InitPowerOn(struct rtw_adapter *padapter)
+{
+	u8 status =3D _SUCCESS;
+	u16 value16 =3D 0;
+	u8 value8 =3D 0;
+
+	/*  RSV_CTRL 0x1C[7:0] =3D 0x00
+	    unlock ISO/CLK/Power control register */
+	rtw_write8(padapter, REG_RSV_CTRL, 0x0);
+
+	/*  HW Power on sequence */
+	if (!HalPwrSeqCmdParsing23a(padapter, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MS=
K,
+				 PWR_INTF_USB_MSK, rtl8723AU_card_enable_flow))
+		return _FAIL;
+
+	/*  0x04[19] =3D 1, suggest by Jackie 2011.05.09, reset 8051 */
+	value8 =3D rtw_read8(padapter, REG_APS_FSMCO+2);
+	rtw_write8(padapter, REG_APS_FSMCO + 2, (value8 | BIT3));
+
+	/*  Enable MAC DMA/WMAC/SCHEDULE/SEC block */
+	/*  Set CR bit10 to enable 32k calibration. Suggested by SD1 Gimmy.
+	    Added by tynli. 2011.08.31. */
+	value16 =3D rtw_read16(padapter, REG_CR);
+	value16 |=3D (HCI_TXDMA_EN | HCI_RXDMA_EN | TXDMA_EN | RXDMA_EN |
+		    PROTOCOL_EN | SCHEDULE_EN | MACTXEN | MACRXEN |
+		    ENSEC | CALTMR_EN);
+	rtw_write16(padapter, REG_CR, value16);
+
+	/* for Efuse PG, suggest by Jackie 2011.11.23 */
+	PHY_SetBBReg(padapter, REG_EFUSE_CTRL, BIT28|BIT29|BIT30, 0x06);
+
+	return status;
+}
+
+/*  Shall USB interface init this? */
+static void _InitInterrupt(struct rtw_adapter *Adapter)
+{
+	u32 value32;
+
+	/*  HISR - turn all on */
+	value32 =3D 0xFFFFFFFF;
+	rtw_write32(Adapter, REG_HISR, value32);
+
+	/*  HIMR - turn all on */
+	rtw_write32(Adapter, REG_HIMR, value32);
+}
+
+static void _InitQueueReservedPage(struct rtw_adapter *Adapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct registry_priv *pregistrypriv =3D &Adapter->registrypriv;
+	u32 numHQ =3D 0;
+	u32 numLQ =3D 0;
+	u32 numNQ =3D 0;
+	u32 numPubQ;
+	u32 value32;
+	u8 value8;
+	bool bWiFiConfig =3D pregistrypriv->wifi_spec;
+	/* u32			txQPageNum, txQPageUnit, txQRemainPage; */
+
+	{ /* for WMM */
+		/* RT_ASSERT((outEPNum>=3D 2), ("for WMM , number of out-ep "
+		   "must more than or equal to 2!\n")); */
+
+		numPubQ =3D bWiFiConfig ?
+			WMM_NORMAL_PAGE_NUM_PUBQ : NORMAL_PAGE_NUM_PUBQ;
+
+		if (pHalData->OutEpQueueSel & TX_SELE_HQ) {
+			numHQ =3D bWiFiConfig ?
+				WMM_NORMAL_PAGE_NUM_HPQ : NORMAL_PAGE_NUM_HPQ;
+		}
+
+		if (pHalData->OutEpQueueSel & TX_SELE_LQ) {
+			numLQ =3D bWiFiConfig ?
+				WMM_NORMAL_PAGE_NUM_LPQ : NORMAL_PAGE_NUM_LPQ;
+		}
+		/*  NOTE: This step shall be proceed before
+		    writting REG_RQPN. */
+		if (pHalData->OutEpQueueSel & TX_SELE_NQ) {
+			numNQ =3D bWiFiConfig ?
+				WMM_NORMAL_PAGE_NUM_NPQ : NORMAL_PAGE_NUM_NPQ;
+		}
+		value8 =3D (u8)_NPQ(numNQ);
+		rtw_write8(Adapter, REG_RQPN_NPQ, value8);
+	}
+
+	/*  TX DMA */
+	value32 =3D _HPQ(numHQ) | _LPQ(numLQ) | _PUBQ(numPubQ) | LD_RQPN;
+	rtw_write32(Adapter, REG_RQPN, value32);
+}
+
+static void _InitTxBufferBoundary(struct rtw_adapter *Adapter)
+{
+	struct registry_priv *pregistrypriv =3D &Adapter->registrypriv;
+
+	u8 txpktbuf_bndy;
+
+	if (!pregistrypriv->wifi_spec)
+		txpktbuf_bndy =3D TX_PAGE_BOUNDARY;
+	else /* for WMM */
+		txpktbuf_bndy =3D WMM_NORMAL_TX_PAGE_BOUNDARY;
+
+	rtw_write8(Adapter, REG_TXPKTBUF_BCNQ_BDNY, txpktbuf_bndy);
+	rtw_write8(Adapter, REG_TXPKTBUF_MGQ_BDNY, txpktbuf_bndy);
+	rtw_write8(Adapter, REG_TXPKTBUF_WMAC_LBK_BF_HD, txpktbuf_bndy);
+	rtw_write8(Adapter, REG_TRXFF_BNDY, txpktbuf_bndy);
+	rtw_write8(Adapter, REG_TDECTRL+1, txpktbuf_bndy);
+}
+
+static void _InitPageBoundary(struct rtw_adapter *Adapter)
+{
+	/*  RX Page Boundary */
+	/* srand(static_cast<unsigned int>(time(NULL))); */
+	u16 rxff_bndy =3D 0x27FF;/* rand() % 1) ? 0x27FF : 0x23FF; */
+
+	rtw_write16(Adapter, (REG_TRXFF_BNDY + 2), rxff_bndy);
+
+	/*  TODO: ?? shall we set tx boundary? */
+}
+
+static void
+_InitNormalChipRegPriority(struct rtw_adapter *Adapter, u16 beQ, u16 b=
kQ,
+			   u16 viQ, u16 voQ, u16 mgtQ, u16 hiQ)
+{
+	u16 value16 =3D rtw_read16(Adapter, REG_TRXDMA_CTRL) & 0x7;
+
+	value16 |=3D _TXDMA_BEQ_MAP(beQ) | _TXDMA_BKQ_MAP(bkQ) |
+		_TXDMA_VIQ_MAP(viQ) | _TXDMA_VOQ_MAP(voQ) |
+		_TXDMA_MGQ_MAP(mgtQ) | _TXDMA_HIQ_MAP(hiQ);
+
+	rtw_write16(Adapter, REG_TRXDMA_CTRL, value16);
+}
+
+static void _InitNormalChipOneOutEpPriority(struct rtw_adapter *Adapte=
r)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	u16 value =3D 0;
+
+	switch (pHalData->OutEpQueueSel) {
+	case TX_SELE_HQ:
+		value =3D QUEUE_HIGH;
+		break;
+	case TX_SELE_LQ:
+		value =3D QUEUE_LOW;
+		break;
+	case TX_SELE_NQ:
+		value =3D QUEUE_NORMAL;
+		break;
+	default:
+		/* RT_ASSERT(false, ("Shall not reach here!\n")); */
+		break;
+	}
+
+	_InitNormalChipRegPriority(Adapter, value, value, value,
+				   value, value, value);
+}
+
+static void _InitNormalChipTwoOutEpPriority(struct rtw_adapter *Adapte=
r)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct registry_priv *pregistrypriv =3D &Adapter->registrypriv;
+	u16 beQ, bkQ, viQ, voQ, mgtQ, hiQ;
+	u16 valueHi =3D 0;
+	u16 valueLow =3D 0;
+
+	switch (pHalData->OutEpQueueSel) {
+	case (TX_SELE_HQ | TX_SELE_LQ):
+		valueHi =3D QUEUE_HIGH;
+		valueLow =3D QUEUE_LOW;
+		break;
+	case (TX_SELE_NQ | TX_SELE_LQ):
+		valueHi =3D QUEUE_NORMAL;
+		valueLow =3D QUEUE_LOW;
+		break;
+	case (TX_SELE_HQ | TX_SELE_NQ):
+		valueHi =3D QUEUE_HIGH;
+		valueLow =3D QUEUE_NORMAL;
+		break;
+	default:
+		/* RT_ASSERT(false, ("Shall not reach here!\n")); */
+		break;
+	}
+
+	if (!pregistrypriv->wifi_spec) {
+		beQ =3D valueLow;
+		bkQ =3D valueLow;
+		viQ =3D valueHi;
+		voQ =3D valueHi;
+		mgtQ =3D valueHi;
+		hiQ =3D valueHi;
+	} else {/* for WMM , CONFIG_OUT_EP_WIFI_MODE */
+		beQ =3D valueLow;
+		bkQ =3D valueHi;
+		viQ =3D valueHi;
+		voQ =3D valueLow;
+		mgtQ =3D valueHi;
+		hiQ =3D valueHi;
+	}
+
+	_InitNormalChipRegPriority(Adapter, beQ, bkQ, viQ, voQ, mgtQ, hiQ);
+}
+
+static void _InitNormalChipThreeOutEpPriority(struct rtw_adapter *Adap=
ter)
+{
+	struct registry_priv *pregistrypriv =3D &Adapter->registrypriv;
+	u16 beQ, bkQ, viQ, voQ, mgtQ, hiQ;
+
+	if (!pregistrypriv->wifi_spec) {/*  typical setting */
+		beQ =3D QUEUE_LOW;
+		bkQ =3D QUEUE_LOW;
+		viQ =3D QUEUE_NORMAL;
+		voQ =3D QUEUE_HIGH;
+		mgtQ =3D QUEUE_HIGH;
+		hiQ =3D QUEUE_HIGH;
+	} else {/*  for WMM */
+		beQ =3D QUEUE_LOW;
+		bkQ =3D QUEUE_NORMAL;
+		viQ =3D QUEUE_NORMAL;
+		voQ =3D QUEUE_HIGH;
+		mgtQ =3D QUEUE_HIGH;
+		hiQ =3D QUEUE_HIGH;
+	}
+	_InitNormalChipRegPriority(Adapter, beQ, bkQ, viQ, voQ, mgtQ, hiQ);
+}
+
+static void _InitNormalChipQueuePriority(struct rtw_adapter *Adapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+
+	switch (pHalData->OutEpNumber) {
+	case 1:
+		_InitNormalChipOneOutEpPriority(Adapter);
+		break;
+	case 2:
+		_InitNormalChipTwoOutEpPriority(Adapter);
+		break;
+	case 3:
+		_InitNormalChipThreeOutEpPriority(Adapter);
+		break;
+	default:
+		/* RT_ASSERT(false, ("Shall not reach here!\n")); */
+		break;
+	}
+}
+
+static void _InitQueuePriority(struct rtw_adapter *Adapter)
+{
+	_InitNormalChipQueuePriority(Adapter);
+}
+
+static void _InitNetworkType(struct rtw_adapter *Adapter)
+{
+	u32 value32;
+
+	value32 =3D rtw_read32(Adapter, REG_CR);
+
+	/*  TODO: use the other function to set network type */
+	value32 =3D (value32 & ~MASK_NETTYPE) | _NETTYPE(NT_LINK_AP);
+	rtw_write32(Adapter, REG_CR, value32);
+}
+
+static void _InitTransferPageSize(struct rtw_adapter *Adapter)
+{
+	/*  Tx page size is always 128. */
+
+	u8 value8;
+	value8 =3D _PSRX(PBP_128) | _PSTX(PBP_128);
+	rtw_write8(Adapter, REG_PBP, value8);
+}
+
+static void _InitDriverInfoSize(struct rtw_adapter *Adapter, u8 drvInf=
oSize)
+{
+	rtw_write8(Adapter, REG_RX_DRVINFO_SZ, drvInfoSize);
+}
+
+static void _InitWMACSetting(struct rtw_adapter *Adapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+
+	/*  don't turn on AAP, it will allow all packets to driver */
+	pHalData->ReceiveConfig =3D RCR_APM | RCR_AM | RCR_AB | RCR_CBSSID_DA=
TA |
+				  RCR_CBSSID_BCN | RCR_APP_ICV | RCR_AMF |
+				  RCR_HTC_LOC_CTRL | RCR_APP_MIC |
+				  RCR_APP_PHYSTS;
+
+	/*  some REG_RCR will be modified later by
+	    phy_ConfigMACWithHeaderFile() */
+	rtw_write32(Adapter, REG_RCR, pHalData->ReceiveConfig);
+
+	/*  Accept all multicast address */
+	rtw_write32(Adapter, REG_MAR, 0xFFFFFFFF);
+	rtw_write32(Adapter, REG_MAR + 4, 0xFFFFFFFF);
+
+	/*  Accept all data frames */
+	/* value16 =3D 0xFFFF; */
+	/* rtw_write16(Adapter, REG_RXFLTMAP2, value16); */
+
+	/*  2010.09.08 hpfan */
+	/*  Since ADF is removed from RCR, ps-poll will not be indicate
+	    to driver, */
+	/*  RxFilterMap should mask ps-poll to gurantee AP mode can
+	    rx ps-poll. */
+	/* value16 =3D 0x400; */
+	/* rtw_write16(Adapter, REG_RXFLTMAP1, value16); */
+
+	/*  Accept all management frames */
+	/* value16 =3D 0xFFFF; */
+	/* rtw_write16(Adapter, REG_RXFLTMAP0, value16); */
+
+	/* enable RX_SHIFT bits */
+	/* rtw_write8(Adapter, REG_TRXDMA_CTRL, rtw_read8(Adapter,
+	   REG_TRXDMA_CTRL)|BIT(1)); */
+}
+
+static void _InitAdaptiveCtrl(struct rtw_adapter *Adapter)
+{
+	u16 value16;
+	u32 value32;
+
+	/*  Response Rate Set */
+	value32 =3D rtw_read32(Adapter, REG_RRSR);
+	value32 &=3D ~RATE_BITMAP_ALL;
+	value32 |=3D RATE_RRSR_CCK_ONLY_1M;
+	rtw_write32(Adapter, REG_RRSR, value32);
+
+	/*  CF-END Threshold */
+	/* m_spIoBase->rtw_write8(REG_CFEND_TH, 0x1); */
+
+	/*  SIFS (used in NAV) */
+	value16 =3D _SPEC_SIFS_CCK(0x10) | _SPEC_SIFS_OFDM(0x10);
+	rtw_write16(Adapter, REG_SPEC_SIFS, value16);
+
+	/*  Retry Limit */
+	value16 =3D _LRL(0x30) | _SRL(0x30);
+	rtw_write16(Adapter, REG_RL, value16);
+}
+
+static void _InitRateFallback(struct rtw_adapter *Adapter)
+{
+	/*  Set Data Auto Rate Fallback Retry Count register. */
+	rtw_write32(Adapter, REG_DARFRC, 0x00000000);
+	rtw_write32(Adapter, REG_DARFRC+4, 0x10080404);
+	rtw_write32(Adapter, REG_RARFRC, 0x04030201);
+	rtw_write32(Adapter, REG_RARFRC+4, 0x08070605);
+}
+
+static void _InitEDCA(struct rtw_adapter *Adapter)
+{
+	/*  Set Spec SIFS (used in NAV) */
+	rtw_write16(Adapter, REG_SPEC_SIFS, 0x100a);
+	rtw_write16(Adapter, REG_MAC_SPEC_SIFS, 0x100a);
+
+	/*  Set SIFS for CCK */
+	rtw_write16(Adapter, REG_SIFS_CTX, 0x100a);
+
+	/*  Set SIFS for OFDM */
+	rtw_write16(Adapter, REG_SIFS_TRX, 0x100a);
+
+	/*  TXOP */
+	rtw_write32(Adapter, REG_EDCA_BE_PARAM, 0x005EA42B);
+	rtw_write32(Adapter, REG_EDCA_BK_PARAM, 0x0000A44F);
+	rtw_write32(Adapter, REG_EDCA_VI_PARAM, 0x005EA324);
+	rtw_write32(Adapter, REG_EDCA_VO_PARAM, 0x002FA226);
+}
+
+static void _InitHWLed(struct rtw_adapter *Adapter)
+{
+	struct led_priv *pledpriv =3D &Adapter->ledpriv;
+
+	if (pledpriv->LedStrategy !=3D HW_LED)
+		return;
+
+/*  HW led control */
+/*  to do .... */
+/* must consider cases of antenna diversity/ commbo card/solo card/min=
i card */
+}
+
+static void _InitRDGSetting(struct rtw_adapter *Adapter)
+{
+	rtw_write8(Adapter, REG_RD_CTRL, 0xFF);
+	rtw_write16(Adapter, REG_RD_NAV_NXT, 0x200);
+	rtw_write8(Adapter, REG_RD_RESP_PKT_TH, 0x05);
+}
+
+static void _InitRetryFunction(struct rtw_adapter *Adapter)
+{
+	u8 value8;
+
+	value8 =3D rtw_read8(Adapter, REG_FWHW_TXQ_CTRL);
+	value8 |=3D EN_AMPDU_RTY_NEW;
+	rtw_write8(Adapter, REG_FWHW_TXQ_CTRL, value8);
+
+	/*  Set ACK timeout */
+	rtw_write8(Adapter, REG_ACKTO, 0x40);
+}
+
+/*--------------------------------------------------------------------=
---------
+ * Function:	usb_AggSettingTxUpdate()
+ *
+ * Overview:	Seperate TX/RX parameters update independent for TP
+ *		detection and dynamic TX/RX aggreagtion parameters update.
+ *
+ * Input:			struct rtw_adapter *
+ *
+ * Output/Return:	NONE
+ *
+ * Revised History:
+ *	When		Who		Remark
+ *	12/10/2010	MHC		Seperate to smaller function.
+ *
+ *--------------------------------------------------------------------=
-------*/
+static void usb_AggSettingTxUpdate(struct rtw_adapter *Adapter)
+{
+}	/*  usb_AggSettingTxUpdate */
+
+/*--------------------------------------------------------------------=
---------
+ * Function:	usb_AggSettingRxUpdate()
+ *
+ * Overview:	Seperate TX/RX parameters update independent for TP
+ *		detection and dynamic TX/RX aggreagtion parameters update.
+ *
+ * Input:			struct rtw_adapter *
+ *
+ * Output/Return:	NONE
+ *
+ * Revised History:
+ *	When		Who		Remark
+ *	12/10/2010	MHC		Seperate to smaller function.
+ *
+ *--------------------------------------------------------------------=
-------*/
+static void usb_AggSettingRxUpdate(struct rtw_adapter *Adapter)
+{
+}	/*  usb_AggSettingRxUpdate */
+
+static void InitUsbAggregationSetting(struct rtw_adapter *Adapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+
+	/*  Tx aggregation setting */
+	usb_AggSettingTxUpdate(Adapter);
+
+	/*  Rx aggregation setting */
+	usb_AggSettingRxUpdate(Adapter);
+
+	/*  201/12/10 MH Add for USB agg mode dynamic switch. */
+	pHalData->UsbRxHighSpeedMode =3D false;
+}
+
+static void _InitOperationMode(struct rtw_adapter *Adapter)
+{
+}
+
+static void _InitRFType(struct rtw_adapter *Adapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	bool is92CU =3D IS_92C_SERIAL(pHalData->VersionID);
+
+	pHalData->rf_chip =3D RF_6052;
+
+	if (is92CU =3D=3D false) {
+		pHalData->rf_type =3D RF_1T1R;
+		DBG_8723A("Set RF Chip ID to RF_6052 and RF type to 1T1R.\n");
+		return;
+	}
+
+	/*  TODO: Consider that EEPROM set 92CU to 1T1R later. */
+	/*  Force to overwrite setting according to chip version. Ignore
+	    EEPROM setting. */
+	/* pHalData->RF_Type =3D is92CU ? RF_2T2R : RF_1T1R; */
+	MSG_8723A("Set RF Chip ID to RF_6052 and RF type to %d.\n",
+		  pHalData->rf_type);
+}
+
+/*  Set CCK and OFDM Block "ON" */
+static void _BBTurnOnBlock(struct rtw_adapter *Adapter)
+{
+	PHY_SetBBReg(Adapter, rFPGA0_RFMOD, bCCKEn, 0x1);
+	PHY_SetBBReg(Adapter, rFPGA0_RFMOD, bOFDMEn, 0x1);
+}
+
+#define MgntActSet_RF_State(...)
+static void _RfPowerSave(struct rtw_adapter *padapter)
+{
+}
+
+enum {
+	Antenna_Lfet =3D 1,
+	Antenna_Right =3D 2,
+};
+
+enum rt_rf_power_state RfOnOffDetect23a(struct rtw_adapter *pAdapter)
+{
+	/* struct hal_data_8723a *pHalData =3D GET_HAL_DATA(pAdapter); */
+	u8 val8;
+	enum rt_rf_power_state rfpowerstate =3D rf_off;
+
+	if (pAdapter->pwrctrlpriv.bHWPowerdown) {
+		val8 =3D rtw_read8(pAdapter, REG_HSISR);
+		DBG_8723A("pwrdown, 0x5c(BIT7) =3D%02x\n", val8);
+		rfpowerstate =3D (val8 & BIT7) ? rf_off : rf_on;
+	} else { /*  rf on/off */
+		rtw_write8(pAdapter, REG_MAC_PINMUX_CFG,
+			   rtw_read8(pAdapter, REG_MAC_PINMUX_CFG) & ~BIT3);
+		val8 =3D rtw_read8(pAdapter, REG_GPIO_IO_SEL);
+		DBG_8723A("GPIO_IN =3D%02x\n", val8);
+		rfpowerstate =3D (val8 & BIT3) ? rf_on : rf_off;
+	}
+	return rfpowerstate;
+}	/*  HalDetectPwrDownMode */
+
+void _ps_open_RF23a(struct rtw_adapter *padapter);
+
+static u32 rtl8723au_hal_init(struct rtw_adapter *Adapter)
+{
+	u8	val8 =3D 0;
+	u32	boundary, status =3D _SUCCESS;
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	struct pwrctrl_priv *pwrctrlpriv =3D &Adapter->pwrctrlpriv;
+	struct registry_priv *pregistrypriv =3D &Adapter->registrypriv;
+	u32 NavUpper =3D WiFiNavUpperUs;
+
+	unsigned long init_start_time =3D jiffies;
+
+#define HAL_INIT_PROFILE_TAG(stage) do {} while (0)
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_BEGIN);
+	if (Adapter->pwrctrlpriv.bkeepfwalive) {
+		_ps_open_RF23a(Adapter);
+
+		if (pHalData->bIQKInitialized) {
+			rtl8723a_phy_iq_calibrate(Adapter, true);
+		} else {
+			rtl8723a_phy_iq_calibrate(Adapter, false);
+			pHalData->bIQKInitialized =3D true;
+		}
+		rtl8723a_odm_check_tx_power_tracking(Adapter);
+		rtl8723a_phy_lc_calibrate(Adapter);
+
+		goto exit;
+	}
+
+	/*  Check if MAC has already power on. by tynli. 2011.05.27. */
+	val8 =3D rtw_read8(Adapter, REG_CR);
+	RT_TRACE(_module_hci_hal_init_c_, _drv_info_,
+		 ("%s: REG_CR 0x100 =3D 0x%02x\n", __func__, val8));
+	/* Fix 92DU-VC S3 hang with the reason is that secondary mac is not
+	   initialized. */
+	/* 0x100 value of first mac is 0xEA while 0x100 value of secondary
+	   is 0x00 */
+	if (val8 =3D=3D 0xEA) {
+		pHalData->bMACFuncEnable =3D false;
+	} else {
+		pHalData->bMACFuncEnable =3D true;
+		RT_TRACE(_module_hci_hal_init_c_, _drv_info_,
+			 ("%s: MAC has already power on\n", __func__));
+	}
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_INIT_PW_ON);
+	status =3D _InitPowerOn(Adapter);
+	if (status =3D=3D _FAIL) {
+		RT_TRACE(_module_hci_hal_init_c_, _drv_err_,
+			 ("Failed to init power on!\n"));
+		goto exit;
+	}
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_INIT_LLTT);
+	if (!pregistrypriv->wifi_spec) {
+		boundary =3D TX_PAGE_BOUNDARY;
+	} else {
+		/*  for WMM */
+		boundary =3D WMM_NORMAL_TX_PAGE_BOUNDARY;
+	}
+
+	if (!pHalData->bMACFuncEnable) {
+		status =3D  InitLLTTable23a(Adapter, boundary);
+		if (status =3D=3D _FAIL) {
+			RT_TRACE(_module_hci_hal_init_c_, _drv_err_,
+				 ("Failed to init LLT table\n"));
+			goto exit;
+		}
+	}
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_MISC01);
+	if (pHalData->bRDGEnable)
+		_InitRDGSetting(Adapter);
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_DOWNLOAD_FW);
+	status =3D rtl8723a_FirmwareDownload(Adapter);
+	if (status !=3D _SUCCESS) {
+		Adapter->bFWReady =3D false;
+		pHalData->fw_ractrl =3D false;
+		DBG_8723A("fw download fail!\n");
+		goto exit;
+	} else {
+		Adapter->bFWReady =3D true;
+		pHalData->fw_ractrl =3D true;
+		DBG_8723A("fw download ok!\n");
+	}
+
+	rtl8723a_InitializeFirmwareVars(Adapter);
+
+	if (pwrctrlpriv->reg_rfoff =3D=3D true) {
+		pwrctrlpriv->rf_pwrstate =3D rf_off;
+	}
+
+	/*  2010/08/09 MH We need to check if we need to turnon or off RF aft=
er detecting */
+	/*  HW GPIO pin. Before PHY_RFConfig8192C. */
+	/* HalDetectPwrDownMode(Adapter); */
+	/*  2010/08/26 MH If Efuse does not support sective suspend then disa=
ble the function. */
+	/* HalDetectSelectiveSuspendMode(Adapter); */
+
+	/*  Set RF type for BB/RF configuration */
+	_InitRFType(Adapter);/* _ReadRFType() */
+
+	/*  Save target channel */
+	/*  <Roger_Notes> Current Channel will be updated again later. */
+	pHalData->CurrentChannel =3D 6;/* default set to 6 */
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_MAC);
+	status =3D PHY_MACConfig8723A(Adapter);
+	if (status =3D=3D _FAIL) {
+		DBG_8723A("PHY_MACConfig8723A fault !!\n");
+		goto exit;
+	}
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_BB);
+	/*  */
+	/* d. Initialize BB related configurations. */
+	/*  */
+	status =3D PHY_BBConfig8723A(Adapter);
+	if (status =3D=3D _FAIL) {
+		DBG_8723A("PHY_BBConfig8723A fault !!\n");
+		goto exit;
+	}
+
+	/*  Add for tx power by rate fine tune. We need to call the function =
after BB config. */
+	/*  Because the tx power by rate table is inited in BB config. */
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_RF);
+	status =3D PHY_RFConfig8723A(Adapter);
+	if (status =3D=3D _FAIL) {
+		DBG_8723A("PHY_RFConfig8723A fault !!\n");
+		goto exit;
+	}
+
+	/* reducing 80M spur */
+	PHY_SetBBReg(Adapter, RF_T_METER, bMaskDWord, 0x0381808d);
+	PHY_SetBBReg(Adapter, RF_SYN_G4, bMaskDWord, 0xf2ffff83);
+	PHY_SetBBReg(Adapter, RF_SYN_G4, bMaskDWord, 0xf2ffff82);
+	PHY_SetBBReg(Adapter, RF_SYN_G4, bMaskDWord, 0xf2ffff83);
+
+	/* RFSW Control */
+	PHY_SetBBReg(Adapter, rFPGA0_TxInfo, bMaskDWord, 0x00000003);	/* 0x80=
4[14]=3D 0 */
+	PHY_SetBBReg(Adapter, rFPGA0_XAB_RFInterfaceSW, bMaskDWord, 0x0700076=
0);	/* 0x870[6:5]=3D b'11 */
+	PHY_SetBBReg(Adapter, rFPGA0_XA_RFInterfaceOE, bMaskDWord, 0x66F60210=
); /* 0x860[6:5]=3D b'00 */
+
+	RT_TRACE(_module_hci_hal_init_c_, _drv_info_, ("%s: 0x870 =3D value 0=
x%x\n", __func__, PHY_QueryBBReg(Adapter, 0x870, bMaskDWord)));
+
+	/*  */
+	/*  Joseph Note: Keep RfRegChnlVal for later use. */
+	/*  */
+	pHalData->RfRegChnlVal[0] =3D PHY_QueryRFReg(Adapter, (enum RF_RADIO_=
PATH)0, RF_CHNLBW, bRFRegOffsetMask);
+	pHalData->RfRegChnlVal[1] =3D PHY_QueryRFReg(Adapter, (enum RF_RADIO_=
PATH)1, RF_CHNLBW, bRFRegOffsetMask);
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_MISC02);
+	if (!pHalData->bMACFuncEnable) {
+		_InitQueueReservedPage(Adapter);
+		_InitTxBufferBoundary(Adapter);
+	}
+	_InitQueuePriority(Adapter);
+	_InitPageBoundary(Adapter);
+	_InitTransferPageSize(Adapter);
+
+	/*  Get Rx PHY status in order to report RSSI and others. */
+	_InitDriverInfoSize(Adapter, DRVINFO_SZ);
+
+	_InitInterrupt(Adapter);
+	hal_init_macaddr23a(Adapter);/* set mac_address */
+	_InitNetworkType(Adapter);/* set msr */
+	_InitWMACSetting(Adapter);
+	_InitAdaptiveCtrl(Adapter);
+	_InitEDCA(Adapter);
+	_InitRateFallback(Adapter);
+	_InitRetryFunction(Adapter);
+	InitUsbAggregationSetting(Adapter);
+	_InitOperationMode(Adapter);/* todo */
+	rtl8723a_InitBeaconParameters(Adapter);
+
+	_InitHWLed(Adapter);
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_TURN_ON_BLOCK);
+	_BBTurnOnBlock(Adapter);
+	/* NicIFSetMacAddress(padapter, padapter->PermanentAddress); */
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_INIT_SECURITY);
+	invalidate_cam_all23a(Adapter);
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_MISC11);
+	/*  2010/12/17 MH We need to set TX power according to EFUSE content =
at first. */
+	PHY_SetTxPowerLevel8723A(Adapter, pHalData->CurrentChannel);
+
+	rtl8723a_InitAntenna_Selection(Adapter);
+
+	/*  HW SEQ CTRL */
+	/* set 0x0 to 0xFF by tynli. Default enable HW SEQ NUM. */
+	rtw_write8(Adapter, REG_HWSEQ_CTRL, 0xFF);
+
+	/*  */
+	/*  Disable BAR, suggested by Scott */
+	/*  2010.04.09 add by hpfan */
+	/*  */
+	rtw_write32(Adapter, REG_BAR_MODE_CTRL, 0x0201ffff);
+
+	if (pregistrypriv->wifi_spec)
+		rtw_write16(Adapter, REG_FAST_EDCA_CTRL, 0);
+
+	/*  Move by Neo for USB SS from above setp */
+	_RfPowerSave(Adapter);
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_IQK);
+		/*  2010/08/26 MH Merge from 8192CE. */
+		/* sherry masked that it has been done in _RfPowerSave */
+		/* 20110927 */
+		/* recovery for 8192cu and 9723Au 20111017 */
+		if (pwrctrlpriv->rf_pwrstate =3D=3D rf_on) {
+			if (pHalData->bIQKInitialized) {
+				rtl8723a_phy_iq_calibrate(Adapter, true);
+			} else {
+				rtl8723a_phy_iq_calibrate(Adapter, false);
+				pHalData->bIQKInitialized =3D true;
+			}
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_PW_TRACK);
+			rtl8723a_odm_check_tx_power_tracking(Adapter);
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_LCK);
+			rtl8723a_phy_lc_calibrate(Adapter);
+
+#ifdef CONFIG_8723AU_BT_COEXIST
+			rtl8723a_SingleDualAntennaDetection(Adapter);
+#endif
+		}
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_MISC21);
+ /* fixed USB interface interference issue */
+	rtw_write8(Adapter, 0xfe40, 0xe0);
+	rtw_write8(Adapter, 0xfe41, 0x8d);
+	rtw_write8(Adapter, 0xfe42, 0x80);
+	rtw_write32(Adapter, 0x20c, 0xfd0320);
+	/* Solve too many protocol error on USB bus */
+	if (!IS_81xxC_VENDOR_UMC_A_CUT(pHalData->VersionID)) {
+		/*  0xE6 =3D 0x94 */
+		rtw_write8(Adapter, 0xFE40, 0xE6);
+		rtw_write8(Adapter, 0xFE41, 0x94);
+		rtw_write8(Adapter, 0xFE42, 0x80);
+
+		/*  0xE0 =3D 0x19 */
+		rtw_write8(Adapter, 0xFE40, 0xE0);
+		rtw_write8(Adapter, 0xFE41, 0x19);
+		rtw_write8(Adapter, 0xFE42, 0x80);
+
+		/*  0xE5 =3D 0x91 */
+		rtw_write8(Adapter, 0xFE40, 0xE5);
+		rtw_write8(Adapter, 0xFE41, 0x91);
+		rtw_write8(Adapter, 0xFE42, 0x80);
+
+		/*  0xE2 =3D 0x81 */
+		rtw_write8(Adapter, 0xFE40, 0xE2);
+		rtw_write8(Adapter, 0xFE41, 0x81);
+		rtw_write8(Adapter, 0xFE42, 0x80);
+
+	}
+
+/* HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_INIT_PABIAS); */
+/*	_InitPABias(Adapter); */
+
+#ifdef CONFIG_8723AU_BT_COEXIST
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_BT_COEXIST);
+	/*  Init BT hw config. */
+	BT_InitHwConfig(Adapter);
+#endif
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_INIT_HAL_DM);
+	rtl8723a_InitHalDm(Adapter);
+
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_MISC31);
+	rtw_hal_set_hwreg23a(Adapter, HW_VAR_NAV_UPPER, (u8 *)&NavUpper);
+
+	/*  2011/03/09 MH debug only, UMC-B cut pass 2500 S5 test, but we nee=
d to fin root cause. */
+	if (((rtw_read32(Adapter, rFPGA0_RFMOD) & 0xFF000000) !=3D 0x83000000=
)) {
+		PHY_SetBBReg(Adapter, rFPGA0_RFMOD, BIT(24), 1);
+		RT_TRACE(_module_hci_hal_init_c_, _drv_err_, ("%s: IQK fail recorver=
\n", __func__));
+	}
+
+	/* ack for xmit mgmt frames. */
+	rtw_write32(Adapter, REG_FWHW_TXQ_CTRL, rtw_read32(Adapter, REG_FWHW_=
TXQ_CTRL)|BIT(12));
+
+exit:
+	HAL_INIT_PROFILE_TAG(HAL_INIT_STAGES_END);
+
+	DBG_8723A("%s in %dms\n", __func__,
+		  jiffies_to_msecs(jiffies - init_start_time));
+	return status;
+}
+
+static void phy_SsPwrSwitch92CU(struct rtw_adapter *Adapter,
+				enum rt_rf_power_state eRFPowerState,
+				int bRegSSPwrLvl)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	u8 value8;
+	u8 bytetmp;
+
+	switch (eRFPowerState) {
+	case rf_on:
+		if (bRegSSPwrLvl =3D=3D 1) {
+			/*  1. Enable MAC Clock. Can not be enabled now. */
+			/* WriteXBYTE(REG_SYS_CLKR+1,
+			   ReadXBYTE(REG_SYS_CLKR+1) | BIT(3)); */
+
+			/*  2. Force PWM, Enable SPS18_LDO_Marco_Block */
+			rtw_write8(Adapter, REG_SPS0_CTRL,
+				   rtw_read8(Adapter, REG_SPS0_CTRL) |
+				   (BIT0|BIT3));
+
+			/*  3. restore BB, AFE control register. */
+			/* RF */
+			if (pHalData->rf_type =3D=3D  RF_2T2R)
+				PHY_SetBBReg(Adapter, rFPGA0_XAB_RFParameter,
+					     0x380038, 1);
+			else
+				PHY_SetBBReg(Adapter, rFPGA0_XAB_RFParameter,
+					     0x38, 1);
+			PHY_SetBBReg(Adapter, rOFDM0_TRxPathEnable, 0xf0, 1);
+			PHY_SetBBReg(Adapter, rFPGA0_RFMOD, BIT1, 0);
+
+			/* AFE */
+			if (pHalData->rf_type =3D=3D  RF_2T2R)
+				PHY_SetBBReg(Adapter, rRx_Wait_CCA, bMaskDWord,
+					     0x63DB25A0);
+			else if (pHalData->rf_type =3D=3D  RF_1T1R)
+				PHY_SetBBReg(Adapter, rRx_Wait_CCA, bMaskDWord,
+					     0x631B25A0);
+
+			/*  4. issue 3-wire command that RF set to Rx idle
+			    mode. This is used to re-write the RX idle mode. */
+			/*  We can only prvide a usual value instead and then
+			    HW will modify the value by itself. */
+			PHY_SetRFReg(Adapter, RF_PATH_A, 0,
+				     bRFRegOffsetMask, 0x32D95);
+			if (pHalData->rf_type =3D=3D  RF_2T2R) {
+				PHY_SetRFReg(Adapter, RF_PATH_B, 0,
+					     bRFRegOffsetMask, 0x32D95);
+			}
+		} else {		/*  Level 2 or others. */
+			/* h.	AFE_PLL_CTRL 0x28[7:0] =3D 0x80
+			   disable AFE PLL */
+			rtw_write8(Adapter, REG_AFE_PLL_CTRL, 0x81);
+
+			/*  i.	AFE_XTAL_CTRL 0x24[15:0] =3D 0x880F
+			    gated AFE DIG_CLOCK */
+			rtw_write16(Adapter, REG_AFE_XTAL_CTRL, 0x800F);
+			mdelay(1);
+
+			/*  2. Force PWM, Enable SPS18_LDO_Marco_Block */
+			rtw_write8(Adapter, REG_SPS0_CTRL,
+				   rtw_read8(Adapter, REG_SPS0_CTRL) |
+				   (BIT0|BIT3));
+
+			/*  3. restore BB, AFE control register. */
+			/* RF */
+			if (pHalData->rf_type =3D=3D  RF_2T2R)
+				PHY_SetBBReg(Adapter, rFPGA0_XAB_RFParameter,
+					     0x380038, 1);
+			else
+				PHY_SetBBReg(Adapter, rFPGA0_XAB_RFParameter,
+					     0x38, 1);
+			PHY_SetBBReg(Adapter, rOFDM0_TRxPathEnable, 0xf0, 1);
+			PHY_SetBBReg(Adapter, rFPGA0_RFMOD, BIT1, 0);
+
+			/* AFE */
+			if (pHalData->rf_type =3D=3D  RF_2T2R)
+				PHY_SetBBReg(Adapter, rRx_Wait_CCA,
+					     bMaskDWord, 0x63DB25A0);
+			else if (pHalData->rf_type =3D=3D  RF_1T1R)
+				PHY_SetBBReg(Adapter, rRx_Wait_CCA,
+					     bMaskDWord, 0x631B25A0);
+
+			/*  4. issue 3-wire command that RF set to Rx idle
+			    mode. This is used to re-write the RX idle mode. */
+			/*  We can only prvide a usual value instead and
+			    then HW will modify the value by itself. */
+			PHY_SetRFReg(Adapter, RF_PATH_A, 0,
+				     bRFRegOffsetMask, 0x32D95);
+			if (pHalData->rf_type =3D=3D  RF_2T2R) {
+				PHY_SetRFReg(Adapter, RF_PATH_B, 0,
+					     bRFRegOffsetMask, 0x32D95);
+			}
+
+			/*  5. gated MAC Clock */
+			bytetmp =3D rtw_read8(Adapter, REG_APSD_CTRL);
+			rtw_write8(Adapter, REG_APSD_CTRL, bytetmp & ~BIT6);
+
+			mdelay(10);
+
+			/*  Set BB reset at first */
+			rtw_write8(Adapter, REG_SYS_FUNC_EN, 0x17); /* 0x16 */
+
+			/*  Enable TX */
+			rtw_write8(Adapter, REG_TXPAUSE, 0x0);
+		}
+		break;
+	case rf_sleep:
+	case rf_off:
+		value8 =3D rtw_read8(Adapter, REG_SPS0_CTRL) ;
+		if (IS_81xxC_VENDOR_UMC_B_CUT(pHalData->VersionID))
+			value8 &=3D ~(BIT0);
+		else
+			value8 &=3D ~(BIT0|BIT3);
+		if (bRegSSPwrLvl =3D=3D 1) {
+			RT_TRACE(_module_hal_init_c_, _drv_err_, ("SS LVL1\n"));
+			/*  Disable RF and BB only for SelectSuspend. */
+
+			/*  1. Set BB/RF to shutdown. */
+			/*	(1) Reg878[5:3]=3D 0	 RF rx_code for
+							preamble power saving */
+			/*	(2)Reg878[21:19]=3D 0	Turn off RF-B */
+			/*	(3) RegC04[7:4]=3D 0	Turn off all paths
+							for packet detection */
+			/*	(4) Reg800[1] =3D 1	enable preamble power
+							saving */
+			Adapter->pwrctrlpriv.PS_BBRegBackup[PSBBREG_RF0] =3D
+				PHY_QueryBBReg(Adapter, rFPGA0_XAB_RFParameter,
+					       bMaskDWord);
+			Adapter->pwrctrlpriv.PS_BBRegBackup[PSBBREG_RF1] =3D
+				PHY_QueryBBReg(Adapter, rOFDM0_TRxPathEnable,
+					       bMaskDWord);
+			Adapter->pwrctrlpriv.PS_BBRegBackup[PSBBREG_RF2] =3D
+				PHY_QueryBBReg(Adapter, rFPGA0_RFMOD,
+					       bMaskDWord);
+			if (pHalData->rf_type =3D=3D  RF_2T2R) {
+				PHY_SetBBReg(Adapter, rFPGA0_XAB_RFParameter,
+					     0x380038, 0);
+			} else if (pHalData->rf_type =3D=3D  RF_1T1R) {
+				PHY_SetBBReg(Adapter, rFPGA0_XAB_RFParameter,
+					     0x38, 0);
+			}
+			PHY_SetBBReg(Adapter, rOFDM0_TRxPathEnable, 0xf0, 0);
+			PHY_SetBBReg(Adapter, rFPGA0_RFMOD, BIT1, 1);
+
+			/*  2 .AFE control register to power down. bit[30:22] */
+			Adapter->pwrctrlpriv.PS_BBRegBackup[PSBBREG_AFE0] =3D
+				PHY_QueryBBReg(Adapter, rRx_Wait_CCA,
+					       bMaskDWord);
+			if (pHalData->rf_type =3D=3D  RF_2T2R)
+				PHY_SetBBReg(Adapter, rRx_Wait_CCA, bMaskDWord,
+					     0x00DB25A0);
+			else if (pHalData->rf_type =3D=3D  RF_1T1R)
+				PHY_SetBBReg(Adapter, rRx_Wait_CCA, bMaskDWord,
+					     0x001B25A0);
+
+			/*  3. issue 3-wire command that RF set to power down.*/
+			PHY_SetRFReg(Adapter, RF_PATH_A, 0, bRFRegOffsetMask, 0);
+			if (pHalData->rf_type =3D=3D  RF_2T2R)
+				PHY_SetRFReg(Adapter, RF_PATH_B, 0,
+					     bRFRegOffsetMask, 0);
+
+			/*  4. Force PFM , disable SPS18_LDO_Marco_Block */
+			rtw_write8(Adapter, REG_SPS0_CTRL, value8);
+		} else {	/*  Level 2 or others. */
+			RT_TRACE(_module_hal_init_c_, _drv_err_, ("SS LVL2\n"));
+			{
+				u8 eRFPath =3D RF_PATH_A, value8 =3D 0;
+				rtw_write8(Adapter, REG_TXPAUSE, 0xFF);
+				PHY_SetRFReg(Adapter,
+					     (enum RF_RADIO_PATH)eRFPath,
+					     0x0, bMaskByte0, 0x0);
+				value8 |=3D APSDOFF;
+				/* 0x40 */
+				rtw_write8(Adapter, REG_APSD_CTRL, value8);
+
+				/*  After switch APSD, we need to delay
+				    for stability */
+				mdelay(10);
+
+				/*  Set BB reset at first */
+				value8 =3D 0 ;
+				value8 |=3D (FEN_USBD | FEN_USBA |
+					   FEN_BB_GLB_RSTn);
+				/* 0x16 */
+				rtw_write8(Adapter, REG_SYS_FUNC_EN, value8);
+			}
+
+			/*  Disable RF and BB only for SelectSuspend. */
+
+			/*  1. Set BB/RF to shutdown. */
+			/*	(1) Reg878[5:3]=3D 0	RF rx_code for
+							preamble power saving */
+			/*	(2)Reg878[21:19]=3D 0	Turn off RF-B */
+			/*	(3) RegC04[7:4]=3D 0	Turn off all paths for
+							packet detection */
+			/*	(4) Reg800[1] =3D 1	enable preamble power
+							saving */
+			Adapter->pwrctrlpriv.PS_BBRegBackup[PSBBREG_RF0] =3D
+				PHY_QueryBBReg(Adapter, rFPGA0_XAB_RFParameter,
+					       bMaskDWord);
+			Adapter->pwrctrlpriv.PS_BBRegBackup[PSBBREG_RF1] =3D
+				PHY_QueryBBReg(Adapter, rOFDM0_TRxPathEnable,
+					       bMaskDWord);
+			Adapter->pwrctrlpriv.PS_BBRegBackup[PSBBREG_RF2] =3D
+				PHY_QueryBBReg(Adapter, rFPGA0_RFMOD,
+					       bMaskDWord);
+			if (pHalData->rf_type =3D=3D  RF_2T2R)
+				PHY_SetBBReg(Adapter, rFPGA0_XAB_RFParameter,
+					     0x380038, 0);
+			else if (pHalData->rf_type =3D=3D  RF_1T1R)
+				PHY_SetBBReg(Adapter, rFPGA0_XAB_RFParameter,
+					     0x38, 0);
+			PHY_SetBBReg(Adapter, rOFDM0_TRxPathEnable, 0xf0, 0);
+			PHY_SetBBReg(Adapter, rFPGA0_RFMOD, BIT1, 1);
+
+			/*  2 .AFE control register to power down. bit[30:22] */
+			Adapter->pwrctrlpriv.PS_BBRegBackup[PSBBREG_AFE0] =3D
+				PHY_QueryBBReg(Adapter, rRx_Wait_CCA,
+					       bMaskDWord);
+			if (pHalData->rf_type =3D=3D  RF_2T2R)
+				PHY_SetBBReg(Adapter, rRx_Wait_CCA, bMaskDWord,
+					     0x00DB25A0);
+			else if (pHalData->rf_type =3D=3D  RF_1T1R)
+				PHY_SetBBReg(Adapter, rRx_Wait_CCA, bMaskDWord,
+					     0x001B25A0);
+
+			/* 3. issue 3-wire command that RF set to power down. */
+			PHY_SetRFReg(Adapter, RF_PATH_A, 0, bRFRegOffsetMask, 0);
+			if (pHalData->rf_type =3D=3D  RF_2T2R)
+				PHY_SetRFReg(Adapter, RF_PATH_B, 0,
+					     bRFRegOffsetMask, 0);
+
+			/*  4. Force PFM , disable SPS18_LDO_Marco_Block */
+			rtw_write8(Adapter, REG_SPS0_CTRL, value8);
+
+			/*  2010/10/13 MH/Isaachsu exchange sequence. */
+			/* h.	AFE_PLL_CTRL 0x28[7:0] =3D 0x80
+				disable AFE PLL */
+			rtw_write8(Adapter, REG_AFE_PLL_CTRL, 0x80);
+			mdelay(1);
+
+			/*  i.	AFE_XTAL_CTRL 0x24[15:0] =3D 0x880F
+				gated AFE DIG_CLOCK */
+			rtw_write16(Adapter, REG_AFE_XTAL_CTRL, 0xA80F);
+		}
+		break;
+	default:
+		break;
+	}
+
+}	/*  phy_PowerSwitch92CU */
+
+void _ps_open_RF23a(struct rtw_adapter *padapter)
+{
+	/* here call with bRegSSPwrLvl 1, bRegSSPwrLvl 2 needs to be verified=
 */
+	phy_SsPwrSwitch92CU(padapter, rf_on, 1);
+}
+
+static void CardDisableRTL8723U(struct rtw_adapter *Adapter)
+{
+	u8		u1bTmp;
+
+	DBG_8723A("CardDisableRTL8723U\n");
+	/*  USB-MF Card Disable Flow */
+	/*  1. Run LPS WL RFOFF flow */
+	HalPwrSeqCmdParsing23a(Adapter, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+			    PWR_INTF_USB_MSK, rtl8723AU_enter_lps_flow);
+
+	/*  2. 0x1F[7:0] =3D 0		turn off RF */
+	rtw_write8(Adapter, REG_RF_CTRL, 0x00);
+
+	/*	=3D=3D=3D=3D Reset digital sequence   =3D=3D=3D=3D=3D=3D */
+	if ((rtw_read8(Adapter, REG_MCUFWDL)&BIT7) &&
+	    Adapter->bFWReady) /* 8051 RAM code */
+		rtl8723a_FirmwareSelfReset(Adapter);
+
+	/*  Reset MCU. Suggested by Filen. 2011.01.26. by tynli. */
+	u1bTmp =3D rtw_read8(Adapter, REG_SYS_FUNC_EN+1);
+	rtw_write8(Adapter, REG_SYS_FUNC_EN+1, (u1bTmp & (~BIT2)));
+
+	/*  g.	MCUFWDL 0x80[1:0]=3D 0		reset MCU ready status */
+	rtw_write8(Adapter, REG_MCUFWDL, 0x00);
+
+	/*	=3D=3D=3D=3D Reset digital sequence end =3D=3D=3D=3D=3D=3D */
+	/*  Card disable power action flow */
+	HalPwrSeqCmdParsing23a(Adapter, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+			       PWR_INTF_USB_MSK,
+			       rtl8723AU_card_disable_flow);
+
+	/*  Reset MCU IO Wrapper, added by Roger, 2011.08.30. */
+	u1bTmp =3D rtw_read8(Adapter, REG_RSV_CTRL + 1);
+	rtw_write8(Adapter, REG_RSV_CTRL+1, (u1bTmp & (~BIT0)));
+	u1bTmp =3D rtw_read8(Adapter, REG_RSV_CTRL + 1);
+	rtw_write8(Adapter, REG_RSV_CTRL+1, u1bTmp | BIT0);
+
+	/*  7. RSV_CTRL 0x1C[7:0] =3D 0x0E  lock ISO/CLK/Power control regist=
er */
+	rtw_write8(Adapter, REG_RSV_CTRL, 0x0e);
+}
+
+static u32 rtl8723au_hal_deinit(struct rtw_adapter *padapter)
+{
+	DBG_8723A("=3D=3D> %s\n", __func__);
+
+#ifdef CONFIG_8723AU_BT_COEXIST
+	BT_HaltProcess(padapter);
+#endif
+	/*  2011/02/18 To Fix RU LNA  power leakage problem. We need to
+	    execute below below in Adapter init and halt sequence.
+	    According to EEchou's opinion, we can enable the ability for all =
*/
+	/*  IC. Accord to johnny's opinion, only RU need the support. */
+	CardDisableRTL8723U(padapter);
+
+	return _SUCCESS;
+}
+
+static unsigned int rtl8723au_inirp_init(struct rtw_adapter *Adapter)
+{
+	u8 i;
+	struct recv_buf *precvbuf;
+	uint	status;
+	struct intf_hdl *pintfhdl =3D &Adapter->iopriv.intf;
+	struct recv_priv *precvpriv =3D &Adapter->recvpriv;
+	u32 (*_read_port)(struct intf_hdl *pintfhdl, u32 addr, u32 cnt,
+			  struct recv_buf *rbuf);
+	u32 (*_read_interrupt)(struct intf_hdl *pintfhdl, u32 addr);
+	struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(Adapter);
+
+	_read_port =3D pintfhdl->io_ops._read_port;
+
+	status =3D _SUCCESS;
+
+	RT_TRACE(_module_hci_hal_init_c_, _drv_info_, ("=3D=3D=3D> usb_inirp_=
init\n"));
+
+	precvpriv->ff_hwaddr =3D RECV_BULK_IN_ADDR;
+
+	/* issue Rx irp to receive data */
+	precvbuf =3D (struct recv_buf *)precvpriv->precv_buf;
+	for (i =3D 0; i < NR_RECVBUFF; i++) {
+		if (_read_port(pintfhdl, precvpriv->ff_hwaddr, 0, precvbuf) =3D=3D
+		    false) {
+			RT_TRACE(_module_hci_hal_init_c_, _drv_err_,
+				 ("usb_rx_init: usb_read_port error\n"));
+			status =3D _FAIL;
+			goto exit;
+		}
+		precvbuf++;
+		precvpriv->free_recv_buf_queue_cnt--;
+	}
+	_read_interrupt =3D pintfhdl->io_ops._read_interrupt;
+	if (_read_interrupt(pintfhdl, RECV_INT_IN_ADDR) =3D=3D false) {
+		RT_TRACE(_module_hci_hal_init_c_, _drv_err_,
+			 ("usb_rx_init: usb_read_interrupt error\n"));
+		status =3D _FAIL;
+	}
+	pHalData->IntrMask[0] =3D rtw_read32(Adapter, REG_USB_HIMR);
+	MSG_8723A("pHalData->IntrMask =3D 0x%04x\n", pHalData->IntrMask[0]);
+	pHalData->IntrMask[0] |=3D UHIMR_C2HCMD|UHIMR_CPWM;
+	rtw_write32(Adapter, REG_USB_HIMR, pHalData->IntrMask[0]);
+exit:
+	RT_TRACE(_module_hci_hal_init_c_, _drv_info_,
+		 ("<=3D=3D=3D usb_inirp_init\n"));
+	return status;
+}
+
+static unsigned int rtl8723au_inirp_deinit(struct rtw_adapter *Adapter=
)
+{
+	struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(Adapter);
+
+	RT_TRACE(_module_hci_hal_init_c_, _drv_info_,
+		 ("\n =3D=3D=3D> usb_rx_deinit\n"));
+	rtw_read_port_cancel(Adapter);
+	pHalData->IntrMask[0] =3D rtw_read32(Adapter, REG_USB_HIMR);
+	MSG_8723A("%s pHalData->IntrMask =3D 0x%04x\n", __func__,
+		  pHalData->IntrMask[0]);
+	pHalData->IntrMask[0] =3D 0x0;
+	rtw_write32(Adapter, REG_USB_HIMR, pHalData->IntrMask[0]);
+	RT_TRACE(_module_hci_hal_init_c_, _drv_info_,
+		 ("\n <=3D=3D=3D usb_rx_deinit\n"));
+	return _SUCCESS;
+}
+
+static void _ReadBoardType(struct rtw_adapter *Adapter, u8 *PROMConten=
t,
+			   bool AutoloadFail)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	u8 boardType =3D BOARD_USB_DONGLE;
+
+	if (AutoloadFail) {
+		if (IS_8723_SERIES(pHalData->VersionID))
+			pHalData->rf_type =3D RF_1T1R;
+		else
+			pHalData->rf_type =3D RF_2T2R;
+		pHalData->BoardType =3D boardType;
+		return;
+	}
+
+	boardType =3D PROMContent[EEPROM_NORMAL_BoardType];
+	boardType &=3D BOARD_TYPE_NORMAL_MASK;/* bit[7:5] */
+	boardType >>=3D 5;
+
+	pHalData->BoardType =3D boardType;
+	MSG_8723A("_ReadBoardType(%x)\n", pHalData->BoardType);
+
+	if (boardType =3D=3D BOARD_USB_High_PA)
+		pHalData->ExternalPA =3D 1;
+}
+
+static void _ReadLEDSetting(struct rtw_adapter *Adapter, u8 *PROMConte=
nt,
+			    bool AutoloadFail)
+{
+	struct led_priv *pledpriv =3D &Adapter->ledpriv;
+
+	pledpriv->LedStrategy =3D HW_LED;
+}
+
+static void Hal_EfuseParsePIDVID_8723AU(struct rtw_adapter *pAdapter,
+					u8 *hwinfo, bool AutoLoadFail)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(pAdapter);
+
+	if (AutoLoadFail) {
+		pHalData->EEPROMVID =3D 0;
+		pHalData->EEPROMPID =3D 0;
+	} else {
+		/*  VID, PID */
+		pHalData->EEPROMVID =3D
+			le16_to_cpu(*(u16 *)&hwinfo[EEPROM_VID_8723AU]);
+		pHalData->EEPROMPID =3D
+			le16_to_cpu(*(u16 *)&hwinfo[EEPROM_PID_8723AU]);
+	}
+
+	MSG_8723A("EEPROM VID =3D 0x%4x\n", pHalData->EEPROMVID);
+	MSG_8723A("EEPROM PID =3D 0x%4x\n", pHalData->EEPROMPID);
+}
+
+static void Hal_EfuseParseMACAddr_8723AU(struct rtw_adapter *padapter,
+					 u8 *hwinfo, bool AutoLoadFail)
+{
+	u16 i;
+	u8 sMacAddr[ETH_ALEN] =3D {0x00, 0xE0, 0x4C, 0x87, 0x23, 0x00};
+	struct eeprom_priv *pEEPROM =3D GET_EEPROM_EFUSE_PRIV(padapter);
+
+	if (AutoLoadFail) {
+		for (i =3D 0; i < 6; i++)
+			pEEPROM->mac_addr[i] =3D sMacAddr[i];
+	} else {
+		/* Read Permanent MAC address */
+		memcpy(pEEPROM->mac_addr, &hwinfo[EEPROM_MAC_ADDR_8723AU],
+		       ETH_ALEN);
+	}
+
+	RT_TRACE(_module_hci_hal_init_c_, _drv_notice_,
+		 ("Hal_EfuseParseMACAddr_8723AU: Permanent Address =3D%02x:%02x:"
+		  "%02x:%02x:%02x:%02x\n",
+		  pEEPROM->mac_addr[0], pEEPROM->mac_addr[1],
+		  pEEPROM->mac_addr[2], pEEPROM->mac_addr[3],
+		  pEEPROM->mac_addr[4], pEEPROM->mac_addr[5]));
+}
+
+static void readAdapterInfo(struct rtw_adapter *padapter)
+{
+	struct eeprom_priv *pEEPROM =3D GET_EEPROM_EFUSE_PRIV(padapter);
+	/* struct hal_data_8723a * pHalData =3D GET_HAL_DATA(padapter); */
+	u8 hwinfo[HWSET_MAX_SIZE];
+
+	Hal_InitPGData(padapter, hwinfo);
+	Hal_EfuseParseIDCode(padapter, hwinfo);
+	Hal_EfuseParsePIDVID_8723AU(padapter, hwinfo,
+				    pEEPROM->bautoload_fail_flag);
+	Hal_EfuseParseEEPROMVer(padapter, hwinfo,
+				pEEPROM->bautoload_fail_flag);
+	Hal_EfuseParseMACAddr_8723AU(padapter, hwinfo,
+				     pEEPROM->bautoload_fail_flag);
+	Hal_EfuseParsetxpowerinfo_8723A(padapter, hwinfo,
+					pEEPROM->bautoload_fail_flag);
+	_ReadBoardType(padapter, hwinfo, pEEPROM->bautoload_fail_flag);
+	Hal_EfuseParseBTCoexistInfo_8723A(padapter, hwinfo,
+					  pEEPROM->bautoload_fail_flag);
+
+	rtl8723a_EfuseParseChnlPlan(padapter, hwinfo,
+				    pEEPROM->bautoload_fail_flag);
+	Hal_EfuseParseThermalMeter_8723A(padapter, hwinfo,
+					 pEEPROM->bautoload_fail_flag);
+	_ReadLEDSetting(padapter, hwinfo, pEEPROM->bautoload_fail_flag);
+/*	_ReadRFSetting(Adapter, PROMContent, pEEPROM->bautoload_fail_flag);=
 */
+/*	_ReadPSSetting(Adapter, PROMContent, pEEPROM->bautoload_fail_flag);=
 */
+	Hal_EfuseParseAntennaDiversity(padapter, hwinfo,
+				       pEEPROM->bautoload_fail_flag);
+
+	Hal_EfuseParseEEPROMVer(padapter, hwinfo, pEEPROM->bautoload_fail_fla=
g);
+	Hal_EfuseParseCustomerID(padapter, hwinfo,
+				 pEEPROM->bautoload_fail_flag);
+	Hal_EfuseParseRateIndicationOption(padapter, hwinfo,
+					   pEEPROM->bautoload_fail_flag);
+	Hal_EfuseParseXtal_8723A(padapter, hwinfo,
+				 pEEPROM->bautoload_fail_flag);
+	/*  */
+	/*  The following part initialize some vars by PG info. */
+	/*  */
+	Hal_InitChannelPlan23a(padapter);
+
+	/* hal_CustomizedBehavior_8723U(Adapter); */
+
+/*	Adapter->bDongle =3D (PROMContent[EEPROM_EASY_REPLACEMENT] =3D=3D 1=
)? 0: 1; */
+	DBG_8723A("%s(): REPLACEMENT =3D %x\n", __func__, padapter->bDongle);
+}
+
+static void _ReadPROMContent(struct rtw_adapter *Adapter)
+{
+	struct eeprom_priv *pEEPROM =3D GET_EEPROM_EFUSE_PRIV(Adapter);
+	u8 eeValue;
+
+	eeValue =3D rtw_read8(Adapter, REG_9346CR);
+	/*  To check system boot selection. */
+	pEEPROM->EepromOrEfuse =3D (eeValue & BOOT_FROM_EEPROM) ? true : fals=
e;
+	pEEPROM->bautoload_fail_flag =3D (eeValue & EEPROM_EN) ? false : true=
;
+
+	DBG_8723A("Boot from %s, Autoload %s !\n",
+		  (pEEPROM->EepromOrEfuse ? "EEPROM" : "EFUSE"),
+		  (pEEPROM->bautoload_fail_flag ? "Fail" : "OK"));
+
+	readAdapterInfo(Adapter);
+}
+
+static void _ReadRFType(struct rtw_adapter *Adapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+
+	pHalData->rf_chip =3D RF_6052;
+}
+
+static void _ReadSilmComboMode(struct rtw_adapter *Adapter)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+
+	pHalData->SlimComboDbg =3D false;	/*  Default is not debug mode. */
+}
+
+/*  */
+/*	Description: */
+/*		We should set Efuse cell selection to WiFi cell in default. */
+/*  */
+/*	Assumption: */
+/*		PASSIVE_LEVEL */
+/*  */
+/*	Added by Roger, 2010.11.23. */
+/*  */
+static void hal_EfuseCellSel(struct rtw_adapter *Adapter)
+{
+	u32 value32;
+
+	value32 =3D rtw_read32(Adapter, EFUSE_TEST);
+	value32 =3D (value32 & ~EFUSE_SEL_MASK) | EFUSE_SEL(EFUSE_WIFI_SEL_0)=
;
+	rtw_write32(Adapter, EFUSE_TEST, value32);
+}
+
+static int _ReadAdapterInfo8723AU(struct rtw_adapter *Adapter)
+{
+	/* struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(Adapter); */
+	unsigned long start =3D jiffies;
+
+	MSG_8723A("=3D=3D=3D=3D> _ReadAdapterInfo8723AU\n");
+
+	hal_EfuseCellSel(Adapter);
+
+	_ReadRFType(Adapter);/* rf_chip -> _InitRFType() */
+	_ReadPROMContent(Adapter);
+
+	/*  2010/10/25 MH THe function must be called after
+	    borad_type & IC-Version recognize. */
+	_ReadSilmComboMode(Adapter);
+
+	/* MSG_8723A("%s()(done), rf_chip =3D 0x%x, rf_type =3D 0x%x\n",
+	   __func__, pHalData->rf_chip, pHalData->rf_type); */
+
+	MSG_8723A("<=3D=3D=3D=3D _ReadAdapterInfo8723AU in %d ms\n",
+		  jiffies_to_msecs(jiffies - start));
+
+	return _SUCCESS;
+}
+
+static void ReadAdapterInfo8723AU(struct rtw_adapter *Adapter)
+{
+	/*  Read EEPROM size before call any EEPROM function */
+	Adapter->EepromAddressSize =3D GetEEPROMSize8723A(Adapter);
+
+	_ReadAdapterInfo8723AU(Adapter);
+}
+
+#define GPIO_DEBUG_PORT_NUM 0
+static void rtl8723au_trigger_gpio_0(struct rtw_adapter *padapter)
+{
+	u32 gpioctrl;
+	DBG_8723A("=3D=3D> trigger_gpio_0...\n");
+	rtw_write16_async(padapter, REG_GPIO_PIN_CTRL, 0);
+	rtw_write8_async(padapter, REG_GPIO_PIN_CTRL+2, 0xFF);
+	gpioctrl =3D (BIT(GPIO_DEBUG_PORT_NUM) << 24)|
+		(BIT(GPIO_DEBUG_PORT_NUM) << 16);
+	rtw_write32_async(padapter, REG_GPIO_PIN_CTRL, gpioctrl);
+	gpioctrl |=3D (BIT(GPIO_DEBUG_PORT_NUM)<<8);
+	rtw_write32_async(padapter, REG_GPIO_PIN_CTRL, gpioctrl);
+	DBG_8723A("<=3D=3D=3D trigger_gpio_0...\n");
+}
+
+/*
+ * If variable not handled here,
+ * some variables will be processed in SetHwReg8723A()
+ */
+static void SetHwReg8723AU(struct rtw_adapter *Adapter, u8 variable, u=
8 *val)
+{
+	switch (variable) {
+	case HW_VAR_RXDMA_AGG_PG_TH:
+		break;
+	case HW_VAR_SET_RPWM:
+		rtl8723a_set_rpwm(Adapter, *val);
+		break;
+	case HW_VAR_TRIGGER_GPIO_0:
+		rtl8723au_trigger_gpio_0(Adapter);
+		break;
+	default:
+		SetHwReg8723A(Adapter, variable, val);
+		break;
+	}
+
+}
+
+/*
+ * If variable not handled here,
+ * some variables will be processed in GetHwReg8723A()
+ */
+static void GetHwReg8723AU(struct rtw_adapter *Adapter, u8 variable, u=
8 *val)
+{
+	GetHwReg8723A(Adapter, variable, val);
+}
+
+/*  */
+/*	Description: */
+/*		Query setting of specified variable. */
+/*  */
+static u8 GetHalDefVar8192CUsb(struct rtw_adapter *Adapter,
+			       enum hal_def_variable eVariable, void *pValue)
+{
+	struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(Adapter);
+	u8			bResult =3D _SUCCESS;
+
+	switch (eVariable) {
+	case HAL_DEF_UNDERCORATEDSMOOTHEDPWDB:
+		*((int *)pValue) =3D pHalData->dmpriv.UndecoratedSmoothedPWDB;
+		break;
+	case HAL_DEF_IS_SUPPORT_ANT_DIV:
+		break;
+	case HAL_DEF_CURRENT_ANTENNA:
+		break;
+	case HAL_DEF_DRVINFO_SZ:
+		*((u32 *)pValue) =3D DRVINFO_SZ;
+		break;
+	case HAL_DEF_MAX_RECVBUF_SZ:
+		*((u32 *)pValue) =3D MAX_RECVBUF_SZ;
+		break;
+	case HAL_DEF_RX_PACKET_OFFSET:
+		*((u32 *)pValue) =3D RXDESC_SIZE + DRVINFO_SZ;
+		break;
+	case HAL_DEF_DBG_DUMP_RXPKT:
+		*((u8 *)pValue) =3D pHalData->bDumpRxPkt;
+		break;
+	case HAL_DEF_DBG_DM_FUNC:
+		*((u32 *)pValue) =3D pHalData->odmpriv.SupportAbility;
+		break;
+	case HW_VAR_MAX_RX_AMPDU_FACTOR:
+		*((u32 *)pValue) =3D IEEE80211_HT_MAX_AMPDU_64K;
+		break;
+	case HW_DEF_ODM_DBG_FLAG:
+	{
+		struct dm_odm_t	*pDM_Odm =3D &pHalData->odmpriv;
+		printk("pDM_Odm->DebugComponents =3D 0x%llx\n",
+		       pDM_Odm->DebugComponents);
+	}
+		break;
+	default:
+		/* RT_TRACE(COMP_INIT, DBG_WARNING, ("GetHalDefVar8192CUsb(): "
+		   "Unkown variable: %d!\n", eVariable)); */
+		bResult =3D _FAIL;
+		break;
+	}
+
+	return bResult;
+}
+
+/*	Change default setting of specified variable. */
+static u8 SetHalDefVar8192CUsb(struct rtw_adapter *Adapter,
+			       enum hal_def_variable eVariable, void *pValue)
+{
+	struct hal_data_8723a *pHalData =3D GET_HAL_DATA(Adapter);
+	u8 bResult =3D _SUCCESS;
+
+	switch (eVariable) {
+	case HAL_DEF_DBG_DUMP_RXPKT:
+		pHalData->bDumpRxPkt =3D *((u8 *)pValue);
+		break;
+	case HAL_DEF_DBG_DM_FUNC:
+	{
+		u8 dm_func =3D *((u8 *)pValue);
+		struct dm_priv	*pdmpriv =3D &pHalData->dmpriv;
+		struct dm_odm_t *podmpriv =3D &pHalData->odmpriv;
+
+		if (dm_func =3D=3D 0) { /* disable all dynamic func */
+			podmpriv->SupportAbility =3D DYNAMIC_FUNC_DISABLE;
+			DBG_8723A("=3D=3D> Disable all dynamic function...\n");
+		} else if (dm_func =3D=3D 1) {/* disable DIG */
+			podmpriv->SupportAbility &=3D (~DYNAMIC_BB_DIG);
+			DBG_8723A("=3D=3D> Disable DIG...\n");
+		} else if (dm_func =3D=3D 2) {/* disable High power */
+			podmpriv->SupportAbility &=3D (~DYNAMIC_BB_DYNAMIC_TXPWR);
+		} else if (dm_func =3D=3D 3) {/* disable tx power tracking */
+			podmpriv->SupportAbility &=3D (~DYNAMIC_RF_CALIBRATION);
+			DBG_8723A("=3D=3D> Disable tx power tracking...\n");
+		} else if (dm_func =3D=3D 4) {/* disable BT coexistence */
+			pdmpriv->DMFlag &=3D (~DYNAMIC_FUNC_BT);
+		} else if (dm_func =3D=3D 5) {/* disable antenna diversity */
+			podmpriv->SupportAbility &=3D (~DYNAMIC_BB_ANT_DIV);
+		} else if (dm_func =3D=3D 6) {/* turn on all dynamic func */
+			if (!(podmpriv->SupportAbility & DYNAMIC_BB_DIG)) {
+				struct dig_t *pDigTable =3D
+					&podmpriv->DM_DigTable;
+				pDigTable->CurIGValue =3D rtw_read8(Adapter, 0xc50);
+			}
+			pdmpriv->DMFlag |=3D DYNAMIC_FUNC_BT;
+			podmpriv->SupportAbility =3D DYNAMIC_ALL_FUNC_ENABLE;
+			DBG_8723A("=3D=3D> Turn on all dynamic function...\n");
+		}
+	}
+		break;
+	case HW_DEF_FA_CNT_DUMP:
+	{
+		u8 bRSSIDump =3D *((u8 *)pValue);
+		struct dm_odm_t *pDM_Odm =3D &pHalData->odmpriv;
+		if (bRSSIDump)
+			pDM_Odm->DebugComponents =3D ODM_COMP_DIG|ODM_COMP_FA_CNT;
+		else
+			pDM_Odm->DebugComponents =3D 0;
+	}
+		break;
+	case HW_DEF_ODM_DBG_FLAG:
+	{
+		u64 DebugComponents =3D *((u64 *)pValue);
+		struct dm_odm_t *pDM_Odm =3D &pHalData->odmpriv;
+		pDM_Odm->DebugComponents =3D DebugComponents;
+	}
+		break;
+	default:
+		/* RT_TRACE(COMP_INIT, DBG_TRACE, ("SetHalDefVar819xUsb(): "
+		   "Unkown variable: %d!\n", eVariable)); */
+		bResult =3D _FAIL;
+		break;
+	}
+
+	return bResult;
+}
+
+static void UpdateHalRAMask8192CUsb(struct rtw_adapter *padapter,
+				    u32 mac_id, u8 rssi_level)
+{
+	u8	init_rate =3D 0;
+	u8	networkType, raid;
+	u32	mask, rate_bitmap;
+	u8	shortGIrate =3D false;
+	int	supportRateNum =3D 0;
+	struct sta_info	*psta;
+	struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(padapter);
+	struct dm_priv	*pdmpriv =3D &pHalData->dmpriv;
+	struct mlme_ext_priv *pmlmeext =3D &padapter->mlmeextpriv;
+	struct mlme_ext_info *pmlmeinfo =3D &pmlmeext->mlmext_info;
+	struct wlan_bssid_ex *cur_network =3D &pmlmeinfo->network;
+
+	if (mac_id >=3D NUM_STA) /* CAM_SIZE */
+		return;
+
+	psta =3D pmlmeinfo->FW_sta_info[mac_id].psta;
+	if (psta =3D=3D NULL)
+		return;
+
+	switch (mac_id) {
+	case 0:/*  for infra mode */
+		supportRateNum =3D
+			rtw_get_rateset_len23a(cur_network->SupportedRates);
+		networkType =3D judge_network_type23a(padapter,
+						 cur_network->SupportedRates,
+						 supportRateNum) & 0xf;
+		/* pmlmeext->cur_wireless_mode =3D networkType; */
+		raid =3D networktype_to_raid23a(networkType);
+
+		mask =3D update_supported_rate23a(cur_network->SupportedRates,
+					     supportRateNum);
+		mask |=3D (pmlmeinfo->HT_enable) ?
+			update_MSC_rate23a(&pmlmeinfo->HT_caps) : 0;
+
+		if (support_short_GI23a(padapter, &pmlmeinfo->HT_caps))
+			shortGIrate =3D true;
+		break;
+
+	case 1:/* for broadcast/multicast */
+		supportRateNum =3D rtw_get_rateset_len23a(
+			pmlmeinfo->FW_sta_info[mac_id].SupportedRates);
+		if (pmlmeext->cur_wireless_mode & WIRELESS_11B)
+			networkType =3D WIRELESS_11B;
+		else
+			networkType =3D WIRELESS_11G;
+		raid =3D networktype_to_raid23a(networkType);
+
+		mask =3D update_basic_rate23a(cur_network->SupportedRates,
+					 supportRateNum);
+		break;
+
+	default: /* for each sta in IBSS */
+		supportRateNum =3D rtw_get_rateset_len23a(
+			pmlmeinfo->FW_sta_info[mac_id].SupportedRates);
+		networkType =3D judge_network_type23a(padapter,
+						 pmlmeinfo->FW_sta_info[mac_id].SupportedRates,
+						 supportRateNum) & 0xf;
+		/* pmlmeext->cur_wireless_mode =3D networkType; */
+		raid =3D networktype_to_raid23a(networkType);
+
+		mask =3D update_supported_rate23a(cur_network->SupportedRates,
+					     supportRateNum);
+
+		/* todo: support HT in IBSS */
+		break;
+	}
+
+	/* mask &=3D 0x0fffffff; */
+	rate_bitmap =3D 0x0fffffff;
+	rate_bitmap =3D ODM_Get_Rate_Bitmap23a(&pHalData->odmpriv,
+					  mac_id, mask, rssi_level);
+	printk(KERN_DEBUG "%s =3D> mac_id:%d, networkType:0x%02x, "
+	       "mask:0x%08x\n\t =3D=3D> rssi_level:%d, rate_bitmap:0x%08x\n",
+	       __func__,
+	       mac_id, networkType, mask, rssi_level, rate_bitmap);
+
+	mask &=3D rate_bitmap;
+	mask |=3D ((raid<<28)&0xf0000000);
+
+	init_rate =3D get_highest_rate_idx23a(mask)&0x3f;
+
+	if (pHalData->fw_ractrl =3D=3D true) {
+		u8 arg =3D 0;
+
+		/* arg =3D (cam_idx-4)&0x1f;MACID */
+		arg =3D mac_id&0x1f;/* MACID */
+
+		arg |=3D BIT(7);
+
+		if (shortGIrate =3D=3D true)
+			arg |=3D BIT(5);
+
+		DBG_8723A("update raid entry, mask =3D 0x%x, arg =3D 0x%x\n",
+			  mask, arg);
+
+		rtl8723a_set_raid_cmd(padapter, mask, arg);
+	} else {
+		if (shortGIrate =3D=3D true)
+			init_rate |=3D BIT(6);
+
+		rtw_write8(padapter, (REG_INIDATA_RATE_SEL+mac_id), init_rate);
+	}
+
+	/* set ra_id */
+	psta->raid =3D raid;
+	psta->init_rate =3D init_rate;
+
+	/* set correct initial date rate for each mac_id */
+	pdmpriv->INIDATA_RATE[mac_id] =3D init_rate;
+}
+
+static void rtl8723au_init_default_value(struct rtw_adapter *padapter)
+{
+	rtl8723a_init_default_value(padapter);
+}
+
+static u8 rtl8192cu_ps_func(struct rtw_adapter *Adapter,
+			    enum hal_intf_ps_func efunc_id, u8 *val)
+{
+	return true;
+}
+
+int rtl8723au_set_hal_ops(struct rtw_adapter *padapter)
+{
+	struct hal_ops	*pHalFunc =3D &padapter->HalFunc;
+
+	padapter->HalData =3D kzalloc(sizeof(struct hal_data_8723a), GFP_KERN=
EL);
+	if (!padapter->HalData) {
+		DBG_8723A("cannot alloc memory for HAL DATA\n");
+		return -ENOMEM;
+	}
+	padapter->hal_data_sz =3D sizeof(struct hal_data_8723a);
+
+	pHalFunc->hal_init =3D &rtl8723au_hal_init;
+	pHalFunc->hal_deinit =3D &rtl8723au_hal_deinit;
+
+	pHalFunc->inirp_init =3D &rtl8723au_inirp_init;
+	pHalFunc->inirp_deinit =3D &rtl8723au_inirp_deinit;
+
+	pHalFunc->init_xmit_priv =3D &rtl8723au_init_xmit_priv;
+	pHalFunc->free_xmit_priv =3D &rtl8723au_free_xmit_priv;
+
+	pHalFunc->init_recv_priv =3D &rtl8723au_init_recv_priv;
+	pHalFunc->free_recv_priv =3D &rtl8723au_free_recv_priv;
+	pHalFunc->InitSwLeds =3D NULL;
+	pHalFunc->DeInitSwLeds =3D NULL;
+
+	pHalFunc->init_default_value =3D &rtl8723au_init_default_value;
+	pHalFunc->intf_chip_configure =3D &rtl8723au_interface_configure;
+	pHalFunc->read_adapter_info =3D &ReadAdapterInfo8723AU;
+	pHalFunc->SetHwRegHandler =3D &SetHwReg8723AU;
+	pHalFunc->GetHwRegHandler =3D &GetHwReg8723AU;
+	pHalFunc->GetHalDefVarHandler =3D &GetHalDefVar8192CUsb;
+	pHalFunc->SetHalDefVarHandler =3D &SetHalDefVar8192CUsb;
+	pHalFunc->UpdateRAMaskHandler =3D &UpdateHalRAMask8192CUsb;
+	pHalFunc->hal_xmit =3D &rtl8723au_hal_xmit;
+	pHalFunc->mgnt_xmit =3D &rtl8723au_mgnt_xmit;
+	pHalFunc->hal_xmitframe_enqueue =3D &rtl8723au_hal_xmitframe_enqueue;
+	pHalFunc->interface_ps_func =3D &rtl8192cu_ps_func;
+	rtl8723a_set_hal_ops(pHalFunc);
+	return 0;
+}
diff --git a/drivers/staging/rtl8723au/hal/usb_ops_linux.c b/drivers/st=
aging/rtl8723au/hal/usb_ops_linux.c
new file mode 100644
index 0000000..0311cdf
--- /dev/null
+++ b/drivers/staging/rtl8723au/hal/usb_ops_linux.c
@@ -0,0 +1,848 @@
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
+#define _HCI_OPS_OS_C_
+
+#include <osdep_service.h>
+#include <drv_types.h>
+#include <osdep_intf.h>
+#include <usb_ops.h>
+#include <recv_osdep.h>
+#include <rtl8723a_hal.h>
+#include <rtl8723a_recv.h>
+
+static int usbctrl_vendorreq(struct intf_hdl *pintfhdl, u8 request, u1=
6 value, u16 index, void *pdata, u16 len, u8 requesttype)
+{
+	struct rtw_adapter		*padapter =3D pintfhdl->padapter ;
+	struct dvobj_priv *pdvobjpriv =3D adapter_to_dvobj(padapter);
+	struct usb_device *udev =3D pdvobjpriv->pusbdev;
+
+	unsigned int pipe;
+	int status =3D 0;
+	u8 reqtype;
+	u8 *pIo_buf;
+	int vendorreq_times =3D 0;
+
+	if ((padapter->bSurpriseRemoved) || (padapter->pwrctrlpriv.pnp_bstop_=
trx)) {
+		RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+			 ("usbctrl_vendorreq:(padapter->bSurpriseRemoved||adapter->pwrctrlp=
riv.pnp_bstop_trx)!!!\n"));
+		status =3D -EPERM;
+		goto exit;
+	}
+
+	if (len > MAX_VENDOR_REQ_CMD_SIZE) {
+		DBG_8723A("[%s] Buffer len error , vendor request failed\n", __FUNCT=
ION__);
+		status =3D -EINVAL;
+		goto exit;
+	}
+
+	mutex_lock(&pdvobjpriv->usb_vendor_req_mutex);
+
+	/*  Acquire IO memory for vendorreq */
+	pIo_buf =3D pdvobjpriv->usb_vendor_req_buf;
+
+	if (pIo_buf =3D=3D NULL) {
+		DBG_8723A("[%s] pIo_buf =3D=3D NULL \n", __FUNCTION__);
+		status =3D -ENOMEM;
+		goto release_mutex;
+	}
+
+	while (++vendorreq_times <=3D MAX_USBCTRL_VENDORREQ_TIMES) {
+		memset(pIo_buf, 0, len);
+
+		if (requesttype =3D=3D 0x01) {
+			pipe =3D usb_rcvctrlpipe(udev, 0);/* read_in */
+			reqtype =3D  REALTEK_USB_VENQT_READ;
+		} else {
+			pipe =3D usb_sndctrlpipe(udev, 0);/* write_out */
+			reqtype =3D  REALTEK_USB_VENQT_WRITE;
+			memcpy(pIo_buf, pdata, len);
+		}
+
+		status =3D rtw_usb_control_msg(udev, pipe, request, reqtype,
+					     value, index, pIo_buf, len,
+					     RTW_USB_CONTROL_MSG_TIMEOUT);
+
+		if (status =3D=3D len) {   /*  Success this control transfer. */
+			rtw_reset_continual_urb_error(pdvobjpriv);
+			if (requesttype =3D=3D 0x01) {
+				/* For Control read transfer, we have to copy
+				 * the read data from pIo_buf to pdata.
+				 */
+				memcpy(pdata, pIo_buf,  len);
+			}
+		} else { /*  error cases */
+			DBG_8723A("reg 0x%x, usb %s %u fail, status:%d value =3D"
+				  " 0x%x, vendorreq_times:%d\n",
+				  value, (requesttype =3D=3D 0x01) ? "read" : "write",
+				  len, status, *(u32 *)pdata, vendorreq_times);
+
+			if (status < 0) {
+				if (status =3D=3D (-ESHUTDOWN) || status =3D=3D -ENODEV) {
+					padapter->bSurpriseRemoved =3D true;
+				} else {
+					struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(padapter);
+					pHalData->srestpriv.Wifi_Error_Status =3D USB_VEN_REQ_CMD_FAIL;
+				}
+			} else { /*  status !=3D len && status >=3D 0 */
+				if (status > 0) {
+					if (requesttype =3D=3D 0x01) {
+						/*  For Control read transfer, we have to copy
+						 * the read data from pIo_buf to pdata.
+						 */
+						memcpy(pdata, pIo_buf,  len);
+					}
+				}
+			}
+
+			if (rtw_inc_and_chk_continual_urb_error(pdvobjpriv)) {
+				padapter->bSurpriseRemoved =3D true;
+				break;
+			}
+
+		}
+
+		/*  firmware download is checksumed, don't retry */
+		if ((value >=3D FW_8723A_START_ADDRESS && value <=3D FW_8723A_END_AD=
DRESS) || status =3D=3D len)
+			break;
+	}
+
+release_mutex:
+	mutex_unlock(&pdvobjpriv->usb_vendor_req_mutex);
+exit:
+	return status;
+}
+
+static u8 usb_read8(struct intf_hdl *pintfhdl, u32 addr)
+{
+	u8 request;
+	u8 requesttype;
+	u16 wvalue;
+	u16 index;
+	u16 len;
+	u8 data =3D 0;
+
+	request =3D 0x05;
+	requesttype =3D 0x01;/* read_in */
+	index =3D 0;/* n/a */
+
+	wvalue =3D (u16)(addr&0x0000ffff);
+	len =3D 1;
+
+	usbctrl_vendorreq(pintfhdl, request, wvalue, index, &data, len, reque=
sttype);
+
+	return data;
+}
+
+static u16 usb_read16(struct intf_hdl *pintfhdl, u32 addr)
+{
+	u8 request;
+	u8 requesttype;
+	u16 wvalue;
+	u16 index;
+	u16 len;
+	u16 data =3D 0;
+
+	request =3D 0x05;
+	requesttype =3D 0x01;/* read_in */
+	index =3D 0;/* n/a */
+
+	wvalue =3D (u16)(addr&0x0000ffff);
+	len =3D 2;
+
+	usbctrl_vendorreq(pintfhdl, request, wvalue, index, &data, len, reque=
sttype);
+
+	return data;
+}
+
+static u32 usb_read32(struct intf_hdl *pintfhdl, u32 addr)
+{
+	u8 request;
+	u8 requesttype;
+	u16 wvalue;
+	u16 index;
+	u16 len;
+	u32 data =3D 0;
+
+	request =3D 0x05;
+	requesttype =3D 0x01;/* read_in */
+	index =3D 0;/* n/a */
+
+	wvalue =3D (u16)(addr&0x0000ffff);
+	len =3D 4;
+
+	usbctrl_vendorreq(pintfhdl, request, wvalue, index, &data, len, reque=
sttype);
+
+	return data;
+}
+
+static int usb_write8(struct intf_hdl *pintfhdl, u32 addr, u8 val)
+{
+	u8 request;
+	u8 requesttype;
+	u16 wvalue;
+	u16 index;
+	u16 len;
+	u8 data;
+	int ret;
+
+	request =3D 0x05;
+	requesttype =3D 0x00;/* write_out */
+	index =3D 0;/* n/a */
+
+	wvalue =3D (u16)(addr&0x0000ffff);
+	len =3D 1;
+
+	data =3D val;
+
+	ret =3D usbctrl_vendorreq(pintfhdl, request, wvalue, index, &data, le=
n, requesttype);
+
+	return ret;
+}
+
+static int usb_write16(struct intf_hdl *pintfhdl, u32 addr, u16 val)
+{
+	u8 request;
+	u8 requesttype;
+	u16 wvalue;
+	u16 index;
+	u16 len;
+	u16 data;
+	int ret;
+
+	request =3D 0x05;
+	requesttype =3D 0x00;/* write_out */
+	index =3D 0;/* n/a */
+
+	wvalue =3D (u16)(addr&0x0000ffff);
+	len =3D 2;
+
+	data =3D val;
+
+	ret =3D usbctrl_vendorreq(pintfhdl, request, wvalue, index, &data, le=
n, requesttype);
+	return ret;
+}
+
+static int usb_write32(struct intf_hdl *pintfhdl, u32 addr, u32 val)
+{
+	u8 request;
+	u8 requesttype;
+	u16 wvalue;
+	u16 index;
+	u16 len;
+	u32 data;
+	int ret;
+
+	request =3D 0x05;
+	requesttype =3D 0x00;/* write_out */
+	index =3D 0;/* n/a */
+
+	wvalue =3D (u16)(addr&0x0000ffff);
+	len =3D 4;
+	data =3D val;
+
+	ret =3D usbctrl_vendorreq(pintfhdl, request, wvalue, index, &data, le=
n, requesttype);
+
+	return ret;
+}
+
+static int usb_writeN(struct intf_hdl *pintfhdl, u32 addr, u32 length,=
 u8 *pdata)
+{
+	u8 request;
+	u8 requesttype;
+	u16 wvalue;
+	u16 index;
+	u16 len;
+	u8 buf[VENDOR_CMD_MAX_DATA_LEN] =3D {0};
+	int ret;
+
+	request =3D 0x05;
+	requesttype =3D 0x00;/* write_out */
+	index =3D 0;/* n/a */
+
+	wvalue =3D (u16)(addr&0x0000ffff);
+	len =3D length;
+	 memcpy(buf, pdata, len);
+
+	ret =3D usbctrl_vendorreq(pintfhdl, request, wvalue, index, buf, len,=
 requesttype);
+
+	return ret;
+}
+
+/*
+ * Description:
+ *	Recognize the interrupt content by reading the interrupt
+ *	register or content and masking interrupt mask (IMR)
+ *	if it is our NIC's interrupt. After recognizing, we may clear
+ *	the all interrupts (ISR).
+ * Arguments:
+ *	[in] Adapter -
+ *		The adapter context.
+ *	[in] pContent -
+ *		Under PCI interface, this field is ignord.
+ *		Under USB interface, the content is the interrupt
+ *		content pointer.
+ *		Under SDIO interface, this is the interrupt type which
+ *		is Local interrupt or system interrupt.
+ *	[in] ContentLen -
+ *		The length in byte of pContent.
+ * Return:
+ *	If any interrupt matches the mask (IMR), return true, and
+ *	return false otherwise.
+ */
+static bool
+InterruptRecognized8723AU(struct rtw_adapter *Adapter, void *pContent,
+			  u32 ContentLen)
+{
+	struct hal_data_8723a	*pHalData =3D GET_HAL_DATA(Adapter);
+	u8 *buffer =3D (u8 *)pContent;
+	struct reportpwrstate_parm report;
+
+	memcpy(&pHalData->IntArray[0], &buffer[USB_INTR_CONTENT_HISR_OFFSET],
+	       4);
+	pHalData->IntArray[0] &=3D pHalData->IntrMask[0];
+
+	/* For HISR extension. Added by tynli. 2009.10.07. */
+	memcpy(&pHalData->IntArray[1],
+	       &buffer[USB_INTR_CONTENT_HISRE_OFFSET], 4);
+	pHalData->IntArray[1] &=3D pHalData->IntrMask[1];
+
+	/* We sholud remove this function later because DDK suggest
+	 * not to executing too many operations in MPISR  */
+
+	memcpy(&report.state, &buffer[USB_INTR_CPWM_OFFSET], 1);
+
+	return ((pHalData->IntArray[0])&pHalData->IntrMask[0]) !=3D 0 ||
+		((pHalData->IntArray[1])&pHalData->IntrMask[1]) !=3D 0;
+}
+
+static void usb_read_interrupt_complete(struct urb *purb, struct pt_re=
gs *regs)
+{
+	int err;
+	struct rtw_adapter *padapter =3D (struct rtw_adapter *)purb->context;
+
+	if (padapter->bSurpriseRemoved || padapter->bDriverStopped ||
+	    padapter->bReadPortCancel) {
+		DBG_8723A("%s() RX Warning! bDriverStopped(%d) OR "
+			  "bSurpriseRemoved(%d) bReadPortCancel(%d)\n",
+			  __FUNCTION__, padapter->bDriverStopped,
+			  padapter->bSurpriseRemoved,
+			  padapter->bReadPortCancel);
+		return;
+	}
+
+	if (purb->status =3D=3D 0) {
+		struct c2h_evt_hdr *c2h_evt;
+
+		c2h_evt =3D (struct c2h_evt_hdr *)purb->transfer_buffer;
+
+		if (purb->actual_length > USB_INTR_CONTENT_LENGTH) {
+			DBG_8723A("usb_read_interrupt_complete: purb->actual_"
+				  "length > USB_INTR_CONTENT_LENGTH\n");
+			goto urb_submit;
+		}
+
+		InterruptRecognized8723AU(padapter, purb->transfer_buffer,
+					  purb->actual_length);
+
+		if (c2h_evt_exist(c2h_evt)) {
+			if (c2h_id_filter_ccx_8723a(c2h_evt->id)) {
+				/* Handle CCX report here */
+				handle_txrpt_ccx_8723a(padapter, (void *)(c2h_evt->payload));
+				/* Replace with special pointer to
+				   trigger c2h_evt_clear23a */
+				if (rtw_cbuf_push23a(padapter->evtpriv.c2h_queue,
+						  (void *)&padapter->evtpriv) !=3D
+				    _SUCCESS)
+					DBG_8723A("%s rtw_cbuf_push23a fail\n",
+						  __func__);
+				schedule_work(&padapter->evtpriv.c2h_wk);
+			} else if ((c2h_evt =3D (struct c2h_evt_hdr *)
+				    kmalloc(16, GFP_ATOMIC))) {
+				memcpy(c2h_evt, purb->transfer_buffer, 16);
+				if (rtw_cbuf_push23a(padapter->evtpriv.c2h_queue,
+						  (void *)c2h_evt) !=3D _SUCCESS)
+					DBG_8723A("%s rtw_cbuf_push23a fail\n",
+						  __func__);
+				schedule_work(&padapter->evtpriv.c2h_wk);
+			} else {
+				/* Error handling for malloc fail */
+				if (rtw_cbuf_push23a(padapter->evtpriv.c2h_queue,
+						  (void *)NULL) !=3D _SUCCESS)
+					DBG_8723A("%s rtw_cbuf_push23a fail\n",
+						  __func__);
+				schedule_work(&padapter->evtpriv.c2h_wk);
+			}
+		}
+
+urb_submit:
+		err =3D usb_submit_urb(purb, GFP_ATOMIC);
+		if (err && (err !=3D -EPERM)) {
+			DBG_8723A("cannot submit interrupt in-token(err =3D "
+				  "0x%08x), urb_status =3D %d\n",
+				  err, purb->status);
+		}
+	} else {
+		DBG_8723A("###=3D> usb_read_interrupt_complete =3D> urb "
+			  "status(%d)\n", purb->status);
+
+		switch (purb->status) {
+		case -EINVAL:
+		case -EPIPE:
+		case -ENODEV:
+		case -ESHUTDOWN:
+			RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+				 ("usb_read_port_complete:bSurpriseRemoved =3D"
+				  "true\n"));
+			/* Fall Through here */
+		case -ENOENT:
+			padapter->bDriverStopped =3D true;
+			RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+				 ("usb_read_port_complete:bDriverStopped =3D"
+				  "true\n"));
+			break;
+		case -EPROTO:
+			break;
+		case -EINPROGRESS:
+			DBG_8723A("ERROR: URB IS IN PROGRESS!/n");
+			break;
+		default:
+			break;
+		}
+	}
+}
+
+static u32 usb_read_interrupt(struct intf_hdl *pintfhdl, u32 addr)
+{
+	int err;
+	unsigned int pipe;
+	u32 ret =3D _SUCCESS;
+	struct rtw_adapter *adapter =3D pintfhdl->padapter;
+	struct dvobj_priv *pdvobj =3D adapter_to_dvobj(adapter);
+	struct recv_priv *precvpriv =3D &adapter->recvpriv;
+	struct usb_device *pusbd =3D pdvobj->pusbdev;
+
+	/* translate DMA FIFO addr to pipehandle */
+	pipe =3D ffaddr2pipehdl23a(pdvobj, addr);
+
+	usb_fill_int_urb(precvpriv->int_in_urb, pusbd, pipe,
+			 precvpriv->int_in_buf, USB_INTR_CONTENT_LENGTH,
+			 usb_read_interrupt_complete, adapter, 1);
+
+	err =3D usb_submit_urb(precvpriv->int_in_urb, GFP_ATOMIC);
+	if (err && (err !=3D -EPERM)) {
+		DBG_8723A("cannot submit interrupt in-token(err =3D 0x%08x),"
+			  "urb_status =3D %d\n", err,
+			  precvpriv->int_in_urb->status);
+		ret =3D _FAIL;
+	}
+
+	return ret;
+}
+
+static int recvbuf2recvframe(struct rtw_adapter *padapter, struct sk_b=
uff *pskb)
+{
+	u8	*pbuf;
+	u8	shift_sz =3D 0;
+	u16	pkt_cnt;
+	u32	pkt_offset, skb_len, alloc_sz;
+	s32	transfer_len;
+	struct recv_stat	*prxstat;
+	struct phy_stat	*pphy_info =3D NULL;
+	struct sk_buff		*pkt_copy =3D NULL;
+	struct recv_frame	*precvframe =3D NULL;
+	struct rx_pkt_attrib	*pattrib =3D NULL;
+	struct recv_priv	*precvpriv =3D &padapter->recvpriv;
+	struct rtw_queue	*pfree_recv_queue =3D &precvpriv->free_recv_queue;
+
+	transfer_len =3D (s32)pskb->len;
+	pbuf =3D pskb->data;
+
+	prxstat =3D (struct recv_stat *)pbuf;
+	pkt_cnt =3D (le32_to_cpu(prxstat->rxdw2) >> 16) & 0xff;
+
+	do {
+		RT_TRACE(_module_rtl871x_recv_c_, _drv_info_,
+			 ("recvbuf2recvframe: rxdesc =3D offsset 0:0x%08x, "
+			  "4:0x%08x, 8:0x%08x, C:0x%08x\n", prxstat->rxdw0,
+			  prxstat->rxdw1, prxstat->rxdw2, prxstat->rxdw4));
+
+		prxstat =3D (struct recv_stat *)pbuf;
+
+		precvframe =3D rtw_alloc_recvframe23a(pfree_recv_queue);
+		if (!precvframe) {
+			RT_TRACE(_module_rtl871x_recv_c_, _drv_err_,
+				 ("recvbuf2recvframe: precvframe =3D=3D NULL\n"));
+			DBG_8723A("%s()-%d: rtw_alloc_recvframe23a() failed! RX "
+				  "Drop!\n", __FUNCTION__, __LINE__);
+			goto _exit_recvbuf2recvframe;
+		}
+
+		INIT_LIST_HEAD(&precvframe->list);
+
+		update_recvframe_attrib(precvframe, prxstat);
+
+		pattrib =3D &precvframe->attrib;
+
+		if (pattrib->crc_err) {
+			DBG_8723A("%s()-%d: RX Warning! rx CRC ERROR !!\n",
+				  __FUNCTION__, __LINE__);
+			rtw_free_recvframe23a(precvframe, pfree_recv_queue);
+			goto _exit_recvbuf2recvframe;
+		}
+
+		pkt_offset =3D RXDESC_SIZE + pattrib->drvinfo_sz +
+			pattrib->shift_sz + pattrib->pkt_len;
+
+		if ((pattrib->pkt_len <=3D 0) || (pkt_offset > transfer_len)) {
+			RT_TRACE(_module_rtl871x_recv_c_, _drv_info_,
+				 ("recvbuf2recvframe: pkt_len<=3D 0\n"));
+			DBG_8723A("%s()-%d: RX Warning!\n",
+				  __FUNCTION__, __LINE__);
+			rtw_free_recvframe23a(precvframe, pfree_recv_queue);
+			goto _exit_recvbuf2recvframe;
+		}
+
+		/*	Modified by Albert 20101213 */
+		/*	For 8 bytes IP header alignment. */
+		/*	Qos data, wireless lan header length is 26 */
+		if (pattrib->qos) {
+			shift_sz =3D 6;
+		} else {
+			shift_sz =3D 0;
+		}
+
+		skb_len =3D pattrib->pkt_len;
+
+		/* for first fragment packet, driver need allocate
+		 * 1536+drvinfo_sz+RXDESC_SIZE to defrag packet.
+		 * modify alloc_sz for recvive crc error packet
+		 * by thomas 2011-06-02 */
+		if ((pattrib->mfrag =3D=3D 1) && (pattrib->frag_num =3D=3D 0)) {
+			/* alloc_sz =3D 1664;	1664 is 128 alignment. */
+			if (skb_len <=3D 1650)
+				alloc_sz =3D 1664;
+			else
+				alloc_sz =3D skb_len + 14;
+		} else {
+			alloc_sz =3D skb_len;
+		/*  6 is for IP header 8 bytes alignment in QoS packet case. */
+		/*  8 is for skb->data 4 bytes alignment. */
+			alloc_sz +=3D 14;
+		}
+
+		pkt_copy =3D netdev_alloc_skb(padapter->pnetdev, alloc_sz);
+		if (pkt_copy) {
+			pkt_copy->dev =3D padapter->pnetdev;
+			precvframe->pkt =3D pkt_copy;
+			skb_reserve(pkt_copy, 8 - ((unsigned long)(pkt_copy->data) & 7));/*=
 force pkt_copy->data at 8-byte alignment address */
+	/*force ip_hdr at 8-byte alignment address according to shift_sz. */
+			skb_reserve(pkt_copy, shift_sz);
+			memcpy(pkt_copy->data, (pbuf + pattrib->shift_sz + pattrib->drvinfo=
_sz + RXDESC_SIZE), skb_len);
+			skb_put(pkt_copy, skb_len);
+		} else {
+			if ((pattrib->mfrag =3D=3D 1) && (pattrib->frag_num =3D=3D 0)) {
+				DBG_8723A("recvbuf2recvframe: alloc_skb fail, "
+					  "drop frag frame \n");
+				rtw_free_recvframe23a(precvframe,
+						   pfree_recv_queue);
+				goto _exit_recvbuf2recvframe;
+			}
+
+			precvframe->pkt =3D skb_clone(pskb, GFP_ATOMIC);
+			if (!precvframe->pkt) {
+				DBG_8723A("recvbuf2recvframe: skb_clone "
+					  "fail\n");
+				rtw_free_recvframe23a(precvframe,
+						   pfree_recv_queue);
+				goto _exit_recvbuf2recvframe;
+			}
+		}
+
+		if (pattrib->physt) {
+			pphy_info =3D (struct phy_stat *)(pbuf + RXDESC_OFFSET);
+			update_recvframe_phyinfo(precvframe, pphy_info);
+		}
+
+		if (rtw_recv_entry23a(precvframe) !=3D _SUCCESS)
+			RT_TRACE(_module_rtl871x_recv_c_, _drv_err_,
+				 ("recvbuf2recvframe: rtw_recv_entry23a"
+				  "(precvframe) !=3D _SUCCESS\n"));
+
+		pkt_cnt--;
+		transfer_len -=3D pkt_offset;
+		pbuf +=3D pkt_offset;
+		precvframe =3D NULL;
+		pkt_copy =3D NULL;
+
+		if (transfer_len > 0 && pkt_cnt =3D=3D 0)
+			pkt_cnt =3D (le32_to_cpu(prxstat->rxdw2)>>16) & 0xff;
+
+	} while ((transfer_len > 0) && (pkt_cnt > 0));
+
+_exit_recvbuf2recvframe:
+
+	return _SUCCESS;
+}
+
+void rtl8723au_recv_tasklet(void *priv)
+{
+	struct sk_buff *pskb;
+	struct rtw_adapter *padapter =3D (struct rtw_adapter *)priv;
+	struct recv_priv *precvpriv =3D &padapter->recvpriv;
+
+	while (NULL !=3D (pskb =3D skb_dequeue(&precvpriv->rx_skb_queue))) {
+		if ((padapter->bDriverStopped) ||
+		    (padapter->bSurpriseRemoved)) {
+			DBG_8723A("recv_tasklet =3D> bDriverStopped or "
+				  "bSurpriseRemoved \n");
+			dev_kfree_skb_any(pskb);
+			break;
+		}
+
+		recvbuf2recvframe(padapter, pskb);
+		skb_reset_tail_pointer(pskb);
+
+		pskb->len =3D 0;
+
+		skb_queue_tail(&precvpriv->free_recv_skb_queue, pskb);
+	}
+}
+
+static void usb_read_port_complete(struct urb *purb, struct pt_regs *r=
egs)
+{
+	struct recv_buf *precvbuf =3D (struct recv_buf *)purb->context;
+	struct rtw_adapter *padapter =3D (struct rtw_adapter *)precvbuf->adap=
ter;
+	struct recv_priv *precvpriv =3D &padapter->recvpriv;
+	struct hal_data_8723a *pHalData;
+
+	RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+		 ("usb_read_port_complete!!!\n"));
+
+	precvpriv->rx_pending_cnt--;
+
+	if (padapter->bSurpriseRemoved || padapter->bDriverStopped ||
+	    padapter->bReadPortCancel) {
+		RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+			 ("usb_read_port_complete:bDriverStopped(%d) OR "
+			  "bSurpriseRemoved(%d)\n", padapter->bDriverStopped,
+			  padapter->bSurpriseRemoved));
+
+		DBG_8723A("%s()-%d: RX Warning! bDriverStopped(%d) OR "
+			  "bSurpriseRemoved(%d) bReadPortCancel(%d)\n",
+			  __FUNCTION__, __LINE__, padapter->bDriverStopped,
+			  padapter->bSurpriseRemoved, padapter->bReadPortCancel);
+		return;
+	}
+
+	if (purb->status =3D=3D 0) {
+		if ((purb->actual_length > MAX_RECVBUF_SZ) ||
+		    (purb->actual_length < RXDESC_SIZE)) {
+			RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+				 ("usb_read_port_complete: (purb->actual_"
+				  "length > MAX_RECVBUF_SZ) || (purb->actual_"
+				  "length < RXDESC_SIZE)\n"));
+			rtw_read_port(padapter, precvpriv->ff_hwaddr, 0,
+				      precvbuf);
+			DBG_8723A("%s()-%d: RX Warning!\n",
+				  __FUNCTION__, __LINE__);
+		} else {
+			rtw_reset_continual_urb_error(
+				adapter_to_dvobj(padapter));
+
+			skb_put(precvbuf->pskb, purb->actual_length);
+			skb_queue_tail(&precvpriv->rx_skb_queue,
+				       precvbuf->pskb);
+
+			if (skb_queue_len(&precvpriv->rx_skb_queue) <=3D 1)
+				tasklet_schedule(&precvpriv->recv_tasklet);
+
+			precvbuf->pskb =3D NULL;
+			rtw_read_port(padapter, precvpriv->ff_hwaddr, 0,
+				      precvbuf);
+		}
+	} else {
+		RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+			 ("usb_read_port_complete : purb->status(%d) !=3D 0 \n",
+			  purb->status));
+		skb_put(precvbuf->pskb, purb->actual_length);
+		precvbuf->pskb =3D NULL;
+
+		DBG_8723A("###=3D> usb_read_port_complete =3D> urb status(%d)\n",
+			  purb->status);
+
+		if (rtw_inc_and_chk_continual_urb_error(
+			    adapter_to_dvobj(padapter))) {
+			padapter->bSurpriseRemoved =3D true;
+		}
+
+		switch (purb->status) {
+		case -EINVAL:
+		case -EPIPE:
+		case -ENODEV:
+		case -ESHUTDOWN:
+			RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+				 ("usb_read_port_complete:bSurprise"
+				  "Removed =3D true\n"));
+			/* Intentional fall through here */
+		case -ENOENT:
+			padapter->bDriverStopped =3D true;
+			RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+				 ("usb_read_port_complete:"
+				  "bDriverStopped =3D true\n"));
+			break;
+		case -EPROTO:
+		case -EOVERFLOW:
+			pHalData =3D GET_HAL_DATA(padapter);
+			pHalData->srestpriv.Wifi_Error_Status =3D
+				USB_READ_PORT_FAIL;
+			rtw_read_port(padapter, precvpriv->ff_hwaddr,
+				      0, precvbuf);
+			break;
+		case -EINPROGRESS:
+			DBG_8723A("ERROR: URB IS IN PROGRESS!/n");
+			break;
+		default:
+			break;
+		}
+
+	}
+}
+
+static u32 usb_read_port(struct intf_hdl *pintfhdl, u32 addr, u32 cnt,
+			 struct recv_buf *precvbuf)
+{
+	int err;
+	unsigned int pipe;
+	unsigned long tmpaddr =3D 0;
+	unsigned long alignment =3D 0;
+	u32 ret =3D _SUCCESS;
+	struct urb *purb =3D NULL;
+	struct rtw_adapter		*adapter =3D pintfhdl->padapter;
+	struct dvobj_priv	*pdvobj =3D adapter_to_dvobj(adapter);
+	struct recv_priv	*precvpriv =3D &adapter->recvpriv;
+	struct usb_device	*pusbd =3D pdvobj->pusbdev;
+
+	if (adapter->bDriverStopped || adapter->bSurpriseRemoved ||
+	    adapter->pwrctrlpriv.pnp_bstop_trx) {
+		RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+			 ("usb_read_port:(padapter->bDriverStopped ||"
+			  "padapter->bSurpriseRemoved ||adapter->"
+			  "pwrctrlpriv.pnp_bstop_trx)!!!\n"));
+		return _FAIL;
+	}
+
+	if (!precvbuf) {
+		RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+			 ("usb_read_port:precvbuf =3D=3D NULL\n"));
+		return _FAIL;
+	}
+
+	if (!precvbuf->pskb)
+		precvbuf->pskb =3D skb_dequeue(&precvpriv->free_recv_skb_queue);
+
+	rtl8723au_init_recvbuf(adapter, precvbuf);
+
+	/* re-assign for linux based on skb */
+	if (!precvbuf->pskb) {
+		precvbuf->pskb =3D netdev_alloc_skb(adapter->pnetdev, MAX_RECVBUF_SZ=
 + RECVBUFF_ALIGN_SZ);
+		if (precvbuf->pskb =3D=3D NULL) {
+			RT_TRACE(_module_hci_ops_os_c_, _drv_err_, ("init_recvbuf(): alloc_=
skb fail!\n"));
+			return _FAIL;
+		}
+
+		tmpaddr =3D (unsigned long)precvbuf->pskb->data;
+		alignment =3D tmpaddr & (RECVBUFF_ALIGN_SZ-1);
+		skb_reserve(precvbuf->pskb, (RECVBUFF_ALIGN_SZ - alignment));
+	}
+
+	precvpriv->rx_pending_cnt++;
+
+	purb =3D precvbuf->purb;
+
+	/* translate DMA FIFO addr to pipehandle */
+	pipe =3D ffaddr2pipehdl23a(pdvobj, addr);
+
+	usb_fill_bulk_urb(purb, pusbd, pipe, precvbuf->pskb->data,
+			  MAX_RECVBUF_SZ, usb_read_port_complete,
+			  precvbuf);/* context is precvbuf */
+
+	err =3D usb_submit_urb(purb, GFP_ATOMIC);
+	if ((err) && (err !=3D -EPERM)) {
+		RT_TRACE(_module_hci_ops_os_c_, _drv_err_,
+			 ("cannot submit rx in-token(err =3D 0x%.8x), URB_STATUS "
+			  "=3D 0x%.8x", err, purb->status));
+		DBG_8723A("cannot submit rx in-token(err =3D 0x%08x), urb_status "
+			  "=3D %d\n", err, purb->status);
+		ret =3D _FAIL;
+	}
+	return ret;
+}
+
+void rtl8723au_xmit_tasklet(void *priv)
+{
+	int ret =3D false;
+	struct rtw_adapter *padapter =3D (struct rtw_adapter *)priv;
+	struct xmit_priv *pxmitpriv =3D &padapter->xmitpriv;
+
+	if (check_fwstate(&padapter->mlmepriv, _FW_UNDER_SURVEY))
+		return;
+
+	while (1) {
+		if ((padapter->bDriverStopped) ||
+		    (padapter->bSurpriseRemoved) ||
+		    (padapter->bWritePortCancel)) {
+			DBG_8723A("xmit_tasklet =3D> bDriverStopped or "
+				  "bSurpriseRemoved or bWritePortCancel\n");
+			break;
+		}
+
+		ret =3D rtl8723au_xmitframe_complete(padapter, pxmitpriv, NULL);
+
+		if (!ret)
+			break;
+	}
+}
+
+void rtl8723au_set_intf_ops(struct _io_ops *pops)
+{
+
+	memset((u8 *)pops, 0, sizeof(struct _io_ops));
+
+	pops->_read8 =3D &usb_read8;
+	pops->_read16 =3D &usb_read16;
+	pops->_read32 =3D &usb_read32;
+	pops->_read_mem =3D &usb_read_mem23a;
+	pops->_read_port =3D &usb_read_port;
+
+	pops->_write8 =3D &usb_write8;
+	pops->_write16 =3D &usb_write16;
+	pops->_write32 =3D &usb_write32;
+	pops->_writeN =3D &usb_writeN;
+
+	pops->_write_mem =3D &usb_write_mem23a;
+	pops->_write_port =3D &usb_write_port23a;
+
+	pops->_read_port_cancel =3D &usb_read_port_cancel23a;
+	pops->_write_port_cancel =3D &usb_write_port23a_cancel;
+
+	pops->_read_interrupt =3D &usb_read_interrupt;
+}
+
+void rtl8723au_set_hw_type(struct rtw_adapter *padapter)
+{
+	padapter->chip_type =3D RTL8723A;
+	padapter->HardwareType =3D HARDWARE_TYPE_RTL8723AU;
+	DBG_8723A("CHIP TYPE: RTL8723A\n");
+}
--=20
1.8.4.5
