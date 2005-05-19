From: "David S. Miller" <davem@davemloft.net>
Subject: Re: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at
 net/netlink/af_netlink.c (122)
Date: Thu, 19 May 2005 12:47:16 -0700 (PDT)
Message-ID: <20050519.124716.74565187.davem@davemloft.net>
References: <20050511005836.GA1674@gondor.apana.org.au>
	<4282846F.6070403@tpack.net>
	<20050511222210.GA21280@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tommy.christensen@tpack.net, chamas@h4.dion.ne.jp, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050511222210.GA21280@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 12 May 2005 08:22:10 +1000

> > What about an alternative fix, that avoids even more cloning (where
> > possible)? This resurrects the skb_orphan call that was moved out, last
> > time we had 'shared-skb troubles'. It is practically a no-op in the
> > common case, but still prevents the possible race with recvmsg.
> > (And I have a weakness for one-line-fixes). :-)
> 
> Yep this is much better.  Thanks Tommy.
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks a lot guys.
