From: Adrian George Sav <adi_sav@yahoo.com>
Subject: Re: Kernel driver r8169 not working for Realtek 8111E onboard network card
Date: Mon, 24 Oct 2011 11:54:04 -0700 (PDT)
Message-ID: <1319482444.38178.YahooMailNeo@web161917.mail.bf1.yahoo.com>
References: <1319296941.68390.YahooMailNeo@web161905.mail.bf1.yahoo.com> <20111022214443.GA21689@electric-eye.fr.zoreil.com>
Reply-To: Adrian George Sav <adi_sav@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm35-vm7.bullet.mail.bf1.yahoo.com ([72.30.238.79]:33234 "HELO
	nm35-vm7.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751358Ab1JXSyG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Oct 2011 14:54:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you for your answer.

I don't know what you mean by "current -rc", the release candidate vers=
ion of the kernel or maybe of the driver?
I guess it's the driver's version you're recommending, but I can't find=
 a rc version of the driver anywhere on the net.

Trying to solve this, I installed the latest version of ubuntu, because=
 I saw it has a new kernel, 3.0.0.12, but no improvement.

Then I went to Realtek site to download driver version 6.015.00 (http:/=
/www.realtek.com/downloads/downloadsView.aspx?Langid=3D1&PNid=3D4&PFid=3D=
4&Level=3D5&Conn=3D4&DownTypeID=3D3&GetDown=3Dfalse&Downloads=3Dtrue) :

LINUX driver for kernel 2.6.x and 2.4.X (support x86 and x64)
6.015.00
2011/6/29
30k=20

I followed the instructions to compile and install and there were no er=
rors.

The new driver has the same manifestation, often not working at all, or=
 working at very low speeds.


I provide below the output of the commands uname -a, modinfo,=A0 dmesg,=
 AFTER installation of version 6.015.00 of driver and reboot:


#uname -a

Linux admin-pc 3.0.0-12-generic #20-Ubuntu SMP Fri Oct 7 14:50:42 UTC 2=
011 i686 i686 i386 GNU/Linux


# modinfo r8169

filename:=A0=A0=A0=A0=A0=A0 /lib/modules/3.0.0-12-generic/kernel/driver=
s/net/r8169.ko
firmware:=A0=A0=A0=A0=A0=A0 rtl_nic/rtl8105e-1.fw
firmware:=A0=A0=A0=A0=A0=A0 rtl_nic/rtl8168e-2.fw
firmware:=A0=A0=A0=A0=A0=A0 rtl_nic/rtl8168e-1.fw
firmware:=A0=A0=A0=A0=A0=A0 rtl_nic/rtl8168d-2.fw
firmware:=A0=A0=A0=A0=A0=A0 rtl_nic/rtl8168d-1.fw
version:=A0=A0=A0=A0=A0=A0=A0 2.3LK-NAPI
license:=A0=A0=A0=A0=A0=A0=A0 GPL
description:=A0=A0=A0 RealTek RTL-8169 Gigabit Ethernet driver
author:=A0=A0=A0=A0=A0=A0=A0=A0 Realtek and the Linux r8169 crew <netde=
v@vger.kernel.org>
srcversion:=A0=A0=A0=A0 91BDC1109C31F7EEF7E9783
alias:=A0=A0=A0=A0=A0=A0=A0=A0=A0 pci:v00000001d00008168sv*sd00002410bc=
*sc*i*
alias:=A0=A0=A0=A0=A0=A0=A0=A0=A0 pci:v00001737d00001032sv*sd00000024bc=
*sc*i*
alias:=A0=A0=A0=A0=A0=A0=A0=A0=A0 pci:v000016ECd00000116sv*sd*bc*sc*i*
alias:=A0=A0=A0=A0=A0=A0=A0=A0=A0 pci:v00001259d0000C107sv*sd*bc*sc*i*
alias:=A0=A0=A0=A0=A0=A0=A0=A0=A0 pci:v00001186d00004302sv*sd*bc*sc*i*
alias:=A0=A0=A0=A0=A0=A0=A0=A0=A0 pci:v00001186d00004300sv*sd*bc*sc*i*
alias:=A0=A0=A0=A0=A0=A0=A0=A0=A0 pci:v000010ECd00008169sv*sd*bc*sc*i*
alias:=A0=A0=A0=A0=A0=A0=A0=A0=A0 pci:v000010ECd00008168sv*sd*bc*sc*i*
alias:=A0=A0=A0=A0=A0=A0=A0=A0=A0 pci:v000010ECd00008167sv*sd*bc*sc*i*
alias:=A0=A0=A0=A0=A0=A0=A0=A0=A0 pci:v000010ECd00008136sv*sd*bc*sc*i*
alias:=A0=A0=A0=A0=A0=A0=A0=A0=A0 pci:v000010ECd00008129sv*sd*bc*sc*i*
depends:=A0=A0=A0=A0=A0=A0=A0=20
vermagic:=A0=A0=A0=A0=A0=A0 3.0.0-12-generic SMP mod_unload modversions=
 686=20
parm:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 use_dac:Enable PCI DAC. Unsafe on 3=
2 bit PCI slot. (int)
parm:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 debug:Debug verbosity level (0=3Dno=
ne, ..., 16=3Dall) (int)



# dmesg

[=A0=A0=A0 0.000000] Initializing cgroup subsys cpuset
[=A0=A0=A0 0.000000] Initializing cgroup subsys cpu
[=A0=A0=A0 0.000000] Linux version 3.0.0-12-generic (buildd@vernadsky) =
(gcc version 4.6.1 (Ubuntu/Linaro 4.6.1-9ubuntu3) ) #20-Ubuntu SMP Fri =
Oct 7 14:50:42 UTC 2011 (Ubuntu 3.0.0-12.20-generic 3.0.4)
[=A0=A0=A0 0.000000] KERNEL supported cpus:
[=A0=A0=A0 0.000000]=A0=A0 Intel GenuineIntel
[=A0=A0=A0 0.000000]=A0=A0 AMD AuthenticAMD
[=A0=A0=A0 0.000000]=A0=A0 NSC Geode by NSC
[=A0=A0=A0 0.000000]=A0=A0 Cyrix CyrixInstead
[=A0=A0=A0 0.000000]=A0=A0 Centaur CentaurHauls
[=A0=A0=A0 0.000000]=A0=A0 Transmeta GenuineTMx86
[=A0=A0=A0 0.000000]=A0=A0 Transmeta TransmetaCPU
[=A0=A0=A0 0.000000]=A0=A0 UMC UMC UMC UMC
[=A0=A0=A0 0.000000] BIOS-provided physical RAM map:
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 0000000000000000 - 000000000009d800 =
(usable)
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 000000000009d800 - 00000000000a0000 =
(reserved)
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 00000000000e0000 - 0000000000100000 =
(reserved)
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 0000000000100000 - 00000000bef9c000 =
(usable)
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 00000000bef9c000 - 00000000beff5000 =
(ACPI NVS)
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 00000000beff5000 - 00000000bf59d000 =
(reserved)
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 00000000bf59d000 - 00000000bf5ae000 =
(ACPI NVS)
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 00000000bf5ae000 - 00000000bf5c5000 =
(reserved)
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 00000000bf5c5000 - 00000000bf5c7000 =
(usable)
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 00000000bf5c7000 - 00000000bf5c8000 =
(ACPI NVS)
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 00000000bf5c8000 - 00000000bf5d0000 =
(reserved)
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 00000000bf5d0000 - 00000000bf5da000 =
(ACPI NVS)
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 00000000bf5da000 - 00000000bf636000 =
(reserved)
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 00000000bf636000 - 00000000bf679000 =
(ACPI NVS)
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 00000000bf679000 - 00000000bf800000 =
(usable)
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 00000000fed1c000 - 00000000fed20000 =
(reserved)
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 00000000ff000000 - 0000000100000000 =
(reserved)
[=A0=A0=A0 0.000000]=A0 BIOS-e820: 0000000100000000 - 000000043f800000 =
(usable)
[=A0=A0=A0 0.000000] Notice: NX (Execute Disable) protection cannot be =
enabled in hardware: non-PAE kernel!
[=A0=A0=A0 0.000000] NX (Execute Disable) protection: approximated by x=
86 segment limits
[=A0=A0=A0 0.000000] DMI 2.6 present.
[=A0=A0=A0 0.000000] DMI: System manufacturer System Product Name/P8P67=
 REV 3.1, BIOS 1704 06/08/2011
[=A0=A0=A0 0.000000] e820 update range: 0000000000000000 - 000000000001=
0000 (usable) =3D=3D> (reserved)
[=A0=A0=A0 0.000000] e820 remove range: 00000000000a0000 - 000000000010=
0000 (usable)
[=A0=A0=A0 0.000000] last_pfn =3D 0xbf800 max_arch_pfn =3D 0x100000
[=A0=A0=A0 0.000000] MTRR default type: uncachable
[=A0=A0=A0 0.000000] MTRR fixed ranges enabled:
[=A0=A0=A0 0.000000]=A0=A0 00000-9FFFF write-back
[=A0=A0=A0 0.000000]=A0=A0 A0000-BFFFF uncachable
[=A0=A0=A0 0.000000]=A0=A0 C0000-CFFFF write-protect
[=A0=A0=A0 0.000000]=A0=A0 D0000-E7FFF uncachable
[=A0=A0=A0 0.000000]=A0=A0 E8000-FFFFF write-protect
[=A0=A0=A0 0.000000] MTRR variable ranges enabled:
[=A0=A0=A0 0.000000]=A0=A0 0 base 000000000 mask C00000000 write-back
[=A0=A0=A0 0.000000]=A0=A0 1 base 400000000 mask FC0000000 write-back
[=A0=A0=A0 0.000000]=A0=A0 2 base 0C0000000 mask FC0000000 uncachable
[=A0=A0=A0 0.000000]=A0=A0 3 base 43F800000 mask FFF800000 uncachable
[=A0=A0=A0 0.000000]=A0=A0 4 disabled
[=A0=A0=A0 0.000000]=A0=A0 5 disabled
[=A0=A0=A0 0.000000]=A0=A0 6 disabled
[=A0=A0=A0 0.000000]=A0=A0 7 disabled
[=A0=A0=A0 0.000000]=A0=A0 8 disabled
[=A0=A0=A0 0.000000]=A0=A0 9 disabled
[=A0=A0=A0 0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0=
x7010600070106
[=A0=A0=A0 0.000000] original variable MTRRs
[=A0=A0=A0 0.000000] reg 0, base: 0GB, range: 16GB, type WB
[=A0=A0=A0 0.000000] reg 1, base: 16GB, range: 1GB, type WB
[=A0=A0=A0 0.000000] reg 2, base: 3GB, range: 1GB, type UC
[=A0=A0=A0 0.000000] reg 3, base: 17400MB, range: 8MB, type UC
[=A0=A0=A0 0.000000] total RAM covered: 16376M
[=A0=A0=A0 0.000000] Found optimal setting for mtrr clean up
[=A0=A0=A0 0.000000]=A0 gran_size: 64K =A0=A0=A0 chunk_size: 16M =A0=A0=
=A0 num_reg: 6=A0 =A0=A0=A0 lose cover RAM: 0G
[=A0=A0=A0 0.000000] New variable MTRRs
[=A0=A0=A0 0.000000] reg 0, base: 0GB, range: 2GB, type WB
[=A0=A0=A0 0.000000] reg 1, base: 2GB, range: 1GB, type WB
[=A0=A0=A0 0.000000] reg 2, base: 4GB, range: 4GB, type WB
[=A0=A0=A0 0.000000] reg 3, base: 8GB, range: 8GB, type WB
[=A0=A0=A0 0.000000] reg 4, base: 16GB, range: 1GB, type WB
[=A0=A0=A0 0.000000] reg 5, base: 17400MB, range: 8MB, type UC
[=A0=A0=A0 0.000000] e820 update range: 00000000c0000000 - 000000010000=
0000 (usable) =3D=3D> (reserved)
[=A0=A0=A0 0.000000] found SMP MP-table at [c00fcf00] fcf00
[=A0=A0=A0 0.000000] initial memory mapped : 0 - 01c00000
[=A0=A0=A0 0.000000] Base memory trampoline at [c0099000] 99000 size 16=
384
[=A0=A0=A0 0.000000] init_memory_mapping: 0000000000000000-00000000377f=
e000
[=A0=A0=A0 0.000000]=A0 0000000000 - 0000400000 page 4k
[=A0=A0=A0 0.000000]=A0 0000400000 - 0037400000 page 2M
[=A0=A0=A0 0.000000]=A0 0037400000 - 00377fe000 page 4k
[=A0=A0=A0 0.000000] kernel direct mapping tables up to 377fe000 @ 1bfb=
000-1c00000
[=A0=A0=A0 0.000000] RAMDISK: 365f2000 - 372f1000
[=A0=A0=A0 0.000000] ACPI: RSDP 000f0420 00024 (v02 ALASKA)
[=A0=A0=A0 0.000000] ACPI: XSDT befec068 0004C (v01 ALASKA=A0=A0=A0 A M=
 I 01072009 AMI=A0 00010013)
[=A0=A0=A0 0.000000] ACPI: FACP beff4210 000F4 (v04 ALASKA=A0=A0=A0 A M=
 I 01072009 AMI=A0 00010013)
[=A0=A0=A0 0.000000] ACPI: DSDT befec140 080D0 (v02 ALASKA=A0=A0=A0 A M=
 I 00000000 INTL 20051117)
[=A0=A0=A0 0.000000] ACPI: FACS bf5d1f80 00040
[=A0=A0=A0 0.000000] ACPI: APIC beff4308 00092 (v03 ALASKA=A0=A0=A0 A M=
 I 01072009 AMI=A0 00010013)
[=A0=A0=A0 0.000000] ACPI: SSDT beff43a0 001D6 (v01 AMICPU=A0=A0=A0=A0 =
PROC 00000001 MSFT 03000001)
[=A0=A0=A0 0.000000] ACPI: MCFG beff4578 0003C (v01 ALASKA=A0=A0=A0 A M=
 I 01072009 MSFT 00000097)
[=A0=A0=A0 0.000000] ACPI: HPET beff45b8 00038 (v01 ALASKA=A0=A0=A0 A M=
 I 01072009 AMI. 00000004)
[=A0=A0=A0 0.000000] ACPI: Local APIC address 0xfee00000
[=A0=A0=A0 0.000000] 2176MB HIGHMEM available.
[=A0=A0=A0 0.000000] 887MB LOWMEM available.
[=A0=A0=A0 0.000000]=A0=A0 mapped low ram: 0 - 377fe000
[=A0=A0=A0 0.000000]=A0=A0 low ram: 0 - 377fe000
[=A0=A0=A0 0.000000] Zone PFN ranges:
[=A0=A0=A0 0.000000]=A0=A0 DMA=A0=A0=A0=A0=A0 0x00000010 -> 0x00001000
[=A0=A0=A0 0.000000]=A0=A0 Normal=A0=A0 0x00001000 -> 0x000377fe
[=A0=A0=A0 0.000000]=A0=A0 HighMem=A0 0x000377fe -> 0x000bf800
[=A0=A0=A0 0.000000] Movable zone start PFN for each node
[=A0=A0=A0 0.000000] early_node_map[4] active PFN ranges
[=A0=A0=A0 0.000000]=A0=A0=A0=A0 0: 0x00000010 -> 0x0000009d
[=A0=A0=A0 0.000000]=A0=A0=A0=A0 0: 0x00000100 -> 0x000bef9c
[=A0=A0=A0 0.000000]=A0=A0=A0=A0 0: 0x000bf5c5 -> 0x000bf5c7
[=A0=A0=A0 0.000000]=A0=A0=A0=A0 0: 0x000bf679 -> 0x000bf800
[=A0=A0=A0 0.000000] On node 0 totalpages: 782514
[=A0=A0=A0 0.000000] free_area_init_node: node 0, pgdat c17b11c0, node_=
mem_map f4e02200
[=A0=A0=A0 0.000000]=A0=A0 DMA zone: 32 pages used for memmap
[=A0=A0=A0 0.000000]=A0=A0 DMA zone: 0 pages reserved
[=A0=A0=A0 0.000000]=A0=A0 DMA zone: 3949 pages, LIFO batch:0
[=A0=A0=A0 0.000000]=A0=A0 Normal zone: 1744 pages used for memmap
[=A0=A0=A0 0.000000]=A0=A0 Normal zone: 221486 pages, LIFO batch:31
[=A0=A0=A0 0.000000]=A0=A0 HighMem zone: 4353 pages used for memmap
[=A0=A0=A0 0.000000]=A0=A0 HighMem zone: 550950 pages, LIFO batch:31
[=A0=A0=A0 0.000000] Using APIC driver default
[=A0=A0=A0 0.000000] ACPI: PM-Timer IO Port: 0x408
[=A0=A0=A0 0.000000] ACPI: Local APIC address 0xfee00000
[=A0=A0=A0 0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[=A0=A0=A0 0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[=A0=A0=A0 0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x04] enabled)
[=A0=A0=A0 0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x06] enabled)
[=A0=A0=A0 0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x01] enabled)
[=A0=A0=A0 0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x03] enabled)
[=A0=A0=A0 0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x05] enabled)
[=A0=A0=A0 0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x07] enabled)
[=A0=A0=A0 0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1]=
)
[=A0=A0=A0 0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_bas=
e[0])
[=A0=A0=A0 0.000000] IOAPIC[0]: apic_id 0, version 32, address 0xfec000=
00, GSI 0-23
[=A0=A0=A0 0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 df=
l dfl)
[=A0=A0=A0 0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 hi=
gh level)
[=A0=A0=A0 0.000000] ACPI: IRQ0 used by override.
[=A0=A0=A0 0.000000] ACPI: IRQ2 used by override.
[=A0=A0=A0 0.000000] ACPI: IRQ9 used by override.
[=A0=A0=A0 0.000000] Using ACPI (MADT) for SMP configuration informatio=
n
[=A0=A0=A0 0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[=A0=A0=A0 0.000000] SMP: Allowing 8 CPUs, 0 hotplug CPUs
[=A0=A0=A0 0.000000] nr_irqs_gsi: 40
[=A0=A0=A0 0.000000] PM: Registered nosave memory: 000000000009d000 - 0=
00000000009e000
[=A0=A0=A0 0.000000] PM: Registered nosave memory: 000000000009e000 - 0=
0000000000a0000
[=A0=A0=A0 0.000000] PM: Registered nosave memory: 00000000000a0000 - 0=
0000000000e0000
[=A0=A0=A0 0.000000] PM: Registered nosave memory: 00000000000e0000 - 0=
000000000100000
[=A0=A0=A0 0.000000] Allocating PCI resources starting at bf800000 (gap=
: bf800000:3f51c000)
[=A0=A0=A0 0.000000] Booting paravirtualized kernel on bare hardware
[=A0=A0=A0 0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_i=
ds:8 nr_node_ids:1
[=A0=A0=A0 0.000000] PERCPU: Embedded 12 pages/cpu @f4800000 s26240 r0 =
d22912 u524288
[=A0=A0=A0 0.000000] pcpu-alloc: s26240 r0 d22912 u524288 alloc=3D1*419=
4304
[=A0=A0=A0 0.000000] pcpu-alloc: [0] 0 1 2 3 4 5 6 7=20
[=A0=A0=A0 0.000000] Built 1 zonelists in Zone order, mobility grouping=
 on.=A0 Total pages: 776385
[=A0=A0=A0 0.000000] Kernel command line: BOOT_IMAGE=3D/boot/vmlinuz-3.=
0.0-12-generic root=3DUUID=3D3d6fa566-5eda-4460-adea-0845bf58b022 ro qu=
iet splash vt.handoff=3D7
[=A0=A0=A0 0.000000] PID hash table entries: 4096 (order: 2, 16384 byte=
s)
[=A0=A0=A0 0.000000] Dentry cache hash table entries: 131072 (order: 7,=
 524288 bytes)
[=A0=A0=A0 0.000000] Inode-cache hash table entries: 65536 (order: 6, 2=
62144 bytes)
[=A0=A0=A0 0.000000] Initializing CPU#0
[=A0=A0=A0 0.000000] xsave/xrstor: enabled xstate_bv 0x7, cntxt size 0x=
340
[=A0=A0=A0 0.000000] allocated 12549888 bytes of page_cgroup
[=A0=A0=A0 0.000000] please try 'cgroup_disable=3Dmemory' option if you=
 don't want memory cgroups
[=A0=A0=A0 0.000000] Initializing HighMem for node 0 (000377fe:000bf800=
)
[=A0=A0=A0 0.000000] Memory: 3069188k/3137536k available (5329k kernel =
code, 60868k reserved, 2589k data, 696k init, 2221212k highmem)
[=A0=A0=A0 0.000000] virtual kernel memory layout:
[=A0=A0=A0 0.000000]=A0=A0=A0=A0 fixmap=A0 : 0xfff16000 - 0xfffff000=A0=
=A0 ( 932 kB)
[=A0=A0=A0 0.000000]=A0=A0=A0=A0 pkmap=A0=A0 : 0xff800000 - 0xffc00000=A0=
=A0 (4096 kB)
[=A0=A0=A0 0.000000]=A0=A0=A0=A0 vmalloc : 0xf7ffe000 - 0xff7fe000=A0=A0=
 ( 120 MB)
[=A0=A0=A0 0.000000]=A0=A0=A0=A0 lowmem=A0 : 0xc0000000 - 0xf77fe000=A0=
=A0 ( 887 MB)
[=A0=A0=A0 0.000000]=A0=A0=A0=A0=A0=A0 .init : 0xc17bc000 - 0xc186a000=A0=
=A0 ( 696 kB)
[=A0=A0=A0 0.000000]=A0=A0=A0=A0=A0=A0 .data : 0xc1534784 - 0xc17bbd80=A0=
=A0 (2589 kB)
[=A0=A0=A0 0.000000]=A0=A0=A0=A0=A0=A0 .text : 0xc1000000 - 0xc1534784=A0=
=A0 (5329 kB)
[=A0=A0=A0 0.000000] Checking if this processor honours the WP bit even=
 in supervisor mode...Ok.
[=A0=A0=A0 0.000000] SLUB: Genslabs=3D15, HWalign=3D64, Order=3D0-3, Mi=
nObjects=3D0, CPUs=3D8, Nodes=3D1
[=A0=A0=A0 0.000000] Hierarchical RCU implementation.
[=A0=A0=A0 0.000000] =A0=A0=A0 RCU dyntick-idle grace-period accelerati=
on is enabled.
[=A0=A0=A0 0.000000] NR_IRQS:2304 nr_irqs:744 16
[=A0=A0=A0 0.000000] CPU 0 irqstacks, hard=3Df380a000 soft=3Df380c000
[=A0=A0=A0 0.000000] Extended CMOS year: 2000
[=A0=A0=A0 0.000000] vt handoff: transparent VT on vt#7
[=A0=A0=A0 0.000000] Console: colour dummy device 80x25
[=A0=A0=A0 0.000000] console [tty0] enabled
[=A0=A0=A0 0.000000] hpet clockevent registered
[=A0=A0=A0 0.000000] Fast TSC calibration using PIT
[=A0=A0=A0 0.004000] Detected 3411.019 MHz processor.
[=A0=A0=A0 0.000001] Calibrating delay loop (skipped), value calculated=
 using timer frequency.. 6822.03 BogoMIPS (lpj=3D13644076)
[=A0=A0=A0 0.000004] pid_max: default: 32768 minimum: 301
[=A0=A0=A0 0.000017] Security Framework initialized
[=A0=A0=A0 0.000025] AppArmor: AppArmor initialized
[=A0=A0=A0 0.000026] Yama: becoming mindful.
[=A0=A0=A0 0.000055] Mount-cache hash table entries: 512
[=A0=A0=A0 0.000126] Initializing cgroup subsys cpuacct
[=A0=A0=A0 0.000129] Initializing cgroup subsys memory
[=A0=A0=A0 0.000134] Initializing cgroup subsys devices
[=A0=A0=A0 0.000135] Initializing cgroup subsys freezer
[=A0=A0=A0 0.000136] Initializing cgroup subsys net_cls
[=A0=A0=A0 0.000137] Initializing cgroup subsys blkio
[=A0=A0=A0 0.000141] Initializing cgroup subsys perf_event
[=A0=A0=A0 0.000159] CPU: Physical Processor ID: 0
[=A0=A0=A0 0.000160] CPU: Processor Core ID: 0
[=A0=A0=A0 0.000163] ENERGY_PERF_BIAS: Set to 'normal', was 'performanc=
e'
[=A0=A0=A0 0.000164] ENERGY_PERF_BIAS: View and update with x86_energy_=
perf_policy(8)
[=A0=A0=A0 0.000175] mce: CPU supports 9 MCE banks
[=A0=A0=A0 0.000185] CPU0: Thermal monitoring enabled (TM1)
[=A0=A0=A0 0.000190] using mwait in idle threads.
[=A0=A0=A0 0.001621] ACPI: Core revision 20110413
[=A0=A0=A0 0.105973] ftrace: allocating 24885 entries in 49 pages
[=A0=A0=A0 0.112194] Enabling APIC mode:=A0 Flat.=A0 Using 1 I/O APICs
[=A0=A0=A0 0.112526] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D=
-1 pin2=3D-1
[=A0=A0=A0 0.152182] CPU0: Intel(R) Core(TM) i7-2600 CPU @ 3.40GHz step=
ping 07
[=A0=A0=A0 0.260000] Performance Events: PEBS fmt1+, SandyBridge events=
, Intel PMU driver.
[=A0=A0=A0 0.260004] ... version:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 3
[=A0=A0=A0 0.260005] ... bit width:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 48
[=A0=A0=A0 0.260006] ... generic registers:=A0=A0=A0=A0=A0 4
[=A0=A0=A0 0.260007] ... value mask:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
 0000ffffffffffff
[=A0=A0=A0 0.260008] ... max period:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
 000000007fffffff
[=A0=A0=A0 0.260008] ... fixed-purpose events:=A0=A0 3
[=A0=A0=A0 0.260009] ... event mask:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
 000000070000000f
[=A0=A0=A0 0.260226] CPU 1 irqstacks, hard=3Df38d6000 soft=3Df38e0000
[=A0=A0=A0 0.260227] Booting Node=A0=A0 0, Processors=A0 #1
[=A0=A0=A0 0.260229] smpboot cpu 1: start_ip =3D 99000
[=A0=A0=A0 0.270588] Initializing CPU#1
[=A0=A0=A0 0.283983] calibrate_delay_direct() ignoring timer_rate as we=
 had a TSC wrap around start=3D4269382184 >=3Dpost_end=3D1703168
[=A0=A0=A0 0.368045] CPU 2 irqstacks, hard=3Df38ea000 soft=3Df38ec000
[=A0=A0=A0 0.368046]=A0 #2
[=A0=A0=A0 0.368047] smpboot cpu 2: start_ip =3D 99000
[=A0=A0=A0 0.378312] Initializing CPU#2
[=A0=A0=A0 0.475960] CPU 3 irqstacks, hard=3Df38f6000 soft=3Df38f8000
[=A0=A0=A0 0.475961]=A0 #3
[=A0=A0=A0 0.475962] smpboot cpu 3: start_ip =3D 99000
[=A0=A0=A0 0.486228] Initializing CPU#3
[=A0=A0=A0 0.583873] CPU 4 irqstacks, hard=3Df390a000 soft=3Df390c000
[=A0=A0=A0 0.583875]=A0 #4
[=A0=A0=A0 0.583875] smpboot cpu 4: start_ip =3D 99000
[=A0=A0=A0 0.594198] Initializing CPU#4
[=A0=A0=A0 0.691861] CPU 5 irqstacks, hard=3Df392a000 soft=3Df392c000
[=A0=A0=A0 0.691862]=A0 #5
[=A0=A0=A0 0.691863] smpboot cpu 5: start_ip =3D 99000
[=A0=A0=A0 0.702030] Initializing CPU#5
[=A0=A0=A0 0.799777] CPU 6 irqstacks, hard=3Df3956000 soft=3Df3960000
[=A0=A0=A0 0.799779]=A0 #6
[=A0=A0=A0 0.799779] smpboot cpu 6: start_ip =3D 99000
[=A0=A0=A0 0.810044] Initializing CPU#6
[=A0=A0=A0 0.907693] CPU 7 irqstacks, hard=3Df396a000 soft=3Df396c000
[=A0=A0=A0 0.907694]=A0 #7 Ok.
[=A0=A0=A0 0.907695] smpboot cpu 7: start_ip =3D 99000
[=A0=A0=A0 0.917960] Initializing CPU#7
[=A0=A0=A0 1.015562] Brought up 8 CPUs
[=A0=A0=A0 1.015563] Total of 8 processors activated (54576.52 BogoMIPS=
).
[=A0=A0=A0 1.020365] devtmpfs: initialized
[=A0=A0=A0 1.020452] PM: Registering ACPI NVS region at bef9c000 (36454=
4 bytes)
[=A0=A0=A0 1.020459] PM: Registering ACPI NVS region at bf59d000 (69632=
 bytes)
[=A0=A0=A0 1.020460] PM: Registering ACPI NVS region at bf5c7000 (4096 =
bytes)
[=A0=A0=A0 1.020462] PM: Registering ACPI NVS region at bf5d0000 (40960=
 bytes)
[=A0=A0=A0 1.020463] PM: Registering ACPI NVS region at bf636000 (27443=
2 bytes)
[=A0=A0=A0 1.021523] print_constraints: dummy:=20
[=A0=A0=A0 1.021547] Time: 21:17:58=A0 Date: 10/24/11
[=A0=A0=A0 1.021571] NET: Registered protocol family 16
[=A0=A0=A0 1.021631] Trying to unpack rootfs image as initramfs...
[=A0=A0=A0 1.021634] EISA bus registered
[=A0=A0=A0 1.021638] ACPI: bus type pci registered
[=A0=A0=A0 1.021675] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem =
0xe0000000-0xe3ffffff] (base 0xe0000000)
[=A0=A0=A0 1.021677] PCI: not using MMCONFIG
[=A0=A0=A0 1.034073] PCI: Using configuration type 1 for base access
[=A0=A0=A0 1.034571] bio: create slab <bio-0> at 0
[=A0=A0=A0 1.035382] ACPI: EC: Look up EC in DSDT
[=A0=A0=A0 1.036111] ACPI: Executed 1 blocks of module-level executable=
 AML code
[=A0=A0=A0 1.037747] ACPI Error: [RAMB] Namespace lookup failure, AE_NO=
T_FOUND (20110413/psargs-359)
[=A0=A0=A0 1.037751] ACPI Exception: AE_NOT_FOUND, Could not execute ar=
guments for [RAMW] (Region) (20110413/nsinit-349)
[=A0=A0=A0 1.037931] ACPI: SSDT bf5d0818 0079C (v01=A0=A0=A0 AMI=A0=A0=A0=
=A0=A0 IST 00000001 MSFT 03000001)
[=A0=A0=A0 1.038219] ACPI: Dynamic OEM Table Load:
[=A0=A0=A0 1.038220] ACPI: SSDT=A0=A0 (null) 0079C (v01=A0=A0=A0 AMI=A0=
=A0=A0=A0=A0 IST 00000001 MSFT 03000001)
[=A0=A0=A0 1.038245] ACPI: SSDT bf5d7a18 0021C (v01=A0=A0=A0 AMI=A0=A0=A0=
=A0=A0 CST 00000001 MSFT 03000001)
[=A0=A0=A0 1.038459] ACPI: Dynamic OEM Table Load:
[=A0=A0=A0 1.038460] ACPI: SSDT=A0=A0 (null) 0021C (v01=A0=A0=A0 AMI=A0=
=A0=A0=A0=A0 CST 00000001 MSFT 03000001)
[=A0=A0=A0 1.039001] ACPI: Interpreter enabled
[=A0=A0=A0 1.039005] ACPI: (supports S0 S1 S3 S4 S5)
[=A0=A0=A0 1.039018] ACPI: Using IOAPIC for interrupt routing
[=A0=A0=A0 1.039032] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem =
0xe0000000-0xe3ffffff] (base 0xe0000000)
[=A0=A0=A0 1.039072] PCI: MMCONFIG at [mem 0xe0000000-0xe3ffffff] reser=
ved in ACPI motherboard resources
[=A0=A0=A0 1.039073] PCI: Using MMCONFIG for extended config space
[=A0=A0=A0 1.039276] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignor=
ed
[=A0=A0=A0 1.042432] ACPI: EC: GPE =3D 0x18, I/O: command/status =3D 0x=
66, data =3D 0x62
[=A0=A0=A0 1.042529] ACPI: No dock devices found.
[=A0=A0=A0 1.042530] HEST: Table not found.
[=A0=A0=A0 1.042533] PCI: Using host bridge windows from ACPI; if neces=
sary, use "pci=3Dnocrs" and report a bug
[=A0=A0=A0 1.042652] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-=
ff])
[=A0=A0=A0 1.042784] pci_root PNP0A08:00: host bridge window [io=A0 0x0=
000-0x0cf7]
[=A0=A0=A0 1.042786] pci_root PNP0A08:00: host bridge window [io=A0 0x0=
d00-0xffff]
[=A0=A0=A0 1.042787] pci_root PNP0A08:00: host bridge window [mem 0x000=
a0000-0x000bffff]
[=A0=A0=A0 1.042789] pci_root PNP0A08:00: host bridge window [mem 0x000=
c8000-0x000dffff]
[=A0=A0=A0 1.042790] pci_root PNP0A08:00: host bridge window [mem 0xc00=
00000-0xffffffff]
[=A0=A0=A0 1.042793] pci_root PNP0A08:00: address space collision: host=
 bridge window [mem 0x000c8000-0x000dffff] conflicts with Video ROM [me=
m 0x000c0000-0x000cd1ff]
[=A0=A0=A0 1.042800] pci 0000:00:00.0: [8086:0100] type 0 class 0x00060=
0
[=A0=A0=A0 1.042826] pci 0000:00:01.0: [8086:0101] type 1 class 0x00060=
4
[=A0=A0=A0 1.042845] pci 0000:00:01.0: PME# supported from D0 D3hot D3c=
old
[=A0=A0=A0 1.042847] pci 0000:00:01.0: PME# disabled
[=A0=A0=A0 1.042886] pci 0000:00:16.0: [8086:1c3a] type 0 class 0x00078=
0
[=A0=A0=A0 1.042908] pci 0000:00:16.0: reg 10: [mem 0xfb408000-0xfb4080=
0f 64bit]
[=A0=A0=A0 1.042965] pci 0000:00:16.0: PME# supported from D0 D3hot D3c=
old
[=A0=A0=A0 1.042969] pci 0000:00:16.0: PME# disabled
[=A0=A0=A0 1.042998] pci 0000:00:1a.0: [8086:1c2d] type 0 class 0x000c0=
3
[=A0=A0=A0 1.043018] pci 0000:00:1a.0: reg 10: [mem 0xfb407000-0xfb4073=
ff]
[=A0=A0=A0 1.043088] pci 0000:00:1a.0: PME# supported from D0 D3hot D3c=
old
[=A0=A0=A0 1.043092] pci 0000:00:1a.0: PME# disabled
[=A0=A0=A0 1.043114] pci 0000:00:1b.0: [8086:1c20] type 0 class 0x00040=
3
[=A0=A0=A0 1.043128] pci 0000:00:1b.0: reg 10: [mem 0xfb400000-0xfb403f=
ff 64bit]
[=A0=A0=A0 1.043180] pci 0000:00:1b.0: PME# supported from D0 D3hot D3c=
old
[=A0=A0=A0 1.043183] pci 0000:00:1b.0: PME# disabled
[=A0=A0=A0 1.043201] pci 0000:00:1c.0: [8086:1c10] type 1 class 0x00060=
4
[=A0=A0=A0 1.043260] pci 0000:00:1c.0: PME# supported from D0 D3hot D3c=
old
[=A0=A0=A0 1.043264] pci 0000:00:1c.0: PME# disabled
[=A0=A0=A0 1.043284] pci 0000:00:1c.1: [8086:1c12] type 1 class 0x00060=
4
[=A0=A0=A0 1.043343] pci 0000:00:1c.1: PME# supported from D0 D3hot D3c=
old
[=A0=A0=A0 1.043347] pci 0000:00:1c.1: PME# disabled
[=A0=A0=A0 1.043367] pci 0000:00:1c.2: [8086:1c14] type 1 class 0x00060=
4
[=A0=A0=A0 1.043426] pci 0000:00:1c.2: PME# supported from D0 D3hot D3c=
old
[=A0=A0=A0 1.043430] pci 0000:00:1c.2: PME# disabled
[=A0=A0=A0 1.043450] pci 0000:00:1c.3: [8086:1c16] type 1 class 0x00060=
4
[=A0=A0=A0 1.043514] pci 0000:00:1c.3: PME# supported from D0 D3hot D3c=
old
[=A0=A0=A0 1.043517] pci 0000:00:1c.3: PME# disabled
[=A0=A0=A0 1.043538] pci 0000:00:1c.4: [8086:1c18] type 1 class 0x00060=
4
[=A0=A0=A0 1.043597] pci 0000:00:1c.4: PME# supported from D0 D3hot D3c=
old
[=A0=A0=A0 1.043601] pci 0000:00:1c.4: PME# disabled
[=A0=A0=A0 1.043622] pci 0000:00:1c.5: [8086:1c1a] type 1 class 0x00060=
4
[=A0=A0=A0 1.043680] pci 0000:00:1c.5: PME# supported from D0 D3hot D3c=
old
[=A0=A0=A0 1.043684] pci 0000:00:1c.5: PME# disabled
[=A0=A0=A0 1.043704] pci 0000:00:1c.6: [8086:244e] type 1 class 0x00060=
4
[=A0=A0=A0 1.043763] pci 0000:00:1c.6: PME# supported from D0 D3hot D3c=
old
[=A0=A0=A0 1.043767] pci 0000:00:1c.6: PME# disabled
[=A0=A0=A0 1.043786] pci 0000:00:1c.7: [8086:1c1e] type 1 class 0x00060=
4
[=A0=A0=A0 1.043845] pci 0000:00:1c.7: PME# supported from D0 D3hot D3c=
old
[=A0=A0=A0 1.043849] pci 0000:00:1c.7: PME# disabled
[=A0=A0=A0 1.043874] pci 0000:00:1d.0: [8086:1c26] type 0 class 0x000c0=
3
[=A0=A0=A0 1.043894] pci 0000:00:1d.0: reg 10: [mem 0xfb406000-0xfb4063=
ff]
[=A0=A0=A0 1.043964] pci 0000:00:1d.0: PME# supported from D0 D3hot D3c=
old
[=A0=A0=A0 1.043968] pci 0000:00:1d.0: PME# disabled
[=A0=A0=A0 1.043989] pci 0000:00:1f.0: [8086:1c46] type 0 class 0x00060=
1
[=A0=A0=A0 1.044097] pci 0000:00:1f.2: [8086:1c02] type 0 class 0x00010=
6
[=A0=A0=A0 1.044114] pci 0000:00:1f.2: reg 10: [io=A0 0xf070-0xf077]
[=A0=A0=A0 1.044121] pci 0000:00:1f.2: reg 14: [io=A0 0xf060-0xf063]
[=A0=A0=A0 1.044129] pci 0000:00:1f.2: reg 18: [io=A0 0xf050-0xf057]
[=A0=A0=A0 1.044136] pci 0000:00:1f.2: reg 1c: [io=A0 0xf040-0xf043]
[=A0=A0=A0 1.044143] pci 0000:00:1f.2: reg 20: [io=A0 0xf020-0xf03f]
[=A0=A0=A0 1.044150] pci 0000:00:1f.2: reg 24: [mem 0xfb405000-0xfb4057=
ff]
[=A0=A0=A0 1.044180] pci 0000:00:1f.2: PME# supported from D3hot
[=A0=A0=A0 1.044183] pci 0000:00:1f.2: PME# disabled
[=A0=A0=A0 1.044198] pci 0000:00:1f.3: [8086:1c22] type 0 class 0x000c0=
5
[=A0=A0=A0 1.044212] pci 0000:00:1f.3: reg 10: [mem 0xfb404000-0xfb4040=
ff 64bit]
[=A0=A0=A0 1.044232] pci 0000:00:1f.3: reg 20: [io=A0 0xf000-0xf01f]
[=A0=A0=A0 1.044278] pci 0000:01:00.0: [10de:0614] type 0 class 0x00030=
0
[=A0=A0=A0 1.044286] pci 0000:01:00.0: reg 10: [mem 0xfa000000-0xfaffff=
ff]
[=A0=A0=A0 1.044295] pci 0000:01:00.0: reg 14: [mem 0xc0000000-0xcfffff=
ff 64bit pref]
[=A0=A0=A0 1.044304] pci 0000:01:00.0: reg 1c: [mem 0xf8000000-0xf9ffff=
ff 64bit]
[=A0=A0=A0 1.044309] pci 0000:01:00.0: reg 24: [io=A0 0xe000-0xe07f]
[=A0=A0=A0 1.044315] pci 0000:01:00.0: reg 30: [mem 0xfb000000-0xfb01ff=
ff pref]
[=A0=A0=A0 1.051472] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[=A0=A0=A0 1.051474] pci 0000:00:01.0:=A0=A0 bridge window [io=A0 0xe00=
0-0xefff]
[=A0=A0=A0 1.051476] pci 0000:00:01.0:=A0=A0 bridge window [mem 0xf8000=
000-0xfb0fffff]
[=A0=A0=A0 1.051479] pci 0000:00:01.0:=A0=A0 bridge window [mem 0xc0000=
000-0xcfffffff 64bit pref]
[=A0=A0=A0 1.051521] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
[=A0=A0=A0 1.051525] pci 0000:00:1c.0:=A0=A0 bridge window [io=A0 0xf00=
0-0x0000] (disabled)
[=A0=A0=A0 1.051529] pci 0000:00:1c.0:=A0=A0 bridge window [mem 0xfff00=
000-0x000fffff] (disabled)
[=A0=A0=A0 1.051535] pci 0000:00:1c.0:=A0=A0 bridge window [mem 0xfff00=
000-0x000fffff pref] (disabled)
[=A0=A0=A0 1.051603] pci 0000:03:00.0: [1b21:1042] type 0 class 0x000c0=
3
[=A0=A0=A0 1.051631] pci 0000:03:00.0: reg 10: [mem 0xfb300000-0xfb307f=
ff 64bit]
[=A0=A0=A0 1.051754] pci 0000:03:00.0: PME# supported from D3hot D3cold
[=A0=A0=A0 1.051759] pci 0000:03:00.0: PME# disabled
[=A0=A0=A0 1.059471] pci 0000:00:1c.1: PCI bridge to [bus 03-03]
[=A0=A0=A0 1.059475] pci 0000:00:1c.1:=A0=A0 bridge window [io=A0 0xf00=
0-0x0000] (disabled)
[=A0=A0=A0 1.059479] pci 0000:00:1c.1:=A0=A0 bridge window [mem 0xfb300=
000-0xfb3fffff]
[=A0=A0=A0 1.059485] pci 0000:00:1c.1:=A0=A0 bridge window [mem 0xfff00=
000-0x000fffff pref] (disabled)
[=A0=A0=A0 1.059528] pci 0000:00:1c.2: PCI bridge to [bus 04-04]
[=A0=A0=A0 1.059531] pci 0000:00:1c.2:=A0=A0 bridge window [io=A0 0xf00=
0-0x0000] (disabled)
[=A0=A0=A0 1.059535] pci 0000:00:1c.2:=A0=A0 bridge window [mem 0xfff00=
000-0x000fffff] (disabled)
[=A0=A0=A0 1.059541] pci 0000:00:1c.2:=A0=A0 bridge window [mem 0xfff00=
000-0x000fffff pref] (disabled)
[=A0=A0=A0 1.059583] pci 0000:00:1c.3: PCI bridge to [bus 05-05]
[=A0=A0=A0 1.059587] pci 0000:00:1c.3:=A0=A0 bridge window [io=A0 0xf00=
0-0x0000] (disabled)
[=A0=A0=A0 1.059590] pci 0000:00:1c.3:=A0=A0 bridge window [mem 0xfff00=
000-0x000fffff] (disabled)
[=A0=A0=A0 1.059596] pci 0000:00:1c.3:=A0=A0 bridge window [mem 0xfff00=
000-0x000fffff pref] (disabled)
[=A0=A0=A0 1.059663] pci 0000:06:00.0: [1b21:1042] type 0 class 0x000c0=
3
[=A0=A0=A0 1.059691] pci 0000:06:00.0: reg 10: [mem 0xfb200000-0xfb207f=
ff 64bit]
[=A0=A0=A0 1.059814] pci 0000:06:00.0: PME# supported from D3hot D3cold
[=A0=A0=A0 1.059820] pci 0000:06:00.0: PME# disabled
[=A0=A0=A0 1.067467] pci 0000:00:1c.4: PCI bridge to [bus 06-06]
[=A0=A0=A0 1.067471] pci 0000:00:1c.4:=A0=A0 bridge window [io=A0 0xf00=
0-0x0000] (disabled)
[=A0=A0=A0 1.067475] pci 0000:00:1c.4:=A0=A0 bridge window [mem 0xfb200=
000-0xfb2fffff]
[=A0=A0=A0 1.067481] pci 0000:00:1c.4:=A0=A0 bridge window [mem 0xfff00=
000-0x000fffff pref] (disabled)
[=A0=A0=A0 1.067544] pci 0000:07:00.0: [10ec:8168] type 0 class 0x00020=
0
[=A0=A0=A0 1.067564] pci 0000:07:00.0: reg 10: [io=A0 0xd000-0xd0ff]
[=A0=A0=A0 1.067597] pci 0000:07:00.0: reg 18: [mem 0xd0004000-0xd0004f=
ff 64bit pref]
[=A0=A0=A0 1.067619] pci 0000:07:00.0: reg 20: [mem 0xd0000000-0xd0003f=
ff 64bit pref]
[=A0=A0=A0 1.067678] pci 0000:07:00.0: supports D1 D2
[=A0=A0=A0 1.067679] pci 0000:07:00.0: PME# supported from D0 D1 D2 D3h=
ot D3cold
[=A0=A0=A0 1.067684] pci 0000:07:00.0: PME# disabled
[=A0=A0=A0 1.075460] pci 0000:00:1c.5: PCI bridge to [bus 07-07]
[=A0=A0=A0 1.075464] pci 0000:00:1c.5:=A0=A0 bridge window [io=A0 0xd00=
0-0xdfff]
[=A0=A0=A0 1.075468] pci 0000:00:1c.5:=A0=A0 bridge window [mem 0xfff00=
000-0x000fffff] (disabled)
[=A0=A0=A0 1.075474] pci 0000:00:1c.5:=A0=A0 bridge window [mem 0xd0000=
000-0xd00fffff 64bit pref]
[=A0=A0=A0 1.075530] pci 0000:08:00.0: [1b21:1080] type 1 class 0x00060=
4
[=A0=A0=A0 1.075632] pci 0000:00:1c.6: PCI bridge to [bus 08-09] (subtr=
active decode)
[=A0=A0=A0 1.075636] pci 0000:00:1c.6:=A0=A0 bridge window [io=A0 0xf00=
0-0x0000] (disabled)
[=A0=A0=A0 1.075639] pci 0000:00:1c.6:=A0=A0 bridge window [mem 0xfff00=
000-0x000fffff] (disabled)
[=A0=A0=A0 1.075645] pci 0000:00:1c.6:=A0=A0 bridge window [mem 0xfff00=
000-0x000fffff pref] (disabled)
[=A0=A0=A0 1.075646] pci 0000:00:1c.6:=A0=A0 bridge window [io=A0 0x000=
0-0x0cf7] (subtractive decode)
[=A0=A0=A0 1.075648] pci 0000:00:1c.6:=A0=A0 bridge window [io=A0 0x0d0=
0-0xffff] (subtractive decode)
[=A0=A0=A0 1.075649] pci 0000:00:1c.6:=A0=A0 bridge window [mem 0x000a0=
000-0x000bffff] (subtractive decode)
[=A0=A0=A0 1.075651] pci 0000:00:1c.6:=A0=A0 bridge window [mem 0xc0000=
000-0xffffffff] (subtractive decode)
[=A0=A0=A0 1.075763] pci 0000:08:00.0: PCI bridge to [bus 09-09] (subtr=
active decode)
[=A0=A0=A0 1.075773] pci 0000:08:00.0:=A0=A0 bridge window [io=A0 0xfff=
000-0x0000] (disabled)
[=A0=A0=A0 1.075778] pci 0000:08:00.0:=A0=A0 bridge window [mem 0xfff00=
000-0x000fffff] (disabled)
[=A0=A0=A0 1.075788] pci 0000:08:00.0:=A0=A0 bridge window [mem 0xfff00=
000-0x000fffff pref] (disabled)
[=A0=A0=A0 1.075789] pci 0000:08:00.0:=A0=A0 bridge window [??? 0x00000=
000 flags 0x0] (subtractive decode)
[=A0=A0=A0 1.075791] pci 0000:08:00.0:=A0=A0 bridge window [??? 0x00000=
000 flags 0x0] (subtractive decode)
[=A0=A0=A0 1.075792] pci 0000:08:00.0:=A0=A0 bridge window [??? 0x00000=
000 flags 0x0] (subtractive decode)
[=A0=A0=A0 1.075794] pci 0000:08:00.0:=A0=A0 bridge window [??? 0x00000=
000 flags 0x0] (subtractive decode)
[=A0=A0=A0 1.075795] pci 0000:08:00.0:=A0=A0 bridge window [io=A0 0x000=
0-0x0cf7] (subtractive decode)
[=A0=A0=A0 1.075797] pci 0000:08:00.0:=A0=A0 bridge window [io=A0 0x0d0=
0-0xffff] (subtractive decode)
[=A0=A0=A0 1.075798] pci 0000:08:00.0:=A0=A0 bridge window [mem 0x000a0=
000-0x000bffff] (subtractive decode)
[=A0=A0=A0 1.075800] pci 0000:08:00.0:=A0=A0 bridge window [mem 0xc0000=
000-0xffffffff] (subtractive decode)
[=A0=A0=A0 1.075870] pci 0000:0a:00.0: [1b4b:9172] type 0 class 0x00010=
6
[=A0=A0=A0 1.075887] pci 0000:0a:00.0: reg 10: [io=A0 0xc040-0xc047]
[=A0=A0=A0 1.075899] pci 0000:0a:00.0: reg 14: [io=A0 0xc030-0xc033]
[=A0=A0=A0 1.075911] pci 0000:0a:00.0: reg 18: [io=A0 0xc020-0xc027]
[=A0=A0=A0 1.075923] pci 0000:0a:00.0: reg 1c: [io=A0 0xc010-0xc013]
[=A0=A0=A0 1.075935] pci 0000:0a:00.0: reg 20: [io=A0 0xc000-0xc00f]
[=A0=A0=A0 1.075948] pci 0000:0a:00.0: reg 24: [mem 0xfb110000-0xfb1101=
ff]
[=A0=A0=A0 1.075960] pci 0000:0a:00.0: reg 30: [mem 0xfb100000-0xfb10ff=
ff pref]
[=A0=A0=A0 1.075995] pci 0000:0a:00.0: PME# supported from D3hot
[=A0=A0=A0 1.076000] pci 0000:0a:00.0: PME# disabled
[=A0=A0=A0 1.083453] pci 0000:00:1c.7: PCI bridge to [bus 0a-0a]
[=A0=A0=A0 1.083457] pci 0000:00:1c.7:=A0=A0 bridge window [io=A0 0xc00=
0-0xcfff]
[=A0=A0=A0 1.083460] pci 0000:00:1c.7:=A0=A0 bridge window [mem 0xfb100=
000-0xfb1fffff]
[=A0=A0=A0 1.083466] pci 0000:00:1c.7:=A0=A0 bridge window [mem 0xfff00=
000-0x000fffff pref] (disabled)
[=A0=A0=A0 1.083503] pci_bus 0000:00: on NUMA node 0
[=A0=A0=A0 1.083507] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT=
]
[=A0=A0=A0 1.083604] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1=
=2E_PRT]
[=A0=A0=A0 1.083628] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0=
=2E_PRT]
[=A0=A0=A0 1.083649] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX1=
=2E_PRT]
[=A0=A0=A0 1.083669] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX2=
=2E_PRT]
[=A0=A0=A0 1.083689] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX3=
=2E_PRT]
[=A0=A0=A0 1.083710] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX4=
=2E_PRT]
[=A0=A0=A0 1.083731] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX5=
=2E_PRT]
[=A0=A0=A0 1.083751] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX6=
=2E_PRT]
[=A0=A0=A0 1.083773] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX6=
=2EBR24._PRT]
[=A0=A0=A0 1.083827] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX7=
=2E_PRT]
[=A0=A0=A0 1.083908]=A0 pci0000:00: Requesting ACPI _OSC control (0x1d)
[=A0=A0=A0 1.084042]=A0 pci0000:00: ACPI _OSC control (0x1c) granted
[=A0=A0=A0 1.086884] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10=
 *11 12 14 15)
