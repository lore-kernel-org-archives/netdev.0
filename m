From: "Christiaan den Besten" <chris@scorpion.nl>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Thu, 30 Mar 2006 10:08:46 +0200
Message-ID: <006d01c653d1$2b4b1910$3d64880a@speedy>
References: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408>
Reply-To: "Christiaan den Besten" <chris@scorpion.nl>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"Jesse Brandeburg" <jesse.brandeburg@gmail.com>,
	<davem@davemloft.net>, <E1000-devel@lists.sourceforge.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	<nipsy@bitgnome.net>, <jrlundgren@gmail.com>, <cat@zip.com.au>,
	<djani22@dynamicweb.hu>, <yoseph.basri@gmail.com>,
	<bb@kernelpanic.ru>, <mykleb@no.ibm.com>, <olel@ans.pl>,
	<michal@feix.cz>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

Hi !

Yes, we still have these errors ... but then, we have not changed the running kernel version for some time now ;)

---
Linux version 2.6.14-rc2-mm2 (root@localhost) (gcc version 3.4.4 20050721 (Red Hat 3.4.4-2)) #2 SMP Thu Dec 15 19:06:21 CET 2005
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009b800 (usable)
 BIOS-e820: 000000000009b800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000cff70000 (usable)
 BIOS-e820: 00000000cff70000 - 00000000cff78000 (ACPI data)
 BIOS-e820: 00000000cff78000 - 00000000cff80000 (ACPI NVS)
 BIOS-e820: 00000000cff80000 - 00000000d0000000 (reserved)
 BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 00000000fec10000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000ff800000 - 00000000ffc00000 (reserved)
 BIOS-e820: 00000000fffffc00 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000000130000000 (usable)
3968MB HIGHMEM available.
896MB LOWMEM available.
found SMP MP-table at 000f6820
NX (Execute Disable) protection: active
On node 0 totalpages: 1245184
  DMA zone: 4096 pages, LIFO batch:2
  DMA32 zone: 0 pages, LIFO batch:2
  Normal zone: 225280 pages, LIFO batch:64
  HighMem zone: 1015808 pages, LIFO batch:64
