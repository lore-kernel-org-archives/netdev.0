From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPV4] Send TCP reset through dst_output in ipt_REJECT
Date: Thu, 17 Mar 2005 10:06:47 -0800
Message-ID: <20050317100647.7e518728.davem@davemloft.net>
References: <20050315091904.GA6256@gondor.apana.org.au>
	<20050315095837.GA7130@gondor.apana.org.au>
	<20050315100522.GA7275@gondor.apana.org.au>
	<20050315102450.0f3f1618.davem@davemloft.net>
	<42373142.6090902@trash.net>
	<20050315204006.GB22349@gondor.apana.org.au>
	<42374A35.6020308@trash.net>
	<20050316105100.GA8404@gondor.apana.org.au>
	<42388263.3090602@trash.net>
	<20050316144424.689d5981.davem@davemloft.net>
	<20050317105145.GA20089@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050317105145.GA20089@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Mar 2005 21:51:45 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I noticed that the TCP reset code in ipt_REJECT didn't call dst_output
> either so it also bypasses IPsec processing.  Here is a patch to fix
> that and use the correct MTU value.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks a lot Herbert.