[=A0=A0=A0 1.086915] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 *7 1=
0 11 12 14 15)
[=A0=A0=A0 1.086943] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 10 *=
11 12 14 15)
[=A0=A0=A0 1.086971] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *10 =
11 12 14 15)
[=A0=A0=A0 1.086998] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 *5 6 7 1=
0 11 12 14 15)
[=A0=A0=A0 1.087026] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 *1=
0 11 12 14 15)
[=A0=A0=A0 1.087054] ACPI: PCI Interrupt Link [LNKG] (IRQs *3 4 5 6 7 1=
0 11 12 14 15)
[=A0=A0=A0 1.087082] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 *5 6 7 1=
0 11 12 14 15)
[=A0=A0=A0 1.087140] vgaarb: device added: PCI:0000:01:00.0,decodes=3Di=
o+mem,owns=3Dio+mem,locks=3Dnone
[=A0=A0=A0 1.087142] vgaarb: loaded
[=A0=A0=A0 1.087143] vgaarb: bridge control possible 0000:01:00.0
[=A0=A0=A0 1.087261] SCSI subsystem initialized
[=A0=A0=A0 1.087295] libata version 3.00 loaded.
[=A0=A0=A0 1.087318] usbcore: registered new interface driver usbfs
[=A0=A0=A0 1.087324] usbcore: registered new interface driver hub
[=A0=A0=A0 1.087338] usbcore: registered new device driver usb
[=A0=A0=A0 1.087385] PCI: Using ACPI for IRQ routing
[=A0=A0=A0 1.088679] PCI: pci_cache_line_size set to 64 bytes
[=A0=A0=A0 1.088769] reserve RAM buffer: 000000000009d800 - 00000000000=
9ffff=20
[=A0=A0=A0 1.088771] reserve RAM buffer: 00000000bef9c000 - 00000000bff=
fffff=20
[=A0=A0=A0 1.088773] reserve RAM buffer: 00000000bf5c7000 - 00000000bff=
fffff=20
[=A0=A0=A0 1.088775] reserve RAM buffer: 00000000bf800000 - 00000000bff=
fffff=20
[=A0=A0=A0 1.088831] NetLabel: Initializing
[=A0=A0=A0 1.088832] NetLabel:=A0 domain hash size =3D 128
[=A0=A0=A0 1.088833] NetLabel:=A0 protocols =3D UNLABELED CIPSOv4
[=A0=A0=A0 1.088840] NetLabel:=A0 unlabeled traffic allowed by default
[=A0=A0=A0 1.088865] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, =
0, 0
[=A0=A0=A0 1.088869] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[=A0=A0=A0 1.090882] Switching to clocksource hpet
[=A0=A0=A0 1.091442] Switched to NOHz mode on CPU #0
[=A0=A0=A0 1.091492] Switched to NOHz mode on CPU #3
[=A0=A0=A0 1.091504] Switched to NOHz mode on CPU #2
[=A0=A0=A0 1.091515] Switched to NOHz mode on CPU #7
[=A0=A0=A0 1.091517] Switched to NOHz mode on CPU #1
[=A0=A0=A0 1.091527] Switched to NOHz mode on CPU #6
[=A0=A0=A0 1.091539] Switched to NOHz mode on CPU #5
[=A0=A0=A0 1.091548] Switched to NOHz mode on CPU #4
[=A0=A0=A0 1.094821] AppArmor: AppArmor Filesystem Enabled
[=A0=A0=A0 1.094830] pnp: PnP ACPI init
[=A0=A0=A0 1.094837] ACPI: bus type pnp registered
[=A0=A0=A0 1.094919] pnp 00:00: [bus 00-ff]
[=A0=A0=A0 1.094920] pnp 00:00: [io=A0 0x0cf8-0x0cff]
[=A0=A0=A0 1.094922] pnp 00:00: [io=A0 0x0000-0x0cf7 window]
[=A0=A0=A0 1.094923] pnp 00:00: [io=A0 0x0d00-0xffff window]
[=A0=A0=A0 1.094924] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[=A0=A0=A0 1.094926] pnp 00:00: [mem 0x000c8000-0x000dffff window]
[=A0=A0=A0 1.094927] pnp 00:00: [mem 0xc0000000-0xffffffff window]
[=A0=A0=A0 1.094928] pnp 00:00: [mem 0x00000000 window]
[=A0=A0=A0 1.094960] pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 =
PNP0a03 (active)
[=A0=A0=A0 1.094995] pnp 00:01: [mem 0xfed10000-0xfed19fff]
[=A0=A0=A0 1.094996] pnp 00:01: [mem 0xe0000000-0xe3ffffff]
[=A0=A0=A0 1.094997] pnp 00:01: [mem 0xfed90000-0xfed93fff]
[=A0=A0=A0 1.094999] pnp 00:01: [mem 0xfed20000-0xfed3ffff]
[=A0=A0=A0 1.095000] pnp 00:01: [mem 0xfee00000-0xfee0ffff]
[=A0=A0=A0 1.095044] system 00:01: [mem 0xfed10000-0xfed19fff] has been=
 reserved
