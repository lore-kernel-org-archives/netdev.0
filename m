From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: 2.6.32: padlock_sha1 and hmac broken?
Date: Sat, 30 Jan 2010 17:34:45 +0100
Message-ID: <201001301734.46003.wolfgang.walter@stwm.de>
References: <201001300044.15769.wolfgang.walter@stwm.de> <20100130022721.GA8324@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:44660 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753894Ab0A3Qet convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jan 2010 11:34:49 -0500
In-Reply-To: <20100130022721.GA8324@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Samstag, 30. Januar 2010 schrieben Sie:
> On Sat, Jan 30, 2010 at 12:44:15AM +0100, Wolfgang Walter wrote:
> > Hello,
> >
> > I upgraded some machines with VIA processors from (vanilla) 2.6.31 =
to
> > 2.6.32.7.
> >
> > If I build the kernel 2.6.32.7 with CONFIG_CRYPTO_DEV_PADLOCK_SHA=3D=
y and
> > padlock supports sha, hmac(sha1) is missing and IPSEC with hmac(sha=
1) no
> > longer is possible.
>
> Can you please attach the dmesg output so we can see if there
> were any error messages?

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
E# disabled
[    0.144494] HPET not enabled in BIOS. You might try hpet=3Dforce boo=
t option
[    0.144634] pci 0000:00:11.5: reg 10 io port: [0xec00-0xecff]
[    0.144698] pci 0000:00:11.5: supports D1 D2
[    0.144787] pci 0000:01:00.0: reg 10 32bit mmio pref: [0xf4000000-0x=
f7ffffff]
[    0.144803] pci 0000:01:00.0: reg 14 32bit mmio: [0xfb000000-0xfbfff=
fff]
[    0.144835] pci 0000:01:00.0: reg 30 32bit mmio pref: [0x000000-0x00=
ffff]
[    0.144865] pci 0000:01:00.0: supports D1 D2
[    0.144921] pci 0000:00:01.0: bridge io port: [0xd000-0xdfff]
[    0.144933] pci 0000:00:01.0: bridge 32bit mmio: [0xfb000000-0xfcfff=
fff]
[    0.144946] pci 0000:00:01.0: bridge 32bit mmio pref: [0xf4000000-0x=
f7ffffff]
[    0.144965] pci_bus 0000:00: on NUMA node 0
[    0.144985] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.327624] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 6 7 10 11 12) =
*5
[    0.328584] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 6 7 10 *11 12)
[    0.329501] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 6 7 *10 11 12)
[    0.330402] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 6 7 10 11 12) =
*0, disabled.
[    0.331336] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 6 7 10 11 12) =
*0, disabled.
[    0.332247] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 6 7 10 11 12) =
*0, disabled.
[    0.333159] ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 6 7 10 11 12) =
*0, disabled.
[    0.334095] ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 6 7 10 11 12) =
*0, disabled.
[    0.335140] ACPI: PCI Interrupt Link [ALKA] (IRQs *20)
[    0.335828] ACPI: PCI Interrupt Link [ALKB] (IRQs *21)
[    0.336519] ACPI: PCI Interrupt Link [ALKC] (IRQs *22)
[    0.337280] ACPI: PCI Interrupt Link [ALKD] (IRQs *23), disabled.
[    0.337998] vgaarb: device added: PCI:0000:01:00.0,decodes=3Dio+mem,=
owns=3Dio+mem,locks=3Dnone
[    0.338080] vgaarb: loaded
[    0.338528] SCSI subsystem initialized
[    0.338658] libata version 3.00 loaded.
[    0.339062] usbcore: registered new interface driver usbfs
[    0.339205] usbcore: registered new interface driver hub
[    0.339364] usbcore: registered new device driver usb
[    0.339798] PCI: Using ACPI for IRQ routing
[    0.340410] Switching to clocksource tsc
[    0.340531] pnp: PnP ACPI init
[    0.340606] ACPI: bus type pnp registered
[    0.354181] pnp: PnP ACPI: found 11 devices
[    0.354252] ACPI: ACPI bus type pnp unregistered
[    0.354343] system 00:00: iomem range 0xf0000-0xfffff could not be r=
eserved
[    0.354415] system 00:00: iomem range 0x1eee0000-0x1eefffff could no=
t be reserved
[    0.354496] system 00:00: iomem range 0xffff0000-0xffffffff has been=
 reserved
