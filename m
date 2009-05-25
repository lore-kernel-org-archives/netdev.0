From: David Miller <davem@davemloft.net>
Subject: Re: skbuff: Move new code into __copy_skb_header
Date: Mon, 25 May 2009 00:40:58 -0700 (PDT)
Message-ID: <20090525.004058.101840379.davem@davemloft.net>
References: <20090523081137.GA12567@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.moore@hp.com,
	Sujith.Manoharan@atheros.com, johannes@sipsolutions.net,
	linville@tuxdriver.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49532
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759758AbZEYHk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2009 03:40:59 -0400
In-Reply-To: <20090523081137.GA12567@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 23 May 2009 18:11:37 +1000

> skbuff: Move new __skb_clone code into __copy_skb_header
> 
> It seems that people just keep on adding stuff to __skb_clone
> instead __copy_skb_header.  This is wrong as it means your brand-new
> attributes won't always get copied as you intended.
> 
> This patch moves them to the right place, and adds a comment to
> prevent this from happening again.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next-2.6
