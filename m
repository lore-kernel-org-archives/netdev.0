From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC] Kill redundan dst_release check in xfrm_dst_destroy
Date: Mon, 7 Mar 2005 09:35:48 -0800
Message-ID: <20050307093548.1c10ef80.davem@davemloft.net>
References: <20050214221006.GA18415@gondor.apana.org.au>
	<20050214221200.GA18465@gondor.apana.org.au>
	<20050214221433.GB18465@gondor.apana.org.au>
	<20050307101657.GA7486@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050307101657.GA7486@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 7 Mar 2005 21:16:57 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Here's a trivial patch to get rid of a redundant check that I added
> in patch 3/4.  dst_release already checks for dst == NULL.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
