From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v2] net/macb: fix sparse warning
Date: Thu, 5 Feb 2015 17:40:12 +0100
Message-ID: <54D39CEC.5040200@atmel.com>
References: <1423153267-1768-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>
To: Lad Prabhakar <prabhakar.csengg@gmail.com>,
	<netdev@vger.kernel.org>, "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423153267-1768-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 05/02/2015 17:21, Lad Prabhakar a =E9crit :
> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
>=20
> this patch fixes following sparse warning:
>=20
> macb.c:2038:26: warning: symbol 'gem_ethtool_ops' was not declared. S=
hould it be static?
>=20
> Alongside drops exporting of gem_ethtool_ops as there is no need.
>=20
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Okay with this one:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks! Bye,

> ---
>  Found this issue on linux-next (gcc  version 4.8.2,
>  sparse version  0.4.5-rc1)and applies on top linux-next.
>=20
>  drivers/net/ethernet/cadence/macb.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index 4f7bd13..ad76b8e 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2035,7 +2035,7 @@ const struct ethtool_ops macb_ethtool_ops =3D {
>  };
>  EXPORT_SYMBOL_GPL(macb_ethtool_ops);
> =20
> -const struct ethtool_ops gem_ethtool_ops =3D {
> +static const struct ethtool_ops gem_ethtool_ops =3D {
>  	.get_settings		=3D macb_get_settings,
>  	.set_settings		=3D macb_set_settings,
>  	.get_regs_len		=3D macb_get_regs_len,
> @@ -2046,7 +2046,6 @@ const struct ethtool_ops gem_ethtool_ops =3D {
>  	.get_strings		=3D gem_get_ethtool_strings,
>  	.get_sset_count		=3D gem_get_sset_count,
>  };
> -EXPORT_SYMBOL_GPL(gem_ethtool_ops);
> =20
>  int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
>  {
>=20


--=20
Nicolas Ferre
