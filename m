From: Piotr Gabriel Kosinski <pg.kosinski@gmail.com>
Subject: Re: Realtek RTL8101E PCI-E ethernet controller does not work with the
 r8169 driver
Date: Thu, 27 Apr 2017 17:33:05 +0200
Message-ID: <CAFMLSdMcsr0n09x3NAgBNxbL933kgyqq3JuAgbFZ7zH7pzcRcQ@mail.gmail.com>
References: <CAFMLSdOBwO4zWZo48EymSGw=4i5DSDfc4VjrxBjWaM5h5DBknw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f54.google.com ([209.85.213.54]:36817 "EHLO
        mail-vk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938978AbdD0PdH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 11:33:07 -0400
Received: by mail-vk0-f54.google.com with SMTP id q78so19145151vke.3
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 08:33:07 -0700 (PDT)
In-Reply-To: <CAFMLSdOBwO4zWZo48EymSGw=4i5DSDfc4VjrxBjWaM5h5DBknw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

00:00.0 Host bridge: Intel Corporation Atom Processor Z36xxx/Z37xxx
Series SoC Transaction Register (rev 0a)
    Subsystem: Toshiba America Info Systems Atom Processor
Z36xxx/Z37xxx Series SoC Transaction Register
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Kernel driver in use: iosf_mbi_pci

00:02.0 VGA compatible controller: Intel Corporation Atom Processor
Z36xxx/Z37xxx Series Graphics & Display (rev 0a) (prog-if 00 [VGA
controller])
    Subsystem: Toshiba America Info Systems Atom Processor
Z36xxx/Z37xxx Series Graphics & Display
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin A routed to IRQ 90
    Region 0: Memory at c0000000 (32-bit, non-prefetchable) [size=4M]
    Region 2: Memory at d0000000 (32-bit, prefetchable) [size=256M]
    Region 4: I/O ports at f080 [size=8]
    [virtual] Expansion ROM at 000c0000 [disabled] [size=128K]
    Capabilities: [d0] Power Management version 2
        Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [90] MSI: Enable+ Count=1/1 Maskable- 64bit-
        Address: fee0200c  Data: 41d1
    Capabilities: [b0] Vendor Specific Information: Len=07 <?>
    Kernel driver in use: i915
    Kernel modules: i915

00:13.0 SATA controller: Intel Corporation Atom Processor E3800 Series
SATA AHCI Controller (rev 0a) (prog-if 01 [AHCI 1.0])
    Subsystem: Toshiba America Info Systems Atom Processor E3800
Series SATA AHCI Controller
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin A routed to IRQ 88
    Region 0: I/O ports at f070 [size=8]
    Region 1: I/O ports at f060 [size=4]
    Region 2: I/O ports at f050 [size=8]
    Region 3: I/O ports at f040 [size=4]
    Region 4: I/O ports at f020 [size=32]
    Region 5: Memory at c0815000 (32-bit, non-prefetchable) [size=2K]
    Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
        Address: fee0200c  Data: 41b1
    Capabilities: [70] Power Management version 3
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot+,D3cold-)
        Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [a8] SATA HBA v1.0 BAR4 Offset=00000004
    Kernel driver in use: ahci
    Kernel modules: ahci

00:14.0 USB controller: Intel Corporation Atom Processor
Z36xxx/Z37xxx, Celeron N2000 Series USB xHCI (rev 0a) (prog-if 30
[XHCI])
    Subsystem: Toshiba America Info Systems Atom Processor
Z36xxx/Z37xxx, Celeron N2000 Series USB xHCI
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin A routed to IRQ 87
    Region 0: Memory at c0800000 (64-bit, non-prefetchable) [size=64K]
    Capabilities: [70] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA
PME(D0-,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [80] MSI: Enable+ Count=1/8 Maskable- 64bit+
        Address: 00000000fee0200c  Data: 4191
    Kernel driver in use: xhci_hcd

00:1a.0 Encryption controller: Intel Corporation Atom Processor
Z36xxx/Z37xxx Series Trusted Execution Engine (rev 0a)
    Subsystem: Toshiba America Info Systems Atom Processor
Z36xxx/Z37xxx Series Trusted Execution Engine
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 91
    Region 0: Memory at c0500000 (32-bit, non-prefetchable) [size=1M]
    Region 1: Memory at c0400000 (32-bit, non-prefetchable) [size=1M]
    Capabilities: [80] Power Management version 3
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold-)
        Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [a0] MSI: Enable+ Count=1/1 Maskable- 64bit-
        Address: fee0300c  Data: 41e1
    Kernel driver in use: mei_txe
    Kernel modules: mei_txe

