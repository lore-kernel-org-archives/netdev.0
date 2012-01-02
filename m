From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [BUG] SIOCSIFFLAGS returns -EIO on SMSC LAN911x
Date: Mon, 02 Jan 2012 19:45:05 +0000
Message-ID: <1325533505.13595.246.camel@deadeye>
References: <CAAwP0s37E=9J-KR397snkvq=idrc7nmELDJKrm33reeK84wJYQ@mail.gmail.com>
	 <1325242573.13595.71.camel@deadeye>
	 <CAAwP0s0Y329AAXpHW9muOECt5DpgpDm6kefXR7uE1233A1LGWg@mail.gmail.com>
	 <1325250948.13595.100.camel@deadeye>
	 <CAAwP0s1KV0gCWXB4-sNDjyVKETGrp9xO8VmAnbJHHCupf4P5pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-72MHETT2cM7abKmF+Wr8"
Cc: netdev@vger.kernel.org,
	Enric Balletbo i Serra <eballetbo@iseebcn.com>
To: Javier Martinez Canillas <martinez.javier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50972 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751251Ab2ABTp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 14:45:26 -0500
In-Reply-To: <CAAwP0s1KV0gCWXB4-sNDjyVKETGrp9xO8VmAnbJHHCupf4P5pg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-72MHETT2cM7abKmF+Wr8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-01-02 at 19:37 +0100, Javier Martinez Canillas wrote:
[...]
> Thanks for your help.
>=20
> Finally, what I did was to bring to operational mode the integrated
> PHY chip by disabling the energy detect power-down mode before doing a
> software reset and re-enabling after it.
>=20
> Does that solution make sense to you? I've sent the patch-set to the
> list for review. The patch-set is composed of the following patches:
[...]

I think that if the data sheet says the power-down bit is reserved on
the 9221i then it is better not to set it at all.  However, given that
you actually have hardware to test on, you are in a better position to
say what actually works.

Ben.

--=20
Ben Hutchings
All the simple programs have been written, and all the good names taken.

--=-72MHETT2cM7abKmF+Wr8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATwIJQee/yOyVhhEJAQodqg//eqw//2lLTNKJE7deaLFP0jIrMVKnIILk
Fg8qe87mWvRL2r19qWuJCMXqr+lrAsPtnbmjzEZdMDI43+sxNlDSnMXsmZDIIgZO
EOe9X0byz9qqaB2/31DgSwb8WFcUzaed0a7rAV2QSvzMY4deG4ZZtAqRWS5zXDEt
RfB3q0IsHjfJdhrDda27K3hPIME3+gwDVAhynW7nB4cU5fWnMNon6mytO8mCb2pF
9y44hlAlFxSSdYvMJBb7y0lTKPQuzah42sXpXa6/0IRsXTnmOSFJzVk5I7XiERY2
TmcdGqP3dBBHZCXb92TbhLe7rYJlPgwCyc8FKcixu3gk8vLMEHrE0tg4bGDhmmWL
BGbRtrAA2ywaMlz//AyqPWvkTYva6UGcAE4UqcRl51j+FMA+eJXnK3aQew90Rb75
Z/U8eeZyXw4He5iUpbxgGNaVG4aWpqJSqQqzNIouAkb2L6yBaVh4E0lh/qoFbSVz
XQteSbJPFqdMYkgAb4qWaON9GmU9aEV/CfoShMtiCzhdNfYouwx0q0MSvtM2sr9M
2678bvO4tXi+RdlR1PFop/+kaVaoheQQxPsv9aiXZYlRgttROM8/FdRNodsgmh1Y
3GTrLkzZ8HCstTI20I5jTNnvrEOplZixPXkWwV6+SfLx+XliBxoOyBqyjKmq0J5T
M5iDUM+d/wM=
=3a3h
-----END PGP SIGNATURE-----

--=-72MHETT2cM7abKmF+Wr8--
