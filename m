From: Denis Joseph Barrow <D.Barow@option.com>
Subject: possible problem with tg3.c not loading firmware
Date: Tue, 13 Jan 2009 15:03:57 +0100
Message-ID: <496C9F4D.7080101@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090003090202030406040800"
To: Linux netdev Mailing list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:24436 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754752AbZAMOEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 09:04:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090003090202030406040800
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,
I'm running ubuntu hardy heron 8.0.4.
my  Ethernet controller is a Broadcom Corporation NetXtreme BCM5788 Gigabit Ethernet (rev 03)

On linux-2.6.28-rc6 for the Tigon 3 driver there doesnt appear to be a seperate firmware file.
on linux-2.6.29-rc1 there is a tg3_tso5.bin.ihex.
There appears to be teething problems in getting the firmware file loaded on 2.6.29-rc1.

>From the dmesg attached the firmware doesn't appear to be loaded on first boot.
When I explicitly rmmod & modprobe the tg3 module it then works. 

-- 
best regards,
D.J. Barrow

Linux Kernel Developer
Option NV, Gaston Geenslaan 14, 3001 Leuven, Belgium
 
T: +32 16 311 621
F: +32 16 207 164
d.barow@option.com
www.option.com

Disclaimer:
http://www.option.com/company/disclaimer.shtml

--------------090003090202030406040800
Content-Type: text/plain;
 name="dmesg.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dmesg.log"

