From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPV4/IPV6] Replace spin_lock_irq with spin_lock_bh
Date: Thu, 02 Jun 2005 22:10:26 -0700 (PDT)
Message-ID: <20050602.221026.112287995.davem@davemloft.net>
References: <20050602094404.GA10316@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050602094404.GA10316@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 2 Jun 2005 19:44:04 +1000

> In light of my recent patch to net/ipv4/udp.c that replaced the
> spin_lock_irq calls on the receive queue lock with spin_lock_bh,
> here is a similar patch for all other occurences of spin_lock_irq
> on receive/error queue locks in IPv4 and IPv6.
> 
> In these stacks, we know that they can only be entered from user
> or softirq context.  Therefore it's safe to disable BH only.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au> 

Applied to net-2.6.13, thanks Herbert.
