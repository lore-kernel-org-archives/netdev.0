From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: pci_set_power_state(): 0000:00:0a.0: state=3, current state=5
Date: Fri, 1 Dec 2006 17:06:36 +0100
Message-ID: <BAY103-DAV6CB48D77FE31CE6188819B2DA0@phx.gbl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s11.bay0.hotmail.com ([65.54.246.211]:7983 "EHLO
	bay0-omc3-s11.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1031223AbWLAQGz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 11:06:55 -0500
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi everybody,

I'm running linux 2.6.19 (on a pretty old system),
and everytime I run 'mii-tool' I get a ton of:

pci_set_power_state(): 0000:00:0a.0: state=3, current state=5

Here is dmesg:

PCI: setting IRQ 10 as level-triggered
PCI: Found IRQ 10 for device 0000:00:0a.0
0000:00:0a.0: 3Com PCI 3c905 Boomerang 100baseTx at 0001dc00.
PCI: Found IRQ 11 for device 0000:00:0b.0
PCI: Sharing IRQ 11 with 0000:00:07.2
0000:00:0b.0: 3Com PCI 3c905 Boomerang 100baseTx at 0001da00.
ip_conntrack_pptp version 3.1 loaded
ip_nat_pptp version 3.0 loaded
eth0:  setting full-duplex.
eth1:  setting full-duplex.
eth2:  setting full-duplex.
root@Electra:/var/log# mii-tool
eth0: negotiated 100baseTx-FD, link ok
eth1: negotiated 100baseTx-FD, link ok
eth2: negotiated 100baseTx-FD, link ok
root@Electra:/var/log# dmesg
Linux version 2.6.19 (root@Electra) (gcc version 3.2.3) #1
Thu Nov 30 16:41:00 CET 2006
BIOS-provided physical RAM map:
  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
  BIOS-e820: 0000000000100000 - 0000000010000000 (usable)
  BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserved)
256MB LOWMEM available.
Entering add_active_range(0, 0, 65536) 0 entries of 256 used
Zone PFN ranges:
   DMA             0 ->     4096
   Normal       4096 ->    65536
early_node_map[1] active PFN ranges
     0:        0 ->    65536
On node 0 totalpages: 65536
   DMA zone: 32 pages used for memmap
   DMA zone: 0 pages reserved
   DMA zone: 4064 pages, LIFO batch:0
   Normal zone: 480 pages used for memmap
   Normal zone: 60960 pages, LIFO batch:15
DMI 2.1 present.
ACPI: Unable to locate RSDP
Allocating PCI resources starting at 20000000 (gap:
10000000:efff0000)
Detected 267.288 MHz processor.
Built 1 zonelists.  Total pages: 65024
Kernel command line: auto BOOT_IMAGE=Linux ro root=301
Local APIC disabled by BIOS -- you can enable it with "lapic"
mapped APIC to ffffd000 (01201000)
Enabling fast FPU save and restore... done.
Initializing CPU#0
PID hash table entries: 1024 (order: 10, 4096 bytes)
Console: colour VGA+ 80x25
Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
Memory: 256584k/262144k available (1946k kernel code, 5132k
reserved, 578k data, 160k init, 0k highmem)
virtual kernel memory layout:
     fixmap  : 0xfffb7000 - 0xfffff000   ( 288 kB)
     vmalloc : 0xd0800000 - 0xfffb5000   ( 759 MB)
     lowmem  : 0xc0000000 - 0xd0000000   ( 256 MB)
       .init : 0xc037a000 - 0xc03a2000   ( 160 kB)
       .data : 0xc02e6b89 - 0xc0377494   ( 578 kB)
       .text : 0xc0100000 - 0xc02e6b89   (1946 kB)
