From: Kasper Sandberg <lkml@metanurb.dk>
Subject: Re: Realtek 8111c weirdness problems, apic/msi, and normal bug
Date: Fri, 11 Apr 2008 20:06:56 +0200
Message-ID: <1207937216.1514.30.camel@localhost>
References: <1207407804.14885.27.camel@localhost>
	 <20080405232354.57ff2fac.akpm@linux-foundation.org>
	 <20080406140624.GA24479@electric-eye.fr.zoreil.com>
	 <1207541340.30698.18.camel@localhost>  <1207829872.1514.3.camel@localhost>
	 <1207876315.1514.21.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-BFVPshpMqGK3p7vtgHOY"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML Mailinglist <linux-kernel@vger.kernel.org>,
	linux-acpi@vger.kernel.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1207876315.1514.21.camel@localhost>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-BFVPshpMqGK3p7vtgHOY
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I've got more information again. This is dmesg, and /proc/interrupts
from a livecd (systemrescuecd), its a .23.14, and only 1 nic works (the
one that doesent work on .25 noapic/msi), the other gets detected as
fiber.. strangely enough, the link detection works on the working nic,
on .23.14.

attached are /proc/interrupts and dmesg..

oh, and this is a 64bit livecd kernel, but it appears to act the same on
the 32bit kernel on the livecd..

This, and the previous information i have given, does it give a clue as
to what may be happening here? from what i can see, it may be either
interrupts or that pci warning thingie...

it appears that on the livecd, which runs with both msi and apic, that
the ethernet controllers gets its interrupt setup with apic, whereas msi
likes to catch it on my own .25 kernel, allthough its abit weird what
happens..

If you need more information, just ask :)

On Fri, 2008-04-11 at 03:11 +0200, Kasper Sandberg wrote:
> Sorry for top posting, but its just easier in this case :)
> 
<snip>
> > 
> > 
> > > > 
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > Please read the FAQ at  http://www.tux.org/lkml/
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/

--=-BFVPshpMqGK3p7vtgHOY
Content-Disposition: attachment; filename=dmesg_64bit_weird
Content-Type: text/plain; name=dmesg_64bit_weird; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Linux version 2.6.23.14-fd12-amd64 (root@gentoo64) (gcc version 4.1.2 (Gentoo 4.1.2 p1.0.1)) #1 SMP Wed Jan 16 22:45:41 UTC 2008
Command line: initrd=rescue64.igz video=ofonly vga=0 cdroot BOOT_IMAGE=rescue64 
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009e800 (usable)
 BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000cfee0000 (usable)
 BIOS-e820: 00000000cfee0000 - 00000000cfee3000 (ACPI NVS)
 BIOS-e820: 00000000cfee3000 - 00000000cfef0000 (ACPI data)
 BIOS-e820: 00000000cfef0000 - 00000000cff00000 (reserved)
 BIOS-e820: 00000000e0000000 - 00000000e4000000 (reserved)
 BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000000130000000 (usable)
Entering add_active_range(0, 0, 158) 0 entries of 256 used
Entering add_active_range(0, 256, 851680) 1 entries of 256 used
Entering add_active_range(0, 1048576, 1245184) 2 entries of 256 used
end_pfn_map = 1245184
DMI 2.4 present.
ACPI: RSDP 000F6EB0, 0014 (r0 GBT   )
ACPI: RSDT CFEE3040, 0034 (r1 GBT    GBTUACPI 42302E31 GBTU  1010101)
ACPI: FACP CFEE30C0, 0074 (r1 GBT    GBTUACPI 42302E31 GBTU  1010101)
ACPI: DSDT CFEE3180, 4C2E (r1 GBT    GBTUACPI     1000 MSFT  100000C)
ACPI: FACS CFEE0000, 0040
ACPI: HPET CFEE7F00, 0038 (r1 GBT    GBTUACPI 42302E31 GBTU       98)
ACPI: MCFG CFEE7F80, 003C (r1 GBT    GBTUACPI 42302E31 GBTU  1010101)
ACPI: APIC CFEE7E00, 0084 (r1 GBT    GBTUACPI 42302E31 GBTU  1010101)
Entering add_active_range(0, 0, 158) 0 entries of 256 used
Entering add_active_range(0, 256, 851680) 1 entries of 256 used
Entering add_active_range(0, 1048576, 1245184) 2 entries of 256 used
Zone PFN ranges:
  DMA             0 ->     4096
  DMA32        4096 ->  1048576
  Normal    1048576 ->  1245184
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0:        0 ->      158
    0:      256 ->   851680
    0:  1048576 ->  1245184
