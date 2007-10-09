From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] [IPSEC]: Move common output code to xfrm_output
Date: Mon, 08 Oct 2007 17:17:17 -0700 (PDT)
Message-ID: <20071008.171717.71577244.davem@davemloft.net>
References: <20071008112818.GA3010@gondor.apana.org.au>
	<E1Ieqnr-0000o7-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42765
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752449AbXJIARS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 20:17:18 -0400
In-Reply-To: <E1Ieqnr-0000o7-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 08 Oct 2007 19:29:39 +0800

> [IPSEC]: Move common output code to xfrm_output
> 
> Most of the code in xfrm4_output_one and xfrm6_output_one are identical so
> this patch moves them into a common xfrm_output function which will live
> in net/xfrm.
> 
> In fact this would seem to fix a bug as on IPv4 we never reset the network
> header after a transform which may upset netfilter later on.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.

Could you submit a 2.6.23 version of just the ipv4 fix?
It might be interesting to determine why it was omitted,
perhaps it was an oversight, and it probably predates the
addition of skb_reset_*().