[=A0=A0=A0 1.095045] system 00:01: [mem 0xe0000000-0xe3ffffff] has been=
 reserved
[=A0=A0=A0 1.095047] system 00:01: [mem 0xfed90000-0xfed93fff] has been=
 reserved
[=A0=A0=A0 1.095048] system 00:01: [mem 0xfed20000-0xfed3ffff] has been=
 reserved
[=A0=A0=A0 1.095050] system 00:01: [mem 0xfee00000-0xfee0ffff] has been=
 reserved
[=A0=A0=A0 1.095052] system 00:01: Plug and Play ACPI device, IDs PNP0c=
01 (active)
[=A0=A0=A0 1.095091] pnp 00:02: [io=A0 0x0000-0xffffffff disabled]
[=A0=A0=A0 1.095092] pnp 00:02: [io=A0 0x0000-0xffffffff disabled]
[=A0=A0=A0 1.095093] pnp 00:02: [io=A0 0x0290-0x029f]
[=A0=A0=A0 1.095094] pnp 00:02: [io=A0 0x0000-0xffffffff disabled]
[=A0=A0=A0 1.095117] system 00:02: [io=A0 0x0290-0x029f] has been reser=
ved
[=A0=A0=A0 1.095118] system 00:02: Plug and Play ACPI device, IDs PNP0c=
02 (active)
[=A0=A0=A0 1.095126] pnp 00:03: [dma 4]
[=A0=A0=A0 1.095127] pnp 00:03: [io=A0 0x0000-0x000f]
[=A0=A0=A0 1.095129] pnp 00:03: [io=A0 0x0081-0x0083]
[=A0=A0=A0 1.095130] pnp 00:03: [io=A0 0x0087]
[=A0=A0=A0 1.095131] pnp 00:03: [io=A0 0x0089-0x008b]
[=A0=A0=A0 1.095132] pnp 00:03: [io=A0 0x008f]
[=A0=A0=A0 1.095133] pnp 00:03: [io=A0 0x00c0-0x00df]
[=A0=A0=A0 1.095145] pnp 00:03: Plug and Play ACPI device, IDs PNP0200 =
(active)
[=A0=A0=A0 1.095151] pnp 00:04: [io=A0 0x0070-0x0071]
[=A0=A0=A0 1.095159] pnp 00:04: [irq 8]
[=A0=A0=A0 1.095172] pnp 00:04: Plug and Play ACPI device, IDs PNP0b00 =
(active)
[=A0=A0=A0 1.095177] pnp 00:05: [io=A0 0x0061]
[=A0=A0=A0 1.095189] pnp 00:05: Plug and Play ACPI device, IDs PNP0800 =
(active)
[=A0=A0=A0 1.095198] pnp 00:06: [io=A0 0x0010-0x001f]
[=A0=A0=A0 1.095200] pnp 00:06: [io=A0 0x0022-0x003f]
[=A0=A0=A0 1.095201] pnp 00:06: [io=A0 0x0044-0x005f]
[=A0=A0=A0 1.095202] pnp 00:06: [io=A0 0x0063]
[=A0=A0=A0 1.095203] pnp 00:06: [io=A0 0x0065]
[=A0=A0=A0 1.095204] pnp 00:06: [io=A0 0x0067-0x006f]
[=A0=A0=A0 1.095205] pnp 00:06: [io=A0 0x0072-0x007f]
[=A0=A0=A0 1.095206] pnp 00:06: [io=A0 0x0080]
[=A0=A0=A0 1.095207] pnp 00:06: [io=A0 0x0084-0x0086]
[=A0=A0=A0 1.095208] pnp 00:06: [io=A0 0x0088]
[=A0=A0=A0 1.095209] pnp 00:06: [io=A0 0x008c-0x008e]
[=A0=A0=A0 1.095210] pnp 00:06: [io=A0 0x0090-0x009f]
[=A0=A0=A0 1.095211] pnp 00:06: [io=A0 0x00a2-0x00bf]
[=A0=A0=A0 1.095212] pnp 00:06: [io=A0 0x00e0-0x00ef]
[=A0=A0=A0 1.095214] pnp 00:06: [io=A0 0x04d0-0x04d1]
[=A0=A0=A0 1.095239] system 00:06: [io=A0 0x04d0-0x04d1] has been reser=
ved
[=A0=A0=A0 1.095241] system 00:06: Plug and Play ACPI device, IDs PNP0c=
02 (active)
[=A0=A0=A0 1.095246] pnp 00:07: [io=A0 0x00f0-0x00ff]
[=A0=A0=A0 1.095250] pnp 00:07: [irq 13]
[=A0=A0=A0 1.095263] pnp 00:07: Plug and Play ACPI device, IDs PNP0c04 =
(active)
[=A0=A0=A0 1.095278] pnp 00:08: [io=A0 0x0060]
[=A0=A0=A0 1.095279] pnp 00:08: [io=A0 0x0064]
[=A0=A0=A0 1.095282] pnp 00:08: [irq 1]
[=A0=A0=A0 1.095300] pnp 00:08: Plug and Play ACPI device, IDs PNP0303 =
PNP030b (active)
[=A0=A0=A0 1.095462] pnp 00:09: [io=A0 0x03f8-0x03ff]
[=A0=A0=A0 1.095466] pnp 00:09: [irq 4]
[=A0=A0=A0 1.095467] pnp 00:09: [dma 0 disabled]
[=A0=A0=A0 1.095499] pnp 00:09: Plug and Play ACPI device, IDs PNP0501 =
(active)
[=A0=A0=A0 1.095594] pnp 00:0a: [io=A0 0x0400-0x0453]
[=A0=A0=A0 1.095595] pnp 00:0a: [io=A0 0x0458-0x047f]
[=A0=A0=A0 1.095596] pnp 00:0a: [io=A0 0x0000-0xffffffff disabled]
[=A0=A0=A0 1.095597] pnp 00:0a: [io=A0 0x0500-0x057f]
[=A0=A0=A0 1.095598] pnp 00:0a: [mem 0xfed1c000-0xfed1ffff]
[=A0=A0=A0 1.095600] pnp 00:0a: [mem 0xfec00000-0xfecfffff]
[=A0=A0=A0 1.095601] pnp 00:0a: [mem 0xfed08000-0xfed08fff]
[=A0=A0=A0 1.095602] pnp 00:0a: [mem 0xff000000-0xffffffff]
[=A0=A0=A0 1.095627] system 00:0a: [io=A0 0x0400-0x0453] has been reser=
ved
[=A0=A0=A0 1.095629] system 00:0a: [io=A0 0x0458-0x047f] has been reser=
ved
[=A0=A0=A0 1.095630] system 00:0a: [io=A0 0x0500-0x057f] has been reser=
ved
[=A0=A0=A0 1.095632] system 00:0a: [mem 0xfed1c000-0xfed1ffff] has been=
 reserved
