From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: SR-IOV problem with Intel 82599EB (not enough MMIO resources
 for SR-IOV)
Date: Thu, 08 Nov 2012 03:23:24 -0800
Message-ID: <509B962C.6070002@gmail.com>
References: <201211081915083774239@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig5EB9C985A4D06E20EF09C0D6"
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, kvm <kvm@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net,
	Greg Rose <gregory.v.rose@intel.com>
To: "pkill.2012" <pkill.2012@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201211081915083774239@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig5EB9C985A4D06E20EF09C0D6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/08/2012 03:15 AM, pkill.2012 wrote:
> Hello,
> =20
> I installed kvm and tried to use SR-IOV virtualizaton for 82599EB(Intel=
 XT-520 T2) dual port card with latest ixgbe driver(version:3.11.33) ,=20
> kernel2.6.32-279.14.1(OS:Centos6.3) ,after configuration and reboot
> It seems that only first port of the card's VFs works,second port of th=
e card's VFs didn't work
> I found some errors in /var/log messages:
> =20
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.1: not enough MMIO resource=
s for SR-IOV
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.1: (unregistered net_device=
): Failed to enable PCI sriov: -12
> =20
> How to fix it,any help would be greatly appreciated.
> =20
> below is the related information:
> Server: R710
> OS: centos6.3
> NIC: X520-T2(dual port)
> kernel: 2.6.32-279.14.1.el6.x86_64
> BIOSVersion: 6.3.0(latest)
> BIOS:Inter VT/VT-d or SR-IOV(enabled)
> ixgbe:3.11.33(latest)
> ixgbevf:2.7.12(latest)
> grub config:intel_iommu=3Don appended
> =20
> /var/log/messages:
> Nov  8 14:56:54 12 kernel: Intel(R) 10 Gigabit PCI Express Network Driv=
er - version 3.11.33
> Nov  8 14:56:54 12 kernel: Copyright (c) 1999-2012 Intel Corporation.
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.0: PCI INT B -> GSI 50 (lev=
el, low) -> IRQ 50
> Nov  8 14:56:54 12 kernel: ixgbe: I/O Virtualization (IOV) set to 2
> Nov  8 14:56:54 12 kernel: ixgbe: 0000:07:00.0: ixgbe_check_options: FC=
oE Offload feature enabled
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.0: (unregistered net_device=
): SR-IOV enabled with 2 VFs
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.0: FCoE offload feature is =
not available. Disabling FCoE offload feature
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.0: (PCI Express:5.0GT/s:Wid=
th x8) 68:05:ca:0c:7a:e2
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.0: eth4: MAC: 2, PHY: 2, PB=
A No: G21371-003
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.0: eth4: Enabled Features: =
RxQ: 1 TxQ: 1 LRO
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.0: eth4: IOV: VF 0 is enabl=
ed mac 0E:15:B9:26:B3:7D
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.0: eth4: IOV: VF 1 is enabl=
ed mac 32:69:2D:16:B9:40
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.0: eth4: Intel(R) 10 Gigabi=
t Network Connection
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.1: PCI INT A -> GSI 40 (lev=
el, low) -> IRQ 40
> Nov  8 14:56:54 12 kernel: ixgbe: I/O Virtualization (IOV) set to 2
> Nov  8 14:56:54 12 kernel: ixgbe: 0000:07:00.1: ixgbe_check_options: FC=
oE Offload feature enabled
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.1: not enough MMIO resource=
s for SR-IOV
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.1: (unregistered net_device=
): Failed to enable PCI sriov: -12
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.1: FCoE offload feature is =
not available. Disabling FCoE offload feature
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.1: (PCI Express:5.0GT/s:Wid=
th x8) 68:05:ca:0c:7a:e3
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.1: eth5: MAC: 2, PHY: 2, PB=
A No: G21371-003
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.1: eth5: Enabled Features:
> RxQ: 16 TxQ: 16 FdirHash RSC
> Nov  8 14:56:54 12 kernel: ixgbe 0000:07:00.1: eth5: Intel(R) 10
> Gigabit Network Connection
> =20
> # dmesg |grep -E 'DMA|IOMMU'
> ACPI: DMAR 00000000bf3b3668 001C0 (v01 DELL   PE_SC3   00000001 DELL 00=
000001)
>   DMA      0x00000001 -> 0x00001000
>   DMA32    0x00001000 -> 0x00100000
>   DMA zone: 56 pages used for memmap
>   DMA zone: 102 pages reserved
>   DMA zone: 3839 pages, LIFO batch:0
>   DMA32 zone: 14280 pages used for memmap
>   DMA32 zone: 764849 pages, LIFO batch:31
> Intel-IOMMU: enabled
> DMAR: Host address width 40
> DMAR: DRHD base: 0x000000fed90000 flags: 0x1
> IOMMU fed90000: ver 1:0 cap c90780106f0462 ecap f020fe
> DMAR: RMRR base: 0x000000bf4c8000 end: 0x000000bf4dffff
> DMAR: RMRR base: 0x000000bf4b1000 end: 0x000000bf4bffff
> DMAR: RMRR base: 0x000000bf4a1000 end: 0x000000bf4a1fff
> DMAR: RMRR base: 0x000000bf4a3000 end: 0x000000bf4a3fff
> DMAR: RMRR base: 0x000000bf4a5000 end: 0x000000bf4a5fff
> DMAR: RMRR base: 0x000000bf4a7000 end: 0x000000bf4a7fff
> DMAR: RMRR base: 0x000000bf4c0000 end: 0x000000bf4c0fff
> DMAR: RMRR base: 0x000000bf4c2000 end: 0x000000bf4c2fff
> DMAR: ATSR flags: 0x0
> DMAR: Device scope device [0000:00:1a.02] not found
> DMAR: Device scope device [0000:00:1a.02] not found
> DMAR: Device scope device [0000:00:1d.02] not found
> DMAR: Device scope device [0000:00:1d.02] not found
> IOMMU 0xfed90000: using Queued invalidation
> IOMMU: Setting RMRR:
> IOMMU: Setting identity map for device 0000:00:1d.7 [0xbf4c2000 - 0xbf4=
c3000]
> IOMMU: Setting identity map for device 0000:00:1a.7 [0xbf4c0000 - 0xbf4=
c1000]
> IOMMU: Setting identity map for device 0000:00:1d.1 [0xbf4a7000 - 0xbf4=
a8000]
> IOMMU: Setting identity map for device 0000:00:1d.0 [0xbf4a5000 - 0xbf4=
a6000]
> IOMMU: Setting identity map for device 0000:00:1a.1 [0xbf4a3000 - 0xbf4=
a4000]
> IOMMU: Setting identity map for device 0000:00:1a.0 [0xbf4a1000 - 0xbf4=
a2000]
> IOMMU: Setting identity map for device 0000:00:1a.0 [0xbf4b1000 - 0xbf4=
c0000]
> IOMMU: Setting identity map for device 0000:00:1a.1 [0xbf4b1000 - 0xbf4=
c0000]
> IOMMU: Setting identity map for device 0000:00:1d.0 [0xbf4b1000 - 0xbf4=
c0000]
> IOMMU: Setting identity map for device 0000:00:1d.1 [0xbf4b1000 - 0xbf4=
c0000]
> IOMMU: Setting identity map for device 0000:00:1a.7 [0xbf4c8000 - 0xbf4=
e0000]
> IOMMU: Setting identity map for device 0000:00:1d.7 [0xbf4c8000 - 0xbf4=
e0000]
> IOMMU: Prepare 0-16MiB unity mapping for LPC
> IOMMU: Setting identity map for device 0000:00:1f.0 [0x0 - 0x1000000]
> PCI-DMA: Intel(R) Virtualization Technology for Directed I/O
> ata1: SATA max UDMA/133 cmd 0xdc10 ctl 0xdc08 bmdma 0xdc20 irq 23
> ata2: SATA max UDMA/133 cmd 0xdc18 ctl 0xdc0c bmdma 0xdc28 irq 23
> ata1.00: ATAPI: TSSTcorp DVD-ROM SN-108BB, D150, max UDMA/100
> ata1.00: configured for UDMA/100
> =20
> # lspci|grep Virtual
> 07:10.0 Ethernet controller: Intel Corporation 82599 Virtual Function (=
rev 01)
> 07:10.2 Ethernet controller: Intel Corporation 82599 Virtual Function (=
rev 01)
> =20
> #lspci|grep '82599EB'
> 07:00.0 Ethernet controller: Intel Corporation 82599EB 10 Gigabit TN
> Network Connection (rev 01)
> 07:00.1 Ethernet controller: Intel Corporation 82599EB 10 Gigabit TN
> Network Connection (rev 01)
> =20
> # lspci -n|grep 07:00
> 07:00.0 0200: 8086:151c (rev 01)
> 07:00.1 0200: 8086:151c (rev 01)
> =20
> # lspci -n -d 8086:151c -vvv|grep -i width
> LnkCap: Port #2, Speed 5GT/s, Width x8, ASPM L0s, Latency L0 <1us, L1 <=
8us
> LnkSta: Speed 5GT/s, Width x8, TrErr- Train- SlotClk+ DLActive- BWMgmt-=
 ABWMgmt-
