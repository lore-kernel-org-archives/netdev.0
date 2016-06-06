From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH] net: fec: fix spelling mistake "coalesed" -> "coalesced"
Date: Mon, 6 Jun 2016 02:13:16 +0000
Message-ID: <VI1PR0401MB185583A9AE7C5615B20DAFFCFF5C0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1465066875-7089-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465066875-7089-1-git-send-email-colin.king@canonical.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com> Sent: Sunday, June 05, 2016 3:01 AM
> To: Fugang Duan <fugang.duan@nxp.com>; netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Subject: [PATCH] net: fec: fix spelling mistake "coalesed" -> "coalesced"
> 
> From: Colin Ian King <colin.king@canonical.com>
> 
> trivial fix to spelling mistake in pr_err message
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 3c0255e..96bd210 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -2427,13 +2427,13 @@ fec_enet_set_coalesce(struct net_device *ndev,
> struct ethtool_coalesce *ec)
> 
>  	cycle = fec_enet_us_to_itr_clock(ndev, fep->rx_time_itr);
>  	if (cycle > 0xFFFF) {
> -		pr_err("Rx coalesed usec exceeed hardware limiation");
> +		pr_err("Rx coalesced usec exceeed hardware limiation");

coalesed -> coalesced, Exceeed -> exceed,  limitation-> limitation

So:
pr_err("Rx coalesced usec exceed hardware limitation \n");

>  		return -EINVAL;
>  	}
> 
>  	cycle = fec_enet_us_to_itr_clock(ndev, fep->tx_time_itr);
>  	if (cycle > 0xFFFF) {
> -		pr_err("Rx coalesed usec exceeed hardware limiation");
> +		pr_err("Rx coalesced usec exceeed hardware limiation");

pr_err("Rx coalesced usec exceed hardware limitation \n");

Of course, pls add "\n" terminate char for all pr_err() in . fec_enet_set_coalesce() function.
Thanks.

>  		return -EINVAL;
>  	}
> 
> --
> 2.8.1
