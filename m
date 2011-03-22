From: Simon Horman <horms@verge.net.au>
Subject: Re: [slab poison overwritten] Re: [GIT] Networking
Date: Wed, 23 Mar 2011 06:52:50 +0900
Message-ID: <20110322215249.GD2423@verge.net.au>
References: <20110320.195156.226769634.davem@davemloft.net>
 <20110321125320.GA23490@elte.hu>
 <1300714346.2884.284.camel@edumazet-laptop>
 <20110321161528.GA28580@elte.hu>
 <20110321164238.GA5303@elte.hu>
 <20110321173941.GB3892@elte.hu>
 <1300730838.2884.578.camel@edumazet-laptop>
 <1300738540.2837.5.camel@edumazet-laptop>
 <20110322095638.GA26130@elte.hu>
 <1300788039.3084.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Arnd Bergmann <arnd@arndb.de>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Julian Anastasov <ja@ssi.bg>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1300788039.3084.0.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 22, 2011 at 11:00:39AM +0100, Eric Dumazet wrote:
> Le mardi 22 mars 2011 =C3=A0 10:56 +0100, Ingo Molnar a =C3=A9crit :
> > * Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >=20
> > > [PATCH] ipvs: fix a typo in __ip_vs_control_init()
> >=20
> > This fix and Simon's:
> >=20
> >   IPVS: Use global mutex in ip_vs_app.c
> >=20
> > Did the trick here, the IPVS related SLAB corruptions are now gone.
> >=20
> > Thanks guys!
>=20
> Thanks for testing Ingo ;)

Yes, thanks Ingo.
