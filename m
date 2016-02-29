From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 0/2] Add CAN support to r8a7795 SoC
Date: Mon, 29 Feb 2016 10:34:59 +0100
Message-ID: <56D410C3.7020106@pengutronix.de>
References: <1456737661-20538-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="msI5Cm51HadH9LhC9meAmI3NifBS8fj7i"
Cc: linux-renesas-soc@vger.kernel.org, devicetree@vger.kernel.org,
	linux-can@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, chris.paterson2@renesas.com
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
	wg@grandegger.com, horms@verge.net.au, magnus.damm@gmail.com,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1456737661-20538-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--msI5Cm51HadH9LhC9meAmI3NifBS8fj7i
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/29/2016 10:20 AM, Ramesh Shanmugasundaram wrote:
> This patch set adds CAN support to r8a7795 SoC.
>=20
> This is based on linux-next (tag: next-20160225).

Please rebase to tags/linux-can-next-for-4.6-20160226 of
git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git

> Pinctrl & Clock related to the controller are already submitted as belo=
w:
>=20
> https://lkml.org/lkml/2016/2/25/546
> https://lkml.org/lkml/2016/2/26/452
> http://www.spinics.net/lists/arm-kernel/msg487238.html
>=20
> The compatibility string used follows the same format as in this patch:=

> http://www.spinics.net/lists/netdev/msg365756.html
>=20
> Ramesh Shanmugasundaram (2):
>   can: rcar_can: Add r8a7795 support
>   arm64: dts: r8a7795: Add CAN support
>=20
>  .../devicetree/bindings/net/can/rcar_can.txt       | 12 +++++++++
>  arch/arm64/boot/dts/renesas/r8a7795.dtsi           | 30 ++++++++++++++=
++++++++
>  drivers/net/can/Kconfig                            |  2 +-
>  drivers/net/can/rcar_can.c                         |  7 ++++-
>  4 files changed, 49 insertions(+), 2 deletions(-)
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--msI5Cm51HadH9LhC9meAmI3NifBS8fj7i
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJW1BDDAAoJED07qiWsqSVq028H/imPQ5sbo1KPNCizsCSmlbwS
3IQBwHcKUTUnYzyUnuHIohWDyChdvB5QybKAtXa7dKByNfINgRBjaI7rX4qSoLS2
x5/rxbvCd/4g3RftJxa+9y73MD6JmSIXjGrLIii/Zjt8qd4MEO0jI0Md1aH1WiCm
II0EGnTh3x+tkwTaPm0ztC5C88gWmqlfg+oRbZ2/C37TfEW1VXabzsDME22DoMYk
K4CW2ACzNuJkuR3YgD/6F/BpniOyDts0vaR4P5Q/WY/md14svKKtCkdBaApZOa/d
ylV55w4QXQ+IxB+zmLnZeK7fp1mLACjcfPTGGhjpcm7v59DtJEyq3DJUxADokbs=
=ektL
-----END PGP SIGNATURE-----

--msI5Cm51HadH9LhC9meAmI3NifBS8fj7i--
