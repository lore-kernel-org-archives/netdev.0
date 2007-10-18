From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/11] [IPSEC]: Move type and mode map into xfrm_state.c
Date: Wed, 17 Oct 2007 21:31:20 -0700 (PDT)
Message-ID: <20071017.213120.31749685.davem@davemloft.net>
References: <20071017142940.GA23879@gondor.apana.org.au>
	<E1Ii9yQ-0006HL-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60301
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751840AbXJREbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 00:31:21 -0400
In-Reply-To: <E1Ii9yQ-0006HL-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 17 Oct 2007 22:34:14 +0800

> [IPSEC]: Move type and mode map into xfrm_state.c
> 
> The type and mode maps are only used by SAs, not policies.  So it makes
> sense to move them from xfrm_policy.c into xfrm_state.c.  This alos allows
> us to mark xfrm_get_type/xfrm_put_type/xfrm_get_mode/xfrm_put_mode as
> static.
> 
> The only other change I've made in the move is to get rid of the casts
> on the request_module call for types.  They're unnecessary because C
> will promote them to ints anyway.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
