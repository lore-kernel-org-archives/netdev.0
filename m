From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] net: dev_close_many() is static
Date: Thu, 20 Jan 2011 11:16:28 +0200
Message-ID: <201101201116.29031.opurdila@ixiacom.com>
References: <1295508202.2653.483.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:2798 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754919Ab1ATJQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 04:16:31 -0500
In-Reply-To: <1295508202.2653.483.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thursday 20 January 2011, 09:23:22

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Octavian Purdila <opurdila@ixiacom.com>
> ---
>  net/core/dev.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 7c6a46f..c135268 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1285,7 +1285,7 @@ static int __dev_close(struct net_device *dev)
>  	return __dev_close_many(&single);
>  }
> 
> -int dev_close_many(struct list_head *head)
> +static int dev_close_many(struct list_head *head)
>  {
>  	struct net_device *dev, *tmp;
>  	LIST_HEAD(tmp_list);

Oops, missed that. Thanks Eric !

Reviewed-by: Octavian Purdila <opurdila@ixiacom.com>
