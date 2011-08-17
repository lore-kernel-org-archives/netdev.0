From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: boot test failure (net tree)
Date: Wed, 17 Aug 2011 11:21:10 +1000
Message-ID: <20110817112110.ec81ef078204bf4a02049a66@canb.auug.org.au>
References: <20110817100146.3b557cf815a5a2ae09bc09a7@canb.auug.org.au>
	<20110816.171525.639251389938336183.davem@davemloft.net>
	<20110817105002.efebf85d08460ad99b14be8e@canb.auug.org.au>
	<20110816.175657.1688139393736610845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__17_Aug_2011_11_21_10_+1000_5_nkI05MstdTgYNs"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110816.175657.1688139393736610845.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__17_Aug_2011_11_21_10_+1000_5_nkI05MstdTgYNs
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Tue, 16 Aug 2011 17:56:57 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 17 Aug 2011 10:50:02 +1000
>=20
> > Which is a bit of a pain for automated systems.  Ours does (essentially=
):
> >=20
> > yes '' | make oldconfig
> >=20
> > We really don't want to select every new config item that comes along.
>=20
> If you're indeed piping "yes" output to "make oldconfig" on an
> existing config, it would select the new guards for you.

Notice the '' that just is the same as typing return to every prompt.  In
the case of these new gueards, that means 'n'.  This will be the same
with "make silentoldconfig".

> This happens on other occaisions, I see new group guards all
> the time when I resync my net and net-next trees with Linus.

"All the time"?  really?

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__17_Aug_2011_11_21_10_+1000_5_nkI05MstdTgYNs
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOSxeGAAoJEDMEi1NhKgbs4yAIAIVTC3VMasJyGhXNJvpBsCV8
ux9PSxAs+tBgMrlzvylUGOt0xZKm8pLj4qpjB29MhZlEeircR1xZt6Upb/MVlov/
M1rzZLCyj2f8Zenrzeq+aNYYHusUBLXbQkqL/+i6rGhq7DaRLvpht3pTiXpyebiY
cUjb1nH4Px99gUhq+ySFVcO7P7emByzM6W7gWcQ4SBHonqb4P14s2zrVBSi+QGaX
lwPAMRA8luJZMXRuoI0yR6szZKRILik4sgiVI8AbV/lJoPFe39DLjnvUlK+kPnEi
M29Zz8PCTAhlUR3NRQHHAJV5bS0TTP2+F9jdyi8uFEHfZ43GPQvTKuJndE41SNs=
=oYQ6
-----END PGP SIGNATURE-----

--Signature=_Wed__17_Aug_2011_11_21_10_+1000_5_nkI05MstdTgYNs--