[=A0=A0=A0 1.095634] system 00:0a: [mem 0xfec00000-0xfecfffff] could no=
t be reserved
[=A0=A0=A0 1.095635] system 00:0a: [mem 0xfed08000-0xfed08fff] has been=
 reserved
[=A0=A0=A0 1.095637] system 00:0a: [mem 0xff000000-0xffffffff] has been=
 reserved
[=A0=A0=A0 1.095639] system 00:0a: Plug and Play ACPI device, IDs PNP0c=
01 (active)
[=A0=A0=A0 1.095660] pnp 00:0b: [io=A0 0x0454-0x0457]
[=A0=A0=A0 1.095683] system 00:0b: [io=A0 0x0454-0x0457] has been reser=
ved
[=A0=A0=A0 1.095685] system 00:0b: Plug and Play ACPI device, IDs INT3f=
0d PNP0c02 (active)
[=A0=A0=A0 1.095752] pnp 00:0c: [mem 0xfed00000-0xfed003ff]
[=A0=A0=A0 1.095774] pnp 00:0c: Plug and Play ACPI device, IDs PNP0103 =
(active)
[=A0=A0=A0 1.095869] pnp: PnP ACPI: found 13 devices
[=A0=A0=A0 1.095870] ACPI: ACPI bus type pnp unregistered
[=A0=A0=A0 1.095872] PnPBIOS: Disabled by ACPI PNP
[=A0=A0=A0 1.131113] PCI: max bus depth: 2 pci_try_num: 3
[=A0=A0=A0 1.131188] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[=A0=A0=A0 1.131189] pci 0000:00:01.0:=A0=A0 bridge window [io=A0 0xe00=
0-0xefff]
[=A0=A0=A0 1.131192] pci 0000:00:01.0:=A0=A0 bridge window [mem 0xf8000=
000-0xfb0fffff]
[=A0=A0=A0 1.131194] pci 0000:00:01.0:=A0=A0 bridge window [mem 0xc0000=
000-0xcfffffff 64bit pref]
[=A0=A0=A0 1.131197] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
[=A0=A0=A0 1.131198] pci 0000:00:1c.0:=A0=A0 bridge window [io=A0 disab=
led]
[=A0=A0=A0 1.131202] pci 0000:00:1c.0:=A0=A0 bridge window [mem disable=
d]
[=A0=A0=A0 1.131206] pci 0000:00:1c.0:=A0=A0 bridge window [mem pref di=
sabled]
[=A0=A0=A0 1.131211] pci 0000:00:1c.1: PCI bridge to [bus 03-03]
[=A0=A0=A0 1.131212] pci 0000:00:1c.1:=A0=A0 bridge window [io=A0 disab=
led]
[=A0=A0=A0 1.131217] pci 0000:00:1c.1:=A0=A0 bridge window [mem 0xfb300=
000-0xfb3fffff]
[=A0=A0=A0 1.131221] pci 0000:00:1c.1:=A0=A0 bridge window [mem pref di=
sabled]
[=A0=A0=A0 1.131226] pci 0000:00:1c.2: PCI bridge to [bus 04-04]
[=A0=A0=A0 1.131227] pci 0000:00:1c.2:=A0=A0 bridge window [io=A0 disab=
led]
[=A0=A0=A0 1.131231] pci 0000:00:1c.2:=A0=A0 bridge window [mem disable=
d]
[=A0=A0=A0 1.131234] pci 0000:00:1c.2:=A0=A0 bridge window [mem pref di=
sabled]
[=A0=A0=A0 1.131240] pci 0000:00:1c.3: PCI bridge to [bus 05-05]
[=A0=A0=A0 1.131241] pci 0000:00:1c.3:=A0=A0 bridge window [io=A0 disab=
led]
[=A0=A0=A0 1.131246] pci 0000:00:1c.3:=A0=A0 bridge window [mem disable=
d]
[=A0=A0=A0 1.131249] pci 0000:00:1c.3:=A0=A0 bridge window [mem pref di=
sabled]
[=A0=A0=A0 1.131255] pci 0000:00:1c.4: PCI bridge to [bus 06-06]
[=A0=A0=A0 1.131256] pci 0000:00:1c.4:=A0=A0 bridge window [io=A0 disab=
led]
[=A0=A0=A0 1.131260] pci 0000:00:1c.4:=A0=A0 bridge window [mem 0xfb200=
000-0xfb2fffff]
[=A0=A0=A0 1.131264] pci 0000:00:1c.4:=A0=A0 bridge window [mem pref di=
sabled]
[=A0=A0=A0 1.131269] pci 0000:00:1c.5: PCI bridge to [bus 07-07]
[=A0=A0=A0 1.131272] pci 0000:00:1c.5:=A0=A0 bridge window [io=A0 0xd00=
0-0xdfff]
[=A0=A0=A0 1.131277] pci 0000:00:1c.5:=A0=A0 bridge window [mem disable=
d]
[=A0=A0=A0 1.131280] pci 0000:00:1c.5:=A0=A0 bridge window [mem 0xd0000=
000-0xd00fffff 64bit pref]
[=A0=A0=A0 1.131286] pci 0000:08:00.0: PCI bridge to [bus 09-09]
[=A0=A0=A0 1.131287] pci 0000:08:00.0:=A0=A0 bridge window [io=A0 disab=
led]
[=A0=A0=A0 1.131294] pci 0000:08:00.0:=A0=A0 bridge window [mem disable=
d]
[=A0=A0=A0 1.131300] pci 0000:08:00.0:=A0=A0 bridge window [mem pref di=
sabled]
[=A0=A0=A0 1.131309] pci 0000:00:1c.6: PCI bridge to [bus 08-09]
[=A0=A0=A0 1.131310] pci 0000:00:1c.6:=A0=A0 bridge window [io=A0 disab=
led]
[=A0=A0=A0 1.131315] pci 0000:00:1c.6:=A0=A0 bridge window [mem disable=
d]
[=A0=A0=A0 1.131318] pci 0000:00:1c.6:=A0=A0 bridge window [mem pref di=
sabled]
[=A0=A0=A0 1.131324] pci 0000:00:1c.7: PCI bridge to [bus 0a-0a]
[=A0=A0=A0 1.131327] pci 0000:00:1c.7:=A0=A0 bridge window [io=A0 0xc00=
0-0xcfff]
[=A0=A0=A0 1.131331] pci 0000:00:1c.7:=A0=A0 bridge window [mem 0xfb100=
000-0xfb1fffff]
[=A0=A0=A0 1.131335] pci 0000:00:1c.7:=A0=A0 bridge window [mem pref di=
sabled]
[=A0=A0=A0 1.131351] pci 0000:00:01.0: PCI INT A -> GSI 16 (level, low)=
 -> IRQ 16
