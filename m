From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 03:37:12 +0200
Message-ID: <20050518013712.GH13748@postel.suug.ch>
References: <20050517.104947.112621738.davem@davemloft.net> <E1DYAHF-0006qW-00@gondolin.me.apana.org.au> <20050518004733.GG13748@postel.suug.ch> <20050518011632.GA27813@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, akepner@sgi.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050518011632.GA27813@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <20050518011632.GA27813@gondor.apana.org.au> 2005-05-18 11:16
> On Wed, May 18, 2005 at 02:47:33AM +0200, Thomas Graf wrote:
> > 
> > I like this, although the problem is derived to the definition
> > of the threshold. Any ideas on how to define this? A
> 
> The threshold doesn't need to be very large at all since it is
> essentially the maximum reordering distance that we allow.
> 
> However, for an initial estimate we can be conservative and
> use something like 30000.  If we're too conservative the SGI
> guys will tell us :)

OK, I initially thought you would head for a much larger
threshold. Not sure if 30000 is large enough for a full
scale NFS server though ;-> You conviced me that my idea
doesn't have any real advantage over yours, it essentialy
gets down the same result but yours is probably easier to
implement and we can also adopt the threshold dynamicaly
depending on the type of system. A big advantage is surely
that it is quite easy to tune this parameter for certain
more difficult cases.
