From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mmotm-2009-12-08-17-45 resume slowly
Date: Thu, 10 Dec 2009 18:52:51 +0900 (JST)
Message-ID: <20091210184931.257A.A69D9226@jp.fujitsu.com>
References: <a8e1da0912100127k4dcddd65gfe5ff0b1330fe63b@mail.gmail.com> <a8e1da0912100130i2e654796mf899dd27df869673@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kosaki.motohiro@jp.fujitsu.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759498AbZLJJxH@vger.kernel.org>
In-Reply-To: <a8e1da0912100130i2e654796mf899dd27df869673@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(cc to netdev)

Hi net-folks

> > [ =C2=A0561.323866] mtrr: type mismatch for e0000000,10000000 old:
> > write-back new: write-combining
> > [ 2688.500033] No probe response from AP 00:02:2d:08:51:2b after
> > 500ms, disconnecting.
> > [ 2689.580376] wlan0: direct probe to AP 00:02:2d:08:51:2b (try 1)

What's mean "No probe response"? Why its point waste 2000sec?



(intentional full quote)

> Sorry forgot cc list
>=20
>=20
> On Thu, Dec 10, 2009 at 5:27 PM, Dave Young <hidave.darkstar@gmail.co=
m> wrote:
> > Hi,
> >
> > With rencent mm patch sets (since 2.6.32), the resume is too slow w=
ith
> > screen being black over 5 minutes
> >
> > (Dell e5400 with intel graphic card)
> >
> > Here is the full dmesg:
> >
> > [ =C2=A0 =C2=A00.000000] Initializing cgroup subsys cpuset
> > [ =C2=A0 =C2=A00.000000] Initializing cgroup subsys cpu
> > [ =C2=A0 =C2=A00.000000] Linux version 2.6.32-mm1 (dave@darkstar) (=
gcc version
> > 4.2.4) #5 SMP Thu Dec 10 15:23:34 CST 2009
> > [ =C2=A0 =C2=A00.000000] BIOS-provided physical RAM map:
> > [ =C2=A0 =C2=A00.000000] =C2=A0BIOS-e820: 0000000000000000 - 000000=
000009f000 (usable)
> > [ =C2=A0 =C2=A00.000000] =C2=A0BIOS-e820: 000000000009f000 - 000000=
00000a0000 (reserved)
> > [ =C2=A0 =C2=A00.000000] =C2=A0BIOS-e820: 0000000000100000 - 000000=
003d38d400 (usable)
> > [ =C2=A0 =C2=A00.000000] =C2=A0BIOS-e820: 000000003d38d400 - 000000=
003d38f400 (ACPI NVS)
> > [ =C2=A0 =C2=A00.000000] =C2=A0BIOS-e820: 000000003d38f400 - 000000=
0040000000 (reserved)
> > [ =C2=A0 =C2=A00.000000] =C2=A0BIOS-e820: 00000000f8000000 - 000000=
00fc000000 (reserved)
> > [ =C2=A0 =C2=A00.000000] =C2=A0BIOS-e820: 00000000fec00000 - 000000=
00fec10000 (reserved)
> > [ =C2=A0 =C2=A00.000000] =C2=A0BIOS-e820: 00000000fed18000 - 000000=
00fed1c000 (reserved)
> > [ =C2=A0 =C2=A00.000000] =C2=A0BIOS-e820: 00000000fed20000 - 000000=
00fed90000 (reserved)
> > [ =C2=A0 =C2=A00.000000] =C2=A0BIOS-e820: 00000000feda0000 - 000000=
00feda6000 (reserved)
> > [ =C2=A0 =C2=A00.000000] =C2=A0BIOS-e820: 00000000fee00000 - 000000=
00fee10000 (reserved)
> > [ =C2=A0 =C2=A00.000000] =C2=A0BIOS-e820: 00000000ffe80000 - 000000=
0100000000 (reserved)
> > [ =C2=A0 =C2=A00.000000] Notice: NX (Execute Disable) protection mi=
ssing in CPU
> > or disabled in BIOS!
> > [ =C2=A0 =C2=A00.000000] DMI 2.4 present.
> > [ =C2=A0 =C2=A00.000000] last_pfn =3D 0x3d38d max_arch_pfn =3D 0x10=
0000
> > [ =C2=A0 =C2=A00.000000] MTRR default type: uncachable
> > [ =C2=A0 =C2=A00.000000] MTRR fixed ranges enabled:
> > [ =C2=A0 =C2=A00.000000] =C2=A0 00000-9FFFF write-back
> > [ =C2=A0 =C2=A00.000000] =C2=A0 A0000-BFFFF uncachable
> > [ =C2=A0 =C2=A00.000000] =C2=A0 C0000-CFFFF write-protect
> > [ =C2=A0 =C2=A00.000000] =C2=A0 D0000-EFFFF uncachable
> > [ =C2=A0 =C2=A00.000000] =C2=A0 F0000-FFFFF write-protect
> > [ =C2=A0 =C2=A00.000000] MTRR variable ranges enabled:
> > [ =C2=A0 =C2=A00.000000] =C2=A0 0 base 000000000 mask C00000000 wri=
te-back
> > [ =C2=A0 =C2=A00.000000] =C2=A0 1 base 0E0000000 mask FE0000000 unc=
achable
> > [ =C2=A0 =C2=A00.000000] =C2=A0 2 base 03DC00000 mask FFFC00000 unc=
achable
> > [ =C2=A0 =C2=A00.000000] =C2=A0 3 base 03E000000 mask FFE000000 unc=
achable
> > [ =C2=A0 =C2=A00.000000] =C2=A0 4 base 03DB00000 mask FFFF00000 unc=
achable
> > [ =C2=A0 =C2=A00.000000] =C2=A0 5 disabled
> > [ =C2=A0 =C2=A00.000000] =C2=A0 6 disabled
> > [ =C2=A0 =C2=A00.000000] =C2=A0 7 disabled
> > [ =C2=A0 =C2=A00.000000] x86 PAT enabled: cpu 0, old 0x704060007040=
6, new 0x7010600070106
> > [ =C2=A0 =C2=A00.000000] e820 update range: 000000003db00000 - 0000=
000040000000
> > (usable) =3D=3D> (reserved)
> > [ =C2=A0 =C2=A00.000000] e820 update range: 00000000e0000000 - 0000=
000100000000
> > (usable) =3D=3D> (reserved)
> > [ =C2=A0 =C2=A00.000000] initial memory mapped : 0 - 02000000
> > [ =C2=A0 =C2=A00.000000] init_memory_mapping: 0000000000000000-0000=
0000377fe000
> > [ =C2=A0 =C2=A00.000000] =C2=A00000000000 - 0000400000 page 4k
> > [ =C2=A0 =C2=A00.000000] =C2=A00000400000 - 0037400000 page 2M
> > [ =C2=A0 =C2=A00.000000] =C2=A00037400000 - 00377fe000 page 4k
> > [ =C2=A0 =C2=A00.000000] kernel direct mapping tables up to 377fe00=
0 @ 7000-c000
> > [ =C2=A0 =C2=A00.000000] ACPI: RSDP 000fbce0 00024 (v02 DELL =C2=A0=
)
> > [ =C2=A0 =C2=A00.000000] ACPI: XSDT 3d391e00 00064 (v01 DELL =C2=A0=
 =C2=A0M09 =C2=A0 =C2=A0 27D9041D
> > ASL =C2=A000000061)
> > [ =C2=A0 =C2=A00.000000] ACPI: FACP 3d391c9c 000F4 (v04 DELL =C2=A0=
 =C2=A0M09 =C2=A0 =C2=A0 27D9041D
> > ASL =C2=A000000061)
> > [ =C2=A0 =C2=A00.000000] ACPI: DSDT 3d392400 06857 (v02 INT430 SYSF=
exxx 00001001
> > INTL 20050624)
> > [ =C2=A0 =C2=A00.000000] ACPI: FACS 3d3a0c00 00040
> > [ =C2=A0 =C2=A00.000000] ACPI: HPET 3d391f00 00038 (v01 DELL =C2=A0=
 =C2=A0M09 =C2=A0 =C2=A0 00000001
> > ASL =C2=A000000061)
> > [ =C2=A0 =C2=A00.000000] ACPI: DMAR 3d3a0400 000F8 (v01 DELL =C2=A0=
 =C2=A0M09 =C2=A0 =C2=A0 27D9041D
> > ASL =C2=A000000061)
> > [ =C2=A0 =C2=A00.000000] ACPI: APIC 3d392000 00068 (v01 DELL =C2=A0=
 =C2=A0M09 =C2=A0 =C2=A0 27D9041D
> > ASL =C2=A000000047)
> > [ =C2=A0 =C2=A00.000000] ACPI: ASF! 3d391c00 00076 (v32 DELL =C2=A0=
 =C2=A0M09 =C2=A0 =C2=A0 27D9041D
> > ASL =C2=A000000061)
> > [ =C2=A0 =C2=A00.000000] ACPI: MCFG 3d391fc0 0003E (v16 DELL =C2=A0=
 =C2=A0M09 =C2=A0 =C2=A0 27D9041D
> > ASL =C2=A000000061)
> > [ =C2=A0 =C2=A00.000000] ACPI: TCPA 3d392300 00032 (v01 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 00000000
> > ASL =C2=A000000000)
> > [ =C2=A0 =C2=A00.000000] ACPI: SSDT 3d3902e7 0066C (v01 =C2=A0PmRef=
 =C2=A0 =C2=A0CpuPm 00003000
> > INTL 20050624)
> > [ =C2=A0 =C2=A00.000000] ACPI: Local APIC address 0xfee00000
> > [ =C2=A0 =C2=A00.000000] 91MB HIGHMEM available.
> > [ =C2=A0 =C2=A00.000000] 887MB LOWMEM available.
> > [ =C2=A0 =C2=A00.000000] =C2=A0 mapped low ram: 0 - 377fe000
> > [ =C2=A0 =C2=A00.000000] =C2=A0 low ram: 0 - 377fe000
> > [ =C2=A0 =C2=A00.000000] =C2=A0 node 0 low ram: 00000000 - 377fe000
> > [ =C2=A0 =C2=A00.000000] =C2=A0 node 0 bootmap 00008000 - 0000ef00
> > [ =C2=A0 =C2=A00.000000] (9 early reservations) =3D=3D> bootmem [00=
00000000 - 00377fe000]
> > [ =C2=A0 =C2=A00.000000] =C2=A0 #0 [0000000000 - 0000001000] =C2=A0=
 BIOS data page =3D=3D>
> > [0000000000 - 0000001000]
> > [ =C2=A0 =C2=A00.000000] =C2=A0 #1 [0000001000 - 0000002000] =C2=A0=
 =C2=A0EX TRAMPOLINE =3D=3D>
> > [0000001000 - 0000002000]
> > [ =C2=A0 =C2=A00.000000] =C2=A0 #2 [0000006000 - 0000007000] =C2=A0=
 =C2=A0 =C2=A0 TRAMPOLINE =3D=3D>
> > [0000006000 - 0000007000]
> > [ =C2=A0 =C2=A00.000000] =C2=A0 #3 [0001000000 - 0001c1ed78] =C2=A0=
 =C2=A0TEXT DATA BSS =3D=3D>
> > [0001000000 - 0001c1ed78]
> > [ =C2=A0 =C2=A00.000000] =C2=A0 #4 [000009f000 - 0000100000] =C2=A0=
 =C2=A0BIOS reserved =3D=3D>
> > [000009f000 - 0000100000]
> > [ =C2=A0 =C2=A00.000000] =C2=A0 #5 [0001c1f000 - 0001c27184] =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0BRK =3D=3D>
> > [0001c1f000 - 0001c27184]
> > [ =C2=A0 =C2=A00.000000] =C2=A0 #6 [0000002000 - 0000006000] =C2=A0=
 =C2=A0 =C2=A0ACPI WAKEUP =3D=3D>
> > [0000002000 - 0000006000]
> > [ =C2=A0 =C2=A00.000000] =C2=A0 #7 [0000007000 - 0000008000] =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0PGTABLE =3D=3D>
> > [0000007000 - 0000008000]
> > [ =C2=A0 =C2=A00.000000] =C2=A0 #8 [0000008000 - 000000f000] =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0BOOTMAP =3D=3D>
> > [0000008000 - 000000f000]
> > [ =C2=A0 =C2=A00.000000] sizeof(struct page) =3D 32
> > [ =C2=A0 =C2=A00.000000] Zone PFN ranges:
> > [ =C2=A0 =C2=A00.000000] =C2=A0 DMA =C2=A0 =C2=A0 =C2=A00x00000000 =
-> 0x00001000
> > [ =C2=A0 =C2=A00.000000] =C2=A0 Normal =C2=A0 0x00001000 -> 0x00037=
7fe
> > [ =C2=A0 =C2=A00.000000] =C2=A0 HighMem =C2=A00x000377fe -> 0x0003d=
38d
> > [ =C2=A0 =C2=A00.000000] Movable zone start PFN for each node
> > [ =C2=A0 =C2=A00.000000] early_node_map[2] active PFN ranges
> > [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 0: 0x00000000 -> 0x0000009f
> > [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 0: 0x00000100 -> 0x0003d38d
> > [ =C2=A0 =C2=A00.000000] On node 0 totalpages: 250668
> > [ =C2=A0 =C2=A00.000000] Node 0 memmap at 0xc1c29000 size 8028160 f=
irst pfn 0xc1c29000
> > [ =C2=A0 =C2=A00.000000] free_area_init_node: node 0, pgdat c162db4=
0,
> > node_mem_map c1c29000
> > [ =C2=A0 =C2=A00.000000] =C2=A0 DMA zone: 32 pages used for memmap
> > [ =C2=A0 =C2=A00.000000] =C2=A0 DMA zone: 0 pages reserved
> > [ =C2=A0 =C2=A00.000000] =C2=A0 DMA zone: 3967 pages, LIFO batch:0
> > [ =C2=A0 =C2=A00.000000] =C2=A0 Normal zone: 1744 pages used for me=
mmap
> > [ =C2=A0 =C2=A00.000000] =C2=A0 Normal zone: 221486 pages, LIFO bat=
ch:31
> > [ =C2=A0 =C2=A00.000000] =C2=A0 HighMem zone: 184 pages used for me=
mmap
> > [ =C2=A0 =C2=A00.000000] =C2=A0 HighMem zone: 23255 pages, LIFO bat=
ch:3
> > [ =C2=A0 =C2=A00.000000] Using APIC driver default
> > [ =C2=A0 =C2=A00.000000] ACPI: PM-Timer IO Port: 0x1008
> > [ =C2=A0 =C2=A00.000000] ACPI: Local APIC address 0xfee00000
> > [ =C2=A0 =C2=A00.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] =
enabled)
> > [ =C2=A0 =C2=A00.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] =
enabled)
> > [ =C2=A0 =C2=A00.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge l=
int[0x1])
> > [ =C2=A0 =C2=A00.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge l=
int[0x1])
> > [ =C2=A0 =C2=A00.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000]=
 gsi_base[0])
