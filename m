From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 14/31] staging: r8188eu: Remove macro ODM_SetRFReg
Date: Sun, 22 Dec 2013 17:36:45 -0600
Message-ID: <1387755422-11443-15-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:44009 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756772Ab3LVXiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:38:07 -0500
Received: by mail-pd0-f178.google.com with SMTP id y10so4570434pdj.9
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 15:38:07 -0800 (PST)
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is a duplicate of macro PHY_SetRFReg.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c     | 32 +++++++++++-----------
 drivers/staging/rtl8188eu/hal/odm.c                |  8 +++---
 drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c |  6 ++--
 drivers/staging/rtl8188eu/hal/odm_interface.c      |  6 ----
 drivers/staging/rtl8188eu/include/odm_interface.h  |  3 --
 5 files changed, 24 insertions(+), 31 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
index 1dbe601..9552e4f 100644
--- a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
+++ b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
@@ -534,14 +534,14 @@ phy_PathA_RxIQK(struct adapter *adapt, bool configPathB)
 	/* modify RXIQK mode table */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("Path-A Rx IQK modify RXIQK mode table!\n"));
 	PHY_SetBBReg(adapt, rFPGA0_IQK, bMaskDWord, 0x00000000);
-	ODM_SetRFReg(dm_odm, RF_PATH_A, RF_WE_LUT, bRFRegOffsetMask, 0x800a0);
-	ODM_SetRFReg(dm_odm, RF_PATH_A, RF_RCK_OS, bRFRegOffsetMask, 0x30000);
-	ODM_SetRFReg(dm_odm, RF_PATH_A, RF_TXPA_G1, bRFRegOffsetMask, 0x0000f);
-	ODM_SetRFReg(dm_odm, RF_PATH_A, RF_TXPA_G2, bRFRegOffsetMask, 0xf117B);
+	PHY_SetRFReg(adapt, RF_PATH_A, RF_WE_LUT, bRFRegOffsetMask, 0x800a0);
+	PHY_SetRFReg(adapt, RF_PATH_A, RF_RCK_OS, bRFRegOffsetMask, 0x30000);
+	PHY_SetRFReg(adapt, RF_PATH_A, RF_TXPA_G1, bRFRegOffsetMask, 0x0000f);
+	PHY_SetRFReg(adapt, RF_PATH_A, RF_TXPA_G2, bRFRegOffsetMask, 0xf117B);
 
 	/* PA,PAD off */
-	ODM_SetRFReg(dm_odm, RF_PATH_A, 0xdf, bRFRegOffsetMask, 0x980);
-	ODM_SetRFReg(dm_odm, RF_PATH_A, 0x56, bRFRegOffsetMask, 0x51000);
+	PHY_SetRFReg(adapt, RF_PATH_A, 0xdf, bRFRegOffsetMask, 0x980);
+	PHY_SetRFReg(adapt, RF_PATH_A, 0x56, bRFRegOffsetMask, 0x51000);
 
 	PHY_SetBBReg(adapt, rFPGA0_IQK, bMaskDWord, 0x80800000);
 
@@ -596,10 +596,10 @@ phy_PathA_RxIQK(struct adapter *adapt, bool configPathB)
 	/* modify RXIQK mode table */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("Path-A Rx IQK modify RXIQK mode table 2!\n"));
 	PHY_SetBBReg(adapt, rFPGA0_IQK, bMaskDWord, 0x00000000);
-	ODM_SetRFReg(dm_odm, RF_PATH_A, RF_WE_LUT, bRFRegOffsetMask, 0x800a0);
-	ODM_SetRFReg(dm_odm, RF_PATH_A, RF_RCK_OS, bRFRegOffsetMask, 0x30000);
-	ODM_SetRFReg(dm_odm, RF_PATH_A, RF_TXPA_G1, bRFRegOffsetMask, 0x0000f);
-	ODM_SetRFReg(dm_odm, RF_PATH_A, RF_TXPA_G2, bRFRegOffsetMask, 0xf7ffa);
+	PHY_SetRFReg(adapt, RF_PATH_A, RF_WE_LUT, bRFRegOffsetMask, 0x800a0);
+	PHY_SetRFReg(adapt, RF_PATH_A, RF_RCK_OS, bRFRegOffsetMask, 0x30000);
+	PHY_SetRFReg(adapt, RF_PATH_A, RF_TXPA_G1, bRFRegOffsetMask, 0x0000f);
+	PHY_SetRFReg(adapt, RF_PATH_A, RF_TXPA_G2, bRFRegOffsetMask, 0xf7ffa);
 	PHY_SetBBReg(adapt, rFPGA0_IQK, bMaskDWord, 0x80800000);
 
 	/* IQK setting */
