From: Tomas Papan <tomas.papan@gmail.com>
Subject: Re: 3.4-rc: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Tue, 12 Jun 2012 07:12:52 +0200
Message-ID: <CAMGsXDT5xu_+gHber-XS=wv9RW7kyUzHNUJN87CuJuNevDuxSw@mail.gmail.com>
References: <20120501182405.3dda59b9@stein>
	<20120501172748.GA17117@electric-eye.fr.zoreil.com>
	<20120501200423.6804dcf0@stein>
	<20120501200403.GA20763@electric-eye.fr.zoreil.com>
	<20120503204813.65468df7@stein>
	<20120602111335.0b94fb59@stein>
	<loom.20120611T175322-643@post.gmane.org>
	<20120611204925.GA7070@electric-eye.fr.zoreil.com>
	<CAMGsXDRjqsgL=KCR=dQGTNhBS7G-AK-VtDEVT+8bUUqFUR5HsA@mail.gmail.com>
	<20120611215203.GA8860@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:63853 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab2FLFMx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 01:12:53 -0400
Received: by pbbrp8 with SMTP id rp8so283950pbb.19
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 22:12:52 -0700 (PDT)
In-Reply-To: <20120611215203.GA8860@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

the XID is

[    2.780758] r8169 0000:03:00.0: eth1: RTL8168e/8111e at
0xffffc9000001c000, 80:ee:73:10:ad:44, XID 0c200000 IRQ 46


and the complete dmesg

