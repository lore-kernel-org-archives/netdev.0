From: Lance Lassetter <lancelassetter@gmail.com>
Subject: Re: r8169 with 3.9.0-rc9
Date: Wed, 1 May 2013 21:18:50 -0500
Message-ID: <20130502021848.GA30099@gmail.com>
References: <20130426132254.GA22821@gmail.com>
 <20130426205018.GA18092@electric-eye.fr.zoreil.com>
 <20130427041230.GA18709@gmail.com>
 <20130428011232.GA4236@gmail.com>
 <20130501100733.GA16115@gmail.com>
 <20130501121502.GA5456@electric-eye.fr.zoreil.com>
 <20130501212803.GA3342@gmail.com>
 <20130501223155.GA15261@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="cWoXeonUoKmBZSoM"
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f52.google.com ([209.85.213.52]:62599 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759206Ab3EBCZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 22:25:21 -0400
Received: by mail-yh0-f52.google.com with SMTP id z6so27829yhz.39
        for <netdev@vger.kernel.org>; Wed, 01 May 2013 19:25:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130501223155.GA15261@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 02, 2013 at 12:31:55AM +0200, Francois Romieu wrote:
> Lance Lassetter <lancelassetter@gmail.com> :
> [...]
> > Yes, it was an up to date Fedora 17.  I know this is probably redundant but
> > I also tried Realtek firmware from a Debian Sid box onto the Fedora 18
> > using testing repos with vanilla stable kernel to the same result.
> > 
> > Should I file a Red Hat bug ?
> 
> Not yet.
> 
> > Manually change IRQs, what do you think?
> 
> I need the version of the last known working Fedora 17 kernel or
> your Fedora 18 install date if you can't retrieve it.
> 
> A complete dmesg and the content of /proc/interrupts will be welcome.
> 
> Thanks.
> 
> -- 
> Ueimor

Ueimor,

afaik, I think my last FC17 kernel was 3.8.8-100 and the Fedora 18 install date was the week of the Fedora 18 alpha release, afaik September of 2012.

Attached are /proc/interrupts and complete dmesg upon reboot.

HTH,

Lance

--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg.aout.txt"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.9.0-1.vanilla.mainline.knurd.1.fc18.x86_64 (mockbuild@buildvm-04.phx2.fedoraproject.org) (gcc version 4.7.2 20121109 (Red Hat 4.7.2-8) (GCC) ) #1 SMP Mon Apr 29 15:54:51 UTC 2013
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-3.9.0-1.vanilla.mainline.knurd.1.fc18.x86_64 root=UUID=f8be3722-4981-448e-9fba-bae666139bea ro rd.md=0 rd.lvm=0 rd.dm=0 SYSFONT=True KEYTABLE=us rd.luks=0 LANG=en_US.UTF-8 rhgb radeon.modeset=1 plymouth.enable=1
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e6000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000bfc4ffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bfc50000-0x00000000bfc5dfff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000bfc5e000-0x00000000bfca7fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bfca8000-0x00000000bfcdffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000bfcec000-0x00000000bfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ffe00000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000023fffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.5 present.
[    0.000000] DMI: Dell Inc. XPS 625/0P927G, BIOS 1.0.1 12/10/2008
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x240000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-EFFFF uncachable
[    0.000000]   F0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000000 mask FFFF80000000 write-back
[    0.000000]   1 base 000080000000 mask FFFFC0000000 write-back
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] TOM2: 0000000240000000 aka 9216M
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] e820: update [mem 0xc0000000-0xffffffff] usable ==> reserved
[    0.000000] e820: last_pfn = 0xbfc50 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000ff780-0x000ff78f] mapped at [ffff8800000ff780]
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x01fc3000, 0x01fc3fff] PGTABLE
[    0.000000] BRK [0x01fc4000, 0x01fc4fff] PGTABLE
[    0.000000] BRK [0x01fc5000, 0x01fc5fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x23fe00000-0x23fffffff]
[    0.000000]  [mem 0x23fe00000-0x23fffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x23c000000-0x23fdfffff]
[    0.000000]  [mem 0x23c000000-0x23fdfffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x200000000-0x23bffffff]
[    0.000000]  [mem 0x200000000-0x23bffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x00100000-0xbfc4ffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x3fffffff] page 2M
[    0.000000]  [mem 0x40000000-0x7fffffff] page 1G
[    0.000000]  [mem 0x80000000-0xbfbfffff] page 2M
[    0.000000]  [mem 0xbfc00000-0xbfc4ffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x100000000-0x1ffffffff]
[    0.000000]  [mem 0x100000000-0x1ffffffff] page 1G
[    0.000000] RAMDISK: [mem 0x359e2000-0x36ce8fff]
[    0.000000] ACPI: RSDP 00000000000fa1d0 00014 (v00 ACPIAM)
[    0.000000] ACPI: RSDT 00000000bfc50000 00044 (v01 DELL    MC09    20081210 MSFT 00000097)
[    0.000000] ACPI: FACP 00000000bfc50200 00084 (v01 121008 FACP1641 20081210 MSFT 00000097)
[    0.000000] ACPI BIOS Bug: Warning: Optional FADT field Pm2ControlBlock has zero address or length: 0x0000000000000000/0x1 (20130117/tbfadt-599)
[    0.000000] ACPI: DSDT 00000000bfc50640 098BA (v01  D2C50 D2C50A01 00000A01 INTL 20051117)
[    0.000000] ACPI: FACS 00000000bfc5e000 00040
[    0.000000] ACPI: APIC 00000000bfc50390 0006C (v01 121008 APIC1641 20081210 MSFT 00000097)
[    0.000000] ACPI: MCFG 00000000bfc50400 0003C (v01 121008 OEMMCFG  20081210 MSFT 00000097)
[    0.000000] ACPI: SLIC 00000000bfc50440 00176 (v01 DELL    MC09    20081210 MSFT 00000097)
[    0.000000] ACPI: OSFR 00000000bfc505c0 0007C (v01 DELL   MC09     20081210 MSFT 00000097)
[    0.000000] ACPI: OEMB 00000000bfc5e040 00072 (v01 121008 OEMB1641 20081210 MSFT 00000097)
[    0.000000] ACPI: HPET 00000000bfc59f00 00038 (v01 121008 OEMHPET  20081210 MSFT 00000097)
[    0.000000] ACPI: SSDT 00000000bfc59f40 0088C (v01 A M I  POWERNOW 00000001 AMD  00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] Scanning NUMA topology in Northbridge 24
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000023fffffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x23fffffff]
[    0.000000]   NODE_DATA [mem 0x23ffea000-0x23fffdfff]
[    0.000000]  [ffffea0000000000-ffffea0008ffffff] PMD -> [ffff880237600000-ffff88023f5fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x23fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0xbfc4ffff]
[    0.000000]   node   0: [mem 0x100000000-0x23fffffff]
[    0.000000] On node 0 totalpages: 2096110
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 12210 pages used for memmap
[    0.000000]   DMA32 zone: 781392 pages, LIFO batch:31
[    0.000000]   Normal zone: 20480 pages used for memmap
[    0.000000]   Normal zone: 1310720 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
[    0.000000] ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 4, version 33, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8300 base: 0xfed00000
[    0.000000] smpboot: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e6000
[    0.000000] PM: Registered nosave memory: 00000000000e6000 - 0000000000100000
[    0.000000] PM: Registered nosave memory: 00000000bfc50000 - 00000000bfc5e000
[    0.000000] PM: Registered nosave memory: 00000000bfc5e000 - 00000000bfca8000
[    0.000000] PM: Registered nosave memory: 00000000bfca8000 - 00000000bfce0000
[    0.000000] PM: Registered nosave memory: 00000000bfce0000 - 00000000bfcec000
[    0.000000] PM: Registered nosave memory: 00000000bfcec000 - 00000000c0000000
[    0.000000] PM: Registered nosave memory: 00000000c0000000 - 00000000ffe00000
[    0.000000] PM: Registered nosave memory: 00000000ffe00000 - 0000000100000000
[    0.000000] e820: [mem 0xc0000000-0xffdfffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:128 nr_cpumask_bits:128 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Embedded 28 pages/cpu @ffff88023fc00000 s85248 r8192 d21248 u524288
[    0.000000] pcpu-alloc: s85248 r8192 d21248 u524288 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 2063335
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-3.9.0-1.vanilla.mainline.knurd.1.fc18.x86_64 root=UUID=f8be3722-4981-448e-9fba-bae666139bea ro rd.md=0 rd.lvm=0 rd.dm=0 SYSFONT=True KEYTABLE=us rd.luks=0 LANG=en_US.UTF-8 rhgb radeon.modeset=1 plymouth.enable=1
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Node 0: aperture @ b4000000 size 32 MB
[    0.000000] Aperture pointing to e820 RAM. Ignoring.
[    0.000000] Your BIOS doesn't leave a aperture memory hole
[    0.000000] Please enable the IOMMU option in the BIOS setup
[    0.000000] This costs you 64 MB of RAM
[    0.000000] Mapping aperture over 65536 KB of RAM @ b4000000
[    0.000000] PM: Registered nosave memory: 00000000b4000000 - 00000000b8000000
[    0.000000] Memory: 8085368k/9437184k available (6549k kernel code, 1052744k absent, 299072k reserved, 6687k data, 1348k init)
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=128 to nr_cpu_ids=4.
[    0.000000] NR_IRQS:8448 nr_irqs:712 16
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] allocated 33554432 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] hpet clockevent registered
[    0.001000] tsc: Fast TSC calibration using PIT
[    0.002000] tsc: Detected 3000.222 MHz processor
[    0.000003] Calibrating delay loop (skipped), value calculated using timer frequency.. 6000.44 BogoMIPS (lpj=3000222)
[    0.000008] pid_max: default: 32768 minimum: 301
[    0.000038] Security Framework initialized
[    0.000046] SELinux:  Initializing.
[    0.000055] SELinux:  Starting in permissive mode
[    0.000651] Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.003340] Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.004556] Mount-cache hash table entries: 256
[    0.004757] Initializing cgroup subsys cpuacct
[    0.004761] Initializing cgroup subsys memory
[    0.004773] Initializing cgroup subsys devices
[    0.004776] Initializing cgroup subsys freezer
[    0.004779] Initializing cgroup subsys net_cls
[    0.004782] Initializing cgroup subsys blkio
[    0.004785] Initializing cgroup subsys perf_event
[    0.004811] tseg: 0000000000
[    0.004817] CPU: Physical Processor ID: 0
[    0.004820] CPU: Processor Core ID: 0
[    0.004822] mce: CPU supports 6 MCE banks
[    0.004829] LVT offset 0 assigned for vector 0xf9
[    0.004835] process: using AMD E400 aware idle routine
[    0.004839] Last level iTLB entries: 4KB 512, 2MB 16, 4MB 8
Last level dTLB entries: 4KB 512, 2MB 128, 4MB 64
tlb_flushall_shift: 4
[    0.004912] Freeing SMP alternatives: 24k freed
[    0.005624] ACPI: Core revision 20130117
[    0.007525] ACPI: All ACPI Tables successfully acquired
[    0.009628] ftrace: allocating 24459 entries in 96 pages
[    0.019228] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.029226] smpboot: CPU0: AMD Phenom(tm) II X4 940 Processor (fam: 10, model: 04, stepping: 02)
[    0.130603] Performance Events: AMD PMU driver.
[    0.130608] ... version:                0
[    0.130610] ... bit width:              48
[    0.130612] ... generic registers:      4
[    0.130613] ... value mask:             0000ffffffffffff
[    0.130615] ... max period:             00007fffffffffff
[    0.130617] ... fixed-purpose events:   0
[    0.130619] ... event mask:             000000000000000f
[    0.131660] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[    0.131743] smpboot: Booting Node   0, Processors  #1 #2 #3 OK
[    0.171223] Brought up 4 CPUs
[    0.171226] smpboot: Total of 4 processors activated (24001.77 BogoMIPS)
[    0.176213] devtmpfs: initialized
[    0.176422] PM: Registering ACPI NVS region [mem 0xbfc5e000-0xbfca7fff] (303104 bytes)
[    0.177196] atomic64 test passed for x86-64 platform with CX8 and with SSE
[    0.177222] RTC time: 15:20:55, date: 05/01/13
[    0.177266] NET: Registered protocol family 16
[    0.177373] node 0 link 0: io port [1000, ffffff]
[    0.177376] TOM: 00000000c0000000 aka 3072M
[    0.177379] Fam 10h mmconf [mem 0xe0000000-0xefffffff]
[    0.177381] node 0 link 0: mmio [e0000000, efffffff] ==> none
[    0.177383] node 0 link 0: mmio [f0000000, ffffffff]
[    0.177385] node 0 link 0: mmio [a0000, bffff]
[    0.177386] node 0 link 0: mmio [c0000000, dfffffff]
[    0.177388] TOM2: 0000000240000000 aka 9216M
[    0.177391] bus: [bus 00-07] on node 0 link 0
[    0.177392] bus: 00 [io  0x0000-0xffff]
[    0.177393] bus: 00 [mem 0xf0000000-0xffffffff]
[    0.177394] bus: 00 [mem 0x000a0000-0x000bffff]
[    0.177395] bus: 00 [mem 0xc0000000-0xdfffffff]
[    0.177396] bus: 00 [mem 0x240000000-0xfcffffffff]
[    0.177466] ACPI: bus type PCI registered
[    0.177514] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
[    0.177518] PCI: not using MMCONFIG
[    0.177520] PCI: Using configuration type 1 for base access
[    0.177522] PCI: Using configuration type 1 for extended access
[    0.177648] mtrr: your CPUs had inconsistent variable MTRR settings
[    0.177651] mtrr: probably your BIOS does not setup all CPUs.
[    0.177652] mtrr: corrected configuration.
[    0.178250] bio: create slab <bio-0> at 0
[    0.178318] ACPI: Added _OSI(Module Device)
[    0.178321] ACPI: Added _OSI(Processor Device)
[    0.178325] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.178328] ACPI: Added _OSI(Processor Aggregator Device)
[    0.178846] ACPI: EC: Look up EC in DSDT
[    0.179576] ACPI: Executed 4 blocks of module-level executable AML code
[    0.184723] ACPI: Interpreter enabled
[    0.184732] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20130117/hwxface-568)
[    0.184738] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20130117/hwxface-568)
[    0.184750] ACPI: (supports S0 S3 S4 S5)
[    0.184752] ACPI: Using IOAPIC for interrupt routing
[    0.184776] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
[    0.185228] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in ACPI motherboard resources
[    0.192944] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.225153] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.225272] PCI host bridge to bus 0000:00
[    0.225277] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.225280] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.225283] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.225287] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    0.225290] pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000dffff]
[    0.225293] pci_bus 0000:00: root bus resource [mem 0xc0000000-0xdfffffff]
[    0.225296] pci_bus 0000:00: root bus resource [mem 0xf0000000-0xfebfffff]
[    0.225307] pci 0000:00:00.0: [1002:5958] type 00 class 0x060000
[    0.225318] pci 0000:00:00.0: reg 1c: [mem 0xe0000000-0xffffffff 64bit]
[    0.225371] pci 0000:00:02.0: [1002:5978] type 01 class 0x060400
[    0.225401] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
[    0.225415] pci 0000:00:02.0: System wakeup disabled by ACPI
[    0.225444] pci 0000:00:03.0: [1002:5979] type 01 class 0x060400
[    0.225473] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[    0.225489] pci 0000:00:03.0: System wakeup disabled by ACPI
[    0.225524] pci 0000:00:0a.0: [1002:597f] type 01 class 0x060400
[    0.225553] pci 0000:00:0a.0: PME# supported from D0 D3hot D3cold
[    0.225570] pci 0000:00:0a.0: System wakeup disabled by ACPI
[    0.225607] pci 0000:00:11.0: [1002:4390] type 00 class 0x01018f
[    0.225625] pci 0000:00:11.0: reg 10: [io  0xa000-0xa007]
[    0.225634] pci 0000:00:11.0: reg 14: [io  0x9000-0x9003]
[    0.225644] pci 0000:00:11.0: reg 18: [io  0x8000-0x8007]
[    0.225653] pci 0000:00:11.0: reg 1c: [io  0x7000-0x7003]
[    0.225662] pci 0000:00:11.0: reg 20: [io  0x6000-0x600f]
[    0.225671] pci 0000:00:11.0: reg 24: [mem 0xfe7ffc00-0xfe7fffff]
[    0.225691] pci 0000:00:11.0: set SATA to AHCI mode
[    0.225772] pci 0000:00:12.0: [1002:4397] type 00 class 0x0c0310
[    0.225785] pci 0000:00:12.0: reg 10: [mem 0xfe7fe000-0xfe7fefff]
[    0.225858] pci 0000:00:12.0: System wakeup disabled by ACPI
[    0.225883] pci 0000:00:12.1: [1002:4398] type 00 class 0x0c0310
[    0.225896] pci 0000:00:12.1: reg 10: [mem 0xfe7fd000-0xfe7fdfff]
[    0.225970] pci 0000:00:12.1: System wakeup disabled by ACPI
[    0.226001] pci 0000:00:12.2: [1002:4396] type 00 class 0x0c0320
[    0.226019] pci 0000:00:12.2: reg 10: [mem 0xfe7ff800-0xfe7ff8ff]
[    0.226099] pci 0000:00:12.2: supports D1 D2
[    0.226101] pci 0000:00:12.2: PME# supported from D0 D1 D2 D3hot
[    0.226129] pci 0000:00:12.2: System wakeup disabled by ACPI
[    0.226160] pci 0000:00:13.0: [1002:4397] type 00 class 0x0c0310
[    0.226173] pci 0000:00:13.0: reg 10: [mem 0xfe7fc000-0xfe7fcfff]
[    0.226249] pci 0000:00:13.0: System wakeup disabled by ACPI
[    0.226274] pci 0000:00:13.1: [1002:4398] type 00 class 0x0c0310
[    0.226286] pci 0000:00:13.1: reg 10: [mem 0xfe7fb000-0xfe7fbfff]
[    0.226363] pci 0000:00:13.1: System wakeup disabled by ACPI
[    0.226393] pci 0000:00:13.2: [1002:4396] type 00 class 0x0c0320
[    0.226411] pci 0000:00:13.2: reg 10: [mem 0xfe7ff400-0xfe7ff4ff]
[    0.226491] pci 0000:00:13.2: supports D1 D2
[    0.226493] pci 0000:00:13.2: PME# supported from D0 D1 D2 D3hot
[    0.226526] pci 0000:00:13.2: System wakeup disabled by ACPI
[    0.226560] pci 0000:00:14.0: [1002:4385] type 00 class 0x0c0500
[    0.226682] pci 0000:00:14.1: [1002:439c] type 00 class 0x01018a
[    0.226698] pci 0000:00:14.1: reg 10: [io  0x0000-0x0007]
[    0.226707] pci 0000:00:14.1: reg 14: [io  0x0000-0x0003]
[    0.226715] pci 0000:00:14.1: reg 18: [io  0x0000-0x0007]
[    0.226724] pci 0000:00:14.1: reg 1c: [io  0x0000-0x0003]
[    0.226733] pci 0000:00:14.1: reg 20: [io  0xff00-0xff0f]
[    0.226818] pci 0000:00:14.3: [1002:439d] type 00 class 0x060100
[    0.226919] pci 0000:00:14.4: [1002:4384] type 01 class 0x060401
[    0.226970] pci 0000:00:14.4: System wakeup disabled by ACPI
[    0.226999] pci 0000:00:14.5: [1002:4399] type 00 class 0x0c0310
[    0.227011] pci 0000:00:14.5: reg 10: [mem 0xfe7fa000-0xfe7fafff]
[    0.227091] pci 0000:00:14.5: System wakeup disabled by ACPI
[    0.227119] pci 0000:00:18.0: [1022:1200] type 00 class 0x060000
[    0.227166] pci 0000:00:18.1: [1022:1201] type 00 class 0x060000
[    0.227209] pci 0000:00:18.2: [1022:1202] type 00 class 0x060000
[    0.227253] pci 0000:00:18.3: [1022:1203] type 00 class 0x060000
[    0.227300] pci 0000:00:18.4: [1022:1204] type 00 class 0x060000
[    0.227392] pci 0000:01:00.0: [1002:9440] type 00 class 0x030000
[    0.227404] pci 0000:01:00.0: reg 10: [mem 0xc0000000-0xcfffffff 64bit pref]
[    0.227413] pci 0000:01:00.0: reg 18: [mem 0xfe8f0000-0xfe8fffff 64bit]
[    0.227420] pci 0000:01:00.0: reg 20: [io  0xb000-0xb0ff]
[    0.227431] pci 0000:01:00.0: reg 30: [mem 0xfe8c0000-0xfe8dffff pref]
[    0.227459] pci 0000:01:00.0: supports D1 D2
[    0.227491] pci 0000:01:00.1: [1002:aa30] type 00 class 0x040300
[    0.227502] pci 0000:01:00.1: reg 10: [mem 0xfe8ec000-0xfe8effff 64bit]
[    0.227557] pci 0000:01:00.1: supports D1 D2
[    0.229531] pci 0000:00:02.0: PCI bridge to [bus 01]
[    0.229538] pci 0000:00:02.0:   bridge window [io  0xb000-0xbfff]
[    0.229541] pci 0000:00:02.0:   bridge window [mem 0xfe800000-0xfe8fffff]
[    0.229544] pci 0000:00:02.0:   bridge window [mem 0xc0000000-0xcfffffff 64bit pref]
[    0.229589] pci 0000:02:00.0: [1002:9440] type 00 class 0x030000
[    0.229604] pci 0000:02:00.0: reg 10: [mem 0xd0000000-0xdfffffff 64bit pref]
[    0.229616] pci 0000:02:00.0: reg 18: [mem 0xfe9f0000-0xfe9fffff 64bit]
[    0.229623] pci 0000:02:00.0: reg 20: [io  0xc000-0xc0ff]
[    0.229637] pci 0000:02:00.0: reg 30: [mem 0xfe9c0000-0xfe9dffff pref]
[    0.229673] pci 0000:02:00.0: supports D1 D2
[    0.229714] pci 0000:02:00.1: [1002:aa30] type 00 class 0x040300
[    0.229728] pci 0000:02:00.1: reg 10: [mem 0xfe9ec000-0xfe9effff 64bit]
[    0.229792] pci 0000:02:00.1: supports D1 D2
[    0.231529] pci 0000:00:03.0: PCI bridge to [bus 02]
[    0.231536] pci 0000:00:03.0:   bridge window [io  0xc000-0xcfff]
[    0.231538] pci 0000:00:03.0:   bridge window [mem 0xfe900000-0xfe9fffff]
[    0.231541] pci 0000:00:03.0:   bridge window [mem 0xd0000000-0xdfffffff 64bit pref]
[    0.231593] pci 0000:03:00.0: [10ec:8168] type 00 class 0x020000
[    0.231605] pci 0000:03:00.0: reg 10: [io  0xd800-0xd8ff]
[    0.231625] pci 0000:03:00.0: reg 18: [mem 0xfdfff000-0xfdffffff 64bit pref]
[    0.231637] pci 0000:03:00.0: reg 20: [mem 0xfdfe0000-0xfdfeffff 64bit pref]
[    0.231646] pci 0000:03:00.0: reg 30: [mem 0xfeaf0000-0xfeafffff pref]
[    0.231691] pci 0000:03:00.0: supports D1 D2
[    0.231693] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.233530] pci 0000:00:0a.0: PCI bridge to [bus 03]
[    0.233537] pci 0000:00:0a.0:   bridge window [io  0xd000-0xdfff]
[    0.233539] pci 0000:00:0a.0:   bridge window [mem 0xfea00000-0xfeafffff]
[    0.233542] pci 0000:00:0a.0:   bridge window [mem 0xfdf00000-0xfdffffff 64bit pref]
[    0.233587] pci 0000:04:05.0: [11c1:5811] type 00 class 0x0c0010
[    0.233608] pci 0000:04:05.0: reg 10: [mem 0xfebff000-0xfebfffff]
[    0.233702] pci 0000:04:05.0: supports D1 D2
[    0.233704] pci 0000:04:05.0: PME# supported from D0 D1 D2 D3hot
[    0.233753] pci 0000:04:09.0: [10ec:8169] type 00 class 0x020000
[    0.233774] pci 0000:04:09.0: reg 10: [io  0xe800-0xe8ff]
[    0.233788] pci 0000:04:09.0: reg 14: [mem 0xfebfec00-0xfebfecff]
[    0.233841] pci 0000:04:09.0: reg 30: [mem 0xfebc0000-0xfebdffff pref]
[    0.233875] pci 0000:04:09.0: supports D1 D2
[    0.233876] pci 0000:04:09.0: PME# supported from D1 D2 D3hot D3cold
[    0.233936] pci 0000:00:14.4: PCI bridge to [bus 04] (subtractive decode)
[    0.233941] pci 0000:00:14.4:   bridge window [io  0xe000-0xefff]
[    0.233945] pci 0000:00:14.4:   bridge window [mem 0xfeb00000-0xfebfffff]
[    0.233949] pci 0000:00:14.4:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
[    0.233951] pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff] (subtractive decode)
[    0.233953] pci 0000:00:14.4:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
[    0.233954] pci 0000:00:14.4:   bridge window [mem 0x000d0000-0x000dffff] (subtractive decode)
[    0.233956] pci 0000:00:14.4:   bridge window [mem 0xc0000000-0xdfffffff] (subtractive decode)
[    0.233958] pci 0000:00:14.4:   bridge window [mem 0xf0000000-0xfebfffff] (subtractive decode)
[    0.233971] acpi PNP0A03:00: ACPI _OSC support notification failed, disabling PCIe ASPM
[    0.233978] acpi PNP0A03:00: Unable to request _OSC control (_OSC support mask: 0x08)
[    0.245566] ACPI: PCI Interrupt Link [LNKA] (IRQs *4 7 10 11 12 14 15)
[    0.245605] ACPI: PCI Interrupt Link [LNKB] (IRQs 4 7 *10 11 12 14 15)
[    0.245639] ACPI: PCI Interrupt Link [LNKC] (IRQs 4 7 *10 11 12 14 15)
[    0.245671] ACPI: PCI Interrupt Link [LNKD] (IRQs 4 7 10 *11 12 14 15)
[    0.245703] ACPI: PCI Interrupt Link [LNKE] (IRQs 4 7 *10 11 12 14 15)
[    0.245737] ACPI: PCI Interrupt Link [LNKF] (IRQs 4 7 10 11 12 14 15) *0, disabled.
[    0.245771] ACPI: PCI Interrupt Link [LNKG] (IRQs 4 *7 10 11 12 14 15)
[    0.245804] ACPI: PCI Interrupt Link [LNKH] (IRQs 4 7 10 *11 12 14 15)
[    0.245918] acpi root: \_SB_.PCI0 notify handler is installed
[    0.245940] Found 1 acpi root devices
[    0.246004] ACPI: No dock devices found.
[    0.246069] vgaarb: device added: PCI:0000:01:00.0,decodes=io+mem,owns=io+mem,locks=none
[    0.246074] vgaarb: device added: PCI:0000:02:00.0,decodes=io+mem,owns=none,locks=none
[    0.246078] vgaarb: loaded
[    0.246079] vgaarb: bridge control possible 0000:02:00.0
[    0.246081] vgaarb: bridge control possible 0000:01:00.0
[    0.246138] SCSI subsystem initialized
[    0.246141] ACPI: bus type ATA registered
[    0.246189] libata version 3.00 loaded.
[    0.246205] ACPI: bus type USB registered
[    0.246218] usbcore: registered new interface driver usbfs
[    0.246227] usbcore: registered new interface driver hub
[    0.246248] usbcore: registered new device driver usb
[    0.246294] PCI: Using ACPI for IRQ routing
[    0.254744] PCI: pci_cache_line_size set to 64 bytes
[    0.254750] pci 0000:00:00.0: no compatible bridge window for [mem 0xe0000000-0xffffffff 64bit]
[    0.254812] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.254813] e820: reserve RAM buffer [mem 0xbfc50000-0xbfffffff]
[    0.254883] NetLabel: Initializing
[    0.254885] NetLabel:  domain hash size = 128
[    0.254887] NetLabel:  protocols = UNLABELED CIPSOv4
[    0.254899] NetLabel:  unlabeled traffic allowed by default
[    0.254950] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
[    0.254954] hpet0: 4 comparators, 32-bit 14.318180 MHz counter
[    0.256978] Switching to clocksource hpet
[    0.261357] pnp: PnP ACPI init
[    0.261371] ACPI: bus type PNP registered
[    0.261407] pnp 00:00: [dma 4]
[    0.261425] pnp 00:00: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.261453] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.261468] pnp 00:02: Plug and Play ACPI device, IDs PNP0800 (active)
[    0.261488] pnp 00:03: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.261654] pnp 00:04: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.261735] system 00:05: [mem 0xfec00000-0xfec00fff] could not be reserved
[    0.261739] system 00:05: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.261743] system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.261885] system 00:06: [io  0x04d0-0x04d1] has been reserved
[    0.261889] system 00:06: [io  0x040b] has been reserved
[    0.261892] system 00:06: [io  0x04d6] has been reserved
[    0.261895] system 00:06: [io  0x0c00-0x0c01] has been reserved
[    0.261898] system 00:06: [io  0x0c14] has been reserved
[    0.261900] system 00:06: [io  0x0c50-0x0c51] has been reserved
[    0.261903] system 00:06: [io  0x0c52] has been reserved
[    0.261906] system 00:06: [io  0x0c6c] has been reserved
[    0.261909] system 00:06: [io  0x0c6f] has been reserved
[    0.261912] system 00:06: [io  0x0cd0-0x0cd1] has been reserved
[    0.261915] system 00:06: [io  0x0cd2-0x0cd3] has been reserved
[    0.261918] system 00:06: [io  0x0cd4-0x0cd5] has been reserved
[    0.261920] system 00:06: [io  0x0cd6-0x0cd7] has been reserved
[    0.261923] system 00:06: [io  0x0cd8-0x0cdf] has been reserved
[    0.261926] system 00:06: [io  0x0800-0x089f] has been reserved
[    0.261929] system 00:06: [io  0x0b00-0x0b0f] has been reserved
[    0.261932] system 00:06: [io  0x0b20-0x0b3f] has been reserved
[    0.261935] system 00:06: [io  0x0900-0x090f] has been reserved
[    0.261938] system 00:06: [io  0x0910-0x091f] has been reserved
[    0.261941] system 00:06: [io  0xfe00-0xfefe] has been reserved
[    0.261945] system 00:06: [mem 0xffb80000-0xffbfffff] has been reserved
[    0.261948] system 00:06: [mem 0xfec10000-0xfec1001f] has been reserved
[    0.261951] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.262089] system 00:07: [io  0x0e00-0x0e0f] has been reserved
[    0.262093] system 00:07: [io  0x0e80-0x0e8f] has been reserved
[    0.262096] system 00:07: [io  0x0f40-0x0f4f] has been reserved
[    0.262099] system 00:07: [io  0x0a30-0x0a3f] has been reserved
[    0.262102] system 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.262149] system 00:08: [mem 0xe0000000-0xefffffff] has been reserved
[    0.262153] system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.282087] pnp 00:09: disabling [mem 0x00000000-0x0009ffff] because it overlaps 0000:00:00.0 BAR 3 [mem 0x00000000-0x1fffffff 64bit]
[    0.282094] pnp 00:09: disabling [mem 0x000c0000-0x000cffff] because it overlaps 0000:00:00.0 BAR 3 [mem 0x00000000-0x1fffffff 64bit]
[    0.282099] pnp 00:09: disabling [mem 0x000e0000-0x000fffff] because it overlaps 0000:00:00.0 BAR 3 [mem 0x00000000-0x1fffffff 64bit]
[    0.282103] pnp 00:09: disabling [mem 0x00100000-0xbfffffff] because it overlaps 0000:00:00.0 BAR 3 [mem 0x00000000-0x1fffffff 64bit]
[    0.282139] system 00:09: [mem 0xfec00000-0xffffffff] could not be reserved
[    0.282144] system 00:09: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.282212] pnp: PnP ACPI: found 10 devices
[    0.282215] ACPI: bus type PNP unregistered
[    0.288529] pci 0000:00:02.0: PCI bridge to [bus 01]
[    0.288534] pci 0000:00:02.0:   bridge window [io  0xb000-0xbfff]
[    0.288538] pci 0000:00:02.0:   bridge window [mem 0xfe800000-0xfe8fffff]
[    0.288542] pci 0000:00:02.0:   bridge window [mem 0xc0000000-0xcfffffff 64bit pref]
[    0.288547] pci 0000:00:03.0: PCI bridge to [bus 02]
[    0.288550] pci 0000:00:03.0:   bridge window [io  0xc000-0xcfff]
[    0.288553] pci 0000:00:03.0:   bridge window [mem 0xfe900000-0xfe9fffff]
[    0.288557] pci 0000:00:03.0:   bridge window [mem 0xd0000000-0xdfffffff 64bit pref]
[    0.288562] pci 0000:00:0a.0: PCI bridge to [bus 03]
[    0.288564] pci 0000:00:0a.0:   bridge window [io  0xd000-0xdfff]
[    0.288568] pci 0000:00:0a.0:   bridge window [mem 0xfea00000-0xfeafffff]
[    0.288572] pci 0000:00:0a.0:   bridge window [mem 0xfdf00000-0xfdffffff 64bit pref]
[    0.288576] pci 0000:00:14.4: PCI bridge to [bus 04]
[    0.288580] pci 0000:00:14.4:   bridge window [io  0xe000-0xefff]
[    0.288586] pci 0000:00:14.4:   bridge window [mem 0xfeb00000-0xfebfffff]
[    0.288746] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.288747] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.288749] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.288751] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000dffff]
[    0.288752] pci_bus 0000:00: resource 8 [mem 0xc0000000-0xdfffffff]
[    0.288754] pci_bus 0000:00: resource 9 [mem 0xf0000000-0xfebfffff]
[    0.288755] pci_bus 0000:01: resource 0 [io  0xb000-0xbfff]
[    0.288757] pci_bus 0000:01: resource 1 [mem 0xfe800000-0xfe8fffff]
[    0.288759] pci_bus 0000:01: resource 2 [mem 0xc0000000-0xcfffffff 64bit pref]
[    0.288760] pci_bus 0000:02: resource 0 [io  0xc000-0xcfff]
[    0.288762] pci_bus 0000:02: resource 1 [mem 0xfe900000-0xfe9fffff]
[    0.288763] pci_bus 0000:02: resource 2 [mem 0xd0000000-0xdfffffff 64bit pref]
[    0.288765] pci_bus 0000:03: resource 0 [io  0xd000-0xdfff]
[    0.288766] pci_bus 0000:03: resource 1 [mem 0xfea00000-0xfeafffff]
[    0.288768] pci_bus 0000:03: resource 2 [mem 0xfdf00000-0xfdffffff 64bit pref]
[    0.288770] pci_bus 0000:04: resource 0 [io  0xe000-0xefff]
[    0.288771] pci_bus 0000:04: resource 1 [mem 0xfeb00000-0xfebfffff]
[    0.288773] pci_bus 0000:04: resource 4 [io  0x0000-0x0cf7]
[    0.288774] pci_bus 0000:04: resource 5 [io  0x0d00-0xffff]
[    0.288776] pci_bus 0000:04: resource 6 [mem 0x000a0000-0x000bffff]
[    0.288777] pci_bus 0000:04: resource 7 [mem 0x000d0000-0x000dffff]
[    0.288779] pci_bus 0000:04: resource 8 [mem 0xc0000000-0xdfffffff]
[    0.288781] pci_bus 0000:04: resource 9 [mem 0xf0000000-0xfebfffff]
[    0.288815] NET: Registered protocol family 2
[    0.289017] TCP established hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.289396] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.289709] TCP: Hash tables configured (established 65536 bind 65536)
[    0.289752] TCP: reno registered
[    0.289765] UDP hash table entries: 4096 (order: 5, 131072 bytes)
[    0.289822] UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
[    0.289920] NET: Registered protocol family 1
[    0.652721] pci 0000:01:00.0: Boot video device
[    0.652737] PCI: CLS 64 bytes, default 64
[    0.652777] Unpacking initramfs...
[    0.942529] Freeing initrd memory: 19484k freed
[    0.948697] PCI-DMA: Disabling AGP.
[    0.949953] PCI-DMA: aperture base @ b4000000 size 65536 KB
[    0.949955] PCI-DMA: using GART IOMMU.
[    0.949959] PCI-DMA: Reserving 64MB of IOMMU area in the AGP aperture
[    0.954268] LVT offset 1 assigned for vector 0x400
[    0.954281] IBS: LVT offset 1 assigned
[    0.954307] perf: AMD IBS detected (0x0000001f)
[    0.954762] Initialise module verification
[    0.954797] audit: initializing netlink socket (disabled)
[    0.954810] type=2000 audit(1367421655.843:1): initialized
[    0.974638] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.976095] VFS: Disk quotas dquot_6.5.2
[    0.976133] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.976461] msgmni has been set to 15958
[    0.976508] SELinux:  Registering netfilter hooks
[    0.977102] alg: No test for stdrng (krng)
[    0.977116] NET: Registered protocol family 38
[    0.977121] Key type asymmetric registered
[    0.977124] Asymmetric key parser 'x509' registered
[    0.977148] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[    0.977177] io scheduler noop registered
[    0.977179] io scheduler deadline registered
[    0.977187] io scheduler cfq registered (default)
[    0.977297] pcieport 0000:00:02.0: irq 40 for MSI/MSI-X
[    0.977358] pcieport 0000:00:03.0: irq 41 for MSI/MSI-X
[    0.977408] pcieport 0000:00:0a.0: irq 42 for MSI/MSI-X
[    0.977456] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    0.977469] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    0.977472] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.977580] vesafb: mode is 1400x1050x32, linelength=5632, pages=0
[    0.977583] vesafb: scrolling: redraw
[    0.977585] vesafb: Truecolor: size=0:8:8:8, shift=0:16:8:0
[    0.977799] vesafb: framebuffer at 0xc0000000, mapped to 0xffffc90010f00000, using 5824k, total 5824k
[    1.001949] Console: switching to colour frame buffer device 175x65
[    1.024645] fb0: VESA VGA frame buffer device
[    1.024803] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
[    1.025007] ACPI: Power Button [PWRB]
[    1.025123] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
[    1.025309] ACPI: Power Button [PWRF]
[    1.048594] GHES: HEST is not enabled!
[    1.048748] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.049350] Non-volatile memory driver v1.3
[    1.049451] Linux agpgart interface v0.103
[    1.050135] loop: module loaded
[    1.050263] ahci 0000:00:11.0: version 3.0
[    1.050421] ahci 0000:00:11.0: AHCI 0001.0100 32 slots 4 ports 3 Gbps 0xf impl SATA mode
[    1.050619] ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo pmp pio slum part ccc 
[    1.051229] scsi0 : ahci
[    1.051359] scsi1 : ahci
[    1.051465] scsi2 : ahci
[    1.051569] scsi3 : ahci
[    1.051653] ata1: SATA max UDMA/133 abar m1024@0xfe7ffc00 port 0xfe7ffd00 irq 22
[    1.051833] ata2: SATA max UDMA/133 abar m1024@0xfe7ffc00 port 0xfe7ffd80 irq 22
[    1.052013] ata3: SATA max UDMA/133 abar m1024@0xfe7ffc00 port 0xfe7ffe00 irq 22
[    1.052192] ata4: SATA max UDMA/133 abar m1024@0xfe7ffc00 port 0xfe7ffe80 irq 22
[    1.052470] libphy: Fixed MDIO Bus: probed
[    1.052633] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.052791] ehci-pci: EHCI PCI platform driver
[    1.052975] ehci-pci 0000:00:12.2: EHCI Host Controller
[    1.053156] ehci-pci 0000:00:12.2: new USB bus registered, assigned bus number 1
[    1.053349] QUIRK: Enable AMD PLL fix
[    1.053351] ehci-pci 0000:00:12.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[    1.053561] ehci-pci 0000:00:12.2: applying AMD SB600/SB700 USB freeze workaround
[    1.053753] ehci-pci 0000:00:12.2: debug port 1
[    1.053898] ehci-pci 0000:00:12.2: irq 17, io mem 0xfe7ff800
[    1.059268] ehci-pci 0000:00:12.2: USB 2.0 started, EHCI 1.00
[    1.059431] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    1.059595] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.059770] usb usb1: Product: EHCI Host Controller
[    1.059887] usb usb1: Manufacturer: Linux 3.9.0-1.vanilla.mainline.knurd.1.fc18.x86_64 ehci_hcd
[    1.060097] usb usb1: SerialNumber: 0000:00:12.2
[    1.066175] hub 1-0:1.0: USB hub found
[    1.072119] hub 1-0:1.0: 6 ports detected
[    1.078191] ehci-pci 0000:00:13.2: EHCI Host Controller
[    1.084149] ehci-pci 0000:00:13.2: new USB bus registered, assigned bus number 2
[    1.090088] ehci-pci 0000:00:13.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[    1.096075] ehci-pci 0000:00:13.2: applying AMD SB600/SB700 USB freeze workaround
[    1.102010] ehci-pci 0000:00:13.2: debug port 1
[    1.107923] ehci-pci 0000:00:13.2: irq 19, io mem 0xfe7ff400
[    1.119211] ehci-pci 0000:00:13.2: USB 2.0 started, EHCI 1.00
[    1.125113] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    1.131074] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.137014] usb usb2: Product: EHCI Host Controller
[    1.142875] usb usb2: Manufacturer: Linux 3.9.0-1.vanilla.mainline.knurd.1.fc18.x86_64 ehci_hcd
[    1.148909] usb usb2: SerialNumber: 0000:00:13.2
[    1.155039] hub 2-0:1.0: USB hub found
[    1.161091] hub 2-0:1.0: 6 ports detected
[    1.167213] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    1.173356] ohci_hcd 0000:00:12.0: OHCI Host Controller
[    1.179429] ohci_hcd 0000:00:12.0: new USB bus registered, assigned bus number 3
[    1.185485] ohci_hcd 0000:00:12.0: irq 16, io mem 0xfe7fe000
[    1.246121] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    1.252187] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.258239] usb usb3: Product: OHCI Host Controller
[    1.264195] usb usb3: Manufacturer: Linux 3.9.0-1.vanilla.mainline.knurd.1.fc18.x86_64 ohci_hcd
[    1.270270] usb usb3: SerialNumber: 0000:00:12.0
[    1.276367] hub 3-0:1.0: USB hub found
[    1.282273] hub 3-0:1.0: 3 ports detected
[    1.288196] ohci_hcd 0000:00:12.1: OHCI Host Controller
[    1.294008] ohci_hcd 0000:00:12.1: new USB bus registered, assigned bus number 4
[    1.299789] ohci_hcd 0000:00:12.1: irq 16, io mem 0xfe7fd000
[    1.357056] ata4: SATA link down (SStatus 0 SControl 300)
[    1.360009] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[    1.360011] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.360012] usb usb4: Product: OHCI Host Controller
[    1.360013] usb usb4: Manufacturer: Linux 3.9.0-1.vanilla.mainline.knurd.1.fc18.x86_64 ohci_hcd
[    1.360013] usb usb4: SerialNumber: 0000:00:12.1
[    1.376017] hub 4-0:1.0: USB hub found
[    1.376023] hub 4-0:1.0: 3 ports detected
[    1.376165] ohci_hcd 0000:00:13.0: OHCI Host Controller
[    1.376206] ohci_hcd 0000:00:13.0: new USB bus registered, assigned bus number 5
[    1.376231] ohci_hcd 0000:00:13.0: irq 18, io mem 0xfe7fc000
[    1.421270] ata1: SATA link down (SStatus 0 SControl 300)
[    1.431365] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    1.437543] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.443814] usb usb5: Product: OHCI Host Controller
[    1.450014] usb usb5: Manufacturer: Linux 3.9.0-1.vanilla.mainline.knurd.1.fc18.x86_64 ohci_hcd
[    1.456341] usb usb5: SerialNumber: 0000:00:13.0
[    1.462699] hub 5-0:1.0: USB hub found
[    1.468955] hub 5-0:1.0: 3 ports detected
[    1.475290] ohci_hcd 0000:00:13.1: OHCI Host Controller
[    1.481558] ohci_hcd 0000:00:13.1: new USB bus registered, assigned bus number 6
[    1.487853] ohci_hcd 0000:00:13.1: irq 18, io mem 0xfe7fb000
[    1.548831] usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
[    1.555165] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.561550] usb usb6: Product: OHCI Host Controller
[    1.567879] usb usb6: Manufacturer: Linux 3.9.0-1.vanilla.mainline.knurd.1.fc18.x86_64 ohci_hcd
[    1.574355] usb usb6: SerialNumber: 0000:00:13.1
[    1.577788] ata3: softreset failed (device not ready)
[    1.577791] ata3: applying PMP SRST workaround and retrying
[    1.579792] ata2: softreset failed (device not ready)
[    1.579795] ata2: applying PMP SRST workaround and retrying
[    1.606162] hub 6-0:1.0: USB hub found
[    1.612512] hub 6-0:1.0: 3 ports detected
[    1.618935] ohci_hcd 0000:00:14.5: OHCI Host Controller
[    1.625306] ohci_hcd 0000:00:14.5: new USB bus registered, assigned bus number 7
[    1.631676] ohci_hcd 0000:00:14.5: irq 18, io mem 0xfe7fa000
[    1.692698] usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
[    1.699101] usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.705550] usb usb7: Product: OHCI Host Controller
[    1.711933] usb usb7: Manufacturer: Linux 3.9.0-1.vanilla.mainline.knurd.1.fc18.x86_64 ohci_hcd
[    1.718471] usb usb7: SerialNumber: 0000:00:14.5
[    1.725034] hub 7-0:1.0: USB hub found
[    1.731417] hub 7-0:1.0: 2 ports detected
[    1.732662] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    1.733157] ata3.00: ATA-8: WDC WD2500HHTZ-04N21V0, 04.06A00, max UDMA/133
[    1.733159] ata3.00: 488397168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    1.733636] ata3.00: configured for UDMA/133
[    1.734653] ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    1.735728] ata2.00: ATAPI: Optiarc DVD+/-RW AD-7200S, 101A, max UDMA/100
[    1.737111] ata2.00: configured for UDMA/100
[    1.739327] scsi 1:0:0:0: CD-ROM            Optiarc  DVD+-RW AD-7200S 101A PQ: 0 ANSI: 5
[    1.741476] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa/form2 cdda tray
[    1.741477] cdrom: Uniform CD-ROM driver Revision: 3.20
[    1.741577] sr 1:0:0:0: Attached scsi CD-ROM sr0
[    1.741647] sr 1:0:0:0: Attached scsi generic sg0 type 5
[    1.741812] scsi 2:0:0:0: Direct-Access     ATA      WDC WD2500HHTZ-0 04.0 PQ: 0 ANSI: 5
[    1.741918] sd 2:0:0:0: Attached scsi generic sg1 type 0
[    1.741935] sd 2:0:0:0: [sda] 488397168 512-byte logical blocks: (250 GB/232 GiB)
[    1.741936] sd 2:0:0:0: [sda] 4096-byte physical blocks
[    1.742040] sd 2:0:0:0: [sda] Write Protect is off
[    1.742042] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.742079] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.754242]  sda: sda1 sda2 sda3 sda4
[    1.754660] sd 2:0:0:0: [sda] Attached SCSI disk
[    1.861727] uhci_hcd: USB Universal Host Controller Interface driver
[    1.868441] usbcore: registered new interface driver usbserial
[    1.875058] usbcore: registered new interface driver usbserial_generic
[    1.881599] usbserial: USB Serial support registered for generic
[    1.888190] i8042: PNP: No PS/2 controller found. Probing ports directly.
[    1.895243] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.901908] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.908581] mousedev: PS/2 mouse device common for all mice
[    1.915355] rtc_cmos 00:01: RTC can wake from S4
[    1.922066] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[    1.928666] rtc_cmos 00:01: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
[    1.935344] device-mapper: uevent: version 1.0.3
[    1.941975] device-mapper: ioctl: 4.24.0-ioctl (2013-01-15) initialised: dm-devel@redhat.com
[    1.948646] cpuidle: using governor ladder
[    1.953440] tsc: Refined TSC clocksource calibration: 3000.106 MHz
[    1.953443] Switching to clocksource tsc
[    1.968474] cpuidle: using governor menu
[    1.975241] EFI Variables Facility v0.08 2004-May-17
[    1.979397] usb 3-2: new low-speed USB device number 2 using ohci_hcd
[    1.988591] hidraw: raw HID events driver (C) Jiri Kosina
[    1.995318] usbcore: registered new interface driver usbhid
[    2.001996] usbhid: USB HID core driver
[    2.008638] drop_monitor: Initializing network drop monitor service
[    2.015329] ip_tables: (C) 2000-2006 Netfilter Core Team
[    2.021943] TCP: cubic registered
[    2.028475] Initializing XFRM netlink socket
[    2.035093] NET: Registered protocol family 10
[    2.041763] mip6: Mobile IPv6
[    2.048251] NET: Registered protocol family 17
[    2.054977] PM: Hibernation image not present or could not be loaded.
[    2.054979] Loading module verification certificates
[    2.062446] MODSIGN: Loaded cert 'Magrathea: Glacier signing key: 603be477f418623c1e76f05597d05e33735b0d80'
[    2.069238] registered taskstats version 1
[    2.076672]   Magic number: 13:927:334
[    2.083403] tty tty55: hash matches
[    2.090046] ohci_hcd 0000:00:13.0: hash matches
[    2.097625] Freeing unused kernel memory: 1348k freed
[    2.104597] Write protecting the kernel read-only data: 12288k
[    2.114575] Freeing unused kernel memory: 1632k freed
[    2.122330] usb 3-2: New USB device found, idVendor=046d, idProduct=c063
[    2.128952] Freeing unused kernel memory: 1328k freed
[    2.128959] usb 3-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    2.128960] usb 3-2: Product: DELL USB Laser Mouse
[    2.128961] usb 3-2: Manufacturer: DELL
[    2.137495] input: DELL DELL USB Laser Mouse as /devices/pci0000:00/0000:00:12.0/usb3/3-2/3-2:1.0/input/input2
[    2.137578] hid-generic 0003:046D:C063.0001: input,hidraw0: USB HID v1.10 Mouse [DELL DELL USB Laser Mouse] on usb-0000:00:12.0-2/input0
[    2.172873] systemd[1]: systemd 201 running in system mode. (+PAM +LIBWRAP +AUDIT +SELINUX +IMA +SYSVINIT +LIBCRYPTSETUP +GCRYPT +ACL +XZ)
[    2.180156] systemd[1]: Running in initial RAM disk.
[    2.208565] systemd[1]: No hostname configured.
[    2.215663] systemd[1]: Set hostname to <localhost>.
[    2.222789] systemd[1]: Initializing machine ID from random generator.
[    2.235300] systemd[1]: Cannot add dependency job for unit timers.target, ignoring: Unit timers.target failed to load: No such file or directory. See system logs and 'systemctl status timers.target' for details.
[    2.250046] systemd[1]: Cannot add dependency job for unit paths.target, ignoring: Unit paths.target failed to load: No such file or directory. See system logs and 'systemctl status paths.target' for details.
[    2.265767] systemd[1]: Starting Encrypted Volumes.
[    2.281490] systemd[1]: Reached target Encrypted Volumes.
[    2.289362] systemd[1]: Starting udev Kernel Socket.
[    2.305090] systemd[1]: Listening on udev Kernel Socket.
[    2.312973] systemd[1]: Starting udev Control Socket.
[    2.328605] systemd[1]: Listening on udev Control Socket.
[    2.336481] systemd[1]: Starting Journal Socket.
[    2.352185] systemd[1]: Listening on Journal Socket.
[    2.360167] systemd[1]: Started Load Kernel Modules.
[    2.367991] systemd[1]: Starting Journal Service...
[    2.378019] usb 5-2: new full-speed USB device number 2 using ohci_hcd
[    2.400354] systemd-journald[70]: Failed to resolve 'systemd-journal' group: No such process
[    2.413303] systemd[1]: Started Journal Service.
[    2.421263] systemd[1]: Starting Sockets.
[    2.436846] systemd[1]: Reached target Sockets.
[    2.444596] systemd[1]: Starting dracut cmdline hook...
[    2.460437] systemd[1]: Starting Swap.
[    2.475797] systemd[1]: Reached target Swap.
[    2.483434] systemd[1]: Starting Local File Systems.
[    2.507351] systemd[1]: Reached target Local File Systems.
[    2.530390] usb 5-2: New USB device found, idVendor=0955, idProduct=000a
[    2.530392] usb 5-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    2.530393] usb 5-2: Product: ESA FW Update
[    2.530394] usb 5-2: Manufacturer: NVIDIA
[    2.565137] systemd[1]: Started dracut cmdline hook.
[    2.565468] hid-generic 0003:0955:000A.0002: item 0 1 0 8 parsing failed
[    2.565478] hid-generic: probe of 0003:0955:000A.0002 failed with error -22
[    2.589899] systemd[1]: Starting Setup Virtual Console...
[    2.606745] systemd[1]: Starting dracut pre-udev hook...
[    2.658472] systemd-udevd[122]: starting version 201
[    2.677743] usb 4-2: new low-speed USB device number 2 using ohci_hcd
[    2.765645] wmi: module verification failed: signature and/or required key missing - tainting kernel
[    2.765889] wmi: Mapper loaded
[    2.768567] [drm] Initialized drm 1.1.0 20060810
[    2.772275] [drm] radeon kernel modesetting enabled.
[    2.772333] checking generic (c0000000 5b0000) vs hw (c0000000 10000000)
[    2.772334] fb: conflicting fb hw usage radeondrmfb vs VESA VGA - removing generic driver
[    2.787968] pata_atiixp 0000:00:14.1: setting latency timer to 64
[    2.809002] Console: switching to colour dummy device 80x25
[    2.809028] scsi4 : pata_atiixp
[    2.809475] scsi5 : pata_atiixp
[    2.809678] ata5: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xff00 irq 14
[    2.809687] ata6: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xff08 irq 15
[    2.810085] [drm] initializing kernel modesetting (RV770 0x1002:0x9440 0x1002:0x0502).
[    2.810099] [drm] register mmio base: 0xFE8F0000
[    2.810101] [drm] register mmio size: 65536
[    2.810890] ATOM BIOS: Wekiva
[    2.810920] radeon 0000:01:00.0: VRAM: 1024M 0x0000000000000000 - 0x000000003FFFFFFF (1024M used)
[    2.810925] radeon 0000:01:00.0: GTT: 512M 0x0000000040000000 - 0x000000005FFFFFFF
[    2.815556] [drm] Detected VRAM RAM=1024M, BAR=256M
[    2.815566] [drm] RAM width 256bits DDR
[    2.816040] [TTM] Zone  kernel: Available graphics memory: 4087568 kiB
[    2.816044] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
[    2.816046] [TTM] Initializing pool allocator
[    2.816051] [TTM] Initializing DMA pool allocator
[    2.816079] [drm] radeon: 1024M of VRAM memory ready
[    2.816082] [drm] radeon: 512M of GTT memory ready.
[    2.816097] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[    2.816100] [drm] Driver supports precise vblank timestamp query.
[    2.816144] radeon 0000:01:00.0: irq 43 for MSI/MSI-X
[    2.816154] radeon 0000:01:00.0: radeon: using MSI.
[    2.816182] [drm] radeon: irq initialized.
[    2.816188] [drm] GART: num cpu pages 131072, num gpu pages 131072
[    2.817016] [drm] probing gen 2 caps for device 1002:5978 = 300c82/0
[    2.817020] [drm] enabling PCIE gen 2 link speeds, disable with radeon.pcie_gen2=0
[    2.817096] [drm] Loading RV770 Microcode
[    2.827685] usb 4-2: New USB device found, idVendor=046d, idProduct=c31c
[    2.827694] usb 4-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    2.827697] usb 4-2: Product: USB Keyboard
[    2.827700] usb 4-2: Manufacturer: Logitech
[    2.837765] [drm] PCIE GART of 512M enabled (table at 0x0000000000040000).
[    2.837810] radeon 0000:01:00.0: WB enabled
[    2.837814] radeon 0000:01:00.0: fence driver on ring 0 use gpu addr 0x0000000040000c00 and cpu addr 0xffff88022f17bc00
[    2.837819] radeon 0000:01:00.0: fence driver on ring 3 use gpu addr 0x0000000040000c0c and cpu addr 0xffff88022f17bc0c
[    2.838878] input: Logitech USB Keyboard as /devices/pci0000:00/0000:00:12.1/usb4/4-2/4-2:1.0/input/input3
[    2.838963] hid-generic 0003:046D:C31C.0003: input,hidraw1: USB HID v1.10 Keyboard [Logitech USB Keyboard] on usb-0000:00:12.1-2/input0
[    2.852707] input: Logitech USB Keyboard as /devices/pci0000:00/0000:00:12.1/usb4/4-2/4-2:1.1/input/input4
[    2.852779] hid-generic 0003:046D:C31C.0004: input,hidraw2: USB HID v1.10 Device [Logitech USB Keyboard] on usb-0000:00:12.1-2/input1
[    2.884075] firewire_ohci 0000:04:05.0: added OHCI v1.0 device as card 0, 8 IR + 8 IT contexts, quirks 0x0
[    2.884094] [drm] ring test on 0 succeeded in 1 usecs
[    2.884154] [drm] ring test on 3 succeeded in 1 usecs
[    2.884261] [drm] ib test on ring 0 succeeded in 0 usecs
[    2.884275] [drm] ib test on ring 3 succeeded in 0 usecs
[    2.884441] [drm] Radeon Display Connectors
[    2.884443] [drm] Connector 0:
[    2.884445] [drm]   DVI-I-1
[    2.884447] [drm]   HPD2
[    2.884449] [drm]   DDC: 0x7e60 0x7e60 0x7e64 0x7e64 0x7e68 0x7e68 0x7e6c 0x7e6c
[    2.884451] [drm]   Encoders:
[    2.884453] [drm]     DFP1: INTERNAL_UNIPHY
[    2.884456] [drm]     CRT2: INTERNAL_KLDSCP_DAC2
[    2.884457] [drm] Connector 1:
[    2.884459] [drm]   DIN-1
[    2.884460] [drm]   Encoders:
[    2.884462] [drm]     TV1: INTERNAL_KLDSCP_DAC2
[    2.884464] [drm] Connector 2:
[    2.884465] [drm]   DVI-I-2
[    2.884467] [drm]   HPD1
[    2.884469] [drm]   DDC: 0x7e20 0x7e20 0x7e24 0x7e24 0x7e28 0x7e28 0x7e2c 0x7e2c
[    2.884471] [drm]   Encoders:
[    2.884473] [drm]     CRT1: INTERNAL_KLDSCP_DAC1
[    2.884475] [drm]     DFP2: INTERNAL_KLDSCP_LVTMA
[    2.884502] [drm] Internal thermal controller with fan control
[    2.884539] [drm] radeon: power management initialized
[    2.932448] [drm] fb mappable at 0xC0142000
[    2.932452] [drm] vram apper at 0xC0000000
[    2.932454] [drm] size 8294400
[    2.932456] [drm] fb depth is 24
[    2.932457] [drm]    pitch is 7680
[    2.932621] fbcon: radeondrmfb (fb0) is primary device
[    3.138339] Console: switching to colour frame buffer device 240x67
[    3.144833] radeon 0000:01:00.0: fb0: radeondrmfb frame buffer device
[    3.144834] radeon 0000:01:00.0: registered panic notifier
[    3.144838] [drm] Initialized radeon 2.30.0 20080528 for 0000:01:00.0 on minor 0
[    3.144888] radeon 0000:02:00.0: enabling device (0000 -> 0003)
[    3.145080] [drm] initializing kernel modesetting (RV770 0x1002:0x9440 0x1002:0x0502).
[    3.145133] [drm] register mmio base: 0xFE9F0000
[    3.145158] [drm] register mmio size: 65536
[    3.260267] ATOM BIOS: Wekiva
[    3.260299] [drm] GPU not posted. posting now...
[    3.315312] radeon 0000:02:00.0: VRAM: 1024M 0x0000000000000000 - 0x000000003FFFFFFF (1024M used)
[    3.315357] radeon 0000:02:00.0: GTT: 512M 0x0000000040000000 - 0x000000005FFFFFFF
[    3.319920] [drm] Detected VRAM RAM=1024M, BAR=256M
[    3.319958] [drm] RAM width 256bits DDR
[    3.320003] [drm] radeon: 1024M of VRAM memory ready
[    3.320029] [drm] radeon: 512M of GTT memory ready.
[    3.320078] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[    3.320116] [drm] Driver supports precise vblank timestamp query.
[    3.320187] radeon 0000:02:00.0: irq 44 for MSI/MSI-X
[    3.320199] radeon 0000:02:00.0: radeon: using MSI.
[    3.320250] [drm] radeon: irq initialized.
[    3.320276] [drm] GART: num cpu pages 131072, num gpu pages 131072
[    3.321051] [drm] probing gen 2 caps for device 1002:5979 = 1300c82/0
[    3.321086] [drm] enabling PCIE gen 2 link speeds, disable with radeon.pcie_gen2=0
[    3.321204] [drm] Loading RV770 Microcode
[    3.322957] [drm] PCIE GART of 512M enabled (table at 0x0000000000040000).
[    3.323037] radeon 0000:02:00.0: WB enabled
[    3.323060] radeon 0000:02:00.0: fence driver on ring 0 use gpu addr 0x0000000040000c00 and cpu addr 0xffff88022ead1c00
[    3.323130] radeon 0000:02:00.0: fence driver on ring 3 use gpu addr 0x0000000040000c0c and cpu addr 0xffff88022ead1c0c
[    3.369376] [drm] ring test on 0 succeeded in 1 usecs
[    3.369458] [drm] ring test on 3 succeeded in 1 usecs
[    3.369581] [drm] ib test on ring 0 succeeded in 0 usecs
[    3.369619] [drm] ib test on ring 3 succeeded in 0 usecs
[    3.369803] [drm] Radeon Display Connectors
[    3.369826] [drm] Connector 0:
[    3.369843] [drm]   DVI-I-3
[    3.369859] [drm]   HPD2
[    3.369874] [drm]   DDC: 0x7e60 0x7e60 0x7e64 0x7e64 0x7e68 0x7e68 0x7e6c 0x7e6c
[    3.369912] [drm]   Encoders:
[    3.369929] [drm]     DFP1: INTERNAL_UNIPHY
[    3.369951] [drm]     CRT2: INTERNAL_KLDSCP_DAC2
[    3.369976] [drm] Connector 1:
[    3.369992] [drm]   DIN-2
[    3.371226] [drm]   Encoders:
[    3.372482] [drm]     TV1: INTERNAL_KLDSCP_DAC2
[    3.373709] [drm] Connector 2:
[    3.374933] [drm]   DVI-I-4
[    3.376185] [drm]   HPD1
[    3.377429] [drm]   DDC: 0x7e20 0x7e20 0x7e24 0x7e24 0x7e28 0x7e28 0x7e2c 0x7e2c
[    3.378719] [drm]   Encoders:
[    3.380008] [drm]     CRT1: INTERNAL_KLDSCP_DAC1
[    3.381259] [drm]     DFP2: INTERNAL_KLDSCP_LVTMA
[    3.382529] [drm] Internal thermal controller with fan control
[    3.383828] [drm] radeon: power management initialized
[    3.387153] firewire_core 0000:04:05.0: created device fw0: GUID 001d098a52f70306, S400
[    3.405367] radeon 0000:02:00.0: No connectors reported connected with modes
[    3.406677] [drm] Cannot find any crtc or sizes - going 1024x768
[    3.409169] [drm] fb mappable at 0xD0142000
[    3.410538] [drm] vram apper at 0xD0000000
[    3.411913] [drm] size 3145728
[    3.413271] [drm] fb depth is 24
[    3.414564] [drm]    pitch is 4096
[    3.415907] radeon 0000:02:00.0: fb1: radeondrmfb frame buffer device
[    3.417226] [drm] Initialized radeon 2.30.0 20080528 for 0000:02:00.0 on minor 1
[    3.444787] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
[    3.545212] EXT4-fs (sda1): barriers disabled
[    3.546586] EXT4-fs (sda1): mounted filesystem with writeback data mode. Opts: data=writeback,barrier=0,errors=remount-ro
[    3.604967] systemd-journald[70]: Received SIGTERM
[    3.997952] type=1404 audit(1367421658.889:2): enforcing=1 old_enforcing=0 auid=4294967295 ses=4294967295
[    4.082141] SELinux: 2048 avtab hash slots, 96403 rules.
[    4.093994] SELinux: 2048 avtab hash slots, 96403 rules.
[    4.231619] SELinux:  9 users, 15 roles, 4389 types, 246 bools, 1 sens, 1024 cats
[    4.231623] SELinux:  83 classes, 96403 rules
[    4.235090] SELinux:  Permission attach_queue in class tun_socket not defined in policy.
[    4.235093] SELinux: the above unknown classes and permissions will be allowed
[    4.235100] SELinux:  Completing initialization.
[    4.235101] SELinux:  Setting up existing superblocks.
[    4.235108] SELinux: initialized (dev sysfs, type sysfs), uses genfs_contexts
[    4.235112] SELinux: initialized (dev rootfs, type rootfs), uses genfs_contexts
[    4.235121] SELinux: initialized (dev bdev, type bdev), uses genfs_contexts
[    4.235125] SELinux: initialized (dev proc, type proc), uses genfs_contexts
[    4.235131] SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
[    4.235177] SELinux: initialized (dev devtmpfs, type devtmpfs), uses transition SIDs
[    4.235784] SELinux: initialized (dev sockfs, type sockfs), uses task SIDs
[    4.235799] SELinux: initialized (dev debugfs, type debugfs), uses genfs_contexts
[    4.236598] SELinux: initialized (dev pipefs, type pipefs), uses task SIDs
[    4.236602] SELinux: initialized (dev anon_inodefs, type anon_inodefs), uses genfs_contexts
[    4.236605] SELinux: initialized (dev devpts, type devpts), uses transition SIDs
[    4.236616] SELinux: initialized (dev hugetlbfs, type hugetlbfs), uses transition SIDs
[    4.236621] SELinux: initialized (dev mqueue, type mqueue), uses transition SIDs
[    4.236625] SELinux: initialized (dev selinuxfs, type selinuxfs), uses genfs_contexts
[    4.236636] SELinux: initialized (dev sysfs, type sysfs), uses genfs_contexts
[    4.236972] SELinux: initialized (dev securityfs, type securityfs), uses genfs_contexts
[    4.236974] SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
[    4.236979] SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
[    4.237045] SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
[    4.237069] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.237072] SELinux: initialized (dev pstore, type pstore), uses genfs_contexts
[    4.237074] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.237079] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.237095] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.237102] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.237106] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.237109] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.237112] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.237119] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.237127] SELinux: initialized (dev sda1, type ext4), uses xattr
[    4.253601] type=1403 audit(1367421659.145:3): policy loaded auid=4294967295 ses=4294967295
[    4.257370] systemd[1]: Successfully loaded SELinux policy in 281.994ms.
[    4.339728] systemd[1]: RTC configured in localtime, applying delta of -300 minutes to system time.
[    4.371033] systemd[1]: Relabelled /dev and /run in 27.106ms.
[    5.206011] SELinux: initialized (dev autofs, type autofs), uses genfs_contexts
[    5.298909] systemd-readahead[261]: Bumped block_nr parameter of 8:0 to 20480. This is a temporary hack and should be removed one day.
[    5.555544] systemd-udevd[269]: starting version 201
[    5.724129] SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
[    5.812564] SELinux: initialized (dev hugetlbfs, type hugetlbfs), uses transition SIDs
[    5.938105] EXT4-fs (sda1): re-mounted. Opts: data=writeback,barrier=0,errors=remount-ro
[    6.188274] microcode: CPU0: patch_level=0x01000086
[    6.200056] SELinux: initialized (dev binfmt_misc, type binfmt_misc), uses genfs_contexts
[    6.310766] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    6.310988] r8169 0000:03:00.0: irq 45 for MSI/MSI-X
[    6.311130] r8169 0000:03:00.0 eth0: RTL8168c/8111c at 0xffffc90000c7c000, 00:22:19:28:86:61, XID 1c4000c0 IRQ 45
[    6.311132] r8169 0000:03:00.0 eth0: jumbo features [frames: 6128 bytes, tx checksumming: ko]
[    6.311154] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    6.311198] r8169 0000:04:09.0 (unregistered net_device): not PCI Express
[    6.311406] r8169 0000:04:09.0 eth1: RTL8169sb/8110sb at 0xffffc90000c7ec00, 48:02:2a:07:90:45, XID 10000000 IRQ 20
[    6.311408] r8169 0000:04:09.0 eth1: jumbo features [frames: 7152 bytes, tx checksumming: ok]
[    6.361864] kvm: disabled by bios
[    6.365680] SELinux: initialized (dev configfs, type configfs), uses genfs_contexts
[    6.378369] systemd-udevd[319]: renamed network interface eth0 to p10p1
[    6.421541] microcode: CPU0: new patch_level=0x010000db
[    6.421560] microcode: CPU1: patch_level=0x01000086
[    6.421570] microcode: CPU1: new patch_level=0x010000db
[    6.421583] microcode: CPU2: patch_level=0x01000086
[    6.421592] microcode: CPU2: new patch_level=0x010000db
[    6.421597] microcode: CPU3: patch_level=0x01000086
[    6.421603] microcode: CPU3: new patch_level=0x010000db
[    6.421726] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    6.422292] kvm: disabled by bios
[    6.427619] kvm: disabled by bios
[    6.427792] acpi-cpufreq: overriding BIOS provided _PSD data
[    6.447774] k10temp 0000:00:18.3: unreliable CPU thermal sensor; monitoring disabled
[    6.468389] systemd-udevd[311]: renamed network interface eth1 to p8p1
[    6.481054] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[    6.486190] input: PC Speaker as /devices/platform/pcspkr/input/input5
[    6.491296] MCE: In-kernel MCE decoding enabled.
[    6.493031] EDAC MC: Ver: 3.0.0
[    6.494098] AMD64 EDAC driver v3.4.0
[    6.494209] EDAC amd64: DRAM ECC disabled.
[    6.494230] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
 Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
 (Note that use of the override may cause unknown side effects.)
