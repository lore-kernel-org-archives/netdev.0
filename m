From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] [IPSEC]: Remove gratuitous km wake-up events on
 ACQUIRE
Date: Tue, 09 Oct 2007 13:27:35 -0700 (PDT)
Message-ID: <20071009.132735.08320319.davem@davemloft.net>
References: <20071009143517.GA20486@gondor.apana.org.au>
	<E1IfGCH-0005Lx-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38176
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752699AbXJIU1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 16:27:36 -0400
In-Reply-To: <E1IfGCH-0005Lx-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 09 Oct 2007 22:36:33 +0800

> [IPSEC]: Remove gratuitous km wake-up events on ACQUIRE
> 
> There is no point in waking people up when creating/updating larval states
> because they'll just go back to sleep again as larval states by definition
> cannot be found by xfrm_state_find.
> 
> We should only wake them up when the larvals mature or die.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks!
