From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: add DiffServ priority based routing
Date: Fri, 15 Jan 2010 09:24:36 +0100
Message-ID: <4B502644.4070000@gmail.com>
References: <20100112.121607.39835310.davem@davemloft.net>	<201001141250.27287.schmto@hrz.tu-chemnitz.de>	<4B4F132B.7020001@gmail.com> <20100114.165142.163322281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torsten.schmidt@s2006.tu-chemnitz.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55637 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754874Ab0AOIYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 03:24:41 -0500
In-Reply-To: <20100114.165142.163322281.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/01/2010 01:51, David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 14 Jan 2010 13:50:51 +0100
>=20
>> Problem is, you might need many sets of counters...
>=20
> Why nobody has suggested using existing kernel facilities for this is
> beyond me.
>=20
> We have a diffserv packet scheduler queueing discipline, so you can
> classify traffic arbitrarily based upon the diffserv bits in the
> packet and then shape them using that classification into different
> packet scheduler queues.
>=20
> Simply attach those child queues to that default pfifo qdisc, nothing
> fancy.
>=20
> Then you can dump the queue stats using 'tc'.

Well, its a good idea but it has drawbacks, for example if your eth0 de=
vice
has 64 tx queues. Parsing tc output can be... interesting :)

