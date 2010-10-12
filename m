From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH net-next] net:  allocate skbs on local node
Date: Tue, 12 Oct 2010 00:58:56 -0700
Message-ID: <20101012005856.994bea6d.akpm@linux-foundation.org>
References: <1286838210.30423.128.camel@edumazet-laptop>
	<1286839363.30423.130.camel@edumazet-laptop>
	<1286859925.30423.184.camel@edumazet-laptop>
	<20101011230322.f0f6dd47.akpm@linux-foundation.org>
	<1286866699.30423.234.camel@edumazet-laptop>
	<20101012002435.f51f2c0e.akpm@linux-foundation.org>
	<1286869793.2732.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Christoph Hellwig <hch@lst.de>,
	Christoph Lameter <cl@linux-foundation.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51567 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756709Ab0JLH6Z convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Oct 2010 03:58:25 -0400
In-Reply-To: <1286869793.2732.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Oct 2010 09:49:53 +0200 Eric Dumazet <eric.dumazet@gmail.com=
> wrote:

> Le mardi 12 octobre 2010 =E0 00:24 -0700, Andrew Morton a =E9crit :
>=20
> > I'd love to forget it, but it's faster for some things (I forget
> > which).  Which is why it's still around.
>=20
> Yes, two years ago it was true on pathological/obscure cases.
> Every time I did the comparison, SLUB won.
> You asked me, I did yet another test this morning, and 40% is pretty
> serious, I believe.
>=20
> >=20
> > And the ghastly thing about this is that you're forced to care abou=
t it
> > too because some people are, apparently, still using it.
> >=20
>=20
> Yes, some people (in my company) still use linux 2.6.9 32bit on HP G6=
/G7
> machines, I know...
>=20
> I am not saying we should not care, but for any serious network workl=
oad
> on NUMA arches, SLUB is the best, and seeing Christoph recent work, i=
t
> might even get better.
>=20
> BTW, I believe all modern distros ship SLUB, dont they ?
>=20

Dunno.

Pekka, why haven't we deleted slab yet??