[    0.000000] Linux version 2.6.29-rc1 (djbarrow@djbarrow-laptop) (gcc version 4.2.3 (Ubuntu 4.2.3-2ubuntu7)) #1 SMP Tue Jan 13 13:41:56 CET 2009
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
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
[    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000003f7d0000 (usable)
[    0.000000]  BIOS-e820: 000000003f7d0000 - 000000003f7e5600 (reserved)
[    0.000000]  BIOS-e820: 000000003f7e5600 - 000000003f7f8000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000003f7f8000 - 000000003f800000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed20000 - 00000000fed9b000 (reserved)
[    0.000000]  BIOS-e820: 00000000feda0000 - 00000000fedc0000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000ffb00000 - 00000000ffc00000 (reserved)
[    0.000000]  BIOS-e820: 00000000fff00000 - 0000000100000000 (reserved)
[    0.000000] DMI 2.4 present.
[    0.000000] last_pfn = 0x3f7d0 max_arch_pfn = 0x100000
[    0.000000] kernel direct mapping tables up to 377fe000 @ 7000-d000
[    0.000000] RAMDISK: 34d5e000 - 37fefbac
[    0.000000] Allocated new RAMDISK: 005c5000 - 03856bac
[    0.000000] Move RAMDISK from 0000000034d5e000 - 0000000037fefbab to 005c5000 - 03856bab
[    0.000000] ACPI: RSDP 000F7D70, 0014 (r0 HP    )
[    0.000000] ACPI: RSDT 3F7E5684, 003C (r1 HP     30AA     28040620 HP          1)
[    0.000000] ACPI: FACP 3F7E5600, 0084 (r2 HP     30AA            2 HP          1)
[    0.000000] FADT: X_PM1a_EVT_BLK.bit_width (16) does not match PM1_EVT_LEN (4)
[    0.000000] ACPI: DSDT 3F7E5798, F360 (r1 HP       nc6340    10000 MSFT  100000E)
[    0.000000] ACPI: FACS 3F7F7E80, 0040
[    0.000000] ACPI: APIC 3F7E56C0, 0068 (r1 HP     30AA            1 HP          1)
[    0.000000] ACPI: MCFG 3F7E5728, 003C (r1 HP     30AA            1 HP          1)
[    0.000000] ACPI: TCPA 3F7E5764, 0032 (r2 HP     30AA            1 HP          1)
[    0.000000] ACPI: SSDT 3F7F4AF8, 033A (r1 HP       HPQPAT        1 MSFT  100000E)
[    0.000000] ACPI: SSDT 3F7F5305, 04E7 (r1 HP        CpuPm     3000 INTL 20050624)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 127MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 00000000 - 377fe000
[    0.000000]   bootmap 00009000 - 0000ff00
[    0.000000] (9 early reservations) ==> bootmem [0000000000 - 00377fe000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
[    0.000000]   #1 [0000001000 - 0000002000]    EX TRAMPOLINE ==> [0000001000 - 0000002000]
[    0.000000]   #2 [0000006000 - 0000007000]       TRAMPOLINE ==> [0000006000 - 0000007000]
[    0.000000]   #3 [0000100000 - 00005c1004]    TEXT DATA BSS ==> [0000100000 - 00005c1004]
[    0.000000]   #4 [00005c2000 - 00005c5000]    INIT_PG_TABLE ==> [00005c2000 - 00005c5000]
[    0.000000]   #5 [000009fc00 - 0000100000]    BIOS reserved ==> [000009fc00 - 0000100000]
[    0.000000]   #6 [0000007000 - 0000009000]          PGTABLE ==> [0000007000 - 0000009000]
[    0.000000]   #7 [00005c5000 - 0003856bac]      NEW RAMDISK ==> [00005c5000 - 0003856bac]
[    0.000000]   #8 [0000009000 - 0000010000]          BOOTMAP ==> [0000009000 - 0000010000]
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000000 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x000377fe
[    0.000000]   HighMem  0x000377fe -> 0x0003f7d0
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000000 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0003f7d0
[    0.000000] On node 0 totalpages: 259951
[    0.000000] free_area_init_node: node 0, pgdat c048c580, node_mem_map c3857000
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3967 pages, LIFO batch:0
[    0.000000]   Normal zone: 1744 pages used for memmap
[    0.000000]   Normal zone: 221486 pages, LIFO batch:31
[    0.000000]   HighMem zone: 256 pages used for memmap
[    0.000000]   HighMem zone: 32466 pages, LIFO batch:7
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] SMP: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
[    0.000000] PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
[    0.000000] Allocating PCI resources starting at 40000000 (gap: 3f800000:bf400000)
[    0.000000] NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:2 nr_node_ids:1
[    0.000000] PERCPU: Allocating 36864 bytes of per cpu data
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 257919
[    0.000000] Kernel command line: root=UUID=2803f4e0-67f7-4044-bba4-2eacabda4050 ro quiet splash  maxcpus=1 
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 4096 (order: 12, 16384 bytes)
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 1994.742 MHz processor.
[    0.004000] Console: colour VGA+ 80x25
[    0.004000] console [tty0] enabled
[    0.004000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.004000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.004000] Memory: 973696k/1040192k available (2411k kernel code, 65716k reserved, 1342k data, 436k init, 130888k highmem)
[    0.004000] virtual kernel memory layout:
[    0.004000]     fixmap  : 0xfff4f000 - 0xfffff000   ( 704 kB)
[    0.004000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.004000]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.004000]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.004000]       .init : 0xc04b1000 - 0xc051e000   ( 436 kB)
[    0.004000]       .data : 0xc035af96 - 0xc04aa814   (1342 kB)
[    0.004000]       .text : 0xc0100000 - 0xc035af96   (2411 kB)
[    0.004000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.004000] SLUB: Genslabs=12, HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
[    0.004009] Calibrating delay loop (skipped), value calculated using timer frequency.. 3989.48 BogoMIPS (lpj=7978968)
[    0.004027] Security Framework initialized
[    0.004034] SELinux:  Disabled at boot.
[    0.004043] Mount-cache hash table entries: 512
[    0.004172] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.004175] CPU: L2 cache: 2048K
[    0.004178] CPU: Physical Processor ID: 0
[    0.004179] CPU: Processor Core ID: 0
[    0.004183] using mwait in idle threads.
[    0.004190] Checking 'hlt' instruction... OK.
[    0.020409] SMP alternatives: switching to UP code
[    0.083742] ACPI: Core revision 20081204
[    0.104454] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.146935] CPU0: Genuine Intel(R) CPU           T2500  @ 2.00GHz stepping 08
[    0.148001] Brought up 1 CPUs
[    0.148001] Total of 1 processors activated (3989.48 BogoMIPS).
[    0.148001] CPU0 attaching NULL sched-domain.
[    0.148001] net_namespace: 1008 bytes
[    0.148001] HP Compaq Laptop series board detected. Selecting BIOS-method for reboots.
[    0.148001] Booting paravirtualized kernel on bare hardware
[    0.148001] NET: Registered protocol family 16
[    0.148001] EISA bus registered
[    0.148001] ACPI: bus type pci registered
[    0.148001] PCI: MCFG configuration 0: base f8000000 segment 0 buses 0 - 63
[    0.148001] PCI: Not using MMCONFIG.
[    0.148001] PCI: PCI BIOS revision 2.10 entry at 0xf0322, last bus=32
[    0.148001] PCI: Using configuration type 1 for base access
[    0.148001] bio: create slab <bio-0> at 0
[    0.148084] ACPI: EC: Look up EC in DSDT
[    0.151374] ACPI: EC: non-query interrupt received, switching to interrupt mode
[    0.200327] ACPI: Interpreter enabled
[    0.200333] ACPI: (supports S0 S3 S4 S5)
[    0.200347] ACPI: Using IOAPIC for interrupt routing
[    0.200412] PCI: MCFG configuration 0: base f8000000 segment 0 buses 0 - 63
[    0.211753] PCI: MCFG area at f8000000 reserved in ACPI motherboard resources
[    0.211756] PCI: Using MMCONFIG for extended config space
[    0.224428] ACPI: EC: GPE = 0x16, I/O: command/status = 0x66, data = 0x62
[    0.224430] ACPI: EC: driver started in interrupt mode
[    0.224650] ACPI: No dock devices found.
[    0.224660] ACPI: PCI Root Bridge [C002] (0000:00)
[    0.224759] pci 0000:00:02.0: reg 10 32bit mmio: [0xe8400000-0xe847ffff]
[    0.224764] pci 0000:00:02.0: reg 14 io port: [0x6000-0x6007]
[    0.224768] pci 0000:00:02.0: reg 18 32bit mmio: [0xd0000000-0xdfffffff]
[    0.224773] pci 0000:00:02.0: reg 1c 32bit mmio: [0xe8480000-0xe84bffff]
[    0.224809] pci 0000:00:02.1: reg 10 32bit mmio: [0xe8500000-0xe857ffff]
[    0.224920] pci 0000:00:1b.0: reg 10 64bit mmio: [0xe8580000-0xe8583fff]
[    0.224978] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.224984] pci 0000:00:1b.0: PME# disabled
[    0.225064] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.225068] pci 0000:00:1c.0: PME# disabled
[    0.225152] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    0.225157] pci 0000:00:1c.2: PME# disabled
[    0.225240] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
[    0.225245] pci 0000:00:1c.3: PME# disabled
[    0.225306] pci 0000:00:1d.0: reg 20 io port: [0x6020-0x603f]
[    0.225366] pci 0000:00:1d.1: reg 20 io port: [0x6040-0x605f]
[    0.225426] pci 0000:00:1d.2: reg 20 io port: [0x6060-0x607f]
[    0.225486] pci 0000:00:1d.3: reg 20 io port: [0x6080-0x609f]
[    0.225550] pci 0000:00:1d.7: reg 10 32bit mmio: [0xe8584000-0xe85843ff]
[    0.225611] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.225617] pci 0000:00:1d.7: PME# disabled
[    0.225785] pci 0000:00:1f.0: Force enabled HPET at 0xfed00000
[    0.225790] pci 0000:00:1f.0: quirk: region 1000-107f claimed by ICH6 ACPI/GPIO/TCO
[    0.225795] pci 0000:00:1f.0: quirk: region 1100-113f claimed by ICH6 GPIO
[    0.225799] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0500 (mask 007f)
[    0.225807] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 4 PIO at 0238 (mask 0007)
[    0.225869] pci 0000:00:1f.2: reg 10 io port: [0x00-0x07]
[    0.225877] pci 0000:00:1f.2: reg 14 io port: [0x00-0x03]
[    0.225884] pci 0000:00:1f.2: reg 18 io port: [0x00-0x07]
[    0.225892] pci 0000:00:1f.2: reg 1c io port: [0x00-0x03]
[    0.225899] pci 0000:00:1f.2: reg 20 io port: [0x60a0-0x60af]
[    0.225933] pci 0000:00:1f.2: PME# supported from D3hot
[    0.225937] pci 0000:00:1f.2: PME# disabled
[    0.226132] pci 0000:08:00.0: reg 10 32bit mmio: [0xe8000000-0xe8000fff]
[    0.226372] pci 0000:08:00.0: PME# supported from D0 D3hot D3cold
[    0.226385] pci 0000:08:00.0: PME# disabled
[    0.226492] pci 0000:00:1c.0: bridge 32bit mmio: [0xe8000000-0xe80fffff]
[    0.226552] pci 0000:00:1c.2: bridge io port: [0x4000-0x5fff]
[    0.226557] pci 0000:00:1c.2: bridge 32bit mmio: [0xe4000000-0xe7ffffff]
[    0.226616] pci 0000:00:1c.3: bridge io port: [0x2000-0x3fff]
[    0.226621] pci 0000:00:1c.3: bridge 32bit mmio: [0xe0000000-0xe3ffffff]
[    0.226687] pci 0000:02:06.0: reg 10 32bit mmio: [0xe8100000-0xe8100fff]
[    0.226716] pci 0000:02:06.0: supports D1 D2
[    0.226718] pci 0000:02:06.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.226723] pci 0000:02:06.0: PME# disabled
[    0.226775] pci 0000:02:06.1: reg 10 32bit mmio: [0xe8101000-0xe81017ff]
[    0.226785] pci 0000:02:06.1: reg 14 32bit mmio: [0xe8104000-0xe8107fff]
[    0.226851] pci 0000:02:06.1: supports D1 D2
[    0.226853] pci 0000:02:06.1: PME# supported from D0 D1 D2 D3hot
[    0.226858] pci 0000:02:06.1: PME# disabled
[    0.226909] pci 0000:02:06.2: reg 10 32bit mmio: [0xe8108000-0xe8108fff]
[    0.226981] pci 0000:02:06.2: supports D1 D2
[    0.226983] pci 0000:02:06.2: PME# supported from D0 D1 D2 D3hot
[    0.226989] pci 0000:02:06.2: PME# disabled
[    0.227041] pci 0000:02:06.3: reg 10 32bit mmio: [0xe8109000-0xe81090ff]
[    0.227114] pci 0000:02:06.3: supports D1 D2
[    0.227115] pci 0000:02:06.3: PME# supported from D0 D1 D2 D3hot
[    0.227121] pci 0000:02:06.3: PME# disabled
[    0.227218] pci 0000:02:0e.0: reg 10 32bit mmio: [0xe8110000-0xe811ffff]
[    0.227310] pci 0000:02:0e.0: PME# supported from D3hot D3cold
[    0.227316] pci 0000:02:0e.0: PME# disabled
[    0.227361] pci 0000:00:1e.0: transparent bridge
[    0.227368] pci 0000:00:1e.0: bridge 32bit mmio: [0xe8100000-0xe83fffff]
[    0.227421] pci_bus 0000:00: on NUMA node 0
[    0.227428] ACPI: PCI Interrupt Routing Table [\_SB_.C002._PRT]
[    0.227655] ACPI: PCI Interrupt Routing Table [\_SB_.C002.C092._PRT]
[    0.227759] ACPI: PCI Interrupt Routing Table [\_SB_.C002.C0FB._PRT]
[    0.227848] ACPI: PCI Interrupt Routing Table [\_SB_.C002.C10E._PRT]
[    0.227943] ACPI: PCI Interrupt Routing Table [\_SB_.C002.C111._PRT]
[    0.265317] ACPI: PCI Interrupt Link [C107] (IRQs 10 *11)
[    0.265557] ACPI: PCI Interrupt Link [C108] (IRQs 10 *11)
[    0.265794] ACPI: PCI Interrupt Link [C109] (IRQs *10 11)
[    0.266032] ACPI: PCI Interrupt Link [C10A] (IRQs *10 11)
[    0.266268] ACPI: PCI Interrupt Link [C123] (IRQs *10 11)
[    0.266502] ACPI: PCI Interrupt Link [C124] (IRQs 10 *11)
[    0.266738] ACPI: PCI Interrupt Link [C125] (IRQs *10 11)
[    0.266848] ACPI Exception (pci_link-0189): AE_NOT_FOUND, Evaluating _PRS [20081204]
[    0.267196] ACPI: Power Resource [C1E8] (on)
[    0.267388] ACPI: Power Resource [C1F5] (on)
[    0.267439] ACPI: Power Resource [C20B] (on)
[    0.267492] ACPI: Power Resource [C213] (off)
[    0.267601] ACPI: Power Resource [C308] (off)
[    0.267708] ACPI: Power Resource [C309] (off)
[    0.267815] ACPI: Power Resource [C30A] (off)
[    0.267920] ACPI: Power Resource [C30B] (off)
[    0.268305] PCI: Using ACPI for IRQ routing
[    0.268547] NET: Registered protocol family 8
[    0.268547] NET: Registered protocol family 20
[    0.268547] hpet clockevent registered
[    0.268547] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.268547] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.268547] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    0.272044] pnp: PnP ACPI init
[    0.272044] ACPI: bus type pnp registered
[    0.282860] pnp: PnP ACPI: found 14 devices
[    0.282862] ACPI: ACPI bus type pnp unregistered
[    0.282866] PnPBIOS: Disabled by ACPI PNP
[    0.282875] system 00:00: iomem range 0x0-0x9ffff could not be reserved
[    0.282878] system 00:00: iomem range 0xe0000-0xfffff could not be reserved
[    0.282881] system 00:00: iomem range 0x100000-0x3f7fffff could not be reserved
[    0.282890] system 00:0b: ioport range 0x500-0x55f has been reserved
[    0.282892] system 00:0b: ioport range 0x800-0x80f has been reserved
[    0.282895] system 00:0b: iomem range 0xffb00000-0xffbfffff has been reserved
[    0.282898] system 00:0b: iomem range 0xfff00000-0xffffffff has been reserved
[    0.282906] system 00:0c: ioport range 0x4d0-0x4d1 has been reserved
[    0.282908] system 00:0c: ioport range 0x1000-0x107f has been reserved
[    0.282911] system 00:0c: ioport range 0x1100-0x113f has been reserved
[    0.282913] system 00:0c: ioport range 0x1200-0x121f has been reserved
[    0.282916] system 00:0c: iomem range 0xf8000000-0xfbffffff has been reserved
[    0.282919] system 00:0c: iomem range 0xfec00000-0xfec000ff has been reserved
[    0.282922] system 00:0c: iomem range 0xfed20000-0xfed3ffff has been reserved
[    0.282924] system 00:0c: iomem range 0xfed45000-0xfed8ffff has been reserved
[    0.282927] system 00:0c: iomem range 0xfed90000-0xfed9afff has been reserved
[    0.282932] system 00:0d: iomem range 0xfeda0000-0xfedbffff has been reserved
[    0.282935] system 00:0d: iomem range 0xfee00000-0xfee00fff has been reserved
[    0.317825] pci 0000:00:1c.0: PCI bridge, secondary bus 0000:08
[    0.317828] pci 0000:00:1c.0:   IO window: disabled
[    0.317834] pci 0000:00:1c.0:   MEM window: 0xe8000000-0xe80fffff
[    0.317839] pci 0000:00:1c.0:   PREFETCH window: disabled
[    0.317846] pci 0000:00:1c.2: PCI bridge, secondary bus 0000:18
[    0.317850] pci 0000:00:1c.2:   IO window: 0x4000-0x5fff
[    0.317856] pci 0000:00:1c.2:   MEM window: 0xe4000000-0xe7ffffff
[    0.317860] pci 0000:00:1c.2:   PREFETCH window: disabled
[    0.317867] pci 0000:00:1c.3: PCI bridge, secondary bus 0000:20
[    0.317871] pci 0000:00:1c.3:   IO window: 0x2000-0x3fff
[    0.317877] pci 0000:00:1c.3:   MEM window: 0xe0000000-0xe3ffffff
[    0.317881] pci 0000:00:1c.3:   PREFETCH window: disabled
[    0.317891] pci 0000:02:06.0: CardBus bridge, secondary bus 0000:03
[    0.317893] pci 0000:02:06.0:   IO window: 0x007000-0x0070ff
[    0.317899] pci 0000:02:06.0:   IO window: 0x007400-0x0074ff
[    0.317904] pci 0000:02:06.0:   PREFETCH window: 0x40000000-0x43ffffff
[    0.317910] pci 0000:02:06.0:   MEM window: 0x44000000-0x47ffffff
[    0.317916] pci 0000:00:1e.0: PCI bridge, secondary bus 0000:02
[    0.317919] pci 0000:00:1e.0:   IO window: 0x7000-0x7fff
[    0.317925] pci 0000:00:1e.0:   MEM window: 0xe8100000-0xe83fffff
[    0.317930] pci 0000:00:1e.0:   PREFETCH window: 0x00000040000000-0x00000043ffffff
[    0.317944] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.317950] pci 0000:00:1c.0: setting latency timer to 64
[    0.317956] pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    0.317960] pci 0000:00:1c.2: setting latency timer to 64
[    0.317967] pci 0000:00:1c.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    0.317971] pci 0000:00:1c.3: setting latency timer to 64
[    0.317979] pci 0000:00:1e.0: setting latency timer to 64
[    0.317985] pci 0000:02:06.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[    0.317992] pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
[    0.317994] pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffff]
[    0.317996] pci_bus 0000:08: resource 0 mem: [0x0-0x0]
[    0.317998] pci_bus 0000:08: resource 1 mem: [0xe8000000-0xe80fffff]
[    0.318001] pci_bus 0000:08: resource 2 mem: [0x0-0x0]
[    0.318003] pci_bus 0000:08: resource 3 mem: [0x0-0x0]
[    0.318005] pci_bus 0000:18: resource 0 io:  [0x4000-0x5fff]
[    0.318007] pci_bus 0000:18: resource 1 mem: [0xe4000000-0xe7ffffff]
[    0.318009] pci_bus 0000:18: resource 2 mem: [0x0-0x0]
[    0.318011] pci_bus 0000:18: resource 3 mem: [0x0-0x0]
[    0.318013] pci_bus 0000:20: resource 0 io:  [0x2000-0x3fff]
[    0.318015] pci_bus 0000:20: resource 1 mem: [0xe0000000-0xe3ffffff]
[    0.318017] pci_bus 0000:20: resource 2 mem: [0x0-0x0]
[    0.318019] pci_bus 0000:20: resource 3 mem: [0x0-0x0]
[    0.318021] pci_bus 0000:02: resource 0 io:  [0x7000-0x7fff]
[    0.318024] pci_bus 0000:02: resource 1 mem: [0xe8100000-0xe83fffff]
[    0.318026] pci_bus 0000:02: resource 2 mem: [0x40000000-0x43ffffff]
[    0.318028] pci_bus 0000:02: resource 3 io:  [0x00-0xffff]
[    0.318030] pci_bus 0000:02: resource 4 mem: [0x000000-0xffffffff]
[    0.318033] pci_bus 0000:03: resource 0 io:  [0x7000-0x70ff]
[    0.318035] pci_bus 0000:03: resource 1 io:  [0x7400-0x74ff]
[    0.318037] pci_bus 0000:03: resource 2 mem: [0x40000000-0x43ffffff]
[    0.318039] pci_bus 0000:03: resource 3 mem: [0x44000000-0x47ffffff]
[    0.318064] NET: Registered protocol family 2
[    0.318214] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.318468] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.319145] TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
[    0.319481] TCP: Hash tables configured (established 131072 bind 65536)
[    0.319484] TCP reno registered
[    0.319586] NET: Registered protocol family 1
[    0.319702] checking if image is initramfs...<7>Switched to high resolution mode on CPU 0
[    2.336996]  it is
[    4.442692] Freeing initrd memory: 51782k freed
[    4.443359] audit: initializing netlink socket (disabled)
[    4.443376] type=2000 audit(1231857965.440:1): initialized
[    4.449977] highmem bounce pool size: 64 pages
[    4.451905] VFS: Disk quotas dquot_6.5.2
[    4.451982] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    4.452038] msgmni has been set to 1748
[    4.452194] alg: No test for stdrng (krng)
[    4.452205] io scheduler noop registered
[    4.452207] io scheduler anticipatory registered
[    4.452209] io scheduler deadline registered
[    4.452219] io scheduler cfq registered (default)
[    4.452232] pci 0000:00:02.0: Boot video device
[    4.452427] pcieport-driver 0000:00:1c.0: setting latency timer to 64
[    4.452507] pcieport-driver 0000:00:1c.0: irq 24 for MSI/MSI-X
[    4.452677] pcieport-driver 0000:00:1c.2: setting latency timer to 64
[    4.452751] pcieport-driver 0000:00:1c.2: irq 25 for MSI/MSI-X
[    4.452915] pcieport-driver 0000:00:1c.3: setting latency timer to 64
[    4.452988] pcieport-driver 0000:00:1c.3: irq 26 for MSI/MSI-X
[    4.453349] isapnp: Scanning for PnP cards...
[    4.807534] isapnp: No Plug & Play device found
[    4.832904] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    4.833066] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    4.833707] 00:02: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    4.835225] brd: module loaded
[    4.835287] input: Macintosh mouse button emulation as /class/input/input0
[    4.835305] Uniform Multi-Platform E-IDE driver
[    4.835376] ide-gd driver 1.18
[    4.835489] PNP: PS/2 Controller [PNP0303:C208,PNP0f13:C209] at 0x60,0x64 irq 1,12
[    4.837495] i8042.c: Detected active multiplexing controller, rev 1.1.
[    4.838199] serio: i8042 KBD port at 0x60,0x64 irq 1
[    4.838204] serio: i8042 AUX0 port at 0x60,0x64 irq 12
[    4.838206] serio: i8042 AUX1 port at 0x60,0x64 irq 12
[    4.838208] serio: i8042 AUX2 port at 0x60,0x64 irq 12
[    4.838210] serio: i8042 AUX3 port at 0x60,0x64 irq 12
[    4.838719] mice: PS/2 mouse device common for all mice
[    4.838827] EISA: Probing bus 0 at eisa.0
[    4.838835] Cannot allocate resource for EISA slot 1
[    4.838837] Cannot allocate resource for EISA slot 2
[    4.838839] Cannot allocate resource for EISA slot 3
[    4.838841] Cannot allocate resource for EISA slot 4
[    4.838843] Cannot allocate resource for EISA slot 5
[    4.838845] Cannot allocate resource for EISA slot 6
[    4.838847] Cannot allocate resource for EISA slot 7
[    4.838853] EISA: Detected 0 cards.
[    4.838856] cpuidle: using governor ladder
[    4.838858] cpuidle: using governor menu
[    4.839283] Using IPI No-Shortcut mode
[    4.839430] registered taskstats version 1
[    4.839551] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[    4.839553] EDD information not available.
[    4.839796] Freeing unused kernel memory: 436k freed
[    4.860846] input: AT Translated Set 2 keyboard as /class/input/input1
[    6.065416] fuse init (API version 7.11)
[    6.072831] fan PNP0C0B:00: registered as cooling_device0
[    6.072838] ACPI: Fan [C30C] (off)
[    6.073077] fan PNP0C0B:01: registered as cooling_device1
[    6.073082] ACPI: Fan [C30D] (off)
[    6.073324] fan PNP0C0B:02: registered as cooling_device2
[    6.073329] ACPI: Fan [C30E] (off)
[    6.073566] fan PNP0C0B:03: registered as cooling_device3
[    6.073571] ACPI: Fan [C30F] (off)
[    6.082648] ACPI: SSDT 3F7F4EBB, 01EA (r1 HP      Cpu0Ist     3000 INTL 20050624)
[    6.082995] ACPI: SSDT 3F7F512A, 01DB (r1 HP      Cpu0Cst     3001 INTL 20050624)
[    6.087181] ACPI: CPU0 (power states: C1[C1] C2[C2])
[    6.087222] processor ACPI_CPU:00: registered as cooling_device4
[    6.087225] ACPI: Processor [CPU0] (supports 8 throttling states)
[    6.087580] ACPI: SSDT 3F7F50A5, 0085 (r1 HP      Cpu1Cst     3000 INTL 20050624)
[    6.088157] tick-broadcast: ignoring broadcast for offline CPU #1
[    6.088269] ACPI: CPU1 (power states: C1[C1] C2[C2])
[    6.088308] processor ACPI_CPU:01: registered as cooling_device5
[    6.088312] ACPI: Processor [CPU1] (supports 8 throttling states)
[    6.092285] thermal LNXTHERM:01: registered as thermal_zone0
[    6.093852] Marking TSC unstable due to TSC halts in idle
[    6.096251] ACPI: Thermal Zone [TZ0] (59 C)
[    6.108198] thermal LNXTHERM:02: registered as thermal_zone1
[    6.116340] ACPI: Thermal Zone [TZ1] (55 C)
[    6.128376] thermal LNXTHERM:03: registered as thermal_zone2
[    6.136413] ACPI: Thermal Zone [TZ2] (47 C)
[    6.142375] thermal LNXTHERM:04: registered as thermal_zone3
[    6.152519] ACPI: Thermal Zone [TZ3] (28 C)
[    6.155789] thermal LNXTHERM:05: registered as thermal_zone4
[    6.161138] ACPI: Thermal Zone [TZ4] (20 C)
[    7.330139] usbcore: registered new interface driver usbfs
[    7.330165] usbcore: registered new interface driver hub
[    7.330190] usbcore: registered new device driver usb
[    7.346310] uhci_hcd: USB Universal Host Controller Interface driver
[    7.346364] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
[    7.346374] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    7.346378] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    7.346420] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 1
[    7.346459] uhci_hcd 0000:00:1d.0: irq 20, io base 0x00006020
[    7.346632] usb usb1: configuration #1 chosen from 1 choice
[    7.346658] hub 1-0:1.0: USB hub found
[    7.346664] hub 1-0:1.0: 2 ports detected
[    7.346774] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[    7.346781] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    7.346784] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    7.346803] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 2
[    7.346836] uhci_hcd 0000:00:1d.1: irq 21, io base 0x00006040
[    7.346915] usb usb2: configuration #1 chosen from 1 choice
[    7.346939] hub 2-0:1.0: USB hub found
[    7.346944] hub 2-0:1.0: 2 ports detected
[    7.347038] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    7.347044] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    7.347048] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    7.347068] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 3
[    7.347101] uhci_hcd 0000:00:1d.2: irq 18, io base 0x00006060
[    7.347182] usb usb3: configuration #1 chosen from 1 choice
[    7.347208] hub 3-0:1.0: USB hub found
[    7.347213] hub 3-0:1.0: 2 ports detected
[    7.347307] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    7.347314] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    7.347317] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    7.347335] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 4
[    7.347369] uhci_hcd 0000:00:1d.3: irq 19, io base 0x00006080
[    7.347449] usb usb4: configuration #1 chosen from 1 choice
[    7.347473] hub 4-0:1.0: USB hub found
[    7.347478] hub 4-0:1.0: 2 ports detected
[    7.366929] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    7.366933] Warning! ehci_hcd should always be loaded before uhci_hcd and ohci_hcd, not after
[    7.366962] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 20 (level, low) -> IRQ 20
[    7.367038] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    7.367042] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    7.367077] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 5
[    7.370999] ehci_hcd 0000:00:1d.7: debug port 1
[    7.371006] ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
[    7.371036] ehci_hcd 0000:00:1d.7: irq 20, io mem 0xe8584000
[    7.391362] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    7.391568] usb usb5: configuration #1 chosen from 1 choice
[    7.391596] hub 5-0:1.0: USB hub found
[    7.391607] hub 5-0:1.0: 8 ports detected
[    7.444664] SCSI subsystem initialized
[    7.527417] tg3.c:v3.97 (December 10, 2008)
[    7.527430] tg3 0000:02:0e.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    7.532063] tg3 0000:02:0e.0: PME# disabled
[    7.616094] libata version 3.00 loaded.
[    7.665808] ata_piix 0000:00:1f.2: version 2.12
[    7.665828] ata_piix 0000:00:1f.2: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    7.665834] ata_piix 0000:00:1f.2: MAP [ P0 P2 IDE IDE ]
[    7.665880] ata_piix 0000:00:1f.2: setting latency timer to 64
[    7.676322] scsi0 : ata_piix
[    7.694311] scsi1 : ata_piix
[    7.695019] ata1: SATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0x60a0 irq 14
[    7.695022] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x60a8 irq 15
[    7.700026] usb 5-1: new high speed USB device using ehci_hcd and address 2
[    7.700526] tg3 0000:02:0e.0: firmware: requesting tigon/tg3_tso5.bin
[    7.774468] tg3: Failed to load firmware "tigon/tg3_tso5.bin"
[    7.774490] tg3 0000:02:0e.0: PCI INT A disabled
[    7.774495] tg3: probe of 0000:02:0e.0 failed with error -2
[    7.774690] ohci1394 0000:02:06.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    7.828080] ohci1394: fw-host0: OHCI-1394 1.1 (PCI): IRQ=[19]  MMIO=[e8101000-e81017ff]  Max Packet=[2048]  IR/IT contexts=[4/8]
[    7.832517] usb 5-1: configuration #1 chosen from 1 choice
[    7.832669] hub 5-1:1.0: USB hub found
[    7.832714] hub 5-1:1.0: 3 ports detected
[    7.856370] ata1.00: ATA-7: FUJITSU MHV2100BH, 892C, max UDMA/100
[    7.856377] ata1.00: 195371568 sectors, multi 16: LBA48 
[    7.872409] ata1.00: configured for UDMA/100
[    7.872511] scsi 0:0:0:0: Direct-Access     ATA      FUJITSU MHV2100B 892C PQ: 0 ANSI: 5
[    7.944043] usb 5-4: new high speed USB device using ehci_hcd and address 3
[    8.036544] ata2.00: ATAPI: MATSHITADVD-RAM UJ-840S, 1.11, max MWDMA2
[    8.052455] ata2.00: configured for MWDMA2
[    8.054727] scsi 1:0:0:0: CD-ROM            MATSHITA DVD-RAM UJ-840S  1.11 PQ: 0 ANSI: 5
[    8.070991] Driver 'sd' needs updating - please use bus_type methods
[    8.071081] sd 0:0:0:0: [sda] 195371568 512-byte hardware sectors: (100 GB/93.1 GiB)
[    8.071095] sd 0:0:0:0: [sda] Write Protect is off
[    8.071097] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    8.071116] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    8.071171] sd 0:0:0:0: [sda] 195371568 512-byte hardware sectors: (100 GB/93.1 GiB)
[    8.071182] sd 0:0:0:0: [sda] Write Protect is off
[    8.071184] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    8.071203] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    8.071207]  sda:<4>Driver 'sr' needs updating - please use bus_type methods
[    8.079738] usb 5-4: configuration #1 chosen from 1 choice
[    8.089838]  sda1 sda2 < sda5 sda6 > sda3
[    8.133456] sd 0:0:0:0: [sda] Attached SCSI disk
[    8.139034] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    8.139069] sr 1:0:0:0: Attached scsi generic sg1 type 5
[    8.139619] ------------[ cut here ]------------
[    8.139622] WARNING: at drivers/ata/libata-sff.c:1017 ata_sff_hsm_move+0x4f4/0x860 [libata]()
[    8.139625] Hardware name: HP Compaq nc6320 (EY401ET#UUG)
[    8.139626] Modules linked in: sg sr_mod(+) cdrom sd_mod ata_generic pata_acpi ata_piix ohci1394 libata tg3 libphy ieee1394 scsi_mod ehci_hcd uhci_hcd usbcore thermal processor fan thermal_sys fuse
[    8.139641] Pid: 1380, comm: udevd Not tainted 2.6.29-rc1 #1
[    8.139643] Call Trace:
[    8.139651]  [<c012bda9>] warn_slowpath+0x99/0xc0
[    8.139655]  [<c019d807>] do_truncate+0x77/0x90
[    8.139660]  [<c0176b0b>] generic_file_aio_write+0x6b/0xe0
[    8.139675]  [<f811b3e5>] ata_sff_data_xfer32+0x85/0xe0 [libata]
[    8.139690]  [<f811a974>] ata_sff_hsm_move+0x4f4/0x860 [libata]
[    8.139704]  [<f811bdce>] ata_sff_interrupt+0x12e/0x1f0 [libata]
[    8.139709]  [<c0356335>] _spin_lock+0x5/0x10
[    8.139713]  [<c0167bf0>] handle_IRQ_event+0x30/0x60
[    8.139716]  [<c0169716>] handle_edge_irq+0xb6/0x120
[    8.139719]  [<c0104ea3>] do_IRQ+0x43/0x90
[    8.139722]  [<c019e0fc>] sys_close+0x6c/0xc0
[    8.139724]  [<c0103a27>] common_interrupt+0x27/0x30
[    8.139727] ---[ end trace bd6ccb16d781d807 ]---
[    8.143089] sr0: scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 cdda tray
[    8.143093] Uniform CD-ROM driver Revision: 3.20
[    8.143167] sr 1:0:0:0: Attached scsi CD-ROM sr0
[    8.176230] usb 5-1.1: new full speed USB device using ehci_hcd and address 4
[    8.294329] usb 5-1.1: configuration #1 chosen from 1 choice
[    8.380119] usb 5-1.2: new full speed USB device using ehci_hcd and address 5
[    8.452113] usb 5-1.2: device descriptor read/64, error -32
[    8.527748] PM: Starting manual resume from disk
[    8.527752] PM: Resume from partition 8:6
[    8.527753] PM: Checking hibernation image.
[    8.527988] PM: Resume from disk failed.
[    8.572875] kjournald starting.  Commit interval 5 seconds
[    8.572891] EXT3-fs: mounted filesystem with ordered data mode.
[    8.649207] usb 5-1.2: configuration #1 chosen from 1 choice
[   18.420567] Linux agpgart interface v0.103
[   18.474430] agpgart-intel 0000:00:00.0: Intel 945GM Chipset
[   18.474897] agpgart-intel 0000:00:00.0: detected 7932K stolen memory
[   18.477677] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xd0000000
[   18.569587] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   18.646249] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[   18.747667] input: Power Button (FF) as /class/input/input2
[   18.776157] ACPI: Power Button (FF) [PWRF]
[   18.776262] input: Sleep Button (CM) as /class/input/input3
[   18.808172] ACPI: Sleep Button (CM) [C231]
[   18.808539] ACPI: AC Adapter [C1B2] (on-line)
[   18.808609] input: Lid Switch as /class/input/input4
[   18.824178] ACPI: Lid Switch [C22A]
[   18.959849] ACPI: Battery Slot [C1B4] (battery present)
[   18.960085] ACPI: Battery Slot [C1B3] (battery absent)
[   20.161905] input: Video Bus as /class/input/input5
[   20.192172] ACPI: Video Device [C07F] (multi-head: yes  rom: no  post: no)
[   20.323714] tpm_inf_pnp 00:04: Found C1F7 with ID IFX0102
[   20.323769] tpm_inf_pnp 00:04: TPM found: config base 0x560, data base 0x570, chip version 0x000b, vendor id 0x15d1 (Infineon), product id 0x000b (SLB 9635 TT 1.2)
[   20.864161] parport_pc 00:03: reported by Plug and Play ACPI
[   20.864240] parport0: PC-style at 0x378 (0x778), irq 7, dma 1 [PCSPP,TRISTATE,COMPAT,ECP,DMA]
[   21.052047] intel_rng: FWH not detected
[   21.147685] iTCO_vendor_support: vendor-support=0
[   21.167403] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.04
[   21.167518] iTCO_wdt: Found a ICH7-M or ICH7-U TCO device (Version=2, TCOBASE=0x1060)
[   21.167662] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
[   21.785191] yenta_cardbus 0000:02:06.0: CardBus bridge found [103c:30aa]
[   21.785215] yenta_cardbus 0000:02:06.0: Enabling burst memory read transactions
[   21.785221] yenta_cardbus 0000:02:06.0: Using INTVAL to route CSC interrupts to PCI
[   21.785224] yenta_cardbus 0000:02:06.0: Routing CardBus interrupts to PCI
[   21.785230] yenta_cardbus 0000:02:06.0: TI: mfunc 0x01a61b22, devctl 0x64
[   22.016734] yenta_cardbus 0000:02:06.0: ISA IRQ mask 0x0c78, PCI irq 18
[   22.016739] yenta_cardbus 0000:02:06.0: Socket status: 30000006
[   22.016743] pci_bus 0000:02: Raising subordinate bus# of parent bus (#02) from #03 to #06
[   22.016751] yenta_cardbus 0000:02:06.0: pcmcia: parent PCI bridge I/O window: 0x7000 - 0x7fff
[   22.016754] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x7000-0x7fff: clean.
[   22.016972] yenta_cardbus 0000:02:06.0: pcmcia: parent PCI bridge Memory window: 0xe8100000 - 0xe83fffff
[   22.016975] yenta_cardbus 0000:02:06.0: pcmcia: parent PCI bridge Memory window: 0x40000000 - 0x43ffffff
[   22.063597] tifm_7xx1 0000:02:06.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[   22.370231] input: PC Speaker as /class/input/input6
[   22.847177] Synaptics Touchpad, model: 1, fw: 6.2, id: 0x25a0b1, caps: 0xa04793/0x300000
[   22.847183] serio: Synaptics pass-through port at isa0060/serio4/input0
[   22.886255] input: SynPS/2 Synaptics TouchPad as /class/input/input7
[   23.496147] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x100-0x3af: clean.
[   23.498251] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x3e0-0x4ff: clean.
[   23.499095] pcmcia_socket pcmcia_socket0: cs: IO port probe 0x820-0x8ff: clean.
[   23.499814] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xc00-0xcf7: clean.
[   23.500676] pcmcia_socket pcmcia_socket0: cs: IO port probe 0xa00-0xaff: clean.
[   24.229432] lp0: using parport0 (interrupt-driven).
[   24.318981] Adding 1325320k swap on /dev/sda6.  Priority:-1 extents:1 across:1325320k 
[   24.850261] EXT3 FS on sda5, internal journal
[   25.192850] device-mapper: uevent: version 1.0.3
[   25.193027] device-mapper: ioctl: 4.14.0-ioctl (2008-04-23) initialised: dm-devel@redhat.com
[   25.297028] aes_i586: Unknown symbol crypto_it_tab
[   25.297121] aes_i586: Unknown symbol crypto_aes_set_key
[   25.297270] aes_i586: Unknown symbol crypto_fl_tab
[   25.297362] aes_i586: Unknown symbol crypto_il_tab
[   25.297453] aes_i586: Unknown symbol crypto_ft_tab
[   25.330458] aes_i586: Unknown symbol crypto_it_tab
[   25.330551] aes_i586: Unknown symbol crypto_aes_set_key
[   25.330700] aes_i586: Unknown symbol crypto_fl_tab
[   25.330791] aes_i586: Unknown symbol crypto_il_tab
[   25.330882] aes_i586: Unknown symbol crypto_ft_tab
[   26.336872] kjournald starting.  Commit interval 5 seconds
[   26.337337] EXT3 FS on sda3, internal journal
[   26.337345] EXT3-fs: mounted filesystem with ordered data mode.
[   26.795061] ip_tables: (C) 2000-2006 Netfilter Core Team
[   28.668937] RPC: Registered udp transport module.
[   28.668941] RPC: Registered tcp transport module.
[   31.592948] NET: Registered protocol family 10
[   31.593386] lo: Disabled Privacy Extensions
[   31.792877] warning: `avahi-daemon' uses 32-bit capabilities (legacy support in use)
[   31.911731] apm: BIOS not found.
[   32.048465] ppdev: user-space parallel port driver
[   32.769625] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   32.978932] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[   32.989452] NFSD: starting 90-second grace period
[   34.474579] Bluetooth: Core ver 2.14
[   34.474659] NET: Registered protocol family 31
[   34.474663] Bluetooth: HCI device and connection manager initialized
[   34.474668] Bluetooth: HCI socket layer initialized
[   34.523530] Bluetooth: L2CAP ver 2.11
[   34.523535] Bluetooth: L2CAP socket layer initialized
[   34.636962] Bluetooth: RFCOMM socket layer initialized
[   34.636978] Bluetooth: RFCOMM TTY layer initialized
[   34.636981] Bluetooth: RFCOMM ver 1.10
[   38.528552] [drm] Initialized drm 1.1.0 20060810
[   38.932072] pci 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[   38.932081] pci 0000:00:02.0: setting latency timer to 64
[   38.935517] [drm] Initialized i915 1.6.0 20080730 on minor 0
[   39.994306] evdev.c(EVIOCGBIT): Suspicious buffer size 511, limiting output to 64 bytes. See http://userweb.kernel.org/~dtor/eviocgbit-bug.html
[   57.178469] [drm:i915_get_vblank_counter] *ERROR* trying to get vblank count for disabled pipe 0
[   63.982097] CPU0 attaching NULL sched-domain.
[   64.000064] CPU0 attaching NULL sched-domain.
[  111.760615] tg3.c:v3.97 (December 10, 2008)
[  111.760632] tg3 0000:02:0e.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[  111.768080] tg3 0000:02:0e.0: PME# disabled
[  111.801326] tg3 0000:02:0e.0: firmware: requesting tigon/tg3_tso5.bin
[  111.871531] eth0: Tigon3 [partno(BCM95788A50) rev 3003] (PCI:33MHz:32-bit) MAC address 00:15:60:cb:c0:d1
[  111.871539] eth0: attached PHY is 5705 (10/100/1000Base-T Ethernet) (WireSpeed[0])
[  111.871544] eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
[  111.871549] eth0: dma_rwctrl[763f0000] dma_mask[32-bit]
[  111.908996] tg3 0000:02:0e.0: PME# disabled
[  112.202902] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  115.479629] tg3: eth0: Link is up at 1000 Mbps, full duplex.
[  115.479635] tg3: eth0: Flow control is on for TX and on for RX.
[  115.480648] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  117.698244] NET: Registered protocol family 17
[  121.733390] Status code returned 0xc000006d NT_STATUS_LOGON_FAILURE
[  121.733403]  CIFS VFS: Send error in SessSetup = -13
[  121.733416]  CIFS VFS: cifs_mount failed w/return code = -13
[  121.775192] Status code returned 0xc000006d NT_STATUS_LOGON_FAILURE
[  121.775205]  CIFS VFS: Send error in SessSetup = -13
[  121.775218]  CIFS VFS: cifs_mount failed w/return code = -13
[  121.829106] Status code returned 0xc000006d NT_STATUS_LOGON_FAILURE
[  121.829120]  CIFS VFS: Send error in SessSetup = -13
[  121.829133]  CIFS VFS: cifs_mount failed w/return code = -13
[  121.854123] Status code returned 0xc000006d NT_STATUS_LOGON_FAILURE
[  121.854135]  CIFS VFS: Send error in SessSetup = -13
[  121.854147]  CIFS VFS: cifs_mount failed w/return code = -13
[  131.928023] eth0: no IPv6 routers present

--------------090003090202030406040800--
