From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Mon, 28 Feb 2011 22:13:27 +0800
Message-ID: <20110228141327.GA22851@gondor.apana.org.au>
References: <20110225.112019.48513284.davem@davemloft.net> <20110226005718.GA19889@gondor.apana.org.au> <20110227110205.GE9763@canuck.infradead.org> <20110227110614.GA6246@gondor.apana.org.au> <20110228113659.GA20726@gondor.apana.org.au> <1298899971.2941.281.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:37779 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754286Ab1B1ONl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 09:13:41 -0500
Content-Disposition: inline
In-Reply-To: <1298899971.2941.281.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 28, 2011 at 02:32:51PM +0100, Eric Dumazet wrote:
>
> Now, input path can run without finding socket locked by xmit path, so
> skb are queued into receive queue, not backlog one.

Indeed, I think this is what Dave alluded to earlier.  This will
eventually have to be dealt with but for now the data rate is low
enough that it isn't killing us.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
