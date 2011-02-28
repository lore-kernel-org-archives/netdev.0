From: Thomas Graf <tgraf@infradead.org>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Mon, 28 Feb 2011 10:01:50 -0500
Message-ID: <20110228150150.GG9763@canuck.infradead.org>
References: <20110225.112019.48513284.davem@davemloft.net>
 <20110226005718.GA19889@gondor.apana.org.au>
 <20110227110205.GE9763@canuck.infradead.org>
 <20110227110614.GA6246@gondor.apana.org.au>
 <20110228113659.GA20726@gondor.apana.org.au>
 <1298899971.2941.281.camel@edumazet-laptop>
 <1298904783.2941.412.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:52147 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754484Ab1B1PB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 10:01:56 -0500
Content-Disposition: inline
In-Reply-To: <1298904783.2941.412.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 28, 2011 at 03:53:03PM +0100, Eric Dumazet wrote:
> What do you suggest to perform a bind based test ?

We use queryperf from BIND sources. I typically run 1 queryperf
instance per core on multiple machines.