DMI present.
ACPI: RSDP (v000 PTLTD                                 ) @ 0x000f6880
ACPI: RSDT (v001 PTLTD    RSDT   0x06040000  LTP 0x00000000) @ 0xcff72d76
ACPI: FADT (v001 INTEL  LINDHRST 0x06040000 PTL  0x00000003) @ 0xcff77e20
ACPI: MADT (v001 PTLTD           APIC   0x06040000  LTP 0x00000000) @ 0xcff77e94
ACPI: BOOT (v001 PTLTD  $SBFTBL$ 0x06040000  LTP 0x00000001) @ 0xcff77f48
ACPI: SPCR (v001 PTLTD  $UCRTBL$ 0x06040000 PTL  0x00000001) @ 0xcff77f70
ACPI: MCFG (v001 PTLTD           MCFG   0x06040000  LTP 0x00000000) @ 0xcff77fc0
ACPI: SSDT (v001  PmRef    CpuPm 0x00003000 INTL 0x20030224) @ 0xcff72db2
ACPI: DSDT (v001  Intel LINDHRST 0x06040000 MSFT 0x0100000e) @ 0x00000000
ACPI: PM-Timer IO Port: 0x1008
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
Processor #0 15:4 APIC version 20
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x06] enabled)
Processor #6 15:4 APIC version 20
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
Processor #1 15:4 APIC version 20
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x07] enabled)
Processor #7 15:4 APIC version 20
ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
ACPI: IOAPIC (id[0x03] address[0xfec80000] gsi_base[24])
IOAPIC[1]: apic_id 3, version 32, address 0xfec80000, GSI 24-47
ACPI: IOAPIC (id[0x04] address[0xfec80400] gsi_base[48])
IOAPIC[2]: apic_id 4, version 32, address 0xfec80400, GSI 48-71
ACPI: IOAPIC (id[0x05] address[0xfec84000] gsi_base[72])
IOAPIC[3]: apic_id 5, version 32, address 0xfec84000, GSI 72-95
ACPI: IOAPIC (id[0x08] address[0xfec84400] gsi_base[96])
IOAPIC[4]: apic_id 8, version 32, address 0xfec84400, GSI 96-119
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 high edge)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Enabling APIC mode:  Flat.  Using 5 I/O APICs
Using ACPI (MADT) for SMP configuration information
Allocating PCI resources starting at d1000000 (gap: d0000000:10000000)
Built 1 zonelists
mapped APIC to ffffd000 (fee00000)
mapped IOAPIC to ffffc000 (fec00000)
mapped IOAPIC to ffffb000 (fec80000)
mapped IOAPIC to ffffa000 (fec80400)
mapped IOAPIC to ffff9000 (fec84000)
mapped IOAPIC to ffff8000 (fec84400)
Initializing CPU#0
Kernel command line: ro root=LABEL=/
PID hash table entries: 4096 (order: 12, 65536 bytes)
Detected 2801.358 MHz processor.
Using pmtmr for high-res timesource
Console: colour VGA+ 80x25
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 4146392k/4980736k available (2757k kernel code, 45216k reserved, 783k data, 216k init, 3276224k highmem)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay using timer specific routine.. 5603.74 BogoMIPS (lpj=2801871)
Mount-cache hash table entries: 512
CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 0000641d 00000000 00000000
CPU: After vendor identify, caps: bfebfbff 20100000 00000000 00000000 0000641d 00000000 00000000
monitor/mwait feature present.
using mwait in idle threads.
CPU: Trace cache: 12K uops, L1 D cache: 16K
CPU: L2 cache: 1024K
CPU: Physical Processor ID: 0
CPU: After all inits, caps: bfebfbff 20100000 00000000 00000080 0000641d 00000000 00000000
mtrr: v2.0 (20020519)
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Checking 'hlt' instruction... OK.
CPU0: Intel(R) Xeon(TM) CPU 2.80GHz stepping 01
Booting processor 1/1 eip 2000
Initializing CPU#1
Calibrating delay using timer specific routine.. 5599.54 BogoMIPS (lpj=2799774)
CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 0000641d 00000000 00000000
CPU: After vendor identify, caps: bfebfbff 20100000 00000000 00000000 0000641d 00000000 00000000
monitor/mwait feature present.
CPU: Trace cache: 12K uops, L1 D cache: 16K
CPU: L2 cache: 1024K
CPU: Physical Processor ID: 0
CPU: After all inits, caps: bfebfbff 20100000 00000000 00000080 0000641d 00000000 00000000
CPU1: Intel(R) Xeon(TM) CPU 2.80GHz stepping 01
Booting processor 2/6 eip 2000
Initializing CPU#2
Calibrating delay using timer specific routine.. 5571.21 BogoMIPS (lpj=2785607)
CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 0000641d 00000000 00000000
CPU: After vendor identify, caps: bfebfbff 20100000 00000000 00000000 0000641d 00000000 00000000
monitor/mwait feature present.
CPU: Trace cache: 12K uops, L1 D cache: 16K
CPU: L2 cache: 1024K
CPU: Physical Processor ID: 3
CPU: After all inits, caps: bfebfbff 20100000 00000000 00000080 0000641d 00000000 00000000
CPU2: Intel(R) Xeon(TM) CPU 2.80GHz stepping 01
Booting processor 3/7 eip 2000
Initializing CPU#3
Calibrating delay using timer specific routine.. 5599.55 BogoMIPS (lpj=2799778)
CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 0000641d 00000000 00000000
CPU: After vendor identify, caps: bfebfbff 20100000 00000000 00000000 0000641d 00000000 00000000
monitor/mwait feature present.
CPU: Trace cache: 12K uops, L1 D cache: 16K
CPU: L2 cache: 1024K
CPU: Physical Processor ID: 3
CPU: After all inits, caps: bfebfbff 20100000 00000000 00000080 0000641d 00000000 00000000
CPU3: Intel(R) Xeon(TM) CPU 2.80GHz stepping 01
Total of 4 processors activated (22374.06 BogoMIPS).
ENABLING IO-APIC IRQs
..TIMER: vector=0x31 pin1=2 pin2=-1
checking TSC synchronization across 4 CPUs: passed.
Brought up 4 CPUs
checking if image is initramfs... it is
Freeing initrd memory: 296k freed
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: PCI BIOS revision 2.10 entry at 0xfd830, last bus=9
PCI: Using MMCONFIG
usbcore: registered new driver usbfs
usbcore: registered new driver hub
ACPI: Subsystem revision 20050916
ACPI: Interpreter enabled
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: Probing PCI hardware (bus 00)
PCI: Ignoring BAR0-3 of IDE controller 0000:00:1f.1
PCI: PXH quirk detected, disabling MSI for SHPC device
PCI: PXH quirk detected, disabling MSI for SHPC device
PCI: PXH quirk detected, disabling MSI for SHPC device
PCI: PXH quirk detected, disabling MSI for SHPC device
Boot video device is 0000:09:01.0
PCI: Transparent bridge - 0000:00:1e.0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0.PXH0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0.PXH1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEY0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEZ0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEZ0.PXH0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEZ0.PXH1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCIB._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 *5 6 7 10 11 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 *10 11 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 *7 10 11 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 10 *11 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 4 5 6 7 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKH] (IRQs 4 5 6 7 *10 11 14 15)
ACPI: Device [PRT] status [0000000c]: functional but not present; setting present
SCSI subsystem initialized
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
PCI: Bridge: 0000:01:00.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:01:00.2
  IO window: 2000-2fff
  MEM window: dd200000-dd2fffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:02.0
  IO window: 2000-2fff
  MEM window: dd100000-dd2fffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:04.0
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:06:01.0
  IO window: disabled.
  MEM window: dd400000-dd4fffff
  PREFETCH window: d1000000-d10fffff
