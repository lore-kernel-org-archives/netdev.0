From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Openswan dev] IPComp
Date: Wed, 7 Jul 2004 07:31:35 +1000
Sender: dev-bounces@lists.openswan.org
Message-ID: <20040706213135.GA21477@gondor.apana.org.au>
References: <20040703113732.GA22082@gondor.apana.org.au>
	<Xine.LNX.4.44.0407061031090.22633-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@lists.openswan.org
Return-path: <dev-bounces@lists.openswan.org>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0407061031090.22633-100000@thoron.boston.redhat.com>
Cc: netdev@oss.sgi.com
Cc: Paul Wouters <paul@xelerance.com>
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/dev>
List-Post: <mailto:dev@lists.openswan.org>
List-Help: <mailto:dev-request@lists.openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=subscribe>
Errors-To: dev-bounces@lists.openswan.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 06, 2004 at 10:34:55AM -0400, James Morris wrote:
> 
> It's only called when an SA is initialized.  This should not happen all 
> the time, and if you can't find 64k for such an ooperation you have big 
> problems.

With most KMs the SAs are renegotiated periodically.  So as time
goes on memory fragmentation will eventually cause this to fail.
You also to consider IPsec gateways where there are hundreds or
thousands of SAs.

Maybe we can use a vmalloc instead? That seems to be what the
deflate module does.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
