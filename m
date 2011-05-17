From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] sfc: Replace enum efx_fc_type with a
 'bitwise' type
Date: Tue, 17 May 2011 14:43:11 -0700
Message-ID: <1305668591.1722.75.camel@Joe-Laptop>
References: <1305658121.2848.29.camel@bwh-desktop>
	 <20110517.152651.1785846817320651943.davem@davemloft.net>
	 <1305666379.2848.45.camel@bwh-desktop>
	 <20110517.171412.1017451005914294196.davem@davemloft.net>
	 <1305667378.1722.65.camel@Joe-Laptop>
	 <1305668197.2691.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1733 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932075Ab1EQVnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 17:43:13 -0400
In-Reply-To: <1305668197.2691.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-17 at 23:36 +0200, Eric Dumazet wrote:
> Le mardi 17 mai 2011 =C3=A0 14:22 -0700, Joe Perches a =C3=A9crit :
> > On Tue, 2011-05-17 at 17:14 -0400, David Miller wrote:
> > > Accept that the compiler currently doesn't want to allow enums to=
 be
> > > used as bit-masks, don't paper around it.
> > A patch applied yesterday using enums as bitmasks:
> > http://patchwork.ozlabs.org/patch/95802/
> Well, quite frankly I focused on solving a bug, not making beautiful
> code. After reading convoluted RFC, going back to C is not exactly
> straightforward.

Given some RFCs, not necessarily possible either.

> I filled a (small) table with C99 initializers, its not the problem
> David raised

True, but it was a similar use of or'd enums.

> To be honest, I was using plain #define and right before sending patc=
h I
> added one enum just because its less chars on screen for the reader.
> No strong opinion on this.

Nor I honestly.  I don't mind either.

cheers, Joe