On node 0 totalpages: 1048190
  DMA zone: 56 pages used for memmap
  DMA zone: 2501 pages reserved
  DMA zone: 1441 pages, LIFO batch:0
  DMA32 zone: 14280 pages used for memmap
  DMA32 zone: 833304 pages, LIFO batch:31
  Normal zone: 2688 pages used for memmap
  Normal zone: 193920 pages, LIFO batch:31
  Movable zone: 0 pages used for memmap
ACPI: PM-Timer IO Port: 0x408
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
Processor #0 (Bootup-CPU)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] disabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] disabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] disabled)
ACPI: LAPIC_NMI (acpi_id[0x00] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x03] dfl dfl lint[0x1])
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Setting APIC routing to flat
ACPI: HPET id: 0x8086a201 base: 0xfed00000
Using ACPI (MADT) for SMP configuration information
Allocating PCI resources starting at e6000000 (gap: e4000000:1ac00000)
SMP: Allowing 4 CPUs, 3 hotplug CPUs
PERCPU: Allocating 36568 bytes of per cpu data
Built 1 zonelists in Zone order.  Total pages: 1028665
Kernel command line: initrd=rescue64.igz video=ofonly vga=0 cdroot BOOT_IMAGE=rescue64 
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 32768 bytes)
hpet clockevent registered
TSC calibrated against HPET
time.c: Detected 1600.055 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
Checking aperture...
PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Placing software IO TLB between 0x58de000 - 0x98de000
Memory: 4040004k/4980736k available (5463k kernel code, 152444k reserved, 3293k data, 276k init)
SLUB: Genslabs=22, HWalign=64, Order=0-1, MinObjects=4, CPUs=4, Nodes=1
Calibrating delay using timer specific routine.. 3202.16 BogoMIPS (lpj=1601081)
Security Framework v1.0.0 initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
selinux_register_security:  Registering secondary module capability
Capability LSM initialized as secondary
Mount-cache hash table entries: 256
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 512K
using mwait in idle threads.
CPU0: Thermal monitoring enabled (TM2)
SMP alternatives: switching to UP code
ACPI: Core revision 20070126
Using local APIC timer interrupts.
APIC timer calibration result 12500427
Detected 12.500 MHz APIC timer.
Brought up 1 CPUs
sizeof(vma)=168 bytes
sizeof(page)=56 bytes
sizeof(inode)=560 bytes
sizeof(dentry)=208 bytes
sizeof(ext3inode)=760 bytes
sizeof(buffer_head)=104 bytes
sizeof(skbuff)=232 bytes
sizeof(task_struct)=2048 bytes
khelper used greatest stack depth: 6584 bytes left
khelper used greatest stack depth: 6528 bytes left
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: Using MMCONFIG at e0000000 - e3ffffff
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S3 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: Transparent bridge - 0000:00:1e.0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX3._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX4._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX5._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.HUB0._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 7 9 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 11 12 14 *15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs *3 4 5 6 7 9 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 5 6 7 9 10 11 12 *14 15)
ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 5 6 *7 9 10 11 12 14 15)
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 12 devices
ACPI: ACPI bus type pnp unregistered
Generic PHY: Registered new driver
SCSI subsystem initialized
libata version 2.21 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
NetLabel: Initializing
NetLabel:  domain hash size = 128
NetLabel:  protocols = UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
PCI-GART: No AMD northbridge found.
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
hpet0: 4 64-bit timers, 14318180 Hz
Time: tsc clocksource has been installed.
pnp: 00:08: ioport range 0x400-0x4bf has been reserved
pnp: 00:09: iomem range 0xe0000000-0xe3ffffff could not be reserved
pnp: 00:0a: iomem range 0xd1e00-0xd3fff has been reserved
pnp: 00:0a: iomem range 0xf0000-0xf7fff could not be reserved
pnp: 00:0a: iomem range 0xf8000-0xfbfff could not be reserved
pnp: 00:0a: iomem range 0xfc000-0xfffff could not be reserved
PCI: Bridge: 0000:00:01.0
  IO window: disabled.
  MEM window: e4000000-e6ffffff
  PREFETCH window: d0000000-dfffffff
