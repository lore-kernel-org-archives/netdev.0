From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] sfc: Replace enum efx_fc_type with a
 'bitwise' type
Date: Tue, 17 May 2011 23:36:37 +0200
Message-ID: <1305668197.2691.15.camel@edumazet-laptop>
References: <1305658121.2848.29.camel@bwh-desktop>
	 <20110517.152651.1785846817320651943.davem@davemloft.net>
	 <1305666379.2848.45.camel@bwh-desktop>
	 <20110517.171412.1017451005914294196.davem@davemloft.net>
	 <1305667378.1722.65.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33251 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932075Ab1EQVgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:36:42 -0400
Received: by wya21 with SMTP id 21so742636wya.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 14:36:41 -0700 (PDT)
In-Reply-To: <1305667378.1722.65.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 17 mai 2011 =C3=A0 14:22 -0700, Joe Perches a =C3=A9crit :
> On Tue, 2011-05-17 at 17:14 -0400, David Miller wrote:
> > Accept that the compiler currently doesn't want to allow enums to b=
e
> > used as bit-masks, don't paper around it.
>=20
> A patch applied yesterday using enums as bitmasks:
> http://patchwork.ozlabs.org/patch/95802/

Well, quite frankly I focused on solving a bug, not making beautiful
code. After reading convoluted RFC, going back to C is not exactly
straightforward.

I filled a (small) table with C99 initializers, its not the problem
David raised with :

switch (value) {
case XXX | YYY:   /* gcc warning */

To be honest, I was using plain #define and right before sending patch =
I
added one enum just because its less chars on screen for the reader.

No strong opinion on this.



