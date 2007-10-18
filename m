From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/11] [IPSEC]: Store afinfo pointer in xfrm_mode
Date: Wed, 17 Oct 2007 21:34:19 -0700 (PDT)
Message-ID: <20071017.213419.52167434.davem@davemloft.net>
References: <20071017142940.GA23879@gondor.apana.org.au>
	<E1Ii9yS-0006Hb-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56791
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752800AbXJREeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 00:34:20 -0400
In-Reply-To: <E1Ii9yS-0006Hb-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 17 Oct 2007 22:34:16 +0800

> [IPSEC]: Store afinfo pointer in xfrm_mode
> 
> It is convenient to have a pointer from xfrm_state to address-specific
> functions such as the output function for a family.  Currently the
> address-specific policy code calls out to the xfrm state code to get
> those pointers when we could get it in an easier way via the state
> itself.
> 
> This patch adds an xfrm_state_afinfo to xfrm_mode (since they're
> address-specific) and changes the policy code to use it.  I've also
> added an owner field to do reference counting on the module providing
> the afinfo even though it isn't strictly necessary today since IPv6
> can't be unloaded yet.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.

Thanks for doing this, those afinfo get/put things all over
the place really bugged me.