[=A0=A0=A0 1.131353] pci 0000:00:01.0: setting latency timer to 64
[=A0=A0=A0 1.131361] pci 0000:00:1c.0: PCI INT A -> GSI 17 (level, low)=
 -> IRQ 17
[=A0=A0=A0 1.131364] pci 0000:00:1c.0: setting latency timer to 64
[=A0=A0=A0 1.131370] pci 0000:00:1c.1: PCI INT B -> GSI 16 (level, low)=
 -> IRQ 16
[=A0=A0=A0 1.131374] pci 0000:00:1c.1: setting latency timer to 64
[=A0=A0=A0 1.131382] pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low)=
 -> IRQ 18
[=A0=A0=A0 1.131386] pci 0000:00:1c.2: setting latency timer to 64
[=A0=A0=A0 1.131394] pci 0000:00:1c.3: PCI INT D -> GSI 19 (level, low)=
 -> IRQ 19
[=A0=A0=A0 1.131397] pci 0000:00:1c.3: setting latency timer to 64
[=A0=A0=A0 1.131403] pci 0000:00:1c.4: PCI INT A -> GSI 17 (level, low)=
 -> IRQ 17
[=A0=A0=A0 1.131407] pci 0000:00:1c.4: setting latency timer to 64
[=A0=A0=A0 1.131412] pci 0000:00:1c.5: PCI INT B -> GSI 16 (level, low)=
 -> IRQ 16
[=A0=A0=A0 1.131416] pci 0000:00:1c.5: setting latency timer to 64
[=A0=A0=A0 1.131422] pci 0000:00:1c.6: PCI INT C -> GSI 18 (level, low)=
 -> IRQ 18
[=A0=A0=A0 1.131425] pci 0000:00:1c.6: setting latency timer to 64
[=A0=A0=A0 1.131431] pci 0000:08:00.0: PCI INT A -> GSI 18 (level, low)=
 -> IRQ 18
[=A0=A0=A0 1.131437] pci 0000:08:00.0: setting latency timer to 64
[=A0=A0=A0 1.131444] pci 0000:00:1c.7: PCI INT D -> GSI 19 (level, low)=
 -> IRQ 19
[=A0=A0=A0 1.131448] pci 0000:00:1c.7: setting latency timer to 64
[=A0=A0=A0 1.131451] pci_bus 0000:00: resource 4 [io=A0 0x0000-0x0cf7]
[=A0=A0=A0 1.131452] pci_bus 0000:00: resource 5 [io=A0 0x0d00-0xffff]
[=A0=A0=A0 1.131454] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000b=
ffff]
[=A0=A0=A0 1.131455] pci_bus 0000:00: resource 7 [mem 0xc0000000-0xffff=
ffff]
[=A0=A0=A0 1.131457] pci_bus 0000:01: resource 0 [io=A0 0xe000-0xefff]
[=A0=A0=A0 1.131458] pci_bus 0000:01: resource 1 [mem 0xf8000000-0xfb0f=
ffff]
[=A0=A0=A0 1.131459] pci_bus 0000:01: resource 2 [mem 0xc0000000-0xcfff=
ffff 64bit pref]
[=A0=A0=A0 1.131461] pci_bus 0000:03: resource 1 [mem 0xfb300000-0xfb3f=
ffff]
[=A0=A0=A0 1.131462] pci_bus 0000:06: resource 1 [mem 0xfb200000-0xfb2f=
ffff]
[=A0=A0=A0 1.131464] pci_bus 0000:07: resource 0 [io=A0 0xd000-0xdfff]
[=A0=A0=A0 1.131465] pci_bus 0000:07: resource 2 [mem 0xd0000000-0xd00f=
ffff 64bit pref]
[=A0=A0=A0 1.131466] pci_bus 0000:08: resource 4 [io=A0 0x0000-0x0cf7]
[=A0=A0=A0 1.131468] pci_bus 0000:08: resource 5 [io=A0 0x0d00-0xffff]
[=A0=A0=A0 1.131469] pci_bus 0000:08: resource 6 [mem 0x000a0000-0x000b=
ffff]
[=A0=A0=A0 1.131470] pci_bus 0000:08: resource 7 [mem 0xc0000000-0xffff=
ffff]
[=A0=A0=A0 1.131472] pci_bus 0000:09: resource 8 [io=A0 0x0000-0x0cf7]
[=A0=A0=A0 1.131473] pci_bus 0000:09: resource 9 [io=A0 0x0d00-0xffff]
[=A0=A0=A0 1.131474] pci_bus 0000:09: resource 10 [mem 0x000a0000-0x000=
bffff]
[=A0=A0=A0 1.131476] pci_bus 0000:09: resource 11 [mem 0xc0000000-0xfff=
fffff]
[=A0=A0=A0 1.131477] pci_bus 0000:0a: resource 0 [io=A0 0xc000-0xcfff]
[=A0=A0=A0 1.131478] pci_bus 0000:0a: resource 1 [mem 0xfb100000-0xfb1f=
ffff]
[=A0=A0=A0 1.131499] NET: Registered protocol family 2
[=A0=A0=A0 1.131534] IP route cache hash table entries: 32768 (order: 5=
, 131072 bytes)
[=A0=A0=A0 1.131626] TCP established hash table entries: 131072 (order:=
 8, 1048576 bytes)
