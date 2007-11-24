From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: wireless vs. alignment requirements
Date: Sat, 24 Nov 2007 22:13:19 +0100
Message-ID: <1195938799.4149.197.camel@johannes.berg>
References: <E1IvoID-0006aR-00@gondolin.me.apana.org.au>
	 <1195893216.4149.186.camel@johannes.berg>
	 <20071124133200.GA27531@gondor.apana.org.au>
	 <1195912176.4149.194.camel@johannes.berg>
	 <20071124141319.GA27819@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-q4B7dJ9BlOd9NBz6pqyr"
Cc: dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071124141319.GA27819-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-q4B7dJ9BlOd9NBz6pqyr
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> OK.  Let me clarify this a bit more.  We require at least one
> of the following rules to be met:
>=20
> * the IPv4/IPv6 header is aligned by 8 bytes on reception;
> * or the platform provides unaligned exception handlers.
>=20
> So if your platform violates both rules then it won't work with
> the IP stack, simple as that.  Fortunately I don't think such a
> platform exists currently on Linux.

Ok, thanks for the clarification.

Eight bytes really sucks for wireless, many things are multiples of four
and QoS vs. non-QoS frames have a multiple of four and common hardware
only adds two padding bytes to get it aligned on four bytes so there's
no easy way to get hardware to align it properly. Hmm.

johannes

--=-q4B7dJ9BlOd9NBz6pqyr
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR0iT7aVg1VMiehFYAQL+Hg//XJQMQl9RlxBzXj2N7u8dg7Ito9gPHyPQ
uQvZonyhu4Cm/mEwJD6us7JaiqDl0njH8xjaE4d7j3aHL/Nn4h5WICdUkD9PiLm4
/9IrtA6H+y1V0SCZ2RksifzCBA68crXdFp9sE+CNYxOPNOXQOg1TIFqILhiLqeZY
k/RYKy4iKKXCB2FQaOFX7KLpn2suRfShFDE1LbaORQ10ravS3VwKh8dSFfBZkbA+
hUbhuoTPaM4RUkb0aJNvJJhi9paLHdMjeZ1bNIRnFIOEat9CxZ/cDAWj1/uL1sgb
BNd0Tubu0Pm0uHQhGBEz6sdBOYocXx76TzXw8ZmC8l80yX/Xqnrd6+x2wmyR6rWv
QEHCUWqq4v+zJgbBLMhgmc6ghPSLkUWf8W/ARLTyGTWG0RaPji2q7cGte7pBndT+
iD4jWM4Udc0CPaqBwsZjHao3cc5DVHP++WkZ/yICMpgAYfZIIswWLhbbSbVQWZRt
BPSrBhmQq1wSacEJaw7Yy6x3jdxBfMjGlXTTuF/xZihkuZQ9SJ7tciL37e6ow16+
0qJO7HCgtY8a0gJ7GMxQZDoguBf7HYJuIsY1NmocQbImjGFGdAur6VWEyIUd0MVH
r5AlZMjk40Hmd5Cfk2fLO+9hLPqE28nS7keClhB2BUXu2iHOzm3jD7niSEEbMxZf
ZkP17w7DMJI=
=+nL9
-----END PGP SIGNATURE-----

--=-q4B7dJ9BlOd9NBz6pqyr--
