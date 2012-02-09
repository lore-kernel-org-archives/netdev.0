From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 09/50] Cadence MACB: use dev_hw_addr_random() instead
 of random_ether_addr()
Date: Thu, 09 Feb 2012 09:24:47 +0100
Message-ID: <4F3382CF.8090302@atmel.com>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de> <1328735457-29986-10-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Jamie Iles <jamie@jamieiles.com>
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-10-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/08/2012 10:10 PM, Danny Kukawka :
> Use dev_hw_addr_random() instead of calling random_ether_addr()
> to set addr_assign_type correctly to NET_ADDR_RANDOM.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Danny,

You can add my "Acked-by" even if you rework this series...

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks, best regards,

> ---
>  drivers/net/ethernet/cadence/macb.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 2320068..3ee8d79 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -87,7 +87,7 @@ static void __init macb_get_hwaddr(struct macb *bp)
>  		memcpy(bp->dev->dev_addr, addr, sizeof(addr));
>  	} else {
>  		netdev_info(bp->dev, "invalid hw address, using random\n");
> -		random_ether_addr(bp->dev->dev_addr);
> +		dev_hw_addr_random(bp->dev, bp->dev->dev_addr);
>  	}
>  }
>  


-- 
Nicolas Ferre
