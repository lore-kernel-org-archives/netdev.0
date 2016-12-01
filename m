From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 18/39] Annotate hardware config module parameters in
 drivers/net/can/
Date: Thu, 1 Dec 2016 14:05:14 +0100
Message-ID: <b8f03afb-05b4-c710-c948-948cefc12c80@pengutronix.de>
References: <148059537897.31612.9461043954611464597.stgit@warthog.procyon.org.uk>
 <148059552122.31612.3286291221641529296.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="xwX8KKmvaVXvGewfsnJXe6XWTdWRdGWhJ"
Cc: gnomes@lxorguk.ukuu.org.uk, minyard@acm.org,
        netdev@vger.kernel.org, linux-can@vger.kernel.org,
        linux-security-module@vger.kernel.org, keyrings@vger.kernel.org,
        Wolfgang Grandegger <wg@grandegger.com>
To: David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <148059552122.31612.3286291221641529296.stgit@warthog.procyon.org.uk>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xwX8KKmvaVXvGewfsnJXe6XWTdWRdGWhJ
Content-Type: multipart/mixed; boundary="pibw3MjHPXDFfDuEcqVPLluMWuU8NI0l0";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org
Cc: gnomes@lxorguk.ukuu.org.uk, minyard@acm.org, netdev@vger.kernel.org,
 linux-can@vger.kernel.org, linux-security-module@vger.kernel.org,
 keyrings@vger.kernel.org, Wolfgang Grandegger <wg@grandegger.com>
Message-ID: <b8f03afb-05b4-c710-c948-948cefc12c80@pengutronix.de>
Subject: Re: [PATCH 18/39] Annotate hardware config module parameters in
 drivers/net/can/
References: <148059537897.31612.9461043954611464597.stgit@warthog.procyon.org.uk>
 <148059552122.31612.3286291221641529296.stgit@warthog.procyon.org.uk>
In-Reply-To: <148059552122.31612.3286291221641529296.stgit@warthog.procyon.org.uk>

--pibw3MjHPXDFfDuEcqVPLluMWuU8NI0l0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 12/01/2016 01:32 PM, David Howells wrote:
> When the kernel is running in secure boot mode, we lock down the kernel=
 to
> prevent userspace from modifying the running kernel image.  Whilst this=

> includes prohibiting access to things like /dev/mem, it must also preve=
nt
> access by means of configuring driver modules in such a way as to cause=
 a
> device to access or modify the kernel image.
>=20
> To this end, annotate module_param* statements that refer to hardware
> configuration and indicate for future reference what type of parameter =
they
> specify.  The parameter parser in the core sees this information and ca=
n
> skip such parameters with an error message if the kernel is locked down=
=2E
> The module initialisation then runs as normal, but just sees whatever t=
he
> default values for those parameters is.
>=20
> Note that we do still need to do the module initialisation because some=

> drivers have viable defaults set in case parameters aren't specified an=
d
> some drivers support automatic configuration (e.g. PNP or PCI) in addit=
ion
> to manually coded parameters.
>=20
> This patch annotates drivers in drivers/net/can/.
>=20
> Suggested-by: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: Wolfgang Grandegger <wg@grandegger.com>
> cc: Marc Kleine-Budde <mkl@pengutronix.de>
> cc: linux-can@vger.kernel.org
> cc: netdev@vger.kernel.org

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--pibw3MjHPXDFfDuEcqVPLluMWuU8NI0l0--

--xwX8KKmvaVXvGewfsnJXe6XWTdWRdGWhJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEES2FAuYbJvAGobdVQPTuqJaypJWoFAlhAIAoACgkQPTuqJayp
JWp1IAgAkADs01rvguaxMOp7okZBrkV5PWieww+Pc0u8sYWav9tPsPOnxnBbiQtE
mznY8OW4pRfa8BHpjyltUtgTShn05ThtwU/E09g8EU4TaIghX146DwjKxbrbUlTR
g6etsM6kV+UzF07AD22PzcMKGGj3gP6Ppgec7AJEdW4eY18CH8TJL5/5xf1hUjRN
b0OKbhOdVLKw62JOaJ9dJ8eTRqv78EIpPYQQ6Il1ztGv1rY023zoz4LFam7be3vI
46U46sW7FHhIuy4RhTwa7WsAON073+etnIYBtAsaHCXM+GKFiGlcyaGsLGuQoV7r
1eFTh9mb0GQ7xObbESgIoBdqqsXDBQ==
=3XdM
-----END PGP SIGNATURE-----

--xwX8KKmvaVXvGewfsnJXe6XWTdWRdGWhJ--
