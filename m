From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [mwifiex/USB8897] Error: Driver 'usb8xxx' is already registered,
 aborting...
Date: Fri, 21 Feb 2014 16:52:35 +0800
Message-ID: <20140221085235.GA2055@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="sdtB3X0nJg68CQEu"
Cc: Nishant Sarmukadam <nishants@marvell.com>,
	Bing Zhao <bzhao@marvell.com>,
	Frank Huang <frankh@marvell.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Yogesh Ashok Powar <yogeshp@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

I got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
commit 68458dede7e0055198318dcb0318df3b4f419507
CommitDate: Mon Jan 13 14:46:59 2014 -0500

    mwifiex: add USB8897 support
    
[    6.211307] Error: Driver 'usb8xxx' is already registered, aborting...
[    6.211307] Error: Driver 'usb8xxx' is already registered, aborting...
[    6.217261] mwifiex_usb: Driver register failed!
[    6.217261] mwifiex_usb: Driver register failed!

git bisect start 6d0abeca3242a88cab8232e4acd7e2bf088f3bc2 v3.13 --
git bisect  bad e914e3f48d0f3978d1561ae3668908e4c0262acf  # 12:41      7-     17  Merge branch 'for-linus' of git://ftp.arm.linux.org.uk/~rmk/linux-arm
git bisect good 0d90d638720ba14874e34cbd8766e4dc3f14f458  # 12:55     27+     27  Merge tag 'for-f2fs-3.14' of git://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs
git bisect  bad b2e448eca1a52fea181905845728ae00a138d84e  # 12:59      0-      3  Merge branch 'ipmi' (ipmi patches from Corey Minyard)
git bisect good 91466574be1a3701fab4abf5ac1539b556575a81  # 13:04     27+     27  Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/git/rzhang/linux
git bisect good 7ae0e06b909e31bf9a396a2326ef09b768d9b4c4  # 13:08     27+     27  Merge tag 'arc-v3.14-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/vgupta/arc
git bisect  bad 4ba9920e5e9c0e16b5ed24292d45322907bb9035  # 13:12      1-     15  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
git bisect good f6d13daaddeb6e63b15a93bf36a80173bafd29bf  # 13:28     27+     27  Merge branch 'sched-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good 82c477669a4665eb4e52030792051e0559ee2a36  # 13:39     27+     27  Merge branch 'perf-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good ad86c55bac643a745f480d26689d153ec0f38b04  # 13:45     27+     27  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next into for-davem
git bisect good b92ed1688e316d1b4410559272e68b246bdc7d0a  # 13:49     27+     27  Merge branch 'qlcnic'
git bisect good cf84eb0b09c0f09b4c70a648b9dfeec78be61f07  # 13:53     27+     27  Merge branch 'virtio_rx_merging'
git bisect  bad 05d063aa867b7a31b84543400b19f5673afc736c  # 13:58      1-      8  ixgbevf: make use of the dev pointer in the ixgbevf_ring struct
git bisect  bad 0673effd41dba323d6a280ef37b5ef29f3f5a653  # 14:03      4-     11  b43: Fix unload oops if firmware is not available
git bisect good 26b0e411d37a2ca5992d02884dc3fa4e1907e598  # 14:06     27+     27  mac80211_hwsim: restore regulatory testing functionality
git bisect good ec665facde820179d71d0f064e692f449df2b94f  # 14:10     27+     27  Merge tag 'nfc-next-3.14-1' of git://git.kernel.org/pub/scm/linux/kernel/git/sameo/nfc-next
git bisect good 869526b958f59592c46086c11f638824b08d164a  # 14:14     27+     27  ath10k: add trace event for WMI_DEBUG_MESG_EVENTID
git bisect good 4f7b91404cd5da3657a82b00394f4f5dfbff13d6  # 14:20     27+     27  cfg80211: make regulatory_hint() remove REGULATORY_CUSTOM_REG
git bisect  bad b30d49b294fe339719918965594f12eb7967dca0  # 14:23      2-     14  wl12xx: fix tx power setting
git bisect  bad 68458dede7e0055198318dcb0318df3b4f419507  # 14:24      4-     21  mwifiex: add USB8897 support
git bisect good f87f960b2fb802f26ee3b00c19320e57a9c583ff  # 14:29     27+     27  rtlwifi: rtl8192cu: Add new device ID
git bisect  bad d158fc7f36a25e19791d25a55da5623399a2644f  # 14:35      0-      8  Merge tag 'pci-v3.14-fixes-1' of git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci
git bisect  bad 12f1d94f0c8b256c04cb9b6b5dd989c32e44f11b  # 14:35      0-      9  Add linux-next specific files for 20140220

Thanks,
Fengguang

--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-yocto-jaketown-38:20140220222139:x86_64-randconfig-a3-02202054::"
Content-Transfer-Encoding: quoted-printable

early console in setup code
Probing EDD (edd=3Doff to disable)... ok
early console in decompress_kernel
KASLR using RDTSC...

Decompressing Linux... Parsing ELF... Performing relocations... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.14.0-rc3-02129-g63e12bf (kbuild@athens) (gcc=
 version 4.8.1 (Debian 4.8.1-8) ) #2 SMP Thu Feb 20 22:16:44 CST 2014
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 debug apic=3Ddebug sysrq_always_enabled panic=3D10 softlockup_panic=3D1 nm=
i_watchdog=3Dpanic  prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty=
0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-tests/run-queue/kvm/x86_=
64-randconfig-a3-02202054/linux-devel:devel-hourly-2014022021/.vmlinuz-63e1=
2bfe8d8b215605812bb912e54db53356a5d5-20140220222018-3-jaketown branch=3Dlin=
ux-devel/devel-hourly-2014022021 BOOT_IMAGE=3D/kernel/x86_64-randconfig-a3-=
02202054/63e12bfe8d8b215605812bb912e54db53356a5d5/vmlinuz-3.14.0-rc3-02129-=
g63e12bf
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
[    0.000000] e820: last_pfn =3D 0xfffe max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdae0-0x000fdaef] mapped at =
[ffff8800000fdae0]
[    0.000000]   mpc: fdaf0-fdbe4
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x0ac6d000, 0x0ac6dfff] PGTABLE
[    0.000000] BRK [0x0ac6e000, 0x0ac6efff] PGTABLE
[    0.000000] BRK [0x0ac6f000, 0x0ac6ffff] PGTABLE
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
[    0.000000] BRK [0x0ac70000, 0x0ac70fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x0fce6000-0x0ffeffff]
[    0.000000] ACPI: RSDP 0x00000000000FD950 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000000FFFE450 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000000FFFFF80 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000000FFFE490 0011A9 (v01 BXPC   BXDSDT   00=
000001 INTL 20100528)
[    0.000000] ACPI: FACS 0x000000000FFFFF40 000040
[    0.000000] ACPI: SSDT 0x000000000FFFF7A0 000796 (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x000000000FFFF680 000080 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x000000000FFFF640 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000000fffdfff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x0fffdfff]
[    0.000000]   NODE_DATA [mem 0x0fffa000-0x0fffdfff]
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fff9001, boot clock
[    0.000000]  [ffffea0000000000-ffffea00003fffff] PMD -> [ffff88000f00000=
0-ffff88000f3fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x00001000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000]   DMA32 zone: 896 pages used for memmap
[    0.000000]   DMA32 zone: 21 pages reserved
[    0.000000]   DMA32 zone: 65436 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
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
[    0.000000] mapped IOAPIC to ffffffffff5f9000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:2 nr_cpu_ids:2 nr_no=
de_ids:1
[    0.000000] PERCPU: Embedded 25 pages/cpu @ffff88000fa00000 s80192 r0 d2=
2208 u1048576
[    0.000000] pcpu-alloc: s80192 r0 d22208 u1048576 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 1=20
[    0.000000] kvm-clock: cpu 0, msr 0:fff9001, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr fa0ddc0
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Tota=
l pages: 64519
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled panic=3D10 softlockup_panic=
=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D0 console=3DttyS0,115200 consol=
e=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-tests/run-queue/k=
vm/x86_64-randconfig-a3-02202054/linux-devel:devel-hourly-2014022021/.vmlin=
uz-63e12bfe8d8b215605812bb912e54db53356a5d5-20140220222018-3-jaketown branc=
h=3Dlinux-devel/devel-hourly-2014022021 BOOT_IMAGE=3D/kernel/x86_64-randcon=
fig-a3-02202054/63e12bfe8d8b215605812bb912e54db53356a5d5/vmlinuz-3.14.0-rc3=
-02129-g63e12bf
[    0.000000] PID hash table entries: 1024 (order: 1, 8192 bytes)
[    0.000000] Memory: 226828K/261744K available (9276K kernel code, 1588K =
rwdata, 5032K rodata, 888K init, 10236K bss, 34916K reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D2
[    0.000000] NR_IRQS:4352 nr_irqs:512 16
[    0.000000] ACPI: Core revision 20140114
[    0.000000] ACPI: All ACPI Tables successfully acquired
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.14.0-rc3-02129-g63e12bf (kbuild@athens) (gcc=
 version 4.8.1 (Debian 4.8.1-8) ) #2 SMP Thu Feb 20 22:16:44 CST 2014
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 debug apic=3Ddebug sysrq_always_enabled panic=3D10 softlockup_panic=3D1 nm=
i_watchdog=3Dpanic  prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty=
0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-tests/run-queue/kvm/x86_=
64-randconfig-a3-02202054/linux-devel:devel-hourly-2014022021/.vmlinuz-63e1=
2bfe8d8b215605812bb912e54db53356a5d5-20140220222018-3-jaketown branch=3Dlin=
ux-devel/devel-hourly-2014022021 BOOT_IMAGE=3D/kernel/x86_64-randconfig-a3-=
02202054/63e12bfe8d8b215605812bb912e54db53356a5d5/vmlinuz-3.14.0-rc3-02129-=
g63e12bf
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
[    0.000000] e820: last_pfn =3D 0xfffe max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdae0-0x000fdaef] mapped at =
[ffff8800000fdae0]
[    0.000000]   mpc: fdaf0-fdbe4
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x0ac6d000, 0x0ac6dfff] PGTABLE
[    0.000000] BRK [0x0ac6e000, 0x0ac6efff] PGTABLE
[    0.000000] BRK [0x0ac6f000, 0x0ac6ffff] PGTABLE
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
[    0.000000] BRK [0x0ac70000, 0x0ac70fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x0fce6000-0x0ffeffff]
[    0.000000] ACPI: RSDP 0x00000000000FD950 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000000FFFE450 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000000FFFFF80 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000000FFFE490 0011A9 (v01 BXPC   BXDSDT   00=
000001 INTL 20100528)
[    0.000000] ACPI: FACS 0x000000000FFFFF40 000040
[    0.000000] ACPI: SSDT 0x000000000FFFF7A0 000796 (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x000000000FFFF680 000080 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x000000000FFFF640 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000000fffdfff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x0fffdfff]
[    0.000000]   NODE_DATA [mem 0x0fffa000-0x0fffdfff]
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fff9001, boot clock
[    0.000000]  [ffffea0000000000-ffffea00003fffff] PMD -> [ffff88000f00000=
0-ffff88000f3fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x00001000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000]   DMA32 zone: 896 pages used for memmap
[    0.000000]   DMA32 zone: 21 pages reserved
[    0.000000]   DMA32 zone: 65436 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
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
[    0.000000] mapped IOAPIC to ffffffffff5f9000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:2 nr_cpu_ids:2 nr_no=
de_ids:1
[    0.000000] PERCPU: Embedded 25 pages/cpu @ffff88000fa00000 s80192 r0 d2=
2208 u1048576
[    0.000000] pcpu-alloc: s80192 r0 d22208 u1048576 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 1=20
[    0.000000] kvm-clock: cpu 0, msr 0:fff9001, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr fa0ddc0
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Tota=
l pages: 64519
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled panic=3D10 softlockup_panic=
=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D0 console=3DttyS0,115200 consol=
e=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-tests/run-queue/k=
vm/x86_64-randconfig-a3-02202054/linux-devel:devel-hourly-2014022021/.vmlin=
uz-63e12bfe8d8b215605812bb912e54db53356a5d5-20140220222018-3-jaketown branc=
h=3Dlinux-devel/devel-hourly-2014022021 BOOT_IMAGE=3D/kernel/x86_64-randcon=
fig-a3-02202054/63e12bfe8d8b215605812bb912e54db53356a5d5/vmlinuz-3.14.0-rc3=
-02129-g63e12bf
[    0.000000] PID hash table entries: 1024 (order: 1, 8192 bytes)
[    0.000000] Memory: 226828K/261744K available (9276K kernel code, 1588K =
rwdata, 5032K rodata, 888K init, 10236K bss, 34916K reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D2
[    0.000000] NR_IRQS:4352 nr_irqs:512 16
[    0.000000] ACPI: Core revision 20140114
[    0.000000] ACPI: All ACPI Tables successfully acquired
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
[    0.000000]  memory used by lock dependency info: 5855 kB
[    0.000000]  memory used by lock dependency info: 5855 kB
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
[    0.000000]                      A-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                  A-B-B-A deadlock:
[    0.000000]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]              A-B-B-C-C-A deadlock:
[    0.000000]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]              A-B-C-A-B-C deadlock:
[    0.000000]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]          A-B-B-C-C-D-D-A deadlock:
[    0.000000]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]          A-B-C-D-B-D-D-A deadlock:
[    0.000000]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]          A-B-C-D-B-C-D-A deadlock:
[    0.000000]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

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
 |  ok  |  ok  |             |             |  ok  |  ok  |

[    0.000000]            recursive read-lock #2:
[    0.000000]            recursive read-lock #2:             |            =
 |  ok  |  ok  |             |             |  ok  |  ok  |

[    0.000000]             mixed read-write-lock:
[    0.000000]             mixed read-write-lock:             |            =
 |  ok  |  ok  |             |             |  ok  |  ok  |

[    0.000000]             mixed write-read-lock:
[    0.000000]             mixed write-read-lock:             |            =
 |  ok  |  ok  |             |             |  ok  |  ok  |

[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:
[    0.000000]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/12:
[    0.000000]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]      hard-irqs-on + irq-safe-A/21:
[    0.000000]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/21:
[    0.000000]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/12:
[    0.000000]        sirq-safe-A =3D> hirqs-on/12:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/21:
[    0.000000]        sirq-safe-A =3D> hirqs-on/21:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/12:
[    0.000000]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/12:
[    0.000000]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/21:
[    0.000000]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/21:
[    0.000000]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/123:
[    0.000000]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/123:
[    0.000000]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/132:
[    0.000000]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/132:
[    0.000000]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/213:
[    0.000000]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/213:
[    0.000000]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/231:
[    0.000000]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/231:
[    0.000000]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/312:
[    0.000000]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/312:
[    0.000000]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/321:
[    0.000000]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/321:
[    0.000000]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/123:
[    0.000000]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/123:
[    0.000000]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/132:
[    0.000000]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/132:
[    0.000000]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/213:
[    0.000000]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/213:
[    0.000000]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/231:
[    0.000000]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/231:
[    0.000000]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/312:
[    0.000000]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/312:
[    0.000000]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/321:
[    0.000000]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/321:
[    0.000000]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/123:
[    0.000000]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/123:
[    0.000000]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/132:
[    0.000000]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/132:
[    0.000000]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/213:
[    0.000000]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/213:
[    0.000000]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/231:
[    0.000000]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/231:
[    0.000000]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/312:
[    0.000000]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/312:
[    0.000000]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/321:
[    0.000000]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/321:
[    0.000000]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

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
[    0.000000]                ww contexts mixing:  ok  |  ok  |  ok  |  ok =
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
[    0.000000]                           context:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                               try:
[    0.000000]                               try:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                             block:
[    0.000000]                             block:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                          spinlock:
[    0.000000]                          spinlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000] -------------------------------------------------------
[    0.000000] -------------------------------------------------------
[    0.000000] Good, all 253 testcases passed! |
[    0.000000] Good, all 253 testcases passed! |
[    0.000000] ---------------------------------
[    0.000000] ---------------------------------
[    0.000000] ODEBUG: 10 of 10 active objects replaced
[    0.000000] ODEBUG: 10 of 10 active objects replaced
[    0.000000] ODEBUG: selftest passed
[    0.000000] ODEBUG: selftest passed
[    0.000000] hpet clockevent registered
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 1600.064 MHz processor
[    0.000000] tsc: Detected 1600.064 MHz processor
[    0.012000] Calibrating delay loop (skipped) preset value..=20
[    0.012000] Calibrating delay loop (skipped) preset value.. 3200.12 Bogo=
MIPS (lpj=3D6400256)
3200.12 BogoMIPS (lpj=3D6400256)
[    0.014567] pid_max: default: 32768 minimum: 301
[    0.014567] pid_max: default: 32768 minimum: 301
[    0.020355] Dentry cache hash table entries: 32768 (order: 6, 262144 byt=
es)
[    0.020355] Dentry cache hash table entries: 32768 (order: 6, 262144 byt=
es)
[    0.024366] Inode-cache hash table entries: 16384 (order: 5, 131072 byte=
s)
[    0.024366] Inode-cache hash table entries: 16384 (order: 5, 131072 byte=
s)
[    0.028181] Mount-cache hash table entries: 256
[    0.028181] Mount-cache hash table entries: 256
[    0.033500] Initializing cgroup subsys debug
[    0.033500] Initializing cgroup subsys debug
[    0.036069] Initializing cgroup subsys freezer
[    0.036069] Initializing cgroup subsys freezer
[    0.044327] mce: CPU supports 10 MCE banks
[    0.044327] mce: CPU supports 10 MCE banks
[    0.048190] numa_add_cpu cpu 0 node 0: mask now 0
[    0.048190] numa_add_cpu cpu 0 node 0: mask now 0
[    0.052048] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.052048] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.052048] tlb_flushall_shift: 6
[    0.052048] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.052048] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.052048] tlb_flushall_shift: 6
[    0.056462] Freeing SMP alternatives memory: 24K (ffffffff8a268000 - fff=
fffff8a26e000)
[    0.056462] Freeing SMP alternatives memory: 24K (ffffffff8a268000 - fff=
fffff8a26e000)
[    0.076843] Getting VERSION: 50014
[    0.076843] Getting VERSION: 50014
[    0.079885] Getting VERSION: 50014
[    0.079885] Getting VERSION: 50014
[    0.080097] Getting ID: 0
[    0.080097] Getting ID: 0
[    0.084057] Getting ID: ff000000
[    0.084057] Getting ID: ff000000
[    0.088059] Getting LVT0: 8700
[    0.088059] Getting LVT0: 8700
[    0.090670] Getting LVT1: 8400
[    0.090670] Getting LVT1: 8400
[    0.092226] enabled ExtINT on CPU#0
[    0.092226] enabled ExtINT on CPU#0
[    0.101132] ENABLING IO-APIC IRQs
[    0.101132] ENABLING IO-APIC IRQs
[    0.104048] init IO_APIC IRQs
[    0.104048] init IO_APIC IRQs
[    0.106643]  apic 0 pin 0 not connected
[    0.106643]  apic 0 pin 0 not connected
[    0.108110] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.108110] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.112113] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.112113] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.116116] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.116116] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.120113] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.120113] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.124122] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.124122] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.128112] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.128112] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.132114] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.132114] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.136115] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.136115] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.140115] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.140115] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.148096] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.148096] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.152109] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.152109] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.156133] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.156133] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.160119] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.160119] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.164108] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.164108] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.168131] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.168131] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.172083]  apic 0 pin 16 not connected
[    0.172083]  apic 0 pin 16 not connected
[    0.176024]  apic 0 pin 17 not connected
[    0.176024]  apic 0 pin 17 not connected
[    0.180025]  apic 0 pin 18 not connected
[    0.180025]  apic 0 pin 18 not connected
[    0.184024]  apic 0 pin 19 not connected
[    0.184024]  apic 0 pin 19 not connected
[    0.188025]  apic 0 pin 20 not connected
[    0.188025]  apic 0 pin 20 not connected
[    0.192025]  apic 0 pin 21 not connected
[    0.192025]  apic 0 pin 21 not connected
[    0.196024]  apic 0 pin 22 not connected
[    0.196024]  apic 0 pin 22 not connected
[    0.200024]  apic 0 pin 23 not connected
[    0.200024]  apic 0 pin 23 not connected
[    0.204306] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.204306] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.208029] smpboot: CPU0:=20
[    0.208029] smpboot: CPU0: Intel Intel Common KVM processorCommon KVM pr=
ocessor (fam: 0f, model: 06 (fam: 0f, model: 06, stepping: 01)
, stepping: 01)
[    0.222321] Using local APIC timer interrupts.
[    0.222321] calibrating APIC timer ...
[    0.222321] Using local APIC timer interrupts.
[    0.222321] calibrating APIC timer ...
[    0.228000] ... lapic delta =3D 6249824
[    0.228000] ... lapic delta =3D 6249824
[    0.228000] ... PM-Timer delta =3D 357940
[    0.228000] ... PM-Timer delta =3D 357940
[    0.228000] ... PM-Timer result ok
[    0.228000] ... PM-Timer result ok
[    0.228000] ..... delta 6249824
[    0.228000] ..... delta 6249824
[    0.228000] ..... mult: 268427896
[    0.228000] ..... mult: 268427896
[    0.228000] ..... calibration result: 3999887
[    0.228000] ..... calibration result: 3999887
[    0.228000] ..... CPU clock speed is 1599.3597 MHz.
[    0.228000] ..... CPU clock speed is 1599.3597 MHz.
[    0.228000] ..... host bus clock speed is 999.3887 MHz.
[    0.228000] ..... host bus clock speed is 999.3887 MHz.
[    0.230806] Performance Events:=20
[    0.230806] Performance Events: unsupported Netburst CPU model 6 unsuppo=
rted Netburst CPU model 6 no PMU driver, software events only.
no PMU driver, software events only.
[    0.249166] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.249166] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.256745] x86: Booting SMP configuration:
[    0.256745] x86: Booting SMP configuration:
[    0.260028] .... node  #0, CPUs: =20
[    0.260028] .... node  #0, CPUs:         #1 #1
[    0.248970] kvm-clock: cpu 1, msr 0:fff9041, secondary cpu clock
[    0.248970] masked ExtINT on CPU#1
[    0.248970] numa_add_cpu cpu 1 node 0: mask now 0-1
[    0.284489] KVM setup async PF for cpu 1
[    0.284489] KVM setup async PF for cpu 1
[    0.284718] x86: Booted up 1 node, 2 CPUs
[    0.284718] x86: Booted up 1 node, 2 CPUs
[    0.284753] ----------------
[    0.284753] ----------------
[    0.284755] | NMI testsuite:
[    0.284755] | NMI testsuite:
[    0.284756] --------------------
[    0.284756] --------------------
[    0.284489]   remote IPI:
[    0.284489]   remote IPI:
[    0.284489] kvm-stealtime: cpu 1, msr fb0ddc0
[    0.284489] kvm-stealtime: cpu 1, msr fb0ddc0
[    0.312178]   ok  |
[    0.312178]   ok  |

[    0.313827]    local IPI:
[    0.313827]    local IPI:  ok  |  ok  |

[    0.336068] --------------------
[    0.336068] --------------------
[    0.338401] Good, all   2 testcases passed! |
[    0.338401] Good, all   2 testcases passed! |
[    0.340017] ---------------------------------
[    0.340017] ---------------------------------
[    0.344020] smpboot: Total of 2 processors activated (6400.25 BogoMIPS)
[    0.344020] smpboot: Total of 2 processors activated (6400.25 BogoMIPS)
[    0.355647] devtmpfs: initialized
[    0.355647] devtmpfs: initialized
[    0.377914] atomic64 test passed for x86-64 platform with CX8 and with S=
SE
[    0.377914] atomic64 test passed for x86-64 platform with CX8 and with S=
SE
[    0.385867] regulator-dummy: no parameters
[    0.385867] regulator-dummy: no parameters
[    0.393266] NET: Registered protocol family 16
[    0.393266] NET: Registered protocol family 16
[    0.403758] cpuidle: using governor ladder
[    0.403758] cpuidle: using governor ladder
[    0.404028] cpuidle: using governor menu
[    0.404028] cpuidle: using governor menu
[    0.413662] ACPI: bus type PCI registered
[    0.413662] ACPI: bus type PCI registered
[    0.416205] PCI: Using configuration type 1 for base access
[    0.416205] PCI: Using configuration type 1 for base access
[    0.519647] ACPI: Added _OSI(Module Device)
[    0.519647] ACPI: Added _OSI(Module Device)
[    0.520025] ACPI: Added _OSI(Processor Device)
[    0.520025] ACPI: Added _OSI(Processor Device)
[    0.524026] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.524026] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.528024] ACPI: Added _OSI(Processor Aggregator Device)
[    0.528024] ACPI: Added _OSI(Processor Aggregator Device)
[    0.559830] ACPI: Interpreter enabled
[    0.559830] ACPI: Interpreter enabled
[    0.560047] ACPI: (supports S0 S5)
[    0.560047] ACPI: (supports S0 S5)
[    0.564014] ACPI: Using IOAPIC for interrupt routing
[    0.564014] ACPI: Using IOAPIC for interrupt routing
[    0.566853] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.566853] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.599817] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.599817] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.600035] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.600035] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.604126] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.604126] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.609634] PCI host bridge to bus 0000:00
[    0.609634] PCI host bridge to bus 0000:00
[    0.612023] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.612023] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.616020] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.616020] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.620019] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.620019] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.623404] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.623404] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.624020] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.624020] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.628189] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.628189] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.637830] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.637830] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.642072] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.642072] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.652025] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.652025] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.659054] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.659054] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.660968] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.660968] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.664044] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.664044] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.672545] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.672545] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.677613] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.677613] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.684114] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.684114] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.704123] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.704123] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.710161] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.710161] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.716024] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    0.716024] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    0.724050] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.724050] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.745716] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    0.745716] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    0.752927] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.752927] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.758007] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.758007] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.778101] ACPI: PCI Interrupt Link [LNKA] (IRQs
[    0.778101] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 5 *10 *10 11 11))

[    0.782006] ACPI: PCI Interrupt Link [LNKB] (IRQs
[    0.782006] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 5 *10 *10 11 11))

[    0.789574] ACPI: PCI Interrupt Link [LNKC] (IRQs
[    0.789574] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 5 10 10 *11 *11))

[    0.794223] ACPI: PCI Interrupt Link [LNKD] (IRQs
[    0.794223] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 5 10 10 *11 *11))

[    0.801233] ACPI: PCI Interrupt Link [LNKS] (IRQs
[    0.801233] ACPI: PCI Interrupt Link [LNKS] (IRQs *9 *9))

[    0.809426] ACPI:=20
[    0.809426] ACPI: Enabled 16 GPEs in block 00 to 0FEnabled 16 GPEs in bl=
ock 00 to 0F

[    0.817945] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.817945] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.824035] vgaarb: loaded
[    0.824035] vgaarb: loaded
[    0.828020] vgaarb: bridge control possible 0000:00:02.0
[    0.828020] vgaarb: bridge control possible 0000:00:02.0
[    0.833223] ACPI: bus type USB registered
[    0.833223] ACPI: bus type USB registered
[    0.836355] usbcore: registered new interface driver usbfs
[    0.836355] usbcore: registered new interface driver usbfs
[    0.840181] usbcore: registered new interface driver hub
[    0.840181] usbcore: registered new interface driver hub
[    0.849211] usbcore: registered new device driver usb
[    0.849211] usbcore: registered new device driver usb
[    0.852511] media: Linux media interface: v0.10
[    0.852511] media: Linux media interface: v0.10
[    0.856255] Linux video capture interface: v2.00
[    0.856255] Linux video capture interface: v2.00
[    0.860240] pps_core: LinuxPPS API ver. 1 registered
[    0.860240] pps_core: LinuxPPS API ver. 1 registered
[    0.864020] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.864020] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.872091] PTP clock support registered
[    0.872091] PTP clock support registered
[    0.875515] EDAC MC: Ver: 3.0.0
[    0.875515] EDAC MC: Ver: 3.0.0
[    0.881185] EDAC DEBUG: edac_mc_sysfs_init: device mc created
[    0.881185] EDAC DEBUG: edac_mc_sysfs_init: device mc created
[    0.888023] Advanced Linux Sound Architecture Driver Initialized.
[    0.888023] Advanced Linux Sound Architecture Driver Initialized.
[    0.892055] PCI: Using ACPI for IRQ routing
[    0.892055] PCI: Using ACPI for IRQ routing
[    0.896038] PCI: pci_cache_line_size set to 64 bytes
[    0.896038] PCI: pci_cache_line_size set to 64 bytes
[    0.900364] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.900364] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.904082] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.904082] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.913665] NET: Registered protocol family 23
[    0.913665] NET: Registered protocol family 23
[    0.916212] NET: Registered protocol family 8
[    0.916212] NET: Registered protocol family 8
[    0.920023] NET: Registered protocol family 20
[    0.920023] NET: Registered protocol family 20
[    0.929212] cfg80211: Calling CRDA to update world regulatory domain
[    0.929212] cfg80211: Calling CRDA to update world regulatory domain
[    0.932461] nfc: nfc_init: NFC Core ver 0.1
[    0.932461] nfc: nfc_init: NFC Core ver 0.1
[    0.936242] NET: Registered protocol family 39
[    0.936242] NET: Registered protocol family 39
[    0.944013] Switched to clocksource kvm-clock
[    0.944013] Switched to clocksource kvm-clock
[    0.949475] FS-Cache: Loaded
[    0.949475] FS-Cache: Loaded
[    0.952389] pnp: PnP ACPI init
[    0.952389] pnp: PnP ACPI init
[    0.955231] ACPI: bus type PNP registered
[    0.955231] ACPI: bus type PNP registered
[    0.958978] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    0.958978] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    0.966208] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.966208] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.972101] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    0.972101] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    0.979194] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.979194] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.984976] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    0.984976] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    0.992219] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.992219] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.998064] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    0.998064] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    1.004894] pnp 00:03: [dma 2]
[    1.004894] pnp 00:03: [dma 2]
[    1.007932] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.007932] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.013872] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    1.013872] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    1.021029] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.021029] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.027091] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    1.027091] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    1.034452] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.034452] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.039748] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.039748] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.046304] pnp: PnP ACPI: found 7 devices
[    1.046304] pnp: PnP ACPI: found 7 devices
[    1.049861] ACPI: bus type PNP unregistered
[    1.049861] ACPI: bus type PNP unregistered
[    1.064712] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.064712] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.069422] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.069422] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.073989] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.073989] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.078917] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.078917] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.084315] NET: Registered protocol family 1
[    1.084315] NET: Registered protocol family 1
[    1.087819] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.087819] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.092694] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.092694] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.097298] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.097298] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.102246] pci 0000:00:02.0: Boot video device
[    1.102246] pci 0000:00:02.0: Boot video device
[    1.106007] PCI: CLS 0 bytes, default 64
[    1.106007] PCI: CLS 0 bytes, default 64
[    1.110254] Unpacking initramfs...
[    1.110254] Unpacking initramfs...
[    1.405881] Freeing initrd memory: 3112K (ffff88000fce6000 - ffff88000ff=
f0000)
[    1.405881] Freeing initrd memory: 3112K (ffff88000fce6000 - ffff88000ff=
f0000)
[    1.535789] DMA-API: preallocated 65536 debug entries
[    1.535789] DMA-API: preallocated 65536 debug entries
[    1.539801] DMA-API: debugging enabled by kernel config
[    1.539801] DMA-API: debugging enabled by kernel config
[    1.545836] kvm: no hardware support
[    1.545836] kvm: no hardware support
[    1.549146] has_svm: not amd
[    1.549146] has_svm: not amd
[    1.551706] kvm: no hardware support
[    1.551706] kvm: no hardware support
[    1.556481] Machine check injector initialized
[    1.556481] Machine check injector initialized
[    1.561109] microcode: CPU0 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    1.561109] microcode: CPU0 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    1.564855] microcode: CPU1 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    1.564855] microcode: CPU1 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    1.570001] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.f=
snet.co.uk>, Peter Oruba
[    1.570001] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.f=
snet.co.uk>, Peter Oruba
[    1.580608] camellia-x86_64: performance on this CPU would be suboptimal=
: disabling camellia-x86_64.
[    1.580608] camellia-x86_64: performance on this CPU would be suboptimal=
: disabling camellia-x86_64.
[    1.580796] cryptomgr_test (24) used greatest stack depth: 6648 bytes le=
ft
[    1.580796] cryptomgr_test (24) used greatest stack depth: 6648 bytes le=
ft
[    1.594554] blowfish-x86_64: performance on this CPU would be suboptimal=
: disabling blowfish-x86_64.
[    1.594554] blowfish-x86_64: performance on this CPU would be suboptimal=
: disabling blowfish-x86_64.
[    1.602919] cryptomgr_test (25) used greatest stack depth: 6328 bytes le=
ft
[    1.602919] cryptomgr_test (25) used greatest stack depth: 6328 bytes le=
ft
[    1.602943] twofish-x86_64-3way: performance on this CPU would be subopt=
imal: disabling twofish-x86_64-3way.
[    1.602943] twofish-x86_64-3way: performance on this CPU would be subopt=
imal: disabling twofish-x86_64-3way.
[    1.603268] sha1_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.603268] sha1_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.603271] PCLMULQDQ-NI instructions are not detected.
[    1.603271] PCLMULQDQ-NI instructions are not detected.
[    1.603273] sha512_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.603273] sha512_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.603276] AVX or AES-NI instructions are not detected.
[    1.603276] AVX or AES-NI instructions are not detected.
[    1.603278] AVX instructions are not detected.
[    1.603278] AVX instructions are not detected.
[    1.603280] AVX instructions are not detected.
[    1.603280] AVX instructions are not detected.
[    1.603282] AVX instructions are not detected.
[    1.603282] AVX instructions are not detected.
[    1.603284] AVX2 or AES-NI instructions are not detected.
[    1.603284] AVX2 or AES-NI instructions are not detected.
[    1.603286] AVX2 instructions are not detected.
[    1.603286] AVX2 instructions are not detected.
[    1.682768] Initializing RT-Tester: OK
[    1.682768] Initializing RT-Tester: OK
[    1.689226] futex hash table entries: 512 (order: 4, 65536 bytes)
[    1.689226] futex hash table entries: 512 (order: 4, 65536 bytes)
[    1.694891] Initialise system trusted keyring
[    1.694891] Initialise system trusted keyring
[    1.699167] audit: initializing netlink subsys (disabled)
[    1.699167] audit: initializing netlink subsys (disabled)
[    1.704467] audit: type=3D2000 audit(1392906036.196:1): initialized
[    1.704467] audit: type=3D2000 audit(1392906036.196:1): initialized
[    1.713572] VFS: Disk quotas dquot_6.5.2
[    1.713572] VFS: Disk quotas dquot_6.5.2
[    1.717386] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.717386] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.728933] cryptomgr_test (42) used greatest stack depth: 6056 bytes le=
ft
[    1.728933] cryptomgr_test (42) used greatest stack depth: 6056 bytes le=
ft
[    1.734753] cryptomgr_test (43) used greatest stack depth: 5832 bytes le=
ft
[    1.734753] cryptomgr_test (43) used greatest stack depth: 5832 bytes le=
ft
[    1.758421] cryptomgr_test (64) used greatest stack depth: 5416 bytes le=
ft
[    1.758421] cryptomgr_test (64) used greatest stack depth: 5416 bytes le=
ft
[    1.764467] alg: No test for crc32 (crc32-table)
[    1.764467] alg: No test for crc32 (crc32-table)
[    1.770633] alg: No test for lz4 (lz4-generic)
[    1.770633] alg: No test for lz4 (lz4-generic)
[    1.775190] alg: No test for lz4hc (lz4hc-generic)
[    1.775190] alg: No test for lz4hc (lz4hc-generic)
[    1.780180] alg: No test for stdrng (krng)
[    1.780180] alg: No test for stdrng (krng)
[    1.810005] alg: No test for fips(ansi_cprng) (fips_ansi_cprng)
[    1.810005] alg: No test for fips(ansi_cprng) (fips_ansi_cprng)
[    1.815355] NET: Registered protocol family 38
[    1.815355] NET: Registered protocol family 38
[    1.819277] Key type asymmetric registered
[    1.819277] Key type asymmetric registered
[    1.827296] list_sort_test: start testing list_sort()
[    1.827296] list_sort_test: start testing list_sort()
[    1.833468] xz_dec_test: module loaded
[    1.833468] xz_dec_test: module loaded
[    1.836257] xz_dec_test: Create a device node with 'mknod xz_dec_test c =
249 0' and write .xz files to it.
[    1.836257] xz_dec_test: Create a device node with 'mknod xz_dec_test c =
249 0' and write .xz files to it.
[    1.846116] rbtree testing
[    1.846116] rbtree testing -> 17619 cycles
 -> 17619 cycles
