From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [vti6_tunnel_init] INFO: trying to register non-static key.
Date: Sun, 5 Jan 2014 10:20:17 +0800
Message-ID: <20140105022017.GB16180@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="xHFwDpU9dbj6ez1V"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Li RongQing <roy.qing.li@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

Commit 469bdcefdc ("ipv6: fix the use of pcpu_tstats in ip6_vti.c") is
found to triggered the following warning

        [   11.962468] NET: Registered protocol family 10
        [   11.968156] mip6: Mobile IPv6
        [   11.968156] mip6: Mobile IPv6
==>     [   11.972776] INFO: trying to register non-static key.

Full dmesg (with call trace) and kconfig attached.

Thanks,
Fengguang

--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-yocto-jaketown-31:20140104222818:i386-randconfig-nh0-01042205:3.13.0-rc6-wl-02230-g0e61c86:1"
Content-Transfer-Encoding: quoted-printable

early console in setup code
early console in decompress_kernel

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Linux version 3.13.0-rc6-wl-02230-g0e61c86 (kbuild@nhm4) (gc=
c version 4.8.1 (Debian 4.8.1-8) ) #1 SMP Sat Jan 4 22:26:13 CST 2014
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   NSC Geode by NSC
[    0.000000]   Cyrix CyrixInstead
[    0.000000]   Transmeta GenuineTMx86
[    0.000000]   Transmeta TransmetaCPU
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0xfffe max_arch_pfn =3D 0x1000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdae0-0x000fdaef] mapped at =
[800fdae0]
[    0.000000]   mpc: fdaf0-fdbe4
[    0.000000] initial memory mapped: [mem 0x00000000-0x02ffffff]
[    0.000000] Base memory trampoline at [8009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0fa00000-0x0fbfffff]
[    0.000000]  [mem 0x0fa00000-0x0fbfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x0c000000-0x0f9fffff]
[    0.000000]  [mem 0x0c000000-0x0f9fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0bffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x0bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x0fc00000-0x0fffdfff]
[    0.000000]  [mem 0x0fc00000-0x0fdfffff] page 2M
[    0.000000]  [mem 0x0fe00000-0x0fffdfff] page 4k
[    0.000000] BRK [0x02631000, 0x02631fff] PGTABLE
[    0.000000] BRK [0x02632000, 0x02633fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x0fce4000-0x0ffeffff]
[    0.000000] ACPI: RSDP 000fd950 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0fffe450 000034 (v01 BOCHS  BXPCRSDT 00000001 BXP=
C 00000001)
[    0.000000] ACPI: FACP 0fffff80 000074 (v01 BOCHS  BXPCFACP 00000001 BXP=
C 00000001)
[    0.000000] ACPI: DSDT 0fffe490 0011A9 (v01   BXPC   BXDSDT 00000001 INT=
L 20100528)
[    0.000000] ACPI: FACS 0fffff40 000040
[    0.000000] ACPI: SSDT 0ffff7a0 000796 (v01 BOCHS  BXPCSSDT 00000001 BXP=
C 00000001)
[    0.000000] ACPI: APIC 0ffff680 000080 (v01 BOCHS  BXPCAPIC 00000001 BXP=
C 00000001)
[    0.000000] ACPI: HPET 0ffff640 000038 (v01 BOCHS  BXPCHPET 00000001 BXP=
C 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 255MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 0fffe000
[    0.000000]   low ram: 0 - 0fffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, boot clock
[    0.000000] BRK [0x02634000, 0x02634fff] PGTABLE
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x00001000-0x0fffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000] free_area_init_node: node 0, pgdat 81ee9700, node_mem_map 8f=
ae4020
[    0.000000]   Normal zone: 512 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 65436 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:2 nr_cpu_ids:2 nr_n=
ode_ids:1
[    0.000000] PERCPU: Embedded 331 pages/cpu @8f84e000 s1339912 r0 d15864 =
u1355776
[    0.000000] pcpu-alloc: s1339912 r0 d15864 u1355776 alloc=3D331*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr f850980
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 64924
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled panic=3D10  prompt_ramdisk=
=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 r=
w link=3D/kernel-tests/run-queue/kvm/i386-randconfig-nh0-01042205/linux-dev=
el:devel-hourly-2014010420/.vmlinuz-0e61c867570dc816d6c5887c1352afc2bc14edb=
3-20140104222630-4-jaketown branch=3Dlinux-devel/devel-hourly-2014010420 BO=
OT_IMAGE=3D/kernel/i386-randconfig-nh0-01042205/0e61c867570dc816d6c5887c135=
2afc2bc14edb3/vmlinuz-3.13.0-rc6-wl-02230-g0e61c86
[    0.000000] PID hash table entries: 1024 (order: 0, 4096 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072 byt=
es)
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 230884K/261744K available (10045K kernel code, 891K =
rwdata, 4464K rodata, 1816K init, 5376K bss, 30860K reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffd36000 - 0xfffff000   (2852 kB)
[    0.000000]     pkmap   : 0xffa00000 - 0xffc00000   (2048 kB)
[    0.000000]     vmalloc : 0x907fe000 - 0xff9fe000   (1778 MB)
[    0.000000]     lowmem  : 0x80000000 - 0x8fffe000   ( 255 MB)
[    0.000000]       .init : 0x81f0c000 - 0x820d2000   (1816 kB)
[    0.000000]       .data : 0x819cfb2c - 0x81f0bc40   (5360 kB)
[    0.000000]       .text : 0x81000000 - 0x819cfb2c   (10046 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000] NR_IRQS:2304 nr_irqs:512 16
[    0.000000] CPU 0 irqstacks, hard=3D80090000 soft=3D80092000
[    0.000000] Linux version 3.13.0-rc6-wl-02230-g0e61c86 (kbuild@nhm4) (gc=
c version 4.8.1 (Debian 4.8.1-8) ) #1 SMP Sat Jan 4 22:26:13 CST 2014
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   NSC Geode by NSC
[    0.000000]   Cyrix CyrixInstead
[    0.000000]   Transmeta GenuineTMx86
[    0.000000]   Transmeta TransmetaCPU
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0xfffe max_arch_pfn =3D 0x1000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdae0-0x000fdaef] mapped at =
[800fdae0]
[    0.000000]   mpc: fdaf0-fdbe4
[    0.000000] initial memory mapped: [mem 0x00000000-0x02ffffff]
[    0.000000] Base memory trampoline at [8009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0fa00000-0x0fbfffff]
[    0.000000]  [mem 0x0fa00000-0x0fbfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x0c000000-0x0f9fffff]
[    0.000000]  [mem 0x0c000000-0x0f9fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0bffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x0bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x0fc00000-0x0fffdfff]
[    0.000000]  [mem 0x0fc00000-0x0fdfffff] page 2M
[    0.000000]  [mem 0x0fe00000-0x0fffdfff] page 4k
[    0.000000] BRK [0x02631000, 0x02631fff] PGTABLE
[    0.000000] BRK [0x02632000, 0x02633fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x0fce4000-0x0ffeffff]
[    0.000000] ACPI: RSDP 000fd950 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0fffe450 000034 (v01 BOCHS  BXPCRSDT 00000001 BXP=
C 00000001)
[    0.000000] ACPI: FACP 0fffff80 000074 (v01 BOCHS  BXPCFACP 00000001 BXP=
C 00000001)
[    0.000000] ACPI: DSDT 0fffe490 0011A9 (v01   BXPC   BXDSDT 00000001 INT=
L 20100528)
[    0.000000] ACPI: FACS 0fffff40 000040
[    0.000000] ACPI: SSDT 0ffff7a0 000796 (v01 BOCHS  BXPCSSDT 00000001 BXP=
C 00000001)
[    0.000000] ACPI: APIC 0ffff680 000080 (v01 BOCHS  BXPCAPIC 00000001 BXP=
C 00000001)
[    0.000000] ACPI: HPET 0ffff640 000038 (v01 BOCHS  BXPCHPET 00000001 BXP=
C 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 255MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 0fffe000
[    0.000000]   low ram: 0 - 0fffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, boot clock
[    0.000000] BRK [0x02634000, 0x02634fff] PGTABLE
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x00001000-0x0fffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000] free_area_init_node: node 0, pgdat 81ee9700, node_mem_map 8f=
ae4020
[    0.000000]   Normal zone: 512 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 65436 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:2 nr_cpu_ids:2 nr_n=
ode_ids:1
[    0.000000] PERCPU: Embedded 331 pages/cpu @8f84e000 s1339912 r0 d15864 =
u1355776
[    0.000000] pcpu-alloc: s1339912 r0 d15864 u1355776 alloc=3D331*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr f850980
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 64924
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled panic=3D10  prompt_ramdisk=
=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 r=
w link=3D/kernel-tests/run-queue/kvm/i386-randconfig-nh0-01042205/linux-dev=
el:devel-hourly-2014010420/.vmlinuz-0e61c867570dc816d6c5887c1352afc2bc14edb=
3-20140104222630-4-jaketown branch=3Dlinux-devel/devel-hourly-2014010420 BO=
OT_IMAGE=3D/kernel/i386-randconfig-nh0-01042205/0e61c867570dc816d6c5887c135=
2afc2bc14edb3/vmlinuz-3.13.0-rc6-wl-02230-g0e61c86
[    0.000000] PID hash table entries: 1024 (order: 0, 4096 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072 byt=
es)
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 230884K/261744K available (10045K kernel code, 891K =
rwdata, 4464K rodata, 1816K init, 5376K bss, 30860K reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffd36000 - 0xfffff000   (2852 kB)
[    0.000000]     pkmap   : 0xffa00000 - 0xffc00000   (2048 kB)
[    0.000000]     vmalloc : 0x907fe000 - 0xff9fe000   (1778 MB)
[    0.000000]     lowmem  : 0x80000000 - 0x8fffe000   ( 255 MB)
[    0.000000]       .init : 0x81f0c000 - 0x820d2000   (1816 kB)
[    0.000000]       .data : 0x819cfb2c - 0x81f0bc40   (5360 kB)
[    0.000000]       .text : 0x81000000 - 0x819cfb2c   (10046 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000] NR_IRQS:2304 nr_irqs:512 16
[    0.000000] CPU 0 irqstacks, hard=3D80090000 soft=3D80092000
[    0.000000] console [ttyS0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 3807 kB
[    0.000000]  memory used by lock dependency info: 3807 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] ------------------------
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] | Locking API testsuite:
[    0.000000] ------------------------------------------------------------=
----------------
[    0.000000] ------------------------------------------------------------=
----------------
[    0.000000]                                  | spin |wlock |rlock |mutex=
 | wsem | rsem |
[    0.000000]                                  | spin |wlock |rlock |mutex=
 | wsem | rsem |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]                      A-A deadlock:
[    0.000000]                      A-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]                  A-B-B-A deadlock:
[    0.000000]                  A-B-B-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]              A-B-B-C-C-A deadlock:
[    0.000000]              A-B-B-C-C-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]              A-B-C-A-B-C deadlock:
[    0.000000]              A-B-C-A-B-C deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]          A-B-B-C-C-D-D-A deadlock:
[    0.000000]          A-B-B-C-C-D-D-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]          A-B-C-D-B-D-D-A deadlock:
[    0.000000]          A-B-C-D-B-D-D-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]          A-B-C-D-B-C-D-A deadlock:
[    0.000000]          A-B-C-D-B-C-D-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]                     double unlock:
[    0.000000]                     double unlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                   initialize held:
[    0.000000]                   initialize held:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                  bad unlock order:
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]               recursive read-lock:
[    0.000000]               recursive read-lock:             |            =
 |  ok  |  ok  |             |             |failed|failed|

[    0.000000]            recursive read-lock #2:
[    0.000000]            recursive read-lock #2:             |            =
 |  ok  |  ok  |             |             |failed|failed|

[    0.000000]             mixed read-write-lock:
[    0.000000]             mixed read-write-lock:             |            =
 |failed|failed|             |             |failed|failed|

[    0.000000]             mixed write-read-lock:
[    0.000000]             mixed write-read-lock:             |            =
 |failed|failed|             |             |failed|failed|

[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:
[    0.000000]      hard-irqs-on + irq-safe-A/12:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/12:
[    0.000000]      soft-irqs-on + irq-safe-A/12:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]      hard-irqs-on + irq-safe-A/21:
[    0.000000]      hard-irqs-on + irq-safe-A/21:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/21:
[    0.000000]      soft-irqs-on + irq-safe-A/21:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/12:
[    0.000000]        sirq-safe-A =3D> hirqs-on/12:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/21:
[    0.000000]        sirq-safe-A =3D> hirqs-on/21:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/12:
[    0.000000]          hard-safe-A + irqs-on/12:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/12:
[    0.000000]          soft-safe-A + irqs-on/12:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/21:
[    0.000000]          hard-safe-A + irqs-on/21:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/21:
[    0.000000]          soft-safe-A + irqs-on/21:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/123:
[    0.000000]     hard-safe-A + unsafe-B #1/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/123:
[    0.000000]     soft-safe-A + unsafe-B #1/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/132:
[    0.000000]     hard-safe-A + unsafe-B #1/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/132:
[    0.000000]     soft-safe-A + unsafe-B #1/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/213:
[    0.000000]     hard-safe-A + unsafe-B #1/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/213:
[    0.000000]     soft-safe-A + unsafe-B #1/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/231:
[    0.000000]     hard-safe-A + unsafe-B #1/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/231:
[    0.000000]     soft-safe-A + unsafe-B #1/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/312:
[    0.000000]     hard-safe-A + unsafe-B #1/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/312:
[    0.000000]     soft-safe-A + unsafe-B #1/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/321:
[    0.000000]     hard-safe-A + unsafe-B #1/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/321:
[    0.000000]     soft-safe-A + unsafe-B #1/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/123:
[    0.000000]     hard-safe-A + unsafe-B #2/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/123:
[    0.000000]     soft-safe-A + unsafe-B #2/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/132:
[    0.000000]     hard-safe-A + unsafe-B #2/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/132:
[    0.000000]     soft-safe-A + unsafe-B #2/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/213:
[    0.000000]     hard-safe-A + unsafe-B #2/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/213:
[    0.000000]     soft-safe-A + unsafe-B #2/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/231:
[    0.000000]     hard-safe-A + unsafe-B #2/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/231:
[    0.000000]     soft-safe-A + unsafe-B #2/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/312:
[    0.000000]     hard-safe-A + unsafe-B #2/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/312:
[    0.000000]     soft-safe-A + unsafe-B #2/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/321:
[    0.000000]     hard-safe-A + unsafe-B #2/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/321:
[    0.000000]     soft-safe-A + unsafe-B #2/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/123:
[    0.000000]       hard-irq lock-inversion/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/123:
[    0.000000]       soft-irq lock-inversion/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/132:
[    0.000000]       hard-irq lock-inversion/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/132:
[    0.000000]       soft-irq lock-inversion/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/213:
[    0.000000]       hard-irq lock-inversion/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/213:
[    0.000000]       soft-irq lock-inversion/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/231:
[    0.000000]       hard-irq lock-inversion/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/231:
[    0.000000]       soft-irq lock-inversion/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/312:
[    0.000000]       hard-irq lock-inversion/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/312:
[    0.000000]       soft-irq lock-inversion/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/321:
[    0.000000]       hard-irq lock-inversion/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/321:
[    0.000000]       soft-irq lock-inversion/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/123:
[    0.000000]       hard-irq read-recursion/123:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/123:
[    0.000000]       soft-irq read-recursion/123:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/132:
[    0.000000]       hard-irq read-recursion/132:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/132:
[    0.000000]       soft-irq read-recursion/132:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/213:
[    0.000000]       hard-irq read-recursion/213:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/213:
[    0.000000]       soft-irq read-recursion/213:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/231:
[    0.000000]       hard-irq read-recursion/231:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/231:
[    0.000000]       soft-irq read-recursion/231:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/312:
[    0.000000]       hard-irq read-recursion/312:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/312:
[    0.000000]       soft-irq read-recursion/312:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/321:
[    0.000000]       hard-irq read-recursion/321:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/321:
[    0.000000]       soft-irq read-recursion/321:  ok  |  ok  |

[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   | Wound/wait tests |
[    0.000000]   | Wound/wait tests |
[    0.000000]   ---------------------
[    0.000000]   ---------------------
[    0.000000]                   ww api failures:
[    0.000000]                   ww api failures:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                ww contexts mixing:
[    0.000000]                ww contexts mixing:failed|failed|  ok  |  ok =
 |

[    0.000000]              finishing ww context:
[    0.000000]              finishing ww context:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                locking mismatches:
[    0.000000]                locking mismatches:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                  EDEADLK handling:
[    0.000000]                  EDEADLK handling:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]            spinlock nest unlocked:
[    0.000000]            spinlock nest unlocked:  ok  |  ok  |

[    0.000000]   -----------------------------------------------------
[    0.000000]   -----------------------------------------------------
[    0.000000]                                  |block | try  |context|
[    0.000000]                                  |block | try  |context|
[    0.000000]   -----------------------------------------------------
[    0.000000]   -----------------------------------------------------
[    0.000000]                           context:
[    0.000000]                           context:failed|failed|  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                               try:
[    0.000000]                               try:failed|failed|  ok  |  ok =
 |failed|failed|

[    0.000000]                             block:
[    0.000000]                             block:failed|failed|  ok  |  ok =
 |failed|failed|

[    0.000000]                          spinlock:
[    0.000000]                          spinlock:failed|failed|  ok  |  ok =
 |failed|failed|

[    0.000000] --------------------------------------------------------
[    0.000000] --------------------------------------------------------
[    0.000000] 141 out of 253 testcases failed, as expected. |
[    0.000000] 141 out of 253 testcases failed, as expected. |
[    0.000000] ----------------------------------------------------
[    0.000000] ----------------------------------------------------
[    0.000000] ODEBUG: 9 of 9 active objects replaced
[    0.000000] ODEBUG: 9 of 9 active objects replaced
[    0.000000] ODEBUG: selftest passed
[    0.000000] ODEBUG: selftest passed
[    0.000000] hpet clockevent registered
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 1600.028 MHz processor
[    0.000000] tsc: Detected 1600.028 MHz processor
[    0.009999] Calibrating delay loop (skipped) preset value..=20
[    0.009999] Calibrating delay loop (skipped) preset value.. 3201.39 Bogo=
MIPS (lpj=3D5333426)
3201.39 BogoMIPS (lpj=3D5333426)
[    0.013357] pid_max: default: 4096 minimum: 301
[    0.013357] pid_max: default: 4096 minimum: 301
[    0.016939] Mount-cache hash table entries: 512
[    0.016939] Mount-cache hash table entries: 512
[    0.023532] mce: CPU supports 10 MCE banks
[    0.023532] mce: CPU supports 10 MCE banks
[    0.026869] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.026869] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.026869] tlb_flushall_shift: 6
[    0.026869] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.026869] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.026869] tlb_flushall_shift: 6
[    0.034102] Freeing SMP alternatives memory: 28K (820d2000 - 820d9000)
[    0.034102] Freeing SMP alternatives memory: 28K (820d2000 - 820d9000)
[    0.048245] ACPI: Core revision 20131115
[    0.048245] ACPI: Core revision 20131115
[    0.069188] ACPI:=20
[    0.069188] ACPI: All ACPI Tables successfully acquiredAll ACPI Tables s=
uccessfully acquired

