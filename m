From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH net-next-2.6 2/6] sfc: Implement generic features
	interface
Date: Sun, 3 Apr 2011 22:50:12 +0200
Message-ID: <20110403205012.GA16335@rere.qmqm.pl>
References: <1301859889.2935.23.camel@localhost> <1301860281.2935.25.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:34592 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449Ab1DCUuN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Apr 2011 16:50:13 -0400
Content-Disposition: inline
In-Reply-To: <1301860281.2935.25.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 03, 2011 at 08:51:21PM +0100, Ben Hutchings wrote:
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/efx.c        |   17 ++++++++-
>  drivers/net/sfc/ethtool.c    |   78 --------------------------------=
----------
>  drivers/net/sfc/net_driver.h |    2 -
>  drivers/net/sfc/rx.c         |    2 +-
>  4 files changed, 16 insertions(+), 83 deletions(-)

Noticed one more thing:

> diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
> index d890679..98da250 100644
> --- a/drivers/net/sfc/efx.c
> +++ b/drivers/net/sfc/efx.c
[...]
> @@ -2452,12 +2463,14 @@ static int __devinit efx_pci_probe(struct pci=
_dev *pci_dev,
>  		return -ENOMEM;
>  	net_dev->features |=3D (type->offload_features | NETIF_F_SG |
>  			      NETIF_F_HIGHDMA | NETIF_F_TSO |
> -			      NETIF_F_GRO);
> +			      NETIF_F_GRO | NETIF_F_RXCSUM);

NETIF_F_GRO is enabled in register_netdev() now , so it's not
needed here.

Best Regards,
Micha=B3 Miros=B3aw
