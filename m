From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: REGRESSION: On 2.6.32-rc5 the firmware hangs, and the nic is unusable.
Date: Wed, 04 Nov 2009 14:42:53 -0800
Message-ID: <m1hbt9x66q.fsf@fess.ebiederm.org>
References: <m1tyxaagal.fsf@fess.ebiederm.org> <4AF1D2C6.20002@qlogic.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Amit Salecha <amit.salecha@qlogic.com>
To: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:34172 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932951AbZKDWnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 17:43:01 -0500
In-Reply-To: <4AF1D2C6.20002@qlogic.com> (Dhananjay Phadke's message of "Wed\, 4 Nov 2009 11\:15\:18 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=


Ok here is my snippet from /var/log/messages from my failed run of 2.6.32-rc5.
It is syslog not dmesg but it doesn't look like anything was missed.


--=-=-=
Content-Disposition: inline;
 filename=messages-2.6.32-rc5-failed-netxen-boot.txt

Nov  3 22:17:24 localhost kernel: imklog 3.22.1, log source = /proc/kmsg started.
Nov  3 22:17:24 localhost rsyslogd: [origin software="rsyslogd" swVersion="3.22.1" x-pid="2977" x-info="http://www.rsyslog.com"] (re)start
Nov  3 22:17:24 localhost kernel: Initializing cgroup subsys cpuset
Nov  3 22:17:24 localhost kernel: Linux version 2.6.32-rc5-198042.2009AroraKernelBeta.fc11.x86_64 (arastra@local4-52.aristanetworks.com) (gcc version 4.4.1 20090725 (Red Hat 4.4.1-2) (GCC) ) #1 SMP Tue Nov 3 07:32:17 EST 2009
Nov  3 22:17:24 localhost kernel: Command line: ro root=LABEL=/ rhgb quiet 8250.nr_uarts=16 crashkernel=128M console=tty0 console=ttyS0,9600 8250.nr_uarts=16
Nov  3 22:17:24 localhost kernel: KERNEL supported cpus:
Nov  3 22:17:24 localhost kernel:  Intel GenuineIntel
Nov  3 22:17:24 localhost kernel:  AMD AuthenticAMD
Nov  3 22:17:24 localhost kernel:  Centaur CentaurHauls
Nov  3 22:17:24 localhost kernel: BIOS-provided physical RAM map:
Nov  3 22:17:24 localhost kernel: BIOS-e820: 0000000000000000 - 000000000009dc00 (usable)
Nov  3 22:17:24 localhost kernel: BIOS-e820: 000000000009dc00 - 00000000000a0000 (reserved)
Nov  3 22:17:24 localhost kernel: BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
Nov  3 22:17:24 localhost kernel: BIOS-e820: 0000000000100000 - 00000000cfef0000 (usable)
Nov  3 22:17:24 localhost kernel: BIOS-e820: 00000000cfef0000 - 00000000cff04000 (ACPI data)
Nov  3 22:17:24 localhost kernel: BIOS-e820: 00000000cff04000 - 00000000cff05000 (ACPI NVS)
Nov  3 22:17:24 localhost kernel: BIOS-e820: 00000000cff05000 - 00000000d0000000 (reserved)
Nov  3 22:17:24 localhost kernel: BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
Nov  3 22:17:24 localhost kernel: BIOS-e820: 00000000fec00000 - 00000000fec10000 (reserved)
Nov  3 22:17:24 localhost kernel: BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
Nov  3 22:17:24 localhost kernel: BIOS-e820: 00000000ff000000 - 0000000100000000 (reserved)
Nov  3 22:17:24 localhost kernel: BIOS-e820: 0000000100000000 - 0000000130000000 (usable)
Nov  3 22:17:24 localhost kernel: DMI present.
Nov  3 22:17:24 localhost kernel: Phoenix BIOS detected: BIOS may corrupt low RAM, working around it.
Nov  3 22:17:24 localhost kernel: last_pfn = 0x130000 max_arch_pfn = 0x400000000
Nov  3 22:17:24 localhost kernel: x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
Nov  3 22:17:24 localhost kernel: last_pfn = 0xcfef0 max_arch_pfn = 0x400000000
Nov  3 22:17:24 localhost kernel: init_memory_mapping: 0000000000000000-00000000cfef0000
Nov  3 22:17:24 localhost kernel: init_memory_mapping: 0000000100000000-0000000130000000
Nov  3 22:17:24 localhost kernel: RAMDISK: 37cfd000 - 37fefdd8
Nov  3 22:17:24 localhost kernel: ACPI: RSDP 00000000000f6880 00024 (v02 PTLTD )
Nov  3 22:17:24 localhost kernel: ACPI: XSDT 00000000cfefcef6 000D4 (v01 PTLTD  ? XSDT   06040000  LTP 00000000)
Nov  3 22:17:24 localhost kernel: ACPI: FACP 00000000cff033a8 000F4 (v03 INTEL  STOAKLEY 06040000 PTL  00000003)
Nov  3 22:17:24 localhost kernel: ACPI: DSDT 00000000cfefeab8 0487C (v01  Intel SEABURG  06040000 MSFT 03000001)
Nov  3 22:17:24 localhost kernel: ACPI: FACS 00000000cff04fc0 00040
Nov  3 22:17:24 localhost kernel: ACPI: _MAR 00000000cff0349c 00030 (v01 Intel  OEMDMAR  06040000 LOHR 00000001)
Nov  3 22:17:24 localhost kernel: ACPI: TCPA 00000000cff034cc 00032 (v01 Intel  STOAKLEY 06040000 LOHR 0000005A)
Nov  3 22:17:24 localhost kernel: ACPI: APIC 00000000cff034fe 000C8 (v01 PTLTD  ? APIC   06040000  LTP 00000000)
Nov  3 22:17:24 localhost kernel: ACPI: MCFG 00000000cff035c6 0003C (v01 PTLTD    MCFG   06040000  LTP 00000000)
Nov  3 22:17:24 localhost kernel: ACPI: HPET 00000000cff03602 00038 (v01 PTLTD  HPETTBL  06040000  LTP 00000001)
Nov  3 22:17:24 localhost kernel: ACPI: BOOT 00000000cff0363a 00028 (v01 PTLTD  $SBFTBL$ 06040000  LTP 00000001)
Nov  3 22:17:24 localhost kernel: ACPI: SPCR 00000000cff03662 00050 (v01 PTLTD  $UCRTBL$ 06040000 PTL  00000001)
Nov  3 22:17:24 localhost kernel: ACPI: ERST 00000000cff036b2 00590 (v01 SMCI   ERSTTBL  06040000 SMCI 00000001)
Nov  3 22:17:24 localhost kernel: ACPI: HEST 00000000cff03c42 000A8 (v01 SMCI   HESTTBL  06040000 SMCI 00000001)
Nov  3 22:17:24 localhost kernel: ACPI: BERT 00000000cff03cea 00030 (v01 SMCI   BERTTBL  06040000 SMCI 00000001)
Nov  3 22:17:24 localhost kernel: ACPI: EINJ 00000000cff03d1a 00170 (v01 SMCI   EINJTBL  06040000 SMCI 00000001)
Nov  3 22:17:24 localhost kernel: ACPI: SLIC 00000000cff03e8a 00176 (v01 OEM_ID OEMTABLE 06040000  LTP 00000000)
Nov  3 22:17:24 localhost kernel: ACPI: SSDT 00000000cfefe859 0025F (v01  PmRef  Cpu0Tst 00003000 INTL 20050228)
Nov  3 22:17:24 localhost kernel: ACPI: SSDT 00000000cfefe7b3 000A6 (v01  PmRef  Cpu7Tst 00003000 INTL 20050228)
Nov  3 22:17:24 localhost kernel: ACPI: SSDT 00000000cfefe70d 000A6 (v01  PmRef  Cpu6Tst 00003000 INTL 20050228)
Nov  3 22:17:24 localhost kernel: ACPI: SSDT 00000000cfefe667 000A6 (v01  PmRef  Cpu5Tst 00003000 INTL 20050228)
Nov  3 22:17:24 localhost kernel: ACPI: SSDT 00000000cfefe5c1 000A6 (v01  PmRef  Cpu4Tst 00003000 INTL 20050228)
Nov  3 22:17:24 localhost kernel: ACPI: SSDT 00000000cfefe51b 000A6 (v01  PmRef  Cpu3Tst 00003000 INTL 20050228)
Nov  3 22:17:24 localhost kernel: ACPI: SSDT 00000000cfefe475 000A6 (v01  PmRef  Cpu2Tst 00003000 INTL 20050228)
Nov  3 22:17:24 localhost kernel: ACPI: SSDT 00000000cfefe3cf 000A6 (v01  PmRef  Cpu1Tst 00003000 INTL 20050228)
Nov  3 22:17:24 localhost kernel: ACPI: SSDT 00000000cfefcfca 01405 (v01  PmRef    CpuPm 00003000 INTL 20050228)
Nov  3 22:17:24 localhost kernel: No NUMA configuration found
Nov  3 22:17:24 localhost kernel: Faking a node at 0000000000000000-0000000130000000
Nov  3 22:17:24 localhost kernel: Bootmem setup node 0 0000000000000000-0000000130000000
Nov  3 22:17:24 localhost kernel:  NODE_DATA [0000000000015000 - 0000000000029fff]
Nov  3 22:17:24 localhost kernel:  bootmap [000000000002a000 -  000000000004ffff] pages 26
Nov  3 22:17:24 localhost kernel: (8 early reservations) ==> bootmem [0000000000 - 0130000000]
Nov  3 22:17:24 localhost kernel:  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
Nov  3 22:17:24 localhost kernel:  #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
Nov  3 22:17:24 localhost kernel:  #2 [0001000000 - 00017f08d4]    TEXT DATA BSS ==> [0001000000 - 00017f08d4]
Nov  3 22:17:24 localhost kernel:  #3 [0037cfd000 - 0037fefdd8]          RAMDISK ==> [0037cfd000 - 0037fefdd8]
Nov  3 22:17:24 localhost kernel:  #4 [000009dc00 - 0000100000]    BIOS reserved ==> [000009dc00 - 0000100000]
Nov  3 22:17:24 localhost kernel:  #5 [00017f1000 - 00017f11ac]              BRK ==> [00017f1000 - 00017f11ac]
Nov  3 22:17:24 localhost kernel:  #6 [0000010000 - 0000014000]          PGTABLE ==> [0000010000 - 0000014000]
Nov  3 22:17:24 localhost kernel:  #7 [0000014000 - 0000015000]          PGTABLE ==> [0000014000 - 0000015000]
Nov  3 22:17:24 localhost kernel: found SMP MP-table at [ffff8800000f68b0] f68b0
Nov  3 22:17:24 localhost kernel: Reserving 128MB of memory at 32MB for crashkernel (System RAM: 4864MB)
Nov  3 22:17:24 localhost kernel: Zone PFN ranges:
Nov  3 22:17:24 localhost kernel:  DMA      0x00000010 -> 0x00001000
Nov  3 22:17:24 localhost kernel:  DMA32    0x00001000 -> 0x00100000
Nov  3 22:17:24 localhost kernel:  Normal   0x00100000 -> 0x00130000
Nov  3 22:17:24 localhost kernel: Movable zone start PFN for each node
Nov  3 22:17:24 localhost kernel: early_node_map[3] active PFN ranges
Nov  3 22:17:24 localhost kernel:    0: 0x00000010 -> 0x0000009d
Nov  3 22:17:24 localhost kernel:    0: 0x00000100 -> 0x000cfef0
Nov  3 22:17:24 localhost kernel:    0: 0x00100000 -> 0x00130000
Nov  3 22:17:24 localhost kernel: ACPI: PM-Timer IO Port: 0x1008
Nov  3 22:17:24 localhost kernel: ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
Nov  3 22:17:24 localhost kernel: ACPI: LAPIC (acpi_id[0x01] lapic_id[0x04] enabled)
Nov  3 22:17:24 localhost kernel: ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
Nov  3 22:17:24 localhost kernel: ACPI: LAPIC (acpi_id[0x03] lapic_id[0x05] enabled)
Nov  3 22:17:24 localhost kernel: ACPI: LAPIC (acpi_id[0x04] lapic_id[0x02] enabled)
Nov  3 22:17:24 localhost kernel: ACPI: LAPIC (acpi_id[0x05] lapic_id[0x06] enabled)
Nov  3 22:17:24 localhost kernel: ACPI: LAPIC (acpi_id[0x06] lapic_id[0x03] enabled)
Nov  3 22:17:24 localhost kernel: ACPI: LAPIC (acpi_id[0x07] lapic_id[0x07] enabled)
Nov  3 22:17:24 localhost kernel: ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
Nov  3 22:17:24 localhost kernel: ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
Nov  3 22:17:24 localhost kernel: ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
Nov  3 22:17:24 localhost kernel: ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
Nov  3 22:17:24 localhost kernel: ACPI: LAPIC_NMI (acpi_id[0x04] high edge lint[0x1])
Nov  3 22:17:24 localhost kernel: ACPI: LAPIC_NMI (acpi_id[0x05] high edge lint[0x1])
Nov  3 22:17:24 localhost kernel: ACPI: LAPIC_NMI (acpi_id[0x06] high edge lint[0x1])
Nov  3 22:17:24 localhost kernel: ACPI: LAPIC_NMI (acpi_id[0x07] high edge lint[0x1])
Nov  3 22:17:24 localhost kernel: ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
Nov  3 22:17:24 localhost kernel: IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
Nov  3 22:17:24 localhost kernel: ACPI: IOAPIC (id[0x09] address[0xfec89000] gsi_base[24])
Nov  3 22:17:24 localhost kernel: IOAPIC[1]: apic_id 9, version 32, address 0xfec89000, GSI 24-47
Nov  3 22:17:24 localhost kernel: ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 high edge)
Nov  3 22:17:24 localhost kernel: ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
Nov  3 22:17:24 localhost kernel: Using ACPI (MADT) for SMP configuration information
Nov  3 22:17:24 localhost kernel: ACPI: HPET id: 0x8086a201 base: 0xfed00000
Nov  3 22:17:24 localhost kernel: SMP: Allowing 8 CPUs, 0 hotplug CPUs
Nov  3 22:17:24 localhost kernel: PM: Registered nosave memory: 000000000009d000 - 000000000009e000
Nov  3 22:17:24 localhost kernel: PM: Registered nosave memory: 000000000009e000 - 00000000000a0000
Nov  3 22:17:24 localhost kernel: PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
Nov  3 22:17:24 localhost kernel: PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
Nov  3 22:17:24 localhost kernel: PM: Registered nosave memory: 00000000cfef0000 - 00000000cff04000
Nov  3 22:17:24 localhost kernel: PM: Registered nosave memory: 00000000cff04000 - 00000000cff05000
Nov  3 22:17:24 localhost kernel: PM: Registered nosave memory: 00000000cff05000 - 00000000d0000000
Nov  3 22:17:24 localhost kernel: PM: Registered nosave memory: 00000000d0000000 - 00000000e0000000
Nov  3 22:17:24 localhost kernel: PM: Registered nosave memory: 00000000e0000000 - 00000000f0000000
Nov  3 22:17:24 localhost kernel: PM: Registered nosave memory: 00000000f0000000 - 00000000fec00000
Nov  3 22:17:24 localhost kernel: PM: Registered nosave memory: 00000000fec00000 - 00000000fec10000
Nov  3 22:17:24 localhost kernel: PM: Registered nosave memory: 00000000fec10000 - 00000000fee00000
Nov  3 22:17:24 localhost kernel: PM: Registered nosave memory: 00000000fee00000 - 00000000fee01000
Nov  3 22:17:24 localhost kernel: PM: Registered nosave memory: 00000000fee01000 - 00000000ff000000
Nov  3 22:17:24 localhost kernel: PM: Registered nosave memory: 00000000ff000000 - 0000000100000000
Nov  3 22:17:24 localhost kernel: Allocating PCI resources starting at d0000000 (gap: d0000000:10000000)
Nov  3 22:17:24 localhost kernel: Booting paravirtualized kernel on bare hardware
Nov  3 22:17:24 localhost kernel: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:8 nr_node_ids:1
Nov  3 22:17:24 localhost kernel: PERCPU: Embedded 28 pages/cpu @ffff880028200000 s82520 r8192 d23976 u262144
Nov  3 22:17:24 localhost kernel: pcpu-alloc: s82520 r8192 d23976 u262144 alloc=1*2097152
Nov  3 22:17:24 localhost kernel: pcpu-alloc: [0] 0 1 2 3 4 5 6 7 
Nov  3 22:17:24 localhost kernel: Built 1 zonelists in Node order, mobility grouping on.  Total pages: 1031059
Nov  3 22:17:24 localhost kernel: Policy zone: Normal
Nov  3 22:17:24 localhost kernel: Kernel command line: ro root=LABEL=/ rhgb quiet 8250.nr_uarts=16 crashkernel=128M console=tty0 console=ttyS0,9600 8250.nr_uarts=16
Nov  3 22:17:24 localhost kernel: PID hash table entries: 4096 (order: 3, 32768 bytes)
Nov  3 22:17:24 localhost kernel: Initializing CPU#0
Nov  3 22:17:24 localhost kernel: Checking aperture...
Nov  3 22:17:24 localhost kernel: No AGP bridge found
Nov  3 22:17:24 localhost kernel: PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Nov  3 22:17:24 localhost kernel: Placing 64MB software IO TLB between ffff880020000000 - ffff880024000000
Nov  3 22:17:24 localhost kernel: software IO TLB at phys 0x20000000 - 0x24000000
Nov  3 22:17:24 localhost kernel: Memory: 3923976k/4980736k available (3916k kernel code, 787980k absent, 268780k reserved, 2155k data, 1328k init)
Nov  3 22:17:24 localhost kernel: SLUB: Genslabs=14, HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=1
Nov  3 22:17:24 localhost kernel: Hierarchical RCU implementation.
Nov  3 22:17:24 localhost kernel: NR_IRQS:4352 nr_irqs:880
Nov  3 22:17:24 localhost kernel: Extended CMOS year: 2000
Nov  3 22:17:24 localhost kernel: Console: colour VGA+ 80x25
Nov  3 22:17:24 localhost kernel: console [tty0] enabled
Nov  3 22:17:24 localhost kernel: console [ttyS0] enabled
Nov  3 22:17:24 localhost kernel: HPET: 3 timers in total, 0 timers will be used for per-cpu timer
Nov  3 22:17:24 localhost kernel: Fast TSC calibration using PIT
Nov  3 22:17:24 localhost kernel: Detected 2499.637 MHz processor.
Nov  3 22:17:24 localhost kernel: Calibrating delay loop (skipped), value calculated using timer frequency.. 4999.27 BogoMIPS (lpj=9998548)
Nov  3 22:17:24 localhost kernel: Security Framework initialized
Nov  3 22:17:24 localhost kernel: SELinux:  Initializing.
Nov  3 22:17:24 localhost kernel: Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
Nov  3 22:17:24 localhost kernel: Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
Nov  3 22:17:24 localhost kernel: Mount-cache hash table entries: 256
Nov  3 22:17:24 localhost kernel: Initializing cgroup subsys cpuacct
Nov  3 22:17:24 localhost kernel: Initializing cgroup subsys devices
Nov  3 22:17:24 localhost kernel: Initializing cgroup subsys freezer
Nov  3 22:17:24 localhost kernel: CPU: L1 I cache: 32K, L1 D cache: 32K
Nov  3 22:17:24 localhost kernel: CPU: L2 cache: 6144K
Nov  3 22:17:24 localhost kernel: CPU 0/0x0 -> Node 0
Nov  3 22:17:24 localhost kernel: CPU: Physical Processor ID: 0
Nov  3 22:17:24 localhost kernel: CPU: Processor Core ID: 0
Nov  3 22:17:24 localhost kernel: mce: CPU supports 6 MCE banks
Nov  3 22:17:24 localhost kernel: CPU0: Thermal monitoring enabled (TM2)
Nov  3 22:17:24 localhost kernel: using mwait in idle threads.
Nov  3 22:17:24 localhost kernel: Performance Events: Core2 events, Intel PMU driver.
Nov  3 22:17:24 localhost kernel: ... version:                2
Nov  3 22:17:24 localhost kernel: ... bit width:              40
Nov  3 22:17:24 localhost kernel: ... generic registers:      2
Nov  3 22:17:24 localhost kernel: ... value mask:             000000ffffffffff
Nov  3 22:17:24 localhost kernel: ... max period:             000000007fffffff
Nov  3 22:17:24 localhost kernel: ... fixed-purpose events:   3
Nov  3 22:17:24 localhost kernel: ... event mask:             0000000700000003
Nov  3 22:17:24 localhost kernel: ACPI: Core revision 20090903
Nov  3 22:17:24 localhost kernel: Setting APIC routing to flat
Nov  3 22:17:24 localhost kernel: ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
Nov  3 22:17:24 localhost kernel: CPU0: Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz stepping 06
Nov  3 22:17:24 localhost kernel: Booting processor 1 APIC 0x4 ip 0x6000
Nov  3 22:17:24 localhost kernel: Initializing CPU#1
Nov  3 22:17:24 localhost kernel: Calibrating delay using timer specific routine.. 5000.23 BogoMIPS (lpj=10000464)
Nov  3 22:17:24 localhost kernel: CPU: L1 I cache: 32K, L1 D cache: 32K
Nov  3 22:17:24 localhost kernel: CPU: L2 cache: 6144K
Nov  3 22:17:24 localhost kernel: CPU 1/0x4 -> Node 0
Nov  3 22:17:24 localhost kernel: CPU: Physical Processor ID: 1
Nov  3 22:17:24 localhost kernel: CPU: Processor Core ID: 0
Nov  3 22:17:24 localhost kernel: mce: CPU supports 6 MCE banks
Nov  3 22:17:24 localhost kernel: CPU1: Thermal monitoring enabled (TM2)
Nov  3 22:17:24 localhost kernel: CPU1: Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz stepping 06
Nov  3 22:17:24 localhost kernel: checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Nov  3 22:17:24 localhost kernel: Booting processor 2 APIC 0x1 ip 0x6000
Nov  3 22:17:24 localhost kernel: Initializing CPU#2
Nov  3 22:17:24 localhost kernel: Calibrating delay using timer specific routine.. 5000.20 BogoMIPS (lpj=10000400)
Nov  3 22:17:24 localhost kernel: CPU: L1 I cache: 32K, L1 D cache: 32K
Nov  3 22:17:24 localhost kernel: CPU: L2 cache: 6144K
Nov  3 22:17:24 localhost kernel: CPU 2/0x1 -> Node 0
Nov  3 22:17:24 localhost kernel: CPU: Physical Processor ID: 0
Nov  3 22:17:24 localhost kernel: CPU: Processor Core ID: 1
Nov  3 22:17:24 localhost kernel: mce: CPU supports 6 MCE banks
Nov  3 22:17:24 localhost kernel: CPU2: Thermal monitoring enabled (TM2)
Nov  3 22:17:24 localhost kernel: CPU2: Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz stepping 06
Nov  3 22:17:24 localhost kernel: checking TSC synchronization [CPU#0 -> CPU#2]: passed.
Nov  3 22:17:24 localhost kernel: Booting processor 3 APIC 0x5 ip 0x6000
Nov  3 22:17:24 localhost kernel: Initializing CPU#3
Nov  3 22:17:24 localhost kernel: Calibrating delay using timer specific routine.. 5000.21 BogoMIPS (lpj=10000425)
Nov  3 22:17:24 localhost kernel: CPU: L1 I cache: 32K, L1 D cache: 32K
Nov  3 22:17:24 localhost kernel: CPU: L2 cache: 6144K
Nov  3 22:17:24 localhost kernel: CPU 3/0x5 -> Node 0
Nov  3 22:17:24 localhost kernel: CPU: Physical Processor ID: 1
Nov  3 22:17:24 localhost kernel: CPU: Processor Core ID: 1
Nov  3 22:17:24 localhost kernel: mce: CPU supports 6 MCE banks
Nov  3 22:17:24 localhost kernel: CPU3: Thermal monitoring enabled (TM2)
Nov  3 22:17:24 localhost kernel: CPU3: Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz stepping 06
Nov  3 22:17:24 localhost kernel: checking TSC synchronization [CPU#0 -> CPU#3]: passed.
Nov  3 22:17:24 localhost kernel: Booting processor 4 APIC 0x2 ip 0x6000
Nov  3 22:17:24 localhost kernel: Initializing CPU#4
Nov  3 22:17:24 localhost kernel: Calibrating delay using timer specific routine.. 5000.18 BogoMIPS (lpj=10000371)
Nov  3 22:17:24 localhost kernel: CPU: L1 I cache: 32K, L1 D cache: 32K
Nov  3 22:17:24 localhost kernel: CPU: L2 cache: 6144K
Nov  3 22:17:24 localhost kernel: CPU 4/0x2 -> Node 0
Nov  3 22:17:24 localhost kernel: CPU: Physical Processor ID: 0
Nov  3 22:17:24 localhost kernel: CPU: Processor Core ID: 2
Nov  3 22:17:24 localhost kernel: mce: CPU supports 6 MCE banks
Nov  3 22:17:24 localhost kernel: CPU4: Thermal monitoring enabled (TM2)
Nov  3 22:17:24 localhost kernel: CPU4: Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz stepping 06
Nov  3 22:17:24 localhost kernel: checking TSC synchronization [CPU#0 -> CPU#4]: passed.
Nov  3 22:17:24 localhost kernel: Booting processor 5 APIC 0x6 ip 0x6000
Nov  3 22:17:24 localhost kernel: Initializing CPU#5
Nov  3 22:17:24 localhost kernel: Calibrating delay using timer specific routine.. 5000.20 BogoMIPS (lpj=10000404)
Nov  3 22:17:24 localhost kernel: CPU: L1 I cache: 32K, L1 D cache: 32K
Nov  3 22:17:24 localhost kernel: CPU: L2 cache: 6144K
Nov  3 22:17:24 localhost kernel: CPU 5/0x6 -> Node 0
Nov  3 22:17:24 localhost kernel: CPU: Physical Processor ID: 1
Nov  3 22:17:24 localhost kernel: CPU: Processor Core ID: 2
Nov  3 22:17:24 localhost kernel: mce: CPU supports 6 MCE banks
Nov  3 22:17:24 localhost kernel: CPU5: Thermal monitoring enabled (TM2)
Nov  3 22:17:24 localhost kernel: CPU5: Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz stepping 06
Nov  3 22:17:24 localhost kernel: checking TSC synchronization [CPU#0 -> CPU#5]: passed.
Nov  3 22:17:24 localhost kernel: Booting processor 6 APIC 0x3 ip 0x6000
Nov  3 22:17:24 localhost kernel: Initializing CPU#6
Nov  3 22:17:24 localhost kernel: Calibrating delay using timer specific routine.. 5000.18 BogoMIPS (lpj=10000377)
Nov  3 22:17:24 localhost kernel: CPU: L1 I cache: 32K, L1 D cache: 32K
Nov  3 22:17:24 localhost kernel: CPU: L2 cache: 6144K
Nov  3 22:17:24 localhost kernel: CPU 6/0x3 -> Node 0
Nov  3 22:17:24 localhost kernel: CPU: Physical Processor ID: 0
Nov  3 22:17:24 localhost kernel: CPU: Processor Core ID: 3
Nov  3 22:17:24 localhost kernel: mce: CPU supports 6 MCE banks
Nov  3 22:17:24 localhost kernel: CPU6: Thermal monitoring enabled (TM2)
Nov  3 22:17:24 localhost kernel: CPU6: Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz stepping 06
Nov  3 22:17:24 localhost kernel: checking TSC synchronization [CPU#0 -> CPU#6]: passed.
Nov  3 22:17:24 localhost kernel: Booting processor 7 APIC 0x7 ip 0x6000
Nov  3 22:17:24 localhost kernel: Initializing CPU#7
Nov  3 22:17:24 localhost kernel: Calibrating delay using timer specific routine.. 5000.21 BogoMIPS (lpj=10000427)
Nov  3 22:17:24 localhost kernel: CPU: L1 I cache: 32K, L1 D cache: 32K
Nov  3 22:17:24 localhost kernel: CPU: L2 cache: 6144K
Nov  3 22:17:24 localhost kernel: CPU 7/0x7 -> Node 0
Nov  3 22:17:24 localhost kernel: CPU: Physical Processor ID: 1
Nov  3 22:17:24 localhost kernel: CPU: Processor Core ID: 3
Nov  3 22:17:24 localhost kernel: mce: CPU supports 6 MCE banks
Nov  3 22:17:24 localhost kernel: CPU7: Thermal monitoring enabled (TM2)
Nov  3 22:17:24 localhost kernel: CPU7: Intel(R) Xeon(R) CPU           E5420  @ 2.50GHz stepping 06
Nov  3 22:17:24 localhost kernel: checking TSC synchronization [CPU#0 -> CPU#7]: passed.
Nov  3 22:17:24 localhost kernel: Brought up 8 CPUs
Nov  3 22:17:24 localhost kernel: Total of 8 processors activated (40000.70 BogoMIPS).
Nov  3 22:17:24 localhost kernel: devtmpfs: initialized
Nov  3 22:17:24 localhost kernel: NET: Registered protocol family 16
Nov  3 22:17:24 localhost kernel: ACPI: bus type pci registered
Nov  3 22:17:24 localhost kernel: PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 9
Nov  3 22:17:24 localhost kernel: PCI: MCFG area at e0000000 reserved in E820
Nov  3 22:17:24 localhost kernel: PCI: Using MMCONFIG at e0000000 - e09fffff
Nov  3 22:17:24 localhost kernel: PCI: Using configuration type 1 for base access
Nov  3 22:17:24 localhost kernel: bio: create slab <bio-0> at 0
Nov  3 22:17:24 localhost kernel: ACPI: Interpreter enabled
Nov  3 22:17:24 localhost kernel: ACPI: (supports S0 S1 S4 S5)
Nov  3 22:17:24 localhost kernel: ACPI: Using IOAPIC for interrupt routing
Nov  3 22:17:24 localhost kernel: ACPI: No dock devices found.
Nov  3 22:17:24 localhost kernel: ACPI: PCI Root Bridge [PCI0] (0000:00)
Nov  3 22:17:24 localhost kernel: pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
Nov  3 22:17:24 localhost kernel: pci 0000:00:00.0: PME# disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
Nov  3 22:17:24 localhost kernel: pci 0000:00:01.0: PME# disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
Nov  3 22:17:24 localhost kernel: pci 0000:00:03.0: PME# disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
Nov  3 22:17:24 localhost kernel: pci 0000:00:05.0: PME# disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
Nov  3 22:17:24 localhost kernel: pci 0000:00:07.0: PME# disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:09.0: PME# supported from D0 D3hot D3cold
Nov  3 22:17:24 localhost kernel: pci 0000:00:09.0: PME# disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
Nov  3 22:17:24 localhost kernel: pci 0000:00:1d.7: PME# disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:1f.2: PME# supported from D3hot
Nov  3 22:17:24 localhost kernel: pci 0000:00:1f.2: PME# disabled
Nov  3 22:17:24 localhost kernel: pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
Nov  3 22:17:24 localhost kernel: pci 0000:02:00.0: PME# disabled
Nov  3 22:17:24 localhost kernel: pci 0000:02:00.3: PME# supported from D0 D3hot D3cold
Nov  3 22:17:24 localhost kernel: pci 0000:02:00.3: PME# disabled
Nov  3 22:17:24 localhost kernel: pci 0000:02:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
Nov  3 22:17:24 localhost kernel: pci 0000:03:00.0: PME# supported from D0 D3hot D3cold
Nov  3 22:17:24 localhost kernel: pci 0000:03:00.0: PME# disabled
Nov  3 22:17:24 localhost kernel: pci 0000:03:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
Nov  3 22:17:24 localhost kernel: pci 0000:06:00.0: PME# supported from D0 D3hot D3cold
Nov  3 22:17:24 localhost kernel: pci 0000:06:00.0: PME# disabled
Nov  3 22:17:24 localhost kernel: pci 0000:06:00.1: PME# supported from D0 D3hot D3cold
Nov  3 22:17:24 localhost kernel: pci 0000:06:00.1: PME# disabled
Nov  3 22:17:24 localhost kernel: pci 0000:08:00.0: PME# supported from D0 D3hot D3cold
Nov  3 22:17:24 localhost kernel: pci 0000:08:00.0: PME# disabled
Nov  3 22:17:24 localhost kernel: pci 0000:08:00.1: PME# supported from D0 D3hot D3cold
Nov  3 22:17:24 localhost kernel: pci 0000:08:00.1: PME# disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:1e.0: transparent bridge
Nov  3 22:17:24 localhost kernel: ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 *11 14 15)
Nov  3 22:17:24 localhost kernel: ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 *11 14 15)
Nov  3 22:17:24 localhost kernel: ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 10 *11 14 15)
Nov  3 22:17:24 localhost kernel: ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 10 11 14 15) *0, disabled.
Nov  3 22:17:24 localhost kernel: ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 *10 11 14 15)
Nov  3 22:17:24 localhost kernel: ACPI: PCI Interrupt Link [LNKF] (IRQs 4 *5 6 7 10 11 14 15)
Nov  3 22:17:24 localhost kernel: ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 *7 10 11 14 15)
Nov  3 22:17:24 localhost kernel: ACPI: PCI Interrupt Link [LNKH] (IRQs 4 5 6 7 10 *11 14 15)
Nov  3 22:17:24 localhost kernel: vgaarb: device added: PCI:0000:09:01.0,decodes=io+mem,owns=io+mem,locks=none
Nov  3 22:17:24 localhost kernel: vgaarb: loaded
Nov  3 22:17:24 localhost kernel: usbcore: registered new interface driver usbfs
Nov  3 22:17:24 localhost kernel: usbcore: registered new interface driver hub
Nov  3 22:17:24 localhost kernel: usbcore: registered new device driver usb
Nov  3 22:17:24 localhost kernel: PCI: Using ACPI for IRQ routing
Nov  3 22:17:24 localhost kernel: NetLabel: Initializing
Nov  3 22:17:24 localhost kernel: NetLabel:  domain hash size = 128
Nov  3 22:17:24 localhost kernel: NetLabel:  protocols = UNLABELED CIPSOv4
Nov  3 22:17:24 localhost kernel: NetLabel:  unlabeled traffic allowed by default
Nov  3 22:17:24 localhost kernel: hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
Nov  3 22:17:24 localhost kernel: hpet0: 3 comparators, 64-bit 14.318180 MHz counter
Nov  3 22:17:24 localhost kernel: Switching to clocksource tsc
Nov  3 22:17:24 localhost kernel: kstop/0 used greatest stack depth: 6992 bytes left
Nov  3 22:17:24 localhost kernel: kstop/1 used greatest stack depth: 6944 bytes left
Nov  3 22:17:24 localhost kernel: pnp: PnP ACPI init
Nov  3 22:17:24 localhost kernel: ACPI: bus type pnp registered
Nov  3 22:17:24 localhost kernel: pnp: PnP ACPI: found 12 devices
Nov  3 22:17:24 localhost kernel: ACPI: ACPI bus type pnp unregistered
Nov  3 22:17:24 localhost kernel: system 00:01: ioport range 0x4d0-0x4d1 has been reserved
Nov  3 22:17:24 localhost kernel: system 00:01: ioport range 0x295-0x296 has been reserved
Nov  3 22:17:24 localhost kernel: system 00:01: ioport range 0xca2-0xca3 has been reserved
Nov  3 22:17:24 localhost kernel: system 00:01: ioport range 0xca8-0xcaf has been reserved
Nov  3 22:17:24 localhost kernel: system 00:01: ioport range 0x800-0x80f has been reserved
Nov  3 22:17:24 localhost kernel: system 00:01: ioport range 0x1000-0x107f has been reserved
Nov  3 22:17:24 localhost kernel: system 00:01: ioport range 0x1180-0x11bf has been reserved
Nov  3 22:17:24 localhost kernel: system 00:01: ioport range 0xfe00-0xfe00 has been reserved
Nov  3 22:17:24 localhost kernel: system 00:01: iomem range 0xe0000000-0xefffffff has been reserved
Nov  3 22:17:24 localhost kernel: system 00:01: iomem range 0xfee00000-0xfee0ffff could not be reserved
Nov  3 22:17:24 localhost kernel: system 00:01: iomem range 0xfec89000-0xfec89fff could not be reserved
Nov  3 22:17:24 localhost kernel: system 00:01: iomem range 0xfed1c000-0xfed1ffff has been reserved
Nov  3 22:17:24 localhost kernel: system 00:01: iomem range 0xfe000000-0xfe01ffff has been reserved
Nov  3 22:17:24 localhost kernel: system 00:01: iomem range 0xfe600000-0xfe6fffff has been reserved
Nov  3 22:17:24 localhost kernel: system 00:01: iomem range 0xfed20000-0xfed44fff has been reserved
Nov  3 22:17:24 localhost kernel: system 00:01: iomem range 0xfed45000-0xfed8ffff has been reserved
Nov  3 22:17:24 localhost kernel: pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
Nov  3 22:17:24 localhost kernel: pci 0000:00:01.0:   IO window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:01.0:   MEM window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:01.0:   PREFETCH window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:03:00.0: PCI bridge, secondary bus 0000:04
Nov  3 22:17:24 localhost kernel: pci 0000:03:00.0:   IO window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:03:00.0:   MEM window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:03:00.0:   PREFETCH window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:02:00.0: PCI bridge, secondary bus 0000:03
Nov  3 22:17:24 localhost kernel: pci 0000:02:00.0:   IO window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:02:00.0:   MEM window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:02:00.0:   PREFETCH window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:02:00.3: PCI bridge, secondary bus 0000:05
Nov  3 22:17:24 localhost kernel: pci 0000:02:00.3:   IO window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:02:00.3:   MEM window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:02:00.3:   PREFETCH window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:03.0: PCI bridge, secondary bus 0000:02
Nov  3 22:17:24 localhost kernel: pci 0000:00:03.0:   IO window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:03.0:   MEM window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:03.0:   PREFETCH window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:05.0: PCI bridge, secondary bus 0000:06
Nov  3 22:17:24 localhost kernel: pci 0000:00:05.0:   IO window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:05.0:   MEM window: 0xd8000000-0xdc3fffff
Nov  3 22:17:24 localhost kernel: pci 0000:00:05.0:   PREFETCH window: 0xdc500000-0xdc5fffff
Nov  3 22:17:24 localhost kernel: pci 0000:00:07.0: PCI bridge, secondary bus 0000:07
Nov  3 22:17:24 localhost kernel: pci 0000:00:07.0:   IO window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:07.0:   MEM window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:07.0:   PREFETCH window: disabled
Nov  3 22:17:24 localhost kernel: pci 0000:00:09.0: PCI bridge, secondary bus 0000:08
Nov  3 22:17:24 localhost kernel: pci 0000:00:09.0:   IO window: 0x2000-0x2fff
Nov  3 22:17:24 localhost kernel: pci 0000:00:09.0:   MEM window: 0xdc400000-0xdc4fffff
Nov  3 22:17:24 localhost kernel: pci 0000:00:09.0:   PREFETCH window: 0xdc700000-0xdc7fffff
Nov  3 22:17:24 localhost kernel: pci 0000:00:1e.0: PCI bridge, secondary bus 0000:09
Nov  3 22:17:24 localhost kernel: pci 0000:00:1e.0:   IO window: 0x3000-0x3fff
Nov  3 22:17:24 localhost kernel: pci 0000:00:1e.0:   MEM window: 0xdc600000-0xdc6fffff
Nov  3 22:17:24 localhost kernel: pci 0000:00:1e.0:   PREFETCH window: 0x000000d0000000-0x000000d7ffffff
Nov  3 22:17:24 localhost kernel: pci 0000:00:01.0: PCI INT A -> GSI 24 (level, low) -> IRQ 24
Nov  3 22:17:24 localhost kernel: pci 0000:00:03.0: PCI INT A -> GSI 26 (level, low) -> IRQ 26
Nov  3 22:17:24 localhost kernel: pci 0000:02:00.0: PCI INT A -> GSI 26 (level, low) -> IRQ 26
Nov  3 22:17:24 localhost kernel: pci 0000:03:00.0: PCI INT A -> GSI 26 (level, low) -> IRQ 26
Nov  3 22:17:24 localhost kernel: pci 0000:00:05.0: PCI INT A -> GSI 28 (level, low) -> IRQ 28
Nov  3 22:17:24 localhost kernel: pci 0000:00:07.0: PCI INT A -> GSI 30 (level, low) -> IRQ 30
Nov  3 22:17:24 localhost kernel: pci 0000:00:09.0: PCI INT A -> GSI 32 (level, low) -> IRQ 32
Nov  3 22:17:24 localhost kernel: NET: Registered protocol family 2
Nov  3 22:17:24 localhost kernel: IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
Nov  3 22:17:24 localhost kernel: TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
Nov  3 22:17:24 localhost kernel: TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
Nov  3 22:17:24 localhost kernel: TCP: Hash tables configured (established 524288 bind 65536)
Nov  3 22:17:24 localhost kernel: TCP reno registered
Nov  3 22:17:24 localhost kernel: NET: Registered protocol family 1
Nov  3 22:17:24 localhost kernel: pci 0000:08:00.0: Disabling L0s
Nov  3 22:17:24 localhost kernel: pci 0000:08:00.1: Disabling L0s
Nov  3 22:17:24 localhost kernel: Trying to unpack rootfs image as initramfs...
Nov  3 22:17:24 localhost kernel: Freeing initrd memory: 3019k freed
Nov  3 22:17:24 localhost kernel: Simple Boot Flag at 0x41 set to 0x80
Nov  3 22:17:24 localhost kernel: audit: initializing netlink socket (disabled)
Nov  3 22:17:24 localhost kernel: type=2000 audit(1257315226.827:1): initialized
Nov  3 22:17:24 localhost kernel: HugeTLB registered 2 MB page size, pre-allocated 0 pages
Nov  3 22:17:24 localhost kernel: VFS: Disk quotas dquot_6.5.2
Nov  3 22:17:24 localhost kernel: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
Nov  3 22:17:24 localhost kernel: msgmni has been set to 7669
Nov  3 22:17:24 localhost kernel: cryptomgr_test used greatest stack depth: 6048 bytes left
Nov  3 22:17:24 localhost kernel: cryptomgr_test used greatest stack depth: 5944 bytes left
Nov  3 22:17:24 localhost kernel: alg: No test for stdrng (krng)
Nov  3 22:17:24 localhost kernel: Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
Nov  3 22:17:24 localhost kernel: io scheduler noop registered
Nov  3 22:17:24 localhost kernel: io scheduler anticipatory registered
Nov  3 22:17:24 localhost kernel: io scheduler deadline registered
Nov  3 22:17:24 localhost kernel: io scheduler cfq registered (default)
Nov  3 22:17:24 localhost kernel: pci_hotplug: PCI Hot Plug PCI Core version: 0.5
Nov  3 22:17:24 localhost kernel: input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A03:00/PNP0C0C:00/input/input0
Nov  3 22:17:24 localhost kernel: ACPI: Power Button [PWRB]
Nov  3 22:17:24 localhost kernel: input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
Nov  3 22:17:24 localhost kernel: ACPI: Power Button [PWRF]
Nov  3 22:17:24 localhost kernel: processor LNXCPU:00: registered as cooling_device0
Nov  3 22:17:24 localhost kernel: processor LNXCPU:01: registered as cooling_device1
Nov  3 22:17:24 localhost kernel: processor LNXCPU:02: registered as cooling_device2
Nov  3 22:17:24 localhost kernel: processor LNXCPU:03: registered as cooling_device3
Nov  3 22:17:24 localhost kernel: processor LNXCPU:04: registered as cooling_device4
Nov  3 22:17:24 localhost kernel: processor LNXCPU:05: registered as cooling_device5
Nov  3 22:17:24 localhost kernel: processor LNXCPU:06: registered as cooling_device6
Nov  3 22:17:24 localhost kernel: processor LNXCPU:07: registered as cooling_device7
Nov  3 22:17:24 localhost kernel: Non-volatile memory driver v1.3
Nov  3 22:17:24 localhost kernel: Linux agpgart interface v0.103
Nov  3 22:17:24 localhost kernel: Serial: 8250/16550 driver, 16 ports, IRQ sharing enabled
Nov  3 22:17:24 localhost kernel: serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
Nov  3 22:17:24 localhost kernel: serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
Nov  3 22:17:24 localhost kernel: 00:0a: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
Nov  3 22:17:24 localhost kernel: 00:0b: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
Nov  3 22:17:24 localhost kernel: brd: module loaded
Nov  3 22:17:24 localhost kernel: input: Macintosh mouse button emulation as /devices/virtual/input/input2
Nov  3 22:17:24 localhost kernel: PNP: PS/2 Controller [PNP0303:KBC0,PNP0f13:MSE0] at 0x60,0x64 irq 1,12
Nov  3 22:17:24 localhost kernel: serio: i8042 KBD port at 0x60,0x64 irq 1
Nov  3 22:17:24 localhost kernel: mice: PS/2 mouse device common for all mice
Nov  3 22:17:24 localhost kernel: Driver 'rtc_cmos' needs updating - please use bus_type methods
Nov  3 22:17:24 localhost kernel: rtc_cmos 00:05: RTC can wake from S4
Nov  3 22:17:24 localhost kernel: rtc_cmos 00:05: rtc core: registered rtc_cmos as rtc0
Nov  3 22:17:24 localhost kernel: rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
Nov  3 22:17:24 localhost kernel: sbc_fitpc2_wdt WATCHDOG: board name is: X7DWU. Should be SBC-FITPC2
Nov  3 22:17:24 localhost kernel: cpuidle: using governor ladder
Nov  3 22:17:24 localhost kernel: cpuidle: using governor menu
Nov  3 22:17:24 localhost kernel: usbcore: registered new interface driver hiddev
Nov  3 22:17:24 localhost kernel: usbcore: registered new interface driver usbhid
Nov  3 22:17:24 localhost kernel: usbhid: v2.6:USB HID core driver
Nov  3 22:17:24 localhost kernel: TCP cubic registered
Nov  3 22:17:24 localhost kernel: Initializing XFRM netlink socket
Nov  3 22:17:24 localhost kernel: NET: Registered protocol family 17
Nov  3 22:17:24 localhost kernel: registered taskstats version 1
Nov  3 22:17:24 localhost kernel: Freeing unused kernel memory: 1328k freed
Nov  3 22:17:24 localhost kernel: Write protecting the kernel read-only data: 5560k
Nov  3 22:17:24 localhost kernel: plymouthd used greatest stack depth: 5832 bytes left
Nov  3 22:17:24 localhost kernel: modprobe used greatest stack depth: 5536 bytes left
Nov  3 22:17:24 localhost kernel: ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
Nov  3 22:17:24 localhost kernel: ehci_hcd 0000:00:1d.7: PCI INT D -> GSI 23 (level, low) -> IRQ 23
Nov  3 22:17:24 localhost kernel: ehci_hcd 0000:00:1d.7: EHCI Host Controller
Nov  3 22:17:24 localhost kernel: ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
Nov  3 22:17:24 localhost kernel: ehci_hcd 0000:00:1d.7: debug port 1
Nov  3 22:17:24 localhost kernel: ehci_hcd 0000:00:1d.7: irq 23, io mem 0xdc904000
Nov  3 22:17:24 localhost kernel: ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
Nov  3 22:17:24 localhost kernel: usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
Nov  3 22:17:24 localhost kernel: usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Nov  3 22:17:24 localhost kernel: usb usb1: Product: EHCI Host Controller
Nov  3 22:17:24 localhost kernel: usb usb1: Manufacturer: Linux 2.6.32-rc5-198042.2009AroraKernelBeta.fc11.x86_64 ehci_hcd
Nov  3 22:17:24 localhost kernel: usb usb1: SerialNumber: 0000:00:1d.7
Nov  3 22:17:24 localhost kernel: usb usb1: configuration #1 chosen from 1 choice
Nov  3 22:17:24 localhost kernel: hub 1-0:1.0: USB hub found
Nov  3 22:17:24 localhost kernel: hub 1-0:1.0: 8 ports detected
Nov  3 22:17:24 localhost kernel: modprobe used greatest stack depth: 4360 bytes left
Nov  3 22:17:24 localhost kernel: ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
Nov  3 22:17:24 localhost kernel: uhci_hcd: USB Universal Host Controller Interface driver
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.0: UHCI Host Controller
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.0: detected 2 ports
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.0: irq 20, io base 0x00001800
Nov  3 22:17:24 localhost kernel: usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
Nov  3 22:17:24 localhost kernel: usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Nov  3 22:17:24 localhost kernel: usb usb2: Product: UHCI Host Controller
Nov  3 22:17:24 localhost kernel: usb usb2: Manufacturer: Linux 2.6.32-rc5-198042.2009AroraKernelBeta.fc11.x86_64 uhci_hcd
Nov  3 22:17:24 localhost kernel: usb usb2: SerialNumber: 0000:00:1d.0
Nov  3 22:17:24 localhost kernel: usb usb2: configuration #1 chosen from 1 choice
Nov  3 22:17:24 localhost kernel: hub 2-0:1.0: USB hub found
Nov  3 22:17:24 localhost kernel: hub 2-0:1.0: 2 ports detected
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.1: UHCI Host Controller
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.1: detected 2 ports
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.1: irq 21, io base 0x00001820
Nov  3 22:17:24 localhost kernel: usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
Nov  3 22:17:24 localhost kernel: usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Nov  3 22:17:24 localhost kernel: usb usb3: Product: UHCI Host Controller
Nov  3 22:17:24 localhost kernel: usb usb3: Manufacturer: Linux 2.6.32-rc5-198042.2009AroraKernelBeta.fc11.x86_64 uhci_hcd
Nov  3 22:17:24 localhost kernel: usb usb3: SerialNumber: 0000:00:1d.1
Nov  3 22:17:24 localhost kernel: usb usb3: configuration #1 chosen from 1 choice
Nov  3 22:17:24 localhost kernel: hub 3-0:1.0: USB hub found
Nov  3 22:17:24 localhost kernel: hub 3-0:1.0: 2 ports detected
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 22 (level, low) -> IRQ 22
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.2: UHCI Host Controller
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.2: detected 2 ports
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.2: irq 22, io base 0x00001840
Nov  3 22:17:24 localhost kernel: usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
Nov  3 22:17:24 localhost kernel: usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Nov  3 22:17:24 localhost kernel: usb usb4: Product: UHCI Host Controller
Nov  3 22:17:24 localhost kernel: usb usb4: Manufacturer: Linux 2.6.32-rc5-198042.2009AroraKernelBeta.fc11.x86_64 uhci_hcd
Nov  3 22:17:24 localhost kernel: usb usb4: SerialNumber: 0000:00:1d.2
Nov  3 22:17:24 localhost kernel: usb usb4: configuration #1 chosen from 1 choice
Nov  3 22:17:24 localhost kernel: hub 4-0:1.0: USB hub found
Nov  3 22:17:24 localhost kernel: hub 4-0:1.0: 2 ports detected
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 23 (level, low) -> IRQ 23
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.3: UHCI Host Controller
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.3: detected 2 ports
Nov  3 22:17:24 localhost kernel: uhci_hcd 0000:00:1d.3: irq 23, io base 0x00001860
Nov  3 22:17:24 localhost kernel: usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
Nov  3 22:17:24 localhost kernel: usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
Nov  3 22:17:24 localhost kernel: usb usb5: Product: UHCI Host Controller
Nov  3 22:17:24 localhost kernel: usb usb5: Manufacturer: Linux 2.6.32-rc5-198042.2009AroraKernelBeta.fc11.x86_64 uhci_hcd
Nov  3 22:17:24 localhost kernel: usb usb5: SerialNumber: 0000:00:1d.3
Nov  3 22:17:24 localhost kernel: usb usb5: configuration #1 chosen from 1 choice
Nov  3 22:17:24 localhost kernel: hub 5-0:1.0: USB hub found
Nov  3 22:17:24 localhost kernel: hub 5-0:1.0: 2 ports detected
Nov  3 22:17:24 localhost kernel: modprobe used greatest stack depth: 4296 bytes left
Nov  3 22:17:24 localhost kernel: SCSI subsystem initialized
Nov  3 22:17:24 localhost kernel: ata_piix 0000:00:1f.1: PCI INT A -> GSI 16 (level, low) -> IRQ 16
Nov  3 22:17:24 localhost kernel: scsi0 : ata_piix
Nov  3 22:17:24 localhost kernel: scsi1 : ata_piix
Nov  3 22:17:24 localhost kernel: ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x1880 irq 14
Nov  3 22:17:24 localhost kernel: ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x1888 irq 15
Nov  3 22:17:24 localhost kernel: ata_piix 0000:00:1f.2: PCI INT B -> GSI 17 (level, low) -> IRQ 17
Nov  3 22:17:24 localhost kernel: ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
Nov  3 22:17:24 localhost kernel: scsi2 : ata_piix
Nov  3 22:17:24 localhost kernel: scsi3 : ata_piix
Nov  3 22:17:24 localhost kernel: ata3: SATA max UDMA/133 cmd 0x18c0 ctl 0x18b8 bmdma 0x18a0 irq 17
Nov  3 22:17:24 localhost kernel: ata4: SATA max UDMA/133 cmd 0x18b0 ctl 0x1894 bmdma 0x18a8 irq 17
Nov  3 22:17:24 localhost kernel: ata1.01: ATAPI: DVD-ROM UJDA780, 1.50, max UDMA/33
Nov  3 22:17:24 localhost kernel: ata1.01: configured for UDMA/33
Nov  3 22:17:24 localhost kernel: scsi 0:0:1:0: CD-ROM            MATSHITA DVD-ROM UJDA780  1.50 PQ: 0 ANSI: 5
Nov  3 22:17:24 localhost kernel: ata3.00: ATA-7: WDC WD2500JS-60NCB2, 10.02E03, max UDMA/100
Nov  3 22:17:24 localhost kernel: ata3.00: 488397168 sectors, multi 16: LBA48 NCQ (depth 0/32)
Nov  3 22:17:24 localhost kernel: ata3.00: configured for UDMA/100
Nov  3 22:17:24 localhost kernel: scsi 2:0:0:0: Direct-Access     ATA      WDC WD2500JS-60N 10.0 PQ: 0 ANSI: 5
Nov  3 22:17:24 localhost kernel: sd 2:0:0:0: [sda] 488397168 512-byte logical blocks: (250 GB/232 GiB)
Nov  3 22:17:24 localhost kernel: sd 2:0:0:0: [sda] Write Protect is off
Nov  3 22:17:24 localhost kernel: sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
Nov  3 22:17:24 localhost kernel: sda: sda1 sda2 sda3
Nov  3 22:17:24 localhost kernel: sd 2:0:0:0: [sda] Attached SCSI disk
Nov  3 22:17:24 localhost kernel: modprobe used greatest stack depth: 3464 bytes left
Nov  3 22:17:24 localhost kernel: kjournald starting.  Commit interval 5 seconds
Nov  3 22:17:24 localhost kernel: EXT3-fs: mounted filesystem with ordered data mode.
Nov  3 22:17:24 localhost kernel: SELinux:  Disabled at runtime.
Nov  3 22:17:24 localhost kernel: type=1404 audit(1257315228.721:2): selinux=0 auid=4294967295 ses=4294967295
Nov  3 22:17:24 localhost kernel: udev: starting version 141
Nov  3 22:17:24 localhost kernel: scsi 0:0:1:0: Attached scsi generic sg0 type 5
Nov  3 22:17:24 localhost kernel: sd 2:0:0:0: Attached scsi generic sg1 type 0
Nov  3 22:17:24 localhost kernel: NetXen Network Driver version 4.0.50
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: PCI INT A -> GSI 28 (level, low) -> IRQ 28
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: 2MB memory map
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:17:24 localhost kernel: dca service started, version 1.12.1
Nov  3 22:17:24 localhost kernel: input: PC Speaker as /devices/platform/pcspkr/input/input3
Nov  3 22:17:24 localhost kernel: Intel(R) Gigabit Ethernet Network Driver - version 1.3.16-k2
Nov  3 22:17:24 localhost kernel: Copyright (c) 2007-2009 Intel Corporation.
Nov  3 22:17:24 localhost kernel: igb 0000:08:00.0: PCI INT A -> GSI 32 (level, low) -> IRQ 32
Nov  3 22:17:24 localhost kernel: sr0: scsi3-mmc drive: 24x/24x cd/rw xa/form2 cdda tray
Nov  3 22:17:24 localhost kernel: Uniform CD-ROM driver Revision: 3.20
Nov  3 22:17:24 localhost kernel: intel_rng: FWH not detected
Nov  3 22:17:24 localhost kernel: EDAC MC: Ver: 2.1.0 Nov  3 2009
Nov  3 22:17:24 localhost kernel: EDAC MC0: Giving out device to 'i5400_edac.c' 'I5400': DEV 0000:00:10.0
Nov  3 22:17:24 localhost kernel: EDAC PCI0: Giving out device to module 'i5400_edac' controller 'EDAC PCI controller': DEV '0000:00:10.0' (POLLED)
Nov  3 22:17:24 localhost kernel: ioatdma: Intel(R) QuickData Technology Driver 4.00
Nov  3 22:17:24 localhost kernel: ioatdma 0000:00:0f.0: PCI INT A -> GSI 33 (level, low) -> IRQ 33
Nov  3 22:17:24 localhost kernel: ioatdma 0000:00:0f.0: zero channels detected
Nov  3 22:17:24 localhost kernel: ioatdma 0000:00:0f.0: Intel(R) I/OAT DMA Engine init failed
Nov  3 22:17:24 localhost kernel: ioatdma 0000:00:0f.0: PCI INT A disabled
Nov  3 22:17:24 localhost kernel: i801_smbus 0000:00:1f.3: PCI INT C -> GSI 18 (level, low) -> IRQ 18
Nov  3 22:17:24 localhost kernel: iTCO_vendor_support: vendor-support=0
Nov  3 22:17:24 localhost kernel: iTCO_wdt: Intel TCO WatchDog Timer Driver v1.05
Nov  3 22:17:24 localhost kernel: iTCO_wdt: Found a 631xESB/632xESB TCO device (Version=2, TCOBASE=0x1060)
Nov  3 22:17:24 localhost kernel: iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
Nov  3 22:17:24 localhost kernel: igb 0000:08:00.0: Intel(R) Gigabit Ethernet Network Connection
Nov  3 22:17:24 localhost kernel: igb 0000:08:00.0: eth0: (PCIe:2.5Gb/s:Width x4) 00:30:48:64:a0:bc
Nov  3 22:17:24 localhost kernel: igb 0000:08:00.0: eth0: PBA No: ffffff-0ff
Nov  3 22:17:24 localhost kernel: igb 0000:08:00.0: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
Nov  3 22:17:24 localhost kernel: igb 0000:08:00.1: PCI INT B -> GSI 46 (level, low) -> IRQ 46
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:17:24 localhost kernel: igb 0000:08:00.1: Intel(R) Gigabit Ethernet Network Connection
Nov  3 22:17:24 localhost kernel: igb 0000:08:00.1: eth1: (PCIe:2.5Gb/s:Width x4) 00:30:48:64:a0:bd
Nov  3 22:17:24 localhost kernel: igb 0000:08:00.1: eth1: PBA No: ffffff-0ff
Nov  3 22:17:24 localhost kernel: igb 0000:08:00.1: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
Nov  3 22:17:24 localhost kernel: udev: renamed network interface eth1 to eth3
Nov  3 22:17:24 localhost kernel: udev: renamed network interface eth0 to eth2
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:17:24 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: using msi-x interrupts
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: eth0: XGbE port initialized
Nov  3 22:17:24 localhost kernel: shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: PCI INT A -> GSI 28 (level, low) -> IRQ 28
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: 2MB memory map
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: using msi-x interrupts
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: eth1: XGbE port initialized
Nov  3 22:17:24 localhost kernel: 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
Nov  3 22:17:24 localhost kernel: All bugs added by David S. Miller <davem@redhat.com>
Nov  3 22:17:24 localhost kernel: tun: Universal TUN/TAP device driver, 1.6
Nov  3 22:17:24 localhost kernel: tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
Nov  3 22:17:24 localhost kernel: nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
Nov  3 22:17:24 localhost kernel: CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use
Nov  3 22:17:24 localhost kernel: nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack module option or
Nov  3 22:17:24 localhost kernel: sysctl net.netfilter.nf_conntrack_acct=1 to enable it.
Nov  3 22:17:24 localhost kernel: ip_tables: (C) 2000-2006 Netfilter Core Team
Nov  3 22:17:24 localhost kernel: fuse init (API version 7.13)
Nov  3 22:17:24 localhost kernel: has_svm: not amd
Nov  3 22:17:24 localhost kernel: kvm: no hardware support
Nov  3 22:17:24 localhost kernel: NET: Registered protocol family 10
Nov  3 22:17:24 localhost kernel: lo: Disabled Privacy Extensions
Nov  3 22:17:24 localhost kernel: Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)
Nov  3 22:17:24 localhost kernel: bonding: MII link monitoring set to 100 ms
Nov  3 22:17:24 localhost kernel: device-mapper: uevent: version 1.0.3
Nov  3 22:17:24 localhost kernel: device-mapper: ioctl: 4.15.0-ioctl (2009-04-01) initialised: dm-devel@redhat.com
Nov  3 22:17:24 localhost kernel: device-mapper: multipath: version 1.1.0 loaded
Nov  3 22:17:24 localhost kernel: net eth0: firmware hang detected
Nov  3 22:17:24 localhost kernel: net eth1: firmware hang detected
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: net eth1: firmware hang detected
Nov  3 22:17:24 localhost kernel: net eth0: firmware hang detected
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:17:24 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: net eth0: firmware hang detected
Nov  3 22:17:24 localhost kernel: net eth1: firmware hang detected
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: net eth1: firmware hang detected
Nov  3 22:17:24 localhost kernel: net eth0: firmware hang detected
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:17:24 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: net eth0: firmware hang detected
Nov  3 22:17:24 localhost kernel: net eth1: firmware hang detected
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:17:24 localhost kernel: EXT3 FS on sda1, internal journal
Nov  3 22:17:24 localhost kernel: EXT4-fs (sda3): mounted filesystem with ordered data mode
Nov  3 22:17:24 localhost kernel: Adding 1951888k swap on /dev/sda2.  Priority:-1 extents:1 across:1951888k 
Nov  3 22:17:24 localhost kernel: microcode: CPU0 sig=0x10676, pf=0x40, revision=0x60b
Nov  3 22:17:24 localhost kernel: platform microcode: firmware: requesting intel-ucode/06-17-06
Nov  3 22:17:24 localhost kernel: microcode: CPU1 sig=0x10676, pf=0x40, revision=0x60b
Nov  3 22:17:24 localhost kernel: platform microcode: firmware: requesting intel-ucode/06-17-06
Nov  3 22:17:24 localhost kernel: microcode: CPU2 sig=0x10676, pf=0x40, revision=0x60b
Nov  3 22:17:24 localhost kernel: platform microcode: firmware: requesting intel-ucode/06-17-06
Nov  3 22:17:24 localhost kernel: microcode: CPU3 sig=0x10676, pf=0x40, revision=0x60b
Nov  3 22:17:24 localhost kernel: platform microcode: firmware: requesting intel-ucode/06-17-06
Nov  3 22:17:24 localhost kernel: microcode: CPU4 sig=0x10676, pf=0x40, revision=0x60b
Nov  3 22:17:24 localhost kernel: platform microcode: firmware: requesting intel-ucode/06-17-06
Nov  3 22:17:24 localhost kernel: microcode: CPU5 sig=0x10676, pf=0x40, revision=0x60b
Nov  3 22:17:24 localhost kernel: platform microcode: firmware: requesting intel-ucode/06-17-06
Nov  3 22:17:24 localhost kernel: microcode: CPU6 sig=0x10676, pf=0x40, revision=0x60b
Nov  3 22:17:24 localhost kernel: platform microcode: firmware: requesting intel-ucode/06-17-06
Nov  3 22:17:24 localhost kernel: microcode: CPU7 sig=0x10676, pf=0x40, revision=0x60b
Nov  3 22:17:24 localhost kernel: platform microcode: firmware: requesting intel-ucode/06-17-06
Nov  3 22:17:24 localhost kernel: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
Nov  3 22:17:24 localhost kernel: microcode: CPU0 updated to revision 0x60c, date = 2008-01-19 
Nov  3 22:17:24 localhost kernel: microcode: CPU1 updated to revision 0x60c, date = 2008-01-19 
Nov  3 22:17:24 localhost kernel: microcode: CPU2 updated to revision 0x60c, date = 2008-01-19 
Nov  3 22:17:24 localhost kernel: microcode: CPU3 updated to revision 0x60c, date = 2008-01-19 
Nov  3 22:17:24 localhost kernel: microcode: CPU4 updated to revision 0x60c, date = 2008-01-19 
Nov  3 22:17:24 localhost kernel: microcode: CPU5 updated to revision 0x60c, date = 2008-01-19 
Nov  3 22:17:24 localhost kernel: microcode: CPU6 updated to revision 0x60c, date = 2008-01-19 
Nov  3 22:17:24 localhost kernel: microcode: CPU7 updated to revision 0x60c, date = 2008-01-19 
Nov  3 22:17:24 localhost kernel: Microcode Update Driver: v2.00 removed.
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: bonding: bond1 is being created...
Nov  3 22:17:24 localhost kernel: ADDRCONF(NETDEV_UP): eth0: link is not ready
Nov  3 22:17:24 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:17:24 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
Nov  3 22:17:24 localhost kernel: net eth1: firmware hang detected
Nov  3 22:17:24 localhost kernel: net eth0: firmware hang detected
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:17:24 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:17:24 localhost kernel: net eth0: firmware hang detected
Nov  3 22:17:24 localhost kernel: net eth1: firmware hang detected
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:17:24 localhost kernel: net eth1: firmware hang detected
Nov  3 22:17:24 localhost kernel: net eth0: firmware hang detected
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:17:24 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:17:24 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:17:24 localhost kernel: net eth0: firmware hang detected
Nov  3 22:17:24 localhost kernel: net eth1: firmware hang detected
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:17:24 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:17:24 localhost rpc.statd[3009]: Version 1.1.6 Starting
Nov  3 22:17:24 localhost kernel: RPC: Registered udp transport module.
Nov  3 22:17:24 localhost kernel: RPC: Registered tcp transport module.
Nov  3 22:17:24 localhost kernel: RPC: Registered tcp NFSv4.1 backchannel transport module.
Nov  3 22:17:32 localhost kdump: kexec: loaded kdump kernel
Nov  3 22:17:32 localhost kdump: started up
Nov  3 22:17:32 localhost avahi-daemon[5377]: Found user 'avahi' (UID 497) and group 'avahi' (GID 489).
Nov  3 22:17:32 localhost avahi-daemon[5377]: Successfully dropped root privileges.
Nov  3 22:17:32 localhost avahi-daemon[5377]: avahi-daemon 0.6.25 starting up.
Nov  3 22:17:32 localhost avahi-daemon[5377]: WARNING: No NSS support for mDNS detected, consider installing nss-mdns!
Nov  3 22:17:32 localhost avahi-daemon[5377]: Successfully called chroot().
Nov  3 22:17:32 localhost avahi-daemon[5377]: Successfully dropped remaining capabilities.
Nov  3 22:17:32 localhost avahi-daemon[5377]: Loading service file /services/ssh.service.
Nov  3 22:17:32 localhost avahi-daemon[5377]: System host name is set to 'localhost'. This is not a suitable mDNS host name, looking for alternatives.
Nov  3 22:17:32 localhost avahi-daemon[5377]: Network interface enumeration completed.
Nov  3 22:17:32 localhost avahi-daemon[5377]: Registering HINFO record with values 'X86_64'/'LINUX'.
Nov  3 22:17:32 localhost avahi-daemon[5377]: Server startup complete. Host name is linux.local. Local service cookie is 544349536.
Nov  3 22:17:32 localhost avahi-daemon[5377]: Service "linux" (/services/ssh.service) successfully established.
Nov  3 22:17:33 localhost acpid: starting up
Nov  3 22:17:33 localhost acpid: 1 rule loaded
Nov  3 22:17:33 localhost acpid: waiting for events: event logging is off
Nov  3 22:17:34 localhost acpid: client connected from 5549[68:482]
Nov  3 22:17:34 localhost acpid: 1 client rule loaded
Nov  3 22:17:34 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:17:34 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:17:34 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:17:34 localhost pcscd: pcscdaemon.c:506:main() pcsc-lite 1.5.2 daemon ready.
Nov  3 22:17:34 localhost bluetoothd[5585]: Bluetooth daemon 4.42
Nov  3 22:17:34 localhost bluetoothd[5585]: Starting SDP server
Nov  3 22:17:35 localhost kernel: Bluetooth: Core ver 2.15
Nov  3 22:17:35 localhost kernel: NET: Registered protocol family 31
Nov  3 22:17:35 localhost kernel: Bluetooth: HCI device and connection manager initialized
Nov  3 22:17:35 localhost kernel: Bluetooth: HCI socket layer initialized
Nov  3 22:17:35 localhost kernel: Bluetooth: L2CAP ver 2.14
Nov  3 22:17:35 localhost kernel: Bluetooth: L2CAP socket layer initialized
Nov  3 22:17:35 localhost bluetoothd[5585]: Parsing /etc/bluetooth/network.conf failed: No such file or directory
Nov  3 22:17:35 localhost kernel: Bluetooth: BNEP (Ethernet Emulation) ver 1.3
Nov  3 22:17:35 localhost kernel: Bluetooth: BNEP filters: protocol multicast
Nov  3 22:17:35 localhost bluetoothd[5585]: bridge pan0 created
Nov  3 22:17:35 localhost bluetoothd[5585]: Parsing /etc/bluetooth/audio.conf failed: No such file or directory
Nov  3 22:17:35 localhost kernel: Bridge firewalling registered
Nov  3 22:17:35 localhost bluetoothd[5585]: Parsing /etc/bluetooth/input.conf failed: No such file or directory
Nov  3 22:17:35 localhost kernel: Bluetooth: SCO (Voice Link) ver 0.6
Nov  3 22:17:35 localhost kernel: Bluetooth: SCO socket layer initialized
Nov  3 22:17:35 localhost xinetd[5639]: xinetd Version 2.3.14 started with libwrap loadavg labeled-networking options compiled in.
Nov  3 22:17:35 localhost xinetd[5639]: Started working: 1 available service
Nov  3 22:17:35 localhost ntpd[5655]: ntpd 4.2.4p7@1.1607-o Thu May 28 18:55:23 UTC 2009 (1)
Nov  3 22:17:35 localhost ntpd[5656]: precision = 0.102 usec
Nov  3 22:17:35 localhost ntpd[5656]: Listening on interface #0 wildcard, 0.0.0.0#123 Disabled
Nov  3 22:17:35 localhost ntpd[5656]: Listening on interface #1 wildcard, ::#123 Disabled
Nov  3 22:17:35 localhost ntpd[5656]: Listening on interface #2 lo, ::1#123 Enabled
Nov  3 22:17:35 localhost ntpd[5656]: Listening on interface #3 lo, 127.0.0.1#123 Enabled
Nov  3 22:17:35 localhost ntpd[5656]: Listening on routing socket on fd #20 for interface updates
Nov  3 22:17:35 localhost ntpd[5656]: kernel time sync status 2040
Nov  3 22:17:35 localhost ntpd[5656]: frequency initialized -90.146 PPM from /var/lib/ntp/drift
Nov  3 22:17:35 localhost kernel: Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
Nov  3 22:17:35 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Nov  3 22:17:35 localhost kernel: NFSD: starting 90-second grace period
Nov  3 22:17:35 localhost kernel: rpc.nfsd used greatest stack depth: 2808 bytes left
Nov  3 22:17:36 localhost distccd[5755]: (dcc_setup_daemon_path) daemon's PATH is /usr/lib64/qt-3.3/bin:/usr/kerberos/bin:/usr/lib64/ccache:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin
Nov  3 22:17:36 localhost distccd[5755]: (dcc_listen_by_addr) listening on 0.0.0.0:3632
Nov  3 22:17:36 localhost distccd[5755]: (dcc_standalone_server) 8 CPUs online on this server
Nov  3 22:17:36 localhost distccd[5755]: (dcc_standalone_server) allowing up to 10 active jobs
Nov  3 22:17:36 localhost distccd[5756]: (dcc_log_daemon_started) preforking daemon started (2.18.3 x86_64-unknown-linux-gnu, built Oct  2 2009 04:40:18)
Nov  3 22:17:37 localhost ladvd: no valid interface found
Nov  3 22:17:37 localhost ladvd: unable fetch interfaces
Nov  3 22:17:40 localhost kernel: net eth1: firmware hang detected
Nov  3 22:17:40 localhost kernel: net eth0: firmware hang detected
Nov  3 22:17:40 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:17:40 localhost firmware.sh[5879]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:17:40 localhost firmware.sh[5889]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:17:40 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:17:47 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:17:47 localhost kernel: type=1305 audit(1257315467.455:60901): auid=4294967295 ses=4294967295 op="remove rule" key=(null) list=2 res=1
Nov  3 22:17:47 localhost kernel: type=1305 audit(1257315467.455:60902): audit_enabled=0 old=1 auid=4294967295 ses=4294967295 res=1
Nov  3 22:17:57 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:17:57 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:17:57 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:18:01 localhost dhclient: dhclient(2896) is already running - exiting. 
Nov  3 22:18:01 localhost dhclient: 
Nov  3 22:18:01 localhost dhclient: This version of ISC DHCP is based on the release available
Nov  3 22:18:01 localhost dhclient: on ftp.isc.org.  Features have been added and other changes
Nov  3 22:18:01 localhost dhclient: have been made to the base software release in order to make
Nov  3 22:18:01 localhost dhclient: it work better with this distribution.
Nov  3 22:18:01 localhost dhclient: 
Nov  3 22:18:01 localhost dhclient: Please report for this software via the Red Hat Bugzilla site:
Nov  3 22:18:01 localhost dhclient:     http://bugzilla.redhat.com
Nov  3 22:18:01 localhost dhclient: 
Nov  3 22:18:01 localhost dhclient: exiting.
Nov  3 22:18:03 localhost kernel: net eth0: firmware hang detected
Nov  3 22:18:03 localhost kernel: net eth1: firmware hang detected
Nov  3 22:18:03 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:18:03 localhost firmware.sh[6012]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:18:03 localhost firmware.sh[6022]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:18:03 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:18:09 localhost dhclient: DHCPREQUEST on eth0 to 255.255.255.255 port 67
Nov  3 22:18:09 localhost dhclient: send_packet: Network is down
Nov  3 22:18:09 localhost dhclient: receive_packet failed on eth0: Network is down
Nov  3 22:18:10 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:18:20 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:18:20 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:18:20 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:18:26 localhost kernel: net eth1: firmware hang detected
Nov  3 22:18:26 localhost kernel: net eth0: firmware hang detected
Nov  3 22:18:26 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:18:26 localhost firmware.sh[6133]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:18:26 localhost firmware.sh[6143]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:18:26 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:18:33 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:18:43 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:18:43 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:18:43 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:18:49 localhost kernel: net eth0: firmware hang detected
Nov  3 22:18:49 localhost kernel: net eth1: firmware hang detected
Nov  3 22:18:49 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:18:49 localhost firmware.sh[6155]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:18:49 localhost firmware.sh[6165]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:18:49 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:18:55 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:19:06 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:19:06 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:19:06 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:19:10 localhost kernel: ADDRCONF(NETDEV_UP): eth0: link is not ready
Nov  3 22:19:10 localhost dhclient: DHCPREQUEST on eth0 to 255.255.255.255 port 67
Nov  3 22:19:10 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:19:10 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
Nov  3 22:19:11 localhost avahi-daemon[5377]: Registering new address record for fe80::20e:1eff:fe00:7756 on eth0.*.
Nov  3 22:19:12 localhost kernel: net eth1: firmware hang detected
Nov  3 22:19:12 localhost kernel: net eth0: firmware hang detected
Nov  3 22:19:12 localhost firmware.sh[6241]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:19:12 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:19:12 localhost firmware.sh[6251]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:19:12 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:19:13 localhost ntpd[5656]: Listening on interface #4 eth0, fe80::20e:1eff:fe00:7756#123 Enabled
Nov  3 22:19:15 localhost dhclient: DHCPREQUEST on eth0 to 255.255.255.255 port 67
Nov  3 22:19:18 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:19:24 localhost dhclient: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 6
Nov  3 22:19:29 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:19:29 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:19:29 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:19:30 localhost dhclient: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 9
Nov  3 22:19:31 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:19:35 localhost kernel: net eth0: firmware hang detected
Nov  3 22:19:35 localhost kernel: net eth1: firmware hang detected
Nov  3 22:19:35 localhost firmware.sh[6266]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:19:35 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:19:35 localhost firmware.sh[6276]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:19:35 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:19:39 localhost dhclient: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 12
Nov  3 22:19:41 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:19:51 localhost dhclient: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 21
Nov  3 22:19:51 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:19:51 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:19:51 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:19:54 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:19:57 localhost kernel: net eth1: firmware hang detected
Nov  3 22:19:58 localhost kernel: net eth0: firmware hang detected
Nov  3 22:19:58 localhost firmware.sh[6290]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:19:58 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:19:58 localhost firmware.sh[6300]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:19:58 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:19:59 localhost kernel: device eth0 entered promiscuous mode
Nov  3 22:20:04 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:20:10 localhost kernel: device eth0 left promiscuous mode
Nov  3 22:20:12 localhost dhclient: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 13
Nov  3 22:20:14 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:20:14 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:20:14 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:20:17 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:20:19 localhost kernel: device eth0 entered promiscuous mode
Nov  3 22:20:21 localhost kernel: net eth0: firmware hang detected
Nov  3 22:20:21 localhost kernel: net eth1: firmware hang detected
Nov  3 22:20:21 localhost firmware.sh[6347]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:20:21 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:20:21 localhost firmware.sh[6357]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:20:21 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:20:25 localhost dhclient: No DHCPOFFERS received.
Nov  3 22:20:25 localhost dhclient: Trying recorded lease 172.17.18.38
Nov  3 22:20:25 localhost avahi-daemon[5377]: Joining mDNS multicast group on interface eth0.IPv4 with address 172.17.18.38.
Nov  3 22:20:25 localhost avahi-daemon[5377]: New relevant interface eth0.IPv4 for mDNS.
Nov  3 22:20:25 localhost avahi-daemon[5377]: Registering new address record for 172.17.18.38 on eth0.IPv4.
Nov  3 22:20:26 localhost ntpd[5656]: Listening on interface #5 eth0, 172.17.18.38#123 Enabled
Nov  3 22:20:27 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:20:28 localhost avahi-daemon[5377]: Withdrawing address record for 172.17.18.38 on eth0.
Nov  3 22:20:28 localhost avahi-daemon[5377]: Leaving mDNS multicast group on interface eth0.IPv4 with address 172.17.18.38.
Nov  3 22:20:28 localhost avahi-daemon[5377]: Interface eth0.IPv4 no longer relevant for mDNS.
Nov  3 22:20:28 localhost avahi-daemon[5377]: Withdrawing address record for fe80::20e:1eff:fe00:7756 on eth0.
Nov  3 22:20:28 localhost dhclient: No working leases in persistent database - sleeping.
Nov  3 22:20:28 localhost dhclient: receive_packet failed on eth0: Network is down
Nov  3 22:20:29 localhost ntpd[5656]: Deleting interface #4 eth0, fe80::20e:1eff:fe00:7756#123, interface stats: received=0, sent=0, dropped=0, active_time=76 secs
Nov  3 22:20:29 localhost ntpd[5656]: Deleting interface #5 eth0, 172.17.18.38#123, interface stats: received=0, sent=0, dropped=0, active_time=3 secs
Nov  3 22:20:37 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:20:37 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:20:37 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:20:43 localhost kernel: net eth1: firmware hang detected
Nov  3 22:20:43 localhost kernel: net eth0: firmware hang detected
Nov  3 22:20:43 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:20:43 localhost firmware.sh[6435]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:20:43 localhost firmware.sh[6445]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:20:43 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:20:50 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:21:00 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:21:00 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:21:00 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:21:06 localhost kernel: net eth0: firmware hang detected
Nov  3 22:21:06 localhost kernel: net eth1: firmware hang detected
Nov  3 22:21:06 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:21:06 localhost firmware.sh[6497]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:21:06 localhost firmware.sh[6507]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:21:06 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:21:13 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:21:23 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:21:23 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:21:23 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:21:29 localhost kernel: net eth1: firmware hang detected
Nov  3 22:21:29 localhost kernel: net eth0: firmware hang detected
Nov  3 22:21:29 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:21:29 localhost firmware.sh[6520]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:21:29 localhost firmware.sh[6530]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:21:29 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:21:36 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:21:46 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:21:46 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:21:46 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:21:46 localhost kernel: ADDRCONF(NETDEV_UP): eth0: link is not ready
Nov  3 22:21:48 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:21:48 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
Nov  3 22:21:49 localhost avahi-daemon[5377]: Registering new address record for fe80::20e:1eff:fe00:7756 on eth0.*.
Nov  3 22:21:51 localhost ntpd[5656]: Listening on interface #6 eth0, fe80::20e:1eff:fe00:7756#123 Enabled
Nov  3 22:21:52 localhost kernel: net eth0: firmware hang detected
Nov  3 22:21:52 localhost kernel: net eth1: firmware hang detected
Nov  3 22:21:52 localhost firmware.sh[6543]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:21:52 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:21:52 localhost firmware.sh[6553]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:21:52 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:21:59 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:22:09 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:22:09 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:22:09 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:22:11 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:22:15 localhost kernel: net eth1: firmware hang detected
Nov  3 22:22:15 localhost kernel: net eth0: firmware hang detected
Nov  3 22:22:15 localhost firmware.sh[6600]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:22:15 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:22:15 localhost firmware.sh[6610]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:22:15 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:22:22 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:22:32 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:22:32 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:22:32 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:22:34 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:22:38 localhost kernel: net eth0: firmware hang detected
Nov  3 22:22:38 localhost kernel: net eth1: firmware hang detected
Nov  3 22:22:38 localhost firmware.sh[6620]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:22:38 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:22:38 localhost firmware.sh[6630]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:22:38 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:22:45 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:22:55 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:22:55 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:22:55 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:22:57 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:23:01 localhost kernel: net eth1: firmware hang detected
Nov  3 22:23:01 localhost kernel: net eth0: firmware hang detected
Nov  3 22:23:01 localhost firmware.sh[6641]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:23:01 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:23:01 localhost firmware.sh[6651]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:23:01 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:23:08 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:23:18 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:23:18 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:23:18 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:23:20 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:23:24 localhost kernel: net eth0: firmware hang detected
Nov  3 22:23:24 localhost kernel: net eth1: firmware hang detected
Nov  3 22:23:24 localhost firmware.sh[6696]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:23:24 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:23:24 localhost firmware.sh[6706]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:23:24 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:23:31 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:23:41 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:23:41 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:23:41 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:23:43 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:23:47 localhost kernel: net eth1: firmware hang detected
Nov  3 22:23:47 localhost kernel: net eth0: firmware hang detected
Nov  3 22:23:47 localhost firmware.sh[6716]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:23:47 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:23:47 localhost firmware.sh[6726]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:23:47 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:23:50 localhost avahi-daemon[5377]: Joining mDNS multicast group on interface eth0.IPv4 with address 172.17.18.38.
Nov  3 22:23:50 localhost avahi-daemon[5377]: New relevant interface eth0.IPv4 for mDNS.
Nov  3 22:23:50 localhost avahi-daemon[5377]: Registering new address record for 172.17.18.38 on eth0.IPv4.
Nov  3 22:23:50 localhost avahi-daemon[5377]: Withdrawing address record for 172.17.18.38 on eth0.
Nov  3 22:23:50 localhost avahi-daemon[5377]: Leaving mDNS multicast group on interface eth0.IPv4 with address 172.17.18.38.
Nov  3 22:23:50 localhost avahi-daemon[5377]: Interface eth0.IPv4 no longer relevant for mDNS.
Nov  3 22:23:50 localhost avahi-daemon[5377]: Joining mDNS multicast group on interface eth0.IPv4 with address 172.17.18.38.
Nov  3 22:23:50 localhost avahi-daemon[5377]: New relevant interface eth0.IPv4 for mDNS.
Nov  3 22:23:50 localhost avahi-daemon[5377]: Registering new address record for 172.17.18.38 on eth0.IPv4.
Nov  3 22:23:52 localhost ntpd[5656]: Listening on interface #7 eth0, 172.17.18.38#123 Enabled
Nov  3 22:23:54 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:24:04 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:24:04 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:24:04 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:24:06 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:24:10 localhost kernel: net eth0: firmware hang detected
Nov  3 22:24:10 localhost kernel: net eth1: firmware hang detected
Nov  3 22:24:10 localhost firmware.sh[6775]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:24:10 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:24:10 localhost firmware.sh[6785]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:24:10 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:24:17 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:24:27 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:24:27 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:24:27 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:24:29 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:24:33 localhost kernel: net eth1: firmware hang detected
Nov  3 22:24:33 localhost kernel: net eth0: firmware hang detected
Nov  3 22:24:33 localhost firmware.sh[6797]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:24:33 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:24:33 localhost firmware.sh[6807]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:24:33 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:24:40 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:24:50 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:24:50 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:24:50 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:24:52 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:24:56 localhost kernel: net eth0: firmware hang detected
Nov  3 22:24:56 localhost kernel: net eth1: firmware hang detected
Nov  3 22:24:56 localhost firmware.sh[6824]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:24:56 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:24:56 localhost firmware.sh[6834]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:24:56 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:25:03 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:25:13 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:25:13 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:25:13 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:25:15 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:25:19 localhost kernel: net eth1: firmware hang detected
Nov  3 22:25:19 localhost kernel: net eth0: firmware hang detected
Nov  3 22:25:19 localhost firmware.sh[6875]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:25:19 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:25:19 localhost firmware.sh[6885]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:25:19 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:25:26 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:25:36 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:25:36 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:25:36 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:25:38 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:25:42 localhost kernel: net eth0: firmware hang detected
Nov  3 22:25:42 localhost kernel: net eth1: firmware hang detected
Nov  3 22:25:42 localhost firmware.sh[6899]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:25:42 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:25:42 localhost firmware.sh[6909]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:25:42 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:25:49 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:25:59 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:25:59 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:25:59 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:26:01 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:26:05 localhost kernel: net eth1: firmware hang detected
Nov  3 22:26:05 localhost kernel: net eth0: firmware hang detected
Nov  3 22:26:05 localhost firmware.sh[6950]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:26:05 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:26:05 localhost firmware.sh[6960]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:26:05 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:26:12 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:26:22 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:26:22 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:26:22 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:26:24 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:26:28 localhost kernel: net eth0: firmware hang detected
Nov  3 22:26:28 localhost kernel: net eth1: firmware hang detected
Nov  3 22:26:28 localhost firmware.sh[6976]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:26:28 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:26:28 localhost firmware.sh[6986]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:26:28 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:26:34 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:26:45 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:26:45 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:26:45 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:26:47 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:26:51 localhost kernel: net eth1: firmware hang detected
Nov  3 22:26:51 localhost kernel: net eth0: firmware hang detected
Nov  3 22:26:51 localhost firmware.sh[7001]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:26:51 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:26:51 localhost firmware.sh[7011]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:26:51 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:26:57 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:27:08 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:27:08 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:27:08 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:27:10 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:27:14 localhost kernel: net eth0: firmware hang detected
Nov  3 22:27:14 localhost kernel: net eth1: firmware hang detected
Nov  3 22:27:14 localhost firmware.sh[7054]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:27:14 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:27:14 localhost firmware.sh[7064]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:27:14 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:27:17 localhost dhclient: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 3
Nov  3 22:27:20 localhost dhclient: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 8
Nov  3 22:27:20 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:27:28 localhost dhclient: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 15
Nov  3 22:27:31 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:27:31 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:27:31 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:27:33 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:27:37 localhost kernel: net eth1: firmware hang detected
Nov  3 22:27:37 localhost kernel: net eth0: firmware hang detected
Nov  3 22:27:37 localhost firmware.sh[7078]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:27:37 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:27:37 localhost firmware.sh[7088]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:27:37 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:27:43 localhost dhclient: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 18
Nov  3 22:27:43 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:27:54 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:27:54 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:27:54 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:27:56 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:28:00 localhost kernel: net eth0: firmware hang detected
Nov  3 22:28:00 localhost kernel: net eth1: firmware hang detected
Nov  3 22:28:00 localhost firmware.sh[7098]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:28:00 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:28:00 localhost firmware.sh[7108]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:28:00 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:28:01 localhost dhclient: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 11
Nov  3 22:28:06 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:28:12 localhost dhclient: DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 6
Nov  3 22:28:17 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:28:17 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:28:17 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:28:18 localhost dhclient: No DHCPOFFERS received.
Nov  3 22:28:18 localhost dhclient: Trying recorded lease 172.17.18.38
Nov  3 22:28:19 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:28:19 localhost avahi-daemon[5377]: Withdrawing address record for 172.17.18.38 on eth0.
Nov  3 22:28:19 localhost avahi-daemon[5377]: Leaving mDNS multicast group on interface eth0.IPv4 with address 172.17.18.38.
Nov  3 22:28:19 localhost avahi-daemon[5377]: Interface eth0.IPv4 no longer relevant for mDNS.
Nov  3 22:28:19 localhost avahi-daemon[5377]: Withdrawing address record for fe80::20e:1eff:fe00:7756 on eth0.
Nov  3 22:28:19 localhost dhclient: No working leases in persistent database - sleeping.
Nov  3 22:28:19 localhost dhclient: receive_packet failed on eth0: Network is down
Nov  3 22:28:20 localhost ntpd[5656]: Deleting interface #6 eth0, fe80::20e:1eff:fe00:7756#123, interface stats: received=0, sent=0, dropped=0, active_time=389 secs
Nov  3 22:28:20 localhost ntpd[5656]: Deleting interface #7 eth0, 172.17.18.38#123, interface stats: received=0, sent=0, dropped=0, active_time=268 secs
Nov  3 22:28:23 localhost kernel: net eth1: firmware hang detected
Nov  3 22:28:23 localhost kernel: net eth0: firmware hang detected
Nov  3 22:28:23 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:28:23 localhost firmware.sh[7181]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:28:23 localhost firmware.sh[7191]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:28:23 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:28:29 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:28:40 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:28:40 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:28:40 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:28:46 localhost kernel: net eth0: firmware hang detected
Nov  3 22:28:46 localhost kernel: net eth1: firmware hang detected
Nov  3 22:28:46 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:28:46 localhost firmware.sh[7207]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:28:46 localhost firmware.sh[7217]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:28:46 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:28:52 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:29:02 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:29:02 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:29:02 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:29:08 localhost kernel: net eth1: firmware hang detected
Nov  3 22:29:08 localhost kernel: net eth0: firmware hang detected
Nov  3 22:29:08 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:29:08 localhost firmware.sh[7262]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:29:08 localhost firmware.sh[7272]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:29:08 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:29:15 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:29:25 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:29:25 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:29:25 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:29:31 localhost kernel: net eth0: firmware hang detected
Nov  3 22:29:31 localhost kernel: net eth1: firmware hang detected
Nov  3 22:29:31 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:29:31 localhost firmware.sh[7282]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:29:31 localhost firmware.sh[7292]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:29:31 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:29:38 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:29:48 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:29:48 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:29:48 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:29:54 localhost kernel: net eth1: firmware hang detected
Nov  3 22:29:54 localhost kernel: net eth0: firmware hang detected
Nov  3 22:29:54 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:29:54 localhost firmware.sh[7306]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:29:54 localhost firmware.sh[7316]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:29:54 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:30:01 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:30:11 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:30:11 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:30:11 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:30:17 localhost kernel: net eth0: firmware hang detected
Nov  3 22:30:17 localhost kernel: net eth1: firmware hang detected
Nov  3 22:30:17 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:30:17 localhost firmware.sh[7363]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:30:17 localhost firmware.sh[7373]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:30:17 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:30:24 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:30:34 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:30:34 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:30:34 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:30:40 localhost kernel: net eth1: firmware hang detected
Nov  3 22:30:40 localhost kernel: net eth0: firmware hang detected
Nov  3 22:30:40 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:30:40 localhost firmware.sh[7388]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:30:40 localhost firmware.sh[7398]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:30:40 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:30:47 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:30:57 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:30:57 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:30:57 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:30:58 localhost avahi-daemon[5377]: Joining mDNS multicast group on interface eth0.IPv4 with address 172.17.18.38.
Nov  3 22:30:58 localhost avahi-daemon[5377]: New relevant interface eth0.IPv4 for mDNS.
Nov  3 22:30:58 localhost kernel: ADDRCONF(NETDEV_UP): eth0: link is not ready
Nov  3 22:30:58 localhost avahi-daemon[5377]: Registering new address record for 172.17.18.38 on eth0.IPv4.
Nov  3 22:30:59 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:30:59 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
Nov  3 22:31:00 localhost avahi-daemon[5377]: Registering new address record for fe80::20e:1eff:fe00:7756 on eth0.*.
Nov  3 22:31:01 localhost ntpd[5656]: Listening on interface #8 eth0, fe80::20e:1eff:fe00:7756#123 Enabled
Nov  3 22:31:01 localhost ntpd[5656]: Listening on interface #9 eth0, 172.17.18.38#123 Enabled
Nov  3 22:31:03 localhost kernel: net eth0: firmware hang detected
Nov  3 22:31:03 localhost kernel: net eth1: firmware hang detected
Nov  3 22:31:03 localhost firmware.sh[7447]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:31:03 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:31:03 localhost firmware.sh[7457]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:31:03 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:31:09 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:31:20 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:31:20 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:31:20 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:31:22 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:31:26 localhost kernel: net eth1: firmware hang detected
Nov  3 22:31:26 localhost kernel: net eth0: firmware hang detected
Nov  3 22:31:26 localhost firmware.sh[7480]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:31:26 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:31:26 localhost firmware.sh[7490]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:31:26 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:31:32 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:31:43 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:31:43 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:31:43 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:31:45 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:31:49 localhost kernel: net eth0: firmware hang detected
Nov  3 22:31:49 localhost kernel: net eth1: firmware hang detected
Nov  3 22:31:49 localhost firmware.sh[7504]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:31:49 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:31:49 localhost firmware.sh[7514]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:31:49 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:31:55 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:32:06 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:32:06 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:32:06 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:32:08 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:32:12 localhost kernel: net eth1: firmware hang detected
Nov  3 22:32:12 localhost kernel: net eth0: firmware hang detected
Nov  3 22:32:12 localhost firmware.sh[7559]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:32:12 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:32:12 localhost firmware.sh[7569]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:32:12 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:32:18 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:32:29 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:32:29 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:32:29 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:32:31 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:32:35 localhost kernel: net eth0: firmware hang detected
Nov  3 22:32:35 localhost kernel: net eth1: firmware hang detected
Nov  3 22:32:35 localhost firmware.sh[7579]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:32:35 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:32:35 localhost firmware.sh[7589]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:32:35 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:32:41 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:32:52 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:32:52 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:32:52 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:32:54 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:32:58 localhost kernel: net eth1: firmware hang detected
Nov  3 22:32:58 localhost kernel: net eth0: firmware hang detected
Nov  3 22:32:58 localhost firmware.sh[7599]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:32:58 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:32:58 localhost firmware.sh[7609]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:32:58 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:33:04 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:33:15 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:33:15 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:33:15 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:33:17 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:33:21 localhost kernel: net eth0: firmware hang detected
Nov  3 22:33:21 localhost kernel: net eth1: firmware hang detected
Nov  3 22:33:21 localhost firmware.sh[7655]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:33:21 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwmn.bin
Nov  3 22:33:21 localhost firmware.sh[7665]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:33:21 localhost kernel: netxen_nic 0000:06:00.1: firmware: requesting nx3fwct.bin
Nov  3 22:33:27 localhost kernel: netxen_nic 0000:06:00.1: loading firmware from flash
Nov  3 22:33:38 localhost kernel: netxen_nic 0000:06:00.1: firmware v4.0.305 [cut-through]
Nov  3 22:33:38 localhost kernel: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Nov  3 22:33:38 localhost kernel: netxen_nic 0000:06:00.0: firmware v4.0.305 [cut-through]
Nov  3 22:33:40 localhost kernel: netxen_nic: eth0 NIC Link is up
Nov  3 22:33:44 localhost kernel: net eth1: firmware hang detected
Nov  3 22:33:44 localhost kernel: net eth0: firmware hang detected
Nov  3 22:33:44 localhost firmware.sh[7675]: Cannot find  firmware file 'nx3fwmn.bin'
Nov  3 22:33:44 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwmn.bin
Nov  3 22:33:44 localhost firmware.sh[7685]: Cannot find  firmware file 'nx3fwct.bin'
Nov  3 22:33:44 localhost kernel: netxen_nic 0000:06:00.0: firmware: requesting nx3fwct.bin
Nov  3 22:33:50 localhost kernel: netxen_nic 0000:06:00.0: loading firmware from flash
Nov  3 22:33:55 localhost init: tty1 main process (5856) killed by TERM signal
Nov  3 22:33:55 localhost avahi-daemon[5377]: Got SIGTERM, quitting.
Nov  3 22:33:55 localhost avahi-daemon[5377]: Leaving mDNS multicast group on interface eth0.IPv4 with address 172.17.18.38.
Nov  3 22:33:55 localhost mountd[5709]: Caught signal 15, un-registering and exiting.
Nov  3 22:33:55 localhost kernel: nfsd: last server has exited, flushing export cache
Nov  3 22:33:56 localhost xinetd[5639]: Exiting...
Nov  3 22:33:56 localhost acpid: exiting
Nov  3 22:33:56 localhost ntpd[5656]: ntpd exiting on signal 15
Nov  3 22:33:56 localhost pcscd: pcscdaemon.c:581:signal_trap() Preparing for suicide
Nov  3 22:33:57 localhost pcscd: readerfactory.c:1242:RFCleanupReaders() entering cleaning function
Nov  3 22:33:57 localhost pcscd: pcscdaemon.c:531:at_exit() cleaning /var/run
Nov  3 22:33:57 localhost bluetoothd[5585]: bridge pan0 removed
Nov  3 22:33:57 localhost bluetoothd[5585]: Stopping SDP server
Nov  3 22:33:57 localhost bluetoothd[5585]: Exit
Nov  3 22:33:57 localhost rpc.statd[3009]: Caught signal 15, un-registering and exiting.
Nov  3 22:33:58 localhost rpcbind: rpcbind terminating on signal. Restart with "rpcbind -w"

--=-=-=--
