From: M G Berberich <berberic@fmi.uni-passau.de>
Subject: Re: 2.6.33 dies on modprobe
Date: Wed, 3 Mar 2010 23:16:02 +0100
Message-ID: <20100303221602.GA3264@invalid>
References: <20100228221257.GA8858@invalid>
 <2375c9f91002282022n29e83858jd8cadbb2e664b436@mail.gmail.com>
 <20100302185213.43a1a0d7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="EVF5PPMfhYS0aIcm"
Content-Transfer-Encoding: 8bit
Cc: =?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	linux-kernel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100302185213.43a1a0d7.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Hello,

Am Dienstag, den 02. März schrieb Andrew Morton:

> It could be that some kobject on that list has become invalid (memory
> was freed, module was unloaded, etc) and later code stumbled across the
> now-invalid object on that list and then crashed.
> 
> What we can do to find this is to add a diagnostic each time an object
> is registered, and a diagnostic each time kset_find_obj() looks at the
> objects.  Then we'll see which kobject caused the crash, then we can
> look back and see where that kobject was registered from.

[...]

> This will generate a lot of output and we don't want to lose any of it.
>  I'd suggest setting up netconsole so all the output can be reliably
> saved: Documentation/networking/netconsole.txt

I have a serial connection to a netbook. Log attached.

	MfG
	bmg

-- 
„Des is völlig wurscht, was heut beschlos- | M G Berberich
 sen wird: I bin sowieso dagegn!“          | berberic@fmi.uni-passau.de
(SPD-Stadtrat Kurt Schindler; Regensburg)  | www.fmi.uni-passau.de/~berberic

--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=log

Linux version 2.6.33-bmg (root@hermione) (gcc version 4.4.3 20100108 (prerelease) (Debian 4.4.2-9) ) #2 SMP Wed Mar 3 22:31:08 CET 2010
Command line: root=/dev/sda2 ro console=ttyS0,115200n8r console=tty0
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
 BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000cfff0000 (usable)
 BIOS-e820: 00000000cfff0000 - 00000000cfff3000 (ACPI NVS)
 BIOS-e820: 00000000cfff3000 - 00000000d0000000 (ACPI data)
 BIOS-e820: 00000000d0000000 - 00000000e0000000 (reserved)
 BIOS-e820: 00000000f0000000 - 00000000f8000000 (reserved)
 BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000000130000000 (usable)
NX (Execute Disable) protection: active
DMI 2.3 present.
No AGP bridge found
last_pfn = 0x130000 max_arch_pfn = 0x400000000
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
last_pfn = 0xcfff0 max_arch_pfn = 0x400000000
found SMP MP-table at [ffff8800000f4a20] f4a20
init_memory_mapping: 0000000000000000-00000000cfff0000
init_memory_mapping: 0000000100000000-0000000130000000
ACPI: RSDP 00000000000f6380 00014 (v00 GBT   )
ACPI: RSDT 00000000cfff3000 00038 (v01 GBT    NVDAACPI 42302E31 NVDA 01010101)
ACPI: FACP 00000000cfff3040 00074 (v01 GBT    NVDAACPI 42302E31 NVDA 01010101)
ACPI: DSDT 00000000cfff30c0 04A61 (v01 GBT    NVDAACPI 00001000 MSFT 0100000C)
ACPI: FACS 00000000cfff0000 00040
ACPI: SSDT 00000000cfff7c00 0028A (v01 PTLTD  POWERNOW 00000001  LTP 00000001)
ACPI: HPET 00000000cfff7ec0 00038 (v01 GBT    NVDAACPI 42302E31 NVDA 00000098)
ACPI: MCFG 00000000cfff7f00 0003C (v01 GBT    NVDAACPI 42302E31 NVDA 01010101)
ACPI: APIC 00000000cfff7b40 00098 (v01 GBT    NVDAACPI 42302E31 NVDA 01010101)
(12 early reservations) ==> bootmem [0000000000 - 0130000000]
  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
  #1 [0001000000 - 00015c0be0]    TEXT DATA BSS ==> [0001000000 - 00015c0be0]
  #2 [00015c1000 - 00015c108a]              BRK ==> [00015c1000 - 00015c108a]
  #3 [00000f4a30 - 0000100000]    BIOS reserved ==> [00000f4a30 - 0000100000]
  #4 [00000f4a20 - 00000f4a30]     MP-table mpf ==> [00000f4a20 - 00000f4a30]
  #5 [000009f800 - 00000f0f00]    BIOS reserved ==> [000009f800 - 00000f0f00]
  #6 [00000f103c - 00000f4a20]    BIOS reserved ==> [00000f103c - 00000f4a20]
  #7 [00000f0f00 - 00000f103c]     MP-table mpc ==> [00000f0f00 - 00000f103c]
  #8 [0000001000 - 0000003000]       TRAMPOLINE ==> [0000001000 - 0000003000]
  #9 [0000003000 - 0000007000]      ACPI WAKEUP ==> [0000003000 - 0000007000]
  #10 [0000008000 - 000000c000]          PGTABLE ==> [0000008000 - 000000c000]
  #11 [000000c000 - 000000d000]          PGTABLE ==> [000000c000 - 000000d000]
Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00130000
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0: 0x00000000 -> 0x0000009f
    0: 0x00000100 -> 0x000cfff0
    0: 0x00100000 -> 0x00130000
