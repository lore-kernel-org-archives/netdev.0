From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Fri, 28 Oct 2011 04:29:26 +0100
Message-ID: <1319772566.6759.27.camel@deadeye>
References: <1319764761.23112.14.camel@edumazet-laptop>
	 <20111028012521.GF25795@one.firstfloor.org>
	 <CA+55aFy9oJSK99K=brRzSfSnLocO=PuS7yuKkAcw3t5hATJrfw@mail.gmail.com>
	 <1319766293.6759.17.camel@deadeye>
	 <1319770376.23112.58.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319770376.23112.58.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-10-28 at 04:52 +0200, Eric Dumazet wrote:
> Le vendredi 28 octobre 2011 =C3=A0 02:44 +0100, Ben Hutchings a =C3=A9=
crit :
>=20
> > Whether or not it needs to provide any ordering guarantee, atomic_r=
ead()
> > must never read more than once, and I think that requires the volat=
ile
> > qualification.  It might be clearer to use the ACCESS_ONCE macro,
> > however.
> >=20
>=20
> Where this requirement comes from ?

That is the conventional behaviour of 'atomic' operations, and callers
may depend on it.

> Maybe then introduce atomic_read_once() for users really needing it :=
)
>
> ACCESS_ONCE will force the read/move instruction I try to avoid :(
[...]

I'm sure you can find some other way to avoid it.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
