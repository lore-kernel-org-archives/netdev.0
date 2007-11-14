From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 16/24] [IPSEC]: Separate inner/outer mode processing on
 input
Date: Tue, 13 Nov 2007 21:41:40 -0800 (PST)
Message-ID: <20071113.214140.94055297.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1Ipla4-0001I0-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45844
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751784AbXKNFll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:41:41 -0500
In-Reply-To: <E1Ipla4-0001I0-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:32 +0800

> [IPSEC]: Separate inner/outer mode processing on input
> 
> With inter-family transforms the inner mode differs from the outer mode.
> Attempting to handle both sides from the same function means that it
> needs to handle both IPv4 and IPv6 which creates duplication and confusion.
> 
> This patch separates the two parts on the input path so that each function
> deals with one family only.
> 
> In particular, the functions xfrm4_extract_inut/xfrm6_extract_inut
> moves the pertinent fields from the IPv4/IPv6 IP headers into a neutral
> format stored in skb->cb.  This is then used by the inner mode input
> functions to modify the inner IP header.  In this way the input function
> no longer has to know about the outer address family.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
