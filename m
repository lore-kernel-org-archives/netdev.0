From: =?ISO-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>
Subject: Re: [Bugme-new] [Bug 14794] New: IP address assigned by DHCP is	dropped
 after ~40 seconds
Date: Fri, 18 Dec 2009 17:57:53 +0100
Message-ID: <4B2BB491.5060708@freemail.hu>
References: <bug-14794-10286@http.bugzilla.kernel.org/> <20091216154713.f082e7cf.akpm@linux-foundation.org> <4B2A9A40.90203@freemail.hu> <20091217132451.b168a796.akpm@linux-foundation.org> <4B2AA64C.50709@gmail.com> <4B2B35B7.6060703@freemail.hu> <adaskb83df6.fsf@roland-alpha.cisco.com> <20091218114123.GA8310@ff.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010204040003060804050201"
Cc: Roland Dreier <rdreier@cisco.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01d.mail.t-online.hu ([84.2.42.6]:60774 "EHLO
	mail01d.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046AbZLRQ6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 11:58:07 -0500
In-Reply-To: <20091218114123.GA8310@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010204040003060804050201
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit

Jarek Poplawski wrote:
> happen here. Then dhcp client might hit some limit of tries. On the
> other hand, such an effect could be amplified by changes in 2.6.32
> too (e.g. with different timing). Could you attach 2.6.31 dmesg after
> this test?

OK, here is the dmesg of 2.6.31. In this case I took care about unplug
the network cable only once.

Regards,

	Márton Németh

--------------010204040003060804050201
Content-Type: text/plain;
 name="dmesg-2.6.31.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dmesg-2.6.31.txt"

[    0.000000] Linux version 2.6.31 (nmarci@europa) (gcc version 4.3.2 (Debian 4.3.2-1.1) ) #1 PREEMPT Sat Nov 14 09:53:19 CET 2009
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   NSC Geode by NSC
[    0.000000]   Cyrix CyrixInstead
[    0.000000]   Centaur CentaurHauls
[    0.000000]   Transmeta GenuineTMx86
[    0.000000]   Transmeta TransmetaCPU
[    0.000000]   UMC UMC UMC UMC
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000d8000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000003bf70000 (usable)
[    0.000000]  BIOS-e820: 000000003bf70000 - 000000003bf7a000 (ACPI data)
[    0.000000]  BIOS-e820: 000000003bf7a000 - 000000003bf80000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000003bf80000 - 0000000040000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fffe0000 - 0000000100000000 (reserved)
[    0.000000] DMI present.
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
[    0.000000] init_memory_mapping: 0000000000000000-00000000377fe000
[    0.000000]  0000000000 - 0000400000 page 4k
[    0.000000]  0000400000 - 0037400000 page 2M
[    0.000000]  0037400000 - 00377fe000 page 4k
[    0.000000] kernel direct mapping tables up to 377fe000 @ 7000-c000
[    0.000000] ACPI: RSDP 000f68d0 00014 (v00 PTLTD )
[    0.000000] ACPI: RSDT 3bf7600b 00030 (v01 PTLTD    RSDT   06040000  LTP 00000000)
[    0.000000] ACPI: FACP 3bf79e87 00074 (v01 AMDK8  PTLTW    06040000 PTL_ 000F4240)
[    0.000000] ACPI: DSDT 3bf7603b 03E4C (v01  VIA   PTL_ACPI 06040000 MSFT 0100000E)
[    0.000000] ACPI: FACS 3bf7afc0 00040
[    0.000000] ACPI: SSDT 3bf79efb 000B5 (v01 PTLTD  POWERNOW 06040000  LTP 00000001)
[    0.000000] ACPI: APIC 3bf79fb0 00050 (v01 PTLTD  	 APIC   06040000  LTP 00000000)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 71MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 0 - 377fe000
[    0.000000]   node 0 low ram: 00000000 - 377fe000
[    0.000000]   node 0 bootmap 00008000 - 0000ef00
[    0.000000] (6 early reservations) ==> bootmem [0000000000 - 00377fe000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
[    0.000000]   #1 [0000100000 - 0000aba290]    TEXT DATA BSS ==> [0000100000 - 0000aba290]
[    0.000000]   #2 [000009f800 - 0000100000]    BIOS reserved ==> [000009f800 - 0000100000]
[    0.000000]   #3 [0000abb000 - 0000abf118]              BRK ==> [0000abb000 - 0000abf118]
[    0.000000]   #4 [0000007000 - 0000008000]          PGTABLE ==> [0000007000 - 0000008000]
[    0.000000]   #5 [0000008000 - 000000f000]          BOOTMAP ==> [0000008000 - 000000f000]
[    0.000000] found SMP MP-table at [c00f6870] f6870
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000000 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x000377fe
[    0.000000]   HighMem  0x000377fe -> 0x0003bf70
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000000 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0003bf70
[    0.000000] On node 0 totalpages: 245519
[    0.000000] free_area_init_node: node 0, pgdat c04c1be0, node_mem_map c1000000
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3967 pages, LIFO batch:0
[    0.000000]   Normal zone: 1744 pages used for memmap
[    0.000000]   Normal zone: 221486 pages, LIFO batch:31
[    0.000000]   HighMem zone: 143 pages used for memmap
[    0.000000]   HighMem zone: 18147 pages, LIFO batch:3
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x4008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 1, version 3, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 high edge)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] nr_irqs_gsi: 24
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000d8000
[    0.000000] PM: Registered nosave memory: 00000000000d8000 - 0000000000100000
[    0.000000] Allocating PCI resources starting at 40000000 (gap: 40000000:bffe0000)
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 243600
[    0.000000] Kernel command line: root=/dev/hda1 ro log_buf_len=1M
[    0.000000] log_buf_len: 1048576
[    0.000000] PID hash table entries: 4096 (order: 12, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (000377fe:0003bf70)
[    0.000000] Memory: 962276k/982464k available (2631k kernel code, 19540k reserved, 1233k data, 364k init, 73160k highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfffa4000 - 0xfffff000   ( 364 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.000000]       .init : 0xc04c7000 - 0xc0522000   ( 364 kB)
[    0.000000]       .data : 0xc0391d8d - 0xc04c62d8   (1233 kB)
[    0.000000]       .text : 0xc0100000 - 0xc0391d8d   (2631 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000] NR_IRQS:288
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 1603.719 MHz processor.
[    0.000999] Console: colour VGA+ 80x25
[    0.000999] console [tty0] enabled
[    0.000999] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000999] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000999] ... MAX_LOCK_DEPTH:          48
[    0.000999] ... MAX_LOCKDEP_KEYS:        8191
[    0.000999] ... CLASSHASH_SIZE:          4096
[    0.000999] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000999] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000999] ... CHAINHASH_SIZE:          16384
[    0.000999]  memory used by lock dependency info: 3487 kB
[    0.000999]  per task-struct memory footprint: 1152 bytes
[    0.000999] ------------------------
[    0.000999] | Locking API testsuite:
[    0.000999] ----------------------------------------------------------------------------
[    0.000999]                                  | spin |wlock |rlock |mutex | wsem | rsem |
[    0.000999]   --------------------------------------------------------------------------
[    0.000999]                      A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]                     double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]                   initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]                  bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000999]   --------------------------------------------------------------------------
[    0.000999]               recursive read-lock:             |  ok  |             |  ok  |
[    0.000999]            recursive read-lock #2:             |  ok  |             |  ok  |
[    0.000999]             mixed read-write-lock:             |  ok  |             |  ok  |
[    0.000999]             mixed write-read-lock:             |  ok  |             |  ok  |
[    0.000999]   --------------------------------------------------------------------------
[    0.000999]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000999]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000999]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000999]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000999]        sirq-safe-A => hirqs-on/12:  ok  |  ok  |  ok  |
[    0.000999]        sirq-safe-A => hirqs-on/21:  ok  |  ok  |  ok  |
[    0.000999]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000999]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000999]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000999]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000999]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000999]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000999]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000999]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000999]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000999]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000999]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000999]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000999]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000999]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000999]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000999]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000999]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000999]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000999]       hard-irq read-recursion/123:  ok  |
[    0.000999]       soft-irq read-recursion/123:  ok  |
[    0.000999]       hard-irq read-recursion/132:  ok  |
[    0.000999]       soft-irq read-recursion/132:  ok  |
[    0.000999]       hard-irq read-recursion/213:  ok  |
[    0.000999]       soft-irq read-recursion/213:  ok  |
[    0.000999]       hard-irq read-recursion/231:  ok  |
[    0.000999]       soft-irq read-recursion/231:  ok  |
[    0.000999]       hard-irq read-recursion/312:  ok  |
[    0.000999]       soft-irq read-recursion/312:  ok  |
[    0.000999]       hard-irq read-recursion/321:  ok  |
[    0.000999]       soft-irq read-recursion/321:  ok  |
[    0.000999] -------------------------------------------------------
[    0.000999] Good, all 218 testcases passed! |
[    0.000999] ---------------------------------
[    0.000999] ODEBUG: 4 of 4 active objects replaced
[    0.001045] Calibrating delay loop (skipped), value calculated using timer frequency.. 3207.43 BogoMIPS (lpj=1603719)
[    0.002024] Mount-cache hash table entries: 512
[    0.005220] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
[    0.005285] CPU: L2 Cache: 128K (64 bytes/line)
[    0.005343] mce: CPU supports 5 MCE banks
[    0.005430] CPU: Mobile AMD Sempron(tm) Processor 2600+ stepping 00
[    0.005601] Checking 'hlt' instruction... OK.
[    0.009488] ACPI: Core revision 20090521
[    0.013535] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.013595] no locks held by swapper/0.
[    0.013650] Modules linked in:
[    0.013746] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.013803] Call Trace:
[    0.013865]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.013927]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.013987]  [<c038a527>] schedule+0x457/0x5a0
[    0.014030]  [<c015405b>] ? trace_hardirqs_on+0xb/0x10
[    0.014091]  [<c02bd065>] ? acpi_ps_pop_scope+0x74/0x7f
[    0.014152]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.014210]  [<c038a715>] _cond_resched+0x25/0x40
[    0.014268]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.014328]  [<c02bb9fa>] ? acpi_ps_get_next_simple_arg+0xdb/0xe6
[    0.014388]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.014447]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.014507]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.014567]  [<c02bb083>] acpi_ns_parse_table+0x34/0x71
[    0.014629]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.014689]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.014749]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.014810]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.014868]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.014927]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.018048] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.018107] no locks held by swapper/0.
[    0.018162] Modules linked in:
[    0.018255] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.018312] Call Trace:
[    0.018368]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.018426]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.018486]  [<c038a527>] schedule+0x457/0x5a0
[    0.018544]  [<c02bd1a6>] ? acpi_ps_free_op+0x4c/0x51
[    0.018604]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.018662]  [<c038a715>] _cond_resched+0x25/0x40
[    0.018720]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.018781]  [<c02c2e45>] ? acpi_ut_delete_generic_state+0x13/0x15
[    0.018843]  [<c02a9998>] ? acpi_ds_scope_stack_pop+0xd0/0xda
[    0.018903]  [<c02ab7e7>] ? acpi_ds_load1_end_op+0x1c9/0x1d9
[    0.018963]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.019133]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.019193]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.019253]  [<c02bb083>] acpi_ns_parse_table+0x34/0x71
[    0.019314]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.019373]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.019432]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.019492]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.019551]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.019610]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.023044] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.023103] no locks held by swapper/0.
[    0.023158] Modules linked in:
[    0.023252] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.023309] Call Trace:
[    0.023366]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.023425]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.023484]  [<c038a527>] schedule+0x457/0x5a0
[    0.023542]  [<c02bd1a6>] ? acpi_ps_free_op+0x4c/0x51
[    0.023602]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.023661]  [<c038a715>] _cond_resched+0x25/0x40
[    0.023719]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.023779]  [<c02c2e45>] ? acpi_ut_delete_generic_state+0x13/0x15
[    0.023841]  [<c02a9998>] ? acpi_ds_scope_stack_pop+0xd0/0xda
[    0.023900]  [<c02ab7e7>] ? acpi_ds_load1_end_op+0x1c9/0x1d9
[    0.023960]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.024101]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.024161]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.024221]  [<c02bb083>] acpi_ns_parse_table+0x34/0x71
[    0.024282]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.024342]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.024401]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.024461]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.024519]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.024579]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.028017] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.028077] no locks held by swapper/0.
[    0.028131] Modules linked in:
[    0.028225] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.028282] Call Trace:
[    0.028338]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.028396]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.028455]  [<c038a527>] schedule+0x457/0x5a0
[    0.028513]  [<c015405b>] ? trace_hardirqs_on+0xb/0x10
[    0.028573]  [<c02bd065>] ? acpi_ps_pop_scope+0x74/0x7f
[    0.028632]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.028691]  [<c038a715>] _cond_resched+0x25/0x40
[    0.028749]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.028809]  [<c02bb9fa>] ? acpi_ps_get_next_simple_arg+0xdb/0xe6
[    0.028869]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.028928]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.028987]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.029106]  [<c02bb083>] acpi_ns_parse_table+0x34/0x71
[    0.029167]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.029227]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.029287]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.029346]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.029405]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.029465]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.033087] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.033147] no locks held by swapper/0.
[    0.033201] Modules linked in:
[    0.033295] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.033352] Call Trace:
[    0.033409]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.033469]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.033528]  [<c038a527>] schedule+0x457/0x5a0
[    0.033585]  [<c015405b>] ? trace_hardirqs_on+0xb/0x10
[    0.033645]  [<c02bd065>] ? acpi_ps_pop_scope+0x74/0x7f
[    0.033705]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.033763]  [<c038a715>] _cond_resched+0x25/0x40
[    0.033821]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.033882]  [<c02c2e45>] ? acpi_ut_delete_generic_state+0x13/0x15
[    0.033945]  [<c02a9998>] ? acpi_ds_scope_stack_pop+0xd0/0xda
[    0.034100]  [<c02ab7e7>] ? acpi_ds_load1_end_op+0x1c9/0x1d9
[    0.034160]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.034220]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.034279]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.034340]  [<c02bb083>] acpi_ns_parse_table+0x34/0x71
[    0.034401]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.034461]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.034521]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.034580]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.034639]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.034699]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.038013] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.038073] no locks held by swapper/0.
[    0.038128] Modules linked in:
[    0.038222] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.038278] Call Trace:
[    0.038335]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.038394]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.038452]  [<c038a527>] schedule+0x457/0x5a0
[    0.038510]  [<c015405b>] ? trace_hardirqs_on+0xb/0x10
[    0.038569]  [<c02bd065>] ? acpi_ps_pop_scope+0x74/0x7f
[    0.038629]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.038688]  [<c038a715>] _cond_resched+0x25/0x40
[    0.038746]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.038805]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.038865]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.038924]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.038985]  [<c02bb083>] acpi_ns_parse_table+0x34/0x71
[    0.039109]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.039169]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.039229]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.039289]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.039348]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.039407]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.043071] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.043133] no locks held by swapper/0.
[    0.043188] Modules linked in:
[    0.043283] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.043339] Call Trace:
[    0.043398]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.043457]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.044102]  [<c038a527>] schedule+0x457/0x5a0
[    0.044162]  [<c02bd1a6>] ? acpi_ps_free_op+0x4c/0x51
[    0.044222]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.044280]  [<c038a715>] _cond_resched+0x25/0x40
[    0.044339]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.044399]  [<c02c2e45>] ? acpi_ut_delete_generic_state+0x13/0x15
[    0.044462]  [<c02a9998>] ? acpi_ds_scope_stack_pop+0xd0/0xda
[    0.044522]  [<c02ab7e7>] ? acpi_ds_load1_end_op+0x1c9/0x1d9
[    0.045094]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.045153]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.045213]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.045273]  [<c02bb083>] acpi_ns_parse_table+0x34/0x71
[    0.045335]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.045394]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.045454]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.045515]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.045573]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.045633]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.048077] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.048136] no locks held by swapper/0.
[    0.048190] Modules linked in:
[    0.048284] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.048340] Call Trace:
[    0.048396]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.048455]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.048514]  [<c038a527>] schedule+0x457/0x5a0
[    0.048572]  [<c015405b>] ? trace_hardirqs_on+0xb/0x10
[    0.048632]  [<c02bd065>] ? acpi_ps_pop_scope+0x74/0x7f
[    0.048692]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.048750]  [<c038a715>] _cond_resched+0x25/0x40
[    0.048808]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.048868]  [<c02bb9fa>] ? acpi_ps_get_next_simple_arg+0xdb/0xe6
[    0.048928]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.049105]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.049164]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.049225]  [<c02bb083>] acpi_ns_parse_table+0x34/0x71
[    0.049286]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.049346]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.049405]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.049464]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.049522]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.049582]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.053022] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.053082] no locks held by swapper/0.
[    0.053136] Modules linked in:
[    0.053231] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.053287] Call Trace:
[    0.053344]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.053404]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.053463]  [<c038a527>] schedule+0x457/0x5a0
[    0.053520]  [<c015405b>] ? trace_hardirqs_on+0xb/0x10
[    0.053580]  [<c02bd065>] ? acpi_ps_pop_scope+0x74/0x7f
[    0.053640]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.053698]  [<c038a715>] _cond_resched+0x25/0x40
[    0.053756]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.053816]  [<c02bb9fa>] ? acpi_ps_get_next_simple_arg+0xdb/0xe6
[    0.053877]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.053936]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.054101]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.054162]  [<c02bb083>] acpi_ns_parse_table+0x34/0x71
[    0.054223]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.054283]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.054342]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.054403]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.054462]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.054521]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.058049] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.058108] no locks held by swapper/0.
[    0.058163] Modules linked in:
[    0.058257] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.058313] Call Trace:
[    0.058370]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.058429]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.058488]  [<c038a527>] schedule+0x457/0x5a0
[    0.058546]  [<c02bd1a6>] ? acpi_ps_free_op+0x4c/0x51
[    0.058606]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.058664]  [<c038a715>] _cond_resched+0x25/0x40
[    0.058723]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.058785]  [<c02c2e45>] ? acpi_ut_delete_generic_state+0x13/0x15
[    0.058849]  [<c02a9998>] ? acpi_ds_scope_stack_pop+0xd0/0xda
[    0.058909]  [<c02ab7e7>] ? acpi_ds_load1_end_op+0x1c9/0x1d9
[    0.058969]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.059106]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.059166]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.059227]  [<c02bb083>] acpi_ns_parse_table+0x34/0x71
[    0.059288]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.059348]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.059407]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.059467]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.059525]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.059585]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.063031] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.063091] no locks held by swapper/0.
[    0.063146] Modules linked in:
[    0.063239] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.063296] Call Trace:
[    0.063353]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.063413]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.063472]  [<c038a527>] schedule+0x457/0x5a0
[    0.063530]  [<c015405b>] ? trace_hardirqs_on+0xb/0x10
[    0.063591]  [<c02bd065>] ? acpi_ps_pop_scope+0x74/0x7f
[    0.063651]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.063710]  [<c038a715>] _cond_resched+0x25/0x40
[    0.063768]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.063827]  [<c02ab0d7>] ? acpi_ds_load2_end_op+0x1ae/0x3f1
[    0.063887]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.063947]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.064105]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.064166]  [<c02bb0b5>] acpi_ns_parse_table+0x66/0x71
[    0.064227]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.064286]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.064346]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.064406]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.064465]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.064524]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.068249] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.068309] no locks held by swapper/0.
[    0.068364] Modules linked in:
[    0.068458] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.068515] Call Trace:
[    0.068573]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.068632]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.068691]  [<c038a527>] schedule+0x457/0x5a0
[    0.068749]  [<c02bd1a6>] ? acpi_ps_free_op+0x4c/0x51
[    0.068809]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.068867]  [<c038a715>] _cond_resched+0x25/0x40
[    0.068925]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.069108]  [<c02ab0d7>] ? acpi_ds_load2_end_op+0x1ae/0x3f1
[    0.069169]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.069229]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.069288]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.069349]  [<c02bb0b5>] acpi_ns_parse_table+0x66/0x71
[    0.069411]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.069470]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.069530]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.069590]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.069649]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.069709]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.073047] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.073107] no locks held by swapper/0.
[    0.073161] Modules linked in:
[    0.073255] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.073311] Call Trace:
[    0.073369]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.073428]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.073487]  [<c038a527>] schedule+0x457/0x5a0
[    0.073545]  [<c015405b>] ? trace_hardirqs_on+0xb/0x10
[    0.073604]  [<c02bd065>] ? acpi_ps_pop_scope+0x74/0x7f
[    0.073664]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.073723]  [<c038a715>] _cond_resched+0x25/0x40
[    0.073781]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.073841]  [<c02ab237>] ? acpi_ds_load2_end_op+0x30e/0x3f1
[    0.073901]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.073960]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.074103]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.074164]  [<c02bb0b5>] acpi_ns_parse_table+0x66/0x71
[    0.074226]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.074286]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.074346]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.074405]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.074464]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.074523]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.078085] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.078145] no locks held by swapper/0.
[    0.078199] Modules linked in:
[    0.078294] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.078350] Call Trace:
[    0.078407]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.078466]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.078525]  [<c038a527>] schedule+0x457/0x5a0
[    0.078584]  [<c02bd1a6>] ? acpi_ps_free_op+0x4c/0x51
[    0.078643]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.078702]  [<c038a715>] _cond_resched+0x25/0x40
[    0.078761]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.078820]  [<c02ab0d7>] ? acpi_ds_load2_end_op+0x1ae/0x3f1
[    0.078880]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.078940]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.079099]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.079160]  [<c02bb0b5>] acpi_ns_parse_table+0x66/0x71
[    0.079221]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.080101]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.080161]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.080221]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.080280]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.080339]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.083066] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.083125] no locks held by swapper/0.
[    0.083180] Modules linked in:
[    0.083274] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.083330] Call Trace:
[    0.083388]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.083447]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.083505]  [<c038a527>] schedule+0x457/0x5a0
[    0.083563]  [<c015405b>] ? trace_hardirqs_on+0xb/0x10
[    0.083623]  [<c02bd065>] ? acpi_ps_pop_scope+0x74/0x7f
[    0.083683]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.083741]  [<c038a715>] _cond_resched+0x25/0x40
[    0.083799]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.083859]  [<c02bb9fa>] ? acpi_ps_get_next_simple_arg+0xdb/0xe6
[    0.083919]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.084097]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.084157]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.084218]  [<c02bb0b5>] acpi_ns_parse_table+0x66/0x71
[    0.084279]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.084338]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.084398]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.084458]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.084517]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.084576]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.088025] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.088086] no locks held by swapper/0.
[    0.088140] Modules linked in:
[    0.088234] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.088291] Call Trace:
[    0.088349]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.088408]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.088467]  [<c038a527>] schedule+0x457/0x5a0
[    0.088525]  [<c015405b>] ? trace_hardirqs_on+0xb/0x10
[    0.088586]  [<c02bd065>] ? acpi_ps_pop_scope+0x74/0x7f
[    0.088646]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.088704]  [<c038a715>] _cond_resched+0x25/0x40
[    0.088762]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.088822]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.088882]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.088941]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.089096]  [<c02bb0b5>] acpi_ns_parse_table+0x66/0x71
[    0.089159]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.089218]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.089278]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.089339]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.089397]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.089457]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.093015] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.093075] no locks held by swapper/0.
[    0.093130] Modules linked in:
[    0.093223] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.093280] Call Trace:
[    0.093337]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.093397]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.093456]  [<c038a527>] schedule+0x457/0x5a0
[    0.093514]  [<c015405b>] ? trace_hardirqs_on+0xb/0x10
[    0.093573]  [<c02bd065>] ? acpi_ps_pop_scope+0x74/0x7f
[    0.093633]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.093692]  [<c038a715>] _cond_resched+0x25/0x40
[    0.093750]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.093810]  [<c02bb9fa>] ? acpi_ps_get_next_simple_arg+0xdb/0xe6
[    0.093870]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.093930]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.094097]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.094158]  [<c02bb0b5>] acpi_ns_parse_table+0x66/0x71
[    0.094219]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.094279]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.094338]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.094398]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.094457]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.094517]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.097997] BUG: scheduling while atomic: swapper/0/0x10000002
[    0.098056] no locks held by swapper/0.
[    0.098110] Modules linked in:
[    0.098204] Pid: 0, comm: swapper Not tainted 2.6.31 #1
[    0.098261] Call Trace:
[    0.098317]  [<c0389dc5>] ? printk+0x18/0x1b
[    0.098377]  [<c012425d>] __schedule_bug+0x7d/0x90
[    0.098436]  [<c038a527>] schedule+0x457/0x5a0
[    0.098493]  [<c015405b>] ? trace_hardirqs_on+0xb/0x10
[    0.098553]  [<c02bd065>] ? acpi_ps_pop_scope+0x74/0x7f
[    0.098613]  [<c0125ec7>] __cond_resched+0x27/0x40
[    0.098671]  [<c038a715>] _cond_resched+0x25/0x40
[    0.098729]  [<c02bc65f>] acpi_ps_complete_op+0x20f/0x21e
[    0.098789]  [<c02ab202>] ? acpi_ds_load2_end_op+0x2d9/0x3f1
[    0.098849]  [<c02bb9fa>] ? acpi_ps_get_next_simple_arg+0xdb/0xe6
[    0.098909]  [<c02bccd6>] acpi_ps_parse_loop+0x668/0x7b6
[    0.098969]  [<c02bbfda>] acpi_ps_parse_aml+0xcf/0x31f
[    0.099095]  [<c02bb039>] acpi_ns_one_complete_parse+0x109/0x11f
[    0.099156]  [<c02bb0b5>] acpi_ns_parse_table+0x66/0x71
[    0.099217]  [<c02b8056>] acpi_ns_load_table+0x5e/0xdc
[    0.099277]  [<c02becb4>] acpi_load_tables+0x66/0x139
[    0.099336]  [<c04df15a>] acpi_early_init+0x5d/0xeb
[    0.099396]  [<c04c7765>] start_kernel+0x2a5/0x2f2
[    0.099455]  [<c04c7274>] ? unknown_bootoption+0x0/0x1fb
[    0.099514]  [<c04c703f>] __init_begin+0x3f/0x41
[    0.104984] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=0 pin2=0
[    0.120488] NET: Registered protocol family 16
[    0.124845] EISA bus registered
[    0.125096] ACPI: bus type pci registered
[    0.134533] PCI: PCI BIOS revision 2.10 entry at 0xfd88c, last bus=1
[    0.134598] PCI: Using configuration type 1 for base access
[    0.157462] bio: create slab <bio-0> at 0
[    0.161186] ACPI: EC: Look up EC in DSDT
[    0.241732] ACPI: Interpreter enabled
[    0.241798] ACPI: (supports S0 S3 S4 S5)
[    0.242399] ACPI: Using IOAPIC for interrupt routing
[    0.333586] ACPI: EC: non-query interrupt received, switching to interrupt mode
[    0.837043] ACPI: EC: missing confirmations, switch off interrupt mode.
[    0.881277] ACPI: EC: GPE = 0xb, I/O: command/status = 0x66, data = 0x62
[    0.881342] ACPI: EC: driver started in poll mode
[    0.904656] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.906024] pci 0000:00:00.0: reg 10 32bit mmio: [0xe0000000-0xefffffff]
[    0.906649] pci 0000:00:01.0: supports D1
[    0.906746] pci 0000:00:08.0: reg 10 io port: [0x1000-0x10ff]
[    0.906756] pci 0000:00:08.0: reg 14 32bit mmio: [0xd0004000-0xd00040ff]
[    0.906807] pci 0000:00:08.0: supports D1 D2
[    0.906811] pci 0000:00:08.0: PME# supported from D1 D2 D3hot D3cold
[    0.906877] pci 0000:00:08.0: PME# disabled
[    0.907020] pci 0000:00:0c.0: reg 10 32bit mmio: [0x000000-0x000fff]
[    0.907045] pci 0000:00:0c.0: supports D1 D2
[    0.907049] pci 0000:00:0c.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.907111] pci 0000:00:0c.0: PME# disabled
[    0.907238] pci 0000:00:0e.0: reg 10 32bit mmio: [0xd0001000-0xd0001fff]
[    0.907248] pci 0000:00:0e.0: reg 14 32bit mmio: [0xd0000000-0xd0000fff]
[    0.907297] pci 0000:00:0e.0: supports D1 D2
[    0.907301] pci 0000:00:0e.0: PME# supported from D1 D2 D3hot D3cold
[    0.907363] pci 0000:00:0e.0: PME# disabled
[    0.907489] pci 0000:00:0e.1: reg 10 32bit mmio: [0xd0003000-0xd0003fff]
[    0.907499] pci 0000:00:0e.1: reg 14 32bit mmio: [0xd0002000-0xd0002fff]
[    0.907548] pci 0000:00:0e.1: supports D1 D2
[    0.907551] pci 0000:00:0e.1: PME# supported from D1 D2 D3hot D3cold
[    0.907613] pci 0000:00:0e.1: PME# disabled
[    0.907769] pci 0000:00:10.0: reg 20 io port: [0x1c00-0x1c1f]
[    0.907804] pci 0000:00:10.0: supports D1 D2
[    0.907807] pci 0000:00:10.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.907869] pci 0000:00:10.0: PME# disabled
[    0.908021] pci 0000:00:10.1: reg 20 io port: [0x1c20-0x1c3f]
[    0.908055] pci 0000:00:10.1: supports D1 D2
[    0.908059] pci 0000:00:10.1: PME# supported from D0 D1 D2 D3hot D3cold
[    0.908121] pci 0000:00:10.1: PME# disabled
[    0.908266] pci 0000:00:10.2: reg 20 io port: [0x1c40-0x1c5f]
[    0.908300] pci 0000:00:10.2: supports D1 D2
[    0.908304] pci 0000:00:10.2: PME# supported from D0 D1 D2 D3hot D3cold
[    0.908366] pci 0000:00:10.2: PME# disabled
[    0.908499] pci 0000:00:10.3: reg 10 32bit mmio: [0xd0004400-0xd00044ff]
[    0.908554] pci 0000:00:10.3: supports D1 D2
[    0.908557] pci 0000:00:10.3: PME# supported from D0 D1 D2 D3hot D3cold
[    0.908619] pci 0000:00:10.3: PME# disabled
[    0.908784] HPET not enabled in BIOS. You might try hpet=force boot option
[    0.908849] pci 0000:00:11.0: quirk: region 4000-407f claimed by vt8235 PM
[    0.908911] pci 0000:00:11.0: quirk: region 8100-810f claimed by vt8235 SMB
[    0.909087] pci 0000:00:11.1: reg 20 io port: [0x1c60-0x1c6f]
[    0.909198] pci 0000:00:11.5: reg 10 io port: [0x1400-0x14ff]
[    0.909255] pci 0000:00:11.5: supports D1 D2
[    0.909330] pci 0000:00:11.6: reg 10 io port: [0x1800-0x18ff]
[    0.909799] pci 0000:01:00.0: reg 10 32bit mmio: [0xf0000000-0xf3ffffff]
[    0.909808] pci 0000:01:00.0: reg 14 32bit mmio: [0xd1000000-0xd1ffffff]
[    0.909830] pci 0000:01:00.0: reg 30 32bit mmio: [0x000000-0x00ffff]
[    0.909853] pci 0000:01:00.0: supports D1 D2
[    0.909906] pci 0000:00:01.0: bridge 32bit mmio: [0xd1000000-0xd1ffffff]
[    0.909914] pci 0000:00:01.0: bridge 32bit mmio pref: [0xf0000000-0xf3ffffff]
[    0.909976] pci_bus 0000:00: on NUMA node 0
[    0.910028] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    1.134965] ACPI: PCI Interrupt Link [ALKA] (IRQs 16 17 18 19 20 21 22 23) *9, disabled.
[    1.136845] ACPI: PCI Interrupt Link [ALKB] (IRQs 16 17 18 19 20 21 22 23) *11, disabled.
[    1.138775] ACPI: PCI Interrupt Link [ALKC] (IRQs 22) *10, disabled.
[    1.140868] ACPI: PCI Interrupt Link [ALKD] (IRQs 21) *5, disabled.
[    1.143607] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 *9 12 14 15)
[    1.146550] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 10 12 14 15) *11
[    1.149806] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 11 12 14 15) *10
[    1.152679] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 *5 7 9 10 11 12 14 15)
[    1.157603] PCI: Using ACPI for IRQ routing
[    1.205075] pnp: PnP ACPI init
[    1.205278] ACPI: bus type pnp registered
[    1.279521] pnp: PnP ACPI: found 11 devices
[    1.279586] ACPI: ACPI bus type pnp unregistered
[    1.279797] system 00:05: iomem range 0x0-0x9ffff could not be reserved
[    1.279885] system 00:05: iomem range 0xe0000-0xfffff could not be reserved
[    1.279987] system 00:05: iomem range 0xfff00000-0xffffffff could not be reserved
[    1.280079] system 00:05: iomem range 0xffee0000-0xffefffff has been reserved
[    1.280167] system 00:05: iomem range 0xfec00000-0xfec00fff could not be reserved
[    1.280260] system 00:05: iomem range 0xfee00000-0xfee00fff has been reserved
[    1.280393] system 00:06: ioport range 0x4d0-0x4d1 has been reserved
[    1.280474] system 00:06: ioport range 0xfe10-0xfe11 has been reserved
[    1.280556] system 00:06: ioport range 0xfe00-0xfe00 has been reserved
[    1.280637] system 00:06: ioport range 0x4000-0x407f has been reserved
[    1.280725] system 00:06: ioport range 0x8100-0x811f could not be reserved
[    1.322090] pci 0000:01:00.0: BAR 6: can't allocate mem resource [0xf4000000-0xf3ffffff]
[    1.322173] pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
[    1.322231] pci 0000:00:01.0:   IO window: disabled
[    1.322293] pci 0000:00:01.0:   MEM window: 0xd1000000-0xd1ffffff
[    1.322355] pci 0000:00:01.0:   PREFETCH window: 0xf0000000-0xf3ffffff
[    1.322419] pci 0000:00:0c.0: CardBus bridge, secondary bus 0000:02
[    1.322478] pci 0000:00:0c.0:   IO window: 0x002000-0x0020ff
[    1.322540] pci 0000:00:0c.0:   IO window: 0x002400-0x0024ff
[    1.322601] pci 0000:00:0c.0:   PREFETCH window: 0x40000000-0x43ffffff
[    1.322664] pci 0000:00:0c.0:   MEM window: 0x44000000-0x47ffffff
[    1.322742] pci 0000:00:01.0: setting latency timer to 64
[    1.322753] pci 0000:00:0c.0: enabling device (0000 -> 0003)
[    1.322840] pci 0000:00:0c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.322906] pci 0000:00:0c.0: setting latency timer to 64
[    1.322913] pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
[    1.322917] pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffff]
[    1.322922] pci_bus 0000:01: resource 1 mem: [0xd1000000-0xd1ffffff]
[    1.322926] pci_bus 0000:01: resource 2 pref mem [0xf0000000-0xf3ffffff]
[    1.322930] pci_bus 0000:02: resource 0 io:  [0x2000-0x20ff]
[    1.322934] pci_bus 0000:02: resource 1 io:  [0x2400-0x24ff]
[    1.322938] pci_bus 0000:02: resource 2 pref mem [0x40000000-0x43ffffff]
[    1.322943] pci_bus 0000:02: resource 3 mem: [0x44000000-0x47ffffff]
[    1.323297] NET: Registered protocol family 2
[    1.323816] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
[    1.325181] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
[    1.327389] TCP bind hash table entries: 65536 (order: 9, 2097152 bytes)
[    1.333993] TCP: Hash tables configured (established 131072 bind 65536)
[    1.334111] TCP reno registered
[    1.334763] NET: Registered protocol family 1
[    1.346125] audit: initializing netlink socket (disabled)
[    1.346332] type=2000 audit(1261154986.345:1): initialized
[    1.350374] highmem bounce pool size: 64 pages
[    1.352397] msgmni has been set to 1737
[    1.353766] alg: No test for stdrng (krng)
[    1.353921] io scheduler noop registered
[    1.354116] io scheduler cfq registered (default)
[    1.354371] pci 0000:00:01.0: disabling DAC on VIA PCI bridge
[    1.354754] pci 0000:01:00.0: Boot video device
[    1.356870] isapnp: Scanning for PnP cards...
[    1.713776] isapnp: No Plug & Play device found
[    1.821964] Switched to high resolution mode on CPU 0
[    2.172108] Uniform Multi-Platform E-IDE driver
[    2.173717] via82cxxx 0000:00:11.1: VIA vt8235 (rev 00) IDE UDMA133
[    2.173791] via82cxxx 0000:00:11.1: IDE controller (0x1106:0x0571 rev 0x06)
[    2.174505] pci 0000:00:11.1: power state changed by ACPI to D0
[    2.175779] ACPI: PCI Interrupt Link [ALKA] disabled and referenced, BIOS bug
[    2.176923] ACPI: PCI Interrupt Link [ALKA] BIOS reported IRQ 0, using IRQ 23
[    2.176989] ACPI: PCI Interrupt Link [ALKA] enabled at IRQ 23
[    2.177087] pci 0000:00:11.1: PCI INT A -> Link[ALKA] -> GSI 23 (level, low) -> IRQ 23
[    2.177508] via82cxxx 0000:00:11.1: not 100% native mode: will probe irqs later
[    2.177584]     ide0: BM-DMA at 0x1c60-0x1c67
[    2.177660]     ide1: BM-DMA at 0x1c68-0x1c6f
[    2.177731] Probing IDE interface ide0...
[    2.441235] hda: SAMSUNG HM160HC, ATA DISK drive
[    3.054107] hda: host max PIO5 wanted PIO255(auto-tune) selected PIO4
[    3.054192] hda: UDMA/100 mode selected
[    3.054322] Probing IDE interface ide1...
[    3.726233] hdc: Optiarc DVD RW AD-7543A, ATAPI CD/DVD-ROM drive
[    4.338934] hdc: host max PIO5 wanted PIO255(auto-tune) selected PIO4
[    4.339093] hdc: UDMA/33 mode selected
[    4.339436] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[    4.401179] ide1 at 0x170-0x177,0x376 on irq 15
[    4.409075] ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
[    4.409615] ide-gd driver 1.18
[    4.410281] hda: max request size: 512KiB
[    4.412228] hda: Host Protected Area detected.
[    4.412230] 	current capacity is 268435456 sectors (137438 MB)
[    4.412232] 	native  capacity is 312581808 sectors (160041 MB)
[    4.412398] hda: 268435456 sectors (137438 MB) w/8192KiB Cache, CHS=16709/255/63
[    4.414145] hda: cache flushes supported
[    4.415173]  hda: hda1 hda2 hda3
[    4.426705] PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
[    4.430769] i8042.c: Detected active multiplexing controller, rev 1.1.
[    4.432415] serio: i8042 KBD port at 0x60,0x64 irq 1
[    4.432599] serio: i8042 AUX0 port at 0x60,0x64 irq 12
[    4.432685] serio: i8042 AUX1 port at 0x60,0x64 irq 12
[    4.432770] serio: i8042 AUX2 port at 0x60,0x64 irq 12
[    4.432854] serio: i8042 AUX3 port at 0x60,0x64 irq 12
[    4.435641] cpuidle: using governor ladder
[    4.435704] cpuidle: using governor menu
[    4.436596] TCP cubic registered
[    4.436659] NET: Registered protocol family 17
[    4.436872] Using IPI Shortcut mode
[    4.439626] PM: Resume from disk failed.
[    4.439962] kmemleak: Kernel memory leak detector initialized
[    4.441926] kmemleak: Automatic memory scanning thread started
[    4.458628] input: AT Translated Set 2 keyboard as /class/input/input0
[    4.483602] EXT3-fs: mounted filesystem with writeback data mode.
[    4.483841] VFS: Mounted root (ext3 filesystem) readonly on device 3:1.
[    4.484152] Freeing unused kernel memory: 364k freed
[    4.484800] Write protecting the kernel text: 2632k
[    4.484946] Write protecting the kernel read-only data: 980k
[    4.485805] kjournald starting.  Commit interval 5 seconds
[   12.074359] input: Power Button as /class/input/input1
[   12.075063] ACPI: Power Button [PWRF]
[   12.092354] ACPI: AC Adapter [AC] (on-line)
[   12.093488] input: Power Button as /class/input/input2
[   12.094211] ACPI: Power Button [PWB]
[   12.095200] input: Sleep Button as /class/input/input3
[   12.095857] ACPI: Sleep Button [SLPB]
[   12.096887] input: Lid Switch as /class/input/input4
[   12.121111] ACPI: Lid Switch [LID]
[   12.134756] Marking TSC unstable due to TSC halts in idle
[   12.136040] ACPI: CPU0 (power states: C1[C1] C2[C2])
[   12.137036] processor LNXCPU:00: registered as cooling_device0
[   12.152840] ACPI: Invalid active0 threshold
[   12.191417] thermal LNXTHERM:01: registered as thermal_zone0
[   12.191666] ACPI: Thermal Zone [THRM] (61 C)
[   12.668609] ACPI: Battery Slot [BAT0] (battery present)
[   12.752293] parport_pc 00:0a: reported by Plug and Play ACPI
[   12.752585] parport0: PC-style at 0x378 (0x778), irq 7, dma 1 [PCSPP,TRISTATE,COMPAT,ECP,DMA]
[   12.802068] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[   12.802898] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   12.955228] 00:09: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   13.002824] rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
[   13.002995] rtc0: alarms up to one year, y3k, 242 bytes nvram
[   13.137254] 8139too Fast Ethernet driver 0.9.28
[   13.137533] 8139too 0000:00:08.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
[   13.139842] eth0: RealTek RTL8139 at 0xf84ea000, 00:90:f5:3e:5a:ca, IRQ 19
[   13.355103] input: Video Bus as /class/input/input5
[   13.355866] ACPI: Video Device [VGA] (multi-head: yes  rom: no  post: no)
[   13.520925] usbcore: registered new interface driver usbfs
[   13.521417] usbcore: registered new interface driver hub
[   13.521869] usbcore: registered new device driver usb
[   13.710610] yenta_cardbus 0000:00:0c.0: CardBus bridge found [1558:4702]
[   13.710696] yenta_cardbus 0000:00:0c.0: Using CSCINT to route CSC interrupts to PCI
[   13.710767] yenta_cardbus 0000:00:0c.0: Routing CardBus interrupts to PCI
[   13.710831] yenta_cardbus 0000:00:0c.0: TI: mfunc 0x00001002, devctl 0x44
[   13.743020] input: PC Speaker as /class/input/input6
[   13.817304] uhci_hcd: USB Universal Host Controller Interface driver
[   13.833482] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   13.833550] Warning! ehci_hcd should always be loaded before uhci_hcd and ohci_hcd, not after
[   13.859252] ide-cd driver 5.00
[   13.860469] ide-cd: hdc: ATAPI 24X DVD-ROM DVD-R/RAM CD-R/RW drive, 2048kB Cache
[   13.861101] Uniform CD-ROM driver Revision: 3.20
[   13.935028] yenta_cardbus 0000:00:0c.0: ISA IRQ mask 0x0868, PCI irq 16
[   13.935094] yenta_cardbus 0000:00:0c.0: Socket status: 30000006
[   13.938383] ACPI: PCI Interrupt Link [ALKD] disabled and referenced, BIOS bug
[   13.939532] ACPI: PCI Interrupt Link [ALKD] BIOS reported IRQ 0, using IRQ 21
[   13.939600] ACPI: PCI Interrupt Link [ALKD] enabled at IRQ 21
[   13.939687] uhci_hcd 0000:00:10.0: PCI INT A -> Link[ALKD] -> GSI 21 (level, low) -> IRQ 21
[   13.939803] uhci_hcd 0000:00:10.0: UHCI Host Controller
[   13.941750] uhci_hcd 0000:00:10.0: new USB bus registered, assigned bus number 1
[   13.942066] uhci_hcd 0000:00:10.0: irq 21, io base 0x00001c00
[   13.945630] usb usb1: configuration #1 chosen from 1 choice
[   13.947535] hub 1-0:1.0: USB hub found
[   13.948133] hub 1-0:1.0: 2 ports detected
[   13.950746] ehci_hcd 0000:00:10.3: PCI INT D -> Link[ALKD] -> GSI 21 (level, low) -> IRQ 21
[   13.950918] ehci_hcd 0000:00:10.3: EHCI Host Controller
[   13.951153] ehci_hcd 0000:00:10.3: new USB bus registered, assigned bus number 2
[   13.951590] ehci_hcd 0000:00:10.3: irq 21, io mem 0xd0004400
[   13.957087] ehci_hcd 0000:00:10.3: USB 2.0 started, EHCI 1.00
[   13.959733] usb usb2: configuration #1 chosen from 1 choice
[   13.960959] hub 2-0:1.0: USB hub found
[   13.961225] hub 2-0:1.0: 6 ports detected
[   13.964705] uhci_hcd 0000:00:10.1: PCI INT B -> Link[ALKD] -> GSI 21 (level, low) -> IRQ 21
[   13.964826] uhci_hcd 0000:00:10.1: UHCI Host Controller
[   13.965164] uhci_hcd 0000:00:10.1: new USB bus registered, assigned bus number 3
[   13.965378] uhci_hcd 0000:00:10.1: irq 21, io base 0x00001c20
[   13.967969] usb usb3: configuration #1 chosen from 1 choice
[   13.969044] hub 3-0:1.0: USB hub found
[   13.969299] hub 3-0:1.0: 2 ports detected
[   13.970849] uhci_hcd 0000:00:10.2: PCI INT C -> Link[ALKD] -> GSI 21 (level, low) -> IRQ 21
[   13.970966] uhci_hcd 0000:00:10.2: UHCI Host Controller
[   13.971190] uhci_hcd 0000:00:10.2: new USB bus registered, assigned bus number 4
[   13.971383] uhci_hcd 0000:00:10.2: irq 21, io base 0x00001c40
[   13.973816] usb usb4: configuration #1 chosen from 1 choice
[   13.974871] hub 4-0:1.0: USB hub found
[   13.975158] hub 4-0:1.0: 2 ports detected
[   14.124529] input: PS/2 Mouse as /class/input/input7
[   14.142418] input: AlpsPS/2 ALPS GlidePoint as /class/input/input8
[   15.612603] mice: PS/2 mouse device common for all mice
[   15.818239] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x100-0x3af: clean.
[   15.823888] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x3e0-0x4ff: clean.
[   15.827372] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x820-0x8ff: clean.
[   15.829303] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xc00-0xcf7: clean.
[   15.832426] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xa00-0xaff: clean.
[   16.114597] VIA 82xx Audio 0000:00:11.5: power state changed by ACPI to D0
[   16.115827] ACPI: PCI Interrupt Link [ALKC] disabled and referenced, BIOS bug
[   16.116993] ACPI: PCI Interrupt Link [ALKC] BIOS reported IRQ 0, using IRQ 22
[   16.117689] ACPI: PCI Interrupt Link [ALKC] enabled at IRQ 22
[   16.117788] VIA 82xx Audio 0000:00:11.5: PCI INT C -> Link[ALKC] -> GSI 22 (level, low) -> IRQ 22
[   16.118305] VIA 82xx Audio 0000:00:11.5: setting latency timer to 64
[   16.661872] VIA 82xx Modem 0000:00:11.6: power state changed by ACPI to D0
[   16.661954] VIA 82xx Modem 0000:00:11.6: PCI INT C -> Link[ALKC] -> GSI 22 (level, low) -> IRQ 22
[   16.664119] VIA 82xx Modem 0000:00:11.6: setting latency timer to 64
[   18.899118] Adding 1951888k swap on /dev/hda2.  Priority:-1 extents:1 across:1951888k 
[   19.409004] EXT3 FS on hda1, internal journal
[   20.137918] leds_clevo_mail: 'Clevo D410J' found
[   20.138980] Registered led device: clevo::mail
[   20.530313] kjournald starting.  Commit interval 5 seconds
[   20.530437] EXT3-fs warning: maximal mount count reached, running e2fsck is recommended
[   20.530741] EXT3 FS on hda3, internal journal
[   20.530848] EXT3-fs: mounted filesystem with writeback data mode.
[   23.695732] eth0: link up, 100Mbps, full-duplex, lpa 0x41E1
[   25.797834] powernow-k8: Found 1 Mobile AMD Sempron(tm) Processor 2600+ processors (1 cpu cores) (version 2.20.00)
[   25.799867] powernow-k8:    0 : fid 0x8 (1600 MHz), vid 0x6
[   25.799873] powernow-k8:    1 : fid 0x0 (800 MHz), vid 0x18
[   25.800860] powernow-k8: ph2 null fid transition 0x8
[   27.790579] NET: Registered protocol family 10
[   29.321045] Clocksource tsc unstable (delta = -126469588 ns)
[   29.429803] lp0: using parport0 (interrupt-driven).
[   29.497457] ppdev: user-space parallel port driver
[   38.234029] eth0: no IPv6 routers present
[   43.194967] Linux agpgart interface v0.103
[   43.383072] powernow-k8: Hardware error - pending bit very stuck - no further pstate changes possible
[   43.383089] powernow-k8: transition frequency failed
[   43.402841] [drm] Initialized drm 1.1.0 20060810
[   43.468156] pci 0000:01:00.0: power state changed by ACPI to D0
[   43.468177] pci 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[   43.473668] [drm] Initialized via 2.11.1 20070202 for 0000:01:00.0 on minor 0
[   43.491079] powernow-k8: failing targ, change pending bit set
[   43.518726] [drm:via_initialize] *ERROR* called with no agp memory available
[   43.557054] powernow-k8: error - out of sync, fix 0x8 0x0, vid 0x6 0x6
[   54.930042] eth0: no IPv6 routers present
[  305.864919] eth0: link down
[  311.962145] eth0: link up, 100Mbps, full-duplex, lpa 0x41E1
[  311.962346] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  328.512062] eth0: no IPv6 routers present

--------------010204040003060804050201--