[    0.354568] system 00:00: iomem range 0x0-0x9ffff could not be reser=
ved
[    0.354638] system 00:00: iomem range 0x100000-0x1eedffff could not =
be reserved
[    0.354717] system 00:00: iomem range 0xfec00000-0xfec00fff could no=
t be reserved
[    0.354797] system 00:00: iomem range 0xfee00000-0xfee00fff has been=
 reserved
[    0.354869] system 00:00: iomem range 0xfff80000-0xfffeffff has been=
 reserved
[    0.354951] system 00:02: ioport range 0x400-0x47f has been reserved
[    0.355020] system 00:02: ioport range 0x500-0x50f has been reserved
[    0.355131] system 00:03: ioport range 0x4d0-0x4d1 has been reserved
[    0.355200] system 00:03: ioport range 0x800-0x87f has been reserved
[    0.355269] system 00:03: ioport range 0x880-0x8ff has been reserved
[    0.391005] pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
[    0.391081] pci 0000:00:01.0:   IO window: 0xd000-0xdfff
[    0.391151] pci 0000:00:01.0:   MEM window: 0xfb000000-0xfcffffff
[    0.391222] pci 0000:00:01.0:   PREFETCH window: 0xf4000000-0xf7ffff=
ff
[    0.391311] pci 0000:00:01.0: setting latency timer to 64
[    0.391326] pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
[    0.391337] pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffff]
[    0.391348] pci_bus 0000:01: resource 0 io:  [0xd000-0xdfff]
[    0.391359] pci_bus 0000:01: resource 1 mem: [0xfb000000-0xfcffffff]
[    0.391370] pci_bus 0000:01: resource 2 pref mem [0xf4000000-0xf7fff=
fff]
[    0.391471] NET: Registered protocol family 2
[    0.391849] IP route cache hash table entries: 4096 (order: 2, 16384=
 bytes)
[    0.392765] TCP established hash table entries: 16384 (order: 5, 131=
072 bytes)
[    0.393170] TCP bind hash table entries: 16384 (order: 4, 65536 byte=
s)
[    0.394127] TCP: Hash tables configured (established 16384 bind 1638=
4)
[    0.394195] TCP reno registered
[    0.394459] NET: Registered protocol family 1
[    0.394579] pci 0000:00:01.0: disabling DAC on VIA PCI bridge
[    0.394773] pci 0000:00:11.0: Bypassing VIA 8237 APIC De-Assert Mess=
age
[    0.394853] pci 0000:01:00.0: Boot video device
[    0.394985] Trying to unpack rootfs image as initramfs...
[    0.397158] rootfs image is not initramfs (no cpio magic); looks lik=
e an initrd
[    0.583043] Freeing initrd memory: 42677k freed
[    0.657473] cpufreq-nforce2: No nForce2 chipset.
[    0.667097] msgmni has been set to 970
[    0.667379] alg: No test for cipher_null (cipher_null-generic)
[    0.667498] alg: No test for ecb(cipher_null) (ecb-cipher_null)
[    0.667610] alg: No test for digest_null (digest_null-generic)
[    0.667718] alg: No test for compress_null (compress_null-generic)
[    0.670760] alg: No test for fcrypt (fcrypt-generic)
[    0.679058] alg: No test for stdrng (krng)
[    0.716094] alg: No test for ghash (ghash-generic)
[    0.716212] io scheduler noop registered
[    0.716272] io scheduler anticipatory registered
[    0.716334] io scheduler deadline registered
[    0.716680] io scheduler cfq registered (default)
[    0.717179] fan PNP0C0B:00: registered as cooling_device0
[    0.717255] ACPI: Fan [FAN] (on)
[    0.717565] processor LNXCPU:00: registered as cooling_device1
[    0.719182] thermal LNXTHERM:01: registered as thermal_zone0
[    0.719267] ACPI: Thermal Zone [THRM] (-248 C)
[    0.727205] Real Time Clock Driver v1.12b
[    0.727761] VIA RNG detected
[    0.727936] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    0.728201] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[    0.728473] serial8250: ttyS1 at I/O 0x2f8 (irq =3D 3) is a 16550A
[    0.729423] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[    0.729847] 00:09: ttyS1 at I/O 0x2f8 (irq =3D 3) is a 16550A
[    0.734418] brd: module loaded
[    0.736455] loop: module loaded
[    0.737003] sata_via 0000:00:0f.0: version 2.4
[    0.737729] ACPI: PCI Interrupt Link [ALKA] enabled at IRQ 20
[    0.737818] sata_via 0000:00:0f.0: PCI INT B -> Link[ALKA] -> GSI 20=
 (level, low) -> IRQ 20
