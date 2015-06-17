From: Simon Guinot <simon.guinot@sequanux.org>
Subject: Re: [PATCH v2 0/3] Fix Ethernet jumbo frames support for Armada 370
 and 38x
Date: Wed, 17 Jun 2015 19:22:17 +0200
Message-ID: <20150617172217.GY4853@kw.sim.vm.gnt>
References: <1434547162-6275-1-git-send-email-simon.guinot@sequanux.org>
 <20150617172458.3e373b8a@free-electrons.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fKfh0xY2eB01Z/0V"
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
	netdev@vger.kernel.org, Vincent Donnefort <vdonnefort@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vm1.sequanux.org ([188.165.36.56]:55150 "EHLO vm1.sequanux.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754163AbbFQRWW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 13:22:22 -0400
Content-Disposition: inline
In-Reply-To: <20150617172458.3e373b8a@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--fKfh0xY2eB01Z/0V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 17, 2015 at 05:24:58PM +0200, Thomas Petazzoni wrote:
> Dear Simon Guinot,
>=20
> On Wed, 17 Jun 2015 15:19:19 +0200, Simon Guinot wrote:
>=20
> > This patch series fixes the Ethernet jumbo frames support for the SoCs
> > Armada 370, 380 and 385. Unlike Armada XP, the Ethernet controller for
> > this SoCs don't support TCP/IP checksumming with a frame size larger
> > than 1600 bytes.
> >=20
> > This patches should be applied to the -stable kernels 3.8 and onwards.
>=20
> You should add a Fixes: tag to each commit to indicate which commit is
> being fixed by your patches.
>=20
> Also, I was a bit surprised by your statement that Armada 38x is also
> affected by the problem, since Armada 38x is more recent than Armada
> XP. but indeed, according to the Armada 38x datasheet:
>=20
>   IPv4 and TCP/UDP over IPv4/IPv6 checksum generation on transmit
>   frames for standard Ethernet packet size
>=20
> While the Armada XP datasheet says:
>=20
>   Long frames transmission (including jumbo frames), with
>   IPv4/v6/TCP/UDP checksum generation
>=20
> So it seems like you're right about this!

At first, I though this was an error in the Armada 38x datasheet (maybe
a sloppy copy/paster). Therefore I have checked on an DB-88F6820-GP
board and then I can confirm that the Armada 38x is also affected.

Simon

--fKfh0xY2eB01Z/0V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlWBrMkACgkQgtp0PDeOcDqa0ACfcOywfyjQZj1IBNEn4LjVVtZ9
OoQAnRkpkyJLBLcSxAL3IWhIjNQivOIq
=bLVg
-----END PGP SIGNATURE-----

--fKfh0xY2eB01Z/0V--
