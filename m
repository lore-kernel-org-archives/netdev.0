From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 4/8] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Thu, 13 Nov 2014 12:09:07 +0100
Message-ID: <54649153.409@pengutronix.de>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-5-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="AVSbkhbQHi8SEJNsH8CKnsSxRmoLxRP7O"
Cc: wsa@the-dreams.de, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, wg@grandegger.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415371762-29885-5-git-send-email-rogerq@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--AVSbkhbQHi8SEJNsH8CKnsSxRmoLxRP7O
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/07/2014 03:49 PM, Roger Quadros wrote:
> Some TI SoCs like DRA7 have a RAMINIT register specification
> different from the other AMxx SoCs and as expected by the
> existing driver.
>=20
> To add more insanity, this register is shared with other
> IPs like DSS, PCIe and PWM.
>=20
> Provides a more generic mechanism to specify the RAMINIT
> register location and START/DONE bit position and use the
> syscon/regmap framework to access the register.

What about the existing device trees that don't have the syscon-raminit
phandle? We can either keep the existing init routines or create regmap
in the platform driver an use the new ones.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--AVSbkhbQHi8SEJNsH8CKnsSxRmoLxRP7O
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZJFTAAoJECte4hHFiupUwokQAI0H4xlC3GWl+lFFavvt1zQG
NFz/6gTXaH1Pb9CmnCEShIj/nZs5i/Y814T8rheOKSSQLzmt7mYTIqYevNXAIcjM
k+xWK2ZXp/9yVB3dYG1DDBV9StK7PJzJamlQ39paRHNYYX/eKgXYP6DkL4lEiGBO
inC9OiJFn1b3L4I9y+0OHZ21XFAfNGV65ITFolJuJaQL1aRy8XWFBFCD7X2MArch
EVSMv8CvSd0eLeOkSmgkdiEuRUXCv2z5Pe0oPldwXsLd48mqi8A9JAa0fwHnf3jQ
4amO/AZPYl8prLKajpY9oWaWEJ+CS7xEEtwLRZhZSIr5/rqFqrXBEHkmvk3JY/f2
7c7qfBocWSzLQ/ilTFlSX4DqC4KC+hcrzgyWXOmUlUu/WgFq8rJabndZSuLqSDJ1
OobADoSOPxCrgaj9xlQPlX+zNivkMlCYB6Kuep+SO4vCtSOnn8Ypv23MoELs8bXl
lxVUr4S+NZu+ulsFA+dhMg5/WKcIg39moND+4qgugArp4RAfSLDcVFdGtLgnu/yH
nXfFdKDqHPRDC6zerg7n2jgbi96CogN5QzDJXmY02oLtJieKo/UYUaPNDfsuotRK
Tgv3aoCayfQaK/VC/02nQv3bUO3MQdVhcpnvqHNr6CfnA4vmcgtmLAcQ2Gz6KitJ
ACcAuPlPf591cMti/0/3
=8lWb
-----END PGP SIGNATURE-----

--AVSbkhbQHi8SEJNsH8CKnsSxRmoLxRP7O--
