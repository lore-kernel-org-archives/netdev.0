From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [27/*] [NET] Make dst_allfrag use dst instead of dst->path
Date: Fri, 18 Mar 2005 10:47:34 -0800
Message-ID: <20050318104734.27da53e6.davem@davemloft.net>
References: <20050314105313.GA21001@gondor.apana.org.au>
	<20050314111002.GA29156@gondor.apana.org.au>
	<20050315091904.GA6256@gondor.apana.org.au>
	<20050315095837.GA7130@gondor.apana.org.au>
	<20050318090310.GA28443@gondor.apana.org.au>
	<20050318091129.GA28658@gondor.apana.org.au>
	<20050318091918.GA28944@gondor.apana.org.au>
	<20050318100757.GA29433@gondor.apana.org.au>
	<20050318101126.GA29583@gondor.apana.org.au>
	<20050318110611.GA5843@gondor.apana.org.au>
	<20050318112804.GA6930@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050318112804.GA6930@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Mar 2005 22:28:04 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Rather than doing that, let's make the path usage explicit in
> the one place that it's needed (the same place where we use
> dst_mtu(dst->path)).
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Ok, applied.

> Hmm, it still doesn't feel right to have an IPv6-specific helper
> in net/dst.h.

We have tons of stuff in the neighbour layer that really is
only taken advantage of by ipv6, it's a similar situation.
