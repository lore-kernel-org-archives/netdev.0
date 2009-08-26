From: DDD <Dongdong.deng@windriver.com>
Subject: Re: [PATCH] smc91x: fix compilation on SMP
Date: Wed, 26 Aug 2009 17:39:58 +0800
Message-ID: <1251279598.7267.21.camel@dengdd-desktop>
References: <20090826085526.GA3209@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49306 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756446AbZHZJ1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 05:27:43 -0400
In-Reply-To: <20090826085526.GA3209@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexey,

Thanks for you correct me. :-)

For "smc91x", I just compile it on an old linux version, and merge the
changes to the latest linux for creating a patch. 
I think it must be OK, so I didn't compile the patch on the latest
linux. 

I'm so sorry for my careless.


Dongdong


On Wed, 2009-08-26 at 12:55 +0400, Alexey Dobriyan wrote:
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  drivers/net/smc91x.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- a/drivers/net/smc91x.c
> +++ b/drivers/net/smc91x.c
> @@ -531,7 +531,7 @@ static inline void  smc_rcv(struct net_device *dev)
>  		local_irq_restore(flags);				\
>  	__ret;								\
>  })
> -#define smc_special_lock(lock, flags)		spin_lock_irq(lock, flags)
> +#define smc_special_lock(lock, flags)		spin_lock_irqsave(lock, flags)
>  #define smc_special_unlock(lock, flags) 	spin_unlock_irqrestore(lock, flags)
>  #else
>  #define smc_special_trylock(lock, flags)	(1)
