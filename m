From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/2] can: rcar_can: Add r8a7795 support
Date: Mon, 29 Feb 2016 13:47:04 +0100
Message-ID: <56D43DC8.8010409@pengutronix.de>
References: <1456737661-20538-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1456737661-20538-2-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <56D411A5.9070706@pengutronix.de>
 <SG2PR06MB10380FC567E038EA92D5401EC3BA0@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <56D416A9.6080608@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Xv4HolPQsQ5Pkul34IelLeVSBUrDQ80Vq"
Cc: "linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chris Paterson <Chris.Paterson2@renesas.com>
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"horms@verge.net.au" <horms@verge.net.au>,
	"magnus.damm@gmail.com" <magnus.damm@gmail.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <56D416A9.6080608@pengutronix.de>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Xv4HolPQsQ5Pkul34IelLeVSBUrDQ80Vq
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/29/2016 11:00 AM, Marc Kleine-Budde wrote:
> I think it's better to fix the algorithm. I'll look into it.

What about:

> ./can-calc-bit-timing -c 39999998 rcar_can                             =
                           =20
> Bit timing parameters for rcar_can with 39.999998 MHz ref clock
> nominal                                 real Bitrt   nom  real SampP
> Bitrate TQ[ns] PrS PhS1 PhS2 SJW BRP Bitrate Error SampP SampP Error   =
   CiBCR
> 1000000    125   2    3    2   1   5  999999  0.0% 75.0% 75.0%  0.0% 0x=
40040100
>  800000    125   3    4    2   1   5  799999  0.0% 80.0% 80.0%  0.0% 0x=
60040100
>  500000    125   6    7    2   1   5  499999  0.0% 87.5% 87.5%  0.0% 0x=
c0040100
>  250000    250   6    7    2   1  10  249999  0.0% 87.5% 87.5%  0.0% 0x=
c0090100
>  125000    500   6    7    2   1  20  124999  0.0% 87.5% 87.5%  0.0% 0x=
c0130100
>  100000    625   6    7    2   1  25   99999  0.0% 87.5% 87.5%  0.0% 0x=
c0180100
>   50000   1250   6    7    2   1  50   49999  0.0% 87.5% 87.5%  0.0% 0x=
c0310100
>   20000   3125   6    7    2   1 125   19999  0.0% 87.5% 87.5%  0.0% 0x=
c07c0100
>   10000   6250   6    7    2   1 250    9999  0.0% 87.5% 87.5%  0.0% 0x=
c0f90100

But I've to port the algorithm from can-calc-bit-timing to the kernel.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Xv4HolPQsQ5Pkul34IelLeVSBUrDQ80Vq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJW1D3IAAoJED07qiWsqSVqUlMH+wXCg8WtLcY+9yv2HvH9J823
9Frqm/fY1kQxPm80JjHMqUPohPizdTVs/x+hNqfbq6i/ipg7NUf2zvAhcuPvQUCc
/G5qwr5qdJd/JK4KaQjvtMIjvlbI9zJm5XiQWokMxeWBDZB/i6nB7Hpi8Ten0dU6
Erx+NmE/BIIN7EY1NHdZ8gvtwsQfU0vy8QMmsC5OLH3Cak1sc1BIEXVSDHW5B8TA
VgIWQLaVOHDjKaJSqyqRG/zSU8VxSaOZT6fiHLDHBuh+QwWuYUg3fyfHIO7g8c9o
DhNm3THfmsG77sE7muwvlQwcQlkXd3comP8FJXu6K6lmz3JZxD7+PWtKmr/+V2c=
=K0ws
-----END PGP SIGNATURE-----

--Xv4HolPQsQ5Pkul34IelLeVSBUrDQ80Vq--
