From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] [IPSEC]: Set skb->data to payload in
 x->mode->output
Date: Wed, 10 Oct 2007 15:44:16 -0700 (PDT)
Message-ID: <20071010.154416.11277802.davem@davemloft.net>
References: <20071010143915.GA7650@gondor.apana.org.au>
	<E1IfcjM-00024E-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47580
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756325AbXJJWoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 18:44:13 -0400
In-Reply-To: <E1IfcjM-00024E-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 10 Oct 2007 22:40:12 +0800

> [IPSEC]: Set skb->data to payload in x->mode->output
> 
> This patch changes the calling convention so that on entry from
> x->mode->output and before entry into x->type->output skb->data
> will point to the payload instead of the IP header.
> 
> This is essentially a redistribution of skb_push/skb_pull calls
> with the aim of minimising them on the common path of tunnel +
> ESP.
> 
> It'll also let us use the same calling convention between IPv4
> and IPv6 with the next patch.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
