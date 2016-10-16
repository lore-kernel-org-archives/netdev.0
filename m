From: Billes Tibor <tbilles@gmx.com>
Subject: Intel Wireless 7260 Microcode SW error detected
Date: Sun, 16 Oct 2016 20:08:54 +0200
Message-ID: <41dbbe14-3098-551d-6c34-0a3654bafca9@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johannes.berg@intel.com, emmanuel.grumbach@intel.com,
        luciano.coelho@intel.com, kvalo@codeaurora.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linuxwifi@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:49822 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756931AbcJPSJU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 16 Oct 2016 14:09:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have Lenovo laptop with an Intel Wireless 7260 wifi module and the 
latest stable kernel 4.8.1. I was playing a movie from an sshfs mounted 
file system, when the movie just froze and my network stopped working. 
Dmesg said 'Microcode SW error detected'. Below is my full `dmesg -r` 
output. I probably will not be able to reproduce this behaviour, because 
it did not happen in the past, and it seems to work fine after reboot.

Is there anything more that I can do to help you debug this?

Tibor Billes


dmesg -r
<5>[    0.000000] Linux version 4.8.1 (tbilles@serpens) (gcc version 
5.4.0 20160609 (Ubuntu 5.4.0-6ubuntu1~16.04.2) ) #63 SMP Tue Oct 11 
21:07:05 CEST 2016
<6>[    0.000000] Command line: BOOT_IMAGE=/vmlinuz-4.8.1 
root=UUID=cb7645e0-6fe2-4d11-b9d1-e3cad8a4ba6b ro quiet splash vt.handoff=7
<6>[    0.000000] KERNEL supported cpus:
<6>[    0.000000]   Intel GenuineIntel
<6>[    0.000000] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating 
point registers'
<6>[    0.000000] x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
<6>[    0.000000] x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
<6>[    0.000000] x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
<6>[    0.000000] x86/fpu: Enabled xstate features 0x7, context size is 
832 bytes, using 'standard' format.
<6>[    0.000000] x86/fpu: Using 'eager' FPU context switches.
<6>[    0.000000] e820: BIOS-provided physical RAM map:
<6>[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009d3ff] 
usable
<6>[    0.000000] BIOS-e820: [mem 0x000000000009d400-0x000000000009ffff] 
reserved
<6>[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] 
reserved
<6>[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000076a6ffff] 
usable
<6>[    0.000000] BIOS-e820: [mem 0x0000000076a70000-0x0000000077e6ffff] 
reserved
<6>[    0.000000] BIOS-e820: [mem 0x0000000077e70000-0x000000009cabefff] 
usable
<6>[    0.000000] BIOS-e820: [mem 0x000000009cabf000-0x000000009cebefff] 
reserved
<6>[    0.000000] BIOS-e820: [mem 0x000000009cebf000-0x000000009cfbefff] 
ACPI NVS
<6>[    0.000000] BIOS-e820: [mem 0x000000009cfbf000-0x000000009cffefff] 
ACPI data
<6>[    0.000000] BIOS-e820: [mem 0x000000009cfff000-0x000000009cffffff] 
usable
<6>[    0.000000] BIOS-e820: [mem 0x000000009d000000-0x000000009f9fffff] 
reserved
<6>[    0.000000] BIOS-e820: [mem 0x00000000e0000000-0x00000000efffffff] 
reserved
<6>[    0.000000] BIOS-e820: [mem 0x00000000feb00000-0x00000000feb0ffff] 
reserved
<6>[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] 
reserved
<6>[    0.000000] BIOS-e820: [mem 0x00000000fed00000-0x00000000fee00fff] 
reserved
<6>[    0.000000] BIOS-e820: [mem 0x00000000ff980000-0x00000000ffffffff] 
reserved
<6>[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000015f5fffff] 
usable
<6>[    0.000000] NX (Execute Disable) protection: active
<6>[    0.000000] SMBIOS 2.7 present.
<7>[    0.000000] DMI: LENOVO 20378/Lenovo Y50-70, BIOS 9ECN36WW(V2.00) 
01/12/2015
<7>[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> 
reserved
<7>[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
<6>[    0.000000] e820: last_pfn = 0x15f600 max_arch_pfn = 0x400000000
<7>[    0.000000] MTRR default type: uncachable
<7>[    0.000000] MTRR fixed ranges enabled:
<7>[    0.000000]   00000-9FFFF write-back
<7>[    0.000000]   A0000-BFFFF uncachable
<7>[    0.000000]   C0000-E7FFF write-protect
<7>[    0.000000]   E8000-EFFFF write-combining
<7>[    0.000000]   F0000-FFFFF write-protect
<7>[    0.000000] MTRR variable ranges enabled:
<7>[    0.000000]   0 base 0000000000 mask 7F80000000 write-back
<7>[    0.000000]   1 base 0080000000 mask 7FE0000000 write-back
<7>[    0.000000]   2 base 009D000000 mask 7FFF000000 uncachable
<7>[    0.000000]   3 base 009E000000 mask 7FFE000000 uncachable
<7>[    0.000000]   4 base 00FF800000 mask 7FFF800000 write-protect
<7>[    0.000000]   5 base 0100000000 mask 7F80000000 write-back
<7>[    0.000000]   6 base 015F600000 mask 7FFFE00000 uncachable
<7>[    0.000000]   7 base 015F800000 mask 7FFF800000 uncachable
<7>[    0.000000]   8 base 0160000000 mask 7FE0000000 uncachable
<7>[    0.000000]   9 disabled
<6>[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  
UC- WT
<6>[    0.000000] e820: last_pfn = 0x9d000 max_arch_pfn = 0x400000000
<6>[    0.000000] Scanning 1 areas for low memory corruption
<7>[    0.000000] Base memory trampoline at [ffff964c80097000] 97000 
size 24576
<6>[    0.000000] Using GB pages for direct mapping
<7>[    0.000000] BRK [0x22f8d000, 0x22f8dfff] PGTABLE
<7>[    0.000000] BRK [0x22f8e000, 0x22f8efff] PGTABLE
<7>[    0.000000] BRK [0x22f8f000, 0x22f8ffff] PGTABLE
<7>[    0.000000] BRK [0x22f90000, 0x22f90fff] PGTABLE
<7>[    0.000000] BRK [0x22f91000, 0x22f91fff] PGTABLE
<7>[    0.000000] BRK [0x22f92000, 0x22f92fff] PGTABLE
<7>[    0.000000] BRK [0x22f93000, 0x22f93fff] PGTABLE
<7>[    0.000000] BRK [0x22f94000, 0x22f94fff] PGTABLE
<7>[    0.000000] BRK [0x22f95000, 0x22f95fff] PGTABLE
<6>[    0.000000] RAMDISK: [mem 0x31576000-0x34ab2fff]
<6>[    0.000000] ACPI: Early table checksum verification disabled
<4>[    0.000000] ACPI: RSDP 0x00000000000FE020 000024 (v02 LENOVO)
<4>[    0.000000] ACPI: XSDT 0x000000009CFFE210 0000AC (v01 LENOVO 
CB-01    00000001      01000013)
<4>[    0.000000] ACPI: FACP 0x000000009CFF8000 00010C (v05 LENOVO 
CB-01    00000001 ACPI 00040000)
<4>[    0.000000] ACPI: DSDT 0x000000009CFEA000 00ABB0 (v01 LENOVO 
CB-01    00000001 ACPI 00040000)
<4>[    0.000000] ACPI: FACS 0x000000009CFBA000 000040
<4>[    0.000000] ACPI: UEFI 0x000000009CFFD000 000236 (v01 LENOVO 
CB-01    00000001 ACPI 00040000)
<4>[    0.000000] ACPI: FPDT 0x000000009CFFB000 000044 (v01 LENOVO 
CB-01    00000001 ACPI 00040000)
<4>[    0.000000] ACPI: ASF! 0x000000009CFF9000 0000A5 (v32 LENOVO 
CB-01    00000001 ACPI 00040000)
<4>[    0.000000] ACPI: HPET 0x000000009CFF7000 000038 (v01 LENOVO 
CB-01    00000001 ACPI 00040000)
<4>[    0.000000] ACPI: APIC 0x000000009CFF6000 00008C (v03 LENOVO 
CB-01    00000001 ACPI 00040000)
<4>[    0.000000] ACPI: MCFG 0x000000009CFF5000 00003C (v01 LENOVO 
CB-01    00000001 ACPI 00040000)
<4>[    0.000000] ACPI: SSDT 0x000000009CFE7000 002028 (v01 LENOVO 
CB-01    00000001 ACPI 00040000)
<4>[    0.000000] ACPI: BOOT 0x000000009CFE5000 000028 (v01 LENOVO 
CB-01    00000001 ACPI 00040000)
<4>[    0.000000] ACPI: LPIT 0x000000009CFE4000 000094 (v01 LENOVO 
CB-01    00000001 ACPI 00040000)
<4>[    0.000000] ACPI: ASPT 0x000000009CFE2000 000034 (v07 LENOVO 
CB-01    00000001 ACPI 00040000)
<4>[    0.000000] ACPI: DBGP 0x000000009CFE1000 000034 (v01 LENOVO 
CB-01    00000001 ACPI 00040000)
<4>[    0.000000] ACPI: SSDT 0x000000009CFE0000 000539 (v01 LENOVO 
CB-01    00000001 ACPI 00040000)
<4>[    0.000000] ACPI: SSDT 0x000000009CFDF000 000AD8 (v01 LENOVO 
CB-01    00000001 ACPI 00040000)
<4>[    0.000000] ACPI: SSDT 0x000000009CFDB000 00348C (v01 LENOVO 
CB-01    00000001 ACPI 00040000)
<4>[    0.000000] ACPI: SSDT 0x000000009CFD5000 003E76 (v01 LENOVO 
CB-01    00000001 ACPI 00040000)
<4>[    0.000000] ACPI: DMAR 0x000000009CFD9000 0000B8 (v01 LENOVO 
CB-01    00000001 ACPI 00040000)
<7>[    0.000000] ACPI: Local APIC address 0xfee00000
<6>[    0.000000] Zone ranges:
<6>[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
<6>[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
<6>[    0.000000]   Normal   [mem 0x0000000100000000-0x000000015f5fffff]
<6>[    0.000000] Movable zone start for each node
<6>[    0.000000] Early memory node ranges
<6>[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009cfff]
<6>[    0.000000]   node   0: [mem 0x0000000000100000-0x0000000076a6ffff]
<6>[    0.000000]   node   0: [mem 0x0000000077e70000-0x000000009cabefff]
<6>[    0.000000]   node   0: [mem 0x000000009cfff000-0x000000009cffffff]
<6>[    0.000000]   node   0: [mem 0x0000000100000000-0x000000015f5fffff]
<6>[    0.000000] Initmem setup node 0 [mem 
0x0000000000001000-0x000000015f5fffff]
<7>[    0.000000] On node 0 totalpages: 1027164
<7>[    0.000000]   DMA zone: 64 pages used for memmap
<7>[    0.000000]   DMA zone: 21 pages reserved
<7>[    0.000000]   DMA zone: 3996 pages, LIFO batch:0
<7>[    0.000000]   DMA32 zone: 9883 pages used for memmap
<7>[    0.000000]   DMA32 zone: 632512 pages, LIFO batch:31
<7>[    0.000000]   Normal zone: 6104 pages used for memmap
<7>[    0.000000]   Normal zone: 390656 pages, LIFO batch:31
<6>[    0.000000] Reserving Intel graphics memory at 
0x000000009da00000-0x000000009f9fffff
<6>[    0.000000] ACPI: PM-Timer IO Port: 0x1808
<7>[    0.000000] ACPI: Local APIC address 0xfee00000
<6>[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, 
GSI 0-23
<6>[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
<6>[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high 
level)
<7>[    0.000000] ACPI: IRQ0 used by override.
<7>[    0.000000] ACPI: IRQ9 used by override.
<6>[    0.000000] Using ACPI (MADT) for SMP configuration information
<6>[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
<6>[    0.000000] smpboot: Allowing 8 CPUs, 0 hotplug CPUs
<6>[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x0009d000-0x0009dfff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009ffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x76a70000-0x77e6ffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x9cabf000-0x9cebefff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x9cebf000-0x9cfbefff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x9cfbf000-0x9cffefff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x9d000000-0x9f9fffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0x9fa00000-0xdfffffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xe0000000-0xefffffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xf0000000-0xfeafffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xfeb00000-0xfeb0ffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xfeb10000-0xfebfffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xfec00fff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xfec01000-0xfecfffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xfed00000-0xfee00fff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xfee01000-0xff97ffff]
<6>[    0.000000] PM: Registered nosave memory: [mem 0xff980000-0xffffffff]
<6>[    0.000000] e820: [mem 0x9fa00000-0xdfffffff] available for PCI 
devices
<6>[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff 
max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
<6>[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:8 
nr_node_ids:1
<6>[    0.000000] percpu: Embedded 34 pages/cpu @ffff964ddf200000 
s101208 r8192 d29864 u262144
<7>[    0.000000] pcpu-alloc: s101208 r8192 d29864 u262144 alloc=1*2097152
<7>[    0.000000] pcpu-alloc: [0] 0 1 2 3 4 5 6 7
<6>[    0.000000] Built 1 zonelists in Zone order, mobility grouping 
on.  Total pages: 1011092
<5>[    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-4.8.1 
root=UUID=cb7645e0-6fe2-4d11-b9d1-e3cad8a4ba6b ro quiet splash vt.handoff=7
<6>[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
<6>[    0.000000] Dentry cache hash table entries: 524288 (order: 10, 
4194304 bytes)
<6>[    0.000000] Inode-cache hash table entries: 262144 (order: 9, 
2097152 bytes)
<7>[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
<7>[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - 
bailing!
<6>[    0.000000] Memory: 3899148K/4108656K available (6874K kernel 
code, 1176K rwdata, 3168K rodata, 1244K init, 1172K bss, 209508K 
reserved, 0K cma-reserved)
<6>[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=1
<6>[    0.000000] Hierarchical RCU implementation.
<6>[    0.000000]     Build-time adjustment of leaf fanout to 64.
<6>[    0.000000] NR_IRQS:4352 nr_irqs:488 16
<6>[    0.000000] Console: colour dummy device 80x25
<6>[    0.000000] console [tty0] enabled
<6>[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 
0xffffffff, max_idle_ns: 133484882848 ns
<7>[    0.000000] hpet clockevent registered
<6>[    0.000000] tsc: Fast TSC calibration using PIT
<6>[    0.000000] tsc: Detected 2494.027 MHz processor
<6>[    0.000021] Calibrating delay loop (skipped), value calculated 
using timer frequency.. 4988.05 BogoMIPS (lpj=9976108)
<6>[    0.000023] pid_max: default: 32768 minimum: 301
<6>[    0.000031] ACPI: Core revision 20160422
<4>[    0.012356] ACPI: 6 ACPI AML tables successfully acquired and loaded

<6>[    0.012377] Security Framework initialized
<6>[    0.012377] Yama: becoming mindful.
<6>[    0.012384] AppArmor: AppArmor initialized
<6>[    0.012413] Mount-cache hash table entries: 8192 (order: 4, 65536 
bytes)
<6>[    0.012414] Mountpoint-cache hash table entries: 8192 (order: 4, 
65536 bytes)
<6>[    0.012626] CPU: Physical Processor ID: 0
<6>[    0.012627] CPU: Processor Core ID: 0
<4>[    0.012630] ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
<4>[    0.012631] ENERGY_PERF_BIAS: View and update with 
x86_energy_perf_policy(8)
<6>[    0.012634] mce: CPU supports 9 MCE banks
<6>[    0.012642] CPU0: Thermal monitoring enabled (TM1)
<6>[    0.012656] process: using mwait in idle threads
<6>[    0.012658] Last level iTLB entries: 4KB 1024, 2MB 1024, 4MB 1024
<6>[    0.012659] Last level dTLB entries: 4KB 1024, 2MB 1024, 4MB 1024, 
1GB 4
<6>[    0.012992] Freeing SMP alternatives memory: 28K (ffffffff94e5f000 
- ffffffff94e66000)
<6>[    0.016438] ftrace: allocating 27409 entries in 108 pages
<6>[    0.027484] smpboot: APIC(0) Converting physical 0 to logical 
package 0
<6>[    0.027485] smpboot: Max logical packages: 2
<6>[    0.027874] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
<7>[    0.067560] TSC deadline timer enabled
<6>[    0.067562] smpboot: CPU0: Intel(R) Core(TM) i7-4710HQ CPU @ 
2.50GHz (family: 0x6, model: 0x3c, stepping: 0x3)
<6>[    0.067565] Performance Events: PEBS fmt2+, Haswell events, 
16-deep LBR, full-width counters, Intel PMU driver.
<6>[    0.067599] ... version:                3
<6>[    0.067599] ... bit width:              48
<6>[    0.067600] ... generic registers:      4
<6>[    0.067600] ... value mask: 0000ffffffffffff
<6>[    0.067601] ... max period: 0000ffffffffffff
<6>[    0.067601] ... fixed-purpose events:   3
<6>[    0.067602] ... event mask: 000000070000000f
<6>[    0.068164] NMI watchdog: enabled on all CPUs, permanently 
consumes one hw-PMU counter.
<6>[    0.068222] x86: Booting SMP configuration:
<6>[    0.068223] .... node  #0, CPUs:      #1 #2 #3 #4 #5 #6 #7
<6>[    0.629752] x86: Booted up 1 node, 8 CPUs
<6>[    0.629754] smpboot: Total of 8 processors activated (39911.98 
BogoMIPS)
<6>[    0.636287] devtmpfs: initialized
<6>[    0.636402] evm: security.selinux
<6>[    0.636403] evm: security.SMACK64
<6>[    0.636403] evm: security.SMACK64EXEC
<6>[    0.636403] evm: security.SMACK64TRANSMUTE
<6>[    0.636404] evm: security.SMACK64MMAP
<6>[    0.636404] evm: security.ima
<6>[    0.636404] evm: security.capability
<6>[    0.636453] PM: Registering ACPI NVS region [mem 
0x9cebf000-0x9cfbefff] (1048576 bytes)
<6>[    0.636514] clocksource: jiffies: mask: 0xffffffff max_cycles: 
0xffffffff, max_idle_ns: 7645041785100000 ns
<6>[    0.636548] pinctrl core: initialized pinctrl subsystem
<6>[    0.636578] RTC time:  4:17:36, date: 10/15/16
<6>[    0.636648] NET: Registered protocol family 16
<6>[    0.652079] cpuidle: using governor ladder
<6>[    0.668090] cpuidle: using governor menu
<6>[    0.668114] Simple Boot Flag at 0x44 set to 0x1
<6>[    0.668120] ACPI FADT declares the system doesn't support PCIe 
ASPM, so disable it
<6>[    0.668121] ACPI: bus type PCI registered
<6>[    0.668122] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
<6>[    0.668172] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 
0xe0000000-0xefffffff] (base 0xe0000000)
<6>[    0.668173] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved 
in E820
<6>[    0.668182] PCI: Using configuration type 1 for base access
<6>[    0.668233] core: PMU erratum BJ122, BV98, HSD29 worked around, HT 
is on
<4>[    0.668378] mtrr: your CPUs had inconsistent variable MTRR settings
<6>[    0.668378] mtrr: probably your BIOS does not setup all CPUs.
<6>[    0.668379] mtrr: corrected configuration.
<6>[    0.684178] HugeTLB registered 1 GB page size, pre-allocated 0 pages
<6>[    0.684178] HugeTLB registered 2 MB page size, pre-allocated 0 pages
<6>[    0.684310] ACPI: Added _OSI(Module Device)
<6>[    0.684311] ACPI: Added _OSI(Processor Device)
<6>[    0.684311] ACPI: Added _OSI(3.0 _SCP Extensions)
<6>[    0.684312] ACPI: Added _OSI(Processor Aggregator Device)
<5>[    0.689055] ACPI: [Firmware Bug]: BIOS _OSI(Linux) query ignored
<4>[    0.690271] ACPI: Dynamic OEM Table Load:
<4>[    0.690278] ACPI: SSDT 0xFFFF964DD9E8D800 0003D3 (v01 PmRef  
Cpu0Cst  00003001 INTL 20120518)
<4>[    0.690887] ACPI: Dynamic OEM Table Load:
<4>[    0.690893] ACPI: SSDT 0xFFFF964DD9E96800 0005AA (v01 PmRef  
ApIst    00003000 INTL 20120518)
<4>[    0.691542] ACPI: Dynamic OEM Table Load:
<4>[    0.691546] ACPI: SSDT 0xFFFF964DD9EB6A00 000119 (v01 PmRef  
ApCst    00003000 INTL 20120518)
<6>[    0.693205] ACPI : EC: EC started
<6>[    0.892283] ACPI: Interpreter enabled
<6>[    0.892311] ACPI: (supports S0 S3 S4 S5)
<6>[    0.892312] ACPI: Using IOAPIC for interrupt routing
<6>[    0.892332] PCI: Using host bridge windows from ACPI; if 
necessary, use "pci=nocrs" and report a bug
<6>[    1.006591] ACPI: Power Resource [PG00] (on)
<6>[    1.006612] ACPI: Power Resource [NVP2] (on)
<6>[    1.009582] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-fe])
<6>[    1.009586] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig 
ASPM ClockPM Segments MSI]
<6>[    1.009700] acpi PNP0A08:00: _OSC failed (AE_ERROR); disabling ASPM
<6>[    1.010145] PCI host bridge to bus 0000:00
<6>[    1.010147] pci_bus 0000:00: root bus resource [io 0x0000-0x0cf7 
window]
<6>[    1.010148] pci_bus 0000:00: root bus resource [io 0x0d00-0xffff 
window]
<6>[    1.010149] pci_bus 0000:00: root bus resource [mem 
0x000a0000-0x000bffff window]
<6>[    1.010150] pci_bus 0000:00: root bus resource [mem 
0x9fa00000-0xfeafffff window]
<6>[    1.010151] pci_bus 0000:00: root bus resource [bus 00-fe]
<7>[    1.010157] pci 0000:00:00.0: [8086:0c04] type 00 class 0x060000
<7>[    1.010291] pci 0000:00:01.0: [8086:0c01] type 01 class 0x060400
<7>[    1.010321] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
<6>[    1.010446] pci 0000:00:01.0: System wakeup disabled by ACPI
<7>[    1.010480] pci 0000:00:02.0: [8086:0416] type 00 class 0x030000
<7>[    1.010488] pci 0000:00:02.0: reg 0x10: [mem 0xd1000000-0xd13fffff 
64bit]
<7>[    1.010493] pci 0000:00:02.0: reg 0x18: [mem 0xc0000000-0xcfffffff 
64bit pref]
<7>[    1.010496] pci 0000:00:02.0: reg 0x20: [io 0x5000-0x503f]
<7>[    1.010635] pci 0000:00:03.0: [8086:0c0c] type 00 class 0x040300
<7>[    1.010642] pci 0000:00:03.0: reg 0x10: [mem 0xd1710000-0xd1713fff 
64bit]
<7>[    1.010790] pci 0000:00:14.0: [8086:8c31] type 00 class 0x0c0330
<7>[    1.010806] pci 0000:00:14.0: reg 0x10: [mem 0xd1700000-0xd170ffff 
64bit]
<7>[    1.010864] pci 0000:00:14.0: PME# supported from D3hot D3cold
<6>[    1.010953] pci 0000:00:14.0: System wakeup disabled by ACPI
<7>[    1.010984] pci 0000:00:16.0: [8086:8c3a] type 00 class 0x078000
<7>[    1.011001] pci 0000:00:16.0: reg 0x10: [mem 0xd1718000-0xd171800f 
64bit]
<7>[    1.011060] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
<7>[    1.011186] pci 0000:00:1a.0: [8086:8c2d] type 00 class 0x0c0320
<7>[    1.011202] pci 0000:00:1a.0: reg 0x10: [mem 0xd171d000-0xd171d3ff]
<7>[    1.011280] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
<6>[    1.011385] pci 0000:00:1a.0: System wakeup disabled by ACPI
<7>[    1.011418] pci 0000:00:1b.0: [8086:8c20] type 00 class 0x040300
<7>[    1.011433] pci 0000:00:1b.0: reg 0x10: [mem 0xd1714000-0xd1717fff 
64bit]
<7>[    1.011497] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
<6>[    1.011589] pci 0000:00:1b.0: System wakeup disabled by ACPI
<7>[    1.011619] pci 0000:00:1c.0: [8086:8c10] type 01 class 0x060400
<7>[    1.011679] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
<6>[    1.011796] pci 0000:00:1c.0: System wakeup disabled by ACPI
<7>[    1.011827] pci 0000:00:1c.1: [8086:8c12] type 01 class 0x060400
<7>[    1.011887] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
<6>[    1.012003] pci 0000:00:1c.1: System wakeup disabled by ACPI
<7>[    1.012033] pci 0000:00:1c.2: [8086:8c14] type 01 class 0x060400
<7>[    1.012092] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
<7>[    1.012213] pci 0000:00:1c.4: [8086:8c18] type 01 class 0x060400
<7>[    1.012272] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
<6>[    1.012393] pci 0000:00:1c.4: System wakeup disabled by ACPI
<7>[    1.012430] pci 0000:00:1d.0: [8086:8c26] type 00 class 0x0c0320
<7>[    1.012446] pci 0000:00:1d.0: reg 0x10: [mem 0xd171c000-0xd171c3ff]
<7>[    1.012525] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
<6>[    1.012630] pci 0000:00:1d.0: System wakeup disabled by ACPI
<7>[    1.012662] pci 0000:00:1f.0: [8086:8c49] type 00 class 0x060100
<7>[    1.012870] pci 0000:00:1f.2: [8086:8c03] type 00 class 0x010601
<7>[    1.012883] pci 0000:00:1f.2: reg 0x10: [io 0x5088-0x508f]
<7>[    1.012889] pci 0000:00:1f.2: reg 0x14: [io 0x5094-0x5097]
<7>[    1.012896] pci 0000:00:1f.2: reg 0x18: [io 0x5080-0x5087]
<7>[    1.012903] pci 0000:00:1f.2: reg 0x1c: [io 0x5090-0x5093]
<7>[    1.012910] pci 0000:00:1f.2: reg 0x20: [io 0x5060-0x507f]
<7>[    1.012917] pci 0000:00:1f.2: reg 0x24: [mem 0xd171b000-0xd171b7ff]
<7>[    1.012950] pci 0000:00:1f.2: PME# supported from D3hot
<7>[    1.013065] pci 0000:00:1f.3: [8086:8c22] type 00 class 0x0c0500
<7>[    1.013077] pci 0000:00:1f.3: reg 0x10: [mem 0xd1719000-0xd17190ff 
64bit]
<7>[    1.013096] pci 0000:00:1f.3: reg 0x20: [io 0x5040-0x505f]
<7>[    1.013270] pci 0000:01:00.0: [10de:1392] type 00 class 0x030200
<7>[    1.013287] pci 0000:01:00.0: reg 0x10: [mem 0xd0000000-0xd0ffffff]
<7>[    1.013304] pci 0000:01:00.0: reg 0x14: [mem 0xa0000000-0xafffffff 
64bit pref]
<7>[    1.013320] pci 0000:01:00.0: reg 0x1c: [mem 0xb0000000-0xb1ffffff 
64bit pref]
<7>[    1.013331] pci 0000:01:00.0: reg 0x24: [io 0x4000-0x407f]
<7>[    1.013342] pci 0000:01:00.0: reg 0x30: [mem 0xfff80000-0xffffffff 
pref]
<6>[    1.013437] pci 0000:01:00.0: System wakeup disabled by ACPI
<6>[    1.013473] pci 0000:00:01.0: PCI bridge to [bus 01-06]
<7>[    1.013475] pci 0000:00:01.0:   bridge window [io 0x4000-0x4fff]
<7>[    1.013477] pci 0000:00:01.0:   bridge window [mem 
0xd0000000-0xd0ffffff]
<7>[    1.013479] pci 0000:00:01.0:   bridge window [mem 
0xa0000000-0xbfffffff 64bit pref]
<6>[    1.013521] pci 0000:00:1c.0: PCI bridge to [bus 07]
<7>[    1.013619] pci 0000:08:00.0: [8086:08b2] type 00 class 0x028000
<7>[    1.013673] pci 0000:08:00.0: reg 0x10: [mem 0xd1600000-0xd1601fff 
64bit]
<7>[    1.013904] pci 0000:08:00.0: PME# supported from D0 D3hot D3cold
<6>[    1.013969] pci 0000:08:00.0: System wakeup disabled by ACPI
<6>[    1.024338] pci 0000:00:1c.1: PCI bridge to [bus 08]
<7>[    1.024342] pci 0000:00:1c.1:   bridge window [mem 
0xd1600000-0xd16fffff]
<7>[    1.024404] pci 0000:09:00.0: [10ec:8168] type 00 class 0x020000
<7>[    1.024423] pci 0000:09:00.0: reg 0x10: [io 0x3000-0x30ff]
<7>[    1.024451] pci 0000:09:00.0: reg 0x18: [mem 0xd1504000-0xd1504fff 
64bit]
<7>[    1.024468] pci 0000:09:00.0: reg 0x20: [mem 0xd1500000-0xd1503fff 
64bit]
<7>[    1.024561] pci 0000:09:00.0: supports D1 D2
<7>[    1.024561] pci 0000:09:00.0: PME# supported from D0 D1 D2 D3hot 
D3cold
<6>[    1.024623] pci 0000:09:00.0: System wakeup disabled by ACPI
<6>[    1.036329] pci 0000:00:1c.2: PCI bridge to [bus 09]
<7>[    1.036332] pci 0000:00:1c.2:   bridge window [io 0x3000-0x3fff]
<7>[    1.036335] pci 0000:00:1c.2:   bridge window [mem 
0xd1500000-0xd15fffff]
<7>[    1.036428] pci 0000:0a:00.0: [10ec:5249] type 00 class 0xff0000
<7>[    1.036457] pci 0000:0a:00.0: reg 0x10: [mem 0xd1400000-0xd1400fff]
<7>[    1.036733] pci 0000:0a:00.0: supports D1 D2
<7>[    1.036734] pci 0000:0a:00.0: PME# supported from D1 D2 D3hot D3cold
<6>[    1.036805] pci 0000:0a:00.0: System wakeup disabled by ACPI
<6>[    1.048360] pci 0000:00:1c.4: PCI bridge to [bus 0a]
<7>[    1.048365] pci 0000:00:1c.4:   bridge window [mem 
0xd1400000-0xd14fffff]
<7>[    1.048391] pci_bus 0000:00: on NUMA node 0
<6>[    1.104702] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 11 12 
14 15) *7
<6>[    1.104743] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 10 *11 
12 14 15)
<6>[    1.104780] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 10 11 12 
14 15) *7
<6>[    1.104817] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *10 11 
12 14 15)
<6>[    1.104854] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 10 11 12 
14 15) *0, disabled.
<6>[    1.104891] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 *10 11 
12 14 15)
<6>[    1.104927] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 10 *11 
12 14 15)
<6>[    1.104964] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 *10 11 
12 14 15)
<4>[    1.105063] ACPI: Enabled 4 GPEs in block 00 to 3F
<4>[    1.105443] ACPI Error: No handler for Region [ECAM] 
(ffff964dda4c4e10) [EmbeddedControl] (20160422/evregion-166)
<4>[    1.105446] ACPI Error: Region EmbeddedControl (ID=3) has no 
handler (20160422/exfldio-299)
<4>[    1.105448] ACPI Error: Method parse/execution failed 
[\_SB.PCI0.LPCB.EC0.REGH] (Node ffff964dda4c50c8), AE_NOT_EXIST 
(20160422/psparse-542)
<4>[    1.105452] ACPI Error: Method parse/execution failed 
[\_SB.PCI0.LPCB.EC0._REG] (Node ffff964dda4c0c30), AE_NOT_EXIST 
(20160422/psparse-542)
<4>[    1.105456] ACPI Exception: AE_NOT_EXIST, from region _REG, 
[EmbeddedControl] (20160422/evregion-397)
<4>[    1.105500] ACPI Error: No handler for Region [ECAM] 
(ffff964dda4c4e10) [EmbeddedControl] (20160422/evregion-166)
<4>[    1.105502] ACPI Error: Region EmbeddedControl (ID=3) has no 
handler (20160422/exfldio-299)
<4>[    1.105503] ACPI Error: Method parse/execution failed 
[\_SB.PCI0.LPCB.EC0.REGH] (Node ffff964dda4c50c8), AE_NOT_EXIST 
(20160422/psparse-542)
<4>[    1.105506] ACPI Error: Method parse/execution failed 
[\_SB.PCI0.LPCB.EC0._REG] (Node ffff964dda4c0c30), AE_NOT_EXIST 
(20160422/psparse-542)
<4>[    1.105510] ACPI Exception: AE_NOT_EXIST, from region _REG, 
[EmbeddedControl] (20160422/evregion-397)
<4>[    1.105553] ACPI Error: No handler for Region [ECAM] 
(ffff964dda4c4e10) [EmbeddedControl] (20160422/evregion-166)
<4>[    1.105554] ACPI Error: Region EmbeddedControl (ID=3) has no 
handler (20160422/exfldio-299)
<4>[    1.105556] ACPI Error: Method parse/execution failed 
[\_SB.PCI0.LPCB.EC0.REGH] (Node ffff964dda4c50c8), AE_NOT_EXIST 
(20160422/psparse-542)
<4>[    1.105558] ACPI Error: Method parse/execution failed 
[\_SB.PCI0.LPCB.EC0._REG] (Node ffff964dda4c0c30), AE_NOT_EXIST 
(20160422/psparse-542)
<4>[    1.105562] ACPI Exception: AE_NOT_EXIST, from region _REG, 
[EmbeddedControl] (20160422/evregion-397)
<4>[    1.105604] ACPI Error: No handler for Region [ECAM] 
(ffff964dda4c4e10) [EmbeddedControl] (20160422/evregion-166)
<4>[    1.105605] ACPI Error: Region EmbeddedControl (ID=3) has no 
handler (20160422/exfldio-299)
<4>[    1.105607] ACPI Error: Method parse/execution failed 
[\_SB.PCI0.LPCB.EC0.REGH] (Node ffff964dda4c50c8), AE_NOT_EXIST 
(20160422/psparse-542)
<4>[    1.105610] ACPI Error: Method parse/execution failed 
[\_SB.PCI0.LPCB.EC0._REG] (Node ffff964dda4c0c30), AE_NOT_EXIST 
(20160422/psparse-542)
<4>[    1.105613] ACPI Exception: AE_NOT_EXIST, from region _REG, 
[EmbeddedControl] (20160422/evregion-397)
<6>[    1.105617] ACPI : EC: EC stopped
<6>[    1.105639] ACPI : EC: GPE = 0x17, I/O: command/status = 0x66, 
data = 0x62
<6>[    1.105639] ACPI : EC: EC started
<6>[    1.144489] vgaarb: setting as boot device: PCI:0000:00:02.0
<6>[    1.144490] vgaarb: device added: 
PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
<6>[    1.144492] vgaarb: loaded
<6>[    1.144492] vgaarb: bridge control possible 0000:00:02.0
<5>[    1.144603] SCSI subsystem initialized
<7>[    1.144627] libata version 3.00 loaded.
<6>[    1.144642] ACPI: bus type USB registered
<6>[    1.144653] usbcore: registered new interface driver usbfs
<6>[    1.144660] usbcore: registered new interface driver hub
<6>[    1.144678] usbcore: registered new device driver usb
<6>[    1.144746] PCI: Using ACPI for IRQ routing
<7>[    1.150368] PCI: pci_cache_line_size set to 64 bytes
<7>[    1.150442] e820: reserve RAM buffer [mem 0x0009d400-0x0009ffff]
<7>[    1.150443] e820: reserve RAM buffer [mem 0x76a70000-0x77ffffff]
<7>[    1.150444] e820: reserve RAM buffer [mem 0x9cabf000-0x9fffffff]
<7>[    1.150444] e820: reserve RAM buffer [mem 0x9d000000-0x9fffffff]
<7>[    1.150445] e820: reserve RAM buffer [mem 0x15f600000-0x15fffffff]
<6>[    1.150513] NetLabel: Initializing
<6>[    1.150514] NetLabel:  domain hash size = 128
<6>[    1.150514] NetLabel:  protocols = UNLABELED CIPSOv4
<6>[    1.150523] NetLabel:  unlabeled traffic allowed by default
<6>[    1.150566] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
<6>[    1.150570] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
<6>[    1.152588] clocksource: Switched to clocksource hpet
<5>[    1.157496] VFS: Disk quotas dquot_6.6.0
<6>[    1.157512] VFS: Dquot-cache hash table entries: 512 (order 0, 
4096 bytes)
<6>[    1.157567] AppArmor: AppArmor Filesystem Enabled
<6>[    1.157604] pnp: PnP ACPI init
<6>[    1.157723] system 00:00: [io  0x0680-0x069f] has been reserved
<6>[    1.157724] system 00:00: [io  0xffff] has been reserved
<6>[    1.157725] system 00:00: [io  0xffff] has been reserved
<6>[    1.157726] system 00:00: [io  0xffff] has been reserved
<6>[    1.157727] system 00:00: [io  0x1800-0x18fe] has been reserved
<6>[    1.157728] system 00:00: [io  0xfd60-0xfd63] has been reserved
<6>[    1.157729] system 00:00: [io  0x164e-0x164f] has been reserved
<7>[    1.157733] system 00:00: Plug and Play ACPI device, IDs PNP0c02 
(active)
<6>[    1.157772] system 00:01: [io  0x0800-0x087f] has been reserved
<7>[    1.157774] system 00:01: Plug and Play ACPI device, IDs PNP0c02 
(active)
<7>[    1.157793] pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
<6>[    1.157830] system 00:03: [io  0x1854-0x1857] has been reserved
<7>[    1.157831] system 00:03: Plug and Play ACPI device, IDs INT3f0d 
PNP0c02 (active)
<7>[    1.157882] pnp 00:04: Plug and Play ACPI device, IDs ETD0622 
ETD0000 PNP0f13 (active)
<7>[    1.157921] pnp 00:05: Plug and Play ACPI device, IDs PNP0303 (active)
<6>[    1.212740] system 00:06: [mem 0xfed1c000-0xfed1ffff] has been 
reserved
<6>[    1.212741] system 00:06: [mem 0xfed10000-0xfed17fff] has been 
reserved
<6>[    1.212742] system 00:06: [mem 0xfed18000-0xfed18fff] has been 
reserved
<6>[    1.212743] system 00:06: [mem 0xfed19000-0xfed19fff] has been 
reserved
<6>[    1.212744] system 00:06: [mem 0xe0000000-0xefffffff] has been 
reserved
<6>[    1.212745] system 00:06: [mem 0xfed20000-0xfed3ffff] has been 
reserved
<6>[    1.212746] system 00:06: [mem 0xfed90000-0xfed93fff] has been 
reserved
<6>[    1.212747] system 00:06: [mem 0xff000000-0xff000fff] has been 
reserved
<6>[    1.212748] system 00:06: [mem 0xff010000-0xffffffff] could not be 
reserved
<6>[    1.212749] system 00:06: [mem 0xfee00000-0xfeefffff] could not be 
reserved
<6>[    1.212750] system 00:06: [mem 0x9fa20000-0x9fa20fff] has been 
reserved
<6>[    1.212751] system 00:06: [mem 0x9fa10000-0x9fa1ffff] has been 
reserved
<7>[    1.212753] system 00:06: Plug and Play ACPI device, IDs PNP0c02 
(active)
<6>[    1.213112] pnp: PnP ACPI: found 7 devices
<6>[    1.219089] clocksource: acpi_pm: mask: 0xffffff max_cycles: 
0xffffff, max_idle_ns: 2085701024 ns
<6>[    1.219093] pci 0000:01:00.0: can't claim BAR 6 [mem 
0xfff80000-0xffffffff pref]: no compatible bridge window
<7>[    1.219106] pci 0000:00:1c.0: bridge window [io 0x1000-0x0fff] to 
[bus 07] add_size 1000
<7>[    1.219107] pci 0000:00:1c.0: bridge window [mem 
0x00100000-0x000fffff 64bit pref] to [bus 07] add_size 200000 add_align 
100000
<7>[    1.219109] pci 0000:00:1c.0: bridge window [mem 
0x00100000-0x000fffff] to [bus 07] add_size 200000 add_align 100000
<7>[    1.219129] pci 0000:00:1c.0: res[14]=[mem 0x00100000-0x000fffff] 
res_to_dev_res add_size 200000 min_align 100000
<7>[    1.219130] pci 0000:00:1c.0: res[14]=[mem 0x00100000-0x002fffff] 
res_to_dev_res add_size 200000 min_align 100000
<7>[    1.219131] pci 0000:00:1c.0: res[15]=[mem 0x00100000-0x000fffff 
64bit pref] res_to_dev_res add_size 200000 min_align 100000
<7>[    1.219132] pci 0000:00:1c.0: res[15]=[mem 0x00100000-0x002fffff 
64bit pref] res_to_dev_res add_size 200000 min_align 100000
<7>[    1.219134] pci 0000:00:1c.0: res[13]=[io 0x1000-0x0fff] 
res_to_dev_res add_size 1000 min_align 1000
<7>[    1.219135] pci 0000:00:1c.0: res[13]=[io 0x1000-0x1fff] 
res_to_dev_res add_size 1000 min_align 1000
<6>[    1.219138] pci 0000:00:1c.0: BAR 14: assigned [mem 
0x9fb00000-0x9fcfffff]
<6>[    1.219141] pci 0000:00:1c.0: BAR 15: assigned [mem 
0x9fd00000-0x9fefffff 64bit pref]
<6>[    1.219142] pci 0000:00:1c.0: BAR 13: assigned [io 0x2000-0x2fff]
<6>[    1.219145] pci 0000:01:00.0: BAR 6: assigned [mem 
0xb2000000-0xb207ffff pref]
<6>[    1.219146] pci 0000:00:01.0: PCI bridge to [bus 01-06]
<6>[    1.219147] pci 0000:00:01.0:   bridge window [io 0x4000-0x4fff]
<6>[    1.219149] pci 0000:00:01.0:   bridge window [mem 
0xd0000000-0xd0ffffff]
<6>[    1.219151] pci 0000:00:01.0:   bridge window [mem 
0xa0000000-0xbfffffff 64bit pref]
<6>[    1.219154] pci 0000:00:1c.0: PCI bridge to [bus 07]
<6>[    1.219157] pci 0000:00:1c.0:   bridge window [io 0x2000-0x2fff]
<6>[    1.219161] pci 0000:00:1c.0:   bridge window [mem 
0x9fb00000-0x9fcfffff]
<6>[    1.219164] pci 0000:00:1c.0:   bridge window [mem 
0x9fd00000-0x9fefffff 64bit pref]
<6>[    1.219169] pci 0000:00:1c.1: PCI bridge to [bus 08]
<6>[    1.219173] pci 0000:00:1c.1:   bridge window [mem 
0xd1600000-0xd16fffff]
<6>[    1.219180] pci 0000:00:1c.2: PCI bridge to [bus 09]
<6>[    1.219182] pci 0000:00:1c.2:   bridge window [io 0x3000-0x3fff]
<6>[    1.219186] pci 0000:00:1c.2:   bridge window [mem 
0xd1500000-0xd15fffff]
<6>[    1.219193] pci 0000:00:1c.4: PCI bridge to [bus 0a]
<6>[    1.219197] pci 0000:00:1c.4:   bridge window [mem 
0xd1400000-0xd14fffff]
<7>[    1.219205] pci_bus 0000:00: resource 4 [io 0x0000-0x0cf7 window]
<7>[    1.219206] pci_bus 0000:00: resource 5 [io 0x0d00-0xffff window]
<7>[    1.219207] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff 
window]
<7>[    1.219208] pci_bus 0000:00: resource 7 [mem 0x9fa00000-0xfeafffff 
window]
<7>[    1.219209] pci_bus 0000:01: resource 0 [io 0x4000-0x4fff]
<7>[    1.219209] pci_bus 0000:01: resource 1 [mem 0xd0000000-0xd0ffffff]
<7>[    1.219210] pci_bus 0000:01: resource 2 [mem 0xa0000000-0xbfffffff 
64bit pref]
<7>[    1.219211] pci_bus 0000:07: resource 0 [io 0x2000-0x2fff]
<7>[    1.219212] pci_bus 0000:07: resource 1 [mem 0x9fb00000-0x9fcfffff]
<7>[    1.219213] pci_bus 0000:07: resource 2 [mem 0x9fd00000-0x9fefffff 
64bit pref]
<7>[    1.219214] pci_bus 0000:08: resource 1 [mem 0xd1600000-0xd16fffff]
<7>[    1.219215] pci_bus 0000:09: resource 0 [io 0x3000-0x3fff]
<7>[    1.219216] pci_bus 0000:09: resource 1 [mem 0xd1500000-0xd15fffff]
<7>[    1.219217] pci_bus 0000:0a: resource 1 [mem 0xd1400000-0xd14fffff]
<6>[    1.219240] NET: Registered protocol family 2
<6>[    1.219359] TCP established hash table entries: 32768 (order: 6, 
262144 bytes)
<6>[    1.219407] TCP bind hash table entries: 32768 (order: 7, 524288 
bytes)
<6>[    1.219506] TCP: Hash tables configured (established 32768 bind 32768)
<6>[    1.219523] UDP hash table entries: 2048 (order: 4, 65536 bytes)
<6>[    1.219536] UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes)
<6>[    1.219579] NET: Registered protocol family 1
<6>[    1.219589] pci 0000:00:02.0: Video device with shadowed ROM at 
[mem 0x000c0000-0x000dffff]
<4>[    3.220774] pci 0000:00:1a.0: EHCI: BIOS handoff failed (BIOS 
bug?) 01010001
<4>[    5.256934] pci 0000:00:1d.0: EHCI: BIOS handoff failed (BIOS 
bug?) 01010001
<7>[    5.257163] PCI: CLS 64 bytes, default 64
<6>[    5.257205] Trying to unpack rootfs image as initramfs...
<6>[    6.028718] Freeing initrd memory: 54516K (ffff964cb1576000 - 
ffff964cb4ab3000)
<6>[    6.028721] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
<6>[    6.028723] software IO TLB [mem 0x98abf000-0x9cabf000] (64MB) 
mapped at [ffff964d18abf000-ffff964d1cabefff]
<6>[    6.029064] Scanning for low memory corruption every 60 seconds
<6>[    6.029357] futex hash table entries: 2048 (order: 5, 131072 bytes)
<6>[    6.029391] audit: initializing netlink subsys (disabled)
<5>[    6.029407] audit: type=2000 audit(1476505061.020:1): initialized
<5>[    6.029718] Initialise system trusted keyrings
<6>[    6.029804] workingset: timestamp_bits=46 max_order=20 bucket_order=0
<6>[    6.031085] zbud: loaded
<6>[    6.031536] fuse init (API version 7.25)
<5>[    6.031642] Key type big_key registered
<5>[    6.031955] Key type asymmetric registered
<5>[    6.031956] Asymmetric key parser 'x509' registered
<6>[    6.031982] Block layer SCSI generic (bsg) driver version 0.4 
loaded (major 250)
<6>[    6.032011] io scheduler noop registered
<6>[    6.032017] io scheduler cfq registered (default)
<6>[    6.032565] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
<6>[    6.032568] pciehp: PCI Express Hot Plug Controller Driver 
version: 0.4
<6>[    6.032580] vesafb: mode is 1920x1080x32, linelength=7680, pages=0
<6>[    6.032581] vesafb: scrolling: redraw
<6>[    6.032582] vesafb: Truecolor: size=8:8:8:8, shift=24:16:8:0
<6>[    6.032592] vesafb: framebuffer at 0xc0000000, mapped to 
0xffffaf21c0800000, using 8128k, total 8128k
<6>[    6.198687] Console: switching to colour frame buffer device 240x67
<6>[    6.364080] fb0: VESA VGA frame buffer device
<7>[    6.364091] intel_idle: MWAIT substates: 0x42120
<7>[    6.364092] intel_idle: v0.4.1 model 0x3C
<7>[    6.364336] intel_idle: lapic_timer_reliable_states 0xffffffff
<6>[    6.364398] ACPI: AC Adapter [ACAD] (on-line)
<6>[    6.364453] input: Power Button as 
/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/device:01/PNP0C0C:00/input/input0
<6>[    6.364456] ACPI: Power Button [PWRB]
<6>[    6.364482] input: Sleep Button as 
/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/device:01/PNP0C0E:00/input/input1
<6>[    6.364484] ACPI: Sleep Button [SLPB]
<6>[    6.364521] input: Lid Switch as 
/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0D:00/input/input2
<6>[    6.364537] ACPI: Lid Switch [LID0]
<6>[    6.364565] input: Power Button as 
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input3
<6>[    6.364566] ACPI: Power Button [PWRF]
<6>[    6.365193] thermal LNXTHERM:00: registered as thermal_zone0
<6>[    6.365194] ACPI: Thermal Zone [TZ00] (49 C)
<6>[    6.365221] GHES: HEST is not enabled!
<6>[    6.365261] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
<6>[    6.473088] ACPI: Battery Slot [BAT1] (battery present)
<6>[    6.475651] brd: module loaded
<6>[    6.476725] loop: module loaded
<6>[    6.476790] tun: Universal TUN/TAP device driver, 1.6
<6>[    6.476791] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
<6>[    6.476815] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
<6>[    6.476817] ehci-pci: EHCI PCI platform driver
<6>[    6.476916] ehci-pci 0000:00:1a.0: EHCI Host Controller
<6>[    6.476920] ehci-pci 0000:00:1a.0: new USB bus registered, 
assigned bus number 1
<6>[    6.476930] ehci-pci 0000:00:1a.0: debug port 2
<7>[    6.480846] ehci-pci 0000:00:1a.0: cache line size of 64 is not 
supported
<6>[    6.480854] ehci-pci 0000:00:1a.0: irq 21, io mem 0xd171d000
<6>[    6.493045] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
<6>[    6.493072] usb usb1: New USB device found, idVendor=1d6b, 
idProduct=0002
<6>[    6.493073] usb usb1: New USB device strings: Mfr=3, Product=2, 
SerialNumber=1
<6>[    6.493074] usb usb1: Product: EHCI Host Controller
<6>[    6.493074] usb usb1: Manufacturer: Linux 4.8.1 ehci_hcd
<6>[    6.493075] usb usb1: SerialNumber: 0000:00:1a.0
<6>[    6.493181] hub 1-0:1.0: USB hub found
<6>[    6.493184] hub 1-0:1.0: 2 ports detected
<6>[    6.493376] ehci-pci 0000:00:1d.0: EHCI Host Controller
<6>[    6.493379] ehci-pci 0000:00:1d.0: new USB bus registered, 
assigned bus number 2
<6>[    6.493388] ehci-pci 0000:00:1d.0: debug port 2
<7>[    6.497297] ehci-pci 0000:00:1d.0: cache line size of 64 is not 
supported
<6>[    6.497304] ehci-pci 0000:00:1d.0: irq 23, io mem 0xd171c000
<6>[    6.513044] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
<6>[    6.513067] usb usb2: New USB device found, idVendor=1d6b, 
idProduct=0002
<6>[    6.513068] usb usb2: New USB device strings: Mfr=3, Product=2, 
SerialNumber=1
<6>[    6.513069] usb usb2: Product: EHCI Host Controller
<6>[    6.513070] usb usb2: Manufacturer: Linux 4.8.1 ehci_hcd
<6>[    6.513071] usb usb2: SerialNumber: 0000:00:1d.0
<6>[    6.513162] hub 2-0:1.0: USB hub found
<6>[    6.513165] hub 2-0:1.0: 2 ports detected
<6>[    6.513252] ehci-platform: EHCI generic platform driver
<6>[    6.513259] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
<6>[    6.513261] ohci-pci: OHCI PCI platform driver
<6>[    6.513267] ohci-platform: OHCI generic platform driver
<6>[    6.513271] uhci_hcd: USB Universal Host Controller Interface driver
<6>[    6.513368] xhci_hcd 0000:00:14.0: xHCI Host Controller
<6>[    6.513371] xhci_hcd 0000:00:14.0: new USB bus registered, 
assigned bus number 3
<6>[    6.514451] xhci_hcd 0000:00:14.0: hcc params 0x200077c1 hci 
version 0x100 quirks 0x00009810
<7>[    6.514456] xhci_hcd 0000:00:14.0: cache line size of 64 is not 
supported
<6>[    6.514519] usb usb3: New USB device found, idVendor=1d6b, 
idProduct=0002
<6>[    6.514520] usb usb3: New USB device strings: Mfr=3, Product=2, 
SerialNumber=1
<6>[    6.514521] usb usb3: Product: xHCI Host Controller
<6>[    6.514522] usb usb3: Manufacturer: Linux 4.8.1 xhci-hcd
<6>[    6.514522] usb usb3: SerialNumber: 0000:00:14.0
<6>[    6.514608] hub 3-0:1.0: USB hub found
<6>[    6.514623] hub 3-0:1.0: 14 ports detected
<6>[    6.517459] xhci_hcd 0000:00:14.0: xHCI Host Controller
<6>[    6.517462] xhci_hcd 0000:00:14.0: new USB bus registered, 
assigned bus number 4
<6>[    6.517490] usb usb4: New USB device found, idVendor=1d6b, 
idProduct=0003
<6>[    6.517491] usb usb4: New USB device strings: Mfr=3, Product=2, 
SerialNumber=1
<6>[    6.517491] usb usb4: Product: xHCI Host Controller
<6>[    6.517492] usb usb4: Manufacturer: Linux 4.8.1 xhci-hcd
<6>[    6.517493] usb usb4: SerialNumber: 0000:00:14.0
<6>[    6.517577] hub 4-0:1.0: USB hub found
<6>[    6.517586] hub 4-0:1.0: 4 ports detected
<6>[    6.518235] i8042: PNP: PS/2 Controller 
[PNP0303:PS2K,PNP0f13:MSS1] at 0x60,0x64 irq 1,12
<6>[    6.544081] serio: i8042 KBD port at 0x60,0x64 irq 1
<6>[    6.544083] serio: i8042 AUX port at 0x60,0x64 irq 12
<6>[    6.544194] mousedev: PS/2 mouse device common for all mice
<6>[    6.544349] rtc_cmos 00:02: RTC can wake from S4
<6>[    6.544463] rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
<6>[    6.544487] rtc_cmos 00:02: alarms up to one month, 242 bytes 
nvram, hpet irqs
<6>[    6.544525] device-mapper: uevent: version 1.0.3
<6>[    6.544581] device-mapper: ioctl: 4.35.0-ioctl (2016-06-23) 
initialised: dm-devel@redhat.com
<6>[    6.544585] intel_pstate: Intel P-state driver initializing
<6>[    6.545042] NET: Registered protocol family 17
<5>[    6.545059] Key type dns_resolver registered
<6>[    6.545708] microcode: sig=0x306c3, pf=0x20, revision=0x1c
<6>[    6.545898] microcode: Microcode Update Driver: v2.01 
<tigran@aivazian.fsnet.co.uk>, Peter Oruba
<6>[    6.546182] registered taskstats version 1
<5>[    6.546186] Loading compiled-in X.509 certificates
<5>[    6.554028] Loaded X.509 cert 'Build time autogenerated kernel 
key: 9ca202597fdbab8d58636ca9966c4a780fad5ccb'
<6>[    6.554073] zswap: loaded using pool lzo/zbud
<6>[    6.556579] input: AT Translated Set 2 keyboard as 
/devices/platform/i8042/serio0/input/input4
<5>[    6.594667] Key type trusted registered
<5>[    6.596580] Key type encrypted registered
<6>[    6.596583] AppArmor: AppArmor sha1 policy hashing enabled
<6>[    6.596584] ima: No TPM chip found, activating TPM-bypass!
<6>[    6.596602] evm: HMAC attrs: 0x1
<6>[    6.597131]   Magic number: 4:293:262
<6>[    6.597246] rtc_cmos 00:02: setting system clock to 2016-10-15 
04:17:42 UTC (1476505062)
<6>[    6.597252] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
<6>[    6.597252] EDD information not available.
<7>[    6.597298] PM: Hibernation image not present or could not be loaded.
<6>[    6.598115] Freeing unused kernel memory: 1244K (ffffffff94d28000 
- ffffffff94e5f000)
<6>[    6.598115] Write protecting the kernel read-only data: 12288k
<6>[    6.598414] Freeing unused kernel memory: 1300K (ffff964ca26bb000 
- ffff964ca2800000)
<6>[    6.599817] Freeing unused kernel memory: 928K (ffff964ca2b18000 - 
ffff964ca2c00000)
<5>[    6.609104] random: systemd-udevd: uninitialized urandom read (16 
bytes read)
<5>[    6.609164] random: systemd-udevd: uninitialized urandom read (16 
bytes read)
<5>[    6.609172] random: systemd-udevd: uninitialized urandom read (16 
bytes read)
<5>[    6.609183] random: systemd-udevd: uninitialized urandom read (16 
bytes read)
<5>[    6.609442] random: udevadm: uninitialized urandom read (16 bytes 
read)
<5>[    6.609463] random: udevadm: uninitialized urandom read (16 bytes 
read)
<5>[    6.610163] random: udevadm: uninitialized urandom read (16 bytes 
read)
<5>[    6.610196] random: udevadm: uninitialized urandom read (16 bytes 
read)
<5>[    6.610205] random: udevadm: uninitialized urandom read (16 bytes 
read)
<5>[    6.610516] random: udevadm: uninitialized urandom read (16 bytes 
read)
<6>[    6.639598] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
<4>[    6.639604] r8169 0000:09:00.0: can't disable ASPM; OS doesn't 
have ASPM control
<7>[    6.643981] ahci 0000:00:1f.2: version 3.0
<6>[    6.644158] ahci 0000:00:1f.2: SSS flag set, parallel bus scan 
disabled
<6>[    6.644214] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 4 ports 6 
Gbps 0x10 impl SATA mode
<6>[    6.644215] ahci 0000:00:1f.2: flags: 64bit ncq stag pm led clo 
pio slum part ems apst
<6>[    6.644233] rtsx_pci 0000:0a:00.0: rtsx_pci_acquire_irq: 
pcr->msi_en = 1, pci->irq = 27
<6>[    6.644691] scsi host0: ahci
<6>[    6.644762] scsi host1: ahci
<6>[    6.644814] scsi host2: ahci
<6>[    6.644866] scsi host3: ahci
<6>[    6.644917] scsi host4: ahci
<6>[    6.644942] ata1: DUMMY
<6>[    6.644943] ata2: DUMMY
<6>[    6.644943] ata3: DUMMY
<6>[    6.644943] ata4: DUMMY
<6>[    6.644945] ata5: SATA max UDMA/133 abar m2048@0xd171b000 port 
0xd171b300 irq 26
<6>[    6.649948] r8169 0000:09:00.0 eth0: RTL8168g/8111g at 
0xffffaf21c001e000, f0:76:1c:57:c8:8d, XID 10900880 IRQ 28
<6>[    6.649950] r8169 0000:09:00.0 eth0: jumbo features [frames: 9200 
bytes, tx checksumming: ko]
<6>[    6.659667] AVX2 version of gcm_enc/dec engaged.
<6>[    6.659668] AES CTR mode by8 optimization enabled
<6>[    6.685098] [drm] Initialized drm 1.1.0 20060810
<6>[    6.821086] usb 1-1: new high-speed USB device number 2 using ehci-pci
<6>[    6.841075] usb 2-1: new high-speed USB device number 2 using ehci-pci
<6>[    6.846011] [drm] Memory usable by graphics device = 2048M
<7>[    6.846013] checking generic (c0000000 7f0000) vs hw (c0000000 
10000000)
<6>[    6.846013] fb: switching to inteldrmfb from VESA VGA
<6>[    6.846028] Console: switching to colour dummy device 80x25
<6>[    6.846084] [drm] Replacing VGA console driver
<6>[    6.849067] usb 3-1: new low-speed USB device number 2 using xhci_hcd
<6>[    6.851090] [drm] Supports vblank timestamp caching Rev 2 
(21.10.2013).
<6>[    6.851090] [drm] Driver supports precise vblank timestamp query.
<6>[    6.853300] vgaarb: device changed decodes: 
PCI:0000:00:02.0,olddecodes=io+mem,decodes=io+mem:owns=io+mem
<4>[    6.897740] [Firmware Bug]: ACPI(PEGP) defines _DOD but not _DOS
<6>[    6.898124] ACPI: Video Device [PEGP] (multi-head: yes  rom: yes  
post: no)
<6>[    6.898309] input: Video Bus as 
/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/device:43/LNXVIDEO:00/input/input7
<6>[    6.900022] ACPI: Video Device [GFX0] (multi-head: yes  rom: no  
post: no)
<6>[    6.900100] input: Video Bus as 
/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/LNXVIDEO:01/input/input8
<6>[    6.900218] [drm] Initialized i915 1.6.0 20160711 for 0000:00:02.0 
on minor 0
<6>[    6.926382] fbcon: inteldrmfb (fb0) is primary device
<6>[    6.959886] ata5: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
<6>[    6.960632] ata5.00: ATA-9: WDC WD10SPCX-24HWST1, 02.01A02, max 
UDMA/133
<6>[    6.960634] ata5.00: 1953525168 sectors, multi 0: LBA48 NCQ (depth 
31/32), AA
<6>[    6.961364] ata5.00: configured for UDMA/133
<5>[    6.961601] scsi 4:0:0:0: Direct-Access     ATA WDC WD10SPCX-24H 
1A02 PQ: 0 ANSI: 5
<6>[    6.973438] usb 1-1: New USB device found, idVendor=8087, 
idProduct=8008
<6>[    6.973440] usb 1-1: New USB device strings: Mfr=0, Product=0, 
SerialNumber=0
<6>[    6.973737] hub 1-1:1.0: USB hub found
<6>[    6.973835] hub 1-1:1.0: 6 ports detected
<6>[    6.989485] usb 2-1: New USB device found, idVendor=8087, 
idProduct=8000
<6>[    6.989486] usb 2-1: New USB device strings: Mfr=0, Product=0, 
SerialNumber=0
<6>[    6.989840] hub 2-1:1.0: USB hub found
<6>[    6.989931] hub 2-1:1.0: 8 ports detected
<6>[    7.001608] usb 3-1: New USB device found, idVendor=045e, 
idProduct=0040
<6>[    7.001609] usb 3-1: New USB device strings: Mfr=1, Product=3, 
SerialNumber=0
<6>[    7.001610] usb 3-1: Product: Microsoft 3-Button Mouse with 
IntelliEye(TM)
<6>[    7.001611] usb 3-1: Manufacturer: Microsoft
<5>[    7.005238] sd 4:0:0:0: [sda] 1953525168 512-byte logical blocks: 
(1.00 TB/932 GiB)
<5>[    7.005239] sd 4:0:0:0: [sda] 4096-byte physical blocks
<5>[    7.005431] sd 4:0:0:0: [sda] Write Protect is off
<7>[    7.005432] sd 4:0:0:0: [sda] Mode Sense: 00 3a 00 00
<5>[    7.005534] sd 4:0:0:0: [sda] Write cache: enabled, read cache: 
enabled, doesn't support DPO or FUA
<6>[    7.008710] hidraw: raw HID events driver (C) Jiri Kosina
<6>[    7.015124] usbcore: registered new interface driver usbhid
<6>[    7.015125] usbhid: USB HID core driver
<6>[    7.017292] input: Microsoft Microsoft 3-Button Mouse with 
IntelliEye(TM) as 
/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:045E:0040.0001/input/input9
<6>[    7.017359] hid-generic 0003:045E:0040.0001: input,hidraw0: USB 
HID v1.10 Mouse [Microsoft Microsoft 3-Button Mouse with IntelliEye(TM)] 
on usb-0000:00:14.0-1/input0
<5>[    7.028559] random: fast init done
<6>[    7.041109] tsc: Refined TSC clocksource calibration: 2494.227 MHz
<6>[    7.041113] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 
0x23f3ec29a0f, max_idle_ns: 440795214066 ns
<6>[    7.057760]  sda: sda1 sda2 sda3
<5>[    7.058495] sd 4:0:0:0: [sda] Attached SCSI disk
<6>[    7.121122] usb 3-6: new high-speed USB device number 3 using xhci_hcd
<6>[    7.153646] psmouse serio1: elantech: assuming hardware version 4 
(with firmware version 0x495f01)
<6>[    7.163905] psmouse serio1: elantech: Synaptics capabilities query 
result 0x70, 0x15, 0x0e.
<6>[    7.174241] psmouse serio1: elantech: Elan sample query result 02, 
33, 75
<6>[    7.228839] input: ETPS/2 Elantech Touchpad as 
/devices/platform/i8042/serio1/input/input6
<6>[    7.280836] usb 3-6: New USB device found, idVendor=174f, 
idProduct=14b8
<6>[    7.280838] usb 3-6: New USB device strings: Mfr=3, Product=1, 
SerialNumber=2
<6>[    7.280839] usb 3-6: Product: Lenovo EasyCamera
<6>[    7.280840] usb 3-6: Manufacturer: Generic
<6>[    7.280840] usb 3-6: SerialNumber: 200901010001
<6>[    7.401163] usb 3-7: new full-speed USB device number 4 using xhci_hcd
<6>[    7.542453] usb 3-7: New USB device found, idVendor=8087, 
idProduct=07dc
<6>[    7.542454] usb 3-7: New USB device strings: Mfr=0, Product=0, 
SerialNumber=0
<6>[    7.661183] usb 3-9: new high-speed USB device number 5 using xhci_hcd
<6>[    7.806038] usb 3-9: New USB device found, idVendor=13fe, 
idProduct=36ff
<6>[    7.806039] usb 3-9: New USB device strings: Mfr=1, Product=2, 
SerialNumber=3
<6>[    7.806040] usb 3-9: Product: USB DISK
<6>[    7.806041] usb 3-9: SerialNumber: 079A1307830F1FF0
<6>[    7.815388] usb-storage 3-9:1.0: USB Mass Storage device detected
<6>[    7.815483] scsi host5: usb-storage 3-9:1.0
<3>[    7.815499] scsi host5: runtime PM trying to activate child device 
host5 but parent (3-9:1.0) is not active
<6>[    7.815525] usbcore: registered new interface driver usb-storage
<6>[    7.817774] usbcore: registered new interface driver uas
<6>[    8.065342] clocksource: Switched to clocksource tsc
<6>[    8.153524] Console: switching to colour frame buffer device 240x67
<6>[    8.181866] i915 0000:00:02.0: fb0: inteldrmfb frame buffer device
<5>[    8.834616] scsi 5:0:0:0: Direct-Access USB DISK         PMAP PQ: 
0 ANSI: 6
<5>[    8.835746] sd 5:0:0:0: [sdb] 7811072 512-byte logical blocks: 
(4.00 GB/3.72 GiB)
<5>[    8.835935] sd 5:0:0:0: [sdb] Write Protect is off
<7>[    8.835937] sd 5:0:0:0: [sdb] Mode Sense: 23 00 00 00
<3>[    8.836086] sd 5:0:0:0: [sdb] No Caching mode page found
<3>[    8.836090] sd 5:0:0:0: [sdb] Assuming drive cache: write through
<6>[    8.839068]  sdb: sdb1
<5>[    8.840376] sd 5:0:0:0: [sdb] Attached SCSI removable disk
<5>[  115.921059] random: crng init done
<6>[  118.069896] NET: Registered protocol family 38
<6>[  123.645150] EXT4-fs (dm-0): mounted filesystem with ordered data 
mode. Opts: (null)
<7>[  125.245077] systemd[1]: Failed to insert module 'autofs4': No such 
file or directory
<7>[  125.411722] systemd[1]: systemd 229 running in system mode. (+PAM 
+AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP 
+GCRYPT +GNUTLS +ACL +XZ -LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN)
<7>[  125.411881] systemd[1]: Detected architecture x86-64.
<7>[  125.424046] systemd[1]: Set hostname to <serpens>.
<7>[  128.882869] systemd[1]: Listening on LVM2 poll daemon socket.
<7>[  128.882940] systemd[1]: Listening on Journal Socket (/dev/log).
<7>[  128.882961] systemd[1]: Listening on /dev/initctl Compatibility 
Named Pipe.
<7>[  128.883013] systemd[1]: Listening on Journal Audit Socket.
<7>[  128.883032] systemd[1]: Starting of Arbitrary Executable File 
Formats File System Automount Point not supported.
<7>[  128.883073] systemd[1]: Listening on Device-mapper event daemon FIFOs.
<7>[  128.883108] systemd[1]: Listening on Journal Socket.
<7>[  130.632935] systemd[1]: Started Journal Service.
<6>[  133.141091] EXT4-fs (dm-0): re-mounted. Opts: errors=remount-ro
<7>[  133.307846] systemd-journald[432]: Received request to flush 
runtime journal from PID 1
<6>[  133.399300] wmi: Mapper loaded
<6>[  134.016072] input: Ideapad extra buttons as 
/devices/pci0000:00/0000:00:1f.0/PNP0C09:00/VPC2004:00/input/input10
<6>[  135.575939] Intel(R) Wireless WiFi driver for Linux
<6>[  135.575940] Copyright(c) 2003- 2015 Intel Corporation
<4>[  135.696237] iwlwifi 0000:08:00.0: Direct firmware load for 
iwlwifi-7260-17.ucode failed with error -2
<4>[  135.696238] iwlwifi 0000:08:00.0: Falling back to user helper
<6>[  136.233761] Linux video capture interface: v2.00
<6>[  136.810756] iwlwifi 0000:08:00.0: loaded firmware version 
16.242414.0 op_mode iwlmvm
<6>[  137.267012] uvcvideo: Found UVC 1.00 device Lenovo EasyCamera 
(174f:14b8)
<6>[  137.268109] input: Lenovo EasyCamera as 
/devices/pci0000:00/0000:00:14.0/usb3/3-6/3-6:1.0/input/input11
<6>[  137.268159] usbcore: registered new interface driver uvcvideo
<6>[  137.268159] USB Video Class driver (1.1.1)
<6>[  137.397871] Bluetooth: Core ver 2.21
<6>[  137.397880] NET: Registered protocol family 31
<6>[  137.397880] Bluetooth: HCI device and connection manager initialized
<6>[  137.397883] Bluetooth: HCI socket layer initialized
<6>[  137.397884] Bluetooth: L2CAP socket layer initialized
<6>[  137.397886] Bluetooth: SCO socket layer initialized
<6>[  137.797261] intel_rapl: Found RAPL domain package
<6>[  137.797264] intel_rapl: Found RAPL domain core
<6>[  137.797265] intel_rapl: Found RAPL domain uncore
<6>[  137.797267] intel_rapl: Found RAPL domain dram
<6>[  137.797269] intel_rapl: RAPL package 0 domain package locked by BIOS
<6>[  138.018373] usbcore: registered new interface driver btusb
<6>[  138.032607] Bluetooth: hci0: read Intel version: 370710018002030d55
<6>[  138.032608] Bluetooth: hci0: Intel device is already patched. 
patch num: 55
<6>[  138.818232] snd_hda_intel 0000:00:03.0: bound 0000:00:02.0 (ops 
i915_audio_component_bind_ops [i915])
<6>[  139.055402] input: HDA Intel HDMI HDMI/DP,pcm=3 as 
/devices/pci0000:00/0000:00:03.0/sound/card0/input12
<6>[  139.055451] input: HDA Intel HDMI HDMI/DP,pcm=7 as 
/devices/pci0000:00/0000:00:03.0/sound/card0/input13
<6>[  139.055482] input: HDA Intel HDMI HDMI/DP,pcm=8 as 
/devices/pci0000:00/0000:00:03.0/sound/card0/input14
<6>[  139.768347] iwlwifi 0000:08:00.0: Detected Intel(R) Dual Band 
Wireless AC 7260, REV=0x144
<6>[  139.770405] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<6>[  139.770667] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<7>[  140.074772] ieee80211 phy0: Selected rate control algorithm 
'iwl-mvm-rs'
<6>[  140.093738] snd_hda_codec_realtek hdaudioC1D0: autoconfig for 
ALC3239: line_outs=1 (0x14/0x0/0x0/0x0/0x0) type:speaker
<6>[  140.093740] snd_hda_codec_realtek hdaudioC1D0: speaker_outs=0 
(0x0/0x0/0x0/0x0/0x0)
<6>[  140.093741] snd_hda_codec_realtek hdaudioC1D0: hp_outs=1 
(0x21/0x0/0x0/0x0/0x0)
<6>[  140.093742] snd_hda_codec_realtek hdaudioC1D0: mono: mono_out=0x0
<6>[  140.093742] snd_hda_codec_realtek hdaudioC1D0: dig-out=0x1e/0x0
<6>[  140.093743] snd_hda_codec_realtek hdaudioC1D0: inputs:
<6>[  140.093744] snd_hda_codec_realtek hdaudioC1D0: Mic=0x19
<6>[  140.093745] snd_hda_codec_realtek hdaudioC1D0: Internal Mic=0x12
<6>[  140.141225] input: HDA Intel PCH Mic as 
/devices/pci0000:00/0000:00:1b.0/sound/card1/input15
<6>[  140.141264] input: HDA Intel PCH Headphone as 
/devices/pci0000:00/0000:00:1b.0/sound/card1/input16
<6>[  141.108454] EXT4-fs (sda1): mounted filesystem with ordered data 
mode. Opts: (null)
<6>[  146.063020] Adding 4081652k swap on /dev/mapper/swap. Priority:-1 
extents:1 across:4081652k FS
<4>[  150.684062] cgroup: new mount options do not match the existing 
superblock, will be ignored
<6>[  160.183828] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<6>[  160.184095] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<6>[  160.402897] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<6>[  160.403161] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<6>[  160.615602] r8169 0000:09:00.0 eth0: link down
<6>[  165.848552] wlan0: authenticate with 00:21:27:de:51:8e
<6>[  165.850885] wlan0: send auth to 00:21:27:de:51:8e (try 1/3)
<6>[  165.852673] wlan0: authenticated
<6>[  165.852743] iwlwifi 0000:08:00.0 wlan0: disabling HT as WMM/QoS is 
not supported by the AP
<6>[  165.852744] iwlwifi 0000:08:00.0 wlan0: disabling VHT as WMM/QoS 
is not supported by the AP
<6>[  165.857827] wlan0: associate with 00:21:27:de:51:8e (try 1/3)
<6>[  165.860314] wlan0: RX AssocResp from 00:21:27:de:51:8e 
(capab=0x431 status=0 aid=2)
<6>[  165.864717] wlan0: associated
<6>[  166.162225] ip_tables: (C) 2000-2006 Netfilter Core Team
<6>[ 1670.474137] usb 3-9: USB disconnect, device number 5
<6>[ 1936.579032] wlan0: deauthenticating from 00:21:27:de:51:8e by 
local choice (Reason: 3=DEAUTH_LEAVING)
<6>[ 1937.084919] PM: Syncing filesystems ... done.
<7>[ 1937.332563] PM: Preparing system for sleep (mem)
<6>[ 1937.356088] Freezing user space processes ... (elapsed 0.001 
seconds) done.
<6>[ 1937.357780] Double checking all user space processes after OOM 
killer disable... (elapsed 0.000 seconds)
<6>[ 1937.357851] Freezing remaining freezable tasks ... (elapsed 0.001 
seconds) done.
<7>[ 1937.359049] PM: Suspending system (mem)
<4>[ 1937.359079] Suspending console(s) (use no_console_suspend to debug)
<5>[ 1937.359284] sd 4:0:0:0: [sda] Synchronizing SCSI cache
<5>[ 1937.448196] sd 4:0:0:0: [sda] Stopping disk
<6>[ 1938.769776] PM: suspend of devices complete after 1410.423 msecs
<3>[ 1938.772204] [drm:hsw_write_dcomp [i915]] *ERROR* Failed to write 
to D_COMP
<6>[ 1938.791735] PM: late suspend of devices complete after 21.952 msecs
<6>[ 1938.792729] r8169 0000:09:00.0: System wakeup enabled by ACPI
<6>[ 1938.792759] ehci-pci 0000:00:1d.0: System wakeup enabled by ACPI
<6>[ 1938.792994] ehci-pci 0000:00:1a.0: System wakeup enabled by ACPI
<6>[ 1938.793008] xhci_hcd 0000:00:14.0: System wakeup enabled by ACPI
<6>[ 1939.123670] PM: noirq suspend of devices complete after 331.898 msecs
<6>[ 1939.123946] ACPI: Preparing to enter system sleep state S3
<6>[ 1939.139833] ACPI : EC: EC stopped
<6>[ 1939.139834] PM: Saving platform NVS memory
<6>[ 1939.139843] Disabling non-boot CPUs ...
<5>[ 1939.140131] Broke affinity for irq 21
<5>[ 1939.140135] Broke affinity for irq 29
<6>[ 1939.141172] smpboot: CPU 1 is now offline
<5>[ 1939.156338] Broke affinity for irq 21
<5>[ 1939.156342] Broke affinity for irq 29
<6>[ 1939.157563] smpboot: CPU 2 is now offline
<5>[ 1939.184256] Broke affinity for irq 21
<5>[ 1939.184257] Broke affinity for irq 25
<5>[ 1939.184259] Broke affinity for irq 29
<6>[ 1939.185267] smpboot: CPU 3 is now offline
<5>[ 1939.200265] Broke affinity for irq 21
<5>[ 1939.200270] Broke affinity for irq 25
<5>[ 1939.200273] Broke affinity for irq 29
<6>[ 1939.201285] smpboot: CPU 4 is now offline
<5>[ 1939.224204] Broke affinity for irq 21
<5>[ 1939.224207] Broke affinity for irq 23
<5>[ 1939.224209] Broke affinity for irq 25
<5>[ 1939.224210] Broke affinity for irq 29
<6>[ 1939.225216] smpboot: CPU 5 is now offline
<5>[ 1939.248168] Broke affinity for irq 21
<5>[ 1939.248171] Broke affinity for irq 23
<5>[ 1939.248173] Broke affinity for irq 25
<5>[ 1939.248175] Broke affinity for irq 26
<5>[ 1939.248177] Broke affinity for irq 29
<6>[ 1939.249188] smpboot: CPU 6 is now offline
<5>[ 1939.272173] Broke affinity for irq 1
<5>[ 1939.272184] Broke affinity for irq 9
<5>[ 1939.272189] Broke affinity for irq 12
<5>[ 1939.272195] Broke affinity for irq 21
<5>[ 1939.272199] Broke affinity for irq 23
<5>[ 1939.272202] Broke affinity for irq 25
<5>[ 1939.272203] Broke affinity for irq 26
<5>[ 1939.272207] Broke affinity for irq 29
<5>[ 1939.272209] Broke affinity for irq 30
<6>[ 1939.273237] smpboot: CPU 7 is now offline
<6>[ 1939.293291] ACPI: Low-level resume complete
<6>[ 1939.293337] ACPI : EC: EC started
<6>[ 1939.293337] PM: Restoring platform NVS memory
<6>[ 1939.293648] mce: [Hardware Error]: Machine check events logged
<6>[ 1939.293653] Enabling non-boot CPUs ...
<6>[ 1939.317368] x86: Booting SMP configuration:
<6>[ 1939.317369] smpboot: Booting Node 0 Processor 1 APIC 0x1
<4>[ 1939.319997]  cache: parent cpu1 should not be sleeping
<6>[ 1939.320142] CPU1 is up
<6>[ 1939.341384] smpboot: Booting Node 0 Processor 2 APIC 0x2
<4>[ 1939.343936]  cache: parent cpu2 should not be sleeping
<6>[ 1939.344101] CPU2 is up
<6>[ 1939.385410] smpboot: Booting Node 0 Processor 3 APIC 0x3
<4>[ 1939.387954]  cache: parent cpu3 should not be sleeping
<6>[ 1939.388125] CPU3 is up
<6>[ 1939.409438] smpboot: Booting Node 0 Processor 4 APIC 0x4
<4>[ 1939.412017]  cache: parent cpu4 should not be sleeping
<6>[ 1939.412207] CPU4 is up
<6>[ 1939.433466] smpboot: Booting Node 0 Processor 5 APIC 0x5
<4>[ 1939.436011]  cache: parent cpu5 should not be sleeping
<6>[ 1939.436204] CPU5 is up
<6>[ 1939.465495] smpboot: Booting Node 0 Processor 6 APIC 0x6
<4>[ 1939.468076]  cache: parent cpu6 should not be sleeping
<6>[ 1939.468273] CPU6 is up
<6>[ 1939.493525] smpboot: Booting Node 0 Processor 7 APIC 0x7
<4>[ 1939.496095]  cache: parent cpu7 should not be sleeping
<6>[ 1939.496628] CPU7 is up
<6>[ 1939.515103] ACPI: Waking up from system sleep state S3
<6>[ 1939.516011] acpi LNXPOWER:01: Turning OFF
<6>[ 1939.521536] ehci-pci 0000:00:1a.0: System wakeup disabled by ACPI
<6>[ 1939.521582] ehci-pci 0000:00:1d.0: System wakeup disabled by ACPI
<6>[ 1939.521605] xhci_hcd 0000:00:14.0: System wakeup disabled by ACPI
<6>[ 1940.097446] PM: noirq resume of devices complete after 581.341 msecs
<6>[ 1940.097746] PM: early resume of devices complete after 0.286 msecs
<6>[ 1940.097909] rtsx_pci 0000:0a:00.0: enabling device (0400 -> 0402)
<6>[ 1940.097952] r8169 0000:09:00.0: System wakeup disabled by ACPI
<3>[ 1940.099424] dpm_run_callback(): pci_pm_resume+0x0/0xa0 returns -110
<3>[ 1940.099425] PM: Device 0000:0a:00.0 failed to resume async: error -110
<5>[ 1940.101891] sd 4:0:0:0: [sda] Starting disk
<6>[ 1940.115668] r8169 0000:09:00.0 eth0: link down
<4>[ 1940.152347] xhci_hcd 0000:00:14.0: port 6 resume PLC timeout
<6>[ 1940.201944] rtc_cmos 00:02: System wakeup disabled by ACPI
<6>[ 1940.389539] usb 3-7: reset full-speed USB device number 4 using 
xhci_hcd
<6>[ 1940.649603] usb 3-6: reset high-speed USB device number 3 using 
xhci_hcd
<6>[ 1940.807937] PM: resume of devices complete after 710.116 msecs
<4>[ 1940.807974] usb 3-7:1.0: rebind failed: -517
<4>[ 1940.807979] usb 3-7:1.1: rebind failed: -517
<7>[ 1940.808180] PM: Finishing wakeup.
<6>[ 1940.808181] Restarting tasks ... done.
<6>[ 1940.826021] Bluetooth: hci0: read Intel version: 370710018002030d00
<6>[ 1942.453623] ata5: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
<6>[ 1942.579716] ata5.00: configured for UDMA/133
<6>[ 1942.674254] Bluetooth: hci0: Intel Bluetooth firmware file: 
intel/ibt-hw-37.7.10-fw-1.80.2.3.d.bseq
<6>[ 1942.875193] Bluetooth: hci0: Intel Bluetooth firmware patch 
completed and activated
<6>[ 1943.232532] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<6>[ 1943.232795] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<6>[ 1943.439602] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<6>[ 1943.439866] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<6>[ 1943.471779] r8169 0000:09:00.0 eth0: link down
<6>[ 1946.905112] wlan0: authenticate with 00:21:27:de:51:8e
<6>[ 1946.907233] wlan0: send auth to 00:21:27:de:51:8e (try 1/3)
<6>[ 1946.909100] wlan0: authenticated
<6>[ 1946.909228] iwlwifi 0000:08:00.0 wlan0: disabling HT as WMM/QoS is 
not supported by the AP
<6>[ 1946.909229] iwlwifi 0000:08:00.0 wlan0: disabling VHT as WMM/QoS 
is not supported by the AP
<6>[ 1946.910032] wlan0: associate with 00:21:27:de:51:8e (try 1/3)
<6>[ 1946.913364] wlan0: RX AssocResp from 00:21:27:de:51:8e 
(capab=0x431 status=0 aid=3)
<6>[ 1946.922335] wlan0: associated
<6>[ 2872.634517] ideapad_laptop: Unknown event: 1
<6>[ 2872.914158] ideapad_laptop: Unknown event: 1
<6>[ 5900.216461] wlan0: deauthenticating from 00:21:27:de:51:8e by 
local choice (Reason: 3=DEAUTH_LEAVING)
<6>[ 5910.336800] PM: Syncing filesystems ... done.
<7>[ 5910.569412] PM: Preparing system for sleep (mem)
<6>[ 5910.569956] Freezing user space processes ... (elapsed 0.002 
seconds) done.
<6>[ 5910.572543] Double checking all user space processes after OOM 
killer disable... (elapsed 0.000 seconds)
<6>[ 5910.572778] Freezing remaining freezable tasks ... (elapsed 0.001 
seconds) done.
<7>[ 5910.574344] PM: Suspending system (mem)
<4>[ 5910.574406] Suspending console(s) (use no_console_suspend to debug)
<5>[ 5910.574940] sd 4:0:0:0: [sda] Synchronizing SCSI cache
<5>[ 5910.655687] sd 4:0:0:0: [sda] Stopping disk
<6>[ 5912.019835] PM: suspend of devices complete after 1444.999 msecs
<3>[ 5912.020242] [drm:hsw_write_dcomp [i915]] *ERROR* Failed to write 
to D_COMP
<6>[ 5912.036458] PM: late suspend of devices complete after 16.616 msecs
<6>[ 5912.037471] ehci-pci 0000:00:1d.0: System wakeup enabled by ACPI
<6>[ 5912.037505] r8169 0000:09:00.0: System wakeup enabled by ACPI
<6>[ 5912.037628] ehci-pci 0000:00:1a.0: System wakeup enabled by ACPI
<6>[ 5912.037650] xhci_hcd 0000:00:14.0: System wakeup enabled by ACPI
<6>[ 5912.364384] PM: noirq suspend of devices complete after 327.895 msecs
<6>[ 5912.364660] ACPI: Preparing to enter system sleep state S3
<6>[ 5912.380540] ACPI : EC: EC stopped
<6>[ 5912.380541] PM: Saving platform NVS memory
<6>[ 5912.380551] Disabling non-boot CPUs ...
<5>[ 5912.380817] Broke affinity for irq 21
<5>[ 5912.380819] Broke affinity for irq 25
<6>[ 5912.382119] smpboot: CPU 1 is now offline
<5>[ 5912.397065] Broke affinity for irq 21
<5>[ 5912.397067] Broke affinity for irq 25
<6>[ 5912.398085] smpboot: CPU 2 is now offline
<5>[ 5912.421018] Broke affinity for irq 21
<5>[ 5912.421019] Broke affinity for irq 25
<5>[ 5912.421021] Broke affinity for irq 29
<6>[ 5912.422028] smpboot: CPU 3 is now offline
<5>[ 5912.448982] Broke affinity for irq 21
<5>[ 5912.448987] Broke affinity for irq 25
<5>[ 5912.448989] Broke affinity for irq 29
<6>[ 5912.450004] smpboot: CPU 4 is now offline
<5>[ 5912.476934] Broke affinity for irq 21
<5>[ 5912.476938] Broke affinity for irq 23
<5>[ 5912.476939] Broke affinity for irq 25
<5>[ 5912.476940] Broke affinity for irq 29
<6>[ 5912.477949] smpboot: CPU 5 is now offline
<5>[ 5912.504892] Broke affinity for irq 21
<5>[ 5912.504896] Broke affinity for irq 23
<5>[ 5912.504898] Broke affinity for irq 25
<5>[ 5912.504899] Broke affinity for irq 26
<5>[ 5912.504902] Broke affinity for irq 29
<6>[ 5912.505918] smpboot: CPU 6 is now offline
<5>[ 5912.520847] Broke affinity for irq 1
<5>[ 5912.520854] Broke affinity for irq 9
<5>[ 5912.520858] Broke affinity for irq 12
<5>[ 5912.520862] Broke affinity for irq 21
<5>[ 5912.520865] Broke affinity for irq 23
<5>[ 5912.520866] Broke affinity for irq 25
<5>[ 5912.520867] Broke affinity for irq 26
<5>[ 5912.520869] Broke affinity for irq 29
<5>[ 5912.520870] Broke affinity for irq 30
<6>[ 5912.521875] smpboot: CPU 7 is now offline
<6>[ 5912.542386] ACPI: Low-level resume complete
<6>[ 5912.542433] ACPI : EC: EC started
<6>[ 5912.542434] PM: Restoring platform NVS memory
<6>[ 5912.542746] mce: [Hardware Error]: Machine check events logged
<6>[ 5912.542781] Enabling non-boot CPUs ...
<6>[ 5912.566267] x86: Booting SMP configuration:
<6>[ 5912.566268] smpboot: Booting Node 0 Processor 1 APIC 0x1
<4>[ 5912.568897]  cache: parent cpu1 should not be sleeping
<6>[ 5912.569045] CPU1 is up
<6>[ 5912.590285] smpboot: Booting Node 0 Processor 2 APIC 0x2
<4>[ 5912.592844]  cache: parent cpu2 should not be sleeping
<6>[ 5912.593010] CPU2 is up
<6>[ 5912.622309] smpboot: Booting Node 0 Processor 3 APIC 0x3
<4>[ 5912.624854]  cache: parent cpu3 should not be sleeping
<6>[ 5912.625024] CPU3 is up
<6>[ 5912.674338] smpboot: Booting Node 0 Processor 4 APIC 0x4
<4>[ 5912.676890]  cache: parent cpu4 should not be sleeping
<6>[ 5912.677082] CPU4 is up
<6>[ 5912.698376] smpboot: Booting Node 0 Processor 5 APIC 0x5
<4>[ 5912.700938]  cache: parent cpu5 should not be sleeping
<6>[ 5912.701137] CPU5 is up
<6>[ 5912.730396] smpboot: Booting Node 0 Processor 6 APIC 0x6
<4>[ 5912.732971]  cache: parent cpu6 should not be sleeping
<6>[ 5912.733151] CPU6 is up
<6>[ 5912.758424] smpboot: Booting Node 0 Processor 7 APIC 0x7
<4>[ 5912.760995]  cache: parent cpu7 should not be sleeping
<6>[ 5912.761527] CPU7 is up
<6>[ 5912.779982] ACPI: Waking up from system sleep state S3
<6>[ 5912.780855] acpi LNXPOWER:01: Turning OFF
<6>[ 5912.786395] ehci-pci 0000:00:1d.0: System wakeup disabled by ACPI
<6>[ 5912.786407] xhci_hcd 0000:00:14.0: System wakeup disabled by ACPI
<6>[ 5912.786545] ehci-pci 0000:00:1a.0: System wakeup disabled by ACPI
<6>[ 5913.346326] PM: noirq resume of devices complete after 565.389 msecs
<6>[ 5913.346620] PM: early resume of devices complete after 0.280 msecs
<6>[ 5913.346828] r8169 0000:09:00.0: System wakeup disabled by ACPI
<3>[ 5913.348398] dpm_run_callback(): pci_pm_resume+0x0/0xa0 returns -110
<3>[ 5913.348399] PM: Device 0000:0a:00.0 failed to resume async: error -110
<5>[ 5913.348613] sd 4:0:0:0: [sda] Starting disk
<6>[ 5913.364509] r8169 0000:09:00.0 eth0: link down
<4>[ 5913.397228] xhci_hcd 0000:00:14.0: port 6 resume PLC timeout
<6>[ 5913.453224] rtc_cmos 00:02: System wakeup disabled by ACPI
<6>[ 5913.634457] usb 3-6: reset high-speed USB device number 3 using 
xhci_hcd
<6>[ 5913.894440] usb 3-7: reset full-speed USB device number 4 using 
xhci_hcd
<6>[ 5914.049894] PM: resume of devices complete after 703.212 msecs
<4>[ 5914.049921] usb 3-7:1.0: rebind failed: -517
<4>[ 5914.049925] usb 3-7:1.1: rebind failed: -517
<7>[ 5914.050064] PM: Finishing wakeup.
<6>[ 5914.050065] Restarting tasks ... done.
<6>[ 5914.065768] Bluetooth: hci0: read Intel version: 370710018002030d00
<6>[ 5914.065773] Bluetooth: hci0: Intel Bluetooth firmware file: 
intel/ibt-hw-37.7.10-fw-1.80.2.3.d.bseq
<6>[ 5914.245791] Bluetooth: hci0: Intel Bluetooth firmware patch 
completed and activated
<6>[ 5915.642435] ata5: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
<6>[ 5915.770131] ata5.00: configured for UDMA/133
<6>[ 5915.998047] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<6>[ 5915.998314] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<6>[ 5916.209257] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<6>[ 5916.209520] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<6>[ 5916.248558] r8169 0000:09:00.0 eth0: link down
<6>[ 5919.699825] wlan0: authenticate with 00:21:27:de:51:8e
<6>[ 5919.701881] wlan0: send auth to 00:21:27:de:51:8e (try 1/3)
<6>[ 5919.703735] wlan0: authenticated
<6>[ 5919.703864] iwlwifi 0000:08:00.0 wlan0: disabling HT as WMM/QoS is 
not supported by the AP
<6>[ 5919.703866] iwlwifi 0000:08:00.0 wlan0: disabling VHT as WMM/QoS 
is not supported by the AP
<6>[ 5919.706783] wlan0: associate with 00:21:27:de:51:8e (try 1/3)
<6>[ 5919.709226] wlan0: RX AssocResp from 00:21:27:de:51:8e 
(capab=0x431 status=0 aid=2)
<6>[ 5919.710414] wlan0: associated
<6>[36177.317658] ideapad_laptop: Unknown event: 1
<6>[37314.059460] wlan0: authenticate with 00:21:27:de:51:8e
<6>[37314.061528] wlan0: send auth to 00:21:27:de:51:8e (try 1/3)
<6>[37314.063255] wlan0: authenticated
<6>[37314.063343] iwlwifi 0000:08:00.0 wlan0: disabling HT as WMM/QoS is 
not supported by the AP
<6>[37314.063345] iwlwifi 0000:08:00.0 wlan0: disabling VHT as WMM/QoS 
is not supported by the AP
<6>[37314.066557] wlan0: associate with 00:21:27:de:51:8e (try 1/3)
<6>[37314.069146] wlan0: RX AssocResp from 00:21:27:de:51:8e 
(capab=0x431 status=0 aid=2)
<6>[37314.078201] wlan0: associated
<3>[37750.190201] iwlwifi 0000:08:00.0: Microcode SW error detected.  
Restarting 0x2000000.
<3>[37750.190206] iwlwifi 0000:08:00.0: CSR values:
<3>[37750.190207] iwlwifi 0000:08:00.0: (2nd byte of CSR_INT_COALESCING 
is CSR_INT_PERIODIC_REG)
<3>[37750.190212] iwlwifi 0000:08:00.0: CSR_HW_IF_CONFIG_REG: 0X40489204
<3>[37750.190226] iwlwifi 0000:08:00.0: CSR_INT_COALESCING: 0X80000040
<3>[37750.190239] iwlwifi 0000:08:00.0: CSR_INT: 0X00000000
<3>[37750.190253] iwlwifi 0000:08:00.0: CSR_INT_MASK: 0X00000000
<3>[37750.190267] iwlwifi 0000:08:00.0: CSR_FH_INT_STATUS: 0X00000000
<3>[37750.190281] iwlwifi 0000:08:00.0: CSR_GPIO_IN: 0X00000000
<3>[37750.190294] iwlwifi 0000:08:00.0: CSR_RESET: 0X00000000
<3>[37750.190308] iwlwifi 0000:08:00.0: CSR_GP_CNTRL: 0X080403c5
<3>[37750.190322] iwlwifi 0000:08:00.0: CSR_HW_REV: 0X00000144
<3>[37750.190336] iwlwifi 0000:08:00.0: CSR_EEPROM_REG: 0X00000000
<3>[37750.190350] iwlwifi 0000:08:00.0: CSR_EEPROM_GP: 0X80000000
<3>[37750.190363] iwlwifi 0000:08:00.0: CSR_OTP_GP_REG: 0X803a0000
<3>[37750.190377] iwlwifi 0000:08:00.0: CSR_GIO_REG: 0X001f0042
<3>[37750.190391] iwlwifi 0000:08:00.0: CSR_GP_UCODE_REG: 0X00000000
<3>[37750.190405] iwlwifi 0000:08:00.0: CSR_GP_DRIVER_REG: 0X00000000
<3>[37750.190419] iwlwifi 0000:08:00.0: CSR_UCODE_DRV_GP1: 0X00000000
<3>[37750.190432] iwlwifi 0000:08:00.0: CSR_UCODE_DRV_GP2: 0X00000000
<3>[37750.190446] iwlwifi 0000:08:00.0: CSR_LED_REG: 0X00000060
<3>[37750.190460] iwlwifi 0000:08:00.0: CSR_DRAM_INT_TBL_REG: 0X881530a3
<3>[37750.190474] iwlwifi 0000:08:00.0: CSR_GIO_CHICKEN_BITS: 0X27800200
<3>[37750.190488] iwlwifi 0000:08:00.0: CSR_ANA_PLL_CFG: 0Xd55555d5
<3>[37750.190501] iwlwifi 0000:08:00.0: CSR_MONITOR_STATUS_REG: 0X3d0801bd
<3>[37750.190515] iwlwifi 0000:08:00.0: CSR_HW_REV_WA_REG: 0X0001001a
<3>[37750.190529] iwlwifi 0000:08:00.0: CSR_DBG_HPET_MEM_REG: 0Xffff0010
<3>[37750.190530] iwlwifi 0000:08:00.0: FH register values:
<3>[37750.190552] iwlwifi 0000:08:00.0: FH_RSCSR_CHNL0_STTS_WPTR_REG: 
0X15005f00
<3>[37750.190566] iwlwifi 0000:08:00.0: FH_RSCSR_CHNL0_RBDCB_BASE_REG: 
0X015005e0
<3>[37750.190580] iwlwifi 0000:08:00.0: FH_RSCSR_CHNL0_WPTR: 0X000000e8
<3>[37750.190593] iwlwifi 0000:08:00.0: FH_MEM_RCSR_CHNL0_CONFIG_REG: 
0X80801114
<3>[37750.190607] iwlwifi 0000:08:00.0: FH_MEM_RSSR_SHARED_CTRL_REG: 
0X000000fc
<3>[37750.190621] iwlwifi 0000:08:00.0: FH_MEM_RSSR_RX_STATUS_REG: 
0X07030000
<3>[37750.190635] iwlwifi 0000:08:00.0: 
FH_MEM_RSSR_RX_ENABLE_ERR_IRQ2DRV: 0X00000000
<3>[37750.190648] iwlwifi 0000:08:00.0: FH_TSSR_TX_STATUS_REG: 0X07ff0001
<3>[37750.190662] iwlwifi 0000:08:00.0: FH_TSSR_TX_ERROR_REG: 0X00000000
<3>[37750.190790] iwlwifi 0000:08:00.0: Start IWL Error Log Dump:
<3>[37750.190791] iwlwifi 0000:08:00.0: Status: 0x00000000, count: 6
<3>[37750.190793] iwlwifi 0000:08:00.0: Loaded firmware version: 16.242414.0
<3>[37750.190794] iwlwifi 0000:08:00.0: 0x0000307C | ADVANCED_SYSASSERT
<3>[37750.190796] iwlwifi 0000:08:00.0: 0x00A00220 | trm_hw_status0
<3>[37750.190797] iwlwifi 0000:08:00.0: 0x00000000 | trm_hw_status1
<3>[37750.190798] iwlwifi 0000:08:00.0: 0x00000B2C | branchlink2
<3>[37750.190799] iwlwifi 0000:08:00.0: 0x00016A90 | interruptlink1
<3>[37750.190800] iwlwifi 0000:08:00.0: 0x00248200 | interruptlink2
<3>[37750.190801] iwlwifi 0000:08:00.0: 0xDEADBEEF | data1
<3>[37750.190802] iwlwifi 0000:08:00.0: 0xDEADBEEF | data2
<3>[37750.190803] iwlwifi 0000:08:00.0: 0xDEADBEEF | data3
<3>[37750.190804] iwlwifi 0000:08:00.0: 0x2E814E9A | beacon time
<3>[37750.190806] iwlwifi 0000:08:00.0: 0x1A86E167 | tsf low
<3>[37750.190807] iwlwifi 0000:08:00.0: 0x00000000 | tsf hi
<3>[37750.190808] iwlwifi 0000:08:00.0: 0x00000000 | time gp1
<3>[37750.190809] iwlwifi 0000:08:00.0: 0x693ED4E8 | time gp2
<3>[37750.190810] iwlwifi 0000:08:00.0: 0x00000000 | uCode revision type
<3>[37750.190811] iwlwifi 0000:08:00.0: 0x00000010 | uCode version major
<3>[37750.190812] iwlwifi 0000:08:00.0: 0x0003B2EE | uCode version minor
<3>[37750.190814] iwlwifi 0000:08:00.0: 0x00000144 | hw version
<3>[37750.190815] iwlwifi 0000:08:00.0: 0x40489204 | board version
<3>[37750.190816] iwlwifi 0000:08:00.0: 0x0000001C | hcmd
<3>[37750.190817] iwlwifi 0000:08:00.0: 0x24002042 | isr0
<3>[37750.190818] iwlwifi 0000:08:00.0: 0x01800000 | isr1
<3>[37750.190819] iwlwifi 0000:08:00.0: 0x0000000A | isr2
<3>[37750.190820] iwlwifi 0000:08:00.0: 0x40400080 | isr3
<3>[37750.190821] iwlwifi 0000:08:00.0: 0x00000000 | isr4
<3>[37750.190822] iwlwifi 0000:08:00.0: 0x00800110 | last cmd Id
<3>[37750.190823] iwlwifi 0000:08:00.0: 0x00000000 | wait_event
<3>[37750.190824] iwlwifi 0000:08:00.0: 0x00006208 | l2p_control
<3>[37750.190826] iwlwifi 0000:08:00.0: 0x00018030 | l2p_duration
<3>[37750.190827] iwlwifi 0000:08:00.0: 0x0000033F | l2p_mhvalid
<3>[37750.190828] iwlwifi 0000:08:00.0: 0x00000000 | l2p_addr_match
<3>[37750.190829] iwlwifi 0000:08:00.0: 0x00000005 | lmpm_pmg_sel
<3>[37750.190830] iwlwifi 0000:08:00.0: 0x17111905 | timestamp
<3>[37750.190831] iwlwifi 0000:08:00.0: 0x062CE8F8 | flow_handler
<6>[37750.190837] ieee80211 phy0: Hardware restart was requested
<6>[37750.602417] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<6>[37750.602683] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<6>[37750.820683] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<6>[37750.820949] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<3>[37770.184581] iwlwifi 0000:08:00.0: regular scan timed out
<3>[37780.937336] iwlwifi 0000:08:00.0: Queue 2 stuck for 10000 ms.
<3>[37780.937366] iwlwifi 0000:08:00.0: Current SW read_ptr 174 
write_ptr 176
<3>[37780.937409] iwl data: 00000000: 00 00 00 00 00 00 00 00 00 00 00 
00 00 00 00 00  ................
<3>[37780.937439] iwlwifi 0000:08:00.0: FH TRBs(0) = 0x00000000
<3>[37780.937473] iwlwifi 0000:08:00.0: FH TRBs(1) = 0x801020af
<3>[37780.937500] iwlwifi 0000:08:00.0: FH TRBs(2) = 0x00000000
<3>[37780.937528] iwlwifi 0000:08:00.0: FH TRBs(3) = 0x00000000
<3>[37780.937565] iwlwifi 0000:08:00.0: FH TRBs(4) = 0x00000000
<3>[37780.937593] iwlwifi 0000:08:00.0: FH TRBs(5) = 0x00000000
<3>[37780.937619] iwlwifi 0000:08:00.0: FH TRBs(6) = 0x00000000
<3>[37780.937646] iwlwifi 0000:08:00.0: FH TRBs(7) = 0x0070906c
<3>[37780.937718] iwlwifi 0000:08:00.0: Q 0 is active and mapped to fifo 
3 ra_tid 0x0000 [0,0]
<3>[37780.937790] iwlwifi 0000:08:00.0: Q 1 is active and mapped to fifo 
2 ra_tid 0x0000 [0,0]
<3>[37780.937863] iwlwifi 0000:08:00.0: Q 2 is active and mapped to fifo 
1 ra_tid 0x0000 [174,176]
<3>[37780.937934] iwlwifi 0000:08:00.0: Q 3 is active and mapped to fifo 
0 ra_tid 0x0000 [0,0]
<3>[37780.938006] iwlwifi 0000:08:00.0: Q 4 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.938078] iwlwifi 0000:08:00.0: Q 5 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.938150] iwlwifi 0000:08:00.0: Q 6 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.938221] iwlwifi 0000:08:00.0: Q 7 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.938293] iwlwifi 0000:08:00.0: Q 8 is active and mapped to fifo 
3 ra_tid 0x0000 [0,0]
<3>[37780.938364] iwlwifi 0000:08:00.0: Q 9 is active and mapped to fifo 
7 ra_tid 0x0000 [109,109]
<3>[37780.938436] iwlwifi 0000:08:00.0: Q 10 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.938508] iwlwifi 0000:08:00.0: Q 11 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.938580] iwlwifi 0000:08:00.0: Q 12 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.938652] iwlwifi 0000:08:00.0: Q 13 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.938723] iwlwifi 0000:08:00.0: Q 14 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.938795] iwlwifi 0000:08:00.0: Q 15 is active and mapped to 
fifo 5 ra_tid 0x0000 [0,0]
<3>[37780.938866] iwlwifi 0000:08:00.0: Q 16 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.938938] iwlwifi 0000:08:00.0: Q 17 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.939009] iwlwifi 0000:08:00.0: Q 18 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.939081] iwlwifi 0000:08:00.0: Q 19 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.939153] iwlwifi 0000:08:00.0: Q 20 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.939224] iwlwifi 0000:08:00.0: Q 21 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.939296] iwlwifi 0000:08:00.0: Q 22 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.939367] iwlwifi 0000:08:00.0: Q 23 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.939439] iwlwifi 0000:08:00.0: Q 24 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.939510] iwlwifi 0000:08:00.0: Q 25 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.939581] iwlwifi 0000:08:00.0: Q 26 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.939653] iwlwifi 0000:08:00.0: Q 27 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.939724] iwlwifi 0000:08:00.0: Q 28 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.939796] iwlwifi 0000:08:00.0: Q 29 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37780.939868] iwlwifi 0000:08:00.0: Q 30 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37871.055819] iwlwifi 0000:08:00.0: Error sending 
SCAN_OFFLOAD_REQUEST_CMD: time out after 2000ms.
<3>[37871.055825] iwlwifi 0000:08:00.0: Current CMD queue read_ptr 109 
write_ptr 110
<3>[37871.055958] iwlwifi 0000:08:00.0: Loaded firmware version: 16.242414.0
<3>[37871.055960] iwlwifi 0000:08:00.0: 0x00000000 | ADVANCED_SYSASSERT
<3>[37871.055961] iwlwifi 0000:08:00.0: 0x00000000 | trm_hw_status0
<3>[37871.055962] iwlwifi 0000:08:00.0: 0x00000000 | trm_hw_status1
<3>[37871.055963] iwlwifi 0000:08:00.0: 0x00000000 | branchlink2
<3>[37871.055964] iwlwifi 0000:08:00.0: 0x00000000 | interruptlink1
<3>[37871.055965] iwlwifi 0000:08:00.0: 0x00000000 | interruptlink2
<3>[37871.055966] iwlwifi 0000:08:00.0: 0x00000000 | data1
<3>[37871.055967] iwlwifi 0000:08:00.0: 0x00000000 | data2
<3>[37871.055968] iwlwifi 0000:08:00.0: 0x00000000 | data3
<3>[37871.055969] iwlwifi 0000:08:00.0: 0x00000000 | beacon time
<3>[37871.055970] iwlwifi 0000:08:00.0: 0x00000000 | tsf low
<3>[37871.055971] iwlwifi 0000:08:00.0: 0x00000000 | tsf hi
<3>[37871.055972] iwlwifi 0000:08:00.0: 0x00000000 | time gp1
<3>[37871.055973] iwlwifi 0000:08:00.0: 0x00000000 | time gp2
<3>[37871.055974] iwlwifi 0000:08:00.0: 0x00000000 | uCode revision type
<3>[37871.055975] iwlwifi 0000:08:00.0: 0x00000000 | uCode version major
<3>[37871.055977] iwlwifi 0000:08:00.0: 0x00000000 | uCode version minor
<3>[37871.055978] iwlwifi 0000:08:00.0: 0x00000000 | hw version
<3>[37871.055979] iwlwifi 0000:08:00.0: 0x00000000 | board version
<3>[37871.055980] iwlwifi 0000:08:00.0: 0x00000000 | hcmd
<3>[37871.055981] iwlwifi 0000:08:00.0: 0x00000000 | isr0
<3>[37871.055982] iwlwifi 0000:08:00.0: 0x00000000 | isr1
<3>[37871.055983] iwlwifi 0000:08:00.0: 0x00000000 | isr2
<3>[37871.055984] iwlwifi 0000:08:00.0: 0x00000000 | isr3
<3>[37871.055985] iwlwifi 0000:08:00.0: 0x00000000 | isr4
<3>[37871.055986] iwlwifi 0000:08:00.0: 0x00000000 | last cmd Id
<3>[37871.055987] iwlwifi 0000:08:00.0: 0x00000000 | wait_event
<3>[37871.055988] iwlwifi 0000:08:00.0: 0x00000000 | l2p_control
<3>[37871.055989] iwlwifi 0000:08:00.0: 0x00000000 | l2p_duration
<3>[37871.055990] iwlwifi 0000:08:00.0: 0x00000000 | l2p_mhvalid
<3>[37871.055991] iwlwifi 0000:08:00.0: 0x00000000 | l2p_addr_match
<3>[37871.055992] iwlwifi 0000:08:00.0: 0x00000000 | lmpm_pmg_sel
<3>[37871.055993] iwlwifi 0000:08:00.0: 0x00000000 | timestamp
<3>[37871.055994] iwlwifi 0000:08:00.0: 0x00000000 | flow_handler
<6>[37871.055998] ieee80211 phy0: Hardware restart was requested
<3>[37871.056005] iwlwifi 0000:08:00.0: Scan failed! ret -110
<3>[37871.327688] [drm:intel_pipe_update_end [i915]] *ERROR* Atomic 
update failure on pipe A (start=1168161 end=1168162) time 554 us, min 
1073, max 1079, scanline start 1056, end 1084
<3>[37871.411221] [drm:intel_pipe_update_end [i915]] *ERROR* Atomic 
update failure on pipe A (start=1168166 end=1168167) time 637 us, min 
1073, max 1079, scanline start 1071, end 1105
<3>[37871.567789] iwlwifi 0000:08:00.0: Queue 9 stuck for 2500 ms.
<3>[37871.567795] iwlwifi 0000:08:00.0: Current SW read_ptr 109 
write_ptr 110
<3>[37875.221718] iwl data: 00000000: a2 a5 a5 a5 a2 a5 a5 a5 a2 a5 a5 
a5 a2 a5 a5 a5  ................
<3>[37875.221766] iwlwifi 0000:08:00.0: FH TRBs(0) = 0xa5a5a5a2
<3>[37875.221805] iwlwifi 0000:08:00.0: FH TRBs(1) = 0xa5a5a5a2
<3>[37875.221843] iwlwifi 0000:08:00.0: FH TRBs(2) = 0xa5a5a5a2
<3>[37875.221882] iwlwifi 0000:08:00.0: FH TRBs(3) = 0xa5a5a5a2
<3>[37875.221932] iwlwifi 0000:08:00.0: FH TRBs(4) = 0xa5a5a5a2
<3>[37875.221974] iwlwifi 0000:08:00.0: FH TRBs(5) = 0xa5a5a5a2
<3>[37875.222013] iwlwifi 0000:08:00.0: FH TRBs(6) = 0xa5a5a5a2
<3>[37875.222051] iwlwifi 0000:08:00.0: FH TRBs(7) = 0xa5a5a5a2
<3>[37875.222333] iwlwifi 0000:08:00.0: Q 0 is inactive and mapped to 
fifo 2 ra_tid 0xa5a2 [162,-1515870814]
<3>[37875.222613] iwlwifi 0000:08:00.0: Q 1 is inactive and mapped to 
fifo 2 ra_tid 0xa5a5 [162,-1515870814]
<3>[37875.222893] iwlwifi 0000:08:00.0: Q 2 is inactive and mapped to 
fifo 2 ra_tid 0xa5a2 [162,-1515870814]
<3>[37875.223173] iwlwifi 0000:08:00.0: Q 3 is inactive and mapped to 
fifo 2 ra_tid 0xa5a5 [162,-1515870814]
<3>[37875.223452] iwlwifi 0000:08:00.0: Q 4 is inactive and mapped to 
fifo 2 ra_tid 0xa5a2 [162,-1515870814]
<3>[37875.223732] iwlwifi 0000:08:00.0: Q 5 is inactive and mapped to 
fifo 2 ra_tid 0xa5a5 [162,-1515870814]
<3>[37875.224012] iwlwifi 0000:08:00.0: Q 6 is inactive and mapped to 
fifo 2 ra_tid 0xa5a2 [162,-1515870814]
<3>[37875.224313] iwlwifi 0000:08:00.0: Q 7 is inactive and mapped to 
fifo 2 ra_tid 0xa5a5 [162,-1515870814]
<3>[37875.224667] iwlwifi 0000:08:00.0: Q 8 is inactive and mapped to 
fifo 2 ra_tid 0xa5a2 [162,-1515870814]
<3>[37875.224947] iwlwifi 0000:08:00.0: Q 9 is inactive and mapped to 
fifo 2 ra_tid 0xa5a5 [162,-1515870814]
<3>[37875.225227] iwlwifi 0000:08:00.0: Q 10 is inactive and mapped to 
fifo 2 ra_tid 0xa5a2 [162,-1515870814]
<3>[37875.225510] iwlwifi 0000:08:00.0: Q 11 is inactive and mapped to 
fifo 2 ra_tid 0xa5a5 [162,-1515870814]
<3>[37875.287357] iwlwifi 0000:08:00.0: Failing on timeout while 
stopping DMA channel 8 [0xa5a5a5a2]
<3>[37875.287621] iwlwifi 0000:08:00.0: Q 12 is inactive and mapped to 
fifo 2 ra_tid 0xa5a2 [162,-1515870814]
<3>[37875.288110] iwlwifi 0000:08:00.0: Q 13 is inactive and mapped to 
fifo 2 ra_tid 0xa5a5 [162,-1515870814]
<4>[37875.321063] ------------[ cut here ]------------
<4>[37875.321074] WARNING: CPU: 0 PID: 0 at 
drivers/net/wireless/intel/iwlwifi/pcie/trans.c:1790 
iwl_trans_pcie_grab_nic_access+0xf3/0x100 [iwlwifi]
<4>[37875.321074] Timeout waiting for hardware access (CSR_GP_CNTRL 
0x080403d8)
<4>[37875.321075] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37875.321099]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37875.321107] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.8.1 #63
<4>[37875.321108] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37875.321109]  0000000000000000 ffff964ddf203ca8 ffffffff94386f78 
ffff964ddf203cf8
<4>[37875.321111]  0000000000000000 ffff964ddf203ce8 ffffffff9405bf7b 
000006fedf203ce0
<4>[37875.321112]  ffff964dd01a0000 0000000000000000 ffff964dd01a7d64 
ffff964ddf203d88
<4>[37875.321113] Call Trace:
<4>[37875.321114]  <IRQ>  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37875.321122]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37875.321123]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37875.321126]  [<ffffffffc06401df>] ? iwl_read32+0x1f/0x90 [iwlwifi]
<4>[37875.321129]  [<ffffffffc0651ea3>] 
iwl_trans_pcie_grab_nic_access+0xf3/0x100 [iwlwifi]
<4>[37875.321132]  [<ffffffffc064fced>] 
iwl_trans_pcie_read_mem+0x2d/0x90 [iwlwifi]
<4>[37875.321135]  [<ffffffffc0653ef6>] 
iwl_trans_pcie_log_scd_error+0x1e6/0x2f0 [iwlwifi]
<4>[37875.321138]  [<ffffffffc064a910>] ? 
iwl_pcie_txq_inc_wr_ptr+0xf0/0xf0 [iwlwifi]
<4>[37875.321141]  [<ffffffffc064a97a>] 
iwl_pcie_txq_stuck_timer+0x6a/0x90 [iwlwifi]
<4>[37875.321143]  [<ffffffff940c3d25>] call_timer_fn+0x35/0x120
<4>[37875.321144]  [<ffffffff940c4466>] run_timer_softirq+0x206/0x470
<4>[37875.321145]  [<ffffffff940cc5bc>] ? ktime_get+0x3c/0xb0
<4>[37875.321147]  [<ffffffff940d2c02>] ? 
clockevents_program_event+0x82/0x120
<4>[37875.321150]  [<ffffffff946b45d0>] __do_softirq+0xf0/0x274
<4>[37875.321151]  [<ffffffff94061726>] irq_exit+0xd6/0xe0
<4>[37875.321152]  [<ffffffff946b43f2>] smp_apic_timer_interrupt+0x42/0x50
<4>[37875.321153]  [<ffffffff946b3829>] apic_timer_interrupt+0x89/0x90
<4>[37875.321153]  <EOI>  [<ffffffff945b0949>] ? 
cpuidle_enter_state+0x129/0x2c0
<4>[37875.321157]  [<ffffffff945b0b17>] cpuidle_enter+0x17/0x20
<4>[37875.321158]  [<ffffffff9409afaa>] call_cpuidle+0x2a/0x40
<4>[37875.321159]  [<ffffffff9409b34f>] cpu_startup_entry+0x27f/0x310
<4>[37875.321161]  [<ffffffff946abb62>] rest_init+0x72/0x80
<4>[37875.321163]  [<ffffffff94d41f61>] start_kernel+0x42b/0x438
<4>[37875.321164]  [<ffffffff94d4128e>] x86_64_start_reservations+0x24/0x26
<4>[37875.321164]  [<ffffffff94d41412>] x86_64_start_kernel+0x182/0x193
<4>[37875.321165] ---[ end trace c865123de068515a ]---
<4>[37875.321259] ------------[ cut here ]------------
<4>[37875.321264] WARNING: CPU: 0 PID: 0 at 
drivers/net/wireless/intel/iwlwifi/iwl-trans.h:1186 
iwl_trans_pcie_log_scd_error+0x238/0x2f0 [iwlwifi]
<4>[37875.321264] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37875.321290]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37875.321306] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        
W       4.8.1 #63
<4>[37875.321307] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37875.321307]  0000000000000000 ffff964ddf203d60 ffffffff94386f78 
0000000000000000
<4>[37875.321309]  0000000000000000 ffff964ddf203da0 ffffffff9405bf7b 
000004a20080ba7c
<4>[37875.321311]  ffff964dd01a0000 000000000000000e 000000000000a5a5 
0000000000a02e6c
<4>[37875.321313] Call Trace:
<4>[37875.321314]  <IRQ>  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37875.321318]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37875.321320]  [<ffffffff9405c06d>] warn_slowpath_null+0x1d/0x20
<4>[37875.321324]  [<ffffffffc0653f48>] 
iwl_trans_pcie_log_scd_error+0x238/0x2f0 [iwlwifi]
<4>[37875.321329]  [<ffffffffc064a910>] ? 
iwl_pcie_txq_inc_wr_ptr+0xf0/0xf0 [iwlwifi]
<4>[37875.321333]  [<ffffffffc064a97a>] 
iwl_pcie_txq_stuck_timer+0x6a/0x90 [iwlwifi]
<4>[37875.321335]  [<ffffffff940c3d25>] call_timer_fn+0x35/0x120
<4>[37875.321336]  [<ffffffff940c4466>] run_timer_softirq+0x206/0x470
<4>[37875.321338]  [<ffffffff940cc5bc>] ? ktime_get+0x3c/0xb0
<4>[37875.321340]  [<ffffffff940d2c02>] ? 
clockevents_program_event+0x82/0x120
<4>[37875.321342]  [<ffffffff946b45d0>] __do_softirq+0xf0/0x274
<4>[37875.321343]  [<ffffffff94061726>] irq_exit+0xd6/0xe0
<4>[37875.321345]  [<ffffffff946b43f2>] smp_apic_timer_interrupt+0x42/0x50
<4>[37875.321346]  [<ffffffff946b3829>] apic_timer_interrupt+0x89/0x90
<4>[37875.321347]  <EOI>  [<ffffffff945b0949>] ? 
cpuidle_enter_state+0x129/0x2c0
<4>[37875.321350]  [<ffffffff945b0b17>] cpuidle_enter+0x17/0x20
<4>[37875.321351]  [<ffffffff9409afaa>] call_cpuidle+0x2a/0x40
<4>[37875.321353]  [<ffffffff9409b34f>] cpu_startup_entry+0x27f/0x310
<4>[37875.321355]  [<ffffffff946abb62>] rest_init+0x72/0x80
<4>[37875.321356]  [<ffffffff94d41f61>] start_kernel+0x42b/0x438
<4>[37875.321357]  [<ffffffff94d4128e>] x86_64_start_reservations+0x24/0x26
<4>[37875.321358]  [<ffffffff94d41412>] x86_64_start_kernel+0x182/0x193
<4>[37875.321359] ---[ end trace c865123de068515b ]---
<3>[37875.387193] iwlwifi 0000:08:00.0: Q 14 is inactive and mapped to 
fifo 2 ra_tid 0xa5a5 [90,1515870810]
<6>[37875.420152] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<4>[37875.453151] ------------[ cut here ]------------
<4>[37875.453167] WARNING: CPU: 0 PID: 0 at 
drivers/net/wireless/intel/iwlwifi/iwl-trans.h:1186 
iwl_trans_pcie_log_scd_error+0x238/0x2f0 [iwlwifi]
<4>[37875.453168] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37875.453215]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37875.453230] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        
W       4.8.1 #63
<4>[37875.453231] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37875.453232]  0000000000000000 ffff964ddf203d60 ffffffff94386f78 
0000000000000000
<4>[37875.453235]  0000000000000000 ffff964ddf203da0 ffffffff9405bf7b 
000004a20080ba7c
<4>[37875.453237]  ffff964dd01a0000 000000000000000f 000000000000a5a5 
0000000000a02e70
<4>[37875.453240] Call Trace:
<4>[37875.453241]  <IRQ>  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37875.453250]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37875.453253]  [<ffffffff9405c06d>] warn_slowpath_null+0x1d/0x20
<6>[37875.453254] iwlwifi 0000:08:00.0: L1 Enabled - LTR Disabled
<4>[37875.453260]  [<ffffffffc0653f48>] 
iwl_trans_pcie_log_scd_error+0x238/0x2f0 [iwlwifi]
<4>[37875.453266]  [<ffffffffc064a910>] ? 
iwl_pcie_txq_inc_wr_ptr+0xf0/0xf0 [iwlwifi]
<4>[37875.453271]  [<ffffffffc064a97a>] 
iwl_pcie_txq_stuck_timer+0x6a/0x90 [iwlwifi]
<4>[37875.453273]  [<ffffffff940c3d25>] call_timer_fn+0x35/0x120
<4>[37875.453275]  [<ffffffff940c4466>] run_timer_softirq+0x206/0x470
<4>[37875.453278]  [<ffffffff940cc5bc>] ? ktime_get+0x3c/0xb0
<4>[37875.453280]  [<ffffffff940d2c02>] ? 
clockevents_program_event+0x82/0x120
<4>[37875.453284]  [<ffffffff946b45d0>] __do_softirq+0xf0/0x274
<4>[37875.453286]  [<ffffffff94061726>] irq_exit+0xd6/0xe0
<4>[37875.453288]  [<ffffffff946b43f2>] smp_apic_timer_interrupt+0x42/0x50
<4>[37875.453290]  [<ffffffff946b3829>] apic_timer_interrupt+0x89/0x90
<4>[37875.453291]  <EOI>  [<ffffffff945b0949>] ? 
cpuidle_enter_state+0x129/0x2c0
<4>[37875.453296]  [<ffffffff945b0b17>] cpuidle_enter+0x17/0x20
<4>[37875.453297]  [<ffffffff9409afaa>] call_cpuidle+0x2a/0x40
<4>[37875.453299]  [<ffffffff9409b34f>] cpu_startup_entry+0x27f/0x310
<4>[37875.453301]  [<ffffffff946abb62>] rest_init+0x72/0x80
<4>[37875.453303]  [<ffffffff94d41f61>] start_kernel+0x42b/0x438
<4>[37875.453305]  [<ffffffff94d4128e>] x86_64_start_reservations+0x24/0x26
<4>[37875.453306]  [<ffffffff94d41412>] x86_64_start_kernel+0x182/0x193
<4>[37875.453307] ---[ end trace c865123de068515c ]---
<3>[37875.453363] iwlwifi 0000:08:00.0: Q 15 is active and mapped to 
fifo 2 ra_tid 0xa5a5 [0,0]
<3>[37875.453457] iwlwifi 0000:08:00.0: Q 16 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37875.453548] iwlwifi 0000:08:00.0: Q 17 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37875.453606] iwlwifi 0000:08:00.0: Q 18 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37875.453707] iwlwifi 0000:08:00.0: Q 19 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37875.453807] iwlwifi 0000:08:00.0: Q 20 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37875.453906] iwlwifi 0000:08:00.0: Q 21 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37875.454006] iwlwifi 0000:08:00.0: Q 22 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37875.454105] iwlwifi 0000:08:00.0: Q 23 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37875.454204] iwlwifi 0000:08:00.0: Q 24 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37875.454303] iwlwifi 0000:08:00.0: Q 25 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37875.454403] iwlwifi 0000:08:00.0: Q 26 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37875.454507] iwlwifi 0000:08:00.0: Q 27 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37875.454598] iwlwifi 0000:08:00.0: Q 28 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37875.454655] iwlwifi 0000:08:00.0: Q 29 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37875.454711] iwlwifi 0000:08:00.0: Q 30 is inactive and mapped to 
fifo 0 ra_tid 0x0000 [0,0]
<3>[37876.464196] iwlwifi 0000:08:00.0: Failed to start INIT ucode: -110
<3>[37876.464201] iwlwifi 0000:08:00.0: Failed to run INIT ucode: -110
<4>[37876.470335] ------------[ cut here ]------------
<4>[37876.470364] WARNING: CPU: 2 PID: 3862 at net/mac80211/util.c:1822 
ieee80211_reconfig+0x1e4/0xfb0 [mac80211]
<4>[37876.470364] Hardware became unavailable during restart.
<4>[37876.470365] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.470395]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.470406] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.470407] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.470416] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.470418]  0000000000000000 ffff964d8b357cf8 ffffffff94386f78 
ffff964d8b357d48
<4>[37876.470420]  0000000000000000 ffff964d8b357d38 ffffffff9405bf7b 
0000071ed74046e0
<4>[37876.470421]  ffff964dd74046e0 00000000ffffff92 ffff964dd74053b8 
ffff964dd74046e0
<4>[37876.470423] Call Trace:
<4>[37876.470427]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.470430]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.470431]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.470441]  [<ffffffffc090b4b4>] ? drv_start+0x44/0x110 [mac80211]
<4>[37876.470453]  [<ffffffffc093c884>] ieee80211_reconfig+0x1e4/0xfb0 
[mac80211]
<4>[37876.470461]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.470465]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.470466]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.470468]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.470470]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.470472]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.470473]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.470474] ---[ end trace c865123de068515d ]---
<4>[37876.470483] ------------[ cut here ]------------
<4>[37876.470492] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 drv_remove_interface+0x10d/0x120 [mac80211]
<4>[37876.470493] p2p-dev-wlan0:  Failed check-sdata-in-driver check, 
flags: 0x0
<4>[37876.470493] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.470513]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.470520] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.470521] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.470530] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.470530]  0000000000000000 ffff964d8b357bb8 ffffffff94386f78 
ffff964d8b357c08
<4>[37876.470532]  0000000000000000 ffff964d8b357bf8 ffffffff9405bf7b 
000000118b357c10
<4>[37876.470534]  ffff964ce146d000 ffff964ce146d000 ffff964dd74046e0 
ffff964dd7404ec8
<4>[37876.470535] Call Trace:
<4>[37876.470537]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.470539]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.470541]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.470543]  [<ffffffff945fbc53>] ? synchronize_net+0x23/0x30
<4>[37876.470552]  [<ffffffffc090ba0d>] drv_remove_interface+0x10d/0x120 
[mac80211]
<4>[37876.470562]  [<ffffffffc0920031>] ieee80211_do_stop+0x501/0x7e0 
[mac80211]
<4>[37876.470572]  [<ffffffffc09216ce>] ieee80211_sdata_stop+0x1e/0x50 
[mac80211]
<4>[37876.470583]  [<ffffffffc0925092>] 
ieee80211_stop_p2p_device+0x12/0x20 [mac80211]
<4>[37876.470600]  [<ffffffffc05a2b6b>] 
cfg80211_stop_p2p_device+0x5b/0x190 [cfg80211]
<4>[37876.470608]  [<ffffffffc05a2d0c>] 
cfg80211_shutdown_all_interfaces+0x6c/0xb0 [cfg80211]
<4>[37876.470620]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.470631]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.470639]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.470641]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.470643]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.470644]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.470646]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.470647]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.470649]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.470649] ---[ end trace c865123de068515e ]---
<6>[37876.470660] wlan0: deauthenticating from 00:21:27:de:51:8e by 
local choice (Reason: 3=DEAUTH_LEAVING)
<4>[37876.470662] ------------[ cut here ]------------
<4>[37876.470671] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 
ieee80211_bss_info_change_notify+0x1ba/0x1c0 [mac80211]
<4>[37876.470672] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.470672] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.470692]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.470699] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.470699] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.470708] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.470709]  0000000000000000 ffff964d8b357968 ffffffff94386f78 
ffff964d8b3579b8
<4>[37876.470710]  0000000000000000 ffff964d8b3579a8 ffffffff9405bf7b 
00000011da494800
<4>[37876.470712]  ffff964dcbdd07c0 0000000000020000 0000000000000001 
ffff964dd74046e0
<4>[37876.470714] Call Trace:
<4>[37876.470716]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.470718]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.470719]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.470728]  [<ffffffffc0909efa>] 
ieee80211_bss_info_change_notify+0x1ba/0x1c0 [mac80211]
<4>[37876.470740]  [<ffffffffc09552fd>] 
ieee80211_recalc_ps_vif+0x2d/0x30 [mac80211]
<4>[37876.470750]  [<ffffffffc0955383>] 
ieee80211_set_disassoc+0x83/0x3f0 [mac80211]
<4>[37876.470761]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.470772]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.470783]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.470792]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.470802]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.470810]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.470818]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.470826]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.470828]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.470830]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.470832]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.470833]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.470834]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.470836]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.470838]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.470845]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.470857]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.470868]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.470876]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.470879]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.470880]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.470882]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.470884]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.470885]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.470886]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.470887] ---[ end trace c865123de068515f ]---
<4>[37876.470889] ------------[ cut here ]------------
<4>[37876.470901] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 __ieee80211_flush_queues+0x1c0/0x1d0 [mac80211]
<4>[37876.470902] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.470902] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.470923]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.470930] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.470930] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.470939] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.470940]  0000000000000000 ffff964d8b357968 ffffffff94386f78 
ffff964d8b3579b8
<4>[37876.470942]  0000000000000000 ffff964d8b3579a8 ffffffff9405bf7b 
0000001100000000
<4>[37876.470943]  ffff964dd74046e0 000000000000000f 0000000000000001 
ffff964dcbdd09b0
<4>[37876.470945] Call Trace:
<4>[37876.470947]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.470949]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.470951]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.470963]  [<ffffffffc093af00>] 
__ieee80211_flush_queues+0x1c0/0x1d0 [mac80211]
<4>[37876.470976]  [<ffffffffc093af23>] ieee80211_flush_queues+0x13/0x20 
[mac80211]
<4>[37876.470989]  [<ffffffffc0955643>] 
ieee80211_set_disassoc+0x343/0x3f0 [mac80211]
<4>[37876.471003]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.471014]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.471025]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.471036]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.471046]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.471054]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.471062]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.471070]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.471073]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.471074]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.471076]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.471078]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.471079]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.471081]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.471082]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.471090]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.471103]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.471116]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.471124]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.471126]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.471128]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.471130]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.471132]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.471133]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.471135]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.471135] ---[ end trace c865123de0685160 ]---
<4>[37876.471142] ------------[ cut here ]------------
<4>[37876.471155] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 __ieee80211_flush_queues+0x1c0/0x1d0 [mac80211]
<4>[37876.471155] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.471156] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.471176]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.471183] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.471184] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.471193] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.471193]  0000000000000000 ffff964d8b357968 ffffffff94386f78 
ffff964d8b3579b8
<4>[37876.471195]  0000000000000000 ffff964d8b3579a8 ffffffff9405bf7b 
0000001100000000
<4>[37876.471197]  ffff964dd74046e0 000000000000000f 0000000000000000 
ffff964dcbdd09b0
<4>[37876.471199] Call Trace:
<4>[37876.471201]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.471203]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.471204]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.471217]  [<ffffffffc093af00>] 
__ieee80211_flush_queues+0x1c0/0x1d0 [mac80211]
<4>[37876.471229]  [<ffffffffc093af23>] ieee80211_flush_queues+0x13/0x20 
[mac80211]
<4>[37876.471243]  [<ffffffffc0955673>] 
ieee80211_set_disassoc+0x373/0x3f0 [mac80211]
<4>[37876.471256]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.471267]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.471278]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.471289]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.471300]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.471308]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.471316]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.471324]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.471326]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.471328]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.471329]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.471331]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.471332]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.471334]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.471335]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.471343]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.471356]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.471369]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.471377]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.471380]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.471381]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.471383]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.471385]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.471386]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.471388]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.471389] ---[ end trace c865123de0685161 ]---
<4>[37876.471392] ------------[ cut here ]------------
<4>[37876.471401] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 __sta_info_destroy_part1+0x3ce/0x540 [mac80211]
<4>[37876.471402] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.471402] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.471423]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.471430] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.471430] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.471439] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.471440]  0000000000000000 ffff964d8b357910 ffffffff94386f78 
ffff964d8b357960
<4>[37876.471441]  0000000000000000 ffff964d8b357950 ffffffff9405bf7b 
0000001100000000
<4>[37876.471443]  ffff964dd74046e0 ffff964dd9c70030 ffff964dcbdd07c0 
ffff964dcbed7480
<4>[37876.471445] Call Trace:
<4>[37876.471447]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.471449]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.471450]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.471459]  [<ffffffffc090dc1e>] 
__sta_info_destroy_part1+0x3ce/0x540 [mac80211]
<4>[37876.471468]  [<ffffffffc0910b2b>] __sta_info_flush+0x12b/0x190 
[mac80211]
<4>[37876.471481]  [<ffffffffc09553ba>] 
ieee80211_set_disassoc+0xba/0x3f0 [mac80211]
<4>[37876.471495]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.471506]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.471517]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.471528]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.471538]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.471547]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.471554]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.471562]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.471565]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.471566]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.471568]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.471569]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.471571]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.471573]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.471574]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.471582]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.471595]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.471607]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.471616]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.471618]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.471620]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.471622]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.471623]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.471625]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.471626]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.471627] ---[ end trace c865123de0685162 ]---
<4>[37876.471647] ------------[ cut here ]------------
<4>[37876.471661] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 __ieee80211_key_destroy+0x28b/0x2e0 [mac80211]
<4>[37876.471662] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.471662] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.471682]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.471689] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.471690] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.471699] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.471700]  0000000000000000 ffff964d8b357890 ffffffff94386f78 
ffff964d8b3578e0
<4>[37876.471702]  0000000000000000 ffff964d8b3578d0 ffffffff9405bf7b 
0000001100000005
<4>[37876.471703]  ffff964ce15d1800 ffff964dd74046e0 ffff964dcbdd07c0 
ffff964dd9c707f8
<4>[37876.471705] Call Trace:
<4>[37876.471707]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.471709]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.471711]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.471713]  [<ffffffff940bf5de>] ? synchronize_rcu_expedited+0xe/0x10
<4>[37876.471726]  [<ffffffffc093860b>] 
__ieee80211_key_destroy+0x28b/0x2e0 [mac80211]
<4>[37876.471738]  [<ffffffffc09392bb>] 
ieee80211_free_sta_keys+0xab/0xd0 [mac80211]
<4>[37876.471747]  [<ffffffffc09106c9>] 
__sta_info_destroy_part2+0x29/0x190 [mac80211]
<4>[37876.471756]  [<ffffffffc0910af0>] __sta_info_flush+0xf0/0x190 
[mac80211]
<4>[37876.471769]  [<ffffffffc09553ba>] 
ieee80211_set_disassoc+0xba/0x3f0 [mac80211]
<4>[37876.471782]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.471794]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.471805]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.471816]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.471826]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.471835]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.471843]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.471851]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.471853]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.471854]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.471856]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.471857]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.471859]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.471861]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.471862]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.471870]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.471883]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.471895]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.471903]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.471906]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.471908]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.471910]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.471911]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.471912]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.471914]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.471915] ---[ end trace c865123de0685163 ]---
<3>[37876.471916] wlan0: failed to remove key (0, 00:21:27:de:51:8e) 
from hardware (-5)
<4>[37876.471949] ------------[ cut here ]------------
<4>[37876.471966] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 drv_sta_state+0x1a2/0x460 [mac80211]
<4>[37876.471966] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.471966] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.471982]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.471987] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.471987] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.471994] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.471995]  0000000000000000 ffff964d8b3578c8 ffffffff94386f78 
ffff964d8b357918
<4>[37876.471996]  0000000000000000 ffff964d8b357908 ffffffff9405bf7b 
000000118b357900
<4>[37876.471997]  ffff964dcbdd07c0 ffff964dd74046e0 0000000000000004 
0000000000000003
<4>[37876.471999] Call Trace:
<4>[37876.472000]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.472002]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.472003]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.472012]  [<ffffffffc09384b6>] ? 
__ieee80211_key_destroy+0x136/0x2e0 [mac80211]
<4>[37876.472018]  [<ffffffffc090bbc2>] drv_sta_state+0x1a2/0x460 [mac80211]
<4>[37876.472025]  [<ffffffffc090fc8e>] sta_info_move_state+0x20e/0x330 
[mac80211]
<4>[37876.472031]  [<ffffffffc09106fc>] 
__sta_info_destroy_part2+0x5c/0x190 [mac80211]
<4>[37876.472038]  [<ffffffffc0910af0>] __sta_info_flush+0xf0/0x190 
[mac80211]
<4>[37876.472048]  [<ffffffffc09553ba>] 
ieee80211_set_disassoc+0xba/0x3f0 [mac80211]
<4>[37876.472057]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.472066]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.472075]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.472083]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.472091]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.472097]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.472103]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.472109]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.472111]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.472112]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.472113]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.472114]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.472115]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.472117]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.472118]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.472124]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.472134]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.472152]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.472158]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.472160]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.472161]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.472162]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.472164]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.472164]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.472166]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.472184] ---[ end trace c865123de0685164 ]---
<4>[37876.472185] ------------[ cut here ]------------
<4>[37876.472193] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/sta_info.c:955 __sta_info_destroy_part2+0x140/0x190 [mac80211]
<4>[37876.472194] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.472252]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.472258] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.472258] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.472265] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.472265]  0000000000000000 ffff964d8b357980 ffffffff94386f78 
0000000000000000
<4>[37876.472266]  0000000000000000 ffff964d8b3579c0 ffffffff9405bf7b 
000003bbd9c70000
<4>[37876.472268]  ffff964dd9c70000 ffff964dd74046e0 ffff964dcbdd07c0 
ffff964dcbdd07c0
<4>[37876.472269] Call Trace:
<4>[37876.472270]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.472272]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.472273]  [<ffffffff9405c06d>] warn_slowpath_null+0x1d/0x20
<4>[37876.472279]  [<ffffffffc09107e0>] 
__sta_info_destroy_part2+0x140/0x190 [mac80211]
<4>[37876.472286]  [<ffffffffc0910af0>] __sta_info_flush+0xf0/0x190 
[mac80211]
<4>[37876.472296]  [<ffffffffc09553ba>] 
ieee80211_set_disassoc+0xba/0x3f0 [mac80211]
<4>[37876.472305]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.472313]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.472323]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.472333]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.472343]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.472353]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.472363]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.472372]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.472378]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.472381]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.472383]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.472388]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.472392]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.472396]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.472400]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.472410]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.472422]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.472435]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.472443]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.472447]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.472450]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.472453]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.472455]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.472458]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.472462]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.472463] ---[ end trace c865123de0685165 ]---
<4>[37876.472466] ------------[ cut here ]------------
<4>[37876.472472] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 drv_sta_state+0x1a2/0x460 [mac80211]
<4>[37876.472473] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.472473] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.472490]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.472496] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.472496] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.472502] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.472503]  0000000000000000 ffff964d8b3578e8 ffffffff94386f78 
ffff964d8b357938
<4>[37876.472505]  0000000000000000 ffff964d8b357928 ffffffff9405bf7b 
0000001100000009
<4>[37876.472506]  ffff964dcbdd07c0 ffff964dd74046e0 0000000000000001 
0000000000000000
<4>[37876.472507] Call Trace:
<4>[37876.472509]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.472510]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.472511]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.472518]  [<ffffffffc090bbc2>] drv_sta_state+0x1a2/0x460 [mac80211]
<4>[37876.472525]  [<ffffffffc09107fb>] 
__sta_info_destroy_part2+0x15b/0x190 [mac80211]
<4>[37876.472532]  [<ffffffffc0910af0>] __sta_info_flush+0xf0/0x190 
[mac80211]
<4>[37876.472545]  [<ffffffffc09553ba>] 
ieee80211_set_disassoc+0xba/0x3f0 [mac80211]
<4>[37876.472558]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.472570]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.472582]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.472592]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.472602]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.472611]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.472620]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.472627]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.472630]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.472632]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.472635]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.472638]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.472642]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.472644]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.472647]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.472654]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.472666]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.472678]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.472687]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.472691]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.472694]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.472698]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.472700]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.472703]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.472704]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.472705] ---[ end trace c865123de0685166 ]---
<4>[37876.472705] ------------[ cut here ]------------
<4>[37876.472712] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/sta_info.c:963 __sta_info_destroy_part2+0x188/0x190 [mac80211]
<4>[37876.472713] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.472730]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.472735] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.472736] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.472743] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.472744]  0000000000000000 ffff964d8b357980 ffffffff94386f78 
0000000000000000
<4>[37876.472745]  0000000000000000 ffff964d8b3579c0 ffffffff9405bf7b 
000003c3c090bbc2
<4>[37876.472747]  ffff964dd9c70000 ffff964dd74046e0 ffff964dcbdd07c0 
ffff964dcbdd07c0
<4>[37876.472748] Call Trace:
<4>[37876.472749]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.472751]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.472753]  [<ffffffff9405c06d>] warn_slowpath_null+0x1d/0x20
<4>[37876.472759]  [<ffffffffc0910828>] 
__sta_info_destroy_part2+0x188/0x190 [mac80211]
<4>[37876.472766]  [<ffffffffc0910af0>] __sta_info_flush+0xf0/0x190 
[mac80211]
<4>[37876.472777]  [<ffffffffc09553ba>] 
ieee80211_set_disassoc+0xba/0x3f0 [mac80211]
<4>[37876.472790]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.472802]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.472814]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.472826]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.472838]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.472848]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.472857]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.472865]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.472869]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.472872]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.472876]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.472878]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.472881]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.472885]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.472887]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.472896]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.472908]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.472920]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.472928]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.472932]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.472935]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.472939]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.472940]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.472941]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.472943]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.472945] ---[ end trace c865123de0685167 ]---
<4>[37876.472946] ------------[ cut here ]------------
<4>[37876.472953] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 sta_set_sinfo+0x7e9/0x8c0 [mac80211]
<4>[37876.472953] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.472953] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.472969]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.472974] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.472975] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.472981] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.472982]  0000000000000000 ffff964d8b3578d8 ffffffff94386f78 
ffff964d8b357928
<4>[37876.472983]  0000000000000000 ffff964d8b357918 ffffffff9405bf7b 
00000011c0973954
<4>[37876.472985]  ffff964dcbdd07c0 ffff964dd74046e0 ffff964dc4413800 
ffff964dd9c701f0
<4>[37876.472986] Call Trace:
<4>[37876.472988]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.472989]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.472990]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.472997]  [<ffffffffc09105c9>] sta_set_sinfo+0x7e9/0x8c0 [mac80211]
<4>[37876.473002]  [<ffffffff941b3e25>] ? kmem_cache_alloc_trace+0x185/0x1a0
<4>[37876.473012]  [<ffffffffc0910745>] 
__sta_info_destroy_part2+0xa5/0x190 [mac80211]
<4>[37876.473023]  [<ffffffffc0910af0>] __sta_info_flush+0xf0/0x190 
[mac80211]
<4>[37876.473037]  [<ffffffffc09553ba>] 
ieee80211_set_disassoc+0xba/0x3f0 [mac80211]
<4>[37876.473050]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.473063]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.473075]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.473087]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.473097]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.473106]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.473114]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.473123]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.473126]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.473129]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.473132]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.473136]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.473138]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.473142]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.473144]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.473152]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.473164]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.473176]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.473184]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.473186]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.473188]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.473189]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.473190]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.473191]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.473193]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.473194] ---[ end trace c865123de0685168 ]---
<4>[37876.473206] ------------[ cut here ]------------
<4>[37876.473218] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 ieee80211_sta_debugfs_remove+0xdd/0xf0 
[mac80211]
<4>[37876.473218] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.473219] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.473261]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.473314] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.473316] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.473323] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.473324]  0000000000000000 ffff964d8b3578f8 ffffffff94386f78 
ffff964d8b357948
<4>[37876.473325]  0000000000000000 ffff964d8b357938 ffffffff9405bf7b 
0000001100000000
<4>[37876.473327]  ffff964dd9c70000 ffff964dcbdd07c0 ffff964dd9c707f8 
ffff964dd3e85a80
<4>[37876.473328] Call Trace:
<4>[37876.473330]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.473331]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.473333]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.473340]  [<ffffffffc0910768>] ? 
__sta_info_destroy_part2+0xc8/0x190 [mac80211]
<4>[37876.473350]  [<ffffffffc0960ded>] 
ieee80211_sta_debugfs_remove+0xdd/0xf0 [mac80211]
<4>[37876.473357]  [<ffffffffc0910796>] 
__sta_info_destroy_part2+0xf6/0x190 [mac80211]
<4>[37876.473364]  [<ffffffffc0910af0>] __sta_info_flush+0xf0/0x190 
[mac80211]
<4>[37876.473374]  [<ffffffffc09553ba>] 
ieee80211_set_disassoc+0xba/0x3f0 [mac80211]
<4>[37876.473385]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.473394]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.473406]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.473418]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.473430]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.473440]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.473450]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.473459]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.473464]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.473467]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.473470]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.473473]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.473477]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.473480]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.473483]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.473490]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.473501]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.473512]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.473521]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.473525]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.473526]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.473528]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.473529]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.473531]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.473532]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.473533] ---[ end trace c865123de0685169 ]---
<4>[37876.473546] ------------[ cut here ]------------
<4>[37876.473554] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 
ieee80211_bss_info_change_notify+0x1ba/0x1c0 [mac80211]
<4>[37876.473554] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.473555] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.473581]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.473586] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.473589] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.473598] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.473599]  0000000000000000 ffff964d8b357980 ffffffff94386f78 
ffff964d8b3579d0
<4>[37876.473600]  0000000000000000 ffff964d8b3579c0 ffffffff9405bf7b 
000000118b3579b8
<4>[37876.473602]  ffff964dcbdd07c0 000000000080309f ffff964dcbdd0eb8 
ffff964dd74046e0
<4>[37876.473603] Call Trace:
<4>[37876.473604]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.473606]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.473608]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.473614]  [<ffffffffc0909efa>] 
ieee80211_bss_info_change_notify+0x1ba/0x1c0 [mac80211]
<4>[37876.473624]  [<ffffffffc0955520>] 
ieee80211_set_disassoc+0x220/0x3f0 [mac80211]
<4>[37876.473635]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.473644]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.473653]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.473661]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.473670]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.473676]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.473682]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.473688]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.473690]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.473692]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.473693]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.473694]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.473695]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.473697]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.473698]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.473704]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.473714]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.473724]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.473731]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.473733]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.473734]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.473736]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.473737]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.473738]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.473740]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.473740] ---[ end trace c865123de068516a ]---
<4>[37876.473741] ------------[ cut here ]------------
<4>[37876.473747] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 drv_conf_tx+0x179/0x1c0 [mac80211]
<4>[37876.473748] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.473749] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.473765]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.473771] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.473771] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.473778] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.473779]  0000000000000000 ffff964d8b357920 ffffffff94386f78 
ffff964d8b357970
<4>[37876.473780]  0000000000000000 ffff964d8b357960 ffffffff9405bf7b 
000000118b357938
<4>[37876.473782]  ffff964dcbdd07c0 ffff964dd74046e0 0000000000000001 
0000000000000000
<4>[37876.473783] Call Trace:
<4>[37876.473784]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.473786]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.473788]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.473794]  [<ffffffffc090c189>] drv_conf_tx+0x179/0x1c0 [mac80211]
<4>[37876.473804]  [<ffffffffc093b692>] 
ieee80211_set_wmm_default+0x1e2/0x290 [mac80211]
<4>[37876.473815]  [<ffffffffc095552c>] 
ieee80211_set_disassoc+0x22c/0x3f0 [mac80211]
<4>[37876.473825]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.473834]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.473842]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.473851]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.473859]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.473866]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.473872]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.473878]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.473880]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.473882]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.473883]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.473884]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.473885]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.473887]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.473888]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.473894]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.473904]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.473914]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.473920]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.473923]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.473924]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.473926]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.473927]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.473928]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.473929]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.473930] ---[ end trace c865123de068516b ]---
<4>[37876.473931] ------------[ cut here ]------------
<4>[37876.473937] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 drv_conf_tx+0x179/0x1c0 [mac80211]
<4>[37876.473938] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.473938] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.473955]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.473961] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.473961] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.473968] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.473969]  0000000000000000 ffff964d8b357920 ffffffff94386f78 
ffff964d8b357970
<4>[37876.473970]  0000000000000000 ffff964d8b357960 ffffffff9405bf7b 
000000118b357938
<4>[37876.473971]  ffff964dcbdd07c0 ffff964dd74046e0 0000000000000002 
0000000000000001
<4>[37876.473973] Call Trace:
<4>[37876.473974]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.473976]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.473978]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.473985]  [<ffffffffc090c189>] drv_conf_tx+0x179/0x1c0 [mac80211]
<4>[37876.473994]  [<ffffffffc093b692>] 
ieee80211_set_wmm_default+0x1e2/0x290 [mac80211]
<4>[37876.474004]  [<ffffffffc095552c>] 
ieee80211_set_disassoc+0x22c/0x3f0 [mac80211]
<4>[37876.474014]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.474023]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.474031]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.474039]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.474048]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.474054]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.474060]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.474067]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.474069]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.474070]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.474071]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.474072]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.474073]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.474075]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.474076]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.474082]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.474092]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.474102]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.474109]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.474111]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.474112]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.474114]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.474115]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.474116]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.474118]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.474118] ---[ end trace c865123de068516c ]---
<4>[37876.474119] ------------[ cut here ]------------
<4>[37876.474125] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 drv_conf_tx+0x179/0x1c0 [mac80211]
<4>[37876.474126] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.474126] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.474143]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.474148] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.474149] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.474155] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.474157]  0000000000000000 ffff964d8b357920 ffffffff94386f78 
ffff964d8b357970
<4>[37876.474158]  0000000000000000 ffff964d8b357960 ffffffff9405bf7b 
000000118b357938
<4>[37876.474159]  ffff964dcbdd07c0 ffff964dd74046e0 0000000000000003 
0000000000000002
<4>[37876.474160] Call Trace:
<4>[37876.474162]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.474164]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.474165]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.474172]  [<ffffffffc090c189>] drv_conf_tx+0x179/0x1c0 [mac80211]
<4>[37876.474182]  [<ffffffffc093b692>] 
ieee80211_set_wmm_default+0x1e2/0x290 [mac80211]
<4>[37876.474192]  [<ffffffffc095552c>] 
ieee80211_set_disassoc+0x22c/0x3f0 [mac80211]
<4>[37876.474202]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.474211]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.474220]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.474228]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.474236]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.474243]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.474249]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.474255]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.474258]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.474259]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.474260]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.474261]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.474262]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.474264]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.474265]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.474271]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.474281]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.474291]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.474298]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.474300]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.474301]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.474303]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.474304]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.474305]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.474306]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.474307] ---[ end trace c865123de068516d ]---
<4>[37876.474308] ------------[ cut here ]------------
<4>[37876.474314] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 drv_conf_tx+0x179/0x1c0 [mac80211]
<4>[37876.474315] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.474315] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.474332]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.474338] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.474338] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.474345] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.474346]  0000000000000000 ffff964d8b357920 ffffffff94386f78 
ffff964d8b357970
<4>[37876.474347]  0000000000000000 ffff964d8b357960 ffffffff9405bf7b 
000000118b357938
<4>[37876.474349]  ffff964dcbdd07c0 ffff964dd74046e0 0000000000000004 
0000000000000003
<4>[37876.474350] Call Trace:
<4>[37876.474351]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.474353]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.474355]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.474361]  [<ffffffffc090c189>] drv_conf_tx+0x179/0x1c0 [mac80211]
<4>[37876.474371]  [<ffffffffc093b692>] 
ieee80211_set_wmm_default+0x1e2/0x290 [mac80211]
<4>[37876.474381]  [<ffffffffc095552c>] 
ieee80211_set_disassoc+0x22c/0x3f0 [mac80211]
<4>[37876.474391]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.474400]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.474409]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.474417]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.474426]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.474432]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.474438]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.474444]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.474446]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.474448]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.474449]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.474450]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.474451]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.474453]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.474454]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.474460]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.474470]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.474480]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.474486]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.474488]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.474490]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.474491]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.474492]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.474493]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.474495]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.474496] ---[ end trace c865123de068516e ]---
<4>[37876.474497] ------------[ cut here ]------------
<4>[37876.474506] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 ieee80211_assign_vif_chanctx+0x3c6/0x480 
[mac80211]
<4>[37876.474507] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.474508] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.474524]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.474530] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.474530] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.474537] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.474538]  0000000000000000 ffff964d8b357930 ffffffff94386f78 
ffff964d8b357980
<4>[37876.474539]  0000000000000000 ffff964d8b357970 ffffffff9405bf7b 
00000011d74046e0
<4>[37876.474541]  ffff964dcbdd07c0 ffff964dd74046e0 0000000000000000 
ffff964dcf50dad8
<4>[37876.474542] Call Trace:
<4>[37876.474544]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.474545]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.474547]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.474557]  [<ffffffffc0940e06>] 
ieee80211_assign_vif_chanctx+0x3c6/0x480 [mac80211]
<4>[37876.474559]  [<ffffffff940c3e8c>] ? lock_timer_base.isra.23+0x7c/0xa0
<4>[37876.474568]  [<ffffffffc0941d34>] 
__ieee80211_vif_release_channel+0x54/0x140 [mac80211]
<4>[37876.474578]  [<ffffffffc09426fd>] 
ieee80211_vif_release_channel+0x4d/0x70 [mac80211]
<4>[37876.474588]  [<ffffffffc0955592>] 
ieee80211_set_disassoc+0x292/0x3f0 [mac80211]
<4>[37876.474598]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.474607]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.474615]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.474624]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.474632]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.474639]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.474645]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.474651]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.474654]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.474655]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.474656]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.474657]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.474658]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.474660]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.474661]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.474667]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.474677]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.474687]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.474693]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.474695]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.474697]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.474698]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.474699]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.474701]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.474702]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.474703] ---[ end trace c865123de068516f ]---
<4>[37876.474703] ------------[ cut here ]------------
<4>[37876.474710] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 
ieee80211_bss_info_change_notify+0x1ba/0x1c0 [mac80211]
<4>[37876.474710] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.474711] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.474727]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.474733] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.474734] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.474740] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.474741]  0000000000000000 ffff964d8b3578f8 ffffffff94386f78 
ffff964d8b357948
<4>[37876.474743]  0000000000000000 ffff964d8b357938 ffffffff9405bf7b 
0000001100000000
<4>[37876.474744]  ffff964dcbdd07c0 0000000000004000 0000000000000000 
ffff964dd74046e0
<4>[37876.474745] Call Trace:
<4>[37876.474747]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.474748]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.474750]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.474751]  [<ffffffff9405bfef>] ? warn_slowpath_fmt+0x4f/0x60
<4>[37876.474758]  [<ffffffffc0909efa>] 
ieee80211_bss_info_change_notify+0x1ba/0x1c0 [mac80211]
<4>[37876.474768]  [<ffffffffc0940c62>] 
ieee80211_assign_vif_chanctx+0x222/0x480 [mac80211]
<4>[37876.474778]  [<ffffffffc0941d34>] 
__ieee80211_vif_release_channel+0x54/0x140 [mac80211]
<4>[37876.474787]  [<ffffffffc09426fd>] 
ieee80211_vif_release_channel+0x4d/0x70 [mac80211]
<4>[37876.474798]  [<ffffffffc0955592>] 
ieee80211_set_disassoc+0x292/0x3f0 [mac80211]
<4>[37876.474808]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.474817]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.474825]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.474834]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.474842]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.474849]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.474855]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.474861]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.474863]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.474865]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.474866]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.474867]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.474868]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.474869]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.474871]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.474877]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.474887]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.474896]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.474903]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.474905]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.474906]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.474908]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.474909]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.474911]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.474912]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.474913] ---[ end trace c865123de0685170 ]---
<4>[37876.474913] ------------[ cut here ]------------
<4>[37876.474923] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:876 ieee80211_del_chanctx+0x16f/0x180 [mac80211]
<4>[37876.474923] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.474940]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.474946] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.474946] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.474953] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.474954]  0000000000000000 ffff964d8b357978 ffffffff94386f78 
0000000000000000
<4>[37876.474955]  0000000000000000 ffff964d8b3579b8 ffffffff9405bf7b 
0000036c00000004
<4>[37876.474957]  ffff964dd74046e0 ffff964dd74046e0 ffff964dcf50da80 
ffff964dcf50dad8
<4>[37876.474958] Call Trace:
<4>[37876.474960]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.474961]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.474963]  [<ffffffff9405c06d>] warn_slowpath_null+0x1d/0x20
<4>[37876.474971]  [<ffffffffc093f6cf>] 
ieee80211_del_chanctx+0x16f/0x180 [mac80211]
<4>[37876.474981]  [<ffffffffc093f779>] ieee80211_free_chanctx+0x99/0xf0 
[mac80211]
<4>[37876.474991]  [<ffffffffc0941dd3>] 
__ieee80211_vif_release_channel+0xf3/0x140 [mac80211]
<4>[37876.475001]  [<ffffffffc09426fd>] 
ieee80211_vif_release_channel+0x4d/0x70 [mac80211]
<4>[37876.475011]  [<ffffffffc0955592>] 
ieee80211_set_disassoc+0x292/0x3f0 [mac80211]
<4>[37876.475021]  [<ffffffffc095a6b7>] ieee80211_mgd_deauth+0x117/0x220 
[mac80211]
<4>[37876.475030]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.475039]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.475047]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.475055]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.475062]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.475068]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.475075]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.475076]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.475078]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.475079]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.475080]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.475082]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.475083]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.475084]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.475091]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.475100]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.475110]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.475117]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.475119]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.475120]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.475122]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.475123]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.475124]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.475126]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.475126] ---[ end trace c865123de0685171 ]---
<4>[37876.475137] ------------[ cut here ]------------
<4>[37876.475147] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 __ieee80211_key_destroy+0x28b/0x2e0 [mac80211]
<4>[37876.475147] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.475149] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.475164]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.475169] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.475170] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.475176] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.475177]  0000000000000000 ffff964d8b357828 ffffffff94386f78 
ffff964d8b357878
<4>[37876.475178]  0000000000000000 ffff964d8b357868 ffffffff9405bf7b 
0000001194c39c90
<4>[37876.475180]  ffff964dd3621000 ffff964dd74046e0 ffff964dcbdd07c0 
00000000000007f8
<4>[37876.475181] Call Trace:
<4>[37876.475183]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.475184]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.475185]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.475187]  [<ffffffff940befe9>] ? 
synchronize_sched_expedited+0x5e9/0xb00
<4>[37876.475197]  [<ffffffffc093860b>] 
__ieee80211_key_destroy+0x28b/0x2e0 [mac80211]
<4>[37876.475206]  [<ffffffffc0938b8d>] ieee80211_key_free+0x4d/0x60 
[mac80211]
<4>[37876.475214]  [<ffffffffc0925586>] ieee80211_del_key+0x86/0xd0 
[mac80211]
<4>[37876.475224]  [<ffffffffc05ccc0a>] 
__cfg80211_disconnected+0x10a/0x3c0 [cfg80211]
<4>[37876.475232]  [<ffffffffc05c930a>] 
cfg80211_process_deauth+0xca/0xf0 [cfg80211]
<4>[37876.475240]  [<ffffffffc05c95fb>] cfg80211_tx_mlme_mgmt+0xcb/0xe0 
[cfg80211]
<4>[37876.475251]  [<ffffffffc09547e4>] 
ieee80211_report_disconnect+0x54/0x150 [mac80211]
<4>[37876.475262]  [<ffffffffc095a6d2>] ieee80211_mgd_deauth+0x132/0x220 
[mac80211]
<4>[37876.475270]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.475279]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.475287]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.475296]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.475302]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.475308]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.475314]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.475316]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.475318]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.475319]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.475320]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.475321]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.475323]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.475324]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.475330]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.475340]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.475350]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.475356]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.475358]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.475360]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.475362]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.475363]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.475364]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.475365]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.475366] ---[ end trace c865123de0685172 ]---
<3>[37876.475367] wlan0: failed to remove key (1, ff:ff:ff:ff:ff:ff) 
from hardware (-5)
<4>[37876.475383] ------------[ cut here ]------------
<4>[37876.475393] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 __ieee80211_key_destroy+0x28b/0x2e0 [mac80211]
<4>[37876.475393] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.475394] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.475410]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.475416] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.475417] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.475423] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.475424]  0000000000000000 ffff964d8b357828 ffffffff94386f78 
ffff964d8b357878
<4>[37876.475426]  0000000000000000 ffff964d8b357868 ffffffff9405bf7b 
0000001194c39ca8
<4>[37876.475427]  ffff964d94f96800 ffff964dd74046e0 ffff964dcbdd07c0 
00000000000007f8
<4>[37876.475428] Call Trace:
<4>[37876.475430]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.475432]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.475433]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.475435]  [<ffffffff940befe9>] ? 
synchronize_sched_expedited+0x5e9/0xb00
<4>[37876.475444]  [<ffffffffc093860b>] 
__ieee80211_key_destroy+0x28b/0x2e0 [mac80211]
<4>[37876.475454]  [<ffffffffc0938b8d>] ieee80211_key_free+0x4d/0x60 
[mac80211]
<4>[37876.475463]  [<ffffffffc0925586>] ieee80211_del_key+0x86/0xd0 
[mac80211]
<4>[37876.475472]  [<ffffffffc05ccc0a>] 
__cfg80211_disconnected+0x10a/0x3c0 [cfg80211]
<4>[37876.475480]  [<ffffffffc05c930a>] 
cfg80211_process_deauth+0xca/0xf0 [cfg80211]
<4>[37876.475489]  [<ffffffffc05c95fb>] cfg80211_tx_mlme_mgmt+0xcb/0xe0 
[cfg80211]
<4>[37876.475499]  [<ffffffffc09547e4>] 
ieee80211_report_disconnect+0x54/0x150 [mac80211]
<4>[37876.475509]  [<ffffffffc095a6d2>] ieee80211_mgd_deauth+0x132/0x220 
[mac80211]
<4>[37876.475518]  [<ffffffffc0925178>] ieee80211_deauth+0x18/0x20 
[mac80211]
<4>[37876.475527]  [<ffffffffc05c9edf>] cfg80211_mlme_deauth+0x8f/0x170 
[cfg80211]
<4>[37876.475535]  [<ffffffffc05ca1db>] cfg80211_mlme_down+0x6b/0x90 
[cfg80211]
<4>[37876.475544]  [<ffffffffc05cd796>] cfg80211_disconnect+0x1a6/0x1c0 
[cfg80211]
<4>[37876.475550]  [<ffffffffc05a3261>] __cfg80211_leave+0x61/0xf0 
[cfg80211]
<4>[37876.475556]  [<ffffffffc05a331b>] cfg80211_leave+0x2b/0x40 [cfg80211]
<4>[37876.475563]  [<ffffffffc05a3694>] 
cfg80211_netdev_notifier_call+0x364/0x520 [cfg80211]
<4>[37876.475565]  [<ffffffff9407b05a>] notifier_call_chain+0x4a/0x70
<4>[37876.475566]  [<ffffffff9407b1d6>] raw_notifier_call_chain+0x16/0x20
<4>[37876.475567]  [<ffffffff945fa295>] 
call_netdevice_notifiers_info+0x35/0x60
<4>[37876.475569]  [<ffffffff945fa563>] __dev_close_many+0x43/0xd0
<4>[37876.475570]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.475571]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.475573]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.475579]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.475588]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.475598]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.475605]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.475607]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.475608]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.475610]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.475611]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.475612]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.475614]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.475614] ---[ end trace c865123de0685173 ]---
<3>[37876.475615] wlan0: failed to remove key (2, ff:ff:ff:ff:ff:ff) 
from hardware (-5)
<4>[37876.475648] ------------[ cut here ]------------
<4>[37876.475656] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.h:17 drv_remove_interface+0x10d/0x120 [mac80211]
<4>[37876.475656] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
<4>[37876.475657] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.475673]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.475679] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.475680] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.475687] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.475688]  0000000000000000 ffff964d8b357b60 ffffffff94386f78 
ffff964d8b357bb0
<4>[37876.475689]  0000000000000000 ffff964d8b357ba0 ffffffff9405bf7b 
0000001100000000
<4>[37876.475691]  ffff964dcbdd07c0 ffff964dcbdd07c0 ffff964dd74046e0 
ffff964dd7404ec8
<4>[37876.475692] Call Trace:
<4>[37876.475693]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.475695]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.475697]  [<ffffffff9405bfef>] warn_slowpath_fmt+0x4f/0x60
<4>[37876.475699]  [<ffffffff946ae058>] ? preempt_schedule_common+0x18/0x30
<4>[37876.475705]  [<ffffffffc090ba0d>] drv_remove_interface+0x10d/0x120 
[mac80211]
<4>[37876.475713]  [<ffffffffc0920031>] ieee80211_do_stop+0x501/0x7e0 
[mac80211]
<4>[37876.475715]  [<ffffffff946b1cfe>] ? _raw_spin_unlock_bh+0xe/0x10
<4>[37876.475723]  [<ffffffffc092032a>] ieee80211_stop+0x1a/0x20 [mac80211]
<4>[37876.475725]  [<ffffffff945fa5a2>] __dev_close_many+0x82/0xd0
<4>[37876.475726]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.475728]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.475729]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.475735]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.475745]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.475755]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.475761]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.475764]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.475766]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.475767]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.475768]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.475769]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.475770]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.475771] ---[ end trace c865123de0685174 ]---
<4>[37876.475773] ------------[ cut here ]------------
<4>[37876.475780] WARNING: CPU: 2 PID: 3862 at 
net/mac80211/driver-ops.c:39 drv_stop+0xfa/0x100 [mac80211]
<4>[37876.475780] Modules linked in: nls_iso8859_1 iptable_filter ctr 
ccm ip_tables x_tables binfmt_misc snd_hda_codec_realtek arc4 iwlmvm 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_codec 
mac80211 btusb btrtl intel_rapl btbcm x86_pkg_temp_thermal 
intel_powerclamp btintel bluetooth snd_hwdep coretemp uvcvideo 
snd_hda_core kvm_intel videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 
videobuf2_core snd_pcm kvm videodev snd_seq_midi snd_seq_midi_event 
iwlwifi snd_rawmidi snd_seq cfg80211 snd_seq_device snd_timer snd 
irqbypass soundcore rtsx_pci_ms lpc_ich memstick ideapad_laptop 
sparse_keymap wmi algif_skcipher af_alg dm_crypt dm_mirror 
dm_region_hash dm_log uas usb_storage hid_generic usbhid hid i915 
intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt 
fb_sys_fops drm
<4>[37876.475795]  rtsx_pci_sdmmc crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel aesni_intel aes_x86_64 lrw psmouse gf128mul 
glue_helper ablk_helper cryptd rtsx_pci ahci r8169 libahci mii video 
jitterentropy_rng drbg ansi_cprng
<4>[37876.475801] CPU: 2 PID: 3862 Comm: kworker/2:1 Tainted: G        
W       4.8.1 #63
<4>[37876.475801] Hardware name: LENOVO 20378/Lenovo Y50-70, BIOS 
9ECN36WW(V2.00) 01/12/2015
<4>[37876.475808] Workqueue: events_freezable ieee80211_restart_work 
[mac80211]
<4>[37876.475808]  0000000000000000 ffff964d8b357ba0 ffffffff94386f78 
0000000000000000
<4>[37876.475810]  0000000000000000 ffff964d8b357be0 ffffffff9405bf7b 
0000002700000004
<4>[37876.475811]  ffff964dd74046e0 ffff964dd74046e0 0000000000000000 
ffff964dd7404ec8
<4>[37876.475812] Call Trace:
<4>[37876.475814]  [<ffffffff94386f78>] dump_stack+0x4d/0x65
<4>[37876.475815]  [<ffffffff9405bf7b>] __warn+0xcb/0xf0
<4>[37876.475817]  [<ffffffff9405c06d>] warn_slowpath_null+0x1d/0x20
<4>[37876.475823]  [<ffffffffc090b67a>] drv_stop+0xfa/0x100 [mac80211]
<4>[37876.475833]  [<ffffffffc093c693>] ieee80211_stop_device+0x43/0x50 
[mac80211]
<4>[37876.475841]  [<ffffffffc091ffd0>] ieee80211_do_stop+0x4a0/0x7e0 
[mac80211]
<4>[37876.475844]  [<ffffffff946b1cfe>] ? _raw_spin_unlock_bh+0xe/0x10
<4>[37876.475852]  [<ffffffffc092032a>] ieee80211_stop+0x1a/0x20 [mac80211]
<4>[37876.475853]  [<ffffffff945fa5a2>] __dev_close_many+0x82/0xd0
<4>[37876.475855]  [<ffffffff945fa672>] dev_close_many+0x82/0x120
<4>[37876.475856]  [<ffffffff945fc5bb>] dev_close.part.88+0x3b/0x50
<4>[37876.475857]  [<ffffffff945fc5ea>] dev_close+0x1a/0x20
<4>[37876.475863]  [<ffffffffc05a2ce5>] 
cfg80211_shutdown_all_interfaces+0x45/0xb0 [cfg80211]
<4>[37876.475873]  [<ffffffffc093a0e8>] 
ieee80211_handle_reconfig_failure+0x98/0xb0 [mac80211]
<4>[37876.475883]  [<ffffffffc093c736>] ieee80211_reconfig+0x96/0xfb0 
[mac80211]
<4>[37876.475890]  [<ffffffffc090820e>] ieee80211_restart_work+0x8e/0xc0 
[mac80211]
<4>[37876.475892]  [<ffffffff94074bb0>] process_one_work+0x160/0x480
<4>[37876.475893]  [<ffffffff94074f18>] worker_thread+0x48/0x4d0
<4>[37876.475894]  [<ffffffff94074ed0>] ? process_one_work+0x480/0x480
<4>[37876.475896]  [<ffffffff9407a299>] kthread+0xc9/0xe0
<4>[37876.475897]  [<ffffffff946b223f>] ret_from_fork+0x1f/0x40
<4>[37876.475898]  [<ffffffff9407a1d0>] ? kthread_worker_fn+0x170/0x170
<4>[37876.475899] ---[ end trace c865123de0685175 ]---
