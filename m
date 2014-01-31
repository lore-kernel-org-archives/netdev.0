From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 0/6] can: sja1000: cleanups and new OF property
Date: Fri, 31 Jan 2014 13:37:28 +0100
Message-ID: <52EB9908.2090903@pengutronix.de>
References: <1391164513-11529-1-git-send-email-florian.vaussard@epfl.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Oa7Sro6m073fX57KnHK4WQbfb7s48rxXQ"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Florian Vaussard <florian.vaussard@epfl.ch>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1391164513-11529-1-git-send-email-florian.vaussard@epfl.ch>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Oa7Sro6m073fX57KnHK4WQbfb7s48rxXQ
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/31/2014 11:35 AM, Florian Vaussard wrote:
> Hello,
>=20
> Changes sinces v1:
> - Merge sja1000_of_platform.c into sja1000_platform.c (patch 4)
>=20
> The first part of this series performs serveral small cleanups
> (patches 1 to 3).
>=20
> Patch 4 merges sja1000_of_platform.c into sja1000_platform.c.
> Changes are pretty conservatives (mostly copy/paste/move). IRQ
> is treated differently in the OF and non-OF versions, thus this
> is where the fused version differs the most.
>=20
> The final part introduces the 'reg-io-width' binding (already used
> by some other drivers) to perform a similar job as what was done
> with IORESOURCE_MEM_XXBIT. This is needed on my system to correctly
> take into account the aliasing of the address bus.

Good work, please keep compatibility for DTs without the 'reg-io-width'
binding. The rest of my comments are only nitpicks. :)

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Oa7Sro6m073fX57KnHK4WQbfb7s48rxXQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLrmQgACgkQjTAFq1RaXHO95QCcC/M7NBTZHBMhoIfldr5iPzJA
z/sAn3TxzCSDJMBKRfLPp/skNhrGeEFa
=Fotn
-----END PGP SIGNATURE-----

--Oa7Sro6m073fX57KnHK4WQbfb7s48rxXQ--