[    0.074031] Getting VERSION: 50014
[    0.074031] Getting VERSION: 50014
[    0.076716] Getting VERSION: 50014
[    0.076716] Getting VERSION: 50014
[    0.080048] Getting ID: 0
[    0.080048] Getting ID: 0
[    0.082073] Getting ID: f000000
[    0.082073] Getting ID: f000000
[    0.083387] Getting LVT0: 8700
[    0.083387] Getting LVT0: 8700
[    0.086704] Getting LVT1: 8400
[    0.086704] Getting LVT1: 8400
[    0.089010] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.089010] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.090275] enabled ExtINT on CPU#0
[    0.090275] enabled ExtINT on CPU#0
[    0.097453] ENABLING IO-APIC IRQs
[    0.097453] ENABLING IO-APIC IRQs
[    0.100038] init IO_APIC IRQs
[    0.100038] init IO_APIC IRQs
[    0.102422]  apic 0 pin 0 not connected
[    0.102422]  apic 0 pin 0 not connected
[    0.103416] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.103416] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.106770] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.106770] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.110112] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.110112] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.113445] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.113445] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.116766] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.116766] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.120111] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.120111] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.123433] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.123433] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.126760] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.126760] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.130111] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.130111] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.133461] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.133461] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.140111] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.140111] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.143447] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.143447] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.146774] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.146774] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.150088] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.150088] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.153431] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.153431] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.156755]  apic 0 pin 16 not connected
[    0.156755]  apic 0 pin 16 not connected
[    0.160019]  apic 0 pin 17 not connected
[    0.160019]  apic 0 pin 17 not connected
[    0.162841]  apic 0 pin 18 not connected
[    0.162841]  apic 0 pin 18 not connected
[    0.163355]  apic 0 pin 19 not connected
[    0.163355]  apic 0 pin 19 not connected
[    0.166685]  apic 0 pin 20 not connected
[    0.166685]  apic 0 pin 20 not connected
[    0.170015]  apic 0 pin 21 not connected
[    0.170015]  apic 0 pin 21 not connected
[    0.173349]  apic 0 pin 22 not connected
[    0.173349]  apic 0 pin 22 not connected
[    0.176686]  apic 0 pin 23 not connected
[    0.176686]  apic 0 pin 23 not connected
[    0.180241] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.180241] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.183357] smpboot: CPU0:=20
[    0.183357] smpboot: CPU0: Intel Intel Common KVM processorCommon KVM pr=
ocessor (fam: 0f, model: 06 (fam: 0f, model: 06, stepping: 01)
, stepping: 01)
[    0.200022] Using local APIC timer interrupts.
[    0.200022] calibrating APIC timer ...
[    0.200022] Using local APIC timer interrupts.
[    0.200022] calibrating APIC timer ...
[    0.206666] ... lapic delta =3D 6249451
[    0.206666] ... lapic delta =3D 6249451
[    0.206666] ... PM-Timer delta =3D 357907
[    0.206666] ... PM-Timer delta =3D 357907
[    0.206666] ... PM-Timer result ok
[    0.206666] ... PM-Timer result ok
[    0.206666] ..... delta 6249451
[    0.206666] ..... delta 6249451
[    0.206666] ..... mult: 268411903
[    0.206666] ..... mult: 268411903
[    0.206666] ..... calibration result: 3333040
[    0.206666] ..... calibration result: 3333040
[    0.206666] ..... CPU clock speed is 1599.2978 MHz.
[    0.206666] ..... CPU clock speed is 1599.2978 MHz.
[    0.206666] ..... host bus clock speed is 1000.0040 MHz.
[    0.206666] ..... host bus clock speed is 1000.0040 MHz.
[    0.206971] Performance Events:=20
[    0.206971] Performance Events: unsupported Netburst CPU model 6 unsuppo=
rted Netburst CPU model 6 no PMU driver, software events only.
no PMU driver, software events only.
[    0.223620] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.223620] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.230263] CPU 1 irqstacks, hard=3D80072000 soft=3D80074000
[    0.230263] CPU 1 irqstacks, hard=3D80072000 soft=3D80074000
[    0.233354] x86: Booting SMP configuration:
[    0.233354] x86: Booting SMP configuration:
[    0.236687] .... node  #0, CPUs: =20
[    0.236687] .... node  #0, CPUs:         #1 #1
[    0.006666] Initializing CPU#1
[    0.009999] kvm-clock: cpu 1, msr 0:fffd041, secondary cpu clock
[    0.009999] masked ExtINT on CPU#1


[    0.260432] x86: Booted up 1 node, 2 CPUs
[    0.260432] x86: Booted up 1 node, 2 CPUs
[    0.261198] KVM setup async PF for cpu 1
[    0.261198] KVM setup async PF for cpu 1
[    0.261198] kvm-stealtime: cpu 1, msr f99b980
[    0.261198] kvm-stealtime: cpu 1, msr f99b980
[    0.263379] ----------------
[    0.263379] ----------------
[    0.266679] | NMI testsuite:
[    0.266679] | NMI testsuite:
[    0.268660] --------------------
[    0.268660] --------------------
[    0.270016]   remote IPI:
[    0.270016]   remote IPI:  ok  |  ok  |

[    0.280227]    local IPI:
[    0.280227]    local IPI:  ok  |  ok  |

[    0.292553] --------------------
[    0.292553] --------------------
[    0.293351] Good, all   2 testcases passed! |
[    0.293351] Good, all   2 testcases passed! |
[    0.296682] ---------------------------------
[    0.296682] ---------------------------------
[    0.300020] smpboot: Total of 2 processors activated (6402.78 BogoMIPS)
[    0.300020] smpboot: Total of 2 processors activated (6402.78 BogoMIPS)
[    0.308351] devtmpfs: initialized
[    0.308351] devtmpfs: initialized
[    0.317180] regulator-dummy: no parameters
[    0.317180] regulator-dummy: no parameters
[    0.320619] NET: Registered protocol family 16
[    0.320619] NET: Registered protocol family 16
[    0.326022] cpuidle: using governor menu
[    0.326022] cpuidle: using governor menu
[    0.348722] ACPI: bus type PCI registered
[    0.348722] ACPI: bus type PCI registered
[    0.350633] PCI : PCI BIOS area is rw and x. Use pci=3Dnobios if you wan=
t it NX.
[    0.350633] PCI : PCI BIOS area is rw and x. Use pci=3Dnobios if you wan=
t it NX.
[    0.353399] PCI: PCI BIOS revision 2.10 entry at 0xfc6d5, last bus=3D0
[    0.353399] PCI: PCI BIOS revision 2.10 entry at 0xfc6d5, last bus=3D0
[    0.427123] ACPI: Added _OSI(Module Device)
[    0.427123] ACPI: Added _OSI(Module Device)
[    0.430028] ACPI: Added _OSI(Processor Device)
[    0.430028] ACPI: Added _OSI(Processor Device)
[    0.433180] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.433180] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.433355] ACPI: Added _OSI(Processor Aggregator Device)
[    0.433355] ACPI: Added _OSI(Processor Aggregator Device)
[    0.478170] ACPI: Interpreter enabled
[    0.478170] ACPI: Interpreter enabled
[    0.480032] ACPI Exception: AE_NOT_FOUND,=20
[    0.480032] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S1_]While evaluating Sleep State [\_S1_] (20131115/hwxface-580)
 (20131115/hwxface-580)
[    0.486699] ACPI Exception: AE_NOT_FOUND,=20
[    0.486699] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_]While evaluating Sleep State [\_S2_] (20131115/hwxface-580)
 (20131115/hwxface-580)
[    0.493484] ACPI: (supports S0 S3 S5)
[    0.493484] ACPI: (supports S0 S3 S5)
[    0.496683] ACPI: Using IOAPIC for interrupt routing
[    0.496683] ACPI: Using IOAPIC for interrupt routing
[    0.500171] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.500171] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.512388] ACPI: No dock devices found.
[    0.512388] ACPI: No dock devices found.
[    0.573007] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.573007] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.573381] acpi PNP0A03:00: _OSC: OS supports [Segments MSI]
[    0.573381] acpi PNP0A03:00: _OSC: OS supports [Segments MSI]
[    0.576811] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.576811] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.582800] PCI host bridge to bus 0000:00
[    0.582800] PCI host bridge to bus 0000:00
[    0.583362] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.583362] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.586694] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.586694] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.590026] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.590026] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.593362] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.593362] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.596692] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.596692] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.600228] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.600228] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.608868] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.608868] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.616124] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.616124] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.625903] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.625903] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.632192] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.632192] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.638029] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.638029] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.640067] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.640067] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.646861] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.646861] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.656817] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.656817] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.666834] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.666834] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.695437] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.695437] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.700696] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.700696] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.708341] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    0.708341] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    0.713372] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.713372] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.733364] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    0.733364] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    0.741558] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.741558] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.747546] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.747546] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.765648] pci_bus 0000:00: on NUMA node 0
[    0.765648] pci_bus 0000:00: on NUMA node 0
[    0.778539] ACPI: PCI Interrupt Link [LNKA] (IRQs
[    0.778539] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 5 *10 *10 11 11))

[    0.785006] ACPI: PCI Interrupt Link [LNKB] (IRQs
[    0.785006] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 5 *10 *10 11 11))

[    0.791354] ACPI: PCI Interrupt Link [LNKC] (IRQs
[    0.791354] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 5 10 10 *11 *11))

[    0.797934] ACPI: PCI Interrupt Link [LNKD] (IRQs
[    0.797934] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 5 10 10 *11 *11))

[    0.803822] ACPI: PCI Interrupt Link [LNKS] (IRQs
[    0.803822] ACPI: PCI Interrupt Link [LNKS] (IRQs *9 *9))

[    0.812285] ACPI:=20
[    0.812285] ACPI: Enabled 16 GPEs in block 00 to 0FEnabled 16 GPEs in bl=
ock 00 to 0F

[    0.813412] ACPI: \_SB_.PCI0: notify handler is installed
[    0.813412] ACPI: \_SB_.PCI0: notify handler is installed
[    0.817171] Found 1 acpi root devices
[    0.817171] Found 1 acpi root devices
[    0.825396] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.825396] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.826694] vgaarb: loaded
[    0.826694] vgaarb: loaded
[    0.830014] vgaarb: bridge control possible 0000:00:02.0
[    0.830014] vgaarb: bridge control possible 0000:00:02.0
[    0.838694] pps_core: LinuxPPS API ver. 1 registered
[    0.838694] pps_core: LinuxPPS API ver. 1 registered
[    0.840017] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.840017] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.843471] PTP clock support registered
[    0.843471] PTP clock support registered
[    0.846901] EDAC MC: Ver: 3.0.0
[    0.846901] EDAC MC: Ver: 3.0.0
[    0.854027] Advanced Linux Sound Architecture Driver Initialized.
[    0.854027] Advanced Linux Sound Architecture Driver Initialized.
[    0.856717] PCI: Using ACPI for IRQ routing
[    0.856717] PCI: Using ACPI for IRQ routing
[    0.860037] PCI: pci_cache_line_size set to 64 bytes
[    0.860037] PCI: pci_cache_line_size set to 64 bytes
[    0.867133] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.867133] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.870052] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.870052] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.878344] NET: Registered protocol family 23
[    0.878344] NET: Registered protocol family 23
[    0.880168] Bluetooth: Core ver 2.18
[    0.880168] Bluetooth: Core ver 2.18
[    0.883508] NET: Registered protocol family 31
[    0.883508] NET: Registered protocol family 31
[    0.886692] Bluetooth: HCI device and connection manager initialized
[    0.886692] Bluetooth: HCI device and connection manager initialized
[    0.890086] Bluetooth: HCI socket layer initialized
[    0.890086] Bluetooth: HCI socket layer initialized
[    0.893364] Bluetooth: L2CAP socket layer initialized
[    0.893364] Bluetooth: L2CAP socket layer initialized
[    0.896842] Bluetooth: SCO socket layer initialized
[    0.896842] Bluetooth: SCO socket layer initialized
[    0.900080] NET: Registered protocol family 8
[    0.900080] NET: Registered protocol family 8
[    0.903349] NET: Registered protocol family 20
[    0.903349] NET: Registered protocol family 20
[    0.906930] nfc: nfc_init: NFC Core ver 0.1
[    0.906930] nfc: nfc_init: NFC Core ver 0.1
[    0.910190] NET: Registered protocol family 39
[    0.910190] NET: Registered protocol family 39
[    0.915469] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    0.915469] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    0.916789] hpet0: at MMIO 0xfed00000, IRQs
[    0.916789] hpet0: at MMIO 0xfed00000, IRQs 2 2, 8, 8, 0, 0

[    0.920980] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    0.920980] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    0.933737] Switched to clocksource kvm-clock
[    0.933737] Switched to clocksource kvm-clock
[    0.938050] pnp: PnP ACPI init
[    0.938050] pnp: PnP ACPI init
[    0.942070] ACPI: bus type PNP registered
[    0.942070] ACPI: bus type PNP registered
[    0.946673] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    0.946673] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    0.955375] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.955375] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.962924] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    0.962924] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    0.973011] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.973011] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.980231] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    0.980231] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    0.988979] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.988979] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.997237] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    0.997237] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    1.005869] pnp 00:03: [dma 2]
[    1.005869] pnp 00:03: [dma 2]
[    1.009537] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.009537] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.016377] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    1.016377] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    1.025533] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.025533] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.033726] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    1.033726] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    1.042741] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.042741] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.052847] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.052847] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.062645] pnp: PnP ACPI: found 7 devices
[    1.062645] pnp: PnP ACPI: found 7 devices
[    1.067787] ACPI: bus type PNP unregistered
[    1.067787] ACPI: bus type PNP unregistered
[    1.071759] PnPBIOS: Disabled
[    1.071759] PnPBIOS: Disabled
[    1.119400] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.119400] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.123432] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.123432] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.128472] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.128472] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.133087] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.133087] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.140176] NET: Registered protocol family 2
[    1.140176] NET: Registered protocol family 2
[    1.144215] TCP established hash table entries: 2048 (order: 1, 8192 byt=
es)
[    1.144215] TCP established hash table entries: 2048 (order: 1, 8192 byt=
es)
[    1.150369] TCP bind hash table entries: 2048 (order: 4, 90112 bytes)
[    1.150369] TCP bind hash table entries: 2048 (order: 4, 90112 bytes)
[    1.155176] TCP: Hash tables configured (established 2048 bind 2048)
[    1.155176] TCP: Hash tables configured (established 2048 bind 2048)
[    1.162308] TCP: reno registered
[    1.162308] TCP: reno registered
[    1.165063] UDP hash table entries: 128 (order: 1, 12288 bytes)
[    1.165063] UDP hash table entries: 128 (order: 1, 12288 bytes)
[    1.170697] UDP-Lite hash table entries: 128 (order: 1, 12288 bytes)
[    1.170697] UDP-Lite hash table entries: 128 (order: 1, 12288 bytes)
[    1.178360] NET: Registered protocol family 1
[    1.178360] NET: Registered protocol family 1
[    1.181926] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.181926] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.187216] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.187216] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.191191] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.191191] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.198605] pci 0000:00:02.0: Boot video device
[    1.198605] pci 0000:00:02.0: Boot video device
[    1.202418] PCI: CLS 0 bytes, default 64
[    1.202418] PCI: CLS 0 bytes, default 64
[    1.207616] Unpacking initramfs...
[    1.207616] Unpacking initramfs...
[    1.795585] Freeing initrd memory: 3120K (8fce4000 - 8fff0000)
[    1.795585] Freeing initrd memory: 3120K (8fce4000 - 8fff0000)
[    1.809000] The force parameter has not been set to 1. The Iris poweroff=
 handler will not be installed.
[    1.809000] The force parameter has not been set to 1. The Iris poweroff=
 handler will not be installed.
[    1.817143] NatSemi SCx200 Driver
[    1.817143] NatSemi SCx200 Driver
[    1.825927] Initializing RT-Tester: OK
[    1.825927] Initializing RT-Tester: OK
[    1.838845] DLM installed
[    1.838845] DLM installed
[    1.841444] fuse init (API version 7.22)
[    1.841444] fuse init (API version 7.22)
[    1.846017] msgmni has been set to 457
[    1.846017] msgmni has been set to 457
[    1.908971] alg: No test for lz4 (lz4-generic)
[    1.908971] alg: No test for lz4 (lz4-generic)
[    1.913651] alg: No test for lz4hc (lz4hc-generic)
[    1.913651] alg: No test for lz4hc (lz4hc-generic)
[    1.918176] alg: No test for stdrng (krng)
[    1.918176] alg: No test for stdrng (krng)
[    1.923429] NET: Registered protocol family 38
[    1.923429] NET: Registered protocol family 38
[    1.926373] Key type asymmetric registered
[    1.926373] Key type asymmetric registered
[    1.934148] list_sort_test: start testing list_sort()
[    1.934148] list_sort_test: start testing list_sort()
[    1.944105] crc32: CRC_LE_BITS =3D 64, CRC_BE BITS =3D 64
[    1.944105] crc32: CRC_LE_BITS =3D 64, CRC_BE BITS =3D 64
[    1.947287] crc32: self tests passed, processed 225944 bytes in 440109 n=
sec
[    1.947287] crc32: self tests passed, processed 225944 bytes in 440109 n=
sec
[    1.951804] crc32c: CRC_LE_BITS =3D 64
[    1.951804] crc32c: CRC_LE_BITS =3D 64
[    1.954024] crc32c: self tests passed, processed 225944 bytes in 232449 =
nsec
[    1.954024] crc32c: self tests passed, processed 225944 bytes in 232449 =
nsec
[    2.571124] crc32_combine: 8373 self tests passed
[    2.571124] crc32_combine: 8373 self tests passed
[    2.807195] tsc: Refined TSC clocksource calibration: 1599.927 MHz
[    2.807195] tsc: Refined TSC clocksource calibration: 1599.927 MHz
[    3.274292] crc32c_combine: 8373 self tests passed
[    3.274292] crc32c_combine: 8373 self tests passed
[    3.279410] xz_dec_test: module loaded
[    3.279410] xz_dec_test: module loaded
[    3.283391] xz_dec_test: Create a device node with 'mknod xz_dec_test c =
250 0' and write .xz files to it.
[    3.283391] xz_dec_test: Create a device node with 'mknod xz_dec_test c =
250 0' and write .xz files to it.
[    3.294196] rbtree testing
[    3.294196] rbtree testing -> 24998 cycles
 -> 24998 cycles
[    4.946511] augmented rbtree testing
[    4.946511] augmented rbtree testing -> 30901 cycles
 -> 30901 cycles
[    6.998896] rivafb_setup START
[    6.998896] rivafb_setup START
[    7.005307] hgafb: HGA card not detected.
[    7.005307] hgafb: HGA card not detected.
[    7.009094] hgafb: probe of hgafb.0 failed with error -22
[    7.009094] hgafb: probe of hgafb.0 failed with error -22
[    7.015700] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    7.015700] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    7.021738] ACPI: Power Button [PWRF]
[    7.021738] ACPI: Power Button [PWRF]
[    7.029579] isapnp: Scanning for PnP cards...
[    7.029579] isapnp: Scanning for PnP cards...
[    7.459992] isapnp: No Plug & Play device found
[    7.459992] isapnp: No Plug & Play device found
[    7.744669] r3964: Philips r3964 Driver $Revision: 1.10 $
[    7.744669] r3964: Philips r3964 Driver $Revision: 1.10 $
[    7.748818] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    7.748818] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    7.786267] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    7.786267] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    7.800792] Initializing Nozomi driver 2.1d
[    7.800792] Initializing Nozomi driver 2.1d
[    7.805662] lp: driver loaded but no devices found
[    7.805662] lp: driver loaded but no devices found
[    7.812244] Non-volatile memory driver v1.3
[    7.812244] Non-volatile memory driver v1.3
[    7.818054] ppdev: user-space parallel port driver
[    7.818054] ppdev: user-space parallel port driver
[    7.822809] platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver Initial=
izing
[    7.822809] platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver Initial=
izing
[    7.843993] platform pc8736x_gpio.0: no device found
[    7.843993] platform pc8736x_gpio.0: no device found
[    7.848423] nsc_gpio initializing
[    7.848423] nsc_gpio initializing
[    7.850985] smapi::smapi_init, ERROR invalid usSmapiID
[    7.850985] smapi::smapi_init, ERROR invalid usSmapiID
[    7.856121] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is=
 not available on this machine
