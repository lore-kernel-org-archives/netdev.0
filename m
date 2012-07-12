From: Joe Jin <joe.jin@oracle.com>
Subject: Re: 82571EB: Detected Hardware Unit Hang
Date: Fri, 13 Jul 2012 07:46:05 +0800
Message-ID: <4FFF61BD.1060604@oracle.com>
References: <4FFA9B96.6040901@oracle.com> <4FFCCA22.8060006@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274EEC8B@ORSMSX102.amr.corp.intel.com>
	<4FFCDA6C.8020708@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274EED74@ORSMSX102.amr.corp.intel.com>
	<4FFCF314.6020400@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274EEDD7@ORSMSX102.amr.corp.intel.com>
	<4FFD0908.6080506@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274EF8AD@ORSMSX102.amr.corp.intel.com>
	<4FFE3505.8060407@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274F018D@ORSMSX102.amr.corp.intel.com>
	<4FFE3D27.7020500@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274F01BE@ORSMSX102.amr.corp.intel.com>
	<4FFE40A9.4060807@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274F02D7@ORSMSX102.amr.corp.intel.com>
	<4FFE6BB9.4060106@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274F033B@ORSMSX102.amr.corp.intel.com>
	<4FFE787B.9050201@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274F0ACC@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Dave, Tushar N" <tushar.n.dave@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <061C8A8601E8EE4CA8D8FD6990CEA891274F0ACC@ORSMSX102.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 07/13/12 02:19, Dave, Tushar N wrote:
>> -----Original Message-----
>> From: Joe Jin [mailto:joe.jin@oracle.com]
>> Sent: Thursday, July 12, 2012 12:11 AM
>> To: Dave, Tushar N
>> Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>> kernel@vger.kernel.org
>> Subject: Re: 82571EB: Detected Hardware Unit Hang
>>
>> On 07/12/12 14:41, Dave, Tushar N wrote:
>>>> On 07/12/12 13:57, Dave, Tushar N wrote:
>>>>>> -----Original Message-----
>>>>>> From: Joe Jin [mailto:joe.jin@oracle.com]
>>>>>> Sent: Wednesday, July 11, 2012 8:13 PM
>>>>>> To: Dave, Tushar N
>>>>>> Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>>>>>> kernel@vger.kernel.org
>>>>>> Subject: Re: 82571EB: Detected Hardware Unit Hang
>>>>>>
>>>>>> On 07/12/12 11:07, Dave, Tushar N wrote:
>>>>>>>> -----Original Message-----
>>>>>>>> From: Joe Jin [mailto:joe.jin@oracle.com]
>>>>>>>> Sent: Wednesday, July 11, 2012 7:58 PM
>>>>>>>> To: Dave, Tushar N
>>>>>>>> Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>>>>>>>> kernel@vger.kernel.org
>>>>>>>> Subject: Re: 82571EB: Detected Hardware Unit Hang
>>>>>>>>
>>>>>>>> On 07/12/12 10:52, Dave, Tushar N wrote:
>>>>>>>>> What is the exact error messages in BIOS log?
>>>>>>>>
>>>>>>>> Error message from BIOS event log:
>>>>>>>> 07/12/12 05:54:00
>>>>>>>>    PCI Express Non-Fatal Error
>>>>>>>>
>>>>>>>> Thanks,
>>>>>>>> Joe
>>>>>> Hi Tushar,
>>>>>>
>>>>>> Please find eeprom from attachment.
>>>>>
>>>>> Do you have lspci -vvv dump of entire system before and after issue
>>>> occurs? If you have can you send it to me?
>>>>>
>>>>
>>> Sorry but I meant the full lspci -vvv of *entire system* before and
>> after issue occurs and not of 82571 only.
>>>
>>
>> Before:
>> =======
>> 00:00.0 Host bridge: Intel Corporation 5500 I/O Hub to ESI Port (rev 22)
>> 	Subsystem: Oracle Corporation Device 5352
> 
> Joe, thanks for all the data.
> You said you have changed max payload size and issue stop occurring. How did you change it? Where did you make that change in BIOS or EEPROM or in PCIe config space?
> Also please send me the full dmesg of entire system after you change max payload size.
> 

I modified it via BIOS.

Full dmesg with pcie-payload-size=128:

Initializing cgroup subsys cpuset
Initializing cgroup subsys cpu
Linux version 2.6.32-300.29.1uek.debug (root@x2270m2-tvp540-h.uk.oracle.com) (gcc version 4.1.2 20080704 (Red Hat 4.1.2-52)) #1 SMP Wed Jul 11 23:57:55 EDT 2012
Command line: ro root=/dev/VolGroup00/LogVol00 rhgb quiet
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  Centaur CentaurHauls
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009b400 (usable)
 BIOS-e820: 000000000009b400 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000bf750000 (usable)
 BIOS-e820: 00000000bf75e000 - 00000000bf760000 type 9
 BIOS-e820: 00000000bf760000 - 00000000bf76e000 (ACPI data)
 BIOS-e820: 00000000bf76e000 - 00000000bf7d0000 (ACPI NVS)
 BIOS-e820: 00000000bf7d0000 - 00000000bf7e0000 (reserved)
 BIOS-e820: 00000000bf7ec000 - 00000000c0000000 (reserved)
 BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000ffa00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000000c40000000 (usable)
DMI present.
AMI BIOS detected: BIOS may corrupt low RAM, working around it.
e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
last_pfn = 0xc40000 max_arch_pfn = 0x400000000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-BFFFF uncachable
  C0000-CBFFF write-protect
  CC000-CFFFF write-through
  D0000-DFFFF uncachable
  E0000-E7FFF write-protect
  E8000-EFFFF write-through
  F0000-FFFFF write-protect
MTRR variable ranges enabled:
  0 base 0000000000 mask F800000000 write-back
  1 base 0800000000 mask FC00000000 write-back
  2 base 0C00000000 mask FFC0000000 write-back
  3 base 00C0000000 mask FFC0000000 uncachable
  4 base 00BF800000 mask FFFF800000 uncachable
  5 disabled
  6 disabled
  7 disabled
  8 disabled
  9 disabled
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
original variable MTRRs
reg 0, base: 0GB, range: 32GB, type WB
reg 1, base: 32GB, range: 16GB, type WB
reg 2, base: 48GB, range: 1GB, type WB
reg 3, base: 3GB, range: 1GB, type UC
reg 4, base: 3064MB, range: 8MB, type UC
total RAM covered: 49144M
Found optimal setting for mtrr clean up
 gran_size: 64K 	chunk_size: 16M 	num_reg: 8  	lose cover RAM: 0G
New variable MTRRs
reg 0, base: 0GB, range: 2GB, type WB
reg 1, base: 2GB, range: 1GB, type WB
reg 2, base: 3064MB, range: 8MB, type UC
reg 3, base: 4GB, range: 4GB, type WB
reg 4, base: 8GB, range: 8GB, type WB
reg 5, base: 16GB, range: 16GB, type WB
reg 6, base: 32GB, range: 16GB, type WB
reg 7, base: 48GB, range: 1GB, type WB
e820 update range: 00000000bf800000 - 0000000100000000 (usable) ==> (reserved)
last_pfn = 0xbf750 max_arch_pfn = 0x400000000
initial memory mapped : 0 - 20000000
Using GB pages for direct mapping
init_memory_mapping: 0000000000000000-00000000bf750000
 0000000000 - 00bf750000 page 4k
kernel direct mapping tables up to bf750000 @ 100000-700000
init_memory_mapping: 0000000100000000-0000000c40000000
 0100000000 - 0c40000000 page 4k
kernel direct mapping tables up to c40000000 @ 2285000-84b7000
RAMDISK: 37c57000 - 37fefa1a
ACPI: RSDP 00000000000fad90 00024 (v02 ACPIAM)
ACPI: XSDT 00000000bf760100 000A4 (v01 111210 XSDT1126 20101112 MSFT 00000097)
ACPI: FACP 00000000bf760290 000F4 (v04 111210 FACP1126 20101112 MSFT 00000097)
ACPI: DSDT 00000000bf7605c0 05DF8 (v02  WASPC WASPC207 00000207 INTL 20051117)
ACPI: FACS 00000000bf76e000 00040
ACPI: APIC 00000000bf760390 0011E (v02 111210 APIC1126 20101112 MSFT 00000097)
ACPI: SPCR 00000000bf7604b0 00050 (v01 111210 SPCR1126 20101112 MSFT 00000097)
ACPI: MCFG 00000000bf760500 0003C (v01 111210 OEMMCFG  20101112 MSFT 00000097)
ACPI: SLIT 00000000bf760540 00030 (v01 111210 OEMSLIT  20101112 MSFT 00000097)
ACPI: SPMI 00000000bf760570 00041 (v05 111210 OEMSPMI  20101112 MSFT 00000097)
ACPI: OEMB 00000000bf76e040 00082 (v01 111210 OEMB1126 20101112 MSFT 00000097)
ACPI: HPET 00000000bf76a5c0 00038 (v01 111210 OEMHPET  20101112 MSFT 00000097)
ACPI: SRAT 00000000bf76a600 00250 (v02 111210 OEMSRAT  00000001 INTL 00000001)
ACPI: DMAR 00000000bf76e0d0 00120 (v01    AMI  OEMDMAR 00000001 MSFT 00000097)
ACPI: TCPA 00000000bf76a850 00032 (v01 111210 TBLOEMID 00000001 MSFT 00000097)
ACPI: SSDT 00000000bf787ba0 00363 (v01 DpgPmm    CpuPm 00000012 INTL 20051117)
ACPI: EINJ 00000000bf76a890 00130 (v01  AMIER AMI_EINJ 20101112 MSFT 00000097)
ACPI: BERT 00000000bf76aa20 00030 (v01  AMIER AMI_BERT 20101112 MSFT 00000097)
ACPI: ERST 00000000bf76aa50 001B0 (v01  AMIER AMI_ERST 20101112 MSFT 00000097)
ACPI: HEST 00000000bf76ac00 000A8 (v01  AMIER ABC_HEST 20101112 MSFT 00000097)
ACPI: Local APIC address 0xfee00000
SRAT: PXM 0 -> APIC 0 -> Node 0
SRAT: PXM 0 -> APIC 2 -> Node 0
SRAT: PXM 0 -> APIC 4 -> Node 0
SRAT: PXM 0 -> APIC 16 -> Node 0
SRAT: PXM 0 -> APIC 18 -> Node 0
SRAT: PXM 0 -> APIC 20 -> Node 0
SRAT: PXM 0 -> APIC 1 -> Node 0
SRAT: PXM 0 -> APIC 3 -> Node 0
SRAT: PXM 0 -> APIC 5 -> Node 0
SRAT: PXM 0 -> APIC 17 -> Node 0
SRAT: PXM 0 -> APIC 19 -> Node 0
SRAT: PXM 0 -> APIC 21 -> Node 0
SRAT: PXM 1 -> APIC 32 -> Node 1
SRAT: PXM 1 -> APIC 34 -> Node 1
SRAT: PXM 1 -> APIC 36 -> Node 1
SRAT: PXM 1 -> APIC 48 -> Node 1
SRAT: PXM 1 -> APIC 50 -> Node 1
SRAT: PXM 1 -> APIC 52 -> Node 1
SRAT: PXM 1 -> APIC 33 -> Node 1
SRAT: PXM 1 -> APIC 35 -> Node 1
SRAT: PXM 1 -> APIC 37 -> Node 1
SRAT: PXM 1 -> APIC 49 -> Node 1
SRAT: PXM 1 -> APIC 51 -> Node 1
SRAT: PXM 1 -> APIC 53 -> Node 1
SRAT: Node 0 PXM 0 0-a0000
SRAT: Node 0 PXM 0 100000-c0000000
SRAT: Node 0 PXM 0 100000000-640000000
SRAT: Node 1 PXM 1 640000000-c40000000
NUMA: Allocated memnodemap from 14040 - 2c880
NUMA: Using 20 for the hash shift.
Bootmem setup node 0 0000000000000000-0000000640000000
  NODE_DATA [000000000002c880 - 000000000004287f]
  bootmap [00000000006fe000 -  00000000007c5fff] pages c8
