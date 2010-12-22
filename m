From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] kptr_restrict for hiding kernel pointers
Date: Wed, 22 Dec 2010 14:48:08 +0100
Message-ID: <1293025688.3027.82.camel@edumazet-laptop>
References: <1292708499.10804.89.camel@dan> <20101222130349.GB13412@elte.hu>
	 <1293023589.9820.186.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	jmorris@namei.org, tgraf@infradead.org, eugeneteo@kernel.org,
	kees.cook@canonical.com, davem@davemloft.net,
	a.p.zijlstra@chello.nl, akpm@linux-foundation.org,
	eparis@parisplace.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1293023589.9820.186.camel@dan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 22 d=C3=A9cembre 2010 =C3=A0 08:13 -0500, Dan Rosenberg a =C3=
=A9crit :
> > Hm, why is it off by default? Is there some user-space regression t=
hat is caused by=20
> > this?
> >=20
> > We really want good security measures to be active by default (and =
to work by=20
> > default) - they are not worth much if they are not.
> >=20
>=20
> I agree entirely, but I've received a lot of resistance to these type=
s
> of changes in net.  I'm afraid that if it's enabled by default, no on=
e
> will actually allow use of the %pK specifier where it should be used.
>=20

Actually, "net resistance" was against your first patches, using quick
and dirty techniques (Should I remind you some of them ?)

Now you have a helper, it should be easier to integrate the changes.

At least, if a mission critical legacy app want to see real pointers
values and a 2.6.38 kernel, it is a matter of sysadmin tweaks.



--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
