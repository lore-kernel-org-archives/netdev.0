From: Erik Mouw <mouw@nl.linux.org>
Subject: Support for Intel 82562V-2?
Date: Mon, 6 Aug 2007 18:38:19 +0200
Message-ID: <20070806163819.GA18130@gateway.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+QahgC5+KEYLbs62"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr12.xs4all.nl ([194.109.24.32]:3329 "EHLO
	smtp-vbr12.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957AbXHFQpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 12:45:31 -0400
Received: from gateway.home (a82-92-155-199.adsl.xs4all.nl [82.92.155.199])
	by smtp-vbr12.xs4all.nl (8.13.8/8.13.8) with ESMTP id l76GcJph061568
	for <netdev@vger.kernel.org>; Mon, 6 Aug 2007 18:38:20 +0200 (CEST)
	(envelope-from mouw@nl.linux.org)
Received: from erik by gateway.home with local (Exim 3.36 #1 (Debian))
	id 1II5b1-0006of-00
	for <netdev@vger.kernel.org>; Mon, 06 Aug 2007 18:38:19 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

Just got a brand new Dell Vostro and it appears to have an unsupported
Intel network card:

00:19.0 Ethernet controller: Intel Corporation 82562V-2 10/100 Network Conn=
ection (rev 02)
	Subsystem: Dell Unknown device 0238
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 10
	Region 0: Memory at fdfc0000 (32-bit, non-prefetchable) [size=3D128K]
	Region 1: Memory at fdfff000 (32-bit, non-prefetchable) [size=3D4K]
	Region 2: I/O ports at fe00 [size=3D32]
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3col=
d+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D1 PME-
	Capabilities: [d0] Message Signalled Interrupts: Mask- 64bit+ Queue=3D0/0 =
Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [e0] Vendor Specific Information
00: 86 80 c0 10 07 00 10 00 02 00 00 02 00 00 00 00
10: 00 00 fc fd 00 f0 ff fd 01 fe 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 28 10 38 02
30: 00 00 00 00 c8 00 00 00 00 00 00 00 0a 01 00 00

The e100 driver doesn't recognise it and the "old" eepro100 also
doesn't. Would it be enought to add the PCI ID to one of these drivers
to get the card supported?


Erik

--=20
They're all fools. Don't worry. Darwin may be slow, but he'll
eventually get them. -- Matthew Lammers in alt.sysadmin.recovery

--+QahgC5+KEYLbs62
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFGt057/PlVHJtIto0RAs8vAJsFIfsDSW4em2h+koXZZf95dhao+wCffPx4
IhB0WG9eTHLSk3LgI359kH4=
=yy1/
-----END PGP SIGNATURE-----

--+QahgC5+KEYLbs62--
