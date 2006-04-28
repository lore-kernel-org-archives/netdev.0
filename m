From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC]: Fix IP ID selection
Date: Fri, 28 Apr 2006 15:23:19 -0700 (PDT)
Message-ID: <20060428.152319.58444954.davem@davemloft.net>
References: <20060427115645.GA20140@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20364
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751775AbWD1WXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 18:23:08 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060427115645.GA20140@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 27 Apr 2006 21:56:45 +1000

> I was looking through the xfrm input/output code in order to abstract
> out the address family specific encapsulation/decapsulation code.  During
> that process I found this bug in the IP ID selection code in xfrm4_output.c.
> 
> At that point dst is still the xfrm_dst for the current SA which
> represents an internal flow as far as the IPsec tunnel is concerned.
> Since the IP ID is going to sit on the outside of the encapsulated
> packet, we obviously want the external flow which is just dst->child.
> 
> The fix is trivial.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks for catching this, applied, thanks Herbert.