[    7.856121] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is=
 not available on this machine
[    7.864128] mwave: mwavedd::mwave_init: Error: Failed to initialize boar=
d data
[    7.864128] mwave: mwavedd::mwave_init: Error: Failed to initialize boar=
d data
[    7.869456] mwave: mwavedd::mwave_init: Error: Failed to initialize
[    7.869456] mwave: mwavedd::mwave_init: Error: Failed to initialize
[    7.875170] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    7.875170] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    7.881580] Hangcheck: Using getrawmonotonic().
[    7.881580] Hangcheck: Using getrawmonotonic().
[    7.887510] parport_pc 00:04: reported by Plug and Play ACPI
[    7.887510] parport_pc 00:04: reported by Plug and Play ACPI
[    7.891764] parport0: PC-style at 0x378
[    7.891764] parport0: PC-style at 0x378, irq 7, irq 7 [ [PCSPPPCSPP(,...=
)(,...)]
]
[    7.899706] lp0: using parport0 (interrupt-driven).
[    7.899706] lp0: using parport0 (interrupt-driven).
[    7.908952] dummy-irq: no IRQ given.  Use irq=3DN
[    7.908952] dummy-irq: no IRQ given.  Use irq=3DN
[    7.914170] Phantom Linux Driver, version n0.9.8, init OK
[    7.914170] Phantom Linux Driver, version n0.9.8, init OK
[    7.920241] Guest personality initialized and is inactive
[    7.920241] Guest personality initialized and is inactive
[    7.925946] VMCI host device registered (name=3Dvmci, major=3D10, minor=
=3D59)
[    7.925946] VMCI host device registered (name=3Dvmci, major=3D10, minor=
=3D59)
[    7.930793] Initialized host personality
[    7.930793] Initialized host personality
[    7.962258] mtdoops: mtd device (mtddev=3Dname/number) must be supplied
[    7.962258] mtdoops: mtd device (mtddev=3Dname/number) must be supplied
[    7.977797] L440GX flash mapping: failed to find PIIX4 ISA bridge, canno=
t continue
[    7.977797] L440GX flash mapping: failed to find PIIX4 ISA bridge, canno=
t continue
[    7.984770] device id =3D 2440
[    7.984770] device id =3D 2440
[    7.987039] device id =3D 2480
[    7.987039] device id =3D 2480
[    7.995933] device id =3D 24c0
[    7.995933] device id =3D 24c0
[    8.008586] device id =3D 24d0
[    8.008586] device id =3D 24d0
[    8.012455] device id =3D 25a1
[    8.012455] device id =3D 25a1
[    8.014870] device id =3D 2670
[    8.014870] device id =3D 2670
[    8.020309] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[    8.020309] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[    8.024970] Failed to ioremap_nocache
[    8.024970] Failed to ioremap_nocache
[    8.028260] slram: not enough parameters.
[    8.028260] slram: not enough parameters.
[    8.048874] parport0: powerup/reset Butterfly
[    8.048874] parport0: powerup/reset Butterfly
[    8.163940] parport_pc 00:04: registered master spi42
[    8.163940] parport_pc 00:04: registered master spi42
[    8.168361] spi spi42.1: spi_bitbang_setup, 66 nsec/bit
[    8.168361] spi spi42.1: spi_bitbang_setup, 66 nsec/bit
[    8.172561] spi spi42.1: setup mode 0, 8 bits/w, 15000000 Hz max --> 0
[    8.172561] spi spi42.1: setup mode 0, 8 bits/w, 15000000 Hz max --> 0
[    8.180884] parport_pc 00:04: registered child spi42.1
[    8.180884] parport_pc 00:04: registered child spi42.1
[    8.184782] parport0: dataflash at spi42.1
[    8.184782] parport0: dataflash at spi42.1
[    8.187936] parport0: AVR Butterfly
[    8.187936] parport0: AVR Butterfly
[    8.192038] HSI/SSI char device loaded
[    8.192038] HSI/SSI char device loaded
[    8.197180] bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, =
2011)
[    8.197180] bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, =
2011)
[    8.220615] libphy: Fixed MDIO Bus: probed
[    8.220615] libphy: Fixed MDIO Bus: probed
[    8.224317] vcan: Virtual CAN interface driver
[    8.224317] vcan: Virtual CAN interface driver
[    8.229548] slcan: serial line CAN interface driver
[    8.229548] slcan: serial line CAN interface driver
[    8.233223] slcan: 10 dynamic interface channels.
[    8.233223] slcan: 10 dynamic interface channels.
[    8.237680] CAN device driver interface
[    8.237680] CAN device driver interface
[    8.240864] sja1000 CAN netdevice driver
[    8.240864] sja1000 CAN netdevice driver
[    8.246934] cc770: CAN netdevice driver
[    8.246934] cc770: CAN netdevice driver
[    8.249817] cc770_isa: insufficient parameters supplied
[    8.249817] cc770_isa: insufficient parameters supplied
[    8.255486] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.18 (Sept 0=
1, 2013)
[    8.255486] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.18 (Sept 0=
1, 2013)
[    8.262516] bnx2x: Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit Ether=
net Driver bnx2x 1.78.17-0 (2013/04/11)
[    8.262516] bnx2x: Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit Ether=
net Driver bnx2x 1.78.17-0 (2013/04/11)
[    8.272075] jme: JMicron JMC2XX ethernet driver version 1.0.8
[    8.272075] jme: JMicron JMC2XX ethernet driver version 1.0.8
[    8.278744] Solarflare NET driver v4.0
[    8.278744] Solarflare NET driver v4.0
[    8.287002] tehuti: Tehuti Networks(R) Network Driver, 7.29.3
[    8.287002] tehuti: Tehuti Networks(R) Network Driver, 7.29.3
[    8.291438] tehuti: Options: hw_csum=20
[    8.291438] tehuti: Options: hw_csum=20
[    8.294389] tlan: ThunderLAN driver v1.17
[    8.294389] tlan: ThunderLAN driver v1.17
[    8.298850] tlan: 0 devices installed, PCI: 0  EISA: 0
[    8.298850] tlan: 0 devices installed, PCI: 0  EISA: 0
[    8.327559] NET3 PLIP version 2.4-parport gniibe@mri.co.jp
[    8.327559] NET3 PLIP version 2.4-parport gniibe@mri.co.jp
[    8.331863] plip0: Parallel port at 0x378, using IRQ 7.
[    8.331863] plip0: Parallel port at 0x378, using IRQ 7.
[    8.336171] PPP generic driver version 2.4.2
[    8.336171] PPP generic driver version 2.4.2
[    8.340284] PPP BSD Compression module registered
[    8.340284] PPP BSD Compression module registered
[    8.344008] PPP MPPE Compression module registered
[    8.344008] PPP MPPE Compression module registered
[    8.347973] NET: Registered protocol family 24
[    8.347973] NET: Registered protocol family 24
[    8.351620] PPTP driver version 0.8.5
[    8.351620] PPTP driver version 0.8.5
[    8.355589] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=
=3D256) (6 bit encapsulation enabled).
[    8.355589] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=
=3D256) (6 bit encapsulation enabled).
[    8.363018] CSLIP: code copyright 1989 Regents of the University of Cali=
fornia.
[    8.363018] CSLIP: code copyright 1989 Regents of the University of Cali=
fornia.
[    8.368817] hdlc: HDLC support module revision 1.22
[    8.368817] hdlc: HDLC support module revision 1.22
[    8.372855] x25_asy: X.25 async: version 0.00 ALPHA (dynamic channels, m=
ax=3D256)
[    8.372855] x25_asy: X.25 async: version 0.00 ALPHA (dynamic channels, m=
ax=3D256)
[    8.378998] DLCI driver v0.35, 4 Jan 1997, mike.mclagan@linux.org.
[    8.378998] DLCI driver v0.35, 4 Jan 1997, mike.mclagan@linux.org.
[    8.383831] SDLA driver v0.30, 12 Sep 1996, mike.mclagan@linux.org.
[    8.383831] SDLA driver v0.30, 12 Sep 1996, mike.mclagan@linux.org.
[    8.392834] LAPB Ethernet driver version 0.02
[    8.392834] LAPB Ethernet driver version 0.02
[    8.399301] ieee802154hardmac ieee802154hardmac: Added ieee802154 HardMA=
C hardware
[    8.399301] ieee802154hardmac ieee802154hardmac: Added ieee802154 HardMA=
C hardware
[    8.426453] ieee802154fakelb ieee802154fakelb: added ieee802154 hardware
[    8.426453] ieee802154fakelb ieee802154fakelb: added ieee802154 hardware
[    8.431759] I2O subsystem v1.325
[    8.431759] I2O subsystem v1.325
[    8.434110] i2o: max drivers =3D 8
[    8.434110] i2o: max drivers =3D 8
[    8.445540] I2O Configuration OSM v1.323
[    8.445540] I2O Configuration OSM v1.323
[    8.449215] I2O Bus Adapter OSM v1.317
[    8.449215] I2O Bus Adapter OSM v1.317
[    8.465217] VFIO - User Level meta-driver version: 0.3
[    8.465217] VFIO - User Level meta-driver version: 0.3
[    8.469493] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    8.469493] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    8.482656] serio: i8042 KBD port at 0x60,0x64 irq 1
[    8.482656] serio: i8042 KBD port at 0x60,0x64 irq 1
[    8.488406] serio: i8042 AUX port at 0x60,0x64 irq 12
[    8.488406] serio: i8042 AUX port at 0x60,0x64 irq 12
[    8.496011] inport.c: Didn't find InPort mouse at 0x23c
[    8.496011] inport.c: Didn't find InPort mouse at 0x23c
[    8.500243] logibm.c: Didn't find Logitech busmouse at 0x23c
[    8.500243] logibm.c: Didn't find Logitech busmouse at 0x23c
[    8.507813] apanel: Fujitsu BIOS signature 'FJKEYINF' not found...
[    8.507813] apanel: Fujitsu BIOS signature 'FJKEYINF' not found...
[    8.516816] ideapad_slidebar: DMI does not match
[    8.516816] ideapad_slidebar: DMI does not match
[    8.521483] rtc_cmos 00:00: RTC can wake from S4
[    8.521483] rtc_cmos 00:00: RTC can wake from S4
[    8.526610] rtc (null): alarm rollover: day
[    8.526610] rtc (null): alarm rollover: day
[    8.531033] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[    8.531033] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[    8.536976] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpet =
irqs
[    8.536976] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpet =
irqs
[    8.548788] i2c /dev entries driver
[    8.548788] i2c /dev entries driver
[    8.573171] pps pps0: new PPS source ktimer
[    8.573171] pps pps0: new PPS source ktimer
[    8.576612] pps pps0: ktimer PPS source registered
[    8.576612] pps pps0: ktimer PPS source registered
[    8.580593] pps_ldisc: PPS line discipline registered
[    8.580593] pps_ldisc: PPS line discipline registered
[    8.587536] pps_parport: parallel port PPS client
[    8.587536] pps_parport: parallel port PPS client
[    8.591842] parport0: cannot grant exclusive access for device pps_parpo=
rt
[    8.591842] parport0: cannot grant exclusive access for device pps_parpo=
rt
[    8.598426] pps_parport: couldn't register with parport0
[    8.598426] pps_parport: couldn't register with parport0
[    8.603259] Driver for 1-wire Dallas network protocol.
[    8.603259] Driver for 1-wire Dallas network protocol.
[    8.614454] applesmc: supported laptop not found!
[    8.614454] applesmc: supported laptop not found!
[    8.618927] applesmc: driver init failed (ret=3D-19)!
[    8.618927] applesmc: driver init failed (ret=3D-19)!
[    8.629587] pc87360: PC8736x not detected, module not inserted
[    8.629587] pc87360: PC8736x not detected, module not inserted
[    8.636377] intel_powerclamp: Intel powerclamp does not run on family 15=
 model 6
[    8.636377] intel_powerclamp: Intel powerclamp does not run on family 15=
 model 6
[    8.645800] advantechwdt: WDT driver for Advantech single board computer=
 initialising
[    8.645800] advantechwdt: WDT driver for Advantech single board computer=
 initialising
[    8.654512] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D1)
[    8.654512] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D1)
[    8.660163] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
[    8.660163] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
[    8.665089] alim7101_wdt: ALi M7101 PMU not present - WDT not set
[    8.665089] alim7101_wdt: ALi M7101 PMU not present - WDT not set
[    8.670469] sp5100_tco: SP5100/SB800 TCO WatchDog Timer Driver v0.05
[    8.670469] sp5100_tco: SP5100/SB800 TCO WatchDog Timer Driver v0.05
[    8.677572] sc520_wdt: cannot register miscdev on minor=3D130 (err=3D-16)
[    8.677572] sc520_wdt: cannot register miscdev on minor=3D130 (err=3D-16)
[    8.683917] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[    8.683917] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[    8.691425] i6300esb: cannot register miscdev on minor=3D130 (err=3D-16)
[    8.691425] i6300esb: cannot register miscdev on minor=3D130 (err=3D-16)
[    8.697112] i6300ESB timer: probe of 0000:00:04.0 failed with error -16
[    8.697112] i6300ESB timer: probe of 0000:00:04.0 failed with error -16
[    8.702792] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[    8.702792] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[    8.708211] sc1200wdt: build 20020303
[    8.708211] sc1200wdt: build 20020303
[    8.712112] sc1200wdt: io parameter must be specified
[    8.712112] sc1200wdt: io parameter must be specified
[    8.716939] pc87413_wdt: Version 1.1 at io 0x2E
[    8.716939] pc87413_wdt: Version 1.1 at io 0x2E
[    8.721421] pc87413_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    8.721421] pc87413_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    8.726912] nv_tco: NV TCO WatchDog Timer Driver v0.01
[    8.726912] nv_tco: NV TCO WatchDog Timer Driver v0.01
[    8.732890] sbc60xxwdt: I/O address 0x0443 already in use
[    8.732890] sbc60xxwdt: I/O address 0x0443 already in use
[    8.738429] sbc8360: failed to register misc device
[    8.738429] sbc8360: failed to register misc device
[    8.742495] cpu5wdt: misc_register failed
[    8.742495] cpu5wdt: misc_register failed
[    8.746096] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 in=
itialising...
[    8.746096] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 in=
itialising...
[    8.754014] smsc37b787_wdt: Unable to register miscdev on minor 130
[    8.754014] smsc37b787_wdt: Unable to register miscdev on minor 130
[    8.759674] w83627hf_wdt: WDT driver for the Winbond(TM) W83627HF/THF/HG=
/DHG Super I/O chip initialising
[    8.759674] w83627hf_wdt: WDT driver for the Winbond(TM) W83627HF/THF/HG=
/DHG Super I/O chip initialising
[    8.768275] w83627hf_wdt: Watchdog already running. Resetting timeout to=
 60 sec
[    8.768275] w83627hf_wdt: Watchdog already running. Resetting timeout to=
 60 sec
[    8.775179] watchdog: W83627HF Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[    8.775179] watchdog: W83627HF Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[    8.781996] watchdog: W83627HF Watchdog: a legacy watchdog module is pro=
bably present.
[    8.781996] watchdog: W83627HF Watchdog: a legacy watchdog module is pro=
bably present.
[    8.808736] w83627hf_wdt: initialized. timeout=3D60 sec (nowayout=3D1)
[    8.808736] w83627hf_wdt: initialized. timeout=3D60 sec (nowayout=3D1)
[    8.813494] w83697hf_wdt: WDT driver for W83697HF/HG initializing
[    8.813494] w83697hf_wdt: WDT driver for W83697HF/HG initializing
[    8.818274] w83697hf_wdt: watchdog not found at address 0x2e
[    8.818274] w83697hf_wdt: watchdog not found at address 0x2e
[    8.822619] w83697hf_wdt: No W83697HF/HG could be found
[    8.822619] w83697hf_wdt: No W83697HF/HG could be found
[    8.827265] w83697ug_wdt: WDT driver for the Winbond(TM) W83697UG/UF Sup=
er I/O chip initialising
[    8.827265] w83697ug_wdt: WDT driver for the Winbond(TM) W83697UG/UF Sup=
er I/O chip initialising
[    8.833900] w83697ug_wdt: No W83697UG/UF could be found
[    8.833900] w83697ug_wdt: No W83697UG/UF could be found
[    8.839673] w83977f_wdt: driver v1.00
[    8.839673] w83977f_wdt: driver v1.00
[    8.842661] w83977f_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    8.842661] w83977f_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    8.849488] Bluetooth: Virtual HCI driver ver 1.4
[    8.849488] Bluetooth: Virtual HCI driver ver 1.4
[    8.855264] Bluetooth: HCI UART driver ver 2.2
[    8.855264] Bluetooth: HCI UART driver ver 2.2
[    8.875925] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    8.875925] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    8.886281] ledtrig-cpu: registered to indicate activity on CPUs
[    8.886281] ledtrig-cpu: registered to indicate activity on CPUs
[    8.921103] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[    8.921103] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[    8.939794] cs5535-clockevt: Could not allocate MFGPT timer
[    8.939794] cs5535-clockevt: Could not allocate MFGPT timer
[    8.943951] hidraw: raw HID events driver (C) Jiri Kosina
[    8.943951] hidraw: raw HID events driver (C) Jiri Kosina
[    8.966973] panel: could not claim access to parport0. Aborting.
[    8.966973] panel: could not claim access to parport0. Aborting.
[    8.971348] panel: driver version 0.9.5 not yet registered
[    8.971348] panel: driver version 0.9.5 not yet registered
[    8.975162] vme_user: VME User Space Access Driver
[    8.975162] vme_user: VME User Space Access Driver
[    8.988626] vme_user: No cards, skipping registration
[    8.988626] vme_user: No cards, skipping registration
[    9.005878] Loading crystalhd 0.9.27
[    9.005878] Loading crystalhd 0.9.27
[    9.013195] cxt1e1: $Release: PMCC4_3_1B,  Copyright (c) 2008 One Stop S=
ystems$
[    9.013195] cxt1e1: $Release: PMCC4_3_1B,  Copyright (c) 2008 One Stop S=
ystems$
[    9.023917] cxt1e1: No boards found
[    9.023917] cxt1e1: No boards found
[    9.038944] dgnc:=20
[    9.038944] dgnc: dgnc-1.3-16, Digi International Part Number 40002369_F
dgnc-1.3-16, Digi International Part Number 40002369_F
[    9.043741] dgnc:=20
[    9.043741] dgnc: For the tools package or updated drivers please visit =
http://www.digi.com
For the tools package or updated drivers please visit http://www.digi.com
[    9.050736] dgap:=20
[    9.050736] dgap: dgap-1.3-16, Digi International Part Number 40002347_C
dgap-1.3-16, Digi International Part Number 40002347_C
[    9.055410] dgap:=20
[    9.055410] dgap: For the tools package or updated drivers please visit =
http://www.digi.com
For the tools package or updated drivers please visit http://www.digi.com
[    9.081183] no UART detected at 0x1
[    9.081183] no UART detected at 0x1
[    9.084863] snd_portman2x4: probe of snd_portman2x4.0 failed with error =
-5
[    9.084863] snd_portman2x4: probe of snd_portman2x4.0 failed with error =
-5
[    9.091588] isa adlib.0: please specify port
[    9.091588] isa adlib.0: please specify port
[    9.108114] isa ad1848.0: please specify port
[    9.108114] isa ad1848.0: please specify port
[    9.124237] isa azt1605.0: please specify port
[    9.124237] isa azt1605.0: please specify port
[    9.129874] isa azt2316.0: please specify port
[    9.129874] isa azt2316.0: please specify port
[   11.906961] input: ImPS/2 Generic Wheel Mouse as /devices/platform/i8042=
/serio1/input/input3
[   11.906961] input: ImPS/2 Generic Wheel Mouse as /devices/platform/i8042=
/serio1/input/input3
[   11.915424] Error: Driver 'msnd_pinnacle' is already registered, abortin=
g...
[   11.915424] Error: Driver 'msnd_pinnacle' is already registered, abortin=
g...
[   11.918875] isa sb8.0: please specify irq
[   11.918875] isa sb8.0: please specify irq
[   11.935474] NET: Registered protocol family 26
[   11.935474] NET: Registered protocol family 26
[   11.941593] ipip: IPv4 over IPv4 tunneling driver
[   11.941593] ipip: IPv4 over IPv4 tunneling driver
[   11.948700] gre: GRE over IPv4 demultiplexor driver
[   11.948700] gre: GRE over IPv4 demultiplexor driver
[   11.954863] TCP: cubic registered
[   11.954863] TCP: cubic registered
[   11.958260] Initializing XFRM netlink socket
[   11.958260] Initializing XFRM netlink socket
[   11.962468] NET: Registered protocol family 10
[   11.962468] NET: Registered protocol family 10
[   11.968156] mip6: Mobile IPv6
[   11.968156] mip6: Mobile IPv6
[   11.972776] INFO: trying to register non-static key.
[   11.972776] INFO: trying to register non-static key.
[   11.973950] the code is fine but needs lockdep annotation.
[   11.973950] the code is fine but needs lockdep annotation.
[   11.973950] turning off the locking correctness validator.
[   11.973950] turning off the locking correctness validator.
[   11.973950] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.13.0-rc6-wl-0223=
0-g0e61c86 #1
[   11.973950] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.13.0-rc6-wl-0223=
0-g0e61c86 #1
[   11.973950]  00000000
[   11.973950]  00000000 00000000 00000000 8001fbac 8001fbac 819bbaff 819bb=
aff 00000000 00000000 8001fbe8 8001fbe8 81078dcf 81078dcf 81d1d914 81d1d914

