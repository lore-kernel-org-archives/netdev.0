From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] lpc_eth: Use resource_size instead of computation
Date: Sun, 01 Jun 2014 19:27:05 -0700 (PDT)
Message-ID: <20140601.192705.693805935389177182.davem@davemloft.net>
References: <1401290047-30005-1-git-send-email-benoit.taine@lip6.fr>
	<1401290047-30005-3-git-send-email-benoit.taine@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: benoit.taine@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401290047-30005-3-git-send-email-benoit.taine@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benoit Taine <benoit.taine@lip6.fr>
Date: Wed, 28 May 2014 17:14:07 +0200

> @@ -1419,8 +1419,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
>  
>  	netdev_dbg(ndev, "IO address start     :0x%08x\n",
>  			res->start);
> -	netdev_dbg(ndev, "IO address size      :%d\n",
> -			res->end - res->start + 1);
> +	netdev_dbg(ndev, "IO address size      :%d\n", resource_size(res));
>  	netdev_dbg(ndev, "IO address (mapped)  :0x%p\n",
>  			pldat->net_base);

Please replace all of this with %pR as suggested by Joe, thanks.
