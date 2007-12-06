From: David Miller <davem@davemloft.net>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Wed, 05 Dec 2007 18:25:00 -0800 (PST)
Message-ID: <20071205.182500.166603251.davem@davemloft.net>
References: <20071204.223023.262159049.davem@davemloft.net>
	<20071205065132.GA11476@gondor.apana.org.au>
	<200712051939.08384.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, simon@fire.lp0.eu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: stefan@loplof.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46436
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754405AbXLFCZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 21:25:01 -0500
In-Reply-To: <200712051939.08384.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Rompf <stefan@loplof.de>
Date: Wed, 5 Dec 2007 19:39:07 +0100

> I'd strongly suggest doing so. AFAIK, behaviour of connect() on nonblocking 
> sockets is quite well defined in POSIX.

You are entitled to your opinion.

POSIX says nothing about the semantics of route resolution.
Non-blocking doesn't mean "cannot sleep no matter what".

> If this is changed for some IP sockets, event-driven applications
> will randomly and subtly break.

If this was such a clear cut case we'd have changed things
a long time ago, but it isn't so don't pretend this is the
case.