[=A0=A0=A0 1.131769] TCP bind hash table entries: 65536 (order: 7, 5242=
88 bytes)
[=A0=A0=A0 1.131831] TCP: Hash tables configured (established 131072 bi=
nd 65536)
[=A0=A0=A0 1.131832] TCP reno registered
[=A0=A0=A0 1.131834] UDP hash table entries: 512 (order: 2, 16384 bytes=
)
[=A0=A0=A0 1.131837] UDP-Lite hash table entries: 512 (order: 2, 16384 =
bytes)
[=A0=A0=A0 1.131884] NET: Registered protocol family 1
[=A0=A0=A0 1.386852] pci 0000:01:00.0: Boot video device
[=A0=A0=A0 1.386907] PCI: CLS 64 bytes, default 64
[=A0=A0=A0 1.387304] audit: initializing netlink socket (disabled)
[=A0=A0=A0 1.387310] type=3D2000 audit(1319491078.064:1): initialized
[=A0=A0=A0 1.401935] highmem bounce pool size: 64 pages
[=A0=A0=A0 1.401939] HugeTLB registered 4 MB page size, pre-allocated 0=
 pages
[=A0=A0=A0 1.406034] VFS: Disk quotas dquot_6.5.2
[=A0=A0=A0 1.406074] Dquot-cache hash table entries: 1024 (order 0, 409=
6 bytes)
[=A0=A0=A0 1.406432] fuse init (API version 7.16)
[=A0=A0=A0 1.406483] msgmni has been set to 1656
[=A0=A0=A0 1.406727] Block layer SCSI generic (bsg) driver version 0.4 =
loaded (major 253)
[=A0=A0=A0 1.406747] io scheduler noop registered
[=A0=A0=A0 1.406748] io scheduler deadline registered
[=A0=A0=A0 1.406755] io scheduler cfq registered (default)
[=A0=A0=A0 1.406835] pcieport 0000:00:01.0: setting latency timer to 64
[=A0=A0=A0 1.406854] pcieport 0000:00:01.0: irq 40 for MSI/MSI-X
[=A0=A0=A0 1.406893] pcieport 0000:00:1c.0: setting latency timer to 64
[=A0=A0=A0 1.406931] pcieport 0000:00:1c.0: irq 41 for MSI/MSI-X
[=A0=A0=A0 1.406986] pcieport 0000:00:1c.1: setting latency timer to 64
[=A0=A0=A0 1.407024] pcieport 0000:00:1c.1: irq 42 for MSI/MSI-X
[=A0=A0=A0 1.407079] pcieport 0000:00:1c.2: setting latency timer to 64
[=A0=A0=A0 1.407116] pcieport 0000:00:1c.2: irq 43 for MSI/MSI-X
[=A0=A0=A0 1.407172] pcieport 0000:00:1c.3: setting latency timer to 64
[=A0=A0=A0 1.407210] pcieport 0000:00:1c.3: irq 44 for MSI/MSI-X
[=A0=A0=A0 1.407265] pcieport 0000:00:1c.4: setting latency timer to 64
[=A0=A0=A0 1.407302] pcieport 0000:00:1c.4: irq 45 for MSI/MSI-X
[=A0=A0=A0 1.407358] pcieport 0000:00:1c.5: setting latency timer to 64
[=A0=A0=A0 1.407395] pcieport 0000:00:1c.5: irq 46 for MSI/MSI-X
[=A0=A0=A0 1.407450] pcieport 0000:00:1c.7: setting latency timer to 64
[=A0=A0=A0 1.407488] pcieport 0000:00:1c.7: irq 47 for MSI/MSI-X
[=A0=A0=A0 1.407550] pcieport 0000:00:01.0: Signaling PME through PCIe =
PME interrupt
[=A0=A0=A0 1.407552] pci 0000:01:00.0: Signaling PME through PCIe PME i=
nterrupt
[=A0=A0=A0 1.407554] pcie_pme 0000:00:01.0:pcie01: service driver pcie_=
pme loaded
[=A0=A0=A0 1.407568] pcieport 0000:00:1c.0: Signaling PME through PCIe =
PME interrupt
[=A0=A0=A0 1.407572] pcie_pme 0000:00:1c.0:pcie01: service driver pcie_=
pme loaded
[=A0=A0=A0 1.407585] pcieport 0000:00:1c.1: Signaling PME through PCIe =
PME interrupt
[=A0=A0=A0 1.407586] pci 0000:03:00.0: Signaling PME through PCIe PME i=
nterrupt
[=A0=A0=A0 1.407590] pcie_pme 0000:00:1c.1:pcie01: service driver pcie_=
pme loaded
[=A0=A0=A0 1.407605] pcieport 0000:00:1c.2: Signaling PME through PCIe =
PME interrupt
[=A0=A0=A0 1.407608] pcie_pme 0000:00:1c.2:pcie01: service driver pcie_=
pme loaded
[=A0=A0=A0 1.407622] pcieport 0000:00:1c.3: Signaling PME through PCIe =
PME interrupt
[=A0=A0=A0 1.407626] pcie_pme 0000:00:1c.3:pcie01: service driver pcie_=
pme loaded
[=A0=A0=A0 1.407640] pcieport 0000:00:1c.4: Signaling PME through PCIe =
PME interrupt
[=A0=A0=A0 1.407642] pci 0000:06:00.0: Signaling PME through PCIe PME i=
nterrupt
[=A0=A0=A0 1.407645] pcie_pme 0000:00:1c.4:pcie01: service driver pcie_=
pme loaded
[=A0=A0=A0 1.407659] pcieport 0000:00:1c.5: Signaling PME through PCIe =
PME interrupt
[=A0=A0=A0 1.407661] pci 0000:07:00.0: Signaling PME through PCIe PME i=
nterrupt
[=A0=A0=A0 1.407664] pcie_pme 0000:00:1c.5:pcie01: service driver pcie_=
pme loaded
[=A0=A0=A0 1.407679] pcieport 0000:00:1c.7: Signaling PME through PCIe =
PME interrupt
[=A0=A0=A0 1.407680] pci 0000:0a:00.0: Signaling PME through PCIe PME i=
nterrupt
[=A0=A0=A0 1.407684] pcie_pme 0000:00:1c.7:pcie01: service driver pcie_=
pme loaded
[=A0=A0=A0 1.407693] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[=A0=A0=A0 1.407707] pciehp: PCI Express Hot Plug Controller Driver ver=
sion: 0.4
[=A0=A0=A0 1.407744] intel_idle: MWAIT substates: 0x1120
[=A0=A0=A0 1.407745] intel_idle: v0.4 model 0x2A
[=A0=A0=A0 1.407746] intel_idle: lapic_timer_reliable_states 0xffffffff
[=A0=A0=A0 1.407810] input: Power Button as /devices/LNXSYSTM:00/device=
:00/PNP0C0C:00/input/input0
[=A0=A0=A0 1.407814] ACPI: Power Button [PWRB]
[=A0=A0=A0 1.407837] input: Power Button as /devices/LNXSYSTM:00/LNXPWR=
BN:00/input/input1
[=A0=A0=A0 1.407838] ACPI: Power Button [PWRF]
[=A0=A0=A0 1.407854] ACPI: acpi_idle yielding to intel_idle
[=A0=A0=A0 1.420151] ERST: Table is not found!
[=A0=A0=A0 1.420190] Serial: 8250/16550 driver, 32 ports, IRQ sharing e=
nabled
[=A0=A0=A0 1.420192] isapnp: Scanning for PnP cards...
[=A0=A0=A0 1.440578] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16=
550A
[=A0=A0=A0 1.440581] Freeing initrd memory: 13308k freed
[=A0=A0=A0 1.775513] isapnp: No Plug & Play device found
[=A0=A0=A0 1.823097] 00:09: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[=A0=A0=A0 1.823274] Linux agpgart interface v0.103
[=A0=A0=A0 1.824002] brd: module loaded
[=A0=A0=A0 1.824311] loop: module loaded
[=A0=A0=A0 1.824554] Fixed MDIO Bus: probed
[=A0=A0=A0 1.824567] PPP generic driver version 2.4.2
[=A0=A0=A0 1.824584] tun: Universal TUN/TAP device driver, 1.6
[=A0=A0=A0 1.824585] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.=
com>
[=A0=A0=A0 1.824622] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI=
) Driver
[=A0=A0=A0 1.824642] ehci_hcd 0000:00:1a.0: PCI INT A -> GSI 23 (level,=
 low) -> IRQ 23
[=A0=A0=A0 1.824650] ehci_hcd 0000:00:1a.0: setting latency timer to 64
[=A0=A0=A0 1.824653] ehci_hcd 0000:00:1a.0: EHCI Host Controller
[=A0=A0=A0 1.824671] ehci_hcd 0000:00:1a.0: new USB bus registered, ass=
igned bus number 1
[=A0=A0=A0 1.824691] ehci_hcd 0000:00:1a.0: debug port 2
[=A0=A0=A0 1.828562] ehci_hcd 0000:00:1a.0: cache line size of 64 is no=
t supported
[=A0=A0=A0 1.828575] ehci_hcd 0000:00:1a.0: irq 23, io mem 0xfb407000
[=A0=A0=A0 1.842537] ehci_hcd 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[=A0=A0=A0 1.842649] hub 1-0:1.0: USB hub found
[=A0=A0=A0 1.842652] hub 1-0:1.0: 2 ports detected
[=A0=A0=A0 1.842689] ehci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level,=
 low) -> IRQ 23
[=A0=A0=A0 1.842697] ehci_hcd 0000:00:1d.0: setting latency timer to 64
[=A0=A0=A0 1.842700] ehci_hcd 0000:00:1d.0: EHCI Host Controller
[=A0=A0=A0 1.842716] ehci_hcd 0000:00:1d.0: new USB bus registered, ass=
igned bus number 2
[=A0=A0=A0 1.842733] ehci_hcd 0000:00:1d.0: debug port 2
[=A0=A0=A0 1.846614] ehci_hcd 0000:00:1d.0: cache line size of 64 is no=
t supported
[=A0=A0=A0 1.846617] ehci_hcd 0000:00:1d.0: irq 23, io mem 0xfb406000
[=A0=A0=A0 1.858526] ehci_hcd 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[=A0=A0=A0 1.858630] hub 2-0:1.0: USB hub found
[=A0=A0=A0 1.858631] hub 2-0:1.0: 2 ports detected
[=A0=A0=A0 1.858665] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Dr=
iver
[=A0=A0=A0 1.858672] uhci_hcd: USB Universal Host Controller Interface =
driver
[=A0=A0=A0 1.858709] i8042: PNP: PS/2 Controller [PNP0303:PS2K] at 0x60=
,0x64 irq 1
[=A0=A0=A0 1.858710] i8042: PNP: PS/2 appears to have AUX port disabled=
, if this is incorrect please boot with i8042.nopnp
[=A0=A0=A0 1.859250] serio: i8042 KBD port at 0x60,0x64 irq 1
[=A0=A0=A0 1.859303] mousedev: PS/2 mouse device common for all mice
[=A0=A0=A0 1.859373] rtc_cmos 00:04: RTC can wake from S4
[=A0=A0=A0 1.859448] rtc_cmos 00:04: rtc core: registered rtc_cmos as r=
tc0
[=A0=A0=A0 1.859473] rtc0: alarms up to one month, y3k, 114 bytes nvram=
, hpet irqs
[=A0=A0=A0 1.859520] device-mapper: uevent: version 1.0.3
[=A0=A0=A0 1.859558] device-mapper: ioctl: 4.20.0-ioctl (2011-02-02) in=
itialised: dm-devel@redhat.com
[=A0=A0=A0 1.859573] EISA: Probing bus 0 at eisa.0
[=A0=A0=A0 1.859575] EISA: Cannot allocate resource for mainboard
[=A0=A0=A0 1.859576] Cannot allocate resource for EISA slot 1
[=A0=A0=A0 1.859577] Cannot allocate resource for EISA slot 2
[=A0=A0=A0 1.859578] Cannot allocate resource for EISA slot 3
[=A0=A0=A0 1.859579] Cannot allocate resource for EISA slot 4
[=A0=A0=A0 1.859580] Cannot allocate resource for EISA slot 5
[=A0=A0=A0 1.859581] Cannot allocate resource for EISA slot 6
[=A0=A0=A0 1.859582] Cannot allocate resource for EISA slot 7
[=A0=A0=A0 1.859583] Cannot allocate resource for EISA slot 8
[=A0=A0=A0 1.859584] EISA: Detected 0 cards.
[=A0=A0=A0 1.859590] cpufreq-nforce2: No nForce2 chipset.
[=A0=A0=A0 1.859706] cpuidle: using governor ladder
[=A0=A0=A0 1.859899] cpuidle: using governor menu
[=A0=A0=A0 1.859901] EFI Variables Facility v0.08 2004-May-17
[=A0=A0=A0 1.860030] TCP cubic registered
[=A0=A0=A0 1.860099] NET: Registered protocol family 10
[=A0=A0=A0 1.860365] NET: Registered protocol family 17
[=A0=A0=A0 1.860372] Registering the dns_resolver key type
[=A0=A0=A0 1.860382] Using IPI No-Shortcut mode
[=A0=A0=A0 1.860420] PM: Hibernation image not present or could not be =
loaded.
[=A0=A0=A0 1.860426] registered taskstats version 1
[=A0=A0=A0 1.866778]=A0=A0 Magic number: 15:775:298
[=A0=A0=A0 1.866886] rtc_cmos 00:04: setting system clock to 2011-10-24=
 21:17:59 UTC (1319491079)
[=A0=A0=A0 1.868037] BIOS EDD facility v0.16 2004-Jun-25, 0 devices fou=
nd
[=A0=A0=A0 1.868038] EDD information not available.
[=A0=A0=A0 1.868206] Freeing unused kernel memory: 696k freed
[=A0=A0=A0 1.868323] Write protecting the kernel text: 5332k
[=A0=A0=A0 1.868388] Write protecting the kernel read-only data: 2188k
[=A0=A0=A0 1.877641] udevd[100]: starting version 173
[=A0=A0=A0 1.885788] input: AT Translated Set 2 keyboard as /devices/pl=
atform/i8042/serio0/input/input2
[=A0=A0=A0 1.891833] xhci_hcd 0000:03:00.0: PCI INT A -> GSI 17 (level,=
 low) -> IRQ 17
[=A0=A0=A0 1.891938] xhci_hcd 0000:03:00.0: setting latency timer to 64
[=A0=A0=A0 1.891942] xhci_hcd 0000:03:00.0: xHCI Host Controller
[=A0=A0=A0 1.891987] xhci_hcd 0000:03:00.0: new USB bus registered, ass=
igned bus number 3
[=A0=A0=A0 1.892889] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[=A0=A0=A0 1.892904] r8169 0000:07:00.0: PCI INT A -> GSI 17 (level, lo=
w) -> IRQ 17
[=A0=A0=A0 1.892957] r8169 0000:07:00.0: setting latency timer to 64
[=A0=A0=A0 1.892967] r8169 0000:07:00.0: (unregistered net_device): unk=
nown MAC, using family default
[=A0=A0=A0 1.893079] r8169 0000:07:00.0: irq 48 for MSI/MSI-X
[=A0=A0=A0 1.893185] ahci 0000:00:1f.2: version 3.0
[=A0=A0=A0 1.893198] ahci 0000:00:1f.2: PCI INT B -> GSI 20 (level, low=
) -> IRQ 20
[=A0=A0=A0 1.893239] ahci 0000:00:1f.2: irq 49 for MSI/MSI-X
[=A0=A0=A0 1.893321] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports=
 6 Gbps 0x1c impl SATA mode
