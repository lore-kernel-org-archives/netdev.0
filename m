From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Thu, 21 Aug 2008 07:09:10 -0700 (PDT)
Message-ID: <654003.23282.qm@web82104.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, Vivek Goyal <vgoyal@redhat.com>,
	Bill Fink <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82104.mail.mud.yahoo.com ([209.191.84.217]:36704 "HELO
	web82104.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753030AbYHUOJM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Aug 2008 10:09:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> > $ dmesg
> > Linux version 2.6.25.test (dawitbro@fileserver) (gcc version 4.3.1 =
(Debian=20
> 4.3.1-2) ) #1 SMP Wed Aug 20 23:31:39 EDT 2008
> > Command line: root=3D/dev/hda1 ro video=3Duvesafb:1280x1024-16@60,m=
trr:3=20
> fbcon=3Dscrollback:256k,font:10x18 debug
> > BIOS-provided physical RAM map:
> >  BIOS-e820: 0000000000000000 - 000000000009f400 (usable)
> >  BIOS-e820: 000000000009f400 - 00000000000a0000 (reserved)
> >  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
> >  BIOS-e820: 0000000000100000 - 0000000077fe0000 (usable)
> >  BIOS-e820: 0000000077fe0000 - 0000000077fe3000 (ACPI NVS)
> >  BIOS-e820: 0000000077fe3000 - 0000000077ff0000 (ACPI data)
> >  BIOS-e820: 0000000077ff0000 - 0000000078000000 (reserved)
> >  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
> >  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
> > Entering add_active_range(0, 0, 159) 0 entries of 3200 used
> > Entering add_active_range(0, 256, 491488) 1 entries of 3200 used
> > end_pfn_map =3D 1048576
> > DMI 2.5 present.
> > ACPI: RSDP 000F7B80, 0024 (r2 RS690 )
> > ACPI: RSDT 77FE3040, 0038 (r1 RS690  AWRDACPI 42302E31 AWRD        =
0)
> > ACPI: FACP 77FE30C0, 0074 (r1 RS690  AWRDACPI 42302E31 AWRD        =
0)
> > ACPI: DSDT 77FE3180, 4B0B (r1 RS690  AWRDACPI     1000 MSFT  300000=
0)
> > ACPI: FACS 77FE0000, 0040
> > ACPI: SSDT 77FE7DC0, 028A (r1 PTLTD  POWERNOW        1  LTP        =
1)
> > ACPI: HPET 77FE80C0, 0038 (r1 RS690  AWRDACPI 42302E31 AWRD       9=
8)
> > ACPI: MCFG 77FE8140, 003C (r1 RS690  AWRDACPI 42302E31 AWRD        =
0)
> > ACPI: APIC 77FE7D00, 0068 (r1 RS690  AWRDACPI 42302E31 AWRD        =
0)
> > No NUMA configuration found
> > Faking a node at 0000000000000000-0000000077fe0000
> > Entering add_active_range(0, 0, 159) 0 entries of 3200 used
> > Entering add_active_range(0, 256, 491488) 1 entries of 3200 used
> > Bootmem setup node 0 0000000000000000-0000000077fe0000
> >  NODE_DATA [000000000000c000 - 0000000000012fff]
> >  bootmap [0000000000013000 -  0000000000021fff] pages f
> > early res: 0 [0-fff] BIOS data page
> > early res: 1 [6000-7fff] SMP_TRAMPOLINE
> > early res: 2 [200000-7b5387] TEXT DATA BSS
> > early res: 3 [9f000-aefff] EBDA
> > early res: 4 [8000-bfff] PGTABLE
> >  [ffffe20000000000-ffffe200001fffff] PMD ->ffff810001200000 on node=
 0
> >  [ffffe20000200000-ffffe200003fffff] PMD ->ffff810001600000 on node=
 0
> >  [ffffe20000400000-ffffe200005fffff] PMD ->ffff810001a00000 on node=
 0
> >  [ffffe20000600000-ffffe200007fffff] PMD ->ffff810001e00000 on node=
 0
> >  [ffffe20000800000-ffffe200009fffff] PMD ->ffff810002200000 on node=
 0
> >  [ffffe20000a00000-ffffe20000bfffff] PMD ->ffff810002600000 on node=
 0
> >  [ffffe20000c00000-ffffe20000dfffff] PMD ->ffff810002a00000 on node=
 0
> >  [ffffe20000e00000-ffffe20000ffffff] PMD ->ffff810002e00000 on node=
 0
> >  [ffffe20001000000-ffffe200011fffff] PMD ->ffff810003200000 on node=
 0
> >  [ffffe20001200000-ffffe200013fffff] PMD ->ffff810003600000 on node=
 0
> >  [ffffe20001400000-ffffe200015fffff] PMD ->ffff810003a00000 on node=
 0
> >  [ffffe20001600000-ffffe200017fffff] PMD ->ffff810003e00000 on node=
 0
> >  [ffffe20001800000-ffffe200019fffff] PMD ->ffff810004200000 on node=
 0
> >  [ffffe20001a00000-ffffe20001bfffff] PMD ->ffff810004600000 on node=
 0
> > Zone PFN ranges:
> >  DMA             0 ->     4096
> >  DMA32        4096 ->  1048576
> >  Normal    1048576 ->  1048576
> > Movable zone start PFN for each node
> > early_node_map[2] active PFN ranges
> >    0:        0 ->      159
> >    0:      256 ->   491488
> > On node 0 totalpages: 491391
> >  DMA zone: 56 pages used for memmap
> >  DMA zone: 1486 pages reserved
> >  DMA zone: 2457 pages, LIFO batch:0
> >  DMA32 zone: 6663 pages used for memmap
> >  DMA32 zone: 480729 pages, LIFO batch:31
> >  Normal zone: 0 pages used for memmap
> >  Movable zone: 0 pages used for memmap
> > ATI board detected. Disabling timer routing over 8254.
> > Detected use of extended apic ids on hypertransport bus
> > ACPI: PM-Timer IO Port: 0x4008
> > ACPI: Local APIC address 0xfee00000
> > ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
> > Processor #0 (Bootup-CPU)
> > ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
> > Processor #1
> > ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
> > ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
> > ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
> > IOAPIC[0]: apic_id 2, address 0xfec00000, GSI 0-23
> > ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> > ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
> > ACPI: IRQ0 used by override.
> > ACPI: IRQ2 used by override.
> > ACPI: IRQ9 used by override.
> > Setting APIC routing to flat
> > ACPI: HPET id: 0x10b9a201 base: 0xfed00000
> > Using ACPI (MADT) for SMP configuration information
> > insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (Loc=
al APIC)=20
> [fee00000, fee00fff]
> >    insert_resource: good with request direct parent: (PCI mem) [0,=20
> ffffffffffffffff], new: (Local APIC) [fee00000, fee00fff]
> > request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (Syst=
em RAM) [0,=20
> 9f3ff] conflict 0
> > request_resource: root: (System RAM) [0, 9f3ff], new: (Kernel code)=
 [200000,=20
> 557241] conflict 1
> > request_resource: root: (System RAM) [0, 9f3ff], new: (Kernel data)=
 [557242,=20
> 6b4397] conflict 1
> > request_resource: root: (System RAM) [0, 9f3ff], new: (Kernel bss) =
[736000,=20
> 7b5387] conflict 1
> > request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (rese=
rved)=20
> [9f400, 9ffff] conflict 0
> > request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (rese=
rved)=20
> [f0000, fffff] conflict 0
> > request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (Syst=
em RAM)=20
> [100000, 77fdffff] conflict 0
> > request_resource: root: (System RAM) [100000, 77fdffff], new: (Kern=
el code)=20
> [200000, 557241] conflict 0
> > request_resource: root: (System RAM) [100000, 77fdffff], new: (Kern=
el data)=20
> [557242, 6b4397] conflict 0
> > request_resource: root: (System RAM) [100000, 77fdffff], new: (Kern=
el bss)=20
> [736000, 7b5387] conflict 0
> > request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (ACPI=
=20
> Non-volatile Storage) [77fe0000, 77fe2fff] conflict 0
> > request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (ACPI=
 Tables)=20
> [77fe3000, 77feffff] conflict 0
> > request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (rese=
rved)=20
> [77ff0000, 77ffffff] conflict 0
> > request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (rese=
rved)=20
> [e0000000, efffffff] conflict 0
> > request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (rese=
rved)=20
> [fec00000, ffffffff] conflict 1
> ..
> > insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (HPE=
T 0)=20
> [fed00000, fed003ff]
> >  insert_resource: first: (0000:00:14.0) [fed00000, fed003ff], new: =
(HPET 0)=20
> [fed00000, fed003ff]
> >  insert_resource: direct parent: (PCI mem) [0, ffffffffffffffff], n=
ew: (HPET=20
> 0) [fed00000, fed003ff]
> >    insert_resource: child: (0000:00:14.0) [fed00000, fed003ff], new=
: (HPET 0)=20
> [fed00000, fed003ff]
> > insert_resource: parent: (PCI mem) [0, ffffffffffffffff], new: (IOA=
PIC 0)=20
> [fec00000, fec00fff]
> >  insert_resource: first: (pnp 00:0d) [fec00000, fec00fff], new: (IO=
APIC 0)=20
> [fec00000, fec00fff]
> >  insert_resource: direct parent: (PCI mem) [0, ffffffffffffffff], n=
ew: (IOAPIC=20
> 0) [fec00000, fec00fff]
> >    insert_resource: child: (pnp 00:0d) [fec00000, fec00fff], new: (=
IOAPIC 0)=20
> [fec00000, fec00fff]
>=20
> so old kernel doesn't register [fec00000, ffffffff] from e820 as
> reserved. because lapic address register at first.

Well, at least it tried!  ;)