[    0.000000] Linux version 3.4.2 (root@anakin) (gcc version 4.5.3
(Gentoo 4.5.3-r2 p1.5, pie-0.4.7) ) #1 SMP PREEMPT Mon Jun 11 14:27:18
CEST 2012
[    0.000000] Command line: panic=3D3
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009e800 (usable)
[    0.000000]  BIOS-e820: 000000000009e800 - 00000000000a0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000000100000 - 00000000bf780000 (usable)
[    0.000000]  BIOS-e820: 00000000bf780000 - 00000000bf78e000 (ACPI da=
ta)
[    0.000000]  BIOS-e820: 00000000bf78e000 - 00000000bf7d0000 (ACPI NV=
S)
[    0.000000]  BIOS-e820: 00000000bf7d0000 - 00000000bf7e0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000bf7ed000 - 00000000c0000000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000ffb00000 - 0000000100000000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000100000000 - 0000000440000000 (usable)
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI present.
[    0.000000] DMI: Shuttle Inc. SH55J/SH55J, BIOS 080015  09/01/2010
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000
(usable) =3D=3D> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (=
usable)
[    0.000000] No AGP bridge found
[    0.000000] last_pfn =3D 0x440000 max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-E3FFF write-protect
[    0.000000]   E4000-E7FFF write-through
[    0.000000]   E8000-EBFFF write-protect
[    0.000000]   EC000-EFFFF write-through
[    0.000000]   F0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask C00000000 write-back
[    0.000000]   1 base 400000000 mask FC0000000 write-back
[    0.000000]   2 base 0C0000000 mask FC0000000 uncachable
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70106=
00070106
[    0.000000] e820 update range: 00000000c0000000 - 0000000100000000
(usable) =3D=3D> (reserved)
[    0.000000] last_pfn =3D 0xbf780 max_arch_pfn =3D 0x400000000
[    0.000000] initial memory mapped : 0 - 20000000
[    0.000000] Base memory trampoline at [ffff88000009c000] 9c000 size =
8192
[    0.000000] init_memory_mapping: 0000000000000000-00000000bf780000
[    0.000000]  0000000000 - 00bf600000 page 2M
[    0.000000]  00bf600000 - 00bf780000 page 4k
[    0.000000] kernel direct mapping tables up to bf780000 @ 1fffb000-2=
0000000
[    0.000000] init_memory_mapping: 0000000100000000-0000000440000000
[    0.000000]  0100000000 - 0440000000 page 2M
[    0.000000] kernel direct mapping tables up to 440000000 @ bf76e000-=
bf780000
[    0.000000] RAMDISK: 37edb000 - 37ff0000
[    0.000000] ACPI: RSDP 00000000000f9b10 00024 (v02 ACPIAM)
[    0.000000] ACPI: XSDT 00000000bf780100 0006C (v01 Shuttl Shuttle
20100901 MSFT 00000097)
[    0.000000] ACPI: FACP 00000000bf780290 000F4 (v03 090110 FACP1159
20100901 MSFT 00000097)
[    0.000000] ACPI: DSDT 00000000bf7805e0 0653F (v01 Shuttl SH55JV10
00000001 INTL 20051117)
[    0.000000] ACPI: FACS 00000000bf78e000 00040
[    0.000000] ACPI: APIC 00000000bf780390 0008C (v01 090110 APIC1159
20100901 MSFT 00000097)
[    0.000000] ACPI: MCFG 00000000bf780420 0003C (v01 090110 OEMMCFG
20100901 MSFT 00000097)
[    0.000000] ACPI: SLIC 00000000bf780460 00176 (v01 Shuttl Shuttle
20100901 MSFT 00000097)
[    0.000000] ACPI: OEMB 00000000bf78e040 00072 (v01 090110 OEMB1159
20100901 MSFT 00000097)
[    0.000000] ACPI: HPET 00000000bf78a5e0 00038 (v01 090110 OEMHPET
20100901 MSFT 00000097)
[    0.000000] ACPI: GSCI 00000000bf78e0c0 02024 (v01 090110 GMCHSCI
20100901 MSFT 00000097)
[    0.000000] ACPI: DMAR 00000000bf7900f0 00090 (v01    AMI  OEMDMAR
00000001 MSFT 00000097)
[    0.000000] ACPI: SSDT 00000000bf7913c0 00363 (v01 DpgPmm    CpuPm
00000012 INTL 20051117)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x00440000
[    0.000000] Movable zone start PFN for each node
[    0.000000] Early memory PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009e
[    0.000000]     0: 0x00000100 -> 0x000bf780
[    0.000000]     0: 0x00100000 -> 0x00440000
[    0.000000] On node 0 totalpages: 4192014
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 2 pages reserved
[    0.000000]   DMA zone: 3916 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 16320 pages used for memmap
[    0.000000]   DMA32 zone: 763840 pages, LIFO batch:31
[    0.000000]   Normal zone: 53248 pages used for memmap
[    0.000000]   Normal zone: 3354624 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x06] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x84] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x85] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x86] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x87] disabled)
[    0.000000] ACPI: IOAPIC (id[0x07] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 7, version 32, address 0xfec00000, GS=
I 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[    0.000000] SMP: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] Allocating PCI resources starting at c0000000 (gap:
c0000000:3ee00000)
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:4
nr_node_ids:1
[    0.000000] PERCPU: Embedded 25 pages/cpu @ffff88043fc00000 s70976
r8192 d23232 u524288
[    0.000000] pcpu-alloc: s70976 r8192 d23232 u524288 alloc=3D1*209715=
2
[    0.000000] pcpu-alloc: [0] 0 1 2 3
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.
Total pages: 4122380
[    0.000000] Kernel command line: panic=3D3
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 2097152 (order: 12,
16777216 bytes)
[    0.000000] Inode-cache hash table entries: 1048576 (order: 11,
8388608 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bai=
ling!
[    0.000000] Memory: 16408404k/17825792k available (2964k kernel
code, 1057736k absent, 359652k reserved, 1296k data, 452k init)
[    0.000000] SLUB: Genslabs=3D15, HWalign=3D64, Order=3D0-3, MinObjec=
ts=3D0,
CPUs=3D4, Nodes=3D1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] NR_IRQS:4352 nr_irqs:712 16
[    0.000000] Extended CMOS year: 2000
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] Fast TSC calibration using PIT
[    0.001000] Detected 2798.395 MHz processor.
[    0.000002] Calibrating delay loop (skipped), value calculated
using timer frequency.. 5596.79 BogoMIPS (lpj=3D2798395)
[    0.000008] pid_max: default: 32768 minimum: 301
[    0.000032] Mount-cache hash table entries: 256
[    0.000161] CPU: Physical Processor ID: 0
[    0.000164] CPU: Processor Core ID: 0
[    0.000169] mce: CPU supports 9 MCE banks
[    0.000179] CPU0: Thermal monitoring enabled (TM1)
[    0.000186] using mwait in idle threads.
[    0.000252] Freeing SMP alternatives: 16k freed
[    0.000260] ACPI: Core revision 20120320
[    0.002924] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin=
2=3D-1
[    0.012904] CPU0: Intel(R) Core(TM) i5 CPU         760  @ 2.80GHz st=
epping 05
[    0.114361] Performance Events: PEBS fmt1+, 16-deep LBR, Nehalem
events, Intel PMU driver.
[    0.114369] CPU erratum AAJ80 worked around
[    0.114372] CPUID marked event: 'bus cycles' unavailable
[    0.114375] ... version:                3
[    0.114378] ... bit width:              48
[    0.114380] ... generic registers:      4
[    0.114382] ... value mask:             0000ffffffffffff
[    0.114385] ... max period:             000000007fffffff
[    0.114388] ... fixed-purpose events:   3
[    0.114390] ... event mask:             000000070000000f
[    0.126335] Booting Node   0, Processors  #1 #2 #3 Ok.
[    0.173435] Brought up 4 CPUs
[    0.173440] Total of 4 processors activated (22387.16 BogoMIPS).
[    0.175918] devtmpfs: initialized
[    0.176041] NET: Registered protocol family 16
[    0.176159] ACPI: bus type pci registered
[    0.176165] PCI: Using configuration type 1 for base access
[    0.177864] bio: create slab <bio-0> at 0
[    0.177909] ACPI: Added _OSI(Module Device)
[    0.177912] ACPI: Added _OSI(Processor Device)
[    0.177915] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.177918] ACPI: Added _OSI(Processor Aggregator Device)
[    0.178667] ACPI: EC: Look up EC in DSDT
[    0.179677] ACPI: Executed 1 blocks of module-level executable AML c=
ode
[    0.181723] ACPI: SSDT 00000000bf790180 01238 (v01 DpgPmm  P001Ist
00000011 INTL 20051117)
[    0.181947] ACPI: Dynamic OEM Table Load:
[    0.181951] ACPI: SSDT           (null) 01238 (v01 DpgPmm  P001Ist
00000011 INTL 20051117)
[    0.182293] ACPI: Interpreter enabled
[    0.182296] ACPI: (supports S0 S5)
[    0.182303] ACPI: Using IOAPIC for interrupt routing
[    0.188000] PCI: Using host bridge windows from ACPI; if necessary,
use "pci=3Dnocrs" and report a bug
[    0.188065] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.188170] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0c=
f7]
[    0.188174] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xff=
ff]
[    0.188178] pci_root PNP0A08:00: host bridge window [mem
0x000a0000-0x000bffff]
[    0.188182] pci_root PNP0A08:00: host bridge window [mem
0x000d0000-0x000dffff]
[    0.188186] pci_root PNP0A08:00: host bridge window [mem
0xc0000000-0xdfffffff]
[    0.188191] pci_root PNP0A08:00: host bridge window [mem
0xf0000000-0xfed8ffff]
[    0.188220] PCI host bridge to bus 0000:00
[    0.188223] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.188227] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.188230] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000=
bffff]
[    0.188234] pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000=
dffff]
[    0.188238] pci_bus 0000:00: root bus resource [mem 0xc0000000-0xdff=
fffff]
[    0.188241] pci_bus 0000:00: root bus resource [mem 0xf0000000-0xfed=
8ffff]
[    0.188252] pci 0000:00:00.0: [8086:d131] type 00 class 0x060000
[    0.188296] pci 0000:00:03.0: [8086:d138] type 01 class 0x060400
[    0.188339] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[    0.188355] pci 0000:00:08.0: [8086:d155] type 00 class 0x088000
[    0.188404] pci 0000:00:08.1: [8086:d156] type 00 class 0x088000
[    0.188453] pci 0000:00:08.2: [8086:d157] type 00 class 0x088000
[    0.188499] pci 0000:00:08.3: [8086:d158] type 00 class 0x088000
[    0.188543] pci 0000:00:10.0: [8086:d150] type 00 class 0x088000
[    0.188581] pci 0000:00:10.1: [8086:d151] type 00 class 0x088000
[    0.188638] pci 0000:00:1a.0: [8086:3b3c] type 00 class 0x0c0320
[    0.188657] pci 0000:00:1a.0: reg 10: [mem 0xfbefc000-0xfbefc3ff]
[    0.188738] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    0.188758] pci 0000:00:1c.0: [8086:3b42] type 01 class 0x060400
[    0.188819] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.188837] pci 0000:00:1c.1: [8086:3b44] type 01 class 0x060400
[    0.188898] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.188925] pci 0000:00:1d.0: [8086:3b34] type 00 class 0x0c0320
[    0.188944] pci 0000:00:1d.0: reg 10: [mem 0xfbefa000-0xfbefa3ff]
[    0.189025] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    0.189043] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
[    0.189098] pci 0000:00:1f.0: [8086:3b06] type 00 class 0x060100
[    0.189213] pci 0000:00:1f.2: [8086:3b22] type 00 class 0x010601
[    0.189230] pci 0000:00:1f.2: reg 10: [io  0xcc00-0xcc07]
[    0.189237] pci 0000:00:1f.2: reg 14: [io  0xc880-0xc883]
[    0.189243] pci 0000:00:1f.2: reg 18: [io  0xc800-0xc807]
[    0.189250] pci 0000:00:1f.2: reg 1c: [io  0xc480-0xc483]
[    0.189257] pci 0000:00:1f.2: reg 20: [io  0xc400-0xc41f]
[    0.189264] pci 0000:00:1f.2: reg 24: [mem 0xfbef8000-0xfbef87ff]
[    0.189304] pci 0000:00:1f.2: PME# supported from D3hot
[    0.189319] pci 0000:00:1f.3: [8086:3b30] type 00 class 0x0c0500
[    0.189332] pci 0000:00:1f.3: reg 10: [mem 0xfbef6000-0xfbef60ff 64b=
it]
[    0.189351] pci 0000:00:1f.3: reg 20: [io  0x0400-0x041f]
[    0.189416] pci 0000:01:00.0: [10ec:8168] type 00 class 0x020000
[    0.189429] pci 0000:01:00.0: reg 10: [io  0xd800-0xd8ff]
[    0.189452] pci 0000:01:00.0: reg 18: [mem 0xfbffb000-0xfbffbfff 64b=
it]
[    0.189479] pci 0000:01:00.0: reg 30: [mem 0xfbfc0000-0xfbfdffff pre=
f]
[    0.189539] pci 0000:01:00.0: supports D1 D2
[    0.189540] pci 0000:01:00.0: PME# supported from D1 D2 D3hot D3cold
[    0.189552] pci 0000:01:00.0: disabling ASPM on pre-1.1 PCIe
device.  You can enable it with 'pcie_aspm=3Dforce'
[    0.189563] pci 0000:00:03.0: PCI bridge to [bus 01-01]
[    0.189567] pci 0000:00:03.0:   bridge window [io  0xd000-0xdfff]
[    0.189570] pci 0000:00:03.0:   bridge window [mem 0xfbf00000-0xfbff=
ffff]
[    0.189606] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
[    0.189665] pci 0000:03:00.0: [10ec:8168] type 00 class 0x020000
[    0.189679] pci 0000:03:00.0: reg 10: [io  0xe800-0xe8ff]
[    0.189705] pci 0000:03:00.0: reg 18: [mem 0xfafff000-0xfaffffff 64b=
it pref]
[    0.189722] pci 0000:03:00.0: reg 20: [mem 0xfaff8000-0xfaffbfff 64b=
it pref]
[    0.189792] pci 0000:03:00.0: supports D1 D2
[    0.189794] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3c=
old
[    0.191174] pci 0000:00:1c.1: PCI bridge to [bus 03-03]
[    0.191184] pci 0000:00:1c.1:   bridge window [io  0xe000-0xefff]
[    0.191195] pci 0000:00:1c.1:   bridge window [mem
0xfaf00000-0xfaffffff 64bit pref]
[    0.191270] pci 0000:00:1e.0: PCI bridge to [bus 04-04] (subtractive=
 decode)
