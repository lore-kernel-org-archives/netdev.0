From: Michael Grzeschik <mgr@pengutronix.de>
Subject: Re: [PATCH] arcnet: fix spelling mistake "Ackknowledge" ->
 "Acknowledge"
Date: Mon, 26 Jun 2017 11:06:48 +0200
Message-ID: <20170626090648.eg3xukww2okiqnll@pengutronix.de>
References: <20170625211506.29222-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170625211506.29222-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 25, 2017 at 10:15:06PM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Trivial fix to spelling mistake in arc_printk message
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/arcnet/capmode.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
> index a80f4eb9262d..b780be6f41ff 100644
> --- a/drivers/net/arcnet/capmode.c
> +++ b/drivers/net/arcnet/capmode.c
> @@ -212,7 +212,7 @@ static int ack_tx(struct net_device *dev, int acked)
>  	ackpkt->soft.cap.proto = 0; /* using protocol 0 for acknowledge */
>  	ackpkt->soft.cap.mes.ack = acked;
>  
> -	arc_printk(D_PROTO, dev, "Ackknowledge for cap packet %x.\n",
> +	arc_printk(D_PROTO, dev, "Acknowledge for cap packet %x.\n",
>  		   *((int *)&ackpkt->soft.cap.cookie[0]));
>  
>  	ackskb->protocol = cpu_to_be16(ETH_P_ARCNET);

I will take it into my next pull request.

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