[    0.737980] sata_via 0000:00:0f.0: routed to hard irq line 11
[    0.738200] scsi0 : sata_via
[    0.738633] scsi1 : sata_via
[    0.743265] ata1: SATA max UDMA/133 cmd 0xff00 ctl 0xfe00 bmdma 0xfb=
00 irq 20
[    0.743344] ata2: SATA max UDMA/133 cmd 0xfd00 ctl 0xfc00 bmdma 0xfb=
08 irq 20
[    0.744718] pata_via 0000:00:0f.1: version 0.3.4
[    0.744767] pata_via 0000:00:0f.1: PCI INT A -> Link[ALKA] -> GSI 20=
 (level, low) -> IRQ 20
[    0.745103] scsi2 : pata_via
[    0.745412] scsi3 : pata_via
[    0.749245] ata3: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xfa00=
 irq 14
[    0.749322] ata4: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xfa08=
 irq 15
[    0.751538] Intel(R) PRO/1000 Network Driver - version 7.3.21-k5-NAP=
I
[    0.751614] Copyright (c) 1999-2006 Intel Corporation.
[    0.751788] e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
[    0.751854] e1000e: Copyright (c) 1999-2008 Intel Corporation.
[    0.752023] Intel(R) Gigabit Ethernet Network Driver - version 1.3.1=
6-k2
[    0.752091] Copyright (c) 2007-2009 Intel Corporation.
[    0.752247] Ethernet Channel Bonding Driver: v3.5.0 (November 4, 200=
8)
[    0.752318] bonding: Warning: either miimon or arp_interval and arp_=
ip_target module parameters must be=20
specified, otherwise bonding will not detect link failures! see bonding=
=2Etxt for details.
[    0.753414] Atheros(R) L2 Ethernet Driver - version 2.2.3
[    0.753481] Copyright (c) 2007 Atheros Corporation.
[    0.753651] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    0.753717] e100: Copyright(c) 1999-2006 Intel Corporation
[    0.754053] via-rhine: Broken BIOS detected, avoid_D3 enabled.
[    0.754409] PPP generic driver version 2.4.2
[    0.754714] PPP Deflate Compression module registered
[    0.754779] NET: Registered protocol family 24
[    0.754865] PPPoL2TP kernel driver, V1.0
[    0.755766] 8139too Fast Ethernet driver 0.9.28
[    0.755863] 8139too 0000:00:05.0: PCI INT A -> GSI 16 (level, low) -=
> IRQ 16
[    0.757379] eth0: RealTek RTL8139 at 0xdf7d2000, 00:30:18:4c:69:5f, =
IRQ 16
[    0.757495] 8139too 0000:00:06.0: PCI INT A -> GSI 17 (level, low) -=
> IRQ 17
[    0.758684] eth1: RealTek RTL8139 at 0xdf7d6000, 00:30:18:4c:69:5e, =
IRQ 17
[    0.758785] 8139too 0000:00:07.0: PCI INT A -> GSI 18 (level, low) -=
> IRQ 18
[    0.760026] eth2: RealTek RTL8139 at 0xdf7da000, 00:30:18:4c:69:5d, =
IRQ 18
[    0.760197] tun: Universal TUN/TAP device driver, 1.6
[    0.760260] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    0.761031] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driv=
er
[    0.761857] ACPI: PCI Interrupt Link [ALKB] enabled at IRQ 21
[    0.761940] ehci_hcd 0000:00:10.4: PCI INT C -> Link[ALKB] -> GSI 21=
 (level, low) -> IRQ 21