[    0.191280] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7]
(subtractive decode)
[    0.191282] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff]
(subtractive decode)
[    0.191284] pci 0000:00:1e.0:   bridge window [mem
0x000a0000-0x000bffff] (subtractive decode)
[    0.191286] pci 0000:00:1e.0:   bridge window [mem
0x000d0000-0x000dffff] (subtractive decode)
[    0.191288] pci 0000:00:1e.0:   bridge window [mem
0xc0000000-0xdfffffff] (subtractive decode)
[    0.191290] pci 0000:00:1e.0:   bridge window [mem
0xf0000000-0xfed8ffff] (subtractive decode)
[    0.191305] pci_bus 0000:00: on NUMA node 0
[    0.191307] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.191461] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.BR20._PRT]
[    0.191484] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.BR21._PRT]
[    0.191513] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2._PRT]
[    0.191534]  pci0000:00: Unable to request _OSC control (_OSC
support mask: 0x1e)
[    0.197033] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 6 7 *10 11 12 =
14 15)
[    0.197069] ACPI: PCI Interrupt Link [LNKB] (IRQs *5)
[    0.197101] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 6 7 10 11 12 *=
14 15)
[    0.197135] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 6 7 10 11 12 1=
4 *15)
[    0.197172] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 6 7 10 11 12
14 15) *0, disabled.
[    0.197208] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 6 7 10 11 12
14 15) *0, disabled.
[    0.197244] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 6 7 10 11 12
14 15) *0, disabled.
[    0.197279] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 6 7 10 *11 12 =
14 15)
[    0.197372] vgaarb: loaded
[    0.197443] SCSI subsystem initialized
[    0.197483] libata version 3.00 loaded.
[    0.197520] usbcore: registered new interface driver usbfs
[    0.197539] usbcore: registered new interface driver hub
[    0.197561] usbcore: registered new device driver usb
[    0.197646] PCI: Using ACPI for IRQ routing
[    0.197649] PCI: pci_cache_line_size set to 64 bytes
[    0.197692] reserve RAM buffer: 000000000009e800 - 000000000009ffff
[    0.197694] reserve RAM buffer: 00000000bf780000 - 00000000bfffffff
[    0.197805] HPET: 8 timers in total, 4 timers will be used for per-c=
pu timer
[    0.197814] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 40, 41, 42, 43, 0,=
 0
