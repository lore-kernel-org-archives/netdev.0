From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Tue, 28 Sep 2004 21:02:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928210225.47b6038e.davem@davemloft.net>
References: <20040928024614.GA9911@gondor.apana.org.au>
	<1096340772.8659.51.camel@jzny.localdomain>
	<20040928032321.GB10116@gondor.apana.org.au>
	<1096343125.8661.96.camel@jzny.localdomain>
	<20040928035921.GA10675@gondor.apana.org.au>
	<1096367787.8662.146.camel@jzny.localdomain>
	<20040928111159.GA18421@gondor.apana.org.au>
	<1096374736.8663.217.camel@jzny.localdomain>
	<20040929001327.GB25293@gondor.apana.org.au>
	<1096426324.1044.129.camel@jzny.localdomain>
	<20040929032724.GA26959@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, pablo@eurodev.net, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040929032724.GA26959@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 13:27:24 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, Sep 28, 2004 at 10:52:05PM -0400, jamal wrote:
> >
> > > You're right.  rtmsg_info() is using GOODISZE unnecessarily.  I'll
> > > write up a patch.
> > 
> > But why? ;->
> 
> So that the alloc_skb() is slightly less likely to fail.  The dumpers
> gain a lot by using GOODSIZE since they can fill it up.  As rtmsg_info
> has no chance of getting anywhere near GOODSIZE we should provide a
> more accruate estimate.
> 
> It also means that with netlink_trim() you'll save a realloc/copy.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> Dave, you can stop reading now :)

Hehe, ok.  Patch applied :-)

Thanks.
