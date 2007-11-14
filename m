From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/24] [IPV6]: Only set nfheader_len for top xfrm dst
Date: Tue, 13 Nov 2007 21:32:42 -0800 (PST)
Message-ID: <20071113.213242.96451363.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1IplZo-0001Fw-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47490
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750759AbXKNFcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:32:43 -0500
In-Reply-To: <E1IplZo-0001Fw-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:16 +0800

> [IPV6]: Only set nfheader_len for top xfrm dst
> 
> We only need to set nfheader_len in the top xfrm dst.  This is because
> we only ever read the nfheader_len from the top xfrm dst.
> 
> It is also easier to count nfheader_len as part of header_len which
> then lets us remove the ugly wrapper functions for incrementing and
> decrementing header lengths in xfrm6_policy.c.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
