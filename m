From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: Fw: unregister_netdevice(): negative refcnt, suggest patch against 2.6.11
Date: Mon, 18 Apr 2005 11:48:13 -0300
Message-ID: <39e6f6c705041807481bb715d6@mail.gmail.com>
References: <20050411125113.GL26731@postel.suug.ch>
	 <E1DNLfx-0000yd-00@gondolin.me.apana.org.au>
	 <20050418080902.GA5675@gondor.apana.org.au>
Reply-To: acme@ghostprotocols.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Thomas Graf <tgraf@suug.ch>, fmp@palmen.homeip.net, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050418080902.GA5675@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 4/18/05, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Mon, Apr 18, 2005 at 12:07:49PM +1000, Herbert Xu wrote:
> >
> > Indeed.  Here is a patch that adds the references that are held by
> > the routes.
> 
> BTW, there are other problems in the appletalk stack that should
> be fixed too.  For instance, the route entries and skb's there don't
> hold a reference to the device that they point to.  So if anyone is
> going to spend time on appletalk then they should have a look at them.

Appletalk is known to be in need of a major reworking, I haven't had time
so far to devote to it even being listed as "MAINTAINER" of such stuff,
perhaps I should send a patch dropping maintainership.

After I'm satisfied with DCCP I may well revisit Appletalk to use the skills I
got/new infrastructure I put in place while working on DCCP, time will tell.

- Arnaldo
