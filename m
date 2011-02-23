From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#614622: linux-image-2.6.37-1-686: atl2 NIC claims NO
 CARRIER after suspend/resume; rmmod+insmod fixes the problem
Date: Wed, 23 Feb 2011 01:14:11 +0000
Message-ID: <1298423651.2211.496.camel@localhost>
References: <20110222180821.5217.2375.reportbug@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-5Lsh2fZPNGfTBnpVzmNQ"
Cc: 614622@bugs.debian.org, netdev <netdev@vger.kernel.org>,
	Daniel Kahn Gillmor <dkg@fifthhorseman.net>
To: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39600 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755560Ab1BWBOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 20:14:38 -0500
In-Reply-To: <20110222180821.5217.2375.reportbug@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5Lsh2fZPNGfTBnpVzmNQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

This bug report was made against Debian's package of Linux 2.6.37:

On Tue, 2011-02-22 at 13:08 -0500, Daniel Kahn Gillmor wrote:
> Package: linux-2.6
> Version: 2.6.37-1
> Severity: normal
>=20
> I recently switched from 2.6.37-trunk-686 to 2.6.37-1-686.
>=20
> after the switch, i find that sometimes my atl2.ko-driven onboard NIC
> persistently claims NO CARRIER after resuming from suspend-to-RAM,
> even when plugged into a legitimate ethernet port.  This is not
> entirely reliable, but maybe 50% of the time.
>=20
> if i remove and re-load atl2.ko, the interface can properly detect the
> ethernet.
>=20
> i'm happy to help debug this further if there is any information you
> want me to gather on this hardware.  Please let me know.

I don't see any changes to this driver between 2.6.37-rc4 (the first
version we built as '2.6.37-trunk-686') and 2.6.37, so I think Daniel
just had good luck with the earlier versions.

> ** Kernel log:
[...]
> [67880.276036] PM: suspend of devices complete after 147.583 msecs
> [67880.292274] PM: late suspend of devices complete after 16.227 msecs
> [67880.292426] ACPI: Preparing to enter system sleep state S3
> [67880.316648] PM: Saving platform NVS memory
> [67880.357927] Disabling non-boot CPUs ...
> [67880.357927] Back to C!
> [67880.357927] PM: Restoring platform NVS memory
> [67880.357927] Force enabled HPET at resume
> [67880.357927] ACPI: Waking up from system sleep state S3
> [67880.400865] HDA Intel 0000:00:1b.0: restoring config space at offset 0=
x1 (was 0x100006, writing 0x100002)
> [67880.400904] pci 0000:00:1c.0: restoring config space at offset 0x9 (wa=
s 0x1fff1, writing 0x3fc13fb1)
> [67880.400913] pci 0000:00:1c.0: restoring config space at offset 0x8 (wa=
s 0xfff0, writing 0x3fa03f90)
> [67880.400923] pci 0000:00:1c.0: restoring config space at offset 0x7 (wa=
s 0xf0, writing 0x1010)
> [67880.400937] pci 0000:00:1c.0: restoring config space at offset 0x1 (wa=
s 0x100104, writing 0x100107)
> [67880.400976] pci 0000:00:1c.1: restoring config space at offset 0x9 (wa=
s 0x1fff1, writing 0x3fe13fd1)
> [67880.400987] pci 0000:00:1c.1: restoring config space at offset 0x7 (wa=
s 0xf0, writing 0x2020)
> [67880.401001] pci 0000:00:1c.1: restoring config space at offset 0x1 (wa=
s 0x100106, writing 0x100107)
> [67880.401042] pci 0000:00:1c.2: restoring config space at offset 0x7 (wa=
s 0xf0, writing 0x3030)
> [67880.401056] pci 0000:00:1c.2: restoring config space at offset 0x1 (wa=
s 0x100106, writing 0x100107)
> [67880.401099] uhci_hcd 0000:00:1d.0: restoring config space at offset 0x=
1 (was 0x2800005, writing 0x2800001)
> [67880.401132] uhci_hcd 0000:00:1d.1: restoring config space at offset 0x=
1 (was 0x2800005, writing 0x2800001)
> [67880.401165] uhci_hcd 0000:00:1d.2: restoring config space at offset 0x=
1 (was 0x2800005, writing 0x2800001)
> [67880.401197] uhci_hcd 0000:00:1d.3: restoring config space at offset 0x=
1 (was 0x2800005, writing 0x2800001)
> [67880.401239] ehci_hcd 0000:00:1d.7: restoring config space at offset 0x=
1 (was 0x2900006, writing 0x2900002)
> [67880.401265] pci 0000:00:1e.0: restoring config space at offset 0xf (wa=
s 0x60000, writing 0x600ff)
> [67880.401538] PM: early resume of devices complete after 0.795 msecs
> [67880.406036] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 16 (level, low) -=
> IRQ 16
> [67880.406048] HDA Intel 0000:00:1b.0: setting latency timer to 64
> [67880.406093] HDA Intel 0000:00:1b.0: irq 40 for MSI/MSI-X
> [67880.406136] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ =
16
> [67880.406143] pci 0000:00:1c.0: setting latency timer to 64
> [67880.406156] pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low) -> IRQ =
17
> [67880.406163] pci 0000:00:1c.1: setting latency timer to 64
> [67880.406176] pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ =
18
> [67880.406183] pci 0000:00:1c.2: setting latency timer to 64
> [67880.406198] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) ->=
 IRQ 23
