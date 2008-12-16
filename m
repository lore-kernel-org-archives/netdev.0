From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] tcp: Add GRO support
Date: Mon, 15 Dec 2008 23:43:47 -0800 (PST)
Message-ID: <20081215.234347.35799162.davem@davemloft.net>
References: <20081213013420.GA13549@gondor.apana.org.au>
	<E1LBJPg-0003Z3-Kg@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johnpol@2ka.mipt.ru,
	bhutchings@solarflare.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38022
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751346AbYLPHnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 02:43:46 -0500
In-Reply-To: <E1LBJPg-0003Z3-Kg@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 13 Dec 2008 12:35:24 +1100

> tcp: Add GRO support
> 
> This patch adds the TCP-specific portion of GRO.  The criterion for
> merging is extremely strict (the TCP header must match exactly apart
> from the checksum) so as to allow refragmentation.  Otherwise this
> is pretty much identical to LRO, except that we support the merging
> of ECN packets.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
