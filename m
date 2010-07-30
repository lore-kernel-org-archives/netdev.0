From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: Re: e1000e crashes with 2.6.34.x and ThinkPad T60
Date: Fri, 30 Jul 2010 14:56:14 +0200
Message-ID: <20100730125614.GB21444@torres.zugschlus.de>
References: <20100724092644.GA13353@torres.zugschlus.de> <8DD2590731AB5D4C9DBF71A877482A9001623EC48E@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="CdrF4e02JqNVZeln"
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:55042 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892Ab0G3M4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jul 2010 08:56:16 -0400
Content-Disposition: inline
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A9001623EC48E@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--CdrF4e02JqNVZeln
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On Mon, Jul 26, 2010 at 09:13:45AM -0700, Allan, Bruce W wrote:
> Adding e1000-devel (the Intel LAN developers list).
> 
> Please supply the full dmesg you meant to attach with the original
> report, as well as the output of lspci -vvv.

Stupid me.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190

--CdrF4e02JqNVZeln
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename=lspci-vvv

00:00.0 Host bridge: Intel Corporation Mobile 945GM/PM/GMS, 943/940GML and 945GT Express Memory Controller Hub (rev 03)
	Subsystem: Lenovo ThinkPad T60
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: <access denied>

00:01.0 PCI bridge: Intel Corporation Mobile 945GM/PM/GMS, 943/940GML and 945GT Express PCI Express Root Port (rev 03) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: ee100000-ee1fffff
	Prefetchable memory behind bridge: 00000000d8000000-00000000dfffffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:1b.0 Audio device: Intel Corporation N10/ICH 7 Family High Definition Audio Controller (rev 02)
	Subsystem: Lenovo ThinkPad T60/R60 series
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin B routed to IRQ 29
	Region 0: Memory at ee400000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: <access denied>
	Kernel driver in use: HDA Intel

00:1c.0 PCI bridge: Intel Corporation N10/ICH 7 Family PCI Express Port 1 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 00003000-00003fff
	Memory behind bridge: ee000000-ee0fffff
	Prefetchable memory behind bridge: 00000000c0000000-00000000c01fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:1c.1 PCI bridge: Intel Corporation N10/ICH 7 Family PCI Express Port 2 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
	I/O behind bridge: 00004000-00005fff
	Memory behind bridge: ec000000-edffffff
	Prefetchable memory behind bridge: 00000000e4000000-00000000e40fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:1c.2 PCI bridge: Intel Corporation N10/ICH 7 Family PCI Express Port 3 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=04, subordinate=0b, sec-latency=0
	I/O behind bridge: 00006000-00007fff
	Memory behind bridge: e8000000-e9ffffff
	Prefetchable memory behind bridge: 00000000e4100000-00000000e41fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:1c.3 PCI bridge: Intel Corporation N10/ICH 7 Family PCI Express Port 4 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=0c, subordinate=13, sec-latency=0
	I/O behind bridge: 00008000-00009fff
	Memory behind bridge: ea000000-ebffffff
	Prefetchable memory behind bridge: 00000000e4200000-00000000e42fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:1d.0 USB Controller: Intel Corporation N10/ICH 7 Family USB UHCI Controller #1 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Lenovo ThinkPad T60/R60 series
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 16
	Region 4: I/O ports at 1800 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.1 USB Controller: Intel Corporation N10/ICH 7 Family USB UHCI Controller #2 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Lenovo ThinkPad T60/R60 series
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 17
	Region 4: I/O ports at 1820 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.2 USB Controller: Intel Corporation N10/ICH 7 Family USB UHCI Controller #3 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Lenovo ThinkPad T60/R60 series
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 4: I/O ports at 1840 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.3 USB Controller: Intel Corporation N10/ICH 7 Family USB UHCI Controller #4 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Lenovo ThinkPad T60/R60 series
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 19
	Region 4: I/O ports at 1860 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.7 USB Controller: Intel Corporation N10/ICH 7 Family USB2 EHCI Controller (rev 02) (prog-if 20 [EHCI])
	Subsystem: Lenovo ThinkPad T60/R60 series
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 19
	Region 0: Memory at ee404000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: <access denied>
	Kernel driver in use: ehci_hcd

