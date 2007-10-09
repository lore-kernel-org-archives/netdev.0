From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] [IPSEC]: Move common code into xfrm_alloc_spi
Date: Tue, 09 Oct 2007 13:30:02 -0700 (PDT)
Message-ID: <20071009.133002.95894603.davem@davemloft.net>
References: <20071009143517.GA20486@gondor.apana.org.au>
	<E1IfGCI-0005M5-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38181
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753588AbXJIUaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 16:30:03 -0400
In-Reply-To: <E1IfGCI-0005M5-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 09 Oct 2007 22:36:34 +0800

> [IPSEC]: Move common code into xfrm_alloc_spi
> 
> This patch moves some common code that conceptually belongs to the xfrm core
> from af_key/xfrm_user into xfrm_alloc_spi.
> 
> In particular, the spin lock on the state is now taken inside xfrm_alloc_spi.
> Previously it also protected the construction of the response PF_KEY/XFRM
> messages to user-space.  This is inconsistent as other identical constructions
> are not protected by the state lock.  This is bad because they in fact should
> be protected but only in certain spots (so as not to hold the lock for too
> long which may cause packet drops).
> 
> The SPI byte order conversion has also been moved.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks!