Detected use of extended apic ids on hypertransport bus
ACPI: PM-Timer IO Port: 0x1008
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] disabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] disabled)
ACPI: LAPIC_NMI (acpi_id[0x00] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x03] dfl dfl lint[0x1])
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, version 17, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high edge)
ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high edge)
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x10b9a201 base: 0xfefffc00
SMP: Allowing 4 CPUs, 2 hotplug CPUs
PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
PM: Registered nosave memory: 00000000000f0000 - 0000000000100000
PM: Registered nosave memory: 00000000cfff0000 - 00000000cfff3000
PM: Registered nosave memory: 00000000cfff3000 - 00000000d0000000
PM: Registered nosave memory: 00000000d0000000 - 00000000e0000000
PM: Registered nosave memory: 00000000e0000000 - 00000000f0000000
PM: Registered nosave memory: 00000000f0000000 - 00000000f8000000
PM: Registered nosave memory: 00000000f8000000 - 00000000fec00000
PM: Registered nosave memory: 00000000fec00000 - 0000000100000000
Allocating PCI resources starting at e0000000 (gap: e0000000:10000000)
setup_percpu: NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
PERCPU: Embedded 26 pages/cpu @ffff880028200000 s76376 r8192 d21928 u524288
pcpu-alloc: s76376 r8192 d21928 u524288 alloc=1*2097152
pcpu-alloc: [0] 0 1 2 3 
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1031332
Kernel command line: root=/dev/sda2 ro console=ttyS0,115200n8r console=tty0
PID hash table entries: 4096 (order: 3, 32768 bytes)
Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
Checking aperture...
No AGP bridge found
Node 0: aperture @ 20000000 size 32 MB
Aperture pointing to e820 RAM. Ignoring.
Your BIOS doesn't leave a aperture memory hole
Please enable the IOMMU option in the BIOS setup
This costs you 64 MB of RAM
Mapping aperture over 65536 KB of RAM @ 20000000
PM: Registered nosave memory: 0000000020000000 - 0000000024000000
Memory: 3989292k/4980736k available (3438k kernel code, 786884k absent, 203580k reserved, 1575k data, 408k init)
SLUB: Genslabs=13, HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
Hierarchical RCU implementation.
NR_IRQS:384
Console: colour VGA+ 80x25
console [tty0] enabled
console [ttyS0] enabled
Fast TSC calibration using PIT
Detected 2613.235 MHz processor.
Calibrating delay loop (skipped), value calculated using timer frequency.. 5226.47 BogoMIPS (lpj=2613235)
Mount-cache hash table entries: 256
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
mce: CPU supports 5 MCE banks
using C1E aware idle routine
Performance Events: AMD PMU driver.
... version:                0
... bit width:              48
... generic registers:      4
... value mask:             0000ffffffffffff
... max period:             00007fffffffffff
... fixed-purpose events:   0
... event mask:             000000000000000f
ACPI: Core revision 20091214
Setting APIC routing to flat
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
CPU0: AMD Athlon(tm) 64 X2 Dual Core Processor 5000+ stepping 01
Booting Node   0, Processors  #1
Brought up 2 CPUs
Total of 2 processors activated (10452.34 BogoMIPS).
kset_register:ffff88012f884018
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff81518a36>] devices_init+0x19/0xad
 [<ffffffff815190a3>] driver_init+0x9/0x29
 [<ffffffff814fa679>] kernel_init+0x122/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f884078
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff81518b12>] buses_init+0x19/0x2b
 [<ffffffff815190a8>] driver_init+0xe/0x29
 [<ffffffff814fa679>] kernel_init+0x122/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f8840d8
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff81518b38>] classes_init+0x14/0x26
 [<ffffffff815190ad>] driver_init+0x13/0x29
 [<ffffffff814fa679>] kernel_init+0x122/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f808518
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81236222>] bus_register+0xc2/0x280
 [<ffffffff81519006>] platform_bus_init+0x29/0x41
 [<ffffffff81519088>] ? firmware_init+0x12/0x24
 [<ffffffff815190b7>] driver_init+0x1d/0x29
 [<ffffffff814fa679>] kernel_init+0x122/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f884138
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff8123624e>] bus_register+0xee/0x280
 [<ffffffff81519006>] platform_bus_init+0x29/0x41
 [<ffffffff81519088>] ? firmware_init+0x12/0x24
 [<ffffffff815190b7>] driver_init+0x1d/0x29
 [<ffffffff814fa679>] kernel_init+0x122/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f884198
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff81236274>] bus_register+0x114/0x280
 [<ffffffff81519006>] platform_bus_init+0x29/0x41
 [<ffffffff81519088>] ? firmware_init+0x12/0x24
 [<ffffffff815190b7>] driver_init+0x1d/0x29
 [<ffffffff814fa679>] kernel_init+0x122/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f8841f8
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff81518ae7>] system_bus_init+0x1d/0x2f
 [<ffffffff815190bc>] driver_init+0x22/0x29
 [<ffffffff814fa679>] kernel_init+0x122/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffffffff814ccb88
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81235105>] sysdev_class_register+0x65/0x70
 [<ffffffff81519031>] cpu_dev_init+0x13/0x58
 [<ffffffff815190c1>] driver_init+0x27/0x29
 [<ffffffff814fa679>] kernel_init+0x122/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffffffff814a1e28
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81503cb7>] ? init_lapic_sysfs+0x0/0x2d
 [<ffffffff81235105>] sysdev_class_register+0x65/0x70
 [<ffffffff81503cd2>] init_lapic_sysfs+0x1b/0x2d
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
NET: Registered protocol family 16
kset_register:ffff88012f823418
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8123787f>] __class_create+0x5f/0x90
 [<ffffffff8150e4ee>] ? bdi_class_init+0x0/0x2c
 [<ffffffff8150e507>] bdi_class_init+0x19/0x2c
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f823618
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff815136bb>] ? pcibus_class_init+0x0/0x19
 [<ffffffff815136d2>] pcibus_class_init+0x17/0x19
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f808818
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81236222>] bus_register+0xc2/0x280
 [<ffffffff812377d5>] ? __class_register+0x185/0x1d0
 [<ffffffff81513e83>] ? pci_driver_init+0x0/0x12
 [<ffffffff81513e93>] pci_driver_init+0x10/0x12
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f884258
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff8123624e>] bus_register+0xee/0x280
 [<ffffffff812377d5>] ? __class_register+0x185/0x1d0
 [<ffffffff81513e83>] ? pci_driver_init+0x0/0x12
 [<ffffffff81513e93>] pci_driver_init+0x10/0x12
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f8842b8
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff81236274>] bus_register+0x114/0x280
 [<ffffffff812377d5>] ? __class_register+0x185/0x1d0
 [<ffffffff81513e83>] ? pci_driver_init+0x0/0x12
 [<ffffffff81513e93>] pci_driver_init+0x10/0x12
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f823818
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8123787f>] __class_create+0x5f/0x90
 [<ffffffff81514548>] ? backlight_class_init+0x0/0x5d
 [<ffffffff81514561>] backlight_class_init+0x19/0x5d
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f823a18
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff81514623>] ? video_output_class_init+0x0/0x19
 [<ffffffff8151463a>] video_output_class_init+0x17/0x19
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f823c18
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8123787f>] __class_create+0x5f/0x90
 [<ffffffff81517005>] ? tty_class_init+0x0/0x38
 [<ffffffff8151701e>] tty_class_init+0x19/0x38
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f823e18
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8123787f>] __class_create+0x5f/0x90
 [<ffffffff815178d1>] ? vtconsole_class_init+0x0/0xc2
 [<ffffffff815178ef>] vtconsole_class_init+0x1e/0xc2
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f808918
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81236222>] bus_register+0xc2/0x280
 [<ffffffff81519cde>] ? spi_init+0x0/0x89
 [<ffffffff81519cde>] ? spi_init+0x0/0x89
 [<ffffffff81519d17>] spi_init+0x39/0x89
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f884318
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff8123624e>] bus_register+0xee/0x280
 [<ffffffff81519cde>] ? spi_init+0x0/0x89
 [<ffffffff81519cde>] ? spi_init+0x0/0x89
 [<ffffffff81519d17>] spi_init+0x39/0x89
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f884378
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff81236274>] bus_register+0x114/0x280
 [<ffffffff81519cde>] ? spi_init+0x0/0x89
 [<ffffffff81519cde>] ? spi_init+0x0/0x89
 [<ffffffff81519d17>] spi_init+0x39/0x89
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f8ce218
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff81519cde>] ? spi_init+0x0/0x89
 [<ffffffff81519d2e>] spi_init+0x50/0x89
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f808a18
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81236222>] bus_register+0xc2/0x280
 [<ffffffff812377d5>] ? __class_register+0x185/0x1d0
 [<ffffffff8151b248>] ? i2c_init+0x0/0x70
 [<ffffffff8151b25c>] i2c_init+0x14/0x70
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f8843d8
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff8123624e>] bus_register+0xee/0x280
 [<ffffffff812377d5>] ? __class_register+0x185/0x1d0
 [<ffffffff8151b248>] ? i2c_init+0x0/0x70
 [<ffffffff8151b25c>] i2c_init+0x14/0x70
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f884438
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff81236274>] bus_register+0x114/0x280
 [<ffffffff812377d5>] ? __class_register+0x185/0x1d0
 [<ffffffff8151b248>] ? i2c_init+0x0/0x70
 [<ffffffff8151b25c>] i2c_init+0x14/0x70
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
TOM: 00000000d0000000 aka 3328M
TOM2: 0000000130000000 aka 4864M
ACPI: bus type pci registered
PCI: MMCONFIG for domain 0000 [bus 00-7f] at [mem 0xf0000000-0xf7ffffff] (base 0xf0000000)
PCI: MMCONFIG at [mem 0xf0000000-0xf7ffffff] reserved in E820
PCI: Using configuration type 1 for base access
kset_register:ffff88012f884498
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff8150b648>] ? param_sysfs_init+0x0/0x21c
 [<ffffffff8150b66e>] param_sysfs_init+0x26/0x21c
 [<ffffffff81109d91>] ? sysfs_create_file+0x21/0x30
 [<ffffffff8123514d>] ? sysdev_create_file+0xd/0x10
 [<ffffffff81355dfe>] ? register_cpu+0x4a/0x70
 [<ffffffff8150b648>] ? param_sysfs_init+0x0/0x21c
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
bio: create slab <bio-0> at 0
kset_register:ffff88012f960c18
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff81512992>] ? genhd_device_init+0x0/0x7c
 [<ffffffff815129bc>] genhd_device_init+0x2a/0x7c
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f8e26d8
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff8119edc0>] ? pci_slot_init+0x0/0x50
 [<ffffffff8119ede2>] pci_slot_init+0x22/0x50
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f8ce618
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8123787f>] __class_create+0x5f/0x90
 [<ffffffff815140ad>] ? fbmem_init+0x0/0x98
 [<ffffffff81514116>] fbmem_init+0x69/0x98
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
ACPI: Interpreter enabled
ACPI: (supports S0 S1 S4 S5)
ACPI: Using IOAPIC for interrupt routing
kset_register:ffff88012f808f18
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81236222>] bus_register+0xc2/0x280
 [<ffffffff81102621>] ? proc_mkdir+0x11/0x20
 [<ffffffff8151549d>] ? acpi_init+0x0/0x130
 [<ffffffff8151562e>] acpi_scan_init+0x1f/0xba
 [<ffffffff8129a150>] ? dmi_check_system+0x20/0x50
 [<ffffffff8151549d>] ? acpi_init+0x0/0x130
 [<ffffffff815155ad>] acpi_init+0x110/0x130
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f884b58
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff8123624e>] bus_register+0xee/0x280
 [<ffffffff81102621>] ? proc_mkdir+0x11/0x20
 [<ffffffff8151549d>] ? acpi_init+0x0/0x130
 [<ffffffff8151562e>] acpi_scan_init+0x1f/0xba
 [<ffffffff8129a150>] ? dmi_check_system+0x20/0x50
 [<ffffffff8151549d>] ? acpi_init+0x0/0x130
 [<ffffffff815155ad>] acpi_init+0x110/0x130
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f884bb8
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff81236274>] bus_register+0x114/0x280
 [<ffffffff81102621>] ? proc_mkdir+0x11/0x20
 [<ffffffff8151549d>] ? acpi_init+0x0/0x130
 [<ffffffff8151562e>] acpi_scan_init+0x1f/0xba
 [<ffffffff8129a150>] ? dmi_check_system+0x20/0x50
 [<ffffffff8151549d>] ? acpi_init+0x0/0x130
 [<ffffffff815155ad>] acpi_init+0x110/0x130
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_find_obj:ffff88012f8e8b40
kset_find_obj:ffff88012f8e8b40
kset_find_obj:ffff88012f8e8000
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci_root PNP0A08:00: ignoring host bridge windows from ACPI; boot with "pci=use_crs" to use them
HPET not enabled in BIOS. You might try hpet=force boot option
pci 0000:00:06.0: PCI bridge to [bus 01-01] (subtractive decode)
pci 0000:00:0f.0: PCI bridge to [bus 02-02]
kset_find_obj:ffff88012f8e8b40
kset_find_obj:ffff88012f8e8000
kset_find_obj:ffff88012f8e89c0
ACPI: PCI Interrupt Link [LNK1] (IRQs 5 7 9 10 *11 14 15)
ACPI: PCI Interrupt Link [LNK2] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNK3] (IRQs 5 7 9 *10 11 14 15)
ACPI: PCI Interrupt Link [LNK4] (IRQs 5 7
Clocksource tsc unstable (delta = 240192207 ns)
 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNK5] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNK6] (IRQs *5 7 9 10 11 14 15)
