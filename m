From: Wichert Akkerman <wichert@wiggy.net>
Subject: Re: sendmsg ignoring bind?
Date: Fri, 20 May 2005 15:31:44 +0200
Message-ID: <20050520133144.GE4151@wiggy.net>
References: <20050520081805.GR25658@wiggy.net> <20050520101749.GA8661@gondor.apana.org.au> <20050520132009.GD4151@wiggy.net> <20050520132429.GA32695@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050520132429.GA32695@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Previously Herbert Xu wrote:
> I suppose we can expect to have this in a future release of strace :)

It just might happen :)

> > cmsg_type=IP_PKTINFO, {ifindex=0,ipi_spec_dst=inet_addr("0.0.0.0"),ipi_addr=("0.0.0.0")}}, msg_flags=0},
> 
> This is far from useless.  This will set the source address back to zero
> which essentially means that the bound address is ignored.

I can see it being useful, except in my case it is somewhat unexpected
and undesirable behaviour. I'll make sure to have that fixed in
FreeRADIUS though.

Wichert.

-- 
Wichert Akkerman <wichert@wiggy.net>    It is simple to make things.
http://www.wiggy.net/                   It is hard to make things simple.