[   11.973950]  9bcbfd5c
[   11.973950]  9bcbfd5c 9bcc0033 9bcc0033 00000004 00000004 00000001 00000=
001 9bcc1295 9bcc1295 00000004 00000004 00000001 00000001 80015000 80015000

[   11.973950]  00000000
[   11.973950]  00000000 80015000 80015000 8f997728 8f997728 00000000 00000=
000 8001fc14 8001fc14 81079fa7 81079fa7 00000002 00000002 00000001 00000001

[   11.973950] Call Trace:
[   11.973950] Call Trace:
[   11.973950]  [<819bbaff>] dump_stack+0x48/0x60
[   11.973950]  [<819bbaff>] dump_stack+0x48/0x60
[   11.973950]  [<81078dcf>] __lock_acquire.isra.22+0x1bf/0xc10
[   11.973950]  [<81078dcf>] __lock_acquire.isra.22+0x1bf/0xc10
[   11.973950]  [<81079fa7>] lock_acquire+0x77/0xa0
[   11.973950]  [<81079fa7>] lock_acquire+0x77/0xa0
[   11.973950]  [<817ca7ab>] ? dev_get_stats+0xcb/0x130
[   11.973950]  [<817ca7ab>] ? dev_get_stats+0xcb/0x130
[   11.973950]  [<8183862d>] ip_tunnel_get_stats64+0x6d/0x230
[   11.973950]  [<8183862d>] ip_tunnel_get_stats64+0x6d/0x230
[   11.973950]  [<817ca7ab>] ? dev_get_stats+0xcb/0x130
[   11.973950]  [<817ca7ab>] ? dev_get_stats+0xcb/0x130
[   11.973950]  [<811cf8c1>] ? __nla_reserve+0x21/0xd0
[   11.973950]  [<811cf8c1>] ? __nla_reserve+0x21/0xd0
[   11.973950]  [<817ca7ab>] dev_get_stats+0xcb/0x130
[   11.973950]  [<817ca7ab>] dev_get_stats+0xcb/0x130
[   11.973950]  [<817d5409>] rtnl_fill_ifinfo+0x569/0xe20
[   11.973950]  [<817d5409>] rtnl_fill_ifinfo+0x569/0xe20
[   11.973950]  [<810352e0>] ? kvm_clock_read+0x20/0x30
[   11.973950]  [<810352e0>] ? kvm_clock_read+0x20/0x30
[   11.973950]  [<81008e38>] ? sched_clock+0x8/0x10
[   11.973950]  [<81008e38>] ? sched_clock+0x8/0x10
[   11.973950]  [<8106ba45>] ? sched_clock_local+0x25/0x170
[   11.973950]  [<8106ba45>] ? sched_clock_local+0x25/0x170
[   11.973950]  [<810da6bd>] ? __kmalloc+0x3d/0x90
[   11.973950]  [<810da6bd>] ? __kmalloc+0x3d/0x90
[   11.973950]  [<817b8c10>] ? __kmalloc_reserve.isra.41+0x20/0x70
[   11.973950]  [<817b8c10>] ? __kmalloc_reserve.isra.41+0x20/0x70
[   11.973950]  [<810da81a>] ? slob_alloc_node+0x2a/0x60
[   11.973950]  [<810da81a>] ? slob_alloc_node+0x2a/0x60
[   11.973950]  [<817b919a>] ? __alloc_skb+0x6a/0x2b0
[   11.973950]  [<817b919a>] ? __alloc_skb+0x6a/0x2b0
[   11.973950]  [<817d8795>] rtmsg_ifinfo+0x65/0xe0
[   11.973950]  [<817d8795>] rtmsg_ifinfo+0x65/0xe0
[   11.973950]  [<817cbd31>] register_netdevice+0x531/0x5a0
[   11.973950]  [<817cbd31>] register_netdevice+0x531/0x5a0
[   11.973950]  [<81892b87>] ? ip6_tnl_get_cap+0x27/0x90
[   11.973950]  [<81892b87>] ? ip6_tnl_get_cap+0x27/0x90
[   11.973950]  [<817cbdb6>] register_netdev+0x16/0x30
[   11.973950]  [<817cbdb6>] register_netdev+0x16/0x30
[   11.973950]  [<81f574a6>] vti6_init_net+0x1c4/0x1d4
[   11.973950]  [<81f574a6>] vti6_init_net+0x1c4/0x1d4
[   11.973950]  [<81f573af>] ? vti6_init_net+0xcd/0x1d4
[   11.973950]  [<81f573af>] ? vti6_init_net+0xcd/0x1d4
[   11.973950]  [<817c16df>] ops_init.constprop.11+0x17f/0x1c0
[   11.973950]  [<817c16df>] ops_init.constprop.11+0x17f/0x1c0
[   11.973950]  [<817c1779>] register_pernet_operations.isra.9+0x59/0x90
[   11.973950]  [<817c1779>] register_pernet_operations.isra.9+0x59/0x90
[   11.973950]  [<817c18d1>] register_pernet_device+0x21/0x60
[   11.973950]  [<817c18d1>] register_pernet_device+0x21/0x60
[   11.973950]  [<81f574b6>] ? vti6_init_net+0x1d4/0x1d4
[   11.973950]  [<81f574b6>] ? vti6_init_net+0x1d4/0x1d4
[   11.973950]  [<81f574c7>] vti6_tunnel_init+0x11/0x68
[   11.973950]  [<81f574c7>] vti6_tunnel_init+0x11/0x68
[   11.973950]  [<81f572a1>] ? mip6_init+0x73/0xb4
[   11.973950]  [<81f572a1>] ? mip6_init+0x73/0xb4
[   11.973950]  [<81f0cba4>] do_one_initcall+0xbb/0x15b
[   11.973950]  [<81f0cba4>] do_one_initcall+0xbb/0x15b
[   11.973950]  [<811a00d8>] ? sha_transform+0x528/0x1150
[   11.973950]  [<811a00d8>] ? sha_transform+0x528/0x1150
[   11.973950]  [<81f0c544>] ? repair_env_string+0x12/0x51
[   11.973950]  [<81f0c544>] ? repair_env_string+0x12/0x51
[   11.973950]  [<8105c30d>] ? parse_args+0x2ad/0x440
[   11.973950]  [<8105c30d>] ? parse_args+0x2ad/0x440
[   11.973950]  [<810546be>] ? __usermodehelper_set_disable_depth+0x3e/0x50
[   11.973950]  [<810546be>] ? __usermodehelper_set_disable_depth+0x3e/0x50
[   11.973950]  [<81f0cd27>] kernel_init_freeable+0xe3/0x182
[   11.973950]  [<81f0cd27>] kernel_init_freeable+0xe3/0x182
[   11.973950]  [<81f0c532>] ? do_early_param+0x7a/0x7a
[   11.973950]  [<81f0c532>] ? do_early_param+0x7a/0x7a
[   11.973950]  [<819b5b1b>] kernel_init+0xb/0x100
[   11.973950]  [<819b5b1b>] kernel_init+0xb/0x100
[   11.973950]  [<819cebf7>] ret_from_kernel_thread+0x1b/0x28
[   11.973950]  [<819cebf7>] ret_from_kernel_thread+0x1b/0x28
[   11.973950]  [<819b5b10>] ? rest_init+0xc0/0xc0
[   11.973950]  [<819b5b10>] ? rest_init+0xc0/0xc0
[   12.162864] NET: Registered protocol family 17
[   12.162864] NET: Registered protocol family 17
[   12.171349] NET: Registered protocol family 9
[   12.171349] NET: Registered protocol family 9
[   12.174420] X.25 for Linux Version 0.2
[   12.174420] X.25 for Linux Version 0.2
[   12.176936] can: controller area network core (rev 20120528 abi 9)
[   12.176936] can: controller area network core (rev 20120528 abi 9)
[   12.182943] can: failed to create /proc/net/can . CONFIG_PROC_FS missing?
[   12.182943] can: failed to create /proc/net/can . CONFIG_PROC_FS missing?
[   12.188753] NET: Registered protocol family 29
[   12.188753] NET: Registered protocol family 29
[   12.193169] can: raw protocol (rev 20120528)
[   12.193169] can: raw protocol (rev 20120528)
[   12.196187] can: netlink gateway (rev 20130117) max_hops=3D1
[   12.196187] can: netlink gateway (rev 20130117) max_hops=3D1
[   12.202614] IrCOMM protocol (Dag Brattli)
[   12.202614] IrCOMM protocol (Dag Brattli)
[   12.219450] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   12.219450] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   12.222983] Bluetooth: BNEP filters: multicast
[   12.222983] Bluetooth: BNEP filters: multicast
[   12.225940] Bluetooth: BNEP socket layer initialized
[   12.225940] Bluetooth: BNEP socket layer initialized
[   12.229232] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[   12.229232] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[   12.233726] Bluetooth: HIDP socket layer initialized
[   12.233726] Bluetooth: HIDP socket layer initialized
[   12.238626] l2tp_core: L2TP core driver, V2.0
[   12.238626] l2tp_core: L2TP core driver, V2.0
[   12.253687] 8021q: 802.1Q VLAN Support v1.8
[   12.253687] 8021q: 802.1Q VLAN Support v1.8
[   12.257586] DCCP: Activated CCID 2 (TCP-like)
[   12.257586] DCCP: Activated CCID 2 (TCP-like)
[   12.261352] sctp: Hash tables configured (established 1365 bind 1489)
[   12.261352] sctp: Hash tables configured (established 1365 bind 1489)
[   12.267050] rds_page_remainder_cpu_notify(): cpu 0 action 0x7
[   12.267050] rds_page_remainder_cpu_notify(): cpu 0 action 0x7
[   12.270930] rds_page_remainder_cpu_notify(): cpu 1 action 0x7
[   12.270930] rds_page_remainder_cpu_notify(): cpu 1 action 0x7
[   12.274925] tipc: Activated (version 2.0.0)
[   12.274925] tipc: Activated (version 2.0.0)
[   12.278989] NET: Registered protocol family 30
[   12.278989] NET: Registered protocol family 30
[   12.282416] tipc: Started in single node mode
[   12.282416] tipc: Started in single node mode
[   12.285470] NET: Registered protocol family 37
[   12.285470] NET: Registered protocol family 37
[   12.288563] NET: Registered protocol family 36
[   12.288563] NET: Registered protocol family 36
[   12.292642] Key type dns_resolver registered
[   12.292642] Key type dns_resolver registered
[   12.295613] Key type ceph registered
[   12.295613] Key type ceph registered
[   12.298351] libceph: loaded (mon/osd proto 15/24)
[   12.298351] libceph: loaded (mon/osd proto 15/24)
[   12.301534] mpls_gso: MPLS GSO support
[   12.301534] mpls_gso: MPLS GSO support
[   12.308968]=20
[   12.308968] printing PIC contents
[   12.308968]=20
[   12.308968] printing PIC contents
[   12.312254] ... PIC  IMR: ffff
[   12.312254] ... PIC  IMR: ffff
[   12.314340] ... PIC  IRR: 1113
[   12.314340] ... PIC  IRR: 1113
[   12.316440] ... PIC  ISR: 0000
[   12.316440] ... PIC  ISR: 0000
[   12.318492] ... PIC ELCR: 0c00
[   12.318492] ... PIC ELCR: 0c00
[   12.320636] printing local APIC contents on CPU#0/0:
[   12.320636] printing local APIC contents on CPU#0/0:
[   12.323933] ... APIC ID:      00000000 (0)
[   12.323933] ... APIC ID:      00000000 (0)
[   12.323933] ... APIC VERSION: 00050014
[   12.323933] ... APIC VERSION: 00050014
[   12.323933] ... APIC TASKPRI: 00000000 (00)
[   12.323933] ... APIC TASKPRI: 00000000 (00)
[   12.323933] ... APIC PROCPRI: 00000000
[   12.323933] ... APIC PROCPRI: 00000000
[   12.323933] ... APIC LDR: 01000000
[   12.323933] ... APIC LDR: 01000000
[   12.323933] ... APIC DFR: ffffffff
[   12.323933] ... APIC DFR: ffffffff
[   12.323933] ... APIC SPIV: 000001ff
[   12.323933] ... APIC SPIV: 000001ff
[   12.323933] ... APIC ISR field:
[   12.323933] ... APIC ISR field:
[   12.323933] 00000000
[   12.323933] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[   12.323933] ... APIC TMR field:
[   12.323933] ... APIC TMR field:
[   12.323933] 00000000
[   12.323933] 000000000200000002000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[   12.323933] ... APIC IRR field:
[   12.323933] ... APIC IRR field:
[   12.323933] 00000000
[   12.323933] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000800000008000

[   12.323933] ... APIC ESR: 00000000
[   12.323933] ... APIC ESR: 00000000
[   12.323933] ... APIC ICR: 000008fd
[   12.323933] ... APIC ICR: 000008fd
[   12.323933] ... APIC ICR2: 02000000
[   12.323933] ... APIC ICR2: 02000000
[   12.323933] ... APIC LVTT: 000000ef
[   12.323933] ... APIC LVTT: 000000ef
[   12.323933] ... APIC LVTPC: 00010000
[   12.323933] ... APIC LVTPC: 00010000
[   12.323933] ... APIC LVT0: 00010700
[   12.323933] ... APIC LVT0: 00010700
[   12.323933] ... APIC LVT1: 00000400
[   12.323933] ... APIC LVT1: 00000400
[   12.323933] ... APIC LVTERR: 000000fe
[   12.323933] ... APIC LVTERR: 000000fe
[   12.323933] ... APIC TMICT: 00031253
[   12.323933] ... APIC TMICT: 00031253
[   12.323933] ... APIC TMCCT: 00000000
[   12.323933] ... APIC TMCCT: 00000000
[   12.323933] ... APIC TDCR: 00000003
[   12.323933] ... APIC TDCR: 00000003
[   12.323933]=20
[   12.323933]=20
[   12.402994] number of MP IRQ sources: 15.
[   12.402994] number of MP IRQ sources: 15.
[   12.407454] number of IO-APIC #0 registers: 24.
[   12.407454] number of IO-APIC #0 registers: 24.
[   12.413245] testing the IO APIC.......................
[   12.413245] testing the IO APIC.......................
[   12.419266] IO APIC #0......
[   12.419266] IO APIC #0......
[   12.423021] .... register #00: 00000000
[   12.423021] .... register #00: 00000000
[   12.427775] .......    : physical APIC id: 00
[   12.427775] .......    : physical APIC id: 00
[   12.432556] .......    : Delivery Type: 0
[   12.432556] .......    : Delivery Type: 0
[   12.437604] .......    : LTS          : 0
[   12.437604] .......    : LTS          : 0
[   12.443816] .... register #01: 00170011
[   12.443816] .... register #01: 00170011
[   12.448150] .......     : max redirection entries: 17
[   12.448150] .......     : max redirection entries: 17
[   12.453605] .......     : PRQ implemented: 0
[   12.453605] .......     : PRQ implemented: 0
[   12.459690] .......     : IO APIC version: 11
[   12.459690] .......     : IO APIC version: 11
[   12.465136] .... register #02: 00000000
[   12.465136] .... register #02: 00000000
[   12.473169] .......     : arbitration: 00
[   12.473169] .......     : arbitration: 00
[   12.477482] .... IRQ redirection table:
[   12.477482] .... IRQ redirection table:
[   12.482237] 1    0    0   0   0    0    0    00
[   12.482237] 1    0    0   0   0    0    0    00
[   12.487789] 0    0    0   0   0    1    1    31
[   12.487789] 0    0    0   0   0    1    1    31
[   12.492683] 0    0    0   0   0    1    1    30
[   12.492683] 0    0    0   0   0    1    1    30
[   12.498996] 0    0    0   0   0    1    1    33
[   12.498996] 0    0    0   0   0    1    1    33
[   12.504197] 1    0    0   0   0    1    1    34
[   12.504197] 1    0    0   0   0    1    1    34
[   12.509038] 1    1    0   0   0    1    1    35
[   12.509038] 1    1    0   0   0    1    1    35
[   12.517079] 0    0    0   0   0    1    1    36
[   12.517079] 0    0    0   0   0    1    1    36
[   12.523338] 0    0    0   0   0    1    1    37
[   12.523338] 0    0    0   0   0    1    1    37
[   12.527307] 0    0    0   0   0    1    1    38
[   12.527307] 0    0    0   0   0    1    1    38
[   12.532315] 0    1    0   0   0    1    1    39
[   12.532315] 0    1    0   0   0    1    1    39
[   12.537782] 1    1    0   0   0    1    1    3A
[   12.537782] 1    1    0   0   0    1    1    3A
[   12.543164] 1    1    0   0   0    1    1    3B
[   12.543164] 1    1    0   0   0    1    1    3B
[   12.548165] 0    0    0   0   0    1    1    3C
[   12.548165] 0    0    0   0   0    1    1    3C
[   12.554281] 0    0    0   0   0    1    1    3D
[   12.554281] 0    0    0   0   0    1    1    3D
[   12.562485] 0    0    0   0   0    1    1    3E
[   12.562485] 0    0    0   0   0    1    1    3E
[   12.567478] 0    0    0   0   0    1    1    3F
[   12.567478] 0    0    0   0   0    1    1    3F
[   12.573275] 1    0    0   0   0    0    0    00
[   12.573275] 1    0    0   0   0    0    0    00
[   12.578507] 1    0    0   0   0    0    0    00
[   12.578507] 1    0    0   0   0    0    0    00
[   12.582256] 1    0    0   0   0    0    0    00
[   12.582256] 1    0    0   0   0    0    0    00
[   12.587488] 1    0    0   0   0    0    0    00
[   12.587488] 1    0    0   0   0    0    0    00
[   12.592365] 1    0    0   0   0    0    0    00
[   12.592365] 1    0    0   0   0    0    0    00
[   12.597663] 1    0    0   0   0    0    0    00
[   12.597663] 1    0    0   0   0    0    0    00
[   12.603604] 1    0    0   0   0    0    0    00
[   12.603604] 1    0    0   0   0    0    0    00
[   12.608303] 1    0    0   0   0    0    0    00
[   12.608303] 1    0    0   0   0    0    0    00
[   12.613260] IRQ to pin mappings:
[   12.613260] IRQ to pin mappings:
[   12.617302] IRQ0=20
[   12.617302] IRQ0 -> 0:2-> 0:2