Checking if this processor honours the WP bit even in
supervisor mode... Ok.
Calibrating delay using timer specific routine.. 535.18
BogoMIPS (lpj=1070378)
Mount-cache hash table entries: 512
CPU: After generic identify, caps: 0183f9ff 00000000
00000000 00000000 00000000 00000000 00000000
CPU: L1 I cache: 16K, L1 D cache: 16K
CPU: After all inits, caps: 0183f9ff 00000000 00000000
00000040 00000000 00000000 00000000
Compat vDSO mapped to ffffe000.
CPU: Intel Celeron (Covington) stepping 00
Checking 'hlt' instruction... OK.
NET: Registered protocol family 16
PCI: PCI BIOS revision 2.10 entry at 0xfda61, last bus=1
PCI: Using configuration type 1
Setting up standard PCI resources
ACPI: Interpreter disabled.
PCI: Probing PCI hardware
PCI: Probing PCI hardware (bus 00)
* Found PM-Timer Bug on the chipset. Due to workarounds for
a bug,
* this clock source is slow. Consider trying other clock sources
PCI quirk: region 6100-613f claimed by PIIX4 ACPI
PCI quirk: region 5f00-5f0f claimed by PIIX4 SMB
Boot video device is 0000:01:00.0
PCI: Using IRQ router PIIX/ICH [8086/7110] at 0000:00:07.0
PCI: setting IRQ 11 as level-triggered
PCI: Found IRQ 11 for device 0000:00:07.2
PCI: Sharing IRQ 11 with 0000:00:0b.0
PCI: Bridge: 0000:00:01.0
   IO window: b000-bfff
   MEM window: efe00000-efefffff
   PREFETCH window: e5c00000-e7cfffff
NET: Registered protocol family 2
IP route cache hash table entries: 2048 (order: 1, 8192 bytes)
TCP established hash table entries: 8192 (order: 3, 32768 bytes)
TCP bind hash table entries: 4096 (order: 2, 16384 bytes)
TCP: Hash tables configured (established 8192 bind 4096)
TCP reno registered
SGI XFS with no debug enabled
io scheduler noop registered
io scheduler deadline registered (default)
Limiting direct PCI/PCI transfers.
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override
with idebus=xx
PIIX4: IDE controller at PCI slot 0000:00:07.1
PIIX4: chipset revision 1
PIIX4: not 100% native mode: will probe irqs later
     ide0: BM-DMA at 0xffa0-0xffa7, BIOS settings: hda:DMA,
hdb:pio
     ide1: BM-DMA at 0xffa8-0xffaf, BIOS settings: hdc:pio,
