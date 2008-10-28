From: Andrey Borzenkov <arvidjaar@mail.ru>
Subject: 2.6.28-rc2 - kernel BUG at /home/bor/src/linux-git/net/rfkill/rfkill.c:347!
Date: Tue, 28 Oct 2008 22:10:37 +0300
Message-ID: <200810282210.38038.arvidjaar@mail.ru>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart8283831.roZQjrUZeO";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752774AbYJ1TLA@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart8283831.roZQjrUZeO
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Is it even supported on Toshiba Portege 4000?

[    0.000000] BIOS EBDA/lowmem at: 0009fc00/0009fc00
[    0.000000] Linux version 2.6.28-rc2-1avb (bor@cooker) (gcc version 4.3.=
2 (GCC) ) #3 Mon Oct 27 22:14:49 MSK 2008
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000] PAT WC disabled due to known CPU erratum.
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
[    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e0000 - 00000000000eee00 (reserved)
[    0.000000]  BIOS-e820: 00000000000eee00 - 00000000000ef000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000000ef000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000001ef60000 (usable)
[    0.000000]  BIOS-e820: 000000001ef60000 - 000000001ef70000 (ACPI data)
[    0.000000]  BIOS-e820: 000000001ef70000 - 0000000020000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fff80000 - 0000000100000000 (reserved)
[    0.000000] DMI 2.3 present.
[    0.000000] last_pfn =3D 0x1ef60 max_arch_pfn =3D 0x100000
[    0.000000] kernel direct mapping tables up to 1ef60000 @ 7000-d000
[    0.000000] RAMDISK: 1eba9000 - 1ef4f0ed
[    0.000000] ACPI: RSDP 000F0090, 0014 (r0 TOSHIB)
[    0.000000] ACPI: RSDT 1EF60000, 0028 (r1 TOSHIB 750        970814 TASM =
 4010000)
[    0.000000] ACPI: FACP 1EF60054, 0084 (r2 TOSHIB 750        970814 TASM =
 4010000)
[    0.000000] ACPI: DSDT 1EF600D8, 68DA (r1 TOSHIB 4000     20020417 MSFT =
 100000A)
[    0.000000] ACPI: FACS 000EEE00, 0040
[    0.000000] ACPI: DMI detected: Toshiba
[    0.000000] 495MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 1ef60000
[    0.000000]   low ram: 00000000 - 1ef60000
[    0.000000]   bootmap 00001000 - 00004dec
[    0.000000] (7 early reservations) =3D=3D> bootmem [0000000000 - 001ef60=
000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page =3D=3D> [000=
0000000 - 0000001000]
[    0.000000]   #1 [0000100000 - 000095cbf4]    TEXT DATA BSS =3D=3D> [000=
0100000 - 000095cbf4]
[    0.000000]   #2 [001eba9000 - 001ef4f0ed]          RAMDISK =3D=3D> [001=
eba9000 - 001ef4f0ed]
[    0.000000]   #3 [000095d000 - 0000961000]    INIT_PG_TABLE =3D=3D> [000=
095d000 - 0000961000]
[    0.000000]   #4 [000009fc00 - 0000100000]    BIOS reserved =3D=3D> [000=
009fc00 - 0000100000]
[    0.000000]   #5 [0000007000 - 0000009000]          PGTABLE =3D=3D> [000=
0007000 - 0000009000]
[    0.000000]   #6 [0000001000 - 0000005000]          BOOTMAP =3D=3D> [000=
0001000 - 0000005000]
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000000 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x0001ef60
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000000 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0001ef60
[    0.000000] On node 0 totalpages: 126719
[    0.000000] free_area_init_node: node 0, pgdat c03f41e0, node_mem_map c1=
000000
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3967 pages, LIFO batch:0
[    0.000000]   Normal zone: 959 pages used for memmap
[    0.000000]   Normal zone: 121761 pages, LIFO batch:31
[    0.000000]   Movable zone: 0 pages used for memmap
[    0.000000] ACPI: PM-Timer IO Port: 0xee08
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000=
a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000=
e0000
[    0.000000] PM: Registered nosave memory: 00000000000e0000 - 00000000000=
ee000
[    0.000000] PM: Registered nosave memory: 00000000000ee000 - 00000000000=
ef000
[    0.000000] PM: Registered nosave memory: 00000000000ef000 - 00000000001=
00000
[    0.000000] Allocating PCI resources starting at 30000000 (gap: 20000000=
:dff80000)
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 125728
[    0.000000] Kernel command line: BOOT_IMAGE=3D2.6.28-rc2-1avb root=3DLAB=
EL=3D/ resume=3DLABEL=3Dswap acpi_backlight=3Dvendor netconsole=3D@10.0.0.1=
/eth0,@10.0.0.2/00:17:42:21:27:e4 vga=3D791
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] CPU 0 irqstacks, hard=3Dc043f000 soft=3Dc043e000
[    0.000000] PID hash table entries: 2048 (order: 11, 8192 bytes)
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 747.712 MHz processor.
[    0.003333] Console: colour dummy device 80x25
[    0.003333] console [tty0] enabled
[    0.003333] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.003333] ... MAX_LOCKDEP_SUBCLASSES:    8
[    0.003333] ... MAX_LOCK_DEPTH:          48
[    0.003333] ... MAX_LOCKDEP_KEYS:        8191
[    0.003333] ... CLASSHASH_SIZE:           4096
[    0.003333] ... MAX_LOCKDEP_ENTRIES:     8192
[    0.003333] ... MAX_LOCKDEP_CHAINS:      16384
[    0.003333] ... CHAINHASH_SIZE:          8192
[    0.003333]  memory used by lock dependency info: 2463 kB
[    0.003333]  per task-struct memory footprint: 1920 bytes
[    0.003333] ------------------------
[    0.003333] | Locking API testsuite:
[    0.003333] ------------------------------------------------------------=
=2D---------------
[    0.003333]                                  | spin |wlock |rlock |mutex=
 | wsem | rsem |
[    0.003333]   ----------------------------------------------------------=
=2D---------------
[    0.003333]                      A-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.003333]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.003333]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.003333]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.003333]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.003333]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.003333]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.003333]                     double unlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.003333]                   initialize held:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.003333]                  bad unlock order:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.003333]   ----------------------------------------------------------=
=2D---------------
[    0.003333]               recursive read-lock:             |  ok  |     =
        |  ok  |
[    0.003333]            recursive read-lock #2:             |  ok  |     =
        |  ok  |
[    0.003333]             mixed read-write-lock:             |  ok  |     =
        |  ok  |
[    0.003333]             mixed write-read-lock:             |  ok  |     =
        |  ok  |
