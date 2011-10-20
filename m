From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic from tg3 net driver
Date: Thu, 20 Oct 2011 22:17:47 +0200
Message-ID: <1319141867.2854.19.camel@edumazet-laptop>
References: <CAEbykaX4UPDBxOHmNr=dodaquSPjhPr-pLCcUn5hSu4-xLZy-g@mail.gmail.com>
	 <20111020.155659.486754557434415381.davem@davemloft.net>
	 <1319141125.2854.14.camel@edumazet-laptop>
	 <20111020.161147.33259825921677777.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ari.m.savolainen@gmail.com, richardcochran@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111020.161147.33259825921677777.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 20 octobre 2011 =C3=A0 16:11 -0400, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 20 Oct 2011 22:05:25 +0200
>=20
> > And I think this was fixed yesterday ?
> >=20
> > De: 	roy.qing.li@gmail.com
> > =C3=80: 	ari.m.savolainen@gmail.com, netdev@vger.kernel.org
> > Sujet: 	[PATCH net-next] neigh: fix rcu splat in neigh_update()
> > Date: 	Tue, 18 Oct 2011 16:32:42 +0800 (18/10/2011 10:32:42)
> >=20
>=20
> Good catch, it seems to be this bug.

Oh well, sorry, it seems it was one bug hit during bisection, but maybe
its completely unrelated to the real problem.
