From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [3/4] [IPSEC] Add route element to xfrm_dst
Date: Sun, 6 Mar 2005 21:28:00 -0800
Message-ID: <20050306212800.43d3d42e.davem@davemloft.net>
References: <20050214221006.GA18415@gondor.apana.org.au>
	<20050214221200.GA18465@gondor.apana.org.au>
	<20050214221433.GB18465@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050214221433.GB18465@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Feb 2005 09:14:33 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch adds a pointer to the route corresponding to the specific
> flow over the SA of an xfrm_dst that's being used.
> 
> It also sets the next pointer of each xfrm_dst to the one above it.
> This allows to traverse the list upwards from the bottom.

Applied, thanks Herbert.

I guess this back traversal list makes it impossible for us
to share xfrm_dst's for multiple unique flows even if that
could be possible, right?
