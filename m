From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Problem with "ESP: sha1 digestsize 20 != 0"
Date: Thu, 3 Feb 2005 15:43:51 -0800
Message-ID: <20050203154351.1c653848.davem@davemloft.net>
References: <1107461073.6833.8.camel@pegasus>
	<E1CwnlK-0001rv-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CwnlK-0001rv-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 04 Feb 2005 07:39:38 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Marcel Holtmann <marcel@holtmann.org> wrote:
> > 
> > when using my RAS account with 2.6.11-rc3, I see a lot of
> > 
> > 	ESP: sha1 digestsize 20 != 0
> > 
> > messages in my logs and the IPsec tunnel is not working. I tracked the
> > problem down to the change below. After reverting this patch, everything
> > works like before.
> 
> Sorry, my fault.
> 
> The name test in xfrm_get_byname is inverted.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
