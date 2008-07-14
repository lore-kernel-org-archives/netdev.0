From: Kasper Sandberg <lkml@metanurb.dk>
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in
	Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another
	Problem)
Date: Mon, 14 Jul 2008 22:45:44 +0200
Message-ID: <1216068344.23392.19.camel@localhost>
References: <4861800B.90703@nscus.com> <48777BC3.6090108@dell.com>
	 <1216052460.23392.14.camel@localhost>
	 <200807142152.26163.eike-kernel@sf-tec.de>  <487BB065.3020709@dell.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rolf Eike Beer <eike-kernel@sf-tec.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Michael Grollman <mgrollman@nscus.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-pci@vger.kernel.org
To: Mario Limonciello <mario_limonciello@dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <487BB065.3020709@dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2008-07-14 at 15:00 -0500, Mario Limonciello wrote:
> Kasper:
> 
> Interesting that it failed for you though.  I was able to run through a
> script of 200x rmmod/modprobe without any trouble when that patch was
> applied.

Well are you sure it actually catches my nics?

i have 8111c:

05:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd.
RTL8111/8168B PCI Express Gigabit Ethernet controller [10ec:8168] (rev
02)
        Subsystem: Giga-byte Technology Unknown device [1458:e000]
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 376
        Region 0: I/O ports at c000 [size=256]
        Region 2: Memory at e9010000 (64-bit, prefetchable) [size=4K]
        Region 4: Memory at e9000000 (64-bit, prefetchable) [size=64K]
        [virtual] Expansion ROM at e9020000 [disabled] [size=64K]
        Capabilities: [40] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1
+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+
Queue=0/1 Enable+
                Address: 00000000fee0f00c  Data: 416e
        Capabilities: [70] Express (v1) Endpoint, MSI 01
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s
<512ns, L1 <8us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+
TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1,
Latency L0 <512ns, L1 <64us
                        ClockPM+ Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
        Capabilities: [b0] MSI-X: Enable- Mask- TabSize=2
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00000800
        Capabilities: [d0] Vital Product Data <?>
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [140] Virtual Channel <?>
        Capabilities: [160] Device Serial Number 00-00-00-00-00-00-00-00
        Kernel driver in use: r8169
        Kernel modules: r8169
00: ec 10 68 81 07 04 10 00 02 00 00 02 08 00 00 00
10: 01 c0 00 00 00 00 00 00 0c 00 01 e9 00 00 00 00
20: 0c 00 00 e9 00 00 00 00 00 00 00 00 58 14 00 e0
30: 00 00 00 00 40 00 00 00 00 00 00 00 0a 01 00 00

06:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd.
RTL8111/8168B PCI Express Gigabit Ethernet controller [10ec:8168] (rev
02)
        Subsystem: Giga-byte Technology Unknown device [1458:e000]
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 375
        Region 0: I/O ports at d000 [size=256]
        Region 2: Memory at e9110000 (64-bit, prefetchable) [size=4K]
        Region 4: Memory at e9100000 (64-bit, prefetchable) [size=64K]
        [virtual] Expansion ROM at e9120000 [disabled] [size=64K]
        Capabilities: [40] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1
+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+
Queue=0/1 Enable+
                Address: 00000000fee0f00c  Data: 4176
        Capabilities: [70] Express (v1) Endpoint, MSI 01
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s
<512ns, L1 <8us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+
TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1,
Latency L0 <512ns, L1 <64us
                        ClockPM+ Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
        Capabilities: [b0] MSI-X: Enable- Mask- TabSize=2
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00000800
        Capabilities: [d0] Vital Product Data <?>
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [140] Virtual Channel <?>
        Capabilities: [160] Device Serial Number 00-00-00-00-00-00-00-00
        Kernel driver in use: r8169
        Kernel modules: r8169
00: ec 10 68 81 07 04 10 00 02 00 00 02 08 00 00 00
10: 01 d0 00 00 00 00 00 00 0c 00 11 e9 00 00 00 00
20: 0c 00 10 e9 00 00 00 00 00 00 00 00 58 14 00 e0
30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 00 00


Either way, the patchset from Francois seems to fix it, With this in
mind, do we actually know exactly what causes it?

> 
> Regards
> 
> Rolf Eike Beer wrote:
> > Kasper Sandberg wrote:
> >   
> >
> > Is there any chance this helps with the famous 8101 problems, e.g. 
> > http://bugzilla.kernel.org/show_bug.cgi?id=6807 ?
> >
> >   
> >
> > There is a typo in the description of 91ba1a976c214766b5ee8c6d17086903c10f6405 
> > (serie should be series I think).
> >
> > Greetings,
> >
> > Eike
> >   
> 
