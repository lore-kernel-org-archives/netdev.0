From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/3] af_key: locking change
Date: Fri, 19 Feb 2010 21:53:14 -0800
Message-ID: <20100219215314.66d6f857@nehalam>
References: <20100219215913.819285957@vyatta.com>
	<20100219220111.868268353@vyatta.com>
	<1266638850.2839.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Peter Oberparleiter <oberpar@linux.vnet.ibm.com>,
	Miklos Szeredi <mszeredi@suse.cz>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, Jiri Olsa <jolsa@redhat.com>,
	Ingo Molnar <mingo@elte.hu>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54091 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929Ab0BTFxt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Feb 2010 00:53:49 -0500
In-Reply-To: <1266638850.2839.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 20 Feb 2010 05:07:30 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le vendredi 19 f=C3=A9vrier 2010 =C3=A0 13:59 -0800, Stephen Hemminge=
r a =C3=A9crit :
> > pi=C3=A8ce jointe document texte brut (pfkey-rcu.patch)
> > Get rid of custom locking that was using wait queue, lock, and atom=
ic
> > to basically build a queued mutex.  Use RCU for read side.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> Excellent
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> I dont know why you used synchronize_sched() instead of
> synchronize_rcu().

I'll go back to synchronize_rcu.

--=20
