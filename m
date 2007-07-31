From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] [IPV6]: Remove circular dependency on if_inet6.h
Date: Mon, 30 Jul 2007 17:06:27 -0700 (PDT)
Message-ID: <20070730.170627.102770795.davem@davemloft.net>
References: <20070726090725.GA510@gondor.apana.org.au>
	<E1IDzLo-0000AX-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53664
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765111AbXGaAG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 20:06:28 -0400
In-Reply-To: <E1IDzLo-0000AX-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 26 Jul 2007 17:09:40 +0800

> [IPV6]: Remove circular dependency on if_inet6.h
> 
> net/if_inet6.h includes linux/ipv6.h which also tries to include
> net/if_inet6.h.  Since the latter only needs it for forward
> declarations, we can fix this by adding the declarations.
> 
> A number of files are implicitly including net/if_inet6.h through
> linux/ipv6.h.  They also use net/ipv6.h so this patch includes
> net/if_inet6.h there.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, thanks a lot.
