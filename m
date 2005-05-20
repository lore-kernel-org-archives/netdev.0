From: Wichert Akkerman <wichert@wiggy.net>
Subject: Re: sendmsg ignoring bind?
Date: Fri, 20 May 2005 15:20:09 +0200
Message-ID: <20050520132009.GD4151@wiggy.net>
References: <20050520081805.GR25658@wiggy.net> <20050520101749.GA8661@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050520101749.GA8661@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Previously Herbert Xu wrote:
> This could be a cmsg option that overrode the bind address.  Please
> decode it so that we know what it's doing.

I had to hack strace a bit to decode that. The cmsg option turns out
to be somewhat useless:

cmsg_type=IP_PKTINFO, {ifindex=0,ipi_spec_dst=inet_addr("0.0.0.0"),ipi_addr=("0.0.0.0")}}, msg_flags=0},

Wichert.

-- 
Wichert Akkerman <wichert@wiggy.net>    It is simple to make things.
http://www.wiggy.net/                   It is hard to make things simple.