[    0.003333]   ----------------------------------------------------------=
=2D---------------
[    0.003333]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.003333]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.003333]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.003333]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.003333]        sirq-safe-A =3D> hirqs-on/12:  ok  |  ok  |  ok  |
[    0.003333]        sirq-safe-A =3D> hirqs-on/21:  ok  |  ok  |  ok  |
[    0.003333]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.003333]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.003333]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.003333]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.003333]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.003333]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.003333]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.003333]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.003333]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.003333]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.003333]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.003333]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.003333]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.003333]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.003333]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.003333]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.003333]       hard-irq read-recursion/123:  ok  |
[    0.003333]       soft-irq read-recursion/123:  ok  |
[    0.003333]       hard-irq read-recursion/132:  ok  |
[    0.003333]       soft-irq read-recursion/132:  ok  |
[    0.003333]       hard-irq read-recursion/213:  ok  |
[    0.003333]       soft-irq read-recursion/213:  ok  |
[    0.003333]       hard-irq read-recursion/231:  ok  |
[    0.003333]       soft-irq read-recursion/231:  ok  |
[    0.003333]       hard-irq read-recursion/312:  ok  |
[    0.003333]       soft-irq read-recursion/312:  ok  |
[    0.003333]       hard-irq read-recursion/321:  ok  |
[    0.003333]       soft-irq read-recursion/321:  ok  |
[    0.003333] -------------------------------------------------------
[    0.003333] Good, all 218 testcases passed! |
[    0.003333] ---------------------------------
[    0.003333] Dentry cache hash table entries: 65536 (order: 6, 262144 byt=
es)
[    0.003333] Inode-cache hash table entries: 32768 (order: 5, 131072 byte=
s)
[    0.003333] Memory: 489948k/507264k available (2088k kernel code, 16732k=
 reserved, 974k data, 240k init, 0k highmem)
[    0.003333] virtual kernel memory layout:
[    0.003333]     fixmap  : 0xffffa000 - 0xfffff000   (  20 kB)
[    0.003333]     vmalloc : 0xdf760000 - 0xffff8000   ( 520 MB)
[    0.003333]     lowmem  : 0xc0000000 - 0xdef60000   ( 495 MB)
[    0.003333]       .init : 0xc03ff000 - 0xc043b000   ( 240 kB)
[    0.003333]       .data : 0xc030a366 - 0xc03fdf5c   ( 974 kB)
[    0.003333]       .text : 0xc0100000 - 0xc030a366   (2088 kB)
[    0.003333] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.003333] SLUB: Genslabs=3D12, HWalign=3D32, Order=3D0-3, MinObjects=
=3D0, CPUs=3D1, Nodes=3D1
[    0.003410] Calibrating delay loop (skipped), value calculated using tim=
er frequency.. 1496.73 BogoMIPS (lpj=3D2492373)
[    0.003576] Mount-cache hash table entries: 512
[    0.005913] CPU: L1 I cache: 16K, L1 D cache: 16K
[    0.005956] CPU: L2 cache: 256K
[    0.005974] CPU serial number disabled.
[    0.006017] CPU: Intel Pentium III (Coppermine) stepping 0a
[    0.006060] Checking 'hlt' instruction... OK.
[    0.017725] Freeing SMP alternatives: 0k freed
[    0.017747] ACPI: Core revision 20080926
[    0.047471] ACPI: setting ELCR to 0200 (from 0a00)
[    0.048051] ftrace: converting mcount calls to 0f 1f 44 00 00
[    0.048079] ftrace: allocating 9102 hash entries in 35 pages
[    0.071549] Testing tracer nop: PASSED
[    0.075010] net_namespace: 392 bytes
[    0.076364] NET: Registered protocol family 16
[    0.079577] ACPI: bus type pci registered
[    0.081563] PCI: PCI BIOS revision 2.10 entry at 0xfe5ae, last bus=3D5
[    0.081612] PCI: Using configuration type 1 for base access
[    0.102414] ACPI: EC: Look up EC in DSDT
[    0.132820] ACPI: Interpreter enabled
[    0.132880] ACPI: (supports S0 S3 S4 S5)
[    0.133304] ACPI: Using PIC for interrupt routing
[    0.193081] ACPI: ACPI Dock Station Driver: 2 docks/bays found
[    0.193251] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.194407] pci 0000:00:00.0: reg 10 32bit mmio: [0xf0000000-0xf3ffffff]
[    0.194768] pci 0000:00:02.0: reg 10 32bit mmio: [0xf7eff000-0xf7efffff]
[    0.194893] pci 0000:00:02.0: PME# supported from D3hot D3cold
[    0.194943] pci 0000:00:02.0: PME# disabled
[    0.195127] pci 0000:00:04.0: reg 20 io port: [0xeff0-0xefff]
[    0.195303] pci 0000:00:06.0: reg 10 io port: [0xed00-0xedff]
[    0.195328] pci 0000:00:06.0: reg 14 32bit mmio: [0xf7efe000-0xf7efefff]
[    0.195436] pci 0000:00:06.0: supports D1 D2
[    0.195444] pci 0000:00:06.0: PME# supported from D2 D3hot D3cold
[    0.195473] pci 0000:00:06.0: PME# disabled
[    0.195909] pci 0000:00:08.0: quirk: region ee00-ee3f claimed by ali7101=
 ACPI
[    0.195941] pci 0000:00:08.0: quirk: region ef00-ef1f claimed by ali7101=
 SMB
[    0.196066] pci 0000:00:0a.0: reg 10 32bit mmio: [0xf7efd000-0xf7efdfff]
[    0.196091] pci 0000:00:0a.0: reg 14 io port: [0xeb40-0xeb7f]
[    0.196116] pci 0000:00:0a.0: reg 18 32bit mmio: [0xf7d00000-0xf7dfffff]
[    0.196210] pci 0000:00:0a.0: supports D1 D2
[    0.196218] pci 0000:00:0a.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.196248] pci 0000:00:0a.0: PME# disabled
[    0.196391] pci 0000:00:10.0: reg 10 32bit mmio: [0x000000-0x000fff]
[    0.196426] pci 0000:00:10.0: supports D1 D2
[    0.196434] pci 0000:00:10.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.196464] pci 0000:00:10.0: PME# disabled
[    0.196725] pci 0000:00:11.0: reg 10 32bit mmio: [0x000000-0x000fff]
[    0.196871] pci 0000:00:11.1: reg 10 32bit mmio: [0x000000-0x000fff]
[    0.197035] pci 0000:00:12.0: reg 10 32bit mmio: [0xf7cffe00-0xf7cfffff]
[    0.197162] pci 0000:00:12.0: supports D1 D2
[    0.197170] pci 0000:00:12.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.197202] pci 0000:00:12.0: PME# disabled
[    0.197413] pci 0000:01:00.0: reg 10 32bit mmio: [0xfc000000-0xfdffffff]
[    0.197438] pci 0000:01:00.0: reg 14 32bit mmio: [0xfbc00000-0xfbffffff]
[    0.197461] pci 0000:01:00.0: reg 18 32bit mmio: [0xf8000000-0xf9ffffff]
[    0.197485] pci 0000:01:00.0: reg 1c 32bit mmio: [0xf7ff8000-0xf7ffffff]
[    0.197536] pci 0000:01:00.0: reg 30 32bit mmio: [0x000000-0x00ffff]
[    0.197574] pci 0000:01:00.0: supports D1 D2
[    0.197726] pci 0000:00:01.0: bridge 32bit mmio: [0xf7f00000-0xfdffffff]
[    0.197949] bus 00 -> node 0
[    0.198001] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.198733] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCI1._PRT]
[    0.236375] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 *11)
[    0.237417] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 *11)
[    0.238326] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 10 *11)
[    0.239230] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 10 *11)
[    0.240250] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 *11)
[    0.241161] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 10 *11)
[    0.242680] ACPI: Power Resource [PFAN] (off)
[    0.245572] PCI: Using ACPI for IRQ routing
[    0.247989] pnp: PnP ACPI init
[    0.247989] ACPI: bus type pnp registered
[    0.274758] pnp: PnP ACPI: found 12 devices
[    0.274816] ACPI: ACPI bus type pnp unregistered
[    0.274938] system 00:00: iomem range 0x0-0x9ffff could not be reserved
[    0.274968] system 00:00: iomem range 0xe0000-0xeffff could not be reser=
ved
[    0.274996] system 00:00: iomem range 0xf0000-0xfffff could not be reser=
ved
[    0.275024] system 00:00: iomem range 0x100000-0x1ef5ffff could not be r=
eserved
[    0.275054] system 00:00: iomem range 0x1ef60000-0x1ef6ffff could not be=
 reserved
