From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool] ethtool: Accept long feature names reported by
 -k option as input to -K option
Date: Mon, 27 Jan 2014 01:33:40 +0000
Message-ID: <1390786420.2735.108.camel@deadeye.wl.decadent.org.uk>
References: <1389217931.1644.44.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-zmGjgP3qXCrWfanwuViY"
Cc: Bill Fink <billfink@mindspring.com>, netdev@vger.kernel.org
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54231 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753121AbaA0Bd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 20:33:57 -0500
In-Reply-To: <1389217931.1644.44.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-zmGjgP3qXCrWfanwuViY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-01-08 at 21:52 +0000, Ben Hutchings wrote:
> Before the generic features API was introduced, the ethtool -K option
> took short names for various features, e.g. 'gso' but the -k option
> reported their state using longer names,
> e.g. 'generic-segmentation-offload'.
>=20
> All newer features have a single kernel-provided name so input
> and output are consistent.  But the old features still aren't, and
> although their short names are documented it's not good to have
> these exceptions.
>=20
> Change the argument parsing code for -K so that the long names
> reported by -k are also accepted.
>=20
> Reported-by: Or Gerlitz <or.gerlitz@gmail.com>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> This turned out to be pretty easy to do as the argument processing is
> all table-driven already.  I'll push this if it works for you.
[...]

Can you confirm whether this does what you wanted?

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-zmGjgP3qXCrWfanwuViY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUuW3dOe/yOyVhhEJAQoYNg/+OELv4ZjpJPUppyZl9y8I+fHZXs09koJP
7a3jJmIg2jwUCNFv8HQcQhwA7PR3voucVtV6A5PRSYoDY/OpwMu6i89w6bDtJj5A
oYUL60uedloqIppIjK10QjzWo4ve7U8mNlW1wYdprlybP7qx1pL4MN/Too0+fGRn
rK4zcpNv1tCwcP6xS3e4vH93DS0y8kHhqcPs9fsCEgWHmDeGFMkSeXpE6bJfVX7O
6JCMkXWr6bbkQOJ0bEaeaDkA8mMOAnsalShdy5pK38OhBHVcSZyrZexDBnSuZ6JI
N9IWsExunGhE1QOeegIz9t1JcchPH/rYqQJRxqIdFrQVxX0iTKdHKQpaUY7kPF9h
P5RhPlrbh9LfLuNrJhpw6bsM64SFIhqAHXcDSiLjJ6yK43NmwkK1oYFrdAXzn88s
FmdGmwfpZdufQpTDZVWA1OKiM5ZVhkpACDg9ozHPlk5QIM9XlkEVp6XGzY5Zy/LQ
iWoEybIq1eOZH5cembisEjMTfI8Tg9R1kM50cBzHQ7Oyy9++SdUmN5YXLZ4HONWI
Y6PX31u6mEQbTsOIIMfpGp5RXueSKkguDL/L83YmR87hl27+CkHEbMiDP63ON5Dw
Hv9Q7W6fxBbtqd0G9U8kzJGKbeTCoSie6EZh5lvNlvDGIbmwrYECDi/CjncYHkHs
VR9ofxw2ao0=
=JJvs
-----END PGP SIGNATURE-----

--=-zmGjgP3qXCrWfanwuViY--