[    3.048565] augmented rbtree testing
[    3.048565] augmented rbtree testing -> 23793 cycles
 -> 23793 cycles
[    4.669203] tsc: Refined TSC clocksource calibration: 1599.925 MHz
[    4.669203] tsc: Refined TSC clocksource calibration: 1599.925 MHz
[    4.673547] no IO addresses supplied
[    4.673547] no IO addresses supplied
[    4.673885] usbcore: registered new interface driver udlfb
[    4.673885] usbcore: registered new interface driver udlfb
[    4.674003] usbcore: registered new interface driver smscufx
[    4.674003] usbcore: registered new interface driver smscufx
[    4.674305] ipmi message handler version 39.2
[    4.674305] ipmi message handler version 39.2
[    4.674429] IPMI System Interface driver.
[    4.674429] IPMI System Interface driver.
[    4.674748] ipmi_si: Adding default-specified kcs state machine
[    4.674748] ipmi_si: Adding default-specified kcs state machine
[    4.674755] ipmi_si: Trying default-specified kcs state machine at i/o a=
ddress 0xca2, slave address 0x0, irq 0
[    4.674755] ipmi_si: Trying default-specified kcs state machine at i/o a=
ddress 0xca2, slave address 0x0, irq 0
[    4.674798] ipmi_si: Interface detection failed
[    4.674798] ipmi_si: Interface detection failed
[    4.672162] [sched_delayed] sched: RT throttling activated
[    4.672162] [sched_delayed] sched: RT throttling activated
[    4.720291] ipmi_si: Adding default-specified smic state machine
[    4.720291] ipmi_si: Adding default-specified smic state machine

[    4.725226] ipmi_si: Trying default-specified smic state machine at i/o =
address 0xca9, slave address 0x0, irq 0
[    4.725226] ipmi_si: Trying default-specified smic state machine at i/o =
address 0xca9, slave address 0x0, irq 0
[    4.733393] ipmi_si: Interface detection failed
[    4.733393] ipmi_si: Interface detection failed
[    4.748231] ipmi_si: Adding default-specified bt state machine
[    4.748231] ipmi_si: Adding default-specified bt state machine

[    4.753375] ipmi_si: Trying default-specified bt state machine at i/o ad=
dress 0xe4, slave address 0x0, irq 0
[    4.753375] ipmi_si: Trying default-specified bt state machine at i/o ad=
dress 0xe4, slave address 0x0, irq 0
[    4.761673] ipmi_si: Interface detection failed
[    4.761673] ipmi_si: Interface detection failed
[    4.776710] ipmi_si: Unable to find any System Interface(s)
[    4.776710] ipmi_si: Unable to find any System Interface(s)
[    4.781078] IPMI Watchdog: driver initialized
[    4.781078] IPMI Watchdog: driver initialized
[    4.784606] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via =
sys_reboot.
[    4.784606] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via =
sys_reboot.
[    4.790615] IPMI poweroff: Unable to register powercycle sysctl
[    4.790615] IPMI poweroff: Unable to register powercycle sysctl
[    4.796282] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    4.796282] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    4.802322] ACPI: Power Button [PWRF]
[    4.802322] ACPI: Power Button [PWRF]
[    4.808589] xenfs: not registering filesystem on non-xen platform
[    4.808589] xenfs: not registering filesystem on non-xen platform
[    5.001512] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    5.001512] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    5.038384] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    5.038384] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    5.050676] Non-volatile memory driver v1.3
[    5.050676] Non-volatile memory driver v1.3
[    5.054172] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    5.054172] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    5.061741] Hangcheck: Using getrawmonotonic().
[    5.061741] Hangcheck: Using getrawmonotonic().
[    5.066359] [drm] Initialized drm 1.1.0 20060810
[    5.066359] [drm] Initialized drm 1.1.0 20060810
[    5.070428] usbcore: registered new interface driver udl
[    5.070428] usbcore: registered new interface driver udl
[    5.075552] dummy-irq: no IRQ given.  Use irq=3DN
[    5.075552] dummy-irq: no IRQ given.  Use irq=3DN
[    5.079912] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Gi=
ometti
[    5.079912] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Gi=
ometti
[    5.086797] c2port c2port0: C2 port uc added
[    5.086797] c2port c2port0: C2 port uc added
[    5.090486] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 by=
tes total)
[    5.090486] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 by=
tes total)
[    5.098568] usbcore: registered new interface driver pn533
[    5.098568] usbcore: registered new interface driver pn533
[    5.103366] usbcore: registered new interface driver port100
[    5.103366] usbcore: registered new interface driver port100
[    5.109766] L440GX flash mapping: failed to find PIIX4 ISA bridge, canno=
t continue
[    5.109766] L440GX flash mapping: failed to find PIIX4 ISA bridge, canno=
t continue
[    5.116328] platform physmap-flash.0: failed to claim resource 0
[    5.116328] platform physmap-flash.0: failed to claim resource 0
[    5.121553] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[    5.121553] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[    5.126557] Could not find PAR responsible for SC520CDP Flash Bank #0
[    5.126557] Could not find PAR responsible for SC520CDP Flash Bank #0
[    5.132104] Trying default address 0x8400000
[    5.132104] Trying default address 0x8400000
[    5.135736] Could not find PAR responsible for SC520CDP Flash Bank #1
[    5.135736] Could not find PAR responsible for SC520CDP Flash Bank #1
[    5.141059] Trying default address 0x8c00000
[    5.141059] Trying default address 0x8c00000
[    5.144894] Could not find PAR responsible for SC520CDP DIL Flash
[    5.144894] Could not find PAR responsible for SC520CDP DIL Flash
[    5.150073] Trying default address 0x9400000
[    5.150073] Trying default address 0x9400000
[    5.153755] SC520 CDP flash device: 0x800000 at 0x8400000
[    5.153755] SC520 CDP flash device: 0x800000 at 0x8400000
[    5.158369] Failed to ioremap_nocache
[    5.158369] Failed to ioremap_nocache
[    5.161575] ------------[ cut here ]------------
[    5.161575] ------------[ cut here ]------------
[    5.165627] WARNING: CPU: 1 PID: 1 at arch/x86/mm/ioremap.c:102 __iorema=
p_caller+0x124/0x2f6()
[    5.165627] WARNING: CPU: 1 PID: 1 at arch/x86/mm/ioremap.c:102 __iorema=
p_caller+0x124/0x2f6()
[    5.174693] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.14.0-rc3-02129-g=
63e12bf #2
[    5.174693] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.14.0-rc3-02129-g=
63e12bf #2
[    5.180855]  0000000000000000
[    5.180855]  0000000000000000 ffff880000151dc8 ffff880000151dc8 ffffffff=
89afbd2f ffffffff89afbd2f 0000000000000000 0000000000000000

[    5.187138]  ffff880000151e00
[    5.187138]  ffff880000151e00 ffffffff892b5733 ffffffff892b5733 ffffffff=
8926b70e ffffffff8926b70e 0000000000000010 0000000000000010

[    5.193514]  0000000009400000
[    5.193514]  0000000009400000 ffffea0000206000 ffffea0000206000 00000000=
00009400 0000000000009400 ffff880000151e10 ffff880000151e10

[    5.199796] Call Trace:
[    5.199796] Call Trace:
[    5.201953]  [<ffffffff89afbd2f>] dump_stack+0x4d/0x66
[    5.201953]  [<ffffffff89afbd2f>] dump_stack+0x4d/0x66
[    5.206255]  [<ffffffff892b5733>] warn_slowpath_common+0x70/0x89
[    5.206255]  [<ffffffff892b5733>] warn_slowpath_common+0x70/0x89
[    5.211228]  [<ffffffff8926b70e>] ? __ioremap_caller+0x124/0x2f6
[    5.211228]  [<ffffffff8926b70e>] ? __ioremap_caller+0x124/0x2f6
[    5.216150]  [<ffffffff892b580e>] warn_slowpath_null+0x15/0x17
[    5.216150]  [<ffffffff892b580e>] warn_slowpath_null+0x15/0x17
[    5.221045]  [<ffffffff8926b70e>] __ioremap_caller+0x124/0x2f6
[    5.221045]  [<ffffffff8926b70e>] __ioremap_caller+0x124/0x2f6
[    5.226111]  [<ffffffff8a1ce8c0>] ? init_ts5500_map+0x17/0xc2
[    5.226111]  [<ffffffff8a1ce8c0>] ? init_ts5500_map+0x17/0xc2
[    5.231168]  [<ffffffff8a1ce8a9>] ? init_sc520cdp+0x22c/0x22c
[    5.231168]  [<ffffffff8a1ce8a9>] ? init_sc520cdp+0x22c/0x22c
[    5.236137]  [<ffffffff8926b91a>] ioremap_nocache+0x12/0x14
[    5.236137]  [<ffffffff8926b91a>] ioremap_nocache+0x12/0x14
[    5.240773]  [<ffffffff8a1ce8c0>] init_ts5500_map+0x17/0xc2
[    5.240773]  [<ffffffff8a1ce8c0>] init_ts5500_map+0x17/0xc2
[    5.245680]  [<ffffffff8a19ee0b>] do_one_initcall+0x9f/0x135
[    5.245680]  [<ffffffff8a19ee0b>] do_one_initcall+0x9f/0x135
[    5.250588]  [<ffffffff892cf010>] ? parse_args+0x25c/0x33a
[    5.250588]  [<ffffffff892cf010>] ? parse_args+0x25c/0x33a
[    5.255243]  [<ffffffff8a19f097>] kernel_init_freeable+0x1f6/0x277
[    5.255243]  [<ffffffff8a19f097>] kernel_init_freeable+0x1f6/0x277
[    5.260620]  [<ffffffff8a19e72a>] ? do_early_param+0x88/0x88
[    5.260620]  [<ffffffff8a19e72a>] ? do_early_param+0x88/0x88
[    5.265488]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[    5.265488]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[    5.270072]  [<ffffffff89aef9d1>] kernel_init+0x9/0xd5
[    5.270072]  [<ffffffff89aef9d1>] kernel_init+0x9/0xd5
[    5.274447]  [<ffffffff89b0bd4c>] ret_from_fork+0x7c/0xb0
[    5.274447]  [<ffffffff89b0bd4c>] ret_from_fork+0x7c/0xb0
[    5.279077]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[    5.279077]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[    5.283723] ---[ end trace c039c2149a18e789 ]---
[    5.283723] ---[ end trace c039c2149a18e789 ]---
[    5.296274] slram: not enough parameters.
[    5.296274] slram: not enough parameters.
[    5.303807] ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.t=
c.umn.edu>
[    5.303807] ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.t=
c.umn.edu>
[    5.311756] ipddp0: Appletalk-IP Encap. mode by Bradford W. Johnson <joh=
ns393@maroon.tc.umn.edu>
[    5.311756] ipddp0: Appletalk-IP Encap. mode by Bradford W. Johnson <joh=
ns393@maroon.tc.umn.edu>
[    5.319270] usbcore: registered new interface driver stir4200
[    5.319270] usbcore: registered new interface driver stir4200
[    5.324241] usbcore: registered new interface driver ksdazzle-sir
[    5.324241] usbcore: registered new interface driver ksdazzle-sir
[    5.329419] usbcore: registered new interface driver ks959-sir
[    5.329419] usbcore: registered new interface driver ks959-sir
[    5.334335] PPP generic driver version 2.4.2
[    5.334335] PPP generic driver version 2.4.2
[    5.338618] PPP BSD Compression module registered
[    5.338618] PPP BSD Compression module registered
[    5.342743] PPP MPPE Compression module registered
[    5.342743] PPP MPPE Compression module registered
[    5.346906] NET: Registered protocol family 24
[    5.346906] NET: Registered protocol family 24
[    5.350835] Atmel at76x USB Wireless LAN Driver 0.17 loading
[    5.350835] Atmel at76x USB Wireless LAN Driver 0.17 loading
[    5.355845] usbcore: registered new interface driver at76c50x-usb
[    5.355845] usbcore: registered new interface driver at76c50x-usb
[    5.361465] Broadcom 43xx-legacy driver loaded [ Features: PLID ]
[    5.361465] Broadcom 43xx-legacy driver loaded [ Features: PLID ]
[    5.366720] zd1211rw usb_init()
[    5.366720] zd1211rw usb_init()
[    5.370064] usbcore: registered new interface driver zd1211rw
[    5.370064] usbcore: registered new interface driver zd1211rw
[    5.375120] zd1211rw initialized
[    5.375120] zd1211rw initialized
[    5.378230] usbcore: registered new interface driver rtl8187
[    5.378230] usbcore: registered new interface driver rtl8187
[    5.383249] usbcore: registered new interface driver rndis_wlan
[    5.383249] usbcore: registered new interface driver rndis_wlan
[    5.388569] usbcore: registered new interface driver zd1201
[    5.388569] usbcore: registered new interface driver zd1201
[    5.393774] usbcore: registered new interface driver usb8xxx
[    5.393774] usbcore: registered new interface driver usb8xxx
[    5.398682] libertas_sdio: Libertas SDIO driver
[    5.398682] libertas_sdio: Libertas SDIO driver
[    5.402743] libertas_sdio: Copyright Pierre Ossman
[    5.402743] libertas_sdio: Copyright Pierre Ossman
[    5.407473] usbcore: registered new interface driver ath6kl_usb
[    5.407473] usbcore: registered new interface driver ath6kl_usb
[    5.414094] cfg80211: Updating information on frequency 2412 MHz with re=
gulatory rule:
[    5.414094] cfg80211: Updating information on frequency 2412 MHz with re=
gulatory rule:
[    5.420885] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.420885] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.427396] cfg80211: Updating information on frequency 2417 MHz with re=
gulatory rule:
[    5.427396] cfg80211: Updating information on frequency 2417 MHz with re=
gulatory rule:
[    5.434249] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.434249] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.440696] cfg80211: Updating information on frequency 2422 MHz with re=
gulatory rule:
[    5.440696] cfg80211: Updating information on frequency 2422 MHz with re=
gulatory rule:
[    5.447556] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.447556] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.454030] cfg80211: Updating information on frequency 2427 MHz with re=
gulatory rule:
[    5.454030] cfg80211: Updating information on frequency 2427 MHz with re=
gulatory rule:
[    5.460816] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.460816] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.467324] cfg80211: Updating information on frequency 2432 MHz with re=
gulatory rule:
[    5.467324] cfg80211: Updating information on frequency 2432 MHz with re=
gulatory rule:
[    5.473920] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.473920] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.480069] cfg80211: Updating information on frequency 2437 MHz with re=
gulatory rule:
[    5.480069] cfg80211: Updating information on frequency 2437 MHz with re=
gulatory rule:
[    5.486802] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.486802] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.493202] cfg80211: Updating information on frequency 2442 MHz with re=
gulatory rule:
[    5.493202] cfg80211: Updating information on frequency 2442 MHz with re=
gulatory rule:
[    5.499993] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.499993] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.506577] cfg80211: Updating information on frequency 2447 MHz with re=
gulatory rule:
[    5.506577] cfg80211: Updating information on frequency 2447 MHz with re=
gulatory rule:
[    5.513202] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.513202] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.519575] cfg80211: Updating information on frequency 2452 MHz with re=
gulatory rule:
[    5.519575] cfg80211: Updating information on frequency 2452 MHz with re=
gulatory rule:
[    5.526378] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.526378] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.532574] cfg80211: Updating information on frequency 2457 MHz with re=
gulatory rule:
[    5.532574] cfg80211: Updating information on frequency 2457 MHz with re=
gulatory rule:
[    5.539189] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.539189] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.545398] cfg80211: Updating information on frequency 2462 MHz with re=
gulatory rule:
[    5.545398] cfg80211: Updating information on frequency 2462 MHz with re=
gulatory rule:
[    5.552007] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.552007] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.558388] cfg80211: Updating information on frequency 2467 MHz with re=
gulatory rule:
[    5.558388] cfg80211: Updating information on frequency 2467 MHz with re=
gulatory rule:
[    5.564657] cfg80211: 2457000 KHz - 2482000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.564657] cfg80211: 2457000 KHz - 2482000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.570679] cfg80211: Updating information on frequency 2472 MHz with re=
gulatory rule:
[    5.570679] cfg80211: Updating information on frequency 2472 MHz with re=
gulatory rule:
[    5.577072] cfg80211: 2457000 KHz - 2482000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.577072] cfg80211: 2457000 KHz - 2482000 KHz @ 40000 KHz), (600 mBi, =
2000 mBm)
[    5.583142] cfg80211: Updating information on frequency 2484 MHz with re=
gulatory rule:
[    5.583142] cfg80211: Updating information on frequency 2484 MHz with re=
gulatory rule:
[    5.589789] cfg80211: 2474000 KHz - 2494000 KHz @ 20000 KHz), (600 mBi, =
2000 mBm)
[    5.589789] cfg80211: 2474000 KHz - 2494000 KHz @ 20000 KHz), (600 mBi, =
2000 mBm)
[    5.596288] cfg80211: Updating information on frequency 5180 MHz with re=
gulatory rule:
[    5.596288] cfg80211: Updating information on frequency 5180 MHz with re=
gulatory rule:
[    5.603270] cfg80211: 5170000 KHz - 5250000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.603270] cfg80211: 5170000 KHz - 5250000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.609935] cfg80211: Updating information on frequency 5200 MHz with re=
gulatory rule:
[    5.609935] cfg80211: Updating information on frequency 5200 MHz with re=
gulatory rule:
[    5.616681] cfg80211: 5170000 KHz - 5250000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.616681] cfg80211: 5170000 KHz - 5250000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.623098] cfg80211: Updating information on frequency 5220 MHz with re=
gulatory rule:
[    5.623098] cfg80211: Updating information on frequency 5220 MHz with re=
gulatory rule:
[    5.629883] cfg80211: 5170000 KHz - 5250000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.629883] cfg80211: 5170000 KHz - 5250000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.636408] cfg80211: Updating information on frequency 5240 MHz with re=
gulatory rule:
[    5.636408] cfg80211: Updating information on frequency 5240 MHz with re=
gulatory rule:
[    5.643200] cfg80211: 5170000 KHz - 5250000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.643200] cfg80211: 5170000 KHz - 5250000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.649670] cfg80211: Updating information on frequency 5260 MHz with re=
gulatory rule:
[    5.649670] cfg80211: Updating information on frequency 5260 MHz with re=
gulatory rule:
[    5.656436] cfg80211: 5250000 KHz - 5330000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.656436] cfg80211: 5250000 KHz - 5330000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.662871] cfg80211: Updating information on frequency 5280 MHz with re=
gulatory rule:
[    5.662871] cfg80211: Updating information on frequency 5280 MHz with re=
gulatory rule:
[    5.669367] cfg80211: 5250000 KHz - 5330000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.669367] cfg80211: 5250000 KHz - 5330000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.675762] cfg80211: Updating information on frequency 5300 MHz with re=
gulatory rule:
[    5.675762] cfg80211: Updating information on frequency 5300 MHz with re=
gulatory rule:
[    5.682556] cfg80211: 5250000 KHz - 5330000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.682556] cfg80211: 5250000 KHz - 5330000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.689000] cfg80211: Updating information on frequency 5320 MHz with re=
gulatory rule:
[    5.689000] cfg80211: Updating information on frequency 5320 MHz with re=
gulatory rule:
[    5.695873] cfg80211: 5250000 KHz - 5330000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.695873] cfg80211: 5250000 KHz - 5330000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.702567] cfg80211: Updating information on frequency 5500 MHz with re=
gulatory rule:
[    5.702567] cfg80211: Updating information on frequency 5500 MHz with re=
gulatory rule:
[    5.709280] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.709280] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.715772] cfg80211: Updating information on frequency 5520 MHz with re=
gulatory rule:
[    5.715772] cfg80211: Updating information on frequency 5520 MHz with re=
gulatory rule:
[    5.722514] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.722514] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.728865] cfg80211: Updating information on frequency 5540 MHz with re=
gulatory rule:
[    5.728865] cfg80211: Updating information on frequency 5540 MHz with re=
gulatory rule:
[    5.735705] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.735705] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.742236] cfg80211: Updating information on frequency 5560 MHz with re=
gulatory rule:
[    5.742236] cfg80211: Updating information on frequency 5560 MHz with re=
gulatory rule:
[    5.748992] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.748992] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.755581] cfg80211: Updating information on frequency 5580 MHz with re=
gulatory rule:
[    5.755581] cfg80211: Updating information on frequency 5580 MHz with re=
gulatory rule:
[    5.762433] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.762433] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.768746] cfg80211: Updating information on frequency 5600 MHz with re=
gulatory rule:
[    5.768746] cfg80211: Updating information on frequency 5600 MHz with re=
gulatory rule:
[    5.775426] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.775426] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.781999] cfg80211: Updating information on frequency 5620 MHz with re=
gulatory rule:
[    5.781999] cfg80211: Updating information on frequency 5620 MHz with re=
gulatory rule:
[    5.788748] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.788748] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.795371] cfg80211: Updating information on frequency 5640 MHz with re=
gulatory rule:
[    5.795371] cfg80211: Updating information on frequency 5640 MHz with re=
gulatory rule:
[    5.802346] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.802346] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.808673] cfg80211: Updating information on frequency 5660 MHz with re=
gulatory rule:
[    5.808673] cfg80211: Updating information on frequency 5660 MHz with re=
gulatory rule:
[    5.815377] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.815377] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.821814] cfg80211: Updating information on frequency 5680 MHz with re=
gulatory rule:
[    5.821814] cfg80211: Updating information on frequency 5680 MHz with re=
gulatory rule:
[    5.828426] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.828426] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.834817] cfg80211: Updating information on frequency 5700 MHz with re=
gulatory rule:
[    5.834817] cfg80211: Updating information on frequency 5700 MHz with re=
gulatory rule:
[    5.841403] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.841403] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 mBi,=
 2000 mBm)
[    5.847745] cfg80211: Disabling freq 5745 MHz
[    5.847745] cfg80211: Disabling freq 5745 MHz
[    5.851455] cfg80211: Disabling freq 5765 MHz
[    5.851455] cfg80211: Disabling freq 5765 MHz
[    5.855257] cfg80211: Disabling freq 5785 MHz
[    5.855257] cfg80211: Disabling freq 5785 MHz
[    5.859034] cfg80211: Disabling freq 5805 MHz
[    5.859034] cfg80211: Disabling freq 5805 MHz
[    5.862839] cfg80211: Disabling freq 5825 MHz
[    5.862839] cfg80211: Disabling freq 5825 MHz
[    5.868285] ieee80211 phy0: Failed to select rate control algorithm
[    5.868285] ieee80211 phy0: Failed to select rate control algorithm
[    5.873857] ieee80211 phy0: Failed to initialize rate control algorithm
[    5.873857] ieee80211 phy0: Failed to initialize rate control algorithm
[    5.893694] mac80211_hwsim: ieee80211_register_hw failed (-2)
[    5.893694] mac80211_hwsim: ieee80211_register_hw failed (-2)
[    5.899549] ------------[ cut here ]------------
[    5.899549] ------------[ cut here ]------------
[    5.903899] WARNING: CPU: 0 PID: 1 at include/linux/kref.h:47 kobject_ge=
t+0x37/0x44()
[    5.903899] WARNING: CPU: 0 PID: 1 at include/linux/kref.h:47 kobject_ge=
t+0x37/0x44()
[    5.913463] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W    3.14.0-=
rc3-02129-g63e12bf #2
[    5.913463] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W    3.14.0-=
rc3-02129-g63e12bf #2
[    5.920495]  0000000000000000
[    5.920495]  0000000000000000 ffff880000151da0 ffff880000151da0 ffffffff=
89afbd2f ffffffff89afbd2f 0000000000000000 0000000000000000

[    5.927197]  ffff880000151dd8
[    5.927197]  ffff880000151dd8 ffffffff892b5733 ffffffff892b5733 ffffffff=
8940ed5a ffffffff8940ed5a ffff88000d5f6010 ffff88000d5f6010

[    5.933927]  ffffffff8a0969d8
[    5.933927]  ffffffff8a0969d8 0000000000000333 0000000000000333 00000000=
00000000 0000000000000000 ffff880000151de8 ffff880000151de8

[    5.940375] Call Trace:
[    5.940375] Call Trace:
[    5.942908]  [<ffffffff89afbd2f>] dump_stack+0x4d/0x66
[    5.942908]  [<ffffffff89afbd2f>] dump_stack+0x4d/0x66
[    5.947464]  [<ffffffff892b5733>] warn_slowpath_common+0x70/0x89
[    5.947464]  [<ffffffff892b5733>] warn_slowpath_common+0x70/0x89
[    5.952507]  [<ffffffff8940ed5a>] ? kobject_get+0x37/0x44
[    5.952507]  [<ffffffff8940ed5a>] ? kobject_get+0x37/0x44
[    5.957088]  [<ffffffff892b580e>] warn_slowpath_null+0x15/0x17
[    5.957088]  [<ffffffff892b580e>] warn_slowpath_null+0x15/0x17
[    5.962507]  [<ffffffff8940ed5a>] kobject_get+0x37/0x44
[    5.962507]  [<ffffffff8940ed5a>] kobject_get+0x37/0x44
[    5.966972]  [<ffffffff89510e69>] get_device+0x12/0x1b
[    5.966972]  [<ffffffff89510e69>] get_device+0x12/0x1b
[    5.971622]  [<ffffffff89514839>] driver_detach+0x4c/0xb2
[    5.971622]  [<ffffffff89514839>] driver_detach+0x4c/0xb2
[    5.976256]  [<ffffffff89513565>] bus_remove_driver+0x93/0xa8
[    5.976256]  [<ffffffff89513565>] bus_remove_driver+0x93/0xa8
[    5.981109]  [<ffffffff89514cc9>] driver_unregister+0x41/0x44
[    5.981109]  [<ffffffff89514cc9>] driver_unregister+0x41/0x44
[    5.986383]  [<ffffffff89515fbd>] platform_driver_unregister+0xd/0xf
[    5.986383]  [<ffffffff89515fbd>] platform_driver_unregister+0xd/0xf
[    5.991790]  [<ffffffff8a1d05ca>] init_mac80211_hwsim+0x429/0x437
[    5.991790]  [<ffffffff8a1d05ca>] init_mac80211_hwsim+0x429/0x437
[    5.997272]  [<ffffffff8a1d01a1>] ? ath9k_cmn_init+0x8/0x8
[    5.997272]  [<ffffffff8a1d01a1>] ? ath9k_cmn_init+0x8/0x8
[    6.002250]  [<ffffffff8a19ee0b>] do_one_initcall+0x9f/0x135
[    6.002250]  [<ffffffff8a19ee0b>] do_one_initcall+0x9f/0x135
[    6.007541]  [<ffffffff892cf010>] ? parse_args+0x25c/0x33a
[    6.007541]  [<ffffffff892cf010>] ? parse_args+0x25c/0x33a
[    6.012213]  [<ffffffff8a19f097>] kernel_init_freeable+0x1f6/0x277
[    6.012213]  [<ffffffff8a19f097>] kernel_init_freeable+0x1f6/0x277
[    6.017701]  [<ffffffff8a19e72a>] ? do_early_param+0x88/0x88
[    6.017701]  [<ffffffff8a19e72a>] ? do_early_param+0x88/0x88
[    6.022674]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[    6.022674]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[    6.027305]  [<ffffffff89aef9d1>] kernel_init+0x9/0xd5
[    6.027305]  [<ffffffff89aef9d1>] kernel_init+0x9/0xd5
[    6.031980]  [<ffffffff89b0bd4c>] ret_from_fork+0x7c/0xb0
[    6.031980]  [<ffffffff89b0bd4c>] ret_from_fork+0x7c/0xb0
[    6.036261]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[    6.036261]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[    6.041911] ---[ end trace c039c2149a18e78a ]---
[    6.041911] ---[ end trace c039c2149a18e78a ]---
[    6.045959] ------------[ cut here ]------------
[    6.045959] ------------[ cut here ]------------
[    6.050025] WARNING: CPU: 0 PID: 1 at fs/kernfs/dir.c:1216 kernfs_remove=
_by_name_ns+0x30/0x83()
[    6.050025] WARNING: CPU: 0 PID: 1 at fs/kernfs/dir.c:1216 kernfs_remove=
_by_name_ns+0x30/0x83()
[    6.059520] kernfs: can not remove 'driver', no directory
[    6.059520] kernfs: can not remove 'driver', no directory
[    6.064295] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W    3.14.0-=
rc3-02129-g63e12bf #2
[    6.064295] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W    3.14.0-=
rc3-02129-g63e12bf #2
[    6.071469]  0000000000000000
[    6.071469]  0000000000000000 ffff880000151d08 ffff880000151d08 ffffffff=
89afbd2f ffffffff89afbd2f ffff880000151d50 ffff880000151d50

[    6.078176]  ffff880000151d40
[    6.078176]  ffff880000151d40 ffffffff892b5733 ffffffff892b5733 ffffffff=
893bc7e7 ffffffff893bc7e7 0000000000000000 0000000000000000

[    6.084781]  ffffffff89f5d735
[    6.084781]  ffffffff89f5d735 ffff88000d5f6060 ffff88000d5f6060 00000000=
00000000 0000000000000000 ffff880000151da0 ffff880000151da0

