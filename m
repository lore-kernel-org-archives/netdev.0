From: Dmitry Kasatkin <dmitry.kasatkin@gmail.com>
Subject: Re: throughput problems with realtek
Date: Wed, 15 Jan 2014 14:04:54 +0200
Message-ID: <CACE9dm_xg68Py=Aigb=ZrPOWpDwKc_OBd2vgE-sdiEkKXLp_dA@mail.gmail.com>
References: <CACE9dm_3jw08_dfXRJRMQ=r4X1NZ1kHF6TZopFSNy3k+DCKgTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: l.moiseichuk@samsung.com
To: nic_swsd@realtek.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:33094 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbaAOME4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 07:04:56 -0500
Received: by mail-wg0-f41.google.com with SMTP id n12so5040596wgh.4
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 04:04:55 -0800 (PST)
In-Reply-To: <CACE9dm_3jw08_dfXRJRMQ=r4X1NZ1kHF6TZopFSNy3k+DCKgTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Forgot to tell, I am running Ubuntu 13.10 with 3.11.0-15 kernel...


On Wed, Jan 15, 2014 at 1:56 PM, Dmitry Kasatkin
<dmitry.kasatkin@gmail.com> wrote:
> Hi,
>
> We have several devices with such adapter..
>
> Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411
> PCI Express Gigabit Ethernet Controller (rev 06)
> See output of the lspci -vvv bellow...
>
> And I suddenly investigated throughput issues..
>
> After couple minutes of running 'iperf -c server' transmission speed
> drops substantially...
>
> [  4]  0.0-10.0 sec  1.10 GBytes   948 Mbits/sec
> [  5] local 106.122.1.113 port 5001 connected with 106.122.1.121 port 60508
> [  5]  0.0-10.0 sec  1.10 GBytes   948 Mbits/sec
> [  4] local 106.122.1.113 port 5001 connected with 106.122.1.121 port 60509
> [  4]  0.0-10.0 sec  1.10 GBytes   949 Mbits/sec
> [  5] local 106.122.1.113 port 5001 connected with 106.122.1.121 port 60510
> [  5]  0.0-10.0 sec  1.10 GBytes   948 Mbits/sec
> [  4] local 106.122.1.113 port 5001 connected with 106.122.1.121 port 60511
> [  4]  0.0-10.0 sec   626 MBytes   525 Mbits/sec
> [  5] local 106.122.1.113 port 5001 connected with 106.122.1.121 port 60512
> [  5]  0.0-10.0 sec  84.4 MBytes  70.5 Mbits/sec
> [  4] local 106.122.1.113 port 5001 connected with 106.122.1.121 port 60513
> [  4]  0.0-10.0 sec  87.4 MBytes  73.0 Mbits/sec
> [  5] local 106.122.1.113 port 5001 connected with 106.122.1.121 port 60514
>
>
> But it seems after certain time of inactivity (low load) speed will be
> up again...
>
> It happens almost the same way on desktop machines and also on Samsung
> Series 7 laptop NP770Z5E...
>
> Does anyone have any ideas about it?
>
> --
> Thanks,
> Dmitry
>
> ---------------------------
>
> 03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 06)
> Subsystem: Samsung Electronics Co Ltd Device c0e6
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0, Cache Line Size: 64 bytes
> Interrupt: pin A routed to IRQ 45
> Region 0: I/O ports at d000 [size=256]
> Region 2: Memory at f0004000 (64-bit, prefetchable) [size=4K]
> Region 4: Memory at f0000000 (64-bit, prefetchable) [size=16K]
> Capabilities: [40] Power Management version 3
> Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
> Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
> Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
> Address: 00000000fee00338  Data: 0000
> Capabilities: [70] Express (v2) Endpoint, MSI 01
> DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
> ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> MaxPayload 128 bytes, MaxReadReq 4096 bytes
> DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
> unlimited, L1 <64us
> ClockPM+ Surprise- LLActRep- BwNot-
> LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
> DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
> DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
> LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-,
> Selectable De-emphasis: -6dB
> Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
> Compliance De-emphasis: -6dB
> LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
> EqualizationPhase1-
> EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> Capabilities: [b0] MSI-X: Enable- Count=4 Masked-
> Vector table: BAR=4 offset=00000000
> PBA: BAR=4 offset=00000800
> Capabilities: [d0] Vital Product Data
> No end tag found
> Capabilities: [100 v1] Advanced Error Reporting
> UESta: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
> MalfTLP- ECRC- UnsupReq- ACSViol-
> UEMsk: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
> MalfTLP- ECRC- UnsupReq- ACSViol-
> UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
> MalfTLP+ ECRC- UnsupReq- ACSViol-
> CESta: RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
> CEMsk: RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
> AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
> Capabilities: [140 v1] Virtual Channel
> Caps: LPEVC=0 RefClk=100ns PATEntryBits=1
> Arb: Fixed- WRR32- WRR64- WRR128-
> Ctrl: ArbSelect=Fixed
> Status: InProgress-
> VC0: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
> Arb: Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
> Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
> Status: NegoPending- InProgress-
> Capabilities: [160 v1] Device Serial Number 01-00-00-00-68-4c-e0-00
> Kernel driver in use: r8169



-- 
Thanks,
Dmitry
