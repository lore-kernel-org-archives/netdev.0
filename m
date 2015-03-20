From: David Miller <davem@davemloft.net>
Subject: Re: [v1 PATCH 0/7] rhashtable: Introduce inlined interface
Date: Fri, 20 Mar 2015 16:17:43 -0400 (EDT)
Message-ID: <20150320.161743.1329037804732884094.davem@davemloft.net>
References: <20150320105421.GA18148@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, eric.dumazet@gmail.com, kaber@trash.net,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbbCTURp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 16:17:45 -0400
In-Reply-To: <20150320105421.GA18148@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 20 Mar 2015 21:54:21 +1100

> This series of patches introduces the inlined rhashtable interface.

Series applied, thanks Herbert.

Why do you need that trailer[] think in the new netlink code?
You only use it in an offsetof() expression and wouldn't sizeof
the structure work just fine for that?  This also makes the
memset() superfluous in the initializer function.
