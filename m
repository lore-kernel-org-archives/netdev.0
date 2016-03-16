From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 4/5] net: macb: Use ether_addr_copy over memcpy
Date: Wed, 16 Mar 2016 14:48:10 +0100
Message-ID: <56E9641A.2020607@atmel.com>
References: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
 <1457896247-25934-5-git-send-email-moritz.fischer@ettus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <michal.simek@xilinx.com>, <joe@perches.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <moritz.fischer.private@gmail.com>
To: Moritz Fischer <moritz.fischer@ettus.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457896247-25934-5-git-send-email-moritz.fischer@ettus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 13/03/2016 20:10, Moritz Fischer a =E9crit :
> Checkpatch suggests using ether_addr_copy over memcpy
> to copy the mac address.
>=20
> Signed-off-by: Moritz Fischer <moritz.fischer@ettus.com>

Yes:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>  drivers/net/ethernet/cadence/macb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index 53400f6..a0c01e5 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2891,7 +2891,7 @@ static int macb_probe(struct platform_device *p=
dev)
> =20
>  	mac =3D of_get_mac_address(np);
>  	if (mac)
> -		memcpy(bp->dev->dev_addr, mac, ETH_ALEN);
> +		ether_addr_copy(bp->dev->dev_addr, mac);
>  	else
>  		macb_get_hwaddr(bp);
> =20
>=20


--=20
Nicolas Ferre
