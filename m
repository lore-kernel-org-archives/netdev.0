From: =?UTF-8?B?TsOpbWV0aCBNw6FydG9u?= <nm127@freemail.hu>
Subject: 2.6.34-rc3: eth0 (8139too): transmit queue 0 timed out
Date: Sat, 10 Apr 2010 14:33:38 +0200
Message-ID: <4BC07022.6000708@freemail.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030007030504050405020609"
Cc: LKML <linux-kernel@vger.kernel.org>
To: Network Development <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030007030504050405020609
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Hi,

I tried the Linux kernel 2.6.34-rc3 on my laptop. The network connection
is not working with this kernel version, but works for example with 2.6.32.
I used the attaced .config to compile the kernel.

Here is the full dmesg:

[    0.000000] Linux version 2.6.34-rc3 (nmarci@europa) (gcc version 4.4.3 20100108 (prerelease) (Debian 4.4.2-9) ) #1 PREEMPT Sat Apr 10 09:54:21 CEST 2010
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000d8000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000003bf70000 (usable)
[    0.000000]  BIOS-e820: 000000003bf70000 - 000000003bf7a000 (ACPI data)
[    0.000000]  BIOS-e820: 000000003bf7a000 - 000000003bf80000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000003bf80000 - 0000000040000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fffe0000 - 0000000100000000 (reserved)
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: non-PAE kernel!
[    0.000000] DMI present.
[    0.000000] e820 update range: 0000000000000000 - 0000000000001000 (usable) ==> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
[    0.000000] last_pfn = 0x3bf70 max_arch_pfn = 0x100000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-D3FFF write-protect
[    0.000000]   D4000-D7FFF uncachable
[    0.000000]   D8000-DBFFF write-protect
[    0.000000]   DC000-DFFFF write-back
[    0.000000]   E0000-E3FFF uncachable
[    0.000000]   E4000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0000000000 mask FFC0000000 write-back
[    0.000000]   1 base 003C000000 mask FFFC000000 uncachable
[    0.000000]   2 base 00E0000000 mask FFF0000000 write-combining
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] initial memory mapped : 0 - 01000000
[    0.000000] found SMP MP-table at [c00f6870] f6870
[    0.000000] init_memory_mapping: 0000000000000000-00000000377fe000
[    0.000000]  0000000000 - 0000400000 page 4k
[    0.000000]  0000400000 - 0037400000 page 2M
[    0.000000]  0037400000 - 00377fe000 page 4k
[    0.000000] kernel direct mapping tables up to 377fe000 @ 7000-c000
[    0.000000] 71MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 0 - 377fe000
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000001 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x000377fe
[    0.000000]   HighMem  0x000377fe -> 0x0003bf70
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000001 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0003bf70
[    0.000000] On node 0 totalpages: 245518
[    0.000000] free_area_init_node: node 0, pgdat c068fc40, node_mem_map c1001020
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3966 pages, LIFO batch:0
[    0.000000]   Normal zone: 1744 pages used for memmap
[    0.000000]   Normal zone: 221486 pages, LIFO batch:31
[    0.000000]   HighMem zone: 143 pages used for memmap
[    0.000000]   HighMem zone: 18147 pages, LIFO batch:3
[    0.000000] Using APIC driver default
[    0.000000] Intel MultiProcessor Specification v1.4
[    0.000000]     Virtual Wire compatibility mode.
[    0.000000] MPTABLE: OEM ID:
[    0.000000] MPTABLE: Product ID:
[    0.000000] MPTABLE: APIC at: 0xFEE00000
[    0.000000] Processor #0 (Bootup-CPU)
[    0.000000] I/O APIC #1 Version 3 at 0xFEC00000.
[    0.000000] Processors: 1
[    0.000000] nr_irqs_gsi: 24
[    0.000000] Allocating PCI resources starting at 40000000 (gap: 40000000:bffe0000)
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 243599
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/2.6.34-rc3/bzImage root=/dev/hda1 ro log_buf_len=1M
[    0.000000] early_res array is doubled to 64 at [1000 - 17ff]
[    0.000000] log_buf_len: 1048576
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] Subtract (33 early reservations)
[    0.000000]   #1 [0000100000 - 0000dd5e08]   TEXT DATA BSS
[    0.000000]   #2 [0000dd6000 - 0000dda118]             BRK
[    0.000000]   #3 [00000f6880 - 0000100000]   BIOS reserved
[    0.000000]   #4 [00000f6870 - 00000f6880]    MP-table mpf
[    0.000000]   #5 [000009f800 - 000009fd70]   BIOS reserved
[    0.000000]   #6 [000009fe90 - 00000f6870]   BIOS reserved
[    0.000000]   #7 [000009fd70 - 000009fe90]    MP-table mpc
[    0.000000]   #8 [0000007000 - 0000008000]         PGTABLE
[    0.000000]   #9 [0001000000 - 0001001000]         BOOTMEM
[    0.000000]   #10 [0001001000 - 0001781000]         BOOTMEM
[    0.000000]   #11 [0001781000 - 0001781004]         BOOTMEM
[    0.000000]   #12 [0001781040 - 0001781280]         BOOTMEM
[    0.000000]   #13 [0001781280 - 00017812d4]         BOOTMEM
[    0.000000]   #14 [0001781300 - 000178a300]         BOOTMEM
[    0.000000]   #15 [000178a300 - 000178a308]         BOOTMEM
[    0.000000]   #16 [000178a340 - 000178b540]         BOOTMEM
[    0.000000]   #17 [000178b540 - 000178b567]         BOOTMEM
[    0.000000]   #18 [000178b580 - 000178b67c]         BOOTMEM
[    0.000000]   #19 [000178b680 - 000178b6c0]         BOOTMEM
[    0.000000]   #20 [000178b6c0 - 000178b700]         BOOTMEM
[    0.000000]   #21 [000178b700 - 000178b740]         BOOTMEM
[    0.000000]   #22 [000178b740 - 000178b780]         BOOTMEM
[    0.000000]   #23 [000178b780 - 000178b7c0]         BOOTMEM
[    0.000000]   #24 [000178b7c0 - 000178b800]         BOOTMEM
[    0.000000]   #25 [000178b800 - 000178b840]         BOOTMEM
[    0.000000]   #26 [000178b840 - 000178b880]         BOOTMEM
[    0.000000]   #27 [000178b880 - 000178b8c5]         BOOTMEM
[    0.000000]   #28 [000178b900 - 000178b945]         BOOTMEM
[    0.000000]   #29 [000178b980 - 000188b980]         BOOTMEM
[    0.000000]   #30 [000188b980 - 000188f980]         BOOTMEM
[    0.000000]   #31 [000188f980 - 000190f980]         BOOTMEM
[    0.000000]   #32 [000190f980 - 000194f980]         BOOTMEM
[    0.000000] Initializing HighMem for node 0 (000377fe:0003bf70)
[    0.000000] Memory: 959368k/982464k available (4366k kernel code, 22704k reserved, 1340k data, 484k init, 73160k highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfffa5000 - 0xfffff000   ( 360 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.000000]       .init : 0xc0693000 - 0xc070c000   ( 484 kB)
[    0.000000]       .data : 0xc05438be - 0xc0692938   (1340 kB)
[    0.000000]       .text : 0xc0100000 - 0xc05438be   (4366 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000] NR_IRQS:288
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 3567 kB
[    0.000000]  per task-struct memory footprint: 1152 bytes
[    0.000000] ODEBUG: 4 of 4 active objects replaced
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 1603.926 MHz processor.
[    0.002064] Calibrating delay loop (skipped), value calculated using timer frequency.. 3207.85 BogoMIPS (lpj=1603926)
[    0.004402] Mount-cache hash table entries: 512
[    0.010271] mce: CPU supports 5 MCE banks
[    0.010396] Performance Events: AMD PMU driver.
[    0.010534] ... version:                0
[    0.010592] ... bit width:              48
[    0.010650] ... generic registers:      4
[    0.010709] ... value mask:             0000ffffffffffff
[    0.010769] ... max period:             00007fffffffffff
[    0.010829] ... fixed-purpose events:   0
[    0.010887] ... event mask:             000000000000000f
[    0.010948] CPU: Mobile AMD Sempron(tm) Processor 2600+ stepping 00
[    0.011163] Checking 'hlt' instruction... OK.
[    0.017299] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.018392] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=0 pin2=0
[    0.137327] gcov: version magic: 0x34303470
[    0.140576] NET: Registered protocol family 16
[    0.148752] EISA bus registered
[    0.148834] node 0 link 0: io port [1000, fffff]
[    0.148841] TOM: 0000000040000000 aka 1024M
[    0.148902] node 0 link 0: mmio [40000000, d100ffff]
[    0.148908] node 0 link 0: mmio [d1000000, d200ffff]
[    0.148913] node 0 link 0: mmio [d2000000, f000ffff]
[    0.148919] node 0 link 0: mmio [f0000000, f400ffff]
[    0.148924] node 0 link 0: mmio [f4000000, fe0bffff]
[    0.148930] node 0 link 0: mmio [a0000, bffff]
[    0.148936] bus: [00, ff] on node 0 link 0
[    0.148943] bus: 00 index 0 [io  0x0000-0xffff]
[    0.148948] bus: 00 index 1 [mem 0x40000000-0xffffffff]
[    0.148952] bus: 00 index 2 [mem 0x000a0000-0x000bffff]
[    0.160347] PCI: PCI BIOS revision 2.10 entry at 0xfd88c, last bus=1
[    0.160424] PCI: Using configuration type 1 for base access
[    0.199368] bio: create slab <bio-0> at 0
[    0.204678] vgaarb: loaded
[    0.209088] PCI: Probing PCI hardware
[    0.209236] PCI: Probing PCI hardware (bus 00)
[    0.210852] pci 0000:00:00.0: reg 10: [mem 0xe0000000-0xefffffff pref]
[    0.211741] pci 0000:00:01.0: supports D1
[    0.211842] pci 0000:00:08.0: reg 10: [io  0x1000-0x10ff]
[    0.211855] pci 0000:00:08.0: reg 14: [mem 0xd0004000-0xd00040ff]
[    0.211919] pci 0000:00:08.0: supports D1 D2
[    0.211924] pci 0000:00:08.0: PME# supported from D1 D2 D3hot D3cold
[    0.211933] pci 0000:00:08.0: PME# disabled
[    0.212050] pci 0000:00:0c.0: reg 10: [mem 0x00000000-0x00000fff]
[    0.212082] pci 0000:00:0c.0: supports D1 D2
[    0.212086] pci 0000:00:0c.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.212094] pci 0000:00:0c.0: PME# disabled
[    0.212182] pci 0000:00:0e.0: reg 10: [mem 0xd0001000-0xd0001fff]
[    0.212194] pci 0000:00:0e.0: reg 14: [mem 0xd0000000-0xd0000fff]
[    0.212258] pci 0000:00:0e.0: supports D1 D2
[    0.212262] pci 0000:00:0e.0: PME# supported from D1 D2 D3hot D3cold
[    0.212270] pci 0000:00:0e.0: PME# disabled
[    0.212367] pci 0000:00:0e.1: reg 10: [mem 0xd0003000-0xd0003fff]
[    0.212379] pci 0000:00:0e.1: reg 14: [mem 0xd0002000-0xd0002fff]
[    0.212443] pci 0000:00:0e.1: supports D1 D2
[    0.212447] pci 0000:00:0e.1: PME# supported from D1 D2 D3hot D3cold
[    0.212455] pci 0000:00:0e.1: PME# disabled
[    0.212581] pci 0000:00:10.0: reg 20: [io  0x1c00-0x1c1f]
[    0.212625] pci 0000:00:10.0: supports D1 D2
[    0.212630] pci 0000:00:10.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.212638] pci 0000:00:10.0: PME# disabled
[    0.212750] pci 0000:00:10.1: reg 20: [io  0x1c20-0x1c3f]
[    0.212794] pci 0000:00:10.1: supports D1 D2
[    0.212798] pci 0000:00:10.1: PME# supported from D0 D1 D2 D3hot D3cold
[    0.212806] pci 0000:00:10.1: PME# disabled
[    0.212917] pci 0000:00:10.2: reg 20: [io  0x1c40-0x1c5f]
[    0.212961] pci 0000:00:10.2: supports D1 D2
[    0.212966] pci 0000:00:10.2: PME# supported from D0 D1 D2 D3hot D3cold
[    0.212974] pci 0000:00:10.2: PME# disabled
[    0.213070] pci 0000:00:10.3: reg 10: [mem 0xd0004400-0xd00044ff]
[    0.213140] pci 0000:00:10.3: supports D1 D2
[    0.213145] pci 0000:00:10.3: PME# supported from D0 D1 D2 D3hot D3cold
[    0.213152] pci 0000:00:10.3: PME# disabled
[    0.213298] HPET not enabled in BIOS. You might try hpet=force boot option
[    0.213381] pci 0000:00:11.0: quirk: [io  0x4000-0x407f] claimed by vt8235 PM
[    0.213448] pci 0000:00:11.0: quirk: [io  0x8100-0x810f] claimed by vt8235 SMB
[    0.213653] pci 0000:00:11.1: reg 20: [io  0x1c60-0x1c6f]
[    0.213799] pci 0000:00:11.5: reg 10: [io  0x1400-0x14ff]
[    0.213873] pci 0000:00:11.5: supports D1 D2
[    0.213960] pci 0000:00:11.6: reg 10: [io  0x1800-0x18ff]
[    0.214482] PCI: peer root bus 00 res updated from pci conf
[    0.214702] pci 0000:01:00.0: reg 10: [mem 0xf0000000-0xf3ffffff pref]
[    0.214713] pci 0000:01:00.0: reg 14: [mem 0xd1000000-0xd1ffffff]
[    0.214744] pci 0000:01:00.0: reg 30: [mem 0x00000000-0x0000ffff pref]
[    0.214774] pci 0000:01:00.0: supports D1 D2
[    0.214841] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[    0.214907] pci 0000:00:01.0:   bridge window [io  0xf000-0x0000] (disabled)
[    0.214916] pci 0000:00:01.0:   bridge window [mem 0xd1000000-0xd1ffffff]
[    0.214925] pci 0000:00:01.0:   bridge window [mem 0xf0000000-0xf3ffffff pref]
[    0.249207] vgaarb: device added: PCI:0000:01:00.0,decodes=io+mem,owns=io+mem,locks=none
[    0.252887] pci 0000:00:11.0: VIA IRQ router [1106:3177]
[    0.253522] PCI: pci_cache_line_size set to 64 bytes
[    0.254561] reserve RAM buffer: 000000000009f800 - 000000000009ffff
[    0.254678] reserve RAM buffer: 000000003bf70000 - 000000003bffffff
[    0.260942] Switching to clocksource tsc
[    0.274471] PCI: max bus depth: 1 pci_try_num: 2
[    0.274577] pci 0000:00:0c.0: BAR 9: assigned [mem 0x40000000-0x43ffffff pref]
[    0.274668] pci 0000:00:0c.0: BAR 10: assigned [mem 0x44000000-0x47ffffff]
[    0.274739] pci 0000:00:0c.0: BAR 0: assigned [mem 0x48000000-0x48000fff]
[    0.274811] pci 0000:00:0c.0: BAR 0: set to [mem 0x48000000-0x48000fff] (PCI address [0x48000000-0x48000fff]
[    0.274896] pci 0000:00:0c.0: BAR 7: assigned [io  0x2000-0x20ff]
[    0.274980] pci 0000:00:0c.0: BAR 8: assigned [io  0x2400-0x24ff]
[    0.275071] pci 0000:01:00.0: BAR 6: can't assign mem pref (size 0x10000)
[    0.275141] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[    0.275201] pci 0000:00:01.0:   bridge window [io  disabled]
[    0.275268] pci 0000:00:01.0:   bridge window [mem 0xd1000000-0xd1ffffff]
[    0.275334] pci 0000:00:01.0:   bridge window [mem 0xf0000000-0xf3ffffff pref]
[    0.275414] pci 0000:00:0c.0: CardBus bridge to [bus 02-05]
[    0.275475] pci 0000:00:0c.0:   bridge window [io  0x2000-0x20ff]
[    0.275540] pci 0000:00:0c.0:   bridge window [io  0x2400-0x24ff]
[    0.275605] pci 0000:00:0c.0:   bridge window [mem 0x40000000-0x43ffffff pref]
[    0.275681] pci 0000:00:0c.0:   bridge window [mem 0x44000000-0x47ffffff]
[    0.275766] pci 0000:00:01.0: setting latency timer to 64
[    0.275780] pci 0000:00:0c.0: enabling device (0000 -> 0003)
[    0.275850] pci 0000:00:0c.0: can't find IRQ for PCI INT A; probably buggy MP table
[    0.275928] pci 0000:00:0c.0: setting latency timer to 64
[    0.275936] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
[    0.275941] pci_bus 0000:00: resource 5 [mem 0x40000000-0xffffffff]
[    0.275955] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.275961] pci_bus 0000:01: resource 1 [mem 0xd1000000-0xd1ffffff]
[    0.275966] pci_bus 0000:01: resource 2 [mem 0xf0000000-0xf3ffffff pref]
[    0.275971] pci_bus 0000:02: resource 0 [io  0x2000-0x20ff]
[    0.275975] pci_bus 0000:02: resource 1 [io  0x2400-0x24ff]
[    0.275980] pci_bus 0000:02: resource 2 [mem 0x40000000-0x43ffffff pref]
[    0.275985] pci_bus 0000:02: resource 3 [mem 0x44000000-0x47ffffff]
[    0.276531] NET: Registered protocol family 2
[    0.277368] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.279458] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.280980] TCP bind hash table entries: 65536 (order: 9, 2097152 bytes)
[    0.291730] TCP: Hash tables configured (established 131072 bind 65536)
[    0.291873] TCP reno registered
[    0.291998] UDP hash table entries: 512 (order: 3, 40960 bytes)
[    0.292251] UDP-Lite hash table entries: 512 (order: 3, 40960 bytes)
[    0.293430] NET: Registered protocol family 1
[    0.293733] pci 0000:00:01.0: disabling DAC on VIA PCI bridge
[    0.294601] pci 0000:01:00.0: Boot video device
[    0.294627] PCI: CLS 64 bytes, default 64
[    0.299863] platform rtc_cmos: registered platform RTC device (no PNP device found)
[    0.314319] audit: initializing netlink socket (disabled)
[    0.314639] type=2000 audit(1270901792.313:1): initialized
[    0.557179] highmem bounce pool size: 64 pages
[    0.560994] msgmni has been set to 1730
[    0.566393] alg: No test for stdrng (krng)
[    0.566628] io scheduler noop registered
[    0.566907] io scheduler cfq registered (default)
[    1.305054] Uniform Multi-Platform E-IDE driver
[    1.307969] via82cxxx 0000:00:11.1: VIA vt8235 (rev 00) IDE UDMA133
[    1.308060] via82cxxx 0000:00:11.1: IDE controller (0x1106:0x0571 rev 0x06)
[    1.308160] pci 0000:00:11.1: PCI->APIC IRQ transform: INT A -> IRQ 18
[    1.308789] via82cxxx 0000:00:11.1: not 100% native mode: will probe irqs later
[    1.308872]     ide0: BM-DMA at 0x1c60-0x1c67
[    1.308944]     ide1: BM-DMA at 0x1c68-0x1c6f
[    1.309009] Probing IDE interface ide0...
[    1.572578] hda: SAMSUNG HM160HC, ATA DISK drive
[    2.185881] hda: host max PIO5 wanted PIO255(auto-tune) selected PIO4
[    2.185977] hda: UDMA/100 mode selected
[    2.187034] Probing IDE interface ide1...
[    2.858103] hdc: Optiarc DVD RW AD-7543A, ATAPI CD/DVD-ROM drive
[    3.471090] hdc: host max PIO5 wanted PIO255(auto-tune) selected PIO4
[    3.473642] hdc: UDMA/33 mode selected
[    3.476628] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[    3.477810] ide1 at 0x170-0x177,0x376 on irq 15
[    3.486132] ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
[    3.487195] ide-gd driver 1.18
[    3.488035] hda: max request size: 512KiB
[    3.548998] hda: Host Protected Area detected.
[    3.549000] 	current capacity is 268435456 sectors (137438 MB)
[    3.549002] 	native  capacity is 312581808 sectors (160041 MB)
[    3.549188] hda: 268435456 sectors (137438 MB) w/8192KiB Cache, CHS=16709/255/63
[    3.550604] hda: cache flushes supported
[    3.552372]  hda: hda1 hda2 hda3
[    3.574201] PNP: No PS/2 controller found. Probing ports directly.
[    3.578329] i8042.c: Detected active multiplexing controller, rev 1.1.
[    3.580068] serio: i8042 KBD port at 0x60,0x64 irq 1
[    3.580330] serio: i8042 AUX0 port at 0x60,0x64 irq 12
[    3.580439] serio: i8042 AUX1 port at 0x60,0x64 irq 12
[    3.580545] serio: i8042 AUX2 port at 0x60,0x64 irq 12
[    3.580707] serio: i8042 AUX3 port at 0x60,0x64 irq 12
[    3.589839] cpuidle: using governor ladder
[    3.589914] cpuidle: using governor menu
[    3.591402] TCP cubic registered
[    3.591482] NET: Registered protocol family 17
[    3.591890] Using IPI Shortcut mode
[    3.596443] kmemleak: Kernel memory leak detector initialized
[    3.601511] kmemleak: Automatic memory scanning thread started
[    3.684323] EXT3-fs (hda1): recovery required on readonly filesystem
[    3.684481] EXT3-fs (hda1): write access will be enabled during recovery
[    3.707383] input: AT Translated Set 2 keyboard as /class/input/input0
[    3.718230] EXT3-fs (hda1): recovery complete
[    3.719585] kjournald starting.  Commit interval 5 seconds
[    3.719854] EXT3-fs (hda1): mounted filesystem with writeback data mode
[    3.720324] VFS: Mounted root (ext3 filesystem) readonly on device 3:1.
[    3.720775] Freeing unused kernel memory: 484k freed
[    3.722001] Write protecting the kernel text: 4368k
[    3.722193] Write protecting the kernel read-only data: 1060k
[   10.243400] input: PC Speaker as /class/input/input1
[   10.286074] 8139too: 8139too Fast Ethernet driver 0.9.28
[   10.286608] 8139too 0000:00:08.0: PCI->APIC IRQ transform: INT A -> IRQ 20
[   10.298859] 8139too 0000:00:08.0: eth0: RealTek RTL8139 at 0xf81d0000, 00:90:f5:3e:5a:ca, IRQ 20
[   10.626455] usbcore: registered new interface driver usbfs
[   10.631277] usbcore: registered new interface driver hub
[   10.634125] usbcore: registered new device driver usb
[   10.886468] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   10.886786] ehci_hcd 0000:00:10.3: PCI->APIC IRQ transform: INT D -> IRQ 20
[   10.886994] ehci_hcd 0000:00:10.3: EHCI Host Controller
[   10.889844] ehci_hcd 0000:00:10.3: new USB bus registered, assigned bus number 1
[   10.890458] ehci_hcd 0000:00:10.3: Enabling legacy PCI PM
[   10.890662] ehci_hcd 0000:00:10.3: irq 20, io mem 0xd0004400
[   10.896136] ehci_hcd 0000:00:10.3: USB 2.0 started, EHCI 1.00
[   10.904601] hub 1-0:1.0: USB hub found
[   10.905022] hub 1-0:1.0: 6 ports detected
[   11.088199] yenta_cardbus 0000:00:0c.0: CardBus bridge found [1558:4702]
[   11.088300] yenta_cardbus 0000:00:0c.0: adjusting diagnostic: 60 -> 00
[   11.088370] yenta_cardbus 0000:00:0c.0: Using INTVAL to route CSC interrupts to PCI
[   11.088444] yenta_cardbus 0000:00:0c.0: Routing CardBus interrupts to ISA
[   11.088511] yenta_cardbus 0000:00:0c.0: TI: mfunc 0x00001002, devctl 0x44
[   11.088576] yenta_cardbus 0000:00:0c.0: Yenta TI: no PCI interrupts. Fish. Please report.
[   11.088657] yenta_cardbus 0000:00:0c.0: no PCI IRQ, CardBus support disabled for this socket.
[   11.088732] yenta_cardbus 0000:00:0c.0: check your BIOS CardBus, BIOS IRQ or ACPI settings.
[   11.181295] ide-cd driver 5.00
[   11.185113] ide-cd: hdc: ATAPI 24X DVD-ROM DVD-R/RAM CD-R/RW drive, 2048kB Cache
[   11.185442] Uniform CD-ROM driver Revision: 3.20
[   11.213218] yenta_cardbus 0000:00:0c.0: ISA IRQ mask 0x0040, PCI irq 0
[   11.213297] yenta_cardbus 0000:00:0c.0: Socket status: 30000006
[   11.292185] uhci_hcd: USB Universal Host Controller Interface driver
[   11.292622] uhci_hcd 0000:00:10.0: PCI->APIC IRQ transform: INT A -> IRQ 16
[   11.292765] uhci_hcd 0000:00:10.0: UHCI Host Controller
[   11.299141] uhci_hcd 0000:00:10.0: new USB bus registered, assigned bus number 2
[   11.299454] uhci_hcd 0000:00:10.0: irq 16, io base 0x00001c00
[   11.324453] hub 2-0:1.0: USB hub found
[   11.328806] hub 2-0:1.0: 2 ports detected
[   11.344141] uhci_hcd 0000:00:10.1: PCI->APIC IRQ transform: INT B -> IRQ 17
[   11.344293] uhci_hcd 0000:00:10.1: UHCI Host Controller
[   11.344597] uhci_hcd 0000:00:10.1: new USB bus registered, assigned bus number 3
[   11.345034] uhci_hcd 0000:00:10.1: irq 17, io base 0x00001c20
[   11.367832] hub 3-0:1.0: USB hub found
[   11.368294] hub 3-0:1.0: 2 ports detected
[   11.390738] uhci_hcd 0000:00:10.2: PCI->APIC IRQ transform: INT C -> IRQ 18
[   11.395302] uhci_hcd 0000:00:10.2: UHCI Host Controller
[   11.395619] uhci_hcd 0000:00:10.2: new USB bus registered, assigned bus number 4
[   11.395952] uhci_hcd 0000:00:10.2: irq 18, io base 0x00001c40
[   11.408848] hub 4-0:1.0: USB hub found
[   11.409284] hub 4-0:1.0: 2 ports detected
[   11.427183] input: PS/2 Mouse as /class/input/input2
[   11.464349] input: AlpsPS/2 ALPS GlidePoint as /class/input/input3
[   11.736828] mice: PS/2 mouse device common for all mice
[   11.989024] rtc_cmos rtc_cmos: rtc core: registered rtc_cmos as rtc0
[   11.989280] rtc0: alarms up to one day, 114 bytes nvram
[   12.112959] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x100-0x3af: clean.
[   12.119174] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x3e0-0x4ff: clean.
[   12.121979] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x820-0x8ff: clean.
[   12.124158] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xc00-0xcf7: clean.
[   12.127426] pcmcia_socket pcmcia_socket0: cs: memory probe 0x0c0000-0x0fffff: excluding 0xc0000-0xfffff
[   12.135399] pcmcia_socket pcmcia_socket0: cs: memory probe 0xa0000000-0xa0ffffff: clean.
[   12.137258] pcmcia_socket pcmcia_socket0: cs: memory probe 0x60000000-0x60ffffff: clean.
[   12.139023] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xa00-0xaff: clean.
[   12.712092] VIA 82xx Modem 0000:00:11.6: PCI->APIC IRQ transform: INT C -> IRQ 18
[   12.714466] VIA 82xx Modem 0000:00:11.6: setting latency timer to 64
[   13.297289] VIA 82xx Audio 0000:00:11.5: PCI->APIC IRQ transform: INT C -> IRQ 18
[   13.297746] VIA 82xx Audio 0000:00:11.5: setting latency timer to 64
[   16.278943] EXT3-fs (hda1): using internal journal
[   16.908153] leds_clevo_mail: 'Clevo D410J' found
[   16.915669] Registered led device: clevo::mail
[   17.490942] fuse init (API version 7.13)
[   20.357320] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[   21.010543] PPP generic driver version 2.4.2
[   21.323112] NET: Registered protocol family 10
[   21.583974] ip_tables: (C) 2000-2006 Netfilter Core Team
[   31.482475] eth0: no IPv6 routers present
[   32.692054] ------------[ cut here ]------------
[   32.692150] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x462/0x480()
[   32.692223] Hardware name: K8N800
[   32.692279] NETDEV WATCHDOG: eth0 (8139too): transmit queue 0 timed out
[   32.692340] Modules linked in: cpufreq_powersave cpufreq_ondemand cpufreq_userspace cpufreq_conservative xt_tcpudp iptable_filter ip_tables x_tables ipv6
ppp_generic slhc fuse leds_clevo_mail led_class snd_via82xx snd_mpu401_uart snd_via82xx_modem snd_seq_oss snd_seq_midi snd_ac97_codec snd_pcm_oss snd_rawmidi
snd_mixer_oss snd_seq_midi_event snd_seq snd_pcm rtc_cmos pcmcia mousedev snd_timer firmware_class snd_seq_device uhci_hcd ide_cd_mod k8temp i2c_viapro snd
ac97_bus yenta_socket psmouse rtc_core ehci_hcd cdrom hwmon serio_raw usbcore rtc_lib i2c_core rsrc_nonstatic snd_page_alloc soundcore 8139too pcspkr nls_base
pcmcia_core mii evdev
[   32.694944] Pid: 0, comm: swapper Not tainted 2.6.34-rc3 #1
[   32.695004] Call Trace:
[   32.695073]  [<c014ae57>] warn_slowpath_common+0xd7/0x160
[   32.695138]  [<c049af62>] ? dev_watchdog+0x462/0x480
[   32.695200]  [<c049af62>] ? dev_watchdog+0x462/0x480
[   32.695264]  [<c014af80>] warn_slowpath_fmt+0x50/0x70
[   32.695327]  [<c049af62>] dev_watchdog+0x462/0x480
[   32.695394]  [<c015d7f7>] ? run_timer_softirq+0x147/0x400
[   32.695458]  [<c049ab00>] ? dev_watchdog+0x0/0x480
[   32.695520]  [<c015d8a8>] run_timer_softirq+0x1f8/0x400
[   32.695583]  [<c015d7f7>] ? run_timer_softirq+0x147/0x400
[   32.695650]  [<c01551cf>] __do_softirq+0xef/0x230
[   32.695714]  [<c01819ae>] ? profile_tick+0x4e/0x180
[   32.695778]  [<c015540b>] do_softirq+0xfb/0x100
[   32.695841]  [<c01558c3>] irq_exit+0x133/0x150
[   32.695904]  [<c0126fb1>] smp_apic_timer_interrupt+0x91/0x100
[   32.695971]  [<c039c7cc>] ? trace_hardirqs_off_thunk+0xc/0x10
[   32.696043]  [<c053a73f>] apic_timer_interrupt+0x2f/0x34
[   32.696109]  [<c010e0f9>] ? default_idle+0x69/0x110
[   32.696172]  [<c0102631>] cpu_idle+0xc1/0x170
[   32.696234]  [<c052866e>] rest_init+0x1ee/0x230
[   32.696296]  [<c0528480>] ? rest_init+0x0/0x230
[   32.696360]  [<c069410c>] start_kernel+0x752/0x766
[   32.696423]  [<c06935e1>] ? unknown_bootoption+0x0/0x36b
[   32.696487]  [<c069309e>] i386_start_kernel+0x9e/0xae
[   32.696548] ---[ end trace bcf0ea219fa68e19 ]---
[   35.695626] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[   41.428137] lp: driver loaded but no devices found
[   41.472132] ppdev: user-space parallel port driver
[   46.524507] Linux agpgart interface v0.103
[   46.707709] [drm] Initialized drm 1.1.0 20060810
[   46.811207] pci 0000:01:00.0: PCI->APIC IRQ transform: INT A -> IRQ 16
[   46.823483] [drm] Initialized via 2.11.1 20070202 for 0000:01:00.0 on minor 0
[   46.853403] [drm:via_initialize] *ERROR* called with no agp memory available
[   47.686604] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[   59.682169] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[   71.734738] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[   83.731451] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[   95.726946] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[  107.722495] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[  119.718082] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[  131.713700] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[  143.709247] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[  155.704834] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[  167.700465] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1