@@ -637,7 +637,7 @@ phy_PathA_RxIQK(struct adapter *adapt, bool configPathB)
 
 	/* reload RF 0xdf */
 	PHY_SetBBReg(adapt, rFPGA0_IQK, bMaskDWord, 0x00000000);
-	ODM_SetRFReg(dm_odm, RF_PATH_A, 0xdf, bRFRegOffsetMask, 0x180);
+	PHY_SetRFReg(adapt, RF_PATH_A, 0xdf, bRFRegOffsetMask, 0x180);
 
 	if (!(regeac & BIT27) &&		/* if Tx is OK, check whether Rx is OK */
 	    (((regEA4 & 0x03FF0000)>>16) != 0x132) &&
@@ -1245,18 +1245,18 @@ static void phy_LCCalibrate_8188E(struct adapter *adapt, bool is2t)
 
 		/* 2. Set RF mode = standby mode */
 		/* Path-A */
-		ODM_SetRFReg(dm_odm, RF_PATH_A, RF_AC, bMask12Bits, (RF_Amode&0x8FFFF)|0x10000);
+		PHY_SetRFReg(adapt, RF_PATH_A, RF_AC, bMask12Bits, (RF_Amode&0x8FFFF)|0x10000);
 
 		/* Path-B */
 		if (is2t)
-			ODM_SetRFReg(dm_odm, RF_PATH_B, RF_AC, bMask12Bits, (RF_Bmode&0x8FFFF)|0x10000);
+			PHY_SetRFReg(adapt, RF_PATH_B, RF_AC, bMask12Bits, (RF_Bmode&0x8FFFF)|0x10000);
 	}
 
 	/* 3. Read RF reg18 */
 	LC_Cal = PHY_QueryRFReg(adapt, RF_PATH_A, RF_CHNLBW, bMask12Bits);
 
 	/* 4. Set LC calibration begin	bit15 */
-	ODM_SetRFReg(dm_odm, RF_PATH_A, RF_CHNLBW, bMask12Bits, LC_Cal|0x08000);
+	PHY_SetRFReg(adapt, RF_PATH_A, RF_CHNLBW, bMask12Bits, LC_Cal|0x08000);
 
 	msleep(100);
 
@@ -1265,11 +1265,11 @@ static void phy_LCCalibrate_8188E(struct adapter *adapt, bool is2t)
 		/* Deal with continuous TX case */
 		/* Path-A */
 		ODM_Write1Byte(dm_odm, 0xd03, tmpreg);
-		ODM_SetRFReg(dm_odm, RF_PATH_A, RF_AC, bMask12Bits, RF_Amode);
+		PHY_SetRFReg(adapt, RF_PATH_A, RF_AC, bMask12Bits, RF_Amode);
 
 		/* Path-B */
 		if (is2t)
