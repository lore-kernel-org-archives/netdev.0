From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Tue, 10 May 2011 12:03:26 +0200
Message-ID: <1305021806.2614.17.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <20110418153852.153d3ed3.akpm@linux-foundation.org>
	 <1303181466.4152.39.camel@edumazet-laptop>
	 <1303182557.4152.48.camel@edumazet-laptop>
	 <1303183217.4152.49.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104191210011.17888@router.home>
	 <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi>
	 <1303279470.2756.17.camel@edumazet-laptop>
	 <1303285519.4dae8f0fdf9b1@imp.free.fr>  <4DAE901C.2090809@cs.helsinki.fi>
	 <1303286998.3186.18.camel@edumazet-laptop>
	 <1303290464.3186.32.camel@edumazet-laptop>
	 <1303293765.3186.74.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104200904440.8634@router.home>
	 <1303309591.3186.84.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104200942020.9266@router.home>
	 <1303311687.3186.100.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105092241390.6784@tiger>
	 <alpine.DEB.2.00.1105091502260.26839@router.home>
	 <1305016988.2614.6.camel@edumazet-laptop> <4DC909BD.5080903@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux.com>, casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:34925 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752666Ab1EJKDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 06:03:31 -0400
Received: by wwk4 with SMTP id 4so3209080wwk.1
        for <netdev@vger.kernel.org>; Tue, 10 May 2011 03:03:29 -0700 (PDT)
In-Reply-To: <4DC909BD.5080903@cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 10 mai 2011 =C3=A0 12:47 +0300, Pekka Enberg a =C3=A9crit :
> On 5/10/11 11:43 AM, Eric Dumazet wrote:
> > I am trying to follow things but honestly I am lost.
> > Isnt commit 1759415e63 planned for 2.6.40 ?
> > ( ref :
> > http://git.kernel.org/?p=3Dlinux/kernel/git/penberg/slab-2.6.git;a=3D=
commitdiff;h=3D1759415e630e5db0dd2390df9f94892cbfb9a8a2 )
>=20
> Yes, it's for 2.6.40.
>=20
> > How shall we fix things for 2.6.39 ? I thought my patch was OK for =
that.
> >
>=20
> It's so late in the release cycle that I think the best option is to =
fix=20
> it in 2.6.40 and backport it to -stable together with the above commi=
t.
>=20
> > Its a bit hard to work with you on this stuff, for a report I made =
ages
> > ago, I find it incredible its not yet fixed in linux-2.6.
>=20
> It's not incredible, I simply managed to miss your patch. Sorry about=
 that.
>=20

Pekka, my word was probably too strong, sorry for that.

What I meant is I dont understand how Christoph expect to solve this
problem if irqsafe_cpu_cmpxchg_double() is used everywhere.




