From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [13/*] [IPV4] Fix room calculation in icmp_send
Date: Mon, 14 Mar 2005 21:26:43 -0800
Message-ID: <20050314212643.67f63669.davem@davemloft.net>
References: <20050214221006.GA18415@gondor.apana.org.au>
	<20050214221200.GA18465@gondor.apana.org.au>
	<20050214221433.GB18465@gondor.apana.org.au>
	<20050214221607.GC18465@gondor.apana.org.au>
	<20050306213214.7d8a143d.davem@davemloft.net>
	<20050307103536.GB7137@gondor.apana.org.au>
	<20050308102741.GA23468@gondor.apana.org.au>
	<20050314102614.GA9610@gondor.apana.org.au>
	<20050314105313.GA21001@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050314105313.GA21001@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Mar 2005 21:53:13 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I'm now cleaning up all users of dst_pmtu with the aim of replacing
> dst_pmtu with dst_mtu.  I'm going to start with the ones that actually
> fix bugs.
> 
> This patch fixes the length calculation in icmp_send.  As it is
> we're overestimating the space available by including the space
> that would be used up by IPsec encapsulation.
> 
> IPv6 doesn't have this problem since its calculation is based
> on 1280 instead of the PMTU.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