[    6.091344] Call Trace:
[    6.091344] Call Trace:
[    6.093448]  [<ffffffff89afbd2f>] dump_stack+0x4d/0x66
[    6.093448]  [<ffffffff89afbd2f>] dump_stack+0x4d/0x66
[    6.097748]  [<ffffffff892b5733>] warn_slowpath_common+0x70/0x89
[    6.097748]  [<ffffffff892b5733>] warn_slowpath_common+0x70/0x89
[    6.103109]  [<ffffffff893bc7e7>] ? kernfs_remove_by_name_ns+0x30/0x83
[    6.103109]  [<ffffffff893bc7e7>] ? kernfs_remove_by_name_ns+0x30/0x83
[    6.109098]  [<ffffffff892b57b6>] warn_slowpath_fmt+0x47/0x49
[    6.109098]  [<ffffffff892b57b6>] warn_slowpath_fmt+0x47/0x49
[    6.114208]  [<ffffffff893bc7e7>] kernfs_remove_by_name_ns+0x30/0x83
[    6.114208]  [<ffffffff893bc7e7>] kernfs_remove_by_name_ns+0x30/0x83
[    6.119539]  [<ffffffff893be37e>] sysfs_remove_link+0x1d/0x1f
[    6.119539]  [<ffffffff893be37e>] sysfs_remove_link+0x1d/0x1f
[    6.124702]  [<ffffffff89513f3a>] driver_sysfs_remove+0x31/0x34
[    6.124702]  [<ffffffff89513f3a>] driver_sysfs_remove+0x31/0x34
[    6.129956]  [<ffffffff89514712>] __device_release_driver+0x2c/0xda
[    6.129956]  [<ffffffff89514712>] __device_release_driver+0x2c/0xda
[    6.135258]  [<ffffffff89514879>] driver_detach+0x8c/0xb2
[    6.135258]  [<ffffffff89514879>] driver_detach+0x8c/0xb2
[    6.140083]  [<ffffffff89513565>] bus_remove_driver+0x93/0xa8
[    6.140083]  [<ffffffff89513565>] bus_remove_driver+0x93/0xa8
[    6.145575]  [<ffffffff89514cc9>] driver_unregister+0x41/0x44
[    6.145575]  [<ffffffff89514cc9>] driver_unregister+0x41/0x44
[    6.150686]  [<ffffffff89515fbd>] platform_driver_unregister+0xd/0xf
[    6.150686]  [<ffffffff89515fbd>] platform_driver_unregister+0xd/0xf
[    6.155927]  [<ffffffff8a1d05ca>] init_mac80211_hwsim+0x429/0x437
[    6.155927]  [<ffffffff8a1d05ca>] init_mac80211_hwsim+0x429/0x437
[    6.160943]  [<ffffffff8a1d01a1>] ? ath9k_cmn_init+0x8/0x8
[    6.160943]  [<ffffffff8a1d01a1>] ? ath9k_cmn_init+0x8/0x8
[    6.165979]  [<ffffffff8a19ee0b>] do_one_initcall+0x9f/0x135
[    6.165979]  [<ffffffff8a19ee0b>] do_one_initcall+0x9f/0x135
[    6.170226]  [<ffffffff892cf010>] ? parse_args+0x25c/0x33a
[    6.170226]  [<ffffffff892cf010>] ? parse_args+0x25c/0x33a
[    6.175229]  [<ffffffff8a19f097>] kernel_init_freeable+0x1f6/0x277
[    6.175229]  [<ffffffff8a19f097>] kernel_init_freeable+0x1f6/0x277
[    6.180774]  [<ffffffff8a19e72a>] ? do_early_param+0x88/0x88
[    6.180774]  [<ffffffff8a19e72a>] ? do_early_param+0x88/0x88
[    6.186425]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[    6.186425]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[    6.191294]  [<ffffffff89aef9d1>] kernel_init+0x9/0xd5
[    6.191294]  [<ffffffff89aef9d1>] kernel_init+0x9/0xd5
[    6.195946]  [<ffffffff89b0bd4c>] ret_from_fork+0x7c/0xb0
[    6.195946]  [<ffffffff89b0bd4c>] ret_from_fork+0x7c/0xb0
[    6.201157]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[    6.201157]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[    6.206748] ---[ end trace c039c2149a18e78b ]---
[    6.206748] ---[ end trace c039c2149a18e78b ]---
[    6.211307] Error: Driver 'usb8xxx' is already registered, aborting...
[    6.211307] Error: Driver 'usb8xxx' is already registered, aborting...
[    6.217261] mwifiex_usb: Driver register failed!
[    6.217261] mwifiex_usb: Driver register failed!
[    6.222273] usbcore: registered new interface driver i2400m_usb
[    6.222273] usbcore: registered new interface driver i2400m_usb
[    6.230601] ieee802154hardmac ieee802154hardmac: Added ieee802154 HardMA=
C hardware
[    6.230601] ieee802154hardmac ieee802154hardmac: Added ieee802154 HardMA=
C hardware
[   32.224051] INFO: rcu_sched self-detected stall on CPU
[   32.224051] INFO: rcu_sched self-detected stall on CPU

[   32.224051]=20
[   32.224051]=20
[   32.224051]=20
 (t=3D6500 jiffies g=3D18446744073709551390 c=3D18446744073709551389 q=3D0)
[   32.224051] sending NMI to all CPUs:
[   32.224051] sending NMI to all CPUs:
[   32.224051] NMI backtrace for cpu 0
[   32.224051] NMI backtrace for cpu 0
[   32.224051] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W    3.14.0-=
rc3-02129-g63e12bf #2
[   32.224051] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W    3.14.0-=
rc3-02129-g63e12bf #2
[   32.224051] task: ffff88000014e010 ti: ffff880000150000 task.ti: ffff880=
000150000
[   32.224051] task: ffff88000014e010 ti: ffff880000150000 task.ti: ffff880=
000150000
[   32.224051] RIP: 0010:[<ffffffff892675a6>]=20
[   32.224051] RIP: 0010:[<ffffffff892675a6>]  [<ffffffff892675a6>] flat_se=
nd_IPI_mask+0x79/0xa7
 [<ffffffff892675a6>] flat_send_IPI_mask+0x79/0xa7
[   32.224051] RSP: 0000:ffff88000fa03df0  EFLAGS: 00010046
[   32.224051] RSP: 0000:ffff88000fa03df0  EFLAGS: 00010046
[   32.224051] RAX: 0000000000000c00 RBX: 0000000000000046 RCX: 00000000000=
02e2c
[   32.224051] RAX: 0000000000000c00 RBX: 0000000000000046 RCX: 00000000000=
02e2c
[   32.224051] RDX: ffffffff8a01c400 RSI: 0000000000000002 RDI: 00000000000=
00300
[   32.224051] RDX: ffffffff8a01c400 RSI: 0000000000000002 RDI: 00000000000=
00300
[   32.224051] RBP: ffff88000fa03e10 R08: 0000000000000002 R09: 00000000000=
00000
[   32.224051] RBP: ffff88000fa03e10 R08: 0000000000000002 R09: 00000000000=
00000
[   32.224051] R10: ffffffff892f6eb5 R11: 0000000000000000 R12: 00000000000=
00002
[   32.224051] R10: ffffffff892f6eb5 R11: 0000000000000000 R12: 00000000000=
00002
[   32.224051] R13: 0000000000000c00 R14: 0000000000000003 R15: 00000000000=
00002
[   32.224051] R13: 0000000000000c00 R14: 0000000000000003 R15: 00000000000=
00002
[   32.224051] FS:  0000000000000000(0000) GS:ffff88000fa00000(0000) knlGS:=
0000000000000000
[   32.224051] FS:  0000000000000000(0000) GS:ffff88000fa00000(0000) knlGS:=
0000000000000000
[   32.224051] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   32.224051] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   32.224051] CR2: 00000000ffffffff CR3: 000000000a005000 CR4: 00000000000=
006f0
[   32.224051] CR2: 00000000ffffffff CR3: 000000000a005000 CR4: 00000000000=
006f0
[   32.224051] Stack:
[   32.224051] Stack:
[   32.224051]  0000000000002710
[   32.224051]  0000000000002710 ffff88000fa0e4f0 ffff88000fa0e4f0 00000000=
00000000 0000000000000000 ffffffff8a037840 ffffffff8a037840

[   32.224051]  ffff88000fa03e20
[   32.224051]  ffff88000fa03e20 ffffffff89267824 ffffffff89267824 ffff8800=
0fa03e38 ffff88000fa03e38 ffffffff89264e66 ffffffff89264e66

[   32.224051]  ffffffff8a037840
[   32.224051]  ffffffff8a037840 ffff88000fa03e90 ffff88000fa03e90 ffffffff=
893008d2 ffffffff893008d2 ffff88000fa03eb8 ffff88000fa03eb8

[   32.224051] Call Trace:
[   32.224051] Call Trace:
[   32.224051]  <IRQ>=20
[   32.224051]  <IRQ>=20

[   32.224051]=20
[   32.224051]  [<ffffffff89267824>] flat_send_IPI_all+0x1a/0x45
 [<ffffffff89267824>] flat_send_IPI_all+0x1a/0x45
[   32.224051]  [<ffffffff89264e66>] arch_trigger_all_cpu_backtrace+0x5f/0x=
92
[   32.224051]  [<ffffffff89264e66>] arch_trigger_all_cpu_backtrace+0x5f/0x=
92
[   32.224051]  [<ffffffff893008d2>] rcu_check_callbacks+0x246/0x5b5
[   32.224051]  [<ffffffff893008d2>] rcu_check_callbacks+0x246/0x5b5
[   32.224051]  [<ffffffff8930b7a5>] ? tick_init_highres+0x12/0x12
[   32.224051]  [<ffffffff8930b7a5>] ? tick_init_highres+0x12/0x12
[   32.224051]  [<ffffffff892be511>] update_process_times+0x38/0x60
[   32.224051]  [<ffffffff892be511>] update_process_times+0x38/0x60
[   32.224051]  [<ffffffff8930b8c9>] tick_sched_timer+0x124/0x14d
[   32.224051]  [<ffffffff8930b8c9>] tick_sched_timer+0x124/0x14d
[   32.224051]  [<ffffffff892d2ed5>] ? __run_hrtimer.isra.24+0x66/0xbf
[   32.224051]  [<ffffffff892d2ed5>] ? __run_hrtimer.isra.24+0x66/0xbf
[   32.224051]  [<ffffffff892d2ed5>] __run_hrtimer.isra.24+0x66/0xbf
[   32.224051]  [<ffffffff892d2ed5>] __run_hrtimer.isra.24+0x66/0xbf
[   32.224051]  [<ffffffff892d35dd>] hrtimer_interrupt+0xe2/0x1c9
[   32.224051]  [<ffffffff892d35dd>] hrtimer_interrupt+0xe2/0x1c9
[   32.224051]  [<ffffffff89263653>] local_apic_timer_interrupt+0x4f/0x52
[   32.224051]  [<ffffffff89263653>] local_apic_timer_interrupt+0x4f/0x52
[   32.224051]  [<ffffffff89263b1a>] smp_apic_timer_interrupt+0x3a/0x4b
[   32.224051]  [<ffffffff89263b1a>] smp_apic_timer_interrupt+0x3a/0x4b
[   32.224051]  [<ffffffff89b0ca6f>] apic_timer_interrupt+0x6f/0x80
[   32.224051]  [<ffffffff89b0ca6f>] apic_timer_interrupt+0x6f/0x80
[   32.224051]  <EOI>=20
[   32.224051]  <EOI>=20

[   32.224051]=20
[   32.224051]  [<ffffffff89b0b5b0>] ? retint_restore_args+0x13/0x13
 [<ffffffff89b0b5b0>] ? retint_restore_args+0x13/0x13
[   32.224051]  [<ffffffff8940f05d>] ? kset_find_obj+0x1d/0x7b
[   32.224051]  [<ffffffff8940f05d>] ? kset_find_obj+0x1d/0x7b
[   32.224051]  [<ffffffff8940f076>] ? kset_find_obj+0x36/0x7b
[   32.224051]  [<ffffffff8940f076>] ? kset_find_obj+0x36/0x7b
[   32.224051]  [<ffffffff8940f07e>] ? kset_find_obj+0x3e/0x7b
[   32.224051]  [<ffffffff8940f07e>] ? kset_find_obj+0x3e/0x7b
[   32.224051]  [<ffffffff89514cea>] driver_find+0x1e/0x3c
[   32.224051]  [<ffffffff89514cea>] driver_find+0x1e/0x3c
[   32.224051]  [<ffffffff89514d6b>] driver_register+0x63/0xc5
[   32.224051]  [<ffffffff89514d6b>] driver_register+0x63/0xc5
[   32.224051]  [<ffffffff89690efd>] usb_register_driver+0xa2/0x14c
[   32.224051]  [<ffffffff89690efd>] usb_register_driver+0xa2/0x14c
[   32.224051]  [<ffffffff8a1d0a5d>] ? netif_init+0x3f/0x3f
[   32.224051]  [<ffffffff8a1d0a5d>] ? netif_init+0x3f/0x3f
[   32.224051]  [<ffffffff8a1d0a76>] kaweth_driver_init+0x19/0x1b
[   32.224051]  [<ffffffff8a1d0a76>] kaweth_driver_init+0x19/0x1b
[   32.224051]  [<ffffffff8a19ee0b>] do_one_initcall+0x9f/0x135
[   32.224051]  [<ffffffff8a19ee0b>] do_one_initcall+0x9f/0x135
[   32.224051]  [<ffffffff892cf010>] ? parse_args+0x25c/0x33a
[   32.224051]  [<ffffffff892cf010>] ? parse_args+0x25c/0x33a
[   32.224051]  [<ffffffff8a19f097>] kernel_init_freeable+0x1f6/0x277
[   32.224051]  [<ffffffff8a19f097>] kernel_init_freeable+0x1f6/0x277
[   32.224051]  [<ffffffff8a19e72a>] ? do_early_param+0x88/0x88
[   32.224051]  [<ffffffff8a19e72a>] ? do_early_param+0x88/0x88
[   32.224051]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[   32.224051]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[   32.224051]  [<ffffffff89aef9d1>] kernel_init+0x9/0xd5
[   32.224051]  [<ffffffff89aef9d1>] kernel_init+0x9/0xd5
[   32.224051]  [<ffffffff89b0bd4c>] ret_from_fork+0x7c/0xb0
[   32.224051]  [<ffffffff89b0bd4c>] ret_from_fork+0x7c/0xb0
[   32.224051]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[   32.224051]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[   32.224051] Code:=20
[   32.224051] Code: eb eb f0 f0 44 44 89 89 f0 f0 c1 c1 e0 e0 18 18 89 89 =
04 04 25 25 10 10 a3 a3 5f 5f ff ff 44 44 89 89 e0 e0 44 44 09 09 e8 e8 41 =
41 81 81 cd cd 00 00 04 04 00 00 00 00 41 41 83 83 fc fc 02 02 41 41 0f 0f =
44 44 c5 c5 89 89 04 04 25 25 00 00 a3 a3 5f 5f ff ff <f6> <f6> c7 c7 02 02=
 75 75 11 11 48 48 89 89 df df 57 57 9d 9d 0f 0f 1f 1f 44 44 00 00 00 00 e8=
 e8 7e 7e 6a 6a 08 08 00 00 eb eb=20

[   32.248063] NMI backtrace for cpu 1
[   32.248063] NMI backtrace for cpu 1
[   32.248063] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        W    3.14.0-=
rc3-02129-g63e12bf #2
[   32.248063] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        W    3.14.0-=
rc3-02129-g63e12bf #2
[   32.248063] task: ffff8800001a6290 ti: ffff8800001a8000 task.ti: ffff880=
0001a8000
[   32.248063] task: ffff8800001a6290 ti: ffff8800001a8000 task.ti: ffff880=
0001a8000
[   32.248063] RIP: 0010:[<ffffffff8926984c>]=20
[   32.248063] RIP: 0010:[<ffffffff8926984c>]  [<ffffffff8926984c>] native_=
safe_halt+0x6/0x8
 [<ffffffff8926984c>] native_safe_halt+0x6/0x8
[   32.248063] RSP: 0000:ffff8800001a9ec0  EFLAGS: 00000202
[   32.248063] RSP: 0000:ffff8800001a9ec0  EFLAGS: 00000202
[   32.248063] RAX: ffff8800001a6290 RBX: ffff8800001a9fd8 RCX: 00000000000=
00003
[   32.248063] RAX: ffff8800001a6290 RBX: ffff8800001a9fd8 RCX: 00000000000=
00003
[   32.248063] RDX: 0000000700000003 RSI: 0000000000000001 RDI: ffff8800001=
a6290
[   32.248063] RDX: 0000000700000003 RSI: 0000000000000001 RDI: ffff8800001=
a6290
[   32.248063] RBP: ffff8800001a9ec0 R08: 0000000000000000 R09: 00000000000=
00001
[   32.248063] RBP: ffff8800001a9ec0 R08: 0000000000000000 R09: 00000000000=
00001
[   32.248063] R10: 0000000000000001 R11: 00000000000003fa R12: ffff8800001=
a9fd8
[   32.248063] R10: 0000000000000001 R11: 00000000000003fa R12: ffff8800001=
a9fd8
[   32.248063] R13: ffff8800001a9fd8 R14: 00000000ffffffff R15: ffff8800001=
a9fd8
[   32.248063] R13: ffff8800001a9fd8 R14: 00000000ffffffff R15: ffff8800001=
a9fd8
[   32.248063] FS:  0000000000000000(0000) GS:ffff88000fb00000(0000) knlGS:=
0000000000000000
[   32.248063] FS:  0000000000000000(0000) GS:ffff88000fb00000(0000) knlGS:=
0000000000000000
[   32.248063] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   32.248063] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   32.248063] CR2: 0000000000000000 CR3: 000000000a005000 CR4: 00000000000=
006e0
[   32.248063] CR2: 0000000000000000 CR3: 000000000a005000 CR4: 00000000000=
006e0
[   32.248063] Stack:
[   32.248063] Stack:
[   32.248063]  ffff8800001a9ed0
[   32.248063]  ffff8800001a9ed0 ffffffff8924602a ffffffff8924602a ffff8800=
001a9ee0 ffff8800001a9ee0 ffffffff89246710 ffffffff89246710

[   32.248063]  ffff8800001a9f18
[   32.248063]  ffff8800001a9f18 ffffffff892f8830 ffffffff892f8830 ffff8800=
0fff3f40 ffff88000fff3f40 0000000000000001 0000000000000001

[   32.248063]  ffff88000fff3f00
[   32.248063]  ffff88000fff3f00 0000000000000000 0000000000000000 00000000=
00000000 0000000000000000 ffff8800001a9f48 ffff8800001a9f48

[   32.248063] Call Trace:
[   32.248063] Call Trace:
[   32.248063]  [<ffffffff8924602a>] default_idle+0xe/0x12
[   32.248063]  [<ffffffff8924602a>] default_idle+0xe/0x12
[   32.248063]  [<ffffffff89246710>] arch_cpu_idle+0x13/0x23
[   32.248063]  [<ffffffff89246710>] arch_cpu_idle+0x13/0x23
[   32.248063]  [<ffffffff892f8830>] cpu_startup_entry+0x103/0x16b
[   32.248063]  [<ffffffff892f8830>] cpu_startup_entry+0x103/0x16b
[   32.248063]  [<ffffffff89261c02>] start_secondary+0x2cd/0x2d6
[   32.248063]  [<ffffffff89261c02>] start_secondary+0x2cd/0x2d6
[   32.248063] Code:=20
[   32.248063] Code: 48 48 89 89 e5 e5 0f 0f 09 09 5d 5d c3 c3 55 55 48 48 =
89 89 e5 e5 9c 9c 58 58 5d 5d c3 c3 55 55 48 48 89 89 e5 e5 57 57 9d 9d 5d =
5d c3 c3 55 55 48 48 89 89 e5 e5 fa fa 5d 5d c3 c3 55 55 48 48 89 89 e5 e5 =
fb fb 5d 5d c3 c3 55 55 48 48 89 89 e5 e5 fb fb f4 f4 <5d> <5d> c3 c3 55 55=
 48 48 89 89 e5 e5 f4 f4 5d 5d c3 c3 55 55 49 49 89 89 ca ca 49 49 89 89 d1=
 d1 8b 8b 07 07 48 48 89 89 e5 e5=20

[   32.224051] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) t=
ook too long to run: 400.899 msecs
[   32.224051] INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) t=
ook too long to run: 400.899 msecs
[   56.252049] BUG: soft lockup - CPU#0 stuck for 22s! [swapper/0:1]
[   56.252049] BUG: soft lockup - CPU#0 stuck for 22s! [swapper/0:1]
[   56.252049] irq event stamp: 867718
[   56.252049] irq event stamp: 867718
[   56.252049] hardirqs last  enabled at (867717):=20
[   56.252049] hardirqs last  enabled at (867717): [<ffffffff89b0b5b0>] res=
tore_args+0x0/0x30
[<ffffffff89b0b5b0>] restore_args+0x0/0x30
[   56.252049] hardirqs last disabled at (867718):=20
[   56.252049] hardirqs last disabled at (867718): [<ffffffff89b0ca6a>] api=
c_timer_interrupt+0x6a/0x80
[<ffffffff89b0ca6a>] apic_timer_interrupt+0x6a/0x80
[   56.252049] softirqs last  enabled at (867716):=20
[   56.252049] softirqs last  enabled at (867716): [<ffffffff892b9a93>] __d=
o_softirq+0x1db/0x26a
[<ffffffff892b9a93>] __do_softirq+0x1db/0x26a
[   56.252049] softirqs last disabled at (867711):=20
[   56.252049] softirqs last disabled at (867711): [<ffffffff892b9d74>] irq=
_exit+0x53/0x83
[<ffffffff892b9d74>] irq_exit+0x53/0x83
[   56.252049] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W    3.14.0-=
rc3-02129-g63e12bf #2
[   56.252049] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W    3.14.0-=
rc3-02129-g63e12bf #2
[   56.252049] task: ffff88000014e010 ti: ffff880000150000 task.ti: ffff880=
000150000
[   56.252049] task: ffff88000014e010 ti: ffff880000150000 task.ti: ffff880=
000150000
[   56.252049] RIP: 0010:[<ffffffff89413a3c>]=20
[   56.252049] RIP: 0010:[<ffffffff89413a3c>]  [<ffffffff89413a3c>] strcmp+=
0x0/0x20
 [<ffffffff89413a3c>] strcmp+0x0/0x20
[   56.252049] RSP: 0000:ffff880000151df0  EFLAGS: 00000282
[   56.252049] RSP: 0000:ffff880000151df0  EFLAGS: 00000282
[   56.252049] RAX: ffff88000d5dacc8 RBX: ffffffff8940f05d RCX: 00000000000=
4504e
[   56.252049] RAX: ffff88000d5dacc8 RBX: ffffffff8940f05d RCX: 00000000000=
4504e
[   56.252049] RDX: 0000000000044e73 RSI: ffffffff89c87b40 RDI: ffff88000d5=
cfd80
[   56.252049] RDX: 0000000000044e73 RSI: ffffffff89c87b40 RDI: ffff88000d5=
cfd80
[   56.252049] RBP: ffff880000151e18 R08: 0000000000000002 R09: 00000000000=
00000
[   56.252049] RBP: ffff880000151e18 R08: 0000000000000002 R09: 00000000000=
00000
[   56.252049] R10: ffffffff8940f05d R11: 0000000000000000 R12: ffffffff89b=
0b5b0
[   56.252049] R10: ffffffff8940f05d R11: 0000000000000000 R12: ffffffff89b=
0b5b0
[   56.252049] R13: ffffffff893003e6 R14: ffff880000151d58 R15: ffff8800001=
4e010
[   56.252049] R13: ffffffff893003e6 R14: ffff880000151d58 R15: ffff8800001=
4e010
[   56.252049] FS:  0000000000000000(0000) GS:ffff88000fa00000(0000) knlGS:=
0000000000000000
[   56.252049] FS:  0000000000000000(0000) GS:ffff88000fa00000(0000) knlGS:=
0000000000000000
[   56.252049] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   56.252049] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   56.252049] CR2: 00000000ffffffff CR3: 000000000a005000 CR4: 00000000000=
006f0
[   56.252049] CR2: 00000000ffffffff CR3: 000000000a005000 CR4: 00000000000=
006f0
[   56.252049] Stack:
[   56.252049] Stack:
[   56.252049]  ffffffff8940f07e
[   56.252049]  ffffffff8940f07e ffffffff8a09aab8 ffffffff8a09aab8 00000000=
00000000 0000000000000000 0000000000000000 0000000000000000

[   56.252049]  ffffffff8a09aab8
[   56.252049]  ffffffff8a09aab8 ffff880000151e30 ffff880000151e30 ffffffff=
89514cea ffffffff89514cea ffffffff8a09aab8 ffffffff8a09aab8

[   56.252049]  ffff880000151e58
[   56.252049]  ffff880000151e58 ffffffff89514d6b ffffffff89514d6b ffffffff=
8a09aa20 ffffffff8a09aa20 0000000000000000 0000000000000000

[   56.252049] Call Trace:
[   56.252049] Call Trace:
[   56.252049]  [<ffffffff8940f07e>] ? kset_find_obj+0x3e/0x7b
[   56.252049]  [<ffffffff8940f07e>] ? kset_find_obj+0x3e/0x7b
[   56.252049]  [<ffffffff89514cea>] driver_find+0x1e/0x3c
[   56.252049]  [<ffffffff89514cea>] driver_find+0x1e/0x3c
[   56.252049]  [<ffffffff89514d6b>] driver_register+0x63/0xc5
[   56.252049]  [<ffffffff89514d6b>] driver_register+0x63/0xc5
[   56.252049]  [<ffffffff89690efd>] usb_register_driver+0xa2/0x14c
[   56.252049]  [<ffffffff89690efd>] usb_register_driver+0xa2/0x14c
[   56.252049]  [<ffffffff8a1d0a5d>] ? netif_init+0x3f/0x3f
[   56.252049]  [<ffffffff8a1d0a5d>] ? netif_init+0x3f/0x3f
[   56.252049]  [<ffffffff8a1d0a76>] kaweth_driver_init+0x19/0x1b
[   56.252049]  [<ffffffff8a1d0a76>] kaweth_driver_init+0x19/0x1b
[   56.252049]  [<ffffffff8a19ee0b>] do_one_initcall+0x9f/0x135
[   56.252049]  [<ffffffff8a19ee0b>] do_one_initcall+0x9f/0x135
[   56.252049]  [<ffffffff892cf010>] ? parse_args+0x25c/0x33a
[   56.252049]  [<ffffffff892cf010>] ? parse_args+0x25c/0x33a
[   56.252049]  [<ffffffff8a19f097>] kernel_init_freeable+0x1f6/0x277
[   56.252049]  [<ffffffff8a19f097>] kernel_init_freeable+0x1f6/0x277
[   56.252049]  [<ffffffff8a19e72a>] ? do_early_param+0x88/0x88
[   56.252049]  [<ffffffff8a19e72a>] ? do_early_param+0x88/0x88
[   56.252049]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[   56.252049]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[   56.252049]  [<ffffffff89aef9d1>] kernel_init+0x9/0xd5
[   56.252049]  [<ffffffff89aef9d1>] kernel_init+0x9/0xd5
[   56.252049]  [<ffffffff89b0bd4c>] ret_from_fork+0x7c/0xb0
[   56.252049]  [<ffffffff89b0bd4c>] ret_from_fork+0x7c/0xb0
[   56.252049]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[   56.252049]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[   56.252049] Code:=20
[   56.252049] Code: 38 38 00 00 74 74 05 05 49 49 ff ff c0 c0 eb eb f5 f5 =
31 31 c9 c9 40 40 8a 8a 3c 3c 0e 0e 4d 4d 8d 8d 0c 0c 08 08 40 40 84 84 ff =
ff 41 41 88 88 3c 3c 08 08 74 74 0d 0d 48 48 ff ff c1 c1 48 48 39 39 ca ca =
75 75 e7 e7 41 41 c6 c6 41 41 01 01 00 00 5d 5d c3 c3 <55> <55> 31 31 c0 c0=
 48 48 89 89 e5 e5 8a 8a 14 14 07 07 3a 3a 14 14 06 06 74 74 07 07 19 19 c0=
 c0 83 83 c8 c8 01 01 eb eb 09 09=20

[   56.252049] Kernel panic - not syncing: softlockup: hung tasks
[   56.252049] Kernel panic - not syncing: softlockup: hung tasks
[   56.252049] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W    3.14.0-=
rc3-02129-g63e12bf #2
[   56.252049] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W    3.14.0-=
rc3-02129-g63e12bf #2
[   56.252049]  0000000000000000
[   56.252049]  0000000000000000 ffff88000fa03e40 ffff88000fa03e40 ffffffff=
89afbd2f ffffffff89afbd2f ffffffff89ed295f ffffffff89ed295f

[   56.252049]  ffff88000fa03eb8
[   56.252049]  ffff88000fa03eb8 ffffffff89af96c5 ffffffff89af96c5 00000000=
00000008 0000000000000008 ffff88000fa03ec8 ffff88000fa03ec8

[   56.252049]  ffff88000fa03e68
[   56.252049]  ffff88000fa03e68 0000000000000002 0000000000000002 00000000=
0000504e 000000000000504e ffff88000014e010 ffff88000014e010

[   56.252049] Call Trace:
[   56.252049] Call Trace:
[   56.252049]  <IRQ>=20
[   56.252049]  <IRQ>  [<ffffffff89afbd2f>] dump_stack+0x4d/0x66
 [<ffffffff89afbd2f>] dump_stack+0x4d/0x66
[   56.252049]  [<ffffffff89af96c5>] panic+0xcb/0x1d7
[   56.252049]  [<ffffffff89af96c5>] panic+0xcb/0x1d7
[   56.252049]  [<ffffffff893271d9>] watchdog_timer_fn+0x128/0x14a
[   56.252049]  [<ffffffff893271d9>] watchdog_timer_fn+0x128/0x14a
[   56.252049]  [<ffffffff893270b1>] ? __touch_watchdog+0x18/0x18
[   56.252049]  [<ffffffff893270b1>] ? __touch_watchdog+0x18/0x18
[   56.252049]  [<ffffffff892d2ed5>] __run_hrtimer.isra.24+0x66/0xbf
[   56.252049]  [<ffffffff892d2ed5>] __run_hrtimer.isra.24+0x66/0xbf
[   56.252049]  [<ffffffff892d35dd>] hrtimer_interrupt+0xe2/0x1c9
[   56.252049]  [<ffffffff892d35dd>] hrtimer_interrupt+0xe2/0x1c9
[   56.252049]  [<ffffffff89263653>] local_apic_timer_interrupt+0x4f/0x52
[   56.252049]  [<ffffffff89263653>] local_apic_timer_interrupt+0x4f/0x52
[   56.252049]  [<ffffffff89263b1a>] smp_apic_timer_interrupt+0x3a/0x4b
[   56.252049]  [<ffffffff89263b1a>] smp_apic_timer_interrupt+0x3a/0x4b
[   56.252049]  [<ffffffff89b0ca6f>] apic_timer_interrupt+0x6f/0x80
[   56.252049]  [<ffffffff89b0ca6f>] apic_timer_interrupt+0x6f/0x80
[   56.252049]  <EOI>=20
[   56.252049]  <EOI>  [<ffffffff8940f05d>] ? kset_find_obj+0x1d/0x7b
 [<ffffffff8940f05d>] ? kset_find_obj+0x1d/0x7b
[   56.252049]  [<ffffffff8940f05d>] ? kset_find_obj+0x1d/0x7b
[   56.252049]  [<ffffffff8940f05d>] ? kset_find_obj+0x1d/0x7b
[   56.252049]  [<ffffffff89413a3c>] ? strncat+0x3c/0x3c
[   56.252049]  [<ffffffff89413a3c>] ? strncat+0x3c/0x3c
[   56.252049]  [<ffffffff8940f07e>] ? kset_find_obj+0x3e/0x7b
[   56.252049]  [<ffffffff8940f07e>] ? kset_find_obj+0x3e/0x7b
[   56.252049]  [<ffffffff89514cea>] driver_find+0x1e/0x3c
[   56.252049]  [<ffffffff89514cea>] driver_find+0x1e/0x3c
[   56.252049]  [<ffffffff89514d6b>] driver_register+0x63/0xc5
[   56.252049]  [<ffffffff89514d6b>] driver_register+0x63/0xc5
[   56.252049]  [<ffffffff89690efd>] usb_register_driver+0xa2/0x14c
[   56.252049]  [<ffffffff89690efd>] usb_register_driver+0xa2/0x14c
[   56.252049]  [<ffffffff8a1d0a5d>] ? netif_init+0x3f/0x3f
[   56.252049]  [<ffffffff8a1d0a5d>] ? netif_init+0x3f/0x3f
[   56.252049]  [<ffffffff8a1d0a76>] kaweth_driver_init+0x19/0x1b
[   56.252049]  [<ffffffff8a1d0a76>] kaweth_driver_init+0x19/0x1b
[   56.252049]  [<ffffffff8a19ee0b>] do_one_initcall+0x9f/0x135
[   56.252049]  [<ffffffff8a19ee0b>] do_one_initcall+0x9f/0x135
[   56.252049]  [<ffffffff892cf010>] ? parse_args+0x25c/0x33a
[   56.252049]  [<ffffffff892cf010>] ? parse_args+0x25c/0x33a
[   56.252049]  [<ffffffff8a19f097>] kernel_init_freeable+0x1f6/0x277
[   56.252049]  [<ffffffff8a19f097>] kernel_init_freeable+0x1f6/0x277
[   56.252049]  [<ffffffff8a19e72a>] ? do_early_param+0x88/0x88
[   56.252049]  [<ffffffff8a19e72a>] ? do_early_param+0x88/0x88
[   56.252049]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[   56.252049]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[   56.252049]  [<ffffffff89aef9d1>] kernel_init+0x9/0xd5
[   56.252049]  [<ffffffff89aef9d1>] kernel_init+0x9/0xd5
[   56.252049]  [<ffffffff89b0bd4c>] ret_from_fork+0x7c/0xb0
[   56.252049]  [<ffffffff89b0bd4c>] ret_from_fork+0x7c/0xb0
[   56.252049]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[   56.252049]  [<ffffffff89aef9c8>] ? rest_init+0x13c/0x13c
[   56.252049] Kernel Offset: 0x8200000 from 0xffffffff81000000 (relocation=
 range: 0xffffffff80000000-0xffffffffbfffffff)
[   56.252049] Kernel Offset: 0x8200000 from 0xffffffff81000000 (relocation=
 range: 0xffffffff80000000-0xffffffffbfffffff)

