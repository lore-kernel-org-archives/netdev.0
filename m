From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] ipv6: all routes share same inetpeer
Date: Thu, 21 Jul 2011 21:25:15 -0700 (PDT)
Message-ID: <20110721.212515.1987592113208079688.davem@davemloft.net>
References: <20110719.115929.106510307852361614.davem@davemloft.net>
	<1311139774.3113.86.camel@edumazet-laptop>
	<1311142716.3113.104.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60096 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741Ab1GVEZR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 00:25:17 -0400
In-Reply-To: <1311142716.3113.104.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Jul 2011 08:18:36 +0200

> Le mercredi 20 juillet 2011 =E0 07:29 +0200, Eric Dumazet a =E9crit :
>=20
>> My first patch had an issue in rt6_alloc_cow(), line 710, where=20
>> ipv6_addr_equal(&rt->rt6i_dst.addr, daddr) becomes always true.
>>=20
>> I guess I can replace it by ipv6_addr_equal(&ort->rt6i_dst.addr, dad=
dr)
>>=20
>>=20
>=20
> Here the combo patch I tested :
>=20
> I also had to solve the icmp6_dst_alloc() problem
> [it uses dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 255);]
>=20
> Note : this is based on net-2.6, but I really tested it on net-next-2=
=2E6
> (with the frag ident patch applied too)
>=20
> [PATCH] ipv6: unshare inetpeers

I applied this to net-next and queued it up for -stable, thanks!
