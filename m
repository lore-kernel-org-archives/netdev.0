From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC PATCH v2] ethtool: add IPv6 to the NFC API
Date: Mon, 25 Jan 2016 03:20:52 +0000
Message-ID: <1453692052.3734.184.camel@decadent.org.uk>
References: <56A260D9.3020004@solarflare.com>
	 <56A26F1A.1000505@solarflare.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-DfFIcJsu1XZMMHAtSvqp"
Cc: netdev@vger.kernel.org
To: Edward Cree <ecree@solarflare.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40137 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754791AbcAYDVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2016 22:21:14 -0500
In-Reply-To: <56A26F1A.1000505@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DfFIcJsu1XZMMHAtSvqp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-01-22 at 18:04 +0000, Edward Cree wrote:
[...]
> =C2=A0#define	IP_USER_FLOW	0x0d	/* spec only (usr_ip4_spec) */
> +#define	IP6_USER_FLOW	0x0e	/* spec only (usr_ip6_spec; nfc only) */
[...]

This should be named IPV6_USER_FLOW for consistency with the other NFC
type names. =C2=A0It might also be worth adding IPV4_USER_FLOW as an alias
for IP_USER_FLOW.

Otherwise this looks fine.

Ben.

--=20
Ben Hutchings
Klipstein's 4th Law of Prototyping and Production:
                                    A fail-safe circuit will destroy others=
.
--=-DfFIcJsu1XZMMHAtSvqp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIUAwUAVqWUlOe/yOyVhhEJAQqeXg/3V/r0MGMus53EbogOdzlFvXCwbskA/8/A
Qf1pMKNukYuM1TvIfbwrZb8JhQFL/qV4JQv7LgIx29Mk+Fjqfc0E//Mba5w46mb5
e6WHDJaIJOBqXc44Tz77noMAkjOw/CtruSN1kbL5DlbVkZrkV0Fmx7U6TtUo12Hj
Cb6SMBl2n+89+WU0GDHOH7IVjC2bFtNjWR+2WOf448+ub5fFVB1uYeK5nUbmQgoo
nQ9GmnzM7+HKeCxZnix8ne5wof+t5D6OSL0eaY958XK9kMbwCHmQ6HHldciqI9ub
TOCPbEkB5rUUUqseq5J/2qEpKVRmXyxoZ86kc3MdVfvfUsAv3aSssdc4ysphXrtm
4NiFkd8wJvXPXAi9YMs1LxAWZGjxSA3xqOeO1c2cQ7Gu38eLART57x2x0G2CvgGN
4RGdVnxLlwU6qIXF++CBOawjeRwiTwiMCwG5EdMt8eJ3fCttUPhOn5TMlEWdlPYv
4MP8mqN0y/qiKgwS7Zr2JaW/ipapKIC2PkuYTuUTo7P/E6Is8bSOPQzk6ZGLLDFl
k5Wt4tGzUg7SAMAWZa7DHGM8lrg0jpUpo2scOSCu7VO4LwTMRnLYUHu9JFg4XjE1
i+8Xd24qoRb15YB4VdaDzlcJ1eQb6YDXmUMnpwhlyNq5dsbZ+flRqrZm/TMkJ92v
nr7o3vTGSw==
=itQM
-----END PGP SIGNATURE-----

--=-DfFIcJsu1XZMMHAtSvqp--
