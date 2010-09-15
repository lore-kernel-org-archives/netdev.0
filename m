From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipip: get rid of ipip_lock
Date: Wed, 15 Sep 2010 14:29:43 -0700 (PDT)
Message-ID: <20100915.142943.13758184.davem@davemloft.net>
References: <1284571676.2462.20.camel@edumazet-laptop>
	<1284583777.2462.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39665
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752456Ab0IOV3Z convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 17:29:25 -0400
In-Reply-To: <1284583777.2462.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 15 Sep 2010 22:49:37 +0200

> Le mercredi 15 septembre 2010 =E0 19:28 +0200, Eric Dumazet a =E9crit=
 :
>> As RTNL is held while doing tunnels inserts and deletes, we can remo=
ve
>> ipip_lock spinlock. My initial RCU conversion was conservative and
>> converted the rwlock to spinlock, with no RTNL requirement.
>>=20
>> Use appropriate rcu annotations and modern lockdep checks as well.
>>=20
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> While doing ip_gre conversion, I realize I should define a new helper
=2E..
> I'll submit a patch serie :
>=20
> 1/3) net: add rtnl_dereference
> 2/3) ipip: get rid of ipip_lock
> 3/3) gre: get rid of ipgre_lock

Ok.
