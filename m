From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv4: add rcu annotations in route.c
Date: Fri, 17 Sep 2010 15:59:30 -0700 (PDT)
Message-ID: <20100917.155930.219742425.davem@davemloft.net>
References: <1284739159.3391.95.camel@edumazet-laptop>
	<1284753573.4373.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50743
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752478Ab0IQW7L convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Sep 2010 18:59:11 -0400
In-Reply-To: <1284753573.4373.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 Sep 2010 21:59:33 +0200

> Le vendredi 17 septembre 2010 =E0 17:59 +0200, Eric Dumazet a =E9crit=
 :
>> Use __rcu attribute where appropriate.
>>=20
>> Use rcu_dereference_raw() in contexts where no lock is held.
>>=20
>> Use rcu_dereference_check() in contexts where the chain spinlock is
>> held.
>=20
> Hmm, it should be rcu_dereference_protected(), I'll send a v2

Ok.