Elapsed time: 65
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/x86_64-randconfig=
-a3-02202054/63e12bfe8d8b215605812bb912e54db53356a5d5/vmlinuz-3.14.0-rc3-02=
129-g63e12bf -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug =
apic=3Ddebug sysrq_always_enabled panic=3D10 softlockup_panic=3D1 nmi_watch=
dog=3Dpanic  prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=
=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-tests/run-queue/kvm/x86_64-ra=
ndconfig-a3-02202054/linux-devel:devel-hourly-2014022021/.vmlinuz-63e12bfe8=
d8b215605812bb912e54db53356a5d5-20140220222018-3-jaketown branch=3Dlinux-de=
vel/devel-hourly-2014022021 BOOT_IMAGE=3D/kernel/x86_64-randconfig-a3-02202=
054/63e12bfe8d8b215605812bb912e54db53356a5d5/vmlinuz-3.14.0-rc3-02129-g63e1=
2bf'  -initrd /kernel-tests/initrd/yocto-minimal-x86_64.cgz -m 256 -smp 2 -=
net nic,vlan=3D1,model=3De1000 -net user,vlan=3D1,hostfwd=3Dtcp::35856-:22 =
-boot order=3Dnc -no-reboot -watchdog i6300esb -rtc base=3Dlocaltime -pidfi=
le /dev/shm/kboot/pid-yocto-jaketown-38 -serial file:/dev/shm/kboot/serial-=
yocto-jaketown-38 -daemonize -display none -monitor null=20

--sdtB3X0nJg68CQEu
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="x86_64-randconfig-a3-02202054-63e12bfe8d8b215605812bb912e54db53356a5d5-kaweth_driver_init+-x-65498.log"
Content-Transfer-Encoding: base64

