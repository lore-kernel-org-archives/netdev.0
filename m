From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] dm9000: fix compilation
Date: Mon, 17 Nov 2008 08:23:17 +0800
Message-ID: <4920B975.6030703@cn.fujitsu.com>
References: <20081115183730.GA2639@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63849 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751861AbYKQAXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Nov 2008 19:23:23 -0500
In-Reply-To: <20081115183730.GA2639@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan said the following on 2008-11-16 2:37:
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  drivers/net/dm9000.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -1447,7 +1447,7 @@ dm9000_drv_remove(struct platform_device *pdev)
>  	platform_set_drvdata(pdev, NULL);
>  
>  	unregister_netdev(ndev);
> -	dm9000_release_board(pdev, (board_info_t *) netdev_priv(ndev);
> +	dm9000_release_board(pdev, (board_info_t *) netdev_priv(ndev));

My bad.
I did "make allmodconfig", but it didn't config dm9000 on i386.
Reviewed-by: Wang Chen <wangchen@cn.fujitsu.com>