PCI: Bridge: 0000:05:00.0
  IO window: disabled.
  MEM window: dd400000-dd4fffff
  PREFETCH window: d1000000-d10fffff
PCI: Bridge: 0000:05:00.2
  IO window: disabled.
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:06.0
  IO window: disabled.
  MEM window: dd300000-dd4fffff
  PREFETCH window: d1000000-d10fffff
PCI: Bridge: 0000:00:1e.0
  IO window: 3000-3fff
  MEM window: dd500000-deffffff
  PREFETCH window: d1100000-d11fffff
ACPI: PCI Interrupt 0000:00:02.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:02.0 to 64
PCI: Setting latency timer of device 0000:01:00.0 to 64
PCI: Setting latency timer of device 0000:01:00.2 to 64
ACPI: PCI Interrupt 0000:00:04.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:04.0 to 64
ACPI: PCI Interrupt 0000:00:06.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:06.0 to 64
PCI: Setting latency timer of device 0000:05:00.0 to 64
PCI: Setting latency timer of device 0000:05:00.2 to 64
PCI: Setting latency timer of device 0000:00:1e.0 to 64
Simple Boot Flag at 0x39 set to 0x1
highmem bounce pool size: 64 pages
Total HugeTLB memory allocated, 0
SGI XFS with large block numbers, no debug enabled
Initializing Cryptographic API
ACPI: PCI Interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:00:1d.7 to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: debug port 1
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1d.7: irq 17, io mem 0xdd001000
PCI: cache line size of 128 is not supported by device 0000:00:1d.7
ehci_hcd 0000:00:1d.7: USB 2.0 initialized, EHCI 1.00, driver 10 Dec 2004
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 8 ports detected
usbcore: registered new driver hiddev
usbcore: registered new driver usbhid
drivers/usb/input/hid-core.c: v2.6:USB HID core driver
usbcore: registered new driver usbserial
drivers/usb/serial/usb-serial.c: USB Serial support registered for Generic
usbcore: registered new driver usbserial_generic
drivers/usb/serial/usb-serial.c: USB Serial Driver core v2.0
ACPI: Power Button (FF) [PWRF]
ACPI: Power Button (CM) [PWRB]
ACPI: CPU0 (power states: C1[C1])
ACPI: CPU2 (power states: C1[C1])
ACPI: CPU1 (power states: C1[C1])
ACPI: CPU3 (power states: C1[C1])
Real Time Clock Driver v1.12
serio: i8042 AUX port at 0x60,0x64 irq 12
serio: i8042 KBD port at 0x60,0x64 irq 1
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
mice: PS/2 mouse device common for all mice
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered
Floppy drive(s): fd0 is 1.44M
FDC 0 is a National Semiconductor PC87306
RAMDISK driver initialized: 16 RAM disks of 16384K size 1024 blocksize
loop: loaded (max 8 devices)
Intel(R) PRO/1000 Network Driver - version 6.0.60-k2
Copyright (c) 1999-2005 Intel Corporation.
ACPI: PCI Interrupt 0000:03:02.0[A] -> GSI 54 (level, low) -> IRQ 18
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
ACPI: PCI Interrupt 0000:03:02.1[B] -> GSI 55 (level, low) -> IRQ 19
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
ICH5: IDE controller at PCI slot 0000:00:1f.1
ACPI: PCI Interrupt 0000:00:1f.1[A] -> GSI 18 (level, low) -> IRQ 20
ICH5: chipset revision 2
ICH5: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0x14a0-0x14a7, BIOS settings: hda:DMA, hdb:pio
    ide1: BM-DMA at 0x14a8-0x14af, BIOS settings: hdc:pio, hdd:pio
