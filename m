From: Rik van Riel <riel@redhat.com>
Subject: Re: [kernel-hardening] Re: HalfSipHash Acceptable Usage
Date: Wed, 21 Dec 2016 11:41:28 -0500
Message-ID: <1482338488.11006.70.camel@redhat.com>
References: <20161221155540.29529.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-0zGKtKxh0W2ZQTwz4HDa"
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, eric.dumazet@gmail.com,
        hannes@stressinduktion.org, jeanphilippe.aumasson@gmail.com,
        linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
        luto@amacapital.net, netdev@vger.kernel.org, tom@herbertland.com,
        torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
To: kernel-hardening@lists.openwall.com, Jason@zx2c4.com,
        linux@sciencehorizons.net
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161221155540.29529.qmail@ns.sciencehorizons.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-0zGKtKxh0W2ZQTwz4HDa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-12-21 at 10:55 -0500, George Spelvin wrote:
> Actually, DJB just made a very relevant suggestion.
>=20
> As I've mentioned, the 32-bit performance problems are an x86-
> specific
> problem.=C2=A0=C2=A0ARM does very well, and other processors aren't bad a=
t all.
>=20
> SipHash fits very nicely (and runs very fast) in the MMX registers.
>=20
> They're 64 bits, and there are 8 of them, so the integer registers
> can
> be reserved for pointers and loop counters and all that.=C2=A0=C2=A0And t=
here's
> reference code available.
>=20
> How much does kernel_fpu_begin()/kernel_fpu_end() cost?

Those can be very expensive. Almost certainly not
worth it for small amounts of data.

--=20
All Rights Reversed.
--=-0zGKtKxh0W2ZQTwz4HDa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJYWrC4AAoJEM553pKExN6DtjoH+gORlWNB2YRtjw6x57PfVui5
yiPwJ3TxC1y8tbLl+g7Jh7ogmtq3HDO2rss+8yYxdMtYDc2NsDhwG29+sZ+i7Jnh
jWmgNgufUZ0mC/GI2jkCKL19r4lelXQCLb7RIf1JfVBA6ba65CZ6L7+1FFb4okPy
QxcyBh4hHuA/VDF5ypiC9gXY5RgJFjLr/LkeUpyogXJ9Kl+8kzMQ80UXoPi3W/go
8JB7NgXHHTA3Dxo/pjcy0Y//DfBJVRol+p1AE34s8JIQD1hioLR5/YvA4MPn7RLh
gjGlehVNsqEOirnoDY8LyAPMOy13Su0PAGyHeYVUSIk4fyRs2+hw3JN2t3QtVf0=
=R3Y6
-----END PGP SIGNATURE-----

--=-0zGKtKxh0W2ZQTwz4HDa--