PCI: Bridge: 0000:00:06.0
  IO window: 9000-9fff
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.0
  IO window: b000-bfff
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.3
  IO window: a000-afff
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.4
  IO window: c000-cfff
  MEM window: e7000000-e7ffffff
  PREFETCH window: e9000000-e90fffff
PCI: Bridge: 0000:00:1c.5
  IO window: d000-dfff
  MEM window: e8000000-e8ffffff
  PREFETCH window: e9100000-e91fffff
PCI: Bridge: 0000:00:1e.0
  IO window: disabled.
  MEM window: e9200000-e92fffff
  PREFETCH window: disabled.
ACPI: PCI Interrupt 0000:00:01.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:01.0 to 64
ACPI: PCI Interrupt 0000:00:06.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:06.0 to 64
ACPI: PCI Interrupt 0000:00:1c.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1c.0 to 64
ACPI: PCI Interrupt 0000:00:1c.3[D] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:1c.3 to 64
ACPI: PCI Interrupt 0000:00:1c.4[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1c.4 to 64
ACPI: PCI Interrupt 0000:00:1c.5[B] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:00:1c.5 to 64
PCI: Setting latency timer of device 0000:00:1e.0 to 64
NET: Registered protocol family 2
IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
TCP established hash table entries: 131072 (order: 9, 3145728 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
checking if image is initramfs... it is
Freeing initrd memory: 1870k freed
audit: initializing netlink socket (disabled)
audit(1207739006.467:1): initialized
Total HugeTLB memory allocated, 0
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
Loading Reiser4. See www.namesys.com for a description of Reiser4.
squashfs: version 3.2-r2 (2007/01/15) Phillip Lougher
squashfs: LZMA suppport for slax.org by jro
NTFS driver 2.1.28 [Flags: R/O].
fuse init (API version 7.8)
SELinux:  Registering netfilter hooks
ksign: Installing public key data
Loading keyring
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
Boot video device is 0000:01:00.0
PCI: Setting latency timer of device 0000:00:01.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:01.0:pcie00]
Allocate Port Service[0000:00:01.0:pcie03]
PCI: Setting latency timer of device 0000:00:06.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:06.0:pcie00]
Allocate Port Service[0000:00:06.0:pcie03]
PCI: Setting latency timer of device 0000:00:1c.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.0:pcie00]
Allocate Port Service[0000:00:1c.0:pcie02]
Allocate Port Service[0000:00:1c.0:pcie03]
PCI: Setting latency timer of device 0000:00:1c.3 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.3:pcie00]
Allocate Port Service[0000:00:1c.3:pcie02]
Allocate Port Service[0000:00:1c.3:pcie03]
PCI: Setting latency timer of device 0000:00:1c.4 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.4:pcie00]
Allocate Port Service[0000:00:1c.4:pcie02]
Allocate Port Service[0000:00:1c.4:pcie03]
PCI: Setting latency timer of device 0000:00:1c.5 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.5:pcie00]
Allocate Port Service[0000:00:1c.5:pcie02]
Allocate Port Service[0000:00:1c.5:pcie03]
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
ACPI: Processor [CPU0] (supports 8 throttling states)
ACPI Exception (processor_core-0819): AE_NOT_FOUND, Processor Device is not present [20070126]
ACPI Exception (processor_core-0819): AE_NOT_FOUND, Processor Device is not present [20070126]
ACPI Exception (processor_core-0819): AE_NOT_FOUND, Processor Device is not present [20070126]
Real Time Clock Driver v1.12ac
hpet_resources: 0xfed00000 is busy
Non-volatile memory driver v1.2
Linux agpgart interface v0.102
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
RAMDISK driver initialized: 16 RAM disks of 16384K size 4096 blocksize
loop: module loaded
Intel(R) PRO/1000 Network Driver - version 7.3.20-k2-NAPI
Copyright (c) 1999-2006 Intel Corporation.
Intel(R) PRO/1000 Network Driver - 0.2.0
Copyright (c) 1999-2007 Intel Corporation.
Intel(R) PRO/10GbE Network Driver - version 1.0.126-k2-NAPI
Copyright (c) 1999-2006 Intel Corporation.
pcnet32.c:v1.33-NAPI 27.Jun.2006 tsbogend@alpha.franken.de
e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
ns83820.c: National Semiconductor DP83820 10/100/1000 driver.
Marvell 88E1101: Registered new driver
Marvell 88E1112: Registered new driver
Marvell 88E1111: Registered new driver
Marvell 88E1145: Registered new driver
Davicom DM9161E: Registered new driver
Davicom DM9161A: Registered new driver
Davicom DM9131: Registered new driver
Cicada Cis8204: Registered new driver
Cicada Cis8201: Registered new driver
LXT970: Registered new driver
LXT971: Registered new driver
QS6612: Registered new driver
SMSC LAN83C185: Registered new driver
Vitesse VSC8244: Registered new driver
Switched to high resolution mode on CPU 0
Broadcom BCM5411: Registered new driver
Broadcom BCM5421: Registered new driver
Broadcom BCM5461: Registered new driver
forcedeth.c: Reverse Engineered nForce ethernet driver. Version 0.60.
Silan SC92031 PCI Fast Ethernet Adapter driver 2.0c
r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
ACPI: PCI Interrupt 0000:05:00.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:05:00.0 to 64
eth0: RTL8168b/8111b at 0xffffc20000022000, 00:1d:7d:06:7b:39, XID 3c2000c0 IRQ 16
r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
ACPI: PCI Interrupt 0000:06:00.0[A] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:06:00.0 to 64
eth1: RTL8168b/8111b at 0xffffc20000024000, 00:1d:7d:06:75:d8, XID 3c2000c0 IRQ 17
myri10ge: Version 1.3.2-1.269
dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
winbond-840.c:v1.01-e (2.4 port) Sep-11-2006  Donald Becker <becker@scyld.com>
  http://www.scyld.com/network/drivers.html
uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-29)
input: Macintosh mouse button emulation as /class/input/input0
Loading iSCSI transport class v2.0-724.
Adaptec aacraid driver 1.1-5[2449]-ms
aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
scsi: <fdomain> Detection failed (no card)
QLogic Fibre Channel HBA Driver
iscsi: registered transport (qla4xxx)
QLogic iSCSI HBA Driver
Emulex LightPulse Fibre Channel SCSI driver 8.2.2
Copyright(c) 2004-2007 Emulex.  All rights reserved.
DC390: clustering now enabled by default. If you get problems load
	with "disable_clustering=1" and report to maintainers
megasas: 00.00.03.10-rc5 Thu May 17 10:09:32 PDT 2007
GDT-HA: Storage RAID Controller Driver. Version: 3.05
GDT-HA: Found 0 PCI Storage RAID Controllers
3ware Storage Controller device driver for Linux v1.26.02.002.
3ware 9000 Storage Controller device driver for Linux v2.26.02.010.
RocketRAID 3xxx SATA Controller driver v1.0 (060426)
stex: Promise SuperTrak EX Driver version: 3.6.0000.1
ahci 0000:00:1f.2: version 2.3
ACPI: PCI Interrupt 0000:00:1f.2[B] -> GSI 19 (level, low) -> IRQ 19
ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 6 ports 3 Gbps 0x3f impl SATA mode
ahci 0000:00:1f.2: flags: 64bit ncq sntf stag pm led clo pmp pio slum part 
PCI: Setting latency timer of device 0000:00:1f.2 to 64
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
scsi4 : ahci
scsi5 : ahci
ata1: SATA max UDMA/133 cmd 0xffffc20000026100 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 1273
ata2: SATA max UDMA/133 cmd 0xffffc20000026180 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 1273
ata3: SATA max UDMA/133 cmd 0xffffc20000026200 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 1273
ata4: SATA max UDMA/133 cmd 0xffffc20000026280 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 1273
ata5: SATA max UDMA/133 cmd 0xffffc20000026300 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 1273
ata6: SATA max UDMA/133 cmd 0xffffc20000026380 ctl 0x0000000000000000 bmdma 0x0000000000000000 irq 1273
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: ATA-6: ST3500320NS, SN04, max UDMA/133
ata1.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata1.00: configured for UDMA/133
ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata2.00: ATA-6: ST3500320NS, SN04, max UDMA/133
ata2.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata2.00: configured for UDMA/133
ata3: SATA link down (SStatus 0 SControl 300)
ata4: SATA link down (SStatus 0 SControl 300)
ata5: SATA link down (SStatus 0 SControl 300)
ata6: SATA link down (SStatus 0 SControl 300)
scsi 0:0:0:0: Direct-Access     ATA      ST3500320NS      SN04 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors (500108 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors (500108 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2 sda3
sd 0:0:0:0: [sda] Attached SCSI disk
sd 0:0:0:0: Attached scsi generic sg0 type 0
scsi 1:0:0:0: Direct-Access     ATA      ST3500320NS      SN04 PQ: 0 ANSI: 5
sd 1:0:0:0: [sdb] 976773168 512-byte hardware sectors (500108 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 1:0:0:0: [sdb] 976773168 512-byte hardware sectors (500108 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdb: sdb1 sdb2 sdb3
sd 1:0:0:0: [sdb] Attached SCSI disk
sd 1:0:0:0: Attached scsi generic sg1 type 0
Fusion MPT base driver 3.04.05
Copyright (c) 1999-2007 LSI Logic Corporation
Fusion MPT SPI Host driver 3.04.05
Fusion MPT FC Host driver 3.04.05
Fusion MPT SAS Host driver 3.04.05
Fusion MPT misc device (ioctl) driver 3.04.05
mptctl: Registered with Fusion MPT base driver
mptctl: /dev/mptctl @ (major,minor=10,220)
Fusion MPT LAN driver 3.04.05
ACPI: PCI Interrupt 0000:00:1a.7[C] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1a.7 to 64
ehci_hcd 0000:00:1a.7: EHCI Host Controller
ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
PCI: cache line size of 32 is not supported by device 0000:00:1a.7
ehci_hcd 0000:00:1a.7: irq 18, io mem 0xe9305000
ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
ACPI: PCI Interrupt 0000:00:1d.7[A] -> GSI 23 (level, low) -> IRQ 23
PCI: Setting latency timer of device 0000:00:1d.7 to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
PCI: cache line size of 32 is not supported by device 0000:00:1d.7
ehci_hcd 0000:00:1d.7: irq 23, io mem 0xe9304000
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 6 ports detected
116x: driver isp116x-hcd, 03 Nov 2005
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
USB Universal Host Controller Interface driver v3.0
ACPI: PCI Interrupt 0000:00:1a.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1a.0 to 64
uhci_hcd 0000:00:1a.0: UHCI Host Controller
uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1a.0: irq 16, io base 0x0000e100
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
usb 1-1: new high speed USB device using ehci_hcd and address 2
ACPI: PCI Interrupt 0000:00:1a.1[B] -> GSI 21 (level, low) -> IRQ 21
PCI: Setting latency timer of device 0000:00:1a.1 to 64
uhci_hcd 0000:00:1a.1: UHCI Host Controller
uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1a.1: irq 21, io base 0x0000e200
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
usb 1-1: configuration #1 chosen from 1 choice
ACPI: PCI Interrupt 0000:00:1a.2[C] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1a.2 to 64
uhci_hcd 0000:00:1a.2: UHCI Host Controller
uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1a.2: irq 18, io base 0x0000e000
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 23 (level, low) -> IRQ 23
PCI: Setting latency timer of device 0000:00:1d.0 to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000e300
usb usb6: configuration #1 chosen from 1 choice
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:1d.1 to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000e400
usb usb7: configuration #1 chosen from 1 choice
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1d.2 to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000e500
usb usb8: configuration #1 chosen from 1 choice
hub 8-0:1.0: USB hub found
hub 8-0:1.0: 2 ports detected
sl811: driver sl811-hcd, 19 May 2005
Initializing USB Mass Storage driver...
scsi6 : SCSI emulation for USB Mass Storage devices
usb-storage: device found at 2
usb-storage: waiting for device to settle before scanning
usb 8-2: new low speed USB device using uhci_hcd and address 2
usb 8-2: configuration #1 chosen from 1 choice
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
PNP: PS/2 Controller [PNP0f13:PS2M] at 0x60,0x64 irq 12
PNP: PS/2 controller doesn't have KBD irq; using default 1
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
usbcore: registered new interface driver hiddev
input: Logitech Logitech USB Keyboard as /class/input/input1
input: USB HID v1.10 Keyboard [Logitech Logitech USB Keyboard] on usb-0000:00:1d.2-2
input: Logitech Logitech USB Keyboard as /class/input/input2
input: USB HID v1.10 Mouse [Logitech Logitech USB Keyboard] on usb-0000:00:1d.2-2
usbcore: registered new interface driver usbhid
drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 1
NET: Registered protocol family 17
Freeing unused kernel memory: 276k freed
Write protecting the kernel read-only data: 2192k
mount used greatest stack depth: 6448 bytes left
mount used greatest stack depth: 6016 bytes left
ata1: soft resetting port
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: configured for UDMA/133
ata1: EH complete
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors (500108 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
input: ImPS/2 Generic Wheel Mouse as /class/input/input3
device-mapper: ioctl: 4.11.0-ioctl (2006-10-12) initialised: dm-devel@redhat.com
JFS: nTxBlock = 8192, nTxLock = 65536
SGI XFS with ACLs, security attributes, large block/inode numbers, no debug enabled
SGI XFS Quota Management subsystem
mount used greatest stack depth: 5896 bytes left
mount used greatest stack depth: 5880 bytes left
UDF-fs: No VRS found
mount used greatest stack depth: 4160 bytes left
UDF-fs: No VRS found
XFS mounting filesystem sda1
Ending clean XFS mount for filesystem: sda1
UDF-fs: No VRS found
XFS mounting filesystem sda2
Ending clean XFS mount for filesystem: sda2
usb-storage: device scan complete
scsi 6:0:0:0: CD-ROM            ATAPI    DVD A  DH20A4P   9P54 PQ: 0 ANSI: 0
sr0: scsi3-mmc drive: 16x/48x writer dvd-ram cd/rw xa/form2 cdda tray
Uniform CD-ROM driver Revision: 3.20
sr 6:0:0:0: Attached scsi CD-ROM sr0
sr 6:0:0:0: Attached scsi generic sg2 type 5
attempt to access beyond end of device
sda3: rw=0, want=18446744073705357316, limit=927448515
UDF-fs: No VRS found
UDF-fs: No VRS found
UDF-fs: No VRS found
XFS mounting filesystem sdb1
Ending clean XFS mount for filesystem: sdb1
UDF-fs: No VRS found
XFS mounting filesystem sdb2
Ending clean XFS mount for filesystem: sdb2
attempt to access beyond end of device
sdb3: rw=0, want=18446744073705357316, limit=927448515
UDF-fs: No VRS found
ISO 9660 Extensions: Microsoft Joliet Level 3
ISO 9660 Extensions: RRIP_1991A
input: Power Button (FF) as /class/input/input4
ACPI: Power Button (FF) [PWRF]
input: Power Button (CM) as /class/input/input5
ACPI: Power Button (CM) [PWRB]
iTCO_vendor_support: vendor-support=0
iTCO_wdt: Intel TCO WatchDog Timer Driver v1.02 (26-Jul-2007)
iTCO_wdt: failed to reset NO_REBOOT flag, reboot disabled by hardware
iTCO_wdt: No card detected
ACPI: PCI Interrupt 0000:00:1f.3[C] -> GSI 18 (level, low) -> IRQ 18
input: PC Speaker as /class/input/input6
ACPI: PCI Interrupt 0000:07:06.0[A] -> GSI 18 (level, low) -> IRQ 18
firewire_ohci: Added fw-ohci device 0000:07:06.0, OHCI version 1.10
firewire_core: created new fw device fw0 (0 config rom retries, S400)
nvidia: module license 'NVIDIA' taints kernel.
ACPI: PCI Interrupt 0000:01:00.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:01:00.0 to 64
NVRM: loading NVIDIA UNIX x86_64 Kernel Module  100.14.19  Wed Sep 12 14:08:38 PDT 2007
r8169: eth1: link down
r8169: eth0: link down
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
NFSD: starting 90-second grace period
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
ADDRCONF(NETDEV_UP): eth0: link is not ready
ADDRCONF(NETDEV_UP): eth1: link is not ready
r8169: eth1: link up
ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
eth1: no IPv6 routers present
r8169: eth1: link down
r8169: eth1: link up
r8169: eth0: link down
r8169: eth0: link down
ADDRCONF(NETDEV_UP): eth0: link is not ready

--=-BFVPshpMqGK3p7vtgHOY
Content-Disposition: attachment; filename=ints
Content-Type: text/plain; name=ints; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

           CPU0       
  0:        167   IO-APIC-edge      timer
  1:          2   IO-APIC-edge      i8042
  8:         29   IO-APIC-edge      rtc
  9:          0   IO-APIC-fasteoi   acpi
 12:        113   IO-APIC-edge      i8042
 16:          0   IO-APIC-fasteoi   uhci_hcd:usb3
 17:          9   IO-APIC-fasteoi   eth1
 18:       6341   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8, firewire_ohci
 19:          0   IO-APIC-fasteoi   uhci_hcd:usb7
 21:          0   IO-APIC-fasteoi   uhci_hcd:usb4
 23:          2   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
1273:    2099045   PCI-MSI-edge      ahci
NMI:          0 
LOC:      68257 
ERR:          0

--=-BFVPshpMqGK3p7vtgHOY
Content-Disposition: attachment; filename=ints2
Content-Type: text/plain; name=ints2; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

           CPU0       
  0:        167   IO-APIC-edge      timer
  1:          2   IO-APIC-edge      i8042
  8:         29   IO-APIC-edge      rtc
  9:          0   IO-APIC-fasteoi   acpi
 12:        113   IO-APIC-edge      i8042
 16:          1   IO-APIC-fasteoi   uhci_hcd:usb3, eth0
 17:          9   IO-APIC-fasteoi   eth1
 18:       6383   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8, firewire_ohci
 19:          0   IO-APIC-fasteoi   uhci_hcd:usb7
 21:          0   IO-APIC-fasteoi   uhci_hcd:usb4
 23:          2   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
1273:    2099045   PCI-MSI-edge      ahci
NMI:          0 
LOC:      68322 
ERR:          0

--=-BFVPshpMqGK3p7vtgHOY--

