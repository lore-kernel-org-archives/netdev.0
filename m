From: Antonio Quartulli <a@unstable.cc>
Subject: Re: [PATCH] batman-adv: Less function calls in
 batadv_is_ap_isolated() after error detection
Date: Tue, 15 Mar 2016 08:14:46 +0800
Message-ID: <20160315001446.GA29332@prodigo>
References: <564EFC67.7050307@users.sourceforge.net>
 <1655341.WCvHHx7pqD@bentobox>
 <56E2BCD8.9010200@users.sourceforge.net>
 <20160314.152502.1823929263984045274.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="MGYHOYXEY6WxJCY8"
Cc: elfring@users.sourceforge.net, b.a.t.m.a.n@lists.open-mesh.org,
	netdev@vger.kernel.org, mareklindner@neomailbox.ch,
	sw@simonwunderlich.de, sven@narfation.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	julia.lawall@lip6.fr
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:17397 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754368AbcCOAP0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 20:15:26 -0400
Content-Disposition: inline
In-Reply-To: <20160314.152502.1823929263984045274.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Mar 14, 2016 at 03:25:02PM -0400, David Miller wrote:
> From: SF Markus Elfring <elfring@users.sourceforge.net>
> Date: Fri, 11 Mar 2016 13:40:56 +0100
>=20
> > From: Markus Elfring <elfring@users.sourceforge.net>
> > Date: Fri, 11 Mar 2016 13:10:20 +0100
> >=20
> > The variables "tt_local_entry" and "tt_global_entry" were eventually
> > checked again despite of a corresponding null pointer test before.
> >=20
> > * Avoid this double check by reordering a function call sequence
> >   and the better selection of jump targets.
> >=20
> > * Omit the initialisation for these variables at the beginning then.
> >=20
> > Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
>=20
> I am assuming Antonio will take this in via his tree.
>=20

Yeah, it will go through our tree. Still under review right now.

Cheers,

--=20
Antonio Quartulli

--MGYHOYXEY6WxJCY8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW51P2AAoJENpFlCjNi1MR30oP/RXWit549NpWaevt0ALg5+Cf
kJF8Y2bFZvtZ+s8O+gnu6Kb1pJMvsZZuG1cueGmF615JQVFS5EfferlO8zvBYf2m
5s3sXlZTM9KC+fOqMByaiM1POFZAsDQehcobwo8ZeVPAbqr1ij0RybjChx2gmw1Z
9cjdM13KBFnWoYLTGpXWoP+LLqxDQxo5KrastQhkTC5JrG9yuexIrLS9+0n7bsKo
CEIGY50O8dCmEgSkOQsaUQdde7MhXh4Tuw10zaCOI/FXEk4/WdHgs0YFLju4YzFJ
sQz1A3YYOW/Wtv3e65vZXVghdlNS3amNJi/ntTfEeeaiuYnSKDc/2kbyVi6ygabl
yEB7izh430mFaj5q/8HmHiMyAf1l3jnRMweYFRNA/gIH/wqNO9exiy79kJuzyOYl
z2zm4z3GU6R02XfEfepsvWCGZjAXVhaoE4ZIdQ6RqxBD2L01bfOkn62gOwSaYTyn
L6F4gKYEMZoprq6XpS7uuqnhF+2gerbglLKAWvMBRGzpvWmjlxslCBmx0PvxMlel
Ap40kvjSFOOzWKN9d9nab95zQXWbCIFyxXHly8sVooMh6eQvQHD1gufbqgZDIfNz
Di8Dakl9T3hjNeLjF/bbj6EKaLYgzm/k7khUmkeTmd3PPc3blrSIhfASfgTkaAnv
IcIp4wGwayqPm2suLyEu
=3vqy
-----END PGP SIGNATURE-----

--MGYHOYXEY6WxJCY8--