(11 early reservations) ==> bootmem [0000000000 - 0640000000]
  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
  #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
  #2 [0001000000 - 0002283a30]    TEXT DATA BSS ==> [0001000000 - 0002283a30]
  #3 [0037c57000 - 0037fefa1a]          RAMDISK ==> [0037c57000 - 0037fefa1a]
  #4 [000009b400 - 0000100000]    BIOS reserved ==> [000009b400 - 0000100000]
  #5 [0002284000 - 00022841d1]              BRK ==> [0002284000 - 00022841d1]
  #6 [0000010000 - 0000014000]      ACPI WAKEUP ==> [0000010000 - 0000014000]
  #7 [0000100000 - 00006fe000]          PGTABLE ==> [0000100000 - 00006fe000]
  #8 [0002285000 - 0007cb2000]          PGTABLE ==> [0002285000 - 0007cb2000]
  #9 [0000014000 - 0000014030]        ACPI SLIT ==> [0000014000 - 0000014030]
  #10 [0000014040 - 000002c880]       MEMNODEMAP ==> [0000014040 - 000002c880]
Bootmem setup node 1 0000000640000000-0000000c40000000
  NODE_DATA [0000000640000000 - 0000000640015fff]
  bootmap [0000000640016000 -  00000006400d5fff] pages c0
(11 early reservations) ==> bootmem [0640000000 - 0c40000000]
  #0 [0000000000 - 0000001000]   BIOS data page
  #1 [0000006000 - 0000008000]       TRAMPOLINE
  #2 [0001000000 - 0002283a30]    TEXT DATA BSS
  #3 [0037c57000 - 0037fefa1a]          RAMDISK
  #4 [000009b400 - 0000100000]    BIOS reserved
  #5 [0002284000 - 00022841d1]              BRK
  #6 [0000010000 - 0000014000]      ACPI WAKEUP
  #7 [0000100000 - 00006fe000]          PGTABLE
  #8 [0002285000 - 0007cb2000]          PGTABLE
  #9 [0000014000 - 0000014030]        ACPI SLIT
  #10 [0000014040 - 000002c880]       MEMNODEMAP
found SMP MP-table at [ffff8800000ff780] ff780
 [ffffea0000000000-ffffea00105fffff] PMD -> [ffff880028600000-ffff880037bfffff] on node 0
 [ffffea0010600000-ffffea0018ffffff] PMD -> [ffff880038000000-ffff8800409fffff] on node 0
 [ffffea0019000000-ffffea0030ffffff] PMD -> [ffff880640200000-ffff8806581fffff] on node 1
Zone PFN ranges:
  DMA      0x00000010 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00c40000
Movable zone start PFN for each node
early_node_map[4] active PFN ranges
    0: 0x00000010 -> 0x0000009b
    0: 0x00000100 -> 0x000bf750
    0: 0x00100000 -> 0x00640000
    1: 0x00640000 -> 0x00c40000
On node 0 totalpages: 6289115
  DMA zone: 64 pages used for memmap
  DMA zone: 1665 pages reserved
  DMA zone: 2250 pages, LIFO batch:0
  DMA32 zone: 16320 pages used for memmap
  DMA32 zone: 763792 pages, LIFO batch:31
  Normal zone: 86016 pages used for memmap
  Normal zone: 5419008 pages, LIFO batch:31
