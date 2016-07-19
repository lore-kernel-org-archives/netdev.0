From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH -next] net: ethernet: nb8800: fix error handling of nb8800_probe()
Date: Tue, 19 Jul 2016 12:37:14 +0100
Message-ID: <yw1x1t2peu51.fsf@unicorn.mansr.com>
References: <1468927990-3041-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: f.fainelli@gmail.com, davem@davemloft.net, tremyfr@gmail.com,
	arnd@arndb.de, sf84@laposte.net,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	netdev@vger.kernel.org
To: Wei Yongjun <weiyj_lk@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:52072 "EHLO unicorn.mansr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752866AbcGSLhV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 07:37:21 -0400
In-Reply-To: <1468927990-3041-1-git-send-email-weiyj_lk@163.com> (Wei
	Yongjun's message of "Tue, 19 Jul 2016 11:33:10 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wei Yongjun <weiyj_lk@163.com> writes:

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
> In ops->reset() error handling case, clk_disable_unprepare() is misse=
d
> before return from this function.
>
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Acked-by: Mans Rullgard <mans@mansr.com>

> ---
>  drivers/net/ethernet/aurora/nb8800.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ether=
net/aurora/nb8800.c
> index 2dcb8c7..0d4ea92 100644
> --- a/drivers/net/ethernet/aurora/nb8800.c
> +++ b/drivers/net/ethernet/aurora/nb8800.c
> @@ -1419,7 +1419,7 @@ static int nb8800_probe(struct platform_device =
*pdev)
>  	if (ops && ops->reset) {
>  		ret =3D ops->reset(dev);
>  		if (ret)
> -			goto err_free_dev;
> +			goto err_disable_clk;
>  	}
>
>  	bus =3D devm_mdiobus_alloc(&pdev->dev);
>

--=20
M=E5ns Rullg=E5rd