> LnkCap: Port #2, Speed 5GT/s, Width x8, ASPM L0s, Latency L0 <1us, L1 <=
8us
> LnkSta: Speed 5GT/s, Width x8, TrErr- Train- SlotClk+ DLActive- BWMgmt-=
 ABWMgmt-
> =20
> #lspci -vvv -s 07:00
> 07:00.0 Ethernet controller: Intel Corporation 82599EB 10 Gigabit TN Ne=
twork Connection (rev 01)
> Subsystem: Intel Corporation Ethernet Server Adapter X520-T2
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Ste=
pping- SERR- FastB2B- DisINTx+
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbor=
t- <MAbort- >SERR- <PERR- INTx-
> Latency: 0, Cache Line Size: 64 bytes
> Interrupt: pin B routed to IRQ 50
> Region 0: Memory at de400000 (64-bit, non-prefetchable) [size=3D2M]
> Region 2: I/O ports at ecc0 [size=3D32]
> Region 4: Memory at de3f8000 (64-bit, non-prefetchable) [size=3D16K]
> Expansion ROM at de200000 [disabled] [size=3D1M]
> Capabilities: [40] Power Management version 3
> Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3c=
old+)
> Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D1 PME-
> Capabilities: [50] MSI: Enable- Count=3D1/1 Maskable+ 64bit+
> Address: 0000000000000000  Data: 0000
> Masking: 00000000  Pending: 00000000
> Capabilities: [70] MSI-X: Enable+ Count=3D64 Masked-
> Vector table: BAR=3D4 offset=3D00000000
> PBA: BAR=3D4 offset=3D00002000
> Capabilities: [a0] Express (v2) Endpoint, MSI 00
> DevCap: MaxPayload 512 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us=

> ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
> DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported+
> RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+ FLReset-
> MaxPayload 256 bytes, MaxReadReq 512 bytes
> DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
> LnkCap: Port #2, Speed 5GT/s, Width x8, ASPM L0s, Latency L0 <1us, L1 <=
8us
> ClockPM- Surprise- LLActRep- BwNot-
> LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> LnkSta: Speed 5GT/s, Width x8, TrErr- Train- SlotClk+ DLActive- BWMgmt-=
 ABWMgmt-
> DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
> DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis-
> LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectab=
le De-emphasis: -6dB
>  Transmit Margin: Normal Operating Range, EnterModifiedCompliance- Comp=
lianceSOS-
>  Compliance De-emphasis: -6dB
> LnkSta2: Current De-emphasis Level: -6dB
> Capabilities: [e0] Vital Product Data
> Unknown small resource type 06, will not decode more.
> Capabilities: [100] Advanced Error Reporting
> UESta: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP=
- ECRC- UnsupReq- ACSViol-
> UEMsk: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt+ UnxCmplt+ RxOF- MalfTLP=
- ECRC- UnsupReq- ACSViol-
> UESvrt: DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt- UnxCmplt- RxOF+ MalfTL=
P+ ECRC+ UnsupReq- ACSViol-
> CESta: RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
> CEMsk: RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalErr+
> AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
> Capabilities: [140] Device Serial Number 68-05-ca-ff-ff-0c-7a-e2
> Capabilities: [150] Alternative Routing-ID Interpretation (ARI)
> ARICap: MFVC- ACS-, Next Function: 1
> ARICtl: MFVC- ACS-, Function Group: 0
> Capabilities: [160] Single Root I/O Virtualization (SR-IOV)
> IOVCap: Migration-, Interrupt Message Number: 000
> IOVCtl: Enable+ Migration- Interrupt- MSE+ ARIHierarchy+
> IOVSta: Migration-
> Initial VFs: 64, Total VFs: 64, Number of VFs: 2, Function Dependency L=
ink: 00
> VF offset: 128, stride: 2, Device ID: 10ed
> Supported Page Size: 00000553, System Page Size: 00000001
> Region 0: Memory at 00000000d5900000 (64-bit, prefetchable)
> Region 3: Memory at 00000000d5a00000 (64-bit, prefetchable)
> VF Migration: offset: 00000000, BIR: 0
> Kernel driver in use: ixgbe
> Kernel modules: ixgbe
> 07:00.1 Ethernet controller: Intel Corporation 82599EB 10 Gigabit TN Ne=
twork Connection (rev 01)
> Subsystem: Intel Corporation Ethernet Server Adapter X520-T2
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Ste=
pping- SERR- FastB2B- DisINTx+
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbor=
t- <MAbort- >SERR- <PERR- INTx-
> Latency: 0, Cache Line Size: 64 bytes
> Interrupt: pin A routed to IRQ 40
> Region 0: Memory at de600000 (64-bit, non-prefetchable) [size=3D2M]
> Region 2: I/O ports at ece0 [size=3D32]
> Region 4: Memory at de3fc000 (64-bit, non-prefetchable) [size=3D16K]
> Expansion ROM at d5800000 [disabled] [size=3D1M]
> Capabilities: [40] Power Management version 3
> Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3c=
old+)
> Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D1 PME-
> Capabilities: [50] MSI: Enable- Count=3D1/1 Maskable+ 64bit+
> Address: 0000000000000000  Data: 0000
> Masking: 00000000  Pending: 00000000
> Capabilities: [70] MSI-X: Enable+ Count=3D64 Masked-
> Vector table: BAR=3D4 offset=3D00000000
> PBA: BAR=3D4 offset=3D00002000
> Capabilities: [a0] Express (v2) Endpoint, MSI 00
> DevCap: MaxPayload 512 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us=

> ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
> DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported+
> RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+ FLReset-
> MaxPayload 256 bytes, MaxReadReq 512 bytes
> DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
> LnkCap: Port #2, Speed 5GT/s, Width x8, ASPM L0s, Latency L0 <1us, L1 <=
8us
> ClockPM- Surprise- LLActRep- BwNot-
> LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> LnkSta: Speed 5GT/s, Width x8, TrErr- Train- SlotClk+ DLActive- BWMgmt-=
 ABWMgmt-
> DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
> DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis-
> LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Select=
able De-emphasis: -6dB
>  Transmit Margin: Normal Operating Range, EnterModifiedCompliance- Comp=
lianceSOS-
>  Compliance De-emphasis: -6dB
> LnkSta2: Current De-emphasis Level: -6dB
> Capabilities: [e0] Vital Product Data
> Unknown small resource type 06, will not decode more.
> Capabilities: [100] Advanced Error Reporting
> UESta: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP=
- ECRC- UnsupReq- ACSViol-
> UEMsk: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt+ UnxCmplt+ RxOF- MalfTLP=
- ECRC- UnsupReq- ACSViol-
> UESvrt: DLP+ SDES- TLP+ FCP+ CmpltTO+ CmpltAbrt- UnxCmplt- RxOF+ MalfTL=
P+ ECRC+ UnsupReq- ACSViol-
> CESta: RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
> CEMsk: RxErr+ BadTLP+ BadDLLP+ Rollover+ Timeout+ NonFatalErr+
> AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
> Capabilities: [140] Device Serial Number 68-05-ca-ff-ff-0c-7a-e2
> Capabilities: [150] Alternative Routing-ID Interpretation (ARI)
> ARICap: MFVC- ACS-, Next Function: 0
> ARICtl: MFVC- ACS-, Function Group: 0
> Capabilities: [160] Single Root I/O Virtualization (SR-IOV)
> IOVCap: Migration-, Interrupt Message Number: 000
> IOVCtl: Enable- Migration- Interrupt- MSE- ARIHierarchy-
> IOVSta: Migration-
> Initial VFs: 64, Total VFs: 64, Number of VFs: 2, Function Dependency L=
ink: 01
> VF offset: 128, stride: 2, Device ID: 10ed
> Supported Page Size: 00000553, System Page Size: 00000001
> Region 0: Memory at 00000000d5b00000 (64-bit, prefetchable)
> Region 3: Memory at 00000000d5b00000 (64-bit, prefetchable)
> VF Migration: offset: 00000000, BIR: 0
> Kernel driver in use: ixgbe
> Kernel modules: ixgbe
> =20
> #modinfo ixgbe
> filename:       /lib/modules/2.6.32-279.14.1.el6.x86_64/kernel/drivers/=
net/ixgbe/ixgbe.ko
> version:        3.11.33
> license:        GPL
> description:    Intel(R) 10 Gigabit PCI Express Network Driver
> author:         Intel Corporation, <linux.nics@intel.com>
> srcversion:     ADDCBFA6FAFE8A0299074F8
> alias:          pci:v00008086d0000154Asv*sd*bc*sc*i*
> alias:          pci:v00008086d00001557sv*sd*bc*sc*i*
> alias:          pci:v00008086d0000154Fsv*sd*bc*sc*i*
> alias:          pci:v00008086d0000154Dsv*sd*bc*sc*i*
> alias:          pci:v00008086d00001528sv*sd*bc*sc*i*
> alias:          pci:v00008086d000010F8sv*sd*bc*sc*i*
> alias:          pci:v00008086d0000151Csv*sd*bc*sc*i*
> alias:          pci:v00008086d00001529sv*sd*bc*sc*i*
> alias:          pci:v00008086d0000152Asv*sd*bc*sc*i*
> alias:          pci:v00008086d000010F9sv*sd*bc*sc*i*
> alias:          pci:v00008086d00001514sv*sd*bc*sc*i*
> alias:          pci:v00008086d00001507sv*sd*bc*sc*i*
> alias:          pci:v00008086d000010FBsv*sd*bc*sc*i*
> alias:          pci:v00008086d00001517sv*sd*bc*sc*i*
> alias:          pci:v00008086d000010FCsv*sd*bc*sc*i*
> alias:          pci:v00008086d000010F7sv*sd*bc*sc*i*
> alias:          pci:v00008086d00001508sv*sd*bc*sc*i*
> alias:          pci:v00008086d000010DBsv*sd*bc*sc*i*
> alias:          pci:v00008086d000010F4sv*sd*bc*sc*i*
> alias:          pci:v00008086d000010E1sv*sd*bc*sc*i*
> alias:          pci:v00008086d000010F1sv*sd*bc*sc*i*
> alias:          pci:v00008086d000010ECsv*sd*bc*sc*i*
> alias:          pci:v00008086d000010DDsv*sd*bc*sc*i*
> alias:          pci:v00008086d0000150Bsv*sd*bc*sc*i*
> alias:          pci:v00008086d000010C8sv*sd*bc*sc*i*
> alias:          pci:v00008086d000010C7sv*sd*bc*sc*i*
> alias:          pci:v00008086d000010C6sv*sd*bc*sc*i*
> alias:          pci:v00008086d000010B6sv*sd*bc*sc*i*
> depends:        dca
> vermagic:       2.6.32-279.14.1.el6.x86_64 SMP mod_unload modversions=20
> parm:           InterruptType:Change Interrupt Mode (0=3DLegacy, 1=3DMS=
I, 2=3DMSI-X), default IntMode (deprecated) (array of int)
> parm:           IntMode:Change Interrupt Mode (0=3DLegacy, 1=3DMSI, 2=3D=
MSI-X), default 2 (array of int)
> parm:           MQ:Disable or enable Multiple Queues, default 1 (array =
of int)
> parm:           DCA:Disable or enable Direct Cache Access, 0=3Ddisabled=
, 1=3Ddescriptor only, 2=3Ddescriptor and data (array of int)
> parm:           RSS:Number of Receive-Side Scaling Descriptor Queues, d=
efault 0=3Dnumber of cpus (array of int)
> parm:           VMDQ:Number of Virtual Machine Device Queues: 0/1 =3D d=
isable, 2-16 enable (default=3D8) (array of int)
> parm:           max_vfs:Number of Virtual Functions: 0 =3D disable (def=
ault), 1-63 =3D enable this many VFs (array of int)
> parm:           L2LBen:L2 Loopback Enable: 0 =3D disable, 1 =3D enable =
(default) (array of int)
> parm:           InterruptThrottleRate:Maximum interrupts per second, pe=
r vector, (0,1,956-488281), default 1 (array of int)
> parm:           LLIPort:Low Latency Interrupt TCP Port (0-65535) (array=
 of int)
