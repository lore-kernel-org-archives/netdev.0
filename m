From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: fix __sk_stream_mem_reclaim
Date: Wed, 12 Jul 2006 17:59:10 -0700 (PDT)
Message-ID: <20060712.175910.85416957.davem@davemloft.net>
References: <5640c7e00607121623i34133297n6894878afd74f27e@mail.gmail.com>
	<E1G0pSx-0006ZI-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.mcdonald@jandi.co.nz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:22963
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932475AbWGMA7L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 20:59:11 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <E1G0pSx-0006ZI-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 13 Jul 2006 10:54:07 +1000

> Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> > __sk_stream_mem_reclaim is only called by sk_stream_mem_reclaim.
> > 
> > As such the check on sk->sk_forward_alloc is not needed and can be removed.
> > 
> > Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> What's more, even if the check does turn out to be false for some renegade
> caller, the function will still work since all the operations turn out to
> be no-ops.

Applied, thanks everyone.
