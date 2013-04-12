From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4] can: sja1000: fix endian on arm
Date: Fri, 12 Apr 2013 13:18:59 +0200
Message-ID: <5167EDA3.9050401@pengutronix.de>
References: <1365428932.5760.52.camel@lovely>  <5162CCB5.3000605@pengutronix.de> <1365705884.4136.5.camel@mars>  <51670532.5060101@pengutronix.de>  <1365706413.4136.15.camel@mars>  <1365707697.4136.26.camel@mars>  <51670D3E.1020808@pengutronix.de> <1365708777.4136.29.camel@mars>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2GKHAVENPWTQPDHKKDCBN"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Andreas Larsson <andreas@gaisler.com>,
	Rob Herring <rob.herring@calxeda.com>,
	Bill Pemberton <wfp5p@virginia.edu>, linux-can@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Daniel Mack <daniel@zonque.org>,
	"Hans J. Koch" <hjk@hansjkoch.de>
To: Christoph Fritz <chf.fritz@googlemail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1365708777.4136.29.camel@mars>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2GKHAVENPWTQPDHKKDCBN
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

On 04/11/2013 09:32 PM, Christoph Fritz wrote:
> To get correct endian on arm cpus while reading device tree properties,=

> this patch replaces of_get_property() with of_property_read_u32().
>=20
> Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>

I've fixed the potential div-by-zero problem and tweaked the commit
message a bit. The patch is included in my latest pull request to david.

Thanks,
Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2GKHAVENPWTQPDHKKDCBN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlFn7aMACgkQjTAFq1RaXHNQUQCfck/P/jUAJfbkBHcDbdhBPjju
GJYAn11wz3SEolYyiCoQS6YItxrzvUzE
=Hy0d
-----END PGP SIGNATURE-----

------enig2GKHAVENPWTQPDHKKDCBN--