[   12.619737] IRQ1=20
[   12.619737] IRQ1 -> 0:1-> 0:1

[   12.623322] IRQ3=20
[   12.623322] IRQ3 -> 0:3-> 0:3

[   12.625387] IRQ4=20
[   12.625387] IRQ4 -> 0:4-> 0:4

[   12.629229] IRQ5=20
[   12.629229] IRQ5 -> 0:5-> 0:5

[   12.632630] IRQ6=20
[   12.632630] IRQ6 -> 0:6-> 0:6

[   12.635050] IRQ7=20
[   12.635050] IRQ7 -> 0:7-> 0:7

[   12.638589] IRQ8=20
[   12.638589] IRQ8 -> 0:8-> 0:8

[   12.641992] IRQ9=20
[   12.641992] IRQ9 -> 0:9-> 0:9

[   12.644327] IRQ10=20
[   12.644327] IRQ10 -> 0:10-> 0:10

[   12.647890] IRQ11=20
[   12.647890] IRQ11 -> 0:11-> 0:11

[   12.651598] IRQ12=20
[   12.651598] IRQ12 -> 0:12-> 0:12

[   12.654462] IRQ13=20
[   12.654462] IRQ13 -> 0:13-> 0:13

[   12.657650] IRQ14=20
[   12.657650] IRQ14 -> 0:14-> 0:14

[   12.661240] IRQ15=20
[   12.661240] IRQ15 -> 0:15-> 0:15

[   12.663798] .................................... done.
[   12.663798] .................................... done.
[   12.669714] Using IPI No-Shortcut mode
[   12.669714] Using IPI No-Shortcut mode
[   12.676553] bootconsole [earlyser0] disabled
[   12.676553] bootconsole [earlyser0] disabled
[   12.680389] registered taskstats version 1
[   12.683816] Key type trusted registered
[   12.686777] RIO: rio_register_scan for mport_id=3D-1
[   12.689236] console [netcon0] enabled
[   12.691030] netconsole: network logging started
[   12.693299] rtc_cmos 00:00: setting system clock to 2014-01-04 22:27:07 =
UTC (1388874427)
[   12.696493] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   12.698957] EDD information not available.
[   12.701073] Unregister pv shared memory for cpu 0
[   12.747057] CPU 0 is now offline
[   12.748360] ALSA device list:
[   12.749916]   #0: Virtual MIDI Card 1
[   12.758444] Freeing unused kernel memory: 1816K (81f0c000 - 820d2000)

mount: mounting proc on /proc failed: No such device
/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: No such file or directory

Please wait: booting...
mount: mounting proc on /proc failed: No such device
grep: /proc/filesystems: No such file or directory
Starting Bootlog daemon: bootlogd: cannot allocate pseudo tty: No such file=
 or directory
bootlogd.
mount: can't read '/proc/mounts': No such file or directory
/etc/rcS.d/S37populate-volatile.sh: line 172: /proc/cmdline: No such file o=
r directory
grep: /proc/filesystems: No such file or directory
Configuring network interfaces... done.
hwclock: can't open '/dev/misc/rtc': No such file or directory
Running postinst /etc/rpm-postinsts/100...

mount: no /proc/mounts
wfg: skip syslogd
Kernel tests: Boot OK!
Kernel tests: Boot OK!
mount: mounting proc on /proc failed: No such device
/etc/rc5.d/S99-rc.local: line 19: /proc/195/oom_score_adj: No such file or =
directory
sed: /lib/modules/3.13.0-rc6-wl-02230-g0e61c86/modules.dep: No such file or=
 directory
xargs: modprobe: No such file or directory
run-parts: /etc/kernel-tests/01-modprobe exited with code 127
grep: /proc/cmdline: No such file or directory
grep: /proc/cmdline: No such file or directory
Trinity v1.0  Dave Jones <davej@redhat.com> 2012
Trinity v1.0  Dave Jones <davej@redhat.com> 2012
Trinity v1.0  Dave Jones <davej@redhat.com> 2012
No idea what syscall (get_robust_list) is.
Trinity v1.0  Dave Jones <davej@redhat.com> 2012
No idea what syscall (get_robust_list) is.
Don't run as root (or pass --dangerous if you know what you are doing).
Couldn't find socket cachefile. Regenerating.
fcntl F_WRLCK F_SETLKW: Permission denied
lsmod: can't open '/proc/modules': No such file or directory
BusyBox v1.19.4 (2012-04-22 09:22:10 PDT) multi-call binary.

Usage: rmmod [-wfa] [MODULE]...

lsmod: can't open '/proc/modules': No such file or directory
BusyBox v1.19.4 (2012-04-22 09:22:10 PDT) multi-call binary.

Usage: rmmod [-wfa] [MODULE]...

lsmod: can't open '/proc/modules': No such file or directory
BusyBox v1.19.4 (2012-04-22 09:22:10 PDT) multi-call binary.

Usage: rmmod [-wfa] [MODULE]...

run-parts: /etc/kernel-tests/99-rmmod exited with code 123


mount: no /proc/mounts
wfg: skip syslogd
sed: /proc/mounts: No such file or directory
sed: /proc/mounts: No such file or directory
sed: /proc/mounts: No such file or directory
Deconfiguring network interfaces... done.
Sending all processes the TERM signal...
mount: mounting proc on /proc failed: No such device
killall5[246]: mount returned non-zero exit status
killall5[246]: /proc not mounted, failed to mount.
Sending all processes the KILL signal...
mount: mounting proc on /proc failed: No such device
killall5[249]: mount returned non-zero exit status
killall5[249]: /proc not mounted, failed to mount.
Unmounting remote filesystems...
Deactivating swap...
Unmounting local filesystems...
grep: /proc/mounts: No such file or directory
mount: can't read '/proc/mounts': No such file or directory
Rebooting...=20
[   80.574266] Unregister pv shared memory for cpu 1
[   80.579413] reboot: Restarting system
[   80.580854] reboot: machine restart
Elapsed time: 90
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/i386-randconfig-n=
h0-01042205/0e61c867570dc816d6c5887c1352afc2bc14edb3/vmlinuz-3.13.0-rc6-wl-=
02230-g0e61c86 -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debu=
g apic=3Ddebug sysrq_always_enabled panic=3D10  prompt_ramdisk=3D0 console=
=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/ke=
rnel-tests/run-queue/kvm/i386-randconfig-nh0-01042205/linux-devel:devel-hou=
rly-2014010420/.vmlinuz-0e61c867570dc816d6c5887c1352afc2bc14edb3-2014010422=
2630-4-jaketown branch=3Dlinux-devel/devel-hourly-2014010420 BOOT_IMAGE=3D/=
kernel/i386-randconfig-nh0-01042205/0e61c867570dc816d6c5887c1352afc2bc14edb=
3/vmlinuz-3.13.0-rc6-wl-02230-g0e61c86'  -initrd /kernel-tests/initrd/yocto=
-minimal-i386.cgz -m 256M -smp 2 -net nic,vlan=3D1,model=3De1000 -net user,=
vlan=3D1,hostfwd=3Dtcp::29612-:22 -boot order=3Dnc -no-reboot -watchdog i63=
00esb -rtc base=3Dlocaltime -pidfile /dev/shm/kboot/pid-yocto-jaketown-31 -=
serial file:/dev/shm/kboot/serial-yocto-jaketown-31 -daemonize -display non=
e -monitor null=20

--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.13.0-rc6-wl-02230-g0e61c86"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 3.13.0-rc6 Kernel Configuration
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf32-i386"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
# CONFIG_ZONE_DMA32 is not set
# CONFIG_AUDIT_ARCH is not set
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_32_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-ecx -fcall-saved-edx"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
CONFIG_KERNEL_BZIP2=y
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SYSVIPC=y
# CONFIG_POSIX_MQUEUE is not set
CONFIG_FHANDLE=y
# CONFIG_AUDIT is not set

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_DEBUG=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_KTIME_SCALAR=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
CONFIG_TASKSTATS=y
# CONFIG_TASK_DELAY_ACCT is not set
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_FANOUT=32
CONFIG_RCU_FANOUT_LEAF=16
CONFIG_RCU_FANOUT_EXACT=y
# CONFIG_RCU_FAST_NO_HZ is not set
CONFIG_TREE_RCU_TRACE=y
CONFIG_RCU_NOCB_CPU=y
# CONFIG_RCU_NOCB_CPU_NONE is not set
# CONFIG_RCU_NOCB_CPU_ZERO is not set
CONFIG_RCU_NOCB_CPU_ALL=y
CONFIG_IKCONFIG=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_CHECKPOINT_RESTORE=y
# CONFIG_NAMESPACES is not set
CONFIG_UIDGID_STRICT_TYPE_CHECKS=y
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_EXPERT=y
# CONFIG_UID16 is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
# CONFIG_ELF_CORE is not set
# CONFIG_PCSPKR_PLATFORM is not set
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
# CONFIG_TIMERFD is not set
# CONFIG_EVENTFD is not set
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_PCI_QUIRKS=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
CONFIG_VM_EVENT_COUNTERS=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_JUMP_LABEL=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
# CONFIG_SYSTEM_TRUSTED_KEYRING is not set
# CONFIG_MODULES is not set
CONFIG_STOP_MACHINE=y
# CONFIG_BLOCK is not set
CONFIG_PADATA=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_BIGSMP=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
CONFIG_X86_32_IRIS=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
# CONFIG_XEN is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_LGUEST_GUEST is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
CONFIG_MPENTIUMM=y
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MELAN is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
# CONFIG_X86_GENERIC is not set
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=5
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_CYRIX_32=y
CONFIG_CPU_SUP_AMD=y
# CONFIG_CPU_SUP_CENTAUR is not set
CONFIG_CPU_SUP_TRANSMETA_32=y
# CONFIG_CPU_SUP_UMC_32 is not set
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
# CONFIG_DMI is not set
CONFIG_NR_CPUS=32
# CONFIG_SCHED_SMT is not set
CONFIG_SCHED_MC=y
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
# CONFIG_X86_MCE_AMD is not set
CONFIG_X86_ANCIENT_MCE=y
CONFIG_X86_MCE_THRESHOLD=y
# CONFIG_X86_MCE_INJECT is not set
CONFIG_X86_THERMAL_VECTOR=y
# CONFIG_VM86 is not set
# CONFIG_TOSHIBA is not set
CONFIG_I8K=y
CONFIG_X86_REBOOTFIXUPS=y
# CONFIG_MICROCODE is not set
# CONFIG_MICROCODE_INTEL_EARLY is not set
# CONFIG_MICROCODE_AMD_EARLY is not set
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
# CONFIG_NOHIGHMEM is not set
# CONFIG_HIGHMEM4G is not set
CONFIG_HIGHMEM64G=y
# CONFIG_VMSPLIT_3G is not set
CONFIG_VMSPLIT_2G=y
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0x80000000
CONFIG_HIGHMEM=y
CONFIG_X86_PAE=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
# CONFIG_NUMA is not set
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=0
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_MEMORY_FAILURE is not set
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_CLEANCACHE is not set
CONFIG_CMA=y
CONFIG_CMA_DEBUG=y
# CONFIG_ZBUD is not set
# CONFIG_HIGHPTE is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MATH_EMULATION is not set
# CONFIG_MTRR is not set
CONFIG_ARCH_RANDOM=y
# CONFIG_X86_SMAP is not set
CONFIG_EFI=y
CONFIG_EFI_STUB=y
# CONFIG_SECCOMP is not set
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
CONFIG_BOOTPARAM_HOTPLUG_CPU0=y
CONFIG_DEBUG_HOTPLUG_CPU0=y
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_EC_DEBUGFS is not set
# CONFIG_ACPI_AC is not set
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_FAN is not set
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
CONFIG_ACPI_DEBUG=y
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_BGRT is not set
# CONFIG_ACPI_APEI is not set
CONFIG_ACPI_EXTLOG=y
CONFIG_SFI=y
# CONFIG_APM is not set

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
# CONFIG_CPU_IDLE_GOV_LADDER is not set
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_GOBIOS=y
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
# CONFIG_PCI_GOANY is not set
CONFIG_PCI_BIOS=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCI_CNB20LE_QUIRK=y
# CONFIG_PCIEPORTBUS is not set
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_REALLOC_ENABLE_AUTO=y
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
# CONFIG_PCI_PASID is not set
CONFIG_PCI_IOAPIC=y
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
CONFIG_ISA=y
# CONFIG_EISA is not set
CONFIG_SCx200=y
CONFIG_SCx200HR_TIMER=y
# CONFIG_ALIX is not set
# CONFIG_NET5501 is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
# CONFIG_PCMCIA is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
CONFIG_PCMCIA_PROBE=y
# CONFIG_HOTPLUG_PCI is not set
CONFIG_RAPIDIO=y
CONFIG_RAPIDIO_DISC_TIMEOUT=30
CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS=y
CONFIG_RAPIDIO_DMA_ENGINE=y
CONFIG_RAPIDIO_DEBUG=y
CONFIG_RAPIDIO_ENUM_BASIC=y

#
# RapidIO Switch drivers
#
CONFIG_RAPIDIO_TSI57X=y
# CONFIG_RAPIDIO_CPS_XX is not set
CONFIG_RAPIDIO_TSI568=y
# CONFIG_RAPIDIO_CPS_GEN2 is not set
CONFIG_X86_SYSFB=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=y
# CONFIG_BINFMT_MISC is not set
CONFIG_COREDUMP=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=y
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_SUB_POLICY is not set
CONFIG_XFRM_MIGRATE=y
# CONFIG_NET_KEY is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_PNP=y
# CONFIG_IP_PNP_DHCP is not set
# CONFIG_IP_PNP_BOOTP is not set
CONFIG_IP_PNP_RARP=y
CONFIG_NET_IPIP=y
CONFIG_NET_IPGRE_DEMUX=y
CONFIG_NET_IP_TUNNEL=y
# CONFIG_NET_IPGRE is not set
# CONFIG_IP_MROUTE is not set
# CONFIG_SYN_COOKIES is not set
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
CONFIG_INET_TUNNEL=y
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_INET_UDP_DIAG is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
# CONFIG_IPV6_ROUTER_PREF is not set
CONFIG_IPV6_OPTIMISTIC_DAD=y
CONFIG_INET6_AH=y
CONFIG_INET6_ESP=y
# CONFIG_INET6_IPCOMP is not set
CONFIG_IPV6_MIP6=y
# CONFIG_INET6_XFRM_TUNNEL is not set
CONFIG_INET6_TUNNEL=y
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
# CONFIG_INET6_XFRM_MODE_BEET is not set
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=y
CONFIG_IPV6_VTI=y
# CONFIG_IPV6_SIT is not set
CONFIG_IPV6_TUNNEL=y
# CONFIG_IPV6_GRE is not set
# CONFIG_IPV6_MULTIPLE_TABLES is not set
CONFIG_IPV6_MROUTE=y
# CONFIG_IPV6_MROUTE_MULTIPLE_TABLES is not set
# CONFIG_IPV6_PIMSM_V2 is not set
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NETWORK_PHY_TIMESTAMPING=y
# CONFIG_NETFILTER is not set
CONFIG_IP_DCCP=y
CONFIG_INET_DCCP_DIAG=y

#
# DCCP CCIDs Configuration
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
# CONFIG_IP_DCCP_CCID3 is not set

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
CONFIG_IP_SCTP=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=y
CONFIG_SCTP_COOKIE_HMAC_SHA1=y
CONFIG_RDS=y
# CONFIG_RDS_RDMA is not set
# CONFIG_RDS_TCP is not set
CONFIG_RDS_DEBUG=y
CONFIG_TIPC=y
CONFIG_TIPC_PORTS=8191
# CONFIG_TIPC_MEDIA_IB is not set
CONFIG_ATM=y
CONFIG_ATM_CLIP=y
CONFIG_ATM_CLIP_NO_ICMP=y
# CONFIG_ATM_LANE is not set
# CONFIG_ATM_BR2684 is not set
CONFIG_L2TP=y
# CONFIG_L2TP_DEBUGFS is not set
# CONFIG_L2TP_V3 is not set
CONFIG_STP=y
CONFIG_MRP=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_IGMP_SNOOPING=y
# CONFIG_BRIDGE_VLAN_FILTERING is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_NET_DSA=y
CONFIG_NET_DSA_TAG_DSA=y
CONFIG_VLAN_8021Q=y
# CONFIG_VLAN_8021Q_GVRP is not set
CONFIG_VLAN_8021Q_MVRP=y
# CONFIG_DECNET is not set
CONFIG_LLC=y
CONFIG_LLC2=y
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
CONFIG_X25=y
CONFIG_LAPB=y
CONFIG_PHONET=y
CONFIG_IEEE802154=y
CONFIG_IEEE802154_6LOWPAN=y
CONFIG_MAC802154=y
# CONFIG_NET_SCHED is not set
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
CONFIG_VSOCKETS=y
# CONFIG_VMWARE_VMCI_VSOCKETS is not set
CONFIG_NETLINK_MMAP=y
CONFIG_NETLINK_DIAG=y
CONFIG_NET_MPLS_GSO=y
CONFIG_HSR=y
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
CONFIG_CAN=y
CONFIG_CAN_RAW=y
# CONFIG_CAN_BCM is not set
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
CONFIG_CAN_SLCAN=y
CONFIG_CAN_DEV=y
CONFIG_CAN_CALC_BITTIMING=y
CONFIG_CAN_LEDS=y
# CONFIG_CAN_MCP251X is not set
CONFIG_CAN_JANZ_ICAN3=y
CONFIG_PCH_CAN=y
CONFIG_CAN_SJA1000=y
# CONFIG_CAN_SJA1000_ISA is not set
# CONFIG_CAN_SJA1000_PLATFORM is not set
CONFIG_CAN_EMS_PCI=y
CONFIG_CAN_PEAK_PCI=y
CONFIG_CAN_PEAK_PCIEC=y
CONFIG_CAN_KVASER_PCI=y
# CONFIG_CAN_PLX_PCI is not set
# CONFIG_CAN_TSCAN1 is not set
CONFIG_CAN_C_CAN=y
CONFIG_CAN_C_CAN_PLATFORM=y
CONFIG_CAN_C_CAN_PCI=y
CONFIG_CAN_CC770=y
CONFIG_CAN_CC770_ISA=y
# CONFIG_CAN_CC770_PLATFORM is not set
CONFIG_CAN_SOFTING=y
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=y

#
# IrDA protocols
#
# CONFIG_IRLAN is not set
CONFIG_IRNET=y
CONFIG_IRCOMM=y
# CONFIG_IRDA_ULTRA is not set

#
# IrDA options
#
CONFIG_IRDA_CACHE_LAST_LSAP=y
CONFIG_IRDA_FAST_RR=y
# CONFIG_IRDA_DEBUG is not set

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
CONFIG_IRTTY_SIR=y

#
# Dongle support
#
# CONFIG_DONGLE is not set

