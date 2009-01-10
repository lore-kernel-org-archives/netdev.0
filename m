From: David Miller <davem@davemloft.net>
Subject: Re: ipcomp: Remove spurious truesize increase
Date: Fri, 09 Jan 2009 23:07:41 -0800 (PST)
Message-ID: <20090109.230741.216082438.davem@davemloft.net>
References: <20090109072706.GA7599@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47019
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752747AbZAJHHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 02:07:41 -0500
In-Reply-To: <20090109072706.GA7599@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 9 Jan 2009 18:27:06 +1100

> ipcomp: Remove spurious truesize increase
> 
> When I made ipcomp use frags, I forgot to take out the original
> truesize update that was added for pskb_expand_head.  As we no
> longer expand the head of skb, that update should have been removed.
> 
> This bug is not related to the truesize warnings since we only
> made it bigger than what it should've been.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
