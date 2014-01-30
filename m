From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 0/5] can: sja1000: cleanups and new OF property
Date: Thu, 30 Jan 2014 16:22:25 +0100
Message-ID: <52EA6E31.2030604@pengutronix.de>
References: <1391092168-21246-1-git-send-email-florian.vaussard@epfl.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="94LWaGbXGI1O0VawOstuAtU6QgVp8ESga"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Florian Vaussard <florian.vaussard@epfl.ch>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1391092168-21246-1-git-send-email-florian.vaussard@epfl.ch>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--94LWaGbXGI1O0VawOstuAtU6QgVp8ESga
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello Florian,

On 01/30/2014 03:29 PM, Florian Vaussard wrote:
> The first part of this series performs serveral small cleanups
> (patches 1 to 3).

Thanks for your contribution. I like patches 1 and 2.

> The second part introduces the 'reg-io-width' binding (already used
> by some other drivers) to perform a similar job as what was done
> with IORESOURCE_MEM_XXBIT on the sja1000_platform. This is needed
> on my system to correctly take into account the aliasing of the
> address bus.

And I appreciate the improvements for the of_platform driver. However
that driver was written back when it was not possible to have platform
and of bindings in the same driver. So I'd like to see that the
of_platform driver gets merged into the platform driver.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--94LWaGbXGI1O0VawOstuAtU6QgVp8ESga
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLqbjEACgkQjTAFq1RaXHOo3QCgijYqHp7JD4YO4LkmN6hIaMnY
KAUAn1LRJPPBRMCbez61AuMpF+/RV+84
=u6dv
-----END PGP SIGNATURE-----

--94LWaGbXGI1O0VawOstuAtU6QgVp8ESga--
