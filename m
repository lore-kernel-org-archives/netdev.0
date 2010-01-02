From: Gregory Petrosyan <gregory.petrosyan@gmail.com>
Subject: sky2: unsupported chip type 0xff failure
Date: Sun, 3 Jan 2010 01:48:58 +0300
Message-ID: <20100102224858.GA17023@gregory-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: stephen hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:57389 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022Ab0ABWtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2010 17:49:18 -0500
Received: by fxm25 with SMTP id 25so7849902fxm.21
        for <netdev@vger.kernel.org>; Sat, 02 Jan 2010 14:49:16 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've got an HP ProBook 5310m laptop with Marvell Ethernet controller. sky2 reports

[14252.318867] sky2 driver version 1.23
[14252.318904] sky2 0000:03:00.0: setting latency timer to 64
[14252.318951] sky2 0000:03:00.0: unsupported chip type 0xff
[14252.318960] sky2: probe of 0000:03:00.0 failed with error -95

(this is captured after 'modprobe -r' + 'modprobe') and I've seen it working
only 1 time (probably after a reboot).

lspci -vvv:

03:00.0 Ethernet controller: Marvell Technology Group Ltd. Device 436c (rev 10)
	Subsystem: Hewlett-Packard Company Device 3634
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR+ <PERR- INTx-
	Latency: 0, Cache Line Size: 1020 bytes
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at 90600000 (64-bit, non-prefetchable) [size=16K]
	Region 2: I/O ports at 2000 [size=256]
	Expansion ROM at 90a00000 [size=128K]
	Capabilities: [48] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] Vital Product Data <?>
	Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [c0] Express (v2) Legacy Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr+ UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <256ns, L1 unlimited
			ClockPM+ Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [100] Advanced Error Reporting <?>
	Capabilities: [130] Device Serial Number 00-26-22-ff-ff-a4-f7-9d
	Kernel modules: sky2

What can I do to make it work?

Note: similar issue has been reported previously [1].

[1] http://lkml.indiana.edu/hypermail/linux/kernel/0806.0/0026.html

	Gregory
