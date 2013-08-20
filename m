From: Chris Clayton <chris2553@gmail.com>
Subject: Networking problem with 3.11-rc6+
Date: Tue, 20 Aug 2013 21:01:27 +0100
Message-ID: <5213CB17.5050308@googlemail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070809030403020905070809"
To: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070809030403020905070809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

I've just booted my laptop and found that networking was broken. Pings 
of other devices on my home network failed. A reboot has restored 
networking, but I thought I should report the problem anyway. I'll have 
no time tomorrow, but on Thursday I'll do a few boots to ascertain how 
repeatable the problem is.

Attached is a complete dmesg, but perhaps the most relevant part is:

[   65.181557] irq 17: nobody cared (try booting with the "irqpoll" option)
[   65.181566] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.11.0-rc6+ #124
[   65.181568] Hardware name: FUJITSU LIFEBOOK AH531/FJNBB0F, BIOS 1.30 
05/28/2012
[   65.181571]  00000011 c141bb51 f3154840 c108d581 c14e071c 00000011 
f3003950 00006650
[   65.181581]  f3154840 00000011 c108d8f0 1e35395f 00000011 c135453b 
00000000 00000000
[   65.181588]  00000000 00000011 00000000 c108bb0b 0e0e192a 75c91d86 
a880c0ad de2115ee
[   65.181597] Call Trace:
[   65.181608]  [<c141bb51>] ? dump_stack+0x48/0x76
[   65.181614]  [<c108d581>] ? __report_bad_irq+0x21/0xc0
[   65.181619]  [<c108d8f0>] ? note_interrupt+0xf0/0x1a0
[   65.181624]  [<c135453b>] ? cpuidle_enter_state+0x3b/0xc0
[   65.181632]  [<c108bb0b>] ? handle_irq_event_percpu+0x9b/0x120
[   65.181641]  [<c1029019>] ? __io_apic_modify_irq+0x39/0x40
[   65.181646]  [<c108bbb9>] ? handle_irq_event+0x29/0x40
[   65.181650]  [<c108e210>] ? unmask_irq+0x20/0x20
[   65.181654]  [<c108e256>] ? handle_fasteoi_irq+0x46/0xd0
[   65.181656]  <IRQ>  [<c1003981>] ? do_IRQ+0x31/0xa0
[   65.181667]  [<c1420fec>] ? common_interrupt+0x2c/0x31
[   65.181673]  [<c107007b>] ? kmsg_dump_rewind_nolock+0x2b/0x40
[   65.181678]  [<c135453b>] ? cpuidle_enter_state+0x3b/0xc0
[   65.181682]  [<c135463b>] ? cpuidle_idle_call+0x7b/0x110
[   65.181688]  [<c1009f85>] ? arch_cpu_idle+0x5/0x20
[   65.181692]  [<c10702be>] ? cpu_startup_entry+0xae/0xf0
[   65.181697]  [<c15ab961>] ? start_kernel+0x2a8/0x2ad
[   65.181702]  [<c15ab505>] ? repair_env_string+0x4d/0x4d
[   65.181704] handlers:
[   65.181715] [<f8e38000>] rtl8169_interrupt [r8169]
[   65.181717] Disabling IRQ #17


Let me know if I can provide any additional information, although to be 
honest, the boot completed and the KDE desktop started up OK, so there 
may not be much else I can provide unless I find that the problem is 
repeatable.

Chris

--------------070809030403020905070809
Content-Type: text/plain; charset=us-ascii;
 name="dmesg.full"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="dmesg.full"

