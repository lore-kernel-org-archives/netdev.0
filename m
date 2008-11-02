From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix ESP SA loading (by default)
Date: Sat, 01 Nov 2008 21:33:15 -0700 (PDT)
Message-ID: <20081101.213315.01349801.davem@davemloft.net>
References: <20081101050458.GA17807@gondor.apana.org.au>
	<20081101113835.GA3127@x200.localdomain>
	<20081101115043.GA19593@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38997
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751820AbYKBEdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 00:33:40 -0400
In-Reply-To: <20081101115043.GA19593@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 1 Nov 2008 19:50:43 +0800

> On Sat, Nov 01, 2008 at 02:38:35PM +0300, Alexey Dobriyan wrote:
> >
> > It's a cut down example. This won't work either:
> 
> OK, in that case I suggest we make AH depend on the null algorithms
> instead.  This is because very few people use AH these days and only
> they need this.

One could even argue that we should blow away all of those select
statements.