[    0.275085] system 00:00: iomem range 0x1f000000-0x1fffffff could not be=
 reserved
[    0.275116] system 00:00: iomem range 0x1ef70000-0x1effffff could not be=
 reserved
[    0.275150] system 00:00: iomem range 0xffe00000-0xffffffff could not be=
 reserved
[    0.275249] system 00:08: ioport range 0x370-0x371 has been reserved
[    0.275276] system 00:08: ioport range 0x40b-0x40b has been reserved
[    0.275302] system 00:08: ioport range 0x480-0x48f has been reserved
[    0.275327] system 00:08: ioport range 0x4d0-0x4d1 has been reserved
[    0.275353] system 00:08: ioport range 0x4d6-0x4d6 has been reserved
[    0.275378] system 00:08: ioport range 0x6c0-0x6ff has been reserved
[    0.275404] system 00:08: ioport range 0xe000-0xe07f has been reserved
[    0.275430] system 00:08: ioport range 0xe080-0xe0ff has been reserved
[    0.275456] system 00:08: ioport range 0xe400-0xe47f has been reserved
[    0.275482] system 00:08: ioport range 0xe480-0xe4ff has been reserved
[    0.275508] system 00:08: ioport range 0xe800-0xe87f has been reserved
[    0.275534] system 00:08: ioport range 0xe880-0xe8ff has been reserved
[    0.275560] system 00:08: ioport range 0xec00-0xec7f has been reserved
[    0.275587] system 00:08: ioport range 0xec80-0xecff has been reserved
[    0.275615] system 00:08: ioport range 0xee00-0xee41 could not be reserv=
ed
[    0.275642] system 00:08: ioport range 0xee90-0xee9f has been reserved
[    0.275668] system 00:08: ioport range 0xeeac-0xeeac has been reserved
[    0.275696] system 00:08: ioport range 0xef00-0xef3f could not be reserv=
ed
[    0.275723] system 00:08: ioport range 0xef40-0xef5f has been reserved
[    0.316315] pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
[    0.316370] pci 0000:00:01.0:   IO window: disabled
[    0.316403] pci 0000:00:01.0:   MEM window: 0xf7f00000-0xfdffffff
[    0.316434] pci 0000:00:01.0:   PREFETCH window: 0x00000048000000-0x0000=
00480fffff
[    0.316481] pci 0000:00:10.0: CardBus bridge, secondary bus 0000:02
[    0.316504] pci 0000:00:10.0:   IO window: 0x001000-0x0010ff
[    0.316533] pci 0000:00:10.0:   IO window: 0x001400-0x0014ff
[    0.316562] pci 0000:00:10.0:   PREFETCH window: 0x30000000-0x33ffffff
[    0.316593] pci 0000:00:10.0:   MEM window: 0x34000000-0x37ffffff
[    0.316624] pci 0000:00:11.0: CardBus bridge, secondary bus 0000:06
[    0.316678] pci 0000:00:11.0:   IO window: 0x001800-0x0018ff
[    0.316709] pci 0000:00:11.0:   IO window: 0x001c00-0x001cff
[    0.316738] pci 0000:00:11.0:   PREFETCH window: 0x38000000-0x3bffffff
[    0.316769] pci 0000:00:11.0:   MEM window: 0x3c000000-0x3fffffff
[    0.316800] pci 0000:00:11.1: CardBus bridge, secondary bus 0000:0a
[    0.316822] pci 0000:00:11.1:   IO window: 0x002000-0x0020ff
[    0.316851] pci 0000:00:11.1:   IO window: 0x002400-0x0024ff
[    0.316880] pci 0000:00:11.1:   PREFETCH window: 0x40000000-0x43ffffff
[    0.316911] pci 0000:00:11.1:   MEM window: 0x44000000-0x47ffffff
[    0.316980] pci 0000:00:01.0: setting latency timer to 64
[    0.317015] pci 0000:00:10.0: enabling device (0000 -> 0003)
[    0.318866] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    0.318895] PCI: setting IRQ 11 as level-triggered
[    0.318909] pci 0000:00:10.0: PCI INT A -> Link[LNKC] -> GSI 11 (level, =
low) -> IRQ 11
[    0.318970] pci 0000:00:11.0: enabling device (0000 -> 0003)
[    0.320462] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 11
[    0.320489] pci 0000:00:11.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, =
low) -> IRQ 11
[    0.320550] pci 0000:00:11.1: enabling device (0000 -> 0003)
[    0.322000] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 11
[    0.322026] pci 0000:00:11.1: PCI INT B -> Link[LNKB] -> GSI 11 (level, =
low) -> IRQ 11
[    0.322075] bus: 00 index 0 io port: [0x00-0xffff]
[    0.322094] bus: 00 index 1 mmio: [0x000000-0xffffffff]
[    0.322113] bus: 01 index 0 mmio: [0x0-0x0]
[    0.322130] bus: 01 index 1 mmio: [0xf7f00000-0xfdffffff]
[    0.322150] bus: 01 index 2 mmio: [0x48000000-0x480fffff]
[    0.322168] bus: 01 index 3 mmio: [0x0-0x0]
[    0.322186] bus: 02 index 0 io port: [0x1000-0x10ff]
[    0.322205] bus: 02 index 1 io port: [0x1400-0x14ff]
[    0.322223] bus: 02 index 2 mmio: [0x30000000-0x33ffffff]
[    0.322242] bus: 02 index 3 mmio: [0x34000000-0x37ffffff]
[    0.322262] bus: 06 index 0 io port: [0x1800-0x18ff]
[    0.322280] bus: 06 index 1 io port: [0x1c00-0x1cff]
[    0.322298] bus: 06 index 2 mmio: [0x38000000-0x3bffffff]
[    0.322317] bus: 06 index 3 mmio: [0x3c000000-0x3fffffff]
[    0.322337] bus: 0a index 0 io port: [0x2000-0x20ff]
[    0.322355] bus: 0a index 1 io port: [0x2400-0x24ff]
[    0.322373] bus: 0a index 2 mmio: [0x40000000-0x43ffffff]
[    0.322393] bus: 0a index 3 mmio: [0x44000000-0x47ffffff]
[    0.322476] NET: Registered protocol family 2
[    0.323535] IP route cache hash table entries: 4096 (order: 2, 16384 byt=
es)
[    0.324682] TCP established hash table entries: 16384 (order: 5, 131072 =
bytes)
[    0.325421] TCP bind hash table entries: 16384 (order: 7, 589824 bytes)
[    0.331441] TCP: Hash tables configured (established 16384 bind 16384)
[    0.331713] TCP reno registered
[    0.332389] NET: Registered protocol family 1
[    0.333862] checking if image is initramfs... it is
[    0.816879] Switched to high resolution mode on CPU 0
[    1.297685] Freeing initrd memory: 3736k freed
[    1.305819] Initializing RT-Tester: OK
[    1.307436] audit: initializing netlink socket (disabled)
[    1.307667] type=3D2000 audit(1225219290.306:1): initialized
[    1.323264] Kprobe smoke test started
[    1.327812] Kprobe smoke test passed successfully
[    1.327929] Testing tracer sched_switch: PASSED
[    1.430671] Testing tracer ftrace: PASSED
[    1.557946] Testing dynamic ftrace: PASSED
[    1.827949] msgmni has been set to 964
[    1.829450] io scheduler noop registered
[    1.829493] io scheduler anticipatory registered
[    1.829513] io scheduler deadline registered
[    1.829641] io scheduler cfq registered (default)
[    1.829927] pci 0000:00:07.0: Activating ISA DMA hang workarounds
[    1.830013] pci 0000:00:0a.0: Firmware left e100 interrupts enabled; dis=
abling
[    1.830227] pci 0000:01:00.0: Boot video device
[    1.833150] vesafb: framebuffer at 0xfc000000, mapped to 0xdf780000, usi=
ng 3072k, total 16384k
[    1.833204] vesafb: mode is 1024x768x16, linelength=3D2048, pages=3D9
[    1.833225] vesafb: protected mode interface info at c000:775e
[    1.833247] vesafb: pmi: set display start =3D c00c777f, set palette =3D=
 c00c77e2