Z2l0IGNoZWNrb3V0IDZkMGFiZWNhMzI0MmE4OGNhYjgyMzJlNGFjZDdlMmJmMDg4ZjNiYzIK
bHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWEz
LTAyMjAyMDU0L2xpbnV4LWRldmVsOmRldmVsLWhvdXJseS0yMDE0MDIyMDIxOjZkMGFiZWNh
MzI0MmE4OGNhYjgyMzJlNGFjZDdlMmJmMDg4ZjNiYzI6YmlzZWN0LWxpbnV4CgoyMDE0LTAy
LTIxLTEyOjIwOjQ2IDZkMGFiZWNhMzI0MmE4OGNhYjgyMzJlNGFjZDdlMmJmMDg4ZjNiYzIg
Y29tcGlsaW5nCjE4MSByZWFsICAxNjA2IHVzZXIgIDE0OCBzeXMgIDk2OC40NyUgY3B1IAl4
ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NAoKMjAxNC0wMi0yMS0xMjoyNDowOSBkZXRl
Y3RpbmcgYm9vdCBzdGF0ZSAzLjE0LjAtcmMzLgkzIFRFU1QgRkFJTFVSRQpbICAgIDIuMzA0
NjkyXSBtYWM4MDIxMV9od3NpbTogaWVlZTgwMjExX3JlZ2lzdGVyX2h3IGZhaWxlZCAoLTIp
ClsgICAgMi4zMDYyOTFdIC0tLS0tLS0tLS0tLVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0tLQpb
ICAgIDIuMzA2MjkxXSAtLS0tLS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0KWyAg
ICAyLjMwNzQ2OV0gV0FSTklORzogQ1BVOiAxIFBJRDogMSBhdCAva2VybmVsLXRlc3RzL2xp
bnV4L2luY2x1ZGUvbGludXgva3JlZi5oOjQ3IGtvYmplY3RfZ2V0KzB4MzcvMHg0NCgpCi9r
ZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvNmQwYWJlY2EzMjQyYTg4Y2Fi
ODIzMmU0YWNkN2UyYmYwODhmM2JjMi9kbWVzZy15b2N0by1pbm4tMjI6MjAxNDAyMjExMjI0
NDc6eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6Ogova2VybmVsL3g4Nl82NC1yYW5k
Y29uZmlnLWEzLTAyMjAyMDU0LzZkMGFiZWNhMzI0MmE4OGNhYjgyMzJlNGFjZDdlMmJmMDg4
ZjNiYzIvZG1lc2cteW9jdG8tc25iLTMzOjIwMTQwMjIxMTIyNDQ0Ong4Nl82NC1yYW5kY29u
ZmlnLWEzLTAyMjAyMDU0OjoKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1
NC82ZDBhYmVjYTMyNDJhODhjYWI4MjMyZTRhY2Q3ZTJiZjA4OGYzYmMyL2RtZXNnLXlvY3Rv
LXNuYi00MToyMDE0MDIyMTEyMjQ0NDp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDo6
Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvNmQwYWJlY2EzMjQyYTg4
Y2FiODIzMmU0YWNkN2UyYmYwODhmM2JjMi9kbWVzZy1xdWFudGFsLWF0aGVucy01NToyMDE0
MDIyMTEyMjQ0ODp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDozLjE0LjAtcmMzOjUy
Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvNmQwYWJlY2EzMjQyYTg4
Y2FiODIzMmU0YWNkN2UyYmYwODhmM2JjMi9kbWVzZy15b2N0by14Z3dvLTQ6MjAxNDAyMjEx
MjI0NDc6eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6My4xNC4wLXJjMzo1Mgova2Vy
bmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0LzZkMGFiZWNhMzI0MmE4OGNhYjgy
MzJlNGFjZDdlMmJmMDg4ZjNiYzIvZG1lc2cteW9jdG8teGd3by02OjIwMTQwMjIxMTIyNDQ4
Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjMuMTQuMC1yYzM6NTIKL2tlcm5lbC94
ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC82ZDBhYmVjYTMyNDJhODhjYWI4MjMyZTRh
Y2Q3ZTJiZjA4OGYzYmMyL2RtZXNnLXF1YW50YWwteGd3by01OjIwMTQwMjIxMTIyNDU1Ong4
Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjMuMTQuMC1yYzM6NTIKL2tlcm5lbC94ODZf
NjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC82ZDBhYmVjYTMyNDJhODhjYWI4MjMyZTRhY2Q3
ZTJiZjA4OGYzYmMyL2RtZXNnLXlvY3RvLWF0aGVucy0xMToyMDE0MDIyMTEyMjQ1MDp4ODZf
NjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDozLjE0LjAtcmMzOjUyCi9rZXJuZWwveDg2XzY0
LXJhbmRjb25maWctYTMtMDIyMDIwNTQvNmQwYWJlY2EzMjQyYTg4Y2FiODIzMmU0YWNkN2Uy
YmYwODhmM2JjMi9kbWVzZy15b2N0by1jYWlyby00MDoyMDE0MDIyMTEyMjQ1Mjp4ODZfNjQt
cmFuZGNvbmZpZy1hMy0wMjIwMjA1NDozLjE0LjAtcmMzOjUyCi9rZXJuZWwveDg2XzY0LXJh
bmRjb25maWctYTMtMDIyMDIwNTQvNmQwYWJlY2EzMjQyYTg4Y2FiODIzMmU0YWNkN2UyYmYw
ODhmM2JjMi9kbWVzZy15b2N0by1jYWlyby05OjIwMTQwMjIxMTIyNDU2Ong4Nl82NC1yYW5k
Y29uZmlnLWEzLTAyMjAyMDU0OjMuMTQuMC1yYzM6NTIKL2tlcm5lbC94ODZfNjQtcmFuZGNv
bmZpZy1hMy0wMjIwMjA1NC82ZDBhYmVjYTMyNDJhODhjYWI4MjMyZTRhY2Q3ZTJiZjA4OGYz
YmMyL2RtZXNnLXlvY3RvLXhpYW4tMTc6MjAxNDAyMjExMjI0NTE6eDg2XzY0LXJhbmRjb25m
aWctYTMtMDIyMDIwNTQ6My4xNC4wLXJjMzo1Mgova2VybmVsL3g4Nl82NC1yYW5kY29uZmln
LWEzLTAyMjAyMDU0LzZkMGFiZWNhMzI0MmE4OGNhYjgyMzJlNGFjZDdlMmJmMDg4ZjNiYzIv
ZG1lc2cteW9jdG8teGlhbi00OToyMDE0MDIyMTEyMjQ1Mzp4ODZfNjQtcmFuZGNvbmZpZy1h
My0wMjIwMjA1NDozLjE0LjAtcmMzOjUyCjA6MTI6MTUgYWxsX2dvb2Q6YmFkOmFsbF9iYWQg
Ym9vdHMKG1sxOzM1bTIwMTQtMDItMjEgMTI6MjU6MTAgUkVQRUFUIENPVU5UOiAyMiAgIyAv
a2VybmVsLXRlc3RzL2xpbnV4L29iai1iaXNlY3QvLnJlcGVhdBtbMG0KCmJpc2VjdDogYmFk
IGNvbW1pdCA2ZDBhYmVjYTMyNDJhODhjYWI4MjMyZTRhY2Q3ZTJiZjA4OGYzYmMyCmdpdCBj
aGVja291dCB2My4xMwpscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0
LXJhbmRjb25maWctYTMtMDIyMDIwNTQvbGludXgtZGV2ZWw6ZGV2ZWwtaG91cmx5LTIwMTQw
MjIwMjE6ZDhlYzI2ZDdmODI4N2Y1Nzg4YTQ5NGY1NmU4ODE0MjEwZjBlNjRiZTpiaXNlY3Qt
bGludXgKCjIwMTQtMDItMjEtMTI6MjU6MTMgZDhlYzI2ZDdmODI4N2Y1Nzg4YTQ5NGY1NmU4
ODE0MjEwZjBlNjRiZSBjb21waWxpbmcKMTk4IHJlYWwgIDE1NzEgdXNlciAgMTQwIHN5cyAg
ODYxLjUyJSBjcHUgCXg4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0CgoyMDE0LTAyLTIx
LTEyOjI5OjUzIGRldGVjdGluZyBib290IHN0YXRlIDMuMTMuMC4uCTIJMTMJMjAuCTIxLgky
MiBTVUNDRVNTCgpiaXNlY3Q6IGdvb2QgY29tbWl0IHYzLjEzCmdpdCBiaXNlY3Qgc3RhcnQg
NmQwYWJlY2EzMjQyYTg4Y2FiODIzMmU0YWNkN2UyYmYwODhmM2JjMiB2My4xMyAtLQovYy9r
ZXJuZWwtdGVzdHMvbGluZWFyLWJpc2VjdDogWyItYiIsICI2ZDBhYmVjYTMyNDJhODhjYWI4
MjMyZTRhY2Q3ZTJiZjA4OGYzYmMyIiwgIi1nIiwgInYzLjEzIiwgIi9jL2tlcm5lbC10ZXN0
cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2giLCAiL2tlcm5lbC10ZXN0cy9saW51eC9v
YmotYmlzZWN0Il0KQmlzZWN0aW5nOiAxMjEyOCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFm
dGVyIHRoaXMgKHJvdWdobHkgMTQgc3RlcHMpCltlOTE0ZTNmNDhkMGYzOTc4ZDE1NjFhZTM2
Njg5MDhlNGMwMjYyYWNmXSBNZXJnZSBicmFuY2ggJ2Zvci1saW51cycgb2YgZ2l0Oi8vZnRw
LmFybS5saW51eC5vcmcudWsvfnJtay9saW51eC1hcm0KcnVubmluZyAvYy9rZXJuZWwtdGVz
dHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9rZXJuZWwtdGVzdHMvbGludXgvb2Jq
LWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRj
b25maWctYTMtMDIyMDIwNTQvbGludXgtZGV2ZWw6ZGV2ZWwtaG91cmx5LTIwMTQwMjIwMjE6
ZTkxNGUzZjQ4ZDBmMzk3OGQxNTYxYWUzNjY4OTA4ZTRjMDI2MmFjZjpiaXNlY3QtbGludXgK
CjIwMTQtMDItMjEtMTI6MzQ6MzggZTkxNGUzZjQ4ZDBmMzk3OGQxNTYxYWUzNjY4OTA4ZTRj
MDI2MmFjZiBjb21waWxpbmcKMjIyIHJlYWwgIDE1OTIgdXNlciAgMTM5IHN5cyAgNzc3Ljky
JSBjcHUgCXg4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0CgoyMDE0LTAyLTIxLTEyOjM5
OjUzIGRldGVjdGluZyBib290IHN0YXRlIDMuMTMuMC0wOTI5NC1nZTkxNGUzZi4uCTIJNyBU
RVNUIEZBSUxVUkUKWyAgICAzLjUxNjUwMF0gU0M1MjAgQ0RQIGZsYXNoIGRldmljZTogMHg4
MDAwMDAgYXQgMHg4NDAwMDAwClsgICAgMy41MTg1NTZdIC0tLS0tLS0tLS0tLVsgY3V0IGhl
cmUgXS0tLS0tLS0tLS0tLQpbICAgIDMuNTE4NTU2XSAtLS0tLS0tLS0tLS1bIGN1dCBoZXJl
IF0tLS0tLS0tLS0tLS0KWyAgICAzLjUyMDM4OF0gV0FSTklORzogQ1BVOiAxIFBJRDogMSBh
dCAva2VybmVsLXRlc3RzL2xpbnV4L2FyY2gveDg2L21tL2lvcmVtYXAuYzoxMDIgX19pb3Jl
bWFwX2NhbGxlcisweDEyNC8weDJmNigpCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMt
MDIyMDIwNTQvZTkxNGUzZjQ4ZDBmMzk3OGQxNTYxYWUzNjY4OTA4ZTRjMDI2MmFjZi9kbWVz
Zy15b2N0by1qYWtldG93bi0zNDoyMDE0MDIyMTEyNDEyNzp4ODZfNjQtcmFuZGNvbmZpZy1h
My0wMjIwMjA1NDo6Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvZTkx
NGUzZjQ4ZDBmMzk3OGQxNTYxYWUzNjY4OTA4ZTRjMDI2MmFjZi9kbWVzZy15b2N0by1pbm4t
Mzk6MjAxNDAyMjExMjQxMzU6eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6Ogova2Vy
bmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0L2U5MTRlM2Y0OGQwZjM5NzhkMTU2
MWFlMzY2ODkwOGU0YzAyNjJhY2YvZG1lc2cteW9jdG8tamFrZXRvd24tMTM6MjAxNDAyMjEx
MjQxMzI6eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6Ogova2VybmVsL3g4Nl82NC1y
YW5kY29uZmlnLWEzLTAyMjAyMDU0L2U5MTRlM2Y0OGQwZjM5NzhkMTU2MWFlMzY2ODkwOGU0
YzAyNjJhY2YvZG1lc2cteW9jdG8tamFrZXRvd24tNDI6MjAxNDAyMjExMjQxMjk6eDg2XzY0
LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6Ogova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEz
LTAyMjAyMDU0L2U5MTRlM2Y0OGQwZjM5NzhkMTU2MWFlMzY2ODkwOGU0YzAyNjJhY2YvZG1l
c2cteW9jdG8tamFrZXRvd24tMzY6MjAxNDAyMjExMjQxMzI6eDg2XzY0LXJhbmRjb25maWct
YTMtMDIyMDIwNTQ6Ogova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0L2U5
MTRlM2Y0OGQwZjM5NzhkMTU2MWFlMzY2ODkwOGU0YzAyNjJhY2YvZG1lc2ctcXVhbnRhbC1h
dGhlbnMtNTk6MjAxNDAyMjExMjQxNDA6eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6
My4xMy4wLTA5Mjk0LWdlOTE0ZTNmOjU0Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMt
MDIyMDIwNTQvZTkxNGUzZjQ4ZDBmMzk3OGQxNTYxYWUzNjY4OTA4ZTRjMDI2MmFjZi9kbWVz
Zy1xdWFudGFsLWlubi0yMDoyMDE0MDIyMTEyNDE0MDp4ODZfNjQtcmFuZGNvbmZpZy1hMy0w
MjIwMjA1NDo6Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvZTkxNGUz
ZjQ4ZDBmMzk3OGQxNTYxYWUzNjY4OTA4ZTRjMDI2MmFjZi9kbWVzZy1xdWFudGFsLWlubi00
MToyMDE0MDIyMTEyNDE0MDp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDo6Ci9rZXJu
ZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvZTkxNGUzZjQ4ZDBmMzk3OGQxNTYx
YWUzNjY4OTA4ZTRjMDI2MmFjZi9kbWVzZy15b2N0by1iZW5zLTY6MjAxNDAyMjExMjQxNDE6
eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6My4xMy4wLTA5Mjk0LWdlOTE0ZTNmOjU0
Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvZTkxNGUzZjQ4ZDBmMzk3
OGQxNTYxYWUzNjY4OTA4ZTRjMDI2MmFjZi9kbWVzZy15b2N0by1jYWlyby0xOjIwMTQwMjIx
MTI0MTQwOng4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjMuMTMuMC0wOTI5NC1nZTkx
NGUzZjo1NAowOjEwOjE3IGFsbF9nb29kOmJhZDphbGxfYmFkIGJvb3RzChtbMTszNW0yMDE0
LTAyLTIxIDEyOjQxOjU0IFJFUEVBVCBDT1VOVDogMjcgICMgL2tlcm5lbC10ZXN0cy9saW51
eC9vYmotYmlzZWN0Ly5yZXBlYXQbWzBtCgpCaXNlY3Rpbmc6IDkyOTQgcmV2aXNpb25zIGxl
ZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDE0IHN0ZXBzKQpbMGQ5MGQ2Mzg3MjBi
YTE0ODc0ZTM0Y2JkODc2NmU0ZGMzZjE0ZjQ1OF0gTWVyZ2UgdGFnICdmb3ItZjJmcy0zLjE0
JyBvZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvamFl
Z2V1ay9mMmZzCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFp
bHVyZS5zaCAva2VybmVsLXRlc3RzL2xpbnV4L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10
ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0L2xpbnV4
LWRldmVsOmRldmVsLWhvdXJseS0yMDE0MDIyMDIxOjBkOTBkNjM4NzIwYmExNDg3NGUzNGNi
ZDg3NjZlNGRjM2YxNGY0NTg6YmlzZWN0LWxpbnV4CgoyMDE0LTAyLTIxLTEyOjQxOjU4IDBk
OTBkNjM4NzIwYmExNDg3NGUzNGNiZDg3NjZlNGRjM2YxNGY0NTggY29tcGlsaW5nCjk3IHJl
YWwgIDE1ODYgdXNlciAgMTM5IHN5cyAgMTc2My4yNiUgY3B1IAl4ODZfNjQtcmFuZGNvbmZp
Zy1hMy0wMjIwMjA1NAoKMjAxNC0wMi0yMS0xMjo0NDo0MCBkZXRlY3RpbmcgYm9vdCBzdGF0
ZSAzLjEzLjAtMDQxNDctZzBkOTBkNjMJMTcJMjMuCTI2Li4uLi4uLi4uLi4uLi4uLgkyNyBT
VUNDRVNTCgpCaXNlY3Rpbmc6IDUxNDcgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0
aGlzIChyb3VnaGx5IDEzIHN0ZXBzKQpbYjJlNDQ4ZWNhMWE1MmZlYTE4MTkwNTg0NTcyOGFl
MDBhMTM4ZDg0ZV0gTWVyZ2UgYnJhbmNoICdpcG1pJyAoaXBtaSBwYXRjaGVzIGZyb20gQ29y
ZXkgTWlueWFyZCkKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1m
YWlsdXJlLnNoIC9rZXJuZWwtdGVzdHMvbGludXgvb2JqLWJpc2VjdApscyAtYSAva2VybmVs
LXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvbGlu
dXgtZGV2ZWw6ZGV2ZWwtaG91cmx5LTIwMTQwMjIwMjE6YjJlNDQ4ZWNhMWE1MmZlYTE4MTkw
NTg0NTcyOGFlMDBhMTM4ZDg0ZTpiaXNlY3QtbGludXgKCjIwMTQtMDItMjEtMTI6NTU6MTMg
YjJlNDQ4ZWNhMWE1MmZlYTE4MTkwNTg0NTcyOGFlMDBhMTM4ZDg0ZSBjb21waWxpbmcKMTYy
IHJlYWwgIDE1NzIgdXNlciAgMTQxIHN5cyAgMTA1NS40OCUgY3B1IAl4ODZfNjQtcmFuZGNv
bmZpZy1hMy0wMjIwMjA1NAoKMjAxNC0wMi0yMS0xMjo1ODoxMyBkZXRlY3RpbmcgYm9vdCBz
dGF0ZSAzLjEzLjAtMDg1MjYtZ2IyZTQ0OGUuLiBURVNUIEZBSUxVUkUKWyAgICAyLjEyMDQ3
NV0gbWFjODAyMTFfaHdzaW06IGllZWU4MDIxMV9yZWdpc3Rlcl9odyBmYWlsZWQgKC0yKQpb
ICAgIDIuMTIxNzIzXSAtLS0tLS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0KWyAg
ICAyLjEyMTcyM10gLS0tLS0tLS0tLS0tWyBjdXQgaGVyZSBdLS0tLS0tLS0tLS0tClsgICAg
Mi4xMjI2NTVdIFdBUk5JTkc6IENQVTogMSBQSUQ6IDEgYXQgL2tlcm5lbC10ZXN0cy9saW51
eC9pbmNsdWRlL2xpbnV4L2tyZWYuaDo0NyBrb2JqZWN0X2dldCsweDM3LzB4NDQoKQova2Vy
bmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0L2IyZTQ0OGVjYTFhNTJmZWExODE5
MDU4NDU3MjhhZTAwYTEzOGQ4NGUvZG1lc2ctcXVhbnRhbC1jYWlyby05OjIwMTQwMjIxMTI1
ODU0Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjMuMTMuMC0wODUyNi1nYjJlNDQ4
ZTo1Ngova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0L2IyZTQ0OGVjYTFh
NTJmZWExODE5MDU4NDU3MjhhZTAwYTEzOGQ4NGUvZG1lc2ctcXVhbnRhbC14aWFuLTI5OjIw
MTQwMjIxMTI1ODUwOng4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjMuMTMuMC0wODUy
Ni1nYjJlNDQ4ZTo1Ngova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0L2Iy
ZTQ0OGVjYTFhNTJmZWExODE5MDU4NDU3MjhhZTAwYTEzOGQ4NGUvZG1lc2cteW9jdG8teGlh
bi00NjoyMDE0MDIyMTEyNTg1MDp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDozLjEz
LjAtMDg1MjYtZ2IyZTQ0OGU6NTYKMDozOjMgYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMK
CkJpc2VjdGluZzogNDM3OSByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJv
dWdobHkgMTMgc3RlcHMpCls5MTQ2NjU3NGJlMWEzNzAxZmFiNGFiZjVhYzE1MzliNTU2NTc1
YTgxXSBNZXJnZSBicmFuY2ggJ25leHQnIG9mIGdpdDovL2dpdC5rZXJuZWwub3JnL3B1Yi9z
Y20vbGludXgva2VybmVsL2dpdC9yemhhbmcvbGludXgKcnVubmluZyAvYy9rZXJuZWwtdGVz
dHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9rZXJuZWwtdGVzdHMvbGludXgvb2Jq
LWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRj
b25maWctYTMtMDIyMDIwNTQvbGludXgtZGV2ZWw6ZGV2ZWwtaG91cmx5LTIwMTQwMjIwMjE6
OTE0NjY1NzRiZTFhMzcwMWZhYjRhYmY1YWMxNTM5YjU1NjU3NWE4MTpiaXNlY3QtbGludXgK
CjIwMTQtMDItMjEtMTI6NTk6MTUgOTE0NjY1NzRiZTFhMzcwMWZhYjRhYmY1YWMxNTM5YjU1
NjU3NWE4MSBjb21waWxpbmcKMTcyIHJlYWwgIDE1NzQgdXNlciAgMTM2IHN5cyAgOTk0LjY2
JSBjcHUgCXg4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0CgoyMDE0LTAyLTIxLTEzOjAy
OjE4IGRldGVjdGluZyBib290IHN0YXRlIDMuMTMuMC0wNTgzMy1nOTE0NjY1NwkzCTE4CTIz
CTI3IFNVQ0NFU1MKCkJpc2VjdGluZzogMjY5MyByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFm
dGVyIHRoaXMgKHJvdWdobHkgMTIgc3RlcHMpCls3YWUwZTA2YjkwOWUzMWJmOWEzOTZhMjMy
NmVmMDliNzY4ZDliNGM0XSBNZXJnZSB0YWcgJ2FyYy12My4xNC1yYzEnIG9mIGdpdDovL2dp
dC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC92Z3VwdGEvYXJjCnJ1bm5p
bmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAva2VybmVs
LXRlc3RzL2xpbnV4L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUv
a3ZtL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0L2xpbnV4LWRldmVsOmRldmVsLWhv
dXJseS0yMDE0MDIyMDIxOjdhZTBlMDZiOTA5ZTMxYmY5YTM5NmEyMzI2ZWYwOWI3NjhkOWI0
YzQ6YmlzZWN0LWxpbnV4CgoyMDE0LTAyLTIxLTEzOjA0OjIzIDdhZTBlMDZiOTA5ZTMxYmY5
YTM5NmEyMzI2ZWYwOWI3NjhkOWI0YzQgY29tcGlsaW5nCjEwOSByZWFsICA2MjIgdXNlciAg
NTQgc3lzICA2MjAuNjYlIGNwdSAJeDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQKCjIw
MTQtMDItMjEtMTM6MDY6MjkgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMy4wLTA2MTA3LWc3
YWUwZTA2CTE5LgkyMQkyNgkyNyBTVUNDRVNTCgpCaXNlY3Rpbmc6IDI0MTkgcmV2aXNpb25z
IGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDEyIHN0ZXBzKQpbNGJhOTkyMGU1
ZTljMGUxNmI1ZWQyNDI5MmQ0NTMyMjkwN2JiOTAzNV0gTWVyZ2UgZ2l0Oi8vZ2l0Lmtlcm5l
bC5vcmcvcHViL3NjbS9saW51eC9rZXJuZWwvZ2l0L2RhdmVtL25ldC1uZXh0CnJ1bm5pbmcg
L2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAva2VybmVsLXRl
c3RzL2xpbnV4L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3Zt
L3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0L2xpbnV4LWRldmVsOmRldmVsLWhvdXJs
eS0yMDE0MDIyMDIxOjRiYTk5MjBlNWU5YzBlMTZiNWVkMjQyOTJkNDUzMjI5MDdiYjkwMzU6
YmlzZWN0LWxpbnV4CgoyMDE0LTAyLTIxLTEzOjA5OjA2IDRiYTk5MjBlNWU5YzBlMTZiNWVk
MjQyOTJkNDUzMjI5MDdiYjkwMzUgY29tcGlsaW5nCjE0OCByZWFsICAxNTgzIHVzZXIgIDE0
MSBzeXMgIDExNjMuOTclIGNwdSAJeDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQKCjIw
MTQtMDItMjEtMTM6MTE6NTYgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMy4wLTA4MzMwLWc0
YmE5OTIwLgkxIFRFU1QgRkFJTFVSRQpbICAgIDMuMTMyNjY5XSBtYWM4MDIxMV9od3NpbTog
aWVlZTgwMjExX3JlZ2lzdGVyX2h3IGZhaWxlZCAoLTIpClsgICAgMy4xMzQ3MzVdIC0tLS0t
LS0tLS0tLVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0tLQpbICAgIDMuMTM0NzM1XSAtLS0tLS0t
LS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0KWyAgICAzLjEzNjI5OF0gV0FSTklORzog
Q1BVOiAxIFBJRDogMSBhdCAva2VybmVsLXRlc3RzL2xpbnV4L2luY2x1ZGUvbGludXgva3Jl
Zi5oOjQ3IGtvYmplY3RfZ2V0KzB4MzcvMHg0NCgpCi9rZXJuZWwveDg2XzY0LXJhbmRjb25m
aWctYTMtMDIyMDIwNTQvNGJhOTkyMGU1ZTljMGUxNmI1ZWQyNDI5MmQ0NTMyMjkwN2JiOTAz
NS9kbWVzZy15b2N0by1pbm4tMjU6MjAxNDAyMjExMzEyNDI6eDg2XzY0LXJhbmRjb25maWct
YTMtMDIyMDIwNTQ6Ogova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0LzRi
YTk5MjBlNWU5YzBlMTZiNWVkMjQyOTJkNDUzMjI5MDdiYjkwMzUvZG1lc2cteW9jdG8teGlh
bi0yNjoyMDE0MDIyMTEzMTI0Mjp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDozLjEz
LjAtMDgzMzAtZzRiYTk5MjA6NTkKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIw
MjA1NC80YmE5OTIwZTVlOWMwZTE2YjVlZDI0MjkyZDQ1MzIyOTA3YmI5MDM1L2RtZXNnLXlv
Y3RvLXhpYW4tNTM6MjAxNDAyMjExMzEyNDQ6eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIw
NTQ6My4xMy4wLTA4MzMwLWc0YmE5OTIwOjU5Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWct
YTMtMDIyMDIwNTQvNGJhOTkyMGU1ZTljMGUxNmI1ZWQyNDI5MmQ0NTMyMjkwN2JiOTAzNS9k
bWVzZy1xdWFudGFsLWNhaXJvLTI2OjIwMTQwMjIxMTMxMjQ4Ong4Nl82NC1yYW5kY29uZmln
LWEzLTAyMjAyMDU0OjMuMTMuMC0wODMzMC1nNGJhOTkyMDo1OQova2VybmVsL3g4Nl82NC1y
YW5kY29uZmlnLWEzLTAyMjAyMDU0LzRiYTk5MjBlNWU5YzBlMTZiNWVkMjQyOTJkNDUzMjI5
MDdiYjkwMzUvZG1lc2cteW9jdG8tY2Fpcm8tNDQ6MjAxNDAyMjExMzEyNDg6eDg2XzY0LXJh
bmRjb25maWctYTMtMDIyMDIwNTQ6My4xMy4wLTA4MzMwLWc0YmE5OTIwOjU5Ci9rZXJuZWwv
eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvNGJhOTkyMGU1ZTljMGUxNmI1ZWQyNDI5
MmQ0NTMyMjkwN2JiOTAzNS9kbWVzZy15b2N0by1jYWlyby00OToyMDE0MDIyMTEzMTI0ODp4
ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDozLjEzLjAtMDgzMzAtZzRiYTk5MjA6NTkK
L2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC80YmE5OTIwZTVlOWMwZTE2
YjVlZDI0MjkyZDQ1MzIyOTA3YmI5MDM1L2RtZXNnLXlvY3RvLWNhaXJvLTU2OjIwMTQwMjIx
MTMxMjQ4Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjMuMTMuMC0wODMzMC1nNGJh
OTkyMDo1OQova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0LzRiYTk5MjBl
NWU5YzBlMTZiNWVkMjQyOTJkNDUzMjI5MDdiYjkwMzUvZG1lc2cteW9jdG8tc25iLTEyOjIw
MTQwMjIxMTMxMjQ3Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjoKL2tlcm5lbC94
ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC80YmE5OTIwZTVlOWMwZTE2YjVlZDI0Mjky
ZDQ1MzIyOTA3YmI5MDM1L2RtZXNnLXF1YW50YWwteGlhbi02MzoyMDE0MDIyMTEzMTI1MDp4
ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDozLjEzLjAtMDgzMzAtZzRiYTk5MjA6NTkK
L2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC80YmE5OTIwZTVlOWMwZTE2
YjVlZDI0MjkyZDQ1MzIyOTA3YmI5MDM1L2RtZXNnLXlvY3RvLWNhaXJvLTE4OjIwMTQwMjIx
MTMxMjQ4Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjMuMTMuMC0wODMzMC1nNGJh
OTkyMDo1OQova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0LzRiYTk5MjBl
NWU5YzBlMTZiNWVkMjQyOTJkNDUzMjI5MDdiYjkwMzUvZG1lc2cteW9jdG8tY2Fpcm8tNjA6
MjAxNDAyMjExMzEyNDg6eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6My4xMy4wLTA4
MzMwLWc0YmE5OTIwOjU5Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQv
NGJhOTkyMGU1ZTljMGUxNmI1ZWQyNDI5MmQ0NTMyMjkwN2JiOTAzNS9kbWVzZy15b2N0by1z
bmItMTQ6MjAxNDAyMjExMzEyNDk6eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6Ogov
a2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0LzRiYTk5MjBlNWU5YzBlMTZi
NWVkMjQyOTJkNDUzMjI5MDdiYjkwMzUvZG1lc2cteW9jdG8tc25iLTE5OjIwMTQwMjIxMTMx
MjQ5Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjoKL2tlcm5lbC94ODZfNjQtcmFu
ZGNvbmZpZy1hMy0wMjIwMjA1NC80YmE5OTIwZTVlOWMwZTE2YjVlZDI0MjkyZDQ1MzIyOTA3
YmI5MDM1L2RtZXNnLXlvY3RvLXNuYi0yODoyMDE0MDIyMTEzMTI1MTp4ODZfNjQtcmFuZGNv
bmZpZy1hMy0wMjIwMjA1NDo6CjA6MTQ6MTUgYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMK
CkJpc2VjdGluZzogMjIyMyByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJv
dWdobHkgMTIgc3RlcHMpCltmNmQxM2RhYWRkZWI2ZTYzYjE1YTkzYmYzNmE4MDE3M2JhZmQy
OWJmXSBNZXJnZSBicmFuY2ggJ3NjaGVkLXVyZ2VudC1mb3ItbGludXMnIG9mIGdpdDovL2dp
dC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC90aXAvdGlwCnJ1bm5pbmcg
L2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAva2VybmVsLXRl
c3RzL2xpbnV4L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3Zt
L3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0L2xpbnV4LWRldmVsOmRldmVsLWhvdXJs
eS0yMDE0MDIyMDIxOmY2ZDEzZGFhZGRlYjZlNjNiMTVhOTNiZjM2YTgwMTczYmFmZDI5YmY6
YmlzZWN0LWxpbnV4CgoyMDE0LTAyLTIxLTEzOjEyOjU4IGY2ZDEzZGFhZGRlYjZlNjNiMTVh
OTNiZjM2YTgwMTczYmFmZDI5YmYgY29tcGlsaW5nCjIwMyByZWFsICAxNTczIHVzZXIgIDE0
MCBzeXMgIDg0My4yNCUgY3B1IAl4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NAoKMjAx
NC0wMi0yMS0xMzoxNjo0NiBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEzLjAtMDYxMTUtZ2Y2
ZDEzZGEuCTMJOAkxOQkyNAkyNi4uLi4uLi4uLi4uLi4uLi4uCTI3IFNVQ0NFU1MKCkJpc2Vj
dGluZzogMjIxNSByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkg
MTIgc3RlcHMpCls4MmM0Nzc2NjlhNDY2NWViNGU1MjAzMDc5MjA1MWUwNTU5ZWUyYTM2XSBN
ZXJnZSBicmFuY2ggJ3BlcmYtdXJnZW50LWZvci1saW51cycgb2YgZ2l0Oi8vZ2l0Lmtlcm5l
bC5vcmcvcHViL3NjbS9saW51eC9rZXJuZWwvZ2l0L3RpcC90aXAKcnVubmluZyAvYy9rZXJu
ZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9rZXJuZWwtdGVzdHMvbGlu
dXgvb2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0
LXJhbmRjb25maWctYTMtMDIyMDIwNTQvbGludXgtZGV2ZWw6ZGV2ZWwtaG91cmx5LTIwMTQw
MjIwMjE6ODJjNDc3NjY5YTQ2NjVlYjRlNTIwMzA3OTIwNTFlMDU1OWVlMmEzNjpiaXNlY3Qt
bGludXgKCjIwMTQtMDItMjEtMTM6Mjg6NDkgODJjNDc3NjY5YTQ2NjVlYjRlNTIwMzA3OTIw
NTFlMDU1OWVlMmEzNiBjb21waWxpbmcKMTkgcmVhbCAgMzggdXNlciAgNSBzeXMgIDIyMy4x
MSUgY3B1IAl4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NAoKMjAxNC0wMi0yMS0xMzoy
OToyMCBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEzLjAtMDYxMjgtZzgyYzQ3NzYuCTkJMjQu
CTI1CTI2Li4uLi4uLi4uLi4uLi4JMjcgU1VDQ0VTUwoKbGluZWFyLWJpc2VjdDogYmFkIGJy
YW5jaCBtYXkgYmUgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9saW51eC9rZXJuZWwv
Z2l0L2RhdmVtL25ldC1uZXh0CmxpbmVhci1iaXNlY3Q6IGhhbmRsZSBvdmVyIHRvIGdpdCBi
aXNlY3QKbGluZWFyLWJpc2VjdDogZ2l0IGJpc2VjdCBzdGFydCA0YmE5OTIwZTVlOWMwZTE2
YjVlZDI0MjkyZDQ1MzIyOTA3YmI5MDM1IDgyYzQ3NzY2OWE0NjY1ZWI0ZTUyMDMwNzkyMDUx
ZTA1NTllZTJhMzYgLS0KUHJldmlvdXMgSEVBRCBwb3NpdGlvbiB3YXMgODJjNDc3Ni4uLiBN
ZXJnZSBicmFuY2ggJ3BlcmYtdXJnZW50LWZvci1saW51cycgb2YgZ2l0Oi8vZ2l0Lmtlcm5l
bC5vcmcvcHViL3NjbS9saW51eC9rZXJuZWwvZ2l0L3RpcC90aXAKSEVBRCBpcyBub3cgYXQg
ZjcxMTk0YS4uLiBNZXJnZSBicmFuY2ggJ3g4Ni91cmdlbnQnIG9mIGdpdDovL2dpdC5rZXJu
ZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC90aXAvdGlwCkJpc2VjdGluZzogMTA5
NiByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMTAgc3RlcHMp
ClthZDg2YzU1YmFjNjQzYTc0NWY0ODBkMjY2ODlkMTUzZWMwZjM4YjA0XSBNZXJnZSBicmFu
Y2ggJ21hc3Rlcicgb2YgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9saW51eC9rZXJu
ZWwvZ2l0L2xpbnZpbGxlL3dpcmVsZXNzLW5leHQgaW50byBmb3ItZGF2ZW0KbGluZWFyLWJp
c2VjdDogZ2l0IGJpc2VjdCBydW4gL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3Qt
ZmFpbHVyZS5zaCAva2VybmVsLXRlc3RzL2xpbnV4L29iai1iaXNlY3QKcnVubmluZyAvYy9r
ZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9rZXJuZWwtdGVzdHMv
bGludXgvb2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2
XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvbGludXgtZGV2ZWw6ZGV2ZWwtaG91cmx5LTIw
MTQwMjIwMjE6YWQ4NmM1NWJhYzY0M2E3NDVmNDgwZDI2Njg5ZDE1M2VjMGYzOGIwNDpiaXNl
Y3QtbGludXgKCjIwMTQtMDItMjEtMTM6NDA6MDUgYWQ4NmM1NWJhYzY0M2E3NDVmNDgwZDI2
Njg5ZDE1M2VjMGYzOGIwNCBjb21waWxpbmcKMTQ5IHJlYWwgIDE1ODMgdXNlciAgMTQxIHN5
cyAgMTE1Ny41MCUgY3B1IAl4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NAoKMjAxNC0w
Mi0yMS0xMzo0MzowNiBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEzLjAtcmM0LTAxMjA0LWdh
ZDg2YzU1Li4JMTQJMjUJMjcgU1VDQ0VTUwoKQmlzZWN0aW5nOiA1NDcgcmV2aXNpb25zIGxl
ZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDkgc3RlcHMpCltiOTJlZDE2ODhlMzE2
ZDFiNDQxMDU1OTI3MmU2OGIyNDZiZGM3ZDBhXSBNZXJnZSBicmFuY2ggJ3FsY25pYycKcnVu
bmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9rZXJu
ZWwtdGVzdHMvbGludXgvb2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1
ZS9rdm0veDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvbGludXgtZGV2ZWw6ZGV2ZWwt
aG91cmx5LTIwMTQwMjIwMjE6YjkyZWQxNjg4ZTMxNmQxYjQ0MTA1NTkyNzJlNjhiMjQ2YmRj
N2QwYTpiaXNlY3QtbGludXgKCjIwMTQtMDItMjEtMTM6NDU6MzggYjkyZWQxNjg4ZTMxNmQx
YjQ0MTA1NTkyNzJlNjhiMjQ2YmRjN2QwYSBjb21waWxpbmcKOTQgcmVhbCAgMTU4NSB1c2Vy
ICAxNDAgc3lzICAxODE4Ljk4JSBjcHUgCXg4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0
CgoyMDE0LTAyLTIxLTEzOjQ3OjIxIGRldGVjdGluZyBib290IHN0YXRlIDMuMTMuMC1yYzYt
MDE3OTUtZ2I5MmVkMTYJMTYJMjUuCTI3IFNVQ0NFU1MKCkJpc2VjdGluZzogMzIyIHJldmlz
aW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA4IHN0ZXBzKQpbY2Y4NGVi
MGIwOWMwZjA5YjRjNzBhNjQ4YjlkZmVlYzc4YmU2MWYwN10gTWVyZ2UgYnJhbmNoICd2aXJ0
aW9fcnhfbWVyZ2luZycKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9v
dC1mYWlsdXJlLnNoIC9rZXJuZWwtdGVzdHMvbGludXgvb2JqLWJpc2VjdApscyAtYSAva2Vy
bmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQv
bGludXgtZGV2ZWw6ZGV2ZWwtaG91cmx5LTIwMTQwMjIwMjE6Y2Y4NGViMGIwOWMwZjA5YjRj
NzBhNjQ4YjlkZmVlYzc4YmU2MWYwNzpiaXNlY3QtbGludXgKCjIwMTQtMDItMjEtMTM6NDk6
MjIgY2Y4NGViMGIwOWMwZjA5YjRjNzBhNjQ4YjlkZmVlYzc4YmU2MWYwNyBjb21waWxpbmcK
NTEgcmVhbCAgNzMyIHVzZXIgIDY0IHN5cyAgMTUzMy43NiUgY3B1IAl4ODZfNjQtcmFuZGNv
bmZpZy1hMy0wMjIwMjA1NAoKMjAxNC0wMi0yMS0xMzo1MDoyNiBkZXRlY3RpbmcgYm9vdCBz
dGF0ZSAzLjEzLjAtcmM3LTAyMDA4LWdjZjg0ZWIwCTExCTI2Li4uCTI3IFNVQ0NFU1MKCkJp
c2VjdGluZzogMTYxIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hs
eSA3IHN0ZXBzKQpbMDVkMDYzYWE4NjdiN2EzMWI4NDU0MzQwMGIxOWY1NjczYWZjNzM2Y10g
aXhnYmV2ZjogbWFrZSB1c2Ugb2YgdGhlIGRldiBwb2ludGVyIGluIHRoZSBpeGdiZXZmX3Jp
bmcgc3RydWN0CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFp
bHVyZS5zaCAva2VybmVsLXRlc3RzL2xpbnV4L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10
ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0L2xpbnV4
LWRldmVsOmRldmVsLWhvdXJseS0yMDE0MDIyMDIxOjA1ZDA2M2FhODY3YjdhMzFiODQ1NDM0
MDBiMTlmNTY3M2FmYzczNmM6YmlzZWN0LWxpbnV4CgoyMDE0LTAyLTIxLTEzOjUzOjMxIDA1
ZDA2M2FhODY3YjdhMzFiODQ1NDM0MDBiMTlmNTY3M2FmYzczNmMgY29tcGlsaW5nCjE1OSBy
ZWFsICA1NTAgdXNlciAgNDkgc3lzICAzNzYuODklIGNwdSAJeDg2XzY0LXJhbmRjb25maWct
YTMtMDIyMDIwNTQKCjIwMTQtMDItMjEtMTM6NTc6MTMgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUg
My4xMy4wLXJjNy0wMjE2OS1nMDVkMDYzYS4uCTEgVEVTVCBGQUlMVVJFClsgICAgMy4xNjg3
MTNdIG1hYzgwMjExX2h3c2ltOiBpZWVlODAyMTFfcmVnaXN0ZXJfaHcgZmFpbGVkICgtMikK
WyAgICAzLjE3MDg3NV0gLS0tLS0tLS0tLS0tWyBjdXQgaGVyZSBdLS0tLS0tLS0tLS0tClsg
ICAgMy4xNzA4NzVdIC0tLS0tLS0tLS0tLVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0tLQpbICAg
IDMuMTcyMjYzXSBXQVJOSU5HOiBDUFU6IDAgUElEOiAxIGF0IC9rZXJuZWwtdGVzdHMvbGlu
dXgvaW5jbHVkZS9saW51eC9rcmVmLmg6NDcga29iamVjdF9nZXQrMHgzNy8weDQ0KCkKL2tl
cm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC8wNWQwNjNhYTg2N2I3YTMxYjg0
NTQzNDAwYjE5ZjU2NzNhZmM3MzZjL2RtZXNnLXF1YW50YWwteGlhbi01NjoyMDE0MDIyMTEz
NTgyOTp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDozLjEzLjAtcmM3LTAyMTY5LWcw
NWQwNjNhOjY1Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvMDVkMDYz
YWE4NjdiN2EzMWI4NDU0MzQwMGIxOWY1NjczYWZjNzM2Yy9kbWVzZy15b2N0by1hdGhlbnMt
NjE6MjAxNDAyMjExMzU4MzE6eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6My4xMy4w
LXJjNy0wMjE2OS1nMDVkMDYzYTo2NQova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAy
MjAyMDU0LzA1ZDA2M2FhODY3YjdhMzFiODQ1NDM0MDBiMTlmNTY3M2FmYzczNmMvZG1lc2ct
eW9jdG8tc25iLTM6MjAxNDAyMjExMzU4MzA6eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIw
NTQ6Ogova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0LzA1ZDA2M2FhODY3
YjdhMzFiODQ1NDM0MDBiMTlmNTY3M2FmYzczNmMvZG1lc2ctcXVhbnRhbC14aWFuLTE5OjIw
MTQwMjIxMTM1ODMzOng4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjMuMTMuMC1yYzct
MDIxNjktZzA1ZDA2M2E6NjUKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1
NC8wNWQwNjNhYTg2N2I3YTMxYjg0NTQzNDAwYjE5ZjU2NzNhZmM3MzZjL2RtZXNnLXF1YW50
YWwteGlhbi0yMToyMDE0MDIyMTEzNTgzMzp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1
NDozLjEzLjAtcmM3LTAyMTY5LWcwNWQwNjNhOjY1Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25m
aWctYTMtMDIyMDIwNTQvMDVkMDYzYWE4NjdiN2EzMWI4NDU0MzQwMGIxOWY1NjczYWZjNzM2
Yy9kbWVzZy1xdWFudGFsLXhpYW4tNjQ6MjAxNDAyMjExMzU4MzM6eDg2XzY0LXJhbmRjb25m
aWctYTMtMDIyMDIwNTQ6My4xMy4wLXJjNy0wMjE2OS1nMDVkMDYzYTo2NQova2VybmVsL3g4
Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0LzA1ZDA2M2FhODY3YjdhMzFiODQ1NDM0MDBi
MTlmNTY3M2FmYzczNmMvZG1lc2cteW9jdG8tYXRoZW5zLTc6MjAxNDAyMjExMzU4MzQ6eDg2
XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6My4xMy4wLXJjNy0wMjE2OS1nMDVkMDYzYTo2
NQowOjc6OCBhbGxfZ29vZDpiYWQ6YWxsX2JhZCBib290cwoKQmlzZWN0aW5nOiA4MCByZXZp
c2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgNiBzdGVwcykKWzA2NzNl
ZmZkNDFkYmEzMjNkNmEyODBlZjM3YjVlZjI5ZjNmNWE2NTNdIGI0MzogRml4IHVubG9hZCBv
b3BzIGlmIGZpcm13YXJlIGlzIG5vdCBhdmFpbGFibGUKcnVubmluZyAvYy9rZXJuZWwtdGVz
dHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9rZXJuZWwtdGVzdHMvbGludXgvb2Jq
LWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRj
b25maWctYTMtMDIyMDIwNTQvbGludXgtZGV2ZWw6ZGV2ZWwtaG91cmx5LTIwMTQwMjIwMjE6
MDY3M2VmZmQ0MWRiYTMyM2Q2YTI4MGVmMzdiNWVmMjlmM2Y1YTY1MzpiaXNlY3QtbGludXgK
CjIwMTQtMDItMjEtMTM6NTk6MDAgMDY3M2VmZmQ0MWRiYTMyM2Q2YTI4MGVmMzdiNWVmMjlm
M2Y1YTY1MyBjb21waWxpbmcKMTA5IHJlYWwgIDE1NTQgdXNlciAgMTM1IHN5cyAgMTU0Ni4x
MSUgY3B1IAl4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NAoKMjAxNC0wMi0yMS0xNDow
MjowNyBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEyLjAtMTE1NTYtZzA2NzNlZmYuCTQgVEVT
VCBGQUlMVVJFClsgICAgMy43NDQ4NjldIG1hYzgwMjExX2h3c2ltOiBpZWVlODAyMTFfcmVn
aXN0ZXJfaHcgZmFpbGVkICgtMikKWyAgICAzLjc0Njg1Nl0gLS0tLS0tLS0tLS0tWyBjdXQg
aGVyZSBdLS0tLS0tLS0tLS0tClsgICAgMy43NDY4NTZdIC0tLS0tLS0tLS0tLVsgY3V0IGhl
cmUgXS0tLS0tLS0tLS0tLQpbICAgIDMuNzQ4Mzg2XSBXQVJOSU5HOiBDUFU6IDEgUElEOiAx
IGF0IC9rZXJuZWwtdGVzdHMvbGludXgvaW5jbHVkZS9saW51eC9rcmVmLmg6NDcga29iamVj
dF9nZXQrMHgzNy8weDQ0KCkKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1
NC8wNjczZWZmZDQxZGJhMzIzZDZhMjgwZWYzN2I1ZWYyOWYzZjVhNjUzL2RtZXNnLXF1YW50
YWwtY2Fpcm8tMTE6MjAxNDAyMjExNDAyNTA6eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIw
NTQ6My4xMi4wLTExNTU2LWcwNjczZWZmOjY2Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWct
YTMtMDIyMDIwNTQvMDY3M2VmZmQ0MWRiYTMyM2Q2YTI4MGVmMzdiNWVmMjlmM2Y1YTY1My9k
bWVzZy1xdWFudGFsLWlubi0yOToyMDE0MDIyMTE0MDI0NDp4ODZfNjQtcmFuZGNvbmZpZy1h
My0wMjIwMjA1NDo6Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvMDY3
M2VmZmQ0MWRiYTMyM2Q2YTI4MGVmMzdiNWVmMjlmM2Y1YTY1My9kbWVzZy15b2N0by1pbm4t
OToyMDE0MDIyMTE0MDI0NDp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDo6Ci9rZXJu
ZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvMDY3M2VmZmQ0MWRiYTMyM2Q2YTI4
MGVmMzdiNWVmMjlmM2Y1YTY1My9kbWVzZy15b2N0by1zbmItMzE6MjAxNDAyMjExNDAyNDk6
eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6Ogova2VybmVsL3g4Nl82NC1yYW5kY29u
ZmlnLWEzLTAyMjAyMDU0LzA2NzNlZmZkNDFkYmEzMjNkNmEyODBlZjM3YjVlZjI5ZjNmNWE2
NTMvZG1lc2cteW9jdG8tY2Fpcm8tNTA6MjAxNDAyMjExNDAyNTE6eDg2XzY0LXJhbmRjb25m
aWctYTMtMDIyMDIwNTQ6My4xMi4wLTExNTU2LWcwNjczZWZmOjY2Ci9rZXJuZWwveDg2XzY0
LXJhbmRjb25maWctYTMtMDIyMDIwNTQvMDY3M2VmZmQ0MWRiYTMyM2Q2YTI4MGVmMzdiNWVm
MjlmM2Y1YTY1My9kbWVzZy15b2N0by14aWFuLTU2OjIwMTQwMjIxMTQwMjUzOng4Nl82NC1y
YW5kY29uZmlnLWEzLTAyMjAyMDU0OjMuMTIuMC0xMTU1Ni1nMDY3M2VmZjo2Ngova2VybmVs
L3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0LzA2NzNlZmZkNDFkYmEzMjNkNmEyODBl
ZjM3YjVlZjI5ZjNmNWE2NTMvZG1lc2cteW9jdG8tY2Fpcm8tMzg6MjAxNDAyMjExNDAyNTY6
eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6My4xMi4wLTExNTU2LWcwNjczZWZmOjY2
Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvMDY3M2VmZmQ0MWRiYTMy
M2Q2YTI4MGVmMzdiNWVmMjlmM2Y1YTY1My9kbWVzZy15b2N0by1jYWlyby00MToyMDE0MDIy
MTE0MDMwNTp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDozLjEyLjAtMTE1NTYtZzA2
NzNlZmY6NjYKMDo4OjExIGFsbF9nb29kOmJhZDphbGxfYmFkIGJvb3RzCgpCaXNlY3Rpbmc6
IDQzIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA1IHN0ZXBz
KQpbMjZiMGU0MTFkMzdhMmNhNTk5MmQwMjg4NGRjM2ZhNGUxOTA3ZTU5OF0gbWFjODAyMTFf
aHdzaW06IHJlc3RvcmUgcmVndWxhdG9yeSB0ZXN0aW5nIGZ1bmN0aW9uYWxpdHkKcnVubmlu
ZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9rZXJuZWwt
dGVzdHMvbGludXgvb2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9r
dm0veDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvbGludXgtZGV2ZWw6ZGV2ZWwtaG91
cmx5LTIwMTQwMjIwMjE6MjZiMGU0MTFkMzdhMmNhNTk5MmQwMjg4NGRjM2ZhNGUxOTA3ZTU5
ODpiaXNlY3QtbGludXgKCjIwMTQtMDItMjEtMTQ6MDM6MTEgMjZiMGU0MTFkMzdhMmNhNTk5
MmQwMjg4NGRjM2ZhNGUxOTA3ZTU5OCBjb21waWxpbmcKMzQgcmVhbCAgMzUxIHVzZXIgIDI5
IHN5cyAgMTA5Ny40MCUgY3B1IAl4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NAoKMjAx
NC0wMi0yMS0xNDowMzo1NSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEyLjAtMTEyNjctZzI2
YjBlNDEJMTYJMjAJMjEJMjIJMjUJMjcgU1VDQ0VTUwoKQmlzZWN0aW5nOiAyMiByZXZpc2lv
bnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgNSBzdGVwcykKW2VjNjY1ZmFj
ZGU4MjAxNzlkNzFkMGYwNjRlNjkyZjQ0OWRmMmI5NGZdIE1lcmdlIHRhZyAnbmZjLW5leHQt
My4xNC0xJyBvZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9n
aXQvc2FtZW8vbmZjLW5leHQKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3Qt
Ym9vdC1mYWlsdXJlLnNoIC9rZXJuZWwtdGVzdHMvbGludXgvb2JqLWJpc2VjdApscyAtYSAv
a2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIw
NTQvbGludXgtZGV2ZWw6ZGV2ZWwtaG91cmx5LTIwMTQwMjIwMjE6ZWM2NjVmYWNkZTgyMDE3
OWQ3MWQwZjA2NGU2OTJmNDQ5ZGYyYjk0ZjpiaXNlY3QtbGludXgKCjIwMTQtMDItMjEtMTQ6
MDc6MDIgZWM2NjVmYWNkZTgyMDE3OWQ3MWQwZjA2NGU2OTJmNDQ5ZGYyYjk0ZiBjb21waWxp
bmcKMzMgcmVhbCAgMzU1IHVzZXIgIDMxIHN5cyAgMTE1MS4wNyUgY3B1IAl4ODZfNjQtcmFu
ZGNvbmZpZy1hMy0wMjIwMjA1NAoKMjAxNC0wMi0yMS0xNDowODoxOSBkZXRlY3RpbmcgYm9v
dCBzdGF0ZSAzLjEyLjAtMTE0OTctZ2VjNjY1ZmEuCTI1CTI2CTI3IFNVQ0NFU1MKCkJpc2Vj
dGluZzogMTEgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDQg
c3RlcHMpCls4Njk1MjZiOTU4ZjU5NTkyYzQ2MDg2YzExZjYzODgyNGIwOGQxNjRhXSBhdGgx
MGs6IGFkZCB0cmFjZSBldmVudCBmb3IgV01JX0RFQlVHX01FU0dfRVZFTlRJRApydW5uaW5n
IC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2tlcm5lbC10
ZXN0cy9saW51eC9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2
bS94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC9saW51eC1kZXZlbDpkZXZlbC1ob3Vy
bHktMjAxNDAyMjAyMTo4Njk1MjZiOTU4ZjU5NTkyYzQ2MDg2YzExZjYzODgyNGIwOGQxNjRh
OmJpc2VjdC1saW51eAoKMjAxNC0wMi0yMS0xNDoxMDoyNiA4Njk1MjZiOTU4ZjU5NTkyYzQ2
MDg2YzExZjYzODgyNGIwOGQxNjRhIGNvbXBpbGluZwozOCByZWFsICAzNTQgdXNlciAgMzEg
c3lzICA5OTAuMzglIGNwdSAJeDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQKCjIwMTQt
MDItMjEtMTQ6MTE6NDIgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMi4wLTExMzI0LWc4Njk1
MjZiCTIwCTIzCTI1CTI2CTI3IFNVQ0NFU1MKCkJpc2VjdGluZzogNSByZXZpc2lvbnMgbGVm
dCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMyBzdGVwcykKWzRmN2I5MTQwNGNkNWRh
MzY1N2E4MmIwMDM5NGY0ZjVkZmJmZjEzZDZdIGNmZzgwMjExOiBtYWtlIHJlZ3VsYXRvcnlf
aGludCgpIHJlbW92ZSBSRUdVTEFUT1JZX0NVU1RPTV9SRUcKcnVubmluZyAvYy9rZXJuZWwt
dGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9rZXJuZWwtdGVzdHMvbGludXgv
b2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJh
bmRjb25maWctYTMtMDIyMDIwNTQvbGludXgtZGV2ZWw6ZGV2ZWwtaG91cmx5LTIwMTQwMjIw
MjE6NGY3YjkxNDA0Y2Q1ZGEzNjU3YTgyYjAwMzk0ZjRmNWRmYmZmMTNkNjpiaXNlY3QtbGlu
dXgKCjIwMTQtMDItMjEtMTQ6MTQ6MTkgNGY3YjkxNDA0Y2Q1ZGEzNjU3YTgyYjAwMzk0ZjRm
NWRmYmZmMTNkNiBjb21waWxpbmcKNDEgcmVhbCAgMzU3IHVzZXIgIDMxIHN5cyAgOTQzLjAw
JSBjcHUgCXg4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0CgoyMDE0LTAyLTIxLTE0OjE1
OjE2IGRldGVjdGluZyBib290IHN0YXRlIDMuMTIuMC0xMTU1MC1nNGY3YjkxNC4uLgkxMgkx
OQkyMQkyNC4uCTI2CTI3IFNVQ0NFU1MKCkJpc2VjdGluZzogMiByZXZpc2lvbnMgbGVmdCB0
byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMiBzdGVwcykKW2IzMGQ0OWIyOTRmZTMzOTcx
OTkxODk2NTU5NGYxMmViNzk2N2RjYTBdIHdsMTJ4eDogZml4IHR4IHBvd2VyIHNldHRpbmcK
cnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9r
ZXJuZWwtdGVzdHMvbGludXgvb2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1x
dWV1ZS9rdm0veDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvbGludXgtZGV2ZWw6ZGV2
ZWwtaG91cmx5LTIwMTQwMjIwMjE6YjMwZDQ5YjI5NGZlMzM5NzE5OTE4OTY1NTk0ZjEyZWI3
OTY3ZGNhMDpiaXNlY3QtbGludXgKCjIwMTQtMDItMjEtMTQ6MjA6NTEgYjMwZDQ5YjI5NGZl
MzM5NzE5OTE4OTY1NTk0ZjEyZWI3OTY3ZGNhMCBjb21waWxpbmcKMjAgcmVhbCAgMzkgdXNl
ciAgNSBzeXMgIDIyNS4xNiUgY3B1IAl4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NAoK
MjAxNC0wMi0yMS0xNDoyMTo0MiBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEyLjAtMTE1NTMt
Z2IzMGQ0OWIuLgkyIFRFU1QgRkFJTFVSRQpbICAgIDMuMDYwNTg2XSBtYWM4MDIxMV9od3Np
bTogaWVlZTgwMjExX3JlZ2lzdGVyX2h3IGZhaWxlZCAoLTIpClsgICAgMy4wNjIwNDJdIC0t
LS0tLS0tLS0tLVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0tLQpbICAgIDMuMDYyMDQyXSAtLS0t
LS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0KWyAgICAzLjA2MzA5Nl0gV0FSTklO
RzogQ1BVOiAxIFBJRDogMSBhdCAva2VybmVsLXRlc3RzL2xpbnV4L2luY2x1ZGUvbGludXgv
a3JlZi5oOjQ3IGtvYmplY3RfZ2V0KzB4MzcvMHg0NCgpCi9rZXJuZWwveDg2XzY0LXJhbmRj
b25maWctYTMtMDIyMDIwNTQvYjMwZDQ5YjI5NGZlMzM5NzE5OTE4OTY1NTk0ZjEyZWI3OTY3
ZGNhMC9kbWVzZy15b2N0by1pbm4tMzc6MjAxNDAyMjExNDIzMDM6eDg2XzY0LXJhbmRjb25m
aWctYTMtMDIyMDIwNTQ6Ogova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0
L2IzMGQ0OWIyOTRmZTMzOTcxOTkxODk2NTU5NGYxMmViNzk2N2RjYTAvZG1lc2cteW9jdG8t
aW5uLTMxOjIwMTQwMjIxMTQyMzA1Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjoK
L2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC9iMzBkNDliMjk0ZmUzMzk3
MTk5MTg5NjU1OTRmMTJlYjc5NjdkY2EwL2RtZXNnLXlvY3RvLWlubi0zODoyMDE0MDIyMTE0
MjMwNDp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDo6Ci9rZXJuZWwveDg2XzY0LXJh
bmRjb25maWctYTMtMDIyMDIwNTQvYjMwZDQ5YjI5NGZlMzM5NzE5OTE4OTY1NTk0ZjEyZWI3
OTY3ZGNhMC9kbWVzZy15b2N0by1zbmItMzM6MjAxNDAyMjExNDIzMDU6eDg2XzY0LXJhbmRj
b25maWctYTMtMDIyMDIwNTQ6Ogova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAy
MDU0L2IzMGQ0OWIyOTRmZTMzOTcxOTkxODk2NTU5NGYxMmViNzk2N2RjYTAvZG1lc2cteW9j
dG8tY2Fpcm8tODoyMDE0MDIyMTE0MjMwNjp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1
NDozLjEyLjAtMTE1NTMtZ2IzMGQ0OWI6NzEKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1h
My0wMjIwMjA1NC9iMzBkNDliMjk0ZmUzMzk3MTk5MTg5NjU1OTRmMTJlYjc5NjdkY2EwL2Rt
ZXNnLXlvY3RvLXNuYi0zOjIwMTQwMjIxMTQyMzA2Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAy
MjAyMDU0OjoKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC9iMzBkNDli
Mjk0ZmUzMzk3MTk5MTg5NjU1OTRmMTJlYjc5NjdkY2EwL2RtZXNnLXlvY3RvLXNuYi0xMjoy
MDE0MDIyMTE0MjMwNzp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDo6Ci9rZXJuZWwv
eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvYjMwZDQ5YjI5NGZlMzM5NzE5OTE4OTY1
NTk0ZjEyZWI3OTY3ZGNhMC9kbWVzZy1xdWFudGFsLWlubi0yNzoyMDE0MDIyMTE0MjMwODp4
ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDo6Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25m
aWctYTMtMDIyMDIwNTQvYjMwZDQ5YjI5NGZlMzM5NzE5OTE4OTY1NTk0ZjEyZWI3OTY3ZGNh
MC9kbWVzZy15b2N0by1hdGhlbnMtMToyMDE0MDIyMTE0MjMwNzp4ODZfNjQtcmFuZGNvbmZp
Zy1hMy0wMjIwMjA1NDozLjEyLjAtMTE1NTMtZ2IzMGQ0OWI6NzEKL2tlcm5lbC94ODZfNjQt
cmFuZGNvbmZpZy1hMy0wMjIwMjA1NC9iMzBkNDliMjk0ZmUzMzk3MTk5MTg5NjU1OTRmMTJl
Yjc5NjdkY2EwL2RtZXNnLXlvY3RvLWF0aGVucy0yOjIwMTQwMjIxMTQyMzA3Ong4Nl82NC1y
YW5kY29uZmlnLWEzLTAyMjAyMDU0OjMuMTIuMC0xMTU1My1nYjMwZDQ5Yjo3MQova2VybmVs
L3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0L2IzMGQ0OWIyOTRmZTMzOTcxOTkxODk2
NTU5NGYxMmViNzk2N2RjYTAvZG1lc2cteW9jdG8tYXRoZW5zLTQyOjIwMTQwMjIxMTQyMzA3
Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjMuMTIuMC0xMTU1My1nYjMwZDQ5Yjo3
MQova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0L2IzMGQ0OWIyOTRmZTMz
OTcxOTkxODk2NTU5NGYxMmViNzk2N2RjYTAvZG1lc2cteW9jdG8tc3RvYWtsZXktNzoyMDE0
MDIyMTE0MjMwNzp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDozLjEyLjAtMTE1NTMt
Z2IzMGQ0OWI6NzEKMDoxMjoxNCBhbGxfZ29vZDpiYWQ6YWxsX2JhZCBib290cwoKQmlzZWN0
aW5nOiAwIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAxIHN0
ZXApCls2ODQ1OGRlZGU3ZTAwNTUxOTgzMThkY2IwMzE4ZGYzYjRmNDE5NTA3XSBtd2lmaWV4
OiBhZGQgVVNCODg5NyBzdXBwb3J0CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10
ZXN0LWJvb3QtZmFpbHVyZS5zaCAva2VybmVsLXRlc3RzL2xpbnV4L29iai1iaXNlY3QKbHMg
LWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAy
MjAyMDU0L2xpbnV4LWRldmVsOmRldmVsLWhvdXJseS0yMDE0MDIyMDIxOjY4NDU4ZGVkZTdl
MDA1NTE5ODMxOGRjYjAzMThkZjNiNGY0MTk1MDc6YmlzZWN0LWxpbnV4CgoyMDE0LTAyLTIx
LTE0OjIzOjE1IDY4NDU4ZGVkZTdlMDA1NTE5ODMxOGRjYjAzMThkZjNiNGY0MTk1MDcgY29t
cGlsaW5nCjE2IHJlYWwgIDM1IHVzZXIgIDUgc3lzICAyNDguNTYlIGNwdSAJeDg2XzY0LXJh
bmRjb25maWctYTMtMDIyMDIwNTQKCjIwMTQtMDItMjEtMTQ6MjM6MzkgZGV0ZWN0aW5nIGJv
b3Qgc3RhdGUgMy4xMi4wLTExNTUyLWc2ODQ1OGRlLgk0IFRFU1QgRkFJTFVSRQpbICAgIDIu
OTcyNjg3XSBtYWM4MDIxMV9od3NpbTogaWVlZTgwMjExX3JlZ2lzdGVyX2h3IGZhaWxlZCAo
LTIpClsgICAgMi45NzQ2MzBdIC0tLS0tLS0tLS0tLVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0t
LQpbICAgIDIuOTc0NjMwXSAtLS0tLS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0K
WyAgICAyLjk3NjAzNl0gV0FSTklORzogQ1BVOiAxIFBJRDogMSBhdCAva2VybmVsLXRlc3Rz
L2xpbnV4L2luY2x1ZGUvbGludXgva3JlZi5oOjQ3IGtvYmplY3RfZ2V0KzB4MzcvMHg0NCgp
Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvNjg0NThkZWRlN2UwMDU1
MTk4MzE4ZGNiMDMxOGRmM2I0ZjQxOTUwNy9kbWVzZy1xdWFudGFsLWlubi0yMDoyMDE0MDIy
MTE0MjQxNzp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDo6Ci9rZXJuZWwveDg2XzY0
LXJhbmRjb25maWctYTMtMDIyMDIwNTQvNjg0NThkZWRlN2UwMDU1MTk4MzE4ZGNiMDMxOGRm
M2I0ZjQxOTUwNy9kbWVzZy1xdWFudGFsLXNuYi0yOToyMDE0MDIyMTE0MjQyMDp4ODZfNjQt
cmFuZGNvbmZpZy1hMy0wMjIwMjA1NDo6Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMt
MDIyMDIwNTQvNjg0NThkZWRlN2UwMDU1MTk4MzE4ZGNiMDMxOGRmM2I0ZjQxOTUwNy9kbWVz
Zy1xdWFudGFsLXNuYi04OjIwMTQwMjIxMTQyNDIwOng4Nl82NC1yYW5kY29uZmlnLWEzLTAy
MjAyMDU0OjoKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC82ODQ1OGRl
ZGU3ZTAwNTUxOTgzMThkY2IwMzE4ZGYzYjRmNDE5NTA3L2RtZXNnLXlvY3RvLWNhaXJvLTE1
OjIwMTQwMjIxMTQyNDIwOng4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjMuMTIuMC0x
MTU1Mi1nNjg0NThkZTo3Mgova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0
LzY4NDU4ZGVkZTdlMDA1NTE5ODMxOGRjYjAzMThkZjNiNGY0MTk1MDcvZG1lc2cteW9jdG8t
Y2Fpcm8tNTg6MjAxNDAyMjExNDI0MjA6eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6
My4xMi4wLTExNTUyLWc2ODQ1OGRlOjcyCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMt
MDIyMDIwNTQvNjg0NThkZWRlN2UwMDU1MTk4MzE4ZGNiMDMxOGRmM2I0ZjQxOTUwNy9kbWVz
Zy1xdWFudGFsLWF0aGVucy0yNToyMDE0MDIyMTE0MjQyMjp4ODZfNjQtcmFuZGNvbmZpZy1h
My0wMjIwMjA1NDozLjEyLjAtMTE1NTItZzY4NDU4ZGU6NzIKL2tlcm5lbC94ODZfNjQtcmFu
ZGNvbmZpZy1hMy0wMjIwMjA1NC82ODQ1OGRlZGU3ZTAwNTUxOTgzMThkY2IwMzE4ZGYzYjRm
NDE5NTA3L2RtZXNnLXF1YW50YWwtYXRoZW5zLTQ5OjIwMTQwMjIxMTQyNDIzOng4Nl82NC1y
YW5kY29uZmlnLWEzLTAyMjAyMDU0OjMuMTIuMC0xMTU1Mi1nNjg0NThkZTo3Mgova2VybmVs
L3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0LzY4NDU4ZGVkZTdlMDA1NTE5ODMxOGRj
YjAzMThkZjNiNGY0MTk1MDcvZG1lc2ctcXVhbnRhbC14cHMtNToyMDE0MDIyMTE0MjQyMzp4
ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDozLjEyLjAtMTE1NTItZzY4NDU4ZGU6NzIK
L2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC82ODQ1OGRlZGU3ZTAwNTUx
OTgzMThkY2IwMzE4ZGYzYjRmNDE5NTA3L2RtZXNnLXF1YW50YWwtY2Fpcm8tMjoyMDE0MDIy
MTE0MjQyOTp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDozLjEyLjAtMTE1NTItZzY4
NDU4ZGU6NzIKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC82ODQ1OGRl
ZGU3ZTAwNTUxOTgzMThkY2IwMzE4ZGYzYjRmNDE5NTA3L2RtZXNnLXF1YW50YWwtaW5uLTE4
OjIwMTQwMjIxMTQyNDI1Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjoKL2tlcm5l
bC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC82ODQ1OGRlZGU3ZTAwNTUxOTgzMThk
Y2IwMzE4ZGYzYjRmNDE5NTA3L2RtZXNnLXF1YW50YWwtamFrZXRvd24tMzI6MjAxNDAyMjEx
NDI0MjM6eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6Ogova2VybmVsL3g4Nl82NC1y
YW5kY29uZmlnLWEzLTAyMjAyMDU0LzY4NDU4ZGVkZTdlMDA1NTE5ODMxOGRjYjAzMThkZjNi
NGY0MTk1MDcvZG1lc2ctcXVhbnRhbC1zbmItMjoyMDE0MDIyMTE0MjQyNTp4ODZfNjQtcmFu
ZGNvbmZpZy1hMy0wMjIwMjA1NDo6Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIy
MDIwNTQvNjg0NThkZWRlN2UwMDU1MTk4MzE4ZGNiMDMxOGRmM2I0ZjQxOTUwNy9kbWVzZy1x
dWFudGFsLXNuYi01OjIwMTQwMjIxMTQyNDI0Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAy
MDU0OjoKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC82ODQ1OGRlZGU3
ZTAwNTUxOTgzMThkY2IwMzE4ZGYzYjRmNDE5NTA3L2RtZXNnLXF1YW50YWwteGd3by02OjIw
MTQwMjIxMTQyNDI5Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjMuMTIuMC0xMTU1
Mi1nNjg0NThkZTo3Mgova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0LzY4
NDU4ZGVkZTdlMDA1NTE5ODMxOGRjYjAzMThkZjNiNGY0MTk1MDcvZG1lc2cteW9jdG8tc25i
LTI1OjIwMTQwMjIxMTQyNDI1Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjoKL2tl
cm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC82ODQ1OGRlZGU3ZTAwNTUxOTgz
MThkY2IwMzE4ZGYzYjRmNDE5NTA3L2RtZXNnLXlvY3RvLXNuYi05OjIwMTQwMjIxMTQyNDI0
Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjoKL2tlcm5lbC94ODZfNjQtcmFuZGNv
bmZpZy1hMy0wMjIwMjA1NC82ODQ1OGRlZGU3ZTAwNTUxOTgzMThkY2IwMzE4ZGYzYjRmNDE5
NTA3L2RtZXNnLXlvY3RvLXhpYW4tNDQ6MjAxNDAyMjExNDI0MjU6eDg2XzY0LXJhbmRjb25m
aWctYTMtMDIyMDIwNTQ6My4xMi4wLTExNTUyLWc2ODQ1OGRlOjcyCjA6MTc6MjEgYWxsX2dv
b2Q6YmFkOmFsbF9iYWQgYm9vdHMKCkJpc2VjdGluZzogMCByZXZpc2lvbnMgbGVmdCB0byB0
ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMCBzdGVwcykKW2Y4N2Y5NjBiMmZiODAyZjI2ZWUz
YjAwYzE5MzIwZTU3YTljNTgzZmZdIHJ0bHdpZmk6IHJ0bDgxOTJjdTogQWRkIG5ldyBkZXZp
Y2UgSUQKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJl
LnNoIC9rZXJuZWwtdGVzdHMvbGludXgvb2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3Rz
L3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvbGludXgtZGV2
ZWw6ZGV2ZWwtaG91cmx5LTIwMTQwMjIwMjE6Zjg3Zjk2MGIyZmI4MDJmMjZlZTNiMDBjMTkz
MjBlNTdhOWM1ODNmZjpiaXNlY3QtbGludXgKCjIwMTQtMDItMjEtMTQ6MjQ6NDEgZjg3Zjk2
MGIyZmI4MDJmMjZlZTNiMDBjMTkzMjBlNTdhOWM1ODNmZiBjb21waWxpbmcKMjAgcmVhbCAg
MzggdXNlciAgNSBzeXMgIDIyMC45OCUgY3B1IAl4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIw
MjA1NAoKMjAxNC0wMi0yMS0xNDoyNToxMiBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEyLjAt
MTE1NTEtZ2Y4N2Y5NjAJMjMuCTI0CTI2Li4uLgkyNyBTVUNDRVNTCgo2ODQ1OGRlZGU3ZTAw
NTUxOTgzMThkY2IwMzE4ZGYzYjRmNDE5NTA3IGlzIHRoZSBmaXJzdCBiYWQgY29tbWl0CmNv
bW1pdCA2ODQ1OGRlZGU3ZTAwNTUxOTgzMThkY2IwMzE4ZGYzYjRmNDE5NTA3CkF1dGhvcjog
WW9nZXNoIEFzaG9rIFBvd2FyIDx5b2dlc2hwQG1hcnZlbGwuY29tPgpEYXRlOiAgIFRodSBK
YW4gOSAxOTozNjo1NSAyMDE0IC0wODAwCgogICAgbXdpZmlleDogYWRkIFVTQjg4OTcgc3Vw
cG9ydAogICAgCiAgICBBZGRpbmcgbmV3IGRldmljZSBJRHMgYW5kIGFzc2lnbmluZyBnZW5l
cmljIGZ1bmN0aW9uL3ZhcmlhYmxlCiAgICBuYW1lcyBpbnN0ZWFkIG9mIHVzaW5nIGRldmlj
ZS1pZCBzcGVjaWZpYyBuYW1lcy4KICAgIAogICAgU2lnbmVkLW9mZi1ieTogWW9nZXNoIEFz
aG9rIFBvd2FyIDx5b2dlc2hwQG1hcnZlbGwuY29tPgogICAgU2lnbmVkLW9mZi1ieTogTmlz
aGFudCBTYXJtdWthZGFtIDxuaXNoYW50c0BtYXJ2ZWxsLmNvbT4KICAgIFNpZ25lZC1vZmYt
Ynk6IEJpbmcgWmhhbyA8YnpoYW9AbWFydmVsbC5jb20+CiAgICBTaWduZWQtb2ZmLWJ5OiBG
cmFuayBIdWFuZyA8ZnJhbmtoQG1hcnZlbGwuY29tPgogICAgU2lnbmVkLW9mZi1ieTogSm9o
biBXLiBMaW52aWxsZSA8bGludmlsbGVAdHV4ZHJpdmVyLmNvbT4KCjowNDAwMDAgMDQwMDAw
IDU0ZDUxNzQyYTdmMzQzOTBkOWQzYjljMDRmZGIzMjQ4MmMyNDNjOWIgMDRlMTYzNDhmMmM5
N2NiMjE4MDZhMzYwODJkZGU4MGY3OTBkODMxYiBNCWRyaXZlcnMKYmlzZWN0IHJ1biBzdWNj
ZXNzChtbMTszNW0yMDE0LTAyLTIxIDE0OjI5OjQyIGNhbm5vdCBmaW5kIHRoZSBmaXJzdCBi
YWQgY29tbWl0G1swbQoKPT09PT09PT09IHVwc3RyZWFtID09PT09PT09PQpQcmV2aW91cyBI
RUFEIHBvc2l0aW9uIHdhcyBmODdmOTYwLi4uIHJ0bHdpZmk6IHJ0bDgxOTJjdTogQWRkIG5l
dyBkZXZpY2UgSUQKSEVBRCBpcyBub3cgYXQgZDE1OGZjNy4uLiBNZXJnZSB0YWcgJ3BjaS12
My4xNC1maXhlcy0xJyBvZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tl
cm5lbC9naXQvaGVsZ2Fhcy9wY2kKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3Zt
L3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0L2xpbnV4LWRldmVsOmRldmVsLWhvdXJs
eS0yMDE0MDIyMDIxOmQxNThmYzdmMzZhMjVlMTk3OTFkMjVhNTVkYTU2MjMzOTlhMjY0NGY6
YmlzZWN0LWxpbnV4CgoyMDE0LTAyLTIxLTE0OjI5OjQ3IGQxNThmYzdmMzZhMjVlMTk3OTFk
MjVhNTVkYTU2MjMzOTlhMjY0NGYgY29tcGlsaW5nCgoyMDE0LTAyLTIxLTE0OjM0OjA4IGRl
dGVjdGluZyBib290IHN0YXRlIDMuMTQuMC1yYzMtMDAyMTktZ2QxNThmYzcuLiBURVNUIEZB
SUxVUkUKWyAgICAzLjA1ODI1N10gU0M1MjAgQ0RQIGZsYXNoIGRldmljZTogMHg4MDAwMDAg
YXQgMHg4NDAwMDAwClsgICAgMy4wNTk4OTNdIC0tLS0tLS0tLS0tLVsgY3V0IGhlcmUgXS0t
LS0tLS0tLS0tLQpbICAgIDMuMDU5ODkzXSAtLS0tLS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0t
LS0tLS0tLS0KWyAgICAzLjA2MTM2M10gV0FSTklORzogQ1BVOiAxIFBJRDogMSBhdCAva2Vy
bmVsLXRlc3RzL2xpbnV4L2FyY2gveDg2L21tL2lvcmVtYXAuYzoxMDIgX19pb3JlbWFwX2Nh
bGxlcisweDEyNC8weDJmNigpCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIw
NTQvZDE1OGZjN2YzNmEyNWUxOTc5MWQyNWE1NWRhNTYyMzM5OWEyNjQ0Zi9kbWVzZy15b2N0
by1hdGhlbnMtMzQ6MjAxNDAyMjExNDM0NDc6eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIw
NTQ6My4xNC4wLXJjMy0wMDIxOS1nZDE1OGZjNzo3NAova2VybmVsL3g4Nl82NC1yYW5kY29u
ZmlnLWEzLTAyMjAyMDU0L2QxNThmYzdmMzZhMjVlMTk3OTFkMjVhNTVkYTU2MjMzOTlhMjY0
NGYvZG1lc2cteW9jdG8tYXRoZW5zLTM6MjAxNDAyMjExNDM0NDc6eDg2XzY0LXJhbmRjb25m
aWctYTMtMDIyMDIwNTQ6My4xNC4wLXJjMy0wMDIxOS1nZDE1OGZjNzo3NAova2VybmVsL3g4
Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0L2QxNThmYzdmMzZhMjVlMTk3OTFkMjVhNTVk
YTU2MjMzOTlhMjY0NGYvZG1lc2cteW9jdG8taW5uLTM6MjAxNDAyMjExNDM0NDQ6eDg2XzY0
LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6Ogova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEz
LTAyMjAyMDU0L2QxNThmYzdmMzZhMjVlMTk3OTFkMjVhNTVkYTU2MjMzOTlhMjY0NGYvZG1l
c2cteW9jdG8tc25iLTI5OjIwMTQwMjIxMTQzNDUwOng4Nl82NC1yYW5kY29uZmlnLWEzLTAy
MjAyMDU0OjoKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC9kMTU4ZmM3
ZjM2YTI1ZTE5NzkxZDI1YTU1ZGE1NjIzMzk5YTI2NDRmL2RtZXNnLXF1YW50YWwtaW5uLTIx
OjIwMTQwMjIxMTQzNDU3Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjoKL2tlcm5l
bC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC9kMTU4ZmM3ZjM2YTI1ZTE5NzkxZDI1
YTU1ZGE1NjIzMzk5YTI2NDRmL2RtZXNnLXF1YW50YWwtaW5uLTM3OjIwMTQwMjIxMTQzNDU4
Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjoKL2tlcm5lbC94ODZfNjQtcmFuZGNv
bmZpZy1hMy0wMjIwMjA1NC9kMTU4ZmM3ZjM2YTI1ZTE5NzkxZDI1YTU1ZGE1NjIzMzk5YTI2
NDRmL2RtZXNnLXF1YW50YWwtaW5uLTQ3OjIwMTQwMjIxMTQzNDU3Ong4Nl82NC1yYW5kY29u
ZmlnLWEzLTAyMjAyMDU0OjoKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1
NC9kMTU4ZmM3ZjM2YTI1ZTE5NzkxZDI1YTU1ZGE1NjIzMzk5YTI2NDRmL2RtZXNnLXF1YW50
YWwteGlhbi04OjIwMTQwMjIxMTQzNDU5Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0
OjMuMTQuMC1yYzMtMDAyMTktZ2QxNThmYzc6NzQKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZp
Zy1hMy0wMjIwMjA1NC9kMTU4ZmM3ZjM2YTI1ZTE5NzkxZDI1YTU1ZGE1NjIzMzk5YTI2NDRm
L2RtZXNnLXlvY3RvLWF0aGVucy0zMDoyMDE0MDIyMTE0MzQ1NDp4ODZfNjQtcmFuZGNvbmZp
Zy1hMy0wMjIwMjA1NDozLjE0LjAtcmMzLTAwMjE5LWdkMTU4ZmM3Ojc0Ci9rZXJuZWwveDg2
XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvZDE1OGZjN2YzNmEyNWUxOTc5MWQyNWE1NWRh
NTYyMzM5OWEyNjQ0Zi9kbWVzZy15b2N0by1hdGhlbnMtMzM6MjAxNDAyMjExNDM0NTc6eDg2
XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6My4xNC4wLXJjMy0wMDIxOS1nZDE1OGZjNzo3
NAova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0L2QxNThmYzdmMzZhMjVl
MTk3OTFkMjVhNTVkYTU2MjMzOTlhMjY0NGYvZG1lc2cteW9jdG8tY2Fpcm8tMjoyMDE0MDIy
MTE0MzQ1ODp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDozLjE0LjAtcmMzLTAwMjE5
LWdkMTU4ZmM3Ojc0Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvZDE1
OGZjN2YzNmEyNWUxOTc5MWQyNWE1NWRhNTYyMzM5OWEyNjQ0Zi9kbWVzZy15b2N0by1jYWly
by01MDoyMDE0MDIyMTE0MzQ1Njp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDozLjE0
LjAtcmMzLTAwMjE5LWdkMTU4ZmM3Ojc0Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMt
MDIyMDIwNTQvZDE1OGZjN2YzNmEyNWUxOTc5MWQyNWE1NWRhNTYyMzM5OWEyNjQ0Zi9kbWVz
Zy15b2N0by1jYWlyby01NDoyMDE0MDIyMTE0MzQ1NDp4ODZfNjQtcmFuZGNvbmZpZy1hMy0w
MjIwMjA1NDozLjE0LjAtcmMzLTAwMjE5LWdkMTU4ZmM3Ojc0Ci9rZXJuZWwveDg2XzY0LXJh
bmRjb25maWctYTMtMDIyMDIwNTQvZDE1OGZjN2YzNmEyNWUxOTc5MWQyNWE1NWRhNTYyMzM5
OWEyNjQ0Zi9kbWVzZy15b2N0by1jYWlyby01NToyMDE0MDIyMTE0MzQ1NDp4ODZfNjQtcmFu
ZGNvbmZpZy1hMy0wMjIwMjA1NDozLjE0LjAtcmMzLTAwMjE5LWdkMTU4ZmM3Ojc0Ci9rZXJu
ZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvZDE1OGZjN2YzNmEyNWUxOTc5MWQy
NWE1NWRhNTYyMzM5OWEyNjQ0Zi9kbWVzZy15b2N0by1jYWlyby02OjIwMTQwMjIxMTQzNDU1
Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjMuMTQuMC1yYzMtMDAyMTktZ2QxNThm
Yzc6NzQKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC9kMTU4ZmM3ZjM2
YTI1ZTE5NzkxZDI1YTU1ZGE1NjIzMzk5YTI2NDRmL2RtZXNnLXlvY3RvLWNhaXJvLTg6MjAx
NDAyMjExNDM0NTY6eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6My4xNC4wLXJjMy0w
MDIxOS1nZDE1OGZjNzo3NAova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0
L2QxNThmYzdmMzZhMjVlMTk3OTFkMjVhNTVkYTU2MjMzOTlhMjY0NGYvZG1lc2cteW9jdG8t
c25iLTE3OjIwMTQwMjIxMTQzNDU3Ong4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjoK
L2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC9kMTU4ZmM3ZjM2YTI1ZTE5
NzkxZDI1YTU1ZGE1NjIzMzk5YTI2NDRmL2RtZXNnLXlvY3RvLXNuYi00MToyMDE0MDIyMTE0
MzQ1Mzp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDo6Ci9rZXJuZWwveDg2XzY0LXJh
bmRjb25maWctYTMtMDIyMDIwNTQvZDE1OGZjN2YzNmEyNWUxOTc5MWQyNWE1NWRhNTYyMzM5
OWEyNjQ0Zi9kbWVzZy15b2N0by14aWFuLTEwOjIwMTQwMjIxMTQzNDU1Ong4Nl82NC1yYW5k
Y29uZmlnLWEzLTAyMjAyMDU0OjMuMTQuMC1yYzMtMDAyMTktZ2QxNThmYzc6NzQKL2tlcm5l
bC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NC9kMTU4ZmM3ZjM2YTI1ZTE5NzkxZDI1
YTU1ZGE1NjIzMzk5YTI2NDRmL2RtZXNnLXlvY3RvLXhpYW4tODoyMDE0MDIyMTE0MzQ1Njp4
ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDozLjE0LjAtcmMzLTAwMjE5LWdkMTU4ZmM3
Ojc0Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvZDE1OGZjN2YzNmEy
NWUxOTc5MWQyNWE1NWRhNTYyMzM5OWEyNjQ0Zi9kbWVzZy1xdWFudGFsLWJlbnMtNDoyMDE0
MDIyMTE0MzUwOTp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDozLjE0LjAtcmMzLTAw
MjE5LWdkMTU4ZmM3Ojc0CjA6MjE6OCBhbGxfZ29vZDpiYWQ6YWxsX2JhZCBib290cwoKCj09
PT09PT09PSBsaW51eC1uZXh0ID09PT09PT09PQpQcmV2aW91cyBIRUFEIHBvc2l0aW9uIHdh
cyBkMTU4ZmM3Li4uIE1lcmdlIHRhZyAncGNpLXYzLjE0LWZpeGVzLTEnIG9mIGdpdDovL2dp
dC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC9oZWxnYWFzL3BjaQpIRUFE
IGlzIG5vdyBhdCAxMmYxZDk0Li4uIEFkZCBsaW51eC1uZXh0IHNwZWNpZmljIGZpbGVzIGZv
ciAyMDE0MDIyMApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJh
bmRjb25maWctYTMtMDIyMDIwNTQvbGludXgtZGV2ZWw6ZGV2ZWwtaG91cmx5LTIwMTQwMjIw
MjE6MTJmMWQ5NGYwYzhiMjU2YzA0Y2I5YjZiNWRkOTg5YzMyZTQ0ZjExYjpiaXNlY3QtbGlu
dXgKIFRFU1QgRkFJTFVSRQpbICAgIDMuMzEzNTUwXSBtYWM4MDIxMV9od3NpbTogaWVlZTgw
MjExX3JlZ2lzdGVyX2h3IGZhaWxlZCAoLTIpClsgICAgMy4zMTUyOTNdIC0tLS0tLS0tLS0t
LVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0tLQpbICAgIDMuMzE1MjkzXSAtLS0tLS0tLS0tLS1b
IGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0KWyAgICAzLjMxNjYzM10gV0FSTklORzogQ1BVOiAx
IFBJRDogMSBhdCBpbmNsdWRlL2xpbnV4L2tyZWYuaDo0NyBrb2JqZWN0X2dldCsweDM3LzB4
NDQoKQova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0LzEyZjFkOTRmMGM4
YjI1NmMwNGNiOWI2YjVkZDk4OWMzMmU0NGYxMWIvZG1lc2ctcXVhbnRhbC1hdGhlbnMtMzoy
MDE0MDIyMDIxMjM1Nzp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDozLjE0LjAtcmMz
LW5leHQtMjAxNDAyMjAtMDQxODMtZzEyZjFkOTQ6MQova2VybmVsL3g4Nl82NC1yYW5kY29u
ZmlnLWEzLTAyMjAyMDU0LzEyZjFkOTRmMGM4YjI1NmMwNGNiOWI2YjVkZDk4OWMzMmU0NGYx
MWIvZG1lc2ctcXVhbnRhbC1yb2FtLTEwOjIwMTQwMjIwMjEyMzE3Ong4Nl82NC1yYW5kY29u
ZmlnLWEzLTAyMjAyMDU0OjMuMTQuMC1yYzMtbmV4dC0yMDE0MDIyMC0wNDE4My1nMTJmMWQ5
NDoxCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQvMTJmMWQ5NGYwYzhi
MjU2YzA0Y2I5YjZiNWRkOTg5YzMyZTQ0ZjExYi9kbWVzZy1xdWFudGFsLWNhaXJvLTQzOjIw
MTQwMjIwMjEyNDUxOng4Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0OjMuMTQuMC1yYzMt
bmV4dC0yMDE0MDIyMC0wNDE4My1nMTJmMWQ5NDoxCi9rZXJuZWwveDg2XzY0LXJhbmRjb25m
aWctYTMtMDIyMDIwNTQvMTJmMWQ5NGYwYzhiMjU2YzA0Y2I5YjZiNWRkOTg5YzMyZTQ0ZjEx
Yi9kbWVzZy15b2N0by1qYWtldG93bi0zMzoyMDE0MDIyMDIxMjQxOTp4ODZfNjQtcmFuZGNv
bmZpZy1hMy0wMjIwMjA1NDo6Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIw
NTQvMTJmMWQ5NGYwYzhiMjU2YzA0Y2I5YjZiNWRkOTg5YzMyZTQ0ZjExYi9kbWVzZy1xdWFu
dGFsLXhpYW4tOToyMDE0MDIyMDIxMjM1Njp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1
NDozLjE0LjAtcmMzLW5leHQtMjAxNDAyMjAtMDQxODMtZzEyZjFkOTQ6MQova2VybmVsL3g4
Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0LzEyZjFkOTRmMGM4YjI1NmMwNGNiOWI2YjVk
ZDk4OWMzMmU0NGYxMWIvZG1lc2ctcXVhbnRhbC1hdGhlbnMtMjY6MjAxNDAyMjAyMTI1MDM6
eDg2XzY0LXJhbmRjb25maWctYTMtMDIyMDIwNTQ6My4xNC4wLXJjMy1uZXh0LTIwMTQwMjIw
LTA0MTgzLWcxMmYxZDk0OjEKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1
NC8xMmYxZDk0ZjBjOGIyNTZjMDRjYjliNmI1ZGQ5ODljMzJlNDRmMTFiL2RtZXNnLXlvY3Rv
LWF0aGVucy01MzoyMDE0MDIyMDIxMjM1NTp4ODZfNjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1
NDozLjE0LjAtcmMzLW5leHQtMjAxNDAyMjAtMDQxODMtZzEyZjFkOTQ6MQova2VybmVsL3g4
Nl82NC1yYW5kY29uZmlnLWEzLTAyMjAyMDU0LzEyZjFkOTRmMGM4YjI1NmMwNGNiOWI2YjVk
ZDk4OWMzMmU0NGYxMWIvZG1lc2ctcXVhbnRhbC1pbm4tODoyMDE0MDIyMDIxMjM1NTp4ODZf
NjQtcmFuZGNvbmZpZy1hMy0wMjIwMjA1NDo6Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWct
YTMtMDIyMDIwNTQvMTJmMWQ5NGYwYzhiMjU2YzA0Y2I5YjZiNWRkOTg5YzMyZTQ0ZjExYi9k
bWVzZy1xdWFudGFsLXJvYW0tMzg6MjAxNDAyMjAyMTI0MDk6eDg2XzY0LXJhbmRjb25maWct
YTMtMDIyMDIwNTQ6My4xNC4wLXJjMy1uZXh0LTIwMTQwMjIwLTA0MTgzLWcxMmYxZDk0OjEK
MDo5OjkgYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKCg==

