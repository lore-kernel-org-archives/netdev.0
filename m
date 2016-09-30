From: vorohin907@gmail.com
Subject: Kernel panic + grsec patch kernel
Date: Fri, 30 Sep 2016 21:33:07 +1000
Message-ID: <20160930113307.GA20552@DEV>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="jI8keyz6grp/JLjh"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:33804 "EHLO
        mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932731AbcI3LdR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 07:33:17 -0400
Received: by mail-lf0-f51.google.com with SMTP id y6so102910302lff.1
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 04:33:16 -0700 (PDT)
Received: from DEV ([46.37.159.101])
        by smtp.gmail.com with ESMTPSA id m63sm2967224lfm.25.2016.09.30.04.33.10
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 30 Sep 2016 04:33:13 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello!
I would like to deal with the issue of kernel panic when using PAX.
Kernel panic occurs when you use wi fi.

All reports are in this thread.

https://forums.grsecurity.net/viewtopic.php?f=3&t=4574

I applied to the letter dmesg ( pax_size_overflow_report_only )

Said to write to this address.

Thank you!

--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=dmesg

[    0.000000]  gran_size: 1M 	chunk_size: 64M 	num_reg: 10  	lose cover RAM: 0G
[    0.000000]  gran_size: 1M 	chunk_size: 128M 	num_reg: 10  	lose cover RAM: 0G
[    0.000000]  gran_size: 1M 	chunk_size: 256M 	num_reg: 10  	lose cover RAM: 0G
[    0.000000] *BAD*gran_size: 1M 	chunk_size: 512M 	num_reg: 10  	lose cover RAM: -256M
[    0.000000]  gran_size: 1M 	chunk_size: 1G 	num_reg: 10  	lose cover RAM: 0G
[    0.000000] *BAD*gran_size: 1M 	chunk_size: 2G 	num_reg: 10  	lose cover RAM: -1G
[    0.000000]  gran_size: 2M 	chunk_size: 2M 	num_reg: 10  	lose cover RAM: 54M
[    0.000000]  gran_size: 2M 	chunk_size: 4M 	num_reg: 10  	lose cover RAM: 54M
[    0.000000]  gran_size: 2M 	chunk_size: 8M 	num_reg: 10  	lose cover RAM: 54M
[    0.000000]  gran_size: 2M 	chunk_size: 16M 	num_reg: 10  	lose cover RAM: 0G
[    0.000000]  gran_size: 2M 	chunk_size: 32M 	num_reg: 10  	lose cover RAM: 0G
[    0.000000]  gran_size: 2M 	chunk_size: 64M 	num_reg: 10  	lose cover RAM: 0G
[    0.000000]  gran_size: 2M 	chunk_size: 128M 	num_reg: 10  	lose cover RAM: 0G
[    0.000000]  gran_size: 2M 	chunk_size: 256M 	num_reg: 10  	lose cover RAM: 0G
[    0.000000] *BAD*gran_size: 2M 	chunk_size: 512M 	num_reg: 10  	lose cover RAM: -256M
[    0.000000]  gran_size: 2M 	chunk_size: 1G 	num_reg: 10  	lose cover RAM: 0G
[    0.000000] *BAD*gran_size: 2M 	chunk_size: 2G 	num_reg: 10  	lose cover RAM: -1G
[    0.000000]  gran_size: 4M 	chunk_size: 4M 	num_reg: 10  	lose cover RAM: 54M
[    0.000000]  gran_size: 4M 	chunk_size: 8M 	num_reg: 10  	lose cover RAM: 54M
[    0.000000]  gran_size: 4M 	chunk_size: 16M 	num_reg: 10  	lose cover RAM: 2M
[    0.000000]  gran_size: 4M 	chunk_size: 32M 	num_reg: 10  	lose cover RAM: 2M
[    0.000000]  gran_size: 4M 	chunk_size: 64M 	num_reg: 10  	lose cover RAM: 2M
[    0.000000]  gran_size: 4M 	chunk_size: 128M 	num_reg: 10  	lose cover RAM: 2M
[    0.000000]  gran_size: 4M 	chunk_size: 256M 	num_reg: 10  	lose cover RAM: 2M
[    0.000000] *BAD*gran_size: 4M 	chunk_size: 512M 	num_reg: 10  	lose cover RAM: -254M
[    0.000000]  gran_size: 4M 	chunk_size: 1G 	num_reg: 10  	lose cover RAM: 2M
[    0.000000] *BAD*gran_size: 4M 	chunk_size: 2G 	num_reg: 10  	lose cover RAM: -1022M
[    0.000000]  gran_size: 8M 	chunk_size: 8M 	num_reg: 10  	lose cover RAM: 54M
[    0.000000]  gran_size: 8M 	chunk_size: 16M 	num_reg: 10  	lose cover RAM: 22M
[    0.000000]  gran_size: 8M 	chunk_size: 32M 	num_reg: 9  	lose cover RAM: 6M
[    0.000000]  gran_size: 8M 	chunk_size: 64M 	num_reg: 9  	lose cover RAM: 6M
[    0.000000]  gran_size: 8M 	chunk_size: 128M 	num_reg: 9  	lose cover RAM: 6M
[    0.000000]  gran_size: 8M 	chunk_size: 256M 	num_reg: 9  	lose cover RAM: 6M
[    0.000000]  gran_size: 8M 	chunk_size: 512M 	num_reg: 10  	lose cover RAM: 6M
[    0.000000]  gran_size: 8M 	chunk_size: 1G 	num_reg: 9  	lose cover RAM: 6M
[    0.000000]  gran_size: 8M 	chunk_size: 2G 	num_reg: 10  	lose cover RAM: 6M
[    0.000000]  gran_size: 16M 	chunk_size: 16M 	num_reg: 10  	lose cover RAM: 30M
[    0.000000]  gran_size: 16M 	chunk_size: 32M 	num_reg: 9  	lose cover RAM: 14M
[    0.000000]  gran_size: 16M 	chunk_size: 64M 	num_reg: 9  	lose cover RAM: 14M
[    0.000000]  gran_size: 16M 	chunk_size: 128M 	num_reg: 9  	lose cover RAM: 14M
[    0.000000]  gran_size: 16M 	chunk_size: 256M 	num_reg: 9  	lose cover RAM: 14M
[    0.000000]  gran_size: 16M 	chunk_size: 512M 	num_reg: 10  	lose cover RAM: 14M
[    0.000000]  gran_size: 16M 	chunk_size: 1G 	num_reg: 9  	lose cover RAM: 14M
[    0.000000]  gran_size: 16M 	chunk_size: 2G 	num_reg: 10  	lose cover RAM: 14M
[    0.000000]  gran_size: 32M 	chunk_size: 32M 	num_reg: 9  	lose cover RAM: 46M
[    0.000000]  gran_size: 32M 	chunk_size: 64M 	num_reg: 9  	lose cover RAM: 46M
[    0.000000]  gran_size: 32M 	chunk_size: 128M 	num_reg: 9  	lose cover RAM: 46M
[    0.000000]  gran_size: 32M 	chunk_size: 256M 	num_reg: 9  	lose cover RAM: 46M
[    0.000000]  gran_size: 32M 	chunk_size: 512M 	num_reg: 10  	lose cover RAM: 46M
[    0.000000]  gran_size: 32M 	chunk_size: 1G 	num_reg: 9  	lose cover RAM: 46M
[    0.000000]  gran_size: 32M 	chunk_size: 2G 	num_reg: 10  	lose cover RAM: 46M
[    0.000000]  gran_size: 64M 	chunk_size: 64M 	num_reg: 7  	lose cover RAM: 110M
[    0.000000]  gran_size: 64M 	chunk_size: 128M 	num_reg: 7  	lose cover RAM: 110M
[    0.000000]  gran_size: 64M 	chunk_size: 256M 	num_reg: 8  	lose cover RAM: 110M
[    0.000000]  gran_size: 64M 	chunk_size: 512M 	num_reg: 9  	lose cover RAM: 110M
[    0.000000]  gran_size: 64M 	chunk_size: 1G 	num_reg: 8  	lose cover RAM: 110M
[    0.000000]  gran_size: 64M 	chunk_size: 2G 	num_reg: 9  	lose cover RAM: 110M
[    0.000000]  gran_size: 128M 	chunk_size: 128M 	num_reg: 6  	lose cover RAM: 174M
[    0.000000]  gran_size: 128M 	chunk_size: 256M 	num_reg: 8  	lose cover RAM: 174M
[    0.000000]  gran_size: 128M 	chunk_size: 512M 	num_reg: 9  	lose cover RAM: 174M
[    0.000000]  gran_size: 128M 	chunk_size: 1G 	num_reg: 8  	lose cover RAM: 174M
[    0.000000]  gran_size: 128M 	chunk_size: 2G 	num_reg: 9  	lose cover RAM: 174M
[    0.000000]  gran_size: 256M 	chunk_size: 256M 	num_reg: 4  	lose cover RAM: 430M
[    0.000000]  gran_size: 256M 	chunk_size: 512M 	num_reg: 4  	lose cover RAM: 430M
[    0.000000]  gran_size: 256M 	chunk_size: 1G 	num_reg: 5  	lose cover RAM: 430M
[    0.000000]  gran_size: 256M 	chunk_size: 2G 	num_reg: 6  	lose cover RAM: 430M
[    0.000000]  gran_size: 512M 	chunk_size: 512M 	num_reg: 4  	lose cover RAM: 430M
[    0.000000]  gran_size: 512M 	chunk_size: 1G 	num_reg: 5  	lose cover RAM: 430M
[    0.000000]  gran_size: 512M 	chunk_size: 2G 	num_reg: 6  	lose cover RAM: 430M
[    0.000000]  gran_size: 1G 	chunk_size: 1G 	num_reg: 3  	lose cover RAM: 942M
[    0.000000]  gran_size: 1G 	chunk_size: 2G 	num_reg: 3  	lose cover RAM: 942M
[    0.000000]  gran_size: 2G 	chunk_size: 2G 	num_reg: 2  	lose cover RAM: 1966M
[    0.000000] mtrr_cleanup: can not find optimal value
[    0.000000] please specify mtrr_gran_size/mtrr_chunk_size
[    0.000000] e820: update [mem 0xcb800000-0xffffffff] usable ==> reserved
[    0.000000] e820: last_pfn = 0xcb000 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000fd820-0x000fd82f] mapped at [ffff8800000fd820]
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000097000] 97000 size 24576
[    0.000000] BRK [0x02c90000, 0x02c90fff] PGTABLE
[    0.000000] BRK [0x02c91000, 0x02c91fff] PGTABLE
[    0.000000] BRK [0x02c92000, 0x02c92fff] PGTABLE
[    0.000000] BRK [0x02c93000, 0x02c93fff] PGTABLE
[    0.000000] BRK [0x02c94000, 0x02c94fff] PGTABLE
[    0.000000] BRK [0x02c95000, 0x02c95fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x346a4000-0x36349fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0490 000024 (v02 ALASKA)
[    0.000000] ACPI: XSDT 0x00000000C9EDF078 000074 (v01 ALASKA A M I    01072009 AMI  00010013)
[    0.000000] ACPI: FACP 0x00000000C9EE9D58 00010C (v05 ALASKA A M I    01072009 AMI  00010013)
[    0.000000] ACPI: DSDT 0x00000000C9EDF188 00ABCD (v02 ALASKA A M I    00000023 INTL 20051117)
[    0.000000] ACPI: FACS 0x00000000C9F21080 000040
[    0.000000] ACPI: APIC 0x00000000C9EE9E68 000072 (v03 ALASKA A M I    01072009 AMI  00010013)
[    0.000000] ACPI: FPDT 0x00000000C9EE9EE0 000044 (v01 ALASKA A M I    01072009 AMI  00010013)
[    0.000000] ACPI: MCFG 0x00000000C9EE9F28 00003C (v01 ALASKA A M I    01072009 MSFT 00000097)
[    0.000000] ACPI: SSDT 0x00000000C9EE9F68 000F92 (v01 TrmRef PtidDevc 00001000 INTL 20091112)
[    0.000000] ACPI: HPET 0x00000000C9EEAF00 000038 (v01 ALASKA A M I    01072009 AMI. 00000005)
[    0.000000] ACPI: SSDT 0x00000000C9EEAF38 000315 (v01 SataRe SataTabl 00001000 INTL 20091112)
[    0.000000] ACPI: SSDT 0x00000000C9EEB250 000968 (v01 PmRef  Cpu0Ist  00003000 INTL 20051117)
[    0.000000] ACPI: SSDT 0x00000000C9EEBBB8 000B22 (v01 PmRef  CpuPm    00003000 INTL 20051117)
[    0.000000] ACPI: SSDT 0x00000000C9EEC6E0 000D30 (v01 NvdRef NvdTabl  00001000 INTL 20091112)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000022f5fffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x22f5f4000-0x22f5f7fff]
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000022f5fffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009cfff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000001fffffff]
[    0.000000]   node   0: [mem 0x0000000020200000-0x0000000040003fff]
[    0.000000]   node   0: [mem 0x0000000040005000-0x00000000c96cefff]
[    0.000000]   node   0: [mem 0x00000000c9dcd000-0x00000000c9e5afff]
[    0.000000]   node   0: [mem 0x00000000ca5b7000-0x00000000ca5b7fff]
[    0.000000]   node   0: [mem 0x00000000ca5fb000-0x00000000cad5ffff]
[    0.000000]   node   0: [mem 0x00000000caff3000-0x00000000caffffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x000000022f5fffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000022f5fffff]
[    0.000000] On node 0 totalpages: 2069099
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3996 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 12852 pages used for memmap
[    0.000000]   DMA32 zone: 822479 pages, LIFO batch:31
[    0.000000]   Normal zone: 19416 pages used for memmap
[    0.000000]   Normal zone: 1242624 pages, LIFO batch:31
[    0.000000] Reserving Intel graphics stolen memory at 0xcba00000-0xcf9fffff
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[    0.000000] smpboot: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009d000-0x0009dfff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x20000000-0x201fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x40004000-0x40004fff]
[    0.000000] PM: Registered nosave memory: [mem 0xc96cf000-0xc9dccfff]
[    0.000000] PM: Registered nosave memory: [mem 0xc9e5b000-0xc9f22fff]
[    0.000000] PM: Registered nosave memory: [mem 0xc9f23000-0xca5b6fff]
[    0.000000] PM: Registered nosave memory: [mem 0xca5b8000-0xca5fafff]
[    0.000000] PM: Registered nosave memory: [mem 0xcad60000-0xcaff2fff]
[    0.000000] PM: Registered nosave memory: [mem 0xcb000000-0xcb7fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xcb800000-0xcf9fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xcfa00000-0xf7ffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xf8000000-0xfbffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfc000000-0xfebfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xfec00fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec01000-0xfecfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed00000-0xfed03fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed04000-0xfed1bfff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xfedfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfee00000-0xfee00fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfee01000-0xfeffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xff000000-0xffffffff]
[    0.000000] e820: [mem 0xcfa00000-0xf7ffffff] available for PCI devices
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
[    0.000000] setup_percpu: NR_CPUS:256 nr_cpumask_bits:256 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] percpu: Embedded 30 pages/cpu @ffff88022f200000 s85464 r8192 d29224 u524288
[    0.000000] pcpu-alloc: s85464 r8192 d29224 u524288 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 2036746
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-4.7.4-grsec root=UUID=f53d38fd-758e-40b1-b63a-4d5751a3982a pax_size_overflow_report_only ro quiet
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Memory: 8019812K/8276396K available (10004K kernel code, 3194K rwdata, 8252K rodata, 3056K init, 1572K bss, 256584K reserved, 0K cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	Build-time adjustment of leaf fanout to 64.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=256 to nr_cpu_ids=4.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=64, nr_cpu_ids=4
[    0.000000] NR_IRQS:16640 nr_irqs:456 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484882848 ns
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 2494.554 MHz processor
[    0.000016] Calibrating delay loop (skipped), value calculated using timer frequency.. 4989.10 BogoMIPS (lpj=9978216)
[    0.000019] pid_max: default: 32768 minimum: 501
[    0.000026] ACPI: Core revision 20160422
[    0.007719] ACPI: 6 ACPI AML tables successfully acquired and loaded

[    0.007739] Security Framework initialized
[    0.007746] AppArmor: AppArmor initialized
[    0.008257] Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.010235] Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.011109] Mount-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.011119] Mountpoint-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.011398] CPU: Physical Processor ID: 0
[    0.011400] CPU: Processor Core ID: 0
[    0.011404] ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
[    0.011405] ENERGY_PERF_BIAS: View and update with x86_energy_perf_policy(8)
[    0.011407] PAX: PCID detected
[    0.011409] mce: CPU supports 7 MCE banks
[    0.011418] CPU0: Thermal monitoring enabled (TM1)
[    0.011428] process: using mwait in idle threads
[    0.011431] Last level iTLB entries: 4KB 512, 2MB 8, 4MB 8
[    0.011432] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32, 1GB 0
[    0.023705] Freeing SMP alternatives memory: 40K (ffffffff82afc000 - ffffffff82b06000)
[    0.035616] ftrace: allocating 30797 entries in 121 pages
[    0.058658] smpboot: Max logical packages: 2
[    0.058661] smpboot: APIC(0) Converting physical 0 to logical package 0
[    0.058735] x2apic: IRQ remapping doesn't support X2APIC mode
[    0.059152] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.098839] TSC deadline timer enabled
[    0.098842] smpboot: CPU0: Intel(R) Core(TM) i5-3210M CPU @ 2.50GHz (family: 0x6, model: 0x3a, stepping: 0x9)
[    0.098847] Performance Events: PEBS fmt1+, 16-deep LBR, IvyBridge events, full-width counters, Intel PMU driver.
[    0.098873] ... version:                3
[    0.098875] ... bit width:              48
[    0.098876] ... generic registers:      4
[    0.098877] ... value mask:             0000ffffffffffff
[    0.098878] ... max period:             0000ffffffffffff
[    0.098879] ... fixed-purpose events:   3
[    0.098880] ... event mask:             000000070000000f
[    0.099525] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[    0.099637] x86: Booting SMP configuration:
[    0.099639] .... node  #0, CPUs:      #1
[    0.099906] PAX: PCID detected
[    0.181027]  #2
[    0.181309] PAX: PCID detected
[    0.261321]  #3
[    0.261321] PAX: PCID detected
[    0.340990] x86: Booted up 1 node, 4 CPUs
[    0.340995] smpboot: Total of 4 processors activated (19960.80 BogoMIPS)
[    0.343946] devtmpfs: initialized
[    0.344009] x86/mm: Memory block size: 128MB
[    0.347170] evm: security.selinux
[    0.347172] evm: security.SMACK64
[    0.347173] evm: security.SMACK64EXEC
[    0.347173] evm: security.SMACK64TRANSMUTE
[    0.347174] evm: security.SMACK64MMAP
[    0.347175] evm: security.ima
[    0.347176] evm: security.capability
[    0.347240] PM: Registering ACPI NVS region [mem 0xc9e5b000-0xc9f22fff] (819200 bytes)
[    0.347253] PM: Registering ACPI NVS region [mem 0xca5b8000-0xca5fafff] (274432 bytes)
[    0.347318] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.347357] pinctrl core: initialized pinctrl subsystem
[    0.347467] RTC time:  2:40:03, date: 09/30/16
[    0.347557] NET: Registered protocol family 16
[    0.359638] cpuidle: using governor ladder
[    0.364968] cpuidle: using governor menu
[    0.365060] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
[    0.365062] ACPI: bus type PCI registered
[    0.365064] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.365134] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.365137] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in E820
[    0.365145] pmd_set_huge: Cannot satisfy [mem 0xf8000000-0xf8200000] with a huge-page mapping due to MTRR override.
[    0.365198] PCI: Using configuration type 1 for base access
[    0.365239] core: PMU erratum BJ122, BV98, HSD29 worked around, HT is on
[    0.373131] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.373367] ACPI: Added _OSI(Module Device)
[    0.373369] ACPI: Added _OSI(Processor Device)
[    0.373370] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.373371] ACPI: Added _OSI(Processor Aggregator Device)
[    0.373546] ACPI: Executed 1 blocks of module-level executable AML code
[    0.377234] ACPI: [Firmware Bug]: BIOS _OSI(Linux) query ignored
[    0.377661] ACPI: Dynamic OEM Table Load:
[    0.377668] ACPI: SSDT 0xFFFF8802258E9000 00083B (v01 PmRef  Cpu0Cst  00003001 INTL 20051117)
[    0.378187] ACPI: Dynamic OEM Table Load:
[    0.378192] ACPI: SSDT 0xFFFF880225980000 000303 (v01 PmRef  ApIst    00003000 INTL 20051117)
[    0.378636] ACPI: Dynamic OEM Table Load:
[    0.378640] ACPI: SSDT 0xFFFF88022595D000 000119 (v01 PmRef  ApCst    00003000 INTL 20051117)
[    0.379535] ACPI : EC: EC started
[    1.329536] ACPI: Interpreter enabled
[    1.329556] ACPI: (supports S0 S3 S4 S5)
[    1.329558] ACPI: Using IOAPIC for interrupt routing
[    1.329582] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    1.337996] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3e])
[    1.338002] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    1.338234] acpi PNP0A08:00: _OSC: platform does not support [PCIeHotplug PME]
[    1.338381] acpi PNP0A08:00: _OSC: OS now controls [AER PCIeCapability]
[    1.338383] acpi PNP0A08:00: FADT indicates ASPM is unsupported, using BIOS configuration
[    1.338793] PCI host bridge to bus 0000:00
[    1.338796] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    1.338798] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    1.338799] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    1.338801] pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000d3fff window]
[    1.338802] pci_bus 0000:00: root bus resource [mem 0x000d4000-0x000d7fff window]
[    1.338804] pci_bus 0000:00: root bus resource [mem 0x000d8000-0x000dbfff window]
[    1.338805] pci_bus 0000:00: root bus resource [mem 0x000dc000-0x000dffff window]
[    1.338807] pci_bus 0000:00: root bus resource [mem 0x000e0000-0x000e3fff window]
[    1.338808] pci_bus 0000:00: root bus resource [mem 0x000e4000-0x000e7fff window]
[    1.338810] pci_bus 0000:00: root bus resource [mem 0xcfa00000-0xfeafffff window]
[    1.338811] pci_bus 0000:00: root bus resource [bus 00-3e]
[    1.338819] pci 0000:00:00.0: [8086:0154] type 00 class 0x060000
[    1.338913] pci 0000:00:01.0: [8086:0151] type 01 class 0x060400
[    1.338945] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    1.338992] pci 0000:00:01.0: System wakeup disabled by ACPI
[    1.339026] pci 0000:00:01.1: [8086:0155] type 01 class 0x060400
[    1.339056] pci 0000:00:01.1: PME# supported from D0 D3hot D3cold
[    1.339099] pci 0000:00:01.1: System wakeup disabled by ACPI
[    1.339137] pci 0000:00:02.0: [8086:0166] type 00 class 0x030000
[    1.339146] pci 0000:00:02.0: reg 0x10: [mem 0xf7400000-0xf77fffff 64bit]
[    1.339152] pci 0000:00:02.0: reg 0x18: [mem 0xd0000000-0xdfffffff 64bit pref]
[    1.339156] pci 0000:00:02.0: reg 0x20: [io  0xf000-0xf03f]
[    1.339291] pci 0000:00:14.0: [8086:1e31] type 00 class 0x0c0330
[    1.339311] pci 0000:00:14.0: reg 0x10: [mem 0xf7a00000-0xf7a0ffff 64bit]
[    1.339382] pci 0000:00:14.0: PME# supported from D3hot D3cold
[    1.339428] pci 0000:00:14.0: System wakeup disabled by ACPI
[    1.339467] pci 0000:00:16.0: [8086:1e3a] type 00 class 0x078000
[    1.339487] pci 0000:00:16.0: reg 0x10: [mem 0xf7a1a000-0xf7a1a00f 64bit]
[    1.339561] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
[    1.339648] pci 0000:00:1a.0: [8086:1e2d] type 00 class 0x0c0320
[    1.339665] pci 0000:00:1a.0: reg 0x10: [mem 0xf7a18000-0xf7a183ff]
[    1.339751] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    1.339809] pci 0000:00:1a.0: System wakeup disabled by ACPI
[    1.339848] pci 0000:00:1b.0: [8086:1e20] type 00 class 0x040300
[    1.339864] pci 0000:00:1b.0: reg 0x10: [mem 0xf7a10000-0xf7a13fff 64bit]
[    1.339938] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    1.339989] pci 0000:00:1b.0: System wakeup disabled by ACPI
[    1.340025] pci 0000:00:1c.0: [8086:1e10] type 01 class 0x060400
[    1.340103] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    1.340153] pci 0000:00:1c.0: System wakeup disabled by ACPI
[    1.340190] pci 0000:00:1c.2: [8086:1e14] type 01 class 0x060400
[    1.340267] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    1.340317] pci 0000:00:1c.2: System wakeup disabled by ACPI
[    1.340353] pci 0000:00:1c.3: [8086:1e16] type 01 class 0x060400
[    1.340430] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
[    1.340481] pci 0000:00:1c.3: System wakeup disabled by ACPI
[    1.340522] pci 0000:00:1d.0: [8086:1e26] type 00 class 0x0c0320
[    1.340539] pci 0000:00:1d.0: reg 0x10: [mem 0xf7a17000-0xf7a173ff]
[    1.340625] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    1.340682] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    1.340721] pci 0000:00:1f.0: [8086:1e59] type 00 class 0x060100
[    1.340896] pci 0000:00:1f.2: [8086:1e03] type 00 class 0x010601
[    1.340910] pci 0000:00:1f.2: reg 0x10: [io  0xf0b0-0xf0b7]
[    1.340918] pci 0000:00:1f.2: reg 0x14: [io  0xf0a0-0xf0a3]
[    1.340925] pci 0000:00:1f.2: reg 0x18: [io  0xf090-0xf097]
[    1.340932] pci 0000:00:1f.2: reg 0x1c: [io  0xf080-0xf083]
[    1.340940] pci 0000:00:1f.2: reg 0x20: [io  0xf060-0xf07f]
[    1.340947] pci 0000:00:1f.2: reg 0x24: [mem 0xf7a16000-0xf7a167ff]
[    1.340988] pci 0000:00:1f.2: PME# supported from D3hot
[    1.341064] pci 0000:00:1f.3: [8086:1e22] type 00 class 0x0c0500
[    1.341079] pci 0000:00:1f.3: reg 0x10: [mem 0xf7a15000-0xf7a150ff 64bit]
[    1.341100] pci 0000:00:1f.3: reg 0x20: [io  0xf040-0xf05f]
[    1.341226] pci 0000:01:00.0: [10de:0fd9] type 00 class 0x030000
[    1.341233] pci 0000:01:00.0: reg 0x10: [mem 0xf6000000-0xf6ffffff]
[    1.341240] pci 0000:01:00.0: reg 0x14: [mem 0xe0000000-0xefffffff 64bit pref]
[    1.341246] pci 0000:01:00.0: reg 0x1c: [mem 0xf0000000-0xf1ffffff 64bit pref]
[    1.341250] pci 0000:01:00.0: reg 0x24: [io  0xe000-0xe07f]
[    1.341254] pci 0000:01:00.0: reg 0x30: [mem 0xf7000000-0xf707ffff pref]
[    1.341332] pci 0000:01:00.0: System wakeup disabled by ACPI
[    1.349489] pci 0000:00:01.0: PCI bridge to [bus 01]
[    1.349496] pci 0000:00:01.0:   bridge window [io  0xe000-0xefff]
[    1.349503] pci 0000:00:01.0:   bridge window [mem 0xf6000000-0xf70fffff]
[    1.349509] pci 0000:00:01.0:   bridge window [mem 0xe0000000-0xf1ffffff 64bit pref]
[    1.349557] pci 0000:00:01.1: PCI bridge to [bus 02]
[    1.349611] pci 0000:00:1c.0: PCI bridge to [bus 03]
[    1.349696] pci 0000:04:00.0: [168c:002e] type 00 class 0x028000
[    1.349735] pci 0000:04:00.0: reg 0x10: [mem 0xf7900000-0xf790ffff 64bit]
[    1.349939] pci 0000:04:00.0: supports D1
[    1.349940] pci 0000:04:00.0: PME# supported from D0 D1 D3hot
[    1.349998] pci 0000:04:00.0: System wakeup disabled by ACPI
[    1.357505] pci 0000:00:1c.2: PCI bridge to [bus 04]
[    1.357515] pci 0000:00:1c.2:   bridge window [mem 0xf7900000-0xf79fffff]
[    1.357686] pci 0000:05:00.0: [10ec:5289] type 00 class 0xff0000
[    1.357756] pci 0000:05:00.0: reg 0x10: [mem 0xf7800000-0xf780ffff]
[    1.358304] pci 0000:05:00.0: supports D1 D2
[    1.358306] pci 0000:05:00.0: PME# supported from D1 D2 D3hot D3cold
[    1.358396] pci 0000:05:00.0: System wakeup disabled by ACPI
[    1.358491] pci 0000:05:00.2: [10ec:8168] type 00 class 0x020000
[    1.358561] pci 0000:05:00.2: reg 0x10: [io  0xd000-0xd0ff]
[    1.358672] pci 0000:05:00.2: reg 0x18: [mem 0xf2104000-0xf2104fff 64bit pref]
[    1.358740] pci 0000:05:00.2: reg 0x20: [mem 0xf2100000-0xf2103fff 64bit pref]
[    1.359066] pci 0000:05:00.2: supports D1 D2
[    1.359068] pci 0000:05:00.2: PME# supported from D0 D1 D2 D3hot D3cold
[    1.359186] pci 0000:05:00.2: System wakeup disabled by ACPI
[    1.365570] pci 0000:00:1c.3: PCI bridge to [bus 05]
[    1.365574] pci 0000:00:1c.3:   bridge window [io  0xd000-0xdfff]
[    1.365578] pci 0000:00:1c.3:   bridge window [mem 0xf7800000-0xf78fffff]
[    1.365583] pci 0000:00:1c.3:   bridge window [mem 0xf2100000-0xf21fffff 64bit pref]
[    1.366135] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 *11 12 14 15)
[    1.366185] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
[    1.366234] ACPI: PCI Interrupt Link [LNKC] (IRQs *3 4 5 6 10 11 12 14 15)
[    1.366283] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *10 11 12 14 15)
[    1.366333] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
[    1.366381] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
[    1.366428] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 *5 6 10 11 12 14 15)
[    1.366475] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 *4 5 6 10 11 12 14 15)
[    1.367085] ACPI: Enabled 5 GPEs in block 00 to 3F
[    1.367133] ACPI : EC: EC stopped
[    1.367160] ACPI : EC: GPE = 0x17, I/O: command/status = 0x66, data = 0x62
[    1.367162] ACPI : EC: EC started
[    2.318113] vgaarb: setting as boot device: PCI:0000:00:02.0
[    2.318116] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    2.318120] vgaarb: device added: PCI:0000:01:00.0,decodes=io+mem,owns=none,locks=none
[    2.318121] vgaarb: loaded
[    2.318122] vgaarb: bridge control possible 0000:01:00.0
[    2.318123] vgaarb: no bridge control possible 0000:00:02.0
[    2.318295] SCSI subsystem initialized
[    2.318346] libata version 3.00 loaded.
[    2.318351] ACPI: bus type USB registered
[    2.318368] usbcore: registered new interface driver usbfs
[    2.318378] usbcore: registered new interface driver hub
[    2.318393] usbcore: registered new device driver usb
[    2.318482] PCI: Using ACPI for IRQ routing
[    2.320015] PCI: pci_cache_line_size set to 64 bytes
[    2.320071] e820: reserve RAM buffer [mem 0x0009d800-0x0009ffff]
[    2.320073] e820: reserve RAM buffer [mem 0x40004000-0x43ffffff]
[    2.320075] e820: reserve RAM buffer [mem 0xc96cf000-0xcbffffff]
[    2.320077] e820: reserve RAM buffer [mem 0xc9e5b000-0xcbffffff]
[    2.320079] e820: reserve RAM buffer [mem 0xca5b8000-0xcbffffff]
[    2.320080] e820: reserve RAM buffer [mem 0xcad60000-0xcbffffff]
[    2.320081] e820: reserve RAM buffer [mem 0xcb000000-0xcbffffff]
[    2.320083] e820: reserve RAM buffer [mem 0x22f600000-0x22fffffff]
[    2.320171] PAX: network_header:0 off:0
[    2.320191] NetLabel: Initializing
[    2.320192] NetLabel:  domain hash size = 128
[    2.320193] NetLabel:  protocols = UNLABELED CIPSOv4
[    2.320200] PAX: network_header:0 off:0
[    2.320204] PAX: network_header:0 off:0
[    2.320208] PAX: network_header:0 off:0
[    2.320210] NetLabel:  unlabeled traffic allowed by default
[    2.320305] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[    2.320310] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    2.322329] clocksource: Switched to clocksource hpet
[    2.325757] VFS: Disk quotas dquot_6.6.0
[    2.325772] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    2.325779] PAX: network_header:0 off:0
[    2.325782] PAX: network_header:0 off:0
[    2.325837] AppArmor: AppArmor Filesystem Enabled
[    2.325876] PAX: network_header:0 off:0
[    2.325878] PAX: network_header:0 off:0
[    2.325885] pnp: PnP ACPI init
[    2.325973] system 00:00: [mem 0xfed40000-0xfed44fff] has been reserved
[    2.325977] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
[    2.326083] system 00:01: [io  0x0680-0x069f] has been reserved
[    2.326085] system 00:01: [io  0x1000-0x100f] has been reserved
[    2.326087] system 00:01: [io  0xffff] has been reserved
[    2.326089] system 00:01: [io  0xffff] has been reserved
[    2.326090] system 00:01: [io  0x0400-0x0453] has been reserved
[    2.326092] system 00:01: [io  0x0458-0x047f] has been reserved
[    2.326093] system 00:01: [io  0x0500-0x057f] has been reserved
[    2.326095] system 00:01: [io  0x164e-0x164f] has been reserved
[    2.326096] system 00:01: [io  0x3322-0x3323] has been reserved
[    2.326099] system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
[    2.326125] pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
[    2.326175] system 00:03: [io  0x0454-0x0457] has been reserved
[    2.326178] system 00:03: Plug and Play ACPI device, IDs INT3f0d PNP0c02 (active)
[    2.326204] pnp 00:04: Plug and Play ACPI device, IDs PNP0303 (active)
[    2.326272] pnp 00:05: Plug and Play ACPI device, IDs ETD0403 PNP0f13 (active)
[    2.326333] system 00:06: [io  0x04d0-0x04d1] has been reserved
[    2.326336] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
[    2.326593] system 00:07: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    2.326595] system 00:07: [mem 0xfed10000-0xfed17fff] has been reserved
[    2.326597] system 00:07: [mem 0xfed18000-0xfed18fff] has been reserved
[    2.326599] system 00:07: [mem 0xfed19000-0xfed19fff] has been reserved
[    2.326601] system 00:07: [mem 0xf8000000-0xfbffffff] has been reserved
[    2.326602] system 00:07: [mem 0xfed20000-0xfed3ffff] has been reserved
[    2.326604] system 00:07: [mem 0xfed90000-0xfed93fff] has been reserved
[    2.326605] system 00:07: [mem 0xfed45000-0xfed8ffff] has been reserved
[    2.326607] system 00:07: [mem 0xff000000-0xffffffff] has been reserved
[    2.326609] system 00:07: [mem 0xfee00000-0xfeefffff] could not be reserved
[    2.326611] system 00:07: [mem 0xcfa00000-0xcfa00fff] has been reserved
[    2.326613] system 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
[    2.326762] system 00:08: [mem 0x20000000-0x201fffff] has been reserved
[    2.326764] system 00:08: [mem 0x40004000-0x40004fff] has been reserved
[    2.326767] system 00:08: Plug and Play ACPI device, IDs PNP0c01 (active)
[    2.327145] pnp: PnP ACPI: found 9 devices
[    2.328917] PAX: network_header:0 off:0
[    2.328920] PAX: network_header:0 off:0
[    2.333405] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    2.333441] pci 0000:00:01.0: PCI bridge to [bus 01]
[    2.333443] pci 0000:00:01.0:   bridge window [io  0xe000-0xefff]
[    2.333446] pci 0000:00:01.0:   bridge window [mem 0xf6000000-0xf70fffff]
[    2.333448] pci 0000:00:01.0:   bridge window [mem 0xe0000000-0xf1ffffff 64bit pref]
[    2.333452] pci 0000:00:01.1: PCI bridge to [bus 02]
[    2.333457] pci 0000:00:1c.0: PCI bridge to [bus 03]
[    2.333468] pci 0000:00:1c.2: PCI bridge to [bus 04]
[    2.333472] pci 0000:00:1c.2:   bridge window [mem 0xf7900000-0xf79fffff]
[    2.333480] pci 0000:00:1c.3: PCI bridge to [bus 05]
[    2.333483] pci 0000:00:1c.3:   bridge window [io  0xd000-0xdfff]
[    2.333487] pci 0000:00:1c.3:   bridge window [mem 0xf7800000-0xf78fffff]
[    2.333491] pci 0000:00:1c.3:   bridge window [mem 0xf2100000-0xf21fffff 64bit pref]
[    2.333497] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    2.333499] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
[    2.333500] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
[    2.333502] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000d3fff window]
[    2.333503] pci_bus 0000:00: resource 8 [mem 0x000d4000-0x000d7fff window]
[    2.333505] pci_bus 0000:00: resource 9 [mem 0x000d8000-0x000dbfff window]
[    2.333506] pci_bus 0000:00: resource 10 [mem 0x000dc000-0x000dffff window]
[    2.333508] pci_bus 0000:00: resource 11 [mem 0x000e0000-0x000e3fff window]
[    2.333509] pci_bus 0000:00: resource 12 [mem 0x000e4000-0x000e7fff window]
[    2.333511] pci_bus 0000:00: resource 13 [mem 0xcfa00000-0xfeafffff window]
[    2.333512] pci_bus 0000:01: resource 0 [io  0xe000-0xefff]
[    2.333514] pci_bus 0000:01: resource 1 [mem 0xf6000000-0xf70fffff]
[    2.333515] pci_bus 0000:01: resource 2 [mem 0xe0000000-0xf1ffffff 64bit pref]
[    2.333517] pci_bus 0000:04: resource 1 [mem 0xf7900000-0xf79fffff]
[    2.333518] pci_bus 0000:05: resource 0 [io  0xd000-0xdfff]
[    2.333520] pci_bus 0000:05: resource 1 [mem 0xf7800000-0xf78fffff]
[    2.333521] pci_bus 0000:05: resource 2 [mem 0xf2100000-0xf21fffff 64bit pref]
[    2.333547] NET: Registered protocol family 2
[    2.333719] TCP established hash table entries: 65536 (order: 7, 524288 bytes)
[    2.333849] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    2.333966] TCP: Hash tables configured (established 65536 bind 65536)
[    2.333981] PAX: network_header:0 off:0
[    2.333992] UDP hash table entries: 4096 (order: 5, 131072 bytes)
[    2.334017] UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
[    2.334075] NET: Registered protocol family 1
[    2.334090] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    2.334582] PCI: CLS mismatch (64 != 32), using 64 bytes
[    2.334640] Trying to unpack rootfs image as initramfs...
[    2.796591] Freeing initrd memory: 29336K (ffff8800346a4000 - ffff88003634a000)
[    2.796597] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    2.796600] software IO TLB [mem 0xc56cf000-0xc96cf000] (64MB) mapped at [ffff8800c56cf000-ffff8800c96cefff]
[    2.796684] RAPL PMU: API unit is 2^-32 Joules, 3 fixed counters, 163840 ms ovfl timer
[    2.796687] RAPL PMU: hw unit of domain pp0-core 2^-16 Joules
[    2.796688] RAPL PMU: hw unit of domain package 2^-16 Joules
[    2.796689] RAPL PMU: hw unit of domain pp1-gpu 2^-16 Joules
[    2.796829] Scanning for low memory corruption every 60 seconds
[    2.797127] futex hash table entries: 1024 (order: 4, 65536 bytes)
[    2.797149] audit: initializing netlink subsys (disabled)
[    2.797164] audit: type=2000 audit(1475203205.776:1): initialized
[    2.797518] Initialise system trusted keyrings
[    2.797613] workingset: timestamp_bits=38 max_order=21 bucket_order=0
[    2.797628] zbud: loaded
[    2.797849] qnx6: QNX6 filesystem 1.0.0 registered.
[    2.797851] fuse init (API version 7.25)
[    2.797917] Key type big_key registered
[    2.798274] Key type asymmetric registered
[    2.798276] Asymmetric key parser 'x509' registered
[    2.798303] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 247)
[    2.798336] io scheduler noop registered
[    2.798338] io scheduler deadline registered (default)
[    2.798349] io scheduler cfq registered
[    2.799014] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    2.799019] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    2.799049] intel_idle: MWAIT substates: 0x21120
[    2.799051] intel_idle: v0.4.1 model 0x3A
[    2.799191] intel_idle: lapic_timer_reliable_states 0xffffffff
[    2.799252] ACPI: AC Adapter [AC] (on-line)
[    2.799313] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
[    2.799316] ACPI: Power Button [PWRB]
[    2.799351] input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/input1
[    2.799353] ACPI: Sleep Button [SLPB]
[    2.799387] input: Lid Switch as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0D:00/input/input2
[    2.799751] ACPI: Lid Switch [LID0]
[    2.799788] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input3
[    2.799790] ACPI: Power Button [PWRF]
[    2.803476] thermal LNXTHERM:00: registered as thermal_zone0
[    2.803479] ACPI: Thermal Zone [TZ0] (77 C)
[    2.803511] GHES: HEST is not enabled!
[    2.803580] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
[    2.808723] Linux agpgart interface v0.103
[    2.811540] brd: module loaded
[    2.812746] loop: module loaded
[    2.812912] cnic: QLogic cnicDriver v2.5.22 (July 20, 2015)
[    2.812950] PPP generic driver version 2.4.2
[    2.813005] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    2.813009] ehci-pci: EHCI PCI platform driver
[    2.813124] ehci-pci 0000:00:1a.0: EHCI Host Controller
[    2.813130] ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus number 1
[    2.813145] ehci-pci 0000:00:1a.0: debug port 2
[    2.813286] ACPI: Battery Slot [BAT0] (battery present)
[    2.817057] ehci-pci 0000:00:1a.0: cache line size of 64 is not supported
[    2.817076] ehci-pci 0000:00:1a.0: irq 16, io mem 0xf7a18000
[    2.826294] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[    2.826339] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    2.826341] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.826342] usb usb1: Product: EHCI Host Controller
[    2.826343] usb usb1: Manufacturer: Linux 4.7.4-grsec ehci_hcd
[    2.826345] usb usb1: SerialNumber: 0000:00:1a.0
[    2.826552] hub 1-0:1.0: USB hub found
[    2.826561] hub 1-0:1.0: 2 ports detected
[    2.826769] ehci-pci 0000:00:1d.0: EHCI Host Controller
[    2.826774] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    2.826785] ehci-pci 0000:00:1d.0: debug port 2
[    2.830668] ehci-pci 0000:00:1d.0: cache line size of 64 is not supported
[    2.830677] ehci-pci 0000:00:1d.0: irq 23, io mem 0xf7a17000
[    2.842359] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[    2.842433] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    2.842436] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.842438] usb usb2: Product: EHCI Host Controller
[    2.842439] usb usb2: Manufacturer: Linux 4.7.4-grsec ehci_hcd
[    2.842441] usb usb2: SerialNumber: 0000:00:1d.0
[    2.842709] hub 2-0:1.0: USB hub found
[    2.842725] hub 2-0:1.0: 2 ports detected
[    2.842881] ehci-platform: EHCI generic platform driver
[    2.842902] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    2.842910] ohci-pci: OHCI PCI platform driver
[    2.842925] ohci-platform: OHCI generic platform driver
[    2.842936] uhci_hcd: USB Universal Host Controller Interface driver
[    2.843096] xhci_hcd 0000:00:14.0: xHCI Host Controller
[    2.843102] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 3
[    2.844183] xhci_hcd 0000:00:14.0: hcc params 0x20007181 hci version 0x100 quirks 0x0000b930
[    2.844188] xhci_hcd 0000:00:14.0: cache line size of 64 is not supported
[    2.844287] usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
[    2.844288] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.844290] usb usb3: Product: xHCI Host Controller
[    2.844291] usb usb3: Manufacturer: Linux 4.7.4-grsec xhci-hcd
[    2.844293] usb usb3: SerialNumber: 0000:00:14.0
[    2.844484] hub 3-0:1.0: USB hub found
[    2.844496] hub 3-0:1.0: 4 ports detected
[    2.844837] xhci_hcd 0000:00:14.0: xHCI Host Controller
[    2.844842] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 4
[    2.844887] usb usb4: New USB device found, idVendor=1d6b, idProduct=0003
[    2.844889] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.844891] usb usb4: Product: xHCI Host Controller
[    2.844892] usb usb4: Manufacturer: Linux 4.7.4-grsec xhci-hcd
[    2.844893] usb usb4: SerialNumber: 0000:00:14.0
[    2.845064] hub 4-0:1.0: USB hub found
[    2.845076] hub 4-0:1.0: 4 ports detected
[    2.845461] i8042: PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:ELNM] at 0x60,0x64 irq 1,12
[    2.848975] i8042: Detected active multiplexing controller, rev 1.1
[    2.850960] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.850964] serio: i8042 AUX0 port at 0x60,0x64 irq 12
[    2.850997] serio: i8042 AUX1 port at 0x60,0x64 irq 12
[    2.851022] serio: i8042 AUX2 port at 0x60,0x64 irq 12
[    2.851048] serio: i8042 AUX3 port at 0x60,0x64 irq 12
[    2.851266] mousedev: PS/2 mouse device common for all mice
[    2.851705] rtc_cmos 00:02: RTC can wake from S4
[    2.851844] rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
[    2.851870] rtc_cmos 00:02: alarms up to one month, y3k, 0 bytes nvram, hpet irqs
[    2.851877] i2c /dev entries driver
[    2.851898] intel_pstate: Intel P-state driver initializing
[    2.852552] NET: Registered protocol family 17
[    2.852584] NET: Registered protocol family 33
[    2.852590] Key type rxrpc registered
[    2.852594] Key type rxrpc_s registered
[    2.852633] Key type dns_resolver registered
[    2.853015] microcode: CPU0 sig=0x306a9, pf=0x10, revision=0x15
[    2.853027] microcode: CPU1 sig=0x306a9, pf=0x10, revision=0x15
[    2.853039] microcode: CPU2 sig=0x306a9, pf=0x10, revision=0x15
[    2.853053] microcode: CPU3 sig=0x306a9, pf=0x10, revision=0x15
[    2.853130] microcode: Microcode Update Driver: v2.01 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    2.853365] PAX: network_header:0 off:0
[    2.853369] registered taskstats version 1
[    2.853382] Loading compiled-in X.509 certificates
[    2.853907] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input4
[    2.858417] Loaded X.509 cert 'Build time autogenerated kernel key: e22bc5dc3b06dd08a8a48ee11adc27aa47c9dbb9'
[    2.858459] zswap: loaded using pool lzo/zbud
[    2.864179] Key type trusted registered
[    2.866298] Key type encrypted registered
[    2.866302] AppArmor: AppArmor sha1 policy hashing enabled
[    2.866305] ima: No TPM chip found, activating TPM-bypass!
[    2.866329] evm: HMAC attrs: 0x1
[    2.866669]   Magic number: 0:615:663
[    2.866763] rtc_cmos 00:02: setting system clock to 2016-09-30 02:40:06 UTC (1475203206)
[    2.866805] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[    2.866806] EDD information not available.
[    2.866879] PM: Hibernation image not present or could not be loaded.
[    2.867222] Freeing unused kernel memory: 3056K (ffffffff82800000 - ffffffff82afc000)
[    2.867224] Write protecting the kernel read-only data: 20480k
[    2.875185] systemd-udevd[141]: starting version 215
[    2.875456] random: systemd-udevd: uninitialized urandom read (16 bytes read, 8 bits of entropy available)
[    2.931944] rtsx_pci 0000:05:00.0: rtsx_pci_acquire_irq: pcr->msi_en = 1, pci->irq = 27
[    2.985180] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    2.985192] r8169 0000:05:00.2: can't disable ASPM; OS doesn't have ASPM control
[    2.985933] r8169 0000:05:00.2 eth0: RTL8411 at 0xffffc90000c6e000, 00:90:f5:df:a4:ec, XID 08800800 IRQ 28
[    2.985936] r8169 0000:05:00.2 eth0: jumbo features [frames: 9200 bytes, tx checksumming: ko]
[    2.987037] ahci 0000:00:1f.2: version 3.0
[    2.987175] ahci 0000:00:1f.2: SSS flag set, parallel bus scan disabled
[    2.997263] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps 0x11 impl SATA mode
[    2.997266] ahci 0000:00:1f.2: flags: 64bit ncq stag pm led clo pio slum part ems sxs apst 
[    3.003583] scsi host0: ahci
[    3.003781] scsi host1: ahci
[    3.003936] scsi host2: ahci
[    3.004058] scsi host3: ahci
[    3.004172] scsi host4: ahci
[    3.004276] scsi host5: ahci
[    3.004335] ata1: SATA max UDMA/133 abar m2048@0xf7a16000 port 0xf7a16100 irq 29
[    3.004338] ata2: DUMMY
[    3.004340] ata3: DUMMY
[    3.004341] ata4: DUMMY
[    3.004344] ata5: SATA max UDMA/133 abar m2048@0xf7a16000 port 0xf7a16300 irq 29
[    3.004345] ata6: DUMMY
[    3.054403] usb 4-1: new SuperSpeed USB device number 2 using xhci_hcd
[    3.070970] usb 4-1: New USB device found, idVendor=2537, idProduct=1066
[    3.070974] usb 4-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    3.070975] usb 4-1: Product: HE-072(NS1066 2.45)
[    3.070976] usb 4-1: Manufacturer: SSK
[    3.070977] usb 4-1: SerialNumber: 0123456789ABD58
[    3.081117] usb-storage 4-1:1.0: USB Mass Storage device detected
[    3.081302] scsi host6: usb-storage 4-1:1.0
[    3.081374] usbcore: registered new interface driver usb-storage
[    3.086348] usbcore: registered new interface driver uas
[    3.154277] usb 2-1: new high-speed USB device number 2 using ehci-pci
[    3.182273] usb 3-2: new high-speed USB device number 2 using xhci_hcd
[    3.203996] usb 1-1: new high-speed USB device number 2 using ehci-pci
[    3.286760] usb 2-1: New USB device found, idVendor=8087, idProduct=0024
[    3.286768] usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    3.287172] hub 2-1:1.0: USB hub found
[    3.287331] hub 2-1:1.0: 6 ports detected
[    3.313472] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    3.313949] usb 3-2: New USB device found, idVendor=0951, idProduct=1653
[    3.313955] usb 3-2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    3.313960] usb 3-2: Product: DT 100 G2
[    3.313963] usb 3-2: Manufacturer: Kingston
[    3.313967] usb 3-2: SerialNumber: 001CC0EC33EEBCB127180094
[    3.314407] usb-storage 3-2:1.0: USB Mass Storage device detected
[    3.314566] scsi host7: usb-storage 3-2:1.0
[    3.315133] ata1.00: ACPI cmd ef/10:06:00:00:00:00 (SET FEATURES) succeeded
[    3.315137] ata1.00: ACPI cmd f5/00:00:00:00:00:00 (SECURITY FREEZE LOCK) filtered out
[    3.315148] ata1.00: ACPI cmd b1/c1:00:00:00:00:00 (DEVICE CONFIGURATION OVERLAY) filtered out
[    3.317073] ata1.00: ATA-8: WDC WD3200BEVT-22A23T0, 01.01A01, max UDMA/133
[    3.317079] ata1.00: 625142448 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    3.318904] ata1.00: ACPI cmd ef/10:06:00:00:00:00 (SET FEATURES) succeeded
[    3.318911] ata1.00: ACPI cmd f5/00:00:00:00:00:00 (SECURITY FREEZE LOCK) filtered out
[    3.318916] ata1.00: ACPI cmd b1/c1:00:00:00:00:00 (DEVICE CONFIGURATION OVERLAY) filtered out
[    3.320666] ata1.00: configured for UDMA/133
[    3.320945] scsi 0:0:0:0: Direct-Access     ATA      WDC WD3200BEVT-2 1A01 PQ: 0 ANSI: 5
[    3.335077] usb 1-1: New USB device found, idVendor=8087, idProduct=0024
[    3.335080] usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    3.335436] hub 1-1:1.0: USB hub found
[    3.335587] hub 1-1:1.0: 6 ports detected
[    3.350625] sd 0:0:0:0: [sda] 625142448 512-byte logical blocks: (320 GB/298 GiB)
[    3.350630] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    3.350827] sd 0:0:0:0: [sda] Write Protect is off
[    3.350834] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    3.350915] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    3.610257] usb 1-1.2: new high-speed USB device number 3 using ehci-pci
[    3.658440] ata5: SATA link down (SStatus 0 SControl 300)
[    3.703691] usb 1-1.2: New USB device found, idVendor=05e3, idProduct=0608
[    3.703694] usb 1-1.2: New USB device strings: Mfr=0, Product=1, SerialNumber=0
[    3.703696] usb 1-1.2: Product: USB2.0 Hub
[    3.768111] hub 1-1.2:1.0: USB hub found
[    3.768433] hub 1-1.2:1.0: 4 ports detected
[    3.794234] tsc: Refined TSC clocksource calibration: 2494.333 MHz
[    3.794238] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x23f45085418, max_idle_ns: 440795285711 ns
[    3.805435] psmouse serio2: elantech: assuming hardware version 3 (with firmware version 0x250f01)
[    3.904095] psmouse serio2: elantech: Synaptics capabilities query result 0x18, 0x17, 0x0b.
[    4.002736] psmouse serio2: elantech: Elan sample query result 05, 0e, 00
[    4.042205] usb 1-1.2.4: new low-speed USB device number 4 using ehci-pci
[    4.139870] usb 1-1.2.4: New USB device found, idVendor=04fc, idProduct=05da
[    4.139874] usb 1-1.2.4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    4.139876] usb 1-1.2.4: Product: Defender 2.4GHz Nano mouse
[    4.139878] usb 1-1.2.4: Manufacturer: MLK
[    4.224521] hidraw: raw HID events driver (C) Jiri Kosina
[    4.240009] usbcore: registered new interface driver usbhid
[    4.240011] usbhid: USB HID core driver
[    4.313804] usbcore: registered new interface driver usbmouse
[    4.315129] input: MLK Defender 2.4GHz Nano mouse as /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.2/1-1.2.4/1-1.2.4:1.0/0003:04FC:05DA.0001/input/input11
[    4.316992] scsi 7:0:0:0: Direct-Access     Kingston DT 100 G2        PMAP PQ: 0 ANSI: 4
[    4.327292] input: ETPS/2 Elantech Touchpad as /devices/platform/i8042/serio2/input/input10
[    4.370777] hid-generic 0003:04FC:05DA.0001: input,hiddev0,hidraw0: USB HID v1.10 Mouse [MLK Defender 2.4GHz Nano mouse] on usb-0000:00:1a.0-1.2.4/input0
[    4.794352] clocksource: Switched to clocksource tsc
[    5.046032] sd 0:0:0:0: [sda] Attached SCSI disk
[    5.624119] scsi 6:0:0:0: Direct-Access     ATA      TOSHIBA MK3263GS 2M   PQ: 0 ANSI: 6
[    5.624614] sd 6:0:0:0: Attached scsi generic sg1 type 0
[    5.624865] sd 7:0:0:0: Attached scsi generic sg2 type 0
[    5.625326] sd 6:0:0:0: [sdb] 625142448 512-byte logical blocks: (320 GB/298 GiB)
[    5.625483] sd 7:0:0:0: [sdc] 31125120 512-byte logical blocks: (15.9 GB/14.8 GiB)
[    5.625636] sd 7:0:0:0: [sdc] Write Protect is off
[    5.625640] sd 7:0:0:0: [sdc] Mode Sense: 23 00 00 00
[    5.625741] sd 6:0:0:0: [sdb] Write Protect is off
[    5.625744] sd 6:0:0:0: [sdb] Mode Sense: 43 00 00 00
[    5.625773] sd 7:0:0:0: [sdc] No Caching mode page found
[    5.625797] sd 7:0:0:0: [sdc] Assuming drive cache: write through
[    5.625938] sd 6:0:0:0: [sdb] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    5.628193]  sdc: sdc1
[    5.629271] sd 7:0:0:0: [sdc] Attached SCSI removable disk
[    7.854226]  sdb: sdb1 sdb2
[    7.855358] sd 6:0:0:0: [sdb] Attached SCSI disk
[    8.285943] device-mapper: ioctl: 4.34.0-ioctl (2015-10-28) initialised: dm-devel@redhat.com
[    8.287932] random: lvm: uninitialized urandom read (4 bytes read, 107 bits of entropy available)
[   13.368460] random: nonblocking pool is initialized
[   13.369105] EXT4-fs (sdb2): INFO: recovery required on readonly filesystem
[   13.369108] EXT4-fs (sdb2): write access will be enabled during recovery
[   13.684765] EXT4-fs (sdb2): recovery complete
[   13.685292] EXT4-fs (sdb2): mounted filesystem with ordered data mode. Opts: (null)
[   14.145795] grsec: time set by /lib/systemd/systemd[systemd:1] uid/euid:0/0 gid/egid:0/0, parent /[swapper/0:0] uid/euid:0/0 gid/egid:0/0
[   14.433776] systemd[1]: Failed to insert module 'ipv6'
[   14.443608] PAX: network_header:0 off:0
[   14.443661] PAX: network_header:0 off:0
[   14.443667] PAX: network_header:0 off:0
[   14.443672] PAX: network_header:0 off:0
[   15.982269] systemd[1]: Configuration file /etc/systemd/system/temptroll.service is marked executable. Please remove executable permission bits. Proceeding anyway.
[   16.022247] systemd[1]: Configuration file /etc/systemd/system/ramclean.service is marked executable. Please remove executable permission bits. Proceeding anyway.
[   16.992326] systemd-udevd[297]: starting version 215
[   17.081769] EXT4-fs (sdb2): re-mounted. Opts: (null)
[   17.731347] ACPI Warning: SystemIO range 0x0000000000000428-0x000000000000042F conflicts with OpRegion 0x0000000000000400-0x000000000000047F (\PMIO) (20160422/utaddress-255)
[   17.731356] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[   17.731360] ACPI Warning: SystemIO range 0x0000000000000540-0x000000000000054F conflicts with OpRegion 0x0000000000000500-0x0000000000000563 (\GPIO) (20160422/utaddress-255)
[   17.731364] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[   17.731365] ACPI Warning: SystemIO range 0x0000000000000530-0x000000000000053F conflicts with OpRegion 0x0000000000000500-0x0000000000000563 (\GPIO) (20160422/utaddress-255)
[   17.731369] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[   17.731370] ACPI Warning: SystemIO range 0x0000000000000500-0x000000000000052F conflicts with OpRegion 0x0000000000000500-0x0000000000000563 (\GPIO) (20160422/utaddress-255)
[   17.731374] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[   17.731375] lpc_ich: Resource conflict(s) found affecting gpio_ich
[   17.793601] i801_smbus 0000:00:1f.3: SMBus using PCI interrupt
[   17.830844] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[   17.866706] wmi: Mapper loaded
[   18.481737] iTCO_vendor_support: vendor-support=0
[   18.562537] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
[   18.562575] iTCO_wdt: Found a Panther Point TCO device (Version=2, TCOBASE=0x0460)
[   18.562675] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
[   18.757049] nvidiafb 0000:01:00.0: enabling device (0000 -> 0003)
[   18.757331] nvidiafb: Device ID: 10de0fd9 
[   18.757333] nvidiafb: unknown NV_ARCH
[   18.840487] snd_hda_codec_via hdaudioC0D0: autoconfig for VT1802: line_outs=1 (0x24/0x0/0x0/0x0/0x0) type:speaker
[   18.840491] snd_hda_codec_via hdaudioC0D0:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
[   18.840493] snd_hda_codec_via hdaudioC0D0:    hp_outs=1 (0x25/0x0/0x0/0x0/0x0)
[   18.840494] snd_hda_codec_via hdaudioC0D0:    mono: mono_out=0x0
[   18.840495] snd_hda_codec_via hdaudioC0D0:    inputs:
[   18.840497] snd_hda_codec_via hdaudioC0D0:      Mic=0x2b
[   18.840498] snd_hda_codec_via hdaudioC0D0:      Internal Mic=0x29
[   18.863392] AVX version of gcm_enc/dec engaged.
[   18.863395] AES CTR mode by8 optimization enabled
[   19.073973] [drm] Initialized drm 1.1.0 20060810
[   19.137718] PAX: network_header:0 off:0
[   19.137724] PAX: network_header:0 off:0
[   19.137727] PAX: network_header:0 off:0
[   19.137730] PAX: network_header:0 off:0
[   19.137733] PAX: network_header:0 off:0
[   19.137736] PAX: network_header:0 off:0
[   20.065247] [drm] Memory usable by graphics device = 2048M
[   20.065251] [drm] Replacing VGA console driver
[   20.065728] Console: switching to colour dummy device 80x25
[   20.070866] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[   20.070872] [drm] Driver supports precise vblank timestamp query.
[   20.073460] vgaarb: device changed decodes: PCI:0000:00:02.0,olddecodes=io+mem,decodes=none:owns=io+mem
[   20.265483] ACPI Exception: AE_NOT_FOUND, Evaluating _DOD (20160422/video-1251)
[   20.265488] ACPI: Video Device [PEGP] (multi-head: no  rom: yes  post: no)
[   20.265609] input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/device:08/LNXVIDEO:00/input/input17
[   20.266064] ACPI: Video Device [GFX0] (multi-head: yes  rom: no  post: no)
[   20.266162] input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/LNXVIDEO:01/input/input18
[   20.345019] intel_rapl: Found RAPL domain package
[   20.345025] intel_rapl: Found RAPL domain core
[   20.345028] intel_rapl: Found RAPL domain uncore
[   20.345034] intel_rapl: RAPL package 0 domain package locked by BIOS
[   20.393524] snd_hda_intel 0000:00:1b.0: bound 0000:00:02.0 (ops ffffffffc09276b0)
[   20.393532] [drm] Initialized i915 1.6.0 20160425 for 0000:00:02.0 on minor 0
[   20.394265] fbcon: inteldrmfb (fb0) is primary device
[   20.405595] ath: phy0: ASPM enabled: 0x43
[   20.405596] ath: EEPROM regdomain: 0x65
[   20.405597] ath: EEPROM indicates we should expect a direct regpair map
[   20.405598] ath: Country alpha2 being used: 00
[   20.405598] ath: Regpair used: 0x65
[   20.406689] PAX: network_header:0 off:0
[   20.422555] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[   20.422985] ieee80211 phy0: Atheros AR9287 Rev:2 mem=0xffffc900013c0000, irq=18
[   21.250019] Console: switching to colour frame buffer device 200x56
[   21.252971] i915 0000:00:02.0: fb0: inteldrmfb frame buffer device
[   21.267689] input: HDA Intel PCH Mic as /devices/pci0000:00/0000:00:1b.0/sound/card0/input15
[   21.267795] input: HDA Intel PCH Front Headphone as /devices/pci0000:00/0000:00:1b.0/sound/card0/input16
[   21.267880] input: HDA Intel PCH HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:1b.0/sound/card0/input19
[   22.065583] systemd-journald[273]: Received request to flush runtime journal from PID 1
[   22.591209] audit: type=1400 audit(1475203226.219:2): apparmor="STATUS" operation="profile_load" name="docker-default" pid=472 comm="apparmor_parser"
[   22.600008] audit: type=1400 audit(1475203226.227:3): apparmor="STATUS" operation="profile_load" name="system_tor" pid=472 comm="apparmor_parser"
[   22.601590] audit: type=1400 audit(1475203226.231:4): apparmor="STATUS" operation="profile_load" name="/usr/bin/obfsproxy" pid=472 comm="apparmor_parser"
[   22.602580] audit: type=1400 audit(1475203226.231:5): apparmor="STATUS" operation="profile_load" name="/usr/lib/libvirt/virt-aa-helper" pid=472 comm="apparmor_parser"
[   22.603695] audit: type=1400 audit(1475203226.231:6): apparmor="STATUS" operation="profile_load" name="/usr/sbin/libvirtd" pid=472 comm="apparmor_parser"
[   29.806908] r8169 0000:05:00.2 eth0: link down
[   29.807711] PAX: network_header:0 off:0
[   29.826904] PAX: network_header:0 off:0
[   30.963052] PAX: network_header:0 off:0
[   31.000155] PAX: network_header:0 off:0
[   31.000187] PAX: network_header:0 off:0
[   31.000215] PAX: network_header:0 off:0
[   31.000324] PAX: network_header:0 off:0
[   31.000335] PAX: network_header:0 off:0
[   31.000409] PAX: network_header:0 off:0
[   31.000500] PAX: network_header:0 off:0
[   31.000549] PAX: network_header:0 off:0
[   31.000619] PAX: network_header:0 off:0
[   31.384200] PAX: network_header:0 off:0
[   32.223727] PAX: network_header:0 off:0
[   32.223743] PAX: network_header:0 off:0
[   33.423690] PAX: network_header:0 off:0
[   34.502022] grsec: denied resource overstep by requesting 148439040 for RLIMIT_MEMLOCK against limit 65536 for /usr/sbin/lightdm-gtk-greeter[lightdm-gtk-gre:651] uid/euid:105/105 gid/egid:111/111, parent /usr/sbin/lightdm[lightdm:645] uid/euid:0/0 gid/egid:0/0
[   35.327892] bridge: automatic filtering via arp/ip/ip6tables has been deprecated. Update your scripts to load br_netfilter if you need this.
[   35.348024] Bridge firewalling registered
[   35.399805] nf_conntrack version 0.5.0 (65536 buckets, 262144 max)
[   35.542242] ip_tables: (C) 2000-2006 Netfilter Core Team
[   35.844215] Initializing XFRM netlink socket
[   35.947179] PAX: network_header:0 off:0
[   35.947199] PAX: network_header:0 off:0
[   35.947214] PAX: network_header:0 off:0
[   35.947233] PAX: network_header:0 off:0
[   55.034709] PAX: network_header:0 off:0
[   55.873765] PAX: network_header:0 off:0
[   55.873811] PAX: network_header:0 off:0
[   88.051139] PAX: network_header:0 off:0
[   88.890704] PAX: network_header:0 off:0
[   88.890720] PAX: network_header:0 off:0
[  131.024426] PAX: network_header:0 off:0
[  131.862987] PAX: network_header:0 off:0
[  131.863000] PAX: network_header:0 off:0
[  134.077390] grsec: denied resource overstep by requesting 148439040 for RLIMIT_MEMLOCK against limit 65536 for /usr/sbin/lightdm-gtk-greeter[lightdm-gtk-gre:880] uid/euid:105/105 gid/egid:111/111, parent /usr/sbin/lightdm[lightdm:877] uid/euid:0/0 gid/egid:0/0
[  184.014889] PAX: network_header:0 off:0
[  184.854393] PAX: network_header:0 off:0
[  184.854412] PAX: network_header:0 off:0
[  276.512954] r8169 0000:05:00.2 eth0: link down
[  276.513780] PAX: network_header:0 off:0
[  276.536065] PAX: network_header:0 off:0
[  276.536625] PAX: network_header:0 off:0
[  276.536642] PAX: network_header:0 off:0
[  276.536711] PAX: network_header:0 off:0
[  276.536810] PAX: network_header:0 off:0
[  276.536847] PAX: network_header:0 off:0
[  276.536921] PAX: network_header:0 off:0
[  276.599039] PAX: network_header:0 off:0
[  277.438113] PAX: network_header:0 off:0
[  277.438131] PAX: network_header:0 off:0
[  300.017259] PAX: network_header:0 off:0
[  300.855982] PAX: network_header:0 off:0
[  300.856013] PAX: network_header:0 off:0
[  306.967992] PAX: network_header:0 off:0
[  307.811351] PAX: network_header:0 off:0
[  307.811397] PAX: network_header:0 off:0
[  307.812022] wlan0: authenticate with cc:b2:66:a2:6f:d7
[  307.836416] PAX: network_header:0 off:0
[  307.836423] wlan0: send auth to cc:b2:66:a2:6f:d7 (try 1/3)
[  307.838163] wlan0: authenticated
[  307.838170] PAX: network_header:0 off:0
[  307.839324] wlan0: associate with cc:b2:66:a2:6f:d7 (try 1/3)
[  307.839340] PAX: network_header:4 off:a
[  307.843062] wlan0: RX AssocResp from cc:b2:66:a2:6f:d7 (capab=0x401 status=0 aid=4)
[  307.843170] wlan0: associated
[  307.843195] PAX: network_header:0 off:0
[  307.843199] PAX: network_header:0 off:0
[  307.843222] PAX: network_header:0 off:0
[  307.843225] PAX: network_header:0 off:0
[  307.843964] PAX: network_header:0 off:ffffffc4
[  307.843968] PAX: size overflow detected in function skb_headers_offset_update net/core/skbuff.c:1052 cicus.735_41 min, count: 22, decl: network_header; num: 0; context: sk_buff;
[  307.843972] CPU: 3 PID: 0 Comm: swapper/3 Not tainted 4.7.4-grsec #2
[  307.843974] Hardware name: Notebook                         W250EGQ / W270EGQ                /W250EGQ / W270EGQ                 , BIOS 4.6.5 10/19/2012
[  307.843976]  0000000000000246 e94b0b0a1b171f26 ffff88022f383ad0 ffffffff814c2f9b
[  307.843980]  000000000000041c e94b0b0a1b171f26 ffffffff81e40660 000000000000041c
[  307.843983]  ffff88022f383b00 ffffffff8126c8b3 ffff8800c33bad00 00000000ffffffc4
[  307.843986] Call Trace:
[  307.843988]  <IRQ>  [<ffffffff814c2f9b>] dump_stack+0x60/0xb5
[  307.843998]  [<ffffffff8126c8b3>] report_size_overflow+0x73/0x90
[  307.844002]  [<ffffffff8187ea26>] skb_headers_offset_update+0x156/0x1e0
[  307.844005]  [<ffffffff81881255>] skb_copy_expand+0x115/0x1e0
[  307.844035]  [<ffffffffc052b63f>] ieee80211_rx_handlers+0x15ef/0x2600 [mac80211]
[  307.844040]  [<ffffffff814e1965>] ? find_next_bit+0x15/0x40
[  307.844043]  [<ffffffff814c2d5f>] ? cpumask_next_and+0x2f/0x60
[  307.844065]  [<ffffffffc052cf02>] ieee80211_prepare_and_rx_handle+0x632/0x1600 [mac80211]
[  307.844068]  [<ffffffff8188afa8>] ? __build_skb+0x48/0x240
[  307.844088]  [<ffffffffc052e51a>] ieee80211_rx_napi+0x64a/0xca0 [mac80211]
[  307.844092]  [<ffffffff8150008a>] ? swiotlb_tbl_map_single+0x2aa/0x2d0
[  307.844099]  [<ffffffffc064cb1c>] ath_rx_tasklet+0xb2c/0xe80 [ath9k]
[  307.844102]  [<ffffffff815006e0>] ? swiotlb_tbl_unmap_single+0x130/0x130
[  307.844107]  [<ffffffffc0649a9e>] ath9k_tasklet+0xee/0x2b0 [ath9k]
[  307.844112]  [<ffffffff8108564a>] tasklet_action+0x20a/0x230
[  307.844116]  [<ffffffff819bdb1e>] __do_softirq+0x11e/0x2d4
[  307.844119]  [<ffffffff81085c33>] irq_exit+0x93/0xb0
[  307.844122]  [<ffffffff819bd774>] do_IRQ+0x54/0x110
[  307.844126]  [<ffffffff819bbc4b>] common_interrupt+0x8b/0x8b
[  307.844128]  <EOI>  [<ffffffff8181b049>] ? cpuidle_enter_state+0x129/0x2b0
[  307.844135]  [<ffffffff8181b237>] cpuidle_enter+0x17/0x30
[  307.844139]  [<ffffffff810cd8d3>] call_cpuidle+0x23/0x50
[  307.844142]  [<ffffffff810cdd87>] cpu_startup_entry+0x2a7/0x350
[  307.844145]  [<ffffffff81046acf>] start_secondary+0x24f/0x2f0
[  307.844150] PAX: network_header:4 off:12
[  317.567068] PAX: network_header:0 off:0
[  317.567077] PAX: network_header:0 off:0
[  317.567082] PAX: network_header:0 off:0
[  317.567087] PAX: network_header:0 off:0
[  317.569539] PAX: network_header:0 off:0
[  317.569626] PAX: network_header:0 off:0
[  317.569672] PAX: network_header:0 off:0
[  317.569808] PAX: network_header:0 off:0
[  318.992651] PAX: network_header:0 off:0
[  318.992754] PAX: network_header:0 off:0
[  318.992843] PAX: network_header:0 off:0
[  324.991224] PAX: network_header:0 off:0
[  324.991330] PAX: network_header:0 off:0
[  324.991408] PAX: network_header:0 off:0
[  325.095277] PAX: network_header:0 off:0
[  325.095351] PAX: network_header:0 off:0
[  325.095357] PAX: network_header:0 off:0
[  325.095362] PAX: network_header:0 off:0
[  325.095367] PAX: network_header:0 off:0
[  325.096955] wlan0: deauthenticating from cc:b2:66:a2:6f:d7 by local choice (Reason: 3=DEAUTH_LEAVING)
[  325.097948] PAX: network_header:0 off:0
[  325.106552] PAX: network_header:0 off:0
[  325.106556] PAX: network_header:0 off:0
[  325.106580] PAX: network_header:0 off:0
[  325.133345] PAX: network_header:0 off:0
[  325.973730] PAX: network_header:0 off:0
[  325.973745] PAX: network_header:0 off:0
[  328.004153] PAX: network_header:0 off:0
[  328.841541] PAX: network_header:0 off:0
[  328.841555] PAX: network_header:0 off:0

--jI8keyz6grp/JLjh--