[    0.762052] ehci_hcd 0000:00:10.4: EHCI Host Controller
[    0.762355] ehci_hcd 0000:00:10.4: new USB bus registered, assigned =
bus number 1
[    0.762532] ehci_hcd 0000:00:10.4: irq 21, io mem 0xfdffc000
[    0.769490] ehci_hcd 0000:00:10.4: USB 2.0 started, EHCI 1.00
[    0.769830] usb usb1: configuration #1 chosen from 1 choice
[    0.770025] hub 1-0:1.0: USB hub found
[    0.770103] hub 1-0:1.0: 8 ports detected
[    0.770359] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    0.770533] uhci_hcd: USB Universal Host Controller Interface driver
[    0.770727] uhci_hcd 0000:00:10.0: PCI INT A -> Link[ALKB] -> GSI 21=
 (level, low) -> IRQ 21
[    0.770820] uhci_hcd 0000:00:10.0: UHCI Host Controller
[    0.771050] uhci_hcd 0000:00:10.0: new USB bus registered, assigned =
bus number 2
[    0.771162] uhci_hcd 0000:00:10.0: irq 21, io base 0x0000f900
[    0.771537] usb usb2: configuration #1 chosen from 1 choice
[    0.771724] hub 2-0:1.0: USB hub found
[    0.771802] hub 2-0:1.0: 2 ports detected
[    0.771986] uhci_hcd 0000:00:10.1: PCI INT A -> Link[ALKB] -> GSI 21=
 (level, low) -> IRQ 21
[    0.772076] uhci_hcd 0000:00:10.1: UHCI Host Controller
[    0.772300] uhci_hcd 0000:00:10.1: new USB bus registered, assigned =
bus number 3
[    0.772412] uhci_hcd 0000:00:10.1: irq 21, io base 0x0000f800
[    0.772780] usb usb3: configuration #1 chosen from 1 choice
[    0.773014] hub 3-0:1.0: USB hub found
[    0.773090] hub 3-0:1.0: 2 ports detected
[    0.773289] uhci_hcd 0000:00:10.2: PCI INT B -> Link[ALKB] -> GSI 21=
 (level, low) -> IRQ 21
[    0.773381] uhci_hcd 0000:00:10.2: UHCI Host Controller
[    0.773597] uhci_hcd 0000:00:10.2: new USB bus registered, assigned =
bus number 4
[    0.773709] uhci_hcd 0000:00:10.2: irq 21, io base 0x0000f700
[    0.774087] usb usb4: configuration #1 chosen from 1 choice
[    0.774286] hub 4-0:1.0: USB hub found
[    0.774362] hub 4-0:1.0: 2 ports detected
[    0.774543] uhci_hcd 0000:00:10.3: PCI INT B -> Link[ALKB] -> GSI 21=
 (level, low) -> IRQ 21