[    0.197822] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    0.200157] hpet: hpet2 irq 40 for MSI
[    0.201443] hpet: hpet3 irq 41 for MSI
[    0.202454] hpet: hpet4 irq 42 for MSI
[    0.203448] hpet: hpet5 irq 43 for MSI
[    0.203464] Switching to clocksource hpet
[    0.203533] pnp: PnP ACPI init
[    0.203539] ACPI: bus type pnp registered
[    0.203613] pnp 00:00: [bus 00-ff]
[    0.203615] pnp 00:00: [io  0x0cf8-0x0cff]
[    0.203616] pnp 00:00: [io  0x0000-0x0cf7 window]
[    0.203618] pnp 00:00: [io  0x0d00-0xffff window]
[    0.203620] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    0.203621] pnp 00:00: [mem 0x000d0000-0x000dffff window]
[    0.203623] pnp 00:00: [mem 0xc0000000-0xdfffffff window]
[    0.203625] pnp 00:00: [mem 0xf0000000-0xfed8ffff window]
[    0.203670] pnp 00:00: Plug and Play ACPI device, IDs PNP0a08
PNP0a03 (active)
[    0.203678] pnp 00:01: [mem 0xfc000000-0xfcffffff]
[    0.203680] pnp 00:01: [mem 0xfd000000-0xfdffffff]
[    0.203681] pnp 00:01: [mem 0xfe000000-0xfebfffff]
[    0.203683] pnp 00:01: [mem 0xfed14000-0xfed19fff]
[    0.203718] system 00:01: [mem 0xfc000000-0xfcffffff] has been reser=
ved
[    0.203723] system 00:01: [mem 0xfd000000-0xfdffffff] has been reser=
ved
[    0.203727] system 00:01: [mem 0xfe000000-0xfebfffff] has been reser=
ved
[    0.203731] system 00:01: [mem 0xfed14000-0xfed19fff] has been reser=
ved
[    0.203735] system 00:01: Plug and Play ACPI device, IDs PNP0c01 (ac=
tive)
[    0.203761] pnp 00:02: [dma 4]
[    0.203762] pnp 00:02: [io  0x0000-0x000f]
[    0.203764] pnp 00:02: [io  0x0081-0x0083]
[    0.203765] pnp 00:02: [io  0x0087]
[    0.203766] pnp 00:02: [io  0x0089-0x008b]
[    0.203768] pnp 00:02: [io  0x008f]
[    0.203769] pnp 00:02: [io  0x00c0-0x00df]
[    0.203796] pnp 00:02: Plug and Play ACPI device, IDs PNP0200 (activ=
e)
[    0.203804] pnp 00:03: [io  0x0070-0x0071]
[    0.203809] pnp 00:03: [irq 8]
[    0.203836] pnp 00:03: Plug and Play ACPI device, IDs PNP0b00 (activ=
e)
[    0.203842] pnp 00:04: [io  0x0061]
[    0.203870] pnp 00:04: Plug and Play ACPI device, IDs PNP0800 (activ=
e)
[    0.203877] pnp 00:05: [io  0x00f0-0x00ff]
[    0.203881] pnp 00:05: [irq 13]
[    0.203907] pnp 00:05: Plug and Play ACPI device, IDs PNP0c04 (activ=
e)
[    0.204481] pnp 00:06: [io  0x0000-0xffffffffffffffff disabled]
[    0.204483] pnp 00:06: [io  0x0a20-0x0a3f]
[    0.204536] system 00:06: [io  0x0a20-0x0a3f] has been reserved
[    0.204541] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (ac=
tive)
[    0.204646] pnp 00:07: [io  0x0000-0xffffffffffffffff disabled]
[    0.204648] pnp 00:07: [io  0x0a00-0x0a0f]
[    0.204650] pnp 00:07: [io  0x0a10-0x0a1f]
[    0.204651] pnp 00:07: [io  0x0a20-0x0a2f]
[    0.204688] system 00:07: [io  0x0a00-0x0a0f] has been reserved
[    0.204693] system 00:07: [io  0x0a10-0x0a1f] has been reserved
[    0.204696] system 00:07: [io  0x0a20-0x0a2f] has been reserved
[    0.204700] system 00:07: Plug and Play ACPI device, IDs PNP0c02 (ac=
tive)
[    0.204783] pnp 00:08: [io  0x0010-0x001f]
[    0.204785] pnp 00:08: [io  0x0022-0x003f]
[    0.204786] pnp 00:08: [io  0x0044-0x005f]
[    0.204788] pnp 00:08: [io  0x0062-0x0063]
[    0.204789] pnp 00:08: [io  0x0065-0x006f]
[    0.204790] pnp 00:08: [io  0x0072-0x007f]
[    0.204792] pnp 00:08: [io  0x0080]
[    0.204793] pnp 00:08: [io  0x0084-0x0086]
[    0.204794] pnp 00:08: [io  0x0088]
[    0.204796] pnp 00:08: [io  0x008c-0x008e]
[    0.204797] pnp 00:08: [io  0x0090-0x009f]
[    0.204800] pnp 00:08: [io  0x00a2-0x00bf]
[    0.204801] pnp 00:08: [io  0x00e0-0x00ef]
[    0.204802] pnp 00:08: [io  0x04d0-0x04d1]
[    0.204804] pnp 00:08: [io  0x0800-0x087f]
[    0.204805] pnp 00:08: [io  0x0000-0xffffffffffffffff disabled]
[    0.204807] pnp 00:08: [io  0x0500-0x057f]
[    0.204808] pnp 00:08: [mem 0xfed1c000-0xfed1ffff]
[    0.204810] pnp 00:08: [mem 0xfed20000-0xfed3ffff]
[    0.204811] pnp 00:08: [mem 0xfed40000-0xfed8ffff]
[    0.204856] system 00:08: [io  0x04d0-0x04d1] has been reserved
[    0.204861] system 00:08: [io  0x0800-0x087f] has been reserved
[    0.204865] system 00:08: [io  0x0500-0x057f] has been reserved
[    0.204869] system 00:08: [mem 0xfed1c000-0xfed1ffff] has been reser=
ved
[    0.204873] system 00:08: [mem 0xfed20000-0xfed3ffff] has been reser=
ved
[    0.204876] system 00:08: [mem 0xfed40000-0xfed8ffff] has been reser=
ved
[    0.204881] system 00:08: Plug and Play ACPI device, IDs PNP0c02 (ac=
tive)
[    0.204921] pnp 00:09: [mem 0xfed00000-0xfed003ff]
[    0.204950] pnp 00:09: Plug and Play ACPI device, IDs PNP0103 (activ=
e)
[    0.204997] pnp 00:0a: [mem 0xffb00000-0xffbfffff]
[    0.204999] pnp 00:0a: [mem 0xfff00000-0xffffffff]
[    0.205028] pnp 00:0a: Plug and Play ACPI device, IDs INT0800 (activ=
e)
[    0.205059] pnp 00:0b: [mem 0xffc00000-0xffefffff]
[    0.205098] system 00:0b: [mem 0xffc00000-0xffefffff] has been reser=
ved
[    0.205103] system 00:0b: Plug and Play ACPI device, IDs PNP0c02 (ac=
tive)
[    0.205161] pnp 00:0c: [io  0x0060]
[    0.205162] pnp 00:0c: [io  0x0064]
[    0.205164] pnp 00:0c: [mem 0xfec00000-0xfec00fff]
[    0.205165] pnp 00:0c: [mem 0xfee00000-0xfee00fff]
[    0.205206] system 00:0c: [mem 0xfec00000-0xfec00fff] could not be r=
eserved
[    0.205211] system 00:0c: [mem 0xfee00000-0xfee00fff] has been reser=
ved
[    0.205215] system 00:0c: Plug and Play ACPI device, IDs PNP0c02 (ac=
tive)
[    0.205240] pnp 00:0d: [mem 0xe0000000-0xefffffff]
[    0.205278] system 00:0d: [mem 0xe0000000-0xefffffff] has been reser=
ved
[    0.205283] system 00:0d: Plug and Play ACPI device, IDs PNP0c02 (ac=
tive)
[    0.205415] pnp 00:0e: [mem 0x00000000-0x0009ffff]
[    0.205417] pnp 00:0e: [mem 0x000c0000-0x000cffff]
[    0.205419] pnp 00:0e: [mem 0x000e0000-0x000fffff]
[    0.205420] pnp 00:0e: [mem 0x00100000-0xbfffffff]
[    0.205422] pnp 00:0e: [mem 0xfed90000-0xffffffff]
[    0.205472] system 00:0e: [mem 0x00000000-0x0009ffff] could not be r=
eserved
[    0.205476] system 00:0e: [mem 0x000c0000-0x000cffff] has been reser=
ved
[    0.205480] system 00:0e: [mem 0x000e0000-0x000fffff] could not be r=
eserved
[    0.205484] system 00:0e: [mem 0x00100000-0xbfffffff] could not be r=
eserved
[    0.205488] system 00:0e: [mem 0xfed90000-0xffffffff] could not be r=
eserved
[    0.205493] system 00:0e: Plug and Play ACPI device, IDs PNP0c01 (ac=
tive)
[    0.205597] pnp: PnP ACPI: found 15 devices
[    0.205600] ACPI: ACPI bus type pnp unregistered
[    0.211899] pci 0000:00:1c.0: bridge window [io  0x1000-0x0fff] to
[bus 02-02] add_size 1000
[    0.211903] pci 0000:00:1c.0: bridge window [mem
0x00100000-0x000fffff 64bit pref] to [bus 02-02] add_size 200000
[    0.211905] pci 0000:00:1c.0: bridge window [mem
0x00100000-0x000fffff] to [bus 02-02] add_size 200000
[    0.211913] pci 0000:00:1c.1: bridge window [mem
0x00100000-0x000fffff] to [bus 03-03] add_size 400000
[    0.211923] pci 0000:00:1c.0: res[8]=3D[mem 0x00100000-0x000fffff]
get_res_add_size add_size 200000
[    0.211926] pci 0000:00:1c.0: res[9]=3D[mem 0x00100000-0x000fffff
64bit pref] get_res_add_size add_size 200000
[    0.211928] pci 0000:00:1c.1: res[8]=3D[mem 0x00100000-0x000fffff]
get_res_add_size add_size 400000
[    0.211930] pci 0000:00:1c.0: res[7]=3D[io  0x1000-0x0fff]
get_res_add_size add_size 1000
[    0.211934] pci 0000:00:1c.0: BAR 8: assigned [mem 0xc0000000-0xc01f=
ffff]
[    0.211939] pci 0000:00:1c.0: BAR 9: assigned [mem
0xc0200000-0xc03fffff 64bit pref]
[    0.211944] pci 0000:00:1c.1: BAR 8: assigned [mem 0xc0400000-0xc07f=
ffff]
[    0.211948] pci 0000:00:1c.0: BAR 7: assigned [io  0x1000-0x1fff]
[    0.211952] pci 0000:00:03.0: PCI bridge to [bus 01-01]
[    0.211956] pci 0000:00:03.0:   bridge window [io  0xd000-0xdfff]
[    0.211961] pci 0000:00:03.0:   bridge window [mem 0xfbf00000-0xfbff=
ffff]
[    0.211968] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
[    0.211972] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
[    0.211977] pci 0000:00:1c.0:   bridge window [mem 0xc0000000-0xc01f=
ffff]
[    0.211983] pci 0000:00:1c.0:   bridge window [mem
0xc0200000-0xc03fffff 64bit pref]
[    0.211990] pci 0000:00:1c.1: PCI bridge to [bus 03-03]
[    0.211994] pci 0000:00:1c.1:   bridge window [io  0xe000-0xefff]
[    0.211999] pci 0000:00:1c.1:   bridge window [mem 0xc0400000-0xc07f=
ffff]
[    0.212005] pci 0000:00:1c.1:   bridge window [mem
0xfaf00000-0xfaffffff 64bit pref]
[    0.212012] pci 0000:00:1e.0: PCI bridge to [bus 04-04]
[    0.212032] pci 0000:00:1c.0: enabling device (0104 -> 0107)
[    0.212045] pci 0000:00:1e.0: setting latency timer to 64
[    0.212047] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.212049] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.212051] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.212052] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000dffff]
[    0.212054] pci_bus 0000:00: resource 8 [mem 0xc0000000-0xdfffffff]
[    0.212056] pci_bus 0000:00: resource 9 [mem 0xf0000000-0xfed8ffff]
[    0.212057] pci_bus 0000:01: resource 0 [io  0xd000-0xdfff]
[    0.212059] pci_bus 0000:01: resource 1 [mem 0xfbf00000-0xfbffffff]
[    0.212061] pci_bus 0000:02: resource 0 [io  0x1000-0x1fff]
[    0.212062] pci_bus 0000:02: resource 1 [mem 0xc0000000-0xc01fffff]
[    0.212064] pci_bus 0000:02: resource 2 [mem 0xc0200000-0xc03fffff
64bit pref]
[    0.212066] pci_bus 0000:03: resource 0 [io  0xe000-0xefff]
[    0.212067] pci_bus 0000:03: resource 1 [mem 0xc0400000-0xc07fffff]
[    0.212069] pci_bus 0000:03: resource 2 [mem 0xfaf00000-0xfaffffff
64bit pref]
[    0.212071] pci_bus 0000:04: resource 4 [io  0x0000-0x0cf7]
[    0.212072] pci_bus 0000:04: resource 5 [io  0x0d00-0xffff]
[    0.212074] pci_bus 0000:04: resource 6 [mem 0x000a0000-0x000bffff]
[    0.212076] pci_bus 0000:04: resource 7 [mem 0x000d0000-0x000dffff]
[    0.212077] pci_bus 0000:04: resource 8 [mem 0xc0000000-0xdfffffff]
[    0.212079] pci_bus 0000:04: resource 9 [mem 0xf0000000-0xfed8ffff]
[    0.212110] NET: Registered protocol family 2
[    0.212155] IP route cache hash table entries: 524288 (order: 10,
4194304 bytes)
[    0.212600] TCP established hash table entries: 262144 (order: 10,
4194304 bytes)
[    0.213688] TCP bind hash table entries: 65536 (order: 8, 1048576 by=
tes)
[    0.213966] TCP: Hash tables configured (established 262144 bind 655=
36)
[    0.213969] TCP: reno registered
[    0.213973] UDP hash table entries: 8192 (order: 6, 262144 bytes)
[    0.214073] UDP-Lite hash table entries: 8192 (order: 6, 262144 byte=
s)
[    0.214208] NET: Registered protocol family 1
[    0.257405] PCI: CLS 32 bytes, default 64
[    0.257451] Unpacking initramfs...
[    0.274366] Freeing initrd memory: 1108k freed
[    0.274466] PCI-DMA: Using software bounce buffering for IO (SWIOTLB=
)
[    0.274470] Placing 64MB software IO TLB between ffff8800bb76e000 -
ffff8800bf76e000
[    0.274475] software IO TLB at phys 0xbb76e000 - 0xbf76e000
[    0.278340] msgmni has been set to 32049
[    0.278471] Block layer SCSI generic (bsg) driver version 0.4
loaded (major 253)
[    0.278476] io scheduler noop registered
[    0.278541] io scheduler cfq registered (default)
[    0.278723] intel_idle: MWAIT substates: 0x1120
[    0.278728] intel_idle: v0.4 model 0x1E
[    0.278729] intel_idle: lapic_timer_reliable_states 0x2
[    0.278803] input: Power Button as
/devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
[    0.278809] ACPI: Power Button [PWRB]
[    0.278852] input: Power Button as
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
[    0.278857] ACPI: Power Button [PWRF]
[    0.278929] ACPI: Requesting acpi_cpufreq
[    0.279349] ahci 0000:00:1f.2: version 3.0
[    0.279384] ahci 0000:00:1f.2: irq 44 for MSI/MSI-X
[    0.279410] ahci: SSS flag set, parallel bus scan disabled
[    0.290325] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 3
Gbps 0x3f impl SATA mode
[    0.290339] ahci 0000:00:1f.2: flags: 64bit ncq sntf stag pm led
clo pio slum part ems sxs apst
[    0.290352] ahci 0000:00:1f.2: setting latency timer to 64
[    0.300730] scsi0 : ahci
[    0.300792] scsi1 : ahci
[    0.300846] scsi2 : ahci
[    0.300900] scsi3 : ahci
[    0.300954] scsi4 : ahci
[    0.301007] scsi5 : ahci
[    0.301056] ata1: SATA max UDMA/133 abar m2048@0xfbef8000 port
0xfbef8100 irq 44
[    0.301061] ata2: SATA max UDMA/133 abar m2048@0xfbef8000 port
0xfbef8180 irq 44
[    0.301066] ata3: SATA max UDMA/133 abar m2048@0xfbef8000 port
0xfbef8200 irq 44
[    0.301071] ata4: SATA max UDMA/133 abar m2048@0xfbef8000 port
0xfbef8280 irq 44
[    0.301075] ata5: SATA max UDMA/133 abar m2048@0xfbef8000 port
0xfbef8300 irq 44
[    0.301080] ata6: SATA max UDMA/133 abar m2048@0xfbef8000 port
0xfbef8380 irq 44
[    0.301156] tun: Universal TUN/TAP device driver, 1.6
[    0.301159] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    0.301197] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driv=
er
[    0.301219] ehci_hcd 0000:00:1a.0: setting latency timer to 64
[    0.301221] ehci_hcd 0000:00:1a.0: EHCI Host Controller
[    0.301227] ehci_hcd 0000:00:1a.0: new USB bus registered, assigned
bus number 1
[    0.301267] ehci_hcd 0000:00:1a.0: debug port 2
[    0.305181] ehci_hcd 0000:00:1a.0: cache line size of 32 is not supp=
orted
[    0.305193] ehci_hcd 0000:00:1a.0: irq 16, io mem 0xfbefc000
[    0.310249] ehci_hcd 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[    0.310383] hub 1-0:1.0: USB hub found
[    0.310388] hub 1-0:1.0: 2 ports detected
[    0.310423] ehci_hcd 0000:00:1d.0: setting latency timer to 64
[    0.310426] ehci_hcd 0000:00:1d.0: EHCI Host Controller
[    0.310431] ehci_hcd 0000:00:1d.0: new USB bus registered, assigned
bus number 2
[    0.310452] ehci_hcd 0000:00:1d.0: debug port 2
[    0.314407] ehci_hcd 0000:00:1d.0: cache line size of 32 is not supp=
orted
[    0.314418] ehci_hcd 0000:00:1d.0: irq 23, io mem 0xfbefa000
[    0.320230] ehci_hcd 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[    0.320349] hub 2-0:1.0: USB hub found
[    0.320353] hub 2-0:1.0: 2 ports detected
[    0.320390] Initializing USB Mass Storage driver...
[    0.320418] usbcore: registered new interface driver usb-storage
[    0.320421] USB Mass Storage support registered.
[    0.320499] i8042: PNP: No PS/2 controller found. Probing ports dire=
ctly.
[    0.569660] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.569765] mousedev: PS/2 mouse device common for all mice
[    0.569807] rtc_cmos 00:03: RTC can wake from S4
[    0.569907] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
[    0.569933] rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet=
 irqs
