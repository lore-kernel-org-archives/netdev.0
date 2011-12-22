From: Nico Schottelius <nico-linux-20111201@schottelius.org>
Subject: Re: BCM43224 hanging [3.2.0-rc5] (was: [3.2.0-rc4-00248-gb835c0f]
 ...)
Date: Thu, 22 Dec 2011 11:24:08 +0100
Message-ID: <20111222102408.GA2643@schottelius.org>
References: <20111201224851.GB20536@ethz.ch>
 <4ED8B610.2010703@broadcom.com>
 <20111202150128.GC3096@schottelius.org>
 <20111207190821.GA1775@schottelius.org>
 <20111212181619.GD1975@schottelius.org>
 <20111214112148.GE3191@ethz.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="NzB8fVQJ5HfG6fxh"
To: Nico Schottelius <nico-linux-20111201@schottelius.org>,
	Arend van Spriel <arend@broadcom.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	b43-dev@lists.infradead.org, Greg KH <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111214112148.GE3191@ethz.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Update:

- dmesg with hanging logs
- The hang problem seems to happen ONLY with a specific access point: c8:6c:87:a9:df:a9
  -> this is a zyxel P-2802HWL-I1, running at channel 13, with WPA2-PSK.
  -> If you need more information, just let me know
- Using wlan with the Samsung S2 as access point seems to work fine

So this is now a rather specific issue, but I guess others will run into
this sooner or later as well.

Attached dmesg with hanging processes including traceback.

Nico

-- 
PGP key: 7ED9 F7D3 6B10 81D7 0EC5  5C09 D7DC C8E4 3187 7DF0