> > [ =C2=A0 =C2=A00.000000] IOAPIC[0]: apic_id 2, version 32, address =
0xfec00000, GSI 0-23
> > [ =C2=A0 =C2=A00.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_=
irq 2 dfl dfl)
> > [ =C2=A0 =C2=A00.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_=
irq 9 high level)
> > [ =C2=A0 =C2=A00.000000] ACPI: IRQ0 used by override.
> > [ =C2=A0 =C2=A00.000000] ACPI: IRQ2 used by override.
> > [ =C2=A0 =C2=A00.000000] ACPI: IRQ9 used by override.
> > [ =C2=A0 =C2=A00.000000] Enabling APIC mode: =C2=A0Flat. =C2=A0Usin=
g 1 I/O APICs
> > [ =C2=A0 =C2=A00.000000] Using ACPI (MADT) for SMP configuration in=
formation
> > [ =C2=A0 =C2=A00.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
> > [ =C2=A0 =C2=A00.000000] SMP: Allowing 2 CPUs, 0 hotplug CPUs
> > [ =C2=A0 =C2=A00.000000] nr_irqs_gsi: 24
> > [ =C2=A0 =C2=A00.000000] PM: Registered nosave memory: 000000000009=
f000 - 00000000000a0000
> > [ =C2=A0 =C2=A00.000000] PM: Registered nosave memory: 00000000000a=
0000 - 0000000000100000
> > [ =C2=A0 =C2=A00.000000] Allocating PCI resources starting at 40000=
000 (gap:
> > 40000000:b8000000)
> > [ =C2=A0 =C2=A00.000000] Booting paravirtualized kernel on bare har=
dware
> > [ =C2=A0 =C2=A00.000000] NR_CPUS:2 nr_cpumask_bits:2 nr_cpu_ids:2 n=
r_node_ids:1
> > [ =C2=A0 =C2=A00.000000] PERCPU: Embedded 14 pages/cpu @c2400000 s3=
3048 r0 d24296 u2097152
> > [ =C2=A0 =C2=A00.000000] pcpu-alloc: s33048 r0 d24296 u2097152 allo=
c=3D1*4194304
> > [ =C2=A0 =C2=A00.000000] pcpu-alloc: [0] 0 1
> > [ =C2=A0 =C2=A00.000000] Built 1 zonelists in Zone order, mobility =
grouping on.
> > Total pages: 248708
> > [ =C2=A0 =C2=A00.000000] Kernel command line: BOOT_IMAGE=3Dmm ro ro=
ot=3D802
> > vt.default_utf8=3D0 resume=3D/dev/sda8
> > [ =C2=A0 =C2=A00.000000] PID hash table entries: 4096 (order: 2, 16=
384 bytes)
> > [ =C2=A0 =C2=A00.000000] Dentry cache hash table entries: 131072 (o=
rder: 7, 524288 bytes)
> > [ =C2=A0 =C2=A00.000000] Inode-cache hash table entries: 65536 (ord=
er: 6, 262144 bytes)
> > [ =C2=A0 =C2=A00.000000] Enabling fast FPU save and restore... done=
=2E
> > [ =C2=A0 =C2=A00.000000] Enabling unmasked SIMD FPU exception suppo=
rt... done.
> > [ =C2=A0 =C2=A00.000000] Initializing CPU#0
> > [ =C2=A0 =C2=A00.000000] Initializing HighMem for node 0 (000377fe:=
0003d38d)
> > [ =C2=A0 =C2=A00.000000] Memory: 980956k/1003060k available (3904k =
kernel code,
> > 21272k reserved, 2488k data, 408k init, 93756k highmem)
> > [ =C2=A0 =C2=A00.000000] virtual kernel memory layout:
> > [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 fixmap =C2=A0: 0xfff90000 - =
0xfffff000 =C2=A0 ( 444 kB)
> > [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 pkmap =C2=A0 : 0xff800000 - =
0xffc00000 =C2=A0 (4096 kB)
> > [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 vmalloc : 0xf7ffe000 - 0xff7=
fe000 =C2=A0 ( 120 MB)
> > [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 lowmem =C2=A0: 0xc0000000 - =
0xf77fe000 =C2=A0 ( 887 MB)
> > [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 =C2=A0 .init : 0xc163f000 - =
0xc16a5000 =C2=A0 ( 408 kB)
> > [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 =C2=A0 .data : 0xc13d0244 - =
0xc163e5a0 =C2=A0 (2488 kB)
> > [ =C2=A0 =C2=A00.000000] =C2=A0 =C2=A0 =C2=A0 .text : 0xc1000000 - =
0xc13d0244 =C2=A0 (3904 kB)
> > [ =C2=A0 =C2=A00.000000] Checking if this processor honours the WP =
bit even in
> > supervisor mode...Ok.
> > [ =C2=A0 =C2=A00.000000] Hierarchical RCU implementation.
> > [ =C2=A0 =C2=A00.000000] NR_IRQS:320
> > [ =C2=A0 =C2=A00.000000] Extended CMOS year: 2000
> > [ =C2=A0 =C2=A00.000000] Console: colour dummy device 80x25
> > [ =C2=A0 =C2=A00.000000] console [tty0] enabled
> > [ =C2=A0 =C2=A00.000000] Lock dependency validator: Copyright (c) 2=
006 Red Hat,
> > Inc., Ingo Molnar
> > [ =C2=A0 =C2=A00.000000] ... MAX_LOCKDEP_SUBCLASSES: =C2=A08
> > [ =C2=A0 =C2=A00.000000] ... MAX_LOCK_DEPTH: =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A048
> > [ =C2=A0 =C2=A00.000000] ... MAX_LOCKDEP_KEYS: =C2=A0 =C2=A0 =C2=A0=
 =C2=A08191
> > [ =C2=A0 =C2=A00.000000] ... CLASSHASH_SIZE: =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A04096
> > [ =C2=A0 =C2=A00.000000] ... MAX_LOCKDEP_ENTRIES: =C2=A0 =C2=A0 163=
84
> > [ =C2=A0 =C2=A00.000000] ... MAX_LOCKDEP_CHAINS: =C2=A0 =C2=A0 =C2=A0=
32768
> > [ =C2=A0 =C2=A00.000000] ... CHAINHASH_SIZE: =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A016384
> > [ =C2=A0 =C2=A00.000000] =C2=A0memory used by lock dependency info:=
 3567 kB
> > [ =C2=A0 =C2=A00.000000] =C2=A0per task-struct memory footprint: 11=
52 bytes
> > [ =C2=A0 =C2=A00.000000] hpet clockevent registered
> > [ =C2=A0 =C2=A00.000000] Fast TSC calibration using PIT
> > [ =C2=A0 =C2=A00.000000] Detected 1995.100 MHz processor.
> > [ =C2=A0 =C2=A00.003349] Calibrating delay loop (skipped), value ca=
lculated
> > using timer frequency.. 3991.45 BogoMIPS (lpj=3D6650333)
> > [ =C2=A0 =C2=A00.003611] Security Framework initialized
> > [ =C2=A0 =C2=A00.003717] Mount-cache hash table entries: 512
> > [ =C2=A0 =C2=A00.006964] Initializing cgroup subsys ns
> > [ =C2=A0 =C2=A00.006972] Initializing cgroup subsys cpuacct
> > [ =C2=A0 =C2=A00.007103] CPU: Physical Processor ID: 0
> > [ =C2=A0 =C2=A00.007108] CPU: Processor Core ID: 0
> > [ =C2=A0 =C2=A00.007114] using mwait in idle threads.
> > [ =C2=A0 =C2=A00.007122] Performance Events: Core2 events, Intel PM=
U driver.
> > [ =C2=A0 =C2=A00.007153] ... version: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A02
> > [ =C2=A0 =C2=A00.007158] ... bit width: =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A040
> > [ =C2=A0 =C2=A00.007163] ... generic registers: =C2=A0 =C2=A0 =C2=A0=
2
> > [ =C2=A0 =C2=A00.007168] ... value mask: =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 000000ffffffffff
> > [ =C2=A0 =C2=A00.007173] ... max period: =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 000000007fffffff
> > [ =C2=A0 =C2=A00.007179] ... fixed-purpose events: =C2=A0 3
> > [ =C2=A0 =C2=A00.007184] ... event mask: =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 0000000700000003
> > [ =C2=A0 =C2=A00.007199] Checking 'hlt' instruction... OK.
> > [ =C2=A0 =C2=A00.021587] ACPI: Core revision 20091112
> > [ =C2=A0 =C2=A00.043974] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 =
apic2=3D-1 pin2=3D-1
> > [ =C2=A0 =C2=A00.079689] CPU0: Intel(R) Core(TM)2 Duo CPU =C2=A0 =C2=
=A0 T7250 =C2=A0@ 2.00GHz stepping 0d
> > [ =C2=A0 =C2=A00.079999] lockdep: fixing up alternatives.
> > [ =C2=A0 =C2=A00.079999] Booting processor 1 APIC 0x1 ip 0x6000
> > [ =C2=A0 =C2=A00.079999] Initializing CPU#1
> > [ =C2=A0 =C2=A00.079999] CPU: Physical Processor ID: 0
> > [ =C2=A0 =C2=A00.079999] CPU: Processor Core ID: 1
> > [ =C2=A0 =C2=A00.170015] CPU1: Intel(R) Core(TM)2 Duo CPU =C2=A0 =C2=
=A0 T7250 =C2=A0@ 2.00GHz stepping 0d
> > [ =C2=A0 =C2=A00.173386] Brought up 2 CPUs
> > [ =C2=A0 =C2=A00.173393] Total of 2 processors activated (7983.61 B=
ogoMIPS).
> > [ =C2=A0 =C2=A00.175046] khelper used greatest stack depth: 6928 by=
tes left
> > [ =C2=A0 =C2=A00.175046] regulator: core version 0.5
> > [ =C2=A0 =C2=A00.176722] Time: 15:30:08 =C2=A0Date: 12/10/09
> > [ =C2=A0 =C2=A00.176823] khelper used greatest stack depth: 6728 by=
tes left
> > [ =C2=A0 =C2=A00.176984] NET: Registered protocol family 16
> > [ =C2=A0 =C2=A00.180083] ACPI: bus type pci registered
> > [ =C2=A0 =C2=A00.180201] PCI: MMCONFIG for domain 0000 [bus 00-3f] =
at [mem
> > 0xf8000000-0xfbffffff] (base 0xf8000000)
> > [ =C2=A0 =C2=A00.180201] PCI: MMCONFIG at [mem 0xf8000000-0xfbfffff=
f] reserved in E820
> > [ =C2=A0 =C2=A00.180201] PCI: Using MMCONFIG for extended config sp=
ace
> > [ =C2=A0 =C2=A00.180201] PCI: Using configuration type 1 for base a=
ccess
> > [ =C2=A0 =C2=A00.203625] bio: create slab <bio-0> at 0
> > [ =C2=A0 =C2=A00.213198] ACPI: EC: Look up EC in DSDT
> > [ =C2=A0 =C2=A00.213825] ACPI: BIOS _OSI(Linux) query ignored
> > [ =C2=A0 =C2=A00.276349] ACPI: SSDT 3d3a0c80 00043 (v01 =C2=A0LMPWR=
 =C2=A0DELLLOM 00001001
> > INTL 20050624)
> > [ =C2=A0 =C2=A00.323792] ACPI: Interpreter enabled
> > [ =C2=A0 =C2=A00.323804] ACPI: (supports S0 S3 S4 S5)
> > [ =C2=A0 =C2=A00.323895] ACPI: Using IOAPIC for interrupt routing
> > [ =C2=A0 =C2=A00.490535] ACPI: EC: GPE =3D 0x11, I/O: command/statu=
s =3D 0x934, data =3D 0x930
> > [ =C2=A0 =C2=A00.493757] ACPI: No dock devices found.
> > [ =C2=A0 =C2=A00.529913] ACPI: PCI Root Bridge [PCI0] (0000:00)
> > [ =C2=A0 =C2=A00.530130] pci_root PNP0A03:00: ignoring host bridge =
windows from
> > ACPI; boot with "pci=3Duse_crs" to use them
> > [ =C2=A0 =C2=A00.600625] pci_root PNP0A03:00: host bridge window [i=
o
> > 0x0000-0x0cf7] (ignored)
> > [ =C2=A0 =C2=A00.600630] pci_root PNP0A03:00: host bridge window [i=
o
> > 0x0d00-0xffff] (ignored)
> > [ =C2=A0 =C2=A00.600634] pci_root PNP0A03:00: host bridge window [m=
em
> > 0x000a0000-0x000bffff] (ignored)
> > [ =C2=A0 =C2=A00.600637] pci_root PNP0A03:00: host bridge window [m=
em
> > 0x000d0000-0x000dffff] (ignored)
> > [ =C2=A0 =C2=A00.600641] pci_root PNP0A03:00: host bridge window [m=
em
> > 0x40000000-0xf7ffffff] (ignored)
> > [ =C2=A0 =C2=A00.600645] pci_root PNP0A03:00: host bridge window [m=
em
> > 0xfc000000-0xfebfffff] (ignored)
> > [ =C2=A0 =C2=A00.600648] pci_root PNP0A03:00: host bridge window [m=
em
> > 0xfec10000-0xfecfffff] (ignored)
> > [ =C2=A0 =C2=A00.600652] pci_root PNP0A03:00: host bridge window [m=
em
> > 0xfed1c000-0xfed1ffff] (ignored)
> > [ =C2=A0 =C2=A00.600656] pci_root PNP0A03:00: host bridge window [m=
em
> > 0xfed90000-0xfed9ffff] (ignored)
> > [ =C2=A0 =C2=A00.600659] pci_root PNP0A03:00: host bridge window [m=
em
> > 0xfed40000-0xfed44fff] (ignored)
> > [ =C2=A0 =C2=A00.600663] pci_root PNP0A03:00: host bridge window [m=
em
> > 0xfeda7000-0xfedfffff] (ignored)
> > [ =C2=A0 =C2=A00.600667] pci_root PNP0A03:00: host bridge window [m=
em
> > 0xfee10000-0xff9fffff] (ignored)
> > [ =C2=A0 =C2=A00.600670] pci_root PNP0A03:00: host bridge window [m=
em
> > 0xffb80000-0xffe7ffff] (ignored)
> > [ =C2=A0 =C2=A00.600882] pci 0000:00:02.0: reg 10: [mem 0xf6c00000-=
0xf6ffffff 64bit]
> > [ =C2=A0 =C2=A00.600897] pci 0000:00:02.0: reg 18: [mem 0xe0000000-=
0xefffffff 64bit pref]
> > [ =C2=A0 =C2=A00.600906] pci 0000:00:02.0: reg 20: [io =C2=A00xefe8=
-0xefef]
> > [ =C2=A0 =C2=A00.600999] pci 0000:00:02.1: reg 10: [mem 0xf6b00000-=
0xf6bfffff 64bit]
> > [ =C2=A0 =C2=A00.601223] pci 0000:00:1a.0: reg 20: [io =C2=A00x6f60=
-0x6f7f]
> > [ =C2=A0 =C2=A00.601374] pci 0000:00:1a.1: reg 20: [io =C2=A00x6f80=
-0x6f9f]
> > [ =C2=A0 =C2=A00.601525] pci 0000:00:1a.2: reg 20: [io =C2=A00x6fa0=
-0x6fbf]
> > [ =C2=A0 =C2=A00.601673] pci 0000:00:1a.7: reg 10: [mem 0xfed1c400-=
0xfed1c7ff]
> > [ =C2=A0 =C2=A00.601783] pci 0000:00:1a.7: PME# supported from D0 D=
3hot D3cold
> > [ =C2=A0 =C2=A00.601791] pci 0000:00:1a.7: PME# disabled
> > [ =C2=A0 =C2=A00.601875] pci 0000:00:1b.0: reg 10: [mem 0xf6afc000-=
0xf6afffff 64bit]
> > [ =C2=A0 =C2=A00.601974] pci 0000:00:1b.0: PME# supported from D0 D=
3hot D3cold
> > [ =C2=A0 =C2=A00.601981] pci 0000:00:1b.0: PME# disabled
> > [ =C2=A0 =C2=A00.602144] pci 0000:00:1c.0: PME# supported from D0 D=
3hot D3cold
> > [ =C2=A0 =C2=A00.602151] pci 0000:00:1c.0: PME# disabled
> > [ =C2=A0 =C2=A00.602322] pci 0000:00:1c.1: PME# supported from D0 D=
3hot D3cold
> > [ =C2=A0 =C2=A00.602329] pci 0000:00:1c.1: PME# disabled
> > [ =C2=A0 =C2=A00.602501] pci 0000:00:1c.4: PME# supported from D0 D=
3hot D3cold
> > [ =C2=A0 =C2=A00.602509] pci 0000:00:1c.4: PME# disabled
> > [ =C2=A0 =C2=A00.602629] pci 0000:00:1d.0: reg 20: [io =C2=A00x6f00=
-0x6f1f]
> > [ =C2=A0 =C2=A00.602783] pci 0000:00:1d.1: reg 20: [io =C2=A00x6f20=
-0x6f3f]
> > [ =C2=A0 =C2=A00.602934] pci 0000:00:1d.2: reg 20: [io =C2=A00x6f40=
-0x6f5f]
> > [ =C2=A0 =C2=A00.603078] pci 0000:00:1d.7: reg 10: [mem 0xfed1c000-=
0xfed1c3ff]
> > [ =C2=A0 =C2=A00.603187] pci 0000:00:1d.7: PME# supported from D0 D=
3hot D3cold
> > [ =C2=A0 =C2=A00.603195] pci 0000:00:1d.7: PME# disabled
> > [ =C2=A0 =C2=A00.603580] pci 0000:00:1f.2: reg 10: [io =C2=A00x6e70=
-0x6e77]
> > [ =C2=A0 =C2=A00.603592] pci 0000:00:1f.2: reg 14: [io =C2=A00x6e78=
-0x6e7b]
> > [ =C2=A0 =C2=A00.603604] pci 0000:00:1f.2: reg 18: [io =C2=A00x6e80=
-0x6e87]
> > [ =C2=A0 =C2=A00.603616] pci 0000:00:1f.2: reg 1c: [io =C2=A00x6e88=
-0x6e8b]
> > [ =C2=A0 =C2=A00.603628] pci 0000:00:1f.2: reg 20: [io =C2=A00x6ea0=
-0x6eaf]
> > [ =C2=A0 =C2=A00.603640] pci 0000:00:1f.2: reg 24: [io =C2=A00x6e90=
-0x6e9f]
> > [ =C2=A0 =C2=A00.603762] pci 0000:00:1f.3: reg 10: [mem 0xf6afbf00-=
0xf6afbfff 64bit]
> > [ =C2=A0 =C2=A00.603793] pci 0000:00:1f.3: reg 20: [io =C2=A00x1100=
-0x111f]
> > [ =C2=A0 =C2=A00.603905] pci 0000:00:1f.5: reg 10: [io =C2=A00x6eb0=
-0x6eb7]
> > [ =C2=A0 =C2=A00.603917] pci 0000:00:1f.5: reg 14: [io =C2=A00x6eb8=
-0x6ebb]
> > [ =C2=A0 =C2=A00.603929] pci 0000:00:1f.5: reg 18: [io =C2=A00x6ec0=
-0x6ec7]
> > [ =C2=A0 =C2=A00.603941] pci 0000:00:1f.5: reg 1c: [io =C2=A00x6ec8=
-0x6ecb]
> > [ =C2=A0 =C2=A00.603953] pci 0000:00:1f.5: reg 20: [io =C2=A00x6ee0=
-0x6eef]
> > [ =C2=A0 =C2=A00.603965] pci 0000:00:1f.5: reg 24: [io =C2=A00xeff0=
-0xefff]
> > [ =C2=A0 =C2=A00.604140] pci 0000:00:1c.0: PCI bridge to [bus 0b-0b=
]
> > [ =C2=A0 =C2=A00.604519] pci 0000:0c:00.0: reg 10: [mem 0xf69fc000-=
0xf69fffff 64bit]
> > [ =C2=A0 =C2=A00.604778] pci 0000:0c:00.0: supports D1 D2
> > [ =C2=A0 =C2=A00.604781] pci 0000:0c:00.0: PME# supported from D0 D=
3hot D3cold
> > [ =C2=A0 =C2=A00.604796] pci 0000:0c:00.0: PME# disabled
> > [ =C2=A0 =C2=A00.604958] pci 0000:00:1c.1: PCI bridge to [bus 0c-0c=
]
> > [ =C2=A0 =C2=A00.604974] pci 0000:00:1c.1: =C2=A0 bridge window [me=
m 0xf6900000-0xf69fffff]
> > [ =C2=A0 =C2=A00.605134] pci 0000:09:00.0: reg 10: [mem 0xf68f0000-=
0xf68fffff 64bit]
> > [ =C2=A0 =C2=A00.605282] pci 0000:09:00.0: PME# supported from D3ho=
t D3cold
> > [ =C2=A0 =C2=A00.605291] pci 0000:09:00.0: PME# disabled
> > [ =C2=A0 =C2=A00.605402] pci 0000:00:1c.4: PCI bridge to [bus 09-09=
]
> > [ =C2=A0 =C2=A00.605418] pci 0000:00:1c.4: =C2=A0 bridge window [me=
m 0xf6800000-0xf68fffff]
> > [ =C2=A0 =C2=A00.605503] pci 0000:02:01.0: reg 10: [mem 0x00000000-=
0x00000fff]
> > [ =C2=A0 =C2=A00.605541] pci 0000:02:01.0: supports D1 D2
> > [ =C2=A0 =C2=A00.605544] pci 0000:02:01.0: PME# supported from D0 D=
1 D2 D3hot D3cold
> > [ =C2=A0 =C2=A00.605552] pci 0000:02:01.0: PME# disabled
> > [ =C2=A0 =C2=A00.605617] pci 0000:02:01.1: reg 10: [mem 0xf67ff800-=
0xf67fffff]
> > [ =C2=A0 =C2=A00.605711] pci 0000:02:01.1: supports D1 D2
> > [ =C2=A0 =C2=A00.605714] pci 0000:02:01.1: PME# supported from D0 D=
1 D2 D3hot D3cold
> > [ =C2=A0 =C2=A00.605721] pci 0000:02:01.1: PME# disabled
> > [ =C2=A0 =C2=A00.605790] pci 0000:02:01.2: reg 10: [mem 0xf67ff700-=
0xf67ff7ff]
> > [ =C2=A0 =C2=A00.605884] pci 0000:02:01.2: supports D1 D2
> > [ =C2=A0 =C2=A00.605887] pci 0000:02:01.2: PME# supported from D0 D=
1 D2 D3hot D3cold
> > [ =C2=A0 =C2=A00.605895] pci 0000:02:01.2: PME# disabled
> > [ =C2=A0 =C2=A00.606011] pci 0000:00:1e.0: PCI bridge to [bus 02-03=
] (subtractive decode)
> > [ =C2=A0 =C2=A00.606028] pci 0000:00:1e.0: =C2=A0 bridge window [me=
m 0xf6700000-0xf67fffff]
> > [ =C2=A0 =C2=A00.606075] pci_bus 0000:03: [bus 03-06] partially hid=
den behind
> > transparent bridge 0000:02 [bus 02-03]
> > [ =C2=A0 =C2=A00.606125] pci_bus 0000:00: on NUMA node 0
> > [ =C2=A0 =C2=A00.606134] ACPI: PCI Interrupt Routing Table [\_SB_.P=
CI0._PRT]
> > [ =C2=A0 =C2=A00.607778] ACPI: PCI Interrupt Routing Table [\_SB_.P=
CI0.PCIE._PRT]
> > [ =C2=A0 =C2=A00.608386] ACPI: PCI Interrupt Routing Table [\_SB_.P=
CI0.RP01._PRT]
> > [ =C2=A0 =C2=A00.608653] ACPI: PCI Interrupt Routing Table [\_SB_.P=
CI0.RP02._PRT]
> > [ =C2=A0 =C2=A00.608946] ACPI: PCI Interrupt Routing Table [\_SB_.P=
CI0.RP05._PRT]
> > [ =C2=A0 =C2=A00.667029] ACPI: PCI Interrupt Link [LNKA] (IRQs 10 *=
11)
> > [ =C2=A0 =C2=A00.667370] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 7)=
 *4
> > [ =C2=A0 =C2=A00.667708] ACPI: PCI Interrupt Link [LNKC] (IRQs 10 1=
1) *3
> > [ =C2=A0 =C2=A00.668044] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 7 =
*10 11)
> > [ =C2=A0 =C2=A00.668382] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 =
5 6 7 *10 11 12 14 15)
> > [ =C2=A0 =C2=A00.670294] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 =
5 6 *7 10 11 12 14 15)
> > [ =C2=A0 =C2=A00.670639] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 =
*5 6 7 10 11 12 14 15)
> > [ =C2=A0 =C2=A00.670927] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 =
5 6 7 10 11
> > 12 14 15) *0, disabled.
> > [ =C2=A0 =C2=A00.671151] vgaarb: device added:
> > PCI:0000:00:02.0,decodes=3Dio+mem,owns=3Dio+mem,locks=3Dnone
> > [ =C2=A0 =C2=A00.671151] vgaarb: loaded
> > [ =C2=A0 =C2=A00.673347] SCSI subsystem initialized
> > [ =C2=A0 =C2=A00.673534] libata version 3.00 loaded.
> > [ =C2=A0 =C2=A00.673633] usbcore: registered new interface driver u=
sbfs
> > [ =C2=A0 =C2=A00.673633] usbcore: registered new interface driver h=
ub
> > [ =C2=A0 =C2=A00.673633] usbcore: registered new device driver usb
> > [ =C2=A0 =C2=A00.673697] PCI: Using ACPI for IRQ routing
> > [ =C2=A0 =C2=A00.673697] PCI: pci_cache_line_size set to 64 bytes
> > [ =C2=A0 =C2=A00.677479] HPET: 4 timers in total, 0 timers will be =
used for per-cpu timer
> > [ =C2=A0 =C2=A00.677479] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
> > [ =C2=A0 =C2=A00.677479] hpet0: 4 comparators, 64-bit 14.318180 MHz=
 counter
> > [ =C2=A0 =C2=A00.686678] Switching to clocksource tsc
> > [ =C2=A0 =C2=A00.698122] pnp: PnP ACPI init
> > [ =C2=A0 =C2=A00.698167] ACPI: bus type pnp registered
> > [ =C2=A0 =C2=A00.810987] pnp: PnP ACPI: found 13 devices
> > [ =C2=A0 =C2=A00.810996] ACPI: ACPI bus type pnp unregistered
> > [ =C2=A0 =C2=A00.811028] system 00:05: [io =C2=A00x0c80-0x0caf] has=
 been reserved
> > [ =C2=A0 =C2=A00.811038] system 00:05: [io =C2=A00x0cc0-0x0cff] cou=
ld not be reserved
> > [ =C2=A0 =C2=A00.811062] system 00:08: [mem 0xfed00000-0xfed003ff] =
has been reserved
> > [ =C2=A0 =C2=A00.811085] system 00:09: [io =C2=A00x0cb0-0x0cbb] has=
 been reserved
> > [ =C2=A0 =C2=A00.811104] system 00:09: [mem 0xfed40000-0xfed44fff] =
has been reserved
> > [ =C2=A0 =C2=A00.811126] system 00:0a: [io =C2=A00x0900-0x092f] has=
 been reserved
> > [ =C2=A0 =C2=A00.811135] system 00:0a: [io =C2=A00x0931-0x0933] has=
 been reserved
> > [ =C2=A0 =C2=A00.811144] system 00:0a: [io =C2=A00x0935-0x097f] has=
 been reserved
> > [ =C2=A0 =C2=A00.811152] system 00:0a: [io =C2=A00x04d0-0x04d1] has=
 been reserved
> > [ =C2=A0 =C2=A00.811161] system 00:0a: [io =C2=A00x1000-0x1005] has=
 been reserved
> > [ =C2=A0 =C2=A00.811170] system 00:0a: [io =C2=A00x1008-0x100f] has=
 been reserved
> > [ =C2=A0 =C2=A00.811192] system 00:0b: [io =C2=A00xf400-0xf4fe] has=
 been reserved
> > [ =C2=A0 =C2=A00.811201] system 00:0b: [io =C2=A00x1006-0x1007] has=
 been reserved
> > [ =C2=A0 =C2=A00.811211] system 00:0b: [io =C2=A00x100a-0x1059] cou=
ld not be reserved
> > [ =C2=A0 =C2=A00.811219] system 00:0b: [io =C2=A00x1060-0x107f] has=
 been reserved
> > [ =C2=A0 =C2=A00.811228] system 00:0b: [io =C2=A00x1080-0x10bf] has=
 been reserved
> > [ =C2=A0 =C2=A00.811236] system 00:0b: [io =C2=A00x1100-0x111f] has=
 been reserved
> > [ =C2=A0 =C2=A00.811245] system 00:0b: [io =C2=A00x1010-0x102f] has=
 been reserved
> > [ =C2=A0 =C2=A00.811253] system 00:0b: [io =C2=A00x0809] has been r=
eserved
> > [ =C2=A0 =C2=A00.811276] system 00:0c: [mem 0x00000000-0x0009efff] =
could not be reserved
> > [ =C2=A0 =C2=A00.811287] system 00:0c: [mem 0x0009f000-0x0009ffff] =
could not be reserved
> > [ =C2=A0 =C2=A00.811297] system 00:0c: [mem 0x000c0000-0x000cffff] =
could not be reserved
> > [ =C2=A0 =C2=A00.811307] system 00:0c: [mem 0x000e0000-0x000fffff] =
could not be reserved
> > [ =C2=A0 =C2=A00.811318] system 00:0c: [mem 0x00100000-0x3d38d3ff] =
could not be reserved
> > [ =C2=A0 =C2=A00.811328] system 00:0c: [mem 0x3d38d400-0x3dafffff] =
could not be reserved
> > [ =C2=A0 =C2=A00.811338] system 00:0c: [mem 0x3db00000-0x3dbfffff] =
has been reserved
> > [ =C2=A0 =C2=A00.811347] system 00:0c: [mem 0xffe80000-0xffffffff] =
has been reserved
> > [ =C2=A0 =C2=A00.811356] system 00:0c: [mem 0xffa00000-0xffb7ffff] =
has been reserved
> > [ =C2=A0 =C2=A00.811366] system 00:0c: [mem 0xfec00000-0xfec0ffff] =
could not be reserved
> > [ =C2=A0 =C2=A00.811376] system 00:0c: [mem 0xfee00000-0xfee0ffff] =
has been reserved
> > [ =C2=A0 =C2=A00.811385] system 00:0c: [mem 0xfed20000-0xfed3ffff] =
has been reserved
> > [ =C2=A0 =C2=A00.811394] system 00:0c: [mem 0xfed45000-0xfed8ffff] =
has been reserved
> > [ =C2=A0 =C2=A00.811403] system 00:0c: [mem 0xfeda0000-0xfeda3fff] =
has been reserved
> > [ =C2=A0 =C2=A00.811413] system 00:0c: [mem 0xfeda4000-0xfeda4fff] =
has been reserved
> > [ =C2=A0 =C2=A00.811423] system 00:0c: [mem 0xfeda5000-0xfeda5fff] =
has been reserved
> > [ =C2=A0 =C2=A00.811432] system 00:0c: [mem 0xfeda6000-0xfeda6fff] =
has been reserved
> > [ =C2=A0 =C2=A00.811441] system 00:0c: [mem 0xfed1c800-0xfed1cfff] =
has been reserved
> > [ =C2=A0 =C2=A00.811451] system 00:0c: [mem 0xfed18000-0xfed1bfff] =
has been reserved
> > [ =C2=A0 =C2=A00.811460] system 00:0c: [mem 0xf8000000-0xfbffffff] =
has been reserved
> > [ =C2=A0 =C2=A00.848952] b43-pci-bridge 0000:0c:00.0: PCI INT A -> =
GSI 17
> > (level, low) -> IRQ 17
> > [ =C2=A0 =C2=A00.848977] b43-pci-bridge 0000:0c:00.0: setting laten=
cy timer to 64
> > [ =C2=A0 =C2=A00.863385] ssb: Core 0 found: ChipCommon (cc 0x800, r=
ev 0x16, vendor 0x4243)
> > [ =C2=A0 =C2=A00.863405] ssb: Core 1 found: IEEE 802.11 (cc 0x812, =
rev 0x0F,
> > vendor 0x4243)
> > [ =C2=A0 =C2=A00.863425] ssb: Core 2 found: PCMCIA (cc 0x80D, rev 0=
x0A, vendor 0x4243)
> > [ =C2=A0 =C2=A00.863445] ssb: Core 3 found: PCI-E (cc 0x820, rev 0x=
09, vendor 0x4243)
> > [ =C2=A0 =C2=A00.879792] ssb: Found rev 1 PMU (capabilities 0x02A62=
=4601)
> > [ =C2=A0 =C2=A00.889038] ssb: SPROM revision 8 detected.
> > [ =C2=A0 =C2=A00.903507] ssb: Sonics Silicon Backplane found on PCI=
 device 0000:0c:00.0
> > [ =C2=A0 =C2=A00.903853] pci 0000:00:1e.0: BAR 9: assigned [mem
> > 0x40000000-0x43ffffff pref]
> > [ =C2=A0 =C2=A00.903864] pci 0000:00:1c.0: BAR 8: assigned [mem 0x4=
4000000-0x441fffff]
> > [ =C2=A0 =C2=A00.903873] pci 0000:00:1c.0: BAR 9: assigned [mem
> > 0x44200000-0x443fffff 64bit pref]
> > [ =C2=A0 =C2=A00.903883] pci 0000:00:1c.1: BAR 9: assigned [mem
> > 0x44400000-0x445fffff 64bit pref]
> > [ =C2=A0 =C2=A00.903893] pci 0000:00:1c.4: BAR 9: assigned [mem
> > 0x44600000-0x447fffff 64bit pref]
> > [ =C2=A0 =C2=A00.903903] pci 0000:00:1c.0: BAR 7: assigned [io =C2=A0=
0x2000-0x2fff]
> > [ =C2=A0 =C2=A00.903911] pci 0000:00:1c.1: BAR 7: assigned [io =C2=A0=
0x3000-0x3fff]
> > [ =C2=A0 =C2=A00.903919] pci 0000:00:1c.4: BAR 7: assigned [io =C2=A0=
0x4000-0x4fff]
> > [ =C2=A0 =C2=A00.903927] pci 0000:00:1e.0: BAR 7: assigned [io =C2=A0=
0x5000-0x5fff]
> > [ =C2=A0 =C2=A00.903935] pci 0000:00:1c.0: PCI bridge to [bus 0b-0b=
]
> > [ =C2=A0 =C2=A00.903944] pci 0000:00:1c.0: =C2=A0 bridge window [io=
 =C2=A00x2000-0x2fff]
> > [ =C2=A0 =C2=A00.903958] pci 0000:00:1c.0: =C2=A0 bridge window [me=
m 0x44000000-0x441fffff]
> > [ =C2=A0 =C2=A00.903970] pci 0000:00:1c.0: =C2=A0 bridge window [me=
m
> > 0x44200000-0x443fffff 64bit pref]
> > [ =C2=A0 =C2=A00.903987] pci 0000:00:1c.1: PCI bridge to [bus 0c-0c=
]
> > [ =C2=A0 =C2=A00.903996] pci 0000:00:1c.1: =C2=A0 bridge window [io=
 =C2=A00x3000-0x3fff]
> > [ =C2=A0 =C2=A00.904009] pci 0000:00:1c.1: =C2=A0 bridge window [me=
m 0xf6900000-0xf69fffff]
> > [ =C2=A0 =C2=A00.904021] pci 0000:00:1c.1: =C2=A0 bridge window [me=
m
> > 0x44400000-0x445fffff 64bit pref]
> > [ =C2=A0 =C2=A00.904038] pci 0000:00:1c.4: PCI bridge to [bus 09-09=
]
> > [ =C2=A0 =C2=A00.904047] pci 0000:00:1c.4: =C2=A0 bridge window [io=
 =C2=A00x4000-0x4fff]
> > [ =C2=A0 =C2=A00.904061] pci 0000:00:1c.4: =C2=A0 bridge window [me=
m 0xf6800000-0xf68fffff]
> > [ =C2=A0 =C2=A00.904073] pci 0000:00:1c.4: =C2=A0 bridge window [me=
m
> > 0x44600000-0x447fffff 64bit pref]
> > [ =C2=A0 =C2=A00.904094] pci 0000:02:01.0: BAR 9: assigned [mem
> > 0x40000000-0x43ffffff pref]
> > [ =C2=A0 =C2=A00.904105] pci 0000:02:01.0: BAR 10: assigned [mem 0x=
48000000-0x4bffffff]
> > [ =C2=A0 =C2=A00.904113] pci 0000:02:01.0: BAR 0: assigned [mem 0xf=
6700000-0xf6700fff]
> > [ =C2=A0 =C2=A00.904126] pci 0000:02:01.0: BAR 0: set to [mem
> > 0xf6700000-0xf6700fff] (PCI address [0xf6700000-0xf6700fff]
> > [ =C2=A0 =C2=A00.904137] pci 0000:02:01.0: BAR 7: assigned [io =C2=A0=
0x5000-0x50ff]
> > [ =C2=A0 =C2=A00.904145] pci 0000:02:01.0: BAR 8: assigned [io =C2=A0=
0x5100-0x51ff]
> > [ =C2=A0 =C2=A00.904152] pci 0000:02:01.0: CardBus bridge to [bus 0=
3-06]
> > [ =C2=A0 =C2=A00.904159] pci 0000:02:01.0: =C2=A0 bridge window [io=
 =C2=A00x5000-0x50ff]
> > [ =C2=A0 =C2=A00.904170] pci 0000:02:01.0: =C2=A0 bridge window [io=
 =C2=A00x5100-0x51ff]
> > [ =C2=A0 =C2=A00.904182] pci 0000:02:01.0: =C2=A0 bridge window [me=
m
> > 0x40000000-0x43ffffff pref]
> > [ =C2=A0 =C2=A00.904194] pci 0000:02:01.0: =C2=A0 bridge window [me=
m 0x48000000-0x4bffffff]
> > [ =C2=A0 =C2=A00.904206] pci 0000:00:1e.0: PCI bridge to [bus 02-03=
]
> > [ =C2=A0 =C2=A00.904214] pci 0000:00:1e.0: =C2=A0 bridge window [io=
 =C2=A00x5000-0x5fff]
> > [ =C2=A0 =C2=A00.904228] pci 0000:00:1e.0: =C2=A0 bridge window [me=
m 0xf6700000-0xf67fffff]
> > [ =C2=A0 =C2=A00.904240] pci 0000:00:1e.0: =C2=A0 bridge window [me=
m
> > 0x40000000-0x43ffffff pref]
> > [ =C2=A0 =C2=A00.904273] pci 0000:00:1c.0: PCI INT A -> GSI 16 (lev=
el, low) -> IRQ 16
> > [ =C2=A0 =C2=A00.904285] pci 0000:00:1c.0: setting latency timer to=
 64
> > [ =C2=A0 =C2=A00.904302] pci 0000:00:1c.1: PCI INT B -> GSI 17 (lev=
el, low) -> IRQ 17
> > [ =C2=A0 =C2=A00.904314] pci 0000:00:1c.1: setting latency timer to=
 64
> > [ =C2=A0 =C2=A00.904330] pci 0000:00:1c.4: PCI INT A -> GSI 16 (lev=
el, low) -> IRQ 16
> > [ =C2=A0 =C2=A00.904342] pci 0000:00:1c.4: setting latency timer to=
 64
> > [ =C2=A0 =C2=A00.904355] pci 0000:00:1e.0: setting latency timer to=
 64
> > [ =C2=A0 =C2=A00.904375] pci 0000:02:01.0: PCI INT A -> GSI 19 (lev=
el, low) -> IRQ 19
> > [ =C2=A0 =C2=A00.904388] pci_bus 0000:00: resource 0 [io =C2=A00x00=
00-0xffff]
> > [ =C2=A0 =C2=A00.904392] pci_bus 0000:00: resource 1 [mem 0x0000000=
0-0xffffffff]
> > [ =C2=A0 =C2=A00.904395] pci_bus 0000:0b: resource 0 [io =C2=A00x20=
00-0x2fff]
> > [ =C2=A0 =C2=A00.904398] pci_bus 0000:0b: resource 1 [mem 0x4400000=
0-0x441fffff]
> > [ =C2=A0 =C2=A00.904402] pci_bus 0000:0b: resource 2 [mem 0x4420000=
0-0x443fffff
> > 64bit pref]
> > [ =C2=A0 =C2=A00.904405] pci_bus 0000:0c: resource 0 [io =C2=A00x30=
00-0x3fff]
> > [ =C2=A0 =C2=A00.904408] pci_bus 0000:0c: resource 1 [mem 0xf690000=
0-0xf69fffff]
> > [ =C2=A0 =C2=A00.904412] pci_bus 0000:0c: resource 2 [mem 0x4440000=
0-0x445fffff
> > 64bit pref]
> > [ =C2=A0 =C2=A00.904415] pci_bus 0000:09: resource 0 [io =C2=A00x40=
00-0x4fff]
> > [ =C2=A0 =C2=A00.904418] pci_bus 0000:09: resource 1 [mem 0xf680000=
0-0xf68fffff]
> > [ =C2=A0 =C2=A00.904422] pci_bus 0000:09: resource 2 [mem 0x4460000=
0-0x447fffff
> > 64bit pref]
> > [ =C2=A0 =C2=A00.904425] pci_bus 0000:02: resource 0 [io =C2=A00x50=
00-0x5fff]
> > [ =C2=A0 =C2=A00.904428] pci_bus 0000:02: resource 1 [mem 0xf670000=
0-0xf67fffff]
> > [ =C2=A0 =C2=A00.904432] pci_bus 0000:02: resource 2 [mem 0x4000000=
0-0x43ffffff pref]
> > [ =C2=A0 =C2=A00.904435] pci_bus 0000:02: resource 3 [io =C2=A00x00=
00-0xffff]
> > [ =C2=A0 =C2=A00.904438] pci_bus 0000:02: resource 4 [mem 0x0000000=
0-0xffffffff]
> > [ =C2=A0 =C2=A00.904441] pci_bus 0000:03: resource 0 [io =C2=A00x50=
00-0x50ff]
> > [ =C2=A0 =C2=A00.904444] pci_bus 0000:03: resource 1 [io =C2=A00x51=
00-0x51ff]
> > [ =C2=A0 =C2=A00.904447] pci_bus 0000:03: resource 2 [mem 0x4000000=
0-0x43ffffff pref]
> > [ =C2=A0 =C2=A00.904451] pci_bus 0000:03: resource 3 [mem 0x4800000=
0-0x4bffffff]
> > [ =C2=A0 =C2=A00.904632] NET: Registered protocol family 2
> > [ =C2=A0 =C2=A00.904933] IP route cache hash table entries: 32768 (=
order: 5, 131072 bytes)
> > [ =C2=A0 =C2=A00.905890] TCP established hash table entries: 131072=
 (order: 8,
> > 1048576 bytes)
> > [ =C2=A0 =C2=A00.906395] TCP bind hash table entries: 65536 (order:=
 9, 2097152 bytes)
> > [ =C2=A0 =C2=A00.914821] TCP: Hash tables configured (established 1=
31072 bind 65536)
> > [ =C2=A0 =C2=A00.914889] TCP reno registered
> > [ =C2=A0 =C2=A00.914906] UDP hash table entries: 512 (order: 3, 409=
60 bytes)
> > [ =C2=A0 =C2=A00.915056] UDP-Lite hash table entries: 512 (order: 3=
, 40960 bytes)
> > [ =C2=A0 =C2=A00.915548] NET: Registered protocol family 1
> > [ =C2=A0 =C2=A00.915594] pci 0000:00:02.0: Boot video device
> > [ =C2=A0 =C2=A00.916138] PCI: CLS 64 bytes, default 64
> > [ =C2=A0 =C2=A00.920703] microcode: CPU0 sig=3D0x6fd, pf=3D0x80, re=
vision=3D0xa3
> > [ =C2=A0 =C2=A00.920737] microcode: CPU1 sig=3D0x6fd, pf=3D0x80, re=
vision=3D0xa3
> > [ =C2=A0 =C2=A00.920934] Microcode Update Driver: v2.00
> > <tigran@aivazian.fsnet.co.uk>, Peter Oruba
> > [ =C2=A0 =C2=A00.921968] audit: initializing netlink socket (disabl=
ed)
> > [ =C2=A0 =C2=A00.922049] type=3D2000 audit(1260459007.916:1): initi=
alized
> > [ =C2=A0 =C2=A00.930909] highmem bounce pool size: 64 pages
> > [ =C2=A0 =C2=A00.930924] HugeTLB registered 4 MB page size, pre-all=
ocated 0 pages
> > [ =C2=A0 =C2=A00.931615] VFS: Disk quotas dquot_6.5.2
> > [ =C2=A0 =C2=A00.931702] Dquot-cache hash table entries: 1024 (orde=
r 0, 4096 bytes)
> > [ =C2=A0 =C2=A00.933146] Btrfs loaded
> > [ =C2=A0 =C2=A00.933162] msgmni has been set to 1733
> > [ =C2=A0 =C2=A00.934396] alg: No test for stdrng (krng)
> > [ =C2=A0 =C2=A00.934614] Block layer SCSI generic (bsg) driver vers=
ion 0.4
> > loaded (major 253)
> > [ =C2=A0 =C2=A00.934641] io scheduler noop registered
> > [ =C2=A0 =C2=A00.934647] io scheduler deadline registered
> > [ =C2=A0 =C2=A00.934697] io scheduler cfq registered (default)
> > [ =C2=A0 =C2=A00.935545] pcieport 0000:00:1c.0: setting latency tim=
er to 64
> > [ =C2=A0 =C2=A00.935634] pcieport 0000:00:1c.0: irq 24 for MSI/MSI-=
X
> > [ =C2=A0 =C2=A00.936286] pcieport 0000:00:1c.1: setting latency tim=
er to 64
> > [ =C2=A0 =C2=A00.936377] pcieport 0000:00:1c.1: irq 25 for MSI/MSI-=
X
> > [ =C2=A0 =C2=A00.937034] pcieport 0000:00:1c.4: setting latency tim=
er to 64
> > [ =C2=A0 =C2=A00.937118] pcieport 0000:00:1c.4: irq 26 for MSI/MSI-=
X
> > [ =C2=A0 =C2=A00.938238] pci_hotplug: PCI Hot Plug PCI Core version=
: 0.5
> > [ =C2=A0 =C2=A00.939692] ALI M7101 PMU not found.
> > [ =C2=A0 =C2=A00.940148] vesafb: framebuffer at 0xe0000000, mapped =
to
> > 0xf8080000, using 3072k, total 32704k
> > [ =C2=A0 =C2=A00.940158] vesafb: mode is 1024x768x16, linelength=3D=
2048, pages=3D20
> > [ =C2=A0 =C2=A00.940165] vesafb: scrolling: redraw
> > [ =C2=A0 =C2=A00.940171] vesafb: Truecolor: size=3D0:5:6:5, shift=3D=
0:11:5:0
> > [ =C2=A0 =C2=A00.953782] Console: switching to colour frame buffer =
device 128x48
> > [ =C2=A0 =C2=A00.966131] fb0: VESA VGA frame buffer device
> > [ =C2=A0 =C2=A00.967114] ACPI: AC Adapter [AC] (on-line)
> > [ =C2=A0 =C2=A00.968048] input: Lid Switch as
> > /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0D:00/input/input0
> > [ =C2=A0 =C2=A00.970682] ACPI: Lid Switch [LID]
> > [ =C2=A0 =C2=A00.971064] input: Power Button as
> > /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input1
> > [ =C2=A0 =C2=A00.971270] ACPI: Power Button [PBTN]
> > [ =C2=A0 =C2=A00.971668] input: Sleep Button as
> > /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/input2
> > [ =C2=A0 =C2=A00.971869] ACPI: Sleep Button [SBTN]
> > [ =C2=A0 =C2=A00.973787] ACPI: SSDT 3d390953 002C3 (v01 =C2=A0PmRef=
 =C2=A0 BspIst 00003000
> > INTL 20050624)
> > [ =C2=A0 =C2=A00.976373] ACPI: SSDT 3d390ded 005C6 (v01 =C2=A0PmRef=
 =C2=A0 BspCst 00003001
> > INTL 20050624)
> > [ =C2=A0 =C2=A00.978792] Monitor-Mwait will be used to enter C-1 st=
ate
> > [ =C2=A0 =C2=A00.978888] Monitor-Mwait will be used to enter C-2 st=
ate
> > [ =C2=A0 =C2=A00.978969] Monitor-Mwait will be used to enter C-3 st=
ate
> > [ =C2=A0 =C2=A00.978985] Marking TSC unstable due to TSC halts in i=
dle
> > [ =C2=A0 =C2=A00.979117] Switching to clocksource hpet
> > [ =C2=A0 =C2=A00.980233] processor LNXCPU:00: registered as cooling=
_device0
> > [ =C2=A0 =C2=A00.981727] ACPI: SSDT 3d390c16 001D7 (v01 =C2=A0PmRef=
 =C2=A0 =C2=A0ApIst 00003000
> > INTL 20050624)
> > [ =C2=A0 =C2=A00.984297] ACPI: SSDT 3d3913b3 0008D (v01 =C2=A0PmRef=
 =C2=A0 =C2=A0ApCst 00003000
> > INTL 20050624)
> > [ =C2=A0 =C2=A00.987470] processor LNXCPU:01: registered as cooling=
_device1
> > [ =C2=A0 =C2=A01.036564] thermal LNXTHERM:01: registered as thermal=
_zone0
> > [ =C2=A0 =C2=A01.036744] ACPI: Thermal Zone [THM] (50 C)
> > [ =C2=A0 =C2=A01.057169] Non-volatile memory driver v1.3
> > [ =C2=A0 =C2=A01.058010] i8k: unable to get SMM BIOS version
> > [ =C2=A0 =C2=A01.058127] Dell laptop SMM driver v1.14 21/02/2005 Ma=
ssimo Dal
> > Zotto (dz@debian.org)
> > [ =C2=A0 =C2=A01.058728] Linux agpgart interface v0.103
> > [ =C2=A0 =C2=A01.059781] agpgart-intel 0000:00:00.0: Intel Mobile I=
ntel=C2=AE GM45
> > Express Chipset
> > [ =C2=A0 =C2=A01.066202] agpgart-intel 0000:00:00.0: detected 32764=
K stolen memory
> > [ =C2=A0 =C2=A01.075474] agpgart-intel 0000:00:00.0: AGP aperture i=
s 256M @ 0xe0000000
> > [ =C2=A0 =C2=A01.081183] Hangcheck: starting hangcheck timer 0.9.0 =
(tick is 180
> > seconds, margin is 60 seconds).
> > [ =C2=A0 =C2=A01.086768] Hangcheck: Using get_cycles().
> > [ =C2=A0 =C2=A01.092487] [drm] Initialized drm 1.1.0 20060810
> > [ =C2=A0 =C2=A01.098041] i915 0000:00:02.0: PCI INT A -> GSI 16 (le=
vel, low) -> IRQ 16
> > [ =C2=A0 =C2=A01.103610] i915 0000:00:02.0: setting latency timer t=
o 64
> > [ =C2=A0 =C2=A01.109032] mtrr: type mismatch for e0000000,10000000 =
old:
> > write-back new: write-combining
> > [ =C2=A0 =C2=A01.114711] [drm] MTRR allocation failed. =C2=A0Graphi=
cs performance may suffer.
> > [ =C2=A0 =C2=A01.120525] i915 0000:00:02.0: irq 27 for MSI/MSI-X
> > [ =C2=A0 =C2=A01.120541] [drm] set up 31M of stolen space
> > [ =C2=A0 =C2=A01.173585] ACPI: Battery Slot [BAT0] (battery present=
)
> > [ =C2=A0 =C2=A01.743361] [drm] TV-21: set mode NTSC 480i 0
> > [ =C2=A0 =C2=A01.917419] fb: conflicting fb hw usage inteldrmfb vs =
VESA VGA -
> > removing generic driver
> > [ =C2=A0 =C2=A01.923290] Console: switching to colour dummy device =
80x25
> > [ =C2=A0 =C2=A01.993413] [drm] LVDS-8: set mode 1280x800 c
> > [ =C2=A0 =C2=A02.180028] async/0 used greatest stack depth: 6240 by=
tes left
> > [ =C2=A0 =C2=A02.311701] Console: switching to colour frame buffer =
device 160x50
> > [ =C2=A0 =C2=A02.344161] fb0: inteldrmfb frame buffer device
> > [ =C2=A0 =C2=A02.344163] registered panic notifier
> > [ =C2=A0 =C2=A02.381263] acpi device:3b: registered as cooling_devi=
ce2
> > [ =C2=A0 =C2=A02.383064] input: Video Bus as
> > /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A03:00/LNXVIDEO:01/input/input=
3
> > [ =C2=A0 =C2=A02.383507] ACPI: Video Device [VID1] (multi-head: yes=
 =C2=A0rom: no =C2=A0post: no)
> > [ =C2=A0 =C2=A02.383961] ACPI Warning for \_SB_.PCI0.VID2._DOD: Ret=
urn Package
> > has no elements (empty) (20091112/nspredef-439)
> > [ =C2=A0 =C2=A02.384794] input: Video Bus as
> > /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A03:00/LNXVIDEO:02/input/input=
4
> > [ =C2=A0 =C2=A02.385220] ACPI: Video Device [VID2] (multi-head: yes=
 =C2=A0rom: no =C2=A0post: no)
> > [ =C2=A0 =C2=A02.385736] [drm] Initialized i915 1.6.0 20080730 for =
0000:00:02.0 on minor 0
> > [ =C2=A0 =C2=A02.386291] Serial: 8250/16550 driver, 4 ports, IRQ sh=
aring enabled
> > [ =C2=A0 =C2=A02.397666] brd: module loaded
> > [ =C2=A0 =C2=A02.402531] loop: module loaded
> > [ =C2=A0 =C2=A02.403545] Loading iSCSI transport class v2.0-870.
> > [ =C2=A0 =C2=A02.405776] ata_piix 0000:00:1f.2: version 2.13
> > [ =C2=A0 =C2=A02.405803] ata_piix 0000:00:1f.2: PCI INT D -> GSI 19=
 (level, low) -> IRQ 19
> > [ =C2=A0 =C2=A02.406147] ata_piix 0000:00:1f.2: MAP [ P0 -- P1 -- ]
> > [ =C2=A0 =C2=A02.406810] ata_piix 0000:00:1f.2: setting latency tim=
er to 64
> > [ =C2=A0 =C2=A02.406998] scsi0 : ata_piix
> > [ =C2=A0 =C2=A02.407806] scsi1 : ata_piix
> > [ =C2=A0 =C2=A02.410373] ata1: SATA max UDMA/133 cmd 0x6e70 ctl 0x6=
e78 bmdma 0x6ea0 irq 19
> > [ =C2=A0 =C2=A02.410705] ata2: SATA max UDMA/133 cmd 0x6e80 ctl 0x6=
e88 bmdma 0x6ea8 irq 19
> > [ =C2=A0 =C2=A02.411165] ata_piix 0000:00:1f.5: PCI INT D -> GSI 19=
 (level, low) -> IRQ 19
> > [ =C2=A0 =C2=A02.411501] ata_piix 0000:00:1f.5: MAP [ P0 -- P1 -- ]
> > [ =C2=A0 =C2=A02.563394] ata_piix 0000:00:1f.5: setting latency tim=
er to 64
> > [ =C2=A0 =C2=A02.563493] scsi2 : ata_piix
> > [ =C2=A0 =C2=A02.564121] scsi3 : ata_piix
> > [ =C2=A0 =C2=A02.575834] ata3: SATA max UDMA/133 cmd 0x6eb0 ctl 0x6=
eb8 bmdma 0x6ee0 irq 19
> > [ =C2=A0 =C2=A02.586887] ata4: SATA max UDMA/133 cmd 0x6ec0 ctl 0x6=
ec8 bmdma 0x6ee8 irq 19
> > [ =C2=A0 =C2=A02.600548] tg3.c:v3.105 (December 2, 2009)
> > [ =C2=A0 =C2=A02.611593] tg3 0000:09:00.0: PCI INT A -> GSI 16 (lev=
el, low) -> IRQ 16
> > [ =C2=A0 =C2=A02.622751] tg3 0000:09:00.0: setting latency timer to=
 64
> > [ =C2=A0 =C2=A02.638698] eth0: Tigon3 [partno(BCM95756m) rev a200] =
(PCI Express)
> > MAC address 00:21:9b:f5:60:0f
> > [ =C2=A0 =C2=A02.650064] eth0: attached PHY is 5722/5756 (10/100/10=
00Base-T
> > Ethernet) (WireSpeed[1])
> > [ =C2=A0 =C2=A02.661533] eth0: RXcsums[1] LinkChgREG[0] MIirq[0] AS=
=46[0] TSOcap[1]
> > [ =C2=A0 =C2=A02.673063] eth0: dma_rwctrl[76180000] dma_mask[64-bit=
]
> > [ =C2=A0 =C2=A02.684889] sky2 driver version 1.26
> > [ =C2=A0 =C2=A02.696408] PPP generic driver version 2.4.2
> > [ =C2=A0 =C2=A02.708158] PPP Deflate Compression module registered
> > [ =C2=A0 =C2=A02.719445] PPP BSD Compression module registered
> > [ =C2=A0 =C2=A02.731444] PPP MPPE Compression module registered
> > [ =C2=A0 =C2=A02.742638] NET: Registered protocol family 24
> > [ =C2=A0 =C2=A02.753770] PPPoL2TP kernel driver, V1.0
> > [ =C2=A0 =C2=A02.764836] SLIP: version 0.8.4-NET3.019-NEWTTY (dynam=
ic channels,
> > max=3D256) (6 bit encapsulation enabled).
> > [ =C2=A0 =C2=A02.776283] CSLIP: code copyright 1989 Regents of the =
University of
> > California.
> > [ =C2=A0 =C2=A02.787734] SLIP linefill/keepalive option.
> > [ =C2=A0 =C2=A02.799316] console [netcon0] enabled
> > [ =C2=A0 =C2=A02.810537] netconsole: network logging started
> > [ =C2=A0 =C2=A02.822002] ehci_hcd: USB 2.0 'Enhanced' Host Controll=
er (EHCI) Driver
> > [ =C2=A0 =C2=A02.833433] ehci_hcd 0000:00:1a.7: PCI INT C -> GSI 22=
 (level, low) -> IRQ 22
> > [ =C2=A0 =C2=A02.844842] ehci_hcd 0000:00:1a.7: setting latency tim=
er to 64
> > [ =C2=A0 =C2=A02.844848] ehci_hcd 0000:00:1a.7: EHCI Host Controlle=
r
> > [ =C2=A0 =C2=A02.856214] ehci_hcd 0000:00:1a.7: new USB bus registe=
red, assigned
> > bus number 1
> > [ =C2=A0 =C2=A02.867638] ehci_hcd 0000:00:1a.7: debug port 1
> > [ =C2=A0 =C2=A02.882679] ehci_hcd 0000:00:1a.7: cache line size of =
64 is not supported
> > [ =C2=A0 =C2=A02.882717] ehci_hcd 0000:00:1a.7: irq 22, io mem 0xfe=
d1c400
> > [ =C2=A0 =C2=A02.894255] ata1: SATA link up 3.0 Gbps (SStatus 123 S=
Control 300)
> > [ =C2=A0 =C2=A02.905663] ata2: SATA link up 1.5 Gbps (SStatus 113 S=
Control 300)
> > [ =C2=A0 =C2=A02.906708] ehci_hcd 0000:00:1a.7: USB 2.0 started, EH=
CI 1.00
> > [ =C2=A0 =C2=A02.906949] usb usb1: New USB device found, idVendor=3D=
1d6b, idProduct=3D0002
> > [ =C2=A0 =C2=A02.906952] usb usb1: New USB device strings: Mfr=3D3,=
 Product=3D2,
> > SerialNumber=3D1
> > [ =C2=A0 =C2=A02.906955] usb usb1: Product: EHCI Host Controller
> > [ =C2=A0 =C2=A02.906958] usb usb1: Manufacturer: Linux 2.6.32-mm1 e=
hci_hcd
> > [ =C2=A0 =C2=A02.906960] usb usb1: SerialNumber: 0000:00:1a.7
> > [ =C2=A0 =C2=A02.908100] hub 1-0:1.0: USB hub found
> > [ =C2=A0 =C2=A02.908116] hub 1-0:1.0: 6 ports detected
> > [ =C2=A0 =C2=A02.908556] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 20=
 (level, low) -> IRQ 20
> > [ =C2=A0 =C2=A02.908581] ehci_hcd 0000:00:1d.7: setting latency tim=
er to 64
> > [ =C2=A0 =C2=A02.908585] ehci_hcd 0000:00:1d.7: EHCI Host Controlle=
r
> > [ =C2=A0 =C2=A02.908603] ehci_hcd 0000:00:1d.7: new USB bus registe=
red, assigned
> > bus number 2
> > [ =C2=A0 =C2=A02.908679] ehci_hcd 0000:00:1d.7: debug port 1
> > [ =C2=A0 =C2=A02.912557] ehci_hcd 0000:00:1d.7: cache line size of =
64 is not supported
> > [ =C2=A0 =C2=A02.912592] ehci_hcd 0000:00:1d.7: irq 20, io mem 0xfe=
d1c000
> > [ =C2=A0 =C2=A02.934701] ata3: SATA link down (SStatus 0 SControl 3=
00)
> > [ =C2=A0 =C2=A02.946085] ata4: SATA link down (SStatus 4 SControl 3=
00)
> > [ =C2=A0 =C2=A02.946126] ehci_hcd 0000:00:1d.7: USB 2.0 started, EH=
CI 1.00
> > [ =C2=A0 =C2=A02.946207] usb usb2: New USB device found, idVendor=3D=
1d6b, idProduct=3D0002
> > [ =C2=A0 =C2=A02.946210] usb usb2: New USB device strings: Mfr=3D3,=
 Product=3D2,
> > SerialNumber=3D1
> > [ =C2=A0 =C2=A02.946212] usb usb2: Product: EHCI Host Controller
> > [ =C2=A0 =C2=A02.946215] usb usb2: Manufacturer: Linux 2.6.32-mm1 e=
hci_hcd
> > [ =C2=A0 =C2=A02.946217] usb usb2: SerialNumber: 0000:00:1d.7
> > [ =C2=A0 =C2=A02.946808] hub 2-0:1.0: USB hub found
> > [ =C2=A0 =C2=A02.946831] hub 2-0:1.0: 6 ports detected
> > [ =C2=A0 =C2=A02.947216] uhci_hcd: USB Universal Host Controller In=
terface driver
> > [ =C2=A0 =C2=A03.159489] uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 20=
 (level, low) -> IRQ 20
> > [ =C2=A0 =C2=A03.160208] ata1.00: ATA-8: ST9160310AS, DE04, max UDM=
A/133
> > [ =C2=A0 =C2=A03.160212] ata1.00: 312581808 sectors, multi 8: LBA48=
 NCQ (depth 0/32)
> > [ =C2=A0 =C2=A03.189480] uhci_hcd 0000:00:1a.0: setting latency tim=
er to 64
> > [ =C2=A0 =C2=A03.189485] uhci_hcd 0000:00:1a.0: UHCI Host Controlle=
r
> > [ =C2=A0 =C2=A03.191391] ata2.00: ATAPI: TSSTcorp DVD+/-RW TS-L633A=
, D500, max UDMA/100
> > [ =C2=A0 =C2=A03.191405] ata2.00: applying bridge limits
> > [ =C2=A0 =C2=A03.219002] uhci_hcd 0000:00:1a.0: new USB bus registe=
red, assigned
> > bus number 3
> > [ =C2=A0 =C2=A03.229172] ata1.00: configured for UDMA/133
> > [ =C2=A0 =C2=A03.229191] uhci_hcd 0000:00:1a.0: irq 20, io base 0x0=
0006f60
> > [ =C2=A0 =C2=A03.229343] usb usb3: New USB device found, idVendor=3D=
1d6b, idProduct=3D0001
> > [ =C2=A0 =C2=A03.229347] usb usb3: New USB device strings: Mfr=3D3,=
 Product=3D2,
> > SerialNumber=3D1
> > [ =C2=A0 =C2=A03.229349] usb usb3: Product: UHCI Host Controller
> > [ =C2=A0 =C2=A03.229351] usb usb3: Manufacturer: Linux 2.6.32-mm1 u=
hci_hcd
> > [ =C2=A0 =C2=A03.229354] usb usb3: SerialNumber: 0000:00:1a.0
> > [ =C2=A0 =C2=A03.229946] hub 3-0:1.0: USB hub found
> > [ =C2=A0 =C2=A03.230036] hub 3-0:1.0: 2 ports detected
> > [ =C2=A0 =C2=A03.230281] uhci_hcd 0000:00:1a.1: PCI INT B -> GSI 21=
 (level, low) -> IRQ 21
> > [ =C2=A0 =C2=A03.230296] uhci_hcd 0000:00:1a.1: setting latency tim=
er to 64
> > [ =C2=A0 =C2=A03.230301] uhci_hcd 0000:00:1a.1: UHCI Host Controlle=
r
> > [ =C2=A0 =C2=A03.230323] uhci_hcd 0000:00:1a.1: new USB bus registe=
red, assigned
> > bus number 4
> > [ =C2=A0 =C2=A03.230400] uhci_hcd 0000:00:1a.1: irq 21, io base 0x0=
0006f80
> > [ =C2=A0 =C2=A03.230538] usb usb4: New USB device found, idVendor=3D=
1d6b, idProduct=3D0001
> > [ =C2=A0 =C2=A03.230541] usb usb4: New USB device strings: Mfr=3D3,=
 Product=3D2,
> > SerialNumber=3D1
> > [ =C2=A0 =C2=A03.230544] usb usb4: Product: UHCI Host Controller
> > [ =C2=A0 =C2=A03.230546] usb usb4: Manufacturer: Linux 2.6.32-mm1 u=
hci_hcd
> > [ =C2=A0 =C2=A03.230549] usb usb4: SerialNumber: 0000:00:1a.1
> > [ =C2=A0 =C2=A03.231135] hub 4-0:1.0: USB hub found
> > [ =C2=A0 =C2=A03.231150] hub 4-0:1.0: 2 ports detected
> > [ =C2=A0 =C2=A03.231310] uhci_hcd 0000:00:1a.2: PCI INT C -> GSI 22=
 (level, low) -> IRQ 22
> > [ =C2=A0 =C2=A03.231324] uhci_hcd 0000:00:1a.2: setting latency tim=
er to 64
> > [ =C2=A0 =C2=A03.231329] uhci_hcd 0000:00:1a.2: UHCI Host Controlle=
r
> > [ =C2=A0 =C2=A03.231346] uhci_hcd 0000:00:1a.2: new USB bus registe=
red, assigned
> > bus number 5
> > [ =C2=A0 =C2=A03.231393] uhci_hcd 0000:00:1a.2: irq 22, io base 0x0=
0006fa0
> > [ =C2=A0 =C2=A03.231521] usb usb5: New USB device found, idVendor=3D=
1d6b, idProduct=3D0001
> > [ =C2=A0 =C2=A03.231524] usb usb5: New USB device strings: Mfr=3D3,=
 Product=3D2,
> > SerialNumber=3D1
> > [ =C2=A0 =C2=A03.231526] usb usb5: Product: UHCI Host Controller
> > [ =C2=A0 =C2=A03.231529] usb usb5: Manufacturer: Linux 2.6.32-mm1 u=
hci_hcd
> > [ =C2=A0 =C2=A03.231531] usb usb5: SerialNumber: 0000:00:1a.2
> > [ =C2=A0 =C2=A03.232101] hub 5-0:1.0: USB hub found
> > [ =C2=A0 =C2=A03.232121] hub 5-0:1.0: 2 ports detected
> > [ =C2=A0 =C2=A03.232287] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 20=
 (level, low) -> IRQ 20
> > [ =C2=A0 =C2=A03.232302] uhci_hcd 0000:00:1d.0: setting latency tim=
er to 64
> > [ =C2=A0 =C2=A03.232306] uhci_hcd 0000:00:1d.0: UHCI Host Controlle=
r
> > [ =C2=A0 =C2=A03.232323] uhci_hcd 0000:00:1d.0: new USB bus registe=
red, assigned
> > bus number 6
> > [ =C2=A0 =C2=A03.232370] uhci_hcd 0000:00:1d.0: irq 20, io base 0x0=
0006f00
> > [ =C2=A0 =C2=A03.232504] usb usb6: New USB device found, idVendor=3D=
1d6b, idProduct=3D0001
> > [ =C2=A0 =C2=A03.232507] usb usb6: New USB device strings: Mfr=3D3,=
 Product=3D2,
> > SerialNumber=3D1
> > [ =C2=A0 =C2=A03.232510] usb usb6: Product: UHCI Host Controller
> > [ =C2=A0 =C2=A03.232512] usb usb6: Manufacturer: Linux 2.6.32-mm1 u=
hci_hcd
> > [ =C2=A0 =C2=A03.232514] usb usb6: SerialNumber: 0000:00:1d.0
> > [ =C2=A0 =C2=A03.233084] hub 6-0:1.0: USB hub found
> > [ =C2=A0 =C2=A03.233100] hub 6-0:1.0: 2 ports detected
> > [ =C2=A0 =C2=A03.233273] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 21=
 (level, low) -> IRQ 21
> > [ =C2=A0 =C2=A03.233287] uhci_hcd 0000:00:1d.1: setting latency tim=
er to 64
> > [ =C2=A0 =C2=A03.233292] uhci_hcd 0000:00:1d.1: UHCI Host Controlle=
r
> > [ =C2=A0 =C2=A03.233310] uhci_hcd 0000:00:1d.1: new USB bus registe=
red, assigned
> > bus number 7
> > [ =C2=A0 =C2=A03.233380] uhci_hcd 0000:00:1d.1: irq 21, io base 0x0=
0006f20
> > [ =C2=A0 =C2=A03.233513] usb usb7: New USB device found, idVendor=3D=
1d6b, idProduct=3D0001
> > [ =C2=A0 =C2=A03.233516] usb usb7: New USB device strings: Mfr=3D3,=
 Product=3D2,
> > SerialNumber=3D1
> > [ =C2=A0 =C2=A03.233518] usb usb7: Product: UHCI Host Controller
> > [ =C2=A0 =C2=A03.233521] usb usb7: Manufacturer: Linux 2.6.32-mm1 u=
hci_hcd
> > [ =C2=A0 =C2=A03.233523] usb usb7: SerialNumber: 0000:00:1d.1
> > [ =C2=A0 =C2=A03.234086] hub 7-0:1.0: USB hub found
> > [ =C2=A0 =C2=A03.234101] hub 7-0:1.0: 2 ports detected
> > [ =C2=A0 =C2=A03.234263] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 22=
 (level, low) -> IRQ 22
> > [ =C2=A0 =C2=A03.234277] uhci_hcd 0000:00:1d.2: setting latency tim=
er to 64
> > [ =C2=A0 =C2=A03.234282] uhci_hcd 0000:00:1d.2: UHCI Host Controlle=
r
> > [ =C2=A0 =C2=A03.234299] uhci_hcd 0000:00:1d.2: new USB bus registe=
red, assigned
> > bus number 8
> > [ =C2=A0 =C2=A03.234347] uhci_hcd 0000:00:1d.2: irq 22, io base 0x0=
0006f40
> > [ =C2=A0 =C2=A03.234480] usb usb8: New USB device found, idVendor=3D=
1d6b, idProduct=3D0001
> > [ =C2=A0 =C2=A03.234483] usb usb8: New USB device strings: Mfr=3D3,=
 Product=3D2,
> > SerialNumber=3D1
> > [ =C2=A0 =C2=A03.234486] usb usb8: Product: UHCI Host Controller
> > [ =C2=A0 =C2=A03.234488] usb usb8: Manufacturer: Linux 2.6.32-mm1 u=
hci_hcd
> > [ =C2=A0 =C2=A03.234490] usb usb8: SerialNumber: 0000:00:1d.2
> > [ =C2=A0 =C2=A03.235059] hub 8-0:1.0: USB hub found
> > [ =C2=A0 =C2=A03.235082] hub 8-0:1.0: 2 ports detected
> > [ =C2=A0 =C2=A03.235437] Initializing USB Mass Storage driver...
> > [ =C2=A0 =C2=A03.235668] usbcore: registered new interface driver u=
sb-storage
> > [ =C2=A0 =C2=A03.235673] USB Mass Storage support registered.
> > [ =C2=A0 =C2=A03.236109] usbcore: registered new interface driver l=
ibusual
> > [ =C2=A0 =C2=A03.236534] PNP: PS/2 Controller [PNP0303:KBC,PNP0f13:=
PS2M] at
> > 0x60,0x64 irq 1,12
> > [ =C2=A0 =C2=A03.237387] i8042.c: Warning: Keylock active.
> > [ =C2=A0 =C2=A03.240564] serio: i8042 KBD port at 0x60,0x64 irq 1
> > [ =C2=A0 =C2=A03.240605] serio: i8042 AUX port at 0x60,0x64 irq 12
> > [ =C2=A0 =C2=A03.241694] mice: PS/2 mouse device common for all mic=
e
> > [ =C2=A0 =C2=A03.243828] Driver 'rtc_cmos' needs updating - please =
use bus_type methods
> > [ =C2=A0 =C2=A03.243873] rtc_cmos 00:03: RTC can wake from S4
> > [ =C2=A0 =C2=A03.244268] rtc_cmos 00:03: rtc core: registered rtc_c=
mos as rtc0
> > [ =C2=A0 =C2=A03.244314] rtc0: alarms up to one month, y3k, 114 byt=
es nvram, hpet irqs
> > [ =C2=A0 =C2=A03.244498] i2c /dev entries driver
> > [ =C2=A0 =C2=A03.246702] i801_smbus 0000:00:1f.3: PCI INT B -> GSI =
19 (level,
> > low) -> IRQ 19
> > [ =C2=A0 =C2=A03.982537] ata2.00: configured for UDMA/100
> > [ =C2=A0 =C2=A03.983129] scsi 0:0:0:0: Direct-Access =C2=A0 =C2=A0 =
ATA =C2=A0 =C2=A0 =C2=A0ST9160310AS
> > =C2=A0DE04 PQ: 0 ANSI: 5
> > [ =C2=A0 =C2=A03.984407] i6300ESB timer: Intel 6300ESB WatchDog Tim=
er Driver v0.04
> > [ =C2=A0 =C2=A03.985019] sd 0:0:0:0: [sda] 312581808 512-byte logic=
al blocks:
> > (160 GB/149 GiB)
> > [ =C2=A0 =C2=A03.985213] sd 0:0:0:0: [sda] Write Protect is off
> > [ =C2=A0 =C2=A03.985217] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
> > [ =C2=A0 =C2=A03.985296] sd 0:0:0:0: [sda] Write cache: enabled, re=
ad cache:
> > enabled, doesn't support DPO or FUA
> > [ =C2=A0 =C2=A03.986007] =C2=A0sda:
> > [ =C2=A0 =C2=A03.987294] iTCO_wdt: Intel TCO WatchDog Timer Driver =
v1.05
> > [ =C2=A0 =C2=A03.987559] sd 0:0:0:0: Attached scsi generic sg0 type=
 0
> > [ =C2=A0 =C2=A03.988645] iTCO_wdt: Found a ICH9M TCO device (Versio=
n=3D2, TCOBASE=3D0x1060)
> > [ =C2=A0 =C2=A03.988921] iTCO_wdt: initialized. heartbeat=3D30 sec =
(nowayout=3D0)
> > [ =C2=A0 =C2=A03.988927] iTCO_vendor_support: vendor-support=3D0
> > [ =C2=A0 =C2=A04.103269] device-mapper: ioctl: 4.16.0-ioctl (2009-1=
1-05)
> > initialised: dm-devel@redhat.com
> > [ =C2=A0 =C2=A04.114089] device-mapper: dm-log-userspace: version 1=
=2E0.0 loaded
> > [ =C2=A0 =C2=A04.115717] scsi 1:0:0:0: CD-ROM =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0TSSTcorp DVD+-RW
> > TS-L633A D500 PQ: 0 ANSI: 5
> > [ =C2=A0 =C2=A04.136170] input: AT Translated Set 2 keyboard as
> > /devices/platform/i8042/serio0/input/input5
> > [ =C2=A0 =C2=A04.137513] cpuidle: using governor ladder
> > [ =C2=A0 =C2=A04.160918] cpuidle: using governor menu
> > [ =C2=A0 =C2=A04.172702] sdhci: Secure Digital Host Controller Inte=
rface driver
> > [ =C2=A0 =C2=A04.183721] sdhci: Copyright(c) Pierre Ossman
> > [ =C2=A0 =C2=A04.187247] sr0: scsi3-mmc drive: 24x/24x writer dvd-r=
am cd/rw
> > xa/form2 cdda tray
> > [ =C2=A0 =C2=A04.187251] Uniform CD-ROM driver Revision: 3.20
> > [ =C2=A0 =C2=A04.188050] sr 1:0:0:0: Attached scsi CD-ROM sr0
> > [ =C2=A0 =C2=A04.188595] sr 1:0:0:0: Attached scsi generic sg1 type=
 5
> > [ =C2=A0 =C2=A04.228490] dcdbas dcdbas: Dell Systems Management Bas=
e Driver
> > (version 5.6.0-3.2)
> > [ =C2=A0 =C2=A04.244671] =C2=A0sda1 sda2 sda3 sda4 <
> > [ =C2=A0 =C2=A04.246859] usbcore: registered new interface driver h=
iddev
> > [ =C2=A0 =C2=A04.269823] usbcore: registered new interface driver u=
sbhid
> > [ =C2=A0 =C2=A04.281086] usbhid: USB HID core driver
> > [ =C2=A0 =C2=A04.292291] =C2=A0sda5
> > [ =C2=A0 =C2=A04.292837] Advanced Linux Sound Architecture Driver V=
ersion 1.0.21.
> > [ =C2=A0 =C2=A04.314873] ALSA device list:
> > [ =C2=A0 =C2=A04.325942] =C2=A0 No soundcards found.
> > [ =C2=A0 =C2=A04.336996] Netfilter messages via NETLINK v0.30.
> > [ =C2=A0 =C2=A04.348290] =C2=A0sda6nf_conntrack version 0.5.0 (1533=
4 buckets, 61336 max)
> > [ =C2=A0 =C2=A04.360287] ctnetlink v0.93: registering with nfnetlin=
k.
> > [ =C2=A0 =C2=A04.374177] ip_tables: (C) 2000-2006 Netfilter Core Te=
am
> > [ =C2=A0 =C2=A04.385662] TCP cubic registered
> > [ =C2=A0 =C2=A04.396917] NET: Registered protocol family 17
> > [ =C2=A0 =C2=A04.408204] lib80211: common routines for IEEE802.11 d=
rivers
> > [ =C2=A0 =C2=A04.419455] lib80211_crypt: registered algorithm 'NULL=
'
> > [ =C2=A0 =C2=A04.421640] =C2=A0sda7
> > [ =C2=A0 =C2=A04.422604] Using IPI No-Shortcut mode
> > [ =C2=A0 =C2=A04.444566] =C2=A0sda8 >
> > [ =C2=A0 =C2=A04.457176] PM: Checking image partition /dev/sda8
> > [ =C2=A0 =C2=A04.457222] PM: Resume from partition 8:8
> > [ =C2=A0 =C2=A04.457225] PM: Checking hibernation image.
> > [ =C2=A0 =C2=A04.457992] PM: Error -22 checking image file
> > [ =C2=A0 =C2=A04.457994] PM: Resume from disk failed.
> > [ =C2=A0 =C2=A04.458061] registered taskstats version 1
> > [ =C2=A0 =C2=A04.460011] sd 0:0:0:0: [sda] Attached SCSI disk
> > [ =C2=A0 =C2=A04.481540] =C2=A0 Magic number: 5:855:537
> > [ =C2=A0 =C2=A04.492483] bdi 1:15: hash matches
> > [ =C2=A0 =C2=A04.503405] BIOS EDD facility v0.16 2004-Jun-25, 1 dev=
ices found
> > [ =C2=A0 =C2=A04.650495] input: PS/2 Mouse as /devices/platform/i80=
42/serio1/input/input6
> > [ =C2=A0 =C2=A04.692892] input: AlpsPS/2 ALPS GlidePoint as
> > /devices/platform/i8042/serio1/input/input7
> > [ =C2=A0 =C2=A04.720082] md: Waiting for all devices to be availabl=
e before autodetect
> > [ =C2=A0 =C2=A04.742549] md: If you don't use raid, use raid=3Dnoau=
todetect
> > [ =C2=A0 =C2=A04.767844] md: Autodetecting RAID arrays.
> > [ =C2=A0 =C2=A04.778687] md: Scanned 0 and added 0 devices.
> > [ =C2=A0 =C2=A04.789416] md: autorun ...
> > [ =C2=A0 =C2=A04.800012] md: ... autorun DONE.
> > [ =C2=A0 =C2=A05.003501] Clocksource tsc unstable (delta =3D -32160=
4132 ns)
> > [ =C2=A0 =C2=A05.079096] kjournald starting. =C2=A0Commit interval =
5 seconds
> > [ =C2=A0 =C2=A05.079824] EXT3-fs (sda2): mounted filesystem with wr=
iteback data mode
> > [ =C2=A0 =C2=A05.080120] VFS: Mounted root (ext3 filesystem) readon=
ly on device 8:2.
> > [ =C2=A0 =C2=A05.142808] Freeing unused kernel memory: 408k freed
> > [ =C2=A0 =C2=A05.165214] Write protecting the kernel text: 3908k
> > [ =C2=A0 =C2=A05.186530] async/1 used greatest stack depth: 6064 by=
tes left
> > [ =C2=A0 =C2=A05.196969] Write protecting the kernel read-only data=
: 2088k
> > [ =C2=A0 =C2=A06.333570] mount used greatest stack depth: 6040 byte=
s left
> > [ =C2=A0 =C2=A06.951249] udevd used greatest stack depth: 5952 byte=
s left
> > [ =C2=A0 =C2=A07.234948] modprobe used greatest stack depth: 5828 b=
ytes left
> > [ =C2=A0 =C2=A07.651236] cfg80211: Using static regulatory domain i=
nfo
> > [ =C2=A0 =C2=A07.661764] cfg80211: Regulatory domain: US
> > [ =C2=A0 =C2=A07.671985] =C2=A0 =C2=A0 (start_freq - end_freq @ ban=
dwidth),
> > (max_antenna_gain, max_eirp)
> > [ =C2=A0 =C2=A07.682267] =C2=A0 =C2=A0 (2402000 KHz - 2472000 KHz @=
 40000 KHz), (600 mBi, 2700 mBm)
> > [ =C2=A0 =C2=A07.692698] =C2=A0 =C2=A0 (5170000 KHz - 5190000 KHz @=
 40000 KHz), (600 mBi, 2300 mBm)
> > [ =C2=A0 =C2=A07.703043] =C2=A0 =C2=A0 (5190000 KHz - 5210000 KHz @=
 40000 KHz), (600 mBi, 2300 mBm)
> > [ =C2=A0 =C2=A07.713325] =C2=A0 =C2=A0 (5210000 KHz - 5230000 KHz @=
 40000 KHz), (600 mBi, 2300 mBm)
> > [ =C2=A0 =C2=A07.723694] =C2=A0 =C2=A0 (5230000 KHz - 5330000 KHz @=
 40000 KHz), (600 mBi, 2300 mBm)
> > [ =C2=A0 =C2=A07.733671] =C2=A0 =C2=A0 (5735000 KHz - 5835000 KHz @=
 40000 KHz), (600 mBi, 3000 mBm)
> > [ =C2=A0 =C2=A07.771924] sdhci-pci 0000:02:01.2: SDHCI controller f=
ound
> > [1180:0822] (rev 21)
> > [ =C2=A0 =C2=A07.781951] sdhci-pci 0000:02:01.2: PCI INT C -> GSI 1=
8 (level,
> > low) -> IRQ 18
> > [ =C2=A0 =C2=A07.794964] ACPI: WMI: Mapper loaded
> > [ =C2=A0 =C2=A07.879419] Registered led device: mmc0::
> > [ =C2=A0 =C2=A07.944622] mmc0: SDHCI controller on PCI [0000:02:01.=
2] using DMA
> > [ =C2=A0 =C2=A07.966785] mmc0: Minimum clock frequency too high for=
 identification mode
> > [ =C2=A0 =C2=A07.997256] ohci1394 0000:02:01.1: PCI INT B -> GSI 17=
 (level, low) -> IRQ 17
> > [ =C2=A0 =C2=A08.016459] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 2=
1 (level,
> > low) -> IRQ 21
> > [ =C2=A0 =C2=A08.036194] cfg80211: Calling CRDA for country: US
> > [ =C2=A0 =C2=A08.069726] ohci1394: fw-host0: OHCI-1394 1.1 (PCI): I=
RQ=3D[17]
> > MMIO=3D[f67ff800-f67fffff] =C2=A0Max Packet=3D[2048] =C2=A0IR/IT co=
ntexts=3D[4/4]
> > [ =C2=A0 =C2=A08.080275] HDA Intel 0000:00:1b.0: irq 28 for MSI/MSI=
-X
> > [ =C2=A0 =C2=A08.080357] HDA Intel 0000:00:1b.0: setting latency ti=
mer to 64
> > [ =C2=A0 =C2=A08.512355] input: Dell WMI hotkeys as /devices/virtua=
l/input/input8
> > [ =C2=A0 =C2=A09.389757] ieee1394: Host added: ID:BUS[0-00:1023] =C2=
=A0GUID[464fc0001679c05c]
> > [ =C2=A0 =C2=A09.532991] b43-phy0: Broadcom 4312 WLAN found (core r=
evision 15)
> > [ =C2=A0 =C2=A09.580380] b43-phy0 debug: Found PHY: Analog 6, Type =
5, Revision 1
> > [ =C2=A0 =C2=A09.580405] b43-phy0 debug: Found Radio: Manuf 0x17F, =
Version
> > 0x2062, Revision 2
> > [ =C2=A0 =C2=A09.604678] phy0: Selected rate control algorithm 'min=
strel'
> > [ =C2=A0 =C2=A09.608519] Registered led device: b43-phy0::tx
> > [ =C2=A0 =C2=A09.630314] Registered led device: b43-phy0::rx
> > [ =C2=A0 =C2=A09.651887] Registered led device: b43-phy0::radio
> > [ =C2=A0 =C2=A09.662725] Broadcom 43xx driver loaded [ Features: PL=
S, Firmware-ID: FW13 ]
> > [ =C2=A0 10.307938] Adding 2008084k swap on /dev/sda8. =C2=A0Priori=
ty:-1
> > extents:1 across:2008084k
> > [ =C2=A0 12.595365] EXT3-fs (sda2): using internal journal
> > [ =C2=A0 17.969618] kjournald starting. =C2=A0Commit interval 5 sec=
onds
> > [ =C2=A0 17.991570] EXT3-fs (sda3): using internal journal
> > [ =C2=A0 18.013380] EXT3-fs (sda3): mounted filesystem with writeba=
ck data mode
> > [ =C2=A0 18.237351] modprobe used greatest stack depth: 5816 bytes =
left
> > [ =C2=A0 18.299750] REISERFS (device sda5): found reiserfs format "=
3.6"
> > with standard journal
> > [ =C2=A0 18.322229] REISERFS warning (device sda5): =C2=A0reiserfs_=
fill_super:
> > CONFIG_REISERFS_CHECK is set ON
> > [ =C2=A0 18.344705] REISERFS warning (device sda5): =C2=A0reiserfs_=
fill_super: -
> > it is slow mode for debugging.
> > [ =C2=A0 18.366916] REISERFS (device sda5): using ordered data mode
> > [ =C2=A0 18.402628] REISERFS (device sda5): journal params: device =
sda5,
> > size 8192, journal first block 18, max trans len 1024, max batch 90=
0,
> > max commit age 30, max trans age 30
> > [ =C2=A0 18.425822] REISERFS (device sda5): checking transaction lo=
g (sda5)
> > [ =C2=A0 18.437324] REISERFS debug (device sda5): journal-1153: fou=
nd in
> > header: first_unflushed_offset 1203, last_flushed_trans_id 124057
> > [ =C2=A0 18.441500] REISERFS debug (device sda5): journal-1006: fou=
nd valid
> > transaction start offset 4294968499, len 121333 id 4096
> > [ =C2=A0 18.441510] REISERFS debug (device sda5): journal-1206: Sta=
rting
> > replay from offset 532825052808371, trans_id 2823643143
> > [ =C2=A0 18.441519] REISERFS debug (device sda5): journal-1037:
> > journal_read_transaction, offset 4294968499, len 359 mount_id
> > -1471324153
> > [ =C2=A0 18.441527] REISERFS debug (device sda5): journal-1039:
> > journal_read_trans skipping because 1203 is too old
> > [ =C2=A0 18.441534] REISERFS debug (device sda5): journal-1299: Set=
ting
> > newest_mount_id to 457
> > [ =C2=A0 18.465006] REISERFS (device sda5): Using r5 hash to sort n=
ames
> > [ =C2=A0 18.517772] mount used greatest stack depth: 5740 bytes lef=
t
> > [ =C2=A0 19.151072] rc.S used greatest stack depth: 5424 bytes left
> > [ =C2=A0 27.284345] smbd used greatest stack depth: 5296 bytes left
> > [ =C2=A0224.256014] PM: Syncing filesystems ... done.
> > [ =C2=A0224.295550] PM: Preparing system for mem sleep
> > [ =C2=A0224.295734] Freezing user space processes ... (elapsed 0.01=
 seconds) done.
> > [ =C2=A0224.306948] Freezing remaining freezable tasks ... (elapsed=
 0.01
> > seconds) done.
> > [ =C2=A0224.320225] PM: Entering mem sleep
> > [ =C2=A0224.320350] Suspending console(s) (use no_console_suspend t=
o debug)
> > [ =C2=A0224.335095] sd 0:0:0:0: [sda] Synchronizing SCSI cache
> > [ =C2=A0224.538141] sd 0:0:0:0: [sda] Stopping disk
> > [ =C2=A0225.379324] ACPI handle has no context!
> > [ =C2=A0225.379364] sdhci-pci 0000:02:01.2: PCI INT C disabled
> > [ =C2=A0225.379374] ACPI handle has no context!
> > [ =C2=A0225.395501] ACPI handle has no context!
> > [ =C2=A0225.407487] b43-pci-bridge 0000:0c:00.0: PCI INT A disabled
> > [ =C2=A0225.420718] ata_piix 0000:00:1f.5: PCI INT D disabled
> > [ =C2=A0225.433838] ata_piix 0000:00:1f.2: PCI INT D disabled
> > [ =C2=A0225.446992] ehci_hcd 0000:00:1d.7: PCI INT A disabled
> > [ =C2=A0225.447061] uhci_hcd 0000:00:1d.2: PCI INT C disabled
> > [ =C2=A0225.447076] uhci_hcd 0000:00:1d.1: PCI INT B disabled
> > [ =C2=A0225.447090] uhci_hcd 0000:00:1d.0: PCI INT A disabled
> > [ =C2=A0225.653729] HDA Intel 0000:00:1b.0: PCI INT A disabled
> > [ =C2=A0225.666930] ehci_hcd 0000:00:1a.7: PCI INT C disabled
> > [ =C2=A0225.666952] uhci_hcd 0000:00:1a.2: PCI INT C disabled
> > [ =C2=A0225.666974] uhci_hcd 0000:00:1a.1: PCI INT B disabled
> > [ =C2=A0225.667001] uhci_hcd 0000:00:1a.0: PCI INT A disabled
> > [ =C2=A0225.680708] render error detected, EIR: 0x00000010
> > [ =C2=A0225.680711] =C2=A0 IPEIR: 0x00000000
> > [ =C2=A0225.680714] =C2=A0 IPEHR: 0x01000000
> > [ =C2=A0225.680716] =C2=A0 INSTDONE: 0xfffffffe
> > [ =C2=A0225.680718] =C2=A0 INSTPS: 0x0001e000
> > [ =C2=A0225.680720] =C2=A0 INSTDONE1: 0xffffffff
> > [ =C2=A0225.680722] =C2=A0 ACTHD: 0x02000018
> > [ =C2=A0225.680725] page table error
> > [ =C2=A0225.680727] =C2=A0 PGTBL_ER: 0x00100000
> > [ =C2=A0225.680731] [drm:i915_handle_error] *ERROR* EIR stuck: 0x00=
000010, masking
> > [ =C2=A0225.731462] ACPI: Preparing to enter system sleep state S3
> > [ =C2=A0225.754167] Disabling non-boot CPUs ...
> > [ =C2=A0225.809478] CPU 1 is now offline
> > [ =C2=A0225.809481] lockdep: fixing up alternatives.
> > [ =C2=A0225.809487] SMP alternatives: switching to UP code
> > [ =C2=A0225.816500] Extended CMOS year: 2000
> > [ =C2=A0225.816500] Back to C!
> > [ =C2=A0225.816500] Extended CMOS year: 2000
> > [ =C2=A0225.816720] Enabling non-boot CPUs ...
> > [ =C2=A0225.818422] lockdep: fixing up alternatives.
> > [ =C2=A0225.818425] SMP alternatives: switching to SMP code
> > [ =C2=A0225.822188] Booting processor 1 APIC 0x1 ip 0x6000
> > [ =C2=A0225.818021] Initializing CPU#1
> > [ =C2=A0225.818021] CPU: Physical Processor ID: 0
> > [ =C2=A0225.818021] CPU: Processor Core ID: 1
> > [ =C2=A0225.913392] CPU1: Intel(R) Core(TM)2 Duo CPU =C2=A0 =C2=A0 =
T7250 =C2=A0@ 2.00GHz stepping 0d
> > [ =C2=A0225.937046] microcode: CPU1 sig=3D0x6fd, pf=3D0x80, revisio=
n=3D0xa3
> > [ =C2=A0225.937053] platform microcode: firmware: requesting intel-=
ucode/06-0f-0d
> > [ =C2=A0225.937179] firmware microcode: parent microcode should not=
 be sleeping
> > [ =C2=A0285.940840] CPU1 is up
> > [ =C2=A0285.941309] ACPI: Waking up from system sleep state S3
> > [ =C2=A0285.991446] i915 0000:00:02.0: restoring config space at of=
fset 0xf
> > (was 0x100, writing 0x10b)
> > [ =C2=A0285.991465] i915 0000:00:02.0: restoring config space at of=
fset 0x8
> > (was 0x1, writing 0xefe9)
> > [ =C2=A0285.991474] i915 0000:00:02.0: restoring config space at of=
fset 0x6
> > (was 0xc, writing 0xe000000c)
> > [ =C2=A0285.991488] i915 0000:00:02.0: restoring config space at of=
fset 0x1
> > (was 0x900007, writing 0x900407)
> > [ =C2=A0285.991554] pci 0000:00:02.1: restoring config space at off=
set 0x4
> > (was 0x4, writing 0xf6b00004)
> > [ =C2=A0285.991564] pci 0000:00:02.1: restoring config space at off=
set 0x1
> > (was 0x900000, writing 0x900007)
> > [ =C2=A0285.991594] uhci_hcd 0000:00:1a.0: restoring config space a=
t offset
> > 0xf (was 0x100, writing 0x10a)
> > [ =C2=A0285.991618] uhci_hcd 0000:00:1a.0: restoring config space a=
t offset
> > 0x8 (was 0x1, writing 0x6f61)
> > [ =C2=A0285.991643] uhci_hcd 0000:00:1a.0: restoring config space a=
t offset
> > 0x1 (was 0x2900000, writing 0x2900001)
> > [ =C2=A0285.991678] uhci_hcd 0000:00:1a.1: restoring config space a=
t offset
> > 0xf (was 0x200, writing 0x207)
> > [ =C2=A0285.991703] uhci_hcd 0000:00:1a.1: restoring config space a=
t offset
> > 0x8 (was 0x1, writing 0x6f81)
> > [ =C2=A0285.991727] uhci_hcd 0000:00:1a.1: restoring config space a=
t offset
> > 0x1 (was 0x2900000, writing 0x2900001)
> > [ =C2=A0285.991762] uhci_hcd 0000:00:1a.2: restoring config space a=
t offset
> > 0xf (was 0x300, writing 0x305)
> > [ =C2=A0285.991786] uhci_hcd 0000:00:1a.2: restoring config space a=
t offset
> > 0x8 (was 0x1, writing 0x6fa1)
> > [ =C2=A0285.991811] uhci_hcd 0000:00:1a.2: restoring config space a=
t offset
> > 0x1 (was 0x2900000, writing 0x2900001)
> > [ =C2=A0285.991895] ehci_hcd 0000:00:1a.7: restoring config space a=
t offset
> > 0x1 (was 0x2900106, writing 0x2900102)
> > [ =C2=A0285.991956] HDA Intel 0000:00:1b.0: restoring config space =
at
> > offset 0xf (was 0x100, writing 0x107)
> > [ =C2=A0285.991991] HDA Intel 0000:00:1b.0: restoring config space =
at
> > offset 0x4 (was 0xfebfc004, writing 0xf6afc004)
> > [ =C2=A0285.992000] HDA Intel 0000:00:1b.0: restoring config space =
at
> > offset 0x3 (was 0x0, writing 0x10)
> > [ =C2=A0285.992011] HDA Intel 0000:00:1b.0: restoring config space =
at
> > offset 0x1 (was 0x100000, writing 0x100102)
> > [ =C2=A0285.992068] pcieport 0000:00:1c.0: restoring config space a=
t offset
> > 0xf (was 0x100, writing 0x20100)
> > [ =C2=A0285.992090] pcieport 0000:00:1c.0: restoring config space a=
t offset
> > 0x9 (was 0x10001, writing 0x44314421)
> > [ =C2=A0285.992098] pcieport 0000:00:1c.0: restoring config space a=
t offset
> > 0x8 (was 0x0, writing 0x44104400)
> > [ =C2=A0285.992107] pcieport 0000:00:1c.0: restoring config space a=
t offset
> > 0x7 (was 0x20000000, writing 0x2020)
> > [ =C2=A0285.992115] pcieport 0000:00:1c.0: restoring config space a=
t offset
> > 0x6 (was 0x0, writing 0xb0b00)
> > [ =C2=A0285.992129] pcieport 0000:00:1c.0: restoring config space a=
t offset
> > 0x3 (was 0x810000, writing 0x810010)
> > [ =C2=A0285.992140] pcieport 0000:00:1c.0: restoring config space a=
t offset
> > 0x1 (was 0x100000, writing 0x100507)
> > [ =C2=A0285.992227] pcieport 0000:00:1c.1: restoring config space a=
t offset
> > 0xf (was 0x200, writing 0x20200)
> > [ =C2=A0285.992249] pcieport 0000:00:1c.1: restoring config space a=
t offset
> > 0x9 (was 0x10001, writing 0x44514441)
> > [ =C2=A0285.992257] pcieport 0000:00:1c.1: restoring config space a=
t offset
> > 0x8 (was 0x0, writing 0xf690f690)
> > [ =C2=A0285.992266] pcieport 0000:00:1c.1: restoring config space a=
t offset
> > 0x7 (was 0x20000000, writing 0x3030)
> > [ =C2=A0285.992275] pcieport 0000:00:1c.1: restoring config space a=
t offset
> > 0x6 (was 0x0, writing 0xc0c00)
> > [ =C2=A0285.992289] pcieport 0000:00:1c.1: restoring config space a=
t offset
> > 0x3 (was 0x810000, writing 0x810010)
> > [ =C2=A0285.992300] pcieport 0000:00:1c.1: restoring config space a=
t offset
> > 0x1 (was 0x100000, writing 0x100507)
> > [ =C2=A0285.992386] pcieport 0000:00:1c.4: restoring config space a=
t offset
> > 0xf (was 0x100, writing 0x20100)
> > [ =C2=A0285.992408] pcieport 0000:00:1c.4: restoring config space a=
t offset
> > 0x9 (was 0x10001, writing 0x44714461)
> > [ =C2=A0285.992417] pcieport 0000:00:1c.4: restoring config space a=
t offset
> > 0x8 (was 0x0, writing 0xf680f680)
> > [ =C2=A0285.992425] pcieport 0000:00:1c.4: restoring config space a=
t offset
> > 0x7 (was 0x20000000, writing 0x4040)
> > [ =C2=A0285.992434] pcieport 0000:00:1c.4: restoring config space a=
t offset
> > 0x6 (was 0x0, writing 0x90900)
> > [ =C2=A0285.992448] pcieport 0000:00:1c.4: restoring config space a=
t offset
> > 0x3 (was 0x810000, writing 0x810010)
> > [ =C2=A0285.992459] pcieport 0000:00:1c.4: restoring config space a=
t offset
> > 0x1 (was 0x100000, writing 0x100407)
> > [ =C2=A0285.992571] uhci_hcd 0000:00:1d.0: restoring config space a=
t offset
> > 0x1 (was 0x2900005, writing 0x2900001)
> > [ =C2=A0285.992606] uhci_hcd 0000:00:1d.1: restoring config space a=
t offset
> > 0xf (was 0x200, writing 0x207)
> > [ =C2=A0285.992630] uhci_hcd 0000:00:1d.1: restoring config space a=
t offset
> > 0x8 (was 0x1, writing 0x6f21)
> > [ =C2=A0285.992655] uhci_hcd 0000:00:1d.1: restoring config space a=
t offset
> > 0x1 (was 0x2900000, writing 0x2900001)
> > [ =C2=A0285.992689] uhci_hcd 0000:00:1d.2: restoring config space a=
t offset
> > 0xf (was 0x300, writing 0x305)
> > [ =C2=A0285.992714] uhci_hcd 0000:00:1d.2: restoring config space a=
t offset
> > 0x8 (was 0x1, writing 0x6f41)
> > [ =C2=A0285.992738] uhci_hcd 0000:00:1d.2: restoring config space a=
t offset
> > 0x1 (was 0x2900000, writing 0x2900001)
> > [ =C2=A0285.992823] ehci_hcd 0000:00:1d.7: restoring config space a=
t offset
> > 0x1 (was 0x2900106, writing 0x2900102)
> > [ =C2=A0285.992883] pci 0000:00:1e.0: restoring config space at off=
set 0x9
> > (was 0x1fff1, writing 0x43f14001)
> > [ =C2=A0285.992895] pci 0000:00:1e.0: restoring config space at off=
set 0x7
> > (was 0x2280e0f0, writing 0x22805050)
> > [ =C2=A0285.992903] pci 0000:00:1e.0: restoring config space at off=
set 0x6
> > (was 0x20020200, writing 0x20030200)
> > [ =C2=A0285.992997] pci 0000:00:1f.0: restoring config space at off=
set 0x1
> > (was 0x2100007, writing 0x2100107)
> > [ =C2=A0285.993041] ata_piix 0000:00:1f.2: restoring config space a=
t offset
> > 0xf (was 0x400, writing 0x40a)
> > [ =C2=A0285.993109] i801_smbus 0000:00:1f.3: restoring config space=
 at
> > offset 0xf (was 0x200, writing 0x204)
> > [ =C2=A0285.993144] i801_smbus 0000:00:1f.3: restoring config space=
 at
> > offset 0x4 (was 0x4, writing 0xf6afbf04)
> > [ =C2=A0285.993159] i801_smbus 0000:00:1f.3: restoring config space=
 at
> > offset 0x1 (was 0x2800001, writing 0x2800103)
> > [ =C2=A0285.993192] ata_piix 0000:00:1f.5: restoring config space a=
t offset
> > 0xf (was 0x400, writing 0x40a)
> > [ =C2=A0285.993214] ata_piix 0000:00:1f.5: restoring config space a=
t offset
> > 0x9 (was 0x1, writing 0xeff1)
> > [ =C2=A0285.993241] ata_piix 0000:00:1f.5: restoring config space a=
t offset
> > 0x1 (was 0x2b00000, writing 0x2b00007)
> > [ =C2=A0285.993557] b43-pci-bridge 0000:0c:00.0: restoring config s=
pace at
> > offset 0xf (was 0x100, writing 0x104)
> > [ =C2=A0285.993632] b43-pci-bridge 0000:0c:00.0: restoring config s=
pace at
> > offset 0x4 (was 0x4, writing 0xf69fc004)
> > [ =C2=A0285.993648] b43-pci-bridge 0000:0c:00.0: restoring config s=
pace at
> > offset 0x3 (was 0x0, writing 0x10)
> > [ =C2=A0285.993669] b43-pci-bridge 0000:0c:00.0: restoring config s=
pace at
> > offset 0x1 (was 0x100000, writing 0x100106)
> > [ =C2=A0285.993877] tg3 0000:09:00.0: restoring config space at off=
set 0x3
> > (was 0x0, writing 0x10)
> > [ =C2=A0285.993890] tg3 0000:09:00.0: restoring config space at off=
set 0x1
> > (was 0x100000, writing 0x100106)
> > [ =C2=A0285.993958] pci 0000:02:01.0: restoring config space at off=
set 0xf
> > (was 0x7000100, writing 0x700010a)
> > [ =C2=A0285.993966] pci 0000:02:01.0: restoring config space at off=
set 0xe
> > (was 0x0, writing 0x51fc)
> > [ =C2=A0285.993975] pci 0000:02:01.0: restoring config space at off=
set 0xd
> > (was 0x0, writing 0x5100)
> > [ =C2=A0285.993983] pci 0000:02:01.0: restoring config space at off=
set 0xc
> > (was 0x0, writing 0x50fc)
> > [ =C2=A0285.993992] pci 0000:02:01.0: restoring config space at off=
set 0xb
> > (was 0x0, writing 0x5000)
> > [ =C2=A0285.994000] pci 0000:02:01.0: restoring config space at off=
set 0xa
> > (was 0x0, writing 0x4bfff000)
> > [ =C2=A0285.994009] pci 0000:02:01.0: restoring config space at off=
set 0x9
> > (was 0x0, writing 0x48000000)
> > [ =C2=A0285.994017] pci 0000:02:01.0: restoring config space at off=
set 0x8
> > (was 0x0, writing 0x43fff000)
> > [ =C2=A0285.994026] pci 0000:02:01.0: restoring config space at off=
set 0x7
> > (was 0x0, writing 0x40000000)
> > [ =C2=A0285.994035] pci 0000:02:01.0: restoring config space at off=
set 0x6
> > (was 0x0, writing 0xb0060302)
> > [ =C2=A0285.994046] pci 0000:02:01.0: restoring config space at off=
set 0x4
> > (was 0x0, writing 0xf6700000)
> > [ =C2=A0285.994054] pci 0000:02:01.0: restoring config space at off=
set 0x3
> > (was 0x820000, writing 0x824000)
> > [ =C2=A0285.994066] pci 0000:02:01.0: restoring config space at off=
set 0x1
> > (was 0x2100000, writing 0x2100107)
> > [ =C2=A0285.994106] ohci1394 0000:02:01.1: restoring config space a=
t offset
> > 0xf (was 0x4020200, writing 0x4020204)
> > [ =C2=A0285.994146] ohci1394 0000:02:01.1: restoring config space a=
t offset
> > 0x3 (was 0x800000, writing 0x804010)
> > [ =C2=A0285.994159] ohci1394 0000:02:01.1: restoring config space a=
t offset
> > 0x1 (was 0x2100000, writing 0x2100106)
> > [ =C2=A0285.994197] sdhci-pci 0000:02:01.2: restoring config space =
at
> > offset 0xf (was 0x300, writing 0x303)
> > [ =C2=A0285.994232] sdhci-pci 0000:02:01.2: restoring config space =
at
> > offset 0x4 (was 0x0, writing 0xf67ff700)
> > [ =C2=A0285.994241] sdhci-pci 0000:02:01.2: restoring config space =
at
> > offset 0x3 (was 0x800000, writing 0x804010)
> > [ =C2=A0285.994253] sdhci-pci 0000:02:01.2: restoring config space =
at
> > offset 0x1 (was 0x2100000, writing 0x2100106)
> > [ =C2=A0286.009482] PM: Device PNP0C0D:00 failed to resume: error 1
> > [ =C2=A0286.039022] dell-wmi: Unknown key e044 pressed
> > [ =C2=A0286.151069] i915 0000:00:02.0: setting latency timer to 64
> > [ =C2=A0286.243570] [drm] LVDS-8: set mode 1280x800 c
> > [ =C2=A0286.290393] uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 20 (lev=
el, low) -> IRQ 20
> > [ =C2=A0286.290404] uhci_hcd 0000:00:1a.0: setting latency timer to=
 64
> > [ =C2=A0286.290441] usb usb3: root hub lost power or was reset
> > [ =C2=A0286.290466] uhci_hcd 0000:00:1a.1: PCI INT B -> GSI 21 (lev=
el, low) -> IRQ 21
> > [ =C2=A0286.290475] uhci_hcd 0000:00:1a.1: setting latency timer to=
 64
> > [ =C2=A0286.290505] usb usb4: root hub lost power or was reset
> > [ =C2=A0286.290527] uhci_hcd 0000:00:1a.2: PCI INT C -> GSI 22 (lev=
el, low) -> IRQ 22
> > [ =C2=A0286.290537] uhci_hcd 0000:00:1a.2: setting latency timer to=
 64
> > [ =C2=A0286.290565] usb usb5: root hub lost power or was reset
> > [ =C2=A0286.290588] ehci_hcd 0000:00:1a.7: PCI INT C -> GSI 22 (lev=
el, low) -> IRQ 22
> > [ =C2=A0286.290598] ehci_hcd 0000:00:1a.7: setting latency timer to=
 64
> > [ =C2=A0286.290613] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 21 (le=
vel,
> > low) -> IRQ 21
> > [ =C2=A0286.290623] HDA Intel 0000:00:1b.0: setting latency timer t=
o 64
> > [ =C2=A0286.290689] HDA Intel 0000:00:1b.0: irq 28 for MSI/MSI-X
> > [ =C2=A0286.290764] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 20 (lev=
el, low) -> IRQ 20
> > [ =C2=A0286.290773] uhci_hcd 0000:00:1d.0: setting latency timer to=
 64
> > [ =C2=A0286.290801] usb usb6: root hub lost power or was reset
> > [ =C2=A0286.290846] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 21 (lev=
el, low) -> IRQ 21
> > [ =C2=A0286.290856] uhci_hcd 0000:00:1d.1: setting latency timer to=
 64
> > [ =C2=A0286.290887] usb usb7: root hub lost power or was reset
> > [ =C2=A0286.290911] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 22 (lev=
el, low) -> IRQ 22
> > [ =C2=A0286.290921] uhci_hcd 0000:00:1d.2: setting latency timer to=
 64
> > [ =C2=A0286.290950] usb usb8: root hub lost power or was reset
> > [ =C2=A0286.290972] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 20 (lev=
el, low) -> IRQ 20
> > [ =C2=A0286.290982] ehci_hcd 0000:00:1d.7: setting latency timer to=
 64
> > [ =C2=A0286.291001] pci 0000:00:1e.0: setting latency timer to 64
> > [ =C2=A0286.291018] ata_piix 0000:00:1f.2: PCI INT D -> GSI 19 (lev=
el, low) -> IRQ 19
> > [ =C2=A0286.291025] ata_piix 0000:00:1f.2: setting latency timer to=
 64
> > [ =C2=A0286.291110] ata_piix 0000:00:1f.5: PCI INT D -> GSI 19 (lev=
el, low) -> IRQ 19
> > [ =C2=A0286.291119] ata_piix 0000:00:1f.5: setting latency timer to=
 64
> > [ =C2=A0286.291394] b43-pci-bridge 0000:0c:00.0: PCI INT A -> GSI 1=
7
> > (level, low) -> IRQ 17
> > [ =C2=A0286.307121] pci 0000:02:01.0: PCI INT A -> GSI 19 (level, l=
ow) -> IRQ 19
> > [ =C2=A0286.362261] ohci1394: fw-host0: OHCI-1394 1.1 (PCI): IRQ=3D=
[17]
> > MMIO=3D[f67ff800-f67fffff] =C2=A0Max Packet=3D[2048] =C2=A0IR/IT co=
ntexts=3D[4/4]
> > [ =C2=A0286.368333] sdhci-pci 0000:02:01.2: PCI INT C -> GSI 18 (le=
vel,
> > low) -> IRQ 18
> > [ =C2=A0286.383529] mmc0: Minimum clock frequency too high for iden=
tification mode
> > [ =C2=A0286.423034] sd 0:0:0:0: [sda] Starting disk
> > [ =C2=A0286.621595] ata3: SATA link down (SStatus 0 SControl 300)
> > [ =C2=A0286.632845] ata4: SATA link down (SStatus 4 SControl 300)
> > [ =C2=A0286.763599] ata1: SATA link up 3.0 Gbps (SStatus 123 SContr=
ol 300)
> > [ =C2=A0286.763812] ata2: SATA link up 1.5 Gbps (SStatus 113 SContr=
ol 300)
> > [ =C2=A0286.823841] ata2.00: configured for UDMA/100
> > [ =C2=A0287.027642] ata1.00: configured for UDMA/133
> > [ =C2=A0287.095609] PM: Finishing wakeup.
> > [ =C2=A0287.095611] Restarting tasks ... done.
> > [ =C2=A0457.056279] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0457.249535] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0457.423506] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0457.608626] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0457.788025] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0457.947402] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0460.438540] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0475.910065] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0476.103445] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0477.844084] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0478.093328] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0478.950676] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0479.229816] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0479.459126] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0479.658534] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0480.525933] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0480.748745] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0480.944699] dell-wmi: Unknown key 48 pressed
> > [ =C2=A0549.103799] b43 ssb0:0: firmware: requesting b43/ucode15.fw
> > [ =C2=A0549.215863] b43 ssb0:0: firmware: requesting b43/lp0initval=
s15.fw
> > [ =C2=A0549.244516] b43 ssb0:0: firmware: requesting b43/lp0bsinitv=
als15.fw
> > [ =C2=A0549.403735] b43-phy0: Loading firmware version 410.2160 (20=
07-05-26 15:32:10)
> > [ =C2=A0549.406244] b43-phy0 debug: b2062: Using crystal tab entry =
19200 kHz.
> > [ =C2=A0553.990808] b43-phy0 debug: Chip initialized
> > [ =C2=A0553.991181] b43-phy0 debug: PIO initialized
> > [ =C2=A0553.991297] b43-phy0 debug: QoS enabled
> > [ =C2=A0554.010624] b43-phy0 debug: Wireless interface started
> > [ =C2=A0554.018136] b43-phy0 debug: Adding Interface type 2
> > [ =C2=A0555.225635] wlan0: direct probe to AP 00:02:2d:08:51:2b (tr=
y 1)
> > [ =C2=A0555.227406] wlan0: direct probe to AP 00:02:2d:08:51:2b (tr=
y 1)
> > [ =C2=A0555.247446] wlan0: direct probe responded
> > [ =C2=A0555.247504] wlan0: authenticate with AP 00:02:2d:08:51:2b (=
try 1)
> > [ =C2=A0555.275021] wlan0: authenticated
> > [ =C2=A0555.275905] wlan0: associate with AP 00:02:2d:08:51:2b (try=
 1)
