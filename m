From: Iouri Atiounkine - Pixart <iouri@pixartargentina.com.ar>
Subject: Re: 2.6.9 - SiS900 - No MII transceivers found!
Date: Fri, 26 Nov 2004 11:37:27 -0300
Message-ID: <41A73FA7.8050502@pixartargentina.com.ar>
References: <41A63E19.8080902@pixartargentina.com.ar>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070707060004000104010108"
Return-path: <netdev-bounce@oss.sgi.com>
To: webvenza@libero.it, netdev@oss.sgi.com
In-Reply-To: <41A63E19.8080902@pixartargentina.com.ar>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070707060004000104010108
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id iAQEUtUX006707

  Hi

In attached files has included messages then a network interface is=20
working.

  After the first reboot NIC is still working.
  After shutdown it not working.

Thank you


Iouri Atiounkine - Pixart escribi=F3:
> Hi
>  I have two motherboards PC Chips 909G version 1.0.
> In this motherboards network interface is SiS900 onboard.
>=20
> The network interface does not work always.
> Sometimes in both motherboard the network interface is working.
>=20
> It work good then computer was turned off for one day or more  and unti=
l=20
> the power is turned off.
>  After shutdown (or reboot) it not working at all.
>=20
> The problem is at loading module:
>=20
> eth0: No MII transceivers found!
>=20
> In the case if module loaded good it print a message:
>  found internal sis900 transceiver.
>=20
> The kernel is downloaded from this address:
> http://http.us.debian.org/debian/pool/main/k/kernel-image-2.6.9-i386/ke=
rnel-image-2.6.9-1-686_2.6.9-2_i386.deb=20
>=20
>=20
> This motherboard has onboard separated SiS900 chip and LAN Transformer =
-
> TD1603C.
>=20
> Thank you.
>=20
> ***********************************
> Here is message of dmesg, lsmod, lspci -n -vv and mii-tool:
> ***********************************
> R_xart:~# lsmod
> Module                  Size  Used by
> sis900                 20484  0
> mii                     4928  0
> mousedev               11576  1
> tsdev                   7648  0
> psmouse                21960  0
> uhci_hcd               32944  0
> ohci_hcd               21412  0
> ehci_hcd               32068  0
> usbcore               119396  5 uhci_hcd,ohci_hcd,ehci_hcd
> parport_pc             37188  1
> lp                     11080  0
> parport                41704  2 parport_pc,lp
> i8xx_tco                6996  0
> hw_random               5364  0
> pciehp                 98916  0
> shpchp                101924  0
> pci_hotplug            34448  2 pciehp,shpchp
> intel_agp              22592  1
> agpgart                34600  2 intel_agp
> evdev                   9504  0
> crc32                   4192  1 sis900
> snd_intel8x0           35276  1
> snd_ac97_codec         73200  1 snd_intel8x0
> snd_pcm_oss            54024  0
> snd_mixer_oss          20192  1 snd_pcm_oss
> snd_pcm                98696  2 snd_intel8x0,snd_pcm_oss
> snd_timer              25668  1 snd_pcm
> snd_page_alloc          9992  2 snd_intel8x0,snd_pcm
> gameport                4512  1 snd_intel8x0
> snd_mpu401_uart         7872  1 snd_intel8x0
> snd_rawmidi            24900  1 snd_mpu401_uart
> snd_seq_device          7976  1 snd_rawmidi
> snd                    56804  11=20
> snd_intel8x0,snd_ac97_codec,snd_pcm_oss,snd_mixer_oss,snd_pcm,snd_timer=
,snd_mpu401_uart,snd_rawmidi,snd_seq_device=20
>=20
> soundcore              10176  1 snd
> nls_iso8859_1           3904  1
> nls_cp437               5568  1
> capability              4392  0
> commoncap               7008  1 capability
> ide_cd                 42592  1
> cdrom                  40956  1 ide_cd
> rtc                    12664  0
> vfat                   14528  1
> fat                    46624  1 vfat
> xfs                   616216  0
> reiserfs              248976  1
> romfs                   9220  0
> isofs                  37208  0
> ext2                   70632  1
> ext3                  126184  0
> jbd                    64056  1 ext3
> mbcache                 9220  2 ext2,ext3
> ide_generic             1280  0
> ide_disk               20480  5
> piix                   13216  1
> ide_core              143088  4 ide_cd,ide_generic,ide_disk,piix
> sd_mod                 17904  0
> ata_piix                9028  0
> libata                 45540  1 ata_piix
> scsi_mod              125676  2 sd_mod,libata
> unix                   28564  172
> fbcon                  40416  0
> font                    8128  1 fbcon
> vesafb                  6656  0
> cfbcopyarea             3936  1 vesafb
> cfbimgblt               2880  1 vesafb
> cfbfillrect             3584  1 vesafb
>=20
> R_xart:~# dmesg
>  0000000000100000 - 000000000f7f0000 (usable)
>  BIOS-e820: 000000000f7f0000 - 000000000f7f8000 (ACPI data)
>  BIOS-e820: 000000000f7f8000 - 000000000f800000 (ACPI NVS)
>  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
>  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
>  BIOS-e820: 00000000ffb00000 - 00000000ffc00000 (reserved)
>  BIOS-e820: 00000000fff00000 - 0000000100000000 (reserved)
> 0MB HIGHMEM available.
> 247MB LOWMEM available.
> found SMP MP-table at 000fb960
> On node 0 totalpages: 63472
>   DMA zone: 4096 pages, LIFO batch:1
>   Normal zone: 59376 pages, LIFO batch:14
>   HighMem zone: 0 pages, LIFO batch:1
> DMI 2.3 present.
> ACPI: RSDP (v000 AMI                                   ) @ 0x000fa000
> ACPI: RSDT (v001 AMIINT INTEL845 0x00000010 MSFT 0x00000097) @ 0x0f7f00=
00
> ACPI: FADT (v001 AMIINT INTEL845 0x00000011 MSFT 0x00000097) @ 0x0f7f00=
30
> ACPI: MADT (v001 AMIINT INTEL845 0x00000009 MSFT 0x00000097) @ 0x0f7f00=
c0
> ACPI: DSDT (v001  INTEL BROKDLEG 0x00001000 MSFT 0x0100000d) @ 0x000000=
00
> ACPI: PM-Timer IO Port: 0x808
> ACPI: Local APIC address 0xfee00000
> ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
> Processor #0 15:2 APIC version 20
> ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] disabled)
> ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
> IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
> ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> ACPI: IRQ0 used by override.
> ACPI: IRQ2 used by override.
> ACPI: IRQ9 used by override.
> Enabling APIC mode:  Flat.  Using 1 I/O APICs
> Using ACPI (MADT) for SMP configuration information
> Built 1 zonelists
> Kernel command line: root=3D/dev/hda5 ro
> Initializing CPU#0
> PID hash table entries: 1024 (order: 10, 16384 bytes)
> Detected 1799.442 MHz processor.
> Using pmtmr for high-res timesource
> Console: colour VGA+ 80x25
> Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
> Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
> Memory: 243616k/253888k available (1654k kernel code, 9600k reserved,=20
> 723k data, 152k init, 0k highmem)
> Checking if this processor honours the WP bit even in supervisor mode..=
.=20
> Ok.
> Calibrating delay loop... 3563.52 BogoMIPS (lpj=3D1781760)
> Security Scaffold v1.0.0 initialized
> SELinux:  Disabled at boot.
> Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
> CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000
> CPU: After vendor identify, caps:  bfebfbff 00000000 00000000 00000000
> CPU: Trace cache: 12K uops, L1 D cache: 8K
> CPU: L2 cache: 128K
> CPU: After all inits, caps:        bfebfbff 00000000 00000000 00000080
> Intel machine check architecture supported.
> Intel machine check reporting enabled on CPU#0.
> CPU0: Intel P4/Xeon Extended MCE MSRs (12) available
> CPU0: Thermal monitoring enabled
> CPU: Intel(R) Celeron(R) CPU 1.80GHz stepping 09
> Enabling fast FPU save and restore... done.
> Enabling unmasked SIMD FPU exception support... done.
> Checking 'hlt' instruction... OK.
> ENABLING IO-APIC IRQs
> ..TIMER: vector=3D0x31 pin1=3D2 pin2=3D-1
> checking if image is initramfs...it isn't (ungzip failed); looks like a=
n=20
> initrd
> Freeing initrd memory: 4632k freed
> NET: Registered protocol family 16
> PCI: PCI BIOS revision 2.10 entry at 0xfdb81, last bus=3D3
> PCI: Using configuration type 1
> mtrr: v2.0 (20020519)
> ACPI: Subsystem revision 20040816
> ACPI: Interpreter enabled
> ACPI: Using IOAPIC for interrupt routing
> ACPI: PCI Root Bridge [PCI0] (00:00)
> PCI: Probing PCI hardware (bus 00)
> PCI: Ignoring BAR0-3 of IDE controller 0000:00:1f.1
> PCI: Transparent bridge - 0000:00:1e.0
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.ICHB._PRT]
> ACPI: Power Resource [URP1] (off)
> ACPI: Power Resource [URP2] (off)
> ACPI: Power Resource [FDDP] (off)
> ACPI: Power Resource [LPTP] (off)
> ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 *11 12 14 15)
> ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 *5 6 7 10 11 12 14 15)
> ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 7 10 11 12 14 15)
> ACPI: PCI Interrupt Link [LNKD] (IRQs *3 4 5 6 7 10 11 12 14 15)
> ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0,=20
> disabled.
> ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0,=20
> disabled.
> ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 15) *0,=20
> disabled.
> ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 *10 11 12 14 15)
> Linux Plug and Play Support v0.97 (c) Adam Belay
> PnPBIOS: Scanning system for PnP BIOS support...
> PnPBIOS: Found PnP BIOS installation structure at 0xc00f7330
> PnPBIOS: PnP BIOS version 1.0, entry 0xf0000:0x600b, dseg 0xf0000
> PnPBIOS: Missing SMALL_TAG_ENDDEP tag
> PnPBIOS: Missing SMALL_TAG_ENDDEP tag
> PnPBIOS: Missing SMALL_TAG_ENDDEP tag
> PnPBIOS: Missing SMALL_TAG_ENDDEP tag
> PnPBIOS: 13 nodes reported by PnP BIOS; 13 recorded by driver
> PCI: Using ACPI for IRQ routing
> ACPI: PCI interrupt 0000:00:02.0[A] -> GSI 16 (level, low) -> IRQ 169
> ACPI: PCI interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) -> IRQ 169
> ACPI: PCI interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 177
> ACPI: PCI interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 185
> ACPI: PCI interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 193
> ACPI: PCI interrupt 0000:00:1f.1[A] -> GSI 18 (level, low) -> IRQ 185
> ACPI: PCI interrupt 0000:00:1f.5[B] -> GSI 17 (level, low) -> IRQ 201
> ACPI: PCI interrupt 0000:03:03.0[A] -> GSI 23 (level, low) -> IRQ 193
> ACPI: PCI interrupt 0000:03:07.0[A] -> GSI 18 (level, low) -> IRQ 185
> VFS: Disk quotas dquot_6.5.1
> Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
> devfs: 2004-01-31 Richard Gooch (rgooch@atnf.csiro.au)
> devfs: boot_options: 0x0
> Initializing Cryptographic API
> isapnp: Scanning for PnP cards...
> isapnp: No Plug & Play device found
> serio: i8042 AUX port at 0x60,0x64 irq 12
> serio: i8042 KBD port at 0x60,0x64 irq 1
> Serial: 8250/16550 driver $Revision: 1.90 $ 48 ports, IRQ sharing enabl=
ed
> ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
> ACPI: PCI interrupt 0000:03:03.0[A] -> GSI 23 (level, low) -> IRQ 193
> ttyS15 at I/O 0xcc08 (irq =3D 193) is a 16450
> ttyS44 at I/O 0xcc10 (irq =3D 193) is a 8250
> ttyS45 at I/O 0xcc18 (irq =3D 193) is a 16450
> ttyS46 at I/O 0xcc20 (irq =3D 193) is a 8250
> ttyS47 at I/O 0xcc28 (irq =3D 193) is a 8250
> RAMDISK driver initialized: 16 RAM disks of 8192K size 1024 blocksize
> input: AT Translated Set 2 keyboard on isa0060/serio0
> NET: Registered protocol family 2
> IP: routing cache hash table of 2048 buckets, 16Kbytes
> TCP: Hash tables configured (established 16384 bind 32768)
> NET: Registered protocol family 8
> NET: Registered protocol family 20
> ACPI: (supports S0 S1 S4 S5)
> ACPI wakeup devices:
> USB1 USB2 USB3 EHCI ICHB PS2M PS2K UAR1  MC9
> RAMDISK: cramfs filesystem found at block 0
> RAMDISK: Loading 4632KiB [1 disk] into ram disk... done.
> VFS: Mounted root (cramfs filesystem) readonly.
> Freeing unused kernel memory: 152k freed
> vesafb: probe of vesafb0 failed with error -6
> NET: Registered protocol family 1
> SCSI subsystem initialized
> libata version 1.02 loaded.
> Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
> ide: Assuming 33MHz system bus speed for PIO modes; override with idebu=
s=3Dxx
> ICH4: IDE controller at PCI slot 0000:00:1f.1
> ACPI: PCI interrupt 0000:00:1f.1[A] -> GSI 18 (level, low) -> IRQ 185
> ICH4: chipset revision 2
> ICH4: not 100% native mode: will probe irqs later
>     ide0: BM-DMA at 0xfc00-0xfc07, BIOS settings: hda:DMA, hdb:pio
>     ide1: BM-DMA at 0xfc08-0xfc0f, BIOS settings: hdc:DMA, hdd:pio
> Probing IDE interface ide0...
> hda: HDS728040PLAT20, ATA DISK drive
> Using anticipatory io scheduler
> ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
> hda: max request size: 1024KiB
> hda: 80418240 sectors (41174 MB) w/1719KiB Cache, CHS=3D16383/255/63,=20
> UDMA(33)
> hda: cache flushes supported
>  /dev/ide/host0/bus0/target0/lun0: p1 p2 p3 < p5 p6 > p4
> Probing IDE interface ide1...
> hdc: SAMSUNG CD-R/RW SW-252S, ATAPI CD/DVD-ROM drive
> ide1 at 0x170-0x177,0x376 on irq 15
> Probing IDE interface ide2...
> ide2: Wait for ready failed before probe !
> Probing IDE interface ide3...
> ide3: Wait for ready failed before probe !
> Probing IDE interface ide4...
> ide4: Wait for ready failed before probe !
> Probing IDE interface ide5...
> ide5: Wait for ready failed before probe !
> SGI XFS with ACLs, security attributes, realtime, large block numbers,=20
> no debug enabled
> SGI XFS Quota Management subsystem
> VFS: Can't find ext3 filesystem on dev hda5.
> VFS: Can't find ext2 filesystem on dev hda5.
> Unable to identify CD-ROM format.
> VFS: Can't find a romfs filesystem on dev hda5.
> ReiserFS: hda5: found reiserfs format "3.6" with standard journal
> ReiserFS: hda5: using ordered data mode
> ReiserFS: hda5: journal params: device hda5, size 8192, journal first=20
> block 18, max trans len 1024, max batch 900, max commit age 30, max=20
> trans age 30
> ReiserFS: hda5: checking transaction log (hda5)
> ReiserFS: hda5: Using r5 hash to sort names
> Adding 498004k swap on /dev/hda2.  Priority:-1 extents:1
> Real Time Clock Driver v1.12
> hdc: ATAPI 52X CD-ROM CD-R/RW drive, 2048kB Cache, UDMA(33)
> Uniform CD-ROM driver Revision: 3.20
> Capability LSM initialized
> cdrom: open failed.
> cdrom: open failed.
> cdrom: open failed.
> cdrom: open failed.
> FAT: bogus number of reserved sectors
> VFS: Can't find a valid FAT filesystem on dev hda6.
> ACPI: PCI interrupt 0000:00:1f.5[B] -> GSI 17 (level, low) -> IRQ 201
> PCI: Setting latency timer of device 0000:00:1f.5 to 64
> intel8x0_measure_ac97_clock: measured 49535 usecs
> intel8x0: clocking to 48000
> usbcore: registered new driver usbfs
> usbcore: registered new driver hub
> ACPI: PCI interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 193
> ehci_hcd 0000:00:1d.7: Intel Corp. 82801DB/DBM (ICH4/ICH4-M) USB 2.0=20
> EHCI Controller
> PCI: Setting latency timer of device 0000:00:1d.7 to 64
> ehci_hcd 0000:00:1d.7: irq 193, pci mem d017ec00
> ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
> PCI: cache line size of 128 is not supported by device 0000:00:1d.7
> ehci_hcd 0000:00:1d.7: USB 2.0 enabled, EHCI 1.00, driver 2004-May-10
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 6 ports detected
> sis900.c: v1.08.07 11/02/2003
> ACPI: PCI interrupt 0000:03:07.0[A] -> GSI 18 (level, low) -> IRQ 185
> eth0: No MII transceivers found!
> atmsvc: no signaling demon
> Linux agpgart interface v0.100 (c) Dave Jones
> agpgart: Detected an Intel 845G Chipset.
> agpgart: Maximum main memory to use for agp memory: 196M
> agpgart: Detected 8060K stolen memory.
> agpgart: AGP aperture is 128M @ 0xd0000000
> USB Universal Host Controller Interface driver v2.2
> ACPI: PCI interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) -> IRQ 169
> uhci_hcd 0000:00:1d.0: Intel Corp. 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M)=
=20
> USB UHCI Controller #1
> PCI: Setting latency timer of device 0000:00:1d.0 to 64
> uhci_hcd 0000:00:1d.0: irq 169, io base 0000e400
> uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
> hub 2-0:1.0: USB hub found
> hub 2-0:1.0: 2 ports detected
> ACPI: PCI interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 177
> uhci_hcd 0000:00:1d.1: Intel Corp. 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M)=
=20
> USB UHCI Controller #2
> PCI: Setting latency timer of device 0000:00:1d.1 to 64
> uhci_hcd 0000:00:1d.1: irq 177, io base 0000e800
> uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
> hub 3-0:1.0: USB hub found
> hub 3-0:1.0: 2 ports detected
> ACPI: PCI interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 185
> uhci_hcd 0000:00:1d.2: Intel Corp. 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M)=
=20
> USB UHCI Controller #3
> PCI: Setting latency timer of device 0000:00:1d.2 to 64
> uhci_hcd 0000:00:1d.2: irq 185, io base 0000ec00
> uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
> hub 4-0:1.0: USB hub found
> hub 4-0:1.0: 2 ports detected
> cpci_hotplug: CompactPCI Hot Plug Core version: 0.2
> pci_hotplug: PCI Hot Plug PCI Core version: 0.5
> shpchp: shpc_init : shpc_cap_offset =3D=3D 0
> shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
> pciehp: PCI Express Hot Plug Controller Driver version: 0.4
> hw_random hardware driver 1.0.0 loaded
> i8xx TCO timer: initialized (0x0860). heartbeat=3D30 sec (nowayout=3D0)
> parport: PnPBIOS parport detected.
> parport0: PC-style at 0x378 (0x778), irq 7, dma 3=20
> [PCSPP,TRISTATE,COMPAT,EPP,ECP,DMA]
> lp0: using parport0 (interrupt-driven).
> ehci_hcd 0000:00:1d.7: remove, state 1
> usb usb1: USB disconnect, address 1
> ehci_hcd 0000:00:1d.7: USB bus 1 deregistered
> uhci_hcd 0000:00:1d.0: remove, state 1
> usb usb2: USB disconnect, address 1
> uhci_hcd 0000:00:1d.0: USB bus 2 deregistered
> uhci_hcd 0000:00:1d.1: remove, state 1
> usb usb3: USB disconnect, address 1
> uhci_hcd 0000:00:1d.1: USB bus 3 deregistered
> uhci_hcd 0000:00:1d.2: remove, state 1
> usb usb4: USB disconnect, address 1
> uhci_hcd 0000:00:1d.2: USB bus 4 deregistered
> usbcore: deregistering driver usbfs
> usbcore: deregistering driver hub
> usbcore: registered new driver usbfs
> usbcore: registered new driver hub
> ACPI: PCI interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 193
> ehci_hcd 0000:00:1d.7: Intel Corp. 82801DB/DBM (ICH4/ICH4-M) USB 2.0=20
> EHCI Controller
> PCI: Setting latency timer of device 0000:00:1d.7 to 64
> ehci_hcd 0000:00:1d.7: irq 193, pci mem d026ac00
> ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
> PCI: cache line size of 128 is not supported by device 0000:00:1d.7
> ehci_hcd 0000:00:1d.7: USB 2.0 enabled, EHCI 1.00, driver 2004-May-10
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 6 ports detected
> ohci_hcd: 2004 Feb 02 USB 1.1 'Open' Host Controller (OHCI) Driver (PCI=
)
> USB Universal Host Controller Interface driver v2.2
> ACPI: PCI interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) -> IRQ 169
> uhci_hcd 0000:00:1d.0: Intel Corp. 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M)=
=20
> USB UHCI Controller #1
> PCI: Setting latency timer of device 0000:00:1d.0 to 64
> uhci_hcd 0000:00:1d.0: irq 169, io base 0000e400
> uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
> hub 2-0:1.0: USB hub found
> hub 2-0:1.0: 2 ports detected
> ACPI: PCI interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 177
> uhci_hcd 0000:00:1d.1: Intel Corp. 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M)=
=20
> USB UHCI Controller #2
> PCI: Setting latency timer of device 0000:00:1d.1 to 64
> uhci_hcd 0000:00:1d.1: irq 177, io base 0000e800
> uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
> hub 3-0:1.0: USB hub found
> hub 3-0:1.0: 2 ports detected
> ACPI: PCI interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 185
> uhci_hcd 0000:00:1d.2: Intel Corp. 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M)=
=20
> USB UHCI Controller #3
> PCI: Setting latency timer of device 0000:00:1d.2 to 64
> uhci_hcd 0000:00:1d.2: irq 185, io base 0000ec00
> uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
> hub 4-0:1.0: USB hub found
> hub 4-0:1.0: 2 ports detected
> input: ImPS/2 Generic Wheel Mouse on isa0060/serio1
> ts: Compaq touchscreen protocol output
> mice: PS/2 mouse device common for all mice
> sis900.c: v1.08.07 11/02/2003
> ACPI: PCI interrupt 0000:03:07.0[A] -> GSI 18 (level, low) -> IRQ 185
> eth0: No MII transceivers found!
> R_xart:~# ifconfig eth0 up
> eth0: ERROR while getting interface flags: No existe tal dispositivo
> R_xart:~# mii-tool -vv
> Using SIOCGMIIPHY=3D0x8947
> no MII interfaces found
>=20
> R_xart:~# lspci
> 0000:00:00.0 Host bridge: Intel Corp. 82845G/GL[Brookdale-G]/GE/PE DRAM=
=20
> Controller/Host-Hub Interface (rev 03)
> 0000:00:02.0 VGA compatible controller: Intel Corp.=20
> 82845G/GL[Brookdale-G]/GE Chipset Integrated Graphics Device (rev 03)
> 0000:00:1d.0 USB Controller: Intel Corp. 82801DB (ICH4) USB UHCI #1 (re=
v=20
> 02)
> 0000:00:1d.1 USB Controller: Intel Corp. 82801DB (ICH4) USB UHCI #2 (re=
v=20
> 02)
> 0000:00:1d.2 USB Controller: Intel Corp. 82801DB (ICH4) USB UHCI #3 (re=
v=20
> 02)
> 0000:00:1d.7 USB Controller: Intel Corp. 82801DB (ICH4) USB2 EHCI=20
> Controller (rev 02)
> 0000:00:1e.0 PCI bridge: Intel Corp. 82801BA/CA/DB/EB/ER Hub interface=20
> to PCI Bridge (rev 82)
> 0000:00:1f.0 ISA bridge: Intel Corp. 82801DB (ICH4) LPC Bridge (rev 02)
> 0000:00:1f.1 IDE interface: Intel Corp. 82801DB (ICH4) Ultra ATA 100=20
> Storage Controller (rev 02)
> 0000:00:1f.5 Multimedia audio controller: Intel Corp. 82801DB (ICH4)=20
> AC'97 Audio Controller (rev 02)
> 0000:03:03.0 Modem: PCTel Inc: Unknown device 2189 (rev 04)
> 0000:03:07.0 Ethernet controller: Silicon Integrated Systems [SiS]=20
> SiS900 PCI Fast Ethernet (rev 02)
>=20
> R_xart:~# lspci -n -vv
> 0000:00:00.0 Class 0600: 8086:2560 (rev 03)
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-=20
> ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort=
-=20
> <TAbort- <MAbort+ >SERR- <PERR-
>         Latency: 0
>         Region 0: Memory at e0000000 (32-bit, prefetchable)
>         Capabilities: [e4] #09 [1105]
>=20
> 0000:00:02.0 Class 0300: 8086:2562 (rev 03)
>         Subsystem: 8086:2562
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-=20
> ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort=
-=20
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 169
>         Region 0: Memory at d0000000 (32-bit, prefetchable)
>         Region 1: Memory at dff80000 (32-bit, non-prefetchable) [size=3D=
512K]
>         Capabilities: [d0] Power Management version 1
>                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA=20
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>=20
> 0000:00:1d.0 Class 0c03: 8086:24c2 (rev 02)
>         Subsystem: 8086:24c0
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-=20
> ParErr- Stepping- SERR- FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbo=
rt-=20
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 169
>         Region 4: I/O ports at e400 [size=3D32]
>=20
> 0000:00:1d.1 Class 0c03: 8086:24c4 (rev 02)
>         Subsystem: 8086:24c0
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-=20
> ParErr- Stepping- SERR- FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbo=
rt-=20
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin B routed to IRQ 177
>         Region 4: I/O ports at e800 [size=3D32]
>=20
> 0000:00:1d.2 Class 0c03: 8086:24c7 (rev 02)
>         Subsystem: 8086:24c0
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-=20
> ParErr- Stepping- SERR- FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbo=
rt-=20
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin C routed to IRQ 185
>         Region 4: I/O ports at ec00 [size=3D32]
>=20
> 0000:00:1d.7 Class 0c03: 8086:24cd (rev 02) (prog-if 20)
>         Subsystem: 8086:24c0
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-=20
> ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbo=
rt-=20
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin D routed to IRQ 193
>         Region 0: Memory at dff7bc00 (32-bit, non-prefetchable)
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D375mA=20
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>         Capabilities: [58] #0a [2080]
>=20
> 0000:00:1e.0 Class 0604: 8086:244e (rev 82)
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-=20
> ParErr- Stepping- SERR+ FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort=
-=20
> <TAbort- <MAbort- >SERR- <PERR+
>         Latency: 0
>         Bus: primary=3D00, secondary=3D03, subordinate=3D03, sec-latenc=
y=3D32
>         I/O behind bridge: 0000c000-0000cfff
>         Memory behind bridge: dfd00000-dfdfffff
>         BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
>=20
> 0000:00:1f.0 Class 0601: 8086:24c0 (rev 02)
>         Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop-=20
> ParErr- Stepping- SERR- FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbo=
rt-=20
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>=20
> 0000:00:1f.1 Class 0101: 8086:24cb (rev 02) (prog-if 8a [Master SecP Pr=
iP])
>         Subsystem: 8086:24c0
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-=20
> ParErr- Stepping- SERR- FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbo=
rt-=20
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 185
>         Region 0: I/O ports at <unassigned>
>         Region 1: I/O ports at <unassigned>
>         Region 2: I/O ports at <unassigned>
>         Region 3: I/O ports at <unassigned>
>         Region 4: I/O ports at fc00 [size=3D16]
>         Region 5: Memory at 10000000 (32-bit, non-prefetchable) [size=3D=
1K]
>=20
> 0000:00:1f.5 Class 0401: 8086:24c5 (rev 02)
>         Subsystem: 1019:a00a
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-=20
> ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbo=
rt-=20
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin B routed to IRQ 201
>         Region 0: I/O ports at e000
>         Region 1: I/O ports at dc00 [size=3D64]
>         Region 2: Memory at dff7ba00 (32-bit, non-prefetchable) [size=3D=
512]
>         Region 3: Memory at dff7b900 (32-bit, non-prefetchable) [size=3D=
256]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D375mA=20
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>=20
> 0000:03:03.0 Class 0703: 134d:2189 (rev 04)
>         Subsystem: 134d:1002
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-=20
> ParErr- Stepping+ SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbo=
rt-=20
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32 (250ns min, 15500ns max), Cache Line Size: 0x08 (32=
=20
> bytes)
>         Interrupt: pin A routed to IRQ 193
>         Region 0: Memory at dfdff000 (32-bit, non-prefetchable)
>         Region 1: I/O ports at cc00 [size=3D256]
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D55mA=20
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>=20
> 0000:03:07.0 Class 0200: 1039:0900 (rev 02)
>         Subsystem: 1039:0900
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-=20
> ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbo=
rt-=20
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 32 (13000ns min, 2750ns max)
>         Interrupt: pin A routed to IRQ 185
>         Region 0: I/O ports at c800 [size=3Ddfdc0000]
>         Region 1: Memory at dfdfe000 (32-bit, non-prefetchable) [size=3D=
4K]
>         Expansion ROM at 00020000 [disabled]
>         Capabilities: [40] Power Management version 1
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA=20
> PME(D0+,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
>=20
> R_xart:~#
> R_xart:~# uname -a
> Linux R_xart 2.6.9-1-686 #1 Tue Nov 16 17:52:21 JST 2004 i686 GNU/Linux
>=20
>=20


--=20
----------------------------------------------------------
Iouri Atiounkine
Buenos Aires, Argentina

--------------070707060004000104010108
Content-Type: text/plain;
 name="dmesg-good.txt"
Content-Disposition: inline;
 filename="dmesg-good.txt"
Content-Transfer-Encoding: 7bit

000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000ffb00000 - 00000000ffc00000 (reserved)
 BIOS-e820: 00000000fff00000 - 0000000100000000 (reserved)
0MB HIGHMEM available.
247MB LOWMEM available.
found SMP MP-table at 000fb960
On node 0 totalpages: 63472
  DMA zone: 4096 pages, LIFO batch:1
  Normal zone: 59376 pages, LIFO batch:14
  HighMem zone: 0 pages, LIFO batch:1
DMI 2.3 present.
ACPI: RSDP (v000 AMI                                   ) @ 0x000fa000
ACPI: RSDT (v001 AMIINT INTEL845 0x00000010 MSFT 0x00000097) @ 0x0f7f0000
ACPI: FADT (v001 AMIINT INTEL845 0x00000011 MSFT 0x00000097) @ 0x0f7f0030
ACPI: MADT (v001 AMIINT INTEL845 0x00000009 MSFT 0x00000097) @ 0x0f7f00c0
ACPI: DSDT (v001  INTEL BROKDLEG 0x00001000 MSFT 0x0100000d) @ 0x00000000
ACPI: PM-Timer IO Port: 0x808
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
Processor #0 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] disabled)
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Enabling APIC mode:  Flat.  Using 1 I/O APICs
Using ACPI (MADT) for SMP configuration information
Built 1 zonelists
Kernel command line: root=/dev/hda5 ro 
Initializing CPU#0
PID hash table entries: 1024 (order: 10, 16384 bytes)
Detected 1799.435 MHz processor.
Using pmtmr for high-res timesource
Console: colour VGA+ 80x25
Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
Memory: 243616k/253888k available (1654k kernel code, 9600k reserved, 723k data, 152k init, 0k highmem)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay loop... 3563.52 BogoMIPS (lpj=1781760)
Security Scaffold v1.0.0 initialized
SELinux:  Disabled at boot.
Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000
CPU: After vendor identify, caps:  bfebfbff 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 128K
CPU: After all inits, caps:        bfebfbff 00000000 00000000 00000080
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU0: Intel P4/Xeon Extended MCE MSRs (12) available
CPU0: Thermal monitoring enabled
CPU: Intel(R) Celeron(R) CPU 1.80GHz stepping 09
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Checking 'hlt' instruction... OK.
ENABLING IO-APIC IRQs
..TIMER: vector=0x31 pin1=2 pin2=-1
checking if image is initramfs...it isn't (ungzip failed); looks like an initrd
Freeing initrd memory: 4632k freed
NET: Registered protocol family 16
PCI: PCI BIOS revision 2.10 entry at 0xfdb81, last bus=3
PCI: Using configuration type 1
mtrr: v2.0 (20020519)
ACPI: Subsystem revision 20040816
ACPI: Interpreter enabled
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (00:00)
PCI: Probing PCI hardware (bus 00)
PCI: Ignoring BAR0-3 of IDE controller 0000:00:1f.1
PCI: Transparent bridge - 0000:00:1e.0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.ICHB._PRT]
ACPI: Power Resource [URP1] (off)
ACPI: Power Resource [URP2] (off)
ACPI: Power Resource [FDDP] (off)
ACPI: Power Resource [LPTP] (off)
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 *5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs *3 4 5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 *10 11 12 14 15)
Linux Plug and Play Support v0.97 (c) Adam Belay
PnPBIOS: Scanning system for PnP BIOS support...
PnPBIOS: Found PnP BIOS installation structure at 0xc00f7330
PnPBIOS: PnP BIOS version 1.0, entry 0xf0000:0x600b, dseg 0xf0000
PnPBIOS: Missing SMALL_TAG_ENDDEP tag
PnPBIOS: Missing SMALL_TAG_ENDDEP tag
PnPBIOS: Missing SMALL_TAG_ENDDEP tag
PnPBIOS: Missing SMALL_TAG_ENDDEP tag
PnPBIOS: 13 nodes reported by PnP BIOS; 13 recorded by driver
PCI: Using ACPI for IRQ routing
ACPI: PCI interrupt 0000:00:02.0[A] -> GSI 16 (level, low) -> IRQ 169
ACPI: PCI interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) -> IRQ 169
ACPI: PCI interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 177
ACPI: PCI interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 185
ACPI: PCI interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 193
ACPI: PCI interrupt 0000:00:1f.1[A] -> GSI 18 (level, low) -> IRQ 185
ACPI: PCI interrupt 0000:00:1f.5[B] -> GSI 17 (level, low) -> IRQ 201
ACPI: PCI interrupt 0000:03:03.0[A] -> GSI 23 (level, low) -> IRQ 193
ACPI: PCI interrupt 0000:03:07.0[A] -> GSI 18 (level, low) -> IRQ 185
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
devfs: 2004-01-31 Richard Gooch (rgooch@atnf.csiro.au)
devfs: boot_options: 0x0
Initializing Cryptographic API
isapnp: Scanning for PnP cards...
isapnp: No Plug & Play device found
serio: i8042 AUX port at 0x60,0x64 irq 12
serio: i8042 KBD port at 0x60,0x64 irq 1
Serial: 8250/16550 driver $Revision: 1.90 $ 48 ports, IRQ sharing enabled
ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
ACPI: PCI interrupt 0000:03:03.0[A] -> GSI 23 (level, low) -> IRQ 193
ttyS15 at I/O 0xcc08 (irq = 193) is a 16450
ttyS44 at I/O 0xcc10 (irq = 193) is a 8250
ttyS45 at I/O 0xcc18 (irq = 193) is a 16450
ttyS46 at I/O 0xcc20 (irq = 193) is a 8250
ttyS47 at I/O 0xcc28 (irq = 193) is a 8250
RAMDISK driver initialized: 16 RAM disks of 8192K size 1024 blocksize
input: AT Translated Set 2 keyboard on isa0060/serio0
NET: Registered protocol family 2
IP: routing cache hash table of 2048 buckets, 16Kbytes
TCP: Hash tables configured (established 16384 bind 32768)
NET: Registered protocol family 8
NET: Registered protocol family 20
ACPI: (supports S0 S1 S4 S5)
ACPI wakeup devices: 
USB1 USB2 USB3 EHCI ICHB PS2M PS2K UAR1  MC9 
RAMDISK: cramfs filesystem found at block 0
RAMDISK: Loading 4632KiB [1 disk] into ram disk... |/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/done.
VFS: Mounted root (cramfs filesystem) readonly.
Freeing unused kernel memory: 152k freed
vesafb: probe of vesafb0 failed with error -6
NET: Registered protocol family 1
SCSI subsystem initialized
libata version 1.02 loaded.
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
ICH4: IDE controller at PCI slot 0000:00:1f.1
ACPI: PCI interrupt 0000:00:1f.1[A] -> GSI 18 (level, low) -> IRQ 185
ICH4: chipset revision 2
ICH4: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0xfc00-0xfc07, BIOS settings: hda:DMA, hdb:pio
    ide1: BM-DMA at 0xfc08-0xfc0f, BIOS settings: hdc:DMA, hdd:pio
