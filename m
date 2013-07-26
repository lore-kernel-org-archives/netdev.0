From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: use pre-defined macro in bond_mode_name
 instead of magic number 0
Date: Fri, 26 Jul 2013 13:54:09 -0700 (PDT)
Message-ID: <20130726.135409.1813499553216352267.davem@davemloft.net>
References: <51EF79E6.9060309@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org
To: shhuiw@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933090Ab3GZUyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 16:54:10 -0400
In-Reply-To: <51EF79E6.9060309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Sheng-Hui <shhuiw@gmail.com>
Date: Wed, 24 Jul 2013 14:53:26 +0800

> We have BOND_MODE_ROUNDROBIN pre-defined as 0, and it's the lowest
> mode number.
> Use it to check the arg lower bound instead of magic number 0 in
> bond_mode_name.
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
> ---
>  drivers/net/bonding/bond_main.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c
> b/drivers/net/bonding/bond_main.c
> index 07f257d4..5890def 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -273,7 +273,7 @@ const char *bond_mode_name(int mode)
>  		[BOND_MODE_ALB] = "adaptive load balancing",
>  	};
> 
> -	if (mode < 0 || mode > BOND_MODE_ALB)
> +	if (mode < BOND_MODE_ROUNDROBIN || mode > BOND_MODE_ALB)
>  		return "unknown";
> 
>  	return names[mode];

I applied this version of your patch, thanks.
