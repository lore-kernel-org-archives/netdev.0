From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [14/*] [IPV6] Reload skb->dst after xfrm6_route_forward
Date: Mon, 14 Mar 2005 21:27:28 -0800
Message-ID: <20050314212728.75ce14e4.davem@davemloft.net>
References: <20050214221006.GA18415@gondor.apana.org.au>
	<20050214221200.GA18465@gondor.apana.org.au>
	<20050214221433.GB18465@gondor.apana.org.au>
	<20050214221607.GC18465@gondor.apana.org.au>
	<20050306213214.7d8a143d.davem@davemloft.net>
	<20050307103536.GB7137@gondor.apana.org.au>
	<20050308102741.GA23468@gondor.apana.org.au>
	<20050314102614.GA9610@gondor.apana.org.au>
	<20050314105313.GA21001@gondor.apana.org.au>
	<20050314111002.GA29156@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050314111002.GA29156@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Mar 2005 22:10:02 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> While replacing dst_pmtu in ip6_output I found this little gem.  In
> ip6_forward we're not reloading the dst pointer after calling
> xfrm6_route_forward.  So all subsequent dereferences of dst will
> refer to its pre-IPsec value.
> 
> The solution is of course to refresh its value.
>  
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Good catch Herbert.

Applied, thanks.