ACPI: PCI Interrupt Link [LNK7] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNK8] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LP2P] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LUBA] (IRQs 5 7 9 10 11 14 *15)
ACPI: PCI Interrupt Link [LMAC] (IRQs 5 7 9 *10 11 14 15)
ACPI: PCI Interrupt Link [LAZA] (IRQs 5 7 9 10 11 14 *15)
ACPI: PCI Interrupt Link [LPMU] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LSMB] (IRQs 5 7 9 10 *11 14 15)
ACPI: PCI Interrupt Link [LUB2] (IRQs *5 7 9 10 11 14 15)
ACPI: PCI Interrupt Link [LIDE] (IRQs 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LSID] (IRQs 5 7 9 10 11 14 *15)
ACPI: PCI Interrupt Link [LFID] (IRQs 5 7 9 10 *11 14 15)
ACPI: PCI Interrupt Link [APC1] (IRQs 16) *0
ACPI: PCI Interrupt Link [APC2] (IRQs 17) *0, disabled.
ACPI: PCI Interrupt Link [APC3] (IRQs 18) *0
ACPI: PCI Interrupt Link [APC4] (IRQs 19) *0, disabled.
ACPI: PCI Interrupt Link [APC5] (IRQs 16) *0, disabled.
ACPI: PCI Interrupt Link [APC6] (IRQs 16) *0
ACPI: PCI Interrupt Link [APC7] (IRQs 16) *0, disabled.
ACPI: PCI Interrupt Link [APC8] (IRQs 16) *0, disabled.
ACPI: PCI Interrupt Link [APCF] (IRQs 20 21 22 23) *0
ACPI: PCI Interrupt Link [APCH] (IRQs 20 21 22 23) *0
ACPI: PCI Interrupt Link [APMU] (IRQs 20 21 22 23) *0, disabled.
ACPI: PCI Interrupt Link [AAZA] (IRQs 20 21 22 23) *0
ACPI: PCI Interrupt Link [APCS] (IRQs 20 21 22 23) *0
ACPI: PCI Interrupt Link [APCL] (IRQs 20 21 22 23) *0
ACPI: PCI Interrupt Link [APCM] (IRQs 20 21 22 23) *0, disabled.
ACPI: PCI Interrupt Link [APCZ] (IRQs 20 21 22 23) *0, disabled.
ACPI: PCI Interrupt Link [APSI] (IRQs 20 21 22 23) *0
ACPI: PCI Interrupt Link [APSJ] (IRQs 20 21 22 23) *0
kset_register:ffff88012f808b18
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81236222>] bus_register+0xc2/0x280
 [<ffffffff81515b48>] ? acpi_pci_link_init+0x0/0x43
 [<ffffffff81516521>] ? pnp_init+0x0/0x12
 [<ffffffff81516531>] pnp_init+0x10/0x12
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f884eb8
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff8123624e>] bus_register+0xee/0x280
 [<ffffffff81515b48>] ? acpi_pci_link_init+0x0/0x43
 [<ffffffff81516521>] ? pnp_init+0x0/0x12
 [<ffffffff81516531>] pnp_init+0x10/0x12
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f884f18
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff81236274>] bus_register+0x114/0x280
 [<ffffffff81515b48>] ? acpi_pci_link_init+0x0/0x43
 [<ffffffff81516521>] ? pnp_init+0x0/0x12
 [<ffffffff81516531>] pnp_init+0x10/0x12
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f8cf018
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8123787f>] __class_create+0x5f/0x90
 [<ffffffff81517685>] ? misc_init+0x0/0xba
 [<ffffffff815176bc>] misc_init+0x37/0xba
 [<ffffffff81516531>] ? pnp_init+0x10/0x12
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
vgaarb: device added: PCI:0000:02:00.0,decodes=io+mem,owns=io+mem,locks=none
vgaarb: loaded
kset_register:ffff88012f8cf818
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8151930f>] ? init_scsi+0x0/0x7c
 [<ffffffff812426d7>] scsi_init_hosts+0x17/0x20
 [<ffffffff81519333>] init_scsi+0x24/0x7c
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f9d0218
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81236222>] bus_register+0xc2/0x280
 [<ffffffff8151930f>] ? init_scsi+0x0/0x7c
 [<ffffffff8151930f>] ? init_scsi+0x0/0x7c
 [<ffffffff8124cfc4>] scsi_sysfs_register+0x14/0x50
 [<ffffffff815195f8>] ? scsi_init_sysctl+0x10/0x22
 [<ffffffff81519349>] init_scsi+0x3a/0x7c
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f9d2258
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff8123624e>] bus_register+0xee/0x280
 [<ffffffff8151930f>] ? init_scsi+0x0/0x7c
 [<ffffffff8151930f>] ? init_scsi+0x0/0x7c
 [<ffffffff8124cfc4>] scsi_sysfs_register+0x14/0x50
 [<ffffffff815195f8>] ? scsi_init_sysctl+0x10/0x22
 [<ffffffff81519349>] init_scsi+0x3a/0x7c
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f9d22b8
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff81236274>] bus_register+0x114/0x280
 [<ffffffff8151930f>] ? init_scsi+0x0/0x7c
 [<ffffffff8151930f>] ? init_scsi+0x0/0x7c
 [<ffffffff8124cfc4>] scsi_sysfs_register+0x14/0x50
 [<ffffffff815195f8>] ? scsi_init_sysctl+0x10/0x22
 [<ffffffff81519349>] init_scsi+0x3a/0x7c
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f8cfa18
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8151930f>] ? init_scsi+0x0/0x7c
 [<ffffffff8124cfe3>] scsi_sysfs_register+0x33/0x50
 [<ffffffff815195f8>] ? scsi_init_sysctl+0x10/0x22
 [<ffffffff81519349>] init_scsi+0x3a/0x7c
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
SCSI subsystem initialized
kset_register:ffff88012f9d0318
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81236222>] bus_register+0xc2/0x280
 [<ffffffff811851f0>] ? kobject_release+0x0/0x90
 [<ffffffff81519ee6>] ? serio_init+0x0/0x8f
 [<ffffffff81519ef9>] serio_init+0x13/0x8f
 [<ffffffff81519ee6>] ? serio_init+0x0/0x8f
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f9d2318
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff8123624e>] bus_register+0xee/0x280
 [<ffffffff811851f0>] ? kobject_release+0x0/0x90
 [<ffffffff81519ee6>] ? serio_init+0x0/0x8f
 [<ffffffff81519ef9>] serio_init+0x13/0x8f
 [<ffffffff81519ee6>] ? serio_init+0x0/0x8f
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f9d2378
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff81236274>] bus_register+0x114/0x280
 [<ffffffff811851f0>] ? kobject_release+0x0/0x90
 [<ffffffff81519ee6>] ? serio_init+0x0/0x8f
 [<ffffffff81519ef9>] serio_init+0x13/0x8f
 [<ffffffff81519ee6>] ? serio_init+0x0/0x8f
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f8cfc18
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8151abbc>] ? input_init+0x0/0x13c
 [<ffffffff8151ac08>] input_init+0x4c/0x13c
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f8cfe18
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8123787f>] __class_create+0x5f/0x90
 [<ffffffff8151abbc>] ? input_init+0x0/0x13c
 [<ffffffff8151b02c>] ? rtc_init+0x0/0x71
 [<ffffffff8151b045>] rtc_init+0x19/0x71
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f9f6018
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8123787f>] __class_create+0x5f/0x90
 [<ffffffff8151b2b8>] ? power_supply_class_init+0x0/0x38
 [<ffffffff8151b2d1>] power_supply_class_init+0x19/0x38
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f9f6218
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8123787f>] __class_create+0x5f/0x90
 [<ffffffff8151b2f0>] ? hwmon_init+0x0/0x109
 [<ffffffff8151b2f0>] ? hwmon_init+0x0/0x109
 [<ffffffff8151b3cb>] hwmon_init+0xdb/0x109
 [<ffffffff8151b2b8>] ? power_supply_class_init+0x0/0x38
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f9f6418
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8151b42f>] ? thermal_init+0x0/0x3f
 [<ffffffff8151b44a>] thermal_init+0x1b/0x3f
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
PCI: Using ACPI for IRQ routing
kset_register:ffff88012f9f6618
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8151eb15>] ? net_dev_init+0x0/0x176
 [<ffffffff812c4a37>] netdev_kobject_init+0x17/0x20
 [<ffffffff8151eb44>] net_dev_init+0x2f/0x176
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
Switching to clocksource jiffies
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 14 devices
ACPI: ACPI bus type pnp unregistered
system 00:01: [io  0x1000-0x107f] has been reserved
system 00:01: [io  0x1080-0x10ff] has been reserved
system 00:01: [io  0x1400-0x147f] has been reserved
system 00:01: [io  0x1480-0x14ff] has been reserved
system 00:01: [io  0x1800-0x187f] has been reserved
system 00:01: [io  0x1880-0x18ff] has been reserved
system 00:01: [mem 0xd0000000-0xdfffffff] has been reserved
system 00:02: [io  0x04d0-0x04d1] has been reserved
system 00:02: [io  0x0800-0x087f] has been reserved
system 00:02: [io  0x0295-0x0314] has been reserved
system 00:02: [io  0x0290-0x0294] has been reserved
system 00:0c: [mem 0xf0000000-0xf7ffffff] has been reserved
system 00:0d: [mem 0x000cde00-0x000cffff] has been reserved
system 00:0d: [mem 0x000f0000-0x000f7fff] could not be reserved
system 00:0d: [mem 0x000f8000-0x000fbfff] could not be reserved
system 00:0d: [mem 0x000fc000-0x000fffff] could not be reserved
system 00:0d: [mem 0xcfff0000-0xcfffffff] could not be reserved
system 00:0d: [mem 0xffff0000-0xffffffff] has been reserved
system 00:0d: [mem 0x00000000-0x0009ffff] could not be reserved
system 00:0d: [mem 0x00100000-0xcffeffff] could not be reserved
system 00:0d: [mem 0xfec00000-0xfec00fff] could not be reserved
system 00:0d: [mem 0xfee00000-0xfee00fff] has been reserved
kset_register:ffff88012f9f6818
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8123787f>] __class_create+0x5f/0x90
 [<ffffffff81516f33>] ? chr_dev_init+0x0/0xc3
 [<ffffffff81516fa2>] chr_dev_init+0x6f/0xc3
 [<ffffffff81516f33>] ? chr_dev_init+0x0/0xc3
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f9f7c18
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff815190c3>] ? firmware_class_init+0x0/0x79
 [<ffffffff815190df>] firmware_class_init+0x1c/0x79
 [<ffffffff81516f33>] ? chr_dev_init+0x0/0xc3
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
Switching to clocksource acpi_pm
pci 0000:00:06.0: PCI bridge to [bus 01-01]
pci 0000:00:06.0:   bridge window [io  0x8000-0x9fff]
pci 0000:00:06.0:   bridge window [mem 0xfb000000-0xfb0fffff]
pci 0000:00:06.0:   bridge window [mem pref disabled]
pci 0000:02:00.0: BAR 6: assigned [mem 0xfa000000-0xfa01ffff pref]
pci 0000:00:0f.0: PCI bridge to [bus 02-02]
pci 0000:00:0f.0:   bridge window [io  0xa000-0xafff]
pci 0000:00:0f.0:   bridge window [mem 0xf8000000-0xfaffffff]
pci 0000:00:0f.0:   bridge window [mem 0xe0000000-0xefffffff 64bit pref]
NET: Registered protocol family 2
IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
UDP hash table entries: 2048 (order: 4, 65536 bytes)
UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes)
NET: Registered protocol family 1
pci 0000:00:05.0: Enabling HT MSI Mapping
pci 0000:00:05.1: Enabling HT MSI Mapping
pci 0000:00:06.0: Enabling HT MSI Mapping
pci 0000:00:06.1: Enabling HT MSI Mapping
pci 0000:00:08.0: Enabling HT MSI Mapping
pci 0000:00:0f.0: Enabling HT MSI Mapping
PCI-DMA: Disabling AGP.
kset_register:ffffffff814a5b88
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81235105>] sysdev_class_register+0x65/0x70
 [<ffffffff81507153>] gart_iommu_init+0x1c8/0x46f
 [<ffffffff814fd9b0>] ? pci_iommu_init+0x0/0x31
 [<ffffffff814fd9ba>] pci_iommu_init+0xa/0x31
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
PCI-DMA: aperture base @ 20000000 size 65536 KB
PCI-DMA: using GART IOMMU.
PCI-DMA: Reserving 64MB of IOMMU area in the AGP aperture
kset_register:ffffffff8149fa68
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff814fbb41>] ? i8259A_init_sysfs+0x0/0x22
 [<ffffffff81235105>] sysdev_class_register+0x65/0x70
 [<ffffffff814fbb51>] i8259A_init_sysfs+0x10/0x22
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffffffff8149fee8
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff814fdaa6>] ? i8237A_init_sysfs+0x0/0x22
 [<ffffffff81235105>] sysdev_class_register+0x65/0x70
 [<ffffffff814fdab6>] i8237A_init_sysfs+0x10/0x22
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffffffff814a0968
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81235105>] sysdev_class_register+0x65/0x70
 [<ffffffff814febdb>] mcheck_init_device+0x8f/0x103
 [<ffffffff814feb4c>] ? mcheck_init_device+0x0/0x103
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f9cea18
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8123787f>] __class_create+0x5f/0x90
 [<ffffffff81501b3d>] ? msr_init+0x0/0x12e
 [<ffffffff81501b9f>] msr_init+0x62/0x12e
 [<ffffffff81501b3d>] ? msr_init+0x0/0x12e
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f9cf018
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8123787f>] __class_create+0x5f/0x90
 [<ffffffff81501c6b>] ? cpuid_init+0x0/0x12e
 [<ffffffff81501ccd>] cpuid_init+0x62/0x12e
 [<ffffffff81501c6b>] ? cpuid_init+0x0/0x12e
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffffffff814a2268
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81504e41>] ? ioapic_init_sysfs+0x0/0xba
 [<ffffffff81235105>] sysdev_class_register+0x65/0x70
 [<ffffffff81504e58>] ioapic_init_sysfs+0x17/0xba
 [<ffffffff81504e41>] ? ioapic_init_sysfs+0x0/0xba
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffffffff814a9c08
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8150bd3b>] ? timekeeping_init_device+0x0/0x22
 [<ffffffff81235105>] sysdev_class_register+0x65/0x70
 [<ffffffff8150bd4b>] timekeeping_init_device+0x10/0x22
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffffffff814a9de8
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8150beb5>] ? init_clocksource_sysfs+0x0/0x50
 [<ffffffff81235105>] sysdev_class_register+0x65/0x70
 [<ffffffff8150bec5>] init_clocksource_sysfs+0x10/0x50
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
HugeTLB registered 2 MB page size, pre-allocated 0 pages
kset_register:ffff88012fa57078
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff8150f5c5>] ? slab_sysfs_init+0x0/0xf7
 [<ffffffff8150f5e6>] slab_sysfs_init+0x21/0xf7
 [<ffffffff8150f5c5>] ? slab_sysfs_init+0x0/0xf7
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012fa57198
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff81511cc3>] ? init_ext4_fs+0x0/0xe9
 [<ffffffff81511cf0>] init_ext4_fs+0x2d/0xe9
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
fuse init (API version 7.13)
msgmni has been set to 7922
alg: No test for stdrng (krng)
kset_register:ffff88012fa95218
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8123787f>] __class_create+0x5f/0x90
 [<ffffffff81512eab>] ? bsg_init+0x0/0x12e
 [<ffffffff81512f1a>] bsg_init+0x6f/0x12e
 [<ffffffff81512956>] ? proc_genhd_init+0x0/0x3c
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
kset_register:ffff88012f8d7718
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81236222>] bus_register+0xc2/0x280
 [<ffffffff81513ee6>] ? pci_proc_init+0x0/0x6a
 [<ffffffff81513f50>] ? pcie_portdrv_init+0x0/0x4c
 [<ffffffff8119fd90>] pcie_port_bus_register+0x10/0x20
 [<ffffffff81513f5e>] pcie_portdrv_init+0xe/0x4c
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f8e28b8
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff8123624e>] bus_register+0xee/0x280
 [<ffffffff81513ee6>] ? pci_proc_init+0x0/0x6a
 [<ffffffff81513f50>] ? pcie_portdrv_init+0x0/0x4c
 [<ffffffff8119fd90>] pcie_port_bus_register+0x10/0x20
 [<ffffffff81513f5e>] pcie_portdrv_init+0xe/0x4c
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012f8e2918
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff81236274>] bus_register+0x114/0x280
 [<ffffffff81513ee6>] ? pci_proc_init+0x0/0x6a
 [<ffffffff81513f50>] ? pcie_portdrv_init+0x0/0x4c
 [<ffffffff8119fd90>] pcie_port_bus_register+0x10/0x20
 [<ffffffff81513f5e>] pcie_portdrv_init+0xe/0x4c
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8e2540
kset_find_obj:ffff88012f987d80
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8e2540
kset_register:ffff88012fa95e18
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8123787f>] __class_create+0x5f/0x90
 [<ffffffff815145a5>] ? display_class_init+0x0/0x7e
 [<ffffffff815145be>] display_class_init+0x19/0x7e
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_find_obj:ffff88012f987d80
kset_find_obj:ffff88012fac1e40
ACPI: PCI Interrupt Link [APC6] enabled at IRQ 16
nvidiafb 0000:02:00.0: PCI INT A -> Link[APC6] -> GSI 16 (level, low) -> IRQ 16
nvidiafb: Device ID: 10de0392 
nvidiafb: CRTC0 analog not found
nvidiafb: CRTC1 analog not found
i2c i2c-0: unable to read EDID block.
i2c i2c-0: unable to read EDID block.
i2c i2c-0: unable to read EDID block.
nvidiafb: EDID found from BUS2
nvidiafb: CRTC 0 is currently programmed for DFP
nvidiafb: Using DFP on CRTC 0
nvidiafb: Panel size is 1280 x 1024
nvidiafb: Panel is TMDS
nvidiafb: MTRR set to ON
nvidiafb: Flat panel dithering disabled
Console: switching to colour frame buffer device 160x64
nvidiafb: PCI nVidia NV39 framebuffer (64MB @ 0xE0000000)
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8e2540
kset_register:ffffffff814bd948
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81515a7d>] ? irqrouter_init_sysfs+0x0/0x38
 [<ffffffff81235105>] sysdev_class_register+0x65/0x70
 [<ffffffff81515a9f>] irqrouter_init_sysfs+0x22/0x38
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_find_obj:ffff88012f8e8b40
kset_find_obj:ffff88012f8e8000
kset_find_obj:ffff88012f8e89c0
kset_find_obj:ffff88012f9920c0
kset_find_obj:ffff88012f8e8b40
kset_find_obj:ffff88012f8e8000
kset_find_obj:ffff88012f8e89c0
kset_find_obj:ffff88012f9920c0
kset_find_obj:ffff88012f9e0000
input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
ACPI: Power Button [PWRB]
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
ACPI: Power Button [PWRF]
kset_find_obj:ffff88012f8e8b40
kset_find_obj:ffff88012f8e8000
kset_find_obj:ffff88012f8e89c0
kset_find_obj:ffff88012f9920c0
kset_find_obj:ffff88012f9e0000
kset_find_obj:ffff88012f9e0cc0
kset_find_obj:ffff88012f8e8b40
kset_find_obj:ffff88012f8e8000
kset_find_obj:ffff88012f8e89c0
kset_find_obj:ffff88012f9920c0
kset_find_obj:ffff88012f9e0000
kset_find_obj:ffff88012f9e0cc0
kset_find_obj:ffff88012f8e8e40
kset_find_obj:ffff88012f8e8b40
kset_find_obj:ffff88012f8e8000
kset_find_obj:ffff88012f8e89c0
kset_find_obj:ffff88012f9920c0
kset_find_obj:ffff88012f9e0000
kset_find_obj:ffff88012f9e0cc0
kset_find_obj:ffff88012f8e8e40
kset_find_obj:ffff88012fa6d3c0
kset_find_obj:ffff88012f8e8b40
kset_find_obj:ffff88012f8e8000
kset_find_obj:ffff88012f8e89c0
kset_find_obj:ffff88012f9920c0
kset_find_obj:ffff88012f9e0000
kset_find_obj:ffff88012f9e0cc0
kset_find_obj:ffff88012f8e8e40
kset_find_obj:ffff88012fa6d3c0
kset_find_obj:ffff88012fa6df00
kset_find_obj:ffff88012f8e8b40
kset_find_obj:ffff88012f8e8000
kset_find_obj:ffff88012f8e89c0
kset_find_obj:ffff88012f9920c0
kset_find_obj:ffff88012f9e0000
kset_find_obj:ffff88012f9e0cc0
kset_find_obj:ffff88012f8e8e40
kset_find_obj:ffff88012fa6d3c0
kset_find_obj:ffff88012fa6df00
kset_find_obj:ffff88012fa6d180
kset_find_obj:ffff88012f8e8b40
kset_find_obj:ffff88012f8e8000
kset_find_obj:ffff88012f8e89c0
kset_find_obj:ffff88012f9920c0
kset_find_obj:ffff88012f9e0000
kset_find_obj:ffff88012f9e0cc0
kset_find_obj:ffff88012f8e8e40
kset_find_obj:ffff88012fa6d3c0
kset_find_obj:ffff88012fa6df00
kset_find_obj:ffff88012fa6d180
kset_find_obj:ffff88012fa6d000
kset_register:ffff88012fa72a18
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8123787f>] __class_create+0x5f/0x90
 [<ffffffff8151703d>] ? tty_init+0x0/0xfa
 [<ffffffff8151778e>] vcs_init+0x4f/0x99
 [<ffffffff81517a0b>] vty_init+0x78/0x17d
 [<ffffffff81517133>] tty_init+0xf6/0xfa
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_find_obj:ffff88012f8e8b40
kset_find_obj:ffff88012f8e8000
kset_find_obj:ffff88012f8e89c0
kset_find_obj:ffff88012f9920c0
kset_find_obj:ffff88012f9e0000
kset_find_obj:ffff88012f9e0cc0
kset_find_obj:ffff88012f8e8e40
kset_find_obj:ffff88012fa6d3c0
kset_find_obj:ffff88012fa6df00
kset_find_obj:ffff88012fa6d180
kset_find_obj:ffff88012fa6d000
kset_find_obj:ffff88012f9a2b40
hpet_acpi_add: no address or irqs in _CRS
Linux agpgart interface v0.103
kset_register:ffff88012ee2a018
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8123787f>] __class_create+0x5f/0x90
 [<ffffffff81517e34>] ? drm_core_init+0x0/0x110
 [<ffffffff8121f615>] drm_sysfs_create+0x15/0x80
 [<ffffffff81517e34>] ? drm_core_init+0x0/0x110
 [<ffffffff81517e84>] drm_core_init+0x50/0x110
 [<ffffffff81517e30>] ? agp_init+0x22/0x26
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
[drm] Initialized drm 1.1.0 20060810
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
kset_find_obj:ffff88012f9e0c00
00:08: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
kset_find_obj:ffff88012f987d80
kset_find_obj:ffff88012fac1e40
kset_find_obj:ffff88012f8e6900
ACPI: PCI Interrupt Link [APC1] enabled at IRQ 16
serial 0000:01:08.0: PCI INT A -> Link[APC1] -> GSI 16 (level, low) -> IRQ 16
0000:01:08.0: ttyS1 at I/O 0x8000 (irq = 16) is a 16550A
0000:01:08.0: ttyS2 at I/O 0x8400 (irq = 16) is a 16550A
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8e2540
loop: module loaded
kset_register:ffff88012ee1ac18
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8151960a>] ? spi_transport_init+0x0/0x79
 [<ffffffff8123a2d0>] transport_class_register+0x10/0x20
 [<ffffffff81519663>] spi_transport_init+0x59/0x79
 [<ffffffff8151913c>] ? loop_init+0x0/0x1b9
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012ee1ae18
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8151960a>] ? spi_transport_init+0x0/0x79
 [<ffffffff8123a2d0>] transport_class_register+0x10/0x20
 [<ffffffff8151967f>] spi_transport_init+0x75/0x79
 [<ffffffff8151913c>] ? loop_init+0x0/0x1b9
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012ee1b018
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff815196eb>] init_sd+0x68/0x148
 [<ffffffff81519683>] ? init_sd+0x0/0x148
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_find_obj:ffff88012f987d80
kset_find_obj:ffff88012fac1e40
kset_find_obj:ffff88012f8e6900
kset_find_obj:ffff88012fa8f900
ACPI: PCI Interrupt Link [APSI] enabled at IRQ 23
sata_nv 0000:00:05.0: PCI INT A -> Link[APSI] -> GSI 23 (level, low) -> IRQ 23
sata_nv 0000:00:05.0: Using SWNCQ mode
scsi0 : sata_nv
scsi1 : sata_nv
ata1: SATA max UDMA/133 cmd 0x9f0 ctl 0xbf0 bmdma 0xc400 irq 23
ata2: SATA max UDMA/133 cmd 0x970 ctl 0xb70 bmdma 0xc408 irq 23
ACPI: PCI Interrupt Link [APSJ] enabled at IRQ 22
sata_nv 0000:00:05.1: PCI INT B -> Link[APSJ] -> GSI 22 (level, low) -> IRQ 22
sata_nv 0000:00:05.1: Using SWNCQ mode
scsi2 : sata_nv
scsi3 : sata_nv
ata3: SATA max UDMA/133 cmd 0x9e0 ctl 0xbe0 bmdma 0xd800 irq 22
ata4: SATA max UDMA/133 cmd 0x960 ctl 0xb60 bmdma 0xd808 irq 22
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f987d80
kset_find_obj:ffff88012fac1e40
kset_find_obj:ffff88012f8e6900
kset_find_obj:ffff88012fa8f900
kset_find_obj:ffff88012ee11900
scsi4 : pata_amd
scsi5 : pata_amd
ata5: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xf000 irq 14
ata6: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xf008 irq 15
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8e2540
kset_find_obj:ffff88012f9e0c00
kset_find_obj:ffff88012fac4780
kset_find_obj:ffff88012f9e0c00
kset_find_obj:ffff88012fac4780
kset_find_obj:ffff88012fa8f240
PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
kset_find_obj:ffff88012fa8c300
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
ata5.00: ATAPI: Optiarc DVD RW AD-7173A, 1-01, max UDMA/66
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
ata5.00: configured for UDMA/66
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8e2540
kset_find_obj:ffff88012ed003c0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input2
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f9e0c00
kset_find_obj:ffff88012fac4780
kset_find_obj:ffff88012fa8f240
kset_find_obj:ffff88012ee19b40
rtc_cmos 00:05: RTC can wake from S4
rtc_cmos 00:05: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one year, y3k, 242 bytes nvram
kset_find_obj:ffff88012f987d80
kset_find_obj:ffff88012fac1e40
kset_find_obj:ffff88012f8e6900
kset_find_obj:ffff88012fa8f900
kset_find_obj:ffff88012ee11900
kset_find_obj:ffff88012ede9240
k8temp 0000:00:18.3: Temperature readouts might be wrong - check erratum #141
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
kset_find_obj:ffff88012f8e2120
ata1.00: HPA detected: current 62531183, native 62533296
ata1.00: ATA-8: OCZ-VERTEX, 1.5, max UDMA/133
ata1.00: 62531183 sectors, multi 1: LBA48 NCQ (depth 31/32)
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
ata1.00: configured for UDMA/133
scsi 0:0:0:0: Direct-Access     ATA      OCZ-VERTEX       1.5  PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 62531183 512-byte logical blocks: (32.0 GB/29.8 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8e2540
ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
kset_find_obj:ffff88012f987d80
kset_find_obj:ffff88012fac1e40
kset_find_obj:ffff88012f8e6900
kset_find_obj:ffff88012fa8f900
kset_find_obj:ffff88012ee11900
kset_find_obj:ffff88012ede9240
kset_find_obj:ffff88012fa6de40
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
device-mapper: ioctl: 4.16.0-ioctl (2009-11-05) initialised: dm-devel@redhat.com
cpuidle: using governor ladder
cpuidle: using governor menu
kset_register:ffff88012ee24418
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81236222>] bus_register+0xc2/0x280
 [<ffffffff8151c29d>] ? hid_init+0x0/0x47
 [<ffffffff8151c2c9>] hid_init+0x2c/0x47
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012fa57cd8
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff8123624e>] bus_register+0xee/0x280
 [<ffffffff8151c29d>] ? hid_init+0x0/0x47
 [<ffffffff8151c2c9>] hid_init+0x2c/0x47
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
kset_register:ffff88012fa57d38
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff81236274>] bus_register+0x114/0x280
 [<ffffffff8151c29d>] ? hid_init+0x0/0x47
 [<ffffffff8151c2c9>] hid_init+0x2c/0x47
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
TCP cubic registered
NET: Registered protocol family 17
Bridge firewalling registered
802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
All bugs added by David S. Miller <davem@redhat.com>
SCTP: Hash tables configured (established 65536 bind 65536)
rtc_cmos 00:05: setting system clock to 2010-03-03 21:48:41 UTC (1267652921)
kset_register:ffff88012ee5acd8
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
ata3.00: HPA detected: current 625140335, native 625142448
ata3.00: ATA-7: WDC WD3200AAKS-75SBA0, 12.01B01, max UDMA/133
ata3.00: 625140335 sectors, multi 16: LBA48 NCQ (depth 31/32)
 [<ffffffff8151c031>] ? memmap_init+0x0/0xa3
