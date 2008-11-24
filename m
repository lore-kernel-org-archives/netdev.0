From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Could we avoid touching dst->refcount in some cases ?
Date: Mon, 24 Nov 2008 15:36:11 -0800 (PST)
Message-ID: <20081124.153611.199553928.davem@davemloft.net>
References: <87y6z9h33h.fsf@basil.nowhere.org>
	<492A7E85.3060502@cosmosbay.com>
	<20081124112709.GX6703@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59775
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752752AbYKXXgM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2008 18:36:12 -0500
In-Reply-To: <20081124112709.GX6703@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Andi Kleen <andi@firstfloor.org>
Date: Mon, 24 Nov 2008 12:27:09 +0100

> On Mon, Nov 24, 2008 at 11:14:29AM +0100, Eric Dumazet wrote:
> > Andi Kleen a =E9crit :
> > >Eric Dumazet <dada1@cosmosbay.com> writes:
> > >
> > >>tbench has hard time incrementing decrementing the route cache re=
fcount
> > >>shared by all communications on localhost.
> > >
> > >iirc there was a patch some time ago to use per CPU loopback devic=
es to=20
> > >avoid this, but it was considered too much a benchmark hack.
> > >As core counts increase it might stop being that though.
> >=20
> > Well, you probably mention Stephen patch to avoid dirtying other co=
ntended
> > cache lines (one napi structure per cpu)
>=20
> No that patch wasn't from Stephen. iirc it was from someone at SGI.

That's how I remember it too.
