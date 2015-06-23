From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/2] sh_eth: Remove obsolete r8a779x-ether
 platform_device_id entries
Date: Wed, 24 Jun 2015 08:50:12 +0900
Message-ID: <20150623235011.GG9988@verge.net.au>
References: <1435064462-11680-1-git-send-email-geert+renesas@glider.be>
 <1435064462-11680-2-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1435064462-11680-2-git-send-email-geert+renesas@glider.be>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 23, 2015 at 03:01:02PM +0200, Geert Uytterhoeven wrote:
> Since commit a483dcbfa21f919c ("ARM: shmobile: lager: Remove legacy
> board support"), R-Car Gen2 SoCs are only supported in generic DT-only
> ARM multi-platform builds.  The driver doesn't need to match platform
> devices by name anymore, hence remove the corresponding
> platform_device_id entry.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Acked-by: Simon Horman <horms+renesas@verge.net.au>

> ---
>  drivers/net/ethernet/renesas/sh_eth.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 06ac93468e04aff8..70f3eff4ffc1d6f1 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -3305,10 +3305,6 @@ static struct platform_device_id sh_eth_id_table[] = {
>  	{ "sh7763-gether", (kernel_ulong_t)&sh7763_data },
>  	{ "r8a7740-gether", (kernel_ulong_t)&r8a7740_data },
>  	{ "r8a777x-ether", (kernel_ulong_t)&r8a777x_data },
> -	{ "r8a7790-ether", (kernel_ulong_t)&r8a779x_data },
> -	{ "r8a7791-ether", (kernel_ulong_t)&r8a779x_data },
> -	{ "r8a7793-ether", (kernel_ulong_t)&r8a779x_data },
> -	{ "r8a7794-ether", (kernel_ulong_t)&r8a779x_data },
>  	{ }
>  };
>  MODULE_DEVICE_TABLE(platform, sh_eth_id_table);
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sh" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