ata3.00: configured for UDMA/133
 [<ffffffff8151c051>] memmap_init+0x20/0xa3
 [<ffffffff8151c031>] ? memmap_init+0x0/0xa3
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10
 sda: sda1 sda2 sda3 sda4
sd 0:0:0:0: [sda] Attached SCSI disk
ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata2.00: HPA detected: current 625140335, native 625142448
ata2.00: ATA-7: WDC WD3200AAKS-75SBA0, 12.01B01, max UDMA/133
ata2.00: 625140335 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata2.00: configured for UDMA/133
scsi 1:0:0:0: Direct-Access     ATA      WDC WD3200AAKS-7 12.0 PQ: 0 ANSI: 5
sd 1:0:0:0: [sdb] 625140335 512-byte logical blocks: (320 GB/298 GiB)
scsi 2:0:0:0: Direct-Access     ATA      WDC WD3200AAKS-7 12.0 PQ: 0 ANSI: 5
sd 2:0:0:0: [sdc] 625140335 512-byte logical blocks: (320 GB/298 GiB)
sd 2:0:0:0: [sdc] Write Protect is off
sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdc: sdc1 sdc2 sdc3 < sdc5 sdc6 sdc7 sdc8
sd 1:0:0:0: [sdb] Write Protect is off
 sdc9 >
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 2:0:0:0: [sdc] Attached SCSI disk
 sdb: sdb1 sdb2 sdb3 < sdb5 sdb6 sdb7 sdb8 sdb9 >
