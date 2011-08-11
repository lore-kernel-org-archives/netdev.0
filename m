From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sh_irda: fixup build error on v3.1
Date: Wed, 10 Aug 2011 23:15:58 -0700 (PDT)
Message-ID: <20110810.231558.2202030270747790994.davem@davemloft.net>
References: <87aabgwl9y.wl%kuninori.morimoto.gx@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kuninori.morimoto.gx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46803 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116Ab1HKGQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 02:16:01 -0400
In-Reply-To: <87aabgwl9y.wl%kuninori.morimoto.gx@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kuninori Morimoto <kuninori.morimoto.gx@gmail.com>
Date: Wed, 10 Aug 2011 22:49:01 -0700 (PDT)

> @@ -171,7 +173,7 @@ static void sh_irda_write(struct sh_irda_self *self, u32 offset, u16 data)
>  	unsigned long flags;
>  
>  	spin_lock_irqsave(&self->lock, flags);
> -	iowrite16(data, self->membase + offset);
> +	__raw_writew(data, self->membase + offset);
>  	spin_unlock_irqrestore(&self->lock, flags);

Every platform, including "sh", provides ioread16() and iowrite16().

So changing this is not part of "fixup build error" as your commit
message states.

If this change is needed, it should be in a seperate commit and with
a proper explanation in the commit message.