[    1.833269] vesafb: scrolling: redraw
[    1.833290] vesafb: Truecolor: size=3D0:5:6:5, shift=3D0:11:5:0
[    1.901005] Console: switching to colour frame buffer device 128x48
[    1.966818] fb0: VESA VGA frame buffer device
[    2.365503] brd: module loaded
[    2.365954] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
[    2.366968] e100: Copyright(c) 1999-2006 Intel Corporation
[    2.369829] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[    2.370661] e100 0000:00:0a.0: PCI INT A -> Link[LNKD] -> GSI 11 (level,=
 low) -> IRQ 11
[    2.398887] e100 0000:00:0a.0: PME# disabled
[    2.400727] e100: eth0: e100_probe: addr 0xf7efd000, irq 11, MAC addr 00=
:00:39:d7:14:a1
[    2.402144] netconsole: local port 6665
[    2.402630] netconsole: local IP 10.0.0.1
[    2.403128] netconsole: interface eth0
[    2.403676] netconsole: remote port 6666
[    2.404166] netconsole: remote IP 10.0.0.2
[    2.404678] netconsole: remote ethernet address 00:17:42:21:27:e4
[    2.405468] netconsole: device eth0 not up yet, forcing it
[    6.436728] netconsole: timeout waiting for carrier
[    6.439411] console [netcon0] enabled
[   12.089157] Clocksource tsc unstable (delta =3D 4687087476 ns)
[   12.113944] netconsole: network logging started
[   12.138790] PNP: PS/2 Controller [PNP0303:KBC,PNP0f13:PS2M] at 0x60,0x64=
 irq 1,12
[   12.168646] serio: i8042 KBD port at 0x60,0x64 irq 1
[   12.192643] serio: i8042 AUX port at 0x60,0x64 irq 12
[   12.219155] mice: PS/2 mouse device common for all mice
[   12.243590] cpuidle: using governor ladder
[   12.267057] cpuidle: using governor menu
[   12.290370] TCP cubic registered
[   12.313265] Using IPI Shortcut mode
[   12.339472] BIOS EDD facility v0.16 2004-Jun-25, 1 devices found
[   12.365497] Freeing unused kernel memory: 240k freed
[   12.389515] Write protecting the kernel read-only data: 804k
[   12.438783] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input0
[   13.000459] SCSI subsystem initialized
[   13.072363] Driver 'sd' needs updating - please use bus_type methods
[   13.199825] libata version 3.00 loaded.
[   13.241426] pata_ali 0000:00:04.0: can't derive routing for PCI INT A
[   13.266694] scsi0 : pata_ali
[   13.292060] scsi1 : pata_ali
[   13.320025] ata1: PATA max UDMA/66 cmd 0x1f0 ctl 0x3f6 bmdma 0xeff0 irq =
14
[   13.343377] ata2: PATA max UDMA/66 cmd 0x170 ctl 0x376 bmdma 0xeff8 irq =
15
[   13.524307] ata1.00: ATA-5: IC25N020ATDA04-0, DA3OA70A, max UDMA/100
[   13.547347] ata1.00: 39070080 sectors, multi 0: LBA=20
[   13.570174] ata1.00: limited to UDMA/33 due to 40-wire cable
[   13.604141] ata1.00: configured for UDMA/33
[   13.823921] ata2.00: ATAPI: TOSHIBA DVD-ROM SD-C2502, 1313, max UDMA/33
[   13.846515] ata2.00: WARNING: ATAPI DMA disabled for reliablity issues. =
 It can be enabled
