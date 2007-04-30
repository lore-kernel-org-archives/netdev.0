From: David Miller <davem@davemloft.net>
Subject: Re: many sockets, slow sendto
Date: Mon, 30 Apr 2007 00:26:43 -0700 (PDT)
Message-ID: <20070430.002643.68156452.davem@davemloft.net>
References: <4600592E.80605@fw.hu>
	<460064C6.5030302@cosmosbay.com>
	<4601ADD8.8040500@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zacco@fw.hu, baruch@ev-en.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52036
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423103AbXD3H0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 03:26:47 -0400
In-Reply-To: <4601ADD8.8040500@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 21 Mar 2007 23:12:40 +0100

> [PATCH] INET : IPV4 UDP lookups converted to a 2 pass algo
> 
> Some people want to have many UDP sockets, binded to a single port but many 
> different addresses. We currently hash all those sockets into a single chain. 
> Processing of incoming packets is very expensive, because the whole chain must 
> be examined to find the best match.
> 
> I chose in this patch to hash UDP sockets with a hash function that take into 
> account both their port number and address : This has a drawback because we 
> need two lookups : one with a given address, one with a wildcard (null) address.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Eric, I've applied this, thanks again.

Could I trouble you to cook up an ipv6 version of this patch?

Thanks a lot.