request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (reserved=
) [fec00000, ffffffff] conflict 1


> lapic, ioapic, and hpet0 addr all should be children of [fec00000,
> fffffffff] as reserved from e820.

I can see that the resources are not recorded in the tree properly, but=
=20
this kernel was still able to boot without hanging.  Is it enough that
the memory region was already marked as busy, or do these resource=20
structures need to be in the tree for other purposes?


> please use my print out patch with current kernel.

On the suggestion of Ilpo J=E4rvinen, I tried to delay the printk's lon=
g
enough to see them using CONFIG_BOOT_PRINTK_DELAY.  Unfortunately, I wa=
s
stung by what the help text for that option warns of:  the
CONFIG_BOOT_PRINTK_DELAY option can cause the kernel to hang on SMP
machines.

That is exactly what happens:  the kernel hangs pretty much immediately=
,
with only about a half dozen lines printed.

I did try my own suggestion:  change KERN_DEBUG to KERN_WARNING in your=
 patch,
and boot with "loglevel=3D5".  This worked, and almost the only lines p=
rinted
were those from your patch.  However, without the printk delay everythi=
ng
just scrolled away too fast to read... until the kernel hung.

I believe I can find a workaround to print this output in a more compac=
t way...
your formatting takes up 2 lines for each printk.  However, I am busy t=
his
morning and I have to work this afternoon.  I may not be able to provid=
e
the entire output until tonight or tomorrow.

