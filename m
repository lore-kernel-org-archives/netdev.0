From: Stefan Rompf <stefan@loplof.de>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Wed, 5 Dec 2007 19:39:07 +0100
Message-ID: <200712051939.08384.stefan@loplof.de>
References: <4755A21F.2020407@simon.arlott.org.uk> <20071204.223023.262159049.davem@davemloft.net> <20071205065132.GA11476@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, simon@fire.lp0.eu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cg-p07-fb.rzone.de ([81.169.146.215]:20269 "EHLO
	cg-p07-fb.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbXLESmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 13:42:32 -0500
In-Reply-To: <20071205065132.GA11476@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 5. Dezember 2007 07:51 schrieb Herbert Xu:

> > If he sets this sysctl to "1" as I detailed in my reply, he'll
> > get the behavior he wants.
>
> Does anybody actually need the 0 setting? What would we break if
> the default became 1?

I'd strongly suggest doing so. AFAIK, behaviour of connect() on nonblocking 
sockets is quite well defined in POSIX. If this is changed for some IP 
sockets, event-driven applications will randomly and subtly break.

Stefan
