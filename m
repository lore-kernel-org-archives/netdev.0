From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [SCTP] Replace spin_lock_irqsave with spin_lock_bh
Date: Thu, 02 Jun 2005 22:11:19 -0700 (PDT)
Message-ID: <20050602.221119.105431518.davem@davemloft.net>
References: <20050602094404.GA10316@gondor.apana.org.au>
	<20050602095459.GA26638@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050602095459.GA26638@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 2 Jun 2005 19:54:59 +1000

> The call in question is only called from recvmsg which means that
> IRQs aren't disabled.  Therefore it is safe to replace it with
> spin_lock_bh.
>  
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au> 

Also applied to net-2.6.13, thanks.