[=A0=A0=A0 1.893324] ahci 0000:00:1f.2: flags: 64bit ncq sntf pm led cl=
o pio slum part ems apst=20
[=A0=A0=A0 1.893329] ahci 0000:00:1f.2: setting latency timer to 64
[=A0=A0=A0 1.893490] r8169 0000:07:00.0: eth0: RTL8168b/8111b at 0xf802=
e000, f4:6d:04:40:36:6f, XID 0c900800 IRQ 48
[=A0=A0=A0 1.899229] xhci_hcd 0000:03:00.0: irq 17, io mem 0xfb300000
[=A0=A0=A0 1.899287] xhci_hcd 0000:03:00.0: irq 50 for MSI/MSI-X
[=A0=A0=A0 1.899292] xhci_hcd 0000:03:00.0: irq 51 for MSI/MSI-X
[=A0=A0=A0 1.899296] xhci_hcd 0000:03:00.0: irq 52 for MSI/MSI-X
[=A0=A0=A0 1.899300] xhci_hcd 0000:03:00.0: irq 53 for MSI/MSI-X
[=A0=A0=A0 1.899304] xhci_hcd 0000:03:00.0: irq 54 for MSI/MSI-X
[=A0=A0=A0 1.899308] xhci_hcd 0000:03:00.0: irq 55 for MSI/MSI-X
[=A0=A0=A0 1.899312] xhci_hcd 0000:03:00.0: irq 56 for MSI/MSI-X
[=A0=A0=A0 1.899317] xhci_hcd 0000:03:00.0: irq 57 for MSI/MSI-X
[=A0=A0=A0 1.899517] xHCI xhci_add_endpoint called for root hub
[=A0=A0=A0 1.899519] xHCI xhci_check_bandwidth called for root hub
[=A0=A0=A0 1.899546] hub 3-0:1.0: USB hub found
[=A0=A0=A0 1.899554] hub 3-0:1.0: 2 ports detected
[=A0=A0=A0 1.899613] xhci_hcd 0000:03:00.0: xHCI Host Controller
[=A0=A0=A0 1.899641] xhci_hcd 0000:03:00.0: new USB bus registered, ass=
igned bus number 4
[=A0=A0=A0 1.904332] xHCI xhci_add_endpoint called for root hub
[=A0=A0=A0 1.904334] xHCI xhci_check_bandwidth called for root hub
[=A0=A0=A0 1.904355] hub 4-0:1.0: USB hub found
[=A0=A0=A0 1.904361] hub 4-0:1.0: 2 ports detected
[=A0=A0=A0 1.904398] xhci_hcd 0000:06:00.0: PCI INT A -> GSI 16 (level,=
 low) -> IRQ 16
[=A0=A0=A0 1.904417] xhci_hcd 0000:06:00.0: setting latency timer to 64
[=A0=A0=A0 1.904420] xhci_hcd 0000:06:00.0: xHCI Host Controller
[=A0=A0=A0 1.904439] xhci_hcd 0000:06:00.0: new USB bus registered, ass=
igned bus number 5
[=A0=A0=A0 1.906785] scsi0 : ahci
[=A0=A0=A0 1.906940] scsi1 : ahci
[=A0=A0=A0 1.907080] scsi2 : ahci
[=A0=A0=A0 1.907210] scsi3 : ahci
[=A0=A0=A0 1.907352] scsi4 : ahci
[=A0=A0=A0 1.907423] scsi5 : ahci
[=A0=A0=A0 1.907541] ata1: DUMMY
[=A0=A0=A0 1.907542] ata2: DUMMY
[=A0=A0=A0 1.907544] ata3: SATA max UDMA/133 abar m2048@0xfb405000 port=
 0xfb405200 irq 49
[=A0=A0=A0 1.907546] ata4: SATA max UDMA/133 abar m2048@0xfb405000 port=
 0xfb405280 irq 49
[=A0=A0=A0 1.907549] ata5: SATA max UDMA/133 abar m2048@0xfb405000 port=
 0xfb405300 irq 49
[=A0=A0=A0 1.907550] ata6: DUMMY
[=A0=A0=A0 1.907574] ahci 0000:0a:00.0: PCI INT A -> GSI 19 (level, low=
) -> IRQ 19
[=A0=A0=A0 1.907672] ahci 0000:0a:00.0: irq 58 for MSI/MSI-X
[=A0=A0=A0 1.907800] ahci 0000:0a:00.0: AHCI 0001.0000 32 slots 2 ports=
 6 Gbps 0x3 impl SATA mode
[=A0=A0=A0 1.907802] ahci 0000:0a:00.0: flags: 64bit ncq sntf led only =
pmp fbs pio slum part sxs=20
[=A0=A0=A0 1.907808] ahci 0000:0a:00.0: setting latency timer to 64
[=A0=A0=A0 1.908000] scsi6 : ahci
[=A0=A0=A0 1.908046] scsi7 : ahci
[=A0=A0=A0 1.908071] ata7: SATA max UDMA/133 abar m512@0xfb110000 port =
0xfb110100 irq 58
[=A0=A0=A0 1.908074] ata8: SATA max UDMA/133 abar m512@0xfb110000 port =
0xfb110180 irq 58
[=A0=A0=A0 1.911449] xhci_hcd 0000:06:00.0: irq 16, io mem 0xfb200000
[=A0=A0=A0 1.911497] xhci_hcd 0000:06:00.0: irq 59 for MSI/MSI-X
[=A0=A0=A0 1.911499] xhci_hcd 0000:06:00.0: irq 60 for MSI/MSI-X
[=A0=A0=A0 1.911502] xhci_hcd 0000:06:00.0: irq 61 for MSI/MSI-X
[=A0=A0=A0 1.911504] xhci_hcd 0000:06:00.0: irq 62 for MSI/MSI-X
[=A0=A0=A0 1.911507] xhci_hcd 0000:06:00.0: irq 63 for MSI/MSI-X
[=A0=A0=A0 1.911510] xhci_hcd 0000:06:00.0: irq 64 for MSI/MSI-X
[=A0=A0=A0 1.911513] xhci_hcd 0000:06:00.0: irq 65 for MSI/MSI-X
[=A0=A0=A0 1.911515] xhci_hcd 0000:06:00.0: irq 66 for MSI/MSI-X
[=A0=A0=A0 1.911648] xHCI xhci_add_endpoint called for root hub
[=A0=A0=A0 1.911649] xHCI xhci_check_bandwidth called for root hub
[=A0=A0=A0 1.911662] hub 5-0:1.0: USB hub found
[=A0=A0=A0 1.911668] hub 5-0:1.0: 2 ports detected
[=A0=A0=A0 1.911701] xhci_hcd 0000:06:00.0: xHCI Host Controller
[=A0=A0=A0 1.911718] xhci_hcd 0000:06:00.0: new USB bus registered, ass=
igned bus number 6
[=A0=A0=A0 1.916645] xHCI xhci_add_endpoint called for root hub
[=A0=A0=A0 1.916646] xHCI xhci_check_bandwidth called for root hub
[=A0=A0=A0 1.916666] hub 6-0:1.0: USB hub found
[=A0=A0=A0 1.916672] hub 6-0:1.0: 2 ports detected
[=A0=A0=A0 2.154386] usb 1-1: new high speed USB device number 2 using =
ehci_hcd
[=A0=A0=A0 2.226351] ata7: SATA link down (SStatus 0 SControl 300)
[=A0=A0=A0 2.226393] ata8: SATA link down (SStatus 0 SControl 300)
[=A0=A0=A0 2.230346] ata5: SATA link up 1.5 Gbps (SStatus 113 SControl =
300)
[=A0=A0=A0 2.230372] ata4: SATA link up 3.0 Gbps (SStatus 123 SControl =
300)
[=A0=A0=A0 2.230393] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl =
300)
[=A0=A0=A0 2.230598] ata5.00: ATAPI: ATAPI=A0=A0 iHAS220=A0=A0 6, 8L07,=
 max UDMA/100
[=A0=A0=A0 2.231538] ata5.00: configured for UDMA/100
[=A0=A0=A0 2.235441] ata3.00: ATA-7: SAMSUNG SP2504C, VT100-33, max UDM=
A7
[=A0=A0=A0 2.235446] ata3.00: 488397168 sectors, multi 16: LBA48 NCQ (d=
epth 31/32), AA
[=A0=A0=A0 2.236910] ata4.00: ATA-7: SAMSUNG HD103UJ, 1AA01118, max UDM=
A7
[=A0=A0=A0 2.236914] ata4.00: 1953525168 sectors, multi 16: LBA48 NCQ (=
depth 31/32), AA
[=A0=A0=A0 2.240587] ata3.00: configured for UDMA/133
[=A0=A0=A0 2.240769] scsi 2:0:0:0: Direct-Access=A0=A0=A0=A0 ATA=A0=A0=A0=
=A0=A0 SAMSUNG SP2504C=A0 VT10 PQ: 0 ANSI: 5
[=A0=A0=A0 2.240898] sd 2:0:0:0: Attached scsi generic sg0 type 0
[=A0=A0=A0 2.240987] sd 2:0:0:0: [sda] 488397168 512-byte logical block=
s: (250 GB/232 GiB)
[=A0=A0=A0 2.241066] sd 2:0:0:0: [sda] Write Protect is off
[=A0=A0=A0 2.241068] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[=A0=A0=A0 2.241089] sd 2:0:0:0: [sda] Write cache: enabled, read cache=
: enabled, doesn't support DPO or FUA
[=A0=A0=A0 2.243529] ata4.00: configured for UDMA/133
[=A0=A0=A0 2.243675] scsi 3:0:0:0: Direct-Access=A0=A0=A0=A0 ATA=A0=A0=A0=
=A0=A0 SAMSUNG HD103UJ=A0 1AA0 PQ: 0 ANSI: 5
[=A0=A0=A0 2.243739] sd 3:0:0:0: [sdb] 1953525168 512-byte logical bloc=
ks: (1.00 TB/931 GiB)
[=A0=A0=A0 2.243755] sd 3:0:0:0: Attached scsi generic sg1 type 0
[=A0=A0=A0 2.243771] sd 3:0:0:0: [sdb] Write Protect is off
[=A0=A0=A0 2.243774] sd 3:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[=A0=A0=A0 2.243788] sd 3:0:0:0: [sdb] Write cache: enabled, read cache=
: enabled, doesn't support DPO or FUA
[=A0=A0=A0 2.244816] scsi 4:0:0:0: CD-ROM=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 ATAPI=A0=A0=A0 iHAS220=A0=A0 6=A0=A0=A0=A0=A0 8L07 PQ: 0 ANSI: 5
[=A0=A0=A0 2.248160] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw=
 xa/form2 cdda tray
[=A0=A0=A0 2.248165] cdrom: Uniform CD-ROM driver Revision: 3.20
[=A0=A0=A0 2.248272] sr 4:0:0:0: Attached scsi CD-ROM sr0
[=A0=A0=A0 2.248300] sr 4:0:0:0: Attached scsi generic sg2 type 5
[=A0=A0=A0 2.249301]=A0 sda: sda1 sda2
[=A0=A0=A0 2.249527] sd 2:0:0:0: [sda] Attached SCSI disk
[=A0=A0=A0 2.264739]=A0 sdb: sdb1 sdb2 sdb3
[=A0=A0=A0 2.264990] sd 3:0:0:0: [sdb] Attached SCSI disk
[=A0=A0=A0 2.290978] hub 1-1:1.0: USB hub found
[=A0=A0=A0 2.291072] hub 1-1:1.0: 6 ports detected
[=A0=A0=A0 2.386225] Refined TSC clocksource calibration: 3411.127 MHz.
[=A0=A0=A0 2.386231] Switching to clocksource tsc
[=A0=A0=A0 2.402188] usb 2-1: new high speed USB device number 2 using =
ehci_hcd
[=A0=A0=A0 2.534709] hub 2-1:1.0: USB hub found
[=A0=A0=A0 2.534821] hub 2-1:1.0: 8 ports detected
[=A0=A0=A0 2.589051] EXT4-fs (sdb1): mounted filesystem with ordered da=
ta mode. Opts: (null)
[=A0=A0=A0 2.806022] usb 2-1.5: new low speed USB device number 3 using=
 ehci_hcd
[=A0=A0=A0 2.973911] usb 2-1.7: new full speed USB device number 4 usin=
g ehci_hcd
[=A0=A0=A0 8.928527] udevd[324]: starting version 173
[=A0=A0=A0 8.947964] wmi: Mapper loaded
[=A0=A0=A0 8.948075] mei: module is from the staging directory, the qua=
lity is unknown, you have been warned.
[=A0=A0=A0 8.948285] mei 0000:00:16.0: PCI INT A -> GSI 21 (level, low)=
 -> IRQ 21
