From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 1 Mar 2011 21:18:23 +0800
Message-ID: <20110301131823.GB8028@gondor.apana.org.au>
References: <20110228163742.GH9763@canuck.infradead.org> <1298912869.2941.687.camel@edumazet-laptop> <20110301101955.GI9763@canuck.infradead.org> <1298975602.3284.13.camel@edumazet-laptop> <20110301110708.GJ9763@canuck.infradead.org> <1298977984.3284.15.camel@edumazet-laptop> <20110301112759.GK9763@canuck.infradead.org> <1298979909.3284.28.camel@edumazet-laptop> <20110301115305.GA6984@gondor.apana.org.au> <1298984609.3284.98.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@infradead.org>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:51903 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061Ab1CANSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 08:18:45 -0500
Content-Disposition: inline
In-Reply-To: <1298984609.3284.98.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 02:03:29PM +0100, Eric Dumazet wrote:
>
> I believe its now done properly (in net-next-2.6) with commit
> 4f57c087de9b46182 (net: implement mechanism for HW based QOS)

Nope, that has nothing to do with this.

> > The odd packet reordering each time your scheduler decides to
> > migrate the process isn't a big deal IMHO.  If your scheduler
> > is constantly moving things you've got bigger problems to worry
> > about.
> 
> Well, BENET has one TX queue anyway...

Interesting.  So I wonder which lock is showing up at the top
of the profile with a single socket then.  As it's definitely
going away with multiple sockets, that means it's not the TX
queue lock.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