[    0.774632] uhci_hcd 0000:00:10.3: UHCI Host Controller
[    0.774849] uhci_hcd 0000:00:10.3: new USB bus registered, assigned =
bus number 5
[    0.774961] uhci_hcd 0000:00:10.3: irq 21, io base 0x0000f600
[    0.775332] usb usb5: configuration #1 chosen from 1 choice
[    0.775528] hub 5-0:1.0: USB hub found
[    0.775605] hub 5-0:1.0: 2 ports detected
[    0.775847] Initializing USB Mass Storage driver...
[    0.776082] usbcore: registered new interface driver usb-storage
[    0.776240] USB Mass Storage support registered.
[    0.776614] PNP: No PS/2 controller found. Probing ports directly.
[    0.952805] ata1: SATA link down 1.5 Gbps (SStatus 0 SControl 300)
[    1.039562] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.040107] mice: PS/2 mouse device common for all mice
[    1.040511] vt1211: Found VT1211 chip at 0x6000, revision 2
[    1.040751] hwmon-vid: Unknown VRM version of your x86 CPU
[    1.041244] EDAC MC: Ver: 2.1.0 Jan 29 2010
[    1.041624] cpuidle: using governor ladder
[    1.041985] padlock: Using VIA PadLock ACE for AES algorithm.
[    1.042208] padlock: Using VIA PadLock ACE for SHA1/SHA256 algorithm=
s.
[    1.044696] usbcore: registered new interface driver hiddev
[    1.044855] usbcore: registered new interface driver usbhid
[    1.044921] usbhid: v2.6:USB HID core driver
[    1.045210] GACT probability on
[    1.045269] Mirror/redirect action on
[    1.045329] Simple TC action Loaded
[    1.046549] netem: version 1.2
[    1.046610] u32 classifier
[    1.046664]     Performance counters on
[    1.046722]     input device check on=20
[    1.046779]     Actions configured=20
[    1.046842] Netfilter messages via NETLINK v0.30.
[    1.047083] xt_time: kernel timezone is -0000
[    1.048522] IPv4 over IPv4 tunneling driver
[    1.050009] GRE over IPv4 tunneling driver
[    1.051417] ip_tables: (C) 2000-2006 Netfilter Core Team
[    1.051547] arp_tables: (C) 2002 David S. Miller
[    1.051695] TCP cubic registered
[    1.051752] Initializing XFRM netlink socket
[    1.051816] IPv6: Loaded, but administratively disabled, reboot requ=
ired to enable
[    1.051892] ipv6 ah init: can't add xfrm type
[    1.051952] ipv6 esp init: can't add xfrm type
[    1.052012] ipcomp6 init: can't add xfrm type
[    1.052089] ip6_tables: (C) 2000-2006 Netfilter Core Team
[    1.052212] IPv6 over IPv4 tunneling driver
[    1.054635] NET: Registered protocol family 17
[    1.054715] NET: Registered protocol family 15
[    1.055004] Bridge firewalling registered
[    1.055071] Ebtables v2.0 registered
[    1.055189] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech=
=2Ecom>
[    1.055256] All bugs added by David S. Miller <davem@redhat.com>
[    1.055363] Using IPI Shortcut mode
[    1.166687] ata2: SATA link down 1.5 Gbps (SStatus 0 SControl 300)
[    1.357068] ata4.00: ATA-0: TRANSCEND, 20070312, max MWDMA2
[    1.357136] ata4.00: 996912 sectors, multi 0: LBA=20
[    1.370307] ata4.00: configured for PIO4
[    1.390304] ata4.00: configured for PIO4
[    1.390365] ata4: EH complete
[    1.403538] scsi 3:0:0:0: Direct-Access     ATA      TRANSCEND      =
  2007 PQ: 0 ANSI: 5
[    1.404179] sd 3:0:0:0: [sda] 996912 512-byte logical blocks: (510 M=
B/486 MiB)
[    1.404337] sd 3:0:0:0: [sda] Write Protect is off
[    1.404403] sd 3:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.404450] sd 3:0:0:0: [sda] Write cache: disabled, read cache: ena=
bled, doesn't support DPO or FUA
[    1.404811]  sda: sda1
[    1.406838] sd 3:0:0:0: Attached scsi generic sg0 type 0
[    1.407324] sd 3:0:0:0: [sda] Attached SCSI disk
[    1.426851] RAMDISK: gzip image found at block 0
[    8.951329] VFS: Mounted root (ext2 filesystem) readonly on device 1=
:0.
[    8.951452] devtmpfs: mounted
[    8.951542] Freeing unused kernel memory: 316k freed
[   10.473262] IPv4 FIB: Using LC-trie version 0.409
[   10.917146] eth2: link up, 100Mbps, full-duplex, lpa 0x41E1
[   10.917722] eth1: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   10.918198] eth0: link up, 100Mbps, full-duplex, lpa 0x41E1
[   11.885269] nf_conntrack version 0.5.0 (7766 buckets, 31064 max)
[   11.885768] CONFIG_NF_CT_ACCT is deprecated and will be removed soon=
=2E Please use
[   11.885778] nf_conntrack.acct=3D1 kernel parameter, acct=3D1 nf_conn=
track module option or
[   11.885786] sysctl net.netfilter.nf_conntrack_acct=3D1 to enable it.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

>
> Please also try "modprobe tcrypt mode=3D101".
>


[  474.947508] alg: hash: Failed to load transform for hmac(sha1): -2
[  474.952660] alg: hash: Failed to load transform for hmac(sha1): -2
[  474.952737] tcrypt: one or more tests failed!


Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts

