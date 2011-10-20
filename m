From: David Miller <davem@davemloft.net>
Subject: Re: Kernel panic from tg3 net driver
Date: Thu, 20 Oct 2011 16:11:47 -0400 (EDT)
Message-ID: <20111020.161147.33259825921677777.davem@davemloft.net>
References: <CAEbykaX4UPDBxOHmNr=dodaquSPjhPr-pLCcUn5hSu4-xLZy-g@mail.gmail.com>
	<20111020.155659.486754557434415381.davem@davemloft.net>
	<1319141125.2854.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ari.m.savolainen@gmail.com, richardcochran@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319141125.2854.14.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Oct 2011 22:05:25 +0200

> And I think this was fixed yesterday ?
>=20
> De: 	roy.qing.li@gmail.com
> =C0: 	ari.m.savolainen@gmail.com, netdev@vger.kernel.org
> Sujet: 	[PATCH net-next] neigh: fix rcu splat in neigh_update()
> Date: 	Tue, 18 Oct 2011 16:32:42 +0800 (18/10/2011 10:32:42)
>=20

Good catch, it seems to be this bug.
