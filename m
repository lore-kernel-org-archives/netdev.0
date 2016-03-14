From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH 4/5] net: macb: Use ether_addr_copy over memcpy
Date: Mon, 14 Mar 2016 21:48:11 +0100
Message-ID: <56E7238B.7030807@xilinx.com>
References: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
 <1457896247-25934-5-git-send-email-moritz.fischer@ettus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <michal.simek@xilinx.com>, <joe@perches.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <moritz.fischer.private@gmail.com>
To: Moritz Fischer <moritz.fischer@ettus.com>,
	<nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457896247-25934-5-git-send-email-moritz.fischer@ettus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13.3.2016 20:10, Moritz Fischer wrote:
> Checkpatch suggests using ether_addr_copy over memcpy
> to copy the mac address.
> 
> Signed-off-by: Moritz Fischer <moritz.fischer@ettus.com>
> ---
>  drivers/net/ethernet/cadence/macb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 53400f6..a0c01e5 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2891,7 +2891,7 @@ static int macb_probe(struct platform_device *pdev)
>  
>  	mac = of_get_mac_address(np);
>  	if (mac)
> -		memcpy(bp->dev->dev_addr, mac, ETH_ALEN);
> +		ether_addr_copy(bp->dev->dev_addr, mac);
>  	else
>  		macb_get_hwaddr(bp);
>  
> 

Acked-by: Michal Simek <michal.simek@xilinx.com>
M
