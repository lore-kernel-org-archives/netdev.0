From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [15/*] [INET] Fix IPsec calculation in
 ip_append_data/ip6_append_data
Date: Wed, 16 Mar 2005 14:02:54 -0800
Message-ID: <20050316140254.76f5e693.davem@davemloft.net>
References: <20050214221200.GA18465@gondor.apana.org.au>
	<20050214221433.GB18465@gondor.apana.org.au>
	<20050214221607.GC18465@gondor.apana.org.au>
	<20050306213214.7d8a143d.davem@davemloft.net>
	<20050307103536.GB7137@gondor.apana.org.au>
	<20050308102741.GA23468@gondor.apana.org.au>
	<20050314102614.GA9610@gondor.apana.org.au>
	<20050314105313.GA21001@gondor.apana.org.au>
	<20050314111002.GA29156@gondor.apana.org.au>
	<20050315091904.GA6256@gondor.apana.org.au>
	<20050316113149.GA10960@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050316113149.GA10960@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Mar 2005 22:31:49 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch is wrong.  This is the *one* place where we do need to
> use the path MTU.  The reason is that when the packet is fragmented
> we only pay for the IPsec overhead once over all and not once for
> each fragment.
> 
> Please revert it for now.

Ok, done.
