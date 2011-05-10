From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.39-rc6-mmotm0506 - another lockdep splat (networking this
 time)
Date: Tue, 10 May 2011 23:48:36 +0200
Message-ID: <1305064116.2437.34.camel@edumazet-laptop>
References: <6954.1304989523@localhost>
	 <1304994188.3050.17.camel@edumazet-laptop>
	 <1304999271.3050.41.camel@edumazet-laptop>
	 <20110509.205851.189693332.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis.Kletnieks@vt.edu, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110509.205851.189693332.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 09 mai 2011 =C3=A0 20:58 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 10 May 2011 05:47:51 +0200
>=20
> > [PATCH net-next-2.6] net: fix two lockdep splats
> >=20
> > Commit e67f88dd12f6 (net: dont hold rtnl mutex during netlink dump
> > callbacks) switched rtnl protection to RCU, but we forgot to adjust=
 two
> > rcu_dereference() lockdep annotations :
> >=20
> > inet_get_link_af_size() or inet_fill_link_af() might be called with
> > rcu_read_lock or rtnl held, so use rcu_dereference_rtnl()
> > instead of rtnl_dereference()
> >=20
> > Reported-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied, thanks everyone.

David, I found you applied this patch for net-2.6, but it was
net-next-2.6 material only ...
