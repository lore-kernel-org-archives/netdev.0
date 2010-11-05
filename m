From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] atomic: add atomic_inc_not_zero_hint()
Date: Fri, 05 Nov 2010 20:12:51 +0100
Message-ID: <1288984371.2665.13.camel@edumazet-laptop>
References: <1288975980.2882.877.camel@edumazet-laptop>
	 <20101105102038.53e36f9e.akpm@linux-foundation.org>
	 <1288980046.2882.1054.camel@edumazet-laptop>
	 <20101105184034.GG2850@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>,
	Nick Piggin <npiggin@kernel.dk>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39768 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753502Ab0KETNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 15:13:01 -0400
In-Reply-To: <20101105184034.GG2850@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 05 novembre 2010 =C3=A0 11:40 -0700, Paul E. McKenney a =C3=
=A9crit :

> OK, so I cannot resist the challenge...  ;-)
>=20

I knew that ;)

> Suppose that the atomic_inc_not_zero_hint() is in common code that mi=
ght
> be invoked from a cleanup path.  On the cleanup path, perhaps within =
an
> RCU callback, if the reference is zero, we have the only reference an=
d
> thus don't need to increment the reference count.  On the other hand,
> if the reference is non-zero, we want to obtain a reference in order
> to safely attempt to encourage the other reference holder to let go
> more quickly.
>=20
> Perhaps a bit of a stretch, but why not just replace the above
> "return 0" with "atomic_inc_not_zero(v)"?  It will usually be
> compiled out, right?

Yes indeed, thanks !