> parm:           LLIPush:Low Latency Interrupt on TCP Push flag (0,1) (a=
rray of int)
> parm:           LLISize:Low Latency Interrupt on Packet Size (0-1500) (=
array of int)
> parm:           LLIEType:Low Latency Interrupt Ethernet Protocol Type (=
array of int)
> parm:           LLIVLANP:Low Latency Interrupt on VLAN priority thresho=
ld (array of int)
> parm:           FdirPballoc:Flow Director packet buffer allocation leve=
l:
> 1 =3D 8k hash filters or 2k perfect filters
> 2 =3D 16k hash filters or 4k perfect filters
> 3 =3D 32k hash filters or 8k perfect filters (array of int)
> parm:           AtrSampleRate:Software ATR Tx packet sample rate (array=
 of int)
> parm:           FCoE:Disable or enable FCoE Offload, default 1 (array o=
f int)
> parm:           LRO:Large Receive Offload (0,1), default 1 =3D on (arra=
y of int)
> parm:           allow_unsupported_sfp:Allow unsupported and untested SF=
P+ modules on 82599 based adapters, default 0 =3D Disable (array of int)
> =20
> # modinfo ixgbevf
> filename:       /lib/modules/2.6.32-279.14.1.el6.x86_64/kernel/drivers/=
net/ixgbevf/ixgbevf.ko
> version:        2.7.12
> license:        GPL
> description:    Intel(R) 10 Gigabit PCI Express Virtual Function Networ=
k Driver
> author:         Intel Corporation, <linux.nics@intel.com>
> srcversion:     4D00B4A5B811D6D07D8BD15
> alias:          pci:v00008086d00001515sv*sd*bc*sc*i*
> alias:          pci:v00008086d000010EDsv*sd*bc*sc*i*
> depends:       =20
> vermagic:       2.6.32-279.14.1.el6.x86_64 SMP mod_unload modversions=20
> parm:           InterruptThrottleRate:Maximum interrupts per second, pe=
r vector, (956-488281), default 8000, use 1 for dynamic (array of int)
> =20
> =20
> # dmidecode -t bios
> # dmidecode 2.11
> SMBIOS 2.6 present.
> Handle 0x0000, DMI type 0, 24 bytes
> BIOS Information
>         Vendor: Dell Inc.
>         Version: 6.3.0
>         Release Date: 07/24/2012
>         Address: 0xF0000
>         Runtime Size: 64 kB
>         ROM Size: 4096 kB
>         Characteristics:
>                 ISA is supported
>                 PCI is supported
>                 PNP is supported
>                 BIOS is upgradeable
>                 BIOS shadowing is allowed
>                 Boot from CD is supported
>                 Selectable boot is supported
>                 EDD is supported
>                 Japanese floppy for Toshiba 1.2 MB is supported (int 13=
h)
>                 5.25"/360 kB floppy services are supported (int 13h)
>                 5.25"/1.2 MB floppy services are supported (int 13h)
>                 3.5"/720 kB floppy services are supported (int 13h)
>                 8042 keyboard services are supported (int 9h)
>                 Serial services are supported (int 14h)
>                 CGA/mono video services are supported (int 10h)
>                 ACPI is supported
>                 USB legacy is supported
>                 BIOS boot specification is supported
>                 Function key-initiated network boot is supported
>                 Targeted content distribution is supported
>         BIOS Revision: 6.3
> Handle 0x0D00, DMI type 13, 22 bytes
> BIOS Language Information
>         Language Description Format: Long
>         Installable Languages: 1
>                 en|US|iso8859-1
>         Currently Installed Language: en|US|iso8859-1
> =20
> Jason Gao
> --
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
Adding e100-devel mailing list