[    0.570033] md: raid1 personality registered for level 1
[    0.570099] device-mapper: ioctl: 4.22.0-ioctl (2011-10-19)
initialised: dm-devel@redhat.com
[    0.570152] cpuidle: using governor ladder
[    0.571395] usbcore: registered new interface driver usbhid
[    0.571400] usbhid: USB HID core driver
[    0.571455] TCP: cubic registered
[    0.572176] NET: Registered protocol family 10
[    0.572512] IPv6 over IPv4 tunneling driver
[    0.573065] NET: Registered protocol family 17
[    0.573081] Bridge firewalling registered
[    0.573085] 8021q: 802.1Q VLAN Support v1.8
[    0.573818] registered taskstats version 1
[    0.574617] rtc_cmos 00:03: setting system clock to 2012-06-11
12:32:09 UTC (1339417929)
[    0.606741] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    0.611727] usb 1-1: new high-speed USB device number 2 using ehci_h=
cd
[    0.657127] ata1.00: ATA-8: OCZ-VERTEX2, 1.11, max UDMA/133
[    0.657139] ata1.00: 97696368 sectors, multi 1: LBA48 NCQ (depth 31/=
32), AA
[    0.707003] ata1.00: configured for UDMA/133
[    0.707188] scsi 0:0:0:0: Direct-Access     ATA      OCZ-VERTEX2
  1.11 PQ: 0 ANSI: 5
