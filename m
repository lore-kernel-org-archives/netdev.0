From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [7/*] [IPSEC] Get metrics for xfrm_dst from top dst
Date: Sun, 6 Mar 2005 21:47:54 -0800
Message-ID: <20050306214754.7a1839e1.davem@davemloft.net>
References: <20050214221006.GA18415@gondor.apana.org.au>
	<20050214221200.GA18465@gondor.apana.org.au>
	<20050214221433.GB18465@gondor.apana.org.au>
	<20050214221607.GC18465@gondor.apana.org.au>
	<20050216103744.GA476@gondor.apana.org.au>
	<20050216110842.GA1024@gondor.apana.org.au>
	<20050216113836.GA1652@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050216113836.GA1652@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Feb 2005 22:38:36 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> For the metrics other than MTU, we should also be getting it from
> the top dst as opposed to the bottom dst.  With this change, the
> user is able to manipulate values such as advmss for individual
> hosts behind a remote IPsec gateway.
>  
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, great work Herbert.

This is the last patch I saw in this series.  Any more stuff
you have ready to apply in this area?

My net-2.6 tree at:

	bk://kernel.bkbits.net/davem/net-2.6

has all of the patches I applied today in it.  I'll push that
to Linus tomorrow most likely.