On node 1 totalpages: 6291456
  Normal zone: 98304 pages used for memmap
  Normal zone: 6193152 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0x808
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x04] enabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x10] enabled)
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x12] enabled)
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x14] enabled)
ACPI: LAPIC (acpi_id[0x07] lapic_id[0x20] enabled)
ACPI: LAPIC (acpi_id[0x08] lapic_id[0x22] enabled)
ACPI: LAPIC (acpi_id[0x09] lapic_id[0x24] enabled)
ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x30] enabled)
ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x32] enabled)
ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x34] enabled)
ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x03] enabled)
ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x05] enabled)
ACPI: LAPIC (acpi_id[0x10] lapic_id[0x11] enabled)
ACPI: LAPIC (acpi_id[0x11] lapic_id[0x13] enabled)
ACPI: LAPIC (acpi_id[0x12] lapic_id[0x15] enabled)
ACPI: LAPIC (acpi_id[0x13] lapic_id[0x21] enabled)
ACPI: LAPIC (acpi_id[0x14] lapic_id[0x23] enabled)
ACPI: LAPIC (acpi_id[0x15] lapic_id[0x25] enabled)
ACPI: LAPIC (acpi_id[0x16] lapic_id[0x31] enabled)
ACPI: LAPIC (acpi_id[0x17] lapic_id[0x33] enabled)
ACPI: LAPIC (acpi_id[0x18] lapic_id[0x35] enabled)
ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
ACPI: IOAPIC (id[0x06] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 6, version 32, address 0xfec00000, GSI 0-23
ACPI: IOAPIC (id[0x07] address[0xfec8a000] gsi_base[24])
IOAPIC[1]: apic_id 7, version 32, address 0xfec8a000, GSI 24-47
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x8086a301 base: 0xfed00000
SMP: Allowing 24 CPUs, 0 hotplug CPUs
nr_irqs_gsi: 48
PM: Registered nosave memory: 000000000009b000 - 000000000009c000
PM: Registered nosave memory: 000000000009c000 - 00000000000a0000
PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
PM: Registered nosave memory: 00000000bf750000 - 00000000bf75e000
PM: Registered nosave memory: 00000000bf75e000 - 00000000bf760000
PM: Registered nosave memory: 00000000bf760000 - 00000000bf76e000
PM: Registered nosave memory: 00000000bf76e000 - 00000000bf7d0000
PM: Registered nosave memory: 00000000bf7d0000 - 00000000bf7e0000
PM: Registered nosave memory: 00000000bf7e0000 - 00000000bf7ec000
PM: Registered nosave memory: 00000000bf7ec000 - 00000000c0000000
PM: Registered nosave memory: 00000000c0000000 - 00000000e0000000
PM: Registered nosave memory: 00000000e0000000 - 00000000f0000000
PM: Registered nosave memory: 00000000f0000000 - 00000000fee00000
PM: Registered nosave memory: 00000000fee00000 - 00000000fee01000
PM: Registered nosave memory: 00000000fee01000 - 00000000ffa00000
PM: Registered nosave memory: 00000000ffa00000 - 0000000100000000
Allocating PCI resources starting at c0000000 (gap: c0000000:20000000)
Booting paravirtualized kernel on bare hardware
NR_CPUS:256 nr_cpumask_bits:256 nr_cpu_ids:24 nr_node_ids:2
PERCPU: Embedded 29 pages/cpu @ffff880028200000 s88664 r8192 d21928 u131072
pcpu-alloc: s88664 r8192 d21928 u131072 alloc=1*2097152
pcpu-alloc: [0] 00 01 02 03 04 05 12 13 14 15 16 17 -- -- -- -- 
pcpu-alloc: [1] 06 07 08 09 10 11 18 19 20 21 22 23 -- -- -- -- 
Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 12378202
Policy zone: Normal
Kernel command line: ro root=/dev/VolGroup00/LogVol00 rhgb quiet
PID hash table entries: 4096 (order: 3, 32768 bytes)
Initializing CPU#0
Checking aperture...
No AGP bridge found
Calgary: detecting Calgary via BIOS EBDA area
Calgary: Unable to locate Rio Grande table in EBDA - bailing!
PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Placing 64MB software IO TLB between ffff880020000000 - ffff880024000000
software IO TLB at phys 0x20000000 - 0x24000000
Memory: 49345116k/51380224k available (4546k kernel code, 1057940k absent, 977168k reserved, 7277k data, 1744k init)
Hierarchical RCU implementation.
NR_IRQS:4352 nr_irqs:1008
Extended CMOS year: 2000
Console: colour VGA+ 80x25
console [tty0] enabled
allocated 503316480 bytes of page_cgroup
please try 'cgroup_disable=memory' option if you don't want memory cgroups
hpet clockevent registered
Fast TSC calibration using PIT
Detected 2932.852 MHz processor.
Calibrating delay loop (skipped), value calculated using timer frequency.. 5865.70 BogoMIPS (lpj=2932852)
Security Framework initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
Dentry cache hash table entries: 8388608 (order: 14, 67108864 bytes)
Inode-cache hash table entries: 4194304 (order: 13, 33554432 bytes)
Mount-cache hash table entries: 256
Initializing cgroup subsys ns
Initializing cgroup subsys cpuacct
Initializing cgroup subsys memory
Initializing cgroup subsys devices
Initializing cgroup subsys freezer
Initializing cgroup subsys net_cls
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 0/0x0 -> Node 0
mce: CPU supports 9 MCE banks
CPU0: Thermal monitoring enabled (TM1)
CPU 0 MCA banks CMCI:2 CMCI:3 CMCI:5 CMCI:6 CMCI:8
using mwait in idle threads.
Performance Events: Westmere events, Intel PMU driver.
... version:                3
... bit width:              48
... generic registers:      4
... value mask:             0000ffffffffffff
... max period:             000000007fffffff
... fixed-purpose events:   3
... event mask:             000000070000000f
ACPI: Core revision 20090903
ftrace: converting mcount calls to 0f 1f 44 00 00
ftrace: allocating 26961 entries in 106 pages
DMAR: Host address width 40
DMAR: DRHD base: 0x000000fbffe000 flags: 0x1
IOMMU fbffe000: ver 1:0 cap c90780106f0462 ecap f020f6
DMAR: RMRR base: 0x000000000ec000 end: 0x000000000effff
DMAR: RMRR base: 0x000000bf7ec000 end: 0x000000bf7fffff
DMAR: ATSR flags: 0x0
Setting APIC routing to physical flat
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
CPU0: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
Booting processor 1 APIC 0x2 ip 0x6000
Initializing CPU#1
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 1/0x2 -> Node 0
CPU1: Thermal monitoring enabled (TM1)
CPU 1 MCA banks CMCI:2 CMCI:3 CMCI:5 SHD:6 SHD:8
CPU1: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Booting processor 2 APIC 0x4 ip 0x6000
Initializing CPU#2
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 2
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 2/0x4 -> Node 0
CPU2: Thermal monitoring enabled (TM1)
CPU 2 MCA banks CMCI:2 CMCI:3 CMCI:5 SHD:6 SHD:8
CPU2: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#2]: passed.
Booting processor 3 APIC 0x10 ip 0x6000
Initializing CPU#3
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 8
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 3/0x10 -> Node 0
CPU3: Thermal monitoring enabled (TM1)
CPU 3 MCA banks CMCI:2 CMCI:3 CMCI:5 SHD:6 SHD:8
CPU3: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#3]: passed.
Booting processor 4 APIC 0x12 ip 0x6000
Initializing CPU#4
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 9
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 4/0x12 -> Node 0
CPU4: Thermal monitoring enabled (TM1)
CPU 4 MCA banks CMCI:2 CMCI:3 CMCI:5 SHD:6 SHD:8
CPU4: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#4]: passed.
Booting processor 5 APIC 0x14 ip 0x6000
Initializing CPU#5
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 10
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 5/0x14 -> Node 0
CPU5: Thermal monitoring enabled (TM1)
CPU 5 MCA banks CMCI:2 CMCI:3 CMCI:5 SHD:6 SHD:8
CPU5: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#5]: passed.
Booting processor 6 APIC 0x20 ip 0x6000
Initializing CPU#6
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 0
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 6/0x20 -> Node 1
CPU6: Thermal monitoring enabled (TM1)
CPU 6 MCA banks CMCI:2 CMCI:3 CMCI:5 CMCI:6 CMCI:8
CPU6: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#6]: passed.
Booting processor 7 APIC 0x22 ip 0x6000
Initializing CPU#7
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 1
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 7/0x22 -> Node 1
CPU7: Thermal monitoring enabled (TM1)
CPU 7 MCA banks CMCI:2 CMCI:3 CMCI:5 SHD:6 SHD:8
CPU7: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#7]: passed.
Booting processor 8 APIC 0x24 ip 0x6000
Initializing CPU#8
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 2
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 8/0x24 -> Node 1
CPU8: Thermal monitoring enabled (TM1)
CPU 8 MCA banks CMCI:2 CMCI:3 CMCI:5 SHD:6 SHD:8
CPU8: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#8]: passed.
Booting processor 9 APIC 0x30 ip 0x6000
Initializing CPU#9
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 8
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 9/0x30 -> Node 1
CPU9: Thermal monitoring enabled (TM1)
CPU 9 MCA banks CMCI:2 CMCI:3 CMCI:5 SHD:6 SHD:8
CPU9: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#9]: passed.
Booting processor 10 APIC 0x32 ip 0x6000
Initializing CPU#10
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 9
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 10/0x32 -> Node 1
CPU10: Thermal monitoring enabled (TM1)
CPU 10 MCA banks CMCI:2 CMCI:3 CMCI:5 SHD:6 SHD:8
CPU10: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#10]: passed.
Booting processor 11 APIC 0x34 ip 0x6000
Initializing CPU#11
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 10
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 11/0x34 -> Node 1
CPU11: Thermal monitoring enabled (TM1)
CPU 11 MCA banks CMCI:2 CMCI:3 CMCI:5 SHD:6 SHD:8
CPU11: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#11]: passed.
Booting processor 12 APIC 0x1 ip 0x6000
Initializing CPU#12
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 12/0x1 -> Node 0
CPU12: Thermal monitoring enabled (TM1)
CPU 12 MCA banks SHD:2 SHD:3 SHD:5 SHD:6 SHD:8
CPU12: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#12]: passed.
Booting processor 13 APIC 0x3 ip 0x6000
Initializing CPU#13
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 13/0x3 -> Node 0
CPU13: Thermal monitoring enabled (TM1)
CPU 13 MCA banks SHD:2 SHD:3 SHD:5 SHD:6 SHD:8
CPU13: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#13]: passed.
Booting processor 14 APIC 0x5 ip 0x6000
Initializing CPU#14
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 2
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 14/0x5 -> Node 0
CPU14: Thermal monitoring enabled (TM1)
CPU 14 MCA banks SHD:2 SHD:3 SHD:5 SHD:6 SHD:8
CPU14: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#14]: passed.
Booting processor 15 APIC 0x11 ip 0x6000
Initializing CPU#15
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 8
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 15/0x11 -> Node 0
CPU15: Thermal monitoring enabled (TM1)
CPU 15 MCA banks SHD:2 SHD:3 SHD:5 SHD:6 SHD:8
CPU15: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#15]: passed.
Booting processor 16 APIC 0x13 ip 0x6000
Initializing CPU#16
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 9
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 16/0x13 -> Node 0
CPU16: Thermal monitoring enabled (TM1)
CPU 16 MCA banks SHD:2 SHD:3 SHD:5 SHD:6 SHD:8
CPU16: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#16]: passed.
Booting processor 17 APIC 0x15 ip 0x6000
Initializing CPU#17
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 10
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 17/0x15 -> Node 0
CPU17: Thermal monitoring enabled (TM1)
CPU 17 MCA banks SHD:2 SHD:3 SHD:5 SHD:6 SHD:8
CPU17: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#17]: passed.
Booting processor 18 APIC 0x21 ip 0x6000
Initializing CPU#18
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 0
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 18/0x21 -> Node 1
CPU18: Thermal monitoring enabled (TM1)
CPU 18 MCA banks SHD:2 SHD:3 SHD:5 SHD:6 SHD:8
CPU18: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#18]: passed.
Booting processor 19 APIC 0x23 ip 0x6000
Initializing CPU#19
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 1
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 19/0x23 -> Node 1
CPU19: Thermal monitoring enabled (TM1)
CPU 19 MCA banks SHD:2 SHD:3 SHD:5 SHD:6 SHD:8
CPU19: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#19]: passed.
Booting processor 20 APIC 0x25 ip 0x6000
Initializing CPU#20
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 2
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 20/0x25 -> Node 1
CPU20: Thermal monitoring enabled (TM1)
CPU 20 MCA banks SHD:2 SHD:3 SHD:5 SHD:6 SHD:8
CPU20: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#20]: passed.
Booting processor 21 APIC 0x31 ip 0x6000
Initializing CPU#21
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 8
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 21/0x31 -> Node 1
CPU21: Thermal monitoring enabled (TM1)
CPU 21 MCA banks SHD:2 SHD:3 SHD:5 SHD:6 SHD:8
CPU21: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#21]: passed.
Booting processor 22 APIC 0x33 ip 0x6000
Initializing CPU#22
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 9
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 22/0x33 -> Node 1
CPU22: Thermal monitoring enabled (TM1)
CPU 22 MCA banks SHD:2 SHD:3 SHD:5 SHD:6 SHD:8
CPU22: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#22]: passed.
Booting processor 23 APIC 0x35 ip 0x6000
Initializing CPU#23
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 10
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 12288K
CPU 23/0x35 -> Node 1
CPU23: Thermal monitoring enabled (TM1)
CPU 23 MCA banks SHD:2 SHD:3 SHD:5 SHD:6 SHD:8
CPU23: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#23]: passed.
Brought up 24 CPUs
Total of 24 processors activated (140776.82 BogoMIPS).
CPU0 attaching sched-domain:
 domain 0: span 0,12 level SIBLING
  groups: 0 (cpu_power = 589) 12 (cpu_power = 589)
  domain 1: span 0-5,12-17 level MC
   groups: 0,12 (cpu_power = 1178) 1,13 (cpu_power = 1178) 2,14 (cpu_power = 1178) 3,15 (cpu_power = 1178) 4,16 (cpu_power = 1178) 5,17 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 0-5,12-17 (cpu_power = 7068) 6-11,18-23 (cpu_power = 7068)
CPU1 attaching sched-domain:
 domain 0: span 1,13 level SIBLING
  groups: 1 (cpu_power = 589) 13 (cpu_power = 589)
  domain 1: span 0-5,12-17 level MC
   groups: 1,13 (cpu_power = 1178) 2,14 (cpu_power = 1178) 3,15 (cpu_power = 1178) 4,16 (cpu_power = 1178) 5,17 (cpu_power = 1178) 0,12 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 0-5,12-17 (cpu_power = 7068) 6-11,18-23 (cpu_power = 7068)
CPU2 attaching sched-domain:
 domain 0: span 2,14 level SIBLING
  groups: 2 (cpu_power = 589) 14 (cpu_power = 589)
  domain 1: span 0-5,12-17 level MC
   groups: 2,14 (cpu_power = 1178) 3,15 (cpu_power = 1178) 4,16 (cpu_power = 1178) 5,17 (cpu_power = 1178) 0,12 (cpu_power = 1178) 1,13 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 0-5,12-17 (cpu_power = 7068) 6-11,18-23 (cpu_power = 7068)
CPU3 attaching sched-domain:
 domain 0: span 3,15 level SIBLING
  groups: 3 (cpu_power = 589) 15 (cpu_power = 589)
  domain 1: span 0-5,12-17 level MC
   groups: 3,15 (cpu_power = 1178) 4,16 (cpu_power = 1178) 5,17 (cpu_power = 1178) 0,12 (cpu_power = 1178) 1,13 (cpu_power = 1178) 2,14 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 0-5,12-17 (cpu_power = 7068) 6-11,18-23 (cpu_power = 7068)
CPU4 attaching sched-domain:
 domain 0: span 4,16 level SIBLING
  groups: 4 (cpu_power = 589) 16 (cpu_power = 589)
  domain 1: span 0-5,12-17 level MC
   groups: 4,16 (cpu_power = 1178) 5,17 (cpu_power = 1178) 0,12 (cpu_power = 1178) 1,13 (cpu_power = 1178) 2,14 (cpu_power = 1178) 3,15 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 0-5,12-17 (cpu_power = 7068) 6-11,18-23 (cpu_power = 7068)
CPU5 attaching sched-domain:
 domain 0: span 5,17 level SIBLING
  groups: 5 (cpu_power = 589) 17 (cpu_power = 589)
  domain 1: span 0-5,12-17 level MC
   groups: 5,17 (cpu_power = 1178) 0,12 (cpu_power = 1178) 1,13 (cpu_power = 1178) 2,14 (cpu_power = 1178) 3,15 (cpu_power = 1178) 4,16 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 0-5,12-17 (cpu_power = 7068) 6-11,18-23 (cpu_power = 7068)
CPU6 attaching sched-domain:
 domain 0: span 6,18 level SIBLING
  groups: 6 (cpu_power = 589) 18 (cpu_power = 589)
  domain 1: span 6-11,18-23 level MC
   groups: 6,18 (cpu_power = 1178) 7,19 (cpu_power = 1178) 8,20 (cpu_power = 1178) 9,21 (cpu_power = 1178) 10,22 (cpu_power = 1178) 11,23 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 6-11,18-23 (cpu_power = 7068) 0-5,12-17 (cpu_power = 7068)
CPU7 attaching sched-domain:
 domain 0: span 7,19 level SIBLING
  groups: 7 (cpu_power = 589) 19 (cpu_power = 589)
  domain 1: span 6-11,18-23 level MC
   groups: 7,19 (cpu_power = 1178) 8,20 (cpu_power = 1178) 9,21 (cpu_power = 1178) 10,22 (cpu_power = 1178) 11,23 (cpu_power = 1178) 6,18 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 6-11,18-23 (cpu_power = 7068) 0-5,12-17 (cpu_power = 7068)
CPU8 attaching sched-domain:
 domain 0: span 8,20 level SIBLING
  groups: 8 (cpu_power = 589) 20 (cpu_power = 589)
  domain 1: span 6-11,18-23 level MC
   groups: 8,20 (cpu_power = 1178) 9,21 (cpu_power = 1178) 10,22 (cpu_power = 1178) 11,23 (cpu_power = 1178) 6,18 (cpu_power = 1178) 7,19 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 6-11,18-23 (cpu_power = 7068) 0-5,12-17 (cpu_power = 7068)
CPU9 attaching sched-domain:
 domain 0: span 9,21 level SIBLING
  groups: 9 (cpu_power = 589) 21 (cpu_power = 589)
  domain 1: span 6-11,18-23 level MC
   groups: 9,21 (cpu_power = 1178) 10,22 (cpu_power = 1178) 11,23 (cpu_power = 1178) 6,18 (cpu_power = 1178) 7,19 (cpu_power = 1178) 8,20 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 6-11,18-23 (cpu_power = 7068) 0-5,12-17 (cpu_power = 7068)
CPU10 attaching sched-domain:
 domain 0: span 10,22 level SIBLING
  groups: 10 (cpu_power = 589) 22 (cpu_power = 589)
  domain 1: span 6-11,18-23 level MC
   groups: 10,22 (cpu_power = 1178) 11,23 (cpu_power = 1178) 6,18 (cpu_power = 1178) 7,19 (cpu_power = 1178) 8,20 (cpu_power = 1178) 9,21 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 6-11,18-23 (cpu_power = 7068) 0-5,12-17 (cpu_power = 7068)
CPU11 attaching sched-domain:
 domain 0: span 11,23 level SIBLING
  groups: 11 (cpu_power = 589) 23 (cpu_power = 589)
  domain 1: span 6-11,18-23 level MC
   groups: 11,23 (cpu_power = 1178) 6,18 (cpu_power = 1178) 7,19 (cpu_power = 1178) 8,20 (cpu_power = 1178) 9,21 (cpu_power = 1177) 10,22 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 6-11,18-23 (cpu_power = 7068) 0-5,12-17 (cpu_power = 7068)
CPU12 attaching sched-domain:
 domain 0: span 0,12 level SIBLING
  groups: 12 (cpu_power = 589) 0 (cpu_power = 589)
  domain 1: span 0-5,12-17 level MC
   groups: 0,12 (cpu_power = 1178) 1,13 (cpu_power = 1178) 2,14 (cpu_power = 1178) 3,15 (cpu_power = 1178) 4,16 (cpu_power = 1178) 5,17 (cpu_power = 1177)
   domain 2: span 0-23 level NODE
    groups: 0-5,12-17 (cpu_power = 7068) 6-11,18-23 (cpu_power = 7068)
CPU13 attaching sched-domain:
 domain 0: span 1,13 level SIBLING
  groups: 13 (cpu_power = 589) 1 (cpu_power = 589)
  domain 1: span 0-5,12-17 level MC
   groups: 1,13 (cpu_power = 1178) 2,14 (cpu_power = 1177) 3,15 (cpu_power = 1178) 4,16 (cpu_power = 1178) 5,17 (cpu_power = 1177) 0,12 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 0-5,12-17 (cpu_power = 7068) 6-11,18-23 (cpu_power = 7068)
CPU14 attaching sched-domain:
 domain 0: span 2,14 level SIBLING
  groups: 14 (cpu_power = 589) 2 (cpu_power = 588)
  domain 1: span 0-5,12-17 level MC
   groups: 2,14 (cpu_power = 1177) 3,15 (cpu_power = 1178) 4,16 (cpu_power = 1178) 5,17 (cpu_power = 1177) 0,12 (cpu_power = 1178) 1,13 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 0-5,12-17 (cpu_power = 7068) 6-11,18-23 (cpu_power = 7068)
CPU15 attaching sched-domain:
 domain 0: span 3,15 level SIBLING
  groups: 15 (cpu_power = 589) 3 (cpu_power = 589)
  domain 1: span 0-5,12-17 level MC
   groups: 3,15 (cpu_power = 1178) 4,16 (cpu_power = 1178) 5,17 (cpu_power = 1177) 0,12 (cpu_power = 1178) 1,13 (cpu_power = 1178) 2,14 (cpu_power = 1177)
   domain 2: span 0-23 level NODE
    groups: 0-5,12-17 (cpu_power = 7068) 6-11,18-23 (cpu_power = 7068)
CPU16 attaching sched-domain:
 domain 0: span 4,16 level SIBLING
  groups: 16 (cpu_power = 589) 4 (cpu_power = 589)
  domain 1: span 0-5,12-17 level MC
   groups: 4,16 (cpu_power = 1178) 5,17 (cpu_power = 1177) 0,12 (cpu_power = 1178) 1,13 (cpu_power = 1178) 2,14 (cpu_power = 1177) 3,15 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 0-5,12-17 (cpu_power = 7068) 6-11,18-23 (cpu_power = 7068)
CPU17 attaching sched-domain:
 domain 0: span 5,17 level SIBLING
  groups: 17 (cpu_power = 589) 5 (cpu_power = 588)
  domain 1: span 0-5,12-17 level MC
   groups: 5,17 (cpu_power = 1177) 0,12 (cpu_power = 1178) 1,13 (cpu_power = 1178) 2,14 (cpu_power = 1177) 3,15 (cpu_power = 1178) 4,16 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 0-5,12-17 (cpu_power = 7068) 6-11,18-23 (cpu_power = 7068)
CPU18 attaching sched-domain:
 domain 0: span 6,18 level SIBLING
  groups: 18 (cpu_power = 589) 6 (cpu_power = 589)
  domain 1: span 6-11,18-23 level MC
   groups: 6,18 (cpu_power = 1178) 7,19 (cpu_power = 1177) 8,20 (cpu_power = 1177) 9,21 (cpu_power = 1177) 10,22 (cpu_power = 1178) 11,23 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 6-11,18-23 (cpu_power = 7068) 0-5,12-17 (cpu_power = 7068)
CPU19 attaching sched-domain:
 domain 0: span 7,19 level SIBLING
  groups: 19 (cpu_power = 589) 7 (cpu_power = 588)
  domain 1: span 6-11,18-23 level MC
   groups: 7,19 (cpu_power = 1177) 8,20 (cpu_power = 1177) 9,21 (cpu_power = 1177) 10,22 (cpu_power = 1178) 11,23 (cpu_power = 1178) 6,18 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 6-11,18-23 (cpu_power = 7068) 0-5,12-17 (cpu_power = 7068)
CPU20 attaching sched-domain:
 domain 0: span 8,20 level SIBLING
  groups: 20 (cpu_power = 589) 8 (cpu_power = 588)
  domain 1: span 6-11,18-23 level MC
   groups: 8,20 (cpu_power = 1177) 9,21 (cpu_power = 1177) 10,22 (cpu_power = 1178) 11,23 (cpu_power = 1178) 6,18 (cpu_power = 1178) 7,19 (cpu_power = 1177)
   domain 2: span 0-23 level NODE
    groups: 6-11,18-23 (cpu_power = 7068) 0-5,12-17 (cpu_power = 7068)
CPU21 attaching sched-domain:
 domain 0: span 9,21 level SIBLING
  groups: 21 (cpu_power = 589) 9 (cpu_power = 588)
  domain 1: span 6-11,18-23 level MC
   groups: 9,21 (cpu_power = 1177) 10,22 (cpu_power = 1178) 11,23 (cpu_power = 1178) 6,18 (cpu_power = 1178) 7,19 (cpu_power = 1177) 8,20 (cpu_power = 1177)
   domain 2: span 0-23 level NODE
    groups: 6-11,18-23 (cpu_power = 7068) 0-5,12-17 (cpu_power = 7068)
CPU22 attaching sched-domain:
 domain 0: span 10,22 level SIBLING
  groups: 22 (cpu_power = 589) 10 (cpu_power = 589)
  domain 1: span 6-11,18-23 level MC
   groups: 10,22 (cpu_power = 1178) 11,23 (cpu_power = 1178) 6,18 (cpu_power = 1178) 7,19 (cpu_power = 1177) 8,20 (cpu_power = 1177) 9,21 (cpu_power = 1177)
   domain 2: span 0-23 level NODE
    groups: 6-11,18-23 (cpu_power = 7068) 0-5,12-17 (cpu_power = 7068)
CPU23 attaching sched-domain:
 domain 0: span 11,23 level SIBLING
  groups: 23 (cpu_power = 589) 11 (cpu_power = 589)
  domain 1: span 6-11,18-23 level MC
   groups: 11,23 (cpu_power = 1178) 6,18 (cpu_power = 1178) 7,19 (cpu_power = 1177) 8,20 (cpu_power = 1177) 9,21 (cpu_power = 1177) 10,22 (cpu_power = 1178)
   domain 2: span 0-23 level NODE
    groups: 6-11,18-23 (cpu_power = 7068) 0-5,12-17 (cpu_power = 7068)
regulator: core version 0.5
Time:  3:25:42  Date: 07/13/12
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
PCI: MCFG area at e0000000 reserved in E820
PCI: Using MMCONFIG at e0000000 - efffffff
PCI: Using configuration type 1 for base access
bio: create slab <bio-0> at 0
ACPI: EC: Look up EC in DSDT
ACPI Warning for \_SB_._OSC: Return type mismatch - found Integer, expected Buffer (20090903/nspredef-1006)
\_SB_:_OSC evaluation returned wrong type
_OSC request data:1 6 
ACPI: Executed 1 blocks of module-level executable AML code
ACPI: Interpreter enabled
ACPI: (supports S0 S1 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: No dock devices found.
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
pci 0000:00:00.0: PME# disabled
pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
pci 0000:00:01.0: PME# disabled
pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
pci 0000:00:03.0: PME# disabled
pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
pci 0000:00:07.0: PME# disabled
pci 0000:00:13.0: reg 10 32bit mmio: [0xfec8a000-0xfec8afff]
pci 0000:00:13.0: PME# supported from D0 D3hot D3cold
pci 0000:00:13.0: PME# disabled
pci 0000:00:16.0: reg 10 64bit mmio: [0xfbbf0000-0xfbbf3fff]
pci 0000:00:16.1: reg 10 64bit mmio: [0xfbbec000-0xfbbeffff]
pci 0000:00:16.2: reg 10 64bit mmio: [0xfbbe8000-0xfbbebfff]
pci 0000:00:16.3: reg 10 64bit mmio: [0xfbbe4000-0xfbbe7fff]
pci 0000:00:16.4: reg 10 64bit mmio: [0xfbbe0000-0xfbbe3fff]
pci 0000:00:16.5: reg 10 64bit mmio: [0xfbbdc000-0xfbbdffff]
pci 0000:00:16.6: reg 10 64bit mmio: [0xfbbd8000-0xfbbdbfff]
pci 0000:00:16.7: reg 10 64bit mmio: [0xfbbd4000-0xfbbd7fff]
pci 0000:00:1a.0: reg 20 io port: [0x9800-0x981f]
pci 0000:00:1a.1: reg 20 io port: [0x9480-0x949f]
pci 0000:00:1a.2: reg 20 io port: [0x9400-0x941f]
pci 0000:00:1a.7: reg 10 32bit mmio: [0xfbbf4000-0xfbbf43ff]
pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1a.7: PME# disabled
pci 0000:00:1d.0: reg 20 io port: [0xa000-0xa01f]
pci 0000:00:1d.1: reg 20 io port: [0x9c00-0x9c1f]
pci 0000:00:1d.2: reg 20 io port: [0x9880-0x989f]
pci 0000:00:1d.7: reg 10 32bit mmio: [0xfbbf6000-0xfbbf63ff]
pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.7: PME# disabled
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0a00 (mask 00ff)
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 0ca0 (mask 003f)
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 4700 (mask 000f)
pci 0000:00:1f.2: reg 10 io port: [0xac00-0xac07]
pci 0000:00:1f.2: reg 14 io port: [0xa880-0xa883]
pci 0000:00:1f.2: reg 18 io port: [0xa800-0xa807]
pci 0000:00:1f.2: reg 1c io port: [0xa480-0xa483]
pci 0000:00:1f.2: reg 20 io port: [0xa400-0xa41f]
pci 0000:00:1f.2: reg 24 32bit mmio: [0xfbbfa000-0xfbbfa7ff]
pci 0000:00:1f.2: PME# supported from D3hot
pci 0000:00:1f.2: PME# disabled
pci 0000:00:1f.3: reg 10 64bit mmio: [0xfbbf8000-0xfbbf80ff]
pci 0000:00:1f.3: reg 20 io port: [0x400-0x41f]
pci 0000:07:00.0: reg 10 32bit mmio: [0xfbee0000-0xfbefffff]
pci 0000:07:00.0: reg 14 32bit mmio: [0xfbec0000-0xfbedffff]
pci 0000:07:00.0: reg 18 io port: [0xec00-0xec1f]
pci 0000:07:00.0: reg 1c 32bit mmio: [0xfbebc000-0xfbebffff]
pci 0000:07:00.0: reg 30 32bit mmio pref: [0xfbe80000-0xfbe9ffff]
pci 0000:07:00.0: PME# supported from D0 D3hot D3cold
pci 0000:07:00.0: PME# disabled
pci 0000:07:00.1: reg 10 32bit mmio: [0xfbe60000-0xfbe7ffff]
pci 0000:07:00.1: reg 14 32bit mmio: [0xfbe40000-0xfbe5ffff]
pci 0000:07:00.1: reg 18 io port: [0xe880-0xe89f]
pci 0000:07:00.1: reg 1c 32bit mmio: [0xfbe3c000-0xfbe3ffff]
pci 0000:07:00.1: reg 30 32bit mmio pref: [0xfbe00000-0xfbe1ffff]
pci 0000:07:00.1: PME# supported from D0 D3hot D3cold
pci 0000:07:00.1: PME# disabled
pci 0000:00:01.0: bridge io port: [0xe000-0xefff]
pci 0000:00:01.0: bridge 32bit mmio: [0xfbe00000-0xfbefffff]
pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
pci 0000:02:00.0: PME# disabled
pci 0000:00:07.0: bridge io port: [0xc000-0xdfff]
pci 0000:00:07.0: bridge 32bit mmio: [0xfbc00000-0xfbdfffff]
pci 0000:03:02.0: PME# supported from D0 D3hot D3cold
pci 0000:03:02.0: PME# disabled
pci 0000:03:04.0: PME# supported from D0 D3hot D3cold
pci 0000:03:04.0: PME# disabled
pci 0000:02:00.0: bridge io port: [0xc000-0xdfff]
pci 0000:02:00.0: bridge 32bit mmio: [0xfbc00000-0xfbdfffff]
pci 0000:05:00.0: reg 10 32bit mmio: [0xfbde0000-0xfbdfffff]
pci 0000:05:00.0: reg 14 32bit mmio: [0xfbdc0000-0xfbddffff]
pci 0000:05:00.0: reg 18 io port: [0xdc00-0xdc1f]
pci 0000:05:00.0: reg 30 32bit mmio pref: [0xfbda0000-0xfbdbffff]
pci 0000:05:00.0: PME# supported from D0 D3hot D3cold
pci 0000:05:00.0: PME# disabled
pci 0000:05:00.1: reg 10 32bit mmio: [0xfbd80000-0xfbd9ffff]
pci 0000:05:00.1: reg 14 32bit mmio: [0xfbd60000-0xfbd7ffff]
pci 0000:05:00.1: reg 18 io port: [0xd880-0xd89f]
pci 0000:05:00.1: PME# supported from D0 D3hot D3cold
pci 0000:05:00.1: PME# disabled
pci 0000:05:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
pci 0000:03:02.0: bridge io port: [0xd000-0xdfff]
pci 0000:03:02.0: bridge 32bit mmio: [0xfbd00000-0xfbdfffff]
pci 0000:04:00.0: reg 10 32bit mmio: [0xfbce0000-0xfbcfffff]
pci 0000:04:00.0: reg 14 32bit mmio: [0xfbcc0000-0xfbcdffff]
pci 0000:04:00.0: reg 18 io port: [0xcc00-0xcc1f]
pci 0000:04:00.0: PME# supported from D0 D3hot
pci 0000:04:00.0: PME# disabled
pci 0000:04:00.1: reg 10 32bit mmio: [0xfbca0000-0xfbcbffff]
pci 0000:04:00.1: reg 14 32bit mmio: [0xfbc80000-0xfbc9ffff]
pci 0000:04:00.1: reg 18 io port: [0xc880-0xc89f]
pci 0000:04:00.1: PME# supported from D0 D3hot
pci 0000:04:00.1: PME# disabled
pci 0000:04:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
pci 0000:03:04.0: bridge io port: [0xc000-0xcfff]
pci 0000:03:04.0: bridge 32bit mmio: [0xfbc00000-0xfbcfffff]
pci 0000:01:05.0: reg 10 32bit mmio: [0xfb000000-0xfb7fffff]
pci 0000:01:05.0: reg 14 32bit mmio: [0xfafe0000-0xfaffffff]
pci 0000:01:05.0: reg 18 io port: [0xbc00-0xbc7f]
pci 0000:01:05.0: supports D1 D2
pci 0000:01:05.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:01:05.0: PME# disabled
pci 0000:00:1e.0: transparent bridge
pci 0000:00:1e.0: bridge io port: [0xb000-0xbfff]
pci 0000:00:1e.0: bridge 32bit mmio: [0xfaf00000-0xfb7fffff]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE3._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE7._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 6 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs *5)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 6 7 10 11 12 14 *15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 6 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs *3 4 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 6 7 10 11 12 *14 15)
vgaarb: device added: PCI:0000:01:05.0,decodes=io+mem,owns=io+mem,locks=none
vgaarb: loaded
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
NetLabel: Initializing
NetLabel:  domain hash size = 128
NetLabel:  protocols = UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
hpet0: 4 comparators, 64-bit 14.318180 MHz counter
Switching to clocksource hpet
kstop/0 used greatest stack depth: 7240 bytes left
kstop/1 used greatest stack depth: 6968 bytes left
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 14 devices
ACPI: ACPI bus type pnp unregistered
system 00:01: iomem range 0xfbf00000-0xfbffffff has been reserved
system 00:01: iomem range 0xfc000000-0xfcffffff has been reserved
system 00:01: iomem range 0xfd000000-0xfdffffff has been reserved
system 00:01: iomem range 0xfe000000-0xfebfffff has been reserved
system 00:01: iomem range 0xfec8a000-0xfec8afff could not be reserved
system 00:01: iomem range 0xfed10000-0xfed10fff has been reserved
system 00:06: ioport range 0xa00-0xa0f has been reserved
system 00:06: ioport range 0xa10-0xa1f has been reserved
system 00:07: ioport range 0x4d0-0x4d1 has been reserved
system 00:07: ioport range 0x800-0x87f has been reserved
system 00:07: ioport range 0x500-0x57f has been reserved
system 00:07: ioport range 0xca2-0xca2 has been reserved
system 00:07: ioport range 0xca6-0xca6 has been reserved
system 00:07: ioport range 0xcaa-0xcaa has been reserved
system 00:07: ioport range 0xcae-0xcae has been reserved
system 00:07: ioport range 0xcb2-0xcb6 has been reserved
system 00:07: iomem range 0xfed1c000-0xfed1ffff has been reserved
system 00:07: iomem range 0xfed20000-0xfed3ffff has been reserved
system 00:07: iomem range 0xfed45000-0xfed89fff has been reserved
system 00:07: iomem range 0xfed20000-0xfed3ffff has been reserved
system 00:07: iomem range 0xfed45000-0xfed8ffff could not be reserved
system 00:07: iomem range 0xfec8a000-0xfec8afff could not be reserved
system 00:09: iomem range 0xfec00000-0xfec00fff could not be reserved
system 00:09: iomem range 0xfee00000-0xfee00fff has been reserved
system 00:0b: iomem range 0xe0000000-0xefffffff has been reserved
system 00:0d: iomem range 0x0-0x9ffff could not be reserved
system 00:0d: iomem range 0xc0000-0xcffff could not be reserved
system 00:0d: iomem range 0xe0000-0xfffff could not be reserved
system 00:0d: iomem range 0x100000-0xbfffffff could not be reserved
system 00:0d: iomem range 0xfed90000-0xffffffff could not be reserved
pci 0000:00:01.0: PCI bridge, secondary bus 0000:07
pci 0000:00:01.0:   IO window: 0xe000-0xefff
pci 0000:00:01.0:   MEM window: 0xfbe00000-0xfbefffff
pci 0000:00:01.0:   PREFETCH window: disabled
pci 0000:00:03.0: PCI bridge, secondary bus 0000:06
pci 0000:00:03.0:   IO window: disabled
pci 0000:00:03.0:   MEM window: disabled
pci 0000:00:03.0:   PREFETCH window: disabled
pci 0000:03:02.0: PCI bridge, secondary bus 0000:05
pci 0000:03:02.0:   IO window: 0xd000-0xdfff
pci 0000:03:02.0:   MEM window: 0xfbd00000-0xfbdfffff
pci 0000:03:02.0:   PREFETCH window: disabled
pci 0000:03:04.0: PCI bridge, secondary bus 0000:04
pci 0000:03:04.0:   IO window: 0xc000-0xcfff
pci 0000:03:04.0:   MEM window: 0xfbc00000-0xfbcfffff
pci 0000:03:04.0:   PREFETCH window: disabled
pci 0000:02:00.0: PCI bridge, secondary bus 0000:03
pci 0000:02:00.0:   IO window: 0xc000-0xdfff
pci 0000:02:00.0:   MEM window: 0xfbc00000-0xfbdfffff
pci 0000:02:00.0:   PREFETCH window: disabled
pci 0000:00:07.0: PCI bridge, secondary bus 0000:02
pci 0000:00:07.0:   IO window: 0xc000-0xdfff
pci 0000:00:07.0:   MEM window: 0xfbc00000-0xfbdfffff
pci 0000:00:07.0:   PREFETCH window: disabled
pci 0000:00:1e.0: PCI bridge, secondary bus 0000:01
pci 0000:00:1e.0:   IO window: 0xb000-0xbfff
pci 0000:00:1e.0:   MEM window: 0xfaf00000-0xfb7fffff
pci 0000:00:1e.0:   PREFETCH window: disabled
pci 0000:00:01.0: setting latency timer to 64
pci 0000:00:03.0: setting latency timer to 64
pci 0000:00:07.0: setting latency timer to 64
pci 0000:02:00.0: setting latency timer to 64
pci 0000:03:02.0: setting latency timer to 64
pci 0000:03:04.0: setting latency timer to 64
pci 0000:00:1e.0: setting latency timer to 64
pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffffffffffff]
pci_bus 0000:07: resource 0 io:  [0xe000-0xefff]
pci_bus 0000:07: resource 1 mem: [0xfbe00000-0xfbefffff]
pci_bus 0000:02: resource 0 io:  [0xc000-0xdfff]
pci_bus 0000:02: resource 1 mem: [0xfbc00000-0xfbdfffff]
pci_bus 0000:03: resource 0 io:  [0xc000-0xdfff]
pci_bus 0000:03: resource 1 mem: [0xfbc00000-0xfbdfffff]
pci_bus 0000:05: resource 0 io:  [0xd000-0xdfff]
pci_bus 0000:05: resource 1 mem: [0xfbd00000-0xfbdfffff]
pci_bus 0000:04: resource 0 io:  [0xc000-0xcfff]
pci_bus 0000:04: resource 1 mem: [0xfbc00000-0xfbcfffff]
pci_bus 0000:01: resource 0 io:  [0xb000-0xbfff]
pci_bus 0000:01: resource 1 mem: [0xfaf00000-0xfb7fffff]
pci_bus 0000:01: resource 3 io:  [0x00-0xffff]
pci_bus 0000:01: resource 4 mem: [0x000000-0xffffffffffffffff]
NET: Registered protocol family 2
IP route cache hash table entries: 524288 (order: 10, 4194304 bytes)
TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
TCP bind hash table entries: 65536 (order: 9, 2097152 bytes)
TCP: Hash tables configured (established 524288 bind 65536)
TCP reno registered
NET: Registered protocol family 1
pci 0000:07:00.0: Disabling L0s
pci 0000:07:00.1: Disabling L0s
pci 0000:01:05.0: Boot video device
Trying to unpack rootfs image as initramfs...
debug: unmapping init memory ffff880037c57000..ffff880037ff0000
audit: initializing netlink socket (disabled)
type=2000 audit(1342149941.046:1): initialized
HugeTLB registered 2 MB page size, pre-allocated 0 pages
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
msgmni has been set to 32768
SELinux:  Registering netfilter hooks
cryptomgr_test used greatest stack depth: 5752 bytes left
alg: No test for stdrng (krng)
ksign: Installing public key data
Loading keyring
- Added public key B53125DC86710D19
- User ID: Oracle America, Inc. (Kernel Module GPG key)
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered (default)
io scheduler cfq registered
  alloc irq_desc for 48 on node -1
  alloc kstat_irqs on node -1
