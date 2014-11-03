From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 4/7] can: m_can: add a bit delay after setting CCCR_INIT
 bit
Date: Mon, 03 Nov 2014 17:52:11 +0100
Message-ID: <5457B2BB.9050807@pengutronix.de>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com> <1414579527-31100-4-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="59wpUdW39w4bBDpUnfAOClG67Id7nAUck"
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:36845 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752917AbaKCQwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 11:52:20 -0500
In-Reply-To: <1414579527-31100-4-git-send-email-b29396@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--59wpUdW39w4bBDpUnfAOClG67Id7nAUck
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/29/2014 11:45 AM, Dong Aisheng wrote:
> The spec mentions there may be a delay until the value written to
> INIT can be read back due to the synchronization mechanism between the
> two clock domains. But it does not indicate the exact clock cycles need=
ed.
> The 5us delay is a test value and seems ok.
>=20
> Without the delay, CCCR.CCE bit may fail to be set and then the
> initialization fail sometimes when do repeatly up and down.
>=20
> Signed-off-by: Dong Aisheng <b29396@freescale.com>

Applied to can/master.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--59wpUdW39w4bBDpUnfAOClG67Id7nAUck
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUV7K7AAoJECte4hHFiupUn7UP/00Pa4sLpqkvwkwI99EgLJHT
4fq+Gl3VC6JaycbwcuO/LN+75Ddgf3sXWjhVR9UJBERJ++eu4bEDf2Kxk7V0TdRb
k/Qr+YaE9WbbweQaRcXEUuT39Hlj04LJVGga1j0X52e0NPJxW+ptCKz9PdDnxzAU
ZxkB+zN46m1GP29e1WYSC0OcX60uuspSnkMC/Zr/FjV/LBLQQ8WztcZn/sBHs749
t3jGTS2lO2h1htzctKZ5gANBCfwRKGD2qGup07bwAANpLNOsHDy0iabZdcGHoSoY
so54HvI0uY65Jal7X+/drVMZZ1+ItGipz45nPHNhPVjW98M5Q4Dm8Lq5Igd9T7o1
9QVxkpCQDJhos3rdJVpPkHe4IuxrvcXeIeZZ09eWhROb+23lxPw0REUUn8H6smyp
WIQyt5SBNZyuJULZ2jV96e5fHVaMHTvjqf0ueGhIiBD9YndjOzgUAFtHKfex0OHB
mUoCwmcInPzcecB+kArOYQCXMGpzDm4CyH2utqa3vGatqDhUrn/e22o1FSwixfmH
76hOcWIvHGdpEBBAM5JYO3+sZB/u8fjYe2bSXsBrMgAjBg8a69zPz/Z7LAfM+naA
nKGjo0rFBhn1G+kIIyZ3Yrv5CEz5VRGEwNnaNXgMmsGAlSf8fqg7xVOOcR0WnXMs
yNzh+2XVWoUnsBUwitdN
=oRVY
-----END PGP SIGNATURE-----

--59wpUdW39w4bBDpUnfAOClG67Id7nAUck--
