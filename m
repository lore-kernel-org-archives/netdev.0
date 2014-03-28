From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v5 net-next 0/2] patchset: Support for configurable RSS
 hash key
Date: Fri, 28 Mar 2014 01:39:30 +0000
Message-ID: <1395970770.2898.54.camel@deadeye.wl.decadent.org.uk>
References: <1395412393.2770.48.camel@deadeye.wl.decadent.org.uk>
	 <20140321.152836.1010161671166010422.davem@davemloft.net>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C89CCDD@CMEXMB1.ad.emulex.com>
	 <20140327.145336.1708122219432567015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-VpTiDDk06uSN0Q0vWkIY"
Cc: VenkatKumar.Duvvuru@Emulex.Com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55590 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756738AbaC1BkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 21:40:00 -0400
In-Reply-To: <20140327.145336.1708122219432567015.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-VpTiDDk06uSN0Q0vWkIY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-03-27 at 14:53 -0400, David Miller wrote:
> From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
> Date: Wed, 26 Mar 2014 09:21:01 +0000
>=20
> > I don't mind going back to the original approach of adding a new
> > hash key operation. Please let me know what you guys think, combined
> > operation or a new operation.
>=20
> Unless Ben has a major objection, I would prefer that we just add a
> new hash key interface.

My objection is that there is also the prospect of having multiple RSS
contexts on a single device.  I think we discussed the usefulness of
that several years back at a netconf.  And there is now hardware that
supports it: at least the Solarflare SFC9100 controllers do, and I doubt
they are unique in this.

By grouping the key and hash together, with some reserved fields (which
the setter should initially require to be equal to zero), it should be
possible to fill in support for numbered RSS contexts later without yet
another new structure and operations.

Ben.

--=20
Ben Hutchings
Always try to do things in chronological order;
it's less confusing that way.

--=-VpTiDDk06uSN0Q0vWkIY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUzTS0ue/yOyVhhEJAQqrYQ//SxTLELGly+5JqE3pJqoG9SyiS5Af1jNV
CYWBb8KsB+oOjXlrXsHj+E7NP42vdnzZrfJmf9DZur4B7nmx3+Omp/I3T9gIN6qj
S60bA5byAUUBj3baezKo8sMruLf+99lweSANERb4AtuEIx0mqNAcb4WnCyjb9BTc
lzQ4rI/N3m449SnH1u/Psc/OdDwCo3K1yoXrXw1inOVNWcxocrtmcdiCoaICgp0G
M5ipM73JCxqWR7gUu8MGnaTnl5NQutDEKnPu9oPl2P1IprmgTqRpVAqeyHeCcVbO
3kPL+R0ottzWUIFvG+0nYhqp3kPnJZrtKVW89eCt+9dKJKXBaV1Grkw91SAk+m17
jfyX3dXznSxQIsPr27f0ALKKuPxxYEfbcvOpHn6WlxbbzjqQc6ldHUMZ3JmNVwGk
/PhJWaHa9x+c2C/Ix5B84nRXhFm1y7RRv2Lz/R6Ivqlv7kq4dlFtxafi1t6FI30M
KuGkEZzQUEwg4KIUXqKFRFhqo8Bw9ltA5XM78Pfo7jYa+HSH91HBdFh9tFd70RPf
kxosJY1OZ5qdDbfISX7qSlC6i2lCB5TSU+Mx46R6QzsUI1Un1D1pl2HsRkKjMLa+
nsmo53SnqhTDSQRuyd9ktwKbcueIb746PqFYzRindI4DsEemGTgpUTzSUBybjC9p
HSvHJQhhvEM=
=TrEy
-----END PGP SIGNATURE-----

--=-VpTiDDk06uSN0Q0vWkIY--
