From: Johannes Berg <johannes@sipsolutions.net>
Subject: RE: [patch] d80211: use pfifo_qdisc_ops rather
	thand80211-specificqdisc
Date: Sat, 04 Nov 2006 00:07:08 +0100
Message-ID: <1162595228.24673.1.camel@johannes.berg>
References: <C86180A8C204554D8A3323D8F6B0A29F018B5FAE@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-sY37O4jwQVblruHxBRSm"
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Christoph Hellwig <hch@infradead.org>,
	James Ketrenos <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:4255 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932488AbWKCXKx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 18:10:53 -0500
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F018B5FAE@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-sY37O4jwQVblruHxBRSm
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-11-03 at 11:23 -0800, Simon Barber wrote:
> I would
> think the master device is the perfect place to do packet capture,

Sort of. Since it'll be an 802.11 protocol thing, you won't be getting
any signal strength information etc. You really do need that.

>  and
> raw packet transmission.

Same here, you really do want to be able to submit a frame with the
bitrate to use etc. All not part of 802.11.

All the meta info you want from RX or need for proper TX cannot be
transported over that master netdev since it'll have a proper 802.11
protocol, so it's pretty much useless.

johannes

--=-sY37O4jwQVblruHxBRSm
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARUvLmqVg1VMiehFYAQJEKg//RKpEvQ5sd4XA8rQv0/uqE7cg5VegGhZN
uknrwrf9GRihcp5+R/iECfBU30MQa7EkSB9XvgD7fw1O+GBMj1QvXD2g8+c5sNPG
Y1wyUzdhab+5EW1zEwFJuNoaUjtUz2hKema4oGfrszQQds2xAff4/YWuUJQV7kZm
kOguQWECSb5jA7g1UPirx4r/eof38ads3W+UMrbBlQsVr/RQ0LUN0RQ/g+pzFzgt
8HCFpwwUkhUgEYDg3J/LizCd47rdTLv4kmlb6iQ1+FxcvigivLays6aOyzBKd16K
xPsXfDI9NIACvWha1K4K/dvBGjTJclT4Y8ikZ5dDqT3V6xJUHtABIoMkx3dvkoO8
OCyz4MV7w9deDU99NZj5UkG15DsgYstVhxHhbDW/gsJh6KMhkSBgfcSeafEfTnTp
nVZ0Re/Iz00Mh+9MJbHCEDwqn3CkCmvkpKfRdAy1cX04yvGtvuNtDUVEOJ2C4Orh
/G4sINd+Vt2K7OKchI+YAHKrz5qTNv1CoinhWUuufHecIjMffXywnBtji7LTxQST
CTAYwSb0TbuGa/D23PgMS6Fyg8MEeujztK5gjiUUjJA+63WLKt597AQi+Kk3w4FZ
z0UpQUc3mQKGVSLSUTNjm2108/pYFELEPKpRw8XVQ0yfkW3fzAzxLkxbUwDbzNot
pKdqk74edAM=
=6iFV
-----END PGP SIGNATURE-----

--=-sY37O4jwQVblruHxBRSm--