#
# FIR device drivers
#
CONFIG_NSC_FIR=y
# CONFIG_WINBOND_FIR is not set
# CONFIG_TOSHIBA_FIR is not set
CONFIG_SMC_IRCC_FIR=y
# CONFIG_ALI_FIR is not set
CONFIG_VLSI_FIR=y
CONFIG_VIA_FIR=y
CONFIG_BT=y
# CONFIG_BT_RFCOMM is not set
CONFIG_BT_BNEP=y
CONFIG_BT_BNEP_MC_FILTER=y
# CONFIG_BT_BNEP_PROTO_FILTER is not set
CONFIG_BT_HIDP=y

#
# Bluetooth device drivers
#
CONFIG_BT_HCIUART=y
# CONFIG_BT_HCIUART_H4 is not set
# CONFIG_BT_HCIUART_BCSP is not set
# CONFIG_BT_HCIUART_ATH3K is not set
# CONFIG_BT_HCIUART_LL is not set
# CONFIG_BT_HCIUART_3WIRE is not set
CONFIG_BT_HCIVHCI=y
# CONFIG_BT_MRVL is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_WIRELESS is not set
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_RFKILL_REGULATOR is not set
# CONFIG_NET_9P is not set
CONFIG_CAIF=y
CONFIG_CAIF_DEBUG=y
CONFIG_CAIF_NETDEV=y
CONFIG_CAIF_USB=y
CONFIG_CEPH_LIB=y
CONFIG_CEPH_LIB_PRETTYDEBUG=y
CONFIG_CEPH_LIB_USE_DNS_RESOLVER=y
CONFIG_NFC=y
CONFIG_NFC_DIGITAL=y
# CONFIG_NFC_NCI is not set
CONFIG_NFC_HCI=y
CONFIG_NFC_SHDLC=y

#
# Near Field Communication (NFC) devices
#
# CONFIG_NFC_MEI_PHY is not set
CONFIG_NFC_SIM=y
# CONFIG_NFC_PN544 is not set
CONFIG_NFC_MICROREAD=y
# CONFIG_NFC_MICROREAD_I2C is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
# CONFIG_STANDALONE is not set
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_FW_LOADER_USER_HELPER is not set
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
# CONFIG_DMA_SHARED_BUFFER is not set
# CONFIG_DMA_CMA is not set

#
# Bus devices
#
CONFIG_CONNECTOR=y
# CONFIG_PROC_EVENTS is not set
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
# CONFIG_MTD_REDBOOT_PARTS_READONLY is not set
CONFIG_MTD_CMDLINE_PARTS=y
# CONFIG_MTD_AR7_PARTS is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_OOPS=y

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
CONFIG_MTD_CFI_ADV_OPTIONS=y
# CONFIG_MTD_CFI_NOSWAP is not set
CONFIG_MTD_CFI_BE_BYTE_SWAP=y
# CONFIG_MTD_CFI_LE_BYTE_SWAP is not set
# CONFIG_MTD_CFI_GEOMETRY is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_OTP=y
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
CONFIG_MTD_PHYSMAP=y
# CONFIG_MTD_PHYSMAP_COMPAT is not set
CONFIG_MTD_TS5500=y
CONFIG_MTD_SBC_GXX=y
CONFIG_MTD_AMD76XROM=y
# CONFIG_MTD_ICHXROM is not set
CONFIG_MTD_ESB2ROM=y
# CONFIG_MTD_CK804XROM is not set
CONFIG_MTD_SCB2_FLASH=y
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
# CONFIG_MTD_PCI is not set
CONFIG_MTD_INTEL_VR_NOR=y
# CONFIG_MTD_PLATRAM is not set
CONFIG_MTD_LATCH_ADDR=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_DATAFLASH=y
# CONFIG_MTD_DATAFLASH_WRITE_VERIFY is not set
# CONFIG_MTD_DATAFLASH_OTP is not set
CONFIG_MTD_M25P80=y
CONFIG_MTD_SST25L=y
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
CONFIG_MTD_MTDRAM=y
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTDRAM_ABS_POS=0

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
# CONFIG_MTD_NAND is not set
# CONFIG_MTD_ONENAND is not set

#
# LPDDR flash memory drivers
#
# CONFIG_MTD_LPDDR is not set
# CONFIG_MTD_UBI is not set
CONFIG_PARPORT=y
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT_PC=y
CONFIG_PARPORT_SERIAL=y
# CONFIG_PARPORT_PC_FIFO is not set
# CONFIG_PARPORT_PC_SUPERIO is not set
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=y
# CONFIG_PARPORT_1284 is not set
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_ISAPNP=y
CONFIG_PNPBIOS=y
CONFIG_PNPACPI=y

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_AD525X_DPOT_SPI=y
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
CONFIG_PHANTOM=y
# CONFIG_SGI_IOC4 is not set
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=y
CONFIG_ATMEL_SSC=y
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_CS5535_MFGPT=y
CONFIG_CS5535_MFGPT_DEFAULT_IRQ=7
CONFIG_CS5535_CLOCK_EVENT_SRC=y
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
# CONFIG_ISL29003 is not set
CONFIG_ISL29020=y
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1780 is not set
CONFIG_SENSORS_BH1770=y
CONFIG_SENSORS_APDS990X=y
# CONFIG_HMC6352 is not set
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
# CONFIG_VMWARE_BALLOON is not set
# CONFIG_BMP085_I2C is not set
# CONFIG_BMP085_SPI is not set
CONFIG_PCH_PHUB=y
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_LATTICE_ECP3_CONFIG=y
# CONFIG_SRAM is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_AT25 is not set
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
# CONFIG_EEPROM_93XX46 is not set
CONFIG_CB710_CORE=y
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
CONFIG_VMWARE_VMCI=y

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_SCSI_DMA is not set
# CONFIG_SCSI_NETLINK is not set
CONFIG_FUSION=y
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
CONFIG_FIREWIRE_OHCI=y
# CONFIG_FIREWIRE_NET is not set
CONFIG_FIREWIRE_NOSY=y
CONFIG_I2O=y
# CONFIG_I2O_LCT_NOTIFY_ON_CHANGES is not set
# CONFIG_I2O_EXT_ADAPTEC is not set
CONFIG_I2O_CONFIG=y
# CONFIG_I2O_CONFIG_OLD_IOCTL is not set
CONFIG_I2O_BUS=y
# CONFIG_I2O_PROC is not set
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
CONFIG_BONDING=y
CONFIG_DUMMY=y
# CONFIG_EQUALIZER is not set
# CONFIG_NET_TEAM is not set
CONFIG_MACVLAN=y
CONFIG_MACVTAP=y
# CONFIG_VXLAN is not set
CONFIG_NETCONSOLE=y
# CONFIG_NETCONSOLE_DYNAMIC is not set
CONFIG_NETPOLL=y
CONFIG_NETPOLL_TRAP=y
CONFIG_NET_POLL_CONTROLLER=y
CONFIG_NTB_NETDEV=y
# CONFIG_RIONET is not set
# CONFIG_TUN is not set
CONFIG_VETH=y
# CONFIG_VIRTIO_NET is not set
CONFIG_NLMON=y
CONFIG_SUNGEM_PHY=y
# CONFIG_ARCNET is not set
# CONFIG_ATM_DRIVERS is not set

#
# CAIF transport drivers
#
CONFIG_CAIF_TTY=y
# CONFIG_CAIF_SPI_SLAVE is not set
# CONFIG_CAIF_HSI is not set
CONFIG_CAIF_VIRTIO=y
CONFIG_VHOST_RING=y

#
# Distributed Switch Architecture drivers
#
CONFIG_NET_DSA_MV88E6XXX=y
# CONFIG_NET_DSA_MV88E6060 is not set
CONFIG_NET_DSA_MV88E6XXX_NEED_PPU=y
CONFIG_NET_DSA_MV88E6131=y
# CONFIG_NET_DSA_MV88E6123_61_65 is not set
CONFIG_ETHERNET=y
CONFIG_MDIO=y
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_NET_VENDOR_ADAPTEC is not set
# CONFIG_NET_VENDOR_ALTEON is not set
# CONFIG_NET_VENDOR_AMD is not set
# CONFIG_NET_VENDOR_ARC is not set
# CONFIG_NET_VENDOR_ATHEROS is not set
# CONFIG_NET_CADENCE is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
CONFIG_BNX2=y
CONFIG_CNIC=y
CONFIG_TIGON3=y
CONFIG_BNX2X=y
# CONFIG_BNX2X_SRIOV is not set
# CONFIG_NET_VENDOR_BROCADE is not set
# CONFIG_NET_CALXEDA_XGMAC is not set
# CONFIG_NET_VENDOR_CHELSIO is not set
CONFIG_NET_VENDOR_CIRRUS=y
CONFIG_CS89x0=y
CONFIG_CS89x0_PLATFORM=y
# CONFIG_NET_VENDOR_CISCO is not set
CONFIG_DNET=y
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
CONFIG_DL2K=y
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=y
# CONFIG_NET_VENDOR_EXAR is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
# CONFIG_NET_VENDOR_INTEL is not set
# CONFIG_IP1000 is not set
CONFIG_JME=y
# CONFIG_NET_VENDOR_MARVELL is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
CONFIG_MLX4_CORE=y
# CONFIG_MLX4_DEBUG is not set
# CONFIG_MLX5_CORE is not set
# CONFIG_NET_VENDOR_MICREL is not set
CONFIG_NET_VENDOR_MICROCHIP=y
CONFIG_ENC28J60=y
CONFIG_ENC28J60_WRITEVERIFY=y
# CONFIG_NET_VENDOR_MYRI is not set
CONFIG_FEALNX=y
# CONFIG_NET_VENDOR_NATSEMI is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_PCH_GBE is not set
CONFIG_ETHOC=y
CONFIG_NET_PACKET_ENGINE=y
CONFIG_HAMACHI=y
CONFIG_YELLOWFIN=y
# CONFIG_NET_VENDOR_QLOGIC is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R8169 is not set
# CONFIG_SH_ETH is not set
# CONFIG_NET_VENDOR_RDC is not set
# CONFIG_NET_VENDOR_SEEQ is not set
# CONFIG_NET_VENDOR_SILAN is not set
CONFIG_NET_VENDOR_SIS=y
CONFIG_SIS900=y
CONFIG_SIS190=y
CONFIG_SFC=y
CONFIG_SFC_MTD=y
CONFIG_SFC_MCDI_MON=y
# CONFIG_SFC_SRIOV is not set
CONFIG_NET_VENDOR_SMSC=y
CONFIG_SMC9194=y
CONFIG_EPIC100=y
# CONFIG_SMSC911X is not set
CONFIG_SMSC9420=y
CONFIG_NET_VENDOR_STMICRO=y
CONFIG_STMMAC_ETH=y
CONFIG_STMMAC_PLATFORM=y
# CONFIG_STMMAC_PCI is not set
CONFIG_STMMAC_DEBUG_FS=y
# CONFIG_STMMAC_DA is not set
CONFIG_NET_VENDOR_SUN=y
CONFIG_HAPPYMEAL=y
CONFIG_SUNGEM=y
# CONFIG_CASSINI is not set
CONFIG_NIU=y
CONFIG_NET_VENDOR_TEHUTI=y
CONFIG_TEHUTI=y
CONFIG_NET_VENDOR_TI=y
CONFIG_TLAN=y
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
CONFIG_VIA_VELOCITY=y
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_FDDI=y
CONFIG_DEFXX=y
# CONFIG_DEFXX_MMIO is not set
# CONFIG_SKFP is not set
CONFIG_HIPPI=y
CONFIG_ROADRUNNER=y
CONFIG_ROADRUNNER_LARGE_RINGS=y
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
CONFIG_AT803X_PHY=y
# CONFIG_AMD_PHY is not set
CONFIG_MARVELL_PHY=y
CONFIG_DAVICOM_PHY=y
# CONFIG_QSEMI_PHY is not set
CONFIG_LXT_PHY=y
CONFIG_CICADA_PHY=y
CONFIG_VITESSE_PHY=y
CONFIG_SMSC_PHY=y
CONFIG_BROADCOM_PHY=y
CONFIG_BCM87XX_PHY=y
CONFIG_ICPLUS_PHY=y
CONFIG_REALTEK_PHY=y
# CONFIG_NATIONAL_PHY is not set
# CONFIG_STE10XP is not set
CONFIG_LSI_ET1011C_PHY=y
# CONFIG_MICREL_PHY is not set
CONFIG_FIXED_PHY=y
CONFIG_MDIO_BITBANG=y
# CONFIG_MICREL_KS8995MA is not set
CONFIG_PLIP=y
CONFIG_PPP=y
CONFIG_PPP_BSDCOMP=y
# CONFIG_PPP_DEFLATE is not set
CONFIG_PPP_FILTER=y
CONFIG_PPP_MPPE=y
# CONFIG_PPP_MULTILINK is not set
CONFIG_PPPOATM=y
CONFIG_PPPOE=y
CONFIG_PPTP=y
CONFIG_PPPOL2TP=y
# CONFIG_PPP_ASYNC is not set
# CONFIG_PPP_SYNC_TTY is not set
CONFIG_SLIP=y
CONFIG_SLHC=y
CONFIG_SLIP_COMPRESSED=y
# CONFIG_SLIP_SMART is not set
CONFIG_SLIP_MODE_SLIP6=y
# CONFIG_WLAN is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
CONFIG_WAN=y
CONFIG_LANMEDIA=y
CONFIG_HDLC=y
CONFIG_HDLC_RAW=y
CONFIG_HDLC_RAW_ETH=y
CONFIG_HDLC_CISCO=y
CONFIG_HDLC_FR=y
# CONFIG_HDLC_PPP is not set
# CONFIG_HDLC_X25 is not set
# CONFIG_PCI200SYN is not set
# CONFIG_WANXL is not set
CONFIG_PC300TOO=y
CONFIG_N2=y
# CONFIG_C101 is not set
CONFIG_FARSYNC=y
CONFIG_DLCI=y
CONFIG_DLCI_MAX=8
CONFIG_SDLA=y
CONFIG_LAPBETHER=y
CONFIG_X25_ASY=y
CONFIG_SBNI=y
# CONFIG_SBNI_MULTILINE is not set
CONFIG_IEEE802154_DRIVERS=y
CONFIG_IEEE802154_FAKEHARD=y
CONFIG_IEEE802154_FAKELB=y
# CONFIG_IEEE802154_AT86RF230 is not set
CONFIG_IEEE802154_MRF24J40=y
# CONFIG_VMXNET3 is not set
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
# CONFIG_INPUT_SPARSEKMAP is not set
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_STMPE is not set
# CONFIG_KEYBOARD_TWL4030 is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
# CONFIG_MOUSE_PS2_LOGIPS2PP is not set
# CONFIG_MOUSE_PS2_SYNAPTICS is not set
CONFIG_MOUSE_PS2_CYPRESS=y
# CONFIG_MOUSE_PS2_TRACKPOINT is not set
CONFIG_MOUSE_PS2_ELANTECH=y
CONFIG_MOUSE_PS2_SENTELIC=y
CONFIG_MOUSE_PS2_TOUCHKIT=y
CONFIG_MOUSE_SERIAL=y
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
CONFIG_MOUSE_INPORT=y
CONFIG_MOUSE_ATIXL=y
CONFIG_MOUSE_LOGIBM=y
# CONFIG_MOUSE_PC110PAD is not set
CONFIG_MOUSE_VSXXXAA=y
CONFIG_MOUSE_SYNAPTICS_I2C=y
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
CONFIG_INPUT_TABLET=y
# CONFIG_TABLET_USB_ACECAD is not set
# CONFIG_TABLET_USB_AIPTEK is not set
# CONFIG_TABLET_USB_HANWANG is not set
# CONFIG_TABLET_USB_KBTAB is not set
# CONFIG_TABLET_USB_WACOM is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_88PM80X_ONKEY=y
# CONFIG_INPUT_AD714X is not set
CONFIG_INPUT_ARIZONA_HAPTICS=y
CONFIG_INPUT_BMA150=y
CONFIG_INPUT_MC13783_PWRBUTTON=y
CONFIG_INPUT_MMA8450=y
CONFIG_INPUT_MPU3050=y
CONFIG_INPUT_APANEL=y
# CONFIG_INPUT_WISTRON_BTNS is not set
CONFIG_INPUT_ATLAS_BTNS=y
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
CONFIG_INPUT_KXTJ9=y
# CONFIG_INPUT_KXTJ9_POLLED_MODE is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_RETU_PWRBUTTON=y
CONFIG_INPUT_TWL4030_PWRBUTTON=y
# CONFIG_INPUT_TWL4030_VIBRA is not set
CONFIG_INPUT_TWL6040_VIBRA=y
CONFIG_INPUT_UINPUT=y
CONFIG_INPUT_PCF50633_PMU=y
CONFIG_INPUT_PCF8574=y
CONFIG_INPUT_DA9052_ONKEY=y
CONFIG_INPUT_DA9055_ONKEY=y
CONFIG_INPUT_WM831X_ON=y
# CONFIG_INPUT_PCAP is not set
CONFIG_INPUT_ADXL34X=y
CONFIG_INPUT_ADXL34X_I2C=y
CONFIG_INPUT_ADXL34X_SPI=y
# CONFIG_INPUT_CMA3000 is not set
CONFIG_INPUT_IDEAPAD_SLIDEBAR=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
# CONFIG_SERIO_ARC_PS2 is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_SERIAL_NONSTANDARD is not set
CONFIG_NOZOMI=y
CONFIG_N_GSM=y
# CONFIG_TRACE_ROUTER is not set
CONFIG_TRACE_SINK=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
CONFIG_SERIAL_8250_DW=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
# CONFIG_SERIAL_MAX310X is not set
# CONFIG_SERIAL_MRST_MAX3110 is not set
CONFIG_SERIAL_MFD_HSU=y
CONFIG_SERIAL_MFD_HSU_CONSOLE=y
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
# CONFIG_SERIAL_SCCNXP is not set
CONFIG_SERIAL_TIMBERDALE=y
CONFIG_SERIAL_ALTERA_JTAGUART=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE_BYPASS=y
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
CONFIG_SERIAL_ALTERA_UART_CONSOLE=y
# CONFIG_SERIAL_PCH_UART is not set
CONFIG_SERIAL_ARC=y
CONFIG_SERIAL_ARC_CONSOLE=y
CONFIG_SERIAL_ARC_NR_PORTS=1
CONFIG_SERIAL_RP2=y
CONFIG_SERIAL_RP2_NR_UARTS=32
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=y
# CONFIG_VIRTIO_CONSOLE is not set
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_GEODE=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_HW_RANDOM_TPM=y
CONFIG_NVRAM=y
# CONFIG_DTLK is not set
CONFIG_R3964=y
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set
CONFIG_MWAVE=y
# CONFIG_SCx200_GPIO is not set
CONFIG_PC8736x_GPIO=y
CONFIG_NSC_GPIO=y
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
# CONFIG_HPET_MMAP_DEFAULT is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_I2C_ATMEL=y
# CONFIG_TCG_TIS_I2C_INFINEON is not set
# CONFIG_TCG_TIS_I2C_NUVOTON is not set
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
# CONFIG_TCG_INFINEON is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=y
# CONFIG_I2C_MUX is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=y
CONFIG_I2C_ALI1563=y
# CONFIG_I2C_ALI15X3 is not set
CONFIG_I2C_AMD756=y
# CONFIG_I2C_AMD756_S4882 is not set
# CONFIG_I2C_AMD8111 is not set
CONFIG_I2C_I801=y
# CONFIG_I2C_ISCH is not set
CONFIG_I2C_ISMT=y
# CONFIG_I2C_PIIX4 is not set
CONFIG_I2C_NFORCE2=y
CONFIG_I2C_NFORCE2_S4985=y
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
CONFIG_I2C_SIS96X=y
CONFIG_I2C_VIA=y
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
CONFIG_I2C_SCMI=y

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PCI=y
# CONFIG_I2C_EG20T is not set
CONFIG_I2C_KEMPLD=y
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
# CONFIG_I2C_SIMTEC is not set
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_TAOS_EVM is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_PCA_ISA is not set
CONFIG_SCx200_ACB=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
CONFIG_SPI_DEBUG=y
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
# CONFIG_SPI_LM70_LLP is not set
CONFIG_SPI_PXA2XX_DMA=y
CONFIG_SPI_PXA2XX=y
CONFIG_SPI_PXA2XX_PCI=y
# CONFIG_SPI_SC18IS602 is not set
# CONFIG_SPI_TOPCLIFF_PCH is not set
CONFIG_SPI_XCOMM=y
# CONFIG_SPI_XILINX is not set
CONFIG_SPI_DESIGNWARE=y
CONFIG_SPI_DW_PCI=y
CONFIG_SPI_DW_MID_DMA=y

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
CONFIG_SPI_TLE62X0=y
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI clients
#
CONFIG_HSI_CHAR=y

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
CONFIG_PPS_CLIENT_LDISC=y
CONFIG_PPS_CLIENT_PARPORT=y
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y
CONFIG_DP83640_PHY=y
# CONFIG_PTP_1588_CLOCK_PCH is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
CONFIG_W1=y
# CONFIG_W1_CON is not set

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
CONFIG_W1_MASTER_DS2482=y
# CONFIG_W1_MASTER_DS1WM is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
# CONFIG_W1_SLAVE_SMEM is not set
# CONFIG_W1_SLAVE_DS2408 is not set
CONFIG_W1_SLAVE_DS2413=y
# CONFIG_W1_SLAVE_DS2423 is not set
# CONFIG_W1_SLAVE_DS2431 is not set
CONFIG_W1_SLAVE_DS2433=y
CONFIG_W1_SLAVE_DS2433_CRC=y
# CONFIG_W1_SLAVE_DS2760 is not set
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
CONFIG_PDA_POWER=y
CONFIG_GENERIC_ADC_BATTERY=y
CONFIG_WM831X_BACKUP=y
CONFIG_WM831X_POWER=y
# CONFIG_TEST_POWER is not set
CONFIG_BATTERY_DS2780=y
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
CONFIG_BATTERY_BQ27x00=y
CONFIG_BATTERY_BQ27X00_I2C=y
# CONFIG_BATTERY_BQ27X00_PLATFORM is not set
CONFIG_BATTERY_DA9030=y
# CONFIG_BATTERY_DA9052 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
CONFIG_BATTERY_TWL4030_MADC=y
# CONFIG_CHARGER_PCF50633 is not set
# CONFIG_BATTERY_RX51 is not set
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_TWL4030=y
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_BQ2415X=y
# CONFIG_CHARGER_SMB347 is not set
CONFIG_POWER_RESET=y
CONFIG_POWER_AVS=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_AD7314=y
# CONFIG_SENSORS_AD7414 is not set
CONFIG_SENSORS_AD7418=y
# CONFIG_SENSORS_ADCXX is not set
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
# CONFIG_SENSORS_ADT7310 is not set
CONFIG_SENSORS_ADT7410=y
# CONFIG_SENSORS_ADT7411 is not set
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K8TEMP is not set
CONFIG_SENSORS_K10TEMP=y
CONFIG_SENSORS_FAM15H_POWER=y
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ATXP1=y
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DA9052_ADC=y
# CONFIG_SENSORS_DA9055 is not set
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_G760A=y
# CONFIG_SENSORS_G762 is not set
CONFIG_SENSORS_GL518SM=y
# CONFIG_SENSORS_GL520SM is not set
CONFIG_SENSORS_HIH6130=y
# CONFIG_SENSORS_HTU21 is not set
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_IIO_HWMON is not set
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM70=y
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
# CONFIG_SENSORS_LM77 is not set
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
# CONFIG_SENSORS_LM83 is not set
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
# CONFIG_SENSORS_LM90 is not set
# CONFIG_SENSORS_LM92 is not set
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_LM95234 is not set
CONFIG_SENSORS_LM95241=y
# CONFIG_SENSORS_LM95245 is not set
CONFIG_SENSORS_MAX1111=y
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
# CONFIG_SENSORS_MAX1668 is not set
CONFIG_SENSORS_MAX197=y
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_MCP3021 is not set
CONFIG_SENSORS_NCT6775=y
CONFIG_SENSORS_PC87360=y
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_PMBUS is not set
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SIS5595=y
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
CONFIG_SENSORS_SCH5636=y
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_ADS7871=y
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP401=y
# CONFIG_SENSORS_TMP421 is not set
# CONFIG_SENSORS_TWL4030_MADC is not set
CONFIG_SENSORS_VIA_CPUTEMP=y
CONFIG_SENSORS_VIA686A=y
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=y
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_WM831X is not set
CONFIG_SENSORS_APPLESMC=y
CONFIG_SENSORS_MC13783_ADC=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
CONFIG_SENSORS_ATK0110=y
CONFIG_THERMAL=y
# CONFIG_THERMAL_HWMON is not set
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE=y
CONFIG_THERMAL_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_GOV_STEP_WISE is not set
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_THERMAL_EMULATION=y
CONFIG_INTEL_POWERCLAMP=y
CONFIG_X86_PKG_TEMP_THERMAL=y

