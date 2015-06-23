From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/2] sh_eth: Remove obsolete r7s72100-ether
 platform_device_id entry
Date: Wed, 24 Jun 2015 08:49:50 +0900
Message-ID: <20150623234949.GF9988@verge.net.au>
References: <1435064462-11680-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1435064462-11680-1-git-send-email-geert+renesas@glider.be>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 23, 2015 at 03:01:01PM +0200, Geert Uytterhoeven wrote:
> Since commit 05104c266ae9a167 ("ARM: shmobile: r7s72100: genmai: Remove
> legacy board file"), r7s72100 is only supported in generic DT-only ARM
> multi-platform builds.  The driver doesn't need to match platform
> devices by name anymore, hence remove the corresponding
> platform_device_id entry.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Acked-by: Simon Horman <horms+renesas@verge.net.au>

> ---
>  drivers/net/ethernet/renesas/sh_eth.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 7fb244f565b283b0..06ac93468e04aff8 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -3303,7 +3303,6 @@ static struct platform_device_id sh_eth_id_table[] = {
>  	{ "sh7757-ether", (kernel_ulong_t)&sh7757_data },
>  	{ "sh7757-gether", (kernel_ulong_t)&sh7757_data_giga },
>  	{ "sh7763-gether", (kernel_ulong_t)&sh7763_data },
> -	{ "r7s72100-ether", (kernel_ulong_t)&r7s72100_data },
>  	{ "r8a7740-gether", (kernel_ulong_t)&r8a7740_data },
>  	{ "r8a777x-ether", (kernel_ulong_t)&r8a777x_data },
>  	{ "r8a7790-ether", (kernel_ulong_t)&r8a779x_data },
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