> [67880.406208] uhci_hcd 0000:00:1d.0: setting latency timer to 64
> [67880.406234] usb usb2: root hub lost power or was reset
> [67880.406253] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) ->=
 IRQ 19
> [67880.406262] uhci_hcd 0000:00:1d.1: setting latency timer to 64
> [67880.406287] usb usb3: root hub lost power or was reset
> [67880.406303] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) ->=
 IRQ 18
> [67880.406313] uhci_hcd 0000:00:1d.2: setting latency timer to 64
> [67880.406337] usb usb4: root hub lost power or was reset
> [67880.406354] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 16 (level, low) ->=
 IRQ 16
> [67880.406363] uhci_hcd 0000:00:1d.3: setting latency timer to 64
> [67880.406387] usb usb5: root hub lost power or was reset
> [67880.406405] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) ->=
 IRQ 23
> [67880.406415] ehci_hcd 0000:00:1d.7: setting latency timer to 64
> [67880.406486] pci 0000:00:1e.0: setting latency timer to 64
> [67880.406505] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) ->=
 IRQ 19
> [67880.406513] ata_piix 0000:00:1f.2: setting latency timer to 64
> [67880.406543] atl2 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ=
 17
> [67880.406551] atl2 0000:03:00.0: setting latency timer to 64
> [67880.411177] i915 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ=
 16
> [67880.411186] i915 0000:00:02.0: setting latency timer to 64
> [67880.413110] sd 0:0:0:0: [sda] Starting disk
> [67880.652031] usb 1-5: reset high speed USB device using ehci_hcd and ad=
dress 2
> [67880.896031] usb 1-8: reset high speed USB device using ehci_hcd and ad=
dress 3
> [67882.532200] ata1.00: ACPI cmd ef/03:45:00:00:00:a0 (SET FEATURES) filt=
ered out
> [67882.532209] ata1.00: ACPI cmd ef/03:0c:00:00:00:a0 (SET FEATURES) filt=
ered out
> [67882.548191] ata1.00: configured for UDMA/133
> [67882.548697] PM: resume of devices complete after 2147.034 msecs
> [67882.549278] PM: Finishing wakeup.
> [67882.549283] Restarting tasks ... done.
> [67882.549761] video LNXVIDEO:00: Restoring backlight state
> [67882.980083] usb 3-2: new low speed USB device using uhci_hcd and addre=
ss 5
> [67883.150414] atl2 0000:03:00.0: irq 41 for MSI/MSI-X
> [67883.151364] ADDRCONF(NETDEV_UP): eth0: link is not ready
> [67883.159163] usb 3-2: New USB device found, idVendor=3D0973, idProduct=
=3D0001
> [67883.159174] usb 3-2: New USB device strings: Mfr=3D1, Product=3D2, Ser=
ialNumber=3D0
> [67883.159181] usb 3-2: Product: SchlumbergerSema Cryptoflex e-gate
> [67883.159187] usb 3-2: Manufacturer: SchlumbergerSema