sd 1:0:0:0: [sdb] Attached SCSI disk
input: ImPS/2 Logitech Wheel Mouse as /devices/platform/i8042/serio1/input/input3
ata4: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata4.00: HPA detected: current 1953523055, native 1953525168
ata4.00: ATA-8: WDC WD10EACS-07D6B1, 01.01A01, max UDMA/133
ata4.00: 1953523055 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata4.00: configured for UDMA/133
scsi 3:0:0:0: Direct-Access     ATA      WDC WD10EACS-07D 01.0 PQ: 0 ANSI: 5
sd 3:0:0:0: [sdd] 1953523055 512-byte logical blocks: (1.00 TB/931 GiB)
scsi 4:0:0:0: CD-ROM            Optiarc  DVD RW AD-7173A  1-01 PQ: 0 ANSI: 5
sd 3:0:0:0: [sdd] Write Protect is off
sd 3:0:0:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdd: sdd1
sd 3:0:0:0: [sdd] Attached SCSI disk
EXT4-fs (sda2): mounted filesystem with ordered data mode
VFS: Mounted root (ext4 filesystem) readonly on device 8:2.
Freeing unused kernel memory: 408k freed
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8e2540
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_register:ffff88012d053518
Pid: 1251, comm: modprobe Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81236222>] bus_register+0xc2/0x280
 [<ffffffffa0022000>] ? usb_init+0x0/0x156 [usbcore]
 [<ffffffffa0022000>] ? usb_init+0x0/0x156 [usbcore]
 [<ffffffffa002214b>] usb_init+0x14b/0x156 [usbcore]
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff81067296>] sys_init_module+0xd6/0x250
 [<ffffffff8100246b>] system_call_fastpath+0x16/0x1b
