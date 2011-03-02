From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Wed, 2 Mar 2011 08:23:54 +0800
Message-ID: <20110302002353.GA15009@gondor.apana.org.au>
References: <20110301101955.GI9763@canuck.infradead.org> <1298975602.3284.13.camel@edumazet-laptop> <20110301110708.GJ9763@canuck.infradead.org> <1298977984.3284.15.camel@edumazet-laptop> <20110301112759.GK9763@canuck.infradead.org> <1298979909.3284.28.camel@edumazet-laptop> <20110301115305.GA6984@gondor.apana.org.au> <1298984609.3284.98.camel@edumazet-laptop> <20110301131823.GB8028@gondor.apana.org.au> <1298997084.3284.119.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@infradead.org>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:59222 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757636Ab1CBAYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 19:24:11 -0500
Content-Disposition: inline
In-Reply-To: <1298997084.3284.119.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 05:31:24PM +0100, Eric Dumazet wrote:
>
> This wont work for tcp streams, you could imagine a multi-threaded
> application using a shared tcp socket as well. Too many OOO packets.

Think about it, a TCP socket cannot be used by a multi-threaded app
in a scalable way.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
