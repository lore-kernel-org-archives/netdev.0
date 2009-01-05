From: David Miller <davem@davemloft.net>
Subject: Re: [1/2] gro: Use gso_size to store MSS
Date: Sun, 04 Jan 2009 16:13:25 -0800 (PST)
Message-ID: <20090104.161325.211585417.davem@davemloft.net>
References: <20081229122445.GA11161@gondor.apana.org.au>
	<20081229.230703.265458431.davem@davemloft.net>
	<20081230100705.GA31741@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58650
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750964AbZAEANW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 19:13:22 -0500
In-Reply-To: <20081230100705.GA31741@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 30 Dec 2008 21:07:05 +1100

> gro: Use gso_size to store MSS
> 
> In order to allow GRO packets without frag_list at all, we need to
> store the MSS in the packet itself.  The obvious place is gso_size.
> The only thing to watch out for is if the packet ends up not being
> GRO then we need to clear gso_size before pushing the packet into
> the stack.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
