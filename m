From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] [IPSEC]: Move IP protocol setting from transforms
 into xfrm4_input.c
Date: Wed, 10 Oct 2007 15:46:30 -0700 (PDT)
Message-ID: <20071010.154630.32718624.davem@davemloft.net>
References: <20071010143915.GA7650@gondor.apana.org.au>
	<E1IfcjQ-00024k-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49160
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756349AbXJJWq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 18:46:27 -0400
In-Reply-To: <E1IfcjQ-00024k-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 10 Oct 2007 22:40:16 +0800

> [IPSEC]: Move IP protocol setting from transforms into xfrm4_input.c
> 
> This patch makes the IPv4 x->type->input functions return the next protocol
> instead of setting it directly.  This is identical to how we do things in
> IPv6 and will help us merge common code on the input path.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
