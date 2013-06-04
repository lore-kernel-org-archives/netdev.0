From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH -next] net: sun4i-emac: fix a typo in emac_probe()
Date: Tue, 4 Jun 2013 15:24:08 +0200
Message-ID: <20130604132408.GD3283@lukather>
References: <CAPgLHd-fXnt9H_CxDD1Ww=C-6nn3COVkYirKY6ucOJVR2Pkwkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: grant.likely@linaro.org, rob.herring@calxeda.com,
	davem@davemloft.net, sr@denx.de, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:57591 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753978Ab3FDNYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 09:24:11 -0400
Content-Disposition: inline
In-Reply-To: <CAPgLHd-fXnt9H_CxDD1Ww=C-6nn3COVkYirKY6ucOJVR2Pkwkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Jun 03, 2013 at 09:36:52PM +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Just fixed a typo in emac_probe().
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/ethernet/allwinner/sun4i-emac.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
> index b411344..26083cd 100644
> --- a/drivers/net/ethernet/allwinner/sun4i-emac.c
> +++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
> @@ -821,7 +821,7 @@ static int emac_probe(struct platform_device *pdev)
>  	db->membase = of_iomap(np, 0);
>  	if (!db->membase) {
>  		dev_err(&pdev->dev, "failed to remap registers\n");
> -		return -ENOMEM;
> +		ret = -ENOMEM;
>  		goto out;
>  	}
>  
> 

Ouch, nice catch.
Thanks!

Acked-by: Maxime Ripard <maxime.ripard@free-electrons.com>
