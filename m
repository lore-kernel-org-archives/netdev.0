From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NET] Check skb_header_cloned for TSO packets in ixgb
Date: Thu, 24 Feb 2005 11:30:54 -0800
Message-ID: <20050224113054.51a2020e.davem@davemloft.net>
References: <20050126110043.GA29950@yakov.inr.ac.ru>
	<20050126222522.GA21670@gondor.apana.org.au>
	<20050127110946.GA20494@gondor.apana.org.au>
	<20050127111201.GB20494@gondor.apana.org.au>
	<20050128202542.GA23670@yakov.inr.ac.ru>
	<20050129031740.GA6130@gondor.apana.org.au>
	<20050129032210.GA7424@gondor.apana.org.au>
	<20050215103312.6178385f.davem@davemloft.net>
	<20050215202453.GA4355@gondor.apana.org.au>
	<20050223195137.1e769c77.davem@davemloft.net>
	<20050224102951.GA23562@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050224102951.GA23562@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 24 Feb 2005 21:29:51 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, Feb 23, 2005 at 07:51:37PM -0800, David S. Miller wrote:
> > 
> > Also queued to 2.6.12, thanks.  Someone should cook up the versions
> > for other drivers supporting TSO.
> 
> I only found one other TSO driver that touches the headers, ixgb.
> Here is the patch which adds an skb_header_cloned check to it.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.

> Do you know of any others?

I thought there was another that messed with the headers, but I
can't spot it anymore :-)
