From: "devendra.aaru" <devendra.aaru@gmail.com>
Subject: Re: 3.6.10: Intel: ixgbe 0000:01:00.0 eth4: Detected Tx Unit Hang
Date: Mon, 17 Dec 2012 13:38:36 -0500
Message-ID: <CAHdPZaOCKy8Ee17g-sU6YViGdfGPOsV7OLN+w+XA2eUWGmAy_Q@mail.gmail.com>
References: <004101cddadb$b890e910$29b2bb30$@lucidpixels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Justin Piszcz <jpiszcz@lucidpixels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <004101cddadb$b890e910$29b2bb30$@lucidpixels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ccing netdev
On Sat, Dec 15, 2012 at 10:49 AM, Justin Piszcz <jpiszcz@lucidpixels.com> wrote:
> Hello,
>
> Kernel 3.6.10, first time I have seen this that I can remember (on 10GbE)
> anyway, is this a known issue with 3.6.10?
>
> When the link went down is when I rebooted/etc the remote host attached on
> the other end.
> I've not changed anything physically with the hardware and have been on
> 3.6.0-3.6.9 and noticed this when I moved to 3.6.10.
>
> [10270.229200] ixgbe 0000:01:00.0 eth4: NIC Link is Down
> [10276.124937] ixgbe 0000:01:00.0 eth4: NIC Link is Up 10 Gbps, Flow
> Control: RX/TX
> [24529.430997] ixgbe 0000:01:00.0 eth4: Detected Tx Unit Hang
> [24529.430997]   Tx Queue             <10>
> [24529.430997]   TDH, TDT             <4e>, <51>
> [24529.430997]   next_to_use          <51>
> [24529.430997]   next_to_clean        <4e>
> [24529.430997] tx_buffer_info[next_to_clean]
> [24529.430997]   time_stamp           <10172668f>
> [24529.430997]   jiffies              <101726ea4>
> [24529.431011] ixgbe 0000:01:00.0 eth4: tx hang 1 detected on queue 10,
> resetting adapter
> [24529.431028] ixgbe 0000:01:00.0 eth4: Reset adapter
>
> Thoughts?
>
> lspci -vvxx
>
> 01:00.0 Ethernet controller: Intel Corporation 82598EB 10-Gigabit AT2 Server
> Adapter (rev 01)
>   Subsystem: Intel Corporation 82598EB 10-Gigabit AT2 Server Adapter
>   Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
>   Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
> <MAbort- >SERR- <PERR- INTx-
>   Latency: 0, Cache Line Size: 64 bytes
>   Interrupt: pin A routed to IRQ 26
>   Region 0: Memory at fbe40000 (32-bit, non-prefetchable) [size=128K]
>   Region 1: Memory at fbe00000 (32-bit, non-prefetchable) [size=256K]
>   Region 2: I/O ports at e000 [size=32]
>   Region 3: Memory at fbe60000 (32-bit, non-prefetchable) [size=16K]
>   Capabilities: [40] Power Management version 3
>     Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold-)
>     Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
>   Capabilities: [50] MSI: Enable- Count=1/1 Maskable- 64bit+
>     Address: 0000000000000000  Data: 0000
>   Capabilities: [60] MSI-X: Enable+ Count=18 Masked-
>     Vector table: BAR=3 offset=00000000
>     PBA: BAR=3 offset=00002000
>   Capabilities: [a0] Express (v2) Endpoint, MSI 00
>     DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
>       ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
>     DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
>       RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
>       MaxPayload 256 bytes, MaxReadReq 512 bytes
>     DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
>     LnkCap: Port #0, Speed 2.5GT/s, Width x8, ASPM L0s L1, Latency L0 <4us,
> L1 <64us
>       ClockPM- Surprise- LLActRep- BwNot-
>     LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
>       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>     LnkSta: Speed 2.5GT/s, Width x8, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
>     DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
>     DevCtl2: Completion Timeout: 16ms to 55ms, TimeoutDis-
>     LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-,
> Selectable De-emphasis: -6dB
>        Transmit Margin: Normal Operating Range, EnterModifiedCompliance-
> ComplianceSOS-
>        Compliance De-emphasis: -6dB
>     LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
> EqualizationPhase1-
>        EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
>   Capabilities: [100 v1] Advanced Error Reporting
>     UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
> MalfTLP- ECRC- UnsupReq- ACSViol-
>     UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
> MalfTLP- ECRC- UnsupReq+ ACSViol-
>     UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
> MalfTLP+ ECRC- UnsupReq- ACSViol-
>     CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
>     CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
>     AERCap: First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
>   Capabilities: [140 v1] Device Serial Number XX-XX-XX-XX-XX-XX-XX-XX
> (masked)
>   Kernel driver in use: ixgbe
> 00: 86 80 0b 15 07 04 10 00 01 00 00 02 10 00 00 00
> 10: 00 00 e4 fb 00 00 e0 fb 01 e0 00 00 00 00 e6 fb
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 2c a1
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 00 00
>
> Justin.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
