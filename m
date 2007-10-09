From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] [IPSEC]: Move output replay code into xfrm_output
Date: Mon, 08 Oct 2007 17:26:10 -0700 (PDT)
Message-ID: <20071008.172610.56884636.davem@davemloft.net>
References: <20071008112818.GA3010@gondor.apana.org.au>
	<E1Ieqnu-0000oF-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46284
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752284AbXJIA0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 20:26:11 -0400
In-Reply-To: <E1Ieqnu-0000oF-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 08 Oct 2007 19:29:42 +0800

> [IPSEC]: Move output replay code into xfrm_output
> 
> The replay counter is one of only two remaining things in the output code
> that requires a lock on the xfrm state (the other being the crypto).  This
> patch moves it into the generic xfrm_output so we can remove the lock from
> the transforms themselves.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