[    6.556954] ACPI Warning: 0x0000000000000b00-0x0000000000000b07 SystemIO conflicts with Region \SOR1 1 (20130117/utaddress-251)
[    6.556973] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[    6.570747] sp5100_tco: SP5100/SB800 TCO WatchDog Timer Driver v0.05
[    6.570883] sp5100_tco: PCI Revision ID: 0x3a
[    6.570908] sp5100_tco: failed to find MMIO address, giving up.
[    6.655203] Adding 2008060k swap on /dev/sda2.  Priority:-1 extents:1 across:2008060k 
[    7.769558] EXT4-fs (sda4): mounting ext3 file system using the ext4 subsystem
[    7.988142] EXT4-fs (sda4): mounted filesystem with ordered data mode. Opts: (null)
[    7.988163] SELinux: initialized (dev sda4, type ext3), uses xattr
[    8.590198] EXT4-fs (sda3): barriers disabled
[    8.599088] EXT4-fs (sda3): mounted filesystem with writeback data mode. Opts: data=writeback,barrier=0,errors=remount-ro
[    8.599115] SELinux: initialized (dev sda3, type ext4), uses xattr
[    9.006168] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   11.292963] r8169 0000:03:00.0 p10p1: link down
[   11.292972] r8169 0000:03:00.0 p10p1: link down
[   11.293021] IPv6: ADDRCONF(NETDEV_UP): p10p1: link is not ready
[   11.301107] r8169 0000:04:09.0 p8p1: link down
[   11.301126] r8169 0000:04:09.0 p8p1: link down
[   11.301157] IPv6: ADDRCONF(NETDEV_UP): p8p1: link is not ready
[   12.334436] Bluetooth: Core ver 2.16
[   12.334519] NET: Registered protocol family 31
[   12.334520] Bluetooth: HCI device and connection manager initialized
[   12.334529] Bluetooth: HCI socket layer initialized
[   12.334532] Bluetooth: L2CAP socket layer initialized
[   12.334536] Bluetooth: SCO socket layer initialized
[   12.460073] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   12.460083] Bluetooth: BNEP filters: protocol multicast
[   12.460102] Bluetooth: BNEP socket layer initialized
[   13.618238] r8169 0000:04:09.0 p8p1: link up
[   13.618260] IPv6: ADDRCONF(NETDEV_CHANGE): p8p1: link becomes ready
[   13.693990] r8169 0000:03:00.0 p10p1: link up
[   13.694011] IPv6: ADDRCONF(NETDEV_CHANGE): p10p1: link becomes ready
[   15.007800] IN=p8p1 OUT= MAC=ff:ff:ff:ff:ff:ff:00:22:19:28:86:61:08:00 SRC=0.0.0.0 DST=255.255.255.255 LEN=328 TOS=0x10 PREC=0x00 TTL=128 ID=0 PROTO=UDP SPT=68 DPT=67 LEN=308 
[   15.177538] vgaarb: device changed decodes: PCI:0000:02:00.0,olddecodes=io+mem,decodes=none:owns=none
[   15.177543] vgaarb: device changed decodes: PCI:0000:01:00.0,olddecodes=io+mem,decodes=none:owns=io+mem
[   17.891752] IN=p8p1 OUT= MAC=ff:ff:ff:ff:ff:ff:00:22:19:28:86:61:08:00 SRC=0.0.0.0 DST=255.255.255.255 LEN=328 TOS=0x10 PREC=0x00 TTL=128 ID=0 PROTO=UDP SPT=68 DPT=67 LEN=308 
[   28.421540] fuse init (API version 7.21)
[   28.425708] SELinux: initialized (dev fuse, type fuse), uses genfs_contexts
[   62.569443] r8169 0000:04:09.0 p8p1: link down
[   62.592949] r8169 0000:03:00.0 p10p1: link down
[   64.908617] r8169 0000:04:09.0 p8p1: link up
[   64.957276] r8169 0000:03:00.0 p10p1: link up
[   74.605912] ata3: exception Emask 0x40 SAct 0x0 SErr 0x800 action 0x7
[   74.605918] ata3: SError: { HostInt }
[   74.605923] ata3: hard resetting link
[   75.064802] ata3: softreset failed (device not ready)
[   75.064815] ata3: applying PMP SRST workaround and retrying
[   75.219614] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[   75.220677] ata3.00: configured for UDMA/133
[   75.231610] ata3: EH complete
[  271.440427] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=184.30.14.216 DST=192.168.1.69 LEN=89 TOS=0x00 PREC=0x00 TTL=50 ID=63778 DF PROTO=TCP SPT=443 DPT=48529 WINDOW=8893 RES=0x00 ACK PSH URGP=0 
[  271.440688] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=184.30.14.216 DST=192.168.1.69 LEN=52 TOS=0x00 PREC=0x00 TTL=50 ID=63779 DF PROTO=TCP SPT=443 DPT=48529 WINDOW=8893 RES=0x00 ACK FIN URGP=0 
[  273.208535] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=184.30.14.216 DST=192.168.1.69 LEN=89 TOS=0x00 PREC=0x00 TTL=50 ID=63780 DF PROTO=TCP SPT=443 DPT=48529 WINDOW=8893 RES=0x00 ACK PSH URGP=0 
[  276.740987] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=184.30.14.216 DST=192.168.1.69 LEN=89 TOS=0x00 PREC=0x00 TTL=50 ID=63781 DF PROTO=TCP SPT=443 DPT=48529 WINDOW=8893 RES=0x00 ACK PSH URGP=0 
[  283.815012] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=184.30.14.216 DST=192.168.1.69 LEN=89 TOS=0x00 PREC=0x00 TTL=50 ID=63782 DF PROTO=TCP SPT=443 DPT=48529 WINDOW=8893 RES=0x00 ACK PSH URGP=0 
[  297.947651] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=184.30.14.216 DST=192.168.1.69 LEN=89 TOS=0x00 PREC=0x00 TTL=50 ID=63783 DF PROTO=TCP SPT=443 DPT=48529 WINDOW=8893 RES=0x00 ACK PSH URGP=0 
[  326.178696] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=184.30.14.216 DST=192.168.1.69 LEN=89 TOS=0x00 PREC=0x00 TTL=50 ID=63784 DF PROTO=TCP SPT=443 DPT=48529 WINDOW=8893 RES=0x00 ACK PSH URGP=0 
[  431.835094] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.139.188 DST=192.168.1.69 LEN=226 TOS=0x00 PREC=0x00 TTL=44 ID=50085 PROTO=TCP SPT=5228 DPT=42847 WINDOW=1002 RES=0x00 ACK PSH URGP=0 
[  432.177632] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.139.188 DST=192.168.1.69 LEN=226 TOS=0x00 PREC=0x00 TTL=44 ID=50086 PROTO=TCP SPT=5228 DPT=42847 WINDOW=1002 RES=0x00 ACK PSH URGP=0 
[  433.109391] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.139.188 DST=192.168.1.69 LEN=226 TOS=0x00 PREC=0x00 TTL=44 ID=50087 PROTO=TCP SPT=5228 DPT=42847 WINDOW=1002 RES=0x00 ACK PSH URGP=0 
[  433.940937] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.139.188 DST=192.168.1.69 LEN=226 TOS=0x00 PREC=0x00 TTL=44 ID=50088 PROTO=TCP SPT=5228 DPT=42847 WINDOW=1002 RES=0x00 ACK PSH URGP=0 
[  436.068786] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.134.108 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=60851 PROTO=TCP SPT=587 DPT=47778 WINDOW=0 RES=0x00 RST URGP=0 
[  438.153011] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.139.188 DST=192.168.1.69 LEN=226 TOS=0x00 PREC=0x00 TTL=44 ID=50089 PROTO=TCP SPT=5228 DPT=42847 WINDOW=1002 RES=0x00 ACK PSH URGP=0 
[  446.577432] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.139.188 DST=192.168.1.69 LEN=226 TOS=0x00 PREC=0x00 TTL=44 ID=50090 PROTO=TCP SPT=5228 DPT=42847 WINDOW=1002 RES=0x00 ACK PSH URGP=0 
[  456.570175] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.139.188 DST=192.168.1.69 LEN=226 TOS=0x00 PREC=0x00 TTL=44 ID=50091 PROTO=TCP SPT=5228 DPT=42847 WINDOW=1002 RES=0x00 ACK PSH URGP=0 
[  461.920165] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.130.109 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=25136 PROTO=TCP SPT=993 DPT=40111 WINDOW=0 RES=0x00 RST URGP=0 
[  466.561423] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.139.188 DST=192.168.1.69 LEN=226 TOS=0x00 PREC=0x00 TTL=44 ID=50092 PROTO=TCP SPT=5228 DPT=42847 WINDOW=1002 RES=0x00 ACK PSH URGP=0 
[  476.552669] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.139.188 DST=192.168.1.69 LEN=226 TOS=0x00 PREC=0x00 TTL=44 ID=50093 PROTO=TCP SPT=5228 DPT=42847 WINDOW=1002 RES=0x00 ACK PSH URGP=0 
[  486.543904] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.139.188 DST=192.168.1.69 LEN=226 TOS=0x00 PREC=0x00 TTL=44 ID=50094 PROTO=TCP SPT=5228 DPT=42847 WINDOW=1002 RES=0x00 ACK PSH URGP=0 
[ 1241.858832] r8169 0000:04:09.0 p8p1: link down
[ 1241.884743] r8169 0000:03:00.0 p10p1: link down
[ 1244.238997] r8169 0000:04:09.0 p8p1: link up
[ 1244.316354] r8169 0000:03:00.0 p10p1: link up
[ 1301.871665] r8169 0000:03:00.0 p10p1: link down
[ 1304.273223] r8169 0000:03:00.0 p10p1: link up
[ 1321.884085] r8169 0000:04:09.0 p8p1: link down
[ 1324.239347] r8169 0000:04:09.0 p8p1: link up
[ 1897.596085] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.130.109 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=43581 PROTO=TCP SPT=993 DPT=40255 WINDOW=0 RES=0x00 RST URGP=0 
[ 3946.589003] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=8.254.64.126 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=47 ID=0 DF PROTO=TCP SPT=80 DPT=52543 WINDOW=0 RES=0x00 RST URGP=0 
[ 4005.191275] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=216.239.127.78 DST=192.168.1.69 LEN=56 TOS=0x00 PREC=0xE0 TTL=237 ID=1521 PROTO=ICMP TYPE=11 CODE=0 [SRC=192.168.1.69 DST=216.239.127.70 LEN=70 TOS=0x00 PREC=0x00 TTL=1 ID=45112 PROTO=UDP SPT=26299 DPT=53 LEN=50 ] 
[ 4005.554571] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=216.239.127.78 DST=192.168.1.69 LEN=56 TOS=0x00 PREC=0xE0 TTL=237 ID=2713 PROTO=ICMP TYPE=11 CODE=0 [SRC=192.168.1.69 DST=216.239.127.70 LEN=70 TOS=0x00 PREC=0x00 TTL=1 ID=45113 PROTO=UDP SPT=10701 DPT=53 LEN=50 ] 
[ 4005.931689] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=216.239.127.78 DST=192.168.1.69 LEN=56 TOS=0x00 PREC=0xE0 TTL=237 ID=4087 PROTO=ICMP TYPE=11 CODE=0 [SRC=192.168.1.69 DST=216.239.127.70 LEN=70 TOS=0x00 PREC=0x00 TTL=1 ID=45114 PROTO=UDP SPT=24500 DPT=53 LEN=50 ] 
[ 4006.687494] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=216.239.127.78 DST=192.168.1.69 LEN=56 TOS=0x00 PREC=0xE0 TTL=237 ID=7519 PROTO=ICMP TYPE=11 CODE=0 [SRC=192.168.1.69 DST=216.239.127.70 LEN=70 TOS=0x00 PREC=0x00 TTL=1 ID=45115 PROTO=UDP SPT=62126 DPT=53 LEN=50 ] 
[ 4260.008837] r8169 0000:04:09.0 p8p1: link down
[ 4260.035742] r8169 0000:03:00.0 p10p1: link down
[ 4262.428926] r8169 0000:04:09.0 p8p1: link up
[ 4262.644022] r8169 0000:03:00.0 p10p1: link up
[ 4320.021974] r8169 0000:04:09.0 p8p1: link down
[ 4320.043588] r8169 0000:03:00.0 p10p1: link down
[ 4322.412767] r8169 0000:03:00.0 p10p1: link up
[ 4322.932128] r8169 0000:04:09.0 p8p1: link up
[ 4373.233380] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.120 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=1546 PROTO=TCP SPT=443 DPT=37531 WINDOW=0 RES=0x00 RST URGP=0 
[ 4567.577301] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.138 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=24087 PROTO=TCP SPT=443 DPT=42753 WINDOW=0 RES=0x00 RST URGP=0 
[ 4942.332456] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.102 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=33556 PROTO=TCP SPT=443 DPT=35094 WINDOW=0 RES=0x00 RST URGP=0 
[ 4942.333683] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.102 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=33557 PROTO=TCP SPT=443 DPT=35094 WINDOW=0 RES=0x00 RST URGP=0 
[ 4942.334921] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.102 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=33558 PROTO=TCP SPT=443 DPT=35094 WINDOW=0 RES=0x00 RST URGP=0 
[ 5153.954338] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.84 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=2462 PROTO=TCP SPT=443 DPT=56147 WINDOW=0 RES=0x00 RST URGP=0 
[ 5153.955146] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.84 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=2463 PROTO=TCP SPT=443 DPT=56147 WINDOW=0 RES=0x00 RST URGP=0 
[ 5153.955392] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.84 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=2464 PROTO=TCP SPT=443 DPT=56147 WINDOW=0 RES=0x00 RST URGP=0 
[ 9863.407437] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=66.155.171.116 DST=192.168.1.69 LEN=102 TOS=0x00 PREC=0x00 TTL=42 ID=42043 PROTO=ICMP TYPE=3 CODE=3 [SRC=192.168.1.69 DST=66.155.171.116 LEN=74 TOS=0x00 PREC=0x00 TTL=42 ID=48803 PROTO=UDP SPT=13974 DPT=53 LEN=54 ] 
[ 9863.565922] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=66.155.171.116 DST=192.168.1.69 LEN=106 TOS=0x00 PREC=0x00 TTL=42 ID=42044 PROTO=ICMP TYPE=3 CODE=3 [SRC=192.168.1.69 DST=66.155.171.116 LEN=78 TOS=0x00 PREC=0x00 TTL=42 ID=48804 PROTO=UDP SPT=37457 DPT=53 LEN=58 ] 
[ 9863.782297] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=66.155.171.116 DST=192.168.1.69 LEN=102 TOS=0x00 PREC=0x00 TTL=42 ID=42045 PROTO=ICMP TYPE=3 CODE=3 [SRC=192.168.1.69 DST=66.155.171.116 LEN=74 TOS=0x00 PREC=0x00 TTL=42 ID=48805 PROTO=UDP SPT=35287 DPT=53 LEN=54 ] 
[ 9863.926547] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=66.155.171.116 DST=192.168.1.69 LEN=106 TOS=0x00 PREC=0x00 TTL=42 ID=42046 PROTO=ICMP TYPE=3 CODE=3 [SRC=192.168.1.69 DST=66.155.171.116 LEN=78 TOS=0x00 PREC=0x00 TTL=42 ID=48806 PROTO=UDP SPT=62838 DPT=53 LEN=58 ] 
[14102.043231] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.18 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=29408 PROTO=TCP SPT=443 DPT=55851 WINDOW=0 RES=0x00 RST URGP=0 
[14671.599232] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.95 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=23847 PROTO=TCP SPT=443 DPT=49747 WINDOW=0 RES=0x00 RST URGP=0 
[14671.600378] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.95 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=23848 PROTO=TCP SPT=443 DPT=49747 WINDOW=0 RES=0x00 RST URGP=0 
[14671.601816] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.95 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=23849 PROTO=TCP SPT=443 DPT=49747 WINDOW=0 RES=0x00 RST URGP=0 
[15525.704148] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.104 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=30006 PROTO=TCP SPT=443 DPT=44342 WINDOW=0 RES=0x00 RST URGP=0 
[15525.705503] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.104 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=30007 PROTO=TCP SPT=443 DPT=44342 WINDOW=0 RES=0x00 RST URGP=0 
[15525.705627] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.104 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=30008 PROTO=TCP SPT=443 DPT=44342 WINDOW=0 RES=0x00 RST URGP=0 
[16245.016611] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.104 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=7766 PROTO=TCP SPT=443 DPT=44413 WINDOW=0 RES=0x00 RST URGP=0 
[16245.021750] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.104 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=7767 PROTO=TCP SPT=443 DPT=44413 WINDOW=0 RES=0x00 RST URGP=0 
[16245.021863] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.104 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=7768 PROTO=TCP SPT=443 DPT=44413 WINDOW=0 RES=0x00 RST URGP=0 
[16245.026949] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.138 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=49253 PROTO=TCP SPT=443 DPT=43325 WINDOW=0 RES=0x00 RST URGP=0 
[16245.028090] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.138 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=49254 PROTO=TCP SPT=443 DPT=43325 WINDOW=0 RES=0x00 RST URGP=0 
[16245.029295] IN=p10p1 OUT= MAC=00:22:19:28:86:61:14:5b:d1:dd:6e:50:08:00 SRC=74.125.137.138 DST=192.168.1.69 LEN=40 TOS=0x00 PREC=0x00 TTL=44 ID=49255 PROTO=TCP SPT=443 DPT=43325 WINDOW=0 RES=0x00 RST URGP=0 

