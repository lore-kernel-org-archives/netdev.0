From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] neigh: fix rcu splat in neigh_update()
Date: Wed, 19 Oct 2011 19:39:10 -0400 (EDT)
Message-ID: <20111019.193910.388701305423765916.davem@davemloft.net>
References: <1318926762-14563-1-git-send-email-roy.qing.li@gmail.com>
	<1318929095.2657.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roy.qing.li@gmail.com, ari.m.savolainen@gmail.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754680Ab1JSXjO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 19:39:14 -0400
In-Reply-To: <1318929095.2657.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 18 Oct 2011 11:11:35 +0200

> Le mardi 18 octobre 2011 =E0 16:32 +0800, roy.qing.li@gmail.com a =E9=
crit :
>> when use dst_get_neighbour to get neighbour, we need=20
>> rcu_read_lock to protect, since dst_get_neighbour uses
>> rcu_dereference.
>>=20
>> The bug was reported by Ari Savolainen <ari.m.savolainen@gmail.com>
>>=20
> ...
>>=20
>> Reported-by: Ari Savolainen <ari.m.savolainen@gmail.com>
>> Signed-off-by: RongQing <roy.qing.li@gmail.com>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