[   13.869240] ata2.00: WARNING: via pata_ali.atapi_dma modparam or corresp=
onding sysfs node.
[   13.903874] ata2.00: configured for UDMA/33
[   13.931500] scsi 0:0:0:0: Direct-Access     ATA      IC25N020ATDA04-0 DA=
3O PQ: 0 ANSI: 5
[   13.958177] sd 0:0:0:0: [sda] 39070080 512-byte hardware sectors: (20.0 =
GB/18.6 GiB)
[   13.982852] sd 0:0:0:0: [sda] Write Protect is off
[   14.007087] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[   14.007315] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[   14.034288] sd 0:0:0:0: [sda] 39070080 512-byte hardware sectors: (20.0 =
GB/18.6 GiB)
[   14.059678] sd 0:0:0:0: [sda] Write Protect is off
[   14.084964] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[   14.085270] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[   14.111012]  sda: sda1 sda2
[   14.406085] sd 0:0:0:0: [sda] Attached SCSI disk
[   14.446376] scsi 1:0:0:0: CD-ROM            TOSHIBA  DVD-ROM SD-C2502 13=
13 PQ: 0 ANSI: 5
[   17.308560] ReiserFS: sda2: found reiserfs format "3.6" with standard jo=
urnal
[   17.335282] ReiserFS: sda2: using ordered data mode
[   17.379047] ReiserFS: sda2: journal params: device sda2, size 8192, jour=
nal first block 18, max trans len 1024, max batch 900, max commit age 30, m=
ax trans age 30
[   17.442824] ReiserFS: sda2: checking transaction log (sda2)
[   17.520752] ReiserFS: sda2: Using r5 hash to sort names
[   58.689383] usbcore: registered new interface driver usbfs
[   58.716608] usbcore: registered new interface driver hub
[   58.743242] usbcore: registered new device driver usb
[   65.830582] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   65.832729] ACPI: PCI Interrupt Link [LNKG] enabled at IRQ 11
[   65.832749] ohci_hcd 0000:00:02.0: PCI INT A -> Link[LNKG] -> GSI 11 (le=
vel, low) -> IRQ 11
[   65.832920] ohci_hcd 0000:00:02.0: OHCI Host Controller
[   65.835604] ohci_hcd 0000:00:02.0: new USB bus registered, assigned bus =
number 1
[   65.835734] ohci_hcd 0000:00:02.0: irq 11, io mem 0xf7eff000
[   65.892791] usb usb1: configuration #1 chosen from 1 choice
[   65.893645] hub 1-0:1.0: USB hub found
[   65.893925] hub 1-0:1.0: 3 ports detected
[   66.157858] Linux agpgart interface v0.103
[   66.175761] ACPI Warning (nspredef-0858): \_SB_.BAT1._BIF: Return Packag=
e type mismatch at index 9 - found Buffer, expected String [20080926]
[   66.178279] ACPI: Battery Slot [BAT1] (battery present)
[   66.178625] ACPI: Battery Slot [BAT2] (battery absent)
[   66.254535] input: Power Button (FF) as /devices/LNXSYSTM:00/LNXPWRBN:00=
/input/input1
[   66.273271] ACPI: Power Button (FF) [PWRF]
[   66.274016] input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:=
00/input/input2
[   66.274461] ACPI: Lid Switch [LID]
[   66.292614] ACPI: AC Adapter [ADP1] (off-line)
[   66.347890] ACPI: CPU0 (power states: C1[C1] C2[C2])
[   66.349373] processor ACPI0007:00: registered as cooling_device0
[   66.373496] agpgart-ali 0000:00:00.0: ALi M1644 chipset
[   66.410315] agpgart-ali 0000:00:00.0: AGP aperture is 64M @ 0xf0000000
[   66.439829] thermal LNXTHERM:01: registered as thermal_zone0
[   66.441873] ACPI: Thermal Zone [THRM] (50 C)
[   66.633036] toshiba_acpi: Toshiba Laptop ACPI Extras version 0.19
[   66.633054] toshiba_acpi:     HCI method: \_SB_.VALD.GHCI
[   66.637764] input: Toshiba RFKill Switch as /devices/virtual/input/input3
[   66.752678] input: Video Bus as /devices/LNXSYSTM:00/device:00/PNP0A03:0=
0/device:14/device:15/input/input4
[   66.778071] ACPI: Video Device [VGA] (multi-head: yes  rom: yes  post: n=
o)
[   66.809622] sd 0:0:0:0: Attached scsi generic sg0 type 0
[   66.809996] scsi 1:0:0:0: Attached scsi generic sg1 type 5
[   66.819296] ACPI: Transitioning device [FAN] to D3
[   66.819594] fan PNP0C0B:00: registered as cooling_device1
[   66.819630] ACPI: Fan [FAN] (off)
[   67.124073] pci 0000:00:08.0: enabling device (0000 -> 0001)
[   67.130246] ALi_M1535: initialized. timeout=3D60 sec (nowayout=3D0)
[   67.244036] Driver 'sr' needs updating - please use bus_type methods
[   67.307413] sr0: scsi3-mmc drive: 24x/24x cd/rw xa/form2 cdda tray
[   67.307439] Uniform CD-ROM driver Revision: 3.20
[   67.308855] sr 1:0:0:0: Attached scsi CD-ROM sr0
[   67.699473] input: PC Speaker as /devices/platform/pcspkr/input/input5
[   68.191660] input: ImPS/2 Generic Wheel Mouse as /devices/platform/i8042=
/serio1/input/input6
[   68.435651] yenta_cardbus 0000:00:10.0: CardBus bridge found [12a3:ab01]
[   68.563839] yenta_cardbus 0000:00:10.0: ISA IRQ mask 0x0000, PCI irq 11
[   68.563857] yenta_cardbus 0000:00:10.0: Socket status: 30000011
[   68.567481] yenta_cardbus 0000:00:11.0: CardBus bridge found [1179:0001]
[   68.696068] yenta_cardbus 0000:00:11.0: ISA IRQ mask 0x04b8, PCI irq 11
[   68.696086] yenta_cardbus 0000:00:11.0: Socket status: 30000007
[   68.701499] yenta_cardbus 0000:00:11.1: CardBus bridge found [1179:0001]
[   68.839726] yenta_cardbus 0000:00:11.1: ISA IRQ mask 0x04b8, PCI irq 11
[   68.839745] yenta_cardbus 0000:00:11.1: Socket status: 30000007
[   69.210160] pcmcia_socket pcmcia_socket0: pccard: PCMCIA card inserted i=
nto slot 0
[   70.137343] NET: Registered protocol family 23
[   70.147647] rtc_cmos 00:07: RTC can wake from S4
[   70.149723] rtc_cmos 00:07: rtc core: registered rtc_cmos as rtc0
[   70.149824] rtc0: alarms up to one year, 114 bytes nvram,  irqs
[   71.705464] Detected unconfigured Toshiba laptop with ALi ISA bridge SMS=
C IrDA chip, pre-configuring device.
[   71.705503] Activated ALi 1533 ISA bridge port 0x02e8.
[   71.705521] Activated ALi 1533 ISA bridge port 0x02f8.
[   71.705777] found SMC SuperIO Chip (devid=3D0x5a rev=3D00 base=3D0x002e)=
: LPC47N227
[   71.705793] smsc_superio_flat(): IrDA not enabled
[   71.705822] smsc_superio_flat(): fir: 0x2f8, sir: 0x2e8, dma: 03, irq: 7=
, mode: 0x02
[   71.705864] SMsC IrDA Controller found
[   71.705868]  IrCC version 2.0, firport 0x2f8, sirport 0x2e8 dma=3D3, irq=
=3D7
[   71.706080] No transceiver found. Defaulting to Fast pin select
[   71.707223] IrDA: Registered device irda0
[   72.873489] ALI 5451 0000:00:06.0: power state changed by ACPI to D0
[   72.875203] ACPI: PCI Interrupt Link [LNKH] enabled at IRQ 11
[   72.875222] ALI 5451 0000:00:06.0: PCI INT A -> Link[LNKH] -> GSI 11 (le=
vel, low) -> IRQ 11
[   77.653084] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x100-0x3af:=
 excluding 0x200-0x207 0x220-0x22f 0x330-0x337 0x388-0x38f
[   77.656956] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x3e0-0x4ff:=
 clean.
[   77.658657] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x820-0x8ff:=
 clean.
[   77.660096] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xc00-0xcf7:=
 clean.
[   77.662822] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xa00-0xaff:=
 clean.
[   77.673981] pcmcia_socket pcmcia_socket2: cs: IO port probe 0x100-0x3af:=
 excluding 0x200-0x207 0x220-0x22f 0x330-0x337 0x388-0x38f
[   77.677823] pcmcia_socket pcmcia_socket2: cs: IO port probe 0x3e0-0x4ff:=
 clean.