=46or now, I can only report that the last lines printed were the same =
as
these from the working kernel's 'dmesg' output:

=3D=3D=3D=3D=3D=3D=3D=3D
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:14.1) [3f6, 3=
f6] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:14.1) [170, 1=
77] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:14.1) [376, 3=
76] conflict 0
request_resource: root: (PCI IO) [0, ffff], new: (0000:00:14.1) [f900, =
f90f] conflict 0
request_resource: root: (PCI mem) [0, ffffffffffffffff], new: (0000:00:=
14.2) [fe020000, fe023fff] conflict 0
request_resource: root: (PCI Bus #01) [d8000000, dfffffff], new: (0000:=
01:05.0) [d8000000, dfffffff] conflict 0
request_resource: root: (PCI Bus #01) [fdd00000, fdefffff], new: (0000:=
01:05.0) [fdee0000, fdeeffff] conflict 0
request_resource: root: (PCI Bus #01) [e000, efff], new: (0000:01:05.0)=
 [ee00, eeff] conflict 0
request_resource: root: (PCI Bus #01) [fdd00000, fdefffff], new: (0000:=
01:05.0) [fdd00000, fddfffff] conflict 0
request_resource: root: (PCI Bus #01) [fdd00000, fdefffff], new: (0000:=
01:05.2) [fdefc000, fdefffff] conflict 0
request_resource: root: (PCI Bus #02) [d000, dfff], new: (0000:02:05.0)=
 [de00, deff] conflict 0
request_resource: root: (PCI Bus #02) [fdc00000, fdcfffff], new: (0000:=
02:05.0) [fdcff000, fdcff0ff] conflict 0
=3D=3D=3D=3D=3D=3D=3D=3D

The only differences were trivial:  the "PCI Bus" strings now print in =
a
different format, like "PCI Bus 0000:01".

I will try to provide the entire output tonight or tomorrow.  It will b=
e
difficult, though:  it looks like I have to try to fit the info from ab=
out
60 of the printk's in your patch onto the 80x25 VGA screen, and still
make it understandable enough to be useful.


BTW, in a previous message, I recursed the iomem_resource tree and prin=
ted
all of the elements that end up there.  This was not sufficient, right?=
  You
also want to see what is rejected and not stored in the tree, which you=
r
patch's printks do show?


Thanks,
Dave W.
