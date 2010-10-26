From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_hash: fix rcu sparse and logical errors
Date: Tue, 26 Oct 2010 11:43:32 -0700 (PDT)
Message-ID: <20101026.114332.191388048.davem@davemloft.net>
References: <1288099456.3169.110.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57224
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933301Ab0JZSnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 14:43:09 -0400
In-Reply-To: <1288099456.3169.110.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 Oct 2010 15:24:16 +0200

> While fixing CONFIG_SPARSE_RCU_POINTER errors, I had to fix accesses to
> fz->fz_hash for real.
> 
> -	&fz->fz_hash[fn_hash(f->fn_key, fz)]
> +	rcu_dereference(fz->fz_hash) + fn_hash(f->fn_key, fz)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
