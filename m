From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] [NET]: Call uninit if necessary in
 register_netdevice
Date: Mon, 30 Jul 2007 16:29:55 -0700 (PDT)
Message-ID: <20070730.162955.38321755.davem@davemloft.net>
References: <20070726090725.GA510@gondor.apana.org.au>
	<E1IDzLI-00009i-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52333
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760058AbXG3XaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 19:30:02 -0400
In-Reply-To: <E1IDzLI-00009i-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 26 Jul 2007 17:09:08 +0800

> [NET]: Call uninit if necessary in register_netdevice
> 
> This patch makes register_netdevice call dev->uninit if the regsitration
> fails after dev->init has completed successfully.  Very few drivers use
> the init/uninit calls but at least one (drivers/net/wan/sealevel.c) may
> leak without this change.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks great, applied.
