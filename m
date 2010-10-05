From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: relax rtnl_dereference()
Date: Tue, 05 Oct 2010 00:29:59 -0700 (PDT)
Message-ID: <20101005.002959.45905767.davem@davemloft.net>
References: <20101003094221.GA2028@del.dom.local>
	<1286181729.18293.8.camel@edumazet-laptop>
	<1286182812.18293.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, netdev@vger.kernel.org, jarkao2@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60620
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753882Ab0JEH3i convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 03:29:38 -0400
In-Reply-To: <1286182812.18293.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 04 Oct 2010 11:00:12 +0200

> Le lundi 04 octobre 2010 =E0 10:42 +0200, Eric Dumazet a =E9crit :
>=20
>> BTW, rtnl_dereference() should be changed to use
>> rcu_dereference_protected() instead of rcu_dereference_check() :
>> If RTBL is held, there is no need to force a barrier.
>>=20
>=20
> [PATCH net-next] net: relax rtnl_dereference()
>=20
> rtnl_dereference() is used in contexts where RTNL is held, to fetch a=
n
> RCU protected pointer.
> =20
> Updates to this pointer are prevented by RTNL, so we dont need
> smp_read_barrier_depends() and the ACCESS_ONCE() provided in
> rcu_dereference_check().
>=20
> rtnl_dereference() is mainly a macro to document the locking invarian=
t.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
