From: Diego Calleja <diegocg@gmail.com>
Subject: Re: 2.6.37-rc1 boot Problem - BUG: unable to handle kernel null pointer - dmesg und config Datei
Date: Tue, 2 Nov 2010 23:58:32 +0100
Message-ID: <201011022358.32889.diegocg@gmail.com>
References: <web-395697375@zbackend1.aha.ru>
Reply-To: diegocg@gmail.com
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "werner" <w.landgraf@ru.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33399 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596Ab0KBW6r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 18:58:47 -0400
In-Reply-To: <web-395697375@zbackend1.aha.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> BUG: unable to handle kernel NULL pointer dereference at=20
> 00000008
> IP: [<feee45f4>] atl1_probe+0x7ee/0x992 [atl1]

I hit this problem too (CC'ing netdev)

On Martes, 2 de Noviembre de 2010 03:09:39 werner escribi=F3:
> 000000 (gap: b0000000:4ec00000)
> Booting paravirtualized kernel on bare hardware
> setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:2=20
> nr_node_ids:1
> PERCPU: 10 4K pages/cpu @f7ffe000 s26896 r0 d14064
> pcpu-alloc: s26896 r0 d14064 u40960 alloc=3D10*4096
> pcpu-alloc: [0] 0 [0] 1
> Built 1 zonelists in Zone order, mobility grouping on.=20
>  Total pages: 715087
> Kernel command line: BOOT_IMAGE=3D2637rc1 ro root=3D801 4=20
> root=3D/dev/sda1 devfs=3Dnomount noapic nolapic acpi=3Dht=20
> rootwait percpu_alloc=3Dpage
> PID hash table entries: 4096 (order: 2, 16384 bytes)
> Dentry cache hash table entries: 131072 (order: 7, 524288=20
> bytes)
> Inode-cache hash table entries: 65536 (order: 6, 262144=20
> bytes)
> Initializing CPU#0
> Initializing HighMem for node 0 (000377fe:000affc0)
> Memory: 2836460k/2883328k available (13895k kernel code,=20
> 46416k reserved, 4973k data, 876k init, 1974024k highmem)
> virtual kernel memory layout:
>      fixmap  : 0xffd36000 - 0xfffff000   (2852 kB)
>      pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
>      vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
>      lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
>        .init : 0xc226e000 - 0xc2349000   ( 876 kB)
>        .data : 0xc1d91da3 - 0xc226d3b8   (4973 kB)
>        .text : 0xc1000000 - 0xc1d91da3   (13895 kB)
> Checking if this processor honours the WP bit even in=20
> supervisor mode...Ok.
> SLUB: Genslabs=3D15, HWalign=3D64, Order=3D0-3, MinObjects=3D0,=20
> CPUs=3D2, Nodes=3D1
> Preemptable hierarchical RCU implementation.
> 	RCU-based detection of stalled CPUs is disabled.
> 	Verbose stalled-CPUs detection is disabled.
> NR_IRQS:1280
> CPU 0 irqstacks, hard=3Df5c08000 soft=3Df5c0a000
> Extended CMOS year: 2000
> spurious 8259A interrupt: IRQ7.
> Console: colour dummy device 80x25
> console [tty0] enabled
> hpet clockevent registered
> Fast TSC calibration using PIT
> Detected 2410.917 MHz processor.
> Calibrating delay loop (skipped), value calculated using=20
> timer frequency.. 4821.83 BogoMIPS (lpj=3D2410917)
> pid_max: default: 32768 minimum: 301
> Security Framework initialized
> Mount-cache hash table entries: 512
> CPU: Physical Processor ID: 0
> CPU: Processor Core ID: 0
> mce: CPU supports 5 MCE banks
> using C1E aware idle routine
> Performance Events:
> no APIC, boot with the "lapic" boot parameter to=20
> force-enable it.
> no hardware sampling interrupt available.
> AMD PMU driver.
> ... version:                0
> ... bit width:              48
> ... generic registers:      4
> ... value mask:             0000ffffffffffff
> ... max period:             00007fffffffffff
> ... fixed-purpose events:   0
> ... event mask:             000000000000000f
> ACPI: Core revision 20101013
> ACPI: setting ELCR to 0200 (from 8c00)
> SMP disabled
> MCE: In-kernel MCE decoding enabled.
> Brought up 1 CPUs
> Total of 1 processors activated (4821.83 BogoMIPS).
> devtmpfs: initialized
> xor: automatically using best checksumming function:=20
> pIII_sse
>     pIII_sse  :  6836.000 MB/sec
> xor: using function: pIII_sse (6836.000 MB/sec)
> regulator: core version 0.5
> regulator: dummy:
> NET: Registered protocol family 16
> EISA bus registered
> node 0 link 0: io port [1000, ffffff]
> TOM: 00000000c0000000 aka 3072M
> node 0 link 0: mmio [e0000000, efffffff]
> node 0 link 0: mmio [a0000, bffff]
> node 0 link 0: mmio [c0000000, fe0bffff]
> TOM2: 0000000240000000 aka 9216M
> bus: [00, ff] on node 0 link 0
> bus: 00 index 0 [io  0x0000-0xffff]
> bus: 00 index 1 [mem 0xc0000000-0xffffffff]
> bus: 00 index 2 [mem 0x000a0000-0x000bffff]
> ACPI: bus type pci registered
> PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem=20
> 0xe0000000-0xefffffff] (base 0xe0000000)
> PCI: not using MMCONFIG
> PCI: PCI BIOS revision 3.00 entry at 0xf0031, last bus=3D4
> PCI: Using configuration type 1 for base access
> bio: create slab <bio-0> at 0
> raid6: int32x1    613 MB/s
> raid6: int32x2    828 MB/s
> raid6: int32x4    675 MB/s
> raid6: int32x8    535 MB/s
> raid6: mmxx1     1941 MB/s
> raid6: mmxx2     3343 MB/s
> raid6: sse1x1    1906 MB/s
> raid6: sse1x2    2945 MB/s
> raid6: sse2x1    3312 MB/s
> raid6: sse2x2    4312 MB/s
> raid6: using algorithm sse2x2 (4312 MB/s)
> ACPI: EC: Look up EC in DSDT
> ACPI: Executed 1 blocks of module-level executable AML=20
> code
> ACPI: Interpreter enabled
> ACPI: (supports S0 S1 S3 S4 S5)
> ACPI: Using PIC for interrupt routing
> PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem=20
> 0xe0000000-0xefffffff] (base 0xe0000000)
> PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in=20
> ACPI motherboard resources
> PCI: Using MMCONFIG for extended config space
> ACPI: No dock devices found.
> PCI: Ignoring host bridge windows from ACPI; if necessary,=20
> use "pci=3Duse_crs" and report a bug
> ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
> pci_root PNP0A03:00: host bridge window [io=20
>  0x0000-0x0cf7] (ignored)
> pci_root PNP0A03:00: host bridge window [io=20
>  0x0d00-0xffff] (ignored)
> pci_root PNP0A03:00: host bridge window [mem=20
> 0x000a0000-0x000bffff] (ignored)
> pci_root PNP0A03:00: host bridge window [mem=20
> 0x000d0000-0x000dffff] (ignored)
> pci_root PNP0A03:00: host bridge window [mem=20
> 0xb0000000-0xff77ffff] (ignored)
> pci 0000:00:00.0: [10de:03ea] type 0 class 0x000500
> pci 0000:00:01.0: [10de:03e0] type 0 class 0x000601
> pci 0000:00:01.1: [10de:03eb] type 0 class 0x000c05
> pci 0000:00:01.1: reg 10: [io  0xdc00-0xdc3f]
> pci 0000:00:01.1: reg 20: [io  0x0600-0x063f]
> pci 0000:00:01.1: reg 24: [io  0x0700-0x073f]
> pci 0000:00:01.1: PME# supported from D3hot D3cold
> pci 0000:00:01.1: PME# disabled
> pci 0000:00:01.2: [10de:03f5] type 0 class 0x000500
> pci 0000:00:02.0: [10de:03f1] type 0 class 0x000c03
> pci 0000:00:02.0: reg 10: [mem 0xdfdff000-0xdfdfffff]
> pci 0000:00:02.0: supports D1 D2
> pci 0000:00:02.0: PME# supported from D0 D1 D2 D3hot=20
> D3cold
> pci 0000:00:02.0: PME# disabled
> pci 0000:00:02.1: [10de:03f2] type 0 class 0x000c03
> pci 0000:00:02.1: reg 10: [mem 0xdfdfec00-0xdfdfecff]
> pci 0000:00:02.1: supports D1 D2
> pci 0000:00:02.1: PME# supported from D0 D1 D2 D3hot=20
> D3cold
> pci 0000:00:02.1: PME# disabled
> pci 0000:00:04.0: [10de:03f3] type 1 class 0x000604
> pci 0000:00:05.0: [10de:03f0] type 0 class 0x000403
> pci 0000:00:05.0: reg 10: [mem 0xdfdf8000-0xdfdfbfff]
> pci 0000:00:05.0: PME# supported from D3hot D3cold
> pci 0000:00:05.0: PME# disabled
> pci 0000:00:06.0: [10de:03ec] type 0 class 0x000101
> pci 0000:00:06.0: reg 20: [io  0xffa0-0xffaf]
> pci 0000:00:08.0: [10de:03f6] type 0 class 0x000101
> pci 0000:00:08.0: reg 10: [io  0xd480-0xd487]
> pci 0000:00:08.0: reg 14: [io  0xd400-0xd403]
> pci 0000:00:08.0: reg 18: [io  0xd080-0xd087]
> pci 0000:00:08.0: reg 1c: [io  0xd000-0xd003]
> pci 0000:00:08.0: reg 20: [io  0xcc00-0xcc0f]
> pci 0000:00:08.0: reg 24: [mem 0xdfdfd000-0xdfdfdfff]
> pci 0000:00:09.0: [10de:03e8] type 1 class 0x000604
> pci 0000:00:09.0: PME# supported from D0 D1 D2 D3hot=20
> D3cold
> pci 0000:00:09.0: PME# disabled
> pci 0000:00:0b.0: [10de:03e9] type 1 class 0x000604
> pci 0000:00:0b.0: PME# supported from D0 D1 D2 D3hot=20
> D3cold
> pci 0000:00:0b.0: PME# disabled
> pci 0000:00:0c.0: [10de:03e9] type 1 class 0x000604
> pci 0000:00:0c.0: PME# supported from D0 D1 D2 D3hot=20
> D3cold
> pci 0000:00:0c.0: PME# disabled
> pci 0000:00:0d.0: [10de:03d1] type 0 class 0x000300
> pci 0000:00:0d.0: reg 10: [mem 0xde000000-0xdeffffff]
> pci 0000:00:0d.0: reg 14: [mem 0xc0000000-0xcfffffff 64bit=20
> pref]
> pci 0000:00:0d.0: reg 1c: [mem 0xdd000000-0xddffffff=20
> 64bit]
> pci 0000:00:0d.0: reg 30: [mem 0xdfdc0000-0xdfddffff pref]
> pci 0000:00:18.0: [1022:1100] type 0 class 0x000600
> pci 0000:00:18.1: [1022:1101] type 0 class 0x000600
> pci 0000:00:18.2: [1022:1102] type 0 class 0x000600
> pci 0000:00:18.3: [1022:1103] type 0 class 0x000600
> PCI: peer root bus 00 res updated from pci conf
> pci 0000:01:07.0: [10ec:8139] type 0 class 0x000200
> pci 0000:01:07.0: reg 10: [io  0xe800-0xe8ff]
> pci 0000:01:07.0: reg 14: [mem 0xdfeffc00-0xdfeffcff]
> pci 0000:01:07.0: supports D1 D2
> pci 0000:01:07.0: PME# supported from D1 D2 D3hot
> pci 0000:01:07.0: PME# disabled
> pci 0000:00:04.0: PCI bridge to [bus 01-01] (subtractive=20
> decode)
> pci 0000:00:04.0:   bridge window [io  0xe000-0xefff]
> pci 0000:00:04.0:   bridge window [mem=20
> 0xdfe00000-0xdfefffff]
> pci 0000:00:04.0:   bridge window [mem=20
> 0xfff00000-0x000fffff pref] (disabled)
> pci 0000:00:04.0:   bridge window [io  0x0000-0xffff]=20
> (subtractive decode)
> pci 0000:00:04.0:   bridge window [mem=20
> 0xc0000000-0xffffffff] (subtractive decode)
> pci 0000:00:04.0:   bridge window [mem=20
> 0x000a0000-0x000bffff] (subtractive decode)
> pci 0000:00:09.0: PCI bridge to [bus 02-02]
> pci 0000:00:09.0:   bridge window [io  0xf000-0x0000]=20
> (disabled)
> pci 0000:00:09.0:   bridge window [mem=20
> 0xfff00000-0x000fffff] (disabled)
> pci 0000:00:09.0:   bridge window [mem=20
> 0xfff00000-0x000fffff pref] (disabled)
> pci 0000:00:0b.0: PCI bridge to [bus 03-03]
> pci 0000:00:0b.0:   bridge window [io  0xf000-0x0000]=20
> (disabled)
> pci 0000:00:0b.0:   bridge window [mem=20
> 0xfff00000-0x000fffff] (disabled)
> pci 0000:00:0b.0:   bridge window [mem=20
> 0xfff00000-0x000fffff pref] (disabled)
> pci 0000:04:00.0: [1969:1048] type 0 class 0x000200
> pci 0000:04:00.0: reg 10: [mem 0xdffc0000-0xdfffffff=20
> 64bit]
> pci 0000:04:00.0: reg 30: [mem 0xdffa0000-0xdffbffff pref]
> pci 0000:04:00.0: PME# supported from D3hot D3cold
> pci 0000:04:00.0: PME# disabled
> pci 0000:04:00.0: disabling ASPM on pre-1.1 PCIe device.=20
>  You can enable it with 'pcie_aspm=3Dforce'
> pci 0000:00:0c.0: PCI bridge to [bus 04-04]
> pci 0000:00:0c.0:   bridge window [io  0xf000-0x0000]=20
> (disabled)
> pci 0000:00:0c.0:   bridge window [mem=20
> 0xdff00000-0xdfffffff]
> pci 0000:00:0c.0:   bridge window [mem=20
> 0xfff00000-0x000fffff pref] (disabled)
> pci_bus 0000:00: on NUMA node 0
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.BR11._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.BR12._PRT]
> ACPI: PCI Interrupt Link [LNKA] (IRQs 7 10 11 14) *0,=20
> disabled.
> ACPI: PCI Interrupt Link [LNKB] (IRQs 7 10 *11 14)
> ACPI: PCI Interrupt Link [LNKC] (IRQs 7 10 11 14) *0,=20
> disabled.
> ACPI: PCI Interrupt Link [LNKD] (IRQs 7 10 11 14) *0,=20
> disabled.
> ACPI: PCI Interrupt Link [LNEA] (IRQs 7 10 *11 14)
> ACPI: PCI Interrupt Link [LNEB] (IRQs 7 10 11 14) *0,=20
> disabled.
> ACPI: PCI Interrupt Link [LNEC] (IRQs 7 10 11 14) *0,=20
> disabled.
> ACPI: PCI Interrupt Link [LNED] (IRQs 7 10 11 14) *0,=20
> disabled.
> ACPI: PCI Interrupt Link [LUB0] (IRQs 7 10 *11 14)
> ACPI: PCI Interrupt Link [LUB2] (IRQs 7 *10 11 14)
> ACPI: PCI Interrupt Link [LMAC] (IRQs 7 10 11 14) *0,=20
> disabled.
> ACPI: PCI Interrupt Link [LAZA] (IRQs 7 10 *11 14)
> ACPI: PCI Interrupt Link [LACI] (IRQs 7 10 11 14) *0,=20
> disabled.
> ACPI: PCI Interrupt Link [LMC9] (IRQs 7 10 *11 14)
> ACPI: PCI Interrupt Link [LSMB] (IRQs 7 *10 11 14)
> ACPI: PCI Interrupt Link [LPMU] (IRQs 7 10 11 14) *0,=20
> disabled.
> ACPI: PCI Interrupt Link [LSA0] (IRQs *15)
> ACPI: PCI Interrupt Link [LSA1] (IRQs 5) *0, disabled.
> ACPI: PCI Interrupt Link [LATA] (IRQs 7 10 11 14) *0,=20
> disabled.
> HEST: Table is not found!
> vgaarb: device added:=20
> PCI:0000:00:0d.0,decodes=3Dio+mem,owns=3Dio+mem,locks=3Dnone
> vgaarb: loaded
> SCSI subsystem initialized
> libata version 3.00 loaded.
> usbcore: registered new interface driver usbfs
> usbcore: registered new interface driver hub
> usbcore: registered new device driver usb
> wmi: Mapper loaded
> PCI: Using ACPI for IRQ routing
> PCI: pci_cache_line_size set to 64 bytes
> reserve RAM buffer: 000000000009fc00 - 000000000009ffff
> reserve RAM buffer: 00000000affc0000 - 00000000afffffff
> NetLabel: Initializing
> NetLabel:  domain hash size =3D 128
> NetLabel:  protocols =3D UNLABELED CIPSOv4
> NetLabel:  unlabeled traffic allowed by default
> hpet0: at MMIO 0xfed00000, IRQs 2, 8, 31
> hpet0: 3 comparators, 32-bit 25.000000 MHz counter
> Switching to clocksource hpet
> FS-Cache: Loaded
> CacheFiles: Loaded
> pnp: PnP ACPI init
> ACPI: bus type pnp registered
> pnp 00:00: [bus 00-ff]
> pnp 00:00: [io  0x0cf8-0x0cff]
> pnp 00:00: [io  0x0000-0x0cf7 window]
> pnp 00:00: [io  0x0d00-0xffff window]
> pnp 00:00: [mem 0x000a0000-0x000bffff window]
> pnp 00:00: [mem 0x000d0000-0x000dffff window]
> pnp 00:00: [mem 0xb0000000-0xff77ffff window]
> pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (active)
> pnp 00:01: [dma 4]
> pnp 00:01: [io  0x0000-0x000f]
> pnp 00:01: [io  0x0081-0x0083]
> pnp 00:01: [io  0x0087]
> pnp 00:01: [io  0x0089-0x008b]
> pnp 00:01: [io  0x008f]
> pnp 00:01: [io  0x00c0-0x00df]
> pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
> pnp 00:02: [io  0x0070-0x0071]
> pnp 00:02: [irq 8]
> pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
> pnp 00:03: [io  0x0061]
> pnp 00:03: Plug and Play ACPI device, IDs PNP0800 (active)
> pnp 00:04: [io  0x00f0-0x00ff]
> pnp 00:04: [irq 13]
> pnp 00:04: Plug and Play ACPI device, IDs PNP0c04 (active)
> pnp 00:05: [io  0x03f0-0x03f5]
> pnp 00:05: [io  0x03f7]
> pnp 00:05: [irq 6]
> pnp 00:05: [dma 2]
> pnp 00:05: Plug and Play ACPI device, IDs PNP0700 (active)
> pnp 00:06: [io  0x0378-0x037f]
> pnp 00:06: [io  0x0778-0x077f]
> pnp 00:06: [irq 7]
> pnp 00:06: [dma 3]
> pnp 00:06: Plug and Play ACPI device, IDs PNP0401 (active)
> pnp 00:07: [mem 0x000d0000-0x000d3fff window]
> pnp 00:07: [mem 0x000d4000-0x000d7fff window]
> pnp 00:07: [mem 0x000de000-0x000dffff window]
> pnp 00:07: [io  0x0010-0x001f]
> pnp 00:07: [io  0x0022-0x003f]
> pnp 00:07: [io  0x0044-0x004d]
> pnp 00:07: [io  0x0050-0x005f]
> pnp 00:07: [io  0x0062-0x0063]
> pnp 00:07: [io  0x0065-0x006f]
> pnp 00:07: [io  0x0072-0x007f]
> pnp 00:07: [io  0x0080]
> pnp 00:07: [io  0x0084-0x0086]
> pnp 00:07: [io  0x0088]
> pnp 00:07: [io  0x008c-0x008e]
> pnp 00:07: [io  0x0090-0x009f]
> pnp 00:07: [io  0x00a2-0x00bf]
> pnp 00:07: [io  0x00e0-0x00ef]
> pnp 00:07: [io  0x04d0-0x04d1]
> pnp 00:07: [io  0x0800-0x080f]
> pnp 00:07: [io  0x0500-0x057f]
> pnp 00:07: [io  0x0580-0x05ff]
> pnp 00:07: [io  0x0800-0x087f]
> pnp 00:07: [io  0x0880-0x08ff]
> pnp 00:07: [io  0x0d00-0x0d7f]
> pnp 00:07: [io  0x0d80-0x0dff]
> pnp 00:07: [io  0x2000-0x207f]
> pnp 00:07: [io  0x2080-0x20ff]
> pnp 00:07: [mem 0xfefe0000-0xfefe01ff]
> pnp 00:07: [mem 0xfefe1000-0xfefe1fff]
> pnp 00:07: [mem 0xfee01000-0xfeefffff]
> pnp 00:07: [mem 0xffb80000-0xffffffff]
> pnp 00:07: [mem 0xff300000-0xff3fffff]
> pnp 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
> pnp 00:08: [mem 0xfed00000-0xfed00fff]
> pnp 00:08: Plug and Play ACPI device, IDs PNP0103 (active)
> pnp 00:09: [mem 0xfec00000-0xfec00fff]
> pnp 00:09: [mem 0xfee00000-0xfee00fff]
> pnp 00:09: [mem 0xb0000000-0xbfffffff]
> pnp 00:09: Plug and Play ACPI device, IDs PNP0c02 (active)
> pnp 00:0a: [io  0x0060]
> pnp 00:0a: [io  0x0064]
> pnp 00:0a: [irq 1]
> pnp 00:0a: Plug and Play ACPI device, IDs PNP0303 PNP030b=20
> (active)
> pnp 00:0b: [irq 12]
> pnp 00:0b: Plug and Play ACPI device, IDs PNP0f03 PNP0f13=20
> (active)
> pnp 00:0c: [io  0x0000-0xffffffff disabled]
> pnp 00:0c: [io  0x0230-0x023f]
> pnp 00:0c: [io  0x0290-0x029f]
> pnp 00:0c: [io  0x0a00-0x0a0f]
> pnp 00:0c: [io  0x0a10-0x0a1f]
> pnp 00:0c: Plug and Play ACPI device, IDs PNP0c02 (active)
> pnp 00:0d: [io  0x03f8-0x03ff]
> pnp 00:0d: [irq 4]
> pnp 00:0d: [dma 0 disabled]
> pnp 00:0d: Plug and Play ACPI device, IDs PNP0501 (active)
> pnp 00:0e: [mem 0xe0000000-0xefffffff]
> pnp 00:0e: Plug and Play ACPI device, IDs PNP0c02 (active)
> pnp 00:0f: [mem 0x00000000-0x0009ffff]
> pnp 00:0f: [mem 0x000c0000-0x000cffff]
> pnp 00:0f: [mem 0x000e0000-0x000fffff]
> pnp 00:0f: [mem 0x00100000-0xafffffff]
> pnp 00:0f: [mem 0xff780000-0xffffffff]
> pnp 00:0f: Plug and Play ACPI device, IDs PNP0c01 (active)
> pnp: PnP ACPI: found 16 devices
> ACPI: ACPI bus type pnp unregistered
> PnPBIOS: Disabled by ACPI PNP
> system 00:07: [io  0x04d0-0x04d1] has been reserved
> system 00:07: [io  0x0800-0x080f] has been reserved
> system 00:07: [io  0x0500-0x057f] has been reserved
> system 00:07: [io  0x0580-0x05ff] has been reserved
> system 00:07: [io  0x0800-0x087f] could not be reserved
> system 00:07: [io  0x0880-0x08ff] has been reserved
> system 00:07: [io  0x0d00-0x0d7f] has been reserved
> system 00:07: [io  0x0d80-0x0dff] has been reserved
> system 00:07: [io  0x2000-0x207f] has been reserved
> system 00:07: [io  0x2080-0x20ff] has been reserved
> system 00:07: [mem 0x000d0000-0x000d3fff window] has been=20
> reserved
> system 00:07: [mem 0x000d4000-0x000d7fff window] has been=20
> reserved
> system 00:07: [mem 0x000de000-0x000dffff window] has been=20
> reserved
> system 00:07: [mem 0xfefe0000-0xfefe01ff] has been=20
> reserved
> system 00:07: [mem 0xfefe1000-0xfefe1fff] has been=20
> reserved
> system 00:07: [mem 0xfee01000-0xfeefffff] has been=20
> reserved
> system 00:07: [mem 0xffb80000-0xffffffff] has been=20
> reserved
> system 00:07: [mem 0xff300000-0xff3fffff] has been=20
> reserved
> system 00:09: [mem 0xfec00000-0xfec00fff] has been=20
> reserved
> system 00:09: [mem 0xfee00000-0xfee00fff] has been=20
> reserved
> system 00:09: [mem 0xb0000000-0xbfffffff] has been=20
> reserved
> system 00:0c: [io  0x0230-0x023f] has been reserved
> system 00:0c: [io  0x0290-0x029f] has been reserved
> system 00:0c: [io  0x0a00-0x0a0f] has been reserved
> system 00:0c: [io  0x0a10-0x0a1f] has been reserved
> system 00:0e: [mem 0xe0000000-0xefffffff] has been=20
> reserved
> system 00:0f: [mem 0x00000000-0x0009ffff] could not be=20
> reserved
> system 00:0f: [mem 0x000c0000-0x000cffff] could not be=20
> reserved
> system 00:0f: [mem 0x000e0000-0x000fffff] could not be=20
> reserved
> system 00:0f: [mem 0x00100000-0xafffffff] could not be=20
> reserved
> system 00:0f: [mem 0xff780000-0xffffffff] could not be=20
> reserved
> mdacon: MDA with 8K of memory detected.
> Console: switching consoles 13-16 to MDA-2
> pci 0000:00:04.0: PCI bridge to [bus 01-01]
> pci 0000:00:04.0:   bridge window [io  0xe000-0xefff]
> pci 0000:00:04.0:   bridge window [mem=20
> 0xdfe00000-0xdfefffff]
> pci 0000:00:04.0:   bridge window [mem pref disabled]
> pci 0000:00:09.0: PCI bridge to [bus 02-02]
> pci 0000:00:09.0:   bridge window [io  disabled]
> pci 0000:00:09.0:   bridge window [mem disabled]
> pci 0000:00:09.0:   bridge window [mem pref disabled]
> pci 0000:00:0b.0: PCI bridge to [bus 03-03]
> pci 0000:00:0b.0:   bridge window [io  disabled]
> pci 0000:00:0b.0:   bridge window [mem disabled]
> pci 0000:00:0b.0:   bridge window [mem pref disabled]
> pci 0000:00:0c.0: PCI bridge to [bus 04-04]
> pci 0000:00:0c.0:   bridge window [io  disabled]
> pci 0000:00:0c.0:   bridge window [mem=20
> 0xdff00000-0xdfffffff]
> pci 0000:00:0c.0:   bridge window [mem pref disabled]
> pci 0000:00:04.0: setting latency timer to 64
> pci 0000:00:09.0: setting latency timer to 64
> pci 0000:00:0b.0: setting latency timer to 64
> pci 0000:00:0c.0: setting latency timer to 64
> pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
> pci_bus 0000:00: resource 5 [mem 0xc0000000-0xffffffff]
> pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
> pci_bus 0000:01: resource 0 [io  0xe000-0xefff]
> pci_bus 0000:01: resource 1 [mem 0xdfe00000-0xdfefffff]
> pci_bus 0000:01: resource 4 [io  0x0000-0xffff]
> pci_bus 0000:01: resource 5 [mem 0xc0000000-0xffffffff]
> pci_bus 0000:01: resource 6 [mem 0x000a0000-0x000bffff]
> pci_bus 0000:04: resource 1 [mem 0xdff00000-0xdfffffff]
> NET: Registered protocol family 2
> IP route cache hash table entries: 32768 (order: 5, 131072=20
> bytes)
> TCP established hash table entries: 131072 (order: 8,=20
> 1048576 bytes)
> TCP bind hash table entries: 65536 (order: 7, 524288=20
> bytes)
> TCP: Hash tables configured (established 131072 bind=20
> 65536)
> TCP reno registered
> UDP hash table entries: 512 (order: 2, 16384 bytes)
> UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
> NET: Registered protocol family 1
> RPC: Registered udp transport module.
> RPC: Registered tcp transport module.
> RPC: Registered tcp NFSv4.1 backchannel transport module.
> pci 0000:00:0d.0: Boot video device
> PCI: CLS 64 bytes, default 64
> Machine check injector initialized
> elanfreq: error: no Elan processor found!
> cpufreq-nforce2: No nForce2 chipset.
> apm: BIOS version 1.2 Flags 0x03 (Driver version 1.16ac)
> apm: overridden by ACPI.
> microcode: microcode: CPU0: AMD CPU family 0xf not=20
> supported
> microcode: Microcode Update Driver: v2.00=20
> <tigran@aivazian.fsnet.co.uk>, Peter Oruba
> Scanning for low memory corruption every 60 seconds
> scx200: NatSemi SCx200 Driver
> audit: initializing netlink socket (disabled)
> type=3D2000 audit(1288652030.818:1): initialized
> highmem bounce pool size: 64 pages
> HugeTLB registered 4 MB page size, pre-allocated 0 pages
> VFS: Disk quotas dquot_6.5.2
> Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
> DLM (built Nov  1 2010 20:54:43) installed
> squashfs: version 4.0 (2009/01/31) Phillip Lougher
> Registering the id_resolver key type
> FS-Cache: Netfs 'nfs' registered for caching
> nfs4filelayout_init: NFSv4 File Layout Driver=20
> Registering...
> Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> NTFS driver 2.1.29 [Flags: R/W].
> EFS: 1.0a - http://aeschi.ch.eu.org/efs/
> JFFS2 version 2.2. (NAND) (SUMMARY)  =C2=A9 2001-2006 Red Hat,=20
> Inc.
> ROMFS MTD (C) 2007 Red Hat, Inc.
> QNX4 filesystem 0.2.3 registered.
> fuse init (API version 7.15)
> JFS: nTxBlock =3D 8192, nTxLock =3D 65536
> SGI XFS with ACLs, security attributes, realtime, large=20
> block/inode numbers, no debug enabled
> SGI XFS Quota Management subsystem
> NILFS version 2 loaded
> BeFS version: 0.9.3
> OCFS2 1.5.0
> ocfs2: Registered cluster interface o2cb
> ocfs2: Registered cluster interface user
> OCFS2 DLMFS 1.5.0
> OCFS2 User DLM kernel interface loaded
> OCFS2 Node Manager 1.5.0
> OCFS2 DLM 1.5.0
> Btrfs loaded
> GFS2 (built Nov  1 2010 20:56:12) installed
> msgmni has been set to 1684
> async_tx: api initialized (async)
> Block layer SCSI generic (bsg) driver version 0.4 loaded=20
> (major 254)
> io scheduler noop registered
> io scheduler deadline registered
> io scheduler cfq registered (default)
> pci_hotplug: PCI Hot Plug PCI Core version: 0.5
> cpqphp: Compaq Hot Plug PCI Controller Driver version:=20
> 0.9.8
> ibmphpd: IBM Hot Plug PCI Controller Driver version: 0.6
> pciehp: PCI Express Hot Plug Controller Driver version:=20
> 0.4
> cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version:=20
> 0.2
> cpcihp_generic: Generic port I/O CompactPCI Hot Plug=20
> Driver version: 0.1
> cpcihp_generic: not configured, disabling.
> shpchp: Standard Hot Plug PCI Controller Driver version:=20
> 0.4
> acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
> acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
> ACPI: PCI Interrupt Link [LMC9] enabled at IRQ 11
> PCI: setting IRQ 11 as level-triggered
> nvidiafb 0000:00:0d.0: PCI INT A -> Link[LMC9] -> GSI 11=20
> (level, low) -> IRQ 11
> nvidiafb: Device ID: 10de03d1
> nvidiafb: CRTC0 analog found
> nvidiafb: CRTC1 analog not found
> i2c i2c-0: unable to read EDID block.
> i2c i2c-0: unable to read EDID block.
> i2c i2c-0: unable to read EDID block.
> nvidiafb: EDID found from BUS2
> nvidiafb: CRTC 0 appears to have a CRT attached
> nvidiafb: Using CRT on CRTC 0
> nvidiafb: MTRR set to ON
> fbcon: NV3d (fb0) is primary device
> Console: switching to colour frame buffer device 210x65
> nvidiafb: PCI nVidia NV3d framebuffer (64MB @ 0xC0000000)
> VIA Graphics Intergration Chipset framebuffer 2.4=20
> initializing
> vmlfb: initializing
> Could not find Carillo Ranch MCH device.
> no IO addresses supplied
> hgafb: HGA card not detected.
> hgafb: probe of hgafb.0 failed with error -22
> uvesafb: failed to execute /sbin/v86d
> uvesafb: make sure that the v86d helper is installed and=20
> executable
> uvesafb: Getting VBE info block failed (eax=3D0x4f00,=20
> err=3D-2)
> uvesafb: vbe_init() failed with -22
> uvesafb: probe of uvesafb.0 failed with error -22
> vesafb: cannot reserve video memory at 0xc0000000
> vesafb: framebuffer at 0xc0000000, mapped to 0xfd700000,=20
> using 3072k, total 262144k
> vesafb: mode is 1024x768x16, linelength=3D2048, pages=3D1
> vesafb: protected mode interface info at c000:d2a0
> vesafb: pmi: set display start =3D c00cd2d6, set palette =3D=20
> c00cd340
> vesafb: pmi: ports =3D b4c3 b503 ba03 c003 c103 c403 c503=20
> c603 c703 c803 c903 cc03 ce03 cf03 d003 d103 d203 d303=20
> d403 d503 da03 ff03
> vesafb: scrolling: redraw
> vesafb: Truecolor: size=3D0:5:6:5, shift=3D0:11:5:0
> fb1: VESA VGA frame buffer device
> vga16fb: initializing
> vga16fb: mapped to 0xc00a0000
> checking generic (c0000000 10000000) vs hw (a0000 10000)
> fb2: VGA16 VGA frame buffer device
> input: Power Button as=20
> /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
> ACPI: Power Button [PWRB]
> input: Power Button as=20
> /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
> ACPI: Power Button [PWRF]
> ACPI: acpi_idle registered with cpuidle
> ERST: Table is not found!
> isapnp: Scanning for PnP cards...
> isapnp: No Plug & Play device found
> Non-volatile memory driver v1.3
> toshiba: not a supported Toshiba laptop
> Linux agpgart interface v0.103
> [drm] Initialized drm 1.1.0 20060810
> [drm] radeon defaulting to userspace modesetting.
> Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
> serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
> 00:0d: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
> IT8712 SuperIO detected.
> parport_pc 00:06: reported by Plug and Play ACPI
> parport0: PC-style at 0x378 (0x778), irq 7, dma 3=20
> [PCSPP,TRISTATE,COMPAT,ECP,DMA]
> FDC 0 is a post-1991 82077
> brd: module loaded
> loop: module loaded
> Compaq SMART2 Driver (v 2.6.0)
> HP CISS Driver (v 3.6.26)
> MM: desc_per_page =3D 128
> nbd: registered device at major 43
> usbcore: registered new interface driver ub
> ibmasm: IBM ASM Service Processor Driver version 1.0=20
> loaded
> Phantom Linux Driver, version n0.9.8, init OK
> Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo=20
> Giometti
> c2port c2port0: C2 port uc added
> c2port c2port0: uc flash has 30 blocks x 512 bytes (15360=20
> bytes total)
> Driver for timberdale has been successfully registered.
> Uniform Multi-Platform E-IDE driver
> amd74xx 0000:00:06.0: UDMA133 controller
> amd74xx 0000:00:06.0: IDE controller (0x10de:0x03ec rev=20
> 0xa2)
> amd74xx 0000:00:06.0: IDE port disabled
> amd74xx 0000:00:06.0: not 100% native mode: will probe=20
> irqs later
>      ide0: BM-DMA at 0xffa0-0xffa7
> Probing IDE interface ide0...
> ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
> ide_generic: please use "probe_mask=3D0x3f" module parameter=20
> for probing all legacy ISA IDE ports
> ide-gd driver 1.18
> ide-cd driver 5.00
> Loading iSCSI transport class v2.0-870.
> rdac: device handler registered
> hp_sw: device handler registered
> emc: device handler registered
> alua: device handler registered
> fnic: Cisco FCoE HBA Driver, ver 1.4.0.145
> iscsi: registered transport (tcp)
> Loading Adaptec I2O RAID: Version 2.4 Build 5go
> Detecting Adaptec I2O RAID controllers...
> Adaptec aacraid driver 1.1-5[26400]-ms
> aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3=20
> loaded
> scsi: <fdomain> Detection failed (no card)
> NCR53c406a: no available ports found
> sym53c416.c: Version 1.0.0-ac
> qlogicfas: no cards were found, please specify I/O address=20
> and IRQ using iobase=3D and irq=3D options
> QLogic Fibre Channel HBA Driver: 8.03.04-k0
> iscsi: registered transport (qla4xxx)
> QLogic iSCSI HBA Driver
> Emulex LightPulse Fibre Channel SCSI driver 8.3.18
> Copyright(c) 2004-2009 Emulex.  All rights reserved.
> Brocade BFA FC/FCOE SCSI driver - version: 2.3.2.0
> Failed initialization of WD-7000 SCSI card!
> DC390: clustering now enabled by default. If you get=20
> problems load
>         with "disable_clustering=3D1" and report to=20
> maintainers
> megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03=20
> EST 2006)
> megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST=20
> 2006)
> megasas: 00.00.04.31-rc1 Mon. May 3, 11:41:51 PST 2010
> mpt2sas version 06.100.00.00 loaded
> GDT-HA: Storage RAID Controller Driver. Version: 3.05
> 3ware Storage Controller device driver for Linux=20
> v1.26.02.003.
> 3ware 9000 Storage Controller device driver for Linux=20
> v2.26.02.014.
> ppa: Version 2.07 (for Linux 2.4.x)
> imm: Version 2.05 (for Linux 2.4.0)
> nsp32: loading...
> ipr: IBM Power RAID SCSI Device Driver version: 2.5.1=20
> (August 10, 2010)
> RocketRAID 3xxx/4xxx Controller driver v1.6 (090910)
> stex: Promise SuperTrak EX Driver version: 4.6.0000.4
> libcxgbi:libcxgbi_init_module: tag itt 0x1fff, 13 bits,=20
> age 0xf, 4 bits.
> libcxgbi:ddp_setup_host_page_size: system PAGE 4096, ddp=20
> idx 0.
> Chelsio T3 iSCSI Driver cxgb3i v2.0.0 (Jun. 2010)
> iscsi: registered transport (cxgb3i)
> Broadcom NetXtreme II iSCSI Driver bnx2i v2.1.3 (Aug 10,=20
> 2010)
> iscsi: registered transport (bnx2i)
> iscsi: registered transport (be2iscsi)
> st: Version 20100829, fixed bufsize 32768, s/g segs 256
> osst :I: Tape driver with OnStream support version 0.99.4
> osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp=20
> $
> SCSI Media Changer driver v0.25
> osd: LOADED open-osd 0.2.0
> sata_nv 0000:00:08.0: version 3.5
> ACPI: PCI Interrupt Link [LSA0] enabled at IRQ 15
> PCI: setting IRQ 15 as level-triggered
> sata_nv 0000:00:08.0: PCI INT A -> Link[LSA0] -> GSI 15=20
> (level, low) -> IRQ 15
> sata_nv 0000:00:08.0: setting latency timer to 64
> scsi2 : sata_nv
> scsi3 : sata_nv
> ata1: SATA max UDMA/133 cmd 0xd480 ctl 0xd400 bmdma 0xcc00=20
> irq 15
> ata2: SATA max UDMA/133 cmd 0xd080 ctl 0xd000 bmdma 0xcc08=20
> irq 15
> Error: Driver 'pata_platform' is already registered,=20
> aborting...
> SSFDC read-only Flash Translation layer
> mtdoops: mtd device (mtddev=3Dname/number) must be supplied
> L440GX flash mapping: failed to find PIIX4 ISA bridge,=20
> cannot continue
> device id =3D 2440
> device id =3D 2480
> device id =3D 24c0
> device id =3D 24d0
> device id =3D 25a1
> device id =3D 2670
> physmap-flash.0: failed to claim resource 0
> SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
> Could not find PAR responsible for SC520CDP Flash Bank #0
> Trying default address 0x8400000
> Could not find PAR responsible for SC520CDP Flash Bank #1
> Trying default address 0x8c00000
> Could not find PAR responsible for SC520CDP DIL Flash
> Trying default address 0x9400000
> SC520 CDP flash device: 0x800000 at 0x8400000
> Failed to ioremap_nocache
> NetSc520 flash device: 0x100000 at 0x200000
> Failed to ioremap_nocache
> Failed to ioremap_nocache
> scx200_docflash: NatSemi SCx200 DOCCS Flash Driver
> SNAPGEAR: failed to ioremap() BOOTCS
> Generic platform RAM MTD, (c) 2004 Simtec Electronics
> No recognised DiskOnChip devices found
> slram: not enough parameters.
> Ramix PMC551 PCI Mezzanine Ram Driver. (C) 1999,2000=20
> Nortel Networks.
> pmc551: not detected
> ftl_cs: FTL header not found.
> No valid DiskOnChip devices found
> [nandsim] warning: read_byte: unexpected data output=20
> cycle, state is STATE_READY return 0x0
> [nandsim] warning: read_byte: unexpected data output=20
> cycle, state is STATE_READY return 0x0
> [nandsim] warning: read_byte: unexpected data output=20
> cycle, state is STATE_READY return 0x0
> [nandsim] warning: read_byte: unexpected data output=20
> cycle, state is STATE_READY return 0x0
> [nandsim] warning: read_byte: unexpected data output=20
> cycle, state is STATE_READY return 0x0
> [nandsim] warning: read_byte: unexpected data output=20
> cycle, state is STATE_READY return 0x0
> NAND device: Manufacturer ID: 0x98, Chip ID: 0x39 (Toshiba=20
> )
> flash size: 8 MiB
> page size: 512 bytes
> OOB area size: 16 bytes
> sector size: 8 KiB
> pages number: 16384
> pages per sector: 16
> bus width: 8
> bits in sector size: 13
> bits in page size: 9
> bits in OOB size: 4
> flash size with OOB: 8448 KiB
> page address bytes: 3
> sector address bytes: 2
> options: 0x62
> Scanning device for bad blocks
> Creating 1 MTD partitions on "NAND 8MiB 1,8V 8-bit":
> 0x000000000000-0x000000800000 : "NAND simulator partition=20
> 0"
> ftl_cs: FTL header not found.
> usbcore: registered new interface driver alauda
> onenand_wait: timeout! ctrl=3D0x0000 intr=3D0x0000
> OneNAND Manufacturer: Samsung (0xec)
> OneNAND 16MB 1.8V 16-bit (0x04)
> OneNAND version =3D 0x001e
> Lock scheme is Continuous Lock
> Scanning device for bad blocks
> Creating 1 MTD partitions on "OneNAND simulator":
> 0x000000000000-0x000001000000 : "OneNAND simulator=20
> partition"
> ftl_cs: FTL header not found.
> Fixed MDIO Bus: probed
> Atheros(R) L2 Ethernet Driver - version 2.2.3
> Copyright (c) 2007 Atheros Corporation.
> e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
> e100: Copyright(c) 1999-2006 Intel Corporation
> cnic: Broadcom NetXtreme II CNIC Driver cnic v2.2.6 (Oct=20
> 12, 2010)
> D-Link DE-620 pocket adapter io 0x378, which is busy.
> PPP generic driver version 2.4.2
> PPP Deflate Compression module registered
> PPP BSD Compression module registered
> PPP MPPE Compression module registered
> NET: Registered protocol family 24
> SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels,=20
> max=3D256) (6 bit encapsulation enabled).
> CSLIP: code copyright 1989 Regents of the University of=20
> California.
> SLIP linefill/keepalive option.
> DE600: port 0x378 busy
> atp.c:v1.09=3Dac 2002/10/01 Donald Becker <becker@scyld.com>
> I2O subsystem v1.325
> i2o: max drivers =3D 8
> I2O Configuration OSM v1.323
> I2O Bus Adapter OSM v1.317
> I2O Block Device OSM v1.325
> I2O SCSI Peripheral OSM v1.316
> I2O ProcFS OSM v1.316
> Fusion MPT base driver 3.04.17
> Copyright (c) 1999-2008 LSI Corporation
> Fusion MPT SPI Host driver 3.04.17
> Fusion MPT FC Host driver 3.04.17
> Fusion MPT SAS Host driver 3.04.17
> Fusion MPT misc device (ioctl) driver 3.04.17
> mptctl: Registered with Fusion MPT base driver
> mptctl: /dev/mptctl @ (major,minor=3D10,220)
> Fusion MPT LAN driver 3.04.17
> Intel ISA PCIC probe: not found.
> Databook TCIC-2 PCMCIA probe: not found.
> aoe: AoE v47 initialised.
> paride: aten registered as protocol 0
> paride: bpck registered as protocol 1
> paride: comm registered as protocol 2
> paride: dstr registered as protocol 3
> paride: k951 registered as protocol 4
> paride: k971 registered as protocol 5
> paride: epat registered as protocol 6
> paride: epia registered as protocol 7
> paride: frpw registered as protocol 8
> paride: friq registered as protocol 9
> paride: fit2 registered as protocol 10
> paride: fit3 registered as protocol 11
> paride: on20 registered as protocol 12
> paride: on26 registered as protocol 13
> paride: ktti registered as protocol 14
> bpck6: BACKPACK Protocol Driver V2.0.2
> bpck6: Copyright 2001 by Micro Solutions, Inc., DeKalb IL.=20
> USA
> paride: bpck6 registered as protocol 15
> pd: pd version 1.05, major 45, cluster 64, nice 0
> ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> ata1.00: ATA-8: SAMSUNG HD203WI, 1AN10002, max UDMA/133
> ata1.00: 3907029168 sectors, multi 16: LBA48 NCQ (depth=20
> 0/32)
> ata1.00: configured for UDMA/133
> scsi 2:0:0:0: Direct-Access     ATA      SAMSUNG HD203WI=20
>  1AN1 PQ: 0 ANSI: 5
> sd 2:0:0:0: [sda] 3907029168 512-byte logical blocks:=20
> (2.00 TB/1.81 TiB)
> sd 2:0:0:0: [sda] Write Protect is off
> sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
> sd 2:0:0:0: [sda] Write cache: enabled, read cache:=20
> enabled, doesn't support DPO or FUA
> sd 2:0:0:0: Attached scsi generic sg0 type 0
>   sda: sda1 sda2
> sd 2:0:0:0: [sda] Attached SCSI disk
> ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
> ata2.00: ATAPI: HL-DT-ST DVDRAM GSA-H66N, CB00, max=20
> UDMA/100
> ata2.00: configured for UDMA/100
> scsi 3:0:0:0: CD-ROM            HL-DT-ST DVDRAM GSA-H66N=20
>  CB00 PQ: 0 ANSI: 5
> sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw=20
> xa/form2 cdda tray
> cdrom: Uniform CD-ROM driver Revision: 3.20
> sr 3:0:0:0: Attached scsi CD-ROM sr0
> sr 3:0:0:0: Attached scsi generic sg1 type 5
> pda: Autoprobe failed
> pd: no valid drive found
> pcd: pcd version 1.07, major 46, nice 0
> pcd0: Autoprobe failed
> pcd: No CD-ROM drive found
> pf: pf version 1.04, major 47, cluster 64, nice 0
> pf: No ATAPI disk detected
> pt: pt version 1.04, major 96
> pt0: Autoprobe failed
> pt: No ATAPI tape drive detected
> pg: pg version 1.02, major 97
> pga: Autoprobe failed
> pg: No ATAPI device detected
> usbcore: registered new interface driver hwa-rc
> ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> ACPI: PCI Interrupt Link [LUB2] enabled at IRQ 10
> PCI: setting IRQ 10 as level-triggered
> ehci_hcd 0000:00:02.1: PCI INT B -> Link[LUB2] -> GSI 10=20
> (level, low) -> IRQ 10
> ehci_hcd 0000:00:02.1: setting latency timer to 64
> ehci_hcd 0000:00:02.1: EHCI Host Controller
> ehci_hcd 0000:00:02.1: new USB bus registered, assigned=20
> bus number 1
> ehci_hcd 0000:00:02.1: debug port 1
> ehci_hcd 0000:00:02.1: cache line size of 64 is not=20
> supported
> ehci_hcd 0000:00:02.1: irq 10, io mem 0xdfdfec00
> ehci_hcd 0000:00:02.1: USB 2.0 started, EHCI 1.00
> usb usb1: New USB device found, idVendor=3D1d6b,=20
> idProduct=3D0002
> usb usb1: New USB device strings: Mfr=3D3, Product=3D2,=20
> SerialNumber=3D1
> usb usb1: Product: EHCI Host Controller
> usb usb1: Manufacturer: Linux 2.6.37-rc1 ehci_hcd
> usb usb1: SerialNumber: 0000:00:02.1
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 8 ports detected
> 116x: driver isp116x-hcd, 03 Nov 2005
> driver isp1362-hcd, 2005-04-04
> ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
> ACPI: PCI Interrupt Link [LUB0] enabled at IRQ 11
> ohci_hcd 0000:00:02.0: PCI INT A -> Link[LUB0] -> GSI 11=20
> (level, low) -> IRQ 11
> ohci_hcd 0000:00:02.0: setting latency timer to 64
> ohci_hcd 0000:00:02.0: OHCI Host Controller
> ohci_hcd 0000:00:02.0: new USB bus registered, assigned=20
> bus number 2
> ohci_hcd 0000:00:02.0: irq 11, io mem 0xdfdff000
> usb usb2: New USB device found, idVendor=3D1d6b,=20
> idProduct=3D0001
> usb usb2: New USB device strings: Mfr=3D3, Product=3D2,=20
> SerialNumber=3D1
> usb usb2: Product: OHCI Host Controller
> usb usb2: Manufacturer: Linux 2.6.37-rc1 ohci_hcd
> usb usb2: SerialNumber: 0000:00:02.0
> hub 2-0:1.0: USB hub found
> hub 2-0:1.0: 8 ports detected
> uhci_hcd: USB Universal Host Controller Interface driver
> sl811: driver sl811-hcd, 19 May 2005
> r8a66597_hcd: driver r8a66597_hcd, 2009-05-26
> usbcore: registered new interface driver hwa-hc
> usbcore: registered new interface driver wusb-cbaf
> usbcore: registered new interface driver cdc_acm
> cdc_acm: v0.26:USB Abstract Control Model driver for USB=20
> modems and ISDN adapters
> usbcore: registered new interface driver usblp
> usbcore: registered new interface driver cdc_wdm
> usbcore: registered new interface driver uas
> Initializing USB Mass Storage driver...
> usbcore: registered new interface driver usb-storage
> USB Mass Storage support registered.
> usbcore: registered new interface driver ums-alauda
> usbcore: registered new interface driver ums-cypress
> usbcore: registered new interface driver ums-datafab
> usbcore: registered new interface driver ums-freecom
> usbcore: registered new interface driver ums-isd200
> usbcore: registered new interface driver ums-jumpshot
> usbcore: registered new interface driver ums-karma
> usbcore: registered new interface driver ums-onetouch
> usbcore: registered new interface driver ums-sddr09
> usbcore: registered new interface driver ums-sddr55
> usbcore: registered new interface driver ums-usbat
> PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at=20
> 0x60,0x64 irq 1,12
> serio: i8042 KBD port at 0x60,0x64 irq 1
> serio: i8042 AUX port at 0x60,0x64 irq 12
> serio: PARKBD AT adapter on parport0
> mice: PS/2 mouse device common for all mice
> usbcore: registered new interface driver appletouch
> usbcore: registered new interface driver bcm5974
> inport.c: Didn't find InPort mouse at 0x23c
> logibm.c: Didn't find Logitech busmouse at 0x23c
> usbcore: registered new interface driver usb_acecad
> acecad: v3.2:USB Acecad Flair tablet driver
> usbcore: registered new interface driver aiptek
> aiptek: v2.3 (May 2, 2007):Aiptek HyperPen USB Tablet=20
> Driver (Linux 2.6.x)
> aiptek: Bryan W. Headley/Chris Atenasio/Cedric Brun/Rene=20
> van Paassen
> usbcore: registered new interface driver gtco
> GTCO usb driver version: 2.00.0006
> usbcore: registered new interface driver hanwang
> usbcore: registered new interface driver kbtab
> kbtab: v0.0.2:USB KB Gear JamStudio Tablet driver
> usbcore: registered new interface driver wacom
> wacom: v1.52:USB Wacom tablet driver
> input: PC Speaker as /devices/platform/pcspkr/input/input2
> i2c /dev entries driver
> lirc_dev: IR Remote Control driver registered, major 242
> IR NEC protocol handler initialized
> IR RC5(x) protocol handler initialized
> IR RC6 protocol handler initialized
> IR JVC protocol handler initialized
> IR Sony protocol handler initialized
> IR RC5 (streamzap) protocol handler initialized
> IR LIRC bridge handler initialized
> Linux video capture interface: v2.00
> usbcore: registered new interface driver dabusb
> dabusb: v1.54:DAB-USB Interface Driver for Linux (c)1999
> md: linear personality registered for level -1
> md: raid0 personality registered for level 0
> md: raid1 personality registered for level 1
> md: raid10 personality registered for level 10
> md: raid6 personality registered for level 6
> md: raid5 personality registered for level 5
> md: raid4 personality registered for level 4
> md: multipath personality registered for level -4
> md: faulty personality registered for level -5
> device-mapper: uevent: version 1.0.3
> device-mapper: ioctl: 4.18.0-ioctl (2010-06-29)=20
> initialised: dm-devel@redhat.com
> device-mapper: multipath: version 1.1.1 loaded
> device-mapper: multipath round-robin: version 1.0.0 loaded
> input: AT Translated Set 2 keyboard as=20
> /devices/platform/i8042/serio0/input/input3
> EDAC MC: Ver: 2.1.0 Nov  1 2010
> EISA: Probing bus 0 at eisa.0
> EISA: Cannot allocate resource for mainboard
> Cannot allocate resource for EISA slot 1
> Cannot allocate resource for EISA slot 2
> Cannot allocate resource for EISA slot 3
> Cannot allocate resource for EISA slot 4
> Cannot allocate resource for EISA slot 5
> Cannot allocate resource for EISA slot 6
> Cannot allocate resource for EISA slot 7
> Cannot allocate resource for EISA slot 8
> EISA: Detected 0 cards.
> cpuidle: using governor ladder
> sdhci: Secure Digital Host Controller Interface driver
> sdhci: Copyright(c) Pierre Ossman
> wbsd: Winbond W83L51xD SD/MMC card interface driver
> wbsd: Copyright(c) Pierre Ossman
> via_sdmmc: VIA SD/MMC Card Reader driver (C) 2008 VIA=20
> Technologies, Inc.
> usbcore: registered new interface driver usbhid
> usbhid: USB HID core driver
> XGIfb: Options (null)
> dell-wmi: No known WMI GUID found
> This machine doesn't have MSI-hotkeys through WMI
> Topstar Laptop ACPI extras driver loaded
> oprofile: using timer interrupt.
> TCP cubic registered
> Initializing XFRM netlink socket
> NET: Registered protocol family 17
> NET: Registered protocol family 33
> lib80211: common routines for IEEE802.11 drivers
> lib80211_crypt: registered algorithm 'NULL'
> lib80211_crypt: registered algorithm 'WEP'
> lib80211_crypt: registered algorithm 'CCMP'
> lib80211_crypt: registered algorithm 'TKIP'
> Registering the dns_resolver key type
> powernow-k8: Found 1 AMD Athlon(tm) 64 X2 Dual Core=20
> Processor 4800+ (1 cpu cores) (version 2.20.00)
> [Firmware Bug]: powernow-k8: No PSB or ACPI _PSS objects
> powernow-k8: Make sure that your BIOS is up to date and=20
> Cool'N'Quiet support is enabled in BIOS setup
> Using IPI No-Shortcut mode
> psmouse serio1: ID: 10 00 64
> input: ImPS/2 Generic Wheel Mouse as=20
> /devices/platform/i8042/serio1/input/input4
> kAFS: Red Hat AFS client v0.1 registering.
> raid6test: testing the 4-disk case...
> raid6test: test_disks(0, 1): faila=3D  0(D)  failb=3D  1(D)=20
>  OK
> raid6test: test_disks(0, 2): faila=3D  0(D)  failb=3D  2(P)=20
>  OK
> raid6test: test_disks(0, 3): faila=3D  0(D)  failb=3D  3(Q)=20
>  OK
> raid6test: test_disks(1, 2): faila=3D  1(D)  failb=3D  2(P)=20
>  OK
> raid6test: test_disks(1, 3): faila=3D  1(D)  failb=3D  3(Q)=20
>  OK
> raid6test: test_disks(2, 3): faila=3D  2(P)  failb=3D  3(Q)=20
>  OK
> raid6test: testing the 5-disk case...
> raid6test: test_disks(0, 1): faila=3D  0(D)  failb=3D  1(D)=20
>  OK
> raid6test: test_disks(0, 2): faila=3D  0(D)  failb=3D  2(D)=20
>  OK
> raid6test: test_disks(0, 3): faila=3D  0(D)  failb=3D  3(P)=20
>  OK
> raid6test: test_disks(0, 4): faila=3D  0(D)  failb=3D  4(Q)=20
>  OK
> raid6test: test_disks(1, 2): faila=3D  1(D)  failb=3D  2(D)=20
>  OK
> raid6test: test_disks(1, 3): faila=3D  1(D)  failb=3D  3(P)=20
>  OK
> raid6test: test_disks(1, 4): faila=3D  1(D)  failb=3D  4(Q)=20
>  OK
> raid6test: test_disks(2, 3): faila=3D  2(D)  failb=3D  3(P)=20
>  OK
> raid6test: test_disks(2, 4): faila=3D  2(D)  failb=3D  4(Q)=20
>  OK
> raid6test: test_disks(3, 4): faila=3D  3(P)  failb=3D  4(Q)=20
>  OK
> raid6test: testing the 11-disk case...
> raid6test: test_disks(0, 1): faila=3D  0(D)  failb=3D  1(D)=20
>  OK
> raid6test: test_disks(0, 2): faila=3D  0(D)  failb=3D  2(D)=20
>  OK
> raid6test: test_disks(0, 3): faila=3D  0(D)  failb=3D  3(D)=20
>  OK
> raid6test: test_disks(0, 4): faila=3D  0(D)  failb=3D  4(D)=20
>  OK
> raid6test: test_disks(0, 5): faila=3D  0(D)  failb=3D  5(D)=20
>  OK
> raid6test: test_disks(0, 6): faila=3D  0(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(0, 7): faila=3D  0(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(0, 8): faila=3D  0(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(0, 9): faila=3D  0(D)  failb=3D  9(P)=20
>  OK
> raid6test: test_disks(0, 10): faila=3D  0(D)  failb=3D 10(Q)=20
>  OK
> raid6test: test_disks(1, 2): faila=3D  1(D)  failb=3D  2(D)=20
>  OK
> raid6test: test_disks(1, 3): faila=3D  1(D)  failb=3D  3(D)=20
>  OK
> raid6test: test_disks(1, 4): faila=3D  1(D)  failb=3D  4(D)=20
>  OK
> raid6test: test_disks(1, 5): faila=3D  1(D)  failb=3D  5(D)=20
>  OK
> raid6test: test_disks(1, 6): faila=3D  1(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(1, 7): faila=3D  1(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(1, 8): faila=3D  1(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(1, 9): faila=3D  1(D)  failb=3D  9(P)=20
>  OK
> raid6test: test_disks(1, 10): faila=3D  1(D)  failb=3D 10(Q)=20
>  OK
> raid6test: test_disks(2, 3): faila=3D  2(D)  failb=3D  3(D)=20
>  OK
> raid6test: test_disks(2, 4): faila=3D  2(D)  failb=3D  4(D)=20
>  OK
> raid6test: test_disks(2, 5): faila=3D  2(D)  failb=3D  5(D)=20
>  OK
> raid6test: test_disks(2, 6): faila=3D  2(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(2, 7): faila=3D  2(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(2, 8): faila=3D  2(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(2, 9): faila=3D  2(D)  failb=3D  9(P)=20
>  OK
> raid6test: test_disks(2, 10): faila=3D  2(D)  failb=3D 10(Q)=20
>  OK
> raid6test: test_disks(3, 4): faila=3D  3(D)  failb=3D  4(D)=20
>  OK
> raid6test: test_disks(3, 5): faila=3D  3(D)  failb=3D  5(D)=20
>  OK
> raid6test: test_disks(3, 6): faila=3D  3(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(3, 7): faila=3D  3(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(3, 8): faila=3D  3(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(3, 9): faila=3D  3(D)  failb=3D  9(P)=20
>  OK
> raid6test: test_disks(3, 10): faila=3D  3(D)  failb=3D 10(Q)=20
>  OK
> raid6test: test_disks(4, 5): faila=3D  4(D)  failb=3D  5(D)=20
>  OK
> raid6test: test_disks(4, 6): faila=3D  4(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(4, 7): faila=3D  4(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(4, 8): faila=3D  4(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(4, 9): faila=3D  4(D)  failb=3D  9(P)=20
>  OK
> raid6test: test_disks(4, 10): faila=3D  4(D)  failb=3D 10(Q)=20
>  OK
> raid6test: test_disks(5, 6): faila=3D  5(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(5, 7): faila=3D  5(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(5, 8): faila=3D  5(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(5, 9): faila=3D  5(D)  failb=3D  9(P)=20
>  OK
> raid6test: test_disks(5, 10): faila=3D  5(D)  failb=3D 10(Q)=20
>  OK
> raid6test: test_disks(6, 7): faila=3D  6(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(6, 8): faila=3D  6(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(6, 9): faila=3D  6(D)  failb=3D  9(P)=20
>  OK
> raid6test: test_disks(6, 10): faila=3D  6(D)  failb=3D 10(Q)=20
>  OK
> raid6test: test_disks(7, 8): faila=3D  7(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(7, 9): faila=3D  7(D)  failb=3D  9(P)=20
>  OK
> raid6test: test_disks(7, 10): faila=3D  7(D)  failb=3D 10(Q)=20
>  OK
> raid6test: test_disks(8, 9): faila=3D  8(D)  failb=3D  9(P)=20
>  OK
> raid6test: test_disks(8, 10): faila=3D  8(D)  failb=3D 10(Q)=20
>  OK
> raid6test: test_disks(9, 10): faila=3D  9(P)  failb=3D 10(Q)=20
>  OK
> raid6test: testing the 12-disk case...
> raid6test: test_disks(0, 1): faila=3D  0(D)  failb=3D  1(D)=20
>  OK
> raid6test: test_disks(0, 2): faila=3D  0(D)  failb=3D  2(D)=20
>  OK
> raid6test: test_disks(0, 3): faila=3D  0(D)  failb=3D  3(D)=20
>  OK
> raid6test: test_disks(0, 4): faila=3D  0(D)  failb=3D  4(D)=20
>  OK
> raid6test: test_disks(0, 5): faila=3D  0(D)  failb=3D  5(D)=20
>  OK
> raid6test: test_disks(0, 6): faila=3D  0(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(0, 7): faila=3D  0(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(0, 8): faila=3D  0(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(0, 9): faila=3D  0(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(0, 10): faila=3D  0(D)  failb=3D 10(P)=20
>  OK
> raid6test: test_disks(0, 11): faila=3D  0(D)  failb=3D 11(Q)=20
>  OK
> raid6test: test_disks(1, 2): faila=3D  1(D)  failb=3D  2(D)=20
>  OK
> raid6test: test_disks(1, 3): faila=3D  1(D)  failb=3D  3(D)=20
>  OK
> raid6test: test_disks(1, 4): faila=3D  1(D)  failb=3D  4(D)=20
>  OK
> raid6test: test_disks(1, 5): faila=3D  1(D)  failb=3D  5(D)=20
>  OK
> raid6test: test_disks(1, 6): faila=3D  1(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(1, 7): faila=3D  1(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(1, 8): faila=3D  1(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(1, 9): faila=3D  1(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(1, 10): faila=3D  1(D)  failb=3D 10(P)=20
>  OK
> raid6test: test_disks(1, 11): faila=3D  1(D)  failb=3D 11(Q)=20
>  OK
> raid6test: test_disks(2, 3): faila=3D  2(D)  failb=3D  3(D)=20
>  OK
> raid6test: test_disks(2, 4): faila=3D  2(D)  failb=3D  4(D)=20
>  OK
> raid6test: test_disks(2, 5): faila=3D  2(D)  failb=3D  5(D)=20
>  OK
> raid6test: test_disks(2, 6): faila=3D  2(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(2, 7): faila=3D  2(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(2, 8): faila=3D  2(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(2, 9): faila=3D  2(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(2, 10): faila=3D  2(D)  failb=3D 10(P)=20
>  OK
> raid6test: test_disks(2, 11): faila=3D  2(D)  failb=3D 11(Q)=20
>  OK
> raid6test: test_disks(3, 4): faila=3D  3(D)  failb=3D  4(D)=20
>  OK
> raid6test: test_disks(3, 5): faila=3D  3(D)  failb=3D  5(D)=20
>  OK
> raid6test: test_disks(3, 6): faila=3D  3(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(3, 7): faila=3D  3(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(3, 8): faila=3D  3(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(3, 9): faila=3D  3(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(3, 10): faila=3D  3(D)  failb=3D 10(P)=20
>  OK
> raid6test: test_disks(3, 11): faila=3D  3(D)  failb=3D 11(Q)=20
>  OK
> raid6test: test_disks(4, 5): faila=3D  4(D)  failb=3D  5(D)=20
>  OK
> raid6test: test_disks(4, 6): faila=3D  4(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(4, 7): faila=3D  4(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(4, 8): faila=3D  4(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(4, 9): faila=3D  4(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(4, 10): faila=3D  4(D)  failb=3D 10(P)=20
>  OK
> raid6test: test_disks(4, 11): faila=3D  4(D)  failb=3D 11(Q)=20
>  OK
> raid6test: test_disks(5, 6): faila=3D  5(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(5, 7): faila=3D  5(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(5, 8): faila=3D  5(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(5, 9): faila=3D  5(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(5, 10): faila=3D  5(D)  failb=3D 10(P)=20
>  OK
> raid6test: test_disks(5, 11): faila=3D  5(D)  failb=3D 11(Q)=20
>  OK
> raid6test: test_disks(6, 7): faila=3D  6(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(6, 8): faila=3D  6(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(6, 9): faila=3D  6(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(6, 10): faila=3D  6(D)  failb=3D 10(P)=20
>  OK
> raid6test: test_disks(6, 11): faila=3D  6(D)  failb=3D 11(Q)=20
>  OK
> raid6test: test_disks(7, 8): faila=3D  7(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(7, 9): faila=3D  7(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(7, 10): faila=3D  7(D)  failb=3D 10(P)=20
>  OK
> raid6test: test_disks(7, 11): faila=3D  7(D)  failb=3D 11(Q)=20
>  OK
> raid6test: test_disks(8, 9): faila=3D  8(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(8, 10): faila=3D  8(D)  failb=3D 10(P)=20
>  OK
> raid6test: test_disks(8, 11): faila=3D  8(D)  failb=3D 11(Q)=20
>  OK
> raid6test: test_disks(9, 10): faila=3D  9(D)  failb=3D 10(P)=20
>  OK
> raid6test: test_disks(9, 11): faila=3D  9(D)  failb=3D 11(Q)=20
>  OK
> raid6test: test_disks(10, 11): faila=3D 10(P)  failb=3D 11(Q)=20
>  OK
> raid6test: testing the 16-disk case...
> raid6test: test_disks(0, 1): faila=3D  0(D)  failb=3D  1(D)=20
>  OK
> raid6test: test_disks(0, 2): faila=3D  0(D)  failb=3D  2(D)=20
>  OK
> raid6test: test_disks(0, 3): faila=3D  0(D)  failb=3D  3(D)=20
>  OK
> raid6test: test_disks(0, 4): faila=3D  0(D)  failb=3D  4(D)=20
>  OK
> raid6test: test_disks(0, 5): faila=3D  0(D)  failb=3D  5(D)=20
>  OK
> raid6test: test_disks(0, 6): faila=3D  0(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(0, 7): faila=3D  0(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(0, 8): faila=3D  0(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(0, 9): faila=3D  0(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(0, 10): faila=3D  0(D)  failb=3D 10(D)=20
>  OK
> raid6test: test_disks(0, 11): faila=3D  0(D)  failb=3D 11(D)=20
>  OK
> raid6test: test_disks(0, 12): faila=3D  0(D)  failb=3D 12(D)=20
>  OK
> raid6test: test_disks(0, 13): faila=3D  0(D)  failb=3D 13(D)=20
>  OK
> raid6test: test_disks(0, 14): faila=3D  0(D)  failb=3D 14(P)=20
>  OK
> raid6test: test_disks(0, 15): faila=3D  0(D)  failb=3D 15(Q)=20
>  OK
> raid6test: test_disks(1, 2): faila=3D  1(D)  failb=3D  2(D)=20
>  OK
> raid6test: test_disks(1, 3): faila=3D  1(D)  failb=3D  3(D)=20
>  OK
> raid6test: test_disks(1, 4): faila=3D  1(D)  failb=3D  4(D)=20
>  OK
> raid6test: test_disks(1, 5): faila=3D  1(D)  failb=3D  5(D)=20
>  OK
> raid6test: test_disks(1, 6): faila=3D  1(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(1, 7): faila=3D  1(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(1, 8): faila=3D  1(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(1, 9): faila=3D  1(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(1, 10): faila=3D  1(D)  failb=3D 10(D)=20
>  OK
> raid6test: test_disks(1, 11): faila=3D  1(D)  failb=3D 11(D)=20
>  OK
> raid6test: test_disks(1, 12): faila=3D  1(D)  failb=3D 12(D)=20
>  OK
> raid6test: test_disks(1, 13): faila=3D  1(D)  failb=3D 13(D)=20
>  OK
> raid6test: test_disks(1, 14): faila=3D  1(D)  failb=3D 14(P)=20
>  OK
> raid6test: test_disks(1, 15): faila=3D  1(D)  failb=3D 15(Q)=20
>  OK
> raid6test: test_disks(2, 3): faila=3D  2(D)  failb=3D  3(D)=20
>  OK
> raid6test: test_disks(2, 4): faila=3D  2(D)  failb=3D  4(D)=20
>  OK
> raid6test: test_disks(2, 5): faila=3D  2(D)  failb=3D  5(D)=20
>  OK
> raid6test: test_disks(2, 6): faila=3D  2(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(2, 7): faila=3D  2(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(2, 8): faila=3D  2(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(2, 9): faila=3D  2(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(2, 10): faila=3D  2(D)  failb=3D 10(D)=20
>  OK
> raid6test: test_disks(2, 11): faila=3D  2(D)  failb=3D 11(D)=20
>  OK
> raid6test: test_disks(2, 12): faila=3D  2(D)  failb=3D 12(D)=20
>  OK
> raid6test: test_disks(2, 13): faila=3D  2(D)  failb=3D 13(D)=20
>  OK
> raid6test: test_disks(2, 14): faila=3D  2(D)  failb=3D 14(P)=20
>  OK
> raid6test: test_disks(2, 15): faila=3D  2(D)  failb=3D 15(Q)=20
>  OK
> raid6test: test_disks(3, 4): faila=3D  3(D)  failb=3D  4(D)=20
>  OK
> raid6test: test_disks(3, 5): faila=3D  3(D)  failb=3D  5(D)=20
>  OK
> raid6test: test_disks(3, 6): faila=3D  3(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(3, 7): faila=3D  3(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(3, 8): faila=3D  3(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(3, 9): faila=3D  3(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(3, 10): faila=3D  3(D)  failb=3D 10(D)=20
>  OK
> raid6test: test_disks(3, 11): faila=3D  3(D)  failb=3D 11(D)=20
>  OK
> raid6test: test_disks(3, 12): faila=3D  3(D)  failb=3D 12(D)=20
>  OK
> raid6test: test_disks(3, 13): faila=3D  3(D)  failb=3D 13(D)=20
>  OK
> raid6test: test_disks(3, 14): faila=3D  3(D)  failb=3D 14(P)=20
>  OK
> raid6test: test_disks(3, 15): faila=3D  3(D)  failb=3D 15(Q)=20
>  OK
> raid6test: test_disks(4, 5): faila=3D  4(D)  failb=3D  5(D)=20
>  OK
> raid6test: test_disks(4, 6): faila=3D  4(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(4, 7): faila=3D  4(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(4, 8): faila=3D  4(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(4, 9): faila=3D  4(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(4, 10): faila=3D  4(D)  failb=3D 10(D)=20
>  OK
> raid6test: test_disks(4, 11): faila=3D  4(D)  failb=3D 11(D)=20
>  OK
> raid6test: test_disks(4, 12): faila=3D  4(D)  failb=3D 12(D)=20
>  OK
> raid6test: test_disks(4, 13): faila=3D  4(D)  failb=3D 13(D)=20
>  OK
> raid6test: test_disks(4, 14): faila=3D  4(D)  failb=3D 14(P)=20
>  OK
> raid6test: test_disks(4, 15): faila=3D  4(D)  failb=3D 15(Q)=20
>  OK
> raid6test: test_disks(5, 6): faila=3D  5(D)  failb=3D  6(D)=20
>  OK
> raid6test: test_disks(5, 7): faila=3D  5(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(5, 8): faila=3D  5(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(5, 9): faila=3D  5(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(5, 10): faila=3D  5(D)  failb=3D 10(D)=20
>  OK
> raid6test: test_disks(5, 11): faila=3D  5(D)  failb=3D 11(D)=20
>  OK
> raid6test: test_disks(5, 12): faila=3D  5(D)  failb=3D 12(D)=20
>  OK
> raid6test: test_disks(5, 13): faila=3D  5(D)  failb=3D 13(D)=20
>  OK
> raid6test: test_disks(5, 14): faila=3D  5(D)  failb=3D 14(P)=20
>  OK
> raid6test: test_disks(5, 15): faila=3D  5(D)  failb=3D 15(Q)=20
>  OK
> raid6test: test_disks(6, 7): faila=3D  6(D)  failb=3D  7(D)=20
>  OK
> raid6test: test_disks(6, 8): faila=3D  6(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(6, 9): faila=3D  6(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(6, 10): faila=3D  6(D)  failb=3D 10(D)=20
>  OK
> raid6test: test_disks(6, 11): faila=3D  6(D)  failb=3D 11(D)=20
>  OK
> raid6test: test_disks(6, 12): faila=3D  6(D)  failb=3D 12(D)=20
>  OK
> raid6test: test_disks(6, 13): faila=3D  6(D)  failb=3D 13(D)=20
>  OK
> raid6test: test_disks(6, 14): faila=3D  6(D)  failb=3D 14(P)=20
>  OK
> raid6test: test_disks(6, 15): faila=3D  6(D)  failb=3D 15(Q)=20
>  OK
> raid6test: test_disks(7, 8): faila=3D  7(D)  failb=3D  8(D)=20
>  OK
> raid6test: test_disks(7, 9): faila=3D  7(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(7, 10): faila=3D  7(D)  failb=3D 10(D)=20
>  OK
> raid6test: test_disks(7, 11): faila=3D  7(D)  failb=3D 11(D)=20
>  OK
> raid6test: test_disks(7, 12): faila=3D  7(D)  failb=3D 12(D)=20
>  OK
> raid6test: test_disks(7, 13): faila=3D  7(D)  failb=3D 13(D)=20
>  OK
> raid6test: test_disks(7, 14): faila=3D  7(D)  failb=3D 14(P)=20
>  OK
> raid6test: test_disks(7, 15): faila=3D  7(D)  failb=3D 15(Q)=20
>  OK
> raid6test: test_disks(8, 9): faila=3D  8(D)  failb=3D  9(D)=20
>  OK
> raid6test: test_disks(8, 10): faila=3D  8(D)  failb=3D 10(D)=20
>  OK
> raid6test: test_disks(8, 11): faila=3D  8(D)  failb=3D 11(D)=20
>  OK
> raid6test: test_disks(8, 12): faila=3D  8(D)  failb=3D 12(D)=20
>  OK
> raid6test: test_disks(8, 13): faila=3D  8(D)  failb=3D 13(D)=20
>  OK
> raid6test: test_disks(8, 14): faila=3D  8(D)  failb=3D 14(P)=20
>  OK
> raid6test: test_disks(8, 15): faila=3D  8(D)  failb=3D 15(Q)=20
>  OK
> raid6test: test_disks(9, 10): faila=3D  9(D)  failb=3D 10(D)=20
>  OK
> raid6test: test_disks(9, 11): faila=3D  9(D)  failb=3D 11(D)=20
>  OK
> raid6test: test_disks(9, 12): faila=3D  9(D)  failb=3D 12(D)=20
>  OK
> raid6test: test_disks(9, 13): faila=3D  9(D)  failb=3D 13(D)=20
>  OK
> raid6test: test_disks(9, 14): faila=3D  9(D)  failb=3D 14(P)=20
>  OK
> raid6test: test_disks(9, 15): faila=3D  9(D)  failb=3D 15(Q)=20
>  OK
> raid6test: test_disks(10, 11): faila=3D 10(D)  failb=3D 11(D)=20
>  OK
> raid6test: test_disks(10, 12): faila=3D 10(D)  failb=3D 12(D)=20
>  OK
> raid6test: test_disks(10, 13): faila=3D 10(D)  failb=3D 13(D)=20
>  OK
> raid6test: test_disks(10, 14): faila=3D 10(D)  failb=3D 14(P)=20
>  OK
> raid6test: test_disks(10, 15): faila=3D 10(D)  failb=3D 15(Q)=20
>  OK
> raid6test: test_disks(11, 12): faila=3D 11(D)  failb=3D 12(D)=20
>  OK
> raid6test: test_disks(11, 13): faila=3D 11(D)  failb=3D 13(D)=20
>  OK
> raid6test: test_disks(11, 14): faila=3D 11(D)  failb=3D 14(P)=20
>  OK
> raid6test: test_disks(11, 15): faila=3D 11(D)  failb=3D 15(Q)=20
>  OK
> raid6test: test_disks(12, 13): faila=3D 12(D)  failb=3D 13(D)=20
>  OK
> raid6test: test_disks(12, 14): faila=3D 12(D)  failb=3D 14(P)=20
>  OK
> raid6test: test_disks(12, 15): faila=3D 12(D)  failb=3D 15(Q)=20
>  OK
> raid6test: test_disks(13, 14): faila=3D 13(D)  failb=3D 14(P)=20
>  OK
> raid6test: test_disks(13, 15): faila=3D 13(D)  failb=3D 15(Q)=20
>  OK
> raid6test: test_disks(14, 15): faila=3D 14(P)  failb=3D 15(Q)=20
>  OK
> raid6test:
> raid6test: complete (257 tests, 0 failures)
> BIOS EDD facility v0.16 2004-Jun-25, 1 devices found
> md: Waiting for all devices to be available before=20
> autodetect
> md: If you don't use raid, use raid=3Dnoautodetect
> md: Autodetecting RAID arrays.
> md: Scanned 0 and added 0 devices.
> md: autorun ...
> md: ... autorun DONE.
> EXT3-fs: barriers not enabled
> EXT3-fs (sda1): mounted filesystem with ordered data mode
> VFS: Mounted root (ext3 filesystem) readonly on device=20
> 8:1.
> kjournald starting.  Commit interval 5 seconds
> devtmpfs: mounted
> Freeing unused kernel memory: 876k freed
> udevd (2424): /proc/2424/oom_adj is deprecated, please use=20
> /proc/2424/oom_score_adj instead.
> i2c i2c-3: nForce2 SMBus adapter at 0x600
> i2c i2c-4: nForce2 SMBus adapter at 0x700
> k8temp 0000:00:18.3: Temperature readouts might be wrong -=20
> check erratum #141
> ACPI: PCI Interrupt Link [LAZA] enabled at IRQ 11
> HDA Intel 0000:00:05.0: PCI INT B -> Link[LAZA] -> GSI 11=20
> (level, low) -> IRQ 11
> hda_intel: Disable MSI for Nvidia chipset
> HDA Intel 0000:00:05.0: setting latency timer to 64
> rtc_cmos 00:02: RTC can wake from S4
> rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
> rtc0: alarms up to one year, y3k, 114 bytes nvram, hpet=20
> irqs
> 8139too: 8139too Fast Ethernet driver 0.9.28
> ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 11
> 8139too 0000:01:07.0: PCI INT A -> Link[LNKB] -> GSI 11=20
> (level, low) -> IRQ 11
> 8139too 0000:01:07.0: eth0: RealTek RTL8139 at 0xe800,=20
> 00:08:a1:6d:38:47, IRQ 11
> ACPI: PCI Interrupt Link [LNEA] enabled at IRQ 11
> atl1 0000:04:00.0: PCI INT A -> Link[LNEA] -> GSI 11=20
> (level, low) -> IRQ 11
> atl1 0000:04:00.0: setting latency timer to 64
> atl1 0000:04:00.0: version 2.1.3
> BUG: unable to handle kernel NULL pointer dereference at=20
> 00000008
> IP: [<feee45f4>] atl1_probe+0x7ee/0x992 [atl1]
> *pde =3D 00000000
> Oops: 0002 [#1] PREEMPT SMP
> last sysfs file: /sys/devices/platform/i8042/modalias
> Modules linked in: tpm_tis tpm atl1(+) tpm_bios 8139too=20
> rtc_cmos rtc_core rtc_lib snd_hda_intel(+) asus_atk0110=20
> snd_hda_codec snd_hwdep snd_pcm k8temp snd_timer snd=20
> soundcore snd_page_alloc i2c_nforce2
>=20
> Pid: 3174, comm: modprobe Not tainted 2.6.37-rc1 #1=20
> M2N8-VMX/System Product Name
> EIP: 0060:[<feee45f4>] EFLAGS: 00010246 CPU: 0
> EIP is at atl1_probe+0x7ee/0x992 [atl1]
> EAX: 00000008 EBX: 00000000 ECX: f5128000 EDX: 00000000
> ESI: f51283c0 EDI: 00000000 EBP: f514be44 ESP: f514bdb4
>   DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> Process modprobe (pid: 3174, ti=3Df514a000 task=3Df509f480=20
> task.ti=3Df514a000)
> Stack:
>   f5c93060 feee4cc1 feee4be6 f50ab848 f514bdd8 f51283c0=20
> 00000000 f517c120
>   f51285f7 f5c93000 f51285a4 f5128000 f5c93000 f51712fc=20
> c1d8f1af f514be1c
>   c111fd66 f514be00 00000128 00000008 f517c120 f514be48=20
> 00000000 00000000
> Call Trace:
>   [<c1d8f1af>] ? mutex_unlock+0x8/0x1b
>   [<c111fd66>] ? sysfs_addrm_finish+0x1a/0xa8
>   [<c157b2fe>] ? local_pci_probe+0x41/0x85
>   [<c157be71>] ? pci_device_probe+0x48/0x6b
>   [<c1762fe1>] ? driver_probe_device+0x9c/0x145
>   [<c17630d2>] ? __driver_attach+0x48/0x64
>   [<c17628b4>] ? bus_for_each_dev+0x42/0x6c
>   [<c1762e6a>] ? driver_attach+0x1e/0x20
>   [<c176308a>] ? __driver_attach+0x0/0x64
>   [<c17622c9>] ? bus_add_driver+0x124/0x268
>   [<c1763363>] ? driver_register+0x98/0xf8
>   [<c157c068>] ? __pci_register_driver+0x3d/0x96
>   [<feee8017>] ? atl1_init_module+0x17/0x19 [atl1]
>   [<c100117e>] ? do_one_initcall+0x8c/0x142
>   [<feee8000>] ? atl1_init_module+0x0/0x19 [atl1]
>   [<c106b759>] ? sys_init_module+0x83/0x1b7
>   [<c10cea83>] ? sys_read+0x42/0x66
>   [<c1d909dc>] ? syscall_call+0x7/0xb
> Code: 4a 68 c2 8b 96 e4 01 00 00 81 c2 08 10 00 00 80 cc=20
> 80 e8 e9 49 68 c2 8b 45 9c e8 0f 6b da c2 8b 45 9c 8b 90=20
> d0 01 00 00 8d 42 08 <f0> 80 4a 08 01 c7 86 3c 01 00 00 31=20
> 0a ee fe 89 b6 40 01 00 00
> EIP: [<feee45f4>] atl1_probe+0x7ee/0x992 [atl1] SS:ESP=20
> 0068:f514bdb4
> CR2: 0000000000000008
> ---[ end trace 7a332cb401051431 ]---
> EXT3-fs (sda1): using internal journal
> parport0: no more devices allowed
> lp: driver loaded but no devices found
> usbcore: registered new interface driver uvcvideo
> USB Video Class driver (v1.0.0)
> rt2860sta: module is from the staging directory, the=20
> quality is unknown, you have been warned.
> usbcore: registered new interface driver snd-usb-audio
> EXT3-fs: barriers not enabled
> EXT3-fs (sda2): warning: maximal mount count reached,=20
> running e2fsck is recommended
> kjournald starting.  Commit interval 5 seconds
> EXT3-fs (sda2): using internal journal
> EXT3-fs (sda2): mounted filesystem with ordered data mode
>=20
>=20
>=20
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
> #
> # Automatically generated make config: don't edit
> # Linux/i386 2.6.37-rc1 Kernel Configuration
> # Mon Nov  1 20:48:50 2010
> #
> # CONFIG_64BIT is not set
> CONFIG_X86_32=3Dy
> # CONFIG_X86_64 is not set
> CONFIG_X86=3Dy
> CONFIG_INSTRUCTION_DECODER=3Dy
> CONFIG_OUTPUT_FORMAT=3D"elf32-i386"
> CONFIG_ARCH_DEFCONFIG=3D"arch/x86/configs/i386_defconfig"
> CONFIG_GENERIC_CMOS_UPDATE=3Dy
> CONFIG_CLOCKSOURCE_WATCHDOG=3Dy
> CONFIG_GENERIC_CLOCKEVENTS=3Dy
> CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=3Dy
> CONFIG_LOCKDEP_SUPPORT=3Dy
> CONFIG_STACKTRACE_SUPPORT=3Dy
> CONFIG_HAVE_LATENCYTOP_SUPPORT=3Dy
> CONFIG_MMU=3Dy
> CONFIG_ZONE_DMA=3Dy
> # CONFIG_NEED_DMA_MAP_STATE is not set
> CONFIG_NEED_SG_DMA_LENGTH=3Dy
> CONFIG_GENERIC_ISA_DMA=3Dy
> CONFIG_GENERIC_IOMAP=3Dy
> CONFIG_GENERIC_BUG=3Dy
> CONFIG_GENERIC_HWEIGHT=3Dy
> CONFIG_GENERIC_GPIO=3Dy
> CONFIG_ARCH_MAY_HAVE_PC_FDC=3Dy
> # CONFIG_RWSEM_GENERIC_SPINLOCK is not set
> CONFIG_RWSEM_XCHGADD_ALGORITHM=3Dy
> CONFIG_ARCH_HAS_CPU_IDLE_WAIT=3Dy
> CONFIG_GENERIC_CALIBRATE_DELAY=3Dy
> # CONFIG_GENERIC_TIME_VSYSCALL is not set
> CONFIG_ARCH_HAS_CPU_RELAX=3Dy
> CONFIG_ARCH_HAS_DEFAULT_IDLE=3Dy
> CONFIG_ARCH_HAS_CACHE_LINE_SIZE=3Dy
> CONFIG_HAVE_SETUP_PER_CPU_AREA=3Dy
> CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=3Dy
> CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=3Dy
> # CONFIG_HAVE_CPUMASK_OF_CPU_MAP is not set
> CONFIG_ARCH_HIBERNATION_POSSIBLE=3Dy
> CONFIG_ARCH_SUSPEND_POSSIBLE=3Dy
> # CONFIG_ZONE_DMA32 is not set
> CONFIG_ARCH_POPULATES_NODE_MAP=3Dy
> # CONFIG_AUDIT_ARCH is not set
> CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=3Dy
> CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=3Dy
> CONFIG_USE_GENERIC_SMP_HELPERS=3Dy
> CONFIG_X86_32_SMP=3Dy
> CONFIG_X86_HT=3Dy
> CONFIG_X86_TRAMPOLINE=3Dy
> CONFIG_ARCH_HWEIGHT_CFLAGS=3D"-fcall-saved-ecx=20
> -fcall-saved-edx"
> CONFIG_KTIME_SCALAR=3Dy
> CONFIG_ARCH_CPU_PROBE_RELEASE=3Dy
> CONFIG_DEFCONFIG_LIST=3D"/lib/modules/$UNAME_RELEASE/.config"
> CONFIG_CONSTRUCTORS=3Dy
> CONFIG_HAVE_IRQ_WORK=3Dy
> CONFIG_IRQ_WORK=3Dy
>=20
> #
> # General setup
> #
> CONFIG_EXPERIMENTAL=3Dy
> CONFIG_LOCK_KERNEL=3Dy
> CONFIG_INIT_ENV_ARG_LIMIT=3D32
> CONFIG_CROSS_COMPILE=3D""
> CONFIG_LOCALVERSION=3D""
> # CONFIG_LOCALVERSION_AUTO is not set
> CONFIG_HAVE_KERNEL_GZIP=3Dy
> CONFIG_HAVE_KERNEL_BZIP2=3Dy
> CONFIG_HAVE_KERNEL_LZMA=3Dy
> CONFIG_HAVE_KERNEL_LZO=3Dy
> CONFIG_KERNEL_GZIP=3Dy
> # CONFIG_KERNEL_BZIP2 is not set
> # CONFIG_KERNEL_LZMA is not set
> # CONFIG_KERNEL_LZO is not set
> CONFIG_SWAP=3Dy
> CONFIG_SYSVIPC=3Dy
> CONFIG_SYSVIPC_SYSCTL=3Dy
> CONFIG_POSIX_MQUEUE=3Dy
> CONFIG_POSIX_MQUEUE_SYSCTL=3Dy
> CONFIG_BSD_PROCESS_ACCT=3Dy
> CONFIG_BSD_PROCESS_ACCT_V3=3Dy
> # CONFIG_TASKSTATS is not set
> CONFIG_AUDIT=3Dy
> CONFIG_AUDITSYSCALL=3Dy
> CONFIG_AUDIT_WATCH=3Dy
> CONFIG_AUDIT_TREE=3Dy
> CONFIG_HAVE_GENERIC_HARDIRQS=3Dy
>=20
> #
> # IRQ subsystem
> #
> CONFIG_GENERIC_HARDIRQS=3Dy
> CONFIG_GENERIC_HARDIRQS_NO__DO_IRQ=3Dy
> # CONFIG_GENERIC_HARDIRQS_NO_DEPRECATED is not set
> CONFIG_HAVE_SPARSE_IRQ=3Dy
> CONFIG_GENERIC_IRQ_PROBE=3Dy
> CONFIG_GENERIC_PENDING_IRQ=3Dy
> # CONFIG_AUTO_IRQ_AFFINITY is not set
> # CONFIG_IRQ_PER_CPU is not set
> # CONFIG_HARDIRQS_SW_RESEND is not set
> # CONFIG_SPARSE_IRQ is not set
>=20
> #
> # RCU Subsystem
> #
> CONFIG_TREE_PREEMPT_RCU=3Dy
> CONFIG_PREEMPT_RCU=3Dy
> # CONFIG_RCU_TRACE is not set
> CONFIG_RCU_FANOUT=3D32
> # CONFIG_RCU_FANOUT_EXACT is not set
> # CONFIG_TREE_RCU_TRACE is not set
> CONFIG_IKCONFIG=3Dy
> CONFIG_IKCONFIG_PROC=3Dy
> CONFIG_LOG_BUF_SHIFT=3D21
> CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=3Dy
> # CONFIG_CGROUPS is not set
> CONFIG_NAMESPACES=3Dy
> CONFIG_UTS_NS=3Dy
> CONFIG_IPC_NS=3Dy
> CONFIG_USER_NS=3Dy
> CONFIG_PID_NS=3Dy
> CONFIG_NET_NS=3Dy
> # CONFIG_SYSFS_DEPRECATED is not set
> CONFIG_RELAY=3Dy
> CONFIG_BLK_DEV_INITRD=3Dy
> CONFIG_INITRAMFS_SOURCE=3D""
> CONFIG_RD_GZIP=3Dy
> CONFIG_RD_BZIP2=3Dy
> CONFIG_RD_LZMA=3Dy
> CONFIG_RD_LZO=3Dy
> CONFIG_CC_OPTIMIZE_FOR_SIZE=3Dy
> CONFIG_SYSCTL=3Dy
> CONFIG_ANON_INODES=3Dy
> CONFIG_EMBEDDED=3Dy
> CONFIG_UID16=3Dy
> CONFIG_SYSCTL_SYSCALL=3Dy
> CONFIG_KALLSYMS=3Dy
> # CONFIG_KALLSYMS_EXTRA_PASS is not set
> CONFIG_HOTPLUG=3Dy
> CONFIG_PRINTK=3Dy
> CONFIG_BUG=3Dy
> CONFIG_ELF_CORE=3Dy
> CONFIG_PCSPKR_PLATFORM=3Dy
> CONFIG_BASE_FULL=3Dy
> CONFIG_FUTEX=3Dy
> CONFIG_EPOLL=3Dy
> CONFIG_SIGNALFD=3Dy
> CONFIG_TIMERFD=3Dy
> CONFIG_EVENTFD=3Dy
> CONFIG_SHMEM=3Dy
> CONFIG_AIO=3Dy
> CONFIG_HAVE_PERF_EVENTS=3Dy
>=20
> #
> # Kernel Performance Events And Counters
> #
> CONFIG_PERF_EVENTS=3Dy
> # CONFIG_PERF_COUNTERS is not set
> CONFIG_VM_EVENT_COUNTERS=3Dy
> CONFIG_PCI_QUIRKS=3Dy
> CONFIG_SLUB_DEBUG=3Dy
> CONFIG_COMPAT_BRK=3Dy
> # CONFIG_SLAB is not set
> CONFIG_SLUB=3Dy
> # CONFIG_SLOB is not set
> CONFIG_PROFILING=3Dy
> CONFIG_TRACEPOINTS=3Dy
> CONFIG_OPROFILE=3Dy
> CONFIG_OPROFILE_EVENT_MULTIPLEX=3Dy
> CONFIG_HAVE_OPROFILE=3Dy
> # CONFIG_KPROBES is not set
> CONFIG_JUMP_LABEL=3Dy
> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=3Dy
> CONFIG_USER_RETURN_NOTIFIER=3Dy
> CONFIG_HAVE_IOREMAP_PROT=3Dy
> CONFIG_HAVE_KPROBES=3Dy
> CONFIG_HAVE_KRETPROBES=3Dy
> CONFIG_HAVE_OPTPROBES=3Dy
> CONFIG_HAVE_ARCH_TRACEHOOK=3Dy
> CONFIG_HAVE_DMA_ATTRS=3Dy
> CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=3Dy
> CONFIG_HAVE_DMA_API_DEBUG=3Dy
> CONFIG_HAVE_HW_BREAKPOINT=3Dy
> CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=3Dy
> CONFIG_HAVE_USER_RETURN_NOTIFIER=3Dy
> CONFIG_HAVE_PERF_EVENTS_NMI=3Dy
> CONFIG_HAVE_ARCH_JUMP_LABEL=3Dy
>=20
> #
> # GCOV-based kernel profiling
> #
> # CONFIG_GCOV_KERNEL is not set
> CONFIG_HAVE_GENERIC_DMA_COHERENT=3Dy
> CONFIG_SLABINFO=3Dy
> CONFIG_RT_MUTEXES=3Dy
> CONFIG_BASE_SMALL=3D0
> CONFIG_MODULES=3Dy
> CONFIG_MODULE_FORCE_LOAD=3Dy
> CONFIG_MODULE_UNLOAD=3Dy
> CONFIG_MODULE_FORCE_UNLOAD=3Dy
> # CONFIG_MODVERSIONS is not set
> # CONFIG_MODULE_SRCVERSION_ALL is not set
> CONFIG_STOP_MACHINE=3Dy
> CONFIG_BLOCK=3Dy
> CONFIG_LBDAF=3Dy
> CONFIG_BLK_DEV_BSG=3Dy
> CONFIG_BLK_DEV_INTEGRITY=3Dy
>=20
> #
> # IO Schedulers
> #
> CONFIG_IOSCHED_NOOP=3Dy
> CONFIG_IOSCHED_DEADLINE=3Dy
> CONFIG_IOSCHED_CFQ=3Dy
> # CONFIG_DEFAULT_DEADLINE is not set
> CONFIG_DEFAULT_CFQ=3Dy
> # CONFIG_DEFAULT_NOOP is not set
> CONFIG_DEFAULT_IOSCHED=3D"cfq"
> CONFIG_PREEMPT_NOTIFIERS=3Dy
> CONFIG_PADATA=3Dy
> # CONFIG_INLINE_SPIN_TRYLOCK is not set
> # CONFIG_INLINE_SPIN_TRYLOCK_BH is not set
> # CONFIG_INLINE_SPIN_LOCK is not set
> # CONFIG_INLINE_SPIN_LOCK_BH is not set
> # CONFIG_INLINE_SPIN_LOCK_IRQ is not set
> # CONFIG_INLINE_SPIN_LOCK_IRQSAVE is not set
> # CONFIG_INLINE_SPIN_UNLOCK is not set
> # CONFIG_INLINE_SPIN_UNLOCK_BH is not set
> # CONFIG_INLINE_SPIN_UNLOCK_IRQ is not set
> # CONFIG_INLINE_SPIN_UNLOCK_IRQRESTORE is not set
> # CONFIG_INLINE_READ_TRYLOCK is not set
> # CONFIG_INLINE_READ_LOCK is not set
> # CONFIG_INLINE_READ_LOCK_BH is not set
> # CONFIG_INLINE_READ_LOCK_IRQ is not set
> # CONFIG_INLINE_READ_LOCK_IRQSAVE is not set
> # CONFIG_INLINE_READ_UNLOCK is not set
> # CONFIG_INLINE_READ_UNLOCK_BH is not set
> # CONFIG_INLINE_READ_UNLOCK_IRQ is not set
> # CONFIG_INLINE_READ_UNLOCK_IRQRESTORE is not set
> # CONFIG_INLINE_WRITE_TRYLOCK is not set
> # CONFIG_INLINE_WRITE_LOCK is not set
> # CONFIG_INLINE_WRITE_LOCK_BH is not set
> # CONFIG_INLINE_WRITE_LOCK_IRQ is not set
> # CONFIG_INLINE_WRITE_LOCK_IRQSAVE is not set
> # CONFIG_INLINE_WRITE_UNLOCK is not set
> # CONFIG_INLINE_WRITE_UNLOCK_BH is not set
> # CONFIG_INLINE_WRITE_UNLOCK_IRQ is not set
> # CONFIG_INLINE_WRITE_UNLOCK_IRQRESTORE is not set
> CONFIG_MUTEX_SPIN_ON_OWNER=3Dy
> CONFIG_FREEZER=3Dy
>=20
> #
> # Processor type and features
> #
> CONFIG_TICK_ONESHOT=3Dy
> # CONFIG_NO_HZ is not set
> CONFIG_HIGH_RES_TIMERS=3Dy
> CONFIG_GENERIC_CLOCKEVENTS_BUILD=3Dy
> CONFIG_SMP=3Dy
> CONFIG_X86_MPPARSE=3Dy
> CONFIG_X86_BIGSMP=3Dy
> CONFIG_X86_EXTENDED_PLATFORM=3Dy
> CONFIG_X86_ELAN=3Dy
> # CONFIG_X86_MRST is not set
> CONFIG_X86_RDC321X=3Dy
> # CONFIG_X86_32_NON_STANDARD is not set
> CONFIG_X86_SUPPORTS_MEMORY_FAILURE=3Dy
> CONFIG_SCHED_OMIT_FRAME_POINTER=3Dy
> CONFIG_PARAVIRT_GUEST=3Dy
> # CONFIG_XEN_PRIVILEGED_GUEST is not set
> CONFIG_KVM_CLOCK=3Dy
> CONFIG_KVM_GUEST=3Dy
> CONFIG_LGUEST_GUEST=3Dy
> CONFIG_PARAVIRT=3Dy
> # CONFIG_PARAVIRT_SPINLOCKS is not set
> CONFIG_PARAVIRT_CLOCK=3Dy
> CONFIG_NO_BOOTMEM=3Dy
> CONFIG_MEMTEST=3Dy
> CONFIG_X86_CPU=3Dy
> CONFIG_X86_INTERNODE_CACHE_SHIFT=3D4
> CONFIG_X86_CMPXCHG=3Dy
> CONFIG_X86_L1_CACHE_SHIFT=3D4
> CONFIG_X86_XADD=3Dy
> CONFIG_X86_WP_WORKS_OK=3Dy
> CONFIG_X86_INVLPG=3Dy
> CONFIG_X86_BSWAP=3Dy
> CONFIG_X86_POPAD_OK=3Dy
> CONFIG_X86_ALIGNMENT_16=3Dy
> CONFIG_X86_MINIMUM_CPU_FAMILY=3D4
> CONFIG_X86_DEBUGCTLMSR=3Dy
> CONFIG_PROCESSOR_SELECT=3Dy
> CONFIG_CPU_SUP_INTEL=3Dy
> CONFIG_CPU_SUP_CYRIX_32=3Dy
> CONFIG_CPU_SUP_AMD=3Dy
> CONFIG_CPU_SUP_CENTAUR=3Dy
> CONFIG_CPU_SUP_TRANSMETA_32=3Dy
> CONFIG_CPU_SUP_UMC_32=3Dy
> CONFIG_HPET_TIMER=3Dy
> CONFIG_HPET_EMULATE_RTC=3Dy
> CONFIG_DMI=3Dy
> # CONFIG_IOMMU_HELPER is not set
> # CONFIG_IOMMU_API is not set
> CONFIG_NR_CPUS=3D32
> CONFIG_SCHED_SMT=3Dy
> CONFIG_SCHED_MC=3Dy
> # CONFIG_IRQ_TIME_ACCOUNTING is not set
> # CONFIG_PREEMPT_NONE is not set
> # CONFIG_PREEMPT_VOLUNTARY is not set
> CONFIG_PREEMPT=3Dy
> CONFIG_X86_LOCAL_APIC=3Dy
> CONFIG_X86_IO_APIC=3Dy
> CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=3Dy
> CONFIG_X86_MCE=3Dy
> CONFIG_X86_MCE_INTEL=3Dy
> CONFIG_X86_MCE_AMD=3Dy
> CONFIG_X86_ANCIENT_MCE=3Dy
> CONFIG_X86_MCE_THRESHOLD=3Dy
> CONFIG_X86_MCE_INJECT=3Dy
> CONFIG_X86_THERMAL_VECTOR=3Dy
> CONFIG_VM86=3Dy
> CONFIG_TOSHIBA=3Dy
> CONFIG_I8K=3Dy
> CONFIG_X86_REBOOTFIXUPS=3Dy
> CONFIG_MICROCODE=3Dy
> CONFIG_MICROCODE_INTEL=3Dy
> CONFIG_MICROCODE_AMD=3Dy
> CONFIG_MICROCODE_OLD_INTERFACE=3Dy
> CONFIG_X86_MSR=3Dy
> CONFIG_X86_CPUID=3Dy
> # CONFIG_NOHIGHMEM is not set
> CONFIG_HIGHMEM4G=3Dy
> # CONFIG_HIGHMEM64G is not set
> CONFIG_VMSPLIT_3G=3Dy
> # CONFIG_VMSPLIT_3G_OPT is not set
> # CONFIG_VMSPLIT_2G is not set
> # CONFIG_VMSPLIT_2G_OPT is not set
> # CONFIG_VMSPLIT_1G is not set
> CONFIG_PAGE_OFFSET=3D0xC0000000
> CONFIG_HIGHMEM=3Dy
> # CONFIG_ARCH_PHYS_ADDR_T_64BIT is not set
> # CONFIG_ARCH_DMA_ADDR_T_64BIT is not set
> CONFIG_ARCH_FLATMEM_ENABLE=3Dy
> CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy
> CONFIG_ARCH_SELECT_MEMORY_MODEL=3Dy
> CONFIG_ILLEGAL_POINTER_VALUE=3D0
> CONFIG_SELECT_MEMORY_MODEL=3Dy
> CONFIG_FLATMEM_MANUAL=3Dy
> # CONFIG_SPARSEMEM_MANUAL is not set
> CONFIG_FLATMEM=3Dy
> CONFIG_FLAT_NODE_MEM_MAP=3Dy
> CONFIG_SPARSEMEM_STATIC=3Dy
> CONFIG_HAVE_MEMBLOCK=3Dy
> CONFIG_PAGEFLAGS_EXTENDED=3Dy
> CONFIG_SPLIT_PTLOCK_CPUS=3D4
> # CONFIG_COMPACTION is not set
> # CONFIG_PHYS_ADDR_T_64BIT is not set
> CONFIG_ZONE_DMA_FLAG=3D1
> CONFIG_BOUNCE=3Dy
> CONFIG_VIRT_TO_BUS=3Dy
> CONFIG_MMU_NOTIFIER=3Dy
> CONFIG_KSM=3Dy
> CONFIG_DEFAULT_MMAP_MIN_ADDR=3D65536
> CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=3Dy
> CONFIG_MEMORY_FAILURE=3Dy
> CONFIG_HIGHPTE=3Dy
> CONFIG_X86_CHECK_BIOS_CORRUPTION=3Dy
> CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=3Dy
> CONFIG_X86_RESERVE_LOW=3D64
> CONFIG_MATH_EMULATION=3Dy
> CONFIG_MTRR=3Dy
> CONFIG_MTRR_SANITIZER=3Dy
> CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=3D0
> CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=3D1
> CONFIG_X86_PAT=3Dy
> CONFIG_ARCH_USES_PG_UNCACHED=3Dy
> CONFIG_EFI=3Dy
> CONFIG_SECCOMP=3Dy
> CONFIG_CC_STACKPROTECTOR=3Dy
> # CONFIG_HZ_100 is not set
> # CONFIG_HZ_250 is not set
> # CONFIG_HZ_300 is not set
> CONFIG_HZ_1000=3Dy
> CONFIG_HZ=3D1000
> CONFIG_SCHED_HRTICK=3Dy
> # CONFIG_KEXEC is not set
> # CONFIG_CRASH_DUMP is not set
> CONFIG_PHYSICAL_START=3D0x1000000
> # CONFIG_RELOCATABLE is not set
> CONFIG_PHYSICAL_ALIGN=3D0x100000
> CONFIG_HOTPLUG_CPU=3Dy
> CONFIG_COMPAT_VDSO=3Dy
> # CONFIG_CMDLINE_BOOL is not set
> CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=3Dy
>=20
> #
> # Power management and ACPI options
> #
> CONFIG_PM=3Dy
> # CONFIG_PM_DEBUG is not set
> CONFIG_PM_SLEEP_SMP=3Dy
> CONFIG_PM_SLEEP=3Dy
> CONFIG_SUSPEND_NVS=3Dy
> CONFIG_SUSPEND=3Dy
> CONFIG_SUSPEND_FREEZER=3Dy
> CONFIG_HIBERNATION=3Dy
> CONFIG_PM_STD_PARTITION=3D"\"\""
> CONFIG_PM_RUNTIME=3Dy
> CONFIG_PM_OPS=3Dy
> # CONFIG_PM_OPP is not set
> CONFIG_ACPI=3Dy
> CONFIG_ACPI_SLEEP=3Dy
> CONFIG_ACPI_PROCFS=3Dy
> CONFIG_ACPI_PROCFS_POWER=3Dy
> CONFIG_ACPI_POWER_METER=3Dm
> # CONFIG_ACPI_EC_DEBUGFS is not set
> CONFIG_ACPI_PROC_EVENT=3Dy
> CONFIG_ACPI_AC=3Dy
> CONFIG_ACPI_BATTERY=3Dy
> CONFIG_ACPI_BUTTON=3Dy
> CONFIG_ACPI_VIDEO=3Dy
> CONFIG_ACPI_FAN=3Dy
> CONFIG_ACPI_DOCK=3Dy
> CONFIG_ACPI_PROCESSOR=3Dy
> CONFIG_ACPI_HOTPLUG_CPU=3Dy
> CONFIG_ACPI_PROCESSOR_AGGREGATOR=3Dy
> CONFIG_ACPI_THERMAL=3Dy
> # CONFIG_ACPI_CUSTOM_DSDT is not set
> CONFIG_ACPI_BLACKLIST_YEAR=3D2001
> # CONFIG_ACPI_DEBUG is not set
> CONFIG_ACPI_PCI_SLOT=3Dy
> CONFIG_X86_PM_TIMER=3Dy
> CONFIG_ACPI_CONTAINER=3Dy
> CONFIG_ACPI_SBS=3Dy
> CONFIG_ACPI_HED=3Dy
> CONFIG_ACPI_APEI=3Dy
> CONFIG_ACPI_APEI_GHES=3Dm
> # CONFIG_ACPI_APEI_EINJ is not set
> # CONFIG_ACPI_APEI_ERST_DEBUG is not set
> CONFIG_SFI=3Dy
> CONFIG_X86_APM_BOOT=3Dy
> CONFIG_APM=3Dy
> # CONFIG_APM_IGNORE_USER_SUSPEND is not set
> # CONFIG_APM_DO_ENABLE is not set
> # CONFIG_APM_CPU_IDLE is not set
> # CONFIG_APM_DISPLAY_BLANK is not set
> # CONFIG_APM_ALLOW_INTS is not set
>=20
> #
> # CPU Frequency scaling
> #
> CONFIG_CPU_FREQ=3Dy
> CONFIG_CPU_FREQ_TABLE=3Dy
> # CONFIG_CPU_FREQ_DEBUG is not set
> CONFIG_CPU_FREQ_STAT=3Dy
> CONFIG_CPU_FREQ_STAT_DETAILS=3Dy
> CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=3Dy
> # CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
> # CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
> # CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
> # CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
> CONFIG_CPU_FREQ_GOV_PERFORMANCE=3Dy
> CONFIG_CPU_FREQ_GOV_POWERSAVE=3Dy
> CONFIG_CPU_FREQ_GOV_USERSPACE=3Dy
> CONFIG_CPU_FREQ_GOV_ONDEMAND=3Dy
> CONFIG_CPU_FREQ_GOV_CONSERVATIVE=3Dy
>=20
> #
> # CPUFreq processor drivers
> #
> CONFIG_X86_PCC_CPUFREQ=3Dy
> CONFIG_X86_ACPI_CPUFREQ=3Dy
> CONFIG_ELAN_CPUFREQ=3Dy
> CONFIG_SC520_CPUFREQ=3Dy
> CONFIG_X86_POWERNOW_K6=3Dy
> CONFIG_X86_POWERNOW_K7=3Dy
> CONFIG_X86_POWERNOW_K7_ACPI=3Dy
> CONFIG_X86_POWERNOW_K8=3Dy
> CONFIG_X86_GX_SUSPMOD=3Dy
> CONFIG_X86_SPEEDSTEP_CENTRINO=3Dy
> CONFIG_X86_SPEEDSTEP_CENTRINO_TABLE=3Dy
> CONFIG_X86_SPEEDSTEP_ICH=3Dy
> CONFIG_X86_SPEEDSTEP_SMI=3Dy
> CONFIG_X86_P4_CLOCKMOD=3Dy
> CONFIG_X86_CPUFREQ_NFORCE2=3Dy
> CONFIG_X86_LONGRUN=3Dy
> CONFIG_X86_LONGHAUL=3Dy
> CONFIG_X86_E_POWERSAVER=3Dy
>=20
> #
> # shared options
> #
> CONFIG_X86_SPEEDSTEP_LIB=3Dy
> CONFIG_X86_SPEEDSTEP_RELAXED_CAP_CHECK=3Dy
> CONFIG_CPU_IDLE=3Dy
> CONFIG_CPU_IDLE_GOV_LADDER=3Dy
> # CONFIG_INTEL_IDLE is not set
>=20
> #
> # Bus options (PCI etc.)
> #
> CONFIG_PCI=3Dy
> # CONFIG_PCI_GOBIOS is not set
> # CONFIG_PCI_GOMMCONFIG is not set
> # CONFIG_PCI_GODIRECT is not set
> # CONFIG_PCI_GOOLPC is not set
> CONFIG_PCI_GOANY=3Dy
> CONFIG_PCI_BIOS=3Dy
> CONFIG_PCI_DIRECT=3Dy
> CONFIG_PCI_MMCONFIG=3Dy
> CONFIG_PCI_OLPC=3Dy
> CONFIG_PCI_DOMAINS=3Dy
> CONFIG_PCI_CNB20LE_QUIRK=3Dy
> CONFIG_PCIEPORTBUS=3Dy
> CONFIG_HOTPLUG_PCI_PCIE=3Dy
> CONFIG_PCIEAER=3Dy
> CONFIG_PCIE_ECRC=3Dy
> CONFIG_PCIEAER_INJECT=3Dy
> CONFIG_PCIEASPM=3Dy
> CONFIG_PCIEASPM_DEBUG=3Dy
> CONFIG_PCIE_PME=3Dy
> CONFIG_ARCH_SUPPORTS_MSI=3Dy
> # CONFIG_PCI_MSI is not set
> # CONFIG_PCI_STUB is not set
> CONFIG_HT_IRQ=3Dy
> CONFIG_PCI_IOV=3Dy
> CONFIG_PCI_IOAPIC=3Dy
> CONFIG_ISA_DMA_API=3Dy
> CONFIG_ISA=3Dy
> CONFIG_EISA=3Dy
> CONFIG_EISA_VLB_PRIMING=3Dy
> CONFIG_EISA_PCI_EISA=3Dy
> CONFIG_EISA_VIRTUAL_ROOT=3Dy
> CONFIG_EISA_NAMES=3Dy
> CONFIG_MCA=3Dy
> CONFIG_MCA_LEGACY=3Dy
> CONFIG_MCA_PROC_FS=3Dy
> CONFIG_SCx200=3Dy
> CONFIG_SCx200HR_TIMER=3Dy
> CONFIG_OLPC=3Dy
> CONFIG_OLPC_XO1=3Dm
> CONFIG_OLPC_OPENFIRMWARE=3Dy
> CONFIG_AMD_NB=3Dy
> CONFIG_PCCARD=3Dy
> CONFIG_PCMCIA=3Dy
> CONFIG_PCMCIA_LOAD_CIS=3Dy
> CONFIG_CARDBUS=3Dy
>=20
> #
> # PC-card bridges
> #
> CONFIG_YENTA=3Dy
> CONFIG_YENTA_O2=3Dy
> CONFIG_YENTA_RICOH=3Dy
> CONFIG_YENTA_TI=3Dy
> CONFIG_YENTA_ENE_TUNE=3Dy
> CONFIG_YENTA_TOSHIBA=3Dy
> CONFIG_PD6729=3Dy
> CONFIG_I82092=3Dy
> CONFIG_I82365=3Dy
> CONFIG_TCIC=3Dy
> CONFIG_PCMCIA_PROBE=3Dy
> CONFIG_PCCARD_NONSTATIC=3Dy
> CONFIG_HOTPLUG_PCI=3Dy
> # CONFIG_HOTPLUG_PCI_FAKE is not set
> CONFIG_HOTPLUG_PCI_COMPAQ=3Dy
> # CONFIG_HOTPLUG_PCI_COMPAQ_NVRAM is not set
> CONFIG_HOTPLUG_PCI_IBM=3Dy
> CONFIG_HOTPLUG_PCI_ACPI=3Dy
> CONFIG_HOTPLUG_PCI_ACPI_IBM=3Dy
> CONFIG_HOTPLUG_PCI_CPCI=3Dy
> CONFIG_HOTPLUG_PCI_CPCI_ZT5550=3Dy
> CONFIG_HOTPLUG_PCI_CPCI_GENERIC=3Dy
> CONFIG_HOTPLUG_PCI_SHPC=3Dy
>=20
> #
> # Executable file formats / Emulations
> #
> CONFIG_BINFMT_ELF=3Dy
> # CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
> CONFIG_HAVE_AOUT=3Dy
> CONFIG_BINFMT_AOUT=3Dy
> CONFIG_BINFMT_MISC=3Dy
> CONFIG_HAVE_ATOMIC_IOMAP=3Dy
> CONFIG_HAVE_TEXT_POKE_SMP=3Dy
> CONFIG_NET=3Dy
>=20
> #
> # Networking options
> #
> CONFIG_PACKET=3Dy
> CONFIG_UNIX=3Dy
> CONFIG_XFRM=3Dy
> CONFIG_XFRM_USER=3Dy
> CONFIG_XFRM_SUB_POLICY=3Dy
> CONFIG_XFRM_MIGRATE=3Dy
> CONFIG_XFRM_STATISTICS=3Dy
> CONFIG_XFRM_IPCOMP=3Dm
> CONFIG_NET_KEY=3Dm
> CONFIG_NET_KEY_MIGRATE=3Dy
> CONFIG_INET=3Dy
> CONFIG_IP_MULTICAST=3Dy
> CONFIG_IP_ADVANCED_ROUTER=3Dy
> CONFIG_ASK_IP_FIB_HASH=3Dy
> # CONFIG_IP_FIB_TRIE is not set
> CONFIG_IP_FIB_HASH=3Dy
> CONFIG_IP_MULTIPLE_TABLES=3Dy
> CONFIG_IP_ROUTE_MULTIPATH=3Dy
> CONFIG_IP_ROUTE_VERBOSE=3Dy
> CONFIG_IP_PNP=3Dy
> CONFIG_IP_PNP_DHCP=3Dy
> CONFIG_IP_PNP_BOOTP=3Dy
> CONFIG_IP_PNP_RARP=3Dy
> CONFIG_NET_IPIP=3Dm
> CONFIG_NET_IPGRE_DEMUX=3Dm
> CONFIG_NET_IPGRE=3Dm
> CONFIG_NET_IPGRE_BROADCAST=3Dy
> CONFIG_IP_MROUTE=3Dy
> CONFIG_IP_MROUTE_MULTIPLE_TABLES=3Dy
> CONFIG_IP_PIMSM_V1=3Dy
> CONFIG_IP_PIMSM_V2=3Dy
> CONFIG_ARPD=3Dy
> CONFIG_SYN_COOKIES=3Dy
> CONFIG_INET_AH=3Dm
> CONFIG_INET_ESP=3Dm
> CONFIG_INET_IPCOMP=3Dm
> CONFIG_INET_XFRM_TUNNEL=3Dm
> CONFIG_INET_TUNNEL=3Dm
> CONFIG_INET_XFRM_MODE_TRANSPORT=3Dm
> CONFIG_INET_XFRM_MODE_TUNNEL=3Dm
> CONFIG_INET_XFRM_MODE_BEET=3Dm
> CONFIG_INET_LRO=3Dy
> CONFIG_INET_DIAG=3Dm
> CONFIG_INET_TCP_DIAG=3Dm
> CONFIG_TCP_CONG_ADVANCED=3Dy
> CONFIG_TCP_CONG_BIC=3Dm
> CONFIG_TCP_CONG_CUBIC=3Dy
> CONFIG_TCP_CONG_WESTWOOD=3Dm
> CONFIG_TCP_CONG_HTCP=3Dm
> CONFIG_TCP_CONG_HSTCP=3Dm
> CONFIG_TCP_CONG_HYBLA=3Dm
> CONFIG_TCP_CONG_VEGAS=3Dm
> CONFIG_TCP_CONG_SCALABLE=3Dm
> CONFIG_TCP_CONG_LP=3Dm
> CONFIG_TCP_CONG_VENO=3Dm
> CONFIG_TCP_CONG_YEAH=3Dm
> CONFIG_TCP_CONG_ILLINOIS=3Dm
> CONFIG_DEFAULT_CUBIC=3Dy
> # CONFIG_DEFAULT_RENO is not set
> CONFIG_DEFAULT_TCP_CONG=3D"cubic"
> CONFIG_TCP_MD5SIG=3Dy
> CONFIG_IPV6=3Dm
> CONFIG_IPV6_PRIVACY=3Dy
> CONFIG_IPV6_ROUTER_PREF=3Dy
> CONFIG_IPV6_ROUTE_INFO=3Dy
> CONFIG_IPV6_OPTIMISTIC_DAD=3Dy
> CONFIG_INET6_AH=3Dm
> CONFIG_INET6_ESP=3Dm
> CONFIG_INET6_IPCOMP=3Dm
> CONFIG_IPV6_MIP6=3Dm
> CONFIG_INET6_XFRM_TUNNEL=3Dm
> CONFIG_INET6_TUNNEL=3Dm
> CONFIG_INET6_XFRM_MODE_TRANSPORT=3Dm
> CONFIG_INET6_XFRM_MODE_TUNNEL=3Dm
> CONFIG_INET6_XFRM_MODE_BEET=3Dm
> CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=3Dm
> CONFIG_IPV6_SIT=3Dm
> CONFIG_IPV6_SIT_6RD=3Dy
> CONFIG_IPV6_NDISC_NODETYPE=3Dy
> CONFIG_IPV6_TUNNEL=3Dm
> CONFIG_IPV6_MULTIPLE_TABLES=3Dy
> CONFIG_IPV6_SUBTREES=3Dy
> CONFIG_IPV6_MROUTE=3Dy
> CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=3Dy
> CONFIG_IPV6_PIMSM_V2=3Dy
> CONFIG_NETLABEL=3Dy
> # CONFIG_NETWORK_SECMARK is not set
> # CONFIG_NETWORK_PHY_TIMESTAMPING is not set
> CONFIG_NETFILTER=3Dy
> # CONFIG_NETFILTER_DEBUG is not set
> CONFIG_NETFILTER_ADVANCED=3Dy
> CONFIG_BRIDGE_NETFILTER=3Dy
>=20
> #
> # Core Netfilter Configuration
> #
> CONFIG_NETFILTER_NETLINK=3Dm
> CONFIG_NETFILTER_NETLINK_QUEUE=3Dm
> CONFIG_NETFILTER_NETLINK_LOG=3Dm
> CONFIG_NF_CONNTRACK=3Dm
> CONFIG_NF_CONNTRACK_MARK=3Dy
> # CONFIG_NF_CONNTRACK_ZONES is not set
> # CONFIG_NF_CONNTRACK_EVENTS is not set
> CONFIG_NF_CT_PROTO_DCCP=3Dm
> CONFIG_NF_CT_PROTO_GRE=3Dm
> CONFIG_NF_CT_PROTO_SCTP=3Dm
> CONFIG_NF_CT_PROTO_UDPLITE=3Dm
> CONFIG_NF_CONNTRACK_AMANDA=3Dm
> CONFIG_NF_CONNTRACK_FTP=3Dm
> CONFIG_NF_CONNTRACK_H323=3Dm
> CONFIG_NF_CONNTRACK_IRC=3Dm
> CONFIG_NF_CONNTRACK_NETBIOS_NS=3Dm
> CONFIG_NF_CONNTRACK_PPTP=3Dm
> CONFIG_NF_CONNTRACK_SANE=3Dm
> CONFIG_NF_CONNTRACK_SIP=3Dm
> CONFIG_NF_CONNTRACK_TFTP=3Dm
> CONFIG_NF_CT_NETLINK=3Dm
> CONFIG_NETFILTER_TPROXY=3Dm
> CONFIG_NETFILTER_XTABLES=3Dm
>=20
> #
> # Xtables combined modules
> #
> CONFIG_NETFILTER_XT_MARK=3Dm
> CONFIG_NETFILTER_XT_CONNMARK=3Dm
>=20
> #
> # Xtables targets
> #
> CONFIG_NETFILTER_XT_TARGET_CHECKSUM=3Dm
> CONFIG_NETFILTER_XT_TARGET_CLASSIFY=3Dm
> CONFIG_NETFILTER_XT_TARGET_CONNMARK=3Dm
> CONFIG_NETFILTER_XT_TARGET_CT=3Dm
> CONFIG_NETFILTER_XT_TARGET_DSCP=3Dm
> CONFIG_NETFILTER_XT_TARGET_HL=3Dm
> CONFIG_NETFILTER_XT_TARGET_IDLETIMER=3Dm
> CONFIG_NETFILTER_XT_TARGET_LED=3Dm
> CONFIG_NETFILTER_XT_TARGET_MARK=3Dm
> CONFIG_NETFILTER_XT_TARGET_NFLOG=3Dm
> CONFIG_NETFILTER_XT_TARGET_NFQUEUE=3Dm
> CONFIG_NETFILTER_XT_TARGET_NOTRACK=3Dm
> CONFIG_NETFILTER_XT_TARGET_RATEEST=3Dm
> CONFIG_NETFILTER_XT_TARGET_TEE=3Dm
> CONFIG_NETFILTER_XT_TARGET_TPROXY=3Dm
> CONFIG_NETFILTER_XT_TARGET_TRACE=3Dm
> CONFIG_NETFILTER_XT_TARGET_TCPMSS=3Dm
> CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=3Dm
>=20
> #
> # Xtables matches
> #
> CONFIG_NETFILTER_XT_MATCH_CLUSTER=3Dm
> CONFIG_NETFILTER_XT_MATCH_COMMENT=3Dm
> CONFIG_NETFILTER_XT_MATCH_CONNBYTES=3Dm
> CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=3Dm
> CONFIG_NETFILTER_XT_MATCH_CONNMARK=3Dm
> CONFIG_NETFILTER_XT_MATCH_CONNTRACK=3Dm
> CONFIG_NETFILTER_XT_MATCH_CPU=3Dm
> CONFIG_NETFILTER_XT_MATCH_DCCP=3Dm
> CONFIG_NETFILTER_XT_MATCH_DSCP=3Dm
> CONFIG_NETFILTER_XT_MATCH_ESP=3Dm
> CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=3Dm
> CONFIG_NETFILTER_XT_MATCH_HELPER=3Dm
> CONFIG_NETFILTER_XT_MATCH_HL=3Dm
> CONFIG_NETFILTER_XT_MATCH_IPRANGE=3Dm
> CONFIG_NETFILTER_XT_MATCH_IPVS=3Dm
> CONFIG_NETFILTER_XT_MATCH_LENGTH=3Dm
> CONFIG_NETFILTER_XT_MATCH_LIMIT=3Dm
> CONFIG_NETFILTER_XT_MATCH_MAC=3Dm
> CONFIG_NETFILTER_XT_MATCH_MARK=3Dm
> CONFIG_NETFILTER_XT_MATCH_MULTIPORT=3Dm
> CONFIG_NETFILTER_XT_MATCH_OSF=3Dm
> CONFIG_NETFILTER_XT_MATCH_OWNER=3Dm
> CONFIG_NETFILTER_XT_MATCH_POLICY=3Dm
> CONFIG_NETFILTER_XT_MATCH_PHYSDEV=3Dm
> CONFIG_NETFILTER_XT_MATCH_PKTTYPE=3Dm
> CONFIG_NETFILTER_XT_MATCH_QUOTA=3Dm
> CONFIG_NETFILTER_XT_MATCH_RATEEST=3Dm
> CONFIG_NETFILTER_XT_MATCH_REALM=3Dm
> CONFIG_NETFILTER_XT_MATCH_RECENT=3Dm
> CONFIG_NETFILTER_XT_MATCH_SCTP=3Dm
> CONFIG_NETFILTER_XT_MATCH_SOCKET=3Dm
> CONFIG_NETFILTER_XT_MATCH_STATE=3Dm
> CONFIG_NETFILTER_XT_MATCH_STATISTIC=3Dm
> CONFIG_NETFILTER_XT_MATCH_STRING=3Dm
> CONFIG_NETFILTER_XT_MATCH_TCPMSS=3Dm
> CONFIG_NETFILTER_XT_MATCH_TIME=3Dm
> CONFIG_NETFILTER_XT_MATCH_U32=3Dm
> CONFIG_IP_VS=3Dm
> CONFIG_IP_VS_IPV6=3Dy
> # CONFIG_IP_VS_DEBUG is not set
> CONFIG_IP_VS_TAB_BITS=3D12
>=20
> #
> # IPVS transport protocol load balancing support
> #
> CONFIG_IP_VS_PROTO_TCP=3Dy
> CONFIG_IP_VS_PROTO_UDP=3Dy
> CONFIG_IP_VS_PROTO_AH_ESP=3Dy
> CONFIG_IP_VS_PROTO_ESP=3Dy
> CONFIG_IP_VS_PROTO_AH=3Dy
> CONFIG_IP_VS_PROTO_SCTP=3Dy
>=20
> #
> # IPVS scheduler
> #
> CONFIG_IP_VS_RR=3Dm
> CONFIG_IP_VS_WRR=3Dm
> CONFIG_IP_VS_LC=3Dm
> CONFIG_IP_VS_WLC=3Dm
> CONFIG_IP_VS_LBLC=3Dm
> CONFIG_IP_VS_LBLCR=3Dm
> CONFIG_IP_VS_DH=3Dm
> CONFIG_IP_VS_SH=3Dm
> CONFIG_IP_VS_SED=3Dm
> CONFIG_IP_VS_NQ=3Dm
>=20
> #
> # IPVS application helper
> #
> CONFIG_IP_VS_FTP=3Dm
> CONFIG_IP_VS_NFCT=3Dy
> CONFIG_IP_VS_PE_SIP=3Dm
>=20
> #
> # IP: Netfilter Configuration
> #
> CONFIG_NF_DEFRAG_IPV4=3Dm
> CONFIG_NF_CONNTRACK_IPV4=3Dm
> CONFIG_NF_CONNTRACK_PROC_COMPAT=3Dy
> CONFIG_IP_NF_QUEUE=3Dm
> CONFIG_IP_NF_IPTABLES=3Dm
> CONFIG_IP_NF_MATCH_ADDRTYPE=3Dm
> CONFIG_IP_NF_MATCH_AH=3Dm
> CONFIG_IP_NF_MATCH_ECN=3Dm
> CONFIG_IP_NF_MATCH_TTL=3Dm
> CONFIG_IP_NF_FILTER=3Dm
> CONFIG_IP_NF_TARGET_REJECT=3Dm
> CONFIG_IP_NF_TARGET_LOG=3Dm
> CONFIG_IP_NF_TARGET_ULOG=3Dm
> CONFIG_NF_NAT=3Dm
> CONFIG_NF_NAT_NEEDED=3Dy
> CONFIG_IP_NF_TARGET_MASQUERADE=3Dm
> CONFIG_IP_NF_TARGET_NETMAP=3Dm
> CONFIG_IP_NF_TARGET_REDIRECT=3Dm
> CONFIG_NF_NAT_SNMP_BASIC=3Dm
> CONFIG_NF_NAT_PROTO_DCCP=3Dm
> CONFIG_NF_NAT_PROTO_GRE=3Dm
> CONFIG_NF_NAT_PROTO_UDPLITE=3Dm
> CONFIG_NF_NAT_PROTO_SCTP=3Dm
> CONFIG_NF_NAT_FTP=3Dm
> CONFIG_NF_NAT_IRC=3Dm
> CONFIG_NF_NAT_TFTP=3Dm
> CONFIG_NF_NAT_AMANDA=3Dm
> CONFIG_NF_NAT_PPTP=3Dm
> CONFIG_NF_NAT_H323=3Dm
> CONFIG_NF_NAT_SIP=3Dm
> CONFIG_IP_NF_MANGLE=3Dm
> CONFIG_IP_NF_TARGET_CLUSTERIP=3Dm
> CONFIG_IP_NF_TARGET_ECN=3Dm
> CONFIG_IP_NF_TARGET_TTL=3Dm
> CONFIG_IP_NF_RAW=3Dm
> CONFIG_IP_NF_SECURITY=3Dm
> CONFIG_IP_NF_ARPTABLES=3Dm
> CONFIG_IP_NF_ARPFILTER=3Dm
> CONFIG_IP_NF_ARP_MANGLE=3Dm
>=20
> #
> # IPv6: Netfilter Configuration
> #
> CONFIG_NF_DEFRAG_IPV6=3Dm
> CONFIG_NF_CONNTRACK_IPV6=3Dm
> CONFIG_IP6_NF_QUEUE=3Dm
> CONFIG_IP6_NF_IPTABLES=3Dm
> CONFIG_IP6_NF_MATCH_AH=3Dm
> CONFIG_IP6_NF_MATCH_EUI64=3Dm
> CONFIG_IP6_NF_MATCH_FRAG=3Dm
> CONFIG_IP6_NF_MATCH_OPTS=3Dm
> CONFIG_IP6_NF_MATCH_HL=3Dm
> CONFIG_IP6_NF_MATCH_IPV6HEADER=3Dm
> CONFIG_IP6_NF_MATCH_MH=3Dm
> CONFIG_IP6_NF_MATCH_RT=3Dm
> CONFIG_IP6_NF_TARGET_HL=3Dm
> CONFIG_IP6_NF_TARGET_LOG=3Dm
> CONFIG_IP6_NF_FILTER=3Dm
> CONFIG_IP6_NF_TARGET_REJECT=3Dm
> CONFIG_IP6_NF_MANGLE=3Dm
> CONFIG_IP6_NF_RAW=3Dm
> CONFIG_IP6_NF_SECURITY=3Dm
>=20
> #
> # DECnet: Netfilter Configuration
> #
> CONFIG_DECNET_NF_GRABULATOR=3Dm
> CONFIG_BRIDGE_NF_EBTABLES=3Dm
> CONFIG_BRIDGE_EBT_BROUTE=3Dm
> CONFIG_BRIDGE_EBT_T_FILTER=3Dm
> CONFIG_BRIDGE_EBT_T_NAT=3Dm
> CONFIG_BRIDGE_EBT_802_3=3Dm
> CONFIG_BRIDGE_EBT_AMONG=3Dm
> CONFIG_BRIDGE_EBT_ARP=3Dm
> CONFIG_BRIDGE_EBT_IP=3Dm
> CONFIG_BRIDGE_EBT_IP6=3Dm
> CONFIG_BRIDGE_EBT_LIMIT=3Dm
> CONFIG_BRIDGE_EBT_MARK=3Dm
> CONFIG_BRIDGE_EBT_PKTTYPE=3Dm
> CONFIG_BRIDGE_EBT_STP=3Dm
> CONFIG_BRIDGE_EBT_VLAN=3Dm
> CONFIG_BRIDGE_EBT_ARPREPLY=3Dm
> CONFIG_BRIDGE_EBT_DNAT=3Dm
> CONFIG_BRIDGE_EBT_MARK_T=3Dm
> CONFIG_BRIDGE_EBT_REDIRECT=3Dm
> CONFIG_BRIDGE_EBT_SNAT=3Dm
> CONFIG_BRIDGE_EBT_LOG=3Dm
> CONFIG_BRIDGE_EBT_ULOG=3Dm
> CONFIG_BRIDGE_EBT_NFLOG=3Dm
> CONFIG_IP_DCCP=3Dm
> CONFIG_INET_DCCP_DIAG=3Dm
>=20
> #
> # DCCP CCIDs Configuration (EXPERIMENTAL)
> #
> # CONFIG_IP_DCCP_CCID2_DEBUG is not set
> CONFIG_IP_DCCP_CCID3=3Dy
> # CONFIG_IP_DCCP_CCID3_DEBUG is not set
> CONFIG_IP_DCCP_TFRC_LIB=3Dy
> CONFIG_IP_SCTP=3Dm
> # CONFIG_SCTP_DBG_MSG is not set
> # CONFIG_SCTP_DBG_OBJCNT is not set
> # CONFIG_SCTP_HMAC_NONE is not set
> # CONFIG_SCTP_HMAC_SHA1 is not set
> CONFIG_SCTP_HMAC_MD5=3Dy
> CONFIG_RDS=3Dm
> CONFIG_RDS_RDMA=3Dm
> CONFIG_RDS_TCP=3Dm
> # CONFIG_RDS_DEBUG is not set
> CONFIG_TIPC=3Dm
> CONFIG_TIPC_ADVANCED=3Dy
> CONFIG_TIPC_ZONES=3D3
> CONFIG_TIPC_CLUSTERS=3D1
> CONFIG_TIPC_NODES=3D255
> CONFIG_TIPC_PORTS=3D8191
> CONFIG_TIPC_LOG=3D0
> # CONFIG_TIPC_DEBUG is not set
> CONFIG_ATM=3Dm
> CONFIG_ATM_CLIP=3Dm
> # CONFIG_ATM_CLIP_NO_ICMP is not set
> CONFIG_ATM_LANE=3Dm
> CONFIG_ATM_MPOA=3Dm
> CONFIG_ATM_BR2684=3Dm
> # CONFIG_ATM_BR2684_IPFILTER is not set
> CONFIG_L2TP=3Dm
> # CONFIG_L2TP_DEBUGFS is not set
> CONFIG_L2TP_V3=3Dy
> CONFIG_L2TP_IP=3Dm
> CONFIG_L2TP_ETH=3Dm
> CONFIG_STP=3Dm
> CONFIG_GARP=3Dm
> CONFIG_BRIDGE=3Dm
> CONFIG_BRIDGE_IGMP_SNOOPING=3Dy
> CONFIG_NET_DSA=3Dy
> CONFIG_NET_DSA_TAG_DSA=3Dy
> CONFIG_NET_DSA_TAG_EDSA=3Dy
> CONFIG_NET_DSA_TAG_TRAILER=3Dy
> CONFIG_NET_DSA_MV88E6XXX=3Dy
> CONFIG_NET_DSA_MV88E6060=3Dy
> CONFIG_NET_DSA_MV88E6XXX_NEED_PPU=3Dy
> CONFIG_NET_DSA_MV88E6131=3Dy
> CONFIG_NET_DSA_MV88E6123_61_65=3Dy
> CONFIG_VLAN_8021Q=3Dm
> CONFIG_VLAN_8021Q_GVRP=3Dy
> CONFIG_DECNET=3Dm
> CONFIG_DECNET_ROUTER=3Dy
> CONFIG_LLC=3Dy
> CONFIG_LLC2=3Dm
> CONFIG_IPX=3Dm
> CONFIG_IPX_INTERN=3Dy
> CONFIG_ATALK=3Dm
> CONFIG_DEV_APPLETALK=3Dm
> CONFIG_LTPC=3Dm
> CONFIG_COPS=3Dm
> CONFIG_COPS_DAYNA=3Dy
> CONFIG_COPS_TANGENT=3Dy
> CONFIG_IPDDP=3Dm
> CONFIG_IPDDP_ENCAP=3Dy
> CONFIG_IPDDP_DECAP=3Dy
> CONFIG_X25=3Dm
> CONFIG_LAPB=3Dm
> CONFIG_ECONET=3Dm
> CONFIG_ECONET_AUNUDP=3Dy
> CONFIG_ECONET_NATIVE=3Dy
> CONFIG_WAN_ROUTER=3Dm
> CONFIG_PHONET=3Dm
> CONFIG_PHONET_PIPECTRLR=3Dy
> CONFIG_IEEE802154=3Dm
> CONFIG_NET_SCHED=3Dy
>=20
> #
> # Queueing/Scheduling
> #
> CONFIG_NET_SCH_CBQ=3Dm
> CONFIG_NET_SCH_HTB=3Dm
> CONFIG_NET_SCH_HFSC=3Dm
> CONFIG_NET_SCH_ATM=3Dm
> CONFIG_NET_SCH_PRIO=3Dm
> CONFIG_NET_SCH_MULTIQ=3Dm
> CONFIG_NET_SCH_RED=3Dm
> CONFIG_NET_SCH_SFQ=3Dm
> CONFIG_NET_SCH_TEQL=3Dm
> CONFIG_NET_SCH_TBF=3Dm
> CONFIG_NET_SCH_GRED=3Dm
> CONFIG_NET_SCH_DSMARK=3Dm
> CONFIG_NET_SCH_NETEM=3Dm
> CONFIG_NET_SCH_DRR=3Dm
> CONFIG_NET_SCH_INGRESS=3Dm
>=20
> #
> # Classification
> #
> CONFIG_NET_CLS=3Dy
> CONFIG_NET_CLS_BASIC=3Dm
> CONFIG_NET_CLS_TCINDEX=3Dm
> CONFIG_NET_CLS_ROUTE4=3Dm
> CONFIG_NET_CLS_ROUTE=3Dy
> CONFIG_NET_CLS_FW=3Dm
> CONFIG_NET_CLS_U32=3Dm
> CONFIG_CLS_U32_PERF=3Dy
> CONFIG_CLS_U32_MARK=3Dy
> CONFIG_NET_CLS_RSVP=3Dm
> CONFIG_NET_CLS_RSVP6=3Dm
> CONFIG_NET_CLS_FLOW=3Dm
> # CONFIG_NET_EMATCH is not set
> CONFIG_NET_CLS_ACT=3Dy
> CONFIG_NET_ACT_POLICE=3Dy
> CONFIG_NET_ACT_GACT=3Dm
> CONFIG_GACT_PROB=3Dy
> CONFIG_NET_ACT_MIRRED=3Dm
> CONFIG_NET_ACT_IPT=3Dm
> CONFIG_NET_ACT_NAT=3Dm
> CONFIG_NET_ACT_PEDIT=3Dm
> CONFIG_NET_ACT_SIMP=3Dm
> CONFIG_NET_ACT_SKBEDIT=3Dm
> CONFIG_NET_ACT_CSUM=3Dm
> CONFIG_NET_CLS_IND=3Dy
> CONFIG_NET_SCH_FIFO=3Dy
> CONFIG_DCB=3Dy
> CONFIG_DNS_RESOLVER=3Dy
> CONFIG_RPS=3Dy
>=20
> #
> # Network testing
> #
> # CONFIG_NET_PKTGEN is not set
> # CONFIG_NET_DROP_MONITOR is not set
> CONFIG_HAMRADIO=3Dy
>=20
> #
> # Packet Radio protocols
> #
> CONFIG_AX25=3Dm
> CONFIG_AX25_DAMA_SLAVE=3Dy
> CONFIG_NETROM=3Dm
> CONFIG_ROSE=3Dm
>=20
> #
> # AX.25 network device drivers
> #
> CONFIG_MKISS=3Dm
> CONFIG_6PACK=3Dm
> CONFIG_BPQETHER=3Dm
> CONFIG_SCC=3Dm
> CONFIG_SCC_DELAY=3Dy
> CONFIG_SCC_TRXECHO=3Dy
> CONFIG_BAYCOM_SER_FDX=3Dm
> CONFIG_BAYCOM_SER_HDX=3Dm
> CONFIG_BAYCOM_PAR=3Dm
> CONFIG_BAYCOM_EPP=3Dm
> CONFIG_YAM=3Dm
> CONFIG_CAN=3Dm
> CONFIG_CAN_RAW=3Dm
> CONFIG_CAN_BCM=3Dm
>=20
> #
> # CAN Device Drivers
> #
> CONFIG_CAN_VCAN=3Dm
> CONFIG_CAN_DEV=3Dm
> CONFIG_CAN_CALC_BITTIMING=3Dy
> CONFIG_CAN_MCP251X=3Dm
> CONFIG_CAN_JANZ_ICAN3=3Dm
> CONFIG_PCH_CAN=3Dm
> CONFIG_CAN_SJA1000=3Dm
> CONFIG_CAN_SJA1000_ISA=3Dm
> CONFIG_CAN_SJA1000_PLATFORM=3Dm
> CONFIG_CAN_EMS_PCI=3Dm
> CONFIG_CAN_KVASER_PCI=3Dm
> CONFIG_CAN_PLX_PCI=3Dm
> CONFIG_CAN_TSCAN1=3Dm
>=20
> #
> # CAN USB interfaces
> #
> CONFIG_CAN_EMS_USB=3Dm
> CONFIG_CAN_ESD_USB2=3Dm
> # CONFIG_CAN_DEBUG_DEVICES is not set
> CONFIG_IRDA=3Dm
>=20
> #
> # IrDA protocols
> #
> CONFIG_IRLAN=3Dm
> CONFIG_IRNET=3Dm
> CONFIG_IRCOMM=3Dm
> CONFIG_IRDA_ULTRA=3Dy
>=20
> #
> # IrDA options
> #
> CONFIG_IRDA_CACHE_LAST_LSAP=3Dy
> CONFIG_IRDA_FAST_RR=3Dy
> # CONFIG_IRDA_DEBUG is not set
>=20
> #
> # Infrared-port device drivers
> #
>=20
> #
> # SIR device drivers
> #
> CONFIG_IRTTY_SIR=3Dm
>=20
> #
> # Dongle support
> #
> CONFIG_DONGLE=3Dy
> CONFIG_ESI_DONGLE=3Dm
> CONFIG_ACTISYS_DONGLE=3Dm
> CONFIG_TEKRAM_DONGLE=3Dm
> CONFIG_TOIM3232_DONGLE=3Dm
> CONFIG_LITELINK_DONGLE=3Dm
> CONFIG_MA600_DONGLE=3Dm
> CONFIG_GIRBIL_DONGLE=3Dm
> CONFIG_MCP2120_DONGLE=3Dm
> CONFIG_OLD_BELKIN_DONGLE=3Dm
> CONFIG_ACT200L_DONGLE=3Dm
> CONFIG_KINGSUN_DONGLE=3Dm
> CONFIG_KSDAZZLE_DONGLE=3Dm
> CONFIG_KS959_DONGLE=3Dm
>=20
> #
> # FIR device drivers
> #
> CONFIG_USB_IRDA=3Dm
> CONFIG_SIGMATEL_FIR=3Dm
> CONFIG_NSC_FIR=3Dm
> CONFIG_WINBOND_FIR=3Dm
> CONFIG_TOSHIBA_FIR=3Dm
> CONFIG_SMC_IRCC_FIR=3Dm
> CONFIG_ALI_FIR=3Dm
> CONFIG_VLSI_FIR=3Dm
> CONFIG_VIA_FIR=3Dm
> CONFIG_MCS_FIR=3Dm
> CONFIG_BT=3Dm
> CONFIG_BT_L2CAP=3Dm
> CONFIG_BT_SCO=3Dm
> CONFIG_BT_RFCOMM=3Dm
> CONFIG_BT_RFCOMM_TTY=3Dy
> CONFIG_BT_BNEP=3Dm
> CONFIG_BT_BNEP_MC_FILTER=3Dy
> CONFIG_BT_BNEP_PROTO_FILTER=3Dy
> CONFIG_BT_CMTP=3Dm
> CONFIG_BT_HIDP=3Dm
>=20
> #
> # Bluetooth device drivers
> #
> CONFIG_BT_HCIBTUSB=3Dm
> CONFIG_BT_HCIBTSDIO=3Dm
> CONFIG_BT_HCIUART=3Dm
> CONFIG_BT_HCIUART_H4=3Dy
> CONFIG_BT_HCIUART_BCSP=3Dy
> CONFIG_BT_HCIUART_ATH3K=3Dy
> CONFIG_BT_HCIUART_LL=3Dy
> CONFIG_BT_HCIBCM203X=3Dm
> CONFIG_BT_HCIBPA10X=3Dm
> CONFIG_BT_HCIBFUSB=3Dm
> CONFIG_BT_HCIDTL1=3Dm
> CONFIG_BT_HCIBT3C=3Dm
> CONFIG_BT_HCIBLUECARD=3Dm
> CONFIG_BT_HCIBTUART=3Dm
> CONFIG_BT_HCIVHCI=3Dm
> CONFIG_BT_MRVL=3Dm
> CONFIG_BT_MRVL_SDIO=3Dm
> # CONFIG_BT_ATH3K is not set
> CONFIG_AF_RXRPC=3Dy
> # CONFIG_AF_RXRPC_DEBUG is not set
> CONFIG_RXKAD=3Dm
> CONFIG_FIB_RULES=3Dy
> CONFIG_WIRELESS=3Dy
> CONFIG_WIRELESS_EXT=3Dy
> CONFIG_WEXT_CORE=3Dy
> CONFIG_WEXT_PROC=3Dy
> CONFIG_WEXT_SPY=3Dy
> CONFIG_WEXT_PRIV=3Dy
> CONFIG_CFG80211=3Dm
> # CONFIG_NL80211_TESTMODE is not set
> # CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
> # CONFIG_CFG80211_REG_DEBUG is not set
> CONFIG_CFG80211_DEFAULT_PS=3Dy
> # CONFIG_CFG80211_DEBUGFS is not set
> # CONFIG_CFG80211_INTERNAL_REGDB is not set
> CONFIG_CFG80211_WEXT=3Dy
> CONFIG_WIRELESS_EXT_SYSFS=3Dy
> CONFIG_LIB80211=3Dy
> CONFIG_LIB80211_CRYPT_WEP=3Dy
> CONFIG_LIB80211_CRYPT_CCMP=3Dy
> CONFIG_LIB80211_CRYPT_TKIP=3Dy
> # CONFIG_LIB80211_DEBUG is not set
> CONFIG_MAC80211=3Dm
> CONFIG_MAC80211_HAS_RC=3Dy
> CONFIG_MAC80211_RC_PID=3Dy
> CONFIG_MAC80211_RC_MINSTREL=3Dy
> CONFIG_MAC80211_RC_MINSTREL_HT=3Dy
> # CONFIG_MAC80211_RC_DEFAULT_PID is not set
> CONFIG_MAC80211_RC_DEFAULT_MINSTREL=3Dy
> CONFIG_MAC80211_RC_DEFAULT=3D"minstrel_ht"
> CONFIG_MAC80211_MESH=3Dy
> CONFIG_MAC80211_LEDS=3Dy
> # CONFIG_MAC80211_DEBUGFS is not set
> # CONFIG_MAC80211_DEBUG_MENU is not set
> CONFIG_WIMAX=3Dm
> CONFIG_WIMAX_DEBUG_LEVEL=3D8
> CONFIG_RFKILL=3Dm
> CONFIG_RFKILL_LEDS=3Dy
> CONFIG_RFKILL_INPUT=3Dy
> CONFIG_NET_9P=3Dm
> CONFIG_NET_9P_VIRTIO=3Dm
> CONFIG_NET_9P_RDMA=3Dm
> # CONFIG_NET_9P_DEBUG is not set
> CONFIG_CAIF=3Dm
> # CONFIG_CAIF_DEBUG is not set
> CONFIG_CAIF_NETDEV=3Dm
> CONFIG_CEPH_LIB=3Dm
> # CONFIG_CEPH_LIB_PRETTYDEBUG is not set
>=20
> #
> # Device Drivers
> #
>=20
> #
> # Generic Driver Options
> #
> CONFIG_UEVENT_HELPER_PATH=3D"/sbin/hotplug"
> CONFIG_DEVTMPFS=3Dy
> CONFIG_DEVTMPFS_MOUNT=3Dy
> CONFIG_STANDALONE=3Dy
> CONFIG_PREVENT_FIRMWARE_BUILD=3Dy
> CONFIG_FW_LOADER=3Dy
> # CONFIG_FIRMWARE_IN_KERNEL is not set
> CONFIG_EXTRA_FIRMWARE=3D""
> # CONFIG_SYS_HYPERVISOR is not set
> CONFIG_CONNECTOR=3Dy
> CONFIG_PROC_EVENTS=3Dy
> CONFIG_MTD=3Dy
> # CONFIG_MTD_DEBUG is not set
> CONFIG_MTD_TESTS=3Dm
> CONFIG_MTD_CONCAT=3Dy
> CONFIG_MTD_PARTITIONS=3Dy
> CONFIG_MTD_REDBOOT_PARTS=3Dy
> CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=3D-1
> CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED=3Dy
> # CONFIG_MTD_REDBOOT_PARTS_READONLY is not set
> CONFIG_MTD_CMDLINE_PARTS=3Dy
> CONFIG_MTD_AR7_PARTS=3Dy
>=20
> #
> # User Modules And Translation Layers
> #
> CONFIG_MTD_CHAR=3Dy
> CONFIG_HAVE_MTD_OTP=3Dy
> CONFIG_MTD_BLKDEVS=3Dy
> CONFIG_MTD_BLOCK=3Dy
> CONFIG_FTL=3Dy
> CONFIG_NFTL=3Dy
> CONFIG_NFTL_RW=3Dy
> CONFIG_INFTL=3Dy
> CONFIG_RFD_FTL=3Dy
> CONFIG_SSFDC=3Dy
> CONFIG_SM_FTL=3Dm
> CONFIG_MTD_OOPS=3Dy
>=20
> #
> # RAM/ROM/Flash chip drivers
> #
> CONFIG_MTD_CFI=3Dy
> CONFIG_MTD_JEDECPROBE=3Dy
> CONFIG_MTD_GEN_PROBE=3Dy
> CONFIG_MTD_CFI_ADV_OPTIONS=3Dy
> CONFIG_MTD_CFI_NOSWAP=3Dy
> # CONFIG_MTD_CFI_BE_BYTE_SWAP is not set
> # CONFIG_MTD_CFI_LE_BYTE_SWAP is not set
> CONFIG_MTD_CFI_GEOMETRY=3Dy
> CONFIG_MTD_MAP_BANK_WIDTH_1=3Dy
> CONFIG_MTD_MAP_BANK_WIDTH_2=3Dy
> CONFIG_MTD_MAP_BANK_WIDTH_4=3Dy
> CONFIG_MTD_MAP_BANK_WIDTH_8=3Dy
> CONFIG_MTD_MAP_BANK_WIDTH_16=3Dy
> CONFIG_MTD_MAP_BANK_WIDTH_32=3Dy
> CONFIG_MTD_CFI_I1=3Dy
> CONFIG_MTD_CFI_I2=3Dy
> CONFIG_MTD_CFI_I4=3Dy
> CONFIG_MTD_CFI_I8=3Dy
> CONFIG_MTD_OTP=3Dy
> CONFIG_MTD_CFI_INTELEXT=3Dy
> CONFIG_MTD_CFI_AMDSTD=3Dy
> CONFIG_MTD_CFI_STAA=3Dy
> CONFIG_MTD_CFI_UTIL=3Dy
> CONFIG_MTD_RAM=3Dy
> CONFIG_MTD_ROM=3Dy
> CONFIG_MTD_ABSENT=3Dy
>=20
> #
> # Mapping drivers for chip access
> #
> CONFIG_MTD_COMPLEX_MAPPINGS=3Dy
> CONFIG_MTD_PHYSMAP=3Dy
> CONFIG_MTD_PHYSMAP_COMPAT=3Dy
> CONFIG_MTD_PHYSMAP_START=3D0x8000000
> CONFIG_MTD_PHYSMAP_LEN=3D0
> CONFIG_MTD_PHYSMAP_BANKWIDTH=3D2
> CONFIG_MTD_SC520CDP=3Dy
> CONFIG_MTD_NETSC520=3Dy
> CONFIG_MTD_TS5500=3Dy
> CONFIG_MTD_SBC_GXX=3Dy
> CONFIG_MTD_SCx200_DOCFLASH=3Dy
> CONFIG_MTD_AMD76XROM=3Dy
> CONFIG_MTD_ICHXROM=3Dy
> CONFIG_MTD_ESB2ROM=3Dy
> CONFIG_MTD_CK804XROM=3Dy
> CONFIG_MTD_SCB2_FLASH=3Dy
> CONFIG_MTD_NETtel=3Dy
> CONFIG_MTD_L440GX=3Dy
> CONFIG_MTD_PCI=3Dy
> CONFIG_MTD_PCMCIA=3Dm
> CONFIG_MTD_PCMCIA_ANONYMOUS=3Dy
> CONFIG_MTD_GPIO_ADDR=3Dy
> CONFIG_MTD_INTEL_VR_NOR=3Dy
> CONFIG_MTD_PLATRAM=3Dy
>=20
> #
> # Self-contained MTD device drivers
> #
> CONFIG_MTD_PMC551=3Dy
> CONFIG_MTD_PMC551_BUGFIX=3Dy
> # CONFIG_MTD_PMC551_DEBUG is not set
> CONFIG_MTD_DATAFLASH=3Dy
> CONFIG_MTD_DATAFLASH_WRITE_VERIFY=3Dy
> CONFIG_MTD_DATAFLASH_OTP=3Dy
> CONFIG_MTD_M25P80=3Dy
> CONFIG_M25PXX_USE_FAST_READ=3Dy
> CONFIG_MTD_SST25L=3Dy
> CONFIG_MTD_SLRAM=3Dy
> CONFIG_MTD_PHRAM=3Dy
> CONFIG_MTD_MTDRAM=3Dy
> CONFIG_MTDRAM_TOTAL_SIZE=3D4096
> CONFIG_MTDRAM_ERASE_SIZE=3D128
> CONFIG_MTDRAM_ABS_POS=3D0
> CONFIG_MTD_BLOCK2MTD=3Dy
>=20
> #
> # Disk-On-Chip Device Drivers
> #
> CONFIG_MTD_DOC2000=3Dy
> CONFIG_MTD_DOC2001=3Dy
> CONFIG_MTD_DOC2001PLUS=3Dy
> CONFIG_MTD_DOCPROBE=3Dy
> CONFIG_MTD_DOCECC=3Dy
> CONFIG_MTD_DOCPROBE_ADVANCED=3Dy
> CONFIG_MTD_DOCPROBE_ADDRESS=3D0x0000
> CONFIG_MTD_DOCPROBE_HIGH=3Dy
> CONFIG_MTD_DOCPROBE_55AA=3Dy
> CONFIG_MTD_NAND_ECC=3Dy
> CONFIG_MTD_NAND_ECC_SMC=3Dy
> CONFIG_MTD_NAND=3Dy
> CONFIG_MTD_NAND_VERIFY_WRITE=3Dy
> CONFIG_MTD_SM_COMMON=3Dm
> CONFIG_MTD_NAND_MUSEUM_IDS=3Dy
> CONFIG_MTD_NAND_DENALI=3Dm
> CONFIG_MTD_NAND_DENALI_SCRATCH_REG_ADDR=3D0xFF108018
> CONFIG_MTD_NAND_IDS=3Dy
> CONFIG_MTD_NAND_RICOH=3Dm
> CONFIG_MTD_NAND_DISKONCHIP=3Dy
> CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED=3Dy
> CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=3D0
> CONFIG_MTD_NAND_DISKONCHIP_PROBE_HIGH=3Dy
> CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE=3Dy
> CONFIG_MTD_NAND_CAFE=3Dy
> CONFIG_MTD_NAND_CS553X=3Dy
> CONFIG_MTD_NAND_NANDSIM=3Dy
> CONFIG_MTD_NAND_PLATFORM=3Dy
> CONFIG_MTD_ALAUDA=3Dy
> CONFIG_MTD_ONENAND=3Dy
> CONFIG_MTD_ONENAND_VERIFY_WRITE=3Dy
> CONFIG_MTD_ONENAND_GENERIC=3Dy
> CONFIG_MTD_ONENAND_OTP=3Dy
> CONFIG_MTD_ONENAND_2X_PROGRAM=3Dy
> CONFIG_MTD_ONENAND_SIM=3Dy
>=20
> #
> # LPDDR flash memory drivers
> #
> CONFIG_MTD_LPDDR=3Dy
> CONFIG_MTD_QINFO_PROBE=3Dy
> CONFIG_MTD_UBI=3Dy
> CONFIG_MTD_UBI_WL_THRESHOLD=3D4096
> CONFIG_MTD_UBI_BEB_RESERVE=3D1
> CONFIG_MTD_UBI_GLUEBI=3Dy
>=20
> #
> # UBI debugging options
> #
> # CONFIG_MTD_UBI_DEBUG is not set
> CONFIG_PARPORT=3Dy
> CONFIG_PARPORT_PC=3Dy
> CONFIG_PARPORT_SERIAL=3Dy
> CONFIG_PARPORT_PC_FIFO=3Dy
> CONFIG_PARPORT_PC_SUPERIO=3Dy
> CONFIG_PARPORT_PC_PCMCIA=3Dy
> # CONFIG_PARPORT_GSC is not set
> CONFIG_PARPORT_AX88796=3Dy
> CONFIG_PARPORT_1284=3Dy
> CONFIG_PARPORT_NOT_PC=3Dy
> CONFIG_PNP=3Dy
> CONFIG_PNP_DEBUG_MESSAGES=3Dy
>=20
> #
> # Protocols
> #
> CONFIG_ISAPNP=3Dy
> CONFIG_PNPBIOS=3Dy
> CONFIG_PNPBIOS_PROC_FS=3Dy
> CONFIG_PNPACPI=3Dy
> CONFIG_BLK_DEV=3Dy
> CONFIG_BLK_DEV_FD=3Dy
> CONFIG_BLK_DEV_XD=3Dy
> CONFIG_PARIDE=3Dy
>=20
> #
> # Parallel IDE high-level drivers
> #
> CONFIG_PARIDE_PD=3Dy
> CONFIG_PARIDE_PCD=3Dy
> CONFIG_PARIDE_PF=3Dy
> CONFIG_PARIDE_PT=3Dy
> CONFIG_PARIDE_PG=3Dy
>=20
> #
> # Parallel IDE protocol modules
> #
> CONFIG_PARIDE_ATEN=3Dy
> CONFIG_PARIDE_BPCK=3Dy
> CONFIG_PARIDE_BPCK6=3Dy
> CONFIG_PARIDE_COMM=3Dy
> CONFIG_PARIDE_DSTR=3Dy
> CONFIG_PARIDE_FIT2=3Dy
> CONFIG_PARIDE_FIT3=3Dy
> CONFIG_PARIDE_EPAT=3Dy
> CONFIG_PARIDE_EPATC8=3Dy
> CONFIG_PARIDE_EPIA=3Dy
> CONFIG_PARIDE_FRIQ=3Dy
> CONFIG_PARIDE_FRPW=3Dy
> CONFIG_PARIDE_KBIC=3Dy
> CONFIG_PARIDE_KTTI=3Dy
> CONFIG_PARIDE_ON20=3Dy
> CONFIG_PARIDE_ON26=3Dy
> CONFIG_BLK_CPQ_DA=3Dy
> CONFIG_BLK_CPQ_CISS_DA=3Dy
> CONFIG_CISS_SCSI_TAPE=3Dy
> CONFIG_BLK_DEV_DAC960=3Dy
> CONFIG_BLK_DEV_UMEM=3Dy
> # CONFIG_BLK_DEV_COW_COMMON is not set
> CONFIG_BLK_DEV_LOOP=3Dy
> CONFIG_BLK_DEV_CRYPTOLOOP=3Dy
> CONFIG_BLK_DEV_DRBD=3Dm
> # CONFIG_DRBD_FAULT_INJECTION is not set
> CONFIG_BLK_DEV_NBD=3Dy
> CONFIG_BLK_DEV_OSD=3Dy
> CONFIG_BLK_DEV_SX8=3Dy
> CONFIG_BLK_DEV_UB=3Dy
> CONFIG_BLK_DEV_RAM=3Dy
> CONFIG_BLK_DEV_RAM_COUNT=3D16
> CONFIG_BLK_DEV_RAM_SIZE=3D16384
> CONFIG_BLK_DEV_XIP=3Dy
> CONFIG_CDROM_PKTCDVD=3Dy
> CONFIG_CDROM_PKTCDVD_BUFFERS=3D8
> CONFIG_CDROM_PKTCDVD_WCACHE=3Dy
> CONFIG_ATA_OVER_ETH=3Dy
> CONFIG_VIRTIO_BLK=3Dy
> # CONFIG_BLK_DEV_HD is not set
> CONFIG_BLK_DEV_RBD=3Dm
> CONFIG_MISC_DEVICES=3Dy
> CONFIG_AD525X_DPOT=3Dm
> CONFIG_AD525X_DPOT_I2C=3Dm
> CONFIG_AD525X_DPOT_SPI=3Dm
> CONFIG_IBM_ASM=3Dy
> CONFIG_PHANTOM=3Dy
> CONFIG_SGI_IOC4=3Dy
> CONFIG_TIFM_CORE=3Dy
> CONFIG_TIFM_7XX1=3Dy
> CONFIG_ICS932S401=3Dy
> CONFIG_ENCLOSURE_SERVICES=3Dy
> CONFIG_CS5535_MFGPT=3Dm
> CONFIG_CS5535_MFGPT_DEFAULT_IRQ=3D7
> CONFIG_CS5535_CLOCK_EVENT_SRC=3Dm
> CONFIG_HP_ILO=3Dy
> CONFIG_APDS9802ALS=3Dm
> CONFIG_ISL29003=3Dy
> CONFIG_ISL29020=3Dm
> CONFIG_SENSORS_TSL2550=3Dm
> CONFIG_SENSORS_BH1780=3Dm
> CONFIG_SENSORS_BH1770=3Dm
> CONFIG_SENSORS_APDS990X=3Dm
> CONFIG_HMC6352=3Dm
> CONFIG_DS1682=3Dm
> CONFIG_TI_DAC7512=3Dm
> CONFIG_VMWARE_BALLOON=3Dm
> CONFIG_BMP085=3Dm
> CONFIG_PCH_PHUB=3Dm
> CONFIG_C2PORT=3Dy
> CONFIG_C2PORT_DURAMAR_2150=3Dy
>=20
> #
> # EEPROM support
> #
> CONFIG_EEPROM_AT24=3Dy
> CONFIG_EEPROM_AT25=3Dy
> CONFIG_EEPROM_LEGACY=3Dy
> CONFIG_EEPROM_MAX6875=3Dy
> CONFIG_EEPROM_93CX6=3Dy
> CONFIG_CB710_CORE=3Dy
> # CONFIG_CB710_DEBUG is not set
> CONFIG_CB710_DEBUG_ASSUMPTIONS=3Dy
> CONFIG_IWMC3200TOP=3Dm
> # CONFIG_IWMC3200TOP_DEBUG is not set
> # CONFIG_IWMC3200TOP_DEBUGFS is not set
>=20
> #
> # Texas Instruments shared transport line discipline
> #
> CONFIG_TI_ST=3Dm
> CONFIG_HAVE_IDE=3Dy
> CONFIG_IDE=3Dy
>=20
> #
> # Please see Documentation/ide/ide.txt for help/info on=20
> IDE drives
> #
> CONFIG_IDE_XFER_MODE=3Dy
> CONFIG_IDE_TIMINGS=3Dy
> CONFIG_IDE_ATAPI=3Dy
> CONFIG_IDE_LEGACY=3Dy
> # CONFIG_BLK_DEV_IDE_SATA is not set
> CONFIG_IDE_GD=3Dy
> CONFIG_IDE_GD_ATA=3Dy
> CONFIG_IDE_GD_ATAPI=3Dy
> CONFIG_BLK_DEV_IDECS=3Dy
> CONFIG_BLK_DEV_DELKIN=3Dy
> CONFIG_BLK_DEV_IDECD=3Dy
> CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=3Dy
> CONFIG_BLK_DEV_IDETAPE=3Dy
> CONFIG_BLK_DEV_IDEACPI=3Dy
> CONFIG_IDE_TASK_IOCTL=3Dy
> CONFIG_IDE_PROC_FS=3Dy
>=20
> #
> # IDE chipset support/bugfixes
> #
> CONFIG_IDE_GENERIC=3Dy
> CONFIG_BLK_DEV_PLATFORM=3Dy
> CONFIG_BLK_DEV_CMD640=3Dy
> CONFIG_BLK_DEV_CMD640_ENHANCED=3Dy
> CONFIG_BLK_DEV_IDEPNP=3Dy
> CONFIG_BLK_DEV_IDEDMA_SFF=3Dy
>=20
> #
> # PCI IDE chipsets support
> #
> CONFIG_BLK_DEV_IDEPCI=3Dy
> # CONFIG_IDEPCI_PCIBUS_ORDER is not set
> # CONFIG_BLK_DEV_OFFBOARD is not set
> CONFIG_BLK_DEV_GENERIC=3Dy
> CONFIG_BLK_DEV_OPTI621=3Dy
> CONFIG_BLK_DEV_RZ1000=3Dy
> CONFIG_BLK_DEV_IDEDMA_PCI=3Dy
> CONFIG_BLK_DEV_AEC62XX=3Dy
> CONFIG_BLK_DEV_ALI15X3=3Dy
> CONFIG_BLK_DEV_AMD74XX=3Dy
> CONFIG_BLK_DEV_ATIIXP=3Dy
> CONFIG_BLK_DEV_CMD64X=3Dy
> CONFIG_BLK_DEV_TRIFLEX=3Dy
> CONFIG_BLK_DEV_CS5520=3Dy
> CONFIG_BLK_DEV_CS5530=3Dy
> CONFIG_BLK_DEV_CS5535=3Dy
> CONFIG_BLK_DEV_CS5536=3Dy
> CONFIG_BLK_DEV_HPT366=3Dy
> CONFIG_BLK_DEV_JMICRON=3Dy
> CONFIG_BLK_DEV_SC1200=3Dy
> CONFIG_BLK_DEV_PIIX=3Dy
> CONFIG_BLK_DEV_IT8172=3Dy
> CONFIG_BLK_DEV_IT8213=3Dy
> CONFIG_BLK_DEV_IT821X=3Dy
> CONFIG_BLK_DEV_NS87415=3Dy
> CONFIG_BLK_DEV_PDC202XX_OLD=3Dy
> CONFIG_BLK_DEV_PDC202XX_NEW=3Dy
> CONFIG_BLK_DEV_SVWKS=3Dy
> CONFIG_BLK_DEV_SIIMAGE=3Dy
> CONFIG_BLK_DEV_SIS5513=3Dy
> CONFIG_BLK_DEV_SLC90E66=3Dy
> CONFIG_BLK_DEV_TRM290=3Dy
> CONFIG_BLK_DEV_VIA82CXXX=3Dy
> CONFIG_BLK_DEV_TC86C001=3Dy
>=20
> #
> # Other IDE chipsets support
> #
>=20
> #
> # Note: most of these also require special kernel boot=20
> parameters
> #
> CONFIG_BLK_DEV_4DRIVES=3Dy
> CONFIG_BLK_DEV_ALI14XX=3Dy
> CONFIG_BLK_DEV_DTC2278=3Dy
> CONFIG_BLK_DEV_HT6560B=3Dy
> CONFIG_BLK_DEV_QD65XX=3Dy
> CONFIG_BLK_DEV_UMC8672=3Dy
> CONFIG_BLK_DEV_IDEDMA=3Dy
>=20
> #
> # SCSI device support
> #
> CONFIG_SCSI_MOD=3Dy
> CONFIG_RAID_ATTRS=3Dy
> CONFIG_SCSI=3Dy
> CONFIG_SCSI_DMA=3Dy
> CONFIG_SCSI_TGT=3Dy
> CONFIG_SCSI_NETLINK=3Dy
> CONFIG_SCSI_PROC_FS=3Dy
>=20
> #
> # SCSI support type (disk, tape, CD-ROM)
> #
> CONFIG_BLK_DEV_SD=3Dy
> CONFIG_CHR_DEV_ST=3Dy
> CONFIG_CHR_DEV_OSST=3Dy
> CONFIG_BLK_DEV_SR=3Dy
> CONFIG_BLK_DEV_SR_VENDOR=3Dy
> CONFIG_CHR_DEV_SG=3Dy
> CONFIG_CHR_DEV_SCH=3Dy
> CONFIG_SCSI_ENCLOSURE=3Dy
> CONFIG_SCSI_MULTI_LUN=3Dy
> CONFIG_SCSI_CONSTANTS=3Dy
> CONFIG_SCSI_LOGGING=3Dy
> CONFIG_SCSI_SCAN_ASYNC=3Dy
> CONFIG_SCSI_WAIT_SCAN=3Dm
>=20
> #
> # SCSI Transports
> #
> CONFIG_SCSI_SPI_ATTRS=3Dy
> CONFIG_SCSI_FC_ATTRS=3Dy
> CONFIG_SCSI_FC_TGT_ATTRS=3Dy
> CONFIG_SCSI_ISCSI_ATTRS=3Dy
> CONFIG_SCSI_SAS_ATTRS=3Dy
> CONFIG_SCSI_SAS_LIBSAS=3Dy
> CONFIG_SCSI_SAS_ATA=3Dy
> CONFIG_SCSI_SAS_HOST_SMP=3Dy
> # CONFIG_SCSI_SAS_LIBSAS_DEBUG is not set
> CONFIG_SCSI_SRP_ATTRS=3Dy
> CONFIG_SCSI_SRP_TGT_ATTRS=3Dy
> CONFIG_SCSI_LOWLEVEL=3Dy
> CONFIG_ISCSI_TCP=3Dy
> CONFIG_ISCSI_BOOT_SYSFS=3Dy
> CONFIG_SCSI_CXGB3_ISCSI=3Dy
> CONFIG_SCSI_CXGB4_ISCSI=3Dm
> CONFIG_SCSI_BNX2_ISCSI=3Dy
> CONFIG_BE2ISCSI=3Dy
> CONFIG_BLK_DEV_3W_XXXX_RAID=3Dy
> CONFIG_SCSI_HPSA=3Dm
> CONFIG_SCSI_3W_9XXX=3Dy
> CONFIG_SCSI_3W_SAS=3Dm
> CONFIG_SCSI_7000FASST=3Dy
> CONFIG_SCSI_ACARD=3Dy
> CONFIG_SCSI_AHA152X=3Dy
> CONFIG_SCSI_AHA1542=3Dy
> CONFIG_SCSI_AHA1740=3Dy
> CONFIG_SCSI_AACRAID=3Dy
> CONFIG_SCSI_AIC7XXX=3Dy
> CONFIG_AIC7XXX_CMDS_PER_DEVICE=3D4
> CONFIG_AIC7XXX_RESET_DELAY_MS=3D15000
> # CONFIG_AIC7XXX_DEBUG_ENABLE is not set
> CONFIG_AIC7XXX_DEBUG_MASK=3D0
> # CONFIG_AIC7XXX_REG_PRETTY_PRINT is not set
> CONFIG_SCSI_AIC7XXX_OLD=3Dy
> CONFIG_SCSI_AIC79XX=3Dy
> CONFIG_AIC79XX_CMDS_PER_DEVICE=3D4
> CONFIG_AIC79XX_RESET_DELAY_MS=3D15000
> # CONFIG_AIC79XX_DEBUG_ENABLE is not set
> CONFIG_AIC79XX_DEBUG_MASK=3D0
> # CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
> CONFIG_SCSI_AIC94XX=3Dy
> # CONFIG_AIC94XX_DEBUG is not set
> CONFIG_SCSI_MVSAS=3Dy
> CONFIG_SCSI_MVSAS_DEBUG=3Dy
> CONFIG_SCSI_DPT_I2O=3Dy
> CONFIG_SCSI_ADVANSYS=3Dy
> CONFIG_SCSI_IN2000=3Dy
> CONFIG_SCSI_ARCMSR=3Dy
> CONFIG_SCSI_ARCMSR_AER=3Dy
> CONFIG_MEGARAID_NEWGEN=3Dy
> CONFIG_MEGARAID_MM=3Dy
> CONFIG_MEGARAID_MAILBOX=3Dy
> CONFIG_MEGARAID_LEGACY=3Dy
> CONFIG_MEGARAID_SAS=3Dy
> CONFIG_SCSI_MPT2SAS=3Dy
> CONFIG_SCSI_MPT2SAS_MAX_SGE=3D128
> CONFIG_SCSI_MPT2SAS_LOGGING=3Dy
> CONFIG_SCSI_HPTIOP=3Dy
> CONFIG_SCSI_BUSLOGIC=3Dy
> CONFIG_SCSI_FLASHPOINT=3Dy
> CONFIG_VMWARE_PVSCSI=3Dm
> CONFIG_LIBFC=3Dy
> CONFIG_LIBFCOE=3Dy
> CONFIG_FCOE=3Dy
> CONFIG_FCOE_FNIC=3Dy
> CONFIG_SCSI_DMX3191D=3Dy
> CONFIG_SCSI_DTC3280=3Dy
> CONFIG_SCSI_EATA=3Dy
> CONFIG_SCSI_EATA_TAGGED_QUEUE=3Dy
> CONFIG_SCSI_EATA_LINKED_COMMANDS=3Dy
> CONFIG_SCSI_EATA_MAX_TAGS=3D16
> CONFIG_SCSI_FUTURE_DOMAIN=3Dy
> CONFIG_SCSI_FD_MCS=3Dy
> CONFIG_SCSI_GDTH=3Dy
> CONFIG_SCSI_GENERIC_NCR5380=3Dy
> CONFIG_SCSI_GENERIC_NCR5380_MMIO=3Dy
> CONFIG_SCSI_GENERIC_NCR53C400=3Dy
> CONFIG_SCSI_IBMMCA=3Dy
> CONFIG_IBMMCA_SCSI_ORDER_STANDARD=3Dy
> CONFIG_IBMMCA_SCSI_DEV_RESET=3Dy
> CONFIG_SCSI_IPS=3Dy
> CONFIG_SCSI_INITIO=3Dy
> CONFIG_SCSI_INIA100=3Dy
> CONFIG_SCSI_PPA=3Dy
> CONFIG_SCSI_IMM=3Dy
> CONFIG_SCSI_IZIP_EPP16=3Dy
> # CONFIG_SCSI_IZIP_SLOW_CTR is not set
> CONFIG_SCSI_NCR53C406A=3Dy
> CONFIG_SCSI_NCR_D700=3Dy
> CONFIG_SCSI_STEX=3Dy
> CONFIG_SCSI_SYM53C8XX_2=3Dy
> CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=3D1
> CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=3D16
> CONFIG_SCSI_SYM53C8XX_MAX_TAGS=3D64
> CONFIG_SCSI_SYM53C8XX_MMIO=3Dy
> CONFIG_SCSI_IPR=3Dy
> CONFIG_SCSI_IPR_TRACE=3Dy
> CONFIG_SCSI_IPR_DUMP=3Dy
> CONFIG_SCSI_NCR_Q720=3Dy
> CONFIG_SCSI_NCR53C8XX_DEFAULT_TAGS=3D8
> CONFIG_SCSI_NCR53C8XX_MAX_TAGS=3D32
> CONFIG_SCSI_NCR53C8XX_SYNC=3D20
> CONFIG_SCSI_PAS16=3Dy
> CONFIG_SCSI_QLOGIC_FAS=3Dy
> CONFIG_SCSI_QLOGIC_1280=3Dy
> CONFIG_SCSI_QLA_FC=3Dy
> CONFIG_SCSI_QLA_ISCSI=3Dy
> CONFIG_SCSI_LPFC=3Dy
> CONFIG_SCSI_LPFC_DEBUG_FS=3Dy
> CONFIG_SCSI_SIM710=3Dy
> CONFIG_SCSI_SYM53C416=3Dy
> CONFIG_SCSI_DC395x=3Dy
> CONFIG_SCSI_DC390T=3Dy
> CONFIG_SCSI_T128=3Dy
> CONFIG_SCSI_U14_34F=3Dy
> CONFIG_SCSI_U14_34F_TAGGED_QUEUE=3Dy
> CONFIG_SCSI_U14_34F_LINKED_COMMANDS=3Dy
> CONFIG_SCSI_U14_34F_MAX_TAGS=3D8
> CONFIG_SCSI_ULTRASTOR=3Dy
> CONFIG_SCSI_NSP32=3Dy
> # CONFIG_SCSI_DEBUG is not set
> CONFIG_SCSI_PMCRAID=3Dy
> CONFIG_SCSI_PM8001=3Dm
> CONFIG_SCSI_SRP=3Dy
> CONFIG_SCSI_BFA_FC=3Dy
> CONFIG_SCSI_LOWLEVEL_PCMCIA=3Dy
> CONFIG_PCMCIA_AHA152X=3Dm
> CONFIG_PCMCIA_FDOMAIN=3Dm
> CONFIG_PCMCIA_NINJA_SCSI=3Dm
> CONFIG_PCMCIA_QLOGIC=3Dm
> CONFIG_PCMCIA_SYM53C500=3Dm
> CONFIG_SCSI_DH=3Dy
> CONFIG_SCSI_DH_RDAC=3Dy
> CONFIG_SCSI_DH_HP_SW=3Dy
> CONFIG_SCSI_DH_EMC=3Dy
> CONFIG_SCSI_DH_ALUA=3Dy
> CONFIG_SCSI_OSD_INITIATOR=3Dy
> CONFIG_SCSI_OSD_ULD=3Dy
> CONFIG_SCSI_OSD_DPRINT_SENSE=3D1
> # CONFIG_SCSI_OSD_DEBUG is not set
> CONFIG_ATA=3Dy
> # CONFIG_ATA_NONSTANDARD is not set
> CONFIG_ATA_VERBOSE_ERROR=3Dy
> CONFIG_ATA_ACPI=3Dy
> CONFIG_SATA_PMP=3Dy
>=20
> #
> # Controllers with non-SFF native interface
> #
> CONFIG_SATA_AHCI=3Dy
> CONFIG_SATA_AHCI_PLATFORM=3Dm
> CONFIG_SATA_INIC162X=3Dy
> CONFIG_SATA_SIL24=3Dy
> CONFIG_ATA_SFF=3Dy
>=20
> #
> # SFF controllers with custom DMA interface
> #
> CONFIG_PDC_ADMA=3Dy
> CONFIG_SATA_QSTOR=3Dy
> CONFIG_SATA_SX4=3Dy
> CONFIG_ATA_BMDMA=3Dy
>=20
> #
> # SATA SFF controllers with BMDMA
> #
> CONFIG_ATA_PIIX=3Dy
> CONFIG_SATA_MV=3Dy
> CONFIG_SATA_NV=3Dy
> CONFIG_SATA_PROMISE=3Dy
> CONFIG_SATA_SIL=3Dy
> CONFIG_SATA_SIS=3Dy
> CONFIG_SATA_SVW=3Dy
> CONFIG_SATA_ULI=3Dy
> CONFIG_SATA_VIA=3Dy
> CONFIG_SATA_VITESSE=3Dy
>=20
> #
> # PATA SFF controllers with BMDMA
> #
> CONFIG_PATA_ALI=3Dy
> CONFIG_PATA_AMD=3Dy
> CONFIG_PATA_ARTOP=3Dy
> CONFIG_PATA_ATIIXP=3Dy
> CONFIG_PATA_ATP867X=3Dy
> CONFIG_PATA_CMD64X=3Dy
> CONFIG_PATA_CS5520=3Dy
> CONFIG_PATA_CS5530=3Dy
> CONFIG_PATA_CS5535=3Dy
> CONFIG_PATA_CS5536=3Dy
> CONFIG_PATA_CYPRESS=3Dy
> CONFIG_PATA_EFAR=3Dy
> CONFIG_PATA_HPT366=3Dy
> CONFIG_PATA_HPT37X=3Dy
> CONFIG_PATA_HPT3X2N=3Dy
> CONFIG_PATA_HPT3X3=3Dy
> CONFIG_PATA_HPT3X3_DMA=3Dy
> CONFIG_PATA_IT8213=3Dy
> CONFIG_PATA_IT821X=3Dy
> CONFIG_PATA_JMICRON=3Dy
> CONFIG_PATA_MARVELL=3Dy
> CONFIG_PATA_NETCELL=3Dy
> CONFIG_PATA_NINJA32=3Dy
> CONFIG_PATA_NS87415=3Dy
> CONFIG_PATA_OLDPIIX=3Dy
> CONFIG_PATA_OPTIDMA=3Dy
> CONFIG_PATA_PDC2027X=3Dy
> CONFIG_PATA_PDC_OLD=3Dy
> CONFIG_PATA_RADISYS=3Dy
> CONFIG_PATA_RDC=3Dy
> CONFIG_PATA_SC1200=3Dy
> CONFIG_PATA_SCH=3Dy
> CONFIG_PATA_SERVERWORKS=3Dy
> CONFIG_PATA_SIL680=3Dy
> CONFIG_PATA_SIS=3Dy
> CONFIG_PATA_TOSHIBA=3Dy
> CONFIG_PATA_TRIFLEX=3Dy
> CONFIG_PATA_VIA=3Dy
> CONFIG_PATA_WINBOND=3Dy
>=20
> #
> # PIO-only SFF controllers
> #
> CONFIG_PATA_CMD640_PCI=3Dy
> CONFIG_PATA_ISAPNP=3Dy
> CONFIG_PATA_MPIIX=3Dy
> CONFIG_PATA_NS87410=3Dy
> CONFIG_PATA_OPTI=3Dy
> CONFIG_PATA_PCMCIA=3Dy
> CONFIG_PATA_PLATFORM=3Dy
> CONFIG_PATA_QDI=3Dy
> CONFIG_PATA_RZ1000=3Dy
> CONFIG_PATA_WINBOND_VLB=3Dy
>=20
> #
> # Generic fallback / legacy drivers
> #
> CONFIG_PATA_ACPI=3Dy
> CONFIG_ATA_GENERIC=3Dy
> CONFIG_PATA_LEGACY=3Dy
> CONFIG_MD=3Dy
> CONFIG_BLK_DEV_MD=3Dy
> CONFIG_MD_AUTODETECT=3Dy
> CONFIG_MD_LINEAR=3Dy
> CONFIG_MD_RAID0=3Dy
> CONFIG_MD_RAID1=3Dy
> CONFIG_MD_RAID10=3Dy
> CONFIG_MD_RAID456=3Dy
> CONFIG_MULTICORE_RAID456=3Dy
> CONFIG_MD_MULTIPATH=3Dy
> CONFIG_MD_FAULTY=3Dy
> CONFIG_BLK_DEV_DM=3Dy
> # CONFIG_DM_DEBUG is not set
> CONFIG_DM_CRYPT=3Dy
> CONFIG_DM_SNAPSHOT=3Dy
> CONFIG_DM_MIRROR=3Dy
> # CONFIG_DM_LOG_USERSPACE is not set
> CONFIG_DM_ZERO=3Dy
> CONFIG_DM_MULTIPATH=3Dy
> # CONFIG_DM_MULTIPATH_QL is not set
> # CONFIG_DM_MULTIPATH_ST is not set
> # CONFIG_DM_DELAY is not set
> CONFIG_DM_UEVENT=3Dy
> CONFIG_FUSION=3Dy
> CONFIG_FUSION_SPI=3Dy
> CONFIG_FUSION_FC=3Dy
> CONFIG_FUSION_SAS=3Dy
> CONFIG_FUSION_MAX_SGE=3D128
> CONFIG_FUSION_CTL=3Dy
> CONFIG_FUSION_LAN=3Dy
> CONFIG_FUSION_LOGGING=3Dy
>=20
> #
> # IEEE 1394 (FireWire) support
> #
> CONFIG_FIREWIRE=3Dy
> CONFIG_FIREWIRE_OHCI=3Dy
> CONFIG_FIREWIRE_OHCI_DEBUG=3Dy
> CONFIG_FIREWIRE_SBP2=3Dy
> CONFIG_FIREWIRE_NET=3Dy
> CONFIG_FIREWIRE_NOSY=3Dm
> CONFIG_I2O=3Dy
> CONFIG_I2O_LCT_NOTIFY_ON_CHANGES=3Dy
> CONFIG_I2O_EXT_ADAPTEC=3Dy
> CONFIG_I2O_CONFIG=3Dy
> CONFIG_I2O_CONFIG_OLD_IOCTL=3Dy
> CONFIG_I2O_BUS=3Dy
> CONFIG_I2O_BLOCK=3Dy
> CONFIG_I2O_SCSI=3Dy
> CONFIG_I2O_PROC=3Dy
> CONFIG_MACINTOSH_DRIVERS=3Dy
> CONFIG_MAC_EMUMOUSEBTN=3Dy
> CONFIG_NETDEVICES=3Dy
> CONFIG_IFB=3Dm
> CONFIG_DUMMY=3Dm
> CONFIG_BONDING=3Dm
> CONFIG_MACVLAN=3Dm
> CONFIG_MACVTAP=3Dm
> CONFIG_EQUALIZER=3Dm
> CONFIG_TUN=3Dm
> CONFIG_VETH=3Dm
> CONFIG_NET_SB1000=3Dm
> CONFIG_ARCNET=3Dm
> CONFIG_ARCNET_1201=3Dm
> CONFIG_ARCNET_1051=3Dm
> CONFIG_ARCNET_RAW=3Dm
> CONFIG_ARCNET_CAP=3Dm
> CONFIG_ARCNET_COM90xx=3Dm
> CONFIG_ARCNET_COM90xxIO=3Dm
> CONFIG_ARCNET_RIM_I=3Dm
> CONFIG_ARCNET_COM20020=3Dm
> CONFIG_ARCNET_COM20020_ISA=3Dm
> CONFIG_ARCNET_COM20020_PCI=3Dm
> CONFIG_MII=3Dy
> CONFIG_PHYLIB=3Dy
>=20
> #
> # MII PHY device drivers
> #
> CONFIG_MARVELL_PHY=3Dm
> CONFIG_DAVICOM_PHY=3Dm
> CONFIG_QSEMI_PHY=3Dm
> CONFIG_LXT_PHY=3Dm
> CONFIG_CICADA_PHY=3Dm
> CONFIG_VITESSE_PHY=3Dm
> CONFIG_SMSC_PHY=3Dm
> CONFIG_BROADCOM_PHY=3Dm
> CONFIG_BCM63XX_PHY=3Dm
> CONFIG_ICPLUS_PHY=3Dm
> CONFIG_REALTEK_PHY=3Dm
> CONFIG_NATIONAL_PHY=3Dm
> CONFIG_STE10XP=3Dm
> CONFIG_LSI_ET1011C_PHY=3Dm
> CONFIG_MICREL_PHY=3Dm
> CONFIG_FIXED_PHY=3Dy
> CONFIG_MDIO_BITBANG=3Dm
> CONFIG_MDIO_GPIO=3Dm
> CONFIG_NET_ETHERNET=3Dy
> CONFIG_HAPPYMEAL=3Dm
> CONFIG_SUNGEM=3Dm
> CONFIG_CASSINI=3Dm
> CONFIG_NET_VENDOR_3COM=3Dy
> CONFIG_EL1=3Dm
> CONFIG_EL2=3Dm
> CONFIG_ELPLUS=3Dm
> CONFIG_EL16=3Dm
> CONFIG_EL3=3Dm
> CONFIG_3C515=3Dm
> CONFIG_ELMC=3Dm
> CONFIG_ELMC_II=3Dm
> CONFIG_VORTEX=3Dm
> CONFIG_TYPHOON=3Dm
> CONFIG_LANCE=3Dm
> CONFIG_NET_VENDOR_SMC=3Dy
> CONFIG_WD80x3=3Dm
> CONFIG_ULTRAMCA=3Dm
> CONFIG_ULTRA=3Dm
> CONFIG_ULTRA32=3Dm
> CONFIG_SMC9194=3Dm
> CONFIG_ENC28J60=3Dm
> # CONFIG_ENC28J60_WRITEVERIFY is not set
> CONFIG_ETHOC=3Dm
> CONFIG_NET_VENDOR_RACAL=3Dy
> CONFIG_NI52=3Dm
> CONFIG_NI65=3Dm
> CONFIG_DNET=3Dm
> CONFIG_NET_TULIP=3Dy
> CONFIG_DE2104X=3Dm
> CONFIG_DE2104X_DSL=3D0
> CONFIG_TULIP=3Dm
> CONFIG_TULIP_MWI=3Dy
> CONFIG_TULIP_MMIO=3Dy
> CONFIG_TULIP_NAPI=3Dy
> CONFIG_TULIP_NAPI_HW_MITIGATION=3Dy
> CONFIG_DE4X5=3Dm
> CONFIG_WINBOND_840=3Dm
> CONFIG_DM9102=3Dm
> CONFIG_ULI526X=3Dm
> CONFIG_PCMCIA_XIRCOM=3Dm
> CONFIG_AT1700=3Dm
> CONFIG_DEPCA=3Dm
> CONFIG_HP100=3Dm
> CONFIG_NET_ISA=3Dy
> CONFIG_E2100=3Dm
> CONFIG_EWRK3=3Dm
> CONFIG_EEXPRESS=3Dm
> CONFIG_EEXPRESS_PRO=3Dm
> CONFIG_HPLAN_PLUS=3Dm
> CONFIG_HPLAN=3Dm
> CONFIG_LP486E=3Dm
> CONFIG_ETH16I=3Dm
> CONFIG_NE2000=3Dm
> CONFIG_ZNET=3Dm
> CONFIG_SEEQ8005=3Dm
> CONFIG_NE2_MCA=3Dm
> CONFIG_IBMLANA=3Dm
> # CONFIG_IBM_NEW_EMAC_ZMII is not set
> # CONFIG_IBM_NEW_EMAC_RGMII is not set
> # CONFIG_IBM_NEW_EMAC_TAH is not set
> # CONFIG_IBM_NEW_EMAC_EMAC4 is not set
> # CONFIG_IBM_NEW_EMAC_NO_FLOW_CTRL is not set
> # CONFIG_IBM_NEW_EMAC_MAL_CLR_ICINTSTAT is not set
> # CONFIG_IBM_NEW_EMAC_MAL_COMMON_ERR is not set
> CONFIG_NET_PCI=3Dy
> CONFIG_PCNET32=3Dm
> CONFIG_AMD8111_ETH=3Dm
> CONFIG_ADAPTEC_STARFIRE=3Dm
> CONFIG_AC3200=3Dm
> CONFIG_KSZ884X_PCI=3Dm
> CONFIG_APRICOT=3Dm
> CONFIG_B44=3Dm
> CONFIG_B44_PCI_AUTOSELECT=3Dy
> CONFIG_B44_PCICORE_AUTOSELECT=3Dy
> CONFIG_B44_PCI=3Dy
> CONFIG_FORCEDETH=3Dm
> CONFIG_CS89x0=3Dm
> CONFIG_E100=3Dy
> CONFIG_LNE390=3Dm
> CONFIG_FEALNX=3Dm
> CONFIG_NATSEMI=3Dm
> CONFIG_NE2K_PCI=3Dm
> CONFIG_NE3210=3Dm
> CONFIG_ES3210=3Dm
> CONFIG_8139CP=3Dm
> CONFIG_8139TOO=3Dm
> CONFIG_8139TOO_PIO=3Dy
> CONFIG_8139TOO_TUNE_TWISTER=3Dy
> CONFIG_8139TOO_8129=3Dy
> # CONFIG_8139_OLD_RX_RESET is not set
> CONFIG_R6040=3Dm
> CONFIG_SIS900=3Dm
> CONFIG_EPIC100=3Dm
> CONFIG_SMSC9420=3Dm
> CONFIG_SUNDANCE=3Dm
> # CONFIG_SUNDANCE_MMIO is not set
> CONFIG_TLAN=3Dm
> CONFIG_KS8842=3Dm
> CONFIG_KS8851=3Dm
> CONFIG_KS8851_MLL=3Dm
> CONFIG_VIA_RHINE=3Dy
> CONFIG_VIA_RHINE_MMIO=3Dy
> CONFIG_SC92031=3Dm
> CONFIG_NET_POCKET=3Dy
> CONFIG_ATP=3Dy
> CONFIG_DE600=3Dy
> CONFIG_DE620=3Dy
> CONFIG_ATL2=3Dy
> CONFIG_NETDEV_1000=3Dy
> CONFIG_ACENIC=3Dm
> # CONFIG_ACENIC_OMIT_TIGON_I is not set
> CONFIG_DL2K=3Dm
> CONFIG_E1000=3Dm
> CONFIG_E1000E=3Dm
> CONFIG_IP1000=3Dm
> CONFIG_IGB=3Dm
> CONFIG_IGB_DCA=3Dy
> CONFIG_IGBVF=3Dm
> CONFIG_NS83820=3Dm
> CONFIG_HAMACHI=3Dm
> CONFIG_YELLOWFIN=3Dm
> CONFIG_R8169=3Dy
> CONFIG_R8169_VLAN=3Dy
> CONFIG_SIS190=3Dm
> CONFIG_SKGE=3Dm
> # CONFIG_SKGE_DEBUG is not set
> CONFIG_SKY2=3Dm
> # CONFIG_SKY2_DEBUG is not set
> CONFIG_VIA_VELOCITY=3Dm
> CONFIG_TIGON3=3Dm
> CONFIG_BNX2=3Dy
> CONFIG_CNIC=3Dy
> CONFIG_QLA3XXX=3Dm
> CONFIG_ATL1=3Dm
> CONFIG_ATL1E=3Dm
> CONFIG_ATL1C=3Dm
> CONFIG_JME=3Dm
> CONFIG_STMMAC_ETH=3Dm
> CONFIG_STMMAC_DA=3Dy
> CONFIG_STMMAC_DUAL_MAC=3Dy
> CONFIG_PCH_GBE=3Dm
> CONFIG_NETDEV_10000=3Dy
> CONFIG_MDIO=3Dy
> CONFIG_CHELSIO_T1=3Dm
> CONFIG_CHELSIO_T1_1G=3Dy
> CONFIG_CHELSIO_T3_DEPENDS=3Dy
> CONFIG_CHELSIO_T3=3Dy
> CONFIG_CHELSIO_T4_DEPENDS=3Dy
> CONFIG_CHELSIO_T4=3Dm
> CONFIG_CHELSIO_T4VF_DEPENDS=3Dy
> CONFIG_CHELSIO_T4VF=3Dm
> CONFIG_ENIC=3Dm
> CONFIG_IXGBE=3Dm
> CONFIG_IXGBE_DCA=3Dy
> CONFIG_IXGBE_DCB=3Dy
> CONFIG_IXGB=3Dm
> CONFIG_S2IO=3Dm
> CONFIG_VXGE=3Dm
> # CONFIG_VXGE_DEBUG_TRACE_ALL is not set
> CONFIG_MYRI10GE=3Dm
> CONFIG_MYRI10GE_DCA=3Dy
> CONFIG_NETXEN_NIC=3Dm
> CONFIG_NIU=3Dm
> CONFIG_MLX4_EN=3Dm
> CONFIG_MLX4_CORE=3Dm
> CONFIG_MLX4_DEBUG=3Dy
> CONFIG_TEHUTI=3Dm
> CONFIG_BNX2X=3Dm
> CONFIG_QLCNIC=3Dm
> CONFIG_QLGE=3Dm
> CONFIG_BNA=3Dm
> CONFIG_SFC=3Dm
> CONFIG_SFC_MTD=3Dy
> CONFIG_BE2NET=3Dm
> CONFIG_TR=3Dy
> CONFIG_IBMTR=3Dm
> CONFIG_IBMOL=3Dm
> CONFIG_IBMLS=3Dm
> CONFIG_3C359=3Dm
> CONFIG_TMS380TR=3Dm
> CONFIG_TMSPCI=3Dm
> CONFIG_SKISA=3Dm
> CONFIG_PROTEON=3Dm
> CONFIG_ABYSS=3Dm
> CONFIG_MADGEMC=3Dm
> CONFIG_SMCTR=3Dm
> CONFIG_WLAN=3Dy
> CONFIG_PCMCIA_RAYCS=3Dm
> CONFIG_LIBERTAS_THINFIRM=3Dm
> # CONFIG_LIBERTAS_THINFIRM_DEBUG is not set
> CONFIG_LIBERTAS_THINFIRM_USB=3Dm
> CONFIG_AIRO=3Dm
> CONFIG_ATMEL=3Dm
> CONFIG_PCI_ATMEL=3Dm
> CONFIG_PCMCIA_ATMEL=3Dm
> CONFIG_AT76C50X_USB=3Dm
> CONFIG_AIRO_CS=3Dm
> CONFIG_PCMCIA_WL3501=3Dm
> CONFIG_PRISM54=3Dm
> CONFIG_USB_ZD1201=3Dm
> CONFIG_USB_NET_RNDIS_WLAN=3Dm
> CONFIG_RTL8180=3Dm
> CONFIG_RTL8187=3Dm
> CONFIG_RTL8187_LEDS=3Dy
> CONFIG_ADM8211=3Dm
> CONFIG_MAC80211_HWSIM=3Dm
> CONFIG_MWL8K=3Dm
> CONFIG_ATH_COMMON=3Dm
> # CONFIG_ATH_DEBUG is not set
> CONFIG_ATH5K=3Dm
> # CONFIG_ATH5K_DEBUG is not set
> CONFIG_ATH9K_HW=3Dm
> CONFIG_ATH9K_COMMON=3Dm
> CONFIG_ATH9K=3Dm
> # CONFIG_ATH9K_DEBUGFS is not set
> CONFIG_ATH9K_RATE_CONTROL=3Dy
> CONFIG_ATH9K_HTC=3Dm
> # CONFIG_ATH9K_HTC_DEBUGFS is not set
> CONFIG_AR9170_USB=3Dm
> CONFIG_AR9170_LEDS=3Dy
> # CONFIG_CARL9170 is not set
> CONFIG_B43=3Dm
> CONFIG_B43_PCI_AUTOSELECT=3Dy
> CONFIG_B43_PCICORE_AUTOSELECT=3Dy
> CONFIG_B43_PCMCIA=3Dy
> CONFIG_B43_SDIO=3Dy
> CONFIG_B43_PIO=3Dy
> CONFIG_B43_PHY_LP=3Dy
> CONFIG_B43_LEDS=3Dy
> CONFIG_B43_HWRNG=3Dy
> # CONFIG_B43_DEBUG is not set
> CONFIG_B43LEGACY=3Dm
> CONFIG_B43LEGACY_PCI_AUTOSELECT=3Dy
> CONFIG_B43LEGACY_PCICORE_AUTOSELECT=3Dy
> CONFIG_B43LEGACY_LEDS=3Dy
> CONFIG_B43LEGACY_HWRNG=3Dy
> # CONFIG_B43LEGACY_DEBUG is not set
> CONFIG_B43LEGACY_DMA=3Dy
> CONFIG_B43LEGACY_PIO=3Dy
> CONFIG_B43LEGACY_DMA_AND_PIO_MODE=3Dy
> # CONFIG_B43LEGACY_DMA_MODE is not set
> # CONFIG_B43LEGACY_PIO_MODE is not set
> CONFIG_HOSTAP=3Dy
> CONFIG_HOSTAP_FIRMWARE=3Dy
> CONFIG_HOSTAP_FIRMWARE_NVRAM=3Dy
> CONFIG_HOSTAP_PLX=3Dm
> CONFIG_HOSTAP_PCI=3Dm
> CONFIG_HOSTAP_CS=3Dm
> CONFIG_IPW2100=3Dm
> CONFIG_IPW2100_MONITOR=3Dy
> # CONFIG_IPW2100_DEBUG is not set
> CONFIG_IPW2200=3Dm
> CONFIG_IPW2200_MONITOR=3Dy
> CONFIG_IPW2200_RADIOTAP=3Dy
> CONFIG_IPW2200_PROMISCUOUS=3Dy
> CONFIG_IPW2200_QOS=3Dy
> # CONFIG_IPW2200_DEBUG is not set
> CONFIG_LIBIPW=3Dm
> # CONFIG_LIBIPW_DEBUG is not set
> CONFIG_IWLWIFI=3Dm
>=20
> #
> # Debugging Options
> #
> # CONFIG_IWLWIFI_DEBUG is not set
> CONFIG_IWLWIFI_DEVICE_TRACING=3Dy
> CONFIG_IWLAGN=3Dm
> CONFIG_IWL4965=3Dy
> CONFIG_IWL5000=3Dy
> CONFIG_IWL3945=3Dm
> CONFIG_IWM=3Dm
> # CONFIG_IWM_DEBUG is not set
> CONFIG_IWM_TRACING=3Dy
> CONFIG_LIBERTAS=3Dm
> CONFIG_LIBERTAS_USB=3Dm
> CONFIG_LIBERTAS_CS=3Dm
> CONFIG_LIBERTAS_SDIO=3Dm
> CONFIG_LIBERTAS_SPI=3Dm
> # CONFIG_LIBERTAS_DEBUG is not set
> CONFIG_LIBERTAS_MESH=3Dy
> CONFIG_HERMES=3Dm
> CONFIG_HERMES_PRISM=3Dy
> CONFIG_HERMES_CACHE_FW_ON_INIT=3Dy
> CONFIG_PLX_HERMES=3Dm
> CONFIG_TMD_HERMES=3Dm
> CONFIG_NORTEL_HERMES=3Dm
> CONFIG_PCI_HERMES=3Dm
> CONFIG_PCMCIA_HERMES=3Dm
> CONFIG_PCMCIA_SPECTRUM=3Dm
> CONFIG_ORINOCO_USB=3Dm
> CONFIG_P54_COMMON=3Dm
> CONFIG_P54_USB=3Dm
> CONFIG_P54_PCI=3Dm
> CONFIG_P54_SPI=3Dm
> CONFIG_P54_SPI_DEFAULT_EEPROM=3Dy
> CONFIG_P54_LEDS=3Dy
> CONFIG_RT2X00=3Dm
> CONFIG_RT2400PCI=3Dm
> CONFIG_RT2500PCI=3Dm
> CONFIG_RT61PCI=3Dm
> CONFIG_RT2800PCI_PCI=3Dy
> CONFIG_RT2800PCI=3Dm
> CONFIG_RT2800PCI_RT30XX=3Dy
> CONFIG_RT2800PCI_RT35XX=3Dy
> CONFIG_RT2500USB=3Dm
> CONFIG_RT73USB=3Dm
> CONFIG_RT2800USB=3Dm
> CONFIG_RT2800USB_RT30XX=3Dy
> CONFIG_RT2800USB_RT35XX=3Dy
> CONFIG_RT2800USB_UNKNOWN=3Dy
> CONFIG_RT2800_LIB=3Dm
> CONFIG_RT2X00_LIB_PCI=3Dm
> CONFIG_RT2X00_LIB_USB=3Dm
> CONFIG_RT2X00_LIB=3Dm
> CONFIG_RT2X00_LIB_HT=3Dy
> CONFIG_RT2X00_LIB_FIRMWARE=3Dy
> CONFIG_RT2X00_LIB_CRYPTO=3Dy
> CONFIG_RT2X00_LIB_LEDS=3Dy
> # CONFIG_RT2X00_DEBUG is not set
> CONFIG_WL1251=3Dm
> CONFIG_WL1251_SPI=3Dm
> CONFIG_WL1251_SDIO=3Dm
> CONFIG_WL12XX=3Dm
> CONFIG_WL1271=3Dm
> CONFIG_WL1271_SPI=3Dm
> CONFIG_WL1271_SDIO=3Dm
> CONFIG_WL12XX_PLATFORM_DATA=3Dy
> CONFIG_ZD1211RW=3Dm
> # CONFIG_ZD1211RW_DEBUG is not set
>=20
> #
> # WiMAX Wireless Broadband devices
> #
> CONFIG_WIMAX_I2400M=3Dm
> CONFIG_WIMAX_I2400M_USB=3Dm
> CONFIG_WIMAX_I2400M_SDIO=3Dm
> CONFIG_WIMAX_IWMC3200_SDIO=3Dy
> CONFIG_WIMAX_I2400M_DEBUG_LEVEL=3D8
>=20
> #
> # USB Network Adapters
> #
> CONFIG_USB_CATC=3Dm
> CONFIG_USB_KAWETH=3Dm
> CONFIG_USB_PEGASUS=3Dm
> CONFIG_USB_RTL8150=3Dm
> CONFIG_USB_USBNET=3Dm
> CONFIG_USB_NET_AX8817X=3Dm
> CONFIG_USB_NET_CDCETHER=3Dm
> CONFIG_USB_NET_CDC_EEM=3Dm
> CONFIG_USB_NET_DM9601=3Dm
> CONFIG_USB_NET_SMSC75XX=3Dm
> CONFIG_USB_NET_SMSC95XX=3Dm
> CONFIG_USB_NET_GL620A=3Dm
> CONFIG_USB_NET_NET1080=3Dm
> CONFIG_USB_NET_PLUSB=3Dm
> CONFIG_USB_NET_MCS7830=3Dm
> CONFIG_USB_NET_RNDIS_HOST=3Dm
> CONFIG_USB_NET_CDC_SUBSET=3Dm
> CONFIG_USB_ALI_M5632=3Dy
> CONFIG_USB_AN2720=3Dy
> CONFIG_USB_BELKIN=3Dy
> CONFIG_USB_ARMLINUX=3Dy
> CONFIG_USB_EPSON2888=3Dy
> CONFIG_USB_KC2190=3Dy
> CONFIG_USB_NET_ZAURUS=3Dm
> CONFIG_USB_NET_CX82310_ETH=3Dm
> CONFIG_USB_HSO=3Dm
> CONFIG_USB_NET_INT51X1=3Dm
> CONFIG_USB_CDC_PHONET=3Dm
> CONFIG_USB_IPHETH=3Dm
> CONFIG_USB_SIERRA_NET=3Dm
> CONFIG_NET_PCMCIA=3Dy
> CONFIG_PCMCIA_3C589=3Dm
> CONFIG_PCMCIA_3C574=3Dm
> CONFIG_PCMCIA_FMVJ18X=3Dm
> CONFIG_PCMCIA_PCNET=3Dm
> CONFIG_PCMCIA_NMCLAN=3Dm
> CONFIG_PCMCIA_SMC91C92=3Dm
> CONFIG_PCMCIA_XIRC2PS=3Dm
> CONFIG_PCMCIA_AXNET=3Dm
> CONFIG_ARCNET_COM20020_CS=3Dm
> CONFIG_PCMCIA_IBMTR=3Dm
> CONFIG_WAN=3Dy
> CONFIG_HOSTESS_SV11=3Dm
> CONFIG_COSA=3Dm
> CONFIG_LANMEDIA=3Dm
> CONFIG_SEALEVEL_4021=3Dm
> CONFIG_HDLC=3Dm
> CONFIG_HDLC_RAW=3Dm
> CONFIG_HDLC_RAW_ETH=3Dm
> CONFIG_HDLC_CISCO=3Dm
> CONFIG_HDLC_FR=3Dm
> CONFIG_HDLC_PPP=3Dm
> CONFIG_HDLC_X25=3Dm
> CONFIG_PCI200SYN=3Dm
> CONFIG_WANXL=3Dm
> CONFIG_PC300TOO=3Dm
> CONFIG_N2=3Dm
> CONFIG_C101=3Dm
> CONFIG_FARSYNC=3Dm
> CONFIG_DSCC4=3Dm
> CONFIG_DSCC4_PCISYNC=3Dy
> CONFIG_DSCC4_PCI_RST=3Dy
> CONFIG_DLCI=3Dm
> CONFIG_DLCI_MAX=3D8
> CONFIG_SDLA=3Dm
> CONFIG_WAN_ROUTER_DRIVERS=3Dm
> CONFIG_CYCLADES_SYNC=3Dm
> CONFIG_CYCLOMX_X25=3Dy
> CONFIG_LAPBETHER=3Dm
> CONFIG_X25_ASY=3Dm
> CONFIG_SBNI=3Dm
> CONFIG_SBNI_MULTILINE=3Dy
> CONFIG_ATM_DRIVERS=3Dy
> CONFIG_ATM_DUMMY=3Dm
> CONFIG_ATM_TCP=3Dm
> CONFIG_ATM_LANAI=3Dm
> CONFIG_ATM_ENI=3Dm
> # CONFIG_ATM_ENI_DEBUG is not set
> # CONFIG_ATM_ENI_TUNE_BURST is not set
> CONFIG_ATM_FIRESTREAM=3Dm
> CONFIG_ATM_ZATM=3Dm
> # CONFIG_ATM_ZATM_DEBUG is not set
> CONFIG_ATM_NICSTAR=3Dm
> # CONFIG_ATM_NICSTAR_USE_SUNI is not set
> CONFIG_ATM_NICSTAR_USE_IDT77105=3Dy
> CONFIG_ATM_IDT77252=3Dm
> # CONFIG_ATM_IDT77252_DEBUG is not set
> # CONFIG_ATM_IDT77252_RCV_ALL is not set
> CONFIG_ATM_IDT77252_USE_SUNI=3Dy
> CONFIG_ATM_AMBASSADOR=3Dm
> # CONFIG_ATM_AMBASSADOR_DEBUG is not set
> CONFIG_ATM_HORIZON=3Dm
> # CONFIG_ATM_HORIZON_DEBUG is not set
> CONFIG_ATM_IA=3Dm
> # CONFIG_ATM_IA_DEBUG is not set
> CONFIG_ATM_FORE200E=3Dm
> CONFIG_ATM_FORE200E_USE_TASKLET=3Dy
> CONFIG_ATM_FORE200E_TX_RETRY=3D16
> CONFIG_ATM_FORE200E_DEBUG=3D0
> CONFIG_ATM_HE=3Dm
> # CONFIG_ATM_HE_USE_SUNI is not set
> CONFIG_ATM_SOLOS=3Dm
> CONFIG_IEEE802154_DRIVERS=3Dm
> CONFIG_IEEE802154_FAKEHARD=3Dm
>=20
> #
> # CAIF transport drivers
> #
> CONFIG_CAIF_TTY=3Dm
> CONFIG_CAIF_SPI_SLAVE=3Dm
> CONFIG_CAIF_SPI_SYNC=3Dy
> CONFIG_FDDI=3Dy
> CONFIG_DEFXX=3Dm
> # CONFIG_DEFXX_MMIO is not set
> CONFIG_SKFP=3Dm
> CONFIG_HIPPI=3Dy
> CONFIG_ROADRUNNER=3Dm
> # CONFIG_ROADRUNNER_LARGE_RINGS is not set
> CONFIG_PLIP=3Dm
> CONFIG_PPP=3Dy
> CONFIG_PPP_MULTILINK=3Dy
> CONFIG_PPP_FILTER=3Dy
> CONFIG_PPP_ASYNC=3Dy
> CONFIG_PPP_SYNC_TTY=3Dy
> CONFIG_PPP_DEFLATE=3Dy
> CONFIG_PPP_BSDCOMP=3Dy
> CONFIG_PPP_MPPE=3Dy
> CONFIG_PPPOE=3Dy
> CONFIG_PPTP=3Dm
> CONFIG_PPPOATM=3Dm
> CONFIG_PPPOL2TP=3Dm
> CONFIG_SLIP=3Dy
> CONFIG_SLIP_COMPRESSED=3Dy
> CONFIG_SLHC=3Dy
> CONFIG_SLIP_SMART=3Dy
> CONFIG_SLIP_MODE_SLIP6=3Dy
> CONFIG_NET_FC=3Dy
> CONFIG_NETCONSOLE=3Dm
> CONFIG_NETCONSOLE_DYNAMIC=3Dy
> CONFIG_NETPOLL=3Dy
> # CONFIG_NETPOLL_TRAP is not set
> CONFIG_NET_POLL_CONTROLLER=3Dy
> CONFIG_VIRTIO_NET=3Dm
> CONFIG_VMXNET3=3Dm
> CONFIG_ISDN=3Dy
> CONFIG_ISDN_I4L=3Dm
> CONFIG_ISDN_PPP=3Dy
> CONFIG_ISDN_PPP_VJ=3Dy
> CONFIG_ISDN_MPP=3Dy
> CONFIG_IPPP_FILTER=3Dy
> CONFIG_ISDN_PPP_BSDCOMP=3Dm
> CONFIG_ISDN_AUDIO=3Dy
> CONFIG_ISDN_TTY_FAX=3Dy
> CONFIG_ISDN_X25=3Dy
>=20
> #
> # ISDN feature submodules
> #
> CONFIG_ISDN_DIVERSION=3Dm
>=20
> #
> # ISDN4Linux hardware drivers
> #
>=20
> #
> # Passive cards
> #
> CONFIG_ISDN_DRV_HISAX=3Dm
>=20
> #
> # D-channel protocol features
> #
> CONFIG_HISAX_EURO=3Dy
> CONFIG_DE_AOC=3Dy
> CONFIG_HISAX_NO_SENDCOMPLETE=3Dy
> CONFIG_HISAX_NO_LLC=3Dy
> CONFIG_HISAX_NO_KEYPAD=3Dy
> CONFIG_HISAX_1TR6=3Dy
> CONFIG_HISAX_NI1=3Dy
> CONFIG_HISAX_MAX_CARDS=3D8
>=20
> #
> # HiSax supported cards
> #
> CONFIG_HISAX_16_0=3Dy
> CONFIG_HISAX_16_3=3Dy
> CONFIG_HISAX_TELESPCI=3Dy
> CONFIG_HISAX_S0BOX=3Dy
> CONFIG_HISAX_AVM_A1=3Dy
> CONFIG_HISAX_FRITZPCI=3Dy
> CONFIG_HISAX_AVM_A1_PCMCIA=3Dy
> CONFIG_HISAX_ELSA=3Dy
> CONFIG_HISAX_IX1MICROR2=3Dy
> CONFIG_HISAX_DIEHLDIVA=3Dy
> CONFIG_HISAX_ASUSCOM=3Dy
> CONFIG_HISAX_TELEINT=3Dy
> CONFIG_HISAX_HFCS=3Dy
> CONFIG_HISAX_SEDLBAUER=3Dy
> CONFIG_HISAX_SPORTSTER=3Dy
> CONFIG_HISAX_MIC=3Dy
> CONFIG_HISAX_NETJET=3Dy
> CONFIG_HISAX_NETJET_U=3Dy
> CONFIG_HISAX_NICCY=3Dy
> CONFIG_HISAX_ISURF=3Dy
> CONFIG_HISAX_HSTSAPHIR=3Dy
> CONFIG_HISAX_BKM_A4T=3Dy
> CONFIG_HISAX_SCT_QUADRO=3Dy
> CONFIG_HISAX_GAZEL=3Dy
> CONFIG_HISAX_HFC_PCI=3Dy
> CONFIG_HISAX_W6692=3Dy
> CONFIG_HISAX_HFC_SX=3Dy
> CONFIG_HISAX_ENTERNOW_PCI=3Dy
> # CONFIG_HISAX_DEBUG is not set
>=20
> #
> # HiSax PCMCIA card service modules
> #
> CONFIG_HISAX_SEDLBAUER_CS=3Dm
> CONFIG_HISAX_ELSA_CS=3Dm
> CONFIG_HISAX_AVM_A1_CS=3Dm
> CONFIG_HISAX_TELES_CS=3Dm
>=20
> #
> # HiSax sub driver modules
> #
> CONFIG_HISAX_ST5481=3Dm
> CONFIG_HISAX_HFCUSB=3Dm
> CONFIG_HISAX_HFC4S8S=3Dm
> CONFIG_HISAX_FRITZ_PCIPNP=3Dm
>=20
> #
> # Active cards
> #
> CONFIG_ISDN_DRV_ICN=3Dm
> CONFIG_ISDN_DRV_PCBIT=3Dm
> CONFIG_ISDN_DRV_SC=3Dm
> CONFIG_ISDN_DRV_ACT2000=3Dm
> CONFIG_ISDN_CAPI=3Dm
> CONFIG_ISDN_DRV_AVMB1_VERBOSE_REASON=3Dy
> CONFIG_CAPI_TRACE=3Dy
> CONFIG_ISDN_CAPI_MIDDLEWARE=3Dy
> CONFIG_ISDN_CAPI_CAPI20=3Dm
> CONFIG_ISDN_CAPI_CAPIFS_BOOL=3Dy
> CONFIG_ISDN_CAPI_CAPIFS=3Dm
> CONFIG_ISDN_CAPI_CAPIDRV=3Dm
>=20
> #
> # CAPI hardware drivers
> #
> CONFIG_CAPI_AVM=3Dy
> CONFIG_ISDN_DRV_AVMB1_B1ISA=3Dm
> CONFIG_ISDN_DRV_AVMB1_B1PCI=3Dm
> CONFIG_ISDN_DRV_AVMB1_B1PCIV4=3Dy
> CONFIG_ISDN_DRV_AVMB1_T1ISA=3Dm
> CONFIG_ISDN_DRV_AVMB1_B1PCMCIA=3Dm
> CONFIG_ISDN_DRV_AVMB1_AVM_CS=3Dm
> CONFIG_ISDN_DRV_AVMB1_T1PCI=3Dm
> CONFIG_ISDN_DRV_AVMB1_C4=3Dm
> CONFIG_CAPI_EICON=3Dy
> CONFIG_ISDN_DIVAS=3Dm
> CONFIG_ISDN_DIVAS_BRIPCI=3Dy
> CONFIG_ISDN_DIVAS_PRIPCI=3Dy
> CONFIG_ISDN_DIVAS_DIVACAPI=3Dm
> CONFIG_ISDN_DIVAS_USERIDI=3Dm
> CONFIG_ISDN_DIVAS_MAINT=3Dm
> CONFIG_ISDN_DRV_GIGASET=3Dm
> CONFIG_GIGASET_CAPI=3Dy
> # CONFIG_GIGASET_I4L is not set
> # CONFIG_GIGASET_DUMMYLL is not set
> CONFIG_GIGASET_BASE=3Dm
> CONFIG_GIGASET_M105=3Dm
> CONFIG_GIGASET_M101=3Dm
> # CONFIG_GIGASET_DEBUG is not set
> CONFIG_HYSDN=3Dm
> CONFIG_HYSDN_CAPI=3Dy
> CONFIG_MISDN=3Dm
> CONFIG_MISDN_DSP=3Dm
> CONFIG_MISDN_L1OIP=3Dm
>=20
> #
> # mISDN hardware drivers
> #
> CONFIG_MISDN_HFCPCI=3Dm
> CONFIG_MISDN_HFCMULTI=3Dm
> CONFIG_MISDN_HFCUSB=3Dm
> CONFIG_MISDN_AVMFRITZ=3Dm
> CONFIG_MISDN_SPEEDFAX=3Dm
> CONFIG_MISDN_INFINEON=3Dm
> CONFIG_MISDN_W6692=3Dm
> CONFIG_MISDN_NETJET=3Dm
> CONFIG_MISDN_IPAC=3Dm
> CONFIG_MISDN_ISAR=3Dm
> CONFIG_ISDN_HDLC=3Dm
> CONFIG_PHONE=3Dm
> CONFIG_PHONE_IXJ=3Dm
> CONFIG_PHONE_IXJ_PCMCIA=3Dm
>=20
> #
> # Input device support
> #
> CONFIG_INPUT=3Dy
> CONFIG_INPUT_FF_MEMLESS=3Dy
> CONFIG_INPUT_POLLDEV=3Dy
> CONFIG_INPUT_SPARSEKMAP=3Dy
>=20
> #
> # Userland interfaces
> #
> CONFIG_INPUT_MOUSEDEV=3Dy
> CONFIG_INPUT_MOUSEDEV_PSAUX=3Dy
> CONFIG_INPUT_MOUSEDEV_SCREEN_X=3D1024
> CONFIG_INPUT_MOUSEDEV_SCREEN_Y=3D768
> CONFIG_INPUT_JOYDEV=3Dy
> CONFIG_INPUT_EVDEV=3Dy
> # CONFIG_INPUT_EVBUG is not set
>=20
> #
> # Input Device Drivers
> #
> CONFIG_INPUT_KEYBOARD=3Dy
> CONFIG_KEYBOARD_ADP5520=3Dy
> CONFIG_KEYBOARD_ADP5588=3Dy
> CONFIG_KEYBOARD_ATKBD=3Dy
> CONFIG_KEYBOARD_QT2160=3Dy
> CONFIG_KEYBOARD_LKKBD=3Dy
> CONFIG_KEYBOARD_GPIO=3Dy
> CONFIG_KEYBOARD_TCA6416=3Dy
> CONFIG_KEYBOARD_MATRIX=3Dy
> CONFIG_KEYBOARD_LM8323=3Dm
> CONFIG_KEYBOARD_MAX7359=3Dy
> CONFIG_KEYBOARD_MCS=3Dy
> CONFIG_KEYBOARD_NEWTON=3Dy
> CONFIG_KEYBOARD_OPENCORES=3Dy
> CONFIG_KEYBOARD_STOWAWAY=3Dy
> CONFIG_KEYBOARD_SUNKBD=3Dy
> CONFIG_KEYBOARD_STMPE=3Dy
> CONFIG_KEYBOARD_TWL4030=3Dy
> CONFIG_KEYBOARD_XTKBD=3Dy
> CONFIG_INPUT_MOUSE=3Dy
> CONFIG_MOUSE_PS2=3Dy
> CONFIG_MOUSE_PS2_ALPS=3Dy
> CONFIG_MOUSE_PS2_LOGIPS2PP=3Dy
> CONFIG_MOUSE_PS2_SYNAPTICS=3Dy
> CONFIG_MOUSE_PS2_LIFEBOOK=3Dy
> CONFIG_MOUSE_PS2_TRACKPOINT=3Dy
> CONFIG_MOUSE_PS2_ELANTECH=3Dy
> CONFIG_MOUSE_PS2_SENTELIC=3Dy
> CONFIG_MOUSE_PS2_TOUCHKIT=3Dy
> CONFIG_MOUSE_PS2_OLPC=3Dy
> CONFIG_MOUSE_SERIAL=3Dy
> CONFIG_MOUSE_APPLETOUCH=3Dy
> CONFIG_MOUSE_BCM5974=3Dy
> CONFIG_MOUSE_INPORT=3Dy
> CONFIG_MOUSE_ATIXL=3Dy
> CONFIG_MOUSE_LOGIBM=3Dy
> CONFIG_MOUSE_PC110PAD=3Dy
> CONFIG_MOUSE_VSXXXAA=3Dy
> CONFIG_MOUSE_GPIO=3Dy
> CONFIG_MOUSE_SYNAPTICS_I2C=3Dy
> CONFIG_INPUT_JOYSTICK=3Dy
> CONFIG_JOYSTICK_ANALOG=3Dy
> CONFIG_JOYSTICK_A3D=3Dm
> CONFIG_JOYSTICK_ADI=3Dm
> CONFIG_JOYSTICK_COBRA=3Dm
> CONFIG_JOYSTICK_GF2K=3Dm
> CONFIG_JOYSTICK_GRIP=3Dm
> CONFIG_JOYSTICK_GRIP_MP=3Dm
> CONFIG_JOYSTICK_GUILLEMOT=3Dm
> CONFIG_JOYSTICK_INTERACT=3Dm
> CONFIG_JOYSTICK_SIDEWINDER=3Dm
> CONFIG_JOYSTICK_TMDC=3Dm
> CONFIG_JOYSTICK_IFORCE=3Dm
> CONFIG_JOYSTICK_IFORCE_USB=3Dy
> CONFIG_JOYSTICK_IFORCE_232=3Dy
> CONFIG_JOYSTICK_WARRIOR=3Dm
> CONFIG_JOYSTICK_MAGELLAN=3Dm
> CONFIG_JOYSTICK_SPACEORB=3Dm
> CONFIG_JOYSTICK_SPACEBALL=3Dm
> CONFIG_JOYSTICK_STINGER=3Dm
> CONFIG_JOYSTICK_TWIDJOY=3Dm
> CONFIG_JOYSTICK_ZHENHUA=3Dm
> CONFIG_JOYSTICK_DB9=3Dm
> CONFIG_JOYSTICK_GAMECON=3Dm
> CONFIG_JOYSTICK_TURBOGRAFX=3Dm
> CONFIG_JOYSTICK_JOYDUMP=3Dm
> CONFIG_JOYSTICK_XPAD=3Dm
> CONFIG_JOYSTICK_XPAD_FF=3Dy
> CONFIG_JOYSTICK_XPAD_LEDS=3Dy
> CONFIG_JOYSTICK_WALKERA0701=3Dm
> CONFIG_INPUT_TABLET=3Dy
> CONFIG_TABLET_USB_ACECAD=3Dy
> CONFIG_TABLET_USB_AIPTEK=3Dy
> CONFIG_TABLET_USB_GTCO=3Dy
> CONFIG_TABLET_USB_HANWANG=3Dy
> CONFIG_TABLET_USB_KBTAB=3Dy
> CONFIG_TABLET_USB_WACOM=3Dy
> CONFIG_INPUT_TOUCHSCREEN=3Dy
> CONFIG_TOUCHSCREEN_88PM860X=3Dm
> CONFIG_TOUCHSCREEN_ADS7846=3Dm
> CONFIG_TOUCHSCREEN_AD7877=3Dm
> CONFIG_TOUCHSCREEN_AD7879=3Dm
> CONFIG_TOUCHSCREEN_AD7879_I2C=3Dm
> CONFIG_TOUCHSCREEN_AD7879_SPI=3Dm
> CONFIG_TOUCHSCREEN_BU21013=3Dm
> CONFIG_TOUCHSCREEN_CY8CTMG110=3Dm
> CONFIG_TOUCHSCREEN_DA9034=3Dy
> CONFIG_TOUCHSCREEN_DYNAPRO=3Dm
> CONFIG_TOUCHSCREEN_HAMPSHIRE=3Dm
> CONFIG_TOUCHSCREEN_EETI=3Dm
> CONFIG_TOUCHSCREEN_FUJITSU=3Dm
> CONFIG_TOUCHSCREEN_GUNZE=3Dm
> CONFIG_TOUCHSCREEN_ELO=3Dm
> CONFIG_TOUCHSCREEN_WACOM_W8001=3Dm
> CONFIG_TOUCHSCREEN_MCS5000=3Dm
> CONFIG_TOUCHSCREEN_MTOUCH=3Dm
> CONFIG_TOUCHSCREEN_INEXIO=3Dm
> CONFIG_TOUCHSCREEN_MK712=3Dm
> CONFIG_TOUCHSCREEN_HTCPEN=3Dm
> CONFIG_TOUCHSCREEN_PENMOUNT=3Dm
> CONFIG_TOUCHSCREEN_QT602240=3Dm
> CONFIG_TOUCHSCREEN_TOUCHRIGHT=3Dm
> CONFIG_TOUCHSCREEN_TOUCHWIN=3Dm
> CONFIG_TOUCHSCREEN_UCB1400=3Dm
> CONFIG_TOUCHSCREEN_WM97XX=3Dm
> CONFIG_TOUCHSCREEN_WM9705=3Dy
> CONFIG_TOUCHSCREEN_WM9712=3Dy
> CONFIG_TOUCHSCREEN_WM9713=3Dy
> CONFIG_TOUCHSCREEN_USB_COMPOSITE=3Dm
> CONFIG_TOUCHSCREEN_MC13783=3Dm
> CONFIG_TOUCHSCREEN_USB_EGALAX=3Dy
> CONFIG_TOUCHSCREEN_USB_PANJIT=3Dy
> CONFIG_TOUCHSCREEN_USB_3M=3Dy
> CONFIG_TOUCHSCREEN_USB_ITM=3Dy
> CONFIG_TOUCHSCREEN_USB_ETURBO=3Dy
> CONFIG_TOUCHSCREEN_USB_GUNZE=3Dy
> CONFIG_TOUCHSCREEN_USB_DMC_TSC10=3Dy
> CONFIG_TOUCHSCREEN_USB_IRTOUCH=3Dy
> CONFIG_TOUCHSCREEN_USB_IDEALTEK=3Dy
> CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH=3Dy
> CONFIG_TOUCHSCREEN_USB_GOTOP=3Dy
> CONFIG_TOUCHSCREEN_USB_JASTEC=3Dy
> CONFIG_TOUCHSCREEN_USB_E2I=3Dy
> CONFIG_TOUCHSCREEN_USB_ZYTRONIC=3Dy
> CONFIG_TOUCHSCREEN_USB_ETT_TC45USB=3Dy
> CONFIG_TOUCHSCREEN_USB_NEXIO=3Dy
> CONFIG_TOUCHSCREEN_TOUCHIT213=3Dm
> CONFIG_TOUCHSCREEN_TSC2007=3Dm
> CONFIG_TOUCHSCREEN_PCAP=3Dm
> CONFIG_TOUCHSCREEN_TPS6507X=3Dm
> CONFIG_TOUCHSCREEN_STMPE=3Dm
> CONFIG_INPUT_MISC=3Dy
> CONFIG_INPUT_88PM860X_ONKEY=3Dm
> CONFIG_INPUT_AD714X=3Dm
> CONFIG_INPUT_AD714X_I2C=3Dm
> CONFIG_INPUT_AD714X_SPI=3Dm
> CONFIG_INPUT_PCSPKR=3Dy
> CONFIG_INPUT_MAX8925_ONKEY=3Dm
> CONFIG_INPUT_APANEL=3Dm
> CONFIG_INPUT_WISTRON_BTNS=3Dm
> CONFIG_INPUT_ATLAS_BTNS=3Dm
> CONFIG_INPUT_ATI_REMOTE=3Dm
> CONFIG_INPUT_ATI_REMOTE2=3Dm
> CONFIG_INPUT_KEYSPAN_REMOTE=3Dm
> CONFIG_INPUT_POWERMATE=3Dm
> CONFIG_INPUT_YEALINK=3Dm
> CONFIG_INPUT_CM109=3Dm
> CONFIG_INPUT_TWL4030_PWRBUTTON=3Dm
> CONFIG_INPUT_TWL4030_VIBRA=3Dm
> CONFIG_INPUT_UINPUT=3Dm
> CONFIG_INPUT_WINBOND_CIR=3Dm
> CONFIG_INPUT_PCF50633_PMU=3Dm
> CONFIG_INPUT_PCF8574=3Dm
> CONFIG_INPUT_GPIO_ROTARY_ENCODER=3Dm
> CONFIG_INPUT_WM831X_ON=3Dm
> CONFIG_INPUT_PCAP=3Dm
> CONFIG_INPUT_ADXL34X=3Dm
> CONFIG_INPUT_ADXL34X_I2C=3Dm
> CONFIG_INPUT_ADXL34X_SPI=3Dm
>=20
> #
> # Hardware I/O ports
> #
> CONFIG_SERIO=3Dy
> CONFIG_SERIO_I8042=3Dy
> CONFIG_SERIO_SERPORT=3Dy
> CONFIG_SERIO_CT82C710=3Dy
> CONFIG_SERIO_PARKBD=3Dy
> CONFIG_SERIO_PCIPS2=3Dy
> CONFIG_SERIO_LIBPS2=3Dy
> CONFIG_SERIO_RAW=3Dy
> CONFIG_SERIO_ALTERA_PS2=3Dy
> CONFIG_SERIO_PS2MULT=3Dy
> CONFIG_GAMEPORT=3Dy
> CONFIG_GAMEPORT_NS558=3Dy
> CONFIG_GAMEPORT_L4=3Dy
> CONFIG_GAMEPORT_EMU10K1=3Dy
> CONFIG_GAMEPORT_FM801=3Dy
>=20
> #
> # Character devices
> #
> CONFIG_VT=3Dy
> CONFIG_CONSOLE_TRANSLATIONS=3Dy
> CONFIG_VT_CONSOLE=3Dy
> CONFIG_HW_CONSOLE=3Dy
> CONFIG_VT_HW_CONSOLE_BINDING=3Dy
> CONFIG_DEVKMEM=3Dy
> CONFIG_SERIAL_NONSTANDARD=3Dy
> CONFIG_COMPUTONE=3Dm
> CONFIG_ROCKETPORT=3Dm
> CONFIG_CYCLADES=3Dm
> CONFIG_CYZ_INTR=3Dy
> CONFIG_DIGIEPCA=3Dm
> CONFIG_MOXA_INTELLIO=3Dm
> CONFIG_MOXA_SMARTIO=3Dm
> CONFIG_ISI=3Dm
> CONFIG_SYNCLINK=3Dm
> CONFIG_SYNCLINKMP=3Dm
> CONFIG_SYNCLINK_GT=3Dm
> CONFIG_N_HDLC=3Dm
> CONFIG_N_GSM=3Dm
> CONFIG_RISCOM8=3Dm
> CONFIG_SPECIALIX=3Dm
> CONFIG_STALDRV=3Dy
> CONFIG_STALLION=3Dm
> CONFIG_ISTALLION=3Dm
> CONFIG_NOZOMI=3Dm
>=20
> #
> # Serial drivers
> #
> CONFIG_SERIAL_8250=3Dy
> CONFIG_SERIAL_8250_CONSOLE=3Dy
> CONFIG_FIX_EARLYCON_MEM=3Dy
> CONFIG_SERIAL_8250_PCI=3Dy
> CONFIG_SERIAL_8250_PNP=3Dy
> CONFIG_SERIAL_8250_CS=3Dm
> CONFIG_SERIAL_8250_NR_UARTS=3D4
> CONFIG_SERIAL_8250_RUNTIME_UARTS=3D4
> CONFIG_SERIAL_8250_EXTENDED=3Dy
> CONFIG_SERIAL_8250_MANY_PORTS=3Dy
> CONFIG_SERIAL_8250_FOURPORT=3Dm
> CONFIG_SERIAL_8250_ACCENT=3Dm
> CONFIG_SERIAL_8250_BOCA=3Dm
> CONFIG_SERIAL_8250_EXAR_ST16C554=3Dm
> CONFIG_SERIAL_8250_HUB6=3Dm
> CONFIG_SERIAL_8250_SHARE_IRQ=3Dy
> CONFIG_SERIAL_8250_DETECT_IRQ=3Dy
> CONFIG_SERIAL_8250_RSA=3Dy
> CONFIG_SERIAL_8250_MCA=3Dm
>=20
> #
> # Non-8250 serial port support
> #
> CONFIG_SERIAL_MAX3100=3Dm
> CONFIG_SERIAL_MAX3107=3Dm
> CONFIG_SERIAL_MRST_MAX3110=3Dm
> CONFIG_SERIAL_MFD_HSU=3Dm
> CONFIG_SERIAL_UARTLITE=3Dm
> CONFIG_SERIAL_CORE=3Dy
> CONFIG_SERIAL_CORE_CONSOLE=3Dy
> CONFIG_SERIAL_JSM=3Dm
> CONFIG_SERIAL_TIMBERDALE=3Dm
> CONFIG_SERIAL_ALTERA_JTAGUART=3Dm
> CONFIG_SERIAL_ALTERA_UART=3Dm
> CONFIG_SERIAL_ALTERA_UART_MAXPORTS=3D4
> CONFIG_SERIAL_ALTERA_UART_BAUDRATE=3D115200
> CONFIG_UNIX98_PTYS=3Dy
> CONFIG_DEVPTS_MULTIPLE_INSTANCES=3Dy
> CONFIG_LEGACY_PTYS=3Dy
> CONFIG_LEGACY_PTY_COUNT=3D256
> # CONFIG_TTY_PRINTK is not set
> CONFIG_PRINTER=3Dm
> CONFIG_LP_CONSOLE=3Dy
> CONFIG_PPDEV=3Dm
> CONFIG_HVC_DRIVER=3Dy
> CONFIG_VIRTIO_CONSOLE=3Dy
> CONFIG_IPMI_HANDLER=3Dm
> # CONFIG_IPMI_PANIC_EVENT is not set
> CONFIG_IPMI_DEVICE_INTERFACE=3Dm
> CONFIG_IPMI_SI=3Dm
> CONFIG_IPMI_WATCHDOG=3Dm
> CONFIG_IPMI_POWEROFF=3Dm
> CONFIG_HW_RANDOM=3Dy
> CONFIG_HW_RANDOM_TIMERIOMEM=3Dm
> CONFIG_HW_RANDOM_INTEL=3Dm
> CONFIG_HW_RANDOM_AMD=3Dm
> CONFIG_HW_RANDOM_GEODE=3Dm
> CONFIG_HW_RANDOM_VIA=3Dm
> CONFIG_HW_RANDOM_VIRTIO=3Dm
> CONFIG_NVRAM=3Dy
> CONFIG_DTLK=3Dm
> CONFIG_R3964=3Dm
> CONFIG_APPLICOM=3Dm
> CONFIG_SONYPI=3Dm
>=20
> #
> # PCMCIA character devices
> #
> CONFIG_SYNCLINK_CS=3Dm
> CONFIG_CARDMAN_4000=3Dm
> CONFIG_CARDMAN_4040=3Dm
> CONFIG_IPWIRELESS=3Dm
> CONFIG_MWAVE=3Dm
> CONFIG_SCx200_GPIO=3Dm
> CONFIG_PC8736x_GPIO=3Dm
> CONFIG_NSC_GPIO=3Dm
> CONFIG_CS5535_GPIO=3Dm
> CONFIG_RAW_DRIVER=3Dm
> CONFIG_MAX_RAW_DEVS=3D256
> CONFIG_HPET=3Dy
> CONFIG_HPET_MMAP=3Dy
> CONFIG_HANGCHECK_TIMER=3Dm
> CONFIG_TCG_TPM=3Dm
> CONFIG_TCG_TIS=3Dm
> CONFIG_TCG_NSC=3Dm
> CONFIG_TCG_ATMEL=3Dm
> CONFIG_TCG_INFINEON=3Dm
> CONFIG_TELCLOCK=3Dm
> CONFIG_DEVPORT=3Dy
> CONFIG_RAMOOPS=3Dm
> CONFIG_I2C=3Dy
> CONFIG_I2C_BOARDINFO=3Dy
> CONFIG_I2C_COMPAT=3Dy
> CONFIG_I2C_CHARDEV=3Dy
> CONFIG_I2C_MUX=3Dm
>=20
> #
> # Multiplexer I2C Chip support
> #
> CONFIG_I2C_MUX_PCA9541=3Dm
> CONFIG_I2C_MUX_PCA954x=3Dm
> CONFIG_I2C_HELPER_AUTO=3Dy
> CONFIG_I2C_SMBUS=3Dm
> CONFIG_I2C_ALGOBIT=3Dy
> CONFIG_I2C_ALGOPCA=3Dm
>=20
> #
> # I2C Hardware Bus support
> #
>=20
> #
> # PC SMBus host controller drivers
> #
> CONFIG_I2C_ALI1535=3Dm
> CONFIG_I2C_ALI1563=3Dm
> CONFIG_I2C_ALI15X3=3Dm
> CONFIG_I2C_AMD756=3Dm
> CONFIG_I2C_AMD756_S4882=3Dm
> CONFIG_I2C_AMD8111=3Dm
> CONFIG_I2C_I801=3Dm
> CONFIG_I2C_ISCH=3Dm
> CONFIG_I2C_PIIX4=3Dm
> CONFIG_I2C_NFORCE2=3Dm
> CONFIG_I2C_NFORCE2_S4985=3Dm
> CONFIG_I2C_SIS5595=3Dm
> CONFIG_I2C_SIS630=3Dm
> CONFIG_I2C_SIS96X=3Dm
> CONFIG_I2C_VIA=3Dm
> CONFIG_I2C_VIAPRO=3Dm
>=20
> #
> # ACPI drivers
> #
> CONFIG_I2C_SCMI=3Dm
>=20
> #
> # I2C system bus drivers (mostly embedded /=20
> system-on-chip)
> #
> CONFIG_I2C_GPIO=3Dm
> # CONFIG_I2C_INTEL_MID is not set
> CONFIG_I2C_OCORES=3Dm
> CONFIG_I2C_PCA_PLATFORM=3Dm
> CONFIG_I2C_SIMTEC=3Dm
> CONFIG_I2C_XILINX=3Dm
>=20
> #
> # External I2C/SMBus adapter drivers
> #
> CONFIG_I2C_PARPORT=3Dm
> CONFIG_I2C_PARPORT_LIGHT=3Dm
> CONFIG_I2C_TAOS_EVM=3Dm
> CONFIG_I2C_TINY_USB=3Dm
>=20
> #
> # Other I2C/SMBus bus drivers
> #
> CONFIG_I2C_PCA_ISA=3Dm
> CONFIG_I2C_STUB=3Dm
> CONFIG_SCx200_I2C=3Dm
> CONFIG_SCx200_I2C_SCL=3D12
> CONFIG_SCx200_I2C_SDA=3D13
> CONFIG_SCx200_ACB=3Dm
> # CONFIG_I2C_DEBUG_CORE is not set
> # CONFIG_I2C_DEBUG_ALGO is not set
> # CONFIG_I2C_DEBUG_BUS is not set
> CONFIG_SPI=3Dy
> CONFIG_SPI_MASTER=3Dy
>=20
> #
> # SPI Master Controller Drivers
> #
> CONFIG_SPI_BITBANG=3Dm
> CONFIG_SPI_BUTTERFLY=3Dm
> CONFIG_SPI_GPIO=3Dm
> CONFIG_SPI_LM70_LLP=3Dm
> CONFIG_SPI_TOPCLIFF_PCH=3Dm
> CONFIG_SPI_XILINX=3Dm
> CONFIG_SPI_XILINX_PLTFM=3Dm
> CONFIG_SPI_DESIGNWARE=3Dy
> CONFIG_SPI_DW_PCI=3Dm
>=20
> #
> # SPI Protocol Masters
> #
> CONFIG_SPI_SPIDEV=3Dm
> CONFIG_SPI_TLE62X0=3Dm
>=20
> #
> # PPS support
> #
> CONFIG_PPS=3Dm
> # CONFIG_PPS_DEBUG is not set
>=20
> #
> # PPS clients support
> #
> CONFIG_PPS_CLIENT_KTIMER=3Dm
> CONFIG_PPS_CLIENT_LDISC=3Dm
> CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=3Dy
> CONFIG_GPIOLIB=3Dy
> CONFIG_GPIO_SYSFS=3Dy
> CONFIG_GPIO_MAX730X=3Dm
>=20
> #
> # Memory mapped GPIO expanders:
> #
> CONFIG_GPIO_BASIC_MMIO=3Dm
> CONFIG_GPIO_IT8761E=3Dm
> CONFIG_GPIO_SCH=3Dm
> CONFIG_GPIO_VX855=3Dm
>=20
> #
> # I2C GPIO expanders:
> #
> CONFIG_GPIO_MAX7300=3Dm
> CONFIG_GPIO_MAX732X=3Dm
> CONFIG_GPIO_PCA953X=3Dm
> CONFIG_GPIO_PCF857X=3Dm
> CONFIG_GPIO_SX150X=3Dy
> CONFIG_GPIO_STMPE=3Dy
> CONFIG_GPIO_TC35892=3Dy
> CONFIG_GPIO_TWL4030=3Dm
> CONFIG_GPIO_WM831X=3Dm
> CONFIG_GPIO_WM8350=3Dm
> CONFIG_GPIO_WM8994=3Dm
> CONFIG_GPIO_ADP5520=3Dm
> CONFIG_GPIO_ADP5588=3Dm
>=20
> #
> # PCI GPIO expanders:
> #
> CONFIG_GPIO_CS5535=3Dm
> CONFIG_GPIO_LANGWELL=3Dy
> CONFIG_GPIO_PCH=3Dm
> CONFIG_GPIO_TIMBERDALE=3Dy
> CONFIG_GPIO_RDC321X=3Dm
>=20
> #
> # SPI GPIO expanders:
> #
> CONFIG_GPIO_MAX7301=3Dm
> CONFIG_GPIO_MCP23S08=3Dm
> CONFIG_GPIO_MC33880=3Dm
> CONFIG_GPIO_74X164=3Dm
>=20
> #
> # AC97 GPIO expanders:
> #
> CONFIG_GPIO_UCB1400=3Dy
>=20
> #
> # MODULbus GPIO expanders:
> #
> CONFIG_GPIO_JANZ_TTL=3Dm
> CONFIG_W1=3Dm
> CONFIG_W1_CON=3Dy
>=20
> #
> # 1-wire Bus Masters
> #
> CONFIG_W1_MASTER_MATROX=3Dm
> CONFIG_W1_MASTER_DS2490=3Dm
> CONFIG_W1_MASTER_DS2482=3Dm
> CONFIG_W1_MASTER_GPIO=3Dm
>=20
> #
> # 1-wire Slaves
> #
> CONFIG_W1_SLAVE_THERM=3Dm
> CONFIG_W1_SLAVE_SMEM=3Dm
> CONFIG_W1_SLAVE_DS2431=3Dm
> CONFIG_W1_SLAVE_DS2433=3Dm
> CONFIG_W1_SLAVE_DS2433_CRC=3Dy
> CONFIG_W1_SLAVE_DS2760=3Dm
> CONFIG_W1_SLAVE_BQ27000=3Dm
> CONFIG_POWER_SUPPLY=3Dy
> # CONFIG_POWER_SUPPLY_DEBUG is not set
> CONFIG_PDA_POWER=3Dm
> CONFIG_MAX8925_POWER=3Dm
> CONFIG_WM831X_BACKUP=3Dm
> CONFIG_WM831X_POWER=3Dm
> CONFIG_WM8350_POWER=3Dm
> # CONFIG_TEST_POWER is not set
> CONFIG_BATTERY_DS2760=3Dm
> CONFIG_BATTERY_DS2782=3Dm
> CONFIG_BATTERY_OLPC=3Dm
> CONFIG_BATTERY_BQ20Z75=3Dm
> CONFIG_BATTERY_BQ27x00=3Dm
> CONFIG_BATTERY_DA9030=3Dm
> CONFIG_BATTERY_MAX17040=3Dm
> CONFIG_CHARGER_PCF50633=3Dm
> CONFIG_CHARGER_ISP1704=3Dm
> CONFIG_CHARGER_TWL4030=3Dm
> CONFIG_HWMON=3Dy
> CONFIG_HWMON_VID=3Dm
> # CONFIG_HWMON_DEBUG_CHIP is not set
>=20
> #
> # Native drivers
> #
> CONFIG_SENSORS_ABITUGURU=3Dm
> CONFIG_SENSORS_ABITUGURU3=3Dm
> CONFIG_SENSORS_AD7414=3Dm
> CONFIG_SENSORS_AD7418=3Dm
> CONFIG_SENSORS_ADCXX=3Dm
> CONFIG_SENSORS_ADM1021=3Dm
> CONFIG_SENSORS_ADM1025=3Dm
> CONFIG_SENSORS_ADM1026=3Dm
> CONFIG_SENSORS_ADM1029=3Dm
> CONFIG_SENSORS_ADM1031=3Dm
> CONFIG_SENSORS_ADM9240=3Dm
> CONFIG_SENSORS_ADT7411=3Dm
> CONFIG_SENSORS_ADT7462=3Dm
> CONFIG_SENSORS_ADT7470=3Dm
> CONFIG_SENSORS_ADT7475=3Dm
> CONFIG_SENSORS_ASC7621=3Dm
> CONFIG_SENSORS_K8TEMP=3Dm
> CONFIG_SENSORS_K10TEMP=3Dm
> CONFIG_SENSORS_ASB100=3Dm
> CONFIG_SENSORS_ATXP1=3Dm
> CONFIG_SENSORS_DS1621=3Dm
> CONFIG_SENSORS_I5K_AMB=3Dm
> CONFIG_SENSORS_F71805F=3Dm
> CONFIG_SENSORS_F71882FG=3Dm
> CONFIG_SENSORS_F75375S=3Dm
> CONFIG_SENSORS_FSCHMD=3Dm
> CONFIG_SENSORS_G760A=3Dm
> CONFIG_SENSORS_GL518SM=3Dm
> CONFIG_SENSORS_GL520SM=3Dm
> CONFIG_SENSORS_GPIO_FAN=3Dm
> CONFIG_SENSORS_CORETEMP=3Dm
> CONFIG_SENSORS_PKGTEMP=3Dm
> CONFIG_SENSORS_IBMAEM=3Dm
> CONFIG_SENSORS_IBMPEX=3Dm
> CONFIG_SENSORS_IT87=3Dm
> CONFIG_SENSORS_JC42=3Dm
> CONFIG_SENSORS_LM63=3Dm
> CONFIG_SENSORS_LM70=3Dm
> CONFIG_SENSORS_LM73=3Dm
> CONFIG_SENSORS_LM75=3Dm
> CONFIG_SENSORS_LM77=3Dm
> CONFIG_SENSORS_LM78=3Dm
> CONFIG_SENSORS_LM80=3Dm
> CONFIG_SENSORS_LM83=3Dm
> CONFIG_SENSORS_LM85=3Dm
> CONFIG_SENSORS_LM87=3Dm
> CONFIG_SENSORS_LM90=3Dm
> CONFIG_SENSORS_LM92=3Dm
> CONFIG_SENSORS_LM93=3Dm
> CONFIG_SENSORS_LTC4215=3Dm
> CONFIG_SENSORS_LTC4245=3Dm
> CONFIG_SENSORS_LTC4261=3Dm
> CONFIG_SENSORS_LM95241=3Dm
> CONFIG_SENSORS_MAX1111=3Dm
> CONFIG_SENSORS_MAX1619=3Dm
> CONFIG_SENSORS_MAX6650=3Dm
> CONFIG_SENSORS_PC87360=3Dm
> CONFIG_SENSORS_PC87427=3Dm
> CONFIG_SENSORS_PCF8591=3Dm
> CONFIG_SENSORS_SHT15=3Dm
> CONFIG_SENSORS_SIS5595=3Dm
> CONFIG_SENSORS_SMM665=3Dm
> CONFIG_SENSORS_DME1737=3Dm
> CONFIG_SENSORS_EMC1403=3Dm
> CONFIG_SENSORS_EMC2103=3Dm
> CONFIG_SENSORS_SMSC47M1=3Dm
> CONFIG_SENSORS_SMSC47M192=3Dm
> CONFIG_SENSORS_SMSC47B397=3Dm
> CONFIG_SENSORS_ADS7828=3Dm
> CONFIG_SENSORS_ADS7871=3Dm
> CONFIG_SENSORS_AMC6821=3Dm
> CONFIG_SENSORS_THMC50=3Dm
> CONFIG_SENSORS_TMP102=3Dm
> CONFIG_SENSORS_TMP401=3Dm
> CONFIG_SENSORS_TMP421=3Dm
> CONFIG_SENSORS_VIA_CPUTEMP=3Dm
> CONFIG_SENSORS_VIA686A=3Dm
> CONFIG_SENSORS_VT1211=3Dm
> CONFIG_SENSORS_VT8231=3Dm
> CONFIG_SENSORS_W83781D=3Dm
> CONFIG_SENSORS_W83791D=3Dm
> CONFIG_SENSORS_W83792D=3Dm
> CONFIG_SENSORS_W83793=3Dm
> CONFIG_SENSORS_W83795=3Dm
> # CONFIG_SENSORS_W83795_FANCTRL is not set
> CONFIG_SENSORS_W83L785TS=3Dm
> CONFIG_SENSORS_W83L786NG=3Dm
> CONFIG_SENSORS_W83627HF=3Dm
> CONFIG_SENSORS_W83627EHF=3Dm
> CONFIG_SENSORS_WM831X=3Dm
> CONFIG_SENSORS_WM8350=3Dm
> CONFIG_SENSORS_LIS3_I2C=3Dm
> CONFIG_SENSORS_APPLESMC=3Dm
> CONFIG_SENSORS_MC13783_ADC=3Dm
>=20
> #
> # ACPI drivers
> #
> CONFIG_SENSORS_ATK0110=3Dm
> CONFIG_SENSORS_LIS3LV02D=3Dm
> CONFIG_THERMAL=3Dy
> CONFIG_THERMAL_HWMON=3Dy
> CONFIG_WATCHDOG=3Dy
> # CONFIG_WATCHDOG_NOWAYOUT is not set
>=20
> #
> # Watchdog Device Drivers
> #
> CONFIG_SOFT_WATCHDOG=3Dm
> CONFIG_WM831X_WATCHDOG=3Dm
> CONFIG_WM8350_WATCHDOG=3Dm
> CONFIG_TWL4030_WATCHDOG=3Dm
> CONFIG_ACQUIRE_WDT=3Dm
> CONFIG_ADVANTECH_WDT=3Dm
> CONFIG_ALIM1535_WDT=3Dm
> CONFIG_ALIM7101_WDT=3Dm
> CONFIG_F71808E_WDT=3Dm
> CONFIG_GEODE_WDT=3Dm
> CONFIG_SC520_WDT=3Dm
> CONFIG_SBC_FITPC2_WATCHDOG=3Dm
> CONFIG_EUROTECH_WDT=3Dm
> CONFIG_IB700_WDT=3Dm
> CONFIG_IBMASR=3Dm
> CONFIG_WAFER_WDT=3Dm
> CONFIG_I6300ESB_WDT=3Dm
> CONFIG_ITCO_WDT=3Dm
> CONFIG_ITCO_VENDOR_SUPPORT=3Dy
> CONFIG_IT8712F_WDT=3Dm
> CONFIG_IT87_WDT=3Dm
> CONFIG_HP_WATCHDOG=3Dm
> CONFIG_HPWDT_NMI_DECODING=3Dy
> CONFIG_SC1200_WDT=3Dm
> CONFIG_SCx200_WDT=3Dm
> CONFIG_PC87413_WDT=3Dm
> CONFIG_RDC321X_WDT=3Dm
> CONFIG_60XX_WDT=3Dm
> CONFIG_SBC8360_WDT=3Dm
> CONFIG_SBC7240_WDT=3Dm
> CONFIG_CPU5_WDT=3Dm
> CONFIG_SMSC_SCH311X_WDT=3Dm
> CONFIG_SMSC37B787_WDT=3Dm
> CONFIG_W83627HF_WDT=3Dm
> CONFIG_W83697HF_WDT=3Dm
> CONFIG_W83697UG_WDT=3Dm
> CONFIG_W83877F_WDT=3Dm
> CONFIG_W83977F_WDT=3Dm
> CONFIG_MACHZ_WDT=3Dm
> CONFIG_SBC_EPX_C3_WATCHDOG=3Dm
>=20
> #
> # ISA-based Watchdog Cards
> #
> CONFIG_PCWATCHDOG=3Dm
> CONFIG_MIXCOMWD=3Dm
> CONFIG_WDT=3Dm
>=20
> #
> # PCI-based Watchdog Cards
> #
> CONFIG_PCIPCWATCHDOG=3Dm
> CONFIG_WDTPCI=3Dm
>=20
> #
> # USB-based Watchdog Cards
> #
> CONFIG_USBPCWATCHDOG=3Dm
> CONFIG_SSB_POSSIBLE=3Dy
>=20
> #
> # Sonics Silicon Backplane
> #
> CONFIG_SSB=3Dm
> CONFIG_SSB_SPROM=3Dy
> CONFIG_SSB_BLOCKIO=3Dy
> CONFIG_SSB_PCIHOST_POSSIBLE=3Dy
> CONFIG_SSB_PCIHOST=3Dy
> CONFIG_SSB_B43_PCI_BRIDGE=3Dy
> CONFIG_SSB_PCMCIAHOST_POSSIBLE=3Dy
> CONFIG_SSB_PCMCIAHOST=3Dy
> CONFIG_SSB_SDIOHOST_POSSIBLE=3Dy
> CONFIG_SSB_SDIOHOST=3Dy
> # CONFIG_SSB_SILENT is not set
> # CONFIG_SSB_DEBUG is not set
> CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=3Dy
> CONFIG_SSB_DRIVER_PCICORE=3Dy
> CONFIG_MFD_SUPPORT=3Dy
> CONFIG_MFD_CORE=3Dy
> CONFIG_MFD_88PM860X=3Dy
> CONFIG_MFD_SM501=3Dm
> CONFIG_MFD_SM501_GPIO=3Dy
> CONFIG_HTC_PASIC3=3Dm
> CONFIG_HTC_I2CPLD=3Dy
> CONFIG_UCB1400_CORE=3Dm
> CONFIG_TPS65010=3Dm
> CONFIG_TPS6507X=3Dm
> CONFIG_TWL4030_CORE=3Dy
> CONFIG_TWL4030_CODEC=3Dy
> CONFIG_TWL6030_PWM=3Dm
> CONFIG_MFD_STMPE=3Dy
> CONFIG_MFD_TC35892=3Dy
> # CONFIG_MFD_TMIO is not set
> CONFIG_PMIC_DA903X=3Dy
> CONFIG_PMIC_ADP5520=3Dy
> CONFIG_MFD_MAX8925=3Dy
> CONFIG_MFD_MAX8998=3Dy
> CONFIG_MFD_WM8400=3Dm
> CONFIG_MFD_WM831X=3Dy
> CONFIG_MFD_WM831X_I2C=3Dy
> CONFIG_MFD_WM831X_SPI=3Dy
> CONFIG_MFD_WM8350=3Dy
> CONFIG_MFD_WM8350_I2C=3Dy
> CONFIG_MFD_WM8994=3Dy
> CONFIG_MFD_PCF50633=3Dm
> CONFIG_MFD_MC13783=3Dm
> CONFIG_MFD_MC13XXX=3Dm
> CONFIG_PCF50633_ADC=3Dm
> CONFIG_PCF50633_GPIO=3Dm
> CONFIG_ABX500_CORE=3Dy
> CONFIG_AB3100_CORE=3Dy
> CONFIG_AB3100_OTP=3Dm
> CONFIG_EZX_PCAP=3Dy
> CONFIG_AB3550_CORE=3Dy
> CONFIG_MFD_TIMBERDALE=3Dy
> CONFIG_LPC_SCH=3Dm
> CONFIG_MFD_RDC321X=3Dm
> CONFIG_MFD_JANZ_CMODIO=3Dm
> CONFIG_MFD_TPS6586X=3Dy
> CONFIG_MFD_VX855=3Dm
> CONFIG_REGULATOR=3Dy
> # CONFIG_REGULATOR_DEBUG is not set
> CONFIG_REGULATOR_DUMMY=3Dy
> CONFIG_REGULATOR_FIXED_VOLTAGE=3Dm
> CONFIG_REGULATOR_VIRTUAL_CONSUMER=3Dm
> CONFIG_REGULATOR_USERSPACE_CONSUMER=3Dm
> CONFIG_REGULATOR_BQ24022=3Dm
> CONFIG_REGULATOR_MAX1586=3Dm
> CONFIG_REGULATOR_MAX8649=3Dm
> CONFIG_REGULATOR_MAX8660=3Dm
> CONFIG_REGULATOR_MAX8925=3Dm
> CONFIG_REGULATOR_MAX8952=3Dm
> CONFIG_REGULATOR_MAX8998=3Dm
> CONFIG_REGULATOR_TWL4030=3Dy
> CONFIG_REGULATOR_WM831X=3Dm
> CONFIG_REGULATOR_WM8350=3Dm
> CONFIG_REGULATOR_WM8400=3Dm
> CONFIG_REGULATOR_WM8994=3Dm
> CONFIG_REGULATOR_DA903X=3Dm
> CONFIG_REGULATOR_PCF50633=3Dm
> CONFIG_REGULATOR_LP3971=3Dm
> CONFIG_REGULATOR_LP3972=3Dm
> CONFIG_REGULATOR_PCAP=3Dm
> CONFIG_REGULATOR_MC13783=3Dm
> CONFIG_REGULATOR_AB3100=3Dm
> CONFIG_REGULATOR_TPS65023=3Dm
> CONFIG_REGULATOR_TPS6507X=3Dm
> CONFIG_REGULATOR_88PM8607=3Dy
> CONFIG_REGULATOR_ISL6271A=3Dm
> CONFIG_REGULATOR_AD5398=3Dm
> CONFIG_REGULATOR_TPS6586X=3Dm
> CONFIG_MEDIA_SUPPORT=3Dy
>=20
> #
> # Multimedia core support
> #
> CONFIG_VIDEO_DEV=3Dy
> CONFIG_VIDEO_V4L2_COMMON=3Dy
> CONFIG_VIDEO_ALLOW_V4L1=3Dy
> CONFIG_VIDEO_V4L1_COMPAT=3Dy
> CONFIG_DVB_CORE=3Dy
> CONFIG_VIDEO_MEDIA=3Dy
>=20
> #
> # Multimedia drivers
> #
> CONFIG_VIDEO_SAA7146=3Dm
> CONFIG_VIDEO_SAA7146_VV=3Dm
> CONFIG_IR_CORE=3Dy
> CONFIG_VIDEO_IR=3Dy
> CONFIG_LIRC=3Dy
> CONFIG_RC_MAP=3Dy
> CONFIG_IR_NEC_DECODER=3Dy
> CONFIG_IR_RC5_DECODER=3Dy
> CONFIG_IR_RC6_DECODER=3Dy
> CONFIG_IR_JVC_DECODER=3Dy
> CONFIG_IR_SONY_DECODER=3Dy
> CONFIG_IR_RC5_SZ_DECODER=3Dy
> CONFIG_IR_LIRC_CODEC=3Dy
> CONFIG_IR_ENE=3Dm
> CONFIG_IR_IMON=3Dm
> CONFIG_IR_MCEUSB=3Dm
> CONFIG_IR_NUVOTON=3Dm
> CONFIG_IR_STREAMZAP=3Dm
> CONFIG_MEDIA_ATTACH=3Dy
> CONFIG_MEDIA_TUNER=3Dy
> CONFIG_MEDIA_TUNER_CUSTOMISE=3Dy
> CONFIG_MEDIA_TUNER_SIMPLE=3Dm
> CONFIG_MEDIA_TUNER_TDA8290=3Dm
> CONFIG_MEDIA_TUNER_TDA827X=3Dm
> CONFIG_MEDIA_TUNER_TDA18271=3Dm
> CONFIG_MEDIA_TUNER_TDA9887=3Dm
> CONFIG_MEDIA_TUNER_TEA5761=3Dm
> CONFIG_MEDIA_TUNER_TEA5767=3Dm
> CONFIG_MEDIA_TUNER_MT20XX=3Dm
> CONFIG_MEDIA_TUNER_MT2060=3Dm
> CONFIG_MEDIA_TUNER_MT2266=3Dm
> CONFIG_MEDIA_TUNER_MT2131=3Dm
> CONFIG_MEDIA_TUNER_QT1010=3Dm
> CONFIG_MEDIA_TUNER_XC2028=3Dm
> CONFIG_MEDIA_TUNER_XC5000=3Dm
> CONFIG_MEDIA_TUNER_MXL5005S=3Dm
> CONFIG_MEDIA_TUNER_MXL5007T=3Dm
> CONFIG_MEDIA_TUNER_MC44S803=3Dm
> CONFIG_MEDIA_TUNER_MAX2165=3Dm
> CONFIG_MEDIA_TUNER_TDA18218=3Dm
> CONFIG_VIDEO_V4L2=3Dy
> CONFIG_VIDEO_V4L1=3Dy
> CONFIG_VIDEOBUF_GEN=3Dm
> CONFIG_VIDEOBUF_DMA_SG=3Dm
> CONFIG_VIDEOBUF_VMALLOC=3Dm
> CONFIG_VIDEOBUF_DMA_CONTIG=3Dm
> CONFIG_VIDEOBUF_DVB=3Dm
> CONFIG_VIDEO_BTCX=3Dm
> CONFIG_VIDEO_TVEEPROM=3Dm
> CONFIG_VIDEO_TUNER=3Dm
> CONFIG_VIDEO_CAPTURE_DRIVERS=3Dy
> # CONFIG_VIDEO_ADV_DEBUG is not set
> # CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
> CONFIG_VIDEO_HELPER_CHIPS_AUTO=3Dy
> CONFIG_VIDEO_IR_I2C=3Dy
> CONFIG_VIDEO_TVAUDIO=3Dm
> CONFIG_VIDEO_TDA7432=3Dm
> CONFIG_VIDEO_TDA9840=3Dm
> CONFIG_VIDEO_TEA6415C=3Dm
> CONFIG_VIDEO_TEA6420=3Dm
> CONFIG_VIDEO_MSP3400=3Dm
> CONFIG_VIDEO_CS5345=3Dm
> CONFIG_VIDEO_CS53L32A=3Dm
> CONFIG_VIDEO_M52790=3Dm
> CONFIG_VIDEO_WM8775=3Dm
> CONFIG_VIDEO_WM8739=3Dm
> CONFIG_VIDEO_VP27SMPX=3Dm
> CONFIG_VIDEO_SAA6588=3Dm
> CONFIG_VIDEO_BT819=3Dm
> CONFIG_VIDEO_BT856=3Dm
> CONFIG_VIDEO_BT866=3Dm
> CONFIG_VIDEO_KS0127=3Dm
> CONFIG_VIDEO_OV7670=3Dm
> CONFIG_VIDEO_MT9V011=3Dm
> CONFIG_VIDEO_SAA7110=3Dm
> CONFIG_VIDEO_SAA711X=3Dm
> CONFIG_VIDEO_SAA717X=3Dm
> CONFIG_VIDEO_TVP5150=3Dm
> CONFIG_VIDEO_VPX3220=3Dm
> CONFIG_VIDEO_CX25840=3Dm
> CONFIG_VIDEO_CX2341X=3Dm
> CONFIG_VIDEO_SAA7127=3Dm
> CONFIG_VIDEO_SAA7185=3Dm
> CONFIG_VIDEO_ADV7170=3Dm
> CONFIG_VIDEO_ADV7175=3Dm
> CONFIG_VIDEO_UPD64031A=3Dm
> CONFIG_VIDEO_UPD64083=3Dm
> CONFIG_VIDEO_VIVI=3Dm
> CONFIG_VIDEO_BT848=3Dm
> CONFIG_VIDEO_BT848_DVB=3Dy
> CONFIG_VIDEO_PMS=3Dm
> CONFIG_VIDEO_BWQCAM=3Dm
> CONFIG_VIDEO_CQCAM=3Dm
> CONFIG_VIDEO_W9966=3Dm
> CONFIG_VIDEO_CPIA2=3Dm
> CONFIG_VIDEO_ZORAN=3Dm
> CONFIG_VIDEO_ZORAN_DC30=3Dm
> CONFIG_VIDEO_ZORAN_ZR36060=3Dm
> CONFIG_VIDEO_ZORAN_BUZ=3Dm
> CONFIG_VIDEO_ZORAN_DC10=3Dm
> CONFIG_VIDEO_ZORAN_LML33=3Dm
> CONFIG_VIDEO_ZORAN_LML33R10=3Dm
> CONFIG_VIDEO_ZORAN_AVS6EYES=3Dm
> CONFIG_VIDEO_MEYE=3Dm
> CONFIG_VIDEO_SAA7134=3Dm
> CONFIG_VIDEO_SAA7134_ALSA=3Dm
> CONFIG_VIDEO_SAA7134_RC=3Dy
> CONFIG_VIDEO_SAA7134_DVB=3Dm
> CONFIG_VIDEO_MXB=3Dm
> CONFIG_VIDEO_HEXIUM_ORION=3Dm
> CONFIG_VIDEO_HEXIUM_GEMINI=3Dm
> CONFIG_VIDEO_CX88=3Dm
> CONFIG_VIDEO_CX88_ALSA=3Dm
> CONFIG_VIDEO_CX88_BLACKBIRD=3Dm
> CONFIG_VIDEO_CX88_DVB=3Dm
> CONFIG_VIDEO_CX88_MPEG=3Dm
> CONFIG_VIDEO_CX88_VP3054=3Dm
> CONFIG_VIDEO_CX23885=3Dm
> CONFIG_VIDEO_AU0828=3Dm
> CONFIG_VIDEO_IVTV=3Dm
> CONFIG_VIDEO_FB_IVTV=3Dm
> CONFIG_VIDEO_CX18=3Dm
> CONFIG_VIDEO_CX18_ALSA=3Dm
> CONFIG_VIDEO_SAA7164=3Dm
> CONFIG_VIDEO_CAFE_CCIC=3Dm
> CONFIG_VIDEO_SR030PC30=3Dm
> CONFIG_VIDEO_VIA_CAMERA=3Dm
> CONFIG_SOC_CAMERA=3Dm
> CONFIG_SOC_CAMERA_IMX074=3Dm
> CONFIG_SOC_CAMERA_MT9M001=3Dm
> CONFIG_SOC_CAMERA_MT9M111=3Dm
> CONFIG_SOC_CAMERA_MT9T031=3Dm
> CONFIG_SOC_CAMERA_MT9T112=3Dm
> CONFIG_SOC_CAMERA_MT9V022=3Dm
> CONFIG_SOC_CAMERA_RJ54N1=3Dm
> CONFIG_SOC_CAMERA_TW9910=3Dm
> CONFIG_SOC_CAMERA_PLATFORM=3Dm
> CONFIG_SOC_CAMERA_OV6650=3Dm
> CONFIG_SOC_CAMERA_OV772X=3Dm
> CONFIG_SOC_CAMERA_OV9640=3Dm
> CONFIG_V4L_USB_DRIVERS=3Dy
> CONFIG_USB_VIDEO_CLASS=3Dm
> CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=3Dy
> CONFIG_USB_GSPCA=3Dm
> CONFIG_USB_M5602=3Dm
> CONFIG_USB_STV06XX=3Dm
> CONFIG_USB_GL860=3Dm
> CONFIG_USB_GSPCA_BENQ=3Dm
> CONFIG_USB_GSPCA_CONEX=3Dm
> CONFIG_USB_GSPCA_CPIA1=3Dm
> CONFIG_USB_GSPCA_ETOMS=3Dm
> CONFIG_USB_GSPCA_FINEPIX=3Dm
> CONFIG_USB_GSPCA_JEILINJ=3Dm
> CONFIG_USB_GSPCA_KONICA=3Dm
> CONFIG_USB_GSPCA_MARS=3Dm
> CONFIG_USB_GSPCA_MR97310A=3Dm
> CONFIG_USB_GSPCA_OV519=3Dm
> CONFIG_USB_GSPCA_OV534=3Dm
> CONFIG_USB_GSPCA_OV534_9=3Dm
> CONFIG_USB_GSPCA_PAC207=3Dm
> CONFIG_USB_GSPCA_PAC7302=3Dm
> CONFIG_USB_GSPCA_PAC7311=3Dm
> CONFIG_USB_GSPCA_SN9C2028=3Dm
> CONFIG_USB_GSPCA_SN9C20X=3Dm
> CONFIG_USB_GSPCA_SONIXB=3Dm
> CONFIG_USB_GSPCA_SONIXJ=3Dm
> CONFIG_USB_GSPCA_SPCA500=3Dm
> CONFIG_USB_GSPCA_SPCA501=3Dm
> CONFIG_USB_GSPCA_SPCA505=3Dm
> CONFIG_USB_GSPCA_SPCA506=3Dm
> CONFIG_USB_GSPCA_SPCA508=3Dm
> CONFIG_USB_GSPCA_SPCA561=3Dm
> CONFIG_USB_GSPCA_SPCA1528=3Dm
> CONFIG_USB_GSPCA_SQ905=3Dm
> CONFIG_USB_GSPCA_SQ905C=3Dm
> CONFIG_USB_GSPCA_SQ930X=3Dm
> CONFIG_USB_GSPCA_STK014=3Dm
> CONFIG_USB_GSPCA_STV0680=3Dm
> CONFIG_USB_GSPCA_SUNPLUS=3Dm
> CONFIG_USB_GSPCA_T613=3Dm
> CONFIG_USB_GSPCA_TV8532=3Dm
> CONFIG_USB_GSPCA_VC032X=3Dm
> CONFIG_USB_GSPCA_XIRLINK_CIT=3Dm
> CONFIG_USB_GSPCA_ZC3XX=3Dm
> CONFIG_VIDEO_PVRUSB2=3Dm
> CONFIG_VIDEO_PVRUSB2_SYSFS=3Dy
> CONFIG_VIDEO_PVRUSB2_DVB=3Dy
> # CONFIG_VIDEO_PVRUSB2_DEBUGIFC is not set
> CONFIG_VIDEO_HDPVR=3Dm
> CONFIG_VIDEO_EM28XX=3Dm
> CONFIG_VIDEO_EM28XX_ALSA=3Dm
> CONFIG_VIDEO_EM28XX_DVB=3Dm
> CONFIG_VIDEO_TLG2300=3Dm
> CONFIG_VIDEO_CX231XX=3Dm
> CONFIG_VIDEO_CX231XX_ALSA=3Dm
> CONFIG_VIDEO_CX231XX_DVB=3Dm
> CONFIG_VIDEO_USBVISION=3Dm
> CONFIG_VIDEO_USBVIDEO=3Dm
> CONFIG_USB_VICAM=3Dm
> CONFIG_USB_IBMCAM=3Dm
> CONFIG_USB_KONICAWC=3Dm
> CONFIG_USB_ET61X251=3Dm
> CONFIG_USB_SE401=3Dm
> CONFIG_USB_SN9C102=3Dm
> CONFIG_USB_PWC=3Dm
> # CONFIG_USB_PWC_DEBUG is not set
> CONFIG_USB_PWC_INPUT_EVDEV=3Dy
> CONFIG_USB_ZR364XX=3Dm
> CONFIG_USB_STKWEBCAM=3Dm
> CONFIG_USB_S2255=3Dm
> CONFIG_V4L_MEM2MEM_DRIVERS=3Dy
> # CONFIG_VIDEO_MEM2MEM_TESTDEV is not set
> CONFIG_RADIO_ADAPTERS=3Dy
> CONFIG_RADIO_CADET=3Dm
> CONFIG_RADIO_RTRACK=3Dm
> CONFIG_RADIO_RTRACK2=3Dm
> CONFIG_RADIO_AZTECH=3Dm
> CONFIG_RADIO_GEMTEK=3Dm
> CONFIG_RADIO_GEMTEK_PCI=3Dm
> CONFIG_RADIO_MAXIRADIO=3Dm
> CONFIG_RADIO_MAESTRO=3Dm
> CONFIG_RADIO_MIROPCM20=3Dm
> CONFIG_RADIO_SF16FMI=3Dm
> CONFIG_RADIO_SF16FMR2=3Dm
> CONFIG_RADIO_TERRATEC=3Dm
> CONFIG_RADIO_TRUST=3Dm
> CONFIG_RADIO_TYPHOON=3Dm
> CONFIG_RADIO_ZOLTRIX=3Dm
> CONFIG_I2C_SI4713=3Dm
> CONFIG_RADIO_SI4713=3Dm
> CONFIG_USB_DSBR=3Dm
> CONFIG_RADIO_SI470X=3Dy
> CONFIG_USB_SI470X=3Dm
> CONFIG_I2C_SI470X=3Dm
> CONFIG_USB_MR800=3Dm
> CONFIG_RADIO_TEA5764=3Dm
> CONFIG_RADIO_SAA7706H=3Dm
> CONFIG_RADIO_TEF6862=3Dm
> CONFIG_RADIO_TIMBERDALE=3Dm
> CONFIG_DVB_MAX_ADAPTERS=3D8
> CONFIG_DVB_DYNAMIC_MINORS=3Dy
> CONFIG_DVB_CAPTURE_DRIVERS=3Dy
>=20
> #
> # Supported SAA7146 based PCI Adapters
> #
> CONFIG_TTPCI_EEPROM=3Dm
> CONFIG_DVB_AV7110=3Dm
> CONFIG_DVB_AV7110_OSD=3Dy
> CONFIG_DVB_BUDGET_CORE=3Dm
> CONFIG_DVB_BUDGET=3Dm
> CONFIG_DVB_BUDGET_CI=3Dm
> CONFIG_DVB_BUDGET_AV=3Dm
> CONFIG_DVB_BUDGET_PATCH=3Dm
>=20
> #
> # Supported USB Adapters
> #
> CONFIG_DVB_USB=3Dm
> # CONFIG_DVB_USB_DEBUG is not set
> CONFIG_DVB_USB_A800=3Dm
> CONFIG_DVB_USB_DIBUSB_MB=3Dm
> CONFIG_DVB_USB_DIBUSB_MB_FAULTY=3Dy
> CONFIG_DVB_USB_DIBUSB_MC=3Dm
> CONFIG_DVB_USB_DIB0700=3Dm
> CONFIG_DVB_USB_UMT_010=3Dm
> CONFIG_DVB_USB_CXUSB=3Dm
> CONFIG_DVB_USB_M920X=3Dm
> CONFIG_DVB_USB_GL861=3Dm
> CONFIG_DVB_USB_AU6610=3Dm
> CONFIG_DVB_USB_DIGITV=3Dm
> CONFIG_DVB_USB_VP7045=3Dm
> CONFIG_DVB_USB_VP702X=3Dm
> CONFIG_DVB_USB_GP8PSK=3Dm
> CONFIG_DVB_USB_NOVA_T_USB2=3Dm
> CONFIG_DVB_USB_TTUSB2=3Dm
> CONFIG_DVB_USB_DTT200U=3Dm
> CONFIG_DVB_USB_OPERA1=3Dm
> CONFIG_DVB_USB_AF9005=3Dm
> CONFIG_DVB_USB_AF9005_REMOTE=3Dm
> CONFIG_DVB_USB_DW2102=3Dm
> CONFIG_DVB_USB_CINERGY_T2=3Dm
> CONFIG_DVB_USB_ANYSEE=3Dm
> CONFIG_DVB_USB_DTV5100=3Dm
> CONFIG_DVB_USB_AF9015=3Dm
> CONFIG_DVB_USB_CE6230=3Dm
> CONFIG_DVB_USB_FRIIO=3Dm
> CONFIG_DVB_USB_EC168=3Dm
> CONFIG_DVB_USB_AZ6027=3Dm
> CONFIG_DVB_USB_LME2510=3Dm
> CONFIG_DVB_TTUSB_BUDGET=3Dm
> CONFIG_DVB_TTUSB_DEC=3Dm
> CONFIG_SMS_SIANO_MDTV=3Dm
>=20
> #
> # Siano module components
> #
> CONFIG_SMS_USB_DRV=3Dm
> CONFIG_SMS_SDIO_DRV=3Dm
>=20
> #
> # Supported FlexCopII (B2C2) Adapters
> #
> CONFIG_DVB_B2C2_FLEXCOP=3Dm
> CONFIG_DVB_B2C2_FLEXCOP_PCI=3Dm
> CONFIG_DVB_B2C2_FLEXCOP_USB=3Dm
> # CONFIG_DVB_B2C2_FLEXCOP_DEBUG is not set
>=20
> #
> # Supported BT878 Adapters
> #
> CONFIG_DVB_BT8XX=3Dm
>=20
> #
> # Supported Pluto2 Adapters
> #
> CONFIG_DVB_PLUTO2=3Dm
>=20
> #
> # Supported SDMC DM1105 Adapters
> #
> CONFIG_DVB_DM1105=3Dm
> CONFIG_DVB_FIREDTV=3Dm
> CONFIG_DVB_FIREDTV_FIREWIRE=3Dy
> # CONFIG_DVB_FIREDTV_IEEE1394 is not set
> CONFIG_DVB_FIREDTV_INPUT=3Dy
>=20
> #
> # Supported Earthsoft PT1 Adapters
> #
> CONFIG_DVB_PT1=3Dm
>=20
> #
> # Supported Mantis Adapters
> #
> CONFIG_MANTIS_CORE=3Dm
> CONFIG_DVB_MANTIS=3Dm
> CONFIG_DVB_HOPPER=3Dm
>=20
> #
> # Supported nGene Adapters
> #
> CONFIG_DVB_NGENE=3Dm
>=20
> #
> # Supported DVB Frontends
> #
> CONFIG_DVB_FE_CUSTOMISE=3Dy
>=20
> #
> # Customise DVB Frontends
> #
>=20
> #
> # Multistandard (satellite) frontends
> #
> CONFIG_DVB_STB0899=3Dm
> CONFIG_DVB_STB6100=3Dm
> CONFIG_DVB_STV090x=3Dm
> CONFIG_DVB_STV6110x=3Dm
>=20
> #
> # DVB-S (satellite) frontends
> #
> CONFIG_DVB_CX24110=3Dm
> CONFIG_DVB_CX24123=3Dm
> CONFIG_DVB_MT312=3Dm
> CONFIG_DVB_ZL10036=3Dm
> CONFIG_DVB_ZL10039=3Dm
> CONFIG_DVB_S5H1420=3Dm
> CONFIG_DVB_STV0288=3Dm
> CONFIG_DVB_STB6000=3Dm
> CONFIG_DVB_STV0299=3Dm
> CONFIG_DVB_STV6110=3Dm
> CONFIG_DVB_STV0900=3Dm
> CONFIG_DVB_TDA8083=3Dm
> CONFIG_DVB_TDA10086=3Dm
> CONFIG_DVB_TDA8261=3Dm
> CONFIG_DVB_VES1X93=3Dm
> CONFIG_DVB_TUNER_ITD1000=3Dm
> CONFIG_DVB_TUNER_CX24113=3Dm
> CONFIG_DVB_TDA826X=3Dm
> CONFIG_DVB_TUA6100=3Dm
> CONFIG_DVB_CX24116=3Dm
> CONFIG_DVB_SI21XX=3Dm
> CONFIG_DVB_DS3000=3Dm
> CONFIG_DVB_MB86A16=3Dm
>=20
> #
> # DVB-T (terrestrial) frontends
> #
> CONFIG_DVB_SP8870=3Dm
> CONFIG_DVB_SP887X=3Dm
> CONFIG_DVB_CX22700=3Dm
> CONFIG_DVB_CX22702=3Dm
> CONFIG_DVB_S5H1432=3Dm
> CONFIG_DVB_DRX397XD=3Dm
> CONFIG_DVB_L64781=3Dm
> CONFIG_DVB_TDA1004X=3Dm
> CONFIG_DVB_NXT6000=3Dm
> CONFIG_DVB_MT352=3Dm
> CONFIG_DVB_ZL10353=3Dm
> CONFIG_DVB_DIB3000MB=3Dm
> CONFIG_DVB_DIB3000MC=3Dm
> CONFIG_DVB_DIB7000M=3Dm
> CONFIG_DVB_DIB7000P=3Dm
> CONFIG_DVB_TDA10048=3Dm
> CONFIG_DVB_AF9013=3Dm
> CONFIG_DVB_EC100=3Dm
>=20
> #
> # DVB-C (cable) frontends
> #
> CONFIG_DVB_VES1820=3Dm
> CONFIG_DVB_TDA10021=3Dm
> CONFIG_DVB_TDA10023=3Dm
> CONFIG_DVB_STV0297=3Dm
>=20
> #
> # ATSC (North American/Korean Terrestrial/Cable DTV)=20
> frontends
> #
> CONFIG_DVB_NXT200X=3Dm
> CONFIG_DVB_OR51211=3Dm
> CONFIG_DVB_OR51132=3Dm
> CONFIG_DVB_BCM3510=3Dm
> CONFIG_DVB_LGDT330X=3Dm
> CONFIG_DVB_LGDT3305=3Dm
> CONFIG_DVB_S5H1409=3Dm
> CONFIG_DVB_AU8522=3Dm
> CONFIG_DVB_S5H1411=3Dm
>=20
> #
> # ISDB-T (terrestrial) frontends
> #
> CONFIG_DVB_S921=3Dm
> CONFIG_DVB_DIB8000=3Dm
>=20
> #
> # Digital terrestrial only tuners/PLL
> #
> CONFIG_DVB_PLL=3Dm
> CONFIG_DVB_TUNER_DIB0070=3Dm
> CONFIG_DVB_TUNER_DIB0090=3Dm
>=20
> #
> # SEC control devices for DVB-S
> #
> CONFIG_DVB_LNBP21=3Dm
> CONFIG_DVB_ISL6405=3Dm
> CONFIG_DVB_ISL6421=3Dm
> CONFIG_DVB_ISL6423=3Dm
> CONFIG_DVB_LGS8GL5=3Dm
> CONFIG_DVB_LGS8GXX=3Dm
> CONFIG_DVB_ATBM8830=3Dm
> CONFIG_DVB_TDA665x=3Dm
> CONFIG_DVB_IX2505V=3Dm
>=20
> #
> # Tools to develop new frontends
> #
> # CONFIG_DVB_DUMMY_FE is not set
> CONFIG_DAB=3Dy
> CONFIG_USB_DABUSB=3Dy
>=20
> #
> # Graphics support
> #
> CONFIG_AGP=3Dy
> CONFIG_AGP_ALI=3Dy
> CONFIG_AGP_ATI=3Dy
> CONFIG_AGP_AMD=3Dy
> CONFIG_AGP_AMD64=3Dy
> CONFIG_AGP_INTEL=3Dy
> CONFIG_AGP_NVIDIA=3Dy
> CONFIG_AGP_SIS=3Dy
> CONFIG_AGP_SWORKS=3Dy
> CONFIG_AGP_VIA=3Dy
> CONFIG_AGP_EFFICEON=3Dy
> CONFIG_VGA_ARB=3Dy
> CONFIG_VGA_ARB_MAX_GPUS=3D16
> CONFIG_VGA_SWITCHEROO=3Dy
> CONFIG_DRM=3Dy
> CONFIG_DRM_KMS_HELPER=3Dy
> CONFIG_DRM_TTM=3Dy
> CONFIG_DRM_TDFX=3Dy
> CONFIG_DRM_R128=3Dy
> CONFIG_DRM_RADEON=3Dy
> # CONFIG_DRM_RADEON_KMS is not set
> CONFIG_DRM_I810=3Dy
> CONFIG_DRM_I830=3Dm
> CONFIG_DRM_I915=3Dm
> CONFIG_DRM_I915_KMS=3Dy
> CONFIG_DRM_MGA=3Dy
> CONFIG_DRM_SIS=3Dm
> CONFIG_DRM_VIA=3Dy
> CONFIG_DRM_SAVAGE=3Dy
> CONFIG_STUB_POULSBO=3Dm
> CONFIG_VGASTATE=3Dy
> CONFIG_VIDEO_OUTPUT_CONTROL=3Dy
> CONFIG_FB=3Dy
> CONFIG_FIRMWARE_EDID=3Dy
> CONFIG_FB_DDC=3Dy
> CONFIG_FB_BOOT_VESA_SUPPORT=3Dy
> CONFIG_FB_CFB_FILLRECT=3Dy
> CONFIG_FB_CFB_COPYAREA=3Dy
> CONFIG_FB_CFB_IMAGEBLIT=3Dy
> # CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
> CONFIG_FB_SYS_FILLRECT=3Dy
> CONFIG_FB_SYS_COPYAREA=3Dy
> CONFIG_FB_SYS_IMAGEBLIT=3Dy
> CONFIG_FB_FOREIGN_ENDIAN=3Dy
> CONFIG_FB_BOTH_ENDIAN=3Dy
> # CONFIG_FB_BIG_ENDIAN is not set
> # CONFIG_FB_LITTLE_ENDIAN is not set
> CONFIG_FB_SYS_FOPS=3Dy
> CONFIG_FB_DEFERRED_IO=3Dy
> CONFIG_FB_HECUBA=3Dy
> CONFIG_FB_SVGALIB=3Dy
> # CONFIG_FB_MACMODES is not set
> CONFIG_FB_BACKLIGHT=3Dy
> CONFIG_FB_MODE_HELPERS=3Dy
> CONFIG_FB_TILEBLITTING=3Dy
>=20
> #
> # Frame buffer hardware drivers
> #
> CONFIG_FB_CIRRUS=3Dy
> CONFIG_FB_PM2=3Dy
> CONFIG_FB_PM2_FIFO_DISCONNECT=3Dy
> CONFIG_FB_CYBER2000=3Dy
> CONFIG_FB_ARC=3Dy
> CONFIG_FB_ASILIANT=3Dy
> CONFIG_FB_IMSTT=3Dy
> CONFIG_FB_VGA16=3Dy
> CONFIG_FB_UVESA=3Dy
> CONFIG_FB_VESA=3Dy
> CONFIG_FB_EFI=3Dy
> CONFIG_FB_N411=3Dy
> CONFIG_FB_HGA=3Dy
> CONFIG_FB_HGA_ACCEL=3Dy
> CONFIG_FB_S1D13XXX=3Dy
> CONFIG_FB_NVIDIA=3Dy
> CONFIG_FB_NVIDIA_I2C=3Dy
> # CONFIG_FB_NVIDIA_DEBUG is not set
> CONFIG_FB_NVIDIA_BACKLIGHT=3Dy
> CONFIG_FB_RIVA=3Dy
> CONFIG_FB_RIVA_I2C=3Dy
> # CONFIG_FB_RIVA_DEBUG is not set
> CONFIG_FB_RIVA_BACKLIGHT=3Dy
> CONFIG_FB_I810=3Dy
> CONFIG_FB_I810_GTF=3Dy
> CONFIG_FB_I810_I2C=3Dy
> CONFIG_FB_LE80578=3Dy
> CONFIG_FB_CARILLO_RANCH=3Dy
> CONFIG_FB_INTEL=3Dm
> # CONFIG_FB_INTEL_DEBUG is not set
> CONFIG_FB_INTEL_I2C=3Dy
> CONFIG_FB_MATROX=3Dy
> CONFIG_FB_MATROX_MILLENIUM=3Dy
> CONFIG_FB_MATROX_MYSTIQUE=3Dy
> CONFIG_FB_MATROX_G=3Dy
> CONFIG_FB_MATROX_I2C=3Dy
> CONFIG_FB_MATROX_MAVEN=3Dy
> CONFIG_FB_RADEON=3Dy
> CONFIG_FB_RADEON_I2C=3Dy
> CONFIG_FB_RADEON_BACKLIGHT=3Dy
> # CONFIG_FB_RADEON_DEBUG is not set
> CONFIG_FB_ATY128=3Dy
> CONFIG_FB_ATY128_BACKLIGHT=3Dy
> CONFIG_FB_ATY=3Dy
> CONFIG_FB_ATY_CT=3Dy
> CONFIG_FB_ATY_GENERIC_LCD=3Dy
> CONFIG_FB_ATY_GX=3Dy
> CONFIG_FB_ATY_BACKLIGHT=3Dy
> CONFIG_FB_S3=3Dy
> CONFIG_FB_SAVAGE=3Dy
> CONFIG_FB_SAVAGE_I2C=3Dy
> CONFIG_FB_SAVAGE_ACCEL=3Dy
> CONFIG_FB_SIS=3Dy
> CONFIG_FB_SIS_300=3Dy
> CONFIG_FB_SIS_315=3Dy
> CONFIG_FB_VIA=3Dy
> # CONFIG_FB_VIA_DIRECT_PROCFS is not set
> CONFIG_FB_NEOMAGIC=3Dy
> CONFIG_FB_KYRO=3Dy
> CONFIG_FB_3DFX=3Dy
> CONFIG_FB_3DFX_ACCEL=3Dy
> CONFIG_FB_3DFX_I2C=3Dy
> CONFIG_FB_VOODOO1=3Dy
> CONFIG_FB_VT8623=3Dy
> CONFIG_FB_TRIDENT=3Dy
> CONFIG_FB_ARK=3Dy
> CONFIG_FB_PM3=3Dy
> CONFIG_FB_CARMINE=3Dy
> # CONFIG_FB_CARMINE_DRAM_EVAL is not set
> CONFIG_CARMINE_DRAM_CUSTOM=3Dy
> CONFIG_FB_GEODE=3Dy
> CONFIG_FB_GEODE_LX=3Dy
> CONFIG_FB_GEODE_GX=3Dy
> CONFIG_FB_GEODE_GX1=3Dy
> CONFIG_FB_TMIO=3Dm
> CONFIG_FB_TMIO_ACCELL=3Dy
> CONFIG_FB_SM501=3Dm
> # CONFIG_FB_VIRTUAL is not set
> CONFIG_FB_METRONOME=3Dy
> CONFIG_FB_MB862XX=3Dy
> CONFIG_FB_MB862XX_PCI_GDC=3Dy
> CONFIG_FB_BROADSHEET=3Dy
> CONFIG_BACKLIGHT_LCD_SUPPORT=3Dy
> CONFIG_LCD_CLASS_DEVICE=3Dm
> CONFIG_LCD_L4F00242T03=3Dm
> CONFIG_LCD_LMS283GF05=3Dm
> CONFIG_LCD_LTV350QV=3Dm
> CONFIG_LCD_ILI9320=3Dm
> CONFIG_LCD_TDO24M=3Dm
> CONFIG_LCD_VGG2432A4=3Dm
> CONFIG_LCD_PLATFORM=3Dm
> CONFIG_LCD_S6E63M0=3Dm
> CONFIG_BACKLIGHT_CLASS_DEVICE=3Dy
> CONFIG_BACKLIGHT_GENERIC=3Dy
> CONFIG_BACKLIGHT_PROGEAR=3Dm
> CONFIG_BACKLIGHT_CARILLO_RANCH=3Dm
> CONFIG_BACKLIGHT_DA903X=3Dm
> CONFIG_BACKLIGHT_MAX8925=3Dm
> CONFIG_BACKLIGHT_MBP_NVIDIA=3Dm
> CONFIG_BACKLIGHT_SAHARA=3Dm
> CONFIG_BACKLIGHT_WM831X=3Dm
> CONFIG_BACKLIGHT_ADP5520=3Dm
> CONFIG_BACKLIGHT_ADP8860=3Dm
> CONFIG_BACKLIGHT_88PM860X=3Dm
> CONFIG_BACKLIGHT_PCF50633=3Dm
>=20
> #
> # Display device support
> #
> CONFIG_DISPLAY_SUPPORT=3Dy
>=20
> #
> # Display hardware drivers
> #
>=20
> #
> # Console display driver support
> #
> CONFIG_VGA_CONSOLE=3Dy
> CONFIG_VGACON_SOFT_SCROLLBACK=3Dy
> CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=3D256
> CONFIG_MDA_CONSOLE=3Dy
> CONFIG_DUMMY_CONSOLE=3Dy
> CONFIG_FRAMEBUFFER_CONSOLE=3Dy
> CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=3Dy
> CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=3Dy
> CONFIG_FONTS=3Dy
> CONFIG_FONT_8x8=3Dy
> CONFIG_FONT_8x16=3Dy
> CONFIG_FONT_6x11=3Dy
> CONFIG_FONT_7x14=3Dy
> CONFIG_FONT_PEARL_8x8=3Dy
> CONFIG_FONT_ACORN_8x8=3Dy
> CONFIG_FONT_MINI_4x6=3Dy
> CONFIG_FONT_SUN8x16=3Dy
> CONFIG_FONT_SUN12x22=3Dy
> CONFIG_FONT_10x18=3Dy
> CONFIG_LOGO=3Dy
> # CONFIG_LOGO_LINUX_MONO is not set
> # CONFIG_LOGO_LINUX_VGA16 is not set
> CONFIG_LOGO_LINUX_CLUT224=3Dy
> CONFIG_SOUND=3Dm
> CONFIG_SOUND_OSS_CORE=3Dy
> CONFIG_SOUND_OSS_CORE_PRECLAIM=3Dy
> CONFIG_SND=3Dm
> CONFIG_SND_TIMER=3Dm
> CONFIG_SND_PCM=3Dm
> CONFIG_SND_HWDEP=3Dm
> CONFIG_SND_RAWMIDI=3Dm
> CONFIG_SND_JACK=3Dy
> CONFIG_SND_SEQUENCER=3Dm
> CONFIG_SND_SEQ_DUMMY=3Dm
> CONFIG_SND_OSSEMUL=3Dy
> CONFIG_SND_MIXER_OSS=3Dm
> CONFIG_SND_PCM_OSS=3Dm
> CONFIG_SND_PCM_OSS_PLUGINS=3Dy
> CONFIG_SND_SEQUENCER_OSS=3Dy
> CONFIG_SND_HRTIMER=3Dm
> CONFIG_SND_SEQ_HRTIMER_DEFAULT=3Dy
> CONFIG_SND_DYNAMIC_MINORS=3Dy
> CONFIG_SND_SUPPORT_OLD_API=3Dy
> CONFIG_SND_VERBOSE_PROCFS=3Dy
> # CONFIG_SND_VERBOSE_PRINTK is not set
> # CONFIG_SND_DEBUG is not set
> CONFIG_SND_VMASTER=3Dy
> CONFIG_SND_DMA_SGBUF=3Dy
> CONFIG_SND_RAWMIDI_SEQ=3Dm
> CONFIG_SND_OPL3_LIB_SEQ=3Dm
> CONFIG_SND_OPL4_LIB_SEQ=3Dm
> CONFIG_SND_SBAWE_SEQ=3Dm
> CONFIG_SND_EMU10K1_SEQ=3Dm
> CONFIG_SND_MPU401_UART=3Dm
> CONFIG_SND_OPL3_LIB=3Dm
> CONFIG_SND_OPL4_LIB=3Dm
> CONFIG_SND_VX_LIB=3Dm
> CONFIG_SND_AC97_CODEC=3Dm
> CONFIG_SND_DRIVERS=3Dy
> CONFIG_SND_PCSP=3Dm
> CONFIG_SND_DUMMY=3Dm
> CONFIG_SND_ALOOP=3Dm
> CONFIG_SND_VIRMIDI=3Dm
> CONFIG_SND_MTPAV=3Dm
> CONFIG_SND_MTS64=3Dm
> CONFIG_SND_SERIAL_U16550=3Dm
> CONFIG_SND_MPU401=3Dm
> CONFIG_SND_PORTMAN2X4=3Dm
> CONFIG_SND_AC97_POWER_SAVE=3Dy
> CONFIG_SND_AC97_POWER_SAVE_DEFAULT=3D0
> CONFIG_SND_WSS_LIB=3Dm
> CONFIG_SND_SB_COMMON=3Dm
> CONFIG_SND_SB8_DSP=3Dm
> CONFIG_SND_SB16_DSP=3Dm
> CONFIG_SND_ISA=3Dy
> CONFIG_SND_ADLIB=3Dm
> CONFIG_SND_AD1816A=3Dm
> CONFIG_SND_AD1848=3Dm
> CONFIG_SND_ALS100=3Dm
> CONFIG_SND_AZT1605=3Dm
> CONFIG_SND_AZT2316=3Dm
> CONFIG_SND_AZT2320=3Dm
> CONFIG_SND_CMI8330=3Dm
> CONFIG_SND_CS4231=3Dm
> CONFIG_SND_CS4236=3Dm
> CONFIG_SND_ES1688=3Dm
> CONFIG_SND_ES18XX=3Dm
> CONFIG_SND_SC6000=3Dm
> CONFIG_SND_GUSCLASSIC=3Dm
> CONFIG_SND_GUSEXTREME=3Dm
> CONFIG_SND_GUSMAX=3Dm
> CONFIG_SND_INTERWAVE=3Dm
> CONFIG_SND_INTERWAVE_STB=3Dm
> CONFIG_SND_JAZZ16=3Dm
> CONFIG_SND_OPL3SA2=3Dm
> CONFIG_SND_OPTI92X_AD1848=3Dm
> CONFIG_SND_OPTI92X_CS4231=3Dm
> CONFIG_SND_OPTI93X=3Dm
> CONFIG_SND_MIRO=3Dm
> CONFIG_SND_SB8=3Dm
> CONFIG_SND_SB16=3Dm
> CONFIG_SND_SBAWE=3Dm
> CONFIG_SND_SB16_CSP=3Dy
> CONFIG_SND_SSCAPE=3Dm
> CONFIG_SND_WAVEFRONT=3Dm
> CONFIG_SND_MSND_PINNACLE=3Dm
> CONFIG_SND_MSND_CLASSIC=3Dm
> CONFIG_SND_PCI=3Dy
> CONFIG_SND_AD1889=3Dm
> CONFIG_SND_ALS300=3Dm
> CONFIG_SND_ALS4000=3Dm
> CONFIG_SND_ALI5451=3Dm
> CONFIG_SND_ASIHPI=3Dm
> CONFIG_SND_ATIIXP=3Dm
> CONFIG_SND_ATIIXP_MODEM=3Dm
> CONFIG_SND_AU8810=3Dm
> CONFIG_SND_AU8820=3Dm
> CONFIG_SND_AU8830=3Dm
> CONFIG_SND_AW2=3Dm
> CONFIG_SND_AZT3328=3Dm
> CONFIG_SND_BT87X=3Dm
> # CONFIG_SND_BT87X_OVERCLOCK is not set
> CONFIG_SND_CA0106=3Dm
> CONFIG_SND_CMIPCI=3Dm
> CONFIG_SND_OXYGEN_LIB=3Dm
> CONFIG_SND_OXYGEN=3Dm
> CONFIG_SND_CS4281=3Dm
> CONFIG_SND_CS46XX=3Dm
> CONFIG_SND_CS46XX_NEW_DSP=3Dy
> CONFIG_SND_CS5530=3Dm
> CONFIG_SND_CS5535AUDIO=3Dm
> CONFIG_SND_CTXFI=3Dm
> CONFIG_SND_DARLA20=3Dm
> CONFIG_SND_GINA20=3Dm
> CONFIG_SND_LAYLA20=3Dm
> CONFIG_SND_DARLA24=3Dm
> CONFIG_SND_GINA24=3Dm
> CONFIG_SND_LAYLA24=3Dm
> CONFIG_SND_MONA=3Dm
> CONFIG_SND_MIA=3Dm
> CONFIG_SND_ECHO3G=3Dm
> CONFIG_SND_INDIGO=3Dm
> CONFIG_SND_INDIGOIO=3Dm
> CONFIG_SND_INDIGODJ=3Dm
> CONFIG_SND_INDIGOIOX=3Dm
> CONFIG_SND_INDIGODJX=3Dm
> CONFIG_SND_EMU10K1=3Dm
> CONFIG_SND_EMU10K1X=3Dm
> CONFIG_SND_ENS1370=3Dm
> CONFIG_SND_ENS1371=3Dm
> CONFIG_SND_ES1938=3Dm
> CONFIG_SND_ES1968=3Dm
> CONFIG_SND_ES1968_INPUT=3Dy
> CONFIG_SND_FM801=3Dm
> CONFIG_SND_FM801_TEA575X_BOOL=3Dy
> CONFIG_SND_FM801_TEA575X=3Dm
> CONFIG_SND_HDA_INTEL=3Dm
> CONFIG_SND_HDA_HWDEP=3Dy
> CONFIG_SND_HDA_RECONFIG=3Dy
> CONFIG_SND_HDA_INPUT_BEEP=3Dy
> CONFIG_SND_HDA_INPUT_BEEP_MODE=3D1
> CONFIG_SND_HDA_INPUT_JACK=3Dy
> # CONFIG_SND_HDA_PATCH_LOADER is not set
> CONFIG_SND_HDA_CODEC_REALTEK=3Dy
> CONFIG_SND_HDA_CODEC_ANALOG=3Dy
> CONFIG_SND_HDA_CODEC_SIGMATEL=3Dy
> CONFIG_SND_HDA_CODEC_VIA=3Dy
> CONFIG_SND_HDA_CODEC_HDMI=3Dy
> CONFIG_SND_HDA_CODEC_CIRRUS=3Dy
> CONFIG_SND_HDA_CODEC_CONEXANT=3Dy
> CONFIG_SND_HDA_CODEC_CA0110=3Dy
> CONFIG_SND_HDA_CODEC_CMEDIA=3Dy
> CONFIG_SND_HDA_CODEC_SI3054=3Dy
> CONFIG_SND_HDA_GENERIC=3Dy
> # CONFIG_SND_HDA_POWER_SAVE is not set
> CONFIG_SND_HDSP=3Dm
> CONFIG_SND_HDSPM=3Dm
> CONFIG_SND_HIFIER=3Dm
> CONFIG_SND_ICE1712=3Dm
> CONFIG_SND_ICE1724=3Dm
> CONFIG_SND_INTEL8X0=3Dm
> CONFIG_SND_INTEL8X0M=3Dm
> CONFIG_SND_KORG1212=3Dm
> CONFIG_SND_LX6464ES=3Dm
> CONFIG_SND_MAESTRO3=3Dm
> CONFIG_SND_MAESTRO3_INPUT=3Dy
> CONFIG_SND_MIXART=3Dm
> CONFIG_SND_NM256=3Dm
> CONFIG_SND_PCXHR=3Dm
> CONFIG_SND_RIPTIDE=3Dm
> CONFIG_SND_RME32=3Dm
> CONFIG_SND_RME96=3Dm
> CONFIG_SND_RME9652=3Dm
> CONFIG_SND_SIS7019=3Dm
> CONFIG_SND_SONICVIBES=3Dm
> CONFIG_SND_TRIDENT=3Dm
> CONFIG_SND_VIA82XX=3Dm
> CONFIG_SND_VIA82XX_MODEM=3Dm
> CONFIG_SND_VIRTUOSO=3Dm
> CONFIG_SND_VX222=3Dm
> CONFIG_SND_YMFPCI=3Dm
> CONFIG_SND_SPI=3Dy
> CONFIG_SND_USB=3Dy
> CONFIG_SND_USB_AUDIO=3Dm
> CONFIG_SND_USB_UA101=3Dm
> CONFIG_SND_USB_USX2Y=3Dm
> CONFIG_SND_USB_CAIAQ=3Dm
> CONFIG_SND_USB_CAIAQ_INPUT=3Dy
> CONFIG_SND_USB_US122L=3Dm
> CONFIG_SND_PCMCIA=3Dy
> CONFIG_SND_VXPOCKET=3Dm
> CONFIG_SND_PDAUDIOCF=3Dm
> CONFIG_SND_SOC=3Dm
> CONFIG_SND_SOC_I2C_AND_SPI=3Dm
> CONFIG_SND_SOC_ALL_CODECS=3Dm
> CONFIG_SND_SOC_88PM860X=3Dm
> CONFIG_SND_SOC_WM_HUBS=3Dm
> CONFIG_SND_SOC_AD1836=3Dm
> CONFIG_SND_SOC_AD193X=3Dm
> CONFIG_SND_SOC_AD73311=3Dm
> CONFIG_SND_SOC_ADS117X=3Dm
> CONFIG_SND_SOC_AK4104=3Dm
> CONFIG_SND_SOC_AK4535=3Dm
> CONFIG_SND_SOC_AK4642=3Dm
> CONFIG_SND_SOC_AK4671=3Dm
> CONFIG_SND_SOC_CS42L51=3Dm
> CONFIG_SND_SOC_CS4270=3Dm
> CONFIG_SND_SOC_L3=3Dm
> CONFIG_SND_SOC_DA7210=3Dm
> CONFIG_SND_SOC_MAX98088=3Dm
> CONFIG_SND_SOC_PCM3008=3Dm
> CONFIG_SND_SOC_SPDIF=3Dm
> CONFIG_SND_SOC_SSM2602=3Dm
> CONFIG_SND_SOC_TLV320AIC23=3Dm
> CONFIG_SND_SOC_TLV320AIC26=3Dm
> CONFIG_SND_SOC_TLV320AIC3X=3Dm
> CONFIG_SND_SOC_TLV320DAC33=3Dm
> CONFIG_SND_SOC_TWL4030=3Dm
> CONFIG_SND_SOC_TWL6040=3Dm
> CONFIG_SND_SOC_UDA134X=3Dm
> CONFIG_SND_SOC_UDA1380=3Dm
> CONFIG_SND_SOC_WM8350=3Dm
> CONFIG_SND_SOC_WM8400=3Dm
> CONFIG_SND_SOC_WM8510=3Dm
> CONFIG_SND_SOC_WM8523=3Dm
> CONFIG_SND_SOC_WM8580=3Dm
> CONFIG_SND_SOC_WM8711=3Dm
> CONFIG_SND_SOC_WM8727=3Dm
> CONFIG_SND_SOC_WM8728=3Dm
> CONFIG_SND_SOC_WM8731=3Dm
> CONFIG_SND_SOC_WM8741=3Dm
> CONFIG_SND_SOC_WM8750=3Dm
> CONFIG_SND_SOC_WM8753=3Dm
> CONFIG_SND_SOC_WM8776=3Dm
> CONFIG_SND_SOC_WM8804=3Dm
> CONFIG_SND_SOC_WM8900=3Dm
> CONFIG_SND_SOC_WM8903=3Dm
> CONFIG_SND_SOC_WM8904=3Dm
> CONFIG_SND_SOC_WM8940=3Dm
> CONFIG_SND_SOC_WM8955=3Dm
> CONFIG_SND_SOC_WM8960=3Dm
> CONFIG_SND_SOC_WM8961=3Dm
> CONFIG_SND_SOC_WM8962=3Dm
> CONFIG_SND_SOC_WM8971=3Dm
> CONFIG_SND_SOC_WM8974=3Dm
> CONFIG_SND_SOC_WM8978=3Dm
> CONFIG_SND_SOC_WM8985=3Dm
> CONFIG_SND_SOC_WM8988=3Dm
> CONFIG_SND_SOC_WM8990=3Dm
> CONFIG_SND_SOC_WM8993=3Dm
> CONFIG_SND_SOC_WM8994=3Dm
> CONFIG_SND_SOC_WM9081=3Dm
> CONFIG_SND_SOC_MAX9877=3Dm
> CONFIG_SND_SOC_TPA6130A2=3Dm
> CONFIG_SND_SOC_WM2000=3Dm
> CONFIG_SND_SOC_WM9090=3Dm
> CONFIG_SOUND_PRIME=3Dm
> # CONFIG_SOUND_MSNDCLAS is not set
> # CONFIG_SOUND_MSNDPIN is not set
> CONFIG_SOUND_OSS=3Dm
> CONFIG_SOUND_TRACEINIT=3Dy
> CONFIG_SOUND_DMAP=3Dy
> CONFIG_SOUND_VMIDI=3Dm
> CONFIG_SOUND_TRIX=3Dm
> CONFIG_SOUND_MSS=3Dm
> CONFIG_SOUND_MPU401=3Dm
> CONFIG_SOUND_PAS=3Dm
> CONFIG_SOUND_PSS=3Dm
> CONFIG_PSS_MIXER=3Dy
> CONFIG_SOUND_SB=3Dm
> CONFIG_SOUND_YM3812=3Dm
> CONFIG_SOUND_UART6850=3Dm
> CONFIG_SOUND_AEDSP16=3Dm
> CONFIG_SC6600=3Dy
> CONFIG_SC6600_JOY=3Dy
> CONFIG_SC6600_CDROM=3D4
> CONFIG_SC6600_CDROMBASE=3D0
> CONFIG_SOUND_KAHLUA=3Dm
> CONFIG_AC97_BUS=3Dm
> CONFIG_HID_SUPPORT=3Dy
> CONFIG_HID=3Dy
> CONFIG_HIDRAW=3Dy
>=20
> #
> # USB Input Devices
> #
> CONFIG_USB_HID=3Dy
> CONFIG_HID_PID=3Dy
> CONFIG_USB_HIDDEV=3Dy
>=20
> #
> # Special HID drivers
> #
> CONFIG_HID_3M_PCT=3Dm
> CONFIG_HID_A4TECH=3Dy
> CONFIG_HID_ACRUX_FF=3Dm
> CONFIG_HID_APPLE=3Dy
> CONFIG_HID_BELKIN=3Dy
> CONFIG_HID_CANDO=3Dm
> CONFIG_HID_CHERRY=3Dy
> CONFIG_HID_CHICONY=3Dy
> CONFIG_HID_PRODIKEYS=3Dm
> CONFIG_HID_CYPRESS=3Dy
> CONFIG_HID_DRAGONRISE=3Dy
> CONFIG_DRAGONRISE_FF=3Dy
> CONFIG_HID_EGALAX=3Dm
> CONFIG_HID_ELECOM=3Dm
> CONFIG_HID_EZKEY=3Dy
> CONFIG_HID_KYE=3Dy
> CONFIG_HID_UCLOGIC=3Dm
> CONFIG_HID_WALTOP=3Dm
> CONFIG_HID_GYRATION=3Dy
> CONFIG_HID_TWINHAN=3Dy
> CONFIG_HID_KENSINGTON=3Dy
> CONFIG_HID_LOGITECH=3Dy
> CONFIG_LOGITECH_FF=3Dy
> CONFIG_LOGIRUMBLEPAD2_FF=3Dy
> CONFIG_LOGIG940_FF=3Dy
> CONFIG_LOGIWII_FF=3Dy
> CONFIG_HID_MAGICMOUSE=3Dm
> CONFIG_HID_MICROSOFT=3Dy
> CONFIG_HID_MOSART=3Dm
> CONFIG_HID_MONTEREY=3Dy
> CONFIG_HID_NTRIG=3Dy
> CONFIG_HID_ORTEK=3Dm
> CONFIG_HID_PANTHERLORD=3Dy
> CONFIG_PANTHERLORD_FF=3Dy
> CONFIG_HID_PETALYNX=3Dy
> CONFIG_HID_PICOLCD=3Dm
> CONFIG_HID_PICOLCD_FB=3Dy
> CONFIG_HID_PICOLCD_BACKLIGHT=3Dy
> CONFIG_HID_PICOLCD_LCD=3Dy
> CONFIG_HID_PICOLCD_LEDS=3Dy
> CONFIG_HID_QUANTA=3Dm
> CONFIG_HID_ROCCAT=3Dm
> CONFIG_HID_ROCCAT_KONE=3Dm
> CONFIG_HID_ROCCAT_PYRA=3Dm
> CONFIG_HID_SAMSUNG=3Dy
> CONFIG_HID_SONY=3Dy
> CONFIG_HID_STANTUM=3Dm
> CONFIG_HID_SUNPLUS=3Dy
> CONFIG_HID_GREENASIA=3Dy
> CONFIG_GREENASIA_FF=3Dy
> CONFIG_HID_SMARTJOYPLUS=3Dy
> CONFIG_SMARTJOYPLUS_FF=3Dy
> CONFIG_HID_TOPSEED=3Dy
> CONFIG_HID_THRUSTMASTER=3Dy
> CONFIG_THRUSTMASTER_FF=3Dy
> CONFIG_HID_WACOM=3Dm
> CONFIG_HID_WACOM_POWER_SUPPLY=3Dy
> CONFIG_HID_ZEROPLUS=3Dy
> CONFIG_ZEROPLUS_FF=3Dy
> CONFIG_HID_ZYDACRON=3Dm
> CONFIG_USB_SUPPORT=3Dy
> CONFIG_USB_ARCH_HAS_HCD=3Dy
> CONFIG_USB_ARCH_HAS_OHCI=3Dy
> CONFIG_USB_ARCH_HAS_EHCI=3Dy
> CONFIG_USB=3Dy
> # CONFIG_USB_DEBUG is not set
> CONFIG_USB_ANNOUNCE_NEW_DEVICES=3Dy
>=20
> #
> # Miscellaneous USB options
> #
> # CONFIG_USB_DEVICEFS is not set
> CONFIG_USB_DEVICE_CLASS=3Dy
> CONFIG_USB_DYNAMIC_MINORS=3Dy
> # CONFIG_USB_SUSPEND is not set
> # CONFIG_USB_OTG_WHITELIST is not set
> # CONFIG_USB_OTG_BLACKLIST_HUB is not set
> CONFIG_USB_MON=3Dy
> CONFIG_USB_WUSB=3Dy
> CONFIG_USB_WUSB_CBAF=3Dy
> # CONFIG_USB_WUSB_CBAF_DEBUG is not set
>=20
> #
> # USB Host Controller Drivers
> #
> CONFIG_USB_C67X00_HCD=3Dy
> CONFIG_USB_XHCI_HCD=3Dy
> # CONFIG_USB_XHCI_HCD_DEBUGGING is not set
> CONFIG_USB_EHCI_HCD=3Dy
> CONFIG_USB_EHCI_ROOT_HUB_TT=3Dy
> CONFIG_USB_EHCI_TT_NEWSCHED=3Dy
> CONFIG_USB_OXU210HP_HCD=3Dy
> CONFIG_USB_ISP116X_HCD=3Dy
> CONFIG_USB_ISP1760_HCD=3Dy
> CONFIG_USB_ISP1362_HCD=3Dy
> CONFIG_USB_OHCI_HCD=3Dy
> # CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
> # CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
> CONFIG_USB_OHCI_LITTLE_ENDIAN=3Dy
> CONFIG_USB_UHCI_HCD=3Dy
> CONFIG_USB_U132_HCD=3Dm
> CONFIG_USB_SL811_HCD=3Dy
> CONFIG_USB_SL811_CS=3Dy
> CONFIG_USB_R8A66597_HCD=3Dy
> CONFIG_USB_WHCI_HCD=3Dy
> CONFIG_USB_HWA_HCD=3Dy
>=20
> #
> # USB Device Class drivers
> #
> CONFIG_USB_ACM=3Dy
> CONFIG_USB_PRINTER=3Dy
> CONFIG_USB_WDM=3Dy
> CONFIG_USB_TMC=3Dm
>=20
> #
> # NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
> #
>=20
> #
> # also be needed; see USB_STORAGE Help for more info
> #
> CONFIG_USB_STORAGE=3Dy
> # CONFIG_USB_STORAGE_DEBUG is not set
> CONFIG_USB_STORAGE_DATAFAB=3Dy
> CONFIG_USB_STORAGE_FREECOM=3Dy
> CONFIG_USB_STORAGE_ISD200=3Dy
> CONFIG_USB_STORAGE_USBAT=3Dy
> CONFIG_USB_STORAGE_SDDR09=3Dy
> CONFIG_USB_STORAGE_SDDR55=3Dy
> CONFIG_USB_STORAGE_JUMPSHOT=3Dy
> CONFIG_USB_STORAGE_ALAUDA=3Dy
> CONFIG_USB_STORAGE_ONETOUCH=3Dy
> CONFIG_USB_STORAGE_KARMA=3Dy
> CONFIG_USB_STORAGE_CYPRESS_ATACB=3Dy
> CONFIG_USB_UAS=3Dy
> # CONFIG_USB_LIBUSUAL is not set
>=20
> #
> # USB Imaging devices
> #
> CONFIG_USB_MDC800=3Dm
> CONFIG_USB_MICROTEK=3Dm
>=20
> #
> # USB port drivers
> #
> CONFIG_USB_USS720=3Dm
> CONFIG_USB_SERIAL=3Dm
> CONFIG_USB_EZUSB=3Dy
> CONFIG_USB_SERIAL_GENERIC=3Dy
> CONFIG_USB_SERIAL_AIRCABLE=3Dm
> CONFIG_USB_SERIAL_ARK3116=3Dm
> CONFIG_USB_SERIAL_BELKIN=3Dm
> CONFIG_USB_SERIAL_CH341=3Dm
> CONFIG_USB_SERIAL_WHITEHEAT=3Dm
> CONFIG_USB_SERIAL_DIGI_ACCELEPORT=3Dm
> CONFIG_USB_SERIAL_CP210X=3Dm
> CONFIG_USB_SERIAL_CYPRESS_M8=3Dm
> CONFIG_USB_SERIAL_EMPEG=3Dm
> CONFIG_USB_SERIAL_FTDI_SIO=3Dm
> CONFIG_USB_SERIAL_FUNSOFT=3Dm
> CONFIG_USB_SERIAL_VISOR=3Dm
> CONFIG_USB_SERIAL_IPAQ=3Dm
> CONFIG_USB_SERIAL_IR=3Dm
> CONFIG_USB_SERIAL_EDGEPORT=3Dm
> CONFIG_USB_SERIAL_EDGEPORT_TI=3Dm
> CONFIG_USB_SERIAL_GARMIN=3Dm
> CONFIG_USB_SERIAL_IPW=3Dm
> CONFIG_USB_SERIAL_IUU=3Dm
> CONFIG_USB_SERIAL_KEYSPAN_PDA=3Dm
> CONFIG_USB_SERIAL_KEYSPAN=3Dm
> CONFIG_USB_SERIAL_KLSI=3Dm
> CONFIG_USB_SERIAL_KOBIL_SCT=3Dm
> CONFIG_USB_SERIAL_MCT_U232=3Dm
> CONFIG_USB_SERIAL_MOS7720=3Dm
> CONFIG_USB_SERIAL_MOS7715_PARPORT=3Dy
> CONFIG_USB_SERIAL_MOS7840=3Dm
> CONFIG_USB_SERIAL_MOTOROLA=3Dm
> CONFIG_USB_SERIAL_NAVMAN=3Dm
> CONFIG_USB_SERIAL_PL2303=3Dm
> CONFIG_USB_SERIAL_OTI6858=3Dm
> CONFIG_USB_SERIAL_QCAUX=3Dm
> CONFIG_USB_SERIAL_QUALCOMM=3Dm
> CONFIG_USB_SERIAL_SPCP8X5=3Dm
> CONFIG_USB_SERIAL_HP4X=3Dm
> CONFIG_USB_SERIAL_SAFE=3Dm
> CONFIG_USB_SERIAL_SAFE_PADDED=3Dy
> CONFIG_USB_SERIAL_SAMBA=3Dm
> CONFIG_USB_SERIAL_SIEMENS_MPI=3Dm
> CONFIG_USB_SERIAL_SIERRAWIRELESS=3Dm
> CONFIG_USB_SERIAL_SYMBOL=3Dm
> CONFIG_USB_SERIAL_TI=3Dm
> CONFIG_USB_SERIAL_CYBERJACK=3Dm
> CONFIG_USB_SERIAL_XIRCOM=3Dm
> CONFIG_USB_SERIAL_WWAN=3Dm
> CONFIG_USB_SERIAL_OPTION=3Dm
> CONFIG_USB_SERIAL_OMNINET=3Dm
> CONFIG_USB_SERIAL_OPTICON=3Dm
> CONFIG_USB_SERIAL_VIVOPAY_SERIAL=3Dm
> CONFIG_USB_SERIAL_ZIO=3Dm
> CONFIG_USB_SERIAL_SSU100=3Dm
> CONFIG_USB_SERIAL_DEBUG=3Dm
>=20
> #
> # USB Miscellaneous drivers
> #
> CONFIG_USB_EMI62=3Dm
> CONFIG_USB_EMI26=3Dm
> CONFIG_USB_ADUTUX=3Dm
> CONFIG_USB_SEVSEG=3Dm
> CONFIG_USB_RIO500=3Dm
> CONFIG_USB_LEGOTOWER=3Dm
> CONFIG_USB_LCD=3Dm
> CONFIG_USB_LED=3Dm
> CONFIG_USB_CYPRESS_CY7C63=3Dm
> CONFIG_USB_CYTHERM=3Dm
> CONFIG_USB_IDMOUSE=3Dm
> CONFIG_USB_FTDI_ELAN=3Dm
> CONFIG_USB_APPLEDISPLAY=3Dm
> CONFIG_USB_SISUSBVGA=3Dm
> CONFIG_USB_SISUSBVGA_CON=3Dy
> CONFIG_USB_LD=3Dm
> CONFIG_USB_TRANCEVIBRATOR=3Dm
> CONFIG_USB_IOWARRIOR=3Dm
> # CONFIG_USB_TEST is not set
> CONFIG_USB_ISIGHTFW=3Dm
> CONFIG_USB_YUREX=3Dm
> CONFIG_USB_ATM=3Dm
> CONFIG_USB_SPEEDTOUCH=3Dm
> CONFIG_USB_CXACRU=3Dm
> CONFIG_USB_UEAGLEATM=3Dm
> CONFIG_USB_XUSBATM=3Dm
> CONFIG_USB_GADGET=3Dm
> # CONFIG_USB_GADGET_DEBUG_FILES is not set
> # CONFIG_USB_GADGET_DEBUG_FS is not set
> CONFIG_USB_GADGET_VBUS_DRAW=3D2
> CONFIG_USB_GADGET_SELECTED=3Dy
> # CONFIG_USB_GADGET_R8A66597 is not set
> # CONFIG_USB_GADGET_M66592 is not set
> # CONFIG_USB_GADGET_AMD5536UDC is not set
> # CONFIG_USB_GADGET_CI13XXX is not set
> # CONFIG_USB_GADGET_NET2280 is not set
> # CONFIG_USB_GADGET_GOKU is not set
> CONFIG_USB_GADGET_LANGWELL=3Dy
> CONFIG_USB_LANGWELL=3Dm
> # CONFIG_USB_GADGET_DUMMY_HCD is not set
> CONFIG_USB_GADGET_DUALSPEED=3Dy
> CONFIG_USB_ZERO=3Dm
> CONFIG_USB_AUDIO=3Dm
> CONFIG_USB_ETH=3Dm
> CONFIG_USB_ETH_RNDIS=3Dy
> CONFIG_USB_ETH_EEM=3Dy
> CONFIG_USB_GADGETFS=3Dm
> CONFIG_USB_FUNCTIONFS=3Dm
> CONFIG_USB_FUNCTIONFS_ETH=3Dy
> CONFIG_USB_FUNCTIONFS_RNDIS=3Dy
> CONFIG_USB_FUNCTIONFS_GENERIC=3Dy
> CONFIG_USB_FILE_STORAGE=3Dm
> CONFIG_USB_FILE_STORAGE_TEST=3Dy
> CONFIG_USB_MASS_STORAGE=3Dm
> CONFIG_USB_G_SERIAL=3Dm
> CONFIG_USB_MIDI_GADGET=3Dm
> CONFIG_USB_G_PRINTER=3Dm
> CONFIG_USB_CDC_COMPOSITE=3Dm
> CONFIG_USB_G_NOKIA=3Dm
> CONFIG_USB_G_MULTI=3Dm
> CONFIG_USB_G_MULTI_RNDIS=3Dy
> CONFIG_USB_G_MULTI_CDC=3Dy
> CONFIG_USB_G_HID=3Dm
> CONFIG_USB_G_DBGP=3Dm
> CONFIG_USB_G_DBGP_PRINTK=3Dy
> # CONFIG_USB_G_DBGP_SERIAL is not set
> CONFIG_USB_G_WEBCAM=3Dm
>=20
> #
> # OTG and related infrastructure
> #
> CONFIG_USB_OTG_UTILS=3Dy
> CONFIG_USB_GPIO_VBUS=3Dm
> CONFIG_TWL4030_USB=3Dm
> CONFIG_NOP_USB_XCEIV=3Dm
> CONFIG_UWB=3Dy
> CONFIG_UWB_HWA=3Dy
> CONFIG_UWB_WHCI=3Dy
> CONFIG_UWB_I1480U=3Dm
> CONFIG_MMC=3Dy
> # CONFIG_MMC_DEBUG is not set
> # CONFIG_MMC_UNSAFE_RESUME is not set
>=20
> #
> # MMC/SD/SDIO Card Drivers
> #
> CONFIG_MMC_BLOCK=3Dy
> CONFIG_MMC_BLOCK_MINORS=3D8
> CONFIG_MMC_BLOCK_BOUNCE=3Dy
> CONFIG_SDIO_UART=3Dy
> CONFIG_MMC_TEST=3Dy
>=20
> #
> # MMC/SD/SDIO Host Controller Drivers
> #
> CONFIG_MMC_SDHCI=3Dy
> CONFIG_MMC_SDHCI_PCI=3Dy
> CONFIG_MMC_RICOH_MMC=3Dy
> CONFIG_MMC_SDHCI_PLTFM=3Dy
> CONFIG_MMC_WBSD=3Dy
> CONFIG_MMC_TIFM_SD=3Dy
> CONFIG_MMC_SDRICOH_CS=3Dm
> CONFIG_MMC_CB710=3Dy
> CONFIG_MMC_VIA_SDMMC=3Dy
> CONFIG_MMC_USHC=3Dm
> CONFIG_MEMSTICK=3Dy
> # CONFIG_MEMSTICK_DEBUG is not set
>=20
> #
> # MemoryStick drivers
> #
> # CONFIG_MEMSTICK_UNSAFE_RESUME is not set
> CONFIG_MSPRO_BLOCK=3Dy
>=20
> #
> # MemoryStick Host Controller Drivers
> #
> CONFIG_MEMSTICK_TIFM_MS=3Dy
> CONFIG_MEMSTICK_JMICRON_38X=3Dy
> CONFIG_NEW_LEDS=3Dy
> CONFIG_LEDS_CLASS=3Dm
>=20
> #
> # LED drivers
> #
> CONFIG_LEDS_88PM860X=3Dm
> CONFIG_LEDS_NET48XX=3Dm
> CONFIG_LEDS_NET5501=3Dm
> CONFIG_LEDS_WRAP=3Dm
> CONFIG_LEDS_ALIX2=3Dm
> CONFIG_LEDS_PCA9532=3Dm
> CONFIG_LEDS_GPIO=3Dm
> CONFIG_LEDS_GPIO_PLATFORM=3Dy
> CONFIG_LEDS_LP3944=3Dm
> CONFIG_LEDS_CLEVO_MAIL=3Dm
> CONFIG_LEDS_PCA955X=3Dm
> CONFIG_LEDS_WM831X_STATUS=3Dm
> CONFIG_LEDS_WM8350=3Dm
> CONFIG_LEDS_DA903X=3Dm
> CONFIG_LEDS_DAC124S085=3Dm
> CONFIG_LEDS_REGULATOR=3Dm
> CONFIG_LEDS_BD2802=3Dm
> CONFIG_LEDS_INTEL_SS4200=3Dm
> CONFIG_LEDS_LT3593=3Dm
> CONFIG_LEDS_ADP5520=3Dm
> CONFIG_LEDS_DELL_NETBOOKS=3Dm
> CONFIG_LEDS_MC13783=3Dm
> CONFIG_LEDS_TRIGGERS=3Dy
>=20
> #
> # LED Triggers
> #
> CONFIG_LEDS_TRIGGER_TIMER=3Dm
> CONFIG_LEDS_TRIGGER_IDE_DISK=3Dy
> CONFIG_LEDS_TRIGGER_HEARTBEAT=3Dm
> CONFIG_LEDS_TRIGGER_BACKLIGHT=3Dm
> CONFIG_LEDS_TRIGGER_GPIO=3Dm
> CONFIG_LEDS_TRIGGER_DEFAULT_ON=3Dm
>=20
> #
> # iptables trigger is under Netfilter config (LED target)
> #
> CONFIG_ACCESSIBILITY=3Dy
> CONFIG_A11Y_BRAILLE_CONSOLE=3Dy
> CONFIG_INFINIBAND=3Dm
> CONFIG_INFINIBAND_USER_MAD=3Dm
> CONFIG_INFINIBAND_USER_ACCESS=3Dm
> CONFIG_INFINIBAND_USER_MEM=3Dy
> CONFIG_INFINIBAND_ADDR_TRANS=3Dy
> CONFIG_INFINIBAND_MTHCA=3Dm
> CONFIG_INFINIBAND_MTHCA_DEBUG=3Dy
> CONFIG_INFINIBAND_AMSO1100=3Dm
> # CONFIG_INFINIBAND_AMSO1100_DEBUG is not set
> CONFIG_INFINIBAND_CXGB3=3Dm
> # CONFIG_INFINIBAND_CXGB3_DEBUG is not set
> CONFIG_INFINIBAND_CXGB4=3Dm
> CONFIG_MLX4_INFINIBAND=3Dm
> CONFIG_INFINIBAND_NES=3Dm
> # CONFIG_INFINIBAND_NES_DEBUG is not set
> CONFIG_INFINIBAND_IPOIB=3Dm
> # CONFIG_INFINIBAND_IPOIB_CM is not set
> # CONFIG_INFINIBAND_IPOIB_DEBUG is not set
> CONFIG_INFINIBAND_SRP=3Dm
> CONFIG_INFINIBAND_ISER=3Dm
> CONFIG_EDAC=3Dy
>=20
> #
> # Reporting subsystems
> #
> # CONFIG_EDAC_DEBUG is not set
> CONFIG_EDAC_DECODE_MCE=3Dy
> CONFIG_EDAC_MCE_INJ=3Dm
> CONFIG_EDAC_MM_EDAC=3Dy
> CONFIG_EDAC_MCE=3Dy
> CONFIG_EDAC_AMD76X=3Dm
> CONFIG_EDAC_E7XXX=3Dm
> CONFIG_EDAC_E752X=3Dm
> CONFIG_EDAC_I82875P=3Dm
> CONFIG_EDAC_I82975X=3Dm
> CONFIG_EDAC_I3000=3Dm
> CONFIG_EDAC_I3200=3Dm
> CONFIG_EDAC_X38=3Dm
> CONFIG_EDAC_I5400=3Dm
> CONFIG_EDAC_I7CORE=3Dm
> CONFIG_EDAC_I82860=3Dm
> CONFIG_EDAC_R82600=3Dm
> CONFIG_EDAC_I5000=3Dm
> CONFIG_EDAC_I5100=3Dm
> CONFIG_EDAC_I7300=3Dm
> CONFIG_RTC_LIB=3Dm
> CONFIG_RTC_CLASS=3Dm
>=20
> #
> # RTC interfaces
> #
> CONFIG_RTC_INTF_SYSFS=3Dy
> CONFIG_RTC_INTF_PROC=3Dy
> CONFIG_RTC_INTF_DEV=3Dy
> CONFIG_RTC_INTF_DEV_UIE_EMUL=3Dy
> CONFIG_RTC_DRV_TEST=3Dm
>=20
> #
> # I2C RTC drivers
> #
> CONFIG_RTC_DRV_DS1307=3Dm
> CONFIG_RTC_DRV_DS1374=3Dm
> CONFIG_RTC_DRV_DS1672=3Dm
> CONFIG_RTC_DRV_DS3232=3Dm
> CONFIG_RTC_DRV_MAX6900=3Dm
> CONFIG_RTC_DRV_MAX8925=3Dm
> CONFIG_RTC_DRV_MAX8998=3Dm
> CONFIG_RTC_DRV_RS5C372=3Dm
> CONFIG_RTC_DRV_ISL1208=3Dm
> CONFIG_RTC_DRV_ISL12022=3Dm
> CONFIG_RTC_DRV_X1205=3Dm
> CONFIG_RTC_DRV_PCF8563=3Dm
> CONFIG_RTC_DRV_PCF8583=3Dm
> CONFIG_RTC_DRV_M41T80=3Dm
> CONFIG_RTC_DRV_M41T80_WDT=3Dy
> CONFIG_RTC_DRV_BQ32K=3Dm
> CONFIG_RTC_DRV_TWL4030=3Dm
> CONFIG_RTC_DRV_S35390A=3Dm
> CONFIG_RTC_DRV_FM3130=3Dm
> CONFIG_RTC_DRV_RX8581=3Dm
> CONFIG_RTC_DRV_RX8025=3Dm
>=20
> #
> # SPI RTC drivers
> #
> CONFIG_RTC_DRV_M41T94=3Dm
> CONFIG_RTC_DRV_DS1305=3Dm
> CONFIG_RTC_DRV_DS1390=3Dm
> CONFIG_RTC_DRV_MAX6902=3Dm
> CONFIG_RTC_DRV_R9701=3Dm
> CONFIG_RTC_DRV_RS5C348=3Dm
> CONFIG_RTC_DRV_DS3234=3Dm
> CONFIG_RTC_DRV_PCF2123=3Dm
>=20
> #
> # Platform RTC drivers
> #
> CONFIG_RTC_DRV_CMOS=3Dm
> CONFIG_RTC_DRV_DS1286=3Dm
> CONFIG_RTC_DRV_DS1511=3Dm
> CONFIG_RTC_DRV_DS1553=3Dm
> CONFIG_RTC_DRV_DS1742=3Dm
> CONFIG_RTC_DRV_STK17TA8=3Dm
> CONFIG_RTC_DRV_M48T86=3Dm
> CONFIG_RTC_DRV_M48T35=3Dm
> CONFIG_RTC_DRV_M48T59=3Dm
> CONFIG_RTC_DRV_MSM6242=3Dm
> CONFIG_RTC_DRV_BQ4802=3Dm
> CONFIG_RTC_DRV_RP5C01=3Dm
> CONFIG_RTC_DRV_V3020=3Dm
> CONFIG_RTC_DRV_WM831X=3Dm
> CONFIG_RTC_DRV_WM8350=3Dm
> CONFIG_RTC_DRV_PCF50633=3Dm
> CONFIG_RTC_DRV_AB3100=3Dm
>=20
> #
> # on-CPU RTC drivers
> #
> CONFIG_RTC_DRV_PCAP=3Dm
> CONFIG_RTC_DRV_MC13XXX=3Dm
> CONFIG_DMADEVICES=3Dy
> # CONFIG_DMADEVICES_DEBUG is not set
>=20
> #
> # DMA Devices
> #
> CONFIG_INTEL_MID_DMAC=3Dm
> CONFIG_INTEL_IOATDMA=3Dm
> CONFIG_TIMB_DMA=3Dm
> CONFIG_PCH_DMA=3Dm
> CONFIG_DMA_ENGINE=3Dy
>=20
> #
> # DMA Clients
> #
> CONFIG_NET_DMA=3Dy
> CONFIG_ASYNC_TX_DMA=3Dy
> CONFIG_DMATEST=3Dm
> CONFIG_DCA=3Dm
> CONFIG_AUXDISPLAY=3Dy
> CONFIG_KS0108=3Dm
> CONFIG_KS0108_PORT=3D0x378
> CONFIG_KS0108_DELAY=3D2
> CONFIG_CFAG12864B=3Dm
> CONFIG_CFAG12864B_RATE=3D20
> CONFIG_UIO=3Dy
> CONFIG_UIO_CIF=3Dm
> CONFIG_UIO_PDRV=3Dm
> CONFIG_UIO_PDRV_GENIRQ=3Dm
> CONFIG_UIO_AEC=3Dm
> CONFIG_UIO_SERCOS3=3Dm
> CONFIG_UIO_PCI_GENERIC=3Dm
> CONFIG_UIO_NETX=3Dm
> CONFIG_STAGING=3Dy
> # CONFIG_STAGING_EXCLUDE_BUILD is not set
> CONFIG_ET131X=3Dm
> # CONFIG_ET131X_DEBUG is not set
> CONFIG_SLICOSS=3Dm
> CONFIG_VIDEO_GO7007=3Dm
> CONFIG_VIDEO_GO7007_USB=3Dm
> CONFIG_VIDEO_GO7007_USB_S2250_BOARD=3Dm
> CONFIG_VIDEO_GO7007_OV7640=3Dm
> CONFIG_VIDEO_GO7007_SAA7113=3Dm
> CONFIG_VIDEO_GO7007_SAA7115=3Dm
> CONFIG_VIDEO_GO7007_TW9903=3Dm
> CONFIG_VIDEO_GO7007_UDA1342=3Dm
> CONFIG_VIDEO_GO7007_SONY_TUNER=3Dm
> CONFIG_VIDEO_GO7007_TW2804=3Dm
> CONFIG_VIDEO_CX25821=3Dm
> CONFIG_VIDEO_CX25821_ALSA=3Dm
> CONFIG_VIDEO_TM6000=3Dm
> CONFIG_VIDEO_TM6000_ALSA=3Dm
> CONFIG_VIDEO_TM6000_DVB=3Dm
> CONFIG_VIDEO_CPIA=3Dm
> CONFIG_VIDEO_CPIA_PP=3Dm
> CONFIG_VIDEO_CPIA_USB=3Dm
> CONFIG_VIDEO_STRADIS=3Dm
> CONFIG_USB_IP_COMMON=3Dm
> CONFIG_USB_IP_VHCI_HCD=3Dm
> CONFIG_USB_IP_HOST=3Dm
> # CONFIG_USB_IP_DEBUG_ENABLE is not set
> CONFIG_W35UND=3Dm
> CONFIG_PRISM2_USB=3Dm
> CONFIG_ECHO=3Dm
> CONFIG_BRCM80211=3Dm
> CONFIG_BRCM80211_PCI=3Dy
> # CONFIG_BRCMFMAC is not set
> CONFIG_RT2860=3Dm
> CONFIG_RT2870=3Dm
> CONFIG_COMEDI=3Dm
> # CONFIG_COMEDI_DEBUG is not set
> CONFIG_COMEDI_MISC_DRIVERS=3Dm
> CONFIG_COMEDI_KCOMEDILIB=3Dm
> CONFIG_COMEDI_BOND=3Dm
> CONFIG_COMEDI_TEST=3Dm
> CONFIG_COMEDI_PARPORT=3Dm
> CONFIG_COMEDI_SERIAL2002=3Dm
> CONFIG_COMEDI_SKEL=3Dm
> CONFIG_COMEDI_ISA_DRIVERS=3Dm
> CONFIG_COMEDI_ACL7225B=3Dm
> CONFIG_COMEDI_PCL711=3Dm
> CONFIG_COMEDI_PCL724=3Dm
> CONFIG_COMEDI_PCL725=3Dm
> CONFIG_COMEDI_PCL726=3Dm
> CONFIG_COMEDI_PCL730=3Dm
> CONFIG_COMEDI_PCL812=3Dm
> CONFIG_COMEDI_PCL816=3Dm
> CONFIG_COMEDI_PCL818=3Dm
> CONFIG_COMEDI_PCM3724=3Dm
> CONFIG_COMEDI_PCM3730=3Dm
> CONFIG_COMEDI_RTI800=3Dm
> CONFIG_COMEDI_RTI802=3Dm
> CONFIG_COMEDI_DAS16M1=3Dm
> CONFIG_COMEDI_DAS16=3Dm
> CONFIG_COMEDI_DAS800=3Dm
> CONFIG_COMEDI_DAS1800=3Dm
> CONFIG_COMEDI_DAS6402=3Dm
> CONFIG_COMEDI_DT2801=3Dm
> CONFIG_COMEDI_DT2811=3Dm
> CONFIG_COMEDI_DT2814=3Dm
> CONFIG_COMEDI_DT2815=3Dm
> CONFIG_COMEDI_DT2817=3Dm
> CONFIG_COMEDI_DT282X=3Dm
> CONFIG_COMEDI_DMM32AT=3Dm
> CONFIG_COMEDI_FL512=3Dm
> CONFIG_COMEDI_AIO_AIO12_8=3Dm
> CONFIG_COMEDI_AIO_IIRO_16=3Dm
> CONFIG_COMEDI_C6XDIGIO=3Dm
> CONFIG_COMEDI_MPC624=3Dm
> CONFIG_COMEDI_ADQ12B=3Dm
> CONFIG_COMEDI_NI_AT_A2150=3Dm
> CONFIG_COMEDI_NI_AT_AO=3Dm
> CONFIG_COMEDI_NI_ATMIO=3Dm
> CONFIG_COMEDI_NI_ATMIO16D=3Dm
> CONFIG_COMEDI_PCMAD=3Dm
> CONFIG_COMEDI_PCMDA12=3Dm
> CONFIG_COMEDI_PCMMIO=3Dm
> CONFIG_COMEDI_PCMUIO=3Dm
> CONFIG_COMEDI_MULTIQ3=3Dm
> CONFIG_COMEDI_POC=3Dm
> CONFIG_COMEDI_PCI_DRIVERS=3Dm
> CONFIG_COMEDI_ADDI_APCI_035=3Dm
> CONFIG_COMEDI_ADDI_APCI_1032=3Dm
> CONFIG_COMEDI_ADDI_APCI_1500=3Dm
> CONFIG_COMEDI_ADDI_APCI_1516=3Dm
> CONFIG_COMEDI_ADDI_APCI_1564=3Dm
> CONFIG_COMEDI_ADDI_APCI_16XX=3Dm
> CONFIG_COMEDI_ADDI_APCI_2016=3Dm
> CONFIG_COMEDI_ADDI_APCI_2032=3Dm
> CONFIG_COMEDI_ADDI_APCI_2200=3Dm
> CONFIG_COMEDI_ADDI_APCI_3001=3Dm
> CONFIG_COMEDI_ADDI_APCI_3120=3Dm
> CONFIG_COMEDI_ADDI_APCI_3501=3Dm
> CONFIG_COMEDI_ADDI_APCI_3XXX=3Dm
> CONFIG_COMEDI_ADL_PCI6208=3Dm
> CONFIG_COMEDI_ADL_PCI7230=3Dm
> CONFIG_COMEDI_ADL_PCI7296=3Dm
> CONFIG_COMEDI_ADL_PCI7432=3Dm
> CONFIG_COMEDI_ADL_PCI8164=3Dm
> CONFIG_COMEDI_ADL_PCI9111=3Dm
> CONFIG_COMEDI_ADL_PCI9118=3Dm
> CONFIG_COMEDI_ADV_PCI1710=3Dm
> CONFIG_COMEDI_ADV_PCI1723=3Dm
> CONFIG_COMEDI_ADV_PCI_DIO=3Dm
> CONFIG_COMEDI_AMPLC_DIO200=3Dm
> CONFIG_COMEDI_AMPLC_PC236=3Dm
> CONFIG_COMEDI_AMPLC_PC263=3Dm
> CONFIG_COMEDI_AMPLC_PCI224=3Dm
> CONFIG_COMEDI_AMPLC_PCI230=3Dm
> CONFIG_COMEDI_CONTEC_PCI_DIO=3Dm
> CONFIG_COMEDI_DT3000=3Dm
> CONFIG_COMEDI_UNIOXX5=3Dm
> CONFIG_COMEDI_GSC_HPDI=3Dm
> CONFIG_COMEDI_ICP_MULTI=3Dm
> CONFIG_COMEDI_II_PCI20KC=3Dm
> CONFIG_COMEDI_DAQBOARD2000=3Dm
> CONFIG_COMEDI_JR3_PCI=3Dm
> CONFIG_COMEDI_KE_COUNTER=3Dm
> CONFIG_COMEDI_CB_PCIDAS64=3Dm
> CONFIG_COMEDI_CB_PCIDAS=3Dm
> CONFIG_COMEDI_CB_PCIDDA=3Dm
> CONFIG_COMEDI_CB_PCIDIO=3Dm
> CONFIG_COMEDI_CB_PCIMDAS=3Dm
> CONFIG_COMEDI_CB_PCIMDDA=3Dm
> CONFIG_COMEDI_ME4000=3Dm
> CONFIG_COMEDI_ME_DAQ=3Dm
> CONFIG_COMEDI_NI_6527=3Dm
> CONFIG_COMEDI_NI_65XX=3Dm
> CONFIG_COMEDI_NI_660X=3Dm
> CONFIG_COMEDI_NI_670X=3Dm
> CONFIG_COMEDI_NI_PCIDIO=3Dm
> CONFIG_COMEDI_NI_PCIMIO=3Dm
> CONFIG_COMEDI_RTD520=3Dm
> CONFIG_COMEDI_S526=3Dm
> CONFIG_COMEDI_S626=3Dm
> CONFIG_COMEDI_SSV_DNP=3Dm
> CONFIG_COMEDI_PCMCIA_DRIVERS=3Dm
> CONFIG_COMEDI_CB_DAS16_CS=3Dm
> CONFIG_COMEDI_DAS08_CS=3Dm
> CONFIG_COMEDI_NI_DAQ_700_CS=3Dm
> CONFIG_COMEDI_NI_DAQ_DIO24_CS=3Dm
> CONFIG_COMEDI_NI_LABPC_CS=3Dm
> CONFIG_COMEDI_NI_MIO_CS=3Dm
> CONFIG_COMEDI_QUATECH_DAQP_CS=3Dm
> CONFIG_COMEDI_USB_DRIVERS=3Dm
> CONFIG_COMEDI_DT9812=3Dm
> CONFIG_COMEDI_USBDUX=3Dm
> CONFIG_COMEDI_USBDUXFAST=3Dm
> CONFIG_COMEDI_VMK80XX=3Dm
> CONFIG_COMEDI_NI_COMMON=3Dm
> CONFIG_COMEDI_MITE=3Dm
> CONFIG_COMEDI_NI_TIO=3Dm
> CONFIG_COMEDI_NI_LABPC=3Dm
> CONFIG_COMEDI_8255=3Dm
> CONFIG_COMEDI_DAS08=3Dm
> CONFIG_COMEDI_FC=3Dm
> CONFIG_ASUS_OLED=3Dm
> CONFIG_PANEL=3Dm
> CONFIG_PANEL_PARPORT=3D0
> CONFIG_PANEL_PROFILE=3D5
> # CONFIG_PANEL_CHANGE_MESSAGE is not set
> CONFIG_R8187SE=3Dm
> CONFIG_RTL8192U=3Dm
> CONFIG_RTL8192E=3Dm
> CONFIG_R8712U=3Dm
> CONFIG_R8712_AP=3Dy
> CONFIG_TRANZPORT=3Dm
> CONFIG_POHMELFS=3Dm
> # CONFIG_POHMELFS_DEBUG is not set
> CONFIG_POHMELFS_CRYPTO=3Dy
> CONFIG_AUTOFS_FS=3Dy
> CONFIG_IDE_PHISON=3Dm
> CONFIG_LINE6_USB=3Dm
> CONFIG_LINE6_USB_DEBUG=3Dy
> CONFIG_LINE6_USB_DUMP_CTRL=3Dy
> CONFIG_LINE6_USB_DUMP_MIDI=3Dy
> CONFIG_LINE6_USB_DUMP_PCM=3Dy
> CONFIG_LINE6_USB_RAW=3Dy
> CONFIG_LINE6_USB_IMPULSE_RESPONSE=3Dy
> CONFIG_DRM_VMWGFX=3Dm
> CONFIG_DRM_NOUVEAU=3Dm
> CONFIG_DRM_NOUVEAU_BACKLIGHT=3Dy
> CONFIG_DRM_NOUVEAU_DEBUG=3Dy
>=20
> #
> # I2C encoder or helper chips
> #
> CONFIG_DRM_I2C_CH7006=3Dm
> CONFIG_DRM_I2C_SIL164=3Dm
> CONFIG_USB_SERIAL_QUATECH2=3Dm
> CONFIG_USB_SERIAL_QUATECH_USB2=3Dm
> CONFIG_VT6655=3Dm
> CONFIG_VT6656=3Dm
> CONFIG_FB_UDL=3Dm
> # CONFIG_HYPERV is not set
> CONFIG_VME_BUS=3Dm
>=20
> #
> # VME Bridge Drivers
> #
> CONFIG_VME_CA91CX42=3Dm
> CONFIG_VME_TSI148=3Dm
>=20
> #
> # VME Device Drivers
> #
> CONFIG_VME_USER=3Dm
>=20
> #
> # VME Board Drivers
> #
> CONFIG_VMIVME_7805=3Dm
> CONFIG_IIO=3Dm
> CONFIG_IIO_RING_BUFFER=3Dy
> CONFIG_IIO_SW_RING=3Dm
> CONFIG_IIO_TRIGGER=3Dy
>=20
> #
> # Accelerometers
> #
> CONFIG_ADIS16209=3Dm
> CONFIG_ADIS16220=3Dm
> CONFIG_ADIS16240=3Dm
> CONFIG_KXSD9=3Dm
> CONFIG_LIS3L02DQ=3Dm
> CONFIG_SCA3000=3Dm
>=20
> #
> # Analog to digital convertors
> #
> CONFIG_MAX1363=3Dm
> CONFIG_MAX1363_RING_BUFFER=3Dy
> CONFIG_AD799X=3Dm
> CONFIG_AD799X_RING_BUFFER=3Dy
> CONFIG_AD7476=3Dm
>=20
> #
> # Digital gyroscope sensors
> #
> CONFIG_ADIS16260=3Dm
>=20
> #
> # Inertial measurement units
> #
> CONFIG_ADIS16300=3Dm
> CONFIG_ADIS16350=3Dm
> CONFIG_ADIS16400=3Dm
>=20
> #
> # Light sensors
> #
> CONFIG_SENSORS_TSL2563=3Dm
> CONFIG_SENSORS_ISL29018=3Dm
>=20
> #
> # Magnetometer sensors
> #
> CONFIG_SENSORS_AK8975=3Dm
> CONFIG_SENSORS_HMC5843=3Dm
>=20
> #
> # Triggers - standalone
> #
> CONFIG_IIO_PERIODIC_RTC_TRIGGER=3Dm
> CONFIG_IIO_GPIO_TRIGGER=3Dm
> CONFIG_ZRAM=3Dm
> CONFIG_WLAGS49_H2=3Dm
> CONFIG_WLAGS49_H25=3Dm
> CONFIG_BATMAN_ADV=3Dm
> # CONFIG_BATMAN_ADV_DEBUG is not set
> CONFIG_SAMSUNG_LAPTOP=3Dm
> CONFIG_FB_SM7XX=3Dy
> CONFIG_VIDEO_DT3155=3Dm
> CONFIG_DT3155_CCIR=3Dy
> CONFIG_CRYSTALHD=3Dm
> CONFIG_CXT1E1=3Dm
> CONFIG_SBE_PMCC4_NCOMM=3Dy
>=20
> #
> # Texas Instruments shared transport line discipline
> #
> CONFIG_ST_BT=3Dm
> CONFIG_ADIS16255=3Dm
> CONFIG_FB_XGI=3Dy
> CONFIG_LIRC_STAGING=3Dy
> CONFIG_LIRC_BT829=3Dm
> CONFIG_LIRC_I2C=3Dm
> CONFIG_LIRC_IGORPLUGUSB=3Dm
> CONFIG_LIRC_IMON=3Dm
> CONFIG_LIRC_IT87=3Dm
> CONFIG_LIRC_ITE8709=3Dm
> CONFIG_LIRC_PARALLEL=3Dm
> CONFIG_LIRC_SASEM=3Dm
> CONFIG_LIRC_SERIAL=3Dm
> CONFIG_LIRC_SERIAL_TRANSMITTER=3Dy
> CONFIG_LIRC_SIR=3Dm
> CONFIG_LIRC_TTUSBIR=3Dm
> CONFIG_LIRC_ZILOG=3Dm
> CONFIG_SMB_FS=3Dy
> # CONFIG_SMB_NLS_DEFAULT is not set
> CONFIG_EASYCAP=3Dm
> # CONFIG_SOLO6X10 is not set
> CONFIG_ACPI_QUICKSTART=3Dy
> CONFIG_MACH_NO_WESTBRIDGE=3Dy
> CONFIG_SBE_2T3E3=3Dm
> # CONFIG_ATH6K_LEGACY is not set
> CONFIG_USB_ENESTORAGE=3Dm
> CONFIG_BCM_WIMAX=3Dm
> CONFIG_FT1000=3Dm
> CONFIG_FT1000_USB=3Dm
>=20
> #
> # Speakup console speech
> #
> CONFIG_SPEAKUP=3Dm
> CONFIG_SPEAKUP_SYNTH_ACNTSA=3Dm
> CONFIG_SPEAKUP_SYNTH_ACNTPC=3Dm
> CONFIG_SPEAKUP_SYNTH_APOLLO=3Dm
> CONFIG_SPEAKUP_SYNTH_AUDPTR=3Dm
> CONFIG_SPEAKUP_SYNTH_BNS=3Dm
> CONFIG_SPEAKUP_SYNTH_DECTLK=3Dm
> CONFIG_SPEAKUP_SYNTH_DECEXT=3Dm
> CONFIG_SPEAKUP_SYNTH_DECPC=3Dm
> CONFIG_SPEAKUP_SYNTH_DTLK=3Dm
> CONFIG_SPEAKUP_SYNTH_KEYPC=3Dm
> CONFIG_SPEAKUP_SYNTH_LTLK=3Dm
> CONFIG_SPEAKUP_SYNTH_SOFT=3Dm
> CONFIG_SPEAKUP_SYNTH_SPKOUT=3Dm
> CONFIG_SPEAKUP_SYNTH_TXPRT=3Dm
> CONFIG_SPEAKUP_SYNTH_DUMMY=3Dm
> CONFIG_X86_PLATFORM_DEVICES=3Dy
> CONFIG_ACER_WMI=3Dm
> CONFIG_ACERHDF=3Dm
> CONFIG_DELL_LAPTOP=3Dm
> CONFIG_DELL_WMI=3Dy
> CONFIG_FUJITSU_LAPTOP=3Dm
> # CONFIG_FUJITSU_LAPTOP_DEBUG is not set
> CONFIG_TC1100_WMI=3Dy
> CONFIG_HP_WMI=3Dm
> CONFIG_MSI_LAPTOP=3Dm
> CONFIG_PANASONIC_LAPTOP=3Dy
> CONFIG_COMPAL_LAPTOP=3Dm
> CONFIG_SONY_LAPTOP=3Dm
> CONFIG_SONYPI_COMPAT=3Dy
> CONFIG_IDEAPAD_LAPTOP=3Dm
> CONFIG_THINKPAD_ACPI=3Dm
> CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=3Dy
> # CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
> # CONFIG_THINKPAD_ACPI_DEBUG is not set
> CONFIG_THINKPAD_ACPI_UNSAFE_LEDS=3Dy
> CONFIG_THINKPAD_ACPI_VIDEO=3Dy
> CONFIG_THINKPAD_ACPI_HOTKEY_POLL=3Dy
> CONFIG_SENSORS_HDAPS=3Dm
> CONFIG_INTEL_MENLOW=3Dy
> CONFIG_EEEPC_LAPTOP=3Dm
> CONFIG_EEEPC_WMI=3Dm
> CONFIG_ACPI_WMI=3Dy
> CONFIG_MSI_WMI=3Dy
> CONFIG_ACPI_ASUS=3Dy
> CONFIG_TOPSTAR_LAPTOP=3Dy
> CONFIG_ACPI_TOSHIBA=3Dm
> CONFIG_TOSHIBA_BT_RFKILL=3Dy
> CONFIG_ACPI_CMPC=3Dm
> CONFIG_INTEL_IPS=3Dm
> CONFIG_IBM_RTL=3Dm
> CONFIG_XO1_RFKILL=3Dm
>=20
> #
> # Firmware Drivers
> #
> CONFIG_EDD=3Dy
> # CONFIG_EDD_OFF is not set
> CONFIG_FIRMWARE_MEMMAP=3Dy
> # CONFIG_EFI_VARS is not set
> CONFIG_DELL_RBU=3Dm
> CONFIG_DCDBAS=3Dm
> CONFIG_DMIID=3Dy
> CONFIG_ISCSI_IBFT_FIND=3Dy
> CONFIG_ISCSI_IBFT=3Dm
>=20
> #
> # File systems
> #
> CONFIG_EXT2_FS=3Dy
> CONFIG_EXT2_FS_XATTR=3Dy
> CONFIG_EXT2_FS_POSIX_ACL=3Dy
> CONFIG_EXT2_FS_SECURITY=3Dy
> CONFIG_EXT2_FS_XIP=3Dy
> CONFIG_EXT3_FS=3Dy
> CONFIG_EXT3_DEFAULTS_TO_ORDERED=3Dy
> CONFIG_EXT3_FS_XATTR=3Dy
> CONFIG_EXT3_FS_POSIX_ACL=3Dy
> CONFIG_EXT3_FS_SECURITY=3Dy
> CONFIG_EXT4_FS=3Dy
> CONFIG_EXT4_FS_XATTR=3Dy
> CONFIG_EXT4_FS_POSIX_ACL=3Dy
> CONFIG_EXT4_FS_SECURITY=3Dy
> # CONFIG_EXT4_DEBUG is not set
> CONFIG_FS_XIP=3Dy
> CONFIG_JBD=3Dy
> # CONFIG_JBD_DEBUG is not set
> CONFIG_JBD2=3Dy
> # CONFIG_JBD2_DEBUG is not set
> CONFIG_FS_MBCACHE=3Dy
> CONFIG_REISERFS_FS=3Dy
> # CONFIG_REISERFS_CHECK is not set
> # CONFIG_REISERFS_PROC_INFO is not set
> CONFIG_REISERFS_FS_XATTR=3Dy
> CONFIG_REISERFS_FS_POSIX_ACL=3Dy
> CONFIG_REISERFS_FS_SECURITY=3Dy
> CONFIG_JFS_FS=3Dy
> CONFIG_JFS_POSIX_ACL=3Dy
> CONFIG_JFS_SECURITY=3Dy
> # CONFIG_JFS_DEBUG is not set
> # CONFIG_JFS_STATISTICS is not set
> CONFIG_FS_POSIX_ACL=3Dy
> CONFIG_XFS_FS=3Dy
> CONFIG_XFS_QUOTA=3Dy
> CONFIG_XFS_POSIX_ACL=3Dy
> CONFIG_XFS_RT=3Dy
> # CONFIG_XFS_DEBUG is not set
> CONFIG_GFS2_FS=3Dy
> CONFIG_GFS2_FS_LOCKING_DLM=3Dy
> CONFIG_OCFS2_FS=3Dy
> CONFIG_OCFS2_FS_O2CB=3Dy
> CONFIG_OCFS2_FS_USERSPACE_CLUSTER=3Dy
> # CONFIG_OCFS2_FS_STATS is not set
> CONFIG_OCFS2_DEBUG_MASKLOG=3Dy
> # CONFIG_OCFS2_DEBUG_FS is not set
> CONFIG_BTRFS_FS=3Dy
> CONFIG_BTRFS_FS_POSIX_ACL=3Dy
> CONFIG_NILFS2_FS=3Dy
> CONFIG_EXPORTFS=3Dy
> CONFIG_FILE_LOCKING=3Dy
> CONFIG_FSNOTIFY=3Dy
> CONFIG_DNOTIFY=3Dy
> CONFIG_INOTIFY_USER=3Dy
> CONFIG_FANOTIFY=3Dy
> # CONFIG_FANOTIFY_ACCESS_PERMISSIONS is not set
> CONFIG_QUOTA=3Dy
> CONFIG_QUOTA_NETLINK_INTERFACE=3Dy
> # CONFIG_PRINT_QUOTA_WARNING is not set
> # CONFIG_QUOTA_DEBUG is not set
> CONFIG_QUOTA_TREE=3Dy
> CONFIG_QFMT_V1=3Dy
> CONFIG_QFMT_V2=3Dy
> CONFIG_QUOTACTL=3Dy
> CONFIG_AUTOFS4_FS=3Dy
> CONFIG_FUSE_FS=3Dy
> CONFIG_CUSE=3Dy
> CONFIG_GENERIC_ACL=3Dy
>=20
> #
> # Caches
> #
> CONFIG_FSCACHE=3Dy
> CONFIG_FSCACHE_STATS=3Dy
> CONFIG_FSCACHE_HISTOGRAM=3Dy
> # CONFIG_FSCACHE_DEBUG is not set
> # CONFIG_FSCACHE_OBJECT_LIST is not set
> CONFIG_CACHEFILES=3Dy
> # CONFIG_CACHEFILES_DEBUG is not set
> CONFIG_CACHEFILES_HISTOGRAM=3Dy
>=20
> #
> # CD-ROM/DVD Filesystems
> #
> CONFIG_ISO9660_FS=3Dy
> CONFIG_JOLIET=3Dy
> CONFIG_ZISOFS=3Dy
> CONFIG_UDF_FS=3Dy
> CONFIG_UDF_NLS=3Dy
>=20
> #
> # DOS/FAT/NT Filesystems
> #
> CONFIG_FAT_FS=3Dy
> CONFIG_MSDOS_FS=3Dy
> CONFIG_VFAT_FS=3Dy
> CONFIG_FAT_DEFAULT_CODEPAGE=3D437
> CONFIG_FAT_DEFAULT_IOCHARSET=3D"iso8859-1"
> CONFIG_NTFS_FS=3Dy
> # CONFIG_NTFS_DEBUG is not set
> CONFIG_NTFS_RW=3Dy
>=20
> #
> # Pseudo filesystems
> #
> CONFIG_PROC_FS=3Dy
> CONFIG_PROC_KCORE=3Dy
> CONFIG_PROC_SYSCTL=3Dy
> CONFIG_PROC_PAGE_MONITOR=3Dy
> CONFIG_SYSFS=3Dy
> CONFIG_TMPFS=3Dy
> CONFIG_TMPFS_POSIX_ACL=3Dy
> CONFIG_HUGETLBFS=3Dy
> CONFIG_HUGETLB_PAGE=3Dy
> CONFIG_CONFIGFS_FS=3Dy
> CONFIG_MISC_FILESYSTEMS=3Dy
> CONFIG_ADFS_FS=3Dy
> CONFIG_ADFS_FS_RW=3Dy
> CONFIG_AFFS_FS=3Dy
> CONFIG_ECRYPT_FS=3Dy
> CONFIG_HFS_FS=3Dy
> CONFIG_HFSPLUS_FS=3Dy
> CONFIG_BEFS_FS=3Dy
> # CONFIG_BEFS_DEBUG is not set
> CONFIG_BFS_FS=3Dy
> CONFIG_EFS_FS=3Dy
> CONFIG_JFFS2_FS=3Dy
> CONFIG_JFFS2_FS_DEBUG=3D0
> CONFIG_JFFS2_FS_WRITEBUFFER=3Dy
> CONFIG_JFFS2_FS_WBUF_VERIFY=3Dy
> CONFIG_JFFS2_SUMMARY=3Dy
> CONFIG_JFFS2_FS_XATTR=3Dy
> CONFIG_JFFS2_FS_POSIX_ACL=3Dy
> CONFIG_JFFS2_FS_SECURITY=3Dy
> CONFIG_JFFS2_COMPRESSION_OPTIONS=3Dy
> CONFIG_JFFS2_ZLIB=3Dy
> CONFIG_JFFS2_LZO=3Dy
> CONFIG_JFFS2_RTIME=3Dy
> CONFIG_JFFS2_RUBIN=3Dy
> # CONFIG_JFFS2_CMODE_NONE is not set
> CONFIG_JFFS2_CMODE_PRIORITY=3Dy
> # CONFIG_JFFS2_CMODE_SIZE is not set
> # CONFIG_JFFS2_CMODE_FAVOURLZO is not set
> CONFIG_UBIFS_FS=3Dy
> CONFIG_UBIFS_FS_XATTR=3Dy
> CONFIG_UBIFS_FS_ADVANCED_COMPR=3Dy
> CONFIG_UBIFS_FS_LZO=3Dy
> CONFIG_UBIFS_FS_ZLIB=3Dy
> # CONFIG_UBIFS_FS_DEBUG is not set
> # CONFIG_LOGFS is not set
> CONFIG_CRAMFS=3Dy
> CONFIG_SQUASHFS=3Dy
> CONFIG_SQUASHFS_XATTR=3Dy
> CONFIG_SQUASHFS_LZO=3Dy
> CONFIG_SQUASHFS_EMBEDDED=3Dy
> CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3D3
> CONFIG_VXFS_FS=3Dy
> CONFIG_MINIX_FS=3Dy
> CONFIG_OMFS_FS=3Dy
> CONFIG_HPFS_FS=3Dy
> CONFIG_QNX4FS_FS=3Dy
> CONFIG_ROMFS_FS=3Dy
> # CONFIG_ROMFS_BACKED_BY_BLOCK is not set
> # CONFIG_ROMFS_BACKED_BY_MTD is not set
> CONFIG_ROMFS_BACKED_BY_BOTH=3Dy
> CONFIG_ROMFS_ON_BLOCK=3Dy
> CONFIG_ROMFS_ON_MTD=3Dy
> CONFIG_SYSV_FS=3Dy
> CONFIG_UFS_FS=3Dy
> CONFIG_UFS_FS_WRITE=3Dy
> # CONFIG_UFS_DEBUG is not set
> CONFIG_EXOFS_FS=3Dy
> # CONFIG_EXOFS_DEBUG is not set
> CONFIG_NETWORK_FILESYSTEMS=3Dy
> CONFIG_NFS_FS=3Dy
> CONFIG_NFS_V3=3Dy
> CONFIG_NFS_V3_ACL=3Dy
> CONFIG_NFS_V4=3Dy
> CONFIG_NFS_V4_1=3Dy
> CONFIG_PNFS_FILE_LAYOUT=3Dy
> CONFIG_ROOT_NFS=3Dy
> CONFIG_NFS_FSCACHE=3Dy
> CONFIG_NFS_USE_LEGACY_DNS=3Dy
> CONFIG_NFS_USE_NEW_IDMAPPER=3Dy
> CONFIG_NFSD=3Dy
> CONFIG_NFSD_DEPRECATED=3Dy
> CONFIG_NFSD_V2_ACL=3Dy
> CONFIG_NFSD_V3=3Dy
> CONFIG_NFSD_V3_ACL=3Dy
> CONFIG_NFSD_V4=3Dy
> CONFIG_LOCKD=3Dy
> CONFIG_LOCKD_V4=3Dy
> CONFIG_NFS_ACL_SUPPORT=3Dy
> CONFIG_NFS_COMMON=3Dy
> CONFIG_SUNRPC=3Dy
> CONFIG_SUNRPC_GSS=3Dy
> CONFIG_SUNRPC_XPRT_RDMA=3Dm
> CONFIG_RPCSEC_GSS_KRB5=3Dy
> CONFIG_CEPH_FS=3Dm
> CONFIG_CIFS=3Dy
> CONFIG_CIFS_STATS=3Dy
> CONFIG_CIFS_STATS2=3Dy
> CONFIG_CIFS_WEAK_PW_HASH=3Dy
> CONFIG_CIFS_UPCALL=3Dy
> CONFIG_CIFS_XATTR=3Dy
> CONFIG_CIFS_POSIX=3Dy
> # CONFIG_CIFS_DEBUG2 is not set
> CONFIG_CIFS_DFS_UPCALL=3Dy
> # CONFIG_CIFS_FSCACHE is not set
> CONFIG_CIFS_EXPERIMENTAL=3Dy
> CONFIG_NCP_FS=3Dy
> CONFIG_NCPFS_PACKET_SIGNING=3Dy
> CONFIG_NCPFS_IOCTL_LOCKING=3Dy
> CONFIG_NCPFS_STRONG=3Dy
> CONFIG_NCPFS_NFS_NS=3Dy
> CONFIG_NCPFS_OS2_NS=3Dy
> CONFIG_NCPFS_SMALLDOS=3Dy
> CONFIG_NCPFS_NLS=3Dy
> CONFIG_NCPFS_EXTRAS=3Dy
> CONFIG_CODA_FS=3Dy
> CONFIG_AFS_FS=3Dy
> # CONFIG_AFS_DEBUG is not set
> CONFIG_AFS_FSCACHE=3Dy
> CONFIG_9P_FS=3Dm
> CONFIG_9P_FSCACHE=3Dy
> CONFIG_9P_FS_POSIX_ACL=3Dy
>=20
> #
> # Partition Types
> #
> CONFIG_PARTITION_ADVANCED=3Dy
> CONFIG_ACORN_PARTITION=3Dy
> CONFIG_ACORN_PARTITION_CUMANA=3Dy
> CONFIG_ACORN_PARTITION_EESOX=3Dy
> CONFIG_ACORN_PARTITION_ICS=3Dy
> CONFIG_ACORN_PARTITION_ADFS=3Dy
> CONFIG_ACORN_PARTITION_POWERTEC=3Dy
> CONFIG_ACORN_PARTITION_RISCIX=3Dy
> CONFIG_OSF_PARTITION=3Dy
> CONFIG_AMIGA_PARTITION=3Dy
> CONFIG_ATARI_PARTITION=3Dy
> CONFIG_MAC_PARTITION=3Dy
> CONFIG_MSDOS_PARTITION=3Dy
> CONFIG_BSD_DISKLABEL=3Dy
> CONFIG_MINIX_SUBPARTITION=3Dy
> CONFIG_SOLARIS_X86_PARTITION=3Dy
> CONFIG_UNIXWARE_DISKLABEL=3Dy
> CONFIG_LDM_PARTITION=3Dy
> CONFIG_LDM_DEBUG=3Dy
> CONFIG_SGI_PARTITION=3Dy
> CONFIG_ULTRIX_PARTITION=3Dy
> CONFIG_SUN_PARTITION=3Dy
> CONFIG_KARMA_PARTITION=3Dy
> CONFIG_EFI_PARTITION=3Dy
> CONFIG_SYSV68_PARTITION=3Dy
> CONFIG_NLS=3Dy
> CONFIG_NLS_DEFAULT=3D"utf8"
> CONFIG_NLS_CODEPAGE_437=3Dy
> CONFIG_NLS_CODEPAGE_737=3Dm
> CONFIG_NLS_CODEPAGE_775=3Dm
> CONFIG_NLS_CODEPAGE_850=3Dy
> CONFIG_NLS_CODEPAGE_852=3Dy
> CONFIG_NLS_CODEPAGE_855=3Dm
> CONFIG_NLS_CODEPAGE_857=3Dm
> CONFIG_NLS_CODEPAGE_860=3Dy
> CONFIG_NLS_CODEPAGE_861=3Dm
> # CONFIG_NLS_CODEPAGE_862 is not set
> CONFIG_NLS_CODEPAGE_863=3Dm
> CONFIG_NLS_CODEPAGE_864=3Dy
> CONFIG_NLS_CODEPAGE_865=3Dm
> CONFIG_NLS_CODEPAGE_866=3Dy
> CONFIG_NLS_CODEPAGE_869=3Dm
> CONFIG_NLS_CODEPAGE_936=3Dy
> CONFIG_NLS_CODEPAGE_950=3Dm
> CONFIG_NLS_CODEPAGE_932=3Dy
> CONFIG_NLS_CODEPAGE_949=3Dm
> CONFIG_NLS_CODEPAGE_874=3Dm
> # CONFIG_NLS_ISO8859_8 is not set
> CONFIG_NLS_CODEPAGE_1250=3Dm
> CONFIG_NLS_CODEPAGE_1251=3Dm
> CONFIG_NLS_ASCII=3Dm
> CONFIG_NLS_ISO8859_1=3Dy
> CONFIG_NLS_ISO8859_2=3Dm
> CONFIG_NLS_ISO8859_3=3Dm
> CONFIG_NLS_ISO8859_4=3Dm
> CONFIG_NLS_ISO8859_5=3Dy
> CONFIG_NLS_ISO8859_6=3Dy
> CONFIG_NLS_ISO8859_7=3Dm
> CONFIG_NLS_ISO8859_9=3Dm
> CONFIG_NLS_ISO8859_13=3Dm
> CONFIG_NLS_ISO8859_14=3Dm
> CONFIG_NLS_ISO8859_15=3Dy
> CONFIG_NLS_KOI8_R=3Dy
> CONFIG_NLS_KOI8_U=3Dm
> CONFIG_NLS_UTF8=3Dy
> CONFIG_DLM=3Dy
> # CONFIG_DLM_DEBUG is not set
>=20
> #
> # Kernel hacking
> #
> CONFIG_TRACE_IRQFLAGS_SUPPORT=3Dy
> # CONFIG_PRINTK_TIME is not set
> CONFIG_ENABLE_WARN_DEPRECATED=3Dy
> CONFIG_ENABLE_MUST_CHECK=3Dy
> CONFIG_FRAME_WARN=3D0
> CONFIG_MAGIC_SYSRQ=3Dy
> # CONFIG_STRIP_ASM_SYMS is not set
> CONFIG_UNUSED_SYMBOLS=3Dy
> CONFIG_DEBUG_FS=3Dy
> # CONFIG_HEADERS_CHECK is not set
> # CONFIG_DEBUG_KERNEL is not set
> # CONFIG_HARDLOCKUP_DETECTOR is not set
> # CONFIG_SLUB_DEBUG_ON is not set
> # CONFIG_SLUB_STATS is not set
> CONFIG_BKL=3Dy
> # CONFIG_SPARSE_RCU_POINTER is not set
> CONFIG_STACKTRACE=3Dy
> CONFIG_DEBUG_BUGVERBOSE=3Dy
> CONFIG_DEBUG_MEMORY_INIT=3Dy
> CONFIG_ARCH_WANT_FRAME_POINTERS=3Dy
> CONFIG_FRAME_POINTER=3Dy
> # CONFIG_RCU_CPU_STALL_DETECTOR is not set
> # CONFIG_LKDTM is not set
> CONFIG_SYSCTL_SYSCALL_CHECK=3Dy
> CONFIG_USER_STACKTRACE_SUPPORT=3Dy
> CONFIG_NOP_TRACER=3Dy
> CONFIG_HAVE_FUNCTION_TRACER=3Dy
> CONFIG_HAVE_FUNCTION_GRAPH_TRACER=3Dy
> CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=3Dy
> CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=3Dy
> CONFIG_HAVE_DYNAMIC_FTRACE=3Dy
> CONFIG_HAVE_FTRACE_MCOUNT_RECORD=3Dy
> CONFIG_HAVE_SYSCALL_TRACEPOINTS=3Dy
> CONFIG_HAVE_C_RECORDMCOUNT=3Dy
> CONFIG_RING_BUFFER=3Dy
> CONFIG_EVENT_TRACING=3Dy
> CONFIG_CONTEXT_SWITCH_TRACER=3Dy
> CONFIG_RING_BUFFER_ALLOW_SWAP=3Dy
> CONFIG_TRACING=3Dy
> CONFIG_GENERIC_TRACER=3Dy
> CONFIG_TRACING_SUPPORT=3Dy
> CONFIG_FTRACE=3Dy
> CONFIG_FUNCTION_TRACER=3Dy
> # CONFIG_IRQSOFF_TRACER is not set
> # CONFIG_PREEMPT_TRACER is not set
> # CONFIG_SCHED_TRACER is not set
> # CONFIG_FTRACE_SYSCALLS is not set
> CONFIG_BRANCH_PROFILE_NONE=3Dy
> # CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
> # CONFIG_PROFILE_ALL_BRANCHES is not set
> # CONFIG_STACK_TRACER is not set
> # CONFIG_BLK_DEV_IO_TRACE is not set
> # CONFIG_DYNAMIC_FTRACE is not set
> # CONFIG_FUNCTION_PROFILER is not set
> # CONFIG_FTRACE_STARTUP_TEST is not set
> # CONFIG_MMIOTRACE is not set
> # CONFIG_RING_BUFFER_BENCHMARK is not set
> # CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
> # CONFIG_FIREWIRE_OHCI_REMOTE_DMA is not set
> # CONFIG_DYNAMIC_DEBUG is not set
> # CONFIG_DMA_API_DEBUG is not set
> # CONFIG_ATOMIC64_SELFTEST is not set
> CONFIG_ASYNC_RAID6_TEST=3Dy
> # CONFIG_SAMPLES is not set
> CONFIG_HAVE_ARCH_KGDB=3Dy
> CONFIG_HAVE_ARCH_KMEMCHECK=3Dy
> CONFIG_STRICT_DEVMEM=3Dy
> CONFIG_X86_VERBOSE_BOOTUP=3Dy
> CONFIG_EARLY_PRINTK=3Dy
> # CONFIG_EARLY_PRINTK_DBGP is not set
> CONFIG_DOUBLEFAULT=3Dy
> # CONFIG_IOMMU_STRESS is not set
> CONFIG_HAVE_MMIOTRACE_SUPPORT=3Dy
> CONFIG_IO_DELAY_TYPE_0X80=3D0
> CONFIG_IO_DELAY_TYPE_0XED=3D1
> CONFIG_IO_DELAY_TYPE_UDELAY=3D2
> CONFIG_IO_DELAY_TYPE_NONE=3D3
> CONFIG_IO_DELAY_0X80=3Dy
> # CONFIG_IO_DELAY_0XED is not set
> # CONFIG_IO_DELAY_UDELAY is not set
> # CONFIG_IO_DELAY_NONE is not set
> CONFIG_DEFAULT_IO_DELAY_TYPE=3D0
> # CONFIG_OPTIMIZE_INLINING is not set
>=20
> #
> # Security options
> #
> CONFIG_KEYS=3Dy
> CONFIG_KEYS_DEBUG_PROC_KEYS=3Dy
> CONFIG_SECURITY=3Dy
> CONFIG_SECURITYFS=3Dy
> CONFIG_SECURITY_NETWORK=3Dy
> CONFIG_SECURITY_NETWORK_XFRM=3Dy
> # CONFIG_SECURITY_PATH is not set
> # CONFIG_SECURITY_SELINUX is not set
> # CONFIG_SECURITY_SMACK is not set
> # CONFIG_SECURITY_TOMOYO is not set
> # CONFIG_SECURITY_APPARMOR is not set
> # CONFIG_IMA is not set
> CONFIG_DEFAULT_SECURITY_DAC=3Dy
> CONFIG_DEFAULT_SECURITY=3D""
> CONFIG_XOR_BLOCKS=3Dy
> CONFIG_ASYNC_CORE=3Dy
> CONFIG_ASYNC_MEMCPY=3Dy
> CONFIG_ASYNC_XOR=3Dy
> CONFIG_ASYNC_PQ=3Dy
> CONFIG_ASYNC_RAID6_RECOV=3Dy
> CONFIG_ASYNC_TX_DISABLE_PQ_VAL_DMA=3Dy
> CONFIG_ASYNC_TX_DISABLE_XOR_VAL_DMA=3Dy
> CONFIG_CRYPTO=3Dy
>=20
> #
> # Crypto core or helper
> #
> CONFIG_CRYPTO_ALGAPI=3Dy
> CONFIG_CRYPTO_ALGAPI2=3Dy
> CONFIG_CRYPTO_AEAD=3Dy
> CONFIG_CRYPTO_AEAD2=3Dy
> CONFIG_CRYPTO_BLKCIPHER=3Dy
> CONFIG_CRYPTO_BLKCIPHER2=3Dy
> CONFIG_CRYPTO_HASH=3Dy
> CONFIG_CRYPTO_HASH2=3Dy
> CONFIG_CRYPTO_RNG=3Dm
> CONFIG_CRYPTO_RNG2=3Dy
> CONFIG_CRYPTO_PCOMP=3Dm
> CONFIG_CRYPTO_PCOMP2=3Dy
> CONFIG_CRYPTO_MANAGER=3Dy
> CONFIG_CRYPTO_MANAGER2=3Dy
> CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=3Dy
> CONFIG_CRYPTO_GF128MUL=3Dy
> CONFIG_CRYPTO_NULL=3Dy
> CONFIG_CRYPTO_PCRYPT=3Dm
> CONFIG_CRYPTO_WORKQUEUE=3Dy
> CONFIG_CRYPTO_CRYPTD=3Dm
> CONFIG_CRYPTO_AUTHENC=3Dy
> CONFIG_CRYPTO_TEST=3Dm
>=20
> #
> # Authenticated Encryption with Associated Data
> #
> CONFIG_CRYPTO_CCM=3Dm
> CONFIG_CRYPTO_GCM=3Dm
> CONFIG_CRYPTO_SEQIV=3Dm
>=20
> #
> # Block modes
> #
> CONFIG_CRYPTO_CBC=3Dy
> CONFIG_CRYPTO_CTR=3Dm
> CONFIG_CRYPTO_CTS=3Dm
> CONFIG_CRYPTO_ECB=3Dy
> CONFIG_CRYPTO_LRW=3Dy
> CONFIG_CRYPTO_PCBC=3Dy
> CONFIG_CRYPTO_XTS=3Dy
>=20
> #
> # Hash modes
> #
> CONFIG_CRYPTO_HMAC=3Dy
> CONFIG_CRYPTO_XCBC=3Dy
> CONFIG_CRYPTO_VMAC=3Dm
>=20
> #
> # Digest
> #
> CONFIG_CRYPTO_CRC32C=3Dy
> CONFIG_CRYPTO_CRC32C_INTEL=3Dm
> CONFIG_CRYPTO_GHASH=3Dm
> CONFIG_CRYPTO_MD4=3Dy
> CONFIG_CRYPTO_MD5=3Dy
> CONFIG_CRYPTO_MICHAEL_MIC=3Dy
> CONFIG_CRYPTO_RMD128=3Dm
> CONFIG_CRYPTO_RMD160=3Dm
> CONFIG_CRYPTO_RMD256=3Dm
> CONFIG_CRYPTO_RMD320=3Dm
> CONFIG_CRYPTO_SHA1=3Dy
> CONFIG_CRYPTO_SHA256=3Dy
> CONFIG_CRYPTO_SHA512=3Dy
> CONFIG_CRYPTO_TGR192=3Dy
> CONFIG_CRYPTO_WP512=3Dy
>=20
> #
> # Ciphers
> #
> CONFIG_CRYPTO_AES=3Dy
> CONFIG_CRYPTO_AES_586=3Dy
> CONFIG_CRYPTO_ANUBIS=3Dy
> CONFIG_CRYPTO_ARC4=3Dy
> CONFIG_CRYPTO_BLOWFISH=3Dy
> CONFIG_CRYPTO_CAMELLIA=3Dy
> CONFIG_CRYPTO_CAST5=3Dy
> CONFIG_CRYPTO_CAST6=3Dy
> CONFIG_CRYPTO_DES=3Dy
> CONFIG_CRYPTO_FCRYPT=3Dy
> CONFIG_CRYPTO_KHAZAD=3Dy
> CONFIG_CRYPTO_SALSA20=3Dm
> CONFIG_CRYPTO_SALSA20_586=3Dm
> CONFIG_CRYPTO_SEED=3Dy
> CONFIG_CRYPTO_SERPENT=3Dy
> CONFIG_CRYPTO_TEA=3Dy
> CONFIG_CRYPTO_TWOFISH=3Dy
> CONFIG_CRYPTO_TWOFISH_COMMON=3Dy
> CONFIG_CRYPTO_TWOFISH_586=3Dy
>=20
> #
> # Compression
> #
> CONFIG_CRYPTO_DEFLATE=3Dy
> CONFIG_CRYPTO_ZLIB=3Dm
> CONFIG_CRYPTO_LZO=3Dy
>=20
> #
> # Random Number Generation
> #
> # CONFIG_CRYPTO_ANSI_CPRNG is not set
> CONFIG_CRYPTO_HW=3Dy
> CONFIG_CRYPTO_DEV_PADLOCK=3Dm
> CONFIG_CRYPTO_DEV_PADLOCK_AES=3Dm
> CONFIG_CRYPTO_DEV_PADLOCK_SHA=3Dm
> CONFIG_CRYPTO_DEV_GEODE=3Dm
> CONFIG_CRYPTO_DEV_HIFN_795X=3Dm
> CONFIG_CRYPTO_DEV_HIFN_795X_RNG=3Dy
> CONFIG_HAVE_KVM=3Dy
> CONFIG_HAVE_KVM_IRQCHIP=3Dy
> CONFIG_HAVE_KVM_EVENTFD=3Dy
> CONFIG_KVM_APIC_ARCHITECTURE=3Dy
> CONFIG_KVM_MMIO=3Dy
> CONFIG_VIRTUALIZATION=3Dy
> CONFIG_KVM=3Dm
> CONFIG_KVM_INTEL=3Dm
> CONFIG_KVM_AMD=3Dm
> # CONFIG_KVM_MMU_AUDIT is not set
> CONFIG_VHOST_NET=3Dm
> # CONFIG_LGUEST is not set
> CONFIG_VIRTIO=3Dy
> CONFIG_VIRTIO_RING=3Dy
> CONFIG_VIRTIO_PCI=3Dm
> CONFIG_VIRTIO_BALLOON=3Dm
> CONFIG_BINARY_PRINTF=3Dy
>=20
> #
> # Library routines
> #
> CONFIG_RAID6_PQ=3Dy
> CONFIG_BITREVERSE=3Dy
> CONFIG_GENERIC_FIND_FIRST_BIT=3Dy
> CONFIG_GENERIC_FIND_NEXT_BIT=3Dy
> CONFIG_GENERIC_FIND_LAST_BIT=3Dy
> CONFIG_CRC_CCITT=3Dy
> CONFIG_CRC16=3Dy
> CONFIG_CRC_T10DIF=3Dy
> CONFIG_CRC_ITU_T=3Dy
> CONFIG_CRC32=3Dy
> CONFIG_CRC7=3Dy
> CONFIG_LIBCRC32C=3Dy
> CONFIG_AUDIT_GENERIC=3Dy
> CONFIG_ZLIB_INFLATE=3Dy
> CONFIG_ZLIB_DEFLATE=3Dy
> CONFIG_LZO_COMPRESS=3Dy
> CONFIG_LZO_DECOMPRESS=3Dy
> CONFIG_DECOMPRESS_GZIP=3Dy
> CONFIG_DECOMPRESS_BZIP2=3Dy
> CONFIG_DECOMPRESS_LZMA=3Dy
> CONFIG_DECOMPRESS_LZO=3Dy
> CONFIG_GENERIC_ALLOCATOR=3Dy
> CONFIG_REED_SOLOMON=3Dy
> CONFIG_REED_SOLOMON_DEC16=3Dy
> CONFIG_TEXTSEARCH=3Dy
> CONFIG_TEXTSEARCH_KMP=3Dm
> CONFIG_TEXTSEARCH_BM=3Dm
> CONFIG_TEXTSEARCH_FSM=3Dm
> CONFIG_HAS_IOMEM=3Dy
> CONFIG_HAS_IOPORT=3Dy
> CONFIG_HAS_DMA=3Dy
> CONFIG_CHECK_SIGNATURE=3Dy
> CONFIG_NLATTR=3Dy
> CONFIG_LRU_CACHE=3Dm
> ---
> Professional hosting for everyone - http://www.host.ru
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20
