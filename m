From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [22/*] [NETFILTER] Use correct IPsec MTU in TCPMSS
Date: Fri, 18 Mar 2005 10:40:13 -0800
Message-ID: <20050318104013.57d65e99.davem@davemloft.net>
References: <20050214221607.GC18465@gondor.apana.org.au>
	<20050306213214.7d8a143d.davem@davemloft.net>
	<20050307103536.GB7137@gondor.apana.org.au>
	<20050308102741.GA23468@gondor.apana.org.au>
	<20050314102614.GA9610@gondor.apana.org.au>
	<20050314105313.GA21001@gondor.apana.org.au>
	<20050314111002.GA29156@gondor.apana.org.au>
	<20050315091904.GA6256@gondor.apana.org.au>
	<20050315095837.GA7130@gondor.apana.org.au>
	<20050318090310.GA28443@gondor.apana.org.au>
	<20050318091129.GA28658@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050318091129.GA28658@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Mar 2005 20:11:29 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch makes ipt_TCPMSS use the correct MTU value for clamping.
> This is a bit tricky actually since TCPMSS can be used in FORWARD,
> LOCAL_OUT as well as POST_ROUTING.
> 
> In the first two cases we haven't performed IPsec yet so dst_mtu
> obviously does the right thing.  As it is, POST_ROUTING is performed
> after xfrm_output so MSS clamping is useless there.
> 
> With Patrick's IPsec netfilter stuff, there will be a POST_ROUTING
> processing before IPsec processing, in which case dst_mtu also returns
> exactly what we want.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.

> BTW Patrick, how is the IPsec netfilter stuff going?

That boy is seriously backlogged, so I'm not sure how much time
he's gotten to work on that yet.
