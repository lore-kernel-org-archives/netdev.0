From: "Yoseph Basri" <yoseph.basri@gmail.com>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Thu, 30 Mar 2006 12:02:11 +0800
Message-ID: <e282236e0603292002g46a92c1u4eb0bee9881745e4@mail.gmail.com>
References: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: nipsy@bitgnome.net, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, bb@kernelpanic.ru, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org,
	"Jesse Brandeburg" <jesse.brandeburg@gmail.com>, davem@davemloft.net,
	E1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408>
Content-Disposition: inline
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

Hi Jesse,

Thanks for your concern,

My server still send warning message regarding this KERNEL: assertion
(!sk_forward_alloc)  after upgrade kernel 2.6.12 or 2.6.15.

This is from dmesg server:

Linux version 2.6.15.4 (root@xxxxx) (gcc version 3.3.4 (Debian
1:3.3.4-13)) #1 SMP Tue Feb 21 17:12:27 SGT 2006
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009d400 (usable)
 BIOS-e820: 000000000009d400 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000f7ffb300 (usable)
 BIOS-e820: 00000000f7ffb300 - 00000000f8000000 (ACPI data)
 BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000000108000000 (usable)
Warning only 4GB will be used.
Use a PAE enabled kernel.
3200MB HIGHMEM available.
896MB LOWMEM available.
found SMP MP-table at 0009d540
On node 0 totalpages: 1048576
  DMA zone: 4096 pages, LIFO batch:0
  DMA32 zone: 0 pages, LIFO batch:0
  Normal zone: 225280 pages, LIFO batch:31
  HighMem zone: 819200 pages, LIFO batch:31