Regards,

	Márton Németh

--------------030007030504050405020609
Content-Type: text/plain;
 name=".config"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename=".config"

IwojIEF1dG9tYXRpY2FsbHkgZ2VuZXJhdGVkIG1ha2UgY29uZmlnOiBkb24ndCBlZGl0CiMg
TGludXgga2VybmVsIHZlcnNpb246IDIuNi4zNC1yYzMKIyBTYXQgQXByIDEwIDA5OjE5OjA1
IDIwMTAKIwojIENPTkZJR182NEJJVCBpcyBub3Qgc2V0CkNPTkZJR19YODZfMzI9eQojIENP
TkZJR19YODZfNjQgaXMgbm90IHNldApDT05GSUdfWDg2PXkKQ09ORklHX09VVFBVVF9GT1JN
QVQ9ImVsZjMyLWkzODYiCkNPTkZJR19BUkNIX0RFRkNPTkZJRz0iYXJjaC94ODYvY29uZmln
cy9pMzg2X2RlZmNvbmZpZyIKQ09ORklHX0dFTkVSSUNfVElNRT15CkNPTkZJR19HRU5FUklD
X0NNT1NfVVBEQVRFPXkKQ09ORklHX0NMT0NLU09VUkNFX1dBVENIRE9HPXkKQ09ORklHX0dF
TkVSSUNfQ0xPQ0tFVkVOVFM9eQpDT05GSUdfR0VORVJJQ19DTE9DS0VWRU5UU19CUk9BRENB
U1Q9eQpDT05GSUdfTE9DS0RFUF9TVVBQT1JUPXkKQ09ORklHX1NUQUNLVFJBQ0VfU1VQUE9S
VD15CkNPTkZJR19IQVZFX0xBVEVOQ1lUT1BfU1VQUE9SVD15CkNPTkZJR19NTVU9eQpDT05G
SUdfWk9ORV9ETUE9eQojIENPTkZJR19ORUVEX0RNQV9NQVBfU1RBVEUgaXMgbm90IHNldApD
T05GSUdfR0VORVJJQ19JU0FfRE1BPXkKQ09ORklHX0dFTkVSSUNfSU9NQVA9eQpDT05GSUdf
R0VORVJJQ19CVUc9eQpDT05GSUdfR0VORVJJQ19IV0VJR0hUPXkKQ09ORklHX0FSQ0hfTUFZ
X0hBVkVfUENfRkRDPXkKIyBDT05GSUdfUldTRU1fR0VORVJJQ19TUElOTE9DSyBpcyBub3Qg
c2V0CkNPTkZJR19SV1NFTV9YQ0hHQUREX0FMR09SSVRITT15CkNPTkZJR19BUkNIX0hBU19D
UFVfSURMRV9XQUlUPXkKQ09ORklHX0dFTkVSSUNfQ0FMSUJSQVRFX0RFTEFZPXkKIyBDT05G
SUdfR0VORVJJQ19USU1FX1ZTWVNDQUxMIGlzIG5vdCBzZXQKQ09ORklHX0FSQ0hfSEFTX0NQ
VV9SRUxBWD15CkNPTkZJR19BUkNIX0hBU19ERUZBVUxUX0lETEU9eQpDT05GSUdfQVJDSF9I
QVNfQ0FDSEVfTElORV9TSVpFPXkKQ09ORklHX0hBVkVfU0VUVVBfUEVSX0NQVV9BUkVBPXkK
Q09ORklHX05FRURfUEVSX0NQVV9FTUJFRF9GSVJTVF9DSFVOSz15CkNPTkZJR19ORUVEX1BF
Ul9DUFVfUEFHRV9GSVJTVF9DSFVOSz15CiMgQ09ORklHX0hBVkVfQ1BVTUFTS19PRl9DUFVf
TUFQIGlzIG5vdCBzZXQKQ09ORklHX0FSQ0hfSElCRVJOQVRJT05fUE9TU0lCTEU9eQpDT05G
SUdfQVJDSF9TVVNQRU5EX1BPU1NJQkxFPXkKIyBDT05GSUdfWk9ORV9ETUEzMiBpcyBub3Qg
c2V0CkNPTkZJR19BUkNIX1BPUFVMQVRFU19OT0RFX01BUD15CiMgQ09ORklHX0FVRElUX0FS
Q0ggaXMgbm90IHNldApDT05GSUdfQVJDSF9TVVBQT1JUU19PUFRJTUlaRURfSU5MSU5JTkc9
eQpDT05GSUdfQVJDSF9TVVBQT1JUU19ERUJVR19QQUdFQUxMT0M9eQpDT05GSUdfSEFWRV9F
QVJMWV9SRVM9eQpDT05GSUdfR0VORVJJQ19IQVJESVJRUz15CkNPTkZJR19HRU5FUklDX0hB
UkRJUlFTX05PX19ET19JUlE9eQpDT05GSUdfR0VORVJJQ19JUlFfUFJPQkU9eQpDT05GSUdf
WDg2XzMyX0xBWllfR1M9eQpDT05GSUdfS1RJTUVfU0NBTEFSPXkKQ09ORklHX0RFRkNPTkZJ
R19MSVNUPSIvbGliL21vZHVsZXMvJFVOQU1FX1JFTEVBU0UvLmNvbmZpZyIKQ09ORklHX0NP
TlNUUlVDVE9SUz15CgojCiMgR2VuZXJhbCBzZXR1cAojCkNPTkZJR19FWFBFUklNRU5UQUw9
eQpDT05GSUdfQlJPS0VOX09OX1NNUD15CkNPTkZJR19MT0NLX0tFUk5FTD15CkNPTkZJR19J
TklUX0VOVl9BUkdfTElNSVQ9MzIKQ09ORklHX0xPQ0FMVkVSU0lPTj0iIgpDT05GSUdfTE9D
QUxWRVJTSU9OX0FVVE89eQpDT05GSUdfSEFWRV9LRVJORUxfR1pJUD15CkNPTkZJR19IQVZF
X0tFUk5FTF9CWklQMj15CkNPTkZJR19IQVZFX0tFUk5FTF9MWk1BPXkKQ09ORklHX0hBVkVf
S0VSTkVMX0xaTz15CkNPTkZJR19LRVJORUxfR1pJUD15CiMgQ09ORklHX0tFUk5FTF9CWklQ
MiBpcyBub3Qgc2V0CiMgQ09ORklHX0tFUk5FTF9MWk1BIGlzIG5vdCBzZXQKIyBDT05GSUdf
S0VSTkVMX0xaTyBpcyBub3Qgc2V0CkNPTkZJR19TV0FQPXkKQ09ORklHX1NZU1ZJUEM9eQpD
T05GSUdfU1lTVklQQ19TWVNDVEw9eQpDT05GSUdfUE9TSVhfTVFVRVVFPXkKQ09ORklHX1BP
U0lYX01RVUVVRV9TWVNDVEw9eQojIENPTkZJR19CU0RfUFJPQ0VTU19BQ0NUIGlzIG5vdCBz
ZXQKIyBDT05GSUdfVEFTS1NUQVRTIGlzIG5vdCBzZXQKQ09ORklHX0FVRElUPXkKQ09ORklH
X0FVRElUU1lTQ0FMTD15CkNPTkZJR19BVURJVF9UUkVFPXkKCiMKIyBSQ1UgU3Vic3lzdGVt
CiMKQ09ORklHX1RSRUVfUkNVPXkKIyBDT05GSUdfVFJFRV9QUkVFTVBUX1JDVSBpcyBub3Qg
c2V0CiMgQ09ORklHX1RJTllfUkNVIGlzIG5vdCBzZXQKIyBDT05GSUdfUkNVX1RSQUNFIGlz
IG5vdCBzZXQKQ09ORklHX1JDVV9GQU5PVVQ9MzIKIyBDT05GSUdfUkNVX0ZBTk9VVF9FWEFD
VCBpcyBub3Qgc2V0CiMgQ09ORklHX1RSRUVfUkNVX1RSQUNFIGlzIG5vdCBzZXQKQ09ORklH
X0lLQ09ORklHPW0KQ09ORklHX0lLQ09ORklHX1BST0M9eQpDT05GSUdfTE9HX0JVRl9TSElG
VD0xNApDT05GSUdfSEFWRV9VTlNUQUJMRV9TQ0hFRF9DTE9DSz15CiMgQ09ORklHX0NHUk9V
UFMgaXMgbm90IHNldApDT05GSUdfU1lTRlNfREVQUkVDQVRFRD15CkNPTkZJR19TWVNGU19E
RVBSRUNBVEVEX1YyPXkKIyBDT05GSUdfUkVMQVkgaXMgbm90IHNldAojIENPTkZJR19OQU1F
U1BBQ0VTIGlzIG5vdCBzZXQKIyBDT05GSUdfQkxLX0RFVl9JTklUUkQgaXMgbm90IHNldAoj
IENPTkZJR19DQ19PUFRJTUlaRV9GT1JfU0laRSBpcyBub3Qgc2V0CkNPTkZJR19TWVNDVEw9
eQpDT05GSUdfQU5PTl9JTk9ERVM9eQpDT05GSUdfRU1CRURERUQ9eQpDT05GSUdfVUlEMTY9
eQojIENPTkZJR19TWVNDVExfU1lTQ0FMTCBpcyBub3Qgc2V0CkNPTkZJR19LQUxMU1lNUz15
CkNPTkZJR19LQUxMU1lNU19BTEw9eQojIENPTkZJR19LQUxMU1lNU19FWFRSQV9QQVNTIGlz
IG5vdCBzZXQKQ09ORklHX0hPVFBMVUc9eQpDT05GSUdfUFJJTlRLPXkKQ09ORklHX0JVRz15
CkNPTkZJR19FTEZfQ09SRT15CkNPTkZJR19QQ1NQS1JfUExBVEZPUk09eQpDT05GSUdfQkFT
RV9GVUxMPXkKQ09ORklHX0ZVVEVYPXkKQ09ORklHX0VQT0xMPXkKQ09ORklHX1NJR05BTEZE
PXkKQ09ORklHX1RJTUVSRkQ9eQpDT05GSUdfRVZFTlRGRD15CkNPTkZJR19TSE1FTT15CkNP
TkZJR19BSU89eQpDT05GSUdfSEFWRV9QRVJGX0VWRU5UUz15CgojCiMgS2VybmVsIFBlcmZv
cm1hbmNlIEV2ZW50cyBBbmQgQ291bnRlcnMKIwpDT05GSUdfUEVSRl9FVkVOVFM9eQojIENP
TkZJR19QRVJGX0NPVU5URVJTIGlzIG5vdCBzZXQKIyBDT05GSUdfREVCVUdfUEVSRl9VU0Vf
Vk1BTExPQyBpcyBub3Qgc2V0CkNPTkZJR19WTV9FVkVOVF9DT1VOVEVSUz15CkNPTkZJR19Q
Q0lfUVVJUktTPXkKQ09ORklHX0NPTVBBVF9CUks9eQpDT05GSUdfU0xBQj15CiMgQ09ORklH
X1NMVUIgaXMgbm90IHNldAojIENPTkZJR19TTE9CIGlzIG5vdCBzZXQKQ09ORklHX1BST0ZJ
TElORz15CkNPTkZJR19PUFJPRklMRT1tCiMgQ09ORklHX09QUk9GSUxFX0VWRU5UX01VTFRJ
UExFWCBpcyBub3Qgc2V0CkNPTkZJR19IQVZFX09QUk9GSUxFPXkKQ09ORklHX0tQUk9CRVM9
eQpDT05GSUdfSEFWRV9FRkZJQ0lFTlRfVU5BTElHTkVEX0FDQ0VTUz15CkNPTkZJR19LUkVU
UFJPQkVTPXkKQ09ORklHX1VTRVJfUkVUVVJOX05PVElGSUVSPXkKQ09ORklHX0hBVkVfSU9S
RU1BUF9QUk9UPXkKQ09ORklHX0hBVkVfS1BST0JFUz15CkNPTkZJR19IQVZFX0tSRVRQUk9C
RVM9eQpDT05GSUdfSEFWRV9PUFRQUk9CRVM9eQpDT05GSUdfSEFWRV9BUkNIX1RSQUNFSE9P
Sz15CkNPTkZJR19IQVZFX0RNQV9BVFRSUz15CkNPTkZJR19IQVZFX1JFR1NfQU5EX1NUQUNL
X0FDQ0VTU19BUEk9eQpDT05GSUdfSEFWRV9ETUFfQVBJX0RFQlVHPXkKQ09ORklHX0hBVkVf
SFdfQlJFQUtQT0lOVD15CkNPTkZJR19IQVZFX1VTRVJfUkVUVVJOX05PVElGSUVSPXkKCiMK
IyBHQ09WLWJhc2VkIGtlcm5lbCBwcm9maWxpbmcKIwpDT05GSUdfR0NPVl9LRVJORUw9eQpD
T05GSUdfR0NPVl9QUk9GSUxFX0FMTD15CkNPTkZJR19TTE9XX1dPUks9eQojIENPTkZJR19T
TE9XX1dPUktfREVCVUcgaXMgbm90IHNldApDT05GSUdfSEFWRV9HRU5FUklDX0RNQV9DT0hF
UkVOVD15CkNPTkZJR19TTEFCSU5GTz15CkNPTkZJR19SVF9NVVRFWEVTPXkKQ09ORklHX0JB
U0VfU01BTEw9MApDT05GSUdfTU9EVUxFUz15CiMgQ09ORklHX01PRFVMRV9GT1JDRV9MT0FE
IGlzIG5vdCBzZXQKQ09ORklHX01PRFVMRV9VTkxPQUQ9eQpDT05GSUdfTU9EVUxFX0ZPUkNF
X1VOTE9BRD15CiMgQ09ORklHX01PRFZFUlNJT05TIGlzIG5vdCBzZXQKIyBDT05GSUdfTU9E
VUxFX1NSQ1ZFUlNJT05fQUxMIGlzIG5vdCBzZXQKQ09ORklHX0JMT0NLPXkKQ09ORklHX0xC
REFGPXkKIyBDT05GSUdfQkxLX0RFVl9CU0cgaXMgbm90IHNldAojIENPTkZJR19CTEtfREVW
X0lOVEVHUklUWSBpcyBub3Qgc2V0CgojCiMgSU8gU2NoZWR1bGVycwojCkNPTkZJR19JT1ND
SEVEX05PT1A9eQpDT05GSUdfSU9TQ0hFRF9ERUFETElORT1tCkNPTkZJR19JT1NDSEVEX0NG
UT15CiMgQ09ORklHX0RFRkFVTFRfREVBRExJTkUgaXMgbm90IHNldApDT05GSUdfREVGQVVM
VF9DRlE9eQojIENPTkZJR19ERUZBVUxUX05PT1AgaXMgbm90IHNldApDT05GSUdfREVGQVVM
VF9JT1NDSEVEPSJjZnEiCkNPTkZJR19QUkVFTVBUX05PVElGSUVSUz15CiMgQ09ORklHX0lO
TElORV9TUElOX1RSWUxPQ0sgaXMgbm90IHNldAojIENPTkZJR19JTkxJTkVfU1BJTl9UUllM
T0NLX0JIIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5MSU5FX1NQSU5fTE9DSyBpcyBub3Qgc2V0
CiMgQ09ORklHX0lOTElORV9TUElOX0xPQ0tfQkggaXMgbm90IHNldAojIENPTkZJR19JTkxJ
TkVfU1BJTl9MT0NLX0lSUSBpcyBub3Qgc2V0CiMgQ09ORklHX0lOTElORV9TUElOX0xPQ0tf
SVJRU0FWRSBpcyBub3Qgc2V0CiMgQ09ORklHX0lOTElORV9TUElOX1VOTE9DSyBpcyBub3Qg
c2V0CiMgQ09ORklHX0lOTElORV9TUElOX1VOTE9DS19CSCBpcyBub3Qgc2V0CiMgQ09ORklH
X0lOTElORV9TUElOX1VOTE9DS19JUlEgaXMgbm90IHNldAojIENPTkZJR19JTkxJTkVfU1BJ
Tl9VTkxPQ0tfSVJRUkVTVE9SRSBpcyBub3Qgc2V0CiMgQ09ORklHX0lOTElORV9SRUFEX1RS
WUxPQ0sgaXMgbm90IHNldAojIENPTkZJR19JTkxJTkVfUkVBRF9MT0NLIGlzIG5vdCBzZXQK
IyBDT05GSUdfSU5MSU5FX1JFQURfTE9DS19CSCBpcyBub3Qgc2V0CiMgQ09ORklHX0lOTElO
RV9SRUFEX0xPQ0tfSVJRIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5MSU5FX1JFQURfTE9DS19J
UlFTQVZFIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5MSU5FX1JFQURfVU5MT0NLIGlzIG5vdCBz
ZXQKIyBDT05GSUdfSU5MSU5FX1JFQURfVU5MT0NLX0JIIGlzIG5vdCBzZXQKIyBDT05GSUdf
SU5MSU5FX1JFQURfVU5MT0NLX0lSUSBpcyBub3Qgc2V0CiMgQ09ORklHX0lOTElORV9SRUFE
X1VOTE9DS19JUlFSRVNUT1JFIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5MSU5FX1dSSVRFX1RS
WUxPQ0sgaXMgbm90IHNldAojIENPTkZJR19JTkxJTkVfV1JJVEVfTE9DSyBpcyBub3Qgc2V0
CiMgQ09ORklHX0lOTElORV9XUklURV9MT0NLX0JIIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5M
SU5FX1dSSVRFX0xPQ0tfSVJRIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5MSU5FX1dSSVRFX0xP
Q0tfSVJRU0FWRSBpcyBub3Qgc2V0CiMgQ09ORklHX0lOTElORV9XUklURV9VTkxPQ0sgaXMg
bm90IHNldAojIENPTkZJR19JTkxJTkVfV1JJVEVfVU5MT0NLX0JIIGlzIG5vdCBzZXQKIyBD
T05GSUdfSU5MSU5FX1dSSVRFX1VOTE9DS19JUlEgaXMgbm90IHNldAojIENPTkZJR19JTkxJ
TkVfV1JJVEVfVU5MT0NLX0lSUVJFU1RPUkUgaXMgbm90IHNldAojIENPTkZJR19NVVRFWF9T
UElOX09OX09XTkVSIGlzIG5vdCBzZXQKIyBDT05GSUdfRlJFRVpFUiBpcyBub3Qgc2V0Cgoj
CiMgUHJvY2Vzc29yIHR5cGUgYW5kIGZlYXR1cmVzCiMKQ09ORklHX1RJQ0tfT05FU0hPVD15
CkNPTkZJR19OT19IWj15CkNPTkZJR19ISUdIX1JFU19USU1FUlM9eQpDT05GSUdfR0VORVJJ
Q19DTE9DS0VWRU5UU19CVUlMRD15CiMgQ09ORklHX1NNUCBpcyBub3Qgc2V0CiMgQ09ORklH
X1NQQVJTRV9JUlEgaXMgbm90IHNldApDT05GSUdfWDg2X01QUEFSU0U9eQpDT05GSUdfWDg2
X0VYVEVOREVEX1BMQVRGT1JNPXkKIyBDT05GSUdfWDg2X0VMQU4gaXMgbm90IHNldAojIENP
TkZJR19YODZfTVJTVCBpcyBub3Qgc2V0CiMgQ09ORklHX1g4Nl9SREMzMjFYIGlzIG5vdCBz
ZXQKQ09ORklHX1g4Nl9TVVBQT1JUU19NRU1PUllfRkFJTFVSRT15CkNPTkZJR19TQ0hFRF9P
TUlUX0ZSQU1FX1BPSU5URVI9eQojIENPTkZJR19QQVJBVklSVF9HVUVTVCBpcyBub3Qgc2V0
CkNPTkZJR19OT19CT09UTUVNPXkKIyBDT05GSUdfTUVNVEVTVCBpcyBub3Qgc2V0CiMgQ09O
RklHX00zODYgaXMgbm90IHNldAojIENPTkZJR19NNDg2IGlzIG5vdCBzZXQKIyBDT05GSUdf
TTU4NiBpcyBub3Qgc2V0CiMgQ09ORklHX001ODZUU0MgaXMgbm90IHNldAojIENPTkZJR19N
NTg2TU1YIGlzIG5vdCBzZXQKIyBDT05GSUdfTTY4NiBpcyBub3Qgc2V0CiMgQ09ORklHX01Q
RU5USVVNSUkgaXMgbm90IHNldAojIENPTkZJR19NUEVOVElVTUlJSSBpcyBub3Qgc2V0CiMg
Q09ORklHX01QRU5USVVNTSBpcyBub3Qgc2V0CiMgQ09ORklHX01QRU5USVVNNCBpcyBub3Qg
c2V0CiMgQ09ORklHX01LNiBpcyBub3Qgc2V0CiMgQ09ORklHX01LNyBpcyBub3Qgc2V0CkNP
TkZJR19NSzg9eQojIENPTkZJR19NQ1JVU09FIGlzIG5vdCBzZXQKIyBDT05GSUdfTUVGRklD
RU9OIGlzIG5vdCBzZXQKIyBDT05GSUdfTVdJTkNISVBDNiBpcyBub3Qgc2V0CiMgQ09ORklH
X01XSU5DSElQM0QgaXMgbm90IHNldAojIENPTkZJR19NR0VPREVHWDEgaXMgbm90IHNldAoj
IENPTkZJR19NR0VPREVfTFggaXMgbm90IHNldAojIENPTkZJR19NQ1lSSVhJSUkgaXMgbm90
IHNldAojIENPTkZJR19NVklBQzNfMiBpcyBub3Qgc2V0CiMgQ09ORklHX01WSUFDNyBpcyBu
b3Qgc2V0CiMgQ09ORklHX01QU0MgaXMgbm90IHNldAojIENPTkZJR19NQ09SRTIgaXMgbm90
IHNldAojIENPTkZJR19NQVRPTSBpcyBub3Qgc2V0CiMgQ09ORklHX0dFTkVSSUNfQ1BVIGlz
IG5vdCBzZXQKQ09ORklHX1g4Nl9HRU5FUklDPXkKQ09ORklHX1g4Nl9DUFU9eQpDT05GSUdf
WDg2X0lOVEVSTk9ERV9DQUNIRV9TSElGVD02CkNPTkZJR19YODZfQ01QWENIRz15CkNPTkZJ
R19YODZfTDFfQ0FDSEVfU0hJRlQ9NgpDT05GSUdfWDg2X1hBREQ9eQpDT05GSUdfWDg2X1dQ
X1dPUktTX09LPXkKQ09ORklHX1g4Nl9JTlZMUEc9eQpDT05GSUdfWDg2X0JTV0FQPXkKQ09O
RklHX1g4Nl9QT1BBRF9PSz15CkNPTkZJR19YODZfSU5URUxfVVNFUkNPUFk9eQpDT05GSUdf
WDg2X1VTRV9QUFJPX0NIRUNLU1VNPXkKQ09ORklHX1g4Nl9UU0M9eQpDT05GSUdfWDg2X0NN
T1Y9eQpDT05GSUdfWDg2X01JTklNVU1fQ1BVX0ZBTUlMWT00CkNPTkZJR19YODZfREVCVUdD
VExNU1I9eQpDT05GSUdfUFJPQ0VTU09SX1NFTEVDVD15CkNPTkZJR19DUFVfU1VQX0lOVEVM
PXkKQ09ORklHX0NQVV9TVVBfQ1lSSVhfMzI9eQpDT05GSUdfQ1BVX1NVUF9BTUQ9eQpDT05G
SUdfQ1BVX1NVUF9DRU5UQVVSPXkKQ09ORklHX0NQVV9TVVBfVFJBTlNNRVRBXzMyPXkKQ09O
RklHX0NQVV9TVVBfVU1DXzMyPXkKIyBDT05GSUdfWDg2X0RTIGlzIG5vdCBzZXQKQ09ORklH
X0hQRVRfVElNRVI9eQpDT05GSUdfSFBFVF9FTVVMQVRFX1JUQz15CkNPTkZJR19ETUk9eQoj
IENPTkZJR19JT01NVV9IRUxQRVIgaXMgbm90IHNldAojIENPTkZJR19JT01NVV9BUEkgaXMg
bm90IHNldApDT05GSUdfTlJfQ1BVUz0xCiMgQ09ORklHX1BSRUVNUFRfTk9ORSBpcyBub3Qg
c2V0CiMgQ09ORklHX1BSRUVNUFRfVk9MVU5UQVJZIGlzIG5vdCBzZXQKQ09ORklHX1BSRUVN
UFQ9eQpDT05GSUdfWDg2X1VQX0FQSUM9eQpDT05GSUdfWDg2X1VQX0lPQVBJQz15CkNPTkZJ
R19YODZfTE9DQUxfQVBJQz15CkNPTkZJR19YODZfSU9fQVBJQz15CiMgQ09ORklHX1g4Nl9S
RVJPVVRFX0ZPUl9CUk9LRU5fQk9PVF9JUlFTIGlzIG5vdCBzZXQKQ09ORklHX1g4Nl9NQ0U9
eQpDT05GSUdfWDg2X01DRV9JTlRFTD15CkNPTkZJR19YODZfTUNFX0FNRD15CiMgQ09ORklH
X1g4Nl9BTkNJRU5UX01DRSBpcyBub3Qgc2V0CkNPTkZJR19YODZfTUNFX1RIUkVTSE9MRD15
CiMgQ09ORklHX1g4Nl9NQ0VfSU5KRUNUIGlzIG5vdCBzZXQKQ09ORklHX1g4Nl9USEVSTUFM
X1ZFQ1RPUj15CkNPTkZJR19WTTg2PXkKIyBDT05GSUdfVE9TSElCQSBpcyBub3Qgc2V0CiMg
Q09ORklHX0k4SyBpcyBub3Qgc2V0CiMgQ09ORklHX1g4Nl9SRUJPT1RGSVhVUFMgaXMgbm90
IHNldApDT05GSUdfTUlDUk9DT0RFPW0KIyBDT05GSUdfTUlDUk9DT0RFX0lOVEVMIGlzIG5v
dCBzZXQKQ09ORklHX01JQ1JPQ09ERV9BTUQ9eQpDT05GSUdfTUlDUk9DT0RFX09MRF9JTlRF
UkZBQ0U9eQpDT05GSUdfWDg2X01TUj1tCkNPTkZJR19YODZfQ1BVSUQ9bQojIENPTkZJR19O
T0hJR0hNRU0gaXMgbm90IHNldApDT05GSUdfSElHSE1FTTRHPXkKIyBDT05GSUdfSElHSE1F
TTY0RyBpcyBub3Qgc2V0CkNPTkZJR19WTVNQTElUXzNHPXkKIyBDT05GSUdfVk1TUExJVF8z
R19PUFQgaXMgbm90IHNldAojIENPTkZJR19WTVNQTElUXzJHIGlzIG5vdCBzZXQKIyBDT05G
SUdfVk1TUExJVF8yR19PUFQgaXMgbm90IHNldAojIENPTkZJR19WTVNQTElUXzFHIGlzIG5v
dCBzZXQKQ09ORklHX1BBR0VfT0ZGU0VUPTB4QzAwMDAwMDAKQ09ORklHX0hJR0hNRU09eQoj
IENPTkZJR19BUkNIX1BIWVNfQUREUl9UXzY0QklUIGlzIG5vdCBzZXQKQ09ORklHX0FSQ0hf
RkxBVE1FTV9FTkFCTEU9eQpDT05GSUdfQVJDSF9TUEFSU0VNRU1fRU5BQkxFPXkKQ09ORklH
X0FSQ0hfU0VMRUNUX01FTU9SWV9NT0RFTD15CkNPTkZJR19JTExFR0FMX1BPSU5URVJfVkFM
VUU9MApDT05GSUdfU0VMRUNUX01FTU9SWV9NT0RFTD15CkNPTkZJR19GTEFUTUVNX01BTlVB
TD15CiMgQ09ORklHX0RJU0NPTlRJR01FTV9NQU5VQUwgaXMgbm90IHNldAojIENPTkZJR19T
UEFSU0VNRU1fTUFOVUFMIGlzIG5vdCBzZXQKQ09ORklHX0ZMQVRNRU09eQpDT05GSUdfRkxB
VF9OT0RFX01FTV9NQVA9eQpDT05GSUdfU1BBUlNFTUVNX1NUQVRJQz15CkNPTkZJR19QQUdF
RkxBR1NfRVhURU5ERUQ9eQpDT05GSUdfU1BMSVRfUFRMT0NLX0NQVVM9OTk5OTk5CiMgQ09O
RklHX1BIWVNfQUREUl9UXzY0QklUIGlzIG5vdCBzZXQKQ09ORklHX1pPTkVfRE1BX0ZMQUc9
MQpDT05GSUdfQk9VTkNFPXkKQ09ORklHX1ZJUlRfVE9fQlVTPXkKQ09ORklHX01NVV9OT1RJ
RklFUj15CiMgQ09ORklHX0tTTSBpcyBub3Qgc2V0CkNPTkZJR19ERUZBVUxUX01NQVBfTUlO
X0FERFI9NDA5NgpDT05GSUdfQVJDSF9TVVBQT1JUU19NRU1PUllfRkFJTFVSRT15CiMgQ09O
RklHX01FTU9SWV9GQUlMVVJFIGlzIG5vdCBzZXQKIyBDT05GSUdfSElHSFBURSBpcyBub3Qg
c2V0CiMgQ09ORklHX1g4Nl9DSEVDS19CSU9TX0NPUlJVUFRJT04gaXMgbm90IHNldApDT05G
SUdfWDg2X1JFU0VSVkVfTE9XXzY0Sz15CiMgQ09ORklHX01BVEhfRU1VTEFUSU9OIGlzIG5v
dCBzZXQKQ09ORklHX01UUlI9eQojIENPTkZJR19NVFJSX1NBTklUSVpFUiBpcyBub3Qgc2V0
CiMgQ09ORklHX1g4Nl9QQVQgaXMgbm90IHNldApDT05GSUdfU0VDQ09NUD15CiMgQ09ORklH
X0NDX1NUQUNLUFJPVEVDVE9SIGlzIG5vdCBzZXQKIyBDT05GSUdfSFpfMTAwIGlzIG5vdCBz
ZXQKIyBDT05GSUdfSFpfMjUwIGlzIG5vdCBzZXQKIyBDT05GSUdfSFpfMzAwIGlzIG5vdCBz
ZXQKQ09ORklHX0haXzEwMDA9eQpDT05GSUdfSFo9MTAwMApDT05GSUdfU0NIRURfSFJUSUNL
PXkKIyBDT05GSUdfS0VYRUMgaXMgbm90IHNldAojIENPTkZJR19DUkFTSF9EVU1QIGlzIG5v
dCBzZXQKQ09ORklHX1BIWVNJQ0FMX1NUQVJUPTB4MTAwMDAwCiMgQ09ORklHX1JFTE9DQVRB
QkxFIGlzIG5vdCBzZXQKQ09ORklHX1BIWVNJQ0FMX0FMSUdOPTB4MTAwMDAwCiMgQ09ORklH
X0NPTVBBVF9WRFNPIGlzIG5vdCBzZXQKIyBDT05GSUdfQ01ETElORV9CT09MIGlzIG5vdCBz
ZXQKQ09ORklHX0FSQ0hfRU5BQkxFX01FTU9SWV9IT1RQTFVHPXkKCiMKIyBQb3dlciBtYW5h
Z2VtZW50IGFuZCBBQ1BJIG9wdGlvbnMKIwojIENPTkZJR19QTSBpcyBub3Qgc2V0CiMgQ09O
RklHX1NGSSBpcyBub3Qgc2V0CgojCiMgQ1BVIEZyZXF1ZW5jeSBzY2FsaW5nCiMKQ09ORklH
X0NQVV9GUkVRPXkKQ09ORklHX0NQVV9GUkVRX1RBQkxFPXkKQ09ORklHX0NQVV9GUkVRX0RF
QlVHPXkKQ09ORklHX0NQVV9GUkVRX1NUQVQ9eQojIENPTkZJR19DUFVfRlJFUV9TVEFUX0RF
VEFJTFMgaXMgbm90IHNldApDT05GSUdfQ1BVX0ZSRVFfREVGQVVMVF9HT1ZfUEVSRk9STUFO
Q0U9eQojIENPTkZJR19DUFVfRlJFUV9ERUZBVUxUX0dPVl9QT1dFUlNBVkUgaXMgbm90IHNl
dAojIENPTkZJR19DUFVfRlJFUV9ERUZBVUxUX0dPVl9VU0VSU1BBQ0UgaXMgbm90IHNldAoj
IENPTkZJR19DUFVfRlJFUV9ERUZBVUxUX0dPVl9PTkRFTUFORCBpcyBub3Qgc2V0CiMgQ09O
RklHX0NQVV9GUkVRX0RFRkFVTFRfR09WX0NPTlNFUlZBVElWRSBpcyBub3Qgc2V0CkNPTkZJ
R19DUFVfRlJFUV9HT1ZfUEVSRk9STUFOQ0U9eQpDT05GSUdfQ1BVX0ZSRVFfR09WX1BPV0VS
U0FWRT1tCkNPTkZJR19DUFVfRlJFUV9HT1ZfVVNFUlNQQUNFPW0KQ09ORklHX0NQVV9GUkVR
X0dPVl9PTkRFTUFORD1tCkNPTkZJR19DUFVfRlJFUV9HT1ZfQ09OU0VSVkFUSVZFPW0KCiMK
IyBDUFVGcmVxIHByb2Nlc3NvciBkcml2ZXJzCiMKQ09ORklHX1g4Nl9QT1dFUk5PV19LNj1t
CkNPTkZJR19YODZfUE9XRVJOT1dfSzc9bQpDT05GSUdfWDg2X0dYX1NVU1BNT0Q9bQpDT05G
SUdfWDg2X1NQRUVEU1RFUF9DRU5UUklOTz1tCkNPTkZJR19YODZfU1BFRURTVEVQX0NFTlRS
SU5PX1RBQkxFPXkKQ09ORklHX1g4Nl9TUEVFRFNURVBfSUNIPW0KQ09ORklHX1g4Nl9TUEVF
RFNURVBfU01JPW0KQ09ORklHX1g4Nl9QNF9DTE9DS01PRD1tCiMgQ09ORklHX1g4Nl9DUFVG
UkVRX05GT1JDRTIgaXMgbm90IHNldAojIENPTkZJR19YODZfTE9OR1JVTiBpcyBub3Qgc2V0
CiMgQ09ORklHX1g4Nl9FX1BPV0VSU0FWRVIgaXMgbm90IHNldAoKIwojIHNoYXJlZCBvcHRp
b25zCiMKQ09ORklHX1g4Nl9TUEVFRFNURVBfTElCPW0KIyBDT05GSUdfWDg2X1NQRUVEU1RF
UF9SRUxBWEVEX0NBUF9DSEVDSyBpcyBub3Qgc2V0CkNPTkZJR19DUFVfSURMRT15CkNPTkZJ
R19DUFVfSURMRV9HT1ZfTEFEREVSPXkKQ09ORklHX0NQVV9JRExFX0dPVl9NRU5VPXkKCiMK
IyBCdXMgb3B0aW9ucyAoUENJIGV0Yy4pCiMKQ09ORklHX1BDST15CiMgQ09ORklHX1BDSV9H
T0JJT1MgaXMgbm90IHNldAojIENPTkZJR19QQ0lfR09NTUNPTkZJRyBpcyBub3Qgc2V0CiMg
Q09ORklHX1BDSV9HT0RJUkVDVCBpcyBub3Qgc2V0CiMgQ09ORklHX1BDSV9HT09MUEMgaXMg
bm90IHNldApDT05GSUdfUENJX0dPQU5ZPXkKQ09ORklHX1BDSV9CSU9TPXkKQ09ORklHX1BD
SV9ESVJFQ1Q9eQpDT05GSUdfUENJX0RPTUFJTlM9eQojIENPTkZJR19QQ0lFUE9SVEJVUyBp
cyBub3Qgc2V0CkNPTkZJR19BUkNIX1NVUFBPUlRTX01TST15CkNPTkZJR19QQ0lfTVNJPXkK
IyBDT05GSUdfUENJX0RFQlVHIGlzIG5vdCBzZXQKIyBDT05GSUdfUENJX1NUVUIgaXMgbm90
IHNldApDT05GSUdfSFRfSVJRPXkKIyBDT05GSUdfUENJX0lPViBpcyBub3Qgc2V0CkNPTkZJ
R19JU0FfRE1BX0FQST15CkNPTkZJR19JU0E9eQpDT05GSUdfRUlTQT15CiMgQ09ORklHX0VJ
U0FfVkxCX1BSSU1JTkcgaXMgbm90IHNldApDT05GSUdfRUlTQV9QQ0lfRUlTQT15CiMgQ09O
RklHX0VJU0FfVklSVFVBTF9ST09UIGlzIG5vdCBzZXQKQ09ORklHX0VJU0FfTkFNRVM9eQoj
IENPTkZJR19NQ0EgaXMgbm90IHNldAojIENPTkZJR19TQ3gyMDAgaXMgbm90IHNldAojIENP
TkZJR19PTFBDIGlzIG5vdCBzZXQKQ09ORklHX0s4X05CPXkKQ09ORklHX1BDQ0FSRD1tCkNP
TkZJR19QQ01DSUE9bQpDT05GSUdfUENNQ0lBX0xPQURfQ0lTPXkKQ09ORklHX0NBUkRCVVM9
eQoKIwojIFBDLWNhcmQgYnJpZGdlcwojCkNPTkZJR19ZRU5UQT1tCkNPTkZJR19ZRU5UQV9P
Mj15CkNPTkZJR19ZRU5UQV9SSUNPSD15CkNPTkZJR19ZRU5UQV9UST15CkNPTkZJR19ZRU5U
QV9FTkVfVFVORT15CkNPTkZJR19ZRU5UQV9UT1NISUJBPXkKQ09ORklHX1BENjcyOT1tCkNP
TkZJR19JODIwOTI9bQpDT05GSUdfSTgyMzY1PW0KQ09ORklHX1RDSUM9bQpDT05GSUdfUENN
Q0lBX1BST0JFPXkKQ09ORklHX1BDQ0FSRF9OT05TVEFUSUM9bQojIENPTkZJR19IT1RQTFVH
X1BDSSBpcyBub3Qgc2V0CgojCiMgRXhlY3V0YWJsZSBmaWxlIGZvcm1hdHMgLyBFbXVsYXRp
b25zCiMKQ09ORklHX0JJTkZNVF9FTEY9eQojIENPTkZJR19DT1JFX0RVTVBfREVGQVVMVF9F
TEZfSEVBREVSUyBpcyBub3Qgc2V0CkNPTkZJR19IQVZFX0FPVVQ9eQpDT05GSUdfQklORk1U
X0FPVVQ9bQpDT05GSUdfQklORk1UX01JU0M9bQpDT05GSUdfSEFWRV9BVE9NSUNfSU9NQVA9
eQpDT05GSUdfTkVUPXkKCiMKIyBOZXR3b3JraW5nIG9wdGlvbnMKIwpDT05GSUdfUEFDS0VU
PXkKQ09ORklHX1VOSVg9eQojIENPTkZJR19ORVRfS0VZIGlzIG5vdCBzZXQKQ09ORklHX0lO
RVQ9eQpDT05GSUdfSVBfTVVMVElDQVNUPXkKIyBDT05GSUdfSVBfQURWQU5DRURfUk9VVEVS
IGlzIG5vdCBzZXQKQ09ORklHX0lQX0ZJQl9IQVNIPXkKIyBDT05GSUdfSVBfUE5QIGlzIG5v
dCBzZXQKIyBDT05GSUdfTkVUX0lQSVAgaXMgbm90IHNldAojIENPTkZJR19ORVRfSVBHUkUg
aXMgbm90IHNldAojIENPTkZJR19JUF9NUk9VVEUgaXMgbm90IHNldAojIENPTkZJR19BUlBE
IGlzIG5vdCBzZXQKIyBDT05GSUdfU1lOX0NPT0tJRVMgaXMgbm90IHNldAojIENPTkZJR19J
TkVUX0FIIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5FVF9FU1AgaXMgbm90IHNldAojIENPTkZJ
R19JTkVUX0lQQ09NUCBpcyBub3Qgc2V0CiMgQ09ORklHX0lORVRfWEZSTV9UVU5ORUwgaXMg
bm90IHNldApDT05GSUdfSU5FVF9UVU5ORUw9bQojIENPTkZJR19JTkVUX1hGUk1fTU9ERV9U
UkFOU1BPUlQgaXMgbm90IHNldAojIENPTkZJR19JTkVUX1hGUk1fTU9ERV9UVU5ORUwgaXMg
bm90IHNldAojIENPTkZJR19JTkVUX1hGUk1fTU9ERV9CRUVUIGlzIG5vdCBzZXQKIyBDT05G
SUdfSU5FVF9MUk8gaXMgbm90IHNldApDT05GSUdfSU5FVF9ESUFHPXkKQ09ORklHX0lORVRf
VENQX0RJQUc9eQojIENPTkZJR19UQ1BfQ09OR19BRFZBTkNFRCBpcyBub3Qgc2V0CkNPTkZJ
R19UQ1BfQ09OR19DVUJJQz15CkNPTkZJR19ERUZBVUxUX1RDUF9DT05HPSJjdWJpYyIKIyBD
T05GSUdfVENQX01ENVNJRyBpcyBub3Qgc2V0CkNPTkZJR19JUFY2PW0KIyBDT05GSUdfSVBW
Nl9QUklWQUNZIGlzIG5vdCBzZXQKIyBDT05GSUdfSVBWNl9ST1VURVJfUFJFRiBpcyBub3Qg
c2V0CiMgQ09ORklHX0lQVjZfT1BUSU1JU1RJQ19EQUQgaXMgbm90IHNldAojIENPTkZJR19J
TkVUNl9BSCBpcyBub3Qgc2V0CiMgQ09ORklHX0lORVQ2X0VTUCBpcyBub3Qgc2V0CiMgQ09O
RklHX0lORVQ2X0lQQ09NUCBpcyBub3Qgc2V0CiMgQ09ORklHX0lQVjZfTUlQNiBpcyBub3Qg
c2V0CiMgQ09ORklHX0lORVQ2X1hGUk1fVFVOTkVMIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5F
VDZfVFVOTkVMIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5FVDZfWEZSTV9NT0RFX1RSQU5TUE9S
VCBpcyBub3Qgc2V0CiMgQ09ORklHX0lORVQ2X1hGUk1fTU9ERV9UVU5ORUwgaXMgbm90IHNl
dAojIENPTkZJR19JTkVUNl9YRlJNX01PREVfQkVFVCBpcyBub3Qgc2V0CiMgQ09ORklHX0lO
RVQ2X1hGUk1fTU9ERV9ST1VURU9QVElNSVpBVElPTiBpcyBub3Qgc2V0CkNPTkZJR19JUFY2
X1NJVD1tCiMgQ09ORklHX0lQVjZfU0lUXzZSRCBpcyBub3Qgc2V0CkNPTkZJR19JUFY2X05E
SVNDX05PREVUWVBFPXkKIyBDT05GSUdfSVBWNl9UVU5ORUwgaXMgbm90IHNldAojIENPTkZJ
R19JUFY2X01VTFRJUExFX1RBQkxFUyBpcyBub3Qgc2V0CiMgQ09ORklHX0lQVjZfTVJPVVRF
IGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUV09SS19TRUNNQVJLIGlzIG5vdCBzZXQKQ09ORklH
X05FVEZJTFRFUj15CiMgQ09ORklHX05FVEZJTFRFUl9ERUJVRyBpcyBub3Qgc2V0CkNPTkZJ
R19ORVRGSUxURVJfQURWQU5DRUQ9eQoKIwojIENvcmUgTmV0ZmlsdGVyIENvbmZpZ3VyYXRp
b24KIwpDT05GSUdfTkVURklMVEVSX05FVExJTks9bQpDT05GSUdfTkVURklMVEVSX05FVExJ
TktfUVVFVUU9bQpDT05GSUdfTkVURklMVEVSX05FVExJTktfTE9HPW0KQ09ORklHX05GX0NP
Tk5UUkFDSz1tCkNPTkZJR19ORl9DVF9BQ0NUPXkKQ09ORklHX05GX0NPTk5UUkFDS19NQVJL
PXkKIyBDT05GSUdfTkZfQ09OTlRSQUNLX0VWRU5UUyBpcyBub3Qgc2V0CiMgQ09ORklHX05G
X0NUX1BST1RPX0RDQ1AgaXMgbm90IHNldApDT05GSUdfTkZfQ1RfUFJPVE9fR1JFPW0KQ09O
RklHX05GX0NUX1BST1RPX1NDVFA9bQojIENPTkZJR19ORl9DVF9QUk9UT19VRFBMSVRFIGlz
IG5vdCBzZXQKQ09ORklHX05GX0NPTk5UUkFDS19BTUFOREE9bQpDT05GSUdfTkZfQ09OTlRS
QUNLX0ZUUD1tCkNPTkZJR19ORl9DT05OVFJBQ0tfSDMyMz1tCkNPTkZJR19ORl9DT05OVFJB
Q0tfSVJDPW0KQ09ORklHX05GX0NPTk5UUkFDS19ORVRCSU9TX05TPW0KQ09ORklHX05GX0NP
Tk5UUkFDS19QUFRQPW0KQ09ORklHX05GX0NPTk5UUkFDS19TQU5FPW0KQ09ORklHX05GX0NP
Tk5UUkFDS19TSVA9bQpDT05GSUdfTkZfQ09OTlRSQUNLX1RGVFA9bQpDT05GSUdfTkZfQ1Rf
TkVUTElOSz1tCiMgQ09ORklHX05FVEZJTFRFUl9UUFJPWFkgaXMgbm90IHNldApDT05GSUdf
TkVURklMVEVSX1hUQUJMRVM9bQpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9DTEFTU0lG
WT1tCkNPTkZJR19ORVRGSUxURVJfWFRfVEFSR0VUX0NPTk5NQVJLPW0KIyBDT05GSUdfTkVU
RklMVEVSX1hUX1RBUkdFVF9DVCBpcyBub3Qgc2V0CkNPTkZJR19ORVRGSUxURVJfWFRfVEFS
R0VUX0RTQ1A9bQpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9ITD1tCiMgQ09ORklHX05F
VEZJTFRFUl9YVF9UQVJHRVRfTEVEIGlzIG5vdCBzZXQKQ09ORklHX05FVEZJTFRFUl9YVF9U
QVJHRVRfTUFSSz1tCkNPTkZJR19ORVRGSUxURVJfWFRfVEFSR0VUX05GTE9HPW0KQ09ORklH
X05FVEZJTFRFUl9YVF9UQVJHRVRfTkZRVUVVRT1tCkNPTkZJR19ORVRGSUxURVJfWFRfVEFS
R0VUX05PVFJBQ0s9bQojIENPTkZJR19ORVRGSUxURVJfWFRfVEFSR0VUX1JBVEVFU1QgaXMg
bm90IHNldAojIENPTkZJR19ORVRGSUxURVJfWFRfVEFSR0VUX1RSQUNFIGlzIG5vdCBzZXQK
Q09ORklHX05FVEZJTFRFUl9YVF9UQVJHRVRfVENQTVNTPW0KIyBDT05GSUdfTkVURklMVEVS
X1hUX1RBUkdFVF9UQ1BPUFRTVFJJUCBpcyBub3Qgc2V0CiMgQ09ORklHX05FVEZJTFRFUl9Y
VF9NQVRDSF9DTFVTVEVSIGlzIG5vdCBzZXQKQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9D
T01NRU5UPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9DT05OQllURVM9bQojIENPTkZJ
R19ORVRGSUxURVJfWFRfTUFUQ0hfQ09OTkxJTUlUIGlzIG5vdCBzZXQKQ09ORklHX05FVEZJ
TFRFUl9YVF9NQVRDSF9DT05OTUFSSz1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfQ09O
TlRSQUNLPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9EQ0NQPW0KQ09ORklHX05FVEZJ
TFRFUl9YVF9NQVRDSF9EU0NQPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9FU1A9bQpD
T05GSUdfTkVURklMVEVSX1hUX01BVENIX0hBU0hMSU1JVD1tCkNPTkZJR19ORVRGSUxURVJf
WFRfTUFUQ0hfSEVMUEVSPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9ITD1tCiMgQ09O
RklHX05FVEZJTFRFUl9YVF9NQVRDSF9JUFJBTkdFIGlzIG5vdCBzZXQKQ09ORklHX05FVEZJ
TFRFUl9YVF9NQVRDSF9MRU5HVEg9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX0xJTUlU
PW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9NQUM9bQpDT05GSUdfTkVURklMVEVSX1hU
X01BVENIX01BUks9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX01VTFRJUE9SVD1tCiMg
Q09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9PV05FUiBpcyBub3Qgc2V0CkNPTkZJR19ORVRG
SUxURVJfWFRfTUFUQ0hfUEtUVFlQRT1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfUVVP
VEE9bQojIENPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfUkFURUVTVCBpcyBub3Qgc2V0CkNP
TkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfUkVBTE09bQojIENPTkZJR19ORVRGSUxURVJfWFRf
TUFUQ0hfUkVDRU5UIGlzIG5vdCBzZXQKQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9TQ1RQ
PW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9TVEFURT1tCkNPTkZJR19ORVRGSUxURVJf
WFRfTUFUQ0hfU1RBVElTVElDPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9TVFJJTkc9
bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX1RDUE1TUz1tCiMgQ09ORklHX05FVEZJTFRF
Ul9YVF9NQVRDSF9USU1FIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVURklMVEVSX1hUX01BVENI
X1UzMiBpcyBub3Qgc2V0CiMgQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9PU0YgaXMgbm90
IHNldAojIENPTkZJR19JUF9WUyBpcyBub3Qgc2V0CgojCiMgSVA6IE5ldGZpbHRlciBDb25m
aWd1cmF0aW9uCiMKQ09ORklHX05GX0RFRlJBR19JUFY0PW0KQ09ORklHX05GX0NPTk5UUkFD
S19JUFY0PW0KQ09ORklHX05GX0NPTk5UUkFDS19QUk9DX0NPTVBBVD15CiMgQ09ORklHX0lQ
X05GX1FVRVVFIGlzIG5vdCBzZXQKQ09ORklHX0lQX05GX0lQVEFCTEVTPW0KQ09ORklHX0lQ
X05GX01BVENIX0FERFJUWVBFPW0KQ09ORklHX0lQX05GX01BVENIX0FIPW0KQ09ORklHX0lQ
X05GX01BVENIX0VDTj1tCkNPTkZJR19JUF9ORl9NQVRDSF9UVEw9bQpDT05GSUdfSVBfTkZf
RklMVEVSPW0KQ09ORklHX0lQX05GX1RBUkdFVF9SRUpFQ1Q9bQpDT05GSUdfSVBfTkZfVEFS
R0VUX0xPRz1tCkNPTkZJR19JUF9ORl9UQVJHRVRfVUxPRz1tCkNPTkZJR19ORl9OQVQ9bQpD
T05GSUdfTkZfTkFUX05FRURFRD15CkNPTkZJR19JUF9ORl9UQVJHRVRfTUFTUVVFUkFERT1t
CkNPTkZJR19JUF9ORl9UQVJHRVRfTkVUTUFQPW0KQ09ORklHX0lQX05GX1RBUkdFVF9SRURJ
UkVDVD1tCkNPTkZJR19ORl9OQVRfU05NUF9CQVNJQz1tCkNPTkZJR19ORl9OQVRfUFJPVE9f
R1JFPW0KQ09ORklHX05GX05BVF9QUk9UT19TQ1RQPW0KQ09ORklHX05GX05BVF9GVFA9bQpD
T05GSUdfTkZfTkFUX0lSQz1tCkNPTkZJR19ORl9OQVRfVEZUUD1tCkNPTkZJR19ORl9OQVRf
QU1BTkRBPW0KQ09ORklHX05GX05BVF9QUFRQPW0KQ09ORklHX05GX05BVF9IMzIzPW0KQ09O
RklHX05GX05BVF9TSVA9bQpDT05GSUdfSVBfTkZfTUFOR0xFPW0KIyBDT05GSUdfSVBfTkZf
VEFSR0VUX0NMVVNURVJJUCBpcyBub3Qgc2V0CkNPTkZJR19JUF9ORl9UQVJHRVRfRUNOPW0K
Q09ORklHX0lQX05GX1RBUkdFVF9UVEw9bQpDT05GSUdfSVBfTkZfUkFXPW0KIyBDT05GSUdf
SVBfTkZfQVJQVEFCTEVTIGlzIG5vdCBzZXQKCiMKIyBJUHY2OiBOZXRmaWx0ZXIgQ29uZmln
dXJhdGlvbgojCkNPTkZJR19ORl9DT05OVFJBQ0tfSVBWNj1tCiMgQ09ORklHX0lQNl9ORl9R
VUVVRSBpcyBub3Qgc2V0CkNPTkZJR19JUDZfTkZfSVBUQUJMRVM9bQpDT05GSUdfSVA2X05G
X01BVENIX0FIPW0KQ09ORklHX0lQNl9ORl9NQVRDSF9FVUk2ND1tCkNPTkZJR19JUDZfTkZf
TUFUQ0hfRlJBRz1tCkNPTkZJR19JUDZfTkZfTUFUQ0hfT1BUUz1tCkNPTkZJR19JUDZfTkZf
TUFUQ0hfSEw9bQpDT05GSUdfSVA2X05GX01BVENIX0lQVjZIRUFERVI9bQpDT05GSUdfSVA2
X05GX01BVENIX01IPW0KQ09ORklHX0lQNl9ORl9NQVRDSF9SVD1tCkNPTkZJR19JUDZfTkZf
VEFSR0VUX0hMPW0KQ09ORklHX0lQNl9ORl9UQVJHRVRfTE9HPW0KQ09ORklHX0lQNl9ORl9G
SUxURVI9bQpDT05GSUdfSVA2X05GX1RBUkdFVF9SRUpFQ1Q9bQpDT05GSUdfSVA2X05GX01B
TkdMRT1tCkNPTkZJR19JUDZfTkZfUkFXPW0KIyBDT05GSUdfSVBfRENDUCBpcyBub3Qgc2V0
CiMgQ09ORklHX0lQX1NDVFAgaXMgbm90IHNldAojIENPTkZJR19SRFMgaXMgbm90IHNldAoj
IENPTkZJR19USVBDIGlzIG5vdCBzZXQKIyBDT05GSUdfQVRNIGlzIG5vdCBzZXQKIyBDT05G
SUdfQlJJREdFIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX0RTQSBpcyBub3Qgc2V0CiMgQ09O
RklHX1ZMQU5fODAyMVEgaXMgbm90IHNldAojIENPTkZJR19ERUNORVQgaXMgbm90IHNldAoj
IENPTkZJR19MTEMyIGlzIG5vdCBzZXQKIyBDT05GSUdfSVBYIGlzIG5vdCBzZXQKIyBDT05G
SUdfQVRBTEsgaXMgbm90IHNldAojIENPTkZJR19YMjUgaXMgbm90IHNldAojIENPTkZJR19M
QVBCIGlzIG5vdCBzZXQKIyBDT05GSUdfRUNPTkVUIGlzIG5vdCBzZXQKIyBDT05GSUdfV0FO
X1JPVVRFUiBpcyBub3Qgc2V0CiMgQ09ORklHX1BIT05FVCBpcyBub3Qgc2V0CiMgQ09ORklH
X0lFRUU4MDIxNTQgaXMgbm90IHNldAojIENPTkZJR19ORVRfU0NIRUQgaXMgbm90IHNldApD
T05GSUdfTkVUX0NMU19ST1VURT15CiMgQ09ORklHX0RDQiBpcyBub3Qgc2V0CgojCiMgTmV0
d29yayB0ZXN0aW5nCiMKIyBDT05GSUdfTkVUX1BLVEdFTiBpcyBub3Qgc2V0CiMgQ09ORklH
X05FVF9UQ1BQUk9CRSBpcyBub3Qgc2V0CiMgQ09ORklHX0hBTVJBRElPIGlzIG5vdCBzZXQK
IyBDT05GSUdfQ0FOIGlzIG5vdCBzZXQKIyBDT05GSUdfSVJEQSBpcyBub3Qgc2V0CiMgQ09O
RklHX0JUIGlzIG5vdCBzZXQKIyBDT05GSUdfQUZfUlhSUEMgaXMgbm90IHNldApDT05GSUdf
V0lSRUxFU1M9eQpDT05GSUdfV0VYVF9DT1JFPXkKQ09ORklHX1dFWFRfUFJPQz15CkNPTkZJ
R19DRkc4MDIxMT1tCiMgQ09ORklHX05MODAyMTFfVEVTVE1PREUgaXMgbm90IHNldAojIENP
TkZJR19DRkc4MDIxMV9ERVZFTE9QRVJfV0FSTklOR1MgaXMgbm90IHNldAojIENPTkZJR19D
Rkc4MDIxMV9SRUdfREVCVUcgaXMgbm90IHNldApDT05GSUdfQ0ZHODAyMTFfREVGQVVMVF9Q
Uz15CiMgQ09ORklHX0NGRzgwMjExX0RFQlVHRlMgaXMgbm90IHNldAojIENPTkZJR19DRkc4
MDIxMV9JTlRFUk5BTF9SRUdEQiBpcyBub3Qgc2V0CkNPTkZJR19DRkc4MDIxMV9XRVhUPXkK
Q09ORklHX1dJUkVMRVNTX0VYVF9TWVNGUz15CiMgQ09ORklHX0xJQjgwMjExIGlzIG5vdCBz
ZXQKQ09ORklHX01BQzgwMjExPW0KQ09ORklHX01BQzgwMjExX1JDX1BJRD15CiMgQ09ORklH
X01BQzgwMjExX1JDX01JTlNUUkVMIGlzIG5vdCBzZXQKQ09ORklHX01BQzgwMjExX1JDX0RF
RkFVTFRfUElEPXkKIyBDT05GSUdfTUFDODAyMTFfUkNfREVGQVVMVF9NSU5TVFJFTCBpcyBu
b3Qgc2V0CkNPTkZJR19NQUM4MDIxMV9SQ19ERUZBVUxUPSJwaWQiCiMgQ09ORklHX01BQzgw
MjExX01FU0ggaXMgbm90IHNldAojIENPTkZJR19NQUM4MDIxMV9MRURTIGlzIG5vdCBzZXQK
IyBDT05GSUdfTUFDODAyMTFfREVCVUdGUyBpcyBub3Qgc2V0CiMgQ09ORklHX01BQzgwMjEx
X0RFQlVHX01FTlUgaXMgbm90IHNldAojIENPTkZJR19XSU1BWCBpcyBub3Qgc2V0CkNPTkZJ
R19SRktJTEw9bQpDT05GSUdfUkZLSUxMX0xFRFM9eQojIENPTkZJR19SRktJTExfSU5QVVQg
aXMgbm90IHNldAojIENPTkZJR19ORVRfOVAgaXMgbm90IHNldAoKIwojIERldmljZSBEcml2
ZXJzCiMKCiMKIyBHZW5lcmljIERyaXZlciBPcHRpb25zCiMKQ09ORklHX1VFVkVOVF9IRUxQ
RVJfUEFUSD0iL3NiaW4vaG90cGx1ZyIKIyBDT05GSUdfREVWVE1QRlMgaXMgbm90IHNldApD
T05GSUdfU1RBTkRBTE9ORT15CkNPTkZJR19QUkVWRU5UX0ZJUk1XQVJFX0JVSUxEPXkKQ09O
RklHX0ZXX0xPQURFUj1tCkNPTkZJR19GSVJNV0FSRV9JTl9LRVJORUw9eQpDT05GSUdfRVhU
UkFfRklSTVdBUkU9IiIKIyBDT05GSUdfREVCVUdfRFJJVkVSIGlzIG5vdCBzZXQKIyBDT05G
SUdfREVCVUdfREVWUkVTIGlzIG5vdCBzZXQKIyBDT05GSUdfU1lTX0hZUEVSVklTT1IgaXMg
bm90IHNldAojIENPTkZJR19DT05ORUNUT1IgaXMgbm90IHNldAojIENPTkZJR19NVEQgaXMg
bm90IHNldApDT05GSUdfUEFSUE9SVD1tCkNPTkZJR19QQVJQT1JUX1BDPW0KIyBDT05GSUdf
UEFSUE9SVF9TRVJJQUwgaXMgbm90IHNldApDT05GSUdfUEFSUE9SVF9QQ19GSUZPPXkKIyBD
T05GSUdfUEFSUE9SVF9QQ19TVVBFUklPIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFSUE9SVF9Q
Q19QQ01DSUEgaXMgbm90IHNldAojIENPTkZJR19QQVJQT1JUX0dTQyBpcyBub3Qgc2V0CiMg
Q09ORklHX1BBUlBPUlRfQVg4ODc5NiBpcyBub3Qgc2V0CkNPTkZJR19QQVJQT1JUXzEyODQ9
eQpDT05GSUdfUE5QPXkKQ09ORklHX1BOUF9ERUJVR19NRVNTQUdFUz15CgojCiMgUHJvdG9j
b2xzCiMKIyBDT05GSUdfSVNBUE5QIGlzIG5vdCBzZXQKIyBDT05GSUdfUE5QQklPUyBpcyBu
b3Qgc2V0CiMgQ09ORklHX1BOUEFDUEkgaXMgbm90IHNldApDT05GSUdfQkxLX0RFVj15CkNP
TkZJR19CTEtfREVWX0ZEPW0KIyBDT05GSUdfQkxLX0RFVl9YRCBpcyBub3Qgc2V0CiMgQ09O
RklHX1BBUklERSBpcyBub3Qgc2V0CiMgQ09ORklHX0JMS19DUFFfREEgaXMgbm90IHNldAoj
IENPTkZJR19CTEtfQ1BRX0NJU1NfREEgaXMgbm90IHNldAojIENPTkZJR19CTEtfREVWX0RB
Qzk2MCBpcyBub3Qgc2V0CiMgQ09ORklHX0JMS19ERVZfVU1FTSBpcyBub3Qgc2V0CiMgQ09O
RklHX0JMS19ERVZfQ09XX0NPTU1PTiBpcyBub3Qgc2V0CkNPTkZJR19CTEtfREVWX0xPT1A9
bQojIENPTkZJR19CTEtfREVWX0NSWVBUT0xPT1AgaXMgbm90IHNldAoKIwojIERSQkQgZGlz
YWJsZWQgYmVjYXVzZSBQUk9DX0ZTLCBJTkVUIG9yIENPTk5FQ1RPUiBub3Qgc2VsZWN0ZWQK
IwojIENPTkZJR19CTEtfREVWX05CRCBpcyBub3Qgc2V0CiMgQ09ORklHX0JMS19ERVZfU1g4
IGlzIG5vdCBzZXQKIyBDT05GSUdfQkxLX0RFVl9VQiBpcyBub3Qgc2V0CkNPTkZJR19CTEtf
REVWX1JBTT1tCkNPTkZJR19CTEtfREVWX1JBTV9DT1VOVD0xNgpDT05GSUdfQkxLX0RFVl9S
QU1fU0laRT00MDk2CiMgQ09ORklHX0JMS19ERVZfWElQIGlzIG5vdCBzZXQKQ09ORklHX0NE
Uk9NX1BLVENEVkQ9bQpDT05GSUdfQ0RST01fUEtUQ0RWRF9CVUZGRVJTPTgKIyBDT05GSUdf
Q0RST01fUEtUQ0RWRF9XQ0FDSEUgaXMgbm90IHNldAojIENPTkZJR19BVEFfT1ZFUl9FVEgg
aXMgbm90IHNldAojIENPTkZJR19CTEtfREVWX0hEIGlzIG5vdCBzZXQKQ09ORklHX01JU0Nf
REVWSUNFUz15CiMgQ09ORklHX0FENTI1WF9EUE9UIGlzIG5vdCBzZXQKIyBDT05GSUdfSUJN
X0FTTSBpcyBub3Qgc2V0CiMgQ09ORklHX1BIQU5UT00gaXMgbm90IHNldAojIENPTkZJR19T
R0lfSU9DNCBpcyBub3Qgc2V0CkNPTkZJR19USUZNX0NPUkU9bQpDT05GSUdfVElGTV83WFgx
PW0KIyBDT05GSUdfSUNTOTMyUzQwMSBpcyBub3Qgc2V0CiMgQ09ORklHX0VOQ0xPU1VSRV9T
RVJWSUNFUyBpcyBub3Qgc2V0CiMgQ09ORklHX0NTNTUzNV9NRkdQVCBpcyBub3Qgc2V0CiMg
Q09ORklHX0hQX0lMTyBpcyBub3Qgc2V0CiMgQ09ORklHX0lTTDI5MDAzIGlzIG5vdCBzZXQK
Q09ORklHX1NFTlNPUlNfVFNMMjU1MD1tCkNPTkZJR19EUzE2ODI9bQojIENPTkZJR19DMlBP
UlQgaXMgbm90IHNldAoKIwojIEVFUFJPTSBzdXBwb3J0CiMKIyBDT05GSUdfRUVQUk9NX0FU
MjQgaXMgbm90IHNldAojIENPTkZJR19FRVBST01fTEVHQUNZIGlzIG5vdCBzZXQKIyBDT05G
SUdfRUVQUk9NX01BWDY4NzUgaXMgbm90IHNldApDT05GSUdfRUVQUk9NXzkzQ1g2PW0KIyBD
T05GSUdfQ0I3MTBfQ09SRSBpcyBub3Qgc2V0CiMgQ09ORklHX0lXTUMzMjAwVE9QIGlzIG5v
dCBzZXQKQ09ORklHX0hBVkVfSURFPXkKQ09ORklHX0lERT15CgojCiMgUGxlYXNlIHNlZSBE
b2N1bWVudGF0aW9uL2lkZS9pZGUudHh0IGZvciBoZWxwL2luZm8gb24gSURFIGRyaXZlcwoj
CkNPTkZJR19JREVfWEZFUl9NT0RFPXkKQ09ORklHX0lERV9USU1JTkdTPXkKQ09ORklHX0lE
RV9BVEFQST15CiMgQ09ORklHX0JMS19ERVZfSURFX1NBVEEgaXMgbm90IHNldApDT05GSUdf
SURFX0dEPXkKQ09ORklHX0lERV9HRF9BVEE9eQojIENPTkZJR19JREVfR0RfQVRBUEkgaXMg
bm90IHNldAojIENPTkZJR19CTEtfREVWX0lERUNTIGlzIG5vdCBzZXQKIyBDT05GSUdfQkxL
X0RFVl9ERUxLSU4gaXMgbm90IHNldApDT05GSUdfQkxLX0RFVl9JREVDRD1tCkNPTkZJR19C
TEtfREVWX0lERUNEX1ZFUkJPU0VfRVJST1JTPXkKIyBDT05GSUdfQkxLX0RFVl9JREVUQVBF
IGlzIG5vdCBzZXQKQ09ORklHX0lERV9UQVNLX0lPQ1RMPXkKQ09ORklHX0lERV9QUk9DX0ZT
PXkKCiMKIyBJREUgY2hpcHNldCBzdXBwb3J0L2J1Z2ZpeGVzCiMKQ09ORklHX0lERV9HRU5F
UklDPXkKIyBDT05GSUdfQkxLX0RFVl9QTEFURk9STSBpcyBub3Qgc2V0CiMgQ09ORklHX0JM
S19ERVZfQ01ENjQwIGlzIG5vdCBzZXQKQ09ORklHX0JMS19ERVZfSURFUE5QPXkKQ09ORklH
X0JMS19ERVZfSURFRE1BX1NGRj15CgojCiMgUENJIElERSBjaGlwc2V0cyBzdXBwb3J0CiMK
Q09ORklHX0JMS19ERVZfSURFUENJPXkKQ09ORklHX0lERVBDSV9QQ0lCVVNfT1JERVI9eQoj
IENPTkZJR19CTEtfREVWX09GRkJPQVJEIGlzIG5vdCBzZXQKQ09ORklHX0JMS19ERVZfR0VO
RVJJQz15CiMgQ09ORklHX0JMS19ERVZfT1BUSTYyMSBpcyBub3Qgc2V0CiMgQ09ORklHX0JM
S19ERVZfUloxMDAwIGlzIG5vdCBzZXQKQ09ORklHX0JMS19ERVZfSURFRE1BX1BDST15CiMg
Q09ORklHX0JMS19ERVZfQUVDNjJYWCBpcyBub3Qgc2V0CiMgQ09ORklHX0JMS19ERVZfQUxJ
MTVYMyBpcyBub3Qgc2V0CiMgQ09ORklHX0JMS19ERVZfQU1ENzRYWCBpcyBub3Qgc2V0CiMg
Q09ORklHX0JMS19ERVZfQVRJSVhQIGlzIG5vdCBzZXQKIyBDT05GSUdfQkxLX0RFVl9DTUQ2
NFggaXMgbm90IHNldAojIENPTkZJR19CTEtfREVWX1RSSUZMRVggaXMgbm90IHNldAojIENP
TkZJR19CTEtfREVWX0NTNTUyMCBpcyBub3Qgc2V0CiMgQ09ORklHX0JMS19ERVZfQ1M1NTMw
IGlzIG5vdCBzZXQKIyBDT05GSUdfQkxLX0RFVl9DUzU1MzUgaXMgbm90IHNldAojIENPTkZJ
R19CTEtfREVWX0NTNTUzNiBpcyBub3Qgc2V0CiMgQ09ORklHX0JMS19ERVZfSFBUMzY2IGlz
IG5vdCBzZXQKIyBDT05GSUdfQkxLX0RFVl9KTUlDUk9OIGlzIG5vdCBzZXQKIyBDT05GSUdf
QkxLX0RFVl9TQzEyMDAgaXMgbm90IHNldAojIENPTkZJR19CTEtfREVWX1BJSVggaXMgbm90
IHNldAojIENPTkZJR19CTEtfREVWX0lUODE3MiBpcyBub3Qgc2V0CiMgQ09ORklHX0JMS19E
RVZfSVQ4MjEzIGlzIG5vdCBzZXQKIyBDT05GSUdfQkxLX0RFVl9JVDgyMVggaXMgbm90IHNl
dAojIENPTkZJR19CTEtfREVWX05TODc0MTUgaXMgbm90IHNldAojIENPTkZJR19CTEtfREVW
X1BEQzIwMlhYX09MRCBpcyBub3Qgc2V0CiMgQ09ORklHX0JMS19ERVZfUERDMjAyWFhfTkVX
IGlzIG5vdCBzZXQKIyBDT05GSUdfQkxLX0RFVl9TVldLUyBpcyBub3Qgc2V0CiMgQ09ORklH
X0JMS19ERVZfU0lJTUFHRSBpcyBub3Qgc2V0CiMgQ09ORklHX0JMS19ERVZfU0lTNTUxMyBp
cyBub3Qgc2V0CiMgQ09ORklHX0JMS19ERVZfU0xDOTBFNjYgaXMgbm90IHNldAojIENPTkZJ
R19CTEtfREVWX1RSTTI5MCBpcyBub3Qgc2V0CkNPTkZJR19CTEtfREVWX1ZJQTgyQ1hYWD15
CiMgQ09ORklHX0JMS19ERVZfVEM4NkMwMDEgaXMgbm90IHNldAoKIwojIE90aGVyIElERSBj
aGlwc2V0cyBzdXBwb3J0CiMKCiMKIyBOb3RlOiBtb3N0IG9mIHRoZXNlIGFsc28gcmVxdWly
ZSBzcGVjaWFsIGtlcm5lbCBib290IHBhcmFtZXRlcnMKIwojIENPTkZJR19CTEtfREVWXzRE
UklWRVMgaXMgbm90IHNldAojIENPTkZJR19CTEtfREVWX0FMSTE0WFggaXMgbm90IHNldAoj
IENPTkZJR19CTEtfREVWX0RUQzIyNzggaXMgbm90IHNldAojIENPTkZJR19CTEtfREVWX0hU
NjU2MEIgaXMgbm90IHNldAojIENPTkZJR19CTEtfREVWX1FENjVYWCBpcyBub3Qgc2V0CiMg
Q09ORklHX0JMS19ERVZfVU1DODY3MiBpcyBub3Qgc2V0CkNPTkZJR19CTEtfREVWX0lERURN
QT15CgojCiMgU0NTSSBkZXZpY2Ugc3VwcG9ydAojCkNPTkZJR19TQ1NJX01PRD1tCiMgQ09O
RklHX1JBSURfQVRUUlMgaXMgbm90IHNldApDT05GSUdfU0NTST1tCkNPTkZJR19TQ1NJX0RN
QT15CiMgQ09ORklHX1NDU0lfVEdUIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9ORVRMSU5L
IGlzIG5vdCBzZXQKQ09ORklHX1NDU0lfUFJPQ19GUz15CgojCiMgU0NTSSBzdXBwb3J0IHR5
cGUgKGRpc2ssIHRhcGUsIENELVJPTSkKIwpDT05GSUdfQkxLX0RFVl9TRD1tCiMgQ09ORklH
X0NIUl9ERVZfU1QgaXMgbm90IHNldAojIENPTkZJR19DSFJfREVWX09TU1QgaXMgbm90IHNl
dApDT05GSUdfQkxLX0RFVl9TUj1tCiMgQ09ORklHX0JMS19ERVZfU1JfVkVORE9SIGlzIG5v
dCBzZXQKQ09ORklHX0NIUl9ERVZfU0c9bQojIENPTkZJR19DSFJfREVWX1NDSCBpcyBub3Qg
c2V0CiMgQ09ORklHX1NDU0lfTVVMVElfTFVOIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9D
T05TVEFOVFMgaXMgbm90IHNldAojIENPTkZJR19TQ1NJX0xPR0dJTkcgaXMgbm90IHNldAoj
IENPTkZJR19TQ1NJX1NDQU5fQVNZTkMgaXMgbm90IHNldApDT05GSUdfU0NTSV9XQUlUX1ND
QU49bQoKIwojIFNDU0kgVHJhbnNwb3J0cwojCiMgQ09ORklHX1NDU0lfU1BJX0FUVFJTIGlz
IG5vdCBzZXQKIyBDT05GSUdfU0NTSV9GQ19BVFRSUyBpcyBub3Qgc2V0CiMgQ09ORklHX1ND
U0lfSVNDU0lfQVRUUlMgaXMgbm90IHNldAojIENPTkZJR19TQ1NJX1NBU19MSUJTQVMgaXMg
bm90IHNldAojIENPTkZJR19TQ1NJX1NSUF9BVFRSUyBpcyBub3Qgc2V0CiMgQ09ORklHX1ND
U0lfTE9XTEVWRUwgaXMgbm90IHNldAojIENPTkZJR19TQ1NJX0xPV0xFVkVMX1BDTUNJQSBp
cyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfREggaXMgbm90IHNldAojIENPTkZJR19TQ1NJX09T
RF9JTklUSUFUT1IgaXMgbm90IHNldAojIENPTkZJR19BVEEgaXMgbm90IHNldAojIENPTkZJ
R19NRCBpcyBub3Qgc2V0CiMgQ09ORklHX0ZVU0lPTiBpcyBub3Qgc2V0CgojCiMgSUVFRSAx
Mzk0IChGaXJlV2lyZSkgc3VwcG9ydAojCgojCiMgWW91IGNhbiBlbmFibGUgb25lIG9yIGJv
dGggRmlyZVdpcmUgZHJpdmVyIHN0YWNrcy4KIwoKIwojIFRoZSBuZXdlciBzdGFjayBpcyBy
ZWNvbW1lbmRlZC4KIwojIENPTkZJR19GSVJFV0lSRSBpcyBub3Qgc2V0CiMgQ09ORklHX0lF
RUUxMzk0IGlzIG5vdCBzZXQKIyBDT05GSUdfSTJPIGlzIG5vdCBzZXQKIyBDT05GSUdfTUFD
SU5UT1NIX0RSSVZFUlMgaXMgbm90IHNldApDT05GSUdfTkVUREVWSUNFUz15CkNPTkZJR19E
VU1NWT1tCiMgQ09ORklHX0JPTkRJTkcgaXMgbm90IHNldAojIENPTkZJR19NQUNWTEFOIGlz
IG5vdCBzZXQKIyBDT05GSUdfRVFVQUxJWkVSIGlzIG5vdCBzZXQKQ09ORklHX1RVTj1tCiMg
Q09ORklHX1ZFVEggaXMgbm90IHNldAojIENPTkZJR19ORVRfU0IxMDAwIGlzIG5vdCBzZXQK
IyBDT05GSUdfQVJDTkVUIGlzIG5vdCBzZXQKIyBDT05GSUdfUEhZTElCIGlzIG5vdCBzZXQK
Q09ORklHX05FVF9FVEhFUk5FVD15CkNPTkZJR19NSUk9bQojIENPTkZJR19IQVBQWU1FQUwg
aXMgbm90IHNldAojIENPTkZJR19TVU5HRU0gaXMgbm90IHNldAojIENPTkZJR19DQVNTSU5J
IGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl8zQ09NIGlzIG5vdCBzZXQKIyBDT05G
SUdfTEFOQ0UgaXMgbm90IHNldAojIENPTkZJR19ORVRfVkVORE9SX1NNQyBpcyBub3Qgc2V0
CiMgQ09ORklHX0VUSE9DIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9SQUNBTCBp
cyBub3Qgc2V0CiMgQ09ORklHX0RORVQgaXMgbm90IHNldAojIENPTkZJR19ORVRfVFVMSVAg
aXMgbm90IHNldAojIENPTkZJR19BVDE3MDAgaXMgbm90IHNldAojIENPTkZJR19ERVBDQSBp
cyBub3Qgc2V0CiMgQ09ORklHX0hQMTAwIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX0lTQSBp
cyBub3Qgc2V0CiMgQ09ORklHX0lCTV9ORVdfRU1BQ19aTUlJIGlzIG5vdCBzZXQKIyBDT05G
SUdfSUJNX05FV19FTUFDX1JHTUlJIGlzIG5vdCBzZXQKIyBDT05GSUdfSUJNX05FV19FTUFD
X1RBSCBpcyBub3Qgc2V0CiMgQ09ORklHX0lCTV9ORVdfRU1BQ19FTUFDNCBpcyBub3Qgc2V0
CiMgQ09ORklHX0lCTV9ORVdfRU1BQ19OT19GTE9XX0NUUkwgaXMgbm90IHNldAojIENPTkZJ
R19JQk1fTkVXX0VNQUNfTUFMX0NMUl9JQ0lOVFNUQVQgaXMgbm90IHNldAojIENPTkZJR19J
Qk1fTkVXX0VNQUNfTUFMX0NPTU1PTl9FUlIgaXMgbm90IHNldApDT05GSUdfTkVUX1BDST15
CiMgQ09ORklHX1BDTkVUMzIgaXMgbm90IHNldAojIENPTkZJR19BTUQ4MTExX0VUSCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0FEQVBURUNfU1RBUkZJUkUgaXMgbm90IHNldAojIENPTkZJR19B
QzMyMDAgaXMgbm90IHNldAojIENPTkZJR19LU1o4ODRYX1BDSSBpcyBub3Qgc2V0CiMgQ09O
RklHX0FQUklDT1QgaXMgbm90IHNldAojIENPTkZJR19CNDQgaXMgbm90IHNldAojIENPTkZJ
R19GT1JDRURFVEggaXMgbm90IHNldAojIENPTkZJR19DUzg5eDAgaXMgbm90IHNldAojIENP
TkZJR19FMTAwIGlzIG5vdCBzZXQKIyBDT05GSUdfTE5FMzkwIGlzIG5vdCBzZXQKIyBDT05G
SUdfRkVBTE5YIGlzIG5vdCBzZXQKIyBDT05GSUdfTkFUU0VNSSBpcyBub3Qgc2V0CiMgQ09O
RklHX05FMktfUENJIGlzIG5vdCBzZXQKIyBDT05GSUdfTkUzMjEwIGlzIG5vdCBzZXQKIyBD
T05GSUdfRVMzMjEwIGlzIG5vdCBzZXQKIyBDT05GSUdfODEzOUNQIGlzIG5vdCBzZXQKQ09O
RklHXzgxMzlUT089bQojIENPTkZJR184MTM5VE9PX1BJTyBpcyBub3Qgc2V0CiMgQ09ORklH
XzgxMzlUT09fVFVORV9UV0lTVEVSIGlzIG5vdCBzZXQKIyBDT05GSUdfODEzOVRPT184MTI5
IGlzIG5vdCBzZXQKIyBDT05GSUdfODEzOV9PTERfUlhfUkVTRVQgaXMgbm90IHNldAojIENP
TkZJR19SNjA0MCBpcyBub3Qgc2V0CiMgQ09ORklHX1NJUzkwMCBpcyBub3Qgc2V0CiMgQ09O
RklHX0VQSUMxMDAgaXMgbm90IHNldAojIENPTkZJR19TTVNDOTQyMCBpcyBub3Qgc2V0CiMg
Q09ORklHX1NVTkRBTkNFIGlzIG5vdCBzZXQKIyBDT05GSUdfVExBTiBpcyBub3Qgc2V0CiMg
Q09ORklHX0tTODg0MiBpcyBub3Qgc2V0CiMgQ09ORklHX0tTODg1MV9NTEwgaXMgbm90IHNl
dAojIENPTkZJR19WSUFfUkhJTkUgaXMgbm90IHNldAojIENPTkZJR19TQzkyMDMxIGlzIG5v
dCBzZXQKIyBDT05GSUdfTkVUX1BPQ0tFVCBpcyBub3Qgc2V0CiMgQ09ORklHX0FUTDIgaXMg
bm90IHNldAojIENPTkZJR19ORVRERVZfMTAwMCBpcyBub3Qgc2V0CiMgQ09ORklHX05FVERF
Vl8xMDAwMCBpcyBub3Qgc2V0CiMgQ09ORklHX1RSIGlzIG5vdCBzZXQKQ09ORklHX1dMQU49
eQojIENPTkZJR19QQ01DSUFfUkFZQ1MgaXMgbm90IHNldAojIENPTkZJR19MSUJFUlRBU19U
SElORklSTSBpcyBub3Qgc2V0CiMgQ09ORklHX0FJUk8gaXMgbm90IHNldAojIENPTkZJR19B
VE1FTCBpcyBub3Qgc2V0CiMgQ09ORklHX0FUNzZDNTBYX1VTQiBpcyBub3Qgc2V0CiMgQ09O
RklHX0FJUk9fQ1MgaXMgbm90IHNldAojIENPTkZJR19QQ01DSUFfV0wzNTAxIGlzIG5vdCBz
ZXQKIyBDT05GSUdfUFJJU001NCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9aRDEyMDEgaXMg
bm90IHNldAojIENPTkZJR19VU0JfTkVUX1JORElTX1dMQU4gaXMgbm90IHNldAojIENPTkZJ
R19SVEw4MTgwIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRMODE4NyBpcyBub3Qgc2V0CiMgQ09O
RklHX0FETTgyMTEgaXMgbm90IHNldAojIENPTkZJR19NQUM4MDIxMV9IV1NJTSBpcyBub3Qg
c2V0CiMgQ09ORklHX01XTDhLIGlzIG5vdCBzZXQKIyBDT05GSUdfQVRIX0NPTU1PTiBpcyBu
b3Qgc2V0CiMgQ09ORklHX0I0MyBpcyBub3Qgc2V0CiMgQ09ORklHX0I0M0xFR0FDWSBpcyBu
b3Qgc2V0CiMgQ09ORklHX0hPU1RBUCBpcyBub3Qgc2V0CiMgQ09ORklHX0lQVzIxMDAgaXMg
bm90IHNldAojIENPTkZJR19JUFcyMjAwIGlzIG5vdCBzZXQKIyBDT05GSUdfSVdMV0lGSSBp
cyBub3Qgc2V0CiMgQ09ORklHX0lXTSBpcyBub3Qgc2V0CiMgQ09ORklHX0xJQkVSVEFTIGlz
IG5vdCBzZXQKIyBDT05GSUdfSEVSTUVTIGlzIG5vdCBzZXQKIyBDT05GSUdfUDU0X0NPTU1P
TiBpcyBub3Qgc2V0CkNPTkZJR19SVDJYMDA9bQpDT05GSUdfUlQyNDAwUENJPW0KQ09ORklH
X1JUMjUwMFBDST1tCkNPTkZJR19SVDYxUENJPW0KQ09ORklHX1JUMjgwMFBDSV9QQ0k9eQpD
T05GSUdfUlQyODAwUENJPW0KIyBDT05GSUdfUlQyODAwUENJX1JUMzBYWCBpcyBub3Qgc2V0
CiMgQ09ORklHX1JUMjgwMFBDSV9SVDM1WFggaXMgbm90IHNldApDT05GSUdfUlQyNTAwVVNC
PW0KQ09ORklHX1JUNzNVU0I9bQpDT05GSUdfUlQyODAwVVNCPW0KIyBDT05GSUdfUlQyODAw
VVNCX1JUMzBYWCBpcyBub3Qgc2V0CiMgQ09ORklHX1JUMjgwMFVTQl9SVDM1WFggaXMgbm90
IHNldAojIENPTkZJR19SVDI4MDBVU0JfVU5LTk9XTiBpcyBub3Qgc2V0CkNPTkZJR19SVDI4
MDBfTElCPW0KQ09ORklHX1JUMlgwMF9MSUJfUENJPW0KQ09ORklHX1JUMlgwMF9MSUJfVVNC
PW0KQ09ORklHX1JUMlgwMF9MSUI9bQpDT05GSUdfUlQyWDAwX0xJQl9IVD15CkNPTkZJR19S
VDJYMDBfTElCX0ZJUk1XQVJFPXkKQ09ORklHX1JUMlgwMF9MSUJfQ1JZUFRPPXkKQ09ORklH
X1JUMlgwMF9MSUJfTEVEUz15CkNPTkZJR19SVDJYMDBfREVCVUc9eQojIENPTkZJR19XTDEy
WFggaXMgbm90IHNldAojIENPTkZJR19aRDEyMTFSVyBpcyBub3Qgc2V0CgojCiMgRW5hYmxl
IFdpTUFYIChOZXR3b3JraW5nIG9wdGlvbnMpIHRvIHNlZSB0aGUgV2lNQVggZHJpdmVycwoj
CgojCiMgVVNCIE5ldHdvcmsgQWRhcHRlcnMKIwojIENPTkZJR19VU0JfQ0FUQyBpcyBub3Qg
c2V0CiMgQ09ORklHX1VTQl9LQVdFVEggaXMgbm90IHNldAojIENPTkZJR19VU0JfUEVHQVNV
UyBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9SVEw4MTUwIGlzIG5vdCBzZXQKIyBDT05GSUdf
VVNCX1VTQk5FVCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9IU08gaXMgbm90IHNldAojIENP
TkZJR19ORVRfUENNQ0lBIGlzIG5vdCBzZXQKIyBDT05GSUdfV0FOIGlzIG5vdCBzZXQKIyBD
T05GSUdfRkRESSBpcyBub3Qgc2V0CiMgQ09ORklHX0hJUFBJIGlzIG5vdCBzZXQKQ09ORklH
X1BMSVA9bQpDT05GSUdfUFBQPW0KIyBDT05GSUdfUFBQX01VTFRJTElOSyBpcyBub3Qgc2V0
CkNPTkZJR19QUFBfRklMVEVSPXkKQ09ORklHX1BQUF9BU1lOQz1tCiMgQ09ORklHX1BQUF9T
WU5DX1RUWSBpcyBub3Qgc2V0CkNPTkZJR19QUFBfREVGTEFURT1tCkNPTkZJR19QUFBfQlNE
Q09NUD1tCkNPTkZJR19QUFBfTVBQRT1tCkNPTkZJR19QUFBPRT1tCiMgQ09ORklHX1BQUE9M
MlRQIGlzIG5vdCBzZXQKIyBDT05GSUdfU0xJUCBpcyBub3Qgc2V0CkNPTkZJR19TTEhDPW0K
IyBDT05GSUdfTkVUX0ZDIGlzIG5vdCBzZXQKQ09ORklHX05FVENPTlNPTEU9bQojIENPTkZJ
R19ORVRDT05TT0xFX0RZTkFNSUMgaXMgbm90IHNldApDT05GSUdfTkVUUE9MTD15CiMgQ09O
RklHX05FVFBPTExfVFJBUCBpcyBub3Qgc2V0CkNPTkZJR19ORVRfUE9MTF9DT05UUk9MTEVS
PXkKIyBDT05GSUdfVk1YTkVUMyBpcyBub3Qgc2V0CiMgQ09ORklHX0lTRE4gaXMgbm90IHNl
dAojIENPTkZJR19QSE9ORSBpcyBub3Qgc2V0CgojCiMgSW5wdXQgZGV2aWNlIHN1cHBvcnQK
IwpDT05GSUdfSU5QVVQ9eQojIENPTkZJR19JTlBVVF9GRl9NRU1MRVNTIGlzIG5vdCBzZXQK
Q09ORklHX0lOUFVUX1BPTExERVY9bQpDT05GSUdfSU5QVVRfU1BBUlNFS01BUD1tCgojCiMg
VXNlcmxhbmQgaW50ZXJmYWNlcwojCkNPTkZJR19JTlBVVF9NT1VTRURFVj1tCkNPTkZJR19J
TlBVVF9NT1VTRURFVl9QU0FVWD15CkNPTkZJR19JTlBVVF9NT1VTRURFVl9TQ1JFRU5fWD0x
MDI0CkNPTkZJR19JTlBVVF9NT1VTRURFVl9TQ1JFRU5fWT03NjgKIyBDT05GSUdfSU5QVVRf
Sk9ZREVWIGlzIG5vdCBzZXQKQ09ORklHX0lOUFVUX0VWREVWPW0KQ09ORklHX0lOUFVUX0VW
QlVHPW0KCiMKIyBJbnB1dCBEZXZpY2UgRHJpdmVycwojCkNPTkZJR19JTlBVVF9LRVlCT0FS
RD15CiMgQ09ORklHX0tFWUJPQVJEX0FEUDU1ODggaXMgbm90IHNldApDT05GSUdfS0VZQk9B
UkRfQVRLQkQ9eQojIENPTkZJR19RVDIxNjAgaXMgbm90IHNldAojIENPTkZJR19LRVlCT0FS
RF9MS0tCRCBpcyBub3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX0xNODMyMyBpcyBub3Qgc2V0
CiMgQ09ORklHX0tFWUJPQVJEX01BWDczNTkgaXMgbm90IHNldAojIENPTkZJR19LRVlCT0FS
RF9ORVdUT04gaXMgbm90IHNldAojIENPTkZJR19LRVlCT0FSRF9PUEVOQ09SRVMgaXMgbm90
IHNldAojIENPTkZJR19LRVlCT0FSRF9TVE9XQVdBWSBpcyBub3Qgc2V0CiMgQ09ORklHX0tF
WUJPQVJEX1NVTktCRCBpcyBub3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX1hUS0JEIGlzIG5v
dCBzZXQKQ09ORklHX0lOUFVUX01PVVNFPXkKQ09ORklHX01PVVNFX1BTMj1tCkNPTkZJR19N
T1VTRV9QUzJfQUxQUz15CkNPTkZJR19NT1VTRV9QUzJfTE9HSVBTMlBQPXkKQ09ORklHX01P
VVNFX1BTMl9TWU5BUFRJQ1M9eQpDT05GSUdfTU9VU0VfUFMyX0xJRkVCT09LPXkKQ09ORklH
X01PVVNFX1BTMl9UUkFDS1BPSU5UPXkKIyBDT05GSUdfTU9VU0VfUFMyX0VMQU5URUNIIGlz
IG5vdCBzZXQKIyBDT05GSUdfTU9VU0VfUFMyX1NFTlRFTElDIGlzIG5vdCBzZXQKIyBDT05G
SUdfTU9VU0VfUFMyX1RPVUNIS0lUIGlzIG5vdCBzZXQKQ09ORklHX01PVVNFX1NFUklBTD1t
CiMgQ09ORklHX01PVVNFX0FQUExFVE9VQ0ggaXMgbm90IHNldAojIENPTkZJR19NT1VTRV9C
Q001OTc0IGlzIG5vdCBzZXQKIyBDT05GSUdfTU9VU0VfSU5QT1JUIGlzIG5vdCBzZXQKIyBD
T05GSUdfTU9VU0VfTE9HSUJNIGlzIG5vdCBzZXQKIyBDT05GSUdfTU9VU0VfUEMxMTBQQUQg
aXMgbm90IHNldAojIENPTkZJR19NT1VTRV9WU1hYWEFBIGlzIG5vdCBzZXQKIyBDT05GSUdf
TU9VU0VfU1lOQVBUSUNTX0kyQyBpcyBub3Qgc2V0CiMgQ09ORklHX0lOUFVUX0pPWVNUSUNL
IGlzIG5vdCBzZXQKIyBDT05GSUdfSU5QVVRfVEFCTEVUIGlzIG5vdCBzZXQKIyBDT05GSUdf
SU5QVVRfVE9VQ0hTQ1JFRU4gaXMgbm90IHNldApDT05GSUdfSU5QVVRfTUlTQz15CkNPTkZJ
R19JTlBVVF9QQ1NQS1I9bQojIENPTkZJR19JTlBVVF9BUEFORUwgaXMgbm90IHNldApDT05G
SUdfSU5QVVRfV0lTVFJPTl9CVE5TPW0KIyBDT05GSUdfSU5QVVRfQVRJX1JFTU9URSBpcyBu
b3Qgc2V0CiMgQ09ORklHX0lOUFVUX0FUSV9SRU1PVEUyIGlzIG5vdCBzZXQKIyBDT05GSUdf
SU5QVVRfS0VZU1BBTl9SRU1PVEUgaXMgbm90IHNldAojIENPTkZJR19JTlBVVF9QT1dFUk1B
VEUgaXMgbm90IHNldAojIENPTkZJR19JTlBVVF9ZRUFMSU5LIGlzIG5vdCBzZXQKIyBDT05G
SUdfSU5QVVRfQ00xMDkgaXMgbm90IHNldApDT05GSUdfSU5QVVRfVUlOUFVUPW0KIyBDT05G
SUdfSU5QVVRfV0lOQk9ORF9DSVIgaXMgbm90IHNldAoKIwojIEhhcmR3YXJlIEkvTyBwb3J0
cwojCkNPTkZJR19TRVJJTz15CkNPTkZJR19TRVJJT19JODA0Mj15CkNPTkZJR19TRVJJT19T
RVJQT1JUPW0KIyBDT05GSUdfU0VSSU9fQ1Q4MkM3MTAgaXMgbm90IHNldAojIENPTkZJR19T
RVJJT19QQVJLQkQgaXMgbm90IHNldAojIENPTkZJR19TRVJJT19QQ0lQUzIgaXMgbm90IHNl
dApDT05GSUdfU0VSSU9fTElCUFMyPXkKQ09ORklHX1NFUklPX1JBVz1tCiMgQ09ORklHX1NF
UklPX0FMVEVSQV9QUzIgaXMgbm90IHNldAojIENPTkZJR19HQU1FUE9SVCBpcyBub3Qgc2V0
CgojCiMgQ2hhcmFjdGVyIGRldmljZXMKIwpDT05GSUdfVlQ9eQpDT05GSUdfQ09OU09MRV9U
UkFOU0xBVElPTlM9eQpDT05GSUdfVlRfQ09OU09MRT15CkNPTkZJR19IV19DT05TT0xFPXkK
IyBDT05GSUdfVlRfSFdfQ09OU09MRV9CSU5ESU5HIGlzIG5vdCBzZXQKQ09ORklHX0RFVktN
RU09eQojIENPTkZJR19TRVJJQUxfTk9OU1RBTkRBUkQgaXMgbm90IHNldAojIENPTkZJR19O
T1pPTUkgaXMgbm90IHNldAoKIwojIFNlcmlhbCBkcml2ZXJzCiMKQ09ORklHX1NFUklBTF84
MjUwPW0KQ09ORklHX0ZJWF9FQVJMWUNPTl9NRU09eQpDT05GSUdfU0VSSUFMXzgyNTBfUENJ
PW0KQ09ORklHX1NFUklBTF84MjUwX1BOUD1tCiMgQ09ORklHX1NFUklBTF84MjUwX0NTIGlz
IG5vdCBzZXQKQ09ORklHX1NFUklBTF84MjUwX05SX1VBUlRTPTQKQ09ORklHX1NFUklBTF84
MjUwX1JVTlRJTUVfVUFSVFM9NAojIENPTkZJR19TRVJJQUxfODI1MF9FWFRFTkRFRCBpcyBu
b3Qgc2V0CgojCiMgTm9uLTgyNTAgc2VyaWFsIHBvcnQgc3VwcG9ydAojCkNPTkZJR19TRVJJ
QUxfQ09SRT1tCiMgQ09ORklHX1NFUklBTF9KU00gaXMgbm90IHNldAojIENPTkZJR19TRVJJ
QUxfVElNQkVSREFMRSBpcyBub3Qgc2V0CkNPTkZJR19VTklYOThfUFRZUz15CiMgQ09ORklH
X0RFVlBUU19NVUxUSVBMRV9JTlNUQU5DRVMgaXMgbm90IHNldApDT05GSUdfTEVHQUNZX1BU
WVM9eQpDT05GSUdfTEVHQUNZX1BUWV9DT1VOVD0yNTYKQ09ORklHX1BSSU5URVI9bQojIENP
TkZJR19MUF9DT05TT0xFIGlzIG5vdCBzZXQKQ09ORklHX1BQREVWPW0KIyBDT05GSUdfSVBN
SV9IQU5ETEVSIGlzIG5vdCBzZXQKIyBDT05GSUdfSFdfUkFORE9NIGlzIG5vdCBzZXQKQ09O
RklHX05WUkFNPW0KIyBDT05GSUdfRFRMSyBpcyBub3Qgc2V0CiMgQ09ORklHX1IzOTY0IGlz
IG5vdCBzZXQKIyBDT05GSUdfQVBQTElDT00gaXMgbm90IHNldAojIENPTkZJR19TT05ZUEkg
aXMgbm90IHNldAoKIwojIFBDTUNJQSBjaGFyYWN0ZXIgZGV2aWNlcwojCiMgQ09ORklHX1NZ
TkNMSU5LX0NTIGlzIG5vdCBzZXQKIyBDT05GSUdfQ0FSRE1BTl80MDAwIGlzIG5vdCBzZXQK
IyBDT05GSUdfQ0FSRE1BTl80MDQwIGlzIG5vdCBzZXQKIyBDT05GSUdfSVBXSVJFTEVTUyBp
cyBub3Qgc2V0CiMgQ09ORklHX01XQVZFIGlzIG5vdCBzZXQKIyBDT05GSUdfUEM4NzM2eF9H
UElPIGlzIG5vdCBzZXQKIyBDT05GSUdfTlNDX0dQSU8gaXMgbm90IHNldAojIENPTkZJR19D
UzU1MzVfR1BJTyBpcyBub3Qgc2V0CiMgQ09ORklHX1JBV19EUklWRVIgaXMgbm90IHNldApD
T05GSUdfSEFOR0NIRUNLX1RJTUVSPW0KIyBDT05GSUdfVENHX1RQTSBpcyBub3Qgc2V0CiMg
Q09ORklHX1RFTENMT0NLIGlzIG5vdCBzZXQKQ09ORklHX0RFVlBPUlQ9eQpDT05GSUdfSTJD
PW0KQ09ORklHX0kyQ19CT0FSRElORk89eQpDT05GSUdfSTJDX0NPTVBBVD15CkNPTkZJR19J
MkNfQ0hBUkRFVj1tCkNPTkZJR19JMkNfSEVMUEVSX0FVVE89eQpDT05GSUdfSTJDX1NNQlVT
PW0KQ09ORklHX0kyQ19BTEdPQklUPW0KQ09ORklHX0kyQ19BTEdPUENBPW0KCiMKIyBJMkMg
SGFyZHdhcmUgQnVzIHN1cHBvcnQKIwoKIwojIFBDIFNNQnVzIGhvc3QgY29udHJvbGxlciBk
cml2ZXJzCiMKQ09ORklHX0kyQ19BTEkxNTM1PW0KQ09ORklHX0kyQ19BTEkxNTYzPW0KQ09O
RklHX0kyQ19BTEkxNVgzPW0KQ09ORklHX0kyQ19BTUQ3NTY9bQpDT05GSUdfSTJDX0FNRDc1
Nl9TNDg4Mj1tCkNPTkZJR19JMkNfQU1EODExMT1tCkNPTkZJR19JMkNfSTgwMT1tCiMgQ09O
RklHX0kyQ19JU0NIIGlzIG5vdCBzZXQKQ09ORklHX0kyQ19QSUlYND1tCkNPTkZJR19JMkNf
TkZPUkNFMj1tCiMgQ09ORklHX0kyQ19ORk9SQ0UyX1M0OTg1IGlzIG5vdCBzZXQKQ09ORklH
X0kyQ19TSVM1NTk1PW0KQ09ORklHX0kyQ19TSVM2MzA9bQpDT05GSUdfSTJDX1NJUzk2WD1t
CkNPTkZJR19JMkNfVklBPW0KQ09ORklHX0kyQ19WSUFQUk89bQoKIwojIEkyQyBzeXN0ZW0g
YnVzIGRyaXZlcnMgKG1vc3RseSBlbWJlZGRlZCAvIHN5c3RlbS1vbi1jaGlwKQojCkNPTkZJ
R19JMkNfT0NPUkVTPW0KQ09ORklHX0kyQ19TSU1URUM9bQojIENPTkZJR19JMkNfWElMSU5Y
IGlzIG5vdCBzZXQKCiMKIyBFeHRlcm5hbCBJMkMvU01CdXMgYWRhcHRlciBkcml2ZXJzCiMK
Q09ORklHX0kyQ19QQVJQT1JUPW0KQ09ORklHX0kyQ19QQVJQT1JUX0xJR0hUPW0KQ09ORklH
X0kyQ19UQU9TX0VWTT1tCkNPTkZJR19JMkNfVElOWV9VU0I9bQoKIwojIE90aGVyIEkyQy9T
TUJ1cyBidXMgZHJpdmVycwojCiMgQ09ORklHX0kyQ19FTEVLVE9SIGlzIG5vdCBzZXQKQ09O
RklHX0kyQ19QQ0FfSVNBPW0KIyBDT05GSUdfSTJDX1BDQV9QTEFURk9STSBpcyBub3Qgc2V0
CkNPTkZJR19JMkNfU1RVQj1tCkNPTkZJR19TQ3gyMDBfQUNCPW0KIyBDT05GSUdfSTJDX0RF
QlVHX0NPUkUgaXMgbm90IHNldAojIENPTkZJR19JMkNfREVCVUdfQUxHTyBpcyBub3Qgc2V0
CiMgQ09ORklHX0kyQ19ERUJVR19CVVMgaXMgbm90IHNldAojIENPTkZJR19TUEkgaXMgbm90
IHNldAoKIwojIFBQUyBzdXBwb3J0CiMKIyBDT05GSUdfUFBTIGlzIG5vdCBzZXQKQ09ORklH
X0FSQ0hfV0FOVF9PUFRJT05BTF9HUElPTElCPXkKIyBDT05GSUdfR1BJT0xJQiBpcyBub3Qg
c2V0CiMgQ09ORklHX1cxIGlzIG5vdCBzZXQKQ09ORklHX1BPV0VSX1NVUFBMWT15CiMgQ09O
RklHX1BPV0VSX1NVUFBMWV9ERUJVRyBpcyBub3Qgc2V0CiMgQ09ORklHX1BEQV9QT1dFUiBp
cyBub3Qgc2V0CiMgQ09ORklHX0JBVFRFUllfRFMyNzYwIGlzIG5vdCBzZXQKIyBDT05GSUdf
QkFUVEVSWV9EUzI3ODIgaXMgbm90IHNldAojIENPTkZJR19CQVRURVJZX0JRMjd4MDAgaXMg
bm90IHNldAojIENPTkZJR19CQVRURVJZX01BWDE3MDQwIGlzIG5vdCBzZXQKQ09ORklHX0hX
TU9OPW0KQ09ORklHX0hXTU9OX1ZJRD1tCiMgQ09ORklHX0hXTU9OX0RFQlVHX0NISVAgaXMg
bm90IHNldAoKIwojIE5hdGl2ZSBkcml2ZXJzCiMKQ09ORklHX1NFTlNPUlNfQUJJVFVHVVJV
PW0KQ09ORklHX1NFTlNPUlNfQUJJVFVHVVJVMz1tCkNPTkZJR19TRU5TT1JTX0FENzQxND1t
CkNPTkZJR19TRU5TT1JTX0FENzQxOD1tCkNPTkZJR19TRU5TT1JTX0FETTEwMjE9bQpDT05G
SUdfU0VOU09SU19BRE0xMDI1PW0KQ09ORklHX1NFTlNPUlNfQURNMTAyNj1tCkNPTkZJR19T
RU5TT1JTX0FETTEwMjk9bQpDT05GSUdfU0VOU09SU19BRE0xMDMxPW0KQ09ORklHX1NFTlNP
UlNfQURNOTI0MD1tCiMgQ09ORklHX1NFTlNPUlNfQURUNzQxMSBpcyBub3Qgc2V0CiMgQ09O
RklHX1NFTlNPUlNfQURUNzQ2MiBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfQURUNzQ3
MCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfQURUNzQ3NSBpcyBub3Qgc2V0CiMgQ09O
RklHX1NFTlNPUlNfQVNDNzYyMSBpcyBub3Qgc2V0CkNPTkZJR19TRU5TT1JTX0s4VEVNUD1t
CiMgQ09ORklHX1NFTlNPUlNfSzEwVEVNUCBpcyBub3Qgc2V0CkNPTkZJR19TRU5TT1JTX0FT
QjEwMD1tCkNPTkZJR19TRU5TT1JTX0FUWFAxPW0KQ09ORklHX1NFTlNPUlNfRFMxNjIxPW0K
IyBDT05GSUdfU0VOU09SU19JNUtfQU1CIGlzIG5vdCBzZXQKQ09ORklHX1NFTlNPUlNfRjcx
ODA1Rj1tCiMgQ09ORklHX1NFTlNPUlNfRjcxODgyRkcgaXMgbm90IHNldAojIENPTkZJR19T
RU5TT1JTX0Y3NTM3NVMgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0ZTQ0hNRCBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfRzc2MEEgaXMgbm90IHNldApDT05GSUdfU0VOU09S
U19HTDUxOFNNPW0KQ09ORklHX1NFTlNPUlNfR0w1MjBTTT1tCkNPTkZJR19TRU5TT1JTX0NP
UkVURU1QPW0KQ09ORklHX1NFTlNPUlNfSVQ4Nz1tCkNPTkZJR19TRU5TT1JTX0xNNjM9bQoj
IENPTkZJR19TRU5TT1JTX0xNNzMgaXMgbm90IHNldApDT05GSUdfU0VOU09SU19MTTc1PW0K
Q09ORklHX1NFTlNPUlNfTE03Nz1tCkNPTkZJR19TRU5TT1JTX0xNNzg9bQpDT05GSUdfU0VO
U09SU19MTTgwPW0KQ09ORklHX1NFTlNPUlNfTE04Mz1tCkNPTkZJR19TRU5TT1JTX0xNODU9
bQpDT05GSUdfU0VOU09SU19MTTg3PW0KQ09ORklHX1NFTlNPUlNfTE05MD1tCkNPTkZJR19T
RU5TT1JTX0xNOTI9bQpDT05GSUdfU0VOU09SU19MTTkzPW0KIyBDT05GSUdfU0VOU09SU19M
VEM0MjE1IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19MVEM0MjQ1IGlzIG5vdCBzZXQK
IyBDT05GSUdfU0VOU09SU19MTTk1MjQxIGlzIG5vdCBzZXQKQ09ORklHX1NFTlNPUlNfTUFY
MTYxOT1tCkNPTkZJR19TRU5TT1JTX01BWDY2NTA9bQpDT05GSUdfU0VOU09SU19QQzg3MzYw
PW0KQ09ORklHX1NFTlNPUlNfUEM4NzQyNz1tCkNPTkZJR19TRU5TT1JTX1BDRjg1OTE9bQpD
T05GSUdfU0VOU09SU19TSVM1NTk1PW0KQ09ORklHX1NFTlNPUlNfRE1FMTczNz1tCkNPTkZJ
R19TRU5TT1JTX1NNU0M0N00xPW0KQ09ORklHX1NFTlNPUlNfU01TQzQ3TTE5Mj1tCkNPTkZJ
R19TRU5TT1JTX1NNU0M0N0IzOTc9bQojIENPTkZJR19TRU5TT1JTX0FEUzc4MjggaXMgbm90
IHNldAojIENPTkZJR19TRU5TT1JTX0FNQzY4MjEgaXMgbm90IHNldApDT05GSUdfU0VOU09S
U19USE1DNTA9bQojIENPTkZJR19TRU5TT1JTX1RNUDQwMSBpcyBub3Qgc2V0CiMgQ09ORklH
X1NFTlNPUlNfVE1QNDIxIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19WSUFfQ1BVVEVN
UCBpcyBub3Qgc2V0CkNPTkZJR19TRU5TT1JTX1ZJQTY4NkE9bQpDT05GSUdfU0VOU09SU19W
VDEyMTE9bQpDT05GSUdfU0VOU09SU19WVDgyMzE9bQpDT05GSUdfU0VOU09SU19XODM3ODFE
PW0KQ09ORklHX1NFTlNPUlNfVzgzNzkxRD1tCkNPTkZJR19TRU5TT1JTX1c4Mzc5MkQ9bQpD
T05GSUdfU0VOU09SU19XODM3OTM9bQpDT05GSUdfU0VOU09SU19XODNMNzg1VFM9bQojIENP
TkZJR19TRU5TT1JTX1c4M0w3ODZORyBpcyBub3Qgc2V0CkNPTkZJR19TRU5TT1JTX1c4MzYy
N0hGPW0KQ09ORklHX1NFTlNPUlNfVzgzNjI3RUhGPW0KQ09ORklHX1NFTlNPUlNfSERBUFM9
bQojIENPTkZJR19TRU5TT1JTX0xJUzNfSTJDIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09S
U19BUFBMRVNNQyBpcyBub3Qgc2V0CkNPTkZJR19USEVSTUFMPXkKIyBDT05GSUdfV0FUQ0hE
T0cgaXMgbm90IHNldApDT05GSUdfU1NCX1BPU1NJQkxFPXkKCiMKIyBTb25pY3MgU2lsaWNv
biBCYWNrcGxhbmUKIwojIENPTkZJR19TU0IgaXMgbm90IHNldAoKIwojIE11bHRpZnVuY3Rp
b24gZGV2aWNlIGRyaXZlcnMKIwojIENPTkZJR19NRkRfQ09SRSBpcyBub3Qgc2V0CiMgQ09O
RklHX01GRF9TTTUwMSBpcyBub3Qgc2V0CiMgQ09ORklHX0hUQ19QQVNJQzMgaXMgbm90IHNl
dAojIENPTkZJR19NRkRfVE1JTyBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9XTTg0MDAgaXMg
bm90IHNldAojIENPTkZJR19NRkRfV004OTk0IGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX1BD
RjUwNjMzIGlzIG5vdCBzZXQKIyBDT05GSUdfTFBDX1NDSCBpcyBub3Qgc2V0CiMgQ09ORklH
X1JFR1VMQVRPUiBpcyBub3Qgc2V0CkNPTkZJR19NRURJQV9TVVBQT1JUPW0KCiMKIyBNdWx0
aW1lZGlhIGNvcmUgc3VwcG9ydAojCkNPTkZJR19WSURFT19ERVY9bQpDT05GSUdfVklERU9f
VjRMMl9DT01NT049bQpDT05GSUdfVklERU9fQUxMT1dfVjRMMT15CkNPTkZJR19WSURFT19W
NEwxX0NPTVBBVD15CiMgQ09ORklHX0RWQl9DT1JFIGlzIG5vdCBzZXQKQ09ORklHX1ZJREVP
X01FRElBPW0KCiMKIyBNdWx0aW1lZGlhIGRyaXZlcnMKIwpDT05GSUdfSVJfQ09SRT1tCkNP
TkZJR19WSURFT19JUj1tCiMgQ09ORklHX01FRElBX0FUVEFDSCBpcyBub3Qgc2V0CkNPTkZJ
R19NRURJQV9UVU5FUj1tCiMgQ09ORklHX01FRElBX1RVTkVSX0NVU1RPTUlTRSBpcyBub3Qg
c2V0CkNPTkZJR19NRURJQV9UVU5FUl9TSU1QTEU9bQpDT05GSUdfTUVESUFfVFVORVJfVERB
ODI5MD1tCkNPTkZJR19NRURJQV9UVU5FUl9UREE5ODg3PW0KQ09ORklHX01FRElBX1RVTkVS
X1RFQTU3NjE9bQpDT05GSUdfTUVESUFfVFVORVJfVEVBNTc2Nz1tCkNPTkZJR19NRURJQV9U
VU5FUl9NVDIwWFg9bQpDT05GSUdfTUVESUFfVFVORVJfWEMyMDI4PW0KQ09ORklHX01FRElB
X1RVTkVSX1hDNTAwMD1tCkNPTkZJR19NRURJQV9UVU5FUl9NQzQ0UzgwMz1tCkNPTkZJR19W
SURFT19WNEwyPW0KQ09ORklHX1ZJREVPX1Y0TDE9bQpDT05GSUdfVklERU9CVUZfR0VOPW0K
Q09ORklHX1ZJREVPQlVGX1ZNQUxMT0M9bQpDT05GSUdfVklERU9fVFZFRVBST009bQpDT05G
SUdfVklERU9fVFVORVI9bQpDT05GSUdfVklERU9fQ0FQVFVSRV9EUklWRVJTPXkKIyBDT05G
SUdfVklERU9fQURWX0RFQlVHIGlzIG5vdCBzZXQKIyBDT05GSUdfVklERU9fRklYRURfTUlO
T1JfUkFOR0VTIGlzIG5vdCBzZXQKQ09ORklHX1ZJREVPX0hFTFBFUl9DSElQU19BVVRPPXkK
Q09ORklHX1ZJREVPX0lSX0kyQz1tCkNPTkZJR19WSURFT19NU1AzNDAwPW0KQ09ORklHX1ZJ
REVPX01UOVYwMTE9bQpDT05GSUdfVklERU9fU0FBNzExWD1tCkNPTkZJR19WSURFT19UVlA1
MTUwPW0KQ09ORklHX1ZJREVPX1ZJVkk9bQojIENPTkZJR19WSURFT19CVDg0OCBpcyBub3Qg
c2V0CiMgQ09ORklHX1ZJREVPX1BNUyBpcyBub3Qgc2V0CiMgQ09ORklHX1ZJREVPX0JXUUNB
TSBpcyBub3Qgc2V0CiMgQ09ORklHX1ZJREVPX0NRQ0FNIGlzIG5vdCBzZXQKIyBDT05GSUdf
VklERU9fVzk5NjYgaXMgbm90IHNldAojIENPTkZJR19WSURFT19DUElBIGlzIG5vdCBzZXQK
IyBDT05GSUdfVklERU9fQ1BJQTIgaXMgbm90IHNldAojIENPTkZJR19WSURFT19TQUE1MjQ2
QSBpcyBub3Qgc2V0CiMgQ09ORklHX1ZJREVPX1NBQTUyNDkgaXMgbm90IHNldAojIENPTkZJ
R19WSURFT19TVFJBRElTIGlzIG5vdCBzZXQKIyBDT05GSUdfVklERU9fWk9SQU4gaXMgbm90
IHNldAojIENPTkZJR19WSURFT19TQUE3MTM0IGlzIG5vdCBzZXQKIyBDT05GSUdfVklERU9f
TVhCIGlzIG5vdCBzZXQKIyBDT05GSUdfVklERU9fSEVYSVVNX09SSU9OIGlzIG5vdCBzZXQK
IyBDT05GSUdfVklERU9fSEVYSVVNX0dFTUlOSSBpcyBub3Qgc2V0CiMgQ09ORklHX1ZJREVP
X0NYODggaXMgbm90IHNldAojIENPTkZJR19WSURFT19JVlRWIGlzIG5vdCBzZXQKIyBDT05G
SUdfVklERU9fQ0FGRV9DQ0lDIGlzIG5vdCBzZXQKIyBDT05GSUdfU09DX0NBTUVSQSBpcyBu
b3Qgc2V0CkNPTkZJR19WNExfVVNCX0RSSVZFUlM9eQpDT05GSUdfVVNCX1ZJREVPX0NMQVNT
PW0KQ09ORklHX1VTQl9WSURFT19DTEFTU19JTlBVVF9FVkRFVj15CkNPTkZJR19VU0JfR1NQ
Q0E9bQojIENPTkZJR19VU0JfTTU2MDIgaXMgbm90IHNldAojIENPTkZJR19VU0JfU1RWMDZY
WCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9HTDg2MCBpcyBub3Qgc2V0CiMgQ09ORklHX1VT
Ql9HU1BDQV9CRU5RIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0dTUENBX0NPTkVYIGlzIG5v
dCBzZXQKIyBDT05GSUdfVVNCX0dTUENBX0NQSUExIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNC
X0dTUENBX0VUT01TIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0dTUENBX0ZJTkVQSVggaXMg
bm90IHNldAojIENPTkZJR19VU0JfR1NQQ0FfSkVJTElOSiBpcyBub3Qgc2V0CiMgQ09ORklH
X1VTQl9HU1BDQV9NQVJTIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0dTUENBX01SOTczMTBB
IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0dTUENBX09WNTE5IGlzIG5vdCBzZXQKIyBDT05G
SUdfVVNCX0dTUENBX09WNTM0IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0dTUENBX09WNTM0
XzkgaXMgbm90IHNldAojIENPTkZJR19VU0JfR1NQQ0FfUEFDMjA3IGlzIG5vdCBzZXQKQ09O
RklHX1VTQl9HU1BDQV9QQUM3MzAyPW0KIyBDT05GSUdfVVNCX0dTUENBX1BBQzczMTEgaXMg
bm90IHNldAojIENPTkZJR19VU0JfR1NQQ0FfU045QzIwMjggaXMgbm90IHNldAojIENPTkZJ
R19VU0JfR1NQQ0FfU045QzIwWCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9HU1BDQV9TT05J
WEIgaXMgbm90IHNldAojIENPTkZJR19VU0JfR1NQQ0FfU09OSVhKIGlzIG5vdCBzZXQKIyBD
T05GSUdfVVNCX0dTUENBX1NQQ0E1MDAgaXMgbm90IHNldAojIENPTkZJR19VU0JfR1NQQ0Ff
U1BDQTUwMSBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9HU1BDQV9TUENBNTA1IGlzIG5vdCBz
ZXQKIyBDT05GSUdfVVNCX0dTUENBX1NQQ0E1MDYgaXMgbm90IHNldAojIENPTkZJR19VU0Jf
R1NQQ0FfU1BDQTUwOCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9HU1BDQV9TUENBNTYxIGlz
IG5vdCBzZXQKIyBDT05GSUdfVVNCX0dTUENBX1NROTA1IGlzIG5vdCBzZXQKIyBDT05GSUdf
VVNCX0dTUENBX1NROTA1QyBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9HU1BDQV9TVEswMTQg
aXMgbm90IHNldAojIENPTkZJR19VU0JfR1NQQ0FfU1RWMDY4MCBpcyBub3Qgc2V0CkNPTkZJ
R19VU0JfR1NQQ0FfU1VOUExVUz1tCiMgQ09ORklHX1VTQl9HU1BDQV9UNjEzIGlzIG5vdCBz
ZXQKIyBDT05GSUdfVVNCX0dTUENBX1RWODUzMiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9H
U1BDQV9WQzAzMlggaXMgbm90IHNldAojIENPTkZJR19VU0JfR1NQQ0FfWkMzWFggaXMgbm90
IHNldAojIENPTkZJR19WSURFT19QVlJVU0IyIGlzIG5vdCBzZXQKIyBDT05GSUdfVklERU9f
SERQVlIgaXMgbm90IHNldApDT05GSUdfVklERU9fRU0yOFhYPW0KQ09ORklHX1ZJREVPX0VN
MjhYWF9BTFNBPW0KIyBDT05GSUdfVklERU9fQ1gyMzFYWCBpcyBub3Qgc2V0CiMgQ09ORklH
X1ZJREVPX1VTQlZJU0lPTiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9WSUNBTSBpcyBub3Qg
c2V0CiMgQ09ORklHX1VTQl9JQk1DQU0gaXMgbm90IHNldAojIENPTkZJR19VU0JfS09OSUNB
V0MgaXMgbm90IHNldAojIENPTkZJR19VU0JfUVVJQ0tDQU1fTUVTU0VOR0VSIGlzIG5vdCBz
ZXQKIyBDT05GSUdfVVNCX0VUNjFYMjUxIGlzIG5vdCBzZXQKIyBDT05GSUdfVklERU9fT1ZD
QU1DSElQIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX09WNTExIGlzIG5vdCBzZXQKIyBDT05G
SUdfVVNCX1NFNDAxIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NOOUMxMDIgaXMgbm90IHNl
dAojIENPTkZJR19VU0JfU1RWNjgwIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1pDMDMwMSBp
cyBub3Qgc2V0CiMgQ09ORklHX1VTQl9QV0MgaXMgbm90IHNldAojIENPTkZJR19VU0JfUFdD
X0lOUFVUX0VWREVWIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1pSMzY0WFggaXMgbm90IHNl
dAojIENPTkZJR19VU0JfU1RLV0VCQ0FNIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1MyMjU1
IGlzIG5vdCBzZXQKIyBDT05GSUdfUkFESU9fQURBUFRFUlMgaXMgbm90IHNldAojIENPTkZJ
R19EQUIgaXMgbm90IHNldAoKIwojIEdyYXBoaWNzIHN1cHBvcnQKIwpDT05GSUdfQUdQPW0K
IyBDT05GSUdfQUdQX0FMSSBpcyBub3Qgc2V0CiMgQ09ORklHX0FHUF9BVEkgaXMgbm90IHNl
dAojIENPTkZJR19BR1BfQU1EIGlzIG5vdCBzZXQKIyBDT05GSUdfQUdQX0FNRDY0IGlzIG5v
dCBzZXQKIyBDT05GSUdfQUdQX0lOVEVMIGlzIG5vdCBzZXQKIyBDT05GSUdfQUdQX05WSURJ
QSBpcyBub3Qgc2V0CiMgQ09ORklHX0FHUF9TSVMgaXMgbm90IHNldAojIENPTkZJR19BR1Bf
U1dPUktTIGlzIG5vdCBzZXQKQ09ORklHX0FHUF9WSUE9bQojIENPTkZJR19BR1BfRUZGSUNF
T04gaXMgbm90IHNldApDT05GSUdfVkdBX0FSQj15CkNPTkZJR19WR0FfQVJCX01BWF9HUFVT
PTE2CkNPTkZJR19EUk09bQojIENPTkZJR19EUk1fVERGWCBpcyBub3Qgc2V0CiMgQ09ORklH
X0RSTV9SMTI4IGlzIG5vdCBzZXQKIyBDT05GSUdfRFJNX1JBREVPTiBpcyBub3Qgc2V0CiMg
Q09ORklHX0RSTV9NR0EgaXMgbm90IHNldAojIENPTkZJR19EUk1fU0lTIGlzIG5vdCBzZXQK
Q09ORklHX0RSTV9WSUE9bQojIENPTkZJR19EUk1fU0FWQUdFIGlzIG5vdCBzZXQKIyBDT05G
SUdfVkdBU1RBVEUgaXMgbm90IHNldApDT05GSUdfVklERU9fT1VUUFVUX0NPTlRST0w9bQoj
IENPTkZJR19GQiBpcyBub3Qgc2V0CkNPTkZJR19CQUNLTElHSFRfTENEX1NVUFBPUlQ9eQpD
T05GSUdfTENEX0NMQVNTX0RFVklDRT1tCiMgQ09ORklHX0xDRF9JTEk5MzIwIGlzIG5vdCBz
ZXQKIyBDT05GSUdfTENEX1BMQVRGT1JNIGlzIG5vdCBzZXQKQ09ORklHX0JBQ0tMSUdIVF9D
TEFTU19ERVZJQ0U9bQpDT05GSUdfQkFDS0xJR0hUX0dFTkVSSUM9bQpDT05GSUdfQkFDS0xJ
R0hUX1BST0dFQVI9bQojIENPTkZJR19CQUNLTElHSFRfTUJQX05WSURJQSBpcyBub3Qgc2V0
CiMgQ09ORklHX0JBQ0tMSUdIVF9TQUhBUkEgaXMgbm90IHNldAoKIwojIERpc3BsYXkgZGV2
aWNlIHN1cHBvcnQKIwpDT05GSUdfRElTUExBWV9TVVBQT1JUPW0KCiMKIyBEaXNwbGF5IGhh
cmR3YXJlIGRyaXZlcnMKIwoKIwojIENvbnNvbGUgZGlzcGxheSBkcml2ZXIgc3VwcG9ydAoj
CkNPTkZJR19WR0FfQ09OU09MRT15CiMgQ09ORklHX1ZHQUNPTl9TT0ZUX1NDUk9MTEJBQ0sg
aXMgbm90IHNldAojIENPTkZJR19NREFfQ09OU09MRSBpcyBub3Qgc2V0CkNPTkZJR19EVU1N
WV9DT05TT0xFPXkKQ09ORklHX1NPVU5EPW0KQ09ORklHX1NPVU5EX09TU19DT1JFPXkKQ09O
RklHX1NPVU5EX09TU19DT1JFX1BSRUNMQUlNPXkKQ09ORklHX1NORD1tCkNPTkZJR19TTkRf
VElNRVI9bQpDT05GSUdfU05EX1BDTT1tCkNPTkZJR19TTkRfSFdERVA9bQpDT05GSUdfU05E
X1JBV01JREk9bQpDT05GSUdfU05EX1NFUVVFTkNFUj1tCiMgQ09ORklHX1NORF9TRVFfRFVN
TVkgaXMgbm90IHNldApDT05GSUdfU05EX09TU0VNVUw9eQpDT05GSUdfU05EX01JWEVSX09T
Uz1tCkNPTkZJR19TTkRfUENNX09TUz1tCkNPTkZJR19TTkRfUENNX09TU19QTFVHSU5TPXkK
Q09ORklHX1NORF9TRVFVRU5DRVJfT1NTPXkKIyBDT05GSUdfU05EX0hSVElNRVIgaXMgbm90
IHNldAojIENPTkZJR19TTkRfRFlOQU1JQ19NSU5PUlMgaXMgbm90IHNldApDT05GSUdfU05E
X1NVUFBPUlRfT0xEX0FQST15CkNPTkZJR19TTkRfVkVSQk9TRV9QUk9DRlM9eQojIENPTkZJ
R19TTkRfVkVSQk9TRV9QUklOVEsgaXMgbm90IHNldAojIENPTkZJR19TTkRfREVCVUcgaXMg
bm90IHNldApDT05GSUdfU05EX1ZNQVNURVI9eQpDT05GSUdfU05EX0RNQV9TR0JVRj15CkNP
TkZJR19TTkRfUkFXTUlESV9TRVE9bQojIENPTkZJR19TTkRfT1BMM19MSUJfU0VRIGlzIG5v
dCBzZXQKIyBDT05GSUdfU05EX09QTDRfTElCX1NFUSBpcyBub3Qgc2V0CiMgQ09ORklHX1NO
RF9TQkFXRV9TRVEgaXMgbm90IHNldAojIENPTkZJR19TTkRfRU1VMTBLMV9TRVEgaXMgbm90
IHNldApDT05GSUdfU05EX01QVTQwMV9VQVJUPW0KQ09ORklHX1NORF9BQzk3X0NPREVDPW0K
Q09ORklHX1NORF9EUklWRVJTPXkKIyBDT05GSUdfU05EX1BDU1AgaXMgbm90IHNldApDT05G
SUdfU05EX0RVTU1ZPW0KQ09ORklHX1NORF9WSVJNSURJPW0KIyBDT05GSUdfU05EX01UUEFW
IGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX01UUzY0IGlzIG5vdCBzZXQKIyBDT05GSUdfU05E
X1NFUklBTF9VMTY1NTAgaXMgbm90IHNldAojIENPTkZJR19TTkRfTVBVNDAxIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU05EX1BPUlRNQU4yWDQgaXMgbm90IHNldApDT05GSUdfU05EX0FDOTdf
UE9XRVJfU0FWRT15CkNPTkZJR19TTkRfQUM5N19QT1dFUl9TQVZFX0RFRkFVTFQ9MAojIENP
TkZJR19TTkRfSVNBIGlzIG5vdCBzZXQKQ09ORklHX1NORF9QQ0k9eQojIENPTkZJR19TTkRf
QUQxODg5IGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0FMUzMwMCBpcyBub3Qgc2V0CiMgQ09O
RklHX1NORF9BTFM0MDAwIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0FMSTU0NTEgaXMgbm90
IHNldAojIENPTkZJR19TTkRfQVRJSVhQIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0FUSUlY
UF9NT0RFTSBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9BVTg4MTAgaXMgbm90IHNldAojIENP
TkZJR19TTkRfQVU4ODIwIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0FVODgzMCBpcyBub3Qg
c2V0CiMgQ09ORklHX1NORF9BVzIgaXMgbm90IHNldAojIENPTkZJR19TTkRfQVpUMzMyOCBp
cyBub3Qgc2V0CiMgQ09ORklHX1NORF9CVDg3WCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9D
QTAxMDYgaXMgbm90IHNldAojIENPTkZJR19TTkRfQ01JUENJIGlzIG5vdCBzZXQKIyBDT05G
SUdfU05EX09YWUdFTiBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9DUzQyODEgaXMgbm90IHNl
dAojIENPTkZJR19TTkRfQ1M0NlhYIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0NTNTUzMCBp
cyBub3Qgc2V0CiMgQ09ORklHX1NORF9DUzU1MzVBVURJTyBpcyBub3Qgc2V0CiMgQ09ORklH
X1NORF9DVFhGSSBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9EQVJMQTIwIGlzIG5vdCBzZXQK
IyBDT05GSUdfU05EX0dJTkEyMCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9MQVlMQTIwIGlz
IG5vdCBzZXQKIyBDT05GSUdfU05EX0RBUkxBMjQgaXMgbm90IHNldAojIENPTkZJR19TTkRf
R0lOQTI0IGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0xBWUxBMjQgaXMgbm90IHNldAojIENP
TkZJR19TTkRfTU9OQSBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9NSUEgaXMgbm90IHNldAoj
IENPTkZJR19TTkRfRUNITzNHIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0lORElHTyBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NORF9JTkRJR09JTyBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9J
TkRJR09ESiBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9JTkRJR09JT1ggaXMgbm90IHNldAoj
IENPTkZJR19TTkRfSU5ESUdPREpYIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0VNVTEwSzEg
aXMgbm90IHNldAojIENPTkZJR19TTkRfRU1VMTBLMVggaXMgbm90IHNldAojIENPTkZJR19T
TkRfRU5TMTM3MCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9FTlMxMzcxIGlzIG5vdCBzZXQK
IyBDT05GSUdfU05EX0VTMTkzOCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9FUzE5NjggaXMg
bm90IHNldAojIENPTkZJR19TTkRfRk04MDEgaXMgbm90IHNldAojIENPTkZJR19TTkRfSERB
X0lOVEVMIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0hEU1AgaXMgbm90IHNldAojIENPTkZJ
R19TTkRfSERTUE0gaXMgbm90IHNldAojIENPTkZJR19TTkRfSElGSUVSIGlzIG5vdCBzZXQK
IyBDT05GSUdfU05EX0lDRTE3MTIgaXMgbm90IHNldAojIENPTkZJR19TTkRfSUNFMTcyNCBp
cyBub3Qgc2V0CiMgQ09ORklHX1NORF9JTlRFTDhYMCBpcyBub3Qgc2V0CiMgQ09ORklHX1NO
RF9JTlRFTDhYME0gaXMgbm90IHNldAojIENPTkZJR19TTkRfS09SRzEyMTIgaXMgbm90IHNl
dAojIENPTkZJR19TTkRfTFg2NDY0RVMgaXMgbm90IHNldAojIENPTkZJR19TTkRfTUFFU1RS
TzMgaXMgbm90IHNldAojIENPTkZJR19TTkRfTUlYQVJUIGlzIG5vdCBzZXQKIyBDT05GSUdf
U05EX05NMjU2IGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX1BDWEhSIGlzIG5vdCBzZXQKIyBD
T05GSUdfU05EX1JJUFRJREUgaXMgbm90IHNldAojIENPTkZJR19TTkRfUk1FMzIgaXMgbm90
IHNldAojIENPTkZJR19TTkRfUk1FOTYgaXMgbm90IHNldAojIENPTkZJR19TTkRfUk1FOTY1
MiBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9TSVM3MDE5IGlzIG5vdCBzZXQKIyBDT05GSUdf
U05EX1NPTklDVklCRVMgaXMgbm90IHNldAojIENPTkZJR19TTkRfVFJJREVOVCBpcyBub3Qg
c2V0CkNPTkZJR19TTkRfVklBODJYWD1tCkNPTkZJR19TTkRfVklBODJYWF9NT0RFTT1tCiMg
Q09ORklHX1NORF9WSVJUVU9TTyBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9WWDIyMiBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NORF9ZTUZQQ0kgaXMgbm90IHNldApDT05GSUdfU05EX1VTQj15
CkNPTkZJR19TTkRfVVNCX0FVRElPPW0KIyBDT05GSUdfU05EX1VTQl9VQTEwMSBpcyBub3Qg
c2V0CkNPTkZJR19TTkRfVVNCX1VTWDJZPW0KIyBDT05GSUdfU05EX1VTQl9DQUlBUSBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NORF9VU0JfVVMxMjJMIGlzIG5vdCBzZXQKIyBDT05GSUdfU05E
X1BDTUNJQSBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9TT0MgaXMgbm90IHNldAojIENPTkZJ
R19TT1VORF9QUklNRSBpcyBub3Qgc2V0CkNPTkZJR19BQzk3X0JVUz1tCkNPTkZJR19ISURf
U1VQUE9SVD15CkNPTkZJR19ISUQ9eQojIENPTkZJR19ISURSQVcgaXMgbm90IHNldAoKIwoj
IFVTQiBJbnB1dCBEZXZpY2VzCiMKQ09ORklHX1VTQl9ISUQ9bQojIENPTkZJR19ISURfUElE
IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0hJRERFViBpcyBub3Qgc2V0CgojCiMgVVNCIEhJ
RCBCb290IFByb3RvY29sIGRyaXZlcnMKIwojIENPTkZJR19VU0JfS0JEIGlzIG5vdCBzZXQK
IyBDT05GSUdfVVNCX01PVVNFIGlzIG5vdCBzZXQKCiMKIyBTcGVjaWFsIEhJRCBkcml2ZXJz
CiMKIyBDT05GSUdfSElEXzNNX1BDVCBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9BNFRFQ0gg
aXMgbm90IHNldAojIENPTkZJR19ISURfQVBQTEUgaXMgbm90IHNldAojIENPTkZJR19ISURf
QkVMS0lOIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX0NIRVJSWSBpcyBub3Qgc2V0CiMgQ09O
RklHX0hJRF9DSElDT05ZIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX0NZUFJFU1MgaXMgbm90
IHNldAojIENPTkZJR19ISURfRFJBR09OUklTRSBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9F
WktFWSBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9LWUUgaXMgbm90IHNldAojIENPTkZJR19I
SURfR1lSQVRJT04gaXMgbm90IHNldAojIENPTkZJR19ISURfVFdJTkhBTiBpcyBub3Qgc2V0
CiMgQ09ORklHX0hJRF9LRU5TSU5HVE9OIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX0xPR0lU
RUNIIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX01JQ1JPU09GVCBpcyBub3Qgc2V0CiMgQ09O
RklHX0hJRF9NT1NBUlQgaXMgbm90IHNldAojIENPTkZJR19ISURfTU9OVEVSRVkgaXMgbm90
IHNldAojIENPTkZJR19ISURfTlRSSUcgaXMgbm90IHNldAojIENPTkZJR19ISURfT1JURUsg
aXMgbm90IHNldAojIENPTkZJR19ISURfUEFOVEhFUkxPUkQgaXMgbm90IHNldAojIENPTkZJ
R19ISURfUEVUQUxZTlggaXMgbm90IHNldAojIENPTkZJR19ISURfUVVBTlRBIGlzIG5vdCBz
ZXQKIyBDT05GSUdfSElEX1NBTVNVTkcgaXMgbm90IHNldAojIENPTkZJR19ISURfU09OWSBp
cyBub3Qgc2V0CiMgQ09ORklHX0hJRF9TVEFOVFVNIGlzIG5vdCBzZXQKIyBDT05GSUdfSElE
X1NVTlBMVVMgaXMgbm90IHNldAojIENPTkZJR19ISURfR1JFRU5BU0lBIGlzIG5vdCBzZXQK
IyBDT05GSUdfSElEX1NNQVJUSk9ZUExVUyBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9UT1BT
RUVEIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX1RIUlVTVE1BU1RFUiBpcyBub3Qgc2V0CiMg
Q09ORklHX0hJRF9aRVJPUExVUyBpcyBub3Qgc2V0CkNPTkZJR19VU0JfU1VQUE9SVD15CkNP
TkZJR19VU0JfQVJDSF9IQVNfSENEPXkKQ09ORklHX1VTQl9BUkNIX0hBU19PSENJPXkKQ09O
RklHX1VTQl9BUkNIX0hBU19FSENJPXkKQ09ORklHX1VTQj1tCiMgQ09ORklHX1VTQl9ERUJV
RyBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9BTk5PVU5DRV9ORVdfREVWSUNFUyBpcyBub3Qg
c2V0CgojCiMgTWlzY2VsbGFuZW91cyBVU0Igb3B0aW9ucwojCkNPTkZJR19VU0JfREVWSUNF
RlM9eQojIENPTkZJR19VU0JfREVWSUNFX0NMQVNTIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNC
X0RZTkFNSUNfTUlOT1JTIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX09URyBpcyBub3Qgc2V0
CiMgQ09ORklHX1VTQl9PVEdfV0hJVEVMSVNUIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX09U
R19CTEFDS0xJU1RfSFVCIGlzIG5vdCBzZXQKQ09ORklHX1VTQl9NT049bQojIENPTkZJR19V
U0JfV1VTQiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9XVVNCX0NCQUYgaXMgbm90IHNldAoK
IwojIFVTQiBIb3N0IENvbnRyb2xsZXIgRHJpdmVycwojCiMgQ09ORklHX1VTQl9DNjdYMDBf
SENEIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1hIQ0lfSENEIGlzIG5vdCBzZXQKQ09ORklH
X1VTQl9FSENJX0hDRD1tCiMgQ09ORklHX1VTQl9FSENJX1JPT1RfSFVCX1RUIGlzIG5vdCBz
ZXQKIyBDT05GSUdfVVNCX0VIQ0lfVFRfTkVXU0NIRUQgaXMgbm90IHNldAojIENPTkZJR19V
U0JfT1hVMjEwSFBfSENEIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0lTUDExNlhfSENEIGlz
IG5vdCBzZXQKIyBDT05GSUdfVVNCX0lTUDE3NjBfSENEIGlzIG5vdCBzZXQKIyBDT05GSUdf
VVNCX0lTUDEzNjJfSENEIGlzIG5vdCBzZXQKQ09ORklHX1VTQl9PSENJX0hDRD1tCiMgQ09O
RklHX1VTQl9PSENJX0JJR19FTkRJQU5fREVTQyBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9P
SENJX0JJR19FTkRJQU5fTU1JTyBpcyBub3Qgc2V0CkNPTkZJR19VU0JfT0hDSV9MSVRUTEVf
RU5ESUFOPXkKQ09ORklHX1VTQl9VSENJX0hDRD1tCiMgQ09ORklHX1VTQl9TTDgxMV9IQ0Qg
aXMgbm90IHNldAojIENPTkZJR19VU0JfUjhBNjY1OTdfSENEIGlzIG5vdCBzZXQKIyBDT05G
SUdfVVNCX1dIQ0lfSENEIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0hXQV9IQ0QgaXMgbm90
IHNldAoKIwojIEVuYWJsZSBIb3N0IG9yIEdhZGdldCBzdXBwb3J0IHRvIHNlZSBJbnZlbnRy
YSBvcHRpb25zCiMKCiMKIyBVU0IgRGV2aWNlIENsYXNzIGRyaXZlcnMKIwojIENPTkZJR19V
U0JfQUNNIGlzIG5vdCBzZXQKQ09ORklHX1VTQl9QUklOVEVSPW0KIyBDT05GSUdfVVNCX1dE
TSBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9UTUMgaXMgbm90IHNldAoKIwojIE5PVEU6IFVT
Ql9TVE9SQUdFIGRlcGVuZHMgb24gU0NTSSBidXQgQkxLX0RFVl9TRCBtYXkKIwoKIwojIGFs
c28gYmUgbmVlZGVkOyBzZWUgVVNCX1NUT1JBR0UgSGVscCBmb3IgbW9yZSBpbmZvCiMKQ09O
RklHX1VTQl9TVE9SQUdFPW0KIyBDT05GSUdfVVNCX1NUT1JBR0VfREVCVUcgaXMgbm90IHNl
dAojIENPTkZJR19VU0JfU1RPUkFHRV9EQVRBRkFCIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNC
X1NUT1JBR0VfRlJFRUNPTSBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TVE9SQUdFX0lTRDIw
MCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TVE9SQUdFX1VTQkFUIGlzIG5vdCBzZXQKIyBD
T05GSUdfVVNCX1NUT1JBR0VfU0REUjA5IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NUT1JB
R0VfU0REUjU1IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NUT1JBR0VfSlVNUFNIT1QgaXMg
bm90IHNldAojIENPTkZJR19VU0JfU1RPUkFHRV9BTEFVREEgaXMgbm90IHNldAojIENPTkZJ
R19VU0JfU1RPUkFHRV9PTkVUT1VDSCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TVE9SQUdF
X0tBUk1BIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NUT1JBR0VfQ1lQUkVTU19BVEFDQiBp
cyBub3Qgc2V0CiMgQ09ORklHX1VTQl9MSUJVU1VBTCBpcyBub3Qgc2V0CgojCiMgVVNCIElt
YWdpbmcgZGV2aWNlcwojCiMgQ09ORklHX1VTQl9NREM4MDAgaXMgbm90IHNldAojIENPTkZJ
R19VU0JfTUlDUk9URUsgaXMgbm90IHNldAoKIwojIFVTQiBwb3J0IGRyaXZlcnMKIwojIENP
TkZJR19VU0JfVVNTNzIwIGlzIG5vdCBzZXQKQ09ORklHX1VTQl9TRVJJQUw9bQojIENPTkZJ
R19VU0JfRVpVU0IgaXMgbm90IHNldApDT05GSUdfVVNCX1NFUklBTF9HRU5FUklDPXkKIyBD
T05GSUdfVVNCX1NFUklBTF9BSVJDQUJMRSBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJ
QUxfQVJLMzExNiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxfQkVMS0lOIGlzIG5v
dCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9DSDM0MSBpcyBub3Qgc2V0CiMgQ09ORklHX1VT
Ql9TRVJJQUxfV0hJVEVIRUFUIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9ESUdJ
X0FDQ0VMRVBPUlQgaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFMX0NQMjEwWCBpcyBu
b3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxfQ1lQUkVTU19NOCBpcyBub3Qgc2V0CiMgQ09O
RklHX1VTQl9TRVJJQUxfRU1QRUcgaXMgbm90IHNldApDT05GSUdfVVNCX1NFUklBTF9GVERJ
X1NJTz1tCiMgQ09ORklHX1VTQl9TRVJJQUxfRlVOU09GVCBpcyBub3Qgc2V0CiMgQ09ORklH
X1VTQl9TRVJJQUxfVklTT1IgaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFMX0lQQVEg
aXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFMX0lSIGlzIG5vdCBzZXQKIyBDT05GSUdf
VVNCX1NFUklBTF9FREdFUE9SVCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxfRURH
RVBPUlRfVEkgaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFMX0dBUk1JTiBpcyBub3Qg
c2V0CiMgQ09ORklHX1VTQl9TRVJJQUxfSVBXIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NF
UklBTF9JVVUgaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFMX0tFWVNQQU5fUERBIGlz
IG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9LRVlTUEFOIGlzIG5vdCBzZXQKIyBDT05G
SUdfVVNCX1NFUklBTF9LTFNJIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9LT0JJ
TF9TQ1QgaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFMX01DVF9VMjMyIGlzIG5vdCBz
ZXQKIyBDT05GSUdfVVNCX1NFUklBTF9NT1M3NzIwIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNC
X1NFUklBTF9NT1M3ODQwIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9NT1RPUk9M
QSBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxfTkFWTUFOIGlzIG5vdCBzZXQKQ09O
RklHX1VTQl9TRVJJQUxfUEwyMzAzPW0KIyBDT05GSUdfVVNCX1NFUklBTF9PVEk2ODU4IGlz
IG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9RQ0FVWCBpcyBub3Qgc2V0CiMgQ09ORklH
X1VTQl9TRVJJQUxfUVVBTENPTU0gaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFMX1NQ
Q1A4WDUgaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFMX0hQNFggaXMgbm90IHNldAoj
IENPTkZJR19VU0JfU0VSSUFMX1NBRkUgaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFM
X1NJRU1FTlNfTVBJIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9TSUVSUkFXSVJF
TEVTUyBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxfU1lNQk9MIGlzIG5vdCBzZXQK
IyBDT05GSUdfVVNCX1NFUklBTF9USSBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxf
Q1lCRVJKQUNLIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9YSVJDT00gaXMgbm90
IHNldAojIENPTkZJR19VU0JfU0VSSUFMX09QVElPTiBpcyBub3Qgc2V0CiMgQ09ORklHX1VT
Ql9TRVJJQUxfT01OSU5FVCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxfT1BUSUNP
TiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxfVklWT1BBWV9TRVJJQUwgaXMgbm90
IHNldAojIENPTkZJR19VU0JfU0VSSUFMX0RFQlVHIGlzIG5vdCBzZXQKCiMKIyBVU0IgTWlz
Y2VsbGFuZW91cyBkcml2ZXJzCiMKIyBDT05GSUdfVVNCX0VNSTYyIGlzIG5vdCBzZXQKIyBD
T05GSUdfVVNCX0VNSTI2IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0FEVVRVWCBpcyBub3Qg
c2V0CiMgQ09ORklHX1VTQl9TRVZTRUcgaXMgbm90IHNldAojIENPTkZJR19VU0JfUklPNTAw
IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0xFR09UT1dFUiBpcyBub3Qgc2V0CiMgQ09ORklH
X1VTQl9MQ0QgaXMgbm90IHNldAojIENPTkZJR19VU0JfTEVEIGlzIG5vdCBzZXQKIyBDT05G
SUdfVVNCX0NZUFJFU1NfQ1k3QzYzIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0NZVEhFUk0g
aXMgbm90IHNldAojIENPTkZJR19VU0JfSURNT1VTRSBpcyBub3Qgc2V0CiMgQ09ORklHX1VT
Ql9GVERJX0VMQU4gaXMgbm90IHNldAojIENPTkZJR19VU0JfQVBQTEVESVNQTEFZIGlzIG5v
dCBzZXQKIyBDT05GSUdfVVNCX1NJU1VTQlZHQSBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9M
RCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9UUkFOQ0VWSUJSQVRPUiBpcyBub3Qgc2V0CiMg
Q09ORklHX1VTQl9JT1dBUlJJT1IgaXMgbm90IHNldAojIENPTkZJR19VU0JfVEVTVCBpcyBu
b3Qgc2V0CiMgQ09ORklHX1VTQl9JU0lHSFRGVyBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9H
QURHRVQgaXMgbm90IHNldAoKIwojIE9URyBhbmQgcmVsYXRlZCBpbmZyYXN0cnVjdHVyZQoj
CiMgQ09ORklHX05PUF9VU0JfWENFSVYgaXMgbm90IHNldAojIENPTkZJR19VV0IgaXMgbm90
IHNldApDT05GSUdfTU1DPW0KIyBDT05GSUdfTU1DX0RFQlVHIGlzIG5vdCBzZXQKIyBDT05G
SUdfTU1DX1VOU0FGRV9SRVNVTUUgaXMgbm90IHNldAoKIwojIE1NQy9TRC9TRElPIENhcmQg
RHJpdmVycwojCkNPTkZJR19NTUNfQkxPQ0s9bQpDT05GSUdfTU1DX0JMT0NLX0JPVU5DRT15
CiMgQ09ORklHX1NESU9fVUFSVCBpcyBub3Qgc2V0CiMgQ09ORklHX01NQ19URVNUIGlzIG5v
dCBzZXQKCiMKIyBNTUMvU0QvU0RJTyBIb3N0IENvbnRyb2xsZXIgRHJpdmVycwojCkNPTkZJ
R19NTUNfU0RIQ0k9bQojIENPTkZJR19NTUNfU0RIQ0lfUENJIGlzIG5vdCBzZXQKIyBDT05G
SUdfTU1DX1NESENJX1BMVEZNIGlzIG5vdCBzZXQKQ09ORklHX01NQ19XQlNEPW0KQ09ORklH
X01NQ19USUZNX1NEPW0KIyBDT05GSUdfTU1DX1NEUklDT0hfQ1MgaXMgbm90IHNldAojIENP
TkZJR19NTUNfQ0I3MTAgaXMgbm90IHNldAojIENPTkZJR19NTUNfVklBX1NETU1DIGlzIG5v
dCBzZXQKIyBDT05GSUdfTUVNU1RJQ0sgaXMgbm90IHNldApDT05GSUdfTkVXX0xFRFM9eQpD
T05GSUdfTEVEU19DTEFTUz1tCgojCiMgTEVEIGRyaXZlcnMKIwojIENPTkZJR19MRURTX0FM
SVgyIGlzIG5vdCBzZXQKIyBDT05GSUdfTEVEU19QQ0E5NTMyIGlzIG5vdCBzZXQKIyBDT05G
SUdfTEVEU19MUDM5NDQgaXMgbm90IHNldApDT05GSUdfTEVEU19DTEVWT19NQUlMPW0KIyBD
T05GSUdfTEVEU19QQ0E5NTVYIGlzIG5vdCBzZXQKIyBDT05GSUdfTEVEU19CRDI4MDIgaXMg
bm90IHNldAojIENPTkZJR19MRURTX0lOVEVMX1NTNDIwMCBpcyBub3Qgc2V0CkNPTkZJR19M
RURTX1RSSUdHRVJTPXkKCiMKIyBMRUQgVHJpZ2dlcnMKIwpDT05GSUdfTEVEU19UUklHR0VS
X1RJTUVSPW0KIyBDT05GSUdfTEVEU19UUklHR0VSX0lERV9ESVNLIGlzIG5vdCBzZXQKQ09O
RklHX0xFRFNfVFJJR0dFUl9IRUFSVEJFQVQ9bQojIENPTkZJR19MRURTX1RSSUdHRVJfQkFD
S0xJR0hUIGlzIG5vdCBzZXQKIyBDT05GSUdfTEVEU19UUklHR0VSX0RFRkFVTFRfT04gaXMg
bm90IHNldAoKIwojIGlwdGFibGVzIHRyaWdnZXIgaXMgdW5kZXIgTmV0ZmlsdGVyIGNvbmZp
ZyAoTEVEIHRhcmdldCkKIwojIENPTkZJR19BQ0NFU1NJQklMSVRZIGlzIG5vdCBzZXQKIyBD
T05GSUdfSU5GSU5JQkFORCBpcyBub3Qgc2V0CiMgQ09ORklHX0VEQUMgaXMgbm90IHNldApD
T05GSUdfUlRDX0xJQj1tCkNPTkZJR19SVENfQ0xBU1M9bQoKIwojIFJUQyBpbnRlcmZhY2Vz
CiMKQ09ORklHX1JUQ19JTlRGX1NZU0ZTPXkKQ09ORklHX1JUQ19JTlRGX1BST0M9eQpDT05G
SUdfUlRDX0lOVEZfREVWPXkKIyBDT05GSUdfUlRDX0lOVEZfREVWX1VJRV9FTVVMIGlzIG5v
dCBzZXQKQ09ORklHX1JUQ19EUlZfVEVTVD1tCgojCiMgSTJDIFJUQyBkcml2ZXJzCiMKQ09O
RklHX1JUQ19EUlZfRFMxMzA3PW0KIyBDT05GSUdfUlRDX0RSVl9EUzEzNzQgaXMgbm90IHNl
dApDT05GSUdfUlRDX0RSVl9EUzE2NzI9bQpDT05GSUdfUlRDX0RSVl9NQVg2OTAwPW0KQ09O
RklHX1JUQ19EUlZfUlM1QzM3Mj1tCkNPTkZJR19SVENfRFJWX0lTTDEyMDg9bQpDT05GSUdf
UlRDX0RSVl9YMTIwNT1tCkNPTkZJR19SVENfRFJWX1BDRjg1NjM9bQpDT05GSUdfUlRDX0RS
Vl9QQ0Y4NTgzPW0KQ09ORklHX1JUQ19EUlZfTTQxVDgwPW0KIyBDT05GSUdfUlRDX0RSVl9N
NDFUODBfV0RUIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9CUTMySyBpcyBub3Qgc2V0
CiMgQ09ORklHX1JUQ19EUlZfUzM1MzkwQSBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZf
Rk0zMTMwIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9SWDg1ODEgaXMgbm90IHNldAoj
IENPTkZJR19SVENfRFJWX1JYODAyNSBpcyBub3Qgc2V0CgojCiMgU1BJIFJUQyBkcml2ZXJz
CiMKCiMKIyBQbGF0Zm9ybSBSVEMgZHJpdmVycwojCkNPTkZJR19SVENfRFJWX0NNT1M9bQoj
IENPTkZJR19SVENfRFJWX0RTMTI4NiBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZfRFMx
NTExIGlzIG5vdCBzZXQKQ09ORklHX1JUQ19EUlZfRFMxNTUzPW0KQ09ORklHX1JUQ19EUlZf
RFMxNzQyPW0KQ09ORklHX1JUQ19EUlZfU1RLMTdUQTg9bQpDT05GSUdfUlRDX0RSVl9NNDhU
ODY9bQojIENPTkZJR19SVENfRFJWX000OFQzNSBpcyBub3Qgc2V0CkNPTkZJR19SVENfRFJW
X000OFQ1OT1tCiMgQ09ORklHX1JUQ19EUlZfTVNNNjI0MiBpcyBub3Qgc2V0CiMgQ09ORklH
X1JUQ19EUlZfQlE0ODAyIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9SUDVDMDEgaXMg
bm90IHNldApDT05GSUdfUlRDX0RSVl9WMzAyMD1tCgojCiMgb24tQ1BVIFJUQyBkcml2ZXJz
CiMKQ09ORklHX0RNQURFVklDRVM9eQojIENPTkZJR19ETUFERVZJQ0VTX0RFQlVHIGlzIG5v
dCBzZXQKCiMKIyBETUEgRGV2aWNlcwojCkNPTkZJR19BU1lOQ19UWF9ESVNBQkxFX0NIQU5O
RUxfU1dJVENIPXkKQ09ORklHX0lOVEVMX0lPQVRETUE9bQpDT05GSUdfRE1BX0VOR0lORT15
CgojCiMgRE1BIENsaWVudHMKIwpDT05GSUdfTkVUX0RNQT15CiMgQ09ORklHX0FTWU5DX1RY
X0RNQSBpcyBub3Qgc2V0CiMgQ09ORklHX0RNQVRFU1QgaXMgbm90IHNldApDT05GSUdfRENB
PW0KIyBDT05GSUdfQVVYRElTUExBWSBpcyBub3Qgc2V0CkNPTkZJR19VSU89bQojIENPTkZJ
R19VSU9fQ0lGIGlzIG5vdCBzZXQKIyBDT05GSUdfVUlPX1BEUlYgaXMgbm90IHNldAojIENP
TkZJR19VSU9fUERSVl9HRU5JUlEgaXMgbm90IHNldAojIENPTkZJR19VSU9fQUVDIGlzIG5v
dCBzZXQKIyBDT05GSUdfVUlPX1NFUkNPUzMgaXMgbm90IHNldAojIENPTkZJR19VSU9fUENJ
X0dFTkVSSUMgaXMgbm90IHNldAojIENPTkZJR19VSU9fTkVUWCBpcyBub3Qgc2V0CgojCiMg
VEkgVkxZTlEKIwpDT05GSUdfU1RBR0lORz15CiMgQ09ORklHX1NUQUdJTkdfRVhDTFVERV9C
VUlMRCBpcyBub3Qgc2V0CiMgQ09ORklHX1ZJREVPX0dPNzAwNyBpcyBub3Qgc2V0CkNPTkZJ
R19VU0JfSVBfQ09NTU9OPW0KQ09ORklHX1VTQl9JUF9WSENJX0hDRD1tCkNPTkZJR19VU0Jf
SVBfSE9TVD1tCiMgQ09ORklHX1VTQl9JUF9ERUJVR19FTkFCTEUgaXMgbm90IHNldAojIENP
TkZJR19XMzVVTkQgaXMgbm90IHNldAojIENPTkZJR19QUklTTTJfVVNCIGlzIG5vdCBzZXQK
IyBDT05GSUdfRUNITyBpcyBub3Qgc2V0CiMgQ09ORklHX1BPQ0ggaXMgbm90IHNldAojIENP
TkZJR19PVFVTIGlzIG5vdCBzZXQKIyBDT05GSUdfUlQyODYwIGlzIG5vdCBzZXQKIyBDT05G
SUdfUlQyODcwIGlzIG5vdCBzZXQKIyBDT05GSUdfQ09NRURJIGlzIG5vdCBzZXQKIyBDT05G
SUdfQVNVU19PTEVEIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFORUwgaXMgbm90IHNldAojIENP
TkZJR19SODE4N1NFIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRMODE5MlNVIGlzIG5vdCBzZXQK
IyBDT05GSUdfUlRMODE5MlUgaXMgbm90IHNldAojIENPTkZJR19SVEw4MTkyRSBpcyBub3Qg
c2V0CiMgQ09ORklHX1RSQU5aUE9SVCBpcyBub3Qgc2V0CgojCiMgUXVhbGNvbW0gTVNNIENh
bWVyYSBBbmQgVmlkZW8KIwoKIwojIENhbWVyYSBTZW5zb3IgU2VsZWN0aW9uCiMKIyBDT05G
SUdfSU5QVVRfR1BJTyBpcyBub3Qgc2V0CiMgQ09ORklHX1BPSE1FTEZTIGlzIG5vdCBzZXQK
IyBDT05GSUdfTElORTZfVVNCIGlzIG5vdCBzZXQKIyBDT05GSUdfRFJNX1ZNV0dGWCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0RSTV9OT1VWRUFVIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NF
UklBTF9RVUFURUNIMiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxfUVVBVEVDSF9V
U0IyIGlzIG5vdCBzZXQKIyBDT05GSUdfVlQ2NjU1IGlzIG5vdCBzZXQKIyBDT05GSUdfVlQ2
NjU2IGlzIG5vdCBzZXQKIyBDT05GSUdfSFlQRVJWIGlzIG5vdCBzZXQKIyBDT05GSUdfVk1F
X0JVUyBpcyBub3Qgc2V0CgojCiMgUkFSIFJlZ2lzdGVyIERyaXZlcgojCiMgQ09ORklHX1JB
Ul9SRUdJU1RFUiBpcyBub3Qgc2V0CiMgQ09ORklHX0lJTyBpcyBub3Qgc2V0CiMgQ09ORklH
X1JBTVpTV0FQIGlzIG5vdCBzZXQKIyBDT05GSUdfQkFUTUFOX0FEViBpcyBub3Qgc2V0CiMg
Q09ORklHX1NBTVNVTkdfTEFQVE9QIGlzIG5vdCBzZXQKIyBDT05GSUdfU1RSSVAgaXMgbm90
IHNldAojIENPTkZJR19BUkxBTiBpcyBub3Qgc2V0CiMgQ09ORklHX1dBVkVMQU4gaXMgbm90
IHNldAojIENPTkZJR19QQ01DSUFfV0FWRUxBTiBpcyBub3Qgc2V0CiMgQ09ORklHX1BDTUNJ
QV9ORVRXQVZFIGlzIG5vdCBzZXQKIyBDT05GSUdfRFQzMTU1IGlzIG5vdCBzZXQKIyBDT05G
SUdfQ1JZU1RBTEhEIGlzIG5vdCBzZXQKQ09ORklHX1g4Nl9QTEFURk9STV9ERVZJQ0VTPXkK
CiMKIyBGaXJtd2FyZSBEcml2ZXJzCiMKIyBDT05GSUdfRUREIGlzIG5vdCBzZXQKQ09ORklH
X0ZJUk1XQVJFX01FTU1BUD15CiMgQ09ORklHX0RFTExfUkJVIGlzIG5vdCBzZXQKIyBDT05G
SUdfRENEQkFTIGlzIG5vdCBzZXQKQ09ORklHX0RNSUlEPXkKIyBDT05GSUdfSVNDU0lfSUJG
VF9GSU5EIGlzIG5vdCBzZXQKCiMKIyBGaWxlIHN5c3RlbXMKIwpDT05GSUdfRVhUMl9GUz15
CiMgQ09ORklHX0VYVDJfRlNfWEFUVFIgaXMgbm90IHNldAojIENPTkZJR19FWFQyX0ZTX1hJ
UCBpcyBub3Qgc2V0CkNPTkZJR19FWFQzX0ZTPXkKIyBDT05GSUdfRVhUM19ERUZBVUxUU19U
T19PUkRFUkVEIGlzIG5vdCBzZXQKQ09ORklHX0VYVDNfRlNfWEFUVFI9eQojIENPTkZJR19F
WFQzX0ZTX1BPU0lYX0FDTCBpcyBub3Qgc2V0CiMgQ09ORklHX0VYVDNfRlNfU0VDVVJJVFkg
aXMgbm90IHNldAojIENPTkZJR19FWFQ0X0ZTIGlzIG5vdCBzZXQKQ09ORklHX0pCRD15CiMg
Q09ORklHX0pCRF9ERUJVRyBpcyBub3Qgc2V0CkNPTkZJR19GU19NQkNBQ0hFPXkKQ09ORklH
X1JFSVNFUkZTX0ZTPXkKIyBDT05GSUdfUkVJU0VSRlNfQ0hFQ0sgaXMgbm90IHNldAojIENP
TkZJR19SRUlTRVJGU19QUk9DX0lORk8gaXMgbm90IHNldAojIENPTkZJR19SRUlTRVJGU19G
U19YQVRUUiBpcyBub3Qgc2V0CiMgQ09ORklHX0pGU19GUyBpcyBub3Qgc2V0CkNPTkZJR19G
U19QT1NJWF9BQ0w9eQojIENPTkZJR19YRlNfRlMgaXMgbm90IHNldAojIENPTkZJR19HRlMy
X0ZTIGlzIG5vdCBzZXQKIyBDT05GSUdfT0NGUzJfRlMgaXMgbm90IHNldAojIENPTkZJR19C
VFJGU19GUyBpcyBub3Qgc2V0CiMgQ09ORklHX05JTEZTMl9GUyBpcyBub3Qgc2V0CkNPTkZJ
R19GSUxFX0xPQ0tJTkc9eQpDT05GSUdfRlNOT1RJRlk9eQpDT05GSUdfRE5PVElGWT15CkNP
TkZJR19JTk9USUZZPXkKQ09ORklHX0lOT1RJRllfVVNFUj15CiMgQ09ORklHX1FVT1RBIGlz
IG5vdCBzZXQKIyBDT05GSUdfQVVUT0ZTX0ZTIGlzIG5vdCBzZXQKQ09ORklHX0FVVE9GUzRf
RlM9bQpDT05GSUdfRlVTRV9GUz1tCiMgQ09ORklHX0NVU0UgaXMgbm90IHNldAoKIwojIENh
Y2hlcwojCiMgQ09ORklHX0ZTQ0FDSEUgaXMgbm90IHNldAoKIwojIENELVJPTS9EVkQgRmls
ZXN5c3RlbXMKIwpDT05GSUdfSVNPOTY2MF9GUz1tCkNPTkZJR19KT0xJRVQ9eQpDT05GSUdf
WklTT0ZTPXkKQ09ORklHX1VERl9GUz1tCkNPTkZJR19VREZfTkxTPXkKCiMKIyBET1MvRkFU
L05UIEZpbGVzeXN0ZW1zCiMKQ09ORklHX0ZBVF9GUz1tCkNPTkZJR19NU0RPU19GUz1tCkNP
TkZJR19WRkFUX0ZTPW0KQ09ORklHX0ZBVF9ERUZBVUxUX0NPREVQQUdFPTQzNwpDT05GSUdf
RkFUX0RFRkFVTFRfSU9DSEFSU0VUPSJpc284ODU5LTIiCkNPTkZJR19OVEZTX0ZTPW0KIyBD
T05GSUdfTlRGU19ERUJVRyBpcyBub3Qgc2V0CiMgQ09ORklHX05URlNfUlcgaXMgbm90IHNl
dAoKIwojIFBzZXVkbyBmaWxlc3lzdGVtcwojCkNPTkZJR19QUk9DX0ZTPXkKQ09ORklHX1BS
T0NfS0NPUkU9eQpDT05GSUdfUFJPQ19TWVNDVEw9eQpDT05GSUdfUFJPQ19QQUdFX01PTklU
T1I9eQpDT05GSUdfU1lTRlM9eQpDT05GSUdfVE1QRlM9eQojIENPTkZJR19UTVBGU19QT1NJ
WF9BQ0wgaXMgbm90IHNldAojIENPTkZJR19IVUdFVExCRlMgaXMgbm90IHNldAojIENPTkZJ
R19IVUdFVExCX1BBR0UgaXMgbm90IHNldAojIENPTkZJR19DT05GSUdGU19GUyBpcyBub3Qg
c2V0CkNPTkZJR19NSVNDX0ZJTEVTWVNURU1TPXkKIyBDT05GSUdfQURGU19GUyBpcyBub3Qg
c2V0CiMgQ09ORklHX0FGRlNfRlMgaXMgbm90IHNldAojIENPTkZJR19IRlNfRlMgaXMgbm90
IHNldAojIENPTkZJR19IRlNQTFVTX0ZTIGlzIG5vdCBzZXQKIyBDT05GSUdfQkVGU19GUyBp
cyBub3Qgc2V0CiMgQ09ORklHX0JGU19GUyBpcyBub3Qgc2V0CiMgQ09ORklHX0VGU19GUyBp
cyBub3Qgc2V0CiMgQ09ORklHX0xPR0ZTIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JBTUZTIGlz
IG5vdCBzZXQKIyBDT05GSUdfU1FVQVNIRlMgaXMgbm90IHNldAojIENPTkZJR19WWEZTX0ZT
IGlzIG5vdCBzZXQKIyBDT05GSUdfTUlOSVhfRlMgaXMgbm90IHNldAojIENPTkZJR19PTUZT
X0ZTIGlzIG5vdCBzZXQKIyBDT05GSUdfSFBGU19GUyBpcyBub3Qgc2V0CiMgQ09ORklHX1FO
WDRGU19GUyBpcyBub3Qgc2V0CiMgQ09ORklHX1JPTUZTX0ZTIGlzIG5vdCBzZXQKIyBDT05G
SUdfU1lTVl9GUyBpcyBub3Qgc2V0CiMgQ09ORklHX1VGU19GUyBpcyBub3Qgc2V0CkNPTkZJ
R19ORVRXT1JLX0ZJTEVTWVNURU1TPXkKQ09ORklHX05GU19GUz1tCkNPTkZJR19ORlNfVjM9
eQojIENPTkZJR19ORlNfVjNfQUNMIGlzIG5vdCBzZXQKQ09ORklHX05GU19WND15CiMgQ09O
RklHX05GU19WNF8xIGlzIG5vdCBzZXQKQ09ORklHX05GU0Q9bQpDT05GSUdfTkZTRF9WMz15
CiMgQ09ORklHX05GU0RfVjNfQUNMIGlzIG5vdCBzZXQKQ09ORklHX05GU0RfVjQ9eQpDT05G
SUdfTE9DS0Q9bQpDT05GSUdfTE9DS0RfVjQ9eQpDT05GSUdfRVhQT1JURlM9bQpDT05GSUdf
TkZTX0NPTU1PTj15CkNPTkZJR19TVU5SUEM9bQpDT05GSUdfU1VOUlBDX0dTUz1tCkNPTkZJ
R19SUENTRUNfR1NTX0tSQjU9bQojIENPTkZJR19SUENTRUNfR1NTX1NQS00zIGlzIG5vdCBz
ZXQKQ09ORklHX1NNQl9GUz1tCkNPTkZJR19TTUJfTkxTX0RFRkFVTFQ9eQpDT05GSUdfU01C
X05MU19SRU1PVEU9Imlzbzg4NTktMiIKIyBDT05GSUdfQ0VQSF9GUyBpcyBub3Qgc2V0CkNP
TkZJR19DSUZTPW0KIyBDT05GSUdfQ0lGU19TVEFUUyBpcyBub3Qgc2V0CiMgQ09ORklHX0NJ
RlNfV0VBS19QV19IQVNIIGlzIG5vdCBzZXQKIyBDT05GSUdfQ0lGU19YQVRUUiBpcyBub3Qg
c2V0CiMgQ09ORklHX0NJRlNfREVCVUcyIGlzIG5vdCBzZXQKIyBDT05GSUdfQ0lGU19FWFBF
UklNRU5UQUwgaXMgbm90IHNldAojIENPTkZJR19OQ1BfRlMgaXMgbm90IHNldAojIENPTkZJ
R19DT0RBX0ZTIGlzIG5vdCBzZXQKIyBDT05GSUdfQUZTX0ZTIGlzIG5vdCBzZXQKCiMKIyBQ
YXJ0aXRpb24gVHlwZXMKIwojIENPTkZJR19QQVJUSVRJT05fQURWQU5DRUQgaXMgbm90IHNl
dApDT05GSUdfTVNET1NfUEFSVElUSU9OPXkKQ09ORklHX05MUz1tCkNPTkZJR19OTFNfREVG
QVVMVD0iaXNvODg1OS0yIgpDT05GSUdfTkxTX0NPREVQQUdFXzQzNz1tCiMgQ09ORklHX05M
U19DT0RFUEFHRV83MzcgaXMgbm90IHNldAojIENPTkZJR19OTFNfQ09ERVBBR0VfNzc1IGlz
IG5vdCBzZXQKIyBDT05GSUdfTkxTX0NPREVQQUdFXzg1MCBpcyBub3Qgc2V0CkNPTkZJR19O
TFNfQ09ERVBBR0VfODUyPW0KIyBDT05GSUdfTkxTX0NPREVQQUdFXzg1NSBpcyBub3Qgc2V0
CiMgQ09ORklHX05MU19DT0RFUEFHRV84NTcgaXMgbm90IHNldAojIENPTkZJR19OTFNfQ09E
RVBBR0VfODYwIGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0NPREVQQUdFXzg2MSBpcyBub3Qg
c2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV84NjIgaXMgbm90IHNldAojIENPTkZJR19OTFNf
Q09ERVBBR0VfODYzIGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0NPREVQQUdFXzg2NCBpcyBu
b3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV84NjUgaXMgbm90IHNldAojIENPTkZJR19O
TFNfQ09ERVBBR0VfODY2IGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0NPREVQQUdFXzg2OSBp
cyBub3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV85MzYgaXMgbm90IHNldAojIENPTkZJ
R19OTFNfQ09ERVBBR0VfOTUwIGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0NPREVQQUdFXzkz
MiBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV85NDkgaXMgbm90IHNldAojIENP
TkZJR19OTFNfQ09ERVBBR0VfODc0IGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0lTTzg4NTlf
OCBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV8xMjUwIGlzIG5vdCBzZXQKIyBD
T05GSUdfTkxTX0NPREVQQUdFXzEyNTEgaXMgbm90IHNldAojIENPTkZJR19OTFNfQVNDSUkg
aXMgbm90IHNldApDT05GSUdfTkxTX0lTTzg4NTlfMT1tCkNPTkZJR19OTFNfSVNPODg1OV8y
PW0KIyBDT05GSUdfTkxTX0lTTzg4NTlfMyBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19JU084
ODU5XzQgaXMgbm90IHNldAojIENPTkZJR19OTFNfSVNPODg1OV81IGlzIG5vdCBzZXQKIyBD
T05GSUdfTkxTX0lTTzg4NTlfNiBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19JU084ODU5Xzcg
aXMgbm90IHNldAojIENPTkZJR19OTFNfSVNPODg1OV85IGlzIG5vdCBzZXQKIyBDT05GSUdf
TkxTX0lTTzg4NTlfMTMgaXMgbm90IHNldAojIENPTkZJR19OTFNfSVNPODg1OV8xNCBpcyBu
b3Qgc2V0CiMgQ09ORklHX05MU19JU084ODU5XzE1IGlzIG5vdCBzZXQKIyBDT05GSUdfTkxT
X0tPSThfUiBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19LT0k4X1UgaXMgbm90IHNldApDT05G
SUdfTkxTX1VURjg9bQojIENPTkZJR19ETE0gaXMgbm90IHNldAoKIwojIEtlcm5lbCBoYWNr
aW5nCiMKQ09ORklHX1RSQUNFX0lSUUZMQUdTX1NVUFBPUlQ9eQpDT05GSUdfUFJJTlRLX1RJ
TUU9eQpDT05GSUdfRU5BQkxFX1dBUk5fREVQUkVDQVRFRD15CkNPTkZJR19FTkFCTEVfTVVT
VF9DSEVDSz15CkNPTkZJR19GUkFNRV9XQVJOPTEwMjQKQ09ORklHX01BR0lDX1NZU1JRPXkK
IyBDT05GSUdfU1RSSVBfQVNNX1NZTVMgaXMgbm90IHNldApDT05GSUdfVU5VU0VEX1NZTUJP
TFM9eQpDT05GSUdfREVCVUdfRlM9eQojIENPTkZJR19IRUFERVJTX0NIRUNLIGlzIG5vdCBz
ZXQKQ09ORklHX0RFQlVHX0tFUk5FTD15CiMgQ09ORklHX0RFQlVHX1NISVJRIGlzIG5vdCBz
ZXQKQ09ORklHX0RFVEVDVF9TT0ZUTE9DS1VQPXkKIyBDT05GSUdfQk9PVFBBUkFNX1NPRlRM
T0NLVVBfUEFOSUMgaXMgbm90IHNldApDT05GSUdfQk9PVFBBUkFNX1NPRlRMT0NLVVBfUEFO
SUNfVkFMVUU9MApDT05GSUdfREVURUNUX0hVTkdfVEFTSz15CiMgQ09ORklHX0JPT1RQQVJB
TV9IVU5HX1RBU0tfUEFOSUMgaXMgbm90IHNldApDT05GSUdfQk9PVFBBUkFNX0hVTkdfVEFT
S19QQU5JQ19WQUxVRT0wCkNPTkZJR19TQ0hFRF9ERUJVRz15CkNPTkZJR19TQ0hFRFNUQVRT
PXkKQ09ORklHX1RJTUVSX1NUQVRTPXkKQ09ORklHX0RFQlVHX09CSkVDVFM9eQojIENPTkZJ
R19ERUJVR19PQkpFQ1RTX1NFTEZURVNUIGlzIG5vdCBzZXQKQ09ORklHX0RFQlVHX09CSkVD
VFNfRlJFRT15CkNPTkZJR19ERUJVR19PQkpFQ1RTX1RJTUVSUz15CiMgQ09ORklHX0RFQlVH
X09CSkVDVFNfV09SSyBpcyBub3Qgc2V0CkNPTkZJR19ERUJVR19PQkpFQ1RTX0VOQUJMRV9E
RUZBVUxUPTEKQ09ORklHX0RFQlVHX1NMQUI9eQpDT05GSUdfREVCVUdfU0xBQl9MRUFLPXkK
Q09ORklHX0RFQlVHX0tNRU1MRUFLPXkKQ09ORklHX0RFQlVHX0tNRU1MRUFLX0VBUkxZX0xP
R19TSVpFPTQwMApDT05GSUdfREVCVUdfS01FTUxFQUtfVEVTVD1tCkNPTkZJR19ERUJVR19Q
UkVFTVBUPXkKQ09ORklHX0RFQlVHX1JUX01VVEVYRVM9eQpDT05GSUdfREVCVUdfUElfTElT
VD15CiMgQ09ORklHX1JUX01VVEVYX1RFU1RFUiBpcyBub3Qgc2V0CkNPTkZJR19ERUJVR19T
UElOTE9DSz15CkNPTkZJR19ERUJVR19NVVRFWEVTPXkKQ09ORklHX0RFQlVHX0xPQ0tfQUxM
T0M9eQpDT05GSUdfUFJPVkVfTE9DS0lORz15CiMgQ09ORklHX1BST1ZFX1JDVSBpcyBub3Qg
c2V0CkNPTkZJR19MT0NLREVQPXkKIyBDT05GSUdfTE9DS19TVEFUIGlzIG5vdCBzZXQKIyBD
T05GSUdfREVCVUdfTE9DS0RFUCBpcyBub3Qgc2V0CkNPTkZJR19UUkFDRV9JUlFGTEFHUz15
CkNPTkZJR19ERUJVR19TUElOTE9DS19TTEVFUD15CiMgQ09ORklHX0RFQlVHX0xPQ0tJTkdf
QVBJX1NFTEZURVNUUyBpcyBub3Qgc2V0CkNPTkZJR19TVEFDS1RSQUNFPXkKIyBDT05GSUdf
REVCVUdfS09CSkVDVCBpcyBub3Qgc2V0CiMgQ09ORklHX0RFQlVHX0hJR0hNRU0gaXMgbm90
IHNldApDT05GSUdfREVCVUdfQlVHVkVSQk9TRT15CkNPTkZJR19ERUJVR19JTkZPPXkKIyBD
T05GSUdfREVCVUdfVk0gaXMgbm90IHNldAojIENPTkZJR19ERUJVR19WSVJUVUFMIGlzIG5v
dCBzZXQKIyBDT05GSUdfREVCVUdfV1JJVEVDT1VOVCBpcyBub3Qgc2V0CiMgQ09ORklHX0RF
QlVHX01FTU9SWV9JTklUIGlzIG5vdCBzZXQKIyBDT05GSUdfREVCVUdfTElTVCBpcyBub3Qg
c2V0CiMgQ09ORklHX0RFQlVHX1NHIGlzIG5vdCBzZXQKIyBDT05GSUdfREVCVUdfTk9USUZJ
RVJTIGlzIG5vdCBzZXQKIyBDT05GSUdfREVCVUdfQ1JFREVOVElBTFMgaXMgbm90IHNldApD
T05GSUdfQVJDSF9XQU5UX0ZSQU1FX1BPSU5URVJTPXkKQ09ORklHX0ZSQU1FX1BPSU5URVI9
eQojIENPTkZJR19CT09UX1BSSU5US19ERUxBWSBpcyBub3Qgc2V0CiMgQ09ORklHX1JDVV9U
T1JUVVJFX1RFU1QgaXMgbm90IHNldAojIENPTkZJR19SQ1VfQ1BVX1NUQUxMX0RFVEVDVE9S
IGlzIG5vdCBzZXQKIyBDT05GSUdfS1BST0JFU19TQU5JVFlfVEVTVCBpcyBub3Qgc2V0CiMg
Q09ORklHX0JBQ0tUUkFDRV9TRUxGX1RFU1QgaXMgbm90IHNldAojIENPTkZJR19ERUJVR19C
TE9DS19FWFRfREVWVCBpcyBub3Qgc2V0CiMgQ09ORklHX0RFQlVHX0ZPUkNFX1dFQUtfUEVS
X0NQVSBpcyBub3Qgc2V0CiMgQ09ORklHX0xLRFRNIGlzIG5vdCBzZXQKQ09ORklHX0ZBVUxU
X0lOSkVDVElPTj15CkNPTkZJR19GQUlMU0xBQj15CkNPTkZJR19GQUlMX1BBR0VfQUxMT0M9
eQojIENPTkZJR19GQUlMX01BS0VfUkVRVUVTVCBpcyBub3Qgc2V0CiMgQ09ORklHX0ZBSUxf
SU9fVElNRU9VVCBpcyBub3Qgc2V0CiMgQ09ORklHX0ZBVUxUX0lOSkVDVElPTl9ERUJVR19G
UyBpcyBub3Qgc2V0CkNPTkZJR19MQVRFTkNZVE9QPXkKIyBDT05GSUdfU1lTQ1RMX1NZU0NB
TExfQ0hFQ0sgaXMgbm90IHNldAojIENPTkZJR19ERUJVR19QQUdFQUxMT0MgaXMgbm90IHNl
dApDT05GSUdfVVNFUl9TVEFDS1RSQUNFX1NVUFBPUlQ9eQpDT05GSUdfSEFWRV9GVU5DVElP
Tl9UUkFDRVI9eQpDT05GSUdfSEFWRV9GVU5DVElPTl9HUkFQSF9UUkFDRVI9eQpDT05GSUdf
SEFWRV9GVU5DVElPTl9HUkFQSF9GUF9URVNUPXkKQ09ORklHX0hBVkVfRlVOQ1RJT05fVFJB
Q0VfTUNPVU5UX1RFU1Q9eQpDT05GSUdfSEFWRV9EWU5BTUlDX0ZUUkFDRT15CkNPTkZJR19I
QVZFX0ZUUkFDRV9NQ09VTlRfUkVDT1JEPXkKQ09ORklHX0hBVkVfU1lTQ0FMTF9UUkFDRVBP
SU5UUz15CkNPTkZJR19SSU5HX0JVRkZFUj15CkNPTkZJR19SSU5HX0JVRkZFUl9BTExPV19T
V0FQPXkKQ09ORklHX1RSQUNJTkdfU1VQUE9SVD15CiMgQ09ORklHX0ZUUkFDRSBpcyBub3Qg
c2V0CiMgQ09ORklHX1BST1ZJREVfT0hDSTEzOTRfRE1BX0lOSVQgaXMgbm90IHNldAojIENP
TkZJR19EWU5BTUlDX0RFQlVHIGlzIG5vdCBzZXQKIyBDT05GSUdfRE1BX0FQSV9ERUJVRyBp
cyBub3Qgc2V0CiMgQ09ORklHX1NBTVBMRVMgaXMgbm90IHNldApDT05GSUdfSEFWRV9BUkNI
X0tHREI9eQojIENPTkZJR19LR0RCIGlzIG5vdCBzZXQKQ09ORklHX0hBVkVfQVJDSF9LTUVN
Q0hFQ0s9eQojIENPTkZJR19LTUVNQ0hFQ0sgaXMgbm90IHNldAojIENPTkZJR19TVFJJQ1Rf
REVWTUVNIGlzIG5vdCBzZXQKQ09ORklHX1g4Nl9WRVJCT1NFX0JPT1RVUD15CkNPTkZJR19F
QVJMWV9QUklOVEs9eQojIENPTkZJR19FQVJMWV9QUklOVEtfREJHUCBpcyBub3Qgc2V0CkNP
TkZJR19ERUJVR19TVEFDS09WRVJGTE9XPXkKIyBDT05GSUdfREVCVUdfU1RBQ0tfVVNBR0Ug
aXMgbm90IHNldAojIENPTkZJR19YODZfUFREVU1QIGlzIG5vdCBzZXQKQ09ORklHX0RFQlVH
X1JPREFUQT15CiMgQ09ORklHX0RFQlVHX1JPREFUQV9URVNUIGlzIG5vdCBzZXQKIyBDT05G
SUdfREVCVUdfTlhfVEVTVCBpcyBub3Qgc2V0CiMgQ09ORklHXzRLU1RBQ0tTIGlzIG5vdCBz
ZXQKQ09ORklHX0RPVUJMRUZBVUxUPXkKIyBDT05GSUdfSU9NTVVfU1RSRVNTIGlzIG5vdCBz
ZXQKQ09ORklHX0hBVkVfTU1JT1RSQUNFX1NVUFBPUlQ9eQojIENPTkZJR19YODZfREVDT0RF
Ul9TRUxGVEVTVCBpcyBub3Qgc2V0CkNPTkZJR19JT19ERUxBWV9UWVBFXzBYODA9MApDT05G
SUdfSU9fREVMQVlfVFlQRV8wWEVEPTEKQ09ORklHX0lPX0RFTEFZX1RZUEVfVURFTEFZPTIK
Q09ORklHX0lPX0RFTEFZX1RZUEVfTk9ORT0zCkNPTkZJR19JT19ERUxBWV8wWDgwPXkKIyBD
T05GSUdfSU9fREVMQVlfMFhFRCBpcyBub3Qgc2V0CiMgQ09ORklHX0lPX0RFTEFZX1VERUxB
WSBpcyBub3Qgc2V0CiMgQ09ORklHX0lPX0RFTEFZX05PTkUgaXMgbm90IHNldApDT05GSUdf
REVGQVVMVF9JT19ERUxBWV9UWVBFPTAKIyBDT05GSUdfREVCVUdfQk9PVF9QQVJBTVMgaXMg
bm90IHNldAojIENPTkZJR19DUEFfREVCVUcgaXMgbm90IHNldAojIENPTkZJR19PUFRJTUla
RV9JTkxJTklORyBpcyBub3Qgc2V0CkNPTkZJR19ERUJVR19TVFJJQ1RfVVNFUl9DT1BZX0NI
RUNLUz15CgojCiMgU2VjdXJpdHkgb3B0aW9ucwojCiMgQ09ORklHX0tFWVMgaXMgbm90IHNl
dAojIENPTkZJR19TRUNVUklUWSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFQ1VSSVRZRlMgaXMg
bm90IHNldAojIENPTkZJR19ERUZBVUxUX1NFQ1VSSVRZX1NFTElOVVggaXMgbm90IHNldAoj
IENPTkZJR19ERUZBVUxUX1NFQ1VSSVRZX1NNQUNLIGlzIG5vdCBzZXQKIyBDT05GSUdfREVG
QVVMVF9TRUNVUklUWV9UT01PWU8gaXMgbm90IHNldApDT05GSUdfREVGQVVMVF9TRUNVUklU
WV9EQUM9eQpDT05GSUdfREVGQVVMVF9TRUNVUklUWT0iIgpDT05GSUdfQVNZTkNfVFhfRElT
QUJMRV9QUV9WQUxfRE1BPXkKQ09ORklHX0FTWU5DX1RYX0RJU0FCTEVfWE9SX1ZBTF9ETUE9
eQpDT05GSUdfQ1JZUFRPPXkKCiMKIyBDcnlwdG8gY29yZSBvciBoZWxwZXIKIwpDT05GSUdf
Q1JZUFRPX0FMR0FQST15CkNPTkZJR19DUllQVE9fQUxHQVBJMj15CkNPTkZJR19DUllQVE9f
QUVBRDI9eQpDT05GSUdfQ1JZUFRPX0JMS0NJUEhFUj1tCkNPTkZJR19DUllQVE9fQkxLQ0lQ
SEVSMj15CkNPTkZJR19DUllQVE9fSEFTSD15CkNPTkZJR19DUllQVE9fSEFTSDI9eQpDT05G
SUdfQ1JZUFRPX1JORzI9eQpDT05GSUdfQ1JZUFRPX1BDT01QPXkKQ09ORklHX0NSWVBUT19N
QU5BR0VSPW0KQ09ORklHX0NSWVBUT19NQU5BR0VSMj15CiMgQ09ORklHX0NSWVBUT19HRjEy
OE1VTCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19OVUxMIGlzIG5vdCBzZXQKQ09ORklH
X0NSWVBUT19XT1JLUVVFVUU9eQojIENPTkZJR19DUllQVE9fQ1JZUFREIGlzIG5vdCBzZXQK
IyBDT05GSUdfQ1JZUFRPX0FVVEhFTkMgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fVEVT
VCBpcyBub3Qgc2V0CgojCiMgQXV0aGVudGljYXRlZCBFbmNyeXB0aW9uIHdpdGggQXNzb2Np
YXRlZCBEYXRhCiMKIyBDT05GSUdfQ1JZUFRPX0NDTSBpcyBub3Qgc2V0CiMgQ09ORklHX0NS
WVBUT19HQ00gaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fU0VRSVYgaXMgbm90IHNldAoK
IwojIEJsb2NrIG1vZGVzCiMKQ09ORklHX0NSWVBUT19DQkM9bQojIENPTkZJR19DUllQVE9f
Q1RSIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX0NUUyBpcyBub3Qgc2V0CkNPTkZJR19D
UllQVE9fRUNCPW0KIyBDT05GSUdfQ1JZUFRPX0xSVyBpcyBub3Qgc2V0CkNPTkZJR19DUllQ
VE9fUENCQz1tCiMgQ09ORklHX0NSWVBUT19YVFMgaXMgbm90IHNldAoKIwojIEhhc2ggbW9k
ZXMKIwojIENPTkZJR19DUllQVE9fSE1BQyBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19Y
Q0JDIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX1ZNQUMgaXMgbm90IHNldAoKIwojIERp
Z2VzdAojCkNPTkZJR19DUllQVE9fQ1JDMzJDPW0KIyBDT05GSUdfQ1JZUFRPX0NSQzMyQ19J
TlRFTCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19HSEFTSCBpcyBub3Qgc2V0CiMgQ09O
RklHX0NSWVBUT19NRDQgaXMgbm90IHNldApDT05GSUdfQ1JZUFRPX01ENT15CkNPTkZJR19D
UllQVE9fTUlDSEFFTF9NSUM9bQojIENPTkZJR19DUllQVE9fUk1EMTI4IGlzIG5vdCBzZXQK
IyBDT05GSUdfQ1JZUFRPX1JNRDE2MCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19STUQy
NTYgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fUk1EMzIwIGlzIG5vdCBzZXQKQ09ORklH
X0NSWVBUT19TSEExPW0KIyBDT05GSUdfQ1JZUFRPX1NIQTI1NiBpcyBub3Qgc2V0CiMgQ09O
RklHX0NSWVBUT19TSEE1MTIgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fVEdSMTkyIGlz
IG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX1dQNTEyIGlzIG5vdCBzZXQKCiMKIyBDaXBoZXJz
CiMKQ09ORklHX0NSWVBUT19BRVM9bQojIENPTkZJR19DUllQVE9fQUVTXzU4NiBpcyBub3Qg
c2V0CiMgQ09ORklHX0NSWVBUT19BTlVCSVMgaXMgbm90IHNldApDT05GSUdfQ1JZUFRPX0FS
QzQ9bQojIENPTkZJR19DUllQVE9fQkxPV0ZJU0ggaXMgbm90IHNldAojIENPTkZJR19DUllQ
VE9fQ0FNRUxMSUEgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fQ0FTVDUgaXMgbm90IHNl
dAojIENPTkZJR19DUllQVE9fQ0FTVDYgaXMgbm90IHNldApDT05GSUdfQ1JZUFRPX0RFUz1t
CiMgQ09ORklHX0NSWVBUT19GQ1JZUFQgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fS0hB
WkFEIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX1NBTFNBMjAgaXMgbm90IHNldAojIENP
TkZJR19DUllQVE9fU0FMU0EyMF81ODYgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fU0VF
RCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19TRVJQRU5UIGlzIG5vdCBzZXQKIyBDT05G
SUdfQ1JZUFRPX1RFQSBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19UV09GSVNIIGlzIG5v
dCBzZXQKIyBDT05GSUdfQ1JZUFRPX1RXT0ZJU0hfNTg2IGlzIG5vdCBzZXQKCiMKIyBDb21w
cmVzc2lvbgojCiMgQ09ORklHX0NSWVBUT19ERUZMQVRFIGlzIG5vdCBzZXQKIyBDT05GSUdf
Q1JZUFRPX1pMSUIgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fTFpPIGlzIG5vdCBzZXQK
CiMKIyBSYW5kb20gTnVtYmVyIEdlbmVyYXRpb24KIwojIENPTkZJR19DUllQVE9fQU5TSV9D
UFJORyBpcyBub3Qgc2V0CkNPTkZJR19DUllQVE9fSFc9eQojIENPTkZJR19DUllQVE9fREVW
X1BBRExPQ0sgaXMgbm90IHNldApDT05GSUdfQ1JZUFRPX0RFVl9HRU9ERT1tCiMgQ09ORklH
X0NSWVBUT19ERVZfSElGTl83OTVYIGlzIG5vdCBzZXQKQ09ORklHX0hBVkVfS1ZNPXkKQ09O
RklHX0hBVkVfS1ZNX0lSUUNISVA9eQpDT05GSUdfSEFWRV9LVk1fRVZFTlRGRD15CkNPTkZJ
R19LVk1fQVBJQ19BUkNISVRFQ1RVUkU9eQpDT05GSUdfS1ZNX01NSU89eQpDT05GSUdfVklS
VFVBTElaQVRJT049eQpDT05GSUdfS1ZNPW0KIyBDT05GSUdfS1ZNX0lOVEVMIGlzIG5vdCBz
ZXQKQ09ORklHX0tWTV9BTUQ9bQojIENPTkZJR19WSE9TVF9ORVQgaXMgbm90IHNldAojIENP
TkZJR19MR1VFU1QgaXMgbm90IHNldAojIENPTkZJR19WSVJUSU9fUENJIGlzIG5vdCBzZXQK
IyBDT05GSUdfVklSVElPX0JBTExPT04gaXMgbm90IHNldAojIENPTkZJR19CSU5BUllfUFJJ
TlRGIGlzIG5vdCBzZXQKCiMKIyBMaWJyYXJ5IHJvdXRpbmVzCiMKQ09ORklHX0JJVFJFVkVS
U0U9eQpDT05GSUdfR0VORVJJQ19GSU5EX0ZJUlNUX0JJVD15CkNPTkZJR19HRU5FUklDX0ZJ
TkRfTkVYVF9CSVQ9eQpDT05GSUdfR0VORVJJQ19GSU5EX0xBU1RfQklUPXkKQ09ORklHX0NS
Q19DQ0lUVD1tCiMgQ09ORklHX0NSQzE2IGlzIG5vdCBzZXQKQ09ORklHX0NSQ19UMTBESUY9
bQpDT05GSUdfQ1JDX0lUVV9UPW0KQ09ORklHX0NSQzMyPXkKIyBDT05GSUdfQ1JDNyBpcyBu
b3Qgc2V0CkNPTkZJR19MSUJDUkMzMkM9bQpDT05GSUdfQVVESVRfR0VORVJJQz15CkNPTkZJ
R19aTElCX0lORkxBVEU9bQpDT05GSUdfWkxJQl9ERUZMQVRFPW0KQ09ORklHX1RFWFRTRUFS
Q0g9eQpDT05GSUdfVEVYVFNFQVJDSF9LTVA9bQpDT05GSUdfVEVYVFNFQVJDSF9CTT1tCkNP
TkZJR19URVhUU0VBUkNIX0ZTTT1tCkNPTkZJR19IQVNfSU9NRU09eQpDT05GSUdfSEFTX0lP
UE9SVD15CkNPTkZJR19IQVNfRE1BPXkKQ09ORklHX0NIRUNLX1NJR05BVFVSRT15CkNPTkZJ
R19OTEFUVFI9eQo=
--------------030007030504050405020609--
