From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net/macb: fix sparse warning
Date: Thu, 5 Feb 2015 17:06:52 +0100
Message-ID: <54D3951C.1080200@atmel.com>
References: <1423150846-7027-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>
To: Lad Prabhakar <prabhakar.csengg@gmail.com>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423150846-7027-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 05/02/2015 16:40, Lad Prabhakar a =E9crit :
> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
>=20
> this patch fixes following sparse warning:
>=20
> macb.c:2038:26: warning: symbol 'gem_ethtool_ops' was not declared. S=
hould it be static?

Well, actually this function doesn't need to be exported and indeed
should be marked as static.

I'm not against this patch, but removing the export macro and making it
as static should do the trick even better.

Bye,

> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
> ---
>  Found this issue on linux-next (gcc  version 4.8.2,
>  sparse version  0.4.5-rc1)and applies on top linux-next.
>=20
>  drivers/net/ethernet/cadence/macb.h | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethern=
et/cadence/macb.h
> index 31dc080..e6ad68a 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -821,6 +821,7 @@ struct macb {
>  };
> =20
>  extern const struct ethtool_ops macb_ethtool_ops;
> +extern const struct ethtool_ops gem_ethtool_ops;
> =20
>  int macb_mii_init(struct macb *bp);
>  int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
>=20


--=20
Nicolas Ferre
