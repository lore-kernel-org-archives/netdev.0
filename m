From: Martin Capitanio <c4p7n@capitanio.org>
Subject: [PATCH] r8169: Increase version number
Date: Tue, 21 Oct 2008 13:40:39 +0200
Message-ID: <1224589239.23443.30.camel@marvin>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:39012 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666AbYJULku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 07:40:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An ubuntu user reported me 8101e success:

[    0.000000] Linux version 2.6.27-7-generic (buildd@palmer) (gcc version 4.3.2 (Ubuntu 4.3.2-1ubuntu10) ) #1 SMP Fri Oct 17 22:24:21 UTC 2008 (Ubuntu 2.6.27-7.12-generic)
[    2.892918] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    2.892971] r8169 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    2.893019] r8169 0000:02:00.0: setting latency timer to 64
[    2.893321] eth0: RTL8101e at 0xf883e000, o.k., XID 34200000 IRQ 221
[   26.652528] r8169: eth0: link up

02:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8101E/RTL8102E PCI Express Fast Ethernet controller [10ec:8136] (rev 01)
	Subsystem: Elitegroup Computer Systems Device [1019:8136]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 221
	Region 0: I/O ports at d800 [size=256]
	Region 2: Memory at feaff000 (64-bit, non-prefetchable) [size=4K]
	Expansion ROM at feac0000 [disabled] [size=128K]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [48] Vital Product Data <?>
	Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ Queue=0/1 Enable+
		Address: 00000000fee0f00c  Data: 41d9
	Capabilities: [60] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <1us, L1 unlimited
			ExtTag+ AttnBtn+ AttnInd+ PwrInd+ RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Latency L0 unlimited, L1 unlimited
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [84] Vendor Specific Information <?>
	Capabilities: [100] Advanced Error Reporting <?>
	Capabilities: [12c] Virtual Channel <?>
	Capabilities: [148] Device Serial Number 36-81-ec-10-00-00-10-64
	Capabilities: [154] Power Budgeting <?>
	Kernel driver in use: r8169
	Kernel modules: r8169

Could you upgrade the version number, to be sure the new 2.6.28
patch-set get applied?

Thanks,
Martin

---
diff --git a/r8169.c b/r8169.c
index 2b4e975..3832141 100644
--- a/r8169.c
+++ b/r8169.c
@@ -28,7 +28,7 @@
 #include <asm/io.h>
 #include <asm/irq.h>
 
-#define RTL8169_VERSION "2.3LK-NAPI"
+#define RTL8169_VERSION "2.4LK-NAPI"
 #define MODULENAME "r8169"
 #define PFX MODULENAME ": "