[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.11.0-rc6+ (chris@laptop) (gcc version 4.8.2 20130815 (prerelease) (GCC) ) #124 SMP PREEMPT Tue Aug 20 10:54:09 BST 2013
[    0.000000] Disabled fast string operations
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009d7ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009d800-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000dab0efff] usable
[    0.000000] BIOS-e820: [mem 0x00000000dab0f000-0x00000000dad4efff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000dad4f000-0x00000000dad6efff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000dad6f000-0x00000000daf1efff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000daf1f000-0x00000000daf9efff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000daf9f000-0x00000000daffefff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000dafff000-0x00000000daffffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000db000000-0x00000000df9fffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000f8000000-0x00000000fbffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed10000-0x00000000fed19fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ffd80000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000021fdfffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.6 present.
[    0.000000] DMI: FUJITSU LIFEBOOK AH531/FJNBB0F, BIOS 1.30 05/28/2012
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0x21fe00 max_arch_pfn = 0x1000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0FFC00000 mask FFFC00000 write-protect
[    0.000000]   1 base 000000000 mask F80000000 write-back
[    0.000000]   2 base 080000000 mask FC0000000 write-back
[    0.000000]   3 base 0C0000000 mask FE0000000 write-back
[    0.000000]   4 base 0DC000000 mask FFC000000 uncachable
[    0.000000]   5 base 0DB000000 mask FFF000000 uncachable
[    0.000000]   6 base 100000000 mask F00000000 write-back
[    0.000000]   7 base 200000000 mask FE0000000 write-back
[    0.000000]   8 base 21FE00000 mask FFFE00000 uncachable
[    0.000000]   9 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] initial memory mapped: [mem 0x00000000-0x01bfffff]
[    0.000000] Base memory trampoline at [c0099000] 99000 size 16384
[    0.000000] reserving inaccessible SNB gfx pages
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x37800000-0x379fffff]
[    0.000000]  [mem 0x37800000-0x379fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x34000000-0x377fffff]
[    0.000000]  [mem 0x34000000-0x377fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x33ffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x33ffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x37a00000-0x37bfdfff]
[    0.000000]  [mem 0x37a00000-0x37bfdfff] page 4k
[    0.000000] BRK [0x01669000, 0x01669fff] PGTABLE
[    0.000000] ACPI: RSDP 000f00e0 00024 (v02 FUJ   )
[    0.000000] ACPI: XSDT daffe120 00084 (v01 FUJ    PC       00000001 FUJ  00000001)
[    0.000000] ACPI: FACP daff0000 000F4 (v03 FUJ    PC       00000001 PTL  00000001)
[    0.000000] ACPI: DSDT daff3000 0794A (v02 FUJ    FJNBB0F  00000000 INTL 20061109)
[    0.000000] ACPI: FACS daf3d000 00040
[    0.000000] ACPI: SLIC daffd000 00176 (v01 FUJ    PC       00000001 FUJ  00000001)
[    0.000000] ACPI: SSDT daffb000 01068 (v01 FUJ    PtidDevc 00001000 INTL 20061109)
[    0.000000] ACPI: ASF! daff2000 000A5 (v32 FUJ    PC       00000001 PTL  00000001)
[    0.000000] ACPI: HPET dafef000 00038 (v01 FUJ    PC       00000001 PTL  00000001)
[    0.000000] ACPI: APIC dafee000 00098 (v01 FUJ    PC       00000001 PTL  00000001)
[    0.000000] ACPI: MCFG dafed000 0003C (v01 FUJ    PC       00000001 PTL  00000001)
[    0.000000] ACPI: SSDT dafec000 007C2 (v01  PmRef  Cpu0Ist 00003000 INTL 20061109)
[    0.000000] ACPI: SSDT dafeb000 00996 (v01  PmRef    CpuPm 00003000 INTL 20061109)
[    0.000000] ACPI: UEFI dafea000 0003E (v01 FUJ    PC       00000001 PTL  00000001)
[    0.000000] ACPI: UEFI dafe9000 00042 (v01 PTL      COMBUF 00000001 PTL  00000001)
[    0.000000] ACPI: UEFI dafe8000 00242 (v01 FUJ    PC       00000001 PTL  00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 7810MB HIGHMEM available.
[    0.000000] 891MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 37bfe000
[    0.000000]   low ram: 0 - 37bfe000
[    0.000000] BRK [0x0166a000, 0x0166afff] PGTABLE
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x37bfdfff]
[    0.000000]   HighMem  [mem 0x37bfe000-0x1fdfffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009cfff]
[    0.000000]   node   0: [mem 0x00100000-0xdab0efff]
[    0.000000]   node   0: [mem 0xdafff000-0xdaffffff]
[    0.000000]   node   0: [mem 0x00000000-0x1fdfffff]
[    0.000000] On node 0 totalpages: 2074796
[    0.000000] free_area_init_node: node 0, pgdat c15a4e00, node_mem_map f37fe020
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3996 pages, LIFO batch:0
[    0.000000]   Normal zone: 1752 pages used for memmap
[    0.000000]   Normal zone: 224254 pages, LIFO batch:31
[    0.000000]   HighMem zone: 15621 pages used for memmap
[    0.000000]   HighMem zone: 1846546 pages, LIFO batch:31
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x00] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x00] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x00] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x00] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x0e] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 14, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a301 base: 0xfed00000
[    0.000000] smpboot: 8 Processors exceeds NR_CPUS limit of 4
[    0.000000] smpboot: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: [mem 0x0009d000-0x0009dfff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] e820: [mem 0xdfa00000-0xf7ffffff] available for PCI devices
[    0.000000] setup_percpu: NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Embedded 12 pages/cpu @f37bc000 s27008 r0 d22144 u49152
[    0.000000] pcpu-alloc: s27008 r0 d22144 u49152 alloc=12*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 2073012
[    0.000000] Kernel command line: root=/dev/sda5 pcie_ports=native ro resume=/dev/sda6
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
[    0.000000] Initializing HighMem for node 0 (00037bfe:0021fe00)
[    0.000000] Memory: 8221276K/8299184K available (4230K kernel code, 300K rwdata, 1264K rodata, 380K init, 304K bss, 77908K reserved, 7386180K highmem)
[    0.000000] virtual kernel memory layout:
    fixmap  : 0xfff66000 - 0xfffff000   ( 612 kB)
    pkmap   : 0xffc00000 - 0xffe00000   (2048 kB)
    vmalloc : 0xf83fe000 - 0xffbfe000   ( 120 MB)
    lowmem  : 0xc0000000 - 0xf7bfe000   ( 891 MB)
      .init : 0xc15ab000 - 0xc160a000   ( 380 kB)
      .data : 0xc1421d34 - 0xc15aa300   (1569 kB)
      .text : 0xc1000000 - 0xc1421d34   (4231 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] 	Dump stacks of tasks blocking RCU-preempt GP.