DMI 2.3 present.
ACPI: RSDP (v000 IBM                                   ) @ 0x000fdfc0
ACPI: RSDT (v001 IBM    SERONYXP 0x00001000 IBM  0x45444f43) @ 0xf7ffff80
ACPI: FADT (v001 IBM    SERONYXP 0x00001000 IBM  0x45444f43) @ 0xf7ffff00
ACPI: MADT (v001 IBM    SERONYXP 0x00001000 IBM  0x45444f43) @ 0xf7fffe80
ACPI: ASF! (v016 IBM    SERONYXP 0x00000001 IBM  0x45444f43) @ 0xf7fffdc0
ACPI: DSDT (v001 IBM    SERGEODE 0x00001000 MSFT 0x0100000b) @ 0x00000000
ACPI: PM-Timer IO Port: 0x488
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
Processor #0 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
Processor #1 15:2 APIC version 20
ACPI: LAPIC_NMI (acpi_id[0x00] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
ACPI: IOAPIC (id[0x0e] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 14, version 17, address 0xfec00000, GSI 0-15
ACPI: IOAPIC (id[0x0d] address[0xfec01000] gsi_base[16])
IOAPIC[1]: apic_id 13, version 17, address 0xfec01000, GSI 16-31
ACPI: IOAPIC (id[0x0c] address[0xfec02000] gsi_base[32])
IOAPIC[2]: apic_id 12, version 17, address 0xfec02000, GSI 32-47
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ7 used by override.
Enabling APIC mode:  Flat.  Using 3 I/O APICs
Using ACPI (MADT) for SMP configuration information
Allocating PCI resources starting at f8800000 (gap: f8000000:06c00000)
Built 1 zonelists
Kernel command line: BOOT_IMAGE=3Dlinux-2.6.15.4 ro root=3D801
mapped APIC to ffffd000 (fee00000)
mapped IOAPIC to ffffc000 (fec00000)
mapped IOAPIC to ffffb000 (fec01000)
mapped IOAPIC to ffffa000 (fec02000)
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 65536 bytes)
Detected 2794.685 MHz processor.
Using pmtmr for high-res timesource
Console: colour VGA+ 80x25
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 4025292k/4194304k available (1906k kernel code, 36796k
reserved, 650k data, 240k init, 3145708k highmem)
Checking if this processor honours the WP bit even in supervisor mode... Ok=
.
Calibrating delay using timer specific routine.. 5593.74 BogoMIPS (lpj=3D11=
187486)
Mount-cache hash table entries: 512
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000
00004400 00000000 00000000
CPU: After vendor identify, caps: bfebfbff 00000000 00000000 00000000
00004400 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: Physical Processor ID: 0
CPU: After all inits, caps: bfebfbff 00000000 00000000 00000080
00004400 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU0: Intel P4/Xeon Extended MCE MSRs (12) available
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Checking 'hlt' instruction... OK.
CPU0: Intel(R) Xeon(TM) CPU 2.80GHz stepping 07
Booting processor 1/1 eip 2000
Initializing CPU#1
Calibrating delay using timer specific routine.. 5588.12 BogoMIPS (lpj=3D11=
176253)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000
00004400 00000000 00000000
CPU: After vendor identify, caps: bfebfbff 00000000 00000000 00000000
00004400 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: Physical Processor ID: 0
CPU: After all inits, caps: bfebfbff 00000000 00000000 00000080
00004400 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#1.
CPU1: Intel P4/Xeon Extended MCE MSRs (12) available
CPU1: Intel(R) Xeon(TM) CPU 2.80GHz stepping 07
Total of 2 processors activated (11181.86 BogoMIPS).
ENABLING IO-APIC IRQs
..TIMER: vector=3D0x31 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D-1
checking TSC synchronization across 2 CPUs: passed.
Brought up 2 CPUs
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: PCI BIOS revision 2.10 entry at 0xfd7dc, last bus=3D8
PCI: Using configuration type 1
ACPI: Subsystem revision 20050902
ACPI: Interpreter enabled
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: Probing PCI hardware (bus 00)
Boot video device is 0000:00:06.0
PCI: Ignoring BAR0-3 of IDE controller 0000:00:0f.1
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Root Bridge [PCI1] (0000:02)
PCI: Probing PCI hardware (bus 02)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1._PRT]
ACPI: PCI Root Bridge [PCI2] (0000:04)
PCI: Probing PCI hardware (bus 04)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI2._PRT]
ACPI: PCI Root Bridge [PCI3] (0000:06)
PCI: Probing PCI hardware (bus 06)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI3._PRT]
ACPI: PCI Root Bridge [PCI4] (0000:08)
PCI: Probing PCI hardware (bus 08)
ACPI: PCI Interrupt Routing Table [\_SB_.PCI4._PRT]
ACPI: PCI Interrupt Link [LP00] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP01] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP02] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP03] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP04] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP05] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP06] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP07] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP08] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP09] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP0A] (IRQs *10)
ACPI: PCI Interrupt Link [LP0B] (IRQs *9)
ACPI: PCI Interrupt Link [LP0C] (IRQs *9)
ACPI: PCI Interrupt Link [LP0D] (IRQs *3)
ACPI: PCI Interrupt Link [LP0E] (IRQs *5)
ACPI: PCI Interrupt Link [LP0F] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP10] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP11] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP12] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP13] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP14] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP15] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP16] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP17] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP18] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP19] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP1A] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP1B] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP1C] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP1D] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP1E] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LP1F] (IRQs) *0, disabled.
ACPI: PCI Interrupt Link [LPUS] (IRQs *11)
SCSI subsystem initialized
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=3Drouteirq".  If it helps, post a r=
eport
IA-32 Microcode Update Driver: v1.14 <tigran@veritas.com>
highmem bounce pool size: 64 pages
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered
Real Time Clock Driver v1.12
serio: i8042 AUX port at 0x60,0x64 irq 12
serio: i8042 KBD port at 0x60,0x64 irq 1
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
Floppy drive(s): fd0 is 1.44M
FDC 0 is a National Semiconductor PC87306
Intel(R) PRO/1000 Network Driver - version 6.1.16-k2
Copyright (c) 1999-2005 Intel Corporation.
ACPI: PCI Interrupt 0000:06:08.0[A] -> GSI 29 (level, low) -> IRQ 16
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
ACPI: PCI Interrupt 0000:06:08.1[B] -> GSI 30 (level, low) -> IRQ 17
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
e100: Intel(R) PRO/100 Network Driver, 3.4.14-k4-NAPI
e100: Copyright(c) 1999-2005 Intel Corporation
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=3D=
xx
Probing IDE interface ide0...
hda: LG CD-ROM CRN-8245B, ATAPI CD/DVD-ROM drive
Probing IDE interface ide1...
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Fusion MPT base driver 3.03.04
Copyright (c) 1999-2005 LSI Logic Corporation
Fusion MPT SPI Host driver 3.03.04
Fusion MPT base driver 3.03.04
Copyright (c) 1999-2005 LSI Logic Corporation
Fusion MPT SPI Host driver 3.03.04
ACPI: PCI Interrupt 0000:08:07.0[A] -> GSI 27 (level, low) -> IRQ 18
mptbase: Initiating ioc0 bringup
ioc0: 53C1030: Capabilities=3D{Initiator}
scsi0 : ioc0: LSI53C1030, FwRev=3D01000e00h, Ports=3D1, MaxQ=3D222, IRQ=3D1=
8
  Vendor: IBM-ESXS  Model: MAP3735NC     FN  Rev: B109
  Type:   Direct-Access                      ANSI SCSI revision: 03