[=A0=A0=A0 8.948291] mei 0000:00:16.0: setting latency timer to 64
[=A0=A0=A0 8.949743] [drm] Initialized drm 1.1.0 20060810
[=A0=A0=A0 8.950727] lp: driver loaded but no devices found
[=A0=A0=A0 8.954135] nouveau 0000:01:00.0: PCI INT A -> GSI 16 (level, =
low) -> IRQ 16
[=A0=A0=A0 8.954140] nouveau 0000:01:00.0: setting latency timer to 64
[=A0=A0=A0 8.955102] [drm] nouveau 0000:01:00.0: Detected an NV50 gener=
ation card (0x092a00a2)
[=A0=A0=A0 8.958136] [drm] nouveau 0000:01:00.0: Attempting to load BIO=
S image from PRAMIN
[=A0=A0=A0 8.967795] Bluetooth: Core ver 2.16
[=A0=A0=A0 8.967810] NET: Registered protocol family 31
[=A0=A0=A0 8.967812] Bluetooth: HCI device and connection manager initi=
alized
[=A0=A0=A0 8.967813] Bluetooth: HCI socket layer initialized
[=A0=A0=A0 8.967814] Bluetooth: L2CAP socket layer initialized
[=A0=A0=A0 8.969034] Bluetooth: SCO socket layer initialized
[=A0=A0=A0 8.969228] Bluetooth: Generic Bluetooth USB driver ver 0.6
[=A0=A0=A0 8.969656] usbcore: registered new interface driver btusb
[=A0=A0=A0 8.991553] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 22 (level=
, low) -> IRQ 22
[=A0=A0=A0 8.991557] hda_intel: position_fix set to 1 for device 1043:8=
410
[=A0=A0=A0 8.991627] HDA Intel 0000:00:1b.0: irq 67 for MSI/MSI-X
[=A0=A0=A0 8.991662] HDA Intel 0000:00:1b.0: setting latency timer to 6=
4
[=A0=A0=A0 8.994853] type=3D1400 audit(1319480286.629:2): apparmor=3D"S=
TATUS" operation=3D"profile_load" name=3D"/sbin/dhclient" pid=3D444 com=
m=3D"apparmor_parser"
[=A0=A0=A0 8.995180] type=3D1400 audit(1319480286.629:3): apparmor=3D"S=
TATUS" operation=3D"profile_load" name=3D"/usr/lib/NetworkManager/nm-dh=
cp-client.action" pid=3D444 comm=3D"apparmor_parser"
[=A0=A0=A0 8.995244] Adding 544764k swap on /dev/sdb2.=A0 Priority:-1 e=
xtents:1 across:544764k=20
[=A0=A0=A0 8.995396] type=3D1400 audit(1319480286.629:4): apparmor=3D"S=
TATUS" operation=3D"profile_load" name=3D"/usr/lib/connman/scripts/dhcl=
ient-script" pid=3D444 comm=3D"apparmor_parser"
[=A0=A0=A0 8.996287] type=3D1400 audit(1319480286.629:5): apparmor=3D"S=
TATUS" operation=3D"profile_replace" name=3D"/sbin/dhclient" pid=3D546 =
comm=3D"apparmor_parser"
[=A0=A0=A0 8.996580] type=3D1400 audit(1319480286.629:6): apparmor=3D"S=
TATUS" operation=3D"profile_replace" name=3D"/usr/lib/NetworkManager/nm=
-dhcp-client.action" pid=3D546 comm=3D"apparmor_parser"
[=A0=A0=A0 8.996786] type=3D1400 audit(1319480286.629:7): apparmor=3D"S=
TATUS" operation=3D"profile_replace" name=3D"/usr/lib/connman/scripts/d=
hclient-script" pid=3D546 comm=3D"apparmor_parser"
[=A0=A0=A0 9.012390] asus_wmi: ASUS WMI generic driver loaded
[=A0=A0=A0 9.012858] asus_wmi: Initialization: 0x0
[=A0=A0=A0 9.012885] asus_wmi: BIOS WMI version: 0.9
[=A0=A0=A0 9.012934] asus_wmi: SFUN value: 0x0
[=A0=A0=A0 9.013266] input: Eee PC WMI hotkeys as /devices/platform/eee=
pc-wmi/input/input3
[=A0=A0=A0 9.015034] [drm] nouveau 0000:01:00.0: ... appears to be vali=
d
[=A0=A0=A0 9.015038] [drm] nouveau 0000:01:00.0: BIT BIOS found
[=A0=A0=A0 9.015040] [drm] nouveau 0000:01:00.0: Bios version 62.92.6d.=
00
[=A0=A0=A0 9.015043] [drm] nouveau 0000:01:00.0: TMDS table version 2.0
[=A0=A0=A0 9.015045] [drm] nouveau 0000:01:00.0: Found Display Configur=
ation Block version 4.0
[=A0=A0=A0 9.015047] [drm] nouveau 0000:01:00.0: Raw DCB entry 0: 02000=
300 00000028
[=A0=A0=A0 9.015049] [drm] nouveau 0000:01:00.0: Raw DCB entry 1: 01000=
302 00020030
[=A0=A0=A0 9.015051] [drm] nouveau 0000:01:00.0: Raw DCB entry 2: 04011=
310 00000028
[=A0=A0=A0 9.015053] [drm] nouveau 0000:01:00.0: Raw DCB entry 3: 02023=
322 00020030
[=A0=A0=A0 9.015056] [drm] nouveau 0000:01:00.0: DCB connector table: V=
HER 0x40 5 16 4
[=A0=A0=A0 9.015058] [drm] nouveau 0000:01:00.0:=A0=A0 0: 0x00001030: t=
ype 0x30 idx 0 tag 0x07
[=A0=A0=A0 9.015060] [drm] nouveau 0000:01:00.0:=A0=A0 1: 0x00000100: t=
ype 0x00 idx 1 tag 0xff
[=A0=A0=A0 9.015062] [drm] nouveau 0000:01:00.0:=A0=A0 2: 0x00000210: t=
ype 0x10 idx 2 tag 0xff
[=A0=A0=A0 9.015064] [drm] nouveau 0000:01:00.0:=A0=A0 3: 0x00002261: t=
ype 0x61 idx 3 tag 0x08
[=A0=A0=A0 9.015066] [drm] nouveau 0000:01:00.0:=A0=A0 4: 0x00000213: t=
ype 0x13 idx 4 tag 0xff
[=A0=A0=A0 9.015068] [drm] nouveau 0000:01:00.0:=A0=A0 5: 0x00002361: t=
ype 0x61 idx 5 tag 0x08
[=A0=A0=A0 9.015072] [drm] nouveau 0000:01:00.0: Parsing VBIOS init tab=
le 0 at offset 0xC5D1
[=A0=A0=A0 9.035688] hda_codec: ALC892: BIOS auto-probing.
[=A0=A0=A0 9.041051] input: HDA Intel PCH Headphone as /devices/pci0000=
:00/0000:00:1b.0/sound/card0/input4
[=A0=A0=A0 9.047331] [drm] nouveau 0000:01:00.0: Parsing VBIOS init tab=
le 1 at offset 0xCB70
[=A0=A0=A0 9.050142] [drm] nouveau 0000:01:00.0: Parsing VBIOS init tab=
le 2 at offset 0xD941
[=A0=A0=A0 9.050147] [drm] nouveau 0000:01:00.0: Parsing VBIOS init tab=
le 3 at offset 0xDA3F
[=A0=A0=A0 9.051206] [drm] nouveau 0000:01:00.0: Parsing VBIOS init tab=
le 4 at offset 0xDCA7
[=A0=A0=A0 9.051208] [drm] nouveau 0000:01:00.0: Parsing VBIOS init tab=
le at offset 0xDD0C
[=A0=A0=A0 9.071039] [drm] nouveau 0000:01:00.0: 0xDD0C: Condition stil=
l not met after 20ms, skipping following opcodes
[=A0=A0=A0 9.071051] [drm] nouveau 0000:01:00.0: timingset 255 does not=
 exist
[=A0=A0=A0 9.089633] [drm] nouveau 0000:01:00.0: 1 available performanc=
e level(s)
[=A0=A0=A0 9.089636] [drm] nouveau 0000:01:00.0: 3: memory 900MHz core =
600MHz shader 1500MHz fanspeed 100%
[=A0=A0=A0 9.089648] [drm] nouveau 0000:01:00.0: c: memory 399MHz core =
399MHz shader 810MHz voltage 1150mV
[=A0=A0=A0 9.089708] [TTM] Zone=A0 kernel: Available graphics memory: 4=
30990 kiB.
[=A0=A0=A0 9.089710] [TTM] Zone highmem: Available graphics memory: 154=
1596 kiB.
[=A0=A0=A0 9.089711] [TTM] Initializing pool allocator.
[=A0=A0=A0 9.089719] [drm] nouveau 0000:01:00.0: Detected 1024MiB VRAM
[=A0=A0=A0 9.094170] [drm] nouveau 0000:01:00.0: 512 MiB GART (aperture=
)
[=A0=A0=A0 9.104453] input: Logitech USB Optical Mouse as /devices/pci0=
000:00/0000:00:1d.0/usb2/2-1/2-1.5/2-1.5:1.0/input/input5
[=A0=A0=A0 9.104535] generic-usb 0003:046D:C019.0001: input,hidraw0: US=
B HID v1.11 Mouse [Logitech USB Optical Mouse] on usb-0000:00:1d.0-1.5/=
input0
[=A0=A0=A0 9.104557] usbcore: registered new interface driver usbhid
[=A0=A0=A0 9.104558] usbhid: USB HID core driver
[=A0=A0=A0 9.117051] [drm] Supports vblank timestamp caching Rev 1 (10.=
10.2010).
[=A0=A0=A0 9.117052] [drm] No driver support for vblank timestamp query=
=2E
[=A0=A0=A0 9.278929] [drm] nouveau 0000:01:00.0: allocated 1920x1200 fb=
: 0x40000000, bo f0df0200
[=A0=A0=A0 9.278961] fbcon: nouveaufb (fb0) is primary device
[=A0=A0=A0 9.279031] Console: switching to colour frame buffer device 2=
40x75
[=A0=A0=A0 9.279068] fb0: nouveaufb frame buffer device
[=A0=A0=A0 9.279069] drm: registered panic notifier
[=A0=A0=A0 9.279074] [drm] Initialized nouveau 0.0.16 20090420 for 0000=
:01:00.0 on minor 0
[=A0=A0=A0 9.318521] EXT4-fs (sdb1): re-mounted. Opts: errors=3Dremount=
-ro
[=A0=A0=A0 9.458922] type=3D1400 audit(1319480287.093:8): apparmor=3D"S=
TATUS" operation=3D"profile_load" name=3D"/usr/lib/lightdm/lightdm-gues=
t-session-wrapper" pid=3D841 comm=3D"apparmor_parser"
[=A0=A0=A0 9.459308] type=3D1400 audit(1319480287.093:9): apparmor=3D"S=
TATUS" operation=3D"profile_replace" name=3D"/sbin/dhclient" pid=3D842 =
comm=3D"apparmor_parser"
[=A0=A0=A0 9.459842] type=3D1400 audit(1319480287.093:10): apparmor=3D"=
STATUS" operation=3D"profile_load" name=3D"/usr/lib/cups/backend/cups-p=
df" pid=3D847 comm=3D"apparmor_parser"
[=A0=A0=A0 9.460268] type=3D1400 audit(1319480287.093:11): apparmor=3D"=
STATUS" operation=3D"profile_load" name=3D"/usr/sbin/cupsd" pid=3D847 c=
omm=3D"apparmor_parser"
[=A0=A0=A0 9.477866] ppdev: user-space parallel port driver
[=A0=A0=A0 9.578167] r8169 0000:07:00.0: eth0: link down
[=A0=A0=A0 9.578173] r8169 0000:07:00.0: eth0: link down
[=A0=A0=A0 9.578337] ADDRCONF(NETDEV_UP): eth0: link is not ready
[=A0=A0=A0 9.580544] init: failsafe main process (791) killed by TERM s=
ignal
[=A0=A0=A0 9.580893] init: apport pre-start process (906) terminated wi=
th status 1
[=A0=A0=A0 9.584230] init: apport post-stop process (932) terminated wi=
th status 1
[=A0=A0=A0 9.697514] Bluetooth: RFCOMM TTY layer initialized
[=A0=A0=A0 9.697518] Bluetooth: RFCOMM socket layer initialized
[=A0=A0=A0 9.697520] Bluetooth: RFCOMM ver 1.11
[=A0=A0=A0 9.698980] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[=A0=A0=A0 9.698982] Bluetooth: BNEP filters: protocol multicast
[=A0=A0 10.150010] EXT4-fs (sdb1): re-mounted. Opts: errors=3Dremount-r=
o,commit=3D0
[=A0=A0 10.342243] init: plymouth-stop pre-start process (1094) termina=
ted with status 1
[=A0=A0 11.101056] EXT4-fs (sdb1): re-mounted. Opts: errors=3Dremount-r=
o,commit=3D0
[=A0=A0 11.248710] r8169 0000:07:00.0: eth0: link up
[=A0=A0 11.248779] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[=A0=A0 22.241342] eth0: no IPv6 routers present
[=A0 196.975073] r8169 0000:07:00.0: eth0: link up
[=A0 207.107441] r8169 0000:07:00.0: eth0: link up
[=A0 230.616489] r8169 0000:07:00.0: eth0: link up
[=A0 231.239748] r8169 0000:07:00.0: eth0: link up
[=A0 231.799134] r8169 0000:07:00.0: eth0: link up
[=A0 240.748847] r8169 0000:07:00.0: eth0: link up
[=A0 245.990835] r8169 0000:07:00.0: eth0: link up
[=A0 246.170619] r8169 0000:07:00.0: eth0: link up
[=A0 246.394361] r8169 0000:07:00.0: eth0: link up
[=A0 246.638096] r8169 0000:07:00.0: eth0: link up
[=A0 246.989694] r8169 0000:07:00.0: eth0: link up
[=A0 247.573039] r8169 0000:07:00.0: eth0: link up
[=A0 251.628368] r8169 0000:07:00.0: eth0: link up
[=A0 255.843519] r8169 0000:07:00.0: eth0: link up
[=A0 298.786271] r8169 0000:07:00.0: eth0: link up
[=A0 318.479667] r8169 0000:07:00.0: eth0: link up
[=A0 318.815294] r8169 0000:07:00.0: eth0: link up
[=A0 319.466557] r8169 0000:07:00.0: eth0: link up
[=A0 320.121810] r8169 0000:07:00.0: eth0: link up
[=A0 321.632076] r8169 0000:07:00.0: eth0: link up
[=A0 323.322134] r8169 0000:07:00.0: eth0: link up
[=A0 324.317186] r8169 0000:07:00.0: eth0: link up
[=A0 325.036176] r8169 0000:07:00.0: eth0: link up
[=A0 325.727384] r8169 0000:07:00.0: eth0: link up
[=A0 326.826111] r8169 0000:07:00.0: eth0: link up
[=A0 327.185701] r8169 0000:07:00.0: eth0: link up
[=A0 327.816990] r8169 0000:07:00.0: eth0: link up
[=A0 328.420284] r8169 0000:07:00.0: eth0: link up
[=A0 329.339244] r8169 0000:07:00.0: eth0: link up
[=A0 330.146305] r8169 0000:07:00.0: eth0: link up
[=A0 331.716490] r8169 0000:07:00.0: eth0: link up
[=A0 350.107409] r8169 0000:07:00.0: eth0: link up
[=A0 355.001788] r8169 0000:07:00.0: eth0: link up
[=A0 355.365365] r8169 0000:07:00.0: eth0: link up
[=A0 355.728939] r8169 0000:07:00.0: eth0: link up
[=A0 356.052577] r8169 0000:07:00.0: eth0: link up
[=A0 356.512052] r8169 0000:07:00.0: eth0: link up
[=A0 356.611943] r8169 0000:07:00.0: eth0: link up
[=A0 356.887632] r8169 0000:07:00.0: eth0: link up
[=A0 356.991509] r8169 0000:07:00.0: eth0: link up
[=A0 357.271184] r8169 0000:07:00.0: eth0: link up
[=A0 360.659292] net_ratelimit: 4 callbacks suppressed
[=A0 360.659299] r8169 0000:07:00.0: eth0: link up
[=A0 363.064547] r8169 0000:07:00.0: eth0: link up
[=A0 391.943419] r8169 0000:07:00.0: eth0: link up
[=A0 393.197959] r8169 0000:07:00.0: eth0: link up
[=A0 399.267045] r8169 0000:07:00.0: eth0: link up
[=A0 403.302382] r8169 0000:07:00.0: eth0: link up
[=A0 641.409239] r8169 0000:07:00.0: eth0: link up
[=A0 647.877845] r8169 0000:07:00.0: eth0: link up






----- Original Message -----
=46rom: Francois Romieu <romieu@fr.zoreil.com>
To: Adrian George Sav <adi_sav@yahoo.com>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Sent: Saturday, October 22, 2011 9:44 PM
Subject: Re: Kernel driver r8169 not working for Realtek 8111E onboard =
network card

Adrian George Sav <adi_sav@yahoo.com> :
[...]
> I am having trouble with the r8169 kernel driver for Realtek 8111E ne=
twork
> card. The NIC works intermittently and horribly with this driver. Unu=
sable.
>=20
> Below is my config. I am happy to provide any and every other necessa=
ry
> information to help in solving this.

Up to 2.6.39 ?

Your r8169 driver is too old. Please try current -rc and send your dmes=
g
including the XID line from the r8169 driver.

--=20
Ueimor
