From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 2/4 ethtool] ethtool: Support for configurable RSS hash
 key.
Date: Mon, 20 Jan 2014 13:43:18 +0000
Message-ID: <1390225398.3651.86.camel@deadeye.wl.decadent.org.uk>
References: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8D4@CMEXMB1.ad.emulex.com>
	 <1390156549.16433.119.camel@deadeye.wl.decadent.org.uk>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C84C38B@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ARDj2ATfGGjdb/UCTYfa"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34236 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750744AbaATNna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 08:43:30 -0500
In-Reply-To: <BF3270C86E8B1349A26C34E4EC1C44CB2C84C38B@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ARDj2ATfGGjdb/UCTYfa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-01-20 at 13:28 +0000, Venkata Duvvuru wrote:
> Ben, Please ignore my previous reply. My reply options were screwed up in=
 that.
>=20
> > -----Original Message-----
> > From: Ben Hutchings [mailto:ben@decadent.org.uk]
> > Sent: Monday, January 20, 2014 12:06 AM
> > To: Venkata Duvvuru
> > Cc: netdev@vger.kernel.org
> > Subject: Re: [PATCH 2/4 ethtool] ethtool: Support for configurable RSS =
hash
> > key.
> >=20
> > On Fri, 2014-01-17 at 13:02 +0000, Venkata Duvvuru wrote:
> > > This ethtool patch will primarily implement the parser for the option=
s
> > provided by the user for set and get hashkey before invoking the ioctl.
> > > This patch also has Ethtool man page changes which describes the Usag=
e of
> > set and get hashkey options.
> >=20
> > I'd prefer to have this combined with the -x/-X options (and add new lo=
ng
> > options to reflect that they cover the key as well).
>=20
> if we add hashkey options to the existing -x/-X (--show-rxfh-indir/ --set=
-rxfh-indir), I think it won't be appropriate going by the command name.
> We could change the command name to something like --show-rssconfig /--rs=
s-config but I'm afraid would that be backward compatible?
[...]

That's why I said 'add new long options'.  The ethtool argument parser
allows arbitrarily many aliases for each sub-command.

Ben.

--=20
Ben Hutchings
One of the nice things about standards is that there are so many of them.

--=-ARDj2ATfGGjdb/UCTYfa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUt0n9ue/yOyVhhEJAQot6w/9G7xDYB8L+v3Gk0VBYqV/bP8vdmAvKI32
tq3E8NLz2KuJ/Jnn1yvofsYnqsgl1QIUV9CkKI/d2d2rBYkagkhKZEHDvEpRvIES
Ta5BlijVnpJ0O+EQBnkSFDVEUHFOOe5ay+vp1a/591xBT/Rs/3e5qnAuQr4HZikR
bTjFnTsGz7VNjinnyj4PjgAJdIhliTrNuESnD7owwMDvE/zojc6WijtWzQbm/Q+o
yTqF8fifL3PWZlMv/04OuBYYNbouLB/+OuTuwJGf8B+BYG/LQVjkhDpZcqVgW7Lu
d63CUybcvb4gq6GRZdZ0m/IKe/tzeLHJ236oYdk3tNN9BlyvXqyQVCG9H02PrHLi
pMGbMFF0G7KPzY44NMwmdQzZ3jRDYo3Khxb4CIKn1OaofMO0qh2LrkYCQlhlaNBD
P0CcMR3wU6UjISKF/LvZUzqMG8Io11tzpjbnkplVQk/+IlMe6YCCt6iiwIBGSDVP
HvueTKTJ4mFQd8mASg3giN9PpgVHOQohGTfprXjmTcxhF/kBZqzmlKYrV3hmCmy5
kGXrcU2VCrCPftBAVylEQCIjorUJxseKZilDyPgOL59U5pgS385x9+2Xm0IhZgIN
u5sO2hJBamnufifdjkX9d71keCUxg+1QyF0wjThT1O6am/horvCQ7CgqhSM6to8g
xpMe7xqEPXM=
=TD8G
-----END PGP SIGNATURE-----

--=-ARDj2ATfGGjdb/UCTYfa--
