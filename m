From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Wed, 01 Oct 2014 00:29:12 -0700
Message-ID: <1412148552.8414.0.camel@jtkirshe-mobl>
References: <20141001170403.7a319458@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-r3SlTKgkLArCl1iymItz"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141001170403.7a319458@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-r3SlTKgkLArCl1iymItz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-10-01 at 17:04 +1000, Stephen Rothwell wrote:
> Hi all,
>=20
> After merging the net-next tree, today's linux-next build (powerpc
> allyesconfig) failed like this:
>=20
> drivers/net/ethernet/xilinx/ll_temac_main.c: In function 'temac_start_xmi=
t_done':
> drivers/net/ethernet/xilinx/ll_temac_main.c:633:22: warning: cast to poin=
ter from integer of different size [-Wint-to-pointer-cast]
>     dev_kfree_skb_irq((struct sk_buff *)cur_p->app4);
>                       ^
> drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c: In function 'fm10k_set_=
ringparam':
> drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c:477:2: error: implicit d=
eclaration of function 'vmalloc' [-Werror=3Dimplicit-function-declaration]
>   temp_ring =3D vmalloc(i * sizeof(struct fm10k_ring));
>   ^
> drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c:477:12: warning: assignm=
ent makes pointer from integer without a cast
>   temp_ring =3D vmalloc(i * sizeof(struct fm10k_ring));
>             ^
> drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c:546:2: error: implicit d=
eclaration of function 'vfree' [-Werror=3Dimplicit-function-declaration]
>   vfree(temp_ring);
>   ^
>=20
> Caused by commit 82dd0f7ee9a3 ("fm10k: Add ethtool support").  See Rule
> 1 in Documentation/SubmitChecklist.
>=20
> I have added the following fix patch for today:
>=20
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 1 Oct 2014 17:00:49 +1000
> Subject: [PATCH] fm10k: using vmalloc requires including linux/vmalloc.h
>=20
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>  drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/n=
et/ethernet/intel/fm10k/fm10k_ethtool.c
> index a9bbe60347d8..2d04464e6aa3 100644
> --- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
> @@ -18,6 +18,8 @@
>   * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-=
6497
>   */
> =20
> +#include <linux/vmalloc.h>
> +
>  #include "fm10k.h"
> =20
>  struct fm10k_stats {
> --=20
> 2.1.1
>=20



--=-r3SlTKgkLArCl1iymItz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUK61IAAoJEOVv75VaS+3Or9QQAJ+ypn2wASgbRjqxnFtuIqX+
LkoYZNAmjopjPK4+/tADH7jwYMg1Le6AtkyqbXRbmC2KeVU8ZkGvgI2Twp8mC4lJ
qB5A8kga+gJ89mXi5S2Kp9hzLLBFBWsTfQO+9m/DLg3giZswUSHagCZPBjVxagh6
oFZauTeAxmgFFmBN0i+l1OR+1yxqUN1KEHgos0WfwpaBrLPsfn2vY8Ul1yDZehYP
7xPHYjX4TZRkqTVcihDTho3Y8obySClHAA6fEAGfwMZJN/FbSK6KnyajefYVvsaM
yWt77jjv2zZYKUMxnxBcAHXFtsckHYt2kopoL1dnilUWp5OK4sYP2gfexNdlTXpV
eHmG4nRUt9KaLn9FDFOOkzI++SWW0zXp7U3DGFZtQ2CAVpJcX0aKPAOriFZTlkEy
K/bxRn/bdHjSFJ+nGPY8q7j8LqxOd98wdoD0TP0DUh5URI+5uXO3WF3w0hMWqr0c
TtFcZm+hf4aiXNOtPGlWE3XWHHXQt62G0hYyJd7GiSoaHtK5KFzQUwZe+exG95EH
EqnERdKGRhwtlNSRnppkxj2bj46r7Fw3sdbprrfjke//FqasD1/nqFlZr5hibdnE
cCYE4ZyUdxmukhTisPYrlYrnGnSSQNbTnxW8uYaM6ngvHe3+KBG0VyR3ZPRjLLx2
+qGYpMViQyHnoR9rDZAx
=xPeF
-----END PGP SIGNATURE-----

--=-r3SlTKgkLArCl1iymItz--