I assume this is where Daniel reloads the driver:

> [67977.344181] atl2 0000:03:00.0: PCI INT A disabled
> [67977.379792] Atheros(R) L2 Ethernet Driver - version 2.2.3
> [67977.379802] Copyright (c) 2007 Atheros Corporation.
> [67977.379870] atl2 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ=
 17
> [67977.379892] atl2 0000:03:00.0: setting latency timer to 64
> [67993.948723] atl2 0000:03:00.0: irq 41 for MSI/MSI-X
> [67993.949268] ADDRCONF(NETDEV_UP): eth0: link is not ready
> [67994.154327] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
> [67994.154739] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

[...]
> ** PCI devices:
[...]
> 03:00.0 Ethernet controller [0200]: Atheros Communications L2 Fast Ethern=
et [1969:2048] (rev a0)
>         Subsystem: ASUSTeK Computer Inc. Device [1043:8233]
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- =
<TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 16 bytes
>         Interrupt: pin A routed to IRQ 41
>         Region 0: Memory at fbfc0000 (64-bit, non-prefetchable) [size=3D2=
56K]
>         Expansion ROM at fbfa0000 [disabled] [size=3D128K]
>         Capabilities: <access denied>
>         Kernel driver in use: atl2
[...]

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-5Lsh2fZPNGfTBnpVzmNQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATWRfXee/yOyVhhEJAQpWuw//UNT+orNQAwTX6vnxouxAXMToV1sR8+ux
rbA/P89lwNAnHO/RI5dCd+G31S6WvxiqWfy3xAKnmkERCr8xx0tztOYyym6GwRVd
WB2RbhqBYT8q+d3IVw5oeHm2G671DPHFW11bz2AvSUMgdlAaTz9d58BIiAUe2c4b
FxWoRtol0WyChA/sfRVeZN6ak4MzoPjpxxbPbopj3Kv3YcbSp6n7T4Qd4rrYwTtL
J73OXgZ3JI1Aupe7UgKScVz9urSXwW+qO5BzgFzHXYmVR2M3xLF05ZWhIibQdEi7
Ukgi5I7DTh2MbSLh+nx2IzaqcA4f+CBgKDKcR3qWT9nmg1dM8PoCQvEC2f5kqxEC
WyGy0iqwbQr3410egRuWHVXhJw0sWUIEglo69qMTWi4dZ5rrdFtzIZZMWK+8oxKs
X6cXZwF/sAM52V6XVpau01ECf9NOCDvUUyre3cuWRc7wB3jlCkRR2FBo+AVX7uJK
OBNWcBgvLx5hGjQwfPTrrKaSdRgs9CjuuyUFk9NmqzbWceFUkpdUcb5gwQLx6IAQ
Tu9M8HEWhcF+SIgjmOfKIMxXlP+cfLwEUZRAD1wZzYC4ZhSfxuLtFvgVXiskdS7l
JR53onPvA3jRrD2E77uYlI4ctPmjIYQZz/3WjgoXvQnTUR1B2ZVXYMwwD9+o0bb7
hus0LSSwOhE=
=z9li
-----END PGP SIGNATURE-----

--=-5Lsh2fZPNGfTBnpVzmNQ--