00:1b.0 Audio device: Intel Corporation Atom Processor Z36xxx/Z37xxx
Series High Definition Audio Controller (rev 0a)
    Subsystem: Toshiba America Info Systems Atom Processor
Z36xxx/Z37xxx Series High Definition Audio Controller
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 92
    Region 0: Memory at c0810000 (64-bit, non-prefetchable) [size=16K]
    Capabilities: [50] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [60] MSI: Enable+ Count=1/1 Maskable- 64bit+
        Address: 00000000fee0300c  Data: 4142
    Kernel driver in use: snd_hda_intel
    Kernel modules: snd_hda_intel

00:1c.0 PCI bridge: Intel Corporation Atom Processor E3800 Series PCI
Express Root Port 1 (rev 0a) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 16
    Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
    I/O behind bridge: 00001000-00001fff
    Memory behind bridge: c0900000-c0afffff
    Prefetchable memory behind bridge: 00000000c0b00000-00000000c0cfffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
        DevCap:    MaxPayload 128 bytes, PhantFunc 0
            ExtTag- RBE+
        DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
            MaxPayload 128 bytes, MaxReadReq 128 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
        LnkCap:    Port #1, Speed 5GT/s, Width x1, ASPM L0s L1, Exit
Latency L0s <512ns, L1 <4us
            ClockPM- Surprise- LLActRep+ BwNot+ ASPMOptComp-
        LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- CommClk+
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
        SltCap:    AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
            Slot #0, PowerLimit 10.000W; Interlock- NoCompl+
        SltCtl:    Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt-
HPIrq- LinkChg-
            Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
        SltSta:    Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
            Changed: MRL- PresDet- LinkState-
        RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
        RootCap: CRSVisible-
        RootSta: PME ReqID 0000, PMEStatus- PMEPending-
        DevCap2: Completion Timeout: Range BC, TimeoutDis+, LTR-, OBFF
Not Supported ARIFwd-
        DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-,
OBFF Disabled ARIFwd-
        LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-
             Transmit Margin: Normal Operating Range,
EnterModifiedCompliance- ComplianceSOS-
             Compliance De-emphasis: -6dB
        LnkSta2: Current De-emphasis Level: -3.5dB,
EqualizationComplete-, EqualizationPhase1-
             EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
    Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
        Address: 00000000  Data: 0000
    Capabilities: [90] Subsystem: Toshiba America Info Systems Atom
Processor E3800 Series PCI Express Root Port 1
    Capabilities: [a0] Power Management version 3
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
    Kernel driver in use: pcieport
    Kernel modules: shpchp

00:1c.1 PCI bridge: Intel Corporation Atom Processor E3800 Series PCI
Express Root Port 2 (rev 0a) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin B routed to IRQ 17
    Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
    I/O behind bridge: 00002000-00002fff
    Memory behind bridge: c0700000-c07fffff
    Prefetchable memory behind bridge: 00000000c0d00000-00000000c0efffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
        DevCap:    MaxPayload 128 bytes, PhantFunc 0
            ExtTag- RBE+
        DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
            MaxPayload 128 bytes, MaxReadReq 128 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
        LnkCap:    Port #2, Speed 5GT/s, Width x1, ASPM L0s L1, Exit
Latency L0s <512ns, L1 <4us
            ClockPM- Surprise- LLActRep+ BwNot+ ASPMOptComp-
        LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- CommClk+
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+
DLActive+ BWMgmt+ ABWMgmt-
        SltCap:    AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
            Slot #1, PowerLimit 10.000W; Interlock- NoCompl+
        SltCtl:    Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt-
HPIrq- LinkChg-
            Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
        SltSta:    Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
            Changed: MRL- PresDet- LinkState-
        RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
        RootCap: CRSVisible-
        RootSta: PME ReqID 0000, PMEStatus- PMEPending-
        DevCap2: Completion Timeout: Range BC, TimeoutDis+, LTR-, OBFF
Not Supported ARIFwd-
        DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis+, LTR-,
OBFF Disabled ARIFwd-
        LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
             Transmit Margin: Normal Operating Range,
EnterModifiedCompliance- ComplianceSOS-
             Compliance De-emphasis: -6dB
        LnkSta2: Current De-emphasis Level: -3.5dB,
EqualizationComplete-, EqualizationPhase1-
             EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
    Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
        Address: 00000000  Data: 0000
    Capabilities: [90] Subsystem: Toshiba America Info Systems Atom
Processor E3800 Series PCI Express Root Port 2
    Capabilities: [a0] Power Management version 3
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
    Kernel driver in use: pcieport
    Kernel modules: shpchp

00:1c.2 PCI bridge: Intel Corporation Atom Processor E3800 Series PCI
Express Root Port 3 (rev 0a) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin C routed to IRQ 18
    Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
    I/O behind bridge: 0000e000-0000efff
    Memory behind bridge: c0600000-c06fffff
    Prefetchable memory behind bridge: 00000000e0000000-00000000e00fffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
        DevCap:    MaxPayload 128 bytes, PhantFunc 0
            ExtTag- RBE+
        DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
            MaxPayload 128 bytes, MaxReadReq 128 bytes
        DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
        LnkCap:    Port #3, Speed 5GT/s, Width x1, ASPM L0s L1, Exit
Latency L0s <512ns, L1 <4us
            ClockPM- Surprise- LLActRep+ BwNot+ ASPMOptComp-
        LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- CommClk+
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+
DLActive+ BWMgmt+ ABWMgmt-
        SltCap:    AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
            Slot #2, PowerLimit 10.000W; Interlock- NoCompl+
        SltCtl:    Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt-
HPIrq- LinkChg-
            Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
        SltSta:    Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
            Changed: MRL- PresDet- LinkState-
        RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
        RootCap: CRSVisible-
        RootSta: PME ReqID 0000, PMEStatus- PMEPending-
        DevCap2: Completion Timeout: Range BC, TimeoutDis+, LTR-, OBFF
Not Supported ARIFwd-
        DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis+, LTR-,
OBFF Disabled ARIFwd-
        LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
             Transmit Margin: Normal Operating Range,
EnterModifiedCompliance- ComplianceSOS-
             Compliance De-emphasis: -6dB
        LnkSta2: Current De-emphasis Level: -3.5dB,
EqualizationComplete-, EqualizationPhase1-
             EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
    Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
        Address: 00000000  Data: 0000
    Capabilities: [90] Subsystem: Toshiba America Info Systems Atom
Processor E3800 Series PCI Express Root Port 3
    Capabilities: [a0] Power Management version 3
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
    Kernel driver in use: pcieport
    Kernel modules: shpchp

00:1f.0 ISA bridge: Intel Corporation Atom Processor Z36xxx/Z37xxx
Series Power Control Unit (rev 0a)
    Subsystem: Toshiba America Info Systems Atom Processor
Z36xxx/Z37xxx Series Power Control Unit
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Capabilities: [e0] Vendor Specific Information: Len=0c <?>
    Kernel driver in use: lpc_ich
    Kernel modules: lpc_ich

00:1f.3 SMBus: Intel Corporation Atom Processor E3800 Series SMBus
Controller (rev 0a)
    Subsystem: Toshiba America Info Systems Atom Processor E3800
Series SMBus Controller
    Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Interrupt: pin B routed to IRQ 255
    Region 0: Memory at c0814000 (32-bit, non-prefetchable) [size=32]
    Region 4: I/O ports at f000 [size=32]
    Capabilities: [50] Power Management version 3
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
    Kernel modules: i2c_i801

02:00.0 Network controller: Qualcomm Atheros QCA9565 / AR9565 Wireless
Network Adapter (rev 01)
    Subsystem: XAVi Technologies Corp. QCA9565 / AR9565 Wireless Network Adapter
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 17
    Region 0: Memory at c0700000 (64-bit, non-prefetchable) [size=512K]
    Expansion ROM at c0780000 [disabled] [size=64K]
    Capabilities: [40] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
        Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [50] MSI: Enable- Count=1/4 Maskable+ 64bit+
        Address: 0000000000000000  Data: 0000
        Masking: 00000000  Pending: 00000000
    Capabilities: [70] Express (v2) Endpoint, MSI 00
        DevCap:    MaxPayload 128 bytes, PhantFunc 0, Latency L0s