SCSI device sda: 143374000 512-byte hdwr sectors (73407 MB)
SCSI device sda: drive cache: write through
SCSI device sda: 143374000 512-byte hdwr sectors (73407 MB)
SCSI device sda: drive cache: write through
 sda: sda1 sda2 sda3 < sda5 sda6 sda7 sda8 sda9 sda10 >
sd 0:0:0:0: Attached scsi disk sda
  Vendor: IBM-ESXS  Model: MAP3735NC     FN  Rev: B109
  Type:   Direct-Access                      ANSI SCSI revision: 03
SCSI device sdb: 143374000 512-byte hdwr sectors (73407 MB)
SCSI device sdb: drive cache: write through
SCSI device sdb: 143374000 512-byte hdwr sectors (73407 MB)
SCSI device sdb: drive cache: write through
 sdb: sdb1 sdb2 sdb3 sdb4
sd 0:0:1:0: Attached scsi disk sdb
  Vendor: IBM-ESXS  Model: MAP3735NC     FN  Rev: B109
  Type:   Direct-Access                      ANSI SCSI revision: 03
SCSI device sdc: 143374000 512-byte hdwr sectors (73407 MB)
SCSI device sdc: drive cache: write through
SCSI device sdc: 143374000 512-byte hdwr sectors (73407 MB)
SCSI device sdc: drive cache: write through
 sdc: sdc1 sdc2 sdc3 sdc4
sd 0:0:2:0: Attached scsi disk sdc
  Vendor: IBM-ESXS  Model: MAP3735NC     FN  Rev: B109
  Type:   Direct-Access                      ANSI SCSI revision: 03
SCSI device sdd: 143374000 512-byte hdwr sectors (73407 MB)
SCSI device sdd: drive cache: write through
SCSI device sdd: 143374000 512-byte hdwr sectors (73407 MB)
SCSI device sdd: drive cache: write through
 sdd: sdd1 sdd2 sdd3 sdd4
sd 0:0:3:0: Attached scsi disk sdd
  Vendor: IBM-ESXS  Model: MAP3735NC     FN  Rev: B109
  Type:   Direct-Access                      ANSI SCSI revision: 03
SCSI device sde: 143374000 512-byte hdwr sectors (73407 MB)
SCSI device sde: drive cache: write through
SCSI device sde: 143374000 512-byte hdwr sectors (73407 MB)
SCSI device sde: drive cache: write through
 sde: sde1 sde2 sde3 sde4
sd 0:0:4:0: Attached scsi disk sde
  Vendor: IBM-ESXS  Model: MAP3735NC     FN  Rev: B109
  Type:   Direct-Access                      ANSI SCSI revision: 03
