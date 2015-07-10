From: Josh Cartwright <joshc@ni.com>
Subject: Re: [PATCH v2] nohz: prevent tilegx network driver interrupts
Date: Fri, 10 Jul 2015 18:12:58 -0500
Message-ID: <20150710231258.GB25028@jcartwri.amer.corp.natinst.com>
References: <55A0175E.2010200@ezchip.com>
 <1436557045-5392-1-git-send-email-cmetcalf@ezchip.com>
 <20150710224500.GA25028@jcartwri.amer.corp.natinst.com>
 <55A04FEF.2000204@ezchip.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="j2Klb18PAKd8hQ5U"
Cc: Frederic Weisbecker <fweisbec@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris Metcalf <cmetcalf@ezchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod2.natinst.com ([130.164.80.23]:49642 "EHLO ni.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751737AbbGJXND (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jul 2015 19:13:03 -0400
In-Reply-To: <55A04FEF.2000204@ezchip.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--j2Klb18PAKd8hQ5U
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 10, 2015 at 07:06:23PM -0400, Chris Metcalf wrote:
> On 7/10/2015 6:45 PM, Josh Cartwright wrote:
> >>+static inline const struct cpumask *housekeeping_cpumask(void)
> >>>+{
> >>>+#ifdef CONFIG_NO_HZ_FULL
> >>>+	if (tick_nohz_full_enabled())
> >>>+		return housekeeping_mask;
> >>>+#endif
> >Just a small comment:
> >
> >We can take these checks out from under a #ifdef CONFIG_NO_HZ_FULL
> >check, given that are stubbed tick_nohz_full_enabled() defined above.
>=20
> True for the "if" clause, but the "housekeeping_mask" variable is only de=
fined
> under CONFIG_NO_HZ_FULL.

Indeed!  I should have read more carefully.

Sorry for the noise.

  Josh

--j2Klb18PAKd8hQ5U
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJVoFF3AAoJEKp7ZBKwQFArqaAH/Aw9Ij2iCX5FoDthulkyAkLT
ycISKWXpI8gXElHLQN27TSrB8YbOFUdBGKff0IlbwoK2qnAUgbY0w5TjQc/wXPXE
DWsSEBoonLq5ST69SgaJUQBYbGgaptc/RHjTGBUwqup2TLZEchkdIxc4e9kgkzPv
qd1rVDvIG9iFPWgAcTv1jcTOy3DRb7haLCc43YdvlgyYU9i5hSRuwJ3VNEDw5xyW
MfoHXuePNh43TXAUqPr0cm3/NQCZTV1dbU14riAxcjyBqDJox3haCyIB4g/wcuf8
uli8cTLaTL2te6zU15oXhCPugi20IZ9a9l9puERExk2pW1Yk0NRXI4BAnvaSGHU=
=Mn5H
-----END PGP SIGNATURE-----

--j2Klb18PAKd8hQ5U--
