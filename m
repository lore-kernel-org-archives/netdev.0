From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [slab poison overwritten] Re: [GIT] Networking
Date: Tue, 22 Mar 2011 11:00:39 +0100
Message-ID: <1300788039.3084.0.camel@edumazet-laptop>
References: <20110320.195156.226769634.davem@davemloft.net>
	 <20110321125320.GA23490@elte.hu>
	 <1300714346.2884.284.camel@edumazet-laptop>
	 <20110321161528.GA28580@elte.hu> <20110321164238.GA5303@elte.hu>
	 <20110321173941.GB3892@elte.hu> <1300730838.2884.578.camel@edumazet-laptop>
	 <1300738540.2837.5.camel@edumazet-laptop>  <20110322095638.GA26130@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Arnd Bergmann <arnd@arndb.de>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34306 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665Ab1CVKAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 06:00:46 -0400
In-Reply-To: <20110322095638.GA26130@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 22 mars 2011 =C3=A0 10:56 +0100, Ingo Molnar a =C3=A9crit :
> * Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > [PATCH] ipvs: fix a typo in __ip_vs_control_init()
>=20
> This fix and Simon's:
>=20
>   IPVS: Use global mutex in ip_vs_app.c
>=20
> Did the trick here, the IPVS related SLAB corruptions are now gone.
>=20
> Thanks guys!

Thanks for testing Ingo ;)



