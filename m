From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6] Re: xfrm_user.c doesn't use NLMSG_F_MULTI
Date: Tue, 19 Oct 2004 23:12:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019231256.1e4b039e.davem@davemloft.net>
References: <20041013080705.GB3387@obroa-skai.de.gnumonks.org>
	<E1CI2I2-0001sI-00@gondolin.me.apana.org.au>
	<20041014105757.GB12694@obroa-skai.de.gnumonks.org>
	<20041014110742.GA7910@gondor.apana.org.au>
	<20041015191444.GM17516@obroa-skai.de.gnumonks.org>
	<20041016094553.GA6546@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041016094553.GA6546@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 16 Oct 2004 19:45:53 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > --- linux-2.6.9-rc3-bk9-test/net/ipv4/tcp_diag.c	2004-10-10 14:01:47.000000000 +0200
> > +++ linux-2.6.9-rc3-bk9-test-xfrm_netlink/net/ipv4/tcp_diag.c	2004-10-15 21:02:19.000000000 +0200
> > @@ -97,7 +97,7 @@
> >  }
> >  
> >  static int tcpdiag_fill(struct sk_buff *skb, struct sock *sk,
> > -			int ext, u32 pid, u32 seq)
> > +			int ext, u32 pid, u32 seq, u16 nlmsg_flags)
> 
> The patch looks OK.  But I have some pending patches in this area (see
> http://oss.sgi.com/projects/netdev/archive/2004-10/msg00456.html).
> Could you please hold off on it for a while?

I just installed Herbert's patches from that thread.
Harald, you can redo your patch against that thread's
patches or just wait until it hits Linus's tree tonight
or tomorrow.

Please also take care of the issue Herbert pointed out
in the xfrm_user.c case wrt. dumping.
