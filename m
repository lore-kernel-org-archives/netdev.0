From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 1 Mar 2011 20:19:51 +0800
Message-ID: <20110301121951.GA7267@gondor.apana.org.au>
References: <1298910174.2941.585.camel@edumazet-laptop> <20110228163742.GH9763@canuck.infradead.org> <1298912869.2941.687.camel@edumazet-laptop> <20110301101955.GI9763@canuck.infradead.org> <1298975602.3284.13.camel@edumazet-laptop> <20110301110708.GJ9763@canuck.infradead.org> <1298977984.3284.15.camel@edumazet-laptop> <20110301112759.GK9763@canuck.infradead.org> <1298979909.3284.28.camel@edumazet-laptop> <20110301121829.GM9763@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:39683 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278Ab1CAMUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 07:20:03 -0500
Content-Disposition: inline
In-Reply-To: <20110301121829.GM9763@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 07:18:29AM -0500, Thomas Graf wrote:
>
> 
> ... makes it use CPU 5 for rxq2 and the qps goes up from 250kqps to 270kqps

I think the increase here comes from the larger number of packets
in flight more than anything.

The bottleneck is still the TX queue (both software and hardware).

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
