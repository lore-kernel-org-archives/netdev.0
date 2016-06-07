From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH][V2] net: fec: fix spelling mistakes and add missing
 newline
Date: Tue, 7 Jun 2016 01:29:07 +0000
Message-ID: <VI1PR0401MB1855E73A0EFDE13B56D19E63FF5D0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1465201304-5136-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465201304-5136-1-git-send-email-colin.king@canonical.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com> Sent: Monday, June 06, 2016 4:22 PM
> To: Fugang Duan <fugang.duan@nxp.com>; netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Subject: [PATCH][V2] net: fec: fix spelling mistakes and add missing newline
> 
> From: Colin Ian King <colin.king@canonical.com>
> 
> trivial fix to spelling mistakes and add missing newline in pr_err messages
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 3c0255e..fea0f33 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -2416,24 +2416,24 @@ fec_enet_set_coalesce(struct net_device *ndev,
> struct ethtool_coalesce *ec)
>  		return -EOPNOTSUPP;
> 
>  	if (ec->rx_max_coalesced_frames > 255) {
> -		pr_err("Rx coalesced frames exceed hardware limiation");
> +		pr_err("Rx coalesced frames exceed hardware limitation\n");
>  		return -EINVAL;
>  	}
> 
>  	if (ec->tx_max_coalesced_frames > 255) {
> -		pr_err("Tx coalesced frame exceed hardware limiation");
> +		pr_err("Tx coalesced frame exceed hardware limitation\n");
>  		return -EINVAL;
>  	}
> 
>  	cycle = fec_enet_us_to_itr_clock(ndev, fep->rx_time_itr);
>  	if (cycle > 0xFFFF) {
> -		pr_err("Rx coalesed usec exceeed hardware limiation");
> +		pr_err("Rx coalesced usec exceed hardware limitation\n");
>  		return -EINVAL;
>  	}
> 
>  	cycle = fec_enet_us_to_itr_clock(ndev, fep->tx_time_itr);
>  	if (cycle > 0xFFFF) {
> -		pr_err("Rx coalesed usec exceeed hardware limiation");
> +		pr_err("Rx coalesced usec exceed hardware limitation\n");
>  		return -EINVAL;
>  	}
> 
> --
> 2.8.1

Acked-by: Fugang Duan <fugang.duan@nxp.com>
