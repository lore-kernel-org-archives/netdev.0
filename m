From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tunnels: Fix tunnels change rcu protection
Date: Wed, 27 Oct 2010 14:21:00 -0700 (PDT)
Message-ID: <20101027.142100.226782695.davem@davemloft.net>
References: <4CC848B9.1060406@parallels.com>
	<1288206172.2658.11.camel@edumazet-laptop>
	<1288206372.2658.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59078
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932342Ab0J0VUh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Oct 2010 17:20:37 -0400
In-Reply-To: <1288206372.2658.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Oct 2010 21:06:12 +0200

> Le mercredi 27 octobre 2010 =E0 21:02 +0200, Eric Dumazet a =E9crit :
>=20
>=20
>> Hmm, maybe we should allocate a "struct ip_tunnel_parm" instead of u=
sing
>> an embedded one (in struct ip_tunnel), and stick an rcu_head in it t=
o
>> delay its freeing...
>>=20
>=20
> I forgot to Ack your patch, of course.
>=20
> We can implement something better when net-next-2.6 re-opens.
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
