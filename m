From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] net: lpc_eth: Increase number of TX descriptors
Date: Mon, 11 Jun 2012 10:21:56 +0200
Message-ID: <1339402916.6001.1688.camel@edumazet-glaptop>
References: <1339401793-12258-1-git-send-email-stigge@antcom.de>
	 <1339401793-12258-2-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.wells@nxp.com,
	srinivas.bakki@nxp.com, aletes.xgr@gmail.com,
	linux-arm-kernel@lists.infradead.org
To: Roland Stigge <stigge@antcom.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339401793-12258-2-git-send-email-stigge@antcom.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-06-11 at 10:03 +0200, Roland Stigge wrote:
> Since we have enough SRAM, we can increase the number of TX descriptors, so the
> "BUSY" warning about occupied TX descriptors doesn't need to show up as often.
> 
> Signed-off-by: Roland Stigge <stigge@antcom.de>
> Tested-by: Alexandre Pereira da Silva <aletes.xgr@gmail.com>
> 
> ---
>  drivers/net/ethernet/nxp/lpc_eth.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-2.6.orig/drivers/net/ethernet/nxp/lpc_eth.c
> +++ linux-2.6/drivers/net/ethernet/nxp/lpc_eth.c
> @@ -56,7 +56,7 @@
>  
>  #define ENET_MAXF_SIZE 1536
>  #define ENET_RX_DESC 48
> -#define ENET_TX_DESC 16
> +#define ENET_TX_DESC 32
>  
>  #define NAPI_WEIGHT 16
>  


Sorry, this is not the right fix.

You only lower probability of the bug.

What is this BUSY warning mentioned in changelog ?
