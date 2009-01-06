From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] net/ehea: use consistent type
Date: Tue, 6 Jan 2009 11:05:11 +1100
Message-ID: <20090106110511.43b0a87a.sfr@canb.auug.org.au>
References: <20081231141730.81449124.sfr@canb.auug.org.au>
	<20081230.215101.228854586.davem@davemloft.net>
	<1230714541.15389.69.camel@pasglop>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__6_Jan_2009_11_05_11_+1100_PMWslh76T_yeTJ70"
Cc: David Miller <davem@davemloft.net>, tklein@de.ibm.com,
	netdev@vger.kernel.org, raisch@de.ibm.com, themann@de.ibm.com,
	linuxppc-dev@ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:34946 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751202AbZAFAF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 19:05:26 -0500
In-Reply-To: <1230714541.15389.69.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Tue__6_Jan_2009_11_05_11_+1100_PMWslh76T_yeTJ70
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Wed, 31 Dec 2008 20:09:01 +1100 Benjamin Herrenschmidt <benh@kernel.cras=
hing.org> wrote:
>
> On Tue, 2008-12-30 at 21:51 -0800, David Miller wrote:
> > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > Date: Wed, 31 Dec 2008 14:17:30 +1100
> >=20
> > > ehea_plpar_hcall9() takes an unsigned long array, so pass that.
> > >=20
> > > This change will avoid some warnings when we change u64 to unsigned
> > > long long.
> > >=20
> > > Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> >=20
> > Patch rejected, for the same reasons as the other driver
> > change.
> >=20
> > We're not going to poop up some drivers with the assumption that long
> > is 64-bit.
>=20
> Well, in that case, this patch is actually correct without considering
> the u64 change. The array is what lands in the registers of the pHyp
> call, so strictly speaking, it's an array of unsigned long's (ie, 32-bit
> on a 32-bit platform, 64-bit on a 64-bit platform), not an array of
> u64's. This function being a wrapper on that pHyp call, it may as well
> use the right type.

So, any response?
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__6_Jan_2009_11_05_11_+1100_PMWslh76T_yeTJ70
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAklioDcACgkQjjKRsyhoI8yL6gCbBn6TnSy/i8zso9iL2Fj7W0YC
46UAnR9a7Hbv7wbhwmmrv6mqu3bbJnlX
=hWiw
-----END PGP SIGNATURE-----

--Signature=_Tue__6_Jan_2009_11_05_11_+1100_PMWslh76T_yeTJ70--