kset_register:ffff88012e94c438
Pid: 1251, comm: modprobe Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff8123624e>] bus_register+0xee/0x280
 [<ffffffffa0022000>] ? usb_init+0x0/0x156 [usbcore]
 [<ffffffffa0022000>] ? usb_init+0x0/0x156 [usbcore]
 [<ffffffffa002214b>] usb_init+0x14b/0x156 [usbcore]
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff81067296>] sys_init_module+0xd6/0x250
 [<ffffffff8100246b>] system_call_fastpath+0x16/0x1b
kset_register:ffff88012e94ce58
Pid: 1251, comm: modprobe Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff81236274>] bus_register+0x114/0x280
 [<ffffffffa0022000>] ? usb_init+0x0/0x156 [usbcore]
 [<ffffffffa0022000>] ? usb_init+0x0/0x156 [usbcore]
 [<ffffffffa002214b>] usb_init+0x14b/0x156 [usbcore]
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff81067296>] sys_init_module+0xd6/0x250
 [<ffffffff8100246b>] system_call_fastpath+0x16/0x1b
usbcore: registered new interface driver usbfs
kset_find_obj:ffff88012d2ec780
usbcore: registered new interface driver hub
kset_find_obj:ffff88012d2ec780
kset_find_obj:ffff88012d2ec840
usbcore: registered new device driver usb
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8e2540
kset_find_obj:ffffffffa001b650
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_register:ffff88012d053818
Pid: 1307, comm: modprobe Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81236222>] bus_register+0xc2/0x280
 [<ffffffffa003e000>] ? fw_core_init+0x0/0x90 [firewire_core]
 [<ffffffffa003e010>] fw_core_init+0x10/0x90 [firewire_core]
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff81067296>] sys_init_module+0xd6/0x250
 [<ffffffff8100246b>] system_call_fastpath+0x16/0x1b