#
# Texas Instruments thermal drivers
#
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
CONFIG_WATCHDOG_NOWAYOUT=y

#
# Watchdog Device Drivers
#
# CONFIG_SOFT_WATCHDOG is not set
CONFIG_DA9052_WATCHDOG=y
# CONFIG_DA9055_WATCHDOG is not set
CONFIG_WM831X_WATCHDOG=y
CONFIG_TWL4030_WATCHDOG=y
# CONFIG_RETU_WATCHDOG is not set
# CONFIG_ACQUIRE_WDT is not set
CONFIG_ADVANTECH_WDT=y
CONFIG_ALIM1535_WDT=y
CONFIG_ALIM7101_WDT=y
CONFIG_F71808E_WDT=y
CONFIG_SP5100_TCO=y
# CONFIG_GEODE_WDT is not set
CONFIG_SC520_WDT=y
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
CONFIG_IBMASR=y
# CONFIG_WAFER_WDT is not set
CONFIG_I6300ESB_WDT=y
# CONFIG_IE6XX_WDT is not set
CONFIG_ITCO_WDT=y
# CONFIG_ITCO_VENDOR_SUPPORT is not set
CONFIG_IT8712F_WDT=y
# CONFIG_IT87_WDT is not set
# CONFIG_HP_WATCHDOG is not set
CONFIG_KEMPLD_WDT=y
CONFIG_SC1200_WDT=y
CONFIG_SCx200_WDT=y
CONFIG_PC87413_WDT=y
CONFIG_NV_TCO=y
CONFIG_60XX_WDT=y
CONFIG_SBC8360_WDT=y
# CONFIG_SBC7240_WDT is not set
CONFIG_CPU5_WDT=y
CONFIG_SMSC_SCH311X_WDT=y
CONFIG_SMSC37B787_WDT=y
# CONFIG_VIA_WDT is not set
CONFIG_W83627HF_WDT=y
CONFIG_W83697HF_WDT=y
CONFIG_W83697UG_WDT=y
# CONFIG_W83877F_WDT is not set
CONFIG_W83977F_WDT=y
# CONFIG_MACHZ_WDT is not set
# CONFIG_SBC_EPX_C3_WATCHDOG is not set

#
# ISA-based Watchdog Cards
#
CONFIG_PCWATCHDOG=y
# CONFIG_MIXCOMWD is not set
# CONFIG_WDT is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
CONFIG_SSB_SILENT=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
# CONFIG_SSB_DRIVER_PCICORE is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_CS5535=y
# CONFIG_MFD_AS3711 is not set
# CONFIG_PMIC_ADP5520 is not set
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
# CONFIG_MFD_CROS_EC_SPI is not set
CONFIG_PMIC_DA903X=y
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_SPI=y
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
CONFIG_MFD_DA9063=y
CONFIG_MFD_MC13783=y
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_SPI=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
CONFIG_MFD_JANZ_CMODIO=y
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
CONFIG_MFD_MAX8998=y
CONFIG_EZX_PCAP=y
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
CONFIG_MFD_RDC321X=y
CONFIG_MFD_RTSX_PCI=y
CONFIG_MFD_RC5T583=y
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
# CONFIG_MFD_SMSC is not set
CONFIG_ABX500_CORE=y
# CONFIG_AB3100_CORE is not set
CONFIG_MFD_STMPE=y

#
# STMicroelectronics STMPE Interface Drivers
#
CONFIG_STMPE_I2C=y
# CONFIG_STMPE_SPI is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
# CONFIG_MFD_LP8788 is not set
CONFIG_MFD_PALMAS=y
# CONFIG_TPS6105X is not set
CONFIG_TPS6507X=y
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=y
CONFIG_MFD_TPS6586X=y
CONFIG_MFD_TPS80031=y
CONFIG_TWL4030_CORE=y
CONFIG_TWL4030_MADC=y
# CONFIG_MFD_TWL4030_AUDIO is not set
CONFIG_TWL6040_CORE=y
# CONFIG_MFD_WL1273_CORE is not set
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
# CONFIG_MFD_ARIZONA_SPI is not set
CONFIG_MFD_WM5102=y
CONFIG_MFD_WM5110=y
CONFIG_MFD_WM8997=y
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
# CONFIG_MFD_WM831X_SPI is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_88PM800=y
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=y
# CONFIG_REGULATOR_ARIZONA is not set
CONFIG_REGULATOR_DA903X=y
CONFIG_REGULATOR_DA9052=y
CONFIG_REGULATOR_DA9055=y
CONFIG_REGULATOR_DA9063=y
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_ISL6271A=y
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8973=y
# CONFIG_REGULATOR_MAX8998 is not set
# CONFIG_REGULATOR_MC13783 is not set
# CONFIG_REGULATOR_MC13892 is not set
CONFIG_REGULATOR_PALMAS=y
CONFIG_REGULATOR_PCAP=y
CONFIG_REGULATOR_PCF50633=y
# CONFIG_REGULATOR_PFUZE100 is not set
# CONFIG_REGULATOR_RC5T583 is not set
# CONFIG_REGULATOR_TPS51632 is not set
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
# CONFIG_REGULATOR_TPS6507X is not set
CONFIG_REGULATOR_TPS65217=y
# CONFIG_REGULATOR_TPS6524X is not set
# CONFIG_REGULATOR_TPS6586X is not set
CONFIG_REGULATOR_TPS80031=y
CONFIG_REGULATOR_TWL4030=y
CONFIG_REGULATOR_WM831X=y
CONFIG_REGULATOR_WM8400=y
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
CONFIG_VGA_SWITCHEROO=y
# CONFIG_DRM is not set
CONFIG_VGASTATE=y
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_DDC=y
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_SVGALIB=y
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
CONFIG_FB_PM2=y
# CONFIG_FB_PM2_FIFO_DISCONNECT is not set
CONFIG_FB_CYBER2000=y
CONFIG_FB_CYBER2000_DDC=y
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
CONFIG_FB_IMSTT=y
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
# CONFIG_FB_VESA is not set
# CONFIG_FB_EFI is not set
# CONFIG_FB_N411 is not set
CONFIG_FB_HGA=y
CONFIG_FB_S1D13XXX=y
CONFIG_FB_NVIDIA=y
# CONFIG_FB_NVIDIA_I2C is not set
# CONFIG_FB_NVIDIA_DEBUG is not set
CONFIG_FB_NVIDIA_BACKLIGHT=y
CONFIG_FB_RIVA=y
CONFIG_FB_RIVA_I2C=y
CONFIG_FB_RIVA_DEBUG=y
# CONFIG_FB_RIVA_BACKLIGHT is not set
CONFIG_FB_I740=y
# CONFIG_FB_LE80578 is not set
CONFIG_FB_MATROX=y
# CONFIG_FB_MATROX_MILLENIUM is not set
# CONFIG_FB_MATROX_MYSTIQUE is not set
# CONFIG_FB_MATROX_G is not set
# CONFIG_FB_MATROX_I2C is not set
CONFIG_FB_RADEON=y
CONFIG_FB_RADEON_I2C=y
# CONFIG_FB_RADEON_BACKLIGHT is not set
CONFIG_FB_RADEON_DEBUG=y
CONFIG_FB_ATY128=y
CONFIG_FB_ATY128_BACKLIGHT=y
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
CONFIG_FB_SAVAGE=y
CONFIG_FB_SAVAGE_I2C=y
CONFIG_FB_SAVAGE_ACCEL=y
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
CONFIG_FB_NEOMAGIC=y
CONFIG_FB_KYRO=y
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
CONFIG_FB_VT8623=y
CONFIG_FB_TRIDENT=y
CONFIG_FB_ARK=y
CONFIG_FB_PM3=y
CONFIG_FB_CARMINE=y
# CONFIG_FB_CARMINE_DRAM_EVAL is not set
CONFIG_CARMINE_DRAM_CUSTOM=y
CONFIG_FB_GEODE=y
CONFIG_FB_GEODE_LX=y
CONFIG_FB_GEODE_GX=y
CONFIG_FB_GEODE_GX1=y
# CONFIG_FB_TMIO is not set
CONFIG_FB_SM501=y
CONFIG_FB_GOLDFISH=y
CONFIG_FB_VIRTUAL=y
# CONFIG_FB_METRONOME is not set
CONFIG_FB_MB862XX=y
CONFIG_FB_MB862XX_PCI_GDC=y
CONFIG_FB_MB862XX_I2C=y
CONFIG_FB_BROADSHEET=y
CONFIG_FB_AUO_K190X=y
CONFIG_FB_AUO_K1900=y
# CONFIG_FB_AUO_K1901 is not set
# CONFIG_FB_SIMPLE is not set
CONFIG_EXYNOS_VIDEO=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
CONFIG_BACKLIGHT_PWM=y
CONFIG_BACKLIGHT_DA903X=y
CONFIG_BACKLIGHT_DA9052=y
CONFIG_BACKLIGHT_APPLE=y
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=y
CONFIG_BACKLIGHT_ADP8860=y
# CONFIG_BACKLIGHT_ADP8870 is not set
CONFIG_BACKLIGHT_PCF50633=y
# CONFIG_BACKLIGHT_LM3630A is not set
CONFIG_BACKLIGHT_LM3639=y
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_PANDORA=y
# CONFIG_BACKLIGHT_TPS65217 is not set
CONFIG_BACKLIGHT_LV5207LP=y
CONFIG_BACKLIGHT_BD6107=y
# CONFIG_LOGO is not set
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_HWDEP=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_COMPRESS_OFFLOAD=y
CONFIG_SND_JACK=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
# CONFIG_SND_MIXER_OSS is not set
# CONFIG_SND_PCM_OSS is not set
# CONFIG_SND_SEQUENCER_OSS is not set
CONFIG_SND_HRTIMER=y
# CONFIG_SND_SEQ_HRTIMER_DEFAULT is not set
# CONFIG_SND_DYNAMIC_MINORS is not set
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_VERBOSE_PRINTK=y
# CONFIG_SND_DEBUG is not set
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_RAWMIDI_SEQ=y
CONFIG_SND_OPL3_LIB_SEQ=y
CONFIG_SND_OPL4_LIB_SEQ=y
CONFIG_SND_SBAWE_SEQ=y
# CONFIG_SND_EMU10K1_SEQ is not set
CONFIG_SND_MPU401_UART=y
CONFIG_SND_OPL3_LIB=y
CONFIG_SND_OPL4_LIB=y
CONFIG_SND_DRIVERS=y
# CONFIG_SND_DUMMY is not set
# CONFIG_SND_ALOOP is not set
CONFIG_SND_VIRMIDI=y
# CONFIG_SND_MTPAV is not set
# CONFIG_SND_MTS64 is not set
CONFIG_SND_SERIAL_U16550=y
# CONFIG_SND_MPU401 is not set
CONFIG_SND_PORTMAN2X4=y
CONFIG_SND_WSS_LIB=y
CONFIG_SND_SB_COMMON=y
CONFIG_SND_SB8_DSP=y
CONFIG_SND_SB16_DSP=y
CONFIG_SND_ISA=y
CONFIG_SND_ADLIB=y
CONFIG_SND_AD1816A=y
CONFIG_SND_AD1848=y
# CONFIG_SND_ALS100 is not set
CONFIG_SND_AZT1605=y
CONFIG_SND_AZT2316=y
CONFIG_SND_AZT2320=y
CONFIG_SND_CMI8328=y
# CONFIG_SND_CMI8330 is not set
# CONFIG_SND_CS4231 is not set
CONFIG_SND_CS4236=y
CONFIG_SND_ES1688=y
CONFIG_SND_ES18XX=y
# CONFIG_SND_SC6000 is not set
CONFIG_SND_GUSCLASSIC=y
CONFIG_SND_GUSEXTREME=y
CONFIG_SND_GUSMAX=y
# CONFIG_SND_INTERWAVE is not set
# CONFIG_SND_INTERWAVE_STB is not set
# CONFIG_SND_JAZZ16 is not set
# CONFIG_SND_OPL3SA2 is not set
CONFIG_SND_OPTI92X_AD1848=y
CONFIG_SND_OPTI92X_CS4231=y
CONFIG_SND_OPTI93X=y
CONFIG_SND_MIRO=y
CONFIG_SND_SB8=y
# CONFIG_SND_SB16 is not set
CONFIG_SND_SBAWE=y
# CONFIG_SND_SB16_CSP is not set
CONFIG_SND_SSCAPE=y
CONFIG_SND_WAVEFRONT=y
CONFIG_SND_MSND_PINNACLE=y
CONFIG_SND_MSND_CLASSIC=y
# CONFIG_SND_PCI is not set
CONFIG_SND_SPI=y
CONFIG_SND_AT73C213=y
CONFIG_SND_AT73C213_TARGET_BITRATE=48000
# CONFIG_SND_FIREWIRE is not set
CONFIG_SND_SOC=y
CONFIG_SND_ATMEL_SOC=y
CONFIG_SND_SOC_I2C_AND_SPI=y
CONFIG_SND_SIMPLE_CARD=y
CONFIG_SOUND_PRIME=y
# CONFIG_SOUND_MSNDCLAS is not set
# CONFIG_SOUND_MSNDPIN is not set
# CONFIG_SOUND_OSS is not set

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
CONFIG_UHID=y
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
CONFIG_HID_AUREAL=y
# CONFIG_HID_BELKIN is not set
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_PRODIKEYS=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
CONFIG_DRAGONRISE_FF=y
CONFIG_HID_EMS_FF=y
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_EZKEY is not set
CONFIG_HID_KEYTOUCH=y
CONFIG_HID_KYE=y
CONFIG_HID_UCLOGIC=y
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_GYRATION is not set
CONFIG_HID_ICADE=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LENOVO_TPKBD=y
CONFIG_HID_LOGITECH=y
# CONFIG_HID_LOGITECH_DJ is not set
CONFIG_LOGITECH_FF=y
CONFIG_LOGIRUMBLEPAD2_FF=y
CONFIG_LOGIG940_FF=y
# CONFIG_LOGIWHEELS_FF is not set
CONFIG_HID_MAGICMOUSE=y
# CONFIG_HID_MICROSOFT is not set
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
# CONFIG_HID_PETALYNX is not set
CONFIG_HID_PICOLCD=y
# CONFIG_HID_PICOLCD_FB is not set
# CONFIG_HID_PICOLCD_BACKLIGHT is not set
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PRIMAX=y
CONFIG_HID_SAITEK=y
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SPEEDLINK=y
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
CONFIG_HID_GREENASIA=y
CONFIG_GREENASIA_FF=y
CONFIG_HID_SMARTJOYPLUS=y
CONFIG_SMARTJOYPLUS_FF=y
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_WACOM=y
# CONFIG_HID_WIIMOTE is not set
CONFIG_HID_XINMO=y
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_USB_PHY is not set
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_SAMSUNG_USB2PHY is not set
# CONFIG_SAMSUNG_USB3PHY is not set
# CONFIG_USB_GADGET is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
CONFIG_MEMSTICK_JMICRON_38X=y
CONFIG_MEMSTICK_R592=y
CONFIG_MEMSTICK_REALTEK_PCI=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
CONFIG_LEDS_LM3530=y
# CONFIG_LEDS_LM3533 is not set
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_PCA9532=y
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
# CONFIG_LEDS_LP5523 is not set
# CONFIG_LEDS_LP5562 is not set
CONFIG_LEDS_LP8501=y
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_PCA9685=y
CONFIG_LEDS_WM831X_STATUS=y
CONFIG_LEDS_DA903X=y
# CONFIG_LEDS_DA9052 is not set
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_PWM=y
# CONFIG_LEDS_REGULATOR is not set
CONFIG_LEDS_BD2802=y
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_OT200=y
# CONFIG_LEDS_BLINKM is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
# CONFIG_LEDS_TRIGGER_CAMERA is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_INFINIBAND=y
CONFIG_INFINIBAND_USER_MAD=y
# CONFIG_INFINIBAND_USER_ACCESS is not set
CONFIG_INFINIBAND_ADDR_TRANS=y
# CONFIG_INFINIBAND_MTHCA is not set
CONFIG_INFINIBAND_AMSO1100=y
CONFIG_INFINIBAND_AMSO1100_DEBUG=y
CONFIG_MLX4_INFINIBAND=y
# CONFIG_MLX5_INFINIBAND is not set
CONFIG_INFINIBAND_NES=y
# CONFIG_INFINIBAND_NES_DEBUG is not set
# CONFIG_INFINIBAND_OCRDMA is not set
CONFIG_INFINIBAND_IPOIB=y
CONFIG_INFINIBAND_IPOIB_CM=y
# CONFIG_INFINIBAND_IPOIB_DEBUG is not set
CONFIG_EDAC=y
# CONFIG_EDAC_LEGACY_SYSFS is not set
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_MM_EDAC=y
CONFIG_EDAC_AMD76X=y
# CONFIG_EDAC_E7XXX is not set
CONFIG_EDAC_E752X=y
# CONFIG_EDAC_I82875P is not set
CONFIG_EDAC_I82975X=y
# CONFIG_EDAC_I3000 is not set
# CONFIG_EDAC_I3200 is not set
CONFIG_EDAC_X38=y
CONFIG_EDAC_I5400=y
CONFIG_EDAC_I7CORE=y
# CONFIG_EDAC_I82860 is not set
# CONFIG_EDAC_R82600 is not set
# CONFIG_EDAC_I5000 is not set
CONFIG_EDAC_I5100=y
CONFIG_EDAC_I7300=y
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
# CONFIG_RTC_SYSTOHC is not set
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
CONFIG_RTC_DEBUG=y

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
# CONFIG_RTC_INTF_DEV is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM80X=y
CONFIG_RTC_DRV_DS1307=y
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1672=y
# CONFIG_RTC_DRV_DS3232 is not set
# CONFIG_RTC_DRV_MAX6900 is not set
# CONFIG_RTC_DRV_MAX8998 is not set
CONFIG_RTC_DRV_RS5C372=y
CONFIG_RTC_DRV_ISL1208=y
CONFIG_RTC_DRV_ISL12022=y
# CONFIG_RTC_DRV_ISL12057 is not set
# CONFIG_RTC_DRV_X1205 is not set
CONFIG_RTC_DRV_PALMAS=y
CONFIG_RTC_DRV_PCF2127=y
CONFIG_RTC_DRV_PCF8523=y
CONFIG_RTC_DRV_PCF8563=y
# CONFIG_RTC_DRV_PCF8583 is not set
CONFIG_RTC_DRV_M41T80=y
# CONFIG_RTC_DRV_M41T80_WDT is not set
CONFIG_RTC_DRV_BQ32K=y
CONFIG_RTC_DRV_TWL4030=y
CONFIG_RTC_DRV_TPS6586X=y
CONFIG_RTC_DRV_TPS80031=y
CONFIG_RTC_DRV_RC5T583=y
CONFIG_RTC_DRV_S35390A=y
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8581=y
CONFIG_RTC_DRV_RX8025=y
CONFIG_RTC_DRV_EM3027=y
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# SPI RTC drivers
#
CONFIG_RTC_DRV_M41T93=y
# CONFIG_RTC_DRV_M41T94 is not set
# CONFIG_RTC_DRV_DS1305 is not set
# CONFIG_RTC_DRV_DS1390 is not set
CONFIG_RTC_DRV_MAX6902=y
# CONFIG_RTC_DRV_R9701 is not set
CONFIG_RTC_DRV_RS5C348=y
CONFIG_RTC_DRV_DS3234=y
# CONFIG_RTC_DRV_PCF2123 is not set
# CONFIG_RTC_DRV_RX4581 is not set

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
CONFIG_RTC_DRV_DS1511=y
# CONFIG_RTC_DRV_DS1553 is not set
CONFIG_RTC_DRV_DS1742=y
# CONFIG_RTC_DRV_DA9052 is not set
CONFIG_RTC_DRV_DA9055=y
CONFIG_RTC_DRV_STK17TA8=y
# CONFIG_RTC_DRV_M48T86 is not set
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
# CONFIG_RTC_DRV_RP5C01 is not set
CONFIG_RTC_DRV_V3020=y
# CONFIG_RTC_DRV_DS2404 is not set
CONFIG_RTC_DRV_WM831X=y
CONFIG_RTC_DRV_PCF50633=y

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_PCAP=y
# CONFIG_RTC_DRV_MC13XXX is not set
CONFIG_RTC_DRV_MOXART=y

