From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/3] rcu: documents rculist_nulls
Date: Sun, 16 Nov 2008 19:36:59 -0800 (PST)
Message-ID: <20081116.193659.159456126.davem@davemloft.net>
References: <491C2F27.2000908@cosmosbay.com>
	<491C4FA8.4020704@cosmosbay.com>
	<1226675798.7685.7797.camel@twins>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dada1@cosmosbay.com, minyard@acm.org, paulmck@linux.vnet.ibm.com,
	shemminger@vyatta.com, benny+usenet@amorsen.dk,
	netdev@vger.kernel.org, cl@linux-foundation.org, zbr@ioremap.net,
	christian@myri.com
To: a.p.zijlstra@chello.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36305
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755492AbYKQDhA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Nov 2008 22:37:00 -0500
In-Reply-To: <1226675798.7685.7797.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 14 Nov 2008 16:16:38 +0100

> On Thu, 2008-11-13 at 17:02 +0100, Eric Dumazet wrote:
> >=20
> Eric Dumazet a =E9crit :
> > > Peter Zijlstra a =E9crit :
> > >> So by not using some memory barriers (would be nice to have it
> > >> illustrated which ones), we can race and end up on the wrong cha=
in, in
> > >> case that happens we detect this by using this per-chain termina=
tor and
> > >> try again.
> > >>
> > >> It would be really good to have it explained in the rculist_null=
s.h
> > >> comments what memory barriers are missing, what races they open,=
 and how
> > >> the this special terminator trick closes that race.
> > >=20
> > > OK, maybe I should add a Documentation/RCU/rculist_nulls.txt file=
 with
> > > appropriate examples and documentation.
> > >=20
> > > (Say the lookup/insert algorithms, with standard hlist and memory=
 barriers,
> > > and with hlist_nulls without those two memory barriers.
> > >=20
> >=20
> > [PATCH 4/3] rcu: documents rculist_nulls
> >=20
> > Adds Documentation/RCU/rculist_nulls.txt file to describe how 'null=
s'
> > end-of-list can help in some RCU algos.
> >=20
> >=20
> > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Since there seems to be consensus for these changes I'm going to merge =
this
stuff into net-next-2.6 so that I can add in the users that Eric has wr=
itten.

Thanks everyone for the review and feedback.