pcieport 0000:00:01.0: irq 48 for MSI/MSI-X
pcieport 0000:00:01.0: setting latency timer to 64
  alloc irq_desc for 49 on node -1
  alloc kstat_irqs on node -1
pcieport 0000:00:03.0: irq 49 for MSI/MSI-X
pcieport 0000:00:03.0: setting latency timer to 64
  alloc irq_desc for 50 on node -1
  alloc kstat_irqs on node -1
pcieport 0000:00:07.0: irq 50 for MSI/MSI-X
pcieport 0000:00:07.0: setting latency timer to 64
pcieport 0000:02:00.0: setting latency timer to 64
  alloc irq_desc for 51 on node -1
  alloc kstat_irqs on node -1
pcieport 0000:03:02.0: irq 51 for MSI/MSI-X
pcieport 0000:03:02.0: setting latency timer to 64
  alloc irq_desc for 52 on node -1
  alloc kstat_irqs on node -1
pcieport 0000:03:04.0: irq 52 for MSI/MSI-X
pcieport 0000:03:04.0: setting latency timer to 64
aer 0000:00:01.0:pcie02: AER service couldn't init device: no _OSC support
aer 0000:00:03.0:pcie02: AER service couldn't init device: no _OSC support
aer 0000:00:07.0:pcie02: AER service couldn't init device: no _OSC support
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
pciehp: PCI Express Hot Plug Controller Driver version: 0.4
acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
input: Power Button as /class/input/input0
ACPI: Power Button [PWRB]
input: Power Button as /class/input/input1
ACPI: Power Button [PWRF]
ACPI: SSDT 00000000bf7804c0 0603C (v01 DpgPmm  P001Ist 00000011 INTL 20051117)
ACPI: SSDT 00000000bf786500 00C88 (v01  PmRef  P001Cst 00003001 INTL 20051117)
ACPI: SSDT 00000000bf787190 00A0A (v01  PmRef  Cpu0Tst 00003000 INTL 20051117)
Monitor-Mwait will be used to enter C-1 state
Monitor-Mwait will be used to enter C-2 state
Monitor-Mwait will be used to enter C-3 state
processor LNXCPU:00: registered as cooling_device0
processor LNXCPU:01: registered as cooling_device1
processor LNXCPU:02: registered as cooling_device2
processor LNXCPU:03: registered as cooling_device3
processor LNXCPU:04: registered as cooling_device4
processor LNXCPU:05: registered as cooling_device5
processor LNXCPU:06: registered as cooling_device6
processor LNXCPU:07: registered as cooling_device7
processor LNXCPU:08: registered as cooling_device8
processor LNXCPU:09: registered as cooling_device9
processor LNXCPU:0a: registered as cooling_device10
processor LNXCPU:0b: registered as cooling_device11
processor LNXCPU:0c: registered as cooling_device12
processor LNXCPU:0d: registered as cooling_device13
processor LNXCPU:0e: registered as cooling_device14
processor LNXCPU:0f: registered as cooling_device15
processor LNXCPU:10: registered as cooling_device16
processor LNXCPU:11: registered as cooling_device17
processor LNXCPU:12: registered as cooling_device18
processor LNXCPU:13: registered as cooling_device19
processor LNXCPU:14: registered as cooling_device20
processor LNXCPU:15: registered as cooling_device21
processor LNXCPU:16: registered as cooling_device22
processor LNXCPU:17: registered as cooling_device23
Non-volatile memory driver v1.3
Linux agpgart interface v0.103
tpm_tis 00:0a: 1.2 TPM (device-id 0xB, rev-id 16)
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
brd: module loaded
loop: module loaded
input: Macintosh mouse button emulation as /class/input/input2
Fixed MDIO Bus: probed
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
  alloc irq_desc for 18 on node -1
  alloc kstat_irqs on node -1