--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.14.0-rc3-02129-g63e12bf"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.14.0-rc3 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
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
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SYSVIPC is not set
CONFIG_POSIX_MQUEUE=y
CONFIG_FHANDLE=y
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
# CONFIG_NO_HZ_FULL is not set
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
# CONFIG_TICK_CPU_ACCOUNTING is not set
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
# CONFIG_TASK_XACCT is not set

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_STALL_COMMON=y
CONFIG_CONTEXT_TRACKING=y
CONFIG_RCU_USER_QS=y
CONFIG_CONTEXT_TRACKING_FORCE=y
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
CONFIG_TREE_RCU_TRACE=y
CONFIG_RCU_NOCB_CPU=y
CONFIG_RCU_NOCB_CPU_NONE=y
# CONFIG_RCU_NOCB_CPU_ZERO is not set
# CONFIG_RCU_NOCB_CPU_ALL is not set
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
# CONFIG_NUMA_BALANCING is not set
CONFIG_CGROUPS=y
CONFIG_CGROUP_DEBUG=y
CONFIG_CGROUP_FREEZER=y
# CONFIG_CGROUP_DEVICE is not set
CONFIG_CPUSETS=y
# CONFIG_PROC_PID_CPUSET is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_RESOURCE_COUNTERS is not set
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_SCHED=y
# CONFIG_FAIR_GROUP_SCHED is not set
# CONFIG_RT_GROUP_SCHED is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
# CONFIG_USER_NS is not set
CONFIG_PID_NS=y
CONFIG_NET_NS=y
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
# CONFIG_RD_LZ4 is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_EXPERT=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
# CONFIG_ELF_CORE is not set
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
# CONFIG_SIGNALFD is not set
# CONFIG_TIMERFD is not set
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_PCI_QUIRKS=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
# CONFIG_VM_EVENT_COUNTERS is not set
# CONFIG_COMPAT_BRK is not set
CONFIG_SLAB=y
# CONFIG_SLUB is not set
# CONFIG_SLOB is not set
CONFIG_PROFILING=y
CONFIG_OPROFILE=y
CONFIG_OPROFILE_EVENT_MULTIPLEX=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_JUMP_LABEL=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
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
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
# CONFIG_GCOV_PROFILE_ALL is not set
# CONFIG_GCOV_FORMAT_AUTODETECT is not set
CONFIG_GCOV_FORMAT_3_4=y
# CONFIG_GCOV_FORMAT_4_7 is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_SYSTEM_TRUSTED_KEYRING=y
# CONFIG_MODULES is not set
CONFIG_STOP_MACHINE=y
# CONFIG_BLOCK is not set
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_PARAVIRT_SPINLOCKS=y
CONFIG_XEN=y
CONFIG_XEN_DOM0=y
CONFIG_XEN_PRIVILEGED_GUEST=y
CONFIG_XEN_PVHVM=y
CONFIG_XEN_MAX_DOMAIN_MEMORY=500
CONFIG_XEN_SAVE_RESTORE=y
# CONFIG_XEN_DEBUG_FS is not set
# CONFIG_XEN_PVH is not set
CONFIG_KVM_GUEST=y
CONFIG_KVM_DEBUG_FS=y
CONFIG_PARAVIRT_TIME_ACCOUNTING=y
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
# CONFIG_DMI is not set
# CONFIG_GART_IOMMU is not set
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
# CONFIG_MAXSMP is not set
CONFIG_NR_CPUS=8
# CONFIG_SCHED_SMT is not set
# CONFIG_SCHED_MC is not set
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
# CONFIG_X86_MCE_INTEL is not set
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y
CONFIG_I8K=y
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_MICROCODE_INTEL_EARLY=y
# CONFIG_MICROCODE_AMD_EARLY is not set
CONFIG_MICROCODE_EARLY=y
CONFIG_X86_MSR=y
# CONFIG_X86_CPUID is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=6
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MOVABLE_NODE is not set
CONFIG_HAVE_BOOTMEM_INFO_NODE=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
# CONFIG_BALLOON_COMPACTION is not set
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=0
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_MEMORY_FAILURE is not set
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_CLEANCACHE=y
# CONFIG_CMA is not set
# CONFIG_ZBUD is not set
# CONFIG_ZSMALLOC is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
# CONFIG_X86_PAT is not set
# CONFIG_ARCH_RANDOM is not set
# CONFIG_X86_SMAP is not set
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_RANDOMIZE_BASE=y
CONFIG_RANDOMIZE_BASE_MAX_OFFSET=0x40000000
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
CONFIG_BOOTPARAM_HOTPLUG_CPU0=y
CONFIG_DEBUG_HOTPLUG_CPU0=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
CONFIG_PM_AUTOSLEEP=y
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
CONFIG_PM_WAKELOCKS_GC=y
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_PM_TRACE_RTC is not set
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ACPI=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
# CONFIG_ACPI_APEI is not set
# CONFIG_ACPI_EXTLOG is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
# CONFIG_CPU_FREQ_GOV_ONDEMAND is not set
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# x86 CPU frequency scaling drivers
#
# CONFIG_X86_INTEL_PSTATE is not set
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#
# CONFIG_X86_SPEEDSTEP_LIB is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_XEN=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_XEN_PCIDEV_FRONTEND=y
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
# CONFIG_ISA_DMA_API is not set
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
# CONFIG_IA32_EMULATION is not set
CONFIG_X86_DEV_DMA_OPS=y
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
CONFIG_XFRM_SUB_POLICY=y
# CONFIG_XFRM_MIGRATE is not set
CONFIG_NET_KEY=y
# CONFIG_NET_KEY_MIGRATE is not set
# CONFIG_INET is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
CONFIG_NETFILTER_DEBUG=y
CONFIG_NETFILTER_ADVANCED=y

