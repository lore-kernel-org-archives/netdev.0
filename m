From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net:  allocate skbs on local node
Date: Tue, 12 Oct 2010 09:49:53 +0200
Message-ID: <1286869793.2732.24.camel@edumazet-laptop>
References: <1286838210.30423.128.camel@edumazet-laptop>
	 <1286839363.30423.130.camel@edumazet-laptop>
	 <1286859925.30423.184.camel@edumazet-laptop>
	 <20101011230322.f0f6dd47.akpm@linux-foundation.org>
	 <1286866699.30423.234.camel@edumazet-laptop>
	 <20101012002435.f51f2c0e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Christoph Hellwig <hch@lst.de>,
	Christoph Lameter <cl@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45372 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756621Ab0JLH4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 03:56:38 -0400
Received: by wye20 with SMTP id 20so1148429wye.19
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 00:56:37 -0700 (PDT)
In-Reply-To: <20101012002435.f51f2c0e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 octobre 2010 =C3=A0 00:24 -0700, Andrew Morton a =C3=A9crit=
 :

> I'd love to forget it, but it's faster for some things (I forget
> which).  Which is why it's still around.

Yes, two years ago it was true on pathological/obscure cases.
Every time I did the comparison, SLUB won.
You asked me, I did yet another test this morning, and 40% is pretty
serious, I believe.

>=20
> And the ghastly thing about this is that you're forced to care about =
it
> too because some people are, apparently, still using it.
>=20

Yes, some people (in my company) still use linux 2.6.9 32bit on HP G6/G=
7
machines, I know...

I am not saying we should not care, but for any serious network workloa=
d
on NUMA arches, SLUB is the best, and seeing Christoph recent work, it
might even get better.

BTW, I believe all modern distros ship SLUB, dont they ?


