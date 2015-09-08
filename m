From: Ben Pope <benpope81@gmail.com>
Subject: [PATCH] alx: Add the Device ID for the Killer E2400 03:00.0 Ethernet
 controller: Qualcomm Atheros Device e0a1 (rev 10) 	Subsystem: Micro-Star
 International Co., Ltd. [MSI] Device 7977 	Control: I/O+ Mem+ BusMaster+
 SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
  Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
 <MAbort- >SERR- <PERR- INTx- 	Latency: 0 	Interrupt: pin A routed to IRQ 325
 	Region 0: Memory at dfc00000 (64-bit, non-prefetchable) [size=256K]  Region
 2: I/O ports at d000 [size=128] 	Capabilities: [40] Power Management version
 3 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
 		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME- 	Capabilities: [58]
 Express (v1) Endpoint, MSI 00 		DevCap:	MaxPayload 4096 bytes, PhantFunc 0,
 Latency L0s unlimited, L1 unlimited 			ExtTag- AttnBtn+
Date: Wed,  9 Sep 2015 01:07:30 +0800
Message-ID: <1441732050-7005-1-git-send-email-benpope81@gmail.com>
Cc: netdev@vger.kernel.org, BenPope <ben@pope.name>
To: jcliburn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35863 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754618AbbIHRHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 13:07:35 -0400
Received: by padhk3 with SMTP id hk3so44127318pad.3
        for <netdev@vger.kernel.org>; Tue, 08 Sep 2015 10:07:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: BenPope <ben@pope.name>

Signed-off-by: BenPope <ben@pope.name>
---
 drivers/net/ethernet/atheros/alx/main.c | 2 ++
 drivers/net/ethernet/atheros/alx/reg.h  | 1 +
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index c8af3ce..bd377a6 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -1534,6 +1534,8 @@ static const struct pci_device_id alx_pci_tbl[] = {
 	  .driver_data = ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_E2200),
 	  .driver_data = ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
+	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_E2400),
+	  .driver_data = ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8162),
 	  .driver_data = ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8171) },
diff --git a/drivers/net/ethernet/atheros/alx/reg.h b/drivers/net/ethernet/atheros/alx/reg.h
index af006b4..0959e68 100644
--- a/drivers/net/ethernet/atheros/alx/reg.h
+++ b/drivers/net/ethernet/atheros/alx/reg.h
@@ -37,6 +37,7 @@
 
 #define ALX_DEV_ID_AR8161				0x1091
 #define ALX_DEV_ID_E2200				0xe091
+#define ALX_DEV_ID_E2400				0xe0a1
 #define ALX_DEV_ID_AR8162				0x1090
 #define ALX_DEV_ID_AR8171				0x10A1
 #define ALX_DEV_ID_AR8172				0x10A0
-- 
2.1.4
