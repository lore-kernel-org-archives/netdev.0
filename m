From: crochu nicolas <nicolas.crochu@sgam.com>
Subject: Re: [update] 2.6.4-rc2 - Realtek 8169 patches
Date: Tue, 09 Mar 2004 10:01:19 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1078822878.2408.8.camel@pinacola>
References: <20040307023748.A7829@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-8ffB+lyr+tPBDC0kMySh"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: romieu@fr.zoreil.com
In-Reply-To: <20040307023748.A7829@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-8ffB+lyr+tPBDC0kMySh
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

If i apply only these patch, everything goes fine

r8169-dma-api-tx.patch
r8169-dma-api-rx-buffers.patch
r8169-dma-api-tx-buffers.patch
r8169-rx_copybreak.patch
r8169-mac-phy-version.patch
r8169-init_one.patch
r8169-timer.patch
r8169-hw_start.patch
r8169-intr_mask.patch
r8169-suspend.patch
r8169-endianness.patch
r8169-getstats.patch

if i apply

r8169-addr-high.patch,=20

then i can ping myself, but i can't ping the rest of the world.=20
and, even if i put back my previous correct working driver,=20
i can't make it work right =3D> reboot.

nothing realy interesting in the logfiles.

C.Nicolas.


--=-8ffB+lyr+tPBDC0kMySh
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Ceci est une partie de message
	=?ISO-8859-1?Q?num=E9riquement?= =?ISO-8859-1?Q?_sign=E9e?=

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQBATYfdxsSeKWK8V4QRAs+AAJ4z9gjWvGvFXu6KyiVGg4zFNCSYxQCeMVns
mkbJyGm7tKlnWT7ALM83hrY=
=9iq0
-----END PGP SIGNATURE-----

--=-8ffB+lyr+tPBDC0kMySh--