unlimited, L1 <64us
            ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
            MaxPayload 128 bytes, MaxReadReq 512 bytes
        DevSta:    CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
        LnkCap:    Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit
Latency L0s <4us, L1 <64us
            ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp-
        LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- CommClk+
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
        DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR-,
OBFF Not Supported
        DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis+, LTR-,
OBFF Disabled
        LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
             Transmit Margin: Normal Operating Range,
EnterModifiedCompliance- ComplianceSOS-
             Compliance De-emphasis: -6dB
        LnkSta2: Current De-emphasis Level: -6dB,
EqualizationComplete-, EqualizationPhase1-
             EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
    Capabilities: [100 v1] Advanced Error Reporting
        UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
        UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
        UESvrt:    DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt-
RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
        CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
        CEMsk:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
        AERCap:    First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
    Capabilities: [140 v1] Virtual Channel
        Caps:    LPEVC=0 RefClk=100ns PATEntryBits=1
        Arb:    Fixed- WRR32- WRR64- WRR128-
        Ctrl:    ArbSelect=Fixed
        Status:    InProgress-
        VC0:    Caps:    PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
            Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
            Ctrl:    Enable+ ID=0 ArbSelect=Fixed TC/VC=01
            Status:    NegoPending- InProgress-
    Capabilities: [160 v1] Device Serial Number 00-00-00-00-00-00-00-00
    Kernel driver in use: ath9k
    Kernel modules: ath9k

03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8101/2/6E PCI Express Fast/Gigabit Ethernet controller (rev 07)
    Subsystem: Toshiba America Info Systems RTL8101/2/6E PCI Express
Fast/Gigabit Ethernet controller
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 89
    Region 0: I/O ports at e000 [size=256]
    Region 2: Memory at e0004000 (64-bit, prefetchable) [size=4K]
    Region 4: Memory at e0000000 (64-bit, prefetchable) [size=16K]
    Expansion ROM at c0600000 [disabled] [size=64K]
    Capabilities: [40] Power Management version 3
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
        Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
        Address: 00000000fee0300c  Data: 41c1
    Capabilities: [70] Express (v2) Endpoint, MSI 01
        DevCap:    MaxPayload 128 bytes, PhantFunc 0, Latency L0s
unlimited, L1 <64us
            ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
            RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
            MaxPayload 128 bytes, MaxReadReq 512 bytes
        DevSta:    CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
        LnkCap:    Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit
Latency L0s unlimited, L1 <64us
            ClockPM+ Surprise- LLActRep- BwNot- ASPMOptComp+
        LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- CommClk+
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
        DevCap2: Completion Timeout: Range ABCD, TimeoutDis+, LTR+,
OBFF Via message/WAKE#
        DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis+, LTR+,
OBFF Disabled
        LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
             Transmit Margin: Normal Operating Range,
EnterModifiedCompliance- ComplianceSOS-
             Compliance De-emphasis: -6dB
        LnkSta2: Current De-emphasis Level: -6dB,
EqualizationComplete-, EqualizationPhase1-
             EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
    Capabilities: [b0] MSI-X: Enable- Count=4 Masked-
        Vector table: BAR=4 offset=00000000
        PBA: BAR=4 offset=00000800
    Capabilities: [d0] Vital Product Data
        Not readable
    Capabilities: [100 v1] Advanced Error Reporting
        UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
        UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
        UESvrt:    DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt-
RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
        CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
        CEMsk:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
        AERCap:    First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
    Capabilities: [140 v1] Virtual Channel
        Caps:    LPEVC=0 RefClk=100ns PATEntryBits=1
        Arb:    Fixed- WRR32- WRR64- WRR128-
        Ctrl:    ArbSelect=Fixed
        Status:    InProgress-
        VC0:    Caps:    PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
            Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
            Ctrl:    Enable+ ID=0 ArbSelect=Fixed TC/VC=01
            Status:    NegoPending- InProgress-
    Capabilities: [160 v1] Device Serial Number 00-00-00-00-00-00-00-00
    Capabilities: [170 v1] Latency Tolerance Reporting
        Max snoop latency: 71680ns
        Max no snoop latency: 71680ns
    Kernel driver in use: r8169
    Kernel modules: r8169