kset_register:ffff88012e94c498
Pid: 1307, comm: modprobe Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff8123624e>] bus_register+0xee/0x280
 [<ffffffffa003e000>] ? fw_core_init+0x0/0x90 [firewire_core]
 [<ffffffffa003e010>] fw_core_init+0x10/0x90 [firewire_core]
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff81067296>] sys_init_module+0xd6/0x250
 [<ffffffff8100246b>] system_call_fastpath+0x16/0x1b
kset_register:ffff88012e94c018
Pid: 1307, comm: modprobe Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff81185b3f>] kset_create_and_add+0x6f/0xa0
 [<ffffffff81236274>] bus_register+0x114/0x280
 [<ffffffffa003e000>] ? fw_core_init+0x0/0x90 [firewire_core]
 [<ffffffffa003e010>] fw_core_init+0x10/0x90 [firewire_core]
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff81067296>] sys_init_module+0xd6/0x250
 [<ffffffff8100246b>] system_call_fastpath+0x16/0x1b
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8e2540
kset_find_obj:ffffffffa001b650
kset_find_obj:ffffffffa00398b0
kset_find_obj:ffff88012f987d80
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8e2540
kset_find_obj:ffffffffa001b650
kset_find_obj:ffffffffa00398b0
kset_find_obj:ffffffffa00506f0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8e2540
kset_find_obj:ffffffffa001b650
kset_find_obj:ffffffffa00398b0
kset_find_obj:ffffffffa00506f0
kset_find_obj:ffffffffa0060970
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8e2540
kset_find_obj:ffffffffa001b650
kset_find_obj:ffffffffa00398b0
kset_find_obj:ffffffffa00506f0
kset_find_obj:ffffffffa0060970
kset_find_obj:ffffffffa006c3b0
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8e2540
kset_find_obj:ffffffffa001b650
kset_find_obj:ffffffffa00398b0
kset_find_obj:ffffffffa00506f0
kset_find_obj:ffffffffa0060970
kset_find_obj:ffffffffa006c3b0
kset_find_obj:ffffffffa0076610
kset_register:ffff88012d846a18
Pid: 1250, comm: modprobe Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff8118557a>] kset_register+0x4a/0x70
 [<ffffffff8123772c>] __class_register+0xdc/0x1d0
 [<ffffffff8123787f>] __class_create+0x5f/0x90
 [<ffffffffa0081000>] ? init_soundcore+0x0/0x9a [soundcore]
 [<ffffffffa008105f>] init_soundcore+0x5f/0x9a [soundcore]
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff81067296>] sys_init_module+0xd6/0x250
 [<ffffffff8100246b>] system_call_fastpath+0x16/0x1b
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8e2540
kset_find_obj:ffffffffa001b650
kset_find_obj:ffffffffa00398b0
kset_find_obj:ffffffffa00506f0
kset_find_obj:ffffffffa0060970
kset_find_obj:ffffffffa006c3b0
kset_find_obj:ffffffffa0076610
kset_find_obj:ffffffffa007e030
kset_find_obj:ffff88012fa8c300
kset_find_obj:ffff88012ee193c0
IT8716 SuperIO detected.
kset_find_obj:ffff88012f9e0c00
kset_find_obj:ffff88012fac4780
kset_find_obj:ffff88012fa8f240
kset_find_obj:ffff88012ee19b40
kset_find_obj:ffff88012ed00f00
parport_pc 00:09: reported by Plug and Play ACPI
parport0: PC-style at 0x378, irq 7 [PCSPP(,...)]
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8e2540
kset_find_obj:ffffffffa001b650
kset_find_obj:ffffffffa00398b0
kset_find_obj:ffffffffa00506f0
kset_find_obj:ffffffffa0060970
kset_find_obj:ffffffffa006c3b0
kset_find_obj:ffffffffa0076610
kset_find_obj:ffffffffa007e030
kset_find_obj:ffffffffa008ad70
BUG: unable to handle kernel paging request at ffffffffa005857f
IP: [<ffffffff811895fb>] strcmp+0xb/0x30
PGD 1498067 PUD 149c063 PMD 12d0aa067 PTE 0
Oops: 0000 [#1] SMP 
last sysfs file: /sys/devices/pci0000:00/0000:00:05.1/host2/target2:0:0/2:0:0:0/block/sdc/uevent
CPU 0 
Pid: 1246, comm: modprobe Not tainted 2.6.33-bmg #2 M55S-S3/ 
RIP: 0010:[<ffffffff811895fb>]  [<ffffffff811895fb>] strcmp+0xb/0x30
RSP: 0018:ffff88012ebbde58  EFLAGS: 00010292
RAX: 0000000000000070 RBX: ffff88012f987d80 RCX: 0000000000000000
RDX: ffffffff814a64a8 RSI: ffffffffa005857f RDI: ffff88012f8e0410
RBP: ffff88012ebbde58 R08: 0000000000000000 R09: ffff88012ebbda56
R10: ffff88012ebbda55 R11: 00000000000000ff R12: ffff88012f8842a0
R13: ffffffffa005857f R14: 0000000000a7b970 R15: 0000000000a79050
FS:  00007f53ebdcb6f0(0000) GS:ffff880028200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffffffffa005857f CR3: 000000012ebe2000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process modprobe (pid: 1246, threadinfo ffff88012ebbc000, task ffff88012eeca340)
Stack:
 ffff88012ebbde88 ffffffff81185320 ffff88012ebbde88 ffffffffa0050080
<0> ffffffffa00500e0 0000000000a7b970 ffff88012ebbde98 ffffffff81236ba7
<0> ffff88012ebbded8 ffffffff81236cc7 ffff88012ebbdf08 ffffffff81034855
Call Trace:
 [<ffffffff81185320>] kset_find_obj+0x70/0x90
 [<ffffffff81236ba7>] driver_find+0x17/0x30
 [<ffffffff81236cc7>] driver_register+0x67/0x140
 [<ffffffff81034855>] ? try_to_wake_up+0x215/0x2f0
 [<ffffffff8119b791>] __pci_register_driver+0x51/0xd0
 [<ffffffffa0054000>] ? init_nic+0x0/0x20 [forcedeth]
 [<ffffffffa005401e>] init_nic+0x1e/0x20 [forcedeth]
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff81067296>] sys_init_module+0xd6/0x250
 [<ffffffff8100246b>] system_call_fastpath+0x16/0x1b
