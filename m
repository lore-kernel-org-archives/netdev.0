From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/2] can: rcar_can: Add r8a7795 support
Date: Mon, 29 Feb 2016 11:00:09 +0100
Message-ID: <56D416A9.6080608@pengutronix.de>
References: <1456737661-20538-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1456737661-20538-2-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <56D411A5.9070706@pengutronix.de>
 <SG2PR06MB10380FC567E038EA92D5401EC3BA0@SG2PR06MB1038.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="2XsOGtBhgUTBHMXDGWjOlmjSLgMgT41d6"
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
In-Reply-To: <SG2PR06MB10380FC567E038EA92D5401EC3BA0@SG2PR06MB1038.apcprd06.prod.outlook.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--2XsOGtBhgUTBHMXDGWjOlmjSLgMgT41d6
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/29/2016 10:56 AM, Ramesh Shanmugasundaram wrote:
>> On 02/29/2016 10:21 AM, Ramesh Shanmugasundaram wrote:
>>> Added r8a7795 SoC support.
>>>
>>> For smoother bit timing calculation, the rounded clock frequency is
>> used.
>>
>> Why this? From my point of view this introduces a clock error.
>=20
> Thanks for the comments.=20
>=20
> Without the rounded clock, can_calc_bittiming returns different BRP
> values and reports high sampling error percentage. However, the
> rounded clock shows no such issues and it works fine for all
> bitrates.
>=20
> Below is an e.g. from my board for an input clock differs by 2Hz.

I think it's better to fix the algorithm. I'll look into it.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--2XsOGtBhgUTBHMXDGWjOlmjSLgMgT41d6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJW1BapAAoJED07qiWsqSVqx0gH+wdaVApbZr7dQF0+4VnzwZMd
+MLQ+n44pTm/XfDrhnPuMA3Y/oAZJ57620LPQIOfG9PZEtlSOu69q9p2udjbFfFz
Oo8rrKthpfT4c9AhxBAXaGSIYoIPPSKooEuslk8lV6cttHxPX2aOkBoxOCZS0CVf
GLREMcTjcQtT6rDmocV+djeAdRg4zMS/Nev73+Cu2GtlG72xgzQAxCbRCom5c3Ef
lPMbm9qMR2pPIFtgYjUwUNnyiz/TctPW/nlw2ycQkU5aBaDD/ZqXVP9QkbIoN2CI
DAcRrvRgMCSBDQxVwLcN7oRArKR1TLLAIWZB1AuALEovr0hD9JLhFvGzAzZeuiI=
=Ue8T
-----END PGP SIGNATURE-----

--2XsOGtBhgUTBHMXDGWjOlmjSLgMgT41d6--
