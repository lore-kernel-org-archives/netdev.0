From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] arp_queue: serializing unlink + kfree_skb
Date: Fri, 4 Feb 2005 07:30:10 +1100
Message-ID: <20050203203010.GA7081@gondor.apana.org.au>
References: <20050131102920.GC4170@suse.de> <E1CvZo6-0001Bz-00@gondolin.me.apana.org.au> <20050203142705.GA11318@krispykreme.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olaf Kirch <okir@suse.de>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Content-Disposition: inline
In-Reply-To: <20050203142705.GA11318@krispykreme.ozlabs.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Feb 04, 2005 at 01:27:05AM +1100, Anton Blanchard wrote:
> 
> Architectures should guarantee that any of the atomics and bitops that
> return values order in both directions. So you dont need the
> smp_mb__before_atomic_dec here.

I wasn't aware of this requirement before.  However, if this is so,
why don't we get rid of the smp_mb__* macros?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
