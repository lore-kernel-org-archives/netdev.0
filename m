From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: SKB BUG: Invalid truesize, current git
Date: Wed, 8 Nov 2006 13:39:39 -0500
Message-ID: <20061108183939.GI31439@kvack.org>
References: <20061106190725.GW9057@kvack.org> <20061106193620.GA1766@gondor.apana.org.au> <20061107.145724.129450194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:27585 "EHLO kanga.kvack.org")
	by vger.kernel.org with ESMTP id S1161463AbWKHSjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 13:39:49 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061107.145724.129450194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 07, 2006 at 02:57:24PM -0800, David Miller wrote:
> > Since pskb_copy tacks on the non-linear bits from the original
> > skb, it needs to count them in the truesize field of the new skb.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Applied, thanks Herbert.

This seems to work -- I haven't been able to trigger the message with the 
patch applied now.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
