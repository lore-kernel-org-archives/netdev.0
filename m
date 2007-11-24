From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: wireless vs. alignment requirements
Date: Sat, 24 Nov 2007 22:33:14 +0100
Message-ID: <1195939994.4149.199.camel@johannes.berg>
References: <E1IvoID-0006aR-00@gondolin.me.apana.org.au>
	 <1195893216.4149.186.camel@johannes.berg>
	 <20071124133200.GA27531@gondor.apana.org.au>
	 <1195912176.4149.194.camel@johannes.berg>
	 <20071124141319.GA27819@gondor.apana.org.au>
	 <4748855C.5090103@linux-foundation.org>
	 (sfid-20071124_201316_613257_4C997365)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-AR9UCfDvReNfUU0AFp3v"
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4748855C.5090103-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> (sfid-20071124_201316_613257_4C997365)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-AR9UCfDvReNfUU0AFp3v
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> Then what about hardware that can't dma ethernet to non-aligned address.
> Sky2 hardware breaks if DMA is not 8 byte aligned.  IMHO the IP stack sho=
uld
> handle any alignment, and do the appropriate memove if the CPU requires=20
> alignment.

Wouldn't that better be handled in the driver rather than having the
test in the generic RX path?

johannes

--=-AR9UCfDvReNfUU0AFp3v
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR0iYmaVg1VMiehFYAQJcbw//WX3ty8Ui8C372ud1MKr5tCkkoDrEenNE
3wdO+/i7ZHEFwTc0p2TZiVcjmWk9xR1X01LMIo+2q5kILyK6R/lXUfAcS9G1TKpM
oyveI8Kx+PCs+9Jk1zu1GcmuaGcXSpX9bTCLL3OctscwnaGgvgLgV5tycn1tq7LO
ozjTpgUhZ/gjUqxqS4oYeX9clYqZZSjc05CIaN6mKuqXOGdFcSkSsfNr/t2H/Phf
JnYl+dzDy40Vtjdg1pdjsxkrtsBqoPwbjsUk60SLsc4+YNcLiXOqqKIaFbx/G17w
ARFerIYkNPyoiDDSLl3T0Lepp0ixQm9Rrzylvg5C2dYO3tiRMOOcZ0yJxWtRS3zk
MaEsUCEG3PkgswPRviUzZlkrZkVwfNOLzoTKFpYszkewJzDUgcmjLd/4EyrVC/3F
fHRKYXpEG4y6NZxU5Tde/bm5HPGKV1aKmPbFqUSnVwmVIY8CjiP2GFApoLsPGKZE
1FE7Fa/GUKuqU9JZyRfqHRvj7mpiHhXQbZB9RdtNGGHM6oWSt9dtizzAxlATa2OX
C7l5orRwz2rvyS2U5kOkS+s6XAewp8shHt12O91UffDr/FtKGuK229EfyPJ116B2
qQBf17Nbhqr5JjM1Qhb77U1QBvSEV0RArxTzctAri79IKrXi11zsJ8RKAp5uwSfL
OTnPsNpF2PY=
=8cJX
-----END PGP SIGNATURE-----

--=-AR9UCfDvReNfUU0AFp3v--
