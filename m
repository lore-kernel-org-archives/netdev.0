From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [5/*] [IPSEC] Use dst_mtu in xfrm[46]_output
Date: Sun, 6 Mar 2005 21:33:33 -0800
Message-ID: <20050306213333.4e2e47e9.davem@davemloft.net>
References: <20050214221006.GA18415@gondor.apana.org.au>
	<20050214221200.GA18465@gondor.apana.org.au>
	<20050214221433.GB18465@gondor.apana.org.au>
	<20050214221607.GC18465@gondor.apana.org.au>
	<20050216103744.GA476@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050216103744.GA476@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Feb 2005 21:37:44 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> There was a lot of fun in laying the foundations.  Now it's time
> to start using it.
> 
> This patch fixes the calculations in xfrm[46]_output so that we don't
> reject properly sized packets from the TCP stack.  The previous
> calculation is wrong because the xfrm overhead is not constant.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> After this I'll start cleaning stuff up.  For example, tcp's
> ext2_header_len and dst's path can both be removed.

Looks good, applied.
