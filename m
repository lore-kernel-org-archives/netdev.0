From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Change masquerade code to use first IP address of
 interface.
Date: Wed, 20 Oct 2004 22:29:38 -0700
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20041020222938.0dee0d5b.davem@davemloft.net>
References: <E1CKBtq-0005FC-00@gondolin.me.apana.org.au>
	<Pine.LNX.4.61.0410201123200.25590@filer.marasystems.com>
	<20041020104650.GA20868@gondor.apana.org.au>
	<Pine.LNX.4.61.0410201300580.28452@filer.marasystems.com>
	<20041020111245.GA22703@gondor.apana.org.au>
	<1098319849.10571.155.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
	herbert@gondor.apana.org.au, hno@marasystems.com
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <1098319849.10571.155.camel@localhost.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004 10:50:49 +1000
Rusty Russell <rusty@rustcorp.com.au> wrote:

> On Wed, 2004-10-20 at 21:12, Herbert Xu wrote:
> > On Wed, Oct 20, 2004 at 01:04:51PM +0200, Henrik Nordstrom wrote:
> > > On Wed, 20 Oct 2004, Herbert Xu wrote:
> > > 
> > > >I mean
> > > >
> > > >	rt = (struct rtable *)(*pskb)->dst;
> > > >	newsrc = inet_select_addr(out, rt->rt_gateway, RT_SCOPE_UNIVERSE);
> > > 
> > > IIRC we are not allowed to access this here, but I may be wrong.. If we 
> > 
> > Why? POST_ROUTING is called in three places in ip_output.c and they all
> > give a valid dst.  In fact ip_refrag in ip_conntrack_standalone.c is also
> > accessing skb->dst.
> 
> Yeah, I like it.  Please send patch on top of mine to Dave, and we'll
> see what blows up.

Patrick feel free to send this along to me whenever you like.
