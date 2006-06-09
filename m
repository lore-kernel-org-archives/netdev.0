From: David Miller <davem@davemloft.net>
Subject: Re: [3/3] [NET]: skb_trim audit
Date: Fri, 09 Jun 2006 16:13:10 -0700 (PDT)
Message-ID: <20060609.161310.77059866.davem@davemloft.net>
References: <20060609074234.GA17580@gondor.apana.org.au>
	<20060609074433.GB19524@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36319
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932582AbWFIXNH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 19:13:07 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060609074433.GB19524@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 9 Jun 2006 17:44:33 +1000

> [NET]: skb_trim audit
> 
> I found a few more spots where pskb_trim_rcsum could be used but were not.
> This patch changes them to use it.
> 
> Also, sk_filter can get paged skb data.  Therefore we must use pskb_trim
> instead of skb_trim.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