[    0.708238] sd 0:0:0:0: [sda] 97696368 512-byte logical blocks:
(50.0 GB/46.5 GiB)
[    0.708369] sd 0:0:0:0: [sda] Write Protect is off
[    0.708378] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    0.708401] sd 0:0:0:0: [sda] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[    0.709343]  sda: sda1 sda2
[    0.710474] sd 0:0:0:0: [sda] Attached SCSI disk
[    0.726633] hub 1-1:1.0: USB hub found
[    0.726776] hub 1-1:1.0: 6 ports detected
[    0.829131] usb 2-1: new high-speed USB device number 2 using ehci_h=
cd
[    0.944177] hub 2-1:1.0: USB hub found
[    0.944382] hub 2-1:1.0: 8 ports detected
[    1.012701] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    1.034269] ata2.00: ATA-8: WDC WD20EARX-00PASB0, 51.0AB51, max UDMA=
/133
[    1.034282] ata2.00: 3907029168 sectors, multi 0: LBA48 NCQ (depth 3=
1/32), AA
[    1.038763] ata2.00: configured for UDMA/133
[    1.038926] scsi 1:0:0:0: Direct-Access     ATA      WDC
WD20EARX-00P 51.0 PQ: 0 ANSI: 5
[    1.039570] sd 1:0:0:0: [sdb] 3907029168 512-byte logical blocks:
(2.00 TB/1.81 TiB)
[    1.039583] sd 1:0:0:0: [sdb] 4096-byte physical blocks
[    1.039640] sd 1:0:0:0: [sdb] Write Protect is off
[    1.039648] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    1.039671] sd 1:0:0:0: [sdb] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[    1.051596]  sdb: sdb1
[    1.052317] sd 1:0:0:0: [sdb] Attached SCSI disk
[    1.220344] usb 2-1.1: new high-speed USB device number 3 using ehci=
_hcd
[    1.274015] Refined TSC clocksource calibration: 2798.279 MHz.
[    1.274027] Switching to clocksource tsc
[    1.314873] usb-storage 2-1.1:1.0: Quirks match for vid 05e3 pid 072=
3: 8000
[    1.315085] scsi6 : usb-storage 2-1.1:1.0
[    1.346851] ata3: SATA link down (SStatus 0 SControl 300)
[    1.379933] usb 2-1.2: new high-speed USB device number 4 using ehci=
_hcd
[    1.460472] scsi7 : usb-storage 2-1.2:1.0
[    1.654057] ata4: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    1.672502] ata4.00: ATA-8: WDC WD20EARS-00MVWB0, 51.0AB51, max UDMA=
/133
[    1.672515] ata4.00: 3907029168 sectors, multi 0: LBA48 NCQ (depth 3=
1/32), AA
[    1.676543] ata4.00: configured for UDMA/133
[    1.676715] scsi 3:0:0:0: Direct-Access     ATA      WDC
WD20EARS-00M 51.0 PQ: 0 ANSI: 5
[    1.677562] sd 3:0:0:0: [sdc] 3907029168 512-byte logical blocks:
(2.00 TB/1.81 TiB)
[    1.677575] sd 3:0:0:0: [sdc] 4096-byte physical blocks
[    1.677634] sd 3:0:0:0: [sdc] Write Protect is off
[    1.677643] sd 3:0:0:0: [sdc] Mode Sense: 00 3a 00 00
[    1.677666] sd 3:0:0:0: [sdc] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[    1.689931]  sdc: sdc1
[    1.690856] sd 3:0:0:0: [sdc] Attached SCSI disk
[    1.982213] ata5: SATA link down (SStatus 0 SControl 300)
[    2.286423] ata6: SATA link down (SStatus 0 SControl 300)
[    2.287953] Freeing unused kernel memory: 452k freed
[    2.317015] scsi 6:0:0:0: Direct-Access     Generic  STORAGE DEVICE
  9451 PQ: 0 ANSI: 0
