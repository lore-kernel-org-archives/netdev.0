From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] [IPSEC]: Move state lock into x->type->output
Date: Tue, 09 Oct 2007 13:33:45 -0700 (PDT)
Message-ID: <20071009.133345.111207011.davem@davemloft.net>
References: <20071009143517.GA20486@gondor.apana.org.au>
	<E1IfGCL-0005MT-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38034
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753716AbXJIUdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 16:33:45 -0400
In-Reply-To: <E1IfGCL-0005MT-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 09 Oct 2007 22:36:37 +0800

> [IPSEC]: Move state lock into x->type->output
> 
> This patch releases the lock on the state before calling x->type->output.
> It also adds the lock to the spots where they're currently needed.
> 
> Most of those places (all except mip6) are expected to disappear with
> async crypto.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks!
