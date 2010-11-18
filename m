From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: IGMP handling cleanup
Date: Thu, 18 Nov 2010 09:33:30 -0800 (PST)
Message-ID: <20101118.093330.39181120.davem@davemloft.net>
References: <1290073388.2781.12.camel@edumazet-laptop>
	<1290075978.2781.36.camel@edumazet-laptop>
	<1290077352.2781.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sachinp@in.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, linux-next@vger.kernel.org,
	ursula.braun@de.ibm.com, fubar@us.ibm.com
To: eric.dumazet@gmail.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1290077352.2781.47.camel@edumazet-laptop>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Nov 2010 11:49:12 +0100

> Le jeudi 18 novembre 2010 =E0 11:26 +0100, Eric Dumazet a =E9crit :
>=20
>> Actually this raises an interesting case for bonding as well.
>>=20
>> Before my RCU conversion __bond_resend_igmp_join_requests() was unsa=
fe.
>>=20
>> For net-next-2.6, it is now safe (RCU is held), but needs a cleanup
>> patch to avoid sparse errors.
>=20
> [PATCH net-next-2.6] bonding: IGMP handling cleanup
>=20
> Instead of iterating in_dev->mc_list from bonding driver, its better
> to call a helper function provided by igmp.c
> Details of implementation (locking) are private to igmp code.
>=20
> ip_mc_rejoin_group(struct ip_mc_list *im) becomes
> ip_mc_rejoin_groups(struct in_device *in_dev);
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: Sachin Sant <sachinp@in.ibm.com>

Applied, thanks Eric.
