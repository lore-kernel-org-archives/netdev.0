From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [21/*] [IPv4] Fix MTU check in ipmr_queue_xmit
Date: Fri, 18 Mar 2005 10:39:05 -0800
Message-ID: <20050318103905.0455cca8.davem@davemloft.net>
References: <20050214221433.GB18465@gondor.apana.org.au>
	<20050214221607.GC18465@gondor.apana.org.au>
	<20050306213214.7d8a143d.davem@davemloft.net>
	<20050307103536.GB7137@gondor.apana.org.au>
	<20050308102741.GA23468@gondor.apana.org.au>
	<20050314102614.GA9610@gondor.apana.org.au>
	<20050314105313.GA21001@gondor.apana.org.au>
	<20050314111002.GA29156@gondor.apana.org.au>
	<20050315091904.GA6256@gondor.apana.org.au>
	<20050315095837.GA7130@gondor.apana.org.au>
	<20050318090310.GA28443@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050318090310.GA28443@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Mar 2005 20:03:10 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Somehow I missed four files with dst_pmtu usages in them.  I'm going
> to split them along the sames lines I did before: bug fixes and then
> the trivial changes.

Must be some bug in your grep binary... kidding ;-)

> Here is a patch that replaces dst_pmtu with dst_pmtu in ipmr.c
> since this is straight IPIP tunneling equivalent to what we have
> in ipip.c.
> 
> As it is we may send ICMP packets when IPsec is present which is
> exactly what the comment says that we shouldn't do.
>  
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
