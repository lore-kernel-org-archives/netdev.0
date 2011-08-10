From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix potential neighbour race in dst_ifdown()
Date: Tue, 09 Aug 2011 21:47:50 -0700 (PDT)
Message-ID: <20110809.214750.1834270193519738636.davem@davemloft.net>
References: <1312002053.2873.41.camel@edumazet-laptop>
	<20110803.033442.1456080508068739176.davem@davemloft.net>
	<1312872974.2531.51.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: synapse@hippy.csoma.elte.hu, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850Ab1HJEsK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 00:48:10 -0400
In-Reply-To: <1312872974.2531.51.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 09 Aug 2011 08:56:14 +0200

> Le mercredi 03 ao=FBt 2011 =E0 03:34 -0700, David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Sat, 30 Jul 2011 07:00:53 +0200
>>=20
>> > [PATCH] net: fix NULL dereferences in check_peer_redir()
>>=20
>> I'm adding this now to my tree so it gets more widespread
>> testing.
>=20
> Thanks David
>=20
> We probably have other races, here is a followup patch, probably suit=
ed
> for net-next, since its not clear if its a real problem while device =
is
> unregistering. Consider it as a cleanup at very least.
>=20
> [PATCH] net: fix potential neighbour race in dst_ifdown()
>=20
> Followup of commit f2c31e32b378a (fix NULL dereferences in
> check_peer_redir()).
>=20
> We need to make sure dst neighbour doesnt change in dst_ifdown().
>=20
> Fix some sparse errors.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Ok, applied.  I'll keep working to eliminate dst->_neighbour entirely
as that's a better long term solution I think :-)
