From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 3/3] can: sja1000: of: add compatibility with
 Technologic Systems version
Date: Tue, 12 Jan 2016 08:55:38 +0100
Message-ID: <5694B17A.10406@pengutronix.de>
References: <1450978973-30417-1-git-send-email-damien.riegel@savoirfairelinux.com>
 <1450978973-30417-4-git-send-email-damien.riegel@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="wlwpQ0NMcjHgjD91eXgqct6bgA5qSkRQa"
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	kernel@savoirfairelinux.com
To: Damien Riegel <damien.riegel@savoirfairelinux.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1450978973-30417-4-git-send-email-damien.riegel@savoirfairelinux.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--wlwpQ0NMcjHgjD91eXgqct6bgA5qSkRQa
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 12/24/2015 06:42 PM, Damien Riegel wrote:
> Technologic Systems provides an IP compatible with the SJA1000,
> instantiated in an FPGA. Because of some bus widths issue, access to
> registers is made through a "window" that works like this:
>=20
>     base + 0x0: address to read/write
>     base + 0x2: 8-bit register value

Why do you use io{read,write}16 if it's a 8 bit register?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--wlwpQ0NMcjHgjD91eXgqct6bgA5qSkRQa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWlLF6AAoJEP5prqPJtc/HgRgIAJ1DIQX3i2VMJagqfR+nMJKP
G4P7W2U0/Ee6U2xs2bpdwr00GojJltUcrm5itiAacNWKEbhuuA7JLvjHyxLec5V2
m3xpCgie6lt+JEHL23wtGuxCQpo1AWsCDq9tt09ovZbKF3FvIR2Q8MR6rPpb6VUr
A0OpiHr0b9r/oaGKCMDLqyJysQNe4WWz3PuMgExilmGMa7lkM4ls7UvLIJAXCKh5
YMDxhhgMdn6cmY/kQdcg7LbrJuYV84lPtaMVSJz2PIxPR60NmYGObDg9Cpz7B6By
Wagb566V1XN7nv8LyvXk7ViRJjiOFdyZvHK7OxIfcRui9vB5X/qp42sFEscNA3w=
=ZSMF
-----END PGP SIGNATURE-----

--wlwpQ0NMcjHgjD91eXgqct6bgA5qSkRQa--
