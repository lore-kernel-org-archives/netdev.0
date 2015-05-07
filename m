From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] net: ll_temac: Use one return statement instead of two
Date: Thu, 7 May 2015 17:30:52 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1505071730090.2462@hadrien>
References: <b10b8e1e696a09152b9df535a8bd37e6500ac1c7.1431005352.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Michal Simek <monstr@monstr.eu>,
	=?ISO-8859-15?Q?S=F6ren_Brinkmann?= <soren.brinkmann@xilinx.com>,
	Fabian Frederick <fabf@skynet.be>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	=?ISO-8859-15?Q?Manuel_Sch=F6lling?= <manuel.schoelling@gmx.de>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Markus Elfring <elfring@users.sourceforge.net>,
	Subbaraya Sundeep Bhatta <subbaraya.sundeep.bhatta@xilinx.com>,
	linux-arm-kernel@lists.infradead.org
To: Michal Simek <michal.simek@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b10b8e1e696a09152b9df535a8bd37e6500ac1c7.1431005352.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 May 2015, Michal Simek wrote:

> From: Michal Simek <monstr@monstr.eu>
>
> Use one return statement instead of two to simplify the code.
> Both are returning the same value.
>
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>

The from should be the same as the signed off.  You need From if you want
something different than what is naturally put by your mailer.  But that
doesn't see to be the case.

julia

> ---
>
>  drivers/net/ethernet/xilinx/ll_temac_main.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
> index 690a4c36b316..ca640d04fd93 100644
> --- a/drivers/net/ethernet/xilinx/ll_temac_main.c
> +++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
> @@ -688,10 +688,8 @@ static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  	cur_p = &lp->tx_bd_v[lp->tx_bd_tail];
>
>  	if (temac_check_tx_bd_space(lp, num_frag)) {
> -		if (!netif_queue_stopped(ndev)) {
> +		if (!netif_queue_stopped(ndev))
>  			netif_stop_queue(ndev);
> -			return NETDEV_TX_BUSY;
> -		}
>  		return NETDEV_TX_BUSY;
>  	}
>
> --
> 2.3.5
>
>
