From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Fix ___pskb_trim when entire frag_list needs dropping
Date: Sun, 30 Jul 2006 15:46:50 -0700 (PDT)
Message-ID: <20060730.154650.62668232.davem@davemloft.net>
References: <20060713090341.GA28426@gondor.apana.org.au>
	<20060729114525.GA10549@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pupilla@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51333
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964775AbWG3Wqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 18:46:39 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060729114525.GA10549@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 29 Jul 2006 21:45:25 +1000

> [NET]: Fix ___pskb_trim when entire frag_list needs dropping
> 
> When the trim point is within the head and there is no paged data,
> ___pskb_trim fails to drop the first element in the frag_list.
> This patch fixes this by moving the len <= offset case out of the
> page data loop.
> 
> This patch also adds a missing kfree_skb on the frag that we just
> cloned.
>  
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
