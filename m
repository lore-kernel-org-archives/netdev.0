From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] : __in_dev_get_rtnl() can use
 rtnl_dereference()
Date: Mon, 06 Dec 2010 13:00:15 -0800 (PST)
Message-ID: <20101206.130015.246519364.davem@davemloft.net>
References: <1291202063-6239-1-git-send-email-amwang@redhat.com>
	<1291202476.2856.584.camel@edumazet-laptop>
	<1291203462.2856.607.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: amwang@redhat.com, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291203462.2856.607.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Dec 2010 12:37:42 +0100

> Le mercredi 01 d=E9cembre 2010 =E0 12:21 +0100, Eric Dumazet a =E9cri=
t :
>=20
>> Same here. RTNL is held. Please use __in_dev_get_rtnl()
>=20
> By the way we can use rtnl_dereference() in __in_dev_get_rtnl()
>=20
> [PATCH net-next-2.6] : __in_dev_get_rtnl() can use rtnl_dereference()
>=20
> If caller holds RTNL, we dont need a memory barrier
> (smp_read_barrier_depends) included in rcu_dereference().
>=20
> Just use rtnl_dereference() to properly document the assertions.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
