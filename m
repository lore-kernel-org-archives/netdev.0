From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v4] kptr_restrict for hiding kernel pointers
Date: Wed, 22 Dec 2010 17:21:18 +0100
Message-ID: <20101222162118.GC20358@elte.hu>
References: <1292708499.10804.89.camel@dan>
 <20101222130349.GB13412@elte.hu>
 <1293023589.9820.186.camel@dan>
 <1293025688.3027.82.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Rosenberg <drosenberg@vsecurity.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	tgraf@infradead.org, eugeneteo@kernel.org, kees.cook@canonical.com,
	davem@davemloft.net, a.p.zijlstra@chello.nl,
	akpm@linux-foundation.org, eparis@parisplace.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1293025688.3027.82.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mercredi 22 d=E9cembre 2010 =E0 08:13 -0500, Dan Rosenberg a =E9cr=
it :
> > > Hm, why is it off by default? Is there some user-space regression=
 that is caused by=20
> > > this?
> > >=20
> > > We really want good security measures to be active by default (an=
d to work by=20
> > > default) - they are not worth much if they are not.
> > >=20
> >=20
> > I agree entirely, but I've received a lot of resistance to these ty=
pes
> > of changes in net.  I'm afraid that if it's enabled by default, no =
one
> > will actually allow use of the %pK specifier where it should be use=
d.
> >=20
>=20
> Actually, "net resistance" was against your first patches, using quic=
k
> and dirty techniques (Should I remind you some of them ?)
>=20
> Now you have a helper, it should be easier to integrate the changes.

Great - if the concept itself wasnt objected to then i think we should =
flip the=20
default to on.

Thanks,

	Ingo
