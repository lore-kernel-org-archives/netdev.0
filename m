From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Openswan Users] Invalid argument NULL
Date: Tue, 17 Aug 2004 11:17:17 +1000
Sender: users-bounces@lists.openswan.org
Message-ID: <20040817011717.GA18992@gondor.apana.org.au>
References: <BD428BAA.4BBE%jiva@ixiacom.com>
	<E1BwINn-0000ZX-00@gondolin.me.apana.org.au>
	<20040815112548.GA2864@gondor.apana.org.au>
	<20040815195313.31bacf13.davem@redhat.com>
	<20040817004141.GA18789@gondor.apana.org.au>
	<20040816180350.780e4912.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: users@lists.openswan.org
Return-path: <users-bounces@lists.openswan.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040816180350.780e4912.davem@redhat.com>
Cc: kuznet@ms2.inr.ac.ru
Cc: netdev@oss.sgi.com
Cc: dev@lists.openswan.org
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/users>,
	<mailto:users-request@lists.openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/users>
List-Post: <mailto:users@lists.openswan.org>
List-Help: <mailto:users-request@lists.openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/users>,
	<mailto:users-request@lists.openswan.org?subject=subscribe>
Errors-To: users-bounces@lists.openswan.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 16, 2004 at 06:03:50PM -0700, David S. Miller wrote:
> On Tue, 17 Aug 2004 10:41:41 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > So maybe we should keep the numbers?
> 
> If we take out the names, won't this break xfrm_user apps
> that currently can receive them?

I mean that we should keep the numbers internally.  So xfrm_user.c
will translate the names given by existing applications into numbers
as the patch that you've just applied does.

We can then create a new NETLINK payload type that uses numbers if
we wish.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
