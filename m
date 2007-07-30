From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] [NET] loopback: Panic if registration fails
Date: Mon, 30 Jul 2007 16:38:19 -0700 (PDT)
Message-ID: <20070730.163819.45740505.davem@davemloft.net>
References: <20070726090725.GA510@gondor.apana.org.au>
	<E1IDzLh-0000AB-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39836
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761434AbXG3XiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 19:38:20 -0400
In-Reply-To: <E1IDzLh-0000AB-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 26 Jul 2007 17:09:33 +0800

> [NET] loopback: Panic if registration fails
> 
> Because IPv4 and IPv6 both depend on the presence of the loopback device
> to function, failure in registration the loopback device should be fatal.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.

It might be nice to tightly integrate the loopback driver into
net/core/dev.c because that is what is happening anyways and it would
allow us to cons the thing up by hand and deal with these dependencies
more reliably.
