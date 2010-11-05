From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] atomic: add atomic_inc_not_zero_hint()
Date: Fri, 05 Nov 2010 20:46:31 +0100
Message-ID: <1288986391.2665.157.camel@edumazet-laptop>
References: <1288975980.2882.877.camel@edumazet-laptop>
	 <20101105102038.53e36f9e.akpm@linux-foundation.org>
	 <1288980046.2882.1054.camel@edumazet-laptop>
	 <20101105110828.52f061b3.akpm@linux-foundation.org>
	 <1288981224.2882.1105.camel@edumazet-laptop>
	 <20101105112821.57f80481.akpm@linux-foundation.org>
	 <1288984844.2665.52.camel@edumazet-laptop>
	 <20101105123927.5779e464.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Nick Piggin <npiggin@kernel.dk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40527 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754618Ab0KETqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 15:46:40 -0400
In-Reply-To: <20101105123927.5779e464.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 05 novembre 2010 =C3=A0 12:39 -0700, Andrew Morton a =C3=A9=
crit :

> Ah.  I wasn't able to see much duplicated code at all, so I wasn't su=
re
> that we needed to bother about this issue.
>=20
> yup, atomic_inc_not_zero() looks like a candidate.

yes, and atomic_add_unless()...

>=20
> > [PATCH v3] atomic: add atomic_inc_not_zero_hint()
>=20
> Let's go with this for now ;)
>=20
> I'll assume that you intend to make use of this function soon, and it
> looks safe enough to sneak it into 2.6.37-rc2, IMO.  If Linus shouts =
at
> me then we could merge it into 2.6.38-rc1 via net-next, but I think
> straight-to-mainline is best.
>=20

Well, I dont expect using it before 2.6.38, no hurry Andrew, but it
probably can be merged before, since it has no user yet. It'll help our
job for sure.

Thanks


