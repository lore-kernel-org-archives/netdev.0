From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 23/24] [IPSEC]: Move integrity stat collection into
 xfrm_input
Date: Tue, 13 Nov 2007 21:45:38 -0800 (PST)
Message-ID: <20071113.214538.89057033.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1IplaC-0001Iv-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39583
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756845AbXKNFpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:45:39 -0500
In-Reply-To: <E1IplaC-0001Iv-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:40 +0800

> [IPSEC]: Move integrity stat collection into xfrm_input
> 
> Similar to the moving out of the replay processing on the output,
> this patch moves the integrity stat collectin from x->type->input
> into xfrm_input.
> 
> This would eventually allow transforms such as AH/ESP to be lockless.
> 
> The error value EBADMSG (currently unused in the crypto layer) is used
> to indicate a failed integrity check.  In future this error can be
> directly returned by the crypto layer once we switch to aead algorithms.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