#
# DECnet: Netfilter Configuration
#
CONFIG_DECNET_NF_GRABULATOR=y
CONFIG_ATM=y
# CONFIG_ATM_LANE is not set
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_NET_DSA=y
CONFIG_NET_DSA_TAG_EDSA=y
CONFIG_VLAN_8021Q=y
# CONFIG_VLAN_8021Q_GVRP is not set
# CONFIG_VLAN_8021Q_MVRP is not set
CONFIG_DECNET=y
CONFIG_DECNET_ROUTER=y
CONFIG_LLC=y
CONFIG_LLC2=y
CONFIG_IPX=y
CONFIG_IPX_INTERN=y
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=y
CONFIG_IPDDP=y
CONFIG_IPDDP_ENCAP=y
CONFIG_X25=y
CONFIG_LAPB=y
# CONFIG_PHONET is not set
CONFIG_IEEE802154=y
# CONFIG_MAC802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=y
CONFIG_BATMAN_ADV_NC=y
CONFIG_BATMAN_ADV_DEBUG=y
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_MMAP is not set
CONFIG_NETLINK_DIAG=y
CONFIG_NET_MPLS_GSO=y
CONFIG_HSR=y
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
CONFIG_IRDA=y

#
# IrDA protocols
#
CONFIG_IRLAN=y
CONFIG_IRNET=y
# CONFIG_IRCOMM is not set
CONFIG_IRDA_ULTRA=y

#
# IrDA options
#
CONFIG_IRDA_CACHE_LAST_LSAP=y
# CONFIG_IRDA_FAST_RR is not set
# CONFIG_IRDA_DEBUG is not set

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
# CONFIG_IRTTY_SIR is not set

#
# Dongle support
#
# CONFIG_KINGSUN_DONGLE is not set
CONFIG_KSDAZZLE_DONGLE=y
CONFIG_KS959_DONGLE=y

#
# FIR device drivers
#
# CONFIG_USB_IRDA is not set
CONFIG_SIGMATEL_FIR=y
# CONFIG_VLSI_FIR is not set
# CONFIG_MCS_FIR is not set
# CONFIG_BT is not set
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=y
CONFIG_NL80211_TESTMODE=y
CONFIG_CFG80211_DEVELOPER_WARNINGS=y
CONFIG_CFG80211_REG_DEBUG=y
CONFIG_CFG80211_CERTIFICATION_ONUS=y
# CONFIG_CFG80211_DEFAULT_PS is not set
# CONFIG_CFG80211_DEBUGFS is not set
# CONFIG_CFG80211_INTERNAL_REGDB is not set
CONFIG_CFG80211_WEXT=y
CONFIG_LIB80211=y
CONFIG_LIB80211_CRYPT_WEP=y
CONFIG_LIB80211_CRYPT_CCMP=y
CONFIG_LIB80211_CRYPT_TKIP=y
CONFIG_LIB80211_DEBUG=y
CONFIG_MAC80211=y
# CONFIG_MAC80211_RC_PID is not set
# CONFIG_MAC80211_RC_MINSTREL is not set
CONFIG_MAC80211_RC_DEFAULT=""

#
# Some wireless drivers require a rate control algorithm
#
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
CONFIG_MAC80211_DEBUGFS=y
CONFIG_MAC80211_MESSAGE_TRACING=y
CONFIG_MAC80211_DEBUG_MENU=y
# CONFIG_MAC80211_NOINLINE is not set
CONFIG_MAC80211_VERBOSE_DEBUG=y
CONFIG_MAC80211_MLME_DEBUG=y
CONFIG_MAC80211_STA_DEBUG=y
CONFIG_MAC80211_HT_DEBUG=y
CONFIG_MAC80211_IBSS_DEBUG=y
# CONFIG_MAC80211_PS_DEBUG is not set
# CONFIG_MAC80211_MPL_DEBUG is not set
CONFIG_MAC80211_MPATH_DEBUG=y
# CONFIG_MAC80211_MHWMP_DEBUG is not set
# CONFIG_MAC80211_MESH_SYNC_DEBUG is not set
# CONFIG_MAC80211_MESH_CSA_DEBUG is not set
# CONFIG_MAC80211_MESH_PS_DEBUG is not set
# CONFIG_MAC80211_TDLS_DEBUG is not set
# CONFIG_MAC80211_DEBUG_COUNTERS is not set
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
# CONFIG_RFKILL is not set
CONFIG_RFKILL_REGULATOR=y
# CONFIG_NET_9P is not set
CONFIG_CAIF=y
# CONFIG_CAIF_DEBUG is not set
CONFIG_CAIF_NETDEV=y
CONFIG_CAIF_USB=y
CONFIG_NFC=y
CONFIG_NFC_DIGITAL=y
# CONFIG_NFC_NCI is not set
# CONFIG_NFC_HCI is not set

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_PN533=y
# CONFIG_NFC_SIM is not set
CONFIG_NFC_PORT100=y
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
CONFIG_SYS_HYPERVISOR=y
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=y
# CONFIG_MTD_REDBOOT_PARTS is not set
CONFIG_MTD_CMDLINE_PARTS=y
# CONFIG_MTD_AR7_PARTS is not set

#
# User Modules And Translation Layers
#
# CONFIG_MTD_OOPS is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
CONFIG_MTD_CFI_ADV_OPTIONS=y
# CONFIG_MTD_CFI_NOSWAP is not set
# CONFIG_MTD_CFI_BE_BYTE_SWAP is not set
CONFIG_MTD_CFI_LE_BYTE_SWAP=y
CONFIG_MTD_CFI_GEOMETRY=y
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
CONFIG_MTD_MAP_BANK_WIDTH_32=y
# CONFIG_MTD_CFI_I1 is not set
# CONFIG_MTD_CFI_I2 is not set
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
# CONFIG_MTD_OTP is not set
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
# CONFIG_MTD_CFI_STAA is not set
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
# CONFIG_MTD_ROM is not set
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
CONFIG_MTD_PHYSMAP=y
CONFIG_MTD_PHYSMAP_COMPAT=y
CONFIG_MTD_PHYSMAP_START=0x8000000
CONFIG_MTD_PHYSMAP_LEN=0
CONFIG_MTD_PHYSMAP_BANKWIDTH=2
CONFIG_MTD_SC520CDP=y
# CONFIG_MTD_NETSC520 is not set
CONFIG_MTD_TS5500=y
CONFIG_MTD_SBC_GXX=y
# CONFIG_MTD_AMD76XROM is not set
# CONFIG_MTD_ICHXROM is not set
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
# CONFIG_MTD_PCI is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=y
CONFIG_MTD_LATCH_ADDR=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
# CONFIG_MTD_MTDRAM is not set

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
# CONFIG_MTD_NAND is not set
# CONFIG_MTD_ONENAND is not set

#
# LPDDR flash memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
CONFIG_MTD_UBI_GLUEBI=y
# CONFIG_PARPORT is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
# CONFIG_AD525X_DPOT_I2C is not set
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=y
CONFIG_ATMEL_SSC=y
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1780 is not set
CONFIG_SENSORS_BH1770=y
# CONFIG_SENSORS_APDS990X is not set
CONFIG_HMC6352=y
# CONFIG_DS1682 is not set
CONFIG_VMWARE_BALLOON=y
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
# CONFIG_PCH_PHUB is not set
CONFIG_USB_SWITCH_FSA9480=y
# CONFIG_SRAM is not set
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Host Driver
#
# CONFIG_INTEL_MIC_HOST is not set

#
# Intel MIC Card Driver
#
# CONFIG_INTEL_MIC_CARD is not set
# CONFIG_GENWQE is not set
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_SCSI_DMA is not set
# CONFIG_SCSI_NETLINK is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_NETDEVICES=y
CONFIG_MII=y
# CONFIG_NET_CORE is not set
# CONFIG_ARCNET is not set
# CONFIG_ATM_DRIVERS is not set

#
# CAIF transport drivers
#
# CONFIG_CAIF_TTY is not set
CONFIG_CAIF_SPI_SLAVE=y
CONFIG_CAIF_SPI_SYNC=y
CONFIG_CAIF_HSI=y
CONFIG_CAIF_VIRTIO=y
CONFIG_VHOST_NET=y
CONFIG_VHOST_RING=y
CONFIG_VHOST=y

#
# Distributed Switch Architecture drivers
#
CONFIG_NET_DSA_MV88E6XXX=y
# CONFIG_NET_DSA_MV88E6060 is not set
# CONFIG_NET_DSA_MV88E6XXX_NEED_PPU is not set
# CONFIG_NET_DSA_MV88E6131 is not set
CONFIG_NET_DSA_MV88E6123_61_65=y
# CONFIG_ETHERNET is not set
# CONFIG_FDDI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
CONFIG_AT803X_PHY=y
CONFIG_AMD_PHY=y
CONFIG_MARVELL_PHY=y
CONFIG_DAVICOM_PHY=y
# CONFIG_QSEMI_PHY is not set
# CONFIG_LXT_PHY is not set
# CONFIG_CICADA_PHY is not set
CONFIG_VITESSE_PHY=y
# CONFIG_SMSC_PHY is not set
CONFIG_BROADCOM_PHY=y
# CONFIG_BCM7XXX_PHY is not set
CONFIG_BCM87XX_PHY=y
# CONFIG_ICPLUS_PHY is not set
# CONFIG_REALTEK_PHY is not set
# CONFIG_NATIONAL_PHY is not set
CONFIG_STE10XP=y
CONFIG_LSI_ET1011C_PHY=y
CONFIG_MICREL_PHY=y
# CONFIG_FIXED_PHY is not set
# CONFIG_MDIO_BITBANG is not set
CONFIG_PPP=y
CONFIG_PPP_BSDCOMP=y
# CONFIG_PPP_DEFLATE is not set
# CONFIG_PPP_FILTER is not set
CONFIG_PPP_MPPE=y
# CONFIG_PPP_MULTILINK is not set
CONFIG_PPPOATM=y
CONFIG_PPPOE=y
# CONFIG_PPP_ASYNC is not set
# CONFIG_PPP_SYNC_TTY is not set
# CONFIG_SLIP is not set
CONFIG_SLHC=y

#
# USB Network Adapters
#
# CONFIG_USB_CATC is not set
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
CONFIG_USB_RTL8150=y
# CONFIG_USB_RTL8152 is not set
CONFIG_USB_USBNET=y
CONFIG_USB_NET_AX8817X=y
# CONFIG_USB_NET_AX88179_178A is not set
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_CDC_NCM=y
# CONFIG_USB_NET_HUAWEI_CDC_NCM is not set
# CONFIG_USB_NET_CDC_MBIM is not set
CONFIG_USB_NET_DM9601=y
# CONFIG_USB_NET_SR9700 is not set
CONFIG_USB_NET_SR9800=y
CONFIG_USB_NET_SMSC75XX=y
# CONFIG_USB_NET_SMSC95XX is not set
CONFIG_USB_NET_GL620A=y
CONFIG_USB_NET_NET1080=y
# CONFIG_USB_NET_PLUSB is not set
CONFIG_USB_NET_MCS7830=y
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET=y
# CONFIG_USB_ALI_M5632 is not set
# CONFIG_USB_AN2720 is not set
CONFIG_USB_BELKIN=y
# CONFIG_USB_ARMLINUX is not set
# CONFIG_USB_EPSON2888 is not set
# CONFIG_USB_KC2190 is not set
# CONFIG_USB_NET_ZAURUS is not set
CONFIG_USB_NET_CX82310_ETH=y
# CONFIG_USB_NET_KALMIA is not set
# CONFIG_USB_NET_QMI_WWAN is not set
# CONFIG_USB_NET_INT51X1 is not set
# CONFIG_USB_IPHETH is not set
CONFIG_USB_SIERRA_NET=y
# CONFIG_USB_VL600 is not set
CONFIG_WLAN=y
# CONFIG_LIBERTAS_THINFIRM is not set
# CONFIG_ATMEL is not set
CONFIG_AT76C50X_USB=y
# CONFIG_PRISM54 is not set
CONFIG_USB_ZD1201=y
CONFIG_USB_NET_RNDIS_WLAN=y
# CONFIG_RTL8180 is not set
CONFIG_RTL8187=y
CONFIG_RTL8187_LEDS=y
# CONFIG_ADM8211 is not set
CONFIG_MAC80211_HWSIM=y
# CONFIG_MWL8K is not set
CONFIG_ATH_COMMON=y
CONFIG_ATH_CARDS=y
# CONFIG_ATH_DEBUG is not set
CONFIG_ATH_REG_DYNAMIC_USER_REG_HINTS=y
# CONFIG_ATH_REG_DYNAMIC_USER_CERT_TESTING is not set
# CONFIG_ATH5K is not set
# CONFIG_ATH5K_PCI is not set
CONFIG_ATH9K_HW=y
CONFIG_ATH9K_COMMON=y
# CONFIG_ATH9K_BTCOEX_SUPPORT is not set
CONFIG_ATH9K=y
CONFIG_ATH9K_PCI=y
CONFIG_ATH9K_AHB=y
# CONFIG_ATH9K_DEBUGFS is not set
CONFIG_ATH9K_DFS_CERTIFIED=y
# CONFIG_ATH9K_WOW is not set
# CONFIG_ATH9K_HTC is not set
# CONFIG_CARL9170 is not set
CONFIG_ATH6KL=y
# CONFIG_ATH6KL_SDIO is not set
CONFIG_ATH6KL_USB=y
# CONFIG_ATH6KL_DEBUG is not set
CONFIG_ATH6KL_REGDOMAIN=y
# CONFIG_AR5523 is not set
# CONFIG_WIL6210 is not set
# CONFIG_ATH10K is not set
# CONFIG_WCN36XX is not set
# CONFIG_B43 is not set
CONFIG_B43LEGACY=y
CONFIG_B43LEGACY_PCI_AUTOSELECT=y
CONFIG_B43LEGACY_PCICORE_AUTOSELECT=y
CONFIG_B43LEGACY_LEDS=y
CONFIG_B43LEGACY_DEBUG=y
CONFIG_B43LEGACY_DMA=y
CONFIG_B43LEGACY_PIO=y
CONFIG_B43LEGACY_DMA_AND_PIO_MODE=y
# CONFIG_B43LEGACY_DMA_MODE is not set
# CONFIG_B43LEGACY_PIO_MODE is not set
CONFIG_BRCMUTIL=y
# CONFIG_BRCMSMAC is not set
CONFIG_BRCMFMAC=y
# CONFIG_BRCMFMAC_SDIO is not set
# CONFIG_BRCMFMAC_USB is not set
CONFIG_BRCM_TRACING=y
# CONFIG_BRCMDBG is not set
CONFIG_HOSTAP=y
CONFIG_HOSTAP_FIRMWARE=y
CONFIG_HOSTAP_FIRMWARE_NVRAM=y
# CONFIG_HOSTAP_PLX is not set
# CONFIG_HOSTAP_PCI is not set
# CONFIG_IPW2100 is not set
# CONFIG_IPW2200 is not set
# CONFIG_IWLWIFI is not set
# CONFIG_IWL4965 is not set
# CONFIG_IWL3945 is not set
CONFIG_LIBERTAS=y
CONFIG_LIBERTAS_USB=y
CONFIG_LIBERTAS_SDIO=y
CONFIG_LIBERTAS_DEBUG=y
# CONFIG_LIBERTAS_MESH is not set
# CONFIG_HERMES is not set
# CONFIG_P54_COMMON is not set
CONFIG_RT2X00=y
# CONFIG_RT2400PCI is not set
# CONFIG_RT2500PCI is not set
# CONFIG_RT61PCI is not set
# CONFIG_RT2800PCI is not set
# CONFIG_RT2500USB is not set
# CONFIG_RT73USB is not set
# CONFIG_RT2800USB is not set
# CONFIG_RTL_CARDS is not set
# CONFIG_WL_TI is not set
CONFIG_ZD1211RW=y
CONFIG_ZD1211RW_DEBUG=y
CONFIG_MWIFIEX=y
# CONFIG_MWIFIEX_SDIO is not set
# CONFIG_MWIFIEX_PCIE is not set
CONFIG_MWIFIEX_USB=y
CONFIG_CW1200=y
CONFIG_CW1200_WLAN_SDIO=y

#
# WiMAX Wireless Broadband devices
#
CONFIG_WIMAX_I2400M=y
CONFIG_WIMAX_I2400M_USB=y
CONFIG_WIMAX_I2400M_DEBUG_LEVEL=8
# CONFIG_WAN is not set
CONFIG_IEEE802154_DRIVERS=y
CONFIG_IEEE802154_FAKEHARD=y
CONFIG_XEN_NETDEV_FRONTEND=y
# CONFIG_XEN_NETDEV_BACKEND is not set
CONFIG_ISDN=y
# CONFIG_ISDN_I4L is not set
CONFIG_ISDN_CAPI=y
# CONFIG_ISDN_DRV_AVMB1_VERBOSE_REASON is not set
CONFIG_CAPI_TRACE=y
# CONFIG_ISDN_CAPI_MIDDLEWARE is not set
CONFIG_ISDN_CAPI_CAPI20=y

#
# CAPI hardware drivers
#
CONFIG_CAPI_AVM=y
# CONFIG_ISDN_DRV_AVMB1_B1PCI is not set
# CONFIG_ISDN_DRV_AVMB1_T1PCI is not set
# CONFIG_ISDN_DRV_AVMB1_C4 is not set
# CONFIG_CAPI_EICON is not set
# CONFIG_ISDN_DRV_GIGASET is not set
CONFIG_MISDN=y
CONFIG_MISDN_DSP=y
CONFIG_MISDN_L1OIP=y

#
# mISDN hardware drivers
#
# CONFIG_MISDN_HFCPCI is not set
# CONFIG_MISDN_HFCMULTI is not set
CONFIG_MISDN_HFCUSB=y
# CONFIG_MISDN_AVMFRITZ is not set
# CONFIG_MISDN_SPEEDFAX is not set
# CONFIG_MISDN_INFINEON is not set
# CONFIG_MISDN_W6692 is not set
# CONFIG_MISDN_NETJET is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
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
# CONFIG_MOUSE_PS2 is not set
CONFIG_MOUSE_SERIAL=y
CONFIG_MOUSE_APPLETOUCH=y
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
CONFIG_MOUSE_VSXXXAA=y
CONFIG_MOUSE_SYNAPTICS_I2C=y
CONFIG_MOUSE_SYNAPTICS_USB=y
# CONFIG_INPUT_JOYSTICK is not set
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=y
CONFIG_TABLET_USB_AIPTEK=y
CONFIG_TABLET_USB_GTCO=y
CONFIG_TABLET_USB_HANWANG=y
# CONFIG_TABLET_USB_KBTAB is not set
# CONFIG_TABLET_USB_WACOM is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_AD7879=y
CONFIG_TOUCHSCREEN_AD7879_I2C=y
CONFIG_TOUCHSCREEN_ATMEL_MXT=y
CONFIG_TOUCHSCREEN_BU21013=y
CONFIG_TOUCHSCREEN_CYTTSP_CORE=y
CONFIG_TOUCHSCREEN_CYTTSP_I2C=y
# CONFIG_TOUCHSCREEN_CYTTSP4_CORE is not set
CONFIG_TOUCHSCREEN_DA9052=y
CONFIG_TOUCHSCREEN_DYNAPRO=y
# CONFIG_TOUCHSCREEN_HAMPSHIRE is not set
CONFIG_TOUCHSCREEN_EETI=y
CONFIG_TOUCHSCREEN_FUJITSU=y
# CONFIG_TOUCHSCREEN_ILI210X is not set
# CONFIG_TOUCHSCREEN_GUNZE is not set
# CONFIG_TOUCHSCREEN_ELO is not set
CONFIG_TOUCHSCREEN_WACOM_W8001=y
CONFIG_TOUCHSCREEN_WACOM_I2C=y
# CONFIG_TOUCHSCREEN_MAX11801 is not set
CONFIG_TOUCHSCREEN_MCS5000=y
# CONFIG_TOUCHSCREEN_MMS114 is not set
CONFIG_TOUCHSCREEN_MTOUCH=y
CONFIG_TOUCHSCREEN_INEXIO=y
# CONFIG_TOUCHSCREEN_MK712 is not set
CONFIG_TOUCHSCREEN_PENMOUNT=y
CONFIG_TOUCHSCREEN_EDT_FT5X06=y
CONFIG_TOUCHSCREEN_TOUCHRIGHT=y
# CONFIG_TOUCHSCREEN_TOUCHWIN is not set
CONFIG_TOUCHSCREEN_TI_AM335X_TSC=y
# CONFIG_TOUCHSCREEN_PIXCIR is not set
# CONFIG_TOUCHSCREEN_WM831X is not set
CONFIG_TOUCHSCREEN_USB_COMPOSITE=y
CONFIG_TOUCHSCREEN_MC13783=y
CONFIG_TOUCHSCREEN_USB_EGALAX=y
# CONFIG_TOUCHSCREEN_USB_PANJIT is not set
CONFIG_TOUCHSCREEN_USB_3M=y
# CONFIG_TOUCHSCREEN_USB_ITM is not set
# CONFIG_TOUCHSCREEN_USB_ETURBO is not set
CONFIG_TOUCHSCREEN_USB_GUNZE=y
CONFIG_TOUCHSCREEN_USB_DMC_TSC10=y
CONFIG_TOUCHSCREEN_USB_IRTOUCH=y
CONFIG_TOUCHSCREEN_USB_IDEALTEK=y
# CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH is not set
CONFIG_TOUCHSCREEN_USB_GOTOP=y
# CONFIG_TOUCHSCREEN_USB_JASTEC is not set
CONFIG_TOUCHSCREEN_USB_ELO=y
# CONFIG_TOUCHSCREEN_USB_E2I is not set
# CONFIG_TOUCHSCREEN_USB_ZYTRONIC is not set
# CONFIG_TOUCHSCREEN_USB_ETT_TC45USB is not set
# CONFIG_TOUCHSCREEN_USB_NEXIO is not set
CONFIG_TOUCHSCREEN_USB_EASYTOUCH=y
CONFIG_TOUCHSCREEN_TOUCHIT213=y
CONFIG_TOUCHSCREEN_TSC_SERIO=y
# CONFIG_TOUCHSCREEN_TSC2007 is not set
CONFIG_TOUCHSCREEN_ST1232=y
CONFIG_TOUCHSCREEN_STMPE=y
CONFIG_TOUCHSCREEN_SUR40=y
CONFIG_TOUCHSCREEN_TPS6507X=y
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
CONFIG_SERIO_ARC_PS2=y
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
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_HVC_DRIVER=y
CONFIG_HVC_IRQ=y
CONFIG_HVC_XEN=y
CONFIG_HVC_XEN_FRONTEND=y
# CONFIG_VIRTIO_CONSOLE is not set
CONFIG_IPMI_HANDLER=y
# CONFIG_IPMI_PANIC_EVENT is not set
# CONFIG_IPMI_DEVICE_INTERFACE is not set
CONFIG_IPMI_SI=y
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
# CONFIG_HW_RANDOM is not set
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_TIS_I2C_ATMEL is not set
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_TIS_I2C_NUVOTON=y
# CONFIG_TCG_NSC is not set
CONFIG_TCG_ATMEL=y
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_XEN is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_PCA9541=y
CONFIG_I2C_MUX_PCA954x=y
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
# CONFIG_I2C_KEMPLD is not set
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
# CONFIG_I2C_SIMTEC is not set
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=y

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
# CONFIG_HSI is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PTP_1588_CLOCK_PCH=y
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2490=y
# CONFIG_W1_MASTER_DS2482 is not set
CONFIG_W1_MASTER_DS1WM=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2408=y
CONFIG_W1_SLAVE_DS2408_READBACK=y
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2423=y
# CONFIG_W1_SLAVE_DS2431 is not set
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
CONFIG_GENERIC_ADC_BATTERY=y
CONFIG_MAX8925_POWER=y
# CONFIG_WM831X_BACKUP is not set
# CONFIG_WM831X_POWER is not set
# CONFIG_WM8350_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2760 is not set
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
# CONFIG_BATTERY_BQ27x00 is not set
CONFIG_BATTERY_DA9052=y
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_CHARGER_PCF50633=y
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
CONFIG_CHARGER_TWL4030=y
CONFIG_CHARGER_LP8727=y
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_BQ2415X=y
# CONFIG_CHARGER_SMB347 is not set
CONFIG_CHARGER_TPS65090=y
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_AD7414=y
# CONFIG_SENSORS_AD7418 is not set
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
# CONFIG_SENSORS_ADM1031 is not set
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7410=y
# CONFIG_SENSORS_ADT7411 is not set
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
# CONFIG_SENSORS_DA9052_ADC is not set
CONFIG_SENSORS_DA9055=y
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
CONFIG_SENSORS_F75375S=y
# CONFIG_SENSORS_MC13783_ADC is not set
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
# CONFIG_SENSORS_G760A is not set
# CONFIG_SENSORS_G762 is not set
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IBMAEM=y
# CONFIG_SENSORS_IBMPEX is not set
CONFIG_SENSORS_IIO_HWMON=y
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_IT87 is not set
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LTC2945=y
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=y
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_LTC4260 is not set
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_MAX16065=y
# CONFIG_SENSORS_MAX1619 is not set
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=y
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
# CONFIG_SENSORS_MAX6650 is not set
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_HTU21=y
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
# CONFIG_SENSORS_LM77 is not set
CONFIG_SENSORS_LM78=y
# CONFIG_SENSORS_LM80 is not set
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_NCT6775=y
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
CONFIG_SENSORS_SHT21=y
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=y
# CONFIG_SENSORS_SMSC47M192 is not set
CONFIG_SENSORS_SMSC47B397=y
# CONFIG_SENSORS_SCH56XX_COMMON is not set
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_ADC128D818=y
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_AMC6821=y
CONFIG_SENSORS_INA209=y
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
CONFIG_SENSORS_W83792D=y
# CONFIG_SENSORS_W83793 is not set
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_WM831X=y
CONFIG_SENSORS_WM8350=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_THERMAL_EMULATION=y
CONFIG_INTEL_POWERCLAMP=y
# CONFIG_ACPI_INT3403_THERMAL is not set

#
# Texas Instruments thermal drivers
#
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_B43_PCI_BRIDGE=y
CONFIG_SSB_SDIOHOST_POSSIBLE=y
# CONFIG_SSB_SDIOHOST is not set
CONFIG_SSB_SILENT=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_AS3711 is not set
# CONFIG_PMIC_ADP5520 is not set
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
CONFIG_MFD_DA9063=y
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_I2C=y
# CONFIG_HTC_PASIC3 is not set
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX14577 is not set
# CONFIG_MFD_MAX77686 is not set
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX665X is not set
CONFIG_MFD_MAX8925=y
CONFIG_MFD_MAX8997=y
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_VIPERBOARD is not set
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_RTSX_USB is not set
CONFIG_MFD_RC5T583=y
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
CONFIG_MFD_SMSC=y
# CONFIG_ABX500_CORE is not set
CONFIG_MFD_STMPE=y

#
# STMicroelectronics STMPE Interface Drivers
#
# CONFIG_STMPE_I2C is not set
# CONFIG_MFD_SYSCON is not set
CONFIG_MFD_TI_AM335X_TSCADC=y
# CONFIG_MFD_LP3943 is not set
CONFIG_MFD_LP8788=y
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65090=y
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TPS65218 is not set
CONFIG_MFD_TPS6586X=y
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
# CONFIG_TWL4030_MADC is not set
# CONFIG_MFD_TWL4030_AUDIO is not set
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_WM5102=y
# CONFIG_MFD_WM5110 is not set
CONFIG_MFD_WM8997=y
# CONFIG_MFD_WM8400 is not set
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
CONFIG_REGULATOR_ACT8865=y
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_DA9052=y
CONFIG_REGULATOR_DA9055=y
CONFIG_REGULATOR_DA9063=y
# CONFIG_REGULATOR_DA9210 is not set
# CONFIG_REGULATOR_FAN53555 is not set
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_LP8788=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8907=y
# CONFIG_REGULATOR_MAX8925 is not set
# CONFIG_REGULATOR_MAX8952 is not set
# CONFIG_REGULATOR_MAX8973 is not set
# CONFIG_REGULATOR_MAX8997 is not set
CONFIG_REGULATOR_MAX77693=y
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
CONFIG_REGULATOR_MC13892=y
CONFIG_REGULATOR_PALMAS=y
CONFIG_REGULATOR_PCF50633=y
# CONFIG_REGULATOR_PFUZE100 is not set
CONFIG_REGULATOR_RC5T583=y
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=y
# CONFIG_REGULATOR_TPS62360 is not set
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65090=y
# CONFIG_REGULATOR_TPS6586X is not set
# CONFIG_REGULATOR_TWL4030 is not set
CONFIG_REGULATOR_WM831X=y
# CONFIG_REGULATOR_WM8350 is not set
# CONFIG_REGULATOR_WM8994 is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
# CONFIG_MEDIA_RADIO_SUPPORT is not set
# CONFIG_MEDIA_RC_SUPPORT is not set
CONFIG_MEDIA_CONTROLLER=y
CONFIG_VIDEO_DEV=y
# CONFIG_VIDEO_V4L2_SUBDEV_API is not set
CONFIG_VIDEO_V4L2=y
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_TUNER=y
CONFIG_V4L2_MEM2MEM_DEV=y
CONFIG_VIDEOBUF_GEN=y
CONFIG_VIDEOBUF_VMALLOC=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_DVB_CORE=y
# CONFIG_TTPCI_EEPROM is not set
CONFIG_DVB_MAX_ADAPTERS=8
CONFIG_DVB_DYNAMIC_MINORS=y

#
# Media drivers
#
CONFIG_MEDIA_USB_SUPPORT=y

#
# Webcam devices
#
CONFIG_USB_VIDEO_CLASS=y
CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=y
# CONFIG_USB_GSPCA is not set
CONFIG_USB_PWC=y
# CONFIG_USB_PWC_DEBUG is not set
CONFIG_USB_PWC_INPUT_EVDEV=y
# CONFIG_VIDEO_CPIA2 is not set
CONFIG_USB_ZR364XX=y
CONFIG_USB_STKWEBCAM=y
CONFIG_USB_S2255=y
CONFIG_VIDEO_USBTV=y

#
# Analog/digital TV USB devices
#
# CONFIG_VIDEO_AU0828 is not set

#
# Digital TV USB devices
#
# CONFIG_DVB_USB_V2 is not set
# CONFIG_DVB_TTUSB_BUDGET is not set
# CONFIG_DVB_TTUSB_DEC is not set
CONFIG_SMS_USB_DRV=y
CONFIG_DVB_B2C2_FLEXCOP_USB=y
CONFIG_DVB_B2C2_FLEXCOP_USB_DEBUG=y

#
# Webcam, TV (analog/digital) USB devices
#
CONFIG_VIDEO_EM28XX=y
CONFIG_VIDEO_EM28XX_V4L2=y
# CONFIG_VIDEO_EM28XX_ALSA is not set
CONFIG_VIDEO_EM28XX_DVB=y
# CONFIG_MEDIA_PCI_SUPPORT is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
CONFIG_V4L_TEST_DRIVERS=y
CONFIG_VIDEO_VIVI=y
CONFIG_VIDEO_MEM2MEM_TESTDEV=y

#
# Supported MMC/SDIO adapters
#
CONFIG_SMS_SDIO_DRV=y
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
CONFIG_VIDEO_TVEEPROM=y
CONFIG_CYPRESS_FIRMWARE=y
CONFIG_DVB_B2C2_FLEXCOP=y
CONFIG_DVB_B2C2_FLEXCOP_DEBUG=y
CONFIG_SMS_SIANO_MDTV=y

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
# CONFIG_MEDIA_SUBDRV_AUTOSELECT is not set

#
# Encoders, decoders, sensors and other helper chips
#

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=y
CONFIG_VIDEO_TDA7432=y
# CONFIG_VIDEO_TDA9840 is not set
CONFIG_VIDEO_TEA6415C=y
# CONFIG_VIDEO_TEA6420 is not set
# CONFIG_VIDEO_MSP3400 is not set
# CONFIG_VIDEO_CS5345 is not set
CONFIG_VIDEO_CS53L32A=y
CONFIG_VIDEO_TLV320AIC23B=y
CONFIG_VIDEO_UDA1342=y
# CONFIG_VIDEO_WM8775 is not set
CONFIG_VIDEO_WM8739=y
CONFIG_VIDEO_VP27SMPX=y
CONFIG_VIDEO_SONY_BTF_MPX=y

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=y

#
# Video decoders
#
CONFIG_VIDEO_ADV7180=y
CONFIG_VIDEO_ADV7183=y
# CONFIG_VIDEO_BT819 is not set
CONFIG_VIDEO_BT856=y
CONFIG_VIDEO_BT866=y
CONFIG_VIDEO_KS0127=y
CONFIG_VIDEO_ML86V7667=y
CONFIG_VIDEO_SAA7110=y
# CONFIG_VIDEO_SAA711X is not set
CONFIG_VIDEO_SAA7191=y
# CONFIG_VIDEO_TVP514X is not set
CONFIG_VIDEO_TVP5150=y
CONFIG_VIDEO_TVP7002=y
CONFIG_VIDEO_TW2804=y
# CONFIG_VIDEO_TW9903 is not set
CONFIG_VIDEO_TW9906=y
CONFIG_VIDEO_VPX3220=y

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=y
CONFIG_VIDEO_CX25840=y

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=y
CONFIG_VIDEO_SAA7185=y
CONFIG_VIDEO_ADV7170=y
CONFIG_VIDEO_ADV7175=y
CONFIG_VIDEO_ADV7343=y
# CONFIG_VIDEO_ADV7393 is not set
# CONFIG_VIDEO_AK881X is not set
# CONFIG_VIDEO_THS8200 is not set

