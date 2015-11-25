From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: net: Generalise wq_has_sleeper helper
Date: Wed, 25 Nov 2015 09:10:56 +0800
Message-ID: <20151125011056.GA5907@gondor.apana.org.au>
References: <20151023124006.GA17308@twins.programming.kicks-ass.net>
 <20151111094829.GA23202@gondor.apana.org.au>
 <20151124055423.GA31611@gondor.apana.org.au>
 <20151124.163025.1551408934471757005.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peterz@infradead.org, tatsu@ab.jp.nec.com, mingo@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jolsa@redhat.com, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151124.163025.1551408934471757005.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 24, 2015 at 04:30:25PM -0500, David Miller wrote:
>
> I'm fine with wherever this patch goes.  Herbert is there any
> particular tree where it'll facilitate another user quickest?
> 
> Or should I just toss it into net-next?
> 
> Acked-by: David S. Miller <davem@davemloft.net>

No Dave net-next is fine I think.  This was prompted by Tatsukawa-san's
patches to fix waitqueue users affected by this very race and they
were all over the tree.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
