From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/11] [IPSEC]: Add missing BEET checks
Date: Wed, 17 Oct 2007 21:31:58 -0700 (PDT)
Message-ID: <20071017.213158.40146272.davem@davemloft.net>
References: <20071017142940.GA23879@gondor.apana.org.au>
	<E1Ii9yR-0006HT-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60305
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751154AbXJREb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 00:31:59 -0400
In-Reply-To: <E1Ii9yR-0006HT-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 17 Oct 2007 22:34:15 +0800

> [IPSEC]: Add missing BEET checks
> 
> Currently BEET mode does not reinject the packet back into the stack
> like tunnel mode does.  Since BEET should behave just like tunnel mode
> this is incorrect.
> 
> This patch fixes this by introducing a flags field to xfrm_mode that
> tells the IPsec code whether it should terminate and reinject the packet
> back into the stack.
> 
> It then sets the flag for BEET and tunnel mode.
> 
> I've also added a number of missing BEET checks elsewhere where we check
> whether a given mode is a tunnel or not.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
