From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Tue, 30 Sep 2014 16:22:08 +0200
Message-ID: <542ABC90.7010900@pengutronix.de>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com> <1410273070-22485-3-git-send-email-rogerq@ti.com> <20140930132650.GN1325@katana> <542AB137.30507@ti.com> <20140930135226.GO1325@katana> <542AB6E9.9000907@ti.com> <20140930141909.GP1325@katana>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="M4TvBCkkAora51HiDneL2TBWhOXKxSNPG"
Cc: wg@grandegger.com, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Wolfram Sang <wsa@the-dreams.de>, Roger Quadros <rogerq@ti.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20140930141909.GP1325@katana>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--M4TvBCkkAora51HiDneL2TBWhOXKxSNPG
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/30/2014 04:19 PM, Wolfram Sang wrote:
>=20
>> As just TI is using this out of band RAMINIT mechanism, should it be "=
ti,syscon" or just "syscon"?
>=20
> Yes, only TI uses this out-of-band RAMINIT (currently, at least). So, w=
e
> need an (optional) way to describe that. However, accessing syscon
> registers in general is not TI specific and a generic way to do this
> should be used. Which looks to me like the "syscon" property to allow
> access to the register. Still, we should ask DT maintainers about it,
> maybe they prefer a more precise property like "syscon-raminit" to allo=
w
> for further syscon extensions later or something...

What do you think about putting the bit information in the
syscon-raminit phandle as additional arguments?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--M4TvBCkkAora51HiDneL2TBWhOXKxSNPG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlQqvJAACgkQjTAFq1RaXHMpvwCgiNbspl4poBjHk0d+RYzV4w43
T6AAnih8y9nQS+qgwAXDQneSlwpDYT+C
=4HUn
-----END PGP SIGNATURE-----

--M4TvBCkkAora51HiDneL2TBWhOXKxSNPG--