[   77.679542] pcmcia_socket pcmcia_socket2: cs: IO port probe 0x820-0x8ff:=
 clean.
[   77.680960] pcmcia_socket pcmcia_socket2: cs: IO port probe 0xc00-0xcf7:=
 clean.
[   77.683902] pcmcia_socket pcmcia_socket2: cs: IO port probe 0xa00-0xaff:=
 clean.
[   77.895977] pcmcia_socket pcmcia_socket0: cs: memory probe 0xa0000000-0x=
a0ffffff: clean.
[   77.923510] pcmcia 0.0: pcmcia: registering new device pcmcia0.0
[   78.436032] pcmcia_socket pcmcia_socket1: cs: IO port probe 0x100-0x3af:=
 excluding 0x200-0x207 0x220-0x22f 0x330-0x337 0x388-0x38f
[   78.439493] pcmcia_socket pcmcia_socket1: cs: IO port probe 0x3e0-0x4ff:=
 clean.
[   78.441049] pcmcia_socket pcmcia_socket1: cs: IO port probe 0x820-0x8ff:=
 clean.
[   78.442885] pcmcia_socket pcmcia_socket1: cs: IO port probe 0xc00-0xcf7:=
 clean.
[   78.445616] pcmcia_socket pcmcia_socket1: cs: IO port probe 0xa00-0xaff:=
 clean.
[   79.088297] Marking TSC unstable due to TSC halts in idle
[   79.337105] orinoco 0.15 (David Gibson <hermes@gibson.dropbear.id.au>, P=
avel Roskin <proski@gnu.org>, et al)
[   79.447146] orinoco_cs 0.15 (David Gibson <hermes@gibson.dropbear.id.au>=
, Pavel Roskin <proski@gnu.org>, et al)
[   79.534977] eth1: Hardware identity 0005:0002:0001:0002
[   79.535112] eth1: Station identity  001f:0001:0006:000e
[   79.535124] eth1: Firmware determined as Lucent/Agere 6.14
[   79.535145] eth1: Attempting to download firmware agere_sta_fw.bin
[   79.535175] hermes_dld: AUX enable returned 0
[   79.536181] hermes_dld: AUX disable returned 0
[   79.536189] hermes_dld: Actual PDA length 998, Max allowed 1000
[   79.536197] eth1: Read PDA returned 0
[   79.536210] orinoco_cs 0.0: firmware: requesting agere_sta_fw.bin
[   79.746491] hermes_dld: AUX enable returned 0
[   79.746506] hermes_dld: Enabling volatile, EP 0x000f8000
[   79.747612] hermes_dld: PROGRAM_ENABLE returned 0
[   79.747621] eth1: Program init returned 0
[   79.747630] hermes_dld: Programming block of length 60416 to address 0x0=
01f0000
[   79.795998] hermes_dld: Programming block of length 4096 to address 0x00=
1ef000
[   79.799287] eth1: Program returned 0
[   79.799298] hermes_dld: Found record 0x0003 at de7edc1c
[   79.799319] hermes_dld: Found record 0x0005 at de7edca8
[   79.799339] hermes_dld: Found record 0x0008 at de7edcd2
[   79.799356] hermes_dld: Found record 0x0007 at de7edcc4
[   79.799374] hermes_dld: Found record 0x0006 at de7edcb6
[   79.799394] hermes_dld: Found record 0x0110 at de7edd9a
[   79.799428] hermes_dld: Found record 0x0120 at de7eddba
[   79.799461] hermes_dld: Found record 0x0130 at de7eddda
[   79.799494] hermes_dld: Found record 0x0140 at de7eddfa
[   79.799508] hermes_dld: Found record 0x0150 at de7ede02
[   79.799521] hermes_dld: Using default record 0x0160 at dfb6bba0
[   79.799554] hermes_dld: Found record 0x0101 at de7edd46
[   79.799569] hermes_dld: Found record 0x0103 at de7edd5c
[   79.799589] hermes_dld: Found record 0x0104 at de7edd6c
[   79.799601] hermes_dld: Found record 0x0105 at de7edd72
[   79.799614] hermes_dld: Found record 0x0105 at de7edd72
[   79.799626] hermes_dld: Found record 0x0105 at de7edd72
[   79.799638] hermes_dld: Found record 0x0107 at de7edd7e
[   79.799650] hermes_dld: Found record 0x0109 at de7edd8c
[   79.799669] hermes_dld: Using default record 0x0161 at dfb6bbc0
[   79.799884] eth1: Apply PDA returned 0
[   79.799949] hermes_dld: PROGRAM_DISABLE returned 0, r0 0x0000, r1 0x0000=
, r2 0x0000
[   79.799978] hermes_dld: AUX disable returned 0
[   79.810623] eth1: Program end returned 0
[   79.810632] eth1: hermes_present returned 1
[   79.811441] eth1: Hardware identity 0005:0002:0001:0002
[   79.811568] eth1: Station identity  001f:0002:0009:0030
[   79.811579] eth1: Firmware determined as Lucent/Agere 9.48
[   79.811588] eth1: Ad-hoc demo mode supported
[   79.811595] eth1: IEEE standard IBSS ad-hoc mode supported
[   79.811603] eth1: WEP supported, 104-bit key
[   79.811611] eth1: WPA-PSK supported
[   80.239692] eth1: MAC address 00:02:2d:26:95:6c
[   80.239806] eth1: Station name "HERMES I"
[   80.240628] eth1: ready
[   80.241525] eth1: orinoco_cs at 0.0, irq 11, io 0x0100-0x013f
[   80.571111] Toshiba System Management Mode driver v1.11 26/9/2001
[   80.661544] Non-volatile memory driver v1.2
[   81.413572] Uniform Multi-Platform E-IDE driver
[   81.757503] device-mapper: uevent: version 1.0.3
[   81.771200] device-mapper: ioctl: 4.14.0-ioctl (2008-04-23) initialised:=
 dm-devel@redhat.com