Probing IDE interface ide0...
hda: HDS728040PLAT20, ATA DISK drive
Using anticipatory io scheduler
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
hda: max request size: 1024KiB
hda: 80418240 sectors (41174 MB) w/1719KiB Cache, CHS=16383/255/63, UDMA(33)
hda: cache flushes supported
 /dev/ide/host0/bus0/target0/lun0: p1 p2 p3 < p5 p6 > p4
Probing IDE interface ide1...
hdc: SAMSUNG CD-R/RW SW-252S, ATAPI CD/DVD-ROM drive
ide1 at 0x170-0x177,0x376 on irq 15
Probing IDE interface ide2...
ide2: Wait for ready failed before probe !
Probing IDE interface ide3...
ide3: Wait for ready failed before probe !
Probing IDE interface ide4...
ide4: Wait for ready failed before probe !
Probing IDE interface ide5...
ide5: Wait for ready failed before probe !
SGI XFS with ACLs, security attributes, realtime, large block numbers, no debug enabled
SGI XFS Quota Management subsystem
VFS: Can't find ext3 filesystem on dev hda5.
VFS: Can't find ext2 filesystem on dev hda5.
Unable to identify CD-ROM format.
VFS: Can't find a romfs filesystem on dev hda5.
ReiserFS: hda5: found reiserfs format "3.6" with standard journal
ReiserFS: hda5: using ordered data mode
ReiserFS: hda5: journal params: device hda5, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
ReiserFS: hda5: checking transaction log (hda5)
ReiserFS: hda5: Using r5 hash to sort names
Adding 498004k swap on /dev/hda2.  Priority:-1 extents:1
Real Time Clock Driver v1.12
hdc: ATAPI 52X CD-ROM CD-R/RW drive, 2048kB Cache, UDMA(33)
Uniform CD-ROM driver Revision: 3.20
Capability LSM initialized
cdrom: open failed.
cdrom: open failed.
cdrom: open failed.
cdrom: open failed.
FAT: bogus number of reserved sectors
VFS: Can't find a valid FAT filesystem on dev hda6.
ACPI: PCI interrupt 0000:00:1f.5[B] -> GSI 17 (level, low) -> IRQ 201
PCI: Setting latency timer of device 0000:00:1f.5 to 64
intel8x0_measure_ac97_clock: measured 49529 usecs
intel8x0: clocking to 48000
usbcore: registered new driver usbfs
usbcore: registered new driver hub
ACPI: PCI interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 193
ehci_hcd 0000:00:1d.7: Intel Corp. 82801DB/DBM (ICH4/ICH4-M) USB 2.0 EHCI Controller
PCI: Setting latency timer of device 0000:00:1d.7 to 64
ehci_hcd 0000:00:1d.7: irq 193, pci mem d017ec00
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
PCI: cache line size of 128 is not supported by device 0000:00:1d.7
ehci_hcd 0000:00:1d.7: USB 2.0 enabled, EHCI 1.00, driver 2004-May-10
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
sis900.c: v1.08.07 11/02/2003
ACPI: PCI interrupt 0000:03:07.0[A] -> GSI 18 (level, low) -> IRQ 185
eth0: SiS 900 Internal MII PHY transceiver found at address 1.
eth0: Using transceiver found at address 1 as default
eth0: SiS 900 PCI Fast Ethernet at 0xc800, IRQ 185, 00:11:5b:22:e2:dd.
atmsvc: no signaling demon
Linux agpgart interface v0.100 (c) Dave Jones
agpgart: Detected an Intel 845G Chipset.
agpgart: Maximum main memory to use for agp memory: 196M
agpgart: Detected 8060K stolen memory.
agpgart: AGP aperture is 128M @ 0xd0000000
USB Universal Host Controller Interface driver v2.2
ACPI: PCI interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) -> IRQ 169
uhci_hcd 0000:00:1d.0: Intel Corp. 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M) USB UHCI Controller #1
PCI: Setting latency timer of device 0000:00:1d.0 to 64
uhci_hcd 0000:00:1d.0: irq 169, io base 0000e400
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ACPI: PCI interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 177
uhci_hcd 0000:00:1d.1: Intel Corp. 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M) USB UHCI Controller #2
PCI: Setting latency timer of device 0000:00:1d.1 to 64
uhci_hcd 0000:00:1d.1: irq 177, io base 0000e800
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
ACPI: PCI interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 185
uhci_hcd 0000:00:1d.2: Intel Corp. 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M) USB UHCI Controller #3
PCI: Setting latency timer of device 0000:00:1d.2 to 64
uhci_hcd 0000:00:1d.2: irq 185, io base 0000ec00
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
cpci_hotplug: CompactPCI Hot Plug Core version: 0.2
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
shpchp: shpc_init : shpc_cap_offset == 0
shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
pciehp: PCI Express Hot Plug Controller Driver version: 0.4
hw_random hardware driver 1.0.0 loaded
i8xx TCO timer: initialized (0x0860). heartbeat=30 sec (nowayout=0)
eth0: Media Link On 100mbps full-duplex 
parport: PnPBIOS parport detected.
parport0: PC-style at 0x378 (0x778), irq 7, dma 3 [PCSPP,TRISTATE,COMPAT,EPP,ECP,DMA]
lp0: using parport0 (interrupt-driven).
ehci_hcd 0000:00:1d.7: remove, state 1
usb usb1: USB disconnect, address 1
ehci_hcd 0000:00:1d.7: USB bus 1 deregistered
uhci_hcd 0000:00:1d.0: remove, state 1
usb usb2: USB disconnect, address 1
uhci_hcd 0000:00:1d.0: USB bus 2 deregistered
uhci_hcd 0000:00:1d.1: remove, state 1
usb usb3: USB disconnect, address 1
uhci_hcd 0000:00:1d.1: USB bus 3 deregistered
uhci_hcd 0000:00:1d.2: remove, state 1
usb usb4: USB disconnect, address 1
uhci_hcd 0000:00:1d.2: USB bus 4 deregistered
usbcore: deregistering driver usbfs
usbcore: deregistering driver hub
usbcore: registered new driver usbfs
usbcore: registered new driver hub
ACPI: PCI interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 193
ehci_hcd 0000:00:1d.7: Intel Corp. 82801DB/DBM (ICH4/ICH4-M) USB 2.0 EHCI Controller
PCI: Setting latency timer of device 0000:00:1d.7 to 64
ehci_hcd 0000:00:1d.7: irq 193, pci mem d026ac00
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
PCI: cache line size of 128 is not supported by device 0000:00:1d.7
ehci_hcd 0000:00:1d.7: USB 2.0 enabled, EHCI 1.00, driver 2004-May-10
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
ohci_hcd: 2004 Feb 02 USB 1.1 'Open' Host Controller (OHCI) Driver (PCI)
USB Universal Host Controller Interface driver v2.2
ACPI: PCI interrupt 0000:00:1d.0[A] -> GSI 16 (level, low) -> IRQ 169
uhci_hcd 0000:00:1d.0: Intel Corp. 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M) USB UHCI Controller #1
PCI: Setting latency timer of device 0000:00:1d.0 to 64
uhci_hcd 0000:00:1d.0: irq 169, io base 0000e400
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ACPI: PCI interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 177
uhci_hcd 0000:00:1d.1: Intel Corp. 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M) USB UHCI Controller #2
PCI: Setting latency timer of device 0000:00:1d.1 to 64
uhci_hcd 0000:00:1d.1: irq 177, io base 0000e800
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
ACPI: PCI interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 185
uhci_hcd 0000:00:1d.2: Intel Corp. 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M) USB UHCI Controller #3
PCI: Setting latency timer of device 0000:00:1d.2 to 64
uhci_hcd 0000:00:1d.2: irq 185, io base 0000ec00
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
input: ImPS/2 Generic Wheel Mouse on isa0060/serio1
ts: Compaq touchscreen protocol output
mice: PS/2 mouse device common for all mice
NET: Registered protocol family 17
NET: Registered protocol family 10
Disabled Privacy Extensions on device c0322340(lo)
IPv6 over IPv4 tunneling driver
eth0: no IPv6 routers present

--------------070707060004000104010108
Content-Type: text/plain;
 name="mii-tool-vv-good.txt"
Content-Disposition: inline;
 filename="mii-tool-vv-good.txt"
Content-Transfer-Encoding: 7bit

Using SIOCGMIIPHY=0x8947
eth0: negotiated 100baseTx-FD, link ok
  registers for MII PHY 1: 
    1000 782d 001d 8000 01e1 45e1 0000 0000
    0000 0000 0000 0000 0000 0000 0000 0000
    0022 ff00 00d0 ffc0 0020 0000 0000 0000
    0000 0000 0000 0000 0000 0000 0000 0000
  product info: vendor 00:07:60, model 0 rev 0
  basic mode:   autonegotiation enabled
  basic status: autonegotiation complete, link ok
  capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  link partner: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control

--------------070707060004000104010108--
