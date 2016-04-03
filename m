From: Wolfram Sang <wsa@the-dreams.de>
Subject: Re: [PATCH 2/6] net: ethernet: renesas: ravb_main: test clock rate
 to avoid division by 0
Date: Sun, 3 Apr 2016 23:36:41 +0200
Message-ID: <20160403213641.GA24129@katana>
References: <1456958018-7849-1-git-send-email-wsa@the-dreams.de>
 <1456958018-7849-3-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7JfCtLOvnd9MIVvH"
Cc: linux-renesas-soc@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1456958018-7849-3-git-send-email-wsa@the-dreams.de>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 02, 2016 at 11:33:33PM +0100, Wolfram Sang wrote:
> From: Wolfram Sang <wsa+renesas@sang-engineering.com>
>=20
> The clk API may return 0 on clk_get_rate, so we should check the result b=
efore
> using it as a divisor.
>=20
> Signed-off-by: Wolfram Sang <wsa+renesas@sang-engineering.com>

Ping.

> ---
>=20
> Should go individually via subsystem tree.
>=20
>  drivers/net/ethernet/renesas/ravb_main.c | 3 +++
>  1 file changed, 3 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ether=
net/renesas/ravb_main.c
> index 88656ceb6e2946..ce1954a6a12726 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -1691,6 +1691,9 @@ static int ravb_set_gti(struct net_device *ndev)
>  	rate =3D clk_get_rate(clk);
>  	clk_put(clk);
> =20
> +	if (!rate)
> +		return -EINVAL;
> +
>  	inc =3D 1000000000ULL << 20;
>  	do_div(inc, rate);
> =20
> --=20
> 2.7.0
>=20
>=20

--7JfCtLOvnd9MIVvH
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXAYzoAAoJEBQN5MwUoCm2ZOoP/0BXGZLd7Ovs7SMeR3uLtFiT
ANaqsOvsbSaraL7+r4WsanKwgViAnHoQQk9Qo43F0mB6z9o+4/+UsPM0MY+ZkcSn
YwdYJeo7fKtzkY6bNJlOf+pEJU/ig7tjrjqklcmnFqZXYHjcidPG/24apHSYH8hw
SNxXEv8icDiVOga4MOAAHOEs47ADPxCP3CLoxLX8XFpgxb51jX+hQ3eV1A8d7NuT
R/0BgYd8ugE7gnz8RRX+Jwyif91rNXz5J490geVq6HQRRLjsrw1uq0Zj1bER+dgo
ItsoommM22inkGl7IDXoRoi/zufELDxicpPtzAD4mQyAURcohfxyf6evwQi3N/Se
NKxoZ3wDvRAG4WgHy+rNXC+YJmnVOO7JlY8jV25g01btDwbSneWBHwZ34AcW+8ai
lU8DvTxsCfKAtmJn9epXTfGrYBZZZFgXcLIJNEiAGP1gIvHupUOAoLHaZ8BUxFoK
IC+5d9Y8y9/BPTXOHF/gUL51EhF916ib70l/0bnq+hTWjucKlL1bTuXUVVQt+xde
ccQuW86qbtDaptTLCM7WzZdiWSYNM3/CadcjJ93oLSU1u/2Vwv2TWk1fQiHFpR04
0At6fiGLbaqZ3TPB96saXwvjKstUqpEoaZkzKFEFmKJjSzfVXPZBukkomrsp51NT
VFiKivFRnU24/8FHXFBm
=EFsV
-----END PGP SIGNATURE-----

--7JfCtLOvnd9MIVvH--