#
# Camera sensor devices
#
CONFIG_VIDEO_OV7640=y
CONFIG_VIDEO_OV7670=y
# CONFIG_VIDEO_VS6624 is not set
CONFIG_VIDEO_MT9V011=y
# CONFIG_VIDEO_SR030PC30 is not set

#
# Flash devices
#
CONFIG_VIDEO_ADP1653=y
CONFIG_VIDEO_AS3645A=y
# CONFIG_VIDEO_LM3560 is not set

#
# Video improvement chips
#
# CONFIG_VIDEO_UPD64031A is not set
# CONFIG_VIDEO_UPD64083 is not set

#
# Audio/Video compression chips
#
CONFIG_VIDEO_SAA6752HS=y

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_THS7303=y
CONFIG_VIDEO_M52790=y

#
# Sensors used on soc_camera driver
#

#
# Customize TV tuners
#
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_MT2060=y
CONFIG_MEDIA_TUNER_MT2063=y
CONFIG_MEDIA_TUNER_MT2266=y
CONFIG_MEDIA_TUNER_MT2131=y
# CONFIG_MEDIA_TUNER_QT1010 is not set
CONFIG_MEDIA_TUNER_XC2028=y
# CONFIG_MEDIA_TUNER_XC5000 is not set
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MXL5005S=y
# CONFIG_MEDIA_TUNER_MXL5007T is not set
# CONFIG_MEDIA_TUNER_MC44S803 is not set
CONFIG_MEDIA_TUNER_MAX2165=y
# CONFIG_MEDIA_TUNER_TDA18218 is not set
CONFIG_MEDIA_TUNER_FC0011=y
CONFIG_MEDIA_TUNER_FC0012=y
# CONFIG_MEDIA_TUNER_FC0013 is not set
CONFIG_MEDIA_TUNER_TDA18212=y
CONFIG_MEDIA_TUNER_E4000=y
CONFIG_MEDIA_TUNER_FC2580=y
# CONFIG_MEDIA_TUNER_M88TS2022 is not set
CONFIG_MEDIA_TUNER_TUA9001=y
# CONFIG_MEDIA_TUNER_IT913X is not set
CONFIG_MEDIA_TUNER_R820T=y

#
# Customise DVB Frontends
#

#
# Multistandard (satellite) frontends
#
# CONFIG_DVB_STB0899 is not set
CONFIG_DVB_STB6100=y
CONFIG_DVB_STV090x=y
# CONFIG_DVB_STV6110x is not set
CONFIG_DVB_M88DS3103=y

#
# Multistandard (cable + terrestrial) frontends
#
# CONFIG_DVB_DRXK is not set
CONFIG_DVB_TDA18271C2DD=y

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24110=y
CONFIG_DVB_CX24123=y
# CONFIG_DVB_MT312 is not set
CONFIG_DVB_ZL10036=y
CONFIG_DVB_ZL10039=y
# CONFIG_DVB_S5H1420 is not set
CONFIG_DVB_STV0288=y
# CONFIG_DVB_STB6000 is not set
CONFIG_DVB_STV0299=y
CONFIG_DVB_STV6110=y
CONFIG_DVB_STV0900=y
CONFIG_DVB_TDA8083=y
CONFIG_DVB_TDA10086=y
CONFIG_DVB_TDA8261=y
CONFIG_DVB_VES1X93=y
# CONFIG_DVB_TUNER_ITD1000 is not set
CONFIG_DVB_TUNER_CX24113=y
CONFIG_DVB_TDA826X=y
CONFIG_DVB_TUA6100=y
# CONFIG_DVB_CX24116 is not set
CONFIG_DVB_CX24117=y
# CONFIG_DVB_SI21XX is not set
CONFIG_DVB_TS2020=y
# CONFIG_DVB_DS3000 is not set
CONFIG_DVB_MB86A16=y
CONFIG_DVB_TDA10071=y

#
# DVB-T (terrestrial) frontends
#
# CONFIG_DVB_SP8870 is not set
CONFIG_DVB_SP887X=y
CONFIG_DVB_CX22700=y
# CONFIG_DVB_CX22702 is not set
CONFIG_DVB_S5H1432=y
CONFIG_DVB_DRXD=y
CONFIG_DVB_L64781=y
CONFIG_DVB_TDA1004X=y
CONFIG_DVB_NXT6000=y
# CONFIG_DVB_MT352 is not set
CONFIG_DVB_ZL10353=y
CONFIG_DVB_DIB3000MB=y
CONFIG_DVB_DIB3000MC=y
CONFIG_DVB_DIB7000M=y
# CONFIG_DVB_DIB7000P is not set
CONFIG_DVB_DIB9000=y
CONFIG_DVB_TDA10048=y
CONFIG_DVB_AF9013=y
CONFIG_DVB_EC100=y
CONFIG_DVB_HD29L2=y
CONFIG_DVB_STV0367=y
# CONFIG_DVB_CXD2820R is not set
# CONFIG_DVB_RTL2830 is not set
# CONFIG_DVB_RTL2832 is not set

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=y
CONFIG_DVB_TDA10021=y
# CONFIG_DVB_TDA10023 is not set
CONFIG_DVB_STV0297=y

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=y
CONFIG_DVB_OR51211=y
# CONFIG_DVB_OR51132 is not set
CONFIG_DVB_BCM3510=y
CONFIG_DVB_LGDT330X=y
CONFIG_DVB_LGDT3305=y
CONFIG_DVB_LG2160=y
CONFIG_DVB_S5H1409=y
CONFIG_DVB_AU8522=y
CONFIG_DVB_AU8522_DTV=y
# CONFIG_DVB_AU8522_V4L is not set
# CONFIG_DVB_S5H1411 is not set

#
# ISDB-T (terrestrial) frontends
#
# CONFIG_DVB_S921 is not set
CONFIG_DVB_DIB8000=y
CONFIG_DVB_MB86A20S=y

#
# Digital terrestrial only tuners/PLL
#
# CONFIG_DVB_PLL is not set
CONFIG_DVB_TUNER_DIB0070=y
# CONFIG_DVB_TUNER_DIB0090 is not set

#
# SEC control devices for DVB-S
#
# CONFIG_DVB_LNBP21 is not set
CONFIG_DVB_LNBP22=y
CONFIG_DVB_ISL6405=y
# CONFIG_DVB_ISL6421 is not set
CONFIG_DVB_ISL6423=y
CONFIG_DVB_A8293=y
# CONFIG_DVB_LGS8GL5 is not set
CONFIG_DVB_LGS8GXX=y
CONFIG_DVB_ATBM8830=y
# CONFIG_DVB_TDA665x is not set
# CONFIG_DVB_IX2505V is not set
CONFIG_DVB_IT913X_FE=y
CONFIG_DVB_M88RS2000=y
CONFIG_DVB_AF9033=y

#
# Tools to develop new frontends
#
CONFIG_DVB_DUMMY_FE=y

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
CONFIG_DRM_USB=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=y
# CONFIG_DRM_I2C_SIL164 is not set
CONFIG_DRM_I2C_NXP_TDA998X=y
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_NOUVEAU is not set
# CONFIG_DRM_I915 is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
CONFIG_DRM_UDL=y
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
# CONFIG_DRM_QXL is not set
# CONFIG_DRM_BOCHS is not set
# CONFIG_VGASTATE is not set
CONFIG_VIDEO_OUTPUT_CONTROL=y
CONFIG_HDMI=y
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
# CONFIG_FB_DDC is not set
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
CONFIG_FB_HECUBA=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_VESA is not set
CONFIG_FB_N411=y
# CONFIG_FB_HGA is not set
CONFIG_FB_OPENCORES=y
CONFIG_FB_S1D13XXX=y
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
CONFIG_FB_TMIO=y
CONFIG_FB_TMIO_ACCELL=y
CONFIG_FB_SM501=y
CONFIG_FB_SMSCUFX=y
CONFIG_FB_UDL=y
# CONFIG_FB_GOLDFISH is not set
CONFIG_FB_VIRTUAL=y
CONFIG_XEN_FBDEV_FRONTEND=y
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
CONFIG_FB_SIMPLE=y
CONFIG_EXYNOS_VIDEO=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
CONFIG_BACKLIGHT_DA9052=y
# CONFIG_BACKLIGHT_MAX8925 is not set
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=y
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
# CONFIG_BACKLIGHT_PCF50633 is not set
CONFIG_BACKLIGHT_LM3630A=y
CONFIG_BACKLIGHT_LM3639=y
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_LP8788=y
CONFIG_BACKLIGHT_PANDORA=y
CONFIG_BACKLIGHT_LV5207LP=y
CONFIG_BACKLIGHT_BD6107=y
# CONFIG_LOGO is not set
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_HWDEP=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
# CONFIG_SND_MIXER_OSS is not set
# CONFIG_SND_PCM_OSS is not set
# CONFIG_SND_SEQUENCER_OSS is not set
# CONFIG_SND_HRTIMER is not set
# CONFIG_SND_DYNAMIC_MINORS is not set
# CONFIG_SND_SUPPORT_OLD_API is not set
# CONFIG_SND_VERBOSE_PROCFS is not set
CONFIG_SND_VERBOSE_PRINTK=y
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_RAWMIDI_SEQ=y
# CONFIG_SND_OPL3_LIB_SEQ is not set
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
# CONFIG_SND_EMU10K1_SEQ is not set
# CONFIG_SND_DRIVERS is not set
CONFIG_SND_PCI=y
# CONFIG_SND_AD1889 is not set
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALI5451 is not set
# CONFIG_SND_ASIHPI is not set
# CONFIG_SND_ATIIXP is not set
# CONFIG_SND_ATIIXP_MODEM is not set
# CONFIG_SND_AU8810 is not set
# CONFIG_SND_AU8820 is not set
# CONFIG_SND_AU8830 is not set
# CONFIG_SND_AW2 is not set
# CONFIG_SND_AZT3328 is not set
# CONFIG_SND_BT87X is not set
# CONFIG_SND_CA0106 is not set
# CONFIG_SND_CMIPCI is not set
# CONFIG_SND_OXYGEN is not set
# CONFIG_SND_CS4281 is not set
# CONFIG_SND_CS46XX is not set
# CONFIG_SND_CS5535AUDIO is not set
# CONFIG_SND_CTXFI is not set
# CONFIG_SND_DARLA20 is not set
# CONFIG_SND_GINA20 is not set
# CONFIG_SND_LAYLA20 is not set
# CONFIG_SND_DARLA24 is not set
# CONFIG_SND_GINA24 is not set
# CONFIG_SND_LAYLA24 is not set
# CONFIG_SND_MONA is not set
# CONFIG_SND_MIA is not set
# CONFIG_SND_ECHO3G is not set
# CONFIG_SND_INDIGO is not set
# CONFIG_SND_INDIGOIO is not set
# CONFIG_SND_INDIGODJ is not set
# CONFIG_SND_INDIGOIOX is not set
# CONFIG_SND_INDIGODJX is not set
# CONFIG_SND_EMU10K1 is not set
# CONFIG_SND_EMU10K1X is not set
# CONFIG_SND_ENS1370 is not set
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_ES1938 is not set
# CONFIG_SND_ES1968 is not set
# CONFIG_SND_FM801 is not set
# CONFIG_SND_HDA_INTEL is not set
# CONFIG_SND_HDSP is not set
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_ICE1712 is not set
# CONFIG_SND_ICE1724 is not set
# CONFIG_SND_INTEL8X0 is not set
# CONFIG_SND_INTEL8X0M is not set
# CONFIG_SND_KORG1212 is not set
# CONFIG_SND_LOLA is not set
# CONFIG_SND_LX6464ES is not set
# CONFIG_SND_MAESTRO3 is not set
# CONFIG_SND_MIXART is not set
# CONFIG_SND_NM256 is not set
# CONFIG_SND_PCXHR is not set
# CONFIG_SND_RIPTIDE is not set
# CONFIG_SND_RME32 is not set
# CONFIG_SND_RME96 is not set
# CONFIG_SND_RME9652 is not set
# CONFIG_SND_SONICVIBES is not set
# CONFIG_SND_TRIDENT is not set
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VIA82XX_MODEM is not set
# CONFIG_SND_VIRTUOSO is not set
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set
CONFIG_SND_USB=y
# CONFIG_SND_USB_AUDIO is not set
# CONFIG_SND_USB_UA101 is not set
CONFIG_SND_USB_USX2Y=y
CONFIG_SND_USB_CAIAQ=y
# CONFIG_SND_USB_CAIAQ_INPUT is not set
CONFIG_SND_USB_US122L=y
CONFIG_SND_USB_6FIRE=y
# CONFIG_SND_USB_HIFACE is not set
# CONFIG_SND_SOC is not set
CONFIG_SOUND_PRIME=y

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
CONFIG_UHID=y
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
CONFIG_HID_AUREAL=y
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
# CONFIG_HID_CHICONY is not set
CONFIG_HID_PRODIKEYS=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
CONFIG_HID_EMS_FF=y
# CONFIG_HID_ELECOM is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
CONFIG_HID_UCLOGIC=y
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
# CONFIG_HID_ICADE is not set
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LENOVO_TPKBD=y
# CONFIG_HID_LOGITECH is not set
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=y
# CONFIG_HID_PICOLCD is not set
CONFIG_HID_PRIMAX=y
CONFIG_HID_SAITEK=y
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SPEEDLINK=y
# CONFIG_HID_STEELSERIES is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
# CONFIG_HID_SMARTJOYPLUS is not set
CONFIG_HID_TIVO=y
# CONFIG_HID_TOPSEED is not set
CONFIG_HID_THINGM=y
CONFIG_HID_THRUSTMASTER=y
CONFIG_THRUSTMASTER_FF=y
CONFIG_HID_WACOM=y
CONFIG_HID_WIIMOTE=y
# CONFIG_HID_XINMO is not set
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
# CONFIG_HID_ZYDACRON is not set
CONFIG_HID_SENSOR_HUB=y

#
# USB HID support
#
# CONFIG_USB_HID is not set
CONFIG_HID_PID=y

#
# USB HID Boot Protocol drivers
#
CONFIG_USB_KBD=y
CONFIG_USB_MOUSE=y

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
# CONFIG_USB_DEFAULT_PERSIST is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_OTG=y
# CONFIG_USB_OTG_WHITELIST is not set
CONFIG_USB_OTG_BLACKLIST_HUB=y
CONFIG_USB_MON=y
CONFIG_USB_WUSB_CBAF=y
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
CONFIG_USB_XHCI_HCD=y
CONFIG_USB_XHCI_PLATFORM=y
# CONFIG_USB_EHCI_HCD is not set
CONFIG_USB_OXU210HP_HCD=y
CONFIG_USB_ISP116X_HCD=y
CONFIG_USB_ISP1760_HCD=y
# CONFIG_USB_ISP1362_HCD is not set
CONFIG_USB_FUSBH200_HCD=y
# CONFIG_USB_FOTG210_HCD is not set
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
CONFIG_USB_OHCI_HCD_SSB=y
CONFIG_USB_OHCI_HCD_PLATFORM=y
# CONFIG_USB_UHCI_HCD is not set
# CONFIG_USB_U132_HCD is not set
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
# CONFIG_USB_R8A66597_HCD is not set
CONFIG_USB_RENESAS_USBHS_HCD=y
CONFIG_USB_HCD_SSB=y
# CONFIG_USB_HCD_TEST_MODE is not set
CONFIG_USB_RENESAS_USBHS=y

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
CONFIG_USB_PRINTER=y
# CONFIG_USB_WDM is not set
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y
# CONFIG_USB_MUSB_HDRC is not set
CONFIG_USB_DWC3=y
# CONFIG_USB_DWC3_HOST is not set
# CONFIG_USB_DWC3_GADGET is not set
CONFIG_USB_DWC3_DUAL_ROLE=y

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_EXYNOS=y
CONFIG_USB_DWC3_PCI=y
CONFIG_USB_DWC3_KEYSTONE=y

#
# Debugging features
#
CONFIG_USB_DWC3_DEBUG=y
CONFIG_USB_DWC3_VERBOSE=y
# CONFIG_USB_DWC2 is not set
# CONFIG_USB_CHIPIDEA is not set

#
# USB port drivers
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
CONFIG_USB_EMI26=y
CONFIG_USB_ADUTUX=y
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
CONFIG_USB_LEGOTOWER=y
CONFIG_USB_LCD=y
# CONFIG_USB_LED is not set
CONFIG_USB_CYPRESS_CY7C63=y
CONFIG_USB_CYTHERM=y
# CONFIG_USB_IDMOUSE is not set
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
# CONFIG_USB_LD is not set
CONFIG_USB_TRANCEVIBRATOR=y
# CONFIG_USB_IOWARRIOR is not set
CONFIG_USB_TEST=y
CONFIG_USB_EHSET_TEST_FIXTURE=y
# CONFIG_USB_ISIGHTFW is not set
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
# CONFIG_USB_HSIC_USB3503 is not set
CONFIG_USB_ATM=y
CONFIG_USB_SPEEDTOUCH=y
# CONFIG_USB_CXACRU is not set
CONFIG_USB_UEAGLEATM=y
# CONFIG_USB_XUSBATM is not set

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_USB_OTG_FSM=y
# CONFIG_NOP_USB_XCEIV is not set
CONFIG_SAMSUNG_USBPHY=y
# CONFIG_SAMSUNG_USB2PHY is not set
CONFIG_SAMSUNG_USB3PHY=y
CONFIG_USB_ISP1301=y
# CONFIG_USB_RCAR_PHY is not set
CONFIG_USB_GADGET=y
CONFIG_USB_GADGET_DEBUG=y
CONFIG_USB_GADGET_VERBOSE=y
CONFIG_USB_GADGET_DEBUG_FILES=y
CONFIG_USB_GADGET_DEBUG_FS=y
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
CONFIG_USB_FOTG210_UDC=y
CONFIG_USB_GR_UDC=y
CONFIG_USB_R8A66597=y
# CONFIG_USB_RENESAS_USBHS_UDC is not set
CONFIG_USB_PXA27X=y
# CONFIG_USB_MV_UDC is not set
CONFIG_USB_MV_U3D=y
CONFIG_USB_M66592=y
# CONFIG_USB_AMD5536UDC is not set
# CONFIG_USB_NET2272 is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
# CONFIG_USB_EG20T is not set
CONFIG_USB_DUMMY_HCD=y
# CONFIG_USB_CONFIGFS is not set
# CONFIG_USB_ZERO is not set
# CONFIG_USB_AUDIO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
CONFIG_USB_GADGETFS=y
# CONFIG_USB_FUNCTIONFS is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_MIDI_GADGET is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
# CONFIG_USB_G_WEBCAM is not set
# CONFIG_UWB is not set
CONFIG_MMC=y
# CONFIG_MMC_DEBUG is not set
# CONFIG_MMC_UNSAFE_RESUME is not set
# CONFIG_MMC_CLKGATE is not set

#
# MMC/SD/SDIO Card Drivers
#
# CONFIG_SDIO_UART is not set
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_SDHCI is not set
# CONFIG_MMC_TIFM_SD is not set
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MMC_VUB300=y
# CONFIG_MMC_USHC is not set
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
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3533=y
CONFIG_LEDS_LM3642=y
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
CONFIG_LEDS_LP8788=y
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_PCA9685=y
# CONFIG_LEDS_WM831X_STATUS is not set
CONFIG_LEDS_WM8350=y
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_REGULATOR=y
# CONFIG_LEDS_BD2802 is not set
CONFIG_LEDS_MC13783=y
# CONFIG_LEDS_TCA6507 is not set
CONFIG_LEDS_MAX8997=y
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_OT200=y
# CONFIG_LEDS_BLINKM is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
# CONFIG_LEDS_TRIGGER_CAMERA is not set
CONFIG_ACCESSIBILITY=y
CONFIG_EDAC=y
# CONFIG_EDAC_LEGACY_SYSFS is not set
CONFIG_EDAC_DEBUG=y
CONFIG_EDAC_DECODE_MCE=y
CONFIG_EDAC_MCE_INJ=y
CONFIG_EDAC_MM_EDAC=y
# CONFIG_EDAC_AMD64 is not set
# CONFIG_EDAC_E752X is not set
# CONFIG_EDAC_I82975X is not set
# CONFIG_EDAC_I3000 is not set
# CONFIG_EDAC_I3200 is not set
# CONFIG_EDAC_X38 is not set
# CONFIG_EDAC_I5400 is not set
# CONFIG_EDAC_I5000 is not set
# CONFIG_EDAC_I5100 is not set
# CONFIG_EDAC_I7300 is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
CONFIG_RTC_DEBUG=y

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_DS1307=y
CONFIG_RTC_DRV_DS1374=y
# CONFIG_RTC_DRV_DS1672 is not set
CONFIG_RTC_DRV_DS3232=y
CONFIG_RTC_DRV_LP8788=y
CONFIG_RTC_DRV_MAX6900=y
# CONFIG_RTC_DRV_MAX8907 is not set
CONFIG_RTC_DRV_MAX8925=y
CONFIG_RTC_DRV_MAX8997=y
CONFIG_RTC_DRV_RS5C372=y
CONFIG_RTC_DRV_ISL1208=y
# CONFIG_RTC_DRV_ISL12022 is not set
CONFIG_RTC_DRV_ISL12057=y
CONFIG_RTC_DRV_X1205=y
CONFIG_RTC_DRV_PALMAS=y
CONFIG_RTC_DRV_PCF2127=y
CONFIG_RTC_DRV_PCF8523=y
# CONFIG_RTC_DRV_PCF8563 is not set
CONFIG_RTC_DRV_PCF8583=y
CONFIG_RTC_DRV_M41T80=y
# CONFIG_RTC_DRV_M41T80_WDT is not set
# CONFIG_RTC_DRV_BQ32K is not set
CONFIG_RTC_DRV_TWL4030=y
CONFIG_RTC_DRV_TPS6586X=y
CONFIG_RTC_DRV_RC5T583=y
CONFIG_RTC_DRV_S35390A=y
# CONFIG_RTC_DRV_FM3130 is not set
CONFIG_RTC_DRV_RX8581=y
CONFIG_RTC_DRV_RX8025=y
# CONFIG_RTC_DRV_EM3027 is not set
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=y
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
# CONFIG_RTC_DRV_DS1742 is not set
CONFIG_RTC_DRV_DA9052=y
CONFIG_RTC_DRV_DA9055=y
# CONFIG_RTC_DRV_STK17TA8 is not set
CONFIG_RTC_DRV_M48T86=y
# CONFIG_RTC_DRV_M48T35 is not set
CONFIG_RTC_DRV_M48T59=y
# CONFIG_RTC_DRV_MSM6242 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
# CONFIG_RTC_DRV_RP5C01 is not set
# CONFIG_RTC_DRV_V3020 is not set
CONFIG_RTC_DRV_DS2404=y
CONFIG_RTC_DRV_WM831X=y
# CONFIG_RTC_DRV_WM8350 is not set
CONFIG_RTC_DRV_PCF50633=y

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_MC13XXX=y
# CONFIG_RTC_DRV_MOXART is not set

#
# HID Sensor RTC drivers
#
# CONFIG_DMADEVICES is not set
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
# CONFIG_UIO_PDRV_GENIRQ is not set
CONFIG_UIO_DMEM_GENIRQ=y
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_MF624 is not set
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_MMIO=y
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set

#
# Xen driver support
#
# CONFIG_XEN_BALLOON is not set
# CONFIG_XEN_DEV_EVTCHN is not set
CONFIG_XEN_BACKEND=y
CONFIG_XENFS=y
# CONFIG_XEN_COMPAT_XENFS is not set
CONFIG_XEN_SYS_HYPERVISOR=y
CONFIG_XEN_XENBUS_FRONTEND=y
CONFIG_XEN_GNTDEV=y
CONFIG_XEN_GRANT_DEV_ALLOC=y
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_TMEM=y
CONFIG_XEN_PCIDEV_BACKEND=y
CONFIG_XEN_PRIVCMD=y
CONFIG_XEN_ACPI_PROCESSOR=y
# CONFIG_XEN_MCE_LOG is not set
CONFIG_XEN_HAVE_PVMMU=y
CONFIG_STAGING=y
# CONFIG_ET131X is not set
# CONFIG_SLICOSS is not set
CONFIG_USBIP_CORE=y
# CONFIG_USBIP_VHCI_HCD is not set
# CONFIG_USBIP_HOST is not set
CONFIG_USBIP_DEBUG=y
# CONFIG_W35UND is not set
CONFIG_PRISM2_USB=y
CONFIG_ECHO=y
CONFIG_R8712U=y
CONFIG_R8188EU=y
# CONFIG_88EU_AP_MODE is not set
# CONFIG_88EU_P2P is not set
CONFIG_TRANZPORT=y
# CONFIG_LINE6_USB is not set
# CONFIG_DX_SEP is not set

#
# IIO staging drivers
#

#
# Accelerometers
#

#
# Analog to digital converters
#
CONFIG_AD7291=y
# CONFIG_AD799X is not set

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

#
# Digital gyroscope sensors
#

#
# Network Analyzer, Impedance Converters
#
# CONFIG_AD5933 is not set

#
# Light sensors
#
CONFIG_SENSORS_ISL29018=y
# CONFIG_SENSORS_ISL29028 is not set
# CONFIG_TSL2583 is not set
CONFIG_TSL2x7x=y

#
# Magnetometer sensors
#
# CONFIG_SENSORS_HMC5843 is not set

#
# Active energy metering IC
#
CONFIG_ADE7854=y
CONFIG_ADE7854_I2C=y

#
# Resolver to digital converters
#

#
# Triggers - standalone
#
# CONFIG_IIO_PERIODIC_RTC_TRIGGER is not set
# CONFIG_IIO_SIMPLE_DUMMY is not set
# CONFIG_FB_SM7XX is not set
# CONFIG_CRYSTALHD is not set
# CONFIG_FB_XGI is not set
# CONFIG_ACPI_QUICKSTART is not set
# CONFIG_BCM_WIMAX is not set
CONFIG_FT1000=y
CONFIG_FT1000_USB=y

#
# Speakup console speech
#
CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4=y
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
CONFIG_ANDROID=y
# CONFIG_ANDROID_BINDER_IPC is not set
# CONFIG_ASHMEM is not set
# CONFIG_ANDROID_LOGGER is not set
# CONFIG_ANDROID_TIMED_OUTPUT is not set
CONFIG_ANDROID_LOW_MEMORY_KILLER=y
# CONFIG_ANDROID_INTF_ALARM_DEV is not set
# CONFIG_SYNC is not set
CONFIG_ION=y
CONFIG_ION_TEST=y
CONFIG_ION_DUMMY=y
CONFIG_USB_WPAN_HCD=y
CONFIG_WIMAX_GDM72XX=y
CONFIG_WIMAX_GDM72XX_QOS=y
CONFIG_WIMAX_GDM72XX_K_MODE=y
CONFIG_WIMAX_GDM72XX_WIMAX2=y
CONFIG_WIMAX_GDM72XX_USB=y
# CONFIG_WIMAX_GDM72XX_SDIO is not set
# CONFIG_WIMAX_GDM72XX_USB_PM is not set
# CONFIG_NET_VENDOR_SILICOM is not set
# CONFIG_CED1401 is not set
# CONFIG_DGRP is not set
# CONFIG_XILLYBUS is not set
# CONFIG_DGNC is not set
# CONFIG_DGAP is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
CONFIG_DELL_LAPTOP=y
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
CONFIG_SAMSUNG_LAPTOP=y
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_PSTORE=y

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
# CONFIG_MAILBOX is not set
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
CONFIG_MEMORY=y
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Accelerometers
#
CONFIG_BMA180=y
CONFIG_HID_SENSOR_ACCEL_3D=y
# CONFIG_IIO_ST_ACCEL_3AXIS is not set

#
# Analog to digital converters
#
# CONFIG_LP8788_ADC is not set
CONFIG_MAX1363=y
CONFIG_MCP3422=y
# CONFIG_NAU7802 is not set
CONFIG_TI_ADC081C=y
CONFIG_TI_AM335X_ADC=y
# CONFIG_TWL6030_GPADC is not set

#
# Amplifiers
#

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=y
CONFIG_HID_SENSOR_IIO_TRIGGER=y
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
# CONFIG_AD5064 is not set
CONFIG_AD5380=y
# CONFIG_AD5446 is not set
CONFIG_MAX517=y
CONFIG_MCP4725=y

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#

#
# Phase-Locked Loop (PLL) frequency synthesizers
#

#
# Digital gyroscope sensors
#
# CONFIG_HID_SENSOR_GYRO_3D is not set
# CONFIG_IIO_ST_GYRO_3AXIS is not set
CONFIG_ITG3200=y

#
# Humidity sensors
#

#
# Inertial measurement units
#
CONFIG_INV_MPU6050_IIO=y

#
# Light sensors
#
# CONFIG_ADJD_S311 is not set
# CONFIG_APDS9300 is not set
# CONFIG_CM32181 is not set
CONFIG_CM36651=y
# CONFIG_GP2AP020A00F is not set
# CONFIG_HID_SENSOR_ALS is not set
CONFIG_SENSORS_LM3533=y
CONFIG_TCS3472=y
# CONFIG_SENSORS_TSL2563 is not set
CONFIG_TSL4531=y
# CONFIG_VCNL4000 is not set

#
# Magnetometer sensors
#
CONFIG_MAG3110=y
CONFIG_HID_SENSOR_MAGNETOMETER_3D=y
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y

#
# Inclinometer sensors
#
CONFIG_HID_SENSOR_INCLINOMETER_3D=y

#
# Triggers - standalone
#
# CONFIG_IIO_INTERRUPT_TRIGGER is not set
CONFIG_IIO_SYSFS_TRIGGER=y

#
# Pressure sensors
#
# CONFIG_MPL3115 is not set
CONFIG_IIO_ST_PRESS=y
CONFIG_IIO_ST_PRESS_I2C=y

#
# Temperature sensors
#
CONFIG_TMP006=y
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set
CONFIG_FMC=y
# CONFIG_FMC_FAKEDEV is not set
CONFIG_FMC_TRIVIAL=y
CONFIG_FMC_WRITE_EEPROM=y
# CONFIG_FMC_CHARDEV is not set

#
# PHY Subsystem
#
# CONFIG_GENERIC_PHY is not set
CONFIG_PHY_EXYNOS_MIPI_VIDEO=y
# CONFIG_POWERCAP is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_DELL_RBU is not set
CONFIG_DCDBAS=y
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_FILE_LOCKING is not set
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
# CONFIG_PRINT_QUOTA_WARNING is not set
CONFIG_QUOTA_DEBUG=y
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_AUTOFS4_FS=y
# CONFIG_FUSE_FS is not set

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
CONFIG_FSCACHE_HISTOGRAM=y
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
# CONFIG_PROC_SYSCTL is not set
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y
# CONFIG_MISC_FILESYSTEMS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=y
# CONFIG_NLS_CODEPAGE_850 is not set
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
CONFIG_NLS_CODEPAGE_865=y
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
# CONFIG_NLS_CODEPAGE_1250 is not set
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
# CONFIG_NLS_MAC_CYRILLIC is not set
CONFIG_NLS_MAC_GAELIC=y
# CONFIG_NLS_MAC_GREEK is not set
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
# CONFIG_NLS_UTF8 is not set

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
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
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
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
# CONFIG_DEBUG_SLAB is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_VM is not set
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=y
CONFIG_DEBUG_PER_CPU_MAPS=y
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
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHEDSTATS is not set
# CONFIG_TIMER_STATS is not set

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
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_WRITECOUNT=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_SG=y
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
# CONFIG_PROVE_RCU_REPEATEDLY is not set
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_TORTURE_TEST is not set
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_CPU_STALL_INFO=y
CONFIG_RCU_TRACE=y
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_CPU_NOTIFIER_ERROR_INJECT=y
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
# CONFIG_FAIL_PAGE_ALLOC is not set
# CONFIG_FAIL_MMC_REQUEST is not set
CONFIG_FAULT_INJECTION_DEBUG_FS=y
# CONFIG_LATENCYTOP is not set
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
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
CONFIG_TEST_LIST_SORT=y
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=y
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_TEST_STRING_HELPERS is not set
CONFIG_TEST_KSTRTOX=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_BUILD_DOCSRC is not set
CONFIG_DMA_API_DEBUG=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_RODATA is not set
CONFIG_DOUBLEFAULT=y
CONFIG_DEBUG_TLBFLUSH=y
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_X86_DEBUG_STATIC_CPU_HAS is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
# CONFIG_BIG_KEYS is not set
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_FIPS=y
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
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=y
# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
# CONFIG_CRYPTO_GCM is not set
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
# CONFIG_CRYPTO_CRC32C_INTEL is not set
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=y
# CONFIG_CRYPTO_GHASH is not set
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
# CONFIG_CRYPTO_RMD256 is not set
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
# CONFIG_CRYPTO_SHA256_SSSE3 is not set
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_TGR192 is not set
CONFIG_CRYPTO_WP512=y
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
# CONFIG_CRYPTO_AES_NI_INTEL is not set
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
# CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_ZLIB is not set
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_USER_API=y
# CONFIG_CRYPTO_USER_API_HASH is not set
CONFIG_CRYPTO_USER_API_SKCIPHER=y
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
# CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE is not set
CONFIG_PUBLIC_KEY_ALGO_RSA=y
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_IRQ_ROUTING=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_KVM_VFIO=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
CONFIG_KVM_AMD=y
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
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
CONFIG_CRC32_SLICEBY4=y
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
# CONFIG_XZ_DEC_POWERPC is not set
# CONFIG_XZ_DEC_IA64 is not set
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
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
CONFIG_FONT_SUPPORT=y
CONFIG_FONT_8x16=y
CONFIG_FONT_AUTOSELECT=y

--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

_______________________________________________
LKP mailing list
LKP@linux.intel.com

--sdtB3X0nJg68CQEu--