hdd:pio
Probing IDE interface ide0...
hda: QUANTUM FIREBALL EX3.2A, ATA DISK drive
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Probing IDE interface ide1...
hda: max request size: 128KiB
hda: 6306048 sectors (3228 MB) w/418KiB Cache,
CHS=6256/16/63, UDMA(33)
hda: cache flushes not supported
  hda: hda1 hda2 < hda5 hda6 hda7 hda8 hda9 >
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
ip_conntrack version 2.4 (2048 buckets, 16384 max) - 228
bytes per conntrack
input: AT Translated Set 2 keyboard as /class/input/input0
ip_tables: (C) 2000-2006 Netfilter Core Team
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 1
NET: Registered protocol family 17
NET: Registered protocol family 15
Using IPI Shortcut mode
Time: tsc clocksource has been installed.
Filesystem "hda1": Disabling barriers, not supported by the
underlying device
XFS mounting filesystem hda1
Starting XFS recovery on filesystem: hda1 (logdev: internal)
Ending XFS recovery on filesystem: hda1 (logdev: internal)
VFS: Mounted root (xfs filesystem) readonly.
Freeing unused kernel memory: 160k freed
Adding 209624k swap on /dev/hda9.  Priority:-1 extents:1
across:209624k
Filesystem "hda1": Disabling barriers, not supported by the
underlying device
Filesystem "hda1": Disabling barriers, not supported by the
underlying device
Filesystem "hda5": Disabling barriers, not supported by the
underlying device
XFS mounting filesystem hda5
Starting XFS recovery on filesystem: hda5 (logdev: internal)
Ending XFS recovery on filesystem: hda5 (logdev: internal)
Filesystem "hda6": Disabling barriers, not supported by the
underlying device
XFS mounting filesystem hda6
Starting XFS recovery on filesystem: hda6 (logdev: internal)
Ending XFS recovery on filesystem: hda6 (logdev: internal)
Filesystem "hda7": Disabling barriers, not supported by the
underlying device
XFS mounting filesystem hda7
Ending clean XFS mount for filesystem: hda7
Filesystem "hda8": Disabling barriers, not supported by the
underlying device
XFS mounting filesystem hda8
Starting XFS recovery on filesystem: hda8 (logdev: internal)
Ending XFS recovery on filesystem: hda8 (logdev: internal)
PCI: setting IRQ 9 as level-triggered
PCI: Found IRQ 9 for device 0000:00:09.0
3c59x: Donald Becker and others.
www.scyld.com/network/vortex.html
0000:00:09.0: 3Com PCI 3c905 Boomerang 100baseTx at 0001de00.
PCI: setting IRQ 10 as level-triggered
PCI: Found IRQ 10 for device 0000:00:0a.0
0000:00:0a.0: 3Com PCI 3c905 Boomerang 100baseTx at 0001dc00.
PCI: Found IRQ 11 for device 0000:00:0b.0
PCI: Sharing IRQ 11 with 0000:00:07.2
0000:00:0b.0: 3Com PCI 3c905 Boomerang 100baseTx at 0001da00.
ip_conntrack_pptp version 3.1 loaded
ip_nat_pptp version 3.0 loaded
eth0:  setting full-duplex.
eth1:  setting full-duplex.
eth2:  setting full-duplex.
pci_set_power_state(): 0000:00:09.0: state=3, current state=5
pci_set_power_state(): 0000:00:09.0: state=3, current state=5
pci_set_power_state(): 0000:00:09.0: state=3, current state=5
pci_set_power_state(): 0000:00:09.0: state=3, current state=5
pci_set_power_state(): 0000:00:09.0: state=3, current state=5
pci_set_power_state(): 0000:00:09.0: state=3, current state=5
pci_set_power_state(): 0000:00:09.0: state=3, current state=5
pci_set_power_state(): 0000:00:09.0: state=3, current state=5
pci_set_power_state(): 0000:00:09.0: state=3, current state=5
pci_set_power_state(): 0000:00:09.0: state=3, current state=5
pci_set_power_state(): 0000:00:0a.0: state=3, current state=5
pci_set_power_state(): 0000:00:0a.0: state=3, current state=5
pci_set_power_state(): 0000:00:0a.0: state=3, current state=5
pci_set_power_state(): 0000:00:0a.0: state=3, current state=5
pci_set_power_state(): 0000:00:0a.0: state=3, current state=5
pci_set_power_state(): 0000:00:0a.0: state=3, current state=5
pci_set_power_state(): 0000:00:0a.0: state=3, current state=5
pci_set_power_state(): 0000:00:0a.0: state=3, current state=5
pci_set_power_state(): 0000:00:0a.0: state=3, current state=5
pci_set_power_state(): 0000:00:0a.0: state=3, current state=5
pci_set_power_state(): 0000:00:0b.0: state=3, current state=5
pci_set_power_state(): 0000:00:0b.0: state=3, current state=5
pci_set_power_state(): 0000:00:0b.0: state=3, current state=5
pci_set_power_state(): 0000:00:0b.0: state=3, current state=5
pci_set_power_state(): 0000:00:0b.0: state=3, current state=5
pci_set_power_state(): 0000:00:0b.0: state=3, current state=5
pci_set_power_state(): 0000:00:0b.0: state=3, current state=5
pci_set_power_state(): 0000:00:0b.0: state=3, current state=5
pci_set_power_state(): 0000:00:0b.0: state=3, current state=5
pci_set_power_state(): 0000:00:0b.0: state=3, current state=5