ehci_hcd 0000:00:1a.7: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ehci_hcd 0000:00:1a.7: setting latency timer to 64
ehci_hcd 0000:00:1a.7: EHCI Host Controller
ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1a.7: debug port 1
ehci_hcd 0000:00:1a.7: cache line size of 32 is not supported
ehci_hcd 0000:00:1a.7: irq 18, io mem 0xfbbf4000
ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00
usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb1: Product: EHCI Host Controller
usb usb1: Manufacturer: Linux 2.6.32-300.29.1uek.debug ehci_hcd
usb usb1: SerialNumber: 0000:00:1a.7
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
  alloc irq_desc for 23 on node -1
  alloc kstat_irqs on node -1
ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
ehci_hcd 0000:00:1d.7: setting latency timer to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
ehci_hcd 0000:00:1d.7: debug port 1
ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfbbf6000
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb2: Product: EHCI Host Controller
usb usb2: Manufacturer: Linux 2.6.32-300.29.1uek.debug ehci_hcd
usb usb2: SerialNumber: 0000:00:1d.7
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 6 ports detected
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
uhci_hcd: USB Universal Host Controller Interface driver
  alloc irq_desc for 16 on node -1
  alloc kstat_irqs on node -1
uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
uhci_hcd 0000:00:1a.0: setting latency timer to 64
uhci_hcd 0000:00:1a.0: UHCI Host Controller
uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1a.0: irq 16, io base 0x00009800
usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb3: Product: UHCI Host Controller
usb usb3: Manufacturer: Linux 2.6.32-300.29.1uek.debug uhci_hcd
usb usb3: SerialNumber: 0000:00:1a.0
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
  alloc irq_desc for 21 on node -1
  alloc kstat_irqs on node -1