[   82.010372] device-mapper: multipath: version 1.0.5 loaded
[   82.658252] device-mapper: multipath round-robin: version 1.0.0 loaded
[   82.659755] device-mapper: table: 254:0: multipath: error getting device
[   82.659774] device-mapper: ioctl: error adding target to table
[   88.083938] loop: module loaded
[   91.341947] Adding 500432k swap on /dev/sda1.  Priority:-1 extents:1 acr=
oss:500432k
[   99.250075] IrCOMM protocol (Dag Brattli)
[  100.840075] PPP generic driver version 2.4.2
[  110.709496] NET: Registered protocol family 17
[  113.920753] ------------[ cut here ]------------
[  113.920828] kernel BUG at /home/bor/src/linux-git/net/rfkill/rfkill.c:34=
7!
[  113.920845] invalid opcode: 0000 [#1]=20
[  113.920877] last sysfs file: /sys/devices/pci0000:00/0000:00:04.0/host0/=
target0:0:0/0:0:0:0/block/sda/size
[  113.920900] Dumping ftrace buffer:
[  113.920919]    (ftrace buffer empty)
[  113.920933] Modules linked in: af_packet irnet ppp_generic slhc ircomm_t=
ty ircomm binfmt_misc loop dm_mirror dm_region_hash dm_log dm_round_robin d=
m_multipath dm_mod alim15x3 ide_core nvram toshiba cryptomgr aead crypto_bl=
kcipher michael_mic crypto_algapi orinoco_cs orinoco hermes_dld hermes pcmc=
ia firmware_class snd_ali5451 snd_ac97_codec ac97_bus snd_seq_dummy snd_seq=
_oss snd_seq_midi_event snd_seq snd_seq_device smsc_ircc2 snd_pcm_oss snd_p=
cm rtc_cmos irda snd_timer snd_mixer_oss rtc_core snd crc_ccitt yenta_socke=
t rtc_lib rsrc_nonstatic i2c_ali1535 pcmcia_core pcspkr psmouse soundcore i=
2c_core evdev sr_mod snd_page_alloc alim1535_wdt cdrom fan sg video output =
toshiba_acpi rfkill thermal backlight ali_agp processor ac button input_pol=
ldev battery agpgart ohci_hcd usbcore reiserfs pata_ali libata sd_mod scsi_=
mod [last unloaded: scsi_wait_scan]
[  113.921765]=20
[  113.921785] Pid: 3272, comm: ipolldevd Not tainted (2.6.28-rc2-1avb #3) =
PORTEGE 4000
[  113.921801] EIP: 0060:[<dfaa4683>] EFLAGS: 00010246 CPU: 0
[  113.921854] EIP is at rfkill_force_state+0x53/0x90 [rfkill]
[  113.921870] EAX: 00000000 EBX: 00000000 ECX: 00000003 EDX: 00000000
[  113.921885] ESI: 00000000 EDI: ddd50300 EBP: d8d7af40 ESP: d8d7af24
[  113.921900]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[  113.921918] Process ipolldevd (pid: 3272, ti=3Dd8d7a000 task=3Dd8d93c90 =
task.ti=3Dd8d7a000)
[  113.921933] Stack:
[  113.921945]  d8d7af38 00000246 dfb029d8 dfb029c0 dfb029d8 dfb029c0 ddd50=
300 d8d7af5c
[  113.922014]  dfb018e2 01000246 01000000 ddd50300 ddd50314 ddabb8a0 d8d7a=
f68 dfb381c1
[  113.922098]  00000000 d8d7afa4 c012ec0a 00000000 00000002 00000000 c012e=
ba8 ddabb8c0
[  113.922240] Call Trace:
[  113.922240]  [<dfb018e2>] ? bt_poll_rfkill+0x5c/0x82 [toshiba_acpi]
[  113.922240]  [<dfb381c1>] ? input_polled_device_work+0x11/0x40 [input_po=
lldev]
[  113.922240]  [<c012ec0a>] ? run_workqueue+0xea/0x1f0
[  113.922240]  [<c012eba8>] ? run_workqueue+0x88/0x1f0
[  113.922240]  [<dfb381b0>] ? input_polled_device_work+0x0/0x40 [input_pol=
ldev]
[  113.922240]  [<c012f047>] ? worker_thread+0x87/0xf0
[  113.922240]  [<c0132b00>] ? autoremove_wake_function+0x0/0x50
[  113.922240]  [<c012efc0>] ? worker_thread+0x0/0xf0
[  113.922240]  [<c013280f>] ? kthread+0x3f/0x80
[  113.922240]  [<c01327d0>] ? kthread+0x0/0x80
[  113.922240]  [<c01040d7>] ? kernel_thread_helper+0x7/0x10
[  113.922240] Code: 43 54 89 73 54 39 c6 74 11 89 d9 ba 01 00 00 00 b8 40 =
68 aa df e8 3e 35 69 e0 89 f8 e8 77 fd 85 e0 31 c0 83 c4 10 5b 5e 5f 5d c3 =
<0f> 0b eb fe 89 f6 8d bc 27 00 00 00 00 be f4 4d aa df bb 5f 01=20
[  113.922240] EIP: [<dfaa4683>] rfkill_force_state+0x53/0x90 [rfkill] SS:E=
SP 0068:d8d7af24
[  113.924700] ---[ end trace 0e404eb40cadd5f0 ]---
[  116.418566] eth1: Lucent/Agere firmware doesn't support manual roaming
[  116.537421] eth1: New link status: Connected (0001)
[  615.868633] PM: Syncing filesystems ... done.
[  615.892089] Freezing user space processes ... (elapsed 0.00 seconds) don=
e.
[  615.897615] Freezing remaining freezable tasks ... (elapsed 0.00 seconds=
) done.
[  615.898275] Suspending console(s) (use no_console_suspend to debug)
[  615.903562] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[  616.430846] sd 0:0:0:0: [sda] Stopping disk
[  617.125438] e100 0000:00:0a.0: PCI INT A disabled
[  617.182023] ALI 5451 0000:00:06.0: PCI INT A disabled
[  617.193773] ALI 5451 0000:00:06.0: power state changed by ACPI to D3
[  617.950832] pata_ali 0000:00:04.0: can't derive routing for PCI INT A
[  617.960140] ohci_hcd 0000:00:02.0: PCI INT A disabled
[  617.975868] ACPI: Preparing to enter system sleep state S3
[  617.975868] Back to C!
[  617.987166] ACPI: Waking up from system sleep state S3
[  618.004377] pci 0000:00:01.0: setting latency timer to 64
[  618.013412] ohci_hcd 0000:00:02.0: PCI INT A -> Link[LNKG] -> GSI 11 (le=
vel, low) -> IRQ 11
[  618.013443] ohci_hcd 0000:00:02.0: restoring config space at offset 0xf =
(was 0x500001ff, writing 0x5000010b)
[  618.068722] usb usb1: root hub lost power or was reset
[  618.080082] pata_ali 0000:00:04.0: restoring config space at offset 0x1 =
(was 0x2900001, writing 0x2900005)
[  618.080120] pata_ali 0000:00:04.0: can't derive routing for PCI INT A
[  618.080520] ALI 5451 0000:00:06.0: power state changed by ACPI to D0
[  618.080545] ALI 5451 0000:00:06.0: restoring config space at offset 0xf =
(was 0x180201ff, writing 0x1802010b)
[  618.080729] ALI 5451 0000:00:06.0: power state changed by ACPI to D0
[  618.080753] ALI 5451 0000:00:06.0: PCI INT A -> Link[LNKH] -> GSI 11 (le=
vel, low) -> IRQ 11
[  618.371841] ali1535_smbus 0000:00:08.0: enabling device (0000 -> 0001)
[  618.383387] e100 0000:00:0a.0: restoring config space at offset 0xf (was=
 0x380801ff, writing 0x3808010b)
[  618.383431] e100 0000:00:0a.0: restoring config space at offset 0x1 (was=
 0x2900003, writing 0x2900007)
[  618.410301] yenta_cardbus 0000:00:10.0: restoring config space at offset=
 0x6 (was 0x50200, writing 0xb0050200)
[  618.660820] ata2.00: ACPI cmd ef/03:0c:00:00:00:00 filtered out
[  618.660830] ata2.00: ACPI cmd ef/03:42:00:00:00:00 filtered out
[  618.667319] ata2.00: configured for UDMA/33
[  619.323782] pcmcia 0.0: pcmcia: registering new device pcmcia0.0
[  619.404234] eth1: Hardware identity 0005:0002:0001:0002
[  619.404345] eth1: Station identity  001f:0001:0006:000e
[  619.404356] eth1: Firmware determined as Lucent/Agere 6.14
[  619.404369] eth1: Attempting to download firmware agere_sta_fw.bin
[  619.404398] hermes_dld: AUX enable returned 0
[  619.405440] hermes_dld: AUX disable returned 0
[  619.405448] hermes_dld: Actual PDA length 998, Max allowed 1000
[  619.405454] eth1: Read PDA returned 0
[  619.405464] orinoco_cs 0.0: firmware: requesting agere_sta_fw.bin
[  620.257118] ata1.00: ACPI cmd ef/03:0c:00:00:00:00 filtered out
[  620.257128] ata1.00: ACPI cmd ef/03:44:00:00:00:00 filtered out
[  620.272387] ata1.00: configured for UDMA/33
[  620.272634] sd 0:0:0:0: [sda] 39070080 512-byte hardware sectors: (20.0 =
GB/18.6 GiB)
[  620.272723] sd 0:0:0:0: [sda] Write Protect is off
[  620.272733] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[  620.272861] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[  679.403515] eth1: Cannot find firmware agere_sta_fw.bin
[  679.403593] eth1: Hardware identity 0005:0002:0001:0002
[  679.403704] eth1: Station identity  001f:0001:0006:000e
[  679.403714] eth1: Firmware determined as Lucent/Agere 6.14
[  679.403721] eth1: Ad-hoc demo mode supported
[  679.403727] eth1: IEEE standard IBSS ad-hoc mode supported
[  679.403733] eth1: WEP supported, 104-bit key
[  679.403856] eth1: MAC address 00:02:2d:26:95:6c
[  679.403962] eth1: Station name "HERMES I"
[  679.404529] eth1: ready
[  679.405117] eth1: orinoco_cs at 0.0, irq 11, io 0x0100-0x013f
[  679.676707] pci 0000:00:12.0: restoring config space at offset 0xf (was =
0x1ff, writing 0x10b)
[  679.676785] pci 0000:01:00.0: restoring config space at offset 0xf (was =
0x1ff, writing 0x10b)
[  679.680310] sd 0:0:0:0: [sda] Starting disk
[  680.109195] Restarting tasks ... done.
[  681.184812] eth1: New link status: Disconnected (0002)
[  688.967595] eth1: New link status: Disconnected (0002)
[  936.423228] pcmcia_socket pcmcia_socket0: pccard: card ejected from slot=
 0
[  941.890025] pcmcia_socket pcmcia_socket0: pccard: PCMCIA card inserted i=
nto slot 0
[  941.890557] pcmcia 0.0: pcmcia: registering new device pcmcia0.0
[  941.975842] eth1: Hardware identity 0005:0002:0001:0002
[  941.976011] eth1: Station identity  001f:0001:0006:000e
[  941.976032] eth1: Firmware determined as Lucent/Agere 6.14
[  941.976061] eth1: Attempting to download firmware agere_sta_fw.bin
[  941.976104] hermes_dld: AUX enable returned 0
[  941.977202] hermes_dld: AUX disable returned 0
[  941.977217] hermes_dld: Actual PDA length 998, Max allowed 1000
[  941.977231] eth1: Read PDA returned 0
[  941.977251] orinoco_cs 0.0: firmware: requesting agere_sta_fw.bin
[  942.100296] hermes_dld: AUX enable returned 0
[  942.100349] hermes_dld: Enabling volatile, EP 0x000f8000
[  942.101404] hermes_dld: PROGRAM_ENABLE returned 0
[  942.101418] eth1: Program init returned 0
[  942.101435] hermes_dld: Programming block of length 60416 to address 0x0=
01f0000
[  942.149611] hermes_dld: Programming block of length 4096 to address 0x00=
1ef000
[  942.152939] eth1: Program returned 0
[  942.152959] hermes_dld: Found record 0x0003 at d8fba41c
[  942.152992] hermes_dld: Found record 0x0005 at d8fba4a8
[  942.153024] hermes_dld: Found record 0x0008 at d8fba4d2
[  942.153052] hermes_dld: Found record 0x0007 at d8fba4c4
[  942.153083] hermes_dld: Found record 0x0006 at d8fba4b6
[  942.153116] hermes_dld: Found record 0x0110 at d8fba59a
[  942.153161] hermes_dld: Found record 0x0120 at d8fba5ba
[  942.153213] hermes_dld: Found record 0x0130 at d8fba5da
[  942.153259] hermes_dld: Found record 0x0140 at d8fba5fa
[  942.153282] hermes_dld: Found record 0x0150 at d8fba602
[  942.153306] hermes_dld: Using default record 0x0160 at dfb6bba0
[  942.153352] hermes_dld: Found record 0x0101 at d8fba546
[  942.153378] hermes_dld: Found record 0x0103 at d8fba55c
[  942.153412] hermes_dld: Found record 0x0104 at d8fba56c
[  942.153434] hermes_dld: Found record 0x0105 at d8fba572
[  942.153454] hermes_dld: Found record 0x0105 at d8fba572
[  942.153528] hermes_dld: Found record 0x0105 at d8fba572
[  942.153549] hermes_dld: Found record 0x0107 at d8fba57e
[  942.153570] hermes_dld: Found record 0x0109 at d8fba58c
[  942.153600] hermes_dld: Using default record 0x0161 at dfb6bbc0
[  942.153864] eth1: Apply PDA returned 0
[  942.153937] hermes_dld: PROGRAM_DISABLE returned 0, r0 0x0000, r1 0x0000=
, r2 0x0000
[  942.153977] hermes_dld: AUX disable returned 0
[  942.164622] eth1: Program end returned 0
[  942.164639] eth1: hermes_present returned 1
[  942.165445] eth1: Hardware identity 0005:0002:0001:0002
[  942.165585] eth1: Station identity  001f:0002:0009:0030
[  942.165602] eth1: Firmware determined as Lucent/Agere 9.48
[  942.165616] eth1: Ad-hoc demo mode supported
[  942.165630] eth1: IEEE standard IBSS ad-hoc mode supported
[  942.165643] eth1: WEP supported, 104-bit key
[  942.165666] eth1: WPA-PSK supported
[  942.186555] eth1: MAC address 00:02:2d:26:95:6c
[  942.186718] eth1: Station name "HERMES I"
[  942.187421] eth1: ready
[  942.188176] eth1: orinoco_cs at 0.0, irq 11, io 0x0100-0x013f
[  943.256450] eth1: Lucent/Agere firmware doesn't support manual roaming
[  943.428503] eth1: New link status: Connected (0001)

--nextPart8283831.roZQjrUZeO
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkkHY60ACgkQR6LMutpd94xq2ACcDOALXPp93wh18HYxzPwavPCe
wsYAnRrzni1sbRn/URtDukouXzROuO8R
=uyjG
-----END PGP SIGNATURE-----

--nextPart8283831.roZQjrUZeO--
