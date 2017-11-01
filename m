From: Alexander Dahl <ada@thorsis.com>
Subject: Re: [PATCH] net: macb: remove redundant assignment to variable work_done
Date: Wed, 01 Nov 2017 10:08:07 +0100
Message-ID: <3739420.Z09RPnxjzp@ada>
References: <20171031142324.25740-1-colin.king@canonical.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Nicolas Ferre <nicolas.ferre@microchip.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171031142324.25740-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hei hei,

Am Dienstag, 31. Oktober 2017, 14:23:24 CET schrieb Colin King:
> --- a/drivers/net/ethernet/cadence/macb_main.c
> +++ b/drivers/net/ethernet/cadence/macb_main.c
> @@ -1218,8 +1218,6 @@ static int macb_poll(struct napi_struct *napi, int
> budget) status = macb_readl(bp, RSR);
>  	macb_writel(bp, RSR, status);
> 
> -	work_done = 0;
> -
>  	netdev_vdbg(bp->dev, "poll: status = %08lx, budget = %d\n",
>  		    (unsigned long)status, budget);

Looks reasonable, when looking at the surrounding code.

Applied this on top of 4.14-rc7 and tested it on an at91sam9g20 based 
platform.

Tested-by: Alexander Dahl <ada@thorsis.com>

Greets
Alex