--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="interrupts.aout.txt"

           CPU0       CPU1       CPU2       CPU3       
  0:        129          0          0          0   IO-APIC-edge      timer
  1:          0          0          2          0   IO-APIC-edge      i8042
  7:          1          0          0          0   IO-APIC-edge    
  8:          0          0          1          0   IO-APIC-edge      rtc0
  9:          0          0          0          0   IO-APIC-fasteoi   acpi
 12:          0          0          0          4   IO-APIC-edge      i8042
 14:          0          0          0          0   IO-APIC-edge      pata_atiixp
 15:          0          0          0          0   IO-APIC-edge      pata_atiixp
 16:          0          0         15         55   IO-APIC-fasteoi   ohci_hcd:usb3, ohci_hcd:usb4
 17:          0          0          0          3   IO-APIC-fasteoi   ehci_hcd:usb1
 18:          0          0          1         33   IO-APIC-fasteoi   ohci_hcd:usb5, ohci_hcd:usb6, ohci_hcd:usb7
 19:          0          0          0          2   IO-APIC-fasteoi   ehci_hcd:usb2
 20:     431440          0         11         23   IO-APIC-fasteoi   p8p1
 22:       8092      58688      47436      41380   IO-APIC-fasteoi   ahci
 23:          0          0          0          2   IO-APIC-fasteoi   firewire_ohci
 43:          1          2         11       5575   PCI-MSI-edge      radeon
 44:          0          0          0          2   PCI-MSI-edge      radeon
 45:          0          0          0     393095   PCI-MSI-edge      p10p1
NMI:          0          0          0          0   Non-maskable interrupts
LOC:    1417407    1538471    1400002    1485117   Local timer interrupts
SPU:          0          0          0          0   Spurious interrupts
PMI:          0          0          0          0   Performance monitoring interrupts
IWI:          1          1          1         37   IRQ work interrupts
RTR:          0          0          0          0   APIC ICR read retries
RES:     647089     437516     426581     401762   Rescheduling interrupts
CAL:        359        390        433        224   Function call interrupts
TLB:      14815      15475      15245      15919   TLB shootdowns
TRM:          0          0          0          0   Thermal event interrupts
THR:          0          0          0          0   Threshold APIC interrupts
MCE:          0          0          0          0   Machine check exceptions
MCP:         59         59         59         59   Machine check polls
ERR:          1
MIS:          0

--cWoXeonUoKmBZSoM--