00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev e2) (prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=00, secondary=15, subordinate=18, sec-latency=32
	I/O behind bridge: 0000a000-0000dfff
	Memory behind bridge: e4300000-e7ffffff
	Prefetchable memory behind bridge: 00000000e0000000-00000000e3ffffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>

00:1f.0 ISA bridge: Intel Corporation 82801GBM (ICH7-M) LPC Interface Bridge (rev 02)
	Subsystem: Lenovo ThinkPad T60/R60 series
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: <access denied>

00:1f.1 IDE interface: Intel Corporation 82801G (ICH7 Family) IDE Controller (rev 02) (prog-if 8a [Master SecP PriP])
	Subsystem: Lenovo ThinkPad T60/R60 series
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 16
	Region 0: I/O ports at 01f0 [size=8]
	Region 1: I/O ports at 03f4 [size=1]
	Region 2: I/O ports at 0170 [size=8]
	Region 3: I/O ports at 0374 [size=1]
	Region 4: I/O ports at 1880 [size=16]
	Kernel driver in use: ata_piix

00:1f.2 SATA controller: Intel Corporation 82801GBM/GHM (ICH7 Family) SATA AHCI Controller (rev 02) (prog-if 01 [AHCI 1.0])
	Subsystem: Lenovo ThinkPad T60/R60 series
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 30
	Region 0: I/O ports at 18c8 [size=8]
	Region 1: I/O ports at 18ac [size=4]
	Region 2: I/O ports at 18c0 [size=8]
	Region 3: I/O ports at 18a8 [size=4]
	Region 4: I/O ports at 18b0 [size=16]
	Region 5: Memory at ee404400 (32-bit, non-prefetchable) [size=1K]
	Capabilities: <access denied>
	Kernel driver in use: ahci

00:1f.3 SMBus: Intel Corporation N10/ICH 7 Family SMBus Controller (rev 02)
	Subsystem: Lenovo ThinkPad T60/R60 series
	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin A routed to IRQ 23
	Region 4: I/O ports at 18e0 [size=32]
	Kernel driver in use: i801_smbus

01:00.0 VGA compatible controller: ATI Technologies Inc Radeon Mobility X1400 (prog-if 00 [VGA controller])
	Subsystem: Lenovo Thinkpad T60 model 2007
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 31
	Region 0: Memory at d8000000 (32-bit, prefetchable) [size=128M]
	Region 1: I/O ports at 2000 [size=256]
	Region 2: Memory at ee100000 (32-bit, non-prefetchable) [size=64K]
	[virtual] Expansion ROM at ee120000 [disabled] [size=128K]
	Capabilities: <access denied>
	Kernel driver in use: radeon

02:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Controller
	Subsystem: Lenovo ThinkPad T60
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 33
	Region 0: Memory at ee000000 (32-bit, non-prefetchable) [size=128K]
	Region 2: I/O ports at 3000 [size=32]
	Capabilities: <access denied>
	Kernel driver in use: e1000e

03:00.0 Network controller: Intel Corporation PRO/Wireless 3945ABG [Golan] Network Connection (rev 02)
	Subsystem: Intel Corporation ThinkPad R60e/X60s
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 32
	Region 0: Memory at edf00000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: <access denied>
	Kernel driver in use: iwl3945

15:00.0 CardBus bridge: Texas Instruments PCI1510 PC card Cardbus Controller
	Subsystem: Lenovo ThinkPad T60/R60 series
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 168, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at e4300000 (32-bit, non-prefetchable) [size=4K]
	Bus: primary=15, secondary=16, subordinate=17, sec-latency=176
	Memory window 0: e0000000-e3fff000 (prefetchable)
	Memory window 1: c4000000-c7fff000
	I/O window 0: 0000a000-0000a0ff
	I/O window 1: 0000a400-0000a4ff
	BridgeCtl: Parity- SERR- ISA- VGA- MAbort- >Reset+ 16bInt+ PostWrite+
	16-bit legacy interface ports at 0001
	Kernel driver in use: yenta_cardbus


--CdrF4e02JqNVZeln
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="dmesg.e1000e"

g unused kernel memory: 456k freed
[    5.136990] Write protecting the kernel text: 2632k
[    5.137063] Write protecting the kernel read-only data: 900k
[    5.195608] udev: starting version 158
[    5.305722] acpi device:05: registered as cooling_device2
[    5.305918] input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/device:04/LNXVIDEO:01/input/input4
[    5.305926] ACPI: Video Device [VID1] (multi-head: yes  rom: no  post: no)
[    5.325995] uhci_hcd: USB Universal Host Controller Interface driver
[    5.326260] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    5.326263] Warning! ehci_hcd should always be loaded before uhci_hcd and ohci_hcd, not after
[    5.326375] uhci_hcd 0000:00:1d.0: power state changed by ACPI to D0
[    5.326640] uhci_hcd 0000:00:1d.0: power state changed by ACPI to D0
[    5.326651] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    5.326661] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    5.326665] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    5.326730] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 1
[    5.326773] uhci_hcd 0000:00:1d.0: irq 16, io base 0x00001800
[    5.326820] usb usb1: New USB device found, idVendor=1d6b, idProduct=0001
[    5.326823] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.326826] usb usb1: Product: UHCI Host Controller
[    5.326829] usb usb1: Manufacturer: Linux 2.6.34.1-zgws1 uhci_hcd
[    5.326831] usb usb1: SerialNumber: 0000:00:1d.0
[    5.326940] hub 1-0:1.0: USB hub found
[    5.326946] hub 1-0:1.0: 2 ports detected
[    5.327182] ehci_hcd 0000:00:1d.7: power state changed by ACPI to D0
[    5.327347] ehci_hcd 0000:00:1d.7: power state changed by ACPI to D0
[    5.327359] ehci_hcd 0000:00:1d.7: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    5.327375] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    5.327380] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    5.327420] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
[    5.327439] ehci_hcd 0000:00:1d.7: using broken periodic workaround
[    5.327452] ehci_hcd 0000:00:1d.7: debug port 1
[    5.331327] ehci_hcd 0000:00:1d.7: cache line size of 64 is not supported
[    5.331343] ehci_hcd 0000:00:1d.7: irq 19, io mem 0xee404000
[    5.336651] Linux agpgart interface v0.103
[    5.339991] e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
[    5.339994] e1000e: Copyright (c) 1999 - 2009 Intel Corporation.
[    5.340095] e1000e 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    5.340120] e1000e 0000:02:00.0: setting latency timer to 64
[    5.340309] e1000e 0000:02:00.0: irq 29 for MSI/MSI-X
[    5.340699] e1000e 0000:02:00.0: Disabling ASPM L0s 
[    5.344102] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    5.344105] libata version 3.00 loaded.
[    5.344138] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    5.344142] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.344145] usb usb2: Product: EHCI Host Controller
[    5.344148] usb usb2: Manufacturer: Linux 2.6.34.1-zgws1 ehci_hcd
[    5.344150] usb usb2: SerialNumber: 0000:00:1d.7
[    5.344357] hub 2-0:1.0: USB hub found
[    5.344364] hub 2-0:1.0: 8 ports detected
[    5.344482] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    5.344490] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    5.344495] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    5.344535] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
[    5.344577] uhci_hcd 0000:00:1d.1: irq 17, io base 0x00001820
[    5.344615] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    5.344618] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.344621] usb usb3: Product: UHCI Host Controller
[    5.344623] usb usb3: Manufacturer: Linux 2.6.34.1-zgws1 uhci_hcd
[    5.344626] usb usb3: SerialNumber: 0000:00:1d.1
[    5.344720] hub 3-0:1.0: USB hub found
[    5.344725] hub 3-0:1.0: 2 ports detected
[    5.347870] uhci_hcd 0000:00:1d.2: power state changed by ACPI to D0
[    5.348150] uhci_hcd 0000:00:1d.2: power state changed by ACPI to D0
[    5.348161] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    5.348169] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    5.348174] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    5.348225] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
[    5.348262] uhci_hcd 0000:00:1d.2: irq 18, io base 0x00001840
[    5.348306] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[    5.348309] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.348312] usb usb4: Product: UHCI Host Controller
[    5.348314] usb usb4: Manufacturer: Linux 2.6.34.1-zgws1 uhci_hcd
[    5.348317] usb usb4: SerialNumber: 0000:00:1d.2
[    5.348420] hub 4-0:1.0: USB hub found
[    5.348425] hub 4-0:1.0: 2 ports detected
[    5.348500] ata_piix 0000:00:1f.1: version 2.13
[    5.348510] ata_piix 0000:00:1f.1: PCI INT C -> GSI 16 (level, low) -> IRQ 16
[    5.348554] ata_piix 0000:00:1f.1: setting latency timer to 64
[    5.348648] scsi0 : ata_piix
[    5.348747] scsi1 : ata_piix
[    5.349523] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x1880 irq 14
[    5.349527] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x1888 irq 15
[    5.349577] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    5.349585] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    5.349589] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    5.349640] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
[    5.349669] uhci_hcd 0000:00:1d.3: irq 19, io base 0x00001860
[    5.349711] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    5.349714] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.349717] usb usb5: Product: UHCI Host Controller
[    5.349720] usb usb5: Manufacturer: Linux 2.6.34.1-zgws1 uhci_hcd
[    5.349723] usb usb5: SerialNumber: 0000:00:1d.3
[    5.349830] hub 5-0:1.0: USB hub found
[    5.349836] hub 5-0:1.0: 2 ports detected
[    5.350121] ata2: port disabled. ignoring.
[    5.431411] ahci 0000:00:1f.2: version 3.0
[    5.431430] ahci 0000:00:1f.2: PCI INT B -> GSI 16 (level, low) -> IRQ 16
[    5.431485] ahci 0000:00:1f.2: irq 30 for MSI/MSI-X
[    5.431560] ahci 0000:00:1f.2: AHCI 0001.0100 32 slots 4 ports 1.5 Gbps 0x1 impl SATA mode
[    5.431564] ahci 0000:00:1f.2: flags: 64bit ncq pm led clo pio slum part 
[    5.431570] ahci 0000:00:1f.2: setting latency timer to 64
[    5.431727] scsi2 : ahci
[    5.431804] scsi3 : ahci
[    5.431867] scsi4 : ahci
[    5.431940] scsi5 : ahci
[    5.432058] ata3: SATA max UDMA/133 abar m1024@0xee404400 port 0xee404500 irq 30
[    5.432061] ata4: DUMMY
[    5.432062] ata5: DUMMY
[    5.432064] ata6: DUMMY
[    5.457464] 0000:02:00.0: eth0: (PCI Express:2.5GB/s:Width x1) 00:1e:37:da:7d:6b
[    5.457468] 0000:02:00.0: eth0: Intel(R) PRO/1000 Network Connection
[    5.457606] 0000:02:00.0: eth0: MAC: 2, PHY: 2, PBA No: 005301-003
[    5.512573] ata1.00: ATAPI: DVD/CDRW UJDA775, CB03, max UDMA/33
[    5.528495] ata1.00: configured for UDMA/33
[    5.530345] scsi 0:0:0:0: CD-ROM            MATSHITA DVD/CDRW UJDA775 CB03 PQ: 0 ANSI: 5
[    5.657080] usb 2-5: new high speed USB device using ehci_hcd and address 2
[    5.748096] ata3: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    5.749280] ata3.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) succeeded
[    5.749285] ata3.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZE LOCK) filtered out
[    5.749289] ata3.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) filtered out
[    5.750372] ata3.00: ATA-8: Hitachi HTS545050B9A300, PB4OC64G, max UDMA/133
[    5.750375] ata3.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    5.751707] ata3.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) succeeded
[    5.751712] ata3.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZE LOCK) filtered out
[    5.751716] ata3.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) filtered out
[    5.752839] ata3.00: configured for UDMA/133
[    5.770575] ata3.00: configured for UDMA/133
[    5.770578] ata3: EH complete
[    5.770658] scsi 2:0:0:0: Direct-Access     ATA      Hitachi HTS54505 PB4O PQ: 0 ANSI: 5
[    5.779704] sd 2:0:0:0: [sda] 976773168 512-byte logical blocks: (500 GB/465 GiB)
[    5.779774] sd 2:0:0:0: [sda] Write Protect is off
[    5.779777] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    5.779806] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    5.779969]  sda:
[    5.790425] usb 2-5: New USB device found, idVendor=14cd, idProduct=121c
[    5.790432] usb 2-5: New USB device strings: Mfr=1, Product=3, SerialNumber=2
[    5.790438] usb 2-5: Product: Mass Storage Device
[    5.790443] usb 2-5: Manufacturer: Generic
[    5.790448] usb 2-5: SerialNumber: 812320090519
[    5.798461] Initializing USB Mass Storage driver...
[    5.798567] scsi6 : usb-storage 2-5:1.0
[    5.798660] usbcore: registered new interface driver usb-storage
[    5.798663] USB Mass Storage support registered.
[    5.900051] usb 2-6: new high speed USB device using ehci_hcd and address 3
[    6.032419] usb 2-6: New USB device found, idVendor=04b3, idProduct=4485
[    6.032422] usb 2-6: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    6.032816] hub 2-6:1.0: USB hub found
[    6.032905] hub 2-6:1.0: 4 ports detected
[    6.116519]  sda1
[    6.116789] sd 2:0:0:0: [sda] Attached SCSI disk
[    6.122759] sr0: scsi3-mmc drive: 24x/24x writer cd/rw xa/form2 cdda tray
[    6.122763] Uniform CD-ROM driver Revision: 3.20
[    6.122859] sr 0:0:0:0: Attached scsi CD-ROM sr0
[    6.127582] sr 0:0:0:0: Attached scsi generic sg0 type 5
[    6.127624] sd 2:0:0:0: Attached scsi generic sg1 type 0
[    6.333225] [drm] Initialized drm 1.1.0 20060810
[    6.370123] [drm] radeon kernel modesetting enabled.
[    6.370243] radeon 0000:01:00.0: power state changed by ACPI to D0
[    6.370290] radeon 0000:01:00.0: power state changed by ACPI to D0
[    6.370306] radeon 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    6.370325] radeon 0000:01:00.0: setting latency timer to 64
[    6.372102] [drm] initializing kernel modesetting (RV515 0x1002:0x7145).
[    6.381089] [drm] register mmio base: 0xEE100000
[    6.381092] [drm] register mmio size: 65536
[    6.381258] ATOM BIOS: M64CSP/M62CSP/M54CSP/M52CSP
[    6.381493] [drm] GPU reset succeed (RBBM_STATUS=0x10000140)
[    6.381506] [drm] 5 Power State(s)
[    6.381509] [drm] State 0 Battery 
[    6.381511] [drm] 	1 PCIE Lanes
[    6.381512] [drm] 	1 Clock Mode(s)
[    6.381514] [drm] 		0 engine/memory: 129000/135000
[    6.381517] [drm] State 1 Battery 
[    6.381518] [drm] 	1 PCIE Lanes
[    6.381520] [drm] 	1 Clock Mode(s)
[    6.381522] [drm] 		0 engine/memory: 210000/135000
[    6.381525] [drm] State 2 Powersave 
[    6.381526] [drm] 	1 PCIE Lanes
[    6.381528] [drm] 	1 Clock Mode(s)
[    6.381530] [drm] 		0 engine/memory: 324000/135000
[    6.381533] [drm] State 3 Default 
[    6.381534] [drm] 	16 PCIE Lanes
[    6.381536] [drm] 	1 Clock Mode(s)
[    6.381538] [drm] 		0 engine/memory: 342000/350000
[    6.381540] [drm] State 4 Default (default)
[    6.381542] [drm] 	16 PCIE Lanes
[    6.381544] [drm] 	1 Clock Mode(s)
[    6.381546] [drm] 		0 engine/memory: 392000/350000
[    6.381555] [drm] radeon: power management initialized
[    6.381565] [drm] Generation 2 PCI interface, using max accessible memory
[    6.381575] radeon 0000:01:00.0: VRAM: 128M 0x00000000 - 0x07FFFFFF (128M used)
[    6.381579] radeon 0000:01:00.0: GTT: 512M 0x08000000 - 0x27FFFFFF
[    6.381765] radeon 0000:01:00.0: irq 31 for MSI/MSI-X
[    6.381777] [drm] radeon: using MSI.
[    6.381829] [drm] radeon: irq initialized.
[    6.382609] [drm] Detected VRAM RAM=128M, BAR=128M
[    6.382612] [drm] RAM width 128bits DDR
[    6.382728] [TTM] Zone  kernel: Available graphics memory: 439548 kiB.
[    6.382731] [TTM] Zone highmem: Available graphics memory: 1557152 kiB.
[    6.382749] [drm] radeon: 128M of VRAM memory ready
[    6.382752] [drm] radeon: 512M of GTT memory ready.
[    6.382773] [drm] GART: num cpu pages 131072, num gpu pages 131072
[    6.385802] [drm] RB2D reset succeed (RBBM_STATUS=0x10000140)
[    6.385838] [drm] radeon: 1 quad pipes, 1 z pipes initialized.
[    6.387136] [drm] PCIE GART of 512M enabled (table at 0x00040000).
[    6.387162] [drm] radeon: cp idle (0x10000C03)
[    6.387201] [drm] Loading R500 Microcode
[    6.387205] platform radeon_cp.0: firmware: requesting radeon/R520_cp.bin
[    6.390354] [drm] radeon: ring at 0x0000000008000000
[    6.390413] [drm] ring test succeeded in 4 usecs
[    6.390598] [drm] radeon: ib pool ready.
[    6.390699] [drm] ib test succeeded in 0 usecs
[    6.390728] [drm] Unknown TV standard; defaulting to NTSC
[    6.390899] [drm] Radeon Display Connectors
[    6.390901] [drm] Connector 0:
[    6.390903] [drm]   VGA
[    6.390906] [drm]   DDC: 0x7e40 0x7e40 0x7e44 0x7e44 0x7e48 0x7e48 0x7e4c 0x7e4c
[    6.390908] [drm]   Encoders:
[    6.390910] [drm]     CRT1: INTERNAL_KLDSCP_DAC1
[    6.390912] [drm] Connector 1:
[    6.390914] [drm]   LVDS
[    6.390916] [drm]   DDC: 0x7e60 0x7e60 0x7e64 0x7e64 0x7e68 0x7e68 0x7e6c 0x7e6c
[    6.390919] [drm]   Encoders:
[    6.390921] [drm]     LCD1: INTERNAL_LVTM1
[    6.390923] [drm] Connector 2:
[    6.390924] [drm]   DVI-I
[    6.390926] [drm]   HPD1
[    6.390929] [drm]   DDC: 0x7e50 0x7e50 0x7e54 0x7e54 0x7e58 0x7e58 0x7e5c 0x7e5c
[    6.390931] [drm]   Encoders:
[    6.390933] [drm]     DFP1: INTERNAL_KLDSCP_TMDS1
[    6.496045] usb 5-1: new full speed USB device using uhci_hcd and address 2
[    6.663730] usb 5-1: New USB device found, idVendor=0a5c, idProduct=2110
[    6.663734] usb 5-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    6.663737] usb 5-1: Product: BCM2045B
[    6.663740] usb 5-1: Manufacturer: Broadcom Corp
[    6.664949] [drm] fb mappable at 0xD80C0000
[    6.664952] [drm] vram apper at 0xD8000000
[    6.664954] [drm] size 7680000
[    6.664955] [drm] fb depth is 24
[    6.664957] [drm]    pitch is 6400
[    6.720466] Console: switching to colour frame buffer device 175x65
[    6.727852] fb0: radeondrmfb frame buffer device
[    6.727855] registered panic notifier
[    6.727860] [drm] Initialized radeon 2.3.0 20080528 for 0000:01:00.0 on minor 0
[    6.797816] scsi 6:0:0:0: Direct-Access     USB Mass Storage Device        PQ: 0 ANSI: 0 CCS
[    6.798745] sd 6:0:0:0: Attached scsi generic sg2 type 0
[    6.799280] sd 6:0:0:0: [sdb] 3862528 512-byte logical blocks: (1.97 GB/1.84 GiB)
[    6.799778] sd 6:0:0:0: [sdb] Write Protect is off
[    6.799782] sd 6:0:0:0: [sdb] Mode Sense: 03 00 00 00
[    6.799785] sd 6:0:0:0: [sdb] Assuming drive cache: write through
[    6.803028] sd 6:0:0:0: [sdb] Assuming drive cache: write through
[    6.803093]  sdb: sdb4
[    6.806035] sd 6:0:0:0: [sdb] Assuming drive cache: write through
[    6.806104] sd 6:0:0:0: [sdb] Attached SCSI removable disk
[    6.908037] usb 5-2: new full speed USB device using uhci_hcd and address 3
[    6.909069] device-mapper: ioctl: 4.17.0-ioctl (2010-03-05) initialised: dm-devel@redhat.com
[    7.080708] usb 5-2: New USB device found, idVendor=0483, idProduct=2016
[    7.080712] usb 5-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    7.080716] usb 5-2: Product: Biometric Coprocessor
[    7.080718] usb 5-2: Manufacturer: STMicroelectronics
[    7.156174] usb 2-6.2: new low speed USB device using ehci_hcd and address 6
[    7.252631] usb 2-6.2: New USB device found, idVendor=1bcf, idProduct=0007
[    7.252636] usb 2-6.2: New USB device strings: Mfr=0, Product=2, SerialNumber=0
[    7.252639] usb 2-6.2: Product: USB Optical Mouse
[    7.261671] usbcore: registered new interface driver hiddev
[    7.264938] input: USB Optical Mouse as /devices/pci0000:00/0000:00:1d.7/usb2/2-6/2-6.2/2-6.2:1.0/input/input5
[    7.265271] generic-usb 0003:1BCF:0007.0001: input,hiddev96,hidraw0: USB HID v1.10 Mouse [USB Optical Mouse] on usb-0000:00:1d.7-6.2/input0
[    7.265417] usbcore: registered new interface driver usbhid
[    7.265420] usbhid: USB HID core driver
[    7.615658] md: raid1 personality registered for level 1
[    7.684070] raid6: int32x1    571 MB/s
[    7.752038] raid6: int32x2    697 MB/s
[    7.820149] raid6: int32x4    576 MB/s
[    7.888098] raid6: int32x8    472 MB/s
[    7.956028] raid6: mmxx1     1813 MB/s
[    8.024031] raid6: mmxx2     2075 MB/s
[    8.092034] raid6: sse1x1    1376 MB/s
[    8.160034] raid6: sse1x2    1852 MB/s
[    8.228010] raid6: sse2x1    2106 MB/s
[    8.296030] raid6: sse2x2    2336 MB/s
[    8.296033] raid6: using algorithm sse2x2 (2336 MB/s)
[    8.297410] xor: automatically using best checksumming function: pIII_sse
[    8.316009]    pIII_sse  :  4994.000 MB/sec
[    8.316011] xor: using function: pIII_sse (4994.000 MB/sec)
[    8.321750] md: raid6 personality registered for level 6
[    8.321753] md: raid5 personality registered for level 5
[    8.321755] md: raid4 personality registered for level 4
[   10.474844] PM: Starting manual resume from disk
[   10.490588] EXT3-fs (dm-12): recovery required on readonly filesystem
[   10.490593] EXT3-fs (dm-12): write access will be enabled during recovery
[   10.515959] EXT3-fs (dm-12): recovery complete
[   10.515984] kjournald starting.  Commit interval 5 seconds
[   10.524577] EXT3-fs (dm-12): mounted filesystem with writeback data mode
[   12.234536] udev: starting version 158
[   12.603415] i801_smbus 0000:00:1f.3: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[   12.688053] Bluetooth: Core ver 2.15
[   12.688298] NET: Registered protocol family 31
[   12.688301] Bluetooth: HCI device and connection manager initialized
[   12.688304] Bluetooth: HCI socket layer initialized
[   12.712827] Non-volatile memory driver v1.3
[   12.713683] intel_rng: FWH not detected
[   12.714101] rtc_cmos 00:07: RTC can wake from S4
[   12.714154] rtc_cmos 00:07: rtc core: registered rtc_cmos as rtc0
[   12.714191] rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
[   12.838929] cfg80211: Calling CRDA to update world regulatory domain
[   12.852309] Bluetooth: Generic Bluetooth USB driver ver 0.6
[   12.852786] usbcore: registered new interface driver btusb
[   12.868136] yenta_cardbus 0000:15:00.0: CardBus bridge found [17aa:2012]
[   13.000907] yenta_cardbus 0000:15:00.0: ISA IRQ mask 0x0cf8, PCI irq 16
[   13.000913] yenta_cardbus 0000:15:00.0: Socket status: 30000007
[   13.000922] yenta_cardbus 0000:15:00.0: pcmcia: parent PCI bridge window: [io  0xa000-0xdfff]
[   13.000926] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xa000-0xdfff: excluding 0xa000-0xa0ff 0xa400-0xa4ff
[   13.050121] yenta_cardbus 0000:15:00.0: pcmcia: parent PCI bridge window: [mem 0xe4300000-0xe7ffffff]
[   13.050126] pcmcia_socket pcmcia_socket0: cs: memory probe 0xe4300000-0xe7ffffff: excluding 0xe4300000-0xe46cffff
[   13.050143] yenta_cardbus 0000:15:00.0: pcmcia: parent PCI bridge window: [mem 0xe0000000-0xe3ffffff 64bit pref]
[   13.050146] pcmcia_socket pcmcia_socket0: cs: memory probe 0xe0000000-0xe3ffffff: excluding 0xe0000000-0xe3ffffff
[   13.050165] yenta_cardbus 0000:15:00.0: pcmcia: parent PCI bridge window: [io  0x0000-0x0cf7]
[   13.050169] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x100-0xcf7: excluding 0x170-0x177 0x1f0-0x1f7 0x370-0x377 0x3c0-0x3df 0x3f0-0x3f7 0x4d0-0x4d7 0x800-0x80f
[   13.056877] yenta_cardbus 0000:15:00.0: pcmcia: parent PCI bridge window: [io  0x0d00-0xffff]
[   13.056881] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xd00-0xffff: excluding 0x1000-0x107f 0x1180-0x11bf 0x15e0-0x15ef 0x1600-0x1607 0x1610-0x161f 0x1648-0x165f 0x1680-0x169f 0x1800-0x188f 0x18a8-0x18cf 0x18e0-0x18ff 0x2000-0xa0ff 0xa400-0xa4ff
[   13.107526] yenta_cardbus 0000:15:00.0: pcmcia: parent PCI bridge window: [mem 0x000a0000-0x000bffff]
[   13.107531] pcmcia_socket pcmcia_socket0: cs: memory probe 0x0a0000-0x0bffff: excluding 0xa0000-0xbffff
[   13.107546] yenta_cardbus 0000:15:00.0: pcmcia: parent PCI bridge window: [mem 0x000d4000-0x000d7fff]
[   13.107550] pcmcia_socket pcmcia_socket0: cs: memory probe 0x0d4000-0x0d7fff: clean.
[   13.107555] yenta_cardbus 0000:15:00.0: pcmcia: parent PCI bridge window: [mem 0x000d8000-0x000dbfff]
[   13.107559] pcmcia_socket pcmcia_socket0: cs: memory probe 0x0d8000-0x0dbfff: clean.
[   13.107564] yenta_cardbus 0000:15:00.0: pcmcia: parent PCI bridge window: [mem 0xc0000000-0xfebfffff]
[   13.107568] pcmcia_socket pcmcia_socket0: cs: memory probe 0xc0000000-0xfebfffff: excluding 0xc0000000-0xc07fffff 0xc4000000-0xc7ffffff 0xd8000000-0xe47fffff 0xe8000000-0xee7fffff 0xf0000000-0xf3ffffff 0xfe800000-0xfeffffff
[   13.107687] yenta_cardbus 0000:15:00.0: pcmcia: parent PCI bridge window: [mem 0xfed40000-0xfed40fff]
[   13.107690] pcmcia_socket pcmcia_socket0: cs: memory probe 0xfed40000-0xfed40fff: excluding 0xfed40000-0xfed41fff
[   13.126470] thinkpad_acpi: ThinkPad ACPI Extras v0.24
[   13.126473] thinkpad_acpi: http://ibm-acpi.sf.net/
[   13.126476] thinkpad_acpi: ThinkPad BIOS 79ETE6WW (2.26 ), EC 79HT50WW-1.07
[   13.126478] thinkpad_acpi: Lenovo ThinkPad T60, model 2007VC8
[   13.127070] thinkpad_acpi: radio switch found; radios are enabled
[   13.127182] thinkpad_acpi: This ThinkPad has standard ACPI backlight brightness control, supported by the ACPI video driver
[   13.127185] thinkpad_acpi: Disabling thinkpad-acpi brightness events by default...
[   13.134783] thinkpad_acpi: rfkill switch tpacpi_bluetooth_sw: radio is unblocked
[   13.135263] Registered led device: tpacpi::thinklight
[   13.135504] Registered led device: tpacpi::power
[   13.135525] Registered led device: tpacpi::standby
[   13.135541] Registered led device: tpacpi::thinkvantage
[   13.138101] thinkpad_acpi: Standard ACPI backlight interface available, not loading native one.
[   13.138192] thinkpad_acpi: Console audio control enabled, mode: monitor (read only)
[   13.140903] input: ThinkPad Extra Buttons as /devices/platform/thinkpad_acpi/input/input6
[   13.352454] Synaptics Touchpad, model: 1, fw: 6.2, id: 0x81a0b1, caps: 0xa04793/0x300000/0x0
[   13.352459] serio: Synaptics pass-through port at isa0060/serio1/input0
[   13.394122] input: SynPS/2 Synaptics TouchPad as /devices/platform/i8042/serio1/input/input7
[   13.452301] iwl3945: Intel(R) PRO/Wireless 3945ABG/BG Network Connection driver for Linux, in-tree:s
[   13.452305] iwl3945: Copyright(c) 2003-2010 Intel Corporation
[   13.452439] iwl3945 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[   13.452454] iwl3945 0000:03:00.0: setting latency timer to 64
[   13.460945] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x100-0x4ff: excluding 0x170-0x177 0x1f0-0x1f7 0x370-0x377 0x3c0-0x3df 0x3f0-0x3f7 0x4d0-0x4d7
[   13.465882] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x800-0x8ff: excluding 0x800-0x80f
[   13.467416] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xc00-0xcff: excluding 0xcf8-0xcff
[   13.469061] pcmcia_socket pcmcia_socket0: cs: memory probe 0x0c0000-0x0fffff: excluding 0xc0000-0xd3fff 0xdc000-0xfffff
[   13.469129] pcmcia_socket pcmcia_socket0: cs: memory probe 0xa0000000-0xa0ffffff: excluding 0xa0000000-0xa0ffffff
[   13.469194] pcmcia_socket pcmcia_socket0: cs: memory probe 0x60000000-0x60ffffff: excluding 0x60000000-0x60ffffff
[   13.469264] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xa00-0xaff: clean.
[   13.508754] iwl3945 0000:03:00.0: Tunable channels: 13 802.11bg, 23 802.11a channels
[   13.508758] iwl3945 0000:03:00.0: Detected Intel Wireless WiFi Link 3945ABG
[   13.508903] iwl3945 0000:03:00.0: irq 32 for MSI/MSI-X
[   13.590288] phy0: Selected rate control algorithm 'iwl-3945-rs'
[   13.689824] HDA Intel 0000:00:1b.0: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[   13.689829] hda_intel: probe_mask set to 0x1 for device 17aa:2010
[   13.689898] HDA Intel 0000:00:1b.0: irq 33 for MSI/MSI-X
[   13.689935] HDA Intel 0000:00:1b.0: setting latency timer to 64
[   13.771713] input: HDA Digital PCBeep as /devices/pci0000:00/0000:00:1b.0/input/input8
[   14.272085] EXT3-fs (dm-12): using internal journal
[   18.863934] IBM TrackPoint firmware: 0x0e, buttons: 3/3
[   19.096023] input: TPPS/2 IBM TrackPoint as /devices/platform/i8042/serio1/serio2/input/input9
[   20.805639] usb 2-5: USB disconnect, address 2
[   22.247194] Adding 3145208k swap on /dev/mapper/swap0.  Priority:-1 extents:1 across:3145208k 
[   33.161570] kjournald starting.  Commit interval 5 seconds
[   33.178321] EXT3-fs (dm-14): using internal journal
[   33.178327] EXT3-fs (dm-14): mounted filesystem with writeback data mode
[   33.209284] kjournald starting.  Commit interval 5 seconds
[   33.236197] EXT3-fs (dm-17): using internal journal
[   33.236204] EXT3-fs (dm-17): mounted filesystem with writeback data mode
[   33.328798] kjournald starting.  Commit interval 5 seconds
[   33.329055] EXT3-fs (dm-15): using internal journal
[   33.329060] EXT3-fs (dm-15): mounted filesystem with writeback data mode
[   33.381481] kjournald starting.  Commit interval 5 seconds
[   33.381722] EXT3-fs (dm-16): using internal journal
[   33.381726] EXT3-fs (dm-16): mounted filesystem with writeback data mode
[   33.455836] kjournald starting.  Commit interval 5 seconds
[   33.456067] EXT3-fs (dm-18): using internal journal
[   33.456071] EXT3-fs (dm-18): mounted filesystem with writeback data mode
[   33.488303] kjournald starting.  Commit interval 5 seconds
[   33.488541] EXT3-fs (dm-20): using internal journal
[   33.488546] EXT3-fs (dm-20): mounted filesystem with writeback data mode
[   33.532337] kjournald starting.  Commit interval 5 seconds
[   33.532595] EXT3-fs (dm-19): using internal journal
[   33.532600] EXT3-fs (dm-19): mounted filesystem with writeback data mode
[   37.140935] NET: Registered protocol family 10
[   37.141485] lo: Disabled Privacy Extensions
[   37.448469] Bridge firewalling registered
[   38.784920] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
[   38.784924] All bugs added by David S. Miller <davem@redhat.com>
[   39.849498] e1000e 0000:02:00.0: irq 29 for MSI/MSI-X
[   39.904216] e1000e 0000:02:00.0: irq 29 for MSI/MSI-X
[   39.904760] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   40.191010] iwl3945 0000:03:00.0: firmware: requesting iwlwifi-3945-2.ucode
[   40.238930] iwl3945 0000:03:00.0: loaded firmware version 15.32.2.9
[   40.325080] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   41.822705] e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX/TX
[   41.822709] 0000:02:00.0: eth0: 10/100 speed: disabling TSO
[   41.822986] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   42.017500] vboxdrv: Trying to deactivate the NMI watchdog permanently...
[   42.017504] vboxdrv: Warning: 2.6.31+ kernel detected. Most likely the hardware performance
[   42.017506] vboxdrv: counter framework which can generate NMIs is active. You have to prevent
[   42.017508] vboxdrv: the usage of hardware performance counters by
[   42.017509] vboxdrv:   echo 2 > /proc/sys/kernel/perf_counter_paranoid
[   42.017514] vboxdrv: Found 2 processor cores.
[   42.017598] vboxdrv: fAsync=1 offMin=0x8a9e4 offMax=0x8a9e4
[   42.017661] vboxdrv: TSC mode is 'asynchronous', kernel timer mode is 'normal'.
[   42.017663] vboxdrv: Successfully loaded version 3.2.6_OSE (interface 0x00140001).
[   44.069208] ip_tables: (C) 2000-2006 Netfilter Core Team
[   44.123908] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   44.124123] CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use
[   44.124126] nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack module option or
[   44.124128] sysctl net.netfilter.nf_conntrack_acct=1 to enable it.
[   46.810862] Bluetooth: L2CAP ver 2.14
[   46.810865] Bluetooth: L2CAP socket layer initialized
[   47.187334] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   47.187338] Bluetooth: BNEP filters: protocol multicast
[   47.207756] Bluetooth: SCO (Voice Link) ver 0.6
[   47.207759] Bluetooth: SCO socket layer initialized
[   47.552041] br0: no IPv6 routers present
[   47.668350] Bluetooth: RFCOMM TTY layer initialized
[   47.668356] Bluetooth: RFCOMM socket layer initialized
[   47.668359] Bluetooth: RFCOMM ver 1.11
[   49.332627] lp: driver loaded but no devices found
[   49.552630] ppdev: user-space parallel port driver
[   51.984045] eth0: no IPv6 routers present
[   52.433070] device eth0 entered promiscuous mode
[   68.095028] CPUFREQ: Per core ondemand sysfs interface is deprecated - ignore_nice_load
[   83.852628] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   84.117958] device eth0 left promiscuous mode
[   84.137558] e1000e 0000:02:00.0: irq 29 for MSI/MSI-X
[   84.192247] e1000e 0000:02:00.0: irq 29 for MSI/MSI-X
[   84.192961] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   84.414159] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   86.818732] e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX/TX
[   86.818739] 0000:02:00.0: eth0: 10/100 speed: disabling TSO
[   86.819230] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   89.373315] wlan0: authenticate with 00:24:fe:01:97:12 (try 1)
[   89.378150] wlan0: authenticated
[   89.378747] wlan0: associate with 00:24:fe:01:97:12 (try 1)
[   89.381931] wlan0: RX AssocResp from 00:24:fe:01:97:12 (capab=0x431 status=0 aid=3)
[   89.381938] wlan0: associated
[   89.383699] ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[   97.496054] eth0: no IPv6 routers present
[  100.108053] wlan0: no IPv6 routers present
[  365.914822] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[  365.916906] input: Logitech Elite Keyboard as /devices/pci0000:00/0000:00:1d.3/usb5/5-1/5-1:1.0/bluetooth/hci0/hci0:11/input10
[  365.917244] generic-bluetooth 0005:046D:B301.0002: input,hidraw1: BLUETOOTH HID v23.02 Keyboard [Logitech Elite Keyboard] on 00:16:CF:E2:32:E8
[  428.014455] input: Logitech MX900 Mouse as /devices/pci0000:00/0000:00:1d.3/usb5/5-1/5-1:1.0/bluetooth/hci0/hci0:12/input11
[  428.014650] generic-bluetooth 0005:046D:B001.0003: input,hidraw2: BLUETOOTH HID v22.00 Mouse [Logitech MX900 Mouse] on 00:16:CF:E2:32:E8
[  481.548066] wlan0: deauthenticating from 00:24:fe:01:97:12 by local choice (reason=3)
[  481.596063] cfg80211: Calling CRDA to update world regulatory domain
[  481.693087] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  482.016409] e1000e 0000:02:00.0: irq 29 for MSI/MSI-X
[  482.074538] e1000e 0000:02:00.0: irq 29 for MSI/MSI-X
[  482.075276] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  482.272438] e1000e 0000:02:00.0: irq 29 for MSI/MSI-X
[  482.332208] e1000e 0000:02:00.0: irq 29 for MSI/MSI-X
[  482.332878] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  484.382698] e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX/TX
[  484.382703] 0000:02:00.0: eth0: 10/100 speed: disabling TSO
[  484.382982] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  495.340033] eth0: no IPv6 routers present
[  670.979820] tun: Universal TUN/TAP device driver, 1.6
[  670.979827] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[  670.980928] tun0: Disabled Privacy Extensions

--CdrF4e02JqNVZeln--