Probing IDE interface ide0...
hda: SR244W, ATAPI CD/DVD-ROM drive
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Probing IDE interface ide1...
Probing IDE interface ide1...
hda: ATAPI 24X CD-ROM drive, 128kB Cache, UDMA(33)
Uniform CD-ROM driver Revision: 3.20
ACPI: PCI Interrupt 0000:07:0e.0[A] -> GSI 74 (level, low) -> IRQ 21
ARECA RAID ADAPTER0: 64BITS PCI BUS DMA ADDRESSING SUPPORTED
ARECA RAID ADAPTER0: FIRMWARE VERSION V1.38 2005-10-4
scsi0 : ARECA ARC1160 PCI-X 16 PORTS SATA RAID CONTROLLER (RAID6-ENGINE Inside)
        Driver Version 1.20.00.12
  Vendor: Areca     Model: ARC-1160-VOL#00   Rev: R001
  Type:   Direct-Access                      ANSI SCSI revision: 03
  Vendor: Areca     Model: DATA1             Rev: R001
  Type:   Direct-Access                      ANSI SCSI revision: 03
  Vendor: Areca     Model: DATA2             Rev: R001
  Type:   Direct-Access                      ANSI SCSI revision: 03
arcmsr device major number 254
libata version 1.12 loaded.
SCSI device sda: 312499712 512-byte hdwr sectors (160000 MB)
SCSI device sda: drive cache: write back
SCSI device sda: 312499712 512-byte hdwr sectors (160000 MB)
SCSI device sda: drive cache: write back
 sda: sda1 sda2 sda3 sda4 < sda5 sda6 >
Attached scsi disk sda at scsi0, channel 0, id 0, lun 0
SCSI device sdb: 820310016 512-byte hdwr sectors (419999 MB)
SCSI device sdb: drive cache: write back
SCSI device sdb: 820310016 512-byte hdwr sectors (419999 MB)
SCSI device sdb: drive cache: write back
 sdb: sdb1
Attached scsi disk sdb at scsi0, channel 0, id 1, lun 0
SCSI device sdc: 820310016 512-byte hdwr sectors (419999 MB)
SCSI device sdc: drive cache: write back
SCSI device sdc: 820310016 512-byte hdwr sectors (419999 MB)
SCSI device sdc: drive cache: write back
 sdc: sdc1
