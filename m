From: crochu nicolas <nicolas.crochu@sgam.com>
Subject: r8169 driver & -mm4
Date: Tue, 02 Mar 2004 16:19:00 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1078240740.1781.24.camel@pinacola>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-flc8tQegn8umS13h857g"
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: romieu@fr.zoreil.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-flc8tQegn8umS13h857g
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

Since i compiled the latest 2.6.3-mm4, without PREEMP, without SMP, and
without ACPI, my laptop is almost working flawlessly.
But, i was surprised when i unplugged the RJ45 cable, in=20
/var/log/messages, i got :
[...]
Mar  2 10:48:43 pinacola kernel: r8169: eth0: Reset RTL8169s PHY
[...]

then, even if i plug the cable again, i got=20
[...]
Mar  2 10:48:43 pinacola kernel: r8169: eth0: Reset RTL8169s PHY
Mar  2 10:49:14 pinacola last message repeated 2561 times
Mar  2 10:50:14 pinacola last message repeated 5084 times
Mar  2 10:50:39 pinacola last message repeated 2049 times
[...]

I could not even ping any host. i had to do a=20

ifdown eth0=20
ifup eth0

To be able to ping the world again.=20


C.Nicolas.

lspci
---------------------------------------------
00:00.0 Host bridge: Intel Corp. 82865G/PE/P Processor to I/O Controller
(rev 02)
00:01.0 PCI bridge: Intel Corp. 82865G/PE/P Processor to AGP Controller
(rev 02)
00:1d.0 USB Controller: Intel Corp. 82801EB USB (rev 02)
00:1d.1 USB Controller: Intel Corp. 82801EB USB (rev 02)
00:1d.2 USB Controller: Intel Corp. 82801EB USB (rev 02)
00:1d.3 USB Controller: Intel Corp. 82801EB USB (rev 02)
00:1d.7 USB Controller: Intel Corp. 82801EB USB2 (rev 02)
00:1e.0 PCI bridge: Intel Corp. 82801BA/CA/DB/EB PCI Bridge (rev c2)
00:1f.0 ISA bridge: Intel Corp. 82801EB LPC Interface Controller (rev
02)
00:1f.1 IDE interface: Intel Corp. 82801EB Ultra ATA Storage Controller
(rev 02)
00:1f.3 SMBus: Intel Corp. 82801EB SMBus Controller (rev 02)
00:1f.5 Multimedia audio controller: Intel Corp. 82801EB AC'97 Audio
Controller (rev 02)
00:1f.6 Modem: Intel Corp. 82801EB AC'97 Modem Controller (rev 02)
01:00.0 VGA compatible controller: ATI Technologies Inc: Unknown device
4e50
03:00.0 CardBus bridge: ENE Technology Inc CB1410 Cardbus Controller
03:01.0 FireWire (IEEE 1394): Texas Instruments TSB43AB21
IEEE-1394a-2000 Controller (PHY/Link)
03:03.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169
(rev 10)

/var/log/syslog
------------------------------------------
[...]
Mar  2 09:20:48 pinacola kernel: PCI: Found IRQ 5 for device
0000:03:03.0
Mar  2 09:20:48 pinacola kernel: eth0: Identified chip type is
'RTL8169s/8110s'.
Mar  2 09:20:48 pinacola kernel: eth0: RTL8169 at 0xe18ab800,
00:90:f5:27:36:0f, IRQ 5
Mar  2 09:20:48 pinacola kernel: eth0: Auto-negotiation Enabled.
Mar  2 09:20:48 pinacola kernel: eth0: 100Mbps Full-duplex operation.
[...]

/proc/interrupts
-------------------------------
           CPU0
  0:   25045424          XT-PIC  timer
  1:      58693          XT-PIC  i8042
  2:          0          XT-PIC  cascade
  5:     310068          XT-PIC  Intel ICH5, uhci_hcd, ehci_hcd, eth0
 11:          3          XT-PIC  ohci1394, uhci_hcd, uhci_hcd, uhci_hcd
 12:     417208          XT-PIC  i8042
 14:      32038          XT-PIC  ide0
 15:      23920          XT-PIC  ide1
NMI:          0
ERR:          0


--=-flc8tQegn8umS13h857g
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Ceci est une partie de message
	=?ISO-8859-1?Q?num=E9riquement?= =?ISO-8859-1?Q?_sign=E9e?=

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQBARKXkxsSeKWK8V4QRAgAkAJwMQ/Clz3U6JGITfqDu6K/8fG+1WQCgujQI
C77qdHy+DvMHfFc80CX+G04=
=rLq4
-----END PGP SIGNATURE-----

--=-flc8tQegn8umS13h857g--
