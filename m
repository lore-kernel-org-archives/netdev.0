From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [Openswan dev] Re: [Openswan Users] Invalid argument NULL
Date: Tue, 17 Aug 2004 10:41:41 +1000
Sender: dev-bounces@lists.openswan.org
Message-ID: <20040817004141.GA18789@gondor.apana.org.au>
References: <BD428BAA.4BBE%jiva@ixiacom.com>
	<E1BwINn-0000ZX-00@gondolin.me.apana.org.au>
	<20040815112548.GA2864@gondor.apana.org.au>
	<20040815195313.31bacf13.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: users@lists.openswan.org
Return-path: <dev-bounces@lists.openswan.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040815195313.31bacf13.davem@redhat.com>
Cc: kuznet@ms2.inr.ac.ru
Cc: netdev@oss.sgi.com
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

On Sun, Aug 15, 2004 at 07:53:13PM -0700, David S. Miller wrote:
> 
> I've applied this for now.  There is a lot of duplication around
> the xfrm structures of this kind of information.

Yes we've got the numbers in x->props and the names in the x->*algo
structure.

The question is do we go with the numbers of the names? On the face
of it the names look like a good idea.  However, we can't do sets of
names as easily as we can do sets of numbers (the *algos mask in
xfrm_tmpl).  Further more, for the actual IKE negotiation, numbers
are required anyway.

So maybe we should keep the numbers?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
