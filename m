From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH 10/16] batman-adv: use CRC32C instead of CRC16 in TT code
Date: Wed, 9 Oct 2013 18:15:49 +0200
Message-ID: <20131009161549.GJ3544@neomailbox.net>
References: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
 <1381322418-1349-11-git-send-email-antonio@meshcoding.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7384@saturn3.aculab.com>
 <20131009143500.GH3544@neomailbox.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7385@saturn3.aculab.com>
 <20131009161028.GI3544@neomailbox.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="y9PDtDHaFrXNoMPU"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:10977 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755506Ab3JIQQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 12:16:14 -0400
Content-Disposition: inline
In-Reply-To: <20131009161028.GI3544@neomailbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--y9PDtDHaFrXNoMPU
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 09, 2013 at 06:10:28PM +0200, Antonio Quartulli wrote:
> On Wed, Oct 09, 2013 at 04:49:53PM +0100, David Laight wrote:
> > All CRC are linear.
> > Because '(a + b) mod c' is the same as '((a mod c) + (b mod c)) mod c'.
> >=20
> > The CRC of a buffer is the XOR of the CRCs generated for each '1' bit.
> > The CRC for each bit depends on how far it is from the end of the buffe=
r.
>=20
> In our tables we cannot make any assumption about the order of the entrie=
s: the
> node whom generated the table may store the entries in a different order =
=66rom
> what we have got.
> This is why I did not implemented it as a simple CRC of the
> whole the GlobalTable/buffer but I CRC'd each MAC+VID on its own.
>=20
>=20
> > Presetting the CRC to all-ones generates a value that is dependent on
> > the length of the buffer - otherwise missing/extra leading zeros are
> > not detected.
>=20
>=20
> Assuming what I said above (that we cannot make assumptions on the order =
of the
> entries), what is your suggestion?

Given that CRCs are commutative, the easiest answer to this question is pro=
bably to
perform the XOR of all the entries and than computing the CRC32 once
(and when computing the CRC I should start with 0xFFFFFFFF other than 0),
right?




Regards,



--=20
Antonio Quartulli

--y9PDtDHaFrXNoMPU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSVYE1AAoJEADl0hg6qKeOkw0P+wfvcIb2QbOSEKX7oCZiARA6
MgY0BUT9ar7jQCS3g0GUBB8YdlZM6mnMLC37gkoDchQt//wQmIAl03OPBa6JuECB
K7WX2lGqS5jcdXwjRGDl8HQCfkX+q2Gz9lrwAPi0Ch6dWMlozpGixxtaxTIYkCTD
JNk2GeBGqoD2BFTKN5HqZ+4qVwcccW+LjXJohkYR8RNJAh4NEeOsHpnkLFBpTR4T
hF/z6KR3RV3c78fjAaz0G6QcT95Q3ASbTWnJ6fRA+fjc5/katu8+LYlyOhalOpFL
ce8Wn0vNDs/xMirzYjncDuOcwrG5Icnfv5ox3Ejzm0L+CRdIPmIu4sSZzpjXeyN3
3qktYhEIeJHAwxkhiKjp9lIcvB2qF+3U6RxTlWgybg+UNYbgiVSAISDF2OY/NOgu
U00LeJeCsFwlDTJnS5VDLNv5yNYLcUHtZrEi3p8wY4z1Xmwfr4VzW7zC1np33AsU
9yyEK/2sSgZTmQHT5tHk717RByfNK1qAh+PQWxfoy9uJwmaVJ6Djc2zyMiMLGFv8
Eid/2vKjXC6TdLQeJl9tTqLECy0vQezjjHY5SgCpWlKFmmaEefNWhvzptu0j74xO
9hdtXGM6Vy2CaJbWuPuu+17xzEePwiwNST0k/Bq2M6ykFUPwHU16WWivhT5Z6irL
Ccnl3wwh3b88YLB5RRWp
=scEW
-----END PGP SIGNATURE-----

--y9PDtDHaFrXNoMPU--