SCSI device sdf: 143374000 512-byte hdwr sectors (73407 MB)
SCSI device sdf: drive cache: write through
SCSI device sdf: 143374000 512-byte hdwr sectors (73407 MB)
SCSI device sdf: drive cache: write through
 sdf: sdf1 sdf2 sdf3 sdf4
sd 0:0:5:0: Attached scsi disk sdf
  Vendor: IBM       Model: 32P0032a S320  1  Rev: 1
  Type:   Processor                          ANSI SCSI revision: 02
ACPI: PCI Interrupt 0000:08:07.1[B] -> GSI 28 (level, low) -> IRQ 19
mptbase: Initiating ioc1 bringup
ioc1: 53C1030: Capabilities=3D{Initiator}
scsi1 : ioc1: LSI53C1030, FwRev=3D01000e00h, Ports=3D1, MaxQ=3D222, IRQ=3D1=
9
mice: PS/2 mouse device common for all mice
NET: Registered protocol family 2
IP route cache hash table entries: 262144 (order: 8, 1048576 bytes)
TCP established hash table entries: 524288 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
input: AT Translated Set 2 keyboard as /class/input/input0
TCP: Hash tables configured (established 524288 bind 65536)
TCP reno registered
ip_conntrack version 2.4 (8192 buckets, 65536 max) - 176 bytes per conntrac=
k
ip_tables: (C) 2000-2002 Netfilter core team
TCP bic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
Starting balanced_irq
Using IPI Shortcut mode
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 240k freed
Adding 2104504k swap on /dev/sda2.  Priority:-1 extents:1 across:2104504k
EXT3 FS on sda1, internal journal
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda6, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda5, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda7, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda10, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda9, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda8, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdb1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdb2, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdb3, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdb4, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdc1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdc2, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdc3, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdc4, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdd1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdd2, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdd3, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdd4, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sde1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sde2, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sde3, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sde4, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdf1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdf2, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdf3, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdf4, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
e1000: eth0: e1000_watchdog_task: NIC Link is Up 100 Mbps Full Duplex

Are you all using iptables?

YES

Are you all routing?

NO

>From the reports I assume none of you are using an 82571/2/3 (pci express)?

think so.

Thnaks again.

YB



On 3/30/06, Brandeburg, Jesse <jesse.brandeburg@intel.com> wrote:
> Hi all, I've identified you as people who have at some point in the past
> emailed one of the Linux lists with problems with e1000 and
> sk_forward_alloc.  It seems to be fairly widespread, but only seems to
> have appeared with recent kernel changes (after 2.6.12...)
>
> What I need from you is a reproducible test, and some information.  I
> have never been able to reproduce this, and I'm trying to isolate the
> problem a bit.  What motherboards are you using?  What seems to cause
> this problem?  Are you all using iptables?  Are you all routing? From
> the reports I assume none of you are using an 82571/2/3 (pci express)
>
> As far as I know e1000 has the same requirement as tg3 and some others
> where we have to modify the header of the skb in the case of transmits
> using TSO.  I don't see anywhere else that the driver modifies the skb.
> Tomorrow I'll generate a patch to try a more paranoid copying of the
> skb, I hope some of you can test.
>
> To do this we have code like so in e1000_tso:
> 2529         if (skb_shinfo(skb)->tso_size) {
> 2530                 if (skb_header_cloned(skb)) {
> 2531                         err =3D pskb_expand_head(skb, 0, 0,
> GFP_ATOMIC);
> 2532                         if (err)
> 2533                                 return err;
> 2534                 }
> 2535
> 2536                 hdr_len =3D ((skb->h.raw - skb->data) +
> (skb->h.th->doff << 2));
> 2537                 mss =3D skb_shinfo(skb)->tso_size;
> 2538                 if (skb->protocol =3D=3D ntohs(ETH_P_IP)) {
> 2539                         skb->nh.iph->tot_len =3D 0;
> 2540                         skb->nh.iph->check =3D 0;
>
> Thanks for your assistance
>
> Jesse
>


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