Attached scsi disk sdc at scsi0, channel 0, id 2, lun 0
md: md driver 0.90.2 MAX_MD_DEVS=256, MD_SB_DISKS=27
md: bitmap version 3.39
device-mapper: 4.4.0-ioctl (2005-01-12) initialised: dm-devel@redhat.com
NET: Registered protocol family 2
IP route cache hash table entries: 262144 (order: 8, 1048576 bytes)
TCP established hash table entries: 524288 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
TCP: Hash tables configured (established 524288 bind 65536)
TCP reno registered
ip_conntrack version 2.3 (8192 buckets, 65536 max) - 172 bytes per conntrack
ip_tables: (C) 2000-2002 Netfilter core team
TCP bic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
NET: Registered protocol family 15
802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
All bugs added by David S. Miller <davem@redhat.com>
Starting balanced_irq
Using IPI Shortcut mode
Freeing unused kernel memory: 216k freed
EXT3-fs: INFO: recovery required on readonly filesystem.
EXT3-fs: write access will be enabled during recovery.
kjournald starting.  Commit interval 5 seconds
EXT3-fs: recovery complete.
EXT3-fs: mounted filesystem with ordered data mode.
md: Autodetecting RAID arrays.
md: autorun ...
md: ... autorun DONE.
EXT3 FS on sda1, internal journal
hda: packet command error: status=0x51 { DriveReady SeekComplete Error }
hda: packet command error: error=0x50 { LastFailedSense=0x05 }
ide: failed opcode was: unknown
cdrom: open failed.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda5, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda3, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda6, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
XFS mounting filesystem sdb1
Starting XFS recovery on filesystem: sdb1 (dev: sdb1)
Ending XFS recovery on filesystem: sdb1 (dev: sdb1)
XFS mounting filesystem sdc1
Starting XFS recovery on filesystem: sdc1 (dev: sdc1)
Ending XFS recovery on filesystem: sdc1 (dev: sdc1)
e1000: eth0: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
e1000: eth1: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
e1000: eth1: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
e1000: eth0: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
---

iptables : YES

routing : NO (3 routes at present)

traffic : A lot ;) ... 24x7 300mbit on eth0 and 450 mbit on eth1.

bye,
Chris

----- Original Message ----- 
From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: <nipsy@bitgnome.net>; <jrlundgren@gmail.com>; <cat@zip.com.au>; <djani22@dynamicweb.hu>; <yoseph.basri@gmail.com>; 
<bb@kernelpanic.ru>; <mykleb@no.ibm.com>; <olel@ans.pl>; <michal@feix.cz>; <chris@scorpion.nl>
Cc: <netdev@vger.kernel.org>; "Jesse Brandeburg" <jesse.brandeburg@gmail.com>; <davem@davemloft.net>; 
<E1000-devel@lists.sourceforge.net>; "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Sent: Thursday, March 30, 2006 4:53 AM
Subject: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...


Hi all, I've identified you as people who have at some point in the past
emailed one of the Linux lists with problems with e1000 and
sk_forward_alloc.  It seems to be fairly widespread, but only seems to
have appeared with recent kernel changes (after 2.6.12...)

What I need from you is a reproducible test, and some information.  I
have never been able to reproduce this, and I'm trying to isolate the
problem a bit.  What motherboards are you using?  What seems to cause
this problem?  Are you all using iptables?  Are you all routing? From
the reports I assume none of you are using an 82571/2/3 (pci express)

As far as I know e1000 has the same requirement as tg3 and some others
where we have to modify the header of the skb in the case of transmits
using TSO.  I don't see anywhere else that the driver modifies the skb.
Tomorrow I'll generate a patch to try a more paranoid copying of the
skb, I hope some of you can test.

To do this we have code like so in e1000_tso:
2529         if (skb_shinfo(skb)->tso_size) {
2530                 if (skb_header_cloned(skb)) {
2531                         err = pskb_expand_head(skb, 0, 0,
GFP_ATOMIC);
2532                         if (err)
2533                                 return err;
2534                 }
2535
2536                 hdr_len = ((skb->h.raw - skb->data) +
(skb->h.th->doff << 2));
2537                 mss = skb_shinfo(skb)->tso_size;
2538                 if (skb->protocol == ntohs(ETH_P_IP)) {
2539                         skb->nh.iph->tot_len = 0;
2540                         skb->nh.iph->check = 0;

Thanks for your assistance

Jesse





-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
