From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]: fixed typo of reassembly.c
Date: Fri, 1 Oct 2004 23:38:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001233832.34bd0a91.davem@davemloft.net>
References: <20041001151923.261b42b3.davem@davemloft.net>
	<E1CDc2I-0003wP-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yasuyuki.kozakai@toshiba.co.jp, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CDc2I-0003wP-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 02 Oct 2004 15:02:22 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> David S. Miller <davem@davemloft.net> wrote:
> > 
> > It is textual fix only, do you realize this?
> > Both ntohs() and htons() perform the same transformation
> > on a 16-bit data item.  It really does not matter which
> > one you actually use, in practice.
> 
> It might make a difference in future if the sparse people decide to
> annotate its arguments/return values.

That's true.  Al Viro has done this on the filesystems
and "cpu_to_{be,le}{16,32,64}()" et al. interfaces.

I'm sure he'll hit the networking before long.
