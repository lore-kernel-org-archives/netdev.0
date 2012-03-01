From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Thu, 01 Mar 2012 04:26:42 -0800
Message-ID: <1330604802.2465.43.camel@edumazet-laptop>
References: <4F4B8C66.5060206@collabora.co.uk>
	 <20120227.140535.1623396420455657443.davem@davemloft.net>
	 <1330426059.2139.21.camel@megeve>
	 <20120228.140558.1132853996225815681.davem@davemloft.net>
	 <4F4F641E.7000501@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rodrigo.moya@collabora.co.uk,
	javier@collabora.co.uk, lennart@poettering.net,
	kay.sievers@vrfy.org, alban.crequy@collabora.co.uk,
	bart.cerneels@collabora.co.uk, sjoerd.simons@collabora.co.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F4F641E.7000501@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 01 mars 2012 =C3=A0 12:57 +0100, Javier Martinez Canillas a =C3=
=A9crit :

> Yes, you are right it doesn't follow AF_UNIX semantics so Unix socket=
s
> is not the best place to add our multicast implementation.
>=20

Right, AF_UNIX is already a nightmare to maintain.

> So, now we are trying a different approach. To create a new address
> family AF_MCAST. That way we can have more control over the semantics=
 of
> the socket interface for that family.
>=20
> We expect to have some patches in a few days and we will resend.
>=20
> Does this makes more sense to you?
>=20

Why adding an obscure set of IPC mechanism in network tree, and not
using (maybe extending) traditional IPC (Messages queues, semaphores,
Shared memory, pipes, futexes, ...).
