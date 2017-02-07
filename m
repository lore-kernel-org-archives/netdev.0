From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: linux-next: manual merge of the akpm tree with the net-next tree
Date: Tue, 7 Feb 2017 09:40:09 +0100
Message-ID: <4cbbbce4-1318-9a75-d918-5b209cc418e6@pengutronix.de>
References: <20170207162322.3732a5a1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="NbAEVtBnhOHLsJjPgfEOPeQV3K6mahSfQ"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Masahiro Yamada <yamada.masahiro@socionext.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        Andrew Morton <akpm@linux-foundation.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170207162322.3732a5a1@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--NbAEVtBnhOHLsJjPgfEOPeQV3K6mahSfQ
Content-Type: multipart/mixed; boundary="7uW6Bx8jhoL4Ado0m31CKPN2XpkT4wqs1";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
 Andrew Morton <akpm@linux-foundation.org>, David Miller
 <davem@davemloft.net>, Networking <netdev@vger.kernel.org>
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
 Masahiro Yamada <yamada.masahiro@socionext.com>
Message-ID: <4cbbbce4-1318-9a75-d918-5b209cc418e6@pengutronix.de>
Subject: Re: linux-next: manual merge of the akpm tree with the net-next tree
References: <20170207162322.3732a5a1@canb.auug.org.au>
In-Reply-To: <20170207162322.3732a5a1@canb.auug.org.au>

--7uW6Bx8jhoL4Ado0m31CKPN2XpkT4wqs1
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/07/2017 06:23 AM, Stephen Rothwell wrote:
> Hi Andrew,
>=20
> Today's linux-next merge of the akpm tree got a conflict in:
>=20
>   drivers/net/can/flexcan.c
>=20
> between commits:
>=20
>   9eb7aa891101 ("can: flexcan: add quirk FLEXCAN_QUIRK_ENABLE_EACEN_RRS=
")
>   b3cf53e988ce ("can: flexcan: add support for timestamp based rx-offlo=
ad")
>=20
> from the net-next tree and commit:
>=20
>   "scripts/spelling.txt: add "disble(d)" pattern and fix typo instances=
"
>=20
> from the akpm tree.
>=20
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tre=
e
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularl=
y
> complex conflicts.
>=20

> diff --cc drivers/net/can/flexcan.c
> index ea57fed375c6,4dc71bce525c..000000000000
> --- a/drivers/net/can/flexcan.c
> +++ b/drivers/net/can/flexcan.c
> @@@ -195,9 -189,7 +195,9 @@@
>    */
>   #define FLEXCAN_QUIRK_BROKEN_ERR_STATE	BIT(1) /* [TR]WRN_INT not conn=
ected */
>   #define FLEXCAN_QUIRK_DISABLE_RXFG	BIT(2) /* Disable RX FIFO Global m=
ask */
>  -#define FLEXCAN_QUIRK_DISABLE_MECR	BIT(3) /* Disable Memory error det=
ection */
>  +#define FLEXCAN_QUIRK_ENABLE_EACEN_RRS	BIT(3) /* Enable EACEN and RRS=
 bit in ctrl2 */
> - #define FLEXCAN_QUIRK_DISABLE_MECR	BIT(4) /* Disble Memory error dete=
ction */
> ++#define FLEXCAN_QUIRK_DISABLE_MECR	BIT(4) /* Disbale Memory error det=
ection */

                                                  ^^^^^^^
Should be "Disable". I'll send David Miller a fix for the typo.

>  +#define FLEXCAN_QUIRK_USE_OFF_TIMESTAMP	BIT(5) /* Use timestamp based=
 offloading */
>  =20
>   /* Structure of the message buffer */
>   struct flexcan_mb {

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--7uW6Bx8jhoL4Ado0m31CKPN2XpkT4wqs1--

--NbAEVtBnhOHLsJjPgfEOPeQV3K6mahSfQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAliZh+kACgkQHv7KIOw4
HPZs6ggAqufoPCoCtFid5mS5ZIaGm03bsHFtIzGkvRogmRGJE2fldy9eth+xZf/x
xn2L1sE0SCNq48vpo6R6CvmLcokXVyqqWB7CCLvGiWMxX3r4V9gHMOwrG8AiOtF3
VVcIWllMUZiLgst+cNMsqR8l9ZF1AzBBWQQ9oF3VNNQLwMKrZIzT6a/v7Q5Eahqb
CoOe6L71Zpk5mXZaPjcie65VT5a3ZuaYKYbfG5Ds9jqdnorwsOn4BrtHWN+TQEem
cQpDSPfuKieR6JX4mpn86i517Td5Kvf9nzWtd+HGb8nb/5rgLxY24MwsnzrC37Z/
l0LbUsq2DPcOl8rHmTo8Pqe3cFmuww==
=q9Yu
-----END PGP SIGNATURE-----

--NbAEVtBnhOHLsJjPgfEOPeQV3K6mahSfQ--