[    0.000000] NR_IRQS:2304 nr_irqs:712 16
[    0.000000] CPU 0 irqstacks, hard=f3008000 soft=f300a000
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.004000] tsc: Detected 2494.339 MHz processor
[    0.000001] Calibrating delay loop (skipped), value calculated using timer frequency.. 4988.67 BogoMIPS (lpj=9977356)
[    0.000116] pid_max: default: 32768 minimum: 301
[    0.000196] Mount-cache hash table entries: 512
[    0.000417] Disabled fast string operations
[    0.000472] CPU: Physical Processor ID: 0
[    0.000525] CPU: Processor Core ID: 0
[    0.000582] ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
ENERGY_PERF_BIAS: View and update with x86_energy_perf_policy(8)
[    0.000659] mce: CPU supports 7 MCE banks
[    0.000730] CPU0: Thermal monitoring enabled (TM1)
[    0.000797] Last level iTLB entries: 4KB 512, 2MB 0, 4MB 0
Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32
tlb_flushall_shift: 5
[    0.001011] Freeing SMP alternatives memory: 16K (c160a000 - c160e000)
[    0.001070] ACPI: Core revision 20130517
[    0.005644] ACPI: All ACPI Tables successfully acquired
[    0.006094] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.006562] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.046349] smpboot: CPU0: Intel(R) Core(TM) i5-2450M CPU @ 2.50GHz (fam: 06, model: 2a, stepping: 07)
[    0.046545] TSC deadline timer enabled
[    0.046553] Performance Events: PEBS fmt1+, 16-deep LBR, SandyBridge events, full-width counters, Intel PMU driver.
[    0.046828] perf_event_intel: PEBS disabled due to CPU errata, please upgrade microcode
[    0.046890] ... version:                3
[    0.046944] ... bit width:              48
[    0.046998] ... generic registers:      4
[    0.047053] ... value mask:             0000ffffffffffff
[    0.047110] ... max period:             0000ffffffffffff
[    0.047166] ... fixed-purpose events:   3
[    0.047221] ... event mask:             000000070000000f
[    0.070697] CPU 1 irqstacks, hard=f30b0000 soft=f30b2000
[    0.080949] Initializing CPU#1
[    0.081727] Disabled fast string operations
[    0.070698] smpboot: Booting Node   0, Processors  #1
[    0.091945] CPU 2 irqstacks, hard=f30c0000 soft=f30c2000
[    0.102396] Initializing CPU#2
[    0.103187] Disabled fast string operations
[    0.092105]  #2
[    0.113404] CPU 3 irqstacks, hard=f30cc000 soft=f30ce000
[    0.113563]  #3 OK
[    0.123865] Initializing CPU#3
[    0.124656] Disabled fast string operations
[    0.126772] Brought up 4 CPUs
[    0.126934] smpboot: Total of 4 processors activated (19954.71 BogoMIPS)
[    0.129602] devtmpfs: initialized
[    0.129859] PM: Registering ACPI NVS region [mem 0xdad4f000-0xdad6efff] (131072 bytes)
[    0.129924] PM: Registering ACPI NVS region [mem 0xdaf1f000-0xdaf9efff] (524288 bytes)
[    0.130052] NET: Registered protocol family 16
[    0.130238] ACPI: bus type PCI registered
[    0.130332] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.130407] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in E820
[    0.130465] PCI: Using MMCONFIG for extended config space
[    0.130522] PCI: Using configuration type 1 for base access
[    0.131696] bio: create slab <bio-0> at 0
[    0.131837] ACPI: Added _OSI(Module Device)
[    0.131893] ACPI: Added _OSI(Processor Device)
[    0.131948] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.132004] ACPI: Added _OSI(Processor Aggregator Device)
[    0.133268] ACPI: EC: Look up EC in DSDT
[    0.134513] ACPI: Executed 1 blocks of module-level executable AML code
[    0.146846] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.147274] ACPI: SSDT dad4d718 0067C (v01  PmRef  Cpu0Cst 00003001 INTL 20061109)
[    0.147721] ACPI: Dynamic OEM Table Load:
[    0.147855] ACPI: SSDT   (null) 0067C (v01  PmRef  Cpu0Cst 00003001 INTL 20061109)
[    0.159073] ACPI: SSDT daf0fa98 00303 (v01  PmRef    ApIst 00003000 INTL 20061109)
[    0.159545] ACPI: Dynamic OEM Table Load:
[    0.159677] ACPI: SSDT   (null) 00303 (v01  PmRef    ApIst 00003000 INTL 20061109)
[    0.170967] ACPI: SSDT dad4cd98 00119 (v01  PmRef    ApCst 00003000 INTL 20061109)
[    0.171403] ACPI: Dynamic OEM Table Load:
[    0.171536] ACPI: SSDT   (null) 00119 (v01  PmRef    ApCst 00003000 INTL 20061109)
[    0.183506] ACPI: Interpreter enabled
[    0.183567] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20130517/hwxface-571)
[    0.183722] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20130517/hwxface-571)
[    0.183884] ACPI: (supports S0 S3 S4 S5)
[    0.183939] ACPI: Using IOAPIC for interrupt routing
[    0.184017] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.184175] ACPI: No dock devices found.
[    0.189019] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3e])
[    0.189109] \_SB_.PCI0:_OSC invalid UUID
[    0.189110] _OSC request data:1 8 0 
[    0.189608] PCI host bridge to bus 0000:00
[    0.189666] pci_bus 0000:00: root bus resource [bus 00-3e]
[    0.189724] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.189783] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.189842] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    0.190445] pci_bus 0000:00: root bus resource [mem 0xdfa00000-0xfeafffff]
[    0.190505] pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfed44fff]
[    0.190571] pci 0000:00:00.0: [8086:0104] type 00 class 0x060000
[    0.190642] pci 0000:00:02.0: [8086:0126] type 00 class 0x030000
[    0.190652] pci 0000:00:02.0: reg 0x10: [mem 0xf0000000-0xf03fffff 64bit]
[    0.190658] pci 0000:00:02.0: reg 0x18: [mem 0xe0000000-0xefffffff 64bit pref]
[    0.190662] pci 0000:00:02.0: reg 0x20: [io  0x4000-0x403f]
[    0.190751] pci 0000:00:16.0: [8086:1c3a] type 00 class 0x078000
[    0.190773] pci 0000:00:16.0: reg 0x10: [mem 0xf1605000-0xf160500f 64bit]
[    0.190835] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
[    0.190914] pci 0000:00:1a.0: [8086:1c2d] type 00 class 0x0c0320
[    0.190935] pci 0000:00:1a.0: reg 0x10: [mem 0xf160a000-0xf160a3ff]
[    0.191007] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    0.191061] pci 0000:00:1a.0: System wakeup disabled by ACPI
[    0.191152] pci 0000:00:1b.0: [8086:1c20] type 00 class 0x040300
[    0.191168] pci 0000:00:1b.0: reg 0x10: [mem 0xf1600000-0xf1603fff 64bit]
[    0.191222] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.191289] pci 0000:00:1c.0: [8086:1c10] type 01 class 0x060400
[    0.191388] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.191470] pci 0000:00:1c.3: [8086:1c16] type 01 class 0x060400
[    0.191570] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
[    0.191620] pci 0000:00:1c.3: System wakeup disabled by ACPI
[    0.191706] pci 0000:00:1c.5: [8086:1c1a] type 01 class 0x060400
[    0.191767] pci 0000:00:1c.5: PME# supported from D0 D3hot D3cold
[    0.191812] pci 0000:00:1c.5: System wakeup disabled by ACPI
[    0.191903] pci 0000:00:1d.0: [8086:1c26] type 00 class 0x0c0320
[    0.191925] pci 0000:00:1d.0: reg 0x10: [mem 0xf1609000-0xf16093ff]
[    0.191997] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    0.192049] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    0.192136] pci 0000:00:1f.0: [8086:1c49] type 00 class 0x060100
[    0.192290] pci 0000:00:1f.2: [8086:1c03] type 00 class 0x010601
[    0.192308] pci 0000:00:1f.2: reg 0x10: [io  0x4088-0x408f]
[    0.192316] pci 0000:00:1f.2: reg 0x14: [io  0x4094-0x4097]
[    0.192324] pci 0000:00:1f.2: reg 0x18: [io  0x4080-0x4087]
[    0.192332] pci 0000:00:1f.2: reg 0x1c: [io  0x4090-0x4093]
[    0.192340] pci 0000:00:1f.2: reg 0x20: [io  0x4060-0x407f]
[    0.192348] pci 0000:00:1f.2: reg 0x24: [mem 0xf1608000-0xf16087ff]
[    0.192380] pci 0000:00:1f.2: PME# supported from D3hot
[    0.192440] pci 0000:00:1f.3: [8086:1c22] type 00 class 0x0c0500
[    0.192456] pci 0000:00:1f.3: reg 0x10: [mem 0xf1604000-0xf16040ff 64bit]
[    0.192477] pci 0000:00:1f.3: reg 0x20: [io  0xefa0-0xefbf]
[    0.192780] pci 0000:01:00.0: [8086:008a] type 00 class 0x028000
[    0.192944] pci 0000:01:00.0: reg 0x10: [mem 0xf1500000-0xf1501fff 64bit]
[    0.193504] pci 0000:01:00.0: PME# supported from D0 D3hot D3cold
[    0.193615] pci 0000:01:00.0: System wakeup disabled by ACPI
[    0.199033] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    0.199097] pci 0000:00:1c.0:   bridge window [mem 0xf1500000-0xf15fffff]
[    0.199185] pci 0000:00:1c.3: PCI bridge to [bus 02-06]
[    0.199246] pci 0000:00:1c.3:   bridge window [io  0x3000-0x3fff]
[    0.199251] pci 0000:00:1c.3:   bridge window [mem 0xf0d00000-0xf14fffff]
[    0.199258] pci 0000:00:1c.3:   bridge window [mem 0xf0400000-0xf0bfffff 64bit pref]
[    0.199335] pci 0000:07:00.0: [10ec:8168] type 00 class 0x020000
[    0.199356] pci 0000:07:00.0: reg 0x10: [io  0x2000-0x20ff]
[    0.199390] pci 0000:07:00.0: reg 0x18: [mem 0xf0c04000-0xf0c04fff 64bit pref]
[    0.199412] pci 0000:07:00.0: reg 0x20: [mem 0xf0c00000-0xf0c03fff 64bit pref]
[    0.199472] pci 0000:07:00.0: supports D1 D2
[    0.199473] pci 0000:07:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.199512] pci 0000:07:00.0: System wakeup disabled by ACPI
[    0.206941] pci 0000:00:1c.5: PCI bridge to [bus 07]
[    0.207027] pci 0000:00:1c.5:   bridge window [io  0x2000-0x2fff]
[    0.207034] pci 0000:00:1c.5:   bridge window [mem 0xf0c00000-0xf0cfffff 64bit pref]
[    0.207056] pci_bus 0000:00: on NUMA node 0
[    0.207090] \_SB_.PCI0:_OSC invalid UUID
[    0.207091] _OSC request data:1 f 0 
[    0.207094] acpi PNP0A08:00: ACPI _OSC support notification failed, disabling PCIe ASPM
[    0.207155] acpi PNP0A08:00: Unable to request _OSC control (_OSC support mask: 0x08)
[    0.207536] ACPI: PCI Interrupt Link [LNKA] (IRQs 1 3 4 5 6 10 *11 12 14 15)
[    0.208112] ACPI: PCI Interrupt Link [LNKB] (IRQs 1 3 4 5 6 10 *11 12 14 15)
[    0.208688] ACPI: PCI Interrupt Link [LNKC] (IRQs 1 3 4 5 6 *10 11 12 14 15)
[    0.209266] ACPI: PCI Interrupt Link [LNKD] (IRQs 1 3 4 5 6 10 *11 12 14 15)
[    0.209839] ACPI: PCI Interrupt Link [LNKE] (IRQs 1 3 4 5 6 10 11 12 14 15) *0, disabled.
[    0.210492] ACPI: PCI Interrupt Link [LNKF] (IRQs 1 3 4 5 6 10 11 12 14 15) *0, disabled.
[    0.211150] ACPI: PCI Interrupt Link [LNKG] (IRQs 1 3 4 5 6 *10 11 12 14 15)
[    0.211723] ACPI: PCI Interrupt Link [LNKH] (IRQs 1 3 4 5 6 *10 11 12 14 15)
[    0.212477] ACPI: Enabled 6 GPEs in block 00 to 3F
[    0.212616] ACPI: \_SB_.PCI0: notify handler is installed
[    0.212656] Found 1 acpi root devices
[    0.212682] ACPI: EC: GPE = 0x17, I/O: command/status = 0x66, data = 0x62
[    0.212789] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.212852] vgaarb: loaded
[    0.212904] vgaarb: bridge control possible 0000:00:02.0
[    0.213012] SCSI subsystem initialized
[    0.213066] ACPI: bus type ATA registered
[    0.213132] libata version 3.00 loaded.
[    0.213135] ACPI: bus type USB registered
[    0.213205] usbcore: registered new interface driver usbfs
[    0.213269] usbcore: registered new interface driver hub
[    0.213353] usbcore: registered new device driver usb
[    0.213428] Linux video capture interface: v2.00
[    0.213515] Advanced Linux Sound Architecture Driver Initialized.
[    0.213574] PCI: Using ACPI for IRQ routing
[    0.215269] PCI: pci_cache_line_size set to 64 bytes
[    0.215360] e820: reserve RAM buffer [mem 0x0009d800-0x0009ffff]
[    0.215362] e820: reserve RAM buffer [mem 0xdab0f000-0xdbffffff]
[    0.215363] e820: reserve RAM buffer [mem 0xdb000000-0xdbffffff]
[    0.215364] e820: reserve RAM buffer [mem 0x21fe00000-0x21fffffff]
[    0.215502] Switched to clocksource hpet
[    0.215591] pnp: PnP ACPI init
[    0.215648] ACPI: bus type PNP registered
[    0.215724] pnp 00:00: [dma 4]
[    0.215737] pnp 00:00: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.215752] pnp 00:01: Plug and Play ACPI device, IDs INT0800 (active)
[    0.215822] pnp 00:02: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.215844] pnp 00:03: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.215875] system 00:04: [io  0x0680-0x069f] has been reserved
[    0.215935] system 00:04: [io  0x1000-0x100f] has been reserved
[    0.215993] system 00:04: [io  0xffff] has been reserved
[    0.216051] system 00:04: [io  0xffff] has been reserved
[    0.216107] system 00:04: [io  0x0400-0x0453] could not be reserved
[    0.216165] system 00:04: [io  0x0458-0x047f] has been reserved
[    0.216223] system 00:04: [io  0x0500-0x057f] has been reserved
[    0.216281] system 00:04: [io  0x164e-0x164f] has been reserved
[    0.216339] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.216360] pnp 00:05: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.216396] system 00:06: [io  0x0454-0x0457] has been reserved
[    0.216456] system 00:06: Plug and Play ACPI device, IDs INT3f0d PNP0c02 (active)
[    0.216476] pnp 00:07: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.216495] pnp 00:08: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.216606] system 00:09: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    0.216667] system 00:09: [mem 0xfed10000-0xfed17fff] has been reserved
[    0.216728] system 00:09: [mem 0xfed18000-0xfed18fff] has been reserved
[    0.216788] system 00:09: [mem 0xfed19000-0xfed19fff] has been reserved
[    0.216848] system 00:09: [mem 0xf8000000-0xfbffffff] has been reserved
[    0.216909] system 00:09: [mem 0xfed20000-0xfed3ffff] has been reserved
[    0.216969] system 00:09: [mem 0xfed90000-0xfed93fff] has been reserved
[    0.217029] system 00:09: [mem 0xfed45000-0xfed8ffff] has been reserved
[    0.217089] system 00:09: [mem 0xff000000-0xffffffff] could not be reserved
[    0.217149] system 00:09: [mem 0xfee00000-0xfeefffff] could not be reserved
[    0.217210] system 00:09: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.217378] system 00:0a: [mem 0x20000000-0x201fffff] could not be reserved
[    0.217438] system 00:0a: [mem 0x40000000-0x401fffff] could not be reserved
[    0.217498] system 00:0a: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.217533] pnp: PnP ACPI: found 11 devices
[    0.217588] ACPI: bus type PNP unregistered
[    0.253439] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    0.253502] pci 0000:00:1c.0:   bridge window [mem 0xf1500000-0xf15fffff]
[    0.253572] pci 0000:00:1c.3: PCI bridge to [bus 02-06]
[    0.253631] pci 0000:00:1c.3:   bridge window [io  0x3000-0x3fff]
[    0.253693] pci 0000:00:1c.3:   bridge window [mem 0xf0d00000-0xf14fffff]
[    0.253757] pci 0000:00:1c.3:   bridge window [mem 0xf0400000-0xf0bfffff 64bit pref]
[    0.253825] pci 0000:00:1c.5: PCI bridge to [bus 07]
[    0.253882] pci 0000:00:1c.5:   bridge window [io  0x2000-0x2fff]
[    0.253946] pci 0000:00:1c.5:   bridge window [mem 0xf0c00000-0xf0cfffff 64bit pref]
[    0.254197] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.254198] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.254200] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.254201] pci_bus 0000:00: resource 7 [mem 0xdfa00000-0xfeafffff]
[    0.254202] pci_bus 0000:00: resource 8 [mem 0xfed40000-0xfed44fff]
[    0.254204] pci_bus 0000:01: resource 1 [mem 0xf1500000-0xf15fffff]
[    0.254205] pci_bus 0000:02: resource 0 [io  0x3000-0x3fff]
[    0.254206] pci_bus 0000:02: resource 1 [mem 0xf0d00000-0xf14fffff]
[    0.254208] pci_bus 0000:02: resource 2 [mem 0xf0400000-0xf0bfffff 64bit pref]
[    0.254209] pci_bus 0000:07: resource 0 [io  0x2000-0x2fff]
[    0.254211] pci_bus 0000:07: resource 2 [mem 0xf0c00000-0xf0cfffff 64bit pref]
[    0.254234] NET: Registered protocol family 2
[    0.254407] TCP established hash table entries: 8192 (order: 4, 65536 bytes)
[    0.254480] TCP bind hash table entries: 8192 (order: 4, 65536 bytes)
[    0.254550] TCP: Hash tables configured (established 8192 bind 8192)
[    0.254621] TCP: reno registered
[    0.254675] UDP hash table entries: 512 (order: 2, 16384 bytes)
[    0.254736] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
[    0.254830] NET: Registered protocol family 1
[    0.254893] pci 0000:00:02.0: Boot video device
[    0.255194] PCI: CLS 64 bytes, default 64
[    0.255372] microcode: CPU0 sig=0x206a7, pf=0x10, revision=0x26
[    0.255435] microcode: CPU1 sig=0x206a7, pf=0x10, revision=0x26
[    0.255501] microcode: CPU2 sig=0x206a7, pf=0x10, revision=0x26
[    0.255566] microcode: CPU3 sig=0x206a7, pf=0x10, revision=0x26
[    0.255652] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    0.256163] bounce pool size: 64 pages
[    0.257386] fuse init (API version 7.22)
[    0.257501] msgmni has been set to 1631
[    0.257882] io scheduler noop registered
[    0.257973] io scheduler cfq registered (default)
[    0.258272] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    0.258363] pciehp 0000:00:1c.3:pcie04: HPC vendor_id 8086 device_id 1c16 ss_vid 10cf ss_did 1610
[    0.258479] pciehp 0000:00:1c.3:pcie04: service driver pciehp loaded
[    0.258484] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    0.258553] intel_idle: MWAIT substates: 0x21120
[    0.258553] intel_idle: v0.4 model 0x2A
[    0.258554] intel_idle: lapic_timer_reliable_states 0xffffffff
[    0.258681] ACPI: AC Adapter [ACAD] (on-line)
[    0.258857] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
[    0.258921] ACPI: Power Button [PWRB]
[    0.259003] input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:00/input/input1
[    0.259076] ACPI: Lid Switch [LID]
[    0.259153] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input2
[    0.259215] ACPI: Power Button [PWRF]
[    0.259320] ACPI: Requesting acpi_cpufreq
[    0.259770] thermal LNXTHERM:00: registered as thermal_zone0
[    0.259829] ACPI: Thermal Zone [THRM] (36 C)
[    0.259896] isapnp: Scanning for PnP cards...
[    0.260425] ACPI: Battery Slot [BAT1] (battery present)
[    0.614328] isapnp: No Plug & Play device found
[    0.618914] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    0.619265] Linux agpgart interface v0.103
[    0.619342] [drm] Initialized drm 1.1.0 20060810
[    0.619799] [drm] Memory usable by graphics device = 2048M
[    0.619860] i915 0000:00:02.0: setting latency timer to 64
[    0.619935] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[    0.620006] [drm] Driver supports precise vblank timestamp query.
[    0.620116] vgaarb: device changed decodes: PCI:0000:00:02.0,olddecodes=io+mem,decodes=io+mem:owns=io+mem
[    0.641667] [drm] Wrong MCH_SSKPD value: 0x16040307
[    0.641726] [drm] This can cause pipe underruns and display issues.
[    0.641784] [drm] Please upgrade your BIOS to fix this.
[    0.658632] fbcon: inteldrmfb (fb0) is primary device
[    1.252698] tsc: Refined TSC clocksource calibration: 2494.333 MHz
[    1.817560] [drm] Enabling RC6 states: RC6 on, RC6p off, RC6pp off
[    1.871421] Console: switching to colour frame buffer device 170x48
[    1.874443] i915 0000:00:02.0: fb0: inteldrmfb frame buffer device
[    1.874466] i915 0000:00:02.0: registered panic notifier
[    1.890137] acpi device:32: registered as cooling_device4
[    1.890277] ACPI: Video Device [GFX0] (multi-head: yes  rom: no  post: no)
[    1.890330] input: Video Bus as /devices/LNXSYSTM:00/device:00/PNP0A08:00/LNXVIDEO:00/input/input3
[    1.890377] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on minor 0
[    1.890489] ahci 0000:00:1f.2: version 3.0
[    1.905458] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps 0x9 impl SATA mode
[    1.905491] ahci 0000:00:1f.2: flags: 64bit ncq sntf pm led clo pio slum part ems apst 
[    1.905526] ahci 0000:00:1f.2: setting latency timer to 64
[    1.913676] scsi0 : ahci
[    1.913735] scsi1 : ahci
[    1.913784] scsi2 : ahci
[    1.913833] scsi3 : ahci
[    1.913882] scsi4 : ahci
[    1.913931] scsi5 : ahci
[    1.913966] ata1: SATA max UDMA/133 abar m2048@0xf1608000 port 0xf1608100 irq 19
[    1.913995] ata2: DUMMY
[    1.914002] ata3: DUMMY
[    1.914012] ata4: SATA max UDMA/133 abar m2048@0xf1608000 port 0xf1608280 irq 19
[    1.914040] ata5: DUMMY
[    1.914048] ata6: DUMMY
[    1.914513] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.915040] ehci-pci: EHCI PCI platform driver
[    1.915601] ehci-pci 0000:00:1a.0: setting latency timer to 64
[    1.915607] ehci-pci 0000:00:1a.0: EHCI Host Controller
[    1.916113] ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus number 1
[    1.916649] ehci-pci 0000:00:1a.0: debug port 2
[    1.921073] ehci-pci 0000:00:1a.0: cache line size of 64 is not supported
[    1.921077] ehci-pci 0000:00:1a.0: irq 16, io mem 0xf160a000
[    1.933476] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[    1.934048] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    1.934634] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.935235] usb usb1: Product: EHCI Host Controller
[    1.935846] usb usb1: Manufacturer: Linux 3.11.0-rc6+ ehci_hcd
[    1.936474] usb usb1: SerialNumber: 0000:00:1a.0
[    1.937189] hub 1-0:1.0: USB hub found
[    1.937848] hub 1-0:1.0: 2 ports detected
[    1.938601] ehci-pci 0000:00:1d.0: setting latency timer to 64
[    1.938606] ehci-pci 0000:00:1d.0: EHCI Host Controller
[    1.939274] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    1.939973] ehci-pci 0000:00:1d.0: debug port 2
[    1.944568] ehci-pci 0000:00:1d.0: cache line size of 64 is not supported
[    1.944585] ehci-pci 0000:00:1d.0: irq 23, io mem 0xf1609000
[    1.953499] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[    1.954229] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    1.954978] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.955740] usb usb2: Product: EHCI Host Controller
[    1.956513] usb usb2: Manufacturer: Linux 3.11.0-rc6+ ehci_hcd
[    1.957302] usb usb2: SerialNumber: 0000:00:1d.0
[    1.958157] hub 2-0:1.0: USB hub found
[    1.958915] hub 2-0:1.0: 2 ports detected
[    1.959702] uhci_hcd: USB Universal Host Controller Interface driver
[    1.960487] usbcore: registered new interface driver usb-storage
[    1.961250] usbcore: registered new interface driver ums-realtek
[    1.962030] usbcore: registered new interface driver usbserial
[    1.962796] i8042: PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
[    1.969105] i8042: Detected active multiplexing controller, rev 1.1
[    1.972891] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.973638] serio: i8042 AUX0 port at 0x60,0x64 irq 12
[    1.974357] serio: i8042 AUX1 port at 0x60,0x64 irq 12
[    1.975061] serio: i8042 AUX2 port at 0x60,0x64 irq 12
[    1.975739] serio: i8042 AUX3 port at 0x60,0x64 irq 12
[    1.976466] mousedev: PS/2 mouse device common for all mice
[    1.977259] rtc_cmos 00:05: RTC can wake from S4
[    1.978068] rtc_cmos 00:05: rtc core: registered rtc_cmos as rtc0
[    1.978801] rtc_cmos 00:05: alarms up to one month, y3k, 242 bytes nvram, hpet irqs
[    1.979539] i2c /dev entries driver
[    1.980486] ACPI Warning: 0x0000efa0-0x0000efbf SystemIO conflicts with Region \_SB_.PCI0.SBUS.SMBI 1 (20130517/utaddress-251)
[    1.981258] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[    1.982091] IR NEC protocol handler initialized
[    1.982873] IR RC5(x) protocol handler initialized
[    1.983646] IR RC6 protocol handler initialized
[    1.984441] IR JVC protocol handler initialized
[    1.985206] IR Sony protocol handler initialized
[    1.985970] IR RC5 (streamzap) protocol handler initialized
[    1.986734] IR SANYO protocol handler initialized
[    1.987508] IR MCE Keyboard/mouse protocol handler initialized
[    1.988349] cpuidle: using governor ladder
[    1.989212] cpuidle: using governor menu
[    1.990148] usbcore: registered new interface driver usbhid
[    1.990912] usbhid: USB HID core driver
[    1.991786] ip_tables: (C) 2000-2006 Netfilter Core Team
[    1.992543] TCP: cubic registered
[    1.993310] NET: Registered protocol family 17
[    1.994083] NET: Registered protocol family 15
[    1.994949] Using IPI No-Shortcut mode
[    2.000976] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input4
[    2.233892] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    2.235247] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    2.239949] ata4.00: ATAPI: TSSTcorp CDDVDW SN-208AB, FC01, max UDMA/100
[    2.249823] ata4.00: configured for UDMA/100
[    2.249889] usb 1-1: new high-speed USB device number 2 using ehci-pci
[    2.254115] Switched to clocksource tsc
[    2.282274] ata1.00: ATA-8: TOSHIBA MK7575GSX, GT001A, max UDMA/100
[    2.283075] ata1.00: 1465149168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    2.284893] ata1.00: configured for UDMA/100
[    2.285862] scsi 0:0:0:0: Direct-Access     ATA      TOSHIBA MK7575GS GT00 PQ: 0 ANSI: 5
[    2.286836] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    2.286937] sd 0:0:0:0: [sda] 1465149168 512-byte logical blocks: (750 GB/698 GiB)
[    2.286938] sd 0:0:0:0: [sda] 4096-byte physical blocks
[    2.287045] sd 0:0:0:0: [sda] Write Protect is off
[    2.287047] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    2.287103] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    2.293574] scsi 3:0:0:0: CD-ROM            TSSTcorp CDDVDW SN-208AB  FC01 PQ: 0 ANSI: 5
[    2.300293] sr0: scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 cdda tray
[    2.301172] cdrom: Uniform CD-ROM driver Revision: 3.20
[    2.302109] sr 3:0:0:0: Attached scsi CD-ROM sr0
[    2.302150] sr 3:0:0:0: Attached scsi generic sg1 type 5
[    2.382364] usb 1-1: New USB device found, idVendor=8087, idProduct=0024
[    2.383270] usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    2.384388] hub 1-1:1.0: USB hub found
[    2.385490] hub 1-1:1.0: 6 ports detected
[    2.427919]  sda: sda1 sda2 sda3 < sda5 sda6 sda7 sda8 sda9 sda10 sda11 >
[    2.429227] sd 0:0:0:0: [sda] Attached SCSI disk
[    2.447578] registered taskstats version 1
[    2.448796] rtc_cmos 00:05: setting system clock to 2013-08-20 19:43:35 UTC (1377027815)
[    2.449772] ALSA device list:
[    2.450673]   No soundcards found.
[    2.484795] kjournald starting.  Commit interval 5 seconds
[    2.484826] EXT3-fs (sda5): mounted filesystem with writeback data mode
[    2.484833] VFS: Mounted root (ext3 filesystem) readonly on device 8:5.
[    2.498118] usb 2-1: new high-speed USB device number 2 using ehci-pci
[    2.513815] devtmpfs: mounted
[    2.514871] Freeing unused kernel memory: 380K (c15ab000 - c160a000)
[    2.630675] usb 2-1: New USB device found, idVendor=8087, idProduct=0024
[    2.631651] usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    2.633015] hub 2-1:1.0: USB hub found
[    2.634047] hub 2-1:1.0: 6 ports detected
[    2.706494] usb 1-1.3: new high-speed USB device number 3 using ehci-pci
[    2.832490] usb 1-1.3: New USB device found, idVendor=04f2, idProduct=b213
[    2.833490] usb 1-1.3: New USB device strings: Mfr=2, Product=1, SerialNumber=3
[    2.834444] usb 1-1.3: Product: FJ Camera
[    2.835399] usb 1-1.3: Manufacturer: Sonix Technology Co., Ltd.
[    2.836352] usb 1-1.3: SerialNumber: SN0001
[    2.910734] usb 2-1.2: new low-speed USB device number 3 using ehci-pci
[    3.007099] usb 2-1.2: New USB device found, idVendor=0461, idProduct=4d20
[    3.008083] usb 2-1.2: New USB device strings: Mfr=0, Product=2, SerialNumber=0
[    3.009034] usb 2-1.2: Product: USB Optical Mouse
[    3.012686] input: USB Optical Mouse as /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.2/2-1.2:1.0/input/input5
[    3.013836] hid-generic 0003:0461:4D20.0001: input: USB HID v1.11 Mouse [USB Optical Mouse] on usb-0000:00:1d.0-1.2/input0
[    3.086892] usb 2-1.6: new high-speed USB device number 4 using ehci-pci
[    3.191582] usb 2-1.6: New USB device found, idVendor=0bda, idProduct=0138
[    3.192633] usb 2-1.6: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    3.193660] usb 2-1.6: Product: USB2.0-CRW
[    3.194675] usb 2-1.6: Manufacturer: Generic
[    3.195665] usb 2-1.6: SerialNumber: 20090516388200000
[    3.202408] ums-realtek 2-1.6:1.0: USB Mass Storage device detected
[    3.221135] scsi6 : usb-storage 2-1.6:1.0
[    3.228410] usb 2-1.6: USB disconnect, device number 4
[    3.853975] EXT3-fs (sda5): using internal journal
[    4.732345] udevd[102]: starting version 182
[    5.110161] hda_codec: ALC269VB: SKU not ready 0x90970130
[    5.309757] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    5.311191] r8169 0000:07:00.0: can't disable ASPM; OS doesn't have ASPM control
[    5.312938] r8169 0000:07:00.0 eth0: RTL8168e/8111e at 0xf8e4a000, 5c:9a:d8:5c:63:31, XID 0c200000 IRQ 17
[    5.314458] r8169 0000:07:00.0 eth0: jumbo features [frames: 9200 bytes, tx checksumming: ko]
[    6.114114] r8169 0000:07:00.0 eth0: link down
[    6.115094] r8169 0000:07:00.0 eth0: link down
[    6.702165] uvcvideo: Found UVC 1.00 device FJ Camera (04f2:b213)
[    6.713420] usbcore: registered new interface driver uvcvideo
[    6.715011] USB Video Class driver (1.1.1)
[    7.646192] r8169 0000:07:00.0 eth0: link up
[    7.794911] microcode: CPU0 sig=0x206a7, pf=0x10, revision=0x26
[    7.799256] microcode: CPU0 updated to revision 0x28, date = 2012-04-24
[    7.802624] microcode: CPU1 sig=0x206a7, pf=0x10, revision=0x26
[    7.808121] microcode: CPU1 updated to revision 0x28, date = 2012-04-24
[    7.813188] microcode: CPU2 sig=0x206a7, pf=0x10, revision=0x26
[    7.816933] microcode: CPU2 updated to revision 0x28, date = 2012-04-24
[    7.820319] microcode: CPU3 sig=0x206a7, pf=0x10, revision=0x26
[    7.824046] microcode: CPU3 updated to revision 0x28, date = 2012-04-24
[    7.826882] perf_event_intel: PEBS enabled due to microcode update
[    8.314217] kjournald starting.  Commit interval 5 seconds
[    8.314522] EXT3-fs (sda8): using internal journal
[    8.314525] EXT3-fs (sda8): mounted filesystem with writeback data mode
[    8.343807] kjournald starting.  Commit interval 5 seconds
[    8.344147] EXT3-fs (sda9): using internal journal
[    8.344149] EXT3-fs (sda9): mounted filesystem with writeback data mode
[    8.370572] kjournald starting.  Commit interval 5 seconds
[    8.370931] EXT3-fs (sda10): using internal journal
[    8.370934] EXT3-fs (sda10): mounted filesystem with writeback data mode
[    8.457479] Adding 8191996k swap on /dev/sda6.  Priority:-1 extents:1 across:8191996k 
[   20.097770] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   65.181557] irq 17: nobody cared (try booting with the "irqpoll" option)
[   65.181566] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.11.0-rc6+ #124
[   65.181568] Hardware name: FUJITSU LIFEBOOK AH531/FJNBB0F, BIOS 1.30 05/28/2012
[   65.181571]  00000011 c141bb51 f3154840 c108d581 c14e071c 00000011 f3003950 00006650
[   65.181581]  f3154840 00000011 c108d8f0 1e35395f 00000011 c135453b 00000000 00000000
[   65.181588]  00000000 00000011 00000000 c108bb0b 0e0e192a 75c91d86 a880c0ad de2115ee
[   65.181597] Call Trace:
[   65.181608]  [<c141bb51>] ? dump_stack+0x48/0x76
[   65.181614]  [<c108d581>] ? __report_bad_irq+0x21/0xc0
[   65.181619]  [<c108d8f0>] ? note_interrupt+0xf0/0x1a0
[   65.181624]  [<c135453b>] ? cpuidle_enter_state+0x3b/0xc0
[   65.181632]  [<c108bb0b>] ? handle_irq_event_percpu+0x9b/0x120
[   65.181641]  [<c1029019>] ? __io_apic_modify_irq+0x39/0x40
[   65.181646]  [<c108bbb9>] ? handle_irq_event+0x29/0x40
[   65.181650]  [<c108e210>] ? unmask_irq+0x20/0x20
[   65.181654]  [<c108e256>] ? handle_fasteoi_irq+0x46/0xd0
[   65.181656]  <IRQ>  [<c1003981>] ? do_IRQ+0x31/0xa0
[   65.181667]  [<c1420fec>] ? common_interrupt+0x2c/0x31
[   65.181673]  [<c107007b>] ? kmsg_dump_rewind_nolock+0x2b/0x40
[   65.181678]  [<c135453b>] ? cpuidle_enter_state+0x3b/0xc0
[   65.181682]  [<c135463b>] ? cpuidle_idle_call+0x7b/0x110
[   65.181688]  [<c1009f85>] ? arch_cpu_idle+0x5/0x20
[   65.181692]  [<c10702be>] ? cpu_startup_entry+0xae/0xf0
[   65.181697]  [<c15ab961>] ? start_kernel+0x2a8/0x2ad
[   65.181702]  [<c15ab505>] ? repair_env_string+0x4d/0x4d
[   65.181704] handlers:
[   65.181715] [<f8e38000>] rtl8169_interrupt [r8169]
[   65.181717] Disabling IRQ #17
[  121.958582] ------------[ cut here ]------------
[  121.958600] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:260 dev_watchdog+0x1ea/0x200()
[  121.958603] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
[  121.958605] Modules linked in: iptable_filter xt_conntrack ipt_MASQUERADE iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_core r8169 acpi_cpufreq mperf freq_table mii snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep
[  121.958647] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.11.0-rc6+ #124
[  121.958650] Hardware name: FUJITSU LIFEBOOK AH531/FJNBB0F, BIOS 1.30 05/28/2012
[  121.958653]  00000009 c141bb51 c1561e98 c1037549 c152fc10 c1561eb0 00000000 c152cd52
[  121.958664]  00000104 c13adc3a c13adc3a ef92d000 ffff5200 00000000 000005dc c1037593
[  121.958673]  00000009 c1561e98 c152fc10 c1561eb0 c13adc3a c152cd52 00000104 c152fc10
[  121.958683] Call Trace:
[  121.958694]  [<c141bb51>] ? dump_stack+0x48/0x76
[  121.958703]  [<c1037549>] ? warn_slowpath_common+0x79/0x90
[  121.958709]  [<c13adc3a>] ? dev_watchdog+0x1ea/0x200
[  121.958713]  [<c13adc3a>] ? dev_watchdog+0x1ea/0x200
[  121.958719]  [<c1037593>] ? warn_slowpath_fmt+0x33/0x40
[  121.958724]  [<c13adc3a>] ? dev_watchdog+0x1ea/0x200
[  121.958730]  [<c13ada50>] ? dev_graft_qdisc+0x60/0x60
[  121.958735]  [<c13ada50>] ? dev_graft_qdisc+0x60/0x60
[  121.958742]  [<c10408f6>] ? call_timer_fn.isra.33+0x16/0x70
[  121.958747]  [<c1040425>] ? cascade+0x55/0x70
[  121.958753]  [<c1040a76>] ? run_timer_softirq+0x126/0x1b0
[  121.958761]  [<c103b163>] ? __do_softirq+0xa3/0x160
[  121.958768]  [<c103b326>] ? irq_exit+0x66/0x90
[  121.958776]  [<c1027455>] ? smp_apic_timer_interrupt+0x35/0x50
[  121.958782]  [<c14206c9>] ? apic_timer_interrupt+0x2d/0x34
[  121.958790]  [<c107007b>] ? kmsg_dump_rewind_nolock+0x2b/0x40
[  121.958797]  [<c135453b>] ? cpuidle_enter_state+0x3b/0xc0
[  121.958803]  [<c135463b>] ? cpuidle_idle_call+0x7b/0x110
[  121.958811]  [<c1009f85>] ? arch_cpu_idle+0x5/0x20
[  121.958817]  [<c10702be>] ? cpu_startup_entry+0xae/0xf0
[  121.958823]  [<c15ab961>] ? start_kernel+0x2a8/0x2ad
[  121.958830]  [<c15ab505>] ? repair_env_string+0x4d/0x4d
[  121.958833] ---[ end trace 7db96e0dbf14e47e ]---
[  121.980794] r8169 0000:07:00.0 eth0: rtl_chipcmd_cond == 1 (loop: 100, delay: 100).
[  121.982182] r8169 0000:07:00.0 eth0: rtl_csiar_cond == 1 (loop: 100, delay: 10).
[  121.983362] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  121.984542] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  121.985723] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  121.986903] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  121.988084] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  121.989264] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  121.990445] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  121.991625] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  121.992805] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  121.993987] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  121.995168] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  121.996348] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  121.997527] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  121.997582] r8169 0000:07:00.0 eth0: link up
[  182.049426] r8169 0000:07:00.0 eth0: rtl_chipcmd_cond == 1 (loop: 100, delay: 100).
[  182.050640] r8169 0000:07:00.0 eth0: rtl_csiar_cond == 1 (loop: 100, delay: 10).
[  182.051884] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  182.053078] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  182.054259] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  182.055448] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  182.056629] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  182.057809] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  182.058990] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  182.060181] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  182.061362] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  182.062541] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  182.063731] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  182.064912] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  182.066092] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  182.066146] r8169 0000:07:00.0 eth0: link up
[  212.083724] r8169 0000:07:00.0 eth0: rtl_chipcmd_cond == 1 (loop: 100, delay: 100).
[  212.084927] r8169 0000:07:00.0 eth0: rtl_csiar_cond == 1 (loop: 100, delay: 10).
[  212.086162] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  212.087359] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  212.088540] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  212.089728] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  212.090908] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  212.092088] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  212.093268] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  212.094460] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  212.095642] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  212.096823] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  212.098010] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  212.099191] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  212.100371] r8169 0000:07:00.0 eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
[  212.100424] r8169 0000:07:00.0 eth0: link up

--------------070809030403020905070809--
