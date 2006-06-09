From: David Miller <davem@davemloft.net>
Subject: Re: [4/3] [NET]: Warn in __skb_trim if skb is paged
Date: Fri, 09 Jun 2006 16:13:51 -0700 (PDT)
Message-ID: <20060609.161351.107684565.davem@davemloft.net>
References: <20060609074234.GA17580@gondor.apana.org.au>
	<20060609075538.GA22828@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37087
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030355AbWFIXNt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 19:13:49 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060609075538.GA22828@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 9 Jun 2006 17:55:39 +1000

> [NET]: Warn in __skb_trim if skb is paged
> 
> It's better to warn and fail rather than rarely triggering BUG on paths
> that incorrectly call skb_trim/__skb_trim on a non-linear skb.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Agreed, patch applied, thanks a lot Herbert.
