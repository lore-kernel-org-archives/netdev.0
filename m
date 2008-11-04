From: Milan Kocian <milon@wq.cz>
Subject: Re: WARNING: at net/sched/sch_generic.c:219
Date: Tue, 4 Nov 2008 10:39:24 +0100
Message-ID: <20081104093923.GA11658@ntm.vs.lam.cz>
References: <20081103092609.GA8659@ntm.vs.lam.cz> <F169D4F5E1F1974DBFAFABF47F60C10A0E873C1B@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srw1.wq.cz ([212.71.155.176]:39048 "EHLO srw1.wq.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754818AbYKDJji (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 04:39:38 -0500
Content-Disposition: inline
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A0E873C1B@orsmsx507.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 03, 2008 at 10:49:53AM -0800, Brandeburg, Jesse wrote:
> Milan Kocian wrote:
> > hello,
> > 
> > for your info I have here one warning. Kernel 2.6.27.4.
> > Machine have minimal load and traffic (I can say, it does nothing :-).
> > Probably its related to link up/down. (kvm module is only loaded, not
> > used)
> 
> what kind of hardware do you have? lspci -vvv output please.  you're
> running a 64 bit kernel, does it happen to be an AMD system with a
> hypertransport to PCI express bridge and >= 4GB ram?

Thanks for answer.
Its selfcompiled 64bit kernel. Intel CPU QuadCore. SuperMicro mainboard.
2GB RAM, Debian unstable distro.

00:00.0 Host bridge: Intel Corporation E7230/3000/3010 Memory Controller Hub (rev c0)
	Subsystem: Super Micro Computer Inc Device 9180
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information <?>

00:01.0 PCI bridge: Intel Corporation E7230/3000/3010 PCI Express Root Port (rev c0) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=01, subordinate=03, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: e0100000-e01fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [88] Subsystem: Super Micro Computer Inc Device 9180
	Capabilities: [80] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [90] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
		Address: fee0f00c  Data: 4171
	Capabilities: [a0] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #2, Speed 2.5GT/s, Width x8, ASPM L0s, Latency L0 <1us, L1 <4us
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x8, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surpise-
			Slot #1000, PowerLimit 10.000000; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Off, PwrInd On, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Kernel driver in use: pcieport-driver

00:1c.0 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express Port 1 (rev 01) (prog-if 00 [Normal decode])
	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=09, subordinate=09, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #1, Speed 2.5GT/s, Width x4, ASPM L0s L1, Latency L0 <256ns, L1 <4us
			ClockPM- Suprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surpise+
			Slot #  0, PowerLimit 0.000000; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal+ PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
		Address: fee0f00c  Data: 4179
	Capabilities: [90] Subsystem: Super Micro Computer Inc Device 9180
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: pcieport-driver

00:1c.4 PCI bridge: Intel Corporation 82801GR/GH/GHM (ICH7 Family) PCI Express Port 5 (rev 01) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=0d, subordinate=0d, sec-latency=0
	I/O behind bridge: 00004000-00004fff
	Memory behind bridge: e0200000-e02fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #5, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <256ns, L1 <4us
			ClockPM- Suprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surpise+
			Slot #  5, PowerLimit 10.000000; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal+ PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
		Address: fee0f00c  Data: 4181
	Capabilities: [90] Subsystem: Super Micro Computer Inc Device 9180
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: pcieport-driver

00:1c.5 PCI bridge: Intel Corporation 82801GR/GH/GHM (ICH7 Family) PCI Express Port 6 (rev 01) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=0e, subordinate=0e, sec-latency=0
	I/O behind bridge: 00005000-00005fff
	Memory behind bridge: e0300000-e03fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #6, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <256ns, L1 <4us
			ClockPM- Suprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surpise+
			Slot #  6, PowerLimit 10.000000; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal+ PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
		Address: fee0f00c  Data: 4189
	Capabilities: [90] Subsystem: Super Micro Computer Inc Device 9180
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: pcieport-driver

00:1d.0 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #1 (rev 01) (prog-if 00 [UHCI])
	Subsystem: Super Micro Computer Inc Device 9180
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 4: I/O ports at 3000 [size=32]

00:1d.1 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #2 (rev 01) (prog-if 00 [UHCI])
	Subsystem: Super Micro Computer Inc Device 9180
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 19
	Region 4: I/O ports at 3020 [size=32]

00:1d.2 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #3 (rev 01) (prog-if 00 [UHCI])
	Subsystem: Super Micro Computer Inc Device 9180
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 4: I/O ports at 3040 [size=32]

00:1d.3 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #4 (rev 01) (prog-if 00 [UHCI])
	Subsystem: Super Micro Computer Inc Device 9180
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 16
	Region 4: I/O ports at 3060 [size=32]

00:1d.7 USB Controller: Intel Corporation 82801G (ICH7 Family) USB2 EHCI Controller (rev 01) (prog-if 20 [EHCI])
	Subsystem: Super Micro Computer Inc Device 9180
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 0: Memory at e0000000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0

00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev e1) (prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=00, secondary=0f, subordinate=0f, sec-latency=32
	I/O behind bridge: 00006000-00006fff
	Memory behind bridge: e0400000-e04fffff
	Prefetchable memory behind bridge: 00000000e8000000-00000000efffffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Subsystem: Super Micro Computer Inc Device 9180

00:1f.0 ISA bridge: Intel Corporation 82801GB/GR (ICH7 Family) LPC Interface Bridge (rev 01)
	Subsystem: Super Micro Computer Inc Device 9180
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information <?>

00:1f.1 IDE interface: Intel Corporation 82801G (ICH7 Family) IDE Controller (rev 01) (prog-if 8a [Master SecP PriP])
	Subsystem: Super Micro Computer Inc Device 9180
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx+
	Latency: 0
	Interrupt: pin A routed to IRQ 18
	Region 0: I/O ports at 01f0 [size=8]
	Region 1: I/O ports at 03f4 [size=1]
	Region 2: I/O ports at 0170 [size=8]
	Region 3: I/O ports at 0374 [size=1]
	Region 4: I/O ports at 30a0 [size=16]

00:1f.2 SATA controller: Intel Corporation 82801GR/GH (ICH7 Family) SATA AHCI Controller (rev 01) (prog-if 01 [AHCI 1.0])
	Subsystem: Super Micro Computer Inc Device 9180
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 379
	Region 0: I/O ports at 30e8 [size=8]
	Region 1: I/O ports at 30dc [size=4]
	Region 2: I/O ports at 30e0 [size=8]
	Region 3: I/O ports at 30d8 [size=4]
	Region 4: I/O ports at 30b0 [size=16]
	Region 5: Memory at e0000400 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
		Address: fee0f00c  Data: 4191
	Capabilities: [70] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: ahci

00:1f.3 SMBus: Intel Corporation 82801G (ICH7 Family) SMBus Controller (rev 01)
	Subsystem: Super Micro Computer Inc Device 9180
	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin B routed to IRQ 19
	Region 4: I/O ports at 1100 [size=32]

01:00.0 PCI bridge: Intel Corporation 6700PXH PCI Express-to-PCI Bridge A (rev 09) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=01, secondary=02, subordinate=02, sec-latency=64
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz+ FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [44] Express (v1) PCI/PCI-X Bridge, MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop- BrConfRtry-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x8, ASPM L0s, Latency L0 unlimited, L1 unlimited
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x8, TrErr- Train- SlotClk- DLActive- BWMgmt- ABWMgmt-
	Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [6c] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [d8] PCI-X bridge device
		Secondary Status: 64bit+ 133MHz+ SCD- USC- SCO- SRD- Freq=100MHz
		Status: Dev=01:00.0 64bit- 133MHz- SCD- USC- SCO- SRD-
		Upstream: Capacity=65535 CommitmentLimit=65535
		Downstream: Capacity=65535 CommitmentLimit=65535

01:00.1 PIC: Intel Corporation 6700/6702PXH I/OxAPIC Interrupt Controller A (rev 09) (prog-if 20 [IO(X)-APIC])
	Subsystem: Super Micro Computer Inc Device 9180
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Region 0: Memory at e0100000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [44] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 256 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x8, ASPM L0s, Latency L0 unlimited, L1 unlimited
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x8, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [6c] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

01:00.2 PCI bridge: Intel Corporation 6700PXH PCI Express-to-PCI Bridge B (rev 09) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=01, secondary=03, subordinate=03, sec-latency=64
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz+ FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [44] Express (v1) PCI/PCI-X Bridge, MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop- BrConfRtry-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x8, ASPM L0s, Latency L0 unlimited, L1 unlimited
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x8, TrErr- Train- SlotClk- DLActive- BWMgmt- ABWMgmt-
	Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [6c] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [d8] PCI-X bridge device
		Secondary Status: 64bit+ 133MHz+ SCD- USC- SCO- SRD- Freq=133MHz
		Status: Dev=01:00.2 64bit- 133MHz- SCD- USC- SCO- SRD-
		Upstream: Capacity=65535 CommitmentLimit=65535
		Downstream: Capacity=65535 CommitmentLimit=65535

01:00.3 PIC: Intel Corporation 6700PXH I/OxAPIC Interrupt Controller B (rev 09) (prog-if 20 [IO(X)-APIC])
	Subsystem: Super Micro Computer Inc Device 9180
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Region 0: Memory at e0101000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [44] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 256 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x8, ASPM L0s, Latency L0 unlimited, L1 unlimited
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x8, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [6c] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

0d:00.0 Ethernet controller: Intel Corporation 82573E Gigabit Ethernet Controller (Copper) (rev 03)
	Subsystem: Super Micro Computer Inc Device 108c
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 378
	Region 0: Memory at e0200000 (32-bit, non-prefetchable) [size=128K]
	Region 2: I/O ports at 4000 [size=32]
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [d0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
		Address: 00000000fee0f00c  Data: 41a9
	Capabilities: [e0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM unknown, Latency L0 <128ns, L1 <64us
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Kernel driver in use: e1000e
	Kernel modules: e1000e

0e:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Controller
	Subsystem: Super Micro Computer Inc Device 109a
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 377
	Region 0: Memory at e0300000 (32-bit, non-prefetchable) [size=128K]
	Region 2: I/O ports at 5000 [size=32]
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [d0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
		Address: 00000000fee0f00c  Data: 41c1
	Capabilities: [e0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM unknown, Latency L0 <128ns, L1 <64us
			ClockPM+ Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Kernel driver in use: e1000e
	Kernel modules: e1000e

0f:04.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev 02) (prog-if 00 [VGA controller])
	Subsystem: ATI Technologies Inc ES1000
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR+ FastB2B+ DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 66 (2000ns min), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at e8000000 (32-bit, prefetchable) [size=128M]
	Region 1: I/O ports at 6000 [size=256]
	Region 2: Memory at e0400000 (32-bit, non-prefetchable) [size=64K]
	[virtual] Expansion ROM at e0420000 [disabled] [size=128K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-



>  
> 
> > Nov  1 19:46:40 srw1 kernel: 0000:0d:00.0: eth0: Detected Tx Unit
> > Hang: 
> > Nov  1 19:46:40 srw1 kernel: TDH                  <bf>
> > Nov  1 19:46:40 srw1 kernel: TDT                  <cd>
> > Nov  1 19:46:40 srw1 kernel: next_to_use          <cd>
> > Nov  1 19:46:40 srw1 kernel: next_to_clean        <bf>
> > Nov  1 19:46:40 srw1 kernel: buffer_info[next_to_clean]:
> > Nov  1 19:46:40 srw1 kernel: time_stamp           <1020c297e>
> > Nov  1 19:46:40 srw1 kernel: next_to_watch        <bf>
> > Nov  1 19:46:40 srw1 kernel: jiffies              <1020c3cb4>
> > Nov  1 19:46:40 srw1 kernel: next_to_watch.status <0>
> > Nov  1 19:46:42 srw1 kernel: 0000:0d:00.0: eth0: Detected Tx Unit
> > Hang: 
> > Nov  1 19:46:42 srw1 kernel: TDH                  <bf>
> > Nov  1 19:46:42 srw1 kernel: TDT                  <cd>
> > Nov  1 19:46:42 srw1 kernel: next_to_use          <cd>
> > Nov  1 19:46:42 srw1 kernel: next_to_clean        <bf>
> > Nov  1 19:46:42 srw1 kernel: buffer_info[next_to_clean]:
> > Nov  1 19:46:42 srw1 kernel: time_stamp           <1020c297e>
> > Nov  1 19:46:42 srw1 kernel: next_to_watch        <bf>
> > Nov  1 19:46:42 srw1 kernel: jiffies              <1020c3f0c>
> > Nov  1 19:46:42 srw1 kernel: next_to_watch.status <0>
> 
> this part looks like we are reporting a real tx hang, from hardware's
> perspective at least.  Are you sure your duplex settings are correct?
> are you forcing 10 Full?

10Mb is correct. Its small serverhouse, old Cisco switches (10Mb forced on 
Cisco side, as I know). May be, it is problem with link on cicso side. 
Before it machine was connected to HP switch without problem. I send this
report due to sched warning (I didn't think its may be driver related)

> 
> > Nov  1 19:46:43 srw1 kernel: ------------[ cut here ]------------
> > Nov  1 19:46:43 srw1 kernel: WARNING: at net/sched/sch_generic.c:219
> > dev_watchdog+0x22e/0x240() Nov  1 19:46:43 srw1 kernel: NETDEV
> > WATCHDOG: eth0 (e1000e): transmit timed out 
> > Nov  1 19:46:43 srw1 kernel: Modules linked in: kvm_intel kvm ipv6
> > loop e1000e 
> > Nov  1 19:46:43 srw1 kernel: Pid: 0, comm: swapper Not tainted
> > 2.6.27.4 #2 
> > Nov  1 19:46:43 srw1 kernel:
> > Nov  1 19:46:43 srw1 kernel: Call Trace:
> > Nov  1 19:46:43 srw1 kernel: <IRQ>  [<ffffffff8023449d>]
> > warn_slowpath+0xcd/0x120 
> > Nov  1 19:46:43 srw1 kernel: [<ffffffff8023521d>] vprintk+0x16d/0x3c0
> > Nov  1 19:46:43 srw1 kernel: [<ffffffff8038b829>] __next_cpu+0x19/0x30
> > Nov  1 19:46:43 srw1 kernel: [<ffffffff8022bcec>]
> > find_busiest_group+0x1dc/0x950 
> > Nov  1 19:46:43 srw1 kernel: [<ffffffff803914d1>] strlcpy+0x41/0x50
> > Nov  1 19:46:43 srw1 kernel: [<ffffffff8042e49e>]
> > dev_watchdog+0x22e/0x240 
> > Nov  1 19:46:43 srw1 kernel: [<ffffffff80424c56>]
> > neigh_periodic_timer+0x146/0x1c0 
> > Nov  1 19:46:43 srw1 kernel: [<ffffffff8024f178>]
> > getnstimeofday+0x48/0xc0 
> > Nov  1 19:46:43 srw1 kernel: [<ffffffff8042e270>]
> > dev_watchdog+0x0/0x240 
> > Nov  1 19:46:43 srw1 kernel: [<ffffffff8023e6be>]
> > run_timer_softirq+0x12e/0x200 
> > Nov  1 19:46:43 srw1 kernel: [<ffffffff80239e43>]
> > __do_softirq+0x73/0xf0 
> > Nov  1 19:46:43 srw1 kernel: [<ffffffff8020cb8c>]
> > call_softirq+0x1c/0x30 
> > Nov  1 19:46:43 srw1 kernel: [<ffffffff8020eb75>] do_softirq+0x35/0x70
> > Nov  1 19:46:43 srw1 kernel: [<ffffffff8021c13e>]
> > smp_apic_timer_interrupt+0x7e/0xc0 
> > Nov  1 19:46:43 srw1 kernel: [<ffffffff8020c5d6>]
> > apic_timer_interrupt+0x66/0x70 
> > Nov  1 19:46:43 srw1 kernel: <EOI>  [<ffffffff8021329c>]
> > mwait_idle+0x3c/0x50 
> > Nov  1 19:46:43 srw1 kernel: [<ffffffff8020a86c>] cpu_idle+0x5c/0x90
> > Nov  1 19:46:43 srw1 kernel:
> > Nov  1 19:46:43 srw1 kernel: ---[ end trace c45f300d9ee4877c ]---
> > Nov  1 19:46:45 srw1 kernel: 0000:0d:00.0: eth0: Link is Up 10 Mbps
> > Full Duplex, Flow Control: None Nov  1 19:46:45 srw1 kernel:
> > 0000:0d:00.0: eth0: 10/100 speed: disabling TSO 
> > Nov  1 19:48:40 srw1 kernel: 0000:0d:00.0: eth0: Detected Tx Unit
> > Hang: 
> 
> hm, roughly 2 minutes from link up to hang, and at least 0xd7 packets
> enqueued (215)  
> 
> > Nov  1 19:48:40 srw1 kernel: TDH                  <cc>
> > Nov  1 19:48:40 srw1 kernel: TDT                  <d7>
> > Nov  1 19:48:40 srw1 kernel: next_to_use          <d7>
> > Nov  1 19:48:40 srw1 kernel: next_to_clean        <ca>
> > Nov  1 19:48:40 srw1 kernel: buffer_info[next_to_clean]:
> > Nov  1 19:48:40 srw1 kernel: time_stamp           <1020cb4e0>
> > Nov  1 19:48:40 srw1 kernel: next_to_watch        <cc>
> > Nov  1 19:48:40 srw1 kernel: jiffies              <1020cc828>
> > Nov  1 19:48:40 srw1 kernel: next_to_watch.status <0>
> > Nov  1 19:48:43 srw1 kernel: 0000:0d:00.0: eth0: Link is Up 10 Mbps
> > Full Duplex, Flow Control: None Nov  1 19:48:43 srw1 kernel:
> > 0000:0d:00.0: eth0: 10/100 speed: disabling TSO 
> 
> we have a patch that can dump the hardware state of the transmit ring in
> much more detail, once we get more information maybe we'll have to run
> that to figure out whats up.
> 
> Thanks for the report,
>   Jesse
I am glad, I can help a little with development :-).

I found one more similar warning on kernel 2.6.26.5 (the same machine):

Oct 21 18:50:48 srw1 kernel: eth0: Detected Tx Unit Hang:
Oct 21 18:50:48 srw1 kernel: TDH                  <11>
Oct 21 18:50:48 srw1 kernel: TDT                  <13>
Oct 21 18:50:48 srw1 kernel: next_to_use          <13>
Oct 21 18:50:48 srw1 kernel: next_to_clean        <11>
Oct 21 18:50:48 srw1 kernel: buffer_info[next_to_clean]:
Oct 21 18:50:48 srw1 kernel: time_stamp           <10003c1a2>
Oct 21 18:50:48 srw1 kernel: next_to_watch        <11>
Oct 21 18:50:48 srw1 kernel: jiffies              <10003c4dc>
Oct 21 18:50:48 srw1 kernel: next_to_watch.status <0>
Oct 21 18:50:50 srw1 kernel: eth0: Detected Tx Unit Hang:
Oct 21 18:50:50 srw1 kernel: TDH                  <11>
Oct 21 18:50:50 srw1 kernel: TDT                  <13>
Oct 21 18:50:50 srw1 kernel: next_to_use          <13>
Oct 21 18:50:50 srw1 kernel: next_to_clean        <11>
Oct 21 18:50:50 srw1 kernel: buffer_info[next_to_clean]:
Oct 21 18:50:50 srw1 kernel: time_stamp           <10003c1a2>
Oct 21 18:50:50 srw1 kernel: next_to_watch        <11>
Oct 21 18:50:50 srw1 kernel: jiffies              <10003c734>
Oct 21 18:50:50 srw1 kernel: next_to_watch.status <0>
Oct 21 18:50:52 srw1 kernel: eth0: Detected Tx Unit Hang:
Oct 21 18:50:52 srw1 kernel: TDH                  <11>
Oct 21 18:50:52 srw1 kernel: TDT                  <13>
Oct 21 18:50:52 srw1 kernel: next_to_use          <13>
Oct 21 18:50:52 srw1 kernel: next_to_clean        <11>
Oct 21 18:50:52 srw1 kernel: buffer_info[next_to_clean]:
Oct 21 18:50:52 srw1 kernel: time_stamp           <10003c1a2>
Oct 21 18:50:52 srw1 kernel: next_to_watch        <11>
Oct 21 18:50:52 srw1 kernel: jiffies              <10003c98c>
Oct 21 18:50:52 srw1 kernel: next_to_watch.status <0>
Oct 21 18:50:54 srw1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Oct 21 18:50:54 srw1 kernel: ------------[ cut here ]------------
Oct 21 18:50:54 srw1 kernel: WARNING: at net/sched/sch_generic.c:222 dev_watchdog+0x113/0x130()
Oct 21 18:50:54 srw1 kernel: Modules linked in: kvm_intel kvm ipv6 loop e1000e
Oct 21 18:50:54 srw1 kernel: Pid: 0, comm: swapper Not tainted 2.6.26.5 #1
Oct 21 18:50:54 srw1 kernel: 
Oct 21 18:50:54 srw1 kernel: Call Trace:
Oct 21 18:50:54 srw1 kernel: <IRQ>  [<ffffffff802326a4>] warn_on_slowpath+0x64/0xc0
Oct 21 18:50:54 srw1 kernel: [<ffffffff80248729>] autoremove_wake_function+0x9/0x30
Oct 21 18:50:54 srw1 kernel: [<ffffffff8022807a>] __wake_up_common+0x5a/0x90
Oct 21 18:50:54 srw1 kernel: [<ffffffff802288a3>] __wake_up+0x43/0x70
Oct 21 18:50:54 srw1 kernel: [<ffffffff80244c60>] __queue_work+0x30/0x50
Oct 21 18:50:54 srw1 kernel: [<ffffffff804284a0>] dev_watchdog+0x0/0x130
Oct 21 18:50:54 srw1 kernel: [<ffffffff804285b3>] dev_watchdog+0x113/0x130
Oct 21 18:50:54 srw1 kernel: [<ffffffff8023caae>] run_timer_softirq+0x12e/0x200
Oct 21 18:50:54 srw1 kernel: [<ffffffff802385aa>] __do_softirq+0x7a/0xf0
Oct 21 18:50:54 srw1 kernel: [<ffffffff8020c89c>] call_softirq+0x1c/0x30
Oct 21 18:50:54 srw1 kernel: [<ffffffff8020e8f5>] do_softirq+0x35/0x70
Oct 21 18:50:54 srw1 kernel: [<ffffffff8021b7cd>] smp_apic_timer_interrupt+0x7d/0xc0
Oct 21 18:50:54 srw1 kernel: [<ffffffff80212a80>] mwait_idle+0x0/0x50
Oct 21 18:50:54 srw1 kernel: [<ffffffff8020c346>] apic_timer_interrupt+0x66/0x70
Oct 21 18:50:54 srw1 kernel: <EOI>  [<ffffffff80209410>] default_idle+0x0/0x50
Oct 21 18:50:54 srw1 kernel: [<ffffffff80212abc>] mwait_idle+0x3c/0x50
Oct 21 18:50:54 srw1 kernel: [<ffffffff8020a720>] cpu_idle+0x60/0xa0
Oct 21 18:50:54 srw1 kernel: 
Oct 21 18:50:54 srw1 kernel: ---[ end trace 85d19e848b4f1ce4 ]---
Oct 21 18:50:56 srw1 kernel: eth0: Link is Up 100 Mbps Full Duplex, Flow Control: None
Oct 21 18:50:56 srw1 kernel: eth0: 10/100 speed: disabling TSO


Regards,

-- 
Milan Kocian