--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="3.2.0-rc5.dmesg"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.2.0-rc5 (nico@brief) (gcc version 4.6.2 20111125 (prerelease) (GCC) ) #95 SMP PREEMPT Mon Dec 12 10:33:19 CET 2011
[    0.000000] Command line: root=/dev/mapper/root cryptdevice=/dev/sda5:root ro initrd=../initramfs-mbp.img BOOT_IMAGE=../vmlinuz-mbp 
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000008f000 (usable)
[    0.000000]  BIOS-e820: 000000000008f000 - 0000000000090000 (reserved)
[    0.000000]  BIOS-e820: 0000000000090000 - 000000000009fc00 (usable)
[    0.000000]  BIOS-e820: 000000000009fc00 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 0000000020000000 (usable)
[    0.000000]  BIOS-e820: 0000000020000000 - 0000000020200000 (reserved)
[    0.000000]  BIOS-e820: 0000000020200000 - 0000000040000000 (usable)
[    0.000000]  BIOS-e820: 0000000040000000 - 0000000040200000 (reserved)
[    0.000000]  BIOS-e820: 0000000040200000 - 000000008ad34000 (usable)
[    0.000000]  BIOS-e820: 000000008ad34000 - 000000008ad5f000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000008ad5f000 - 000000008afa2000 (ACPI data)
[    0.000000]  BIOS-e820: 000000008afa2000 - 000000008afff000 (reserved)
[    0.000000]  BIOS-e820: 000000008afff000 - 000000008b000000 (ACPI data)
[    0.000000]  BIOS-e820: 000000008b000000 - 000000008fa00000 (reserved)
[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed00000 - 00000000fed04000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed10000 - 00000000fed14000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed18000 - 00000000fed1a000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed1c000 - 00000000fed20000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000ff800000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 000000016fe00000 (usable)
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.4 present.
[    0.000000] DMI: Apple Inc. MacBookAir4,2/Mac-742912EFDBEE19B3, BIOS MBA41.88Z.0077.B0E.1110141154 10/14/2011
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
[    0.000000] No AGP bridge found
[    0.000000] last_pfn = 0x16fe00 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-DFFFF write-protect
[    0.000000]   E0000-FFFFF uncachable
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0C0000000 mask FC0000000 uncachable
[    0.000000]   1 base 0A0000000 mask FE0000000 uncachable
[    0.000000]   2 base 090000000 mask FF0000000 uncachable
[    0.000000]   3 base 08C000000 mask FFC000000 uncachable
[    0.000000]   4 base 08B800000 mask FFF800000 uncachable
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] last_pfn = 0x8ad34 max_arch_pfn = 0x400000000
[    0.000000] initial memory mapped : 0 - 20000000
[    0.000000] Base memory trampoline at [ffff88000009a000] 9a000 size 20480
[    0.000000] init_memory_mapping: 0000000000000000-000000008ad34000
[    0.000000]  0000000000 - 008ac00000 page 2M
[    0.000000]  008ac00000 - 008ad34000 page 4k
[    0.000000] kernel direct mapping tables up to 8ad34000 @ 1fcf5000-1fcfa000
[    0.000000] init_memory_mapping: 0000000100000000-000000016fe00000
[    0.000000]  0100000000 - 016fe00000 page 2M
[    0.000000] kernel direct mapping tables up to 16fe00000 @ 8ad2d000-8ad34000
[    0.000000] RAMDISK: 1fcfa000 - 1ffff000
[    0.000000] ACPI: RSDP 00000000000fe020 00024 (v02 APPLE )
[    0.000000] ACPI: XSDT 000000008ad8e1c0 000AC (v01 APPLE   Apple00 00000060      01000013)
[    0.000000] ACPI: FACP 000000008ad8c000 000F4 (v04 APPLE   Apple00 00000060 Loki 0000005F)
[    0.000000] ACPI: DSDT 000000008ad81000 05050 (v01 APPLE  MacBookA 00040001 INTL 20100915)
[    0.000000] ACPI: FACS 000000008ad3e000 00040
[    0.000000] ACPI: HPET 000000008ad8b000 00038 (v01 APPLE   Apple00 00000001 Loki 0000005F)
[    0.000000] ACPI: APIC 000000008ad8a000 000BC (v02 APPLE   Apple00 00000001 Loki 0000005F)
[    0.000000] ACPI: SBST 000000008ad88000 00030 (v01 APPLE   Apple00 00000001 Loki 0000005F)
[    0.000000] ACPI: ECDT 000000008ad87000 00053 (v01 APPLE   Apple00 00000001 Loki 0000005F)
[    0.000000] ACPI: SSDT 000000008ad7d000 00024 (v01 APPLE   SmcDppt 00001000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad7b000 006CA (v01 APPLE     UsbSD 00001000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad77000 00159 (v02 APPLE     IGHda 00001000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad73000 015EB (v02 APPLE  SsdtIGPU 00001000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad72000 00569 (v01  PmRef  Cpu0Ist 00003000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad71000 009B1 (v01  PmRef    CpuPm 00003000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad70000 00315 (v01  PmRef  Cpu0Tst 00003000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad6f000 0037A (v01  PmRef    ApTst 00003000 INTL 20100915)
[    0.000000] ACPI: MCFG 000000008ad89000 0003C (v01 APPLE   Apple00 00000001 Loki 0000005F)
[    0.000000] ACPI: SSDT 000000008ad80000 000FA (v01 SataRe  SataPri 00001000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad7f000 000D0 (v01 SataRe  SataSec 00001000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad7e000 00032 (v01  Apple   SsdtS3 00001000 INTL 20100915)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at 0000000000000000-000000016fe00000
[    0.000000] Initmem setup node 0 0000000000000000-000000016fe00000
[    0.000000]   NODE_DATA [000000016fdfb000 - 000000016fdfffff]
[    0.000000]  [ffffea0000000000-ffffea0005bfffff] PMD -> [ffff88016b400000-ffff88016f3fffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x0016fe00
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[6] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000008f
[    0.000000]     0: 0x00000090 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x00020000
[    0.000000]     0: 0x00020200 -> 0x00040000
[    0.000000]     0: 0x00040200 -> 0x0008ad34
[    0.000000]     0: 0x00100000 -> 0x0016fe00
[    0.000000] On node 0 totalpages: 1025730
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 5 pages reserved
[    0.000000]   DMA zone: 3913 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 16320 pages used for memmap
[    0.000000]   DMA32 zone: 547188 pages, LIFO batch:31
[    0.000000]   Normal zone: 7160 pages used for memmap
[    0.000000]   Normal zone: 451080 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x08] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] SMP: Allowing 8 CPUs, 4 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 000000000008f000 - 0000000000090000
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 0000000000100000
[    0.000000] PM: Registered nosave memory: 0000000020000000 - 0000000020200000
[    0.000000] PM: Registered nosave memory: 0000000040000000 - 0000000040200000
[    0.000000] PM: Registered nosave memory: 000000008ad34000 - 000000008ad5f000
[    0.000000] PM: Registered nosave memory: 000000008ad5f000 - 000000008afa2000
[    0.000000] PM: Registered nosave memory: 000000008afa2000 - 000000008afff000
[    0.000000] PM: Registered nosave memory: 000000008afff000 - 000000008b000000
[    0.000000] PM: Registered nosave memory: 000000008b000000 - 000000008fa00000
[    0.000000] PM: Registered nosave memory: 000000008fa00000 - 00000000e0000000
[    0.000000] PM: Registered nosave memory: 00000000e0000000 - 00000000f0000000
[    0.000000] PM: Registered nosave memory: 00000000f0000000 - 00000000fec00000
[    0.000000] PM: Registered nosave memory: 00000000fec00000 - 00000000fec01000
[    0.000000] PM: Registered nosave memory: 00000000fec01000 - 00000000fed00000
[    0.000000] PM: Registered nosave memory: 00000000fed00000 - 00000000fed04000
[    0.000000] PM: Registered nosave memory: 00000000fed04000 - 00000000fed10000
[    0.000000] PM: Registered nosave memory: 00000000fed10000 - 00000000fed14000
[    0.000000] PM: Registered nosave memory: 00000000fed14000 - 00000000fed18000
[    0.000000] PM: Registered nosave memory: 00000000fed18000 - 00000000fed1a000
[    0.000000] PM: Registered nosave memory: 00000000fed1a000 - 00000000fed1c000
[    0.000000] PM: Registered nosave memory: 00000000fed1c000 - 00000000fed20000
[    0.000000] PM: Registered nosave memory: 00000000fed20000 - 00000000fee00000
[    0.000000] PM: Registered nosave memory: 00000000fee00000 - 00000000fee01000
[    0.000000] PM: Registered nosave memory: 00000000fee01000 - 00000000ff800000
[    0.000000] PM: Registered nosave memory: 00000000ff800000 - 0000000100000000
[    0.000000] Allocating PCI resources starting at 8fa00000 (gap: 8fa00000:50600000)
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:8 nr_node_ids:1
[    0.000000] PERCPU: Embedded 28 pages/cpu @ffff88016fa00000 s83584 r8192 d22912 u262144
[    0.000000] pcpu-alloc: s83584 r8192 d22912 u262144 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 4 5 6 7 
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 1002181
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: root=/dev/mapper/root cryptdevice=/dev/sda5:root ro initrd=../initramfs-mbp.img BOOT_IMAGE=../vmlinuz-mbp 
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] xsave/xrstor: enabled xstate_bv 0x7, cntxt size 0x340
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 3947264k/6027264k available (4365k kernel code, 1924344k absent, 155656k reserved, 4581k data, 724k init)
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] 	Verbose stalled-CPUs detection is disabled.
[    0.000000] NR_IRQS:4352 nr_irqs:744 16
[    0.000000] Extended CMOS year: 2000
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
[    0.000000]  memory used by lock dependency info: 5855 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] allocated 33554432 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] hpet clockevent registered
[    0.000000] Fast TSC calibration using PIT
[    0.003333] Detected 1800.147 MHz processor.
[    0.000007] Calibrating delay loop (skipped), value calculated using timer frequency.. 3601.30 BogoMIPS (lpj=6000490)
[    0.000194] pid_max: default: 32768 minimum: 301
[    0.000423] Security Framework initialized
[    0.000516] AppArmor: AppArmor disabled by boot time parameter
[    0.001796] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.004589] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.005719] Mount-cache hash table entries: 256
[    0.007945] Initializing cgroup subsys cpuacct
[    0.008051] Initializing cgroup subsys memory
[    0.008227] Initializing cgroup subsys devices
[    0.008317] Initializing cgroup subsys freezer
[    0.008410] Initializing cgroup subsys net_cls
[    0.008499] Initializing cgroup subsys blkio
[    0.008760] CPU: Physical Processor ID: 0
[    0.008848] CPU: Processor Core ID: 0
[    0.008942] mce: CPU supports 7 MCE banks
[    0.009056] CPU0: Thermal monitoring enabled (TM1)
[    0.009177] using mwait in idle threads.
[    0.013239] ACPI: Core revision 20110623
[    0.060823] ftrace: allocating 16596 entries in 66 pages
[    0.079359] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.112417] CPU0: Intel(R) Core(TM) i7-2677M CPU @ 1.80GHz stepping 07
[    0.218890] Performance Events: PEBS fmt1+, SandyBridge events, Intel PMU driver.
[    0.219165] PEBS disabled due to CPU errata.
[    0.219268] ... version:                3
[    0.219354] ... bit width:              48
[    0.219439] ... generic registers:      4
[    0.219525] ... value mask:             0000ffffffffffff
[    0.219616] ... max period:             000000007fffffff
[    0.219705] ... fixed-purpose events:   3
[    0.219791] ... event mask:             000000070000000f
[    0.239299] NMI watchdog enabled, takes one hw-pmu counter.
[    0.258895] lockdep: fixing up alternatives.
[    0.265747] Booting Node   0, Processors  #1
[    0.265867] smpboot cpu 1: start_ip = 9a000
[    0.379009] NMI watchdog enabled, takes one hw-pmu counter.
[    0.398636] lockdep: fixing up alternatives.
[    0.398790]  #2
[    0.398849] smpboot cpu 2: start_ip = 9a000
[    0.512033] NMI watchdog enabled, takes one hw-pmu counter.
[    0.531759] lockdep: fixing up alternatives.
[    0.531910]  #3
[    0.531972] smpboot cpu 3: start_ip = 9a000
[    0.645098] NMI watchdog enabled, takes one hw-pmu counter.
[    0.651558] Brought up 4 CPUs
[    0.651643] Total of 4 processors activated (14406.28 BogoMIPS).
[    0.663818] devtmpfs: initialized
[    0.667196] PM: Registering ACPI NVS region at 8ad34000 (176128 bytes)
[    0.670515] print_constraints: dummy: 
[    0.671124] NET: Registered protocol family 16
[    0.671873] ACPI: bus type pci registered
[    0.672283] PCI: MMCONFIG for domain 0000 [bus 00-97] at [mem 0xe0000000-0xe97fffff] (base 0xe0000000)
[    0.672413] PCI: MMCONFIG at [mem 0xe0000000-0xe97fffff] reserved in E820
[    0.806472] PCI: Using configuration type 1 for base access
[    0.809289] bio: create slab <bio-0> at 0
[    0.809666] ACPI: Added _OSI(Module Device)
[    0.809756] ACPI: Added _OSI(Processor Device)
[    0.809843] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.809934] ACPI: Added _OSI(Processor Aggregator Device)
[    0.823087] ACPI: EC: EC description table is found, configuring boot EC
[    0.855095] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.857029] ACPI: SSDT 000000008ad39190 00781 (v01  PmRef  Cpu0Cst 00003001 INTL 20100915)
[    0.860809] ACPI: Dynamic OEM Table Load:
[    0.860999] ACPI: SSDT           (null) 00781 (v01  PmRef  Cpu0Cst 00003001 INTL 20100915)
[    0.872190] ACPI: SSDT 000000008ad3a710 003A4 (v01  PmRef    ApIst 00003000 INTL 20100915)
[    0.876174] ACPI: Dynamic OEM Table Load:
[    0.876363] ACPI: SSDT           (null) 003A4 (v01  PmRef    ApIst 00003000 INTL 20100915)
[    0.888188] ACPI: SSDT 000000008ad38d90 00119 (v01  PmRef    ApCst 00003000 INTL 20100915)
[    0.891975] ACPI: Dynamic OEM Table Load:
[    0.892164] ACPI: SSDT           (null) 00119 (v01  PmRef    ApCst 00003000 INTL 20100915)
[    0.906644] ACPI: Interpreter enabled
[    0.906734] ACPI: (supports S0 S3 S4 S5)
[    0.907123] ACPI: Using IOAPIC for interrupt routing
[    0.946116] ACPI: EC: GPE = 0x17, I/O: command/status = 0x66, data = 0x62
[    0.947232] ACPI: No dock devices found.
[    0.947319] HEST: Table not found.
[    0.947406] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.949055] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.951516] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
[    0.951618] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
[    0.951715] pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
[    0.951836] pci_root PNP0A08:00: host bridge window [mem 0x8fa00000-0xfeafffff]
[    0.951955] pci_root PNP0A08:00: host bridge window [mem 0xfed40000-0xfed44fff]
[    0.952152] pci 0000:00:00.0: [8086:0104] type 0 class 0x000600
[    0.952359] pci 0000:00:01.0: [8086:0101] type 1 class 0x000604
[    0.952479] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    0.952547] pci 0000:00:01.0: PME# disabled
[    0.952626] pci 0000:00:02.0: [8086:0116] type 0 class 0x000300
[    0.952674] pci 0000:00:02.0: reg 10: [mem 0xa0000000-0xa03fffff 64bit]
[    0.952701] pci 0000:00:02.0: reg 18: [mem 0x90000000-0x9fffffff 64bit pref]
[    0.952721] pci 0000:00:02.0: reg 20: [io  0x2000-0x203f]
[    0.952922] pci 0000:00:16.0: [8086:1c3a] type 0 class 0x000780
[    0.952990] pci 0000:00:16.0: reg 10: [mem 0xa0607100-0xa060710f 64bit]
[    0.953170] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
[    0.953182] pci 0000:00:16.0: PME# disabled
[    0.953270] pci 0000:00:1a.0: [8086:1c2c] type 0 class 0x000c03
[    0.953407] pci 0000:00:1a.0: reg 20: [io  0x2140-0x215f]
[    0.953580] pci 0000:00:1a.7: [8086:1c2d] type 0 class 0x000c03
[    0.953640] pci 0000:00:1a.7: reg 10: [mem 0xa0606c00-0xa0606fff]
[    0.953854] pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
[    0.953866] pci 0000:00:1a.7: PME# disabled
[    0.953939] pci 0000:00:1b.0: [8086:1c20] type 0 class 0x000403
[    0.953989] pci 0000:00:1b.0: reg 10: [mem 0xa0600000-0xa0603fff 64bit]
[    0.954178] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.954190] pci 0000:00:1b.0: PME# disabled
[    0.954256] pci 0000:00:1c.0: [8086:1c10] type 1 class 0x000604
[    0.954472] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.954485] pci 0000:00:1c.0: PME# disabled
[    0.954562] pci 0000:00:1c.1: [8086:1c12] type 1 class 0x000604
[    0.954768] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.954781] pci 0000:00:1c.1: PME# disabled
[    0.954872] pci 0000:00:1d.0: [8086:1c27] type 0 class 0x000c03
[    0.955010] pci 0000:00:1d.0: reg 20: [io  0x20e0-0x20ff]
[    0.955188] pci 0000:00:1d.7: [8086:1c26] type 0 class 0x000c03
[    0.955248] pci 0000:00:1d.7: reg 10: [mem 0xa0606800-0xa0606bff]
[    0.955462] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.955474] pci 0000:00:1d.7: PME# disabled
[    0.955537] pci 0000:00:1f.0: [8086:1c4d] type 0 class 0x000601
[    0.955828] pci 0000:00:1f.2: [8086:1c01] type 0 class 0x000101
[    0.955881] pci 0000:00:1f.2: reg 10: [io  0x2168-0x216f]
[    0.955908] pci 0000:00:1f.2: reg 14: [io  0x217c-0x217f]
[    0.955936] pci 0000:00:1f.2: reg 18: [io  0x2160-0x2167]
[    0.955964] pci 0000:00:1f.2: reg 1c: [io  0x2178-0x217b]
[    0.955991] pci 0000:00:1f.2: reg 20: [io  0x2060-0x206f]
[    0.956019] pci 0000:00:1f.2: reg 24: [io  0xffe0-0xffef]
[    0.956150] pci 0000:00:1f.3: [8086:1c22] type 0 class 0x000c05
[    0.956200] pci 0000:00:1f.3: reg 10: [mem 0xa0607000-0xa06070ff 64bit]
[    0.956273] pci 0000:00:1f.3: reg 20: [io  0xefa0-0xefbf]
[    0.956486] pci 0000:03:00.0: [8086:151a] type 1 class 0x000604
[    0.956618] pci 0000:03:00.0: supports D1 D2
[    0.956622] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.956633] pci 0000:03:00.0: PME# disabled
[    0.956812] pci 0000:00:01.0: PCI bridge to [bus 03-97]
[    0.956909] pci 0000:00:01.0:   bridge window [io  0x3000-0x3fff]
[    0.956919] pci 0000:00:01.0:   bridge window [mem 0xa0700000-0xa49fffff]
[    0.956933] pci 0000:00:01.0:   bridge window [mem 0xa4a00000-0xa89fffff 64bit pref]
[    0.957061] pci 0000:04:00.0: [8086:151a] type 1 class 0x000604
[    0.957195] pci 0000:04:00.0: supports D1 D2
[    0.957199] pci 0000:04:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.957210] pci 0000:04:00.0: PME# disabled
[    0.957295] pci 0000:04:03.0: [8086:151a] type 1 class 0x000604
[    0.957428] pci 0000:04:03.0: supports D1 D2
[    0.957433] pci 0000:04:03.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.957444] pci 0000:04:03.0: PME# disabled
[    0.957512] pci 0000:04:04.0: [8086:151a] type 1 class 0x000604
[    0.957645] pci 0000:04:04.0: supports D1 D2
[    0.957650] pci 0000:04:04.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.957661] pci 0000:04:04.0: PME# disabled
[    0.957789] pci 0000:03:00.0: PCI bridge to [bus 04-67]
[    0.957895] pci 0000:03:00.0:   bridge window [mem 0xa0700000-0xa09fffff]
[    0.958043] pci 0000:05:00.0: [8086:151a] type 0 class 0x000880
[    0.958076] pci 0000:05:00.0: reg 10: [mem 0xa0700000-0xa073ffff]
[    0.958101] pci 0000:05:00.0: reg 14: [mem 0xa0740000-0xa0740fff]
[    0.958270] pci 0000:05:00.0: supports D1 D2
[    0.958275] pci 0000:05:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.958286] pci 0000:05:00.0: PME# disabled
[    0.958383] pci 0000:04:00.0: PCI bridge to [bus 05-05]
[    0.958489] pci 0000:04:00.0:   bridge window [mem 0xa0700000-0xa07fffff]
[    0.958602] pci 0000:04:03.0: PCI bridge to [bus 06-36]
[    0.958706] pci 0000:04:03.0:   bridge window [mem 0xa0800000-0xa08fffff]
[    0.958818] pci 0000:04:04.0: PCI bridge to [bus 37-67]
[    0.958924] pci 0000:04:04.0:   bridge window [mem 0xa0900000-0xa09fffff]
[    0.959120] pci 0000:00:1c.0: PCI bridge to [bus 01-01]
[    0.959224] pci 0000:00:1c.0:   bridge window [mem 0xa0500000-0xa05fffff]
[    0.959488] pci 0000:02:00.0: [14e4:4353] type 0 class 0x000280
[    0.959572] pci 0000:02:00.0: reg 10: [mem 0xa0400000-0xa0403fff 64bit]
[    0.959919] pci 0000:02:00.0: supports D1 D2
[    0.959923] pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
[    0.959941] pci 0000:02:00.0: PME# disabled
[    0.964485] pci 0000:00:1c.1: PCI bridge to [bus 02-02]
[    0.964592] pci 0000:00:1c.1:   bridge window [mem 0xa0400000-0xa04fffff]
[    0.964659] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.965288] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2._PRT]
[    0.965830] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP02._PRT]
[    0.966328]  pci0000:00: Requesting ACPI _OSC control (0x1d)
[    0.967001]  pci0000:00: ACPI _OSC control (0x19) granted
[    0.985536] ACPI: PCI Interrupt Link [LNKA] (IRQs 1 3 4 5 6 7 10 12 14 15) *11
[    0.986479] ACPI: PCI Interrupt Link [LNKB] (IRQs 1 3 4 5 6 7 *11 12 14 15)
[    0.987342] ACPI: PCI Interrupt Link [LNKC] (IRQs 1 3 4 5 6 7 10 12 14 15) *11
[    0.988294] ACPI: PCI Interrupt Link [LNKD] (IRQs 1 3 4 5 6 7 *11 12 14 15)
[    0.989154] ACPI: PCI Interrupt Link [LNKE] (IRQs 1 3 4 5 6 7 10 12 14 15) *0, disabled.
[    0.990142] ACPI: PCI Interrupt Link [LNKF] (IRQs 1 3 4 5 6 7 11 12 14 15) *10
[    0.991088] ACPI: PCI Interrupt Link [LNKG] (IRQs 1 3 4 5 6 7 10 12 14 15) *11
[    0.992024] ACPI: PCI Interrupt Link [LNKH] (IRQs 1 3 4 5 6 7 *11 12 14 15)
[    0.993569] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.993745] vgaarb: loaded
[    0.993826] vgaarb: bridge control possible 0000:00:02.0
[    0.994207] PCI: Using ACPI for IRQ routing
[    1.002756] PCI: pci_cache_line_size set to 64 bytes
[    1.003073] reserve RAM buffer: 000000000008f000 - 000000000008ffff 
[    1.003080] reserve RAM buffer: 000000000009fc00 - 000000000009ffff 
[    1.003087] reserve RAM buffer: 000000008ad34000 - 000000008bffffff 
[    1.003096] reserve RAM buffer: 000000016fe00000 - 000000016fffffff 
[    1.003918] NetLabel: Initializing
[    1.004004] NetLabel:  domain hash size = 128
[    1.004091] NetLabel:  protocols = UNLABELED CIPSOv4
[    1.004279] NetLabel:  unlabeled traffic allowed by default
[    1.004430] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[    1.004981] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    1.007147] Switching to clocksource hpet
[    1.054853] pnp: PnP ACPI init
[    1.055023] ACPI: bus type pnp registered
[    1.056088] pnp 00:00: [bus 00-ff]
[    1.056095] pnp 00:00: [io  0x0000-0x0cf7 window]
[    1.056101] pnp 00:00: [io  0x0cf8-0x0cff]
[    1.056107] pnp 00:00: [io  0x0d00-0xffff window]
[    1.056113] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    1.056118] pnp 00:00: [mem 0x000c0000-0x000c3fff window]
[    1.056124] pnp 00:00: [mem 0x000c4000-0x000c7fff window]
[    1.056129] pnp 00:00: [mem 0x000c8000-0x000cbfff window]
[    1.056135] pnp 00:00: [mem 0x000cc000-0x000cffff window]
[    1.056140] pnp 00:00: [mem 0x000d0000-0x000d3fff window]
[    1.056145] pnp 00:00: [mem 0x000d4000-0x000d7fff window]
[    1.056151] pnp 00:00: [mem 0x000d8000-0x000dbfff window]
[    1.056156] pnp 00:00: [mem 0x000dc000-0x000dffff window]
[    1.056161] pnp 00:00: [mem 0x000e0000-0x000e3fff window]
[    1.056167] pnp 00:00: [mem 0x000e4000-0x000e7fff window]
[    1.056172] pnp 00:00: [mem 0x000e8000-0x000ebfff window]
[    1.056177] pnp 00:00: [mem 0x000ec000-0x000effff window]
[    1.056183] pnp 00:00: [mem 0x000f0000-0x000fffff window]
[    1.056188] pnp 00:00: [mem 0x8fa00000-0xfeafffff window]
[    1.056194] pnp 00:00: [mem 0xfed40000-0xfed44fff window]
[    1.056505] pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
[    1.056937] pnp 00:01: [io  0x0000-0x001f]
[    1.056942] pnp 00:01: [io  0x0081-0x0091]
[    1.056946] pnp 00:01: [io  0x0093-0x009f]
[    1.056951] pnp 00:01: [io  0x00c0-0x00df]
[    1.056957] pnp 00:01: [dma 4]
[    1.057126] pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
[    1.057159] pnp 00:02: [mem 0xff000000-0xffffffff]
[    1.057349] pnp 00:02: Plug and Play ACPI device, IDs INT0800 (active)
[    1.057586] pnp 00:03: [irq 0 disabled]
[    1.057612] pnp 00:03: [irq 8]
[    1.057617] pnp 00:03: [mem 0xfed00000-0xfed003ff]
[    1.057911] system 00:03: [mem 0xfed00000-0xfed003ff] has been reserved
[    1.058018] system 00:03: Plug and Play ACPI device, IDs PNP0103 PNP0c01 (active)
[    1.058063] pnp 00:04: [io  0x00f0]
[    1.058080] pnp 00:04: [irq 13]
[    1.058253] pnp 00:04: Plug and Play ACPI device, IDs PNP0c04 (active)
[    1.058290] pnp 00:05: [io  0x002e-0x002f]
[    1.058295] pnp 00:05: [io  0x004e-0x004f]
[    1.058299] pnp 00:05: [io  0x0061]
[    1.058304] pnp 00:05: [io  0x0063]
[    1.058308] pnp 00:05: [io  0x0065]
[    1.058316] pnp 00:05: [io  0x0067]
[    1.058320] pnp 00:05: [io  0x0080]
[    1.058324] pnp 00:05: [io  0x0092]
[    1.058329] pnp 00:05: [io  0x00b2-0x00b3]
[    1.058334] pnp 00:05: [io  0x1000-0x100f]
[    1.058338] pnp 00:05: [io  0x0400-0x047f]
[    1.058343] pnp 00:05: [io  0x0500-0x057f]
[    1.058603] system 00:05: [io  0x1000-0x100f] has been reserved
[    1.058701] system 00:05: [io  0x0400-0x047f] has been reserved
[    1.058797] system 00:05: [io  0x0500-0x057f] has been reserved
[    1.058896] system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.058928] pnp 00:06: [io  0x0070-0x0077]
[    1.059097] pnp 00:06: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.059144] pnp 00:07: [io  0x0300-0x031f]
[    1.059160] pnp 00:07: [irq 6]
[    1.059337] pnp 00:07: Plug and Play ACPI device, IDs APP0001 (active)
[    1.059912] pnp 00:08: [mem 0xfed1c000-0xfed1ffff]
[    1.059918] pnp 00:08: [mem 0xfed10000-0xfed17fff]
[    1.059923] pnp 00:08: [mem 0xfed18000-0xfed18fff]
[    1.059928] pnp 00:08: [mem 0xfed19000-0xfed19fff]
[    1.059933] pnp 00:08: [mem 0xe0000000-0xefffffff]
[    1.059938] pnp 00:08: [mem 0xfed20000-0xfed3ffff]
[    1.059943] pnp 00:08: [mem 0xfed90000-0xfed93fff]
[    1.059948] pnp 00:08: [mem 0xfed45000-0xfed8ffff]
[    1.059952] pnp 00:08: [mem 0xff000000-0xffffffff]
[    1.059957] pnp 00:08: [mem 0xfee00000-0xfeefffff]
[    1.059963] pnp 00:08: [mem 0x00000000-0xffffffffffffffff disabled]
[    1.060251] system 00:08: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    1.060353] system 00:08: [mem 0xfed10000-0xfed17fff] could not be reserved
[    1.060454] system 00:08: [mem 0xfed18000-0xfed18fff] has been reserved
[    1.060553] system 00:08: [mem 0xfed19000-0xfed19fff] has been reserved
[    1.060675] system 00:08: [mem 0xe0000000-0xefffffff] has been reserved
[    1.060774] system 00:08: [mem 0xfed20000-0xfed3ffff] has been reserved
[    1.060872] system 00:08: [mem 0xfed90000-0xfed93fff] has been reserved
[    1.060970] system 00:08: [mem 0xfed45000-0xfed8ffff] has been reserved
[    1.061070] system 00:08: [mem 0xff000000-0xffffffff] could not be reserved
[    1.061169] system 00:08: [mem 0xfee00000-0xfeefffff] could not be reserved
[    1.061274] system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.068642] pnp 00:09: [mem 0x20000000-0x201fffff]
[    1.068649] pnp 00:09: [mem 0x40000000-0x401fffff]
[    1.069007] system 00:09: [mem 0x20000000-0x201fffff] has been reserved
[    1.069145] system 00:09: [mem 0x40000000-0x401fffff] has been reserved
[    1.069400] system 00:09: Plug and Play ACPI device, IDs PNP0c01 (active)
[    1.069431] pnp: PnP ACPI: found 10 devices
[    1.069520] ACPI: ACPI bus type pnp unregistered
[    1.085955] PCI: max bus depth: 3 pci_try_num: 4
[    1.086092] pci 0000:04:00.0: PCI bridge to [bus 05-05]
[    1.086195] pci 0000:04:00.0:   bridge window [mem 0xa0700000-0xa07fffff]
[    1.086306] pci 0000:04:03.0: PCI bridge to [bus 06-36]
[    1.086405] pci 0000:04:03.0:   bridge window [mem 0xa0800000-0xa08fffff]
[    1.086517] pci 0000:04:04.0: PCI bridge to [bus 37-67]
[    1.086616] pci 0000:04:04.0:   bridge window [mem 0xa0900000-0xa09fffff]
[    1.086728] pci 0000:03:00.0: PCI bridge to [bus 04-67]
[    1.086826] pci 0000:03:00.0:   bridge window [mem 0xa0700000-0xa09fffff]
[    1.086937] pci 0000:00:01.0: PCI bridge to [bus 03-97]
[    1.087031] pci 0000:00:01.0:   bridge window [io  0x3000-0x3fff]
[    1.087131] pci 0000:00:01.0:   bridge window [mem 0xa0700000-0xa49fffff]
[    1.087250] pci 0000:00:01.0:   bridge window [mem 0xa4a00000-0xa89fffff 64bit pref]
[    1.087378] pci 0000:00:1c.0: PCI bridge to [bus 01-01]
[    1.087479] pci 0000:00:1c.0:   bridge window [mem 0xa0500000-0xa05fffff]
[    1.087596] pci 0000:00:1c.1: PCI bridge to [bus 02-02]
[    1.087697] pci 0000:00:1c.1:   bridge window [mem 0xa0400000-0xa04fffff]
[    1.087854] pci 0000:00:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.087957] pci 0000:00:01.0: setting latency timer to 64
[    1.087976] pci 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.088077] pci 0000:03:00.0: setting latency timer to 64
[    1.088096] pci 0000:04:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.088197] pci 0000:04:00.0: setting latency timer to 64
[    1.088213] pci 0000:04:03.0: enabling device (0000 -> 0002)
[    1.088337] pci 0000:04:03.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
[    1.088442] pci 0000:04:03.0: setting latency timer to 64
[    1.088457] pci 0000:04:04.0: enabling device (0000 -> 0002)
[    1.088556] pci 0000:04:04.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.088659] pci 0000:04:04.0: setting latency timer to 64
[    1.088675] pci 0000:00:1c.0: enabling device (0000 -> 0002)
[    1.089335] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.089443] pci 0000:00:1c.0: setting latency timer to 64
[    1.089620] pci 0000:00:1c.1: power state changed by ACPI to D0
[    1.089725] pci 0000:00:1c.1: power state changed by ACPI to D0
[    1.089846] pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    1.089950] pci 0000:00:1c.1: setting latency timer to 64
[    1.089961] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.089967] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.089973] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.089979] pci_bus 0000:00: resource 7 [mem 0x8fa00000-0xfeafffff]
[    1.089985] pci_bus 0000:00: resource 8 [mem 0xfed40000-0xfed44fff]
[    1.089991] pci_bus 0000:03: resource 0 [io  0x3000-0x3fff]
[    1.089996] pci_bus 0000:03: resource 1 [mem 0xa0700000-0xa49fffff]
[    1.090002] pci_bus 0000:03: resource 2 [mem 0xa4a00000-0xa89fffff 64bit pref]
[    1.090008] pci_bus 0000:04: resource 1 [mem 0xa0700000-0xa09fffff]
[    1.090014] pci_bus 0000:05: resource 1 [mem 0xa0700000-0xa07fffff]
[    1.090020] pci_bus 0000:06: resource 1 [mem 0xa0800000-0xa08fffff]
[    1.090026] pci_bus 0000:37: resource 1 [mem 0xa0900000-0xa09fffff]
[    1.090032] pci_bus 0000:01: resource 1 [mem 0xa0500000-0xa05fffff]
[    1.090038] pci_bus 0000:02: resource 1 [mem 0xa0400000-0xa04fffff]
[    1.090175] NET: Registered protocol family 2
[    1.090881] IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    1.094530] TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
[    1.099223] TCP bind hash table entries: 65536 (order: 10, 4194304 bytes)
[    1.111182] TCP: Hash tables configured (established 524288 bind 65536)
[    1.111327] TCP reno registered
[    1.111518] UDP hash table entries: 2048 (order: 6, 327680 bytes)
[    1.112475] UDP-Lite hash table entries: 2048 (order: 6, 327680 bytes)
[    1.113656] NET: Registered protocol family 1
[    1.113798] pci 0000:00:02.0: Boot video device
[    1.114377] PCI: CLS 256 bytes, default 64
[    1.114764] Unpacking initramfs...
[    1.287218] Freeing initrd memory: 3092k freed
[    1.288428] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.288527] Placing 64MB software IO TLB between ffff880086d2d000 - ffff88008ad2d000
[    1.288647] software IO TLB at phys 0x86d2d000 - 0x8ad2d000
[    1.290866] audit: initializing netlink socket (disabled)
[    1.291038] type=2000 audit(1294394441.116:1): initialized
[    1.302860] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.333249] VFS: Disk quotas dquot_6.5.2
[    1.333701] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.334659] msgmni has been set to 7715
[    1.335872] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[    1.336146] io scheduler noop registered
[    1.336235] io scheduler deadline registered
[    1.336469] io scheduler cfq registered (default)
[    1.337180] pcieport 0000:00:01.0: setting latency timer to 64
[    1.337353] pcieport 0000:00:01.0: irq 40 for MSI/MSI-X
[    1.337869] pcieport 0000:03:00.0: setting latency timer to 64
[    1.337972] pcieport 0000:03:00.0: irq 41 for MSI/MSI-X
[    1.338239] pcieport 0000:04:00.0: setting latency timer to 64
[    1.338341] pcieport 0000:04:00.0: irq 42 for MSI/MSI-X
[    1.338605] pcieport 0000:04:03.0: setting latency timer to 64
[    1.338707] pcieport 0000:04:03.0: irq 43 for MSI/MSI-X
[    1.338977] pcieport 0000:04:04.0: setting latency timer to 64
[    1.339079] pcieport 0000:04:04.0: irq 44 for MSI/MSI-X
[    1.340360] intel_idle: MWAIT substates: 0x21120
[    1.340366] intel_idle: v0.4 model 0x2A
[    1.340370] intel_idle: lapic_timer_reliable_states 0xffffffff
[    1.340682] ERST: Table is not found!
[    1.340769] GHES: HEST is not enabled!
[    1.341096] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    1.544247] Linux agpgart interface v0.103
[    1.544879] i8042: PNP: No PS/2 controller found. Probing ports directly.
[    1.545882] i8042: No controller found
[    1.546414] mousedev: PS/2 mouse device common for all mice
[    1.546918] rtc_cmos 00:06: RTC can wake from S4
[    1.547627] rtc_cmos 00:06: rtc core: registered rtc_cmos as rtc0
[    1.547797] rtc0: alarms up to one month, y3k, 242 bytes nvram, hpet irqs
[    1.548549] cpuidle: using governor ladder
[    1.550138] cpuidle: using governor menu
[    1.551763] TCP cubic registered
[    1.551851] NET: Registered protocol family 17
[    1.551956] Registering the dns_resolver key type
[    1.552863] PM: Hibernation image not present or could not be loaded.
[    1.552880] registered taskstats version 1
[    1.565461] rtc_cmos 00:06: setting system clock to 2011-01-07 10:00:42 UTC (1294394442)
[    1.565912] Initializing network drop monitor service
[    1.570738] Freeing unused kernel memory: 724k freed
[    1.571104] Write protecting the kernel read-only data: 8192k
[    1.586668] Freeing unused kernel memory: 1760k freed
[    1.589529] Freeing unused kernel memory: 228k freed
[    1.626211] udevd[45]: starting version 175
[    1.808779] usbcore: registered new interface driver usbfs
[    1.810153] usbcore: registered new interface driver hub
[    1.811714] usbcore: registered new device driver usb
[    1.821016] SCSI subsystem initialized
[    1.825398] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.825702] ehci_hcd 0000:00:1a.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    1.825925] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[    1.825940] ehci_hcd 0000:00:1a.7: EHCI Host Controller
[    1.827292] ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
[    1.827555] ehci_hcd 0000:00:1a.7: debug port 2
[    1.830602] libata version 3.00 loaded.
[    1.831542] ehci_hcd 0000:00:1a.7: cache line size of 256 is not supported
[    1.831609] ehci_hcd 0000:00:1a.7: irq 23, io mem 0xa0606c00
[    1.842934] ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00
[    1.844962] hub 1-0:1.0: USB hub found
[    1.845122] hub 1-0:1.0: 6 ports detected
[    1.846112] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[    1.846289] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    1.846299] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    1.846450] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
[    1.846634] ehci_hcd 0000:00:1d.7: debug port 2
[    1.850619] ehci_hcd 0000:00:1d.7: cache line size of 256 is not supported
[    1.850707] ehci_hcd 0000:00:1d.7: irq 22, io mem 0xa0606800
[    1.862746] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    1.864742] hub 2-0:1.0: USB hub found
[    1.864878] hub 2-0:1.0: 8 ports detected
[    1.865714] ata_piix 0000:00:1f.2: version 2.13
[    1.865754] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    1.865889] ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
[    1.872046] uhci_hcd: USB Universal Host Controller Interface driver
[    2.019354] ata_piix 0000:00:1f.2: setting latency timer to 64
[    2.021443] scsi0 : ata_piix
[    2.022246] scsi1 : ata_piix
[    2.023254] ata1: SATA max UDMA/133 cmd 0x2168 ctl 0x217c bmdma 0x2060 irq 19
[    2.023361] ata2: SATA max UDMA/133 cmd 0x2160 ctl 0x2178 bmdma 0x2068 irq 19
[    2.024119] uhci_hcd 0000:00:1a.0: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[    2.024271] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[    2.024282] uhci_hcd 0000:00:1a.0: UHCI Host Controller
[    2.024437] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
[    2.024652] uhci_hcd 0000:00:1a.0: irq 21, io base 0x00002140
[    2.025614] hub 3-0:1.0: USB hub found
[    2.025727] hub 3-0:1.0: 2 ports detected
[    2.026263] uhci_hcd 0000:00:1d.0: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    2.026376] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    2.026385] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    2.026513] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 4
[    2.026678] uhci_hcd 0000:00:1d.0: irq 19, io base 0x000020e0
[    2.027532] hub 4-0:1.0: USB hub found
[    2.027643] hub 4-0:1.0: 2 ports detected
[    2.149109] usb 1-1: new high-speed USB device number 2 using ehci_hcd
[    2.274010] hub 1-1:1.0: USB hub found
[    2.274361] hub 1-1:1.0: 3 ports detected
[    2.288997] Refined TSC clocksource calibration: 1800.012 MHz.
[    2.289144] Switching to clocksource tsc
[    2.382028] usb 1-2: new high-speed USB device number 3 using ehci_hcd
[    2.628313] usb 2-1: new high-speed USB device number 2 using ehci_hcd
[    2.752914] hub 2-1:1.0: USB hub found
[    2.753154] hub 2-1:1.0: 2 ports detected
[    2.834936] usb 1-1.1: new full-speed USB device number 4 using ehci_hcd
[    2.934627] hub 1-1.1:1.0: USB hub found
[    2.934990] hub 1-1.1:1.0: 3 ports detected
[    3.014700] usb 1-1.2: new full-speed USB device number 5 using ehci_hcd
[    3.044318] ata2.00: failed to resume link (SControl 0)
[    3.143645] usbcore: registered new interface driver usbhid
[    3.143762] usbhid: USB HID core driver
[    3.201016] usb 1-1.3: new high-speed USB device number 6 using ehci_hcd
[    3.312862] Initializing USB Mass Storage driver...
[    3.313541] scsi2 : usb-storage 1-1.3:1.0
[    3.314217] usbcore: registered new interface driver usb-storage
[    3.314313] USB Mass Storage support registered.
[    3.363826] ata1.01: failed to resume link (SControl 0)
[    3.380741] usb 2-1.1: new high-speed USB device number 3 using ehci_hcd
[    3.483976] scsi3 : usb-storage 2-1.1:1.0
[    3.517012] ata1.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    3.517132] ata1.01: SATA link down (SStatus 0 SControl 0)
[    3.524283] ata1.00: ATA-8: APPLE SSD SM256C, AXM09A1Q, max UDMA/133
[    3.524390] ata1.00: 490234752 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    3.530663] ata1.00: configured for UDMA/133
[    3.532393] scsi 0:0:0:0: Direct-Access     ATA      APPLE SSD SM256C AXM0 PQ: 0 ANSI: 5
[    3.550438] usb 1-1.1.1: new full-speed USB device number 7 using ehci_hcd
[    3.640075] input: HID 05ac:820a as /devices/pci0000:00/0000:00:1a.7/usb1/1-1/1-1.1/1-1.1.1/1-1.1.1:1.0/input/input0
[    3.642360] generic-usb 0003:05AC:820A.0003: input,hidraw0: USB HID v1.11 Keyboard [HID 05ac:820a] on usb-0000:00:1a.7-1.1.1/input0
[    3.710184] usb 1-1.1.2: new full-speed USB device number 8 using ehci_hcd
[    3.799738] input: HID 05ac:820b as /devices/pci0000:00/0000:00:1a.7/usb1/1-1/1-1.1/1-1.1.2/1-1.1.2:1.0/input/input1
[    3.801113] generic-usb 0003:05AC:820B.0004: input,hidraw1: USB HID v1.11 Mouse [HID 05ac:820b] on usb-0000:00:1a.7-1.1.2/input0
[    3.866703] usb 1-1.1.3: new full-speed USB device number 9 using ehci_hcd
[    4.066066] ata2.01: failed to resume link (SControl 0)
[    4.078040] ata2.00: SATA link down (SStatus 0 SControl 0)
[    4.078153] ata2.01: SATA link down (SStatus 0 SControl 0)
[    4.093230] input: Apple Inc. Apple Internal Keyboard / Trackpad as /devices/pci0000:00/0000:00:1a.7/usb1/1-1/1-1.2/1-1.2:1.0/input/input2
[    4.094232] apple 0003:05AC:024D.0001: input,hidraw2: USB HID v1.11 Keyboard [Apple Inc. Apple Internal Keyboard / Trackpad] on usb-0000:00:1a.7-1.2/input0
[    4.099987] apple 0003:05AC:024D.0002: hidraw3: USB HID v1.11 Device [Apple Inc. Apple Internal Keyboard / Trackpad] on usb-0000:00:1a.7-1.2/input1
[    4.103361] sd 0:0:0:0: [sda] 490234752 512-byte logical blocks: (251 GB/233 GiB)
[    4.103862] sd 0:0:0:0: [sda] Write Protect is off
[    4.103954] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    4.104082] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    4.111647]  sda: sda1 sda2 sda3 sda4 sda5
[    4.114642] sd 0:0:0:0: [sda] Attached SCSI disk
[    4.314329] scsi 2:0:0:0: Direct-Access     Android    UMS Composite    00 PQ: 0 ANSI: 2
[    4.317834] scsi 2:0:0:1: Direct-Access     Android    UMS Composite    00 PQ: 0 ANSI: 2
[    4.319211] sd 2:0:0:0: [sdb] Attached SCSI removable disk
[    4.326798] sd 2:0:0:1: [sdc] Attached SCSI removable disk
[    4.350660] device-mapper: uevent: version 1.0.3
[    4.351857] device-mapper: ioctl: 4.22.0-ioctl (2011-10-19) initialised: dm-devel@redhat.com
[    4.504690] scsi 3:0:0:0: Direct-Access     APPLE    SD Card Reader   2.00 PQ: 0 ANSI: 0
[    4.508246] sd 3:0:0:0: [sdd] Attached SCSI removable disk
[   19.456283] JFS: nTxBlock = 8192, nTxLock = 65536
[   20.034207] udevd[314]: starting version 175
[   20.233633] ACPI: AC Adapter [ADP1] (on-line)
[   20.335759] mei: module is from the staging directory, the quality is unknown, you have been warned.
[   20.344368] mei 0000:00:16.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[   20.344486] mei 0000:00:16.0: setting latency timer to 64
[   20.344892] mei 0000:00:16.0: irq 45 for MSI/MSI-X
[   20.368057] ACPI: Battery Slot [BAT0] (battery present)
[   20.368834] input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:00/input/input3
[   20.369179] ACPI: Lid Switch [LID0]
[   20.371121] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input4
[   20.371288] ACPI: Power Button [PWRB]
[   20.371693] input: Sleep Button as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input5
[   20.371852] ACPI: Sleep Button [SLPB]
[   20.375417] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input6
[   20.375573] ACPI: Power Button [PWRF]
[   20.383953] agpgart-intel 0000:00:00.0: Intel Sandybridge Chipset
[   20.384349] iTCO_vendor_support: vendor-support=0
[   20.384836] agpgart-intel 0000:00:00.0: detected gtt size: 2097152K total, 262144K mappable
[   20.389283] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.07
[   20.389863] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by hardware/BIOS
[   20.398163] agpgart-intel 0000:00:00.0: detected 65536K stolen memory
[   20.400404] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0x90000000
[   20.415226] cfg80211: Calling CRDA to update world regulatory domain
[   20.428888] input: PC Speaker as /devices/platform/pcspkr/input/input7
[   20.431018] i801_smbus 0000:00:1f.3: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[   20.490664] brcmsmac 0000:02:00.0: bus 2 slot 0 func 0 irq 11
[   20.490848] brcmsmac 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[   20.490975] brcmsmac 0000:02:00.0: setting latency timer to 64
[   20.548057] [drm] Initialized drm 1.1.0 20060810
[   20.567257] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[   20.567649] snd_hda_intel 0000:00:1b.0: irq 46 for MSI/MSI-X
[   20.567786] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[   20.589610] applesmc: key=349 fan=1 temp=25 acc=0 lux=2 kbd=1
[   20.599119] Registered led device: smc::kbd_backlight
[   20.907356] Linux media interface: v0.10
[   20.919811] input: bcm5974 as /devices/pci0000:00/0000:00:1a.7/usb1/1-1/1-1.2/1-1.2:1.2/input/input8
[   20.921243] usbcore: registered new interface driver bcm5974
[   20.933649] Linux video capture interface: v2.00
[   20.945171] uvcvideo: Found UVC 1.00 device FaceTime Camera (Built-in) (05ac:850a)
[   21.011063] input: FaceTime Camera (Built-in) as /devices/pci0000:00/0000:00:1a.7/usb1/1-2/1-2:1.0/input/input9
[   21.017168] usbcore: registered new interface driver uvcvideo
[   21.017280] USB Video Class driver (1.1.1)
[   21.040969] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[   21.043218] Bluetooth: Core ver 2.16
[   21.043366] NET: Registered protocol family 31
[   21.043456] Bluetooth: HCI device and connection manager initialized
[   21.043648] Bluetooth: HCI socket layer initialized
[   21.043754] Bluetooth: L2CAP socket layer initialized
[   21.043953] Bluetooth: SCO socket layer initialized
[   21.067466] Bluetooth: Generic Bluetooth USB driver ver 0.6
[   21.067590] cdc_acm 1-1.3:1.1: This device cannot do calls on its own. It is not a modem.
[   21.068290] cdc_acm 1-1.3:1.1: ttyACM0: USB ACM device
[   21.077326] usbcore: registered new interface driver cdc_acm
[   21.077495] cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
[   21.080585] usbcore: registered new interface driver btusb
[   21.136252] usb 1-1.1.1: USB disconnect, device number 7
[   21.157198] HDMI status: Codec=3 Pin=5 Presence_Detect=0 ELD_Valid=0
[   21.157858] HDMI status: Codec=3 Pin=6 Presence_Detect=0 ELD_Valid=0
[   21.158188] HDMI status: Codec=3 Pin=7 Presence_Detect=0 ELD_Valid=0
[   21.165216] input: HDA Intel PCH HDMI/DP,pcm=8 as /devices/pci0000:00/0000:00:1b.0/sound/card0/input10
[   21.220609] input: HDA Intel PCH HDMI/DP,pcm=7 as /devices/pci0000:00/0000:00:1b.0/sound/card0/input11
[   21.221346] input: HDA Intel PCH HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:1b.0/sound/card0/input12
[   21.227893] i915 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[   21.228014] i915 0000:00:02.0: setting latency timer to 64
[   21.383113] usb 1-1.1.2: USB disconnect, device number 8
[   21.547866] i915 0000:00:02.0: irq 47 for MSI/MSI-X
[   21.547891] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[   21.547987] [drm] Driver supports precise vblank timestamp query.
[   21.548318] [drm:intel_dsm_platform_mux_info] *ERROR* MUX INFO call failed
[   21.548969] vgaarb: device changed decodes: PCI:0000:00:02.0,olddecodes=io+mem,decodes=io+mem:owns=io+mem
[   23.617193] fbcon: inteldrmfb (fb0) is primary device
[   24.462810] Console: switching to colour frame buffer device 180x56
[   24.470904] fb0: inteldrmfb frame buffer device
[   24.470963] drm: registered panic notifier
[   24.505988] acpi device:0d: registered as cooling_device4
[   24.507010] input: Video Bus as /devices/LNXSYSTM:00/device:00/PNP0A08:00/LNXVIDEO:00/input/input13
[   24.507564] ACPI: Video Device [IGPU] (multi-head: yes  rom: no  post: no)
[   24.508072] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on minor 0
[   26.971162] EXT4-fs (sda4): mounted filesystem with ordered data mode. Opts: (null)
[   28.397649] NET: Registered protocol family 10
[   71.833927] usb 2-1.2: new high-speed USB device number 4 using ehci_hcd
[   71.933317] usb-storage 2-1.2:1.0: Quirks match for vid 1058 pid 0704: 8000
[   71.933420] scsi4 : usb-storage 2-1.2:1.0
[   72.933314] scsi 4:0:0:0: Direct-Access     WD       5000BMV External 1.75 PQ: 0 ANSI: 4
[   72.935182] sd 4:0:0:0: [sde] 976773168 512-byte logical blocks: (500 GB/465 GiB)
[   72.936041] sd 4:0:0:0: [sde] Write Protect is off
[   72.936056] sd 4:0:0:0: [sde] Mode Sense: 23 00 00 00
[   72.936804] sd 4:0:0:0: [sde] No Caching mode page present
[   72.936820] sd 4:0:0:0: [sde] Assuming drive cache: write through
[   72.941169] sd 4:0:0:0: [sde] No Caching mode page present
[   72.941179] sd 4:0:0:0: [sde] Assuming drive cache: write through
[   72.973074]  sde: unknown partition table
[   72.975628] sd 4:0:0:0: [sde] No Caching mode page present
[   72.975639] sd 4:0:0:0: [sde] Assuming drive cache: write through
[   72.975647] sd 4:0:0:0: [sde] Attached SCSI disk
[   99.019860] padlock_sha: VIA PadLock Hash Engine not detected.
[  343.182142] usb 1-1.3: USB disconnect, device number 6
[  350.163439] usb 1-1.3: new high-speed USB device number 10 using ehci_hcd
[  350.783462] asix 1-1.3:1.0: eth0: register 'asix' at usb-0000:00:1a.7-1.3, ASIX AX88772 USB 2.0 Ethernet, 00:50:b6:05:85:62
[  350.784668] usbcore: registered new interface driver asix
[  353.439441] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  353.551116] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  353.553525] asix 1-1.3:1.0: eth0: link down
[  355.226891] asix 1-1.3:1.0: eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[  364.118186] eth0: no IPv6 routers present
[14603.753889] usb 1-1.3: USB disconnect, device number 10
[14603.754436] asix 1-1.3:1.0: eth0: unregister 'asix' usb-0000:00:1a.7-1.3, ASIX AX88772 USB 2.0 Ethernet
[14607.021412] usb 1-1.3: new high-speed USB device number 11 using ehci_hcd
[14607.121122] scsi5 : usb-storage 1-1.3:1.0
[14607.121729] cdc_acm 1-1.3:1.1: This device cannot do calls on its own. It is not a modem.
[14607.121792] cdc_acm 1-1.3:1.1: ttyACM0: USB ACM device
[14608.121304] scsi 5:0:0:0: Direct-Access     Android    UMS Composite    00 PQ: 0 ANSI: 2
[14608.122739] scsi 5:0:0:1: Direct-Access     Android    UMS Composite    00 PQ: 0 ANSI: 2
[14608.126391] sd 5:0:0:0: [sdb] Attached SCSI removable disk
[14608.130104] sd 5:0:0:1: [sdc] Attached SCSI removable disk
[42753.493213] usb 1-1.3: USB disconnect, device number 11
[42758.802291] usb 1-1.3: new high-speed USB device number 12 using ehci_hcd
[42759.224473] asix 1-1.3:1.0: eth0: register 'asix' at usb-0000:00:1a.7-1.3, ASIX AX88772 USB 2.0 Ethernet, 00:50:b6:05:85:62
[42769.043780] ADDRCONF(NETDEV_UP): eth0: link is not ready
[42769.093649] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[42769.094870] asix 1-1.3:1.0: eth0: link down
[42770.885030] asix 1-1.3:1.0: eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[42779.602944] eth0: no IPv6 routers present
[57072.028112] sd 3:0:0:0: [sdd] 257882112 512-byte logical blocks: (132 GB/122 GiB)
[57072.030884] sd 3:0:0:0: [sdd] No Caching mode page present
[57072.030888] sd 3:0:0:0: [sdd] Assuming drive cache: write through
[57072.035237] sd 3:0:0:0: [sdd] No Caching mode page present
[57072.035242] sd 3:0:0:0: [sdd] Assuming drive cache: write through
[57072.036586]  sdd: sdd1 sdd2 sdd3
[83580.992041] usb 1-1.3: USB disconnect, device number 12
[83580.992587] asix 1-1.3:1.0: eth0: unregister 'asix' usb-0000:00:1a.7-1.3, ASIX AX88772 USB 2.0 Ethernet
[83583.568382] usb 2-1.2: USB disconnect, device number 4
[83688.563074] usb 2-1.2: new high-speed USB device number 5 using ehci_hcd
[83688.985099] asix 2-1.2:1.0: eth0: register 'asix' at usb-0000:00:1d.7-1.2, ASIX AX88772 USB 2.0 Ethernet, 00:50:b6:05:85:62
[83694.308354] ADDRCONF(NETDEV_UP): eth0: link is not ready
[83694.371824] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[83694.373052] asix 2-1.2:1.0: eth0: link down
[83696.035575] asix 2-1.2:1.0: eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[83704.903985] eth0: no IPv6 routers present
[86572.298737] usb 2-1.2: USB disconnect, device number 5
[86572.299140] asix 2-1.2:1.0: eth0: unregister 'asix' usb-0000:00:1d.7-1.2, ASIX AX88772 USB 2.0 Ethernet
[86620.658841] sdd: detected capacity change from 132035641344 to 0
[86622.460650] EXT4-fs (sda4): re-mounted. Opts: commit=0
[86622.837272] PM: Syncing filesystems ... done.
[86622.859300] PM: Preparing system for mem sleep
[86624.134747] Freezing user space processes ... (elapsed 0.01 seconds) done.
[86624.147971] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
[86624.161277] PM: Entering mem sleep
[86624.161321] Suspending console(s) (use no_console_suspend to debug)
[86624.163244] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[86624.164565] sd 0:0:0:0: [sda] Stopping disk
[86624.164845] brcmsmac 0000:02:00.0: PCI INT A disabled
[86624.197981] uhci_hcd 0000:00:1a.0: PCI INT B disabled
[86624.197986] uhci_hcd 0000:00:1d.0: PCI INT B disabled
[86624.201206] ehci_hcd 0000:00:1d.7: PCI INT A disabled
[86624.214512] ehci_hcd 0000:00:1a.7: PCI INT A disabled
[86624.371045] snd_hda_intel 0000:00:1b.0: PCI INT A disabled
[86625.577731] ata_piix 0000:00:1f.2: PCI INT B disabled
[86625.589145] PM: suspend of devices complete after 1429.214 msecs
[86625.589705] ehci_hcd 0000:00:1d.7: PME# enabled
[86625.589741] ehci_hcd 0000:00:1d.7: wake-up capability enabled by ACPI
[86625.602457] ehci_hcd 0000:00:1a.7: PME# enabled
[86625.602472] ehci_hcd 0000:00:1a.7: wake-up capability enabled by ACPI
[86625.629055] PM: late suspend of devices complete after 39.967 msecs
[86625.629447] ACPI: Preparing to enter system sleep state S3
[86625.655759] PM: Saving platform NVS memory
[86625.656413] Disabling non-boot CPUs ...
[86625.659541] CPU 1 is now offline
[86625.765449] CPU 2 is now offline
[86625.868593] CPU 3 is now offline
[86625.868596] lockdep: fixing up alternatives.
[86625.869418] Extended CMOS year: 2000
[86625.869933] ACPI: Low-level resume complete
[86625.870013] PM: Restoring platform NVS memory
[86625.870534] Extended CMOS year: 2000
[86625.870605] Enabling non-boot CPUs ...
[86625.877663] lockdep: fixing up alternatives.
[86625.877681] Booting Node 0 Processor 1 APIC 0x2
[86625.877685] smpboot cpu 1: start_ip = 9a000
[86625.889099] Calibrating delay loop (skipped) already calibrated this CPU
[86625.914966] NMI watchdog enabled, takes one hw-pmu counter.
[86625.919086] CPU1 is up
[86625.928027] lockdep: fixing up alternatives.
[86625.928037] Booting Node 0 Processor 2 APIC 0x1
[86625.928041] smpboot cpu 2: start_ip = 9a000
[86625.939305] Calibrating delay loop (skipped) already calibrated this CPU
[86625.963887] NMI watchdog enabled, takes one hw-pmu counter.
[86625.988442] CPU2 is up
[86625.997140] lockdep: fixing up alternatives.
[86625.997523] Booting Node 0 Processor 3 APIC 0x3
[86625.997678] smpboot cpu 3: start_ip = 9a000
[86626.011679] Calibrating delay loop (skipped) already calibrated this CPU
[86626.234545] NMI watchdog enabled, takes one hw-pmu counter.
[86626.257206] CPU3 is up
[86626.270844] ACPI: Waking up from system sleep state S3
[86626.772088] pcieport 0000:00:01.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[86626.772110] pcieport 0000:00:01.0: restoring config space at offset 0x9 (was 0x1fff1, writing 0xa891a4a1)
[86626.772120] pcieport 0000:00:01.0: restoring config space at offset 0x8 (was 0xfff0, writing 0xa490a070)
[86626.772129] pcieport 0000:00:01.0: restoring config space at offset 0x7 (was 0x200000f0, writing 0x3030)
[86626.772144] pcieport 0000:00:01.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[86626.772155] pcieport 0000:00:01.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[86626.772227] i915 0000:00:02.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[86626.772257] i915 0000:00:02.0: restoring config space at offset 0x2 (was 0x3800009, writing 0x3000009)
[86626.772266] i915 0000:00:02.0: restoring config space at offset 0x1 (was 0x900007, writing 0x900407)
[86626.772335] mei 0000:00:16.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[86626.772378] mei 0000:00:16.0: restoring config space at offset 0x4 (was 0xfed1b004, writing 0xa0607104)
[86626.772440] uhci_hcd 0000:00:1a.0: restoring config space at offset 0xf (was 0x200, writing 0x20a)
[86626.772470] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x8 (was 0x1, writing 0x2141)
[86626.772500] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[86626.772561] ehci_hcd 0000:00:1a.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[86626.772604] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606c00)
[86626.772622] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[86626.772677] ehci_hcd 0000:00:1a.7: wake-up capability disabled by ACPI
[86626.772690] ehci_hcd 0000:00:1a.7: PME# disabled
[86626.772735] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[86626.772777] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0600004)
[86626.772789] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[86626.772803] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100002)
[86626.772885] pcieport 0000:00:1c.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[86626.772913] pcieport 0000:00:1c.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[86626.772925] pcieport 0000:00:1c.0: restoring config space at offset 0x8 (was 0x0, writing 0xa050a050)
[86626.772937] pcieport 0000:00:1c.0: restoring config space at offset 0x7 (was 0x20000000, writing 0x200000f0)
[86626.772949] pcieport 0000:00:1c.0: restoring config space at offset 0x6 (was 0x0, writing 0x10100)
[86626.772967] pcieport 0000:00:1c.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[86626.772982] pcieport 0000:00:1c.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[86626.773076] pcieport 0000:00:1c.1: restoring config space at offset 0xf (was 0x200, writing 0x2ff)
[86626.773105] pcieport 0000:00:1c.1: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[86626.773117] pcieport 0000:00:1c.1: restoring config space at offset 0x8 (was 0x0, writing 0xa040a040)
[86626.773129] pcieport 0000:00:1c.1: restoring config space at offset 0x7 (was 0x20000000, writing 0x200000f0)
[86626.773141] pcieport 0000:00:1c.1: restoring config space at offset 0x6 (was 0x0, writing 0x20200)
[86626.773159] pcieport 0000:00:1c.1: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[86626.773174] pcieport 0000:00:1c.1: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[86626.773246] uhci_hcd 0000:00:1d.0: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[86626.773276] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x8 (was 0x1, writing 0x20e1)
[86626.773306] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[86626.773367] ehci_hcd 0000:00:1d.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[86626.773409] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606800)
[86626.773426] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[86626.773478] ehci_hcd 0000:00:1d.7: wake-up capability disabled by ACPI
[86626.773491] ehci_hcd 0000:00:1d.7: PME# disabled
[86626.773610] ata_piix 0000:00:1f.2: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[86626.773640] ata_piix 0000:00:1f.2: restoring config space at offset 0x8 (was 0x1, writing 0x2061)
[86626.773651] ata_piix 0000:00:1f.2: restoring config space at offset 0x7 (was 0x1, writing 0x2179)
[86626.773662] ata_piix 0000:00:1f.2: restoring config space at offset 0x6 (was 0x1, writing 0x2161)
[86626.773674] ata_piix 0000:00:1f.2: restoring config space at offset 0x5 (was 0x1, writing 0x217d)
[86626.773685] ata_piix 0000:00:1f.2: restoring config space at offset 0x4 (was 0x1, writing 0x2169)
[86626.773703] ata_piix 0000:00:1f.2: restoring config space at offset 0x1 (was 0x2b00000, writing 0x2b00007)
[86626.773745] i801_smbus 0000:00:1f.3: restoring config space at offset 0xf (was 0x300, writing 0x30b)
[86626.773788] i801_smbus 0000:00:1f.3: restoring config space at offset 0x4 (was 0x4, writing 0xa0607004)
[86626.773806] i801_smbus 0000:00:1f.3: restoring config space at offset 0x1 (was 0x2800001, writing 0x2800003)
[86626.773875] pcieport 0000:03:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[86626.773885] pcieport 0000:03:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a070)
[86626.773894] pcieport 0000:03:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[86626.773904] pcieport 0000:03:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x670403)
[86626.773918] pcieport 0000:03:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[86626.773930] pcieport 0000:03:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[86626.774036] pcieport 0000:04:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[86626.774046] pcieport 0000:04:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa070a070)
[86626.774056] pcieport 0000:04:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[86626.774065] pcieport 0000:04:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x50504)
[86626.774080] pcieport 0000:04:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[86626.774092] pcieport 0000:04:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[86626.774199] pcieport 0000:04:03.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[86626.774208] pcieport 0000:04:03.0: restoring config space at offset 0x8 (was 0x0, writing 0xa080a080)
[86626.774218] pcieport 0000:04:03.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[86626.774228] pcieport 0000:04:03.0: restoring config space at offset 0x6 (was 0x0, writing 0x360604)
[86626.774242] pcieport 0000:04:03.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[86626.774254] pcieport 0000:04:03.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[86626.774361] pcieport 0000:04:04.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[86626.774371] pcieport 0000:04:04.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a090)
[86626.774380] pcieport 0000:04:04.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[86626.774390] pcieport 0000:04:04.0: restoring config space at offset 0x6 (was 0x0, writing 0x673704)
[86626.774404] pcieport 0000:04:04.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[86626.774416] pcieport 0000:04:04.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[86626.774516] pci 0000:05:00.0: restoring config space at offset 0xf (was 0x1ff, writing 0x10b)
[86626.774550] pci 0000:05:00.0: restoring config space at offset 0x5 (was 0x0, writing 0xa0740000)
[86626.774560] pci 0000:05:00.0: restoring config space at offset 0x4 (was 0x0, writing 0xa0700000)
[86626.774571] pci 0000:05:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[86626.774583] pci 0000:05:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[86626.774738] brcmsmac 0000:02:00.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[86626.774811] brcmsmac 0000:02:00.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0400004)
[86626.774827] brcmsmac 0000:02:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[86626.774849] brcmsmac 0000:02:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[86626.775571] PM: early resume of devices complete after 3.735 msecs
[86626.775943] i915 0000:00:02.0: setting latency timer to 64
[86626.776109] mei 0000:00:16.0: irq 45 for MSI/MSI-X
[86626.776454] uhci_hcd 0000:00:1a.0: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[86626.776475] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[86626.776483] ehci_hcd 0000:00:1a.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[86626.776502] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[86626.776521] usb usb3: root hub lost power or was reset
[86626.776574] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[86626.776590] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[86626.776644] uhci_hcd 0000:00:1d.0: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[86626.776667] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[86626.776715] usb usb4: root hub lost power or was reset
[86626.776727] snd_hda_intel 0000:00:1b.0: irq 46 for MSI/MSI-X
[86626.776751] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[86626.776766] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[86626.776879] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[86626.776890] ata_piix 0000:00:1f.2: setting latency timer to 64
[86626.777028] brcmsmac 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[86626.777050] brcmsmac 0000:02:00.0: setting latency timer to 64
[86626.780243] sd 0:0:0:0: [sda] Starting disk
[86626.920418] Extended CMOS year: 2000
[86627.796727] ata2.00: failed to resume link (SControl 0)
[86628.116228] ata1.01: failed to resume link (SControl 0)
[86628.269419] ata1.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[86628.269438] ata1.01: SATA link down (SStatus 0 SControl 0)
[86628.276296] ata1.00: ACPI cmd ef/03:46:00:00:00:a0 (SET FEATURES) filtered out
[86628.283110] ata1.00: configured for UDMA/133
[86628.707396] PM: resume of devices complete after 1934.753 msecs
[86628.710209] PM: Finishing wakeup.
[86628.710214] Restarting tasks ... done.
[86628.769018] video LNXVIDEO:00: Restoring backlight state
[86628.785300] usb 2-1.2: new high-speed USB device number 6 using ehci_hcd
[86628.818411] ata2.01: failed to resume link (SControl 0)
[86628.831220] ata2.00: SATA link down (SStatus 4 SControl 0)
[86628.831243] ata2.01: SATA link down (SStatus 0 SControl 0)
[86629.206951] asix 2-1.2:1.0: eth0: register 'asix' at usb-0000:00:1d.7-1.2, ASIX AX88178 USB 2.0 Ethernet, 00:11:6b:73:91:ff
[86631.193769] EXT4-fs (sda4): re-mounted. Opts: commit=0
[86663.399116] ADDRCONF(NETDEV_UP): eth0: link is not ready
[86666.016539] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[86666.019507] asix 2-1.2:1.0: eth0: link up, 1000Mbps, full-duplex, lpa 0xC5E1
[86671.964829] usb 1-1.3: new high-speed USB device number 13 using ehci_hcd
[86672.248487] scsi6 : usb-storage 1-1.3:1.0
[86676.447498] eth0: no IPv6 routers present
[86679.505820] scsi 6:0:0:0: Direct-Access     Samsung  STORY Station 3  1AJ1 PQ: 0 ANSI: 0
[86679.508072] sd 6:0:0:0: [sdb] 1953525168 512-byte logical blocks: (1.00 TB/931 GiB)
[86679.509431] sd 6:0:0:0: [sdb] Write Protect is off
[86679.509444] sd 6:0:0:0: [sdb] Mode Sense: 23 00 00 00
[86679.510688] sd 6:0:0:0: [sdb] No Caching mode page present
[86679.510696] sd 6:0:0:0: [sdb] Assuming drive cache: write through
[86679.514549] sd 6:0:0:0: [sdb] No Caching mode page present
[86679.514558] sd 6:0:0:0: [sdb] Assuming drive cache: write through
[86679.558104]  sdb: sdb1 sdb2 sdb3 sdb4
[86679.561845] sd 6:0:0:0: [sdb] No Caching mode page present
[86679.561857] sd 6:0:0:0: [sdb] Assuming drive cache: write through
[86679.561867] sd 6:0:0:0: [sdb] Attached SCSI disk
[95979.786095] EXT4-fs (sda4): re-mounted. Opts: commit=0
[95980.400103] PM: Syncing filesystems ... done.
[95980.433773] PM: Preparing system for mem sleep
[95981.926234] Freezing user space processes ... (elapsed 0.01 seconds) done.
[95981.939081] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
[95981.952392] PM: Entering mem sleep
[95981.952456] Suspending console(s) (use no_console_suspend to debug)
[95981.956660] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[95981.958124] sd 0:0:0:0: [sda] Stopping disk
[95981.958877] brcmsmac 0000:02:00.0: PCI INT A disabled
[95981.992404] uhci_hcd 0000:00:1a.0: PCI INT B disabled
[95981.992440] uhci_hcd 0000:00:1d.0: PCI INT B disabled
[95981.995596] ehci_hcd 0000:00:1d.7: PCI INT A disabled
[95982.008907] ehci_hcd 0000:00:1a.7: PCI INT A disabled
[95982.062319] snd_hda_intel 0000:00:1b.0: PCI INT A disabled
[95983.385761] ata_piix 0000:00:1f.2: PCI INT B disabled
[95983.397020] PM: suspend of devices complete after 1445.208 msecs
[95983.398268] ehci_hcd 0000:00:1d.7: PME# enabled
[95983.398296] ehci_hcd 0000:00:1d.7: wake-up capability enabled by ACPI
[95983.410450] ehci_hcd 0000:00:1a.7: PME# enabled
[95983.410480] ehci_hcd 0000:00:1a.7: wake-up capability enabled by ACPI
[95983.436923] PM: late suspend of devices complete after 39.957 msecs
[95983.437706] ACPI: Preparing to enter system sleep state S3
[95983.463527] PM: Saving platform NVS memory
[95983.465171] Disabling non-boot CPUs ...
[95983.569826] CPU 1 is now offline
[95983.574184] CPU 2 is now offline
[95983.679645] CPU 3 is now offline
[95983.679651] lockdep: fixing up alternatives.
[95983.681158] Extended CMOS year: 2000
[95983.682063] ACPI: Low-level resume complete
[95983.682144] PM: Restoring platform NVS memory
[95983.682519] Extended CMOS year: 2000
[95983.682576] Enabling non-boot CPUs ...
[95983.689769] lockdep: fixing up alternatives.
[95983.689781] Booting Node 0 Processor 1 APIC 0x2
[95983.689784] smpboot cpu 1: start_ip = 9a000
[95983.701205] Calibrating delay loop (skipped) already calibrated this CPU
[95983.725441] NMI watchdog enabled, takes one hw-pmu counter.
[95983.729586] CPU1 is up
[95983.742206] lockdep: fixing up alternatives.
[95983.742216] Booting Node 0 Processor 2 APIC 0x1
[95983.742220] smpboot cpu 2: start_ip = 9a000
[95983.753467] Calibrating delay loop (skipped) already calibrated this CPU
[95983.776453] NMI watchdog enabled, takes one hw-pmu counter.
[95983.777343] CPU2 is up
[95983.783961] lockdep: fixing up alternatives.
[95983.783974] Booting Node 0 Processor 3 APIC 0x3
[95983.783978] smpboot cpu 3: start_ip = 9a000
[95983.795440] Calibrating delay loop (skipped) already calibrated this CPU
[95983.822147] NMI watchdog enabled, takes one hw-pmu counter.
[95983.824875] CPU3 is up
[95983.835169] ACPI: Waking up from system sleep state S3
[95984.340426] pcieport 0000:00:01.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[95984.340448] pcieport 0000:00:01.0: restoring config space at offset 0x9 (was 0x1fff1, writing 0xa891a4a1)
[95984.340457] pcieport 0000:00:01.0: restoring config space at offset 0x8 (was 0xfff0, writing 0xa490a070)
[95984.340467] pcieport 0000:00:01.0: restoring config space at offset 0x7 (was 0x200000f0, writing 0x20003030)
[95984.340482] pcieport 0000:00:01.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[95984.340493] pcieport 0000:00:01.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[95984.340564] i915 0000:00:02.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[95984.340596] i915 0000:00:02.0: restoring config space at offset 0x1 (was 0x900007, writing 0x900407)
[95984.340665] mei 0000:00:16.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[95984.340708] mei 0000:00:16.0: restoring config space at offset 0x4 (was 0xfed1b004, writing 0xa0607104)
[95984.340770] uhci_hcd 0000:00:1a.0: restoring config space at offset 0xf (was 0x200, writing 0x20a)
[95984.340799] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x8 (was 0x1, writing 0x2141)
[95984.340830] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[95984.340892] ehci_hcd 0000:00:1a.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[95984.340935] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606c00)
[95984.340953] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[95984.341009] ehci_hcd 0000:00:1a.7: wake-up capability disabled by ACPI
[95984.341023] ehci_hcd 0000:00:1a.7: PME# disabled
[95984.341068] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[95984.341111] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0600004)
[95984.341123] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[95984.341137] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100002)
[95984.341218] pcieport 0000:00:1c.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[95984.341247] pcieport 0000:00:1c.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[95984.341259] pcieport 0000:00:1c.0: restoring config space at offset 0x8 (was 0x0, writing 0xa050a050)
[95984.341271] pcieport 0000:00:1c.0: restoring config space at offset 0x7 (was 0x20000000, writing 0xf0)
[95984.341283] pcieport 0000:00:1c.0: restoring config space at offset 0x6 (was 0x0, writing 0x10100)
[95984.341301] pcieport 0000:00:1c.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[95984.341316] pcieport 0000:00:1c.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[95984.341412] pcieport 0000:00:1c.1: restoring config space at offset 0xf (was 0x200, writing 0x2ff)
[95984.341440] pcieport 0000:00:1c.1: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[95984.341452] pcieport 0000:00:1c.1: restoring config space at offset 0x8 (was 0x0, writing 0xa040a040)
[95984.341464] pcieport 0000:00:1c.1: restoring config space at offset 0x7 (was 0x20000000, writing 0xf0)
[95984.341476] pcieport 0000:00:1c.1: restoring config space at offset 0x6 (was 0x0, writing 0x20200)
[95984.341494] pcieport 0000:00:1c.1: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[95984.341509] pcieport 0000:00:1c.1: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[95984.341582] uhci_hcd 0000:00:1d.0: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[95984.341612] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x8 (was 0x1, writing 0x20e1)
[95984.341642] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[95984.341703] ehci_hcd 0000:00:1d.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[95984.341746] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606800)
[95984.341763] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[95984.341816] ehci_hcd 0000:00:1d.7: wake-up capability disabled by ACPI
[95984.341828] ehci_hcd 0000:00:1d.7: PME# disabled
[95984.341948] ata_piix 0000:00:1f.2: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[95984.341978] ata_piix 0000:00:1f.2: restoring config space at offset 0x8 (was 0x1, writing 0x2061)
[95984.341989] ata_piix 0000:00:1f.2: restoring config space at offset 0x7 (was 0x1, writing 0x2179)
[95984.342001] ata_piix 0000:00:1f.2: restoring config space at offset 0x6 (was 0x1, writing 0x2161)
[95984.342012] ata_piix 0000:00:1f.2: restoring config space at offset 0x5 (was 0x1, writing 0x217d)
[95984.342023] ata_piix 0000:00:1f.2: restoring config space at offset 0x4 (was 0x1, writing 0x2169)
[95984.342041] ata_piix 0000:00:1f.2: restoring config space at offset 0x1 (was 0x2b00000, writing 0x2b00007)
[95984.342084] i801_smbus 0000:00:1f.3: restoring config space at offset 0xf (was 0x300, writing 0x30b)
[95984.342127] i801_smbus 0000:00:1f.3: restoring config space at offset 0x4 (was 0x4, writing 0xa0607004)
[95984.342145] i801_smbus 0000:00:1f.3: restoring config space at offset 0x1 (was 0x2800001, writing 0x2800003)
[95984.342214] pcieport 0000:03:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[95984.342224] pcieport 0000:03:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a070)
[95984.342233] pcieport 0000:03:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[95984.342243] pcieport 0000:03:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x670403)
[95984.342257] pcieport 0000:03:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[95984.342269] pcieport 0000:03:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[95984.342376] pcieport 0000:04:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[95984.342386] pcieport 0000:04:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa070a070)
[95984.342396] pcieport 0000:04:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[95984.342405] pcieport 0000:04:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x50504)
[95984.342420] pcieport 0000:04:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[95984.342432] pcieport 0000:04:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[95984.342539] pcieport 0000:04:03.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[95984.342549] pcieport 0000:04:03.0: restoring config space at offset 0x8 (was 0x0, writing 0xa080a080)
[95984.342559] pcieport 0000:04:03.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[95984.342569] pcieport 0000:04:03.0: restoring config space at offset 0x6 (was 0x0, writing 0x360604)
[95984.342583] pcieport 0000:04:03.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[95984.342595] pcieport 0000:04:03.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[95984.342703] pcieport 0000:04:04.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[95984.342713] pcieport 0000:04:04.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a090)
[95984.342722] pcieport 0000:04:04.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[95984.342732] pcieport 0000:04:04.0: restoring config space at offset 0x6 (was 0x0, writing 0x673704)
[95984.342747] pcieport 0000:04:04.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[95984.342759] pcieport 0000:04:04.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[95984.342858] pci 0000:05:00.0: restoring config space at offset 0xf (was 0x1ff, writing 0x10b)
[95984.342893] pci 0000:05:00.0: restoring config space at offset 0x5 (was 0x0, writing 0xa0740000)
[95984.342903] pci 0000:05:00.0: restoring config space at offset 0x4 (was 0x0, writing 0xa0700000)
[95984.342914] pci 0000:05:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[95984.342927] pci 0000:05:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[95984.343083] brcmsmac 0000:02:00.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[95984.343155] brcmsmac 0000:02:00.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0400004)
[95984.343172] brcmsmac 0000:02:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[95984.343193] brcmsmac 0000:02:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[95984.343949] PM: early resume of devices complete after 3.778 msecs
[95984.344187] i915 0000:00:02.0: setting latency timer to 64
[95984.345202] mei 0000:00:16.0: irq 45 for MSI/MSI-X
[95984.345268] uhci_hcd 0000:00:1a.0: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[95984.345288] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[95984.345335] usb usb3: root hub lost power or was reset
[95984.345362] ehci_hcd 0000:00:1a.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[95984.345384] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[95984.345391] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[95984.345410] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[95984.345496] uhci_hcd 0000:00:1d.0: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[95984.345514] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[95984.345536] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[95984.345556] snd_hda_intel 0000:00:1b.0: irq 46 for MSI/MSI-X
[95984.345561] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[95984.345581] usb usb4: root hub lost power or was reset
[95984.345637] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[95984.345650] ata_piix 0000:00:1f.2: setting latency timer to 64
[95984.345782] brcmsmac 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[95984.345801] brcmsmac 0000:02:00.0: setting latency timer to 64
[95984.348506] sd 0:0:0:0: [sda] Starting disk
[95984.467133] Extended CMOS year: 2000
[95985.365048] ata2.00: failed to resume link (SControl 0)
[95985.684553] ata1.01: failed to resume link (SControl 0)
[95985.837705] ata1.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[95985.837725] ata1.01: SATA link down (SStatus 0 SControl 0)
[95985.844627] ata1.00: ACPI cmd ef/03:46:00:00:00:a0 (SET FEATURES) filtered out
[95985.851371] ata1.00: configured for UDMA/133
[95986.296199] PM: resume of devices complete after 1955.212 msecs
[95986.299217] PM: Finishing wakeup.
[95986.299222] Restarting tasks ... 
[95986.299595] usb 2-1.2: USB disconnect, device number 6
[95986.306071] asix 2-1.2:1.0: eth0: unregister 'asix' usb-0000:00:1d.7-1.2, ASIX AX88178 USB 2.0 Ethernet
[95986.312882] done.
[95986.350984] video LNXVIDEO:00: Restoring backlight state
[95986.386807] ata2.01: failed to resume link (SControl 0)
[95986.398757] ata2.00: SATA link down (SStatus 4 SControl 0)
[95986.398792] ata2.01: SATA link down (SStatus 0 SControl 0)
[95987.606148] usb 1-1.3: USB disconnect, device number 13
[95988.888207] EXT4-fs (sda4): re-mounted. Opts: commit=600
[96697.473294] EXT4-fs (sda4): re-mounted. Opts: commit=0
[96698.168822] PM: Syncing filesystems ... done.
[96698.229892] PM: Preparing system for mem sleep
[96699.705790] Freezing user space processes ... (elapsed 0.01 seconds) done.
[96699.718503] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
[96699.731820] PM: Entering mem sleep
[96699.731926] Suspending console(s) (use no_console_suspend to debug)
[96699.735293] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[96699.736608] sd 0:0:0:0: [sda] Stopping disk
[96699.737891] brcmsmac 0000:02:00.0: PCI INT A disabled
[96699.771891] uhci_hcd 0000:00:1d.0: PCI INT B disabled
[96699.771941] uhci_hcd 0000:00:1a.0: PCI INT B disabled
[96699.778346] ehci_hcd 0000:00:1d.7: PCI INT A disabled
[96699.791665] ehci_hcd 0000:00:1a.7: PCI INT A disabled
[96699.841849] snd_hda_intel 0000:00:1b.0: PCI INT A disabled
[96701.378565] ata_piix 0000:00:1f.2: PCI INT B disabled
[96701.389382] PM: suspend of devices complete after 1658.494 msecs
[96701.390595] ehci_hcd 0000:00:1d.7: PME# enabled
[96701.390625] ehci_hcd 0000:00:1d.7: wake-up capability enabled by ACPI
[96701.402880] ehci_hcd 0000:00:1a.7: PME# enabled
[96701.402910] ehci_hcd 0000:00:1a.7: wake-up capability enabled by ACPI
[96701.429352] PM: late suspend of devices complete after 40.020 msecs
[96701.430134] ACPI: Preparing to enter system sleep state S3
[96701.455960] PM: Saving platform NVS memory
[96701.457077] Disabling non-boot CPUs ...
[96701.562248] CPU 1 is now offline
[96701.567015] CPU 2 is now offline
[96701.672071] CPU 3 is now offline
[96701.672076] lockdep: fixing up alternatives.
[96701.673102] Extended CMOS year: 2000
[96701.674007] ACPI: Low-level resume complete
[96701.674088] PM: Restoring platform NVS memory
[96701.674466] Extended CMOS year: 2000
[96701.674522] Enabling non-boot CPUs ...
[96701.678259] lockdep: fixing up alternatives.
[96701.678271] Booting Node 0 Processor 1 APIC 0x2
[96701.678274] smpboot cpu 1: start_ip = 9a000
[96701.689683] Calibrating delay loop (skipped) already calibrated this CPU
[96701.712887] NMI watchdog enabled, takes one hw-pmu counter.
[96701.717026] CPU1 is up
[96701.717330] lockdep: fixing up alternatives.
[96701.717340] Booting Node 0 Processor 2 APIC 0x1
[96701.717343] smpboot cpu 2: start_ip = 9a000
[96701.728597] Calibrating delay loop (skipped) already calibrated this CPU
[96701.751090] NMI watchdog enabled, takes one hw-pmu counter.
[96701.751858] CPU2 is up
[96701.758886] lockdep: fixing up alternatives.
[96701.758900] Booting Node 0 Processor 3 APIC 0x3
[96701.758904] smpboot cpu 3: start_ip = 9a000
[96701.770318] Calibrating delay loop (skipped) already calibrated this CPU
[96701.795207] NMI watchdog enabled, takes one hw-pmu counter.
[96701.798166] CPU3 is up
[96701.808207] ACPI: Waking up from system sleep state S3
[96702.309534] pcieport 0000:00:01.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[96702.309556] pcieport 0000:00:01.0: restoring config space at offset 0x9 (was 0x1fff1, writing 0xa891a4a1)
[96702.309566] pcieport 0000:00:01.0: restoring config space at offset 0x8 (was 0xfff0, writing 0xa490a070)
[96702.309575] pcieport 0000:00:01.0: restoring config space at offset 0x7 (was 0x200000f0, writing 0x3030)
[96702.309590] pcieport 0000:00:01.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[96702.309600] pcieport 0000:00:01.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[96702.309672] i915 0000:00:02.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[96702.309705] i915 0000:00:02.0: restoring config space at offset 0x1 (was 0x900007, writing 0x900407)
[96702.309773] mei 0000:00:16.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[96702.309816] mei 0000:00:16.0: restoring config space at offset 0x4 (was 0xfed1b004, writing 0xa0607104)
[96702.309877] uhci_hcd 0000:00:1a.0: restoring config space at offset 0xf (was 0x200, writing 0x20a)
[96702.309907] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x8 (was 0x1, writing 0x2141)
[96702.309938] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[96702.309999] ehci_hcd 0000:00:1a.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[96702.310042] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606c00)
[96702.310060] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[96702.310115] ehci_hcd 0000:00:1a.7: wake-up capability disabled by ACPI
[96702.310129] ehci_hcd 0000:00:1a.7: PME# disabled
[96702.310174] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[96702.310217] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0600004)
[96702.310228] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[96702.310243] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100002)
[96702.310324] pcieport 0000:00:1c.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[96702.310352] pcieport 0000:00:1c.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[96702.310364] pcieport 0000:00:1c.0: restoring config space at offset 0x8 (was 0x0, writing 0xa050a050)
[96702.310376] pcieport 0000:00:1c.0: restoring config space at offset 0x7 (was 0x20000000, writing 0x200000f0)
[96702.310388] pcieport 0000:00:1c.0: restoring config space at offset 0x6 (was 0x0, writing 0x10100)
[96702.310406] pcieport 0000:00:1c.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[96702.310421] pcieport 0000:00:1c.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[96702.310517] pcieport 0000:00:1c.1: restoring config space at offset 0xf (was 0x200, writing 0x2ff)
[96702.310545] pcieport 0000:00:1c.1: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[96702.310557] pcieport 0000:00:1c.1: restoring config space at offset 0x8 (was 0x0, writing 0xa040a040)
[96702.310569] pcieport 0000:00:1c.1: restoring config space at offset 0x7 (was 0x20000000, writing 0x200000f0)
[96702.310581] pcieport 0000:00:1c.1: restoring config space at offset 0x6 (was 0x0, writing 0x20200)
[96702.310599] pcieport 0000:00:1c.1: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[96702.310614] pcieport 0000:00:1c.1: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[96702.310685] uhci_hcd 0000:00:1d.0: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[96702.310715] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x8 (was 0x1, writing 0x20e1)
[96702.310746] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[96702.310806] ehci_hcd 0000:00:1d.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[96702.310848] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606800)
[96702.310866] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[96702.310918] ehci_hcd 0000:00:1d.7: wake-up capability disabled by ACPI
[96702.310930] ehci_hcd 0000:00:1d.7: PME# disabled
[96702.311050] ata_piix 0000:00:1f.2: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[96702.311080] ata_piix 0000:00:1f.2: restoring config space at offset 0x8 (was 0x1, writing 0x2061)
[96702.311091] ata_piix 0000:00:1f.2: restoring config space at offset 0x7 (was 0x1, writing 0x2179)
[96702.311102] ata_piix 0000:00:1f.2: restoring config space at offset 0x6 (was 0x1, writing 0x2161)
[96702.311114] ata_piix 0000:00:1f.2: restoring config space at offset 0x5 (was 0x1, writing 0x217d)
[96702.311125] ata_piix 0000:00:1f.2: restoring config space at offset 0x4 (was 0x1, writing 0x2169)
[96702.311143] ata_piix 0000:00:1f.2: restoring config space at offset 0x1 (was 0x2b00000, writing 0x2b00007)
[96702.311185] i801_smbus 0000:00:1f.3: restoring config space at offset 0xf (was 0x300, writing 0x30b)
[96702.311228] i801_smbus 0000:00:1f.3: restoring config space at offset 0x4 (was 0x4, writing 0xa0607004)
[96702.311246] i801_smbus 0000:00:1f.3: restoring config space at offset 0x1 (was 0x2800001, writing 0x2800003)
[96702.311315] pcieport 0000:03:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[96702.311325] pcieport 0000:03:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a070)
[96702.311335] pcieport 0000:03:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[96702.311344] pcieport 0000:03:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x670403)
[96702.311359] pcieport 0000:03:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[96702.311370] pcieport 0000:03:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[96702.311478] pcieport 0000:04:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[96702.311488] pcieport 0000:04:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa070a070)
[96702.311497] pcieport 0000:04:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[96702.311507] pcieport 0000:04:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x50504)
[96702.311521] pcieport 0000:04:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[96702.311534] pcieport 0000:04:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[96702.311641] pcieport 0000:04:03.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[96702.311651] pcieport 0000:04:03.0: restoring config space at offset 0x8 (was 0x0, writing 0xa080a080)
[96702.311661] pcieport 0000:04:03.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[96702.311671] pcieport 0000:04:03.0: restoring config space at offset 0x6 (was 0x0, writing 0x360604)
[96702.311685] pcieport 0000:04:03.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[96702.311697] pcieport 0000:04:03.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[96702.311805] pcieport 0000:04:04.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[96702.311815] pcieport 0000:04:04.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a090)
[96702.311824] pcieport 0000:04:04.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[96702.311834] pcieport 0000:04:04.0: restoring config space at offset 0x6 (was 0x0, writing 0x673704)
[96702.311849] pcieport 0000:04:04.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[96702.311861] pcieport 0000:04:04.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[96702.311960] pci 0000:05:00.0: restoring config space at offset 0xf (was 0x1ff, writing 0x10b)
[96702.311995] pci 0000:05:00.0: restoring config space at offset 0x5 (was 0x0, writing 0xa0740000)
[96702.312005] pci 0000:05:00.0: restoring config space at offset 0x4 (was 0x0, writing 0xa0700000)
[96702.312015] pci 0000:05:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[96702.312028] pci 0000:05:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[96702.312182] brcmsmac 0000:02:00.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[96702.312255] brcmsmac 0000:02:00.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0400004)
[96702.312271] brcmsmac 0000:02:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[96702.312293] brcmsmac 0000:02:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[96702.313013] PM: early resume of devices complete after 3.732 msecs
[96702.313228] i915 0000:00:02.0: setting latency timer to 64
[96702.314229] mei 0000:00:16.0: irq 45 for MSI/MSI-X
[96702.314290] uhci_hcd 0000:00:1a.0: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[96702.314311] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[96702.314322] ehci_hcd 0000:00:1a.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[96702.314340] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[96702.314357] usb usb3: root hub lost power or was reset
[96702.314411] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[96702.314429] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[96702.314502] uhci_hcd 0000:00:1d.0: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[96702.314524] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[96702.314562] snd_hda_intel 0000:00:1b.0: irq 46 for MSI/MSI-X
[96702.314568] usb usb4: root hub lost power or was reset
[96702.314612] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[96702.314630] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[96702.314750] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[96702.314764] ata_piix 0000:00:1f.2: setting latency timer to 64
[96702.314881] brcmsmac 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[96702.314900] brcmsmac 0000:02:00.0: setting latency timer to 64
[96702.317669] sd 0:0:0:0: [sda] Starting disk
[96702.474893] Extended CMOS year: 2000
[96703.334178] ata2.00: failed to resume link (SControl 0)
[96703.653681] ata1.01: failed to resume link (SControl 0)
[96703.806856] ata1.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[96703.806876] ata1.01: SATA link down (SStatus 0 SControl 0)
[96703.813748] ata1.00: ACPI cmd ef/03:46:00:00:00:a0 (SET FEATURES) filtered out
[96703.820560] ata1.00: configured for UDMA/133
[96704.284932] PM: resume of devices complete after 1974.918 msecs
[96704.287912] PM: Finishing wakeup.
[96704.287917] Restarting tasks ... done.
[96704.342658] video LNXVIDEO:00: Restoring backlight state
[96704.355889] ata2.01: failed to resume link (SControl 0)
[96704.367809] ata2.00: SATA link down (SStatus 4 SControl 0)
[96704.367837] ata2.01: SATA link down (SStatus 0 SControl 0)
[96705.841756] EXT4-fs (sda4): re-mounted. Opts: commit=0
[96813.702383] usb 2-1.2: new high-speed USB device number 7 using ehci_hcd
[96814.123933] asix 2-1.2:1.0: eth0: register 'asix' at usb-0000:00:1d.7-1.2, ASIX AX88178 USB 2.0 Ethernet, 00:11:6b:73:91:ff
[96824.546791] ADDRCONF(NETDEV_UP): eth0: link is not ready
[96827.181443] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[96827.183962] asix 2-1.2:1.0: eth0: link up, 1000Mbps, full-duplex, lpa 0xC5E1
[96837.961010] eth0: no IPv6 routers present
[103086.791061] EXT4-fs (sda4): re-mounted. Opts: commit=0
[103087.246202] PM: Syncing filesystems ... done.
[103087.297777] PM: Preparing system for mem sleep
[103088.560214] Freezing user space processes ... (elapsed 0.01 seconds) done.
[103088.573249] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
[103088.586565] PM: Entering mem sleep
[103088.586613] Suspending console(s) (use no_console_suspend to debug)
[103088.589391] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[103088.590670] sd 0:0:0:0: [sda] Stopping disk
[103088.591457] brcmsmac 0000:02:00.0: PCI INT A disabled
[103088.626685] uhci_hcd 0000:00:1a.0: PCI INT B disabled
[103088.626741] uhci_hcd 0000:00:1d.0: PCI INT B disabled
[103088.629821] ehci_hcd 0000:00:1d.7: PCI INT A disabled
[103088.639851] ehci_hcd 0000:00:1a.7: PCI INT A disabled
[103088.693291] snd_hda_intel 0000:00:1b.0: PCI INT A disabled
[103090.196221] ata_piix 0000:00:1f.2: PCI INT B disabled
[103090.207554] PM: suspend of devices complete after 1622.327 msecs
[103090.208775] ehci_hcd 0000:00:1d.7: PME# enabled
[103090.208805] ehci_hcd 0000:00:1d.7: wake-up capability enabled by ACPI
[103090.221106] ehci_hcd 0000:00:1a.7: PME# enabled
[103090.221136] ehci_hcd 0000:00:1a.7: wake-up capability enabled by ACPI
[103090.247574] PM: late suspend of devices complete after 40.075 msecs
[103090.248357] ACPI: Preparing to enter system sleep state S3
[103090.274179] PM: Saving platform NVS memory
[103090.275699] Disabling non-boot CPUs ...
[103090.279194] CPU 1 is now offline
[103090.383775] CPU 2 is now offline
[103090.387290] CPU 3 is now offline
[103090.387295] lockdep: fixing up alternatives.
[103090.388453] Extended CMOS year: 2000
[103090.389363] ACPI: Low-level resume complete
[103090.389444] PM: Restoring platform NVS memory
[103090.389818] Extended CMOS year: 2000
[103090.389875] Enabling non-boot CPUs ...
[103090.393660] lockdep: fixing up alternatives.
[103090.393672] Booting Node 0 Processor 1 APIC 0x2
[103090.393676] smpboot cpu 1: start_ip = 9a000
[103090.405084] Calibrating delay loop (skipped) already calibrated this CPU
[103090.428249] NMI watchdog enabled, takes one hw-pmu counter.
[103090.432534] CPU1 is up
[103090.432953] lockdep: fixing up alternatives.
[103090.432963] Booting Node 0 Processor 2 APIC 0x1
[103090.432967] smpboot cpu 2: start_ip = 9a000
[103090.444250] Calibrating delay loop (skipped) already calibrated this CPU
[103090.467241] NMI watchdog enabled, takes one hw-pmu counter.
[103090.468126] CPU2 is up
[103090.474751] lockdep: fixing up alternatives.
[103090.474765] Booting Node 0 Processor 3 APIC 0x3
[103090.474769] smpboot cpu 3: start_ip = 9a000
[103090.486185] Calibrating delay loop (skipped) already calibrated this CPU
[103090.511839] NMI watchdog enabled, takes one hw-pmu counter.
[103090.514791] CPU3 is up
[103090.525116] ACPI: Waking up from system sleep state S3
[103091.034577] pcieport 0000:00:01.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[103091.034599] pcieport 0000:00:01.0: restoring config space at offset 0x9 (was 0x1fff1, writing 0xa891a4a1)
[103091.034609] pcieport 0000:00:01.0: restoring config space at offset 0x8 (was 0xfff0, writing 0xa490a070)
[103091.034618] pcieport 0000:00:01.0: restoring config space at offset 0x7 (was 0x200000f0, writing 0x20003030)
[103091.034632] pcieport 0000:00:01.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[103091.034643] pcieport 0000:00:01.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[103091.034715] i915 0000:00:02.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[103091.034747] i915 0000:00:02.0: restoring config space at offset 0x1 (was 0x900007, writing 0x900407)
[103091.034816] mei 0000:00:16.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[103091.034858] mei 0000:00:16.0: restoring config space at offset 0x4 (was 0xfed1b004, writing 0xa0607104)
[103091.034920] uhci_hcd 0000:00:1a.0: restoring config space at offset 0xf (was 0x200, writing 0x20a)
[103091.034950] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x8 (was 0x1, writing 0x2141)
[103091.034980] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[103091.035041] ehci_hcd 0000:00:1a.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[103091.035084] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606c00)
[103091.035102] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[103091.035158] ehci_hcd 0000:00:1a.7: wake-up capability disabled by ACPI
[103091.035171] ehci_hcd 0000:00:1a.7: PME# disabled
[103091.035215] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[103091.035258] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0600004)
[103091.035270] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[103091.035284] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100002)
[103091.035366] pcieport 0000:00:1c.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[103091.035394] pcieport 0000:00:1c.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[103091.035406] pcieport 0000:00:1c.0: restoring config space at offset 0x8 (was 0x0, writing 0xa050a050)
[103091.035418] pcieport 0000:00:1c.0: restoring config space at offset 0x7 (was 0x20000000, writing 0xf0)
[103091.035430] pcieport 0000:00:1c.0: restoring config space at offset 0x6 (was 0x0, writing 0x10100)
[103091.035448] pcieport 0000:00:1c.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[103091.035463] pcieport 0000:00:1c.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[103091.035558] pcieport 0000:00:1c.1: restoring config space at offset 0xf (was 0x200, writing 0x2ff)
[103091.035586] pcieport 0000:00:1c.1: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[103091.035598] pcieport 0000:00:1c.1: restoring config space at offset 0x8 (was 0x0, writing 0xa040a040)
[103091.035610] pcieport 0000:00:1c.1: restoring config space at offset 0x7 (was 0x20000000, writing 0xf0)
[103091.035622] pcieport 0000:00:1c.1: restoring config space at offset 0x6 (was 0x0, writing 0x20200)
[103091.035640] pcieport 0000:00:1c.1: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[103091.035655] pcieport 0000:00:1c.1: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[103091.035728] uhci_hcd 0000:00:1d.0: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[103091.035758] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x8 (was 0x1, writing 0x20e1)
[103091.035788] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[103091.035848] ehci_hcd 0000:00:1d.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[103091.035891] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606800)
[103091.035909] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[103091.035961] ehci_hcd 0000:00:1d.7: wake-up capability disabled by ACPI
[103091.035973] ehci_hcd 0000:00:1d.7: PME# disabled
[103091.036092] ata_piix 0000:00:1f.2: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[103091.036122] ata_piix 0000:00:1f.2: restoring config space at offset 0x8 (was 0x1, writing 0x2061)
[103091.036133] ata_piix 0000:00:1f.2: restoring config space at offset 0x7 (was 0x1, writing 0x2179)
[103091.036145] ata_piix 0000:00:1f.2: restoring config space at offset 0x6 (was 0x1, writing 0x2161)
[103091.036156] ata_piix 0000:00:1f.2: restoring config space at offset 0x5 (was 0x1, writing 0x217d)
[103091.036167] ata_piix 0000:00:1f.2: restoring config space at offset 0x4 (was 0x1, writing 0x2169)
[103091.036185] ata_piix 0000:00:1f.2: restoring config space at offset 0x1 (was 0x2b00000, writing 0x2b00007)
[103091.036228] i801_smbus 0000:00:1f.3: restoring config space at offset 0xf (was 0x300, writing 0x30b)
[103091.036270] i801_smbus 0000:00:1f.3: restoring config space at offset 0x4 (was 0x4, writing 0xa0607004)
[103091.036288] i801_smbus 0000:00:1f.3: restoring config space at offset 0x1 (was 0x2800001, writing 0x2800003)
[103091.036357] pcieport 0000:03:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[103091.036367] pcieport 0000:03:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a070)
[103091.036376] pcieport 0000:03:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[103091.036386] pcieport 0000:03:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x670403)
[103091.036400] pcieport 0000:03:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[103091.036412] pcieport 0000:03:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[103091.036519] pcieport 0000:04:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[103091.036529] pcieport 0000:04:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa070a070)
[103091.036538] pcieport 0000:04:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[103091.036548] pcieport 0000:04:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x50504)
[103091.036563] pcieport 0000:04:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[103091.036575] pcieport 0000:04:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[103091.036681] pcieport 0000:04:03.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[103091.036691] pcieport 0000:04:03.0: restoring config space at offset 0x8 (was 0x0, writing 0xa080a080)
[103091.036701] pcieport 0000:04:03.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[103091.036711] pcieport 0000:04:03.0: restoring config space at offset 0x6 (was 0x0, writing 0x360604)
[103091.036725] pcieport 0000:04:03.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[103091.036737] pcieport 0000:04:03.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[103091.036844] pcieport 0000:04:04.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[103091.036854] pcieport 0000:04:04.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a090)
[103091.036864] pcieport 0000:04:04.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[103091.036873] pcieport 0000:04:04.0: restoring config space at offset 0x6 (was 0x0, writing 0x673704)
[103091.036888] pcieport 0000:04:04.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[103091.036900] pcieport 0000:04:04.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[103091.036999] pci 0000:05:00.0: restoring config space at offset 0xf (was 0x1ff, writing 0x10b)
[103091.037033] pci 0000:05:00.0: restoring config space at offset 0x5 (was 0x0, writing 0xa0740000)
[103091.037044] pci 0000:05:00.0: restoring config space at offset 0x4 (was 0x0, writing 0xa0700000)
[103091.037054] pci 0000:05:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[103091.037067] pci 0000:05:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[103091.037223] brcmsmac 0000:02:00.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[103091.037295] brcmsmac 0000:02:00.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0400004)
[103091.037311] brcmsmac 0000:02:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[103091.037333] brcmsmac 0000:02:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[103091.038064] PM: early resume of devices complete after 3.741 msecs
[103091.038266] i915 0000:00:02.0: setting latency timer to 64
[103091.038418] mei 0000:00:16.0: irq 45 for MSI/MSI-X
[103091.038498] uhci_hcd 0000:00:1a.0: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[103091.038517] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[103091.038564] usb usb3: root hub lost power or was reset
[103091.038615] ehci_hcd 0000:00:1a.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[103091.038634] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[103091.038705] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[103091.038723] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[103091.038808] uhci_hcd 0000:00:1d.0: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[103091.038826] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[103091.038858] snd_hda_intel 0000:00:1b.0: irq 46 for MSI/MSI-X
[103091.038880] usb usb4: root hub lost power or was reset
[103091.038923] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[103091.038942] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[103091.039014] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[103091.039027] ata_piix 0000:00:1f.2: setting latency timer to 64
[103091.039169] brcmsmac 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[103091.039187] brcmsmac 0000:02:00.0: setting latency timer to 64
[103091.041817] sd 0:0:0:0: [sda] Starting disk
[103091.169571] Extended CMOS year: 2000
[103092.059213] ata2.00: failed to resume link (SControl 0)
[103092.378715] ata1.01: failed to resume link (SControl 0)
[103092.531891] ata1.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[103092.531911] ata1.01: SATA link down (SStatus 0 SControl 0)
[103092.538774] ata1.00: ACPI cmd ef/03:46:00:00:00:a0 (SET FEATURES) filtered out
[103092.545626] ata1.00: configured for UDMA/133
[103092.960308] PM: resume of devices complete after 1925.162 msecs
[103092.963320] PM: Finishing wakeup.
[103092.963325] Restarting tasks ... 
[103092.963865] usb 2-1.2: USB disconnect, device number 7
[103092.965800] asix 2-1.2:1.0: eth0: unregister 'asix' usb-0000:00:1d.7-1.2, ASIX AX88178 USB 2.0 Ethernet
[103092.977451] done.
[103093.006792] video LNXVIDEO:00: Restoring backlight state
[103093.080904] ata2.01: failed to resume link (SControl 0)
[103093.094308] ata2.00: SATA link down (SStatus 4 SControl 0)
[103093.094341] ata2.01: SATA link down (SStatus 0 SControl 0)
[103094.549316] EXT4-fs (sda4): re-mounted. Opts: commit=600
[103096.865210] usb 2-1.2: new high-speed USB device number 8 using ehci_hcd
[103096.965075] scsi7 : usb-storage 2-1.2:1.0
[103096.966129] cdc_acm 2-1.2:1.1: This device cannot do calls on its own. It is not a modem.
[103096.966324] cdc_acm 2-1.2:1.1: ttyACM0: USB ACM device
[103097.965033] scsi 7:0:0:0: Direct-Access     Android    UMS Composite    00 PQ: 0 ANSI: 2
[103097.967152] scsi 7:0:0:1: Direct-Access     Android    UMS Composite    00 PQ: 0 ANSI: 2
[103097.972870] sd 7:0:0:0: [sdb] Attached SCSI removable disk
[103097.974492] sd 7:0:0:1: [sdc] Attached SCSI removable disk
[103165.676884] usb 2-1.2: USB disconnect, device number 8
[103165.887762] usb 2-1.2: new high-speed USB device number 9 using ehci_hcd
[103166.229673] usbcore: registered new interface driver cdc_ether
[103166.235906] rndis_host 2-1.2:1.0: usb0: register 'rndis_host' at usb-0000:00:1d.7-1.2, RNDIS device, 4a:22:d8:93:a6:ee
[103166.235993] usbcore: registered new interface driver rndis_host
[103166.240494] usbcore: registered new interface driver rndis_wlan
[103189.677052] usb0: no IPv6 routers present
[104426.221581] tun: Universal TUN/TAP device driver, 1.6
[104426.221591] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[107750.842299] applesmc: light sensor data length set to 10
[108729.532274] EXT4-fs (sda4): re-mounted. Opts: commit=0
[108730.387537] PM: Syncing filesystems ... done.
[108730.513992] PM: Preparing system for mem sleep
[108731.787461] Freezing user space processes ... (elapsed 0.01 seconds) done.
[108731.800137] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
[108731.813456] PM: Entering mem sleep
[108731.813519] Suspending console(s) (use no_console_suspend to debug)
[108731.817593] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[108731.818951] sd 0:0:0:0: [sda] Stopping disk
[108731.819845] brcmsmac 0000:02:00.0: PCI INT A disabled
[108731.853490] uhci_hcd 0000:00:1a.0: PCI INT B disabled
[108731.853528] uhci_hcd 0000:00:1d.0: PCI INT B disabled
[108731.856691] ehci_hcd 0000:00:1d.7: PCI INT A disabled
[108731.899959] ehci_hcd 0000:00:1a.7: PCI INT A disabled
[108731.923479] snd_hda_intel 0000:00:1b.0: PCI INT A disabled
[108733.422838] ata_piix 0000:00:1f.2: PCI INT B disabled
[108733.434379] PM: suspend of devices complete after 1621.809 msecs
[108733.435605] ehci_hcd 0000:00:1d.7: PME# enabled
[108733.435635] ehci_hcd 0000:00:1d.7: wake-up capability enabled by ACPI
[108733.447933] ehci_hcd 0000:00:1a.7: PME# enabled
[108733.447963] ehci_hcd 0000:00:1a.7: wake-up capability enabled by ACPI
[108733.474407] PM: late suspend of devices complete after 40.080 msecs
[108733.475190] ACPI: Preparing to enter system sleep state S3
[108733.501016] PM: Saving platform NVS memory
[108733.502400] Disabling non-boot CPUs ...
[108733.607307] CPU 1 is now offline
[108733.612233] CPU 2 is now offline
[108733.717107] CPU 3 is now offline
[108733.717112] lockdep: fixing up alternatives.
[108733.718196] Extended CMOS year: 2000
[108733.719102] ACPI: Low-level resume complete
[108733.719183] PM: Restoring platform NVS memory
[108733.719560] Extended CMOS year: 2000
[108733.719617] Enabling non-boot CPUs ...
[108733.726795] lockdep: fixing up alternatives.
[108733.726807] Booting Node 0 Processor 1 APIC 0x2
[108733.726810] smpboot cpu 1: start_ip = 9a000
[108733.738221] Calibrating delay loop (skipped) already calibrated this CPU
[108733.761375] NMI watchdog enabled, takes one hw-pmu counter.
[108733.765534] CPU1 is up
[108733.765821] lockdep: fixing up alternatives.
[108733.765830] Booting Node 0 Processor 2 APIC 0x1
[108733.765834] smpboot cpu 2: start_ip = 9a000
[108733.776853] Calibrating delay loop (skipped) already calibrated this CPU
[108733.799885] NMI watchdog enabled, takes one hw-pmu counter.
[108733.800764] CPU2 is up
[108733.808068] lockdep: fixing up alternatives.
[108733.808082] Booting Node 0 Processor 3 APIC 0x3
[108733.808086] smpboot cpu 3: start_ip = 9a000
[108733.819404] Calibrating delay loop (skipped) already calibrated this CPU
[108733.844467] NMI watchdog enabled, takes one hw-pmu counter.
[108733.847321] CPU3 is up
[108733.857391] ACPI: Waking up from system sleep state S3
[108734.357912] pcieport 0000:00:01.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[108734.357935] pcieport 0000:00:01.0: restoring config space at offset 0x9 (was 0x1fff1, writing 0xa891a4a1)
[108734.357944] pcieport 0000:00:01.0: restoring config space at offset 0x8 (was 0xfff0, writing 0xa490a070)
[108734.357954] pcieport 0000:00:01.0: restoring config space at offset 0x7 (was 0x200000f0, writing 0x3030)
[108734.357968] pcieport 0000:00:01.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[108734.357979] pcieport 0000:00:01.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[108734.358050] i915 0000:00:02.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[108734.358082] i915 0000:00:02.0: restoring config space at offset 0x1 (was 0x900007, writing 0x900407)
[108734.358151] mei 0000:00:16.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[108734.358194] mei 0000:00:16.0: restoring config space at offset 0x4 (was 0xfed1b004, writing 0xa0607104)
[108734.358255] uhci_hcd 0000:00:1a.0: restoring config space at offset 0xf (was 0x200, writing 0x20a)
[108734.358284] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x8 (was 0x1, writing 0x2141)
[108734.358315] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[108734.358377] ehci_hcd 0000:00:1a.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[108734.358419] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606c00)
[108734.358436] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[108734.358492] ehci_hcd 0000:00:1a.7: wake-up capability disabled by ACPI
[108734.358505] ehci_hcd 0000:00:1a.7: PME# disabled
[108734.358550] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[108734.358593] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0600004)
[108734.358605] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[108734.358619] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100002)
[108734.358700] pcieport 0000:00:1c.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[108734.358728] pcieport 0000:00:1c.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[108734.358740] pcieport 0000:00:1c.0: restoring config space at offset 0x8 (was 0x0, writing 0xa050a050)
[108734.358752] pcieport 0000:00:1c.0: restoring config space at offset 0x7 (was 0x20000000, writing 0x200000f0)
[108734.358763] pcieport 0000:00:1c.0: restoring config space at offset 0x6 (was 0x0, writing 0x10100)
[108734.358782] pcieport 0000:00:1c.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[108734.358797] pcieport 0000:00:1c.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[108734.358892] pcieport 0000:00:1c.1: restoring config space at offset 0xf (was 0x200, writing 0x2ff)
[108734.358920] pcieport 0000:00:1c.1: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[108734.358932] pcieport 0000:00:1c.1: restoring config space at offset 0x8 (was 0x0, writing 0xa040a040)
[108734.358944] pcieport 0000:00:1c.1: restoring config space at offset 0x7 (was 0x20000000, writing 0x200000f0)
[108734.358956] pcieport 0000:00:1c.1: restoring config space at offset 0x6 (was 0x0, writing 0x20200)
[108734.358974] pcieport 0000:00:1c.1: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[108734.358989] pcieport 0000:00:1c.1: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[108734.359061] uhci_hcd 0000:00:1d.0: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[108734.359091] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x8 (was 0x1, writing 0x20e1)
[108734.359121] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[108734.359181] ehci_hcd 0000:00:1d.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[108734.359224] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606800)
[108734.359241] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[108734.359293] ehci_hcd 0000:00:1d.7: wake-up capability disabled by ACPI
[108734.359305] ehci_hcd 0000:00:1d.7: PME# disabled
[108734.359424] ata_piix 0000:00:1f.2: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[108734.359454] ata_piix 0000:00:1f.2: restoring config space at offset 0x8 (was 0x1, writing 0x2061)
[108734.359465] ata_piix 0000:00:1f.2: restoring config space at offset 0x7 (was 0x1, writing 0x2179)
[108734.359476] ata_piix 0000:00:1f.2: restoring config space at offset 0x6 (was 0x1, writing 0x2161)
[108734.359487] ata_piix 0000:00:1f.2: restoring config space at offset 0x5 (was 0x1, writing 0x217d)
[108734.359499] ata_piix 0000:00:1f.2: restoring config space at offset 0x4 (was 0x1, writing 0x2169)
[108734.359516] ata_piix 0000:00:1f.2: restoring config space at offset 0x1 (was 0x2b00000, writing 0x2b00007)
[108734.359559] i801_smbus 0000:00:1f.3: restoring config space at offset 0xf (was 0x300, writing 0x30b)
[108734.359602] i801_smbus 0000:00:1f.3: restoring config space at offset 0x4 (was 0x4, writing 0xa0607004)
[108734.359619] i801_smbus 0000:00:1f.3: restoring config space at offset 0x1 (was 0x2800001, writing 0x2800003)
[108734.359688] pcieport 0000:03:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[108734.359698] pcieport 0000:03:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a070)
[108734.359708] pcieport 0000:03:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[108734.359717] pcieport 0000:03:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x670403)
[108734.359731] pcieport 0000:03:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[108734.359743] pcieport 0000:03:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[108734.359850] pcieport 0000:04:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[108734.359859] pcieport 0000:04:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa070a070)
[108734.359869] pcieport 0000:04:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[108734.359879] pcieport 0000:04:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x50504)
[108734.359893] pcieport 0000:04:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[108734.359906] pcieport 0000:04:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[108734.360012] pcieport 0000:04:03.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[108734.360022] pcieport 0000:04:03.0: restoring config space at offset 0x8 (was 0x0, writing 0xa080a080)
[108734.360032] pcieport 0000:04:03.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[108734.360042] pcieport 0000:04:03.0: restoring config space at offset 0x6 (was 0x0, writing 0x360604)
[108734.360056] pcieport 0000:04:03.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[108734.360069] pcieport 0000:04:03.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[108734.360176] pcieport 0000:04:04.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[108734.360186] pcieport 0000:04:04.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a090)
[108734.360195] pcieport 0000:04:04.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[108734.360205] pcieport 0000:04:04.0: restoring config space at offset 0x6 (was 0x0, writing 0x673704)
[108734.360219] pcieport 0000:04:04.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[108734.360231] pcieport 0000:04:04.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[108734.360331] pci 0000:05:00.0: restoring config space at offset 0xf (was 0x1ff, writing 0x10b)
[108734.360365] pci 0000:05:00.0: restoring config space at offset 0x5 (was 0x0, writing 0xa0740000)
[108734.360375] pci 0000:05:00.0: restoring config space at offset 0x4 (was 0x0, writing 0xa0700000)
[108734.360386] pci 0000:05:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[108734.360398] pci 0000:05:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[108734.360553] brcmsmac 0000:02:00.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[108734.360626] brcmsmac 0000:02:00.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0400004)
[108734.360642] brcmsmac 0000:02:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[108734.360663] brcmsmac 0000:02:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[108734.361397] PM: early resume of devices complete after 3.739 msecs
[108734.361616] i915 0000:00:02.0: setting latency timer to 64
[108734.361629] uhci_hcd 0000:00:1a.0: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[108734.361640] ehci_hcd 0000:00:1a.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[108734.361661] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[108734.361667] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[108734.361718] usb usb3: root hub lost power or was reset
[108734.361778] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[108734.361788] mei 0000:00:16.0: irq 45 for MSI/MSI-X
[108734.361799] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[108734.361871] uhci_hcd 0000:00:1d.0: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[108734.361895] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[108734.361941] usb usb4: root hub lost power or was reset
[108734.361965] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[108734.361972] snd_hda_intel 0000:00:1b.0: irq 46 for MSI/MSI-X
[108734.361982] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[108734.362010] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[108734.362030] ata_piix 0000:00:1f.2: setting latency timer to 64
[108734.362158] brcmsmac 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[108734.362176] brcmsmac 0000:02:00.0: setting latency timer to 64
[108734.365075] sd 0:0:0:0: [sda] Starting disk
[108734.438482] bcm5974: bad trackpad package, length: 8
[108734.613914] usb 2-1.2: reset high-speed USB device number 9 using ehci_hcd
[108734.710551] usb 2-1.2: device firmware changed
[108735.382575] ata2.00: failed to resume link (SControl 0)
[108735.702071] ata1.01: failed to resume link (SControl 0)
[108735.855237] ata1.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[108735.855257] ata1.01: SATA link down (SStatus 0 SControl 0)
[108735.862127] ata1.00: ACPI cmd ef/03:46:00:00:00:a0 (SET FEATURES) filtered out
[108735.868953] ata1.00: configured for UDMA/133
[108736.260410] PM: resume of devices complete after 1901.899 msecs
[108736.263468] PM: Finishing wakeup.
[108736.263473] Restarting tasks ... 
[108736.269566] usb 2-1.2: USB disconnect, device number 9
[108736.270123] rndis_host 2-1.2:1.0: usb0: unregister 'rndis_host' usb-0000:00:1d.7-1.2, RNDIS device
[108736.270131] done.
[108736.305054] video LNXVIDEO:00: Restoring backlight state
[108736.404306] ata2.01: failed to resume link (SControl 0)
[108736.416930] ata2.00: SATA link down (SStatus 4 SControl 0)
[108736.416963] ata2.01: SATA link down (SStatus 0 SControl 0)
[108737.645880] usb 2-1.2: new high-speed USB device number 10 using ehci_hcd
[108737.746389] scsi8 : usb-storage 2-1.2:1.0
[108737.747277] cdc_acm 2-1.2:1.1: This device cannot do calls on its own. It is not a modem.
[108737.747414] cdc_acm 2-1.2:1.1: ttyACM0: USB ACM device
[108737.862637] EXT4-fs (sda4): re-mounted. Opts: commit=600
[108738.744956] scsi 8:0:0:0: Direct-Access     Android    UMS Composite    00 PQ: 0 ANSI: 2
[108738.747831] scsi 8:0:0:1: Direct-Access     Android    UMS Composite    00 PQ: 0 ANSI: 2
[108738.754531] sd 8:0:0:1: [sdc] Attached SCSI removable disk
[108738.758281] sd 8:0:0:0: [sdb] Attached SCSI removable disk
[108758.646970] usb 2-1.2: USB disconnect, device number 10
[108758.856272] usb 2-1.2: new high-speed USB device number 11 using ehci_hcd
[108758.959924] rndis_host 2-1.2:1.0: usb0: register 'rndis_host' at usb-0000:00:1d.7-1.2, RNDIS device, 4a:22:d8:93:a6:ee
[108794.330638] usb0: no IPv6 routers present
[111542.252185] EXT4-fs (sda4): re-mounted. Opts: commit=0
[111542.903568] PM: Syncing filesystems ... done.
[111543.030681] PM: Preparing system for mem sleep
[111543.936250] Freezing user space processes ... (elapsed 0.01 seconds) done.
[111543.948985] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
[111543.962288] PM: Entering mem sleep
[111543.962341] Suspending console(s) (use no_console_suspend to debug)
[111543.964979] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[111543.966289] sd 0:0:0:0: [sda] Stopping disk
[111543.967328] brcmsmac 0000:02:00.0: PCI INT A disabled
[111544.002223] ehci_hcd 0000:00:1d.7: PCI INT A disabled
[111544.002382] uhci_hcd 0000:00:1d.0: PCI INT B disabled
[111544.002458] uhci_hcd 0000:00:1a.0: PCI INT B disabled
[111544.048823] ehci_hcd 0000:00:1a.7: PCI INT A disabled
[111544.068955] snd_hda_intel 0000:00:1b.0: PCI INT A disabled
[111545.595873] ata_piix 0000:00:1f.2: PCI INT B disabled
[111545.606631] PM: suspend of devices complete after 1645.623 msecs
[111545.607858] ehci_hcd 0000:00:1d.7: PME# enabled
[111545.607887] ehci_hcd 0000:00:1d.7: wake-up capability enabled by ACPI
[111545.620086] ehci_hcd 0000:00:1a.7: PME# enabled
[111545.620115] ehci_hcd 0000:00:1a.7: wake-up capability enabled by ACPI
[111545.646558] PM: late suspend of devices complete after 39.983 msecs
[111545.647341] ACPI: Preparing to enter system sleep state S3
[111545.676482] PM: Saving platform NVS memory
[111545.677770] Disabling non-boot CPUs ...
[111545.782785] CPU 1 is now offline
[111545.787706] CPU 2 is now offline
[111545.892583] CPU 3 is now offline
[111545.892589] lockdep: fixing up alternatives.
[111545.893700] Extended CMOS year: 2000
[111545.894606] ACPI: Low-level resume complete
[111545.894687] PM: Restoring platform NVS memory
[111545.895062] Extended CMOS year: 2000
[111545.895119] Enabling non-boot CPUs ...
[111545.902292] lockdep: fixing up alternatives.
[111545.902303] Booting Node 0 Processor 1 APIC 0x2
[111545.902307] smpboot cpu 1: start_ip = 9a000
[111545.913716] Calibrating delay loop (skipped) already calibrated this CPU
[111545.938338] NMI watchdog enabled, takes one hw-pmu counter.
[111545.942463] CPU1 is up
[111545.955542] lockdep: fixing up alternatives.
[111545.955552] Booting Node 0 Processor 2 APIC 0x1
[111545.955556] smpboot cpu 2: start_ip = 9a000
[111545.966833] Calibrating delay loop (skipped) already calibrated this CPU
[111545.989533] NMI watchdog enabled, takes one hw-pmu counter.
[111545.990326] CPU2 is up
[111545.996693] lockdep: fixing up alternatives.
[111545.996707] Booting Node 0 Processor 3 APIC 0x3
[111545.996711] smpboot cpu 3: start_ip = 9a000
[111546.008121] Calibrating delay loop (skipped) already calibrated this CPU
[111546.033812] NMI watchdog enabled, takes one hw-pmu counter.
[111546.036443] CPU3 is up
[111546.046382] ACPI: Waking up from system sleep state S3
[111546.546739] pcieport 0000:00:01.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[111546.546760] pcieport 0000:00:01.0: restoring config space at offset 0x9 (was 0x1fff1, writing 0xa891a4a1)
[111546.546770] pcieport 0000:00:01.0: restoring config space at offset 0x8 (was 0xfff0, writing 0xa490a070)
[111546.546779] pcieport 0000:00:01.0: restoring config space at offset 0x7 (was 0x200000f0, writing 0x20003030)
[111546.546794] pcieport 0000:00:01.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[111546.546805] pcieport 0000:00:01.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[111546.546875] i915 0000:00:02.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[111546.546907] i915 0000:00:02.0: restoring config space at offset 0x1 (was 0x900007, writing 0x900407)
[111546.546976] mei 0000:00:16.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[111546.547018] mei 0000:00:16.0: restoring config space at offset 0x4 (was 0xfed1b004, writing 0xa0607104)
[111546.547079] uhci_hcd 0000:00:1a.0: restoring config space at offset 0xf (was 0x200, writing 0x20a)
[111546.547109] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x8 (was 0x1, writing 0x2141)
[111546.547140] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[111546.547200] ehci_hcd 0000:00:1a.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[111546.547243] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606c00)
[111546.547261] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[111546.547316] ehci_hcd 0000:00:1a.7: wake-up capability disabled by ACPI
[111546.547330] ehci_hcd 0000:00:1a.7: PME# disabled
[111546.547374] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[111546.547417] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0600004)
[111546.547429] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[111546.547443] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100002)
[111546.547525] pcieport 0000:00:1c.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[111546.547552] pcieport 0000:00:1c.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[111546.547564] pcieport 0000:00:1c.0: restoring config space at offset 0x8 (was 0x0, writing 0xa050a050)
[111546.547576] pcieport 0000:00:1c.0: restoring config space at offset 0x7 (was 0x20000000, writing 0xf0)
[111546.547587] pcieport 0000:00:1c.0: restoring config space at offset 0x6 (was 0x0, writing 0x10100)
[111546.547605] pcieport 0000:00:1c.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[111546.547620] pcieport 0000:00:1c.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[111546.547715] pcieport 0000:00:1c.1: restoring config space at offset 0xf (was 0x200, writing 0x2ff)
[111546.547742] pcieport 0000:00:1c.1: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[111546.547754] pcieport 0000:00:1c.1: restoring config space at offset 0x8 (was 0x0, writing 0xa040a040)
[111546.547765] pcieport 0000:00:1c.1: restoring config space at offset 0x7 (was 0x20000000, writing 0xf0)
[111546.547777] pcieport 0000:00:1c.1: restoring config space at offset 0x6 (was 0x0, writing 0x20200)
[111546.547795] pcieport 0000:00:1c.1: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[111546.547810] pcieport 0000:00:1c.1: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[111546.547881] uhci_hcd 0000:00:1d.0: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[111546.547911] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x8 (was 0x1, writing 0x20e1)
[111546.547940] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[111546.548001] ehci_hcd 0000:00:1d.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[111546.548044] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606800)
[111546.548061] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[111546.548113] ehci_hcd 0000:00:1d.7: wake-up capability disabled by ACPI
[111546.548125] ehci_hcd 0000:00:1d.7: PME# disabled
[111546.548243] ata_piix 0000:00:1f.2: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[111546.548273] ata_piix 0000:00:1f.2: restoring config space at offset 0x8 (was 0x1, writing 0x2061)
[111546.548284] ata_piix 0000:00:1f.2: restoring config space at offset 0x7 (was 0x1, writing 0x2179)
[111546.548296] ata_piix 0000:00:1f.2: restoring config space at offset 0x6 (was 0x1, writing 0x2161)
[111546.548307] ata_piix 0000:00:1f.2: restoring config space at offset 0x5 (was 0x1, writing 0x217d)
[111546.548318] ata_piix 0000:00:1f.2: restoring config space at offset 0x4 (was 0x1, writing 0x2169)
[111546.548336] ata_piix 0000:00:1f.2: restoring config space at offset 0x1 (was 0x2b00000, writing 0x2b00007)
[111546.548378] i801_smbus 0000:00:1f.3: restoring config space at offset 0xf (was 0x300, writing 0x30b)
[111546.548421] i801_smbus 0000:00:1f.3: restoring config space at offset 0x4 (was 0x4, writing 0xa0607004)
[111546.548438] i801_smbus 0000:00:1f.3: restoring config space at offset 0x1 (was 0x2800001, writing 0x2800003)
[111546.548507] pcieport 0000:03:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[111546.548517] pcieport 0000:03:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a070)
[111546.548526] pcieport 0000:03:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[111546.548536] pcieport 0000:03:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x670403)
[111546.548550] pcieport 0000:03:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[111546.548562] pcieport 0000:03:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[111546.548667] pcieport 0000:04:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[111546.548677] pcieport 0000:04:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa070a070)
[111546.548687] pcieport 0000:04:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[111546.548697] pcieport 0000:04:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x50504)
[111546.548711] pcieport 0000:04:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[111546.548723] pcieport 0000:04:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[111546.548829] pcieport 0000:04:03.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[111546.548839] pcieport 0000:04:03.0: restoring config space at offset 0x8 (was 0x0, writing 0xa080a080)
[111546.548849] pcieport 0000:04:03.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[111546.548858] pcieport 0000:04:03.0: restoring config space at offset 0x6 (was 0x0, writing 0x360604)
[111546.548873] pcieport 0000:04:03.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[111546.548885] pcieport 0000:04:03.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[111546.548991] pcieport 0000:04:04.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[111546.549001] pcieport 0000:04:04.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a090)
[111546.549011] pcieport 0000:04:04.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[111546.549020] pcieport 0000:04:04.0: restoring config space at offset 0x6 (was 0x0, writing 0x673704)
[111546.549035] pcieport 0000:04:04.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[111546.549047] pcieport 0000:04:04.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[111546.549145] pci 0000:05:00.0: restoring config space at offset 0xf (was 0x1ff, writing 0x10b)
[111546.549179] pci 0000:05:00.0: restoring config space at offset 0x5 (was 0x0, writing 0xa0740000)
[111546.549190] pci 0000:05:00.0: restoring config space at offset 0x4 (was 0x0, writing 0xa0700000)
[111546.549200] pci 0000:05:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[111546.549213] pci 0000:05:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[111546.549369] brcmsmac 0000:02:00.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[111546.549441] brcmsmac 0000:02:00.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0400004)
[111546.549458] brcmsmac 0000:02:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[111546.549479] brcmsmac 0000:02:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[111546.550221] PM: early resume of devices complete after 3.736 msecs
[111546.550518] i915 0000:00:02.0: setting latency timer to 64
[111546.550587] mei 0000:00:16.0: irq 45 for MSI/MSI-X
[111546.550715] uhci_hcd 0000:00:1a.0: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[111546.550733] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[111546.550782] usb usb3: root hub lost power or was reset
[111546.550931] ehci_hcd 0000:00:1a.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[111546.550958] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[111546.551146] uhci_hcd 0000:00:1d.0: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[111546.551162] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[111546.551188] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[111546.551208] usb usb4: root hub lost power or was reset
[111546.551214] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[111546.551483] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[111546.551498] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[111546.551624] snd_hda_intel 0000:00:1b.0: irq 46 for MSI/MSI-X
[111546.551758] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[111546.551774] ata_piix 0000:00:1f.2: setting latency timer to 64
[111546.551782] brcmsmac 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[111546.551797] brcmsmac 0000:02:00.0: setting latency timer to 64
[111546.555763] sd 0:0:0:0: [sda] Starting disk
[111546.668887] Extended CMOS year: 2000
[111546.806139] usb 2-1.2: reset high-speed USB device number 11 using ehci_hcd
[111546.902741] usb 2-1.2: device firmware changed
[111547.571354] ata2.00: failed to resume link (SControl 0)
[111547.890852] ata1.01: failed to resume link (SControl 0)
[111548.044034] ata1.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[111548.044053] ata1.01: SATA link down (SStatus 0 SControl 0)
[111548.051097] ata1.00: ACPI cmd ef/03:46:00:00:00:a0 (SET FEATURES) filtered out
[111548.057767] ata1.00: configured for UDMA/133
[111548.432571] PM: resume of devices complete after 1885.200 msecs
[111548.435608] PM: Finishing wakeup.
[111548.435613] Restarting tasks ... 
[111548.436083] usb 2-1.2: USB disconnect, device number 11
[111548.436730] rndis_host 2-1.2:1.0: usb0: unregister 'rndis_host' usb-0000:00:1d.7-1.2, RNDIS device
[111548.455807] done.
[111548.501577] video LNXVIDEO:00: Restoring backlight state
[111548.593041] ata2.01: failed to resume link (SControl 0)
[111548.605013] ata2.00: SATA link down (SStatus 4 SControl 0)
[111548.605044] ata2.01: SATA link down (SStatus 0 SControl 0)
[111549.821396] usb 2-1.2: new high-speed USB device number 12 using ehci_hcd
[111549.921780] scsi9 : usb-storage 2-1.2:1.0
[111549.922878] cdc_acm 2-1.2:1.1: This device cannot do calls on its own. It is not a modem.
[111549.923006] cdc_acm 2-1.2:1.1: ttyACM0: USB ACM device
[111550.025532] EXT4-fs (sda4): re-mounted. Opts: commit=600
[111550.920772] scsi 9:0:0:0: Direct-Access     Android    UMS Composite    00 PQ: 0 ANSI: 2
[111550.924038] scsi 9:0:0:1: Direct-Access     Android    UMS Composite    00 PQ: 0 ANSI: 2
[111550.925523] sd 9:0:0:0: [sdb] Attached SCSI removable disk
[111550.941860] sd 9:0:0:1: [sdc] Attached SCSI removable disk
[111572.510776] usb 2-1.2: USB disconnect, device number 12
[111572.712486] usb 2-1.2: new high-speed USB device number 13 using ehci_hcd
[111572.816203] rndis_host 2-1.2:1.0: usb0: register 'rndis_host' at usb-0000:00:1d.7-1.2, RNDIS device, 4a:22:d8:93:a6:ee
[111591.452889] usb0: no IPv6 routers present
[116311.091540] EXT4-fs (sda4): re-mounted. Opts: commit=0
[116311.787812] PM: Syncing filesystems ... done.
[116311.898828] PM: Preparing system for mem sleep
[116313.138471] Freezing user space processes ... (elapsed 0.01 seconds) done.
[116313.151203] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
[116313.164518] PM: Entering mem sleep
[116313.164564] Suspending console(s) (use no_console_suspend to debug)
[116313.167201] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[116313.168499] sd 0:0:0:0: [sda] Stopping disk
[116313.169034] brcmsmac 0000:02:00.0: PCI INT A disabled
[116313.204624] uhci_hcd 0000:00:1d.0: PCI INT B disabled
[116313.204637] uhci_hcd 0000:00:1a.0: PCI INT B disabled
[116313.207779] ehci_hcd 0000:00:1d.7: PCI INT A disabled
[116313.251084] ehci_hcd 0000:00:1a.7: PCI INT A disabled
[116313.271233] snd_hda_intel 0000:00:1b.0: PCI INT A disabled
[116314.797681] ata_piix 0000:00:1f.2: PCI INT B disabled
[116314.808938] PM: suspend of devices complete after 1645.767 msecs
[116314.810161] ehci_hcd 0000:00:1d.7: PME# enabled
[116314.810190] ehci_hcd 0000:00:1d.7: wake-up capability enabled by ACPI
[116314.822439] ehci_hcd 0000:00:1a.7: PME# enabled
[116314.822470] ehci_hcd 0000:00:1a.7: wake-up capability enabled by ACPI
[116314.848850] PM: late suspend of devices complete after 39.976 msecs
[116314.849633] ACPI: Preparing to enter system sleep state S3
[116314.875449] PM: Saving platform NVS memory
[116314.876890] Disabling non-boot CPUs ...
[116314.880363] CPU 1 is now offline
[116314.985026] CPU 2 is now offline
[116315.088207] CPU 3 is now offline
[116315.088212] lockdep: fixing up alternatives.
[116315.089342] Extended CMOS year: 2000
[116315.090248] ACPI: Low-level resume complete
[116315.090329] PM: Restoring platform NVS memory
[116315.090707] Extended CMOS year: 2000
[116315.090764] Enabling non-boot CPUs ...
[116315.094556] lockdep: fixing up alternatives.
[116315.094567] Booting Node 0 Processor 1 APIC 0x2
[116315.094571] smpboot cpu 1: start_ip = 9a000
[116315.105980] Calibrating delay loop (skipped) already calibrated this CPU
[116315.129470] NMI watchdog enabled, takes one hw-pmu counter.
[116315.133638] CPU1 is up
[116315.134019] lockdep: fixing up alternatives.
[116315.134029] Booting Node 0 Processor 2 APIC 0x1
[116315.134033] smpboot cpu 2: start_ip = 9a000
[116315.145274] Calibrating delay loop (skipped) already calibrated this CPU
[116315.167924] NMI watchdog enabled, takes one hw-pmu counter.
[116315.168791] CPU2 is up
[116315.175399] lockdep: fixing up alternatives.
[116315.175413] Booting Node 0 Processor 3 APIC 0x3
[116315.175417] smpboot cpu 3: start_ip = 9a000
[116315.186835] Calibrating delay loop (skipped) already calibrated this CPU
[116315.212536] NMI watchdog enabled, takes one hw-pmu counter.
[116315.215832] CPU3 is up
[116315.226206] ACPI: Waking up from system sleep state S3
[116315.732364] pcieport 0000:00:01.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[116315.732386] pcieport 0000:00:01.0: restoring config space at offset 0x9 (was 0x1fff1, writing 0xa891a4a1)
[116315.732395] pcieport 0000:00:01.0: restoring config space at offset 0x8 (was 0xfff0, writing 0xa490a070)
[116315.732404] pcieport 0000:00:01.0: restoring config space at offset 0x7 (was 0x200000f0, writing 0x3030)
[116315.732419] pcieport 0000:00:01.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[116315.732430] pcieport 0000:00:01.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[116315.732500] i915 0000:00:02.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[116315.732532] i915 0000:00:02.0: restoring config space at offset 0x1 (was 0x900007, writing 0x900407)
[116315.732600] mei 0000:00:16.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[116315.732643] mei 0000:00:16.0: restoring config space at offset 0x4 (was 0xfed1b004, writing 0xa0607104)
[116315.732704] uhci_hcd 0000:00:1a.0: restoring config space at offset 0xf (was 0x200, writing 0x20a)
[116315.732734] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x8 (was 0x1, writing 0x2141)
[116315.732765] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[116315.732826] ehci_hcd 0000:00:1a.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[116315.732869] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606c00)
[116315.732886] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[116315.732942] ehci_hcd 0000:00:1a.7: wake-up capability disabled by ACPI
[116315.732955] ehci_hcd 0000:00:1a.7: PME# disabled
[116315.732999] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[116315.733042] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0600004)
[116315.733054] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[116315.733068] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100002)
[116315.733150] pcieport 0000:00:1c.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[116315.733179] pcieport 0000:00:1c.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[116315.733191] pcieport 0000:00:1c.0: restoring config space at offset 0x8 (was 0x0, writing 0xa050a050)
[116315.733203] pcieport 0000:00:1c.0: restoring config space at offset 0x7 (was 0x20000000, writing 0x200000f0)
[116315.733215] pcieport 0000:00:1c.0: restoring config space at offset 0x6 (was 0x0, writing 0x10100)
[116315.733233] pcieport 0000:00:1c.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[116315.733248] pcieport 0000:00:1c.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[116315.733342] pcieport 0000:00:1c.1: restoring config space at offset 0xf (was 0x200, writing 0x2ff)
[116315.733370] pcieport 0000:00:1c.1: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[116315.733382] pcieport 0000:00:1c.1: restoring config space at offset 0x8 (was 0x0, writing 0xa040a040)
[116315.733394] pcieport 0000:00:1c.1: restoring config space at offset 0x7 (was 0x20000000, writing 0x200000f0)
[116315.733406] pcieport 0000:00:1c.1: restoring config space at offset 0x6 (was 0x0, writing 0x20200)
[116315.733423] pcieport 0000:00:1c.1: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[116315.733439] pcieport 0000:00:1c.1: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[116315.733509] uhci_hcd 0000:00:1d.0: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[116315.733539] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x8 (was 0x1, writing 0x20e1)
[116315.733570] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[116315.733630] ehci_hcd 0000:00:1d.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[116315.733673] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606800)
[116315.733690] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[116315.733742] ehci_hcd 0000:00:1d.7: wake-up capability disabled by ACPI
[116315.733754] ehci_hcd 0000:00:1d.7: PME# disabled
[116315.733872] ata_piix 0000:00:1f.2: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[116315.733902] ata_piix 0000:00:1f.2: restoring config space at offset 0x8 (was 0x1, writing 0x2061)
[116315.733913] ata_piix 0000:00:1f.2: restoring config space at offset 0x7 (was 0x1, writing 0x2179)
[116315.733924] ata_piix 0000:00:1f.2: restoring config space at offset 0x6 (was 0x1, writing 0x2161)
[116315.733936] ata_piix 0000:00:1f.2: restoring config space at offset 0x5 (was 0x1, writing 0x217d)
[116315.733947] ata_piix 0000:00:1f.2: restoring config space at offset 0x4 (was 0x1, writing 0x2169)
[116315.733965] ata_piix 0000:00:1f.2: restoring config space at offset 0x1 (was 0x2b00000, writing 0x2b00007)
[116315.734007] i801_smbus 0000:00:1f.3: restoring config space at offset 0xf (was 0x300, writing 0x30b)
[116315.734050] i801_smbus 0000:00:1f.3: restoring config space at offset 0x4 (was 0x4, writing 0xa0607004)
[116315.734067] i801_smbus 0000:00:1f.3: restoring config space at offset 0x1 (was 0x2800001, writing 0x2800003)
[116315.734136] pcieport 0000:03:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[116315.734145] pcieport 0000:03:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a070)
[116315.734155] pcieport 0000:03:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[116315.734164] pcieport 0000:03:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x670403)
[116315.734178] pcieport 0000:03:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[116315.734190] pcieport 0000:03:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[116315.734296] pcieport 0000:04:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[116315.734306] pcieport 0000:04:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa070a070)
[116315.734316] pcieport 0000:04:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[116315.734325] pcieport 0000:04:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x50504)
[116315.734340] pcieport 0000:04:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[116315.734352] pcieport 0000:04:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[116315.734458] pcieport 0000:04:03.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[116315.734468] pcieport 0000:04:03.0: restoring config space at offset 0x8 (was 0x0, writing 0xa080a080)
[116315.734477] pcieport 0000:04:03.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[116315.734487] pcieport 0000:04:03.0: restoring config space at offset 0x6 (was 0x0, writing 0x360604)
[116315.734501] pcieport 0000:04:03.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[116315.734513] pcieport 0000:04:03.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[116315.734620] pcieport 0000:04:04.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[116315.734630] pcieport 0000:04:04.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a090)
[116315.734640] pcieport 0000:04:04.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[116315.734649] pcieport 0000:04:04.0: restoring config space at offset 0x6 (was 0x0, writing 0x673704)
[116315.734663] pcieport 0000:04:04.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[116315.734676] pcieport 0000:04:04.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[116315.734774] pci 0000:05:00.0: restoring config space at offset 0xf (was 0x1ff, writing 0x10b)
[116315.734808] pci 0000:05:00.0: restoring config space at offset 0x5 (was 0x0, writing 0xa0740000)
[116315.734818] pci 0000:05:00.0: restoring config space at offset 0x4 (was 0x0, writing 0xa0700000)
[116315.734829] pci 0000:05:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[116315.734841] pci 0000:05:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[116315.734997] brcmsmac 0000:02:00.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[116315.735070] brcmsmac 0000:02:00.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0400004)
[116315.735086] brcmsmac 0000:02:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[116315.735108] brcmsmac 0000:02:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[116315.735848] PM: early resume of devices complete after 3.736 msecs
[116315.736064] i915 0000:00:02.0: setting latency timer to 64
[116315.736088] uhci_hcd 0000:00:1a.0: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[116315.736115] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[116315.736165] usb usb3: root hub lost power or was reset
[116315.736213] ehci_hcd 0000:00:1a.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[116315.736223] mei 0000:00:16.0: irq 45 for MSI/MSI-X
[116315.736231] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[116315.736303] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[116315.736322] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[116315.736398] uhci_hcd 0000:00:1d.0: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[116315.736420] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[116315.736458] snd_hda_intel 0000:00:1b.0: irq 46 for MSI/MSI-X
[116315.736463] usb usb4: root hub lost power or was reset
[116315.736507] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[116315.736525] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[116315.736643] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[116315.736658] ata_piix 0000:00:1f.2: setting latency timer to 64
[116315.736747] brcmsmac 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[116315.736767] brcmsmac 0000:02:00.0: setting latency timer to 64
[116315.740121] sd 0:0:0:0: [sda] Starting disk
[116315.905431] Extended CMOS year: 2000
[116316.756987] ata2.00: failed to resume link (SControl 0)
[116317.076490] ata1.01: failed to resume link (SControl 0)
[116317.229671] ata1.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[116317.229691] ata1.01: SATA link down (SStatus 0 SControl 0)
[116317.236617] ata1.00: ACPI cmd ef/03:46:00:00:00:a0 (SET FEATURES) filtered out
[116317.243369] ata1.00: configured for UDMA/133
[116317.671437] PM: resume of devices complete after 1938.526 msecs
[116317.674408] PM: Finishing wakeup.
[116317.674413] Restarting tasks ... done.
[116317.685369] usb 2-1.2: USB disconnect, device number 13
[116317.686708] rndis_host 2-1.2:1.0: usb0: unregister 'rndis_host' usb-0000:00:1d.7-1.2, RNDIS device
[116317.728124] video LNXVIDEO:00: Restoring backlight state
[116317.778667] ata2.01: failed to resume link (SControl 0)
[116317.790646] ata2.00: SATA link down (SStatus 4 SControl 0)
[116317.790676] ata2.01: SATA link down (SStatus 0 SControl 0)
[116319.234837] EXT4-fs (sda4): re-mounted. Opts: commit=0
[116332.296300] usb 2-1.2: new high-speed USB device number 14 using ehci_hcd
[116332.396685] scsi10 : usb-storage 2-1.2:1.0
[116332.397996] cdc_acm 2-1.2:1.1: This device cannot do calls on its own. It is not a modem.
[116332.398127] cdc_acm 2-1.2:1.1: ttyACM0: USB ACM device
[116333.396032] scsi 10:0:0:0: Direct-Access     Android    UMS Composite    00 PQ: 0 ANSI: 2
[116333.398165] scsi 10:0:0:1: Direct-Access     Android    UMS Composite    00 PQ: 0 ANSI: 2
[116333.402738] sd 10:0:0:0: [sdb] Attached SCSI removable disk
[116333.402752] sd 10:0:0:1: [sdc] Attached SCSI removable disk
[116350.756914] usb 2-1.2: USB disconnect, device number 14
[116350.967213] usb 2-1.2: new high-speed USB device number 15 using ehci_hcd
[116351.070370] rndis_host 2-1.2:1.0: usb0: register 'rndis_host' at usb-0000:00:1d.7-1.2, RNDIS device, 4a:22:d8:93:a6:ee
[116368.636110] usb0: no IPv6 routers present
[119833.050838] usb 2-1.2: USB disconnect, device number 15
[119833.051141] rndis_host 2-1.2:1.0: usb0: unregister 'rndis_host' usb-0000:00:1d.7-1.2, RNDIS device
[119860.872574] EXT4-fs (sda4): re-mounted. Opts: commit=0
[119861.470638] PM: Syncing filesystems ... done.
[119861.601178] PM: Preparing system for mem sleep
[119862.861215] Freezing user space processes ... (elapsed 0.01 seconds) done.
[119862.873949] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
[119862.887268] PM: Entering mem sleep
[119862.887327] Suspending console(s) (use no_console_suspend to debug)
[119862.889980] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[119862.891306] sd 0:0:0:0: [sda] Stopping disk
[119862.892212] brcmsmac 0000:02:00.0: PCI INT A disabled
[119862.927195] ehci_hcd 0000:00:1d.7: PCI INT A disabled
[119862.927301] uhci_hcd 0000:00:1a.0: PCI INT B disabled
[119862.927406] uhci_hcd 0000:00:1d.0: PCI INT B disabled
[119862.973795] ehci_hcd 0000:00:1a.7: PCI INT A disabled
[119862.993909] snd_hda_intel 0000:00:1b.0: PCI INT A disabled
[119864.521944] ata_piix 0000:00:1f.2: PCI INT B disabled
[119864.534740] PM: suspend of devices complete after 1648.702 msecs
[119864.535850] ehci_hcd 0000:00:1d.7: PME# enabled
[119864.535876] ehci_hcd 0000:00:1d.7: wake-up capability enabled by ACPI
[119864.548336] ehci_hcd 0000:00:1a.7: PME# enabled
[119864.548363] ehci_hcd 0000:00:1a.7: wake-up capability enabled by ACPI
[119864.574816] PM: late suspend of devices complete after 40.120 msecs
[119864.575520] ACPI: Preparing to enter system sleep state S3
[119864.601435] PM: Saving platform NVS memory
[119864.602676] Disabling non-boot CPUs ...
[119864.605801] CPU 1 is now offline
[119864.711072] CPU 2 is now offline
[119864.814242] CPU 3 is now offline
[119864.814247] lockdep: fixing up alternatives.
[119864.815207] Extended CMOS year: 2000
[119864.816032] ACPI: Low-level resume complete
[119864.816113] PM: Restoring platform NVS memory
[119864.816487] Extended CMOS year: 2000
[119864.816543] Enabling non-boot CPUs ...
[119864.820302] lockdep: fixing up alternatives.
[119864.820313] Booting Node 0 Processor 1 APIC 0x2
[119864.820317] smpboot cpu 1: start_ip = 9a000
[119864.831726] Calibrating delay loop (skipped) already calibrated this CPU
[119864.854629] NMI watchdog enabled, takes one hw-pmu counter.
[119864.858827] CPU1 is up
[119864.866954] lockdep: fixing up alternatives.
[119864.866965] Booting Node 0 Processor 2 APIC 0x1
[119864.866969] smpboot cpu 2: start_ip = 9a000
[119864.878219] Calibrating delay loop (skipped) already calibrated this CPU
[119864.900717] NMI watchdog enabled, takes one hw-pmu counter.
[119864.901603] CPU2 is up
[119864.908295] lockdep: fixing up alternatives.
[119864.908308] Booting Node 0 Processor 3 APIC 0x3
[119864.908312] smpboot cpu 3: start_ip = 9a000
[119864.919730] Calibrating delay loop (skipped) already calibrated this CPU
[119864.944226] NMI watchdog enabled, takes one hw-pmu counter.
[119864.947263] CPU3 is up
[119864.957261] ACPI: Waking up from system sleep state S3
[119865.461650] pcieport 0000:00:01.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[119865.461672] pcieport 0000:00:01.0: restoring config space at offset 0x9 (was 0x1fff1, writing 0xa891a4a1)
[119865.461681] pcieport 0000:00:01.0: restoring config space at offset 0x8 (was 0xfff0, writing 0xa490a070)
[119865.461691] pcieport 0000:00:01.0: restoring config space at offset 0x7 (was 0x200000f0, writing 0x20003030)
[119865.461706] pcieport 0000:00:01.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[119865.461717] pcieport 0000:00:01.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[119865.461789] i915 0000:00:02.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[119865.461821] i915 0000:00:02.0: restoring config space at offset 0x1 (was 0x900007, writing 0x900407)
[119865.461890] mei 0000:00:16.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[119865.461933] mei 0000:00:16.0: restoring config space at offset 0x4 (was 0xfed1b004, writing 0xa0607104)
[119865.461995] uhci_hcd 0000:00:1a.0: restoring config space at offset 0xf (was 0x200, writing 0x20a)
[119865.462025] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x8 (was 0x1, writing 0x2141)
[119865.462055] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[119865.462117] ehci_hcd 0000:00:1a.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[119865.462160] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606c00)
[119865.462178] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[119865.462233] ehci_hcd 0000:00:1a.7: wake-up capability disabled by ACPI
[119865.462247] ehci_hcd 0000:00:1a.7: PME# disabled
[119865.462293] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[119865.462335] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0600004)
[119865.462347] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[119865.462361] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100002)
[119865.462443] pcieport 0000:00:1c.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[119865.462470] pcieport 0000:00:1c.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[119865.462482] pcieport 0000:00:1c.0: restoring config space at offset 0x8 (was 0x0, writing 0xa050a050)
[119865.462494] pcieport 0000:00:1c.0: restoring config space at offset 0x7 (was 0x20000000, writing 0xf0)
[119865.462506] pcieport 0000:00:1c.0: restoring config space at offset 0x6 (was 0x0, writing 0x10100)
[119865.462524] pcieport 0000:00:1c.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[119865.462540] pcieport 0000:00:1c.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[119865.462635] pcieport 0000:00:1c.1: restoring config space at offset 0xf (was 0x200, writing 0x2ff)
[119865.462663] pcieport 0000:00:1c.1: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[119865.462675] pcieport 0000:00:1c.1: restoring config space at offset 0x8 (was 0x0, writing 0xa040a040)
[119865.462687] pcieport 0000:00:1c.1: restoring config space at offset 0x7 (was 0x20000000, writing 0xf0)
[119865.462699] pcieport 0000:00:1c.1: restoring config space at offset 0x6 (was 0x0, writing 0x20200)
[119865.462717] pcieport 0000:00:1c.1: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[119865.462732] pcieport 0000:00:1c.1: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[119865.462804] uhci_hcd 0000:00:1d.0: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[119865.462834] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x8 (was 0x1, writing 0x20e1)
[119865.462865] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[119865.462925] ehci_hcd 0000:00:1d.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[119865.462968] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606800)
[119865.462986] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[119865.463038] ehci_hcd 0000:00:1d.7: wake-up capability disabled by ACPI
[119865.463050] ehci_hcd 0000:00:1d.7: PME# disabled
[119865.463169] ata_piix 0000:00:1f.2: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[119865.463199] ata_piix 0000:00:1f.2: restoring config space at offset 0x8 (was 0x1, writing 0x2061)
[119865.463211] ata_piix 0000:00:1f.2: restoring config space at offset 0x7 (was 0x1, writing 0x2179)
[119865.463222] ata_piix 0000:00:1f.2: restoring config space at offset 0x6 (was 0x1, writing 0x2161)
[119865.463233] ata_piix 0000:00:1f.2: restoring config space at offset 0x5 (was 0x1, writing 0x217d)
[119865.463245] ata_piix 0000:00:1f.2: restoring config space at offset 0x4 (was 0x1, writing 0x2169)
[119865.463262] ata_piix 0000:00:1f.2: restoring config space at offset 0x1 (was 0x2b00000, writing 0x2b00007)
[119865.463305] i801_smbus 0000:00:1f.3: restoring config space at offset 0xf (was 0x300, writing 0x30b)
[119865.463348] i801_smbus 0000:00:1f.3: restoring config space at offset 0x4 (was 0x4, writing 0xa0607004)
[119865.463366] i801_smbus 0000:00:1f.3: restoring config space at offset 0x1 (was 0x2800001, writing 0x2800003)
[119865.463436] pcieport 0000:03:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[119865.463446] pcieport 0000:03:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a070)
[119865.463455] pcieport 0000:03:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[119865.463465] pcieport 0000:03:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x670403)
[119865.463479] pcieport 0000:03:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[119865.463491] pcieport 0000:03:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[119865.463598] pcieport 0000:04:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[119865.463608] pcieport 0000:04:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa070a070)
[119865.463618] pcieport 0000:04:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[119865.463628] pcieport 0000:04:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x50504)
[119865.463642] pcieport 0000:04:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[119865.463654] pcieport 0000:04:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[119865.463762] pcieport 0000:04:03.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[119865.463772] pcieport 0000:04:03.0: restoring config space at offset 0x8 (was 0x0, writing 0xa080a080)
[119865.463782] pcieport 0000:04:03.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[119865.463792] pcieport 0000:04:03.0: restoring config space at offset 0x6 (was 0x0, writing 0x360604)
[119865.463806] pcieport 0000:04:03.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[119865.463818] pcieport 0000:04:03.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[119865.463926] pcieport 0000:04:04.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[119865.463936] pcieport 0000:04:04.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a090)
[119865.463945] pcieport 0000:04:04.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[119865.463955] pcieport 0000:04:04.0: restoring config space at offset 0x6 (was 0x0, writing 0x673704)
[119865.463970] pcieport 0000:04:04.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[119865.463982] pcieport 0000:04:04.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[119865.464082] pci 0000:05:00.0: restoring config space at offset 0xf (was 0x1ff, writing 0x10b)
[119865.464116] pci 0000:05:00.0: restoring config space at offset 0x5 (was 0x0, writing 0xa0740000)
[119865.464126] pci 0000:05:00.0: restoring config space at offset 0x4 (was 0x0, writing 0xa0700000)
[119865.464137] pci 0000:05:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[119865.464150] pci 0000:05:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[119865.464305] brcmsmac 0000:02:00.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[119865.464378] brcmsmac 0000:02:00.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0400004)
[119865.464394] brcmsmac 0000:02:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[119865.464416] brcmsmac 0000:02:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[119865.465144] PM: early resume of devices complete after 3.748 msecs
[119865.465363] i915 0000:00:02.0: setting latency timer to 64
[119865.466275] uhci_hcd 0000:00:1a.0: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[119865.466299] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[119865.466349] ehci_hcd 0000:00:1a.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[119865.466356] usb usb3: root hub lost power or was reset
[119865.466369] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[119865.466401] mei 0000:00:16.0: irq 45 for MSI/MSI-X
[119865.466414] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[119865.466435] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[119865.466518] uhci_hcd 0000:00:1d.0: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[119865.466535] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[119865.466586] snd_hda_intel 0000:00:1b.0: irq 46 for MSI/MSI-X
[119865.466595] usb usb4: root hub lost power or was reset
[119865.466639] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[119865.466656] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[119865.466704] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[119865.466721] ata_piix 0000:00:1f.2: setting latency timer to 64
[119865.466840] brcmsmac 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[119865.466860] brcmsmac 0000:02:00.0: setting latency timer to 64
[119865.469623] sd 0:0:0:0: [sda] Starting disk
[119865.613844] Extended CMOS year: 2000
[119866.486290] ata2.00: failed to resume link (SControl 0)
[119866.805786] ata1.01: failed to resume link (SControl 0)
[119866.958961] ata1.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[119866.958981] ata1.01: SATA link down (SStatus 0 SControl 0)
[119866.965848] ata1.00: ACPI cmd ef/03:46:00:00:00:a0 (SET FEATURES) filtered out
[119866.972637] ata1.00: configured for UDMA/133
[119867.390779] PM: resume of devices complete after 1928.560 msecs
[119867.393772] PM: Finishing wakeup.
[119867.393777] Restarting tasks ... done.
[119867.444570] video LNXVIDEO:00: Restoring backlight state
[119867.507964] ata2.01: failed to resume link (SControl 0)
[119867.520306] ata2.00: SATA link down (SStatus 4 SControl 0)
[119867.520336] ata2.01: SATA link down (SStatus 0 SControl 0)
[119868.944290] EXT4-fs (sda4): re-mounted. Opts: commit=600
[119868.989349] usb 1-1.3: new high-speed USB device number 14 using ehci_hcd
[119869.415980] asix 1-1.3:1.0: eth0: register 'asix' at usb-0000:00:1a.7-1.3, ASIX AX88772 USB 2.0 Ethernet, 00:50:b6:05:85:62
[119880.799096] ADDRCONF(NETDEV_UP): eth0: link is not ready
[119880.814658] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[119880.816006] asix 1-1.3:1.0: eth0: link down
[119882.606408] asix 1-1.3:1.0: eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[119890.868257] eth0: no IPv6 routers present
[120722.583815] EXT4-fs (sda4): re-mounted. Opts: commit=0
[120723.358819] PM: Syncing filesystems ... done.
[120723.511980] PM: Preparing system for mem sleep
[120724.772726] Freezing user space processes ... (elapsed 0.01 seconds) done.
[120724.785389] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
[120724.798707] PM: Entering mem sleep
[120724.798772] Suspending console(s) (use no_console_suspend to debug)
[120724.802549] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[120724.803856] sd 0:0:0:0: [sda] Stopping disk
[120724.805194] brcmsmac 0000:02:00.0: PCI INT A disabled
[120724.838756] uhci_hcd 0000:00:1d.0: PCI INT B disabled
[120724.838785] uhci_hcd 0000:00:1a.0: PCI INT B disabled
[120724.845276] ehci_hcd 0000:00:1d.7: PCI INT A disabled
[120724.885219] ehci_hcd 0000:00:1a.7: PCI INT A disabled
[120724.908725] snd_hda_intel 0000:00:1b.0: PCI INT A disabled
[120726.442552] ata_piix 0000:00:1f.2: PCI INT B disabled
[120726.452788] PM: suspend of devices complete after 1655.059 msecs
[120726.454008] ehci_hcd 0000:00:1d.7: PME# enabled
[120726.454038] ehci_hcd 0000:00:1d.7: wake-up capability enabled by ACPI
[120726.466475] ehci_hcd 0000:00:1a.7: PME# enabled
[120726.466506] ehci_hcd 0000:00:1a.7: wake-up capability enabled by ACPI
[120726.492902] PM: late suspend of devices complete after 40.150 msecs
[120726.493685] ACPI: Preparing to enter system sleep state S3
[120726.519522] PM: Saving platform NVS memory
[120726.520718] Disabling non-boot CPUs ...
[120726.524355] CPU 1 is now offline
[120726.632471] CPU 2 is now offline
[120726.636025] CPU 3 is now offline
[120726.636030] lockdep: fixing up alternatives.
[120726.637149] Extended CMOS year: 2000
[120726.638058] ACPI: Low-level resume complete
[120726.638140] PM: Restoring platform NVS memory
[120726.638515] Extended CMOS year: 2000
[120726.638572] Enabling non-boot CPUs ...
[120726.642363] lockdep: fixing up alternatives.
[120726.642374] Booting Node 0 Processor 1 APIC 0x2
[120726.642378] smpboot cpu 1: start_ip = 9a000
[120726.653787] Calibrating delay loop (skipped) already calibrated this CPU
[120726.678854] NMI watchdog enabled, takes one hw-pmu counter.
[120726.683046] CPU1 is up
[120726.690423] lockdep: fixing up alternatives.
[120726.690433] Booting Node 0 Processor 2 APIC 0x1
[120726.690437] smpboot cpu 2: start_ip = 9a000
[120726.701715] Calibrating delay loop (skipped) already calibrated this CPU
[120726.724629] NMI watchdog enabled, takes one hw-pmu counter.
[120726.725511] CPU2 is up
[120726.732434] lockdep: fixing up alternatives.
[120726.732447] Booting Node 0 Processor 3 APIC 0x3
[120726.732451] smpboot cpu 3: start_ip = 9a000
[120726.743867] Calibrating delay loop (skipped) already calibrated this CPU
[120726.769040] NMI watchdog enabled, takes one hw-pmu counter.
[120726.772766] CPU3 is up
[120726.782827] ACPI: Waking up from system sleep state S3
[120727.283296] pcieport 0000:00:01.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[120727.283318] pcieport 0000:00:01.0: restoring config space at offset 0x9 (was 0x1fff1, writing 0xa891a4a1)
[120727.283328] pcieport 0000:00:01.0: restoring config space at offset 0x8 (was 0xfff0, writing 0xa490a070)
[120727.283337] pcieport 0000:00:01.0: restoring config space at offset 0x7 (was 0x200000f0, writing 0x3030)
[120727.283352] pcieport 0000:00:01.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[120727.283363] pcieport 0000:00:01.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[120727.283434] i915 0000:00:02.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[120727.283466] i915 0000:00:02.0: restoring config space at offset 0x1 (was 0x900007, writing 0x900407)
[120727.283535] mei 0000:00:16.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[120727.283578] mei 0000:00:16.0: restoring config space at offset 0x4 (was 0xfed1b004, writing 0xa0607104)
[120727.283640] uhci_hcd 0000:00:1a.0: restoring config space at offset 0xf (was 0x200, writing 0x20a)
[120727.283670] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x8 (was 0x1, writing 0x2141)
[120727.283700] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[120727.283762] ehci_hcd 0000:00:1a.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[120727.283805] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606c00)
[120727.283823] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[120727.283878] ehci_hcd 0000:00:1a.7: wake-up capability disabled by ACPI
[120727.283892] ehci_hcd 0000:00:1a.7: PME# disabled
[120727.283937] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[120727.283980] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0600004)
[120727.283992] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[120727.284007] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100002)
[120727.284088] pcieport 0000:00:1c.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[120727.284115] pcieport 0000:00:1c.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[120727.284128] pcieport 0000:00:1c.0: restoring config space at offset 0x8 (was 0x0, writing 0xa050a050)
[120727.284139] pcieport 0000:00:1c.0: restoring config space at offset 0x7 (was 0x20000000, writing 0x200000f0)
[120727.284151] pcieport 0000:00:1c.0: restoring config space at offset 0x6 (was 0x0, writing 0x10100)
[120727.284169] pcieport 0000:00:1c.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[120727.284184] pcieport 0000:00:1c.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[120727.284279] pcieport 0000:00:1c.1: restoring config space at offset 0xf (was 0x200, writing 0x2ff)
[120727.284308] pcieport 0000:00:1c.1: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[120727.284319] pcieport 0000:00:1c.1: restoring config space at offset 0x8 (was 0x0, writing 0xa040a040)
[120727.284331] pcieport 0000:00:1c.1: restoring config space at offset 0x7 (was 0x20000000, writing 0x200000f0)
[120727.284343] pcieport 0000:00:1c.1: restoring config space at offset 0x6 (was 0x0, writing 0x20200)
[120727.284361] pcieport 0000:00:1c.1: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[120727.284376] pcieport 0000:00:1c.1: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[120727.284449] uhci_hcd 0000:00:1d.0: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[120727.284479] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x8 (was 0x1, writing 0x20e1)
[120727.284509] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[120727.284569] ehci_hcd 0000:00:1d.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[120727.284612] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606800)
[120727.284630] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[120727.284682] ehci_hcd 0000:00:1d.7: wake-up capability disabled by ACPI
[120727.284694] ehci_hcd 0000:00:1d.7: PME# disabled
[120727.284813] ata_piix 0000:00:1f.2: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[120727.284843] ata_piix 0000:00:1f.2: restoring config space at offset 0x8 (was 0x1, writing 0x2061)
[120727.284854] ata_piix 0000:00:1f.2: restoring config space at offset 0x7 (was 0x1, writing 0x2179)
[120727.284865] ata_piix 0000:00:1f.2: restoring config space at offset 0x6 (was 0x1, writing 0x2161)
[120727.284877] ata_piix 0000:00:1f.2: restoring config space at offset 0x5 (was 0x1, writing 0x217d)
[120727.284888] ata_piix 0000:00:1f.2: restoring config space at offset 0x4 (was 0x1, writing 0x2169)
[120727.284906] ata_piix 0000:00:1f.2: restoring config space at offset 0x1 (was 0x2b00000, writing 0x2b00007)
[120727.284949] i801_smbus 0000:00:1f.3: restoring config space at offset 0xf (was 0x300, writing 0x30b)
[120727.284992] i801_smbus 0000:00:1f.3: restoring config space at offset 0x4 (was 0x4, writing 0xa0607004)
[120727.285009] i801_smbus 0000:00:1f.3: restoring config space at offset 0x1 (was 0x2800001, writing 0x2800003)
[120727.285078] pcieport 0000:03:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[120727.285088] pcieport 0000:03:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a070)
[120727.285097] pcieport 0000:03:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[120727.285107] pcieport 0000:03:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x670403)
[120727.285121] pcieport 0000:03:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[120727.285133] pcieport 0000:03:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[120727.285239] pcieport 0000:04:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[120727.285249] pcieport 0000:04:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa070a070)
[120727.285259] pcieport 0000:04:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[120727.285268] pcieport 0000:04:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x50504)
[120727.285283] pcieport 0000:04:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[120727.285295] pcieport 0000:04:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[120727.285402] pcieport 0000:04:03.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[120727.285412] pcieport 0000:04:03.0: restoring config space at offset 0x8 (was 0x0, writing 0xa080a080)
[120727.285422] pcieport 0000:04:03.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[120727.285431] pcieport 0000:04:03.0: restoring config space at offset 0x6 (was 0x0, writing 0x360604)
[120727.285446] pcieport 0000:04:03.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[120727.285458] pcieport 0000:04:03.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[120727.285565] pcieport 0000:04:04.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[120727.285575] pcieport 0000:04:04.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a090)
[120727.285585] pcieport 0000:04:04.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[120727.285594] pcieport 0000:04:04.0: restoring config space at offset 0x6 (was 0x0, writing 0x673704)
[120727.285609] pcieport 0000:04:04.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[120727.285621] pcieport 0000:04:04.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[120727.285720] pci 0000:05:00.0: restoring config space at offset 0xf (was 0x1ff, writing 0x10b)
[120727.285754] pci 0000:05:00.0: restoring config space at offset 0x5 (was 0x0, writing 0xa0740000)
[120727.285764] pci 0000:05:00.0: restoring config space at offset 0x4 (was 0x0, writing 0xa0700000)
[120727.285775] pci 0000:05:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[120727.285788] pci 0000:05:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[120727.285944] brcmsmac 0000:02:00.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[120727.286016] brcmsmac 0000:02:00.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0400004)
[120727.286032] brcmsmac 0000:02:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[120727.286054] brcmsmac 0000:02:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[120727.286791] PM: early resume of devices complete after 3.750 msecs
[120727.287033] i915 0000:00:02.0: setting latency timer to 64
[120727.287566] uhci_hcd 0000:00:1a.0: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[120727.287590] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[120727.287639] usb usb3: root hub lost power or was reset
[120727.287683] mei 0000:00:16.0: irq 45 for MSI/MSI-X
[120727.287691] ehci_hcd 0000:00:1a.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[120727.287714] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[120727.287798] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[120727.287818] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[120727.287871] uhci_hcd 0000:00:1d.0: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[120727.287895] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[120727.287945] usb usb4: root hub lost power or was reset
[120727.287964] snd_hda_intel 0000:00:1b.0: irq 46 for MSI/MSI-X
[120727.287990] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[120727.288015] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[120727.288566] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[120727.288582] ata_piix 0000:00:1f.2: setting latency timer to 64
[120727.288670] brcmsmac 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[120727.288696] brcmsmac 0000:02:00.0: setting latency timer to 64
[120727.291799] sd 0:0:0:0: [sda] Starting disk
[120728.307919] ata2.00: failed to resume link (SControl 0)
[120728.627417] ata1.01: failed to resume link (SControl 0)
[120728.780593] ata1.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[120728.780613] ata1.01: SATA link down (SStatus 0 SControl 0)
[120728.787472] ata1.00: ACPI cmd ef/03:46:00:00:00:a0 (SET FEATURES) filtered out
[120728.794253] ata1.00: configured for UDMA/133
[120729.248689] PM: resume of devices complete after 1964.876 msecs
[120729.251676] PM: Finishing wakeup.
[120729.251680] Restarting tasks ... done.
[120729.316559] video LNXVIDEO:00: Restoring backlight state
[120729.323139] usb 2-1.2: new high-speed USB device number 16 using ehci_hcd
[120729.329612] ata2.01: failed to resume link (SControl 0)
[120729.341431] ata2.00: SATA link down (SStatus 4 SControl 0)
[120729.341458] ata2.01: SATA link down (SStatus 0 SControl 0)
[120729.745187] asix 2-1.2:1.0: eth1: register 'asix' at usb-0000:00:1d.7-1.2, ASIX AX88178 USB 2.0 Ethernet, 00:11:6b:73:91:ff
[120729.745967] usb 1-1.3: USB disconnect, device number 14
[120729.746735] asix 1-1.3:1.0: eth0: unregister 'asix' usb-0000:00:1a.7-1.3, ASIX AX88772 USB 2.0 Ethernet
[120730.823974] EXT4-fs (sda4): re-mounted. Opts: commit=0
[120785.038276] ADDRCONF(NETDEV_UP): eth1: link is not ready
[120787.620816] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[120787.627122] asix 2-1.2:1.0: eth1: link up, 1000Mbps, full-duplex, lpa 0xC5E1
[120797.922719] eth1: no IPv6 routers present
[147217.163598] usb 2-1.2: USB disconnect, device number 16
[147217.164473] asix 2-1.2:1.0: eth1: unregister 'asix' usb-0000:00:1d.7-1.2, ASIX AX88178 USB 2.0 Ethernet
[147220.500861] EXT4-fs (sda4): re-mounted. Opts: commit=0
[147221.343392] PM: Syncing filesystems ... done.
[147221.584944] PM: Preparing system for mem sleep
[147223.062099] Freezing user space processes ... (elapsed 0.01 seconds) done.
[147223.074533] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
[147223.087846] PM: Entering mem sleep
[147223.087918] Suspending console(s) (use no_console_suspend to debug)
[147223.091185] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[147223.092622] sd 0:0:0:0: [sda] Stopping disk
[147223.093433] brcmsmac 0000:02:00.0: PCI INT A disabled
[147223.127901] uhci_hcd 0000:00:1d.0: PCI INT B disabled
[147223.127953] uhci_hcd 0000:00:1a.0: PCI INT B disabled
[147223.131092] ehci_hcd 0000:00:1d.7: PCI INT A disabled
[147223.174359] ehci_hcd 0000:00:1a.7: PCI INT A disabled
[147223.194507] snd_hda_intel 0000:00:1b.0: PCI INT A disabled
[147224.457181] ata_piix 0000:00:1f.2: PCI INT B disabled
[147224.469088] PM: suspend of devices complete after 1381.761 msecs
[147224.470300] ehci_hcd 0000:00:1d.7: PME# enabled
[147224.470330] ehci_hcd 0000:00:1d.7: wake-up capability enabled by ACPI
[147224.482764] ehci_hcd 0000:00:1a.7: PME# enabled
[147224.482794] ehci_hcd 0000:00:1a.7: wake-up capability enabled by ACPI
[147224.509195] PM: late suspend of devices complete after 40.162 msecs
[147224.509978] ACPI: Preparing to enter system sleep state S3
[147224.535785] PM: Saving platform NVS memory
[147224.537500] Disabling non-boot CPUs ...
[147224.540898] CPU 1 is now offline
[147224.645385] CPU 2 is now offline
[147224.648922] CPU 3 is now offline
[147224.648927] lockdep: fixing up alternatives.
[147224.650100] Extended CMOS year: 2000
[147224.651011] ACPI: Low-level resume complete
[147224.651093] PM: Restoring platform NVS memory
[147224.651469] Extended CMOS year: 2000
[147224.651525] Enabling non-boot CPUs ...
[147224.655313] lockdep: fixing up alternatives.
[147224.655325] Booting Node 0 Processor 1 APIC 0x2
[147224.655328] smpboot cpu 1: start_ip = 9a000
[147224.666737] Calibrating delay loop (skipped) already calibrated this CPU
[147224.689684] NMI watchdog enabled, takes one hw-pmu counter.
[147224.694075] CPU1 is up
[147224.694529] lockdep: fixing up alternatives.
[147224.694540] Booting Node 0 Processor 2 APIC 0x1
[147224.694544] smpboot cpu 2: start_ip = 9a000
[147224.705709] Calibrating delay loop (skipped) already calibrated this CPU
[147224.728241] NMI watchdog enabled, takes one hw-pmu counter.
[147224.729092] CPU2 is up
[147224.735131] lockdep: fixing up alternatives.
[147224.735145] Booting Node 0 Processor 3 APIC 0x3
[147224.735149] smpboot cpu 3: start_ip = 9a000
[147224.746560] Calibrating delay loop (skipped) already calibrated this CPU
[147224.772650] NMI watchdog enabled, takes one hw-pmu counter.
[147224.775652] CPU3 is up
[147224.785487] ACPI: Waking up from system sleep state S3
[147225.286197] pcieport 0000:00:01.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[147225.286219] pcieport 0000:00:01.0: restoring config space at offset 0x9 (was 0x1fff1, writing 0xa891a4a1)
[147225.286228] pcieport 0000:00:01.0: restoring config space at offset 0x8 (was 0xfff0, writing 0xa490a070)
[147225.286238] pcieport 0000:00:01.0: restoring config space at offset 0x7 (was 0x200000f0, writing 0x20003030)
[147225.286253] pcieport 0000:00:01.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[147225.286263] pcieport 0000:00:01.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[147225.286335] i915 0000:00:02.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[147225.286367] i915 0000:00:02.0: restoring config space at offset 0x1 (was 0x900007, writing 0x900407)
[147225.286436] mei 0000:00:16.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[147225.286479] mei 0000:00:16.0: restoring config space at offset 0x4 (was 0xfed1b004, writing 0xa0607104)
[147225.286540] uhci_hcd 0000:00:1a.0: restoring config space at offset 0xf (was 0x200, writing 0x20a)
[147225.286570] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x8 (was 0x1, writing 0x2141)
[147225.286600] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[147225.286662] ehci_hcd 0000:00:1a.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[147225.286705] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606c00)
[147225.286723] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[147225.286777] ehci_hcd 0000:00:1a.7: wake-up capability disabled by ACPI
[147225.286792] ehci_hcd 0000:00:1a.7: PME# disabled
[147225.286837] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[147225.286879] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0600004)
[147225.286891] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[147225.286906] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100002)
[147225.286987] pcieport 0000:00:1c.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[147225.287016] pcieport 0000:00:1c.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[147225.287028] pcieport 0000:00:1c.0: restoring config space at offset 0x8 (was 0x0, writing 0xa050a050)
[147225.287040] pcieport 0000:00:1c.0: restoring config space at offset 0x7 (was 0x20000000, writing 0xf0)
[147225.287052] pcieport 0000:00:1c.0: restoring config space at offset 0x6 (was 0x0, writing 0x10100)
[147225.287070] pcieport 0000:00:1c.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[147225.287085] pcieport 0000:00:1c.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[147225.287180] pcieport 0000:00:1c.1: restoring config space at offset 0xf (was 0x200, writing 0x2ff)
[147225.287208] pcieport 0000:00:1c.1: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[147225.287219] pcieport 0000:00:1c.1: restoring config space at offset 0x8 (was 0x0, writing 0xa040a040)
[147225.287231] pcieport 0000:00:1c.1: restoring config space at offset 0x7 (was 0x20000000, writing 0xf0)
[147225.287243] pcieport 0000:00:1c.1: restoring config space at offset 0x6 (was 0x0, writing 0x20200)
[147225.287261] pcieport 0000:00:1c.1: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[147225.287277] pcieport 0000:00:1c.1: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[147225.287348] uhci_hcd 0000:00:1d.0: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[147225.287378] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x8 (was 0x1, writing 0x20e1)
[147225.287408] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[147225.287468] ehci_hcd 0000:00:1d.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[147225.287511] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606800)
[147225.287528] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[147225.287580] ehci_hcd 0000:00:1d.7: wake-up capability disabled by ACPI
[147225.287592] ehci_hcd 0000:00:1d.7: PME# disabled
[147225.287712] ata_piix 0000:00:1f.2: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[147225.287742] ata_piix 0000:00:1f.2: restoring config space at offset 0x8 (was 0x1, writing 0x2061)
[147225.287753] ata_piix 0000:00:1f.2: restoring config space at offset 0x7 (was 0x1, writing 0x2179)
[147225.287765] ata_piix 0000:00:1f.2: restoring config space at offset 0x6 (was 0x1, writing 0x2161)
[147225.287776] ata_piix 0000:00:1f.2: restoring config space at offset 0x5 (was 0x1, writing 0x217d)
[147225.287787] ata_piix 0000:00:1f.2: restoring config space at offset 0x4 (was 0x1, writing 0x2169)
[147225.287805] ata_piix 0000:00:1f.2: restoring config space at offset 0x1 (was 0x2b00000, writing 0x2b00007)
[147225.287848] i801_smbus 0000:00:1f.3: restoring config space at offset 0xf (was 0x300, writing 0x30b)
[147225.287891] i801_smbus 0000:00:1f.3: restoring config space at offset 0x4 (was 0x4, writing 0xa0607004)
[147225.287909] i801_smbus 0000:00:1f.3: restoring config space at offset 0x1 (was 0x2800001, writing 0x2800003)
[147225.287978] pcieport 0000:03:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[147225.287988] pcieport 0000:03:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a070)
[147225.287998] pcieport 0000:03:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[147225.288007] pcieport 0000:03:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x670403)
[147225.288021] pcieport 0000:03:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[147225.288033] pcieport 0000:03:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[147225.288140] pcieport 0000:04:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[147225.288150] pcieport 0000:04:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa070a070)
[147225.288159] pcieport 0000:04:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[147225.288169] pcieport 0000:04:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x50504)
[147225.288183] pcieport 0000:04:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[147225.288196] pcieport 0000:04:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[147225.288303] pcieport 0000:04:03.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[147225.288312] pcieport 0000:04:03.0: restoring config space at offset 0x8 (was 0x0, writing 0xa080a080)
[147225.288322] pcieport 0000:04:03.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[147225.288332] pcieport 0000:04:03.0: restoring config space at offset 0x6 (was 0x0, writing 0x360604)
[147225.288346] pcieport 0000:04:03.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[147225.288358] pcieport 0000:04:03.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[147225.288465] pcieport 0000:04:04.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[147225.288475] pcieport 0000:04:04.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a090)
[147225.288484] pcieport 0000:04:04.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[147225.288494] pcieport 0000:04:04.0: restoring config space at offset 0x6 (was 0x0, writing 0x673704)
[147225.288508] pcieport 0000:04:04.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[147225.288520] pcieport 0000:04:04.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[147225.288619] pci 0000:05:00.0: restoring config space at offset 0xf (was 0x1ff, writing 0x10b)
[147225.288653] pci 0000:05:00.0: restoring config space at offset 0x5 (was 0x0, writing 0xa0740000)
[147225.288664] pci 0000:05:00.0: restoring config space at offset 0x4 (was 0x0, writing 0xa0700000)
[147225.288674] pci 0000:05:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[147225.288687] pci 0000:05:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[147225.288843] brcmsmac 0000:02:00.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[147225.288916] brcmsmac 0000:02:00.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0400004)
[147225.288932] brcmsmac 0000:02:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[147225.288954] brcmsmac 0000:02:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[147225.289680] PM: early resume of devices complete after 3.737 msecs
[147225.289855] i915 0000:00:02.0: setting latency timer to 64
[147225.289872] uhci_hcd 0000:00:1a.0: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[147225.289895] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[147225.289951] usb usb3: root hub lost power or was reset
[147225.289994] ehci_hcd 0000:00:1a.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[147225.290009] mei 0000:00:16.0: irq 45 for MSI/MSI-X
[147225.290015] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[147225.290076] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[147225.290091] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[147225.290192] snd_hda_intel 0000:00:1b.0: irq 46 for MSI/MSI-X
[147225.292512] uhci_hcd 0000:00:1d.0: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[147225.292530] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[147225.292569] usb usb4: root hub lost power or was reset
[147225.292604] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[147225.292617] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[147225.292730] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[147225.292741] ata_piix 0000:00:1f.2: setting latency timer to 64
[147225.292925] brcmsmac 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[147225.292946] brcmsmac 0000:02:00.0: setting latency timer to 64
[147225.296426] sd 0:0:0:0: [sda] Starting disk
[147225.439936] Extended CMOS year: 2000
[147226.314177] ata2.00: failed to resume link (SControl 0)
[147226.633676] ata1.01: failed to resume link (SControl 0)
[147226.786852] ata1.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[147226.786872] ata1.01: SATA link down (SStatus 0 SControl 0)
[147226.793730] ata1.00: ACPI cmd ef/03:46:00:00:00:a0 (SET FEATURES) filtered out
[147226.800511] ata1.00: configured for UDMA/133
[147227.241942] PM: resume of devices complete after 1955.231 msecs
[147227.244936] PM: Finishing wakeup.
[147227.244941] Restarting tasks ... done.
[147227.300795] video LNXVIDEO:00: Restoring backlight state
[147227.329378] usb 1-1.3: new high-speed USB device number 15 using ehci_hcd
[147227.335855] ata2.01: failed to resume link (SControl 0)
[147227.348209] ata2.00: SATA link down (SStatus 4 SControl 0)
[147227.348235] ata2.01: SATA link down (SStatus 0 SControl 0)
[147227.741913] asix 1-1.3:1.0: eth0: register 'asix' at usb-0000:00:1a.7-1.3, ASIX AX88772 USB 2.0 Ethernet, 00:50:b6:05:85:62
[147228.862063] EXT4-fs (sda4): re-mounted. Opts: commit=0
[147244.180230] ADDRCONF(NETDEV_UP): eth0: link is not ready
[147244.220376] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[147244.221678] asix 1-1.3:1.0: eth0: link down
[147246.018118] asix 1-1.3:1.0: eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[147254.932823] eth0: no IPv6 routers present
[148359.475310] EXT4-fs (sda4): re-mounted. Opts: commit=0
[148360.437929] PM: Syncing filesystems ... done.
[148360.676571] PM: Preparing system for mem sleep
[148362.174535] Freezing user space processes ... (elapsed 0.01 seconds) done.
[148362.187352] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
[148362.200665] PM: Entering mem sleep
[148362.200737] Suspending console(s) (use no_console_suspend to debug)
[148362.204302] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[148362.205704] sd 0:0:0:0: [sda] Stopping disk
[148362.206915] brcmsmac 0000:02:00.0: PCI INT A disabled
[148362.240704] uhci_hcd 0000:00:1a.0: PCI INT B disabled
[148362.240720] uhci_hcd 0000:00:1d.0: PCI INT B disabled
[148362.243920] ehci_hcd 0000:00:1d.7: PCI INT A disabled
[148362.287186] ehci_hcd 0000:00:1a.7: PCI INT A disabled
[148362.310647] snd_hda_intel 0000:00:1b.0: PCI INT A disabled
[148363.839830] ata_piix 0000:00:1f.2: PCI INT B disabled
[148363.851546] PM: suspend of devices complete after 1651.818 msecs
[148363.852768] ehci_hcd 0000:00:1d.7: PME# enabled
[148363.852797] ehci_hcd 0000:00:1d.7: wake-up capability enabled by ACPI
[148363.865089] ehci_hcd 0000:00:1a.7: PME# enabled
[148363.865119] ehci_hcd 0000:00:1a.7: wake-up capability enabled by ACPI
[148363.891569] PM: late suspend of devices complete after 40.065 msecs
[148363.892351] ACPI: Preparing to enter system sleep state S3
[148363.918185] PM: Saving platform NVS memory
[148363.919343] Disabling non-boot CPUs ...
[148363.922845] CPU 1 is now offline
[148364.027793] CPU 2 is now offline
[148364.031354] CPU 3 is now offline
[148364.031359] lockdep: fixing up alternatives.
[148364.032490] Extended CMOS year: 2000
[148364.033399] ACPI: Low-level resume complete
[148364.033480] PM: Restoring platform NVS memory
[148364.033855] Extended CMOS year: 2000
[148364.033912] Enabling non-boot CPUs ...
[148364.037689] lockdep: fixing up alternatives.
[148364.037700] Booting Node 0 Processor 1 APIC 0x2
[148364.037704] smpboot cpu 1: start_ip = 9a000
[148364.049113] Calibrating delay loop (skipped) already calibrated this CPU
[148364.072263] NMI watchdog enabled, takes one hw-pmu counter.
[148364.076495] CPU1 is up
[148364.076913] lockdep: fixing up alternatives.
[148364.076923] Booting Node 0 Processor 2 APIC 0x1
[148364.076927] smpboot cpu 2: start_ip = 9a000
[148364.088244] Calibrating delay loop (skipped) already calibrated this CPU
[148364.110904] NMI watchdog enabled, takes one hw-pmu counter.
[148364.111745] CPU2 is up
[148364.118309] lockdep: fixing up alternatives.
[148364.118322] Booting Node 0 Processor 3 APIC 0x3
[148364.118326] smpboot cpu 3: start_ip = 9a000
[148364.129745] Calibrating delay loop (skipped) already calibrated this CPU
[148364.154638] NMI watchdog enabled, takes one hw-pmu counter.
[148364.157483] CPU3 is up
[148364.167422] ACPI: Waking up from system sleep state S3
[148364.668619] pcieport 0000:00:01.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[148364.668640] pcieport 0000:00:01.0: restoring config space at offset 0x9 (was 0x1fff1, writing 0xa891a4a1)
[148364.668650] pcieport 0000:00:01.0: restoring config space at offset 0x8 (was 0xfff0, writing 0xa490a070)
[148364.668659] pcieport 0000:00:01.0: restoring config space at offset 0x7 (was 0x200000f0, writing 0x3030)
[148364.668674] pcieport 0000:00:01.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[148364.668685] pcieport 0000:00:01.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[148364.668756] i915 0000:00:02.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[148364.668788] i915 0000:00:02.0: restoring config space at offset 0x1 (was 0x900007, writing 0x900407)
[148364.668856] mei 0000:00:16.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[148364.668899] mei 0000:00:16.0: restoring config space at offset 0x4 (was 0xfed1b004, writing 0xa0607104)
[148364.668961] uhci_hcd 0000:00:1a.0: restoring config space at offset 0xf (was 0x200, writing 0x20a)
[148364.668991] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x8 (was 0x1, writing 0x2141)
[148364.669020] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[148364.669082] ehci_hcd 0000:00:1a.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[148364.669125] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606c00)
[148364.669143] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[148364.669198] ehci_hcd 0000:00:1a.7: wake-up capability disabled by ACPI
[148364.669213] ehci_hcd 0000:00:1a.7: PME# disabled
[148364.669257] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[148364.669299] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0600004)
[148364.669311] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[148364.669325] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100002)
[148364.669406] pcieport 0000:00:1c.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[148364.669435] pcieport 0000:00:1c.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[148364.669447] pcieport 0000:00:1c.0: restoring config space at offset 0x8 (was 0x0, writing 0xa050a050)
[148364.669459] pcieport 0000:00:1c.0: restoring config space at offset 0x7 (was 0x20000000, writing 0x200000f0)
[148364.669470] pcieport 0000:00:1c.0: restoring config space at offset 0x6 (was 0x0, writing 0x10100)
[148364.669489] pcieport 0000:00:1c.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[148364.669503] pcieport 0000:00:1c.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[148364.669599] pcieport 0000:00:1c.1: restoring config space at offset 0xf (was 0x200, writing 0x2ff)
[148364.669626] pcieport 0000:00:1c.1: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[148364.669638] pcieport 0000:00:1c.1: restoring config space at offset 0x8 (was 0x0, writing 0xa040a040)
[148364.669650] pcieport 0000:00:1c.1: restoring config space at offset 0x7 (was 0x20000000, writing 0x200000f0)
[148364.669662] pcieport 0000:00:1c.1: restoring config space at offset 0x6 (was 0x0, writing 0x20200)
[148364.669680] pcieport 0000:00:1c.1: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[148364.669695] pcieport 0000:00:1c.1: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[148364.669766] uhci_hcd 0000:00:1d.0: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[148364.669796] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x8 (was 0x1, writing 0x20e1)
[148364.669827] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[148364.669887] ehci_hcd 0000:00:1d.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[148364.669930] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606800)
[148364.669947] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[148364.669999] ehci_hcd 0000:00:1d.7: wake-up capability disabled by ACPI
[148364.670011] ehci_hcd 0000:00:1d.7: PME# disabled
[148364.670129] ata_piix 0000:00:1f.2: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[148364.670159] ata_piix 0000:00:1f.2: restoring config space at offset 0x8 (was 0x1, writing 0x2061)
[148364.670170] ata_piix 0000:00:1f.2: restoring config space at offset 0x7 (was 0x1, writing 0x2179)
[148364.670181] ata_piix 0000:00:1f.2: restoring config space at offset 0x6 (was 0x1, writing 0x2161)
[148364.670193] ata_piix 0000:00:1f.2: restoring config space at offset 0x5 (was 0x1, writing 0x217d)
[148364.670204] ata_piix 0000:00:1f.2: restoring config space at offset 0x4 (was 0x1, writing 0x2169)
[148364.670221] ata_piix 0000:00:1f.2: restoring config space at offset 0x1 (was 0x2b00000, writing 0x2b00007)
[148364.670264] i801_smbus 0000:00:1f.3: restoring config space at offset 0xf (was 0x300, writing 0x30b)
[148364.670307] i801_smbus 0000:00:1f.3: restoring config space at offset 0x4 (was 0x4, writing 0xa0607004)
[148364.670325] i801_smbus 0000:00:1f.3: restoring config space at offset 0x1 (was 0x2800001, writing 0x2800003)
[148364.670393] pcieport 0000:03:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[148364.670403] pcieport 0000:03:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a070)
[148364.670413] pcieport 0000:03:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[148364.670422] pcieport 0000:03:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x670403)
[148364.670437] pcieport 0000:03:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[148364.670449] pcieport 0000:03:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[148364.670555] pcieport 0000:04:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[148364.670565] pcieport 0000:04:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa070a070)
[148364.670574] pcieport 0000:04:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[148364.670584] pcieport 0000:04:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x50504)
[148364.670598] pcieport 0000:04:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[148364.670610] pcieport 0000:04:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[148364.670717] pcieport 0000:04:03.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[148364.670727] pcieport 0000:04:03.0: restoring config space at offset 0x8 (was 0x0, writing 0xa080a080)
[148364.670737] pcieport 0000:04:03.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[148364.670747] pcieport 0000:04:03.0: restoring config space at offset 0x6 (was 0x0, writing 0x360604)
[148364.670761] pcieport 0000:04:03.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[148364.670773] pcieport 0000:04:03.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[148364.670880] pcieport 0000:04:04.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[148364.670889] pcieport 0000:04:04.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a090)
[148364.670899] pcieport 0000:04:04.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[148364.670909] pcieport 0000:04:04.0: restoring config space at offset 0x6 (was 0x0, writing 0x673704)
[148364.670923] pcieport 0000:04:04.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[148364.670935] pcieport 0000:04:04.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[148364.671034] pci 0000:05:00.0: restoring config space at offset 0xf (was 0x1ff, writing 0x10b)
[148364.671068] pci 0000:05:00.0: restoring config space at offset 0x5 (was 0x0, writing 0xa0740000)
[148364.671079] pci 0000:05:00.0: restoring config space at offset 0x4 (was 0x0, writing 0xa0700000)
[148364.671089] pci 0000:05:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[148364.671102] pci 0000:05:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[148364.671258] brcmsmac 0000:02:00.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[148364.671331] brcmsmac 0000:02:00.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0400004)
[148364.671347] brcmsmac 0000:02:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[148364.671369] brcmsmac 0000:02:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[148364.672104] PM: early resume of devices complete after 3.740 msecs
[148364.672344] i915 0000:00:02.0: setting latency timer to 64
[148364.672620] mei 0000:00:16.0: irq 45 for MSI/MSI-X
[148364.672693] uhci_hcd 0000:00:1a.0: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[148364.672723] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[148364.672734] ehci_hcd 0000:00:1a.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[148364.672753] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[148364.672770] usb usb3: root hub lost power or was reset
[148364.672874] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[148364.672893] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[148364.672965] uhci_hcd 0000:00:1d.0: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[148364.672988] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[148364.673035] usb usb4: root hub lost power or was reset
[148364.673041] snd_hda_intel 0000:00:1b.0: irq 46 for MSI/MSI-X
[148364.673079] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[148364.673099] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[148364.673219] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[148364.673234] ata_piix 0000:00:1f.2: setting latency timer to 64
[148364.673343] brcmsmac 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[148364.673360] brcmsmac 0000:02:00.0: setting latency timer to 64
[148364.677019] sd 0:0:0:0: [sda] Starting disk
[148364.845656] Extended CMOS year: 2000
[148364.924664] usb 1-1.3: reset high-speed USB device number 15 using ehci_hcd
[148365.028877] asix 1-1.3:1.0: no reset_resume for driver asix?
[148365.028931] asix 1-1.3:1.0: eth0: unregister 'asix' usb-0000:00:1a.7-1.3, ASIX AX88772 USB 2.0 Ethernet
[148365.693238] ata2.00: failed to resume link (SControl 0)
[148366.012747] ata1.01: failed to resume link (SControl 0)
[148366.165922] ata1.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[148366.165942] ata1.01: SATA link down (SStatus 0 SControl 0)
[148366.172802] ata1.00: ACPI cmd ef/03:46:00:00:00:a0 (SET FEATURES) filtered out
[148366.179580] ata1.00: configured for UDMA/133
[148366.611070] PM: resume of devices complete after 1941.908 msecs
[148366.714975] ata2.01: failed to resume link (SControl 0)
[148366.726816] ata2.00: SATA link down (SStatus 4 SControl 0)
[148366.726838] ata2.01: SATA link down (SStatus 0 SControl 0)
[148366.922530] asix 1-1.3:1.0: eth0: register 'asix' at usb-0000:00:1a.7-1.3, ASIX AX88772 USB 2.0 Ethernet, 00:50:b6:05:85:62
[148366.925989] PM: Finishing wakeup.
[148366.925994] Restarting tasks ... done.
[148367.008598] video LNXVIDEO:00: Restoring backlight state
[148368.531248] EXT4-fs (sda4): re-mounted. Opts: commit=0
[148426.036973] ADDRCONF(NETDEV_UP): eth0: link is not ready
[148426.159056] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[148426.160255] asix 1-1.3:1.0: eth0: link down
[148427.822763] asix 1-1.3:1.0: eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[148436.705868] eth0: no IPv6 routers present
[149989.155483] asix 1-1.3:1.0: eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[150099.958083] asix 1-1.3:1.0: eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[150749.678179] usb 1-1.3: USB disconnect, device number 15
[150749.678814] asix 1-1.3:1.0: eth0: unregister 'asix' usb-0000:00:1a.7-1.3, ASIX AX88772 USB 2.0 Ethernet
[150853.762305] EXT4-fs (sda4): re-mounted. Opts: commit=0
[150854.439874] PM: Syncing filesystems ... done.
[150854.638201] PM: Preparing system for mem sleep
[150858.034099] Freezing user space processes ... (elapsed 0.01 seconds) done.
[150858.045753] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
[150858.059067] PM: Entering mem sleep
[150858.059135] Suspending console(s) (use no_console_suspend to debug)
[150858.062396] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[150858.063854] sd 0:0:0:0: [sda] Stopping disk
[150858.065411] brcmsmac 0000:02:00.0: PCI INT A disabled
[150858.099163] uhci_hcd 0000:00:1a.0: PCI INT B disabled
[150858.099217] uhci_hcd 0000:00:1d.0: PCI INT B disabled
[150858.102351] ehci_hcd 0000:00:1d.7: PCI INT A disabled
[150858.145610] ehci_hcd 0000:00:1a.7: PCI INT A disabled
[150858.169083] snd_hda_intel 0000:00:1b.0: PCI INT A disabled
[150859.684636] ata_piix 0000:00:1f.2: PCI INT B disabled
[150859.696728] PM: suspend of devices complete after 1638.586 msecs
[150859.697943] ehci_hcd 0000:00:1d.7: PME# enabled
[150859.697972] ehci_hcd 0000:00:1d.7: wake-up capability enabled by ACPI
[150859.710225] ehci_hcd 0000:00:1a.7: PME# enabled
[150859.710255] ehci_hcd 0000:00:1a.7: wake-up capability enabled by ACPI
[150859.736699] PM: late suspend of devices complete after 40.017 msecs
[150859.737482] ACPI: Preparing to enter system sleep state S3
[150859.763312] PM: Saving platform NVS memory
[150859.764579] Disabling non-boot CPUs ...
[150859.768078] CPU 1 is now offline
[150859.872916] CPU 2 is now offline
[150859.976075] CPU 3 is now offline
[150859.976080] lockdep: fixing up alternatives.
[150859.977209] Extended CMOS year: 2000
[150859.978117] ACPI: Low-level resume complete
[150859.978198] PM: Restoring platform NVS memory
[150859.978574] Extended CMOS year: 2000
[150859.978631] Enabling non-boot CPUs ...
[150859.982412] lockdep: fixing up alternatives.
[150859.982423] Booting Node 0 Processor 1 APIC 0x2
[150859.982427] smpboot cpu 1: start_ip = 9a000
[150859.993835] Calibrating delay loop (skipped) already calibrated this CPU
[150860.017038] NMI watchdog enabled, takes one hw-pmu counter.
[150860.021199] CPU1 is up
[150860.021495] lockdep: fixing up alternatives.
[150860.021505] Booting Node 0 Processor 2 APIC 0x1
[150860.021509] smpboot cpu 2: start_ip = 9a000
[150860.032751] Calibrating delay loop (skipped) already calibrated this CPU
[150860.055363] NMI watchdog enabled, takes one hw-pmu counter.
[150860.056115] CPU2 is up
[150860.063821] lockdep: fixing up alternatives.
[150860.063835] Booting Node 0 Processor 3 APIC 0x3
[150860.063839] smpboot cpu 3: start_ip = 9a000
[150860.075255] Calibrating delay loop (skipped) already calibrated this CPU
[150860.100020] NMI watchdog enabled, takes one hw-pmu counter.
[150860.102907] CPU3 is up
[150860.112728] ACPI: Waking up from system sleep state S3
[150860.982996] pcieport 0000:00:01.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[150860.983018] pcieport 0000:00:01.0: restoring config space at offset 0x9 (was 0x1fff1, writing 0xa891a4a1)
[150860.983028] pcieport 0000:00:01.0: restoring config space at offset 0x8 (was 0xfff0, writing 0xa490a070)
[150860.983038] pcieport 0000:00:01.0: restoring config space at offset 0x7 (was 0x200000f0, writing 0x20003030)
[150860.983052] pcieport 0000:00:01.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[150860.983063] pcieport 0000:00:01.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[150860.983135] i915 0000:00:02.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[150860.983168] i915 0000:00:02.0: restoring config space at offset 0x1 (was 0x900007, writing 0x900407)
[150860.983237] mei 0000:00:16.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[150860.983279] mei 0000:00:16.0: restoring config space at offset 0x4 (was 0xfed1b004, writing 0xa0607104)
[150860.983341] uhci_hcd 0000:00:1a.0: restoring config space at offset 0xf (was 0x200, writing 0x20a)
[150860.983371] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x8 (was 0x1, writing 0x2141)
[150860.983402] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[150860.983464] ehci_hcd 0000:00:1a.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[150860.983507] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606c00)
[150860.983524] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[150860.983580] ehci_hcd 0000:00:1a.7: wake-up capability disabled by ACPI
[150860.983593] ehci_hcd 0000:00:1a.7: PME# disabled
[150860.983638] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[150860.983681] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0600004)
[150860.983692] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[150860.983707] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100002)
[150860.983789] pcieport 0000:00:1c.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[150860.983817] pcieport 0000:00:1c.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[150860.983829] pcieport 0000:00:1c.0: restoring config space at offset 0x8 (was 0x0, writing 0xa050a050)
[150860.983841] pcieport 0000:00:1c.0: restoring config space at offset 0x7 (was 0x20000000, writing 0xf0)
[150860.983853] pcieport 0000:00:1c.0: restoring config space at offset 0x6 (was 0x0, writing 0x10100)
[150860.983870] pcieport 0000:00:1c.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[150860.983886] pcieport 0000:00:1c.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[150860.983982] pcieport 0000:00:1c.1: restoring config space at offset 0xf (was 0x200, writing 0x2ff)
[150860.984010] pcieport 0000:00:1c.1: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[150860.984022] pcieport 0000:00:1c.1: restoring config space at offset 0x8 (was 0x0, writing 0xa040a040)
[150860.984034] pcieport 0000:00:1c.1: restoring config space at offset 0x7 (was 0x20000000, writing 0xf0)
[150860.984046] pcieport 0000:00:1c.1: restoring config space at offset 0x6 (was 0x0, writing 0x20200)
[150860.984064] pcieport 0000:00:1c.1: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[150860.984079] pcieport 0000:00:1c.1: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[150860.984151] uhci_hcd 0000:00:1d.0: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[150860.984182] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x8 (was 0x1, writing 0x20e1)
[150860.984212] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[150860.984272] ehci_hcd 0000:00:1d.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[150860.984315] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606800)
[150860.984332] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[150860.984384] ehci_hcd 0000:00:1d.7: wake-up capability disabled by ACPI
[150860.984396] ehci_hcd 0000:00:1d.7: PME# disabled
[150860.984515] ata_piix 0000:00:1f.2: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[150860.984545] ata_piix 0000:00:1f.2: restoring config space at offset 0x8 (was 0x1, writing 0x2061)
[150860.984556] ata_piix 0000:00:1f.2: restoring config space at offset 0x7 (was 0x1, writing 0x2179)
[150860.984567] ata_piix 0000:00:1f.2: restoring config space at offset 0x6 (was 0x1, writing 0x2161)
[150860.984579] ata_piix 0000:00:1f.2: restoring config space at offset 0x5 (was 0x1, writing 0x217d)
[150860.984590] ata_piix 0000:00:1f.2: restoring config space at offset 0x4 (was 0x1, writing 0x2169)
[150860.984608] ata_piix 0000:00:1f.2: restoring config space at offset 0x1 (was 0x2b00000, writing 0x2b00007)
[150860.984650] i801_smbus 0000:00:1f.3: restoring config space at offset 0xf (was 0x300, writing 0x30b)
[150860.984693] i801_smbus 0000:00:1f.3: restoring config space at offset 0x4 (was 0x4, writing 0xa0607004)
[150860.984711] i801_smbus 0000:00:1f.3: restoring config space at offset 0x1 (was 0x2800001, writing 0x2800003)
[150860.984780] pcieport 0000:03:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[150860.984790] pcieport 0000:03:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a070)
[150860.984800] pcieport 0000:03:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[150860.984809] pcieport 0000:03:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x670403)
[150860.984823] pcieport 0000:03:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[150860.984835] pcieport 0000:03:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[150860.984942] pcieport 0000:04:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[150860.984952] pcieport 0000:04:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa070a070)
[150860.984962] pcieport 0000:04:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[150860.984972] pcieport 0000:04:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x50504)
[150860.984986] pcieport 0000:04:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[150860.984998] pcieport 0000:04:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[150860.985106] pcieport 0000:04:03.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[150860.985116] pcieport 0000:04:03.0: restoring config space at offset 0x8 (was 0x0, writing 0xa080a080)
[150860.985126] pcieport 0000:04:03.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[150860.985135] pcieport 0000:04:03.0: restoring config space at offset 0x6 (was 0x0, writing 0x360604)
[150860.985150] pcieport 0000:04:03.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[150860.985162] pcieport 0000:04:03.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[150860.985270] pcieport 0000:04:04.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[150860.985280] pcieport 0000:04:04.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a090)
[150860.985290] pcieport 0000:04:04.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[150860.985299] pcieport 0000:04:04.0: restoring config space at offset 0x6 (was 0x0, writing 0x673704)
[150860.985314] pcieport 0000:04:04.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[150860.985326] pcieport 0000:04:04.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[150860.985426] pci 0000:05:00.0: restoring config space at offset 0xf (was 0x1ff, writing 0x10b)
[150860.985460] pci 0000:05:00.0: restoring config space at offset 0x5 (was 0x0, writing 0xa0740000)
[150860.985470] pci 0000:05:00.0: restoring config space at offset 0x4 (was 0x0, writing 0xa0700000)
[150860.985481] pci 0000:05:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[150860.985494] pci 0000:05:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[150860.985650] brcmsmac 0000:02:00.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[150860.985722] brcmsmac 0000:02:00.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0400004)
[150860.985739] brcmsmac 0000:02:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[150860.985760] brcmsmac 0000:02:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[150860.986478] PM: early resume of devices complete after 3.734 msecs
[150860.986673] i915 0000:00:02.0: setting latency timer to 64
[150860.986685] uhci_hcd 0000:00:1a.0: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[150860.986708] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[150860.986763] usb usb3: root hub lost power or was reset
[150860.986809] ehci_hcd 0000:00:1a.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[150860.986830] mei 0000:00:16.0: irq 45 for MSI/MSI-X
[150860.986836] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[150860.986914] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[150860.986933] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[150860.987005] uhci_hcd 0000:00:1d.0: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[150860.987030] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[150860.987070] snd_hda_intel 0000:00:1b.0: irq 46 for MSI/MSI-X
[150860.987075] usb usb4: root hub lost power or was reset
[150860.987118] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[150860.987136] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[150860.987262] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[150860.987277] ata_piix 0000:00:1f.2: setting latency timer to 64
[150860.987410] brcmsmac 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[150860.987430] brcmsmac 0000:02:00.0: setting latency timer to 64
[150860.990767] sd 0:0:0:0: [sda] Starting disk
[150861.003009] Extended CMOS year: 2000
[150861.060918] bcm5974: bad trackpad package, length: 8
[150861.080971] bcm5974: bad trackpad package, length: 8
[150861.081963] bcm5974: bad trackpad package, length: 8
[150862.007623] ata2.00: failed to resume link (SControl 0)
[150862.327129] ata1.01: failed to resume link (SControl 0)
[150862.480311] ata1.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[150862.480331] ata1.01: SATA link down (SStatus 0 SControl 0)
[150862.487164] ata1.00: ACPI cmd ef/03:46:00:00:00:a0 (SET FEATURES) filtered out
[150862.497371] ata1.00: configured for UDMA/133
[150862.868530] PM: resume of devices complete after 1884.912 msecs
[150862.871533] PM: Finishing wakeup.
[150862.871538] Restarting tasks ... done.
[150862.928612] video LNXVIDEO:00: Restoring backlight state
[150863.029328] ata2.01: failed to resume link (SControl 0)
[150863.041546] ata2.00: SATA link down (SStatus 4 SControl 0)
[150863.041579] ata2.01: SATA link down (SStatus 0 SControl 0)
[150863.082509] usb 2-1.2: new high-speed USB device number 17 using ehci_hcd
[150863.504360] asix 2-1.2:1.0: eth0: register 'asix' at usb-0000:00:1d.7-1.2, ASIX AX88178 USB 2.0 Ethernet, 00:11:6b:73:91:ff
[150864.504182] EXT4-fs (sda4): re-mounted. Opts: commit=0
[150910.055279] ADDRCONF(NETDEV_UP): eth0: link is not ready
[150912.758608] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[150912.761150] asix 2-1.2:1.0: eth0: link up, 1000Mbps, full-duplex, lpa 0xC5E1
[150922.952601] eth0: no IPv6 routers present
[151282.928433] usb 1-1.3: new high-speed USB device number 16 using ehci_hcd
[151283.098312] scsi11 : usb-storage 1-1.3:1.0
[151290.557643] scsi 11:0:0:0: Direct-Access     Samsung  STORY Station 3  1AJ1 PQ: 0 ANSI: 0
[151290.559074] sd 11:0:0:0: [sdb] 1953525168 512-byte logical blocks: (1.00 TB/931 GiB)
[151290.559961] sd 11:0:0:0: [sdb] Write Protect is off
[151290.559970] sd 11:0:0:0: [sdb] Mode Sense: 23 00 00 00
[151290.560827] sd 11:0:0:0: [sdb] No Caching mode page present
[151290.560834] sd 11:0:0:0: [sdb] Assuming drive cache: write through
[151290.564425] sd 11:0:0:0: [sdb] No Caching mode page present
[151290.564431] sd 11:0:0:0: [sdb] Assuming drive cache: write through
[151290.600070]  sdb: sdb1 sdb2 sdb3 sdb4
[151290.603635] sd 11:0:0:0: [sdb] No Caching mode page present
[151290.603644] sd 11:0:0:0: [sdb] Assuming drive cache: write through
[151290.603652] sd 11:0:0:0: [sdb] Attached SCSI disk
[153094.677797] usb 1-1.3: USB disconnect, device number 16
[153097.234506] usb 2-1.2: USB disconnect, device number 17
[153097.235304] asix 2-1.2:1.0: eth0: unregister 'asix' usb-0000:00:1d.7-1.2, ASIX AX88178 USB 2.0 Ethernet
[153964.416444] ieee80211 phy0: brcms_ops_config: change monitor mode: false (implement)
[153964.416455] ieee80211 phy0: brcms_ops_config: change power-save mode: false (implement)
[153964.417972] ieee80211 phy0: brcms_ops_bss_info_changed: qos enabled: false (implement)
[153964.419255] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[153966.556857] wlan0: authenticate with 80:17:7d:4d:6f:42 (try 1)
[153966.558778] wlan0: authenticated
[153966.559494] wlan0: associate with 80:17:7d:4d:6f:42 (try 1)
[153966.566163] wlan0: RX AssocResp from 80:17:7d:4d:6f:42 (capab=0x431 status=0 aid=10)
[153966.566172] wlan0: associated
[153966.567628] ieee80211 phy0: brcms_ops_bss_info_changed: qos enabled: true (implement)
[153966.567643] ieee80211 phy0: brcmsmac: brcms_ops_bss_info_changed: associated
[153966.567654] ieee80211 phy0: changing basic rates failed: -22
[153966.567661] ieee80211 phy0: brcms_ops_bss_info_changed: arp filtering: enabled true, count 0 (implement)
[153966.568572] ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[153975.312922] ieee80211 phy0: brcms_ops_bss_info_changed: arp filtering: enabled true, count 1 (implement)
[153977.019751] wlan0: no IPv6 routers present
[174851.035946] usb 1-1.3: new high-speed USB device number 17 using ehci_hcd
[174851.318259] scsi12 : usb-storage 1-1.3:1.0
[174872.945467] scsi 12:0:0:0: Direct-Access     Samsung  STORY Station 3  1AQ1 PQ: 0 ANSI: 0
[174872.947444] sd 12:0:0:0: [sdb] 3907029168 512-byte logical blocks: (2.00 TB/1.81 TiB)
[174872.949184] sd 12:0:0:0: [sdb] Write Protect is off
[174872.949194] sd 12:0:0:0: [sdb] Mode Sense: 23 00 00 00
[174872.950179] sd 12:0:0:0: [sdb] No Caching mode page present
[174872.950186] sd 12:0:0:0: [sdb] Assuming drive cache: write through
[174872.953795] sd 12:0:0:0: [sdb] No Caching mode page present
[174872.953803] sd 12:0:0:0: [sdb] Assuming drive cache: write through
[174872.960535]  sdb: sdb1
[174872.963643] sd 12:0:0:0: [sdb] No Caching mode page present
[174872.963653] sd 12:0:0:0: [sdb] Assuming drive cache: write through
[174872.963660] sd 12:0:0:0: [sdb] Attached SCSI disk
[174891.975629] SGI XFS with ACLs, security attributes, realtime, large block/inode numbers, no debug enabled
[174891.978870] SGI XFS Quota Management subsystem
[174891.981393] XFS (sdb1): Mounting Filesystem
[174892.108649] XFS (sdb1): Ending clean mount
[174926.751880] usb 1-1.3: USB disconnect, device number 17
[174958.644979] usb 1-1.3: new high-speed USB device number 18 using ehci_hcd
[174958.764370] scsi13 : usb-storage 1-1.3:1.0
[174969.164294] scsi 13:0:0:0: Direct-Access     Toshiba  StorE HDD        0000 PQ: 0 ANSI: 4
[174969.165996] sd 13:0:0:0: [sdb] 3907029168 512-byte logical blocks: (2.00 TB/1.81 TiB)
[174969.172434] sd 13:0:0:0: [sdb] Write Protect is off
[174969.172441] sd 13:0:0:0: [sdb] Mode Sense: 38 00 00 00
[174969.178988] sd 13:0:0:0: [sdb] No Caching mode page present
[174969.178995] sd 13:0:0:0: [sdb] Assuming drive cache: write through
[174969.194019] sd 13:0:0:0: [sdb] No Caching mode page present
[174969.194026] sd 13:0:0:0: [sdb] Assuming drive cache: write through
[174969.226060]  sdb: sdb1
[174969.245655] sd 13:0:0:0: [sdb] No Caching mode page present
[174969.245662] sd 13:0:0:0: [sdb] Assuming drive cache: write through
[174969.245666] sd 13:0:0:0: [sdb] Attached SCSI disk
[174973.676976] XFS (sdb1): Mounting Filesystem
[174973.783933] XFS (sdb1): Ending clean mount
[175039.726799] usb 1-1.3: USB disconnect, device number 18
[182603.839516] EXT4-fs (sda4): re-mounted. Opts: commit=0
[182604.476899] PM: Syncing filesystems ... done.
[182604.663984] PM: Preparing system for mem sleep
[182608.352366] Freezing user space processes ... (elapsed 0.01 seconds) done.
[182608.366695] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
[182608.380037] PM: Entering mem sleep
[182608.380103] Suspending console(s) (use no_console_suspend to debug)
[182608.387472] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[182608.388776] sd 0:0:0:0: [sda] Stopping disk
[182608.390293] brcmsmac 0000:02:00.0: PCI INT A disabled
[182608.423337] uhci_hcd 0000:00:1d.0: PCI INT B disabled
[182608.423411] uhci_hcd 0000:00:1a.0: PCI INT B disabled
[182608.426567] ehci_hcd 0000:00:1d.7: PCI INT A disabled
[182608.469821] ehci_hcd 0000:00:1a.7: PCI INT A disabled
[182608.493329] snd_hda_intel 0000:00:1b.0: PCI INT A disabled
[182609.817897] ata_piix 0000:00:1f.2: PCI INT B disabled
[182609.831203] PM: suspend of devices complete after 1451.819 msecs
[182609.832429] ehci_hcd 0000:00:1d.7: PME# enabled
[182609.832459] ehci_hcd 0000:00:1d.7: wake-up capability enabled by ACPI
[182609.844824] ehci_hcd 0000:00:1a.7: PME# enabled
[182609.844854] ehci_hcd 0000:00:1a.7: wake-up capability enabled by ACPI
[182609.871246] PM: late suspend of devices complete after 40.089 msecs
[182609.872029] ACPI: Preparing to enter system sleep state S3
[182609.897858] PM: Saving platform NVS memory
[182609.900452] Disabling non-boot CPUs ...
[182610.004192] CPU 1 is now offline
[182610.008401] CPU 2 is now offline
[182610.011798] CPU 3 is now offline
[182610.011803] lockdep: fixing up alternatives.
[182610.013034] Extended CMOS year: 2000
[182610.013942] ACPI: Low-level resume complete
[182610.014022] PM: Restoring platform NVS memory
[182610.014399] Extended CMOS year: 2000
[182610.014457] Enabling non-boot CPUs ...
[182610.021636] lockdep: fixing up alternatives.
[182610.021647] Booting Node 0 Processor 1 APIC 0x2
[182610.021651] smpboot cpu 1: start_ip = 9a000
[182610.033060] Calibrating delay loop (skipped) already calibrated this CPU
[182610.056713] NMI watchdog enabled, takes one hw-pmu counter.
[182610.060877] CPU1 is up
[182610.068011] lockdep: fixing up alternatives.
[182610.068021] Booting Node 0 Processor 2 APIC 0x1
[182610.068025] smpboot cpu 2: start_ip = 9a000
[182610.079569] Calibrating delay loop (skipped) already calibrated this CPU
[182610.101740] NMI watchdog enabled, takes one hw-pmu counter.
[182610.104231] CPU2 is up
[182610.110788] lockdep: fixing up alternatives.
[182610.110801] Booting Node 0 Processor 3 APIC 0x3
[182610.110805] smpboot cpu 3: start_ip = 9a000
[182610.122232] Calibrating delay loop (skipped) already calibrated this CPU
[182610.147764] NMI watchdog enabled, takes one hw-pmu counter.
[182610.150819] CPU3 is up
[182610.160862] ACPI: Waking up from system sleep state S3
[182610.661603] pcieport 0000:00:01.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[182610.661625] pcieport 0000:00:01.0: restoring config space at offset 0x9 (was 0x1fff1, writing 0xa891a4a1)
[182610.661635] pcieport 0000:00:01.0: restoring config space at offset 0x8 (was 0xfff0, writing 0xa490a070)
[182610.661644] pcieport 0000:00:01.0: restoring config space at offset 0x7 (was 0x200000f0, writing 0x3030)
[182610.661658] pcieport 0000:00:01.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[182610.661669] pcieport 0000:00:01.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[182610.661741] i915 0000:00:02.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[182610.661773] i915 0000:00:02.0: restoring config space at offset 0x1 (was 0x900007, writing 0x900407)
[182610.661842] mei 0000:00:16.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[182610.661884] mei 0000:00:16.0: restoring config space at offset 0x4 (was 0xfed1b004, writing 0xa0607104)
[182610.661946] uhci_hcd 0000:00:1a.0: restoring config space at offset 0xf (was 0x200, writing 0x20a)
[182610.661976] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x8 (was 0x1, writing 0x2141)
[182610.662006] uhci_hcd 0000:00:1a.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[182610.662067] ehci_hcd 0000:00:1a.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[182610.662110] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606c00)
[182610.662128] ehci_hcd 0000:00:1a.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[182610.662183] ehci_hcd 0000:00:1a.7: wake-up capability disabled by ACPI
[182610.662197] ehci_hcd 0000:00:1a.7: PME# disabled
[182610.662241] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[182610.662284] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0600004)
[182610.662295] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[182610.662310] snd_hda_intel 0000:00:1b.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100002)
[182610.662390] pcieport 0000:00:1c.0: restoring config space at offset 0xf (was 0x100, writing 0x1ff)
[182610.662418] pcieport 0000:00:1c.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[182610.662430] pcieport 0000:00:1c.0: restoring config space at offset 0x8 (was 0x0, writing 0xa050a050)
[182610.662442] pcieport 0000:00:1c.0: restoring config space at offset 0x7 (was 0x20000000, writing 0x200000f0)
[182610.662454] pcieport 0000:00:1c.0: restoring config space at offset 0x6 (was 0x0, writing 0x10100)
[182610.662472] pcieport 0000:00:1c.0: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[182610.662487] pcieport 0000:00:1c.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[182610.662581] pcieport 0000:00:1c.1: restoring config space at offset 0xf (was 0x200, writing 0x2ff)
[182610.662608] pcieport 0000:00:1c.1: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[182610.662620] pcieport 0000:00:1c.1: restoring config space at offset 0x8 (was 0x0, writing 0xa040a040)
[182610.662632] pcieport 0000:00:1c.1: restoring config space at offset 0x7 (was 0x20000000, writing 0x200000f0)
[182610.662644] pcieport 0000:00:1c.1: restoring config space at offset 0x6 (was 0x0, writing 0x20200)
[182610.662662] pcieport 0000:00:1c.1: restoring config space at offset 0x3 (was 0x810000, writing 0x810040)
[182610.662677] pcieport 0000:00:1c.1: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[182610.662748] uhci_hcd 0000:00:1d.0: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[182610.662778] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x8 (was 0x1, writing 0x20e1)
[182610.662809] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900001)
[182610.662869] ehci_hcd 0000:00:1d.7: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[182610.662911] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x4 (was 0x0, writing 0xa0606800)
[182610.662929] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x1 (was 0x2900000, writing 0x2900002)
[182610.662981] ehci_hcd 0000:00:1d.7: wake-up capability disabled by ACPI
[182610.662994] ehci_hcd 0000:00:1d.7: PME# disabled
[182610.663112] ata_piix 0000:00:1f.2: restoring config space at offset 0xf (was 0x200, writing 0x20b)
[182610.663142] ata_piix 0000:00:1f.2: restoring config space at offset 0x8 (was 0x1, writing 0x2061)
[182610.663153] ata_piix 0000:00:1f.2: restoring config space at offset 0x7 (was 0x1, writing 0x2179)
[182610.663165] ata_piix 0000:00:1f.2: restoring config space at offset 0x6 (was 0x1, writing 0x2161)
[182610.663176] ata_piix 0000:00:1f.2: restoring config space at offset 0x5 (was 0x1, writing 0x217d)
[182610.663187] ata_piix 0000:00:1f.2: restoring config space at offset 0x4 (was 0x1, writing 0x2169)
[182610.663205] ata_piix 0000:00:1f.2: restoring config space at offset 0x1 (was 0x2b00000, writing 0x2b00007)
[182610.663247] i801_smbus 0000:00:1f.3: restoring config space at offset 0xf (was 0x300, writing 0x30b)
[182610.663289] i801_smbus 0000:00:1f.3: restoring config space at offset 0x4 (was 0x4, writing 0xa0607004)
[182610.663307] i801_smbus 0000:00:1f.3: restoring config space at offset 0x1 (was 0x2800001, writing 0x2800003)
[182610.663376] pcieport 0000:03:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[182610.663386] pcieport 0000:03:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a070)
[182610.663396] pcieport 0000:03:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[182610.663405] pcieport 0000:03:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x670403)
[182610.663419] pcieport 0000:03:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[182610.663431] pcieport 0000:03:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[182610.663538] pcieport 0000:04:00.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[182610.663548] pcieport 0000:04:00.0: restoring config space at offset 0x8 (was 0x0, writing 0xa070a070)
[182610.663557] pcieport 0000:04:00.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[182610.663567] pcieport 0000:04:00.0: restoring config space at offset 0x6 (was 0x0, writing 0x50504)
[182610.663582] pcieport 0000:04:00.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[182610.663594] pcieport 0000:04:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[182610.663701] pcieport 0000:04:03.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[182610.663711] pcieport 0000:04:03.0: restoring config space at offset 0x8 (was 0x0, writing 0xa080a080)
[182610.663720] pcieport 0000:04:03.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[182610.663730] pcieport 0000:04:03.0: restoring config space at offset 0x6 (was 0x0, writing 0x360604)
[182610.663744] pcieport 0000:04:03.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[182610.663756] pcieport 0000:04:03.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[182610.663864] pcieport 0000:04:04.0: restoring config space at offset 0x9 (was 0x10001, writing 0x1fff1)
[182610.663873] pcieport 0000:04:04.0: restoring config space at offset 0x8 (was 0x0, writing 0xa090a090)
[182610.663883] pcieport 0000:04:04.0: restoring config space at offset 0x7 (was 0x101, writing 0x1f1)
[182610.663893] pcieport 0000:04:04.0: restoring config space at offset 0x6 (was 0x0, writing 0x673704)
[182610.663907] pcieport 0000:04:04.0: restoring config space at offset 0x3 (was 0x10000, writing 0x10040)
[182610.663919] pcieport 0000:04:04.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100406)
[182610.664019] pci 0000:05:00.0: restoring config space at offset 0xf (was 0x1ff, writing 0x10b)
[182610.664053] pci 0000:05:00.0: restoring config space at offset 0x5 (was 0x0, writing 0xa0740000)
[182610.664063] pci 0000:05:00.0: restoring config space at offset 0x4 (was 0x0, writing 0xa0700000)
[182610.664073] pci 0000:05:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[182610.664086] pci 0000:05:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100007)
[182610.664242] brcmsmac 0000:02:00.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[182610.664315] brcmsmac 0000:02:00.0: restoring config space at offset 0x4 (was 0x4, writing 0xa0400004)
[182610.664331] brcmsmac 0000:02:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x40)
[182610.664353] brcmsmac 0000:02:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)
[182610.665076] PM: early resume of devices complete after 3.726 msecs
[182610.665315] i915 0000:00:02.0: setting latency timer to 64
[182610.666266] mei 0000:00:16.0: irq 45 for MSI/MSI-X
[182610.666330] uhci_hcd 0000:00:1a.0: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[182610.666349] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[182610.666395] usb usb3: root hub lost power or was reset
[182610.666430] ehci_hcd 0000:00:1a.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[182610.666451] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[182610.666458] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[182610.666476] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[182610.666605] uhci_hcd 0000:00:1d.0: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[182610.666616] snd_hda_intel 0000:00:1b.0: irq 46 for MSI/MSI-X
[182610.666623] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[182610.666672] usb usb4: root hub lost power or was reset
[182610.666716] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[182610.666737] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[182610.666804] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[182610.666819] ata_piix 0000:00:1f.2: setting latency timer to 64
[182610.666965] brcmsmac 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[182610.666984] brcmsmac 0000:02:00.0: setting latency timer to 64
[182610.670087] sd 0:0:0:0: [sda] Starting disk
[182611.686220] ata2.00: failed to resume link (SControl 0)
[182612.005716] ata1.01: failed to resume link (SControl 0)
[182612.158892] ata1.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[182612.158912] ata1.01: SATA link down (SStatus 0 SControl 0)
[182612.165780] ata1.00: ACPI cmd ef/03:46:00:00:00:a0 (SET FEATURES) filtered out
[182612.172602] ata1.00: configured for UDMA/133
[182612.253152] ieee80211 phy0: brcms_ops_config: change monitor mode: false (implement)
[182612.253160] ieee80211 phy0: brcms_ops_config: change power-save mode: false (implement)
[182612.254265] ieee80211 phy0: brcmsmac: brcms_ops_bss_info_changed: associated
[182612.254285] ieee80211 phy0: changing basic rates failed: -22
[182612.254293] ieee80211 phy0: brcms_ops_bss_info_changed: cqm change: threshold 0, hys 0  (implement)
[182612.254297] ieee80211 phy0: brcms_ops_bss_info_changed: qos enabled: true (implement)
[182612.475258] ieee80211 phy0: brcms_ops_bss_info_changed: qos enabled: false (implement)
[182612.475328] ieee80211 phy0: brcmsmac: brcms_ops_bss_info_changed: disassociated
[182612.475340] ieee80211 phy0: brcms_ops_bss_info_changed: arp filtering: enabled false, count 1 (implement)
[182612.625338] cfg80211: Calling CRDA for country: X3
[182612.707965] ata2.01: failed to resume link (SControl 0)
[182612.719804] ata2.00: SATA link down (SStatus 4 SControl 0)
[182612.719826] ata2.01: SATA link down (SStatus 0 SControl 0)
[182612.819698] PM: resume of devices complete after 2157.899 msecs
[182612.823169] PM: Finishing wakeup.
[182612.823173] Restarting tasks ... done.
[182612.883746] video LNXVIDEO:00: Restoring backlight state
[182614.885284] EXT4-fs (sda4): re-mounted. Opts: commit=600
[182663.311684] wlan0: direct probe to 00:13:60:2b:90:40 (try 1/3)
[182663.508794] wlan0: direct probe to 00:13:60:2b:90:40 (try 2/3)
[182663.708442] wlan0: direct probe to 00:13:60:2b:90:40 (try 3/3)
[182663.908177] wlan0: direct probe to 00:13:60:2b:90:40 timed out
[182675.236427] wlan0: authenticate with 04:46:65:8b:88:32 (try 1)
[182675.247574] wlan0: authenticated
[182675.247706] wlan0: associate with 04:46:65:8b:88:32 (try 1)
[182675.250898] wlan0: RX AssocResp from 04:46:65:8b:88:32 (capab=0x431 status=0 aid=1)
[182675.250906] wlan0: associated
[182675.252130] ieee80211 phy0: brcms_ops_bss_info_changed: qos enabled: true (implement)
[182675.252148] ieee80211 phy0: brcmsmac: brcms_ops_bss_info_changed: associated
[182675.252160] ieee80211 phy0: changing basic rates failed: -22
[182675.252168] ieee80211 phy0: brcms_ops_bss_info_changed: arp filtering: enabled true, count 0 (implement)
[182692.417378] ieee80211 phy0: brcms_ops_bss_info_changed: arp filtering: enabled true, count 1 (implement)
[185231.431364] ieee80211 phy0: brcms_ops_bss_info_changed: qos enabled: false (implement)
[185231.431395] ieee80211 phy0: brcmsmac: brcms_ops_bss_info_changed: disassociated
[185231.431409] ieee80211 phy0: brcms_ops_bss_info_changed: arp filtering: enabled false, count 1 (implement)
[185231.570209] cfg80211: Calling CRDA for country: CH
[185233.609447] wlan0: direct probe to c8:6c:87:a9:df:a9 (try 1/3)
[185233.806490] wlan0: direct probe to c8:6c:87:a9:df:a9 (try 2/3)
[185234.006169] wlan0: direct probe to c8:6c:87:a9:df:a9 (try 3/3)
[185234.205889] wlan0: direct probe to c8:6c:87:a9:df:a9 timed out
[185472.274842] INFO: task chromium:11616 blocked for more than 120 seconds.
[185472.274850] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[185472.274856] chromium        D 0000000000000000     0 11616      1 0x00000000
[185472.274867]  ffff88003dd6bb08 0000000000000046 ffffffff81439fd0 800000011e07a067
[185472.274879]  ffffffff81040d57 0000000000000246 ffff88007f650000 ffff88003dd6bfd8
[185472.274890]  ffff88003dd6bfd8 ffff88003dd6bfd8 ffff880168b72f10 ffff88007f650000
[185472.274901] Call Trace:
[185472.274917]  [<ffffffff81439fd0>] ? __schedule+0x790/0xa30
[185472.274928]  [<ffffffff81040d57>] ? do_page_fault+0xf7/0x4e0
[185472.274940]  [<ffffffff810a2d61>] ? mark_held_locks+0x61/0x140
[185472.274949]  [<ffffffff8143bf6d>] ? mutex_lock_nested+0x23d/0x3d0
[185472.274958]  [<ffffffff8143a39f>] schedule+0x3f/0x60
[185472.274967]  [<ffffffff8143beaf>] mutex_lock_nested+0x17f/0x3d0
[185472.274975]  [<ffffffff81380e77>] ? rtnl_lock+0x17/0x20
[185472.274983]  [<ffffffff8139a903>] ? netlink_unicast+0x123/0x320
[185472.274991]  [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185472.274998]  [<ffffffff81380e96>] rtnetlink_rcv+0x16/0x40
[185472.275009]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.275015]  [<ffffffff8139aab9>] netlink_unicast+0x2d9/0x320
[185472.275023]  [<ffffffff8139ae86>] netlink_sendmsg+0x2c6/0x320
[185472.275032]  [<ffffffff8135ced0>] ? sock_update_classid+0xb0/0x110
[185472.275042]  [<ffffffff81358cae>] sock_sendmsg+0x10e/0x130
[185472.275051]  [<ffffffff8104e302>] ? __wake_up+0x32/0x70
[185472.275060]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.275068]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.275077]  [<ffffffff81134649>] ? might_fault+0x89/0x90
[185472.275085]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.275094]  [<ffffffff8135a811>] ? move_addr_to_kernel+0x71/0x80
[185472.275103]  [<ffffffff8135b37d>] sys_sendto+0x13d/0x190
[185472.275112]  [<ffffffff8143e97a>] ? sysret_check+0x2e/0x69
[185472.275121]  [<ffffffff810a2f4d>] ? trace_hardirqs_on_caller+0x10d/0x1a0
[185472.275130]  [<ffffffff812548ae>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[185472.275138]  [<ffffffff8143e942>] system_call_fastpath+0x16/0x1b
[185472.275145] 1 lock held by chromium/11616:
[185472.275148]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185472.275164] INFO: task chromium:15038 blocked for more than 120 seconds.
[185472.275168] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[185472.275173] chromium        D 0000000000000000     0 15038      1 0x00000000
[185472.275182]  ffff880077215b08 0000000000000046 ffffffff81439fd0 ffff880046c6bf00
[185472.275192]  ffffffff8105151f 0000000000000002 ffff88007f654e70 ffff880077215fd8
[185472.275203]  ffff880077215fd8 ffff880077215fd8 ffff880168b72f10 ffff88007f654e70
[185472.275213] Call Trace:
[185472.275221]  [<ffffffff81439fd0>] ? __schedule+0x790/0xa30
[185472.275230]  [<ffffffff8105151f>] ? finish_task_switch+0x3f/0x110
[185472.275239]  [<ffffffff810a2d61>] ? mark_held_locks+0x61/0x140
[185472.275248]  [<ffffffff8143bf6d>] ? mutex_lock_nested+0x23d/0x3d0
[185472.275256]  [<ffffffff8143a39f>] schedule+0x3f/0x60
[185472.275265]  [<ffffffff8143beaf>] mutex_lock_nested+0x17f/0x3d0
[185472.275271]  [<ffffffff81380e77>] ? rtnl_lock+0x17/0x20
[185472.275278]  [<ffffffff8139a903>] ? netlink_unicast+0x123/0x320
[185472.275285]  [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185472.275292]  [<ffffffff81380e96>] rtnetlink_rcv+0x16/0x40
[185472.275300]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.275307]  [<ffffffff8139aab9>] netlink_unicast+0x2d9/0x320
[185472.275313]  [<ffffffff8139ae86>] netlink_sendmsg+0x2c6/0x320
[185472.275321]  [<ffffffff8135ced0>] ? sock_update_classid+0xb0/0x110
[185472.275329]  [<ffffffff81358cae>] sock_sendmsg+0x10e/0x130
[185472.275337]  [<ffffffff8104e302>] ? __wake_up+0x32/0x70
[185472.275346]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.275354]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.275363]  [<ffffffff81134649>] ? might_fault+0x89/0x90
[185472.275372]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.275400]  [<ffffffff8135a811>] ? move_addr_to_kernel+0x71/0x80
[185472.275412]  [<ffffffff8135b37d>] sys_sendto+0x13d/0x190
[185472.275425]  [<ffffffff8143e97a>] ? sysret_check+0x2e/0x69
[185472.275438]  [<ffffffff810a2f4d>] ? trace_hardirqs_on_caller+0x10d/0x1a0
[185472.275449]  [<ffffffff812548ae>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[185472.275462]  [<ffffffff8143e942>] system_call_fastpath+0x16/0x1b
[185472.275471] 1 lock held by chromium/15038:
[185472.275476]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185472.275495] INFO: task chromium:15039 blocked for more than 120 seconds.
[185472.275499] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[185472.275504] chromium        D 0000000000000000     0 15039      1 0x00000000
[185472.275513]  ffff880059923b08 0000000000000046 ffffffff81439fd0 8000000108b31067
[185472.275523]  ffffffff81040d57 0000000000000246 ffff88007f652f10 ffff880059923fd8
[185472.275534]  ffff880059923fd8 ffff880059923fd8 ffff880168bb8000 ffff88007f652f10
[185472.275544] Call Trace:
[185472.275552]  [<ffffffff81439fd0>] ? __schedule+0x790/0xa30
[185472.275560]  [<ffffffff81040d57>] ? do_page_fault+0xf7/0x4e0
[185472.275569]  [<ffffffff810a2d61>] ? mark_held_locks+0x61/0x140
[185472.275578]  [<ffffffff8143bf6d>] ? mutex_lock_nested+0x23d/0x3d0
[185472.275587]  [<ffffffff8143a39f>] schedule+0x3f/0x60
[185472.275594]  [<ffffffff8143beaf>] mutex_lock_nested+0x17f/0x3d0
[185472.275601]  [<ffffffff81380e77>] ? rtnl_lock+0x17/0x20
[185472.275608]  [<ffffffff8139a903>] ? netlink_unicast+0x123/0x320
[185472.275615]  [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185472.275622]  [<ffffffff81380e96>] rtnetlink_rcv+0x16/0x40
[185472.275630]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.275637]  [<ffffffff8139aab9>] netlink_unicast+0x2d9/0x320
[185472.275643]  [<ffffffff8139ae86>] netlink_sendmsg+0x2c6/0x320
[185472.275650]  [<ffffffff8135ced0>] ? sock_update_classid+0xb0/0x110
[185472.275659]  [<ffffffff81358cae>] sock_sendmsg+0x10e/0x130
[185472.275667]  [<ffffffff8104e302>] ? __wake_up+0x32/0x70
[185472.275675]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.275684]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.275693]  [<ffffffff81134649>] ? might_fault+0x89/0x90
[185472.275701]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.275709]  [<ffffffff8135a811>] ? move_addr_to_kernel+0x71/0x80
[185472.275718]  [<ffffffff8135b37d>] sys_sendto+0x13d/0x190
[185472.275725]  [<ffffffff8143e97a>] ? sysret_check+0x2e/0x69
[185472.275734]  [<ffffffff810a2f4d>] ? trace_hardirqs_on_caller+0x10d/0x1a0
[185472.275742]  [<ffffffff812548ae>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[185472.275749]  [<ffffffff8143e942>] system_call_fastpath+0x16/0x1b
[185472.275754] 1 lock held by chromium/15039:
[185472.275758]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185472.275770] INFO: task chromium:15041 blocked for more than 120 seconds.
[185472.275774] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[185472.275779] chromium        D 0000000000000000     0 15041      1 0x00000000
[185472.275787]  ffff8800599f5b08 0000000000000046 ffffffff81439fd0 ffff880049a81200
[185472.275798]  ffffffff8105151f 0000000000000002 ffff88007f656dd0 ffff8800599f5fd8
[185472.275808]  ffff8800599f5fd8 ffff8800599f5fd8 ffff880168b72f10 ffff88007f656dd0
[185472.275818] Call Trace:
[185472.275825]  [<ffffffff81439fd0>] ? __schedule+0x790/0xa30
[185472.275834]  [<ffffffff8105151f>] ? finish_task_switch+0x3f/0x110
[185472.275844]  [<ffffffff810a2d61>] ? mark_held_locks+0x61/0x140
[185472.275852]  [<ffffffff8143bf6d>] ? mutex_lock_nested+0x23d/0x3d0
[185472.275861]  [<ffffffff8143a39f>] schedule+0x3f/0x60
[185472.275869]  [<ffffffff8143beaf>] mutex_lock_nested+0x17f/0x3d0
[185472.275876]  [<ffffffff81380e77>] ? rtnl_lock+0x17/0x20
[185472.275882]  [<ffffffff8139a903>] ? netlink_unicast+0x123/0x320
[185472.275889]  [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185472.275896]  [<ffffffff81380e96>] rtnetlink_rcv+0x16/0x40
[185472.275904]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.275911]  [<ffffffff8139aab9>] netlink_unicast+0x2d9/0x320
[185472.275918]  [<ffffffff8139ae86>] netlink_sendmsg+0x2c6/0x320
[185472.275925]  [<ffffffff8135ced0>] ? sock_update_classid+0xb0/0x110
[185472.275933]  [<ffffffff81358cae>] sock_sendmsg+0x10e/0x130
[185472.275941]  [<ffffffff8104e302>] ? __wake_up+0x32/0x70
[185472.275950]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.275958]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.275967]  [<ffffffff81134649>] ? might_fault+0x89/0x90
[185472.275975]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.275983]  [<ffffffff8135a811>] ? move_addr_to_kernel+0x71/0x80
[185472.275992]  [<ffffffff8135b37d>] sys_sendto+0x13d/0x190
[185472.275999]  [<ffffffff8143e97a>] ? sysret_check+0x2e/0x69
[185472.276008]  [<ffffffff810a2f4d>] ? trace_hardirqs_on_caller+0x10d/0x1a0
[185472.276016]  [<ffffffff812548ae>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[185472.276023]  [<ffffffff8143e942>] system_call_fastpath+0x16/0x1b
[185472.276029] 1 lock held by chromium/15041:
[185472.276032]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185472.276046] INFO: task chromium:15045 blocked for more than 120 seconds.
[185472.276050] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[185472.276055] chromium        D 0000000000000000     0 15045      1 0x00000000
[185472.276063]  ffff88006fae3b08 0000000000000046 ffffffff81439fd0 8000000003655067
[185472.276073]  ffffffff81040d57 0000000000000246 ffff880166546dd0 ffff88006fae3fd8
[185472.276083]  ffff88006fae3fd8 ffff88006fae3fd8 ffffffff8180d020 ffff880166546dd0
[185472.276094] Call Trace:
[185472.276101]  [<ffffffff81439fd0>] ? __schedule+0x790/0xa30
[185472.276109]  [<ffffffff81040d57>] ? do_page_fault+0xf7/0x4e0
[185472.276118]  [<ffffffff810a2fed>] ? trace_hardirqs_on+0xd/0x10
[185472.276126]  [<ffffffff810a2d61>] ? mark_held_locks+0x61/0x140
[185472.276135]  [<ffffffff8143bf6d>] ? mutex_lock_nested+0x23d/0x3d0
[185472.276143]  [<ffffffff8143a39f>] schedule+0x3f/0x60
[185472.276152]  [<ffffffff8143beaf>] mutex_lock_nested+0x17f/0x3d0
[185472.276158]  [<ffffffff81380e77>] ? rtnl_lock+0x17/0x20
[185472.276165]  [<ffffffff8139a903>] ? netlink_unicast+0x123/0x320
[185472.276172]  [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185472.276178]  [<ffffffff81380e96>] rtnetlink_rcv+0x16/0x40
[185472.276187]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.276193]  [<ffffffff8139aab9>] netlink_unicast+0x2d9/0x320
[185472.276200]  [<ffffffff8139ae86>] netlink_sendmsg+0x2c6/0x320
[185472.276207]  [<ffffffff8135ced0>] ? sock_update_classid+0xb0/0x110
[185472.276215]  [<ffffffff81358cae>] sock_sendmsg+0x10e/0x130
[185472.276223]  [<ffffffff8104e302>] ? __wake_up+0x32/0x70
[185472.276232]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.276240]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.276249]  [<ffffffff81134649>] ? might_fault+0x89/0x90
[185472.276257]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.276265]  [<ffffffff8135a811>] ? move_addr_to_kernel+0x71/0x80
[185472.276274]  [<ffffffff8135b37d>] sys_sendto+0x13d/0x190
[185472.276281]  [<ffffffff8143e97a>] ? sysret_check+0x2e/0x69
[185472.276290]  [<ffffffff810a2f4d>] ? trace_hardirqs_on_caller+0x10d/0x1a0
[185472.276298]  [<ffffffff812548ae>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[185472.276305]  [<ffffffff8143e942>] system_call_fastpath+0x16/0x1b
[185472.276311] 1 lock held by chromium/15045:
[185472.276314]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185472.276338] INFO: task wpa_supplicant:28973 blocked for more than 120 seconds.
[185472.276342] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[185472.276347] wpa_supplicant  D 0000000000000000     0 28973      1 0x00000000
[185472.276355]  ffff8800412d9aa8 0000000000000046 ffffffff81439fd0 ffffffff00000555
[185472.276366]  ffff880100000002 ffff88011c1ea598 ffff88011c1e9f60 ffff8800412d9fd8
[185472.276376]  ffff8800412d9fd8 ffff8800412d9fd8 ffff880168b72f10 ffff88011c1e9f60
[185472.276386] Call Trace:
[185472.276394]  [<ffffffff81439fd0>] ? __schedule+0x790/0xa30
[185472.276404]  [<ffffffff811877c0>] ? poll_select_set_timeout+0x90/0x90
[185472.276414]  [<ffffffff81265590>] ? nla_parse+0x90/0xe0
[185472.276423]  [<ffffffff810a2d61>] ? mark_held_locks+0x61/0x140
[185472.276431]  [<ffffffff810a2d61>] ? mark_held_locks+0x61/0x140
[185472.276439]  [<ffffffff8143bf6d>] ? mutex_lock_nested+0x23d/0x3d0
[185472.276448]  [<ffffffff8143a39f>] schedule+0x3f/0x60
[185472.276456]  [<ffffffff8143beaf>] mutex_lock_nested+0x17f/0x3d0
[185472.276494]  [<ffffffffa02ee520>] ? ieee80211_request_scan+0x30/0x60 [mac80211]
[185472.276525]  [<ffffffffa02ee520>] ieee80211_request_scan+0x30/0x60 [mac80211]
[185472.276547]  [<ffffffffa02fe20c>] ieee80211_scan+0x6c/0x90 [mac80211]
[185472.276565]  [<ffffffffa02be2a0>] cfg80211_wext_siwscan+0x2f0/0x370 [cfg80211]
[185472.276575]  [<ffffffff8140e989>] ioctl_standard_iw_point+0x1a9/0x3e0
[185472.276591]  [<ffffffffa02bdfb0>] ? cfg80211_find_vendor_ie+0x90/0x90 [cfg80211]
[185472.276600]  [<ffffffff8143bff5>] ? mutex_lock_nested+0x2c5/0x3d0
[185472.276607]  [<ffffffff81380e77>] ? rtnl_lock+0x17/0x20
[185472.276615]  [<ffffffff8140fb50>] ? iw_handler_get_private+0x60/0x60
[185472.276622]  [<ffffffff8140efd1>] ioctl_standard_call+0xb1/0xd0
[185472.276630]  [<ffffffff8136f3f4>] ? __dev_get_by_name+0xa4/0xe0
[185472.276637]  [<ffffffff8140edbc>] wext_ioctl_dispatch+0x1fc/0x240
[185472.276644]  [<ffffffff8140ef20>] ? call_commit_handler+0x40/0x40
[185472.276651]  [<ffffffff8140f0d6>] wext_handle_ioctl+0x46/0xa0
[185472.276659]  [<ffffffff813741bb>] dev_ioctl+0xdb/0x6e0
[185472.276668]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.276677]  [<ffffffff8135780a>] sock_ioctl+0x10a/0x2f0
[185472.276685]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.276693]  [<ffffffff81186698>] do_vfs_ioctl+0x98/0x560
[185472.276701]  [<ffffffff8143e97a>] ? sysret_check+0x2e/0x69
[185472.276709]  [<ffffffff81186bf1>] sys_ioctl+0x91/0xa0
[185472.276716]  [<ffffffff8143e942>] system_call_fastpath+0x16/0x1b
[185472.276722] 3 locks held by wpa_supplicant/28973:
[185472.276726]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185472.276738]  #1:  (&rdev->mtx){+.+.+.}, at: [<ffffffffa02b8a2a>] cfg80211_get_dev_from_ifindex+0x5a/0xa0 [cfg80211]
[185472.276757]  #2:  (&local->mtx){+.+.+.}, at: [<ffffffffa02ee520>] ieee80211_request_scan+0x30/0x60 [mac80211]
[185472.276790] INFO: task local:15105 blocked for more than 120 seconds.
[185472.276794] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[185472.276799] local           D 0000000000000000     0 15105  11600 0x00000000
[185472.276808]  ffff8800447d7b08 0000000000000046 ffffffff81439fd0 800000007c10c067
[185472.276818]  ffffffff81040d57 0000000000000246 ffff8801617a0fb0 ffff8800447d7fd8
[185472.276829]  ffff8800447d7fd8 ffff8800447d7fd8 ffff880168b72f10 ffff8801617a0fb0
[185472.276839] Call Trace:
[185472.276847]  [<ffffffff81439fd0>] ? __schedule+0x790/0xa30
[185472.276854]  [<ffffffff81040d57>] ? do_page_fault+0xf7/0x4e0
[185472.276864]  [<ffffffff810a2d61>] ? mark_held_locks+0x61/0x140
[185472.276873]  [<ffffffff8143bf6d>] ? mutex_lock_nested+0x23d/0x3d0
[185472.276881]  [<ffffffff8143a39f>] schedule+0x3f/0x60
[185472.276889]  [<ffffffff8143beaf>] mutex_lock_nested+0x17f/0x3d0
[185472.276896]  [<ffffffff81380e77>] ? rtnl_lock+0x17/0x20
[185472.276902]  [<ffffffff8139a903>] ? netlink_unicast+0x123/0x320
[185472.276910]  [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185472.276916]  [<ffffffff81380e96>] rtnetlink_rcv+0x16/0x40
[185472.276925]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.276931]  [<ffffffff8139aab9>] netlink_unicast+0x2d9/0x320
[185472.276938]  [<ffffffff8139ae86>] netlink_sendmsg+0x2c6/0x320
[185472.276946]  [<ffffffff8135ced0>] ? sock_update_classid+0xb0/0x110
[185472.276955]  [<ffffffff81358cae>] sock_sendmsg+0x10e/0x130
[185472.276962]  [<ffffffff8104e302>] ? __wake_up+0x32/0x70
[185472.276971]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.276979]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.276988]  [<ffffffff81134649>] ? might_fault+0x89/0x90
[185472.276996]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.277005]  [<ffffffff8135a811>] ? move_addr_to_kernel+0x71/0x80
[185472.277013]  [<ffffffff8135b37d>] sys_sendto+0x13d/0x190
[185472.277021]  [<ffffffff8143e97a>] ? sysret_check+0x2e/0x69
[185472.277030]  [<ffffffff810a2f4d>] ? trace_hardirqs_on_caller+0x10d/0x1a0
[185472.277038]  [<ffffffff812548ae>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[185472.277045]  [<ffffffff8143e942>] system_call_fastpath+0x16/0x1b
[185472.277050] 1 lock held by local/15105:
[185472.277054]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185472.277067] INFO: task fetchmail:15106 blocked for more than 120 seconds.
[185472.277071] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[185472.277075] fetchmail       D 0000000000000000     0 15106  29014 0x00000000
[185472.277084]  ffff88004210bb08 0000000000000046 ffffffff81439fd0 ffffffff8186f460
[185472.277094]  ffff8801617a0000 0000000000000000 ffff8801617a0000 ffff88004210bfd8
[185472.277104]  ffff88004210bfd8 ffff88004210bfd8 ffff880168b72f10 ffff8801617a0000
[185472.277114] Call Trace:
[185472.277122]  [<ffffffff81439fd0>] ? __schedule+0x790/0xa30
[185472.277131]  [<ffffffff810a04f1>] ? __lock_acquire+0x361/0x1d10
[185472.277140]  [<ffffffff810a2d61>] ? mark_held_locks+0x61/0x140
[185472.277148]  [<ffffffff8143bf6d>] ? mutex_lock_nested+0x23d/0x3d0
[185472.277157]  [<ffffffff8143a39f>] schedule+0x3f/0x60
[185472.277165]  [<ffffffff8143beaf>] mutex_lock_nested+0x17f/0x3d0
[185472.277171]  [<ffffffff81380e77>] ? rtnl_lock+0x17/0x20
[185472.277178]  [<ffffffff8139a903>] ? netlink_unicast+0x123/0x320
[185472.277185]  [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185472.277192]  [<ffffffff81380e96>] rtnetlink_rcv+0x16/0x40
[185472.277200]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.277206]  [<ffffffff8139aab9>] netlink_unicast+0x2d9/0x320
[185472.277213]  [<ffffffff8139ae86>] netlink_sendmsg+0x2c6/0x320
[185472.277220]  [<ffffffff8135ced0>] ? sock_update_classid+0xb0/0x110
[185472.277229]  [<ffffffff81358cae>] sock_sendmsg+0x10e/0x130
[185472.277238]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.277246]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.277255]  [<ffffffff81134649>] ? might_fault+0x89/0x90
[185472.277263]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185472.277272]  [<ffffffff8135a811>] ? move_addr_to_kernel+0x71/0x80
[185472.277280]  [<ffffffff8135b37d>] sys_sendto+0x13d/0x190
[185472.277287]  [<ffffffff8143df5d>] ? retint_swapgs+0x13/0x1b
[185472.277296]  [<ffffffff810a2f4d>] ? trace_hardirqs_on_caller+0x10d/0x1a0
[185472.277304]  [<ffffffff812548ae>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[185472.277311]  [<ffffffff8143e942>] system_call_fastpath+0x16/0x1b
[185472.277317] 1 lock held by fetchmail/15106:
[185472.277320]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185592.088121] INFO: task chromium:11616 blocked for more than 120 seconds.
[185592.088133] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[185592.088141] chromium        D 0000000000000000     0 11616      1 0x00000000
[185592.088159]  ffff88003dd6bb08 0000000000000046 ffffffff81439fd0 800000011e07a067
[185592.088178]  ffffffff81040d57 0000000000000246 ffff88007f650000 ffff88003dd6bfd8
[185592.088197]  ffff88003dd6bfd8 ffff88003dd6bfd8 ffff880168b72f10 ffff88007f650000
[185592.088216] Call Trace:
[185592.088236]  [<ffffffff81439fd0>] ? __schedule+0x790/0xa30
[185592.088251]  [<ffffffff81040d57>] ? do_page_fault+0xf7/0x4e0
[185592.088267]  [<ffffffff810a2d61>] ? mark_held_locks+0x61/0x140
[185592.088279]  [<ffffffff8143bf6d>] ? mutex_lock_nested+0x23d/0x3d0
[185592.088292]  [<ffffffff8143a39f>] schedule+0x3f/0x60
[185592.088304]  [<ffffffff8143beaf>] mutex_lock_nested+0x17f/0x3d0
[185592.088317]  [<ffffffff81380e77>] ? rtnl_lock+0x17/0x20
[185592.088328]  [<ffffffff8139a903>] ? netlink_unicast+0x123/0x320
[185592.088340]  [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185592.088350]  [<ffffffff81380e96>] rtnetlink_rcv+0x16/0x40
[185592.088364]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185592.088374]  [<ffffffff8139aab9>] netlink_unicast+0x2d9/0x320
[185592.088384]  [<ffffffff8139ae86>] netlink_sendmsg+0x2c6/0x320
[185592.088397]  [<ffffffff8135ced0>] ? sock_update_classid+0xb0/0x110
[185592.088411]  [<ffffffff81358cae>] sock_sendmsg+0x10e/0x130
[185592.088422]  [<ffffffff8104e302>] ? __wake_up+0x32/0x70
[185592.088435]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185592.088447]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185592.088460]  [<ffffffff81134649>] ? might_fault+0x89/0x90
[185592.088471]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185592.088484]  [<ffffffff8135a811>] ? move_addr_to_kernel+0x71/0x80
[185592.088498]  [<ffffffff8135b37d>] sys_sendto+0x13d/0x190
[185592.088512]  [<ffffffff8143e97a>] ? sysret_check+0x2e/0x69
[185592.088525]  [<ffffffff810a2f4d>] ? trace_hardirqs_on_caller+0x10d/0x1a0
[185592.088540]  [<ffffffff812548ae>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[185592.088552]  [<ffffffff8143e942>] system_call_fastpath+0x16/0x1b
[185592.088562] 1 lock held by chromium/11616:
[185592.088567]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185592.088591] INFO: task chromium:11722 blocked for more than 120 seconds.
[185592.088598] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[185592.088606] chromium        D 0000000000000000     0 11722      1 0x00000000
[185592.088621]  ffff88007eea7b08 0000000000000046 ffffffff81439fd0 ffff880166afc800
[185592.088638]  ffffffff8105151f 0000000000000002 ffff880070591f60 ffff88007eea7fd8
[185592.088670]  ffff88007eea7fd8 ffff88007eea7fd8 ffff880168bb8000 ffff880070591f60
[185592.088686] Call Trace:
[185592.088700]  [<ffffffff81439fd0>] ? __schedule+0x790/0xa30
[185592.088715]  [<ffffffff8105151f>] ? finish_task_switch+0x3f/0x110
[185592.088729]  [<ffffffff810a2d61>] ? mark_held_locks+0x61/0x140
[185592.088759]  [<ffffffff8143bf6d>] ? mutex_lock_nested+0x23d/0x3d0
[185592.088773]  [<ffffffff8143a39f>] schedule+0x3f/0x60
[185592.088786]  [<ffffffff8143beaf>] mutex_lock_nested+0x17f/0x3d0
[185592.088797]  [<ffffffff81380e77>] ? rtnl_lock+0x17/0x20
[185592.088807]  [<ffffffff8139a903>] ? netlink_unicast+0x123/0x320
[185592.088819]  [<ffffffff81380e77>] rtnl_lock+0x17/0x20
[185592.088829]  [<ffffffff81380e96>] rtnetlink_rcv+0x16/0x40
[185592.088842]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185592.088852]  [<ffffffff8139aab9>] netlink_unicast+0x2d9/0x320
[185592.088863]  [<ffffffff8139ae86>] netlink_sendmsg+0x2c6/0x320
[185592.088875]  [<ffffffff8135ced0>] ? sock_update_classid+0xb0/0x110
[185592.088887]  [<ffffffff81358cae>] sock_sendmsg+0x10e/0x130
[185592.088898]  [<ffffffff8104e302>] ? __wake_up+0x32/0x70
[185592.088911]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185592.088923]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185592.088936]  [<ffffffff81134649>] ? might_fault+0x89/0x90
[185592.088948]  [<ffffffff81134600>] ? might_fault+0x40/0x90
[185592.088960]  [<ffffffff8135a811>] ? move_addr_to_kernel+0x71/0x80
[185592.088973]  [<ffffffff8135b37d>] sys_sendto+0x13d/0x190
[185592.088986]  [<ffffffff8143e97a>] ? sysret_check+0x2e/0x69
[185592.088999]  [<ffffffff810a2f4d>] ? trace_hardirqs_on_caller+0x10d/0x1a0
[185592.089011]  [<ffffffff812548ae>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[185592.089023]  [<ffffffff8143e942>] system_call_fastpath+0x16/0x1b
[185592.089033] 1 lock held by chromium/11722:
[185592.089039]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81380e77>] rtnl_lock+0x17/0x20

--NzB8fVQJ5HfG6fxh--
