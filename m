From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: Reexport sock_alloc_send_pskb
Date: Wed, 04 Feb 2009 16:56:01 -0800 (PST)
Message-ID: <20090204.165601.180781903.davem@davemloft.net>
References: <20090204104825.GA21257@gondor.apana.org.au>
	<E1LUfJs-0005ZH-1U@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59122
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753478AbZBEA4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 19:56:04 -0500
In-Reply-To: <E1LUfJs-0005ZH-1U@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 04 Feb 2009 21:49:24 +1100

> net: Reexport sock_alloc_send_pskb
> 
> The function sock_alloc_send_pskb is completely useless if not
> exported since most of the code in it won't be used as is.  In
> fact, this code has already been duplicated in the tun driver.
> 
> Now that we need accounting in the tun driver, we can in fact
> use this function as is.  So this patch marks it for export again.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