> > [ =C2=A0555.284599] wlan0: RX AssocResp from 00:02:2d:08:51:2b (cap=
ab=3D0x1
> > status=3D0 aid=3D12)
> > [ =C2=A0555.284608] wlan0: associated
> > [ =C2=A0561.323866] mtrr: type mismatch for e0000000,10000000 old:
> > write-back new: write-combining
> > [ 2688.500033] No probe response from AP 00:02:2d:08:51:2b after
> > 500ms, disconnecting.
> > [ 2689.580376] wlan0: direct probe to AP 00:02:2d:08:51:2b (try 1)
> > [ 2689.780643] wlan0: direct probe to AP 00:02:2d:08:51:2b (try 2)
> > [ 2689.798772] wlan0: direct probe responded
> > [ 2689.798778] wlan0: authenticate with AP 00:02:2d:08:51:2b (try 1=
)
> > [ 2689.986996] wlan0: authenticated
> > [ 2689.987691] wlan0: associate with AP 00:02:2d:08:51:2b (try 1)
> > [ 2690.006697] wlan0: RX ReassocResp from 00:02:2d:08:51:2b (capab=3D=
0x1
> > status=3D0 aid=3D1)
> > [ 2690.006706] wlan0: associated
> >
> > --
> > Regards
> > dave
> >
>=20
>=20
>=20
> --=20
> Regards
> dave
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