2017-04-27 17:31 GMT+02:00 Piotr Gabriel Kosinski <pg.kosinski@gmail.com>:
> The Realtek RTL8101E PCI Express ethernet controller does not work
> with the r8169 driver, on kernel 4.10 (it also did not work on earlier
> kernels). These are the messages from the kernel log:
>
> [   11.359593] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [   11.359611] r8169 0000:03:00.0: can't disable ASPM; OS doesn't have
> ASPM control
> [   11.359803] r8169 0000:03:00.0 (unnamed net_device)
> (uninitialized): unknown MAC, using family default
> [   11.369802] r8169 0000:03:00.0 (unnamed net_device)
> (uninitialized): rtl_chipcmd_cond == 1 (loop: 100, delay: 100).
> [   11.406668] r8169 0000:03:00.0 eth0: rtl_counters_cond == 1 (loop:
> 1000, delay: 10).
> [   11.406815] r8169 0000:03:00.0 eth0: RTL8101e at
> 0xffffb3140068d000, ff:ff:ff:ff:ff:ff, XID 9cf0f8ff IRQ 89
> [   11.482740] r8169 0000:03:00.0 enp3s0: renamed from eth0
> [   11.501187] r8169 0000:03:00.0 enp3s0: rtl_counters_cond == 1
> (loop: 1000, delay: 10).
> [   33.348246] r8169 0000:03:00.0 enp3s0: rtl_counters_cond == 1
> (loop: 1000, delay: 10).
> [   34.273602] r8169 0000:03:00.0 enp3s0: rtl_counters_cond == 1
> (loop: 1000, delay: 10).
> [   35.195420] r8169 0000:03:00.0 enp3s0: rtl_counters_cond == 1
> (loop: 1000, delay: 10).
> [   35.678908] r8169 0000:03:00.0 enp3s0: rtl_counters_cond == 1
> (loop: 1000, delay: 10).
> [   36.401291] IPv6: ADDRCONF(NETDEV_UP): enp3s0: link is not ready
> [   36.411989] r8169 0000:03:00.0 enp3s0: rtl_counters_cond == 1
> (loop: 1000, delay: 10).
>
> the rtl_counters_cond message is then regularly repeated.
>
> ifconfig's ether address shows ff:ff:ff:ff:ff:ff
>
>
> If that is of any help - the controller works on FreeBSD's re driver,
> but only when the following two loader options are set:
> hw.re.msix_disable=1
> hw.re.prefer_iomap=1
>
> Both of these options must be set to 1. If prefer_iomap is not set,
> there are messages like:
> re0: reset never completed!
> re0: PHY write failed
> re0: attaching PHYs failed
> device_attach: re0 attach returned 6
>
> If msix_disable is not set (msix is enabled), there are no error
> messages and mac address is read correctly, but the controller does
> not work (no connection can be established, e.g. DHCP).
>
> If both of the above options are set to 1, the controller works fine,
> with the following messages:
> re0: <RealTek 810xE PCIe 10/100baseTX> port 0xe000-0xe0ff mem
> 0xe0004000-0xe0004fff,0xe0000000-0xe0003fff at device 0.0 on pci2
> re0: Using 1 MSI message
> re0: Chip rev. 0x44800000
> re0: MAC rev. 0x00100000
> miibus0: <MII bus> on re0
> rlphy0: <RTL8201E 10/100 media interface> PHY 1 on miibus0
> rlphy0: 10baseT, 100baseT-FDX, 100baseTX, 100baseTX-FDX, auto, auto-flow
> re0: Using defaults for TSO: 65518/35/2048
> re0: netmap queues/slots: TX 1/256, RX 1/256
> re0: link state changed to DOWN
> re0: link state changed to UP
>
> The problem occurs e.g. on Intel Atom-based Toshiba NB10-A-104 Netbook.
> In the next mail I will attach lspci -vvv output.
>
> Thank you,
> Piotr.