Code: 0f b6 3e 48 ff c6 40 84 ff 40 88 39 74 0b 48 ff c1 48 ff ca 75 ea c6 01 00 c9 c3 0f 1f 44 00 00 55 48 89 e5 0f 1f 40 00 0f b6 07 <0f> b6 16 48 ff c7 48 ff c6 38 d0 75 08 84 c0 75 ec 31 c0 c9 c3 
RIP  [<ffffffff811895fb>] strcmp+0xb/0x30
 RSP <ffff88012ebbde58>
CR2: ffffffffa005857f
---[ end trace d116f5ab7701ae4e ]---
kset_find_obj:ffff88012f8844e0
kset_find_obj:ffff88012f884540
kset_find_obj:ffff88012f8845a0
kset_find_obj:ffff88012f884600
kset_find_obj:ffff88012f884660
kset_find_obj:ffff88012f8846c0
kset_find_obj:ffff88012f884720
kset_find_obj:ffff88012f884780
kset_find_obj:ffff88012f8847e0
kset_find_obj:ffff88012f884840
kset_find_obj:ffff88012f8848a0
kset_find_obj:ffff88012f8e2060
kset_find_obj:ffff88012f8e20c0
kset_find_obj:ffff88012f8e2120
kset_find_obj:ffff88012f8e2180
kset_find_obj:ffff88012f8e2240
kset_find_obj:ffff88012f8e22a0
kset_find_obj:ffff88012f8e2300
kset_find_obj:ffff88012f8e2360
kset_find_obj:ffff88012f8e23c0
kset_find_obj:ffff88012f8e2420
kset_find_obj:ffff88012f8e2480
kset_find_obj:ffff88012f8e2540
kset_find_obj:ffffffffa001b650
kset_find_obj:ffffffffa00398b0
kset_find_obj:ffffffffa00506f0
kset_find_obj:ffffffffa0060970
kset_find_obj:ffffffffa006c3b0
kset_find_obj:ffffffffa0076610
kset_find_obj:ffffffffa007e030
kset_find_obj:ffffffffa008ad70
kset_find_obj:ffffffffa0096810
kset_find_obj:ffff88012ee119c0
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver

--EVF5PPMfhYS0aIcm--
