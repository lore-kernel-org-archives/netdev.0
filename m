From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [24/*] [IPSEC] Get ttl from child instead of path
Date: Fri, 18 Mar 2005 10:43:50 -0800
Message-ID: <20050318104350.009e6af7.davem@davemloft.net>
References: <20050307103536.GB7137@gondor.apana.org.au>
	<20050308102741.GA23468@gondor.apana.org.au>
	<20050314102614.GA9610@gondor.apana.org.au>
	<20050314105313.GA21001@gondor.apana.org.au>
	<20050314111002.GA29156@gondor.apana.org.au>
	<20050315091904.GA6256@gondor.apana.org.au>
	<20050315095837.GA7130@gondor.apana.org.au>
	<20050318090310.GA28443@gondor.apana.org.au>
	<20050318091129.GA28658@gondor.apana.org.au>
	<20050318091918.GA28944@gondor.apana.org.au>
	<20050318100757.GA29433@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050318100757.GA29433@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Mar 2005 21:07:57 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Now that dst_pmtu is almost gone let's do the same to dst_path_metric.
> I've only found one legitimate use of it and that's the one that was
> recently added in dst_allfrag.
> 
> This patch makes xfrm4_encap/xfrm6_encap use dst->child instead of
> dst->path so that we choose the correct route to get the hoplimit
> from when nested tunnels are present.
> 
> For simple tunnels dst->child == dst->path so there is no change.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks good, applied.

Thanks Herbert.
