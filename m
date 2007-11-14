From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 24/24] [IPSEC]: Move state lock into x->type->input
Date: Tue, 13 Nov 2007 21:46:09 -0800 (PST)
Message-ID: <20071113.214609.04000914.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1IplaD-0001J4-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39586
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760959AbXKNFqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:46:10 -0500
In-Reply-To: <E1IplaD-0001J4-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:41 +0800

> [IPSEC]: Move state lock into x->type->input
> 
> This patch releases the lock on the state before calling x->type->input.
> It also adds the lock to the spots where they're currently needed.
> 
> Most of those places (all except mip6) are expected to disappear with
> async crypto.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
