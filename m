From: Libor =?utf-8?q?Klep=C3=A1=C4=8D?= <libor.klepac@bcom.cz>
Subject: Re: r8169 and region #2 not an MMIO resource
Date: Wed, 1 Nov 2006 23:23:16 +0100
Message-ID: <200611012323.20828.libor.klepac@bcom.cz>
References: <200611012221.46981.libor.klepac@bcom.cz> <20061101220036.GA3260@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1500607.02b2y99Rp6";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.webx.cz ([82.208.12.1]:64985 "EHLO mail.webx.cz")
	by vger.kernel.org with ESMTP id S1752531AbWKAWo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 17:44:28 -0500
Received: from localhost (ns.webx.cz [127.0.0.1])
	by mail.webx.cz (Postfix) with ESMTP id 4F40741C1EF
	for <netdev@vger.kernel.org>; Wed,  1 Nov 2006 23:41:46 +0100 (CET)
Received: from mail.webx.cz ([127.0.0.1])
	by localhost (ns.webx.cz [127.0.0.1]) (amavisd-new, port 10042)
	with ESMTP id oKM0tkzcOmer for <netdev@vger.kernel.org>;
	Wed,  1 Nov 2006 23:41:41 +0100 (CET)
Received: from leviathan.mugn.local (76-82-244-84.zapcechy.adsl-llu.static.bluetone.cz [84.244.82.76])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.webx.cz (Postfix) with ESMTP id E336841C1F5
	for <netdev@vger.kernel.org>; Wed,  1 Nov 2006 23:23:41 +0100 (CET)
To: netdev@vger.kernel.org
In-Reply-To: <20061101220036.GA3260@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1500607.02b2y99Rp6
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Dne st=C5=99eda 01 listopad 2006 23:00 Francois Romieu napsal(a):
> Libor Klep=C3=A1=C4=8D <libor.klepac@bcom.cz> :
> [...]
>
> > i have build computer with msi MS-7235 motherboard, it has r8169 chip
> > onboard i'm using kernel version 2.6.18 from debian (and i also rebuild
> > kernel without NAPI).
> > When i modprobe module , dmesg says
> >
> > r8169 Gigabit Ethernet driver 2.2LK loaded
> > PCI: Enabling device 0000:03:06.0 (0000 -> 0003)
> > ACPI: PCI Interrupt 0000:03:06.0[A] -> GSI 21 (level, low) -> IRQ 201
> > r8169 0000:03:06.0: region #2 not an MMIO resource, aborting
> >
> > lspci says (there is no region 2? )
>
> Please send lspci -vvx, I need the hexadecimal ID.

hello, here it comes=20

0000:03:06.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169S=
C=20
Gigabit Ethernet (rev 10)
        Subsystem: Micro-Star International Co., Ltd.: Unknown device 235c
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-=
=20
Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort-=
=20
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 32 (8000ns min, 16000ns max), Cache Line Size: 0x10 (64=20
bytes)
        Interrupt: pin A routed to IRQ 201
        Region 0: I/O ports at cc00 [size=3D256]
        Region 1: Memory at fd7fd000 (32-bit, non-prefetchable) [size=3D256]
        Expansion ROM at fde20000 [disabled] [size=3D128K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA=20
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
00: ec 10 67 81 07 00 b0 02 10 00 00 02 10 20 00 00
10: 01 cc 00 00 00 d0 7f fd 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 62 14 5c 23
30: 00 00 00 00 dc 00 00 00 00 00 00 00 07 01 20 40


libor

--nextPart1500607.02b2y99Rp6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBFSR5YhMrxGRe1HmERAoPvAJ9rZe7yvxuib9wDEKWkKCoEk1yRiQCgkf2p
MKsNN7OM3Ix9DJOWnGGdXdw=
=AnXR
-----END PGP SIGNATURE-----

--nextPart1500607.02b2y99Rp6--