-			ODM_SetRFReg(dm_odm, RF_PATH_B, RF_AC, bMask12Bits, RF_Bmode);
+			PHY_SetRFReg(adapt, RF_PATH_B, RF_AC, bMask12Bits, RF_Bmode);
 	} else {
 		/*  Deal with Packet TX case */
 		ODM_Write1Byte(dm_odm, REG_TXPAUSE, 0x00);
diff --git a/drivers/staging/rtl8188eu/hal/odm.c b/drivers/staging/rtl8188eu/hal/odm.c
index 18d3a00..00b0675 100644
--- a/drivers/staging/rtl8188eu/hal/odm.c
+++ b/drivers/staging/rtl8188eu/hal/odm.c
@@ -2012,7 +2012,7 @@ bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
 	PHY_SetBBReg(adapter, rFPGA0_PSDFunction, BIT14|BIT15, 0x0);  /* 128 pts */
 
 	/*  To SET CH1 to do */
-	ODM_SetRFReg(pDM_Odm, RF_PATH_A, ODM_CHANNEL, bRFRegOffsetMask, 0x01);     /* Channel 1 */
+	PHY_SetRFReg(adapter, RF_PATH_A, ODM_CHANNEL, bRFRegOffsetMask, 0x01);     /* Channel 1 */
 
 	/*  AFE all on step */
 	PHY_SetBBReg(adapter, rRx_Wait_CCA, bMaskDWord, 0x6FDB25A4);
@@ -2054,7 +2054,7 @@ bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
 	PHY_SetBBReg(adapter, rIQK_AGC_Rsp, bMaskDWord, 0x001028d0);
 
 	/* RF loop Setting */
-	ODM_SetRFReg(pDM_Odm, RF_PATH_A, 0x0, 0xFFFFF, 0x50008);
+	PHY_SetRFReg(adapter, RF_PATH_A, 0x0, 0xFFFFF, 0x50008);
 
 	/* IQK Single tone start */
 	PHY_SetBBReg(adapter, rFPGA0_IQK, bMaskDWord, 0x80800000);
@@ -2101,8 +2101,8 @@ bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
 	PHY_SetBBReg(adapter, rFPGA0_XCD_RFInterfaceSW, bMaskDWord, Reg874);
 	PHY_SetBBReg(adapter, rOFDM0_XAAGCCore1, 0x7F, 0x40);
 	PHY_SetBBReg(adapter, rOFDM0_XAAGCCore1, bMaskDWord, Regc50);
-	ODM_SetRFReg(pDM_Odm, RF_PATH_A, RF_CHNLBW, bRFRegOffsetMask, CurrentChannel);
-	ODM_SetRFReg(pDM_Odm, RF_PATH_A, 0x00, bRFRegOffsetMask, RfLoopReg);
+	PHY_SetRFReg(adapter, RF_PATH_A, RF_CHNLBW, bRFRegOffsetMask, CurrentChannel);
+	PHY_SetRFReg(adapter, RF_PATH_A, 0x00, bRFRegOffsetMask, RfLoopReg);
 
 	/* Reload AFE Registers */
 	odm_PHY_ReloadAFERegisters(pDM_Odm, AFE_REG_8723A, AFE_Backup, 16);
diff --git a/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c b/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
index eae8358..0594e70 100644
--- a/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
+++ b/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
@@ -24,7 +24,9 @@ void odm_ConfigRFReg_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr,
 			   u32 Data, enum ODM_RF_RADIO_PATH RF_PATH,
 			   u32 RegAddr)
 {
-    if (Addr == 0xffe) {
+	struct adapter *adapter = pDM_Odm->Adapter;
+
+	if (Addr == 0xffe) {
 		msleep(50);
 	} else if (Addr == 0xfd) {
 		mdelay(5);
@@ -37,7 +39,7 @@ void odm_ConfigRFReg_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr,
 	} else if (Addr == 0xf9) {
 		udelay(1);
 	} else {
-		ODM_SetRFReg(pDM_Odm, RF_PATH, RegAddr, bRFRegOffsetMask, Data);
+		PHY_SetRFReg(adapter, RF_PATH, RegAddr, bRFRegOffsetMask, Data);
 		/*  Add 1us delay between BB/RF register setting. */
 		udelay(1);
 	}
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index 68a3391..c2c1d55 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -69,12 +69,6 @@ u32 ODM_GetMACReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 BitMask)
 	return PHY_QueryBBReg(Adapter, RegAddr, BitMask);
 }
 
-void ODM_SetRFReg(struct odm_dm_struct *pDM_Odm, enum ODM_RF_RADIO_PATH	eRFPath, u32 RegAddr, u32 BitMask, u32 Data)
-{
-	struct adapter *Adapter = pDM_Odm->Adapter;
-	PHY_SetRFReg(Adapter, (enum rf_radio_path)eRFPath, RegAddr, BitMask, Data);
-}
-
 u32 ODM_GetRFReg(struct odm_dm_struct *pDM_Odm, enum ODM_RF_RADIO_PATH	eRFPath, u32 RegAddr, u32 BitMask)
 {
 	struct adapter *Adapter = pDM_Odm->Adapter;
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index 65493dd..bc13b6a 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -94,9 +94,6 @@ void ODM_SetMACReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr,
 
 u32 ODM_GetMACReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 BitMask);
 
-void ODM_SetRFReg(struct odm_dm_struct *pDM_Odm, enum ODM_RF_RADIO_PATH eRFPath,
-		  u32 RegAddr, u32 BitMask, u32 Data);
-
 u32 ODM_GetRFReg(struct odm_dm_struct *pDM_Odm, enum ODM_RF_RADIO_PATH eRFPath,
 		 u32 RegAddr, u32 BitMask);
 
-- 
1.8.4
