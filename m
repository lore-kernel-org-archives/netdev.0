From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 13:30:30 +0200
Message-ID: <20050518113030.GA15391@postel.suug.ch>
References: <20050517.104947.112621738.davem@davemloft.net> <E1DYAHF-0006qW-00@gondolin.me.apana.org.au> <20050518004733.GG13748@postel.suug.ch> <20050518011632.GA27813@gondor.apana.org.au> <20050518013712.GH13748@postel.suug.ch> <20050518015213.GB28070@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, akepner@sgi.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050518015213.GB28070@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <20050518015213.GB28070@gondor.apana.org.au> 2005-05-18 11:52
> On Wed, May 18, 2005 at 03:37:12AM +0200, Thomas Graf wrote:
> > 
> > OK, I initially thought you would head for a much larger
> > threshold. Not sure if 30000 is large enough for a full
> > scale NFS server though ;-> You conviced me that my idea
> 
> I think it's big enough.  If it isn't it means that somebody
> has reordered the packets by 30000 which I find hard to
> believe :)

I was thinking about some kind of nfs server with huge recv
buffers and increased limits receiving at 50kpps experiencing
a delayed fragment once in a while. Definitely a rare case
but not impossible ;->
