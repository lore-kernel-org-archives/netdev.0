From: David Miller <davem@davemloft.net>
Subject: Re: pppoe: Unshare skb before anything else
Date: Tue, 10 Jun 2008 14:08:59 -0700 (PDT)
Message-ID: <20080610.140859.112120203.davem@davemloft.net>
References: <20080608062913.GA20871@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56808
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753254AbYFJVI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 17:08:59 -0400
In-Reply-To: <20080608062913.GA20871@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 8 Jun 2008 16:29:13 +1000

> pppoe: Unshare skb before anything else
> 
> We need to unshare the skb first as otherwise pskb_may_pull may
> write to a shared skb which could be bad.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, and queued to -stable, thanks!