[    2.321661] sd 6:0:0:0: [sdd] Attached SCSI removable disk
[    2.363595] EXT4-fs (sda2): couldn't mount as ext3 due to feature
incompatibilities
[    2.369659] EXT4-fs (sda2): couldn't mount as ext2 due to feature
incompatibilities
[    2.382311] EXT4-fs (sda2): mounted filesystem with ordered data
mode. Opts: (null)
[    2.461124] scsi 7:0:0:0: Direct-Access     WD       My Passport
070A 1032 PQ: 0 ANSI: 4
[    2.462957] sd 7:0:0:0: [sde] 1952151552 512-byte logical blocks:
(999 GB/930 GiB)
[    2.464938] sd 7:0:0:0: [sde] Write Protect is off
[    2.464950] sd 7:0:0:0: [sde] Mode Sense: 23 00 10 00
[    2.466980] sd 7:0:0:0: [sde] No Caching mode page present
[    2.466991] sd 7:0:0:0: [sde] Assuming drive cache: write through
[    2.472301] sd 7:0:0:0: [sde] No Caching mode page present
[    2.472312] sd 7:0:0:0: [sde] Assuming drive cache: write through
[    2.473048]  sde: sde1
[    2.479341] sd 7:0:0:0: [sde] No Caching mode page present
[    2.479352] sd 7:0:0:0: [sde] Assuming drive cache: write through
[    2.479361] sd 7:0:0:0: [sde] Attached SCSI disk
[    2.747626] udevd[777]: starting version 171
[    2.780140] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    2.780254] r8169 0000:01:00.0: irq 45 for MSI/MSI-X
[    2.780465] r8169 0000:01:00.0: eth0: RTL8168b/8111b at
0xffffc9000002e000, 00:1f:1f:fa:64:f2, XID 18000000 IRQ 45
[    2.780471] r8169 0000:01:00.0: eth0: jumbo features [frames: 4080
bytes, tx checksumming: ko]
[    2.780484] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    2.780570] r8169 0000:03:00.0: irq 46 for MSI/MSI-X
[    2.780758] r8169 0000:03:00.0: eth1: RTL8168e/8111e at
0xffffc9000001c000, 80:ee:73:10:ad:44, XID 0c200000 IRQ 46
[    2.780764] r8169 0000:03:00.0: eth1: jumbo features [frames: 9200
bytes, tx checksumming: ko]
[    2.815193] udevd[790]: renamed network interface eth1 to rename4
[    2.819167] udevd[789]: renamed network interface eth0 to eth1
[    2.857227] mdadm: sending ioctl 1261 to a partition!
[    2.857232] mdadm: sending ioctl 1261 to a partition!
[    2.857267] mdadm: sending ioctl 1261 to a partition!
[    2.857272] mdadm: sending ioctl 1261 to a partition!
[    2.857363] mdadm: sending ioctl 1261 to a partition!
[    2.857367] mdadm: sending ioctl 1261 to a partition!
[    2.857456] mdadm: sending ioctl 1261 to a partition!
[    2.857496] mdadm: sending ioctl 1261 to a partition!
[    2.857511] mdadm: sending ioctl 1261 to a partition!
[    2.857515] mdadm: sending ioctl 1261 to a partition!
[    2.861727] md: bind<sdc1>
[    2.865236] md: bind<sdb1>
[    2.867334] bio: create slab <bio-1> at 1
[    2.867565] md/raid1:md0: active with 2 out of 2 mirrors
[    2.867589] md0: detected capacity change from 0 to 2000397713408
[    2.869239]  md0: unknown partition table
[    2.869904] udevd[790]: renamed network interface rename4 to eth0
[    3.316265] fuse init (API version 7.18)
[    3.367392] kvm: VM_EXIT_LOAD_IA32_PERF_GLOBAL_CTRL does not work
properly. Using workaround
[    4.210429] EXT4-fs (sda2): re-mounted. Opts: (null)
[    4.279285] EXT4-fs (sda1): mounted filesystem without journal. Opts=
: (null)
[    4.344171] EXT4-fs (dm-2): mounted filesystem with ordered data
mode. Opts: (null)
[    4.377312] EXT4-fs (dm-0): mounted filesystem with ordered data
mode. Opts: (null)
[    4.421482] EXT4-fs (dm-1): mounted filesystem with ordered data
mode. Opts: (null)
[    4.556520] EXT4-fs (sde1): warning: maximal mount count reached,
running e2fsck is recommended
[    4.559696] EXT4-fs (sde1): mounted filesystem with ordered data
mode. Opts: (null)
[    5.765157] r8169 0000:03:00.0: eth0: link down
[    5.765169] r8169 0000:03:00.0: eth0: link down
[    5.766271] ADDRCONF(NETDEV_UP): eth0: link is not ready
[    6.030716] r8169 0000:01:00.0: eth1: link down
[    6.033344] ADDRCONF(NETDEV_UP): eth1: link is not ready
[    8.127010] r8169 0000:03:00.0: eth0: link up
[    8.129719] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[    8.174696] r8169 0000:01:00.0: eth1: link up
[    8.177243] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   14.194472] ADDRCONF(NETDEV_UP): tap0: link is not ready
[   14.485277] device eth0 entered promiscuous mode
[   14.502568] device tap0 entered promiscuous mode
[   14.513622] br0: port 1(eth0) entered forwarding state
[   14.513633] br0: port 1(eth0) entered forwarding state
[   17.625089] ADDRCONF(NETDEV_CHANGE): tap0: link becomes ready
[   17.625133] br0: port 2(tap0) entered forwarding state
[   17.625141] br0: port 2(tap0) entered forwarding state
[   18.395970] eth0: no IPv6 routers present
[   18.661279] eth1: no IPv6 routers present
[   20.350121] ip_tables: (C) 2000-2006 Netfilter Core Team
[   20.356135] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   20.362457] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   20.563254] u32 classifier
[   20.563258]     Performance counters on
[   21.908018] device vnet0 entered promiscuous mode
[   21.912578] br0: port 3(vnet0) entered forwarding state
[   21.912587] br0: port 3(vnet0) entered forwarding state
[   24.636767] br0: no IPv6 routers present
[   27.677915] tap0: no IPv6 routers present
[   29.477290] br0: port 1(eth0) entered forwarding state
[   32.605341] br0: port 2(tap0) entered forwarding state
[   32.631239] vnet0: no IPv6 routers present
[   36.882399] br0: port 3(vnet0) entered forwarding state
[ 2839.337498] ------------[ cut here ]------------
[ 2839.337509] WARNING: at net/sched/sch_generic.c:256
dev_watchdog+0x16b/0x20f()
[ 2839.337513] Hardware name: SH55J
[ 2839.337516] NETDEV WATCHDOG: eth1 (r8169): transmit queue 0 timed ou=
t
[ 2839.337519] Modules linked in: vhost_net cls_route cls_u32 cls_fw
sch_sfq sch_htb ipt_REDIRECT ipt_MASQUERADE xt_limit xt_tcpudp
nf_conntrack_ipv6 nf_defrag_ipv6 xt_state iptable_nat nf_nat
nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip6table_filter
ip6_tables iptable_filter ip_tables x_tables kvm_intel kvm fuse r8169
[ 2839.337554] Pid: 0, comm: swapper/3 Not tainted 3.4.2 #1
[ 2839.337556] Call Trace:
[ 2839.337559]  <IRQ>  [<ffffffff81026881>] ? warn_slowpath_common+0x78=
/0x8c
[ 2839.337571]  [<ffffffff81026936>] ? warn_slowpath_fmt+0x45/0x4a
[ 2839.337576]  [<ffffffff81042fc2>] ? scheduler_tick+0xaf/0xc3
[ 2839.337582]  [<ffffffff812535a0>] ? dev_watchdog+0x16b/0x20f
[ 2839.337588]  [<ffffffff8102f3ae>] ? run_timer_softirq+0x177/0x209
[ 2839.337594]  [<ffffffff8103e7b3>] ? hrtimer_interrupt+0x100/0x19b
[ 2839.337599]  [<ffffffff81253435>] ? qdisc_reset+0x35/0x35
[ 2839.337605]  [<ffffffff8102b256>] ? __do_softirq+0x7f/0x106
[ 2839.337611]  [<ffffffff812e298c>] ? call_softirq+0x1c/0x30
[ 2839.337616]  [<ffffffff81003376>] ? do_softirq+0x31/0x67
[ 2839.337621]  [<ffffffff8102b503>] ? irq_exit+0x44/0x75
[ 2839.337625]  [<ffffffff810032b5>] ? do_IRQ+0x94/0xad
[ 2839.337631]  [<ffffffff812e10a7>] ? common_interrupt+0x67/0x67
[ 2839.337634]  <EOI>  [<ffffffff81163f07>] ? intel_idle+0xde/0x103
[ 2839.337645]  [<ffffffff81163ee3>] ? intel_idle+0xba/0x103
[ 2839.337652]  [<ffffffff81220bfa>] ? cpuidle_idle_call+0x7e/0xc4
[ 2839.337659]  [<ffffffff81008e92>] ? cpu_idle+0x53/0x7c
[ 2839.337663] ---[ end trace 04a2b9c09e9d7860 ]---
[ 2839.341697] r8169 0000:01:00.0: eth1: link up

Regards
Tomas

On Mon, Jun 11, 2012 at 11:52 PM, Francois Romieu <romieu@fr.zoreil.com=
> wrote:
> Tomas Papan <tomas.papan@gmail.com> :
> [...]
>> If you need something else just tell me.
>
> The XID line should look something like :
>
> [ =C2=A0 =C2=A08.925786] r8169 0000:03:00.0: eth0: RTL8168evl/8111evl=
 at 0xffffc900050ec000, 00:e0:4c:68:00:1f, XID 0c900800 IRQ 51
>
> (whence the 'XID' thing)
>
> Please send a _complete_ dmesg. I won't bet it will solve anything bu=
t
> it can't be more useless than the generic watchdog message.
>
> Thanks.
>
> --
> Ueimor
