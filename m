From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NET] Fix neighbour tbl->entries race
Date: Wed, 3 Nov 2004 15:54:38 -0800
Message-ID: <20041103155438.07a219ad.davem@davemloft.net>
References: <20041102112651.GA8633@gondor.apana.org.au>
	<1099404823.1021.15.camel@jzny.localdomain>
	<20041102203720.GA12108@gondor.apana.org.au>
	<20041102210259.GA12642@gondor.apana.org.au>
	<20041102220603.GA13312@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041102220603.GA13312@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 3 Nov 2004 09:06:03 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, Nov 03, 2004 at 08:02:59AM +1100, herbert wrote:
> > 
> > In fact, we can make it a bit more effective/fair by checking the
> > previous entries count as well.
> 
> Call me a flip-flop :) This extra check is silly because in the
> cases where it is done it is very unlikely to succeed.  So here
> is yet another update without that check.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.  We can make the proposed atomic_inc_return() enhancement
as a followon patch.

Can you cook up a 2.4.x version of this Herbert?  The new neighbour
code is now there too.
