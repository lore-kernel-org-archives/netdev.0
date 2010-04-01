From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [r8169] WARNING: at net/sched/sch_generic.c
Date: Thu, 1 Apr 2010 12:29:31 +0300
Message-ID: <20100401092931.GD3294@swordfish.minsk.epam.com>
References: <20100331102142.GA3294@swordfish.minsk.epam.com>
 <20100331111942.GB13963@hmsreliant.think-freely.org>
 <20100331121426.GB3294@swordfish.minsk.epam.com>
 <1270038569.2103.24.camel@edumazet-laptop>
 <20100331133533.GD13963@hmsreliant.think-freely.org>
 <20100331201426.GA3228@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YToU2i3Vx8H2dn7O"
Cc: Neil Horman <nhorman@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: =?iso-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:51441 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363Ab0DAJ3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 05:29:31 -0400
Content-Disposition: inline
In-Reply-To: <20100331201426.GA3228@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--YToU2i3Vx8H2dn7O
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

On (03/31/10 22:14), Fran=E7ois Romieu wrote:
> -1
>=20
> The driver does not support Jumbo frames because the original 8169 will n=
ot
> go much beyond 7200 (see r8169.c::SafeMtu and netdev circa 2004 december =
7).
>=20
> /me checks... Apparently it still works a bit.
>=20

> Sergey, can you 'dmesg | grep XID' and send the output of a lspci as
> well as the MTU used during the test ?
>=20

Sure.=20

dmesg | grep XID
[   11.761633] r8169 0000:02:00.0: eth0: RTL8168b/8111b at 0xfd1da000, 00:1=
a:92:c9:a0:68, XID 18000000 IRQ 28


	Sergey
--YToU2i3Vx8H2dn7O
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iJwEAQECAAYFAku0Z3sACgkQfKHnntdSXjS4kAP/dG+cl8E8bRSRNaLdtNx3gvva
4TKd2BMFauXmNelHFuNMgtaho12rLx09YDVcznw5y8LIu0b3iIXbGXSlamzRtJkx
BKprP2G1r2yhWs6f+Wf99+wmVzz21J/oltioxYH4/gjD1/VZh48x1842RSvGrIH1
sEiWfbv4vl5Gz81N8kA=
=WeE9
-----END PGP SIGNATURE-----

--YToU2i3Vx8H2dn7O--
