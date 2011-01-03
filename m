From: Ben Hutchings <benh@debian.org>
Subject: Re: [net-next-2.6 01/08] r8169: remove the firmware of RTL8111D.
Date: Mon, 03 Jan 2011 23:09:38 +0000
Message-ID: <1294096178.3167.252.camel@localhost>
References: <20110102233552.GB5780@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-AW7OtoqXiTL7LkNsUXce"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>,
	David Woodhouse <dwmw2@infradead.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:32813 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750716Ab1ACXJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 18:09:44 -0500
In-Reply-To: <20110102233552.GB5780@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-AW7OtoqXiTL7LkNsUXce
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-01-03 at 00:35 +0100, Francois Romieu wrote:
> The binary file of the firmware is moved to linux-firmware repository.
> The firmwares are rtl_nic/rtl8168d-1.fw and rtl_nic/rtl8168d-2.fw.
> The driver goes along if the firmware couldn't be found. However, it
> is suggested to be done with the suitable firmware.
[...]

You should also add 'select FW_LOADER' to the Kconfig section for R8169.

Ben.

--=20
Ben Hutchings, Debian Developer and kernel team member


--=-AW7OtoqXiTL7LkNsUXce
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATSJXKOe/yOyVhhEJAQIxdhAAoLLIhpnn1pTRP/+m/XCMzIKLuVu5X43c
XeDKqginIqm7F1xsbtA+46ENqop0kbvN1DUdqdLznvIyJMIUw5ORMztJ3KHQgOtj
G00CM6yreWD5iYMtuQi2wRH+F1IofHiUbeGveVpe/bV5i8nfV5sTzQ//Qq43fz33
S3O29HLcsoNFu2L4seFDU3XB2Q73NAiraev/JvdqBKznABts7tQroficDijjUNSM
mwt9HhFw1/dC92hvE/y5jR+okvcJ3pmbLRJoBKdA1l2k9xv4YGSg044VhILF5UB3
xeokqxWEu467gHXfQrPo696V7K16a77dyQVfd+FK7d6mj5QYYmS7UjUdEbccLaMt
Az/x874j31TUK4avcggbM3zAmLB8Bx4kOshuDP0SNquKUO1Cexm3cPTel0/kbdYJ
1/NxpoHAdtjXq0XtjQEafPvBND1p91ng1jO8AdegXk8KirU1lh9UQ5fk7wdeqn1R
RCyUc7+5GskbQdhFv1vnLolhvutTXJ+2Do/bhGMLATdma6DT0l8ez3SxeSiF8aQ8
L2yJy+JWO38Cb2UnJvI5/xuYn0w0wimYCoAAl68ebJfanuIXthbYZcY6EquVZjcC
TivovH/IUa9QW/6AoC19Z8x1zqVcc3zfKfX7uVDJ6Nt2Tjl2jNiBosNX+B+IyLxd
CoT0+z8y2Mw=
=kZf9
-----END PGP SIGNATURE-----

--=-AW7OtoqXiTL7LkNsUXce--