--------------enig5EB9C985A4D06E20EF09C0D6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iQIcBAEBCgAGBQJQm5YsAAoJEOVv75VaS+3OLcEP/RS4sNSKwohvlg45PoeBRMmE
sbgSilFvrJXxzr+dhvSvn8iHxOmd4GlC0mAraOudhuAcss+sE7sC481JKOCHLhHL
BSlr74sy+Tbb49ybp7noGhx+qVS3rX2mciH8TylwkgXtAAvYK0o7ubIOaNNu4k7t
AQWqkJRd4Co319OF/a11dCJ/zFN7P3TImXZ9Juq9nP2a9PwxVtkhz/xlBGLEXJtG
pP/eF2OGMABLNEjTpReIZbwJEElH3nRC2DZvBsURrK6Y/Vh9tcTDtuVB7++vaFrk
Qu2tE26s1/yvuBkfnAHrjnWXEH4pjhSv9aDd3WtTBqej1nPSfPYJI17+kedtgkZh
cOx1OqMX7M/BN72bRN1CMCERdBkjhZ7niDiseu3r3efrsHoruV04QemmSivk0Vvu
e1/ztEA9iHqzr4OJsjFkujzalYiIR6JrZUUG3sfu0kU9MdqvCA5Zo4avO7AgASEP
D1i2T1umubNExlsWV/5tqpFBEQMjTGyf4jtUykJVnFuOnt7q1NXSmqwdCFcbskD/
GDNIeMNTG/wyPxsDRRfLxWXvwPk86cr5L1QCJlLUTfNXYA9UMBNwt7uDsJAEhRH2
aQH2cZkxUzXDwjZCqiwyTGfpG6S9QEknhCc7KICrOxEzy73aFsD0d9jOlvm5fwbx
tw8/mNh3m4FDgtjgAe+G
=IzLw
-----END PGP SIGNATURE-----

--------------enig5EB9C985A4D06E20EF09C0D6--
