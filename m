From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [Openswan dev] Re: CONFIG_XFRM vs udp.c
Date: Wed, 4 Aug 2004 07:27:53 +1000
Sender: dev-bounces@lists.openswan.org
Message-ID: <20040803212753.GA319@gondor.apana.org.au>
References: <22093.1091561579@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@oss.sgi.com>
Return-path: <dev-bounces@lists.openswan.org>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Content-Disposition: inline
In-Reply-To: <22093.1091561579@marajade.sandelman.ottawa.on.ca>
Cc: dev@lists.openswan.org
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/dev>
List-Post: <mailto:dev@lists.openswan.org>
List-Help: <mailto:dev-request@lists.openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=subscribe>
Errors-To: dev-bounces@lists.openswan.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 03, 2004 at 03:32:59PM -0400, Michael Richardson wrote:
> 
> It is it intentional that this part of XFRM can not be a module?

As it is XFRM cannot be built as a module at all.  This is only one
of the places in the IP stack that calls XFRM directly.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