uhci_hcd 0000:00:1a.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
uhci_hcd 0000:00:1a.1: setting latency timer to 64
uhci_hcd 0000:00:1a.1: UHCI Host Controller
uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1a.1: irq 21, io base 0x00009480
usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb4: Product: UHCI Host Controller
usb usb4: Manufacturer: Linux 2.6.32-300.29.1uek.debug uhci_hcd
usb usb4: SerialNumber: 0000:00:1a.1
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
  alloc irq_desc for 19 on node -1
  alloc kstat_irqs on node -1
uhci_hcd 0000:00:1a.2: PCI INT D -> GSI 19 (level, low) -> IRQ 19
uhci_hcd 0000:00:1a.2: setting latency timer to 64
uhci_hcd 0000:00:1a.2: UHCI Host Controller
uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1a.2: irq 19, io base 0x00009400
usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb5: Product: UHCI Host Controller
usb usb5: Manufacturer: Linux 2.6.32-300.29.1uek.debug uhci_hcd
usb usb5: SerialNumber: 0000:00:1a.2
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
uhci_hcd 0000:00:1d.0: setting latency timer to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000a000
usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb6: Product: UHCI Host Controller
usb usb6: Manufacturer: Linux 2.6.32-300.29.1uek.debug uhci_hcd
usb usb6: SerialNumber: 0000:00:1d.0
usb usb6: configuration #1 chosen from 1 choice
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
uhci_hcd 0000:00:1d.1: setting latency timer to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
uhci_hcd 0000:00:1d.1: irq 19, io base 0x00009c00
usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb7: Product: UHCI Host Controller
usb usb7: Manufacturer: Linux 2.6.32-300.29.1uek.debug uhci_hcd
usb usb7: SerialNumber: 0000:00:1d.1
usb usb7: configuration #1 chosen from 1 choice
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
uhci_hcd 0000:00:1d.2: setting latency timer to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
uhci_hcd 0000:00:1d.2: irq 18, io base 0x00009880
usb usb8: New USB device found, idVendor=1d6b, idProduct=0001
usb usb8: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb8: Product: UHCI Host Controller
usb usb8: Manufacturer: Linux 2.6.32-300.29.1uek.debug uhci_hcd
usb usb8: SerialNumber: 0000:00:1d.2
usb usb8: configuration #1 chosen from 1 choice
hub 8-0:1.0: USB hub found
hub 8-0:1.0: 2 ports detected
PNP: No PS/2 controller found. Probing ports directly.
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
rtc_cmos 00:03: RTC can wake from S4
rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
device-mapper: uevent: version 1.0.3
device-mapper: ioctl: 4.15.0-ioctl (2009-04-01) initialised: dm-devel@redhat.com
cpuidle: using governor ladder
cpuidle: using governor menu
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 17
PM: Resume from disk failed.
registered taskstats version 1
usb 1-3: new high speed USB device using ehci_hcd and address 2
  Magic number: 4:671:411
rtc_cmos 00:03: setting system clock to 2012-07-13 03:25:43 UTC (1342149943)
Initalizing network drop monitor service
debug: unmapping init memory ffffffff81b8d000..ffffffff81d41000
Write protecting the kernel read-only data: 6916k
usb 1-3: config 1 interface 0 altsetting 0 endpoint 0x81 has an invalid bInterval 255, changing to 11
usb 1-3: New USB device found, idVendor=046b, idProduct=ff01
usb 1-3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
usb 1-3: Product: Generic Hub
usb 1-3: Manufacturer: American Megatrends Inc.
usb 1-3: configuration #1 chosen from 1 choice
hub 1-3:1.0: USB hub found
hub 1-3:1.0: 2 ports detected
Refined TSC clocksource calibration: 2933.437 MHz.
Switching to clocksource tsc
udevd used greatest stack depth: 5296 bytes left
ahci 0000:00:1f.2: version 3.0
ahci 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
  alloc irq_desc for 53 on node -1
  alloc kstat_irqs on node -1