#
# HID Sensor RTC drivers
#
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_INTEL_MID_DMAC=y
# CONFIG_INTEL_IOATDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
# CONFIG_DW_DMAC_PCI is not set
# CONFIG_TIMB_DMA is not set
# CONFIG_PCH_DMA is not set
CONFIG_DMA_ENGINE=y
CONFIG_DMA_ACPI=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=y
CONFIG_AUXDISPLAY=y
# CONFIG_KS0108 is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
# CONFIG_UIO_PDRV_GENIRQ is not set
CONFIG_UIO_DMEM_GENIRQ=y
CONFIG_UIO_AEC=y
CONFIG_UIO_SERCOS3=y
CONFIG_UIO_PCI_GENERIC=y
CONFIG_UIO_NETX=y
CONFIG_UIO_MF624=y
CONFIG_VFIO_IOMMU_TYPE1=y
CONFIG_VFIO=y
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_BALLOON=y
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
CONFIG_ET131X=y
# CONFIG_SLICOSS is not set
CONFIG_ECHO=y
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
CONFIG_PANEL_CHANGE_MESSAGE=y
CONFIG_PANEL_BOOT_MESSAGE=""
CONFIG_DX_SEP=y

#
# IIO staging drivers
#

#
# Accelerometers
#
CONFIG_ADIS16201=y
# CONFIG_ADIS16203 is not set
CONFIG_ADIS16204=y
CONFIG_ADIS16209=y
CONFIG_ADIS16220=y
CONFIG_ADIS16240=y
CONFIG_SCA3000=y

#
# Analog to digital converters
#
CONFIG_AD7291=y
CONFIG_AD799X=y
CONFIG_AD799X_RING_BUFFER=y
# CONFIG_AD7192 is not set
# CONFIG_AD7280 is not set

#
# Analog digital bi-direction converters
#

#
# Capacitance to digital converters
#
CONFIG_AD7150=y
CONFIG_AD7152=y
# CONFIG_AD7746 is not set

#
# Direct Digital Synthesis
#
# CONFIG_AD5930 is not set
# CONFIG_AD9832 is not set
# CONFIG_AD9834 is not set
# CONFIG_AD9850 is not set
CONFIG_AD9852=y
CONFIG_AD9910=y
CONFIG_AD9951=y

#
# Digital gyroscope sensors
#
CONFIG_ADIS16060=y

#
# Network Analyzer, Impedance Converters
#
# CONFIG_AD5933 is not set

#
# Light sensors
#
# CONFIG_SENSORS_ISL29018 is not set
# CONFIG_SENSORS_ISL29028 is not set
CONFIG_TSL2583=y
# CONFIG_TSL2x7x is not set

#
# Magnetometer sensors
#
# CONFIG_SENSORS_HMC5843 is not set

#
# Active energy metering IC
#
CONFIG_ADE7753=y
# CONFIG_ADE7754 is not set
# CONFIG_ADE7758 is not set
# CONFIG_ADE7759 is not set
CONFIG_ADE7854=y
CONFIG_ADE7854_I2C=y
CONFIG_ADE7854_SPI=y

#
# Resolver to digital converters
#
# CONFIG_AD2S90 is not set

#
# Triggers - standalone
#
# CONFIG_IIO_PERIODIC_RTC_TRIGGER is not set
CONFIG_IIO_DUMMY_EVGEN=y
CONFIG_IIO_SIMPLE_DUMMY=y
CONFIG_IIO_SIMPLE_DUMMY_EVENTS=y
CONFIG_IIO_SIMPLE_DUMMY_BUFFER=y
# CONFIG_ZSMALLOC is not set
CONFIG_FB_SM7XX=y
CONFIG_CRYSTALHD=y
CONFIG_CXT1E1=y
CONFIG_SBE_PMCC4_NCOMM=y
# CONFIG_FB_XGI is not set
CONFIG_ACPI_QUICKSTART=y
CONFIG_SBE_2T3E3=y
CONFIG_FT1000=y

#
# Speakup console speech
#
CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4=y
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
CONFIG_ANDROID=y
CONFIG_ANDROID_BINDER_IPC=y
# CONFIG_ASHMEM is not set
# CONFIG_ANDROID_LOGGER is not set
# CONFIG_ANDROID_TIMED_OUTPUT is not set
# CONFIG_ANDROID_LOW_MEMORY_KILLER is not set
# CONFIG_ANDROID_INTF_ALARM_DEV is not set
# CONFIG_SYNC is not set
# CONFIG_NET_VENDOR_SILICOM is not set
CONFIG_DGRP=y
# CONFIG_FIREWIRE_SERIAL is not set
CONFIG_XILLYBUS=y
CONFIG_XILLYBUS_PCIE=y
CONFIG_DGNC=y
CONFIG_DGAP=y
# CONFIG_X86_PLATFORM_DEVICES is not set
CONFIG_CHROME_PLATFORMS=y

#
# Hardware Spinlock drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
CONFIG_MAILBOX=y
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y
CONFIG_DMAR_TABLE=y
CONFIG_INTEL_IOMMU=y
# CONFIG_INTEL_IOMMU_DEFAULT_ON is not set
CONFIG_INTEL_IOMMU_FLOPPY_WA=y

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=y

#
# DEVFREQ Drivers
#
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=y
# CONFIG_EXTCON_ARIZONA is not set
# CONFIG_EXTCON_PALMAS is not set
CONFIG_MEMORY=y
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
# CONFIG_IIO_BUFFER_CB is not set
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Accelerometers
#
# CONFIG_BMA180 is not set
# CONFIG_IIO_ST_ACCEL_3AXIS is not set
CONFIG_KXSD9=y

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=y
CONFIG_AD7266=y
CONFIG_AD7298=y
CONFIG_AD7476=y
CONFIG_AD7791=y
CONFIG_AD7793=y
# CONFIG_AD7887 is not set
CONFIG_AD7923=y
# CONFIG_MAX1363 is not set
CONFIG_MCP320X=y
# CONFIG_MCP3422 is not set
CONFIG_NAU7802=y
# CONFIG_TI_ADC081C is not set
CONFIG_TI_AM335X_ADC=y
# CONFIG_TWL6030_GPADC is not set

#
# Amplifiers
#
CONFIG_AD8366=y

#
# Hid Sensor IIO Common
#
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_SPI=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
# CONFIG_AD5360 is not set
# CONFIG_AD5380 is not set
CONFIG_AD5421=y
# CONFIG_AD5446 is not set
# CONFIG_AD5449 is not set
# CONFIG_AD5504 is not set
CONFIG_AD5624R_SPI=y
CONFIG_AD5686=y
CONFIG_AD5755=y
CONFIG_AD5764=y
CONFIG_AD5791=y
CONFIG_AD7303=y
CONFIG_MAX517=y
CONFIG_MCP4725=y

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
# CONFIG_AD9523 is not set

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
CONFIG_ADF4350=y

#
# Digital gyroscope sensors
#
# CONFIG_ADIS16080 is not set
# CONFIG_ADIS16130 is not set
CONFIG_ADIS16136=y
# CONFIG_ADIS16260 is not set
CONFIG_ADXRS450=y
# CONFIG_IIO_ST_GYRO_3AXIS is not set
CONFIG_ITG3200=y

#
# Inertial measurement units
#
CONFIG_ADIS16400=y
# CONFIG_ADIS16480 is not set
CONFIG_IIO_ADIS_LIB=y
CONFIG_IIO_ADIS_LIB_BUFFER=y
# CONFIG_INV_MPU6050_IIO is not set

#
# Light sensors
#
CONFIG_ADJD_S311=y
CONFIG_APDS9300=y
CONFIG_CM36651=y
CONFIG_GP2AP020A00F=y
CONFIG_SENSORS_LM3533=y
# CONFIG_TCS3472 is not set
# CONFIG_SENSORS_TSL2563 is not set
CONFIG_TSL4531=y
CONFIG_VCNL4000=y

#
# Magnetometer sensors
#
# CONFIG_MAG3110 is not set
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y
CONFIG_IIO_ST_MAGN_SPI_3AXIS=y

#
# Triggers - standalone
#
# CONFIG_IIO_INTERRUPT_TRIGGER is not set
# CONFIG_IIO_SYSFS_TRIGGER is not set

#
# Pressure sensors
#
CONFIG_IIO_ST_PRESS=y
CONFIG_IIO_ST_PRESS_I2C=y
CONFIG_IIO_ST_PRESS_SPI=y

#
# Temperature sensors
#
# CONFIG_TMP006 is not set
CONFIG_NTB=y
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
CONFIG_VME_CA91CX42=y
# CONFIG_VME_TSI148 is not set

#
# VME Board Drivers
#
CONFIG_VMIVME_7805=y

#
# VME Device Drivers
#
CONFIG_VME_USER=y
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
# CONFIG_PWM_TWL is not set
CONFIG_PWM_TWL_LED=y
CONFIG_IPACK_BUS=y
CONFIG_BOARD_TPCI200=y
# CONFIG_SERIAL_IPOCTAL is not set
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_EXYNOS_MIPI_VIDEO=y
# CONFIG_POWERCAP is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
CONFIG_EDD_OFF=y
# CONFIG_FIRMWARE_MEMMAP is not set
# CONFIG_DELL_RBU is not set
CONFIG_DCDBAS=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#

#
# EFI (Extensible Firmware Interface) Support
#
# CONFIG_EFI_VARS is not set
CONFIG_UEFI_CPER=y

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_FS_POSIX_ACL is not set
CONFIG_EXPORTFS=y
# CONFIG_FILE_LOCKING is not set
# CONFIG_FSNOTIFY is not set
# CONFIG_DNOTIFY is not set
# CONFIG_INOTIFY_USER is not set
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# Pseudo filesystems
#
# CONFIG_PROC_FS is not set
CONFIG_SYSFS=y
# CONFIG_TMPFS is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y
# CONFIG_MISC_FILESYSTEMS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
CONFIG_NLS_CODEPAGE_737=y
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
CONFIG_NLS_CODEPAGE_857=y
# CONFIG_NLS_CODEPAGE_860 is not set
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
CONFIG_NLS_CODEPAGE_866=y
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
# CONFIG_NLS_CODEPAGE_1250 is not set
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
CONFIG_NLS_ISO8859_7=y
# CONFIG_NLS_ISO8859_9 is not set
CONFIG_NLS_ISO8859_13=y
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
# CONFIG_NLS_MAC_ROMAN is not set
# CONFIG_NLS_MAC_CELTIC is not set
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
# CONFIG_NLS_MAC_ROMANIAN is not set
CONFIG_NLS_MAC_TURKISH=y
# CONFIG_NLS_UTF8 is not set
CONFIG_DLM=y
CONFIG_DLM_DEBUG=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
# CONFIG_BOOT_PRINTK_DELAY is not set
CONFIG_DYNAMIC_DEBUG=y

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=1024
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
# CONFIG_MAGIC_SYSRQ is not set
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_DEBUG_OBJECTS=y
CONFIG_DEBUG_OBJECTS_SELFTEST=y
CONFIG_DEBUG_OBJECTS_FREE=y
CONFIG_DEBUG_OBJECTS_TIMERS=y
# CONFIG_DEBUG_OBJECTS_WORK is not set
CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_RB=y
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_DEBUG_PER_CPU_MAPS=y
# CONFIG_DEBUG_HIGHMEM is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=1
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_RT_MUTEX_TESTER=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_LOCK_ALLOC=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_WRITECOUNT=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_SG is not set
CONFIG_DEBUG_NOTIFIERS=y
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_SPARSE_RCU_POINTER is not set
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
# CONFIG_RCU_CPU_STALL_INFO is not set
CONFIG_RCU_TRACE=y
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_CPU_NOTIFIER_ERROR_INJECT=y
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
CONFIG_FAULT_INJECTION=y
# CONFIG_FAIL_PAGE_ALLOC is not set
CONFIG_FAULT_INJECTION_DEBUG_FS=y
CONFIG_FAULT_INJECTION_STACKTRACE_FILTER=y
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
CONFIG_TEST_LIST_SORT=y
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=y
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_TEST_STRING_HELPERS is not set
CONFIG_TEST_KSTRTOX=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_FIREWIRE_OHCI_REMOTE_DMA is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
# CONFIG_EARLY_PRINTK_EFI is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_RODATA is not set
# CONFIG_DOUBLEFAULT is not set
CONFIG_DEBUG_TLBFLUSH=y
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
CONFIG_IO_DELAY_UDELAY=y
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=2
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
CONFIG_DEBUG_NMI_SELFTEST=y
CONFIG_X86_DEBUG_STATIC_CPU_HAS=y

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_TRUSTED_KEYS=y
# CONFIG_ENCRYPTED_KEYS is not set
CONFIG_KEYS_DEBUG_PROC_KEYS=y
CONFIG_SECURITY_DMESG_RESTRICT=y
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_INTEL_TXT=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=y
# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
# CONFIG_CRYPTO_CRC32 is not set
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
# CONFIG_CRYPTO_SHA512 is not set
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_586=y
CONFIG_CRYPTO_AES_NI_INTEL=y
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAST_COMMON=y
# CONFIG_CRYPTO_CAST5 is not set
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_FCRYPT is not set
CONFIG_CRYPTO_KHAZAD=y
# CONFIG_CRYPTO_SALSA20 is not set
# CONFIG_CRYPTO_SALSA20_586 is not set
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_586 is not set
# CONFIG_CRYPTO_TEA is not set
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_586=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_USER_API=y
# CONFIG_CRYPTO_USER_API_HASH is not set
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
CONFIG_CRYPTO_DEV_PADLOCK_AES=y
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
# CONFIG_CRYPTO_DEV_GEODE is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
# CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE is not set
CONFIG_PUBLIC_KEY_ALGO_RSA=y
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
# CONFIG_XZ_DEC_ARMTHUMB is not set
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_AVERAGE=y
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
# CONFIG_DDR is not set
CONFIG_MPILIB=y
CONFIG_UCS2_STRING=y

--xHFwDpU9dbj6ez1V--