ahci 0000:00:1f.2: irq 53 for MSI/MSI-X
ahci: SSS flag set, parallel bus scan disabled
ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 6 ports 3 Gbps 0x3f impl SATA mode
ahci 0000:00:1f.2: flags: 64bit ncq sntf stag pm led clo pio slum part ccc ems sxs 
ahci 0000:00:1f.2: setting latency timer to 64
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
scsi4 : ahci
scsi5 : ahci
ata1: SATA max UDMA/133 abar m2048@0xfbbfa000 port 0xfbbfa100 irq 53
ata2: SATA max UDMA/133 irq_stat 0x00400040, connection status changed irq 53
ata3: SATA max UDMA/133 irq_stat 0x00400040, connection status changed irq 53
ata4: SATA max UDMA/133 abar m2048@0xfbbfa000 port 0xfbbfa280 irq 53
ata5: SATA max UDMA/133 irq_stat 0x00400040, connection status changed irq 53
ata6: SATA max UDMA/133 irq_stat 0x00400040, connection status changed irq 53
usb 5-1: new low speed USB device using uhci_hcd and address 2
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: ATA-7: SSDSA2SH032G1SB INTEL, 845C8855, max UDMA/133
ata1.00: 62500000 sectors, multi 1: LBA48 NCQ (depth 31)
ata1.00: configured for UDMA/133
scsi 0:0:0:0: Direct-Access     ATA      SSDSA2SH032G1SB  845C PQ: 0 ANSI: 5
sd 0:0:0:0: Attached scsi generic sg0 type 0
sd 0:0:0:0: [sda] 62500000 512-byte logical blocks: (32.0 GB/29.8 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sda: detected capacity change from 0 to 32000000000
 sda: sda1
 sda1: <solaris: [s0] sda5 [s2] sda6 [s8] sda7 >
sd 0:0:0:0: [sda] Attached SCSI disk
usb 5-1: New USB device found, idVendor=046b, idProduct=ff10
usb 5-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
usb 5-1: Product: Virtual Keyboard and Mouse
usb 5-1: Manufacturer: American Megatrends Inc.
usb 5-1: configuration #1 chosen from 1 choice
input: American Megatrends Inc. Virtual Keyboard and Mouse as /class/input/input3
generic-usb 0003:046B:FF10.0001: input,hidraw0: USB HID v1.10 Keyboard [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.2-1/input0
input: American Megatrends Inc. Virtual Keyboard and Mouse as /class/input/input4
generic-usb 0003:046B:FF10.0002: input,hidraw1: USB HID v1.10 Mouse [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.2-1/input1
ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata2.00: ATA-8: HITACHI H7220AA30SUN2.0T 1007MSUD0V, JKAOA28A, max UDMA/133
ata2.00: 3907029168 sectors, multi 0: LBA48 NCQ (depth 31/32), AA
ata2.00: configured for UDMA/133
scsi 1:0:0:0: Direct-Access     ATA      HITACHI H7220AA3 JKAO PQ: 0 ANSI: 5
sd 1:0:0:0: [sdb] 3907029168 512-byte logical blocks: (2.00 TB/1.81 TiB)
sd 1:0:0:0: Attached scsi generic sg1 type 0
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sdb: detected capacity change from 0 to 2000398934016
 sdb: sdb1 sdb2
 sdb1: <solaris: [s0] sdb5 [s1] sdb6 [s2] sdb7 [s7] sdb8 [s8] sdb9 >
sd 1:0:0:0: [sdb] Attached SCSI disk
ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata3.00: ATA-8: HITACHI H7220AA30SUN2.0T 1007MSWLEV, JKAOA28A, max UDMA/133
ata3.00: 3907029168 sectors, multi 0: LBA48 NCQ (depth 31/32), AA
ata3.00: configured for UDMA/133
scsi 2:0:0:0: Direct-Access     ATA      HITACHI H7220AA3 JKAO PQ: 0 ANSI: 5
sd 2:0:0:0: Attached scsi generic sg2 type 0
sd 2:0:0:0: [sdc] 3907029168 512-byte logical blocks: (2.00 TB/1.81 TiB)
sd 2:0:0:0: [sdc] Write Protect is off
sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sdc: detected capacity change from 0 to 2000398934016
 sdc: sdc1 sdc2
sd 2:0:0:0: [sdc] Attached SCSI disk
ata4: SATA link down (SStatus 0 SControl 300)
async/2 used greatest stack depth: 4968 bytes left
async/6 used greatest stack depth: 4936 bytes left
ata5: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata5.00: ATA-8: MARVELL SD88SA024SA0 SUN24G 1008M028TF, 1023D20R, max UDMA/133
ata5.00: 47999744 sectors, multi 0: LBA48 NCQ (depth 31/32)
ata5.00: configured for UDMA/133
scsi 4:0:0:0: Direct-Access     ATA      MARVELL SD88SA02 1023 PQ: 0 ANSI: 5
sd 4:0:0:0: Attached scsi generic sg3 type 0
sd 4:0:0:0: [sdd] 47999744 512-byte logical blocks: (24.5 GB/22.8 GiB)
sd 4:0:0:0: [sdd] Write Protect is off
sd 4:0:0:0: [sdd] Mode Sense: 00 3a 00 00
sd 4:0:0:0: [sdd] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
sdd: detected capacity change from 0 to 24575868928
 sdd: sdd1
 sdd1: <solaris: [s0] sdd5 [s1] sdd6 [s2] sdd7 [s8] sdd8 >
sd 4:0:0:0: [sdd] Attached SCSI disk
ata6: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata6.00: ATA-8: MARVELL SD88SA024SA0 SUN24G 1008M028RX, 1023D20R, max UDMA/133
ata6.00: 47999744 sectors, multi 0: LBA48 NCQ (depth 31/32)
ata6.00: configured for UDMA/133
scsi 5:0:0:0: Direct-Access     ATA      MARVELL SD88SA02 1023 PQ: 0 ANSI: 5
sd 5:0:0:0: [sde] 47999744 512-byte logical blocks: (24.5 GB/22.8 GiB)
sd 5:0:0:0: Attached scsi generic sg4 type 0
sd 5:0:0:0: [sde] Write Protect is off
sd 5:0:0:0: [sde] Mode Sense: 00 3a 00 00
sd 5:0:0:0: [sde] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
sde: detected capacity change from 0 to 24575868928
 sde: sde1
 sde1: <solaris: [s2] sde5 [s8] sde6 >
sd 5:0:0:0: [sde] Attached SCSI disk
insmod used greatest stack depth: 4688 bytes left
shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
type=1404 audit(1342149968.545:2): enforcing=1 old_enforcing=0 auid=4294967295 ses=4294967295
SELinux: 8192 avtab hash slots, 83426 rules.
SELinux: 8192 avtab hash slots, 83426 rules.
SELinux:  3 users, 6 roles, 2067 types, 278 bools, 1 sens, 1024 cats
SELinux:  61 classes, 83426 rules
SELinux:  class peer not defined in policy
SELinux:  class capability2 not defined in policy
SELinux:  class kernel_service not defined in policy
SELinux:  class tun_socket not defined in policy
SELinux:  permission open in class dir not defined in policy
SELinux:  permission open in class file not defined in policy
SELinux:  permission open in class chr_file not defined in policy
SELinux:  permission open in class blk_file not defined in policy
SELinux:  permission open in class sock_file not defined in policy
SELinux:  permission open in class fifo_file not defined in policy
SELinux:  permission recvfrom in class node not defined in policy
SELinux:  permission sendto in class node not defined in policy
SELinux:  permission ingress in class netif not defined in policy
SELinux:  permission egress in class netif not defined in policy
SELinux:  permission module_request in class system not defined in policy
SELinux:  permission setfcap in class capability not defined in policy
SELinux:  permission nlmsg_tty_audit in class netlink_audit_socket not defined in policy
SELinux:  permission forward_in in class packet not defined in policy
SELinux:  permission forward_out in class packet not defined in policy
SELinux: the above unknown classes and permissions will be allowed
SELinux:  Completing initialization.
SELinux:  Setting up existing superblocks.
SELinux: initialized (dev dm-0, type ext3), uses xattr
SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
SELinux: initialized (dev usbfs, type usbfs), uses genfs_contexts
SELinux: initialized (dev securityfs, type securityfs), not configured for labeling
SELinux: initialized (dev selinuxfs, type selinuxfs), uses genfs_contexts
SELinux: initialized (dev mqueue, type mqueue), uses transition SIDs
SELinux: initialized (dev hugetlbfs, type hugetlbfs), uses genfs_contexts
SELinux: initialized (dev devpts, type devpts), uses transition SIDs
SELinux: initialized (dev inotifyfs, type inotifyfs), uses genfs_contexts
SELinux: initialized (dev anon_inodefs, type anon_inodefs), uses genfs_contexts
SELinux: initialized (dev pipefs, type pipefs), uses task SIDs
SELinux: initialized (dev debugfs, type debugfs), uses genfs_contexts
SELinux: initialized (dev sockfs, type sockfs), uses task SIDs
SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
SELinux: initialized (dev proc, type proc), uses genfs_contexts
SELinux: initialized (dev bdev, type bdev), uses genfs_contexts
SELinux: initialized (dev rootfs, type rootfs), uses genfs_contexts
SELinux: initialized (dev sysfs, type sysfs), uses genfs_contexts
type=1403 audit(1342149968.872:3): policy loaded auid=4294967295 ses=4294967295
hostname used greatest stack depth: 4208 bytes left
mount used greatest stack depth: 3632 bytes left
sed used greatest stack depth: 3616 bytes left
dca service started, version 1.12.1
iTCO_vendor_support: vendor-support=0
iTCO_wdt: Intel TCO WatchDog Timer Driver v1.05
iTCO_wdt: failed to reset NO_REBOOT flag, reboot disabled by hardware
iTCO_wdt: No card detected
input: PC Speaker as /class/input/input5
i801_smbus 0000:00:1f.3: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ioatdma: Intel(R) QuickData Technology Driver 4.00
  alloc irq_desc for 43 on node -1
  alloc kstat_irqs on node -1
ioatdma 0000:00:16.0: PCI INT A -> GSI 43 (level, low) -> IRQ 43
ioatdma 0000:00:16.0: setting latency timer to 64
  alloc irq_desc for 54 on node -1
  alloc kstat_irqs on node -1
ioatdma 0000:00:16.0: irq 54 for MSI/MSI-X
  alloc irq_desc for 44 on node -1
  alloc kstat_irqs on node -1
ioatdma 0000:00:16.1: PCI INT B -> GSI 44 (level, low) -> IRQ 44
ioatdma 0000:00:16.1: setting latency timer to 64
  alloc irq_desc for 55 on node -1
  alloc kstat_irqs on node -1
ioatdma 0000:00:16.1: irq 55 for MSI/MSI-X
  alloc irq_desc for 45 on node -1
  alloc kstat_irqs on node -1
ioatdma 0000:00:16.2: PCI INT C -> GSI 45 (level, low) -> IRQ 45
ioatdma 0000:00:16.2: setting latency timer to 64
  alloc irq_desc for 56 on node -1
  alloc kstat_irqs on node -1
ioatdma 0000:00:16.2: irq 56 for MSI/MSI-X
  alloc irq_desc for 46 on node -1
  alloc kstat_irqs on node -1
ioatdma 0000:00:16.3: PCI INT D -> GSI 46 (level, low) -> IRQ 46
ioatdma 0000:00:16.3: setting latency timer to 64
  alloc irq_desc for 57 on node -1
  alloc kstat_irqs on node -1
ioatdma 0000:00:16.3: irq 57 for MSI/MSI-X
ioatdma 0000:00:16.4: PCI INT A -> GSI 43 (level, low) -> IRQ 43
ioatdma 0000:00:16.4: setting latency timer to 64
  alloc irq_desc for 58 on node -1
  alloc kstat_irqs on node -1
ioatdma 0000:00:16.4: irq 58 for MSI/MSI-X
ioatdma 0000:00:16.5: PCI INT B -> GSI 44 (level, low) -> IRQ 44
ioatdma 0000:00:16.5: setting latency timer to 64
  alloc irq_desc for 59 on node -1
  alloc kstat_irqs on node -1
ioatdma 0000:00:16.5: irq 59 for MSI/MSI-X
ioatdma 0000:00:16.6: PCI INT C -> GSI 45 (level, low) -> IRQ 45
ioatdma 0000:00:16.6: setting latency timer to 64
  alloc irq_desc for 60 on node -1
  alloc kstat_irqs on node -1
ioatdma 0000:00:16.6: irq 60 for MSI/MSI-X
ioatdma 0000:00:16.7: PCI INT D -> GSI 46 (level, low) -> IRQ 46
ioatdma 0000:00:16.7: setting latency timer to 64
  alloc irq_desc for 61 on node -1
  alloc kstat_irqs on node -1
ioatdma 0000:00:16.7: irq 61 for MSI/MSI-X
usb_id used greatest stack depth: 3504 bytes left
Intel(R) Gigabit Ethernet Network Driver - version 3.0.6-k
Copyright (c) 2007-2011 Intel Corporation.
  alloc irq_desc for 40 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.0: PCI INT B -> GSI 40 (level, low) -> IRQ 40
igb 0000:07:00.0: setting latency timer to 64
  alloc irq_desc for 62 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.0: irq 62 for MSI/MSI-X
  alloc irq_desc for 63 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.0: irq 63 for MSI/MSI-X
  alloc irq_desc for 64 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.0: irq 64 for MSI/MSI-X
  alloc irq_desc for 65 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.0: irq 65 for MSI/MSI-X
  alloc irq_desc for 66 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.0: irq 66 for MSI/MSI-X
  alloc irq_desc for 67 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.0: irq 67 for MSI/MSI-X
  alloc irq_desc for 68 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.0: irq 68 for MSI/MSI-X
  alloc irq_desc for 69 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.0: irq 69 for MSI/MSI-X
  alloc irq_desc for 70 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.0: irq 70 for MSI/MSI-X
igb 0000:07:00.0: DCA enabled
igb 0000:07:00.0: Intel(R) Gigabit Ethernet Network Connection
igb 0000:07:00.0: eth0: (PCIe:2.5Gb/s:Width x4) 00:21:28:75:7f:7e
igb 0000:07:00.0: eth0: PBA No: FFFFFF-0FF
igb 0000:07:00.0: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
  alloc irq_desc for 28 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.1: PCI INT A -> GSI 28 (level, low) -> IRQ 28
igb 0000:07:00.1: setting latency timer to 64
  alloc irq_desc for 71 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.1: irq 71 for MSI/MSI-X
  alloc irq_desc for 72 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.1: irq 72 for MSI/MSI-X
  alloc irq_desc for 73 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.1: irq 73 for MSI/MSI-X
  alloc irq_desc for 74 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.1: irq 74 for MSI/MSI-X
  alloc irq_desc for 75 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.1: irq 75 for MSI/MSI-X
  alloc irq_desc for 76 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.1: irq 76 for MSI/MSI-X
  alloc irq_desc for 77 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.1: irq 77 for MSI/MSI-X
  alloc irq_desc for 78 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.1: irq 78 for MSI/MSI-X
  alloc irq_desc for 79 on node -1
  alloc kstat_irqs on node -1
igb 0000:07:00.1: irq 79 for MSI/MSI-X
Error: Driver 'pcspkr' is already registered, aborting...
igb 0000:07:00.1: DCA enabled
igb 0000:07:00.1: Intel(R) Gigabit Ethernet Network Connection
igb 0000:07:00.1: eth1: (PCIe:2.5Gb/s:Width x4) 00:21:28:75:7f:7f
igb 0000:07:00.1: eth1: PBA No: FFFFFF-0FF
igb 0000:07:00.1: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
e1000e: Intel(R) PRO/1000 Network Driver - 1.4.4-k
e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
e1000e 0000:05:00.0: Disabling ASPM  L1
  alloc irq_desc for 38 on node -1
  alloc kstat_irqs on node -1
e1000e 0000:05:00.0: PCI INT B -> GSI 38 (level, low) -> IRQ 38
e1000e 0000:05:00.0: setting latency timer to 64
  alloc irq_desc for 80 on node -1
  alloc kstat_irqs on node -1
e1000e 0000:05:00.0: irq 80 for MSI/MSI-X
e1000e 0000:05:00.0: eth0: (PCI Express:2.5GT/s:Width x4) 00:15:17:b9:77:9d
e1000e 0000:05:00.0: eth0: Intel(R) PRO/1000 Network Connection
e1000e 0000:05:00.0: eth0: MAC: 0, PHY: 4, PBA No: D90197-004
e1000e 0000:05:00.1: Disabling ASPM  L1
  alloc irq_desc for 39 on node -1
  alloc kstat_irqs on node -1
e1000e 0000:05:00.1: PCI INT A -> GSI 39 (level, low) -> IRQ 39
e1000e 0000:05:00.1: setting latency timer to 64
  alloc irq_desc for 81 on node -1
  alloc kstat_irqs on node -1
e1000e 0000:05:00.1: irq 81 for MSI/MSI-X
e1000e 0000:05:00.1: eth1: (PCI Express:2.5GT/s:Width x4) 00:15:17:b9:77:9c
e1000e 0000:05:00.1: eth1: Intel(R) PRO/1000 Network Connection
e1000e 0000:05:00.1: eth1: MAC: 0, PHY: 4, PBA No: D90197-004
e1000e 0000:04:00.0: Disabling ASPM  L1
  alloc irq_desc for 37 on node -1
  alloc kstat_irqs on node -1
e1000e 0000:04:00.0: PCI INT B -> GSI 37 (level, low) -> IRQ 37
e1000e 0000:04:00.0: setting latency timer to 64
  alloc irq_desc for 82 on node -1
  alloc kstat_irqs on node -1
e1000e 0000:04:00.0: irq 82 for MSI/MSI-X
e1000e 0000:04:00.0: eth2: (PCI Express:2.5GT/s:Width x4) 00:15:17:b9:77:9f
e1000e 0000:04:00.0: eth2: Intel(R) PRO/1000 Network Connection
e1000e 0000:04:00.0: eth2: MAC: 0, PHY: 4, PBA No: D90197-004
e1000e 0000:04:00.1: Disabling ASPM  L1
  alloc irq_desc for 30 on node -1
  alloc kstat_irqs on node -1
e1000e 0000:04:00.1: PCI INT A -> GSI 30 (level, low) -> IRQ 30
e1000e 0000:04:00.1: setting latency timer to 64
  alloc irq_desc for 83 on node -1
  alloc kstat_irqs on node -1
e1000e 0000:04:00.1: irq 83 for MSI/MSI-X
e1000e 0000:04:00.1: eth3: (PCI Express:2.5GT/s:Width x4) 00:15:17:b9:77:9e
e1000e 0000:04:00.1: eth3: Intel(R) PRO/1000 Network Connection
e1000e 0000:04:00.1: eth3: MAC: 0, PHY: 4, PBA No: D90197-004
floppy0: no floppy controllers found
lp: driver loaded but no devices found
md: Autodetecting RAID arrays.
md: Scanned 0 and added 0 devices.
md: autorun ...
md: ... autorun DONE.
EXT3 FS on dm-0, internal journal
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdc1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
SELinux: initialized (dev sdc1, type ext3), uses xattr
SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
Adding 51511288k swap on /dev/VolGroup00/LogVol01.  Priority:-1 extents:1 across:51511288k 
SELinux: initialized (dev binfmt_misc, type binfmt_misc), uses genfs_contexts
rc.sysinit used greatest stack depth: 3344 bytes left
microcode: CPU0 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU1 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU2 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU3 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU4 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU5 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU6 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU7 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU8 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU9 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU10 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU11 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU12 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU13 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU14 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU15 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU16 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU17 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU18 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU19 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU20 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU21 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU22 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
microcode: CPU23 sig=0x206c2, pf=0x1, revision=0x13
platform microcode: firmware: requesting intel-ucode/06-2c-02
Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
Microcode Update Driver: v2.00 removed.
warning: process `kudzu' used the deprecated sysctl system call with 1.23.
Loading iSCSI transport class v2.0-870.
libcxgbi:libcxgbi_init_module: tag itt 0x1fff, 13 bits, age 0xf, 4 bits.
libcxgbi:ddp_setup_host_page_size: system PAGE 4096, ddp idx 0.
Chelsio T3 iSCSI Driver cxgb3i v2.0.0 (Jun. 2010)
iscsi: registered transport (cxgb3i)
NET: Registered protocol family 10
cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.7 (July 20, 2011)
Broadcom NetXtreme II iSCSI Driver bnx2i v2.7.0.3 (Jun 15, 2010)
iscsi: registered transport (bnx2i)
iscsi: registered transport (tcp)
iscsi: registered transport (iser)
iscsi: registered transport (be2iscsi)
ip6_tables: (C) 2000-2006 Netfilter Core Team
ip_tables: (C) 2000-2006 Netfilter Core Team
nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use
nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack module option or
sysctl net.netfilter.nf_conntrack_acct=1 to enable it.
warning: `mcstransd' uses 32-bit capabilities (legacy support in use)
e1000e 0000:05:00.0: irq 80 for MSI/MSI-X
e1000e 0000:05:00.0: irq 80 for MSI/MSI-X
ADDRCONF(NETDEV_UP): eth0: link is not ready
e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
e1000e 0000:05:00.1: irq 81 for MSI/MSI-X
e1000e 0000:05:00.1: irq 81 for MSI/MSI-X
ADDRCONF(NETDEV_UP): eth1: link is not ready
e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
e1000e 0000:04:00.0: irq 82 for MSI/MSI-X
e1000e 0000:04:00.0: irq 82 for MSI/MSI-X
ADDRCONF(NETDEV_UP): eth2: link is not ready
e1000e: eth2 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
ADDRCONF(NETDEV_CHANGE): eth2: link becomes ready
eth0: no IPv6 routers present
e1000e 0000:04:00.1: irq 83 for MSI/MSI-X
e1000e 0000:04:00.1: irq 83 for MSI/MSI-X
ADDRCONF(NETDEV_UP): eth3: link is not ready
e1000e: eth3 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
ADDRCONF(NETDEV_CHANGE): eth3: link becomes ready
eth1: no IPv6 routers present
ADDRCONF(NETDEV_UP): eth4: link is not ready
igb: eth4 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
ADDRCONF(NETDEV_CHANGE): eth4: link becomes ready
type=1400 audit(1342150012.444:4): avc:  denied  { sys_tty_config } for  pid=4595 comm="consoletype" capability=26  scontext=system_u:system_r:consoletype_t:s0 tcontext=system_u:system_r:consoletype_t:s0 tclass=capability
type=1400 audit(1342150012.506:5): avc:  denied  { sys_tty_config } for  pid=4623 comm="consoletype" capability=26  scontext=system_u:system_r:consoletype_t:s0 tcontext=system_u:system_r:consoletype_t:s0 tclass=capability
eth2: no IPv6 routers present
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
SELinux: initialized (dev rpc_pipefs, type rpc_pipefs), uses genfs_contexts
Bluetooth: Core ver 2.15
NET: Registered protocol family 31
Bluetooth: HCI device and connection manager initialized
Bluetooth: HCI socket layer initialized
Bluetooth: L2CAP ver 2.14
Bluetooth: L2CAP socket layer initialized
Bluetooth: RFCOMM TTY layer initialized
Bluetooth: RFCOMM socket layer initialized
Bluetooth: RFCOMM ver 1.11
eth3: no IPv6 routers present
Bluetooth: HIDP (Human Interface Emulation) ver 1.2
eth4: no IPv6 routers present
SELinux: initialized (dev autofs, type autofs), uses genfs_contexts
SELinux: initialized (dev autofs, type autofs), uses genfs_contexts
SELinux: initialized (dev autofs, type autofs), uses genfs_contexts

Thanks,
Joe

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
